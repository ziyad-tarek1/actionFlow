# DevOps-EKS-GitOps-ActionFlow

![githubactionflow](https://github.com/user-attachments/assets/9c0e3c5e-3bba-4e76-a2d9-29036f46140c)


## Overview
This project implements a GitOps-driven Continuous Deployment (CD) pipeline using GitHub Actions, Terraform, Docker, Amazon EKS, and ArgoCD. It automates Infrastructure as Code (IaC) provisioning, containerized application deployment, and Kubernetes orchestration.

## Features
- **AWS VPC Setup:**
  - 2 Public and 2 Private Subnets
- **Amazon EKS (Elastic Kubernetes Service):**
  - AWS ALB (Application Load Balancer) integration
- **Monitoring Stack:**
  - Prometheus and Grafana
- **GitOps-based Continuous Deployment:**
  - Uses ArgoCD with the App of Apps pattern
- **Amazon ECR (Elastic Container Registry):**
  - Container image storage and management

## CI/CD Pipeline
This project uses **GitHub Actions & ArgoCD** as the CI/CD controller.

### Workflows
1. **Infrastructure as Code (IaC) Workflow** (`iac-feature.yaml`)
   - Runs on the `iac-feature` branch
   - Executes Terraform commands:
     - `terraform init`
     - `terraform fmt`
     - `terraform validate`
     - `terraform plan`
     - Pushes the formatted changes to `infrastructure/`
   - Triggers only when changes occur in the `infrastructure/` directory of this branch

2. **Infrastructure Deployment Workflow** (`Infrastructure-Deployment.yaml`)
   - Requires a manual trigger
   - Runs Terraform commands:
     - `terraform init`
     - `terraform apply`
   - Deploys infrastructure changes to AWS and uses S3 as terraform Backend

3. **Application CI/CD Workflow** (`App-CI.yaml`)
   - Runs on the `main` branch when changes occur in the `app/` directory
   - Steps:
     - Run HTML & CSS Linting
     - Build Docker Image
     - Run Container & Test
     - Trivy Security Scan
     - Log in to Amazon ECR
     - Build, Tag, and Push Docker Image to AWS ECR
     - Update Kubernetes Deployment Manifest with the new image tag (`github.run_number`)
     - Commit and Push updated Kubernetes manifests

## Secrets Required
To run GitHub Actions workflows, configure the following secrets in your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `ECR_REPOSITORY`

## Continuous Deployment (CD) with ArgoCD
ArgoCD handles the deployment of Kubernetes resources using the **App of Apps pattern**.

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



## Prerequisites
- **AWS Account** with proper IAM permissions.
- **Terraform** installed (`>=1.3.0`).
- **kubectl** and **helm** installed for Kubernetes management.
- **ArgoCD CLI** for managing ArgoCD applications.
- **GitHub Actions** configured with required AWS secrets.


## Deployment Steps
To deploy the project, follow these steps:

1. **Fork the Repository**
   - Navigate to [DevOps-EKS-GitOps-ActionFlow](https://github.com/ziyad-tarek1/DevOps-EKS-GitOps-ActionFlow).
   - Click `Fork` to create a copy in your GitHub account.

2. **Setup GitHub Secrets**
   - Go to your forked repository.
   - Navigate to `Settings` > `Secrets and variables` > `Actions`.
   - Add the required secrets listed above.

3. **Configure Terraform Backend**
   - Modify the `backend.tf` file under `infrastructure/production/` to point to your Terraform state backend (e.g., S3 for AWS).

4. **Run Infrastructure Deployment**
   - Create a new branch (`iac-feature`) and push changes to trigger `iac-feature.yaml`.
   - Manually trigger `Infrastructure-Deployment.yaml` from the GitHub Actions tab to provision the infrastructure.

5. **Deploy Application**
   - Push changes to the `app/` directory in the `main` branch to trigger `App-CI.yaml`.
   - ArgoCD will automatically deploy the application to Kubernetes.


### **6. Configure Kubernetes Cluster**  
Once the infrastructure is deployed, configure `kubectl` to manage the EKS cluster:  
```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks
```

![image](https://github.com/user-attachments/assets/d9efaa68-5b25-448a-9550-7ee826ad3b12)


### **7. Create Kubernetes Secret for ECR**  
Run the following command to create a Kubernetes secret for Amazon ECR authentication:  
```bash
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=135808945423.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1)
```


### **8. Deploy Application**  
#### **8.1 Push Changes to Trigger CI Pipeline**  
- Push any modifications to the `app/` directory on the `main` branch to trigger `App-CI.yaml`:  
```bash
git add app/
git commit -m "Deploy application"
git push origin main
```
![image](https://github.com/user-attachments/assets/8b94d282-9e62-404a-8ba8-4d4ac8bb4bd6)


### **9. Access ArgoCD Console**  
#### **9.1 Change ArgoCD Service Type to LoadBalancer**  
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
```

#### **9.2 Retrieve ArgoCD Login Credentials**  
To get the initial password (Default Username: `admin`):  
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
```

### **10. Trigger CD Pipeline & Add Webhook**  
#### **10.1 Deploy ArgoCD App of Apps**  
```bash
kubectl create -f argocd-app-of-apps.yaml 
```

![image](https://github.com/user-attachments/assets/7f36f1de-b3fc-48a5-af9e-690045302ced)


![image](https://github.com/user-attachments/assets/bcd4961c-7a2f-4de7-9591-524df69df139)


### **11. Monitoring & Observability**  
#### **11.1 Access Prometheus & Grafana**  
Once deployed, access monitoring dashboards:  
- **Prometheus**: `http://<load-balancer-ip>:9090`  
- **Grafana**: `http://<load-balancer-ip>:3000` (Default Login: `admin`)  

#### **11.2 Configure Access to Dashboards**  
```bash
kubectl edit svc prometheus-kube-prometheus-prometheus -n prometheus  # Access Prometheus Dashboard
kubectl edit svc prometheus-grafana -n prometheus                     # Access Grafana Dashboard
```

#### **11.3 Retrieve Grafana Default Password**  
```bash
kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 -d
```

### Prometheus Dashboard
![image](https://github.com/user-attachments/assets/95f71efa-5698-424b-afb9-6fcc685ce2c1)

### Grafana Dashboard

![image](https://github.com/user-attachments/assets/a389239d-e751-4f0c-ba6b-bd9ca662afcf)

### **12. Access the Application Ingress Service**  
Once deployed, navigate to the **Ingress Service** to access your application.

![image](https://github.com/user-attachments/assets/f4ca16a6-aaf9-4df5-88d1-a3d9f036e7eb)

### **13. Cleanup (Destroy Infrastructure)**  
If you want to remove all deployed resources, run:  
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

