//
//  CategoryModel.swift
//  Watchly
//
//  Created by Murat Menzilci on 1/31/22.
//

import UIKit
import Firebase

/// A model for a category of watch faces
struct CategoryModel {
    let title: String
    let isPremium: Bool
    let itemsCount: Int
}

// MARK: - Build a category model from Firebase data
extension CategoryModel {
    static func build(_ model: QueryDocumentSnapshot?) -> CategoryModel {
        guard let title = model?.documentID,
              let isPremium = model?.data()["isPremium"] as? Bool,
              let itemsCount = model?.data()["itemsCount"] as? Int
        else { return CategoryModel(title: "", isPremium: false, itemsCount: 0) }
        return CategoryModel(title: title, isPremium: isPremium, itemsCount: itemsCount)
    }
}
