import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/group_controller.dart';
import '../../models/group_model.dart';

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

    return AlertDialog(
      title: Text(widget.group == null ? 'Create Marup Group' : 'Edit Group'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Group Name', hintText: 'e.g. Monthly Savings A'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Contribution (₹)', prefixText: '₹ '),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _limitController,
                        decoration: const InputDecoration(labelText: 'Member Limit'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GroupType>(
                  value: _groupType,
                  decoration: const InputDecoration(labelText: 'Group Type'),
                  items: GroupType.values.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.name.capitalizeFirst!));
                  }).toList(),
                  onChanged: (v) => setState(() => _groupType = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Draw Date', style: TextStyle(fontSize: 12)),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(_drawDate)),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _drawDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) setState(() => _drawDate = date);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Draw Time', style: TextStyle(fontSize: 12)),
                        subtitle: Text(_drawTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: _drawTime);
                          if (time != null) setState(() => _drawTime = time);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cycleController,
                        decoration: const InputDecoration(labelText: 'Total Cycles'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _commissionController,
                        decoration: const InputDecoration(labelText: 'Admin Commission (₹)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active Status'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
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
          child: Text(widget.group == null ? 'Create' : 'Save Changes'),
        ),
      ],
    );
  }
}
