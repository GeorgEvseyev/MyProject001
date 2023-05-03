//
//  ViewController.swift
//  project001
//
//  Created by Георгий Евсеев on 14.05.22.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var count = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendedTapped))

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        performSelector(inBackground: #selector(fetchLoad), with: nil)

        let defaults = UserDefaults.standard

        if let savedPicture = defaults.object(forKey: "count") as? Data {
            if let decodedPicture = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPicture) as? [Int] {
                count = decodedPicture
            }
        }
    }

    @objc func fetchLoad() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
                pictures = pictures.sorted(by: <)
                count.append(0)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "\(count[indexPath.row])"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            var index = 1
            for picture in pictures {
                if picture == pictures[indexPath.row] {
                    break
                }
                index += 1
            }
            vc.selectedPictureNumber = index
            vc.totalPictures = pictures.count
            vc.selectedImage = pictures[indexPath.row]
            count[indexPath.row] += 1
            save()

            navigationController?.pushViewController(vc, animated: true)
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: true)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: count, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "count")
        }
        print("OK")
    }

    @objc func recommendedTapped() {
        let vc = UIActivityViewController(activityItems: ["Try to use this app!"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}


