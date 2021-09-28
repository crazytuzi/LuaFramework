-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_myTeam = i3k_class("wnd_myTeam", ui.wnd_base)

function wnd_myTeam:ctor()
	self._isLeader = nil
	self._state = 1--1是我的队伍，2是附近玩家，3是申请信息
	
	self._widgets = {}
end

function wnd_myTeam:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	end)
	self._layout.vars.refresh:onClick(self, self.refreshCB)
	
	self._widgets.teamPlayers = {}
	self._widgets.addPlayer = {}
	local player1 = self._layout.vars.player1
	local player2 = self._layout.vars.player2
	local player3 = self._layout.vars.player3
	local player4 = self._layout.vars.player4
	self._widgets.teamPlayers.root = {player1, player2, player3, player4}
	
	local addPlayer2 = self._layout.vars.addPlayer2
	local addPlayer3 = self._layout.vars.addPlayer3
	local addPlayer4 = self._layout.vars.addPlayer4
	self._widgets.addPlayer.root = {addPlayer2, addPlayer3, addPlayer4}
	
	local addBtn2 = self._layout.vars.addBtn2
	local addBtn3 = self._layout.vars.addBtn3
	local addBtn4 = self._layout.vars.addBtn4
	self._widgets.addPlayer.btn = {addBtn2, addBtn3, addBtn4}
	
	for i,v in pairs(self._widgets.addPlayer.btn) do
		v:onClick(self, self.addPlayerToTeam)
	end
	
	for i,v in pairs(self._widgets.addPlayer.root) do
		v:hide()
	end
	
	for i,v in pairs(self._widgets.teamPlayers.root) do
		v:hide()
	end
	
	local iconType1 = self._layout.vars.iconType1
	local iconType2 = self._layout.vars.iconType2
	local iconType3 = self._layout.vars.iconType3
	local iconType4 = self._layout.vars.iconType4
	self._widgets.teamPlayers.iconType = {iconType1, iconType2, iconType3, iconType4}
	
	local icon1 = self._layout.vars.icon1
	local icon2 = self._layout.vars.icon2
	local icon3 = self._layout.vars.icon3
	local icon4 = self._layout.vars.icon4
	self._widgets.teamPlayers.icon = {icon1, icon2, icon3, icon4}
	
	local zhiye1 = self._layout.vars.zhiye1
	local zhiye2 = self._layout.vars.zhiye2
	local zhiye3 = self._layout.vars.zhiye3
	local zhiye4 = self._layout.vars.zhiye4
	self._widgets.teamPlayers.zhiye = {zhiye1, zhiye2, zhiye3, zhiye4}
	
	local lvl1 = self._layout.vars.lvl1
	local lvl2 = self._layout.vars.lvl2
	local lvl3 = self._layout.vars.lvl3
	local lvl4 = self._layout.vars.lvl4
	self._widgets.teamPlayers.level = {lvl1, lvl2, lvl3, lvl4}
	
	local playerName1 = self._layout.vars.playerName1
	local playerName2 = self._layout.vars.playerName2
	local playerName3 = self._layout.vars.playerName3
	local playerName4 = self._layout.vars.playerName4
	self._widgets.teamPlayers.name = {playerName1, playerName2, playerName3, playerName4}
	
	local playerPower1 = self._layout.vars.playerPower1
	local playerPower2 = self._layout.vars.playerPower2
	local playerPower3 = self._layout.vars.playerPower3
	local playerPower4 = self._layout.vars.playerPower4
	self._widgets.teamPlayers.powerLabel = {playerPower1, playerPower2, playerPower3, playerPower4}
	
	
	self._layout.vars.quitTeam:onClick(self, self.quitTeamCB)
	
	
	local playerBtn1 = self._layout.vars.playerBtn1
	local playerBtn2 = self._layout.vars.playerBtn2
	local playerBtn3 = self._layout.vars.playerBtn3
	local playerBtn4 = self._layout.vars.playerBtn4
	self._widgets.teamPlayers.btn = {playerBtn1, playerBtn2, playerBtn3, playerBtn4}
	
end

function wnd_myTeam:onShow()
	
end

function wnd_myTeam:onHide()
	
end

function wnd_myTeam:refresh(isHaveApply, leaderId, teamMembers)
	self._isHaveApplyInfo = isHaveApply
	local myTeamBtn = self._layout.vars.myTeamBtn
	local applyInfoBtn = self._layout.vars.applyInfoBtn
--	local aroundPlayer = self._layout.vars.aroundPlayer
	
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local roleId = roleInfo.curChar._id
	
	
	self._tabBar = {myTeamBtn, --[[aroundPlayer,--]] applyInfoBtn}
	
	applyInfoBtn:onClick(self, self.applyInfoPage)
	myTeamBtn:onClick(self, self.myTeamPage)
--	aroundPlayer:onClick(self, self.aroundPlayerCB)
	if self._isHaveApplyInfo then
		if applyInfoBtn then
			applyInfoBtn:stateToPressed(true)
			applyInfoBtn:setTouchEnabled(false)
		end
	else
		if myTeamBtn then
			myTeamBtn:stateToPressed(true)
			myTeamBtn:setTouchEnabled(false)
		end
	end
	
	
	local count = 0
	for i,v in pairs(teamMembers) do
		count = count + 1
	end
	local index = 1
	local roleIndex
	for i,v in pairs(teamMembers) do
		self._widgets.teamPlayers.btn[index]:setTag(1000+i)
		if i==roleId then
			roleIndex = index
		end
		index = index + 1
	end
	if roleId==leaderId then
		roleIndex = 1
	end
	for i=1, count do
		if i==roleIndex then
			self._widgets.teamPlayers.btn[i]:onClick(self,self.bgBtnCB)
		else
			self._widgets.teamPlayers.btn[i]:onClick(self, self.playerOpreation,{})
		end
	end
	
	
	self._layout.vars.bgBtn:onClick(self, self.bgBtnCB)
	self._layout.vars.haveApply:hide()
	
	
	self._layout.vars.disband:onClick(self, self.disbandTeam)
	if self._isHaveApplyInfo then
		self:updateApplyInfo()
	else
		self:updateTeamList(leaderId, teamMembers)
	end
end


function wnd_myTeam:refreshCB(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	if self._state==1 then
		
	elseif self._state==2 then
		local nearPlayer = i3k_sbean.team_mapr_req.new()
		nearPlayer.from = 1
		i3k_game_send_str_cmd(nearPlayer, i3k_sbean.team_mapr_res.getName())
	else
		
	end
end

function wnd_myTeam:myTeamPage(sender)
	self._state = 1
	for i,v in pairs(self._tabBar) do
		if i==1 then
			v:stateToPressed(true)
			v:setTouchEnabled(false)
		else
			v:stateToNormal(true)
			v:setTouchEnabled(true)
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	self:updateTeamList(self._leaderId or g_i3k_game_context:GetTeamLeader(), self._members or g_i3k_game_context:GetAllTeamMembers())
	
	self._layout.vars.teamInfo:show()
	self._layout.vars.fujin:hide()
end

function wnd_myTeam:applyInfoPage(sender)
	self:updateApplyInfo()
end

function wnd_myTeam:aroundPlayerCB(sender)
	self._state =2
	for i,v in pairs(self._tabBar) do
		if i==2 then
			v:stateToPressed(true)
			v:setTouchEnabled(false)
		else
			v:stateToNormal(true)
			v:setTouchEnabled(true)
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	local teamInfo = self._layout.vars.teamInfo
	if teamInfo then
		teamInfo:hide()
	end
	local fujin = self._layout.vars.fujin
	if fujin then
		fujin:show()
	end
	local nearPlayer = i3k_sbean.team_mapr_req.new()
	nearPlayer.from = 1
	i3k_game_send_str_cmd(nearPlayer, i3k_sbean.team_mapr_res.getName())
end

--[[function wnd_myTeam:closeUI(sender)
	local wjxx = g_i3k_ui_mgr:GetUI(eUIID_Wjxx)
	if wjxx then
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_MyTeam)
end--]]

function wnd_myTeam:disbandTeam(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	local disband = i3k_sbean.team_dissolve_req.new()
	i3k_game_send_str_cmd(disband, i3k_sbean.team_dissolve_res.getName())
end

function wnd_myTeam:quitTeamCB(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	
	local leave = i3k_sbean.team_leave_req.new()
	i3k_game_send_str_cmd(leave, i3k_sbean.team_leave_res.getName())
end

function wnd_myTeam:playerOpreation(sender,overview)
	local targetId = sender:getTag()-1000
	local senderPos = sender:getPosition()
	local width = sender:getContentSize().width
	local pos = sender:convertToWorldSpace(cc.p(senderPos.x+width/2, senderPos.y*1.8))
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	g_i3k_game_context:SetSelectedRoleData(overview)
	g_i3k_ui_mgr:OpenUI(eUIID_Wjxx)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Wjxx, "popupTeamMemberMenu", pos, self._isLeader, targetId, overview.name)
end

function wnd_myTeam:addPlayerToTeam(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends,1)
--[[	local desc = string.format("功能正在开发中，敬请期待！")
	g_i3k_ui_mgr:ShowMessageBox1(desc)--]]
end

function wnd_myTeam:inviteToTeam(sender)
	local roleId = sender:getTag()-1000
	i3k_sbean.invite_role_join_team(roleId)
end

function wnd_myTeam:agreeCB(sender)
	local tag = sender:getTag()-1000
	self:applyHandler(tag)
	local isAccept = i3k_sbean.team_appliedby_req.new()
	isAccept.roleId = tag
	isAccept.accept = 1
	i3k_game_send_str_cmd(isAccept, i3k_sbean.team_appliedby_res.getName())
	self:updateApplyInfo()
end

function wnd_myTeam:refuseCB(sender)
	local tag = sender:getTag()-10000
	self:applyHandler(tag)
	local isAccept = i3k_sbean.team_appliedby_req.new()
	isAccept.roleId = tag
	isAccept.accept = 0
	i3k_game_send_str_cmd(isAccept, i3k_sbean.team_appliedby_res.getName())
	self:updateApplyInfo()
end

function wnd_myTeam:bgBtnCB(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end



function wnd_myTeam:applyHandler(id)
	local applyRoleTable = g_i3k_game_context:GetIsHaveReqForTeam()
--[[	for i,v in pairs(applyRoleTable) do
		if v.id==id then
			table.remove(applyRoleTable, i)
		end
	end--]]
	for i=#applyRoleTable,1,-1 do
		if applyRoleTable[i].id==id then
			table.remove(applyRoleTable, i)
		end	
	end
	if #applyRoleTable==0 then
		g_i3k_game_context:SetIsHaveReqForTeam(nil)
	else
		g_i3k_game_context:SetIsHaveReqForTeam(applyRoleTable)
	end
end

function wnd_myTeam:updateTeamList(leaderId, members)
	self._leaderId = leaderId
	self._members = members
	local count = 0
	
	for i,v in pairs(members) do
		count = count+1
	end
	
	local roleInfo = g_i3k_game_context:GetRoleInfo()
	local roleId = roleInfo.curChar._id
	
	for i,v in pairs(self._widgets.teamPlayers.root) do
		v:setImage("dw#dw_d1.png")
		v:hide()
	end
	if count == 0 then
		count = 1
	end
	for i=1,count do
		self._widgets.teamPlayers.root[i]:show()
	end
	for i=count,#self._widgets.addPlayer.root do
		if self._widgets.addPlayer.root[i] then
			self._widgets.addPlayer.root[i]:show()
		end
	end
	
	
	
	local index = 1
	for i,v in pairs(members) do
		local id = v.overview.id
		if id==leaderId then
			self._widgets.teamPlayers.iconType[index]:setImage(g_i3k_get_head_bg_path(v.overview.bwType, v.overview.headBorder))
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.overview.headIcon,g_i3k_db.eHeadShapeQuadrate);
			if hicon and hicon > 0 then
				self._widgets.teamPlayers.icon[index]:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
			end
			
			self._widgets.teamPlayers.zhiye[index]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.overview.type].classImg))
			self._widgets.teamPlayers.btn[index]:setTag(id+1000)
			
			local applyInfoBtn = self._layout.vars.applyInfoBtn
			local disband = self._layout.vars.disband
			if id==roleId then
				applyInfoBtn:show()
				applyInfoBtn:onClick(self, self.applyInfoPage)
				disband:show()
				self._widgets.teamPlayers.btn[index]:onClick(self, self.bgBtnCB)
				self._isLeader = true
			else
				disband:hide()
				applyInfoBtn:hide()
				self._isLeader = false
				self._widgets.teamPlayers.btn[index]:onClick(self, self.playerOpreation,v.overview)
			end
			self._widgets.teamPlayers.level[index]:setText(v.overview.level)
			self._widgets.teamPlayers.name[index]:setText(v.overview.name)
			self._widgets.teamPlayers.powerLabel[index]:setText(v.overview.fightPower)
			if id==roleId then
				self._widgets.teamPlayers.root[index]:setImage("dw#dw_d2.png")
			end
			index = index + 1
		end
	end
	for i,v in pairs(members) do
		local id = v.overview.id
		if id~=leaderId then
			self._widgets.teamPlayers.iconType[index]:setImage(g_i3k_get_head_bg_path(v.overview.bwType, v.overview.headBorder))
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.overview.headIcon,g_i3k_db.eHeadShapeQuadrate);
			if hicon and hicon > 0 then
				self._widgets.teamPlayers.icon[index]:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
			end
			
			self._widgets.teamPlayers.zhiye[index]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.overview.type].classImg))
			self._widgets.teamPlayers.btn[index]:setTag(id+1000)
			if id==roleId then
				self._widgets.teamPlayers.btn[index]:onClick(self, self.bgBtnCB)
			else
				self._widgets.teamPlayers.btn[index]:onClick(self, self.playerOpreation,v.overview)
			end
			self._widgets.teamPlayers.level[index]:setText(v.overview.level)
			self._widgets.teamPlayers.name[index]:setText(v.overview.name)
			self._widgets.teamPlayers.powerLabel[index]:setText(v.overview.fightPower)
			if id==roleId then
				self._widgets.teamPlayers.root[index]:setImage("dw#dw_d2.png")
			end
			index = index + 1
		end
	end
	
end

function wnd_myTeam:updateApplyInfo()
	self._layout.vars.haveApply:hide()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "setTeamBtnAnis", false)
	self._state = 3
	for i,v in pairs(self._tabBar) do
		if i==3 then
			v:stateToPressed(true)
			v:setTouchEnabled(false)
		else
			v:stateToNormal(true)
			v:setTouchEnabled(true)
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	local teamInfo = self._layout.vars.teamInfo
	if teamInfo then
		teamInfo:hide()
	end
	local fujin = self._layout.vars.fujin
	if fujin then
		fujin:show()
	end
	
	local noApply = self._layout.vars.noApply
	
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local applyInfo = g_i3k_game_context:GetIsHaveReqForTeam()
	if applyInfo then
		noApply:hide()
		for i=1, #applyInfo do
			local applyer = require("ui/widgets/sqzdt")()
			applyer.vars.name_label:setText(applyInfo[i].name)
			applyer.vars.iconType:setImage(g_i3k_get_head_bg_path(applyInfo[i].bwType, applyInfo[i].headBorder))
			applyer.vars.level_label:setText(string.format("%d级", applyInfo[i].level))
			applyer.vars.power_label:setText("战斗力"..applyInfo[i].fightPower)
			applyer.vars.cancelLabel:setText("拒绝")
			applyer.vars.okLabel:setText("同意")
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(applyInfo[i].headIcon,g_i3k_db.eHeadShapeQuadrate);
			if hicon and hicon > 0 then
				applyer.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
			end
			
			applyer.vars.invite_btn:setTag(applyInfo[i].id+1000)
			applyer.vars.invite_btn:onClick(self, self.agreeCB)
			applyer.vars.talk_btn:setTag(applyInfo[i].id+10000)
			applyer.vars.talk_btn:onClick(self, self.refuseCB)
			scroll:addItem(applyer)
			
		end
	else
		noApply:show()
	end
end

function wnd_myTeam:updateNearPlayer(roles)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local noApply = self._layout.vars.noApply
	if noApply then noApply:hide() end
	for i=1,#roles do
		local fjwj = require("ui/widgets/sqzdt")()
		fjwj.vars.name_label:setText(roles[i].name)
		fjwj.vars.iconType:setImage(g_i3k_get_head_bg_path(roles[i].bwType, roles[i].headBorder))
		fjwj.vars.level_label:setText(string.format("%d级", roles[i].level))
		fjwj.vars.power_label:setText("战斗力"..roles[i].fightPower)
		fjwj.vars.cancelLabel:setText("交谈")
		fjwj.vars.talk_btn:hide()
		fjwj.vars.cancelLabel:hide()
		fjwj.vars.okLabel:setText("邀请入队")
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(roles[i].headIcon,g_i3k_db.eHeadShapeQuadrate);
		if hicon and hicon > 0 then
			fjwj.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		
		fjwj.vars.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[roles[i].type].classImg))
		fjwj.vars.invite_btn:setTag(roles[i].id+1000)
		fjwj.vars.invite_btn:onClick(self, self.inviteToTeam)
		scroll:addItem(fjwj)
	end
end



function wnd_myTeam:setApplyRed(isShow)
	if self._state==3 then
		isShow = false
		self:updateApplyInfo()
	end
	self._layout.vars.haveApply:setVisible(isShow)
end


function wnd_create(layout, ...)
	local wnd = wnd_myTeam.new();
	wnd:create(layout, ...);
	
	return wnd;
end
