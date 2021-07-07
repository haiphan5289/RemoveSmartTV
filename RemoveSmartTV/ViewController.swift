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


class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
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
        print("====== peripheral \(peripheral)")
        self.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("========= didDiscover peripheral")
        
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
        
        if let f = peripherals.first {
            // Copy the peripheral instance
                        self.activePeripheral = f
                        self.activePeripheral.delegate = self

                        // Connect!
                        self.manager.connect(self.activePeripheral, options: nil)
        }

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
    
    var delegate: BTSmartSensorDelegate?
    // Properties
    private var manager: CBCentralManager!
    private var activePeripheral: CBPeripheral!
    @VariableReplay private var peripherals: [CBPeripheral] = []
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        self.$peripherals.asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { list in
                
                if let f = list.first {
                    self.connect(peripheral: f)
                }
                
        }.disposed(by: disposeBag)
        
    }
    
    private func connect(peripheral: CBPeripheral) {
        
        if peripheral.state != .connected {
            self.manager.connect(peripheral, options: nil)
        }
    }
    
    private func stopScan() {
        self.manager.stopScan()
    }


}

