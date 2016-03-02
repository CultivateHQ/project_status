# ProjectStatus

Aimed to automate project status updates and tracking. Step 1, sending out the daily emails.

It is currently deployed to a Digital Ocean. VMARGS

## Setup

### Fetch dependencies

```bash
  mix deps.get
  npm install
```

### Setup the database

The `dev.exs` and `test.exs` files have the username and password configuration commented out. For convenience, you
can copy the `secret.exs` file and update to reflect your own machine's configuration.

```bash
  cp config/secret.exs.example config/secret.exs
```

Create the schema and migrate.

```bash
  mix ecto.create
  mix ecto.migrate
```

### Setup API keys/tokens

In order for things to work, you'll need to update your `secrets.exs` to include config for trello, github oauth, and honeybadger.

### Run application

```bash
  mix phoenix.server
```

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
