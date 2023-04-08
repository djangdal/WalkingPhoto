//
//  View.swift
//  Trooper
//
//  Created by David Jangdal on 2021-02-28.
//

import SwiftUI

extension View {
    public func padding(top: CGFloat = 0,
                        leading: CGFloat = 0,
                        bottom: CGFloat = 0,
                        trailing: CGFloat = 0) -> some View {
        self.padding(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }

    public func padding(vertical: CGFloat,
                        horizontal: CGFloat) -> some View {
        self.padding(EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal))
    }

    public func padding(vertical: CGFloat) -> some View {
        self.padding(vertical: vertical, horizontal: 0)
    }

    public func padding(horizontal: CGFloat) -> some View {
        self.padding(vertical: 0, horizontal: horizontal)
    }
}
