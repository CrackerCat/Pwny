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

## Supported targets

* `Linux` - `x64` - `x86` - `armle` - `aarch64` - `mipsle` - `mipsbe` - `make linux`
* `iOS` - `aarch64` - `make apple_ios`
* `macOS` - `x64` - `aarch64` - `make macos`

**NOTE:** Pwny Makefile does not contain cross-compiler!

## Basic usage

To use Pwny and build payloads you should import it to your source.

```python3
from pwny import Pwny
from pwny import PwnySession
```

* `Pwny` - Pwny utilities, mostly for generating payloads and encoding arguments.
* `PwnySession` - Wrapper for `HatSploitSession` for Pwny, HatSploit should use it with Pwny payload.

To get Pwny template, you should call `get_template()`.

```python3
from pwny import Pwny

pwny = Pwny()
template = pwny.get_template('linux', 'x64')
```

To encode Pwny data (`host` and/or `port`) use `encode_data()`.

```python3
from pwny import Pwny

pwny = Pwny()
args = pwny.encode_data(host='127.0.0.1', port=8888)
```

There are two types of Pwny - `reverse_tcp` and `bind_tcp`. To use `bind_tcp` instead of `reverse_tcp`, you should encode only `port` in `encode_data()`.

```python3
from pwny import Pwny

pwny = Pwny()
args = pwny.encode_data(port=8888)
```

## Adding Pwny payload

To add Pwny payload to HatSploit you should follow these steps.

* Write a basic HatSploit payload template.
* Import `Pwny` and `PwnySession` and put `Pwny` to `HatSploitPayload` class.
* Set payload parameter `Session` to `PwnySession`.
* Encode data `host` and/or `port` through `encode_data()` and create offset `{'data': encoded_data}`.
* Return `get_template()` with these offset as a payload return value.

In `get_template()` you should put your payload platform and architecture.

```python3
return get_template(self.details['Platform'], self.details['Architecture']),
       {'data': encoded_data}
```
