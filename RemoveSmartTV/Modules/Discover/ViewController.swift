//
//  ViewController.swift
//  RemoveSmartTV
//
//  Created by haiphan on 07/07/2021.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift

protocol BTSmartSensorDelegate {
    func peripheralFound()
    func TAHbleCharValueUpdated()
    func setConnect()
    func setDisconnect()
}


class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: BTSmartSensorDelegate?
    // Properties
    private var manager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var pheripheralManager: CBPeripheralManager!
    @VariableReplay private var peripherals: [CBPeripheral] = []
    let myCustomServiceUUID = CBUUID(string: "47DFC6AB-D093-468B-9FAB-9396B57D31F0")
    var list: [CBMutableCharacteristic] = []
    var listService: [CBMutableService] = []
    var myCharacteristic: CBMutableCharacteristic?
    
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "AF0BADB1-5B99-43CD-917A-A77BC549E3CC")
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupRX()
    }
    
}
extension ViewController {
    
    private func setupUI() {
        manager = CBCentralManager(delegate: self, queue: nil)
        pheripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.tableView.register(DiscoverCell.nib, forCellReuseIdentifier: DiscoverCell.identifier)
        self.tableView.delegate = self
        
    }
    
    private func setupRX() {
        self.$peripherals.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: DiscoverCell.identifier, cellType: DiscoverCell.self)) {(row, element, cell) in
                cell.textLabel?.text = element.name
            }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind(onNext: weakify({ index, wSelf in
            let item = wSelf.peripherals[index.row]
//            let vc = RemoteTV.createVC()
//
//            guard let setupVC = vc as? RemoteTV else { return }
//            setupVC.manageRemoteTV = ManageRemote(activePeripheral: item, manager: self.manager, peripherals: self.peripherals)
//            wSelf.navigationController?.pushViewController(vc, animated: true)
            self.peripheral = item
            self.connect(peripheral: item)
            
        })).disposed(by: disposeBag)
        
    }
    
    private func connect(peripheral: CBPeripheral) {
        self.heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        self.centralManager.stopScan()
        centralManager.connect(heartRatePeripheral)
        print("\(peripheral)")
        
//        if peripheral.state != .connected {
//            self.manager.connect(peripheral, options: nil)
//        }
    }
    
    private func stopScan() {
        self.manager.stopScan()
    }
    
    private func disconnect(peripheral: CBPeripheral) {
        manager.cancelPeripheralConnection(peripheral)
    }
    
}
extension ViewController: CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      switch central.state {
        case .unknown:
          print("central.state is .unknown")
        case .resetting:
          print("central.state is .resetting")
        case .unsupported:
          print("central.state is .unsupported")
        case .unauthorized:
          print("central.state is .unauthorized")
        case .poweredOff:
          print("central.state is .poweredOff")
        case .poweredOn:
          print("central.state is .poweredOn")
  //        let heartRateServiceCBUUID = CBUUID(string: "0xFFE1")
          centralManager.scanForPeripherals(withServices: nil)
      }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let index = peripherals.firstIndex(where: { $0.identifier == peripheral.identifier }) {

        } else {
            self.peripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
      heartRatePeripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
      guard let services = peripheral.services else { return }
      
      for service in services {
        print(service)
        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
      guard let characteristics = service.characteristics else { return }

      for characteristic in characteristics {
        print(characteristic)
        if characteristic.properties.contains(.read) {
          print("\(characteristic.uuid): properties contains .read")
          peripheral.readValue(for: characteristic)
        }
        if characteristic.properties.contains(.notify) {
          print("\(characteristic.uuid): properties contains .notify")
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
  //    switch characteristic.uuid {
  //    case bodySensorLocationCharacteristicCBUUID:
  //      let bpm = heartRate(from: characteristic)
  //      print("")
  //      default:
  //        print("Unhandled Characteristic UUID: \(characteristic.uuid)")
  //    }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
      guard let characteristicData = characteristic.value else { return -1 }
      let byteArray = [UInt8](characteristicData)

      let firstBitValue = byteArray[0] & 0x01
      if firstBitValue == 0 {
        // Heart Rate Value Format is in the 2nd byte
        return Int(byteArray[1])
      } else {
        // Heart Rate Value Format is in the 2nd and 3rd bytes
        return (Int(byteArray[1]) << 8) + Int(byteArray[2])
      }
    }
    
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
////        activePeripheral = peripheral;
////        activePeripheral.delegate = self;
////
////        [activePeripheral discoverServices:nil];
////        //[self notify:peripheral on:YES];
////
////        [self printPeripheralInfo:peripheral];
////
////        printf("Connected to active peripheral Device\n");
////        print("====== peripheral \(peripheral)")
//
//        print("Connected to \(peripheral.name ?? "Unknown Name")")
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
//
//
////        self.peripheral = peripheral
////        self.peripheral.delegate = self
////
//////        Tìm kiếm các service
////        peripheral.discoverServices(nil)
////
////        self.stopScan()
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        self.peripheral = peripheral
//        for service in peripheral.services! {
//            print("Discovered service \(service)")
//            //        Tìm kiếm các characteristic
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        for characteristic in service.characteristics! {
//            print("Discovered uuid \(characteristic.uuid)")
////            Lấy giá trị của một characteristic
//
//            let myCharacteristic = CBMutableCharacteristic(type: characteristic.uuid, properties: .write, value: nil, permissions: .readable)
//            let myService = CBMutableService(type: characteristic.uuid, primary: true)
//            myService.characteristics = [myCharacteristic]
//            self.list.append(myCharacteristic)
//            self.pheripheralManager.add(myService)
//
//            if let f = self.list.first {
//                self.myCharacteristic = f
//                peripheral.readValue(for: f)
//                peripheral.setNotifyValue(true, for: f)
//
//                if let d = characteristic.value {
//                    peripheral.writeValue(d, for: f, type: .withResponse)
//                }
//            }
//
//            peripheral.readValue(for: characteristic)
//            peripheral.setNotifyValue(true, for: characteristic)
//
//            if let d = characteristic.value {
//                peripheral.writeValue(d, for: characteristic, type: .withResponse)
//            }
//
//
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//
//        if let e = error {
//
//            print("======== lỗi didUpdateValueFor \(e)")
//
//            return
//        }
//
//        let data = characteristic.value
//        // parse the data as needed
//        print("====== data \(data)")
//        if let d = data {
//            let str = String(decoding: d, as: UTF8.self)
//            print("===== str \(str) ")
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print("Error changing notification state: \(error.localizedDescription ?? "")")
//        }
//        let data = characteristic.value
//        // parse the data as needed
//    }
//
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        print("Disconnected from the active peripheral Device\n")
//        if(self.peripheral != nil) {
//
//        }
//
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print("Error writing characteristic value \(error.localizedDescription)")
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//
//        // We've found it so stop scan
//        //                self.centralManager.stopScan()
//        //
//        //                // Copy the peripheral instance
//        //                self.peripheral = peripheral
//        //                self.peripheral.delegate = self
//        //
//        //                // Connect!
//        //                self.centralManager.connect(self.peripheral, options: nil)
//
//        if (peripheral.name?.count ?? 0) <= 1 {
//            return
//        }
////
//        if let index = peripherals.firstIndex(where: { $0.identifier == peripheral.identifier }) {
//
//        } else {
//            self.peripherals.append(peripheral)
//        }
//
////        self.manager.stopScan()
//
////        if let f = peripherals.first {
////            // Copy the peripheral instance
////                        self.activePeripheral = f
////                        self.activePeripheral.delegate = self
////
////                        // Connect!
////                        self.manager.connect(self.activePeripheral, options: nil)
////        }
//
//    }
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//
//        print("Central state update")
//                    if central.state != .poweredOn {
//                        print("Central is not powered on")
//                    } else {
////                        print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
//                        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
//                            let service = CBUUID(string: uuid)
//                            manager.scanForPeripherals(withServices: [service],
//                                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
//                        }
////                        let service = CBUUID(string: UUID().uuidString)
////                        manager.scanForPeripherals(withServices: [service],
////                                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
////                        manager.scanForPeripherals(withServices: nil, options: )
//                    }
//
//    }
}
extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
               print("Error publishing service: \(error.localizedDescription)")
           }
        print("===== \(service)")
        
//        if let my = self.myCharacteristic {
//            pheripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [my.uuid]])
//        }
        
        let l = self.list.map{ $0.uuid }
        pheripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: l])
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Error advertising: %@", error.localizedDescription)
        }
        //...
        print("===== peripheral \(peripheral)")
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        guard let myCharacteristic = self.list.first else { return }
        
        if request.characteristic.uuid == myCharacteristic.uuid {
            if request.offset > myCharacteristic.value!.count {
                pheripheralManager.respond(to: request, withResult: CBATTError.Code.invalidOffset)
                let range = Range(NSRange(location: request.offset, length: myCharacteristic.value!.count - request.offset))
                request.value = myCharacteristic.value!.subdata(in: range!)
            }
        }
    }
    
    
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
