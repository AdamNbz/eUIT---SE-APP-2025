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
}
