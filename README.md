# Template for QuestaSim project

## Назначение

Учебно-демонстрационный проект для автоматизации компиляции и симуляции SystemVerilog-тестбенча в QuestaSim 2024.1.  
Проект содержит:

- генератор тактового сигнала и сброса `freq_gen`;
- тестовый модуль сообщений `tb_msg`;
- верхний тестбенч `tb_top`;
- TCL-скрипты для создания проекта, запуска симуляции и отображения волн;
- Windows CMD-скрипт для быстрого запуска.

Основная цель — показать минимальный, но структурированный flow: создание `.mpf`-проекта, добавление файлов из `files.f`, компиляция, запуск `vsim` и просмотр временных диаграмм.

---

## Требования

- **QuestaSim 2024.1** (путь по умолчанию: `C:/questasim64_2024.1`).
- **Windows** для `run_simulation.cmd`.
- **VS Code** (опционально) — для внешнего редактора.  
  В `alt_editor.tcl` ожидается путь `../vscode/code.exe` относительно рабочей директории симуляции.
- Поддержка SystemVerilog.

---

## Структура проекта

```text
.
├── run_simulation.cmd
├── include
│   └── common_pkg.sv
├── scripts
│   ├── alt_editor.tcl
│   ├── create_project.tcl
│   ├── files.f
│   ├── sim.tcl
│   ├── start.tcl
│   └── wave.tcl
└── tb
    ├── freq_gen.sv
    ├── tb_msg.sv
    └── tb_top.sv
```

---

## Быстрый старт

1. Убедись, что QuestaSim установлена в `C:/questasim64_2024.1`.
2. Открой терминал в корне проекта.
3. Запусти:

```cmd
run_simulation.cmd
```

Скрипт:

- удаляет и заново создаёт директорию `simulation`;
- переходит в неё;
- запускает `questasim.exe` с TCL-скриптом `../scripts/start.tcl`.

После запуска в QuestaSim будут созданы кнопки `REP` и `SIM`:

- `REP` — пересоздать проект;
- `SIM` — скомпилировать и запустить симуляцию.

---

## Скрипты автоматизации

### `run_simulation.cmd`

Windows-обёртка для запуска QuestaSim.

```cmd
set DIR_Q_SIM=C:/questasim64_2024.1
set SIM_DIR=simulation
...
"%DIR_Q_SIM%/win64/questasim.exe" -do ../scripts/start.tcl
```

Особенности:

- путь к QuestaSim жёстко зашит;
- рабочая директория симуляции — `simulation`;
- перед запуском очищается старая `simulation`.

---

### `start.tcl`

Главный стартовый скрипт.

Что делает:

1. Подключает `alt_editor.tcl`.
2. Подключает `create_project.tcl`.
3. Устанавливает переменные:
   - `view_wave = on`;
   - `clean_main = on`;
   - `top_module = tb_top`;
   - `PROJ_NAME = "project"`.
4. Добавляет кнопки `REP` и `SIM`.
5. Вызывает `create_project $PROJ_NAME`.

---

### `create_project.tcl`

Создаёт проект QuestaSim `.mpf` на основе списка файлов `scripts/files.f`.

Ключевые процедуры:

- `clean_dir` — удаляет всё в текущей директории, кроме `transcript`;
- `read_filtered_filelist` — читает `files.f`, убирает комментарии `#`, фильтрует по расширениям `.v`, `.sv`, `.vhd`;
- `print_filelist` — печатает список файлов;
- `add_files_to_prj` — добавляет файлы в проект;
- `create_project` — создаёт проект, читает `../scripts/files.f`, добавляет файлы.

> **Важно:** в текущей версии есть ошибка — `set PROJ_NAME prj_name` вместо `set PROJ_NAME $prj_name`.  
> Из-за этого проект всегда создаётся с именем `prj_name`, а не `project`.

---

### `sim.tcl`

Скрипт запуска симуляции.

Основные шаги:

- при `clean_main == "on"` очищает `.main`;
- выполняет `quit -sim`;
- компилирует устаревшие модули: `project compileoutofdate`;
- запускает `vsim` для `$top_module`;
- при `view_wave == "on"` открывает `wave`, `structure`, `signals` и выполняет `wave.tcl`;
- выполняет `run -all`;
- при `view_wave == "on"` делает `wave zoom full`.

---

### `wave.tcl`

Добавляет волны:

```tcl
add wave -divide "TOP"
add wave /$top_module/*
```

То есть добавляются все сигналы верхнего модуля `tb_top`.

---

### `alt_editor.tcl`

Настраивает внешний редактор для QuestaSim.

```tcl
proc external_editor {filename linenumber} {
    exec {*}[auto_execok start] ../vscode/code.exe --goto $filename:$linenumber
}
set PrefSource(altEditor) external_editor
```

Требует наличия `../vscode/code.exe` относительно рабочей директории.

---

## RTL и тестбенч

### `include/common_pkg.sv`

Пакет общих констант:

- `HIGH = 1'b1`
- `LOW = 1'b0`
- `TRIZ = 1'bz`
- `ON = 1'b1`
- `OFF = 1'b0`
- `pref_format = "[%12t]:"`
- `msg_format` — форматная строка для сообщений.

`msg_format` формируется через `$sformatf`.  
В SystemVerilog `$sformatf` не является константной функцией, поэтому в некоторых симуляторах такой `localparam` может вызвать ошибку компиляции. В QuestaSim может работать, но это не переносимо.

---

### `tb/freq_gen.sv`

Генератор тактового сигнала, сброса и сигнала `locked`.

Параметры:

| Параметр | Значение по умолчанию | Описание |
|---|---:|---|
| `RESET_ACTIVE` | `0` | Полярность сброса: `0` — активный низкий |
| `DUTY_CYCLE` | `0.6` | Коэффициент заполнения |
| `CLK_FREQ_HZ` | `100_000_000` | Частота тактирования, Гц |
| `LOCKED_DELAY_STROBS` | `100` | Задержка `locked` в тактах |
| `RESET_DELAY_STROBS` | `200` | Задержка снятия сброса в тактах |
| `LOCKED_DELAY_TIME` | вычисляется | Задержка `locked` в нс |
| `RESET_DELAY_TIME` | вычисляется | Задержка сброса в нс |

Выходы:

- `clk_o` — тактовый сигнал;
- `reset_o` — сброс;
- `locked_o` — признак готовности.

Внутри есть задачи:

- `delay(num_cycles)` — задержка на N тактов;
- `gen_reset(cnt_t)` — генерация сброса.

---

### `tb/tb_msg.sv`

Модуль логирования сообщений.

Поддерживает:

- `info`;
- `warning`;
- `debug`;
- `error`;
- `start`;
- `complite`;
- `timeout`;
- `report`.

Счётчики:

- `n_msg_cnt` — Info;
- `w_msg_cnt` — Warning;
- `d_msg_cnt` — Debug;
- `e_msg_cnt` — Error;
- `o_msg_cnt` — Others.

В конце `report` выводит сводку и определяет:

- `SIMULATION FAILED`, если `e_msg_cnt != 0`;
- `SIMULATION PASSED`, если ошибок нет.

> **Замечание:** `timeout` вызывает `warning`, а не `error`. Поэтому при таймауте симуляция всё равно может быть признана успешной.

---

### `tb/tb_top.sv`

Верхний тестбенч.

Параметры:

| Параметр | Значение по умолчанию | Описание |
|---|---:|---|
| `TIME_OUT_DELAY_STROBS` | `700` | Задержка таймаута в тактах (не используется напрямую) |
| `TIME_OUT_DELAY_NS` | `100_000` | Таймаут в нс |
| `TEST_DELAY` | `100_000 ns` | Период вывода времени симуляции |
| `SIMULATION` | `1` | Признак симуляции |

Локальные параметры:

- `CLK_FREQ_HZ = 100_000_000`
- `LOCKED_DELAY = 50`
- `RESET_DELAY = 70`

Экземпляры:

- `U_GCLK` — `freq_gen` с частотой 100 МГц;
- `MSG` — `tb_msg` с маркером `[T]`.

Есть задача `main()`:

```systemverilog
task main();
    MSG.start();
    wait(reset_n);
    U_GCLK.delay(300);
    U_GCLK.delay(300);
    MSG.complite();
endtask
```

> **Важно:** задача `main()` нигде не вызывается.  
> В текущем виде симуляция не выполняет основной сценарий, а только ждёт таймаут и вызывает `MSG.timeout()`.

---

## Поток симуляции

1. `run_simulation.cmd` создаёт `simulation/` и запускает QuestaSim.
2. `start.tcl` настраивает окружение и создаёт проект.
3. `create_project.tcl` читает `files.f`, создаёт `.mpf` и добавляет файлы.
4. Пользователь нажимает `SIM` или запускает `sim.tcl`.
5. `sim.tcl` компилирует проект, запускает `vsim`, добавляет волны и выполняет `run -all`.
6. По завершении выводится отчёт `tb_msg`.

---

## Известные замечания и TODO

1. **`tb_top.sv`:**  
   Задача `main()` не вызывается. Нужно добавить, например:

   ```systemverilog
   initial begin
       main();
   end
   ```

1. **`tb_msg.sv`:**  
   `timeout()` использует `warning`, поэтому таймаут не приводит к `SIMULATION FAILED`.  
   Лучше вызывать `error("Simulation timeout!")` или увеличивать `e_msg_cnt`.

1. **`common_pkg.sv`:**  
   `localparam msg_format = $sformatf(...)` может быть непереносимым.  
   Лучше сделать функцию или макрос.

1. **`run_simulation.cmd`:**  
   Жёстко задан путь `C:/questasim64_2024.1`.  
   При другой установке нужно поправить `DIR_Q_SIM`.

1. **`create_project.tcl` / `clean_dir`:**  
   Удаляет всё в текущей директории, кроме `transcript`.  
   Опасно запускать не из `simulation/`.

1. **`alt_editor.tcl`:**  
   Ожидает `../vscode/code.exe`.  
   Если VS Code установлен в другом месте, путь нужно изменить.

---
