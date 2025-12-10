import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rate_me/core/shared/style/app_colors.dart';
import '../../../core/di/di.dart';
import '../../data/model/home_tasks_Model.dart';
import '../../../core/utils/loading_dialog.dart';
import '../../../core/utils/snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rate_me/home_page/presentaion/bloc/rate_me_bloc.dart';
import 'package:rate_me/home_page/presentaion/bloc/rate_me_state.dart';

import '../../data/model/task_model.dart';

class CollapsibleItem extends StatefulWidget {
  final HomeTasksModel item;
  final Function() onDelete;
  final int depth;

  const CollapsibleItem({
    super.key,
    required this.item,
    required this.onDelete,
    this.depth = 0,
  });

  @override
  State<CollapsibleItem> createState() => _CollapsibleItemState();
}

class _CollapsibleItemState extends State<CollapsibleItem> {
  final List<Color> levelColors = const [
    AppColors.cLevel1,
    AppColors.cLevel2,
    AppColors.cLevel3,
  ];

  Color getLevelColor(int depth) {
    return levelColors[depth];
  }

  Color progressStepColor(int progress) {
    if (progress <= 20) return AppColors.cProgressLevel1;
    if (progress <= 40) return AppColors.cProgressLevel2;
    if (progress <= 60) return AppColors.cProgressLevel3;
    if (progress <= 80) return AppColors.cProgressLevel4;
    return AppColors.cProgressLevel5;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RateMeCubit>()..getAllTasks(),
      child: BlocConsumer<RateMeCubit, RateMeState>(
          listener: (context, state) {
            if (state is DeleteTaskLoadingState) {
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
              widget.onDelete();
              // ------------------------------------------------------
            } else if (state is UpdateTaskLoadingState) {
              showLoading();
            } else if (state is UpdateTaskErrorState) {
              hideLoading();
              showAppSnackBar(
                context,
                state.errorMessage,
                type: SnackBarType.error,
              );
            } else if (state is UpdateTaskSuccessState) {
              hideLoading();
            }
          },
          builder: (context, state) {
            return Card(
              color: getLevelColor(widget.depth),
              margin: EdgeInsets.symmetric(vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),

              child: ExpansionTile(
                collapsedBackgroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
                collapsedShape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
                title: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      children: [
                        Text(
                          widget.item.task,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        widget.item.children.isNotEmpty ? SizedBox(width: 10.w,) : SizedBox.shrink(),
                        widget.item.children.isNotEmpty ? Icon(Icons.collections_bookmark_rounded, color: Colors.white,size: 20.w) : SizedBox.shrink()
                      ],
                    )
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    RateMeCubit.get(context).deleteTask(widget.item.taskId);
                  },
                ),

                children: [
                  SizedBox(height: 12.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      int starValue = (i + 1) * 20;

                      return IconButton(
                        icon: Icon(
                          widget.item.rateValue >= starValue
                              ? Icons.star
                              : Icons.star_border,
                          color: widget.item.rateValue >= starValue
                              ? progressStepColor(widget.item.rateValue)
                              : Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.item.rateValue = starValue;
                          });
                          TaskModel taskModel = TaskModel(
                            task: widget.item.task,
                            mainId: widget.item.mainId,
                            rateValue: starValue,
                            taskId: widget.item.taskId
                          );
                          RateMeCubit.get(context).updateTask(taskModel);
                        },
                      );
                    }),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: widget.item.rateValue / 100,
                        minHeight: 10.h,
                        color: progressStepColor(widget.item.rateValue),
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Column(
                    children: List.generate(widget.item.children.length, (i) {
                      final child = widget.item.children[i];

                      return Padding(
                        padding: EdgeInsets.fromLTRB(20.w,0,20.w,0),
                        child: CollapsibleItem(
                          item: child,
                          onDelete: () {
                            setState(() {
                              widget.item.children.removeAt(i);
                            });
                          },
                          depth: widget.depth + 1,
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            );
          }
      ),
    );
  }
}
