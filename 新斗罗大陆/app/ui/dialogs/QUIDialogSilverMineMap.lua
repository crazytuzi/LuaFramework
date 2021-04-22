--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林一级主场景
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSilverMineMap = class("QUIDialogSilverMineMap", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QUIWidgetSilverMineNormalMap = import("..widgets.QUIWidgetSilverMineNormalMap")
local QUIWidgetSilverMineSeniorMap = import("..widgets.QUIWidgetSilverMineSeniorMap")
local QUIWidgetSilverMineCave = import("..widgets.QUIWidgetSilverMineCave")
local QUIWidgetSilverMineIcon = import("..widgets.QUIWidgetSilverMineIcon")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")

function QUIDialogSilverMineMap:ctor(options)
	local ccbFile = "ccb/Dialog_SilverMine_Map.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerChest", callback = handler(self, self._onTriggerChest)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
		{ccbCallbackName = "onTriggerSenior", callback = handler(self, self._onTriggerSenior)},
		{ccbCallbackName = "onTriggerLevelInfo", callback = handler(self, self._onTriggerLevelInfo)},
		{ccbCallbackName = "onTriggerAutoFind", callback = handler(self, self._onTriggerAutoFind)},
		{ccbCallbackName = "onTriggerMineInfo", callback = handler(self, self._onTriggerMineInfo)},
		{ccbCallbackName = "onTriggerAssist", callback = handler(self, self._onTriggerAssist)},
		{ccbCallbackName = "onTriggerGoldPickaxe", callback = handler(self, self._onTriggerGoldPickaxe)},
		{ccbCallbackName = "onTriggerOneHelp", callback = handler(self, self._onTriggerOneHelp)},
	}
	QUIDialogSilverMineMap.super.ctor(self, ccbFile, callBacks, options)

	self._ccbOwner.tf_mine_info_title = setShadow5(self._ccbOwner.tf_mine_info_title)
    self._ccbOwner.tf_no_mine_title = setShadow5(self._ccbOwner.tf_no_mine_title)
    self._ccbOwner.tf_no_mine = setShadow5(self._ccbOwner.tf_no_mine)
    self._ccbOwner.tf_level_title = setShadow5(self._ccbOwner.tf_level_title)
    self._ccbOwner.tf_level_up_title = setShadow5(self._ccbOwner.tf_level_up_title)
    self._ccbOwner.tf_mine_time = setShadow5(self._ccbOwner.tf_mine_time)
    
    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
	self._totalStencilWidth = self._ccbOwner.sp_progress:getContentSize().width * self._ccbOwner.sp_progress:getScaleX()

	self:_init(options)
    CalculateBattleUIPosition(self._ccbOwner.map_content , true)

	self:checkRankChangeInfo()

	remote.silverMine:silvermineGetMyInfoRequest()
	local silverType = options.silverType or SILVERMINEWAR_TYPE.SENIOR
	remote.silverMine:silvermineGetCaveListRequest(silverType, function()
			if self:safeCheck() then
				self:checkAssistTips()
			end
		end)
end

function QUIDialogSilverMineMap:viewDidAppear()
    QUIDialogSilverMineMap.super.viewDidAppear(self)
    self:addBackEvent()

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))

    self.silverMineProxy = cc.EventProxy.new(remote.silverMine)
    self.silverMineProxy:addEventListener(remote.silverMine.NEW_DAY, handler(self, self._updateSilverMineHandler))
    self.silverMineProxy:addEventListener(remote.silverMine.MY_INFO_UPDATE, handler(self, self._updateSilverMineHandler))
    self.silverMineProxy:addEventListener(remote.silverMine.CAVE_UPDATE, handler(self, self._updateSilverMineHandler))
    self.silverMineProxy:addEventListener(remote.silverMine.CAVE_LIST_UPDATE, handler(self, self._updateSilverMineHandler))
    self.silverMineProxy:addEventListener(remote.silverMine.BUY_GOLDPICKAXE, handler(self, self._updateSilverMineHandler))
    self.silverMineProxy:addEventListener(remote.silverMine.SILVER_ASSIST_UPDATE, handler(self, self._updateAssistInfo))

    self._ccbOwner.node_effect:setVisible(false)

	if not app.unlock:checkLock("UNLOCK_FORESET_QUICK_HELP", false) then
		self._ccbOwner.node_oneHelp:setVisible(false)
	else
		self._ccbOwner.node_oneHelp:setVisible(true)
		self._ccbOwner.node_oneHelp_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_FORESET_QUICK_HELP"..remote.user.userId))
	end

	self:_selectType()
	
    self:checkTutorial()

    remote.silverMine:setIsNeedShowMineId( 0 )
end

function QUIDialogSilverMineMap:viewWillDisappear()
    QUIDialogSilverMineMap.super.viewWillDisappear(self)
	self:removeBackEvent()

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    self.silverMineProxy:removeAllEventListeners()

    if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	if self._moveHandler ~= nil then
		scheduler.unscheduleGlobal(self._moveHandler)
		self._moveHandler = nil
	end
	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
	
	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	remote.silverMine:setIsNeedShowMineId( 0 )
end

function QUIDialogSilverMineMap:viewAnimationInHandler()
	if remote.silverMine:getIsNeedShowAward() and remote.silverMine:checkSilverMineAwardRedTip() then
		remote.silverMine:setIsNeedShowAward( false )
		self:_onTriggerAward()
	end
end

function QUIDialogSilverMineMap:_updateSilverMineHandler( event )
	if event.name == remote.silverMine.NEW_DAY then
		self:_updateInfo()
	elseif event.name == remote.silverMine.MY_INFO_UPDATE then
		self:_updatePage()
		self:_updateInfo()
		self:_updateMyOccupy()
	elseif event.name == remote.silverMine.CAVE_UPDATE then
		self:_updatePage()
		self:_updateMyOccupy()
	elseif event.name == remote.silverMine.CAVE_LIST_UPDATE then
		self:_updatePage()
		self:_updateMyOccupy()
	elseif event.name == remote.silverMine.BUY_GOLDPICKAXE then
		self._ccbOwner.sp_goldPickaxe_tips:setVisible(false)
	end
end

function QUIDialogSilverMineMap:_init(options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible() end
	if page.setScalingVisible then page:setScalingVisible(false) end

	self._initTotalExpScaleX = self._ccbOwner.sp_progress:getScaleX()

	self:_madeTouchLayer()

	self._totalWidth = 0 
	self._mapIndex = 0
	self._caveCount = 0
	self._mapWidget = {}
	self._caveWidget = {}
	self._mapContent:setPositionX(0)
	self._ccbOwner.map_content:removeAllChildren()

	self:initAssistTips()
end

function QUIDialogSilverMineMap:initAssistTips()
    local ccbi = "effects/xiezhu_paopao_1.ccbi" 

	local leftProxy = CCBProxy:create()
	local leftOwner = {onTriggerAssistOK = function() self:_onTriggerAssistLeft() end}
    self._leftAssistTip = CCBuilderReaderLoad(ccbi, leftProxy, leftOwner)
    leftOwner.node_bg:setScaleX(-1)
    self._ccbOwner.node_left_assist_tip:addChild(self._leftAssistTip)

    local rightProxy = CCBProxy:create()
	local rightOwner = {onTriggerAssistOK = function() self:_onTriggerAssistRight() end}
    self._rightAssistTip = CCBuilderReaderLoad(ccbi, rightProxy, rightOwner)
    self._ccbOwner.node_right_assist_tip:addChild(self._rightAssistTip)

    self._leftAssistTip:setVisible(false)
    self._rightAssistTip:setVisible(false)
end

function QUIDialogSilverMineMap:checkTutorial()
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		page:buildLayer()
		local haveTutorial = false
		if app.tutorial:getStage().silver == app.tutorial.Guide_Start and app.unlock:getUnlockSilverMine() then
			haveTutorial = true
     	    app.tutorial:startTutorial(app.tutorial.Stage_SilverMine)
		end
		if haveTutorial == false then
			page:cleanBuildLayer()
		end
	end
end

-- 拖动屏幕结束后检测协助气泡是否在显示区域内
function QUIDialogSilverMineMap:checkAssistTips()
	self._leftAssistTip:setVisible(false)
    self._rightAssistTip:setVisible(false)	

    -- 没有协助次数了
	if remote.silverMine.assistCount <= 0 then
		return
	end

    local assistInfo = remote.silverMine:getMineAssistInfo()
	local curPosX = self._mapContent:getPositionX()
	for _, assist in pairs(assistInfo) do
		local caveId = assist.caveId
		if self._caveWidget[caveId] then
			local mapIndex, index = self._caveWidget[caveId]:getIndex()
			local mapPosX = self._mapWidget[mapIndex]:getPositionX()
			local posX = self._mapWidget[mapIndex]:getCavePosByIndex(index)+mapPosX
			if posX ~= 0 then
				if posX+curPosX < 0 then
					self._leftAssistTip:setVisible(true)
				end
				if posX+curPosX > display.width then
					self._rightAssistTip:setVisible(true)
				end
			end
		end
	end
end

function QUIDialogSilverMineMap:_onTriggerNormal()
	app.sound:playSound("common_small")
	if self._isMove == true then return end

	self:getOptions().silverType = SILVERMINEWAR_TYPE.NORMAL
	remote.silverMine:setCurCaveType( SILVERMINEWAR_TYPE.NORMAL )
	remote.silverMine:silvermineGetCaveListRequest(SILVERMINEWAR_TYPE.NORMAL, function()
			if self:safeCheck() then
				self:checkAssistTips()
			end
		end)
	self:_selectType()
end

function QUIDialogSilverMineMap:_onTriggerSenior()
	app.sound:playSound("common_small")
	if self._isMove == true then return end

	self:getOptions().silverType = SILVERMINEWAR_TYPE.SENIOR
	remote.silverMine:setCurCaveType( SILVERMINEWAR_TYPE.SENIOR )
	remote.silverMine:silvermineGetCaveListRequest(SILVERMINEWAR_TYPE.SENIOR)
	self:_selectType()
end

function QUIDialogSilverMineMap:_onTriggerRule()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMineRule"})
end

function QUIDialogSilverMineMap:_onTriggerChest()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", options = {tab = "GEMSTONE_TYPE"}})
end

function QUIDialogSilverMineMap:_onTriggerShop()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIDialogSilverMineMap:_onTriggerAward(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_report) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineAwardAndRecord", options = {caveRegion = self._caveType}})
end

function QUIDialogSilverMineMap:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
		options = {cls = "QBuyCountSilverMine"}})
end

function QUIDialogSilverMineMap:_onTriggerLevelInfo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_level_info) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	local x, y = self._ccbOwner.node_info:getPosition()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineLevelTips", options = {x = x, y = y}})
end

function QUIDialogSilverMineMap:_onTriggerMineInfo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_mine_info) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if not self._hasMyOccupy then return end
	local myOccupy = remote.silverMine:getMyOccupy()
	local myMineId = myOccupy.mineId
	local caveConfig = remote.silverMine:getCaveConfigByMineId(myMineId)
	if caveConfig and table.nums(caveConfig) > 0 then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", options = {caveId = caveConfig.cave_id, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, myMineId = myMineId}})
	end
end

function QUIDialogSilverMineMap:_onTriggerAutoFind(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_auto_find) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	remote.silverMine:silvermineQuickFindMineRequest(self:safeHandler(function(response)
			local caveId = response.silverMineQuickFindMineResponse.caveId
			local recommendMineId = response.silverMineQuickFindMineResponse.mineId
			local caveConfig = remote.silverMine:getCaveConfigByCaveId(caveId)
			if caveConfig and table.nums(caveConfig) > 0 then
				local myOccupy = remote.silverMine:getMyOccupy()
				if myOccupy and table.nums(myOccupy) > 0 then
					-- 自己有魂兽区的时候，需要判断找到的新魂兽区是不是比自己的好
					-- local myMine = remote.silverMine:getMineConfigByMineId( myOccupy.mineId )
					-- if myMine.mine_quality == SILVERMINE_TYPE.DIAMOND then
					-- 	app.tip:floatTip("魂师大人，当前您所狩猎的魂兽区已经是最高品质了")
					-- 	return
					-- elseif caveConfig.cave_quality <= myMine.mine_quality then
					-- 	app.tip:floatTip("魂师大人，当前未找到比您所狩猎品质更高的魂兽区，请稍后再试试吧")
					-- 	return
					-- end
					if myOccupy.mineId == recommendMineId then
						app.tip:floatTip("魂师大人，未找到比您当前所狩猎收益更高的魂兽区，建议稍后再试试哦~")
						return
					end
				end
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", options = {caveId = caveConfig.cave_id, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, recommendMineId = recommendMineId}})
			end
		end))
end

function QUIDialogSilverMineMap:_onTriggerAssistLeft()
	print("-------_onTriggerAssistLeft------")
	local assistInfo = remote.silverMine:getMineAssistInfo()
	local curPosX = self._mapContent:getPositionX()
	for _, assist in pairs(assistInfo) do
		local caveId = assist.caveId
		if self._caveWidget[caveId] then
			local mapIndex, index = self._caveWidget[caveId]:getIndex()
			local mapPosX = self._mapWidget[mapIndex]:getPositionX()
			local posX = self._mapWidget[mapIndex]:getCavePosByIndex(index)+mapPosX
			if posX ~= 0 then
				if posX+curPosX < 0 then
					local offsetX = -posX + display.width/2
					if offsetX < -(self._totalWidth - self._pageWidth) then
						offsetX = -(self._totalWidth - self._pageWidth)
					elseif offsetX > 0 then
						offsetX = 0
					end
					self:_moveTo(offsetX, true)
					return
				end
			end
		end
	end
end

function QUIDialogSilverMineMap:_onTriggerAssistRight()
	print("-------_onTriggerAssistRight------")
	local assistInfo = remote.silverMine:getMineAssistInfo()
	local curPosX = self._mapContent:getPositionX()
	for _, assist in pairs(assistInfo) do
		local caveId = assist.caveId
		if self._caveWidget[caveId] then
			local mapIndex, index = self._caveWidget[caveId]:getIndex()
			local mapPosX = self._mapWidget[mapIndex]:getPositionX()
			local posX = self._mapWidget[mapIndex]:getCavePosByIndex(index)+mapPosX
			if posX ~= 0 then
				if posX+curPosX > display.width then
					local offsetX = -posX + display.width/2
					if offsetX < -(self._totalWidth - self._pageWidth) then
						offsetX = -(self._totalWidth - self._pageWidth)
					elseif offsetX > 0 then
						offsetX = 0
					end
					self:_moveTo(offsetX, true)
					return
				end
			end
		end
	end
end

-- 协助邀请
function QUIDialogSilverMineMap:_onTriggerAssist(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_assist) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	local myConsortiaId = remote.silverMine:getMyConsortiaId() 
	if myConsortiaId and myConsortiaId ~= "" then
		remote.silverMine:silverMineGetInviteListRequest(function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineAssist",
				options = {fighters = data.silverMineGetInviteListResponse.consortiaMemberList}})
		end)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineAssist",
			options = {fighters = {}}})
	end
end

-- 一键协助
function QUIDialogSilverMineMap:_onTriggerOneHelp(event)
	app.sound:playSound("common_small")

	if not app:getUserData():getValueForKey("UNLOCK_FORESET_QUICK_HELP"..remote.user.userId) then
		app:getUserData():setValueForKey("UNLOCK_FORESET_QUICK_HELP"..remote.user.userId, "true")
        self._ccbOwner.node_oneHelp_effect:setVisible(false)
	end
	
	if q.buttonEventShadow(event, self._ccbOwner.bt_oneHelp) == false then return end
	if self._isMove == true then return end
	-- body
	if remote.silverMine.assistCount <= 0 then
		app.tip:floatTip("魂师大人，您目前没有协助次数~")
		return
	end
	local assisNum = remote.silverMine:getMineAssistNum()
	if assisNum <= 0 then
		app.tip:floatTip("魂师大人，您目前没有可以协助狩猎的玩家哦~")
		return
	end

	remote.silverMine:silverMineOneKeyAssist(function(data)
		if self:safeCheck() then
			if data.silverMineOneKeyAssistResponse and data.silverMineOneKeyAssistResponse.silverMineAssistResponses then
				self:showAssistAnimation(data.silverMineOneKeyAssistResponse.silverMineAssistResponses)
	
				self:_updateAssistInfo()
			end
		end
	end)
end

function QUIDialogSilverMineMap:showAssistAnimation(assistResponses)
	local index = 1
	local animationFunc
	animationFunc = function()
		if assistResponses[index] and assistResponses[index].targetOccupy then
			local width = q.wordLen("协助成功"..(assistResponses[index].targetOccupy.ownerName or "").."获得5%协助加成", 38, 38)
			local richText = QRichText.new({
	            {oType = "font", content = "协助成功", size = 34,color = COLORS.a, strokeColor = COLORS.Y},
	            {oType = "font", content = assistResponses[index].targetOccupy.ownerName or "", size = 34,color = COLORS.M, strokeColor = COLORS.Y},
	            {oType = "font", content = "获得5%协助加成", size = 34,color = COLORS.a, strokeColor = COLORS.Y},
	        }, width)
	        richText:setOpacity(0)
	        richText:setAnchorPoint(ccp(0.5, 0))
			self._ccbOwner.node_assist_tips:addChild(richText)

			local time = 0.4
			local array1 = CCArray:create()
			array1:addObject(CCMoveBy:create(time, ccp(0,50)))
			array1:addObject(CCFadeTo:create(time, 255))
			local array3 = CCArray:create()
			array3:addObject(CCMoveBy:create(time, ccp(0,50)))
			array3:addObject(CCFadeTo:create(time, 0))
			local array2 = CCArray:create()
			array2:addObject(CCSpawn:create(array1))
			array2:addObject(CCSpawn:create(array3))
			array2:addObject(CCCallFunc:create(function()
				richText:removeFromParent()
		    end))					
			richText:runAction(CCSequence:create(array2))
			index = index + 1
			self._timeScheduler = scheduler.performWithDelayGlobal(animationFunc, 0.1)
		end
	end
	animationFunc()
end

-- 诱魂草
function QUIDialogSilverMineMap:_onTriggerGoldPickaxe()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	remote.flag:set(remote.flag.FLAG_FRIST_GOLDPICKAXE, 1)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverBuyVirtual"})
	self._ccbOwner.node_effect:setVisible(false)
	remote.silverMine:setIsFirstGoldPickaxe(false)
	self._ccbOwner.sp_goldPickaxe_tips:setVisible(false)
end

function QUIDialogSilverMineMap:_onTriggerRank()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "sliverMine"}}, {isPopCurrentDialog = false})
end

function QUIDialogSilverMineMap:_onEvent(event)
	if self._isMove == true then return end
	app.sound:playSound("common_small")
    if event.name == QUIWidgetSilverMineCave.EVENT_OK then
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", options = {caveId = event.caveId, caveRegion = event.caveRegion, caveName = event.caveName}})
    elseif event.name == QUIWidgetSilverMineCave.EVENT_ASSIST then
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMine", options = {caveId = event.caveId, caveRegion = event.caveRegion, caveName = event.caveName, isAssist = event.isAssist}})
    end
end

function QUIDialogSilverMineMap:updateUnionHandler( event )
	if event.name == remote.union.NEW_DAY then
		self._isRefresh = true
		self:_selectType()
	end
end

--根据副本类型显示副本内容
function QUIDialogSilverMineMap:_selectType()
	if self._caveType ~= nil and self._caveType ~= remote.silverMine:getCurCaveType() then
    	self._totalWidth = 0
    	self._mapIndex = 0
    	self._caveCount = 0
    	self._mapWidget = {}
    	self._caveWidget = {}
    	self._mapContent:setPositionX(0)
    	self._ccbOwner.map_content:removeAllChildren()
	end
	self._caveType = remote.silverMine:getCurCaveType()

	if self._caveType == SILVERMINEWAR_TYPE.SENIOR then
		self._ccbOwner.btn_normal:setTouchEnabled(true)
		self._ccbOwner.btn_normal:setHighlighted(false)
		self._ccbOwner.btn_senior:setTouchEnabled(false)
		self._ccbOwner.btn_senior:setHighlighted(true)
		self._ccbOwner.ccb_senior:setVisible(true)
	elseif self._caveType == SILVERMINEWAR_TYPE.NORMAL then
		self._ccbOwner.btn_normal:setTouchEnabled(false)
		self._ccbOwner.btn_normal:setHighlighted(true)
		self._ccbOwner.btn_senior:setTouchEnabled(true)
		self._ccbOwner.btn_senior:setHighlighted(false)
		self._ccbOwner.ccb_senior:setVisible(false)
	end

	self:_initPage()
	self:_initInfo()
end

--根据级别显示巢穴地图
function QUIDialogSilverMineMap:_initPage()
	self._caveData = remote.silverMine:getCaveConfigByCaveRegion(self._caveType)

	local options = self:getOptions()
	local initCaveId, initCaveConfig
	if options.mineId then
		initCaveId = math.floor(options.mineId/10)
		self:getOptions().mineId = nil
	end
	
	local caveNum = 1
	for index, value in pairs(self._caveData) do
		if index > self._caveCount * self._mapIndex then
			caveNum = 1
			self._mapIndex = self._mapIndex + 1
			local mapWidget = nil

			if self._caveType == SILVERMINEWAR_TYPE.SENIOR then
				mapWidget = QUIWidgetSilverMineSeniorMap.new()
			elseif self._caveType == SILVERMINEWAR_TYPE.NORMAL then
				mapWidget = QUIWidgetSilverMineNormalMap.new()
			end

			if not mapWidget then return end

			self._ccbOwner.map_content:addChild(mapWidget)

			if self._mapIndex == 1 then
				mapWidget:setPositionX(0)
			else
				local widget = self._mapWidget[self._mapIndex - 1]
				mapWidget:setPositionX(widget:getPositionX() + widget:getMaxWidth())
			end

			self._totalWidth = self._totalWidth + mapWidget:getMaxWidth()
			if self._caveCount == 0 then
				self._caveCount = mapWidget:getCaveCount()
			end
			self._mapWidget[self._mapIndex] = mapWidget
		end

		local widget = QUIWidgetSilverMineCave.new(value)
		widget:addEventListener(QUIWidgetSilverMineCave.EVENT_OK, handler(self, self._onEvent))
		widget:addEventListener(QUIWidgetSilverMineCave.EVENT_ASSIST, handler(self, self._onEvent))
		widget:setIndex(self._mapIndex, caveNum)
		caveNum = caveNum + 1
		self._caveWidget[value.cave_id] = widget
		self._mapWidget[self._mapIndex]:myAddChild(widget, index - self._caveCount * (self._mapIndex - 1))

		if initCaveId == value.cave_id then
			initCaveConfig = value
		end
	end

	self._totalWidth = self._totalWidth - self._mapWidget[self._mapIndex]:getOffsetWidth()

	remote.flag:get({remote.flag.FLAG_FRIST_GOLDPICKAXE}, function (tbl)
				if tbl[remote.flag.FLAG_FRIST_GOLDPICKAXE] == "" then
					self._ccbOwner.node_effect:setVisible(true)
				end
			end)

	self:_updatePage()

	if q.isEmpty(initCaveConfig) == false then
		self:_onEvent({name = QUIWidgetSilverMineCave.EVENT_OK, caveId = initCaveConfig.cave_id, caveName = initCaveConfig.cave_name, caveRegion = initCaveConfig.cave_region})
	end
end

function QUIDialogSilverMineMap:_updatePage()
	for _, widget in pairs(self._caveWidget) do
		widget:update()
	end
end

function QUIDialogSilverMineMap:_initInfo()
	self:_updateInfo()
	self:_updateMyOccupy()
	self:_updateAssistInfo()
end

function QUIDialogSilverMineMap:_updateAssistInfo()
	self._ccbOwner.node_assist_tip:setVisible(false)
	self._ccbOwner.sp_oneHelp_tips:setVisible(false)
	local assistNum = remote.silverMine:getMineAssistNum()
	if self._caveType == SILVERMINEWAR_TYPE.SENIOR then
		if assistNum == 1 or assistNum == 3 then
			self._ccbOwner.node_assist_tip:setVisible(true)
			self._ccbOwner.node_assist_tip:setPositionY(135)
		end 
	else
		if assistNum == 2 or assistNum == 3 then
			self._ccbOwner.node_assist_tip:setVisible(true)
			self._ccbOwner.node_assist_tip:setPositionY(195)
		end 
	end
	
	if assistNum > 0 then
		self._ccbOwner.sp_oneHelp_tips:setVisible(true)
	end

    self:checkAssistTips()
end

function QUIDialogSilverMineMap:_updateInfo()
	self._ccbOwner.node_assist:setVisible(false)
	-- 奖励小红点
	if remote.silverMine:checkSilverMineAwardRedTip() or remote.silverMine:getIsRecordRedTip() then
		self._ccbOwner.sp_award_tips:setVisible(true)
	else
		self._ccbOwner.sp_award_tips:setVisible(false)
	end
	-- 商店小红点
	if remote.silverMine:checkSilverMineShopRedTip() then
		self._ccbOwner.sp_shop_tips:setVisible(true)
	else
		self._ccbOwner.sp_shop_tips:setVisible(false)
	end
	-- 诱魂草小红点
	if remote.silverMine:checkSilverMineGoldPickaxeRedTip() then
		self._ccbOwner.sp_goldPickaxe_tips:setVisible(true)
	else
		self._ccbOwner.sp_goldPickaxe_tips:setVisible(false)
	end

	local itemInfo
	local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
	if shopItems ~= nil then
		for i, v in pairs(shopItems) do
			if v.id == GEMSTONE_SHOP_ID then
				itemInfo = v
				break
			end
		end
	end
	self._ccbOwner.tf_sale:setVisible(false)
	self._ccbOwner.sp_chest_tips:setVisible(false)
	if itemInfo ~= nil then
		local chestSale = remote.stores:getSaleByShopItemInfo(itemInfo, true)
		if chestSale == 0 then
			self._ccbOwner.sp_chest_tips:setVisible(true)
		elseif chestSale <= 1.7 then
			self._ccbOwner.tf_sale:setVisible(true)
			self._ccbOwner.tf_sale:setString(chestSale.."折")
		end
	end

	local count = remote.silverMine:getFightCount()
	self._ccbOwner.tf_attack_count:setString(count)

	local totalVIPNum = QVIPUtil:getCountByWordField("silvermine_limit", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("silvermine_limit")	
	if totalVIPNum > totalNum or totalNum > remote.silverMine:getBuyFightCount() then
		self._ccbOwner.node_btn_plus:setVisible(true)
		self._ccbOwner.btn_plus:setEnabled(true)
		self._ccbOwner.btn_plus_expand:setEnabled(true)
	else
		self._ccbOwner.node_btn_plus:setVisible(false)
		self._ccbOwner.btn_plus:setEnabled(false)
		self._ccbOwner.btn_plus_expand:setEnabled(false)
	end
	self._ccbOwner.tf_level:setString("LV."..remote.silverMine:getMiningLv())

	local levelConfig = remote.silverMine:getLevelConfigByLevel( remote.silverMine:getMiningLv() )
	self._ccbOwner.tf_money_up:setString("+"..levelConfig.money_output.."%")
	self._ccbOwner.tf_silvermineMoney_up:setString("+"..levelConfig.silvermineMoney_output.."%")

	self._ccbOwner.tf_money_up:setPositionX(self._ccbOwner.sp_money:getPositionX() + 23)
	self._ccbOwner.sp_silvermineMoney:setPositionX(self._ccbOwner.tf_money_up:getPositionX() + self._ccbOwner.tf_money_up:getContentSize().width +23)
	self._ccbOwner.tf_silvermineMoney_up:setPositionX(self._ccbOwner.sp_silvermineMoney:getPositionX() + 23)


	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
	self:_updateGoldPickaxeTime()
	self._goldPickaxeScheduler = scheduler.scheduleGlobal(self:safeHandler(function() 
			self:_updateGoldPickaxeTime()
		end), 1)

	self:_updateExp()
end

function QUIDialogSilverMineMap:_updateMyOccupy()
	local myOccupy = remote.silverMine:getMyOccupy()
	if not myOccupy or table.nums(myOccupy) == 0 then 
		self._ccbOwner.node_assist:setVisible(false)
		-- print("[Kumo] _updateMyOccupy() 没有狩猎")
		self._isOvertime = false
		self._hasMyOccupy = false
		self._ccbOwner.node_no_mine:setVisible(true)
		self._ccbOwner.node_mine_info:setVisible(false)
		if remote.silverMine:getFightCount() > 0 then
			self._ccbOwner.sp_autoFind_tips:setVisible(true)
		end
		return 
	end
	--显示邀请协助按钮
	self._ccbOwner.node_assist:setVisible(true)
	self._ccbOwner.sp_assist_tips:setVisible(remote.silverMine:checkSilverMineAssistRedTip())
	
	self._ccbOwner.sp_autoFind_tips:setVisible(false)
	self._isOvertime = false
	self._hasMyOccupy = true
	self._ccbOwner.node_no_mine:setVisible(false)
	self._ccbOwner.node_mine_info:setVisible(true)

	local myMineId = myOccupy.mineId
	local startTime = myOccupy.startAt
	local endTime = myOccupy.endAt

	--icon
	local mineConfig = remote.silverMine:getMineConfigByMineId(myMineId)
	local quality = mineConfig.mine_quality
	local icon = QUIWidgetSilverMineIcon.new({quality = quality, isNoEvent = true})
	self._ccbOwner.node_mine_icon:removeAllChildren()
	self._ccbOwner.node_mine_icon:addChild(icon)
	icon:setScale(0.5)

	-- buff
	self._ccbOwner.node_buff_up:setVisible(false)
	self._ccbOwner.sp_buff_up_3:setVisible(false)
	self._ccbOwner.sp_buff_up_4:setVisible(false)
	self._ccbOwner.sp_buff_up_5:setVisible(false)
	self._ccbOwner.node_time:setPositionX(-40)
	local caveConfig = remote.silverMine:getCaveConfigByMineId(myMineId)
	if caveConfig and table.nums(caveConfig) > 0 then
		local isBuff, member, consortiaId = remote.silverMine:getSocietyBuffInfoByCaveId(caveConfig.cave_id)
		print("[Kumo] QUIDialogSilverMineMap:_updateMyOccupy() ", isBuff, member, consortiaId, remote.silverMine:getMyConsortiaId(), caveConfig.cave_id)
		if isBuff and consortiaId == remote.silverMine:getMyConsortiaId() then
			self._ccbOwner.node_buff_up:setVisible(true)
			self._ccbOwner.tf_buff_num:setString(member.."人")
			self._ccbOwner.node_time:setPositionX(0)
			self._ccbOwner["sp_buff_up_"..member]:setVisible(true)
		end
	end
	
	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIDialogSilverMineMap:_updateExp()
	local exp = remote.silverMine:getMiningExp()
	local levelConfig = remote.silverMine:getLevelConfigByLevel( remote.silverMine:getMiningLv() + 1 )
	local stencil = self._percentBarClippingNode:getStencil()
	if not levelConfig then
		-- 说明已经满级了，没有下一级的config。
    	stencil:setPositionX(-self._totalStencilWidth + 1*self._totalStencilWidth)
		return
	end

	local maxExp = levelConfig.exp
	local percent = exp / maxExp
	stencil:setPositionX(-self._totalStencilWidth + percent*self._totalStencilWidth)
end

function QUIDialogSilverMineMap:_madeTouchLayer()
	self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = self._size.width
	self._pageHeight = self._size.height
	self._mapContent = self._ccbOwner.node_map

	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer, self._size.width, self._size.height, -self._size.width/2, -self._size.height/2, handler(self, self._onTouchEvent))
end

function QUIDialogSilverMineMap:_onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:_moveTo(event.distance.x, true, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startX = event.x
  		self._pageX = self._mapContent:getPositionX()
  		-- print("start pageX :", self._mapContent:getPositionX())
    elseif event.name == "moved" then
    	local offsetX = self._pageX + event.x - self._startX
        if math.abs(event.x - self._startX) > 10 then
            self._isMove = true
        end
		if self._totalWidth > self._pageWidth then
			if offsetX < -(self._totalWidth - self._pageWidth) then
				offsetX = -(self._totalWidth - self._pageWidth)
			elseif offsetX > 0 then
				offsetX = 0
			end
			self:_moveTo(offsetX, false)
		end
	elseif event.name == "ended" then
		self._timeHandler = scheduler.performWithDelayGlobal(function()
        	self._isMove = false
		end, 0)
		-- self:checkAssistTips()
		-- print("end pageX :", self._mapContent:getPositionX())
    end
end

function QUIDialogSilverMineMap:_moveTo(posX, isAnimation, isCheck)
	local targetX = posX
	if isCheck == true then
		local contentX = self._mapContent:getPositionX()
		if self._totalWidth <= self._pageWidth then
			targetX = 0
		elseif contentX + posX < -(self._totalWidth - self._pageWidth) then
			targetX = -(self._totalWidth - self._pageWidth)
		elseif contentX + posX > 0 then
			targetX = 0
		else
			targetX = contentX + posX
		end
	end
	if isAnimation == false then
		self._mapContent:setPositionX(targetX)
		self:checkAssistTips()
		return 
	end
	self:_contentRunAction(targetX, 0)
end

function QUIDialogSilverMineMap:_removeAction()
	if self._actionHandler ~= nil then
		self._mapContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
	self:checkAssistTips()
end

function QUIDialogSilverMineMap:_contentRunAction(posX, posY)
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(0.5, ccp(posX, posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
			self:_removeAction()
        end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = self._mapContent:runAction(ccsequence)
end

function QUIDialogSilverMineMap:_updateTime()
	if not self._hasMyOccupy then
		-- print("[Kumo] _updateTime() 没有狩猎")
		self._isOvertime = false
		self._ccbOwner.node_no_mine:setVisible(true)
		self._ccbOwner.node_mine_info:setVisible(false)
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end
	end

	local isOvertime, timeStr, color = remote.silverMine:updateTime( true, nil )
	self._ccbOwner.tf_mine_time:setColor( color )

	if isOvertime then
		-- print("[Kumo] _updateTime() 过时了")
		self._isOvertime = true
		self._ccbOwner.tf_mine_time:setString("结算中")
		local myOccupy = remote.silverMine:getMyOccupy()
		if not myOccupy or table.nums(myOccupy) == 0 then 
			-- print("[Kumo] _updateTime() 没有狩猎")
			self._isOvertime = false
			self._hasMyOccupy = false
			self._ccbOwner.node_no_mine:setVisible(true)
			self._ccbOwner.node_mine_info:setVisible(false)
		end
		
		return
	end
	self._ccbOwner.tf_mine_time:setString(timeStr)
end

function QUIDialogSilverMineMap:_updateGoldPickaxeTime()
	local isOvertime, timeStr, color = remote.silverMine:updateGoldPickaxeTime(true)
	if isOvertime then
		-- self._ccbOwner.tf_goldPickaxe_time:setString("00:00:00")
		self._ccbOwner.tf_goldPickaxe_time:setString("")
	else
		self._ccbOwner.tf_goldPickaxe_time:setString(timeStr)
	end
	self._ccbOwner.tf_goldPickaxe_time:setColor( color )
end

function QUIDialogSilverMineMap:checkRankChangeInfo()
	remote.userDynamic:openDynamicDialog(3, function(isConfirm)
			if self:safeCheck() then
				if isConfirm then
					local myOccupy = remote.silverMine:getMyOccupy()
					if myOccupy and table.nums(myOccupy) > 0 then 
						self:_onTriggerMineInfo()
					end
				end
			end
		end)
end

function QUIDialogSilverMineMap:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogSilverMineMap:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogSilverMineMap:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSilverMineMap:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogSilverMineMap