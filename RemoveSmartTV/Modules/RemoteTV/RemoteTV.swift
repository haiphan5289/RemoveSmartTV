//
//  RemoteTV.swift
//  RemoveSmartTV
//
//  Created by haiphan on 08/07/2021.
//

import UIKit
import RxCocoa
import RxSwift
import CoreBluetooth

class RemoteTV: UIViewController {
    
    var manageRemoteTV: ManageRemote?
    
    @IBOutlet weak var btVolume: UIButton!
    
//    NSString *voldownkeyprotocol,*voldownkeyIRvalue, *voldownkeybits;
//    NSString *chupkeyprotocol,*chupkeyIRvalue, *chupkeybits;
//    NSString *chdownkeyprotocol,*chdownkeyIRvalue, *chdownkeybits;
    
    var voldownkeyprotocol: String = ""
    var voldownkeyIRvalue: String = ""
    var voldownkeybits: String = ""
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }

}
extension RemoteTV {
    
    private func setupUI() {
        let defaults = UserDefaults.standard
        
        // voldown key
//        voldownkeyprotocol = [defaults objectForKey:@"voldownkeyprotocol"];
//        voldownkeyIRvalue = [defaults objectForKey:@"voldownkeyIRvalue"];
//        voldownkeybits = [defaults objectForKey:@"voldownkeybits"];
//        voldownkeyprotocol = defaults.object(forKey: "voldownkeyprotocol") as! String
//        voldownkeyIRvalue = defaults.object(forKey: "voldownkeyIRvalue") as! String
//        voldownkeybits = defaults.object(forKey: "voldownkeybits") as! String
        
        if let manage = self.manageRemoteTV {
            manage.connect(peripheral: manage.activePeripheral)
        }
        
    }
    
    private func setupRX() {
        
        self.btVolume.rx.tap.bind { _ in
            
        }.disposed(by: disposeBag)
        
    }
    
}
