# Multi Pub/Sub Test

## Objective

This test verifies message delivery in a multi-publisher, multi-subscriber scenario using the same topic.

It ensures that multiple publishers can send concurrently and that all subscribers receive **all messages** correctly across different eCAL transport modes.

---

## Test Setup

### Components

| Component           | Container         | eCAL Mode      | Role              | Message Value |
| ------------------- | ----------------- | ---------------| ------------------| ------------- |
| `multi_publisher`   | `multi_local*`    | all modes      | Publisher 1       | 42            |
| `multi_publisher2`  | `multi_local*`    | all modes      | Publisher 2       | 43            |
| `multi_subscriber`  | `multi_local*`    | all modes      | Subscriber 1      | -             |
| `multi_subscriber2` | `multi_local*`    | all modes      | Subscriber 2      | -             |

> In *network tests*, each component runs in its own container.
> In *local tests*, all components run in a shared container.

### Communication Structure

1. In Local mode:

```
+-----------------------------------------------------+
| Container: multi_local_tcp (or udp/shm)             |
|                                                     |
|  +----------------+         +----------------+      |
|  | multi_publisher (42)     | multi_publisher2 (43) |
|  +----------------+         +----------------+      |
|          |                           |              |
|          +----------- Topic ---------+              |
|                      |                              |
|        +--------------------------+                 |
|        | multi_subscriber         |                 |
|        | multi_subscriber2        |                 |
|        +--------------------------+                 |
+----------------------------------------------------+

```

2. In Network mode:
```
+------------------+     +------------------+     +------------------+     +------------------+
| Container: pub1  |     | Container: pub2  |     | Container: sub1  |     | Container: sub2  |
|                  |     |                  |     |                  |     |                  |
| multi_publisher  |     | multi_publisher2 |     | multi_subscriber |     | multi_subscriber2|
| (sends 42)       |     | (sends 43)       |     | (receives both)  |     | (receives both)  |
+--------+---------+     +---------+--------+     +--------+---------+     +---------+--------+
         \                     /                         |                          |
          \                   /                          |                          |
           +------ Shared Topic on Docker Network ------ +--------------------------+
```
---

## Test Flow

1. Two publishers send messages with values 42 and 43, respectively.
2. Two subscribers listen on the same topic and must receive messages from **both publishers**.
3. This is repeated across all eCAL transport modes:
   * `local_shm`, `local_udp`, `local_tcp`
   * `network_udp`, `network_tcp`
4. Each subscriber logs the number of received messages.

---

## Pass Conditions

* Each subscriber exits with code `0`.
* Each subscriber receives:
  - **10 messages with value 42**
  - **10 messages with value 43**
* No connection errors or missing messages.

---

## Folder Structure

```
multi_pub_sub/
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── src/
│   ├── multi_publisher.cpp
│   ├── multi_publisher2.cpp
│   ├── multi_subscriber.cpp
│   └── multi_subscriber2.cpp
├── robottests/
│   └── multi_pub_sub.robot
├── Dockerfile
└── README.md
```

---

## Running the Test

```bash
robot robottests/multi_pub_sub.robot
```

---

## Why This Test Is Important

Many real-world systems use multiple data sources and multiple subscribers on shared topics.

This test ensures that:
- eCAL handles **concurrent publishing** correctly.
- Subscribers **don't miss messages** from any source.
- Communication remains reliable across **all transport modes**.
