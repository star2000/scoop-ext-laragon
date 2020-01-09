# scoop-ext-laragon

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/laragon)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/laragon)

Manage [laragon](https://laragon.org) app from [scoop](https://scoop.sh).

## install

```ps1
inmo laragon -Scope CurrentUser
```

## example

- inla is short for Install-LaragonApp.
- unla is short for Uninstall-LaragonApp.

```ps1
# Install the latest version of mariadb
inla mariadb

# Install the specified version
inla nginx@1.16.1

# Uninstall apache
unla apache
```
