//
//  VolumeControlView.swift
//  LullabyRecipe
//
//  Created by hyunho lee on 2022/05/29.
//

import SwiftUI

struct VolumeControlView: View {
    
    @Binding var showVolumeControl: Bool
    @Binding var audioVolumes: (baseVolume: Float, melodyVolume: Float, naturalVolume: Float)
    
    let data: MixedSound
    let baseAudioManager = AudioManager()
    let melodyAudioManager = AudioManager()
    let naturalAudioManager = AudioManager()
    @State var hasShowAlert: Bool = false
    
    var body: some View {
        ZStack {
            ColorPalette.tabBackground.color.ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        showVolumeControl.toggle()
                        baseAudioManager.stop()
                        melodyAudioManager.stop()
                        naturalAudioManager.stop()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Volume Control").WhiteTitleText()
                    Spacer()
                    Button {
                        //showVolumeControl.toggle()
                        baseAudioManager.stop()
                        melodyAudioManager.stop()
                        naturalAudioManager.stop()
                        // TODO: - 볼륨 저장
                        guard let localBaseSound = data.baseSound,
                              let localMelodySound = data.melodySound,
                              let localNaturalSound = data.naturalSound else { return }
                        
                        let newBaseSound = Sound(id: localBaseSound.id,
                                                 name: localBaseSound.name,
                                                 soundType: localBaseSound.soundType,
                                                 audioVolume: audioVolumes.baseVolume,
                                                 imageName: localBaseSound.imageName)
                        let newMelodySound = Sound(id: localMelodySound.id,
                                                   name: localMelodySound.name,
                                                   soundType: localMelodySound.soundType,
                                                   audioVolume: audioVolumes.melodyVolume,
                                                   imageName: localMelodySound.imageName)
                        
                        let newNaturalSound = Sound(id: localNaturalSound.id,
                                                    name: localNaturalSound.name,
                                                    soundType: localNaturalSound.soundType,
                                                    audioVolume: audioVolumes.naturalVolume,
                                                    imageName: localNaturalSound.imageName)
                        
                        let newMixedSound = MixedSound(id: data.id,
                                                       name: data.name,
                                                       baseSound: newBaseSound,
                                                       melodySound: newMelodySound,
                                                       naturalSound: newNaturalSound,
                                                       imageName: data.imageName)
                        
                        userRepositories.remove(at: data.id)
                        userRepositories.insert(newMixedSound, at: data.id)
                        let data = getEncodedData(data: userRepositories)
                        UserDefaultsManager.shared.standard.set(data, forKey: UserDefaultsManager.shared.recipes)
                        
                        hasShowAlert = true
                    } label: {
                        Text("Save")
                            .foregroundColor(ColorPalette.forground.color)
                            .fontWeight(.semibold)
                            .font(Font.system(size: 22))
                    }
                    
                    
                }
                .alert(isPresented: $hasShowAlert) {
                    Alert(
                        title: Text("Volume has changed, Restart the app please."),
                        dismissButton: .default(Text("Got it!")) {
                            showVolumeControl.toggle()
                        }
                    )
                }
                
                
                
                .padding()
                
                if let baseSound = data.baseSound {
                    SoundControlSlider(item: baseSound)
                }
                
                if let melodySound = data.melodySound {
                    SoundControlSlider(item: melodySound)
                }
                
                if let naturalSound = data.naturalSound {
                    SoundControlSlider(item: naturalSound)
                }
                
                Spacer()
            }
        }
    }

    
    @ViewBuilder
    func SoundControlSlider(item: Sound) -> some View {
        HStack {
            Image(item.imageName)
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(4)
                .padding(.trailing, 18)
            
            VStack {
                HStack {
                    Text(item.soundType.rawValue.uppercased())
                        .foregroundColor(.systemGrey1)
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(item.name)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        .baselineOffset(5)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "speaker.wave.1.fill")
                        .frame(width: 18.0, height: 18.0)
                        .foregroundColor(.white)
                    
                    switch item.soundType {
                    case .base:
                        CustomSlider(value: $audioVolumes.baseVolume, range: (0, 1), knobWidth: 14) { modifiers in
                            ZStack {
                                Color.white.cornerRadius(3).frame(height: 2).modifier(modifiers.barLeft)
                                Color.white.opacity(0.4).cornerRadius(3).frame(height: 2).modifier(modifiers.barRight)
                                ZStack {
                                    Circle().fill(Color.white)
                                }.modifier(modifiers.knob)
                            }
                        }
                        .frame(height: 25)
                        .onChange(of: audioVolumes.baseVolume) { newValue in
                            print(newValue)
                            baseAudioManager.changeVolume(track: item.name,
                                                           volume: newValue)
                        }
                        Text("\(Int(audioVolumes.baseVolume * 100))")
                            .font(.body)
                            .foregroundColor(.systemGrey1)
                            .frame(maxWidth: 30)
                        
                    case .melody:
                        CustomSlider(value: $audioVolumes.melodyVolume, range: (0, 1), knobWidth: 14) { modifiers in
                            ZStack {
                                Color.white.cornerRadius(3).frame(height: 2).modifier(modifiers.barLeft)
                                Color.white.opacity(0.4).cornerRadius(3).frame(height: 2).modifier(modifiers.barRight)
                                ZStack {
                                    Circle().fill(Color.white)
                                }.modifier(modifiers.knob)
                            }
                        }
                        .frame(height: 25)
                        .onChange(of: audioVolumes.melodyVolume) { newValue in
                            print(newValue)
                            melodyAudioManager.changeVolume(track: item.name,
                                                           volume: newValue)
                        }
                        Text("\(Int(audioVolumes.melodyVolume * 100))")
                            .font(.body)
                            .foregroundColor(.systemGrey1)
                            .frame(maxWidth: 30)
                    
                    case .natural:
                        CustomSlider(value: $audioVolumes.naturalVolume, range: (0, 1), knobWidth: 14) { modifiers in
                            ZStack {
                                Color.white.cornerRadius(3).frame(height: 2).modifier(modifiers.barLeft)
                                Color.white.opacity(0.4).cornerRadius(3).frame(height: 2).modifier(modifiers.barRight)
                                ZStack {
                                    Circle().fill(Color.white)
                                }.modifier(modifiers.knob)
                            }
                        }
                        .frame(height: 25)
                        .onChange(of: audioVolumes.naturalVolume) { newValue in
                            print(newValue)
                            naturalAudioManager.changeVolume(track: item.name,
                                                           volume: newValue)
                        }
                        Text("\(Int(audioVolumes.naturalVolume * 100))")
                            .font(.body)
                            .foregroundColor(.systemGrey1)
                            .frame(maxWidth: 30)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
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
}

// 오류 때문에 주석처리
//struct VolumeControlView_Previews: PreviewProvider {
//    static var previews: some View {
//        VolumeControlView(showVolumeControl: .constant(true),
//                      baseVolume: 0.3,
//                      melodyVolume: 0.8,
//                      naturalVolume: 1.0,
//                      data: dummyMixedSound, newData: <#Binding<MixedSound>#>)
//    }
//}
