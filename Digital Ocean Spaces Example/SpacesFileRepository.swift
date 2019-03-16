import Foundation
import AWSS3

/// An enum representing the regions in which DO Spaces are available
private enum SpaceRegion: String {
    case sfo = "sfo2", ams = "ams3", sgp = "sgp1"
    
    var endpointUrl: String {
        return "https://\(self.rawValue).digitaloceanspaces.com"
    }
}

struct SpacesFileRepository {
    private static let accessKey = "YOUR-ACCESS-KEY-HERE"
    private static let secretKey = "YOUR-SECRET-KEY-HERE"
    private static let bucket = "YOUR-BUCKET-NAME-HERE"
    private let fileName = "example-image"
    
    private var transferUtility: AWSS3TransferUtility?
    
    init(){
        //Create a credential using DO Spaces API key (https://cloud.digitalocean.com/account/api/tokens)
        let credential = AWSStaticCredentialsProvider(accessKey: SpacesFileRepository.accessKey, secretKey: SpacesFileRepository.secretKey)
        
        //Create an endpoint that points to the data centre where you created your Space
        let regionEndpoint = AWSEndpoint(urlString: SpaceRegion.sfo.endpointUrl)
        
        //Create a configuration using the credential and endpoint. Note that region doesn't matter
        let configuration = AWSServiceConfiguration(region: .USEast1, endpoint: regionEndpoint, credentialsProvider: credential)
        
        //Setup a configuration to point to your Space. Make bucket the name of your Space
        let transferConfiguration = AWSS3TransferUtilityConfiguration()
        transferConfiguration.isAccelerateModeEnabled = false
        transferConfiguration.bucket = SpacesFileRepository.bucket
        
        //Now register your Space with the AWS Transfer Utility so you can upload/download files
        AWSS3TransferUtility.register(with: configuration!, transferUtilityConfiguration: transferConfiguration, forKey: SpacesFileRepository.bucket)
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: SpacesFileRepository.bucket)
    }
    
    /// Uploads an example file (see example-image.jpg in the project directory) using the S3 SDK to your space
    func uploadExampleFile(){
        //Get the image URL within the app bundle
        guard let exampleImage = Bundle.main.url(forResource: fileName, withExtension: "jpg") else {
            print("Example image URL not found")
            return
        }
        
        //Create an upload task
        transferUtility?.uploadFile(exampleImage, key: fileName, contentType: "image/jpeg", expression: nil, completionHandler: { task, error in
            guard error == nil else {
                print("S3 Upload Error: \(error!.localizedDescription)")
                return
            }
            
            print("S3 Upload Completed")
        }).continueWith(block: { (task) -> Any? in
            //Now lets start the upload task
            print("S3 Upload Starting")
            return nil
        })
    }
    
    func downloadExampleFile(completion: @escaping ((Data?, Error?) -> Void)){
        //Create a download task. Replace your-file-name with your actual file name.
        transferUtility?.downloadData(forKey: fileName, expression: nil, completionHandler: { (task, url, data, error) in
            guard error == nil else {
                print("S3 Download Error: \(error!.localizedDescription)")
                completion(nil, error)
                return
            }
            print("S3 Download Completed")
            completion(data, nil)
        }).continueWith(block: { (task) -> Any? in
            //Now lets start the download task
            print("S3 Download Starting")
            return nil
        })
    }
}
