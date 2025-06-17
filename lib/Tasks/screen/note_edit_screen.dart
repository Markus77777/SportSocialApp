import 'package:flutter/material.dart';
import 'package:flutter_app1/const/colors.dart';
import 'package:flutter_app1/Tasks/note_service.dart';
import 'package:flutter_app1/Tasks/task_model.dart';

class NoteEditScreen extends StatefulWidget {
  final Note _note;
  NoteEditScreen(this._note, {super.key});

  @override
  State<NoteEditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<NoteEditScreen> {
  TextEditingController? typeController;
  TextEditingController? subtitleController;

  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  int indexx = 0;
  DateTime? startTime;
  DateTime? endTime;

  final List<String> taskTypes = ['跑步', '一般運動', '其他活動'];
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget._note.type;
    subtitleController = TextEditingController(text: widget._note.subtitle);
    indexx = widget._note.image;
    startTime = widget._note.startTime;
    endTime = widget._note.endTime;
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startTime ?? DateTime.now() : endTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? startTime ?? DateTime.now() : endTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          final fullDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          if (isStart) {
            startTime = fullDate;
          } else {
            endTime = fullDate;
          }
        });
      }
    }
  }

  Widget dateTimePicker(String label, DateTime? time, VoidCallback onTap) {
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
                time == null ? label : '${time.toLocal().toString().substring(0, 16)}',
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
                typeDropdown(),
                SizedBox(height: 20),
                subtitleWidget(),
                SizedBox(height: 20),
                imagess(),
                SizedBox(height: 20),
                dateTimePicker('開始時間', startTime, () => _selectDateTime(isStart: true)),
                SizedBox(height: 10),
                dateTimePicker('結束時間', endTime, () => _selectDateTime(isStart: false)),
                SizedBox(height: 20),
                button()
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
          onPressed: () async {
            if ((selectedType ?? '').isNotEmpty && subtitleController!.text.isNotEmpty) {
              await NoteService().updateNote(
                widget._note.id,
                indexx,
                selectedType!,
                subtitleController!.text,
                startTime,
                endTime,
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('請填寫任務類型與描述')),
              );
            }
          },
          child: Text('儲存任務'),
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

  Widget typeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: custom_green, width: 2.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedType,
            items: taskTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value;
              });
            },
            hint: Text('選擇任務類型'),
          ),
        ),
      ),
    );
  }

  Padding subtitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          maxLines: 3,
          controller: subtitleController,
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
