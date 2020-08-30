deploy: elf pro-graf jenkins

up: cluster up

cluster:
	k3d cluster create epsilon \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --agents 3

jenkins: jenkins-clone jenkins-up jenkins-test jenkins-tidy

jenkins-clone:
	git clone https://github.com/amerahsultan1/k8s-jenkins-epsilon

jenkins-up:
	cd k8s-jenkins-epsilon && ./jenkins.sh

jenkins-test:
	curl -L localhost/jenkins

jenkins-tidy:
	rm -rf k8s-jenkins-epsilon

jenkins-down:
	cd k8s-jenkins-epsilon && kubectl delete jenkins.helm.yaml

elf: elf-clone elf-up elf-test elf-tidy

elf-clone:
	git clone https://github.com/amerahsultan1/epsilon-elf

elf-up:
	cd epsilon-elf && ./elf.sh

elf-test:
	curl localhost/elf

elf-tidy:
	rm -rf epsilon-elf

elf-down:
	helm uninstall elasticsearch --namespace=elf
	helm uninstall fluent-bit --namespace=elf
	helm uninstall kibana --namespace=elf
	kubectl delete random-logger -n elf

pro-graf: pro-graf-clone pro-graf-up pro-graf-test pro-graf-tidy

pro-graf-clone:
	git clone https://github.com/amerahsultan1/epsilon-pro-graf

pro-graf-up:
	cd epsilon-pro-graf && ./pro-graf.sh

pro-graf-test:
	curl localhost/grafana

pro-graf-tidy:
	rm -rf epsilon-pro-graf

pro-graf-down:
	helm uninstall prometheus-operator -n monitor

