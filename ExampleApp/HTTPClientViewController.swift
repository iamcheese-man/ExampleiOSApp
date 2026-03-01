// HTTPClientViewController.swift
import UIKit

class HTTPClientViewController: UIViewController {
    
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
    
    // URL Input
    private let urlTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter URL (https://api.example.com)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .URL
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // Method Selector
    private let methodLabel: UILabel = {
        let label = UILabel()
        label.text = "Method:"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let methodSegment: UISegmentedControl = {
        let items = ["GET", "POST", "PUT", "DELETE", "PATCH"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    // Headers
    private let headersLabel: UILabel = {
        let label = UILabel()
        label.text = "Headers (JSON):"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let headersTextView: UITextView = {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.text = "{\n  \"Content-Type\": \"application/json\"\n}"
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Body
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Body (JSON/Text):"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyTextView: UITextView = {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.text = "{\n  \"key\": \"value\"\n}"
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Send Button
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Request", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Response
    private let responseLabel: UILabel = {
        let label = UILabel()
        label.text = "Response:"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let responseTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.text = "Response will appear here..."
        tv.textColor = .systemGray
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HTTP Client"
        view.backgroundColor = .systemBackground
        
        setupUI()
        addDoneButtonToKeyboard()
        sendButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(urlTextField)
        contentView.addSubview(methodLabel)
        contentView.addSubview(methodSegment)
        contentView.addSubview(headersLabel)
        contentView.addSubview(headersTextView)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(bodyTextView)
        contentView.addSubview(sendButton)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(responseLabel)
        contentView.addSubview(responseTextView)
        
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
            
            urlTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            urlTextField.heightAnchor.constraint(equalToConstant: 44),
            
            methodLabel.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            methodSegment.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 8),
            methodSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            methodSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            headersLabel.topAnchor.constraint(equalTo: methodSegment.bottomAnchor, constant: 20),
            headersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            headersTextView.topAnchor.constraint(equalTo: headersLabel.bottomAnchor, constant: 8),
            headersTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headersTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headersTextView.heightAnchor.constraint(equalToConstant: 100),
            
            bodyLabel.topAnchor.constraint(equalTo: headersTextView.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            bodyTextView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            bodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bodyTextView.heightAnchor.constraint(equalToConstant: 100),
            
            sendButton.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20),
            sendButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 200),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            
            responseLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            responseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            responseTextView.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 8),
            responseTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            responseTextView.heightAnchor.constraint(equalToConstant: 300),
            responseTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    private func addDoneButtonToKeyboard() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
    
    toolbar.items = [flexSpace, done]
    
    // Apply to ALL text inputs
    urlTextField.inputAccessoryView = toolbar
    headersTextView.inputAccessoryView = toolbar
    bodyTextView.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func sendRequest() {
        guard let urlString = urlTextField.text, !urlString.isEmpty,
              let url = URL(string: urlString) else {
            showResponse("❌ Invalid URL", color: .systemRed)
            return
        }
        
        let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
        let method = methods[methodSegment.selectedSegmentIndex]
        
        // Parse headers
        var headers: [String: String] = [:]
        if let headersData = headersTextView.text.data(using: .utf8),
           let headersJSON = try? JSONSerialization.jsonObject(with: headersData) as? [String: String] {
            headers = headersJSON
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        
        // Add headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body for POST/PUT/PATCH
        if method != "GET" && method != "DELETE" {
            if let bodyText = bodyTextView.text, !bodyText.isEmpty {
                request.httpBody = bodyText.data(using: .utf8)
            }
        }
        
        // Show loading
        sendButton.isEnabled = false
        activityIndicator.startAnimating()
        responseTextView.text = "Sending request..."
        responseTextView.textColor = .systemGray
        
        let startTime = Date()
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.sendButton.isEnabled = true
                self?.activityIndicator.stopAnimating()
                
                let elapsed = Int(Date().timeIntervalSince(startTime) * 1000)
                
                if let error = error {
                    self?.showResponse("❌ ERROR (\(elapsed)ms)\n\n\(error.localizedDescription)", color: .systemRed)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showResponse("❌ Invalid response", color: .systemRed)
                    return
                }
                
                var result = "✅ \(httpResponse.statusCode) (\(elapsed)ms)\n\n"
                result += "=== HEADERS ===\n"
                for (key, value) in httpResponse.allHeaderFields {
                    result += "\(key): \(value)\n"
                }
                
                result += "\n=== BODY ===\n"
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data),
                       let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                       let prettyString = String(data: prettyData, encoding: .utf8) {
                        result += prettyString
                    } else if let string = String(data: data, encoding: .utf8) {
                        result += string
                    } else {
                        result += "Binary data (\(data.count) bytes)"
                    }
                } else {
                    result += "No body"
                }
                
                let color: UIColor = httpResponse.statusCode < 400 ? .label : .systemRed
                self?.showResponse(result, color: color)
            }
        }.resume()
    }
    
    private func showResponse(_ text: String, color: UIColor) {
        responseTextView.text = text
        responseTextView.textColor = color
    }
}
