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
    
    var activePeripheral: CBPeripheral!
    
    @IBOutlet weak var btVolume: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
