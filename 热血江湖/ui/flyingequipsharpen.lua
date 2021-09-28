module(..., package.seeall)
local require = require
local ui = require("ui/base")

local wnd_flyingEquipSharpen = i3k_class("wnd_flyingEquipSharpen", ui.wnd_base)

local equip_offset = 8
local level_limit = 7
local POWER_UP_IMG_ID = 174
local POWER_DOWN_IMG_ID = 175
local POWER_EQUAL_IMG_ID = 176
local equip_num = 6

function wnd_flyingEquipSharpen:ctor()
	self._selectNum = 0
	self._selectEquip = nil
	self._sharpenPorps = nil
	self._selectLocks = nil
	self._canTransList = {}
	self._needItemEnough = {}
	self._isSharpenMax = {}
end

function wnd_flyingEquipSharpen:configure()
	local vars = self._layout.vars
	self.equipSharpenBtn = vars.equip_sharpen_btn
	self.equipSharpenBtn:stateToPressed()
	self.equipTransBtn = vars.equip_trans_btn
	if g_i3k_game_context:isFinishFlyingTask(level_limit) then
		self.equipTransBtn:onClick(self, self.onEquipTransBtnClick)
	else
		self.equipTransBtn:setVisible(false)
	end
	self.sharpen_all = vars.sharpen_all
	self.trans_all = vars.trans_all
	self.return_btn = vars.return_btn
	self.return_btn:onClick(self, self.onReturnBtnClick)
	self.return_btn:setVisible(false)
	self.closeBtn = vars.close_btn
	self.closeBtn:onClick(self, self.onCloseBtnClick)
	self.refine_root = vars.refine_root
	self.refine_root:setVisible(false)
	self.productioncostpanel = vars.productioncostpanel
	self.sharpenBtn = vars.sharpenBtn
	self.sharpenBtn:onClick(self, self.onSharpenBtnClick)
	self.saveBtn = vars.saveBtn
	self.saveBtn:onClick(self, self.onSaveBtnClick)
	self.saveBtn:setVisible(false)
	self.finished_panel = vars.finished_panel
	self.redirectBtn = vars.redirectBtn
	self.redirectBtn:onClick(self, self.onRedirectBtnClick)
	self.equip_panel = vars.equip_panel
	self.equip_panel:setVisible(true)
	for i = 1, equip_num do
		self['rank_icon' .. i] = vars['rank_icon' .. i]
		self['equip_icon' .. i] = vars['equip_icon' .. i]
		self['qh_level' .. i] = vars['qh_level' .. i]
		self['tips' .. i] = vars['tips' .. i]
		self['equip' .. i] = vars['equip' .. i]
		self['equip' .. i]:onClick(self, self.onEquipBtnClick, i)
	end
end

function wnd_flyingEquipSharpen:refresh(index)
	self._selectNum = index and index or self._selectNum
	if self._selectNum == 0 then
		self._selectEquip = nil
		self.refine_root:setVisible(false)
		self.equip_panel:setVisible(true)
		self.return_btn:setVisible(false)
	else
		local equipData = g_i3k_game_context:GetWearEquips()
		self._selectEquip = equipData[self._selectNum + equip_offset].equip
		self.refine_root:setVisible(true)
		self.equip_panel:setVisible(false)
		self.return_btn:setVisible(true)
	end
	self:refreshAllRedPoint()
	self:refreshRefineRoot()
	self:refreshEquipPanel()
end

function wnd_flyingEquipSharpen:onCloseBtnClick(sender)
	local flag = self:getPowerUpFlag()
	if flag then
		local callback = function(ok)
			if ok then
				g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipSharpen)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback)
		return
	else
		g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipSharpen)
	end
end

function wnd_flyingEquipSharpen:onEquipTransBtnClick(sender)
	local flag = self:getPowerUpFlag()
	if flag then
		local callback = function(ok)
			if ok then
				g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipTrans)
				g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipSharpen)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback)
		return
	else
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipTrans)
		g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipSharpen)
	end
end

function wnd_flyingEquipSharpen:onEquipBtnClick(sender, index)
	local equipData = g_i3k_game_context:GetWearEquips()
	self._selectEquip = nil
	if equipData[index + equip_offset].equip then
		self._selectNum = index
		self._selectEquip = equipData[index + equip_offset].equip
		self:refresh()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1796))
	end
end

function wnd_flyingEquipSharpen:onSharpenBtnClick(sender)
	if self._selectEquip == nil then
		return
	end
	local consume = g_i3k_db.i3k_db_get_equip_sharpen_need_items(self._selectNum + equip_offset, self._selectLocks and table.nums(self._selectLocks) or 0)
	self._needItemEnough[self._selectNum] = true
	for k, v in pairs(consume) do
		if v.count > g_i3k_game_context:GetCommonItemCanUseCount(v.id) then
			self._needItemEnough[self._selectNum] = false
			break
		end
	end
	if not self._needItemEnough[self._selectNum] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1032))
		return
	end
	if self._allMaxFlag then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1033))
		return
	end
	local data = self:getSharpenData()
	if data then
		local flag = self:getPowerUpFlag()
		if flag then
			local callback = function(ok)
				if ok then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipSharpen, "setPowerUpFlag", false)
					i3k_sbean.equipSharpen(data.id, data.guid, data.pos, data.locks, true)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback)
			return
		end
		i3k_sbean.equipSharpen(data.id, data.guid, data.pos, data.locks, true)
	end
end

function wnd_flyingEquipSharpen:onSaveBtnClick(sender)
	if self._selectEquip == nil then
		return
	end
	local data = self:getSharpenData()
	if data then
		i3k_sbean.saveEquipSharpen(data.id, data.guid, data.pos, true)
	end
end

function wnd_flyingEquipSharpen:onRedirectBtnClick(sender)
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	local transLevel = i3k_db_role_flying[flyingLevel].jingduanLevel
	if transLevel > i3k_db_equips[self._selectEquip.equip_id].flyingLevel then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FlyingEquipTrans, self._selectNum)
		g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipSharpen)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1799, i3k_db_equips[self._selectEquip.equip_id].flyingLevel))
	end
end

function wnd_flyingEquipSharpen:onReturnBtnClick(sender)
	local flag = self:getPowerUpFlag()
	if flag then
		local callback = function(ok)
			if ok then
				self:setPowerUpFlag(false)
				self._selectLocks = nil
				self._selectEquip = nil
				self._selectNum = 0
				self:refresh()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1027), callback)
		return
	else
		self:setPowerUpFlag(false)
		self._selectLocks = nil
		self._selectEquip = nil
		self._selectNum = 0
		self:refresh()
	end
end

function wnd_flyingEquipSharpen:refreshAllRedPoint()
	local equipData = g_i3k_game_context:GetWearEquips()
	local isSharpenAllVisible = g_i3k_game_context:isFlyingSharpenHaveRedPoint()
	self.sharpen_all:setVisible(isSharpenAllVisible)
	local isTransAllVisible = g_i3k_game_context:isFlyingTransHaveRedPoint()
	self.trans_all:setVisible(isTransAllVisible)
	for i = 1, equip_num do
		self['tips' .. i]:setVisible(false)
		self['qh_level' .. i]:setVisible(false)
		self._canTransList[i] = false
		self._isSharpenMax[i] = false
		local equipInfo = equipData[i + equip_offset].equip
		if equipInfo then
			local consume = g_i3k_db.i3k_db_get_equip_sharpen_need_items(i + equip_offset, 0)
			self._needItemEnough[i] = true
			for k, v in pairs(consume) do
				if v.count > g_i3k_game_context:GetCommonItemCanUseCount(v.id) then
					self._needItemEnough[i] = false
					break
				end
			end
			local isSharpenMax = g_i3k_game_context:isFlyingEquipSharpenMax(equipInfo)
			if self._needItemEnough[i] and not isSharpenMax then
				self['tips' .. i]:setVisible(true)
			elseif isSharpenMax then
				self._isSharpenMax[i] = true
				local flyingLevel = g_i3k_game_context:getFlyingLevel()
				local transLevel = i3k_db_role_flying[flyingLevel].jingduanLevel
				if transLevel > i3k_db_equips[equipInfo.equip_id].flyingLevel then
					self['qh_level' .. i]:setVisible(true)
					self._canTransList[i] = true
				end
			end
		end
	end
end

function wnd_flyingEquipSharpen:refreshRefineRoot()
	if self._selectEquip == nil then
		return
	end
	if self._isSharpenMax[self._selectNum] then
		self.finished_panel:setVisible(true)
		self.productioncostpanel:setVisible(false)
	else
		self.finished_panel:setVisible(false)
		self.productioncostpanel:setVisible(true)
	end
	if self._canTransList[self._selectNum] then
		self.redirectBtn:setVisible(true)
	else
		self.redirectBtn:setVisible(false)
	end
	self:setEquipData(self._selectEquip.equip_id)
end

function wnd_flyingEquipSharpen:refreshEquipPanel()
	local equipData = g_i3k_game_context:GetWearEquips()
	for i = 1, equip_num do
		local equipInfo = equipData[i + equip_offset].equip
		if equipInfo then
			self['rank_icon' .. i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipInfo.equip_id))
			self['equip_icon' .. i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipInfo.equip_id, g_i3k_game_context:IsFemaleRole()))
		end
	end
end

function wnd_flyingEquipSharpen:setEquipData(equipID)
	local widgets = self._layout.vars
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	widgets.sharpenScroll:removeAllChildren()
	self.saveBtn:setVisible(false)
	widgets.sjtx1:setVisible(false)
	widgets.sjtx2:setVisible(false)
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	widgets.equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
	widgets.equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	widgets.equipName:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	widgets.equipName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(equipID)))
	widgets.lockImg:setVisible(equipID > 0)
	local wearEquips = g_i3k_game_context:GetWearEquips()
	local attribute = self._selectEquip.attribute
	self:setPropScroll(equipCfg.ext_properties, attribute, equipID)
end

function wnd_flyingEquipSharpen:setPropScroll(props, attribute, equipID)
	self._layout.vars.sharpenRoot:setVisible(false)
	self._oldAttr = attribute
	local scroll = self._layout.vars.propScroll
	scroll:removeAllChildren()
	local allMaxFlag = true
	if props and type(props) == "table" then
		local propDB = {}
		for k, v in ipairs(props) do
			if v.type ~= 0 then
				local widget = require("ui/widgets/feishenghyjdt2")()
				widget.vars.arrow:setVisible(false)
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipID, k, attribute[k])
				if max then
					widget.vars.maxImg:setVisible(true)
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

function wnd_flyingEquipSharpen:setConsumeData()
	local part = self._selectNum + equip_offset
	local lockCount = 0
	if self._selectLocks then
		for k, v in pairs(self._selectLocks) do
			if v == true then
				lockCount = lockCount + 1
			end
		end
	end
	local consume = g_i3k_db.i3k_db_get_equip_sharpen_need_items(part, lockCount)
	local scroll = self._layout.vars.itemlistview
	local money_id = 2
	scroll:removeAllChildren()
	if consume and type(consume) == "table" then
		for i, v in ipairs(consume) do
		    local widget = require("ui/widgets/feishenghyjdt1")()
			local number = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			if v.id == money_id then
				widget.vars.item_count:setText(string.format("%s", v.count))
			else
				widget.vars.item_count:setText(string.format("%s/%s", number, v.count))
			end
			widget.vars.item_lock:setVisible(false)
			widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
            widget.vars.item_count:setTextColor(g_i3k_get_cond_color(v.count <= g_i3k_game_context:GetCommonItemCanUseCount(v.id)))
			widget.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			widget.vars.bt:onClick(self, self.tiShi, v.id)
			scroll:addItem(widget)
		end
	end
end

function wnd_flyingEquipSharpen:tiShi(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_flyingEquipSharpen:onSelectLock(sender, info)
	if info.max then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1029))
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

function wnd_flyingEquipSharpen:getSharpenData()
	local locks = {}
	if self._selectLocks then
		for k, _ in pairs(self._selectLocks) do
			table.insert(locks, k)
		end
	end
	local t = {
		id = self._selectEquip.equip_id,
		guid = self._selectEquip.equip_guid,
		pos = self._selectNum + equip_offset,
		locks = locks
	}
	return t
end

function wnd_flyingEquipSharpen:setPowerUpFlag(bValue)
	self._powerUp = bValue
end

function wnd_flyingEquipSharpen:getPowerUpFlag()
	return self._powerUp
end

function wnd_flyingEquipSharpen:setSharpenScroll(props)
	self._layout.vars.sharpenRoot:show()
	self._layout.vars.saveBtn:show()
	self._sharpenPorps = props
	local oldAttr = self._oldAttr
	local scroll = self._layout.vars.sharpenScroll
	scroll:removeAllChildren()
	if props and type(props) == "table" then
		local propDB = {}
		for k, v in ipairs(props) do
			local widget = require("ui/widgets/feishenghyjdt2")()
			local imgID = self:getPowerChangeIMG(oldAttr[k], v.value)
			widget.vars.arrow:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
			local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(self._selectEquip.equip_id, k, v.value)
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

function wnd_flyingEquipSharpen:getPowerChangeIMG(oldPower, newPower)
	if oldPower < newPower then
		return POWER_UP_IMG_ID
	elseif oldPower > newPower then
		return POWER_DOWN_IMG_ID
	else
		return POWER_EQUAL_IMG_ID
	end
end

function wnd_flyingEquipSharpen:savaSharpenCallback(equipID, guid)
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
	self:setEquipData(equipID)
	local scroll = self._layout.vars.sharpenScroll
	scroll:removeAllChildren()
	self:setPowerUpFlag(nil)
	self._layout.vars.saveBtn:hide()
	self:refresh()
end

function wnd_create(layout)
	local wnd = wnd_flyingEquipSharpen.new()
	wnd:create(layout)
	return wnd
end