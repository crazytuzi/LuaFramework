local data_ui_ui = require("data.data_ui_ui")
local data_yabiao_jiangli_yabiao_jiangli = require("data.data_yabiao_jiangli_yabiao_jiangli")
local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")
local data_item_item = require("data.data_item_item")

local btnCloseRes = {
normal = "#win_base_close.png",
pressed = "#win_base_close.png",
disabled = "#win_base_close.png"
}

local YabiaoSelectView = class("YabiaoSelectView", function()
	return require("utility.ShadeLayer").new(cc.c4b(0,0,0,150))
end)

function YabiaoSelectView:ctor(param)
	self:loadRes()
	self._param = param
	local function func()
		self:setUpView(param)
	end
	self:_getData(func)
end

function YabiaoSelectView:setUpView(param)
	--self:createMask()
	
	local mainBng = display.newScale9Sprite("#win_base_bg2.png", 0, 0, cc.size(display.width, display.width * 1.1)):pos(display.cx, display.cy):addTo(self)
	local mainBngSize = mainBng:getContentSize()
	local innnerBng = display.newScale9Sprite("#win_base_inner_bg_light.png", 0, 0, cc.size(mainBngSize.width * 0.95, mainBngSize.width * 1.1 * 0.87)):pos(mainBngSize.width / 2, mainBngSize.height / 2 - 25):addTo(mainBng)
	local titleText = ui.newBMFontLabel({
	text = common:getLanguageString("@yabiao"),
	size = 22,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_title
	})
	titleText:align(display.CENTER_TOP, mainBngSize.width /2, mainBngSize.height * 0.97)
	titleText:addTo(mainBng)
	
	--关闭按键
	local closeBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = btnCloseRes.normal,
	handle = function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:close()
	end,
	})
	closeBtn:align(display.CENTER, mainBngSize.width - 30, mainBngSize.height - 30)
	closeBtn:addTo(mainBng)
	
	local offset = 24
	self._cars = {}
	for i = 1, 4 do
		local node = self:createCardNode(i)
		node:setPosition(innnerBng:getContentSize().width / 5 * i + (i - 2.5) * offset, innnerBng:getContentSize().height - 120)
		self._cars[i] = node
		innnerBng:addChild(node)
	end
	
	--刷新
	local shuaxinBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#mianfeishuanxin.png",
	handle = function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self._target == 4 then
			show_tip_label(data_error_error[3400010].prompt)
			return
		end
		self:_refreshData(1)
		if self._shuaxinCishu ~= 0 then
			self:refreshBtns()
		end
	end
	})
	shuaxinBtn:align(display.CENTER, innnerBng:getContentSize().width * 0.2, innnerBng:getContentSize().height * 0.42)
	innnerBng:addChild(shuaxinBtn)
	
	--运镖
	local yunbiaoBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#kaishiyunbiao.png",
	handle = function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self._target == 0 then
			show_tip_label(common:getLanguageString("@xuanzebc"))
			return
		end
		if self._yabiaoCishu == 0 then
			show_tip_label(data_error_error[3400006].prompt)
			return
		end
		self:_startRunCar()
	end
	})
	yunbiaoBtn:align(display.CENTER, innnerBng:getContentSize().width * 0.8, innnerBng:getContentSize().height * 0.42)
	innnerBng:addChild(yunbiaoBtn)
	
	self._shuaxinBtn = shuaxinBtn
	self._yabiaoBtn = yunbiaoBtn
	if self._shuaxinCishu ~= 0 then
		self:refreshBtns()
	end
	local yabiaoTime = ui.newTTFLabel({
	text = common:getLanguageString("@yabiaocs"),
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(92, 38, 1),
	font = FONTS_NAME.font_fzcy
	})
	local jiebiaoTime = ui.newTTFLabel({
	text = common:getLanguageString("@jiebiaocs"),
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(92, 38, 1),
	font = FONTS_NAME.font_fzcy
	})
	local yabiaoTimeValue = ui.newTTFLabel({
	text = self._yabiaoCishu,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(92, 38, 1),
	font = FONTS_NAME.font_fzcy
	})
	local jiebiaoTimeValue = ui.newTTFLabel({
	text = self._jiebiaoCishu,
	size = 20,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(92, 38, 1),
	font = FONTS_NAME.font_fzcy
	})
	yabiaoTime:setPosition(cc.p(innnerBng:getContentSize().width * 0.2, innnerBng:getContentSize().height * 0.33))
	jiebiaoTime:setPosition(cc.p(innnerBng:getContentSize().width * 0.8, innnerBng:getContentSize().height * 0.33))
	yabiaoTimeValue:setPosition(cc.p(innnerBng:getContentSize().width * 0.35, innnerBng:getContentSize().height * 0.33))
	jiebiaoTimeValue:setPosition(cc.p(innnerBng:getContentSize().width * 0.95, innnerBng:getContentSize().height * 0.33))
	innnerBng:addChild(yabiaoTime)
	innnerBng:addChild(jiebiaoTime)
	innnerBng:addChild(yabiaoTimeValue)
	innnerBng:addChild(jiebiaoTimeValue)
	alignNodesOneByOne(yabiaoTime, yabiaoTimeValue)
	alignNodesOneByOne(jiebiaoTime, jiebiaoTimeValue)
	local contentBng = display.newScale9Sprite("#guild_cbg_itemInnerBg_1.png", 0, 0, cc.size(innnerBng:getContentSize().width - 30, innnerBng:getContentSize().height * 0.27)):pos(innnerBng:getContentSize().width / 2, 15):addTo(innnerBng)
	contentBng:setAnchorPoint(cc.p(0.5, 0))
	local txt = data_ui_ui[9].content
	local content = CCLabelTTF:create(txt, FONTS_NAME.font_fzcy, 18, cc.size(contentBng:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	content:setAnchorPoint(cc.p(0.5, 1))
	content:setColor(cc.c3b(124, 0, 0))
	content:setPosition(cc.p(contentBng:getContentSize().width / 2, contentBng:getContentSize().height - 20))
	contentBng:addChild(content)
	if self._carId ~= 0 then
		self:randomCard(self._carId, false)
	else
		self:randomCard(1, false)
	end
end

function YabiaoSelectView:refreshGold()
	game.player:setGold(self.gold)
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
end

function YabiaoSelectView:refreshBtns()
	self._shuaxinBtn:replaceNormalButton("#yuanbaoshuaxin.png")
	self._shuaxinPrice = ui.newTTFLabelWithShadow({
	text = data_config_yabiao_config_yabiao[18].value,
	size = 18,
	color = cc.c3b(255, 222, 0),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	self._shuaxinPrice:setPosition(cc.p(self._shuaxinBtn:getContentSize().width * 0.7, self._shuaxinBtn:getContentSize().height * 0.5))
	self._shuaxinBtn:bgAddChild(self._shuaxinPrice)
end

function YabiaoSelectView:forbidenBtns()
	if self._shuaxinCishu ~= 0 then
		self._shuaxinBtn:replaceNormalButton("#yuanbaoshuaxin_p.png")
	else
		self._shuaxinBtn:replaceNormalButton("#mianfeishuanxin_p.png")
	end
	self._yabiaoBtn:replaceNormalButton("#kaishiyunbiao_p.png")
	self._yabiaoBtn:setTouchEnabled(false)
	self._shuaxinBtn:setTouchEnabled(false)
	self._zhaohuanBtn:setTouchEnabled(false)
end

function YabiaoSelectView:activityBtns()
	if self._shuaxinCishu ~= 0 then
		self._shuaxinBtn:replaceNormalButton("#yuanbaoshuaxin.png")
	else
		self._shuaxinBtn:replaceNormalButton("#mianfeishuanxin.png")
	end
	self._yabiaoBtn:replaceNormalButton("#kaishiyunbiao.png")
	self._yabiaoBtn:setTouchEnabled(true)
	self._shuaxinBtn:setTouchEnabled(true)
	self._zhaohuanBtn:setTouchEnabled(true)
end

function YabiaoSelectView:createCardNode(types)
	local node = display.newNode()
	local cardSp = display.newSprite("#card_car_0" .. types .. ".png")
	node:addChild(cardSp)
	local disBng = display.newScale9Sprite("#guild_cbg_innerBg_light.png", 0, 0, cc.size(cardSp:getContentSize().width, cardSp:getContentSize().height * 0.3))
	disBng:setAnchorPoint(cc.p(0.5, 1))
	disBng:setPosition(cc.p(0, -10 - cardSp:getContentSize().height / 2))
	node:addChild(disBng)
	local cardName = {
	common:getLanguageString("@lvsebc"),
	common:getLanguageString("@lansebc"),
	common:getLanguageString("@zisebc"),
	common:getLanguageString("@jinsebc")
	}
	local typeColor = {
	cc.c3b(0, 228, 48),
	cc.c3b(0, 168, 255),
	cc.c3b(192, 0, 255),
	cc.c3b(255, 165, 0)
	}
	--名称
	local typeLabel = ui.newTTFLabelWithShadow({
	text = cardName[types],
	size = size or 18,
	color = typeColor[types],
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	typeLabel:align(display.CENTER, cardSp:getContentSize().width/2, cardSp:getContentSize().height * 0.88)
	cardSp:addChild(typeLabel)
	
	local titleBng = display.newSprite("#jiangli_tag.png")
	titleBng:setPosition(cc.p(disBng:getContentSize().width / 2, disBng:getContentSize().height))
	disBng:addChild(titleBng)
	dump(types)
	local dataBase = data_yabiao_jiangli_yabiao_jiangli[types]
	local itemId1 = dataBase.rewardIds[1]
	local itemId2 = dataBase.rewardIds[2]
	local num01 = math.floor(dataBase.fix[1] + dataBase.ratio[1] * game.player:getLevel())
	local num02 = math.floor(dataBase.fix[2] + dataBase.ratio[2] * game.player:getLevel())
	if self._isInActivity == 0 then
		num01 = num01 .. "X" .. data_config_yabiao_config_yabiao[21].value / 100
		num02 = num02 .. "X" .. data_config_yabiao_config_yabiao[21].value / 100
	end
	
	--消耗银币
	local yinbiTag = ui.newTTFLabelWithShadow({
	text = data_item_item[itemId1].name,
	size = size or 18,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	--消耗银币值
	local yinbiValue = ui.newTTFLabelWithShadow({
	text = num01,
	size = size or 18,
	color = cc.c3b(0, 216, 255),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	--声望
	local shengwangTag = ui.newTTFLabelWithShadow({
	text = data_item_item[itemId2].name,
	size = size or 18,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	local shengwangValue = ui.newTTFLabelWithShadow({
	text = num02,
	size = size or 18,
	color = cc.c3b(252, 28, 255),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	yinbiTag:align(display.LEFT_CENTER, 10, disBng:getContentSize().height * 0.62)
	yinbiValue:align(display.LEFT_CENTER, 15 + yinbiTag:getContentSize().width, disBng:getContentSize().height * 0.62)
	
	shengwangTag:align(display.LEFT_CENTER, 10, disBng:getContentSize().height * 0.25)
	shengwangValue:align(display.LEFT_CENTER, 15 + shengwangTag:getContentSize().width, disBng:getContentSize().height * 0.25)
	
	local zhaoHuanBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#zhuaohuan.png",
	})
	zhaoHuanBtn:align(display.CENTER, cardSp:getContentSize().width / 2, cardSp:getContentSize().height * 0.1)
	cardSp:addChild(zhaoHuanBtn)
	zhaoHuanBtn:setVisible(types == 4)
	local zhaohuanPrice = ui.newTTFLabelWithShadow({
	text = data_config_yabiao_config_yabiao[19].value,
	size = size or 18,
	color = cc.c3b(252, 28, 255),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	zhaohuanPrice:setPosition(cc.p(zhaoHuanBtn:getContentSize().width * 0.7, zhaoHuanBtn:getContentSize().height * 0.5))
	zhaoHuanBtn:bgAddChild(zhaohuanPrice)
	zhaoHuanBtn:setTouchHandle(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self._target == 4 then
			show_tip_label(data_error_error[3400010].prompt)
			return
		end
		local function func()
			self:_refreshData(2)
		end
		self:addChild(require("game.Yabiao.YabiaoSpeedUpCommitPopup").new({
		cost = data_config_yabiao_config_yabiao[19].value,
		disStr = common:getLanguageString("@zhaohuanjbc"),
		confirmFunc = func
		}))
		
	end)
	
	self._zhaohuanBtn = zhaoHuanBtn
	disBng:addChild(yinbiTag)
	disBng:addChild(yinbiValue)
	disBng:addChild(shengwangTag)
	disBng:addChild(shengwangValue)
	return node
end

function YabiaoSelectView:randomCard(target, isPlayAnimation)
	local baseSeed = 1
	local speed = 2
	local counter = 1
	local select = display.newSprite("#card_car_select.png")
	self._target = target
	for k, v in pairs(self._cars) do
		local select = display.newSprite("#card_car_select.png")
		if not v:getChildByTag(111) then
			v:addChild(select, 0, 111)
		end
		v:getChildByTag(111):setVisible(false)
	end
	local step = 0
	local speed = 0.01
	local counter = 1
	local taget = target
	local countDownFuc
	function countDownFuc()
		self:performWithDelay(function()
			if step >= speed * 19 + speed * taget then
				self:activityBtns()
				return
			end
			step = step + speed
			counter = (counter + 1) % 5 == 0 and 1 or (counter + 1) % 5
			for k, v in pairs(self._cars) do
				v:getChildByTag(111):setVisible(false)
			end
			self._cars[counter]:getChildByTag(111):setVisible(true)
			countDownFuc()
		end,
		step)
	end
	if isPlayAnimation then
		self:forbidenBtns()
		countDownFuc()
	else
		self._cars[target]:getChildByTag(111):setVisible(true)
	end
end

function YabiaoSelectView:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(cc.c3b(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask)
end

function YabiaoSelectView:loadRes()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function YabiaoSelectView:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function YabiaoSelectView:close()
	self:releaseRes()
	if self._scheduler then
		self._scheduler.unscheduleGlobal(self._schedule)
		self._scheduler = nil
	end
	self:removeSelf()
end

function YabiaoSelectView:showResetPopup()
	self:removeAllChildren()
	local function func()
		self:setUpView(self.param)
	end
	self:_getData(func)
	show_tip_label(data_error_error[3400011].prompt)
end

function YabiaoSelectView:_getData(func)
	local function initData(data)
		if data.lastQuality == 0 then
		else
		end
		self._yabiaoCishu = data.detainTimes
		self._jiebiaoCishu = data.robTimes
		self._shuaxinCishu = data.refreshTimes
		self._shuaxinCost = data.refreshCost
		self._carId = data.lastQuality
		self._target = data.lastQuality
		self._isInActivity = data.isInActivetime
		func()
	end
	RequestHelper.yaBiaoSystem.carSelectState({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoSelectView:_refreshData(_type)
	local function initData(data)
		if data.isOtherDay == 0 then
			self:showResetPopup()
			return
		end
		self._target = data.quality
		self._shuaxinCishu = data.refreshTimes
		self:randomCard(self._target, _type == 1)
		self.gold = data.gold
		self:refreshGold()
		if self._shuaxinCishu ~= 0 then
			self:refreshBtns()
		end
	end
	RequestHelper.yaBiaoSystem.callNBCar({
	tag = _type,
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoSelectView:_startRunCar()
	
	local function initData(data)
		if data.isOtherDay == 0 then
			self:showResetPopup()
			return
		end
		if data.result == 1 then
			selfCarInfo.types = self._target
			selfCarInfo.name = game.player.m_name
			selfCarInfo.level = game.player:getLevel()
			selfCarInfo.roleId = game.player.m_playerID
			selfCarInfo.dartkey = data.dartKey
			--for k, v in pairs(selfCarInfo) do
			--	dump(k, v)
			--end
			PostNotice(NoticeKey.Yabiao_run_car)
			self:close()
		end
	end
	RequestHelper.yaBiaoSystem.beginRun({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

return YabiaoSelectView