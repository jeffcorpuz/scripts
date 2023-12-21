import os
import argparse

def generate_helm_chart(chart_name, include_service, include_configmap, include_deployment,
                        deployment_replicas, deployment_image, deployment_container_port,
                        deployment_container_port_name, include_ingress, ingress_host,
                        ingress_port, ingress_path, ingress_class, include_job, job_name,
                        job_image):
    chart_dir = chart_name

    # Create the chart directory
    os.makedirs(chart_dir, exist_ok=True)

    # Create Chart.yaml file
    chart_yaml = f"""\
apiVersion: v2
name: {chart_name}
description: A Helm chart for {chart_name}
version: 0.1.0
"""
    with open(os.path.join(chart_dir, 'Chart.yaml'), 'w') as chart_file:
        chart_file.write(chart_yaml)

    # Create templates directory
    templates_dir = os.path.join(chart_dir, 'templates')
    os.makedirs(templates_dir, exist_ok=True)

    # Include Deployment object if specified
    if include_deployment:
        deployment_options = f"""\
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
        - name: {deployment_container_port_name}
          containerPort: {deployment_container_port}
"""
        deployment_yaml = f"""\
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {chart_name}-deployment
{deployment_options}
"""
        with open(os.path.join(templates_dir, 'deployment.yaml'), 'w') as deployment_file:
            deployment_file.write(deployment_yaml)

    # Include Service object if specified
    if include_service:
        service_yaml = f"""\
apiVersion: v1
kind: Service
metadata:
  name: {chart_name}-service
spec:
  selector:
    app: {chart_name}
  ports:
  - port: 80
    targetPort: 80
"""
        with open(os.path.join(templates_dir, 'service.yaml'), 'w') as service_file:
            service_file.write(service_yaml)

    # Include Ingress object if specified
    if include_ingress:
        ingress_options = f"""\
  annotations:
    nginx.ingress.kubernetes.io/ingress-class: {ingress_class}
spec:
  rules:
  - host: {ingress_host}
    http:
      paths:
      - path: {ingress_path}
        pathType: Prefix
        backend:
          service:
            name: {chart_name}-service
            port:
              number: {ingress_port}
"""
        ingress_yaml = f"""\
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {chart_name}-ingress
{ingress_options}
"""
        with open(os.path.join(templates_dir, 'ingress.yaml'), 'w') as ingress_file:
            ingress_file.write(ingress_yaml)

    # Include Job object if specified
    if include_job:
        job_yaml = f"""\
apiVersion: batch/v1
kind: Job
metadata:
  name: {job_name}
spec:
  template:
    spec:
      containers:
      - name: {job_name}-container
        image: {job_image}
      restartPolicy: Never
"""
        with open(os.path.join(templates_dir, 'job.yaml'), 'w') as job_file:
            job_file.write(job_yaml)

    # Include ConfigMap if specified
    if include_configmap:
        configmap_yaml = f"""\
apiVersion: v1
kind: ConfigMap
metadata:
  name: {chart_name}-configmap
data:
  key1: value1
  key2: value2
"""
        with open(os.path.join(templates_dir, 'configmap.yaml'), 'w') as configmap_file:
            configmap_file.write(configmap_yaml)

    print(f"Helm chart '{chart_name}' created successfully in the '{chart_dir}' directory.")

def main():
    parser = argparse.ArgumentParser(description='Generate Helm chart.')
    parser.add_argument('--chart_name', required=True, help='Name of the Helm chart')
    parser.add_argument('--include_service', action='store_true', help='Include Service object')
    parser.add_argument('--include_configmap', action='store_true', help='Include ConfigMap object')
    parser.add_argument('--include_deployment', action='store_true', help='Include Deployment object')
    parser.add_argument('--deployment_replicas', default=1, help='Number of replicas for Deployment')
    parser.add_argument('--deployment_image', required=True, help='Deployment image')
    parser.add_argument('--deployment_container_port', required=True, help='Deployment container port')
    parser.add_argument('--deployment_container_port_name', required=True, help='Deployment container port name')
    parser.add_argument('--include_ingress', action='store_true', help='Include Ingress object')
    parser.add_argument('--ingress_host', default='', help='Ingress host')
    parser.add_argument('--ingress_port', default=80, help='Ingress port')
    parser.add_argument('--ingress_path', default='', help='Ingress path')
    parser.add_argument('--ingress_class', default='nginx', help='Ingress class')
    parser.add_argument('--include_job', action='store_true', help='Include Job object')
    parser.add_argument('--job_name', default='', help='Job name')
    parser.add_argument('--job_image', default='', help='Job image')

    args = parser.parse_args()

    generate_helm_chart(
        args.chart_name,
        args.include_service,
        args.include_configmap,
        args.include_deployment,
        args.deployment_replicas,
        args.deployment_image,
        args.deployment_container_port,
        args.deployment_container_port_name,
        args.include_ingress,
        args.ingress_host,
        args.ingress_port,
        args.ingress_path,
        args.ingress_class,
        args.include_job,
        args.job_name,
        args.job_image
    )

if __name__ == "__main__":
    main()
