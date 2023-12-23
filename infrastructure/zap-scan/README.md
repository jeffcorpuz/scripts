## OWASP ZAP Security Scan

This script automates the OWASP ZAP (Zed Attack Proxy) security scan against a specified URL and/or API. The scan results are presented in HTML reports with a focus on alert levels, and the reports can be optionally opened after the script execution.

### Usage

```bash
./owasp_scan.sh -u <URL> -a <API> -l <Alert Level> -o
```

- `-u`: URL to scan.
- `-a`: API to scan.
- `-l`: Alert level to fail the script (Defaults to 'Medium').
- `-o`: Open OWASP Report after script run.
- `-h`: Display usage information.

### Dependencies

- **Docker**: Ensure Docker is installed and running.
- **jq**: Install jq from [https://stedolan.github.io/jq/].

### Reports

- **Web Scan Report**: HTML report for web application scans.
- **API Scan Report**: HTML report for API scans.

### Example

```bash
./owasp_scan.sh -u http://example.com -o
```

### Note

- The script uses OWASP ZAP in a Docker container to perform scans.
- Make sure to install the required dependencies and set up Docker before running the script.

Feel free to customize the script and adapt it to your specific needs.