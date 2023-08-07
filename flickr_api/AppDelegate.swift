//
//  AppDelegate.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let networkManager = NetworkManager()
        let mainViewModel = MainScreenViewModel(networkManager: networkManager)
        let mainViewController = MainScreenViewController(viewModel: mainViewModel)
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

