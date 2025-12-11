//
//  ContentView.swift
//  Final (FitCart)
//  Created by 陳詠平 on 2025/11/22.
//

import SwiftUI
import Combine

// MARK: - Data Models

enum BodyPart: String, CaseIterable, Identifiable, Codable {
    case chest = "胸"
    case back = "背"
    case legs = "腿"
    case shoulders = "肩"
    case arms = "手"
    case abs = "腹肌"
    case cardio = "有氧"

    var id: String { rawValue }

    private static let predefinedSampleExercises: [BodyPart: [Exercise]] = {
        var exercises: [BodyPart: [Exercise]] = [:]

        exercises[.chest] = [
            Exercise(name: "平板臥推", bodyPart: .chest, imageName: "平板臥推"),
            Exercise(name: "上斜臥推", bodyPart: .chest, imageName: "上斜臥推"),
            Exercise(name: "下斜臥推", bodyPart: .chest, imageName: "下斜臥推"),
            Exercise(name: "蝴蝶機夾胸", bodyPart: .chest, imageName: "蝴蝶機夾胸"),
            Exercise(name: "雙槓臂屈伸", bodyPart: .chest, imageName: "雙槓臂屈伸"),
            Exercise(name: "伏地挺身", bodyPart: .chest, imageName: "伏地挺身")
        ]
        exercises[.back] = [
            Exercise(name: "高位下拉", bodyPart: .back, imageName: "高位下拉"),
            Exercise(name: "坐姿划船", bodyPart: .back, imageName: "坐姿划船"),
            Exercise(name: "俯身划船", bodyPart: .back, imageName: "俯身划船"),
            Exercise(name: "引體向上", bodyPart: .back, imageName: "引體向上")
        ]
        exercises[.legs] = [
            Exercise(name: "深蹲", bodyPart: .legs, imageName: "深蹲"),
            Exercise(name: "保加利亞分腿蹲", bodyPart: .legs, imageName: "保加利亞分腿蹲"),
            Exercise(name: "腿推舉", bodyPart: .legs, imageName: "腿推舉"),
            Exercise(name: "腿彎舉", bodyPart: .legs, imageName: "腿彎舉"),
            Exercise(name: "站姿提踵", bodyPart: .legs, imageName: "站姿提踵")
        ]
        exercises[.shoulders] = [
            Exercise(name: "肩推", bodyPart: .shoulders, imageName: "肩推"),
            Exercise(name: "側平舉", bodyPart: .shoulders, imageName: "側平舉"),
            Exercise(name: "前平舉", bodyPart: .shoulders, imageName: "前平舉"),
            Exercise(name: "繩索面拉", bodyPart: .shoulders, imageName: "繩索面拉"),
            Exercise(name: "反向飛鳥", bodyPart: .shoulders, imageName: "反向飛鳥")
        ]
        exercises[.arms] = [
            Exercise(name: "二頭彎舉", bodyPart: .arms, imageName: "二頭彎舉"),
            Exercise(name: "反握下壓", bodyPart: .arms, imageName: "反握下壓"),
            Exercise(name: "仰臥三頭肌伸展", bodyPart: .arms, imageName: "仰臥三頭肌伸展")
        ]
        exercises[.abs] = [
            Exercise(name: "棒式", bodyPart: .abs, imageName: "棒式"),
            Exercise(name: "捲腹", bodyPart: .abs, imageName: "捲腹"),
            Exercise(name: "俄羅斯轉體", bodyPart: .abs, imageName: "俄羅斯轉體"),
            Exercise(name: "懸吊抬腿", bodyPart: .abs, imageName: "懸吊抬腿")
        ]
        exercises[.cardio] = [
            Exercise(name: "跑步機", bodyPart: .cardio, imageName: "跑步機"),
            Exercise(name: "飛輪", bodyPart: .cardio, imageName: "飛輪"),
            Exercise(name: "划船機", bodyPart: .cardio, imageName: "划船機")
        ]
        return exercises
    }()

    var sampleExercises: [Exercise] {
        return Self.predefinedSampleExercises[self] ?? []
    }

    var assetName: String {
        switch self {
        case .chest: return "胸"
        case .back: return "背"
        case .legs: return "腿"
        case .shoulders: return "肩"
        case .arms: return "手"
        case .abs: return "腹肌"
        case .cardio: return "有氧"
        }
    }
}

struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let bodyPart: BodyPart
    var imageName: String?

    init(id: UUID = UUID(), name: String, bodyPart: BodyPart, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.bodyPart = bodyPart
        self.imageName = imageName
    }
}

struct CartItem: Identifiable, Hashable, Codable {
    let id: UUID
    var exercise: Exercise
    var sets: Int
    var reps: Int
    var isCompleted: Bool
    // 有氧專用：時間（分鐘），非有氧為 nil
    var durationMinutes: Int?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: Int = 3,
        reps: Int = 10,
        isCompleted: Bool = false,
        durationMinutes: Int? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.isCompleted = isCompleted
        self.durationMinutes = durationMinutes
    }
}

// MARK: - ViewModel (EnvironmentObject)

final class WorkoutManager: ObservableObject {
    @Published var cart: [CartItem] = []

    func addToCart(exercise: Exercise) {
        withAnimation(.spring()) {
            if !cart.contains(where: { $0.exercise.id == exercise.id }) {
                if exercise.bodyPart == .cardio {
                    // 有氧：預設 20 分鐘，組/次設為 0
                    let newItem = CartItem(exercise: exercise, sets: 0, reps: 0, isCompleted: false, durationMinutes: 20)
                    cart.append(newItem)
                } else {
                    let newItem = CartItem(exercise: exercise)
                    cart.append(newItem)
                }
            }
        }
    }

    func clearCart() {
        withAnimation(.easeInOut) {
            cart.removeAll()
        }
    }

    func moveCartItem(fromOffsets source: IndexSet, toOffset destination: Int) {
        cart.move(fromOffsets: source, toOffset: destination)
    }
}

// MARK: - Root

struct ContentView: View {
    @StateObject private var manager = WorkoutManager()

    var body: some View {
        MainTabView()
            .environmentObject(manager)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var manager: WorkoutManager
    @State private var showAddSheet = false

    var body: some View {
        TabView {
            NavigationStack {
                ExerciseBrowserView()
                    .navigationTitle("FitCart")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showAddSheet = true
                            } label: {
                                Label("新增動作", systemImage: "plus.circle.fill")
                            }
                        }
                    }
                    .sheet(isPresented: $showAddSheet) {
                        AddExerciseSheet()
                            .environmentObject(manager)
                    }
            }
            .tabItem {
                Label("瀏覽", systemImage: "square.grid.2x2")
            }

            NavigationStack {
                CartView()
                    .navigationTitle("我的清單")
            }
            .tabItem {
                Label("清單", systemImage: "cart")
            }

            NavigationStack {
                NutritionView()
                    .navigationTitle("檔案與營養")
            }
            .tabItem {
                Label("營養", systemImage: "heart.text.square")
            }
        }
    }
}

// MARK: - Exercise Browser

struct ExerciseBrowserView: View {
    @EnvironmentObject var manager: WorkoutManager
    @State private var selectedBodyPart: BodyPart? = nil
    @State private var showExercisesSheet: Bool = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(BodyPart.allCases) { part in
                    Button {
                        selectedBodyPart = part
                        showExercisesSheet = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(part.assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            Text(part.rawValue)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showExercisesSheet) {
            if let part = selectedBodyPart {
                ExerciseListView(bodyPart: part)
                    .environmentObject(manager)
            }
        }
    }
}

struct ExerciseListView: View {
    @EnvironmentObject var manager: WorkoutManager
    @Environment(\.dismiss) var dismissSheet
    let bodyPart: BodyPart

    var body: some View {
        NavigationStack {
            List {
                ForEach(bodyPart.sampleExercises) { exercise in
                    let isInCart = manager.cart.contains { $0.exercise.id == exercise.id }

                    HStack(spacing: 12) {
                        if let name = exercise.imageName {
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            Text(exercise.bodyPart.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            manager.addToCart(exercise: exercise)
                        } label: {
                            if isInCart {
                                Label("已加入", systemImage: "checkmark.circle.fill")
                                    .labelStyle(.titleAndIcon)
                            } else {
                                Label("加入", systemImage: "plus.circle.fill")
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isInCart)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(bodyPart.rawValue)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") {
                        dismissSheet()
                    }
                }
            }
        }
    }
}

// MARK: - Add Exercise Sheet (quick picker)

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: WorkoutManager

    @State private var selectedBodyPart: BodyPart = .chest
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationStack {
            Form {
                Section("選擇部位") {
                    Picker("部位", selection: $selectedBodyPart) {
                        ForEach(BodyPart.allCases) { part in
                            Text(part.rawValue).tag(part)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("動作") {
                    Picker("動作", selection: $selectedExercise) {
                        Text("請選擇").tag(Exercise?.none)
                        ForEach(selectedBodyPart.sampleExercises) { exercise in
                            Text(exercise.name).tag(Exercise?.some(exercise))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("新增動作")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("加入") {
                        if let ex = selectedExercise {
                            manager.addToCart(exercise: ex)
                            dismiss()
                        }
                    }
                    .disabled(selectedExercise == nil)
                }
            }
        }
    }
}

// MARK: - Cart View

struct CartView: View {
    @EnvironmentObject var manager: WorkoutManager
    @State private var presentSession: Bool = false

    var body: some View {
        List {
            if manager.cart.isEmpty {
                Section {
                    ContentUnavailableView("清單是空的", systemImage: "cart", description: Text("到瀏覽頁面加入一些訓練吧。"))
                }
            } else {
                ForEach($manager.cart, id: \.id) { $item in
                    CartItemRow(item: $item)
                        .transaction { $0.animation = nil }
                }
                .onDelete(perform: delete)
                .onMove(perform: manager.moveCartItem)
            }
        }
        .animation(nil, value: manager.cart)
        .navigationTitle("我的清單")
        .toolbar { }
        .safeAreaInset(edge: .bottom) {
            HStack {
                EditButton()
                    .buttonStyle(.bordered)

                Spacer()

                Button {
                    presentSession = true
                } label: {
                    Label("開始訓練", systemImage: "play.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(manager.cart.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .fullScreenCover(isPresented: $presentSession) {
            WorkoutSessionView(cartSnapshot: manager.cart) {
                presentSession = false
            }
            .environmentObject(manager)
        }
    }

    private func delete(at offsets: IndexSet) {
        manager.cart.remove(atOffsets: offsets)
    }
}

struct CartItemRow: View {
    @Binding var item: CartItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Toggle(isOn: $item.isCompleted) {
                    VStack(alignment: .leading) {
                        Text(item.exercise.name)
                            .font(.headline)
                        Text(item.exercise.bodyPart.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
            }

            if item.exercise.bodyPart == .cardio {
                // 有氧：只顯示時間（分鐘）
                HStack {
                    Stepper("時間：\(item.durationMinutes ?? 0) 分鐘",
                            value: Binding(
                                get: { item.durationMinutes ?? 0 },
                                set: { item.durationMinutes = max(0, min(300, $0)) }
                            ),
                            in: 0...300)
                }
                .font(.subheadline)
            } else {
                // 非有氧：顯示組數/次數
                HStack(spacing: 16) {
                    Stepper("組數：\(item.sets)", value: $item.sets, in: 0...20)
                    Stepper("次數：\(item.reps)", value: $item.reps, in: 0...100)
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
        .animation(nil, value: item.isCompleted)
        .animation(nil, value: item.sets)
        .animation(nil, value: item.reps)
        .animation(nil, value: item.durationMinutes)
    }
}

// MARK: - Workout Session

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: WorkoutManager

    let cartSnapshot: [CartItem]
    var onFinish: () -> Void

    @State private var currentIndex: Int = 0
    @State private var completedSets: [UUID: Int] = [:]
    @State private var showCompletedSheet: Bool = false

    private var currentItem: CartItem? {
        guard currentIndex >= 0 && currentIndex < cartSnapshot.count else { return nil }
        return cartSnapshot[currentIndex]
    }

    private var allDone: Bool {
        for item in cartSnapshot {
            if item.exercise.bodyPart == .cardio {
                // 有氧：以 durationMinutes 是否 > 0 作為需完成的「一項」，此處先不自動判斷完成
                // 你可以改成以倒數計時完成，或按一次「完成一項」即視為完成
                continue
            } else {
                let done = (completedSets[item.id] ?? 0) >= item.sets
                if !done { return false }
            }
        }
        // 若全部都是有氧，可視需求決定 allDone 規則；此處保持至少有一項且非有氧都完成才算
        return !cartSnapshot.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if let item = currentItem {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(item.exercise.name)
                                .font(.largeTitle).bold()
                            Text(item.exercise.bodyPart.rawValue)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        if let name = item.exercise.imageName {
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 320, maxHeight: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.vertical, 8)
                        }

                        if item.exercise.bodyPart == .cardio {
                            // 有氧：顯示時間
                            VStack(spacing: 8) {
                                Text("時間：\(item.durationMinutes ?? 0) 分鐘")
                                    .font(.title2)
                                Text("點擊下方按鈕可標記此有氧項目完成")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Button {
                                // 將有氧視為完成一項，直接前往下一個
                                advanceToNext()
                            } label: {
                                Label("完成此項目", systemImage: "checkmark.circle.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            // 非有氧：以組數推進
                            let done = completedSets[item.id] ?? 0
                            VStack(spacing: 8) {
                                ProgressView(value: Double(done), total: Double(max(1, item.sets)))
                                    .tint(.green)
                                Text("已完成 \(done) / \(item.sets) 組")
                                    .font(.headline)
                            }

                            Button {
                                completeOneSet(for: item)
                            } label: {
                                Label("完成一組", systemImage: "checkmark.circle.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Spacer()

                        if let next = nextItem(after: item) {
                            VStack(spacing: 4) {
                                Text("下一個")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(next.exercise.name)
                                    .font(.headline)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    .padding()
                } else {
                    ContentUnavailableView("沒有可進行的訓練", systemImage: "checkmark.seal", description: Text("請回到清單新增動作。"))
                }
            }
            .navigationTitle("訓練中")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        endSession()
                    } label: {
                        Label("結束訓練", systemImage: "xmark.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCompletedSheet, onDismiss: {
                endSession()
            }) {
                VStack(spacing: 16) {
                    Text("運動結束")
                        .font(.largeTitle).bold()
                    Text("做得好！所有動作都完成了。")
                        .foregroundStyle(.secondary)
                    Button {
                        showCompletedSheet = false
                    } label: {
                        Label("回到主畫面", systemImage: "house.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding()
                .presentationDetents([.medium])
            }
            .onAppear {
                var dict: [UUID: Int] = [:]
                for item in cartSnapshot where item.exercise.bodyPart != .cardio {
                    dict[item.id] = 0
                }
                completedSets = dict
                advanceIfNeeded()
            }
        }
    }

    private func completeOneSet(for item: CartItem) {
        let currentDone = completedSets[item.id] ?? 0
        let target = max(0, item.sets)
        let newValue = min(currentDone + 1, target)
        completedSets[item.id] = newValue

        if newValue >= target {
            advanceToNext()
        }
    }

    private func advanceToNext() {
        var nextIndex = currentIndex + 1
        while nextIndex < cartSnapshot.count {
            let nextItem = cartSnapshot[nextIndex]
            if nextItem.exercise.bodyPart == .cardio {
                // 有氧：直接可以前進（按下完成此項目時）
                currentIndex = nextIndex
                return
            } else {
                let done = completedSets[nextItem.id] ?? 0
                if done < nextItem.sets {
                    currentIndex = nextIndex
                    return
                }
            }
            nextIndex += 1
        }
        if allDone {
            showCompletedSheet = true
        }
    }

    private func advanceIfNeeded() {
        while let item = currentItem {
            if item.exercise.bodyPart == .cardio {
                // 有氧不以 sets 驅動，自動停留
                break
            } else {
                let done = completedSets[item.id] ?? 0
                if done >= item.sets {
                    currentIndex += 1
                } else {
                    break
                }
            }
        }
        if allDone {
            showCompletedSheet = true
        }
    }

    private func nextItem(after item: CartItem) -> CartItem? {
        guard let idx = cartSnapshot.firstIndex(where: { $0.id == item.id }) else { return nil }
        var j = idx + 1
        while j < cartSnapshot.count {
            let candidate = cartSnapshot[j]
            if candidate.exercise.bodyPart == .cardio {
                return candidate
            } else {
                let done = completedSets[candidate.id] ?? 0
                if done < candidate.sets {
                    return candidate
                }
            }
            j += 1
        }
        return nil
    }

    private func endSession() {
        onFinish()
        dismiss()
    }
}

// MARK: - Nutrition View

enum Gender: String, CaseIterable, Identifiable {
    case male = "男性"
    case female = "女性"
    var id: String { rawValue }
}

struct NutritionView: View {
    @AppStorage("fitcart_height_cm") private var heightCM: String = ""
    @AppStorage("fitcart_weight_kg") private var weightKG: String = ""
    @AppStorage("fitcart_gender") private var genderRaw: String = Gender.male.rawValue

    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -20, to: .now) ?? .now
    @State private var activity: Double = 1.2
    @State private var showInvalidAlert: Bool = false

    private var gender: Gender {
        Gender(rawValue: genderRaw) ?? .male
    }

    private var age: Int {
        let now = Date()
        let comps = Calendar.current.dateComponents([.year], from: birthday, to: now)
        return max(0, comps.year ?? 0)
    }

    private var bmr: Double? {
        guard let h = Double(heightCM), let w = Double(weightKG), age > 0 else { return nil }
        switch gender {
        case .male:
            return 10.0 * w + 6.25 * h - 5.0 * Double(age) + 5.0
        case .female:
            return 10.0 * w + 6.25 * h - 5.0 * Double(age) - 161.0
        }
    }

    private var tdee: Double? {
        guard let bmr else { return nil }
        return bmr * activity
    }

    var body: some View {
        Form {
            Section("個人檔案") {
                Picker("性別", selection: $genderRaw) {
                    ForEach(Gender.allCases) { g in
                        Text(g.rawValue).tag(g.rawValue)
                    }
                }
                DatePicker("生日", selection: $birthday, displayedComponents: .date)
                HStack {
                    Text("年齡")
                    Spacer()
                    Text("\(age) 歲")
                        .foregroundStyle(.secondary)
                }
            }

            Section("身體數據") {
                HStack {
                    Text("身高（公分）")
                    Spacer()
                    TextField("例如 175", text: $heightCM)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                HStack {
                    Text("體重（公斤）")
                    Spacer()
                    TextField("例如 70", text: $weightKG)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
            }

            Section("活動程度") {
                VStack(alignment: .leading, spacing: 8) {
                    Slider(value: $activity, in: 1.2...2.0, step: 0.1)
                    HStack {
                        Text("久坐 1.2")
                        Spacer()
                        Text(String(format: "目前：%.1f", activity))
                        Spacer()
                        Text("高強度 2.0")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Section("結果") {
                HStack {
                    Text("BMR")
                    Spacer()
                    Text(bmr.map { String(format: "%.0f 大卡", $0) } ?? "--")
                        .foregroundStyle(bmr == nil ? .red : .primary)
                }
                HStack {
                    Text("TDEE")
                    Spacer()
                    Text(tdee.map { String(format: "%.0f 大卡", $0) } ?? "--")
                        .foregroundStyle(tdee == nil ? .red : .primary)
                }
                if bmr == nil || tdee == nil {
                    Text("請確認身高、體重與生日皆為合理數值。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button {
                    validateInputs()
                } label: {
                    Label("重新計算", systemImage: "arrow.clockwise.circle.fill")
                }
            }
        }
        .alert("輸入有誤", isPresented: $showInvalidAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("請輸入正確的身高與體重，並設定合理的生日。")
        }
    }

    private func validateInputs() {
        let heightValid = Double(heightCM) ?? -1
        let weightValid = Double(weightKG) ?? -1
        let valid = heightValid > 0 && weightValid > 0 && age > 0 && activity >= 1.2 && activity <= 2.0
        if !valid { showInvalidAlert = true }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
