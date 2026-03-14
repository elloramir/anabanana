settings = { }

local kvd = {}
kvd.driver = "gemini"
kvd.api_key = "12345"

function settings.setup()
	love.filesystem.setIdentity("anabanana")

	-- Read actual data from settings file
	local content = love.filesystem.read("settings", size)
	if content then
		local lines = g_split(content, "\n")
		for _, line in ipairs(lines) do
			local key, value = unpack(g_split(line, "="))
			settings.set(key, value)
		end
	end
end

function settings.save()
	love.filesystem.write("settings", settings.dump())
end

function settings.get(key)
	return kvd[key]
end

function settings.set(key, value)
	kvd[key] = value
	settings.save()
end

function settings.dump()
	local res = ""
	for k, v in pairs(kvd) do
		res = res .. k .. "=" .. v .. "\n"
	end
	return res
end

