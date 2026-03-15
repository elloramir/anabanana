gemini = { }

local base = "https://generativelanguage.googleapis.com/v1beta/models"
local model = "gemini-2.5-flash:generateContent"

function gemini.ask(str_qst, line)
	local api_key = settings.get("api_key")
	local url = ("%s/%s?key=%s"):format(base, model, api_key)
	local opts = { }
	
	opts.headers = { ["Content-Type"] = "application/json" }
	opts.method = "POST"
	opts.data = ('{"contents":[{"parts":[{"text": "%s"}]}]}'):format(str_qst)

	fetch(url, opts, function(res)
		local data = json.decode(res.body)
		local txt_resp = data.candidates[1].content.parts[1].text

		line:set_content(txt_resp)
		line:set_status("completed")
		coroutine.yield()
	end)
end