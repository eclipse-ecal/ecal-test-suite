#include <ecal_config_helper.h>
#include <ecal/ecal.h>
#include <tclap/CmdLine.h>
#include <iostream>
#include <atomic>
#include <thread>

std::atomic<int> count_42(0);
std::atomic<int> count_43(0);

void OnReceive(const eCAL::STopicId&, const eCAL::SDataTypeInformation&, const eCAL::SReceiveCallbackData& data_)
{
  if (data_.buffer_size > 0)
  {
    int value = static_cast<int>(static_cast<const unsigned char*>(data_.buffer)[0]);
    if (value == 42) ++count_42;
    if (value == 43) ++count_43;

    //std::cout << "[Subscriber 1] Received value: " << value << std::endl;
  }
}

int main(int argc, char* argv[])
{
  try
  {
    TCLAP::CmdLine cmd("Subscriber_1", ' ', "1.0");

    TCLAP::ValueArg<std::string> mode_arg("m", "mode", "Transport mode", true, "", "string");
    TCLAP::ValueArg<std::string> topic_arg("t", "topic", "Topic name", false, "test_topic", "string");
    TCLAP::ValueArg<int> wait_arg("w", "wait", "Wait duration (seconds)", false, 16, "int");

    cmd.add(mode_arg);
    cmd.add(topic_arg);
    cmd.add(wait_arg);
    cmd.parse(argc, argv);

    setup_ecal_configuration(mode_arg.getValue(), false, "multi_subscriber");

    eCAL::CSubscriber sub(topic_arg.getValue());
    sub.SetReceiveCallback(OnReceive);

    std::cout << "[Subscriber 1] Waiting for messages...\n" << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(wait_arg.getValue()));

    eCAL::Finalize();

    std::cout << "\n=== [Subscriber 1] Received Message Summary ===\n";
    std::cout << "PUB1 messages (42):--------------> " << count_42.load() << "/10\n";
    std::cout << "PUB2 messages (43):-------------> " << count_43.load() << "/10\n";

    if (count_42 == 10 && count_43 == 10)
    {
      std::cout << "[Subscriber 1] [✓] Received messages from both publishers.\n" << std::endl;
      return 0;
    }
    else
    {
      std::cerr << "[Subscriber 1] [✗] Missing messages from one or both publishers.\n" << std::endl;
      return 1;
    }
  }
  catch (const TCLAP::ArgException& e)
  {
    std::cerr << "[Subscriber 1] TCLAP error: " << e.error() << " (arg: " << e.argId() << ")" << std::endl;
    return 1;
  }
}
