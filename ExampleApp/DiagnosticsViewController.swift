// DiagnosticsViewController.swift
import UIKit

class DiagnosticsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diagnostics"
        view.backgroundColor = .systemBackground
        
        setupUI()
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        loadDiagnostics()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(infoTextView)
        contentView.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            infoTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            infoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoTextView.heightAnchor.constraint(equalToConstant: 500),
            
            refreshButton.topAnchor.constraint(equalTo: infoTextView.bottomAnchor, constant: 20),
            refreshButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 150),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            refreshButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func refreshTapped() {
        loadDiagnostics()
    }
    
    private func loadDiagnostics() {
        var info = "=== APP DIAGNOSTICS ===\n\n"
        
        // App Info
        info += "📱 APP INFORMATION\n"
        info += "Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")\n"
        info += "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\n"
        info += "Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")\n"
        info += "Executable: \(Bundle.main.executablePath ?? "Unknown")\n"
        info += "\n"
        
        // Device Info
        info += "📱 DEVICE INFORMATION\n"
        info += "Model: \(UIDevice.current.model)\n"
        info += "System: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)\n"
        info += "Name: \(UIDevice.current.name)\n"
        info += "\n"
        
        // JIT Status
        info += "⚡ JIT STATUS\n"
        if isJITEnabled() {
            info += "Status: ✅ ENABLED\n"
        } else {
            info += "Status: ❌ DISABLED\n"
        }
        info += "\n"
        
        // Provisioning Profile
        info += "📄 PROVISIONING PROFILE\n"
        if let profileInfo = getProvisioningProfileInfo() {
            info += profileInfo
        } else {
            info += "No embedded.mobileprovision found\n"
        }
        info += "\n"
        
        // App Sandbox
        info += "📂 APP SANDBOX\n"
        info += "Documents: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "Unknown")\n"
        info += "Bundle: \(Bundle.main.bundlePath)\n"
        
        infoTextView.text = info
    }
    
    private func isJITEnabled() -> Bool {
        // Try to allocate executable memory
        let size = 1024
        let ptr = mmap(nil, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)
        
        if ptr == MAP_FAILED {
            return false
        }
        
        // Successfully allocated executable memory - JIT is enabled
        munmap(ptr, size)
        return true
    }
    
    private func getProvisioningProfileInfo() -> String? {
        guard let profilePath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            return nil
        }
        
        guard let profileData = try? Data(contentsOf: URL(fileURLWithPath: profilePath)) else {
            return "Failed to read profile data"
        }
        
        // Try parsing as binary plist first
        do {
            if let plist = try PropertyListSerialization.propertyList(from: profileData, options: [], format: nil) as? [String: Any] {
                return formatProvisioningInfo(from: plist)
            }
        } catch {
            // Binary parsing failed, try XML extraction
        }
        
        // Try extracting XML from the data
        guard let profileString = String(data: profileData, encoding: .ascii) else {
            return "Failed to decode profile (binary format)"
        }
        
        guard let startRange = profileString.range(of: "<?xml"),
              let endRange = profileString.range(of: "</plist>") else {
            return "Failed to parse profile XML"
        }
        
        let xmlString = String(profileString[startRange.lowerBound...endRange.upperBound])
        guard let xmlData = xmlString.data(using: .utf8) else {
            return "Failed to extract XML"
        }
        
        do {
            if let plist = try PropertyListSerialization.propertyList(from: xmlData, options: [], format: nil) as? [String: Any] {
                return formatProvisioningInfo(from: plist)
            }
        } catch {
            return "Error parsing profile: \(error.localizedDescription)"
        }
        
        return "Unknown profile format"
    }
    
    private func formatProvisioningInfo(from plist: [String: Any]) -> String {
        var info = ""
        
        if let name = plist["Name"] as? String {
            info += "Name: \(name)\n"
        }
        if let teamName = plist["TeamName"] as? String {
            info += "Team: \(teamName)\n"
        }
        if let teamID = plist["TeamIdentifier"] as? [String], let firstID = teamID.first {
            info += "Team ID: \(firstID)\n"
        }
        if let creationDate = plist["CreationDate"] as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            info += "Created: \(formatter.string(from: creationDate))\n"
        }
        if let expirationDate = plist["ExpirationDate"] as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            info += "Expires: \(formatter.string(from: expirationDate))\n"
            
            // Check if expired
            if expirationDate < Date() {
                info += "⚠️ EXPIRED\n"
            }
        }
        if let appID = plist["AppIDName"] as? String {
            info += "App ID: \(appID)\n"
        }
        if let provisions = plist["ProvisionedDevices"] as? [String] {
            info += "Devices: \(provisions.count) device(s)\n"
        }
        if let entitlements = plist["Entitlements"] as? [String: Any] {
            info += "\nEntitlements:\n"
            for (key, value) in entitlements.sorted(by: { $0.key < $1.key }).prefix(5) {
                info += "  \(key): \(value)\n"
            }
            if entitlements.count > 5 {
                info += "  ... and \(entitlements.count - 5) more\n"
            }
        }
        
        return info.isEmpty ? "Profile data found but empty" : info
    }
}
