-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_main = i3k_class("wnd_faction_main", ui.wnd_base)

local LAYER_BPBJT = "ui/widgets/bpbjt"

local _UP_LEVEL_TIME = 0
local _TIME_LABEL = nil

local _UP_BTN = nil
local _UP_LABEl = nil
local _ACIMAGE = nil
local _ACTION = nil

function wnd_faction_main:ctor()
	self._bg = {}
	self._touch_index = 0
	self._faction_lvl = 0
	self.addTouchEventFlag = false

	self.haveShowedShootMsg = 0
	self.shootMsgIndex = 1
	self.shootMsgState = i3k_usercfg:GetIsShowShootMsg()
end

function wnd_faction_main:configure(...)
	local creed_btn = self._layout.vars.creed_btn
	creed_btn:onTouchEvent(self,self.onCreed)
	local set_btn = self._layout.vars.set_btn
	set_btn:onTouchEvent(self,self.onSetBtn)
	self.scroll = self._layout.vars.scroll
	self.faction_name = self._layout.vars.faction_name
	self.faction_lvl = self._layout.vars.faction_lvl
	self.members_label = self._layout.vars.members_label
	self.my_label = self._layout.vars.my_label
	self.faction_icon = self._layout.vars.faction_icon
	self.faction_bg = self._layout.vars.faction_bg
	self.uplvl_label = self._layout.vars.uplvl_label
	self.bg_scroll = self._layout.vars.bg_scroll
	self.uplvl_btn = self._layout.vars.uplvl_btn
	_UP_BTN = self.uplvl_btn
	_UP_LABEl = self.uplvl_label

	self.ss = self._layout.anis.ss
	self.acImage = self._layout.vars.acImg
	_ACIMAGE = self.acImage
	_ACTION = self.ss
	self.up_time_label =  self._layout.vars.up_time_label
	self.faction_sect_btn = self._layout.vars.faction_sect_btn
	self.faction_sect_btn:onTouchEvent(self,self.onSectTips)
	self._layout.vars.faction_sect_btn2:onTouchEvent(self,self.onSectDragonCrystalTips)

	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)

	self.flag_btn = self._layout.vars.flag_btn
	self.flag_btn:onClick(self,self.onFlagBtn)

	local flagCount = self._layout.vars.flagCount
	flagCount:setText(g_i3k_game_context:GetFactionMapFlagCount())

	self.qq_label = self._layout.vars.qq_label
	self._layout.vars.garrison_btn:onClick(self, self.onGarrisonUI)
	self._layout.vars.luckyStarBtn:onClick(self, self.openLuckStar)
	self._layout.vars.shootMsg_btn:onClick(self,function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ShootMsg)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShootMsg,g_SHOOT_MSG_TYPE_FACTION)
	end)
	self._layout.vars.faction_card:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_war_zone_map_cfg.needLvl)
	self._layout.vars.faction_card:onClick(self, function()
		i3k_sbean.global_world_sect_panel(function ()
			g_i3k_logic:OpenWarZoneCard(g_FACTION_WAR_ZONE_CARD_STATE)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionMain)
		end)
	end)
	self:ctrlShootMsg(self.shootMsgState)
	self._layout.vars.showMsgBtn:onClick(self,function ()
		self:ctrlShootMsg(not self.shootMsgState)
		i3k_usercfg:SetIsShowShootMsg(self.shootMsgState)
	end)
	self._layout.vars.factionWareHouse:onClick(self, self.onFactonWareHouse)
	self._layout.vars.fcbsBtn:onClick(self, self.openFCBS)
	self._layout.vars.photoBtn:onClick(self, self.onTakePhoto)
end

function wnd_faction_main:onShowFightGroup()
	local level = g_i3k_db.i3k_db_get_fightGroupLevel()
	if g_i3k_game_context:GetFactionLevel() >= level then
		--先同步帮派成员信息
		local data = i3k_sbean.sect_members_req.new()
		data.fun = function ()
			i3k_sbean.request_sect_fight_group_sync_req(function (data)
				g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroup)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup, data)
			end)
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3085,level))
	end
end

function wnd_faction_main:onShow()

end

function wnd_faction_main:onFlagBtn(sender)
	g_i3k_logic:OpenFactionFlagLog()
end

function wnd_faction_main:onHide()
	self.scroll:stopRollAction()
	self:CancelTimer()
end

function wnd_faction_main:updateFationQq(str)
	self.qq_label:setText(string.format("QQ群：%s",str))
end

function wnd_faction_main:updateApplyPoint()
	self.apply_point:hide()

	local position = g_i3k_game_context:GetSectPosition()
	if position ~= eFactionPeple and position ~= eFactionElite then
		local state = g_i3k_game_context:getApplyMsg()
		if state then
			self.apply_point:show()
		end
	end
end

function wnd_faction_main:onSectTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(309), self:getBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_main:onSectDragonCrystalTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips, i3k_get_string(5288), self:getBtnPosition2())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end


function wnd_faction_main:updateCreed(text)
	--这里要实现scroll横向的动画,封装scrollview方法  bpjmt
	self.scroll:setBounceEnabled(false)
	--local text = base_data.sect.overview.creed
	self.scroll:startRollAction("ui/widgets/bpjmt", text)
end

function wnd_faction_main:onFightGroup(sender, eventType)
	local _index = sender:getTag()

	if eventType == ccui.TouchEventType.began then
		self._bg[_index]:show()
	else
		self._bg[_index]:hide()
	end

	if eventType == ccui.TouchEventType.ended then
		self:onShowFightGroup();
	end
end

function wnd_faction_main:updateMainBg()
	self.bg_scroll:removeAllChildren()
	local _layer = require(LAYER_BPBJT)()

	local fightGroupBg = _layer.vars.fightGroupBg
	fightGroupBg:hide()
	local fightGroupBtn = _layer.vars.fightGroupBtn
	fightGroupBtn:onTouchEvent(self,self.onFightGroup)
	fightGroupBtn:setTag(8)

	local message_btn = _layer.vars.message_btn
	message_btn:onTouchEvent(self,self.onMemberLayer)
	message_btn:setTag(1)

	local message_bg = _layer.vars.message_bg
	message_bg:hide()

	local skill_btn = _layer.vars.skill_btn
	skill_btn:onTouchEvent(self,self.onSkill)
	skill_btn:setTag(2)

	local skill_bg = _layer.vars.skill_bg
	skill_bg:hide()

	local store_btn = _layer.vars.store_btn
	store_btn:onTouchEvent(self,self.onStore)
	store_btn:setTag(3)

	local store_bg = _layer.vars.store_bg
	store_bg:hide()

	local task_btn = _layer.vars.task_btn
	task_btn:onTouchEvent(self,self.onTask)
	task_btn:setTag(4)

	local task_bg = _layer.vars.task_bg
	task_bg:hide()

	local dungeon_btn = _layer.vars.dungeon_btn
	dungeon_btn:onTouchEvent(self,self.onDungeon)
	dungeon_btn:setTag(5)

	local dungeon_bg = _layer.vars.dungeon_bg
	dungeon_bg:hide()

	local dine_btn = _layer.vars.dine_btn
	dine_btn:onTouchEvent(self,self.onDine)
	dine_btn:setTag(6)

	local escort_btn = _layer.vars.escort_btn
	escort_btn:onTouchEvent(self,self.onEscort)
	escort_btn:setTag(7)

	local escort_bg = _layer.vars.escort_bg
	escort_bg:hide()

	local dine_bg = _layer.vars.dine_bg
	dine_bg:hide()

	self.apply_point = _layer.vars.apply_point
	self.dine_point = _layer.vars.dine_point
	self.task_point = _layer.vars.task_point
	self.fightGroup_point = _layer.vars.fightGroup_point

	self._bg = {message_bg,skill_bg,store_bg,task_bg,dungeon_bg,dine_bg,escort_bg,fightGroupBg}

	self.bg_scroll:addItem(_layer)
	self.bg_scroll:jumpToListPercent(50)
end

function wnd_faction_main:updateBaseData(flevel,fsectid,fmemberCount,upgradeTime)
	self._faction_lvl = flevel
	local tmp_str = string.format("等级：%s",flevel)
	self.faction_lvl:setText(tmp_str)
	local maxCount = i3k_db_faction_uplvl[flevel].count
	local tmp_str = string.format("成员：%s/%s",fmemberCount,maxCount)
	self.members_label:setText(tmp_str)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if i3k_db_faction_uplvl[flevel + 1] then
		local needTime = i3k_db_faction_uplvl[flevel + 1].upTime
		local needIngot = i3k_db_faction_uplvl[flevel + 1].consumeIngot
		_UP_LEVEL_TIME = needTime - (serverTime - upgradeTime)
		if serverTime - upgradeTime >= needTime then
			self.uplvl_label:setText("升级")
			self.uplvl_btn:setTag(flevel + 1)
			self.uplvl_btn:onTouchEvent(self,self.onUpLvl)
			self.acImage:show()
			self.ss.play(-1)
		else
			self.uplvl_label:setText("加速")
			self.uplvl_btn:setTag(flevel + 1)
			self.uplvl_btn:onTouchEvent(self,self.onUpSpeed)
			self.ss.stop()
			self.acImage:hide()
		end
	else
		self.uplvl_btn:hide()
		self.ss.stop()
		self.acImage:hide()
	end

	if not self._main_timer then
		_TIME_LABEL = self.up_time_label
		self:setUpTime()
		self._main_timer = i3k_game_timer_faction_mian.new()
		self._main_timer:onTest()
	end
	self._layout.vars.photoBtn:setVisible(self._faction_lvl>= i3k_db_faction_photo.cfgBase.needFactionLvl)
end

function wnd_faction_main:updateFactionName(fName)
	self.faction_name:setText(fName)
end

function wnd_faction_main:updateFactionIcon(fIcon)
	self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[fIcon].iconid))
end

function wnd_faction_main:updateFactionFrame(fFrame)
	self.faction_bg:setImage(g_i3k_db.i3k_db_get_icon_path(fFrame))
end

function wnd_faction_main:updateMyContribution(mcontribution)
	self.my_label:setText(mcontribution)
end

function wnd_faction_main:updateDragonCrystal(DragonCrystal)
	self._layout.vars.my_label2:setText(DragonCrystal)
end

function wnd_faction_main:updateDinePoint()
	self.dine_point:setVisible(g_i3k_game_context:GetFactionDinePoint() > 0 or g_i3k_game_context:GetRedEnvelopePoint() > 0 )
end

function wnd_faction_main:updateTaskPoint()
	self.task_point:setVisible(g_i3k_game_context:GetFactionResetTaskPoint() or g_i3k_game_context:GetFactionShareTaskPoint())
end

function wnd_faction_main:updateFightGroupPoint()
	self.fightGroup_point:setVisible(g_i3k_game_context:getFighGroupApplysStatus())
end




function wnd_faction_main:onCreed(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local myPos = g_i3k_game_context:GetSectPosition()
		if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionTitle == 1 then
			g_i3k_ui_mgr:OpenUI(eUIID_FactionCreed)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionCreed)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			return
		end
	end
end

function wnd_faction_main:onMemberLayer(sender,eventType)
	local _index = sender:getTag()
	if eventType == ccui.TouchEventType.began then
		self._bg[_index]:show()
	else
		self._bg[_index]:hide()
	end

	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_members_req.new()
		data.fun = function ()
			i3k_sbean.request_sect_fight_group_sync_req(function ()
				g_i3k_ui_mgr:OpenUI(eUIID_FactionLayer)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionLayer)
				-- have nothing to say  WTF!!
				g_i3k_ui_mgr:InvokeUIFunction(
					eUIID_FactionLayer,
					"updateMenberData",
					g_i3k_game_context:GetFactionMemberList(),
					g_i3k_game_context:GetFactionChiefID(),
					g_i3k_game_context:GetFactionDeputyID(),
					g_i3k_game_context:GetFactionElderID(),
					g_i3k_game_context:GetRoleId(),
					g_i3k_game_context:GetLevel()
				)
			end)
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
	end
end

function wnd_faction_main:onUpLvl(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local myPos = g_i3k_game_context:GetSectPosition()
		if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionUpLvl == 1 then
			local data = i3k_sbean.sect_upgrade_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_upgrade_res.getName())
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			return
		end
	end
end

function wnd_faction_main:onUpSpeed(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local myPos = g_i3k_game_context:GetSectPosition()
		if not (i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionUpLvl == 1) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			return
		end
		local factionLvl = g_i3k_game_context:GetFactionLevel()
		local maxSectLvl = g_i3k_game_context:GetSeverFactionMaxLvl()
		if factionLvl >= maxSectLvl then
			g_i3k_ui_mgr:PopupTipMessage("本服最高等级帮派不允许升级加速")
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FactionUpSpeed)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionUpSpeed)
	end
end

function wnd_faction_main:onSkill(sender,eventType)
	local _index = sender:getTag()
	if eventType == ccui.TouchEventType.began then
		self._bg[_index]:show()
	else
		self._bg[_index]:hide()
	end
	if eventType == ccui.TouchEventType.ended then
		if g_i3k_game_context:GetLevel() < i3k_db_kungfu_args.openLevel.level then
			local data = i3k_sbean.sect_aurasync_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_aurasync_res.getName())
		else
			g_i3k_ui_mgr:OpenUI(eUIID_FactionResearch)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionResearch)
		end
	end
end

function wnd_faction_main:onDine(sender,eventType)
	local _index = sender:getTag()
		if eventType == ccui.TouchEventType.began then
			self._bg[_index]:show()
		else
			self._bg[_index]:hide()
		end
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_BonusHouse)
		g_i3k_ui_mgr:RefreshUI(eUIID_BonusHouse)
	end
end

function wnd_faction_main:onEscort(sender,eventType)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local _index = sender:getTag()
		if eventType == ccui.TouchEventType.began then
			self._bg[_index]:show()
		else
			self._bg[_index]:hide()
		end
	if eventType == ccui.TouchEventType.ended then
		local need_faction_lvl = i3k_db_escort.escort_args.open_lvl

		local need_role_lvl = i3k_db_escort.escort_args.join_lvl

		local factionLvl = g_i3k_game_context:GetFactionLevel()

		local roleLvl = g_i3k_game_context:GetLevel()

		if factionLvl < need_faction_lvl then
			local tmp_str = i3k_get_string(541,need_faction_lvl)
			g_i3k_ui_mgr:PopupTipMessage(tmp_str)
			return
		end

		if roleLvl < need_role_lvl then
			local tmp_str = i3k_get_string(542,need_role_lvl)
			g_i3k_ui_mgr:PopupTipMessage(tmp_str)
			return
		end


		i3k_sbean.sect_escort_data()
		--g_i3k_ui_mgr:OpenUI(eUIID_FactionEscort)
		--g_i3k_ui_mgr:RefreshUI(eUIID_FactionEscort)
	end
end

function wnd_faction_main:onDungeon(sender,eventType)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local _index = sender:getTag()
		if eventType == ccui.TouchEventType.began then
			self._bg[_index]:show()
		else
			self._bg[_index]:hide()
		end
	if eventType == ccui.TouchEventType.ended then
		local tmp_dungeon = {}
		for k, v in pairs(i3k_db_faction_dungeon) do
			table.insert(tmp_dungeon,v)
		end
		table.sort(tmp_dungeon,function (a,b)
			return a.enterLevel < b.enterLevel
		end)
		local fun = function ()
			local data = i3k_sbean.sectmap_query_req.new()
			if g_i3k_game_context:isSpecialFacionDungeon(tmp_dungeon[1].id) then
				data.mapId = tmp_dungeon[1].specialDungeon
			else
				data.mapId = tmp_dungeon[1].id
			end
			i3k_game_send_str_cmd(data,i3k_sbean.sectmap_query_res.getName())
		end

		local data = i3k_sbean.sectmap_status_req.new()
		data.fun = fun
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_status_res.getName())
	end
end

function wnd_faction_main:onStore(sender,eventType)
	local _index = sender:getTag()
	if eventType == ccui.TouchEventType.began then
		self._bg[_index]:show()
	else
		self._bg[_index]:hide()
	end
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_shopsync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_shopsync_res.getName())
	end
end

function wnd_faction_main:onTask(sender,eventType)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local _index = sender:getTag()
	if eventType == ccui.TouchEventType.began then
		self._bg[_index]:show()
	else
		self._bg[_index]:hide()
	end
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_sync_res.getName())
		g_i3k_game_context:SetFactionResetTaskPoint(false)
	end
end

function wnd_faction_main:onSetBtn(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionSet)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionSet)
	end
end


function wnd_faction_main:CancelTimer()
	if self._main_timer then
		self._main_timer:CancelTimer()
	end
end

function wnd_faction_main:setUpTime()
	_UP_LEVEL_TIME = _UP_LEVEL_TIME - 1
	if _UP_LEVEL_TIME <= 0 then
		_UP_LEVEL_TIME = 0
	end
	local d =math.modf(_UP_LEVEL_TIME/(24*60*60))
	if d ~= 0 then
		local desc = string.format("剩余时间:%s天",d)
		_TIME_LABEL:setText(desc)
	else
		local h =math.modf(_UP_LEVEL_TIME/(60*60))
		local m =math.modf((_UP_LEVEL_TIME - h*60*60)/60)

		if h == 0 and m == 0 then
			local desc = string.format("剩余时间:%s秒",_UP_LEVEL_TIME)
			_TIME_LABEL:setText(desc)
		else
				local desc = string.format("剩余时间:%s时%s分",h,m)
			_TIME_LABEL:setText(desc)
		end


	end

	if not i3k_db_faction_uplvl[self._faction_lvl + 1] then
		_ACTION.stop()
		return
	end

	if _UP_LEVEL_TIME <= 0 then
		_UP_LABEl:setText("升级")
		if not self.addTouchEventFlag then
			_UP_BTN:onTouchEvent(self,self.onUpLvl)
			self.addTouchEventFlag = true
		end
		_ACIMAGE:show()
		_ACTION.play(-1)
		return true
	end
end

function wnd_faction_main:onGarrisonUI(sender)
	g_i3k_logic:OnOpenFactionZone()
end

function wnd_faction_main:onFactonWareHouse(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionWareHouse)
	i3k_sbean.sectshare_sync()
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_main.new();
		wnd:create(layout, ...)

	return wnd
end

function wnd_faction_main:getBtnPosition()
	local btnSize = self.faction_sect_btn:getParent():getContentSize()
	local sectPos = self.faction_sect_btn:getPosition()
	local btnPos = self.faction_sect_btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_main:getBtnPosition2()
	local btnSize = self._layout.vars.faction_sect_btn2:getParent():getContentSize()
	local sectPos = self._layout.vars.faction_sect_btn2:getPosition()
	local btnPos = self._layout.vars.faction_sect_btn2:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_main:refresh()
	self:updateMainBg()
	self:updateCreed(g_i3k_game_context:GetFactionCreed())
	self:updateBaseData(g_i3k_game_context:GetFactionLevel(),g_i3k_game_context:GetFactionSectId(),g_i3k_game_context:GetFactionCurrentMemberCount(),
	g_i3k_game_context:GetFactionUpGradeTime())
	self:updateFactionName(g_i3k_game_context:GetFactionName())
	self:updateFactionIcon(g_i3k_game_context:GetFactionIcon())
	self:updateFactionFrame(g_i3k_game_context:GetFactionFrame())
	self:updateMyContribution(g_i3k_game_context:GetSectContribution())
	self:updateDragonCrystal(g_i3k_game_context:getDragonCrystal())
	self:updateApplyPoint()
	self:updateDinePoint()
	self:updateTaskPoint()
	self:updateFightGroupPoint()
	self:updateFationQq(g_i3k_game_context:GetFactionQq())
	self:refreshWareHouseBt()
	--同步弹幕
	g_i3k_game_context:initShootMsgData()
	i3k_sbean.request_sect_popmsg_sync_req()
end

function wnd_faction_main:refreshWareHouseBt()
	local value = self._faction_lvl >= i3k_db_crossRealmPVE_shareCfg.needGroupLevel and g_i3k_game_context:GetLevel() >= i3k_db_crossRealmPVE_shareCfg.needPlayerLevel
	self._layout.vars.factionWareHouse:setVisible(value)
end

function wnd_faction_main:openLuckStar()
	if g_i3k_game_context:GetLevel() >= i3k_db_luckyStar.cfg.limitLvl  then
		i3k_sbean.lucklystar_sync_req_send()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16870,i3k_db_luckyStar.cfg.limitLvl))
	end
end

local TIMER = require("i3k_timer");
i3k_game_timer_faction_mian = i3k_class("i3k_game_timer_faction_mian", TIMER.i3k_timer)

function i3k_game_timer_faction_mian:Do(args)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionMain,"setUpTime")
end

function i3k_game_timer_faction_mian:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_faction_mian.new(1000))

	end
end

function i3k_game_timer_faction_mian:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end


--弹幕功能
function wnd_faction_main:getShootMsg()
	local ret = nil
	local shootMsgData = g_i3k_game_context:getShootMsgData()
	if #shootMsgData > 0 then
		if self.shootMsgIndex > #shootMsgData then
			self.shootMsgIndex = 1
		end
		ret = shootMsgData[self.shootMsgIndex]
		self.shootMsgIndex = self.shootMsgIndex + 1
	end
	return ret
end

function wnd_faction_main:runOneAction(shootLabel)
	local data = self:getShootMsg()
	if not data then
		return
	end
	if data.roleId == g_i3k_game_context:GetRoleId() then
		shootLabel:setText("<u>" .. data.msg .. "</u>")
	else
		shootLabel:setText(data.msg)
	end
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	local posY = shootLabel:getPositionY()
	shootLabel:setPosition(visibleSize.width,posY)
	local randomColor = i3k_db_common.shootMsg.color
	shootLabel:setTextColor(randomColor[i3k_engine_get_rnd_u(1,#randomColor)])
	g_i3k_ui_mgr:AddTask(self, {shootLabel}, function(ui)
		if shootLabel then
			local width = shootLabel:getInnerSize().width
			local s = visibleSize.width + width + 50
			local speedMax = i3k_db_common.shootMsg.speedMax
			local speedMin = i3k_db_common.shootMsg.speedMin
			local v = i3k_engine_get_rnd_f(speedMin,speedMax)
			local t = s / v
			shootLabel:runAction(
				cc.Sequence:create(
					cc.MoveTo:create(t, cc.p(-(width + 50),posY)),
					cc.CallFunc:create(function ()
						self:runOneAction(shootLabel)
					end)
				)
			)
		end
	end,1)
end


function wnd_faction_main:showOneShootMsg()
	if self.haveShowedShootMsg < 20 then
		self.haveShowedShootMsg = self.haveShowedShootMsg + 1
		local shootLabel = self._layout.vars["shootMsg" .. self.haveShowedShootMsg]
		self:runOneAction(shootLabel)
	end
end
function wnd_faction_main:ctrlShootMsg(state)
	self.shootMsgState = state
	self._layout.vars.shootMsg_btn:setVisible(state)
	if state then
		self._layout.vars.showMsgBtn:setImage(g_i3k_db.i3k_db_get_icon_path(5447))
	else
		self._layout.vars.showMsgBtn:setImage(g_i3k_db.i3k_db_get_icon_path(5446))
	end

	for i = 1,20,1 do
		local shootLabel = self._layout.vars["shootMsg" .. i]
		shootLabel:setVisible(state)
	end
end

function wnd_faction_main:openFCBS()
	local timeStamp = i3k_game_get_time()
	if timeStamp - g_i3k_game_context:getlastjointime() < i3k_db_factionBusiness.cfg.needTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17128, math.floor(i3k_db_factionBusiness.cfg.needTime/3600)))
		return
	end
	if g_i3k_game_context:GetLevel() >= i3k_db_factionBusiness.cfg.openLvl then
		i3k_sbean.sect_trade_routeReq()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17120))
	end
end
--帮派合照
function wnd_faction_main:onTakePhoto()
	if i3k_get_engine_version() >= g_ENGINE_VERSION_1001 then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionPhotoTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionPhotoTips)	
	else
		g_i3k_ui_mgr:ShowTopMessageBox1(i3k_get_string(1774))
	end
end
