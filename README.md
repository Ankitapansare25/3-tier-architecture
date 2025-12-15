# AWS 3-Tier Architecture using Terraform

## 📌 Project Overview

This project demonstrates how to provision a **3-Tier Architecture on AWS using Terraform**. It is designed to showcase real-world DevOps and cloud infrastructure skills suitable for **freshers and entry-level roles**.

The architecture follows best practices by separating the **Web, Application, and Database layers** using public and private subnets, security groups, and a NAT Gateway.

## 🧱 Architecture Components

### 1️⃣ Network Layer

* VPC
* Public Subnet (Web Tier)
* Private Subnet (App Tier)
* Private Subnet (DB Tier)
* Internet Gateway
* NAT Gateway
* Elastic IP
* Public & Private Route Tables

### 2️⃣ Compute Layer

* EC2 instance for Web Server (Public Subnet)
* EC2 instance for Application Server (Private Subnet)
* EC2 instance for Database Server (Private Subnet)

### 3️⃣ Security Layer

* Web Security Group: Allows HTTP (80) and SSH (22) from internet
* App Security Group: Allows traffic only from Web SG (port 8080)
* DB Security Group: Allows MySQL traffic only from App SG (port 3306)

---

## 🔐 Security Group Flow

* Internet → Web Server (HTTP/SSH)
* Web Server → App Server (8080)
* App Server → Database Server (3306)

---

## 🛠️ Tools & Technologies Used

* AWS (EC2, VPC, Subnets, IGW, NAT Gateway, EIP)
* Terraform
* Git & GitHub

---


## 🚀 How to Deploy
1. Initialize Terraform

```bash
terraform init
```

2. Plan terraform

```bash
terraform validate
terraform plan
```

3. Apply the configuration

```bash
terraform apply
```

---

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

---

## 🎯 Learning Outcomes

* Hands-on experience with AWS networking
* Understanding of 3-tier architecture
* Infrastructure as Code using Terraform
* Security best practices using Security Groups

---

