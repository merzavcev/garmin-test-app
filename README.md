# Garmin Test App

## Требования

- Установленный Connect IQ SDK.
- Файл ключа разработчика для подписи `.prg`.
- Наличие в проекте входных артефактов:
  - `manifest.xml`
  - папка `source/`
  - папка `resources/`

## Переменные окружения

Перед сборкой экспортируйте переменные:

```bash
export CIQ_SDK_HOME="/path/to/connectiq-sdk"
export CIQ_DEVELOPER_KEY="/path/to/developer_key.der"
# необязательно, target по умолчанию для скриптов
export CIQ_TARGET="vivoactive6"
```

- `CIQ_SDK_HOME` обязателен всегда.
- `CIQ_DEVELOPER_KEY` обязателен для подписанной сборки.

## Сборка `.prg`

Базовая сборка (по умолчанию target = `vivoactive6`, выход = `build/HelloGarmin.prg`):

```bash
./scripts/build.sh
```

Сборка с явным target (например, vívoactive 6):

```bash
./scripts/build.sh --target vivoactive6
```

Сборка с пользовательским выходным файлом:

```bash
./scripts/build.sh --target vivoactive6 --output build/MyApp.prg
```

Unsigned-сборка (например, для локальной проверки):

```bash
./scripts/build.sh --target vivoactive6 --unsigned
```

## Упаковка/подпись отдельным шагом

Скрипт упаковки создаёт артефакт в `dist/` из уже собранного `.prg`:

```bash
./scripts/package.sh --target vivoactive6
```

Если нужно сначала пересобрать, затем упаковать:

```bash
./scripts/package.sh --target vivoactive6 --rebuild
```

## Установка на часы

Доступный способ зависит от вашей среды и устройства:

1. **Garmin Express (USB):**
   - Подключите часы к компьютеру.
   - Откройте устройство как накопитель (или через Garmin Express).
   - Скопируйте `.prg` в папку приложений Connect IQ на устройстве.

2. **Connect IQ / Mobile (если поддерживается каналом разработки):**
   - Используйте стандартный процесс установки через Connect IQ экосистему для dev-сборок.

3. **Side-load (ручная установка):**
   - Подключите устройство по USB.
   - Скопируйте `build/HelloGarmin.prg` (или файл из `dist/`) в каталог приложений устройства (обычно внутри `GARMIN/APPS`).

> Точный путь может отличаться у разных моделей/прошивок. Ориентируйтесь на структуру каталогов вашего устройства.

## Проверка запуска приложения

1. Отключите часы от компьютера безопасно.
2. На часах откройте список приложений/виджетов.
3. Найдите установленное приложение и запустите его.
4. Убедитесь, что приложение открывается без ошибки и отображает ожидаемый экран.
# Garmin Monkey C Hello App

Минимальный пример Connect IQ `watch-app` для vívoactive 6, который выводит `Hello Garmin` на экран.

## Структура проекта

- `manifest.xml` — описание приложения и целевых устройств.
- `source/App.mc` — класс приложения (`Application.AppBase`).
- `source/View.mc` — базовый `View` с отрисовкой текста.
- `resources/strings/strings.xml` — строковые ресурсы.

## Установка Connect IQ SDK

1. Скачайте **Connect IQ SDK Manager** с официального сайта Garmin Connect IQ Developer Program.
2. Установите SDK через SDK Manager (рекомендуется последняя доступная версия).
3. Убедитесь, что утилита `monkeyc` доступна из командной строки:

```bash
monkeyc -v
```

> Альтернатива: использовать полный путь до `monkeyc` из каталога SDK.

## Сборка приложения

Из корня проекта выполните:

```bash
monkeyc \
  -f manifest.xml \
  -o bin/HelloGarmin.prg \
  -d vivoactive6
```

Где:
- `-f` — манифест приложения.
- `-o` — путь до собранного `.prg`.
- `-d` — целевое устройство.

## Запуск в симуляторе

1. Откройте Connect IQ Simulator.
2. Выберите устройство `vívoactive 6` (или совместимое).
3. Загрузите собранный `bin/HelloGarmin.prg`.
4. После запуска на экране отобразится `Hello Garmin`.
