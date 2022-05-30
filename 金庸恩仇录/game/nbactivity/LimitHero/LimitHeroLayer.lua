local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
require("data.data_error_error")

local LimitHeroLayer = class("LimitHeroLayer", function()
	return display.newNode()
end)

function LimitHeroLayer:adjustHero()
	local adjOffX = (self.curPage - 1) * -display.width
	self:updateHeroName()
	self.heroTableList:setContentOffset(cc.p(adjOffX, 0), true)
	self._rootnode.left_arrow:setVisible(true)
	self._rootnode.right_arrow:setVisible(true)
	if self.curPage == 1 then
		self._rootnode.left_arrow:setVisible(false)
	elseif self.curPage == #self.heroList then
		self._rootnode.right_arrow:setVisible(false)
	else
		self._rootnode.left_arrow:setVisible(true)
		self._rootnode.right_arrow:setVisible(true)
	end
	if #self.heroList == 1 then
		self._rootnode.left_arrow:setVisible(false)
		self._rootnode.right_arrow:setVisible(false)
	end
	local heroId = self.heroList[self.curPage]
	local starNum = ResMgr.getCardData(heroId).star[1]
	for i = 1, 5 do
		if i == starNum then
			self._rootnode["star_" .. i .. "_node"]:setVisible(true)
		else
			self._rootnode["star_" .. i .. "_node"]:setVisible(false)
		end
	end
end

function LimitHeroLayer:ctor(param)
	local viewSize = param.viewSize
	self.viewSize = viewSize
	self:setNodeEventEnabled(true)
	self.player = game.player
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local contentNode = CCBuilderReaderLoad("nbhuodong/limit_hero_layer.ccbi", proxy, self._rootnode, self, viewSize)
	self:addChild(contentNode)
	self:load()
	LimitHeroModel.sendInitRes({
	callback = function()
		self:init()
		self:update()
	end
	})
end

function LimitHeroLayer:init()
	local function createFunc(idx)
		local item = require("game.nbactivity.LimitHero.LimitHeroCell").new()
		return item:create(idx, self.viewSize)
	end
	local refreshFunc = function(cell, id)
		cell:refresh(id)
	end
	self.heroList = LimitHeroModel.getHeroList()
	self.heroTableList = require("utility.TableViewExt").new({
	size = self.viewSize,
	direction = kCCScrollViewDirectionHorizontal,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.heroList,
	cellSize = cc.size(display.width, self.viewSize.height)
	})
	self.heroTableList:setBounceable(true)
	self.heroTableList:setTouchEnabled(false)
	local LIST_HEIGHT = 295
	self.heroTableList:setPosition(0, LIST_HEIGHT)
	self._rootnode.limit_bg:addChild(self.heroTableList)
	self.touchLayer = display.newColorLayer(cc.c4b(100, 50, 50, 0))
	self.touchLayer:setPosition(cc.p(0, LIST_HEIGHT))
	self.touchLayer:setContentSize(cc.size(display.width, self.viewSize.height - LIST_HEIGHT))
	self.touchLayer:setTouchEnabled(true)
	self.touchLayer:setTouchSwallowEnabled(false)
	self.curPage = 1
	self._rootnode.left_arrow:setVisible(false)
	if #self.heroList == 1 then
		self._rootnode.left_arrow:setVisible(false)
		self._rootnode.right_arrow:setVisible(false)
	end
	self._rootnode.limit_bg:addChild(self.touchLayer)
	local isTouching = false
	local preX = 0
	local aftX = 0
	
	--czy
	self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			preX = event.x
			local touchPos = cc.p(event.x, event.y)
			local layPos = self.touchLayer:getParent():convertToWorldSpace(cc.p(self.touchLayer:getPositionX(), self.touchLayer:getPositionY()))
			local layRect = cc.rect(layPos.x, layPos.y, self.touchLayer:getContentSize().width, self.touchLayer:getContentSize().height)
			local isInLayer = cc.rectContainsPoint(layRect, cc.p(event.x, event.y))
			if isInLayer then
				return true
			else
				return false
			end
		elseif event.name == "moved" then
			if math.abs(event.x - event.prevX) > 5 then
				local touchOffx = event.x - event.prevX
				local curOff = self.heroTableList:getContentOffset()
				curOff.x = curOff.x + touchOffx
				self.heroTableList:setContentOffset(curOff, false)
			end
		elseif event.name == "ended" then
			aftX = event.x
			if aftX - preX < -50 then
				if self.curPage < #self.heroList then
					self.curPage = self.curPage + 1
				end
			elseif aftX - preX > 50 and self.curPage > 1 then
				self.curPage = self.curPage - 1
			end
			self:adjustHero()
		end
	end)
	
	self._rootnode.left_arrow:setZOrder(1000)
	self._rootnode.right_arrow:setZOrder(1000)
	ResMgr.setControlBtnEvent(self._rootnode.desc_btn, function()
		local layer = require("game.nbactivity.LimitHero.LimitHeroDescLayer").new()
		display.getRunningScene():addChild(layer, 100)
	end)
	ResMgr.setControlBtnEvent(self._rootnode.free_btn, function()
		self:onFreeDraw()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.gold_btn, function()
		self:onGoldDraw()
	end)
	local startTimeStr = LimitHeroModel.actStartTime()
	local endTimeStr = LimitHeroModel.actEndTime()
	
	--活动时间  亲  测 源 码 网  w w w. q c  y  m  w .c o m
	local actTimePeriod = common:getLanguageString("@ActivityTime", startTimeStr, endTimeStr)
	local timePeriodTTF = ui.newTTFLabelWithShadow({
	text = actTimePeriod,
	size = 26,
	color = cc.c3b(36, 255, 0),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	timePeriodTTF:setPosition(self._rootnode.hero_ttf:getPositionX(), self._rootnode.hero_ttf:getPositionY() + self._rootnode.hero_ttf:getContentSize().height / 2 + timePeriodTTF:getContentSize().height / 2)
	self._rootnode.up_node:addChild(timePeriodTTF)
	self:initActTimeSchedule()
	self:updateHeroName()
	self.luckBar = display.newProgressTimer("#herolimit_bar02.png", display.PROGRESS_TIMER_BAR)
	self.luckBar:setMidpoint(cc.p(0, 0.5))
	self.luckBar:setBarChangeRate(cc.p(1, 0))
	self.luckBar:setAnchorPoint(cc.p(0, 0.5))
	self.luckBar:setPosition(0, self._rootnode.luck_bg:getContentSize().height / 2)
	self._rootnode.luck_bg:addChild(self.luckBar)
	
	--幸运条
	
	self.luckBarTTF = ui.newTTFLabelWithShadow({
	text = LimitHeroModel.luckNum() .. "/" .. LimitHeroModel.maxLuckNum(),
	size = 26,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	self.luckBarTTF:setPosition(self._rootnode.luck_bg:getContentSize().width / 2, self._rootnode.luck_bg:getContentSize().height / 2)
	self._rootnode.luck_bg:addChild(self.luckBarTTF)
	
	self.luckEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xianshihaojie_xingyunzhiman",
	isRetain = true
	})
	self.luckEffect:setPosition(self._rootnode.luck_bg:getContentSize().width / 2, self._rootnode.luck_bg:getContentSize().height / 2)
	self._rootnode.luck_bg:addChild(self.luckEffect)
	self.luckEffect:setVisible(false)
	self.goldDrawEff = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "xianshihaojie_yuanbaochouqu",
	isRetain = true
	})
	self.goldDrawEff:setPosition(self._rootnode.gold_btn:getContentSize().width / 2, self._rootnode.gold_btn:getContentSize().height / 2)
	self._rootnode.gold_btn:addChild(self.goldDrawEff)
	
	self.freeDrawLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@LeftTime"),
	size = 22,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(36, 255, 0),
	shadowColor = display.COLOR_BLACK,
	})
	self.freeDrawLabel:setPosition(self._rootnode.free_btn:getPositionX(), self._rootnode.free_btn:getPositionY() - self._rootnode.free_btn:getContentSize().height / 2 - self.freeDrawLabel:getContentSize().height / 2)
	self._rootnode.down_node:addChild(self.freeDrawLabel)
	
	self.player:setOpenBoxCout(LimitHeroModel.player_score() / 10)
	local scoreLimit = LimitHeroModel.scoreLimit()
	local limitNum = LimitHeroModel.scoreLimitNum()
	local probItems = LimitHeroModel.getProbItems()
	local progressNode = self._rootnode.progressNode
	self._fill = display.newProgressTimer("#progressbng.png", display.PROGRESS_TIMER_BAR)
	self._fill:setMidpoint(cc.p(0, 0.5))
	self._fill:setBarChangeRate(cc.p(1, 0))
	self._fill:setPosition(progressNode:getContentSize().width * 0.5, progressNode:getContentSize().height * 0.5)
	progressNode:addChild(self._fill)
	self._fill:setPercentage(0)
	local width_item = progressNode:getContentSize().width / limitNum[#limitNum]
	self.treasureChest = {}
	for i, v in ipairs(scoreLimit) do
		if self.treasureChest[i] == nil then
			self.treasureChest[i] = display.newSprite("#gold_close.png")
			self.treasureChest[i]:setPosition(width_item * limitNum[i] - 10, progressNode:getContentSize().height * 0.5)
			local disLabel = ui.newTTFLabelWithOutline({
			text = scoreLimit[i] .. common:getLanguageString("@jifen"),
			size = 20,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_CENTER,
			color = cc.c3b(0, 240, 255),
			outlineColor = display.COLOR_BLACK,
			})
			disLabel:setPosition(5, 5)
			progressNode:addChild(self.treasureChest[i])
			
			addTouchListener(self.treasureChest[i], function(sender, eventType)
				if eventType == EventType.began then
					sender:setScale(0.9)
				elseif eventType == EventType.ended then
					local packgeState = LimitHeroModel.packgeState()
					sender:setScale(1)
					self._index = i
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					if self.player:getOpenBoxCout() < limitNum[i] or packgeState[i] == 1 then
						self:showGiftPopup(probItems[i], common:getLanguageString("@lingjiang"), confimFunc, LimitHeroModel.player_score(), scoreLimit[i], packgeState[i])
					else
						local function confimFunc()
							RequestHelper.formation.openBoxReq({
							acc = game.player:getAccount(),
							index = i - 1,
							callback = function(data)
								LimitHeroModel.setPackgeState(i, 1)
								self:setProgressRewards()
							end
							})
						end
						self:showGiftPopup(probItems[i], common:getLanguageString("@lingjiang"), confimFunc, LimitHeroModel.player_score(), scoreLimit[i], packgeState[i])
					end
				elseif eventType == EventType.cancel then
					sender:setScale(1)
				end
			end)
			
		end
	end
	self:setProgressRewards()
	self._rootnode.text_gold:setString(LimitHeroModel.costGold())
	self._rootnode.tag_vip:setString(LimitHeroModel.costVip())
end

function LimitHeroLayer:showGiftPopup(data, title, func, jifen, limitNum, state)
	--dump(data)
	--dump("1111111111111111111111111111111111")
	local dataTemp = {}
	for k, v in ipairs(data) do
		--dump("2222222222222222222222222222222222")
		local temp = {}
		temp.id = v.id
		temp.num = v.n
		temp.type = v.t
		temp.iconType = ResMgr.getResType(v.t)
		temp.name = ResMgr.getItemNameByType(v.id, temp.iconType)
		table.insert(dataTemp, temp)
	end
	local _state = state
	if state == 1 then
		_state = 0
	else
		_state = 1
	end
	local msgBox = require("game.nbactivity.TanBao.JifenRewordBox").new({
	title = title,
	num = limitNum,
	cellDatas = dataTemp,
	jifen = jifen,
	state = _state,
	titleDis = common:getLanguageString("@xianshihaojiejianglitishi"),
	confirmFunc = func
	})
	CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
end

function LimitHeroLayer:showDialog(data, title)
	local itemData = {}
	for k, v in pairs(data) do
		local item = ResMgr.getRefreshIconItem(v.id, v.t)
		item.num = v.n or 0
		table.insert(itemData, item)
	end
	local msgBox = require("game.Huodong.RewardMsgBox").new({title = title, cellDatas = itemData})
	msgBox:setPosition(-display.cx, 0)
	self:addChild(msgBox)
end

function LimitHeroLayer:setProgressRewards()
	local limitNum = LimitHeroModel.scoreLimitNum()
	local packgeState = LimitHeroModel.packgeState()
	local probItems = LimitHeroModel.getProbItems()
	local num = limitNum[#limitNum]
	local _ratio = common:yuan3(num < self.player:getOpenBoxCout(), num, self.player:getOpenBoxCout())
	self._fill:setPercentage(100 / num * _ratio)
	
	local goldRes = {
	{
	"#submap_box_close_1.png",
	"#submap_box_close_2.png",
	"#submap_box_close_3.png"
	},
	{
	"#submap_box_open_1.png",
	"#submap_box_open_2.png",
	"#submap_box_open_3.png"
	},
	{
	"#submap_box_end_1.png",
	"#submap_box_end_3.png",
	"#submap_box_end_3.png"
	}
	}
	for i, _ in ipairs(limitNum) do
		v = self.treasureChest[i]
		if v:getChildByTag(100) then
			v:removeChildByTag(100, true)
		end
		if packgeState[i] == 1 then
			v:setDisplayFrame(display.newSprite("#submap_box_end_3.png"):getDisplayFrame())
		elseif packgeState[i] == 0 then
			if self.player:getOpenBoxCout() >= limitNum[i] then
				v:setDisplayFrame(display.newSprite("#submap_box_open_3.png"):getDisplayFrame())
				if not v:getChildByTag(100) then
					local xunhuanEffect = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = "fubenjiangli_shanguang"
					})
					xunhuanEffect:setPosition(v:getContentSize().width / 2, v:getContentSize().height / 2)
					v:addChild(xunhuanEffect, 1, 100)
				end
			else
				v:setDisplayFrame(display.newSprite("#submap_box_close_2.png"):getDisplayFrame())
			end
		end
	end
end

function LimitHeroLayer:updateDownTableView()
	self._rootnode.table_bg:removeAllChildren()
	local function createFunc(idx)
		local item = require("game.nbactivity.LimitHero.LimitRankCell").new()
		return item:create(idx, self._rootnode.table_bg:getContentSize().width)
	end
	local refreshFunc = function(cell, id)
		cell:refresh(id)
	end
	self.curList = LimitHeroModel.rankList()
	self.rankList = require("utility.TableViewExt").new({
	size = self._rootnode.table_bg:getContentSize(),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.curList,
	cellSize = cc.size(self._rootnode.table_bg:getContentSize().width, 22)
	})
	self.rankList:setTouchEnabled(true)
	self._rootnode.table_bg:addChild(self.rankList)
end

function LimitHeroLayer:updateRightDesc()
	self._rootnode.ttf_node:removeAllChildren()
	local arrPos = function(ttf, node)
		ttf:align(display.LEFT_CENTER)
		ttf:setPosition(node:getPositionX() + node:getContentSize().width / 2, node:getPositionY() - 3)
	end
	
	--排名
	local curText, fontSize = LimitHeroModel.getModifiedPlayerRank()
	local rankNum = ui.newTTFLabelWithShadow({
	text = curText,
	size = fontSize,
	color = cc.c3b(36, 255, 0),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	arrPos(rankNum, self._rootnode.rank)
	self._rootnode.ttf_node:addChild(rankNum)
	
	local scoreNum = ui.newTTFLabelWithShadow({
	text = LimitHeroModel.playerScore(),
	size = 20,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	arrPos(scoreNum, self._rootnode.score)
	self._rootnode.ttf_node:addChild(scoreNum)
	
	local yuanbaoNum = ui.newTTFLabelWithShadow({
	text = game.player.m_gold,
	size = 20,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	arrPos(yuanbaoNum, self._rootnode.yuanbao)
	self._rootnode.ttf_node:addChild(yuanbaoNum)
	
	local times = LimitHeroModel.restLuckNum()
	local textLabel = ui.newBMFontLabel({
	text = "",
	font = FONTS_NAME.font_zhaojiang
	})
	textLabel:setAnchorPoint(cc.p(0, 1))
	textLabel:setScale(0.8)
	textLabel:setPosition(self._rootnode.table_bg:getContentSize().width + 30, self._rootnode.ttf_node:getContentSize().height - 10)
	if times > 0 then
		textLabel:setString(common:getLanguageString("@DrawCardForHero", times))
	else
		textLabel:setString(common:getLanguageString("@DrawCardForHero2"))
	end
	self._rootnode.ttf_node:addChild(textLabel)
	local ttfColor = {
	cc.c3b(255, 210, 0),
	cc.c3b(36, 255, 0),
	cc.c3b(255, 255, 255)
	}
	local textContent = {
	common:getLanguageString("@Rank"),
	{
	" " .. common:getLanguageString("@DI") .. "1",
	" 2-3",
	" 4-20",
	" 21-50"
	},
	common:getLanguageString("@kehuode")
	}
	local orX = self._rootnode.table_bg:getContentSize().width + 32
	local orY = 97
	local curOffsetY = 25
	local curX = orX
	local curY = orY
	for i = 1, 4 do
		for j = 1, 4 do
			local curColor
			if j ~= 4 then
				curColor = ttfColor[j]
				local content = ""
				if j == 2 then
					content = textContent[j][i]
				else
					content = textContent[j]
				end
				local shadowTTF = ui.newTTFLabelWithShadow({
				text = content,
				size = 20,
				color = curColor,
				shadowColor = display.COLOR_BLACK,
				font = FONTS_NAME.font_fzcy,
				align = ui.TEXT_ALIGN_LEFT
				})
				shadowTTF:align(display.LEFT_CENTER, curX, curY)
				curX = curX + shadowTTF:getContentSize().width
				self._rootnode.ttf_node:addChild(shadowTTF)
			else
				local rewardData = LimitHeroModel.rewardList[i]
				if i == 4 then
					local heroNameTTF = ui.newTTFLabelWithShadow({
					text = rewardData[1] .. common:getLanguageString("@FiveStarHero"),
					size = 20,
					color = NAME_COLOR[5],
					shadowColor = display.COLOR_BLACK,
					font = FONTS_NAME.font_fzcy,
					align = ui.TEXT_ALIGN_LEFT
					})
					heroNameTTF:align(display.LEFT_CENTER, curX, curY)
					curX = curX + heroNameTTF:getContentSize().width
					self._rootnode.ttf_node:addChild(heroNameTTF)
				else
					for k = 1, #rewardData do
						local heroData = ResMgr.getCardData(rewardData[k])
						local heroNameTTF = ui.newTTFLabelWithShadow({
						text = heroData.name,
						size = 20,
						color = NAME_COLOR[heroData.star[1]],
						shadowColor = display.COLOR_BLACK,
						font = FONTS_NAME.font_fzcy,
						align = ui.TEXT_ALIGN_LEFT
						})
						heroNameTTF:align(display.LEFT_CENTER, curX, curY)
						curX = curX + heroNameTTF:getContentSize().width
						self._rootnode.ttf_node:addChild(heroNameTTF)
						if k ~= #rewardData then
							local heroNameSym = ui.newTTFLabelWithShadow({
							text = ",",
							size = 20,
							color = NAME_COLOR[heroData.star[1]],
							shadowColor = display.COLOR_BLACK,
							font = FONTS_NAME.font_fzcy,
							align = ui.TEXT_ALIGN_LEFT
							})
							heroNameSym:align(display.LEFT_CENTER, curX, curY)
							curX = curX + heroNameSym:getContentSize().width
							self._rootnode.ttf_node:addChild(heroNameSym)
						end
					end
				end
			end
		end
		curX = orX
		curY = curY - curOffsetY
	end
end

function LimitHeroLayer:updateDownNode()
	self:updateDownTableView()
	self:updateRightDesc()
end

function LimitHeroLayer:updateHeroName()
	local heroResId = self.heroList[self.curPage]
	local heroData = ResMgr.getCardData(heroResId)
	self._rootnode.cur_hero_name:setString(heroData.name)
	self._rootnode.cur_hero_name:setColor(NAME_COLOR[heroData.star[1]])
end

function LimitHeroLayer:updateLuckBar()
	local maxNum = 1
	if LimitHeroModel.maxLuckNum() > 0 then
		maxNum = LimitHeroModel.maxLuckNum()
	end
	local per = checkint(LimitHeroModel.luckNum() / maxNum * 100)
	self.luckBar:setPercentage(per)
	self.luckBarTTF:setString(LimitHeroModel.luckNum() .. "/" .. LimitHeroModel.maxLuckNum())
	if per < 100 then
		self.luckEffect:setVisible(false)
	else
		self.luckEffect:setVisible(true)
	end
end

function LimitHeroLayer:updateFreeDrawSchedule()
	self.freeDrawTime = LimitHeroModel.freeRestTime()
	self.freeDrawLabel:stopAllActions()
	local function freeDrawUpdate()
		local updateStr = ""
		if self.freeDrawTime > 0 then
			self.freeDrawTime = self.freeDrawTime - 1
			updateStr = format_time(self.freeDrawTime)
			LimitHeroModel.isFreeAllowFreeDraw = false
		else
			updateStr = common:getLanguageString("@DrawCardFree")
			LimitHeroModel.isFreeAllowFreeDraw = true
			self.freeDrawLabel:stopAllActions()
		end
		self.freeDrawLabel:setString(updateStr)
	end
	freeDrawUpdate()
	self.freeDrawLabel:schedule(freeDrawUpdate, 1)
end

function LimitHeroLayer:initActTimeSchedule()
	self.actRestTime = LimitHeroModel.actRestTime()
	self.actTimeLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@LeftTime"),
	size = 26,
	color = cc.c3b(36, 255, 0),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	self.actTimeLabel:setAnchorPoint(0.5, 0.5)
	self.actTimeLabel:setPosition(self._rootnode.rest_time_ttf:getContentSize().width / 2, -15)
	self._rootnode.rest_time_ttf:addChild(self.actTimeLabel)
	self._rootnode.rest_time_ttf:setPositionX(40)
	
	local function actUpdate()
		local updateStr = ""
		if self.actRestTime > 0 then
			self.actRestTime = GameModel.getRestTimeInSec(LimitHeroModel.actEndTime_inMS() / 1000)
			updateStr = format_time(self.actRestTime)
		else
			updateStr = common:getLanguageString("@ActivityOver")
			self.scheduler.unscheduleGlobal(self.timeData)
			self:stopAct()
		end
		self.actTimeLabel:setString(updateStr)
	end
	actUpdate()
	self.scheduler = require("framework.scheduler")
	if self.timeData ~= nil then
		self.scheduler.unscheduleGlobal(self.timeData)
	end
	self.timeData = self.scheduler.scheduleGlobal(actUpdate, 1, false)
end

function LimitHeroLayer:stopAct()
	self.isActStop = true
end

function LimitHeroLayer:createDrawSuccessLayer(param)
	local drawedHero = LimitHeroModel.drawedHero()
	local herolist = {}
	herolist[1] = drawedHero
	dump(drawedHero)
	local heroName = ""
	local rankNum, fontSize = LimitHeroModel.getModifiedPlayerRank()
	local zhaojiangLayer = require("game.shop.ZhaojiangResultNormal").new({
	type = 4,
	herolist = herolist,
	leftTime = LimitHeroModel.restLuckNum(),
	scoreTable = {
	LimitHeroModel.getScore(),
	LimitHeroModel.playerScore(),
	rankNum
	},
	buyListener = function()
		self:onGoldDraw()
	end,
	cost = LimitHeroModel.costGold(),
	removeListener = function()
		self:update()
	end
	})
	self:showTip()
	if param.isFree == 1 then
		ResMgr.showMsg(20, 1.5)
	end
	local ZHAOJIANG_LAYER_TAG = 102222
	zhaojiangLayer:setTag(ZHAOJIANG_LAYER_TAG)
	display.getRunningScene():removeChildByTag(ZHAOJIANG_LAYER_TAG, true)
	display.getRunningScene():addChild(zhaojiangLayer, 50)
end

function LimitHeroLayer:showTip()
	if LimitHeroModel.luckNum() >= 100 then
		local firstResId = self.heroList[1]
		local heroData = ResMgr.getCardData(firstResId)
		show_tip_label(ResMgr.getMsg(19) .. heroData.name)
	elseif LimitHeroModel.getLuckNumThisTime() > 0 then
		show_tip_label(common:getLanguageString("@LuckyPlus") .. LimitHeroModel.getLuckNumThisTime())
	end
end

function LimitHeroLayer:onFreeDraw()
	if self.isActStop == true then
		show_tip_label(common:getLanguageString("@ActivityOver"))
		return
	end
	if LimitHeroModel.getIsAllowFreeDraw() then
		LimitHeroModel.sendFreeDraw({
		callback = function()
			self:createDrawSuccessLayer({isFree = 1})
			local limitNum = LimitHeroModel.scoreLimitNum()
			if self.player:getOpenBoxCout() < limitNum[#limitNum] then
				self.player:setOpenBoxCout(self.player:getOpenBoxCout() + 1)
				self:setProgressRewards()
			end
		end
		})
	else
		ResMgr.showMsg(18)
	end
end

function LimitHeroLayer:onGoldDraw()
	if self.isActStop == true then
		show_tip_label(common:getLanguageString("@ActivityOver"))
		return
	end
	if LimitHeroModel.isAllowGoldDraw() then
		LimitHeroModel.sendGoldDraw({
		callback = function()
			self:createDrawSuccessLayer({isFree = 0})
			local limitNum = LimitHeroModel.scoreLimitNum()
			if self.player:getOpenBoxCout() < limitNum[#limitNum] then
				self.player:setOpenBoxCout(self.player:getOpenBoxCout() + 1)
				self:setProgressRewards()
			end
		end
		})
	else
		show_tip_label(common:getLanguageString("@PriceEnough") .. "或者VIP不足")
	end
end

function LimitHeroLayer:update()
	self:updateFreeDrawSchedule()
	self:updateLuckBar()
	self:updateDownNode()
end


function LimitHeroLayer:onEnter()
	
end

function LimitHeroLayer:onExit()
	self:release()
	self.scheduler.unscheduleGlobal(self.timeData)
end

function LimitHeroLayer:load()
	display.addSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
end

function LimitHeroLayer:release()
	display.removeSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
end

return LimitHeroLayer