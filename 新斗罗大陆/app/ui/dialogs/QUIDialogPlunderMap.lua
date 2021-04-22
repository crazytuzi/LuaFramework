--
-- Author: Kumo.Wang
-- Date: 
-- 宗门战一级主场景
--
local QUIDialog = import(".QUIDialog")
local QUIDialogPlunderMap = class("QUIDialogPlunderMap", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QUIWidgetPlunderNormalMap = import("..widgets.QUIWidgetPlunderNormalMap")
local QUIWidgetPlunderSeniorMap = import("..widgets.QUIWidgetPlunderSeniorMap")
local QUIWidgetPlunderCave = import("..widgets.QUIWidgetPlunderCave")
local QUIWidgetPlunderIcon = import("..widgets.QUIWidgetPlunderIcon")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogPlunderMap:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_map.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},

		{ccbCallbackName = "onTriggerSelectPage", callback = handler(self, self._onTriggerSelectPage)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerAutoFind", callback = handler(self, self._onTriggerAutoFind)},
		{ccbCallbackName = "onTriggerMineInfo", callback = handler(self, self._onTriggerMineInfo)},
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
	}
	QUIDialogPlunderMap.super.ctor(self, ccbFile, callBacks, options)

	remote.plunder:plunderGetMyInfoRequest()
	remote.plunder:plunderGetCaveListRequest(PAGE_NUMBER.ONE)

	-- if not app:isNativeLargerEqualThan(1, 2, 1) then
	-- 	self._ccbOwner.tf_mine_info_title = setShadow5(self._ccbOwner.tf_mine_info_title)
	-- 	self._ccbOwner.tf_no_mine_title = setShadow5(self._ccbOwner.tf_no_mine_title)
	-- 	self._ccbOwner.tf_no_mine = setShadow5(self._ccbOwner.tf_no_mine)
	-- end

	self:_init(options)

	self:checkRankChangeInfo()
end

function QUIDialogPlunderMap:viewDidAppear()
    QUIDialogPlunderMap.super.viewDidAppear(self)
    self:addBackEvent()

    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))

    self.plunderProxy = cc.EventProxy.new(remote.plunder)
    self.plunderProxy:addEventListener(remote.plunder.NEW_DAY, handler(self, self._updatePlunderHandler))
    self.plunderProxy:addEventListener(remote.plunder.MY_INFO_UPDATE, handler(self, self._updatePlunderHandler))
    self.plunderProxy:addEventListener(remote.plunder.CAVE_UPDATE, handler(self, self._updatePlunderHandler))

	self:_selectPage()
    remote.plunder:setIsNeedShowMineId( 0 )

    if remote.plunder.needInvestClock or app:getUserOperateRecord():isFirstInPlunderToday() then
    	if app:getUserOperateRecord():isFirstInPlunderToday() then
    		remote.plunder:addInvestClock()
    	end
    	app:getUserOperateRecord():recordeInPlunder()
    	local index, investInfo = remote.plunder:getCurInvestIndex()
    	-- print("QUIDialogPlunderMap:viewDidAppear() clock ", index, remote.plunder:getMyScore(), investInfo[index][2])
    	if index > 0 then
	    	if remote.plunder.needInvestClock or tonumber(remote.plunder:getMyScore()) >= tonumber(investInfo[index][2]) then
	    		app:getAlarmClock():deleteAlarmClock(remote.plunder.CLOCK..index)
	    		app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderInvest"}, {isPopCurrentDialog = false})
	    	end
	    end
    end
end

function QUIDialogPlunderMap:viewWillDisappear()
    QUIDialogPlunderMap.super.viewWillDisappear(self)
	self:removeBackEvent()

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    self.plunderProxy:removeAllEventListeners()

    if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	
	remote.plunder:setIsNeedShowMineId( 0 )
end

function QUIDialogPlunderMap:viewAnimationInHandler()
end

function QUIDialogPlunderMap:_updatePlunderHandler( event )
	if event.name == remote.plunder.NEW_DAY then
		self:_updateInfo()
	elseif event.name == remote.plunder.MY_INFO_UPDATE then
		self:_updatePage()
		self:_updateInfo()
		self:_updateMyOccupy()
	elseif event.name == remote.plunder.CAVE_UPDATE then
		self:_updatePage()
		self:_updateMyOccupy()
	end
end

function QUIDialogPlunderMap:_init(options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible()
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setScalingVisible(false)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(false)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 	page:setScalingVisible(false)
    page.topBar:showWithPlunder()
    
	self:_madeTouchLayer()

	self._totalWidth = 0 
	self._mapIndex = 0
	self._caveCount = 0
	self._mapWidget = {}
	self._caveWidget = {}
	self._mapContent:setPositionX(0)
	self._ccbOwner.map_content:removeAllChildren()
end

function QUIDialogPlunderMap:_onTriggerSelectPage(event, target)
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkBurstIn() then return end 

	local index = 1
	while true do
		local node = self._ccbOwner["btn_page_"..index]
		if node then
			if target == node then
				remote.plunder:setCurCavePage( index )
				remote.plunder:plunderGetCaveListRequest(index, function(response)
						if response.kuafuMineGetCaveListResponse and table.nums(response.kuafuMineGetCaveListResponse) > 0 then
							self:_selectPage()
						else
							app.tip:floatTip("魂师大人，这块魂兽区尚未开放")
						end
					end)
			end
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogPlunderMap:_onTriggerRule()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkUnionState() then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderHelp", options = {}})
end

function QUIDialogPlunderMap:_onTriggerAward()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkUnionState() then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlunderAwards"})
end

function QUIDialogPlunderMap:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkBurstIn() then return end 

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionPlunder"}})
end

function QUIDialogPlunderMap:_onTriggerMineInfo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_mine_info) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkBurstIn() then return end 

	local myMineId = remote.plunder:getMyMineId()
	local caveConfig = remote.plunder:getCaveConfigByMineId(myMineId)
	if caveConfig and table.nums(caveConfig) > 0 then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", options = {caveId = caveConfig.cave_id, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, myMineId = myMineId}})
	end
end

function QUIDialogPlunderMap:_onTriggerAutoFind(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_auto_find) == false then return end
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkBurstIn() then return end 
	
	remote.plunder:plunderQuickFindLootMineRequest(self:safeHandler(function(response)
			local mineId = response.kuafuMineQuickFindLootMineResponse.mineId
			if mineId == 0 then
				-- 后端没找到符合要求的魂兽区
				app.tip:floatTip("魂师大人，未找到适合掠夺的魂兽区，请手动查找")
				return
			end
			local recommendMineId = mineId
			local caveConfig = remote.plunder:getCaveConfigByMineId(mineId)
			if caveConfig and table.nums(caveConfig) > 0 then
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", options = {caveId = caveConfig.cave_id, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, recommendMineId = recommendMineId}})
			end
		end))
end

function QUIDialogPlunderMap:_onTriggerRank()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkUnionState() then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderRank"}, {isPopCurrentDialog = false})
end

function QUIDialogPlunderMap:_onTriggerRecord()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkUnionState() then return end
	self._ccbOwner.sp_record_tips:setVisible(false)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderBattleReport"}, 
		{isPopCurrentDialog = false})
end

function QUIDialogPlunderMap:_onTriggerShop()
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkUnionState() then return end
	remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIDialogPlunderMap:_onEvent(event)
	app.sound:playSound("common_small")
	if self._isMove == true then return end
	if remote.plunder:checkBurstIn() then return end 

    if event.name == QUIWidgetPlunderCave.EVENT_OK then
    	local maxMineId = remote.plunder:getMaxMineId()
	    if maxMineId then
	    	local maxCaveId = remote.plunder:getCaveIdByMineId( maxMineId )
	    	if tonumber(maxCaveId) < tonumber(event.caveId) then
	    		app.tip:floatTip("魂师大人，这块巢穴尚未开放")
	    		return
	    	end
	    end
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", options = {caveId = event.caveId, caveRegion = event.caveRegion, caveName = event.caveName}})
    end
end

--根据页码变动显示内容
function QUIDialogPlunderMap:_selectPage()
	if self._curPage ~= nil and self._curPage ~= remote.plunder:getCurCavePage() then
    	self._totalWidth = 0
    	self._mapIndex = 0
    	self._caveCount = 0
    	self._mapWidget = {}
    	self._caveWidget = {}
    	self._mapContent:setPositionX(0)
    	self._ccbOwner.map_content:removeAllChildren()
	end
	
	self._curPage = remote.plunder:getCurCavePage()

	self:resetAllPageBtn()
	local node = self._ccbOwner["btn_page_"..self._curPage]
	if node then
		node:setTouchEnabled(false)
		node:setHighlighted(true)
	else
		app.tip:floatTip("没有找到第"..self._curPage.."页码")
		return
	end

	self:_initPage()
	self:_initInfo()
end

function QUIDialogPlunderMap:resetAllPageBtn()
	local index = 1
	while true do
		local node = self._ccbOwner["btn_page_"..index]
		if node then
			node:setTouchEnabled(true)
			node:setHighlighted(false)
			index = index + 1
		else
			break
		end
	end
end

--根据级别显示巢穴地图
function QUIDialogPlunderMap:_initPage()
	self._caveData = remote.plunder:getCaveConfigByCaveRegion(self._curPage)

	self._offsie_width = UI_VIEW_MIN_WIDTH - display.ui_width
	self._offsie_width = self._offsie_width * 0.5
	local options = self:getOptions()
	local initCaveId, initCaveConfig
	if options.mineId then
		initCaveId = math.floor(options.mineId/10)
		self:getOptions().mineId = nil
	end

	for index, value in pairs(self._caveData) do
		if index > self._caveCount * self._mapIndex then
			self._mapIndex = self._mapIndex + 1
			local mapWidget = nil

			if self._curPage == PAGE_NUMBER.ONE then
				mapWidget = QUIWidgetPlunderSeniorMap.new()
			elseif self._curPage == PAGE_NUMBER.TWO then
				mapWidget = QUIWidgetPlunderNormalMap.new()
			-- elseif self._curPage == PAGE_NUMBER.THREE then
			-- 	mapWidget = QUIWidgetPlunderNormalMap.new()
			-- elseif self._curPage == PAGE_NUMBER.FOUR then
			-- 	mapWidget = QUIWidgetPlunderNormalMap.new()
			-- elseif self._curPage == PAGE_NUMBER.FIVE then
			-- 	mapWidget = QUIWidgetPlunderNormalMap.new()
			end

			if not mapWidget then return end

			self._ccbOwner.map_content:addChild(mapWidget)

			if self._mapIndex == 1 then
				--mapWidget:setPositionX(0)
				mapWidget:setPositionX(self._offsie_width)
			else
				local widget = self._mapWidget[self._mapIndex - 1]
				mapWidget:setPositionX(widget:getPositionX() + widget:getMaxWidth() + self._offsie_width)
			end

			self._totalWidth = self._totalWidth + mapWidget:getMaxWidth()
			if self._caveCount == 0 then
				self._caveCount = mapWidget:getCaveCount()
			end
			self._mapWidget[self._mapIndex] = mapWidget
		end

		local widget = QUIWidgetPlunderCave.new(value)
		widget:addEventListener(QUIWidgetPlunderCave.EVENT_OK, handler(self, self._onEvent))
		self._caveWidget[value.cave_id] = widget
		self._mapWidget[self._mapIndex]:myAddChild(widget, index - self._caveCount * (self._mapIndex - 1))

		if initCaveId == value.cave_id then
			initCaveConfig = value
		end
	end

	self._totalWidth = self._totalWidth - self._mapWidget[self._mapIndex]:getOffsetWidth()

	self:_updatePage()

	if q.isEmpty(initCaveConfig) == false then
		self:_onEvent({name = QUIWidgetPlunderCave.EVENT_OK, caveId = initCaveConfig.cave_id, caveName = initCaveConfig.cave_name, caveRegion = initCaveConfig.cave_region})
	end
end

function QUIDialogPlunderMap:_updatePage()
	for _, widget in pairs(self._caveWidget) do
		widget:update()
	end
end

function QUIDialogPlunderMap:_initInfo()
	self:_updateInfo()
	self:_updateMyOccupy()
end

function QUIDialogPlunderMap:_updateInfo()
	local lootCnt = remote.plunder:getLootCnt()
	self._ccbOwner.tf_attack_count:setString(lootCnt)
	
	local buyCount = remote.plunder:getBuyLootCnt()
	local totalVIPNum = QVIPUtil:getCountByWordField("gh_ykz_ld_times", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("gh_ykz_ld_times")
	self._ccbOwner.btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
	self._ccbOwner.btn_plus_expand:setVisible(totalVIPNum > totalNum or totalNum > buyCount)

	self._ccbOwner.tf_my_score:setString(remote.plunder:getMyScore())
	self._ccbOwner.tf_society_score:setString(remote.plunder:getConsortiaScore())
	local myRank = remote.plunder:getMyRank()
	if myRank == 0 then
		self._ccbOwner.tf_my_rank:setString("（未上榜）")
	else
		self._ccbOwner.tf_my_rank:setString("（第"..myRank.."名）")
	end
	local societyRank = remote.plunder:getConsortiaRank()
	if societyRank == 0 then
		self._ccbOwner.tf_society_rank:setString("（未上榜）")
	else
		self._ccbOwner.tf_society_rank:setString("（第"..societyRank.."名）")
	end

	self._ccbOwner.tf_my_rank:setPositionX( self._ccbOwner.tf_my_score:getPositionX() + self._ccbOwner.tf_my_score:getContentSize().width )
	self._ccbOwner.tf_society_rank:setPositionX( self._ccbOwner.tf_society_score:getPositionX() + self._ccbOwner.tf_society_score:getContentSize().width )

	-- -- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)

	self:checkRedTip()
end

function QUIDialogPlunderMap:checkRedTip()
	-- print("[Kumo] QUIDialogPlunderMap:checkRedTip() ", remote.plunder.isRecordRedTip)
	self._ccbOwner.sp_award_tips:setVisible(false)
	self._ccbOwner.sp_record_tips:setVisible(false)
	
	if remote.plunder:checkPersonalAwardTips() or remote.plunder:checkUnionAwardTips() then
		self._ccbOwner.sp_award_tips:setVisible(true)
	end

	if remote.plunder.isRecordRedTip then
		self._ccbOwner.sp_record_tips:setVisible(true)
	end
end

function QUIDialogPlunderMap:_updateMyOccupy()
	local myMineId = remote.plunder:getMyMineId()
	if not myMineId or myMineId == 0 then 
		self._ccbOwner.node_no_mine:setVisible(true)
		self._ccbOwner.node_mine_info:setVisible(false)
		return 
	end
	self._ccbOwner.node_no_mine:setVisible(false)
	self._ccbOwner.node_mine_info:setVisible(true)

	--icon
	local mineConfig = remote.plunder:getMineConfigByMineId(myMineId)
	local quality = mineConfig.mine_quality
	local icon = QUIWidgetPlunderIcon.new({quality = quality, isNoEvent = true})
	self._ccbOwner.node_mine_icon:removeAllChildren()
	self._ccbOwner.node_mine_icon:addChild(icon)
	icon:setScale(0.5)

	-- buff
	self._ccbOwner.node_buff_up:setVisible(false)
	self._ccbOwner.sp_buff_up_3:setVisible(false)
	self._ccbOwner.sp_buff_up_4:setVisible(false)
	self._ccbOwner.sp_buff_up_5:setVisible(false)
	self._ccbOwner.node_btn_mineInfo:setPositionX(110)
	local caveConfig = remote.plunder:getCaveConfigByMineId(myMineId)
	if caveConfig and table.nums(caveConfig) > 0 then
		local isBuff, member, consortiaId = remote.plunder:getSocietyBuffInfoByCaveId(caveConfig.cave_id)
		if isBuff and consortiaId == remote.plunder:getMyConsortiaId() then
			self._ccbOwner.node_buff_up:setVisible(true)
			self._ccbOwner.tf_buff_num:setString(member.."人")
			self._ccbOwner.node_btn_mineInfo:setPositionX(150)
			self._ccbOwner["sp_buff_up_"..member]:setVisible(true)
		end
	end
end

function QUIDialogPlunderMap:_madeTouchLayer()
	self._size = self._ccbOwner.node_mask:getContentSize()
	self._pageWidth = self._size.width
	self._pageHeight = self._size.height
	self._mapContent = self._ccbOwner.node_map
    CalculateBattleUIPosition(self._ccbOwner.node_offside , true)

	self._touchLayer = QUIGestureRecognizer.new()
	self._touchLayer:setSlideRate(0.3)
	self._touchLayer:setAttachSlide(true)
    self._touchLayer:attachToNode(self._ccbOwner.map_touchLayer, self._size.width, self._size.height, -self._size.width/2, -self._size.height/2, handler(self, self._onTouchEvent))
end

function QUIDialogPlunderMap:_onTouchEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:_moveTo(event.distance.x, true, true)
  	elseif event.name == "began" then
  		self:_removeAction()
  		self._startX = event.x
  		self._pageX = self._mapContent:getPositionX()
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
    	scheduler.performWithDelayGlobal(function ()
    		self._isMove = false
    		end,0)
    end
end

function QUIDialogPlunderMap:_moveTo(posX, isAnimation, isCheck)
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
		return 
	end
	self:_contentRunAction(targetX, 0)
end

function QUIDialogPlunderMap:_removeAction()
	if self._actionHandler ~= nil then
		self._mapContent:stopAction(self._actionHandler)		
		self._actionHandler = nil
	end
end

function QUIDialogPlunderMap:_contentRunAction(posX, posY)
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

function QUIDialogPlunderMap:_updateTime()
	local timeStr, color, isActive = remote.plunder:updateTime()
	if isActive then
		self._ccbOwner.tf_time_title:setString("结束倒计时：")
		self._ccbOwner.tf_time_title:setPositionX(-112.4)
		q.autoLayerNode({self._ccbOwner.tf_time_title, self._ccbOwner.tf_countdown}, "x")
	else
		self._ccbOwner.tf_time_title:setString("极北之地已结束")
		self._ccbOwner.tf_time_title:setPositionX(3.6)
	end
	self._ccbOwner.tf_countdown:setColor( color )
	self._ccbOwner.tf_countdown:setString(timeStr)
end

function QUIDialogPlunderMap:checkRankChangeInfo()
	remote.userDynamic:openDynamicDialog(4, function(isConfirm)
			if self:safeCheck() then
				if isConfirm then
					self:_onTriggerMineInfo()
				end
			end
		end)
end

function QUIDialogPlunderMap:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogPlunderMap:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogPlunderMap:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlunderMap:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogPlunderMap