# 0x0B-ssh

This project covers basic SSH key management and configuration tasks for secure server access.

## Task List

### 0. Use a private key
- **File:** `0-use_a_private_key`
- **Description:** Bash script to connect to a server using the private key `~/.ssh/school` as the `ubuntu` user.
- **Usage:**
  ```bash
  ./0-use_a_private_key <server_ip>
  ```

### 1. Create an SSH key pair
- **File:** `1-create_ssh_key_pair`
- **Description:** Bash script to generate a 4096-bit RSA key pair named `school` with passphrase `betty`.
- **Usage:**
  ```bash
  ./1-create_ssh_key_pair
  ```

### 2. Client configuration file
- **File:** `2-ssh_config`
- **Description:** SSH client config to use the private key and disable password authentication.

### 3. Let me in!
- **Description:** Add the provided public key to your server's `~/.ssh/authorized_keys` for the `ubuntu` user.

### 4. Client configuration file (with Puppet)
- **File:** `100-puppet_ssh_config.pp`
- **Description:** Puppet manifest to configure SSH client to use the private key and disable password authentication.
- **Usage:**
  ```bash
  sudo puppet apply 100-puppet_ssh_config.pp
  ```

## Notes
- All scripts are executable and start with the correct shebang and a comment.
- Replace `<server_ip>` with your actual server's public IP address.
- Ensure you have the correct permissions for your SSH keys and config files.
