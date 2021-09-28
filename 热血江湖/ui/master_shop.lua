-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local store_base = require("ui/store_base");
-------------------------------------------------------

local LAYER_BPSDT = "ui/widgets/bpsdt"
-- local SHOP_NAME =  "ui/widgets/chushit2" --TODO: 商店图标
local STR_POINT_DESC = 5009 -- string id of master point

--------------------------------------------------------
-- 师徒点商店
local ROW_COUNT = 3

master_store = i3k_class("master_store", store_base.wnd_store_base)

function wnd_create(layout, ...)
	local wnd = master_store.new()
	wnd:create(layout, ...);
	return wnd
end

function master_store:ctor()
	self._curPage = 4
end

function master_store:configure(...)
	local widgets = self._layout.vars;
	widgets.close_btn:onClick(self,self.onCloseUI)
	widgets.refresh_btn:onClick(self,self.onClickRefresh)

	self.imgPointIcon = widgets.contri_icon  -- 师徒点图标
	self.txtPoint = widgets.contri_value     -- 师徒点
	self.txtRefreshTime = self._layout.vars.refreshTime -- 下次自动刷新时间
	self.scrollItems = widgets.item_scroll  -- 商品列表
	self.btnPointTips = widgets.money_root  -- 货币说明按钮
	self.btnPointTips:onTouchEvent(self,self.onTouchPointIcon)

	-- widgets.shopName:setImage("") -- TODO 缺美术资源
	self.imgPointIcon:setImage( g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_MASTER_POINT,i3k_game_context:IsFemaleRole()) ) --TODO 缺美术资源

	widgets.subPage:onClick(self, self.onSubPage)
	widgets.addPage:onClick(self, self.onAddPage)
	widgets.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(3727))
end

function master_store:refresh()
end
-----------------------------------------------------------------
-- 更新商城信息，shopinfo is i3k_sbean.ShopInfo
function master_store:_getNextRefreshTime()

	local times = i3k_db_master_store_refresh.refreshTime
	local _times = {}
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)

	local Y = os.date("%Y",serverTime)
	local M = os.date("%m",serverTime)
	local D = os.date("%d",serverTime)
	local count = 0
	for k,v in ipairs(times) do
		count = count + 1
		local h = string.sub(v,1,2)
		local m = string.sub(v,4,4)
		local s = string.sub(v,5,5)

		local next_time = os.time{year = Y,month = M,day = D,hour = h,min = m,sec = s,isdst=false}

		if next_time > serverTime then
			return v
		end
		if count == #times  and next_time < serverTime then
			return times[1]
		end
	end
end
-- 更新师徒点显示
function master_store:updatePoint(point)
	self.txtPoint:setText("" .. point)
end
-- 更新商品列表显示
function master_store:updateStore(shopinfo)

	self.txtRefreshTime:setText(self:_getNextRefreshTime())

	if shopinfo==nil or shopinfo.goods==nil then
		return
	end

	local items = shopinfo.goods
	local itemCount = #items
	self.scrollItems:removeAllChildren()
	local children = self.scrollItems:addChildWithCount(LAYER_BPSDT, ROW_COUNT, itemCount)
	for i,v in ipairs(children) do
		local id = items[i].id
		local buyTimes = items[i].buyTimes
		local itemid = i3k_db_master_store.item_data[id].itemID
		local maxCount =  i3k_db_master_store.item_data[id].itemCount
		local out_icon = v.vars.out_icon

		local tmp_str = string.format("%s*%s",i3k_db_master_store.item_data[id].itemName,maxCount)
		v.vars.item_name:setText(tmp_str)

		v.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))

		local item_btn = v.vars.item_btn
		if buyTimes == 0 then
			out_icon:hide()
			item_btn:onClick(self,self.onClickItemBuy,i)
		else
			out_icon:show()
			item_btn:setTouchEnabled(true)
		end

		v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_master_store.item_data[id].moneyType,i3k_game_context:IsFemaleRole()))
		v.vars.money_count:setText(i3k_db_master_store.item_data[id].moneyCount)
	end
end
-----------------------------------------------------------------
	-- 刷新商店
function master_store:onClickRefresh()
	--  刷新需要花费师徒点
	local point = g_i3k_game_context:GetMasterPoint()
	local refreshTimes = g_i3k_game_context:GetMasterShopInfo().refreshTimes

	local pointNeed=0 -- 师徒点花费
	local diamdNeed=0 -- 元宝花费

	if refreshTimes+1>=#i3k_db_faction_store_refresh.refreshMoneyCount then
		local index=#i3k_db_master_store_refresh.refreshMoneyCount
		pointNeed = i3k_db_master_store_refresh.refreshMoneyCount[index]
	else
		pointNeed = i3k_db_master_store_refresh.refreshMoneyCount[refreshTimes+1]
	end

	if refreshTimes+1>=#i3k_db_faction_store_refresh.refreshMoneyCount2 then
		local index=#i3k_db_master_store_refresh.refreshMoneyCount2
		diamdNeed = i3k_db_master_store_refresh.refreshMoneyCount2[index]
	else
		diamdNeed = i3k_db_master_store_refresh.refreshMoneyCount2[refreshTimes+1]
	end

	local bDiamdEnough, nRealDiamd = self:enoughDiamond(diamdNeed)
	local bPointEnough = point >= pointNeed
	if not bPointEnough and not bDiamdEnough then
		g_i3k_ui_mgr:PopupTipMessage("师徒点和元宝不足")
		return
	end
	self:openRefreshItemUI(g_BASE_ITEM_MASTER_POINT, pointNeed, bPointEnough, diamdNeed, nRealDiamd, refreshTimes)
end
	-- 按住货币图标的说明
function master_store:_getBtnPosition()
	local btnSize = self.btnPointTips:getParent():getContentSize()
	local sectPos = self.btnPointTips:getPosition()
	local btnPos = self.btnPointTips:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end
function master_store:onTouchPointIcon(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(STR_POINT_DESC), self:_getBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end
	-- 点击商品按钮
function master_store:onClickItemBuy(sender,idx)
	-- 弹出购买商品的面板
	local shopinfo = g_i3k_game_context:GetMasterShopInfo()
	 -- buyTimes只能买一次，看后面购买代码，应该是这个概念
	if shopinfo.goods[idx].buyTimes>0 then
		g_i3k_ui_mgr:PopupTipMessage("商品已经售完")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Master_shop_buy)
	g_i3k_ui_mgr:RefreshUI(eUIID_Master_shop_buy,idx)
end
