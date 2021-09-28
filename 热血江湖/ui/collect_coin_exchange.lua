-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_collect_coin_exchange = i3k_class("wnd_collect_coin_exchange",ui.wnd_base)

local DH_ITEM_WIDGET = "ui/widgets/shunianjnjb3t"
local RowitemCount = 2

function wnd_collect_coin_exchange:ctor()
    self.data = {}
    self.woodsSort = {}
end

function wnd_collect_coin_exchange:configure()
    self._layout.vars.topinfo1:setVisible(false)
    self._layout.vars.topinfo2:setVisible(false)
    self._layout.vars.exchange_btn:setVisible(false)
end

function wnd_collect_coin_exchange:refresh(data, isShowTop)
    self.data = data
    self.isShowTop = isShowTop
    self.wnbid = i3k_db_commecoin_cfg.exchangeConfig.getPropId
    local widgets = self._layout.vars
    widgets.topinfo1:setVisible(isShowTop)
    widgets.topinfo2:setVisible(isShowTop)
    widgets.wnb_count:setText(g_i3k_game_context:GetBagItemCount(self.wnbid))
    widgets.wnb_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.wnbid))
    widgets.wnb_btn:onClick(self, self.onTips, self.wnbid)
    widgets.bj_jnb:setText(i3k_db_commecoin_cfg.exchangeConfig.unitPrice)
    widgets.bl_wnb:setText(self.data.nowExchangeScale)
    widgets.bl_jnbicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_commecoin_cfg.buyConfig.getPropId))
    widgets.bl_wnbicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.wnbid))
    widgets.exchange_btn:onClick(self, self.OnOpenExchangeTips)
    widgets.exchange_btn:setVisible(isShowTop)
    
    self.scroll = widgets.scroll
    self:updateExchangeList()
    widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_collect_coin_exchange:updateExchangeList()
    self.scroll:removeAllChildren()
    self.woodsSort = {}
    self:sortChangeWoods()
    local itemsCount = #i3k_db_commecoin_changewoods
    local allitems = self.scroll:addChildWithCount(DH_ITEM_WIDGET, RowitemCount, itemsCount)

    for i, item in ipairs(allitems) do
        self:setItemContent(i, item)
	end
end

--排序兑换物品
function wnd_collect_coin_exchange:sortChangeWoods()
    for k, v in ipairs(i3k_db_commecoin_changewoods) do
        local isHaveMax = i3k_db_commecoin_changewoods[k].changeNums ~= -1
        local canChangeNums = i3k_db_commecoin_changewoods[k].changeNums
        local sortIndex = i3k_db_commecoin_changewoods[k].sortIndex
        if self.data.exchangeItemNums[k] then
            canChangeNums = math.max(canChangeNums - self.data.exchangeItemNums[k], 0)
            if canChangeNums == 0 then
                sortIndex = -100
            end
        end
        local tab = {
            index = k,
            isHaveMax = isHaveMax,
            canChangeNums = canChangeNums,
            sortIndex = sortIndex
        }
        table.insert(self.woodsSort, tab)
    end
    table.sort(self.woodsSort, function (a, b)
        return a.sortIndex > b.sortIndex
	end)
end

--设置每个兑换物品单元内容
function wnd_collect_coin_exchange:setItemContent(i, item)
    local cfg = i3k_db_commecoin_changewoods[self.woodsSort[i].index]
    item.vars.itemicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.changeItemId))
    item.vars.itembg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.changeItemId))
    item.vars.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(cfg.changeItemId))
    item.vars.itemcount:setText(cfg.changeItemNums)
    item.vars.itembg:onClick(self, self.onTips, cfg.changeItemId)
    item.vars.needicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.goods_id1))
    item.vars.needcount:setText(cfg.goods_count1)
    item.vars.needbtn:onClick(self, self.onChangeItem, i)
    item.vars.synums:setText(i3k_get_string(19100, self.woodsSort[i].canChangeNums))
    item.vars.synums:setVisible(self.woodsSort[i].isHaveMax)
end

--兑换道具
function wnd_collect_coin_exchange:onChangeItem(sender, i)
    if self.woodsSort[i].canChangeNums ~= 0 then
        local cfg = i3k_db_commecoin_changewoods[self.woodsSort[i].index]
        if g_i3k_game_context:GetBagItemCount(self.wnbid) >= cfg.goods_count1 then
            local tbl = {}
            local Id = "goods_id"
            local Count = "goods_count"
            for i = 1, 2 do
                tbl[Id .. i] = cfg[Id .. i]
                tbl[Count .. i] = cfg[Count .. i]
            end
            tbl.isShowTop = self.isShowTop
            tbl.type = g_EXCHANGE_USEWN_GOODS
            tbl.index = self.woodsSort[i].index
            tbl.isHaveMax = self.woodsSort[i].isHaveMax
            tbl.limit_time = self.woodsSort[i].canChangeNums
            g_i3k_logic:OpenExchangeMoreUI(tbl, g_EXCHANGE_ACTIVITY)
        else
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19102))
        end
    else
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19098))
    end
end

--打开兑换万能币tips
function wnd_collect_coin_exchange:OnOpenExchangeTips(sender)
    local jnbCount = g_i3k_game_context:GetBagItemCount(i3k_db_commecoin_cfg.buyConfig.getPropId)
        if jnbCount > 0 then
        local limit_time = math.floor(jnbCount / i3k_db_commecoin_cfg.exchangeConfig.unitPrice)
        local tbl = {
            isHaveMax = true,
            limit_time = limit_time,
            type = g_EXCHANGE_WANNENGCOIN,
            changeScale = self.data.nowExchangeScale,
            goods_id1 = i3k_db_commecoin_cfg.buyConfig.getPropId,
            goods_count1 = i3k_db_commecoin_cfg.exchangeConfig.unitPrice,
        }
        g_i3k_logic:OpenExchangeMoreUI(tbl, g_EXCHANGE_ACTIVITY)
    else
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19101))
    end
end

function wnd_collect_coin_exchange:onTips(sender, itemId)
    g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout, ...)
	local wnd = wnd_collect_coin_exchange.new()
	wnd:create(layout, ...)
	return wnd
end
