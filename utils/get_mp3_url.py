#!/usr/bin/python3

import sys
import urllib3


def get_mp3_url(text):
    l_text = text.replace('\\r\\n', '\n').split('\n')
    for s in l_text:
        if s.find("<a href=") == -1:
            continue

        if s.find(".mp3") == -1:
            continue

        # print(">>> %s\n" %s)
        for e in s.split('>'):
            if e.find("<a href=") != -1:
                print(e.split('"')[-2])


def main(argc, argv):
    if argc != 2:
        sys.stderr.write("Usage: %s <url>\n" % argv[0])
        return 1

    url = argv[1]

    http = urllib3.PoolManager()
    r = http.request('GET', url)
    if r.status != 200:
        sys.stderr.write("FAIL to download %s\n" % url)
        return 1

    get_mp3_url(str(r.data))

    return 0


if __name__ == '__main__':
    sys.exit(main(len(sys.argv), sys.argv))
