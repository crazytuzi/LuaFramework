-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_setWareHouseItemPrice = i3k_class("wnd_setWareHouseItemPrice",ui.wnd_add_sub)

function wnd_setWareHouseItemPrice:ctor()
	
end

function wnd_setWareHouseItemPrice:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)
	
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian  

	self.current_num = 1	
	self._count_label = widgets.sale_count 
	self._count_label:setText("1")
	self._max_str = nil 
	self._min_str = nil 
	self._fun = nil
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)

end

function wnd_setWareHouseItemPrice:refresh(id, info)
	self._info = info
	self.current_num = info.itemsPrice[id] or i3k_db_new_item[id].defaultScore
	self._count_label:setText(self.current_num)
	self.current_add_num = i3k_db_crossRealmPVE_shareCfg.maxchangeRate * i3k_db_new_item[id].defaultScore
	self.current_sub_num = i3k_db_crossRealmPVE_shareCfg.minchangeRate * i3k_db_new_item[id].defaultScore
	self._layout.vars.suggest:onClick(self, self.setRightPrice, id)
	self._layout.vars.ok:onClick(self, self.changePrice, id)
	self:showItemInfo(id)
	self:updateFun()
	
	self._count_label:addEventListener(function(eventType)
		if eventType == "ended" then
			if self._count_label:getText() ~= "" and tonumber(self._count_label:getText()) then
			    local num = tonumber(self._count_label:getText())
			    if num > self.current_add_num then
			       self.current_num = self.current_add_num
			    elseif num < self.current_sub_num then
			       self.current_num = self.current_sub_num
			    else 
					self.current_num = num
		        end
				if self.current_num > g_edit_box_max then
					self.current_num = g_edit_box_max
				end
				if self.current_num < 1 then
					self.current_num = 1
				end
		        self._count_label:setText(self.current_num)
			else 
				self._count_label:setText(self.current_num)
		    end
		end
	end)
end

function wnd_setWareHouseItemPrice:showItemInfo(id)
	local widgets = self._layout.vars
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_count:setText(i3k_get_string(1356,i3k_db_new_item[id].applyNum))
	widgets.item_fitPrice:setText(i3k_db_new_item[id].defaultScore)
end

function wnd_setWareHouseItemPrice:updateFun()
	self._fun = function()
		self:setNumCount(self.current_num)
	end
end

function wnd_setWareHouseItemPrice:setNumCount(count)
	self._count_label:setText(count)
end

function wnd_setWareHouseItemPrice:setRightPrice(sender, id)
	self.current_num = i3k_db_new_item[id].defaultScore
	self._count_label:setText(self.current_num)
end

function wnd_setWareHouseItemPrice:changePrice(sender, id)
	local callback = function(ok)
			if ok then
				if self:ifCanChangePrice() then
					i3k_sbean.globalpve_changeSharePrice(id, self.current_num)
					self:onCloseUI()
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1357))
				end
			end 
		end
	if self._info.itemsPrice[id] then
		if self._info.itemsPrice[id] ~= self.current_num then
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1348), callback)
		end
	elseif self.current_num ~= i3k_db_new_item[id].defaultScore then
		 g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1348), callback)
	end
end

function wnd_setWareHouseItemPrice:ifCanChangePrice()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local open = string.split(i3k_db_crossRealmPVE_shareCfg.allotTime, ":")
	openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})  -- boss开始刷新的时间
	if (timeStamp < openTimeStamp) and (openTimeStamp - timeStamp <= i3k_db_crossRealmPVE_shareCfg.stopChange) then
		return false
	else
		return true
	end
end

function wnd_create(layout)
	local wnd = wnd_setWareHouseItemPrice.new()
	wnd:create(layout)
	return wnd
end
