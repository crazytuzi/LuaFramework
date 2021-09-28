-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_inviteFriends = i3k_class("wnd_inviteFriends", ui.wnd_base)

local TYPE_TEAM = 1 -- 组队
local TYPE_ROOM = 2 -- 副本房间
local TYPE_4V4  = 3 -- 4v4
local TYPE_FORCE_WAR = 4 -- 势力战
local TYPE_FIGHT_TEAM = 5 -- 武道会

local STATE_FRIEND = 1  -- 好友
local STATE_FACTION = 2 -- 帮派
local STATE_NEARBY = 3 -- 附近的玩家
local STATE_MASTER = 4 -- 师徒



function wnd_inviteFriends:ctor()

end

function wnd_inviteFriends:configure(...)
	local close = self._layout.vars.close
	local friend = self._layout.vars.friend
	local faction = self._layout.vars.faction
	local nearPlayer = self._layout.vars.nearPlayer
	local master = self._layout.vars.masterBtn
	self._tabbar = {}

	close:onClick(self, self.closeUI)
	self._layout.vars.refresh:onClick(self, self.refreshNewData)

	self._tabbar[STATE_FRIEND] = friend
	self._tabbar[STATE_FACTION] = faction
	self._tabbar[STATE_NEARBY] = nearPlayer
	self._tabbar[STATE_MASTER] = master

	friend:onClick(self, self.updateState, STATE_FRIEND)
	faction:onClick(self, self.updateState, STATE_FACTION)
	nearPlayer:onClick(self, self.updateState, STATE_NEARBY)
	master:onClick(self, self.updateState, STATE_MASTER)

end

function wnd_inviteFriends:onShow()
	self._state = STATE_FRIEND
end

function wnd_inviteFriends:refresh(type)
	self._type = type
	self:reloadTabBar(self._state)
end

function wnd_inviteFriends:closeUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_InviteFriends)
end

function wnd_inviteFriends:updateState(sender, state)
	if self._state ~= state then
		self:reloadTabBar(state)
	end
	self._state = state
end


function wnd_inviteFriends:reloadTabBar(tag)
	for i,v in pairs(self._tabbar) do
		if i==tag then
			self:onRefreshscroll(tag)
			v:stateToPressed(true)
			v:setTouchEnabled(false)
		else
			v:stateToNormal(true)
			v:setTouchEnabled(true)
		end
		if self._type == TYPE_FIGHT_TEAM then
			v:setVisible(i == STATE_FRIEND)
		end
	end
end

function wnd_inviteFriends:refreshNewData(sender)
	self:onRefreshscroll(self._state)
end

function wnd_inviteFriends:onRefreshscroll(typeValue)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	if typeValue == STATE_FRIEND then
		if self._type ~= TYPE_FIGHT_TEAM then
			i3k_sbean.syncFriend(2)
		else
			i3k_sbean.fightteam_queryf()
		end
	elseif typeValue == STATE_FACTION then
		local sectId = g_i3k_game_context:GetSectId()
		if sectId <= 0 then
			g_i3k_ui_mgr:PopupTipMessage("您当前没有帮派")
			return
		else
			local data = i3k_sbean.sect_members_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
		end
	elseif typeValue == STATE_NEARBY then
		if self._type == TYPE_TEAM then
			local nearPlayer = i3k_sbean.team_mapr_req.new()
			nearPlayer.from = 1
			i3k_game_send_str_cmd(nearPlayer, i3k_sbean.team_mapr_res.getName())
		elseif self._type == TYPE_ROOM then
			i3k_sbean.mroom_mapr(g_NEARBY_IFRIENDS)
		elseif self._type == TYPE_4V4 then
			i3k_sbean.sync_near_player()
		elseif self._type == TYPE_FORCE_WAR then
			local fRoomType = g_i3k_game_context:getForceWarRoomType()
			i3k_sbean.war_sync_near_player(fRoomType) --势力战
		end
	elseif typeValue == STATE_MASTER then -- 师徒
		i3k_sbean.getMasterRequeset()
	end
end

function wnd_inviteFriends:onShowFriendsList()
	local scroll = self._layout.vars.scroll
	local FriendsData = g_i3k_game_context:GetFriendsData()--获取基本数据
	local num = #FriendsData
	if num == 0 then
		g_i3k_ui_mgr:PopupTipMessage("您当前未添加任何好友")
		return;
	end
	local index = 0
	for k,v in ipairs(FriendsData) do
		local id = nil
		local isOnline = 1
		if v.fov then
			id = v.fov.overview.id
			isOnline = v.fov.online
		else
			id = v.overview.id
			isOnline = v.online
		end
		if id and isOnline == 1 then
			local isHave = self:checkIsCanJoin(id)
			if not isHave then
				local info = g_i3k_game_context:GetFrRoleOverviewById(id)
				index = index +1
				local Item = self:createItem(info,index)
				scroll:addItem(Item)
			end
		end
	end
end

-- 武道会
function wnd_inviteFriends:onShowFightTeamFriends(roles)
	for i, e in ipairs(roles) do
		-- if not self:checkIsCanJoin(e) then
			self._layout.vars.scroll:addItem(self:createItem(e))
		--end
	end
end

function wnd_inviteFriends:onShowFactionList(Data)
	local scroll = self._layout.vars.scroll
	if not Data then
		return;
	end
	local index = 0
	local roleId = g_i3k_game_context:GetRoleId()
	for k,v in pairs(Data) do
		if roleId == v.role.id then
			if #Data == 1 then
				g_i3k_ui_mgr:PopupTipMessage("您当前帮派没有任何帮派成员")
				break;
			end
		else
			if v.lastLogoutTime == 0 then
				local isHave = false
				isHave = self:checkIsCanJoin(v.role.id)
				if not isHave then
					index = index +1
					local info = v.role
					local Item = self:createItem(info,index)
					scroll:addItem(Item)
				end
			end
		end
	end
end
--附近好友
function wnd_inviteFriends:onShowPlayerList(Data)
	local scroll = self._layout.vars.scroll
	if not Data then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(370))
		return;
	end
	local index = 0
	for k,v in pairs(Data) do
		local isHave = false
		isHave = self:checkIsCanJoin(v.id)
		if not isHave then
			index = index +1
			local Item = self:createItem(v,index)
			scroll:addItem(Item)
		end
	end
	if index == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(370))
	end
end

-- 师徒
function wnd_inviteFriends:onShowMasterPlayerList(Data)
	local scroll = self._layout.vars.scroll
	if not Data or #Data == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5038))
		return;
	end
	local index = 0
	for k,v in pairs(Data) do
		index = index + 1
		local Item = self:createItem(v,index)
		scroll:addItem(Item)
	end
end

function wnd_inviteFriends:createItem(info)
	local Item = require("ui/widgets/yqhyt")()
	Item.vars.name_label:setText(info.name)
	Item.vars.level_label:setText(string.format("%d级", info.level))
	Item.vars.power_label:setText("战斗力"..info.fightPower)
	Item.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(info.headIcon, false));
	Item.vars.txb_img:setImage(g_i3k_get_head_bg_path(info.bwType, info.headBorder))
	local gcfg = g_i3k_db.i3k_db_get_general(info.type)
	Item.vars.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
	Item.vars.invite_btn:onClick(self, self.inviteToTeam,info)
	return Item
end

function wnd_inviteFriends:checkIsCanJoin(id)
	local isHave = false
	if self._type == TYPE_TEAM then
		isHave = g_i3k_game_context:IsTeamMember(id)
	elseif self._type == TYPE_ROOM then
		local data = g_i3k_game_context:GetRoomData()
		for i,e in ipairs(data) do
			if e.id == id then
				isHave = true
				break;
			end
		end
	elseif self._type == TYPE_4V4 then
		local data = g_i3k_game_context:getTournameMemberProfiles()
		for i,e in ipairs(data) do
			if e.id == id then
				isHave = true
				break;
			end
		end
	elseif self._type == TYPE_FORCE_WAR then
		local data = g_i3k_game_context:getForceWarMemberProfiles()
		for i,e in ipairs(data) do
			if e.id == id then
				isHave = true
				break;
			end
		end
	end
	if g_i3k_game_context:isBlackFriend(id) then
		isHave = true
	end
	return isHave
end

function wnd_inviteFriends:inviteToTeam(sender,info)
	if self._type == TYPE_TEAM then--组队
		i3k_sbean.invite_role_join_team(info.id)
	elseif self._type == TYPE_ROOM then--副本房间
		local data = i3k_sbean.mroom_invite_req.new()
		data.roleId = info.id
		data.roleName = info.name
		i3k_game_send_str_cmd(data, "mroom_invite_res")
	elseif self._type == TYPE_4V4 then--4v4房间
		local invite = i3k_sbean.aroom_invite_req.new()
		invite.roleID = info.id
		i3k_game_send_str_cmd(invite, "aroom_invite_res")
	elseif self._type == TYPE_FORCE_WAR then--势力战
		if g_i3k_game_context:getForceWarRoomType() == g_FORCEWAR_NORMAL then
			if g_i3k_game_context:GetTransformBWtype() == info.bwType then
				i3k_sbean.war_invite_room(info.id)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1021))
			end	
		else
			i3k_sbean.war_invite_room(info.id)
		end
	elseif self._type == TYPE_FIGHT_TEAM then
		self:onInviteToFightTeam(info) 
	end
end

function wnd_inviteFriends:onInviteToFightTeam(info)
	if info.level < i3k_db_fightTeam_base.team.requireLvl then
		return g_i3k_ui_mgr:PopupTipMessage("你邀请的玩家等级不足")
	end
	local fightTeamInfo = g_i3k_game_context:getFightTeamInfo()
	if fightTeamInfo then
		i3k_sbean.fightteam_invite(info.id, fightTeamInfo.id)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_inviteFriends.new();
		wnd:create(layout, ...);

	return wnd;
end
