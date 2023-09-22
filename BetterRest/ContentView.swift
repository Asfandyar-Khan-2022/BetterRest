//
//  ContentView.swift
//  BetterRest
//
//  Created by Mac User on 22/09/2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    // Default value for when to wakeup
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                // What time to wake up
                Section(header: Text("When do you want to wake up?").font(.headline)) {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents:
                            .hourAndMinute)
                            .labelsHidden()
                }
                
                // Hours of sleep wanted
                Section(header: Text("Desired amount of sleep").font(.headline)){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }.onChange(of: sleepAmount){ _ in
                    calculateBedtime()
                }
                
                // Daily coffee intake
                Section(header: Text("Daily coffee intake").font(.headline)){
                    Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("\($0)")
                        }
                    }.onChange(of: (coffeeAmount)) { _ in
                        calculateBedtime()
                    }
                }
                
                // Ideal bedtime calculated
                Section(header: Text("Your ideal bedtime is...").font(.headline)) {
                    Text(alertMessage)
                }
            }.onAppear(){
                calculateBedtime()
            }
        }
    }
    
    // Changes alertMessage property value to display the ideal bedtime
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
