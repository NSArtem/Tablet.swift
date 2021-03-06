//
//  MainController.swift
//  TabletDemo
//
//  Created by Max Sokolov on 16/04/16.
//  Copyright © 2016 Tablet. All rights reserved.
//

import UIKit
import Tablet

class MainController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableDirector = TableDirector(tableView: tableView)
        }
    }
    var tableDirector: TableDirector!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rows = TableRowBuilder<String, StoryboardTableViewCell>(items: ["1", "2", "3"])
            .action(.click) { [unowned self] e in
                self.performSegueWithIdentifier("headerfooter", sender: nil)
            }

        tableDirector += rows
    }
}