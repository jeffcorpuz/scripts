import os
import argparse
import json

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
  pullPolicy: IfNotPresent

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

def parse_arguments():
    parser = argparse.ArgumentParser(description='Generate Helm chart for Kubernetes applications.')
    parser.add_argument('--config', help='Path to JSON configuration file.')
    parser.add_argument('--chart_name', required=True, help='Name of the Helm chart.')
    parser.add_argument('--include_service', action='store_true', help='Include Service object.')
    parser.add_argument('--include_deployment', action='store_true', help='Include Deployment object.')
    parser.add_argument('--deployment_name', help='Name of the Deployment object.')
    parser.add_argument('--service_name', help='Name of the Service object.')
    parser.add_argument('--ingress_name', help='Name of the Ingress object.')
    parser.add_argument('--deployment_replicas', type=int, help='Number of replicas for Deployment.')
    parser.add_argument('--deployment_image', help='Deployment image.')
    parser.add_argument('--deployment_container_port', type=int, help='Deployment container port.')
    parser.add_argument('--deployment_container_port_name', help='Deployment container port name.')
    parser.add_argument('--include_ingress', action='store_true', help='Include Ingress object.')
    parser.add_argument('--ingress_host', help='Ingress host.')
    parser.add_argument('--ingress_port', type=int, help='Ingress port.')
    parser.add_argument('--ingress_path', help='Ingress path.')
    parser.add_argument('--ingress_class', help='Ingress class.')
    parser.add_argument('--service_port', type=int, help='Service port.')
    parser.add_argument('--service_target_port', type=int, help='Service targetPort.')
    parser.add_argument('--chart_dir', help='Directory to create the Helm chart.')

    return parser.parse_args()

def main():
    args = parse_arguments()

    if args.config:
        with open(args.config, 'r') as config_file:
            config = json.load(config_file)

        # Use values from the JSON configuration file
        generate_helm_chart(**config)
    else:
        # Use values from command-line arguments
        generate_helm_chart(
            chart_name=args.chart_name,
            include_service=args.include_service,
            include_deployment=args.include_deployment,
            deployment_name=args.deployment_name,
            service_name=args.service_name,
            ingress_name=args.ingress_name,
            deployment_replicas=args.deployment_replicas,
            deployment_image=args.deployment_image,
            deployment_container_port=args.deployment_container_port,
            deployment_container_port_name=args.deployment_container_port_name,
            include_ingress=args.include_ingress,
            ingress_host=args.ingress_host,
            ingress_port=args.ingress_port,
            ingress_path=args.ingress_path,
            ingress_class=args.ingress_class,
            service_port=args.service_port,
            service_target_port=args.service_target_port,
            chart_dir=args.chart_dir
        )

if __name__ == "__main__":
    main()
