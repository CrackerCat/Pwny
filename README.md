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

* `Pwny` - Pwny utilities, mostly for generating payloads and encoding arguments.
* `PwnySession` - Wrapper for `HatSploitSession` for Pwny, HatSploit should use it with Pwny payload.

To build payload, you should call `get_payload()`.

```python3
from pwny import Pwny

pwny = Pwny()
payload = pwny.get_payload('linux', 'x64')
```

To encode Pwny command line arguments use `encode_args()`.

```python3
from pwny import Pwny

pwny = Pwny()
args = pwny.encode_args('192.168.1.1', 8888)
```

## Adding Pwny payload

To add Pwny payload to HatSploit you should follow these steps.

* Write a basic HatSploit payload template.
* Import `Pwny` and `PwnySession` and put `Pwny` to `HatSploitPayload` class.
* Set payload parameter `Session` to `PwnySession`.
* Encode payload options with `encode_args()` and put them to `Args` payload parameter.
* Return `get_payload()` as a payload return value.

In `get_payload()` you should put your payload platform and architecture.

```python3
return get_payload(self.details['Platform'],
                   self.details['Architecture'])
```
