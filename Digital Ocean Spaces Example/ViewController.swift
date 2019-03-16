import AWSS3
import UIKit

class ViewController: UIViewController {
    private let spacesFileRepository = SpacesFileRepository()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func uploadExampleFile(){
        spacesFileRepository.uploadExampleFile()
    }
    
    @IBAction func downloadExampleFile(){
        //Download and show the image in a UIImageView
        spacesFileRepository.downloadExampleFile { (data, error) in
            guard let data = data else {
                print("Image failed to download")
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}

