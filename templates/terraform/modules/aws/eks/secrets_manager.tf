resource "aws_secretsmanager_secret" "cluster_api_keys" {
  name                    = "${var.cluster_name}_keys"
  description             = "API Key(s) for ${var.cluster_name} that cannot/should not be stored externally"
  recovery_window_in_days = 7
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = aws_secretsmanager_secret.cluster_api_keys[0].id

  depends_on = [aws_secretsmanager_secret.cluster_api_keys]
}
