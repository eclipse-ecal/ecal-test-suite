*** Comments ***
This test verifies whether an eCAL RPC client can recover from a network disconnection
and successfully reconnect to the RPC server.

Setup:
- Client and Server run in separate containers with fixed IPs in the same Docker network.
- The client calls a Ping RPC method once, then we simulate a network failure by
  disconnecting the client from the network.
- After a delay, we reconnect the client and expect it to send a second Ping.
- The client exits with code 0 only if both PING-PONG calls succeed.

*** Settings ***
Library           OperatingSystem
Library           Process
Library           ${CURDIR}/../../lib/DockerLibrary.py
Library           ${CURDIR}/../../lib/GlobalPathsLibrary.py
Suite Setup       Init Test Context

*** Variables ***
${NETWORK}        ecal_rpc_reconnect_net
${BUILD_SCRIPT}   ${EMPTY}
${BASE_IMAGE}     rpc_reconnect_test

${CLIENT_IP}      172.28.0.10
${SERVER_IP}      172.28.0.11

*** Test Cases ***
RPC Reconnect Test
    [Tags]    rpc_reconnect
    Run RPC Reconnect Test
    
RPC Reconnect Test2
    [Tags]    rpc_reconnect
    Run RPC Reconnect Test2

*** Keywords ***
Init Test Context
    Set Test Context    rpc_reconnect_test    rpc_reconnect_test
    ${build}=    Get Build Script Path
    ${args}=     Get Build Script Args
    Set Suite Variable    ${BUILD_SCRIPT}    ${build}

    Create Docker Network With Subnet    ${NETWORK}    172.28.0.0/16
    Log To Console    [SETUP] Building Docker image...
    ${result}=    Run Process    ${BUILD_SCRIPT}    @{args}
    Should Be Equal As Integers    ${result.rc}    0    Failed to build Docker image!
    Sleep    3s

Run RPC Reconnect Test
    Log To Console    \n[INFO] Starting RPC Reconnect Test...

    ${IMAGE}=    Set Variable    ${BASE_IMAGE}_network_udp

    Start Container With IP    rpc_server    ${IMAGE}    server    network_udp    network=${NETWORK}    ip=${SERVER_IP}
    Start Container With IP    rpc_client    ${IMAGE}    client    network_udp    network=${NETWORK}    ip=${CLIENT_IP}

    Sleep    2s
    Disconnect Container From Network    rpc_client    ${NETWORK}
    Sleep    6s
    Reconnect Container To Network With IP    rpc_client    ${NETWORK}    ${CLIENT_IP}
    Sleep    2s

    ${log_cli}=    Get Container Logs    rpc_client
    ${log_srv}=    Get Container Logs    rpc_server

    Log To Console    \n[CONTAINER LOG: CLIENT]\n${log_cli}
    Log To Console    \n[CONTAINER LOG: SERVER]\n${log_srv}
    Log               \n[CONTAINER LOG: CLIENT]\n${log_cli}
    Log               \n[CONTAINER LOG: SERVER]\n${log_srv}

    ${exit_code}=    Wait For Container Exit    rpc_client
    Should Be Equal As Integers    ${exit_code}    0    Client failed after reconnect!

    Log Test Summary    RPC Reconnect Test    ${True}
    Stop Container    rpc_client
    Stop Container    rpc_server
    Sleep    1s

Run RPC Reconnect Test2
    Log To Console    \n[INFO] Starting RPC Reconnect Test...

    ${IMAGE}=    Set Variable    ${BASE_IMAGE}_network_udp

    Start Container With IP    rpc_server    ${IMAGE}    server    network_udp    network=${NETWORK}    ip=${SERVER_IP}
    Start Container With IP    rpc_client    ${IMAGE}    client    network_udp    network=${NETWORK}    ip=${CLIENT_IP}

    Sleep    2s
    Disconnect Container From Network    rpc_server    ${NETWORK}
    Sleep    6s
    Reconnect Container To Network With IP    rpc_server    ${NETWORK}    ${SERVER_IP}
    Sleep    2s

    ${log_cli}=    Get Container Logs    rpc_client
    ${log_srv}=    Get Container Logs    rpc_server

    Log To Console    \n[CONTAINER LOG: CLIENT]\n${log_cli}
    Log To Console    \n[CONTAINER LOG: SERVER]\n${log_srv}
    Log               \n[CONTAINER LOG: CLIENT]\n${log_cli}
    Log               \n[CONTAINER LOG: SERVER]\n${log_srv}

    ${exit_code}=    Wait For Container Exit    rpc_client
    Should Be Equal As Integers    ${exit_code}    0    Client failed after reconnect!

    Log Test Summary    RPC Reconnect Test    ${True}
    Stop Container    rpc_client
    Stop Container    rpc_server
    Sleep    1s
