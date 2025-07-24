#include <ecal_config_helper.h>
#include <ecal/ecal.h>
#include <tclap/CmdLine.h>
#include <iostream>
#include <thread>
#include <atomic>

std::atomic<int> message_count(0);

void OnReceive(const eCAL::STopicId&, const eCAL::SDataTypeInformation&, const eCAL::SReceiveCallbackData& data_)
{
  ++message_count;
  std::cout << "[Subscriber] Received " << data_.buffer_size << " bytes (message " << message_count.load() << ")\n";
}

int main(int argc, char* argv[])
{
  try
  {
    TCLAP::CmdLine cmd("Subscriber", ' ', "1.0");

    TCLAP::ValueArg<std::string> mode_arg("m", "mode", "Transport mode", true, "", "string");
    TCLAP::ValueArg<std::string> topic_arg("t", "topic", "Topic name", false, "test_topic", "string");
    TCLAP::ValueArg<std::string> name_arg("n", "name", "eCAL node name", false, "sub_test", "string");
    TCLAP::ValueArg<int> timeout_arg("w", "wait", "Wait duration (seconds)", false, 6, "int");

    cmd.add(mode_arg);
    cmd.add(topic_arg);
    cmd.add(name_arg);
    cmd.add(timeout_arg);
    cmd.parse(argc, argv);

    setup_ecal_configuration(mode_arg.getValue(), false, name_arg.getValue());

    eCAL::CSubscriber sub(topic_arg.getValue());
    sub.SetReceiveCallback(OnReceive);
    std::cout << "\n\n[Subscriber] Ready and waiting...\n\n";

    std::this_thread::sleep_for(std::chrono::seconds(timeout_arg.getValue()));
    eCAL::Finalize();

    std::cout << "[Subscriber] Received " << message_count << " messages.\n";
    return message_count == 4 ? 0 : 1;
  }
  catch (TCLAP::ArgException& e)
  {
    std::cerr << "[Subscriber] TCLAP error: " << e.error() << " (arg: " << e.argId() << ")" << std::endl;
    return 1;
  }
}
