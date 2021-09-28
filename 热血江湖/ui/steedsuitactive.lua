-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedSuitActive = i3k_class("wnd_steedSuitActive", ui.wnd_base)

function wnd_steedSuitActive:ctor()
	self._suitCfg = nil
	self._suitID = nil
end

function wnd_steedSuitActive:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.activeBtn:onClick(self, self.onActive)
	widgets.desc:setText(i3k_get_string(1641))
end

function wnd_steedSuitActive:refresh(suitID)
	self._suitID = suitID
	self._suitCfg = i3k_db_steed_equip_suit[suitID]
	self:updateUI()
end

function wnd_steedSuitActive:updateUI()
	local widgets = self._layout.vars
	local suitCfg = self._suitCfg
	widgets.title:setText(suitCfg.name)
	self:updateCostScroll()
end

function wnd_steedSuitActive:updateCostScroll()
	local widgets = self._layout.vars
	local items = self._suitCfg.needItems

	widgets.scroll:removeAllChildren()
	for k, v in ipairs(items) do
		local node = require("ui/widgets/qizhantaozhuangjht")()
		local itemID = v.id
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		if math.abs(itemID) == g_BASE_ITEM_DIAMOND or math.abs(itemID) == g_BASE_ITEM_COIN then
			node.vars.count:setText(v.count)
			node.vars.lock:setVisible(itemID > 0)
		else
			node.vars.count:setText(itemCount .."/".. v.count)
			node.vars.lock:hide()
		end
		node.vars.count:setTextColor(g_i3k_get_cond_color(itemCount >= v.count))
		node.vars.btn:onClick(self, self.onItemTips, itemID)
		widgets.scroll:addItem(node)
	end
end

function wnd_steedSuitActive:checkItems()
	local suitCfg = self._suitCfg
	for _, v in ipairs(suitCfg.needItems) do
		local itemID = v.id
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		if itemCount < v.count then
			return false
		end
	end
	return true
end

function wnd_steedSuitActive:onActive(sender)
	if not self:checkItems() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
		return
	end
	local suitID = self._suitID
	if suitID then
		i3k_sbean.steedEquipSuitActive(suitID)
	end
end

function wnd_steedSuitActive:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout)
	local wnd = wnd_steedSuitActive.new();
	wnd:create(layout);
	return wnd;
end
