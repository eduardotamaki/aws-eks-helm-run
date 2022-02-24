# Bitbucket Pipelines Pipe: AWS EKS run helm command

Run a helm command against an AWS EKS cluster.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: atlassian/aws-eks-kubectl-run:2.2.0
  variables:
    AWS_ACCESS_KEY_ID: '<string>' # Optional if already defined in the context.
    AWS_SECRET_ACCESS_KEY: '<string>' # Optional if already defined in the context.
    AWS_DEFAULT_REGION: '<string>' # Optional if already defined in the context.
    CLUSTER_NAME: '<string>'
    HELM_COMMAND: '<string>'
```
