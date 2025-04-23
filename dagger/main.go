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
	action := os.Getenv("ACTION")         // plan, apply, destroy, output
	environment := os.Getenv("ENVIRONMENT") // dev, staging, prod
	module := os.Getenv("MODULE")         // vpc, eks, iam, etc

	if action == "" || environment == "" || module == "" {
		log.Fatal("Missing required environment variables: ACTION, ENVIRONMENT, MODULE")
	}

	tfVersion := "1.8.3"
	tfDir := fmt.Sprintf("./%s", module)
	varFile := fmt.Sprintf("variables/%s.tfvars", environment)
	s3Key := fmt.Sprintf("modules/%s/terraform.tfstate", module)
	s3Bucket := os.Getenv("S3_BACKEND")

	// Connect to Dagger
	client, err := dagger.Connect(ctx)
	if err != nil {
		log.Fatalf("Failed to connect to Dagger: %v", err)
	}
	defer client.Close()

	// Terraform container
	tf := client.Container().
		From("hashicorp/terraform:" + tfVersion).
		WithMountedDirectory("/src", client.Host().Directory(".")).
		WithWorkdir(fmt.Sprintf("/src/%s", module)).
		WithEnvVariable("AWS_ACCESS_KEY_ID", os.Getenv("AWS_ACCESS_KEY_ID")).
		WithEnvVariable("AWS_SECRET_ACCESS_KEY", os.Getenv("AWS_SECRET_ACCESS_KEY")).
		WithEnvVariable("AWS_REGION", os.Getenv("AWS_REGION"))

	// Terraform Init
	_, err = tf.WithExec([]string{
		"init",
		fmt.Sprintf("-backend-config=bucket=%s", s3Bucket),
		fmt.Sprintf("-backend-config=key=%s", s3Key),
	}).Sync(ctx)
	if err != nil {
		log.Fatalf("Terraform init failed: %v", err)
	}

	// Optional steps
	switch action {
	case "plan":
		_, err = tf.WithExec([]string{"plan", "-var-file=" + varFile}).Sync(ctx)
	case "apply":
		_, err = tf.WithExec([]string{"apply", "-var-file=" + varFile, "-auto-approve"}).Sync(ctx)
	case "destroy":
		_, err = tf.WithExec([]string{"destroy", "-var-file=" + varFile, "-auto-approve"}).Sync(ctx)
	case "output":
		_, err = tf.WithExec([]string{"output", "-json"}).Sync(ctx)
	default:
		log.Fatalf("Unsupported action: %s", action)
	}

	if err != nil {
		log.Fatalf("Terraform %s failed: %v", action, err)
	}

	fmt.Printf("Terraform %s completed successfully.\n", action)
}
