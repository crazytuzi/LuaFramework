-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_equip_temper_wash = i3k_class("wnd_equip_temper_wash",ui.wnd_base)

local XL_PROPT1 = "ui/widgets/zbclxlt1" --洗练属性
local NEEDITEMT1 = "ui/widgets/zbclxlt2"
local WASH_PROP_COUNT = 5 --锤炼最大属性个数
function wnd_equip_temper_wash:ctor()
	self.propLock = {count = 0}--属性锁   .count 锁的数量  [1] ~ [5] 是否锁了
end

function wnd_equip_temper_wash:configure()
	local widgets = self._layout.vars
	widgets.noWashHint:setText(i3k_get_string(17409))
	widgets.closeBtn:onClick(self, self.onCloseBtn)
	widgets.saveBtn:onClick(self, self.onSaveBtn)
	widgets.washBtn:onClick(self, self.onWashBtn)
	self:InitLockProp(WASH_PROP_COUNT)
end

function wnd_equip_temper_wash:refresh(partID)
	self.partID = partID or self.partID
	local widgets = self._layout.vars
	local defaultPart = g_i3k_game_context:GetUserCfg():GetDefaultBaiLianPartID()
	local curProps = g_i3k_game_context:GetEquipTemperProps(self.partID) or {}
	local washProps
	if defaultPart ~= 0 and defaultPart ~= self.partID then
		washProps = {}
	else
		washProps = g_i3k_game_context:GetTempEquipBaiLianProps()  --如果有的话 说明未保存离线了
	end
	self:setNeedItem()
	self:setProp(curProps, widgets.curProps, true)
	self:setProp(washProps, widgets.washProps, false)
	widgets.tips:setVisible(not(washProps and #washProps ~= 0))
	widgets.saveBtn:setVisible(washProps and next(washProps) and true or false)
end

function wnd_equip_temper_wash:InitLockProp(count)
	self.propLock = {count = 0}
	for i=1,count do
		self.propLock[i] = false
	end
end

function wnd_equip_temper_wash:setProp(props, widget, isCurWidget)--属性 控件 是否是当前属性
	widget:removeAllChildren()
	if props and next(props) then
		for i, v in ipairs(props) do
			local layer = require(XL_PROPT1)()
			local vars = layer.vars
			local propCfg = i3k_db_prop_id[v.id]
			vars.lockBtn:setVisible(isCurWidget)
			if self.propLock[i] then
				vars.lockBtn:stateToPressed()
			end
			vars.lockBtn:onClick(self, self.onLockClick, i)
			vars.name:setText(propCfg.desc..":")
			vars.prop_icon:setImage(g_i3k_db.i3k_db_get_icon_path(propCfg.icon))
			vars.attr:setText(v.value)
			vars.starCount:setText(g_i3k_db.i3k_db_get_equip_temper_prop_star(v.id, v.value))
			widget:addItem(layer)
		end
	end
end

function wnd_equip_temper_wash:setNeedItem()
	local consume = {}
	for i,v in ipairs(i3k_db_equip_temper_base.bailianConsume) do
		table.insert(consume, v)
	end
	local widgets = self._layout.vars.needItem
	local extraConsume = i3k_db_equip_temper_base.lockConsume
	if self.propLock.count ~= 0 then
		table.insert(consume,extraConsume[self.propLock.count] or extraConsume[#extraConsume])--锁属性的额外消耗
	end
	widgets:removeAllChildren()
	self.canBailian = true
	for i, e in ipairs(consume) do
		local T1 = require(NEEDITEMT1)()
		local widget = T1.vars
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemId))
		widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemId))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemId,i3k_game_context:IsFemaleRole()))
		widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemId))
		if e.itemId == g_BASE_ITEM_DIAMOND or e.itemId == g_BASE_ITEM_COIN then
			widget.item_count:setText(e.itemCount or e.count)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) .."/".. (e.itemCount or e.count))
			if self.canBailian then
				self.canBailian = g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)
			end
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)))
		widget.bt:onClick(self, self.onItemTips, e.itemId)
		widgets:addItem(T1)
	end
end

--百炼成功之后设置
function wnd_equip_temper_wash:setWashProp(props)
	local wash_widget = self._layout.vars.washProps
	self:setProp(props, wash_widget)
	self._layout.vars.tips:hide()
	self:refresh()
end

--保存成功
function wnd_equip_temper_wash:onSaveSuccess()
	self:refresh()
end
----------------------btnClick-----------------------
function wnd_equip_temper_wash:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_equip_temper_wash:onLockClick(sender, index)
	if sender:isStatePressed() then
		sender:stateToNormal()
		self.propLock.count = self.propLock.count - 1
		self.propLock[index] = false
	else
		if self.propLock.count >= #i3k_db_equip_temper_base.lockConsume then
			g_i3k_ui_mgr:PopupTipMessage(string.format("最多可以锁定%s条属性", #i3k_db_equip_temper_base.lockConsume))
		else
			sender:stateToPressed()
			self.propLock.count = self.propLock.count + 1
			self.propLock[index] = true
		end
	end
	self:setNeedItem()
end

function wnd_equip_temper_wash:onSaveBtn(sender)
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17432),function(bValue)
		if bValue then
			local wEquips = g_i3k_game_context:GetWearEquips()
			local equip_id = wEquips[self.partID].equip.equip_id
			local guid = wEquips[self.partID].equip.equip_guid
			i3k_sbean.equip_smelting_save(equip_id, guid, self.partID)
		end
	end)
end

function wnd_equip_temper_wash:onWashBtn(sender)
	if self.canBailian then
		local wEquips = g_i3k_game_context:GetWearEquips()
		local equip_id = wEquips[self.partID].equip.equip_id
		local guid = wEquips[self.partID].equip.equip_guid
		local props = g_i3k_game_context:GetEquipTemperProps(self.partID)
		local lockProps = {}
		for i, v in ipairs(self.propLock) do
			if v then
				lockProps[#lockProps + 1] = props[i].id
			end
		end
		i3k_sbean.equip_smelting(equip_id, guid, self.partID, lockProps)
	else
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法百炼")
	end
end

function wnd_equip_temper_wash:onCloseBtn(sender)
	local partID = self.partID
	local defaultPart = g_i3k_game_context:GetUserCfg():GetDefaultBaiLianPartID()
	if defaultPart ~= 0 and defaultPart ~= partID then
		g_i3k_game_context:ClearTempEquipProps()
		self:onCloseUI()
		return
	end
	local tempBaiLianProps = g_i3k_game_context:GetTempEquipBaiLianProps() --临时的百炼属性
	if tempBaiLianProps and next(tempBaiLianProps) then
		g_i3k_ui_mgr:ShowCustomMessageBox2("保留","不保留","是否保留百炼的结果？",function(bValue)
			if bValue then
				local wEquips = g_i3k_game_context:GetWearEquips()
				local equip_id = wEquips[partID].equip.equip_id
				local guid = wEquips[partID].equip.equip_guid
				i3k_sbean.equip_smelting_save(equip_id, guid, partID, true)
			else
				g_i3k_game_context:ClearTempEquipProps()
				self:onCloseUI()
			end
		end)
	else
		self:onCloseUI()
	end
end
---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_equip_temper_wash.new()
	wnd:create(layout)
	return wnd
end
