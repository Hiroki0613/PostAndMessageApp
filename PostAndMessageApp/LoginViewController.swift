//
//  LoginViewController.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 03/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registerNewUser(_ sender: Any) {
        
        //新規登録
        //ここでのemailTextField、passWordTextFieldはIBOutletで結びつけたものを使用
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passWordTextField.text!) { (user, error) in
            
            //エラーがnilでないなら、つまりエラーが存在しているなら
            if error != nil{
                print(error as Any)
            } else {
                print("ユーザーの作成が成功しました")
                
                //画面をチャット画面に遷移させる
                self.performSegue(withIdentifier: "goToPostView", sender: nil)
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPostView"{
            let postTableVC = segue .destination as! PostTableViewController
            
            postTableVC.userName = emailTextField.text!
        }
     
    }
    
    
    @IBAction func loginUser(_ sender: Any) {
        
        //ログイン
        //ここでのemailTextField、passWordTextFieldはIBOutletで結びつけたものを使用
        Auth.auth().signIn(withEmail: emailTextField.text!, password:passWordTextField.text!) { (user, error) in
            
            //エラーがnilでないなら、つまりエラーが存在しているなら
            if error != nil {
                print(error as Any)
            } else {
                print("ログインが成功！")
                
                //以下の場所は、新規登録が完了後に動かしたいサンプルコードを記載しています
                
                //画面をチャット画面に遷移させる
                self.performSegue(withIdentifier: "goToPostView", sender: nil)
            }
        }
        
    }
    

}

