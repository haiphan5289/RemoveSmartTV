//
//  CheckBC.swift
//  RemoveSmartTV
//
//  Created by haiphan on 12/07/2021.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
//import SwiftyBluetooth
//import BluetoothKit


class CheckBC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var manager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var pheripheralManager: CBPeripheralManager!
//    @VariableReplay private var peripherals: [Peripheral] = []
    let myCustomServiceUUID = CBUUID(string: "47DFC6AB-D093-468B-9FAB-9396B57D31F0")
    var list: [CBMutableCharacteristic] = []
    var listService: [CBMutableService] = []
    var myCharacteristic: CBMutableCharacteristic?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupRX()
        
        // You can pass in nil if you want to discover all Peripherals
//        SwiftyBluetooth.scanForPeripherals(withServiceUUIDs: nil, timeoutAfter: 15) { scanResult in
//            switch scanResult {
//                case .scanStarted: break
//                    // The scan started meaning CBCentralManager scanForPeripherals(...) was called
//
//                case .scanResult(let peripheral, let advertisementData, let RSSI):
//                    // A peripheral was found, your closure may be called multiple time with a .ScanResult enum case.
//                    // You can save that peripheral for future use, or call some of its functions directly in this closure.
//            print("======= peripheral \(peripheral) --- advertisementData \(advertisementData) --- rssi \(RSSI)")
//                    peripheral
//                    if let index = self.peripherals.firstIndex(where: { $0.identifier == peripheral.identifier }) {
//
//                    } else {
//                        self.peripherals.append(peripheral)
//                    }
//
//                case .scanStopped(let list, let error): break
//                    // The scan stopped, an error is passed if the scan stopped unexpectedly
//            }
//        }
    }
    

}
extension CheckBC {
    
    private func setupUI() {
//        manager = CBCentralManager(delegate: self, queue: nil)
//        pheripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        self.tableView.register(DiscoverCell.nib, forCellReuseIdentifier: DiscoverCell.identifier)
        self.tableView.delegate = self
        
    }
    
    private func setupRX() {
        
//        let peripheral = BKPeripheral()
//        peripheral.delegate = self
//        do {
//            let serviceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
//            let characteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
//            let localName = "My Cool Peripheral"
//            let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:     characteristicUUID, localName: localName)
//            try peripheral.startWithConfiguration(configuration)
//            // You are now ready for incoming connections
//        } catch let error {
//            // Handle error.
//        }
//
//
//        self.$peripherals.asObservable()
//            .bind(to: tableView.rx.items(cellIdentifier: DiscoverCell.identifier, cellType: DiscoverCell.self)) {(row, element, cell) in
//                cell.textLabel?.text = element.name
//            }.disposed(by: disposeBag)
//
//        self.tableView.rx.itemSelected.bind(onNext: weakify({ index, wSelf in
//            let item = wSelf.peripherals[index.row]
////            let vc = RemoteTV.createVC()
////
////            guard let setupVC = vc as? RemoteTV else { return }
////            setupVC.manageRemoteTV = ManageRemote(activePeripheral: item, manager: self.manager, peripherals: self.peripherals)
////            wSelf.navigationController?.pushViewController(vc, animated: true)
////            self.peripheral = item
////            self.connect(peripheral: item)
////            item.connect(withTimeout: 10) { result in
////                switch result {
////                case .failure(let err):
////                    print("===== connect errr \(err.localizedDescription)")
////                case .success(_):
////                    print("===== connect success")
////                    break
////                }
////            }
//
////            print("==== \(item.services.map{ $0 })")
//
////            item.readValue(ofCharac: item.services) { result in
////
////            }
//
////            item.discoverServices(withUUIDs: nil) { result in
////                switch result {
////                case .success(let services):
////                    print("services \(services)")
////                    break // An array containing all the services requested
////                case .failure(let error):
////                    print("==== error \(error)")
////                    break // A connection error or an array containing the UUIDs of the services that we're not found
////                }
////            }
//
////            item.discoverCharacteristics(withUUIDs: nil, ofServiceWithUUID: "180A") { result in
////                // The characteristics discovered or an error if something went wrong.
////                switch result {
////                case .success(let services):
////                    print("services \(services)")
////                    break // An array containing all the services requested
////                case .failure(let error):
////                    print("==== error \(error)")
////                    break // A connection error or an array containing the UUIDs of the services that we're not found
////                }
////            }
//
////            item.readValue(ofCharacWithUUID: "2A29", fromServiceWithUUID: "180A") { result in
////                switch result {
////                case .success(let data):
////                    print("==== data \(data)")
////                    break // The data was read and is returned as an NSData instance
////                case .failure(let error):
////                    print("==== error \(error)")
////                    break // An error happened while attempting to read the data
////                }
////            }
//
//        })).disposed(by: disposeBag)
        
    }
    
//    private func connect(peripheral: CBPeripheral) {
//
//        if peripheral.state != .connected {
//            self.manager.connect(peripheral, options: nil)
//        }
//    }
//
//    private func stopScan() {
//        self.manager.stopScan()
//    }
//
//    private func disconnect(peripheral: CBPeripheral) {
//        manager.cancelPeripheralConnection(peripheral)
//    }
    
}
extension CheckBC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
