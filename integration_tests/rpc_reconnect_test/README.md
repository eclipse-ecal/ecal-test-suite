# RPC N:N Test

## Objective

This test verifies that multiple RPC clients can successfully call multiple RPC servers in an eCAL-based setup.

It ensures that all clients can reach all servers and receive valid responses using the "Ping" method over network UDP.

---

## Test Setup

### Components

| Component Type | Count | Role     | Method | Request | Expected Response |
|----------------|-------|----------|--------|---------|-------------------|
| RPC Servers    | 3     | Responder | Ping   | "PING"  | "PONG"            |
| RPC Clients    | 3     | Caller    | Ping   | "PING"  | "PONG"            |

### Communication

```
Each client -> All servers
All servers -> Reply to each client
```

Example:
```
+-----------+    +-----------+
| Client 1  | -> | Server 1  |
| Client 1  | -> | Server 2  |
| Client 1  | -> | Server 3  |
...
| Client 3  | -> | Server 3  |
+-----------+    +-----------+
```

---

## Test Flow

1. Start 3 RPC servers.
2. Start 3 RPC clients after a short delay.
3. Each client sends a "PING" to all known servers.
4. Each server responds with "PONG".
5. Clients verify responses and exit with code 0 if all are received.

---

## Pass Criteria

- Each client receives 3 responses ("PONG") from all servers
- Each client exits with code `0`
- Servers receive and handle one request per client

---

## Folder Structure

```
rpc_n_n_test/
├── docker/
│   └── Dockerfile
├── robottests/
│   └── rpc_n_n_test.robot
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── src/
│   ├── rpc_n_n_client.cpp
│   └── rpc_n_n_server.cpp
└── README.txt
```

---

## Run the Test

```bash
robot robottests/rpc_n_n_test.robot
```

---

## Notes

- This test confirms that multiple clients can simultaneously reach multiple servers using eCAL RPC over UDP.
- It implicitly validates 1:N, N:1, and N:N behavior.