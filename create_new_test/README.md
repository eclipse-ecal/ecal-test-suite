# Generate New Test Folder

This tool creates a **new test folder** with all needed files for the Test setup.

It uses **Jinja2 templates** to generate test folders automatically.

## How to use

### 1. Install Jinja2

```bash
pip install Jinja2
```

### 2. Run the script

```bash
cd create_new_test
python create_test.py my_test_case
```

This creates a new folder:

```bash
/integration_tests/my_test_case/
```

## What does it generate?

Example structure (for test name `my_test_case`):

```bash
integration_tests/my_test_case/
├── docker/Dockerfile
├── robottests/my_test_case.robot
├── scripts/
│ ├── build_images.sh
│ └── entrypoint.sh
├── src/
│ ├── CMakeLists.txt
│ ├── my_test_case_pub.cpp
│ └── my_test_case_sub.cpp
└── README.md
```

## Notes

1. All files include example content with comments

2. You can change the templates in templates/ folder