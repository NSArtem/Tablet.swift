![Tablet.swift](https://raw.githubusercontent.com/maxsokolov/tablet/assets/logo.png)

# Tablet.swift

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://developer.apple.com/ios/)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-0.5.0-blue.svg)](https://cocoapods.org/pods/tablet)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Tablet is a lightweight, generic library for managing `UITableView` data sources and delegate actions in Swift. It helps build table views with multiple cell types and sections without filling view controllers with repetitive `switch` and `if` statements.

> **Compatibility note:** This repository documents the original Swift 2.2 API and targets iOS 8.0+. It is legacy Swift code; modern Swift and Xcode versions may require a port.

## Features

- Type-safe cells using generics
- Map models or view models to table-view cells
- Self-sizing cells with Auto Layout and multiline labels
- Chainable cell actions, including selection and display callbacks
- Support for cells created in code, XIBs, or storyboards
- Automatic cell class and XIB registration
- No need to subclass the library's builders
- Extensible action handling
- Tests

For example, a row builder can be created from a collection of values:

```swift
let builder = TableRowBuilder<String, MyTableViewCell>(
    items: ["1", "2", "3", "4", "5"]
)
```

Tablet relies on [self-sizing table-view cells](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithSelf-SizingTableViewCells.html) and cell reuse. Create your cells, configure their Auto Layout constraints, and let the table view size and reuse them.

## Requirements

- iOS 8.0 or later
- Xcode 7.0 or later
- Swift 2.2

## Installation

### CocoaPods

Add Tablet to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourApp' do
  pod 'Tablet'
end
```

Then install the dependency:

```sh
pod install
```

Open the generated `.xcworkspace` and import the framework where needed:

```swift
import Tablet
```

## Usage

### Type-safe configurable cells

To keep configuration logic inside a custom cell, conform to `ConfigurableCell`. The cell's `T` type represents the model or view model it receives.

```swift
import Tablet

class MyTableViewCell: UITableViewCell, ConfigurableCell {
    typealias T = User

    // Optional when the reusable identifier matches the class name.
    static func reusableIdentifier() -> String {
        return "reusable_id"
    }

    static func estimatedHeight() -> Float {
        return 255
    }

    func configure(item: T) {
        textLabel?.text = item.username
        detailTextLabel?.text = item.isActive ? "Active" : "Inactive"
    }
}
```

Build the rows and add them to a table director:

```swift
import Tablet

let rowBuilder = TableRowBuilder<User, MyTableViewCell>()
rowBuilder += users

let tableDirector = TableDirector(tableView: tableView)
tableDirector += TableSectionBuilder(rows: [rowBuilder])
```

### A basic table view

For a standard `UITableViewCell`, use `TableBaseRowBuilder` and configure the cell with an action:

```swift
import Tablet

let rowBuilder = TableBaseRowBuilder<User, UITableViewCell>(
    items: [user1, user2, user3],
    id: "reusable_id"
)
.action(.configure) { data in
    data.cell?.textLabel?.text = data.item.username
    data.cell?.detailTextLabel?.text = data.item.isActive ? "Active" : "Inactive"
}

let sectionBuilder = TableSectionBuilder(
    headerTitle: "Users",
    footerTitle: nil,
    rows: [rowBuilder]
)

let tableDirector = TableDirector(tableView: tableView)
tableDirector += sectionBuilder
```

### Cell actions

Chain handlers to respond to supported table and cell events:

```swift
import Tablet

let rowBuilder = TableRowBuilder<User, MyTableViewCell>(
    items: [user1, user2, user3],
    id: "reusable_id"
)
.action(.configure) { data in
    // Configure the cell.
}
.action(.click) { data in
    // Handle a row tap.
}
.valueAction(.shouldHighlight) { data in
    return false
}
```

The library also supports custom actions. Invoke an `Action` from a control inside your cell:

```swift
import Tablet

struct MyCellActions {
    static let ButtonClicked = "ButtonClicked"
}

class MyTableViewCell: UITableViewCell {
    @IBAction func buttonClicked(sender: UIButton) {
        Action(
            key: MyCellActions.ButtonClicked,
            sender: self,
            userInfo: nil
        ).invoke()
    }
}
```

Register a handler for that action on the row builder:

```swift
let rowBuilder = TableRowBuilder<User, MyTableViewCell>(items: users)
    .action(MyCellActions.ButtonClicked) { data in
        // Handle the button action.
    }
```

Other events, such as `.willDisplay`, can be handled in the same way when supported by the library.

## Extending Tablet

If you need a delegate callback that Tablet does not expose directly, you can extend `TableDirector` and forward it as a custom action. For example, to handle `tableView(_:didEndDisplaying:forRowAt:)`:

```swift
import Tablet

struct MyTableActions {
    static let DidEndDisplayingCell = "DidEndDisplayingCell"
}

extension TableDirector {
    public func tableView(
        tableView: UITableView,
        didEndDisplayingCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath
    ) {
        invoke(
            action: .custom(MyTableActions.DidEndDisplayingCell),
            cell: cell,
            indexPath: indexPath
        )
    }
}
```

Then handle the custom action in the row builder:

```swift
let rowBuilder = TableRowBuilder<User, MyTableViewCell>(items: users)
    .action(MyTableActions.DidEndDisplayingCell) { data in
        // Handle the cell leaving the screen.
    }
```

The same pattern can be used for custom callbacks that return a value, where the API supports it.

## License

Tablet is available under the [MIT License](LICENSE).
