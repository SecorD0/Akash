#!/bin/bash
# Default variables
avg_block_time="6.207"
language="EN"
action=""
all="false"
config_file="$HOME/.akash/deploy.yaml"
dseq=""
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script provides advanced CLI client features"
		echo
		echo -e "Usage: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help               show help page"
		echo -e "  -l,  --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                            LANGUAGE is '${C_LGn}EN${RES}' (default), '${C_LGn}RU${RES}'"
		echo -e "  -a,  --action ACTION      execute the ACTION"
		echo -e "       --all                show inactive deployments in '${C_LGn}deployments_list${RES}' action"
		echo -e "  -сf, --config-file FILE   config FILE for deployment when using '${C_LGn}deployments_create${RES}'"
		echo -e "                            action (default is ${C_LGn}$config_file${RES})"
		echo -e "  -d,  --dseq DSEQ          deployment ID using in '${C_LGn}deployments_list${RES}',"
		echo -e "                            '${C_LGn}deployments_create${RES}', '${C_LGn}deployments_close${RES}', '${C_LGn}market_list${RES}' actions"
		echo
		echo -e "You can use ${C_LGn}either${RES} \"=\" or \" \" as an option and value delimiter"
		echo
		echo -e "${C_LGn}Arguments${RES} - any arguments separated by spaces for actions not specified in the script"
		echo
		echo -e "${C_LGn}Modified actions${RES}:"
		echo -e "  ${C_C}wallet_info${RES}          shows the wallet information"
		echo -e "  ${C_C}certificates_create${RES}  creates certificate"
		echo -e "  ${C_C}deployments_list${RES}     shows full information about active/inactive (view options) deployments"
		echo -e "  ${C_C}deployments_create${RES}   creates deployment. 5 AKT required for each deployment, which"
		echo -e "                       will be returned after confirmation of leasing or deployment cancellation"
		echo -e "  ${C_C}deployments_close${RES}    creates deployment and returns 5 AKT that were taken at creation"
		echo -e "  ${C_C}market_list${RES}          shows full information about providers by active or selected deployments"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Akash/blob/main/cli_client.sh - script URL"
		echo -e "         (you can send Pull request with new texts to add a language)"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-l*|--language*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		language=`option_value "$1"`
		shift
		;;
	-a*|--action*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		action=`option_value "$1"`
		shift
		;;
	--all)
		all="true"
		shift
		;;
	-cf*|--config-file*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		config_file=`option_value "$1"`
		shift
		;;
	-d*|--dseq*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		dseq=`option_value "$1"`
		shift
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
reverse() { printf "%s\n" "$@" | tac | tr "\n" " "; }
# Texts
if [ "$language" = "RU" ]; then
	t_wa1="Название кошелька:  ${C_LGn}%s${RES}"
	t_wa2="Адрес кошелька:     ${C_LGn}%s${RES}"
	t_wa3="Баланс:             ${C_LGn}%.3f${RES} AKT"
	t_wa4="Сертификат:         ${C_LGn}есть${RES}"
	t_wa5="Сертификат:         ${C_LR}нет${RES}"
	
	t_dl1="Всего деплоев: ${C_LGn}%d${RES}"
	t_dl2="Активных:      ${C_LGn}%d${RES}\n"
	t_dl3="—————————————————————————————————————\n\nDSEQ (ID):               ${C_LGn}%s${RES}"
	t_dl4="Статус:                  ${C_LGn}активный${RES}"
	t_dl5="Статус:                  ${C_LR}неактивный${RES}"
	
	t_dl6="\nПрофили (всего ${C_LGn}%d${RES}):"
	t_dl7="  QSEQ (ID):             ${C_LGn}%s${RES}"
	t_dl8="  Статус:                ${C_LGn}открытый${RES}"
	t_dl9="  Статус:                ${C_LR}закрытый${RES}"
	t_dl10="  Название:              ${C_LGn}%s${RES}"
	t_dl11="  Хост:                  ${C_LGn}%s${RES}"
	
	t_dl12="  Контейнеры (всего ${C_LGn}%d${RES}):"
	t_dl13="    CPU:                 ${C_LGn}%.1f${RES}"
	t_dl14="    RAM:                 ${C_LGn}%d${RES} МБ"
	t_dl15="    RAM:                 ${C_LGn}%.2f${RES} ГБ"
	t_dl16="    Хранилище:           ${C_LGn}%.2f${RES} ГБ"
	t_dl17="    Макс. цена за блок:  ${C_LGn}%d${RES} %s"
	
	t_dc1="Создан деплой, имеющий следующий DSEQ: ${C_LGn}%s${RES}"
	
	t_err_dcl="${C_LR}Вы не указали DSEQ с помощью опции${RES} -d ${C_LR}!${RES}"
	
	t_ml1="DSEQ (ID):  ${C_LGn}%s${RES}"
	t_ml2="\n—————————————————————————————————————\n\nПровайдер:  ${C_LGn}%s${RES}"
	t_ml3="Статус:     ${C_LGn}открытый${RES}\n"
	t_ml4="Статус:     ${C_LR}закрытый${RES}\n"
	t_ml_5="       ${C_LGn}Стоимость аренды${RES}"
	t_ml_6="За час    ${C_LGn}%.3f${RES} AKT\t${C_LGn}%.3f${RES}$"
	t_ml_7="За день   ${C_LGn}%.3f${RES} AKT\t${C_LGn}%.3f${RES}$"
	t_ml_8="За месяц  ${C_LGn}%.3f${RES} AKT\t${C_LGn}%.3f${RES}$\n"
	
	t_err_ml1="${C_LR}Не нашлось ни одного провайдера!${RES}\n\n"
	t_err_ml2="${C_LR}Все провайдеры недоступны!${RES}\n\n"
	
	t_done="${C_LGn}Готово!${RES}"
	t_unsuc="${C_LR}Что-то пошло не так!${RES}"
	t_unsuc_with_err="${C_LR}Что-то пошло не так!${RES}\n%s\n{C_LR}Что-то пошло не так!${RES}"
	t_err1="${C_LR}Вы не указали действие с помощью опции${RES} -a ${C_LR}!${RES}"
	t_err2="${C_LR}В сестеме нет переменной с названием кошелька!${RES}"
	t_err3="${C_LR}В сестеме нет переменной с адресом кошелька!${RES}"
	t_err4="${C_LR}Нет такого действия!${RES} Используйте опцию${RES} -h ${C_LR} для просмотра страницы помощи"
# Send Pull request with new texts to add a language - https://github.com/SecorD0/Massa/blob/main/cli_client.sh
#elif [ "$language" = ".." ]; then
else
	t_wa1="Wallet name:     ${C_LGn}%s${RES}"
	t_wa2="Wallet address:  ${C_LGn}%s${RES}"
	t_wa3="Balance:         ${C_LGn}%.3f${RES} AKT"
	t_wa4="Certificate:     ${C_LGn}yes${RES}"
	t_wa5="Certificate:     ${C_LR}no${RES}"
	
	t_dl1="Total deployments: ${C_LGn}%d${RES}"
	t_dl2="Active:            ${C_LGn}%d${RES}\n"
	t_dl3="—————————————————————————————————————\n\nDSEQ (ID):                 ${C_LGn}%s${RES}"
	t_dl4="Status:                    ${C_LGn}active${RES}"
	t_dl5="Status:                    ${C_LR}inactive${RES}"
	
	t_dl6="\nProfiles (${C_LGn}%d${RES} in total):"
	t_dl7="  QSEQ (ID):               ${C_LGn}%s${RES}"
	t_dl8="  Status:                  ${C_LGn}open${RES}"
	t_dl9="  Status:                  ${C_LR}closed${RES}"
	t_dl10="  Name:                    ${C_LGn}%s${RES}"
	t_dl11="  Host:                    ${C_LGn}%s${RES}"
	
	t_dl12="  Containers (${C_LGn}%d${RES} in total):"
	t_dl13="    CPU:                   ${C_LGn}%.1f${RES}"
	t_dl14="    RAM:                   ${C_LGn}%d${RES} МБ"
	t_dl15="    RAM:                   ${C_LGn}%.2f${RES} ГБ"
	t_dl16="    Storage:               ${C_LGn}%.2f${RES} ГБ"
	t_dl17="    Max. price per block:  ${C_LGn}%d${RES} %s"
	
	t_dc1="A deployment was created that has the following DSEQ: ${C_LGn}%s${RES}"
	
	t_err_dcl="${C_LR}You didn't specify DSEQ via${RES} -d ${C_LR}option!${RES}"
	
	t_ml1="DSEQ (ID):  ${C_LGn}%s${RES}"
	t_ml2="\n—————————————————————————————————————\n\nProvider:  ${C_LGn}%s${RES}"
	t_ml3="Status:    ${C_LGn}open${RES}\n"
	t_ml4="Status:    ${C_LR}closed${RES}\n"
	t_ml_5="       ${C_LGn}Lease price${RES}"
	t_ml_6="Per hour   ${C_LGn}%.3f${RES} AKT\t${C_LGn}%.3f${RES}$"
	t_ml_7="Per day    ${C_LGn}%.3f${RES} AKT\t${C_LGn}%.3f${RES}$"
	t_ml_8="Per month  ${C_LGn}%.3f${RES} AKT\t${C_LGn}%.3f${RES}$\n"
	
	t_err_ml1="${C_LR}There are no providers!${RES}\n\n"
	t_err_ml2="${C_LR}All providers are unavailable!${RES}\n\n"
	
	t_done="${C_LGn}Done!${RES}"
	t_unsuc="${C_LR}Something has gone wrong!${RES}"
	t_unsuc_with_err="${C_LR}Something has gone wrong!${RES}\n%s\n${C_LR}Something has gone wrong!${RES}"
	t_err1="${C_LR}You didn't specify DSEQ via${RES} -a ${C_LR}option!${RES}"
	t_err2="${C_LR}There is no variable with the wallet name!${RES}"
	t_err3="${C_LR}There is no variable with the wallet address!${RES}"
	t_err4="${C_LR}There is no such action!${RES} Use${RES} -h ${C_LR}option to view the help page"	
fi
# Mandatory variables
if [ ! -n "$action" ]; then
	printf_n "$t_err1"
	return 1 2>/dev/null; exit 1
fi
# Insert the missing variables
if [ ! -n "$akash_wallet_name" ]; then
	printf_n "$t_err2"
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n akash_wallet_name
fi
if [ ! -n "$akash_wallet_address" ]; then
	printf_n "$t_err3"
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n akash_wallet_address -v `akash keys show "$akash_wallet_name" -a --keyring-backend file`
fi
if [ ! -n "$akash_chain_id" ]; then
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n akash_chain_id -v "\`wget -qO- https://raw.githubusercontent.com/ovrclk/net/master/mainnet/chain-id.txt\`"
fi
if [ ! -n "$akash_project_node" ]; then
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n akash_project_node -v "\`wget -qO- https://raw.githubusercontent.com/ovrclk/net/master/mainnet/rpc-nodes.txt | head -2\`"
fi
# Actions
sudo apt install bc -y &>/dev/null
if [ "$action" = "wallet_info" ]; then
	printf_n "$t_wa1" "$akash_wallet_name"
	printf_n "$t_wa2" "$akash_wallet_address"
	printf_n "$t_wa3" `bc -l <<< "$(akash query bank balances "$akash_wallet_address" -o json --node "$akash_project_node" | jq -r ".balances[0].amount")/1000000"`
	cert=`akash query cert list --owner "$akash_wallet_address" --node "$akash_project_node"`
	if grep -q valid <<< $cert; then
		printf_n "$t_wa4"
	else
		printf_n "$t_wa5"
	fi	
elif [ "$action" = "certificates_create" ]; then
	resp=`akash tx cert create client \
	--chain-id "$akash_chain_id" \
	--fees 5000uakt \
	--from "$akash_wallet_name" \
	--node "$akash_project_node" \
	--keyring-backend file`
	if grep -q "cert-create-certificate" <<< $resp; then
		printf_n "$t_done"
	else
		printf_n "$t_unsuc_with_err" "$resp"
		return 1 2>/dev/null; exit 1
	fi
elif [ "$action" = "deployments_list" ]; then
	if [ -n "$dseq" ]; then
		deployments_list=`akash query deployment list --owner "$akash_wallet_address" --node "$akash_project_node" --dseq "$dseq" -o json`
	else
		deployments_list=`akash query deployment list --owner "$akash_wallet_address" --node "$akash_project_node" -o json`
		count=`jq -r ".deployments | length" <<< $deployments_list`
		printf_n "$t_dl1" "$count"
		active=`jq <<< $deployments_list | grep active | wc -l`
		printf_n "$t_dl2" "$active"
		if [ "$all" = "true" ]; then
			deployments_list=`akash query deployment list --owner "$akash_wallet_address" --node "$akash_project_node" -o json`
		else
			deployments_list=`akash query deployment list --owner "$akash_wallet_address" --node "$akash_project_node" -o json --state active`
		fi
	fi
	count=`jq -r ".deployments | length" <<< $deployments_list`
	read -r -a deployments <<< `jq -r ".deployments | to_entries[]" <<< $deployments_list | tr -d '[:space:]' | sed 's%}{%} {%g'`
	read -r -a deployments <<< `reverse "${deployments[@]}"`
	deployments="${deployments[@]:0:5}"
	for deployment in $deployments; do
		d_dseq=`jq -r ".value.deployment.deployment_id.dseq" <<< $deployment`
		d_state=`jq -r ".value.deployment.state" <<< $deployment`
		if [ "$d_state" = "active" ]; then
			printf_n "$t_dl3" "$d_dseq"
			printf_n "$t_dl4"
		else
			if [ "$all" = "true" ] || [ "$d_dseq" = "$dseq" ]; then
				printf_n "$t_dl3" "$d_dseq"
				printf_n "$t_dl5"
			else
				continue
			fi
		fi
		profiles=`jq -r ".value.groups | to_entries[]" <<< $deployment | tr -d '[:space:]' | sed 's%}{%} {%'g`
		printf_n "$t_dl6" `jq -r ".value.groups | length" <<< $deployment`
		for profile in $profiles; do
			p_qseq=`jq -r ".value.group_id.gseq" <<< $profile`
			printf_n "$t_dl7" "$p_qseq"
			p_state=`jq -r ".value.state" <<< $profile`
			if [ "$p_state" = "open" ]; then
				printf_n "$t_dl8"
			else
				printf_n "$t_dl9"
			fi
			p_name=`jq -r ".value.group_spec.name" <<< $profile`
			printf_n "$t_dl10" "$p_name"
			p_host=`jq -r ".value.group_spec.requirements.attributes[0].value" <<< $profile`
			printf_n "$t_dl11" "$p_host"
			containers=`jq -r ".value.group_spec.resources | to_entries[]" <<< $profile | tr -d '[:space:]' | sed 's%}{%} {%g'`
			printf_n "$t_dl12" `jq -r ".value.group_spec.resources | length" <<< $profile`
			for container in $containers; do
				p_cpu=`bc -l <<< "$(jq -r '.value.resources.cpu.units.val' <<< $container)/1000"`
				printf_n "$t_dl13" "$p_cpu"
				p_ram=`bc -l <<< "$(jq -r '.value.resources.memory.quantity.val' <<< $container)/1024/1024"`
				if [ `bc <<< "$p_ram<1024"` -eq "1" ]; then
					printf_n "$t_dl14" "$p_ram" 2>/dev/null
				else
					printf_n "$t_dl15" `bc -l <<< "$p_ram/1024"`
				fi
				p_storage=`bc -l <<< "$(jq -r '.value.resources.storage.quantity.val' <<< $container)/1024/1024/1024"`
				printf_n "$t_dl16" "$p_storage"
				p_amount=`jq -r '.value.price.amount' <<< $container`
				p_denom=`jq -r '.value.price.denom' <<< $container`
				printf_n "$t_dl17" "$p_amount" "$p_denom" 2>/dev/null
			done
			printf_n
		done
		printf_n
	done
	if [ ! $count -eq "0" ]; then printf_n "—————————————————————————————————————\n"; fi
elif [ "$action" = "deployments_create" ]; then
	resp=`akash tx deployment create "$config_file" \
	--chain-id "$akash_chain_id" \
	--fees 5000uakt \
	--from "$akash_wallet_name" \
	--node "$akash_project_node" \
	--keyring-backend file`
	if grep -q "deployment-created" <<< $resp; then
		printf_n "$t_dc1" `jq -r '.logs[0].events[0].attributes[4].value'`
	else
		printf_n "$t_unsuc_with_err" "$resp"
		return 1 2>/dev/null; exit 1
	fi
elif [ "$action" = "deployments_close" ]; then
	if [ ! -n "$dseq" ]; then
		printf_n "$t_err_dcl"
		return 1 2>/dev/null; exit 1
	else
		resp=`akash tx deployment close \
		--chain-id "$akash_chain_id" \
		--fees 5000uakt \
		--owner "$akash_wallet_address" \
		--from "$akash_wallet_name" \
		--dseq "$dseq"  \
		--node "$akash_project_node" \
		--keyring-backend file`
		if grep -q "deployment-closed" <<< $resp; then
			printf_n "$t_done"
		else
			printf_n "$t_unsuc_with_err" "$resp"
			return 1 2>/dev/null; exit 1
		fi
	fi
elif [ "$action" = "market_list" ]; then
	if [ -n "$dseq" ]; then
		active_deployments="$dseq"
	else
		read -r -a active_deployments <<< `akash query deployment list --owner "$akash_wallet_address" --node "$akash_project_node" -o json --state active | jq | grep -oP '(?<="dseq": ")([^%]+)(?="$)' | tr '\n' ' '`
		read -r -a active_deployments <<< `reverse "${active_deployments[@]}"`
		active_deployments="${active_deployments[@]}"
	fi
	akt_price=`. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/parsers/token_price.sh) -ts AKT`
	for active_deployment in $active_deployments; do
		printf_n "$t_ml1" "$active_deployment"
		bids=`akash query market bid list --owner $akash_wallet_address --node $akash_project_node --dseq "$active_deployment" -o json`
		bids=`jq -r ".bids | to_entries[]" <<< $bids | tr -d '[:space:]' | sed 's%}{%} {%'g`
		if [ ! -n "$bids" ]; then
			printf_n "$t_err_ml1"
		else
			for bid in $bids; do
				b_provider=`jq -r ".value.bid.bid_id.provider" <<< $bid`
				printf_n "$t_ml2" "$b_provider"
				b_state=`jq -r ".value.bid.state" <<< $bid`
				if [ "$d_state" = "open" ]; then
					printf_n "$t_ml3"
				else
					printf_n "$t_ml4"
				fi
				price_per_block=`jq -r ".value.bid.price.amount" <<< $bid`
				blocks_per_day=`bc -l <<< "86400/${avg_block_time}"`
				price_per_d_akt=`bc -l <<< "${blocks_per_day}*${price_per_block}/1000000"`
				printf_n "$t_ml_5"
				price_per_h_akt=`bc -l <<< "${price_per_d_akt}/24"`
				price_per_h_usdt=`bc -l <<< "${akt_price}*${price_per_h_akt}"`
				printf_n "$t_ml_6" "$price_per_h_akt" "$price_per_h_usdt"
				price_per_d_usdt=`bc -l <<< "${akt_price}*${price_per_d_akt}"`
				printf_n "$t_ml_7" "$price_per_d_akt" "$price_per_d_usdt"
				price_per_m_akt=`bc -l <<< "${price_per_d_akt}*30"`
				price_per_m_usdt=`bc -l <<< "${akt_price}*${price_per_m_akt}"`
				printf_n "$t_ml_8" "$price_per_m_akt" "$price_per_m_usdt"
			done
		fi
		if [ -n "$bids" ]; then printf_n "—————————————————————————————————————\n\n"; fi
	done
else
	printf_n "$t_err4"
fi