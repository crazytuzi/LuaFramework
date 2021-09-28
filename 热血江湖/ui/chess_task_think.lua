-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_think = i3k_class("wnd_chess_task_think", ui.wnd_base)

function wnd_chess_task_think:ctor()
	self.info = {}
	self.loopLvl = 1
	self._disableTime = 0
	self._thinkEnable = true
end

function wnd_chess_task_think:configure()
	local widgets = self._layout.vars
	self.range = widgets.range
	self.jiantouview = widgets.jiantouview
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_chess_task_think:refresh()
	self:setSchedule()
	self:setData()
end

function wnd_chess_task_think:setSchedule()
	local widgets = self._layout.vars
	local cfg = i3k_db_chuanjiabao.cfg.barstyles[1]
	self.info.counts = {1, 2, 3, 2, 1}
	self.info.poss = {35, 47, 53, 65, 100}
end

function wnd_chess_task_think:setData()
	local chessTask = g_i3k_game_context:getChessTask()
	self.loopLvl = chessTask.loopLvl
	self._layout.vars.desc:setText(i3k_get_string(17272))
	self._layout.vars.need_chess:setText(string.format("%s/%s", i3k_db_chess_task_info[chessTask.loopLvl].needChess, chessTask.chessValue))
	self._layout.vars.success_rate:setText(string.format("%s%%", i3k_db_chess_task_info[chessTask.loopLvl].showSuccessRate/100))
	self._layout.vars.left_time:setText(string.format("再尝试%s次必定成功", i3k_db_chess_task_info[chessTask.loopLvl].certainlySuccess - chessTask.curUpCnt))
	if i3k_db_chess_task_info[chessTask.loopLvl].needChess > chessTask.chessValue then
		self._layout.vars.think_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(6499))
		self._layout.vars.think_btn:onClick(self, self.onEndBtn)
	else
		self._layout.vars.think_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(6498))
		self._layout.vars.think_btn:onClick(self, self.onThinkBtn)
	end
end

function wnd_chess_task_think:onEndBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskEnd)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskEnd, 0)
	g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskThink)
end

function wnd_chess_task_think:onThinkBtn(sender)
	if not self._moveFlag then
		self._moveFlag = true
	else
		self:triggerStopArrow()
	end
end

function wnd_chess_task_think:onShow()
	self:setArrowToLeft()
	self._moveFlag = false
	--self._triggerTimes = 1 -- 打开一次ui，设置点击按钮可以重复选择箭头滚动的次数
end

function wnd_chess_task_think:onUpdate(dTime)
	self:moveArrow(dTime)
end

function wnd_chess_task_think:setArrowToLeft()
	self.jiantouview:setPositionX(self.range:getPositionX())
end

function wnd_chess_task_think:checkArrowToRight()
	return self.jiantouview:getPositionX() > self.range:getPositionX() + self.range:getSize().width
end


function wnd_chess_task_think:moveArrow(dTime)
	if self._moveFlag then
		self.jiantouview:setPositionX(self.jiantouview:getPositionX() + i3k_db_chess_task_info[self.loopLvl].schduelSpeed * dTime)
		if self:checkArrowToRight() then
			-- self:setArrowToLeft()
			self:triggerStopArrow()
		end
	end
	if self._thinkEnable then
		self._layout.vars.think_btn:enableWithChildren()
	else
		self._layout.vars.think_btn:disableWithChildren()
		self._disableTime = self._disableTime + dTime
		if self._disableTime >= 0.8 then
			local index = self:checkArrowResult()
			local chessTask = g_i3k_game_context:getChessTask()
			i3k_sbean.chess_game_uplooplvl(index, i3k_db_chess_task_info[chessTask.loopLvl].needChess)
			self._thinkEnable = true
			self._disableTime = 0
			self:setArrowToLeft()
		end
	end
end

-- 触发停止箭头移动
function wnd_chess_task_think:triggerStopArrow()
	self._moveFlag = false
	self._thinkEnable = false
end

-- 箭头停止的通知
function wnd_chess_task_think:checkArrowResult()
	local posx = self.jiantouview:getPositionX() - self.range:getPositionX()
	local width  = self.range:getSize().width
	local value = math.floor(posx / width * 100)
	if value < 0 then value = 0 end
	if value >  99 then	value = 99 end

	local curIndex = nil
	for i = 1 , #self.info.poss  do
		if self.info.poss[i - 1] then
			if value >= self.info.poss[i-1] and value < self.info.poss[i] then
				curIndex = self.info.counts[i]
				break
			end
		else
			if value >= 0 and value < self.info.poss[i] then
				curIndex = self.info.counts[i]
				break
			end
		end
	end
	return curIndex
end

function wnd_create(layout)
	local wnd = wnd_chess_task_think.new()
	wnd:create(layout)
	return wnd
end
