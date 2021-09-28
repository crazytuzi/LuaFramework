module(..., package.seeall)

local require = require
local ui = require("ui/chatBase")


wnd_competitionRoom = i3k_class("wnd_competitionRoom", ui.wnd_chatBase)
--------------------------------------------------------------

local MEBER_ITEM = "ui/widgets/yyqcsfj1t" --成员item yyqcsfj1t


local REFRESH_TIME = 1 --刷新时间

--operationType
local OPERATION_LEDAR = 1 --任命取消队长
local OPERATION_CAMP = 2 --切换阵营
local OPERATION_MEBER = 3  -- 踢出房间

local REB_CAMP = 1 --红阵营
local BULE_CAMP = 2 -- 蓝阵营
--tips --二次确认人提示
local OperationTable = {
	[g_COMPETITION_CAMPS_MEBER] = {
		[1] = {text = 18839, sbeanFunc = "competition_set_team_leader", operationType = OPERATION_LEDAR},
		[2] = {text = 18840, sbeanFunc = "competition_switch_camp", operationType = OPERATION_CAMP },
		[3] = {text = 18841, sbeanFunc = "competition_kick_out_room", operationType = OPERATION_MEBER, tips = 18790 },
	},
	[g_COMPETITION_FREE_MEBER] = {
		[1] = {text = 18841, sbeanFunc = "competition_kick_out_room", operationType = OPERATION_MEBER, tips = 18790  },
	}
}
function wnd_competitionRoom:ctor()
end

function wnd_competitionRoom:configure()
	local widgets = self._layout.vars
	self.operationFilter = widgets.scroll3
	self.campsForScroll = {}
	widgets.leaveBtn:onClick(self, self.onLeaveRoom)
	widgets.inviteBtn:onClick(self, self.onInvite)
	widgets.switchingBtn:onClick(self, self.onSwitchingCamps)
	widgets.close:onClick(self,self.onCloseUI)
	self._timeCount = 0
	widgets.operationMask:onClick(self, function() 
		if widgets.scroll_root:isVisible() then
			widgets.scroll_root:setVisible(false)	
		end
	end)
	widgets.toChat:onClick(self, self.chatCB)
	widgets.chatLog:onTouchEvent(self, self.OpenChatCB)
	self.chatLog = widgets.chatLog
	--语音入口
	self._chatState = global_world
	local voiceBtns = {widgets.vworld, widgets.vsect, widgets.vbattle}
	local chat_state = {global_world, global_sect, global_battle}
	self.remTouchPos={}
	self.lastChatType = global_world
	--self:setFilterBtn()
end

function wnd_competitionRoom:refresh(callBack)
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	g_i3k_ui_mgr:RefreshUI(eUIID_DBF)
	if callBack then
		callBack()
	end
	self._layout.vars.roomId:setText(i3k_get_string(18797, g_i3k_game_context:GetCompetitionRoomID()))
	self:onRefreshChatLog()
	self:setFilterBtn()
	self:updateUI()
end

------------------更新--------------
function wnd_competitionRoom:updateUI()
	self:updateStartBtn()
	self:setTeamScroll()
	self:setPrepareItem(true)
end

-----------------队伍成员----------------

function wnd_competitionRoom:setTeamScroll()
	local widgets = self._layout.vars
	local team = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	self:SetScrollMember(widgets.scroll_red, team[REB_CAMP], REB_CAMP)
	self:SetScrollMember(widgets.scroll_blue, team[BULE_CAMP], BULE_CAMP)
end

function wnd_competitionRoom:SetScrollMember(scroll, team, forceType)
	self.campsForScroll[forceType] = scroll
	local childs = scroll:getAllChildren()
	local cfg = self:memberSort(team.members, team.leader)
	local index = 0
	self._layout.vars["member" .. forceType]:setText(i3k_get_string(18930, table.nums(cfg)))
	for k,v in ipairs(cfg) do
		local node
		if childs[k] then
			node = childs[k]
		else
			node = require(MEBER_ITEM)()
		end
		
		local roleInfo = v.overview
		self:setMemberItem(node, roleInfo, team, forceType)
		if not childs[k] then
			scroll:addItem(node)
		end
		index = k
	end
	local childCount = scroll:getChildrenCount()
	local memberCount = table.nums(cfg)
	if childCount > memberCount then
		memberCount = memberCount + 1
		for i =childCount,memberCount, -1 do
			scroll:removeChildAtIndex(i)
		end
	end
end

--设置成员item
function wnd_competitionRoom:setMemberItem(node, roleInfo, cfg, forceType)
	local widget = node.vars
	local roleId = g_i3k_game_context:GetRoleId()
	widget.redBg:hide()
	widget.buleBg:hide()
	widget.selfBg:hide()
	local bg = forceType == REB_CAMP and "redBg" or "buleBg"
	local selfBg = roleId == roleInfo.id and "selfBg" or bg
	widget[selfBg]:show()
	widget.name_label:setText(roleInfo.name)
	widget.level_label:setText(i3k_get_string(929, roleInfo.level))
	widget.power_label:setText(i3k_get_string(1550, roleInfo.fightPower))
	widget.iconType:setImage(g_i3k_get_head_bg_path(roleInfo.bwType, roleInfo.headBorder))
	widget.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[roleInfo.type].classImg))
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(roleInfo.headIcon, g_i3k_db.eHeadShapeQuadrate)
	widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	widget.operation_btn:onClick(self, function (sender, info)
		if self:isCanOperation(g_COMPETITION_CAMPS_MEBER) then
			self:operationFilterBtn(sender, g_COMPETITION_CAMPS_MEBER, roleInfo.id, roleInfo.name)
		end
	end,  {id = roleInfo.id, name = roleInfo.name})
	widget.ready:hide()
	widget.leadar:hide()
	widget.roomLeadar:hide()
	if roleInfo.id == cfg.leader then
		widget.leadar:show()
		widget.ready:setText(cfg.ready and i3k_get_string(18843) or i3k_get_string(18844))
		widget.ready:show()
	elseif roleInfo.id == g_i3k_game_context:GetCompetitionRoomMaster() then
		widget.roomLeadar:show()
	else
	end
	node.id = roleInfo.id
end

--更新开始按钮
function wnd_competitionRoom:updateStartBtn()
	local widgets = self._layout.vars
	local masterId = g_i3k_game_context:GetCompetitionRoomMaster()
	local roleId = g_i3k_game_context:GetRoleId()
	widgets.startBtn:enable()
	widgets.startBtn:show()
	if masterId == roleId then
		widgets.startBtn:onClick(self, self.onStart)
		widgets.startDesc:setText(i3k_get_string(18846))
	else
		local isLeadr, isReady = self:getIsLeader(roleId)
		if isLeadr then
			widgets.startBtn:onClick(self, self.onReady)
			widgets.startDesc:setText(isReady and i3k_get_string(18847) or i3k_get_string(18848))
		else
			widgets.startBtn:hide()
		end
	end
end

--备战list
function wnd_competitionRoom:setFilterBtn()
	local widgets = self._layout.vars
	local _, prepares = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	widgets.count:setText(i3k_get_string(18849,table.nums(prepares)))
	widgets.mask:onClick(self, function() 
		if widgets.levelRoot:isVisible() then
			widgets.levelRoot:setVisible(false)	
		end
	end)
	local openFilter = function ()
		if widgets.levelRoot:isVisible() then                 --如果下拉列表已经显示
			widgets.levelRoot:setVisible(false)				 --则把列表关闭
		else
			self:setPrepareItem()
		end
	end
	widgets.gradeBtn:onClick(self, openFilter)
end

--设置备战item
function wnd_competitionRoom:setPrepareItem(isRefresh)
	local widgets = self._layout.vars
	local _, prepares = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	widgets.count:setText(i3k_get_string(18849,table.nums(prepares)))
	if (not isRefresh) or  widgets.levelRoot:isVisible() then
		widgets.levelRoot:setVisible(true)					--如果没显示就打开下拉列表
		widgets.filterScroll:removeAllChildren();          --清空scroll
		for i = 1, #prepares do
			local _item = require("ui/widgets/bphzt1")();
			_item.id = prepares[i].overview.id;
			_item.name = prepares[i].overview.name
			_item.vars.levelLabel:setText(prepares[i].overview.name);
			_item.vars.levelBtn:onClick(self, function (sender)
				--widgets.levelRoot:setVisible(false)                          --点击之后关闭下拉列表
				self.filterType = _item.id
				if self:isCanOperation(g_COMPETITION_FREE_MEBER) then
					self:operationFilterBtn(sender, g_COMPETITION_FREE_MEBER, _item.id, _item.name)--self:setMemberChoose( _item,_item.id)
				end
			end)
			widgets.filterScroll:addItem(_item);       --添加到scroll
		end
	end
end

--设置选择
function wnd_competitionRoom:setMemberChoose()
	--TODO
end

--操作
function wnd_competitionRoom:operationFilterBtn(btn,state, roleId, roleName)
	if not self:isCanOperationCurRoleTips(roleId) then return end
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local parent = btn:getParent()
	if parent then
		self._movePosition = parent:convertToNodeSpace(cc.p(touchPos.x, touchPos.y))
	end
	self._layout.vars.scroll_root:setPosition(self._movePosition)
	self._layout.vars.scroll_root:show()
	local operationCfg = OperationTable[state]
	local isLeader = self:getIsLeader(roleId)
	local leader = self:getLeaderSlefCamp(roleId)
	self.operationFilter:removeAllChildren()
	local sbeanFuncBack = function(roleId, leader, meberType, operationType, sbeanFunc)
		local isLeader = self:getIsLeader(roleId)
		if operationType == OPERATION_LEDAR then
			local operationType = not isLeader
			if not isLeader and leader > 0 then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18793))
			end
			i3k_sbean[sbeanFunc](roleId, operationType, g_i3k_game_context:GetCompetitionCampsForRoleId(roleId))
		elseif operationType == OPERATION_MEBER then
			i3k_sbean[sbeanFunc](roleId, meberType)
		else
			i3k_sbean[sbeanFunc](roleId, g_i3k_game_context:GetCompetitionOtherCamp(roleId), meberType)
		end
	end
	for i,v in ipairs(operationCfg) do
		if self:isCanOperationCurType(v.operationType, leader)  then
			local node = require("ui/widgets/bphzt1")()
			local widgets = node.vars
			if v.operationType == OPERATION_LEDAR then
				v.text = isLeader and 18850 or 18839
			end
			widgets.levelLabel:setText(i3k_get_string(v.text))
			widgets.levelBtn:onClick(self, function (sender, roleInfo)
				if v.tips then
					local fun = (function(ok)
						if ok then
							sbeanFuncBack(roleId, leader, state, v.operationType, v.sbeanFunc)
						end
					end)
					g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(v.tips,roleName), fun)
				else
					sbeanFuncBack(roleId, leader, state, v.operationType, v.sbeanFunc)
				end
				self._layout.vars.scroll_root:hide()
			end)
			self.operationFilter:addItem(node)
		end
	end
end


------------------------InvokeUIFunction---------------------------

----------------Btn---------------------------
--返回大厅 
function wnd_competitionRoom:onBackBattle(sender)
	--TODO
	self:onCloseUI()
end

--邀请
function wnd_competitionRoom:onInvite(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends, g_INVITE_TYPE_COMPETITION)
end

--切换阵营
function wnd_competitionRoom:onSwitchingCamps(sender)
	local roleId = g_i3k_game_context:GetRoleId()
	local timeCD = i3k_game_get_time() - g_i3k_game_context:GetCompetitionSwitchingCampLastTime()
	if  timeCD <= i3k_db_dual_meet.switchingCampCD then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(588))
	end
	if g_i3k_game_context:GetCompetitionOtherCamp(roleId) then
		if self:getIsLeader(roleId) then
			local fun = (function(ok)
				if ok then
					i3k_sbean.competition_switch_camp(roleId, g_i3k_game_context:GetCompetitionOtherCamp(roleId))
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18851), fun)
		else
			i3k_sbean.competition_switch_camp(roleId, g_i3k_game_context:GetCompetitionOtherCamp(roleId))
		end
	end
end

--开始游戏
function wnd_competitionRoom:onStart(sender)
	local team = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	local cap = g_i3k_game_context:GetCompetitionRoomCap()
	local red = table.nums(team[REB_CAMP].members)
	local blue = table.nums(team[BULE_CAMP].members)
	if self:memberCountIsCanStart() then
		local isReady, camp = g_i3k_game_context:GetCompetitionLeaderIsReady()
		if red <= (cap/2) or blue < (cap/2) then  --小于配置人数50%提示
			local fun = (function(ok)
				if ok then
					if isReady then
						if self:memberCountIsCanStart() then
							i3k_sbean.competition_map_start()
						end
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(camp == REB_CAMP and  18893 or 18892))
					end
				end
			end)
			return g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18796), fun)
		end
		if isReady then
			i3k_sbean.competition_map_start()
		else
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(camp == REB_CAMP and  18893 or 18892))
		end
	end
end


--离开房间
function wnd_competitionRoom:onLeaveRoom(sender)
	local fun = (function(ok)
		if ok then
			i3k_sbean.competition_leave_room()
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18798), fun)
end

--准备
function wnd_competitionRoom:onReady(sender)
	local roleId = g_i3k_game_context:GetRoleId()
	local leader, ready = self:getIsLeader(roleId)
	i3k_sbean.competition_team_ready(roleId, not ready)
end

--------------------tool------------------
--人数是否可以开始
function wnd_competitionRoom:memberCountIsCanStart()
	local team = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	local red = table.nums(team[REB_CAMP].members)
	local blue = table.nums(team[BULE_CAMP].members)
	if red < 1 or blue < 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18795))
		return false
	end
	return true
end


function wnd_competitionRoom:getIsLeader(roleId)
	local team = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	if team then
		for k,v in ipairs(team) do
			if v.leader == roleId then
				return true, v.ready
			end
		end
	end
	return false, false
end

function wnd_competitionRoom:getLeaderSlefCamp(roleId)
	local team = g_i3k_game_context:GetCompetitionListTeamAndPreparesData()
	if team then
		for k,v in ipairs(team) do
			for i,j in ipairs(v.members) do
				if j.overview.id == roleId then
					return v.leader, k
				end
			end
		end
	end
	return false, false
end

--是否有权现
function wnd_competitionRoom:isCanOperation(typeMeber)
	local masterId = g_i3k_game_context:GetCompetitionRoomMaster()
	local selfId = g_i3k_game_context:GetRoleId()
	if masterId == selfId then
		return true
	elseif self:getIsLeader(selfId) then
		return  g_COMPETITION_CAMPS_MEBER == typeMeber
	end
	return false
end

-- 是否可以操作
function wnd_competitionRoom:isCanOperationCurType(operationType, leaderId)
	local masterId = g_i3k_game_context:GetCompetitionRoomMaster()
	local selfId = g_i3k_game_context:GetRoleId()
	if masterId == selfId then
		return true
	end
	if leaderId == selfId and operationType ~= OPERATION_LEDAR then
		return true
	end
	return false
end
--成员排序
function wnd_competitionRoom:memberSort(cfg, leader)
	local masterId = g_i3k_game_context:GetCompetitionRoomMaster()
	index = 3 --房主队长在前
	for i,v in ipairs(cfg) do
		if v.overview.id == masterId then
			v.sort = 1
		elseif v.overview.id == leader then
			v.sort = 2
		else
			v.sort = index
			index = index + 1
		end 
	end
	table.sort(cfg, function (a,b)
		return a.sort < b.sort 
	end )
	return cfg
end

--不可操作提示
function wnd_competitionRoom:isCanOperationCurRoleTips(roleId)
	local masterId = g_i3k_game_context:GetCompetitionRoomMaster()
	local selfId = g_i3k_game_context:GetRoleId()
	if masterId == roleId or selfId == roleId then
		return false
	end
	local selfCamp = g_i3k_game_context:GetCompetitionCampsForRoleId(selfId)
	local roleCamp = g_i3k_game_context:GetCompetitionCampsForRoleId(roleId)
	if masterId ~= selfId and selfCamp ~= roleCamp then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18799))
		return false
	end
	return true
end

--------------------update-------------
function wnd_competitionRoom:onUpdate(dtime)
	self._timeCount = self._timeCount + dtime
	if self._timeCount > REFRESH_TIME then
		self._timeCount = 0
		local roomId = g_i3k_game_context:GetCompetitionRoomID()
		i3k_sbean.competition_sync_room_info_sync(roomId)
	end
end

--------------------caht---------------------------------------------
--聊天显示内容
function wnd_competitionRoom:chatCB(sender)
	self:OpenChatUI(true)
end

function wnd_competitionRoom:OpenChatUI(shouldTalk)
	local chatUI = g_i3k_ui_mgr:GetUI(eUIID_Chat)
	if chatUI then
		chatUI:reloadScroll()
		local rootVar = chatUI._layout.rootVar
		if rootVar then
			local width = rootVar:getContentSize().width
			local pos = rootVar:getPosition()
			local move = rootVar:createMoveTo(0.2, 0, pos.y)
			rootVar:runAction(move)
		end
	else
		local oldType = self.lastChatType 
		if (shouldTalk and oldType == global_system) or oldType == global_recent or oldType == global_cross or oldType == global_team then
			oldType = global_world
		end
		g_i3k_logic:OpenChatUI(oldType, g_COMPETITION_MARK_TYPE)
	end
end

function wnd_competitionRoom:OpenChatCB(sender,eventType)
	local state = g_i3k_game_context:GetChatUIOpenState()
	if not state then
		local a,b = 1,2
		if eventType == ccui.TouchEventType.began then
			local pos_began = g_i3k_ui_mgr:GetMousePos()
			self.remTouchPos[a] = pos_began
		elseif eventType == ccui.TouchEventType.ended then
			local pos_end = g_i3k_ui_mgr:GetMousePos()
			table.insert(self.remTouchPos,pos_end)
			self.remTouchPos[b] = pos_end
		end
		local pos_began =  self.remTouchPos[a]
		local pos_end = self.remTouchPos[b]
		local scrollSize = self._layout.vars.chatLog:getSize().height
		if pos_began and pos_end then
			local distance = math.abs(pos_end.y - pos_began.y)
			if distance<= scrollSize/2 then
				self:OpenChatUI()
			end
			self.remTouchPos = {}
		end
	end
end

--聊天红点
function wnd_competitionRoom:onShowChatRedPoint(msgtype)
	local redPoint = self._layout.vars.chatRedPoint
	redPoint:show()
end

function wnd_competitionRoom:onHideChatRedPoint()
	local redPoint = self._layout.vars.chatRedPoint
	if g_i3k_game_context:isEmpty() then
		redPoint:hide()
	else
		local msgs = g_i3k_game_context:GetChatMsg()
		if #msgs[global_recent + 1] == 0 then
			redPoint:hide()
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_competitionRoom.new()
	wnd:create(layout)
	return wnd
end
