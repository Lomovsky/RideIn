//
//  RideSearchTableViewCell.swift
//  RideIn
//
//  Created by Алекс Ломовской on 14.04.2021.
//

import UIKit

class RideSearchTableViewCell: UITableViewCell {
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: RideSearchTableViewCell.reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RideSearchTableViewCell: DetailedCellModel {
  func update(with object1: String?, object2: String? = nil) {
    self.textLabel?.font = .boldSystemFont(ofSize: 17)
    self.textLabel?.sizeToFit()
    self.textLabel?.clipsToBounds = true
    self.textLabel?.numberOfLines = 3
    self.textLabel?.textColor = .darkGray
    self.textLabel?.text = object1
    self.detailTextLabel?.text = object2
  }
}
