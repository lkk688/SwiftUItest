//
//  GestureDragView.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 2/20/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

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
 
    var isPressing: Bool {
        switch self {
        case .pressing, .dragging:
            return true
        case .inactive:
            return false
        }
    }
}

struct GestureDragView: View {
    @GestureState private var dragState = DragState.inactive
    @State private var position = CGSize.zero
    
    var body: some View {
        Image(systemName: "star.circle.fill")
            .font(.system(size: 100))
            .opacity(dragState.isPressing ? 0.5 : 1.0)
            .offset(x: position.width + dragState.translation.width, y: position.height + dragState.translation.height)
            .animation(.easeInOut)
            .foregroundColor(.green)
            .gesture(
                LongPressGesture(minimumDuration: 1.0)
                    .sequenced(before: DragGesture())
                    .updating($dragState, body: { (value, state, transaction) in
                        
                        switch value {
                        case .first(true):
                            state = .pressing
                        case .second(true, let drag):
                            state = .dragging(translation: drag?.translation ?? .zero)
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
                        //When the drag ends, the onEnded function will be called. Similarly, we update the final position by figuring out the drag data (i.e. .second case).
                    })
        )
    }
}

struct GestureDragView_Previews: PreviewProvider {
    static var previews: some View {
        GestureDragView()
    }
}
