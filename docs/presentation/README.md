# Инструкция по сборке презентации

Для работы презентации необходимо наличие фреймворка Touying в папке `docs/presentation/touying`.

Если вы клонируете репозиторий впервые:
```bash
git clone --recursive https://github.com/hpc-moment/dns-cacher.git
```

Если репозиторий уже склонирован без субмодулей:
```bash
git submodule update --init --recursive
```

## Установка Typst

Вы можете установить Typst через различные пакетные менеджеры:

- **Linux:**
  - Используйте пакетный менеджер вашего дистрибутива (например, `pacman -S typst` для Arch или `apt install typst` для Debian/Ubuntu, если доступно).
  - Через Snap: `snap install typst`
- **macOS:** `brew install typst`
- **Windows:** `winget install --id Typst.Typst`

### Альтернативные способы:

- **Rust/Cargo:** `cargo install --locked typst-cli`
- **Nix:** `nix-shell -p typst`
- **Docker:** `docker run -it --rm -v $(pwd):/app -w /app ghcr.io/typst/typst:latest compile presentation.typ`

## Сборка презентации

Для компиляции презентации в формат PDF выполните команду в директории `docs/presentation`:

```bash
typst compile presentation.typ
```

Если вы вносите изменения и хотите видеть их в реальном времени:

```bash
typst watch presentation.typ
```

> [!NOTE]
> Фреймворк Touying подключен как локальный модуль, поэтому дополнительных действий по его импорту через сеть не требуется.
