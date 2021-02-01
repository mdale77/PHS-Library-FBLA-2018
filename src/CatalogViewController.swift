//
//  CatalogViewController.swift
//  PHS Library
//
//  Created by Mason Dale on 2/8/18.
//  Copyright © 2018 Mason Dale. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class CatalogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //variables
    var handle: DatabaseHandle?
    var ref:DatabaseReference?
    var uid:String?
    var bookList = [Book]()
    var tagKey: Int = 0
    
    //outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Called when user opens view
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        loadCatalog()
        viewSetup()
        
    }
    
    //Setups up collection view layout
    func viewSetup() {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width - 20)/2, height: self.collectionView.frame.size.height/2.15)
    }
    
    //Called when user loads catalog screen. Loads book information from database
    func loadCatalog() {
        ref = Database.database().reference()
        handle = ref?.child("books").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                //creates book object
                let book = Book()
                
                print("HELLO")
                //set values to book object
                book.setValuesForKeys(dictionary)
                
                //appends book to bookList, which is loaded onto collection view
                self.bookList.append(book)
                
                //reload view on background
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    //Returns a collection view of the amount of books in bookList array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }
    
    //Creates the individual cells for the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        //Cell Style
        cell.layer.cornerRadius = 15
        
        //Image Sytle
        cell.bookImage.layer.cornerRadius = 10
        
        //Button Style
        cell.checkOutButton.layer.cornerRadius = 5
        cell.reserveButton.layer.cornerRadius = 5
        
        //Give a cell an author text and a title text
        let user = bookList[indexPath.item]
        cell.bookTitle.text = user.title
        cell.bookAuthor.text = user.author
        cell.bookTitle.adjustsFontSizeToFitWidth = true
        cell.bookAuthor.adjustsFontSizeToFitWidth = true
        
        //Loads an image to the book image
        let url: URL = URL(string: user.imageSource!)!
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
        
        //used to mark individual buttons in collection view for events
        cell.checkOutButton.tag = tagKey
        cell.reserveButton.tag = tagKey
        tagKey += 1
        
        //check out tapped
        cell.checkOutButton.addTarget(self, action: #selector(checkOutButtonTappedInCollectionViewCell), for: UIControlEvents.touchUpInside)
        //reserve tapped
        cell.reserveButton.addTarget(self, action: #selector(reserveButtonTappedInCollectionViewCell), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    //Called when checkout button is clicked
    @objc func checkOutButtonTappedInCollectionViewCell(sender: UIButton) {
        //set values
        let bookTitle = bookList[sender.tag].title!
        let bookAuthor = bookList[sender.tag].author!
        let bookImage = bookList[sender.tag].imageSource!
        let date = Date()
        let bookDaysLeft = date.getDueDate()
        let bookIsReserved = "false"

        //write data to database
        writeData(titleValue: bookTitle, authorValue: bookAuthor, daysLeftValue: bookDaysLeft, isReservedValue: bookIsReserved, imageSourceValue: bookImage)
    }
    
    //Called when reserve button is clicked
    @objc func reserveButtonTappedInCollectionViewCell(sender: UIButton) {
        //set values
        let bookTitle = bookList[sender.tag].title!
        let bookAuthor = bookList[sender.tag].author!
        let bookImage = bookList[sender.tag].imageSource!
        let bookDaysLeft = "-1"
        let bookIsReserved = "true"
        
        //write data to database
        writeData(titleValue: bookTitle, authorValue: bookAuthor, daysLeftValue: bookDaysLeft, isReservedValue: bookIsReserved, imageSourceValue: bookImage)
    }
    
    //Helper function used to write data to the database. Called by two button functions
    func writeData(titleValue: String, authorValue: String, daysLeftValue: String, isReservedValue: String, imageSourceValue: String) {
        uid = (Auth.auth().currentUser?.uid)!
        
        let key = (ref?.child("users").child(uid!).child("mybooks").childByAutoId().key)!
        
        let book = ["title" : titleValue,
                    "author" : authorValue,
                    "daysLeft" : daysLeftValue,
                    "imageSource": imageSourceValue,
                    "bookId" : key] as [String : Any]
        
        let postBook = ["\(key)" : book]
        
        ref?.child("users").child(uid!).child("mybooks").updateChildValues(postBook)
        
        //return to MyBooks VC
        _ = self.navigationController?.popViewController(animated: true)
    }

}
