import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameController  = TextEditingController();
  final _bioController   = TextEditingController();
  final _cityController  = TextEditingController();
  final _ageController   = TextEditingController();
  bool   _isSaving       = false;
  String _userInitial    = 'Z';

  final List<String> _allVibes = [
    'Adventure', 'Solo Travel', 'Budget', 'Luxury', 'Backpacking',
    'Culture', 'Food', 'Photography', 'Beach', 'Mountains',
    'Road Trips', 'Wildlife', 'History', 'Nightlife', 'Wellness',
  ];
  final Set<String> _selectedVibes = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getSavedUser();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user['fullName'] ?? '';
        _bioController.text  = user['bio']      ?? '';
        _cityController.text = user['city']     ?? '';
        _ageController.text  = user['age']?.toString() ?? '';
        _userInitial = _nameController.text.isNotEmpty
            ? _nameController.text[0].toUpperCase() : 'Z';
        final savedVibes = user['vibes'];
        if (savedVibes is List) _selectedVibes.addAll(savedVibes.cast<String>());
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final user       = await AuthService.getSavedUser() ?? {};
    user['fullName'] = _nameController.text.trim();
    user['bio']      = _bioController.text.trim();
    user['city']     = _cityController.text.trim();
    user['age']      = int.tryParse(_ageController.text.trim()) ?? 0;
    user['vibes']    = _selectedVibes.toList();
    await AuthService.saveUser(user);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated!'),
        backgroundColor: ZussGoTheme.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      context.pop();
    }
  }

  Widget _field(String label, TextEditingController ctrl, {
    int maxLines = 1, TextInputType? keyboardType,
    String? hint, String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl, maxLines: maxLines,
          keyboardType: keyboardType, validator: validator,
          style: ZussGoTheme.labelBold.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: ZussGoTheme.textMuted, fontSize: 14),
            filled: true, fillColor: ZussGoTheme.bgSecondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.borderDefault)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ZussGoTheme.rose.withValues(alpha: 0.6))),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary)),
                  const SizedBox(width: 16),
                  Text('Edit Profile', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save',
                      style: TextStyle(color: _isSaving ? ZussGoTheme.textMuted : ZussGoTheme.rose, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 88, height: 88,
                              decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(28)),
                              alignment: Alignment.center,
                              child: Text(_userInitial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Playfair Display')),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(color: ZussGoTheme.rose, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _field('Full Name', _nameController, hint: 'Your full name',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
                      _field('City', _cityController, hint: 'Where are you based?'),
                      _field('Age', _ageController, keyboardType: TextInputType.number, hint: 'Your age'),
                      _field('Bio', _bioController, maxLines: 3, hint: 'Tell fellow travellers about yourself...'),

                      // Vibes
                      Text('Travel Vibes', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _allVibes.map((vibe) {
                          final selected = _selectedVibes.contains(vibe);
                          return GestureDetector(
                            onTap: () => setState(() => selected ? _selectedVibes.remove(vibe) : _selectedVibes.add(vibe)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? ZussGoTheme.rose.withValues(alpha: 0.12) : ZussGoTheme.bgSecondary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? ZussGoTheme.rose.withValues(alpha: 0.5) : ZussGoTheme.borderDefault),
                              ),
                              child: Text(vibe, style: TextStyle(fontSize: 13,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected ? ZussGoTheme.rose : ZussGoTheme.textSecondary)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ZussGoTheme.rose,
                            disabledBackgroundColor: ZussGoTheme.rose.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(_isSaving ? 'Saving...' : 'Save Changes',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
