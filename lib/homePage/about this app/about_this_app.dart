import 'package:flutter/material.dart';
import 'package:ssgi/reusableWidgets/reusable_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutThisApp extends StatefulWidget {
  const AboutThisApp({super.key});

  @override
  _AboutThisAppState createState() => _AboutThisAppState();
}

class _AboutThisAppState extends State<AboutThisApp>
    with TickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        'About This App',
        IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Hero(
                tag: 'appLogo',
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/images/logo.png',
                    ), 
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: const Column(
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'To',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Space Science And Geo-spatial Institute',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'GSAAS Scheduling System',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(_visible ? 0 : -100, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black), 
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'This app provides a comprehensive platform for managing tasks and enhancing communication, designed with seamless user experience in mind. ',
                          ),
                          TextSpan(
                            text:
                                'It combines powerful task management tools with robust chat functionalities to ensure you stay productive and connected.\n',
                          ),
                          TextSpan(
                            text: 'Core Features\n',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20), 
                          ),
                          TextSpan(
                              text: 'Task Management:\n',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ) 
                              ),
                          TextSpan(
                            text:
                                'Receive and manage tasks assigned by admins, specifically designed to schedule and track satellite operations. Stay organized and on top of your duties with ease.\n',
                          ),
                          TextSpan(
                            text: 'Collaborative Tasks:\n',
                            style: TextStyle(
                                fontWeight: FontWeight
                                    .bold), 
                          ),
                          TextSpan(
                            text:
                                'Share tasks with your team members, and get real-time updates on progress. Perfect for collaborative projects and efficient teamwork.\n',
                          ),
                          TextSpan(
                            text: 'Integrated Chat: \n',
                            style: TextStyle(
                                fontWeight: FontWeight
                                    .bold), 
                          ),
                          TextSpan(
                            text:
                                'Communicate instantly within the app using private and group chats. Share updates, discuss tasks, and send images seamlessly to keep everyone on the same page.\n',
                          ),
                         
                          TextSpan(
                            text: 'Notifications: \n',
                            style: TextStyle(
                                fontWeight: FontWeight
                                    .bold), // Making "Core Features:" bold
                          ),
                          TextSpan(
                            text:
                                'Never miss an important update. Receive notifications even when the app is closed, keeping you informed at all times.\n',
                          ),
                          
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developed By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Arba Minch University internship students',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(_visible ? 0 : 100, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    const Divider(),

                    ListTile(
                      leading: Icon(Icons.support_agent_outlined,
                          color: Colors.blueAccent, size: _visible ? 30 : 20),
                      title: const Text('Telegram Support'),
                      onTap: () => _launchURL('https://t.me/+MaOz79KSXMw3NDI0'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
