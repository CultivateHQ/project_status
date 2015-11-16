# ProjectStatus

Aimed to automate project status updates and tracking. Step 1, sending out the daily emails.

It is currently deployed to a Digital Ocean. VMARGS


## Deployment

Deployed with `ansible-elixir-stack from` https://github.com/HashNuke/ansible-elixir-stack

### Pre-requisites

I believe:
```
 pip install ansible
 ansible-galaxy install HashNuke.elixir-stack

```

Also copy `playbooks/templates/prod.secret.exs.j2.example` to  `playbooks/templates/prod.secret.exs.j2` and fill in Mailgun and Basic Auth credentials.

### Deployment

To deploy.

```
ansible-playbook playbook/deploy.yml

```

To migrate



```
ansible-playbook playbook/migrate.yml

```
