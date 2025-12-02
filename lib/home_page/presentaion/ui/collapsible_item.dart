import 'package:flutter/material.dart';
import '../../data/model/home_tasks_Model.dart';

class CollapsibleItem extends StatefulWidget {
  final HomeTasksModel item;
  final Function() onDelete;
  final bool isSub;
  final double subColorFactor;

  const CollapsibleItem({
    super.key,
    required this.item,
    required this.onDelete,
    this.isSub = false,
    this.subColorFactor = 0.0,
  });

  @override
  State<CollapsibleItem> createState() => _CollapsibleItemState();
}

class _CollapsibleItemState extends State<CollapsibleItem> {
  // Main task color
  final Color mainColor = const Color(0xFF4A6CF7);

  // Sub task color gradient
  Color subTaskColor(double t) {
    return Color.lerp(
      const Color(0xFF7D8FFF),
      const Color(0xFFAAAAC2),
      t,
    )!;
  }

  // Progress color steps
  Color progressStepColor(int progress) {
    if (progress <= 20) return Colors.red;
    if (progress <= 40) return Colors.orange;
    if (progress <= 60) return Colors.yellow;
    if (progress <= 80) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isSub
          ? subTaskColor(widget.subColorFactor)  // Sub-task gradient color
          : mainColor,                           // Main task solid color
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ExpansionTile(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.item.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),

        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: widget.onDelete,
        ),

        children: [
          const SizedBox(height: 12),

          // ⭐ 5 Stars (each = 20%)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              int starValue = (i + 1) * 20;

              return IconButton(
                icon: Icon(
                  widget.item.progress >= starValue
                      ? Icons.star
                      : Icons.star_border,
                  color: widget.item.progress >= starValue
                      ? Colors.orange
                      : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    widget.item.progress = starValue;
                  });
                },
              );
            }),
          ),

          // 📊 Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: widget.item.progress / 100,
                minHeight: 10,
                color: progressStepColor(widget.item.progress),
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sub-items (recursive)
          Column(
            children: List.generate(widget.item.children.length, (i) {
              final child = widget.item.children[i];

              // Gradient factor based on position
              double t = widget.item.children.length == 1
                  ? 0
                  : i / (widget.item.children.length - 1);

              return Padding(
                padding: const EdgeInsets.only(left: 20),
                child: CollapsibleItem(
                  item: child,
                  onDelete: () {
                    setState(() {
                      widget.item.children.removeAt(i);
                    });
                  },
                  isSub: true,
                  subColorFactor: t,
                ),
              );
            }),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


