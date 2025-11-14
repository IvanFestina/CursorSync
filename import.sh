#!/bin/bash

# Скрипт для импорта настроек Cursor (macOS)
# Использование: ./import.sh

set -e

# Путь к настройкам Cursor на macOS
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

echo "📥 Импорт настроек Cursor..."
echo "Целевая директория: $CURSOR_USER_DIR"

# Создаем директорию, если её нет
mkdir -p "$CURSOR_USER_DIR"
mkdir -p "$CURSOR_USER_DIR/globalStorage"

# Проверяем наличие файлов для импорта
if [ ! -d "settings" ]; then
    echo "❌ Директория 'settings' не найдена!"
    echo "   Убедитесь, что вы выполнили export.sh на другом устройстве"
    exit 1
fi

# Создаем резервную копию существующих настроек
BACKUP_DIR="$HOME/.cursor-settings-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "$CURSOR_USER_DIR" ] && [ "$(ls -A $CURSOR_USER_DIR 2>/dev/null)" ]; then
    echo "💾 Создание резервной копии текущих настроек..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$CURSOR_USER_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
    echo "✅ Резервная копия создана: $BACKUP_DIR"
fi

# Импортируем settings.json
if [ -f "settings/settings.json" ]; then
    cp "settings/settings.json" "$CURSOR_USER_DIR/"
    echo "✅ settings.json импортирован"
else
    echo "⚠️  settings.json не найден в settings/"
fi

# Импортируем keybindings.json
if [ -f "settings/keybindings.json" ]; then
    cp "settings/keybindings.json" "$CURSOR_USER_DIR/"
    echo "✅ keybindings.json импортирован"
else
    echo "⚠️  keybindings.json не найден в settings/"
fi

# Импортируем snippets
if [ -d "settings/snippets" ]; then
    cp -r "settings/snippets" "$CURSOR_USER_DIR/"
    echo "✅ snippets импортированы"
else
    echo "⚠️  snippets не найдены в settings/"
fi

# Импортируем globalStorage
if [ -f "settings/globalStorage/storage.json" ]; then
    cp "settings/globalStorage/storage.json" "$CURSOR_USER_DIR/globalStorage/" 2>/dev/null || true
    echo "✅ globalStorage импортирован"
fi

# Устанавливаем расширения
if [ -f "extensions/extensions.txt" ]; then
    echo ""
    echo "📦 Установка расширений..."
    
    CURSOR_CMD="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
    if command -v cursor &> /dev/null; then
        CMD="cursor"
    elif [ -f "$CURSOR_CMD" ]; then
        CMD="$CURSOR_CMD"
    else
        CMD=""
    fi
    
    if [ ! -z "$CMD" ]; then
        while IFS= read -r extension; do
            if [ ! -z "$extension" ]; then
                echo "   Установка: $extension"
                "$CMD" --install-extension "$extension" || echo "   ⚠️  Не удалось установить: $extension"
            fi
        done < extensions/extensions.txt
        echo "✅ Расширения установлены"
    else
        echo "⚠️  Команда 'cursor' не найдена"
        echo "   Установите расширения вручную из файла: extensions/extensions.txt"
        echo "   Используйте: /Applications/Cursor.app/Contents/Resources/app/bin/cursor --install-extension <extension-id>"
    fi
else
    echo "⚠️  extensions/extensions.txt не найден"
fi

echo ""
echo "✨ Импорт завершен!"
echo ""
echo "🔄 Перезапустите Cursor, чтобы применить настройки"
echo "💡 Если что-то пошло не так, резервная копия находится в: $BACKUP_DIR"

