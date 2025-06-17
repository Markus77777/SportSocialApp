import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app1/const/colors.dart';
import 'package:flutter_app1/Tasks/screen/add_note_screen.dart';
import 'package:flutter_app1/Tasks/widget/stream_note.dart';
import 'package:flutter_app1/sport/ui/Sporthome_page.dart';

class Todolist extends StatefulWidget {
  const Todolist({super.key});

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      floatingActionButton: Visibility(
        visible: show,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddnoteScreen(),
            ));
          },
          backgroundColor: custom_green,
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              setState(() => show = true);
            } else if (notification.direction == ScrollDirection.reverse) {
              setState(() => show = false);
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
              // 待辦事項 + 開始運動按鈕區塊
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '待辦事項',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 1.0,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 234, 106, 67),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.deepOrange, width: 1.2),
                          ),
                        ),
                        child: const Text(
                          '開始運動',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 待辦事項清單
              SliverToBoxAdapter(child: StreamNote(false)),

              // 已完成區塊
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Text(
                    '已完成',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              // 已完成清單
              SliverToBoxAdapter(child: StreamNote(true)),

              // 底部空間
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
