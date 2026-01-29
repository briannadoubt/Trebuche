# TrebuchetAWS Module

Deploy Swift distributed actors to AWS Lambda with DynamoDB state and CloudMap discovery.

## Overview

TrebuchetAWS provides AWS-specific implementations of the TrebuchetCloud protocols, enabling seamless deployment of distributed actors to AWS Lambda.

```swift
import TrebuchetAWS

// Configure state and discovery
let stateStore = DynamoDBStateStore(tableName: "my-actor-state")
let registry = CloudMapRegistry(namespace: "my-app")

// Create gateway
let gateway = CloudGateway(configuration: .init(
    stateStore: stateStore,
    registry: registry
))

// Register actors
try await gateway.expose(GameRoom(actorSystem: gateway.system), as: "game-room")
```

## AWS Provider

The AWS provider offers complete Lambda function lifecycle management with production-ready AWS SDK (Soto) integration.

- `AWSProvider` - CloudProvider implementation with deploy, update, status, list, and undeploy operations
- `AWSFunctionConfig` - Lambda function configuration (memory, timeout, VPC, concurrency, environment variables)
- `AWSDeployment` - AWS-specific deployment result with function ARN and metadata
- `AWSCredentials` - AWS credential management supporting static credentials and default credential chain
- `AWSProviderError` - Error types for AWS deployment operations (missingRole, deploymentFailed, deploymentTimeout)
- `VPCConfig` - VPC configuration for Lambda functions requiring private network access

### IAM Role Management

The AWS provider supports automatic IAM role creation for simplified deployments:

```swift
let provider = AWSProvider(
    region: "us-east-1",
    createRoles: true  // Automatically creates IAM roles with basic Lambda execution policy
)
```

When `createRoles` is enabled, the provider creates IAM roles with the `AWSLambdaBasicExecutionRole` policy attached. For custom IAM configurations, set `createRoles: false` and provide a `roleArn` in the function configuration.

## State Storage

- `DynamoDBStateStore` - ActorStateStore implementation using DynamoDB

## Service Discovery

- `CloudMapRegistry` - ServiceRegistry implementation using AWS Cloud Map

## Lambda Integration

Production-ready Lambda integration using the Soto AWS SDK:

- `LambdaInvokeTransport` - Transport for invoking Lambda functions with Soto SDK, supporting AWS credential chain and custom `AWSClient` configuration
- `LambdaEventAdapter` - Converts between Lambda events and Trebuchet format
- `APIGatewayV2Request` - API Gateway HTTP API request format
- `APIGatewayV2Response` - API Gateway HTTP API response format
- `HTTPResponseStatus` - HTTP status codes
- `StreamProcessorHandler` - Handles DynamoDB stream events for WebSocket connection state management
- `StreamProcessorError` - Error types for stream processor operations (missingEnvironmentVariable)

### Stream Processing

The `StreamProcessorHandler` integrates with DynamoDB Streams and API Gateway WebSocket connections for real-time state synchronization. It reads configuration from environment variables:
- `CONNECTION_TABLE` - DynamoDB table for connection storage
- `API_GATEWAY_ENDPOINT` - WebSocket API endpoint
- `AWS_REGION` - AWS region (defaults to us-east-1)

## Actor Communication

- `TrebuchetCloudClient` - Client for resolving actors across Lambda functions using CloudMap service discovery
- `CloudLambdaContext` - Context available to actors running in Lambda
