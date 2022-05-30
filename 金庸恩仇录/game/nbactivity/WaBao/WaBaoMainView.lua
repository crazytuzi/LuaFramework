require("game.Biwu.BiwuFuc")

local WaBaoMainView = class("WaBaoMainView", function()
	return display.newLayer("WaBaoMainView")
end)

local data_item_item = require("data.data_item_item")
function WaBaoMainView:setUpView(param)
	self:setContentSize(param.size)
	local bng = display.newSprite("ui/jpg_bg/main_bng.jpg")
	bng:setAnchorPoint(cc.p(0.5, 0.5))
	bng:setPosition(cc.p(display.width / 2, display.height * 0.44))
	self:addChild(bng)
	local centerIcon = display.newSprite("#center_icon.png")
	centerIcon:setAnchorPoint(cc.p(0.5, 0.6))
	centerIcon:setPosition(cc.p(param.size.width / 2, param.size.height * 0.75))
	self:addChild(centerIcon)
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "wabao_eff",
	isRetain = false
	})
	bgEffect:setScale(0.6)
	bgEffect:setPosition(centerIcon:getContentSize().width / 2, centerIcon:getContentSize().height / 2)
	centerIcon:addChild(bgEffect, 10, 22222)
	
	--奖励预览
	local preBtn = display.newSprite("#wj_extraReward_btn.png")
	preBtn:setPosition(cc.p(param.size.width * 0.1, param.size.height - preBtn:getContentSize().height / 2 - 10))
	self:addChild(preBtn)
	addTouchListener(preBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if not CCDirector:sharedDirector():getRunningScene():getChildByTag(10000000) then
				CCDirector:sharedDirector():getRunningScene():addChild(require("game.nbactivity.WaBao.WaBaoGiftPopup").new(self._libId), 1222222, 10000000)
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	
	--说明按键
	local disBtn = display.newSprite("#shuoming.png")
	disBtn:setPosition(cc.p(param.size.width * 0.9, param.size.height - preBtn:getContentSize().height / 2 - 10))
	self:addChild(disBtn)
	addTouchListener(disBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			local layer = require("game.SplitStove.SplitDescLayer").new(4)
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	local timeLabel = display.newSprite("#countdown.png")
	timeLabel:align(display.RIGHT_TOP, param.size.width - 10, disBtn:getPositionY() - disBtn:getContentSize().height / 2 - 30)
	self:addChild(timeLabel)
	self._timeLabelCountDown = ui.newTTFLabelWithOutline({
	text = "00:00:00",
	size = 23,
	color = cc.c3b(0, 254, 60),
	outlineColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy
	})
	self._timeLabelCountDown:align(display.RIGHT_TOP, param.size.width - 15, timeLabel:getPositionY() - timeLabel:getContentSize().height)
	self:addChild(self._timeLabelCountDown)
	
	local oneBtn = display.newSprite("#btn_one.png")
	oneBtn:setPosition(cc.p(-100 + centerIcon:getContentSize().width / 2, 0))
	centerIcon:addChild(oneBtn)
	
	--czy
	--挖一次
	
	addTouchListener(oneBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:startDig(1)
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	
	self._onePriceLabel = ui.newTTFLabelWithOutline({
	text = "220",
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	self._onePriceLabel:align(display.RIGHT_CENTER, 80, -10)
	self._oneMoneyIcon = display.newSprite("#icon_gold.png")
	self._oneMoneyIcon:align(display.LEFT_CENTER, 80, -10)
	
	oneBtn:addChild(self._onePriceLabel)
	oneBtn:addChild(self._oneMoneyIcon)
	
	local allBtn = display.newSprite("#btn_all.png")
	allBtn:setPosition(cc.p(100 + centerIcon:getContentSize().width / 2, 0))
	centerIcon:addChild(allBtn)
	addTouchListener(allBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if game.player:getVip() > 0 then
				self:startDig(2)
			else
				show_tip_label(data_error_error[1500804].prompt)
			end
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	if display.width / display.height >= 0.75 then
		centerIcon:setPosition(cc.p(param.size.width / 2, param.size.height * 0.75))
		allBtn:setPosition(cc.p(100 + centerIcon:getContentSize().width / 2, 60))
		oneBtn:setPosition(cc.p(-100 + centerIcon:getContentSize().width / 2, 60))
	end
	local vipIcon = display.newSprite("#vipFuli_vip.png")
	vipIcon:setPosition(cc.p(340, -30))
	local vipFont = ui.newBMFontLabel({
	text = "1",
	font = "fonts/font_vip.fnt",
	align = ui.TEXT_ALIGN_LEFT
	})
	vipFont:setPosition(cc.p(360, -38))
	centerIcon:addChild(vipFont)
	centerIcon:addChild(vipIcon)
	vipIcon:setScale(0.7)
	vipFont:setScale(0.7)
	if 1 <= game.player:getVip() then
		vipIcon:setVisible(false)
		vipFont:setVisible(false)
	end
	self._freeTimeLabel = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@mianfeiyc"),
	size = 20,
	color = cc.c3b(0, 240, 255),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	self._freeTimeLabel:align(display.LEFT_CENTER, 0, -10)
	oneBtn:addChild(self._freeTimeLabel)
	
	self._freeTimeLeftLabel = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@NextFreeTime", "00:00"),
	size = 20,
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	self._freeTimeLeftLabel:align(display.LEFT_CENTER, 0, -35)
	oneBtn:addChild(self._freeTimeLeftLabel)
	
	--全部挖	
	self._refAllPriceLabel = ui.newTTFLabelWithOutline({
	text = "220",
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy
	})
	
	self._refAllPriceLabel:align(display.RIGHT_CENTER, 80, -10)
	local moneyIcon = display.newSprite("#icon_gold.png")
	moneyIcon:align(display.LEFT_CENTER, 80, -10)
	allBtn:addChild(self._refAllPriceLabel)
	allBtn:addChild(moneyIcon)
	
	self._actLabel = ui.newTTFLabelWithOutline({
	text = "2012-10-10 20:23:20至2012-10-10 20:23:20",
	size = 23,
	color = cc.c3b(0, 254, 60),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	self._actLabel:align(display.CENTER, param.size.width/2, 250)
	self:addChild(self._actLabel)
	
	local Label1 = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@jinrisyybwbcs"),
	size = 20,
	color = cc.c3b(255, 255, 255),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	Label1:align(display.LEFT_CENTER, param.size.width * 0.2, 230)
	
	self._timeLeftLabel = ui.newTTFLabelWithOutline({
	text = "200",
	size = 20,
	color = cc.c3b(0, 240, 255),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	self._timeLeftLabel:align(display.LEFT_CENTER, Label1:getPositionX() + Label1:getContentSize().width + 10, 230)
	
	local Label3 = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@Next"),
	size = 20,
	color = cc.c3b(255, 255, 255),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	Label3:align(display.LEFT_CENTER, self._timeLeftLabel:getPositionX() + self._timeLeftLabel:getContentSize().width, 230)
	
	self:addChild(Label1)
	self:addChild(self._timeLeftLabel)
	self:addChild(Label3)
	self._bottomBng = display.newScale9Sprite("ui/ui_9Sprite/buttom_bng.png", 0, 0, cc.size(param.size.width - 40, 180))
	self._bottomBng:setAnchorPoint(cc.p(0.5, 0))
	self._bottomBng:setPosition(cc.p(param.size.width / 2, 20))
	self:addChild(self._bottomBng)
	local titleIcon = display.newSprite("#buttom_title.png")
	titleIcon:setPosition(cc.p(self._bottomBng:getContentSize().width * 0.5, self._bottomBng:getContentSize().height * 1))
	self._bottomBng:addChild(titleIcon)
	self.refreshTimeBtn = display.newSprite("#time_btn_refresh.png")
	self.refreshTimeBtn:setAnchorPoint(cc.p(0.5, 0))
	self.refreshTimeBtn:setPosition(cc.p(self._bottomBng:getContentSize().width * 0.3, 10))
	--CZY
	addTouchListener(self.refreshTimeBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if self._remainReFreshTime ~= 0 then
				show_tip_label(common:getLanguageString("@NoTimeRefresh"))
				return
			end
			self:getRefreshData(0, function()
				self:refresh(self._itemData)
				self:refreshAll(self._itemData)
			end)
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	self._bottomBng:addChild(self.refreshTimeBtn)
	self.refreshTimeLabel = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("00:00"),
	size = 20,
	color = cc.c3b(255, 255, 255),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	
	self.refreshTimeLabel:align(display.LEFT_CENTER, 105, 25)
	self.refreshTimeBtn:addChild(self.refreshTimeLabel)
	local refreshBtn = display.newSprite("#gold_btn_refresh.png")
	refreshBtn:align(display.CENTER_BOTTOM, self._bottomBng:getContentSize().width * 0.7, 10)
	
	--czy
	addTouchListener(refreshBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:getRefreshData(1, function()
				self:refresh(self._itemData)
				self:refreshAll(self._itemData)
			end)
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	
	self._bottomBng:addChild(refreshBtn)
	--元宝刷新消耗数量
	
	
	
	self._refreshPrice = ui.newTTFLabelWithOutline({
	text = "20",
	size = 20,
	color = cc.c3b(255, 255, 255),
	outlineColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy
	})
	self._refreshPrice:align(display.RIGHT_CENTER, refreshBtn:getContentSize().width - 40,  refreshBtn:getContentSize().height / 2 - 2)
	refreshBtn:addChild(self._refreshPrice)
end

function WaBaoMainView:showResetPopup()
	local function okFunc()
		local function func()
			self:refresh()
			self:refreshAll(self._itemData)
		end
		self:getData(func)
	end
	local msgBox = require("utility.MsgBox").new({
	size = cc.size(500, 300),
	content = "\n       宝库已在零点刷新，请重新挖宝！",
	showClose = true,
	directclose = true,
	midBtnFunc = okFunc
	})
	CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 10000)
end

function WaBaoMainView:refreshItem(target)
	if self._itemInstance[target] then
		local getTag = display.newSprite("#tag_get.png")
		getTag:setAnchorPoint(cc.p(0.5, 0.5))
		getTag:setPosition(cc.p(self._itemInstance[target]:getContentSize().width / 2, self._itemInstance[target]:getContentSize().height / 2))
		getTag:setRotation(-45)
		self._itemInstance[target]:addChild(getTag, 10)
		local mask = display.newScale9Sprite("#guild_shop_black_bg.png")
		dump(self._itemData)
		if self._itemData[tostring(target)].t == 6 then
			mask:setContentSize(cc.size(self._itemInstance[target]:getContentSize().width, self._itemInstance[target]:getContentSize().height - 35))
			mask:setPosition(cc.p(self._itemInstance[target]:getContentSize().width / 2, self._itemInstance[target]:getContentSize().height / 2 + 14))
			getTag:setPositionY(getTag:getPositionY() + 10)
		else
			mask:setContentSize(self._itemInstance[target]:getContentSize())
			mask:setPosition(cc.p(self._itemInstance[target]:getContentSize().width / 2, self._itemInstance[target]:getContentSize().height / 2))
		end
		mask:setAnchorPoint(cc.p(0.5, 0.5))
		self._itemInstance[target]:addChild(mask)
	else
		dump(common:getLanguageString("@chongfuxz"))
	end
end

function WaBaoMainView:showItemDetail(node, data)
	addTouchListener(node, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.65)
		elseif eventType == EventType.ended then
			sender:setScale(0.7)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			local itemInfo
			if data.type ~= 6 then
				itemInfo = require("game.Huodong.ItemInformation").new({
				id = data.id,
				type = data.type,
				name = require("data.data_item_item").name,
				describe = require("data.data_item_item").dis
				})
			else
				itemInfo = require("game.Spirit.SpiritInfoLayer").new(4, {
				resId = tonumber(data.id)
				})
			end
			CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
		elseif eventType == EventType.cancel then
			sender:setScale(0.7)
		end
	end)
end

function WaBaoMainView:selectAll(data)
	for i = 1, 8 do
		self:refreshItem(i)
	end
end

function WaBaoMainView:refreshAll(data)
	if self._itemInstance then
		for k, v in pairs(self._itemInstance) do
			if v then
				self._itemInstance[k]:removeFromParent()
			end
		end
	end
	self._itemInstance = {}
	for k, v in pairs(data) do
		local icon = self:createItemView(k, self._bottomBng, v)
		if v.t == 6 then
			icon:setPosition(k * (self._bottomBng:getContentSize().width / 8 - 3) - 25, self._bottomBng:getContentSize().height - 60)
		else
			icon:setPosition(k * (self._bottomBng:getContentSize().width / 8 - 3) - 25, self._bottomBng:getContentSize().height - 50)
		end
		self._itemInstance[tonumber(k)] = icon
		dump(k)
	end
	dump(self._itemInstance)
end

function WaBaoMainView:createItemView(index, node, dataTemp)
	data = {
	id = dataTemp.id,
	type = dataTemp.t,
	num = dataTemp.n
	}
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	local icon
	if tonumber(data.type) == ITEM_TYPE.zhenqi then
		icon = require("game.Spirit.SpiritIcon").new({
		resId = data.id,
		bShowName = true,
		bNum = data.num
		})
	else
		icon = ResMgr.refreshIcon({
		id = data.id,
		resType = ResMgr.getResType(data.type),
		iconNum = data.num,
		itemType = data.type
		})
	end
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setAnchorPoint(cc.p(0.5, 0.5))
	self:showItemDetail(icon, data)
	icon:setScale(0.7)
	local nameColor = ResMgr.getItemNameColorByType(data.id, ResMgr.getResType(data.type))
	
	local nameLabel = ui.newTTFLabelWithOutline({
	text = require("data.data_item_item")[data.id].name,
	size = 20,
	color = nameColor,
	outlineColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(100, 60),
	valign = ui.TEXT_ALIGN_CENTER
	})
	nameLabel:setPosition(cc.p(icon:getContentSize().width / 2, -24))
	icon:addChild(nameLabel)
	nameLabel:setScale(1)
	if data.type == 6 then
		nameLabel:setVisible(false)
	end
	node:addChild(icon, index)
	return icon
end

function WaBaoMainView:timeFormat(timeAll)
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
	local nowTimeStr = hour .. common:getLanguageString("@Hour") .. min .. common:getLanguageString("@Minute") .. sec .. common:getLanguageString("@Sec")
	return nowTimeStr
end

function WaBaoMainView:ctor(param)
	self:load()
	self:setUpView(param)
	local function func()
		if not self.isWaBaoMainViewShow then
			return
		end
		self:refresh()
		self:refreshAll(self._itemData)
	end
	self:getData(func)
end

function WaBaoMainView:getData(func)
	local function init(data)
		if not self.isWaBaoMainViewShow then
			return
		end
		self._nowTime = data.nowTime / 1000 or 200
		self._timeLeft = data.surGoldTimes or "200"
		self._timeFree = data.freeTimes or "10"
		self._priceAll = data.digAllGold or "20"
		self._priceOne = data.digOneGold or 0
		self._priceRef = data.refreshCost or "20"
		self._itemData = data.treasuryMap or {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8
		}
		self._hasgetAry = data.hasGetAry
		self._selectCount = #data.hasGetAry
		self._remainReFreshTime = data.remainReFreshTime
		self._remainFreeDigTime = data.remainFreeDigTime
		self._start = data.startT
		self._end = data.endT
		self._libId = data.libId
		if func then
			func()
		end
		for k, v in pairs(self._hasgetAry) do
			self:refreshItem(tonumber(v))
		end
		dump(self._priceRef)
	end
	RequestHelper.wabaoSystem.getBaseInfo({
	callback = function(data)
		dump(data)
		init(data)
	end
	})
end

function WaBaoMainView:timeFormat(timeAll)
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

function WaBaoMainView:timeFormatForMiu(timeAll)
	local basehour = 3600
	local basemin = 60
	local hour = math.floor(timeAll / basehour)
	local time = timeAll - hour * basehour
	local min = math.floor(time / basemin)
	local time = time - basemin * min
	local sec = math.floor(time)
	if min < 10 then
		min = "0" .. min or min
	end
	if sec < 10 then
		sec = "0" .. sec or sec
	end
	local nowTimeStr = min .. ":" .. sec
	return nowTimeStr
end

function WaBaoMainView:getRefreshData(retype, func)
	local function init(data)
		if data.isOtherDay == 1 then
			self:showResetPopup()
			return
		end
		self._priceAll = data.digAllGold
		self._priceOne = data.digOneGold
		self._itemData = data.treasuryMap
		self._remainReFreshTime = data.remainReFreshTime
		self._selectCount = 0
		func()
	end
	
	RequestHelper.wabaoSystem.refresh({
	callback = function(data)
		dump(data)
		init(data)
		
	end,
	retype = retype
	})
end

function WaBaoMainView:startDig(index)
	local function init(data)
		if not self.isWaBaoMainViewShow then
			return
		end
		if data.isOtherDay == 1 then
			self:showResetPopup()
			return
		end
		if data.checkBag and #data.checkBag > 0 then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.checkBag
			})
			self:addChild(layer, 10)
		else
			if self._timeFree == 1 then
				show_tip_label(common:getLanguageString("@FreeTimeOver"))
			end
			local target = data.treasuryMap
			dump(target)
			self._timeLeft = data.surGoldTimes
			self._timeFree = data.freeTimes
			self._priceAll = data.digAllGold
			self._priceOne = data.digOneGold
			self._remainFreeDigTime = data.remainFreeDigTime
			if index == 1 then
				self._selectCount = self._selectCount + 1
			else
				self._selectCount = 8
			end
			self:refresh()
			for k, v in pairs(target) do
				self:refreshItem(tonumber(k))
			end
			local dataTemp = {}
			for k, v in pairs(target) do
				local temp = {}
				temp.id = v.id
				temp.num = v.n
				temp.type = v.t
				temp.iconType = ResMgr.getResType(v.t)
				temp.name = require("data.data_item_item")[v.id].name
				table.insert(dataTemp, temp)
			end
			self:createArmature(dataTemp, func)
		end
	end
	if self._selectCount and self._selectCount >= 8 then
		show_tip_label(data_error_error[1500803].prompt)
		return
	end
	
	RequestHelper.wabaoSystem.beginDig({
	callback = function(data)
		dump(data)
		init(data)
	end,
	type = index
	})
end

function WaBaoMainView:createArmature(dataTemp, func)
	local function secondArm()
		local function callback()
			if CCDirector:sharedDirector():getRunningScene():getChildByTag(11111) then
				CCDirector:sharedDirector():getRunningScene():removeChildByTag(11111)
			end
			if CCDirector:sharedDirector():getRunningScene():getChildByTag(22222) then
				CCDirector:sharedDirector():getRunningScene():removeChildByTag(22222)
			end
			if not self.isWaBaoMainViewShow then
				return
			end
			if self:getChildByTag(1000) then
				self:removeChildByTag(1000)
			end
			if func then
				func()
			end
		end
		local msgBox = require("game.Huodong.RewardMsgBox").new({
		title = common:getLanguageString("@RewardList"),
		cellDatas = dataTemp,
		confirmFunc = callback
		})
		CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
		local bgEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "xiakejinjie_xunhuan",
		isRetain = false
		})
		bgEffect:setScale(0.6)
		bgEffect:setPosition(display.cx, display.cy)
		CCDirector:sharedDirector():getRunningScene():addChild(bgEffect, 10, 22222)
	end
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(cc.c3b(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask, 1, 1000)
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xiakejinjie_qishou",
	isRetain = false,
	frameFunc = secondArm,
	finishFunc = function()
	end
	})
	bgEffect:setScale(0.6)
	bgEffect:setPosition(display.cx, display.cy)
	CCDirector:sharedDirector():getRunningScene():addChild(bgEffect, 10, 11111)
end

function WaBaoMainView:refresh(flag)
	if not self.isWaBaoMainViewShow then
		return
	end
	if not flag then
		self._countDownTime = self._nowTime
	end
	if not self._schedulerTime then
		self._schedulerTime = require("framework.scheduler")
		local function countDown()
			self._countDownTime = self._countDownTime - 1
			if self._countDownTime <= 0 then
				self._timeLabelCountDown:setString(common:getLanguageString("@ActivityOver"))
				show_tip_label(common:getLanguageString("@ActivityOver"))
			else
				self._timeLabelCountDown:setString(self:timeFormat(self._countDownTime))
			end
			if self._remainReFreshTime then
				if 0 >= self._remainReFreshTime then
					self._remainReFreshTime = 0
					self:refresh(true)
				else
					self.refreshTimeLabel:setString(self:timeFormatForMiu(self._remainReFreshTime / 1000))
					self._remainReFreshTime = self._remainReFreshTime - 1000
				end
			end
			if self._remainFreeDigTime then
				if 0 >= self._remainFreeDigTime then
					if self._timeFree < 3 then
						local function func()
							self:refresh(true)
							self:refreshAll(self._itemData)
						end
						self:getData(func)
					end
				else
					self._freeTimeLeftLabel:setString(common:getLanguageString("@NextFreeTime", self:timeFormat(self._remainFreeDigTime / 1000)))
					self._remainFreeDigTime = self._remainFreeDigTime - 1000
				end
			end
		end
		self._scheduleTime = self._schedulerTime.scheduleGlobal(countDown, 1, false)
	end
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
	self._actLabel:setString(startTime .. common:getLanguageString("@DateTo") .. endTime)
	self._timeLeftLabel:setString(self._timeLeft)
	self._freeTimeLabel:setString(common:getLanguageString("@mianfei") .. self._timeFree .. common:getLanguageString("@Next"))
	self._refAllPriceLabel:setString(self._priceAll)
	self._refreshPrice:setString(self._priceRef)
	if 3 <= self._timeFree then
		self._freeTimeLeftLabel:setVisible(false)
	else
		self._freeTimeLeftLabel:setVisible(true)
	end
	if self._timeFree == 0 then
		self._freeTimeLabel:setVisible(false)
		self._oneMoneyIcon:setVisible(true)
		self._onePriceLabel:setVisible(true)
	else
		self._freeTimeLabel:setVisible(true)
		self._oneMoneyIcon:setVisible(false)
		self._onePriceLabel:setVisible(false)
	end
	if self._remainReFreshTime == 0 then
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("time_btn_refresh.png")
		self.refreshTimeBtn:setDisplayFrame(frame)
	else
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("time_btn_refresh_grey.png")
		self.refreshTimeBtn:setDisplayFrame(frame)
	end
	self._onePriceLabel:setString(self._priceOne)
end

function WaBaoMainView:load()
	self.isWaBaoMainViewShow = true
	display.addSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.addSpriteFramesWithFile("ui/ui_nbactivity_wabao.plist", "ui/ui_nbactivity_wabao.png")
	display.addSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.addSpriteFramesWithFile("ui/ui_guild_shop.plist", "ui/ui_guild_shop.png")
	display.addSpriteFramesWithFile("ui/ui_vipFuli.plist", "ui/ui_vipFuli.png")
end

function WaBaoMainView:clear()
	if self._scheduleTime then
		self._schedulerTime.unscheduleGlobal(self._scheduleTime)
		self._scheduleTime = nil
	end
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
		self._schedule = nil
	end
	self:release()
	dump("clear")
end

function WaBaoMainView:release()
	self.isWaBaoMainViewShow = false
	display.removeSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.removeSpriteFramesWithFile("ui/ui_nbactivity_wabao.plist", "ui/ui_nbactivity_wabao.png")
	display.removeSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.removeSpriteFramesWithFile("ui/ui_guild_shop.plist", "ui/ui_guild_shop.png")
	display.removeSpriteFramesWithFile("ui/ui_vipFuli.plist", "ui/ui_vipFuli.png")
end

return WaBaoMainView