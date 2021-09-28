-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_create_combat_team = i3k_class("wnd_create_combat_team", ui.wnd_base)

local NODE_TUANDUIT1 = "ui/widgets/tuanduit1"
local MAX_NUM = 10--i3k_db_forcewar_base.channelData.fightNum

function wnd_create_combat_team:ctor()
	
end

function wnd_create_combat_team:configure()
	local widgets = self._layout.vars	
	widgets.closeBtn:onClick(self, self.closeUI)
	
	self.scroll = widgets.scroll
	widgets.leaveBtn:onClick(self, self.onLeaveBtn)
	widgets.globalBtn:onClick(self, self.onGlobalBtn)
end

function wnd_create_combat_team:refresh()
	
end

function wnd_create_combat_team:onLeaveBtn(sender)
	self:closeWjxx()
	i3k_sbean.war_quit_room()
end

function wnd_create_combat_team:loaMembersProfile(leaderId, membersProfile)
	self:closeWjxx()
	self.scroll:removeAllChildren()
	local nodes = self.scroll:addItemAndChild(NODE_TUANDUIT1, 5, MAX_NUM)
	for i, e in ipairs(nodes) do
		local widget = e.vars
		local profile = membersProfile[i]
		if profile then
			widget.profileRoot:setVisible(true)
			widget.nameLabel:setText(profile.name)
			widget.levelLabel:setText(profile.level)
			widget.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[profile.type].classImg))
			widget.iconType:setImage(g_i3k_get_head_bg_path(profile.bwType, profile.headBorder))
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(profile.headIcon, g_i3k_db.eHeadShapeQuadrate)
			widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			widget.isLeader:setVisible(profile.id == leaderId)
			widget.btn:onClick(self, self.onRoomMemberClick, profile.id)
			widget.kong:setVisible(false)
		else
			widget.profileRoot:setVisible(false)
			widget.kong:setVisible(true)
			widget.btn:onClick(self, self.onInvite)
		end
	end
end

function wnd_create_combat_team:onRoomMemberClick(sender, roleId)
	local myId = g_i3k_game_context:GetRoleId()
	if myId~=roleId then
		local funcsLeader = g_i3k_game_context:getForceWarRoomLeader()==myId and {
			[1] = {
				name = "升为房主",
				roleId = roleId,
				callback = function (sender)
					g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
					i3k_sbean.war_change_leader(roleId)
				end
			},
			[2] = {
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

function wnd_create_combat_team:onInvite(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends, 4)
end

function wnd_create_combat_team:closeWjxx()
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_create_combat_team:closeUI(sender)
	self:closeWjxx()
	g_i3k_ui_mgr:CloseUI(eUIID_CreateCombatTeam)
end

function wnd_create_combat_team:onGlobalBtn(sender)
	self:closeWjxx()
end

function wnd_create(layout)
	local wnd = wnd_create_combat_team.new()
	wnd:create(layout)
	return wnd
end
