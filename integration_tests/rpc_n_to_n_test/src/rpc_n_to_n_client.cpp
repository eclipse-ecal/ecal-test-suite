
#include <ecal/ecal.h>
#include <ecal/service/client.h>
#include <ecal_config_helper.h>

#include <iostream>
#include <thread>
#include <vector>

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
  eCAL::CServiceClient client("rpc_n_to_n_service", method_set);

  std::cout << "[Client] Waiting for server..." << std::endl;
  for (int i = 0; i < 20; ++i)
  {
    if (client.IsConnected()) break;
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
  }

  if (!client.IsConnected())
  {
    std::cerr << "[Client] No server found!" << std::endl;
    return 1;
  }

  std::string request = "PING";
  std::vector<eCAL::SServiceResponse> responses;

  std::cout << "[Client] Sending Ping..." << std::endl;
  bool success = client.CallWithResponse("Ping", request, responses, 2000);

  if (!success || responses.empty())
  {
    std::cerr << "[Client] RPC failed or no response." << std::endl;
    return 1;
  }

  int pong_count = 0;
  for (const auto& r : responses)
  {
    std::cout << "[Client] Response: " << r.response << std::endl;
    if (r.response == "PONG") pong_count++;
  }

  std::cout << "[Client] PONG responses: " << pong_count << std::endl;
  eCAL::Finalize();
  return pong_count > 0 ? 0 : 1;
}