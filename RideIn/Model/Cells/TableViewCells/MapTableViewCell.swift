//
//  MapTableViewCell.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit

class MapTableViewCell: UITableViewCell {

    class var reuseIdentifier: String {
        return "MapTableViewCcell"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: MapTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
