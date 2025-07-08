# Custom DAT Builder

Автоматическая сборка кастомного файла custom.dat для Xray

**Актуальная версия собранного файла:** [custom.dat](https://github.com/xxphantom/custom-dat-file/releases/latest/download/custom.dat)

## Структура проекта

```
├── lists/                  # Исходные списки доменов (по одному файлу на категорию)
├── domain-list-community/  # Инструмент для компиляции DAT файлов
├── output/                 # Скомпилированный custom.dat
├── Makefile                # Скрипты сборки
└── .github/
    └── workflows/          # GitHub Actions для автосборки
```

## Требования

- Go >= 1.22
- Make

## Использование

### Локальная сборка

```bash
# Сборка custom.dat со всеми списками
make build
```

### Автоматическая сборка

При пуше изменений в директорию `lists/` автоматически:

1. Запускается сборка через GitHub Actions
2. Создается новый релиз с версией вида `v2025.01.08-123`
3. Файл `custom.dat` публикуется в релизе

Все релизы доступны на странице [Releases](https://github.com/xxphantom/custom-dat-file/releases).

## Структура данных

Все списки доменов находятся в директории `lists/`. Каждый файл представляет отдельную категорию доменов, названную по имени файла.

### Синтаксис

```
# Комментарий
include:another-file        # Включить содержимое другого файла
domain:google.com @attr1 @attr2  # Домен с атрибутами
keyword:google              # Ключевое слово
regexp:www\.google\.com$    # Регулярное выражение
full:www.google.com         # Полное соответствие домена
```

#### Описание правил:

- **Комментарии** начинаются с `#`. Могут быть в любом месте строки. Всё после `#` игнорируется при сборке.
- **Включение файлов** начинается с `include:`, за которым следует имя существующего файла в той же директории.
- **Поддомены** начинаются с `domain:`, за которым следует валидное доменное имя. Префикс `domain:` можно опустить.
- **Ключевые слова** начинаются с `keyword:`, за которым следует строка для поиска.
- **Регулярные выражения** начинаются с `regexp:`, за которым следует валидное регулярное выражение (по стандарту Golang).
- **Полные домены** начинаются с `full:`, за которым следует полное доменное имя.
- **Атрибуты** начинаются с `@` и могут быть добавлены к любому домену для создания подгрупп.

💡 **Совет**: Избегайте чрезмерного использования `regexp` и `keyword` правил, так как они менее эффективны и будут нагружать ЦП.

### Как это работает

При сборке DAT файла происходит следующее:

1. Удаляются все комментарии
2. `include:` строки заменяются фактическим содержимым указанных файлов
3. Пустые строки игнорируются
4. Каждая `domain:` строка преобразуется в правило поддомена
5. Каждая `keyword:` строка преобразуется в правило поиска по домену
6. Каждая `regexp:` строка преобразуется в правило регулярного выражения
7. Каждая `full:` строка преобразуется в правило полного соответствия

### Организация доменов

#### Атрибуты

Атрибуты полезны для создания подгрупп доменов. Например, список Google может содержать как основные домены, так и рекламные. Рекламные домены можно пометить атрибутом `@ads`:

```
google.com
youtube.com
doubleclick.net @ads
googleadservices.com @ads
```

Использование в Xray: `geosite:google@ads` выберет только домены с атрибутом `@ads`.

## Использование в Xray

После сборки файл `custom.dat` нужно скопировать в директорию Xray и использовать через префикс `ext:`:

```json
{
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "domain": [
          "geosite:google",
          "geosite:facebook",
          "geosite:youtube",
          "ext:custom.dat:custom-block",
          "ext:custom.dat:custom-ai"
        ],
        "outboundTag": "proxy"
      }
    ]
  }
}
```

### Использование с атрибутами:

```json
{
  "type": "field",
  "domain": [
    "ext:custom.dat:custom-block@apple",
    "ext:custom.dat:custom-ai@google"
  ],
  "outboundTag": "direct"
}
```

⚠️ **Важно**: Для кастомных DAT файлов используйте префикс `ext:имя_файла.dat:категория` вместо `geosite:`

## Добавление новых списков

1. Создайте файл в директории `lists/` с именем категории (например, `mylist`)
2. Добавьте домены в файл (по одному на строку)
3. Запустите `make build` или закоммитьте изменения
4. Используйте как `geosite:mylist` в конфигурации

## 🚀 Создание собственного кастомного DAT

Вы можете создать свой собственный репозиторий для автоматической сборки DAT файлов:

### Вариант 1: Через форк (рекомендуется)

1. **Создайте форк** этого репозитория через GitHub
2. **Включите GitHub Actions** в настройках форка (Settings → Actions → General → Allow all actions)
3. **Очистите существующие списки** и создайте свои:
   ```bash
   git clone https://github.com/YOUR_USERNAME/custom-dat-file
   cd custom-dat-file
   rm lists/*
   echo "example.com" > lists/my-custom-list
   ```
4. **Закоммитьте изменения**:
   ```bash
   git add .
   git commit -m "Initial custom lists"
   git push
   ```
5. **Готово!** Ваш DAT файл будет доступен по ссылке:
   ```
   https://github.com/YOUR_USERNAME/custom-dat-file/releases/latest/download/custom.dat
   ```

### Вариант 2: С нуля

1. **Скачайте шаблон**:

   ```bash
   git clone https://github.com/xxphantom/custom-dat-file my-dat-builder
   cd my-dat-builder
   rm -rf .git
   git init
   ```

2. **Создайте новый репозиторий на GitHub**

3. **Настройте свои списки**:

   ```bash
   rm lists/*
   echo "# My blocked domains" > lists/blocked
   echo "ads.example.com" >> lists/blocked
   ```

4. **Запушьте в свой репозиторий**:
   ```bash
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO
   git push -u origin main
   ```

### Настройка списков

- Каждый файл в `lists/` = отдельная категория geosite
- Имя файла = имя категории (например, файл `blocked` → `geosite:blocked`)
- Поддерживаются все форматы domain-list-community (см. выше)

### Примеры использования

```bash
# Скачать ваш кастомный DAT
wget -O /usr/local/share/xray/my-custom.dat \
  https://github.com/YOUR_USERNAME/YOUR_REPO/releases/latest/download/custom.dat

# Использовать в Xray конфиге
"domain": ["geosite:blocked", "geosite:my-custom-list"]
```

## Лицензия

Этот проект распространяется под лицензией MIT.

Инструмент сборки использует [domain-list-community](https://github.com/v2fly/domain-list-community) от V2Fly.
