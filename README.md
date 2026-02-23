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
