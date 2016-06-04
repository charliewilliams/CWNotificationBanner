# CWNotificationBanner
You want a nice iOS Push Notification UI to display popover banners? Here it is.

- Supports queueing messages: new messages are displayed immediately, then NotificationBanner automatically walks backward as the messages expire or are dismissed.
- Supports cancelling individual message or all of them at once.

```swift

import CWNotificationBanner

override func viewDidLoad() {
    super.viewDidLoad()

    // MessageAction to register blocks by key to call when tapping a message banner
    let tapAction:MessageAction = { Void in

    let alert = UIAlertController(title: "Tapped the alert banner", message: "Popups are a terrible user experience, eh?", preferredStyle: .Alert)
    self.showViewController(alert, sender: nil)
    }

    Message.registerAction(tapAction, forKey: "tapAction")
}

override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let message = Message(text: "Hello there")

    NotificationBanner.showMessage(message)
}

override func viewWillDisappear() {
    super.viewWillDisappear()

    NotificationBanner.cancelMessage(message, animated: false)
    NotificationBanner.cancelAllMessages()
}

```

CWNotificationBanner is a Swift 2.0 re-interpretation of AGPushNote (https://github.com/avielg/AGPushNote).

Future improvements:
- Implement actions for when you tap a message (This is hindered somewhat by the rigorous #selector checks in Swift)
- Implement customizations for the banner display


[![CI Status](http://img.shields.io/travis/charliesilliams/CWNotificationBanner.svg?style=flat)](https://travis-ci.org/charliewilliams/CWNotificationBanner)
[![Version](https://img.shields.io/cocoapods/v/CWNotificationBanner.svg?style=flat)](http://cocoapods.org/pods/CWNotificationBanner)
[![License](https://img.shields.io/cocoapods/l/CWNotificationBanner.svg?style=flat)](http://cocoapods.org/pods/CWNotificationBanner)
[![Platform](https://img.shields.io/cocoapods/p/CWNotificationBanner.svg?style=flat)](http://cocoapods.org/pods/CWNotificationBanner)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

SwiftyTimer

## Installation

CWNotificationBanner is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CWNotificationBanner"
```

## Author

Charlie Williams, c@charliewilliams.org / @buildsucceeded

## License

CWNotificationBanner is available under the MIT license. See the LICENSE file for more info.
