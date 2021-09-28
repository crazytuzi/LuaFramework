-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local store_base = require("ui/store_base");
-------------------------------------------------------
wnd_faction_store = i3k_class("wnd_faction_store", store_base.wnd_store_base)

local LAYER_BPSDT = "ui/widgets/bpsdt"
--帮贡id
local contributionID= 3
local RowitemCount = 3

function wnd_faction_store:ctor()
	self._index = nil
	self._curPage = 2
end

function wnd_faction_store:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local refresh_btn = self._layout.vars.refresh_btn
	refresh_btn:onTouchEvent(self,self.onRefresh)
	self.contri_icon = self._layout.vars.contri_icon
	self.contri_value = self._layout.vars.contri_value
	self.refreshTime = self._layout.vars.refreshTime
	self.item_scroll = self._layout.vars.item_scroll
	self.money_root = self._layout.vars.money_root
	self.money_root2 = self._layout.vars.money_root2
	self.money_root:onTouchEvent(self,self.onitemTips, g_BASE_ITEM_SECT_MONEY)
	self.money_root2:onTouchEvent(self, self.onitemTips, g_BASE_ITEM_SECT_HONOR)
	self._layout.vars.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(2383))
	self._layout.vars.subPage:onClick(self, self.onSubPage)
	self._layout.vars.addPage:onClick(self, self.onAddPage)
end

function wnd_faction_store:onShow()

end

function wnd_faction_store:onitemTips(sender,eventType, currencyType)
	if eventType == ccui.TouchEventType.began then
		if currencyType == g_BASE_ITEM_SECT_MONEY then
			g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(309), self:getBtnPosition(self.money_root))
		else
			g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(16873), self:getBtnPosition(self.money_root2))
		end
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_store:getBtnPosition(root)
	local btnSize = root:getParent():getContentSize()
	local sectPos = root:getPosition()
	local btnPos = root:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_store:updateStoreItem(items)
	local contribution = g_i3k_game_context:GetSectContribution()
	local honor = g_i3k_game_context:getSectHonor()
	self.contri_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_SECT_MONEY,g_i3k_game_context:IsFemaleRole()))
	self.contri_value:setText(contribution)
	self._layout.vars.currencyIcon2:show()
	self._layout.vars.contri_value2:setText(honor)
	self._layout.vars.contri_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_SECT_HONOR, g_i3k_game_context:IsFemaleRole()))
	if not items then
		return
	end

	self.refreshTime:setText(self:getNextRefreshTime())

	local itemCount = #items
	local children = self.item_scroll:addChildWithCount(LAYER_BPSDT, RowitemCount, itemCount)
	for i,v in ipairs(children) do
		local id = items[i].id
		local buyTimes = items[i].buyTimes
		local itemid = i3k_db_faction_store.item_data[id].itemID
		local maxCount =  i3k_db_faction_store.item_data[id].itemCount
		local out_icon = v.vars.out_icon

		local tmp_str = string.format("%s*%s",i3k_db_faction_store.item_data[id].itemName,maxCount)
		v.vars.item_name:setText(tmp_str)
		v.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid, g_i3k_game_context:IsFemaleRole()))

		local item_btn = v.vars.item_btn
		if buyTimes == 0 then
			out_icon:hide()
			item_btn:setTag(i)
			item_btn:onTouchEvent(self, self.onItemBuy)
		else
			out_icon:show()
			item_btn:setTouchEnabled(true)
		end
		v.vars.money_icon:hide()
		v.vars.money_icon1:hide()
		v.vars.money_icon2:hide()
		if i3k_db_faction_store.item_data[id].moneyType ~= 0 and i3k_db_faction_store.item_data[id].moneyCount > 0 then
			if i3k_db_faction_store.item_data[id].moneyType2 ~= 0 and i3k_db_faction_store.item_data[id].moneyCount2 > 0 then
				v.vars.money_icon1:show()
				v.vars.money_icon2:show()
				v.vars.money_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[id].moneyType, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count1:setText(i3k_db_faction_store.item_data[id].moneyCount)
				v.vars.money_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[id].moneyType2, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count2:setText(i3k_db_faction_store.item_data[id].moneyCount2)
				if i3k_db_faction_store.item_data[id].moneyCount > contribution then
					v.vars.money_count1:setTextColor(g_COLOR_VALUE_RED)
				end
				if i3k_db_faction_store.item_data[id].moneyCount2 > honor then
					v.vars.money_count2:setTextColor(g_COLOR_VALUE_RED)
				end
			else
				v.vars.money_icon:show()
				v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[id].moneyType, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count:setText(i3k_db_faction_store.item_data[id].moneyCount)
				if i3k_db_faction_store.item_data[id].moneyCount > contribution then
					v.vars.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		else
			if i3k_db_faction_store.item_data[id].moneyType2 ~= 0 and i3k_db_faction_store.item_data[id].moneyCount2 > 0 then
				v.vars.money_icon:show()
				v.vars.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_store.item_data[id].moneyType2, g_i3k_game_context:IsFemaleRole()))
				v.vars.money_count:setText(i3k_db_faction_store.item_data[id].moneyCount2)
				if i3k_db_faction_store.item_data[id].moneyCount2 > honor then
					v.vars.money_count:setTextColor(g_COLOR_VALUE_RED)
				end
			end
		end
	end
end

function wnd_faction_store:getNextRefreshTime()

	local times = i3k_db_faction_store_refresh.refreshTime
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

function wnd_faction_store:onRefresh(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local contribution = g_i3k_game_context:GetSectContribution()
		local refreshTimes = g_i3k_game_context:GetFactionStoreRefreshTimes()
		local moneyCount
		local diaCnt
		if i3k_db_faction_store_refresh.refreshMoneyCount[refreshTimes + 1] then
			moneyCount = i3k_db_faction_store_refresh.refreshMoneyCount[refreshTimes + 1]
			diaCnt = i3k_db_faction_store_refresh.refreshMoneyCount2[refreshTimes + 1]
		else
			local _index = #i3k_db_faction_store_refresh.refreshMoneyCount
			moneyCount = i3k_db_faction_store_refresh.refreshMoneyCount[_index]
			diaCnt = i3k_db_faction_store_refresh.refreshMoneyCount2[_index]
		end
		local isEnough, sub = self:enoughDiamond(diaCnt)
		local spEnough = contribution < moneyCount
		if spEnough and not isEnough then
			g_i3k_ui_mgr:PopupTipMessage("帮贡和元宝不足")
			return
		end

		self:openRefreshItemUI(g_BASE_ITEM_SECT_MONEY, moneyCount, not spEnough, diaCnt, sub, refreshTimes)
		-- local fun = function(ok)
		-- 	if ok then
		-- 		local data = i3k_sbean.sect_shoprefresh_req.new()
		-- 		data.times = refreshTimes + 1
		-- 		i3k_game_send_str_cmd(data,i3k_sbean.sect_shoprefresh_res.getName())
		-- 	end
		-- end
		-- local desc = i3k_get_string(753,moneyCount)
		-- g_i3k_ui_mgr:ShowMessageBox2(desc,fun)

	end
end


function wnd_faction_store:onItemBuy(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local index = sender:getTag()
		local data = g_i3k_game_context:GetFactionStoreData()
		local id = data.items[index].id
		local haveTime = data.items[index].buyTimes
		local maxCount =  i3k_db_faction_store.item_data[id].itemCount
		if maxCount - haveTime <= 0 then
			g_i3k_ui_mgr:PopupTipMessage("已卖完")
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FactionStoreBuy)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionStoreBuy, index)
	end
end

function wnd_faction_store:refresh(items)
	self._curPage = 2
	self:updateStoreItem(items)
end


function wnd_create(layout, ...)
	local wnd = wnd_faction_store.new()
	wnd:create(layout, ...);

	return wnd
end
