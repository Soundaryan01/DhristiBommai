import SwiftUI
import AppKit

enum Charm: String, CaseIterable {
    case drishti = "Drishti Bommai"
    case blueEye = "Blue Eye"
    case donkey = "Donkey"
    case blackDrishti = "Black Drishti Bommai"
    case nimbu = "Nimbu Mirchi"
    case mirchi = "Red Mirchi"
    case clover = "Clover Leaf"

    var imageName: String {
        switch self {
        case .drishti:
            return "DrishtiFace"

        case .blueEye:
            return "BlueEye"
            
        case .donkey:
            return "donkey"
            
        case .blackDrishti:
            return "blackDrishtiFace"
            
        case .nimbu:
            return "Nimbu"
        
        case .mirchi:
            return "Mirchi"
        
        case .clover:
            return "Clover"
            
        }
        
    }
}

@main
struct DhristiBommaiApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var bommaiPanel: NSPanel?

    private var selectedCharm: Charm = .drishti
    private var isCharmVisible = true

    func applicationDidFinishLaunching(
        _ notification: Notification
    ) {

        setupMenuBarIcon()
        createBommaiPanel()

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            self?.positionBommai()
        }
    }

    // MARK: - Menu Bar
    
    private func updateCharmView() {

        guard let panel = bommaiPanel else {
            return
        }

        let contentView = ContentView(
            charm: selectedCharm
        )

        let hostingView =
            NSHostingView(
                rootView: contentView
            )

        hostingView.frame =
            panel.contentView?.bounds ?? .zero

        hostingView.autoresizingMask = [
            .width,
            .height
        ]

        panel.contentView = hostingView
    }
    
    @objc
    private func selectCharm(
        _ sender: NSMenuItem
    ) {

        guard
            let charmName =
                sender.representedObject as? String,
            let charm =
                Charm.allCases.first(
                    where: { $0.rawValue == charmName }
                )
        else {
            return
        }

        selectedCharm = charm

        updateCharmView()

        // Mark the selected menu item.
        for item in sender.menu?.items ?? [] {
            item.state = .off
        }

        sender.state = .on
    }
    
    
    private func setupMenu() {

        let menu = NSMenu()

        // Show / Hide
        let visibilityItem = NSMenuItem(
            title: "Hide Charm",
            action: #selector(toggleCharm),
            keyEquivalent: ""
        )

        visibilityItem.target = self

        menu.addItem(visibilityItem)

        menu.addItem(
            NSMenuItem.separator()
        )

        // Charm submenu
        let charmMenuItem = NSMenuItem(
            title: "Select Charm",
            action: nil,
            keyEquivalent: ""
        )

        let charmMenu = NSMenu()

        for charm in Charm.allCases {

            let item = NSMenuItem(
                title: charm.rawValue,
                action: #selector(selectCharm(_:)),
                keyEquivalent: ""
            )

            item.target = self

            item.representedObject = charm.rawValue

            charmMenu.addItem(item)
        }

        charmMenuItem.submenu = charmMenu

        menu.addItem(charmMenuItem)

        statusItem?.menu = menu
    }
    
    private func setupMenuBarIcon() {

        statusItem =
            NSStatusBar.system.statusItem(
                withLength: NSStatusItem.variableLength
            )

        guard let button = statusItem?.button else {
            return
        }

        if let image = NSImage(
            systemSymbolName: "eye.fill",
            accessibilityDescription: "Drishti Bommai"
        ) {
            image.isTemplate = true
            button.image = image
        }

        button.toolTip = "Drishti Bommai"

        setupMenu()
    }

    // MARK: - Charm Window

    private func createBommaiPanel() {

        let contentView = ContentView(
            charm: selectedCharm
        )

        let hostingView =
            NSHostingView(
                rootView: contentView
            )

        let panel = NSPanel(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 180,
                height: 260
            ),
            styleMask: [
                .borderless,
                .nonactivatingPanel
            ],
            backing: .buffered,
            defer: false
        )

        hostingView.frame =
            panel.contentView?.bounds ?? .zero

        hostingView.autoresizingMask = [
            .width,
            .height
        ]

        panel.contentView = hostingView

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false

        panel.level = .floating

        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true

        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        panel.isMovable = false

        panel.orderFrontRegardless()

        bommaiPanel = panel
    }

    // MARK: - Position

    private func positionBommai() {

        guard
            let button = statusItem?.button,
            let buttonWindow = button.window,
            let panel = bommaiPanel
        else {
            return
        }

        let buttonRect =
            buttonWindow.convertToScreen(
                button.frame
            )

        let panelWidth =
            panel.frame.width

        let panelHeight =
            panel.frame.height

        let x =
            buttonRect.midX
            - panelWidth / 2

        let y =
            buttonRect.minY
            - panelHeight
            + 5

        panel.setFrame(
            NSRect(
                x: x,
                y: y,
                width: panelWidth,
                height: panelHeight
            ),
            display: true
        )
    }

    // MARK: - Show / Hide

    private func updateMenu() {

        guard
            let menu = statusItem?.menu,
            let visibilityItem = menu.items.first
        else {
            return
        }

        visibilityItem.title =
            isCharmVisible
            ? "Hide Charm"
            : "Show Charm"

        visibilityItem.state =
            isCharmVisible
            ? .on
            : .off
    }
    
    @objc
    private func toggleCharm() {

        guard let panel = bommaiPanel else {
            return
        }

        if isCharmVisible {

            panel.orderOut(nil)

            isCharmVisible = false

        } else {

            positionBommai()

            panel.orderFrontRegardless()

            isCharmVisible = true
        }

        updateMenu()
    }
}
