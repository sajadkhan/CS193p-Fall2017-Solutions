//
//  Owner.swift
//  GithubClient
//
//  Created by Sajad on 7/4/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit
import CoreData

class Owner: NSManagedObject {
    // Factory method to create new owner in the database, from the given information of a github owner. Only unique insertions are possible so if owner exist already inthe database, this method returns that owner and not create one.
    class func findOrCreateOwner(matching githubOwner: GithubOwner, in context: NSManagedObjectContext) throws -> Owner {
        let request: NSFetchRequest<Owner> = Owner.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", githubOwner.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Owner.findOrCreateOwner -- database inconistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let owner = Owner(context: context)
        owner.id = Int64(githubOwner.id)
        owner.name = githubOwner.name
        owner.avatarURL = githubOwner.avatarURL
        return owner
    }
}
