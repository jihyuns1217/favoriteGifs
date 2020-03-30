//
//  URLDataTaskManager.swift
//  FavoriteGifs
//
//  Created by Jihyun Son on 2020/03/29.
//  Copyright © 2020 Jihyun Son. All rights reserved.
//

import Foundation

protocol DataTaskManagerDelegate: class {
    func dataTaskCompleted(result: Result<Data, Error>)
}

protocol ProgressBarDelegate: class {
    func progressRateChanged(progressRate: Float)
}

class DataTaskManager: NSObject {
    static var shared: DataTaskManager = DataTaskManager()
    weak var delegate: DataTaskManagerDelegate?
    weak var progressBarDelegate: ProgressBarDelegate?
    
    private var session: URLSession!
    private var expectedContentLength: Int = 0
    private var receivedData: Data?
    
    var dataTask:URLSessionDataTask?
    
    override init() {
        super.init()
        
        session = URLSession(configuration: URLSessionConfiguration.default, delegate:self, delegateQueue: OperationQueue.main)
    }
    
    func resumeDataTask(request: URLRequest) {
        receivedData = nil
        dataTask = session.dataTask(with: request)
        dataTask!.resume()
    }
    
}

extension DataTaskManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if receivedData == nil {
            receivedData = Data()
        }
            
        receivedData!.append(data)

        let percentageDownloaded = Float(data.count) / Float(expectedContentLength)
        progressBarDelegate?.progressRateChanged(progressRate: percentageDownloaded)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        progressBarDelegate?.progressRateChanged(progressRate: 1)
        
        guard let data = receivedData,
            let response = task.response as? HTTPURLResponse,
            (200 ..< 300) ~= response.statusCode,
            error == nil else {
                delegate?.dataTaskCompleted(result: .failure(error ?? NetworkError.extra))
                return
        }

        delegate?.dataTaskCompleted(result: .success(data))
    }
}
