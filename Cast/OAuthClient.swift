import Cocoa
import RxCocoa
import RxSwift

import SwiftyJSON
import KeychainAccess

// MARK: - OAuthClient options

/// OAuth2 flow parameters
public struct OAuthOptions {

	/// Required. The client ID you received from GitHub when you registered.
	public var clientID: String = ""

	/// Required. The client secret you received from GitHub when you registered.
	public var clientSecret: String = ""

	/// Redirect users to request GitHub access
	public var authURL: String = "https://github.com/login/oauth/authorize/"

	/// The URL in your app where users will be sent after authorization.
	public var redirectURL: String = "cast://oauth"

	/// Exchange authURL: code for an access token
	public var tokenURL: String = "https://github.com/login/oauth/access_token"
}


public class OAuthClient: NSObject {
	var options: OAuthOptions
	var eventHandler: NSAppleEventManager?


	//MARK: - Initialization

	required public init(options opt: OAuthOptions) {
		self.options = opt
		super.init()
		self.eventHandler = registerEventHandlerForURL(handler: self)
	}


	//MARK:- Public

	/// Send the user to request authentication web page
	public func authorize() -> Void {

		self.oauthRequest()
	}

	/// Remove the access token from the Key chain
	/// and send the user to the revoke token web page
	public class func revoke() -> NSError? {
		let keychain = Keychain(service: "com.lfaoro.cast.github-token")
		let revokeURL = NSURL(
			string: "https://github.com/settings/connections/applications/" +
			"ef09cfdbba0dfd807592")!

		NSWorkspace.sharedWorkspace().openURL(revokeURL)

		return keychain.remove("token")
	}

	/// Retrieve the access token from the Keychain
	public class func getToken() -> String? {
		let keychain = Keychain(service: "com.lfaoro.cast.github-token")

		return keychain.get("token")
	}


	//MARK:- Internal
	func oauthRequest() -> Void {

		let oauthQuery = [
			NSURLQueryItem(name: "client_id", value: options.clientID),
			NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
			NSURLQueryItem(name: "scope", value: "gist")
			//      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
		]

		let oauthComponents = NSURLComponents()
		oauthComponents.scheme = "https"
		oauthComponents.host = "github.com"
		oauthComponents.path = "/login/oauth/authorize/"
		oauthComponents.queryItems = oauthQuery

		NSWorkspace.sharedWorkspace().openURL(oauthComponents.URL!)
	}


	func exchangeCodeForAccessToken(code: String) -> Observable<String> {

		let oauthQuery = [
			NSURLQueryItem(name: "client_id", value: options.clientID),
			NSURLQueryItem(name: "client_secret", value: options.clientSecret),
			NSURLQueryItem(name: "code", value: code),
			NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
			//      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
		]

		let oauthComponents = NSURLComponents()
		oauthComponents.scheme = "https"
		oauthComponents.host = "github.com"
		oauthComponents.path = "/login/oauth/access_token"
		oauthComponents.queryItems = oauthQuery

		let request = NSMutableURLRequest(URL: oauthComponents.URL!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")

		return create { stream in
			let session = NSURLSession.sharedSession()
			session.dataTaskWithRequest(request) { (data, response, error) -> Void in
				if let data = data {
					if let token = JSON(data: data)["access_token"].string {
						sendNext(stream, token)
						sendCompleted(stream)
					} else {
						sendError(stream, ConnectionError.InvalidData("No Token :((("))
					}
				} else {
					sendError(stream, ConnectionError.NoResponse(error!.localizedDescription))
				}
				}.resume()

			return NopDisposable.instance
		}
	}

}


// MARK: - Legacy NSAppleEventManager

extension OAuthClient {

	/// Registers URL callback event
	func registerEventHandlerForURL(handler object: AnyObject) -> NSAppleEventManager {
		let eventManager: NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
		eventManager.setEventHandler(object,
			andSelector: "handleURLEvent:",
			forEventClass: AEEventClass(kInternetEventClass),
			andEventID: AEEventClass(kAEGetURL))
		return eventManager
	}

	/// Selector of `registerEventHandlerForURL`
	func handleURLEvent(event: NSAppleEventDescriptor) -> Void {

		if let callback = event.descriptorForKeyword(AEEventClass(keyDirectObject))?.stringValue {
			// thank you mikeash!

			if let code = NSURLComponents(string: callback)?.queryItems?[0].value {

				exchangeCodeForAccessToken(code)
					.debug()
					.retry(3)
					.subscribe { event in
						switch event {
						case .Next(let token):
							let keychain = Keychain(service: "com.lfaoro.cast.github-token")
							keychain["token"] = token
						case .Completed:
							Swift.print("completed")
							app.statusBarItem.menu = createMenu(app.menuSendersAction)
							app.userNotification.pushNotification(error: "GitHub Authentication",
								description: "Successfully authenticated!")
						case .Error(let error):
							Swift.print("\(error)")
						}
				}

			} else {
				fatalError("Impossible to extract code")
			}
			
		} else {
			fatalError("No callback")
		}
	}
}
