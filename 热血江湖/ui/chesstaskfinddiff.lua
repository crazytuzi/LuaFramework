-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_chessTaskFindDiff = i3k_class("wnd_chessTaskFindDiff", ui.wnd_base)

local CFG = i3k_db_find_difference
local TotalTime = 30
local PunshTime = 5

function wnd_chessTaskFindDiff:ctor()
	self._rightPositions = {}
	self._positionState = {}
	
	self._haveFound = 0
	
	self._timeFlag = false
	self._wrongFlag = false
	
	self._timeTick = 0
	self._wrongTick = 0
	self._otherId = 0
end

function wnd_chessTaskFindDiff:configure()
	
end

function wnd_chessTaskFindDiff:refresh(index, cfg, otherId)
	--local index = 1
	self._index = index
	self._otherId = otherId or 0
	TotalTime = cfg.arg2
	self:setInterFaceInfo(index)
	self:getRightPositions(index)
	self:resetPositionState(index)
	
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onClose)
	widgets.pic_btn1:onClick(self, self.findDiff, 1)
	widgets.pic_btn2:onClick(self, self.findDiff, 2)
	
	self._timeFlag = true
	self._timeTick = 0
	self._wrongFlag = false
	self._wrongTick = 0
end

function wnd_chessTaskFindDiff:onUpdate(dTime)
	local timeLable = self._layout.vars.left_time
	--local timeBar = self._layout.vars.time_bar
	
	if self._timeFlag then
		self._timeTick = self._timeTick + dTime
	end
	local time = math.floor(TotalTime-self._timeTick)
	time = time>0 and time or 0
	timeLable:setText("剩余时间：" .. math.floor(time))
	--timeBar:setPercent(time * 100 / TotalTime)
	
	if time == 0 then
		self._timeTick = 0
		self._timeFlag = false
		
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			--[[if g_i3k_ui_mgr:GetUI(eUIID_MessageBox1) then
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox1)
			end --]]
			local callback = function()
				g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskFindDiff)
			end
			g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskDiffAnimate)
			g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskDiffAnimate, 0, callback)
			--g_i3k_ui_mgr:ShowMessageBox1("任务失败，请退出重试", callback)
			end, 1)
	end
	
	if self._wrongFlag then
		self._wrongTick = self._wrongTick + dTime
		if(self._wrongTick > 0.7) then
			self._layout.vars.wrong:hide()
			self._wrongTick = 0
			self._wrongFlag = false
		end
	end
end

function wnd_chessTaskFindDiff:findDiff(sender, part)
	local flag = false
	local parent = self._layout.vars["pic_btn"..part]:getParent()
	local location = g_i3k_ui_mgr:GetMousePos()
	local pos = parent:convertToNodeSpace(cc.p(location.x,location.y))
	for i,v in ipairs(self._rightPositions) do
		local distance = cc.pGetDistance(pos, v.pos)
		if distance <= v.radius then
			flag = true
			if(not self._positionState[i]) then
				self:showRight(v.pos, i)
				self._positionState[i] = true
				
			end
			break
		end
	end
	
	if not flag then
		local parent = self._layout.vars.wrong:getParent()
		local pos = parent:convertToNodeSpace(cc.p(location.x,location.y))
		self:showWrong(pos)
	end
end

function wnd_chessTaskFindDiff:getRightPositions(index)
	local size = self._layout.vars.pic_btn1:getSize()
	for i = 1, CFG[index].findCount do
		local _x = (CFG[index].position[i].pos.x / 100) * size.width
		local _y = (CFG[index].position[i].pos.y / 100) * size.height
		local _radius = (CFG[index].position[i].radius / 100) * size.width
		table.insert(self._rightPositions, {pos = {x = _x, y = _y}, radius = _radius})
	end
end

function wnd_chessTaskFindDiff:resetPositionState(index)
	for i = 1, CFG[index].findCount do
		self._positionState[i] = false
	end
end

function wnd_chessTaskFindDiff:setInterFaceInfo(index)
	local widgets = self._layout.vars
	widgets.pic1:setImage(g_i3k_db.i3k_db_get_icon_path(CFG[index].iconId[1]))
	widgets.pic2:setImage(g_i3k_db.i3k_db_get_icon_path(CFG[index].iconId[2]))
	widgets.find_num:setText("已找到：" .. self._haveFound .."/"..CFG[index].findCount)
end

function wnd_chessTaskFindDiff:showRight(pos, i)
	local widgets = self._layout.vars
	widgets["right1_"..i]:setPosition(pos)
	widgets["right1_"..i]:show()
	widgets["right2_"..i]:setPosition(pos)
	widgets["right2_"..i]:show()
	self._haveFound = self._haveFound + 1
	widgets.find_num:setText("已找到：" .. self._haveFound .."/"..CFG[self._index].findCount)
	if(self._haveFound == CFG[self._index].findCount) then
		self._timeFlag = false
		--g_i3k_ui_mgr:PopupTipMessage("成功")
		if g_i3k_db.i3k_db_check_festival_task_by_hash_id(self._otherId) then
			g_i3k_game_context:tellSeverFestivalFinish(g_TASK_FIND_DIFFERENCE, self._index, 0, 1)
		else
			g_i3k_game_context:tellSeverChessTaskFinished(0, g_TASK_FIND_DIFFERENCE, self._index)
		end
		local callback = function()
			g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskFindDiff)
		end
		g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskDiffAnimate)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskDiffAnimate, 1, callback)
		
	end
end

function wnd_chessTaskFindDiff:showWrong(pos)
	
	local widgets = self._layout.vars
	widgets.wrong:setPosition(pos)
	widgets.wrong:show()
	
	self._timeTick = self._timeTick + PunshTime
	self._wrongFlag = true
end

function wnd_chessTaskFindDiff:onClose(sender)
	local callback = function(ok)
			if ok then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChessTaskFindDiff, "onCloseUI")
			end 
		end
	g_i3k_ui_mgr:ShowMessageBox2("确认离开？", callback)
end

function wnd_create(layout)
	local wnd = wnd_chessTaskFindDiff.new()
	wnd:create(layout)
	return wnd
end
