/// HTTP Method
///
/// - delete: DELETE
/// - get: GET
/// - head: HEAD
/// - post: POST
///		- The POST operation adds an object to a specified bucket using HTML forms. POST is an alternate form of PUT that enables browser-based uploads as a way of putting objects in buckets.
/// - put: PUT
/// See https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectOps.html for more information.
public enum HTTPMethod: String {
	case delete = "DELETE"
    case get = "GET"
	case head = "HEAD"
	case post = "POST"
    case put = "PUT"
}
