//
//  ChannelsViewController.swift
//  chat-messaging-firebase
//
//  Created by Avendi Sianipar on 23/01/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ChannelsViewController: UITableViewController {
    
    private let database = Firestore.firestore()
    private var channelReference: CollectionReference {
        return database.collection("channels")
    }
    
    private var channels: [ChannelsModel] = []
    private var channelListener: ListenerRegistration?
    
    private let currentUser: User
    
    private let currentUserLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private let channelCellIdentifier = "channelCell"
    private var currentChannelAlertController: UIAlertController?
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(style: .grouped)
        title = "Channels"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        channelListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setToolBars()
        clearsSelectionOnViewWillAppear = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
        
        channelListener = channelReference.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }
}

// MARK: - TableViewDelegate
extension ChannelsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = channels[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        let viewController = ChatViewController(user: currentUser, channel: channel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Action for Channel
private extension ChannelsViewController {
    func createChannel() {
        guard
            let alertController = currentChannelAlertController,
            let channelName = alertController.textFields?.first?.text
        else {
            return
        }
        
        let channel = ChannelsModel(name: channelName)
        
        channelReference.addDocument(data: channel.representation) { error in
            if let error = error {
                print("Error saving channel: \(error.localizedDescription)")
            }
        }
    }
    
    func addChannelToTable(_ channel: ChannelsModel) {
        if channels.contains(channel) {
            return
        }
        
        channels.append(channel)
        channels.sort()
        
        guard let index = channels.firstIndex(of: channel) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func updateChannelInTable(_ channel: ChannelsModel) {
        guard let index = channels.firstIndex(of: channel) else {
            return
        }
        
        channels[index] = channel
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func removeChannelFromTable(_ channel: ChannelsModel) {
        guard let index = channels.firstIndex(of: channel) else {
            return
        }
        
        channels.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = ChannelsModel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addChannelToTable(channel)
        case .modified:
            updateChannelInTable(channel)
        case .removed:
            removeChannelFromTable(channel)
        }
    }
}

//MARK: Toolbar
private extension ChannelsViewController {
    func setToolBars() {
        toolbarItems = [
            UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: currentUserLabel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        ]
        currentUserLabel.text = AppSettings.displayName
    }
    
    @objc func addButtonPressed() {
        let alertController = UIAlertController(
            title: "Create a new Channel",
            message: nil,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        alertController.addTextField { field in
            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = "Channel name"
            field.returnKeyType = .done
            field.tintColor = .base
        }
        
        let createAction = UIAlertAction(
            title: "Create",
            style: .default
        ) { _ in
            self.createChannel()
        }
        
        createAction.isEnabled = false
        alertController.addAction(createAction)
        alertController.preferredAction = createAction
        
        present(alertController, animated: true) {
            alertController.textFields?.first?.becomeFirstResponder()
        }
        currentChannelAlertController = alertController
    }
    
    @objc func textFieldDidChange(_ field: UITextField) {
        guard let alertController = currentChannelAlertController else {
            return
        }
        alertController.preferredAction?.isEnabled = field.hasText
    }
    
    @objc func signOut() {
        let alertController = UIAlertController(
            title: nil,
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let signOutAction = UIAlertAction(
            title: "Sign Out",
            style: .destructive
        ) { _ in
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
        
        alertController.addAction(signOutAction)
        present(alertController, animated: true)
    }
}
