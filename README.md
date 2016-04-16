# CWNotificationBanner
You want a nice iOS Push Notification UI to display popover banners? Here it is.

Swift 2.0 re-interpretation of AGPushNote (https://github.com/avielg/AGPushNote).

- Supports queueing messages: new messages are displayed immediately, then NotificationBanner automatically walks backward as the messages expire or are dismissed.
- Supports cancelling individual message or all of them at once.

Usage:

<code>
let message = Message("You have an alert")
NotificationBanner.showMessage(message)

//

let message = Message("You have an alert", displayDuration: 2)
NotificationBanner.showMessage(message)

//

NotificationBanner.cancelMessage(message, animated: false)
NotificationBanner.cancelAllMessages()

</code>

Future improvements:
- Implement actions for when you tap a message (This is hindered somewhat by the rigorous #selector checks in Swift)
- Implement customizations for the banner display

License:
The MIT License (MIT)
Copyright (c) 2016 Charlie Williams

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.