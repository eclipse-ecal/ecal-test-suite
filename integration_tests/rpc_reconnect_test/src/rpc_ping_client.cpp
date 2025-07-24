#include <ecal/ecal.h>
#include <ecal/service/client.h>
#include <ecal_config_helper.h>

#include <iostream>
#include <thread>
#include <vector>

int call_rpc(eCAL::CServiceClient& client, const std::string& label, int& pong_counter)
{
  std::string request = "PING";
  std::vector<eCAL::SServiceResponse> responses;

  std::cout << "[Client][" << label << "] Calling RPC 'Ping'..." << std::endl;
  bool success = client.CallWithResponse("Ping", request, responses, 1000);
  if (!success)
  {
    std::cerr << "[Client][" << label << "] RPC call failed." << std::endl;
    return 1;
  }

  for (const auto& r : responses)
  {
    std::cout << "[Client][" << label << "] Response: " << r.response << std::endl;
    if (r.response == "PONG") pong_counter++;
  }

  return 0;
}

int main(int argc, char* argv[])
{
  std::string mode = "network_udp";
  if (argc > 2 && std::string(argv[1]) == "-m") mode = argv[2];

  std::cout << "[Client] Initializing eCAL with mode: " << mode << std::endl;
  setup_ecal_configuration(mode, false, "rpc_client");

  eCAL::SServiceMethodInformation method_info;
  method_info.method_name = "Ping";
  method_info.request_type.name = "std::string";
  method_info.request_type.encoding = "byte";
  method_info.response_type.name = "std::string";
  method_info.response_type.encoding = "byte";

  eCAL::ServiceMethodInformationSetT method_set{ method_info };
  eCAL::CServiceClient client("rpc_test_service", method_set);

  std::cout << "[Client] Waiting for server..." << std::endl;
  for (int i = 0; i < 10; ++i)
  {
    if (client.IsConnected()) break;
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
  }

  if (!client.IsConnected())
  {
    std::cerr << "[Client] No server found!" << std::endl;
    return 1;
  }

  int pong_counter = 0;
  int error = call_rpc(client, "Initial", pong_counter);

  std::this_thread::sleep_for(std::chrono::seconds(8));
  std::cout << "[Client] Trying to reconnect and call again..." << std::endl;

  for (int i = 0; i < 10; ++i)
  {
    if (client.IsConnected()) break;
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
  }

  if (!client.IsConnected())
  {
    std::cerr << "[Client] Still no connection after reconnect!" << std::endl;
    return 1;
  }

  error += call_rpc(client, "Reconnect", pong_counter);
  std::cout << "[Client] Total PONGs received: " << pong_counter << std::endl;

  eCAL::Finalize();

  if (pong_counter >= 2 && error == 0)
  {
    std::cout << "[Client]  Reconnect test passed." << std::endl;
    return 0;
  }
  else
  {
    std::cerr << "[Client]  Reconnect test failed!" << std::endl;
    return 1;
  }
}
