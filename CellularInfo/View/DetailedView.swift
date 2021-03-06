//
//  DetailedView.swift
//  CellularInfo
//
//  Created by 王跃琨 on 2020/11/3.
//

import SwiftUI
import CoreLocation

struct DetailedView: View {
    
    @Binding var showSheetView: Bool
    var pingNumberAveraged : Double
    
    let networkInfo = NetworkInformation()
    @State var alertMessage: String = "网络错误"
    @State var butttonMesssage: String = "同意并提交"
    @State var dataReadyForUpload: FinalDataStructure?
    @State var showAlert: Bool = false
    @ObservedObject var locationManager = LocationManager()
    let hapticsGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        
        NavigationView{
            VStack {
                HStack {
                    FixedMapView()
                        .frame(width: 110, height: 110)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text("机型：" + UIDevice().type.rawValue)
                        Text("运营商：" + networkInfo.carrierName + " " + networkInfo.radioAccessTech)
                        Text("平均延迟：\(Int(pingNumberAveraged))ms")
                    }.padding()
                    
                    Spacer()
                    
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                
                Spacer()
                
                Text("我们非常重视您的隐私，仅上述显示信息会被提交。本 app 基于 CloudKit 构建，我们不设任何中转服务器用于接受或处理信息。您可访问 github.com/Septillion 查阅原始代码。")
                    .frame( maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .font(.footnote)
                
                Button(action: {uploadData()}, label: {
                    Text(butttonMesssage)
                        .frame(minWidth: 100, maxWidth: .infinity, idealHeight: 48, alignment: .center)
                        .padding()
                        .background(Color(.systemBlue))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .font(.title)
                }).alert(isPresented: $showAlert, content: {
                    Alert(title: Text("错误"), message: Text(alertMessage), dismissButton: .default(Text("关闭")))
                })
            }
            .padding()
            .navigationBarTitle(Text("即将提交"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("取消提交")
                self.showSheetView = false
            }) {
                Text("取消").bold()
            })
        }
        
    }
    
    func uploadData() {
        
        if networkInfo.isWiFiConnected{
            self.alertMessage = "已连接 Wi-Fi，请关闭后再试"
            hapticsGenerator.notificationOccurred(.warning)
            showAlert = true
            return
        }
        
        if networkInfo.carrierName == "" {
            self.alertMessage = "蜂窝网络未连接"
            hapticsGenerator.notificationOccurred(.warning)
            showAlert = true
            return
        }
        
        if pingNumberAveraged == 0 {
            self.alertMessage = "网络中断"
            hapticsGenerator.notificationOccurred(.warning)
            showAlert = true
            return
        }
        
        if locationManager.lastLocation == nil {
            self.alertMessage = "获取位置失败，请确认权限"
            hapticsGenerator.notificationOccurred(.warning)
            showAlert = true
            return
        }
        
        self.dataReadyForUpload = FinalDataStructure(AveragedPingLatency: pingNumberAveraged, DeviceName: UIDevice().type.rawValue, Location: locationManager.lastLocation?.coordinate, MobileCarrier: networkInfo.carrierName, RadioAccessTechnology: networkInfo.radioAccessTech)
        let cloudKitmanager = CloudRelatedStuff.CloudKitManager()
        cloudKitmanager.PushData(finalData: [dataReadyForUpload!], completionHandler: {_,_ in
            
            hapticsGenerator.notificationOccurred(.success)
            self.showSheetView = false
            return
        })
    }
}


