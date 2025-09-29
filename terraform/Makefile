include .env
export


init:
	@echo "🔹 Initialisation avec backend S3 (DigitalOcean Spaces)"
	@echo "${AWS_ACCESS_KEY_ID}"
	@echo "${AWS_SECRET_ACCESS_KEY}"
	@echo "${DIGITALOCEAN_TOKEN}"
	@echo "${AWS_BUCKET}"
	@echo "${AWS_ENDPOINT}"

	tofu init -reconfigure -backend-config="endpoint=${AWS_ENDPOINT}" -backend-config="bucket=${AWS_BUCKET}" -backend-config="region=us-east-1"

apply-cluster: init
	tofu plan -target=module.doks-cluster -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=${AWS_SECRET_ACCESS_KEY}" -var "do_token=${DIGITALOCEAN_TOKEN}"
	tofu apply -target=module.doks-cluster -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=${AWS_SECRET_ACCESS_KEY}" -var "do_token=${DIGITALOCEAN_TOKEN}" --auto-approve

apply-cluster-conf: init
	tofu plan -target=module.kubernetes-config -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=${AWS_SECRET_ACCESS_KEY}" -var "do_token=${DIGITALOCEAN_TOKEN}"
	tofu apply -target=module.kubernetes-config -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=${AWS_SECRET_ACCESS_KEY}" -var "do_token=${DIGITALOCEAN_TOKEN}" --auto-approve

apply-applications: init
	tofu plan -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=${AWS_SECRET_ACCESS_KEY}" -var "do_token=${DIGITALOCEAN_TOKEN}"
	tofu apply -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=${AWS_SECRET_ACCESS_KEY}" -var "do_token=${DIGITALOCEAN_TOKEN}" --auto-approve

all:
	make apply-cluster apply-cluster-conf