#include <ecal_config_helper.h>
#include <ecal/ecal.h>
#include <ecal/service/client.h>
#include <iostream>
#include <vector>
#include <thread>
#include <tclap/CmdLine.h>

#define GREEN   "\033[1;32m"
#define RED     "\033[1;31m"
#define YELLOW  "\033[1;33m"
#define RESET   "\033[0m"

int main(int argc, char** argv)
{
  try
  {
    TCLAP::CmdLine cmd("eCAL RPC Ping Client", ' ', "1.0");
    TCLAP::ValueArg<std::string> mode_arg("m", "mode", "eCAL mode (e.g., network_tcp, network_udp, local_tcp)", true, "", "string");
    TCLAP::ValueArg<std::string> name_arg("n", "name", "Node name", false, "rpc_ping_client", "string");

    cmd.add(mode_arg);
    cmd.add(name_arg);
    cmd.parse(argc, argv);

    const std::string mode = mode_arg.getValue();
    const std::string node_name = name_arg.getValue();

    std::cout << YELLOW << "[Client] Initializing eCAL with mode: " << mode << RESET << std::endl;
    setup_ecal_configuration(mode, false, node_name);

    eCAL::SDataTypeInformation req_type;
    req_type.encoding = "byte";
    req_type.name     = "std::string";

    eCAL::SDataTypeInformation resp_type;
    resp_type.encoding = "byte";
    resp_type.name     = "std::string";

    eCAL::SServiceMethodInformation method_info;
    method_info.method_name   = "Ping";
    method_info.request_type  = req_type;
    method_info.response_type = resp_type;

    eCAL::ServiceMethodInformationSetT method_set{ method_info };
    eCAL::CServiceClient client("rpc_test_service", method_set);

    std::cout << YELLOW << "[Client] Waiting for server connection..." << RESET << std::endl;

    int attempts = 10;
    while (!client.IsConnected() && eCAL::Ok() && attempts-- > 0)
    {
      std::this_thread::sleep_for(std::chrono::milliseconds(500));
    }

    if (!client.IsConnected())
    {
      std::cerr << RED << "[Client] Timeout! No server connected." << RESET << std::endl;
      eCAL::Finalize();
      return 1;
    }

    std::cout << GREEN << "[Client] Connected. Calling 'Ping'..." << RESET << std::endl;

    std::string request = "PING";
    std::vector<eCAL::SServiceResponse> responses;

    bool success = client.CallWithResponse("Ping", request, responses, 1000); // 1s Timeout

    if (!success)
    {
      std::cerr << RED << "[Client] Call failed or timed out." << RESET << std::endl;
      eCAL::Finalize();
      return 1;
    }

    for (const auto& response : responses)
    {
      std::cout << GREEN << "[Client] Server response: " << response.response << RESET << std::endl;
    }

    eCAL::Finalize();
    return 0;
  }
  catch (const TCLAP::ArgException& e)
  {
    std::cerr << RED << "[Client] TCLAP error: " << e.error() << " (arg: " << e.argId() << ")" << RESET << std::endl;
    return 1;
  }
}
