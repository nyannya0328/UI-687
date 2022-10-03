//
//  Home.swift
//  UI-687
//
//  Created by nyannyan0328 on 2022/10/03.
//

import SwiftUI

struct Home: View {
    @State var messages : [Meesage] = []
    var body: some View {
        VStack{
            
            SwipeCrouse(items: messages, id: \.id) { message, size in
                
                Image(message.imageFile)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width,height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
             .frame(width: 220,height: 300)
        }
        .onAppear{
            
            for index in 1...5{
                
                messages.append(Meesage(imageFile: "p\(index)"))
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SwipeCrouse<Content : View,ID,Item> : View where Item:RandomAccessCollection,Item.Element:Equatable,Item.Element : Identifiable,ID:Hashable{
    
    
    var id : KeyPath<Item.Element,ID>
    var items : Item
    var content : (Item.Element,CGSize)->Content
    var trailingCard : Int
    
    
    init(items:Item,id:KeyPath<Item.Element,ID>,trailingCard : Int = 3,@ViewBuilder content : @escaping(Item.Element,CGSize)->Content){
        
        
        self.content = content
        self.id = id
        self.items = items
        self.trailingCard = trailingCard
        
    }
    
    @State var currentIndex : Int = 0
    
    @State var offset : CGFloat = 0
    
    @State var showRight : Bool = false
    
    
    var body: some View{
        
        GeometryReader{
            
           let size = $0.size
            
            ZStack{
                
                ForEach(items){item in
                    
                    CardView(item: item, size: size)
                        .overlay(content: {
                            
                            let index = indexOf(item: item)
                            
                            if (currentIndex + 1) == index && Array(items).indices.contains(currentIndex - 1) && showRight{
                                
                                CardView(item: Array(items)[currentIndex - 1], size: size)
                                
                            }
                            
                        })
                        
                        .zIndex(zIndexFor(item: item))
                    
                    
                }
              
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
            .gesture(
            
                DragGesture().onChanged({ value in
                    showRight = (value.translation.width > 0)
                    offset = (value.translation.width / (size.width + 30) * size.width)
                    
                    
                })
                .onEnded({ value in
                    
                    let translation = value.translation.width
                    
                    if translation > 0{
                        
                        deCrease(traslation: translation)
                        
                        
                        
                    }
                    else{
                        
                        inCrease(traslation: translation)
                        
                        
                    }
                    withAnimation(.easeInOut){
                        
                        offset = .zero
                    }
                    
                })
            )
        }
    }
    func rotationForGesture(index : Int)->CGFloat{
        
        let progress = (offset / screenSize.width) * 30
        
        return (currentIndex == index ? progress : 0)
        
    }
    
    func deCrease(traslation : CGFloat){
        
        
        if traslation > 0 && traslation > 100 && currentIndex > 0{
            
            
            withAnimation(.easeInOut(duration: 0.3)){
                
                currentIndex -= 1
            }
        }
        
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){

                showRight =  false


            }
        }

        
        
    }
    
    func inCrease(traslation : CGFloat){
        
        if traslation < 0 && traslation < 110 && currentIndex < (items.count - 1){
            
            withAnimation(.easeInOut(duration: 0.25)){
                
                currentIndex += 1
            }
          
            
            
            
        }
       
        
    }
    @ViewBuilder
    func CardView(item : Item.Element,size : CGSize) -> some View{
        
        let index = indexOf(item: item)
        
        content(item,size)
          .shadow(color: .black.opacity(0.07), radius: 5,x:5,y:5)
          .scaleEffect(scaleFor(item: item))
            .offset(x:offsetFor(item: item))
            .offset(x:currentIndex == index ? offset : 0)
            .rotationEffect(.init(degrees: rotationFor(item: item)),anchor: currentIndex  > index ? .topLeading : .topTrailing)
            .rotationEffect(.init(degrees: rotationForGesture(index: index)),anchor: .top)
            .scaleEffect(scaleFor(item: item))
    }
    
    func rotationFor(item : Item.Element) -> CGFloat{
        
        let index = indexOf(item: item) - currentIndex
        
        if index > 0{
            
            if index > trailingCard{
                
                return CGFloat(trailingCard) * 3
            }
            
            return CGFloat(index) * 3
            
            
        }
        
        if -index > trailingCard{
            
            
            return -CGFloat(trailingCard) * 3
        }
        
        return CGFloat(index) * 3
    }
    
    func scaleFor(item : Item.Element)->CGFloat{
        
        let index = indexOf(item: item) - currentIndex
        
        if index > 0{
            
            if index > trailingCard{
                
                return 1 - (CGFloat(trailingCard) / 10)
                
            }
            
            return 1 - (CGFloat(index) / 20)
            
        }
        
        if -index > trailingCard{
            
            return 1 - (CGFloat(trailingCard) / 20)
        }
        
        return 1 + (CGFloat(index) / 20)
        
        
    }
    
    func scaleForGesture(index : Int) -> CGFloat{
        
        let progress = 1 - ((offset > 0 ? offset : -offset) / screenSize.width)
        
        return (currentIndex == index ? (progress > 0.75 ? progress : 0) : 1)
        
    }
    
    func offsetFor(item : Item.Element)->CGFloat{
        
        let index = indexOf(item: item) - currentIndex
        
        if index > 0{
            
            if index > trailingCard{
                
               return 20 *  CGFloat(trailingCard)
            }
            return  CGFloat(index) * 20
        }
        
        if -index > trailingCard{
            
           return -20 * CGFloat(trailingCard)
        }
        return CGFloat(index) * 20
        
        
    }
    
    
    func zIndexFor(item : Item.Element)->Double{
        
        let index = indexOf(item: item)
        
        let totalCount = items.count
        
        return  currentIndex == index ? 10 : (currentIndex < index ? Double(totalCount - index) : Double(index - totalCount))
        
        
    }
    
    func indexOf(item : Item.Element)->Int{
        
        let arrayItems = Array(items)
        
        if let index = arrayItems.firstIndex(of: item){
            return index
            
        }
        return 0
    }
    
    var screenSize : CGSize = {
     
        
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return .zero}
        return window.screen.bounds.size
        
              }()
}
