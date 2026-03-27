resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.name_prefix}/db-password"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret" "smtp" {
  name                    = "${local.name_prefix}/smtp"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "smtp" {
  secret_id = aws_secretsmanager_secret.smtp.id
  secret_string = jsonencode({
    user     = var.smtp_user
    password = var.smtp_password
  })
}

resource "aws_secretsmanager_secret" "google_sa" {
  name                    = "${local.name_prefix}/google-sa-json"
  recovery_window_in_days = 0

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "google_sa" {
  secret_id     = aws_secretsmanager_secret.google_sa.id
  secret_string = var.google_service_account_json
}
