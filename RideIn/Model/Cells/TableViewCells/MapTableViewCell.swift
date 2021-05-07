//
//  MapTableViewCell.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit

class MapTableViewCell: UITableViewCell {
    
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

extension MapTableViewCell: DetailedCellModel {
    func update(with object1: String?, object2: String? = nil) {
        self.textLabel?.font = .boldSystemFont(ofSize: 20)
        self.textLabel?.numberOfLines = 0
        self.textLabel?.textColor = .darkGray
        self.textLabel?.text = object1
        self.detailTextLabel?.text = object2
    }
}
