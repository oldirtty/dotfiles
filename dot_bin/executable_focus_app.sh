#!/bin/bash

# Define o app alvo. Se nenhum for passado, usa 'spotify' como padrão.
TARGET_APP=${1:-spotify}

# Busca o ID numérico da janela no Niri usando jq
WINDOW_ID=$(niri msg -j windows | jq -r ".[] | select(.app_id == \"$TARGET_APP\") | .id" | head -n 1)

# Se o ID foi encontrado (a variável não está vazia), manda o Niri focar nela
if [ -n "$WINDOW_ID" ]; then
    niri msg action focus-window --id "$WINDOW_ID"
fi
