//
//  ListenListCell.swift
//  RelaxOn
//
//  Created by Doyeon on 2023/05/18.
//

import SwiftUI

/**
 커스텀 음원의 각 정보가 셀 안에 노출되는 View
 */
struct ListenListCell: View {

    @EnvironmentObject var viewModel: CustomSoundViewModel
    var fileName: String

    var body: some View {
        HStack {
            
            Image(uiImage: viewModel.loadImage(fileName))
                .frame(width: 60, height: 60)
            
            Text(fileName)
                .font(.body)
                .bold()
            
            Spacer()
            
            Button(action: {
                viewModel.isPlaying.toggle()
            }) {
                Image(systemName: viewModel.playPauseStatusImage)
                    .padding()
                    .foregroundColor(.black)
            }
        }
    }
}

struct ListenListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListenListCell(fileName: "임시 타이틀")
    }
}
