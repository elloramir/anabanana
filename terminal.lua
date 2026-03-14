
terminal = { }

terminal.lines = { }
terminal.input_content = ""
terminal.erase_timer = 0
terminal.erase_speed = 0
terminal.last_input_time = 0
terminal.cursor_alpha = 0
terminal.cursor_alpha_timer = 0

function terminal.add_line(content)
	return g_t_push(terminal.lines, line.new(content))
end

function terminal.update_input_time()
	terminal.last_input_time = g_time()
end

function terminal.handle_text(txt)
	local content = terminal.input_content
	-- Append text to the file content
	terminal.input_content = content .. txt
	terminal.update_input_time()
end

function terminal.handle_key(key)
	-- On press return we should send the command
	if key == "return" then
		-- Check if we had a command in
		if #terminal.input_content > 0 then
			local content = terminal.input_content
			local tokens = g_split(content, "%s")
			local head = g_t_shift(tokens)
			local cmnd = head and cmnds[head] or nil

			if cmnd then 
				local response = cmnd(tokens)
				if response then
					terminal.add_line(response)
				end
			else
				-- Treat as message to AI, not as command
				local line = terminal.add_line("thinking...")
				-- Schedule an answer
				gemini.ask(content, line)
			end

			-- Set it back to empty
			terminal.input_content = ""
		end
	end

	-- Handle paste event
	if key == 'v' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
		local clipboard = love.system.getClipboardText()
		if clipboard then
			terminal.handle_text(clipboard)
		end
	end
end

function terminal.erase_last()
	local content = terminal.input_content
	local byteoffset = utf8.offset(content, -1) or 0
	if byteoffset > 0 then
		terminal.input_content = content:sub(1, byteoffset - 1)
		terminal.update_input_time()
	end
end

function terminal.update(dt)
	-- Backspace should clean last character from input content
	-- We are trigging it on update because the last character erase
	-- should have an incremental speed.
	if love.keyboard.isDown("backspace") then
		terminal.erase_speed = terminal.erase_speed + dt*2
		terminal.erase_timer = terminal.erase_timer + terminal.erase_speed

		if terminal.erase_timer >= 1 then
			terminal.erase_last()
			terminal.erase_timer = 0
		end
	else
		terminal.erase_speed = 0
		terminal.erase_timer = 1
	end

	-- Update cursor opacity based on idle time
	do
		local is_idle = (g_time() - terminal.last_input_time) > 0.2
		if is_idle then
			terminal.cursor_alpha_timer = terminal.cursor_alpha_timer + dt
			terminal.cursor_alpha = (math.sin(terminal.cursor_alpha_timer*5)+1)/2
		else
			terminal.cursor_alpha_timer = 0
			terminal.cursor_alpha = 0
		end
	end

	-- Update lines cursor
	for _, line in ipairs(terminal.lines) do
		line:update(dt)
	end
end

function terminal.draw()
	local margin = 10
	local font = love.graphics.getFont()
	local font_height = font:getHeight()
	local content = terminal.input_content

	local gutter_height = math.floor(font_height * 2.0) - margin
	local gutter_width = g_width() - margin*2
	local gx = margin
	local gy = g_height() - gutter_height - margin

	-- Draw gutter where the input text will be in
	love.graphics.setColor(0.1, 0.1, 0.1)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle("line", gx, gy, gutter_width, gutter_height, 5)

	local ix = gx + 5
	local iy = gy + (gutter_height - font_height)/2 + 3

	-- Draw input text
	love.graphics.setColor(1, 1, 1)
	love.graphics.print((" > %s"):format(content), ix, iy)

	local input_width = font:getWidth(content)
	local prefix_width = font:getWidth(" > ")
	local cx = ix + prefix_width + input_width + 5
	local cy = iy

	-- Draw cursor on input text
	love.graphics.setColor(1, 1, 1, terminal.cursor_alpha)
	love.graphics.rectangle("fill", cx, cy, 5, font_height - 6)

	local total_lines = #terminal.lines
	local max_visible_lines = 15
	local max_line = math.max(1, #terminal.lines - max_visible_lines)
	for i=total_lines, max_line, -1 do
		local line = terminal.lines[i]
		local line_content = line:get_visual_content()
		local offset_y = font_height * (total_lines - i)

		-- Topic position
		local tx = gx + 20
		local ty = gy - margin - font_height/2 - offset_y

		-- Line position
		local lx = tx + 25
		local ly = ty - font_height/2

		-- Draw lines history
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.circle("fill", tx, ty, 5)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(line_content, lx, ly)
	end
end
