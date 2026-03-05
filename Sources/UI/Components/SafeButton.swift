import SwiftUI

struct SafeButton<Label>: View where Label: View {
    let role: ButtonRole?
    let requiresConfirmation: Bool
    let action: () -> Void
    let label: () -> Label
    
    @State private var showConfirmation = false
    
    init(
        role: ButtonRole? = nil,
        requiresConfirmation: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.requiresConfirmation = requiresConfirmation
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(role: role) {
            if requiresConfirmation {
                showConfirmation = true
            } else {
                action()
            }
        } label: {
            label()
        }
        .alert("确认操作", isPresented: $showConfirmation) {
            Button("取消", role: .cancel) { }
            Button("确认", role: .destructive) {
                action()
            }
        } message: {
            Text("确定要执行此操作吗？")
        }
    }
}

extension SafeButton where Label == Text {
    init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        requiresConfirmation: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(role: role, requiresConfirmation: requiresConfirmation, action: action) {
            Text(titleKey)
        }
    }
}
