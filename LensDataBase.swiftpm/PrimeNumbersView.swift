import SwiftUI

struct PrimeNumbersView: View {
    @State private var primeNumbers: [Int] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.mainBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Prime Numbers")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("Prime numbers up to 100")
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Generating prime numbers...")
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Display count
                            HStack {
                                Text("Total: \(primeNumbers.count) prime numbers")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Spacer()
                            }
                            
                            // Display prime numbers in a grid-like format
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                                ForEach(primeNumbers, id: \.self) { prime in
                                    PrimeNumberCard(number: prime)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            loadPrimeNumbers()
        }
    }
    
    private func loadPrimeNumbers() {
        isLoading = true
        
        // Simulate a slight delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            primeNumbers = PrimeNumberService.shared.generatePrimesUpTo(100)
            isLoading = false
        }
    }
}

struct PrimeNumberCard: View {
    let number: Int
    
    var body: some View {
        Text("\(number)")
            .font(.system(.title3, design: .monospaced))
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.Colors.primaryText)
            .frame(minWidth: 50, minHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.Colors.cardBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
    }
}

#Preview {
    PrimeNumbersView()
        .environmentObject(DataManager())
}