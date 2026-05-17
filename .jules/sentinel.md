## 2025-05-16 - [Pin GitHub Actions to SHAs]
**Vulnerability:** GitHub Actions references using tags (e.g., `actions/checkout@v4`, `actions/setup-python@v6`, `gitleaks/gitleaks-action@v2`) are mutable. A compromised tag could lead to arbitrary code execution in CI/CD pipelines.
**Learning:** Some files in `.github/workflows/` (like `docs.yml`, `ansible-validate.yml`, `gitleaks.yml`) had unpinned actions, unlike `drift.yml` and `terraform-ci.yml` which properly used exact commit SHAs for many of them.
**Prevention:** Always pin GitHub Actions to their exact commit SHAs (and optionally include comments with the tag version for readability) to ensure immutability and improve supply chain security.
