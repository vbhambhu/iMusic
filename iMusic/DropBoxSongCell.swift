//
//  DropBoxSongCell.swift
//  iMusic
//
//  Created by Vinod Kumar on 23/02/2017.
//  Copyright © 2017 Vinod Kumar. All rights reserved.
//

import UIKit

protocol DropBoxCellViewDelegate {
    func downloadSongFromDropbox(forCell: DropBoxSongCell)
}

class DropBoxSongCell: UICollectionViewCell {
    
    var songImage: UIImageView!
    var songLabel: UILabel!
    var downloadBtn: UIButton!
    var delegate: DropBoxCellViewDelegate? = nil
    
    override func awakeFromNib() {
        
        
        //music image
        songImage = UIImageView(frame: contentView.frame)
        songImage.frame =  CGRect(x: 10, y: 15 , width: 40, height: 40)
        songImage.clipsToBounds = true
        contentView.addSubview(songImage)
        
        songLabel = UILabel(frame: CGRect(x: 55, y: 25, width: frame.size.width-100, height: 20))
        songLabel.textColor = UIColor.white
        contentView.addSubview(songLabel)
        
        //Download status button
        downloadBtn = UIButton(frame: CGRect(x: frame.size.width-58, y: 10, width: 48, height: 48))
        downloadBtn.addTarget(self, action: #selector(downloadSong), for: .touchUpInside)
        downloadBtn.backgroundColor = UIColor.blue
        contentView.addSubview(downloadBtn)
    }
    
    func  downloadSong(){
        delegate?.downloadSongFromDropbox(forCell: self)
    }
    
    
    
        
}
