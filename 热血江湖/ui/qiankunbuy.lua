-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_qiankunbuy = i3k_class("wnd_qiankunbuy", ui.wnd_base)

local LAYER_QKSJT = "ui/widgets/qksjt"

function wnd_qiankunbuy:ctor()
	self._needItems = {}
	self._getPoint = 0
	self._discount = 0
end

function wnd_qiankunbuy:configure( )
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.discountRoot = widgets.discountRoot
	self.buyBtn = widgets.buyBtn
	self.desc = widgets.desc
	self.scroll = widgets.scroll
	
	self.buyLabel = widgets.buyLabel
	self.disLabel = widgets.disLabel
	self.discountDesc = widgets.discountDesc
	self.buyBtn:onClick(self, self.onClickBuyBtn)
	widgets.buyBtn2:onClick(self, self.onClickBuyBtn)
	widgets.discountBtn:onClick(self, self.onClickDiscountBtn)
end

function wnd_qiankunbuy:refresh(isDiscount)
 	self:initNeedItemsAndDesc(g_i3k_game_context:getQiankunInfo(), isDiscount)
	self:updateScroll()
end

function wnd_qiankunbuy:initNeedItemsAndDesc(info, isDiscount)
	self._needItems = {}
	local db = i3k_db_experience_universe_buy
	local times = info.buyTimes
	local cfg = db[times+1] or db[#db]
	local discountPoint = db[#db].buyPoint
	self._getPoint = isDiscount and discountPoint or cfg.getPoint
	self._discount = isDiscount and 1 or 0
	if isDiscount then
		self.buyBtn:setVisible(true)
		self.discountRoot:setVisible(false)
		self.buyLabel:setText(i3k_get_string(927, discountPoint))
	else
		local isShowDis = times+1 >= #db and i3k_db_experience_args.experienceUniverse.maxPoint - info.totalPoints >= discountPoint
		self.buyLabel:setText("购买")
		self.disLabel:setText(i3k_get_string(928))
		self.discountDesc:setText(i3k_get_string(927, discountPoint))
		self.buyBtn:setVisible(not isShowDis)
		self.discountRoot:setVisible(isShowDis)
	end
	self.desc:setText(i3k_get_string(872, self._getPoint, i3k_db_experience_args.experienceUniverse.maxPoint - info.totalPoints))
	for i, e in ipairs(cfg.rewards) do
		if e ~= 0 then
			table.insert(self._needItems, {itemID = e, itemCount = isDiscount and cfg.needCount[i] or cfg.rewardsNum[i]})
		end
	end
end

function wnd_qiankunbuy:updateScroll()
	self.scroll:removeAllChildren()
	for _, e in ipairs(self._needItems) do
		local widget = require(LAYER_QKSJT)()
		widget.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
		widget.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemID))
		widget.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemID)))
		if math.abs(e.itemID) == g_BASE_ITEM_DIAMOND or math.abs(e.itemID) == g_BASE_ITEM_COIN then
			widget.vars.item_count:setText(e.itemCount)
		else
			widget.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID).."/"..e.itemCount)
		end
		widget.vars.item_count:setTextColor(g_i3k_get_cond_color(e.itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)))
		widget.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		widget.vars.tip_btn:onClick(self, self.onItemTips, e.itemID)
		self.scroll:addItem(widget)
	end
end

function wnd_qiankunbuy:getIsCanBuyPoint()
	local num = 0
	for _, e in ipairs(self._needItems) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)
		if canUseCount >= e.itemCount then
			num = num + 1
		end
	end
	return num == #self._needItems
end

function wnd_qiankunbuy:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_qiankunbuy:onClickBuyBtn(sender)
	if self:getIsCanBuyPoint() then
 		i3k_sbean.dmgtransfer_buypoint(self._discount, self._getPoint, self._needItems)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(921))
	end
end

function wnd_qiankunbuy:onClickDiscountBtn(sender)
	self:refresh(true)
end

function wnd_create(layout)
	local wnd = wnd_qiankunbuy.new()
	wnd:create(layout)
	return wnd
end
	
