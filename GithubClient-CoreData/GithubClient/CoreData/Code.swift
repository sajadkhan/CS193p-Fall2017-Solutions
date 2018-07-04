//
//  Code.swift
//  GithubClient
//
//  Created by Sajad on 7/4/18.
//  Copyright © 2018 Sajad. All rights reserved.
//

import UIKit
import CoreData

class Code: NSManagedObject {
    // Factory method to create new code entry in the database, from the given information of a github code object. There can be same code object at multiple entries in the database
    class func createCodeObject(matching githubCodeObject: GithubCode, in context: NSManagedObjectContext) throws -> Code {
        let codeObject = Code(context: context)
        codeObject.name = githubCodeObject.name
        codeObject.path = githubCodeObject.path
        do {
             codeObject.repository = try Repository.findOrCreateRepository(matching: githubCodeObject.repository, in: context)
        } catch {
            throw error
        }
       
        return codeObject
    }
}
