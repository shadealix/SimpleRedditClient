//
//  ListingTableViewCell.swift
//  TopRedditClient
//
//  Created by Alix on 12/8/20.
//

import UIKit

class ListingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var entryDateLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if let oldValue = oldValue {
                thumbnailImageView.removeConstraint(oldValue)
            }
            if let aspectConstraint = aspectConstraint {
                thumbnailImageView.addConstraint(aspectConstraint)
            }
        }
    }
    
    var item: ChildData! {
        didSet {
            titleLabel.text = item.title
            authorLabel.text = item.author
            entryDateLabel.text = self.hoursAgoFrom(item.created)
            commentsLabel.text = self.commentsCountString(item.commentsCount)
            if let h = item.thumbnailHeight, let w = item.thumbnailWidth, let thumbnailImageView = thumbnailImageView {

                let aspect = w / h
                
                let constraint = NSLayoutConstraint(item: thumbnailImageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: thumbnailImageView, attribute: NSLayoutConstraint.Attribute.height, multiplier: CGFloat(aspect), constant: 0.0)
                constraint.priority = UILayoutPriority(rawValue: 999)
                    aspectConstraint = constraint
            }
        }
    }
    
    private func commentsCountString(_ count: Int) -> String {
        if count == 0 {
            return "no comments yet"
        } else if count == 1 {
            return "1 comment"
        } else {
            return "\(count) comments"
        }
    }
    
    private func hoursAgoFrom(_ date: Date, calendar: Calendar = .current) -> String {
        let hoursCount = calendar.component(.hour, from: date)
        if hoursCount == 0 {
            return "less then hour ago"
        } else if hoursCount < 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd.MM.yyyy"
            return dateFormatter.string(from: date)
        } else {
            return "\(hoursCount) hours ago"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        aspectConstraint = nil
        thumbnailImageView.image = nil
    }
}
