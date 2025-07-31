# Subscriber Crash During Message Reception

## Objective

This test verifies that **other components remain stable** even if one subscriber crashes while receiving a large message.

It simulates stress and failure scenarios in **high-throughput** conditions, including **Shared Memory with Zero-Copy**.

---

## Test Setup

### Participants

| Component          | Role                     | Notes                                   |
|--------------------|--------------------------|-----------------------------------------|
| `large_publisher`  | Publishes large messages | ~50MB per message                       |
| `crash_subscriber` | Crashes during reception | Simulates failure 2s after first message|
| `test_subscriber`  | Receives all messages    | Must remain stable and succeed          |

### Variants

- **Standard SHM, UDP, TCP**
- **SHM with Zero-Copy enabled** (experimental)
- **Network UDP, TCP**

Note: UDP Local mode is skipped due to message size limits.

---

## Success Criteria

- `test_subscriber` receives at least 3 messages and exits with code `0`.
- `crash_subscriber` terminates due to simulated crash.
- `large_publisher` continues unaffected.
- In SHM Zero-Copy: publisher/subscriber behavior is stable unless known eCAL limitations occur.

---

## Known Issues

- **Zero-Copy SHM mode**: test failes because of SHM with zero copy mode, which is a known issue in the current implementation. (test is commented out by default).
- UDP local cannot handle 50MB messages.

---

## Folder Structure

```
sub_send_crash/
├── robottests/
│   └── sub_send_crash.robot
├── src/
│   ├── crash_send_subscriber.cpp
│   ├── large_publisher.cpp
│   ├── test_subscriber.cpp
│   ├── zero_copy_pub.cpp
│   └── CMakeLists.txt
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── docker/
│   └── Dockerfile
└── README.txt
```

---

## Run the Test

```bash
robot robottests/sub_send_crash.robot
```

---

## Why It Matters

Testing crash scenarios during large message reception helps ensure system **robustness** and **fault tolerance** in real-world high-throughput communication.