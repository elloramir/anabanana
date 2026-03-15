line = { }
line.__index = line

function line.new(content)
	local self = { }

	self.content = content
	self.cursor = 1
	self.height = 0
	self.wrapped_text = {}
	self.status = "pending" -- "pending", "processing", "completed"

	return setmetatable(self, line)
end

function line:update_layout(font, limit)
	local content = self:get_visual_content()
	local width, wrapped = font:getWrap(content, limit)
	self.wrapped_text = wrapped
	self.height = #wrapped * font:getHeight()
end

function line:update(dt)
	self.cursor = math.min(#self.content, self.cursor+dt*80)
end

function line:set_content(str)
	self.content = str
	self.cursor = 1
end

function line:set_status(status)
	local valid = "pending,processing,completed,success"
	assert(valid:find(status), "Invalid status: " .. tostring(status))
	self.status = status
end

function line:get_visual_content()
	local content = self.content
	local cursor = self.cursor
	local end_pos = utf8.offset(content, cursor + 1) or #content + 1

	return content:sub(1, end_pos - 1)
end
