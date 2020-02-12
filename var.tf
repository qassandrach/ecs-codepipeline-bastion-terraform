variable "region"{
    default = "ap-southeast-1"
}
provider "aws"{
    access_key=""
    secret_key=""
    region = var.region
}
variable "ecs_key_pair_name" {
    default = ""
  
}
variable "aws_account_id" {
    default = "95449291256" 
}
variable "service_name" {
    default = "wordpress-qassie"
  
}
variable "container_port" {
    default = "8080"
  
}
variable "memory_reservation" {
default = 100  
}

variable "infrastructure_stage" {
    description = "infrastructure_stage"
}



