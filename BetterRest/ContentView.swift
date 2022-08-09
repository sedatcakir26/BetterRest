//
//  ContentView.swift
//  BetterRest
//
//  Created by Sedat Çakır on 7.08.2022.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var title = ""
    @State private var message = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    
    
    var body: some View {
        NavigationView{
            Form{
                Section {
                Text("When do you want to wake up")
                    .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                        .onChange(of: wakeUp) { newValue in
                                     calculateBedTime()
                                   }
                }
                Section {
                Text("Desired amount of sleep")
                    .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in:4...12, step: 0.25)
                        .onChange(of: sleepAmount) { newValue in
                                     calculateBedTime()
                                   }
                    }
                Section {
                    Picker( "Daily coffee intake", selection: $coffeeAmount){
                        ForEach(1..<21) { index in
                            Text("\(index)")
                        }
                        .onChange(of: coffeeAmount) { newValue in
                                     calculateBedTime()
                                   }
                    }
                    //Stepper(coffeeAmount == 1 ? "1 cup": "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                Section{
                Text("\(title) \(message)")
                        .font(.largeTitle)
                }
            }
           /*
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calculate", action: calculateBedTime)
            }
            */
            
           
        }
        .onAppear(perform: calculateBedTime)
    }
    
    func calculateBedTime() {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            print("hour:\(hour) minute:\(minute)")
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            print("wake up : \(wakeUp) Sleep Time:\(sleepTime)")
            
            title = "Your ideal bedtime is "
            message = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }catch{
            title = "Error"
            message = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
