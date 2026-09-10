from pathlib import Path

p = Path('lib/pages/job_request_management/job_request_management_widget.dart')
s = p.read_text()

# Add explicit playback state.
old = "  final player = AudioPlayer();\n  bool busy = false;"
new = "  final player = AudioPlayer();\n  bool busy = false;\n  bool audioPlaying = false;"
if "bool audioPlaying = false;" not in s:
    if old not in s:
        raise SystemExit('player state marker not found')
    s = s.replace(old, new, 1)

# Reset state when playback finishes.
old = "  void initState() {\n    super.initState();\n    jobsFuture = _loadJobs();\n    requestsFuture = Future.value(<Map<String, dynamic>>[]);\n  }"
new = "  void initState() {\n    super.initState();\n    player.onPlayerComplete.listen((_) {\n      if (mounted) setState(() => audioPlaying = false);\n    });\n    jobsFuture = _loadJobs();\n    requestsFuture = Future.value(<Map<String, dynamic>>[]);\n  }"
if "player.onPlayerComplete.listen" not in s:
    if old not in s:
        raise SystemExit('initState marker not found')
    s = s.replace(old, new, 1)

# Replace the old silent play helper with explicit start/stop/error handling.
old = """  Future<void> _playAudio(String path) async {
    final url = await _signedJob(path);
    if (url == null) return;
    try {
      await player.play(UrlSource(url));
    } catch (_) {}
  }
"""
new = """  Future<void> _playAudio(String path) async {
    if (audioPlaying) {
      try {
        await player.stop();
      } finally {
        if (mounted) setState(() => audioPlaying = false);
      }
      return;
    }
    final url = await _signedJob(path);
    if (url == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ऑडियो लोड नहीं हो पाया।')),
        );
      }
      return;
    }
    try {
      await player.play(UrlSource(url));
      if (mounted) setState(() => audioPlaying = true);
    } catch (e) {
      if (mounted) {
        setState(() => audioPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ऑडियो चल नहीं पाया: $e')),
        );
      }
    }
  }
"""
if "ऑडियो चल नहीं पाया" not in s:
    if old not in s:
        raise SystemExit('play helper marker not found')
    s = s.replace(old, new, 1)

# Replace the play button with a clear play/stop state and status text.
old = """          if (hasAudio)
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  side: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                ),
                onPressed: () => _playAudio(audio),
                icon: const Icon(Icons.play_arrow_outlined, size: 24),
                label: const Text('सुनें', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            )
"""
new = """          if (hasAudio)
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: audioPlaying ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  side: BorderSide(color: audioPlaying ? const Color(0xFFDC2626) : const Color(0xFF16A34A), width: 1.5),
                ),
                onPressed: () => _playAudio(audio),
                icon: Icon(audioPlaying ? Icons.stop_circle_outlined : Icons.play_arrow_outlined, size: 24),
                label: Text(audioPlaying ? 'रोकें' : 'ऑडियो सुनें', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            )
"""
if "audioPlaying ? 'रोकें' : 'ऑडियो सुनें'" not in s:
    if old not in s:
        raise SystemExit('audio button marker not found')
    s = s.replace(old, new, 1)

# Add a visible status below the control.
old = """          else
            const Text('—', style: TextStyle(fontSize: 22, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
"""
new = """          else
            const Text('—', style: TextStyle(fontSize: 22, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
"""
# No-op: keep the compact card layout; button state itself is the status indicator.

p.write_text(s)
