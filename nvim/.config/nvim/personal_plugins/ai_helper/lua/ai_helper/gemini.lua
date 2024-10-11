local logger = require("ai_helper.log").logger

local M = {}

M.prompts = {
    senior_eng =
    "I want you to take the role of a senior software engineer, then rewrite this content in a short and clear way:",
    marketer =
    "I want you to take the role of a senior marketing exective, then rewrite this content to target a large audience:",
    title_gen =
    "I want you to generate better titles. I'll give you the topic and key words of an article, and you will generate ten attention-grabbing titles:",
}

M.api_call = function(content, pre_prompt)
    local prompt = pre_prompt .. "\n" .. content
    logger.debug("AI prompt: ", prompt)

    local parts_json = { parts = { { text = prompt } } }
    local query_json = { contents = { parts_json } }
    local query_string = vim.json.encode(query_json)
    local google_api_key = os.getenv("GOOGLE_API_KEY")
    if google_api_key == nil then
        error("GOOGLE_API_KEY env variable not set")
    end
    local curl_command = {
        "curl",
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. google_api_key,
        "-H", "Content-Type: application/json",
        "-X", "POST",
        "-d",
        query_string
    }
    local result = nil
    vim.system(curl_command, { text = true, timeout = 3000 }, function(obj)
        if obj.code == 124 then
            error("AI timeout exceeded")
            return
        end
        logger.debug("AI result", obj.stdout)
        result = obj.stdout
    end):wait()

    if result == nil then
        error("Failed to get result from gemini api")
        return
    end

    local decoded_result = vim.json.decode(result)
    return decoded_result["candidates"][1]["content"]["parts"][1]["text"]
end

return M
