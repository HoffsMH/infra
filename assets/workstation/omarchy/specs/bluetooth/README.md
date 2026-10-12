# Bluetooth audio

## Headset reconnect on stream failure

Multipoint headsets (Bose QC Ultra) sometimes refuse the laptop's A2DP
stream after being taken off and put back on, or after switching to
another host and back. The device stays connected and is the default
sink, but no audio plays, and Brave stalls video start waiting on it.
The wireplumber journal shows:

```
Acquire .../fd0 returned error: org.bluez.Error.NotAuthorized
Failure in Bluetooth audio transport /org/bluez/hci1/dev_<MAC>/fd0
```

A card profile bounce (`off` then `a2dp-sink`) does not clear it. A full
`bluetoothctl disconnect` + `connect` does.

`bt-audio-heal.service` (linux-arch, enabled by `bootstrap-omarchy.sh`)
runs `~/bin/bt.audio-heal`, which follows the wireplumber journal and
does that reconnect for any device that logs the failure, at most once
a minute per device, then sends a notification.

Why: the failure is in the headset's multipoint state, not in config
here, so there is no setting that prevents it. Healing costs a few
seconds of silence.

Check it:

```
systemctl --user status bt-audio-heal
journalctl --user -u bt-audio-heal
```
