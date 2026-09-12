import SwiftUI
import AppKit
import UniformTypeIdentifiers

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

    private var isCharmVisible = true
    private var selectedCharm: Charm = .drishti

    private var customImagePath: URL?

    func applicationDidFinishLaunching(
        _ notification: Notification
    ) {

        loadCustomImage()

        setupMenuBarIcon()
        createBommaiPanel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.positionBommai()
        }

        // Reposition when the screen/menu-bar configuration changes.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(repositionCharm),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    // MARK: - Menu Bar

    private func setupMenuBarIcon() {

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        guard let button = statusItem?.button else {
            return
        }

        if let image = NSImage(
            systemSymbolName: "eye.fill",
            accessibilityDescription: "Dhristi Bommai"
        ) {
            image.isTemplate = true
            button.image = image
        }

        button.toolTip = "Dhristi Bommai"

        setupMenu()
    }

    private func setupMenu() {

        let menu = NSMenu()

        // Show / Hide
        let visibilityItem = NSMenuItem(
            title: isCharmVisible ? "Hide Charm" : "Show Charm",
            action: #selector(toggleCharm),
            keyEquivalent: ""
        )

        visibilityItem.target = self

        menu.addItem(visibilityItem)

        menu.addItem(.separator())

        // Select Charm
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

            if charm == selectedCharm {
                item.state = .on
            }

            charmMenu.addItem(item)
        }

        charmMenu.addItem(.separator())

        let customItem = NSMenuItem(
            title: "Custom...",
            action: #selector(selectCustomImage),
            keyEquivalent: ""
        )

        customItem.target = self

        if selectedCharm == .drishti && customImagePath != nil {
            customItem.state = .on
        }

        charmMenu.addItem(customItem)

        charmMenuItem.submenu = charmMenu

        menu.addItem(charmMenuItem)

        statusItem?.menu = menu
    }

    // MARK: - Charm Window

    private func createBommaiPanel() {

        let contentView = ContentView(
            charm: selectedCharm,
            customImagePath: customImagePath
        )

        let hostingView = NSHostingView(
            rootView: contentView
        )

        let panel = NSPanel(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 300,
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

    @objc
    private func repositionCharm() {
        positionBommai()
    }

    private func positionBommai() {

        guard
            let button = statusItem?.button,
            let buttonWindow = button.window,
            let panel = bommaiPanel
        else {
            return
        }

        let buttonRect =
            buttonWindow.convertToScreen(button.frame)

        let x =
            buttonRect.midX
            - panel.frame.width / 2
            + 35

        let y =
            buttonRect.minY
            - panel.frame.height

        panel.setFrameOrigin(
            NSPoint(
                x: x,
                y: y
            )
        )
    }    // MARK: - Show / Hide

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

        setupMenu()
    }

    // MARK: - Built-in Charm Selection

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
        customImagePath = nil

        updateCharmView()
        setupMenu()
    }

    // MARK: - Custom Image

    @objc
    private func selectCustomImage() {

        let panel = NSOpenPanel()

        panel.title = "Choose a Charm"
        panel.message = "Select a PNG image for your charm."
        panel.allowedContentTypes = [.png]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        guard panel.runModal() == .OK,
              let url = panel.url
        else {
            return
        }

        saveCustomImage(url)

        customImagePath = customImageURL()

        updateCharmView()
        setupMenu()
    }

    // MARK: - Custom Image Storage

    private func customImageURL() -> URL? {

        guard let applicationSupport =
                FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                ).first
        else {
            return nil
        }

        let folder =
            applicationSupport
                .appendingPathComponent(
                    "DhristiBommai",
                    isDirectory: true
                )

        return folder.appendingPathComponent(
            "CustomCharm.png"
        )
    }

    private func saveCustomImage(
        _ sourceURL: URL
    ) {

        guard let destination =
                customImageURL()
        else {
            return
        }

        do {

            let folder =
                destination.deletingLastPathComponent()

            try FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )

            if FileManager.default.fileExists(
                atPath: destination.path
            ) {
                try FileManager.default.removeItem(
                    at: destination
                )
            }

            try FileManager.default.copyItem(
                at: sourceURL,
                to: destination
            )

        } catch {

            print(
                "Could not save custom charm:",
                error
            )
        }
    }

    private func loadCustomImage() {

        guard
            let url = customImageURL(),
            FileManager.default.fileExists(
                atPath: url.path
            )
        else {
            return
        }

        customImagePath = url
    }

    // MARK: - Update View

    private func updateCharmView() {

        guard let panel = bommaiPanel else {
            return
        }

        let contentView = ContentView(
            charm: selectedCharm,
            customImagePath: customImagePath
        )

        let hostingView = NSHostingView(
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
}
