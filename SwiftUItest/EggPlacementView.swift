//
//  EggPlacementView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 2/20/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct EggPlacementView: View {
    @Binding var eggPlacement: UnitPoint
    
    var body: some View {
        ZStack {
            Image("toast").resizable().aspectRatio(contentMode: .fit).padding()
            DraggableEgg(eggPlacement: $eggPlacement)
        }.navigationBarTitle(Text("Egg Placement"))
    }
}

struct DraggableEgg: View {
    
    @GestureState var dragState = DragState.inactive
    @Binding var eggPlacement: UnitPoint
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    var body: some View {
        let minimumLongPressDuration = 0.0
        let gesture = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                    
                // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
        }
        .onEnded { value in
            guard case .second(true, let drag?) = value else { return }
            self.eggPlacement.x += drag.translation.width//drag.location.x
            self.eggPlacement.y += drag.translation.height//drag.location.y
            
            //When the drag ends, the onEnded function will be called. Similarly, we update the final position by figuring out the drag data (i.e. .second case).
        }
    
        return Image("egg")
            .resizable()
            .overlay(dragState.isDragging ? Circle().stroke(Color.white, lineWidth: 2) : nil)
            .frame(width: 200, height: 200, alignment: .center)
            .offset(
                x: self.eggPlacement.x + dragState.translation.width,
                y: self.eggPlacement.y + dragState.translation.height
        )
            .animation(nil)
            .shadow(radius: dragState.isActive ? 8 : 0)
            .animation(.easeIn)
            .gesture(gesture)
    }
}

struct EggPlacementView_Previews: PreviewProvider {
    @State static var eggPlacement = UnitPoint()
    
    static var previews: some View {
        NavigationView {
            EggPlacementView(eggPlacement: $eggPlacement)
        }
    }
}
