import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // returns current DateTime (separate function for easier testing/overriding)
  DateTime now() => DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchAnnualPlan();
    });
  }

  String? get annualPlanText {
    return context.watch<AcademicProvider>().annualPlan;
  }

  // parse a single date string in dd/MM/yyyy
  DateTime _parseDate(String s) {
    final parts = s.trim().split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $s');
    }
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  // parse a date or range like "dd/MM/yyyy" or "dd/MM/yyyy - dd/MM/yyyy"
  List<DateTime> _parseRange(String s) {
    final parts = s.split(RegExp(r'\s*[-–—]\s*'));
    final start = _parseDate(parts[0]);
    final end = parts.length > 1 ? _parseDate(parts[1]) : start;
    // normalize to date-only (time 00:00)
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return [startDate, endDate];
  }

  bool _isNowInRange(String dateRange) {
    final range = _parseRange(dateRange);
    final today = now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return !todayDate.isBefore(range[0]) && !todayDate.isAfter(range[1]);
  }

  // --- New fields for auto-scroll and focus ---
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _itemKeys = [];
  int _focusedIndex = -1; // item we scrolled to / highlighted
  bool _hasNow = false; // true when an item contains today's date

  @override
  void initState() {
    super.initState();
    // create keys for each timeline item
    _itemKeys = List.generate(annualPlanText?.length ?? 0, (_) => GlobalKey());

    // after first frame, find the index to focus and scroll to it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineFocusAndScroll();
    });
  }

  void _determineFocusAndScroll() {
    try {
      final today = DateTime(now().year, now().month, now().day);

      // 1) try to find an event that contains today
      for (var i = 0; i < annualPlanText!.length; i++) {
        final r = _parseRange(annualPlanText![i]['date'] as String);
        if (!today.isBefore(r[0]) && !today.isAfter(r[1])) {
          setState(() {
            _focusedIndex = i;
            _hasNow = true;
          });
          _ensureVisible(i);
          return;
        }
      }

      // 2) no exact match: find first event that has an end date >= today (upcoming or covering today)
      for (var i = 0; i < annualPlanText!.length; i++) {
        final r = _parseRange(annualPlanText![i]['date'] as String);
        if (!r[1].isBefore(today)) {
          setState(() {
            _focusedIndex = i;
            _hasNow = false;
          });
          _ensureVisible(i);
          return;
        }
      }

      // 3) all events are before today -> focus last
      setState(() {
        _focusedIndex = annualPlanText!.length - 1;
        _hasNow = false;
      });
      _ensureVisible(_focusedIndex);
    } catch (e) {
      // ignore and don't crash UI
    }
  }

  void _ensureVisible(int index) {
    if (index < 0 || index >= _itemKeys.length) return;
    final ctx = _itemKeys[index].currentContext;
    if (ctx == null) return;
    try {
      Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 400), alignment: 0.15);
    } catch (e) {
      // ignore
    }
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final text = annualPlanText;
    if (text == null || text.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Kế hoạch năm học 2024-2025',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Chưa có dữ liệu kế hoạch',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kế hoạch năm học 2024-2025',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, 0.1),
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String title,
    required Color color,
    required bool isLast,
    required bool isNow,
    bool isFocused = false,
  }) {
    final indicatorSize = isNow ? 20.0 : 16.0;
    final borderColor = isNow ? Colors.greenAccent : Color(0xFF0F172A);
    final shadowColor = isNow
        ? Colors.greenAccent.withAlpha((0.4 * 255).round())
        : color.withAlpha((0.5 * 255).round());

    // subtle highlight for focused item
    final focusedDecoration = isFocused
        ? BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.06)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(255, 255, 255, 0.02),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          )
        : null;

    return IntrinsicHeight(
      child: Container(
        decoration: focusedDecoration,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // visible accent stripe when focused
            Container(
              width: 6,
              height: 56,
              margin: EdgeInsets.only(right: 10, top: 6),
              decoration: BoxDecoration(
                color: isFocused ? Colors.amberAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Timeline indicator
            Column(
              children: [
                // Circle
                Container(
                  width: indicatorSize,
                  height: indicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: borderColor,
                      width: isNow ? 3 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: isNow ? 12 : 8,
                        spreadRadius: isNow ? 2 : 1,
                      ),
                    ],
                  ),
                ),

                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color,
                            color.withAlpha((0.3 * 255).round()),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 16),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date row with optional NOW badge
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            color: isNow ? Colors.greenAccent : color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (isNow) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NOW',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (!isNow && isFocused) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NEAREST',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 6),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
