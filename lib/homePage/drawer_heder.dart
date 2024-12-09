import 'package:flutter/material.dart';

class AnimatedDrawerHeader extends StatefulWidget {
  final String? _imageUrl;
  final String? accountName;
  final String? accountEmail;

  const AnimatedDrawerHeader({
    super.key,
    required String? imageUrl,
    required this.accountName,
    required this.accountEmail,
  })  : _imageUrl = imageUrl;

  @override
  _AnimatedDrawerHeaderState createState() => _AnimatedDrawerHeaderState();
}

class _AnimatedDrawerHeaderState extends State<AnimatedDrawerHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<Color?> _color3;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _color1 = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);

    _color2 = ColorTween(
      begin: Colors.green,
      end: Colors.purple,
    ).animate(_controller);
    _color3 = ColorTween(
      begin: const Color.fromARGB(255, 84, 76, 175),
      end: const Color.fromARGB(255, 155, 176, 39),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color1.value!, _color2.value!, _color3.value!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 15)),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget._imageUrl != null
                        ? NetworkImage(widget._imageUrl!)
                        : const AssetImage('assets/images/BGicon.png')
                            as ImageProvider,
                    radius: 40,
                  ),
                  const SizedBox(width: 15), // Space between image and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.accountName ?? 'Loading Name...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.accountEmail ?? 'Loading Email...',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
