utf8 = require "utf8"
fetch = require "fetch"
json = require "json"

require "settings"
require "queue"
require "terminal"
require "cmnds"
require "line"

require "drivers.gemini"

function love.load()
	settings.setup()

	-- Setting up default font
	love.graphics.setFont(
		love.graphics.newFont("data/consolas.ttf", 24))
end

function love.textinput(txt)
	terminal.handle_text(txt)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	terminal.handle_key(key)
end

function love.update(dt)
	fetch.update()
	queue.resume()
	terminal.update(dt)
end

function love.draw()
	terminal.draw()
end

-- Global definitions
function g_time()
	return love.timer.getTime()
end

function g_width()
	return love.graphics.getWidth()
end

function g_height()
	return love.graphics.getHeight()
end

function g_split(inpt, sep)
	local t = {}
	for str in string.gmatch(inpt, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function g_t_shift(t)
	return table.remove(t, 1)
end

function g_t_pop(t)
	return table.remove(t)
end

function g_t_push(t, v)
	table.insert(t, v)
	return v
end