require("game.Biwu.BiwuFuc")
local radius = 130
local ratios = 0
local baseRatio = 6.283184
local data_item_item = require("data.data_item_item")

local TanbaoMainView = class("TanbaoMainView", function()
	return display.newLayer("TanbaoMainView")
end)

local boxType = {
jifen = 1,
suiji = 2,
common = 3
}

function TanbaoMainView:setUpView(param)
	self.size = param.size
	local maskBng = display.newSprite("#bng.png")
	maskBng:setAnchorPoint(cc.p(0.5, 0.5))
	maskBng:setPosition(cc.p(param.size.width / 2, param.size.height * 0.5))
	self:addChild(maskBng)
	local startTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._start) / 1000))
	local endTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._end) / 1000))
	local startTimeStr = string.split(startTimeStr, "-")
	local startTime
	startTime = startTimeStr[1] .. common:getLanguageString("@Year")
	startTime = startTime .. startTimeStr[2] .. common:getLanguageString("@Month")
	startTime = startTime .. startTimeStr[3] .. common:getLanguageString("@Day")
	local endTimeStr = string.split(endTimeStr, "-")
	local endTime
	endTime = endTimeStr[1] .. common:getLanguageString("@Year")
	endTime = endTime .. endTimeStr[2] .. common:getLanguageString("@Month")
	endTime = endTime .. endTimeStr[3] .. common:getLanguageString("@Day")
	
	--活动时间
	local timeLabeldis = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@ActivityTime", startTime, endTime),
	size = 23,
	color = cc.c3b(0, 254, 60),
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	dimensions = cc.size(470, 60),
	valign = ui.TEXT_ALIGN_CENTER
	})
	timeLabeldis:align(display.LEFT_TOP, param.size.width * 0.02, param.size.height - 10)
	self:addChild(timeLabeldis)
	
	local bottomTips = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@hs_mianfeicsyjh"),
	size = 20,
	color = cc.c3b(0, 240, 255),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	bottomTips:align(display.CENTER, self.size.width / 2, self.size.height * 0.05)
	self:addChild(bottomTips)
	
	local titleBng = display.newSprite("#huanggongtanbao.png")
	titleBng:align(display.LEFT_BOTTOM, param.size.width * 0.01, timeLabeldis:getPositionY() - timeLabeldis:getContentSize().height - 40)
	self:addChild(titleBng)
	
	local timeLabel = display.newSprite("#countdown.png")
	timeLabel:align(display.LEFT_BOTTOM, param.size.width * 0.02, titleBng:getPositionY() - 40)
	self:addChild(timeLabel)
	
	--倒计时
	self._countDownTime = math.floor(self._countDownTime / 1000)
	local nowTimeStr = self:timeFormat(self._countDownTime)
	local timeLabelCountDown = ui.newTTFLabelWithOutline({
	text = nowTimeStr,
	size = 23,
	color = cc.c3b(0, 254, 60),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	timeLabelCountDown:align(display.LEFT_CENTER, param.size.width * 0.02, timeLabel:getPositionY() - 20)
	self:addChild(timeLabelCountDown)
	
	--转盘底座
	local roteBng = display.newSprite("#zhuanpandizuo.png")
	roteBng:setPosition(cc.p(param.size.width * 0.5, param.size.height * 0.6))
	self:addChild(roteBng)
	if display.width / display.height >= 0.75 then
		roteBng:setScale(0.9)
	else
		roteBng:setScale(1)
	end
	local roteInnerBng = display.newSprite("#zhuanpanyuandi.png")
	roteInnerBng:setPosition(cc.p(roteBng:getContentSize().width / 2, roteBng:getContentSize().height / 2))
	roteBng:addChild(roteInnerBng, 1)
	
	--积分底图
	local jinfenBng = display.newSprite("#jifenbng_1.png")
	jinfenBng:align(display.RIGHT_CENTER, param.size.width, param.size.height * 0.3)
	self:addChild(jinfenBng)
	
	local jinfenTitle = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@dangqianjf"),
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	jinfenTitle:setAnchorPoint(cc.p(0, 0.5))
	jinfenTitle:setContentSize(jinfenTitle:getContentSize())
	jinfenTitle:setPosition(cc.p(jinfenBng:getContentSize().width * 0.2, jinfenBng:getContentSize().height * 0.85))
	self.jinfenTitle = jinfenTitle
	local jinfenValue = ui.newTTFLabelWithOutline({
	text = self._jifen,
	size = 20,
	color = cc.c3b(36, 255, 0),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy
	})
	jinfenValue:setAnchorPoint(cc.p(0.5, 0.5))
	jinfenValue:setContentSize(jinfenValue:getContentSize())
	jinfenValue:setPositionY(jinfenBng:getContentSize().height * 0.85)
	jinfenBng:addChild(jinfenTitle)
	jinfenBng:addChild(jinfenValue)
	self.jinfenValue = jinfenValue
	alignNodesOneByOne(jinfenTitle, jinfenValue)
	local timeTitle = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@shengyucs"),
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTE,
	font = FONTS_NAME.font_fzcy
	})
	timeTitle:setAnchorPoint(cc.p(0, 0.5))
	timeTitle:setContentSize(timeTitle:getContentSize())
	timeTitle:setPosition(cc.p(jinfenBng:getContentSize().width * 0.2, jinfenBng:getContentSize().height * 0.35))
	local timeValue = ui.newTTFLabelWithOutline({
	text = self._time,
	size = 20,
	color = cc.c3b(0, 240, 255),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	timeValue:setAnchorPoint(cc.p(0.5, 0.5))
	timeValue:setContentSize(timeValue:getContentSize())
	timeValue:setPositionY(jinfenBng:getContentSize().height * 0.35)
	jinfenBng:addChild(timeTitle)
	jinfenBng:addChild(timeValue)
	alignNodesOneByOne(timeTitle, timeValue)
	self.btnOne = display.newSprite("#tanbaoyici.png")
	self.btnOne:setAnchorPoint(cc.p(0.5, 0))
	self.btnOne:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.5, roteInnerBng:getContentSize().height * 0.55))
	roteInnerBng:addChild(self.btnOne)
	self.btnTen = display.newSprite("#tanbaoshici.png")
	self.btnTen:setAnchorPoint(cc.p(0.5, 1))
	self.btnTen:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.5, roteInnerBng:getContentSize().height * 0.44))
	roteInnerBng:addChild(self.btnTen)
	
	--免费次数
	local freeTimeLabel = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@jinrimfcs") .. self._freeTime,
	size = 20,
	color = display.COLOR_WHITE,
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	--freeTimeLabel:setAnchorPoint(cc.p(0.5, 0.5))
	--freeTimeLabel:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.15, roteInnerBng:getContentSize().height * 0.5))
	freeTimeLabel:align(display.CENTER, roteInnerBng:getContentSize().width/2, roteInnerBng:getContentSize().height/2)
	roteInnerBng:addChild(freeTimeLabel)
	local nodeGoldOne = display.newNode()
	local goldIconOne = display.newSprite("#icon_gold.png")
	goldIconOne:setPositionX(-10)
	nodeGoldOne:addChild(goldIconOne)
	local preLabelOne = ui.newTTFLabelWithOutline({
	text = self._priceOne,
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	preLabelOne:setPosition(goldIconOne:getContentSize().width, -3)
	nodeGoldOne:addChild(preLabelOne)
	nodeGoldOne:setPosition(cc.p(self.btnOne:getContentSize().width / 2, self.btnOne:getContentSize().height * 0.7))
	self.btnOne:addChild(nodeGoldOne)
	local nodeGoldTwo = display.newNode()
	local goldIconTwo = display.newSprite("#icon_gold.png")
	goldIconTwo:setPosition(-19, 3)
	nodeGoldTwo:addChild(goldIconTwo)
	local preLabelTen = ui.newTTFLabelWithOutline({
	text = self._priceTen,
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	preLabelTen:setPositionX(goldIconTwo:getContentSize().width)
	nodeGoldTwo:addChild(preLabelTen)
	nodeGoldTwo:setPosition(cc.p(self.btnOne:getContentSize().width / 2, self.btnOne:getContentSize().height * 0.3))
	self.btnTen:addChild(nodeGoldTwo)
	if self._type == 1 or self._type == 2 then
		nodeGoldOne:setVisible(false)
		nodeGoldTwo:setVisible(false)
	else
		nodeGoldOne:setVisible(true)
		nodeGoldTwo:setVisible(true)
		if self._freeTime ~= 0 then
			preLabelOne:setVisible(false)
			goldIconOne:setVisible(false)
		end
	end
	
	local function refreshFunc(type)
		freeTimeLabel:setString(common:getLanguageString("@jinrimfcs") .. self._freeTime)
		timeValue:setString(self._time)
		jinfenValue:setString(self._jifen)
		alignNodesOneByOne(jinfenTitle, jinfenValue)
		if self._freeTime ~= 0 then
			self.btnOne:setDisplayFrame(display.newSprite("#mianfei.png"):getDisplayFrame())
		else
			self.btnOne:setDisplayFrame(display.newSprite("#tanbaoyici.png"):getDisplayFrame())
		end
		if self._freeTime ~= 0 then
			preLabelOne:setVisible(false)
			goldIconOne:setVisible(false)
		else
			preLabelOne:setVisible(self._type == 3)
			goldIconOne:setVisible(self._type == 3)
		end
	end
	
	if self._freeTime ~= 0 then
		self.btnOne:setDisplayFrame(display.newSprite("#mianfei.png"):getDisplayFrame())
	end
	
	--czy
	--一次
	addTouchListener(self.btnOne, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.95)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			if self._time == 0 and self._freeTime == 0 and self._type ~= 3 then
				show_tip_label(common:getLanguageString("@tanbaocsbz"))
				return
			end
			self:tanBaoRequest(refreshFunc, 1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	
	--czy
	--十次
	addTouchListener(self.btnTen, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.95)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			if self._time + self._freeTime < 10 and self._type ~= 3 then
				show_tip_label(common:getLanguageString("@tanbaocsbz"))
				return
			end
			self:tanBaoRequest(refreshFunc, 10)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	local centerNode = display.newNode()
	centerNode:setPosition(roteBng:getContentSize().width / 2, roteBng:getContentSize().height / 2)
	roteBng:addChild(centerNode)
	self.dataNode = display.newNode()
	centerNode:addChild(self.dataNode, 2)
	
	--预览按钮
	local disBtn = display.newSprite("#shuoming.png")
	disBtn:setPosition(cc.p(param.size.width * 0.9, param.size.height * 0.9))
	self:addChild(disBtn)
	--czy
	addTouchListener(disBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			local layer = require("game.SplitStove.SplitDescLayer").new(3)
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	self._roteArrow = display.newSprite("#arraw.png")
	self._roteArrow:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.7, roteInnerBng:getContentSize().height * 0.58))
	centerNode:addChild(self._roteArrow, 3)
	self:setUpArrowPos()
	self._scheduler = require("framework.scheduler")
	self._schedulerTime = require("framework.scheduler")
	function self.countDown()
		if not self.timer or not self.isShowTanbaoMainView then
			return
		end
		self.timer = self.timer + 1
		if self.timer <= self.t1 then
			self.speed = self.speed + self.a1
		elseif self.timer > self.t1 and self.timer <= self.t1 + self.t2 then
			self.speed = self.speed - self.a2
		end
		ratios = ratios + self.speed
		if self.speed < 1.0E-5 then
			self._scheduler.unscheduleGlobal(self._schedule)
			dump(self._totalRatio)
			self.btnOne:setTouchEnabled(true)
			self.btnTen:setTouchEnabled(true)
			self:showGiftPopup(self._tanbaoGift, common:getLanguageString("@huodejl"), nil, boxType.common)
			self.shadowLayer:removeSelf()
			self.shadowLayer = nil
		end
		self:setUpArrowPos()
	end
	self:reloadData()
	local function countDown()
		if not _countDownTime or not self.isShowTanbaoMainView then
			return
		end
		self._countDownTime = self._countDownTime - 1
		if self._countDownTime <= 0 then
			self._schedulerTime.unscheduleGlobal(self._scheduleTime)
			timeLabelCountDown:setString(common:getLanguageString("@ActivityOver"))
			self.btnOne:setTouchEnabled(false)
			self.btnTen:setTouchEnabled(false)
			timeLabelCountDown:setPositionX(timeLabelCountDown:getPositionX() + 20)
			show_tip_label(common:getLanguageString("@ActivityOver"))
		else
			timeLabelCountDown:setString(self:timeFormat(self._countDownTime))
		end
	end
	self._scheduleTime = self._schedulerTime.scheduleGlobal(countDown, 1, false)
	
	--黑市按键
	--[[
	self:createBtn("ui/new_btn/ui_controlbtn14.png", common:getLanguageString("@tbheishi"), function()
		self:gotoHeiShi()
	end,
	cc.p(self:getContentSize().width * 0.7, self:getContentSize().height * 0.12))
	]]
	
	--[[
	--刷新按键
	self:createBtn("ui/new_btn/ui_controlbtn16.png", common:getLanguageString("@hs_shuaxin"), function()
		self._selectIndex = self._selectIndex + 1
		if self._selectIndex >= 5 then
			self._selectIndex = 1
		end
		CCUserDefault:sharedUserDefault():setIntegerForKey("TANBAO_IDX", self._selectIndex)
		CCUserDefault:sharedUserDefault():flush()
		self:reloadData()
	end,
	cc.p(self:getContentSize().width * 0.5, self:getContentSize().height * 0.12))
	]]
end

function TanbaoMainView:reloadData()
	--bug sepcialPos
	--dump("333333333333333333333333333333333")
	--dump(self.sepcialPos)
	--dump(self.sepcialPosGoods)
	
	self.dataNode:removeAllChildrenWithCleanup(true)
	
	for k, v in pairs(self.sepcialPos) do
		local displayItemId = self.sepcialPosGoods[v]
		self._baseItem[v].id = displayItemId
		self._baseItem[v].type = data_item_item[displayItemId].type
	end
	
	for i = 1, 10 do
		local ratios = (i - 1) * 0.1
		local x = 170 * math.sin(ratios * baseRatio)
		local y = 170 * math.cos(ratios * baseRatio)
		local item = self:createItemView(cc.p(x, y), self.dataNode, self._baseItem[i], i)
	end
end

function TanbaoMainView:createBtn(image, text, func, pos)
	local heishiBtn = display.newSprite(image)
	if pos then
		heishiBtn:setPosition(pos)
	end
	self:addChild(heishiBtn)
	addTouchListener(heishiBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.85)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if func then
				func()
			end
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	local jinfenValue = ui.newTTFLabelWithOutline({
	text = text,
	size = 24,
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	jinfenValue:setPosition(ccp(heishiBtn:getContentSize().width / 2, heishiBtn:getContentSize().height / 2))
	heishiBtn:addChild(jinfenValue)
	return heishiBtn
end

function TanbaoMainView:gotoHeiShi()
	local function cb(jifen)
		if self.jinfenValue then
			self.jinfenValue:setString(jifen)
			alignNodesOneByOne(self.jinfenTitle, self.jinfenValue)
		end
	end
	local heishiLayer = require("game.nbactivity.TanBao.HeiShiLayer").new({
	viewSize = self.size,
	callback = cb
	})
	heishiLayer:setPosition(display.cx, 0)
	self:addChild(heishiLayer, 1)
end

function TanbaoMainView:timeFormat(timeAll)
	local basehour = 3600
	local basemin = 60
	local hour = math.floor(timeAll / basehour)
	local time = timeAll - hour * basehour
	local min = math.floor(time / basemin)
	local time = time - basemin * min
	local sec = math.floor(time)
	if hour < 10 then
		hour = "0" .. hour or hour
	end
	if min < 10 then
		min = "0" .. min or min
	end
	if sec < 10 then
		sec = "0" .. sec or sec
	end
	local nowTimeStr = hour .. ":" .. min .. ":" .. sec
	return nowTimeStr
end

function TanbaoMainView:clear()
	self.isShowTanbaoMainView = false
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	if self._scheduleTime then
		self._schedulerTime.unscheduleGlobal(self._scheduleTime)
	end
	self:close()
end

function TanbaoMainView:setUpArrowPos()
	local x = radius * math.sin(ratios * baseRatio)
	local y = radius * math.cos(ratios * baseRatio)
	self._roteArrow:setPosition(cc.p(x, y))
	self._roteArrow:setRotation(360 * ratios)
end

function TanbaoMainView:setUpExtraView(param)
end

function TanbaoMainView:formatTime(timeStr)
	local timeAry = string.splite(timeStr, "_")
end

function TanbaoMainView:resetRoadLenth(target)
	if self._preTarget and self._preTarget ~= target then
		local temp = self._preTarget
		self._preTarget = target
		target = target - temp + 1
	elseif self._preTarget and self._preTarget == target then
		target = 1
		self._preTarget = self._preTarget
	elseif not self._preTarget then
		self._preTarget = target
	end
	local round = 2
	self._totalRatio = (target - 1) * 0.1 + 1 * round
	if self._offset then
		local offset = math.random(-4, 4) * 0.01
		self._totalRatio = self._totalRatio - self._offset + offset
		self._offset = offset
	else
		self._offset = math.random(-4, 4) * 0.01
		self._totalRatio = self._totalRatio + self._offset
	end
	self.speed = 0
	self.t1 = 40
	self.t2 = 150
	self.timer = 0
	self.a1 = self._totalRatio * 2 / (self.t1 + self.t2) / self.t1
	self.a2 = self._totalRatio * 2 / (self.t1 + self.t2) / self.t2
	self._schedule = self._scheduler.scheduleGlobal(self.countDown, 0.01, false)
	self.btnOne:setTouchEnabled(false)
	self.btnTen:setTouchEnabled(false)
end

function TanbaoMainView:ctor(param)
	self.isShowTanbaoMainView = true
	self:load()
	local bng = display.newScale9Sprite("#month_bg.png", 0, 0, param.size)
	bng:setAnchorPoint(cc.p(0, 0))
	self:addChild(bng)
	local function func()
		if not self.isShowTanbaoMainView then
			return
		end
		self:setUpView(param)
	end
	self.shadowLayer = nil
	self:getData(func)
end

function TanbaoMainView:close()
	self:release()
end

function TanbaoMainView:load()
	display.addSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
end

function TanbaoMainView:release()
	display.removeSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
end

function TanbaoMainView:createItemView(pos, node, data, idx)
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	local icon = ResMgr.refreshIcon({
	id = data.id,
	resType = ResMgr.getResType(data.type),
	itemType = data.type
	})
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(pos)
	icon:setAnchorPoint(cc.p(0.5, 0.5))
	local function isSepcial(i)
		for k, v in ipairs(self.sepcialPos) do
			if v == i then
				return true
			end
		end
		return false
	end
	
	--czy
	addTouchListener(icon, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.73)
		elseif eventType == EventType.ended then
			sender:setScale(0.75)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local function callback(data)
				self:showGiftPopup(data, common:getLanguageString("@kesuijihdjl"), nil, boxType.suiji)
			end
			self:yuLanRequest(callback, idx)
			--[[
			if isSepcial(idx) then
				local item = self._baseItem[idx]
				local data = {
				{
				id = item.id,
				type = item.type,
				num = 1
				}
				}
				self:showGiftPopup(data, common:getLanguageString("@kesuijihdjl"), nil, boxType.suiji)
			else
				local function callback(data)
					self:showGiftPopup(data, common:getLanguageString("@kesuijihdjl"), nil, boxType.suiji)
				end
				--self:yuLanRequest(callback, data.itemId)
				self:yuLanRequest(callback, idx)
			end
			]]
		elseif eventType == EventType.cancel then
			sender:setScale(0.75)
		end
	end)
	icon:setScale(0.75)
	
	--道具名称
	local nameColor = ResMgr.getItemNameColorByType(data.id, ResMgr.getResType(data.type))
	local nameLabel = ui.newTTFLabelWithOutline({
	text = require("data.data_item_item")[data.id].name,
	size = 20,
	color = nameColor,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	nameLabel:align(display.CENTER_TOP, icon:getContentSize().width / 2, 0)
	icon:addChild(nameLabel, 1000)
	if tonumber(data.type) == 6 then
		local iconSp = require("game.Spirit.SpiritIcon").new({
		resId = self._data.giftData[index].id,
		bShowName = true
		})
		node:addChild(iconSp)
		iconSp:setAnchorPoint(cc.p(0, 0.5))
		iconSp:setPosition(icon:getPosition())
	else
		node:addChild(icon, 1)
	end
	return icon
end

function TanbaoMainView:showGiftPopup(data, title, func, type, dataExtra)
	dump(data)
	local dataTemp = {}
	for k, v in pairs(data) do
		local temp = {}
		temp.id = v.id
		temp.num = v.num
		temp.type = v.type
		temp.iconType = ResMgr.getResType(v.type)
		temp.name = ResMgr.getItemNameByType(v.id, temp.iconType)
		table.insert(dataTemp, temp)
	end
	local msgBox
	if type == boxType.jifen then
		msgBox = require("game.nbactivity.TanBao.JifenRewordBox").new({
		title = title,
		num = dataExtra.value,
		cellDatas = dataTemp,
		jifen = self._jifen,
		state = dataExtra.state,
		confirmFunc = func
		})
	elseif type == boxType.suiji then
		msgBox = require("game.nbactivity.TanBao.SuijiRewordBox").new({
		title = title,
		cellDatas = dataTemp,
		confirmFunc = func
		})
	elseif type == boxType.common then
		msgBox = require("game.Huodong.RewardMsgBox").new({
		title = title,
		cellDatas = dataTemp,
		confirmFunc = func
		})
	end
	CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
end

function TanbaoMainView:getData(func)
	ratios = 0
	local function init(data)
		self._type = data.activeData.type
		self._totalCount = data.activeData.limitCnt
		self._jifen = data.roleDataState.credit
		self._time = data.roleDataState.surTimes
		self._freeTime = data.roleDataState.freeTimes
		self._priceOne = data.activeData.price
		self._priceTen = data.activeData.price * 10
		self._countDownTime = data.roleDataState.countDown
		self.sepcialPos = data.activeData.sepcialPos
		self.sepcialPosGoods = data.activeData.sepcialPosGoods
		self._start = data.roleDataState.startT
		self._end = data.roleDataState.endT
		self._baseItem = {}
		self._selectIndex = CCUserDefault:sharedUserDefault():getIntegerForKey("TANBAO_IDX", 1)
		for k, v in pairs(data.rouletteState) do
			local item = {}
			item.id = v.itemDisplay
			item.itemId = v.id
			if not data_item_item[v.itemDisplay] then
				dump(v.itemDisplay)
			end
			item.type = data_item_item[v.itemDisplay].type
			table.insert(self._baseItem, item)
		end
		local data = self._baseItem
		table.sort(self._baseItem, function(a, b)
			return a.itemId < b.itemId
		end)
		func()
	end
	
	RequestHelper.tanbaoSystem.getBaseInfo({
	callback = function(data)
		dump(data)
		init(data)
	end
	})
end

--开始探宝
function TanbaoMainView:tanBaoRequest(func, type)
	local function init(data)
		dump(data.checkBag)
		--背包已满
		if data.checkBag and #data.checkBag > 0 then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.checkBag
			})
			self:addChild(layer, 10)
		else
			self._jifen = data.credit
			self._freeTime = data.freeTimes
			self._time = data.surTimes
			self._target = data.position
			self._tanbaoGift = data.itemAry
			self:resetRoadLenth(self._target)
			self.shadowLayer = require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 0))
			CCDirector:sharedDirector():getRunningScene():addChild(self.shadowLayer, 1200)
			func(type)
		end
	end
	
	--开始探宝
	RequestHelper.tanbaoSystem.startFind({
	callback = function(data)
		dump(data)
		init(data)
	end,
	num = type,
	indexId = self._selectIndex
	})
end

--探宝预览请求
function TanbaoMainView:yuLanRequest(func, index)
	local function init(data)
		local dataTemp = {}
		for k, v in pairs(data.itemType) do
			local temp = {}
			temp.id = data.itemId[k]
			temp.type = v
			temp.num = data.itemCnt[k]
			table.insert(dataTemp, temp)
		end
		func(dataTemp)
	end
	RequestHelper.tanbaoSystem.preViewItem({
	callback = function(data)
		dump(data)
		init(data)
	end,
	id = index
	})
end

return TanbaoMainView