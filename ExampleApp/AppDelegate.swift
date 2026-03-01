//
//  AppDelegate.swift
//  ExampleApp
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = UITabBarController()
        
        // Main/Home Tab
        let viewController = ViewController()
        viewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Diagnostics Tab
        let diagnosticsVC = DiagnosticsViewController()
        diagnosticsVC.tabBarItem = UITabBarItem(title: "Diagnostics", image: UIImage(systemName: "stethoscope"), tag: 1)

        // HTTP Client Tab
        let httpVC = HTTPClientViewController()
        httpVC.tabBarItem = UITabBarItem(title: "HTTP", image: UIImage(systemName: "network"), tag: 2)
        
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: viewController),
            UINavigationController(rootViewController: diagnosticsVC),
            UINavigationController(rootViewController: httpVC)
        ]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}
