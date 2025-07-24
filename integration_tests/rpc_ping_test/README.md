# RPC Ping Test

## Objective

This test verifies request-response communication in eCAL using the RPC interface.

It validates that a client can successfully call a remote method ("Ping") on the server and receive a valid response.

---

## Test Setup

### Components

| Component       | Role       | Mode         | Method | Request | Expected Response |
|------------------|-----------|--------------|--------|---------|-------------------|
| RPC Server       | Responder | UDP          | Ping   | "PING"  | "PONG"            |
| RPC Client       | Caller    | UDP          | Ping   | "PING"  | "PONG"            |

### Communication

```
+-------------+         Request: "PING"         +-------------+
| RPC Client  | ------------------------------> | RPC Server  |
|             | <------------------------------ |             |
|             |         Response: "PONG"        |             |
+-------------+                                 +-------------+
```

---

## Test Flow

1. Start the RPC Server and wait for incoming calls.
2. The RPC Client connects to the server and issues a `Ping` request.
3. The Server replies with `PONG`.
4. The Client validates the response content.
5. If the response is correct, the client exits with code 0.

---

## Pass Criteria

- Server receives the request and responds with `"PONG"`
- Client receives the response and exits with code `0`

---

## Folder Structure

```
rpc_ping_test/
├── dockerfile/
│   └── Dockerfile
├── robottests/
│   └── rpc_ping_test.robot
├── scripts/
│   ├── build_images.sh
│   └── entrypoint.sh
├── src/
│   ├── rpc_ping_server.cpp
│   └── rpc_ping_client.cpp
└── README.txt
```

---

## Run the Test

```bash
robot robottests/rpc_ping_test.robot
```

---

## Notes

- This test helps verify correct behavior of eCAL RPC.
- The server and client communicate over the topic `rpc_test_service` with method name `Ping`.