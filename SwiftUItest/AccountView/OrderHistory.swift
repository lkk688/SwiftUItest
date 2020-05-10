//
//  OrderHistory.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 2/20/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import SwiftUI

struct OrderHistory: View {
    @EnvironmentObject var userData: UserData
    //var completedOrders: [CompletedOrder]
    
    @State var showSheetView = false
    
    var body: some View {
        List {
            ForEach(userData.historyorder) { order in
                NavigationLink(destination: CompleteOrderDetail(order: order)) {
                    CompletedOrderCell(order: order)
                }
            }.onDelete(perform: deleteRow)
        }.navigationBarTitle(Text("History"))//, displayMode: .inline
        .navigationBarItems(
          trailing: Button(action: {self.showSheetView.toggle()
            
          }, label: { Image(systemName: "bell.circle.fill")
          .font(Font.system(.title))
          })
        )
        .sheet(isPresented: $showSheetView) {
            SheetView(showSheetView: self.$showSheetView)
        }
//        List(completedOrders) { order in
//            NavigationLink(destination: CompleteOrderDetail(order: order)) {
//                CompletedOrderCell(order: order)
//            }
//        }.navigationBarTitle(Text("History"))//, displayMode: .inline
    }
    
    private func addOrder() {
        print("add Order")
//        NavigationLink(destination: OrderForm()) {
//            Text("Action")
//        }
//        NavigationLink(destination: OrderForm(), label: Text("Action"))
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        //completedOrders.remove(atOffsets: indexSet)
        print("Delete Row")
        userData.historyorder.remove(atOffsets: indexSet)
    }
}

struct SheetView: View {
    @Binding var showSheetView: Bool
    var body: some View {
        NavigationView {
            Text("List of notifications")
            .navigationBarTitle(Text("Notifications"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing sheet view...")
                self.showSheetView = false
            }) {
                Text("Done").bold()
            })
        }
    }
}



struct CompletedOrderCell: View {
    var order: CompletedOrder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(order.summary)
                Text(order.purchaseDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack {
                ForEach(order.toppings, id: \.self) { topping in
                    ToppingIcon(topping: topping)
                }
            }
        }
    }
}



struct ToppingIcon: View {
    var topping: Toppings
    
    var body: some View {
        ZStack() {
            Circle().foregroundColor(toppingColor(topping: topping))
                .frame(width: 20, height: 20)
            
            Text(String(topping.rawValue.first ?? "?").uppercased())
                .foregroundColor(.white)
                .font(.system(size: 10))
        }
        
    }
    
    func toppingColor(topping: Toppings) -> Color {
        switch topping {
        case .salt:
            return .black
        case .redPepperFlakes:
            return .red
        case .eggs:
            return .yellow
        case .paprica:
            return .orange
        case .chives:
            return .green
        case .pickledOnion:
            return .pink
        case .watermelonRadish:
            return .purple
        }
    }
}

struct OrderHistory_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHistory().environmentObject(UserData())
        }
    }
}
