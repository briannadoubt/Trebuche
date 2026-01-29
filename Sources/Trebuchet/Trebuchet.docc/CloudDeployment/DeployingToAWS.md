# Deploying to AWS

Deploy your distributed actors to AWS Lambda with the trebuchet CLI.

## Overview

Trebuchet provides a streamlined deployment experience for AWS Lambda, similar to frameworks like Vercel or AWS Amplify. The CLI handles:

- Actor discovery in your codebase
- Cross-compilation for Lambda (arm64)
- Terraform generation for AWS infrastructure
- Automated deployment

## Prerequisites

Before deploying, ensure you have:

1. **AWS CLI** configured with appropriate credentials
2. **Docker** installed (for cross-compilation)
3. **Terraform** installed (for infrastructure management)
4. **IAM permissions** for Lambda, DynamoDB, CloudMap, and optionally IAM role creation (see <doc:AWSConfiguration>)

```bash
# Verify prerequisites
aws sts get-caller-identity
docker --version
terraform --version
```

### IAM Role Options

The AWS provider supports two approaches for IAM role management:

**Option 1: Automatic Role Creation (Recommended for Development)**

Enable automatic IAM role creation in your provider configuration:

```swift
let provider = AWSProvider(
    region: "us-east-1",
    createRoles: true
)
```

This creates IAM roles automatically with basic Lambda execution permissions. Requires IAM permissions for role creation (see <doc:AWSConfiguration>).

**Option 2: Pre-created Roles (Recommended for Production)**

Create IAM roles separately and reference them in your configuration:

```yaml
actors:
  GameRoom:
    roleArn: arn:aws:iam::123456789012:role/GameRoomLambdaRole
```

## Quick Start

### 1. Initialize Configuration

```bash
trebuchet init --name my-game-server --provider aws
```

This creates `trebuchet.yaml`:

```yaml
name: my-game-server
version: "1"

defaults:
  provider: aws
  region: us-east-1
  memory: 512
  timeout: 30

actors:
  GameRoom:
    memory: 1024
    stateful: true
  Lobby:
    memory: 256

state:
  type: dynamodb

discovery:
  type: cloudmap
  namespace: my-game
```

### 2. Preview Deployment

```bash
trebuchet deploy --dry-run --verbose
```

Output:
```
Discovering actors...
  ✓ GameRoom
  ✓ Lobby

Dry run - would deploy:
  Provider: aws
  Region: us-east-1
  State Table: my-game-server-actor-state
  Namespace: my-game-server

  Actor: GameRoom
    Memory: 1024 MB
    Timeout: 30s
    Isolated: false
```

### 3. Deploy

```bash
trebuchet deploy --provider aws --region us-east-1
```

Output:
```
Discovering actors...
  ✓ GameRoom
  ✓ Lobby

Building for Lambda (arm64)...
  ✓ Package built (14.2 MB)

Deploying to AWS...
  ✓ Lambda: arn:aws:lambda:us-east-1:123456789012:function:my-game-actors
  ✓ API Gateway: https://abc123.execute-api.us-east-1.amazonaws.com
  ✓ DynamoDB: my-game-server-actor-state
  ✓ CloudMap: my-game-server namespace

Ready! Actors can discover each other automatically.
```

## AWS Resources Created

The deployment creates:

| Resource | Purpose |
|----------|---------|
| Lambda Function | Hosts your actors |
| Lambda Function URL | HTTP endpoint for invocations |
| DynamoDB Table | Actor state persistence |
| CloudMap Namespace | Service discovery |
| IAM Role | Lambda execution permissions |
| CloudWatch Log Group | Logging |

## Invoking Actors

### From External Clients

```swift
import Trebuchet

let client = TrebuchetClient(transport: .https(
    host: "abc123.execute-api.us-east-1.amazonaws.com"
))
try await client.connect()

let room = try client.resolve(GameRoom.self, id: "game-room")
let state = try await room.join(player: me)
```

### From Other Lambda Functions

```swift
import TrebuchetAWS

let client = TrebuchetCloudClient.aws(
    region: "us-east-1",
    namespace: "my-game-server"
)

let lobby = try await client.resolve(Lobby.self, id: "lobby")
let players = try await lobby.getPlayers()
```

## Configuration Options

### Actor Configuration

```yaml
actors:
  GameRoom:
    memory: 1024              # Memory in MB (128-10240)
    timeout: 60               # Timeout in seconds (1-900)
    stateful: true            # Enable state persistence
    isolated: true            # Run in dedicated Lambda
    reservedConcurrency: 10   # Reserved concurrent executions (optional)
    roleArn: arn:aws:iam::123456789012:role/MyRole  # Custom IAM role (optional)
    environment:              # Environment variables
      LOG_LEVEL: debug
    vpcConfig:                # VPC configuration (optional)
      securityGroupIds:
        - sg-12345678
      subnetIds:
        - subnet-a1b2c3d4
```

### Environment Overrides

```yaml
environments:
  production:
    region: us-west-2
    memory: 2048
  staging:
    region: us-east-1
```

Deploy to a specific environment:

```bash
trebuchet deploy --environment production
```

## Managing Deployments

### Check Status

The AWS provider implements full deployment status tracking with real-time Lambda function state monitoring:

```bash
trebuchet status --verbose
```

The status command reports:
- `active` - Function is deployed and ready to handle invocations
- `deploying` - Function is being created or updated
- `failed` - Deployment or update failed (includes error details)

### List Deployments

List all Trebuchet-managed Lambda functions in a region:

```bash
trebuchet list --region us-east-1
```

The provider identifies Trebuchet functions using the `ManagedBy=trebuchet` tag.

### Undeploy

Remove deployed Lambda functions and associated resources:

```bash
trebuchet undeploy
```

The undeploy operation:
1. Deletes Lambda functions
2. Removes CloudMap service registrations
3. Optionally removes DynamoDB state tables (if specified)
4. Cleans up CloudWatch log groups

## Terraform Customization

The generated Terraform is in `.trebuchet/terraform/`. You can customize it:

```bash
# View generated Terraform
cat .trebuchet/terraform/main.tf

# Apply with custom variables
cd .trebuchet/terraform
terraform apply -var="lambda_memory=2048"
```

## VPC Configuration

For actors that need VPC access (e.g., RDS, ElastiCache):

```hcl
# terraform.tfvars
vpc_id = "vpc-12345678"
subnet_ids = ["subnet-a1b2c3d4", "subnet-e5f6g7h8"]
security_group_ids = ["sg-12345678"]
```

## Cost Considerations

AWS Lambda pricing is based on:
- **Requests**: $0.20 per 1M requests
- **Duration**: $0.0000166667 per GB-second

DynamoDB uses on-demand pricing:
- **Read**: $0.25 per million reads
- **Write**: $1.25 per million writes

## See Also

- <doc:AWSConfiguration>
- ``AWSProvider``
- ``DynamoDBStateStore``
- ``CloudMapRegistry``
