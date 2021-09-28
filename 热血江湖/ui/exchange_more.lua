-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_exchange_more = i3k_class("wnd_exchange_more",ui.wnd_add_sub)


function wnd_exchange_more:configure()
	
	local widget = self._layout.vars
	
	self.scroll = widget.scroll
	self.times_count = widget.times_count
	self.ok = widget.ok
	self.ok:onClick(self, self.changeItems)
	self.cancel = widget.cancel
	self.cancel:onClick(self, self.onCloseUI)
	self.add_Ten = widget.addTen
	self.add_btn = widget.jia
	self.sub_btn = widget.jian  
	self.max_btn = widget.max
	self.current_num = 1	
	self._count_label = widget.sale_count 
	self._count_label:setText("1")
	self._max_str = nil 
	self._min_str = nil 
	self._fun = nil
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
end
function wnd_exchange_more:setMaxBtnEvent()
	if self.type == g_EXCHANGE_ACTIVITY and self.tbl.type == g_EXCHANGE_WANNENGCOIN then
		self.add_Ten:setVisible(true)
		self.max_btn:setVisible(false)
		self.add_Ten:onTouchEvent(self, self.onAddTen)
	else
	self.max_btn:onTouchEvent(self, self.onMax)	
	 
end
end
 
function wnd_exchange_more:firstOpen(tbl, type)
	self.tbl = tbl
	self.type = type
	self:setMaxBtnEvent()
	self:updateFun()
	self:setItemsAndNum(self.tbl)
	self:getLeftTimes() 
	if self.type == g_EXCHANGE_ACTIVITY and self.tbl.type == g_EXCHANGE_WANNENGCOIN then
		self._count_label:disable()
	else
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
				end
		        self._count_label:setText(self.current_num)
				if self._fun then
					self._fun()
		    end
		end
	end)
	end
end

function wnd_exchange_more:setItemsAndNum(tbl)
	
	self.scroll:removeAllChildren()
	--显示消耗物品
	local Id = "goods_id"
	local Count = "goods_count"
	for i =1, 3 do  
		if tbl[Id .. i] and tbl[Id .. i] ~= 0 then
			local widget = require("ui/widgets/dhslt")()
			if tbl[Id .. i] == g_BASE_ITEM_DIAMOND or tbl[Id .. i] == g_BASE_ITEM_COIN then
				widget.vars.item_lock:show()
			    widget.vars.item_count:setText(self.current_num * tbl[Count .. i])
			elseif tbl[Id .. i] == -g_BASE_ITEM_DIAMOND or tbl[Id .. i] == -g_BASE_ITEM_COIN then
			        widget.vars.item_lock:hide()
			        widget.vars.item_count:setText(self.current_num * tbl[Count .. i])
			else
			    local number = g_i3k_game_context:GetCommonItemCanUseCount(tbl[Id .. i])
				widget.vars.item_count:setText(string.format("%s/%s", number, self.current_num * tbl[Count .. i]))
				widget.vars.item_lock:hide()
		    end
			widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(tbl[Id .. i], g_i3k_game_context:IsFemaleRole()))
            widget.vars.item_count:setTextColor(g_i3k_get_cond_color(tbl[Count .. i] <= g_i3k_game_context:GetCommonItemCanUseCount(tbl[Id .. i])))
			widget.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(tbl[Id .. i]))
			widget.vars.bt:onClick(self, self.itemInfo, tbl[Id .. i])
			self.scroll:addItem(widget)
		end
	end 
	       
end

--获取剩余兑换次数
function wnd_exchange_more:getLeftTimes()
	local dayleftTimes = 0 
	if self.type == g_EXCHANGE_NPC then
	local times = g_i3k_game_context:GetRecordExchangeTimes()
	local limitTimes = i3k_db_npc_exchange[self.tbl.id].limit_times
		dayleftTimes = limitTimes - times[self.tbl.id].limit_time
	elseif self.type == g_EXCHANGE_ACTIVITY then
		if self.tbl.isHaveMax then
			dayleftTimes = self.tbl.limit_time
		else
			dayleftTimes = g_edit_box_max
		end
	end
	
	local minValue = dayleftTimes
	
	local Id = "goods_id"
	local Count = "goods_count"
	for i = 1, 3 do
		if self.tbl[Id .. i] and self.tbl[Id .. i] ~= 0 then
			local number = g_i3k_game_context:GetCommonItemCanUseCount(self.tbl[Id .. i])
			local num = math.floor(number / self.tbl[Count .. i])
			minValue = math.min(num, minValue)
		end
	end
	
	self.current_add_num = minValue                             
	self.times_count:setText(i3k_get_string(19100, dayleftTimes)) 
	if self.type == g_EXCHANGE_ACTIVITY then
		self.times_count:setVisible(self.tbl.type ~= g_EXCHANGE_WANNENGCOIN and self.tbl.isHaveMax)
	elseif self.type == g_EXCHANGE_NPC then
		self.times_count:setVisible(true)
	end 
	--if dayleftTimes == 0 then
	--	self.ok:disable() --次数不足，确定按钮置灰
	--	self.times_count:setTextColor(g_i3k_get_red_color())
	--end   
end

function wnd_exchange_more:setNumCount(count)
	if self.type == g_EXCHANGE_ACTIVITY and self.tbl.type == g_EXCHANGE_WANNENGCOIN then
		self._count_label:setText(count * self.tbl.changeScale)
	else
	self._count_label:setText(count)
	end
end

function wnd_exchange_more:updateFun()
	if self.type == g_EXCHANGE_ACTIVITY and self.tbl.type == g_EXCHANGE_WANNENGCOIN then
		self._count_label:setText(self.current_num * self.tbl.changeScale)
	else
		self._count_label:setText(self.current_num)
	end
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ExchangeMore,"setNumCount",self.current_num)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ExchangeMore,"setItemsAndNum",self.tbl)
	end
end

function wnd_exchange_more:changeItems(sender)
	if self.type == g_EXCHANGE_NPC then
	i3k_sbean.exchange_goods(self.tbl.npcId, self.tbl.id, self.current_num)
	elseif self.type == g_EXCHANGE_ACTIVITY then
		if self.tbl.type == g_EXCHANGE_USEWN_GOODS then	--万能币兑换物品
			i3k_sbean.syncExchangeCoin(self.tbl.index, self.current_num, self.tbl.isShowTop)
		elseif self.tbl.type == g_EXCHANGE_WANNENGCOIN then	--纪念币兑换万能币
			local scaleIndex = g_i3k_db.i3k_db_getCoin_changeScale()
			if self.tbl.changeScale ~= i3k_db_commecoin_addValueNode[scaleIndex].scaleValue then
				g_i3k_game_context:UpdateScaleToChangeCoin()	--提示兑换比例发生变化
			else
				local currentNum = self.current_num
				local jiedian = g_i3k_db.i3k_db_isMissBox_UseCoin(currentNum)
				if jiedian > 0 then
					local function callback(isOk)
						if isOk then
							i3k_sbean.syncCashcomCoin(scaleIndex, currentNum)
						end
					end
					local desc = i3k_get_string(19094, currentNum, jiedian - 1)
					g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
				else
					i3k_sbean.syncCashcomCoin(scaleIndex, currentNum)
				end
			end
		end
	end
	self:onCloseUI()
end

function wnd_exchange_more:itemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end


function wnd_create(layout)
	local wnd =wnd_exchange_more.new()
	wnd:create(layout)
	return wnd
end
