#!/bin/bash
# Default variables
image_name=""
port="3000"
cpu="1"
memory="512Mi"
storage="512Mi"
placement_name="westcoast"
host="akash"
price="30"
file_path="$HOME/.akash/deploy.yaml"
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script helps to create Akash deployment configuration"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help                 show the help page"
		echo -e "  -in, --image-name NAME      Docker image NAME (${C_LGn}mandatory${RES})"
		echo -e "  -po, --port PORT            PORT to expose (default is '${C_LGn}${port}${RES}')"
		echo -e "  -c,  --cpu AMOUNT           desired AMOUNT of vCPU. E.g. '${C_LGn}100m${RES}' (1/10), '${C_LGn}0.5${RES}' (1/2), '${C_LGn}1${RES}' (default)"
		echo -e "  -m,  --memory AMOUNT        desired AMOUNT of memory. E.g. '${C_LGn}512Mi${RES}' (default), '${C_LGn}2Gi${RES}'"
		echo -e "  -s,  --storage AMOUNT       desired AMOUNT of storage. E.g. '${C_LGn}512Mi${RES}' (default), '${C_LGn}20Gi${RES}', '${C_LGn}1Ti${RES}'"
		echo -e "  -pn, --placement-name NAME  placement NAME (${C_LGn}mandatory${RES})"
		echo -e "                              NAME is '${C_LGn}westcoast${RES}' (default) or '${C_LGn}eastcoast${RES}'"
		echo -e "  -ht, --host HOST            leasing HOST (default is '${C_LGn}${host}${RES}')"
		echo -e "  -pr, --price PRICE          max price in uatk per block for the profile. E.g. '${C_LGn}10${RES}', '${C_LGn}30${RES}' (default), '${C_LGn}50${RES}'"
		echo -e "  -fp, --file-path NAME       path to file to save the config (default is ${C_LGn}${file_path}${RES})"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Akash/blob/main/config_builder.sh - script URL"
		echo -e "https://github.com/ovrclk/docs/blob/master/sdl/README.md - official configuration documentation"
		echo -e "https://github.com/SecorD0/Akash/blob/main/hosts.txt - list of hosts"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-in*|--image-name*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		image_name=`option_value "$1"`
		shift
		;;
	-po*|--port*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		port=`option_value "$1"`
		shift
		;;
	-c*|--cpu*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		cpu=`option_value "$1"`
		shift
		;;
	-m*|--memory*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		memory=`option_value "$1"`
		shift
		;;
	-s*|--storage*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		storage=`option_value "$1"`
		shift
		;;
	-pn*|--placement-name*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		placement_name=`option_value "$1"`
		shift
		;;
	-ht*|--host*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		host=`option_value "$1"`
		shift
		;;
	-pr*|--price*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		price=`option_value "$1"`
		shift
		;;
	-fp*|--file-path*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		file_path=`option_value "$1"`
		shift
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Actions
if [ ! -n "$image_name" ]; then
	printf_n "${C_R}You didn't specify an image name via${RES} -in ${C_R}option!${RES}"
	return 1 2>/dev/null; exit 1
fi
if [ "$placement_name" != "westcoast" ] && [ "$placement_name" != "eastcoast" ]; then
	printf_n "${C_R}There is no such placement! Use${RES} -h ${C_R}option to view the help page${RES}"
	return 1 2>/dev/null; exit 1
fi
config="---
version: \"2.0\"

services:
  web:
    image: ${image_name}
    expose:
      - port: ${port}
        as: 80
        to:
          - global: true

profiles:
  compute:
    web:
      resources:
        cpu:
          units: ${cpu}
        memory:
          size: ${memory}
        storage:
          size: ${storage}
  placement:
    ${placement_name}:
      attributes:
        host: ${host}
      signedBy:
        anyOf:
          - \"akash1365yvmc4s7awdyj3n2sav7xfx76adc6dnmlx63\"
      pricing:
        web: 
          denom: uakt
          amount: ${price}

deployment:
  web:
    ${placement_name}:
      profile: web
      count: 1"
echo "$config" > "$file_path"
printf_n "${C_LGn}Done!${RES}\n"
cat "$file_path"
printf_n "\n${C_LGn}cat \"$file_path\"${RES}"