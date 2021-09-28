-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local ITEM = "ui/widgets/lyjf"
local ITEM2 = "ui/widgets/lyjft2"
-------------------------------------------------------
wnd_unlockHunyu = i3k_class("wnd_unlockHunyu", ui.wnd_base)

function wnd_unlockHunyu:ctor()

end

function wnd_unlockHunyu:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.up_btn1:onClick(self, self.onUnlockBtn)
	-- widgets.upTips:setText()
end

function wnd_unlockHunyu:refresh(fengyinID)
	self:updateScroll(fengyinID)
end

-- 购买物品后刷新数量
function wnd_unlockHunyu:refreshItem()
	self:updateScroll(self._fengyinID)
end

function wnd_unlockHunyu:updateScroll(fengyinID)
	self._fengyinID = fengyinID -- 保存一下
	local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(fengyinID)
	local needItems = fengyinCfg.needItem
	local scroll1 = self._layout.vars.consumeScroll
 	self:updateCommonScroll(scroll1, needItems, false)

	local getItems = fengyinCfg.gainItem
	local scroll2 = self._layout.vars.getScroll
	self:updateCommonScroll(scroll2, getItems, true)
end

function wnd_unlockHunyu:createItem(info, isGainItem)
	local widget = isGainItem and require(ITEM2)() or require(ITEM)()
	local curCount = self:getCanUseCount(info.itemID)
	local needCount = info.itemCount
	if math.abs(info.itemID) == 2 or math.abs(info.itemID) == 1 then -- 铜钱
		widget.vars.countLabel:setText(needCount)
	else
		widget.vars.countLabel:setText(curCount.."/"..needCount)
	end
	widget.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.itemID))
	local showLock = (isGainItem and info.itemID > 0) or (not isGainItem and (math.abs(info.itemID) == 2 or math.abs(info.itemID) == 1))
	widget.vars.lock:setVisible(showLock) -- 消耗道具不显示锁
	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.itemID, i3k_game_context:IsFemaleRole()))
	widget.vars.infoBtn:onClick(self, self.onIconBtn, info.itemID)
	-- 如果是获得的东西
	if isGainItem then
		widget.vars.countLabel:setText("x"..needCount)
	else
		widget.vars.countLabel:setTextColor(g_i3k_get_cond_color(curCount >= needCount))
	end
	return widget
end
function wnd_unlockHunyu:onIconBtn(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_unlockHunyu:getCanUseCount(itemID)
	if itemID > 0 then
		local banCount = g_i3k_game_context:GetCommonItemCount(itemID)
		local unBanCount = g_i3k_game_context:GetCommonItemCount(-itemID)
		return banCount + unBanCount
	else
		local banCount = g_i3k_game_context:GetCommonItemCount(itemID)
		return banCount
	end
end

function wnd_unlockHunyu:updateCommonScroll(scroll, data, isGainItem)
	scroll:removeAllChildren()
	for i, v in ipairs(data) do
		if v.itemCount > 0 then
			local widget = self:createItem(v, isGainItem)
			scroll:addItem(widget)
		end
	end
end

function wnd_unlockHunyu:checkNeedItems()
	local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(self._fengyinID)
	local flag = true
	for i, v in ipairs(fengyinCfg.needItem) do
		local curCount = self:getCanUseCount(v.itemID)
		local needCount = v.itemCount
		if curCount < needCount then
			flag = false
		end
		-- flag = flag and curCount >= needCount -- 可以简写
	end
	return flag
end

function wnd_unlockHunyu:checkBagFull()
	local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(self._fengyinID)
	local isEnoughTable = { }
	local gift = {}
	local index = 0
	for i,v in pairs(fengyinCfg.gainItem) do
		if v.itemID ~= 0 then
			isEnoughTable[v.itemID] = v.itemCount
		end
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		gift[index] = {id = i,count = v}
	end
	if isEnough then
		return gift
	else
		return false
	end
end

function wnd_unlockHunyu:onUnlockBtn(sender)
	if not self:checkNeedItems() then
		g_i3k_ui_mgr:PopupTipMessage("您的解封道具不足，不能解封此封印")
		return
	end
	local gift = self:checkBagFull()
	if not gift then
		g_i3k_ui_mgr:PopupTipMessage("您的包裹空间不足，不能解封此封印")
		return
	end
	local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(self._fengyinID)
	local useItems = fengyinCfg.needItem
	i3k_sbean.seal_dispelling(self._fengyinID, gift, useItems)
end

function wnd_unlockHunyu:unlockCallback(needItem)
	for _, v in pairs (needItem) do
		if v.itemID > 0 then
			local banCount = g_i3k_game_context:GetCommonItemCount(v.itemID)
			if v.itemCount > banCount then
				g_i3k_game_context:UseCommonItem(v.itemID, banCount, AT_SEAL_DISPELLING)--UseBagItem
				g_i3k_game_context:UseCommonItem(-v.itemID, v.itemCount - banCount, AT_SEAL_DISPELLING)
			else
				g_i3k_game_context:UseCommonItem(v.itemID, v.itemCount, AT_SEAL_DISPELLING)
			end
		else
			g_i3k_game_context:UseCommonItem(v.itemID, v.itemCount, AT_SEAL_DISPELLING)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_unlockHunyu.new()
		wnd:create(layout, ...)
	return wnd
end
