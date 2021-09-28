-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_garrison_donate = i3k_class("wnd_garrison_donate",ui.wnd_add_sub)

function wnd_garrison_donate:ctor()
	self._getPower = 1
end

function wnd_garrison_donate:configure()
	local widgets = self._layout.vars

	self.item_icon = widgets.itemIcon
	self.item_bg = widgets.itemBg
	self.item_name = widgets.itemName
	self.item_count = widgets.itemCount
	self.donateCount = widgets.donateCount
	self.getCount = widgets.getCount
	-- self.donateCount:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	-- self.donateCount:addEventListener(function(eventType)
	-- 	if eventType == "ended" then
	-- 		local str = tonumber(self.donateCount:getText()) or 1
	-- 		if str > self.current_add_num then
	-- 			str = self.current_add_num
	-- 		end
	-- 		if str > g_edit_box_max then
	-- 			str = g_edit_box_max
	-- 		end
	-- 		if str < 1 then
	-- 			str = 1
	-- 		end
	-- 		self.donateCount:setText(str)
	-- 		self.money_count:setText(str*g_i3k_db.i3k_db_get_common_item_sell_count(self._itemid))
	-- 		self.current_num = str
	-- 	end
	-- end)

	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max

	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
	widgets.donateBtn:onClick(self, self.onDonateBtn)
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_garrison_donate:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionGarrisonDonate, "setDonateCount", self.current_num)
	end
end

function wnd_garrison_donate:setDonateCount(count)
	self.donateCount:setText(count)
	self.getCount:setText(count * self._getPower)
end

function wnd_garrison_donate:refresh(id, haveCount, getPowerCount, bossDonateData)
	self._bossDonateDate = nil
	self._itemId = id
	self.current_num = 0
	self._getPower = getPowerCount
	local itemCount =  g_i3k_game_context:GetCommonItemCanUseCount(id)
	if not bossDonateData then
		local allItemCount = i3k_db_faction_garrison.openCondition.donationItemCount
		itemCount = itemCount > allItemCount and allItemCount or itemCount
		self.current_add_num = math.min(allItemCount - haveCount,  itemCount)
	else
		self._bossDonateDate = bossDonateData
		self._layout.vars.leftTimes:setVisible(true)
		self._leftTimes = bossDonateData.limitTimes - bossDonateData.useTimes
		
		self.current_add_num = math.min(self._leftTimes,  itemCount)		
		self._layout.vars.leftTimes:setText(string.format("今日还可捐赠%s个", self._leftTimes))
	end

	self:setDonateCount(self.current_num)
	self:loadItemInfo(id)
	self:updatefun()
end

function wnd_garrison_donate:loadItemInfo(id)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.item_bg:onClick(self, self.onItmeTips, id)
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(id))
end

function wnd_garrison_donate:onDonateBtn(sender)
	if self._bossDonateDate then
		if self.current_num > g_i3k_game_context:GetCommonItemCanUseCount(self._itemId) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16655))
			return
		end
		if self._leftTimes <=0 or self.current_num > self._leftTimes then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16656))
			return
		end
		if self.current_num == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16622))
			return
		end
		i3k_sbean.request_sect_zone_boss_item_req(self._bossDonateDate.bossId,self._itemId,self.current_num)
	else
		if self.current_num > 0 then
			i3k_sbean.sect_zone_build(self.current_num)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16622))
		end
	end
end

function wnd_garrison_donate:onItmeTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout)
	local wnd = wnd_garrison_donate.new()
	wnd:create(layout)
	return wnd
end
