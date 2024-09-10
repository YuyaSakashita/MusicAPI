//
//  ViewController.swift
//  MusicAPI
//
//  Created by 坂下雄哉 on 2024/09/10.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var musicList: [Music] = []
    var artworks: [UIImage?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.dataSource = self
    }
    func requestMusic(keyword: String) async -> MusicResponse?{
        
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&entity=song&country=JP&lang=ja_jp&limit=20"
        
        guard let encodeUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else{ return nil}
        guard let url = URL(string: encodeUrlString) else {return nil}
        
        do{
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else { return nil }
            
            if httpResponse.statusCode == 200 {
                let decodedData = try JSONDecoder().decode(MusicResponse.self, from:data)
                return decodedData
            } else {
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    func getImage(url: URL) async -> UIImage?{
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else { return nil }
            
            return image
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        Task {
            let response: MusicResponse? = await requestMusic(keyword: text)
            guard let musicResult = response else { return }
            musicList = musicResult.results
            
            artworks = []
            for music in musicList{
                let image = await getImage(url: music.artworkUrl160)
                artworks.append(image)
            }
            
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = artworks[indexPath.row]
        content.text = musicList[indexPath.row].trackName
        cell.contentConfiguration = content

        return cell
    }

}

