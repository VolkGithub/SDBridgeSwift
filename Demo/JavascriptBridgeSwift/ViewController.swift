//
//  ViewController.swift
//  JavascriptBridgeSwift
//
//  Created by 1 on 2022/3/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func setupView() {
        self.title = "MainViewController"
    }
    @IBAction func touch(_ sender: UIButton) {
        self.navigationController?.pushViewController(WebViewController(), animated: true)
    }
}

