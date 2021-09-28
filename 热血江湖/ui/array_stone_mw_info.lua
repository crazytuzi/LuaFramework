------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_array_stone_mw_info = i3k_class("wnd_array_stone_mw_info",ui.wnd_base)

local TAG = "ui/widgets/zfsmwsxt2"
local BASE_PROP = "ui/widgets/zfsmwsxt"
local ADD_PROP = "ui/widgets/zfsmwsxt"
local PROP_SUB_TAG = "ui/widgets/zfsmwsxt3"
-- local YANJUE_PROP = "ui/widgets/zfsmwsxt1"
local YANJUE_PROP = "ui/widgets/hufuzht2"


local CONSUME_ITEM = "ui/widgets/zbqht2"

local FROM_BAG = 1--从背包打开
local FROM_ACHIVE = 3--从图鉴打开
local FROM_EQUIP = 2 --装备界面打开
local FROM_RANK = 4 --从排行榜打开

--[[local SUIT_TYPE_DESC = {--言诀小标题里的描述
	18451,18452,18453,18454
}--]]

function wnd_array_stone_mw_info:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.displace:onClick(self, self.onDisplaceClick)
	widgets.recovery:onClick(self, self.onRecoveryClick)
	widgets.equip:onClick(self, self.onEquipClick)
	widgets.synthetise:onClick(self, self.onSynthetiseClick)
	widgets.unequip:onClick(self, self.onUnEquipClick)
end

-------------interface------
function wnd_array_stone_mw_info:setMiWenInfo(widget, cfg)
	local widgets = widget or self._layout.vars
	local cfg = cfg or self.cfg
	widgets.name:setText(cfg.name)
	widgets.level:setText(i3k_get_string(18403, cfg.level))
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.stoneIcon))
	widgets.quality:setImage(g_i3k_get_icon_frame_path_by_rank(cfg.rank))
	widgets.name:setTextColor(g_i3k_get_color_by_rank(cfg.rank))
	widgets.level:setTextColor(g_i3k_get_color_by_rank(cfg.rank))
end

function wnd_array_stone_mw_info:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_array_stone_mw_info:setConsumes(scroll, items)
	scroll:removeAllChildren()
	local isEnough = true
	for i,v in ipairs(items) do
		local item = require(CONSUME_ITEM)()
		local vars = item.vars
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id))
		vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
		vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
		vars.item_name:setTextColor(name_colour)
		vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN then
			vars.item_count:setText(v.count)
		else
			vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. v.count)
		end
		if isEnough then
			isEnough = g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count
		end
		vars.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count))
		vars.bt:onClick(self, self.onItemTips, v.id)
		scroll:addItem(item)
	end
	return isEnough
end
-----------------------------

function wnd_array_stone_mw_info:refresh(id, from, pos)--id , 是否从背包打开
	self.id = id
	if from ~= nil then
		self.from = from
	else
		from = self.from
	end
	local widgets = self._layout.vars
	local cfg = i3k_db_array_stone_cfg[id]
	self.cfg = cfg
	self:setMiWenInfo()
	local powerProp = self:SetProps()
	
	widgets.equip:		setVisible(from == FROM_BAG)
	widgets.unequip:	setVisible(from == FROM_EQUIP)
	widgets.displace:	setVisible(from == FROM_BAG)
	widgets.recovery:	setVisible(from == FROM_BAG)
	widgets.synthetise:	setVisible(from == FROM_BAG or from == FROM_EQUIP)
end

function wnd_array_stone_mw_info:SetProps()
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local baseTag = require(TAG)()
	baseTag.vars.desc:setText(i3k_get_string(18437))
	scroll:addItem(baseTag)
	local arrayStone = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(arrayStone.exp)
	if self.from == FROM_EQUIP then
		local equipSuit = {}
		local suitAdditionAll = {}
		local suitAdditionSelf = {}
		local commonProp = {}
		local extraProp = {}
		for i, j in pairs(i3k_db_array_stone_suit_group) do
			for m, n in ipairs(j.includeSuit) do
				for k, v in ipairs(arrayStone.equips) do
					if v ~= 0 then
						if g_i3k_db.i3k_db_is_in_stone_suit_group(v, i) then
							if not equipSuit[n] then
								equipSuit[n] = {}
							end
							table.insert(equipSuit[n], v)
						end
					end
				end
			end
		end
		for k, v in pairs(equipSuit) do
			local suitCfg = i3k_db_array_stone_suit[k]
			if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, k) then
				local suitLevel = g_i3k_db.i3k_db_get_stone_suit_level(v, k)
				if suitCfg.additionType == g_STONE_SUIT_ADDITION_SELF then
					if not suitAdditionSelf[k] then
						suitAdditionSelf[k] = {}
					end
					for m, n in ipairs(suitCfg.additionProperty) do
						if n.id ~= 0 then
							if not suitAdditionSelf[k][n.id] then
								suitAdditionSelf[k][n.id] = 0
							end
							suitAdditionSelf[k][n.id] = suitAdditionSelf[k][n.id] + n.value[suitLevel]
						end
					end
				elseif suitCfg.additionType == g_STONE_SUIT_ADDITION_ALL then
					for m, n in ipairs(suitCfg.additionProperty) do
						if n.id ~= 0 then
							if not suitAdditionAll[n.id] then
								suitAdditionAll[n.id] = 0
							end
							suitAdditionAll[n.id] = suitAdditionAll[n.id] + n.value[suitLevel]
						end
					end
				end
			end
		end
		for m, n in ipairs(self.cfg.commonProperty) do
			local percent = 0
			for k, v in pairs(equipSuit) do
				if table.indexof(v, self.id) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
					percent = percent + suitAdditionSelf[k][n.id] / 10000
				end
			end
			if suitAdditionAll[n.id] then
				percent = percent + suitAdditionAll[n.id] / 10000
			end
			if i3k_db_array_stone_level[level].propertyRate ~= 0 then
				percent = percent + i3k_db_array_stone_level[level].propertyRate / 10000
			end
			if not commonProp[n.id] then
				commonProp[n.id] = 0
			end
			commonProp[n.id] = commonProp[n.id] + n.value
			if not extraProp[n.id] then
				extraProp[n.id] = 0
			end
			extraProp[n.id] = extraProp[n.id] + math.floor(n.value * percent)
			local prop = require(BASE_PROP)()
			prop.vars.name:setText(g_i3k_db.i3k_db_get_property_name(n.id))
			if math.floor(n.value * percent) > 0 then
				prop.vars.value:setText(i3k_get_prop_show(n.id, n.value))
				prop.vars.extra:show()
				prop.vars.extra:setText("+" .. i3k_get_prop_show(n.id, math.floor(n.value * percent)))
			else
				prop.vars.extra:hide()
				prop.vars.value:setText(i3k_get_prop_show(n.id, n.value))
			end
			scroll:addItem(prop)
		end
		if #self.cfg.extraProperty ~= 0 then
			local addTag = require(TAG)()
			addTag.vars.desc:setText(i3k_get_string(18438))
			scroll:addItem(addTag)
			for m, n in ipairs(self.cfg.extraProperty) do
				local prop = require(ADD_PROP)()
				prop.vars.name:setText(g_i3k_db.i3k_db_get_property_name(n.id))
				if level >= n.needLvl then
					local percent = 0
					for k, v in pairs(equipSuit) do
						if table.indexof(v, self.id) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
							percent = percent + suitAdditionSelf[k][n.id] / 10000
						end
					end
					if suitAdditionAll[n.id] then
						percent = percent + suitAdditionAll[n.id] / 10000
					end
					if i3k_db_array_stone_level[level].propertyRate ~= 0 then
						percent = percent + i3k_db_array_stone_level[level].propertyRate / 10000
					end
					if not commonProp[n.id] then
						commonProp[n.id] = 0
					end
					commonProp[n.id] = commonProp[n.id] + n.value
					if not extraProp[n.id] then
						extraProp[n.id] = 0
					end
					extraProp[n.id] = extraProp[n.id] + math.floor(n.value * percent)
					if math.floor(n.value * percent) > 0 then
						prop.vars.value:setText(i3k_get_prop_show(n.id, n.value))
						prop.vars.extra:show()
						prop.vars.extra:setText("+" .. i3k_get_prop_show(n.id, math.floor(n.value * percent)))
					else
						prop.vars.extra:hide()
						prop.vars.value:setText(i3k_get_prop_show(n.id, n.value))
					end
				else
					prop.vars.value:setText(i3k_get_prop_show(n.id, n.value)..i3k_get_string(18439, n.needLvl))
					prop.vars.extra:hide()
				end
				scroll:addItem(prop)
			end
		end
		local extraPower = g_i3k_db.i3k_db_get_battle_power(extraProp)
		local basePower = g_i3k_db.i3k_db_get_battle_power(commonProp)
		local str = string.format(extraPower == 0 and "%s" or "%s".."+%s", basePower, extraPower)
		self._layout.vars.power:setText(str)
	else
		local powerProp = {}
		for i,v in ipairs(self.cfg.commonProperty) do
			local prop = require(BASE_PROP)()
			--prop.vars.level:hide()
			prop.vars.name:setText(g_i3k_db.i3k_db_get_property_name(v.id))
			prop.vars.value:setText(i3k_get_prop_show(v.id, v.value))
			prop.vars.extra:hide()
			scroll:addItem(prop)
			powerProp[v.id] = powerProp[v.id] and powerProp[v.id] + v.value or v.value
		end
		if #self.cfg.extraProperty ~= 0 then
			local addTag = require(TAG)()
			addTag.vars.desc:setText(i3k_get_string(18438))
			scroll:addItem(addTag)
			for i,v in ipairs(self.cfg.extraProperty) do
				local prop = require(ADD_PROP)()
				prop.vars.name:setText(g_i3k_db.i3k_db_get_property_name(v.id))
				if level < v.needLvl then
					prop.vars.value:setText(i3k_get_prop_show(v.id, v.value) .. i3k_get_string(18439, v.needLvl))
				else
					prop.vars.value:setText(i3k_get_prop_show(v.id, v.value))
				end
				prop.vars.extra:hide()
				scroll:addItem(prop)
				powerProp[v.id] = powerProp[v.id] and powerProp[v.id] + v.value or v.value
			end
		end
		self._layout.vars.power:setText(g_i3k_db.i3k_db_get_battle_power(powerProp))
	end
 	self:setYanjues()
end

function wnd_array_stone_mw_info:setYanjues()
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	local yanjueTag = require(TAG)()
	yanjueTag.vars.desc:setText(i3k_get_string(18440))
	scroll:addItem(yanjueTag)
	local yanjues = g_i3k_game_context:getArrayStoneSuitGroup(self.id)
	table.sort(yanjues, function(a,b) return a.groupId < b.groupId end)
	for i, v in ipairs(yanjues) do
		local groupCfg =  i3k_db_array_stone_suit_group[v.groupId]
		local minNeedCount, showCount= math.huge
		local _, count = g_i3k_db.i3k_db_get_is_finish_stone_suit(v.stoneList, groupCfg.includeSuit[1])
		if self.from == FROM_EQUIP then
			for ii =1, #groupCfg.includeSuit do
				local suitCfg = i3k_db_array_stone_suit[groupCfg.includeSuit[ii]]
				minNeedCount = math.min(minNeedCount, suitCfg.minCount)
				if count >= suitCfg.minCount then
					showCount = suitCfg.minCount
				end
			end
		end
		local subTag = require(PROP_SUB_TAG)()
		local color = g_i3k_get_cond_color(count >= (showCount or minNeedCount))
		local str = string.format(self.from == FROM_EQUIP and "%s<c=%s>(%s/%s)</c>" or "%s", groupCfg.groupName, color, count, showCount or minNeedCount)
		subTag.vars.desc:setText(str)
		scroll:addItem(subTag)
		local suitType = i3k_db_array_stone_suit[groupCfg.includeSuit[1]].suitType
		local txt = require(YANJUE_PROP)()
		txt.vars.text:setText(groupCfg.stoneDesc)
		self:AddAText(txt)
	end
end

local TXT_SIZE_OFFSET = 5--加一点 放止文字被挡住
function wnd_array_stone_mw_info:AddAText(widget)
	self._layout.vars.scroll:addItem(widget)
	widget.vars.text:setRichTextFormatedEventListener(function()
		local textUI = widget.vars.text
		local size = widget.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or (height + TXT_SIZE_OFFSET)
		widget.rootVar:changeSizeInScroll(self._layout.vars.scroll, width, height, true)
	end)
end

----------------onClick---------------------
function wnd_array_stone_mw_info:onDisplaceClick(sender)--置换
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWDisplace)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWDisplace, self.id)
end

function wnd_array_stone_mw_info:onRecoveryClick(sender)--回收
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWRecovery)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWRecovery, self.id)
end

function wnd_array_stone_mw_info:onEquipClick(sender)--上阵
	local equips = g_i3k_game_context:getEquipArrayStone()
	local full = true
	for i = 1, g_i3k_game_context:getArrayStoneMaxCountNow() do
		if not equips[i] or equips[i] == 0 then
			full = false
			break
		end
	end

	local same,like,likeId = false,false
	for i,v in ipairs(equips) do
		if math.floor(self.id / 100) == math.floor(v / 100) then
			like = true
			likeId = v
			if self.id == v then
				same = true
				break
			end
		end
	end
	if same then --同一个密文
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18441))
	elseif like then -- 同种密文
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWEquipConfirm)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWEquipConfirm, self.id, likeId)
	elseif full then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18442, g_i3k_game_context:getArrayStoneMaxCountNow()))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "onAmuletBtn")
		self:onCloseUI()
		return
	else
		i3k_sbean.array_stone_ciphertext_equip(self.id)
	end
	
end

function wnd_array_stone_mw_info:onUnEquipClick(sender)
	i3k_sbean.array_stone_ciphertext_unequip(self.id)
end

function wnd_array_stone_mw_info:onSynthetiseClick(sender)--合成
	if self.cfg.compoundId == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18443))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWSynthetise)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWSynthetise, self.id, self.from == FROM_EQUIP)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_array_stone_mw_info.new()
	wnd:create(layout,...)
	return wnd
end
