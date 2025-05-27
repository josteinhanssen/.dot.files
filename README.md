# NixOS Configuration

This repository contains my NixOS configuration files.

## Setting Up GitHub SSH Authentication

When installing this configuration on a new machine, you'll need to set up SSH authentication for GitHub. Here's how to do it:

### 1. Generate an SSH Key Pair

After applying the NixOS configuration, generate a new SSH key pair:

```bash
# Generate a new SSH key (use your GitHub email address)
ssh-keygen -t ed25519 -C "jostein.hanssen@gmail.com" -f ~/.ssh/github -N ""

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/github
chmod 644 ~/.ssh/github.pub
```

### 2. Start the SSH Agent and Add Your Key

```bash
# Start the SSH agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/github
```

### 3. Add Your Public Key to GitHub

1. Display and copy your public key:

   ```bash
   cat ~/.ssh/github.pub
   ```

2. Go to GitHub in your browser
3. Click on your profile picture in the top-right corner
4. Select "Settings"
5. In the left sidebar, click on "SSH and GPG keys"
6. Click the "New SSH key" button
7. Give your key a descriptive title (e.g., "NixOS Desktop")
8. Paste your public key into the "Key" field
9. Click "Add SSH key"

### 4. Test Your SSH Connection

```bash
ssh -T git@github.com
```

You should see a message like: "Hi username! You've successfully authenticated, but GitHub does not provide shell access."

### 5. Using Git with SSH

The configuration in this repository automatically rewrites GitHub URLs to use SSH. This means you can use either format when cloning repositories:

```bash
# Both of these will use SSH authentication
git clone https://github.com/username/repo.git
git clone git@github.com:username/repo.git
```

For existing repositories that you've cloned using HTTPS, you can update them to use SSH by running:

```bash
git remote set-url origin git@github.com:username/repo.git
```
