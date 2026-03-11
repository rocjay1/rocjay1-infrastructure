terraform {
  backend "gcs" {
    bucket = "daily-tech-brief-tfstate"
    prefix = "feed-aggregator"
  }
}
