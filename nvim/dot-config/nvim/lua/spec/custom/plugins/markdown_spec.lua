local custom_md = require("custom.plugins.markdown")

describe("custom markdown tests", function()
  it("some test", function()
    assert.equals("hello", "hello")
  end)

  it("convert_time_to_sortable_format", function()
    local test_cases = {
      { "Finish this task by 8.00 am", "08:00" },
      { "Meeting at 14.30 pm today", "14:30" }, -- This should stay 14:30
      { "Call him at 6.15 pm", "18:15" },
      { "Midnight snack at 12.00 am", "00:00" },
      { "Lunch at 12.00 pm", "12:00" },
      { "Early morning at 5.00", "05:00" }, -- No AM/PM, assumes 24-hour format
      { "Appointment at 10.45 am", "10:45" },
      { "Evening plan 9.30 pm", "21:30" },
      { "Late night coding 1.00 am", "01:00" },
      { "Just some text without time", nil },
      { "Another line at 23.59", "23:59" },
      { "12.00 am party", "00:00" },
      { "12.00 pm lunch", "12:00" },
    }

    for _, test_case in ipairs(test_cases) do
      local input_text = test_case[1]
      local expected_output = test_case[2]
      local actual_output = convert_time_to_sortable_format(input_text)
      assert.equals(actual_output, expected_output)
    end
  end)
end)
