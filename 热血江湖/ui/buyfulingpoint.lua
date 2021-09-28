
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_buyFulingPoint = i3k_class("wnd_buyFulingPoint",ui.wnd_base)

function wnd_buyFulingPoint:ctor()
	self._cfg = nil
	self._haveBuyPointsCnt = 0
	self._itemsEnough = false
end

function wnd_buyFulingPoint:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.buyBtn:onClick(self, self.onBuyPoint)
end

function wnd_buyFulingPoint:refresh()
	local haveBuyPointsCnt = g_i3k_game_context:GetFulingBuyPointsCnt()
	self._haveBuyPointsCnt = haveBuyPointsCnt
	self._cfg = i3k_db_longyin_sprite_buy_point[haveBuyPointsCnt + 1]
	self:updateDesc()
	self:updateItemScroll()
end

function wnd_buyFulingPoint:updateDesc()
	local widgets = self._layout.vars
	local haveBuyPoints = g_i3k_db.i3k_db_fuling_have_buy_points(self._haveBuyPointsCnt)
	local maxBuyPoints = g_i3k_db.i3k_db_fuling_max_buy_points()
	widgets.des1:setText(i3k_get_string(17737, haveBuyPoints, maxBuyPoints))

	widgets.des2:setText(i3k_get_string(17738))

	local addPoint = g_i3k_db.i3k_db_fuling_can_add_point(self._haveBuyPointsCnt + 1)
	widgets.des3:setText(i3k_get_string(17739, addPoint))

	--前提文本
	local curLevel = g_i3k_game_context:getFulingCurLevel()
	local curStage = g_i3k_db.i3k_db_fuling_stage_by_curLevel(curLevel - 1)
	widgets.des4:setText(i3k_get_string(17740, curStage, self._cfg.needFulingStage))
	local isCanBuy = curStage >= self._cfg.needFulingStage
	widgets.des4:setTextColor(g_i3k_get_cond_color(isCanBuy))
	widgets.buyBtn:SetIsableWithChildren(isCanBuy)
end

function wnd_buyFulingPoint:updateItemScroll()
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	self._itemsEnough = true
	local consumes = self._cfg.consumes
	for k, v in ipairs(consumes) do
		local ui = require("ui/widgets/gmfpdt")()
		local itemID = v.id
		local itemRank = g_i3k_db.i3k_db_get_common_item_rank(itemID)

		ui.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		ui.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
		ui.vars.item_name:setTextColor(g_i3k_get_color_by_rank(itemRank))

		ui.vars.suo:setVisible(itemID > 0)
		ui.vars.btn:onClick(self, self.onItemTips, itemID)
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		if math.abs(itemID) == g_BASE_ITEM_COIN or math.abs(itemID) == g_BASE_ITEM_DIAMOND then
			ui.vars.item_count:setText((v.count))
		else
			ui.vars.item_count:setText((haveCount).."/"..(v.count))
		end

		ui.vars.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= v.count))
		if haveCount < v.count then
			self._itemsEnough = false
		end
		scroll:addItem(ui)
	end
end

function wnd_buyFulingPoint:onBuyPoint(sender)
	if not self._itemsEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
		return
	end
	local consumes = self._cfg.consumes
	i3k_sbean.seal_given_spirit_buy_point(consumes)
end

function wnd_buyFulingPoint:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_buyFulingPoint.new()
	wnd:create(layout, ...)
	return wnd;
end

