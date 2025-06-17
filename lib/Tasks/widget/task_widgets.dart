import 'package:flutter/material.dart';
import 'package:flutter_app1/const/colors.dart';
import 'package:flutter_app1/Tasks/note_service.dart';
import 'package:flutter_app1/Tasks/task_model.dart';
import 'package:flutter_app1/Tasks/screen/note_edit_screen.dart';
import 'package:flutter_app1/Tasks/screen/task_run_screen.dart';
import 'package:flutter_app1/Tasks/screen/task_sport_screen.dart';
import 'package:flutter_app1/Tasks/screen/task_other_screen.dart';

import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_auth_service.dart';
class Task_Widget extends StatefulWidget {
  final Note _note;
  Task_Widget(this._note, {super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  @override
  Widget build(BuildContext context) {
    bool isDone = widget._note.isDon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GestureDetector(
        onTap: () {
          if (isDone) {
            _navigateToAnalysisPage(widget._note.type);
          }
        },
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                imageee(),
                SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget._note.type,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Checkbox(
                            activeColor: custom_green,
                            value: isDone,
                            onChanged: (value) {
                              setState(() {
                                isDone = !isDone;
                              });
                              NoteService().setDoneStatus(widget._note.id, isDone);
                            },
                          ),
                        ],
                      ),
                      Text(
                        widget._note.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Spacer(),
                      editBotton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget editBotton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: custom_green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Image.asset('images/icon_time.png', height: 20),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    widget._note.startTime != null && widget._note.endTime != null
                        ? '${widget._note.startTime!.toLocal().toString().substring(0, 16)} -\n${widget._note.endTime!.toLocal().toString().substring(0, 16)}'
                        : '未指定時間',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (!widget._note.isDon)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NoteEditScreen(widget._note),
                ));
              },
              child: Container(
                width: 90,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xffE2F6F1),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: Row(
                  children: [
                    Image.asset('images/icon_edit.png'),
                    const SizedBox(width: 8),
                    const Text(
                      '修改',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          if (widget._note.isDon)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildAnalysisButton(widget._note.type),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton(String type) {
    String label;
    Color color;
    IconData icon;

    switch (type) {
      case '跑步':
        label = '分析：心律 / 步數 / 卡路里';
        color = Colors.red.shade100;
        icon = Icons.directions_run;
        break;
      case '一般運動':
        label = '分析：心律 / 卡路里';
        color = Colors.orange.shade100;
        icon = Icons.fitness_center;
        break;
      default:
        label = '分析：心律';
        color = Colors.blue.shade100;
        icon = Icons.favorite;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: () {
          _navigateToAnalysisPage(type);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAnalysisPage(String type) {
    final note = widget._note;
    final auth = FitbitAuthService();

    if (type == '跑步') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskRunScreen(
            startTime: note.startTime!,
            endTime: note.endTime!,
            authService: auth,
          ),
        ),
      );
    } else if (type == '一般運動') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskSportScreen(
            startTime: note.startTime!,
            endTime: note.endTime!,
            authService: auth,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskOtherScreen(
            startTime: note.startTime!,
            endTime: note.endTime!,
            authService: auth,
          ),
        ),
      );
    }
  }

  Widget imageee() {
    return Container(
      height: 130,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('images/${widget._note.image}.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
