import Cocoa
import RxCocoa
import RxSwift

import SwiftyJSON
import KeychainAccess

///- todo: find a way to return multiple configurations from the same enumCase
public enum OAuthClientConfig {
	case GitHub
}

public class OAuthClient: NSObject {
	let clientID: String
	let clientSecret: String
	let authURL: String
	let redirectURL: String
	let tokenURL: String
	var eventHandler: NSAppleEventManager?


	//MARK: - Initialization

	required public init(clientID: String,
		clientSecret: String,
		authURL: String,
		redirectURL: String,
		tokenURL: String) {

			self.clientID = clientID
			self.clientSecret = clientSecret
			self.authURL = authURL
			self.redirectURL = redirectURL
			self.tokenURL = tokenURL
	}

	convenience public init?(
		clientID: String,
		clientSecret: String,
		service: OAuthClientConfig) {
			// get info from service and call super.init
			self.init(
				clientID: clientID,
				clientSecret: clientSecret,
				authURL: "https://github.com/login/oauth/authorize/", //info gathered from OAuthService
				redirectURL: "cast://oauth", // extract info from NSBundle Info.plist
				tokenURL: "https://github.com/login/oauth/access_token" //info gathered from OAuthService
			)

	}


	//MARK:- Public

	public func authorize() -> Void {

		eventHandler = registerEventHandlerForURL(handler: self)

		oauthRequest()
	}

	public class func revoke() -> NSError? {
		let keychain = Keychain(service: "com.lfaoro.cast.github-token")
		let revokeURL = NSURL(
			string: "https://github.com/settings/connections/applications/" +
			"ef09cfdbba0dfd807592")!

		NSWorkspace.sharedWorkspace().openURL(revokeURL)

		return keychain.remove("token")
	}

	public class func getToken() -> String? {
		let keychain = Keychain(service: "com.lfaoro.cast.github-token")

		return keychain.get("token")
	}


	//MARK:- Internal
	func oauthRequest() -> Void {

		let oauthQuery = [
			NSURLQueryItem(name: "client_id", value: clientID),
			NSURLQueryItem(name: "redirect_uri", value: "cast://oauth"),
			NSURLQueryItem(name: "scope", value: "gist")
			//      NSURLQueryItem(name: "state", value: "\(NSUUID().UUIDString)"),
		]

		let oauthComponents = NSURLComponents()
		oauthComponents.scheme = "https"
		oauthComponents.host = "github.com"
		oauthComponents.path = "/login/oauth/authorize/"
		oauthComponents.queryItems = oauthQuery

		// Register for callback from GitHub
		//        eventManager = registerEventHandlerForURL(handler: self)

		NSWorkspace.sharedWorkspace().openURL(oauthComponents.URL!)
	}

	func registerEventHandlerForURL(handler object: AnyObject) -> NSAppleEventManager {
		let eventManager: NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
		eventManager.setEventHandler(object,
			andSelector: "handleURLEvent:",
			forEventClass: AEEventClass(kInternetEventClass),
			andEventID: AEEventClass(kAEGetURL))
		return eventManager
	}

	//Selector of `registerEventHandlerForURL`
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


	func exchangeCodeForAccessToken(code: String) -> Observable<String> {

		let oauthQuery = [
			NSURLQueryItem(name: "client_id", value: clientID),
			NSURLQueryItem(name: "client_secret", value: clientSecret),
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
