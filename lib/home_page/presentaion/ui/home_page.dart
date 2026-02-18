import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rate_me/core/shared/style/app_colors.dart';
import 'package:rate_me/home_page/presentaion/bloc/rate_me_bloc.dart';
import 'package:rate_me/home_page/presentaion/bloc/rate_me_state.dart';
import 'package:rate_me/home_page/presentaion/ui/collapsible_item.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/di.dart';
import '../../../core/shared/constant/app_strings.dart';
import '../../../core/utils/loading_dialog.dart';
import '../../../core/utils/snackbar.dart';
import '../../data/model/home_tasks_Model.dart';
import '../../data/model/task_model.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool subTask = false;
  bool showSubTaskCheck = false;
  bool subTaskCheck = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final TextEditingController _taskNameTextController = TextEditingController();
  String? selectedTask;
  String? selectedSubTaskName;
  String? selectedTaskToDelete;
  String? mainTaskId;
  String? subTaskId;
  int count = 1;
  int min = 1;
  int max = 300;
  List<HomeTasksModel> items = [];
  List<TaskModel> tasksList = [];
  List<TaskModel> tasksMenuList = [];
  List<TaskModel> subTasksList = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _taskNameTextController.dispose();
    super.dispose();
  }

  List<HomeTasksModel> buildTasksTree(List<TaskModel> tasks) {
    final Map<String, List<TaskModel>> childrenMap = {};

    for (var task in tasks) {
      childrenMap.putIfAbsent(task.mainId, () => []);
      childrenMap[task.mainId]!.add(task);
    }

    HomeTasksModel buildNode(TaskModel task) {
      return HomeTasksModel(
        taskId: task.taskId,
        mainId: task.mainId,
        task: task.task,
        rateValue: task.rateValue,
        children:
        childrenMap[task.taskId]?.map((child) => buildNode(child)).toList() ??
            [],
      );
    }

    final roots = tasks.where((t) => t.mainId.isEmpty);
    return roots.map(buildNode).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RateMeCubit>()..getAllTasks(),
      child: BlocConsumer<RateMeCubit, RateMeState>(
        listener: (context, state) {
          if (state is GetTasksLoadingState) {
            showLoading();
          } else if (state is GetTasksErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is GetTasksSuccessState) {
            hideLoading();
            tasksList = state.tasksList;
            tasksMenuList = state.tasksList.where((task) => task.mainId == "").toList();
            items = buildTasksTree(tasksList);
          } else if (state is InsertTaskLoadingState) {
            showLoading();
          } else if (state is InsertTaskErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is InsertTaskSuccessState) {
            hideLoading();
            _taskNameTextController.text = "";
            FocusScope.of(context).unfocus();
            showAppSnackBar(context, AppStrings.success);
          } else if (state is DeleteAllTasksLoadingState) {
            showLoading();
          } else if (state is DeleteAllTasksErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is DeleteAllTasksSuccessState) {
            hideLoading();
            RateMeCubit.get(context).getAllTasks();
          } else if (state is DeleteTaskLoadingState) {
            showLoading();
          } else if (state is DeleteTaskErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is DeleteTaskSuccessState) {
            hideLoading();
            items.removeWhere((task) => task.taskId == selectedTaskToDelete);
            RateMeCubit.get(context).getAllTasks();
          } else if (state is ResetAllTasksLoadingState) {
            showLoading();
          } else if (state is ResetAllTasksErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is ResetAllTasksSuccessState) {
            hideLoading();
            RateMeCubit.get(context).getAllTasks();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.cSurface,
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // Modern Header
                    _buildModernHeader(),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _currentIndex == 0
                            ? _buildHomePage(context)
                            : _currentIndex == 1
                            ? _buildAddTask(context)
                            : _buildAddAlert(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildModernBottomNav(context),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader() {
    final titles = ['المهام', 'إضافة مهمة', 'التنبيهات'];
    final icons = [Icons.assignment_rounded, Icons.add_circle_rounded, Icons.alarm_rounded];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cPrimary, AppColors.cPrimary.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cPrimary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icons[_currentIndex],
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Text(
            titles[_currentIndex],
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildModernNavItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
            index: 0,
            isActive: _currentIndex == 0,
            context: context,
          ),
          _buildModernNavItem(
            icon: Icons.add_box_rounded,
            label: 'إضافة',
            index: 1,
            isActive: _currentIndex == 1,
            context: context,
          ),
          _buildModernNavItem(
            icon: Icons.alarm_on_rounded,
            label: 'تنبيهات',
            index: 2,
            isActive: _currentIndex == 2,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 1) {
            subTask = false;
            showSubTaskCheck = false;
            subTaskCheck = false;
            _taskNameTextController.text = "";
            selectedTask = null;
            selectedSubTaskName = null;
            mainTaskId = null;
            subTaskId = null;
          }
          RateMeCubit.get(context).getAllTasks();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.cPrimary : Colors.grey,
              size: 26.sp,
            ),
            if (isActive) ...[
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: AppColors.cPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return Column(
      children: [
        // Action Buttons
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.sync_rounded,
                label: AppStrings.reload,
                color: AppColors.cPrimary,
                onTap: () => RateMeCubit.get(context).getAllTasks(),
              ),
              _buildActionButton(
                icon: Icons.restart_alt_rounded,
                label: AppStrings.reset,
                color: Colors.orange,
                onTap: () => RateMeCubit.get(context).resetAllTasks(),
              ),
              _buildActionButton(
                icon: Icons.delete_sweep_rounded,
                label: 'حذف الكل',
                color: AppColors.cError,
                onTap: () => _showDeleteAllDialog(context),
              ),
            ],
          ),
        ),

        // Tasks List
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AnimatedOpacity(
                duration: Duration(milliseconds: 300 + (index * 100)),
                opacity: 1.0,
                child: CollapsibleItem(
                  item: items[index],
                  onDelete: () {
                    selectedTaskToDelete = items[index].taskId;
                    RateMeCubit.get(context).deleteTask(items[index].taskId);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Bounceable(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 100.sp,
            color: Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: 20.h),
          Text(
            'لا توجد مهام',
            style: GoogleFonts.cairo(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'ابدأ بإضافة مهمة جديدة',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من حذف جميع المهام؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              RateMeCubit.get(context).deleteAllTasks();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTask(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub Task Toggle
          _buildModernCheckbox(
            value: subTask,
            label: AppStrings.subTask,
            onChanged: (value) {
              setState(() {
                subTask = value!;
                showSubTaskCheck = false;
                subTaskCheck = false;
                subTaskId = null;
              });
              RateMeCubit.get(context).getAllTasks();
            },
          ),

          SizedBox(height: 20.h),

          // Main Task Dropdown
          if (subTask) ...[
            _buildModernDropdown(
              value: selectedTask,
              hint: AppStrings.mainTaskName,
              items: tasksMenuList.map((task) => task.task).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTask = value;
                  mainTaskId = tasksMenuList.firstWhere((task) => task.task == value).taskId;
                  subTasksList = tasksList.where((task) => task.mainId == mainTaskId).toList();
                  subTaskCheck = subTasksList.isNotEmpty;
                  if (!subTaskCheck) subTaskId = null;
                });
              },
            ),
            SizedBox(height: 20.h),
          ],

          // Sub-Sub Task Toggle
          if (subTaskCheck) ...[
            _buildModernCheckbox(
              value: showSubTaskCheck,
              label: AppStrings.subTask,
              onChanged: (value) {
                setState(() {
                  showSubTaskCheck = value!;
                  subTaskId = null;
                });
                RateMeCubit.get(context).getAllTasks();
              },
            ),
            SizedBox(height: 20.h),
          ],

          // Sub Task Dropdown
          if (showSubTaskCheck) ...[
            _buildModernDropdown(
              value: selectedSubTaskName,
              hint: AppStrings.subSubTaskName,
              items: subTasksList.map((task) => task.task).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubTaskName = value;
                  subTaskId = subTasksList.firstWhere((task) => task.task == value).taskId;
                });
              },
            ),
            SizedBox(height: 20.h),
          ],

          // Task Name Input
          _buildModernTextField(
            controller: _taskNameTextController,
            hint: AppStrings.taskName,
            icon: Icons.label_rounded,
          ),

          SizedBox(height: 30.h),

          // Save Button
          Center(
            child: _buildModernButton(
              label: AppStrings.save,
              icon: Icons.done_rounded,
              onTap: () => _saveTask(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCheckbox({
    required bool value,
    required String label,
    required Function(bool?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: value ? AppColors.cPrimary : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.cPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
            onChanged: onChanged,
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: AppColors.cPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.cPrimary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          isDense: false,
        ),
        hint: Text(
          hint,
          style: GoogleFonts.cairo(
            color: Colors.grey,
            fontSize: 16.sp,
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.cPrimary, size: 28.sp),
        selectedItemBuilder: (BuildContext context) {
          return items.map((String item) {
            return Align(
              alignment: Alignment.centerRight,
              child: Text(
                item,
                style: GoogleFonts.cairo(
                  color: AppColors.cPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            );
          }).toList();
        },
        style: GoogleFonts.cairo(
          color: AppColors.cPrimary,
          fontSize: 16.sp,
          height: 1.5,
        ),
        isExpanded: true,
        itemHeight: 60.h,
        menuMaxHeight: 300.h,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                item,
                style: GoogleFonts.cairo(
                  color: AppColors.cPrimary,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.cPrimary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.cairo(
          color: AppColors.cPrimary,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.cPrimary),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.cPrimary, AppColors.cPrimary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cPrimary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask(BuildContext context) {
    if (mainTaskId != null && subTaskId == null) {
      _taskNameTextController.text = "${_taskNameTextController.text} $selectedTask";
    } else if (mainTaskId != null && subTaskId != null) {
      _taskNameTextController.text = "${_taskNameTextController.text} $selectedSubTaskName";
    }

    if (_taskNameTextController.text.trim().isEmpty) return;

    var uuid = const Uuid();
    String id = uuid.v4();

    if (subTask && mainTaskId != null) {
      TaskModel taskModel = TaskModel(
        taskId: id,
        mainId: showSubTaskCheck && subTaskId != null ? subTaskId! : mainTaskId!,
        task: _taskNameTextController.text,
        rateValue: 0,
      );
      RateMeCubit.get(context).insertTask(taskModel);
    } else {
      TaskModel taskModel = TaskModel(
        taskId: id,
        mainId: "",
        task: _taskNameTextController.text,
        rateValue: 0,
      );
      RateMeCubit.get(context).insertTask(taskModel);
    }
  }

  Widget _buildAddAlert(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // Alert Icon
          Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.cPrimary.withOpacity(0.1), AppColors.cPrimary.withOpacity(0.05)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 80.sp,
              color: AppColors.cPrimary,
            ),
          ),

          SizedBox(height: 30.h),

          Text(
            AppStrings.alert,
            style: GoogleFonts.cairo(
              color: AppColors.cPrimary,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 40.h),

          // Timer Selector
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, size: 35.sp),
                  color: count > min ? AppColors.cPrimary : Colors.grey,
                  onPressed: count > min
                      ? () => setState(() => count--)
                      : null,
                ),
                SizedBox(width: 20.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: AppColors.cPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    "$count",
                    style: GoogleFonts.cairo(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 35.sp),
                  color: count < max ? AppColors.cPrimary : Colors.grey,
                  onPressed: count < max
                      ? () => setState(() => count++)
                      : null,
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          Text(
            AppStrings.second,
            style: GoogleFonts.cairo(
              color: Colors.grey,
              fontSize: 18.sp,
            ),
          ),

          SizedBox(height: 50.h),

          // Start Button
          _buildModernButton(
            label: AppStrings.start,
            icon: Icons.play_arrow_rounded,
            onTap: () async {
              final service = FlutterBackgroundService();
              await service.startService();
              service.invoke('setSeconds', {'seconds': count});
            },
          ),

          SizedBox(height: 20.h),

          // Stop Button
          Bounceable(
            onTap: () async {
              final service = FlutterBackgroundService();
              service.invoke('stopService');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.cError, width: 2),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop_rounded, color: AppColors.cError, size: 24.sp),
                  SizedBox(width: 10.w),
                  Text(
                    AppStrings.stop,
                    style: GoogleFonts.cairo(
                      color: AppColors.cError,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
