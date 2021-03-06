import Foundation
import WordPressShared.WPTableViewCell

public class CommentsTableViewCell : WPTableViewCell
{
    // MARK: - Public Properties
    public var author : String? {
        didSet {
            refreshDetailsLabel()
        }
    }
    public var postTitle : String? {
        didSet {
            refreshDetailsLabel()
        }
    }
    public var content : String? {
        didSet {
            refreshDetailsLabel()
        }
    }
    public var timestamp : String? {
        didSet {
            refreshTimestampLabel()
        }
    }
    public var approved : Bool = false {
        didSet {
            refreshTimestampLabel()
            refreshDetailsLabel()
            refreshBackground()
            refreshImages()
        }
    }



    // MARK: - Public Methods
    public func downloadGravatarWithURL(url: NSURL?) {
        if url == gravatarURL {
            return
        }

        let gravatar = url.flatMap { Gravatar($0) }
        gravatarImageView.downloadGravatar(gravatar, placeholder: placeholderImage, animate: true)

        gravatarURL = url
    }

    public func downloadGravatarWithGravatarEmail(email: String?) {
        guard let unwrappedEmail = email else {
            gravatarImageView.image = placeholderImage
            return
        }

        gravatarImageView.downloadGravatarWithEmail(unwrappedEmail, placeholderImage: placeholderImage)
    }


    // MARK: - Overwritten Methods
    public override func awakeFromNib() {
        super.awakeFromNib()

        assert(layoutView != nil)
        assert(gravatarImageView != nil)
        assert(detailsLabel != nil)
        assert(timestampImageView != nil)
        assert(timestampLabel != nil)
    }

    public override func setSelected(selected: Bool, animated: Bool) {
        // Note: this is required, since the cell unhighlight mechanism will reset the new background color
        super.setSelected(selected, animated: animated)
        refreshBackground()
    }

    public override func setHighlighted(highlighted: Bool, animated: Bool) {
        // Note: this is required, since the cell unhighlight mechanism will reset the new background color
        super.setHighlighted(highlighted, animated: animated)
        refreshBackground()
    }



    // MARK: - Private Helpers
    private func refreshDetailsLabel() {
        detailsLabel.attributedText = attributedDetailsText(approved)
        layoutIfNeeded()
    }

    private func refreshTimestampLabel() {
        let style               = Style.timestampStyle(isApproved: approved)
        let unwrappedTimestamp  = timestamp ?? String()
        timestampLabel?.attributedText = NSAttributedString(string: unwrappedTimestamp, attributes: style)
    }

    private func refreshBackground() {
        backgroundColor = Style.backgroundColor(isApproved: approved)
    }

    private func refreshImages() {
        timestampImageView.image = Style.timestampImage(isApproved: approved)
        if !approved {
            timestampImageView.tintColor = WPStyleGuide.alertYellowDark()
        }
    }



    // MARK: - Details Helpers
    private func attributedDetailsText(isApproved: Bool) -> NSAttributedString {
        // Unwrap
        let unwrappedAuthor     = author ?? String()
        let unwrappedTitle      = postTitle ?? NSLocalizedString("(No Title)", comment: "Empty Post Title")
        let unwrappedContent    = content ?? String()

        // Styles
        let detailsBoldStyle    = Style.detailsBoldStyle(isApproved: isApproved)
        let detailsItalicsStyle = Style.detailsItalicsStyle(isApproved: isApproved)
        let detailsRegularStyle = Style.detailsRegularStyle(isApproved: isApproved)
        let regularRedStyle     = Style.detailsRegularRedStyle(isApproved: isApproved)

        // Localize the format
        var details = NSLocalizedString("%1$@ on %2$@: %3$@", comment: "'AUTHOR on POST TITLE: COMMENT' in a comment list")
        if unwrappedContent.isEmpty {
            details = NSLocalizedString("%1$@ on %2$@", comment: "'AUTHOR on POST TITLE' in a comment list")
        }

        // Arrange the Replacement Map
        let replacementMap  = [
            "%1$@" : NSAttributedString(string: unwrappedAuthor,    attributes: detailsBoldStyle),
            "%2$@" : NSAttributedString(string: unwrappedTitle,     attributes: detailsItalicsStyle),
            "%3$@" : NSAttributedString(string: unwrappedContent,   attributes: detailsRegularStyle)
        ]

        // Replace Author + Title + Content
        let attributedDetails = NSMutableAttributedString(string: details, attributes: regularRedStyle)

        for (key, attributedString) in replacementMap {
            let range = (attributedDetails.string as NSString).rangeOfString(key)
            if range.location == NSNotFound {
                continue
            }

            attributedDetails.replaceCharactersInRange(range, withAttributedString: attributedString)
        }

        return attributedDetails
    }



    // MARK: - Aliases
    typealias Style = WPStyleGuide.Comments

    // MARK: - Private Properties
    private var gravatarURL : NSURL?

    // MARK: - Private Calculated Properties
    private var placeholderImage : UIImage {
        return Style.gravatarPlaceholderImage(isApproved: approved)
    }

    // MARK: - IBOutlets
    @IBOutlet private var layoutView            : UIView!
    @IBOutlet private var gravatarImageView     : CircularImageView!
    @IBOutlet private var detailsLabel          : UILabel!
    @IBOutlet private var timestampImageView    : UIImageView!
    @IBOutlet private var timestampLabel        : UILabel!
}
