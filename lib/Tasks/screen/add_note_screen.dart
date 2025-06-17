import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/const/colors.dart';
import 'package:flutter_app1/Tasks/note_service.dart';

class AddnoteScreen extends StatefulWidget {
  const AddnoteScreen({super.key});

  @override
  State<AddnoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddnoteScreen> {
  final typeController = TextEditingController();
  final subtitle = TextEditingController();

  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  int indexx = 0;
  DateTime? startTime;
  DateTime? endTime;
  String? selectedType;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          startTime = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          endTime = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Widget dateTimePicker({required String label, required DateTime? time, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: time == null ? Color(0xffc5c5c5) : custom_green,
              width: 2.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time == null
                    ? label
                    : '${time.toLocal().toString().substring(0, 16)}',
                style: TextStyle(
                  fontSize: 18,
                  color: time == null ? Colors.grey : Colors.black,
                ),
              ),
              Icon(Icons.calendar_today, color: custom_green),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                typeWidget(),
                SizedBox(height: 20),
                subtite_wedgite(),
                SizedBox(height: 20),
                imagess(),
                SizedBox(height: 20),
                dateTimePicker(label: '開始時間', time: startTime, onTap: () => _selectStartDate(context)),
                SizedBox(height: 10),
                dateTimePicker(label: '結束時間', time: endTime, onTap: () => _selectEndDate(context)),
                SizedBox(height: 20),
                button(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: custom_green,
            minimumSize: Size(170, 48),
          ),
          onPressed: () {
            if (typeController.text.isNotEmpty && subtitle.text.isNotEmpty) {
              NoteService().addNote(
                subtitle.text,
                typeController.text,
                indexx,
                startTime,
                endTime,
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('請填寫任務類型與內容')),
              );
            }
          },
          child: Text('新增任務'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size(170, 48),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
      ],
    );
  }

  Container imagess() {
    return Container(
      height: 160,
      child: ListView.builder(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                indexx = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 7 : 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 2,
                    color: indexx == index ? custom_green : Colors.grey,
                  ),
                ),
                width: 140,
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Image.asset('images/${index}.png'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget typeWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: selectedType,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          hint: const Text('請選擇任務類型'),
          items: ['跑步', '一般運動', '其他活動'].map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, style: const TextStyle(fontSize: 18)),
            );
          }).toList(),
          onChanged: (value) {
  setState(() {
    selectedType = value!;
    typeController.text = value;

    // 根據任務類型自動設定圖片 index
    switch (value) {
      case '跑步':
        indexx = 0;
        break;
      case '一般運動':
        indexx = 1;
        break;
      case '其他活動':
        indexx = 2;
        break;
      default:
        indexx = 3;
    }
  });
},

        ),
      ),
    );
  }

  Padding subtite_wedgite() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          maxLines: 3,
          controller: subtitle,
          focusNode: _focusNode2,
          style: TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            hintText: '任務描述',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color(0xffc5c5c5),
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: custom_green,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
