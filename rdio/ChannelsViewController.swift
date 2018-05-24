//
//  FirstViewController.swift
//  rdio
//
//  Created by Tim Wattenberg on 23.04.18.
//  Copyright © 2018 Tim Wattenberg. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as? ChannelTableViewCell else {
            fatalError("The dequeued cell is not an instance of ChannelTableViewCell.")
        }
        cell.nameLabel.text = "Lorem Ipsum"
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

