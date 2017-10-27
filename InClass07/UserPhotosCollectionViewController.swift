//
//  UserPhotosCollectionViewController.swift
//  InClass07
//
//  Created by Ayyanchira, Akshay Murari on 10/26/17.
//  Copyright © 2017 Example. All rights reserved.
//

import UIKit
import Firebase
import Photos

private let reuseIdentifier = "Custom"

class UserPhotosCollectionViewController: UICollectionViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    let picker = UIImagePickerController()
    var imageCollection = [UIImage]()
    var imageArray:[NSDictionary] = [NSDictionary]()
    let uuid = UserDefaults.standard.object(forKey: "uuid") as! String
    let rootref = Database.database().reference()
    let storage = Storage.storage()
    let activityIndicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        picker.delegate = self
        fetchPhotos()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageArray.removeAll()
        fetchPhotos()
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    
    //MARK: - Image Picker Delegates

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Reached here")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageCollection.append(chosenImage)
        dismiss(animated: true, completion: nil)
        uploadToFirebase(image: chosenImage)
        collectionView?.reloadData()
//        }else{
//            let alertController = UIAlertController(title: "Upload Failed", message: "Failed while uploading to cloud", preferredStyle: UIAlertControllerStyle.alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
//        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //PRAGMA MARK:- Firebase Photo upload and retrieval methods
    func uploadToFirebase(image:UIImage) -> Bool {
        var status = false
        let date = Date()
        let storageRef = storage.reference(withPath: "Images/\(self.uuid)/\(date.timeIntervalSince1970).jpg")
        let imageData:Data = UIImageJPEGRepresentation(image,0.5)!
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
                status = false
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()
                print(downloadURL ?? "No downloadURL fetched")
                status = true
                self.uploadCompleteWith(metadata: metadata ,date:date)
            }
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
//        let observer = uploadTask.observe(.progress) { snapshot in
//            // Upload reported progress
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)/Double(snapshot.progress!.totalUnitCount)
//            if percentComplete == 100{
//                self.uploadComplete(withMetadata: )
//            }
//
//        }
        return status
    }
    
    
    func fetchPhotos() {
        let userRef = self.rootref.child("Users").child(self.uuid).child("Images")
        userRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary{
                self.imageArray.removeAll()
                for value in values{
                    let object = value.value as? [String:Any]
                    let url = object!["url"] as! String
                    let ref = object!["ref"] as! String
                    let date = object!["date"] as! String
                    let dictionaryObject = [
                        "url" : url,
                        "ref" : ref,
                        "date": date
                    ]
                    self.imageArray.append(dictionaryObject as NSDictionary)
                }
//                self.imageArray.removeAll()
//                self.imageArray.append(values)
//                for object in self.imageArray{
////                    let url = try? URL(string: object.object(forKey: "url") as! String)
//                    let key = object.allKeys[0] as! String
//                    print(object.object(forKey: key) ?? "Nothing found as URL")
////                    let imageData =
//                }
//                self.collectionView?.reloadData()
            }
            self.collectionView?.reloadData()
        }
        print("Called\n\n\n")
    }
    
    func uploadCompleteWith(metadata:StorageMetadata?, date:Date){
        print("Upload complete")
        
        let stringURL = metadata!.downloadURL()?.absoluteString
        let imageRef = self.rootref.child("Users").child(self.uuid).child("Images").childByAutoId()
        let imageObject = [
            "ref" : imageRef.key,
            "url" : stringURL,
            "date": String(date.timeIntervalSince1970)
        ]
        imageRef.setValue(imageObject)
        self.activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        fetchPhotos()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return imageArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomCollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        let imageObject = imageArray[indexPath.row]
        let imageURLString = imageObject.object(forKey: "url") as! String
        let imageURL = URL.init(string: imageURLString)
        
        cell.image.downloadedFrom(url: imageURL!)
        
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // let selectedImage = imageCollection[indexPath.row]
        performSegue(withIdentifier: "viewPhoto", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto" {
            let photoViewController = segue.destination as! PhotoViewController
            let index = sender as! Int
            let imageObject = imageArray[index]
            let imageURLString = imageObject.object(forKey: "url") as! String
            let imageURL = URL.init(string: imageURLString)
            photoViewController.imageURL = imageURL
            photoViewController.date = imageObject.object(forKey: "date") as! String
            photoViewController.imageKey = imageObject.object(forKey: "ref") as! String
        }
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        UserDefaults.standard.removeObject(forKey: "uuid")
        do {
            try Auth.auth().signOut()
        } catch let signoutError as NSError {
            print(signoutError.localizedDescription)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}


class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}

extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                
                let data = data, error == nil,
                
                let image = UIImage(data: data)
                
                else { return }
            
            DispatchQueue.main.async() { () -> Void in
                
                self.image = image
                
            }
            
            }.resume()
        
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        guard let url = URL(string: link) else { return }
        
        downloadedFrom(url: url, contentMode: mode)
        
    }
    
}
