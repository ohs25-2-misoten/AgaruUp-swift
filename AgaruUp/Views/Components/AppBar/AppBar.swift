import SwiftUI

struct SearchAppBarButtonModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: action) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
    }
}

extension View {
    func addSearchAppBarButton(action: @escaping () -> Void) -> some View {
        modifier(SearchAppBarButtonModifier(action: action))
    }
}

#Preview {
    NavigationStack {
        Text("コンテンツ表示エリア")
            .addSearchAppBarButton {
                print("Search button tapped!")
            }
    }
}
