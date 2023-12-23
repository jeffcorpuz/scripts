If your Terraform files are in a different directory, you can provide the path as a build argument:

```Dockerfile
# Use a base image with Terraform and necessary tools installed
FROM hashicorp/terraform:latest

# Set the working directory inside the container
WORKDIR /terraform

# Build argument to specify the Terraform directory
ARG TERRAFORM_DIR=.

# Copy the contents of the specified Terraform directory into the container
COPY ${TERRAFORM_DIR} /terraform

# Set the entry point to run Terraform with the CMD arguments
ENTRYPOINT ["terraform"]

# Default command when the container starts (can be overridden at runtime)
CMD ["--help"]
```

To build the Docker image with a specific Terraform directory:

```bash
docker build -t terraform-runner --build-arg TERRAFORM_DIR=/path/to/your/terraform/directory .
```

After building the image, you can use it to run Terraform commands in your specified directory like so:

```bash
docker run -v $(pwd):/terraform terraform-runner init
docker run -v $(pwd):/terraform terraform-runner apply
# ... and so on
```

Make sure to adjust paths and configurations according to your specific needs.