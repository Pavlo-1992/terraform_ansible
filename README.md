1. We use Terraform to create EC2 instances. Before starting, you need to run:
terraform init, plan, apply.
Check that the correct region, current key_name, and AMI supported in this region are specified.

2. Obtaining instance IP addresses.
After successfully executing terraform apply, Terraform outputs the public IP addresses of the created instances via outputs.

These IP addresses are added to the inventory.ini file, where:

hosts are grouped into logical groups: zero, first, second;
each host is assigned an alias;
the user for SSH connection (ansible_user) is specified;
the private key (ansible_ssh_private_key_file) is assigned.

This allows Ansible to correctly identify the target nodes and manage them in groups. 

3. Checking the Ansible connection
After preparing the inventory, you need to check the availability of hosts via Ansible using the ping module:

ansible zero   -i inventory.ini -m ping
ansible first  -i inventory.ini -m ping
ansible second -i inventory.ini -m ping
ansible all    -i inventory.ini -m ping


During the first connection, Ansible will ask for SSH fingerprint confirmation, which is standard behavior for OpenSSH.

A successful pong response means that:

The SSH connection is working;
The Python interpreter is available on the remote host;
Ansible can execute playbooks.

4. Installing NGINX with Ansible
To install NGINX on all instance groups, we use the setup_nginx.yml playbook:
ansible-playbook -i inventory.ini setup_nginx.yml

What happens during playbook execution:

Ansible connects to each host via SSH according to the inventory.
Thanks to become: true, commands are executed with root privileges.

On each host:

the package cache is updated;
NGINX is installed via apt;
the NGINX service is checked and ensured to be running.

As a result, going to the instance's IP address in a browser will show the standard NGINX page:
Welcome to nginx!

5. Setting up a custom home page.

To demonstrate flexibility, a separate playbook setup_nginx_home_page.yml has been created, which changes the standard NGINX start page.

Apply only to the zero group:
ansible-playbook -i inventory.ini setup_nginx_home_page.yml --limit zero

In your browser, you will see:
Hello from the zero group of instances!

Apply to all hosts:
ansible-playbook -i inventory.ini setup_nginx_home_page.yml

In this case, each group receives its own unique content, for example:
Hello from the second group of instances!

How it works inside Ansible

The playbook uses conditional logic (when or group_names).
Depending on the host group, the corresponding HTML content is generated.
The file is overwritten:      /var/www/html/index.nginx-debian.html
The playbook also contains a task for installing NGINX, but since NGINX was
installed earlier, Ansible only checks its presence and status.
This demonstrates the idempotency of Ansible.

Conclusions

Terraform is used for automated infrastructure creation (EC2).
Ansible is responsible for server configuration:

installing software,
starting services,
managing configurations.

Grouping hosts in inventory.ini allows you to:
manage different environments;
apply configurations selectively or in bulk.

The solution demonstrates a typical Infrastructure + Configuration as Code approach.
