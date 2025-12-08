import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';

class TrainingProgramScreen extends StatefulWidget {
  const TrainingProgramScreen({super.key});

  @override
  State<TrainingProgramScreen> createState() => _TrainingProgramScreenState();
}

class _TrainingProgramScreenState extends State<TrainingProgramScreen> {
  String selectedProgram = 'Công nghệ thông tin';
  int? expandedCategoryIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchTrainingProgram();
    });
  }

  Map<String, dynamic>? get programData {
    return context.watch<AcademicProvider>().trainingProgram;
  }

  List<String> get programs {
    return programData?.keys.toList() ?? [];
  }

  Map<String, dynamic>? get currentProgramData {
    return programData?[selectedProgram];
  }

  @override
  Widget build(BuildContext context) {
    final data = currentProgramData;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Chương trình đào tạo',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: AnimatedBackground(isDark: isDark)),
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: Text(
                    'Chưa có dữ liệu chương trình đào tạo',
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chương trình đào tạo',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Builder(
                  builder: (ctx) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
                    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);
                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: strokeColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        data.toString(), // Or format better
                        style: TextStyle(
                          color: isDark ? Color.fromRGBO(255,255,255,0.8) : Colors.black87,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    );
                  },
                ),
               ),
             ),
           ),
         ],
       ),
     );
   }
 }
