# LUSH tvOS Player App

The tvOS client for LUSH's Player app.

## Running

Please make sure you have checked out and pulled all submodules before running

1. Make sure that you have the correct Brightcove 'policy ids' in the app's Info.plist: 
        ```
        <key>BrightcoveLivePolicyID</key>
    <string>live_policy_id_here</string>
    <key>BrightcoveOnDemandPolicyID</key>
    <string>on_demand_policy_id_here</string>
        ```

2. Run the app using XCode

## Project guidelines

### Project structure
- `Lush Player/` - The root group for all app logic and assets
    - `AppDelegate.swift` - The single point of entry for the App
    - `Helpers/` - Helper classes for performing common and complicated tasks in the codebase
    - `Models/` - Model classes for all LUSH API objects
    - `Controllers/` - Controllers for all API calls, and any other logic which requires controller logic
    - `Views/` - Any re-usable `UIView` subclasses used in the codebase
    - `View Controllers/` - All view controllers used in the codebase
    - `Main.storyboard` - The storyboard for the app's UI
    - `Assets.xcassets` - All image assets for the app
    - `Info.plist` - The app's info.plist file

### Documenting code

Please make sure to document all public functions, variables and classes fully and comment code where it is necessary. We are using the standard swift Markdown [documentation style](http://nshipster.com/swift-documentation/) for documenting the code, which can be partially auto-generated using the keyboard shordcut `cmd+\` when the cursor is on a function name or variable name.