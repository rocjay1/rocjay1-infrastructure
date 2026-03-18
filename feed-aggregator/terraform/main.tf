resource "random_id" "project_suffix" {
  byte_length = 6
}

resource "cloudflare_pages_project" "feed_aggregator" {
  account_id        = var.account_id
  name              = "${var.project_name}-${random_id.project_suffix.hex}"
  production_branch = "main"

  source = {
    type = "github"
    config = {
      owner                          = split("/", var.github_repo)[0]
      repo_name                      = split("/", var.github_repo)[1]
      production_branch              = "main"
      pr_comments_enabled            = true
      deployments_enabled            = true
      production_deployments_enabled = false
      preview_deployment_setting     = "all"
      preview_branch_includes        = ["*"]
    }
  }

  build_config = {
    build_command   = "curl -LsSf https://astral.sh/uv/install.sh | sh && PYTHONPATH=. /opt/buildhome/.local/bin/uv run python src/generate.py"
    destination_dir = "public"
    root_dir        = ""
  }

  deployment_configs = {
    production = {
      compatibility_date = "2024-01-01"
      environment_variables = {
        PYTHON_VERSION = "3.13"
      }
    }
    preview = {
      compatibility_date = "2024-01-01"
      environment_variables = {
        PYTHON_VERSION = "3.13"
      }
    }
  }
}
