import SwiftUI

struct FlatLensListView: View {
    let lenses: [Lens]
    let onSelect: (Lens) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: AppTheme.Spacing.padding36) {
                ForEach(lenses) { lens in
                    WeatherStyleLensRow(lens: lens)
                        .onTapGesture {
                            onSelect(lens)
                        }
                }
                Spacer(minLength: 200) // мягкий отступ чтобы последний элемент не прилипал к краю
            }
            .padding(.top, AppTheme.Spacing.xl)
        }
    }
}
