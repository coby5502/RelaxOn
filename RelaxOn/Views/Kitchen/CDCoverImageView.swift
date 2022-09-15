//
//  CDCoverImageView.swift
//  RelaxOn
//
//  Created by 김연호 on 2022/08/06.
//

import SwiftUI

struct CDCoverImageView: View {
    // MARK: - State Properties
    var selectedImageNames: (base: String, melody: String, whiteNoise: String)
    
    // MARK: - Life Cycles
    var body: some View {
        ZStack {
            IllustImage(imageName: selectedImageNames.base)
            IllustImage(imageName: selectedImageNames.melody)
            IllustImage(imageName: selectedImageNames.whiteNoise)
        }
        .cornerRadius(4)
    }
}

// MARK: - ViewBuilder
extension CDCoverImageView {
    @ViewBuilder
    func toBlurBackground() -> some View {
        GeometryReader { proxy in
            self
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .blur(radius: 30)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func addDefaultBackground() -> some View {
        self
            .background {
                Rectangle()
                    .fill(.white.opacity(0.2))
            }
            .cornerRadius(4)
            .clipped()
    }
    
    @ViewBuilder
    func IllustImage(imageName: String) -> some View {
        if imageName.isEmpty {
            Rectangle()
                .fill(.clear)
        } else {
            Image(imageName)
                .resizable()
                
        }
    }
}
