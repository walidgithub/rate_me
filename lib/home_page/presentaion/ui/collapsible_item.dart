import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isExpanded = false;

  final List<Color> levelColors = const [
    AppColors.cLevel1,
    AppColors.cLevel2,
    AppColors.cLevel3,
  ];

  final List<LinearGradient> levelGradients = [
    LinearGradient(
      colors: [AppColors.cLevel1, AppColors.cLevel1.withOpacity(0.8)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    LinearGradient(
      colors: [AppColors.cLevel2, AppColors.cLevel2.withOpacity(0.8)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    LinearGradient(
      colors: [AppColors.cLevel3, AppColors.cLevel3.withOpacity(0.8)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
  ];

  @override
  void initState() {
    super.initState();
    count = (widget.item.rateValue / 10).round();
  }

  Color getLevelColor(int depth) {
    return levelColors[depth % levelColors.length];
  }

  LinearGradient getLevelGradient(int depth) {
    return levelGradients[depth % levelGradients.length];
  }

  Color progressStepColor(int progress) {
    if (progress <= 10) return AppColors.cProgressLevel1;
    if (progress <= 20) return AppColors.cProgressLevel2;
    if (progress <= 30) return AppColors.cProgressLevel3;
    if (progress <= 40) return AppColors.cProgressLevel4;
    if (progress <= 50) return AppColors.cProgressLevel5;
    if (progress <= 60) return AppColors.cProgressLevel6;
    if (progress <= 70) return AppColors.cProgressLevel7;
    if (progress <= 80) return AppColors.cProgressLevel8;
    if (progress <= 90) return AppColors.cProgressLevel9;
    return AppColors.cProgressLevel10;
  }

  String getProgressEmoji(int progress) {
    if (progress <= 20) return '🌱';
    if (progress <= 40) return '🌿';
    if (progress <= 60) return '🌳';
    if (progress <= 80) return '⭐';
    return '🏆';
  }

  int count = 0;

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
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is DeleteTaskSuccessState) {
            hideLoading();
            widget.onDelete();
          } else if (state is UpdateTaskLoadingState) {
            // Don't show loading for update
          } else if (state is UpdateTaskErrorState) {
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is UpdateTaskSuccessState) {
            // Success feedback handled by animation
          }
        },
        builder: (context, state) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: getLevelColor(widget.depth).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                decoration: BoxDecoration(
                  gradient: getLevelGradient(widget.depth),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    expansionTileTheme: const ExpansionTileThemeData(
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                    ),
                  ),
                  child: ExpansionTile(
                    onExpansionChanged: (expanded) {
                      setState(() => _isExpanded = expanded);
                    },
                    tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    childrenPadding: EdgeInsets.all(16.w),
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        getProgressEmoji(widget.item.rateValue),
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.task,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.item.children.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${widget.item.children.length}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: LinearProgressIndicator(
                                value: widget.item.rateValue / 100,
                                minHeight: 8.h,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation(
                                  progressStepColor(widget.item.rateValue),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${widget.item.rateValue}%',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: SizedBox(
                      width: 80.w,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.white.withOpacity(0.9),
                              size: 22.sp,
                            ),
                            onPressed: () => _showDeleteDialog(context),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ],
                      ),
                    ),
                    children: [
                      // Counter Section
                      _buildCounterSection(context),

                      if (widget.item.children.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_tree,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'المهام الفرعية',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.h),
                              ...List.generate(widget.item.children.length, (i) {
                                final child = widget.item.children[i];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
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
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounterSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'تقييم التقدم',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCounterButton(
                  icon: Icons.remove_circle,
                  onPressed: count > 0
                      ? () {
                    setState(() {
                      count--;
                      widget.item.rateValue = count * 10;
                    });
                    _updateTask(context);
                  }
                      : null,
                  isEnabled: count > 0,
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressStepColor(widget.item.rateValue),
                        progressStepColor(widget.item.rateValue).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    "$count",
                    style: GoogleFonts.cairo(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                _buildCounterButton(
                  icon: Icons.add_circle,
                  onPressed: count < 10
                      ? () {
                    setState(() {
                      count++;
                      widget.item.rateValue = count * 10;
                    });
                    _updateTask(context);
                  }
                      : null,
                  isEnabled: count < 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isEnabled
              ? getLevelColor(widget.depth).withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? getLevelColor(widget.depth) : Colors.grey,
          size: 32.sp,
        ),
      ),
    );
  }

  void _updateTask(BuildContext context) {
    RateMeCubit.get(context).updateTask(
      TaskModel(
        task: widget.item.task,
        mainId: widget.item.mainId,
        rateValue: count * 10,
        taskId: widget.item.taskId,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.cError, size: 28.sp),
            SizedBox(width: 10.w),
            Text(
              'تأكيد الحذف',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف "${widget.item.task}"؟',
          style: GoogleFonts.cairo(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              RateMeCubit.get(context).deleteTask(widget.item.taskId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
