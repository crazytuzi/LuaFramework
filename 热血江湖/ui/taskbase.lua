module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
taskBase = i3k_class("taskBase", ui.wnd_base)
-- Warn:此UI不对应任何实体界面
--[[
继承自此UI的有：
battle_boss     boss伤害
battleTask      任务
battleTeam      组队
demonhole_summary 伏魔洞ui
]]

function taskBase:ctor()

end


local l_room_red_num = 2


-- 战斗界面左侧变懒按钮的4种状态
local TAB_STATE_NORMAL = 1 -- 正常状态，只有2个
local TAB_STATE_BOSS   = 2 -- 多一个显示boss输出
local TAB_STATE_WAIT   = 3 -- 多一个显示等待。。。
local TAB_STATE_ALL    = 4 -- 4个按钮都需要显示
local TAB_STATE_SPRING = 5 --温泉内显示
local TAB_STATE_HOMELAND = 6 --家园守卫战

local TAB_STATE =
{
	-- closePos 为相对于出现按钮，隔几个btn的距离
	-- bossBtnPos 为任务节点相对几个距离
	-- bossBtnVis 显隐
	[TAB_STATE_NORMAL] = { closePos = 2, bossBtnPos = 2, waitBtnPos = 3, bossBtnVis = false, waitBtnVis = false},
	[TAB_STATE_BOSS]   = { closePos = 3, bossBtnPos = 2, waitBtnPos = 3, bossBtnVis = true,  waitBtnVis = false},
	[TAB_STATE_WAIT]   = { closePos = 3, bossBtnPos = 2, waitBtnPos = 2, bossBtnVis = false, waitBtnVis = true },
	[TAB_STATE_ALL]    = { closePos = 4, bossBtnPos = 2, waitBtnPos = 3, bossBtnVis = true,  waitBtnVis = true },
	[TAB_STATE_SPRING] = { closePos = 2, bossBtnPos = 2, waitBtnPos = 3, bossBtnVis = false,  waitBtnVis = false },
	[TAB_STATE_HOMELAND] = { closePos = 2, bossBtnPos = 2, waitBtnPos = 3, bossBtnVis = false,  waitBtnVis = false },
}


function taskBase:configure()
	self.isSetPos = false
	self._tabState = 1 -- 当前显示的面板ID(1.任务 2.队伍 3.输出)

	widget = self._layout.vars
	widget.taskBtn:onClick(self, self.onBaseTaskBtn)
	widget.team:onClick(self,self.onBaseZuduiBtn)
	widget.room_btn:onClick(self,self.onOpenRoom)
	--世界BOSS伤害输出值
	self._layout.vars.bossBtn:onClick(self, self.onBossBtn)
	self._layout.vars.closeBtn:onClick(self, self.onCloseAnisBtn)
	self._layout.vars.openBtn:onClick(self, self.onOpenAnisBtn)
end

function taskBase:refresh()

end

function taskBase:onShow()
	self:updateRoomData()
end

-----------------------------------重构
-- 对外的接口
function taskBase:updateState()
	local state = self:getState()
	self:setBtnVisibleByState(state)
	self:adjustCloseBtnPositionByTabState(state)
end

-- 根据状态，获取当前state
function taskBase:getState()
	local world = i3k_game_get_world()
	if world then
		if world._cfg.id == i3k_db_spring.common.mapId then
			return TAB_STATE_SPRING
		end
	end
	local mapType = i3k_game_get_map_type()
	if mapType then
		if mapType == g_HOMELAND_GUARD then
			return TAB_STATE_HOMELAND
		end
	end
	local bossState = g_i3k_game_context:getIsShowBossDamageBtn()
	local waitState = g_i3k_game_context:getMatchState() ~= 0 or g_i3k_game_context:IsInRoom() -- 如果在房间或者是在匹配状态
	if not bossState and not waitState then
		return TAB_STATE_NORMAL
	end
	if bossState and waitState then
		return TAB_STATE_ALL
	end
	if bossState then
		return TAB_STATE_BOSS
	end
	if waitState then
		return TAB_STATE_WAIT
	end
end

-- 根据状态，设置4个按钮的显隐and坐标
function taskBase:setBtnVisibleByState(state)
	local pos2 = self._layout.vars.team:getPosition()
	local pos1 = self._layout.vars.taskBtn:getPosition()
	local deltaLengthX = math.abs(pos1.x - pos2.x)
	local cfg = TAB_STATE[state]
	self._layout.vars.taskBtn:setVisible(true)
	self._layout.vars.team:setVisible(true)
	self._layout.vars.bossBtn:setVisible(cfg.bossBtnVis)
	self._layout.vars.room_btn:setVisible(cfg.waitBtnVis)

	self._layout.vars.bossBtn:setPosition(pos1.x + deltaLengthX * cfg.bossBtnPos, pos1.y)
	self._layout.vars.room_btn:setPosition(pos1.x + deltaLengthX * cfg.waitBtnPos, pos1.y)

	if state == TAB_STATE_SPRING then
		if self._layout.vars.taskTitle then
			self._layout.vars.taskTitle:setText("祝福")
			self._layout.vars.taskBtn:onClick(self, function  ()
				g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
				g_i3k_ui_mgr:OpenUI(eUIID_SpringBuff)
				g_i3k_ui_mgr:RefreshUI(eUIID_SpringBuff)
			end)
		end
	end
	if state == TAB_STATE_HOMELAND then
		if self._layout.vars.taskTitle then
			self._layout.vars.taskBtn:onClick(self, function  ()
				g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
				g_i3k_ui_mgr:OpenUI(eUIID_DefendSummary)
				g_i3k_ui_mgr:RefreshUI(eUIID_DefendSummary)
			end)
		end
	end
end


-- 设置隐藏按钮的坐标
function taskBase:adjustCloseBtnPositionByTabState( state )
	local pos1 = self._layout.vars.team:getPosition()
	local pos2 = self._layout.vars.taskBtn:getPosition()
	local deltaLengthX = math.abs(pos2.x - pos1.x)
	local pos3 = self._layout.vars.openBtn:getPosition()
	local tabs = TAB_STATE[state].closePos
	self._layout.vars.closeBtn:setPosition(pos3.x + tabs * deltaLengthX, pos3.y)
end
----------------------------------重构end

-- function taskBase:onCheckCloseBtnPositon()
-- 	if self._tabState == 1 or self._tabState == 2 then
-- 		local inRoom = self._layout.vars.room_btn:isVisible()
-- 		local isBoss = self._layout.vars.bossBtn:isVisible()
-- 		if inRoom or isBoss then
-- 			if self.isSetPos then
-- 				self:setCloseBtnPositon(false)
-- 			end
-- 			self.isSetPos = false
-- 			return
-- 		end
-- 		if not self.isSetPos then
-- 			self:setCloseBtnPositon(true)
-- 			self.isSetPos = true
-- 		end
-- 	end
-- end

-- -- TODO 修改为按照显示多少个按钮，来设置位置
-- function taskBase:setCloseBtnPositon(bValue)
-- 	if bValue then
-- 		local pos1 = self._layout.vars.team:getPosition()
-- 		local pos2 = self._layout.vars.bossBtn:getPosition()
-- 		local pos3 = self._layout.vars.closeBtn:getPosition()
-- 		self._layout.vars.closeBtn:setPosition(pos3.x - math.abs(pos2.x - pos1.x), pos3.y)
-- 	else
-- 		local pos1 = self._layout.vars.team:getPosition()
-- 		local pos2 = self._layout.vars.bossBtn:getPosition()
-- 		local pos3 = self._layout.vars.closeBtn:getPosition()
-- 		self._layout.vars.closeBtn:setPosition(pos3.x + math.abs(pos2.x - pos1.x), pos3.y)
-- 	end
-- end

function taskBase:onCloseAnisBtn(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "clearTaskGuideTimer")

	self._layout.vars.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		self._layout.vars.openBtn:show()
		-- self._layout.vars.buffdRoot:hide()
	end)
end
function taskBase:onOpenAnisBtn(sender)
	self._layout.vars.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		self._layout.vars.closeBtn:show()
		-- self._layout.vars.buffdRoot:show()
	end)
end

function taskBase:hideBuffdRoot()
	self._layout.vars.buffdRoot:hide()
	-- self:onCheckCloseBtnPositon()
	self:updateState()
end
function taskBase:showBuffdRoot()
	self._layout.vars.buffdRoot:show()
	-- self:onCheckCloseBtnPositon()
	self:updateState()
end

function taskBase:setTabState(state)
	self._tabState = state
end

function taskBase:onBaseTaskBtn(sender)
	local isOpen = true
	if i3k_game_get_map_type() == g_FIELD then
		if self._tabState~=1 then
			isOpen = false
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
		end
		if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
			g_i3k_ui_mgr:OpenUI(eUIID_SpringBuff)
			g_i3k_ui_mgr:RefreshUI(eUIID_SpringBuff)
		else
			g_i3k_logic:OpenBattleTaskUI()
			g_i3k_game_context:setOpenTaskState(1)
			self._tabState = 1
			if isOpen then
				g_i3k_logic:OpenTaskUI()
			end
		end
	elseif i3k_game_get_map_type() == g_ANNUNCIATE then
		if self._tabState~=1 then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
			g_i3k_logic:OpenBattleTaskUI(true)
		end
		self._tabState = 1
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateAnnunciateInfo")
	elseif i3k_game_get_map_type() == g_DEMON_HOLE then
		if self._tabState~=1 then
			g_i3k_logic:OpenDemonHoleSummaryUI()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
		end
		self._tabState = 1
	elseif i3k_game_get_map_type() == g_DEFEND_TOWER or i3k_game_get_map_type() == g_DOOR_XIULIAN or i3k_game_get_map_type() == g_HOMELAND_GUARD then
		if self._tabState~=1 then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
			g_i3k_ui_mgr:OpenUI(eUIID_DefendSummary)
			g_i3k_ui_mgr:RefreshUI(eUIID_DefendSummary)
		end
		self._tabState = 1
	elseif i3k_game_get_map_type() == g_FACTION_GARRISON then
		if self._tabState~=1 then
            g_i3k_logic:OpenGarrisonTeam()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
		end
		self._tabState = 1
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(437))
	end
end

function taskBase:onBaseZuduiBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.constituteTeamLvl then
		return g_i3k_ui_mgr:PopupTipMessage("等级到达<c=hlred>10级</c>之后开放组队功能")
	end
	if g_i3k_logic:isTalkUI() then
		return;
	end
	if self._tabState~=2 then
		local data = g_i3k_game_context:GetTeamOtherMembersProfile()
		if data == nil or next(data) == nil  then
			local mapType = i3k_game_get_map_type()
			if  not (mapType == g_FIELD or mapType == g_FACTION_TEAM_DUNGEON or g_ANNUNCIATE == mapType or mapType == g_FACTION_GARRISON) then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(49))
				return
			end
			-- self:setTeamBtnAnis(false)
			local teamId = g_i3k_game_context:GetTeamId()
			local isHaveReqForTeam = g_i3k_game_context:GetIsHaveReqForTeam()
			if teamId~=0 then
				g_i3k_ui_mgr:OpenUI(eUIID_MyTeam)
				g_i3k_ui_mgr:RefreshUI(eUIID_MyTeam, isHaveReqForTeam, g_i3k_game_context:GetTeamLeader(), g_i3k_game_context:GetAllTeamMembers())
			else
				local teamMember = i3k_sbean.team_mapt_req.new()
				i3k_game_send_str_cmd(teamMember, i3k_sbean.team_mapt_res.getName())
			end
		else
			self._tabState = 2
			g_i3k_ui_mgr:CloseUI(eUIID_DefendSummary)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
			g_i3k_ui_mgr:CloseUI(eUIID_SpringBuff)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSummary)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTeam)
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleTeam)
			g_i3k_game_context:setOpenTaskState(2)
			if i3k_game_get_map_type() == g_ANNUNCIATE then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateAnnunciateInfo", true)
			end
		end
	else
		local mapType = i3k_game_get_map_type()
		if not (mapType == g_FIELD or mapType == g_FACTION_TEAM_DUNGEON or g_ANNUNCIATE == mapType or mapType == g_FACTION_GARRISON) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(49))
			return
		end
		-- self:setTeamBtnAnis(false)
		local teamId = g_i3k_game_context:GetTeamId()
		local isHaveReqForTeam = g_i3k_game_context:GetIsHaveReqForTeam()
		if teamId~=0 then
			g_i3k_ui_mgr:OpenUI(eUIID_MyTeam)
			g_i3k_ui_mgr:RefreshUI(eUIID_MyTeam, isHaveReqForTeam, g_i3k_game_context:GetTeamLeader(), g_i3k_game_context:GetAllTeamMembers())
		else
			local teamMember = i3k_sbean.team_mapt_req.new()
			i3k_game_send_str_cmd(teamMember, i3k_sbean.team_mapt_res.getName())
		end
	end
end

-- 更新“房间”按钮显隐
function taskBase:updateRoomData()
	local room = g_i3k_game_context:IsInRoom()
	local room_btn = self._layout.vars.room_btn
	local room_red = self._layout.vars.room_red
	if room then
		-- room_btn:show()
		-- room_btn:onClick(self,self.onOpenRoom)
		if room.type == gRoom_Dungeon and g_i3k_game_context:GetRoleId() == g_i3k_game_context:GetRoomLeaderID() and g_i3k_game_context:GetRoomRoleCount() >= l_room_red_num then
			room_red:setVisible(true)
		else
			room_red:setVisible(false)
		end
	else
		room_btn:hide()
	end
	self:updateState()
	-- self:onCheckCloseBtnPositon()
end

function taskBase:onOpenRoom(sender)
	local room = g_i3k_game_context:IsInRoom()
	local matchType,actType,joinTime = g_i3k_game_context:getMatchState()
	local roomType = room and room.type or 0
	if matchType ~= 0 and roomType == gRoom_Force_War and g_i3k_game_context:getForceWarRoomType() == g_CHANNEL_COMBAT then
		g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
		g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, joinTime, matchType, actType)
		return
	end
	if not room then
		if matchType~=0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
			g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, joinTime, matchType, actType)
		end
		return
	end

	if roomType==gRoom_Dungeon or roomType== gRoom_NPC_MAP or roomType == gRoom_TOWER_DEFENCE then
		i3k_sbean.mroom_self()
	elseif roomType==gRoom_Tournament then
		g_i3k_ui_mgr:OpenUI(eUIID_TournamentRoom)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "aboutMyRoom", g_i3k_game_context:getTournameRoomLeader(), g_i3k_game_context:getTournameMemberProfiles())
	elseif roomType==gRoom_Force_War then
		--打开势力战房间
		if g_i3k_game_context:getForceWarRoomType() ~= g_CHANNEL_COMBAT then
			g_i3k_ui_mgr:OpenUI(eUIID_War_Team_Room)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_War_Team_Room, "aboutMyRoom", g_i3k_game_context:getForceWarRoomLeader(), g_i3k_game_context:getForceWarMemberProfiles())
		else
			g_i3k_ui_mgr:OpenUI(eUIID_CreateCombatTeam)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateCombatTeam, "loaMembersProfile", g_i3k_game_context:getForceWarRoomLeader(), g_i3k_game_context:getForceWarMemberProfiles())
		end
	end
end


function taskBase:showBossBtn()
	-- self._layout.vars.bossBtn:show()
	-- self:onCheckCloseBtnPositon()
	self:updateState()
end
function taskBase:hideBossBtn()
	-- self._layout.vars.bossBtn:hide()
	-- self:onCheckCloseBtnPositon()
	self:updateState()
end

function taskBase:onBossBtn(sender)
	if self._tabState~=3 then
		self._tabState = 3
		g_i3k_game_context:setOpenTaskState(3)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_DemonHolesummary)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSummary)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleBoss)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBoss, "updateState")
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = taskBase.new();
		wnd:create(layout);
	return wnd;
end
