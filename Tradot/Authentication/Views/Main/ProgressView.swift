//
//  ProgressView.swift
//  Tradot
//
//  Created by Fiifi!!!!!  on 13/11/2025.
//

import SwiftUI

struct AppProgressView: View {
    var body: some View {
        Text("Posting job...")
            .foregroundColor(.white)
            .frame(width: 200, height: 100)
            .background(Color.teal)
            .cornerRadius(48)
            
    }
}

struct AppProgressView_Previews: PreviewProvider {
    static var previews: some View {
        AppProgressView()
    }
}
