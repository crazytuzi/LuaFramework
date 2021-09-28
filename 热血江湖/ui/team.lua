-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_team = i3k_class("wnd_team", ui.wnd_base)

function wnd_team:ctor()
	self._tabBar = {}
	self._state = 1--1是附近队伍，2是附近玩家
end

function wnd_team:configure()
	self._layout.vars.close:onClick(self, self.closeUI)
	local aroundTeam = self._layout.vars.aroundTeam
	local aroundPlayer = self._layout.vars.aroundPlayer
	
	if aroundTeam then
		--aroundTeam:setTitleText("附近队伍")
		aroundTeam:onTouchEvent(self, self.aroundTeamCB)
		aroundTeam:stateToPressed(true)
		aroundTeam:setTouchEnabled(false)
		table.insert(self._tabBar, aroundTeam)
	end
	if aroundPlayer then
		--aroundPlayer:setTitleText("附近玩家")
		aroundPlayer:onTouchEvent(self, self.aroundPlayerCB)
		table.insert(self._tabBar, aroundPlayer)
	end
	self._layout.vars.inviteBtn:onClick(self,self.OpenInviteUI)
	self._layout.vars.refresh:onTouchEvent(self, self.refreshCB)
end

function wnd_team:refresh(teams)
	self._teams = teams
	self:updateNearTeam(teams)
end



function wnd_team:onShow()
	
end

function wnd_team:onHide()
	
end

function wnd_team:refreshCB(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		local scroll = self._layout.vars.scroll
		scroll:removeAllChildren()
		if self._state==1 then
			local nearTeam = i3k_sbean.team_mapt_req.new()
			i3k_game_send_str_cmd(nearTeam, i3k_sbean.team_mapt_res.getName())
		else
			local nearPlayer = i3k_sbean.team_mapr_req.new()
			nearPlayer.from = 2
			i3k_game_send_str_cmd(nearPlayer, i3k_sbean.team_mapr_res.getName())
		end
	end
end

function wnd_team:aroundPlayerCB(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		self._state = 2 
		for i,v in pairs(self._tabBar) do
			v:stateToNormal(true)
			v:setTouchEnabled(true)
		end
		self._tabBar[2]:stateToPressed(true)
		self._tabBar[2]:setTouchEnabled(false)
		local scroll = self._layout.vars.scroll
		scroll:removeAllChildren()
		local size = scroll:getContentSize()
		scroll:setContainerSize(size.width, size.height)
		local nearPlayer = i3k_sbean.team_mapr_req.new()
		nearPlayer.from = 2
		i3k_game_send_str_cmd(nearPlayer, i3k_sbean.team_mapr_res.getName())
	end
end

function wnd_team:aroundTeamCB(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		self._state = 1
		for i,v in pairs(self._tabBar) do
			v:stateToNormal(true)
			v:setTouchEnabled(true)
		end
		self._tabBar[1]:stateToPressed(true)
		self._tabBar[1]:setTouchEnabled(false)
		local scroll = self._layout.vars.scroll
		scroll:removeAllChildren()
		local size = scroll:getContentSize()
		scroll:setContainerSize(size.width, size.height)
		local nearTeam = i3k_sbean.team_mapt_req.new()
		i3k_game_send_str_cmd(nearTeam, i3k_sbean.team_mapt_res.getName())
	end
end

function wnd_team:joinTeam(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		local tag = sender:getTag()-1000
		local targetTeamId = self._teams[tag].id
		local apply = i3k_sbean.team_apply_req.new()
		apply.teamId = targetTeamId
		i3k_game_send_str_cmd(apply, i3k_sbean.team_apply_res.getName())
	end
end

function wnd_team:closeUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Team)
end

function wnd_team:OpenInviteUI(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends,1)
end

function wnd_team:inviteToTeam(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		local roleId = sender:getTag()-1000
		i3k_sbean.invite_role_join_team(roleId)
	end
end

function wnd_team:updateNearTeam(teams)
	local scroll = self._layout.vars.scroll
	local noTeam = self._layout.vars.noTeam
	if #teams>0 then
		self._teams = teams
		noTeam:hide()
		scroll:show()
		for i=1,#teams do
			local fjdwt = require("ui/widgets/fjdwt")()
			--fjdwt.vars.joinBtn:setTitleText("加入队伍")
			fjdwt.vars.joinBtn:setTag(1000+i)
			fjdwt.vars.joinBtn:onTouchEvent(self, self.joinTeam)
			fjdwt.vars.index:setText(i..".")
			fjdwt.vars.teamName:setText(teams[i].leaderName.."的队伍")
			if teams[i].memberCount==4 then
				fjdwt.vars.teamCount:setText("<c=red>4/4</c>")
			else
				fjdwt.vars.teamCount:setText("<c=green>"..teams[i].memberCount.."/4</c>")
			end
			scroll:addItem(fjdwt)
		end
	else
		noTeam:setText(i3k_get_string(369))
		noTeam:show()
		scroll:hide()
	end
end

function wnd_team:updateNearPlayer(roles)
	local scroll = self._layout.vars.scroll
	local noPlayer = self._layout.vars.noTeam
	scroll:removeAllChildren()
	local size = scroll:getContentSize()
	scroll:setContainerSize(size.width, size.height)
	local count = 0
	if #roles>0 then
		noPlayer:hide()
		scroll:show()
		for i=1,#roles do
			local fjwj = require("ui/widgets/sqzdt")()
			fjwj.vars.name_label:setText(roles[i].name)
			fjwj.vars.iconType:setImage(g_i3k_get_head_bg_path(roles[i].bwType, roles[i].headBorder))
			fjwj.vars.level_label:setText(roles[i].level.."级")
			fjwj.vars.power_label:setText("战斗力"..roles[i].fightPower)
			fjwj.vars.cancelLabel:setText("交谈")
			fjwj.vars.talk_btn:hide()
			fjwj.vars.cancelLabel:hide()
			fjwj.vars.okLabel:setText("邀请组队")
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(roles[i].headIcon,g_i3k_db.eHeadShapeQuadrate);
			if hicon then
				fjwj.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
			end
				--local leaderId==GetLeaderId()
				--local roleInfo = g_i3k_game_context:GetRoleInfo()
				--local roleId = roleInfo.curChar._id
				--fjwj.vars.invite_btn:setTitleText("邀请入队")
			--else
				--fjwj.vars.invite_btn:setTitleText("邀请组队")
			--end
			fjwj.vars.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[roles[i].type].classImg))
			fjwj.vars.invite_btn:setTag(roles[i].id+1000)
			fjwj.vars.invite_btn:onTouchEvent(self, self.inviteToTeam)
			if not g_i3k_game_context:isBlackFriend(roles[i].id) then
				scroll:addItem(fjwj)
				count = count + 1
			end
		end
	end
	if count == 0 then
		noPlayer:setText(i3k_get_string(370))
		noPlayer:show()
		scroll:hide()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_team.new();
		wnd:create(layout, ...);

	return wnd;
end
