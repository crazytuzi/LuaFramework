-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_gift_bag_select = i3k_class("wnd_gift_bag_select", ui.wnd_base)

local LAYER_NXUANNT = "ui/widgets/nxuannt"
local TOUCHTIME = 1.0

function wnd_gift_bag_select:ctor()
	self._id = 0
	self._count = 1
	self._selectItems = {}
	self._allItems = {}
	self._lastSelectedIndex = 0
	self._selectedCount = 0
	self._scheduler = nil
	self._touchFlag = true
end

function wnd_gift_bag_select:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)
	self.scroll = widget.scroll
	self.desc = widget.desc
	self.tips = widget.tips
	self.sureBtn = widget.sureBtn
	self.sureBtn:onClick(self, self.onSureBtn)
	self.sureBtn:disableWithChildren()
end

function wnd_gift_bag_select:refresh(id, count)
	self._id = id
	self._count = count
	self._selectItems = {}
	self._allItems = g_i3k_db.i3k_db_get_gift_bag_all_items(self._id, self._count)
	self:updateScroll()
	self.desc:setText(i3k_get_string(16948, self:getCanSelectMaxNum()))
	self.tips:setText(i3k_get_string(16949))
	self:showInfo()
end

function wnd_gift_bag_select:updateScroll()
	local items = self._allItems
	local allBars = self.scroll:addChildWithCount(LAYER_NXUANNT, 4, #items)
	self.allBars = allBars
	for i, v in ipairs(allBars) do
		local id = items[i].id
		local count = items[i].count
		v.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		v.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		v.vars.count:setText(count)
		v.vars.lock:setVisible(id > 0)
		v.vars.chosenIcon:hide()
		v.vars.item_btn:setTag(i)
		v.vars.item_btn:onClick(self, self.onSelectItem, v)
	end
end

function wnd_gift_bag_select:onSelectItem(sender, bar)
	local index = sender:getTag()
	local itemInfo = self._allItems[index]

	local is_select = bar.vars.chosenIcon:isVisible()
	local maxNum = self:getCanSelectMaxNum()
	self:showInfo(itemInfo)
	if not is_select then
		if maxNum == 1 then
			bar.vars.chosenIcon:show()
			if self._lastSelectedIndex and self._lastSelectedIndex ~= 0 then
				self.allBars[self._lastSelectedIndex].vars.chosenIcon:hide()
				self._selectItems[self._lastSelectedIndex] = nil
			end
			self._lastSelectedIndex = index
			self._selectItems[index] = itemInfo
			self._selectedCount = 1
		else
			if self._selectedCount < maxNum then
			bar.vars.chosenIcon:show()
				self._selectItems[index] = itemInfo
				self._selectedCount = self._selectedCount + 1
				self._lastSelectedIndex = index
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16950, maxNum))
			end
		end
	else
		bar.vars.chosenIcon:hide()
		self._selectItems[index] = nil
		self._selectedCount = self._selectedCount - 1
		self._lastSelectedIndex = nil
		if self._selectedCount == 0 then
			self:showInfo()
		end
	end
	if self._selectedCount < maxNum then
		self.sureBtn:disableWithChildren()
	else
		self.sureBtn:enableWithChildren()
	end
end

function wnd_gift_bag_select:showInfo(itemInfo)
	local widgets = self._layout.vars
	local id = itemInfo and itemInfo.id or self._id
	local count = itemInfo and itemInfo.count or self._count
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(id)
	widgets.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
	widgets.name:setText(cfg.name)
	widgets.name:setTextColor(name_colour)
	widgets.count:setText("x"..count)
	widgets.des:setText(cfg.desc)
end
function wnd_gift_bag_select:getCanSelectMaxNum()
	local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(self._id)
	local giftID = itemCfg.args1
	if itemCfg.type == UseItemGodEquip then
		return i3k_db_career_gift_bag[giftID].canSelectNum
	else
		return i3k_db_gift_bag[giftID].canSelectNum
	end
end

function wnd_gift_bag_select:onSureBtn(sender)
	local id = self._id
	local count = self._count
	local selectItems = {}
	for k, v in pairs(self._selectItems) do
		table.insert(selectItems,v)
	end

	local callback = function(ok)
		if ok then
			if selectItems and g_i3k_db.i3k_db_get_open_n_select_gift_is_enough(selectItems) then
				local choseIds = {}
				for _, v in ipairs(selectItems) do
					table.insert(choseIds, v.id)
				end
				if g_i3k_db.i3k_db_get_common_item_cfg(id).type == UseItemGodEquip then
					i3k_sbean.bag_useitemchosegiftnew(id, count, choseIds, selectItems)
				else
					i3k_sbean.bag_useitemchosegift(id, count, choseIds, selectItems)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
			end
		end
	end
	local desc = i3k_get_string(16951)
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end

function wnd_create(layout, ...)
	local wnd = wnd_gift_bag_select.new();
	wnd:create(layout, ...);
	return wnd;
end