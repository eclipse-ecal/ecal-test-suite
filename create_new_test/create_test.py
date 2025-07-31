import os
import stat
from jinja2 import Environment, FileSystemLoader

def render_templates(test_name: str, output_dir: str):
    env = Environment(loader=FileSystemLoader("templates"))
    folder_structure = ["docker", "robottests", "scripts", "src"]

    target_root = os.path.join(output_dir, test_name)

    # 1. Create folder structure
    for folder in folder_structure:
        os.makedirs(os.path.join(target_root, folder), exist_ok=True)

    # 2. Render templates
    for root, _, files in os.walk("templates"):
        relative_path = os.path.relpath(root, "templates")
        for file in files:
            template = env.get_template(os.path.join(relative_path, file))
            rendered_content = template.render(test_name=test_name)

            # 3. Replace placeholders in filename
            output_filename = file.replace(".j2", "")
            output_filename = output_filename.replace("test", test_name)

            output_folder = os.path.join(target_root, relative_path)
            output_path = os.path.join(output_folder, output_filename)

            with open(output_path, "w") as f:
                f.write(rendered_content)

            # 4. Make scripts executable if applicable
            if output_filename in ["build_images.sh", "entrypoint.sh"]:
                os.chmod(output_path, os.stat(output_path).st_mode | stat.S_IXUSR)

    print(f"[✓] New test folder '{test_name}' created successfully at: {target_root}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python create_test.py <test_name>")
        sys.exit(1)

    render_templates(sys.argv[1], "../integration_tests")
