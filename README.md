Este es el archivo ejemplo mencionado en el artículo: “Comprendiendo cómo funciona OpenVPN y configurar un Split Tunnel basado en usuarios” de dev.to

El script configura, automáticamente, el networking de nuestro sistema con un Split Tunnel basado en UID. Solo el tráfico generado por un rango de usuarios determinado usará el túnel de OpenVPN, el resto usará la red normal. 

Este script está pensado para ser integrado a OpenVPN y NixOS. El script puede ser integrado de esta manera en `configuration.nix`:

```
...
services.openvpn = {
  servers = {
    myOpenVPN = {
      config = "config /etc/nixos/config.ovpn \n route-noexec \n ifconfig-noexec";
      updateResolvConf = true;
      up = ''
        UID_RANGE=""
        CUSTOM_SCRIPT_MODE="up"
        ${builtins.readFile /etc/nixos/vpn_custom_script.sh}
      '';
      down = ''
        UID_RANGE=""
        CUSTOM_SCRIPT_MODE="down"
        ${builtins.readFile /etc/nixos/vpn_custom_script.sh}
      '';
    };
  };
};
systemd.services.openvpn-myOpenVPN.path = [ pkgs.gawk pkgs.ipcalc ];
...
```

El ejemplo asume que el script y archivo de configuración `config.ovpn` están en `/etc/nixos/`.
`UID_RANGE` debe ser configurado con el rango de UID de los usuarios que usara el túnel de OpenVPN. Ej: `1100-1200` o `1005-1005` (en caso de ser solo un usuario).
