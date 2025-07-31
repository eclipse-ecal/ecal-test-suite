import os
from robot.api.deco import keyword

class GlobalPathsLibrary:
    def __init__(self):
        # Resolve to /integration_tests directory
        current_file_dir = os.path.dirname(os.path.abspath(__file__))
        self.integration_tests_root = os.path.abspath(os.path.join(current_file_dir, ".."))

        # Default values (can be overridden)
        self.test_case_folder = "basic_pub_sub"
        self.tag_prefix = "basic_pub_sub"

    @keyword
    def set_test_context(self, test_case_folder: str, tag_prefix: str):
        """
        Sets the test folder and tag prefix if it's a valid test case.
        The folder must exist under integration_tests/ and contain typical test structure.
        """
        test_case_path = os.path.join(self.integration_tests_root, test_case_folder)

        # Check if it exists and contains a 'robottests' folder
        has_robot = os.path.isdir(os.path.join(test_case_path, "robottests"))
        has_src = os.path.isdir(os.path.join(test_case_path, "src"))
        has_scripts = os.path.isdir(os.path.join(test_case_path, "scripts"))

        if os.path.isdir(test_case_path) and (has_robot or has_src or has_scripts):
            self.test_case_folder = test_case_folder
            self.tag_prefix = tag_prefix
        else:
            raise ValueError(f"'{test_case_folder}' is not a valid test case folder.")

    @keyword
    def get_project_root(self):
        return self.integration_tests_root

    @keyword
    def get_configs_dir(self):
        return os.path.join(self.integration_tests_root, "cfg")

    @keyword
    def get_build_script_path(self):
        return os.path.join(self.integration_tests_root, self.test_case_folder, "scripts", "build_images.sh")

    @keyword
    def get_build_script_args(self):
        return [self.tag_prefix]

    @keyword
    def get_tag_prefix(self):
        return self.tag_prefix

    @keyword
    def get_network_name(self):
        return "ecal_test_net"
    
    @keyword
    def get_test_description(self):
        """
        Reads the *** Comments *** section from the .robot file and returns it as a string.
        """
        robot_file = os.path.join(self.integration_tests_root, self.test_case_folder, "robottests", f"{self.test_case_folder}.robot")
        if not os.path.exists(robot_file):
            return f"[Error] .robot file not found: {robot_file}"

        in_comments = False
        description_lines = []

        with open(robot_file, "r", encoding="utf-8") as file:
            for line in file:
                stripped = line.strip()
                if stripped.startswith("*** Comments ***"):
                    in_comments = True
                    continue
                if stripped.startswith("***") and in_comments:
                    break
                if in_comments:
                    description_lines.append(stripped)

        return "\n".join(description_lines).strip() if description_lines else "[No description found]"
