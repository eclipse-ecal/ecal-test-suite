*** Comments ***
This test checks a basic RPC communication between a client and a server.

Test Setup:
- The server provides a method called "Ping".
- The client sends one "PING" request to this method.

Goals:
- Ensure RPC client-server interaction works over network UDP.
- Validate that the server responds with "PONG".
- The client must connect, call the method, and receive a valid response.

Success Criteria:
- The server receives a call and returns a response.
- The client prints the response and exits with code 0.

*** Settings ***
Library           OperatingSystem
Library           Process
Library           ${CURDIR}/../../lib/DockerLibrary.py
Library           ${CURDIR}/../../lib/GlobalPathsLibrary.py
Suite Setup       Init Test Context

*** Variables ***
${NETWORK}        ${EMPTY}
${BUILD_SCRIPT}   ${EMPTY}
${BASE_IMAGE}     rpc_ping_test

*** Test Cases ***
RPC Ping Test
    [Tags]    rpc_server_client_ping_test
    Run RPC Test Network UDP

*** Keywords ***
Init Test Context
    Set Test Context    rpc_ping_test    rpc_ping_test
    ${build}=    Get Build Script Path
    ${net}=      Get Network Name
    ${args}=     Get Build Script Args
    Set Suite Variable    ${BUILD_SCRIPT}    ${build}
    Set Suite Variable    ${NETWORK}         ${net}

    ${desc}=    Get Test Description
    Log    ${desc}

    Log To Console    [SETUP] Building Docker image...
    ${result}=    Run Process    ${BUILD_SCRIPT}    @{args}
    Should Be Equal As Integers    ${result.rc}    0    Failed to build Docker image!

    Create Docker Network    ${NETWORK}
    Sleep    2s

Run RPC Test Network UDP
    ${IMAGE}=      Set Variable    ${BASE_IMAGE}_network_udp
    ${CLIENT_NAME}=  Set Variable    rpc_client
    ${SERVER_NAME}=  Set Variable    rpc_server

    Log To Console    \n[INFO] Running RPC test (network UDP mode)...

    Start Container    ${SERVER_NAME}    ${IMAGE}    server    network_udp    network=${NETWORK}
    Sleep              1s
    Start Container    ${CLIENT_NAME}    ${IMAGE}    client    network_udp    network=${NETWORK}

    ${exit_code}=    Wait For Container Exit    ${CLIENT_NAME}
    Should Be Equal As Integers    ${exit_code}    0    Client failed!

    ${server_logs}=    Get Container Logs    ${SERVER_NAME}
    ${client_logs}=    Get Container Logs    ${CLIENT_NAME}

    Log To Console    \n[CONTAINER LOG: SERVER]\n${server_logs}
    Log               \n[CONTAINER LOG: SERVER]\n${server_logs}
    Log To Console    \n[CONTAINER LOG: CLIENT]\n${client_logs}
    Log               \n[CONTAINER LOG: CLIENT]\n${client_logs}

    Log Test Summary    RPC Ping Test (UDP)    ${True}
    Stop Container    ${CLIENT_NAME}
    Stop Container    ${SERVER_NAME}
    Sleep             1s
