cmnds = {}

cmnds["clear"] = function(arguments)
	terminal.lines = { }
	return "terminal has been cleared!"
end

cmnds["set"] = function(arguments)
	if type(arguments) ~= "table" then
		return "invalid arguments for set"
	end

	if #arguments ~= 2 then
		return "try: `set {key} {value}`"
	end

	local key = g_t_shift(arguments)
	local has_key = settings.get(key) ~= nil

	if has_key then
		local value = g_t_shift(arguments)
		settings.set(key, value)
		return ("okay, now '%s' is equal to '%s'"):format(key, value)
	else
		return ("uknown key: '%s'"):format(key)
	end
end

cmnds["get"] = function(arguments)
	local key = g_t_shift(arguments)
	local value = settings.get(key)

	if value then
		return ("value of '%s' is equal to '%s'"):format(key, value)
	else
		return ("uknown key: '%s'"):format(key)
	end
end