import SwiftUI

// Экран-заставка с анимированным логотипом и индикатором загрузки
struct SplashScreenView: View {
    // Менеджер данных для отслеживания состояния загрузки
    @EnvironmentObject var dataManager: DataManager
    // Состояние: готов ли переход к основному интерфейсу
    @State private var isActive = false
    // Анимация пульсации логотипа
    @State private var logoPulse = false
    // Анимация появления стеклянной карточки
    @State private var glassBlur = false
    // Анимация появления подзаголовка
    @State private var showSubtitle = false
    // Фаза анимации мерцания для текста разработчика
    @State private var shimmerPhase: CGFloat = 0

    // Основное содержимое экрана
    var body: some View {
        // Условный переход к основному интерфейсу после загрузки
        if isActive {
            MainTabView()
        } else {
            // Контейнер с многослойным дизайном заставки
            ZStack {
                // Градиентный темный фон с фиолетово-синими оттенками
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 28 / 255, green: 32 / 255, blue: 48 / 255, opacity: 1),
                        Color(.sRGB, red: 38 / 255, green: 36 / 255, blue: 97 / 255, opacity: 1),
                    ]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Декоративная светящаяся "аура" для создания атмосферы
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.28),
                                Color.purple.opacity(0.16),
                                Color.clear,
                            ]),
                            center: .center, startRadius: 0, endRadius: 350
                        )
                    )
                    .frame(width: 430, height: 430)
                    .blur(radius: 2)
                    .offset(x: -60, y: -120)

                // Центральная область с логотипом и названием приложения
                VStack(spacing: 0) {
                    // Контейнер логотипа на стеклянной подложке
                    ZStack {
                        // Стеклянная карточка с эффектом размытия
                        GlassCard()
                            .frame(width: 230, height: 230)
                            .opacity(glassBlur ? 1 : 0)
                            .scaleEffect(glassBlur ? 1 : 0.85)
                            .animation(.easeOut(duration: 0.7), value: glassBlur)

                        // Анимированный логотип с градиентной заливкой
                        Image(systemName: "camera.aperture")
                            .font(.system(size: 88, weight: .bold))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.orange, Color.yellow, Color.purple.opacity(0.9)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                Color.white
                            )
                            .shadow(color: .orange.opacity(0.22), radius: 20, x: 0, y: 6)
                            .scaleEffect(logoPulse ? 1.07 : 1)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: logoPulse)
                    }
                    .padding(.bottom, 8)

                    // Основное название приложения с градиентным текстом
                    Text("Lens Data Base")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow, .orange, .purple.opacity(0.95)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.09), radius: 5, x: 0, y: 3)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 10)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: showSubtitle)

                    // Подзаголовок с описанием функциональности
                    Text("Cinematic lens catalog & rentals")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white.opacity(0.65))
                        .padding(.top, 4)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 8)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: showSubtitle)
                }
                .padding(.top, 24)

                // Нижняя область с индикатором загрузки и подписью разработчика
                VStack {
                    Spacer()
                    // Стеклянная карточка для статуса загрузки
                    GlassCard()
                        .frame(height: 80)
                        .overlay(
                            VStack(spacing: 10) {
                                // Условное отображение состояния загрузки
                                if dataManager.loadingState == .loading {
                                    // Индикатор загрузки с текстом
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .scaleEffect(1.1)
                                            .tint(.orange)
                                        Text("Loading data...")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                } else if case let .error(error) = dataManager.loadingState {
                                    // Отображение ошибки загрузки
                                    Text("Error: \(error)")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                                // Анимированная подпись разработчика с эффектом мерцания
                                ShimmeringText(text: "Developed by Skvora007", phase: shimmerPhase)
                                    .font(.system(.caption, design: .monospaced).weight(.medium))
                                    .opacity(0.87)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 1)
                            }
                            .padding(.vertical, 8)
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, 36)
                }
            }
            .onAppear {
                // Инициализация загрузки данных при появлении экрана
                dataManager.loadData()
                // Запуск анимации появления стеклянного эффекта
                withAnimation(.easeInOut(duration: 1.4)) { glassBlur = true }
                // Отложенный запуск анимаций логотипа и подзаголовка
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    logoPulse = true
                    showSubtitle = true
                }
                // Запуск бесконечной анимации мерцания текста
                withAnimation(Animation.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    shimmerPhase = 1.0
                }
                // Автоматический переход к основному интерфейсу через 2.1 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                    withAnimation(.easeInOut(duration: 0.55)) {
                        if dataManager.loadingState != .loading || dataManager.appData != nil {
                            isActive = true
                        }
                    }
                }
            }
            .onChange(of: dataManager.loadingState) { newState in
                // Реакция на завершение загрузки данных
                if newState == .loaded, !isActive {
                    isActive = true
                }
            }
        }
    }
}

// Переиспользуемый компонент стеклянной карточки с материальным эффектом
struct GlassCard: View {
    // Содержимое карточки с многослойным дизайном
    var body: some View {
        // Основная форма карточки с закругленными углами
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(.ultraThinMaterial)
            .shadow(color: Color.white.opacity(0.07), radius: 16, x: 0, y: 10)
            .background(
                // Тонкая белая обводка для четкости краев
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.13), lineWidth: 1.1)
            )
            .overlay(
                // Градиентная обводка для создания световых акцентов
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.13), Color.purple.opacity(0.09), .clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
}

// Компонент текста с анимацией мерцания (shimmer effect)
struct ShimmeringText: View {
    // Отображаемый текст
    let text: String
    // Фаза анимации для управления положением световой полосы
    var phase: CGFloat

    // Содержимое компонента с эффектом наложения
    var body: some View {
        // Контейнер для наложения двух слоев текста
        ZStack {
            // Базовый слой текста с пониженной прозрачностью
            Text(text)
                .foregroundColor(.white.opacity(0.5))
            // Верхний слой с эффектом мерцания
            Text(text)
                .foregroundColor(.white)
                .overlay(
                    // Движущаяся световая полоса для эффекта мерцания
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.7),
                            .white.opacity(0.15),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 120, height: 12)
                    .rotationEffect(.degrees(20))
                    .offset(x: (phase * 200) - 100)
                    .mask(Text(text))
                )
                .opacity(0.95)
        }
        .clipped()
        .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: phase)
    }
}
