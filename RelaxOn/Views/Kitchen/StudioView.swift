//
//  StudioView.swift
//  LullabyRecipe
//
//  Created by 김연호 on 2022/07/23.
//

import SwiftUI

struct StudioView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var select: Int = 0
    @State private var showingAlert = false
    @State private var selectedBaseSound: Sound = Sound(id: 0,
                                                        name: "",
                                                        soundType: .base,
                                                        audioVolume: 0.8,
                                                        imageName: "")
    @State private var selectedMelodySound: Sound = Sound(id: 10,
                                                          name: "",
                                                          soundType: .melody,
                                                          audioVolume: 1.0,
                                                          imageName: "")
    @State private var selectedNaturalSound: Sound = Sound(id: 20,
                                                           name: "",
                                                           soundType: .natural,
                                                           audioVolume: 0.4,
                                                           imageName: "")
    @State private var userName: String = ""
    @State private var textEntered = ""
    
    @State private var selectedImageNames: (base: String, melody: String, natural: String) = (
        base: "",
        melody: "",
        natural: ""
    )
    
    @State private var opacityAnimationValues = [0.0, 0.0, 0.0]
    
    @State var volumes: [Float] = [0.5, 0.5, 0.5]
    
    let baseAudioManager = AudioManager()
    let melodyAudioManager = AudioManager()
    let naturalAudioManager = AudioManager()

    private var items = ["BASE", "MELODY", "NATURAL"]
    init(){
        Theme.navigationBarColors(background: .white, titleColor: .black)
        UINavigationBar.appearance().standardAppearance.shadowColor = .clear
    }

    var body: some View {
        ZStack{
            VStack {
                SelectedImageVIew(selectedImageNames: $selectedImageNames, opacityAnimationValues: $opacityAnimationValues)
                CustomSegmentControlView(items: items, selection: $select)
                switch select {
                case 1:
                    SoundSelectView(sectionTitle: "Melody",
                                    soundType: .melody)
                case 2:
                    SoundSelectView(sectionTitle: "Natural Sound",
                                    soundType: .natural)
                default:
                    SoundSelectView(sectionTitle: "Base Sound",
                                    soundType: .base)
                }
            }
            .navigationBarItems(leading: Text("STUDIO").bold(), trailing: MixButton())
            .navigationBarHidden(false)
            .opacity(showingAlert ? 0.5 : 1)
            
            CustomAlertView(textEntered: $textEntered,
                        showingAlert: $showingAlert)
            .opacity(showingAlert ? 1 : 0)
        }
    }

    
    private func getEncodedData(data: [MixedSound]) -> Data? {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            return encodedData
        } catch {
            print("Unable to Encode Note (\(error))")
        }
        return nil
    }
    
    @ViewBuilder
    func SoundSelectView(sectionTitle: String,
                         soundType: SoundType) -> some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "speaker.wave.1.fill")
                    .frame(width: 18.0, height: 18.0)
                    .foregroundColor(.white)
                
                VolumeSlider(value: $volumes[select], range: (0, 1), knobWidth: 14) { modifiers in
                  ZStack {
                    Color.white.cornerRadius(3).frame(height: 2).modifier(modifiers.barLeft)
                    Color.white.opacity(0.4).cornerRadius(3).frame(height: 2).modifier(modifiers.barRight)
                    ZStack {
                      Circle().fill(Color.white)
                    }.modifier(modifiers.knob)
                  }
                }
                .frame(height: 25)
                .onChange(of: volumes[0]) { volume in
                    baseAudioManager.changeVolume(track: selectedBaseSound.name, volume: volume)
                }
                .onChange(of: volumes[1]) { volume in
                    naturalAudioManager.changeVolume(track: selectedNaturalSound.name, volume: volume)
                }
                .onChange(of: volumes[2]) { volume in
                    melodyAudioManager.changeVolume(track: selectedMelodySound.name, volume: volume)
                }
                
                Text("\(Int(volumes[select] * 100))")
                    .font(.body)
                    .foregroundColor(.systemGrey1)
                    .frame(maxWidth: 30)
            }.background(Color.black) // 나중에 삭제할 예정
                .padding([.horizontal])
            
            ScrollView(.vertical,
                       showsIndicators: false) {
                HStack(spacing: 30) {
                    switch soundType {
                    case .base:
                            RadioButtonGroupView(selectedId: soundType.rawValue,
                                         items: baseSounds) { baseSelected in
                            selectedBaseSound = baseSelected
                            // play music

                            if selectedBaseSound.name == "Empty" {
                                baseAudioManager.stop()
                                
                                opacityAnimationValues[0] = 0.0
                            } else {
                                baseAudioManager.startPlayer(track: selectedBaseSound.name, volume: volumes[select])
                                
                                selectedImageNames.base = selectedBaseSound.imageName
                                opacityAnimationValues[0] = 0.5
                            }
                        }
                    case .natural:
                            RadioButtonGroupView(selectedId: soundType.rawValue,
                                         items: naturalSounds) { naturalSounds in
                            selectedNaturalSound = naturalSounds

                            if selectedNaturalSound.name == "Empty" {
                                naturalAudioManager.stop()
                                
                                opacityAnimationValues[2] = 0.0
                            } else {
                                naturalAudioManager.startPlayer(track: selectedNaturalSound.name, volume: volumes[select])
                                
                                selectedImageNames.natural = selectedNaturalSound.imageName
                                
                                opacityAnimationValues[2] = 0.5
                            }
                        }
                    case .melody:
                            RadioButtonGroupView(selectedId: soundType.rawValue,
                                         items: melodySounds) { melodySounds in
                            selectedMelodySound = melodySounds
                            
                            if selectedMelodySound.name == "Empty" {
                                melodyAudioManager.stop()
                                
                                opacityAnimationValues[1] = 0.0
                            } else {
                                melodyAudioManager.startPlayer(track: selectedMelodySound.name, volume: volumes[select])
                                
                                selectedImageNames.melody = selectedMelodySound.imageName
                                
                                opacityAnimationValues[1] = 0.5
                                
                            }
                        }
                    }
                }
            }.padding(.horizontal, 15)
        }
    }

    @ViewBuilder
    func MixButton() -> some View {
        NavigationLink(destination: StudioNamingView(selectedImageNames: $selectedImageNames, opacityAnimationValues: $opacityAnimationValues)) {
            Text("Mix")
                .foregroundColor( ($selectedBaseSound.id == 0 && $selectedMelodySound.id == 10 && $selectedNaturalSound.id == 20) ? Color.gray : Color.black )
        }.disabled( ($selectedBaseSound.id == 0 && $selectedMelodySound.id == 10 && $selectedNaturalSound.id == 20) ? true : false )
    }
//        Button {
//            showingAlert = true
//
//            baseSound = selectedBaseSound
//            melodySound = selectedMelodySound
//            naturalSound = selectedNaturalSound
//
//            baseAudioManager.stop()
//            melodyAudioManager.stop()
//            naturalAudioManager.stop()
//
//            self.textEntered = ""
////        } label: {
//            Text("Mix")
//                .foregroundColor( ($selectedBaseSound.id == 0 && $selectedMelodySound.id == 10 && $selectedNaturalSound.id == 20) ? Color.gray : Color.black )
//        }.disabled( ($selectedBaseSound.id == 0 && $selectedMelodySound.id == 10 && $selectedNaturalSound.id == 20) ? true : false )
//    }
}

struct StudioView_Previews: PreviewProvider {
    static var previews: some View {
        StudioView()
    }
}
