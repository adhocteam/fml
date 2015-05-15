from glob import glob
import hashlib
import re
import yaml

for f in glob("*.yaml"):
    buf = open(f).read()
    id = hashlib.sha1(buf).hexdigest()
    newbuf = re.sub("(^\s*)(title: .*)", r"\1\2\n\1id: {}".format(id), buf, flags=re.M)
    open(f, 'w').write(newbuf)

    #try:
    #    y = yaml.load(open(f))
    #    assert y["form"]["id"]
    #except yaml.scanner.scannererror as e:
    #    print e
    #    continue
