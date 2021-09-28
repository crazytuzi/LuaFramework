-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_hit_diglett = i3k_class("wnd_hit_diglett", ui.wnd_base)

local COUNTDOWN = 4
function wnd_hit_diglett:ctor()
	self._id = 0
	self._count = {}
	self._countDown = 0 --倒计时
	self._time = 0 --每秒刷新
	self._last = 0 --游戏的时间
	self._startTime = 0 --游戏开始的时间戳
	self._isStart = false
	self._end = false
	self._isPlay = false
end

function wnd_hit_diglett:configure()
	self._layout.vars.exit:onClick(self, self.onExit)
end

function wnd_hit_diglett:refresh(id)
	local info = g_i3k_game_context:getHitDiglettInfo()
	self._id = id
	self:setDiglettCount()
	if info then
		self._last = i3k_db_findMooncake[id].limitTime
		self._startTime = info.startTime
		self:setTimeLabel(self._last - COUNTDOWN)
		self._layout.vars.headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_diglett_position.icon))
		self._layout.vars.left_times:setText(string.format("剩余次数：%s", i3k_db_findMooncake[id].dayTimes - info.useTimes))
	else
		i3k_sbean.mapcopy_leave()
	end
end

function wnd_hit_diglett:setTimeLabel(time)
	self._layout.vars.time:setText(i3k_get_time_show_text(time))
end

function wnd_hit_diglett:addTimeLabel()
	self._last = self._last - i3k_db_findMooncake[self._id].punishTime
	self._layout.anis.c_cuo.play()
end

function wnd_hit_diglett:addDiglettCount(id, count)
	if not self._count[id] then
		self._count[id] = 0
	end
	self._count[id] = self._count[id] + count
	self:setDiglettCount()
end

function wnd_hit_diglett:setDiglettCount()
	local diglettInfo = i3k_db_findMooncake[self._id].cakeInfo
	--[[for i = 1, 3 do
		if diglettInfo[i] then
			self._layout.vars["count"..i]:setText(string.format("%s/%s", self._count[diglettInfo[i].id], diglettInfo[i].count))
		else
			self._layout.vars["count"..i]:hide()
		end
	end--]]
	if diglettInfo[1] then
		if not self._count[diglettInfo[1].id] then
			self._count[diglettInfo[1].id] = 0
		end
		self._layout.vars.count:setText(string.format("%s/%s", self._count[diglettInfo[1].id], diglettInfo[1].count))
		if self._count[diglettInfo[1].id] >= diglettInfo[1].count then
			self:gameEnd()
		end
	else
		self._layout.vars.count:hide()
	end
end

function wnd_hit_diglett:gameEnd()
	self._end = true
	local diglettInfo = i3k_db_findMooncake[self._id].cakeInfo
	local isFinish = true
	--[[for i = 1, 3 do
		if diglettInfo[i] then
			if self._count[diglettInfo[i].id] < diglettInfo[i].count then
				isFinish = false
				break
			end
		else
			break
		end
	end--]]
	if diglettInfo[1] then
		if self._count[diglettInfo[1].id] < diglettInfo[1].count then
			isFinish = false
		end
	end
	if isFinish then
		i3k_sbean.findMooncake_getItems(self._id)
	else
		--失败处理
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local callback = function ()
				i3k_sbean.mapcopy_leave()
			end
			g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17062), callback)
		end, 1)
	end
end

function wnd_hit_diglett:onUpdate(dTime)
	local timeStamp = i3k_game_get_time()
	if self._isStart or timeStamp - self._startTime >= COUNTDOWN then
		local world = i3k_game_get_world()
		if world then
			world._isHitDiglettWorld = true
		end
		if not self._end then
			self._time = self._time + dTime
			if self._time >= 1 then
				local timeStamp = i3k_game_get_time()
				if self._last + self._startTime - timeStamp > 0 then
					self:setTimeLabel(self._last + self._startTime - timeStamp)
					self._time = 0
				else
					self:setTimeLabel(0)
					self:gameEnd()
				end
			end
		end
	else
		self._countDown = self._countDown + dTime
		if self._countDown >= 0 then
			if not self._isPlay then
				g_i3k_ui_mgr:AddTask(self, {}, function(ui)
					g_i3k_ui_mgr:OpenUI(eUIID_BattleFight)
					g_i3k_ui_mgr:RefreshUI(eUIID_BattleFight)
				end, 1)
				self._isPlay = true
			end
		end
		if self._countDown >= COUNTDOWN then
			self._isStart = true
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:CloseUI(eUIID_BattleFight)
			end, 1)
		end
	end
end

function wnd_hit_diglett:onExit(sender)
	local callback = function ()
		i3k_sbean.mapcopy_leave()
	end
	g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(16501), callback)
end

function wnd_create(layout, ...)
	local wnd = wnd_hit_diglett.new();
		wnd:create(layout, ...);
	return wnd;
end
