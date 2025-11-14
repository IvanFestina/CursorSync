#!/bin/bash

# Скрипт для экспорта настроек Cursor (macOS)
# Использование: ./export.sh

set -e

# Путь к настройкам Cursor на macOS
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"

# Создаем директории для экспорта
mkdir -p settings
mkdir -p extensions

echo "📦 Экспорт настроек Cursor..."
echo "Источник: $CURSOR_USER_DIR"

# Копируем основные файлы настроек
if [ -f "$CURSOR_USER_DIR/settings.json" ]; then
    cp "$CURSOR_USER_DIR/settings.json" settings/
    echo "✅ settings.json экспортирован"
else
    echo "⚠️  settings.json не найден"
fi

if [ -f "$CURSOR_USER_DIR/keybindings.json" ]; then
    cp "$CURSOR_USER_DIR/keybindings.json" settings/
    echo "✅ keybindings.json экспортирован"
else
    echo "⚠️  keybindings.json не найден"
fi

# Копируем snippets
if [ -d "$CURSOR_USER_DIR/snippets" ]; then
    cp -r "$CURSOR_USER_DIR/snippets" settings/
    echo "✅ snippets экспортированы"
else
    echo "⚠️  snippets не найдены"
fi

# Экспортируем список расширений
CURSOR_CMD="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
if command -v cursor &> /dev/null; then
    cursor --list-extensions > extensions/extensions.txt
    echo "✅ Список расширений экспортирован"
elif [ -f "$CURSOR_CMD" ]; then
    "$CURSOR_CMD" --list-extensions > extensions/extensions.txt
    echo "✅ Список расширений экспортирован"
else
    echo "⚠️  Команда 'cursor' не найдена. Установите расширения вручную."
fi

# Экспортируем настройки UI (темы и т.д.)
if [ -f "$CURSOR_USER_DIR/globalStorage/storage.json" ]; then
    mkdir -p settings/globalStorage
    cp "$CURSOR_USER_DIR/globalStorage/storage.json" settings/globalStorage/ 2>/dev/null || true
fi

# Создаем файл с информацией о системе
cat > settings/system-info.txt << EOF
Дата экспорта: $(date)
ОС: $(uname -s)
Версия: $(uname -r)
Пользователь: $(whoami)
EOF

echo ""
echo "✨ Экспорт завершен!"
echo "📁 Настройки сохранены в директории: settings/"
echo "📁 Список расширений: extensions/extensions.txt"
echo ""
echo "💡 Следующие шаги:"
echo "   1. Закоммитьте изменения в git"
echo "   2. Запушьте в репозиторий"
echo "   3. На другом устройстве выполните: ./import.sh"

