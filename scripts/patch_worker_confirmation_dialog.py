from pathlib import Path

p = Path('lib/pages/worker_job_feed/worker_job_feed_widget.dart')
s = p.read_text(encoding='utf-8')

old_init_baseline = '''  @override
  void initState() {
    super.initState();
    future = _load();
  }
'''

old_init_previous_patch = '''  @override
  void initState() {
    super.initState();
    future = _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPendingConfirmation());
  }
'''

new_init = '''  @override
  void initState() {
    super.initState();
    future = _load();
    _startConfirmationWatcher();
  }

  void _startConfirmationWatcher() {
    Future<void>(() async {
      await Future<void>.delayed(const Duration(seconds: 2));
      while (mounted) {
        await _showPendingConfirmation();
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    });
  }
'''

if old_init_baseline in s:
    s = s.replace(old_init_baseline, new_init, 1)
elif old_init_previous_patch in s:
    s = s.replace(old_init_previous_patch, new_init, 1)
elif '_startConfirmationWatcher()' not in s:
    raise SystemExit('WorkerJobFeed initState marker not found')

# The popup method itself was already added by the first patch. If it is missing,
# stop rather than making a destructive guess at the large UI method.
if '_showPendingConfirmation()' not in s:
    raise SystemExit('Confirmation popup method is missing; restore the approved popup patch first')

p.write_text(s, encoding='utf-8')
