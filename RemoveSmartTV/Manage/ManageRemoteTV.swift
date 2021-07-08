//
//  ManageRemoteTV.swift
//  RemoveSmartTV
//
//  Created by haiphan on 08/07/2021.
//

import Foundation
import RxSwift
import RxCocoa
import CoreBluetooth

final class ManageRemote: NSObject {
    var activePeripheral: CBPeripheral!
    var manager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    
    init(activePeripheral: CBPeripheral, manager: CBCentralManager, peripherals: [CBPeripheral]) {
        self.activePeripheral = activePeripheral
        self.manager = manager
        self.peripherals = peripherals
    }
    
    func connect(peripheral: CBPeripheral) {
        
        if peripheral.state != .connected {
            self.manager.connect(peripheral, options: nil)
        }
    }
    
    private func stopScan() {
        self.manager.stopScan()
    }
    
    
}
extension ManageRemote: CBPeripheralDelegate, CBCentralManagerDelegate {
    
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
        self.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("========= didDiscover peripheral \(peripheral.name)")
        
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
