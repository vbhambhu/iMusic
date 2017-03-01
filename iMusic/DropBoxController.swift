//
//  DropBoxController.swift
//  iMusic
//
//  Created by Vinod Kumar on 23/02/2017.
//  Copyright © 2017 Vinod Kumar. All rights reserved.
//

import UIKit
import SwiftyDropbox

private let reuseIdentifier = "Cellox"

class DropBoxController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var songArrayList: [Song] = []
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(DropboxClientsManager.authorizedClient != nil){
            //print("You are authorized")
            self.loadSoundFiles()
        } else{
            //print("You are not authorized")
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in UIApplication.shared.openURL(url)
            })
        }
    }

    func downloadSong(){
        print("GGG");
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.title = "Dropbox Files"
        collectionView?.backgroundColor = UIColor.white

        // Register cell classes
        self.collectionView!.register(DropBoxSongCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background")?.drawAsPattern(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.collectionView?.backgroundColor = UIColor(patternImage: image)
        
    }

    
    func loadSoundFiles() {
        
        //let indexPath:IndexPath = IndexPath(row:0, section: 0)
        let client = DropboxClientsManager.authorizedClient!
        client.files.listFolder(path: "").response { response, error in
            if let result = response {
                for entry in result.entries {
                    let filename: NSString = entry.name as NSString;
                    if(filename.pathExtension == "mp3"){
                        self.songArrayList.append(Song(title: entry.name))
                        //print(entry.name)
                        //self.files.insert(entry.name, at: 0)
                        //self.dropBoxTable.insertRows(at: [indexPath], with: .automatic)
                        self.collectionView?.reloadData()
                    }
                }
            } else {
                //print(error!)
            }
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return songArrayList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DropBoxSongCell
        // Configure the cell
        cell.backgroundColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 0.5)
        cell.awakeFromNib()
        cell.delegate = self
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let dropBoxCell = cell as! DropBoxSongCell
        let song = songArrayList[indexPath.item]
        dropBoxCell.songImage.image = UIImage(named: "music")
        dropBoxCell.songLabel.text = song.title
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension UICollectionViewController: DropBoxCellViewDelegate{
    
    func downloadSongFromDropbox(forCell: DropBoxSongCell){
        
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(forCell.songLabel.text!)
        
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destinationUrl
        }
        
        print(documentsDirectoryURL)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            let alert = UIAlertController(title: "Already downloaded", message: "This music is already downloaded to your phone from dropbox.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            let client = DropboxClientsManager.authorizedClient!
            client.files.download(path: "/\(forCell.songLabel.text!)", destination: destination).response { response, error in
                if let (metadata, data) = response {
                    
                    //add new song to list
                    downloadedSongs.append(forCell.songLabel.text!)
                    
                    let filename: NSString = forCell.songLabel.text! as NSString
               
                    localSongArrayList.append(Song(title: filename.deletingPathExtension ))
                    
                    //super.collectionView?.reloadData()
                    
                    let alert = UIAlertController(title: "Download Complete", message: "Music is now downloaded to your phone.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    print(error!)
                }
            }
            
        }
        
    }
    
    
}
