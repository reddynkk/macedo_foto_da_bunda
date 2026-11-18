#!/bin/bash

# Interrompe a execução caso ocorra algum erro crítico
set -e

PROJECT_DIR="/root/Programacao-Web-2-main/"

echo "=================================================="
echo " PASSO 1: Verificando ambiente, pasta e permissões"
echo "=================================================="
whoami
pwd

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Erro: A pasta $PROJECT_DIR não existe."
    exit 1
fi

cd "$PROJECT_DIR"

if [ ! -w "$PROJECT_DIR" ]; then
    echo "Erro: A pasta não possui permissão de escrita para o usuário atual."
    exit 1
fi
echo "✓ Pasta OK e gravável."

echo ""
echo "=================================================="
echo " PASSO 2: Instalando e configurando o Git"
echo "=================================================="
sudo apt update
sudo apt install -y git openssh-client

# ---> ALTERE ABAIXO COM SEUS DADOS DO GITHUB <---
GIT_NAME="Diassis"
GIT_EMAIL="cardinguilherme@gmail.com"
GITHUB_USER="reddynkk"
# -----------------------------------------------

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
echo "✓ Git configurado globalmente para $GIT_NAME."

echo ""
echo "=================================================="
echo " PASSO 3: Criando o arquivo .gitignore de segurança"
echo "=================================================="
cat > .gitignore <<'EOF'
env
.env.*
config.local.php
*.log
/vendor/
/node_modules/
/uploads/
EOF
echo "✓ Arquivo .gitignore criado com sucesso."

echo ""
echo "=================================================="
echo " PASSO 4: Inicializando repositório e 1º commit"
echo "=================================================="
if [ ! -d ".git" ]; then
    git init -b main
else
    echo "Repositório git já inicializado."
fi

git add .
git status

# Verifica se há o que comitar para evitar erro caso esteja limpo
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "Nenhuma alteração nova para commit."
else
    git commit -m "Versão inicial do projeto"
    echo "✓ Primeiro commit realizado."
fi

echo ""
echo "=================================================="
echo " PASSO 5: Configurando chave SSH"
echo "=================================================="
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Gerando nova chave SSH Ed25519..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -N "" -f ~/.ssh/id_ed25519
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
else
    echo "✓ Chave SSH Ed25519 já existe."
fi

echo ""
echo "======================================================================"
echo "ATENÇÃO: Copie a chave pública abaixo e cole nas configurações do GitHub:"
echo "(Settings -> SSH and GPG keys -> New SSH key)"
echo "======================================================================"
cat ~/.ssh/id_ed25519.pub
echo "======================================================================"
echo ""
read -p "Pressione [Enter] APENAS assim que tiver cadastrado a chave no GitHub..."

echo "Testando conexão SSH com o GitHub..."
ssh -T git@github.com || true

echo ""
echo "=================================================="
echo " PASSO 6: Conectando ao repositório remoto e Push"
echo "=================================================="
git remote remove origin 2>/dev/null || true
git remote add origin "git@github.com:${GITHUB_USER}/macedo_foto_da_bunda.git"
git remote -v

echo "Enviando código para o GitHub (branch main)..."
git push -u origin main

echo ""
echo "=================================================="
echo " PROCESSO CONCLUÍDO COM SUCESSO! 🎉"
echo "=================================================="
git status
