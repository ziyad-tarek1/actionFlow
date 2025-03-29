# DevOps-EKS-GitOps-ActionFlow

![Project Banner](https://github.com/ziyad-tarek1/DevOps-EKS-GitOps-ActionFlow/assets/banner.png)

## Overview
This project provides a fully automated infrastructure deployment in AWS using Terraform. The infrastructure is modularized and organized to ensure scalability and maintainability. It includes:
- **VPC** with 2 public and 2 private subnets.
- **Amazon EKS (Elastic Kubernetes Service)** with AWS ALB (Application Load Balancer).
- **Monitoring stack** using Prometheus and Grafana.
- **GitOps-based Continuous Deployment** using ArgoCD with the App of Apps pattern.
- **Amazon ECR (Elastic Container Registry)** for container image storage.
- **CI/CD Pipeline**:
  - GitHub Actions as a controller for CI
  - ArgoCD handles CD
- **Self-Hosted Runner**:
  - Configure GitHub Actions as a self-hosted runner in the Bastion host created from Terraform that manages the EKS cluster. 



## Repository Structure
```bash
DevOps-EKS-GitOps-ActionFlow/
├── .gitignore
├── README.md
├── app/
│   ├── Dockerfile
│   ├── index.html
│   ├── login.html
│   ├── signup.html
│   ├── nginx.conf
│   ├── css/
│   ├── fonts/
│   ├── images/
│   ├── js/
│   ├── scss/
│   └── background.jpg
├── argocd-app-of-apps.yaml
├── argocd-apps/
│   ├── deployment-app.yaml
│   ├── ingress-app.yaml
│   ├── namespace-app.yaml
│   └── service-app.yaml
├── infrastructure/
│   ├── data/
│   │   ├── alb_data/
│   │   ├── argocd_data/
│   │   ├── autoscaler_data/
│   │   ├── bastion_data/
│   │   ├── metrics_server_data/
│   │   └── prometheus_data/
│   ├── module/
│   │   ├── alb/
│   │   ├── app/
│   │   ├── autoscaler/
│   │   ├── bastion_host/
│   │   ├── ecr/
│   │   ├── eks/
│   │   ├── promethous-and-grafana/
│   │   └── vpc/
│   └── production/
│       ├── main.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       ├── output.tf
│       ├── variables.tf
│       ├── myplan
│       └── README.md
├── kubernetes/
│   ├── deployment/
│   │   └── deployment-def.yml
│   ├── ingress/
│   │   └── ingress.yaml
│   ├── namespace/
│   │   └── namespace-def.yml
│   ├── service/
│   │   └── service-def.yml
└── .github/workflows/
    └── CI.yml

```

## Features
- **Infrastructure as Code (IaC)**: Terraform modules are used to define and manage AWS infrastructure.
- **Modular & Scalable Design**: Easily extend or modify components as needed.
- **GitOps Workflow**: ArgoCD handles deployments using the App of Apps pattern.
- **CI/CD Integration**:
  - **GitHub Actions** automates the build and deployment process.
  - **ArgoCD** ensures continuous deployment in the Kubernetes cluster.
- **Monitoring & Observability**: Prometheus and Grafana provide real-time metrics and dashboards.

## Prerequisites
- **AWS Account** with proper IAM permissions.
- **Terraform** installed (`>=1.3.0`).
- **kubectl** and **helm** installed for Kubernetes management.
- **ArgoCD CLI** for managing ArgoCD applications.
- **GitHub Actions** configured with required AWS secrets.

## Deployment Steps
### 1. Clone the Repository
```bash
git clone https://github.com/ziyad-tarek1/DevOps-EKS-GitOps-ActionFlow.git
cd DevOps-EKS-GitOps-ActionFlow
```

### 2. Set Up AWS Credentials
Ensure that AWS credentials are configured in `~/.aws/credentials` or as environment variables:
```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_REGION=us-east-1
```

### 3. Initialize and Apply Terraform
```bash
cd infrastructure/production
terraform init
terraform plan
terraform apply -auto-approve
```

### 4. Configure Kubernetes Cluster with the installed add-ons
```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks
```

![image](https://github.com/user-attachments/assets/d9efaa68-5b25-448a-9550-7ee826ad3b12)


### 5. Create Kubernetes Secret for ECR
```bash
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=135808945423.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1)
```


### 6. Configure GitHub Actions
  1. Create a new self-hosted runner from **Settings > Actions > Runners**.
![image](https://github.com/user-attachments/assets/51064f07-09cb-4d1e-9d7d-aa2a4714057a)

![image](https://github.com/user-attachments/assets/b9d69e84-b37d-4a93-882d-5bd11ad3e52f)

![image](https://github.com/user-attachments/assets/adb8f41d-ba5c-48e1-a089-8fa508183a8f)

![image](https://github.com/user-attachments/assets/d7b37f19-e253-4ef7-bb5b-a489a1a4cea5)
  
  2- Update **Secrets** in GitHub repository settings:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `AWS_REGION`
    - `ECR_REPOSITORY`
  
![image](https://github.com/user-attachments/assets/eb153260-5853-4cb6-94a7-383eacf8277b)



### 7. Trigger CI Pipeline
Push changes to GitHub and let GitHub Actions handle the deployment:
```bash
git add .
git commit -m "Deploy application"
git push origin main
```
![image](https://github.com/user-attachments/assets/8b94d282-9e62-404a-8ba8-4d4ac8bb4bd6)


### 8. Access ArgoCD Console
1- change the svc type to LoadBalancer 
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
```

To get the initial password: (Default Username Login: admin)

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
```

### 9. Trigger CD Pipeline and add web-hook 
- Run The App of Apps 
```bash
kubectl create -f argocd-app-of-apps.yaml 
```

![image](https://github.com/user-attachments/assets/7f36f1de-b3fc-48a5-af9e-690045302ced)


![image](https://github.com/user-attachments/assets/bcd4961c-7a2f-4de7-9591-524df69df139)

## 10. Monitoring and Observability
After deployment, access Prometheus and Grafana:
- **Prometheus**: `http://<load-balancer-ip>:9090`
- **Grafana**: `http://<load-balancer-ip>:3000` (Default Username Login: admin)

```bash
kubectl edit svc prometheus-kube-prometheus-prometheus -n prometheus  # to access the prometheus dashboard
kubectl edit svc prometheus-grafana -n prometheus      # to access the grafana dashboard 
```

Retrieve Grafana Default Password:
```bash
kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 -d
```

### Prometheus Dashboard
![image](https://github.com/user-attachments/assets/95f71efa-5698-424b-afb9-6fcc685ce2c1)

### Grafana Dashboard

![image](https://github.com/user-attachments/assets/a389239d-e751-4f0c-ba6b-bd9ca662afcf)

## 11. Access the Application Ingress Service

![image](https://github.com/user-attachments/assets/f4ca16a6-aaf9-4df5-88d1-a3d9f036e7eb)

## Cleanup
To remove all deployed resources:
```bash
cd infrastructure/production
terraform destroy -auto-approve
```

## Contributing
Feel free to open issues and submit pull requests for improvements!

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For any queries, reach out via:
- GitHub: [ziyad-tarek1](https://github.com/ziyad-tarek1)
- Email: ziyadtarek180@gmail.com

