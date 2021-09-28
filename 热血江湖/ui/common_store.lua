-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local item_info = "ui/widgets/tqsdt"

-------------------------------------------------------
wnd_common_store = i3k_class("wnd_common_store", ui.wnd_base)

local SelectExp =
{
	[ 1] = function(tbl) -- 过滤优先级
		local _cmp = function(d1, d2)
			return d1.filterorder < d2.filterorder;
		end
		table.sort(tbl, _cmp);
	end,
};

moneyiconlist = {32,30}

function wnd_common_store:ctor()
	self.filterItem = {};
	self.groupid=0
end

function wnd_common_store:refresh(gid)
	self.groupid=gid
	self.filterItem = {};
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
	self:getStoreItemList(gid)
	self:setStoreItems();
end

function wnd_common_store:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.item_scroll = self._layout.vars.item_scroll
	
	local widgets = self._layout.vars
	self.diamond = widgets.diamond
	self.diamondLock = widgets.diamondLock
	self.coin = widgets.coin
	self.coinLock = widgets.coinLock
	
	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self, self.addCoinBtn)

end

function wnd_common_store:updateMoney(diamondF, diamondR, coinF, coinR)
	self.diamond:setText(diamondF)
	self.diamondLock:setText(diamondR)
	self.coin:setText(i3k_get_num_to_show(coinF))
	self.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_common_store:addDiamondBtn(sender)
	if i3k_game_get_map_type() == g_FIELD then
		g_i3k_logic:OpenChannelPayUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(918))
	end
end

function wnd_common_store:addCoinBtn(sender)
	if i3k_game_get_map_type() == g_FIELD then
		g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(919))
	end
end


function wnd_common_store:onShow()
	
end

function wnd_common_store:onHide()

end

function wnd_common_store:setStoreItems()
	self.item_scroll:removeAllChildren(refreshall)
	
	local allBars = self.item_scroll:addChildWithCount(item_info, 3, #self.filterItem)
	for index, bar in ipairs(allBars) do
		local item = self.filterItem[index]
		self:setItemDetail(bar,item,index)
	end
end

function wnd_common_store:setItemDetail(bar,item,index)
	local item_btn = bar.vars.item_btn
	local item_name = bar.vars.item_name
	local item_bg = bar.vars.item_bg
	local item_icon = bar.vars.item_icon
	local money_count = bar.vars.money_count
	local money_icon = bar.vars.money_icon
	local moneylockicon = bar.vars.moneylockicon
	local item_filter = bar.vars.item_filter
	local itemlockicon = bar.vars.itemlockicon
	
	local pkpunish = g_i3k_game_context:GetPKPunish()--pk惩罚
	moneylockicon:hide()
	itemlockicon:hide()
	item_filter:setVisible(false);
	item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item.linkitemid)))
	item_btn:setTag(index)
	item_btn:onTouchEvent(self, self.onBuyBtnClick)
	item_bg:setImage(i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.linkitemid))
	item_icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(item.linkitemid,i3k_game_context:IsFemaleRole()))
	if item.itemcount > 1 then
		item_name:setText(i3k_db.i3k_db_get_common_item_name(item.linkitemid).."*"..item.itemcount)
	else
		item_name:setText(i3k_db.i3k_db_get_common_item_name(item.linkitemid))
	end
	local reqlvl = g_i3k_db.i3k_db_get_common_item_level_require(item.linkitemid)
	if reqlvl > g_i3k_game_context:GetLevel() then
		item_filter:setVisible(true);
	end
	if item.buytype > 0 then
		moneylockicon:show()
	end
	if item.linkitemid > 0 then
		itemlockicon:show()
	end
	money_icon:setImage(i3k_db.i3k_db_get_icon_path(moneyiconlist[math.abs(item.buytype)]))
	money_count:setText(math.floor(item.itemprice*(1+pkpunish)))---需要统计pk惩罚
end

function wnd_common_store:getStoreItemList(gid)
	local cfg = i3k_db_drugshop[gid]
	for k,v in ipairs(cfg) do
		if v.issell == 1 then
			table.insert(self.filterItem,v)
		end
	end
	if #self.filterItem > 0 then
		local exp = SelectExp[1];
		exp(self.filterItem);
	end
end


--[[function wnd_common_store:onClose(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_CommmonStore)
	end
end--]]

function wnd_common_store:onBuyBtnClick(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local index = sender:getTag()
		local item = self.filterItem[index]
		g_i3k_ui_mgr:OpenUI(eUIID_CommmonStoreBuy)
		g_i3k_ui_mgr:RefreshUI(eUIID_CommmonStoreBuy,item,self.groupid)
	end
end
	
function wnd_create(layout, ...)
	local wnd = wnd_common_store.new()
		wnd:create(layout, ...)

	return wnd
end
