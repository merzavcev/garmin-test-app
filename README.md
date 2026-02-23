# Garmin Test App

## Требования

- Connect IQ SDK 8.4.1+ (путь вида `~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.4.1-YYYY-MM-DD-<hash>`).
- Файл ключа разработчика (`*.der`) для подписи `.prg`.
- Наличие в проекте входных артефактов:
  - `manifest.xml`
  - `monkey.jungle`
  - папки `source/`, `resources/` (включая `resources/drawables/launcher_icon.png`)

## Переменные окружения

Перед сборкой экспортируйте переменные:

```bash
export CIQ_SDK_HOME="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.4.1-2026-02-03-e9f77eeaa"
export CIQ_DEVELOPER_KEY="$HOME/.garmin/developer_key.der"
# Необязательно: можно переопределять target для build.sh
export CIQ_TARGET="vivoactive6"
```

- `CIQ_SDK_HOME` нужен всегда.
- `CIQ_DEVELOPER_KEY` обязателен — начиная с SDK 8.4.1 компилятор не умеет выпускать unsigned сборки.
- `JAVA_HOME=/opt/homebrew/opt/openjdk` (или иной JDK 17+) требуется, если в системе несколько JVM.

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

> Флаг `--unsigned` оставлен в скрипте для совместимости, но SDK 8.4.1 всё равно потребует ключ.

## Запуск в симуляторе

1. Откройте `ConnectIQ.app` (`$CIQ_SDK_HOME/bin/ConnectIQ.app`) и через Device Manager добавьте устройство vívoactive 6 (раздел **Window → Device Manager → Add Device**).
2. Убедитесь, что включён пункт **Settings → Allow Remote Connections**.
3. Из корня проекта выполните:

   ```bash
   "$CIQ_SDK_HOME/bin/monkeydo" build/HelloGarmin.prg vivoactive6
   ```

   После этого приложение моментально появится в окне выбранного устройства.

## Установка на часы

### Garmin Express (Developer Apps)

1. Подключите vívoactive 6 к Mac и дождитесь, пока Garmin Express отобразит устройство.
2. В разделе **Connect IQ | Приложения** нажмите иконку меню (три полоски) → **Приложения разработчика…**.
3. Нажмите **Добавить**, укажите `build/HelloGarmin.prg`, затем **Установить**. Express скопирует файл в `GARMIN/APPS` и безопасно отключит часы.

### Android File Transfer (прямой MTP-доступ)

1. Установите [Android File Transfer](https://www.android.com/filetransfer/), запустите приложение.
2. На часах в `Settings → System → USB Mode` выберите `MTP`.
3. Подключите кабель: в окне приложения откроется содержимое часов. Перейдите в `GARMIN/APPS/` и перетащите `build/HelloGarmin.prg`.
4. Закройте AFT и отключите кабель — новая сборка появится в списке приложений.

## Проверка запуска приложения

1. Отключите часы от компьютера безопасно.
2. На часах откройте список приложений/виджетов.
3. Найдите установленное приложение и запустите его.
4. Убедитесь, что приложение открывается без ошибок и отображает `Hello Garmin`.
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
