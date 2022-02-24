import sys
import subprocess

from kubectl_run.pipe import KubernetesDeployPipe

schema = {
    'AWS_ACCESS_KEY_ID': {'type': 'string', 'required': True},
    'AWS_SECRET_ACCESS_KEY': {'type': 'string', 'required': True},
    'AWS_DEFAULT_REGION': {'type': 'string', 'required': True},
    'CLUSTER_NAME': {'type': 'string', 'required': True},
    'HELM_COMMAND': {'type': 'string', 'required': True}
}


class EKSDeployPipe(KubernetesDeployPipe):

    def configure(self):
        self.log_info("Configuring kubeconfig...")

        cluster_name = self.get_variable("CLUSTER_NAME")
        role = self.get_variable('ROLE_ARN')
        cmd = f'aws eks update-kubeconfig --name={cluster_name}'.split()
        if role is not None:
            cmd.append(f"--role-arn={role}")

        if self.get_variable('DEBUG'):
            cmd.append("--verbose")

        result = subprocess.run(cmd, stdout=sys.stdout)

        if result.returncode != 0:
            self.fail(f'Failed to update the kube config.')
        else:
            self.log_info(f'Successfully updated the kube config.')
    
    def run_helm_command(self):
        helm_commmand = self.get_variable("HELM_COMMAND")
        cmd = f'{helm_commmand}'.split()
        if self.get_variable('DEBUG'):
            cmd.append("--debug")

        result = subprocess.run(cmd, stdout=sys.stdout)

        if result.returncode != 0:
            self.fail(f'Failed to run helm command: {helm_commmand}')
        else:
            self.log_info(f'Successfully run helm command: {helm_commmand}')


if __name__ == '__main__':
    pipe = EKSDeployPipe(schema=schema, pipe_metadata_file='/pipe.yml', check_for_newer_version=True)
    pipe.configure()
    pipe.run_helm_command()
