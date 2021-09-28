-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_add_sub = i3k_class("wnd_add_sub",ui.wnd_base)

function wnd_add_sub:ctor()
	self.add_btn = nil	--加的按钮
	self.sub_btn = nil  --减的按钮
	
	self.max_btn = nil --一键最大的按钮
	self.current_num = 1	--当前实际的数值 
	self.current_add_num = 1 --当前可以增加到的最大值
	self.current_sub_num = 1 --当前可以减少到的最小值
	
	self._count_label = nil --显示当前数字的label
	
	self._max_str = nil --最大上限提示
	self._min_str = nil --最少下限提示
	
	self._fun = nil 
	
	self._msgPlus = "已达到上限"
	self._msgMinus = "不能再少了"
end

function wnd_add_sub:configure()
	
end

function wnd_add_sub:onAdd(sender,eventType, isShowMax)
	if eventType == ccui.TouchEventType.began  then
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.05) --延时
				if not self.current_num or not self.current_add_num then
					g_i3k_coroutine_mgr:StopCoroutine(self.co)
					return 
				end 
				if self.current_num < self.current_add_num then
					self.current_num  = self.current_num + 1
				else
					if self._max_str then
						g_i3k_ui_mgr:PopupTipMessage(self._max_str)
					else
						g_i3k_ui_mgr:PopupTipMessage(self._msgPlus)
					end
					
				end 
				--[[
				if isShowMax then
					local tmp_str = string.format("%s/%s",self.current_num,self.current_add_num)
					self._count_label:setText(tmp_str)
				else
					self._count_label:setText(self.current_num)
				end
				--]]
				if self._fun then
					self._fun()
				end
			end 
		end)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	end

end 

function wnd_add_sub:onAddTen(sender, eventType, isShowMax)
	if eventType == ccui.TouchEventType.ended  then
		if self.current_num < self.current_add_num then
			if self.current_num + 10 > self.current_add_num then
				self.current_num = self.current_add_num
			else
				self.current_num  = self.current_num + 10
			end
		else
			if self._max_str then
				g_i3k_ui_mgr:PopupTipMessage(self._max_str)
			else
				g_i3k_ui_mgr:PopupTipMessage(self._msgPlus)
			end
		end 
		if self._fun then
			self._fun()
		end
	end
end
function wnd_add_sub:onSub(sender,eventType, isShowMax)
	if eventType == ccui.TouchEventType.began  then
		if not self.current_add_num then
			error(string.format("Trying to use a nil number to current_add_num "))
		end 
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.05) --延时
				if not self.current_num or not self.current_add_num then
					g_i3k_coroutine_mgr:StopCoroutine(self.co)
					return 
				end 
				if tonumber(self.current_num) > self.current_sub_num then
					self.current_num  = self.current_num - 1
				else
					if self._min_str then
						g_i3k_ui_mgr:PopupTipMessage(self._min_str)
					else
						g_i3k_ui_mgr:PopupTipMessage(self._msgMinus)
					end
					g_i3k_coroutine_mgr:StopCoroutine(self.co)
					return
				end 
				--[[
				if isShowMax then
					local tmp_str = string.format("%s/%s",self.current_num,self.current_add_num)
					self._count_label:setText(tmp_str)
				else
					self._count_label:setText(self.current_num)
				end
				--]]
				if self._fun then
					self._fun()
				end
			end 
		end)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	end
end 

function wnd_add_sub:onMax(sender,eventType, isShowMax)
	if eventType == ccui.TouchEventType.ended then
		if not self.current_add_num then
			error(string.format("Trying to use a nil number to current_add_num "))
		end 
		if self.current_add_num ~= 0 and self.current_add_num then
			self.current_num = self.current_add_num
		end
		--[[
		if isShowMax then
			self._count_label:setText(self.current_num.."/"..self.current_num)
		else
			self._count_label:setText(self.current_num)
		end
		--]]
		if self._fun then
			self._fun()
		end
	end
end 

--调用本文件时，子类如果重写ohHide需要自己再销毁协成
function wnd_add_sub:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self.co)
end 

-- 经验丹
function wnd_add_sub:onUseExpItems()
	local itemExp = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args1
	local itemCount = self._item_count
	local maxNum, isCue =  g_i3k_game_context:GetAddExpNumber(itemExp, itemCount)
	local func = function()
		i3k_sbean.bag_useitemexp(self._itemid, self.current_num)
	end

	if g_i3k_game_context:GetLevel() <= g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args2 then
		if isCue and self.current_num == maxNum then
			local fun = (function(ok)
				if ok then
					func()
				end
			end)
			local name = g_i3k_db.i3k_db_get_common_item_name(self._itemid)
			local num = self.current_num
			local str = ""
			if g_i3k_db.i3k_db_get_limit_condition() then
				str = i3k_get_string(826, num, name, num, name, name)
			else
				str = i3k_get_string(825, num, name, num, name)
			end
			g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", str, fun)
			return false
		else
			func()
			return true
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15585))
	end
end

function wnd_add_sub:setMsgPlus(msg)
	self._msgPlus = msg
end

function wnd_add_sub:setMsgMinus(msg)
	self._msgMinus = msg
end

function wnd_create(layout)
	local wnd = wnd_add_sub.new()
		wnd:create(layout)
	return wnd
end
