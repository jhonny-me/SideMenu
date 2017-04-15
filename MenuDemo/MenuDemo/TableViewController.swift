//
//  TableViewController.swift
//  MenuDemo
//
//  Created by Johnny Gu on 15/04/2017.
//  Copyright © 2017 Johnny Gu. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row)
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController
        vc.string = String(indexPath.row)
        guard
            let menuVC = ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? SMViewController),
            let navigationVC = menuVC.rootViewController as? UINavigationController else { return }
        navigationVC.viewControllers = [vc]
        menuVC.setMenuStatus(.menuClosed, animated: true)
    }

}
