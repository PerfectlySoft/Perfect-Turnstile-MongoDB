//
//  Tokens.swift
//  PerfectTurnstileMongoDB
//
//  Created by Jonathan Guthrie on 2016-12-05.
//
//

import MongoDBStORM
import StORM
import Foundation
import SwiftRandom
import Turnstile

/// Class for handling the tokens that are used for JSON API and Web authentication
open class AccessTokenStore : MongoDBStORM {

	/// The token itself.
	var id: String = ""

	/// The userid relates to the Users object UniqueID
	var userid: String = ""

	/// Integer relaing to the created date/time
	var created: Int = 0

	/// Integer relaing to the last updated date/time
	var updated: Int = 0

	/// Idle period specified when token was created
	var idle: Int = 86400 // 86400 seconds = 1 day

	/// Collection name used to store Tokens
	override public init() {
		super.init()
		_collection = "tokens"
	}


	/// Set incoming data from database to object
	open override func to(_ this: StORMRow) {
		if let val = this.data["_id"]		{ id		= val as! String }
		if let val = this.data["userid"]	{ userid	= val as! String }
		if let val = this.data["created"]	{ created	= val as! Int }
		if let val = this.data["updated"]	{ updated	= val as! Int }
		if let val = this.data["idle"]		{ idle		= val as! Int}

	}

	/// Iterate through rows and set to object data
	func rows() -> [AccessTokenStore] {
		var rows = [AccessTokenStore]()
		for i in 0..<self.results.rows.count {
			let row = AccessTokenStore()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}


	private func now() -> Int {
		return Int(Date.timeIntervalSinceReferenceDate)
	}

	/// Checks to see if the token is active
	/// Upticks the updated int to keep it alive.
	public func check() -> Bool? {
		if (updated + idle) < now() { return false } else {
			do {
				updated = now()
				try save()
			} catch {
				print(error)
			}
			return true
		}
	}

	/// Triggers creating a new token.
	public func new(_ u: String) -> String {
		let rand = URandom()
		id = rand.secureToken
		id = id.replacingOccurrences(of: "-", with: "a")
		userid = u
		created = now()
		updated = now()
		do {
			try save()
		} catch {
			print(error)
		}
		return id
	}
}
