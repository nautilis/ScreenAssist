import Figlet
import ArgumentParser
import AppKit
import Cocoa
import ApplicationServices


func readFile(atPath path: String) -> String? {
    do {
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        return contents
    } catch {
        print("Error reading file: \(error)")
        return nil
    }
}


func openApp(withBundleIdentifier bundleIdentifier: String) {
    if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
        do {
            try NSWorkspace.shared.launchApplication(at: appURL, options: .default, configuration: [:])
            print("App opened successfully\(appURL)" )
        } catch {
            print("Failed to open app: \(error)")
        }
    } else {
        print("Invalid bundle identifier: \(bundleIdentifier)")
    }
}

func openDefaultApp() {
    let apps = ["org.hammerspoon.Hammerspoon", "com.googlecode.iterm2","com.alibaba.DingTalkMac", "com.jetbrains.goland", "com.tencent.xinWeChat","com.postmanlabs.mac", "com.jetbrains.datagrip", "com.google.Chrome", "com.clipy-app.Clipy"]
    for app in apps {
        openApp(withBundleIdentifier: app)
    }
}

func openSubScreenApp() {
    let apps = ["com.postmanlabs.mac", "com.jetbrains.datagrip", "com.google.Chrome", "md.obsidian"]
    for app in apps {
        openApp(withBundleIdentifier: app)
    }
    sleep(5)
    moveAppWindow(name: "Postman", x: -1512, y:38, w:1512, h:883)
    moveAppWindow(name: "DataGrip", x: -1512, y:38, w:1512, h:883)
    moveAppWindow(name: "Google Chrome", x: -1512, y:38, w:1512, h:883)
    moveAppWindow(name: "Obsidian", x: -1512, y:38, w:1512, h:883)
}

func openMainScreenApp() {
    let apps = ["com.jetbrains.goland", "com.alibaba.DingTalkMac", "com.googlecode.iterm2"]
    for app in apps {
        openApp(withBundleIdentifier: app)
    }
    sleep(5)
    moveAppWindow(name: "GoLand", x: 0, y:25, w:1706, h:1415)
    moveAppWindow(name: "钉钉", x: 1706, y:25, w:975, h:707)
    moveAppWindow(name: "iTerm2", x: 1706, y:732, w:853, h:707)
}

func getAllRunningAppNames() {
    let runningApps = NSWorkspace.shared.runningApplications
    for app in runningApps {
        if let bundleIdentifier = app.bundleIdentifier {
            print(bundleIdentifier)
        }
        if let appName = app.localizedName{
            print(appName)
        }
    }
}

func getScreenAllWindowPosition() {
    let type = CGWindowListOption.optionOnScreenOnly
    let windowList = CGWindowListCopyWindowInfo(type, kCGNullWindowID) as NSArray? as? [[String: AnyObject]]
    
    print("windowList size is \(windowList!.count)")
    
    for entry  in windowList!
    {
        print("entry=>\(entry)")
    }
}


func moveAppWindow(name: String, x: Int, y: Int, w: Int, h: Int) {
    let type = CGWindowListOption.optionOnScreenOnly
    let windowList = CGWindowListCopyWindowInfo(type, kCGNullWindowID) as NSArray? as? [[String: AnyObject]]
    
    print("windowList size is \(windowList!.count)")
    
    for entry  in windowList!{
        //        print("entry=>\(entry)")
        let owner = entry[kCGWindowOwnerName as String] as! String
        //      var bounds = entry[kCGWindowBounds as String] as? [String: Int]
        let pid = entry[kCGWindowOwnerPID as String] as? Int32
        
        if owner == name{
            let appRef = AXUIElementCreateApplication(pid!);  //TopLevel Accessability Object of PID
            
            var value: AnyObject?
            let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
            _ = result
            
            if let windowList = value as? [AXUIElement] {
                print ("windowList #\(windowList)")
                if windowList.first != nil{
                    print("windowList.first => \(windowList.first!)")
                    var position : CFTypeRef
                    var size : CFTypeRef
                    var  newPoint = CGPoint(x: x, y: y)
                    var newSize = CGSize(width: w, height: h)
                    
                    position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                    AXUIElementSetAttributeValue(windowList.first!, kAXPositionAttribute as CFString, position);
                    
                    size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
                    AXUIElementSetAttributeValue(windowList.first!, kAXSizeAttribute as CFString, size);
                }
            }
        }
    }
}


func closeAllRunningApps() {
    let runningApps = NSWorkspace.shared.runningApplications
    let passIdentifiers = ["com.clipy-app.Clipy","org.hammerspoon.Hammerspoon"]
    for app in runningApps {
        if app.bundleIdentifier != Bundle.main.bundleIdentifier {
            if let identifier = app.bundleIdentifier {
                if identifier.contains("com.apple") && identifier != "com.apple.finder" && identifier != "com.apple.Terminal" && !identifier.contains("com.apple.iWork") && identifier != "com.apple.Preview" && identifier != "com.apple.dt.Xcode" {
                    continue
                }
                if passIdentifiers.contains(identifier) {
                    continue
                }
            }
            app.terminate()
        }
    }
}

@main
struct FigletTool: ParsableCommand {
        @Option(help: "Specify the action")
        public var action: String
    
    public func run() throws {
        Figlet.say("Screen Assistant")
        if action != "" {
            print("now is go to exec \(action)")
        } else {
            print("action is empty")
        }
        if action == "up_for_work" {
            openMainScreenApp()
            openSubScreenApp()
        } else if action == "close_all_app" {
            closeAllRunningApps()
        } else if action == "all_running_apps_name" {
            getAllRunningAppNames()
        }
    }
}
