package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"dagger.io/dagger"
)

func main() {
	ctx := context.Background()

	// Get inputs from environment variables
	action := os.Getenv("ACTION")           // plan, apply, destroy, output
	environment := os.Getenv("ENVIRONMENT") // dev, staging, prod
	module := os.Getenv("MODULE")           // vpc, eks, iam, etc

	awsAccessKey := os.Getenv("AWS_ACCESS_KEY_ID")
	awsSecretKey := os.Getenv("AWS_SECRET_ACCESS_KEY")
	awsRegion := os.Getenv("AWS_REGION")
	s3Bucket := os.Getenv("S3_BACKEND")

	// Check required environment variables
	missingVars := []string{}
	if action == "" {
		missingVars = append(missingVars, "ACTION")
	}
	if environment == "" {
		missingVars = append(missingVars, "ENVIRONMENT")
	}
	if module == "" {
		missingVars = append(missingVars, "MODULE")
	}
	if awsAccessKey == "" {
		missingVars = append(missingVars, "AWS_ACCESS_KEY_ID")
	}
	if awsSecretKey == "" {
		missingVars = append(missingVars, "AWS_SECRET_ACCESS_KEY")
	}
	if awsRegion == "" {
		missingVars = append(missingVars, "AWS_REGION")
	}
	if s3Bucket == "" {
		missingVars = append(missingVars, "S3_BACKEND")
	}
	if len(missingVars) > 0 {
		log.Fatalf("Missing required environment variables: %v", missingVars)
	}

	tfVersion := "1.8.3"
	tfDir := fmt.Sprintf("./%s", module)
	varFile := fmt.Sprintf("variables/%s.tfvars", environment)
	s3Key := fmt.Sprintf("modules/%s/terraform.tfstate", module)

	// Connect to Dagger
	client, err := dagger.Connect(ctx)
	if err != nil {
		log.Fatalf("Failed to connect to Dagger: %v", err)
	}
	defer client.Close()

	// Terraform container setup
	tf := client.Container().
		From("hashicorp/terraform:" + tfVersion).
		WithMountedDirectory("/src", client.Host().Directory(".")).
		WithWorkdir(fmt.Sprintf("/src/%s", module)).
		WithEnvVariable("AWS_ACCESS_KEY_ID", awsAccessKey).
		WithEnvVariable("AWS_SECRET_ACCESS_KEY", awsSecretKey).
		WithEnvVariable("AWS_REGION", awsRegion)

	// Terraform Init
	_, err = tf.WithExec([]string{
		"init",
		fmt.Sprintf("-backend-config=bucket=%s", s3Bucket),
		fmt.Sprintf("-backend-config=key=%s", s3Key),
	}).Sync(ctx)
	if err != nil {
		log.Fatalf("Terraform init failed: %v", err)
	}

	// Handle Terraform actions
	switch action {
	case "plan":
		_, err = tf.WithExec([]string{"plan", "-var-file=" + varFile}).Sync(ctx)
		if err != nil {
			log.Fatalf("Terraform plan failed: %v", err)
		}
		fmt.Println("Terraform plan completed successfully.")
	case "apply":
		_, err = tf.WithExec([]string{"apply", "-var-file=" + varFile, "-auto-approve"}).Sync(ctx)
		if err != nil {
			log.Fatalf("Terraform apply failed: %v", err)
		}
		fmt.Println("Terraform apply completed successfully.")
	case "destroy":
		_, err = tf.WithExec([]string{"destroy", "-var-file=" + varFile, "-auto-approve"}).Sync(ctx)
		if err != nil {
			log.Fatalf("Terraform destroy failed: %v", err)
		}
		fmt.Println("Terraform destroy completed successfully.")
	case "output":
		out, err := tf.WithExec([]string{"output", "-json"}).Stdout(ctx)
		if err != nil {
			log.Fatalf("Terraform output failed: %v", err)
		}
		fmt.Println(out)
	default:
		log.Fatalf("Unsupported action: %s", action)
	}
}
