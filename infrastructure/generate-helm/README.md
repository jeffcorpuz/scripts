# Helm Chart Generator

This Python script helps you generate a Helm chart interactively for Kubernetes applications. It prompts you for various parameters and creates the necessary Kubernetes YAML files for a Helm chart.

## Prerequisites

- Python 3.x
- [Helm](https://helm.sh/) installed on your machine

## How to Use

1. **Run the Script:**
   ```bash
   python generate_helm_interactive.py
   ```

   Follow the prompts to input the desired parameters.

2. **Generated Helm Chart:**
   The script will create a Helm chart in the specified directory. You can find the generated chart in the `<chart_dir>` you provided during the prompts.

## Script Parameters

- **Name of the Helm chart:** The name you want to give to your Helm chart.
- **Include Service object? (y/n):** Specify whether to include the Kubernetes Service object.
- **Include Deployment object? (y/n):** Specify whether to include the Kubernetes Deployment object.
- **Name of the Deployment:** The name you want to give to the Deployment object.
- **Name of the Service:** The name you want to give to the Service object.
- **Name of the Ingress:** The name you want to give to the Ingress object.
- **Number of replicas for Deployment:** Number of replicas for the Deployment object.
- **Deployment image:** The image to use for the Deployment.
- **Deployment container port:** The port on which the Deployment container will listen.
- **Deployment container port name:** The name to assign to the container port.
- **Include Ingress object? (y/n):** Specify whether to include the Kubernetes Ingress object.
- **Ingress host:** The host to use in the Ingress object.
- **Ingress port:** The port to use in the Ingress object.
- **Ingress path:** The path to use in the Ingress object.
- **Ingress class:** The class to use in the Ingress object.
- **Include Service object? (y/n):** Specify whether to include the Kubernetes Service object.
- **Service port:** The port to use in the Service object.
- **Service targetPort:** The targetPort to use in the Service object.
- **Directory to create the Helm chart:** The directory where the Helm chart will be created.

## Examples

### Interactive Mode

```bash
python gen_helm_chart_interactive.py
```

```bash
Name of the Helm chart [my_chart]: test-chart
Directory to create the Helm chart [my_chart]: test-chart
Include Deployment object? (y/n): y
Number of replicas for Deployment [1]: 2
Deployment image [None]: nginx:latest
Deployment container port [None]: 80
Deployment container port name [http]: http
Name of the Deployment [test-chart-deployment]: nginx
Include Ingress object? (y/n): y
Name of the Ingress [test-chart-ingress]: nginx-ingress
Ingress host [None]: test.com
Ingress port [80]: 
Ingress path [None]: /
Ingress class [nginx]: 
Include Service object? (y/n): y
Name of the Service [test-chart-service]: nginx-service
Service port [80]: 
Service targetPort [8080]: 
Helm chart 'test-chart' created successfully in the 'test-chart' directory.
```

### Noninteractive Mode

```bash
python generate_helm_chart_cli.py --chart_name my_chart --include_service --include_deployment --deployment_name my_deployment --service_name my_service --ingress_name my_ingress --deployment_replicas 3 --deployment_image my_image --deployment_container_port 8080 --deployment_container_port_name http --include_ingress --ingress_host example.com --ingress_port 80 --ingress_path /app --ingress_class nginx --include_service --service_port 80 --service_target_port 8080 --chart_dir my_chart

```

### JSON Mode

```bash
python gen_helm_chart.py --config config.json
```

sample json file
```json
{
  "chart_name": "my_chart",
  "include_service": true,
  "include_deployment": true,
  "deployment_name": "my_deployment",
  "service_name": "my_service",
  "ingress_name": "my_ingress",
  "deployment_replicas": 3,
  "deployment_image": "my_image",
  "deployment_container_port": 8080,
  "deployment_container_port_name": "http",
  "include_ingress": true,
  "ingress_host": "example.com",
  "ingress_port": 80,
  "ingress_path": "/app",
  "ingress_class": "nginx",
  "include_service": true,
  "service_port": 80,
  "service_target_port": 8080,
  "chart_dir": "my_chart"
}


```

## License

This script is licensed under the [MIT License](LICENSE).
