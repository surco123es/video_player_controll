import 'package:flutter/material.dart';
import 'package:video_player_controll/video_player_controll.dart';

void main() {
  videoPlayerControll.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TapRegion(
        onTapInside: (event) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const PlayerMin();
            },
          ));
        },
        child: const Text(
          'Go Player',
        ));
  }
}

class PlayerMin extends StatefulWidget {
  const PlayerMin({super.key});

  @override
  State<PlayerMin> createState() => _PlayerMinState();
}

class _PlayerMinState extends State<PlayerMin> {
  FormatMedia media = FormatMedia(title: '', indexPlayer: 0, format: [
    ResolutionFormat(
      format: 'mp4',
      resolution: '1080',
      type: TypeFormat.video,
      urlAudio: 'https://nio.ilove-soft.com/media/audio.m4a',
      urlVideo: 'https://nio.ilove-soft.com/media/1080.mp4',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: '720',
      type: TypeFormat.video,
      urlAudio: 'https://nio.ilove-soft.com/media/audio.m4a',
      urlVideo: 'https://nio.ilove-soft.com/media/720.mp4',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: '480',
      type: TypeFormat.video,
      urlAudio: 'https://nio.ilove-soft.com/media/audio.m4a',
      urlVideo: 'https://nio.ilove-soft.com/media/480.mp4',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: '360',
      type: TypeFormat.video,
      urlAudio: 'https://nio.ilove-soft.com/media/audio.m4a',
      urlVideo: 'https://nio.ilove-soft.com/media/360.mp4',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: '240',
      type: TypeFormat.video,
      urlAudio: 'https://nio.ilove-soft.com/media/audio.m4a',
      urlVideo: 'https://nio.ilove-soft.com/media/240.mp4',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: 'm3u8',
      type: TypeFormat.video,
      urlAudio: '',
      urlVideo:
          'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: 'm3u8',
      type: TypeFormat.video,
      urlAudio: '',
      urlVideo:
          'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: 'm3u8',
      type: TypeFormat.video,
      urlAudio: '',
      urlVideo:
          'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: 'm3u8',
      type: TypeFormat.video,
      urlAudio: '',
      urlVideo:
          'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    ),
    ResolutionFormat(
      format: 'mp4',
      resolution: 'm3u8',
      type: TypeFormat.video,
      urlAudio: '',
      urlVideo:
          'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    ),
  ]);
  FormatMedia media2 = FormatMedia(title: '', indexPlayer: 0, format: [
    ResolutionFormat(
      format: 'mp4',
      resolution: '1080',
      type: TypeFormat.video,
      urlAudio: 'https://nio.ilove-soft.com/media/audio.m4a',
      urlVideo: 'https://nio.ilove-soft.com/media/1080.mp4',
    ),
  ]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TapRegion(
              onTapInside: (event) {
                Navigator.pop(context);
              },
              child: const Text('Regresar Atras'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            videoPlayerControll.play(
              media: media,
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
            const Card(
              child: Text('data'),
            ),
          ],
        ),
      ),
    );
  }
}
