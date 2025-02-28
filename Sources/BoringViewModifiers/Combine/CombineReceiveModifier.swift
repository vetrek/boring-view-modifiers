//
//  BoringViewModifiers
//

import Combine
import SwiftUI

/// A custom SwiftUI ViewModifier that subscribes to two Combine publishers and
/// performs an action with their combined latest values.
public struct CombineReceiveModifier<P1, P2>: ViewModifier where P1: Publisher, P1.Failure == Never, P2: Publisher, P2.Failure == Never {
  
  // MARK: - Stored Properties
  
  let publisher1: P1
  let publisher2: P2
  let action: (P1.Output, P2.Output) -> Void
  
  @State private var cancellable: AnyCancellable?
  
  public func body(content: Content) -> some View {
    content
      .onAppear {
        cancellable = publisher1
          .combineLatest(publisher2)
          .sink { value1, value2 in
            action(value1, value2)
          }
      }
      .onDisappear {
        cancellable?.cancel()
      }
  }
}

public extension View {
  /// Adds a method to SwiftUI's View to easily apply the CombineReceiveModifier.
  func onCombineReceive<P1: Publisher, P2: Publisher>(
    _ publisher1: P1,
    _ publisher2: P2,
    action: @escaping (P1.Output, P2.Output) -> Void
  ) -> some View where P1.Failure == Never, P2.Failure == Never {
    modifier(
      CombineReceiveModifier(
        publisher1: publisher1,
        publisher2: publisher2,
        action: action
      )
    )
  }
}
