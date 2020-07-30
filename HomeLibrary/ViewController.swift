//
//  ViewController.swift
//  HomeLibrary
//
//  Created by Michal Olejniczak on 25/07/2020.
//  Copyright © 2020 Michal Olejniczak. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UISearchBarDelegate, AVCaptureMetadataOutputObjectsDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchLabel: UISearchBar!
    @IBOutlet weak var scannerButton: UIButton!
    @IBOutlet weak var myBooksButton: UIButton!
    @IBOutlet weak var wwwButton: UIButton!
    @IBOutlet weak var scannerFrame: UIImageView!
    
    let API_Key = "AIzaSyBtEUfIv8lFx4KDcaDnK99EIPSPVIiJIBA"
    let userDefaults = UserDefaults()

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var searchingResults: [Book] = []
    var myBooks: [Book] = []
    var myLibrary = true
    var selectedIndex = -1
    var isCollapce = false
    var indexPathTmp: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchLabel.showsScopeBar = true
        searchLabel.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        startingGraphicSettings()
        
        loadDatas()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func found(code: String) {
        print(code)
        searchLabel.text?.append(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func scannerButtonAction(_ sender: Any) {
        
        captureSession = AVCaptureSession()

    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
          let videoInput: AVCaptureDeviceInput

          do {
              videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
          } catch {
              return
          }

          if (captureSession.canAddInput(videoInput)) {
              captureSession.addInput(videoInput)
          } else {
              failed()
              return
          }

          let metadataOutput = AVCaptureMetadataOutput()

          if (captureSession.canAddOutput(metadataOutput)) {
              captureSession.addOutput(metadataOutput)

              metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
              metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
          } else {
              failed()
              return
          }

          previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
          previewLayer.frame = view.layer.bounds
          previewLayer.videoGravity = .resizeAspectFill
          view.layer.addSublayer(previewLayer)

//        self.view.bringSubviewToFront(scannerFrame)
        self.view.layer.
            
          captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
            searchLabel.text?.removeAll()
            searchLabel.text?.append(stringValue)
            searchBarSearchButtonClicked (searchLabel)
            
//            captureSession.stopRunning()
        }
//        self.dismiss(animated: true)
        
        scannerFrame.isHidden = true
        view.layer.sublayers?.removeLast()
        


//        let layer = view.layer.sublayers?.last
//        layer.dismiss(animated: true)
//        scannerButtonAction(().self)

    }
    
    
    
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchingResults.removeAll()
        
        if(myLibrary == true){
            searchFromMyBooks()
        }else{
            searchFromWWW()
        }
        searchLabel.text = ""
        self.searchLabel.endEditing(true)

    }
    
    func searchFromMyBooks(){
        if(searchLabel.text == "" || searchLabel.text == nil){
            self.searchingResults = myBooks
        }
        else{
            myBooks.forEach { item in
                if searchLabel.text == item.title{
                    self.searchingResults.append(item)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func saveDatas(book: Book, remove: Bool){
        var storedItems: [BooksStruct] = []
        
        if let storedObjItem = UserDefaults.standard.object(forKey: "books"){
            do {
                storedItems = try JSONDecoder().decode([BooksStruct].self, from: storedObjItem as! Data)
                print("Retrieved items: \(storedItems)")
            } catch let err {
                print(err)
            }
        }
        if(remove){
            storedItems.remove(at: selectedIndex)
        }else{
            storedItems.append(BooksStruct.init(image: book.image!, title: book.title!, authors: book.authors!, description: book.description!))
        }
        if let encoded = try? JSONEncoder().encode(storedItems) {
            UserDefaults.standard.set(encoded, forKey: "books")
        }
        isCollapce = false
    }
    
    func loadDatas(){
        if let storedObjItem = UserDefaults.standard.object(forKey: "books"){
            do {
                let storedItems = try JSONDecoder().decode([BooksStruct].self, from: storedObjItem as! Data)
                
                storedItems.forEach{book in
                    searchingResults.append(Book.init(image: book.image!, title: book.title!, authors: book.authors!, description: book.description!))
                }
                myBooks = searchingResults
                print("Retrieved items: \(storedItems)")
            } catch let err {
                print(err)
            }
        }
    }
    
    func startingGraphicSettings(){
        myBooksButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        wwwButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        menuBackground.layer.borderWidth = 0.19
//        menuBackground.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        myBooksButton.setTitleColor(.black, for: .normal)
        myBooksButton.layer.cornerRadius = 10
        wwwButton.layer.cornerRadius = 10
        myBooksButton.setTitleColor(.black, for: .normal)
        wwwButton.setTitleColor(.white, for: .normal)
//        scannerFrame.isHidden = true
    }
    
    @IBAction func myBooksAction(_ sender: Any) {
        searchLabel.text = ""
        selectedIndex = -1
        myBooksButton.setTitleColor(.black, for: .normal)
        wwwButton.setTitleColor(.white, for: .normal)
        
        if(myLibrary != true){
            searchingResults.removeAll()
        }
        searchingResults = myBooks
        myLibrary = true
        self.tableView.reloadData()
    }
    
    @IBAction func wwwAction(_ sender: Any) {
        searchLabel.text = ""
        selectedIndex = -1
        searchingResults.removeAll()
        self.tableView.reloadData()
        myBooksButton.setTitleColor(.white, for: .normal)
        wwwButton.setTitleColor(.black, for: .normal)
        myLibrary = false
    }
    
    
    func searchFromWWW(){
        var isbn = ""
        if searchLabel != nil
        {
            isbn = searchLabel.text!
        }
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q="+isbn+"&key="+API_Key)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do{
                let results = try decoder.decode(Results.self, from: data)
                results.items?.forEach { item in
                    if let volumeInfo = item.volumeInfo{
                        if let title = volumeInfo.title{
                            if let image = volumeInfo.imageLinks?.smallThumbnail{
                                if let authors = volumeInfo.authors{
                                    if let description = volumeInfo.description{
                                        self.searchingResults.append(Book(image: image, title: title, authors: authors, description: description))
                                    }
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                }
            }catch{
                print("parsing error")
            }
        }
        task.resume()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
//
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        if let first = metadataObjects.first{
//            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else{
//                return
//            }
//            guard let stringValue = readableObject.stringValue else{
//                return
//            }
//                print(stringValue)
//        }else{
//            print("error barcode")
//        }
//    }
    
    
//    func captureOut(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        if metadataObjects != nil && metadataObjects.count != nil{
//            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
//            {
//                if object.type == AVMetadataObject.ObjectType.qr{
//                    let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
//                    alert.addAction(UIAlertAction(title: "Copy", style: .default, handler:{ (nil) in
//                        UIPasteboard.general.string = object.stringValue
//                    }))
//                    present(alert, animated: true, completion: nil)
//
//                }
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchingResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book = searchingResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as! BookCell
        
        cell.bookTitleView.text = book.title
        if let address = book.image{
            cell.bookImageView.load(url: URL(string: address)!)
        }
        if let authors = book.authors{
            var text = ""
            authors.forEach{ author in
                text = author+" "
            }
            cell.bookAuthorView.text = text
        }
        if let description = book.description{
            cell.bookDecription.text = description
        }
        cell.delegate = self
        cell.bookItem = book
        cell.addBookButton.layer.cornerRadius = 10
        cell.removeBookButton.layer.cornerRadius = 10
        
        if(myLibrary == true){
            cell.addBookButton.isHidden = true
            cell.removeBookButton.isHidden = false
        }else{
            cell.addBookButton.isHidden = false
            cell.removeBookButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == indexPath.row && isCollapce == true{
            return 250
        }else{
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedIndex == indexPath.row{
            if self.isCollapce == false{
                self.isCollapce = true
            }else{
                self.isCollapce = false
            }
        }else{
            self.isCollapce = true
        }
        self.selectedIndex = indexPath.row
        self.indexPathTmp = indexPath
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension ViewController: BookCellDelegate{
    func didTapAddBook(book: Book) {
        print(book.title!)
        if(myBooks.contains(book)){
            bookInMyLibrary(book: book)
        }else{
            bookAddConfirm(book: book)
        }
    }
    
    func didTapRemoveBook(book: Book) {
        bookRemoveConfirm(book: book)
    }
    
    func bookAddConfirm(book: Book){
        let refreshAlert = UIAlertController(title: "Please confirm", message: "Add this book to my library?", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Book added")
            self.myBooks.append(book)
            self.saveDatas(book: book, remove: false)
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Book wasnt added")
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func bookRemoveConfirm(book: Book){
        let refreshAlert = UIAlertController(title: "Please confirm", message: "Remove this book from my library?", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.myBooks.remove(at: self.selectedIndex)
            self.searchingResults.remove(at: self.selectedIndex)
            self.saveDatas(book: book, remove: true)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Book wasn't removed")
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func bookInMyLibrary(book: Book){
        let refreshAlert = UIAlertController(title: "The book is already added", message: "You cannot add this book again", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Book wasnt added")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
