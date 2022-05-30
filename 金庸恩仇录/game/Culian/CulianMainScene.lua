local ZORDER = 100
local seed = 1
require("game.Biwu.BiwuFuc")
require("utility.richtext.richText")
local commonRes = {
progressNoneBng = "#culian_progress_buttom.png",
progressFullBng = "#culian_progress_full.png"
}
local data_item_item = require("data.data_item_item")
local data_equipquench_equipquench = require("data.data_equipquench_equipquench")
local data_quenchcrit_quenchcrit = require("data.data_quenchcrit_quenchcrit")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")


local BaseScene = require("game.BaseScene")
local CulianMainScene = class("CulianMainScene", BaseScene)

local timeDelay = 1
local timeCount = 0
local timeCuLian = 0
local timeBaoJI = 0
local CULIAN_STATE = {
CLICK_SINGLE = 1,
CLICK_CONTINUE = 2,
CLICK_SIGLEKEYUP = 3,
CLICK_CONTINUEUP = 4,
LEVEL_UP = 5,
CLICK_NORMAL = 6
}
local CULIAN_NOWSTAT = CULIAN_STATE.CLICK_NORMAL

function CulianMainScene:ctor(param)
	
	CulianMainScene.super.ctor(self, {
	bgImage = "ui_common/common_bg.png"
	})
	
	self:setUpBottomView()
	self._index = param._index
	self._objId = param._objId
	self._pos = param._pos
	self._rootnode.starBg:setZOrder(ZORDER + 100)
	self._rootnode.name_bngg:setZOrder(ZORDER + 100)
	local cuLianNode = display.newNode()
	
	local culianDis = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@RefinementGive"),
	size = 20,
	color = FONT_COLOR.GREEN_1,
	align = ui.TEXT_ALIGN_CENTER,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy
	})
	culianDis:align(display.LEFT_CENTER, 0, 0)
	cuLianNode:addChild(culianDis)
	
	local iconSp = display.newSprite("#culian_icon.png")
	iconSp:align(display.LEFT_CENTER, culianDis:getContentSize().width, 0)
	cuLianNode:addChild(iconSp)
	
	local cost_quench = ui.newTTFLabelWithShadow({
	text = "8",
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.YELLOW,
	shadowColor = FONT_COLOR.BLACK,
	})
	cost_quench:align(display.LEFT_CENTER, iconSp:getPositionX() + iconSp:getContentSize().width, 0)
	cuLianNode:addChild(cost_quench)
	
	cuLianNode:align(display.LEFT_CENTER, display.width * 0.05, display.height * 0.34)
	self:addChild(cuLianNode, ZORDER + 1)
	
	--消耗银币	 九-零 -一-起 玩-w-w-w-.9-0 -1-7 -5-.-com
	local cost_sivier = ui.newTTFLabelWithShadow({
	text = "1000",
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	local icon_size = self._rootnode.server_icon:getContentSize()
	cost_sivier:align(display.LEFT_CENTER, icon_size.width, icon_size.height / 2)
	cost_sivier:addTo(self._rootnode.server_icon)
	
	self._culianHasLabel = ui.newTTFLabelWithShadow({
	text = "0",
	size = 20,
	align = ui.TEXT_ALIGN_CENTE,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.YELLOW,
	shadowColor = FONT_COLOR.BLACK,
	})
	self._culianHasLabel:setPosition(display.width * 0.6, display.height * 0.28)
	self:addChild(self._culianHasLabel)
	self._culianHasLabel:setZOrder(ZORDER + 1000)
	
	local htmlText = "<font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s</font>"
	local dis = common:getLanguageString("@RefinementTxt")
	local infoNode_y = 0.135
	local infoNode = getRichText(string.format(htmlText, dis), display.width * 0.9 - 30)
	infoNode:setPosition((display.width - infoNode:getContentSize().width) / 2, display.height * infoNode_y)
	self:addChild(infoNode, ZORDER + 1)
	local progress = display.newSprite(commonRes.progressNoneBng)
	local fill = display.newProgressTimer(commonRes.progressFullBng, display.PROGRESS_TIMER_BAR)
	fill:setMidpoint(cc.p(0, 0.5))
	fill:setBarChangeRate(cc.p(1, 0))
	fill:setPosition(progress:getContentSize().width * 0.5, progress:getContentSize().height * 0.5)
	progress:addChild(fill)
	progress:setPosition(display.cx, display.height * 0.4)
	fill:setPercentage(0)
	progress:setAnchorPoint(cc.p(0.5, 1))
	self:addChild(progress, ZORDER + 1)
	
	local progressNum = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@RefinementValue1"),
	size = 18,
	align = ui.TEXT_ALIGN_CENTE,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.WHITE,
	outlineColor = FONT_COLOR.BLACK,
	})
	progressNum:align(display.CENTER, progress:getContentSize().width/2, progress:getContentSize().height/2)
	progress:addChild(progressNum)
	
	self.oneNum = ui.newBMFontLabel({
	text = "1",
	font = "fonts/font_number_yellow.fnt"
	})
	self.tenNum = ui.newBMFontLabel({
	text = "2",
	font = "fonts/font_number_yellow.fnt"
	})
	self.oneNum:setPosition(self._rootnode.one_start:getContentSize().width + 15, 15)
	self.tenNum:setPosition(self._rootnode.ten_start:getContentSize().width + 15, 15)
	self.oneNum:setScale(0.8)
	self.tenNum:setScale(0.8)
	self._rootnode.one_start:addChild(self.oneNum)
	self._rootnode.ten_start:addChild(self.tenNum)
	
	for index = 1, 4 do
		local item = self._rootnode["tab" .. index]
		item:setZOrder(4 - index)
		
		item:addHandleOfControlEvent(function()
			item:setZOrder(10)
			self:pageSelect(index)
		end,
		CCControlEventTouchUpInside)
	end
	self._rootnode.returnBtn:addHandleOfControlEvent(function(sender, eventName)
		if false then
			self:showTipsPopup(function()
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
				BottomBtnEvent.extraCallBack = nil
				self:onClose()
			end,
			function()
				dump("no click")
			end)
			return
		else
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
			BottomBtnEvent.extraCallBack = nil
			self:onClose()
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.disBtn:addHandleOfControlEvent(function(sender, eventName)
		local layer = require("game.SplitStove.SplitDescLayer").new(6)
		CCDirector:sharedDirector():getRunningScene():addChild(layer, 100000)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.start_btn:setVisible(false)
	
	local preBtn = display.newSprite("#culian_btn_start.png")
	preBtn:setPosition(cc.p(display.cx, display.height * 0.3))
	self._rootnode.server_icon:setPositionY(preBtn:getPositionY() - 200)
	self:addChild(preBtn, ZORDER + 10)
	--[[
	local preBtn = ResMgr.newNormalButton({	
		scaleBegan = 0.9,
		sprite = "#culian_btn_start.png"
	})
	]]
	self._rootnode.item_icon:setPositionY(display.height * 0.53)
	self._rootnode.item_icon:setScale(0.8)
	self._itemIcon = self._rootnode.item_icon
	self._priceQuench = cost_quench
	self._priceSivier = cost_sivier
	self._progressFill = fill
	self._progressNum = progressNum
	self._commitBtn = preBtn
	self._culianNode = cuLianNode
	local function func()
		print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~: "..self._pos)
		self:pageSelect(self._pos or 1)
		if self._data.cls == data_equipquench_equipquench[1].limit then
			self._culianNode:setVisible(false)
			self._culianHasLabel:setVisible(false)
			self._rootnode.server_icon:setVisible(false)
			self._commitBtn:setTouchEnabled(false)
		end
	end
	self:getBaseData(func)
	local function clearTimer()
		if self._schedulerlong then
			self._schedulerlong.unscheduleGlobal(self._schedulelong)
			self._schedulerlong = nil
			CLICKDOWN = false
		end
	end
	local function sigleUpLogic()
		CULIAN_NOWSTAT = CULIAN_STATE.CLICK_NORMAL
		self:confirm()
	end
	local function continueUpLogic()
		CULIAN_NOWSTAT = CULIAN_STATE.CLICK_NORMAL
		self:confirm()
	end
	local function continueClickLogic()
		if not self._schedulerlong then
			self._schedulerlong = require("framework.scheduler")
			local function countDown()
				if self:checkCostCion() then
					self:costCoinAndRefresh()
					if self:checkIsCrit(self._data) then
						timeBaoJI = 1
						clearTimer()
						CULIAN_NOWSTAT = CULIAN_STATE.LEVEL_UP
						return
					else
						timeCuLian = timeCuLian + 1
						if self:checkLevelUp() then
							CULIAN_NOWSTAT = CULIAN_STATE.LEVEL_UP
							clearTimer()
						end
					end
				else
					CULIAN_NOWSTAT = CULIAN_STATE.CLICK_CONTINUEUP
					clearTimer()
				end
			end
			self._schedulelong = self._schedulerlong.scheduleGlobal(countDown, 0.1, false)
		end
	end
	local function sigleClickLogic()
		if self:checkCostCion() then
			self:costCoinAndRefresh()
			if self:checkIsCrit(self._data) then
				timeBaoJI = 1
				CULIAN_NOWSTAT = CULIAN_STATE.LEVEL_UP
				return
			else
				timeCuLian = timeCuLian + 1
				if self:checkLevelUp() then
					CULIAN_NOWSTAT = CULIAN_STATE.LEVEL_UP
				else
					CULIAN_NOWSTAT = CULIAN_STATE.CLICK_SIGLEKEYUP
				end
			end
		else
			CULIAN_NOWSTAT = CULIAN_STATE.CLICK_NORMAL
		end
	end
	local normalLogic = function()
	end
	
	local function levelUpLogic()
		self:confirm()
		CLICKDOWN = false
		local finLayer = require("game.Culian.CulianLevelUpView").new({
		data = self._data
		})
		display:getRunningScene():addChild(finLayer, 9999)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakejingjie))
		CULIAN_NOWSTAT = CULIAN_STATE.CLICK_NORMAL
		self._commitBtn:setTouchEnabled(true)
		self._commitBtn.clickEable = true
	end
	
	local function mainLogic()
		if CULIAN_NOWSTAT == CULIAN_STATE.CLICK_NORMAL then
			normalLogic()
		elseif CULIAN_NOWSTAT == CULIAN_STATE.CLICK_CONTINUE then
			continueClickLogic()
		elseif CULIAN_NOWSTAT == CULIAN_STATE.CLICK_SIGLEKEYUP then
			sigleUpLogic()
		elseif CULIAN_NOWSTAT == CULIAN_STATE.CLICK_CONTINUEUP then
			continueUpLogic()
		elseif CULIAN_NOWSTAT == CULIAN_STATE.CLICK_SINGLE then
			sigleClickLogic()
		elseif CULIAN_NOWSTAT == CULIAN_STATE.LEVEL_UP then
			levelUpLogic()
		end
		if self._data then
			if self._data.cls >= data_shangxiansheding_shangxiansheding[9].level then
				preBtn:setTouchEnabled(false)
			else
				preBtn:setTouchEnabled(true)
			end
		end
	end
	local function mainLogicSchedule()
		if not self._scheduler then
			self._scheduler = require("framework.scheduler")
			local function countDown()
				if CLICKDOWN then
					timeCount = timeCount + 0.05
					if timeCount > timeDelay and CULIAN_NOWSTAT ~= CULIAN_STATE.LEVEL_UP then
						CULIAN_NOWSTAT = CULIAN_STATE.CLICK_CONTINUE
					end
				end
				mainLogic()
				if CULIAN_NOWSTAT ~= CULIAN_STATE.CLICK_CONTINUE then
					clearTimer()
				end
			end
			self._schedule = self._scheduler.scheduleGlobal(countDown, 0.05, false)
		end
	end
	local cilckTimes = 0
	local timesSpane = 0
	local countSchedule
	function countSchedule()
		if not self._countscheduler then
			self._countscheduler = require("framework.scheduler")
			local function countDown()
				timesSpane = timesSpane + 1
				if timesSpane <= 3 then
					if cilckTimes >= 2 then
						show_tip_label(data_error_error[3600004].prompt)
						timesSpane = 0
						cilckTimes = 0
					end
				else
					timesSpane = 0
					cilckTimes = 0
				end
			end
			self._countschedule = self._countscheduler.scheduleGlobal(countDown, 1, false)
		end
	end
	
	
	
	
	
	self._clickTag = false
	addTouchListener(preBtn, function(sender, eventType)
		dump(eventType)
		if eventType == EventType.began then
			timeCount = 0
			CLICKDOWN = true
			self._clickTag = true
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			if timeCount > timeDelay then
				CULIAN_NOWSTAT = CULIAN_STATE.CLICK_CONTINUEUP
			elseif CULIAN_NOWSTAT ~= CULIAN_STATE.LEVEL_UP then
				CULIAN_NOWSTAT = CULIAN_STATE.CLICK_SINGLE
				cilckTimes = cilckTimes + 1
				countSchedule()
			end
			CLICKDOWN = false
			clearTimer()
		elseif eventType == EventType.cancel then
			clearTimer()
			CULIAN_NOWSTAT = CULIAN_STATE.CLICK_NORMAL
			CLICKDOWN = false
			sender:setScale(1)
			if timeCount > timeDelay then
				CULIAN_NOWSTAT = CULIAN_STATE.CLICK_CONTINUEUP
			end
		end
	end)
	
	
	
	
	
	
	
	mainLogicSchedule()
	
	function BottomBtnEvent.extraCallBack()
		if false then
			self:showTipsPopup(function()
				BottomBtnEvent.extraCallBack = nil
				BottomBtnEvent.reCall(BottomBtnEvent.tag)
			end,
			function()
				BottomBtnEvent.extraCallBack = nil
			end)
		else
			BottomBtnEvent.extraCallBack = nil
			BottomBtnEvent.reCall(BottomBtnEvent.tag)
		end
	end
end

function CulianMainScene:checkUnComplete()
	local tag = false
	for k, v in pairs(self._equipList) do
		if v.exp > 0 then
			tag = true
		end
	end
	return tag
end

function CulianMainScene:showTipsPopup(confirmFunc, cancelFunc)
	local tipsBox = require("game.Culian.CulianMsgBox").new({okListener = confirmFunc, noListener = cancelFunc})
	CCDirector:sharedDirector():getRunningScene():addChild(tipsBox, ZORDER * 2)
end

function CulianMainScene:onClose()
	if self._scheduler then
		self._scheduler.unscheduleGlobal(self._schedule)
		self._scheduler = nil
	end
	if self._schedulerTime then
		self._schedulerTime.unscheduleGlobal(self._scheduleTime)
		self._schedulerTime = nil
	end
	if self._schedulerlong then
		self._schedulerlong.unscheduleGlobal(self._schedulelong)
		self._schedulerlong = nil
	end
	if self._countscheduler then
		self._countscheduler.unscheduleGlobal(self._countschedule)
		self._countscheduler = nil
	end
	self:unregNotice()
	GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
end

function CulianMainScene:onExit()
	CulianMainScene.super.onExit(self)
	if self._scheduler then
		self._scheduler.unscheduleGlobal(self._schedule)
		self._scheduler = nil
	end
	if self._schedulerTime then
		self._schedulerTime.unscheduleGlobal(self._scheduleTime)
		self._schedulerTime = nil
	end
	if self._schedulerlong then
		self._schedulerlong.unscheduleGlobal(self._schedulelong)
		self._schedulerlong = nil
	end
	self:unregNotice()
end

function CulianMainScene:confirm()
	self._commitBtn:setTouchEnabled(false)
	if not self._clickTag then
		return
	end
	self._clickTag = false
	self:startCulian(timeCuLian, timeBaoJI)
end

function CulianMainScene:costCoinAndRefresh()
	self._culianNum = self._culianNum - data_equipquench_equipquench[self._pageIndex].arr_quench[self._data.cls + 1]
	game.player:setSilver(game.player:getSilver() - data_equipquench_equipquench[self._pageIndex].arr_silver[self._data.cls + 1])
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	self._data.exp = self._data.exp + data_equipquench_equipquench[self._pageIndex].arr_get_exp[self._data.cls + 1]
	self:refreshView(self._pageIndex, self._data)
end

function CulianMainScene:checkCostCion(func)
	if game.player:getSilver() < data_equipquench_equipquench[self._pageIndex].arr_silver[self._data.cls + 1] then
		show_tip_label(data_error_error[100005].prompt)
		return false
	end
	if self._culianNum < data_equipquench_equipquench[self._pageIndex].arr_quench[self._data.cls + 1] then
		show_tip_label(data_error_error[3600008].prompt)
		return false
	end
	return true
end

function CulianMainScene:checkLevelUp()
	local maxExp = data_equipquench_equipquench[self._pageIndex].arr_exp[self._data.cls + 1]
	local addExp = data_equipquench_equipquench[self._pageIndex].arr_get_exp[self._data.cls + 1]
	if maxExp <= self._data.exp then
		return true
	end
	return false
end

function CulianMainScene:rejustScreen()
	local bng = CCSprite:create("bg/biwu_bg.jpg", cc.rect(0, 0, display.width, display.width / 0.77))
	bng:setScaleY(param.size.height / display.width * 0.77)
	self:addChild(bng)
	bng:setAnchorPoint(cc.p(0, 0))
end

function CulianMainScene:getLeastData()
	for index = 1, 4 do
		if self:getDataByPos(index) then
			return index
		end
	end
	return nil
end

function CulianMainScene:getDataByPos(pos)
	for k, v in pairs(self._equipList) do
		if v.pos == pos then
			return v
		end
	end
	return nil
end

function CulianMainScene:createFonts(titleValue, valueValue, weightValue)
	local fontNode = display.newNode()
	local title = ui.newTTFLabelWithShadow({
	text = titleValue .. ":",
	size = 18,
	color = FONT_COLOR.WHITE,
	align = ui.TEXT_ALIGN_CENTER,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy
	})
	local value = ui.newTTFLabelWithShadow({
	text = math.ceil(valueValue * (1 + weightValue / 10000)),
	size = 18,
	color = FONT_COLOR.YELLOW,
	align = ui.TEXT_ALIGN_CENTER,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy
	})
	local weight = ui.newTTFLabelWithShadow({
	text = "(" .. weightValue / 100 .. "%)",
	size = 18,
	color = FONT_COLOR.GREEN_1,
	align = ui.TEXT_ALIGN_CENTER,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy
	})
	title:setPosition(0, 0)
	value:setPosition(title:getPositionX() + title:getContentSize().width, 0)
	weight:setPosition(value:getPositionX() + value:getContentSize().width, 0)
	fontNode:addChild(title)
	fontNode:addChild(value)
	fontNode:addChild(weight)
	return fontNode
end

function CulianMainScene:pageSelect(index)
	if index == self._pageIndex then
		self._rootnode["tab" .. index]:setEnabled(false)
		return
	end
	for index = 1, 4 do
		self._rootnode["tab" .. index]:setEnabled(true)
	end
	self._rootnode["tab" .. index]:setEnabled(false)
	self._progressFill:setPercentage(0)
	self._pageIndex = index
	self:refreshView(index, self:getDataByPos(index))	
	if self._data.cls >= data_shangxiansheding_shangxiansheding[9].level then
		local needExp = data_equipquench_equipquench[index].arr_exp[self._data.cls + 1]
		self._progressNum:setString(common:getLanguageString("@RefinementMax"))
		self._commitBtn:setTouchEnabled(false)
		self._progressFill:setPercentage(100)
	else
		local needExp = data_equipquench_equipquench[index].arr_exp[self._data.cls + 1]
		self._progressNum:setString(common:getLanguageString("@RefinementValue1", 0, needExp))
	end
end

function CulianMainScene:refreshView(index, data)
	self._data = data
	self._rootnode.namebng:removeAllChildren()
	local resStr = data_item_item[data.resId].icon
	self._itemIcon:setDisplayFrame(display.newSprite("equip/large/" .. resStr .. ".png"):getDisplayFrame())
	local nameColor = ResMgr.getItemNameColor(data.resId)
	if data.cls ~= 0 or not "" then
	end
	local nameLbl = ui.newTTFLabelWithShadow({
	text = data_item_item[data.resId].name .. " +" .. data.cls,
	size = 25,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	local namebng_size = self._rootnode.namebng:getContentSize()
	nameLbl:align(display.CENTER, namebng_size.width / 2, namebng_size.height/2)
	self._rootnode.namebng:addChild(nameLbl)
	
	self.oneNum:setString(data.cls)
	self.tenNum:setString(data.cls + 1)
	local level = data.cls
	local oneValue = self:getEquipAttrs(data.id, level, self._pageIndex)
	local tenValue = self:getEquipAttrs(data.id, level + 1, self._pageIndex)
	if self:getChildByTag(1) or self:getChildByTag(2) or self:getChildByTag(3) or self:getChildByTag(4) then
		for i = 1, 4 do
			self:removeChildByTag(i)
		end
	end
	for k, v in pairs(oneValue) do
		if self._data.cls ~= 0 then
			local leftDis = self:createFonts(oneValue[k].name, oneValue[k].value, oneValue[k].weight)
			leftDis:setPosition(cc.p(display.width * 0.03, k == 1 and display.height * 0.49 or display.height * 0.47))
			self:addChild(leftDis, ZORDER + 1, k)
			self._rootnode.one_start:setVisible(true)
		else
			self._rootnode.one_start:setVisible(false)
		end
	end
	for k, v in pairs(tenValue) do
		if self._data.cls ~= data_equipquench_equipquench[1].limit then
			local rightDis = self:createFonts(tenValue[k].name, tenValue[k].value, tenValue[k].weight)
			rightDis:setPosition(cc.p(display.width * 0.75, k == 1 and display.height * 0.49 or display.height * 0.47))
			self:addChild(rightDis, ZORDER + 1, k + 2)
			self._rootnode.ten_start:setVisible(true)
		else
			self._rootnode.ten_start:setVisible(false)
		end
	end
	local start = self:getEquipByID(data.id).star
	for index = 1, 5 do
		if self._rootnode["heroStar_" .. index] then
			self._rootnode["heroStar_" .. index]:setVisible(false)
		end
		if self._rootnode["heroStar_2_" .. index] then
			self._rootnode["heroStar_2_" .. index]:setVisible(false)
		end
	end
	
	if start > 5 then
		start = 5
	end
	
	for index = 1, start do
		if start % 2 ~= 0 then
			self._rootnode["heroStar_" .. index]:setVisible(true)
		else
			self._rootnode["heroStar_2_" .. index]:setVisible(true)
		end
	end
	
	if data.cls >= data_shangxiansheding_shangxiansheding[9].level then
		self._priceQuench:setString(0)
		self._priceSivier:setString(0)
		self._culianNode:setVisible(false)
		self._culianHasLabel:setVisible(false)
		self._rootnode.server_icon:setVisible(false)
		self._commitBtn:setTouchEnabled(false)
		self._progressNum:setString(common:getLanguageString("@RefinementMax"))
		self._progressFill:setPercentage(100)
		return
	else
		self._priceQuench:setString(data_equipquench_equipquench[self._pageIndex].arr_quench[level + 1])
		self._priceSivier:setString(data_equipquench_equipquench[self._pageIndex].arr_silver[level + 1])
		self._culianNode:setVisible(true)
		self._culianHasLabel:setVisible(true)
		self._rootnode.server_icon:setVisible(true)
		self._commitBtn:setTouchEnabled(true)
	end
	self._culianHasLabel:setString(self._culianNum)
	local needExp = data_equipquench_equipquench[self._pageIndex].arr_exp[level + 1]
	local percent = math.ceil(data.exp / needExp * 100)
	self._progressNum:setString(common:getLanguageString("@RefinementValue1", data.exp, needExp))
	if percent >= self._progressFill:getPercentage() then
		if not self._schedulerTime then
			self._schedulerTime = require("framework.scheduler")
			local function countDown()
				if self._progressFill:getPercentage() < percent then
					self._progressFill:setPercentage(self._progressFill:getPercentage() + 1)
					self._progressNum:setString(common:getLanguageString("@RefinementValue1", data.exp, needExp))
				elseif self._scheduleTime then
					self._schedulerTime.unscheduleGlobal(self._scheduleTime)
					self._schedulerTime = nil
				end
			end
			self._scheduleTime = self._schedulerTime.scheduleGlobal(countDown, 0.01, false)
		end
	else
		self._progressFill:setPercentage(0)
		self._progressNum:setString(common:getLanguageString("@RefinementValue1", 0, needExp))
		if self._schedulerTime then
			self._schedulerTime.unscheduleGlobal(self._scheduleTime)
			self._schedulerTime = nil
		end
	end
	if self._rootnode.bng_down:getChildByTag(116) then
		self._rootnode.bng_down:removeChildByTag(116)
	end
	local labels = {
	common:getLanguageString("@VeryLow"),
	common:getLanguageString("@General"),
	common:getLanguageString("@Higher"),
	common:getLanguageString("@VeryHigh")
	}
	local htmlText1 = "<font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#00e430”\">%s</font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font>"
	local htmlText2 = "<font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#00a8ff”\">%s</font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font>"
	local htmlText3 = "<font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#c000ff”\">%s</font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font>"
	local htmlText4 = "<font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ffa500”\">%s</font><font size=\"18\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#D49353\">%s  </font>"
	local htmlText = {
	htmlText1,
	htmlText2,
	htmlText3,
	htmlText4
	}
	local dis_01 = common:getLanguageString("@RefinemenEmpty")
	local dis_02 = labels[self:randomLevel(data)]
	local dis_03 = common:getLanguageString("@UpOrder")
	if self:getChildByTag(116) then
		self:removeChildByTag(116)
	end
	local infoNode_y = 0.17
	local infoNode = getRichText(string.format(htmlText[self:randomLevel(data)], dis_01, dis_02, dis_03), display.width * 0.9 - 30)
	infoNode:setPosition((display.width - infoNode:getContentSize().width) / 2, display.height * infoNode_y)
	self:addChild(infoNode, ZORDER + 1, 116)
end

function CulianMainScene:getEquipAttrs(id, level, pos)
	local keys = {
	"arr_hp",
	"arr_attack",
	"arr_defense",
	"arr_defenseM"
	}
	local name = {
	common:getLanguageString("@life2"),
	common:getLanguageString("@Attack2"),
	common:getLanguageString("@ThingDefense2"),
	common:getLanguageString("@LawDefense2")
	}
	local ret = {}
	if level == 0 then
		for k, v in pairs(keys) do
			if data_equipquench_equipquench[pos][v][1] ~= 0 then
				local temp = {}
				temp.name = name[k]
				temp.value = self:getEquipByID(id).base[k]
				temp.weight = 0
				table.insert(ret, temp)
			end
		end
		return ret
	end
	local maxLevel = data_shangxiansheding_shangxiansheding[9].level	
	if level > maxLevel then
		for k, v in pairs(keys) do
			if data_equipquench_equipquench[pos][v][maxLevel] ~= 0 then
				local temp = {}
				temp.name = name[k]
				temp.value = self:getEquipByID(id).base[k] * (1 + data_equipquench_equipquench[pos][v][level - 1] / 10000)
				temp.weight = 0
				table.insert(ret, temp)
			end
		end
		return ret
	end
	for k, v in pairs(keys) do
		if data_equipquench_equipquench[pos][v][level] ~= 0 then
			local temp = {}
			temp.name = name[k]
			temp.value = self:getEquipByID(id).base[k]
			temp.weight = data_equipquench_equipquench[pos][v][level]
			table.insert(ret, temp)
		end
	end
	return ret
end

function CulianMainScene:getEquipByID(id)
	for k, v in ipairs(game.player:getEquipments()) do
		if v._id == id then
			return v
		end
	end
	return nil
end

function CulianMainScene:randomLevel(data)
	local maxExp = data_equipquench_equipquench[self._pageIndex].arr_exp[data.cls + 1]
	local ret = 1
	if data.exp < maxExp * 0.25 then
		ret = 1
	elseif data.exp >= maxExp * 0.25 and data.exp < maxExp * 0.5 then
		ret = 2
	elseif data.exp >= maxExp * 0.5 and data.exp < maxExp * 0.75 then
		ret = 3
	elseif data.exp >= maxExp * 0.75 and data.exp < maxExp * 1 then
		ret = 4
	end
	return ret
end

function CulianMainScene:calculateProbability(data)
	local maxExp = data_equipquench_equipquench[self._pageIndex].arr_exp[data.cls + 1]
	local onceExp = data_equipquench_equipquench[self._pageIndex].arr_get_exp[data.cls + 1]
	local levelExp = maxExp * ((self:randomLevel(data) - 1) / 4)
	local ret = (data.exp - levelExp) / onceExp
	ret = ret * data_quenchcrit_quenchcrit[data.cls + 1]["crit_add" .. self:randomLevel(data)] / 10000 + data_quenchcrit_quenchcrit[data.cls + 1]["crit_start" .. self:randomLevel(data)] / 10000
	return ret
end

function CulianMainScene:checkIsCrit(data)
	seed = seed + 1
	local probality = self:calculateProbability(data)
	math.randomseed(os.time())
	local randoms = math.random()
	if probality > randoms then
		return true
	end
	return false
end

function CulianMainScene:setUpBottomView()
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	self:setBottomBtnEnabled(true)
	self._rootnode.bottomNode:setTouchEnabled(true)
	ResMgr.removeBefLayer()
	self:regNotice()
	local buttom = clone(self._rootnode.bottomNode)
	buttom:retain()
	self._rootnode.bottomNode:removeFromParent()
	self:addChild(buttom, ZORDER)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("lianhualu/culian_main.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, self:getBottomHeight())
	self._rootnode.bng_up:setScale(1.4)
	self._rootnode.bng_down:setScale(1.2)
	local topOffset = display.height - self._rootnode.nodeCard:getPositionY()
	local midPoint = display.height * 0.33
	local scaleRadio = (display.height - topOffset - midPoint) / self._rootnode.bng_up:getContentSize().height
	local scaleY = scaleRadio
	local scaleX = scaleY * (self._rootnode.bng_up:getContentSize().width / self._rootnode.bng_up:getContentSize().height)
	self._rootnode.bng_up:setScaleX(scaleX)
	self._rootnode.bng_up:setScaleY(scaleY)
	self._rootnode.bng_up:setAnchorPoint(cc.p(0.5, 0))
	self._rootnode.bng_up:setPositionY(midPoint - 24)
	local midPoint = display.height * 0.33
	local scaleRadio = midPoint / self._rootnode.bng_down:getContentSize().height
	local scaleY = scaleRadio
	local scaleX = scaleY * (self._rootnode.bng_down:getContentSize().width / self._rootnode.bng_down:getContentSize().height)
	self._rootnode.bng_down:setScaleX(scaleX)
	self._rootnode.bng_down:setScaleY(scaleY)
	self._rootnode.bng_down:setAnchorPoint(cc.p(0.5, 1))
	self._rootnode.bng_down:setPositionY(midPoint - 24)
	self._rootnode.divier_mid:setAnchorPoint(cc.p(0.5, 1))
	self._rootnode.divier_left:setAnchorPoint(cc.p(0, 1))
	self._rootnode.divier_right:setAnchorPoint(cc.p(1, 1))
	self._rootnode.divier_mid:setPosition(cc.p(display.cx, midPoint - 14))
	self._rootnode.divier_left:setPosition(cc.p(0, midPoint - 24 - self._rootnode.divier_left:getContentSize().height))
	self._rootnode.divier_right:setPosition(cc.p(display.width, midPoint - 24))
	local scaleY = (display.height - self:getBottomHeight() - self:getTopHeight()) / (node:getContentSize().height - 100)
	if display.width / display.height >= 0.75 then
		self._rootnode.starBg:setPositionY(self._rootnode.starBg:getPositionY() - 20)
	end
	self:addChild(node, ZORDER - 1)
end

function CulianMainScene:startCulian(qnum, cnum)
	
	local function initData(data)
		timeBaoJI = 0
		timeCuLian = 0
		self._equipList[self._pageIndex] = data.equip
		self:refreshView(self._pageIndex, data.equip)
		self._commitBtn:setTouchEnabled(true)
		self._culianNum = data.quench
		game.player:setSilver(data.sliver)
		PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	end
	
	RequestHelper.zhuangbeiculian.startCulian({
	callback = function(data)
		dump(data)
		initData(data)
	end,
	errback = function()
		self._commitBtn:setTouchEnabled(true)
	end,
	acc = game.player:getAccount(),
	order = self._index,
	pos = self._pageIndex,
	qnum = qnum,
	cnum = cnum,
	minExp = self._data.exp
	})
end

function CulianMainScene:getBaseData(func)
	local function initData(data)
		table.sort(data.equipList, function(a, b)
			return a.pos < b.pos
		end)
		self._equipList = data.equipList
		self._culianNum = data.quench
		func()
	end
	
	RequestHelper.zhuangbeiculian.getBaseInfo({
	callback = function(data)
		initData(data)
	end,
	acc = game.player:getAccount(),
	order = self._index
	})
end

return CulianMainScene