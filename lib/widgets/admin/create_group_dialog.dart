import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';
import '../../theme/app_colors.dart';

class CreateGroupDialog extends StatefulWidget {
  final MarupGroup? group;
  const CreateGroupDialog({super.key, this.group});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _limitController = TextEditingController();
  final _commissionController = TextEditingController();
  final _cycleController = TextEditingController();

  DateTime _drawDate = DateTime.now().add(const Duration(days: 30));
  TimeOfDay _drawTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  GroupType _groupType = GroupType.monthly;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _descController.text = widget.group!.description;
      _amountController.text = widget.group!.contributionAmount.toString();
      _limitController.text = widget.group!.memberLimit.toString();
      _commissionController.text = widget.group!.adminCommission.toString();
      _cycleController.text = widget.group!.totalCycles.toString();
      _drawDate = widget.group!.drawDate;
      _drawTime = TimeOfDay(
        hour: int.parse(widget.group!.drawTime.split(':')[0]),
        minute: int.parse(widget.group!.drawTime.split(':')[1]),
      );
      _startDate = widget.group!.startDate;
      _endDate = widget.group!.endDate;
      _groupType = widget.group!.groupType;
      _isActive = widget.group!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupController>();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.group == null ? 'NEW MARUP GROUP' : 'EDIT MARUP GROUP',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(_nameController, 'Group Name', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(_descController, 'Description', Icons.description_outlined, maxLines: 2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_amountController, 'Contribution', Icons.currency_rupee, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_limitController, 'Limit', Icons.people_outline, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Schedule & Settings', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildDatePicker('Draw Date', _drawDate, (date) => setState(() => _drawDate = date)),
                _buildTimePicker('Draw Time', _drawTime, (time) => setState(() => _drawTime = time)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_cycleController, 'Cycles', Icons.loop, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_commissionController, 'Commission', Icons.percent, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildToggle('Active Status', _isActive, (v) => setState(() => _isActive = v)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final drawTimeString = '${_drawTime.hour.toString().padLeft(2, '0')}:${_drawTime.minute.toString().padLeft(2, '0')}';
                        
                        if (widget.group == null) {
                          controller.createGroup(
                            name: _nameController.text,
                            description: _descController.text,
                            amount: double.parse(_amountController.text),
                            limit: int.parse(_limitController.text),
                            drawDate: _drawDate,
                            drawTime: drawTimeString,
                            type: _groupType,
                            commission: double.tryParse(_commissionController.text) ?? 0,
                            startDate: _startDate,
                            endDate: _endDate,
                            totalCycles: int.tryParse(_cycleController.text) ?? 12,
                          );
                        } else {
                          controller.updateGroup(widget.group!.copyWith(
                            name: _nameController.text,
                            description: _descController.text,
                            contributionAmount: double.parse(_amountController.text),
                            memberLimit: int.parse(_limitController.text),
                            drawDate: _drawDate,
                            drawTime: drawTimeString,
                            groupType: _groupType,
                            adminCommission: double.tryParse(_commissionController.text) ?? 0,
                            isActive: _isActive,
                            totalCycles: int.tryParse(_cycleController.text) ?? 12,
                          ));
                        }
                        Get.back();
                      }
                    },
                    child: Text(widget.group == null ? 'CREATE GROUP' : 'SAVE CHANGES'),
                  ),
                ),
                if (widget.group != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton.icon(
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Delete Group',
                          middleText: 'Are you sure you want to delete this group?',
                          backgroundColor: AppColors.surface,
                          titleStyle: const TextStyle(color: Colors.white),
                          middleTextStyle: const TextStyle(color: Colors.white70),
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            controller.deleteGroup(widget.group!.id);
                            Get.back(); // close dialog
                            Get.back(); // close edit dialog
                          },
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      label: const Text('Delete Group', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.gold, width: 0.5)),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelect) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      subtitle: Text(DateFormat('dd MMMM, yyyy').format(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.calendar_month, color: AppColors.gold, size: 20),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );
        if (d != null) onSelect(d);
      },
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onSelect) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      subtitle: Text(time.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.access_time, color: AppColors.gold, size: 20),
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onSelect(t);
      },
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
