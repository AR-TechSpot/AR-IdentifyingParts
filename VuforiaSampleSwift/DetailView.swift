//
//  DetailView.swift
//  VuforiaSampleSwift
//
//  Created by Singh, Atul R (US - Mumbai) on 10/13/17.
//  Copyright © 2017 Singh, Atul R (US - Mumbai). All rights reserved.
//

import Foundation
import UIKit

final class DetailView: UIView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var gifImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        gifImage.image = UIImage.gifImageWithName("camshaft_valve_animation")
    }
    
    @IBAction func removeView() {
        self.removeFromSuperview()
    }
    
    class func instanceFromNib(frame: CGRect) -> DetailView {
        
        let view = UINib(nibName: "DetailView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        return  view as! DetailView
    }
}
