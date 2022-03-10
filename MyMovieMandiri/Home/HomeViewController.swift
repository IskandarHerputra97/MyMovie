//
//  HomeViewController.swift
//  MyMovieMandiri
//
//  Created by Iskandar Herputra Wahidiyat on 10/03/22.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var genreList: [Genres] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchCategories()
    }
    
    //MARK: - Private
    private func setupView() {
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "My Movie"
    }
    
    private func fetchCategories() {
        let apiKey = ApiKey.shared.key
        guard let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)&language=en-US") else {
            print("Error: cannot create URL")
            return
        }
        
        //Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Genre.self, from: data)
                    self.genreList = response.genres
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genreList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as? HomeTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = genreList[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genreId = genreList[indexPath.row].id
        let genreTitle = genreList[indexPath.row].name
        let movieListVC = MovieListViewController(genreId: genreId)
        movieListVC.title = genreTitle
        navigationController?.pushViewController(movieListVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
