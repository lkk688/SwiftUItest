//
//  ContentView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 2/14/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var isPressed = false
    
    @State var name: String = ""
    
    @GestureState private var longPressTap = false
    
    @GestureState private var dragOffset = CGSize.zero
    @State private var position = CGSize.zero
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .background(Color.green)
                .padding(10)
                
            
            
            HStack(alignment:.center) {
                //TextField("Enter your name", text: $name)
                Text("Your name: \(name)")
                TextField("Enter name...", text: $name, onEditingChanged: { (changed) in
                    print("Username onEditingChanged - \(changed)")
                }) {
                    print("Username onCommit")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            
            Image("testimg")
            
            
//            Image(systemName: "star.circle.fill")
//            .font(.system(size: 100))
//            .scaleEffect(isPressed ? 0.5 : 1.0)
//            .animation(.easeInOut)
//            .foregroundColor(.green)
//            .gesture(
//                TapGesture()
//                    .onEnded({
//                        print("Tapped!")
//                        self.isPressed.toggle()
//                    })
//            )
            
//            Image(systemName: "star.circle.fill")
//            .font(.system(size: 100))
//            .opacity(longPressTap ? 0.4 : 1.0)
//            .scaleEffect(isPressed ? 0.5 : 1.0)
//            .animation(.easeInOut)
//            .foregroundColor(.green)
//            .gesture(
//                LongPressGesture(minimumDuration: 1.0)
//                .updating($longPressTap, body: { (currentState, state, transaction) in
//                    state = currentState
//                })
//                    .onEnded({_ in
//                        print("Tapped!")
//                        self.isPressed.toggle()
//                    })
//            )
            
//            Image(systemName: "star.circle.fill")
//                   .font(.system(size: 100))
//                   .offset(x: position.width + dragOffset.width, y: position.height + dragOffset.height)
//                   .animation(.easeInOut)
//                   .foregroundColor(.green)
//                   .gesture(
//                       DragGesture()
//                           .updating($dragOffset, body: { (value, state, transaction) in
//                               state = value.translation
//                           })
//                           .onEnded({ (value) in
//                               self.position.height += value.translation.height
//                               self.position.width += value.translation.width
//                           })
//                   )
            
            Image(systemName: "star.circle.fill")
            .font(.system(size: 100))
            .opacity(longPressTap ? 0.5 : 1.0)
            .offset(x: position.width + dragOffset.width, y: position.height + dragOffset.height)
            .animation(.easeInOut)
            .foregroundColor(.green)
            .gesture(
                LongPressGesture(minimumDuration: 1.0)
                    .updating($longPressTap, body: { (currentState, state, transaction) in
                        state = currentState
                    })
                    .sequenced(before: DragGesture())
                    .updating($dragOffset, body: { (value, state, transaction) in
                        switch value {
                        case .first(true):
                            print("Tapping")
                        case .second(true, let drag):
                            state = drag?.translation ?? .zero
                        default:
                            break
                        }
                    })
                    .onEnded({ (value) in
                        guard case .second(true, let drag?) = value else {
                            return
                        }
                        self.position.height += drag.translation.height
                        self.position.width += drag.translation.width
                    })
            )
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
