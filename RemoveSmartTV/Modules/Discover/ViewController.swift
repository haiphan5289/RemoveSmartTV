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
import SwiftyBluetooth

let  SERVICE_UUID   =  0xFFE0
#define CHAR_UUID        0xFFE1

#define HIGH 1
#define LOW 0


// Trakpad
#define Up    256
#define Down  257
#define Right 258
#define Left  259

// Volume
#define VolumeUp 260
#define VolumeDown 261

// Tah Keyboard Modifiers

#define A 65 #define a 97
#define B 66 #define b 98
#define C 67 #define c 99
#define D 68 #define d 100
#define E 69 #define e 101
#define F 70 #define f 102
#define G 71 #define g 103
#define H 72 #define h 104
#define I 73 #define i 105
#define J 74 #define j 106
#define K 75 #define k 107
#define L 76 #define l 108
#define M 77 #define m 109
#define N 78 #define n 110
#define O 79 #define o 111
#define P 80 #define p 112
#define Q 81 #define q 113
#define R 82 #define r 114
#define S 83 #define s 115
#define T 84 #define t 116
#define U 85 #define u 117
#define V 86 #define v 118
#define W 87 #define w 119
#define X 88 #define x 120
#define Y 89 #define y 121
#define Z 90 #define z 122


#define KEY_LEFT_CTRL     128
#define KEY_LEFT_SHIFT     129
#define KEY_LEFT_ALT     130
#define KEY_LEFT_GUI     131
#define KEY_RIGHT_CTRL     132
#define KEY_RIGHT_SHIFT     133
#define KEY_RIGHT_ALT     134
#define KEY_RIGHT_GUI     135
#define KEY_UP_ARROW     218
#define KEY_DOWN_ARROW     217
#define KEY_LEFT_ARROW     216
#define KEY_RIGHT_ARROW     215
#define KEY_SPACE         32
#define KEY_BACKSPACE     178
#define KEY_TAB              179
#define KEY_RETURN         176
#define KEY_ESC             177
#define KEY_INSERT          209
#define KEY_DELETE          212
#define KEY_PAGE_UP          211
#define KEY_PAGE_DOWN     214
#define KEY_HOME          210
#define KEY_END             213
#define KEY_CAPS_LOCK     193
#define KEY_F1          194
#define KEY_F2          195
#define KEY_F3          196
#define KEY_F4          197
#define KEY_F5          198
#define KEY_F6          199
#define KEY_F7          200
#define KEY_F8          201
#define KEY_F9          202
#define KEY_F10          203
#define KEY_F11          204
#define KEY_F12          205

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
        
        if peripheral.state != .connected {
            self.manager.connect(peripheral, options: nil)
        }
    }
    
    private func stopScan() {
        self.manager.stopScan()
    }
    
    private func disconnect(peripheral: CBPeripheral) {
        manager.cancelPeripheralConnection(peripheral)
    }
    
}
extension ViewController: CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        activePeripheral = peripheral;
//        activePeripheral.delegate = self;
//
//        [activePeripheral discoverServices:nil];
//        //[self notify:peripheral on:YES];
//
//        [self printPeripheralInfo:peripheral];
//
//        printf("Connected to active peripheral Device\n");
//        print("====== peripheral \(peripheral)")
        
        print("Connected to \(peripheral.name ?? "Unknown Name")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
//        self.peripheral = peripheral
//        self.peripheral.delegate = self
//
////        Tìm kiếm các service
//        peripheral.discoverServices(nil)
//
//        self.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.peripheral = peripheral
        for service in peripheral.services! {
            print("Discovered service \(service)")
            //        Tìm kiếm các characteristic
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("Discovered uuid \(characteristic.uuid)")
//            Lấy giá trị của một characteristic
            
            let myCharacteristic = CBMutableCharacteristic(type: characteristic.uuid, properties: .write, value: nil, permissions: .readable)
            let myService = CBMutableService(type: characteristic.uuid, primary: true)
            myService.characteristics = [myCharacteristic]
            self.list.append(myCharacteristic)
            self.pheripheralManager.add(myService)
            
            if let f = self.list.first {
                self.myCharacteristic = f
                peripheral.readValue(for: f)
                peripheral.setNotifyValue(true, for: f)
                
                if let d = characteristic.value {
                    peripheral.writeValue(d, for: f, type: .withResponse)
                }
            }
            
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            
            if let d = characteristic.value {
                peripheral.writeValue(d, for: characteristic, type: .withResponse)
            }

            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let e = error {
            
            print("======== lỗi didUpdateValueFor \(e)")
            
            return
        }
        
        let data = characteristic.value
        // parse the data as needed
        print("====== data \(data)")
        if let d = data {
            let str = String(decoding: d, as: UTF8.self)
            print("===== str \(str) ")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription ?? "")")
        }
        let data = characteristic.value
        // parse the data as needed
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from the active peripheral Device\n")
        if(self.peripheral != nil) {
            
        }
           
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing characteristic value \(error.localizedDescription)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       
        // We've found it so stop scan
        //                self.centralManager.stopScan()
        //
        //                // Copy the peripheral instance
        //                self.peripheral = peripheral
        //                self.peripheral.delegate = self
        //
        //                // Connect!
        //                self.centralManager.connect(self.peripheral, options: nil)
        
        if (peripheral.name?.count ?? 0) <= 1 {
            return
        }
//
        if let index = peripherals.firstIndex(where: { $0.identifier == peripheral.identifier }) {

        } else {
            self.peripherals.append(peripheral)
        }
        
//        self.manager.stopScan()
        
//        if let f = peripherals.first {
//            // Copy the peripheral instance
//                        self.activePeripheral = f
//                        self.activePeripheral.delegate = self
//
//                        // Connect!
//                        self.manager.connect(self.activePeripheral, options: nil)
//        }

    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("Central state update")
                    if central.state != .poweredOn {
                        print("Central is not powered on")
                    } else {
//                        print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
                        manager.scanForPeripherals(withServices: nil,
                                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
//                        manager.scanForPeripherals(withServices: nil, options: )
                    }
        
    }
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
