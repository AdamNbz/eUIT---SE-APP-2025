# 🏠 Kiến Trúc Trang Chủ Mới (HomePage Architecture)

## 📋 Tổng Quan

Trang chủ đã được xây dựng lại hoàn toàn với thiết kế hiện đại, nhiều hiệu ứng animation và kiến trúc component-based tốt hơn.

## 🎯 Các Tính Năng Chính

### 1. **Animated Background**
- ✅ Gradient Orbs với hiệu ứng pulse
- ✅ Floating Particles di chuyển
- ✅ Grid Pattern overlay
- ✅ Hỗ trợ cả Dark Mode và Light Mode
- 📁 File: `lib/widgets/animated_background.dart`

### 2. **Frosted Glass AppBar**
- ✅ Hiệu ứng kính mờ (Backdrop Filter)
- ✅ Hiển thị Avatar, Tên, MSSV
- ✅ Badge thông báo với số lượng
- ✅ Responsive và trong suốt
- 📁 File: `lib/widgets/frosted_glass_appbar.dart`

### 3. **Frosted Glass Bottom Navigation Bar**
- ✅ 5 mục điều hướng với icons
- ✅ Hiệu ứng kính mờ
- ✅ Animation khi chuyển tab
- ✅ Gradient cho item được chọn
- 📁 File: `lib/widgets/frosted_glass_bottom_bar.dart`

### 4. **Next Schedule Card**
- ✅ Gradient background với animated orb
- ✅ Hiển thị: Thời gian, Mã MH, Tên MH, Phòng, GV
- ✅ Countdown timer
- ✅ Border và shadow với gradient
- ✅ Fade-in, slide animations với flutter_animate
- 📁 File: `lib/widgets/next_schedule_card.dart`

### 5. **Quick Action Buttons**
- ✅ 8 nút thao tác nhanh với gradient
- ✅ Scale animation khi nhấn
- ✅ Shimmer effect
- ✅ Support cả icon và text icon (ví dụ: "P" cho Gửi xe)
- 📁 File: `lib/widgets/quick_action_button.dart`

### 6. **Notification Cards**
- ✅ Hiển thị title, body, time
- ✅ Unread indicator với pulse animation
- ✅ Gradient border cho thông báo chưa đọc
- ✅ Staggered animation (cascade effect)
- 📁 File: `lib/widgets/notification_card.dart`

### 7. **Info Cards (Thẻ SV & GPA)**
- ✅ Gradient icon container
- ✅ Responsive layout
- ✅ Slide-in animation
- 📁 File: `lib/widgets/info_card.dart`

### 8. **Section Headers**
- ✅ Title với trailing icon button
- ✅ Fade-in và slide animations
- 📁 File: `lib/widgets/section_header.dart`

## 🏗️ Cấu Trúc Component

```
MainScreen (main_screen.dart)
├── FrostedGlassAppBar
├── Body: PageView/IndexedStack
│   └── HomeScreen (home_screen.dart)
│       ├── AnimatedBackground
│       ├── RefreshIndicator
│       └── SingleChildScrollView
│           ├── Welcome Header
│           ├── Next Schedule Card
│           ├── Info Cards Row (Thẻ SV & GPA)
│           ├── Quick Actions Grid
│           └── Notifications List
└── FrostedGlassBottomBar
```

## 🎨 Theme & Colors

### Dark Mode
- Background: `#0f172a`
- Card: `#1e293b`
- Text: `white`
- Secondary Text: `#CBD5E1`

### Light Mode
- Background: Gradient `#5B9BF3` → `#6B7FE8` → `#9B7FE8`
- Card: `#F8FAFC`
- Text: `#0f172a`
- Secondary Text: `#64748B`

### Accent Colors
- Primary Blue: `#2F6BFF`
- Light Blue: `#4D7FFF`
- Dark Blue: `#1A4FCC`
- Error: `#EF4444`
- Success: `#10B981`

## 📦 Dependencies Đã Sử Dụng

```yaml
dependencies:
  flutter_animate: ^4.5.0  # Animations
  shimmer: ^3.0.0          # Skeleton loading
  provider: ^6.1.2         # State management
  flutter_svg: ^2.0.7      # SVG support
```

## 🔄 State Management

### HomeProvider (`lib/providers/home_provider.dart`)

```dart
class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  ScheduleItem _nextSchedule;
  List<NotificationItem> _notifications;
  List<QuickAction> _quickActions;
  
  // Getters
  bool get isLoading;
  ScheduleItem get nextSchedule;
  List<NotificationItem> get notifications;
  List<QuickAction> get quickActions;
}
```

## 🎭 Animation Effects

### 1. **Flutter Animate Package**
- `.fadeIn()` - Fade in effect
- `.slideX()` - Slide horizontal
- `.slideY()` - Slide vertical
- `.scale()` - Scale transformation
- `.shimmer()` - Shimmer effect
- `.then()` - Chain animations

### 2. **Custom Animations**
- Scale animation khi nhấn button (AnimationController)
- Pulse animation cho gradient orbs
- Floating particles animation
- Blinking unread indicator

## 📱 Responsive Design

- ✅ SafeArea cho tất cả screens
- ✅ Wrap cho Quick Actions Grid
- ✅ SingleChildScrollView với BouncingScrollPhysics
- ✅ RefreshIndicator cho pull-to-refresh
- ✅ AutomaticKeepAliveClientMixin để giữ state khi chuyển tab

## 🔮 Shimmer Loading

Skeleton screens hiển thị khi `isLoading = true`:
- Welcome header placeholder
- Schedule card placeholder
- Info cards placeholders
- Quick actions grid placeholders

## 🚀 Performance Optimization

### 1. **AutomaticKeepAliveClientMixin**
```dart
class _HomeScreenState extends State<HomeScreen> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}
```
Giữ state của HomeScreen khi chuyển tab, tránh rebuild không cần thiết.

### 2. **Const Constructors**
Sử dụng `const` cho các widget không thay đổi để tối ưu performance.

### 3. **AnimationController Dispose**
Luôn dispose controllers trong `dispose()` method.

## 📝 TODO List

### Chức năng cần hoàn thiện:
- [ ] Kết nối API thực tế cho dữ liệu
- [ ] Implement Student Card Modal với barcode
- [ ] Implement Settings Screen
- [ ] Implement Notification Panel overlay
- [ ] Navigate to full schedule screen
- [ ] Navigate to academic results
- [ ] Handle quick action taps
- [ ] Implement pull-to-refresh logic
- [ ] Add User Provider cho thông tin user
- [ ] Localization cho tất cả strings
- [ ] Unit tests cho widgets
- [ ] Integration tests cho user flows

### Cải tiến UI/UX:
- [ ] Haptic feedback khi tap
- [ ] Sound effects (tùy chọn)
- [ ] Hero animations giữa screens
- [ ] Swipe gestures cho cards
- [ ] Dark/Light mode toggle animation
- [ ] Customizable Quick Actions
- [ ] Filter/Search notifications
- [ ] Calendar view integration

## 🎓 Best Practices Đã Áp Dụng

1. ✅ **Separation of Concerns**: Widget riêng biệt cho từng component
2. ✅ **Reusable Components**: Tất cả widgets có thể tái sử dụng
3. ✅ **Type Safety**: Sử dụng models cho data
4. ✅ **State Management**: Provider pattern
5. ✅ **Responsive Design**: Hỗ trợ nhiều kích thước màn hình
6. ✅ **Accessibility**: Semantic labels và contrast tốt
7. ✅ **Performance**: const, dispose, keepAlive
8. ✅ **Documentation**: Comments và structure rõ ràng

## 🎨 Design System

### Spacing
- Tiny: 4px
- Small: 8px
- Medium: 12px
- Large: 16px
- XLarge: 20px
- XXLarge: 24px
- Huge: 32px

### Border Radius
- Small: 12px
- Medium: 16px
- Large: 20px
- XLarge: 24px

### Shadows
- Card: blurRadius 10-12, offset (0, 4)
- Button: blurRadius 8, offset (0, 2)
- Glow: blurRadius 20, spreadRadius 2

## 📸 Screenshots

> TODO: Thêm screenshots của Light Mode và Dark Mode

## 🤝 Contributing

Khi thêm features mới:
1. Tạo widget riêng trong `lib/widgets/`
2. Update models nếu cần trong `lib/models/`
3. Update provider trong `lib/providers/`
4. Add localization keys trong `lib/utils/app_localizations.dart`
5. Update documentation này

---

**Version:** 1.0.0  
**Last Updated:** November 13, 2025  
**Maintainer:** Development Team

