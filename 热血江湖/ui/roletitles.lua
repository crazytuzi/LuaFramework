-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_roleTitles = i3k_class("wnd_roleTitles", ui.wnd_profile)

local CHENGHAOT = "ui/widgets/chenghaot"
local CHENGHAOT2 = "ui/widgets/chenghaot2"
local CHENGHAOT3= "ui/widgets/chenghaot3"

function wnd_roleTitles:ctor()
	self.showType = 0
	self.titleType = {[1] = 1, [2] = -1} --大于0解锁称号，小于0是未解锁称号
	self._id = nil
	self._type = 0
	self._info = {}
	self._isHideLeftData = false
	self._recordPresent = nil
end

function wnd_roleTitles:configure()
	local widgets = self._layout.vars

	self.scroll = widgets.scroll

	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	--self.red_point = widgets.red_point
	--self.bg_redPoint = widgets.bg_redPoint
	self.dressTitleBg = widgets.dressTitleBg
	self.dressTitle = widgets.dressTitle
	self.dressTitleLab = widgets.dressTitleLab
	self.timeDesc = widgets.timeDesc
	--self.sz_redPoint = widgets.sz_redPoint
	--widgets.fashion_btn:stateToNormal()
	--widgets.bag_btn:stateToNormal()
	widgets.role_btn:stateToNormal()
	widgets.roleTitle_btn:stateToPressed()
	widgets.role_btn:onClick(self, self.onRoleBtn)
	widgets.reqBtn:onClick(self, self.onRepBtn)
	widgets.xinjueBtn:onClick(self, self.onXinjueBtnClick)
	widgets.propertyBtn:onTouchEvent(self, self.showProperty)

	local isHave = g_i3k_game_context:GetAllRoleTitle()
	if next(isHave) ~= nil then
		self.showType = 1
		self._layout.vars.all_btn:stateToPressed(true)
	else
		self.showType = 2
		self._layout.vars.equip_btn:stateToPressed(true)
	end
	self.fashionTypeButton = {widgets.all_btn, widgets.equip_btn}
	for i, e in ipairs(self.fashionTypeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
	end

	--self.revolve = widgets.revolve
	--self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
end

--[[function wnd_roleTitles:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleTitles)
end --]]

function wnd_roleTitles:refresh()
	self:updateScroll(nil, 1)
	self:updateTitlePlace()
	--self:updateRecover()
	local _,level = g_i3k_game_context:GetRoleDetail()
	self._layout.vars.xinjueBtn:setVisible(level >= i3k_db_xinjue.showLevel)
	self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
end

function wnd_roleTitles:updateScroll(titleId, newTypeID)
	self.scroll:removeAllChildren()
	local isHave = g_i3k_game_context:GetAllRoleTitle()
	local items = g_i3k_db.i3k_db_get_roleTitle_type(self.titleType[self.showType], g_i3k_game_context:GetRoleType())
	local nowTimeTitle = g_i3k_game_context:GetEquipTimedTitle()
	local nowForeverTitle = g_i3k_game_context:GetNowEquipTitle()
	local allEquipTitle = g_i3k_game_context:GetAllEquipTitles()
	--self.dressTitleBg:hide()
	--self.dressTitle:hide()
	--self.dressTitleLab:hide()
	local newItems = self:sortTitle(items)
	local sameTimeType = 0
	local lastTime = 0
	local _info = {}

	--local id = self._id
	if self.titleType[self.showType] > 0 then
		for i, e in ipairs(newItems) do
			if e.isShow == 1 then
			local _layer1 = require(CHENGHAOT)()
			local widget = _layer1.vars
			widget.btnNode:setVisible(false)
			for k,v in ipairs(allEquipTitle) do
				if e.id == v then
					widget.btnNode:setVisible(true)
					_info[e.titleType] = {id = e.id, time = e.time}
				end

			end
			if titleId == nil and i == 1 then
				self:refreshLeftData(e, widget)
			end
			self:updatCell(widget, e, titleId)
			self.scroll:addItem(_layer1)
			end
		end
		self._info = _info
		if self._recordPresent then
			self.scroll:jumpToListPercent(self._recordPresent)
		end
	else
		local allIndex = 0
		local newData = {}
		local index = 1
		local recordIndex = 0
		local newTmp = {}

		for k,v in pairs(i3k_db_roleTitle_type) do
			table.insert(newTmp, v)
		end
		table.sort(newTmp, function (a,b)
			return a.typeId < b.typeId
		end)
		for k,v in ipairs(newTmp) do
			local _layer1 = require(CHENGHAOT2)()
			local widget = _layer1.vars
			widget.openImg:setVisible(v.typeId == newTypeID)
			widget.pickupImg:setVisible(v.typeId ~= newTypeID)
			widget.nameLabel:setText(v.name)
			self.scroll:addItem(_layer1)
			if newTypeID == v.typeId then
				for i,e in ipairs(newItems) do
					if newTypeID == e.titleType then
						if e.isShowTitles == 0 and e.isShow == 1 then
							allIndex = allIndex + 1
							--local order = e.quality + 1000
							table.insert(newData, e)
						end
					end
				end
				table.sort(newData, function (a,b)
					return a.quality < b.quality
				end)
				index = k
				self.timeDesc:setVisible(false)
				local children = self.scroll:addItemAndChild(CHENGHAOT3,2,allIndex)
				widget.btn:onClick(self, self.showDataForType, {typeId = v.typeId, index = k, allIndex = allIndex})
				widget.btn:stateToPressed()
				local cout = 0
				for i,e in pairs(newData) do
					--local _layer1 = require(CHENGHAOT)()
					local widgets = children[i].vars
					widgets.showTipsBtn:onClick(self, self.showTips, {info = e, widget = widgets})
					widgets.name_label:setVisible(false)
					widgets.headBg:setVisible(true)
					widgets.head:setVisible(true)
					--widgets.warnBg:setVisible(false)
					--widgets.equipBtn:setVisible(false)
					--widgets.isShow:setVisible(false)
					widgets.headBg:setImage(g_i3k_db.i3k_db_get_icon_path(e.iconbackground))
					widgets.head:setImage(g_i3k_db.i3k_db_get_icon_path(e.name))
					cout = cout + 1
					if cout == 1 then
						self._id = e.id
					end
				end
			else
				widget.btn:onClick(self, self.selectItemType, v.typeId)
			end

		end
		self.scroll:jumpToChildWithIndex(index)
	end


end

function wnd_roleTitles:showDataForType(sender,data)
	local children = self.scroll:getAllChildren()
	for i=1, data.allIndex do
		self.scroll:removeChildAtIndex(data.index + 1)
	end
	children[data.index].vars.btn:onClick(self, self.selectItemType, data.typeId)
	children[data.index].vars.openImg:hide()
	children[data.index].vars.pickupImg:show()
end

function wnd_roleTitles:selectItemType(sender, typeId)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleTitles, "updateScroll", nil, typeId)
end

function wnd_roleTitles:sortTitle(sort_items) --排序并列表
	local tmp = {}
	local isHave = g_i3k_game_context:GetAllRoleTitle()
	local nowEquipTitle = g_i3k_game_context:GetNowEquipTitle()
	for i, e in ipairs(sort_items) do
		local attribute = {}
		local value = {}
		for k=1, 5 do
			attribute[k] = e["attribute" .. k]
			value[k]	 = e["value" .. k]
		end
		table.insert(tmp, {
							id = e.id,
							titleType = e.titleType,
							name = e.name,
							foreverName = e.foreverName,
							nameDesc = e.nameDesc,
							time = e.time,
							attribute = attribute,
							value = value,
							iconbackground = e.iconbackground,
							quality = e.quality,
							isShowTitles = e.isShowTitles,
							isShow = e.isShow
							})
	end
	if self.titleType[self.showType] > 0 then
		table.sort(tmp, function (a,b)
			return a.quality < b.quality
		end)
	end

	return tmp
end

function wnd_roleTitles:updatCell(widget, info, titleId)
	widget.name_label:setVisible(false)
	widget.headBg:setVisible(true)
	widget.head:setVisible(true)
	widget.headBg:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconbackground))
	widget.head:setImage(g_i3k_db.i3k_db_get_icon_path(info.name))
	widget.warnBg:setVisible(false)
	if self.titleType[self.showType] < 0 then
		widget.warnBg:setVisible(false)
	else
		if info.time > 0 then
			local isHave = g_i3k_game_context:GetAllRoleTitle()
			for k,v in pairs(isHave) do
				if info.id == k then
					local serverTime = i3k_game_get_time()
					serverTime = i3k_integer(serverTime)
					if v - serverTime <= i3k_db_common.roleTitles.titleWarningTime then
						widget.warnBg:setVisible(true)
					end
				end
			end
		end
	end
	local haveTitles = g_i3k_game_context:GetAllRoleTitle()
	widget.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(708))
	widget.equipBtn:setVisible(false)
	widget.isShow:setVisible(false)
	for k,v in pairs(haveTitles) do
		if k == info.id then
			widget.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(707))
			widget.equipBtn:setVisible(true)
			widget.isShow:setVisible(true)
			widget.equipBtn:onClick(self, self.equipTitle,{widget = widget, id = info.id, titleType = info.titleType, name = info.name, iconbackground = info.iconbackground, time = info.time, v = v})

		end

	end
	if titleId == info.id then
		widget.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	end
	widget.showTipsBtn:onClick(self, self.showTips,  {info = info, widget = widget, noHave = false})
end

function wnd_roleTitles:equipTitle(sender,data)
	self._recordPresent = self.scroll:getListPercent()
	self:setCellIsSelectHide(data.id)
	data.widget.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	--self.dressTitleLab:setVisible(false)
	--self.dressTitleBg:setVisible(true)
	--self.dressTitle:setVisible(true)
	self._id = data.id
	--self.dressTitleBg:setImage(g_i3k_db.i3k_db_get_icon_path(data.iconbackground))
	--self.dressTitle:setImage(g_i3k_db.i3k_db_get_icon_path(data.name))
	self:showEquipTitle(data)
end


function wnd_roleTitles:showEquipTitle(info)
	self._isHideLeftData = false
	if next(self._info) ~= nil then
		local _info = self._info
		for k,v in pairs(self._info) do
			if info.id == v.id then
				info.widget.btnNode:setVisible(false)
				if info.time > 0 then
					i3k_sbean.goto_timedtitle_set(info.id, 0, info.titleType)     -- 卸下时效称号(参数2区分)
				else
					i3k_sbean.goto_permanenttitle_set(0, 0, info.id, info.titleType) -- 卸下永久称号
				end
				self._isHideLeftData = true
				return
			end
		end
	end
		if info.time > 0 then
			i3k_sbean.goto_timedtitle_set(info.id, 1, info.titleType)     -- 装备时效称号
		else
			i3k_sbean.goto_permanenttitle_set(info.id, 1, info.id) -- 装备永久称号
		end
end

function wnd_roleTitles:onUpdate(dTime)
	local haveTitles = g_i3k_game_context:GetAllRoleTitle()
	local endTime = 0
	for k,v in pairs(i3k_db_title_base) do
		if self._id == v.id then
			endTime = v.time
			break
		end
	end
	local isHaveTitle = false
	for k,v in pairs(haveTitles) do
		if self._id == k then
			endTime = v
			isHaveTitle = true
			break
		end
	end
	if self._id then
		if self._isHideLeftData then
			self.timeDesc:setVisible(false)
			--self.dressTitleBg:setVisible(false)
		else
			self.timeDesc:setVisible(true)
			self.dressTitleLab:setVisible(false)
			--self.dressTitleBg:setVisible(true)
			--self.dressTitle:setVisible(true)
		end
		--self.dressTitleBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_title_base[self._id].iconbackground))
		--self.dressTitle:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_title_base[self._id].name))
		if endTime > 0 then
			if isHaveTitle then
				local serverTime = i3k_game_get_time()
				serverTime = i3k_integer(serverTime)
				if serverTime < endTime then
					local nowTime = endTime - serverTime
					--local day = math.modf(nowTime/(3600*24))
					local hour = math.modf(nowTime/(3600*24) * 24)
					local min = math.fmod(math.floor(nowTime/60), 60)
					local sec = math.fmod(nowTime, 60)
					local str
					--if day >= 1 then
						--str = string.format("剩余%s天",day)
					if hour >= 1 then
						str = string.format("剩余%s小时%s分钟",hour,min)
					elseif hour < 1 then
						str = string.format("剩余%s分钟%s秒", min, sec)
					end
					self.timeDesc:setText("时效:" .. str)
				else
					--时效称号到期
					g_i3k_game_context:SetAllEquipTitles(self._id, 0)
					self.timeDesc:setVisible(false)
				end
			else
				local nowTime = endTime
				--local day = math.modf(nowTime/(3600*24))
				local hour = math.modf(nowTime/(3600*24) * 24)
				local min = math.fmod(math.floor(nowTime/60), 60)
				local sec = math.fmod(nowTime, 60)
				local str
				--if day >= 1 then
				--	str = string.format("保存%s天",day)
				if hour >= 1 then
					str = string.format("保存%s小时%s分钟",hour,min)
				elseif hour < 1 then
					str = string.format("保存%s分钟%s秒", min, sec)
				end
				self.timeDesc:setText("时效:" .. str)
			end
		else
			self.timeDesc:setText("时效: 永久")
		end
	else
		self.timeDesc:setVisible(false)
	end
end

function wnd_roleTitles:refreshLeftData(info, widget)
	self:setCellIsSelectHide(info.id)
	widget.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	--self._id = info.id
end

function wnd_roleTitles:showTips(sender, data)
	local cfg = i3k_db_title_base[data.info.id]
	self._isHideLeftData = false
	if data.noHave and data.noHave == false then
		self:setCellIsSelectHide(data.info.id)
		data.widget.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(706))
	end
	self._id = data.info.id
	if cfg and cfg.isDynamic == 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_DynamicTitle)
		g_i3k_ui_mgr:RefreshUI(eUIID_DynamicTitle, data.info)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_RoleTitlesProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleTitlesProperty, data.info)
	end
end

function wnd_roleTitles:showProperty(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_RoleTitlesAllProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleTitlesAllProperty)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_RoleTitlesAllProperty)
		end
	end
end


function wnd_roleTitles:onShowTypeChanged(sender, tag)
	self:setFashionShowType(tag)
end

function wnd_roleTitles:setFashionShowType(showType)
	if self.showType ~= showType then
		self.showType = showType
		for i, e in ipairs(self.fashionTypeButton) do
			e:stateToNormal(true)
		end

		self.timeDesc:setVisible(false)
		self.fashionTypeButton[showType]:stateToPressed(true)
		self:updateScroll(nil, 1)
		self._id = nil
		self.scroll:jumpToListPercent(0)
	end
end

function wnd_roleTitles:setCellIsSelectHide(id)
	for i, e in pairs(self.scroll:getAllChildren()) do
		if e.vars.isHave then
			local haveTitles = g_i3k_game_context:GetAllRoleTitle()
			e.vars.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(708))
			for k,v in pairs(haveTitles) do
				if k == id then
					e.vars.isHave:setImage(g_i3k_db.i3k_db_get_icon_path(707))
					break
				end
			end
		end
	end
end

function wnd_roleTitles:updateTitlePlace()
	local titles = g_i3k_game_context:GetAllEquipTitles()
	local index = 0
	for i=#titles, 1, -1 do
		index = index + 1
		local info = i3k_db_title_base[titles[i]]
		if info then
			self._layout.vars["bg_"..index]:show()
			self._layout.vars["bg_"..index]:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconbackground))
			self._layout.vars["icon_"..index]:setImage(g_i3k_db.i3k_db_get_icon_path(info.name))
			if self._layout.vars["show_"..index] then
				self._layout.vars["show_"..index]:hide()
				self._layout.vars["lock_"..index]:hide()
				self._layout.vars["btn_"..index]:hide()
			end
		end
	end
	local unlock = g_i3k_game_context:getTitlesUnlockPlace()
	if unlock > index then
		for i=index+1, unlock do
			index = index + 1
			self._layout.vars["bg_"..i]:hide()
			if self._layout.vars["show_"..i] then
				self._layout.vars["show_"..i]:show()
				self._layout.vars["lock_"..i]:hide()
				self._layout.vars["btn_"..i]:hide()
			end
		end
	end
	local count = 1 + (#i3k_db_common.roleTitles.clearPrice)
	if index < count then
		for i=index+1, count do
			self._layout.vars["bg_"..i]:hide()
			if self._layout.vars["show_"..i] then
				self._layout.vars["show_"..i]:hide()
				self._layout.vars["lock_"..i]:show()
				self._layout.vars["btn_"..i]:show()
				self._layout.vars["btn_"..i]:onClick(self, self.unlockPlace, i)
			end
		end
	end
end

function wnd_roleTitles:unlockPlace(sender,index)
	if index ~= g_i3k_game_context:getTitlesUnlockPlace() + 1 then
		local str = string.format("需要先解锁槽位元%s", g_i3k_game_context:getTitlesUnlockPlace() + 1)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end
	local function callback(isOk)
		if isOk then
			local haveDiamond = g_i3k_game_context:GetDiamondCanUse(true)
			if haveDiamond >= i3k_db_common.roleTitles.clearPrice[index-1] then
				i3k_sbean.titleslot_unlock(index)
			else
				local tips = string.format("%s", "您的元宝不足，解锁失败")
				g_i3k_ui_mgr:PopupTipMessage(tips)
			end
		end
	end
	local str = string.format("是否花费%s元宝解锁新槽位？", i3k_db_common.roleTitles.clearPrice[index-1])
	g_i3k_ui_mgr:ShowMessageBox2(str, callback)
end

function wnd_roleTitles:onFashionBtn()
	g_i3k_logic:OpenFashionDressUI(nil, eUIID_RoleTitles)
end

function wnd_roleTitles:onRoleBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_RoleTitles)
	g_i3k_logic:OpenRoleLyUI()
end

function wnd_roleTitles:onRepBtn()
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local openLevel = g_i3k_db.i3k_db_power_rep_get_open_min_level()
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage("势力声望在"..openLevel.."级开启")
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_RoleTitles)
	g_i3k_logic:OpenReputationUI()
end

function wnd_roleTitles:onXinjueBtnClick()
	local _,level = g_i3k_game_context:GetRoleDetail()
	if level < i3k_db_xinjue.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s级解锁心决",i3k_db_xinjue.openLevel))
	else
		g_i3k_ui_mgr:CloseUI(eUIID_RoleTitles)
		g_i3k_logic:OpenXinJueUI()
	end
end

function wnd_roleTitles:onBagBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_RoleTitles)
	g_i3k_logic:OpenBagUI()
end

function wnd_create(layout)
	local wnd = wnd_roleTitles.new()
	wnd:create(layout)
	return wnd
end
