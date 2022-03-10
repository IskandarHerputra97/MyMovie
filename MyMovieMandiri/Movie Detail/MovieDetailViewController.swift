//
//  MovieDetailViewController.swift
//  MyMovieMandiri
//
//  Created by Iskandar Herputra Wahidiyat on 10/03/22.
//

import UIKit
import WebKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    @IBOutlet weak var movieTrailerLabel: UILabel!
    @IBOutlet weak var movieWebView: WKWebView!
    @IBOutlet weak var movieTableView: UITableView!
    
    private var reviewData: [MovieReviewsResponseDetail] = []
    
    private var movieId: Int
    
    //MARK: - Lifecycle
    required init(movieId: Int) {
        self.movieId = movieId
        
        super.init(nibName: "MovieDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchMovieDetail()
    }
    
    //MARK: - Setup
    private func setupView() {
        title = "Movie Title"
        
        movieWebView.allowsBackForwardNavigationGestures = true
        
        movieTableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        movieTableView.delegate = self
        movieTableView.dataSource = self
    }
    
    //MARK: - Private
    private func fetchMovieDetail() {
        let movieId = "\(self.movieId)"
        let apiKey = ApiKey.shared.key
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&language=en-US") else {
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
                    let response = try JSONDecoder().decode(MovieDetailResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.title = response.title
                        self.movieReleaseDateLabel.text = "Release Date: \(response.release_date)"
                        self.movieOverviewLabel.text = response.overview
                        
                        guard let imageURL = URL(string: "https://image.tmdb.org/t/p/w780\(response.backdrop_path)") else {
                            return
                        }
                        guard let imageData = try? Data(contentsOf: imageURL) else {
                            return
                        }
                        let image = UIImage(data: imageData)
                        self.movieImageView.image = image
                    }
                    self.fetchTrailerVideo()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    private func fetchTrailerVideo() {
        let movieId = "\(self.movieId)"
        let apiKey = ApiKey.shared.key
        
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apiKey)&language=en-US") else {
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
                    let response = try JSONDecoder().decode(TrailerVideo.self, from: data)
                    if response.results.count > 0 {
                        let videoKey = response.results[0].key
                        guard let videoURL = URL(string: "https://www.youtube.com/embed/\(videoKey)") else {
                            return
                        }
                        DispatchQueue.main.async {
                            self.movieWebView.load(URLRequest(url: videoURL))
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.movieTrailerLabel.isHidden = true
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
        fetchUserReviews()
    }
    
    private func fetchUserReviews() {
        let movieId = "\(self.movieId)"
        let apiKey = ApiKey.shared.key
        
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)/reviews?api_key=\(apiKey)&language=en-US&page=1") else {
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
                    let response = try JSONDecoder().decode(MovieReviewsResponse.self, from: data)
                    self.reviewData = response.results
                    DispatchQueue.main.async {
                        if response.results.count == 0 {
                            self.movieTableView.isHidden = true
                        }
                        else {
                            self.movieTableView.isHidden = false
                        }
                        self.movieTableView.reloadData()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}

extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ReviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        cell.usernameLabel.text = reviewData[indexPath.row].author
        cell.userReviewLabel.text = reviewData[indexPath.row].content
        
        return cell
    }
}
