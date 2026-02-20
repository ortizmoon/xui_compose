# Ansible-проект для автоматического развёртывания VLESS VPN на вашей VPS.
---
<p align="center">
  <img src="https://img.shields.io/badge/Ansible-automation-EE0000?style=for-the-badge&logo=ansible">
  <img src="https://img.shields.io/badge/3X--UI-VLESS-1E90FF?style=for-the-badge">
  <img src="https://img.shields.io/badge/HAProxy-L4%20SNI%20Router-6A0DAD?style=for-the-badge&logo=haproxy">
  <img src="https://img.shields.io/badge/Cloudflare-DNS--01-F38020?style=for-the-badge&logo=cloudflare">
  <img src="https://img.shields.io/badge/Cloudflare-R2%20Bucket-F38020?style=for-the-badge&logo=cloudflare">
</p>




Устанавливает [3X-UI](https://github.com/mhsanaei/3x-ui) за HAProxy L4 балансировщиком,<br> выпускает wildcard TLS-сертификаты через Certbot + Cloudflare DNS-01,<br> настраивает автоматический бэкап базы данных в Cloudflare R2-бакет.
---
### Перед запуском роли, уже должно быть:
- Настроен рут-доступ по ssh, к нужной VPS
- Создан Cloudflare R2-бакет + S3-ключи
- Куплен домен у Cloudflare
- Сгенерирован api-токен для купленного домена, с правами `Zone:DNS:Edit`
<br>
<br>

## Архитектура

Haproxy маршрутизирует трафик по TLS SNI, с фронта `ft_main:443`, на бэкенды:

```
vless_fake_domain --> Xray/VLESS:55555
xui_panel_domain --> 3X-UI panel:2053
ssh_domain` --> sshd :22
```
<br>

Предполагается, что, по итогу, сервер наружу будет открыт только по порту **443**.<br>
Поэтому для подключения по ssh, на клиенте рекомендуется настроить примерно такой алиас:
```
host vps
hostname connect.mydomain.com
port 443
user root
proxycommand openssl s_client -connect %h:%p -servername connect.mydomain.com -quiet 2>/dev/null
```
<br>



## Деплой

### Установить коллекции:

```bash
ansible-galaxy collection install -r requirements.yml
```
---

### Отредактировать `inventories/inventory.yml`:

```yaml
all:
  children:
    xui:
      hosts:
        xui_server:
          ansible_host: YOUR_VPS_IP
          ansible_user: root
```
---

### Скопировать и задать переменные:

```bash
cp inventories/group_vars/xui/main.yml.example inventories/group_vars/xui/main.yml
cp inventories/group_vars/xui/creds.yml.example inventories/group_vars/xui/creds.yml
```

**`main.yml`** — основные переменные:

| Переменная | Описание | Пример |
|---|---|---|
| `main_domain` | Корневой домен на Cloudflare | `example.com` |
| `xui_panel_domain` | Поддомен для панели 3x-ui | `panel.example.com` |
| `ssh_domain` | Поддомен для ssh | `connect.example.com` |
| `vless_fake_domain` | Маскирующий SNI для VLESS | `vk.com` |



### Запуск роли

```bash
ansible-playbook playbooks/vpn_deploy.yml
```


## Playbook флаги

В `playbooks/vpn_deploy.yml` управляются через vars роли:

```yaml
xui_control_deploy_cert: true         # Создать DNS-записи + выпустить wildcard TLS-сертификат
xui_control_install_3xui: true        # Установить haproxy + 3X-UI
xui_control_restore_db: false         # Восстановить БД из R2 (используется при миграции)
xui_control_add_backup_service: true  # Задеплоить службу в виде скрипта для бэкапа, с кроном
```

## Бэкап и восстановление

Бэкап запускается ежедневно в **04:00** через systemd-таймер (можно изменить на свое в vars)<br>
Файлы хранятся в R2 с именем `x-ui-YYYY-MM-DD_HHMMSS.db`

**Запустить бэкап вручную:**

```bash
systemctl start backup-db.service
```

## Обновление сертификата

Certbot обновляет сертификат автоматически.<br> После каждого обновления хук
`/etc/letsencrypt/renewal-hooks/deploy/renewal-hook.sh` пересобирает `bundle.pem`
и перезагружает haproxy.

## Лицензия

MIT
