# Publisher Crash Test

## Objective

Verify that eCAL communication continues even if one of the publishers crashes during runtime.

This simulates a failure scenario where a process unexpectedly terminates.

---

## Test Setup

### Components

| Component        | Container           | eCAL Mode   | Role                             | Message Value |
|------------------|---------------------|-------------|----------------------------------|---------------|
| `crash_publisher`| crash_pub_*         | all modes   | Sends few messages, then crashes | 42            |
| `test_publisher` | test_pub_*          | all modes   | Sends messages continuously      | 43            |
| `subscriber`     | sub_*               | all modes   | Receives from both publishers    | -             |

*Optional:* A monitoring process can track component presence and shutdown timing.

---

## Communication Structure

```
         +------------------+         +------------------+
         | crash_publisher  |         |  test_publisher  |
         |  (value = 42)    |         |  (value = 43)    |
         +------------------+         +------------------+
                      \                /
                       \              /
                        \            /
                         \          /
                         +-------------+
                         | subscriber  |
                         +-------------+
```

---

## Test Flow

1. Start subscriber and both publishers.
2. `crash_publisher` sends a few messages and crashes intentionally.
3. `test_publisher` continues to send messages normally.
4. Subscriber continues listening.
5. After ~35s, all containers exit.

---

## Pass Criteria

✅ Subscriber receives enough messages with value 43 **after** crash.  
✅ Subscriber exits with code `0`.  
✅ All containers stop cleanly.  

---

## Folder Structure

```
pub_crash/
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── src/
│   ├── crash_publisher.cpp
│   ├── test_publisher.cpp
│   ├── test_subscriber.cpp
│   └── monitoring.cpp  (optional)
├── robottests/
│   └── pub_crash.robot
├── Dockerfile
└── README.txt
```

---

## Running the Test

```bash
robot robottests/pub_crash.robot
```

---

## Notes

- This test checks robustness of eCAL under partial failure.
- Crashing publisher must not disrupt overall topic delivery.
- Useful for fault-tolerance validation in distributed systems.