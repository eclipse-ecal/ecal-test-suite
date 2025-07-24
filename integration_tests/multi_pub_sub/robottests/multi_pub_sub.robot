*** Comments ***
This test validates eCAL communication in a scenario involving multiple publishers and subscribers.

Test Setup:
- Two publishers run in parallel and publish messages on the **same topic**.
  • Publisher 1 sends messages containing the byte value **42**.
  • Publisher 2 sends messages containing the byte value **43**.
- Two subscribers listen on that same topic and must receive all messages from both publishers.

Covered eCAL modes:
- local_shm
- local_udp
- local_tcp
- network_udp
- network_tcp

Goals:
- Ensure that eCAL correctly distributes messages from **multiple sources** to **multiple receivers**.
- Verify that **topic routing, message integrity, and delivery** work consistently across different transport modes.

Success Criteria:
- Each subscriber must receive **10 messages with value 42** and **10 with value 43**.
- If this condition is met, the subscriber exits with code **0**.
- If any expected messages are missing, the subscriber exits with code **1**.

*** Settings ***
Library           OperatingSystem
Library           Process
Library           ${CURDIR}/../../lib/DockerLibrary.py
Library           ${CURDIR}/../../lib/GlobalPathsLibrary.py
Suite Setup       Init Test Context

*** Variables ***
${NETWORK}        ${EMPTY}
${BUILD_SCRIPT}   ${EMPTY}
${BASE_IMAGE}     multi_pub_sub

*** Test Cases ***
Multi Pub/Sub Local SHM Test
    [Tags]    multi_pub_sub_local_shm
    Run Multi Pub Sub Test Local    local_shm

Multi Pub/Sub Local UDP Test
    [Tags]    multi_pub_sub_local_udp
    Run Multi Pub Sub Test Local    local_udp

Multi Pub/Sub Local TCP Test
    [Tags]    multi_pub_sub_local_tcp
    Run Multi Pub Sub Test Local    local_tcp

Multi Pub/Sub Network UDP Test
    [Tags]    multi_pub_sub_network_udp
    Run Multi Pub Sub Test Network    network_udp    network

Multi Pub/Sub Network TCP Test
    [Tags]    multi_pub_sub_network_tcp
    Run Multi Pub Sub Test Network    network_tcp    network
 
*** Keywords ***
Init Test Context
    Set Test Context    multi_pub_sub    multi_pub_sub
    ${build}=    Get Build Script Path
    ${net}=      Get Network Name
    ${args}=     Get Build Script Args
    Set Suite Variable    ${BUILD_SCRIPT}    ${build}
    Set Suite Variable    ${NETWORK}         ${net}

    ${desc}=    Get Test Description
    Log         ${desc}

    Log To Console    [SETUP] Building Docker image...
    ${result}=    Run Process    ${BUILD_SCRIPT}    @{args}
    Should Be Equal As Integers    ${result.rc}    0    Failed to build Docker image!

    Create Docker Network    ${NETWORK}
    Sleep    3s

Run Multi Pub Sub Test Network
    [Arguments]    ${layer_tag}    ${mode}
    ${IMAGE}=    Set Variable    ${BASE_IMAGE}_${layer_tag}
    ${TOPIC}=    Set Variable    test_topic
    ${PUB1}=     Set Variable    pub1_${layer_tag}
    ${PUB2}=     Set Variable    pub2_${layer_tag}
    ${SUB1}=     Set Variable    sub1_${layer_tag}
    ${SUB2}=     Set Variable    sub2_${layer_tag}

    Log To Console    \n[INFO] Starting multi pub/sub test with ${layer_tag}

    Start Container    ${SUB1}    ${IMAGE}    multi_subscriber    ${layer_tag}    ${TOPIC}    network=${NETWORK}
    Start Container    ${SUB2}    ${IMAGE}    multi_subscriber2    ${layer_tag}    ${TOPIC}    network=${NETWORK}
    Start Container    ${PUB1}    ${IMAGE}    multi_publisher     ${layer_tag}    ${TOPIC}    network=${NETWORK}
    Start Container    ${PUB2}    ${IMAGE}    multi_publisher2     ${layer_tag}    ${TOPIC}    network=${NETWORK}
    
    Sleep    18s

    ${log1}=    Get Container Logs    ${SUB1}
    Log To Console    \n[CONTAINER LOG: SUBSCRIBER 1]\n${log1}
    Log        \n[CONTAINER LOG: SUBSCRIBER 1]\n${log1}

    ${log2}=    Get Container Logs    ${SUB2}
    Log To Console    \n[CONTAINER LOG: SUBSCRIBER 2]\n${log2}
    Log        \n[CONTAINER LOG: SUBSCRIBER 1]\n${log2}

    Wait For Container Exit    ${SUB1}
    Wait For Container Exit    ${SUB2}
    Wait For Container Exit    ${PUB1}
    Wait For Container Exit    ${PUB2}

    ${exit1}=    Wait For Container Exit    ${SUB1}
    ${exit2}=    Wait For Container Exit    ${SUB2}
    Should Be Equal As Integers    ${exit1}    0    Subscriber 1 failed!
    Should Be Equal As Integers    ${exit2}    0    Subscriber 2 failed!

    Log Test Summary    Multi Pub/Sub Test ${layer_tag}    ${True}

    Stop Container    ${SUB1}
    Stop Container    ${SUB2}
    Stop Container    ${PUB1}
    Stop Container    ${PUB2}
    Sleep    1s

Run Multi Pub Sub Test Local
    [Arguments]    ${layer_tag}
    ${IMAGE}=      Set Variable    ${BASE_IMAGE}_${layer_tag}
    ${CONTAINER}=  Set Variable    multi_local${layer_tag}

    Log To Console    \n[INFO] Running local multi pub/sub test (all binarys in same Container) with ${layer_tag}

    Start Container    ${CONTAINER}    ${IMAGE}    local_multi    ${layer_tag}
    Sleep    18s
    ${logs}=    Get Container Logs    ${CONTAINER}
    Log To Console    \n[CONTAINER LOG: All Local Binarys Multi Pub/Sub]\n${logs}
    Log    \n[CONTAINER LOG: All Local Binarys Multi Pub/Sub]\n${logs}

    ${exit_code}=    Wait For Container Exit    ${CONTAINER}

    Should Be Equal As Integers    ${exit_code}    0    Local Multi Pub/Sub Test test failed!

    Stop Container    ${CONTAINER}
    Sleep    1s