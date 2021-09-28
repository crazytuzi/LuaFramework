-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_buy_business_stars = i3k_class("buy_business_stars", ui.wnd_base)

local BPSLDZT = "ui/widgets/bpsldzt"

function wnd_buy_business_stars:ctor()
	
end

function wnd_buy_business_stars:configure()
	self._layout.vars.cancel_btn:onClick(self, self.onCloseUI)
end

function wnd_buy_business_stars:refresh(stars)
	self._layout.vars.desc1:setText(i3k_get_string(17119, stars*i3k_db_factionBusiness.cfg.oneStarCost))
	self._layout.vars.ok_btn:onClick(self, self.onBuyBtn, stars)
	self._layout.vars.money_count:setText(stars * i3k_db_factionBusiness.cfg.oneStarCost)
	self._layout.vars.suo:hide()
	for _, v in ipairs(i3k_db_factionBusiness.cfg.oneStarAward) do
		local layer = require(BPSLDZT)()
		layer.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		layer.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id), g_i3k_game_context:IsFemaleRole())
		layer.vars.suo:setVisible(v.id > 0)
		layer.vars.btn:onClick(self, self.onItem, v.id)
		layer.vars.count:setText(string.format("x%s", stars * v.count))
		self._layout.vars.scroll:addItem(layer)
	end
	local layer = require(BPSLDZT)()
	layer.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(g_BASE_ITEM_EXP))
	layer.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP, g_i3k_game_context:IsFemaleRole()))
	layer.vars.suo:hide()
	layer.vars.count:setText(string.format("x%dw", math.floor(stars * i3k_db_factionBusiness.cfg.expRate * i3k_db_exp[g_i3k_game_context:GetLevel()].businessExp / 10000)))
	self._layout.vars.scroll:addItem(layer)
end

function wnd_buy_business_stars:onBuyBtn(sender, stars)
	if g_i3k_game_context:GetCommonItemCount(-1) >= stars*i3k_db_factionBusiness.cfg.oneStarCost then
		i3k_sbean.sect_trade_route_buy_starReq(stars)
		g_i3k_ui_mgr:CloseUI(eUIID_BuyBusinessStars)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17121))
	end
end

function wnd_buy_business_stars:onItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_buy_business_stars.new()
	wnd:create(layout)
	return wnd
end
