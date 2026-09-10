$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
if (-not (Test-Path $p)) { throw "Worker job feed file not found: $p" }
$s = Get-Content -Raw -Encoding UTF8 $p

# 1) Track whether the worker explicitly cancelled the confirmation dialog.
$old = "      bool finalized = false;"
$new = "      bool finalized = false;`r`n      bool cancelled = false;"
if ($s.Contains($old) -and -not $s.Contains("bool cancelled = false;")) {
  $s = $s.Replace($old, $new)
}

# 2) The orange button must explicitly mark FINALIZE before closing the dialog.
$old = """              onPressed: () => Navigator.pop(c),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),"""
$new = """              onPressed: () {
                finalized = true;
                Navigator.pop(c);
              },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),"""
if ($s.Contains($old)) {
  $s = $s.Replace($old, $new)
} elseif (-not $s.Contains("finalized = true;")) {
  throw 'Could not find the worker final-confirm button.'
}

# 3) Add a clearly separate cancel button immediately below the final-confirm button.
$anchor = """              label: const Text('सौदा पक्का करें  →', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 6),
              const Text('(काम फाइनल करें)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),"""
$replacement = """              label: const Text('सौदा पक्का करें  →', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 6),
              const Text('(काम फाइनल करें)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    cancelled = true;
                    Navigator.pop(c);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 22),
                  label: const Text('डील कैंसल करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),"""
if ($s.Contains($anchor) -and -not $s.Contains("डील कैंसल करें")) {
  $s = $s.Replace($anchor, $replacement)
} elseif (-not $s.Contains("डील कैंसल करें")) {
  throw 'Could not find the confirmation button area for inserting the cancel button.'
}

# 4) Cancel must call the backend first. This clears every confirmation/finalize condition.
$anchor = """        if (!mounted) return;
        await SupaFlow.client.rpc(
          'finalize_worker_job_confirmation_v2',
          params: {'p_job_id': '${j['job_id']}'},
        );"""
$replacement = """        if (!mounted) return;
        if (cancelled) {
          await SupaFlow.client.rpc(
            'cancel_worker_job_confirmation',
            params: {'p_job_id': '${j['job_id']}'},
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('डील कैंसल कर दी गई। यह जॉब अब फिर से उपलब्ध है।')),
          );
          setState(() => future = _load());
          return;
        }
        await SupaFlow.client.rpc(
          'finalize_worker_job_confirmation_v2',
          params: {'p_job_id': '${j['job_id']}'},
        );"""
if ($s.Contains($anchor)) {
  $s = $s.Replace($anchor, $replacement)
} elseif (-not $s.Contains("'cancel_worker_job_confirmation'")) {
  throw 'Could not find the finalize RPC block.'
}

Set-Content -Path $p -Value $s -Encoding UTF8
Write-Host 'OK: worker deal cancel button + cancel RPC flow added.'
Write-Host 'Cancel clears pending_worker_id, pending_final_amount, worker_confirmation_pending and reopens the job.'
