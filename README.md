PRE-Request
------
# Terraform Part
1. you HAVE TO edit these file for aws account number
taskdef.json
feature.json
terraform.tfvars

2. these file for your aws profile
provider.tf
.backend_config.hcl # if you needed

# ECR Part
Create an ECR named: sb

(optional)
# S3 Part
A bucket that you save your tfstate if you use my backend_config.hcl
------
Files
------
vpc.tf : from aws-terraform-module
ecs.tf : A cluster called sb and will run fargate with autoscaling min:1 max:2
asg.tf : setting for autoscaling threshold
codebuild.tf : 2 codebuilds that download from my github public repo to get app codebuild
iam.tf : iam.tf
variables.tf : variables.tf

quiz2.tf : Almost same as ecs.tf but for Quiz2

------
Quiz1:

Use apache bench to send the http request to ALB endpoint after terraform deployed
ab -c 3 -n 10000 http://<alb-endpoint> 
then you will see the ecs fargate doing autoscaling

------
Quiz2:

Please run the python code: github.py
It will find the ECS service tag:branch called "feature" 
and check the branch last commit in my repository,
to see the last commit time over 3 days or not.
Finally, set the ecs service desire count to 0

*In this environment, I create 2 cluster named sb & feature 
to make sure prd env. and dev env. were separated.