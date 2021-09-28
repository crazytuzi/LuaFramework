module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_equipSharpen = i3k_class("wnd_equipSharpen", ui.wnd_base)


local SelectBglist = {707, 706}
local POWER_UP_IMG_ID = 174
local POWER_DOWN_IMG_ID = 175
local POWER_EQUAL_IMG_ID = 176

function wnd_equipSharpen:ctor()

end

function wnd_equipSharpen:configure()
	self._curSelectEquipID = nil -- 当前选中的装备id

	local widgets = self._layout.vars
	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self, self.addCoinBtn)
	widgets.close_btn:onClick(self, self.onClose)
	widgets.sharpenBtn:onClick(self, self.onSharpen)
	widgets.help_bt:onClick(self, self.showHelp)
	widgets.saveBtn:onClick(self, self.onSave)
	widgets.saveBtn:hide()
	self:initPartBtn()
	self:setUIVisiable(false)
end

function wnd_equipSharpen:initPartBtn()
	local widgets = self._layout.vars
	for i = 1, eEquipSharpen do
		local btnName = "part"..i
		widgets[btnName]:onClick(self, self.onPartBtn, i)
	end
end

function wnd_equipSharpen:setUIVisiable(bValue)
	local widgets = self._layout.vars
	widgets.equipName:setVisible(bValue)
	widgets.equipName:setVisible(bValue)
	widgets.equipLvl:setVisible(bValue)
	widgets.equipLvl:setVisible(bValue)
	widgets.partName:setVisible(bValue)
	widgets.powerImg:setVisible(bValue)
	widgets.equipPower:setVisible(bValue)
	widgets.equipType:setVisible(bValue)
	widgets.oriPowerRoot:setVisible(bValue)
	widgets.sharpenRoot:setVisible(bValue)
	widgets.canTradeLabel:setVisible(bValue)
	widgets.equipTrans:setVisible(bValue)
	widgets.equipBtn:setTouchEnabled(bValue)
	if not bValue then
		widgets.lockImg:hide()
		widgets.equipIcon:setImage(g_i3k_db.i3k_db_get_icon_path(2396))
		widgets.equipBg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
		local scroll = self._layout.vars.propScroll
		scroll:removeAllChildren()
		self._layout.vars.sharpenScroll:removeAllChildren()
		self._layout.vars.itemlistview:removeAllChildren()
		widgets.sjtx1:hide()
		widgets.sjtx2:hide()
	end
end

function wnd_equipSharpen:onShow()
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true),g_i3k_game_context:GetMoney(false))
	self:onPartBtn(nil, 1) -- 界面刚打开，默认选中第一个

end

function wnd_equipSharpen:refresh()

end

-- 点击装备部位
function wnd_equipSharpen:onPartBtn(sender, index)
	local func = function (index)
		self:updatePartBtnState(index)
		self._selectPart = index -- 存一下装备的部位
		local equips = g_i3k_db.i3k_db_get_equip_sharpen_list(index)
		self:setEquipScroll(equips)
	end
	local flag = self:getPowerUpFlag()
	if flag then
		local callback = function(ok)
			if ok then
				self:setPowerUpFlag(false)
				func(index)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback) --当前未保存的淬锋结果拥有更高战力，确认退出吗？
		return
	else
		func(index)
	end
end

-- 设置装备滚动条
function wnd_equipSharpen:setEquipScroll(data)
	self._selectLocks = nil
	self._selectEquipID = nil
	self:setUIVisiable(false)
	local scroll = self._layout.vars.equipScroll
	scroll:removeAllChildren()
	local firstBtnData = nil
	for k, v in ipairs(data) do
		local equipID = v.id
		local equipGuid = v.guid
		local widget = require("ui/widgets/zbsct2")()
		widget.vars.productionlvl:hide()
		if not v.inBag then
			widget.vars.productionlvl:show()
			widget.vars.productionlvl:setText(i3k_get_string(1028))
		end
		widget.vars.productionexp:hide()
		widget.vars.productionwarn:hide()
		self:setLegend(widget.vars, v.inBag, equipID, equipGuid)
		widget.vars.lockImg:setVisible(equipID > 0)
		local info = {id = equipID, guid = equipGuid, index = k, inBag = v.inBag}
		widget.vars.productionbtn:onClick(self, self.onSelectEquip, info)
		widget.vars.productionbtn:stateToPressed()
		if not firstBtnData then
			firstBtnData = info
		end
		local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
		widget.vars.productionName:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
		widget.vars.productionName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(equipID)))
		widget.vars.productionrank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
		widget.vars.productionicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
		scroll:addItem(widget)
	end
	if firstBtnData then
		self:onSelectEquip(nil, firstBtnData) -- 模拟点击第一个按钮
	end
end

function wnd_equipSharpen:setLegend(widget, inBag, equipID, equipGuid)
	if inBag then
		local equip = g_i3k_game_context:GetBagEquip(equipID, equipGuid)
		if equip.naijiu and equip.naijiu ~= -1 then
			local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(equipID, equip.naijiu)
			if rankIndex ~= 0 then
				local index = rankIndex == 1 and 2 or 1
				widget["sjtx"..index]:show()
			end
		end
	else
		local wearEquips = g_i3k_game_context:GetWearEquips()
		for i, v in ipairs(wearEquips) do
			if v.equip and v.equip.equip_id == equipID and v.equip.equip_guid == equipGuid then
				local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(equipID, v.equip.naijiu)
				if rankIndex ~= 0 then
					local index = rankIndex == 1 and 2 or 1
					widget["sjtx"..index]:show()
				end
			end
		end
	end
end


function wnd_equipSharpen:onSelectEquip(sender, data)
	local func = function (data)
		self._selectLocks = nil
		self._selectEquipID = data.id
		self._selectGuid = data.guid
		self:setEquipData(data.id, data.guid, data.inBag)
		self:updateEquipScrollBtnState(data.index)
		self._layout.vars.saveBtn:hide()
		local scroll = self._layout.vars.sharpenScroll
		scroll:removeAllChildren()
	end
	local flag = self:getPowerUpFlag()
	if flag then
		local callback = function(ok)
			if ok then
				func(data)
				self:setPowerUpFlag(false)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback) --当前未保存的淬锋结果拥有更高战力，确认退出吗？
		return
	else
		func(data)
	end
end

-- 设置装备原有属性，名字等
function wnd_equipSharpen:setEquipData(equipID, guid, inBag)
	if equipID ~= self._selectEquipID or self._selectGuid ~= guid then
		self._selectLocks = nil
		self._allMaxFlag = nil
	end
	self:setUIVisiable(true)
	local widgets = self._layout.vars
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	widgets.sjtx1:hide()
	widgets.sjtx2:hide()
	self:setLegend(widgets, inBag, equipID, guid)
	widgets.equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
	widgets.equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	widgets.equipName:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	widgets.equipName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(equipID)))
	widgets.lockImg:setVisible(equipID > 0)
	widgets.equipLvl:setText(equipCfg.levelReq.."级")
	if g_i3k_game_context:GetLevel() < equipCfg.levelReq then
		widgets.equipLvl:setTextColor(g_i3k_game_context:GetRedColour())
	end
	widgets.equipLvl:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= equipCfg.levelReq))
	widgets.partName:setText(i3k_db_equip_part[equipCfg.partID].partName)
	local roleName = TYPE_SERIES_NAME[equipCfg.roleType]
	widgets.equipType:setText(roleName)
	-- if equipCfg.roleType ~= 0 and equipCfg.roleType ~= g_i3k_game_context:GetRoleType() then
	-- 	widgets.equipType:setTextColor(g_i3k_get_cond_color(false))
	-- end
	local C_require = equipCfg.C_require
	local M_require = equipCfg.M_require
	local roleStr = ""
	local bwtype = g_i3k_game_context:GetTransformBWtype()
	local bwCheck = bwtype == M_require
	if M_require == 1 then
		roleStr = "转".."  正"
	elseif M_require == 2 then
		roleStr = "转".."  邪"
	elseif M_require == 0 then
		roleStr = "转"
	end
	widgets.equipTrans:setText(C_require..roleStr)
	-- if not bwCheck then
	-- 	widgets.equipTrans:setTextColor(g_i3k_get_cond_color(false))
	-- end
	widgets.canTradeLabel:setText(g_i3k_db.i3k_db_get_common_item_can_sale(equipID) and equipID < 0 and "可交易" or "不可交易")
	widgets.canTradeLabel:setTextColor(g_i3k_get_cond_color(g_i3k_db.i3k_db_get_common_item_can_sale(equipID) and equipID < 0))
	local power = 0
	if inBag then
		self._selectInBag = true
		local equip = g_i3k_game_context:GetBagEquip(equipID, guid)
		local attribute = equip.attribute
		self:setPropScroll(equipCfg.ext_properties, attribute, equipID)
		power = g_i3k_game_context:GetBagEquipPower(equip.equip_id, equip.attribute, equip.naijiu, equip.refine, equip.legends, equip.smeltingProps)
		local info = {id = equipID, guid = guid}
		widgets.equipBtn:onClick(self, self.onEquipCompareBtn, info)
	else
		self._selectInBag = false
		local wearEquips = g_i3k_game_context:GetWearEquips()
		local equip = wearEquips[self._selectPart].equip
		local attribute = equip.attribute
		self:setPropScroll(equipCfg.ext_properties, attribute, equipID)
		power = g_i3k_game_context:GetBagEquipPower(equip.equip_id, equip.attribute, equip.naijiu, equip.refine, equip.legends, equip.smeltingProps)
		local info = {equip = wearEquips[self._selectPart].equip}
		widgets.equipBtn:onClick(self, self.onEquipBtn, info)
	end
	widgets.equipPower:setText(power)

end

function wnd_equipSharpen:onEquipBtn(sender, info)
	g_i3k_ui_mgr:ShowCommonEquipInfo(info.equip,true)
end
function wnd_equipSharpen:onEquipCompareBtn(sender, info)
	g_i3k_ui_mgr:ShowCommonEquipInfo(g_i3k_game_context:GetBagEquip(info.id, info.guid))
end

-- 设置显示原有的附加属性
function wnd_equipSharpen:setPropScroll(props, attribute, equipID)
	self._layout.vars.sharpenRoot:hide()
	self._oldAttr = attribute
	local scroll = self._layout.vars.propScroll
	scroll:removeAllChildren()
	local allMaxFlag = true
	if props and type(props) == "table" then
		local propDB = {}
		for k, v in ipairs(props) do
			if v.type ~= 0 then
				local widget = require("ui/widgets/zbcft1")()
				widget.vars.arrow:hide() -- 箭头隐藏掉
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipID, k, attribute[k])
				if max then
					widget.vars.maxImg:show()
					widget.vars.selectBtn:stateToNormal()
					if self._selectLocks then
						self._selectLocks[k] = nil
					end
				else
					allMaxFlag = false
				end
				local cfg = i3k_db_prop_id[v.args]
				local name = cfg.desc
				local colour1 = cfg.textColor
				local colour2 = cfg.valuColor
				widget.vars.name:setText(name)
				widget.vars.value:setText("+"..i3k_get_prop_show(v.args, attribute[k]))
				propDB[v.args] = (propDB[v.args] or 0) + attribute[k]
				local btnInfo = { id = k, max = max}
				widget.vars.selectBtn:onClick(self, self.onSelectLock, btnInfo)
				if self._selectLocks and self._selectLocks[k] then
					widget.vars.selectBtn:stateToPressed()
				end
				scroll:addItem(widget)
			end
		end
		local power = g_i3k_db.i3k_db_get_battle_power(propDB);
		self._layout.vars.powerLabel:setText(power)
		self._oldPower = power
	end
	self._allMaxFlag = allMaxFlag
	self:setConsumeData()
end

-- 点击上锁按钮
function wnd_equipSharpen:onSelectLock(sender, info)
	if info.max then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1029)) --此属性已满，无需加锁，淬锋也不会再改变数值
		return
	end
	local isPressed = sender:isStatePressed()
	if isPressed then
		sender:stateToNormal()
		self._selectLocks[info.id] = nil
	else
		sender:stateToPressed()
		if not self._selectLocks then
			self._selectLocks = {}
		end
		self._selectLocks[info.id] = true
	end
	self:setConsumeData()
end

function wnd_equipSharpen:setConsumeData()
	local part = self._selectPart
	local lockCount = 0
	local isNeedItemEnough = true
	if self._selectLocks then
		for k, v in pairs(self._selectLocks) do
			if v == true then
				lockCount = lockCount + 1
			end
		end
	end
	local consume = g_i3k_db.i3k_db_get_equip_sharpen_need_items(part, lockCount)
	local scroll = self._layout.vars.itemlistview
	scroll:removeAllChildren()
	if consume and type(consume) == "table" then
		for i, v in ipairs(consume) do
		    local widget = require("ui/widgets/zbcft")()
			if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN then
				widget.vars.item_lock:show()
			    widget.vars.item_count:setText(v.count)
			elseif v.id == -g_BASE_ITEM_DIAMOND or v.id == -g_BASE_ITEM_COIN then
			        widget.vars.item_lock:hide()
			        widget.vars.item_count:setText(v.count)
			else
			    local number = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
				widget.vars.item_count:setText(string.format("%s/%s", number, v.count))
				widget.vars.item_lock:hide()
			end
			widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
            widget.vars.item_count:setTextColor(g_i3k_get_cond_color(v.count <= g_i3k_game_context:GetCommonItemCanUseCount(v.id)))
			isNeedItemEnough = isNeedItemEnough and (v.count <= g_i3k_game_context:GetCommonItemCanUseCount(v.id))
			widget.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			widget.vars.bt:onClick(self, self.tiShi, v.id)
			scroll:addItem(widget)
		end
	end
	self._needItemEnough = isNeedItemEnough
end

-- 设置显示淬锋过的新的附加属性（协议返回显示数据）
function wnd_equipSharpen:setSharpenScroll(props)
	self._layout.vars.sharpenRoot:show()
	self._layout.vars.saveBtn:show()
	self._sharpenPorps = props
	local oldAttr = self._oldAttr
	local scroll = self._layout.vars.sharpenScroll
	scroll:removeAllChildren()
	if props and type(props) == "table" then
		local propDB = {}
		for k, v in ipairs(props) do
			local widget = require("ui/widgets/zbcft1")()
			local imgID = self:getPowerChangeIMG(oldAttr[k], v.value)
			widget.vars.arrow:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
			local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(self._selectEquipID, k, v.value)
			if max then
				widget.vars.arrow:hide()
				widget.vars.maxImg:show()
			end
			local cfg = i3k_db_prop_id[v.id]
			local name = cfg.desc
			local colour1 = cfg.textColor
			local colour2 = cfg.valuColor
			widget.vars.name:setText(name)
			widget.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			propDB[v.id] = (propDB[v.id] or 0) + v.value
			widget.vars.selectBtn:hide()
			scroll:addItem(widget)
		end
		local power = g_i3k_db.i3k_db_get_battle_power(propDB)
		self._layout.vars.powerLabel2:setText(power)
		self._newPower = power
	end
	local imgID = self:getPowerChangeIMG(self._oldPower, self._newPower)
	if imgID == POWER_UP_IMG_ID then
		self:setPowerUpFlag(true)
	end
	self._layout.vars.powerChangeIMG:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
end

-- 根据战力，返回箭头变化的图片id
function wnd_equipSharpen:getPowerChangeIMG(oldPower, newPower)
	if oldPower < newPower then
		return POWER_UP_IMG_ID
	elseif oldPower > newPower then
		return POWER_DOWN_IMG_ID
	else
		return POWER_EQUAL_IMG_ID
	end
end

-- 保存一下战力变化的结果
function wnd_equipSharpen:setPowerUpFlag(bValue)
	self._powerUp = bValue
end

function wnd_equipSharpen:getPowerUpFlag()
	return self._powerUp
end

-- 选中滚动条中的一个，设置按钮的选中状态
function wnd_equipSharpen:updateEquipScrollBtnState(index)
	local scroll = self._layout.vars.equipScroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		if index == k then
			v.vars.productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[2]))
			v.vars.productionbtn:disable()
		else
			v.vars.productionselectbg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBglist[1]))
			v.vars.productionbtn:enable()
		end
	end
end

-- 更新按钮的选中状态
function wnd_equipSharpen:updatePartBtnState(index)
	local widgets = self._layout.vars
	for i = 1, 8 do
		local btnName = "part"..i
		if index == i then
			widgets[btnName]:stateToPressed(true)
		else
			widgets[btnName]:stateToNormal(true)
		end
	end
end

function wnd_equipSharpen:getSharpenData()
	if not self._selectEquipID then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1030)) --未选择任何装备
		return
	end
	local roleLevel = g_i3k_game_context:GetLevel()
	local openLevel = i3k_db_common.equipSharpen.openLevel
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1031,openLevel)) -- "装备淬锋"..openLevel.."级开启")
		return
	end
	local locks = {}
	if self._selectLocks then
		for k, _ in pairs(self._selectLocks) do
			table.insert(locks, k)
		end
	end
	local t = {
		id = self._selectEquipID,
		guid = self._selectGuid,
		pos = self._selectInBag and 0 or self._selectPart, -- 背包内道具，pos字段为0
		locks = locks
	}
	return t
end


function wnd_equipSharpen:onSharpen(sender)
	-- TODO 1.检查是否满足道具消耗的条件  2.检查上次淬锋的战力是否有提高   3.等等
	local data = self:getSharpenData()
	if data then
		local flag = self:getPowerUpFlag()
		if flag then
			local callback = function(ok)
				if ok then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipSharpen, "setPowerUpFlag", false)
					i3k_sbean.equipSharpen(data.id, data.guid, data.pos, data.locks)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback) --当前未保存的淬锋结果拥有更高战力，确认退出吗？
			return
		end
		local part = self._selectPart
		local count = 0
		for k, v in pairs(data.locks) do
			if v == true then
				count = count + 1
			end
		end
		if not self._needItemEnough then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1032)) --淬锋道具不足
			return
		end
		if self._allMaxFlag then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1033)) --淬锋已满，无需在继续淬锋
			return
		end

		i3k_sbean.equipSharpen(data.id, data.guid, data.pos, data.locks)
	end
end

function wnd_equipSharpen:savaSharpenCallback(equipID, guid)
	local props = self._sharpenPorps
	local propsValue = {}
	for k, v in ipairs(props) do
		table.insert(propsValue, v.value)
	end
	if self._selectInBag then
		g_i3k_game_context:UpdateBagEquipAttrPorps(equipID, guid, propsValue)
	else
		local pos = g_i3k_db.i3k_db_get_equip_item_cfg(equipID).partID
		g_i3k_game_context:UpdateWearEquipAttrProps(pos, propsValue)
	end
	self:setEquipData(equipID, guid, self._selectInBag)
	local scroll = self._layout.vars.sharpenScroll
	scroll:removeAllChildren()
	self:setPowerUpFlag(nil)
	self._layout.vars.saveBtn:hide()
end

function wnd_equipSharpen:onSave(sender)
	-- TODO 1.保存按钮的显隐状态  2.当前有没有淬锋出新的数据  3.等等
	local data = self:getSharpenData()
	if data then
		i3k_sbean.saveEquipSharpen(data.id, data.guid, data.pos)
	end
end


function wnd_equipSharpen:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_equipSharpen:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

--显示帮助
function wnd_equipSharpen:showHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1026))
end

function wnd_equipSharpen:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_equipSharpen:gengxinUi()
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true),g_i3k_game_context:GetMoney(false))
	self:setConsumeData()
end

function wnd_equipSharpen:tiShi(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_equipSharpen:onClose(sender)
	local flag = self:getPowerUpFlag()
	if flag then
		local callback = function(ok)
			if ok then
				g_i3k_ui_mgr:CloseUI(eUIID_EquipSharpen)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback) --当前未保存的淬锋结果拥有更高战力，确认退出吗？
		return
	else
		g_i3k_ui_mgr:CloseUI(eUIID_EquipSharpen)
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_equipSharpen.new();
		wnd:create(layout);
	return wnd;
end
