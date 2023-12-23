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
