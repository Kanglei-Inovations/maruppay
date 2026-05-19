import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';
import '../../routes/app_routes.dart';
import './create_group_dialog.dart';

class GroupList extends StatelessWidget {
  final List<MarupGroup> groups;
  const GroupList({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    if (groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text('No Marup groups created yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            onTap: () => Get.toNamed(AppRoutes.adminMembers, arguments: group.id),
            contentPadding: const EdgeInsets.all(16),
            title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(group.description),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoPill(
                      '₹${group.contributionAmount}',
                      Colors.green,
                    ),

                    _infoPill(
                      '${group.totalMembers}/${group.memberLimit} Members',
                      Colors.blue,
                    ),

                    _infoPill(
                      group.groupType.name.capitalizeFirst!,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Next Draw: ${DateFormat('dd MMM').format(group.drawDate)} at ${group.drawTime}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => Get.dialog(CreateGroupDialog(group: group)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, controller, group),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDelete(BuildContext context, GroupController controller, MarupGroup group) {
    Get.defaultDialog(
      title: 'Delete Group',
      middleText: 'Are you sure you want to delete "${group.name}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteGroup(group.id);
        Get.back();
      },
    );
  }
}
