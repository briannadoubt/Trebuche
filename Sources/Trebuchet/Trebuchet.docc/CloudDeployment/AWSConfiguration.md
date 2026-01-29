# AWS Configuration Reference

Complete reference for AWS deployment configuration options.

## Overview

This article covers all configuration options available when deploying to AWS.

## trebuchet.yaml Reference

### Top-Level Configuration

```yaml
name: my-project           # Project name (used for resource naming)
version: "1"               # Configuration version

defaults:
  provider: aws            # Cloud provider
  region: us-east-1        # AWS region
  memory: 512              # Default memory (MB)
  timeout: 30              # Default timeout (seconds)

actors: {}                 # Actor-specific configuration
environments: {}           # Environment overrides
state: {}                  # State storage configuration
discovery: {}              # Service discovery configuration
```

### Actor Configuration

```yaml
actors:
  MyActor:
    memory: 1024           # Memory in MB (128-10240)
    timeout: 60            # Timeout in seconds (1-900)
    stateful: true         # Enable DynamoDB state persistence
    isolated: true         # Run in dedicated Lambda function
    reservedConcurrency: 10  # Reserved concurrent executions (optional)
    roleArn: arn:aws:iam::123456789012:role/MyCustomRole  # Custom IAM role (optional)
    environment:           # Environment variables
      KEY: value
    vpcConfig:             # VPC configuration (optional)
      securityGroupIds:
        - sg-12345678
      subnetIds:
        - subnet-a1b2c3d4
        - subnet-e5f6g7h8
```

### State Configuration

```yaml
state:
  type: dynamodb           # State store type
  tableName: custom-table  # Optional: custom table name
```

### Discovery Configuration

```yaml
discovery:
  type: cloudmap           # Registry type
  namespace: my-namespace  # CloudMap namespace name
```

### Environment Configuration

```yaml
environments:
  production:
    region: us-west-2
    memory: 2048
    environment:
      LOG_LEVEL: warn
  staging:
    region: us-east-1
    environment:
      LOG_LEVEL: debug
```

## AWS Credentials

The AWS provider uses the standard AWS credential chain powered by the Soto SDK:

1. Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)
2. AWS credentials file (`~/.aws/credentials`)
3. IAM instance profile (EC2, ECS, Lambda)
4. AWS SSO credentials
5. ECS container credentials
6. EC2 instance metadata service

```bash
# Using environment variables
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_REGION=us-east-1

trebuchet deploy
```

```bash
# Using a named profile
export AWS_PROFILE=my-profile
trebuchet deploy
```

### Programmatic Credential Configuration

When using the AWS provider directly in code, you can specify credentials explicitly or rely on the default credential chain:

```swift
import TrebuchetAWS

// Use default credential chain (recommended)
let provider = AWSProvider(region: "us-east-1")

// Use static credentials
let provider = AWSProvider(
    region: "us-east-1",
    credentials: AWSCredentials(
        accessKeyId: "AKIAIOSFODNN7EXAMPLE",
        secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        sessionToken: nil  // Optional session token
    )
)

// Use custom AWSClient for advanced configuration
let customClient = AWSClient(
    credentialProvider: .default,
    httpClientProvider: .createNew
)
let provider = AWSProvider(
    region: "us-east-1",
    awsClient: customClient
)
```

## IAM Role Management

### Automatic Role Creation

The AWS provider supports automatic IAM role creation for simplified deployments. When enabled, the provider creates roles with the `AWSLambdaBasicExecutionRole` policy attached:

```swift
let provider = AWSProvider(
    region: "us-east-1",
    createRoles: true  // Automatically creates IAM roles for Lambda functions
)
```

Created roles are named `trebuchet-{function-name}-role` and include:
- Trust policy allowing Lambda service to assume the role
- `AWSLambdaBasicExecutionRole` managed policy for CloudWatch Logs access
- Tags: `ManagedBy=trebuchet`, `FunctionName={function-name}`

**Note:** Role propagation can take up to 10 seconds. The provider waits for role availability before creating the Lambda function.

### Custom IAM Roles

For production deployments or when additional permissions are needed, provide a custom IAM role ARN:

```yaml
actors:
  MyActor:
    roleArn: arn:aws:iam::123456789012:role/MyCustomLambdaRole
```

## IAM Permissions

### Deployment Permissions

The deployment process requires these IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:DeleteFunction",
        "lambda:GetFunction",
        "lambda:ListFunctions",
        "lambda:ListTags",
        "lambda:PutFunctionConcurrency",
        "lambda:DeleteFunctionConcurrency",
        "lambda:CreateFunctionUrlConfig",
        "lambda:DeleteFunctionUrlConfig"
      ],
      "Resource": "arn:aws:lambda:*:*:function:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "servicediscovery:CreatePrivateDnsNamespace",
        "servicediscovery:DeleteNamespace",
        "servicediscovery:CreateService",
        "servicediscovery:DeleteService"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PassRole",
        "iam:TagRole"
      ],
      "Resource": "arn:aws:iam::*:role/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "${var.allowed_regions}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:*"
    }
  ]
}
```

## Terraform Variables

The generated Terraform accepts these variables:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-1 | AWS region |
| `vpc_id` | string | required | VPC ID |
| `subnet_ids` | list(string) | required | Subnet IDs |
| `security_group_ids` | list(string) | required | Security group IDs |
| `lambda_memory` | number | 512 | Lambda memory (MB) |
| `lambda_timeout` | number | 30 | Lambda timeout (seconds) |
| `lambda_url_auth_type` | string | NONE | Auth type (NONE, AWS_IAM) |
| `create_api_gateway` | bool | false | Create API Gateway |
| `cors_allowed_origins` | list(string) | ["*"] | CORS origins |
| `log_level` | string | info | Application log level |
| `log_retention_days` | number | 14 | Log retention period |

## DynamoDB Table Schema

The state table uses this schema:

| Attribute | Type | Description |
|-----------|------|-------------|
| `actorId` | String (PK) | Actor identifier |
| `state` | Binary | Serialized actor state |
| `updatedAt` | String | Last update timestamp |
| `ttl` | Number | TTL for automatic cleanup |

## CloudMap Configuration

Actors register with CloudMap using:

| Attribute | Description |
|-----------|-------------|
| `ENDPOINT` | Lambda ARN or API Gateway URL |
| `REGION` | AWS region |
| `PROVIDER` | Always "aws" |

## See Also

- <doc:DeployingToAWS>
- ``AWSProvider``
- ``AWSFunctionConfig``
