//
//  BookCell.swift
//  HomeLibrary
//
//  Created by Michal Olejniczak on 25/07/2020.
//  Copyright © 2020 Michal Olejniczak. All rights reserved.
//

import UIKit

protocol  BookCellDelegate {
    func didTapAddBook(book: Book)
    func didTapRemoveBook(book: Book)
}
class BookCell: UITableViewCell {
    
    var bookItem: Book!
    var delegate: BookCellDelegate?

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitleView: UILabel!
    @IBOutlet weak var bookAuthorView: UILabel!
    @IBOutlet weak var bookDecription: UITextView!
    @IBOutlet weak var addBookButton: UIButton!
    @IBOutlet weak var removeBookButton: UIButton!
    
    @IBAction func addBook(_ sender: Any) {
        delegate?.didTapAddBook(book: bookItem!)
    }
    
    @IBAction func removeBook(_ sender: Any) {
        delegate?.didTapRemoveBook(book: bookItem!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor = UIColor.init(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    

}
