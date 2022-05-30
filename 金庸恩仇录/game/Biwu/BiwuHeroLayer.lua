local DialyTimes = 20
local ReFreshBtnRes = {
normal = "#refresh_n.png",
pressed = "#refresh_p.png",
disabled = "#refresh_p.png"
}
local TAG = {
TAG_HERO_NAME = 10,
TAG_HERO_LEVEL = 20,
TAG_HERO_DIS = 30,
TAG_HERO_HERO = 40,
TAG_LABEL_COUNT = 50,
TAG_HERO_BNG = 60,
TAG_HERO_BNG_LABEL = 70
}

local BiwuHeroLayer = class("BiwuHeroLayer", function()
	return display.newLayer("BiwuHeroLayer")
end)

function BiwuHeroLayer:ctor(param)
	self:setContentSize(param.size)
	local bng = CCSprite:create("bg/biwu_bg.jpg", cc.rect(0, 0, display.width, display.width / 0.77))
	bng:setScaleY(param.size.height / display.width * 0.77)
	self:addChild(bng)
	bng:setAnchorPoint(cc.p(0, 0))
	self:_getData()
	self._scheduler = require("framework.scheduler")
end

function BiwuHeroLayer:setUpLabelView()
	local res = {
	{
	icon = "#naili.png",
	text = "38/38",
	font = FONTS_NAME.font_fzcy
	},
	{
	icon = "#times.png",
	text = "12/38",
	font = FONTS_NAME.font_fzcy
	},
	{
	icon = "#jifen.png",
	text = "311",
	font = FONTS_NAME.font_fzcy
	},
	{
	icon = "#paiming.png",
	text = "312",
	font = FONTS_NAME.font_fzcy
	}
	}
	local function createAddBtn(node)
		local buyBtn = display.newSprite("#add.png")
		buyBtn:setPosition(cc.p(node:getContentSize().width - 20, node:getContentSize().height / 2))
		buyBtn:setAnchorPoint(cc.p(0.5, 0.5))
		buyBtn:setTouchEnabled(true)
		node:addChild(buyBtn, 10)
		
		--czy
		buyBtn:setTouchEnabled(true)
		addTouchListener(buyBtn, function(sender, eventType)
			if eventType == EventType.began then
				sender:setScale(0.9)
			elseif eventType == EventType.ended then
				sender:setScale(1)
				buyBtn:setScale(1)
				if self._isWeekDay then
					show_tip_label(common:getLanguageString("@NotBuy"))
					return
				end
				if self.dataCenter.role.buynum == 0 then
					show_tip_label(common:getLanguageString("@NotEnough"))
					return
				end
				if self.dataCenter.role.cishu ~= 0 then
				end
				local function fuc(num, cost)
					RequestHelper.biwuSystem.addChallengeTimes({
					callback = function(data)
						self.labelObj[2]:getChildByTag(TAG.TAG_LABEL_COUNT):setString(data.times .. "/20")
						game.player:setGold(data.gold)
						self.dataCenter.role.cishu = self.dataCenter.role.cishu + num
						self.dataCenter.role.buynum = self.dataCenter.role.buynum - num
						PostNotice(NoticeKey.CommonUpdate_Label_Gold)
						PostNotice(NoticeKey.CommonUpdate_Label_Silver)
					end,
					times = num
					})
				end
				local param = {
				addPrice = 0,
				baseprice = self.dataCenter.role.cost,
				coinType = 1,
				desc = common:getLanguageString("@GetSilverCoin"),
				hadBuy = 0,
				havenum = 1,
				icon = "yidaiyinbi",
				id = 1,
				itemId = 4302,
				maxN = self.dataCenter.role.buynum,
				maxnum = self.dataCenter.role.buynum,
				name = common:getLanguageString("@ContestNumber"),
				price = self.dataCenter.role.cost,
				remainnum = self.dataCenter.role.buynum
				}
				CCDirector:sharedDirector():getRunningScene():addChild(require("game.Biwu.BiwuByTimesCountBox").new(param, fuc), 100000)
			elseif eventType == EventType.cancel then
				sender:setScale(1)
			end
		end)
	end
	self.labelObj = {}
	local baseData = {
	self.dataCenter.role.naili,
	self.dataCenter.role.cishu,
	self.dataCenter.role.jifen,
	self.dataCenter.role.paiming
	}
	for k, v in pairs(res) do
		local labelNode = self:creatDislabel(v.icon, v.text, v.font)
		labelNode:setPosition(cc.p(0, self:getContentSize().height - 40 * (k - 1) - 15))
		labelNode:setAnchorPoint(cc.p(0, 1))
		if k == 2 then
			createAddBtn(labelNode)
		end
		self:addChild(labelNode)
		local text = baseData[k]
		if k == 1 then
			text = baseData[k] .. "/" .. game.player.m_maxEnergy
		end
		if k == 2 then
			text = baseData[k] .. "/20"
		end
		labelNode:getChildByTag(TAG.TAG_LABEL_COUNT):setString(text)
		self.labelObj[k] = labelNode
	end
	
	--czy
	self.refreshBtn = display.newSprite(ReFreshBtnRes.normal)
	self.refreshBtn:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height * 0.2))
	self:addChild(self.refreshBtn)
	addTouchListener(self.refreshBtn, function(sender, eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			if game.player._biwuCollTime ~= 0 then
				show_tip_label(common:getLanguageString("@NextRefreshTime"))
				return
			end
			sender:setScale(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
			self.refreshBtn:setTouchEnabled(false)
			self:_getRefreshData()
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	
	self.titleLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@NextRefresh"),
	size = 22,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self.countDownLabel = ui.newTTFLabelWithShadow({
	text = "00:00:00",
	size = 22,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(0, 219, 52),
	shadowColor = FONT_COLOR.BLACK,
	})
	if self._isWeekDay then
		self.countDownLabel:setVisible(false)
		self.titleLabel:setVisible(false)
		self.refreshBtn:setVisible(false)
	else
		self.countDownLabel:setVisible(true)
		self.titleLabel:setVisible(true)
		self.refreshBtn:setVisible(true)
	end
	local jiangliBnt = display.newSprite("#wj_extraReward_btn.png")
	jiangliBnt:setPosition(display.width * 0.9, self:getContentSize().height * 0.9)
	self:addChild(jiangliBnt)
	addTouchListener(jiangliBnt, function(sender, eventType)
		dump(eventType)
		if eventType == EventType.began then
			sender:setScale(0.9)
		elseif eventType == EventType.ended then
			sender:setScale(1)
			if not CCDirector:sharedDirector():getRunningScene():getChildByTag(10000000) then
				CCDirector:sharedDirector():getRunningScene():addChild(require("game.Biwu.BiwuGiftPrePopup").new(self.dataCenter.role.paiming), 1222222, 10000000)
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		elseif eventType == EventType.cancel then
			sender:setScale(1)
		end
	end)
	self.titleLabel:setPosition(cc.p(display.width * 0.35, display.height * 0.06))
	self.countDownLabel:setPosition(cc.p(display.width * 0.5, display.height * 0.06))
	self:addChild(self.titleLabel)
	self:addChild(self.countDownLabel)
	alignNodesOneByOne(self.titleLabel, self.countDownLabel)
	if self._isWeekDay then
	end
	RegNotice(self, function()
		self.labelObj[1]:getChildByTag(TAG.TAG_LABEL_COUNT):setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
	end,
	NoticeKey.BIWu_update_naili)
end

function BiwuHeroLayer:setUpHeroView(...)
	local pos02 = cc.p(display.width * 0.16, display.height * 0.1)
	local pos03 = cc.p(display.width * 0.84, display.height * 0.1)
	local pos01 = cc.p(display.width * 0.5, display.height * 0.24)
	self._hero01 = self:createHeros(pos01, 1)
	self._hero02 = self:createHeros(pos02, 2)
	self._hero03 = self:createHeros(pos03, 3)
	self:refreshHeros()
end

function BiwuHeroLayer:creatDislabel(titleicon, count, fontType)
	local disBng = display.newSprite("#labebng.png")
	local disIcon = display.newSprite(titleicon)
	disIcon:setPosition(cc.p(disBng:getContentSize().width * 0.2, disBng:getContentSize().height / 2))
	disBng:addChild(disIcon)
	local countLabel = ui.newTTFLabel({
	text = count,
	size = self._titleDisFontSize,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.YELLOW,
	shadowColor = FONT_COLOR.BLACK,
	font = fontType
	})
	countLabel:setAnchorPoint(cc.p(0, 0.5))
	countLabel:setPosition(cc.p(disBng:getContentSize().width * 0.4, disBng:getContentSize().height / 2))
	disBng:addChild(countLabel, 0, TAG.TAG_LABEL_COUNT)
	return disBng
end

function BiwuHeroLayer:createHeros(pos, index)
	self.nameBng = display.newSprite("#hero_label_bng.png")
	local dizuoBng = display.newNode()
	local disLabel = ui.newTTFLabelWithOutline({
	text = "",
	size = 24,
	color = FONT_COLOR.YELLOW,
	align = ui.TEXT_ALIGN_CENTER,
	outlineColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy
	})
	local levelLabel = ui.newTTFLabelWithShadow({
	text = "",
	size = 22,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	local nameLabel = ui.newTTFLabelWithShadow({
	text = "",
	size = 22,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.YELLOW,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy
	})
	local fationLabel = ui.newTTFLabelWithShadow({
	text = "",
	size = 22,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy
	})
	
	disLabel:setPosition(cc.p(dizuoBng:getContentSize().width / 2 - disLabel:getContentSize().width / 2, dizuoBng:getPositionY() + 330))
	levelLabel:setPosition(cc.p(dizuoBng:getContentSize().width / 2 - levelLabel:getContentSize().width / 2, dizuoBng:getPositionY() + 50))
	nameLabel:setPosition(cc.p(dizuoBng:getContentSize().width / 2 - nameLabel:getContentSize().width / 2, dizuoBng:getPositionY() + 25))
	fationLabel:setPosition(cc.p(dizuoBng:getContentSize().width / 2 - fationLabel:getContentSize().width / 2, dizuoBng:getPositionY()))
	fationLabel:setVisible(true)
	local hero = display.newSprite("hero/large/banshuxian.png")
	hero:setPosition(cc.p(dizuoBng:getContentSize().width / 2, dizuoBng:getPositionY() + 200))
	hero:setScale(0.6)
	dizuoBng:addChild(disLabel, 1, TAG.TAG_HERO_DIS)
	dizuoBng:addChild(levelLabel, 1, TAG.TAG_HERO_LEVEL)
	dizuoBng:addChild(nameLabel, 1, TAG.TAG_HERO_NAME)
	dizuoBng:addChild(hero, -1, TAG.TAG_HERO_HERO)
	dizuoBng:addChild(fationLabel, 1, TAG.TAG_HERO_BNG_LABEL)
	dizuoBng:addChild(self.nameBng, 0, TAG.TAG_HERO_BNG)
	dizuoBng:setPosition(pos)
	self:addChild(dizuoBng)
	self.nameBng:setPositionY(self.nameBng:getPositionY() + 25)
	if display.width / display.height >= 0.75 then
		dizuoBng:setScale(0.77)
	else
		dizuoBng:setScale(0.9)
	end
	addTouchListener(hero, function(sender, event)
		dump(event)
		if event == EventType.began then
			sender:setScale(0.63)
		elseif event == EventType.ended then
			sender:setScale(0.6)
			if self._isWeekDay then
				local layer = require("game.form.EnemyFormLayer").new(1, self.dataCenter.enemy[index].acc)
				layer:setPosition(0, 0)
				CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000000)
			else
				if self.dataCenter.role.cishu == 0 then
					show_tip_label(common:getLanguageString("@DareNumberIsNull"))
					return
				end
				self["fightFuc" .. index]()
			end
		elseif event == EventType.cancel then
			sender:setScale(0.6)
		end
	end)
	return dizuoBng
end

function BiwuHeroLayer:refreshHeros()
	for i = 1, 3 do
		self:refreshHeroByPos(i, self.dataCenter.enemy[i])
	end
	if game.player._biwuCollTime > 0 then
		self:countDownLogic()
	end
end

function BiwuHeroLayer:refreshHeroByPos(pos, data)
	local level = self["_hero0" .. pos]:getChildByTag(TAG.TAG_HERO_LEVEL)
	local name = self["_hero0" .. pos]:getChildByTag(TAG.TAG_HERO_NAME)
	local icon = self["_hero0" .. pos]:getChildByTag(TAG.TAG_HERO_HERO)
	local dis = self["_hero0" .. pos]:getChildByTag(TAG.TAG_HERO_DIS)
	local bng = self["_hero0" .. pos]:getChildByTag(TAG.TAG_HERO_BNG)
	local fation = self["_hero0" .. pos]:getChildByTag(TAG.TAG_HERO_BNG_LABEL)
	if data == nil then
		dis:setString("")
		level:setString("")
		name:setString("")
		icon:setVisible(false)
		return
	end
	icon:setVisible(true)
	level:setString("LV:" .. data.level)
	name:setString(data.name)
	local _levelDis
	if not self._isWeekDay then
		_levelDis = {
		{
		dis = common:getLanguageString("@GetBit"),
		font = "fonts/font_yellow_brown_num.fnt",
		color = FONT_COLOR.GREEN_1
		},
		{
		dis = common:getLanguageString("@GetFair"),
		font = "fonts/font_yellow_brown_num.fnt",
		color = FONT_COLOR.BLUE
		},
		{
		dis = common:getLanguageString("@GetExpert"),
		font = "fonts/font_yellow_brown_num.fnt",
		color = FONT_COLOR.YELLOW
		}
		}
	else
		_levelDis = {
		{
		dis = common:getLanguageString("@First"),
		font = "fonts/font_yellow_brown_num.fnt",
		color = FONT_COLOR.YELLOW
		},
		{
		dis = common:getLanguageString("@Second"),
		font = "fonts/font_yellow_brown_num.fnt",
		color = FONT_COLOR.BLUE
		},
		{
		dis = common:getLanguageString("@Thirdly"),
		font = "fonts/font_yellow_brown_num.fnt",
		color = FONT_COLOR.GREEN
		}
		}
	end
	dis:setString(_levelDis[data.quality].dis)
	dis:setColor(_levelDis[data.quality].color)
	if data.faction ~= "" then
		bng:setScaleY(1.7)
		if not fation:isVisible() then
			bng:setPositionY(level:getPositionY() - 26)
		end
		fation:setVisible(true)
		fation:setString("【" .. data.faction .. "】")
	else
		bng:setScaleY(1)
		bng:setPositionY(level:getPositionY() - 13)
		fation:setVisible(false)
	end
	local heroFrame = ResMgr.getHeroFrame(data.leadId, data.cls, data.fashionId or 0)
	icon:setDisplayFrame(heroFrame)
	self["fightFuc" .. pos] = function()
		BiwuController.sendFightData(BiwuConst.BIWU, data.roleId, TabIndex.BIWU, data.name)
	end
end

function BiwuHeroLayer:countDownLogic(...)
	if self.dataCenter.colltime == 0 then
		self.refreshBtn:setDisplayFrame(display.newSprite(ReFreshBtnRes.normal):getDisplayFrame())
	else
		self.refreshBtn:setDisplayFrame(display.newSprite(ReFreshBtnRes.pressed):getDisplayFrame())
	end
	local function countDown()
		self.refreshBtn:setTouchEnabled(false)
		if game.player._biwuCollTime ~= 0 then
			self.countDownLabel:setString(format_time(game.player._biwuCollTime))
			self.refreshBtn:setTouchEnabled(false)
		else
			self.refreshBtn:setDisplayFrame(display.newSprite(ReFreshBtnRes.normal):getDisplayFrame())
			self._scheduler.unscheduleGlobal(self._schedule)
			self.countDownLabel:setString(format_time(game.player._biwuCollTime))
			self.refreshBtn:setTouchEnabled(true)
		end
		alignNodesOneByOne(self.titleLabel, self.countDownLabel)
	end
	self._schedule = self._scheduler.scheduleGlobal(countDown, 1, false)
end

function BiwuHeroLayer:remove()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	UnRegNotice(self, NoticeKey.BIWu_update_naili)
	self:removeSelf()
end

function BiwuHeroLayer:_getData()
	local function initData(data)
		self.dataCenter = {}
		self.dataCenter.role = {}
		self.dataCenter.role.naili = data.resisVal
		self.dataCenter.role.cishu = data.challengeTimes
		self.dataCenter.role.paiming = data.rank
		self.dataCenter.role.jifen = data.score
		self.dataCenter.role.buynum = data.buy_num
		self.dataCenter.role.cost = data.cost
		if data.rank == 0 then
			self.dataCenter.role.paiming = common:getLanguageString("@NotHave")
		else
			self.dataCenter.role.paiming = data.rank
		end
		if #data.top3 == 0 then
			self.dataCenter.enemy = data.opponents
			self._isWeekDay = false
		else
			self.dataCenter.enemy = data.top3
			self._isWeekDay = true
		end
		self.dataCenter.colltime = data.nextFleshTime / 1000 - os.time() + GameModel.deltaTime
		if not self.setUpLabelView or not self.setUpHeroView then
			return
		end
		self:setUpLabelView()
		self:setUpHeroView()
	end
	RequestHelper.biwuSystem.getBaseInfo({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function BiwuHeroLayer:_getRefreshData(...)
	local function initEnemy(data)
		self.dataCenter.enemy = data.opponents
		game.player._biwuCollTime = 10
	end
	RequestHelper.biwuSystem.getRefreshHero({
	callback = function(data)
		dump(data)
		initEnemy(data)
		self:refreshHeros()
	end
	})
end

return BiwuHeroLayer