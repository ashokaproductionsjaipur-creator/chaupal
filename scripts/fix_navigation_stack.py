from pathlib import Path

ROOT = Path('lib/pages')
EXCLUDED = {
    'lib/pages/login',
    'lib/pages/role_selection',
}

changed = []
for path in ROOT.rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    if str(path.parent).replace('\\', '/') in EXCLUDED:
        continue
    new = text.replace('context.goNamed(', 'context.pushNamed(')
    if new != text:
        path.write_text(new, encoding='utf-8')
        changed.append(str(path))

print(f'Updated {len(changed)} page files')
for p in changed:
    print(p)
