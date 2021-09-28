-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_suit = i3k_class("wnd_array_stone_suit", ui.wnd_base)

--local g_SUIT_LEVEL_STRING = {18467, 18468, 18469, 18470, 18471, 18472, 18473, 18474, 18475}
-- local STONELEVELSTRING = {18458, 18459, 18460, 18461, 18462, 18463, 18464, 18465, 18466}

function wnd_array_stone_suit:ctor()
	self._stoneSuit = {}
	self._curGroupIndex = 1
	self._childIndex = 1
	self._curSuitLevel = 1
	self._isShowChild = true
end

function wnd_array_stone_suit:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.leftBtn:onClick(self, self.onLeftBtn)
	self._layout.vars.rightBtn:onClick(self, self.onRightBtn)
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_array_stone_suit:refresh()
	--self._layout.vars.desc:setText(i3k_get_string(18477))
	self._layout.vars.desc:hide()
	self:getEquipStoneSuit()
	self:updateSuitGroupScroll()
	--self:updateEquipStones()
	--self:updateStoneSuitProperty()
end

function wnd_array_stone_suit:getEquipStoneSuit()
	local info = g_i3k_game_context:getArrayStoneData()
	for k, v in pairs(i3k_db_array_stone_suit_group) do
		local stoneSuit = {}
		for i, j in ipairs(info.equips) do
			if j ~= 0 then
				if g_i3k_db.i3k_db_is_in_stone_suit_group(j, k) then
					table.insert(stoneSuit, j)
				end
			end
		end
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(stoneSuit, v.includeSuit[1]) then
			table.insert(self._stoneSuit, {groupId = k, stones = stoneSuit, finishState = 1})
		else
			table.insert(self._stoneSuit, {groupId = k, stones = stoneSuit, finishState = 0})
		end
	end
	table.sort(self._stoneSuit, function (a, b)
		if a.finishState == b.finishState then
			return a.groupId < b.groupId
		else
			return a.finishState > b.finishState
		end
	end)
end

function wnd_array_stone_suit:updateSuitGroupScroll()
	self._layout.vars.groupScroll:removeAllChildren()
	for k, v in ipairs(self._stoneSuit) do
		local node = require("ui/widgets/zfsyjt2")()
		node.vars.groupIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_suit_group[v.groupId].groupIcon))
		node.vars.groupName:setText(i3k_db_array_stone_suit_group[v.groupId].groupName)
		node.vars.level:hide()
		node.vars.groupBtn:onClick(self, self.onChangeSuitGroup, k)
		node.vars.chooseIcon:setVisible(k == self._curGroupIndex)
		node.vars.unfoldIcon:setVisible(k == self._curGroupIndex and self._isShowChild)
		self._layout.vars.groupScroll:addItem(node)
	end
	self._childIndex = 1
	self._isShowChild = true
	self:addSuitGroupChildren()
	self:updateStoneNameScroll()
end

function wnd_array_stone_suit:addSuitGroupChildren()
	local index = 1
	local groupId = self._stoneSuit[self._curGroupIndex].groupId
	local suitId = i3k_db_array_stone_suit_group[groupId].includeSuit[self._childIndex]
	if g_i3k_db.i3k_db_get_is_finish_stone_suit(self._stoneSuit[self._curGroupIndex].stones, suitId) then
		self._curSuitLevel = g_i3k_db.i3k_db_get_stone_suit_level(self._stoneSuit[self._curGroupIndex].stones, suitId)
	else
		self._curSuitLevel = 1
	end
	for k, v in ipairs(i3k_db_array_stone_suit_group[groupId].includeSuit) do
		local node = require("ui/widgets/zfsyjt4")()
		node.vars.btn:onClick(self, self.onChooseSuitId, k)
		if k == self._childIndex then
			node.vars.btn:stateToPressed(true)
		else
			node.vars.btn:stateToNormal(true)
		end
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(self._stoneSuit[self._curGroupIndex].stones, v) then
			local level = g_i3k_db.i3k_db_get_stone_suit_level(self._stoneSuit[self._curGroupIndex].stones, v)
			node.vars.name:setText(i3k_get_string(g_SUIT_LEVEL_STRING[level]) .. i3k_db_array_stone_suit[v].name)
			node.vars.name:setTextColor(g_COLOR_VALUE_GREEN)
			node.vars.active:show()
		else
			node.vars.name:setText(i3k_get_string(g_SUIT_LEVEL_STRING[1]) .. i3k_db_array_stone_suit[v].name)
			node.vars.name:setTextColor(g_COLOR_VALUE_RED)
			node.vars.active:hide()
		end
		self._layout.vars.groupScroll:insertChildToIndex(node, index + self._curGroupIndex)
		index = index + 1
	end
	self:updateEquipStones()
	self:updateStoneSuitProperty()
end

function wnd_array_stone_suit:removeSuitGroupChildren()
	local groupId = self._stoneSuit[self._curGroupIndex].groupId
	for k = 1, #i3k_db_array_stone_suit_group[groupId].includeSuit do
		self._layout.vars.groupScroll:removeChildAtIndex(self._curGroupIndex + 1)
	end
end

function wnd_array_stone_suit:onChangeSuitGroup(sender, index)
	if self._curGroupIndex == index then
		if self._isShowChild then
			self:removeSuitGroupChildren()
		else
			self:addSuitGroupChildren()
		end
		self._isShowChild = not self._isShowChild
		local children = self._layout.vars.groupScroll:getAllChildren()
		children[self._curGroupIndex].vars.unfoldIcon:setVisible(self._isShowChild)
	else
		if self._isShowChild then
			self:removeSuitGroupChildren()
		end
		self._curGroupIndex = index
		local children = self._layout.vars.groupScroll:getAllChildren()
		for k, v in ipairs(children) do
			if k == index then
				v.vars.chooseIcon:show()
				v.vars.unfoldIcon:show()
			else
				v.vars.chooseIcon:hide()
				v.vars.unfoldIcon:hide()
			end
		end
		self._childIndex = 1
		self._isShowChild = true
		self:addSuitGroupChildren()
		self:updateStoneNameScroll()
		--self:updateEquipStones()
		--self:updateStoneSuitProperty()
	end
end

function wnd_array_stone_suit:updateStoneNameScroll()
	self._layout.vars.stoneScroll:removeAllChildren()
	--[[local groupId = self._stoneSuit[self._curGroupIndex].groupId
	local children = self._layout.vars.stoneScroll:addItemAndChild("ui/widgets/zfsyjt3", 3, #i3k_db_array_stone_suit_group[groupId].needList)
	for k, v in ipairs(children) do
		local needId = i3k_db_array_stone_suit_group[groupId].needList[k]
		local needCfg = i3k_db_array_stone_suit_need_list[needId]
		v.vars.text:setText(needCfg.name)
		v.vars.text:setTextColor(g_COLOR_VALUE_RED)
		for i, j in ipairs(self._stoneSuit[self._curGroupIndex].stones) do
			local stoneCfg = i3k_db_array_stone_cfg[j]
			if stoneCfg.prefixId == needCfg.needPrefix and table.indexof(needCfg.needSuffix, stoneCfg.suffixId) then
				v.vars.text:setTextColor(g_COLOR_VALUE_GREEN)
				break
			end
		end
	end--]]
end

function wnd_array_stone_suit:onChooseSuitId(sender, index)
	if self._childIndex == index then
		
	else
		self._childIndex = index
		local groupId = self._stoneSuit[self._curGroupIndex].groupId
		local children = self._layout.vars.groupScroll:getAllChildren()
		for k = 1, #i3k_db_array_stone_suit_group[groupId].includeSuit do
			if k == index then
				children[k + self._curGroupIndex].vars.btn:stateToPressed(true)
			else
				children[k + self._curGroupIndex].vars.btn:stateToNormal(true)
			end
		end
		local suitId = i3k_db_array_stone_suit_group[groupId].includeSuit[self._childIndex]
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(self._stoneSuit[self._curGroupIndex].stones, suitId) then
			self._curSuitLevel = g_i3k_db.i3k_db_get_stone_suit_level(self._stoneSuit[self._curGroupIndex].stones, suitId)
		else
			self._curSuitLevel = 1
		end
		self:updateEquipStones()
		self:updateStoneSuitProperty()
	end
end

function wnd_array_stone_suit:updateEquipStones()
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	local equipCount = i3k_db_array_stone_level[level].equipStoneCount
	local widgets = self._layout.vars
	local groupId = self._stoneSuit[self._curGroupIndex].groupId
	local suitId = i3k_db_array_stone_suit_group[groupId].includeSuit[self._childIndex]
	local stoneList = {}
	local suitStones = {}
	local suitLevel = i3k_db_array_stone_common.maxStoneLevel
	for k, v in ipairs(info.equips) do
		if v ~= 0 and g_i3k_db.i3k_db_is_in_stone_suit_group(v, groupId) then
			table.insert(stoneList, v)
		end
	end
	if g_i3k_db.i3k_db_get_is_finish_stone_suit(stoneList, suitId) then
		local suitCfg = i3k_db_array_stone_suit[suitId]
		if suitCfg.suitType == g_ARRAY_STONE_SUIT_COMBINE then
			local suitTable = {}
			for k, v in ipairs(suitCfg.needStoneType) do
				for i, j in ipairs(stoneList) do
					if i3k_db_array_stone_cfg[j].prefixId == v then
						if not suitTable[v] then
							suitTable[v] = j
						else
							if i3k_db_array_stone_cfg[j].level == i3k_db_array_stone_cfg[suitTable[v]].level then
								suitTable[v] = math.min(j, suitTable[v])
							elseif i3k_db_array_stone_cfg[j].level > i3k_db_array_stone_cfg[suitTable[v]].level then
								suitTable[v] = j
							end
						end
					end
				end
			end
			for k, v in pairs(suitTable) do
				suitLevel = math.min(suitLevel, i3k_db_array_stone_cfg[v].level)
				table.insert(suitStones, v)
			end
		else
			if #stoneList <= 1 then
				--这里直接引用应该也没关系
				suitStones = stoneList
			else
				table.sort(stoneList, function (a, b)
					if i3k_db_array_stone_cfg[a].level == i3k_db_array_stone_cfg[b].level then
						return a < b
					else
						return i3k_db_array_stone_cfg[a].level > i3k_db_array_stone_cfg[b].level
					end
				end)
				for k = 1, suitCfg.minCount do
					table.insert(suitStones, stoneList[k])
				end
			end
			suitLevel = i3k_db_array_stone_cfg[suitStones[#suitStones]].level
		end
	end
	for k = 1, g_ARRAY_STONE_MAX_EQUIP do
		widgets["amuletLock"..k]:hide()
		if info.equips[k] and info.equips[k] ~= 0 then
			local stoneCfg = i3k_db_array_stone_cfg[info.equips[k]]
			if table.indexof(suitStones, info.equips[k]) and self._curSuitLevel == suitLevel then
				widgets["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(stoneCfg.inSuitIcon))
			else
				widgets["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(stoneCfg.unSuitIcon))
			end
			if g_i3k_db.i3k_db_is_in_stone_suit_group(info.equips[k], self._stoneSuit[self._curGroupIndex].groupId) then
				widgets["stoneLight"..k]:show()
			else
				widgets["stoneLight"..k]:hide()
			end
			widgets["stoneLevelBg"..k]:show()
			widgets["stoneLevel"..k]:setText(i3k_get_string(18403, stoneCfg.level))
		else
			widgets["stoneLevelBg"..k]:hide()
			widgets["stoneLight"..k]:hide()
			if k <= equipCount then
				widgets["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(2396))
				widgets["amuletLock"..k]:hide()
				widgets["amuletIcon"..k]:show()
			else
				widgets["amuletIcon"..k]:hide()
				widgets["amuletLock"..k]:show()
			end
		end
	end
end

function wnd_array_stone_suit:updateStoneSuitProperty()
	self._layout.vars.propertyScroll:removeAllChildren()
	local groupId = self._stoneSuit[self._curGroupIndex].groupId
	local suitId = i3k_db_array_stone_suit_group[groupId].includeSuit[self._childIndex]
	local node = require("ui/widgets/zfsyjt")()
	node.vars.text:setText(i3k_db_array_stone_suit_group[groupId].groupName)
	self._layout.vars.propertyScroll:addItem(node)
	local node = require("ui/widgets/zfsyjt1")()
	node.vars.text:setText(i3k_db_array_stone_suit[suitId].suitDesc)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui._layout.vars.propertyScroll, width, height, true)
	end, 1)
	self._layout.vars.propertyScroll:addItem(node)
	local node = require("ui/widgets/zfsyjt1")()
	node.vars.text:setText(g_i3k_db.i3k_db_get_array_stone_suit_desc(suitId, self._curSuitLevel))
	if g_i3k_db.i3k_db_get_is_finish_stone_suit(self._stoneSuit[self._curGroupIndex].stones, suitId) then
		if self._curSuitLevel == g_i3k_db.i3k_db_get_stone_suit_level(self._stoneSuit[self._curGroupIndex].stones, suitId) then
			node.vars.text:setTextColor(g_COLOR_VALUE_GREEN)
		else
			node.vars.text:setTextColor(g_COLOR_VALUE_RED)
		end
	else
		node.vars.text:setTextColor(g_COLOR_VALUE_RED)
	end
	--[[node.vars.text:setRichTextFormatedEventListener(function()
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(self._layout.vars.propertyScroll, width, height, true)
	end)--]]
	self._layout.vars.propertyScroll:addItem(node)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		
		node.rootVar:changeSizeInScroll(ui._layout.vars.propertyScroll, width, height, true)
	end, 1)
	self._layout.vars.page:setText(i3k_get_string(g_SUIT_LEVEL_STRING[self._curSuitLevel]))
end

function wnd_array_stone_suit:onLeftBtn(sender)
	if self._curSuitLevel > 1 then
		self._curSuitLevel = self._curSuitLevel - 1
		self:updateEquipStones()
		self:updateStoneSuitProperty()
	end
end

function wnd_array_stone_suit:onRightBtn(sender)
	if self._curSuitLevel < i3k_db_array_stone_common.maxStoneLevel then
		self._curSuitLevel = self._curSuitLevel + 1
		self:updateEquipStones()
		self:updateStoneSuitProperty()
	end
end

function wnd_array_stone_suit:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18478))
end

function wnd_create(layout)
	local wnd = wnd_array_stone_suit.new()
	wnd:create(layout)
	return wnd
end