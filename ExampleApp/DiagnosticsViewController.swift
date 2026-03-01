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
        info += "\n"
        
        // Certificate Info
        info += "🔐 CODE SIGNING\n"
        if let certInfo = getCodeSigningInfo() {
            info += certInfo
        } else {
            info += "Unable to read signing info\n"
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
        
        // Entitlements
        info += "🎫 ENTITLEMENTS\n"
        if let entitlements = getEntitlements() {
            info += entitlements
        } else {
            info += "Unable to read entitlements\n"
        }
        
        infoTextView.text = info
    }
    
    private func getCodeSigningInfo() -> String? {
        var info = ""
        
        // Get executable path
        guard let executablePath = Bundle.main.executablePath else {
            return "Executable path not found"
        }
        
        // Try to read code signature
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        task.arguments = ["-dv", executablePath]
        
        let pipe = Pipe()
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                info += output
            }
        } catch {
            info += "Error reading signature: \(error.localizedDescription)\n"
        }
        
        return info.isEmpty ? nil : info
    }
    
    private func getProvisioningProfileInfo() -> String? {
        guard let profilePath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            return nil
        }
        
        guard let profileData = try? Data(contentsOf: URL(fileURLWithPath: profilePath)) else {
            return "Failed to read profile data"
        }
        
        // Find XML content between <?xml and </plist>
        guard let profileString = String(data: profileData, encoding: .ascii) else {
            return "Failed to decode profile"
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
                    info += "Created: \(creationDate)\n"
                }
                if let expirationDate = plist["ExpirationDate"] as? Date {
                    info += "Expires: \(expirationDate)\n"
                }
                if let appID = plist["AppIDName"] as? String {
                    info += "App ID: \(appID)\n"
                }
                if let provisions = plist["ProvisionedDevices"] as? [String] {
                    info += "Devices: \(provisions.count) device(s)\n"
                }
                
                return info
            }
        } catch {
            return "Error parsing profile: \(error.localizedDescription)"
        }
        
        return nil
    }
    
    private func getEntitlements() -> String? {
        guard let entitlements = Bundle.main.infoDictionary?["Entitlements"] as? [String: Any] else {
            // Try alternative method
            return getEntitlementsFromCodeSign()
        }
        
        var info = ""
        for (key, value) in entitlements.sorted(by: { $0.key < $1.key }) {
            info += "\(key): \(value)\n"
        }
        
        return info.isEmpty ? nil : info
    }
    
    private func getEntitlementsFromCodeSign() -> String? {
        guard let executablePath = Bundle.main.executablePath else {
            return "Executable path not found"
        }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        task.arguments = ["-d", "--entitlements", "-", executablePath]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
        } catch {
            return "Error reading entitlements: \(error.localizedDescription)"
        }
        
        return nil
    }
}
