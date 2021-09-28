-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

--势力战组队房间
-------------------------------------------------------
wnd_war_team_room = i3k_class("wnd_war_team_room", ui.wnd_base)

MYROOM_STATE		= 1
NEARPLAYER_STATE	= 2
APPLYINFO_STATE		= 3

function wnd_war_team_room:ctor()
	self._joinTime = 0
	self._isLeader = false
end

function wnd_war_team_room:configure()
	self._memberCount = 0
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		self:closeWjxx()
	end)
	self._layout.vars.quitRoom:onClick(self, self.onQuitRoom)
	self._layout.vars.mateBtn:onClick(self, self.onMating)
	local widgets = self._layout.vars
	--我的房间版块
	local playerTable = {}
	for i=1, 4 do
		local player = {}
		player.root = widgets["player"..i]
		player.btn = widgets["playerBtn"..i]
		player.icon = widgets["icon"..i]
		player.typeImg = widgets["type"..i]
		player.levelLabel = widgets["levelLabel"..i]
		player.nameLabel = widgets["nameLabel"..i]
		player.powerLabel = widgets["powerLabel"..i]
		player.iconType = widgets["iconType"..i]
		player.addRoot = widgets["addPlayer"..i]
		player.addBtn = widgets["addBtn"..i]
		playerTable[i] = player
	end
	local myRoom = {
		root = widgets.teamInfo,
		viewWidget = playerTable,
	}
	
	--附近玩家版块
	local nearWidget = {
		scroll = widgets.scroll,
		noPlayerWord = widgets.noApply,
	}
	local nearPlayer = {
		root = widgets.fujin,
		viewWidget = nearWidget,
	}
	
	--申请信息版块
	local applyWidget = {
		scroll = widgets.scroll,
		noApplyWord = widgets.noApply
	}
	local applyInfo = {
		root = widgets.fujin,
		viewWidget = applyWidget,
	}
	
	self._widget = {
		[1] = myRoom,
		[2] = nearPlayer,
		[3] = applyInfo,
	}
	self._tabBar = {
		[1] = widgets.myTeamBtn,
		[2] = widgets.aroundPlayer,
		[3] = widgets.applyInfoBtn,
	}
	
	
	self._state = 1
	
	for i,v in ipairs(self._tabBar) do
		v:setTag(i)
		v:onClick(self, self.onTabBarClick)
		if i==self._state then
			v:stateToPressedAndDisable(true)
		else
			v:stateToNormal(true)
		end
		if i==3 then
			v:hide()
		end
	end
	for i,v in ipairs(self._widget[1].viewWidget) do
		v.root:hide()
		if v.addRoot then
			v.addRoot:show()
			v.addBtn:onClick(self, self.onAddPlayer)
		end
	end
	
	self._layout.vars.bgBtn:onClick(self, self.onBgClick)
end

function wnd_war_team_room:onShow()
	local matchType, actType, joinTime = g_i3k_game_context:getMatchState()
	self._joinTime = joinTime
	if matchType==g_FORCE_WAR_MATCH then
		self._layout.vars.waitLabel:show()
		self._layout.vars.mateBtn:show()
		self._layout.vars.mateLabel:setText(string.format("等待…"))
		self._layout.vars.mateBtn:onClick(self, self.onWait, matchType)
		self._layout.vars.quitRoom:onClick(self, self.stopMatchingOperation)
		self._layout.vars.quitLabel:setText(string.format("取消匹配"))
		--差等待时间
		self._layout.vars.closeBtn:onClick(self, self.onWait, matchType)
	end
end

function wnd_war_team_room:onWait(sender, matchType)
	local usercfg = g_i3k_game_context:GetUserCfg()
	if usercfg:GetMatchIsShow(matchType) then
		g_i3k_ui_mgr:OpenUI(eUIID_WaitTip)
		g_i3k_ui_mgr:RefreshUI(eUIID_WaitTip, matchType)
	end
	self:closeWjxx()
	g_i3k_ui_mgr:CloseUI(eUIID_War_Team_Room)
end

function wnd_war_team_room:onTabBarClick(sender)
	local tag = sender:getTag()
	if tag==1 then
		self:aboutMyRoom(g_i3k_game_context:getForceWarRoomLeader(), g_i3k_game_context:getForceWarMemberProfiles())
	elseif tag==2 then
		--附近的玩家请求协议
		-- local fRoomType = g_i3k_game_context:getForceWarRoomType()
		-- i3k_sbean.war_sync_near_player(fRoomType)
	else
		
	end
end

function wnd_war_team_room:setTabBarState(state)
	self:closeWjxx()
	self._state = state
	for i,v in ipairs(self._tabBar) do
		if i==self._state then
			v:stateToPressedAndDisable(true)
		else
			v:stateToNormal(true)
		end
	end
	for i,v in ipairs(self._widget) do
		v.root:hide()
	end
	self._widget[self._state].root:show()
	self._layout.vars.refreshBtn:setVisible(state==2)
	self._layout.vars.refreshBtn:onClick(self, function()
		i3k_sbean.sync_near_player()
	end)
end

function wnd_war_team_room:setRoleProperty(index, profile)
	local widget = self._widget[1].viewWidget[index]
	if not widget then
		error(string.format("index = %d, #viewWidget = %d", index, #self._widget[1].viewWidget))
	end
	widget.nameLabel:setText(profile.name)
	widget.levelLabel:setText(profile.level)
	widget.iconType:setImage(g_i3k_get_head_bg_path(profile.bwType, profile.headBorder))
	widget.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(profile.headIcon, false))
	widget.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[profile.type].classImg))
	widget.powerLabel:setText(profile.fightPower)
	widget.btn:onClick(self, self.onRoomMemberClick, profile.id)
	local roleId = g_i3k_game_context:GetRoleId()
	local bgImg = roleId==profile.id and "dw#dw_d2.png" or "dw#dw_d1.png"
	widget.root:setImage(bgImg)
	widget.root:setTag(profile.id)
	widget.root:show()
end

function wnd_war_team_room:refresh()
	
end

function wnd_war_team_room:aboutMyRoom(leaderId, membersProfile)
	local roleId = g_i3k_game_context:GetRoleId()
	local matchType = g_i3k_game_context:getMatchState()
	if  matchType==g_FORCE_WAR_MATCH then
		self._layout.vars.mateBtn:setVisible(true)
	else
		if roleId==leaderId then
			self._layout.vars.mateBtn:setVisible(true)
		else
			self._layout.vars.mateBtn:setVisible(false)
		end
	end
	--self._layout.vars.mateBtn:setVisible(roleId==leaderId and matchType~=g_FORCE_WAR_MATCH)
	self._isLeader = roleId==leaderId
	self:setTabBarState(1)
	local widget = self._widget[1]
	for i,v in ipairs(membersProfile) do
		if v.id==leaderId then
			self:setRoleProperty(1, v)
			break
		end
	end
	local isSkipLeader = false
	for i,v in ipairs(membersProfile) do
		--判断不是房主的并且需要控制好index
		if v.id~=leaderId then
			if isSkipLeader then
				self:setRoleProperty(i, v)
				widget.viewWidget[i].addRoot:hide()
			else
				self:setRoleProperty(i+1, v)
				widget.viewWidget[i+1].addRoot:hide()
			end
		else
			isSkipLeader = true
		end
	end
	self._memberCount = #membersProfile
end

function wnd_war_team_room:addRoomMember(profile)
	local id = profile.id
	self._memberCount = self._memberCount + 1
	if self._state==MYROOM_STATE then
		for i,v in ipairs(self._widget[1].viewWidget) do
			if not v.root:isVisible() then
				--添加新成员的操作
				self:setRoleProperty(i, profile)
				if v.addRoot then
					v.addRoot:hide()
				end
				break
			end
		end
	end
end

function wnd_war_team_room:roomMemberLeave(id)
	if self._state==MYROOM_STATE then
		local widget = self._widget[self._state]
		local index = 0
		for i,v in ipairs(widget.viewWidget) do
			if v.root:getTag()==id then
				index = i
			end
		end
		local profiles = g_i3k_game_context:getForceWarMemberProfiles()
		for i=index, self._memberCount-1 do
			self:setRoleProperty(i, profiles[i])
		end
		widget.viewWidget[self._memberCount].root:hide()
		widget.viewWidget[self._memberCount].root:setTag(0)
		widget.viewWidget[self._memberCount].addRoot:show()
	end
	self._memberCount = self._memberCount - 1
end

function wnd_war_team_room:onQuitRoom(sender)
	self:closeWjxx()
	i3k_sbean.war_quit_room()
end

function wnd_war_team_room:onBgClick(sender)
	self:closeWjxx()
end

function wnd_war_team_room:closeWjxx()
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_war_team_room:onRoomMemberClick(sender, roleId)
	local myId = g_i3k_game_context:GetRoleId()
	if myId~=roleId then
		if self._joinTime~=0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3012))
			return
		end
		local funcsLeader = g_i3k_game_context:getForceWarRoomLeader()==myId and {
			[1] = {
				name = "升为房主",
				roleId = roleId,
				callback = function (sender)
					g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
					i3k_sbean.war_change_leader(roleId)
				end
			},
			[4] = {
				name = "踢出成员",
				roleId = roleId,
				callback = function (sender)
					g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
					i3k_sbean.war_kick_room_member(roleId)
				end
			}
		} or nil
		local senderPos = sender:getPosition()
		local pos = sender:convertToWorldSpace(cc.p(senderPos.x+sender:getContentSize().width/2, senderPos.y))
		if funcsLeader then
			g_i3k_ui_mgr:PopupMenuList(pos, funcsLeader)
		end
	else
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	end
end

function wnd_war_team_room:onAddPlayer(sender)
	if self._joinTime~=0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3012))
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends,4)
end

function wnd_war_team_room:onMating(sender)
	--所有成员同一势力
	--等级
	--在线
	self:closeWjxx()
	local fRoomType = g_i3k_game_context:getForceWarRoomType() 
	g_i3k_game_context:InMatchingState(i3k_game_get_time(), g_FORCE_WAR_MATCH, fRoomType)
	i3k_sbean.join_forcewar(fRoomType)
end

--function 附近玩家() end
function wnd_war_team_room:aroundPlayer(roles)
	self:setTabBarState(2)
	local widget = self._widget[2].viewWidget
	local scroll = widget.scroll
	scroll:removeAllChildren(true)
	local noPlayerWord = widget.noPlayerWord
	for i,v in ipairs(roles) do
		local node = require("ui/widgets/sqzdt")()
		node.vars.name_label:setText(v.name)
		node.vars.level_label:setText(v.level)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(v.headIcon, false))
		node.vars.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.type].classImg))
		node.vars.okLabel:setText("邀请")
		node.vars.cancelLabel:setText("交谈")
		node.vars.iconType:setImage(g_i3k_get_head_bg_path(v.bwType, v.headBorder))
		node.vars.talk_btn:onClick(self, self.talkWithPlayer, v.id)
		node.vars.invite_btn:onClick(self, self.inviteToRoom, v.id)
		node.vars.power_label:setText("战力:"..v.fightPower)
		scroll:addItem(node)
	end
	noPlayerWord:setText(i3k_get_string(370))
	noPlayerWord:setVisible(#roles==0)
end

function wnd_war_team_room:inviteToRoom(sender, roleId)
	i3k_sbean.war_invite_room(roleId)
end

function wnd_war_team_room:talkWithPlayer(sender, roleId)
	g_i3k_ui_mgr:PopupTipMessage(string.format("交谈逻辑制作中"))
end

function wnd_war_team_room:startMatching()
	local matchType, actType, joinTime = g_i3k_game_context:getMatchState()
	local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
	self._joinTime = joinTime
	self._layout.vars.mateBtn:onClick(self, self.onWait, g_FORCE_WAR_MATCH)
	self._layout.vars.mateLabel:setText("等待…")
	self._layout.vars.mateBtn:show()
	self._layout.vars.quitRoom:onClick(self, self.stopMatchingOperation)
	self._layout.vars.quitLabel:setText("取消匹配")
	
	self._layout.vars.closeBtn:onClick(self, self.onWait, g_FORCE_WAR_MATCH)
end

function wnd_war_team_room:stopMatchingOperation(sender)
	i3k_sbean.quit_join_forcewar()
end

function wnd_war_team_room:stopMatching()
	self._layout.vars.mateBtn:onClick(self, self.onMating)
	self._layout.vars.mateLabel:setText("开始匹配")
	self._layout.vars.mateBtn:setVisible(self._isLeader)
	self._layout.vars.quitRoom:onClick(self, self.onQuitRoom)
	self._layout.vars.quitLabel:setText("离开房间")
	
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		self:closeWjxx()
	end)
	self._joinTime = 0
end

function wnd_war_team_room:onUpdate(dTime)
	if self._joinTime and self._joinTime~=0 then
		if not self._layout.vars.waitLabel:isVisible() then
			self._layout.vars.waitLabel:show()
		end
		local timeDis = i3k_game_get_time() - self._joinTime
		local min = timeDis/60
		if min <0 then
			min = 0
		end	
		local second = timeDis%60
		self._layout.vars.waitLabel:setText(string.format("已等待%d分%d秒", min, second))
	else
		if self._layout.vars.waitLabel:isVisible() then
			self._layout.vars.waitLabel:hide()
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_war_team_room.new()
	wnd:create(layout, ...)
	return wnd;
end
