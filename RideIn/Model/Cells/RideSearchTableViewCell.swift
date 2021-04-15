//
//  RideSearchTableViewCell.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit

class RideSearchTableViewCell: UITableViewCell {

    class var reuseIdentifier: String {
        return "RideSearchCell"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: RideSearchTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
