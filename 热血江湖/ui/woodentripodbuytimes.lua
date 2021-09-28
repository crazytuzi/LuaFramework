-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_woodenTripodBuyTimes = i3k_class("wnd_woodenTripodBuyTimes",ui.wnd_add_sub)

function wnd_woodenTripodBuyTimes:ctor()
end

function wnd_woodenTripodBuyTimes:configure()
	local widget = self._layout.vars
	
	self.add_btn = widget.jia_btn
	self.sub_btn = widget.jian_btn  
	self.max_btn = widget.max_btn
	self.current_num = 1	
	self._count_label = widget.sale_count 
	self._count_label:setText("1")
	self._max_str = nil 
	self._min_str = nil 
	self._fun = nil
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)
	
	widget.cancel_btn:onClick(self, self.onCloseUI)
	widget.ok_btn:onClick(self, self.buyTimes)
end

function wnd_woodenTripodBuyTimes:refresh(leftTimes)
	self.current_add_num = leftTimes
	self:showCost()
	self:updateFun()
	self:showTimesInfo()
end

function wnd_woodenTripodBuyTimes:setNumCount(count)
	self._count_label:setText(count)
end

function wnd_woodenTripodBuyTimes:updateFun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripodBuyTimes,"setNumCount",self.current_num)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripodBuyTimes,"showCost")
	end
end

function wnd_woodenTripodBuyTimes:buyTimes(sender)
	if self._totalCost > g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND) then
		g_i3k_ui_mgr:PopupTipMessage("元宝不足")
	else
	    i3k_sbean.woodenTripodBuyTimes(self.current_num, self._totalCost)
	end
end

function wnd_woodenTripodBuyTimes:showTimesInfo()
	local widget = self._layout.vars
	widget.desc1:setText(string.format("本日您还可以购买%d%s",self.current_add_num,"次"))
	local index = g_i3k_game_context:GetVipLevel() + 1
	if i3k_db_kungfu_vip[index] then
		for i = index , #i3k_db_kungfu_vip do
			if i3k_db_kungfu_vip[i].woodenTripodBuyTimes > i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].woodenTripodBuyTimes then
				widget.desc2:show()
		        widget.desc2:setText(string.format("升级至贵族%d%s%d%s", i ,"：每日可购买",i3k_db_kungfu_vip[i].woodenTripodBuyTimes,"次"))
				break
			else
			    widget.desc2:hide()
			end
		end
		--widget.desc2:show()
		--widget.desc2:setText(string.format("升级至贵族%d%s%d%s",g_i3k_game_context:GetVipLevel() + 1,"：每日可购买",i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel() + 1].woodenTripodBuyTimes,"次"))
	else
	    widget.desc2:hide()
	end
end

function wnd_woodenTripodBuyTimes:showCost()
	local totalCost = 0
	local index = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].woodenTripodBuyTimes - self.current_add_num 
	if self.current_num + index <= #i3k_db_woodenTripod_cfg.diamondNum then
		for i = index + 1 , self.current_num + index  do
			totalCost = totalCost + i3k_db_woodenTripod_cfg.diamondNum[i]
		end 
	elseif (index  < #i3k_db_woodenTripod_cfg.diamondNum) and (self.current_num + index > #i3k_db_woodenTripod_cfg.diamondNum) then
	      for i = index + 1 , #i3k_db_woodenTripod_cfg.diamondNum  do
			totalCost = totalCost + i3k_db_woodenTripod_cfg.diamondNum[i]
          end
		  totalCost = totalCost + i3k_db_woodenTripod_cfg.diamondNum[#i3k_db_woodenTripod_cfg.diamondNum] * (self.current_num + index - #i3k_db_woodenTripod_cfg.diamondNum)
	elseif  index  >= #i3k_db_woodenTripod_cfg.diamondNum then
	      totalCost = totalCost + i3k_db_woodenTripod_cfg.diamondNum[#i3k_db_woodenTripod_cfg.diamondNum] * self.current_num 
	end
	self._totalCost = totalCost
	self._layout.vars.money_count:setText(totalCost)
end
	
function wnd_create(layout)
	local wnd = wnd_woodenTripodBuyTimes.new()
	wnd:create(layout)
	return wnd
end
