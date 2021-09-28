-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local store_base = require("ui/store_base");
-------------------------------------------------------
wnd_petRaceShop = i3k_class("wnd_petRaceShop", store_base.wnd_store_base)

local LAYER_BPSDT = "ui/widgets/bpsdt"
local RowitemCount = 3

function wnd_petRaceShop:ctor()
	self._index = nil
	self._curPage = 5
end

function wnd_petRaceShop:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local refresh_btn = self._layout.vars.refresh_btn
	refresh_btn:onTouchEvent(self,self.onRefresh)
	self.contri_icon = self._layout.vars.contri_icon
	self.contri_value = self._layout.vars.contri_value
	self.refreshTime = self._layout.vars.refreshTime
	self.item_scroll = self._layout.vars.item_scroll
	self.money_root = self._layout.vars.money_root
	self.money_root:onTouchEvent(self,self.onitemTips)

	self._layout.vars.subPage:onClick(self, self.onSubPage)
	self._layout.vars.addPage:onClick(self, self.onAddPage)
	self._layout.vars.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(4292))
end

function wnd_petRaceShop:onShow()

end

function wnd_petRaceShop:onitemTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(16011), self:getBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_petRaceShop:getBtnPosition()
	local btnSize = self.money_root:getParent():getContentSize()
	local sectPos = self.money_root:getPosition()
	local btnPos = self.money_root:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_petRaceShop:refreshPetCoin(value)
	self.contri_value:setText(value)
end

function wnd_petRaceShop:updateStoreItem(items)
	self.contri_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_PETCOIN, i3k_game_context:IsFemaleRole()))
	if not items then
		return
	end
	self.refreshTime:setText(self:getNextRefreshTime())
	local itemCount = #items
	local row = math.modf(itemCount/RowitemCount)
	local last = itemCount%RowitemCount
	if last ~= 0 then
		row = row + 1
	end

	local children = self.item_scroll:addChildWithCount(LAYER_BPSDT, RowitemCount, itemCount)
	for i,v in ipairs(children) do
		local id = items[i].id
		local buyTimes = items[i].buyTimes
		local itemid = i3k_db_pet_race_store.item_data[id].itemID
		local maxCount =  i3k_db_pet_race_store.item_data[id].itemCount
		local out_icon = v.vars.out_icon
		local tmp_str = string.format("%s*%s",i3k_db_pet_race_store.item_data[id].itemName, maxCount)
		v.vars.item_name:setText(tmp_str)
		v.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		local item_btn = v.vars.item_btn
		if buyTimes == 0 then
			out_icon:hide()
			item_btn:setTag(i)
			item_btn:onTouchEvent(self,self.onItemBuy)
		else
			out_icon:show()
			item_btn:setTouchEnabled(true)
		end
		v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_pet_race_store.item_data[id].moneyType, i3k_game_context:IsFemaleRole()))
		v.vars.money_count:setText(i3k_db_pet_race_store.item_data[id].moneyCount)
	end
end

function wnd_petRaceShop:getNextRefreshTime()
	local times = i3k_db_pet_race_store_refresh.refreshTime
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

function wnd_petRaceShop:onRefresh(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local contribution = g_i3k_game_context:GetPetRaceCoin()
		local refreshTimes = g_i3k_game_context:getPetRaceShopRefreshTimes()
		local moneyCount
		local diaCnt
		if i3k_db_pet_race_store_refresh.refreshMoneyCount[refreshTimes + 1] then
			moneyCount = i3k_db_pet_race_store_refresh.refreshMoneyCount[refreshTimes + 1]
			diaCnt = i3k_db_pet_race_store_refresh.refreshMoneyCount2[refreshTimes + 1]
		else
			local _index = #i3k_db_pet_race_store_refresh.refreshMoneyCount
			moneyCount = i3k_db_pet_race_store_refresh.refreshMoneyCount[_index]
			diaCnt = i3k_db_pet_race_store_refresh.refreshMoneyCount2[_index]
		end
		local isEnough, sub = self:enoughDiamond(diaCnt)
		local spEnough = contribution < moneyCount
		if spEnough and not isEnough then
			g_i3k_ui_mgr:PopupTipMessage("龟龟币和元宝不足")
			return
		end
		self:openRefreshItemUI(g_BASE_ITEM_PETCOIN, moneyCount, not spEnough, diaCnt, sub, refreshTimes)
	end
end


function wnd_petRaceShop:onItemBuy(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local index = sender:getTag()
		local data = g_i3k_game_context:getPetRaceShopData()
		local id = data.items[index].id
		local haveTime = data.items[index].buyTimes
		local maxCount =  i3k_db_pet_race_store.item_data[id].itemCount
		if maxCount - haveTime <= 0 then
			g_i3k_ui_mgr:PopupTipMessage("已卖完")
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_PetRaceShopBuy)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetRaceShopBuy, index)
	end
end

function wnd_petRaceShop:refresh(info, contribution)
	self._curPage = 5
	self:updateStoreItem(info.goods)
	self:refreshPetCoin(contribution)
end


function wnd_create(layout, ...)
	local wnd = wnd_petRaceShop.new()
	wnd:create(layout, ...);
	return wnd
end
