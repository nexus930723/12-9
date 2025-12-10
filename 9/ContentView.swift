//
//  ContentView.swift
//  Final (FitCart)
//  Created by 陳詠平 on 2025/11/22.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// 身體部位分類（加入：胸、背、腿、肩、手、腹肌、有氧）
enum BodyPart: String, CaseIterable, Identifiable, Codable {
    case chest = "胸"
    case back = "背"
    case legs = "腿"
    case shoulders = "肩"
    case arms = "手"
    case abs = "腹肌"
    case cardio = "有氧"

    var id: String { rawValue }

    // MARK: - 修正範例動作的生成方式以確保 Exercise 的 ID 穩定

    /// 預先定義所有部位的範例動作，確保每次存取時 Exercise 的 ID 都是穩定的。
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

    /// 各部位的範例動作（中文），現在會從預先定義的靜態字典中獲取
    var sampleExercises: [Exercise] {
        return Self.predefinedSampleExercises[self] ?? []
    }

    /// 對應資產圖片名稱（與 rawValue 相同）
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

/// 動作定義（加入可選的圖片名稱）
struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID // Exercise 的 ID 現在是穩定的，因為它們只會被創建一次
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

/// 購物車中的一個訓練項目
struct CartItem: Identifiable, Hashable, Codable {
    let id: UUID
    var exercise: Exercise
    var sets: Int
    var reps: Int
    var isCompleted: Bool

    init(id: UUID = UUID(), exercise: Exercise, sets: Int = 3, reps: Int = 10, isCompleted: Bool = false) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.isCompleted = isCompleted
    }
}

// MARK: - ViewModel (EnvironmentObject)

/// 管理整個 App 的訓練購物車
final class WorkoutManager: ObservableObject {
    @Published var cart: [CartItem] = []

    /// 新增動作到購物車（含動畫）
    func addToCart(exercise: Exercise) {
        withAnimation(.spring()) {
            // 在加入前檢查是否已存在，雖然按鈕會禁用，但這提供一層保障
            if !cart.contains(where: { $0.exercise.id == exercise.id }) {
                let newItem = CartItem(exercise: exercise)
                cart.append(newItem)
            }
        }
    }

    /// 清空購物車
    func clearCart() {
        withAnimation(.easeInOut) {
            cart.removeAll()
        }
    }

    /// 切換完成狀態
    func toggleCompleted(for item: CartItem) {
        if let idx = cart.firstIndex(where: { $0.id == item.id }) {
            cart[idx].isCompleted.toggle()
        }
    }

    /// 更新組數
    func updateSets(for item: CartItem, sets: Int) {
        if let idx = cart.firstIndex(where: { $0.id == item.id }) {
            cart[idx].sets = max(0, sets)
        }
    }

    /// 更新次數
    func updateReps(for item: CartItem, reps: Int) {
        if let idx = cart.firstIndex(where: { $0.id == item.id }) {
            cart[idx].reps = max(0, reps)
        }
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
    @Environment(\.dismiss) var dismissSheet // 使用 @Environment(\.dismiss) 關閉 sheet
    let bodyPart: BodyPart

    var body: some View {
        NavigationStack {
            List {
                ForEach(bodyPart.sampleExercises) { exercise in
                    // 判斷該動作是否已在購物車中
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
                            // 根據是否在購物車中，改變按鈕的文字和圖示
                            if isInCart {
                                Label("已加入", systemImage: "checkmark.circle.fill")
                                    .labelStyle(.titleAndIcon)
                            } else {
                                Label("加入", systemImage: "plus.circle.fill")
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        // 當動作已在購物車中時，禁用按鈕
                        .disabled(isInCart)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(bodyPart.rawValue)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") {
                        dismissSheet() // 使用 dismissSheet() 關閉 sheet
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
    @State private var showClearAlert: Bool = false
    @State private var showFinishAlert: Bool = false

    var body: some View {
        VStack {
            if manager.cart.isEmpty {
                ContentUnavailableView("清單是空的", systemImage: "cart", description: Text("到瀏覽頁面加入一些訓練吧。"))
            } else {
                List {
                    ForEach(manager.cart) { item in
                        CartItemRow(item: item)
                    }
                    .onDelete(perform: delete)
                }
            }

            HStack {
                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Label("清空清單", systemImage: "trash")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    showFinishAlert = true
                } label: {
                    Label("完成訓練", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .alert("要清除所有項目嗎？", isPresented: $showClearAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) { manager.clearCart() }
        } message: {
            Text("這會移除清單中的所有動作。")
        }
        .alert("太棒了！", isPresented: $showFinishAlert) {
            Button("OK") {}
        } message: {
            Text("訓練完成！🎉\n\n// TODO: 加入彩帶動畫")
        }
    }

    private func delete(at offsets: IndexSet) {
        manager.cart.remove(atOffsets: offsets)
    }
}

struct CartItemRow: View {
    @EnvironmentObject var manager: WorkoutManager
    let item: CartItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Toggle(isOn: Binding(
                    get: { item.isCompleted },
                    set: { _ in manager.toggleCompleted(for: item) }
                )) {
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

            HStack(spacing: 16) {
                Stepper("組數：\(item.sets)", value: Binding(
                    get: { item.sets },
                    set: { manager.updateSets(for: item, sets: $0) }
                ), in: 0...20)

                Stepper("次數：\(item.reps)", value: Binding(
                    get: { item.reps },
                    set: { manager.updateReps(for: item, reps: $0) }
                ), in: 0...100)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Nutrition View

enum Gender: String, CaseIterable, Identifiable {
    case male = "男性"
    case female = "女性"
    var id: String { rawValue }
}

struct NutritionView: View {
    // 持久化資料
    @AppStorage("fitcart_height_cm") private var heightCM: String = ""
    @AppStorage("fitcart_weight_kg") private var weightKG: String = ""
    @AppStorage("fitcart_gender") private var genderRaw: String = Gender.male.rawValue

    // 非持久化但由使用者控制
    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -20, to: .now) ?? .now
    @State private var activity: Double = 1.2 // 1.2 - 2.0
    @State private var showInvalidAlert: Bool = false

    private var gender: Gender {
        Gender(rawValue: genderRaw) ?? .male
    }

    // 由生日計算年齡
    private var age: Int {
        let now = Date()
        let comps = Calendar.current.dateComponents([.year], from: birthday, to: now)
        return max(0, comps.year ?? 0)
    }

    // 基礎代謝率（Mifflin-St Jeor）
    private var bmr: Double? {
        guard let h = Double(heightCM), let w = Double(weightKG), age > 0 else { return nil }
        switch gender {
        case .male:
            return 10.0 * w + 6.25 * h - 5.0 * Double(age) + 5.0
        case .female:
            return 10.0 * w + 6.25 * h - 5.0 * Double(age) - 161.0
        }
    }

    // 總消耗熱量 = BMR * 活動係數
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
