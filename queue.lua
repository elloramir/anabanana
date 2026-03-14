queue = { }

local tasks = { }

function queue.add_task(func)
	return g_t_push(tasks, coroutine.create(func))
end

function queue.sleep(seconds)
	local start = g_time()
	while g_time() - start < seconds do
		coroutine.yield()
	end
end

function queue.resume()
	-- Resume coroutines
	for i = #tasks, 1, -1 do
		local co = tasks[i]
		local ok, res = coroutine.resume(co)

		if coroutine.status(co) == "dead" then
			table.remove(tasks, i)
		end
	end
end

