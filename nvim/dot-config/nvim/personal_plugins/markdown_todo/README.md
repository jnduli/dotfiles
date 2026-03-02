# markdown_todo

A Neovim plugin for managing markdown checklists with time tracking and task reordering.

## Setup

```lua
require("markdown_todo").setup({
  -- Work hours for pace score calculation
  start_time = { hour = 5, min = 0 },
  end_time = { hour = 21, min = 0 },

  -- Where to move done tasks: "top", "bottom", or "none"
  done_task_position = "top",

  -- Minutes to add between overdue tasks when shifting times
  readjust_interval_minutes = 30,
})
```

## Key Mappings

| Mapping | Description |
|---------|-------------|
| `<C-x>` | Cycle todo item state (open ↔ done) |
| `<C-u>` | Move item up in the list |

## Commands

| Command | Description |
|---------|-------------|
| `:MarkdownTodoOrder` | Reorder tasks by time |
| `:MarkdownTodoShiftTimes` | Readjust overdue task times to now + interval |
| `:MarkdownTodoMissingHours [n]` | Set missing work hours for pace calculation |

## Features

- **Task Cycling**: Toggle tasks between `- [ ]` and `- [X]` with `<C-x>`
- **Auto-reorder**: Done tasks move to top/bottom based on config
- **Time Highlighting**: Overdue tasks are highlighted in red
- **Pace Score**: Shows expected vs actual completion in virtual text
- **Time Readjustment**: Shift all overdue tasks to current time with spacing
