--[[	
	文件名称：QUIDialogActivityTurntable.lua
	创建时间：2016-07-26 10:28:35
	作者：nieming
	描述：QUIDialogActivityTurntable  豪华召唤 轮盘
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogActivityTurntable = class("QUIDialogActivityTurntable", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogTavernAchieve = import("..dialogs.QUIDialogTavernAchieve")
local QActivityTurntable = import("...utils.QActivityTurntable")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")
local QRichText = import("...utils.QRichText") 
local QQuickWay = import("...utils.QQuickWay")

--初始化
function QUIDialogActivityTurntable:ctor(options)
	local ccbFile = "Dialog_WineGod_Cricle.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, QUIDialogActivityTurntable._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerBuyTen", callback = handler(self, QUIDialogActivityTurntable._onTriggerBuyTen)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogActivityTurntable._onTriggerRank)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIDialogActivityTurntable._onTriggerRule)},
		{ccbCallbackName = "onTriggerBox1", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox1)},
		{ccbCallbackName = "onTriggerBox2", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox2)},
		{ccbCallbackName = "onTriggerBox3", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox3)},
		{ccbCallbackName = "onTriggerBox4", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox4)},
		{ccbCallbackName = "onTriggerBox5", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox5)},
		{ccbCallbackName = "onTriggerBox6", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox6)},
		{ccbCallbackName = "onTriggerBox7", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox7)},
		{ccbCallbackName = "onTriggerBox8", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox8)},
		{ccbCallbackName = "onTriggerBox9", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox9)},
		{ccbCallbackName = "onTriggerBox10", callback = handler(self, QUIDialogActivityTurntable._onTriggerBox10)},
		{ccbCallbackName = "onTriggerHeroIntroduce", callback = handler(self, QUIDialogActivityTurntable._onTriggerHeroIntroduce)},
	}
	QUIDialogActivityTurntable.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page:setScalingVisible(false)
	page.topBar:showWithActivityTurntable()

	--代码
	self.scoresBarMask = self:_addScoresBarMaskLayer(self._ccbOwner.node_bar, self._ccbOwner.barParent)
	self._itemPos = 1
	self._schedulerID = scheduler.scheduleGlobal(handler(self, self._timeUpdate), 1)

	setShadow5(self._ccbOwner.myRankLabel)
	setShadow5(self._ccbOwner.myScoreLabel)
	setShadow5(self._ccbOwner.activityScore)
	setShadow5(self._ccbOwner.activityRank)
	setShadow5(self._ccbOwner.myEliteRankLabel)
	setShadow5(self._ccbOwner.activityEliteRank)
	-- setShadow5(self._ccbOwner.hero_name)
	self._nameRichText = QRichText.new(nil, 300, {autoCenter = true})

	self._ccbOwner.richTextNode:addChild(self._nameRichText)

	remote.activityRounds:getTurntable():getActivityInfo()
	self:_onDataChange()

	self._root:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QUIDialogActivityTurntable.onFrame))
    self._root:scheduleUpdate()

end


function QUIDialogActivityTurntable:onFrame(  )
	-- body
	if self._dataDirty  then
		if not self._isShowEnd then
			self:checkTime()
			self:_onDataChange()
		end
		self._dataDirty = nil
	end
end



function QUIDialogActivityTurntable:checkTime( )
	-- body

	local curTime = q.serverTime()

	if curTime >= self._data.showEndAt then
	
		self._isShowEnd = true
		self._isActivityEnd = true
	elseif curTime >= self._data.endAt then

		self._isActivityEnd = true
		self._time = self._data.showEndAt - curTime
	else
	
		self._isActivityEnd = false
		self._time = self._data.endAt - curTime
	end
end


function QUIDialogActivityTurntable:_onDataChange( )
	-- body

	self._data = remote.activityRounds:getTurntable():getData() or {}
	self._dungeon_monster_tips = self._data.dungeon_monster_tips
	-- QPrintTable(self._data)
	if self._data.isOpen then
		self:checkTime()
		self:render()
	else
		if self._schedulerID then
			scheduler.unscheduleGlobal(self._schedulerID)
			self._schedulerID = nil
		end
		if self._schedulerID2 then
			scheduler.unscheduleGlobal(self._schedulerID2)
			self._schedulerID2 = nil
		end
		app:alert({content = "该活动下线了", title = "系统提示", callback = function (  )
                -- body
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end},false,true)
	end
	
end


function QUIDialogActivityTurntable:render(  )
	-- body
	self._ccbOwner.tf_genre:setString(self._data.theme)
	self._ccbOwner.activityScore:setString(self._data.curScore or 0)
	
	if self._data.commonRank and self._data.commonRank > 0 then
		self._ccbOwner.activityRank:setString(self._data.commonRank)
	else
		self._ccbOwner.activityRank:setString("未上榜")
	end

	if self._data.eliteRank and self._data.eliteRank > 0 then
		self._ccbOwner.activityEliteRank:setString(self._data.eliteRank)
	else
		self._ccbOwner.activityEliteRank:setString("未上榜")
	end

	self:initBox()

	if self._isShowEnd then
		self._ccbOwner.time_count_down:setString("活动已结束")
	else
		if self._time and self._time >= 0 then
			if self._isActivityEnd then
				self._ccbOwner.time_count_down:setString(string.format("领奖剩余时间: %s",q.timeToHourMinuteSecond(self._time)))
			else
				self._ccbOwner.time_count_down:setString(string.format("活动剩余时间: %s",q.timeToHourMinuteSecond(self._time)))
			end

		end
	end


	self:setScoresBarProgress()

	self._itemNum = remote.items:getItemsNumByID(41)
	if self._data.isFree then
		self._ccbOwner.tf_money:setString("免费")
	else
		self._ccbOwner.tf_money:setString(self._itemNum.."/1")
	end
	self._ccbOwner.tf_money_ten:setString(self._itemNum.."/10")
	
	if self._isActivityEnd then
		self._ccbOwner.node_buy:setVisible(false)
	else
		self._ccbOwner.node_buy:setVisible(true)
	end

	self:setItemBox()
end

function QUIDialogActivityTurntable:initBox( )
	-- body
	local width = self._ccbOwner.node_bar:getContentSize().width * self._ccbOwner.node_bar:getScaleX()
	for k, v in pairs(self._data.boxData) do
		if v.isOpened then
			self._ccbOwner["node_light"..k]:setVisible(false)
			self._ccbOwner["node_open"..k]:setVisible(true)
			self._ccbOwner["node_close"..k]:setVisible(false)
		else
			if v.isLight then
				self._ccbOwner["node_light"..k]:setVisible(true)
			else
				self._ccbOwner["node_light"..k]:setVisible(false)
			end
			self._ccbOwner["node_open"..k]:setVisible(false)
			self._ccbOwner["node_close"..k]:setVisible(true)
		end
		self._ccbOwner["score"..k]:setString(v.score)
		-- print("-----------11------------",width -70, v.score/self._data.maxScore)
		-- self._ccbOwner["node_"..k]:setPositionX((width ) * (v.score/self._data.maxScore))
	end
end



function QUIDialogActivityTurntable:_timeUpdate(  )
	-- body
	if self._isShowEnd then
		self._ccbOwner.time_count_down:setString("活动已结束")
	else
		if self._time then
			self._time = self._time -1
			if self._time <= 0 then
				self:checkTime()
			end
			if self._isActivityEnd and self._time >= 0 then
				self._ccbOwner.time_count_down:setString(string.format("领奖剩余时间: %s",q.timeToHourMinuteSecond(self._time)))
			else
				self._ccbOwner.time_count_down:setString(string.format("活动剩余时间: %s",q.timeToHourMinuteSecond(self._time)))
			end

		end
	end

end

function QUIDialogActivityTurntable:triggerBoxbyId( id )
	if self._data.boxData[id] == nil then
		app.tip:floatTip(id.."号宝箱是空的哦~~")
		return
	end

	-- body
	if self._isShowEnd then
		app.tip:floatTip("当前活动领奖时间已过，下次请早！")
		return
	end
	if self._data.boxData[id].isLight then
		self:getBoxAwards(id)
	else
		self:openBoxAwardPreview(self._data.boxData[id].awards, self._data.boxData[id].score)
	end
end

function QUIDialogActivityTurntable:getBoxAwards( boxid )
	-- body
	remote.activityRounds:getTurntable():getBoxAwards(boxid, function ( data )
		-- body
		if data.userLuckyDrawDirectionalInfo then
		    remote.activityRounds:getTurntable():updateSelfInfo(data.userLuckyDrawDirectionalInfo)
		end
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = self._data.boxData[boxid].awards}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得豪华召唤宝箱奖励")

	end)
end


function QUIDialogActivityTurntable:openBoxAwardPreview( awards, scores )
	-- body
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBoxReward",
        options = {
        	title = "宝箱奖励",
        	richTextConfig = {
        		{oType = "font", content = "领取奖励：当前积分达到",size = 26,color = GAME_COLOR_LIGHT.normal},
        		{oType = "font", content = scores,size = 26,color = GAME_COLOR_LIGHT.stress},
        		{oType = "font", content = "可领取",size = 26,color = GAME_COLOR_LIGHT.normal},
        	},
        	awards = awards
        	-- awards = {{id = 701, count = 10},{id = 701, count = 10}}
        }},{isPopCurrentDialog = false})
end



function QUIDialogActivityTurntable:setItemBox( )
	-- body

	-- 
	local index = 1
	local items = string.split(self._data.itemshow, ";")	
	self.pointNum = 1000
	self._itemBoxs = {}
	while items[index] ~= nil and index <= 6 do
		self._ccbOwner["item"..index]:stopAllActions()

		self._ccbOwner["item"..index]:removeAllChildren()

		self._itemBoxs[index] = QUIWidgetItemsBox.new()
		self._ccbOwner["item"..index]:addChild(self._itemBoxs[index])

		local itemType = remote.items:getItemType(items[index])
		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			self._itemBoxs[index]:setGoodsInfo(items[index], itemType, 0)
		else
			self._itemBoxs[index]:setGoodsInfo(items[index], ITEM_TYPE.ITEM, 0)
		end
		self._itemBoxs[index]:setPositionY(25)
		self._itemBoxs[index]:setVisible(false)
		self._itemBoxs[index]:setScale(0)
		self._itemBoxs[index]:setPromptIsOpen(true)

		local itemEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner["item"..index]:addChild(itemEffect)


		self._ccbOwner["item"..index]:setPosition(self:getStartPosByIndex(index))

		itemEffect:playAnimation("effects/WineGodItem2.ccbi", function()
				self._itemBoxs[index]:setVisible(true)
				self._itemBoxs[index]:runAction(CCScaleTo:create(0.7, 1))
			end, function()
				index = index - 1
				self:itemRunAction(index)
		end)
		index = index + 1
	end

	self:setCenterItemInfomation()
end

function QUIDialogActivityTurntable:getStartPosByIndex( index )
	-- body
	local startP = self.pointNum* 2/3
	local gap = self.pointNum/6
	startP = startP-(index*gap)

	local horizontalR = 260
    local verticalR = 110
    local PI = 3.1415926

    local data = 2 * PI / self.pointNum * startP

	return ccp(horizontalR * math.cos(data), verticalR * math.sin(data))
end

function QUIDialogActivityTurntable:itemRunAction(index) 
	local startP = self.pointNum* 2/3
	local endP = -self.pointNum*1/3
	local gap = self.pointNum/6
	startP = startP-(index*gap)
	endP = endP-(index*gap)

    local horizontalR = 260
    local verticalR = 110
    local points = CCPointArray:create(self.pointNum)
    local PI = 3.1415926
    for i = startP, endP, -1 do
        local data = 2 * PI / self.pointNum * i 
        points:add(ccp(horizontalR * math.cos(data), verticalR * math.sin(data)))
    end

    local lineTo = CCCardinalSplineTo:create(12, points, 0)
    self._ccbOwner["item"..index]:runAction(CCRepeatForever:create(lineTo))
end

function QUIDialogActivityTurntable:setCenterItemInfomation()
	if not self._data or not self._data.centerItem then
		return 
	end

	local items = string.split(self._data.centerItem, ";")
	local itemsCount = #items

	
	self._actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(items[self._itemPos])

	local node 
	if self._actorId then
		if self._itemSprite then
			self._itemSprite:stopAllActions()
	   		self._itemSprite:setVisible(false)
	   	end

		if not self._avatar  then
			self._avatar = QUIWidgetHeroInformation.new()
		    self._ccbOwner.item:addChild(self._avatar)
		    self._avatar:setBackgroundVisible(false)
			self._avatar:setNameVisible(false)
			self._ccbOwner.item:setPositionY(160)
		end

		self._avatar:setAvatarByHeroInfo(nil, tonumber(self._actorId), 1.2)
		self._avatar:setStarVisible(false)

		local heroName = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId).name
		-- self._ccbOwner.hero_name:setString(heroName or "")
		self._nameRichText:setString({{oType = "font", content = heroName,size = 26,color = UNITY_COLOR.yellow,strokeColor=QIDEA_STROKE_COLOR}})

		node = self._avatar:getActorView()
		self._avatar:setVisible(true)
	else
		if self._avatar then
			local avatarView = self._avatar:getActorView()
			avatarView:stopAllActions()
	   		self._avatar:setVisible(false)
	   	end
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(items[self._itemPos]) or {}

		if itemInfo then
			if not self._itemSprite then
				self._itemSprite = CCSprite:create(itemInfo.icon_1 or itemInfo.icon)
				self._ccbOwner.item:addChild(self._itemSprite)
				self._itemSprite:setScale(1.4)
				self._itemSprite:setPositionY(50)
				self._ccbOwner.item:setPositionY(0)
			else

				local imageTexture =CCTextureCache:sharedTextureCache():addImage(itemInfo.icon_1 or itemInfo.icon)
				self._itemSprite:setTexture(imageTexture)

			end
		end

		if itemInfo and (itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE or itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE) then
				
			local quality = itemInfo.gemstone_quality 
			if quality then
				local aptitudeInfo = {}
			    for _,value in ipairs(HERO_SABC) do
			        if value.aptitude ==  quality then
			            aptitudeInfo = value
			        end
			    end
				self._qualityWidget = QUIWidgetQualitySmall.new()
				
				self._qualityWidget:setScale(0.7)
			
				self._qualityWidget:setQuality(aptitudeInfo.lower)
				-- self._qualityWidget:setContentSize(30, 40)

				-- self._qualityWidget:setVisible(true)
				if aptitudeInfo.lower == "a+" then
					self._nameRichText:setString({
					{oType = "node", node = self._qualityWidget,offset=ccp(-30,0)},
					{oType = "font", content = itemInfo.name,size = 26,color = UNITY_COLOR.yellow,strokeColor=QIDEA_STROKE_COLOR}
					})

				else
					self._nameRichText:setString({
					{oType = "node", node = self._qualityWidget,offset=ccp(-15,0)},
					{oType = "font", content = itemInfo.name,size = 26,color = UNITY_COLOR.yellow,strokeColor=QIDEA_STROKE_COLOR}
					})

				end
				
			else
			
				self._nameRichText:setString({{oType = "font", content = itemInfo.name,size = 26,color = UNITY_COLOR.yellow,strokeColor=QIDEA_STROKE_COLOR}})

			end
		else
		
			self._nameRichText:setString({{oType = "font", content = itemInfo.name,size = 26,color = UNITY_COLOR.yellow,strokeColor=QIDEA_STROKE_COLOR}})
			
		end

		self._itemSprite:setVisible(true)
		node = self._itemSprite
	end

	makeNodeCascadeOpacityEnabled(node, true)
	node:setOpacity(0)
   	node:runAction(CCFadeIn:create(1))
 

  	self._ccbOwner.effect_node:removeAllChildren()
   	-- self._heroEffect = QUIWidgetAnimationPlayer.new()
    -- self._ccbOwner.effect_node:addChild(self._heroEffect)
    -- self._heroEffect:playAnimation("ccb/effects/WineGodLight_di.ccbi")

    if self._schedulerID2 then
		scheduler.unscheduleGlobal(self._schedulerID2)
	end
	self._schedulerID2 = scheduler.performWithDelayGlobal(function()
			self._itemPos = self._itemPos + 1
			self._itemPos = self._itemPos > itemsCount and 1 or self._itemPos

		    local fadeOut = CCFadeOut:create(1)
		    local callFunc = CCCallFunc:create(function()
				self:setCenterItemInfomation()
		    end)
		    local fadeAction = CCArray:create()
		   	fadeAction:addObject(fadeOut)
		    fadeAction:addObject(callFunc)
		    node:runAction(CCSequence:create(fadeAction))

		end, 3)
end

function QUIDialogActivityTurntable:_confirmCallBack()

	self:removeBackEvent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page:setScalingVisible(false)
	page.topBar:showWithActivityTurntable()
	self:addBackEvent(false)
	-- self:_dataChange()
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
end
--describe：
function QUIDialogActivityTurntable:_onTriggerBuyOne()
	--代码
	if not remote.activityRounds:getTurntable().isActivityNotEnd then
		app.tip:floatTip("活动已结束，敬请期待下次活动")
		return
	end

	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.TURN_TABLE)
	if self._itemNum >= 1 or self._data.isFree or isShowDialog == false then
		self:buyItem(1, false)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = 41, buyNum = 1, price = self._data.onePrice, buyType = DAILY_TIME_TYPE.TURN_TABLE, callback = function()
				if self:_checkMoney(self._data.onePrice) == true then
					self:buyItem(1, false)
				end
			end}}, {isPopCurrentDialog = false})
	end
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBuyTen()
	--代码
	if not remote.activityRounds:getTurntable().isActivityNotEnd then
		app.tip:floatTip("活动已结束，敬请期待下次活动")
		return
	end
	
	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.TURN_TABLE)
	if self._itemNum >= 10 or isShowDialog == false then
		self:buyItem(10, true)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = 41, buyNum = 10, price = self._data.tenPrice, buyType = DAILY_TIME_TYPE.TURN_TABLE, callback = function()
				if self:_checkMoney(self._data.tenPrice) == true then
					self:buyItem(10, true)
				end
			end}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogActivityTurntable:_checkMoney(cost)
	if remote.user.token < cost then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return false
	end
	return true
end


function QUIDialogActivityTurntable:buyItem(count, isTen)
	local oldHeros = clone(remote.herosUtil:getHaveHero())
	remote.activityRounds:getTurntable():buyItems(count, function(data)
		if self.class ~= nil then
			if data.userLuckyDrawDirectionalInfo then
		        remote.activityRounds:getTurntable():updateSelfInfo(data.userLuckyDrawDirectionalInfo)
		    end
		    local callback = handler(self, self._onTriggerBuyOne)
		    if isTen then
		    	callback = handler(self, self._onTriggerBuyTen)
		    end
			remote.items:getRewardItemsTips(data.prizes, oldHeros, self._itemNum, callback, 
				ITEM_TYPE.TURN_TABLE_CARD, nil, TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE, handler(self, self._confirmCallBack))
			
		end
	end)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerRank()
	--代码
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityTurntableRank", 
        options = {rowNum = self._data.rowNum}})
end

--describe：
function QUIDialogActivityTurntable:_onTriggerRule()
	--代码
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityTurntableHelp", 
        options = {}})

end


function QUIDialogActivityTurntable:setScoresBarProgress(  )
	-- body
	local boxNum = 10
	local curScore = (self._data.curScore or 0)
	local progress = 0
	if curScore < self._data.maxScore then
		for k, v in pairs(self._data.boxData) do
			if curScore <= v.score then
				if k > 1 then
					progress = (k-1)/boxNum + ((curScore - self._data.boxData[k-1].score)/(v.score - self._data.boxData[k-1].score))*(1.0/boxNum)
				else		
					progress = (curScore/v.score)*(1.0/boxNum)	
				end
				break		
			end
		end
	else
		progress = 1
	end

	self.scoresBarMask:setScaleX(progress)
end


function QUIDialogActivityTurntable:_addScoresBarMaskLayer(ccb, mask)
    local width = ccb:getContentSize().width * ccb:getScaleX()
    local height = ccb:getContentSize().height * ccb:getScaleY()
    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0))
    maskLayer:setPosition(ccp(0, 0))

    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccb:setPosition(ccp(0, 0))
    ccclippingNode:addChild(ccb)
    ccb:release()

    mask:addChild(ccclippingNode)
    return maskLayer
end



--describe：
function QUIDialogActivityTurntable:_onTriggerBox1(event)
	if self._ccbOwner.node_close1:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close1) == false then return end
	end
	if self._ccbOwner.node_open1:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open1) == false then return end
	end
	app.sound:playSound("battle_starbox")
	
	self:triggerBoxbyId(1)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox2(event)
	if self._ccbOwner.node_close2:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close2) == false then return end
	end
	if self._ccbOwner.node_open2:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open2) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(2)

end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox3(event)
	if self._ccbOwner.node_close3:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close3) == false then return end
	end
	if self._ccbOwner.node_open3:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open3) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(3)
end



--describe：
function QUIDialogActivityTurntable:_onTriggerBox4(event)
	if self._ccbOwner.node_close4:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close4) == false then return end
	end
	if self._ccbOwner.node_open4:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open4) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(4)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox5(event)
	if self._ccbOwner.node_close5:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close5) == false then return end
	end
	if self._ccbOwner.node_open5:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open5) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(5)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox6(event)
	if self._ccbOwner.node_close6:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close6) == false then return end
	end
	if self._ccbOwner.node_open6:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open6) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(6)
end



--describe：
function QUIDialogActivityTurntable:_onTriggerBox7(event)
	if self._ccbOwner.node_close7:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close7) == false then return end
	end
	if self._ccbOwner.node_open7:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open7) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(7)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox8(event)
	if self._ccbOwner.node_close8:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close8) == false then return end
	end
	if self._ccbOwner.node_open8:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open8) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(8)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox9(event)
	if self._ccbOwner.node_close9:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close9) == false then return end
	end
	if self._ccbOwner.node_open9:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open9) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(9)
end

--describe：
function QUIDialogActivityTurntable:_onTriggerBox10(event)
	if self._ccbOwner.node_close10:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_close10) == false then return end
	end
	if self._ccbOwner.node_open10:isVisible() then
		if q.buttonEvent(event, self._ccbOwner.node_open10) == false then return end
	end
	app.sound:playSound("battle_starbox")
	self:triggerBoxbyId(10)
end

function QUIDialogActivityTurntable:_onTriggerHeroIntroduce(event)
	app.sound:playSound("common_small")
	if self._actorId and self._dungeon_monster_tips then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
			options = {bossId = self._actorId, enemyTips = self._dungeon_monster_tips}})
	else
		app.tip:floatTip("三哥，当前主题不是魂师哦～")
	end
end

--describe：关闭对话框
function QUIDialogActivityTurntable:close( )
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogActivityTurntable:viewAnimationOutHandler()
	--代码
end

function QUIDialogActivityTurntable:viewDidAppear()
	QUIDialogActivityTurntable.super.viewDidAppear(self)

	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.TURNTABLE_UPDATE, function (  )
		-- body
		self._dataDirty = true
	end)

	self:addBackEvent(false)
	--代码
end



function QUIDialogActivityTurntable:viewWillDisappear()
	QUIDialogActivityTurntable.super.viewWillDisappear(self)
	if self._schedulerID then
		scheduler.unscheduleGlobal(self._schedulerID)
	end
	if self._schedulerID2 then
		scheduler.unscheduleGlobal(self._schedulerID2)
	end
	self:removeBackEvent()

	self._activityRoundsEventProxy:removeAllEventListeners()
	self._activityRoundsEventProxy = nil
	--代码
end

--describe：返回键事件处理
function QUIDialogActivityTurntable:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end



--describe：viewAnimationInHandler 
--function QUIDialogActivityTurntable:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
--function QUIDialogActivityTurntable:_backClickHandler()
	----代码
--end

return QUIDialogActivityTurntable
