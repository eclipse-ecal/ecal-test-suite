#include <ecal_config_helper.h>
#include <ecal/ecal.h>
#include <ecal/service/server.h>
#include <iostream>
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
    TCLAP::CmdLine cmd("eCAL RPC Ping Server", ' ', "1.0");
    TCLAP::ValueArg<std::string> mode_arg("m", "mode", "eCAL mode (e.g., network_udp)", true, "", "string");
    TCLAP::ValueArg<std::string> name_arg("n", "name", "Node name", false, "rpc_ping_server", "string");

    cmd.add(mode_arg);
    cmd.add(name_arg);
    cmd.parse(argc, argv);

    const std::string mode = mode_arg.getValue();
    const std::string node_name = name_arg.getValue();

    std::cout << YELLOW << "[Server] Initializing eCAL with mode: " << mode << RESET << std::endl;
    setup_ecal_configuration(mode, true, node_name);

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

    eCAL::CServiceServer server("rpc_test_service");

    server.SetMethodCallback(method_info, [](const eCAL::SServiceMethodInformation&,
                                             const std::string& request,
                                             std::string& response) -> int
    {
      std::cout << GREEN << "[Server] Received RPC request: " << request << RESET << std::endl;

      if (request == "PING")
      {
        response = "PONG";
        std::cout << GREEN << "[Server] Responding with: PONG" << RESET << std::endl;
        return 0;
      }

      response = "UNKNOWN";
      std::cerr << RED << "[Server] Unknown request: " << request << RESET << std::endl;
      return 1;
    });

    std::cout << GREEN << "[Server] Waiting for RPC calls (method: Ping)" << RESET << std::endl;

    while (eCAL::Ok())
    {
      std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    std::cout << YELLOW << "[Server] Shutting down..." << RESET << std::endl;
    eCAL::Finalize();
    return 0;
  }
  catch (const TCLAP::ArgException& e)
  {
    std::cerr << RED << "TCLAP error: " << e.error() << " (arg: " << e.argId() << ")" << RESET << std::endl;
    return 1;
  }
}
