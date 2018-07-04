//
//  Repository.swift
//  GithubClient
//
//  Created by Sajad on 7/4/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit
import CoreData

class Repository: NSManagedObject {
    // Factory method to create new Repository in the database, from the given information of a github repo. Only unique insertions are possible so if repo exist already inthe database, this method returns that repo and not create one.
    class func findOrCreateRepository(matching githubRepo: GithubRepository, in context: NSManagedObjectContext) throws -> Repository {
        let fetchRequest: NSFetchRequest<Repository> = Repository.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", githubRepo.id)
        
        do {
            let matches = try context.fetch(fetchRequest)
            if matches.count > 0 {
                assert(matches.count == 1, "Repository.findOrCreateRepository -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let repository = Repository(context: context)
        repository.id = Int64(githubRepo.id)
        repository.name = githubRepo.name
        repository.fullName = githubRepo.fullName
        repository.created = githubRepo.createdDate
        repository.language = githubRepo.language
        repository.repoDescription = githubRepo.description
        repository.owner = try Owner.findOrCreateOwner(matching: githubRepo.owner, in: context)
        
        return repository
    }
}
