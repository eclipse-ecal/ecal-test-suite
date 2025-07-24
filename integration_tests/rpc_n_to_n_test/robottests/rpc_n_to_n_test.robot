*** Comments ***
This test validates N-to-N RPC communication using eCAL, where multiple clients
send concurrent Ping requests to multiple servers.

Test Setup:
- 2 RPC servers provide a method called "Ping".
- 2 RPC clients call this method on all available servers.
- Each client must receive a valid "PONG" response from all available servers.

Goals:
- Validate that RPC communication scales to N clients and N servers.
- Ensure all clients connect and receive correct responses from all servers.

Success Criteria:
- Each client prints the correct number of "PONG" responses.
- All clients exit with code 0.

*** Settings ***
Library           OperatingSystem
Library           Process
Library           ${CURDIR}/../../lib/DockerLibrary.py
Library           ${CURDIR}/../../lib/GlobalPathsLibrary.py
Suite Setup       Init Test Context

*** Variables ***
${NETWORK}        ${EMPTY}
${BUILD_SCRIPT}   ${EMPTY}
${BASE_IMAGE}     rpc_n_to_n_test
${NUM_CLIENTS}    2
${NUM_SERVERS}    2

*** Test Cases ***
RPC N-to-N Test
    [Tags]    rpc_n_to_n_test
    Run RPC N-to-N Test

*** Keywords ***
Init Test Context
    Set Test Context    rpc_n_to_n_test    rpc_n_to_n_test
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

Run RPC N-to-N Test
    ${IMAGE}=      Set Variable    ${BASE_IMAGE}_network_udp

    Log To Console    \n[INFO] Starting ${NUM_SERVERS} servers and ${NUM_CLIENTS} clients...

    FOR    ${i}    IN RANGE    ${NUM_SERVERS}
        ${name}=    Set Variable    rpc_server_${i}
        Start Container    ${name}    ${IMAGE}    server    network_udp    network=${NETWORK}
    END

    Sleep    2s

    FOR    ${j}    IN RANGE    ${NUM_CLIENTS}
        ${name}=    Set Variable    rpc_client_${j}
        Start Container    ${name}    ${IMAGE}    client    network_udp     network=${NETWORK}
    END

    FOR    ${j}    IN RANGE    ${NUM_CLIENTS}
        ${name}=    Set Variable    rpc_client_${j}
        ${exit_code}=    Wait For Container Exit    ${name}
        Should Be Equal As Integers    ${exit_code}    0    ${name} failed!
        ${logs}=    Get Container Logs    ${name}
        Log To Console    \n[CLIENT LOG: ${name}]\n${logs}
        Log               \n[CLIENT LOG: ${name}]\n${logs}
    END

    FOR    ${i}    IN RANGE    ${NUM_SERVERS}
        ${name}=    Set Variable    rpc_server_${i}
        ${logs}=    Get Container Logs    ${name}
        Log To Console    \n[SERVER LOG: ${name}]\n${logs}
        Log               \n[SERVER LOG: ${name}]\n${logs}
        Stop Container    ${name}
    END

    FOR    ${j}    IN RANGE    ${NUM_CLIENTS}
        Stop Container    rpc_client_${j}
    END

    Log Test Summary    RPC N-to-N Test    ${True}
    Sleep               1s
