//
//  EditAndPostViewController.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 03/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import UIKit
import Firebase

class EditAndPostViewController: UIViewController,UITextFieldDelegate {

    //カメラ、アルバムの画像がtossされている
    var passedImage = UIImage()
    
    var userName = String()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var ref: DatabaseReference!
    
    let screenSize = UIScreen.main.bounds.size
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        commentTextField.delegate = self
        
        
        // MARK: - キーボードの可変コード    //キーボードが出てきたときに、textField、送信ボタンが同時に上にスライドするコード
        NotificationCenter.default.addObserver(self, selector: #selector(EditAndPostViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //キーボードが閉じる時に、textFieldの高さが可変になるもの。
        NotificationCenter.default.addObserver(self, selector: #selector(EditAndPostViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //アプリ内に保存されているデータを呼び出して、
        //パーツに反映していく
        if UserDefaults.standard.object(forKey: "userName") != nil {
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        userNameLabel.text = userName
        postImageView.image = passedImage
        
    }
    
    
    
    
    // MARK: - キーボードの可変コード
    @objc func keyboardWillShow(_ notification:NSNotification){
        //キーボードの高さを取得
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        
        //上にスライドした後の高さを決めたい。
        // フレームの高さ - キーボードの高さ - messageTextFieldの高さ
        commentTextField.frame.origin.y = screenSize.height - keyboardHeight - commentTextField.frame.height
        sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
    }
    
    @objc func keyboardWillHide(_ notifiation:NSNotification){
        
        //下へスライドした後の高さを決めたい。
        //今回はキーボードが消えるので、キーボードの高さは考慮しない。
        //スクリーンの高さ - messageTextFieldの高さ
        commentTextField.frame.origin.y = screenSize.height - commentTextField.frame.height
        
        guard let rect = (notifiation.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            
            
            //キーボードが下がる時間をdurationとして取得
            let duration = notifiation.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
        
    }
    
    
    //画面をタッチした時にキーボードが下がる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextField.resignFirstResponder()
    }
    
    //画面をタッチした時にキーボードが下がる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    
    
    // MARK: - Database,Storage
    @IBAction func postAction(_ sender: Any) {
        
        
        //DBのchildを決めていく。つまり、DatabaseのURLを取得していく
        let timeLineDB = ref.child("timeLine").childByAutoId()
        
        //ストレージサーバーのURLを取得していく
        //URLの場所はFirebaseのStorageに記載
        let storage = Storage.storage().reference(forURL: "gs://postandmessageapp.appspot.com")
        
        //データを更新、削除するためのパスを作成する。
        //フォルダを作成していく。ここに画像が入っていく。
        //フォルダの名前はそれぞれ、Users Contentsとしておく
        let key = timeLineDB.child("Contents").childByAutoId().key
        
        
        
        /*
         参照を作成する
         ファイルをアップロードするには、まず Cloud Storage 内のファイルをアップロードする場所への Cloud Storage 参照を作成します。
         ストレージ ルートに子パスを付加することで、参照を作成できます。
         */
        let imageRef = storage.child("Contents").child("\(String(describing:key!)).jpg")
        
        var postImageData:Data = Data()
        
        if postImageView.image != nil {
            
            //そのままの画像データでStorageサーバーに送ると、かなり大きいので100分の1に圧縮している
            postImageData = (postImageView.image?.jpegData(compressionQuality: 0.01))!
        }
        
        
        //アップロードタスク。デバイスからStorageサーバーに画像を送信
        let upLoadTask = imageRef.putData(postImageData, metadata: nil) { (metaData, error) in
            
            if error != nil {
                print(error)
                return
            }
        }
        
        
        //サーバーに画像に保存をした後に、画像が保存されているURLをFireBase Storageが返信してくる
        imageRef.downloadURL { (url, error) in
            
            //urlに何か入っていたら
            if url != nil {
                
                //databaseに送信するデータの準備
                //ServerValue.timestanp()で現在時刻を取得
                let timeLineInfo = ["userName":self.userName as Any,"contents":url?.absoluteString as Any,"comment":self.commentTextField.text as Any,"postDate":ServerValue.timestamp()] as [String:Any]
                
                //このコードでtimeLineInfoの情報をFirebaseDBへ送信したことを記載
                timeLineDB.updateChildValues(timeLineInfo)
                
                //ナビゲーションコントローラーでの”戻る"の意味になる。modal遷移でのdismissと同じ
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        //ここで「アップロードを続けてください」と書いてある
        upLoadTask.resume()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
