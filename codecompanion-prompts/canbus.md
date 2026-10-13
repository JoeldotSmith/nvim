---
name: CAN Bus Reverse Engineering
interaction: chat
description: Start a CAN bus reverse-engineering session for ESP32RET/SavvyCAN logs
opts:
  is_slash_cmd: true
  alias: canbus
---

## user

Use the `canbus-reverse-engineering` skill.

Assume my capture setup is:
- Waveshare ESP32-S3-LCD-5B running ESP32RET.
- Connected through the vehicle OBDII port.
- Streaming CAN frames over the local network.
- Mac laptop running SavvyCAN for viewing and CSV export.

Do not start with CANsub discovery or CANsub capture. First locate or ask for the
SavvyCAN CSV/log and any reference source, then follow the skill workflow to
survey IDs, correlate candidates, bitsearch fields, build DBCs, verify the
result, and combine confirmed DBCs when useful.
