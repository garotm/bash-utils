provider "aws" {
  region  = "${var.aws_region}"
  profile = "default"
}

resource "aws_instance" "PhishMe-dev" {
  ami                         = "ami-cb9ec1b1"
  availability_zone           = "us-east-1a"
  ebs_optimized               = false
  monitoring                  = false
  associate_public_ip_address = true
  source_dest_check           = true
  instance_type               = "t2.micro"
  key_name                    = "${var.ec2_key_name}"
  subnet_id                   = "subnet-e5c14381"
  vpc_security_group_ids      = ["sg-ec95e598"]
  count                       = 2

  tags {
        "Stack" = "dev"
        "Owner" = "DevOps"
        "Name"  = "PhishMe_terraform"
        "Env"   = "development"
  }

provisioner "remote-exec" {

  connection {
    agent       = "false"
    user        = "ec2-user"
    Type        = "ssh"
    private_key = "${var.ec2_key_path}"
    private_key = "${file("/Users/garotconklin/.aws/dev_key.pem")}"
  }

  inline = [ 
             "sudo yum install -y docker",
             "sudo service docker restart",
             "sudo docker pull redmine",
             "sudo docker run -d --restart=unless-stopped -p 80:3000 redmine"  
            ]
  }
}
