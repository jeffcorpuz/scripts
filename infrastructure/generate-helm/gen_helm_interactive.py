import os
import yaml

def prompt_for_input(parameter, default_value=None):
    user_input = input(f"{parameter} [{default_value}]: ").strip()
    return user_input if user_input else default_value

def generate_helm_chart(chart_name, include_service, include_deployment,
                        deployment_name, service_name, ingress_name,
                        deployment_replicas, deployment_image, deployment_container_port,
                        deployment_container_port_name, include_ingress, ingress_host,
                        ingress_port, ingress_path, ingress_class, service_port,
                        service_target_port, chart_dir):
    # Create chart directory
    os.makedirs(chart_dir, exist_ok=True)

    # Create templates directory
    templates_dir = os.path.join(chart_dir, 'templates')
    os.makedirs(templates_dir, exist_ok=True)

    # Write Helm chart files
    if include_service:
        service_content = f"""apiVersion: v1
kind: Service
metadata:
  name: {service_name}
spec:
  selector:
    app: {chart_name}
  ports:
    - protocol: TCP
      port: {service_port}
      targetPort: {service_target_port}
"""
        with open(os.path.join(templates_dir, 'service.yaml'), 'w') as service_file:
            service_file.write(service_content)

    if include_deployment:
        deployment_content = f"""apiVersion: apps/v1
kind: Deployment
metadata:
  name: {deployment_name}
spec:
  replicas: {deployment_replicas}
  selector:
    matchLabels:
      app: {chart_name}
  template:
    metadata:
      labels:
        app: {chart_name}
    spec:
      containers:
      - name: {chart_name}-container
        image: {deployment_image}
        ports:
        - containerPort: {deployment_container_port}
          name: {deployment_container_port_name}
"""
        with open(os.path.join(templates_dir, 'deployment.yaml'), 'w') as deployment_file:
            deployment_file.write(deployment_content)

    if include_ingress:
        ingress_content = f"""apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {ingress_name}
spec:
  rules:
  - host: {ingress_host}
    http:
      paths:
      - path: {ingress_path}
        pathType: Prefix
        backend:
          service:
            name: {service_name}
            port:
              number: {service_port}
"""
        with open(os.path.join(templates_dir, 'ingress.yaml'), 'w') as ingress_file:
            ingress_file.write(ingress_content)

    # Write Chart.yaml
    chart_content = f"""apiVersion: v2
name: {chart_name}
description: A Helm chart for {chart_name}
version: 0.1.0
"""
    with open(os.path.join(chart_dir, 'Chart.yaml'), 'w') as chart_file:
        chart_file.write(chart_content)

    # Write values.yaml
    values_content = f"""# Default values for {chart_name}
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: {deployment_replicas}

image:
  repository: {deployment_image}
  tag: latest
  pullPolicy: Always

service:
  name: {service_name}
  type: ClusterIP
  port: {service_port}

ingress:
  enabled: {str(include_ingress).lower()}
  className: {ingress_class}
  hosts:
    - host: {ingress_host}
      paths:
        - {ingress_path}

"""
    with open(os.path.join(chart_dir, 'values.yaml'), 'w') as values_file:
        values_file.write(values_content)

    print(f"Helm chart '{chart_name}' created successfully in the '{chart_dir}' directory.")

def main():

    # chart information
    chart_name = prompt_for_input("Name of the Helm chart", "my_chart")
    chart_dir = prompt_for_input("Directory to create the Helm chart", "my_chart")

    # deployment
    deployment_replicas = deployment_image = deployment_container_port = deployment_container_port_name = None
    include_deployment = input("Include Deployment object? (y/n): ").lower() == 'y'
    if include_deployment:
        deployment_name = prompt_for_input("Name of the Deployment object", f"{chart_name}-deployment")
        deployment_replicas = int(prompt_for_input("Number of replicas for Deployment", 1))
        deployment_image = prompt_for_input("Deployment image", "nginx:latest")
        deployment_container_port = int(prompt_for_input("Deployment container port", 80))
        deployment_container_port_name = prompt_for_input("Deployment container port name", "http")

    # ingress
    include_ingress = ingress_host = ingress_port = ingress_path = ingress_class = None
    include_ingress = input("Include Ingress object? (y/n): ").lower() == 'y'
    if include_ingress:
      ingress_name = prompt_for_input("Name of the Ingress object", f"{chart_name}-ingress")
      ingress_host = prompt_for_input("Ingress host", "https://example.com")
      ingress_port = int(prompt_for_input("Ingress port number", 80))
      ingress_path = prompt_for_input("Ingress path", "/")
      ingress_class = prompt_for_input("Ingress class", "nginx")

    # service
    service_port = service_target_port = None
    include_service = input("Include Service object? (y/n): ").lower() == 'y'
    if include_service:
      service_name = prompt_for_input("Name of the Service", f"{chart_name}-service")
      service_port = int(prompt_for_input("Service port", 80))
      service_target_port = (prompt_for_input("Service targetPort", "port # | name"))

    generate_helm_chart(
        chart_name=chart_name,
        include_service=include_service,
        include_deployment=include_deployment,
        deployment_name=deployment_name,
        service_name=service_name,
        ingress_name=ingress_name,
        deployment_replicas=deployment_replicas,
        deployment_image=deployment_image,
        deployment_container_port=deployment_container_port,
        deployment_container_port_name=deployment_container_port_name,
        include_ingress=include_ingress,
        ingress_host=ingress_host,
        ingress_port=ingress_port,
        ingress_path=ingress_path,
        ingress_class=ingress_class,
        service_port=service_port,
        service_target_port=service_target_port,
        chart_dir=chart_dir
    )

if __name__ == "__main__":
    main()
