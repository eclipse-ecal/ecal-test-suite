# Subscriber Crash Test

## Objective

Ensure that communication in an eCAL system continues when one of the subscribers crashes.

This test simulates a subscriber failure scenario and checks that other components are unaffected.

---

## Test Setup

### Components

| Component          | Container           | eCAL Mode   | Role                             | Message Value |
|--------------------|---------------------|-------------|----------------------------------|---------------|
| `crash_subscriber` | crash_sub_*         | all modes   | Crashes after receiving messages | -             |
| `test_subscriber`  | test_sub_*          | all modes   | Receives continuously            | 43            |
| `test_publisher`   | test_pub_*          | all modes   | Sends messages continuously      | 43            |

*Optional:* A monitor can track all processes to detect lifecycle events.

---

## Communication Structure

```
         +------------------+
         | test_publisher   | (value = 43)
         +--------+---------+
                  |
         +--------+---------+
         | crash_subscriber | (crashes)
         | test_subscriber  | (stays alive)
         +------------------+
```

---

## Test Flow

1. Start both subscribers and the publisher.
2. `crash_subscriber` receives a few messages and terminates.
3. `test_subscriber` continues receiving data from `test_publisher`.
4. Test completes after 35s.

---

## Pass Criteria

✅ `test_subscriber` receives sufficient messages.  
✅ It exits with code `0`.  
✅ The crash of one subscriber does **not** affect others.  
✅ All containers terminate properly.

---

## Folder Structure

```
sub_crash/
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── src/
│   ├── crash_subscriber.cpp
│   ├── test_subscriber.cpp
│   ├── test_publisher.cpp
│   └── monitoring.cpp (optional)
├── robottests/
│   └── sub_crash.robot
├── Dockerfile
└── README.txt
```

---

## Running the Test

```bash
robot robottests/sub_crash.robot
```

---

## Notes

- This test is useful to validate eCAL's fault isolation.
- Real systems must be able to tolerate isolated component failures.
- Try different transport modes (UDP, TCP, SHM) for comparison.