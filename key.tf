# Create an EC2 key pair
resource "aws_key_pair" "prod" {
  key_name   = "prod-key"
  public_key = tls_private_key.prod.public_key_openssh
}

# Generate a new TLS key pair locally
resource "tls_private_key" "prod" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.prod.private_key_pem
  filename = "${path.module}/prod-key.pem"

  # Ensure the private key file has restricted permissions
  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/prod-key.pem"
  }
}

# Optionally, you can output the key pair details
output "key_name" {
  value = aws_key_pair.prod.key_name
}

output "private_key_path" {
  value = local_file.private_key.filename
}


