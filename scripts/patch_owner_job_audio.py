from pathlib import Path

p = Path('lib/pages/job_request_management/job_request_management_widget.dart')
s = p.read_text()

marker = "  Widget _jobCard(FlutterFlowTheme t, Map<String, dynamic> j) {"
if marker not in s:
    raise SystemExit('job card marker not found')

helper = r'''  Widget _ownerAudioSection(String audio) {
    final hasAudio = audio.isNotEmpty && audio != 'null';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasAudio ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasAudio ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Icon(
            hasAudio ? Icons.audiotrack_outlined : Icons.mic_off_outlined,
            size: 28,
            color: hasAudio ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasAudio ? 'ऑडियो नोट' : 'ऑडियो नोट उपलब्ध नहीं है',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: hasAudio ? const Color(0xFF166534) : const Color(0xFF64748B),
              ),
            ),
          ),
          if (hasAudio)
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
          else
            const Text('—', style: TextStyle(fontSize: 22, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

'''
if '_ownerAudioSection(String audio)' not in s:
    s = s.replace(marker, helper + marker, 1)

old = """              Text('तारीख: ${j['job_date'] ?? '-'}   •   समय: ${j['start_time'] ?? '-'}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              SizedBox("""
new = """              Text('तारीख: ${j['job_date'] ?? '-'}   •   समय: ${j['start_time'] ?? '-'}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 10),
              _ownerAudioSection('${j['audio_note'] ?? ''}'.trim()),
              const SizedBox(height: 12),
              SizedBox("""
if old not in s:
    raise SystemExit('job card insertion point not found')
s = s.replace(old, new, 1)
p.write_text(s)
