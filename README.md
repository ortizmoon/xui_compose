# Autodeploy VLESS via ansible

## Asset: <br>
**[3X-UI](https://github.com/MHSanaei/3x-ui)** - VLESS<br> 
**Haproxy**- L4 balancer<br>
**Wildcard certs - Cloudflare DNS01 with API-token** <br>
**Auto backups -  Cloudflare R2-backet with API-token** <br>

<p align="center">
  <img src="https://raw.githubusercontent.com/MHSanaei/3x-ui/main/media/3x-ui.png" width="600">
</p>

## Quick start

### Setup inventory

```yaml
all:
  children:
    xui:
      hosts:
        xui_server:
          ansible_host: YOUR_VPS_IP
          ansible_user: YOUR_VPS_USER
```

### Configure vars

```bash
# Copy and edit examples
inventories/group_vars/xui/main.yml.example
inventories/group_vars/xui/creds.yml.example 
```

### Deploy

```bash
ansible-playbook playbooks/vpn_deploy.yml
```

### Manual backup

```bash
ssh xui_server
sudo systemctl start backup-db.service
sudo journalctl -u backup-db.service -f
```

## Playbook flags

Edit `playbooks/deploy.yml` before running:

```yaml
xui_control_deploy_cert: true          ## Setup DNS + certificates
xui_control_install_3xui: true         ## Install HAProxy + 3X-UI
xui_control_restore_db: true          ## Restore from R2 (migration)
xui_control_add_backup_service: true   ## Setup backup service
```
<br>

## License

MIT
