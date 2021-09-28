module(..., package.seeall)

local require = require;

local ui = require("ui/base");


wnd_sweepActivity = i3k_class("wnd_sweepActivity", ui.wnd_base)

local SWEEPITEM = "ui/widgets/shiliansaodang2t"
local CONSUME_ITEM = "ui/widgets/shiliansaodang2t2"
local CHOOESE_TIMES = "ui/widgets/shiliansaodang2t3"
local WEEPINGOT = i3k_db_common.wipe.ingot
local f_redWordColor	= "FFFF0000"
local f_greenWordColor	= "FF029133"
local f_nomalColor = "FF966856"

function wnd_sweepActivity:ctor()
	self._sweepItems = {}
	self._allCoin = 0
	self._allVit = 0
	self._record = {}
	self._refreshFlag = false
	self._uis = {}
	self._dataMap = {} -- k :mapId v data
	self._buyTimesNeedDiamond = i3k_db_common.activity.buyTimesNeedDiamond
end

function wnd_sweepActivity:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.sureBtn:onClick(self, self.onSweepBtUI)
	widgets.allFanPaiBtn:onClick(self, self.onAllFanPaiBtnClick)
	widgets.allSaoDangBtn:onClick(self, self.onAllSaoDangBtnClick)
	widgets.mask:onTouchEvent(self, function() widgets.scroll2_root:hide() end)
	widgets.allSaoDangTxt:setText("扫荡0次")
	widgets.allFanPaiFlag:hide()
	widgets.scroll2_root:hide()
end

function wnd_sweepActivity:refresh(sweepTable)
	self._sweepTable = sweepTable or {}
	self:SetConsumeScrollInfo()
	self:SetScrollInfo(sweepTable)
	self:UpdateAllScrollInfo()
end

function wnd_sweepActivity:SetScrollInfo(sweepTable)
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	self._uis = {}
	self._record = {}
	self._dataMap = {}
	for i, v in ipairs(self._sweepTable) do
		local info = sweepTable[i]
		local sweep = require(SWEEPITEM)()
		local vars = sweep.vars
		vars.name:setText(info.data.desc)
		vars.extra_btn:onClick(self, self.onItemExtraBtnClick, info)
		vars.selectTimesBtn:onClick(self, self.onSelectTimesBtnClick, info)
		widgets.scroll:addItem(sweep)
		self._uis[info.data.id] = vars
		self._record[info.data.id] = {times = 0, cost = 0, isExtra = false}
		self._dataMap[info.data.id] = info
	end
end

function wnd_sweepActivity:SetConsumeScrollInfo()
	local widgets = self._layout.vars
	widgets.consumeScroll:removeAllChildren()
	local coin = require(CONSUME_ITEM)()
	local vit = require(CONSUME_ITEM)()
	self._coinNum = coin.vars.value
	self._vitNum = vit.vars.value
	vit.vars.icon:setImage("tb#tl")--体力
	vit.vars.suo:hide()
	widgets.consumeScroll:addItem(coin)
	widgets.consumeScroll:addItem(vit)
	self:refreshVitAndCoin()
end

function wnd_sweepActivity:UpdateOneScrollInfo(mapId, times, isExtra)
	local ui = self._uis[mapId]
	local data = self._dataMap[mapId]
	local record = self._record[mapId]
	if times then
		record.times = math.min(times, data.reTimes)
		if record.times == 0 then
			record.isExtra = false
		end
	end
	if isExtra ~= nil and record.times > 0 then
		record.isExtra = isExtra
	end
	ui.flag:setVisible(record.isExtra)
	ui.sweepCount:setText(string.format("扫荡%s次", record.times))
end

function wnd_sweepActivity:UpdateAllScrollInfo(times, isExtra)
	for k,v in pairs(self._uis) do
		self:UpdateOneScrollInfo(k, times, isExtra)
	end
	self:refreshVitAndCoin()
end

function wnd_sweepActivity:onAllFanPaiBtnClick(sender)
	local widgets = self._layout.vars
	local isAllFanPai = widgets.allFanPaiFlag:isVisible()
	self:UpdateAllScrollInfo(nil, not isAllFanPai)
	widgets.allFanPaiFlag:setVisible(not isAllFanPai)
	self:refreshVitAndCoin()
end

function wnd_sweepActivity:onAllSaoDangBtnClick(sender)
	local maxTimes = 0
	for k,v in pairs(self._dataMap) do
		maxTimes = math.max(maxTimes, v.reTimes)
	end
	self:OpenChooseTimesPannel(maxTimes, function(index)
		self:UpdateAllScrollInfo(index, nil)
		self._layout.vars.allSaoDangTxt:setText(string.format("扫荡%s次", index))
	end, sender)
end

function wnd_sweepActivity:onItemExtraBtnClick(sender, info)
	local record = self._record[info.data.id]
	if record.times > 0 then
		self:UpdateOneScrollInfo(info.data.id, nil, not record.isExtra)
		self:refreshVitAndCoin()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17229))
	end
end

function wnd_sweepActivity:onSelectTimesBtnClick(sender, info)
	self:OpenChooseTimesPannel(info.reTimes, function(index)
		if index <= info.reTimes then
			self:UpdateOneScrollInfo(info.data.id, index, nil)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17228))
		end
	end, sender)
end

function wnd_sweepActivity:onChooseTimesOnClick(sender, data)
	data.callback(data.index)
	self._layout.vars.scroll2_root:hide()
	self:refreshVitAndCoin()
end

function wnd_sweepActivity:OpenChooseTimesPannel(count, callback, sender)
	local widgets = self._layout.vars
	widgets.scroll2_root:show()
	widgets.scroll2:removeAllChildren()
	widgets.scroll2:setSizePercent(1,math.min((count+1)/4, 5/4))
	widgets.scroll2_bg:setSizePercent(1, math.min((count+1)/4, 5/4))
	local scrollX = widgets.scroll2:getPositionX()
	local scrollSize = widgets.scroll:getContentSize()
	local scrollPosY = widgets.scroll:getPositionY()
	local scroll2Size = widgets.scroll2:getContentSize()
	local itemSize = sender:getParent():getContentSize()
	local sectPos = sender:getPosition()
	local btnPos = sender:getParent():getParent():convertToWorldSpace(sectPos)
	local y = btnPos.y - scrollSize.height - scroll2Size.height / 2 - itemSize.height
	if y < (scrollPosY - scrollSize.height) then--pannel顶部在scroll下面
		y = y + scroll2Size.height + itemSize.height
	end
	widgets.scroll2_bg:setPosition(scrollX, y)
	widgets.scroll2:setPosition(scrollX, y)
	for i = 0, count do
		local ui = require(CHOOESE_TIMES)()
		ui.vars.txt:setText(string.format("扫荡%d次", i))
		ui.vars.btn:onClick(self, self.onChooseTimesOnClick, {callback = callback, index = i})
		widgets.scroll2:addItem(ui)
	end
end

function wnd_sweepActivity:updateDiamond()
	self._coinNum:setText(self._allCoin)
	local totalDiamond =  g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND) 
	
	if self._allCoin == 0 then
		self._coinNum:setTextColor(f_nomalColor)
	elseif self._allCoin <= totalDiamond then
		self._coinNum:setTextColor(f_greenWordColor)
	else
		self._coinNum:setTextColor(f_redWordColor)
	end
end

function wnd_sweepActivity:updateVit()
	self._vitNum:setText(self._allVit)
	local totalvit = g_i3k_game_context:GetVit()
	
	if self._allVit == 0 then
		self._vitNum:setTextColor(f_nomalColor)
	elseif self._allVit <= totalvit then
		self._vitNum:setTextColor(f_greenWordColor)
	else
		self._vitNum:setTextColor(f_redWordColor)
	end
end

function wnd_sweepActivity:refreshVitAndCoin()--重新计算
	local coin, vit = 0, 0
	for k,v in pairs(self._uis) do
		local tmpCoin, tmpVit, tmpBuyTimes = self:getOneCostAndVitAndBuyTimes(k)
		self._record[k].buyTimes = tmpBuyTimes
		self._record[k].cost = tmpCoin
		coin = coin + tmpCoin
		vit = vit + tmpVit
	end
	self._allVit = vit
	self._allCoin = coin
	self:updateVit()
	self:updateDiamond()
end

function wnd_sweepActivity:getOneCostAndVitAndBuyTimes(mapId)
	local record = self._record[mapId]
	local data = self._dataMap[mapId].data
	local groupId = data.groupId
	local hadBuyTimes = g_i3k_game_context:getActDayBuyTimes(groupId) -- 已经购买的次数
	local enterTimes = g_i3k_game_context:getActivityDayEnterTime(groupId) or 0
	local itemAddTimes = g_i3k_game_context:getActDayItemAddTimes()
	local freeTimes = i3k_db_activity[groupId].times - enterTimes + itemAddTimes-- 总免费次数 - 已经进的次数 = 剩余免费次数
	local needVit = record.times * data.needTili
	local extraCost = record.isExtra and WEEPINGOT * record.times or 0
	if record.times <= freeTimes or record.times <= freeTimes + hadBuyTimes then
		return 0 + extraCost, needVit, 0
	else
		local cost = 0 --花费的金币数量 1      0    2
		local needPayTimes = record.times - freeTimes - hadBuyTimes --需要额外购买的次数
		
		if needPayTimes > 1 then
			for i = 1, needPayTimes do
				local need = self._buyTimesNeedDiamond[hadBuyTimes + i] or 0
				cost = cost + need
			end
		else
			local needCount = hadBuyTimes + needPayTimes
			cost = self._buyTimesNeedDiamond[needCount] or 0
		end
		needPayTimes = math.max(0, needPayTimes)
		return cost + extraCost, needVit, needPayTimes
		
	end
end

function wnd_sweepActivity:sendMessage()
	
	local fun = function(ok)
		if ok then
			local tb = {}
	
			for k, v in pairs(self._record) do
				if v.times ~= 0 then
					local bean = i3k_sbean.ActivitySweepInfo.new()
					bean.mapId = k
					bean.times = v.times
					bean.extraCard = v.isExtra and 1 or 0
					table.insert(tb, bean)
				end
			end
			i3k_sbean.activity_instance_sweep_sync(tb, self._record)
		end
	end
	g_i3k_game_context:CheckJudgeEmailIsFull(fun)
end

function wnd_sweepActivity:Check()
	local canSaoDang = true
	for k, v in pairs(self._dataMap) do
		if v.reTimes == 0 then
			canSaoDang = false
			break
		end
	end
	if not canSaoDang then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17230))
		return false
	end
	local times = 0
	for k, v in pairs(self._record) do
		times = times + v.times
	end
	if times == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17231))
		return false
	else
		local wipeCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_common.wipe.itemid)	
		if wipeCount < times then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(64))
			return false
		end
	end
	return true
end

function wnd_sweepActivity:onSweepBtUI()
	if self._refreshFlag then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17238))
		g_i3k_ui_mgr:CloseUI(eUIID_sweepActivity)
		return
	end

	if not g_i3k_db.i3k_db_check_now_activity_is_open() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17236))
			return
	end

	if not self:Check() then
		return
	end

	local vit = g_i3k_game_context:GetVit()
	if vit < self._allVit then
		g_i3k_logic:OpenBuyVitUI(true)
		return
	end

	local totalDiamond =  g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND)
	if totalDiamond < self._allCoin then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17232))
		return
	end

	if self._allCoin == 0 then
		self:sendMessage()
	else
		g_i3k_ui_mgr:ShowTopCustomMessageBox2("确定", "取消", i3k_get_string(17233, self._allCoin),
		function(retry)
			if retry then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_sweepActivity, "sendMessage")
			end
		end)
	end
end

function wnd_sweepActivity:refreshSweepCountFlag()
	self._refreshFlag = true
end

function wnd_create(layout, ...)
	local wnd = wnd_sweepActivity.new();
	wnd:create(layout, ...);
	return wnd;
end

