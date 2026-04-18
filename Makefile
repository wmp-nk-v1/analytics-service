docker-build:
	git pull
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 293222827824.dkr.ecr.us-east-1.amazonaws.com
	docker build -t 293222827824.dkr.ecr.us-east-1.amazonaws.com/analytics-service:${image_tag} .
	docker push 293222827824.dkr.ecr.us-east-1.amazonaws.com/analytics-service:${image_tag}

eks-deploy:
	env
	aws eks update-kubeconfig --name dev
	helm upgrade -i analytics-service helm -f helm/values/analytics-service.yml --set image.tag=${image_tag}

argocd-deploy:
	argocd login $(argocd_server) --insecure --username admin --password $(argocd_admin_password)
	argocd app create analytics-service --sync-policy auto --repo https://github.com/nikkaushal/wmp-helm-v1.git --path . --dest-server https://kubernetes.default.svc   --dest-namespace default --helm-set-string image.tag=$(image_tag) --values values/analytics-service.yml --upsert