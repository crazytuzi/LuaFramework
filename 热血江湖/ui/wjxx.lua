-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_wjxx = i3k_class("wnd_wjxx", ui.wnd_base)

function wnd_wjxx:ctor()
	self._widgets = {}
end

function wnd_wjxx:configure()
	self._rootView = self._layout.vars.rootView
	self._scroll = self._layout.vars.scroll
	self._scroll2 = self._layout.vars.scroll2
end

function wnd_wjxx:onShow()
	self._scroll:setBounceEnabled(false)
	self._scroll2:setBounceEnabled(false)
end

function wnd_wjxx:onHide()

end

function wnd_wjxx:closeUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:kickPlayer(sender)
	local memberId = sender:getTag()
	local kick = i3k_sbean.team_kick_req.new()
	kick.roleId = memberId
	i3k_game_send_str_cmd(kick, i3k_sbean.team_kick_res.getName())
end

function wnd_wjxx:letItLeader(sender)
	local memberId = sender:getTag()
	local changeLeader = i3k_sbean.team_change_leader_req.new()
	changeLeader.roleId = memberId
	i3k_game_send_str_cmd(changeLeader, i3k_sbean.team_change_leader_res.getName())
end

function wnd_wjxx:inviteToTeam(sender)
	local roleId = sender:getTag()
	i3k_sbean.invite_role_join_team(roleId)
end

function wnd_wjxx:applyToTeam(sender)
	local targetTeamId = sender:getTag()
	local apply = i3k_sbean.team_apply_req.new()
	apply.teamId = targetTeamId
	i3k_game_send_str_cmd(apply, i3k_sbean.team_apply_res.getName())
end

function wnd_wjxx:priviteChat(sender)
	--local roleId = sender:getTag()
	local data = g_i3k_game_context:GetSelectedRoleData()
	if data then
	local player = {}
	player.msgType = global_recent
	player.name = data.name
	player.id = data.id
	player.level = data.level
	player.iconId = data.headIcon
	player.bwType = data.bwType
	player.headBorder = data.headBorder

	g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat, player)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	end
end

function wnd_wjxx:check(sender)
	local roleId = sender:getTag()
	i3k_sbean.query_rolefeature(roleId)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:toTheAim(sender)
	local roleId = sender:getTag()
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:gotoHomeland(sender)
	local roleId = sender:getTag()
	g_i3k_game_context:gotoPlayerHomeLand(roleId)
end

function wnd_wjxx:addFriends(sender)
	local roleId = sender:getTag()
	i3k_sbean.addFriend(roleId)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function  wnd_wjxx:deleteFriends(sender)
	local roleId = sender:getTag()
	i3k_sbean.deleteFriend(roleId)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:giveFlowers(sender)
	local data = g_i3k_game_context:GetSelectedRoleData()
	if data then
	local player = {id = data.id, name = data.name,  level = data.level, iconId = data.headIcon, bwType = data.bwType, headBorder = data.headBorder}
	g_i3k_logic:OpenSendFlowerUI(player)
	self:onCloseUI()
	end
end

function wnd_wjxx:useShowLoveItem(sender, roleID)
	g_i3k_logic:openShowLoveItemUI(roleID)
end

function wnd_wjxx:openMoodDiary(sender)
	local data = g_i3k_game_context:GetSelectedRoleData()
	if data then
	i3k_sbean.mood_diary_open_main_page(2, data.id)
	end
end

function wnd_wjxx:inviteRide(sender) --邀请骑乘协议
	if not g_i3k_game_context:IsOnMulRide() then
		g_i3k_ui_mgr:PopupTipMessage("您当前没有骑乘多人坐骑")
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		return
	end
	local roleID = sender:getTag()
	i3k_sbean.mulhorse_invite(roleID)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end
function wnd_wjxx:toBlack(sender) --加入黑名单
	local roleID = sender:getTag()
	i3k_sbean.addBlackFriend(roleID)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

-- 踢出家园
function wnd_wjxx:kickOut(sender)
	local roleId = sender:getTag()
	g_i3k_logic:kickOut(roleId, function()
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	end)
end

function wnd_wjxx:applyRide(sender) --申请骑乘协议
	local tips
	if g_i3k_game_context:IsAutoFight() then
		tips = 669
	elseif g_i3k_game_context:IsInFightTime() then
		tips = 670
	elseif g_i3k_game_context:IsInRoom() then
		tips = 671
	elseif g_i3k_game_context:IsOnRide() then
		tips = 741
	elseif g_i3k_game_context:IsInSuperMode() then
		tips = 17051
	elseif g_i3k_game_context:GetIsSpringWorld() then
		tips = 17052
	elseif g_i3k_game_context:IsInMetamorphosisMode() then
		tips = 1567
	end
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(tips))
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		return
	end
	local roleID = sender:getTag()
	i3k_sbean.mulhorse_apply(roleID)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:giveItem(sender, data)
	local items = g_i3k_db.i3k_db_get_can_giveItem()
	if #items ~= 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		g_i3k_ui_mgr:OpenUI(eUIID_GiveItem)
		g_i3k_ui_mgr:RefreshUI(eUIID_GiveItem, data.roleId, data.name)
	else
		g_i3k_ui_mgr:PopupTipMessage("当前背包没有任何物品可以赠送")
	end

end

-- 点击“收徒”按钮
function wnd_wjxx:onClickEnrollApprtc(sender,roleId)
	-- 向徒弟发收徒申请
	i3k_sbean.master_send_enroll_apt_request(roleId)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

-- 点击“拜师”按钮
function wnd_wjxx:onClickApplyMaster(sender,roleId)
	-- 向师傅发拜师申请
	if g_i3k_game_context:IsApprtcApplyEnrollCooling(roleId) then
		-- 冷却中
		g_i3k_ui_mgr:PopupTipMessage("您的申请行为过于频繁，请稍后再试。")
	else
		i3k_sbean.master_request_master(roleId,"HEADICON_UI")
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:onHug(sender, roleGender)
	local tips
	local escort_taskId = g_i3k_game_context:GetFactionEscortTaskId()
	local roleID = sender:getTag()
	local world = i3k_game_get_world();
	local mapInfo = g_i3k_game_context:getTreasureMapInfo()
	if g_i3k_game_context:GetLevel() < i3k_db_common.hugMode.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17055, i3k_db_common.hugMode.openLvl))
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		return
	end
	if escort_taskId ~= 0 then
		tips = 17041
	elseif g_i3k_game_context:IsInFightTime() then
		tips = 17042
	elseif g_i3k_game_context:IsAutoFight() then
		tips = 17043
	elseif g_i3k_game_context:IsOnRide() then
		tips = 17044
	elseif not g_i3k_game_context:GetFriendsDataByID(roleID) then
		tips = 17045
	elseif g_i3k_game_context:IsInSuperMode() then
		tips = 17046
	elseif (mapInfo and mapInfo.open~=0) then
		tips = 17047
	elseif g_i3k_game_context:GetIsSpringWorld() then
		tips = 17048
	elseif g_i3k_game_context:IsInRoom() then
		tips = 17049
	elseif g_i3k_game_context:IsInMissionMode() then
		if g_i3k_game_context:IsInMetamorphosisMode() then
			tips = 1569
		else
		tips = 17056
		end
	elseif g_i3k_game_context:GetHomeLandFishStatus() then
		tips = 5149
	end
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(tips))
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
		return
	end
	i3k_sbean.staywith_invite(roleID)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
end

function wnd_wjxx:inviteFaction(sender) --邀请入帮协议
	local roleID = sender:getTag()
	i3k_sbean.invite_faction(roleID)
	self:onCloseUI()
end

function wnd_wjxx:giveLuckyStar(sender, name)
	local roleID = sender:getTag()
	i3k_sbean.lucklystar_gift_req_send(roleID, name)
end

function wnd_wjxx:updateNotLeaderUI(viewPos, roleId, name)
	local size = self._rootView:getContentSize()
	local factionId = g_i3k_game_context:GetFactionSectId()
	local height = 0
	for i=1,7 do
		local is_add = true
		local root
		if i==1 then
			root = require("ui/widgets/an")()
		elseif i==6 then
			root = require("ui/widgets/an3")()
		else
			root = require("ui/widgets/an2")()
		end
		local btn = root.vars.btn
		local btnName = root.vars.btnName
		btn:setTag(roleId)
		if i==1 then
			local value = g_i3k_game_context:GetFriendsDataByID(roleId)
			if value == nil then
				btn:onClick(self, self.addFriends)
				btnName:setText("加为好友")
			else
				btn:onClick(self, self.deleteFriends)
				btnName:setText("删除好友")
			end
		elseif i==2 then
			btn:onClick(self, self.priviteChat)
			btnName:setText("私聊")
		elseif i==3 then
			btn:onClick(self, self.check)
			btnName:setText("查看")
		elseif i == 4 then
			if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
				is_add = false
			else
				btn:onClick(self, self.giveFlowers)
				btnName:setText("赠花")
			end
		elseif i == 5 then
			local myPos = g_i3k_game_context:GetSectPosition() or 0
			if factionId ~= 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
				btn:onClick(self, self.inviteFaction)
				btnName:setText("邀请入帮")
			else
				is_add = false
			end
		elseif i == 6 then
			if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
				is_add = false
			else
				btn:onClick(self, self.giveItem, {roleId = roleId, name = name})
				btnName:setText("赠送")
			end
		elseif i == 7 then
			btn:onClick(self, self.toBlack)
			btnName:setText("加黑名单")
		elseif i == 8 then
			btn:onClick(self, self.toTheAim)
			btnName:setText("寻径至目标")
		end
		if is_add then
			self._scroll:addItem(root)
			height = height + root.rootVar:getSizeInScroll(self._scroll).height
		end
	end
	self._rootView:setContentSize(size.width,height+10)
	self._scroll:setContentSize(size.width, height+10)
	self._scroll:setContainerSize(size.width, height+10)
	self._scroll:update()
	local child = self._scroll:getChildAtIndex(1)
	local pos = child.rootVar:getPositionInScroll(self._scroll)
	self._rootView:setAnchorPoint(0, pos.y/(height+10))
	self._rootView:setPosition(viewPos)
end

function wnd_wjxx:updateLeaderUI(viewPos, roleId, name)
	local size = self._rootView:getContentSize()
	local factionId = g_i3k_game_context:GetFactionSectId()
	local height = 0
	for i=1,9 do
		local is_add = true
		local root
		if i==1 then
			root = require("ui/widgets/an")()
		elseif i==8 then
			root = require("ui/widgets/an3")()
		else
			root = require("ui/widgets/an2")()
		end
		local btn = root.vars.btn
		local btnName = root.vars.btnName
		btn:setTag(roleId)
		if i==1 then
			btn:onClick(self, self.kickPlayer)
			btnName:setText("踢出队员")
		elseif i==2 then
			btn:onClick(self, self.letItLeader)
			btnName:setText("升为队长")
		elseif i==3 then
			local value = g_i3k_game_context:GetFriendsDataByID(roleId)
			if value == nil then
				btn:onClick(self, self.addFriends)
				btnName:setText("加为好友")
			else
				btn:onClick(self, self.deleteFriends)
				btnName:setText("删除好友")
			end
		elseif i==4 then
			btn:onClick(self, self.priviteChat)
			btnName:setText("私聊")
		elseif i==5 then
			btn:onClick(self, self.check)
			btnName:setText("查看")
		elseif i == 6 then
			if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
				is_add = false
			else
				btn:onClick(self, self.giveFlowers)
				btnName:setText("赠花")
			end
		elseif i == 7 then
			local myPos = g_i3k_game_context:GetSectPosition() or 0
			if factionId ~= 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
				btn:onClick(self, self.inviteFaction)
				btnName:setText("邀请入帮")
			else
				is_add = false
			end
		elseif i == 8 then
			if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
				is_add = false
			else
				btn:onClick(self, self.giveItem, {roleId = roleId, name = name})
				btnName:setText("赠送")
			end
		elseif i == 9 then
			btn:onClick(self, self.toBlack)
			btnName:setText("加黑名单")
		elseif i == 10 then
			btn:onClick(self, self.toTheAim)
			btnName:setText("寻径至目标")
		end
		if is_add then
			self._scroll:addItem(root)
			height = height + root.rootVar:getSizeInScroll(self._scroll).height
		end
	end

	self._rootView:setContentSize(size.width, height+10)
	self._scroll:setContentSize(size.width, height+10)
	self._scroll:setContainerSize(size.width, height+10)
	self._scroll:update()
	local child = self._scroll:getChildAtIndex(1)
	local pos = child.rootVar:getPositionInScroll(self._scroll)
	self._rootView:setAnchorPoint(0, pos.y/(height+10))
	self._rootView:setPosition(viewPos)
end

function wnd_wjxx:popupTeamMemberMenu(pos, isLeader, roleId, name)
	if isLeader then
		self:updateLeaderUI(pos, roleId, name)
	else
		self:updateNotLeaderUI(pos, roleId, name)
	end
end

function wnd_wjxx:popupClickBossIcon(teamId, viewPos, roleId, isMulHorse,sectID, gender, name, level)
	local heights = {0, 0, 0}
	self._scroll:removeAllChildren()
	self._scroll2:removeAllChildren()
	local factionId = g_i3k_game_context:GetFactionSectId()
	local myTeamId = g_i3k_game_context:GetTeamId()
	local roleGender = g_i3k_game_context:GetRoleGender()
	local size = self._rootView:getContentSize()
	local addCount = 0
	if myTeamId~=0 then
		local roleInfo = g_i3k_game_context:GetRoleInfo()
		local myId = roleInfo.curChar._id

		--代表是队长并且对方没有队伍
		for i=1,16 do
			local is_add = true
			local root
			if i==1 then
				root = require("ui/widgets/an")()
			elseif i==7 or i == 8 then
				root = require("ui/widgets/an3")()
			else
				root = require("ui/widgets/an2")()
			end
			local btn = root.vars.btn
			btn:setTag(roleId)
			local btnName = root.vars.btnName
			if i==1 then
				btn:onClick(self, self.check)
				btnName:setText("查看资料")
			elseif i==2 then
				btn:onClick(self, self.inviteToTeam)
				btnName:setText("邀请入队")
				local leaderId = g_i3k_game_context:GetTeamLeader()
				if leaderId==myId then

				else
					btn:disableWithChildren()
				end
			elseif i == 3 then
				btn:onClick(self, self.onHug, roleGender)
				btnName:setText("相依相偎")
				local world = i3k_game_get_world()
				if (gender == roleGender and gender == 1) or  world._mapType ~= g_FIELD then
					is_add = false
				end
			elseif i == 4 then
				local value = g_i3k_game_context:GetFriendsDataByID(roleId)
				if value == nil then
					btn:onClick(self, self.addFriends)
					btnName:setText("加为好友")
				else
					btn:onClick(self, self.deleteFriends)
					btnName:setText("删除好友")
				end
			elseif i == 5 then
				btn:onClick(self, self.priviteChat)
				btnName:setText("私聊")
			elseif i == 6 then
				if i3k_game_get_map_type() == g_FIELD and g_i3k_game_context:GetWorldMapID() ~= i3k_db_spring.common.mapId then
					btn:onClick(self, self.giveFlowers)
					btnName:setText("赠花")
				else
					is_add = false
				end
			elseif i == 7 then
				local myPos = g_i3k_game_context:GetSectPosition() or 0
				if factionId ~= 0 and sectID == 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
					btn:onClick(self, self.inviteFaction)
					btnName:setText("邀请入帮")
				else
					is_add = false
				end
			elseif i == 8 then
				if g_i3k_game_context:GetIsSpringWorld() then
					is_add = false
				else
					if isMulHorse then
						btn:onClick(self, self.applyRide)
						btnName:setText("申请骑乘")
					else
						btn:onClick(self, self.inviteRide)
						btnName:setText("邀请骑乘")
						if not g_i3k_game_context:GetMulIsLeader() then
							is_add = false
						end
					end
				end
			elseif i == 9 then
				if i3k_game_get_map_type() ~= g_FIELD or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
					is_add = false
				else
					btn:onClick(self, self.giveItem, {roleId = roleId, name = name})
					btnName:setText("赠送")
				end
			elseif i == 10 then
				btn:onClick(self, self.toBlack)
				btnName:setText("加黑名单")
			elseif i == 11 then
				local lkData = g_i3k_game_context:GetLuckyStarData()
				if lkData.dayRecvTimes <= 0 or lkData.lastGiftTimes <= 0 or i3k_game_get_map_type() ~= g_FIELD then
					is_add = false
				end
				btn:onClick(self, self.giveLuckyStar, name)
				btnName:setText("幸运星")
			elseif i == 12 then
				-- liping, 拜师收徒按钮
				local cfg = i3k_db_master_cfg.cfg
				if g_i3k_game_context:CanMasterEnrollByBrief() then
					-- 收徒
					if level>=cfg.apptc_min_lvl and level<=cfg.apptc_max_lvl then
						btnName:setText("收徒")
						btn:onClick(self,self.onClickEnrollApprtc,roleId)
					else
						is_add = false
					end
				elseif g_i3k_game_context:CanApplyMasterByBrief() then
					-- 拜师
					if level>=cfg.master_min_lvl then
						btnName:setText("拜师")
						btn:onClick(self,self.onClickApplyMaster,roleId)
					else
						is_add = false
					end
				else
					is_add = false
				end
			elseif i == 13 then
				--切磋
				is_add = false
				if i3k_game_get_map_type() == g_FIELD and level >= i3k_db_common.qiecuo.startLevel and g_i3k_game_context:GetLevel() >= i3k_db_common.qiecuo.startLevel and g_i3k_game_context:GetWorldMapID() ~= i3k_db_spring.common.mapId then
					is_add = true
					btnName:setText("切磋")
					btn:onClick(self, function ()
						i3k_sbean.request_role_single_invite_req(roleId)
					end)
				end
			elseif i == 14 then
				-- 示爱道具
				is_add = false
				local curMapID = g_i3k_game_context:GetWorldMapID()
				if g_i3k_db.i3k_db_check_show_love_item_mapID(curMapID) then
					btnName:setText("示爱")
					btn:onClick(self,self.useShowLoveItem, roleId)
					is_add = true
				end
			elseif i == 15 then
				-- 心情日记
				is_add = false
				if level >= i3k_db_mood_diary_cfg.openLevel then
					btnName:setText("心情日记")
					btn:onClick(self,self.openMoodDiary)
					is_add = true
				end
			elseif i == 16 then 
				if i3k_game_get_map_type() == g_FIELD then 
					btnName:setText("拜访家园")
					btn:onClick(self,self.gotoHomeland)
					is_add = true
				else 
					is_add = false
				end
			end
			if is_add then
				self:addToScroll(addCount, heights, root)
				addCount = addCount + 1
			end
		end
	else
		local isInHomeLand = g_i3k_game_context:GetIsInHomeLandZone()
		for i=1,17 do
			local is_add = true
			local root
			if i==1 then
				root = require("ui/widgets/an")()
			elseif i==7 or i == 8 then
				root = require("ui/widgets/an3")()
			else
				root = require("ui/widgets/an2")()
			end
			local btn = root.vars.btn
			btn:setTag(roleId)
			local btnName = root.vars.btnName
			if i==1 then
				btn:onClick(self, self.check)
				btnName:setText("查看资料")
			elseif i==2 then
				if teamId==0 then
					btn:onClick(self, self.inviteToTeam)
					btnName:setText("邀请组队")
				else
					btn:onClick(self, self.applyToTeam)
					btn:setTag(teamId)
					btnName:setText("申请入队")
				end
			elseif i == 3 then
				btn:onClick(self, self.onHug, roleGender)
				btnName:setText("相依相偎")
				local world = i3k_game_get_world()
				if (gender == roleGender and gender == 1) or (world._mapType ~= g_FIELD and not isInHomeLand and  world._mapType ~= g_HOMELAND_HOUSE) then
					is_add = false
				end
			elseif i == 4 then
				if i3k_game_get_map_type() ~= g_FIELD or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
					is_add = false
				else
					btn:onClick(self, self.giveFlowers)
					btnName:setText("赠花")
				end
			elseif i==5 then
				local value = g_i3k_game_context:GetFriendsDataByID(roleId)
				if value == nil then
					btn:onClick(self, self.addFriends)
					btnName:setText("加为好友")
				else
					btn:onClick(self, self.deleteFriends)
					btnName:setText("删除好友")
				end
			elseif i == 6 then
				btn:onClick(self, self.priviteChat)
				btnName:setText("私聊")
			elseif i == 7 then
				local myPos = g_i3k_game_context:GetSectPosition() or 0
				if factionId ~= 0 and sectID == 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
					btn:onClick(self, self.inviteFaction)
					btnName:setText("邀请入帮")
				else
					is_add = false
				end
			elseif i == 8 then
				if g_i3k_game_context:GetIsSpringWorld() then
					is_add = false
				else
					if isMulHorse then
						btn:onClick(self, self.applyRide)
						btnName:setText("申请骑乘")
					else
						btn:onClick(self, self.inviteRide)
						btnName:setText("邀请骑乘")
						if not g_i3k_game_context:GetMulIsLeader() then
							is_add = false
						end
					end
				end
			elseif i == 9 then
				if (i3k_game_get_map_type() ~= g_FIELD and not isInHomeLand) or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
					is_add = false
				else
					btn:onClick(self, self.giveItem, {roleId = roleId, name = name})
					btnName:setText("赠送")
				end
			elseif i == 10 then
				btn:onClick(self, self.toBlack)
				btnName:setText("加黑名单")
			elseif i == 11 then
				local lkData = g_i3k_game_context:GetLuckyStarData()
				if lkData.dayRecvTimes <= 0 or lkData.lastGiftTimes <= 0 or i3k_game_get_map_type() ~= g_FIELD then
					is_add = false
				end
				btn:onClick(self, self.giveLuckyStar, name)
				btnName:setText("幸运星")
			elseif i == 12 then
				-- liping, 拜师收徒按钮
				local cfg = i3k_db_master_cfg.cfg
				if g_i3k_game_context:CanMasterEnrollByBrief() then
					-- 收徒
					if level>=cfg.apptc_min_lvl and level<=cfg.apptc_max_lvl then
						btnName:setText("收徒")
						btn:onClick(self,self.onClickEnrollApprtc,roleId)
					else
						is_add = false
					end
				elseif g_i3k_game_context:CanApplyMasterByBrief() then
					-- 拜师
					if level>=cfg.master_min_lvl then
						btnName:setText("拜师")
						btn:onClick(self,self.onClickApplyMaster,roleId)
					else
						is_add = false
					end
				else
					is_add = false
				end
			elseif i == 13 then
				--切磋
				is_add = false
				if i3k_game_get_map_type() == g_FIELD and level >= i3k_db_common.qiecuo.startLevel and g_i3k_game_context:GetLevel() >= i3k_db_common.qiecuo.startLevel and g_i3k_game_context:GetWorldMapID() ~= i3k_db_spring.common.mapId then
					is_add = true
					btnName:setText("切磋")
					btn:onClick(self, function ()
						i3k_sbean.request_role_single_invite_req(roleId)
					end)
				end
			elseif i == 14 then
				-- 示爱道具
				is_add = false
				local curMapID = g_i3k_game_context:GetWorldMapID()
				if g_i3k_db.i3k_db_check_show_love_item_mapID(curMapID) then
					btnName:setText("示爱")
					btn:onClick(self,self.useShowLoveItem, roleId)
					is_add = true
				end
			elseif i == 15 then
				-- 心情日记
				is_add = false
				if level >= i3k_db_mood_diary_cfg.openLevel then
					btnName:setText("心情日记")
					btn:onClick(self,self.openMoodDiary)
					is_add = true
				end
			elseif i == 16 then 
				if g_i3k_game_context:isInMyHomeLand() then 
					btnName:setText("请离")
					btn:onClick(self,self.kickOut)
					is_add = true
				else 
					is_add = false 
				end
			elseif i == 17 then 
				if i3k_game_get_map_type() == g_FIELD then 
					btnName:setText("拜访家园")
					btn:onClick(self,self.gotoHomeland)
					is_add = true
				else 
					is_add = false
				end
			end
			if is_add then
				self:addToScroll(addCount, heights, root)
				addCount = addCount + 1
			end
		end
	end
	self._rootView:setContentSize(size.width, heights[1] + 10)
	self._scroll:setContentSize(size.width, heights[1] + 10)
	self._scroll:setContainerSize(size.width, heights[1] + 10)
	self._scroll:update()
	-- self._scroll2:setContentSize(size.width, height+10)
	self._scroll2:setContainerSize(size.width, heights[2] + 10)
	self._scroll2:update()
	local child = self._scroll:getChildAtIndex(1)
	local pos = child.rootVar:getPositionInScroll(self._scroll)
	self._rootView:setAnchorPoint(0, pos.y/(heights[1] + 10))
	self._rootView:setPosition(viewPos)
end

function wnd_wjxx:addToScroll(count, heights, root)
	local scroll
	if count > 9 then 
		scroll = self._scroll2
		scroll:addItem(root)
		heights[2] = heights[2] + root.rootVar:getSizeInScroll(scroll).height
	else 
		scroll = self._scroll
		scroll:addItem(root)
		heights[1] = heights[1] + root.rootVar:getSizeInScroll(scroll).height
	end
end 

--通用的弹出逻辑
function wnd_wjxx:popMenuList(needPos, funcs)
	local max = 1
	for i,v in pairs(funcs) do
		max = i>max and i or max
	end
	self._scroll:removeAllChildren(true)
	self._scroll2:removeAllChildren(true)
	local height = 0
	local size = self._rootView:getContentSize()
	for i,v in pairs(funcs) do
		local root
		if i==1 then
			root = require("ui/widgets/an")()
		elseif i==max then
			root = require("ui/widgets/an3")()
		else
			root = require("ui/widgets/an2")()
		end
		local btn = root.vars.btn
		btn:setTag(v.roleId)
		btn:onClick(self, v.callback)
		root.vars.btnName:setText(v.name)
		self._scroll:addItem(root)
		height = height + root.rootVar:getSizeInScroll(self._scroll).height
	end
	self._rootView:setContentSize(size.width, height+10)
	self._scroll:setContentSize(size.width, height+10)
	self._scroll:setContainerSize(size.width, height+10)
	self._scroll:update()
	local child = self._scroll:getChildAtIndex(1)
	local pos = child.rootVar:getPositionInScroll(self._scroll)
	self._rootView:setAnchorPoint(0, pos.y/(height+10))
	self._rootView:setPosition(needPos)
end

function wnd_create(layout, ...)
	local wnd = wnd_wjxx.new();
	wnd:create(layout, ...);
	return wnd;
end
