variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "012345678901.dkr.ecr.ap-northeast-1.amazonaws.com/sb:latest"
}

variable "app_name" {
    description = "Fargate service name"
    default = "sb"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "ecs_as_network_low_threshold_per" {
  default = "2048" 
}

variable "ecs_as_network_high_threshold_per" {
  default = "5120"
}

variable "account_id" {}
variable "github_token" {}

