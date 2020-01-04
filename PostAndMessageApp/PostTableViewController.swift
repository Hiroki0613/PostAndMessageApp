//
//  PostTableViewController.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 04/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import UIKit
import Photos
import Firebase
import SDWebImage

class PostTableViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    
    @IBOutlet weak var cameraButton: UIButton!
    
    var ref: DatabaseReference!
    
    var selectedImage = UIImage()
    
    var userName = String()
    var commentString = String()
    var creatDate = String()
    var contentImageString = String()
    
    var contentsArray =  [Contents]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        //ユーザーに画像ライブラリーの許可を促す。
        PHPhotoLibrary.requestAuthorization { (status) in
            
            switch status{
                
            case .authorized:
                print("許可されています。")
            case .denied:
                print("拒否された")
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            }
        }
        
        timeLineTableView.delegate = self
        timeLineTableView.dataSource = self
        
    }
    
    
    
    
    
    
    
    
    
    
    @IBAction func cameraAction(_ sender: Any) {
        
     showAlert()
    }
    
    
    
    
    
    
    
    
    
    // MARK: - カメラ、アルバムの使用許可
    func doCamera(){
        let sourceType = UIImagePickerController.SourceType.camera
        //カメラが利用可能かチェック,カメラが使えるのならばTrueが返ってくる
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //変数化、インスタンス化する
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            present(cameraPicker, animated: true, completion: nil)
        } else {
            print("エラー")
        }
    }
    
    //アルバム立ち上げメソッド
    func doAlbum(){
        
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        
        //アルバムが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            let albumPicker = UIImagePickerController()
            albumPicker.allowsEditing = true
            albumPicker.sourceType = sourceType
            albumPicker.delegate = self
            
            self.present(albumPicker, animated: true, completion: nil)
        }
    }
    
    // 写真が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        selectedImage = info[.originalImage] as! UIImage
        
        //ナビゲーションを用いて画面遷移
        let editPostVC = self.storyboard?.instantiateViewController(withIdentifier: "editPost") as! EditAndPostViewController
        
        editPostVC.passedImage = selectedImage
        editPostVC.userName = userName
        self.navigationController?.pushViewController(editPostVC, animated: true)
        
        //ピッカーを閉じる
        picker.dismiss(animated: true, completion: nil)
        
    }
      
    //カメラの画面が閉じる操作
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //アラート
      func showAlert(){
          let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか？", preferredStyle: .actionSheet)
          
          let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
              self.doCamera()
          }
          
          let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
              self.doAlbum()
          }
          
          let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
          
          alertController.addAction(action1)
          alertController.addAction(action2)
          alertController.addAction(action3)
          
          self.present(alertController, animated: true, completion: nil)
          
      }
    
    
    
    
    
        // MARK: - timeLineTableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = timeLineTableView.dequeueReusableCell(withIdentifier: "timeLineCell", for: indexPath)
        
        //コンテンツに受信したものを貼り付けていく
        //タグは1からスタートすること。配列は0からスタート。
        
        //ユーザー名
        let userNameLabel = cell.viewWithTag(1) as! UILabel
        userNameLabel.text = contentsArray[indexPath.row].userNameString
        
        //投稿日時
        let dateLabel = cell.viewWithTag(2) as! UILabel
        dateLabel.text = contentsArray[indexPath.row].postDateString
        
        //投稿画像
        let postImageView = cell.viewWithTag(3) as! UIImageView
        postImageView.sd_setImage(with: URL(string: contentsArray[indexPath.row].postImageString), completed: nil)
        
        //コメントラベル
        let commentLabel = cell.viewWithTag(4) as! UILabel
        commentLabel.text = contentsArray[indexPath.row].commentString
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 385
    }
    
    //FirebaseDatabaseに蓄積されているデータを取得する
    func fetchContentsData(){
        
         //queryLimited toLast に100を入れることで、最新100件を取得
        //queryOrderdでpostDateにすることで、postDateの順番に取得
        let fetchRef = ref.child("timeLine").queryLimited(toLast: 100).queryOrdered(byChild: "postDate").observe(.value) { (snapShot) in
            
            //contentsArrayに入っているものを空にして、fetcRefで取得したものをAppendしていく
            self.contentsArray.removeAll()
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if let postData = snap.value as? [String:Any] {
                        let userName = postData["userName"] as? String
                        let contents = postData["contens"] as? String
                        let comment = postData["comment"] as? String
                        
                        var postDate:CLong?
                        
                        if let postedDate = postData["postDate"] as? CLong{
                            postDate = postedDate
                        }
                        
                        //postDateを時間に変換
                        let timeString = self.convertTimeStamp(serverTimeStamp: postDate!)
                        
                        self.contentsArray.append(Contents(userNameString: userName!, postImageString: contents!, commentString: comment!, postDateString: timeString))
                        
                    }
                }
                self.timeLineTableView.reloadData()
                

                let indexPath = IndexPath(row: self.contentsArray.count - 1, section: 0)
                
                if self.contentsArray.count >= 5 {

                    //タイムラインを一番下まで自動スクロール
                    self.timeLineTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    
    func convertTimeStamp(serverTimeStamp: CLong) -> String{
           
           let x = serverTimeStamp / 1000
           let date = Date(timeIntervalSince1970: TimeInterval(x))
           let formatter = DateFormatter()
           formatter.dateStyle = .long
           formatter.timeStyle = .medium
           
           return formatter.string(from: date)
       }
       
    
    
}
