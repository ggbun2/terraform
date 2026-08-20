output "public_IP"{
    value = aws_instance.myinstance.public_ip
    description = "myEC2 publicIP"
}