local md_todo_utils = require("markdown_todo.utils")

describe("custom markdown tests", function()
  it("convert_time_to_sortable_format", function()
    local test_cases = {
      { "Finish this task by 8.00 am", { hour = 8, minute = 0 } },
      { "Meeting at 14.30 pm today", { hour = 14, minute = 30 } }, -- This should stay 14:30
      { "Call him at 6.15 pm", { hour = 18, minute = 15 } },
      { "Midnight snack at 12.00 am", { hour = 0, minute = 0 } },
      { "Lunch at 12.00 pm", { hour = 12, minute = 0 } },
      { "Early morning at 5.00", { hour = 5, minute = 0 } }, -- No AM/PM, assumes 24-hour format
      { "Appointment at 10.45 am", { hour = 10, minute = 45 } },
      { "Evening plan 9.30 pm", { hour = 21, minute = 30 } },
      { "Late night coding 1.00 am", { hour = 1, minute = 0 } },
      { "Just some text without time", { hour = 24, minute = 0 } },
      { "Another line at 23.59", { hour = 23, minute = 59 } },
      { "12.00 am party", { hour = 0, minute = 0 } },
      { "12.00 pm lunch", { hour = 12, minute = 0 } },
      { "lua fix error in personal programming improvement parsing by 12.00", { hour = 12, minute = 0 } },
    }

    for _, test_case in ipairs(test_cases) do
      local input_text = test_case[1]
      local expected_output = test_case[2]
      local actual_output = md_todo_utils.Checklist.get_time(input_text)
      assert.equals(actual_output.hour, expected_output.hour)
      assert.equals(actual_output.minute, expected_output.minute)
    end
  end)
end)
