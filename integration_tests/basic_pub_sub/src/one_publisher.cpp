#include <ecal_config_helper.h>
#include <ecal/ecal.h>
#include <tclap/CmdLine.h>
#include <iostream>
#include <string>
#include <thread>

int main(int argc, char* argv[])
{
  try
  {
    TCLAP::CmdLine cmd("Publisher", ' ', "1.0");

    TCLAP::ValueArg<std::string> mode_arg("m", "mode", "Transport mode", true, "", "string");
    TCLAP::ValueArg<std::string> topic_arg("t", "topic", "Topic name", false, "test_topic", "string");
    TCLAP::ValueArg<std::string> name_arg("n", "name", "eCAL node name", false, "pub_test", "string");
    TCLAP::ValueArg<int> count_arg("c", "count", "Number of messages", false, 4, "int");
    TCLAP::ValueArg<int> delay_arg("d", "delay", "Delay between sends (ms)", false, 500, "int");

    cmd.add(mode_arg);
    cmd.add(topic_arg);
    cmd.add(name_arg);
    cmd.add(count_arg);
    cmd.add(delay_arg);
    cmd.parse(argc, argv);

    setup_ecal_configuration(mode_arg.getValue(), true, name_arg.getValue());


    eCAL::Publisher::Configuration pub_config;

    eCAL::CPublisher pub(topic_arg.getValue(), eCAL::SDataTypeInformation(), pub_config);

    std::string buffer(0.2L * 1024L * 1024L, 'X');
    //std::cout << "[Publisher] Prepared 0.2MB message.\n\n";

    wait_for_subscriber(topic_arg.getValue(), 1, 50000);

    for (int i = 0; i < count_arg.getValue() && eCAL::Ok(); ++i)
    {
      bool sent = pub.Send(buffer.data(), buffer.size());
      std::cout << "[Publisher] Send result: " << (sent ? "✓" : "✗") << ", size: " << buffer.size() << " bytes\n";
      std::this_thread::sleep_for(std::chrono::milliseconds(delay_arg.getValue()));
    }

    std::cout << "[Publisher] Finished sending.\n";
    eCAL::Finalize();
    return 0;
  }
  catch (TCLAP::ArgException& e)
  {
    std::cerr << "[Publisher] TCLAP error: " << e.error() << " (arg: " << e.argId() << ")" << std::endl;
    return 1;
  }

  return 0;
}
