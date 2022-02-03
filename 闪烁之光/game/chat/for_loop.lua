-- 提供一个for循环，使用定时器执行循环体
-- 支持循环间隔时间、暂停循环、启动循环接口
-- author:hp

ForLoop = ForLoop or BaseClass()

function ForLoop:__init(params, body_func)
	params = params or {}
	self._speed = params.speed or 10/60
	self._way = params.way or 1
	self._body_func = body_func
end

-- 开启
function ForLoop:start(begin_id, end_id)
	self._start_id = begin_id
	self._end_id = end_id
	self:launch()
end

-- 结束
function ForLoop:stop()
	self:pause()
end

-- 循环体
function ForLoop:setLoopBody(func)
	self._body_func = func
end

-- 启动定时器
function ForLoop:launch()
	if not self._running then
		self._running = true
	    self._ticket_name = GlobalTimeTicket:getInstance():add(function()
	    	self:push()
	    end, self._speed)
	end
end

-- 关闭定时器
function ForLoop:pause()
	if self._running then
		self._running = nil
		if self._ticket_name then
			GlobalTimeTicket:getInstance():remove(self._ticket_name)
			self._ticket_name = nil
		end
	end
end

function ForLoop:setWay(value)
	self._way=value
end

-- 处理数据
function ForLoop:push()
	if not self._start_id or not self._end_id then return end
	if self._way == 1 then
		-- 递增
		if self._start_id <= self._end_id then
			self._body_func(self._start_id)
			self._start_id = self._start_id + 1
		else
			self:pause()
		end
	else
		-- 递减
		if self._start_id >= 0 then
			self._body_func(self._start_id)
			self._start_id = self._start_id - 1
		else
			self:pause()
		end
	end
end

-- 运行状态
function ForLoop:isRunning()
	return self._running
end

-- 销毁数据
function ForLoop:__delete()
	self:stop()
end