//
//  PostTableViewController.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 04/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import UIKit
import Photos

class PostTableViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    
    @IBOutlet weak var cameraButton: UIButton!
    
    var selectedImage = UIImage()
    
    var userName = String()
    var commentString = String()
    var creatDate = String()
    var contentImageString = String()
    
    var contentsArray =  [Contents]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //userNameで何かしらデータが保存されていたのであれば
        if UserDefaults.standard.object(forKey: "userName") != nil {
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        
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
        let contentImageView = cell.viewWithTag(3) as! UIImageView
        contentImageView.sd_setImage(with: URL(string: contentsArray[indexPath.row].postImageString), completed: nil)
        
        //コメントラベル
        let commentLabel = cell.viewWithTag(4) as! UILabel
        commentLabel.text = contentsArray[indexPath.row].commentString
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 385
    }
    
    
    
    
    
}
