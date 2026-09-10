$ErrorActionPreference = 'Stop'

$p = Join-Path (Get-Location) 'lib/pages/worker_job_feed/worker_job_feed_widget.dart'
if (-not (Test-Path $p)) { throw "Worker job feed file not found: $p" }
$s = Get-Content -Raw -Encoding UTF8 $p

# 1) Track whether the worker explicitly cancelled the confirmation dialog.
if (-not $s.Contains("bool cancelled = false;")) {
  $old = "      bool finalized = false;"
  if (-not $s.Contains($old)) { throw 'Could not find the confirmation state variables.' }
  $s = $s.Replace($old, "      bool finalized = false;`r`n      bool cancelled = false;")
}

# 2) The orange button must explicitly mark FINALIZE before closing the dialog.
if (-not $s.Contains("finalized = true;")) {
  $pattern = "(?s)(onPressed:\s*)\(\)\s*=>\s*Navigator\.pop\(c\),\s*(style:\s*FilledButton\.styleFrom\(\s*backgroundColor:\s*const Color\(0xFFFF8C00\),)"
  $replacement = '$1() {`r`n                finalized = true;`r`n                Navigator.pop(c);`r`n              },`r`n                $2'
  $newS = [regex]::Replace($s, $pattern, $replacement, 1)
  if ($newS -eq $s) { throw 'Could not find the orange worker final-confirm button.' }
  $s = $newS
}

# 3) Add a clearly separate cancel button immediately below the final-confirm area.
if (-not $s.Contains("डील कैंसल करें")) {
  $pattern = "(?s)(\s+const SizedBox\(height: 6\),\s+const Text\('\(काम फाइनल करें\)'.*?\),)"
  $button = @"
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
              ),
"@
  $newS = [regex]::Replace($s, $pattern, '$1' + $button, 1)
  if ($newS -eq $s) { throw 'Could not find the confirmation button area for inserting the cancel button.' }
  $s = $newS
}

# 4) Cancel must call the backend first. This clears every confirmation/finalize condition.
if (-not $s.Contains("'cancel_worker_job_confirmation'")) {
  $anchor = @"
        if (!mounted) return;
        await SupaFlow.client.rpc(
          'finalize_worker_job_confirmation_v2',
          params: {'p_job_id': '${j['job_id']}'},
        );
"@
  $replacement = @"
        if (!mounted) return;
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
        );
"@
  if (-not $s.Contains($anchor)) { throw 'Could not find the finalize RPC block.' }
  $s = $s.Replace($anchor, $replacement)
}

Set-Content -Path $p -Value $s -Encoding UTF8
Write-Host 'OK: worker deal cancel button + cancel RPC flow added.'
Write-Host 'Cancel clears pending_worker_id, pending_final_amount, worker_confirmation_pending and reopens the job.'
