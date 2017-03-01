//
//  HomeController.swift
//  iMusic
//
//  Created by Vinod Kumar on 23/02/2017.
//  Copyright © 2017 Vinod Kumar. All rights reserved.
//

import UIKit
import AVFoundation

private let reuseIdentifier = "Cell"
var localSongArrayList: [Song] = []
var downloadedSongs: [String] = []

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout , AVAudioRecorderDelegate , AVAudioPlayerDelegate {
    
    var isPlaying:Bool = false
    var player: AVAudioPlayer!
    var songIndex:Int = 0;
    var isShuffle:Bool = false
    var isReplay:Bool = false
    var refreshControl:UIRefreshControl!
    var totalSongs:Int = 0;
    
    var playPauseBtn: UIButton!
    var currentSelectedCellIndex:Int = 0;
    
    var progressSongLabel: UILabel!
    
    var playerSlider:UISlider?
    
    
    func listLocalSongs(){
        
        
        do {
            
            // Get the directory contents urls (including subfolders urls)
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: [])
            
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            
            for localSongName in mp3FileNames{
                localSongArrayList.append(Song(title: localSongName ))
            }
            
            totalSongs = localSongArrayList.count
            self.collectionView?.reloadData()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if downloadedSongs.isEmpty == false {
            
            var indexPaths = Array<IndexPath>()
            
            var counter = localSongArrayList.count-downloadedSongs.count
            for downloadedSong in downloadedSongs{
                var indexPath = IndexPath(item: counter, section: 0)
                indexPaths.append(indexPath)
                counter = counter+1
            }
            
            self.collectionView?.performBatchUpdates({Void in
                self.collectionView?.insertItems(at: indexPaths)
            }, completion: nil)
            
            self.collectionView?.reloadData()
            downloadedSongs.removeAll()
            
            
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listLocalSongs()
        
        // Register cell classes
        self.collectionView!.register(LocalSongCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        navigationItem.title = "Home"
        
        // navigationController?.navigationBar.barTintColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 1)
        
        //self.collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bg1")?.drawAsPattern(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.collectionView?.backgroundColor = UIColor(patternImage: image)
        
        
        
        
        
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showDropBoxPage))
        navigationItem.rightBarButtonItem = addButton
        
        setupPlayerView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = .white
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.white])
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.collectionView!.addSubview(refreshControl)
        
    }
    
    func refresh(sender:AnyObject){
        print("refresh required")
        self.listLocalSongs()
        //collectionView!.reloadData()
        refreshControl.endRefreshing()
    }
    
    func showDropBoxPage(){
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let namepage = DropBoxController(collectionViewLayout: layout)
        navigationController?.pushViewController(namepage, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("on appear")
        return localSongArrayList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LocalSongCell
        
        // Configure the cell
        //cell.songObj = songArrayList[indexPath.item]
        
        //        cell.layer.borderWidth = 1.0
        //        cell.layer.borderColor = UIColor.gray.cgColor
        
        cell.backgroundColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 0.5)
        cell.awakeFromNib()
        cell.customItemIndex = indexPath
        cell.delegate = self
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let localSongCell = cell as! LocalSongCell
        let song = localSongArrayList[indexPath.item]
        localSongCell.songImage.image = UIImage(named: "music")
        localSongCell.songLabel.text = song.title
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        self.songIndex = indexPath.item
//        play()
        return true
    }
    
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    
    
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.songIndex = indexPath.item
        play()
        let cell = self.collectionView?.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 0.7)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.collectionView?.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 0.5)
    }
    
    
    func playPauseBtnClicked(_ sender: Any){
        if(!self.isPlaying){
            play()
        } else{
            pause()
        }
    }
    
    
    func play(){
        
        if(localSongArrayList.count == 0){
            
            let alert = UIAlertController(title: "No music", message: "No music on your playlist. Click + to add music from dropbox.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        isPlaying = true
        self.playPauseBtn.setImage(UIImage(named: "pause"), for: UIControlState.normal)
        
        if(self.currentSelectedCellIndex != self.songIndex){
            let cellk = self.collectionView?.cellForItem(at: [0,self.currentSelectedCellIndex])
            cellk?.backgroundColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 0.5)
        }
        
        
        let cell = self.collectionView?.cellForItem(at: [0,self.songIndex])
        cell?.backgroundColor = UIColor(red: 28/255, green: 36/255, blue: 39/255, alpha: 0.7)
        self.currentSelectedCellIndex = self.songIndex
        
        
        
        let song = localSongArrayList[self.songIndex]
        
        //label
        self.progressSongLabel.text = song.title

        
        
        let songname:String = "\(song.title).mp3";
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(songname)
        print(destinationUrl.path);
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            
    
            if let encoded = destinationUrl.path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                let url = URL(string: encoded)
            {
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    player = try AVAudioPlayer(contentsOf: url)
                    player.delegate = self
                    player.prepareToPlay()
                    player.play()
                    
                    
                    self.playerSlider?.maximumValue = Float(player.duration)
                   // self.playerSlider?.value = Float(player.currentTime/player.duration)
                    
                    //self.playerSlider.value = 10
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
                    
                
                    
//                    self.progressView.setProgress(Float(player.currentTime/player.duration), animated: false)

                    
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
            }
            
        } else {
            print("file not exists")
        }
        
        
    }
    
    func updateAudioProgressView(){
        //print("updating time ===========\(player.duration)")
        self.playerSlider?.setValue(Float(player.currentTime), animated: true)
    }
    
    func pause(){
        
        if player != nil {
            self.playPauseBtn.setImage(UIImage(named: "play"), for: UIControlState.normal)
            player.stop()
            isPlaying = false
        }
    }
    
    func forwardBtnClicked(_ sender: Any){
        
        if(localSongArrayList.count == songIndex + 1){
            songIndex = 0
        } else{
            songIndex += 1
        }
        
        play()
        
    }
    
    
    func rewindBtnClicked(_ sender: Any){
        
        if(songIndex == 0){
            songIndex = localSongArrayList.count - 1
        } else {
            songIndex -= 1
        }
        
        play()
    }
    
    
    func shuffleBtnClicked(_ sender: Any){
        
        if(isShuffle){
            isShuffle = false
        } else {
            isShuffle = true
        }
    }
    
    func repeatBtnClicked(_ sender: Any){
        
        if(isReplay){
            isReplay = false
        } else {
            isReplay = true
        }
        
    }
    
    func setupPlayerView(){
        
        let heightOfView = view.frame.size.height
        let widthOfView = view.frame.size.width
        
        //Add bottom view for music controller
        let bottomPlayer = UIView()
        bottomPlayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        bottomPlayer.frame = CGRect(x: 0, y: heightOfView - 80 , width: self.view.frame.width, height: 80)
        self.view.addSubview(bottomPlayer)
        
        
        progressSongLabel = UILabel(frame: CGRect(x: 35, y: 3, width: widthOfView-70, height: 20))
        progressSongLabel.textColor = UIColor.white
        progressSongLabel.text = "This is long name of song from librartu fsds sdsdad addsa dada adsd"
        progressSongLabel.font = progressSongLabel.font.withSize(12)
        bottomPlayer.addSubview(progressSongLabel)
        
        //play and pause button
        playPauseBtn = UIButton(frame: CGRect(x: (widthOfView/2)-24, y: 25, width: 48, height: 48))
        playPauseBtn.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnClicked), for: .touchUpInside)
        bottomPlayer.addSubview(playPauseBtn)
        
        //forward button
        let forwardBtn = UIButton(frame: CGRect(x: (widthOfView/2)+32, y: 25, width: 48, height: 48))
        forwardBtn.setImage(UIImage(named: "forward.png"), for: UIControlState.normal)
        forwardBtn.addTarget(self, action: #selector(forwardBtnClicked), for: .touchUpInside)
        bottomPlayer.addSubview(forwardBtn)
        
        //rewind button
        let rewindBtn = UIButton(frame: CGRect(x: (widthOfView/2)-80, y: 25, width: 48, height: 48))
        rewindBtn.setImage(UIImage(named: "rewind.png"), for: UIControlState.normal)
        rewindBtn.addTarget(self, action: #selector(rewindBtnClicked), for: .touchUpInside)
        bottomPlayer.addSubview(rewindBtn)

        
        //shuffle button
        let shuffleBtn = UIButton(frame: CGRect(x: 28, y: 35, width: 32, height: 32))
        shuffleBtn.setImage(UIImage(named: "shuffle.png"), for: UIControlState.normal)
        shuffleBtn.addTarget(self, action: #selector(shuffleBtnClicked), for: .touchUpInside)
        bottomPlayer.addSubview(shuffleBtn)
        
        //repeat button
        let repeatBtn = UIButton(frame: CGRect(x: widthOfView-60, y: 35, width: 32, height: 32))
        repeatBtn.setImage(UIImage(named: "replay.png"), for: UIControlState.normal)
        repeatBtn.addTarget(self, action: #selector(repeatBtnClicked), for: .touchUpInside)
        bottomPlayer.addSubview(repeatBtn)
        
        
        
        
        
        
        //add slider
        playerSlider = UISlider(frame: CGRect(x:0, y: 0, width: widthOfView, height: 1))
        playerSlider?.minimumValue = 0
        playerSlider?.maximumValue = 100
        playerSlider?.isContinuous = true
        playerSlider?.tintColor = UIColor.white
        playerSlider?.value = 0
        playerSlider?.setThumbImage(UIImage(named: "progress_thumb"), for: UIControlState.normal)
    
        
        // playerSlider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
        bottomPlayer.addSubview(playerSlider!)
        
    }
    
 
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        
        
        if(localSongArrayList.count == songIndex + 1){
            songIndex = 0
        } else{
            songIndex += 1
        }
        
        play()
        
    }
    
    
    
    
}

extension UICollectionViewController: LocalStorageCellViewDelegate{
    
    func deleteSongFromPhone(forCell: LocalSongCell){
        
        
        // create the alert
        let alert = UIAlertController(title: "Action", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Play", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteSong(cellIndex: forCell.customItemIndex)
            //delete
            //self.collectionView?.deleteItems(at: forCell)
            
            //delete end
        }))
        
        
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteSong(cellIndex:IndexPath){
        
        let song = localSongArrayList[cellIndex.item]
        let songname:String = "\(song.title).mp3";
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(songname)
        
        do {
            try FileManager.default.removeItem(atPath: destinationUrl.path)
            localSongArrayList.remove(at: cellIndex.item)
            self.collectionView?.deleteItems(at: [cellIndex])
            self.collectionView?.reloadData()
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
}
