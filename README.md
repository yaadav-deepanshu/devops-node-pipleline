# DevOps Node Pipeline

## Overview

This project implements a CI/CD pipeline for a Node.js application (forked from [SwayattDrishtigochar/devops-task](https://github.com/SwayattDrishtigochar/devops-task)) using Jenkins, AWS ECS Fargate, Docker, and Terraform. The app is a simple Express.js server that serves a logo image (`logoswayatt.png`) on port 3000.

## Features

- **App**: Express.js server serving `logoswayatt.png`.
- **CI/CD**: Jenkins pipeline for automated build, test, Dockerize, and deployment.
- **Infra**: AWS ECS Fargate, ECR, ALB, and CloudWatch, provisioned with Terraform.
- **Branching**: `main` for production, `dev` for integration.

## Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/yaadav-deepanshu/devops-node-pipleline.git
   cd devops-node-pipleline
   ```
