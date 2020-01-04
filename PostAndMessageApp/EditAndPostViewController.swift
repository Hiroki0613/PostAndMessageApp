//
//  EditAndPostViewController.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 03/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class EditAndPostViewController: UIViewController,UITextFieldDelegate {
    
    var passedImage = UIImage()
    
    var userName = String()
    var userImageString = String()
    var userImageData = Data()
    var userImage = UIImage()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    let screenSize = UIScreen.main.bounds.size
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextField.delegate = self
        
        //キーボードが出てきたときに、textField、送信ボタンが同時に上にスライドするコード
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

    
    @IBAction func postAction(_ sender: Any) {
    }
    
    
}
