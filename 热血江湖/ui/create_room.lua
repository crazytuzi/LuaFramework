-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_create_room = i3k_class("wnd_create_room", ui.wnd_base)

local replace_iconid = 162
local IS_LEADER = 1
local NOT_LEADER = 2

--快速加入按钮点击时间间隔
local TOUCH_TIME = 2
local LAYER_SQZDT	= "ui/widgets/sqzdt"

local l_team_num_limit = 4
local timeCounter = 0

function wnd_create_room:ctor()
	self._type = 1
	self._refresh_time  = 0
	self.inviteFriend = {}
	self.hRoot = {}
	self.tabBtn = {}
end

function wnd_create_room:configure()
	local widgets = self._layout.vars

	widgets.close_btn:onClick(self,self.onCloseUI, function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "updateDungeonUI")
	end)
	self.tabBtn = {
		[1] = widgets.myTeam_btn, 
		[2] = widgets.nearBy_btn,
		[3] = widgets.assist_btn,
	}

	self.myTeam_btn = widgets.myTeam_btn
	self.myTeam_btn:onClick(self, self.onMyTeamBtn)
	self.nearBy_btn = widgets.nearBy_btn
	self.assist_btn = widgets.assist_btn
	self.assist_btn:onClick(self, self.onAssistBtn)
	self.open_btn = widgets.open_btn
	self.refresh_btn = widgets.refresh_btn

	self.teamRoot = widgets.teamRoot
	self.otherRoot = widgets.otherRoot
	self.scrollRoot = widgets.scrollRoot

	self.teamid = widgets.teamid
	self.team_num = widgets.team_num
	self.wait_time = widgets.wait_time
	self.team_name = widgets.team_name
	self.team_tag = widgets.team_tag
	self.leave_btn = widgets.leave_btn

	self.wait_btn1 = widgets.wait_btn1
	self.wait_btn2 = widgets.wait_btn2

	for i=2,4 do
		local nroot = string.format("NRoot%s",i)
		local nroot_btn = string.format("NRoot_btn%s",i)
		self.inviteFriend[i] = {nRoot = widgets[nroot], nRootBtn = widgets[nroot_btn]}
	end

	for i=1,4 do
		local temp_hroot = string.format("HRoot%s",i)
		self.hRoot[i] = {member = widgets[temp_hroot]}
	end
	self.leader_mark = widgets.leader_mark
	self._layout.vars.inviteMsgBtn:onClick(self,self.sendRoomInviteMsg)
	self._layout.vars.swornBtn:onClick(self, self.onSwornBtn)
end

function wnd_create_room:hideRoot()
	for i,e in pairs(self.hRoot) do
		e.member:hide()
	end
end

function wnd_create_room:hideInviteFriend()
	for i=2,4 do
		self.inviteFriend[i].nRoot:show()
		self.inviteFriend[i].nRootBtn:onClick(self, self.onInviteFriend)
	end
end

--助战按钮显示条件
function wnd_create_room:updateAssistBtnState()
	local cond1 = g_i3k_game_context:GetRoleId() == g_i3k_game_context:GetRoomLeaderID()
	local cond2 = g_i3k_db.i3k_db_is_faction_assist_open()
	self.assist_btn:setVisible(cond1 and cond2)
end

function wnd_create_room:updateTabBtnState(state)
	for i, v in ipairs(self.tabBtn) do
		v:stateToNormal(true)
		if i == state then
			v:stateToPressed(true)
		end
	end
end

function wnd_create_room:refresh()
	self._type = 1
	self.teamRoot:show()
	self.otherRoot:hide()
	self:hideInviteFriend()
	self:hideRoot()
	self:updateAssistBtnState()
	self:setMemberInfoUI()
	self.myTeam_btn:onClick(self, self.onMyTeamBtn)
	self:updateTabBtnState(self._type)
	self.nearBy_btn:onClick(self, self.onNearByBtn)
	self.refresh_btn:onClick(self, self.onRefresh)
	self.leave_btn:onClick(self, self.onLeaveRoom)
	local mapid = g_i3k_game_context:GetMapID()
	local roomType = g_i3k_game_context:GetCommonRoomType()
	if roomType == gRoom_Dungeon then
		if mapid ~= 0 then
			if i3k_db_new_dungeon[mapid].difficulty == DUNGEON_DIFF_MASTER then
				self:setMasterUI()
			end
		end
	end
	self:isShowSwornBtn()
end

-- 如果是师徒副本，那么就显示为师徒
function wnd_create_room:setMasterUI()
	self._layout.vars.nearLabel:setText("师徒")
	self._layout.vars.nearBy_btn:onClick(self, self.onMasterClick)
	self.assist_btn:hide()
end

function wnd_create_room:onMasterClick(sender)
	i3k_sbean.getMasterRequeset(true)
end

-- 师徒
function wnd_create_room:onShowMasterPlayerList(Data)
	self.teamRoot:hide()
	self.otherRoot:show()
	self:updateTabBtnState(2)  --附近的人改为师徒
	self.scrollRoot:removeAllChildren()
	local scroll = self.scrollRoot
	local index = 0
	for k,v in pairs(Data) do
		index = index + 1
		local Item = self:createItem(v,index)
		scroll:addItem(Item)
	end
end

function wnd_create_room:inviteToTeam(sender, info)
	local data = i3k_sbean.mroom_invite_req.new()
	data.roleId = info.id
	data.roleName = info.name
	i3k_game_send_str_cmd(data, "mroom_invite_res")
end

function wnd_create_room:createItem(info,index)
	local Item = require("ui/widgets/yqhyt")()
	Item.vars.name_label:setText(info.name)
	Item.vars.level_label:setText(string.format("%d级", info.level))
	Item.vars.power_label:setText("战斗力"..info.fightPower)
	Item.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(info.headIcon, false));
	Item.vars.txb_img:setImage(g_i3k_get_head_bg_path(info.bwType, info.headBorder))
	local gcfg = g_i3k_db.i3k_db_get_general(info.type)
	Item.vars.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
	Item.vars.invite_btn:onClick(self, self.inviteToTeam,info)
	Item.vars.invite_btn:setTag(index)
	return Item
end

function wnd_create_room:setMemberInfoUI()
	local widget = self._layout.vars
	local is_leader = 0
	for i, e in ipairs(g_i3k_game_context:GetRoomData()) do
		if self.inviteFriend[i] then
			self.inviteFriend[i].nRoot:hide()
		end
		self.hRoot[i].member:show()
		local temp_job_icon = string.format("job_icon%s",i)
		local temp_lvl_lable = "lvl_lable"..i
		local temp_name = "name"..i
		local temp_power = "power"..i
		local temp_btn = "h_btn"..i
		local temp_role_icon = "role_icon"..i
		local headBg = "headBg"..i
		local assist_mark = "assist_mark"..i
		if i == 1 then
			self.leader_mark:show()
		else
			widget[assist_mark]:setVisible(e.id < 0)
		end
		if g_i3k_game_context:GetRoleId() == e.id then
			is_leader = e.leader -- 默认每个人信息中都有是否为房主的标志0不是1是
		end
		if e.leader == 1 then
			leader_name = e.name
		end
		widget[temp_name]:setText(e.name)
		widget[temp_power]:setText(e.power)
		widget[temp_lvl_lable]:setText(e.lvl)
		widget[headBg]:setImage(g_i3k_get_head_bg_path(e.bwType, e.headBorder))
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(e.headIcon, g_i3k_db.eHeadShapeQuadrate)
		widget[temp_role_icon]:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		local gcfg = g_i3k_db.i3k_db_get_general(e.job)
		widget[temp_job_icon]:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
		widget[temp_btn]:onClick(self, self.onTalkWithOther, {id = e.id, is_leader = is_leader})
	end

	self.open_btn:setVisible(is_leader == 1)
	self.wait_btn1:setVisible(is_leader == 1)
	self.wait_btn2:setVisible(is_leader ~= 1)
	self.open_btn:onClick(self, self.onOpen)
	self.wait_btn1:onClick(self,self.onWait)
	self.wait_btn2:onClick(self,self.onWait)

	self.teamid:hide()
	-- self.teamid:setText(g_i3k_game_context:GetRoomID())
	self.team_num:setText(string.format("等待中的临时队伍(%s/%s)",#(g_i3k_game_context:GetRoomData()),l_team_num_limit))
	self.createTime = i3k_game_get_time() - g_i3k_game_context:GetRoomCreateTime()
	self.wait_time:setText("已等待:"..self:getCreateTimeStr(self.createTime))
	self.team_name:setText(leader_name.."的队伍")
	self:setRoomName()
end

function wnd_create_room:setRoomName( )
	local mapid = g_i3k_game_context:GetMapID()
	local roomType = g_i3k_game_context:GetCommonRoomType()
	if roomType == gRoom_Dungeon then
		if mapid == 0 then
			self.team_tag:setText("目标：正义之心副本")
			--self._layout.vars.inviteMsgBtn:hide()
		else
			self.team_tag:setText("目标："..i3k_db_new_dungeon[mapid].name)
		end
	elseif roomType == gRoom_NPC_MAP then
		self.team_tag:setText("目标："..i3k_db_NpcDungeon[mapid].name)
	elseif roomType == gRoom_TOWER_DEFENCE then
		self.team_tag:setText(string.format("目标：%s", i3k_db_defend_cfg[mapid].descName))
	end
end

function wnd_create_room:getCreateTimeStr(timeNum)
	local str = ""
	local hour = math.modf(timeNum / (60 * 60))
	local leftMin = timeNum % (60 * 60)
	if hour ~= 0 then
		str = str..hour.."小时"
	end
	local min = math.modf(leftMin / 60)
	local leftSec = leftMin % 60
	if min ~= 0 then
		str = str..min.."分钟"
	end
	str = str..leftSec.."秒"
	return str
end

function wnd_create_room:onUpdate(dTime)
	-- 计时
	timeCounter = timeCounter + dTime
	if timeCounter > 1 and self.createTime then
		self.createTime = self.createTime + 1
		self.wait_time:setText("已等待:"..self:getCreateTimeStr(self.createTime))
		timeCounter = 0
	end
end

function wnd_create_room:onWait(sender)
	local cfg = g_i3k_game_context:GetUserCfg()
	local tipFlag = cfg:GetDungeonWaitTipStatus(g_i3k_game_context:GetRoleId())
	if tipFlag then
		g_i3k_ui_mgr:OpenUI(eUIID_WaitTip)
		g_i3k_ui_mgr:RefreshUI(eUIID_WaitTip)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_CreateRoom)
end

function wnd_create_room:SetNearbyData()
	self.teamRoot:hide()
	self.otherRoot:show()
	self.scrollRoot:removeAllChildren()
	for i, e in pairs(g_i3k_game_context:GetNearByRoleData()) do
		local _layer = require(LAYER_SQZDT)()
		local widget = _layer.vars
		widget.name_label:setText(e.name)
		widget.level_label:setText(e.lvl)
		widget.power_label:setText(e.power)
		widget.iconType:setImage(g_i3k_get_head_bg_path(e.bwType, e.headBorder))
		widget.cancelLabel:setText("交流")
		widget.talk_btn:onClick(self, self.onTalkWithApply, {id = e.id})
		widget.cancelLabel:hide() --Zhang 暂时注释掉交流按钮
		widget.talk_btn:hide()
		widget.okLabel:setText("邀请")
		widget.invite_btn:onClick(self, self.onInviteApply, {id = e.id, name = e.name})
		local gcfg = g_i3k_db.i3k_db_get_general(e.job)
		widget.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(e.headIcon, g_i3k_db.eHeadShapeQuadrate)
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		self.scrollRoot:addItem(_layer)
	end
end

--设置助战信息
function wnd_create_room:SetAssistData()
	self.teamRoot:hide()
	self.otherRoot:show()
	self.scrollRoot:removeAllChildren()
	for i, e in ipairs(g_i3k_game_context:GetAssistRoleData()) do
		local _layer = require(LAYER_SQZDT)()
		local widget = _layer.vars
		widget.name_label:setText(e.name)
		widget.level_label:setText(e.level)
		widget.power_label:setText(e.fightPower)
		widget.iconType:setImage(g_i3k_get_head_bg_path(e.bwType, e.headBorder))
		widget.zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[e.type].classImg))
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(e.headIcon, g_i3k_db.eHeadShapeQuadrate)
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		widget.talk_btn:hide()
		widget.cancelLabel:hide()
		widget.okLabel:setText(i3k_get_string(1393))
		widget.invite_btn:onClick(self, self.onAssistApply, {id = e.id, name = e.name, level = e.level})
		self.scrollRoot:addItem(_layer)
	end
end

function wnd_create_room:onRefresh(sender)
	local serverTime = i3k_integer(i3k_game_get_time())
	if serverTime - self._refresh_time <  TOUCH_TIME then
		return
	end
	self._refresh_time = serverTime
	if self._type == 1 then
		i3k_sbean.mroom_self()
	elseif self._type == 2 then
		i3k_sbean.mroom_mapr(g_NEARBY_CROOM)
	elseif self._type == 3 then
		i3k_sbean.sect_assist_sync(g_CROOM_ASSIST)
	end
end

function wnd_create_room:onOpen(sender)
	local mapid = g_i3k_game_context:GetMapID()
	local roomType = g_i3k_game_context:GetCommonRoomType()
	if roomType == gRoom_Dungeon then
		if mapid == 0 then
			if not self:isTeamPersonEnough(i3k_db_common.teamPersonNum.min, i3k_db_common.teamPersonNum.max) then
				return
			end
			i3k_sbean.justicemap_start()
		else
			local roleCount = g_i3k_game_context:GetRoomRoleCount()
			if not self:isTeamPersonEnough(i3k_db_new_dungeon[mapid].minPlayer, i3k_db_new_dungeon[mapid].maxPlayer) then
				return
			end
			g_i3k_game_context:ClearFindWayStatus()
			i3k_sbean.normalmap_start(mapid)
			g_i3k_ui_mgr:CloseUI(eUIID_CreateRoom)
		end
	elseif roomType == gRoom_NPC_MAP then
		if not self:isTeamPersonEnough(i3k_db_common.teamPersonNum.min, i3k_db_common.teamPersonNum.max) then
			return
		end
		i3k_sbean.start_npc_mapReq(mapid)
	elseif roomType == gRoom_TOWER_DEFENCE then
		if not self:isTeamPersonEnough(i3k_db_common.teamPersonNum.min, i3k_db_common.teamPersonNum.max) then
			return
		end
		i3k_sbean.towerdefence_start(mapid)
	end
end

function wnd_create_room:isTeamPersonEnough(min, max)
	local roleCount = g_i3k_game_context:GetRoomRoleCount()
	if roleCount < min or roleCount > max then
		g_i3k_ui_mgr:PopupTipMessage("临时队伍人数与副本要求人数不匹配")
		return false
	end
	return true
end

function wnd_create_room:onLeaveRoom(sender)
	local data = i3k_sbean.mroom_leave_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.mroom_leave_res.getName())
end

function wnd_create_room:onTalkWithOther(sender, data)
	local senderPos = sender:getPosition()
	local width = sender:getContentSize().width
	local pos = sender:convertToWorldSpace(cc.p(senderPos.x+width/2, senderPos.y))

	if data.id ~= g_i3k_game_context:GetRoleId() then
		if data.is_leader == 1 then
			if data.id > 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_RoomTips)
				g_i3k_ui_mgr:RefreshUI(eUIID_RoomTips, pos, true, data.id)
			else
				local desc = i3k_get_string(1391)
				local func = function(ok)
					if ok then
						i3k_sbean.sect_assist_kick(data.id)
					end
				end
				g_i3k_ui_mgr:ShowMessageBox2(desc, func)
			end
		else
			if data.id > 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_RoomTips)
				g_i3k_ui_mgr:RefreshUI(eUIID_RoomTips, pos, false, data.id)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1392))
			end
		end
	end
end

function wnd_create_room:onInviteFriend(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteFriends,2)
--[[	local desc = string.format("功能正在开发中，敬请期待！")
	g_i3k_ui_mgr:ShowMessageBox1(desc)--]]
end

function wnd_create_room:onTalkWithApply(sender, data)
	local id = data.id
	local parent = sender:getParent()
	local x,y = sender:getPosition()
	local width = sender:getContentSize().width
	local pos = parent:convertToWorldSpace(cc.p(x.x+width/2, x.y))

	g_i3k_ui_mgr:OpenUI(eUIID_RoomTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoomTips, pos,false,id)
end

function wnd_create_room:onInviteApply(sender, data)
	i3k_sbean.mroom_invite(data.id, data.name)
end

function wnd_create_room:onAssistApply(sender, data)
	--房间人数
	local roleCount = g_i3k_game_context:GetRoomRoleCount()
	if roleCount == l_team_num_limit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1395))
		return 
	end
	--副本进入等级
	local mapid = g_i3k_game_context:GetMapID()
	local roomType = g_i3k_game_context:GetCommonRoomType()
	local enterLvl = 0
	if roomType == gRoom_Dungeon then
		if mapid == 0 then  --正义之心副本
			enterLvl = i3k_db_rightHeart.openlevel
		else
			enterLvl = i3k_db_new_dungeon[mapid].reqLvl
		end
	elseif roomType == gRoom_NPC_MAP then
		enterLvl = i3k_db_NpcDungeon[mapid].openLevel
	elseif roomType == gRoom_TOWER_DEFENCE then
		enterLvl = i3k_db_defend_cfg[mapid].needLevel
	end
	if data.level < enterLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1396))
		return 
	end
	--助战者或真人已经加入房间（理论不可能发生）
	for _, v in pairs(g_i3k_game_context:GetRoomData()) do
		if data.id == math.abs(v.id) then
			if v.id > 0 then  --真人
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1398))
				return
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1397))
				return
			end
		end
	end

	i3k_sbean.sect_assist_apply(data.id, data.name)
end

function wnd_create_room:onMyTeamBtn(sender)
	self._type = 1
	self:updateTabBtnState(self._type)
	self:refresh()
end

function wnd_create_room:onNearByBtn(sender)
	self._type = 2
	self:updateTabBtnState(self._type)
	i3k_sbean.mroom_mapr(g_NEARBY_CROOM)
end

function wnd_create_room:onAssistBtn(sender)
	self._type = 3
	self:updateTabBtnState(self._type)
	i3k_sbean.sect_assist_sync(g_CROOM_ASSIST)
end

function wnd_create_room:sendRoomInviteMsg(sender)
	if g_i3k_game_context:GetRoomLeaderID() ~= g_i3k_game_context:GetRoleId() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(871))
		return
	end

	local mapId = g_i3k_game_context:GetMapID()
	local roomId = g_i3k_game_context:GetRoomID()
	local roomType = g_i3k_game_context:GetCommonRoomType()
	local msg = "#R"..mapId..","..roomId..",".. roomType.."#"
	i3k_sbean.world_msg_send_req(msg)
end

function wnd_create_room:isShowSwornBtn()
	if g_i3k_game_context:getSwornFriends() then
		local mapid = g_i3k_game_context:GetMapID()
		local roomType = g_i3k_game_context:GetCommonRoomType()
		if roomType == gRoom_Dungeon then
			if mapid ~= 0 then
				if i3k_db_new_dungeon[mapid].difficulty == DUNGEON_DIFF_MASTER or i3k_db_new_dungeon[mapid].difficulty == DUNGEON_DIFF_GOLD then
					self._layout.vars.swornBtn:hide()
					self._layout.vars.swornBtn:disableWithChildren()
				else
					self._layout.vars.swornBtn:show()
					self._layout.vars.swornBtn:enableWithChildren()
				end
			end
		elseif roomType == gRoom_NPC_MAP then
			if i3k_db_sworn_system.hideHelpBtn[mapid] then
				self._layout.vars.swornBtn:hide()
				self._layout.vars.swornBtn:disableWithChildren()
			else
				self._layout.vars.swornBtn:show()
				self._layout.vars.swornBtn:enableWithChildren()
			end
		else
			self._layout.vars.swornBtn:hide()
			self._layout.vars.swornBtn:disableWithChildren()
		end
	else
		self._layout.vars.swornBtn:hide()
		self._layout.vars.swornBtn:disableWithChildren()
	end
end
function wnd_create_room:onSwornBtn(sender)
	i3k_sbean.one_key_summond_sworn_friends()
end
--[[function wnd_create_room:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_CreateRoom)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "updateDungeonUI")
end--]]

function wnd_create(layout)
	local wnd = wnd_create_room.new()
		wnd:create(layout)
	return wnd
end
