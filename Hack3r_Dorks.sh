#!/bin/bash
# Script de Enumeração com Google Dorks
# By WTECHSEC

# Exibição do Banner

    echo " ██████████                           ████               █████   █████                    █████       ████████           "
    echo "░░███░░░░░█                          ░░███              ░░███   ░░███                    ░░███       ███░░░░███          "
    echo " ░███  █ ░   █████   ██████   ██████  ░███   ██████      ░███    ░███   ██████    ██████  ░███ █████░░░    ░███ ████████ "
    echo " ░██████    ███░░   ███░░███ ███░░███ ░███  ░░░░░███     ░███████████  ░░░░░███  ███░░███ ░███░░███    ██████░ ░░███░░███"
    echo " ░███░░█   ░░█████ ░███ ░░░ ░███ ░███ ░███   ███████     ░███░░░░░███   ███████ ░███ ░░░  ░██████░    ░░░░░░███ ░███ ░░░ "
    echo " ░███ ░   █ ░░░░███░███  ███░███ ░███ ░███  ███░░███     ░███    ░███  ███░░███ ░███  ███ ░███░░███  ███   ░███ ░███     "
    echo " ██████████ ██████ ░░██████ ░░██████  █████░░████████    █████   █████░░████████░░██████  ████ █████░░████████  █████    "
    echo "░░░░░░░░░░ ░░░░░░   ░░░░░░   ░░░░░░  ░░░░░  ░░░░░░░░    ░░░░░   ░░░░░  ░░░░░░░░  ░░░░░░  ░░░░ ░░░░░  ░░░░░░░░  ░░░░░     "
    echo "                                                                                                                         "
                                                                                                                             
    echo "                                            Google Dorks Script V.2                                                            "



# Verificação de dependências
if ! command -v curl &> /dev/null; then
    echo "O 'curl' é necessário, mas não está instalado. Por favor, instale-o e tente novamente."
    exit 1
fi

# Variáveis gerais
domain=$1
folder_name="${domain//https:\/\//}" 
folder_name="${folder_name//http:\/\//}"
output_file="${folder_name}/dorks_results.txt" # Nome do arquivo
sleeptime=6
use_proxy=""

# Verificação de domínio
if [ -z "$domain" ]; then
    echo "Uso: $0 <domínio>"
    echo "Exemplo: $0 www.exemplo.com"
    exit 1
fi

# Cria a pasta para o domínio se não existir
mkdir -p "$folder_name"

# Lista de user-agents para evitar bloqueios
user_agents=("Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
             "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
             "Mozilla/5.0 (Linux; Android 10; Mobile)")

# Menu para escolha de uso de proxy
echo "Deseja usar proxies para mascarar seu IP? (s/n)"
read -r proxy_choice

if [[ "$proxy_choice" == "s" || "$proxy_choice" == "S" ]]; then
    use_proxy="true"
    # Lê proxies de um arquivo
    proxies=()
    while IFS= read -r line; do
        proxies+=("$line")
    done < proxies.txt

    # Verifica se há proxies disponíveis
    if [ ${#proxies[@]} -eq 0 ]; then
        echo "Nenhum proxy encontrado no arquivo proxies.txt. O script será executado sem proxies."
        use_proxy=""
    fi
fi

# Cria ou limpa o arquivo de saída
> "$output_file"

# Função de consulta
function Query {
    local query_type=$1
    local query_str="$2" # Usa o parâmetro fornecido
    local result=""

    echo "Executando Dork: $query_type - $query_str"
    
    for start in `seq 0 10 40`; do
        random_agent=${user_agents[$RANDOM % ${#user_agents[@]}]}
        
        # Se usar proxy, seleciona um proxy aleatório
        if [ "$use_proxy" ]; then
            random_proxy=${proxies[$RANDOM % ${#proxies[@]}]}
            query=$(curl -sS -A "$random_agent" -x "$random_proxy" "https://www.google.com/search?q=site:$domain%20$query_str&start=$start&client=firefox-b-e")
        else
            query=$(curl -sS -A "$random_agent" "https://www.google.com/search?q=site:$domain%20$query_str&start=$start&client=firefox-b-e")
        fi

        # Verificação de bloqueio do Google
        if echo "$query" | grep -q "https://www.google.com/sorry/index"; then
            echo "Bloqueado pelo Google! Tente novamente mais tarde."
            exit
        fi

        # Extrair URLs do resultado
        checkdata=$(echo "$query" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_~-]*$domain/[a-zA-Z0-9./?=_~-]*")
        
        # Verifica se não há mais resultados
        if [ -z "$checkdata" ]; then
            sleep $sleeptime
            break
        else
            result+="$checkdata "
            sleep $((RANDOM % 5 + 5)) # Atraso aleatório entre 5 e 10 segundos
        fi
    done

    # Exibir e salvar resultados
    if [ -n "$result" ]; then
        IFS=$'\n' sorted=($(sort -u <<<"${result[@]}" | tr " " "\n"))
        for each in "${sorted[@]}"; do
            echo "$query_type: $each" | tee -a "$output_file"
        done
    else
        echo "Nenhum resultado para $query_type" | tee -a "$output_file"
    fi
}

# Execução dos Google Dorks com mais consultas focadas em pentesting
dorks=(
    "Login Pages|inurl:login"
    "Painéis de Admin|inurl:admin"
    "Emails|intext:@$domain"
    "Listas de Usuários|filetype:txt intext:@$domain"
    "Documentos PDF|filetype:pdf"
    "Planilhas Excel|filetype:xls OR filetype:xlsx"
    "Documentos Word|filetype:doc OR filetype:docx"
    "Apresentações PowerPoint|filetype:ppt OR filetype:pptx"
    "Pastas FTP|intitle:\"index of\" \"ftp\""
    "Configurações Expostas|ext:xml OR ext:conf OR ext:cnf OR ext:reg OR ext:env"
    "Pastas Públicas|intitle:\"index of\""
    "Backup Files|ext:bkf OR ext:bkp OR ext:bak OR ext:old OR ext:backup"
    "Arquivos de Logs|filetype:log"
    "Scripts de Banco de Dados|filetype:sql"
    "WordPress Paths|inurl:wp-content OR inurl:wp-includes"
    "WordPress Backup|inurl:wp-content/backup"
    "WordPress XML-RPC|inurl:xmlrpc.php"
    "Path Traversal|inurl:../../../../ OR inurl:../.."
    "Vulnerabilidades PHP|filetype:php inurl:error"
    "Diretórios Expandidos|intitle:\"index of /admin\" OR intitle:\"index of /config\" OR intitle:\"index of /backup\""
    "Exposição de Logs de Erro|intitle:\"index of\" error_log"
    "Listas de Senhas|filetype:txt intext:password"
    "Configurações de Banco de Dados|inurl:db OR inurl:database OR filetype:sql OR filetype:cnf"
    "Arquivo .htaccess Exposto|filetype:htaccess"
    "Arquivo .git Exposto|inurl:.git"
    "Chaves SSH Expostas|filetype:key OR intext:ssh-rsa OR intext:ssh-dss"
    "Configurações de FTP|inurl:ftpconfig OR filetype:ini"
    "Configurações de Email|intext:smtp OR intext:mail OR intext:email OR filetype:eml"
    "Arquivos Python|filetype:py"
    "Códigos Fontes Expostos|filetype:java OR filetype:c OR filetype:cpp OR filetype:cs"
    "Documentos Internos|intitle:\"index of\" confidential"
    "Controle de Versão Exposto|inurl:.svn OR inurl:.hg"
    "Arquivos de Certificado|filetype:crt OR filetype:pem OR filetype:key"
    "Paginas Admin Expostas|intitle:\"admin\" \"login\" OR inurl:admin"
)

# Executa cada dork
for dork in "${dorks[@]}"; do
    IFS='|' read -r query_type query_str <<< "$dork"
    Query "$query_type" "$query_str"
done

echo "A enumeração com Google Dorks foi concluída. Os resultados estão no arquivo: $output_file"
