import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuggestDestinationDialog extends StatefulWidget {
  const SuggestDestinationDialog({super.key});

  @override
  State<SuggestDestinationDialog> createState() =>
      _SuggestDestinationDialogState();
}

class _SuggestDestinationDialogState extends State<SuggestDestinationDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController coordinatesController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedType;
  final List<String> types = ['Cultural', 'Natural', 'Religious', 'Adventure'];

  bool _isSubmitting = false;

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate submission delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSubmitting = false);
      Get.back(); // close dialog
      Get.snackbar(
        'Submitted',
        'Your destination suggestion is marked as Pending.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Suggest a New Destination',
                    style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 24),

                // Upload media placeholder
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Upload', 'Media picker coming soon!',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Upload Photos/Videos (Max 3)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.deepPurple.shade200),
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter destination name',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a name'
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: coordinatesController,
                  decoration: const InputDecoration(
                    labelText: 'Coordinates (lat, long)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 27.7172, 85.3240',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter coordinates'
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Select Type',
                    border: OutlineInputBorder(),
                  ),
                  items: types
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedType = val),
                  validator: (val) =>
                      val == null ? 'Please select a type' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Brief description of the destination',
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a description'
                      : null,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Submit Suggestion',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
