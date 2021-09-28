-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_server_line_up = i3k_class("wnd_server_line_up", ui.wnd_base)

local TIME_SPACE = 10 -- 查询时间 10十秒

function wnd_server_line_up:ctor()
	self._isFirst = true
	self._recordTime = 0 --记录时间
end

function wnd_server_line_up:configure()
	local widgets = self._layout.vars	
	--widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.cancel:onClick(self, self.onCancelLineUp)
	
	self.serverDesc = widgets.serverDesc
	self.posDesc = widgets.posDesc
	self.timeDesc = widgets.timeDesc
end

function wnd_server_line_up:refresh(pos)
	local loginQueueData = g_i3k_game_context:GetLoginQueueData()
	self._recordTime = i3k_game_get_time()
	self.serverDesc:setText(string.format("服务器%s人数已满", loginQueueData.serverName))
	self.posDesc:setText(string.format("正在排队等待进入，伫列位置：%s", pos))
	self.timeDesc:setText(string.format("预计时间：%s", self:getBudgetTime(loginQueueData.pos, pos)))
	self._isFirst = false 
end

function wnd_server_line_up:getBudgetTime(lastPos, nowPos)
	if self._isFirst then
		return string.format("正在估算...")
	else
		local speed =  (10 / (lastPos - nowPos)) -- 秒/人
		local needTime = speed * nowPos -- 秒
		local minute = math.ceil(needTime / 60)
		if minute > 60 then -- 大于一小时
			return string.format("正在估算...")
		else
			return string.format("%s分钟", minute)
		end
	end
end

function wnd_server_line_up:onUpdate(dTime)
	if i3k_game_get_time() - self._recordTime >  TIME_SPACE then
		i3k_sbean.query_loginqueue()
	end
end

function wnd_server_line_up:onCancelLineUp(sender)
	local data = i3k_sbean.cancel_loginqueue.new()
	i3k_game_send_str_cmd(data)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_server_line_up.new()
	wnd:create(layout)
	return wnd
end
