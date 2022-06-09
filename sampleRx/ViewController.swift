//
//  ViewController.swift
//  sampleRx
//
//  Created by Glenn Posadas on 6/9/22.
//

import RxCocoa
import RxSwift
import UIKit

// MARK: VC

class ViewController: UIViewController {

    @IBOutlet weak var stateLabel: UILabel!
    private let vm = VM()
    private let disposeBag = DisposeBag()
    
    // To verify that we don't have memory leaks
    deinit {
        print("Deinit VC ✅")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    private func setupBindings() {
        vm.state.bind(to: stateLabel.rx.text).disposed(by: disposeBag)
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        vm.login()
    }
    
    @IBAction func logout(_ sender: Any) {
        vm.logout()
    }
}

// MARK: VM

class VM {
    
    private(set) var state = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    init() {
        // Delegate or observe
        setuoBindings()
    }
    
    private func setuoBindings() {
        AuthManager.shared
            .currentUser
            .subscribe { [weak self] user in
                guard let self = self else {
                    return
                }
                if let user = user {
                    let username = user.name
                    self.state.accept("Logged in: \(username)")
                } else {
                    self.state.accept("Logged out")
                }
            } onError: { error in
                print("Error: \(error.localizedDescription)")
            } onCompleted: {
                print("onCompleted")
            } onDisposed: {
                print("onDisposed")
            }.disposed(by: disposeBag)

    }
    
    func login() {
        AuthManager.shared.login()
    }
    
    func logout() {
        AuthManager.shared.logout()
    }
}

// MARK: Manager

class AuthManager {
    
    private init() {}
    
    static let shared = AuthManager()
        
    private(set) var currentUser = BehaviorRelay<User?>(value: nil)
    
    /// Calls server, do database, etc.
    func login() {
        currentUser.accept(.init(id: Int.random(in: 0...10), name: "A: \(Date())"))
    }
    
    /// Calls server, do database, etc.
    func logout() {
        currentUser.accept(nil)
    }
}

// MARK: Model

struct User {
    let id: Int
    let name: String
}
