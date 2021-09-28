-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_wait_tip = i3k_class("wnd_wait_tip", ui.wnd_base)

function wnd_wait_tip:ctor()
  self._tipType = 0
end

function wnd_wait_tip:configure(...)
	
end

function wnd_wait_tip:onShow()
	
end

function wnd_wait_tip:refresh(matchType)
	local room = g_i3k_game_context:IsInRoom()
	if room and (room.type==gRoom_Dungeon or room.type == gRoom_TOWER_DEFENCE or room.type==gRoom_NPC_MAP) then
		self._layout.vars.bzts_img:setVisible(false)
		self._layout.vars.bzts_btn:onClick(self,self.formatDungonWaitTip)
		self._layout.vars.ok:onClick(self,self.onCloseUI)
		self._tipType = g_DUNGEON_WAIT
	elseif matchType and (matchType==g_TOURNAMENT_MATCH or matchType==g_FORCE_WAR_MATCH or matchType == g_FIGHT_TEAM_MATCH or g_GLOBAL_MATCH_TEAM[matchType]) then
		self._layout.vars.bzts_btn:onClick(self, self.onArenaOperation, matchType)
		self._layout.vars.ok:onClick(self, self.onSaveClose, matchType)
		if matchType==g_TOURNAMENT_MATCH then
			self._tipType = g_TOURNAMENT_WAIT
		elseif matchType==g_FORCE_WAR_MATCH then
			self._tipType = g_FORCE_WAR_WAIT
		elseif matchType == g_FIGHT_TEAM_MATCH then
			self._tipType = g_FIGHT_TEAM_WAIT
		end
	end
end

function wnd_wait_tip:getWaitType()
	return self._tipType
end

function wnd_wait_tip:formatDungonWaitTip(sender)--组队副本的处理逻辑
	local tipImage = self._layout.vars.bzts_img
	local selectFlag = tipImage:isVisible()
	local cfg = g_i3k_game_context:GetUserCfg()
	if selectFlag then
		cfg:SetDungeonWaitTipStatus(g_i3k_game_context:GetRoleId(),1)
	else
		cfg:SetDungeonWaitTipStatus(g_i3k_game_context:GetRoleId())
	end 
	tipImage:setVisible(not selectFlag)
end


function wnd_wait_tip:onArenaOperation(sender)
	local tipImage = self._layout.vars.bzts_img
	tipImage:setVisible(not tipImage:isVisible())
end

function wnd_wait_tip:onSaveClose(sender, matchType)
	if self._layout.vars.bzts_img:isVisible() then
		local usercfg = g_i3k_game_context:GetUserCfg()
		usercfg:SetMatchNotShow(matchType)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_WaitTip)
end


function wnd_create(layout,...)
	local wnd = wnd_wait_tip.new()
	wnd:create(layout,...)
	return wnd
end
