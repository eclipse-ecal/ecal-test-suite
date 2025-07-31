# Basic Pub/Sub Test

## Objective

This test verifies basic communication in eCAL between a single publisher and a single subscriber.

It focuses on message delivery over all five supported eCAL transport layers.

---

## Test Setup

### Components

| Component     | Role         | Mode       | Message Count | Message Size |
|---------------|--------------|------------|----------------|----------------|
| Publisher     | Sender       | All Modes  | 4 messages     | 0.2 MB         |
| Subscriber    | Receiver     | All Modes  | Receives 4     | 0.2 MB         |

### Communication

```
+-------------+          +--------------+
|  Publisher  |  --->    |  Subscriber  |
+-------------+          +--------------+
         Sends 4 × 0.2MB messages
```

---

## Test Flow

1. The publisher sends 4 messages (0.2 MB each) on one topic.
2. The subscriber listens for 6 seconds.
3. It counts the messages received.
4. If it received exactly 4, it exits with code 0.
5. Otherwise, it exits with code 1.

---

## Pass Criteria

- Subscriber receives all 4 messages  
- Clean exit (code 0)

---

## Folder Structure

```
basic_pub_sub/
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── src/
│   ├── one_publisher.cpp
│   └── one_subscriber.cpp
├── robottests/
│   └── basic_pub_sub.robot
├── Dockerfile
└── README.txt
```

---

## Run the Test

```bash
robot robottests/basic_pub_sub.robot
```

---

## Notes

- This test helps validate buffer sizes and basic transmission logic in all modes.