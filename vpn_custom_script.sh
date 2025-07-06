echo "Custom OpenVPN Script"
echo $CUSTOM_SCRIPT_MODE

#env

interface_name=$(ip route show default | awk '/default/ {print $5}')
ip_cidr=$(ip addr show "$interface_name" | grep 'inet ' | awk '{print $2}')
local_network=$(ipcalc "$ip_cidr" | grep Network | awk '{print $2}')
tun_network=$(ipcalc "$ifconfig_local" "$ifconfig_netmask" | grep Network | awk '{print $2}')

if [ "$CUSTOM_SCRIPT_MODE" = "up" ]; then
	ip addr add $ifconfig_local dev $dev
	ip link set dev $dev up

	ip route add $tun_network dev $dev scope link src $ifconfig_local table 200
	ip route add default via $route_vpn_gateway dev $dev src $ifconfig_local table 200

	ip rule add from all uidrange $UID_RANGE lookup 200
	ip rule add to $route_vpn_gateway lookup 200
	ip rule add from $tun_network lookup 200
	ip rule add to $trusted_ip lookup main
	ip rule add to $local_network lookup main
else
	ip rule del from all uidrange $UID_RANGE lookup 200
	ip rule del to $route_vpn_gateway lookup 200
	ip rule del from $tun_network lookup 200
	ip rule del to $trusted_ip lookup main
	ip rule del to $local_network lookup main
fi