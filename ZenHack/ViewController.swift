//
//  ViewController.swift
//  ZenHack
//
//  Created by KazushiKawamura on 10/1/16.
//  Copyright © 2016 KazushiKawamura. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import RxSwift
import FontAwesome_swift
import Alamofire
import AVFoundation
import SVProgressHUD
import Photos

class ViewController: UIViewController, AVAudioPlayerDelegate, UITextFieldDelegate{
    // ユーザーへの許可のリクエスト.
    var request : PHCollectionListChangeRequest!
    // アラート.
    var myAlert : UIAlertController!
    // AlertのOKAction.
    var myOKAction : UIAlertAction!
    // アルバム名を保存するtext.
    var text : String!
    
    
    let disposeBag = DisposeBag()

    var datas = [Data]()
    
    let dataURLs = [
        "http://shakuhachi-genkai.com/images/photo/Land02-01.jpg",
        "https://upload.wikimedia.org/wikipedia/en/b/b9/Love_Live!_promotional_image.jpg",
        "http://www.lovelive-anime.jp/otonokizaka/img/release/cd_56a.jpg",
        "http://i2.wp.com/funip.jp/wp-content/uploads/2014/04/56a1e59c8ae41baf92c59de4a6f06d53.jpg?resize=400%2C300",
        "http://i.ytimg.com/vi/5krGxU5UA2g/maxresdefault.jpg",
        "https://media.giphy.com/media/3o7abmKhQ80pURWbgQ/giphy.gif",
    ]
    
    var verticalDataURLs = [
        "http://shakuhachi-genkai.com/images/photo/Land02-01.jpg",
    ]
    //-----------マイク用
    let fileManager = NSFileManager()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var now_recording = false
    let fileName = "sample.wav"
    let watson = WATSON_S2TAPI()

    
    var imageCollectionView: UICollectionView!
    var arrowButton: ArrowButton!
    var imageListView: UICollectionView!
    var microphoneButton = UIButton()
    // TODO: Standarize
    var inputTextField: UITextField!
    
    var segmentView = UIView()
    var segmentControl = UISegmentedControl()
    var drawingControl = UISegmentedControl()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        WATSON_S2TAPI.IBMUname = "39f05951-139e-469a-babe-aba2c47e50f4"
        WATSON_S2TAPI.IBMPass = "7MlOotFadHE8"
        WATSON_S2TAPI.upateKeySettings()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setupHotizontalImage()
        // let view
        
        segmentView = UISegmentedControl(frame: CGRectNull)
        segmentView.backgroundColor = UIColor("#f1f1f1", 1.0)
        self.view.addSubview(segmentView)
        segmentView.snp_makeConstraints { (make) in
            make.bottom.equalTo(imageCollectionView.snp_top)
            make.left.right.equalTo(0)
            make.height.equalTo(40)
        }
        
        let array = ["me", "you"]
        self.segmentControl = UISegmentedControl(items: array)
        self.segmentControl.selectedSegmentIndex = 0
        self.segmentControl.addTarget(self, action: #selector(segmentedControlChanged), forControlEvents: .ValueChanged)
        segmentView.addSubview(segmentControl)
        segmentControl.snp_makeConstraints { (make) in
            make.bottom.equalTo(segmentView.snp_bottom).offset(-4)
            make.left.equalTo(8)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        let d = ["draw", "normal"]
        self.drawingControl = UISegmentedControl(items: d)
        self.drawingControl.selectedSegmentIndex = 1
        self.segmentControl.addTarget(self, action: #selector(segmentedControlChanged), forControlEvents: .ValueChanged)
        self.drawingControl.addTarget(self, action: #selector(drawingControlChanged), forControlEvents: .ValueChanged)
        segmentView.addSubview(drawingControl)
        drawingControl.snp_makeConstraints { (make) in
            make.bottom.equalTo(segmentView.snp_bottom).offset(-4)
            make.right.equalTo(-8)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor("#cccccc", 1.0)
        self.view.addSubview(line)
        line.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(segmentView.snp_top)
            make.height.equalTo(1.0)
        }
        
        self.setupVerticalImage()
        
        WATSON_S2TAPI.LoadKeySettings()
        
//        arrowButton = ArrowButton(frame: CGRectNull)
//        self.view.addSubview(arrowButton)
//        arrowButton.snp_makeConstraints { (make) in
//            make.bottom.equalTo(self.imageCollectionView.snp_top)
//            make.right.equalTo(0)
//            make.width.equalTo(40)
//            make.height.equalTo(30)
//        }
        
        self.inputTextField = UITextField(frame: CGRectNull)
        self.inputTextField.backgroundColor = UIColor("#ffffff", 0.7)
        self.inputTextField.layer.cornerRadius = 4.0
        self.inputTextField.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0);
        inputTextField.delegate = self
        self.view.addSubview(inputTextField)
        inputTextField.snp_makeConstraints { (make) in
            make.top.equalTo(25.0)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalTo(50)
        }
        
        self.microphoneButton = UIButton(frame: CGRectNull)
        self.microphoneButton.titleLabel?.font = UIFont.fontAwesomeOfSize(18.0)
        self.microphoneButton.setTitle(String.fontAwesomeIconWithCode("fa-microphone"), forState: .Normal)
        self.microphoneButton.setTitleColor(UIColor("#333333", 1.0), forState: .Normal)
        self.view.addSubview(self.microphoneButton)
        self.microphoneButton.snp_makeConstraints { (make) in
            make.right.equalTo(self.inputTextField.snp_right)
            make.width.height.equalTo(50)
            make.centerY.equalTo(self.inputTextField)
        }
        
        self.microphoneButton.addTarget(self, action: #selector(microphonePressed), forControlEvents: .TouchUpInside)
        
      
        // Buttonの定義.
        let myButton = UIButton()
        myButton.frame = CGRectMake(0,0,200,40)
        myButton.backgroundColor = UIColor.redColor();
        myButton.layer.masksToBounds = true
        myButton.setTitle("アルバムを作成", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        myButton.addTarget(self, action: #selector(ViewController.onClickMyButton(_:)), forControlEvents: .TouchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButton)
        
        
        
    
        DataModel.fetchDatas("犬")
            .subscribe(
                onNext: { [weak self](datas) in
                    self?.datas = datas
                    self?.imageCollectionView.reloadData()
                }
            )
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //----------------アルバム⬇︎
    /*
     ボタンイベント.
     */
    func onClickMyButton(sender: UIButton){
        //PhotoKitの使用をユーザーから許可を得る.
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch(status){
            case .Authorized:
                print("Authorized")
                
            case .Denied:
                print("Denied")
                
            case .NotDetermined:
                print("NotDetermined")
                
            case .Restricted:
                print("Restricted")
            }
        }
        
        
        // UIAlertControllerを作成.
        myAlert = UIAlertController(title: "思い出を保存♪", message: "アルバム名を入力", preferredStyle: .Alert)
        
        // OKのアクションを作成.
        myOKAction = UIAlertAction(title: "OK", style: .Default) { action in
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                
                // iOSのフォトアルバムにコレクション(アルバム)を追加する.
                self.request = PHCollectionListChangeRequest.creationRequestForCollectionListWithTitle(self.text)
                
                }, completionHandler: { (isSuccess, error) -> Void in
                    
                    if isSuccess == true {
                        print("Success!")
                        //--------------アルバムに保存
//                        //savingView配下のeditingPhoto等を1枚の画像として保存
//                        UIGraphicsBeginImageContextWithOptions(self.imageListView.frame.size, false, 0)
//                        self.imageListView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//                        print("保存")
//                        
//                        let exportImage = UIGraphicsGetImageFromCurrentImageContext()
//                        
//                        UIGraphicsEndImageContext()
//                        
//                        //アルバム名を指定する
//                        let albumTitle = "abc"//self.text
//                        print(self.text)
//                        
//                        var theAlbum: PHAssetCollection?
//                        
//                        // アルバムを検索
//                        let result = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: nil)
//                        result.enumerateObjectsUsingBlock({(object, index, stop) in
//                            if let theCollection = object as? PHAssetCollection where
//                                theCollection.localizedTitle == albumTitle
//                            {
//                                theAlbum = theCollection
//                                print("アルバム検索")
//                            }
//                        })
//                        // アルバムにイメージを保存
//                        if let anAlbum = theAlbum {
//                            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(exportImage)
//                                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset!
//                                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: anAlbum)
//                                albumChangeRequest!.addAssets([assetPlaceholder])
//                                }, completionHandler: nil)
//                            print("save image into the Album.")
//                        }
                        let albumTitle = self.text // アルバム名
                        let savingImage = //UIImage(named: "a.png")! // 保存するイメージ
                        PhotoAlbumUtil.saveImageInAlbum(savingImage, albumName: albumTitle, completion: { (result) in
                            switch result {
                            case .SUCCESS:
                                // 保存に成功した時
                                break
                            case .ERROR:
                                // 保存orアルバム生成orアルバムに追加が失敗した時
                                break
                            case .DENIED:
                                // アプリ内で写真へのアクセス認証を一度も行っていないか、認証が許可されなかった時
                                break
                            default:
                                break
                            }
                        })
                        
                        
                    }
                    else{
                        print("error occured")
                    }
                    
            })
        }
        
        // OKボタンを押せないようにする.
        //myOKAction.enabled = false
        
        // キャンセルのアクションを作成.
        let myNoAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (action) -> Void in
            print("cancel")
        }
        
        // タイトルを入力する用のTextFieldをAlertに追加する.
        myAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            // 編集が終わる(returnキーが押される)とメソッドが呼び出される.
            textField.addTarget(self, action: #selector(ViewController.onTextEnter(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        }
        
        myAlert.addAction(myOKAction)
        myAlert.addAction(myNoAction)
        
        // UIAlertを発動する.
        presentViewController(myAlert, animated: true, completion: nil)
    }
    
    /*
     TextFieldのTextの編集が終了した時に呼ばれるメソッド.
     */
    func onTextEnter(sender : UITextField){
        
        text = sender.text
        myOKAction.enabled = true
        
    }
    
    //----------------アルバム⬆︎
    
    
    
    
    
    
    
    
    
    
    
    func setUpPlayer() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: self.documentFilePath())
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        } catch {
            print("AVAudioPlayerの作成に失敗")
        }
    }
    
    // 録音するために必要な設定を行う
    func setupAudioRecorder() {
        // 再生と録音機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        try! session.setActive(true)
        let recordSetting : [String : AnyObject] = [
            AVFormatIDKey:Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey : 16,
            AVLinearPCMIsFloatKey:false,
            AVLinearPCMIsBigEndianKey:false,
            AVEncoderAudioQualityKey : AVAudioQuality.Min.rawValue
        ]
        do {
            try audioRecorder = AVAudioRecorder(URL: self.documentFilePath(), settings: recordSetting)
            audioRecorder?.prepareToRecord()
        } catch {
            print("初期設定でerror")
        }
    }
    
    // 録音するファイルのパスを取得(録音時、再生時に参照)
    func documentFilePath()-> NSURL {
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        let dirURL = urls[0]
        return dirURL.URLByAppendingPathComponent(fileName)
    }
    
    // 音声の再生が終了すると呼ばれる(今は何もしない)
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer,
                                     successfully flag: Bool) {
    }
    
    
    func segmentedControlChanged(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        if sender.selectedSegmentIndex == 0 {
        self.watson.endpoint = "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?timestamps=true&word_alternatives_threshold=0.9&model=en-US_BroadbandModel"
        } else {
            self.watson.endpoint = "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?timestamps=true&word_alternatives_threshold=0.9&model=ja-JP_BroadbandModel"
        }
    }
    
    func drawingControlChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.imageListView.scrollEnabled = false
        } else {
            self.imageListView.scrollEnabled = true
        }
    }
    
    // 下の横スクロールのやつ
    func setupHotizontalImage() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = 8.0
        layout.scrollDirection = .Horizontal
        
        self.imageCollectionView = UICollectionView(frame: CGRectNull, collectionViewLayout: layout)
        self.imageCollectionView.registerNib(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        self.imageCollectionView.backgroundColor = UIColor("#f1f1f1", 1.0)
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        self.view.addSubview(imageCollectionView)
        self.imageCollectionView.snp_makeConstraints { (make) in
            make.right.bottom.left.equalTo(0)
            make.height.equalTo(150)
        }
    }
    
    func setupVerticalImage() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = 8.0
        layout.scrollDirection = .Vertical
        
        self.imageListView = UICollectionView(frame: CGRectNull, collectionViewLayout: layout)
        self.imageListView.registerNib(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        self.imageListView.backgroundColor = UIColor("#C5EFF7", 1.0)
        self.imageListView.alwaysBounceVertical = true
        self.imageListView.delegate = self
        self.imageListView.dataSource = self
        self.imageListView.contentInset = UIEdgeInsets(top: 90, left: 0, bottom: 0, right: 0)
        self.view.addSubview(imageListView)
        self.imageListView.snp_makeConstraints { (make) in
            make.right.top.left.equalTo(0)
            make.bottom.equalTo(self.segmentView.snp_top)
        }
        
    }
    
    // マイクボタンの押した時
    func microphonePressed() {
        self.setupAudioRecorder()
        self.audioRecorder?.record()
        self.now_recording = true
        
        let alert: UIAlertController = UIAlertController(title: "録音中", message: "録音後送信して下さい", preferredStyle:  UIAlertControllerStyle.Alert)
        
        // アラートのOK押下時の処理
        let defaultAction: UIAlertAction = UIAlertAction(title: "送信", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            //SVProgressHUD.showWithStatus("解析中...")
            self.audioRecorder?.stop()
            self.now_recording = false
            self.setUpPlayer()
            
            self.watson.send(self.documentFilePath(), callback: {_,_,_ in
                dispatch_async(dispatch_get_main_queue(),{
                    //----------------返答------------------
                    SVProgressHUD.dismiss()
                    self.inputTextField.text = self.watson.transcript
                    DataModel.fetchDatas(self.inputTextField.text!)
                        .subscribe(
                            onNext: { [weak self](datas) in
                                self?.datas = datas
                                self?.imageListView.reloadData()
                            }
                        )
                        .addDisposableTo(self.disposeBag)
                })
            })
            print("録音完了&送信")
        })
        
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.audioRecorder?.stop()
            self.now_recording = false
            print("Cancel")
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // ④ Alertを表示
        presentViewController(alert, animated: true, completion: nil)
        
//        let vc = DrawableViewController()
//        vc.modalPresentationStyle = .OverFullScreen
//        presentViewController(vc, animated: true, completion: nil)  
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    

    
    //改行でキーボード閉じる
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        inputTextField.resignFirstResponder()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == imageListView {
            let width: CGFloat = 200
            let height: CGFloat = 200
            
            return CGSizeMake(width, height)
        }
        
        
        return CGSizeMake(150, 150)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    // on click
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == imageListView {
            
        } else {
            let url = self.datas[indexPath.section].thumbnails![indexPath.row]
            self.verticalDataURLs.append(url)
            self.imageListView.reloadData()
            let i = NSIndexPath(forRow: self.verticalDataURLs.count - 1, inSection: 0)
            self.imageListView.scrollToItemAtIndexPath(i, atScrollPosition: .Top, animated: true)
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath)
        if collectionView == self.imageListView {
            (cell as! ImageCell).imageView.sd_setImageWithURL(NSURL(string: verticalDataURLs[indexPath.row]))
            (cell as! ImageCell).drawable = true
        } else {
            let url = NSURL(string: datas[indexPath.section].thumbnails![indexPath.row])
            print(url)
            (cell as! ImageCell).imageView.sd_setImageWithURL(url)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.imageListView {
            return verticalDataURLs.count
        } else {
            return datas[section].thumbnails!.count
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == imageCollectionView {
            // section
            return datas.count
        }
        return 1
    }
    
}