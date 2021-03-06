![Alamofire: Elegant Networking in Swift](https://raw.githubusercontent.com/maxsokolov/tablet/assets/logo.png)

#Tablet.swift

<p align="left">
<a href="https://travis-ci.org/maxsokolov/Tablet.swift"><img src="https://api.travis-ci.org/maxsokolov/Tablet.swift.svg" alt="Build Status" /></a>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift_2.2-compatible-4BC51D.svg?style=flat" alt="Swift 2.2 compatible" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://cocoapods.org/pods/tablet"><img src="https://img.shields.io/badge/pod-0.5.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/maxsokolov/tablet/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

Tablet is a super lightweight yet powerful generic library that handles a complexity of UITableView's datasource and delegate methods in a Swift environment. Tablet's goal is to provide an easiest way to create complex table views. With Tablet you don't have to write a messy code of `switch` or `if` statements when you deal with bunch of different cells in different sections. 

## Features

- [x] Type-safe cells based on generics
- [x] The easiest way to map your models or view models to cells
- [x] Correctly handles autolayout cells with multiline labels
- [x] Chainable cell actions (select/deselect etc.)
- [x] Support cells created from code, xib, or storyboard
- [x] Automatic xib/classes registration
- [x] No need to subclass
- [x] Extensibility
- [x] Tests

That's almost all you need to build a bunch of cells in a section:
```swift
let builder = TableRowBuilder<String, MyTableViewCell>(items: ["1", "2", "3", "4", "5"])
```
Tablet relies on <a href="https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithSelf-SizingTableViewCells.html" target="_blank">self-sizing table view cells</a>, respects cells reusability feature and also built with performace in mind. You don't have to worry about anything, just create your cells, setup autolayout constraints and be happy. See the Usage section to learn more.

## Requirements

- iOS 8.0+
- Xcode 7.0+
- Swift 2.2

## Installation

### CocoaPods
To integrate Tablet into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Tablet'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Type-safe configurable cells

Let's say you want to put your cell configuration logic into cell itself. Say you want to pass your view model (or even model) to your cell.
You could easily do this using the `TableRowBuilder`. Your cell should conforms to `ConfigurableCell` protocol as you may see in example below:

```swift
import Tablet

class MyTableViewCell : UITableViewCell, ConfigurableCell {

	typealias T = User

	// this method is not required to be implemented if your cell's id equals to class name
	static func reusableIdentifier() -> String {
		return "reusable_id"
	}

	static func estimatedHeight() -> Float {
        return 255
    }

	func configure(item: T) { // item is user here

		textLabel?.text = item.username
		detailTextLabel?.text = item.isActive ? "Active" : "Inactive"
	}
}
```
Once you've implemented the protocol, simply use the `TableRowBuilder` to build cells:

```swift
import Tablet

let rowBuilder = TableRowBuilder<User, MyTableViewCell>()
rowBuilder += users

director = TableDirector(tableView: tableView)
tableDirector += TableSectionBuilder(rows: [rowBuilder])
```

### Very basic table view

You may want to setup a very basic table view, without any custom cells. In that case simply use the `TableBaseRowBuilder`.

```swift
import Tablet

let rowBuilder = TableBaseRowBuilder<User, UITableViewCell>(items: [user1, user2, user3], id: "reusable_id")
	.action(.configure) { (data) in

		data.cell?.textLabel?.text = data.item.username
		data.cell?.detailTextLabel?.text = data.item.isActive ? "Active" : "Inactive"
	}

let sectionBuilder = TableSectionBuilder(headerTitle: "Users", footerTitle: nil, rows: [rowBuilder])

director = TableDirector(tableView: tableView)
director += sectionBuilder
```

### Cell actions

Tablet provides a chaining approach to handle actions from your cells:

```swift
import Tablet

let rowBuilder = TableRowBuilder<User, MyTableViewCell>(items: [user1, user2, user3], id: "reusable_id")
	.action(.configure) { (data) in

	}
	.action(.click) { (data) in

	}
	.valueAction(.shouldHighlight) { (data) in

		return false
	}
```

### Custom cell actions
```swift
import Tablet

struct MyCellActions {
	static let ButtonClicked = "ButtonClicked"
}

class MyTableViewCell : UITableViewCell {

	@IBAction func buttonClicked(sender: UIButton) {

		Action(key: MyCellActions.ButtonClicked, sender: self, userInfo: nil).invoke()
	}
}
```
And receive this actions with your row builder:
```swift
import Tablet

let rowBuilder = TableRowBuilder<User, MyTableViewCell>(items: users)
	.action(.click) { (data) in
		
	}
	.action(.willDisplay) { (data) in
		
	}
	.action(MyCellActions.ButtonClicked) { (data) in
		
	}
```

## Extensibility

If you find that Tablet is not provide an action you need, for example you need UITableViewDelegate's `didEndDisplayingCell` method and it's not out of the box,
simply provide an extension for `TableDirector`:
```swift
import Tablet

struct MyTableActions {
	static let DidEndDisplayingCell = "DidEndDisplayingCell"
}

extension TableDirector {

	public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

		invoke(action: .custom(MyTableActions.DidEndDisplayingCell), cell: cell, indexPath: indexPath)
	}
}
```
Catch your action with row builder:
```swift
let rowBuilder = TableRowBuilder<User, MyTableViewCell>(items: users)
	.action(MyTableActions.DidEndDisplayingCell) { (data) -> Void in

	}
```
You could also invoke an action that returns a value.

## License

Tablet is available under the MIT license. See LICENSE for details.