//
//  PTCDocumentCell.swift
//  Facedriver
//
//  Created by DAT-Asset-259 on 16/07/19.
//  Copyright © 2019 Dapl. All rights reserved.
//

import UIKit

class PTCDocumentCell: UITableViewCell {

    @IBOutlet weak var imageViewPTCDocument: UIImageView!
    @IBOutlet weak var labelPTCDocument: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageViewPTCDocument.image = UIImage(named: ApiKeyConstants.ImageType.kDocsIcon)
        imageViewPTCDocument.contentMode = .center
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
