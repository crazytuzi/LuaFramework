module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleDesertWatchWar = i3k_class("wnd_battleDesertWatchWar", ui.wnd_base)

local TIMER = 1

function wnd_battleDesertWatchWar:ctor()
	self._hero = i3k_game_get_player_hero();
	self._moveFlag = false
	self._timeCount = 0
	self._timeFlag = true
end

function wnd_battleDesertWatchWar:configure()
	local weigths = self._layout.vars
	weigths.exit:onClick(self, self.onExitBtn)
	weigths.killTips:onClick(self, self.onChangeBtn)
end

function wnd_battleDesertWatchWar:refresh(name)
	self._layout.vars.des:setText(i3k_get_string(17631, name))
end

function wnd_battleDesertWatchWar:onShow()

end

function wnd_battleDesertWatchWar:onExitBtn()
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17622), function(isok)
		if isok then
			g_i3k_ui_mgr:CloseUI(eUIID_DesertBattleWatchWar)
			i3k_sbean.survive_final_score_result()
		end
	end)
end

function wnd_battleDesertWatchWar:onUpdate(dTime)
	if not self._timeFlag then
		self._timeCount = self._timeCount + dTime
		
		if self._timeCount > TIMER then
			self._timeFlag = true
		end
	end
end

function wnd_battleDesertWatchWar:onChangeBtn()
	if not self._timeFlag then
		return
	end
	
	self._timeFlag = false
	self._timeCount = 0
	local entity = g_i3k_game_context:getdesertBattleViewEntity()
	local curViewId = entity and entity:GetGuidID() or g_i3k_game_context:GetRoleId()	
	local teamInfo = g_i3k_game_context:GetTeamOtherMembersProfile()
	local info = g_i3k_game_context:getDesertBattleMapInfo()
	local memberId = 0
	local curIndex = 0
	local temData = {}
	
	for k, v in ipairs(teamInfo) do -- 没有玩家自己的数据
		local id = v.overview.id
		local isConnect = g_i3k_game_context:GetTeamMemberState(id)
		local lifeCount = info.lifes[id]
			
		if lifeCount > 0 and isConnect then
			table.insert(temData, {roleId = id, index = k}) 
		end
		
		if curViewId == id then
			curIndex = k
		end
	end
	
	local count = table.nums(temData)
	
	if count == 0 or (count == 1 and temData[1].roleId == curViewId) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17632))
		return		
	else
		for i = count, 1, -1 do
			local value = temData[i]
			
			if value.index > curIndex then
				memberId = value.roleId
			end
		end
		
		if memberId == 0 then
			memberId = temData[1].roleId
		end
	end
	
	i3k_sbean.requireOtherView(memberId)
end

function wnd_battleDesertWatchWar:updateOutCountTime(time, color)
	self._layout.vars.timeElapse:setText(self:formatTime(time))
	self._layout.vars.timeElapse:setTextColor(color)
end

function wnd_battleDesertWatchWar:formatTime(time)
	local tm = time;
	local h = i3k_integer(tm / (60 * 60));
	tm = tm - h * 60 * 60;

	local m = i3k_integer(tm / 60);
	tm = tm - m * 60;
	local s = tm;
	return string.format("%02d:%02d:%02d", h, m, s);
end

function wnd_create(layout)
	local wnd = wnd_battleDesertWatchWar.new();
	wnd:create(layout);
	return wnd;
end
