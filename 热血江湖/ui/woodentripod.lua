-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_woodenTripod = i3k_class("wnd_woodenTripod", ui.wnd_base)

local WT_WIDGET = "ui/widgets/shenmudingt"
local RowitemCount = 4

function wnd_woodenTripod:ctor()
	self._selectItem = {id = nil, count = 0}
	self._addFlag = false
	self._minusFlag = false
	self._refineFlag = false
	self._timecounter = 0
	self._refineTime = 0
end

function wnd_woodenTripod:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.refine_btn:onClick(self, self.itemRefine)
	widgets.help_btn:onClick(self, self.showHelp)
	widgets.buy_times:onClick(self, self.buyTimes)
	widgets.tips_btn:onClick(self, self.itemInfo)
	widgets.ding_model:setSprite(i3k_db_models[1306].path)
	widgets.ding_model:setSprSize(i3k_db_models[1306].uiscale)
	--widgets.ding_model:setRotation(2)
	widgets.ding_model:playAction("stand")
end

--显示可以炼化的物品
function wnd_woodenTripod:showItems()
	local scroll = self._layout.vars.item_scroll
	scroll:removeAllChildren()
	local item = self:getAllId()
	local children = scroll:addChildWithCount(WT_WIDGET, RowitemCount, 40)
	for i, v in ipairs(children) do
		if i <= #item then
			v.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item[i]))
			v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item[i], g_i3k_game_context:IsFemaleRole()))
			v.vars.item_count:setText("X" .. g_i3k_game_context:GetCommonItemCanUseCount(item[i]))
			v.vars.gray_icon:hide()
			v.vars.add_btn:onTouchEvent(self, self.putInItem, item[i])
			v.vars.reduce_btn:onTouchEvent(self, self.reduceItem, item[i])
			v.vars.reduce_btn:hide()
		else
		    v.vars.item_count:hide()
			v.vars.reduce_btn:hide()
		end
	end
end

function wnd_woodenTripod:onUpdate(dTime)
	if self._addFlag then
		self._timecounter = self._timecounter + dTime
		if self._timecounter > 0.5 then
			if self._selectItem.id then
				self._selectItem.count = self:getLimitNum()[self._selectItem.id]
			end
			self:showSelectItem()
			self:showSuccessRate()
			self:itemCanClick()
		end
	end
	
	if self._minusFlag then
		self._timecounter = self._timecounter + dTime
		if self._timecounter > 0.5 then
			self._selectItem.count = 0
			self._selectItem.id = nil
			self:showSelectItem()
			self:showSuccessRate()
			self:itemCanClick()
		end
	end
	
	if self._refineFlag then
		self._refineTime = self._refineTime + dTime
		if self._refineTime > 1 then
			i3k_sbean.woodenTripodRefine(self._selectItem.id, self._selectItem.count)
			self._refineFlag = false
			self._refineTime = 0
		end
	end
end

function wnd_woodenTripod:refresh(dayUsedTimes, dayBuyTimes)
	self._leftTimes = (dayBuyTimes + i3k_db_woodenTripod_cfg.dayTimes) - dayUsedTimes
	self._leftBuyTimes = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].woodenTripodBuyTimes - dayBuyTimes
	--self:getAllId()
	--self:getLimitNum()
	self:refreshUI()
end

function wnd_woodenTripod:refreshUI()
	self._selectItem.count = 0
	self._selectItem.id = nil
	self._layout.vars.tips_btn:enable()
	self:showItems()
	self:showSelectItem()
	self:showSuccessRate()
	self:showLeftTimes()
	self:btnShowOrHide(self._leftTimes)
end

--炼化
function wnd_woodenTripod:itemRefine(sender)
	if not self._selectItem.id then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3202))
	elseif self._leftTimes <= 0 then
	       g_i3k_ui_mgr:PopupTipMessage("次数不足")
	elseif not g_i3k_game_context:IsBagEnough({[i3k_db_woodenTripod[self._selectItem.id].getId] = 1}) then
	       g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3204))
	else
	    --self._layout.vars.ding_model:pushActionList("lianhua", 1)
	    --self._layout.vars.ding_model:pushActionList("stand", -1)
	    --self._layout.vars.ding_model:playActionList()
		self._layout.anis.c_lx.play()
		self:btnShowOrHide(0) 
		self._layout.vars.tips_btn:disable()                                      --播放模型动作期间令物品按钮无法点击
		self._refineFlag = true
	    --self.co1 = g_i3k_coroutine_mgr:StartCoroutine(function()
			    --g_i3k_coroutine_mgr.WaitForSeconds(4) --延时
			    --i3k_sbean.woodenTripodRefine(self._selectItem.id, self._selectItem.count)
			   -- g_i3k_coroutine_mgr:StopCoroutine(self.co1)
			    --self.co1 = nil
		   -- end)
	end
end

--加物品
function wnd_woodenTripod:putInItem(sender, eventType, id)
	if eventType == ccui.TouchEventType.began then
		if self._selectItem.count < self:getLimitNum()[id] then
			self._addFlag = true
			self._selectItem.id = id
			self._selectItem.count = self._selectItem.count + 1
			self:showSelectItem()
			self:showSuccessRate()
			self:itemCanClick()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3203))
		end
	elseif eventType == ccui.TouchEventType.canceled then
		self._addFlag = false
		self._timecounter = 0
	elseif eventType == ccui.TouchEventType.ended then
	    self._addFlag = false
		self._timecounter = 0    
	end
end

--显示帮助
function wnd_woodenTripod:showHelp()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(3200))
end

--显示被选物品以及可得到物品的信息
function wnd_woodenTripod:showSelectItem()
	if not self._selectItem.id then
		self._layout.vars.select_count:hide()
		self._layout.vars.select_bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
		self._layout.vars.select_icon:hide()
		self._layout.vars.get_name:hide()
	else 
	    self._layout.vars.select_count:show()
		self._layout.vars.select_icon:show()
		self._layout.vars.get_name:show()
	    self._layout.vars.select_count:setText("X" .. self._selectItem.count)
		self._layout.vars.select_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._selectItem.id))
		self._layout.vars.select_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._selectItem.id, g_i3k_game_context:IsFemaleRole()))
		self._layout.vars.get_name:setText(i3k_get_string(3206, i3k_db_woodenTripod[self._selectItem.id].getName))
		self._layout.vars.get_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(i3k_db_woodenTripod[self._selectItem.id].getId)))
	end
end

--减物品
function wnd_woodenTripod:reduceItem(sender, eventType, id)
	if eventType == ccui.TouchEventType.began then
		if self._selectItem.count > 0 then
			self._minusFlag = true
			self._selectItem.count = self._selectItem.count - 1
			if self._selectItem.count == 0 then
				self._selectItem.id = nil
			end
			self:showSelectItem()
			self:showSuccessRate()
			self:itemCanClick()
		end
	elseif eventType == ccui.TouchEventType.canceled then
		self._minusFlag = false
		self._timecounter = 0
	elseif eventType == ccui.TouchEventType.ended then
	    self._minusFlag = false
		self._timecounter = 0    
	end
end

--获取物品最大可用数量
function wnd_woodenTripod:getLimitNum()
	local limitNums = {}
	for i, v in pairs(i3k_db_woodenTripod) do
		if g_i3k_game_context:GetCommonItemCanUseCount(i) > 0 then
			limitNums[i] = math.min(#i3k_db_woodenTripod[i].successRate, g_i3k_game_context:GetCommonItemCanUseCount(i))
		end
	end
	return limitNums
end

--获取背包内可炼化物品的ID
function wnd_woodenTripod:getAllId()
	local allId = {}
	for i, v in pairs(i3k_db_woodenTripod) do
		if g_i3k_game_context:GetCommonItemCanUseCount(i) > 0 then
			table.insert(allId, i)
		end
	end
	table.sort(allId)
	return allId
end

--控制物品是否可点击
function wnd_woodenTripod:itemCanClick()
	local children = self._layout.vars.item_scroll:getAllChildren()
	if self._selectItem.id then
		local item = self:getAllId()
		for i, v in ipairs(children) do
			if item[i] == self._selectItem.id then
				v.vars.gray_icon:hide()
				v.vars.add_btn:enable()
				v.vars.reduce_btn:show()
			else
				v.vars.gray_icon:show()
				v.vars.add_btn:disable()
				v.vars.reduce_btn:hide()
			end
	    end
	else
	    for i, v in ipairs(children) do
			v.vars.gray_icon:hide()
			v.vars.add_btn:enable()
			v.vars.reduce_btn:hide()
	    end
	end
end

--显示成功率
function wnd_woodenTripod:showSuccessRate()
	local widgets = self._layout.vars
	if self._selectItem.id then
		widgets.rate_value:setText(i3k_db_woodenTripod[self._selectItem.id].successRate[self._selectItem.count]/100 .."%")
		widgets.rate_bar:setPercent(i3k_db_woodenTripod[self._selectItem.id].successRate[self._selectItem.count]/100)
	else
	    widgets.rate_value:setText(0 .."%")
		widgets.rate_bar:setPercent(0)
	end
end

--显示剩余炼化次数
function wnd_woodenTripod:showLeftTimes()
	self._layout.vars.left_times:setText("剩余次数："..self._leftTimes)
	if self._leftTimes > 0 then
		self._layout.vars.buy_times:hide()  --控制购买次数按钮的显隐
	else
	    self._layout.vars.buy_times:show()
	end
end

--购买次数
function wnd_woodenTripod:buyTimes(sender)
	if self._leftBuyTimes > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_WoodenTripodBuyTimes)
	    g_i3k_ui_mgr:RefreshUI(eUIID_WoodenTripodBuyTimes, self._leftBuyTimes)	
	elseif g_i3k_game_context:GetVipLevel() < 11 then
	       g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3209))
	else
	    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3207))
	end
end

--更新剩余可用次数
function wnd_woodenTripod:updateLeftTimes(num)
	self._leftTimes = self._leftTimes - num
end

--更新剩余购买次数
function wnd_woodenTripod:updateLeftBuyTimes(num)
	self._leftBuyTimes = self._leftBuyTimes - num
end

--控制炼化及物品按钮是否置灰
function wnd_woodenTripod:btnShowOrHide(leftTimes)
	if leftTimes <= 0 then
		for i, v in ipairs(self._layout.vars.item_scroll:getAllChildren()) do
			v.vars.gray_icon:show()
			v.vars.add_btn:disable()
			v.vars.reduce_btn:disable()
		end
	    self._layout.vars.refine_btn:disableWithChildren()
	else
	    for i, v in ipairs(self._layout.vars.item_scroll:getAllChildren()) do
			v.vars.gray_icon:hide()
			v.vars.add_btn:enable()
			v.vars.reduce_btn:enable()
		end
	    self._layout.vars.refine_btn:enableWithChildren()
	end
end

--清理协程
--function wnd_woodenTripod:onHide()
--	if self.co1 then
--		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
--		self.co1 = nil
--	end
--end

function wnd_woodenTripod:itemInfo(sender)
	if self._selectItem.id then
		g_i3k_ui_mgr:ShowCommonItemInfo(self._selectItem.id)
	end
end

function wnd_create(layout)
	local wnd = wnd_woodenTripod.new()
	wnd:create(layout)
	return wnd
end
