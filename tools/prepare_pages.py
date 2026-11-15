#!/usr/bin/env python3
"""Prepare only a GitHub Pages landing page pointing to an approved game host.
This command writes local files. It never pushes or deploys anything.
"""
import argparse
import html
import pathlib
import shutil
import urllib.parse


def prepare(site, output, game_url):
    parsed = urllib.parse.urlsplit(game_url)
    if parsed.scheme != 'https' or not parsed.hostname or parsed.username or parsed.password or parsed.query or parsed.fragment or not parsed.path.endswith('/80_arcade_games/qbert/'):
        raise ValueError('Serve un URL HTTPS senza credenziali, query o frammenti, terminante in /80_arcade_games/qbert/.')
    site = pathlib.Path(site).resolve(strict=True)
    output = pathlib.Path(output).resolve()
    if output.exists():
        raise ValueError('La directory di destinazione deve essere nuova; nessun sito viene sovrascritto.')
    document = (site / 'index.html').read_text()
    if 'href="80_arcade_games/qbert/"' not in document:
        raise ValueError('Link di avvio non trovato nella home.')
    assets = ['arcade.css', 'game-screen.png', 'index.icon.png', 'LICENSE.txt', 'THIRD_PARTY_NOTICES.txt',
              'DEPENDENCY_LICENSES.txt', 'DejaVuSans-LICENSE.txt', 'SOURCE_NOTICE.txt']
    for name in assets:
        if not (site / '80_arcade_games/qbert' / name).is_file():
            raise ValueError('Risorsa richiesta mancante: ' + name)
    target = output / '80_arcade_games/qbert'
    target.mkdir(parents=True)
    (output / 'index.html').write_text(document.replace('href="80_arcade_games/qbert/"', 'href="'+html.escape(game_url, quote=True)+'"'))
    (output / '.nojekyll').touch()
    for name in assets:
        shutil.copyfile(site / '80_arcade_games/qbert' / name, target / name)
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('site', type=pathlib.Path)
    parser.add_argument('output', type=pathlib.Path)
    parser.add_argument('--game-url', required=True)
    args = parser.parse_args()
    try:
        print(prepare(args.site, args.output, args.game_url))
    except (ValueError, FileNotFoundError) as error:
        parser.error(str(error))

if __name__ == '__main__':
    main()
