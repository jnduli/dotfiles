local md_todo = require("markdown_todo.init")
local utils = require("markdown_todo.utils")

describe("move_up_checklist_item", function()
  local buf

  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
  end)

  after_each(function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  local function set_buffer_lines(lines)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local function get_buffer_lines()
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end

  it("moves done task to top of section", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [ ] task 2",
      "- [X] task 3",
      "- [ ] task 4",
    })

    md_todo.move_up_checklist_item(3)

    local result = get_buffer_lines()
    assert.equals("# Plan", result[1])
    assert.equals("- [X] task 3", result[2])
    assert.equals("- [ ] task 1", result[3])
    assert.equals("- [ ] task 2", result[4])
    assert.equals("- [ ] task 4", result[5])
  end)

  it("does not move if already at top", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [X] task 1",
      "- [ ] task 2",
      "- [ ] task 3",
    })

    md_todo.move_up_checklist_item(1)

    local result = get_buffer_lines()
    assert.equals("- [X] task 1", result[2])
  end)

  it("moves done task to top even when incomplete tasks exist above", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [X] task 2",
      "- [X] task 3",
    })

    md_todo.move_up_checklist_item(2)

    local result = get_buffer_lines()
    assert.equals("# Plan", result[1])
    assert.equals("- [X] task 2", result[2])
    assert.equals("- [ ] task 1", result[3])
    assert.equals("- [X] task 3", result[4])
  end)
end)

describe("move_down_checklist_item", function()
  local buf

  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
  end)

  after_each(function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  local function set_buffer_lines(lines)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  local function get_buffer_lines()
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end

  it("moves done task to end of section", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [X] task 1",
      "- [ ] task 2",
      "- [ ] task 3",
    })

    md_todo.move_down_checklist_item(1)

    local result = get_buffer_lines()
    assert.equals("- [ ] task 2", result[2])
    assert.equals("- [ ] task 3", result[3])
    assert.equals("- [X] task 1", result[4])
  end)

  it("does not move if already at bottom", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [ ] task 2",
      "- [X] task 3",
    })

    md_todo.move_down_checklist_item(3)

    local result = get_buffer_lines()
    assert.equals("- [X] task 3", result[4])
  end)

  it("moves done task to end of section", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [ ] task 2",
      "- [X] task 3",
      "- [ ] task 4",
    })

    md_todo.move_down_checklist_item(3)

    local result = get_buffer_lines()
    assert.equals("- [ ] task 1", result[2])
    assert.equals("- [ ] task 2", result[3])
    assert.equals("- [ ] task 4", result[4])
    assert.equals("- [X] task 3", result[5])
  end)
end)

describe("get_section_boundaries", function()
  local buf

  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
  end)

  after_each(function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  local function set_buffer_lines(lines)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  it("finds section boundaries in middle of checklist", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [ ] task 2",
      "- [ ] task 3",
    })

    local start, end_line = md_todo.get_section_boundaries(2)

    assert.equals(1, start)
    assert.equals(3, end_line)
  end)

  it("finds boundaries at start of checklist", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [ ] task 2",
    })

    local start, end_line = md_todo.get_section_boundaries(1)

    assert.equals(1, start)
    assert.equals(2, end_line)
  end)

  it("finds boundaries at end of checklist", function()
    vim.api.nvim_set_current_buf(buf)
    set_buffer_lines({
      "# Plan",
      "- [ ] task 1",
      "- [ ] task 2",
    })

    local start, end_line = md_todo.get_section_boundaries(2)

    assert.equals(1, start)
    assert.equals(2, end_line)
  end)
end)
