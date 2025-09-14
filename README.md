# Node.js CI/CD Pipeline with Terraform and Jenkins

This project sets up a streamlined CI/CD pipeline for a Node.js application, designed with care to automate the build, test, and deployment process. It’s built to be scalable, secure, and aligned with modern DevOps practices, making development and deployment smooth and reliable.

## Project Overview
The goal of this project is to create an automated pipeline that takes a Node.js application from code to production with minimal manual effort. It uses a combination of industry-standard tools to ensure consistency, security, and maintainability.

**Tools & Services Used:**
- **GitHub**: Manages the source code with `main` and `dev` branches for clear version control.
- **Jenkins**: Orchestrates the CI/CD pipeline, automating builds, tests, and deployments.
- **Docker**: Packages the application into containers for consistent and portable deployments.
- **AWS**:
  - **EC2**: Hosts the Jenkins server.
  - **ECS Fargate**: Runs the containerized Node.js application.
  - **ECR**: Stores Docker images securely.
  - **ALB**: Routes traffic to the application.
  - **CloudWatch**: Tracks logs and performance metrics.
- **Terraform**: Defines and provisions AWS infrastructure as code.

The pipeline ensures that code changes are automatically built, tested, and deployed, following best practices for DevOps workflows.

## Repository Structure
```
devops-node-pipeline/
├── terraform/                  # Infrastructure as Code files
│   ├── main.tf                # Defines ECS, ALB, Jenkins EC2, and security groups
│   ├── variables.tf           # Configurable variables for Terraform
│   ├── provider.tf            # AWS provider and S3 backend setup
│   └── outputs.tf             # Outputs like ALB URL, Jenkins IP, and ECR repo
├── nodejs-app/                # Node.js application source code
├── deployment-proof/          # Screenshots or public URL for deployment proof
├── docs/                      # Documentation and architecture diagram
│   └── architecture.png       # Visual overview of the pipeline
├── Jenkinsfile                # Jenkins pipeline configuration
├── Dockerfile                 # Docker image definition for the Node.js app
├── README.md                  # Project documentation
└── WRITEUP.md                 # Details on tools, challenges, and improvements
```

## Architecture Diagram
![Architecture Diagram](docs/architecture.png)

The architecture is thoughtfully designed for efficiency:
- **GitHub**: Stores the Node.js app code with a clear branching strategy (`main`, `dev`).
- **Jenkins**: Triggers the pipeline on code pushes, handling builds and deployments.
- **AWS ECR**: Securely stores Docker images.
- **AWS ECS Fargate**: Runs the app in a serverless container environment.
- **AWS ALB**: Directs traffic to ECS tasks.
- **CloudWatch**: Provides real-time logging and monitoring.
- **Terraform**: Manages all AWS resources declaratively.

## Setup Instructions

### Prerequisites
- An AWS account with programmatic access (access key and secret key).
- Terraform installed (version `>= 1.5.0`).
- A Jenkins server with Docker, Node.js, AWS CLI, and required plugins.
- A GitHub repository forked or cloned from [devops-task](https://github.com/SwayattDrishtigochar/devops-task).
- Docker installed on the Jenkins server.

### Step-by-Step Setup
1. **Clone the Repository**  
   ```bash
   git clone https://github.com/<your-username>/devops-node-pipeline.git
   cd devops-node-pipeline
   ```

2. **Set Up Terraform**  
   - Navigate to the `terraform/` directory.
   - Configure AWS credentials (via `~/.aws/credentials` or environment variables).
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Review and apply infrastructure changes:
     ```bash
     terraform plan
     terraform apply
     ```

3. **Configure Jenkins**  
   - Access Jenkins via the EC2 public IP on port `8080`.
   - Install plugins: `Docker`, `AWS`, and `GitHub Integration`.
   - Set up a GitHub webhook to trigger the pipeline on code pushes.
   - Add AWS and ECR credentials in Jenkins for secure access.

4. **Run the Pipeline**  
   - Create a pipeline job in Jenkins, linking it to the `Jenkinsfile`.
   - Push changes to the `dev` branch to start the pipeline.

5. **Access the Application**  
   - Get the ALB DNS name from Terraform outputs:
     ```bash
     terraform output alb_dns_name
     ```
   - Open the URL in a browser to view the deployed Node.js app.

6. **Monitor Logs and Metrics**  
   - **Logs**: Check ECS task logs in CloudWatch > Log Groups.
   - **Metrics**: View CPU, memory, and network metrics in CloudWatch > Metrics.

## Pipeline Flow
The Jenkins pipeline, defined in the `Jenkinsfile`, automates these stages:
1. **Checkout**: Pulls the latest code from the `dev` branch on GitHub.
2. **Build**: Installs Node.js dependencies and runs tests (`npm install && npm test`).
3. **Dockerize**: Builds a Docker image using the `Dockerfile`.
4. **Push to ECR**: Uploads the image to AWS ECR.
5. **Deploy to ECS**: Updates the ECS service with the new image.

**Best Practices**:
- Avoids hardcoded credentials by using IAM roles or Jenkins credentials (commit `e23f795`).
- Cleans the workspace before each build.
- Includes detailed logging for easier troubleshooting.

## Docker Setup
The `Dockerfile` creates a clean and efficient container:
- **Base Image**: `node:18-alpine` for a lightweight and secure setup.
- **Steps**:
  - Copies the application code.
  - Installs dependencies (`npm install`).
  - Exposes port `3000`.
  - Runs the app with `node server.js`.
- **Optimization**: Excludes unnecessary files, like the `terraform/` folder, for a smaller image (commit `c7bbb2a`).

## Infrastructure Details
### Terraform Configuration
- **Files**:
  - `provider.tf`: Sets up the AWS provider and S3 backend for state storage (commit `6f50fed`).
  - `variables.tf`: Defines parameters like `region` and `ami_id` (commit `40f3c75`).
  - `main.tf`: Provisions:
    - Jenkins EC2 instance with Docker, Node.js, and AWS CLI (commit `3bc9a05`).
    - ECS Fargate cluster and service (commit `371ac46`).
    - ECR repository for Docker images (commit `371ac46`).
    - ALB with target group and listener on port `80` (commit `371ac46`).
    - Security groups for ALB, ECS, and Jenkins (commit `76cefbe`).
    - IAM roles for ECS execution and Jenkins.
  - `outputs.tf`: Provides ALB DNS, Jenkins IP, and ECR URL (commit `ccfa170`).

- **Security**:
  - IAM roles follow the principle of least privilege.
  - Terraform state is stored in an encrypted S3 bucket (commit `6f50fed`).
  - Credentials are managed securely via Jenkins or AWS Secrets Manager (commit `e23f795`).

## Monitoring & Logging
- **CloudWatch**:
  - **Logs**: ECS task logs are stored in CloudWatch Log Groups for debugging.
  - **Metrics**: Tracks CPU, memory, and network usage for ECS tasks.
- **Access**:
  - Logs: Navigate to CloudWatch > Log Groups > ECS log group.
  - Metrics: Check CloudWatch > Metrics > ECS > Cluster metrics.

## Deployment Proof
- **Public URL**: Available via the ALB DNS name (from Terraform outputs).
- **Screenshots**: Stored in the `deployment-proof/` folder, showing:
  - Successful Jenkins pipeline execution.
  - Running ECS service.
  - ALB URL response.

## Write-Up
### Tools & Services Used
- **GitHub**: Manages code with `main` and `dev` branches for smooth integration (commit `79f6798`).
- **Jenkins**: Automates the pipeline with build, test, and deploy stages (commits `d066125`, `499b9de`).
- **Docker**: Ensures consistent deployments with a production-ready container (commit `d63eaad`).
- **AWS**:
  - **EC2**: Runs the Jenkins server (commits `3bc9a05`, `9b16734`).
  - **ECS Fargate**: Hosts the containerized app (commit `371ac46`).
  - **ECR**: Stores Docker images (commit `371ac46`).
  - **ALB**: Routes traffic to ECS (commit `371ac46`).
  - **CloudWatch**: Provides logging and monitoring.
- **Terraform**: Provisions infrastructure with modular, reusable files (commits `f4ff138`, `163a81c`).

### Challenges Faced & Solutions
- **Challenge**: Issues with Docker pulling images in the Jenkins pipeline.  
  - **Solution**: Configured IAM roles for Jenkins EC2 to access ECR properly and verified Docker daemon setup (commit `e23f795` removed hardcoded credentials).  
- **Challenge**: Subnet CIDR conflicts in Terraform setup.  
  - **Solution**: Corrected CIDR ranges in `variables.tf` and updated `main.tf` references (commits `f0abe09`, `2dadcda`).  
- **Challenge**: Jenkins EC2 user_data script failures during installation.  
  - **Solution**: Fixed installation scripts in `main.tf` and upgraded to Java 17 for compatibility (commits `3bc9a05`, `79e6716`).  
- **Challenge**: Incorrect public IP assignment for Jenkins EC2.  
  - **Solution**: Updated `main.tf` to assign the public IP correctly (commit `9b16734`).  
- **Challenge**: Syntax errors in ECS service configuration in the Jenkinsfile.  
  - **Solution**: Fixed `ECS_SERVICE` syntax to ensure proper deployment (commit `ce7570c`).

### Possible Improvements
- **Modular Terraform Files**: Split `main.tf` into separate files for ECS, ECR, EC2, security groups, and networking to improve readability and maintainability.
- **Automated Rollbacks**: Add pipeline logic to revert to a previous stable version if a deployment fails.
- **Enhanced Testing**: Include unit and integration tests in the pipeline for better code quality.
- **Advanced Monitoring**: Integrate Prometheus and Grafana for more detailed metrics and visualizations.
- **Blue-Green Deployments**: Implement zero-downtime deployments using ECS blue-green strategies.

## References
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [AWS ECS Fargate](https://aws.amazon.com/fargate/)
- [Docker Documentation](https://docs.docker.com/)

## Submission
- **Repository**: https://github.com/<your-username>/devops-node-pipeline
- **Submission Link**: [Google Form](https://forms.gle/otmnfQvxiBh4YLW1A)
- **Deadline**: Midnight, September 14, 2025