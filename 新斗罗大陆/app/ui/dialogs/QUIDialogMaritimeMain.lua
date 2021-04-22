-- @Author: xurui
-- @Date:   2016-12-24 11:08:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-04 15:28:24
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeMain = class("QUIDialogMaritimeMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetShipBox = import("..widgets.QUIWidgetShipBox")
local QMaritimeDefenseArrangement = import("...arrangement.QMaritimeDefenseArrangement")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QChatData = import("...models.chatdata.QChatData")

local maxShipCount = 30

function QUIDialogMaritimeMain:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang_z.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerTransport", callback = handler(self, self._onTriggerTransport)},
		{ccbCallbackName = "onTriggerShipInfo", callback = handler(self, self._onTriggerShipInfo)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
		{ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerAwards", callback = handler(self, self._onTriggerAwards)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},  
        {ccbCallbackName = "onTriggerEscort",	callback = handler(self,self._onTriggerEscort)}, 
        {ccbCallbackName = "onTriggerRecord", callback = handler(self,self._onTriggerRecord)},
	}
	QUIDialogMaritimeMain.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setManyUIVisible then page:setManyUIVisible() end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
    if page and page.topBar then
        page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MONEY})
    end
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    if options then
    	self._isShowAwards = options.isShowAwards
    end

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._robberyNum = configuration["maritime_plunder"].value

	self._ships = {}
	self._myShipInfo = {}
	self._shipInfo = {}
	self._fadeOutAnimation = {}
	self._fadeInAnimation = {}

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()

	self:initShipBox()	
end

function QUIDialogMaritimeMain:viewDidAppear()
	QUIDialogMaritimeMain.super.viewDidAppear(self)

    self._maritimeProxy = cc.EventProxy.new(remote.maritime)
    self._maritimeProxy:addEventListener(remote.maritime.EVENT_UPDATE_ROBBERY_NUM, handler(self, self.setRobberyNum))

	self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))

	self:addBackEvent(false)
	
	self:setMyInfo()
	self:setShipInfo()

	local haveTutorial = self:_checkTutorial()

	if not haveTutorial then
		remote.maritime.startShipId = 2
		if remote.maritime:checkAwardsTips() and self._isShowAwards then
			self:_onTriggerAwards({isQuick = true}, true)
		else
	    	self:checkRankChangeInfo()
		end
		self:getOptions().isShowAwards = false
	end
end

function QUIDialogMaritimeMain:viewWillDisappear()
	QUIDialogMaritimeMain.super.viewWillDisappear(self)

	if self._positionScheduler then
		scheduler.unscheduleGlobal(self._positionScheduler)
		self._positionScheduler = nil
	end

	for i = 1, #self._ships do
		if self._fadeOutAnimation[i] ~= nil then 
			self._ships[i].ship:stopAction(self._fadeOutAnimation[i])
			self._fadeOutAnimation[i] = nil
		end
		if self._fadeInAnimation[i] ~= nil then 
			self._ships[i].ship:stopAction(self._fadeInAnimation[i])
			self._fadeInAnimation[i] = nil
		end
	end
	if self._myShipScheduler then
		scheduler.unscheduleGlobal(self._myShipScheduler)
		self._myShipScheduler = nil
	end

	for i = 1, #self._ships do
		if self._ships[i] then
			self._ships[i].ship:removeFromParent()
			self._ships[i].ship = nil
			self._ships[i] = nil
		end
	end

    self._maritimeProxy:removeAllEventListeners()
    self._maritimeProxy = nil

	self._chatDataProxy:removeAllEventListeners()
	self._chatDataProxy = nil

	self:removeBackEvent()
end

function QUIDialogMaritimeMain:_checkTutorial()
    local haveTutorial = false

	if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        if app.tutorial:getStage().maritimeTop == app.tutorial.Guide_Start then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_Maritime_Top)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end

    return haveTutorial
end

function QUIDialogMaritimeMain:initShipBox()
	for i = 1, 31 do
		self._ships[i] = {}
		self._ships[i].ship = QUIWidgetShipBox.new()
		self._ccbOwner.ly_ship_space:addChild(self._ships[i].ship)
		self._ships[i].ship:addEventListener(QUIWidgetShipBox.EVENT_CLICK, handler(self, self._clickShip))
		self._ships[i].positionX = 0
		self._ships[i].positionY = 0
	end

	--左下角聊天室按钮
	self.widgetChat = QUIWidgetChat.new({state = QUIWidgetChat.STATE_ALL})
	self.widgetChat:setPosition(54, 44)
	self.widgetChat:setChatAreaVisible(false)
	self._ccbOwner.node_chat:addChild(self.widgetChat)
	self.widgetChat:checkPrivateChannelRedTips()
end

function QUIDialogMaritimeMain:_onMessageReceived(event)
	local lastChatMsg = {}
	if not app.battle and event.channelId and event.channelId ~= app:getServerChatData():teamChannelId() then
		lastChatMsg = {from = event.from, message = event.message, delayed = event.delayed, misc = event.misc, channelId = event.channelId}
	end
	if self.widgetChat and q.isEmpty(lastChatMsg) == false then
		self.widgetChat:updatePage(lastChatMsg)
		self.widgetChat:checkPrivateChannelRedTips()
	end
end

function QUIDialogMaritimeMain:setMyInfo()
	self._myInfo = remote.maritime:getMyMaritimeInfo()
	if next(self._myInfo) == nil then return end

	self._ccbOwner.tf_today_money:setString(self._myInfo.score or "")

	local force1 = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.MARITIME_DEFEND_TEAM1, false)
	local force2 = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.MARITIME_DEFEND_TEAM2, false)
	local force = force1 + force2
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
	local num, word = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(num..(word or ""))
	local color = string.split(fontInfo.force_color, ";")
	self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)

	local myShipInfo = remote.maritime:getMyShipInfo()
	self._ccbOwner.sp_ship_icon:setVisible(false)
	self._ccbOwner.tf_last_time_content:setVisible(false)
	-- self._ccbOwner.tf_last_time:setPositionX(170)
	if next(myShipInfo) == nil then 
		self._ccbOwner.btn_ship_info:setVisible(false)
		self._ccbOwner.tf_last_time_content:setString("当前没有运送仙品")
		self._ccbOwner.tf_last_time_content:setVisible(true)
		self._ccbOwner.tf_last_time:setVisible(false)
		-- self._ccbOwner.tf_last_time:setPositionX(115)
	else
		local shipFrame = QResPath("maritime_ship_frame")[myShipInfo.shipId]
    	shipFrame = QSpriteFrameByPath(shipFrame)
		if shipFrame then
			self._ccbOwner.sp_ship_icon:setDisplayFrame(shipFrame)
			self._ccbOwner.sp_ship_icon:setScale(0.3)
		end
		self._ccbOwner.btn_ship_info:setVisible(true)
		self._ccbOwner.sp_ship_icon:setVisible(true)

		self:myShipScheduler(myShipInfo.endAt/1000)
	end

	self:setRobberyNum()

	if remote.maritime:checkIsDoubleTime() then
		self._ccbOwner.tf_double_tip:setColor(UNITY_COLOR_LIGHT.yellow)
	end
end

function QUIDialogMaritimeMain:setRobberyNum()
	local myInfo = remote.maritime:getMyMaritimeInfo()
	local robberyNum = self._robberyNum + (myInfo.buyLootCnt or 0) - (myInfo.lootCnt or 0)
	robberyNum = robberyNum < 0 and 0 or robberyNum
	self._ccbOwner.bf_robbery_num:setString(robberyNum or "")

    local buyCount = myInfo.buyLootCnt or 0
	local totalVIPNum = QVIPUtil:getCountByWordField("maritime_plunder", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("maritime_plunder")
	self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogMaritimeMain:myShipScheduler(endTime)
	if self._myShipScheduler then
		scheduler.unscheduleGlobal(self._myShipScheduler)
		self._myShipScheduler = nil
	end

	if endTime - q.serverTime() > 0 then
		local date = q.timeToHourMinuteSecond(endTime - q.serverTime())
		self._ccbOwner.tf_last_time:setString(date or "")
		self._myShipScheduler = scheduler.performWithDelayGlobal(function ()
			self:myShipScheduler(endTime)
		end, 1)
	else
		self:myShipIsDone()
	end
end

function QUIDialogMaritimeMain:setShipInfo()
	for i = 1, #self._ships do
		self._ships[i].ship:setVisible(false)
		self._ships[i].shipInfo = nil
		self._ships[i].ship:setOpacity(255)
	end

	self:getShipData()

	self:initShipPosition()

	self:setPositionScheduler()

	self:checkRedTips()
end

function QUIDialogMaritimeMain:getShipData()
	self._myShipInfo = clone(remote.maritime:getMyShipInfo())
	self._shipInfo = clone(remote.maritime:getEnemyShipInfo())

	if self._myShipInfo ~= nil and next(self._myShipInfo) ~= nil then
		local num = #self._shipInfo
		num = num <= 1 and 1 or num
		local myShipNum = math.random(1, num)
		table.insert(self._shipInfo, myShipNum, self._myShipInfo)
	end

	for _, value in pairs(self._shipInfo) do
		value.isMy = value.userId == remote.user.userId
	end
end

function QUIDialogMaritimeMain:initShipPosition()
	self._totalWidth = self._ccbOwner.ly_ship_space:getContentSize().width / 1130 * display.ui_width
	self._totalHeight = self._ccbOwner.ly_ship_space:getContentSize().height / 640 * display.ui_height

	for i = 1, #self._shipInfo do
		local positionX = self:getShipPositionX(self._shipInfo[i])
		local positionY = math.random(1, self._totalHeight)
		positionY = self:getShipPositionY(positionX, positionY, -10, positionY)

		if self._ships[i] then
			self._ships[i].positionX = positionX
			self._ships[i].positionY = positionY
			if self._ships[i].ship ~= nil then --and self._ships[i].positionX > 0 then
				self._ships[i].ship:setPosition(ccp(self._ships[i].positionX, self._ships[i].positionY))
				self._ships[i].ship:setShipInfo(self._shipInfo[i], i)
				self._ships[i].ship:setVisible(true)
				self._ships[i].shipInfo = self._shipInfo[i]
				
				self._ships[i].ship:setGrayState(false)
				if remote.maritime:checkCanRobberyShip(self._shipInfo[i]) and self._shipInfo[i].isMy ~= true then
					self._ships[i].ship:setGrayState(true)
				end
			end
		end
	end

	self:sortAllShip()
end

function QUIDialogMaritimeMain:sortAllShip()
	table.sort(self._ships, function(a, b) 
		if a.positionY ~= b.positionY then
			return a.positionY > b.positionY
		else
			return false
		end
	end)

	for i = 1, #self._ships do
		if self._ships[i].ship ~= nil then
			self._ships[i].ship:setZOrder(i)
		end
	end
	QPrintTable(self._ships)
end

function QUIDialogMaritimeMain:getShipPositionX(shipInfo)
	if shipInfo == nil or next(shipInfo) == nil then return self._totalWidth end

	local ships = remote.maritime:getMaritimeShipInfoByShipId(shipInfo.shipId)
	local positionX = 0
	local spendTime = ships.ship_transportation_time * 60
	local realTime = math.ceil(shipInfo.endAt/1000) - math.ceil(shipInfo.startAt/1000)
	if spendTime <= 0 then return self._totalWidth end

	local speed = self._totalWidth/spendTime
	local startPositionY = (spendTime - realTime) * speed
	positionX = startPositionY + speed * (q.serverTime() - math.ceil(shipInfo.startAt/1000))
	return positionX
end

function QUIDialogMaritimeMain:getShipPositionY(positionX, positionY, offsetY, startPositionY)
	local shipWidth = 170
	local shipHeight = 240
	local curPosy = positionY
	if curPosy < 0 then
		curPosy = math.random(1, self._totalHeight) --startPositionY
		offsetY = 120
	elseif curPosy > self._totalHeight then
		curPosy = math.random(1, self._totalHeight)
	end
	for i = 1, #self._ships do
		if self._ships[i].positionX >= positionX-shipWidth/2 and self._ships[i].positionX <= positionX+shipWidth/2 and
			self._ships[i].positionY >= positionY-shipHeight/2 and self._ships[i].positionY <= curPosy+shipHeight/2 then
			curPosy = self:getShipPositionY(positionX, curPosy+offsetY, offsetY, startPositionY)
			break
		end
	end
	return curPosy
end

function QUIDialogMaritimeMain:setPositionScheduler()
	if self._positionScheduler then
		scheduler.unscheduleGlobal(self._positionScheduler)
		self._positionScheduler = nil
	end

	local getShipInfo = function(shipInfo)
		for _, value in pairs(self._shipInfo) do
			if value.userId == shipInfo.userId then
				return value
			end
		end
		return {}
	end

	local updateZOrder = false
	for i = 1, #self._ships do
		if self._ships[i].shipInfo ~= nil then
			local shipInfo = getShipInfo(self._ships[i].shipInfo)
			local positionX = self:getShipPositionX(shipInfo)
			if positionX >= self._totalWidth then
				updateZOrder = true
				self:deleteShip(i)
			else
				self._ships[i].ship:setPositionX(positionX)
			end
		end
	end

	if updateZOrder == false then
		self._positionScheduler = scheduler.performWithDelayGlobal(function ()
				if self:safeCheck() then
					self:setPositionScheduler()
				end
			end, 0)
	end
end

function QUIDialogMaritimeMain:deleteShip(index) 
	makeNodeCascadeOpacityEnabled(self._ships[index].ship, true)
    self._ships[index].ship:setOpacity(255)
	local fadeOut = CCFadeOut:create(0.5)
    local callFunc = CCCallFunc:create(function()
        self._fadeOutAnimation[index] = nil
        self:getNewShip(index)
    end)
    local array = CCArray:create()
    array:addObject(fadeOut)
    array:addObject(callFunc)
	self._fadeOutAnimation[index] = self._ships[index].ship:runAction(CCSequence:create(array))
end

function QUIDialogMaritimeMain:getNewShip(shipIndex)
	local count = maxShipCount - #self._shipInfo + 1
	if self._ships[shipIndex] and self._ships[shipIndex].shipInfo and self._ships[shipIndex].shipInfo.isMy then
		count = count - 1
	end
	if self._ships[shipIndex] ~= nil then
		remote.maritime:removeShipInfo(self._ships[shipIndex].shipInfo)
	end
	self._ships[shipIndex].shipInfo = nil
	self._ships[shipIndex].positionX = 0
	self._ships[shipIndex].positionY = 0
	self._ships[shipIndex].ship:setVisible(false)
	self._ships[shipIndex].ship:setGrayState(false)
	self._ships[shipIndex].ship:setSelectState(false)
	remote.maritime:requestGetNewShip(count, function (data)
		if self:safeCheck() then
			if data.maritimeGetNewShipResponse.shipInfos then
				self:addNewShip(data.maritimeGetNewShipResponse.shipInfos, shipIndex)
			else
				self:setPositionScheduler()
				self:checkRedTips()
			end
		end
	end)

end

function QUIDialogMaritimeMain:addNewShip(data, shipIndex)
	local oldShipNum = #self._shipInfo
	self:getShipData()

	local animaitonIndex = 0
	local setShipInfo = function(index, shipInfo)
		animaitonIndex = animaitonIndex + 1
		self._ships[index].shipInfo = shipInfo
		local positionX = self:getShipPositionX(shipInfo)
		local positionY = math.random(1, self._totalHeight)
		positionY = self:getShipPositionY(positionX, positionY, -10, positionY)
		self._ships[index].positionY = positionY
		self._ships[index].positionX = positionX
		self._ships[index].ship:setPosition(ccp(positionX, positionY))
		self._ships[index].ship:setShipInfo(shipInfo, index)
		self._ships[index].ship:setVisible(true)

		self._ships[index].ship:setOpacity(0)
		local fadeIn = CCFadeIn:create(0.5)
	    local callFunc = CCCallFunc:create(function()
	        self._fadeInAnimation[index] = nil
	        if self:safeCheck() then
				self:setPositionScheduler()
				self:checkRedTips()
			end
	    end)
	    local array = CCArray:create()
	    array:addObject(fadeIn)
	    array:addObject(callFunc)
		self._fadeInAnimation[animaitonIndex] = self._ships[index].ship:runAction(CCSequence:create(array))
	end

	setShipInfo(shipIndex, data[1])

	local index = oldShipNum+1
	for i = 2, #data do
		if self._ships[index] and self._ships[index].ship then
			setShipInfo(index, data[i])
			index = index + 1
		end
	end

	self:sortAllShip()
end

function QUIDialogMaritimeMain:checkRedTips()
	if self:safeCheck() then
		self._ccbOwner.award_tips:setVisible(remote.maritime:checkAwardsTips())
		self._ccbOwner.sp_team_tips:setVisible(remote.maritime:checkTeamIsFull())
		self._ccbOwner.help_tips:setVisible(remote.maritime:checkEscortTips())
		local flagTips = remote.maritime:checkReplayTips() or remote.maritime:checkProjectReplayTips()
		self._ccbOwner.sp_record_tips:setVisible(flagTips)
	end
end


function QUIDialogMaritimeMain:myShipIsDone()
	remote.maritime:requestMaritimeMyInfo(false, function()
		if self:safeCheck() then
			remote.maritime:setMaritimeInfo({myShipInfo = {}})
			self:getShipData()
			self:setMyInfo()

			local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
			if dialog and dialog.class.__cname == "QUIDialogMaritimeShipInfo" then
				app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			end

			self:_onTriggerAwards({}, true)
		end
	end)
end

function QUIDialogMaritimeMain:_clickShip(event)
	if event and event.shipInfo and event.shipInfo.userId then
		local userId = event.shipInfo.userId
		local shipStartAt = event.shipInfo.startAt

		local deleteShip = function()
			for i = 1, #self._ships do
				local shipInfo = self._ships[i].shipInfo
				if shipInfo and shipInfo.userId == userId then
					self:deleteShip(i)
					break
				end
			end
		end
		
		remote.maritime:requestGetMaritimeShipInfo(userId, function(data)
				if self:safeCheck() then
					local shipInfo = data.maritimeQueryShipResponse.shipInfo
					shipInfo.isMy = shipInfo.userId == remote.user.userId
					if shipStartAt and math.abs(shipStartAt - shipInfo.startAt) > 1000 then
						deleteShip()
					else
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaritimeShipInfo", 
							options = {shipInfo = shipInfo, callBack = handler(self, self._shipIsDone), quickCallBack = handler(self, self._quickenSuccess)}})
					end
				end
			end, function(data)
				if data.error == "MARITIME_SHIP_END" then
					if self:safeCheck() then
						deleteShip()
					end
				end
			end)
	end
end

function QUIDialogMaritimeMain:_shipIsDone(shipInfo)
	if shipInfo.isMy then
		self:myShipIsDone()
	end
end

function QUIDialogMaritimeMain:_quickenSuccess()
	if self:safeCheck() then
		self:getShipData()
		self:setMyInfo()
	end
end

function QUIDialogMaritimeMain:checkRankChangeInfo()
	local haveDialog = remote.userDynamic:openDynamicDialog(6, function(isConfirm)
		if self:safeCheck() then
			if isConfirm == false then
				remote.maritime:updateReplayTip(true)
				self:checkRedTips()
			else
				self:_onTriggerRecord({tab = "TAB_PERSONAL_REPLAY"}, true)
			end
		end
	end,7,nil)
end

function QUIDialogMaritimeMain:_teamIsNil()
  	app:alert({content="还未设置战队，无法参加战斗！现在就设置战队？",title="系统提示",callback = function(state)
  		if state == ALERT_TYPE.CONFIRM then
			self:_onTriggerTeam()
		end
  	end, callBack = function ()
	end})
end

function QUIDialogMaritimeMain:_onTriggerTransport(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_transport) == false then return end
	app.sound:playSound("common_small")
	if remote.maritime:checkIsAccountTime() then
		app.tip:floatTip("魂师大人，每天凌晨4:00-5:00无法运送仙品，请稍后再试哦~")
		return 
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaritimeChooseShip"})
end

function QUIDialogMaritimeMain:_onTriggerShipInfo(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_ship_info) == false then return end
	app.sound:playSound("common_small")

	if self._myShipInfo == nil or next(self._myShipInfo) == nil then
		app.tip:floatTip("魂师大人，您还没有开始商运~")
	else
		self:_clickShip({shipInfo = self._myShipInfo})
	end
end

function QUIDialogMaritimeMain:_onTriggerTeam(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_team) == false then return end

	app.sound:playSound("common_small")
	local arenaArrangement1 = QMaritimeDefenseArrangement.new({teamKey = remote.teamManager.MARITIME_DEFEND_TEAM1})
	local arenaArrangement2 = QMaritimeDefenseArrangement.new({teamKey = remote.teamManager.MARITIME_DEFEND_TEAM2})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
		options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})
end

function QUIDialogMaritimeMain:_onTriggerChange(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	if self._isAnimationPlaying == true then
		return
	end

	app.sound:playSound("common_small")
    local proxy = CCBProxy:create()
    local aniCcbOwner = {}
    local aniCcbView = CCBuilderReaderLoad("ccb/Widget_Haishang_Yun.ccbi", proxy, aniCcbOwner)
    self._ccbOwner.node_effect:addChild(aniCcbView)

    self._isAnimationPlaying = true

    self._cloudManager = tolua.cast(aniCcbView:getUserObject(), "CCBAnimationManager")
    self._cloudManager:runAnimationsForSequenceNamed("close")
    self._cloudManager:connectScriptHandler(function(str)
            if str == "close" then
				remote.maritime:requestGetOtherShip(function ()
	            	if self:safeCheck() then
						self:setShipInfo()
						self._cloudManager:runAnimationsForSequenceNamed("open")
					end 
				end)
            elseif str == "open" then
                self._isAnimationPlaying = false
                self._cloudManager = nil
            end
        end)
end

function QUIDialogMaritimeMain:_onTriggerPlus(event)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountMaritimeRobbery"}})
end

function QUIDialogMaritimeMain:_onTriggerAwards(event, isForce)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_award) == false then return end

	app.sound:playSound("common_small")
	local isQuick = false 
	local tab
	if event then
		isQuick = event.isQuick
		tab = event.tab
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMaritimeAwards", 
    	options = {isQuick = isQuick, tab = tab, callBack = handler(self, self.checkRedTips)}})
end

function QUIDialogMaritimeMain:_onTriggerRecord(event, isForce)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_record) == false then return end

	app.sound:playSound("common_small")
	local isQuick = false 
	local tab
	if event then
		isQuick = event.isQuick
		tab = event.tab
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMaritimeRecord", 
    	options = {isQuick = isQuick, tab = "TAB_PERSONAL_REPLAY", callBack = handler(self, self.checkRedTips)}})

end

function QUIDialogMaritimeMain:_onTriggerEscort(event,isForce)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_escort) == false then return end

	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaritimeProtect", 
		options = {openType = "DialogMartimeMain", callBack = handler(self, self.checkRedTips)}})
end

function QUIDialogMaritimeMain:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.MARITIME_DEFEND_TEAM1, teamKey2 = remote.teamManager.MARITIME_DEFEND_TEAM2, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogMaritimeMain:_onTriggerHelp()
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMaritimeHelp"})
end

function QUIDialogMaritimeMain:_onTriggerRank()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
        options = {initRank = "maritime"}})
end

function QUIDialogMaritimeMain:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogMaritimeMain