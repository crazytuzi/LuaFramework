-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_debrisRecycle = i3k_class("wnd_debrisRecycle", ui.wnd_base)

function wnd_debrisRecycle:ctor()
    self._falg = false
	self._timecounter = 0
	self._num = nil
end

function wnd_debrisRecycle:configure()
    local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.exchange_btn:onClick(self, self.onRecycle)
end

function wnd_debrisRecycle:onUpdate(dTime)
	if self._flag then
		self._timecounter = self._timecounter + dTime
		if self._timecounter > 1 then
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:ShowCommonItemInfo(self._cfg["item" .. self._num + 1])
			end, 1)
			self._falg = false
			self._timecounter = 0
		end
	end
end

function wnd_debrisRecycle:refresh(kind, cfg, log)
	self._cfg = cfg
	self._dayTimes = i3k_db_debrisRecycle_times[kind].dayTimes
	self._id = cfg.debrisId
	if not log[kind] then
		self._leftTimes = self._dayTimes
	else
	    self._leftTimes = self._dayTimes - log[kind]
	end
	local widgets = self._layout.vars
    widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._id))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._id, g_i3k_game_context:IsFemaleRole()))
	widgets.item_count:setText("X" .. self._cfg.debrisNum)
	widgets.coin_cost:setText(self._cfg.coinNum)
	self:setItems()
	self:showLeftTimes()
	--self:onChoose(1)         --默认选择第一个物品
end

--设置可以转化的物品
function wnd_debrisRecycle:setItems()
	local scroll = self._layout.vars.itemScroll
	scroll:removeAllChildren()
	for i = 1, 3 do
		local widget = require("ui/widgets/djsht")()
		if self._cfg["item" .. i] ~= 0 and self._cfg["count" .. i] ~= 0 then
			 widget.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._cfg["item" .. i]))
	         widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._cfg["item" .. i], g_i3k_game_context:IsFemaleRole()))
	         widget.vars.item_count:setText("X" .. self._cfg["count" .. i])
			 widget.vars.light_icon:hide()
			if self._cfg["item" .. i] < 0 then
				widget.vars.lock:hide()
			end
			 widget.vars.choose_btn:onTouchEvent(self, self.onChoose, i)
			 scroll:addItem(widget)
		end
	end
end

--点击转换
function wnd_debrisRecycle:onRecycle()
	if not (self._num and self._selected) then
		g_i3k_ui_mgr:PopupTipMessage("请选择一件兑换物品")
	elseif  self._leftTimes <= 0 then  
		 g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16134))                                          
    elseif self._cfg.coinNum > g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_COIN) then
	        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16132))
	elseif self._cfg.debrisNum > g_i3k_game_context:GetCommonItemCanUseCount(self._id) then                                          
	        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16133))               
	else	
	    local tbl = {order = self._cfg.order, itemOrder = self._num, itemId = self._id, itemCount = self._cfg.debrisNum, coinCost = self._cfg.coinNum}
		if g_i3k_game_context:IsExcNeedShowTip(g_DEBRIS_RECYCLE_TYPE) then
			g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
			g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_DEBRIS_RECYCLE_TYPE, tbl)
		else 	
	       i3k_sbean.debrisRecycle_req(self._cfg.order, self._num, self._id, self._cfg.debrisNum, self._cfg.coinNum)
		end
	end
end

--选择物品
function wnd_debrisRecycle:onChoose(sender, eventType, num)
	if eventType == ccui.TouchEventType.began then
		self._num = num - 1
		self._flag = true
	elseif eventType == ccui.TouchEventType.moved then
		self._flag = false
		self._timecounter = 0
	elseif eventType == ccui.TouchEventType.ended then
		self:updateBtn(num)
		self._selected = {{id = self._cfg["item" .. num], count = self._cfg["count" .. num]}}
		self._flag = false
		self._timecounter = 0
	end
end

--更新按钮状态
function wnd_debrisRecycle:updateBtn(num)
	local allItems = self._layout.vars.itemScroll:getAllChildren()
	for k, v in ipairs(allItems) do
		if k == num then
			allItems[k].vars.light_icon:show()
		else
		    allItems[k].vars.light_icon:hide()
		end
	end
end

--显示得到的物品
function wnd_debrisRecycle:showGetItem()
	g_i3k_ui_mgr:ShowGainItemInfo(self._selected)
end

--显示剩余次数
function wnd_debrisRecycle:showLeftTimes()
	local widgets = self._layout.vars
	widgets.dayLeftTimes:setText(string.format("今日剩余次数：%s/%s", self._leftTimes, self._dayTimes))
end

--更新剩余次数
function wnd_debrisRecycle:updateLeftTimes()
	self._leftTimes = self._leftTimes - 1
end

function wnd_create(layout)
	local wnd =wnd_debrisRecycle.new()
	wnd:create(layout)
	return wnd
end
