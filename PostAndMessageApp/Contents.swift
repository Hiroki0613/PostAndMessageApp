//
//  Contents.swift
//  PostAndMessageApp
//
//  Created by 宏輝 on 03/01/2020.
//  Copyright © 2020 宏輝. All rights reserved.
//

import Foundation

class Contents{
    
    var userNameString: String = ""
    var postImageString: String = ""
    var commentString: String = ""
    var postDateString: String = ""
    
    init(userNameString:String,postImageString:String,commentString:String,postDateString:String){
        
        self.userNameString = userNameString
        self.postImageString = postImageString
        self.commentString = commentString
        self.postDateString = postDateString

    }
}
