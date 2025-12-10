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
import 'package:workmanager/workmanager.dart';
import '../../../core/di/di.dart';
import '../../../core/shared/constant/app_strings.dart';
import '../../../core/utils/loading_dialog.dart';
import '../../../core/utils/snackbar.dart';
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
  String? selectedTask;
  String? selectedTaskToDelete;
  String? mainTaskId;
  int count = 1;
  int min = 1;
  int max = 15;
  List<HomeTasksModel> items = [];
  List<TaskModel> tasksList = [];

  List<HomeTasksModel> buildTasksTree(List<TaskModel> tasks) {
    final Map<String, List<TaskModel>> childrenMap = {};

    // بناء قائمة الأبناء
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
        children: childrenMap[task.taskId]
            ?.map((child) => buildNode(child))
            .toList() ??
            [],
      );
    }

    // استخراج الجذور
    final roots = tasks.where((t) => t.mainId.isEmpty);

    return roots.map(buildNode).toList();
  }

  Future<void> vibrateEveryMinutes(int minutes, String taskName) async {
    await Workmanager().registerPeriodicTask(
      "periodicVibration$minutes",
      taskName,
      frequency: Duration(minutes: minutes),
      inputData: {"minutes": minutes},
    );
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
            showAppSnackBar(
              context,
              state.errorMessage,
              type: SnackBarType.error,
            );
          } else if (state is GetTasksSuccessState) {
            hideLoading();
            tasksList = state.tasksList;
            items = buildTasksTree(tasksList);
            // ------------------------------------------------------
          } else if (state is InsertTaskLoadingState) {
            showLoading();
          } else if (state is InsertTaskErrorState) {
            hideLoading();
            showAppSnackBar(
              context,
              state.errorMessage,
              type: SnackBarType.error,
            );
          } else if (state is InsertTaskSuccessState) {
            hideLoading();
            _taskNameTextController.text = "";
            FocusScope.of(context).unfocus();
            showAppSnackBar(context, AppStrings.success);
            // ------------------------------------------------------
          } else if (state is DeleteAllTasksLoadingState) {
            showLoading();
          } else if (state is DeleteAllTasksErrorState) {
            hideLoading();
            showAppSnackBar(
              context,
              state.errorMessage,
              type: SnackBarType.error,
            );
          } else if (state is DeleteAllTasksSuccessState) {
            hideLoading();
            RateMeCubit.get(context).getAllTasks();
            // ------------------------------------------------------
          } else if (state is DeleteTaskLoadingState) {
            showLoading();
          } else if (state is DeleteTaskErrorState) {
            hideLoading();
            showAppSnackBar(
              context,
              state.errorMessage,
              type: SnackBarType.error,
            );
          } else if (state is DeleteTaskSuccessState) {
            hideLoading();
            items.removeWhere((task) => task.taskId == selectedTaskToDelete);
            RateMeCubit.get(context).getAllTasks();
            // ------------------------------------------------------
          } else if (state is ResetAllTasksLoadingState) {
            showLoading();
          } else if (state is ResetAllTasksErrorState) {
            hideLoading();
            showAppSnackBar(
              context,
              state.errorMessage,
              type: SnackBarType.error,
            );
          } else if (state is ResetAllTasksSuccessState) {
            hideLoading();
            RateMeCubit.get(context).getAllTasks();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _currentIndex == 0
                          ? _buildHomePage(context)
                          : _currentIndex == 1
                          ? _buildAddTask(context)
                          : _buildAddAlert(context),
                    ),
                  ],
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
                    context: context
                  ),
                  _buildNavItem(
                    icon: Icons.add,
                    index: 1,
                    isActive: _currentIndex == 1,
                      context: context
                  ),
                  _buildNavItem(
                    icon: Icons.notifications_active,
                    index: 2,
                    isActive: _currentIndex == 2,
                      context: context
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
    required BuildContext context
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          
          if (index == 1) {
            subTask = false;
            _taskNameTextController.text = "";
            selectedTask = null;
          }
          
          RateMeCubit.get(context).getAllTasks();
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
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

  Widget _buildHomePage(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.cError),
              onPressed: () {
                RateMeCubit.get(context).deleteAllTasks();
              },
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.loop, color: AppColors.cPrimary),
                  onPressed: () {
                    RateMeCubit.get(context).resetAllTasks();
                  },
                ),
                Text(
                  AppStrings.reset,
                  style: TextStyle(color: AppColors.cPrimary, fontSize: 15.sp),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.refresh, color: AppColors.cPrimary),
                  onPressed: () {
                    RateMeCubit.get(context).getAllTasks();
                  },
                ),
                Text(
                  AppStrings.reload,
                  style: TextStyle(color: AppColors.cPrimary, fontSize: 15.sp),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CollapsibleItem(
                item: items[index],
                onDelete: () {
                  // setState(() {
                  //   items.removeAt(index);
                  // });
                  selectedTaskToDelete = items[index].taskId;
                  RateMeCubit.get(context).deleteTask(items[index].taskId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddTask(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
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
                  RateMeCubit.get(context).getAllTasks();
                },
              ),
              Text(
                AppStrings.subTask,
                style: TextStyle(color: AppColors.cPrimary, fontSize: 20.sp),
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
                        AppStrings.mainTaskName,
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
                      items: tasksList.map((task) {
                        return DropdownMenuItem(
                          value: task.task, // ✔ dropdown value
                          child: Text(task.task), // ✔ dropdown display text
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDropdown(() {
                          selectedTask = value;
                          mainTaskId = tasksList.firstWhere((task) {
                            return task.task == value;
                          }).taskId;
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
            style: TextStyle(color: AppColors.cPrimary, fontSize: 20.sp),
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
            onTap: () {
              if (_taskNameTextController.text.trim().isEmpty) {
                return;
              }
              if (subTask && selectedTask == null) {
                setState(() {
                  subTask = false;
                });
                return;
              }
              var uuid = Uuid();
              String id = uuid.v4();
              if (subTask && selectedTask != null) {
                TaskModel taskModel = TaskModel(
                  taskId: id,
                  mainId: mainTaskId!,
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
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
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
      ),
    );
  }

  Widget _buildAddAlert(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          Text(
            AppStrings.alert,
            style: TextStyle(color: AppColors.cPrimary, fontSize: 20.sp),
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
            onTap: () {
              vibrateEveryMinutes(count, "rate_me_vibration");
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
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
      ),
    );
  }
}
