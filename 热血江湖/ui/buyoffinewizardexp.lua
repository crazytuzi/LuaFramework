-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_buyOffineWizardExp = i3k_class("wnd_buyOffineWizardExp",ui.wnd_add_sub)

local Cfg = i3k_db_offline_exp.buyExp

function wnd_buyOffineWizardExp:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian  
	self.max_btn = widgets.max
	self.current_num = 1	
	self._count_label = widgets.sale_count 
	self._count_label:setText("1")
	self._max_str = nil 
	self._min_str = nil 
	self._fun = nil
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)	
	
	widgets.plusTen_btn:onClick(self, self.plusTen)
	widgets.buy_btn:onClick(self, self.onBuy)
end

function wnd_buyOffineWizardExp:ctor()
	
end

function wnd_buyOffineWizardExp:refresh(info)
	self:setMsgPlus("已达到本次升级所需次数")
	self:getMaxTimes(info)
	self:showInfo()
	self:updateFun()
	
	--对输入的数字进行控制
	self._count_label:addEventListener(function(eventType)
		if eventType == "ended" then
			if self._count_label:getText() ~= "" and tonumber(self._count_label:getText()) then
			    local num = tonumber(self._count_label:getText())
			    if num > self.current_add_num then
			       self.current_num = self.current_add_num
			    elseif num < 1 then
			       self.current_num = 1
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
			self:showInfo()
		end
	end)
end

function wnd_buyOffineWizardExp:setNumCount(count)
	self._count_label:setText(count)
end

function wnd_buyOffineWizardExp:updateFun()
	self._fun = function()
		self:setNumCount(self.current_num)
		self:showInfo()
	end
end

function wnd_buyOffineWizardExp:getMaxTimes(info)
	local nextExp = i3k_db_activity_wipe[info.lvl+1].expArgs
	local needExp = nextExp - info.exp
	self.current_add_num = math.ceil(needExp/Cfg.gainExp)
	self._layout.vars.get_desc:setText("升级还需" .. needExp .. "点经验，需购买" .. self.current_add_num .. "次")
end

function wnd_buyOffineWizardExp:showInfo()
	local widgets = self._layout.vars
	widgets.costCount:setText(Cfg.consumeCount * self.current_num)
	widgets.gain:setText(Cfg.gainExp * self.current_num .. "精灵经验")
end

function wnd_buyOffineWizardExp:plusTen(sender)
	if self.current_num == self.current_add_num then
		g_i3k_ui_mgr:PopupTipMessage("已达到本次升级所需次数")
	elseif self.current_num == 1 then
		self.current_num = 10
	elseif self.current_num + 10 <= self.current_add_num then
	    self.current_num = self.current_num + 10
	elseif self.current_num + 10 > self.current_add_num then
		self.current_num = self.current_add_num
	end
	self:setNumCount(self.current_num)
	self:showInfo()
end

function wnd_buyOffineWizardExp:onBuy(sender)
	local haveBound = g_i3k_game_context:GetBaseItemCount(Cfg.consumeId)
	local haveTotal = g_i3k_game_context:GetCommonItemCanUseCount(Cfg.consumeId)
	if haveTotal < Cfg.consumeCount * self.current_num then
		g_i3k_ui_mgr:PopupTipMessage("绑定元宝不足")
	elseif haveBound < Cfg.consumeCount * self.current_num then
		local callfunction = function(ok)
			if ok then
				i3k_sbean.buyOffineWizardExp(self.current_num)
			end
		end
		local msg = i3k_get_string(299,haveBound, Cfg.consumeCount * self.current_num-haveBound)
		g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
	else
		i3k_sbean.buyOffineWizardExp(self.current_num)
	end
end

function wnd_create(layout)
	local wnd = wnd_buyOffineWizardExp.new()
	wnd:create(layout)
	return wnd
end
