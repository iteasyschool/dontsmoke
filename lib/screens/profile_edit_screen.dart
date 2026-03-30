import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  final bool isNewUser;

  const ProfileEditScreen({super.key, this.isNewUser = false});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _cigarettesPerDayController;
  late TextEditingController _costPerPackController;
  late TextEditingController _cigarettesPerPackController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserProfileProvider>();
    final profile = provider.profile;

    _selectedDate = profile?.quitDate ?? DateTime.now();
    _cigarettesPerDayController = TextEditingController(
      text: profile?.cigarettesPerDay.toString() ?? '',
    );
    _costPerPackController = TextEditingController(
      text: profile?.costPerPack.toString() ?? '',
    );
    _cigarettesPerPackController = TextEditingController(
      text: profile?.cigarettesPerPack.toString() ?? '20',
    );
  }

  @override
  void dispose() {
    _cigarettesPerDayController.dispose();
    _costPerPackController.dispose();
    _cigarettesPerPackController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_cigarettesPerDayController.text.isEmpty ||
        _costPerPackController.text.isEmpty ||
        _cigarettesPerPackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    final newProfile = UserProfile(
      id: context.read<UserProfileProvider>().profile?.id,
      quitDate: _selectedDate,
      cigarettesPerDay: int.parse(_cigarettesPerDayController.text),
      costPerPack: int.parse(_costPerPackController.text),
      cigarettesPerPack: int.parse(_cigarettesPerPackController.text),
    );

    final provider = context.read<UserProfileProvider>();

    if (widget.isNewUser) {
      provider.createProfile(newProfile);
    } else {
      provider.updateProfile(newProfile);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0.5,
        shadowColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация о курении',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Дата отказа
              Text(
                'Дата отказа от курения',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Сигареты в день
              Text(
                'Сколько сигарет выкуривали в день',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cigarettesPerDayController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Например: 20',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Стоимость пачки
              Text(
                'Стоимость одной пачки (₽)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _costPerPackController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Например: 300',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Сигареты в пачке
              Text(
                'Сколько сигарет в одной пачке',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cigarettesPerPackController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Например: 20',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Сохранить',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
