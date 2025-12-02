import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rate_me/core/shared/style/app_colors.dart';
import 'package:rate_me/home_page/presentaion/ui/collapsible_item.dart';

import '../../../core/shared/constant/app_strings.dart';
import '../../data/model/home_tasks_Model.dart';
import '../../data/model/task_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  bool subTask = false;

  final TextEditingController _taskNameTextController = TextEditingController();
  List<String> taskList = ['مهمة', 'مهمة 2', 'مهمة 3'];
  String? selectedTask;
  int count = 1;
  int min = 1;
  int max = 15;
  List<HomeTasksModel> items = [
    HomeTasksModel(
      title: "Main Task 1",
      children: [
        HomeTasksModel(title: "Sub Task 1"),
        HomeTasksModel(
          title: "Sub Task 2",
          children: [
            HomeTasksModel(title: "Sub sub Task 1"),
            HomeTasksModel(title: "Sub sub Task 2"),
          ],
        ),
      ],
    ),
    HomeTasksModel(title: "Main Task 2"),
  ];

  @override
  void initState() {
    selectedTask = taskList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _currentIndex == 0
                      ? _buildHomePage()
                      : _currentIndex == 1
                      ? _buildAddTask()
                      : _buildAddAlert(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(10.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_filled,
              index: 0,
              isActive: _currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.add,
              index: 1,
              isActive: _currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.notifications_active,
              index: 2,
              isActive: _currentIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cPrimary : AppColors.cSurface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cPrimary),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.cSurface : AppColors.cPrimary,
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CollapsibleItem(
                item: items[index],
                onDelete: () {
                  setState(() {
                    items.removeAt(index);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddTask() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: subTask,
              activeColor: Colors.orangeAccent,
              onChanged: (value) {
                setState(() {
                  subTask = value!;
                });
              },
            ),
            Text(
              AppStrings.subTask,
              style: TextStyle(color: AppColors.cPrimary),
            ),
          ],
        ),

        subTask
            ? StatefulBuilder(
                builder: (context, setStateDropdown) {
                  return DropdownButtonFormField<String>(
                    dropdownColor: AppColors.cSurface,
                    initialValue: selectedTask,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: AppColors.cPrimary),
                      ),
                    ),
                    hint: Text(
                      AppStrings.taskName,
                      style: TextStyle(
                        color: AppColors.cPrimary,
                        fontSize: 20.sp,
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.cPrimary,
                    ),
                    style: TextStyle(
                      color: AppColors.cPrimary,
                      fontSize: 20.sp,
                    ),
                    items: taskList.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (value) {
                      setStateDropdown(() {
                        selectedTask = value!;
                      });
                    },
                  );
                },
              )
            : SizedBox.shrink(),

        subTask ? SizedBox(height: 20.h) : SizedBox.shrink(),

        TextField(
          controller: _taskNameTextController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
          decoration: InputDecoration(
            hintText: AppStrings.taskName,
            hintStyle: TextStyle(color: AppColors.cPrimary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.cPrimary),
            ),
          ),
        ),

        SizedBox(height: 20.h),

        Bounceable(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                width: 120.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: AppColors.cPrimary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    AppStrings.save,
                    style: GoogleFonts.poppins(
                      color: AppColors.cSurface,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddAlert() {
    return Column(
      children: [
        Text(
          AppStrings.alert,
          style: TextStyle(color: AppColors.cPrimary, fontSize: 20.sp),
        ),

        SizedBox(height: 20.h),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: count > min
                        ? () {
                            setState(() {
                              count = count - 1;
                            });
                          }
                        : null,
                  ),

                  Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: count < max
                        ? () {
                            setState(() {
                              count = count + 1;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            Text(
              AppStrings.minute,
              style: TextStyle(color: AppColors.cPrimary, fontSize: 20.sp),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        Bounceable(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                width: 120.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: AppColors.cPrimary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    AppStrings.start,
                    style: GoogleFonts.poppins(
                      color: AppColors.cSurface,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
