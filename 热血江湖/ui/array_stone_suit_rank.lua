-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_suit_rank = i3k_class("wnd_array_stone_suit_rank", ui.wnd_base)

function wnd_array_stone_suit_rank:ctor()
	self._overview = {}
	self._stoneSuit = {}
	self._curGroupIndex = 1
	self._childIndex = 1
	self._curSuitLevel = 1
	self._isShowChild = true
end

function wnd_array_stone_suit_rank:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_array_stone_suit_rank:refresh(overview, stoneSuit)
	self._overview = overview
	self._stoneSuit = stoneSuit
	self._level = g_i3k_db.i3k_db_get_array_stone_level(overview.exp)
	--self:updateFinishedGroup()
	self:updateSuitGroupScroll()
end
--[[
function wnd_array_stone_suit_rank:updateFinishedGroup()
	local stoneSuit = {}
	self._stoneSuit = {}
	for k, v in pairs(i3k_db_array_stone_suit_group) do
		for i, j in ipairs(self._overview.equips) do
			if j ~= 0 then
				if g_i3k_db.i3k_db_is_in_stone_suit_group(j, k) then
					if not stoneSuit[k] then
						stoneSuit[k] = {}
					end
					table.insert(stoneSuit[k], j)
				end
			end
		end
	end
	for k, v in pairs(stoneSuit) do
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, i3k_db_array_stone_suit_group[k].includeSuit[1]) then
			local finishSuit = {}
			for i, j in ipairs(i3k_db_array_stone_suit_group[k].includeSuit) do
				if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, j) then
					table.insert(finishSuit, j)
				end
			end
			table.insert(self._stoneSuit, {groupId = k, stones = v, finishSuit = finishSuit})
		end
	end
end
--]]
function wnd_array_stone_suit_rank:updateSuitGroupScroll()
	if next(self._stoneSuit) then
		self._layout.vars.suitNameBg:show()
		self._layout.vars.groupScroll:removeAllChildren()
		for k, v in ipairs(self._stoneSuit) do
			local node = require("ui/widgets/zfsphbt2")()
			node.vars.groupIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_suit_group[v.groupId].groupIcon))
			node.vars.groupName:setText(i3k_db_array_stone_suit_group[v.groupId].groupName)
			node.vars.count:hide()
			node.vars.groupBtn:onClick(self, self.onChangeSuitGroup, k)
			node.vars.chooseIcon:setVisible(k == self._curGroupIndex)
			node.vars.unfoldIcon:setVisible(k == self._curGroupIndex and self._isShowChild)
			self._layout.vars.groupScroll:addItem(node)
		end
		self._childIndex = 1
		self._isShowChild = true
		self:addSuitGroupChildren()
	else
		self._layout.vars.suitNameBg:hide()
	end
end

function wnd_array_stone_suit_rank:onChangeSuitGroup(sender, index)
	if self._curGroupIndex == index then
		if self._isShowChild then
			self:removeSuitGroupChildren()
			
		else
			self:addSuitGroupChildren()
			local children = self._layout.vars.groupScroll:getAllChildren()
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
				v.vars.unfoldIcon:hide()
				v.vars.chooseIcon:hide()
			end
		end
		self._childIndex = 1
		self._isShowChild = true
		self:addSuitGroupChildren()
	end
end

function wnd_array_stone_suit_rank:addSuitGroupChildren()
	local index = 1
	local groupId = self._stoneSuit[self._curGroupIndex].groupId
	local suitId = i3k_db_array_stone_suit_group[groupId].includeSuit[self._childIndex]
	if g_i3k_db.i3k_db_get_is_finish_stone_suit(self._stoneSuit[self._curGroupIndex].stones, suitId) then
		self._curSuitLevel = g_i3k_db.i3k_db_get_stone_suit_level(self._stoneSuit[self._curGroupIndex].stones, suitId)
	else
		self._curSuitLevel = 1
	end
	for k, v in ipairs(self._stoneSuit[self._curGroupIndex].finishSuit) do
		local node = require("ui/widgets/zfsphbt4")()
		node.vars.finishIcon:hide()
		node.vars.btn:onClick(self, self.onChooseSuitId, k)
		if k == self._childIndex then
			node.vars.btn:stateToPressed(true)
		else
			node.vars.btn:stateToNormal(true)
		end
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(self._stoneSuit[self._curGroupIndex].stones, v) then
			local level = g_i3k_db.i3k_db_get_stone_suit_level(self._stoneSuit[self._curGroupIndex].stones, v)
			node.vars.name:setText(i3k_get_string(g_SUIT_LEVEL_STRING[level]) .. i3k_db_array_stone_suit[v].name)
		else
			node.vars.name:setText(i3k_get_string(g_SUIT_LEVEL_STRING[1]) .. i3k_db_array_stone_suit[v].name)
		end
		self._layout.vars.groupScroll:insertChildToIndex(node, index + self._curGroupIndex)
		index = index + 1
	end
	self:updateStoneSuitProperty()
end

function wnd_array_stone_suit_rank:onChooseSuitId(sender, index)
	if self._childIndex == index then
		
	else
		self._childIndex = index
		local groupId = self._stoneSuit[self._curGroupIndex].groupId
		local children = self._layout.vars.groupScroll:getAllChildren()
		for k = 1, #self._stoneSuit[self._curGroupIndex].finishSuit do
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
		self:updateStoneSuitProperty()
	end
end

function wnd_array_stone_suit_rank:removeSuitGroupChildren()
	for k = 1, #self._stoneSuit[self._curGroupIndex].finishSuit do
		self._layout.vars.groupScroll:removeChildAtIndex(self._curGroupIndex + 1)
	end
end

function wnd_array_stone_suit_rank:updateStoneSuitProperty()
	self._layout.vars.textScroll:removeAllChildren()
	local groupId = self._stoneSuit[self._curGroupIndex].groupId
	local suitId = i3k_db_array_stone_suit_group[groupId].includeSuit[self._childIndex]
	local node = require("ui/widgets/zfsphbt3")()
	node.vars.text:setText(g_i3k_db.i3k_db_get_array_stone_suit_desc(suitId, self._curSuitLevel))
	self._layout.vars.textScroll:addItem(node)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui._layout.vars.textScroll, width, height, true)
	end, 1)
	self._layout.vars.suitName:setText(i3k_db_array_stone_suit_group[self._stoneSuit[self._curGroupIndex].groupId].groupName)
end

function wnd_create(layout)
	local wnd = wnd_array_stone_suit_rank.new()
	wnd:create(layout)
	return wnd
end