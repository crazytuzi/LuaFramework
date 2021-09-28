module(..., package.seeall)
local require = require
local ui = require("ui/base")

local wnd_flyingExpItem = i3k_class("wnd_flyingExpItem", ui.wnd_base)

local UNBIND_FLAG = -1

function wnd_flyingExpItem:ctor()
	self.itemsList = {}
end

function wnd_flyingExpItem:configure()
	local vars = self._layout.vars
	self.scroll = vars.scroll
	self.descript_text = vars.descript_text
	self.auto_btn = vars.auto_btn
	self.auto_btn:onClick(self, self.onAutoBtnClick)
	self.close_btn = vars.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
end

function wnd_flyingExpItem:refresh()
	self.scroll:removeAllChildren()
	self.itemsList = {}
	self.descript_text:setText(i3k_get_string(1808))
	local itemList = i3k_db_feisheng_misc.expItemList
	for k, v in ipairs(itemList) do
		local cfg = i3k_db_new_item[v]
		local itemNum = g_i3k_game_context:GetCommonItemCanUseCount(cfg.id)
		local node = require("ui/widgets/feishengjysyt")()
		self.itemsList[cfg.id] = node
		local nodeVars = node.vars
		nodeVars.rank_img:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.rank))
		nodeVars.item_img:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
		nodeVars.num_text:setText("x" .. itemNum)
		nodeVars.desc_text:setText(cfg.args1)
		nodeVars.item_btn:onTouchEvent(self, self.onItemBtnTouch, cfg.id)
		self.scroll:addItem(node)
	end
end

function wnd_flyingExpItem:onHide()
	if self.co then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	end
end

function wnd_flyingExpItem:onAutoBtnClick(sender)
	local itemList = i3k_db_feisheng_misc.expItemList
	local items = {}
	local diff = self:getExpDiff()
	local flag = false
	for i = #itemList, 1, -1 do
		local cfg = i3k_db_new_item[itemList[i]]
		local itemCnt = g_i3k_game_context:GetCommonItemCount(cfg.id)
		if itemCnt > 0 then
			flag = true
			local canUseNum = math.floor(diff / cfg.args1)
			if canUseNum > itemCnt then
				items[cfg.id] = itemCnt
				diff = diff - itemCnt * cfg.args1
			elseif canUseNum > 0 then
				items[cfg.id] = canUseNum
				diff = diff - canUseNum * cfg.args1
			end
		end
	end
	for i = #itemList, 1, -1 do
		local cfg = i3k_db_new_item[itemList[i]]
		local itemCnt = g_i3k_game_context:GetCommonItemCount(cfg.id * UNBIND_FLAG)
		if itemCnt > 0 then
			flag = true
			local canUseNum = math.floor(diff / cfg.args1)
			if canUseNum > itemCnt then
				items[cfg.id * UNBIND_FLAG] = itemCnt
				diff = diff - itemCnt * cfg.args1
			elseif canUseNum > 0 then
				items[cfg.id * UNBIND_FLAG] = canUseNum
				diff = diff - canUseNum * cfg.args1
			end
		end
	end
	if table.nums(items) > 0 then
		self:useExpItem(items)
	elseif flag then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1792))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1794))
	end
end

function wnd_flyingExpItem:onItemBtnTouch(sender, eventType, itemID)
	local itemCnt = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	local items = {[itemID] = 1}
	if eventType == ccui.TouchEventType.began then
		if itemCnt <= 0 then
			g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
			return
		end
		if self:getExpDiff() < i3k_db_new_item[itemID].args1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1792))
			return
		end
		local unbindItems = self:partUnbindItems(items)
		self:useExpItem(unbindItems)
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.5)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingExpItem, "coroutinefunc", itemID, items)
			end
		end)
	elseif eventType ~= ccui.TouchEventType.moved then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	end
end

function wnd_flyingExpItem:coroutinefunc(itemID, items)
	local itemCnt = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	if itemCnt <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1792))
		return
	elseif self:getExpDiff() < i3k_db_new_item[itemID].args1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1792))
		return
	else
		local unbindItems = self:partUnbindItems(items)
		self:useExpItem(unbindItems)
	end
end

function wnd_flyingExpItem:partUnbindItems(items)
	local unbindItems = {}
	for k, v in pairs(items) do
		local bindItemNum = g_i3k_game_context:GetCommonItemCount(k)
		if v > bindItemNum then
			unbindItems[k] = bindItemNum ~= 0 and bindItemNum or nil
			unbindItems[k * UNBIND_FLAG] = v - bindItemNum ~= 0 and v - bindItemNum or nil
		else
			unbindItems[k] = v
		end
	end
	return unbindItems
end

function wnd_flyingExpItem:useExpItem(items)
	i3k_sbean.use_flying_item(items)
end

function wnd_flyingExpItem:getExpDiff()
	local currentExp = g_i3k_game_context:getFlyingExp()
	local maxExp = g_i3k_game_context:getFlyingMaxExp()
	return maxExp - currentExp
end

function wnd_flyingExpItem:updateExpItemNum(items)
	for k, v in pairs(items) do
		local itemNum = g_i3k_game_context:GetCommonItemCanUseCount(k)
		self.itemsList[math.abs(k)].vars.num_text:setText("x" .. itemNum)
	end
end

function wnd_create(layout)
	local wnd = wnd_flyingExpItem.new()
	wnd:create(layout)
	return wnd
end