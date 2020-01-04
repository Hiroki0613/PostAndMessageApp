//
//  PostTableViewController.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 04/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import UIKit
import Photos

class PostTableViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    
    @IBOutlet weak var cameraButton: UIButton!
    
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
        
        if info[.originalImage] as? UIImage != nil {
            
            //compressionQualityを設定することでデータサイズを小さくしている
            let selectedImage = info[.originalImage] as! UIImage
            UserDefaults.standard.set(selectedImage.jpegData(compressionQuality: 0.1), forKey: "userImage")
            
            //ここはpostImageを入れる。後日修正
            logoImageView.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
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
    
    
    
    
}
