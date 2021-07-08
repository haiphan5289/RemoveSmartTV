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
    private var activePeripheral: CBPeripheral!
    private var pheripheralManager: CBPeripheralManager!
    @VariableReplay private var peripherals: [CBPeripheral] = []
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
        
        self.activePeripheral = peripheral
        self.activePeripheral.delegate = self
        
//        Tìm kiếm các service
        peripheral.discoverServices(nil)
        
        self.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print("Discovered service \(service)")
            //        Tìm kiếm các characteristic
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("Discovered characteristic \(characteristic)")
//            Lấy giá trị của một characteristic
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            
            if let d = characteristic.value {
                peripheral.writeValue(d, for: characteristic, type: .withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
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
        if(self.activePeripheral != nil) {
            
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
    
    
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
