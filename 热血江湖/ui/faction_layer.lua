-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_layer = i3k_class("wnd_faction_layer", ui.wnd_base)

local LAYER_BPLBT = "ui/widgets/bpcyt"
local LAYER_BPSQT = "ui/widgets/bpsqt"
local LAYER_BPXXT2 = "ui/widgets/bpxxt2"
local LAYER_BPXXT = "ui/widgets/bpxxt"

local job_text = {"帮主","副帮主","长老","精英","平民"}
local title_icons = {2482,2483,2484}


function wnd_faction_layer:ctor()
	self._data = {} -- 临时缓存玩家数据
	self._selectPart = 1

	self._all_root = {}
	self._all_btn = {}
end

function wnd_faction_layer:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	local factionRoot = self._layout.vars.factionRoot
	factionRoot:show()

	local applyRoot = self._layout.vars.applyRoot
	applyRoot:hide()

	local thingRoot = self._layout.vars.thingRoot
	thingRoot:hide()

	self._all_root = {factionRoot = factionRoot,applyRoot = applyRoot,thingRoot = thingRoot}

	local member_btn = self._layout.vars.member_btn
	member_btn:onTouchEvent(self,self.onFaction)
	member_btn:stateToPressed()
	self.apply_btn = self._layout.vars.apply_btn
	self.apply_btn:onTouchEvent(self,self.onApply)
	local thing_btn = self._layout.vars.thing_btn
	thing_btn:onTouchEvent(self,self.onThing)

	self._all_btn = {member_btn = member_btn,apply_btn = self.apply_btn,thing_btn = thing_btn}


	local faction_btn = self._layout.vars.faction_btn
	faction_btn:onTouchEvent(self,self.onFactionList)
	local refuse_btn = self._layout.vars.refuse_btn
	refuse_btn:onTouchEvent(self,self.onRefuseAll)

	local leave_btn = self._layout.vars.leave_btn
	leave_btn:show()
	leave_btn:onTouchEvent(self,self.onLeaveFaction)

	local leave_label = self._layout.vars.leave_label
	leave_label:setText("离开帮派")

	local get_award = self._layout.vars.get_award
	get_award:onTouchEvent(self,self.onGetWorshipAward)

	local my_id = g_i3k_game_context:GetRoleId()
	if my_id == g_i3k_game_context:GetFactionChiefID() then
		local leave_btn = self._layout.vars.leave_btn
		leave_btn:onTouchEvent(self,self.onDisbandFaction)
		leave_label:setText("解散帮派")
	end
	local factionID_label = self._layout.vars.factionID_label
	factionID_label:setText(g_i3k_game_context:GetFactionSectId())
	self.member_scroll = self._layout.vars.member_scroll
	self.apply_point = self._layout.vars.apply_point
	self.apply_point:hide()

	self.apply_scroll = self._layout.vars.apply_scroll
	self.thing_scroll = self._layout.vars.thing_scroll
	self.worshipPoint = self._layout.vars.worshipPoint
	self.title_name = self._layout.vars.title_name
	self.title_name:setImage(g_i3k_db.i3k_db_get_icon_path(title_icons[1]))

	self.control_btn = self._layout.vars.control_btn
	self.control_btn:hide()
end

function wnd_faction_layer:onShow()

end

function wnd_faction_layer:onControlMember(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionControlLayer)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionControlLayer,g_i3k_game_context:GetFactionMemberList())
end

function wnd_faction_layer:hideAllRoot()
	for k,v in pairs(self._all_root) do
		v:hide()
	end
end

function wnd_faction_layer:updateRootShow(root)
	self:hideAllRoot()
	for k,v in pairs(self._all_root) do
		if k == root then
			v:show()
		end
	end
end

function wnd_faction_layer:updateAllBtnNomal()
	for k,v in pairs(self._all_btn) do
		v:stateToNormal()
	end
end

function wnd_faction_layer:updateOnebtnState(btn)
	self:updateAllBtnNomal()
	for k,v in pairs(self._all_btn) do
		if k == btn then
			v:stateToPressed()
		end
	end
end

function wnd_faction_layer:updateMenberData(tmp_members,chiefId,deputy,elder,my_id,my_level)
	if not (my_id == chiefId or deputy[my_id] ) then
		self.control_btn:hide()
	else
		self.control_btn:show()
		self.control_btn:onClick(self,self.onControlMember)
	end
	self._data = {}
	self.member_scroll:removeAllChildren()
	local elite = g_i3k_game_context:GetFactionEliteID()
	for k,v in ipairs(tmp_members) do
		local _first_btn = false
		local _second_btn = false
		local _layer = require(LAYER_BPLBT)()
		local headIcon = _layer.vars.headIcon
		local member_headIcon = v.role.headIcon
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(member_headIcon,g_i3k_db.eHeadShapeQuadrate)
		if hicon and hicon > 0 then
			headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		local name_label = _layer.vars.name_label
		name_label:setText(v.role.name)
		local level_label = _layer.vars.level_label
		level_label:setText(v.role.level)
		local job_label = _layer.vars.job_label
		local tmp_pos = 0
		if v.role.id == chiefId then
			job_label:setText(job_text[eFactionOwner])
			job_label:setTextColor("FF574990")
			_layer.vars.old_contri:setTextColor("FF574990")
			_layer.vars.state:setTextColor("FF574990")
			tmp_pos = eFactionOwner
		elseif deputy[v.role.id] then
			job_label:setText(job_text[eFactionSencondOwner])
			tmp_pos = eFactionSencondOwner
		elseif elder[v.role.id] then
			job_label:setText(job_text[eFactionElder])
			tmp_pos = eFactionElder
		elseif elite[v.role.id] then
			job_label:setText(job_text[eFactionElite])
			tmp_pos = eFactionElite
		else
			job_label:setText(job_text[eFactionPeple])
			tmp_pos = eFactionPeple
		end
		if v.role.id == chiefId then
			_layer.vars.memberBg:setImage(g_i3k_db.i3k_db_get_icon_path(8754))
		else
			_layer.vars.memberBg:setImage(g_i3k_db.i3k_db_get_icon_path(6204))
		end
		local old_contri = _layer.vars.old_contri
		old_contri:setText(v.role.fightPower)
		local state = _layer.vars.state
		local desc = self:getUserState(v.lastLogoutTime)
		state:setText(desc)
		--local control_btn = _layer.vars.control_btn
		--control_btn:show()
		local detail_btn = _layer.vars.detail_btn
		detail_btn:onClick(self,self.onMemberDetailBtn,v)

		local kneel_btn = _layer.vars.kneel_btn
		kneel_btn:hide()
		kneel_btn:setTag(v.role.id)
		kneel_btn:onTouchEvent(self,self.onKneel)
		if my_level < v.role.level and v.lastLogoutTime == 0 then
			kneel_btn:show()
		end
		local roleHeadBg = _layer.vars.roleHeadBg
		roleHeadBg:setImage(g_i3k_get_head_bg_path(v.role.bwType, v.role.headBorder))
		self.member_scroll:addItem(_layer)

		local job_icon = _layer.vars.job_icon
		job_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.role.type].classImg))

		self._data[v.role.id] = {name = v.role.name,level = v.role.level}
	end
	self:updateRedPoint()
end

function wnd_faction_layer:onMemberDetailBtn(sender,detailData)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionMemberDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionMemberDetail,detailData)
	local groupId = g_i3k_game_context:isInFactionFightGroupLeader()
	if groupId ~= nil then
		--检查是否已有分堂
		if not g_i3k_game_context:isInFactionFightGroup(detailData.role.id) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionMemberDetail,
				"addBtn",{
				[1]={
					desc="邀请入堂",
					func = function ()
						--检查是否已有分堂
						--if g_i3k_game_context:isInFactionFightGroup(detailData.role.id) then
							--g_i3k_ui_mgr:PopupTipMessage("您邀请的帮派成员已加入分堂，邀请失败")
							--return
						--end
						--检查对方等级
						if detailData.role.level < i3k_db_faction_fightgroup.common.joinLevel then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3103, i3k_db_faction_fightgroup.common.joinLevel))
							return
						end
						--检查分堂数量
						if g_i3k_game_context:fightGroupIsFull(groupId) then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3105))
							return
						end
						i3k_sbean.request_sect_fight_group_invite_req(groupId,detailData.role.id)
					end
				}
			})
		end
	end
end

function wnd_faction_layer:updateRedPoint()
	self.apply_point:hide()
	local position = g_i3k_game_context:GetSectPosition()
	if position ~= eFactionPeple then
		local state = g_i3k_game_context:getApplyMsg()
		if state then
			self.apply_point:show()
			g_i3k_game_context:setApplyMsg(false)
		end
	end

end

function wnd_faction_layer:getUserState(Timer)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if Timer < 0 then
		return "刚刚"
	elseif Timer == 0 then
		return "线上"
	else
		local count =  serverTime - Timer
		if count >= 3600 and count <= 3600 * 24 then
			--local nums = math.modf(count / 3600)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc
		elseif count > 3600 * 24  and count <= 3600* 24 * 7 then
			local nums = math.modf(count /(3600 * 24))
			local desc = "离线%s天"
			desc = string.format(desc,nums)
			return  desc
		elseif count > 3600 * 24 *7 then
			return "久未上线"
		elseif count < 3600 then
			local nums = math.modf(count / 60)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc
		end
	end
end

function wnd_faction_layer:updateApplyData(apply_data)
	self.apply_scroll:removeAllChildren()
	self._selectPart = 2
	self:updateRootShow("applyRoot")
	self:updateOnebtnState("apply_btn")
	self.title_name:setImage(g_i3k_db.i3k_db_get_icon_path(title_icons[2]))
	for k,v in pairs(apply_data) do
		local _layer = require(LAYER_BPSQT)()
		local apply_hicon = _layer.vars.headIcon
		local member_headIcon = v.headIcon
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(member_headIcon,g_i3k_db.eHeadShapeQuadrate)
		if hicon and hicon > 0 then
			apply_hicon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		local name_label = _layer.vars.name_label
		name_label:setText(v.name)
		local level_label = _layer.vars.level_label
		level_label:setText(v.level)
		local power_label = _layer.vars.power_label
		power_label:setText(v.fightPower)
		local transferLvl = v.tLvl
		local bwType = v.bwType
		local jobName
		if transferLvl == 0 then
			jobName = i3k_db_generals[v.type].name
		else
			jobName = i3k_db_zhuanzhi[v.type][transferLvl][bwType].name
		end
		local job_label = _layer.vars.job_label
		job_label:setText(jobName)
		local agree_btn =_layer.vars.agree_btn
		agree_btn:setTag(v.id)
		agree_btn:onTouchEvent(self,self.onAgree)

		local refuse_btn = _layer.vars.refuse_btn
		refuse_btn:setTag(v.id)

		local roleHeadBg = _layer.vars.roleHeadBg
		roleHeadBg:setImage(g_i3k_get_head_bg_path(v.bwType, v.headBorder))
		refuse_btn:onTouchEvent(self,self.onRefuse)
		self.apply_scroll:addItem(_layer)
	end
	self:updateRedPoint()
	self.apply_point:hide()
end

function wnd_faction_layer:updateThingData(ting_data)
	local _tmp_data = {}
	local _tmp_month = {}
	local _tmp_day = {}

	table.sort(ting_data,function (a,b)
		return a.time > b.time
	end)

	for k,v in ipairs(ting_data) do
		local _time = v.time
		_time = g_i3k_get_GMTtime(_time)
		local m = os.date("%m",_time)
		local d = os.date("%d",_time)
		if not _tmp_data[m] then
			_tmp_data[m] = {}
			local _index = #_tmp_month
			local t = {month = m,day = d}

			_tmp_month[_index + 1] = t
		end
		if not _tmp_data[m][d] then
			_tmp_data[m][d] = {}
		end
		local _index = #_tmp_data[m][d]
		_tmp_data[m][d][_index + 1] = v
	end

	self.thing_scroll:removeAllChildren()
	local use_height = 0
	for k,v in ipairs(_tmp_month) do
		local _layer = require(LAYER_BPXXT2)()
		local time_label = _layer.vars.time_label
		local tmp_str = string.format("%s月%s日",v.month,v.day)
		time_label:setText(tmp_str)
		self.thing_scroll:addItem(_layer)
		for i,j in ipairs(_tmp_data[v.month][v.day]) do
			local _time = g_i3k_get_GMTtime(j.time)
			local h = os.date("%H",_time)
			local m = os.date("%M",_time)
			local name
			if i3k_db_faction_skill[j.arg2] then
				name = i3k_db_faction_skill[j.arg2][0].name
			end
			local desc = i3k_GetFactionThingDesc(j.eid,j.operatorName,j.memberName,j.arg,name)
			local _layer = require(LAYER_BPXXT)()
			local desc_label = _layer.vars.desc_label
			local time_label = _layer.vars.time_label
			local tmp_str = string.format("%s:%s",h,m)
			time_label:setText(tmp_str)
			desc_label:setText(desc)
			self.thing_scroll:addItem(_layer)
		end

	end
	self:updateRedPoint()
end

function  wnd_faction_layer:GetFactionThingDesc(id,operatorName,memberName,arg,name)
	local desc
	if id == 1 then
		desc = i3k_get_string(id + 11999,operatorName)
	elseif id == 2 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 3 then
		desc = i3k_get_string(id + 11999,operatorName)
	elseif id == 4 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 5 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 6 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 7 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 8 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 9 then
		desc = i3k_get_string(id + 11999,memberName,operatorName)
	elseif id == 10 then
		desc = i3k_get_string(id + 11999,arg)
	elseif id == 11 then
		desc = i3k_get_string(id + 11999,name,arg)
	elseif id == 12 then
		desc = i3k_get_string(id + 11999,operatorName,arg)
	elseif id == 13 then
		desc = i3k_get_string(id + 11999,operatorName,g_i3k_db.i3k_db_get_common_item_name(arg))
	elseif id == 14 then
		desc = i3k_get_string(id + 11999,operatorName,memberName)
	elseif id == 15 then
		desc = i3k_get_string(id + 11999,operatorName,i3k_db_faction_dine[arg].name)
	elseif id == 16 then
		desc = i3k_get_string(id + 11999,operatorName,i3k_db_faction_dine[arg].name)
	elseif id == 17 then
		desc = i3k_get_string(id + 11999,operatorName,i3k_db_dungeon_base[arg].desc)
	elseif id == 18 then
		desc = i3k_get_string(id + 11999,operatorName,i3k_db_dungeon_base[arg].desc)
	elseif id == 19 then
		local name  = g_i3k_db.i3k_db_get_common_item_name(arg)

		desc = i3k_get_string(id + 11999,operatorName,name)
	elseif id == 20 then
		desc = i3k_get_string(id + 11999,operatorName,i3k_db_dungeon_base[arg].desc)
	elseif id == 21 then
		desc = i3k_get_string(id + 11999,operatorName,arg,memberName)
	elseif id == 22 then
		desc = i3k_get_string(id + 11999,i3k_db_dungeon_base[arg].desc,memberName,operatorName)
	elseif id == 23 then
		if memberName == "" then
			desc = i3k_get_string(id + 11999,operatorName,memberName,i3k_db_dungeon_base[arg].desc)
			desc = string.gsub(desc,"占领的","")
		else
			desc = i3k_get_string(id + 11999,operatorName,memberName,i3k_db_dungeon_base[arg].desc)
		end
	elseif id == 24 then
		desc = i3k_get_string(id + 11999,i3k_db_dungeon_base[arg].desc)
	end
	return desc

end

function wnd_faction_layer:onGetWorshipAward(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_syncworshipreward_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_syncworshipreward_res.getName())
	end
end

function wnd_faction_layer:onControl1(sender,t)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionControl)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionControl,1,t.id,t.pos,t.name)
end

function wnd_faction_layer:onControl2(sender,t)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionControl)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionControl,2,t.id,t.pos,t.name)
end

function wnd_faction_layer:onKneel(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		i3k_sbean.query_rolebrief(sender:getTag(), { faction = true, })
		g_i3k_ui_mgr:OpenUI(eUIID_FactionWorship)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionWorship,sender:getTag(),self._data[sender:getTag()].name)
	end
end

function wnd_faction_layer:onAgree(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local faction_level = g_i3k_game_context:GetFactionLevel()
		local max_count = i3k_db_faction_uplvl[faction_level].count
		local now_count = g_i3k_game_context:GetFactionCurrentMemberCount()
		if now_count >= max_count then
			g_i3k_ui_mgr:PopupTipMessage("帮派人数已到上限")
			return
		end
		local myPos = g_i3k_game_context:GetSectPosition()
		if not (i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			return
		end
		local tag = sender:getTag()
		local data = i3k_sbean.sect_appliedby_req.new()
		data.roleId = tag
		data.accept = 1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appliedby_res.getName())
	end
end


function wnd_faction_layer:onRefuse(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		local data = i3k_sbean.sect_appliedby_req.new()
		data.roleId = tag
		data.accept = 2
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appliedby_res.getName())
	end
end

function wnd_faction_layer:onAgreeAll(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_appliedbyall_req.new()
		data.accept = 1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appliedbyall_res.getName())
	end
end

function wnd_faction_layer:onRefuseAll(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_appliedbyall_req.new()
		data.accept = 2
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appliedbyall_res.getName())
	end
end

function wnd_faction_layer:onFactionList(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_list_req.new()
		data.layer = 1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_list_res.getName())

	end
end

function wnd_faction_layer:onFaction(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self._selectPart = 1
		self:updateRootShow("factionRoot")
		self:updateOnebtnState("member_btn")
		self.title_name:setImage(g_i3k_db.i3k_db_get_icon_path(title_icons[1]))
		local data = i3k_sbean.sect_members_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
	end
end

function wnd_faction_layer:onApply(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self._selectPart = 2
		local my_id = g_i3k_game_context:GetRoleId()
		local chiefId = g_i3k_game_context:GetFactionChiefID()
		local deputy = g_i3k_game_context:GetFactionDeputyID() or {}
		local elder = g_i3k_game_context:GetFactionElderID() or {}
		if not (my_id == chiefId or deputy[my_id] or elder[my_id]) then
			g_i3k_ui_mgr:PopupTipMessage("无许可权查看")
			return
		end
		local data = i3k_sbean.sect_applications_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_applications_res.getName())
	end
end

function wnd_faction_layer:onThing(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self._selectPart = 3
		self:updateRootShow("thingRoot")
		self:updateOnebtnState("thing_btn")
		self.title_name:setImage(g_i3k_db.i3k_db_get_icon_path(title_icons[3]))
		local data = i3k_sbean.sect_history_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_history_res.getName())
	end
end

function wnd_faction_layer:onLeaveFaction(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local role_id = g_i3k_game_context:GetRoleId()
		if g_i3k_game_context:judgeInFactionFight() and g_i3k_game_context:isInFactionFightGroup(role_id) then
			g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
			return
		end
		local fun = (function(ok)
			if ok then
				local data = i3k_sbean.sect_leave_req.new()
				i3k_game_send_str_cmd(data,i3k_sbean.sect_leave_res.getName())
			end
		end)
		local _data = g_i3k_game_context:GetFactionMyData()
		local times = _data.leaveTimes or 0
		local seconds = g_i3k_db.i3k_db_get_faction_kick_punish_time(times + 1)
		local desc = string.format(i3k_get_string(10074, g_i3k_db.i3k_db_seconds2hour(seconds)))
		if seconds == 0 then
			desc = i3k_get_string(10081)
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	end
end

function wnd_faction_layer:onDisbandFaction(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
			local fun = (function(ok)
				if ok then
					local data = i3k_sbean.sect_disband_req.new()
					i3k_game_send_str_cmd(data,i3k_sbean.sect_disband_res.getName())
				end
			end)
			local desc = i3k_get_string(10073)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	end
end

function wnd_faction_layer:refresh()
	self:UpdateWorshipPoint()
end

function wnd_faction_layer:UpdateWorshipPoint()
	local state = g_i3k_game_context:GetFactionWorshipPoint()
	if state then
		self.worshipPoint:show()
	else
		self.worshipPoint:hide()
	end
end

function wnd_faction_layer:refreshLayer()
	if self._selectPart == 1 then
		local data = i3k_sbean.sect_members_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
	elseif self._selectPart == 2 then
		local data = i3k_sbean.sect_applications_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_applications_res.getName())
	elseif self._selectPart == 3 then
		local data = i3k_sbean.sect_history_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_history_res.getName())
	end
end



--[[function wnd_faction_layer:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionLayer)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_layer.new()
	wnd:create(layout, ...)

	return wnd
end
