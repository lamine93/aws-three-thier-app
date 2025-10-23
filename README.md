# 🏗️ Three-Tier Web Application on AWS

This project deploys a **three-tier web application** architecture on **AWS** using **Terraform**.  
It consists of a **frontend**, a **backend API (Flask)** running on **ECS Fargate**, and a **PostgreSQL database** hosted on **Amazon RDS**.  
An **Application Load Balancer (ALB)** routes incoming HTTP traffic to the backend running in private subnets.

---

## 🧠 Architecture Overview

```mermaid
graph TD
    A[User] -->|HTTP| B[ALB - Public Subnets]
    B -->|Forward Traffic| C[ECS Service (Fargate) - Private Subnets]
    C -->|DB Connection| D[(Amazon RDS - PostgreSQL)]
    C -->|Secrets| E[AWS Secrets Manager]
    F[S3 - Frontend Static Site] -->|Optional| A

