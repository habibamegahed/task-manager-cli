Task Manager - Docker Project

A simple Task Manager web application** built with Flask and containerized using Docker.  
This project demonstrates how to run a multi-service application using **Docker Compose**, including a web server, database, cache, and load balancer.

---

 Overview

The application allows users to add and view tasks through a simple web interface and REST API.

The system architecture includes:

- **Flask** for the backend application
- **Gunicorn** as the production server
- **Nginx** as a reverse proxy and load balancer
- **PostgreSQL** for storing tasks
- **Redis** for caching
- **Docker Compose** to orchestrate all services

---

 System Architecture

```
Client
  |
  v
Nginx (Reverse Proxy / Load Balancer)
  |               |
  v               v
Flask App 1    Flask App 2
      \           /
       \         /
        PostgreSQL
             |
           Redis
```

This setup simulates a **scalable production-like environment**.

---

 Technologies Used

- Python (Flask)
- Gunicorn
- Nginx
- PostgreSQL
- Redis
- Docker
- Docker Compose
- Bash / Linux

---

 Project Structure

```
taskmanager
│
├── docker-compose.yml
├── Dockerfile
├── flask_app.py
├── requirements.txt
├── init.sql
│
├── conf
│   └── nginx.conf
│
├── ssl
│   └── generate_ssl.sh
│
└── static
    └── style.css
```

---

 How to Run the Project

 Clone the repository

```bash
git clone https://github.com/habibamegahed/taskmanager.git
cd taskmanager
```

 Generate SSL certificate

```bash
cd ssl
chmod +x generate_ssl.sh
./generate_ssl.sh
cd ..
```

 Start the containers

```bash
docker compose up --build
```

---

 Access the Application

Open your browser and go to:

```
http://localhost
```

or

```
https://localhost
```

---

 API Endpoints

**Get all tasks**

```
GET /api/tasks
```

Add new task

```
POST /api/tasks
```

Example request body:

```json
{
  "title": "Learn Docker",
  "priority": "high"
}
```

**Health Check**

```
GET /api/health
```

---

 Learning Outcomes

Through this project I practiced:

- Building containerized applications
- Using Docker Compose for service orchestration
- Configuring Nginx as a reverse proxy
- Load balancing between multiple containers
- Integrating PostgreSQL and Redis
- Implementing HTTPS using self-signed SSL certificates

---

 Author

Habiba Megahed

GitHub:  
https://github.com/habibamegahed

 🏷️ Tags

Docker • DevOps • Flask • Nginx • PostgreSQL • Redis • Containerization
