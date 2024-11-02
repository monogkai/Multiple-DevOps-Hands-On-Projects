# Deploying Starbucks Clone on AWS EKS using DevSeOps Approach

Steps:
1) Create a AWS instance
    - Name "deploying-starbucks"
    - Select ubuntu
    - Select t2.xlarge
    - Create a new key pair named "deploying-starbucks-key-pair"
    - Create a new security group
    - In Configure storage section, select 1 x 30 GiB gp3
    - Identify the Public IP: 13.39.242.27
    - Connect locally to the instance created
        - Open an SSH client.
        - Locate your private key file. The key used to launch this instance is deploying-starbucks-key-pair.pem
        - chmod 400 "deploying-starbucks-key-pair.pem"
        - ssh -i "deploying-starbucks-key-pair.pem" ubuntu@13.39.242.27

    ![Alt text](images/ec2-instance-created.png)

2) Install "installer.sh" dependencies in the instance

3) Run docker to run Sonarqube
    - docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
    - docker ps
    - Use http://13.39.242.27:9000

4) Configure Jenkins account
    - Login using using http://13.39.242.27:8080
        - Use "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" in AWS CLI to get the admin password
        - Create Jenkins user
    - Add plugins
        - Eclipse Temurin installer
        - Sonarqube Scanner
        - NodeJs
        - OWASP Dependency-Check
        - Docker
        - Docker Commons
        - Docker Pipeline
        - Docker API
        - docker-build-step
        - Pipeline: Stage View
        - Prometheus metrics
        - Email Extension Template
    - Click "Restart Jenkins when installation is complete and no jobs are running" option

5) Configure Sonarqube
    - Login (admin, admin)
    - Change password
    - Create token

4) Configure tools in Jenkins account
    - Go to Dashboard > Manage Jenkins > Tools
    - JDK installations: select jdk17, Install from adoptium.net, jdk-17.0.8.1+1
    - SonarQube Scanner installations: select sonar-scanner, Install from Maven Central, SonarQube Scanner 6.2.0.4584
    - NodeJS installations, node16, Install from nodejs.org, NodeJS 16.20.0
    - Dependency-Check installations, DP-Check, Install from github.com dependency-check 10.0.4
    - Docker installations: docker, latest

5) Add credentials in Jenkins account
    - Go to Dashboard > Manage Jenkins > Credentials
    - Click global
    - Add sonar credential: Use the token created and the name is "Sonar-token"
    - Add docker credential: Use my email has username and the name used is docker-cred
    - Add Gmail credentials: it's necessary to create a App password in Gmail named "jenkins". The credential name is "mail-cred"

6) Configure System in Jenkins account
    - In SonarQube servers, add a "sonar-server" and the Server Url is "http://13.39.242.27:9000". In "Server authentication token", select "Sonar-token"
    - In Extended E-mail Notification, add "smtp.gmail.com" in SMTP server. Add "465" in "SMTP Port"
        - Click in Advanced, and select "Use SSL" and select "Use OAuth 2.0". And select "docker-cred" in Credentials
    - In E-mail Notification, add "smtp.gmail.com" in SMTP server. I click on the Advanced, select "Use SMTP Authentication", add my email in username, use the password generated. Select Use SSL. Add "465" in "SMTP Port". Add email in "Reply-To Address". I select "Test configuration by sending test email" using my email
    - Build triggers: select always, failure - any, success

7) Create new item named "amazon-starbucks"
    - Paste the pipeline script and change the email in this content
    - Trigger pipeline

8) Create a webhook in SonarQube
    - Name: "jenkins"
    - URL: "http://13.38.54.236:8080/sonarqube-webhook/"

9) Create a second instance to be used to do the remaining tasks
    - Name: monitering-server
    - Use the sane security-group and key-pair
    - Access the instance via terminal
        - chmod 400 "deploying-starbucks-key-pair.pem"
        - ssh -i "deploying-starbucks-key-pair.pem" ubuntu@13.39.242.27

10) Configure monitoring tools
    - Install Prometheus run the commands
    - Open with http://15.236.35.79:9090
    - Install Node Explorer
    - Complete node_explorer.service file
    - Configure prometheus.yml, adding two new jobs: node_explorer and jenkins. In the main directory
    - Go to Targets in the Prometheus
    - Install Grafana using commands
    - Access the Grafana using http://15.236.35.79:9090
    - Add data-source option
    - Select Prometheus
    - In Prometheus URL, add http://15.236.35.79:9090. Save and test
    - Go to Dashboards, import 1860 dashboard (https://grafana.com/grafana/dashboards/1860-node-exporter-full/) and select Prometheus
    - Verify that the graphics are shown and save the dashboard
    - Get the Jenkins Grafana Dashboard Id 9964: https://grafana.com/grafana/dashboards/9964-jenkins-performance-and-health-overview/
    - Create Grafana dashboard and save it

11) Create EKS (Use https://github.com/yeshwanthlm/Learn-AWS-EKS/blob/main/Day1.md)
    - Install eksctl in command line using:
        brew tap weaveworks/tap
        brew install eksctl
    - It's necessary to exist a IAM with the correct permissions
    - Run command:
        - eksctl create cluster --name=monogkai \
            --region=eu-west-3 \
            --zones=eu-west-3a,eu-west-3b \
            --without-nodegroup \
            --profile monokai
        - eksctl get cluster
    - Error occurred
        - Remove Elastic IPs
        - It was necessary the complete the ~/.aws/config, and add monokai. Not using the default one
    - Run command
        - eksctl utils associate-iam-oidc-provider \
            --region eu-west-3 \
            --cluster monogkai \
            --approve --profile monokai
    - Run command
        - eksctl utils associate-iam-oidc-provider \
            --region eu-west-3 \
            --cluster monogkai \
            --approve
        - eksctl utils associate-iam-oidc-provider --region eu-west-3 --cluster monogkai --approve --profile monokai
    - Run command
        eksctl create nodegroup --cluster=monogkai \
            --region=eu-west-3 \
            --name=monokai-ng-public1 \
            --node-type=t3.medium \
            --nodes=2 \
            --nodes-min=2 \
            --nodes-max=4 \
            --node-volume-size=20 \
            --ssh-access \
            --ssh-public-key=deploying-starbucks-key-pair \
            --managed \
            --asg-access \
            --external-dns-access \
            --full-ecr-access \
            --appmesh-access \
            --alb-ingress-access --profile monokai
    - Use http://13.39.242.27:3000/ to see the application
    - Use "kubectl get nodes" to verify the existing nodes

12) Monitor Kubernetes with Prometheus
    - Use https://archive.eksworkshop.com/intermediate/290_argocd/install/
    -   Install ArgoCD
        - kubectl create namespace argocd
        - kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
        - kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
        - kubectl get pods -n argocd
    - Add the Prometheus Community Helm repository
        - brew install helm
        - helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        - kubectl create namespace prometheus-node-exporter
        - helm install prometheus-node-exporter prometheus-community/prometheus-node-exporter --namespace prometheus-node-exporter
        - export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
        - echo $ARGOCD_SERVER
        - Browser "a301e07d69fcf42b688a5206c56b1f7b-139841734.eu-west-3.elb.amazonaws.com"
        - export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
        - echo $ARGO_PWD
        - Use the username admin and the password to login
        - Manage repositories
        - Connector repository using HTTPS:
            - Type: Git
            - Repository URL: https://github.com/yeshwanthlm/Prime-Video-Clone-Deployment.git
            - Connect
        - Create a new app:
            - Application name: starbucks
            - Sync policy: Automatic
            - Source Repository URL: https://github.com/yeshwanthlm/Prime-Video-Clone-Deployment.git
            - Destination Cluster URL: https://kubernetes.default.svc
            - Destination Path: Kubernetes (the name of folder inside the repository)
            - Create
            - Verify the files inside the Kubernetes folder,  files
        - Update prometheus.yml file
            - Add new job for Prometheus
        - Add Port 30001 inbound rule in the "monogkai-monokai-ng-public1-Node"
        - Browser http://13.38.17.202:30001/
        - Add Port 9100 inbound rule in the "monogkai-monokai-ng-public1-Node" and then verify the Prometheus Targets

13) Delete Node Group
    # List EKS Clusters
    eksctl get clusters

    # Capture Node Group name
    eksctl get nodegroup --cluster=<clusterName>
    eksctl get nodegroup --cluster=amcdemo

    # Delete Node Group
    eksctl delete nodegroup --cluster=<clusterName> --name=<nodegroupName>
    eksctl delete nodegroup --cluster=amcdemo --name=amcdemo-ng-public

14) Delete Cluster
    # Delete Cluster
    eksctl delete cluster <clusterName>
    eksctl delete cluster amcdemo

    1:41:28
    https://www.youtube.com/watch?v=uaiuUGg5gLE&t=862s
    http://13.39.242.27:8080/job/amazon-starbucks/
    http://15.236.35.79:9090/targets?search=
    http://15.236.35.79:3000/d/rYdddlPWk/node-exporter-full?from=now-30m&to=now&timezone=browser&var-datasource=de21kbc03rq4gf&var-job=node_exporter&var-node=15.236.35.79:9100&var-diskdevices=%5Ba-z%5D%2B%7Cnvme%5B0-9%5D%2Bn%5B0-9%5D%2B%7Cmmcblk%5B0-9%5D%2B&refresh=1m
    https://github.com/yeshwanthlm/Prime-Video-Clone-Deployment


## References
- https://www.youtube.com/watch?v=uaiuUGg5gLE&t=862s