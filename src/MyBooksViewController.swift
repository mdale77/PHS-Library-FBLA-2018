//
//  MyBooksViewController.swift
//  FBLA Project 1
//
//  Created by Mason Dale on 2/12/18.
//  Copyright © 2018 Mason Dale. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MyBooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //variables
    var bookList = [Book]()
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var date: Date?
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    //When tapped, the user is logged out
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginVC
        } catch {
            print("Problem logging out")
        }
    }
    
    //Called when user opens view
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        loadBooks()
        date = Date()
    }
    
    //Should be called everytime this screen is loaded
    func loadBooks() {
        ref = Database.database().reference()
        handle = ref?.child("users").child((Auth.auth().currentUser?.uid)!).child("mybooks").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                //creates book object
                let book = Book()
        
                book.setValuesForKeys(dictionary)
                //appends book to bookList, which is loaded onto collection view
                self.bookList.append(book)

                self.tableView.reloadData()
            }
        })
        
            
    }

    //Returns a table view with a size equal to the amount of titles
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookList.count
    }
    
    //Creates a table cell with attributes given from passed data
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let book = bookList[indexPath.item]
        
        //loads an image to the book image
        let url: URL = URL(string: book.imageSource!)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if data != nil {
                let image = UIImage(data: data!)
                if image != nil {
                    DispatchQueue.main.async {
                        cell.bookImage.image = image
                    }
                }
            }
        })
        task.resume()
        
        //set and adjust the labels
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.authorLabel.adjustsFontSizeToFitWidth = true
        
        //logic used to check what dateLabel should be shown to user
        let day: String = book.daysLeft!

        if (day == "-1") {
             cell.dateLabel.text = "Reserved"
        } else {
            let dateMaker = DateFormatter()
            dateMaker.dateFormat = "yyyy/MM/dd hh:mm:ss"
            
            let futureDate = dateMaker.date(from: day)
            let todayDate = dateMaker.date(from: (date?.getCurrentDate())!)
            if (todayDate?.compare(futureDate!) == .orderedDescending) {
                cell.dateLabel.text = "Overdue"
            } else {
                cell.dateLabel.text = "Date Due: " + book.daysLeft!
            }
        }
        
        return cell
    }
    
    //Handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //get string id to use for deletion of child
            let id = bookList[indexPath.row].bookId!
        
            //remove value from the database
            ref?.child("users").child((Auth.auth().currentUser?.uid)!).child("mybooks").child(id).removeValue { (error, ref ) in
                if error != nil {
                    print("error \(String(describing: error))")
                } 
            }
            
            //remove the item from bookList
            bookList.remove(at: indexPath.row)
            
            //delete tableView row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
