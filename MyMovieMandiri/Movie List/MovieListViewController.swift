//
//  MovieListViewController.swift
//  MyMovieMandiri
//
//  Created by Iskandar Herputra Wahidiyat on 10/03/22.
//

import UIKit

class MovieListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var movieResponseData: [MovieListResponseDetail] = []
    private var genreId: Int
    
    //MARK: - Lifecycle
    required init(genreId: Int) {
        self.genreId = genreId
        
        super.init(nibName: "MovieListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchMovies()
    }
    
    //MARK: - Setup
    private func setupView() {
        tableView.register(UINib(nibName: "MovieListTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieListTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Private
    private func fetchMovies() {
        let apiKey = ApiKey.shared.key
        let genreId = "\(self.genreId)"
        
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&with_genres=\(genreId)") else {
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
                    let response = try JSONDecoder().decode(MovieListResponse.self, from: data)
                    self.movieResponseData = response.results
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

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieResponseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MovieListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell") as? MovieListTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = movieResponseData[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieId = movieResponseData[indexPath.row].id
        let movieDetailVC = MovieDetailViewController(movieId: movieId)
        navigationController?.pushViewController(movieDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
