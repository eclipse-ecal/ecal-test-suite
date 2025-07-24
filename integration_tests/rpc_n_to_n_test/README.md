# RPC N:N Test

## Objective

This test verifies N:N request-response communication in eCAL using the RPC interface.

It validates that multiple clients can simultaneously call a remote method ("Ping") on multiple servers and receive valid responses.

---

## Test Setup

### Components

| Component Type | Count | Role      | Mode         | Method | Request | Expected Response |
|----------------|-------|-----------|--------------|--------|---------|-------------------|
| RPC Server     | 2     | Responder | UDP (network) | Ping   | "PING"  | "PONG"            |
| RPC Client     | 3     | Caller    | UDP (network) | Ping   | "PING"  | "PONG"            |

### Communication

Each client sends a "PING" to both servers and expects a "PONG" in return:

```
  Client_1   --->   Server_1 (PING -> PONG)
            --->   Server_2 (PING -> PONG)

  Client_2   --->   Server_1 (PING -> PONG)
            --->   Server_2 (PING -> PONG)

  Client_3   --->   Server_1 (PING -> PONG)
            --->   Server_2 (PING -> PONG)
```

---

## Test Flow

1. Start two servers providing a "Ping" method.
2. Start three clients that connect to all servers and call "Ping".
3. Each client waits for all responses (one from each server).
4. Each client exits with code 0 only if it receives all expected "PONG" replies.

---

## Pass Criteria

- All servers respond to all incoming requests with `"PONG"`.
- All clients receive 2 responses and exit with code `0`.

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
│   ├── rpc_n_n_server.cpp
│   └── rpc_n_n_client.cpp
└── README.txt
```

---

## Run the Test

```bash
robot robottests/rpc_n_n_test.robot
```

---

## Notes

- The server and client communicate over the topic `rpc_n_n_service` with method name `Ping`.
- This test helps validate multiple parallel RPC request handling across several components.