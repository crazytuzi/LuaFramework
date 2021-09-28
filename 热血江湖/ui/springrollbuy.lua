module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_springRollBuy = i3k_class("wnd_springRollBuy", ui.wnd_base)

function wnd_springRollBuy:ctor()
	self._npcID = nil
end

function wnd_springRollBuy:configure()
	local widgets = self._layout.vars
	
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.buy_btn = widgets.buy_btn
	self.buy_btn:onClick(self, self.onBuyBtnClick)
	
	self.item_btn = widgets.item_btn
	self.item_btn:onClick(self, self.onItemBtnClick)
	
	self.item_name = widgets.item_name
	self.item_icon = widgets.item_icon
	self.item_rank = widgets.item_rank
	self.coin_num = widgets.coin_num
	self.npc_desc = widgets.npc_desc
end

function wnd_springRollBuy:refresh(npcID)
	self._npcID = npcID
	local groupID = g_i3k_game_context:getSpringRollGroupID()
	local cfg = i3k_db_spring_roll.npcConfig[groupID]
	self.coin_num:setText(string.format("x%s", cfg[npcID].args4))
	self.npc_desc:setText(i3k_get_string(19043, i3k_db_npc[npcID].remarkName))
	local itemID = i3k_db_spring_roll.rollConfig.itemImageID
	local itemCfg = i3k_db_new_item[itemID]
	self.item_name:setText(itemCfg.name)
	self.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(itemCfg.icon))
	self.item_rank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemCfg.rank))
end

function wnd_springRollBuy:onBuyBtnClick(sender)
	local isSpringRollOpen = g_i3k_game_context:checkSpringRollOpen()
	if not isSpringRollOpen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19167))
		g_i3k_ui_mgr:CloseUI(eUIID_SpringRollBuy)
		return
	end
	local groupID = g_i3k_game_context:getSpringRollGroupID()
	local cfg = i3k_db_spring_roll.npcConfig[groupID][self._npcID]
	local canUseCoin = g_i3k_game_context:GetMoneyCanUse(false)
	if canUseCoin <= cfg.args4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19044))
		return
	end
	i3k_sbean.spring_lantern_join(self._npcID)
end

function wnd_springRollBuy:onItemBtnClick(sender)
	g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_spring_roll.rollConfig.itemImageID)
end

function wnd_create(layout, ...)
	local wnd = wnd_springRollBuy.new()
	wnd:create(layout, ...)
	return wnd
end