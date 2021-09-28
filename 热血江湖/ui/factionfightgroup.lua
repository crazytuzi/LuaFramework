-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionFightGroup = i3k_class("wnd_factionFightGroup", ui.wnd_base)

function wnd_factionFightGroup:ctor()
	self._curGroupId = 0;
	self._curIndex = 0
end

function wnd_factionFightGroup:configure()
	local vars = self._layout.vars
	vars.close_btn:onClick(self,self.onClose)
	vars.member_btn:onClick(self,self.showMember)
	vars.msg_btn:onClick(self,self.showMsg)
end

function wnd_factionFightGroup:showMember()
	self._curIndex = 0;
	self._layout.vars.member_btn:stateToPressed()
	self._layout.vars.msg_btn:stateToNormal()
	self._layout.vars.factionRoot:setVisible(true)
	self._layout.vars.applyRoot:setVisible(false)
	self._layout.vars.title_name:setImage(g_i3k_db.i3k_db_get_icon_path(4029))
end

function wnd_factionFightGroup:showMsg()
	local isInGroup = g_i3k_game_context:isInFactionFightGroupById(g_i3k_game_context:GetRoleId(),self._curGroupId);

	local leaderId = g_i3k_game_context:getFactionFightGroupLeaderId(self._curGroupId)
	local isHavePower = false
	local powerIndex = g_i3k_game_context:GetRoleId() == leaderId and 1 or 2
	if i3k_db_faction_fightgroup.power[powerIndex].apply == 1 or i3k_db_faction_fightgroup.power[powerIndex].kick == 1 then
		isHavePower = true
	end
	if not isInGroup or not isHavePower then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3082)) --无权限
		return
	end
	i3k_sbean.request_sect_fight_group_apply_sync_req(self._curGroupId,function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightGroup, "updateMsgInfo")
	end)
end

function wnd_factionFightGroup:updateMsgInfo()
	self._curIndex = 1;
	self._layout.vars.title_name:setImage(g_i3k_db.i3k_db_get_icon_path(4030))
	self._layout.vars.member_btn:stateToNormal()
	self._layout.vars.msg_btn:stateToPressed()
	self._layout.vars.factionRoot:setVisible(false)
	self._layout.vars.applyRoot:setVisible(true)
end

function wnd_factionFightGroup:refresh(isDismiss)
	local data = g_i3k_game_context:getFactionFightGroupData()
	self:updateRedPoint();
	local isHaveDismissPower = self:judgePower()
	self._layout.vars.dismissBtn:setVisible(isHaveDismissPower and table.nums(data) > 0)
	
	local sortData = {}
	for k,v in pairs(data) do
		table.insert(sortData, v)
	end
	table.sort(sortData,function (a, b)
		return a.id < b.id
	end)

	local vars = self._layout.vars
	vars.member_scroll2:removeAllChildren()

	vars.groupName:setText("")
	vars.groupRank:setText("")
	vars.groupNum:setText("")
	vars.leaderName:setText("")
	vars.groupPower:setText("")
	vars.member_scroll:removeAllChildren()

	local count = 0;
	local showInfo = nil;

	for _, v in ipairs(sortData) do
		if v then
			count = count + 1

			if count == 1 and (self._curGroupId == 0 or not data[self._curGroupId]) then
				showInfo = v
				--self:showGroupInfo(v)
			end

			local _item = require("ui/widgets/bpftt1")()
			_item.vars.group:setVisible(true)
			_item.vars.create:setVisible(false)
			_item.vars.name:setText(v.name)

			_item.vars.inGroupMark:setVisible(g_i3k_game_context:isInFactionFightGroupById(g_i3k_game_context:GetRoleId(), v.id))
			_item.vars.select1_btn:setTag(v.id)
			_item.vars.select1_btn:onClick(self,function ()
				self:showGroupInfo(v)
			end)

			vars.member_scroll2:addItem(_item)
		end
	end

	local inGroupId = g_i3k_game_context:getFightGroupId()

	--上次停留的分堂
	if self._curGroupId ~= 0 and data[self._curGroupId] then
		showInfo = data[self._curGroupId]
		--self:showGroupInfo(data[self._curGroupId])
	end

	--判断所在分堂
	if inGroupId and data[inGroupId] then
		showInfo = data[inGroupId]
	end

	if showInfo then
		self:showGroupInfo(showInfo)
	end

	if count == 0 then
		if not isDismiss then
			if g_i3k_game_context:ishaveFactionFightGroupPower("fightGroupCreate") then
				g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroupCreate)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroupCreate, 1)
			else
				self:onClose()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3096))
			end
		end
	end

	--末尾添加创建按钮
	local createItem = require("ui/widgets/bpftt1")()
	createItem.vars.group:setVisible(false)
	createItem.vars.create:setVisible(true)
	createItem.vars.select1_btn:onClick(self,function ()
		
		if g_i3k_game_context:judgeInFactionFight() then
			g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
			return
		end
		
		if not g_i3k_game_context:ishaveFactionFightGroupPower("fightGroupCreate") then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3081)) --无权限创建
			return
		end

		if g_i3k_game_context:isInFactionFightGroup(g_i3k_game_context:GetRoleId()) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3083)) --已加入分堂
			return
		end

		--[[if table.nums(data) >= g_i3k_game_context:getFightGroupMaxNum() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3101))
			return
		end--]]
		if table.nums(data) >= i3k_db_faction_uplvl[#i3k_db_faction_uplvl].fightGroupCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3101))
			return
		else
			local faction_lvl = g_i3k_game_context:GetFactionLevel()
			if table.nums(data) >= i3k_db_faction_uplvl[faction_lvl].fightGroupCount then
				for k, v in ipairs(i3k_db_faction_uplvl) do
					if table.nums(data) < v.fightGroupCount then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3100,k))
						return
					end
				end
			end
		end
		
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroupCreate)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroupCreate, table.nums(data) + 1)
	end)
	vars.member_scroll2:addItem(createItem)
	if self._curIndex == 0 then
		self:showMember()
	else
		self:showMsg()
	end
end

function wnd_factionFightGroup:updateRedPoint()
	self._layout.vars.redPoint:setVisible(g_i3k_game_context:getFighGroupApplysStatus())
end

function wnd_factionFightGroup:showGroupInfo(data)
	local vars = self._layout.vars
	self._curGroupId = data.id
	vars.groupName:setText(data.name)
	vars.groupRank:setText(data.sectWarScore)
	vars.groupNum:setText(table.nums(data.member) .. "/" .. i3k_db_faction_fightgroup.common.total)

	for _, children in ipairs(vars.member_scroll2:getAllChildren()) do
		if children.vars.select1_btn:getTag() == data.id then
			children.vars.group:setImage(g_i3k_db.i3k_db_get_icon_path(4045))
		else
			children.vars.group:setImage(g_i3k_db.i3k_db_get_icon_path(4044))
		end
	end

	local leader = g_i3k_game_context:getFactionRoleDataById(data.leader)
	if leader ~= nil then
		vars.leaderName:setText(leader.role.name)
	end

	local sumPower = 0;
	vars.member_scroll:removeAllChildren()

	local addMember = function(_member)
		if _member ~= nil then
			local _item = require("ui/widgets/bpftt2")()
			_item.vars.name_label:setText(_member.role.name)
			_item.vars.state:setText(i3k_getUserState(_member.lastLogoutTime))
			_item.vars.old_contri:setText(_member.role.fightPower)
			_item.vars.job_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[_member.role.type].classImg))
			_item.vars.detail_btn:onClick(self,function ()
				g_i3k_ui_mgr:OpenUI(eUIID_FactionMemberDetail)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionMemberDetail,_member)
				--本堂堂主
				local funcs = {
					[1]={
						desc="查看属性",
						func = function ()
							i3k_sbean.query_rolefeature(_member.role.id)
							--g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionMemberDetail,'onDescBtn',_,_member.role.id)
						end
					}
				}
				if g_i3k_game_context:GetRoleId() == data.leader then
					if g_i3k_game_context:GetRoleId() ~= _member.role.id then
						--1.踢人
						--2.转让堂主
						table.insert(funcs,{
							desc="转让堂主",
							func = function ()
								if g_i3k_game_context:judgeInFactionFight() then
									g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
								else
									g_i3k_ui_mgr:ShowMessageBox2(string.format("确定将%s任命为堂主？",_member.role.name), function (ok)
										if ok then
											i3k_sbean.request_sect_fight_group_change_leader_req(data.id,_member.role.id)
										end
									end)
								end
							end
						})
						table.insert(funcs,{
							desc="踢出分堂",
							func = function ()
								if g_i3k_game_context:judgeInFactionFight() then
									g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
								else
									g_i3k_ui_mgr:ShowMessageBox2(string.format("确认将%s踢出分堂？",_member.role.name), function (ok)
										if ok then
											i3k_sbean.request_sect_fight_group_kick_req(data.id,_member.role.id)
										end
									end)
								end
							end
						})
					end
				else
					--非堂主判断其他人权限
					if g_i3k_game_context:ishaveFactionFightGroupPower("factionFightGroup") then
						table.insert(funcs,{
							desc="任命堂主",
							func = function ()
								if g_i3k_game_context:judgeInFactionFight() then
									g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
								elseif g_i3k_game_context:roleIsFactionFightGroupLeaderById(_member.role.id, data.id) ~= nil then
									g_i3k_ui_mgr:PopupTipMessage(string.format("%s已经是堂主", _member.role.name))
									return
								end
								g_i3k_ui_mgr:ShowMessageBox2(string.format("确定将%s任命为堂主？",_member.role.name), function (ok)
									if ok then
										i3k_sbean.request_sect_fight_group_change_leader_req(data.id,_member.role.id)
									end
								end)
							end
						})
					end
				end
				g_i3k_ui_mgr:InvokeUIFunction(
					eUIID_FactionMemberDetail,
					"updateBtn",
					funcs
				)
			end)
			vars.member_scroll:addItem(_item)

			sumPower = sumPower + _member.role.fightPower
		end
	end
	addMember(g_i3k_game_context:getFactionRoleDataById(data.leader))
	for id,_ in pairs(data.member) do
		if id ~= data.leader then
			addMember(g_i3k_game_context:getFactionRoleDataById(id))
		end
	end

	self:showMsgInfo()

	--全部拒绝
	vars.refuse_btn:onClick(self,function ()
		if g_i3k_game_context:judgeInFactionFight() then
			g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
		else
			i3k_sbean.request_sect_fight_group_refuse_req(data.id, data.applys)
		end
	end)

	vars.groupPower:setText(sumPower)

	if g_i3k_game_context:isInFactionFightGroupById(g_i3k_game_context:GetRoleId(),data.id) then
		vars.opt_btn_title:setText("退出")
		vars.opt_btn:onClick(self, function ()
			if g_i3k_game_context:judgeInFactionFight() then
				g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
			else
				i3k_sbean.request_sect_fight_group_exit_req(data.id)
			end
		end)
	else
		vars.opt_btn_title:setText("申请")
		vars.opt_btn:onClick(self, function ()
			if g_i3k_game_context:judgeInFactionFight() then
				g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
			elseif g_i3k_game_context:isInFactionFightGroup(g_i3k_game_context:GetRoleId()) then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3107))
			elseif g_i3k_game_context:GetLevel() < i3k_db_faction_fightgroup.common.joinLevel then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3102, i3k_db_faction_fightgroup.common.joinLevel))
			elseif  i3k_game_get_time() - g_i3k_game_context:getlastjointime() < i3k_db_faction_fightgroup.common.time then
				local time = i3k_db_faction_fightgroup.common.time - (i3k_game_get_time() - g_i3k_game_context:getlastjointime())
				local hour = math.floor(time/3600)
				local min = math.floor(time%3600/60)
				if hour == 0 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3092, min.."分钟"))
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3092, hour.."小时"..min.."分钟"))
				end
				return
			else
				i3k_sbean.request_sect_fight_group_apply_req(data.id)
			end
		end)
	end
	--解散分堂
	local isHaveDismissPower = self:judgePower()

	vars.dismissBtn:setVisible(isHaveDismissPower)

	vars.dismissBtn:onClick(self,function ()
		if g_i3k_game_context:judgeInFactionFight() then
			g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
			return
		end
		
		if not isHaveDismissPower then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3082)) --无权限
			return
		end

		if table.nums(data.member) > 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3086))
			return
		end

		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(3108), function (ok)
			if ok then
				i3k_sbean.request_sect_fight_group_dismiss_req(data.id)
			end
		end)
	end)

	--分堂改名
	vars.changeNameBtn:onClick(self,function ()
		if g_i3k_game_context:judgeInFactionFight() then
			g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
			return
		end
		if g_i3k_game_context:GetRoleId() ~= data.leader then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3082)) --无权限
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroupRename)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroupRename,data.id)
	end)
end

function wnd_factionFightGroup:showMsgInfo()
	local applys = g_i3k_game_context:getFightGroupApplysById(self._curGroupId)
	local vars = self._layout.vars
	vars.apply_scroll:removeAllChildren()
	for id,_ in pairs(applys) do
		local _member = g_i3k_game_context:getFactionRoleDataById(id)
		if _member ~= nil then
			local _item = require("ui/widgets/bpftt3")()
			_item.vars.name_label:setText(_member.role.name)
			_item.vars.power_label:setText(_member.role.fightPower)

			local apply_hicon = _item.vars.headIcon
			local member_headIcon = _member.role.headIcon
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(member_headIcon,g_i3k_db.eHeadShapeQuadrate)
			if hicon and hicon > 0 then
				apply_hicon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end
			_item.vars.roleHeadBg:setImage(g_i3k_get_head_bg_path(_member.role.bwType, _member.role.headBorder))
			local name_label = _item.vars.name_label
			name_label:setText(_member.role.name)
			local level_label = _item.vars.level_label
			level_label:setText(_member.role.level)

			local transferLvl = _member.role.tLvl
			local bwType = _member.role.bwType
			local jobName = "";
			if transferLvl == 0 then
				jobName = i3k_db_generals[_member.role.type].name
			else
				jobName = i3k_db_zhuanzhi[_member.role.type][transferLvl][bwType].name
			end
			_item.vars.job_label:setText(jobName)
			_item.vars.agree_btn:onClick(self, function ()
				if g_i3k_game_context:judgeInFactionFight() then
					g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
					return
				end
				if g_i3k_game_context:fightGroupIsFull(self._curGroupId) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3097))
					return
				end
				i3k_sbean.request_sect_fight_group_accept_req(self._curGroupId, _member.role.id)
			end)
			_item.vars.refuse_btn:onClick(self, function ()
				if g_i3k_game_context:judgeInFactionFight() then
					g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
					return
				end
				i3k_sbean.request_sect_fight_group_refuse_req(self._curGroupId, {[_member.role.id]=true})
			end)
			vars.apply_scroll:addItem(_item)
		end
	end

	if not applys or table.nums(applys) == 0 then
		vars.refuse_btn:disableWithChildren()
		g_i3k_game_context:setFightGroupApplyStatus(false)
	else
		vars.refuse_btn:enableWithChildren()
	end
end

--判断解散分堂权限
function wnd_factionFightGroup:judgePower()
	if g_i3k_game_context:getFightGroupId() then
		self._curGroupId = g_i3k_game_context:getFightGroupId()
	end
	--解散分堂
	local leaderId = g_i3k_game_context:getFactionFightGroupLeaderId(self._curGroupId)
	local isHaveDismissPower = false
	local powerIndex = 2
	--分堂内权限
	if leaderId then
		powerIndex = g_i3k_game_context:GetRoleId() == leaderId and 1 or 2
	end
	if i3k_db_faction_fightgroup.power[powerIndex].dismiss == 1 then
		isHaveDismissPower = true
	end
	--帮主等特殊权限
	if g_i3k_game_context:ishaveFactionFightGroupPower("fightGroupDismiss") then
		isHaveDismissPower = true
	end
	return isHaveDismissPower
end

function wnd_factionFightGroup:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroup)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionFightGroup.new()
		wnd:create(layout, ...)
	return wnd
end
