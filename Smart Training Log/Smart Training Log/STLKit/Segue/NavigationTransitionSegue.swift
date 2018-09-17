//
//  NavigationTransitionSegue.swift
//  Smart Training Log
//

import UIKit

class NavigationTransistionSegue: UIStoryboardSegue {

    override func perform() {
        UIApplication.shared.switchRootViewController(rootViewController: destination, animated: true, completion: nil)
    }

}
