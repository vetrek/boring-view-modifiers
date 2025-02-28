import Combine
import SwiftUI

/// A custom SwiftUI ViewModifier that subscribes to two Combine publishers and
/// performs an action with their combined latest values.
public struct DebounceReceiveModifier<P, S>: ViewModifier where P: Publisher,  P.Failure == Never, S: Scheduler {
  
  // MARK: - Stored Properties
  
  let publisher: P
  let dueTime: S.SchedulerTimeType.Stride
  let scheduler: S
  let options: S.SchedulerOptions?
  let action: (P.Output) -> Void
  
  @State private var cancellable: AnyCancellable?
  
  public func body(content: Content) -> some View {
    content
      .onAppear {
        cancellable = publisher
          .debounce(for: dueTime, scheduler: scheduler, options: options)
          .sink { value in
            action(value)
          }
      }
      .onDisappear {
        cancellable?.cancel()
      }
  }
}

public extension View {
  /// Adds a method to SwiftUI's View to easily apply the CombineReceiveModifier.
  func debounceReceive<P, S: Scheduler>(
    _ publisher1: P,
    for dueTime: S.SchedulerTimeType.Stride,
    scheduler: S,
    options: S.SchedulerOptions? = nil,
    action: @escaping (P.Output) -> Void
  ) -> some View where P: Publisher, P.Failure == Never, S: Scheduler {
    modifier(
      DebounceReceiveModifier(
        publisher: publisher1,
        dueTime: dueTime,
        scheduler: scheduler,
        options: options,
        action: action
      )
    )
  }
}
