resource "aws_backup_vault" "webapp" {
  name = "webappBackupVault"
}

resource "aws_backup_vault" "webapp_backup_vault" {
  provider = aws.backup
  name     = "webappBackupBackupVault"
  // Naming on purpose
}

resource "aws_backup_plan" "daily_backup" {
  name = "${var.region_name}-${var.env_designator}-daily-backup"

  rule {
    rule_name         = "${var.region_name}-${var.env_designator}-daily-backup"
    target_vault_name = aws_backup_vault.webapp.name
    // 0 = Minute
    // 0 = Hour  We run it directly b/c we do not want to loose our first application
    // L = Last day of month
    // * = Every month
    // ? = Any day of week. Must be ? if month is *
    // * = Any year
    // Daily 10pm
    schedule = "cron(00 22 ? * * *)"
    //

    lifecycle {
      cold_storage_after = null
      delete_after       = 7
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.webapp_backup_vault.arn
      lifecycle {
        cold_storage_after = null
        delete_after       = 7
      }
    }
  }
}

resource "aws_backup_plan" "weekly_backup" {
  name = "${var.region_name}-${var.env_designator}-weekly-backup"

  rule {
    rule_name         = "${var.region_name}-${var.env_designator}-weekly-backup"
    target_vault_name = aws_backup_vault.webapp.name
    // 0 = Minute
    // 0 = Hour  We run it directly b/c we do not want to loose our first application
    // L = Last day of month
    // * = Every month
    // ? = Any day of week. Must be ? if month is *
    // * = Any year
    // Saturdays 22:00
    schedule = "cron(0 22 ? * 7 *)"
    //

    lifecycle {
      cold_storage_after = null
      delete_after       = 28
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.webapp_backup_vault.arn
      lifecycle {
        cold_storage_after = null
        delete_after       = 28
      }
    }
  }


}

resource "aws_backup_selection" "daily_instances" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.region_name}-${var.env_designator}-daily-backup"
  plan_id      = aws_backup_plan.daily_backup.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "webappDailyBackup"
    value = "true"
  }
}

resource "aws_backup_selection" "weekly_instances" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.region_name}-${var.env_designator}-weekly-backup"
  plan_id      = aws_backup_plan.weekly_backup.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "webappWeeklyBackup"
    value = "true"
  }
}

# As per usual we need a shitload of permissions.
data "aws_iam_policy_document" "backup_invoke_permission" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "backup.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

resource "aws_iam_role" "backup_role" {
  name               = "BACKUP_SERVICE_ROLE"
  description        = "Role that the backup service can assume."
  assume_role_policy = data.aws_iam_policy_document.backup_invoke_permission.json
}

resource "aws_iam_role_policy_attachment" "backup_role_create" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_iam_role_policy_attachment" "backup_role_restore" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_role.name
}

