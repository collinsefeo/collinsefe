# ---------------------------------------------------------------------------------------------------------------------
# itsnwe-aws-account-062 makefile
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# vars
# ---------------------------------------------------------------------------------------------------------------------

include .env
export

ENV = env
RESOURCE = resource
CALLER_ID = $(shell aws sts get-caller-identity --output json | jq -r '.Account')
# ---------------------------------------------------------------------------------------------------------------------
# environments
# ---------------------------------------------------------------------------------------------------------------------

prod:
	$(eval ENV = prod)


# ---------------------------------------------------------------------------------------------------------------------
# layers
# ---------------------------------------------------------------------------------------------------------------------

vpc:
	$(eval RESOURCE = vpc)

iam:
	$(eval RESOURCE = iam)

config:
	$(eval RESOURCE = config)

ec2-scheduler:
	$(eval RESOURCE = ec2-scheduler)

splunk-connector:
	$(eval RESOURCE = splunk-connector)

logging:
	$(eval RESOURCE = logging)

# ---------------------------------------------------------------------------------------------------------------------
# targets
# ---------------------------------------------------------------------------------------------------------------------

verify_account_match:
ifeq ($(CALLER_ID), $(TF_VAR_aws_account_id))
		@:
else
		$(error Error: You're currently assumed into an AWS Account that does not match the value for TF_VAR_aws_account_id)
endif

backend_init:
		export ENV=${ENV} && cd ./backend/${ENV} && \
		terraform init

backend_plan: backend_init
		export ENV=${ENV} && cd ./backend/${ENV} && \
		terraform plan -lock=false -out=.terraform/terraform.tfplan


backend_apply:
		export ENV=${ENV} && cd ./backend/${ENV} && \
		terraform apply -auto-approve -lock=false -state=.terraform/terraform.tfstate

backend_destroy:
		export ENV=${ENV} && cd ./backend/${ENV} && \
		terraform destroy -force -lock=false -state=.terraform/terraform.tfstate



plan:
		export ENV=${ENV} && export RESOURCE=${RESOURCE} && cd ./terraform/${ENV}/${TF_VAR_aws_region}/${RESOURCE} && \
		terragrunt plan-all --terragrunt-non-interactive --terragrunt-source-update

destroy-plan:
		export ENV=${ENV} && export RESOURCE=${RESOURCE} && cd ./terraform/${ENV}/${TF_VAR_aws_region}/${RESOURCE} && \
		terragrunt plan-all -destroy --terragrunt-non-interactive --terragrunt-source-update

apply:
		export ENV=${ENV} && export RESOURCE=${RESOURCE} && cd ./terraform/${ENV}/${TF_VAR_aws_region}/${RESOURCE} && \
		terragrunt apply-all --terragrunt-non-interactive --terragrunt-source-update

destroy: destroy-plan
		export ENV=${ENV} && export RESOURCE=${RESOURCE} && cd ./terraform/${ENV}/${TF_VAR_aws_region}/${RESOURCE} && \
		terragrunt destroy-all --terragrunt-non-interactive --terragrunt-source-update

output:
		export ENV=${ENV} && export RESOURCE=${RESOURCE} && cd ./terraform/${ENV}/${TF_VAR_aws_region}/${RESOURCE} && \
		terragrunt output-all --terragrunt-non-interactive --terragrunt-source-update

apply_all:
		export ENV=${ENV} && cd ./terraform/${ENV}/${TF_VAR_aws_region} && \
		terragrunt apply-all --terragrunt-non-interactive --terragrunt-source-update

plan_all:
		export ENV=${ENV} && cd ./terraform/${ENV}/${TF_VAR_aws_region} && \
		terragrunt plan-all --terragrunt-non-interactive --terragrunt-source-update

destroy_all:
		export ENV=${ENV} && cd ./terraform/${ENV}/${TF_VAR_aws_region} && \
		terragrunt destroy-all --terragrunt-non-interactive --terragrunt-source-update

clean:
		rm -rf ~/.terragrunt/*
		find . -type d -name '.terraform' | xargs rm -r


# ---------------------------------------------------------------------------------------------------------------------
# terraform actions
# ---------------------------------------------------------------------------------------------------------------------

# backend
backend-prod-init: prod backend_init
backend-prod-plan: prod backend_plan
backend-prod-apply: prod backend_apply
backend-prod-destroy: prod backend_destroy

backend-test-init: test backend_init
backend-test-plan: test backend_plan
backend-test-apply: test backend_apply
backend-test-destroy: test backend_destroy

# all
all-prod-plan: prod verify_account_match plan_all
all-prod-apply: prod verify_account_match apply_all
all-prod-destroy: prod verify_account_match destroy_all
all-prod-output: prod verify_account_match output


# vpc
vpc-prod-plan: vpc prod verify_account_match plan
vpc-prod-apply: vpc prod verify_account_match apply
vpc-prod-destroy: vpc prod verify_account_match destroy
vpc-prod-output: vpc prod verify_account_match output


# iam
iam-prod-plan: iam prod verify_account_match plan
iam-prod-apply: iam prod verify_account_match apply
iam-prod-destroy: iam prod verify_account_match destroy
iam-prod-output: iam prod verify_account_match output


# config
config-prod-plan: config prod verify_account_match plan
config-prod-apply: config prod verify_account_match apply
config-prod-destroy: config prod verify_account_match destroy
config-prod-output: config prod verify_account_match output


# scheduler
ec2-scheduler-prod-plan: ec2-scheduler prod verify_account_match plan
ec2-scheduler-prod-apply: ec2-scheduler prod verify_account_match apply
ec2-scheduler-prod-destroy: ec2-scheduler prod verify_account_match destroy
ec2-scheduler-prod-output: ec2-scheduler prod verify_account_match output


# splunk-connector
splunk-connector-prod-plan: splunk-connector prod verify_account_match plan
splunk-connector-prod-apply: splunk-connector prod verify_account_match apply
splunk-connector-prod-destroy: splunk-connector prod verify_account_match destroy
splunk-connector-prod-output: splunk-connector prod verify_account_match output

# logging
logging-prod-plan: logging prod verify_account_match plan
logging-prod-apply: logging prod verify_account_match apply
logging-prod-destroy: logging prod verify_account_match destroy
logging-prod-output: logging prod verify_account_match output

# destroy default vpcs

destroy-default-vpc: verify_account_match && cd ./scripts/ && python remove-vpc.py