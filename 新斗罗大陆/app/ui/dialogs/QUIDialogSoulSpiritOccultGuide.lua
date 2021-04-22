-- @Author: liaoxianbo
-- @Date:   2020-02-27 13:30:18
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-12 12:14:22
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritOccultGuide = class("QUIDialogSoulSpiritOccultGuide", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetSoulSpiritFirePoint = import("..widgets.QUIWidgetSoulSpiritFirePoint")
local QUIWidgetSoulFire = import("..widgets.QUIWidgetSoulFire")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUserData = import("...utils.QUserData")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")

local ROTATION_VALUR = {
	{angle=0,  pos = ccp(330,163)},
	{angle=30, pos = ccp(388,143)},
	{angle=65, pos = ccp(420,95)},
	{angle=108,pos = ccp(417,37)},
	{angle=150,pos = ccp(384,-8)},	
	{angle=180,pos = ccp(330,-25)},
	{angle=210,pos = ccp(270,-6)},
	{angle=240,pos = ccp(237,44)},
	{angle=280,pos = ccp(240,102)},
	{angle=330,pos = ccp(275,145)},
}

function QUIDialogSoulSpiritOccultGuide:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Occult_guide.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerUpgrade", callback = handler(self, self._onTriggerUpgrade)},
		{ccbCallbackName = "onTriggerGenre", callback = handler(self, self._onTriggerGenre)},
		{ccbCallbackName = "onTriggerLookOccult", callback = handler(self, self._onTriggerLookOccult)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
    }
    QUIDialogSoulSpiritOccultGuide.super.ctor(self, ccbFile, callBacks, options)
    -- self.isAnimation = true
    CalculateUIBgSize(self._ccbOwner.sp_bg)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithSoulSpiritOccult()

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_genre)
	q.setButtonEnableShadow(self._ccbOwner.btn_check)
	q.setButtonEnableShadow(self._ccbOwner.btn_upgrade)
	q.setButtonEnableShadow(self._ccbOwner.btn_reset)

    self._pageWidth = self._ccbOwner.node_occult_mask:getContentSize().width
    self._pageHeight = self._ccbOwner.node_occult_mask:getContentSize().height
    self._pageContent = self._ccbOwner.node_occult_prop
    self._orginalPosition = ccp(self._pageContent:getPosition())
    self._totalHeight = 170

    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(self._ccbOwner.node_occult_mask:getPositionX())
    layerColor:setPositionY(self._ccbOwner.node_occult_mask:getPositionY())
    ccclippingNode:setStencil(layerColor)
    -- self._pageContent:retain()
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)
	-- self._pageContent:release()
	self._ccbOwner.node_occult_mask:getParent():addChild(ccclippingNode)

    self._pointWidgetList = {}
    self._soulFireWidgetList = {}

    self._isActionEffect = false

    self._treeType = options.treeType or 1
    self._itemId = nil
    self:initPoint()
    self:initSoulFire()

    local bigPoint = 4 --4是是策划定死的初始选中点
    local smallPoint = remote.soulSpirit:getSoulFireActiviteByBigPoint(self._treeType,4)

    local historyBigpoint = app:getUserData():getUserValueForKey(QUserData.SOULSPIRIT_OCCULT_POINT)
    print("historyBigpoint---",historyBigpoint)
    if tonumber(historyBigpoint) then
    	bigPoint = tonumber(historyBigpoint)
    	smallPoint = remote.soulSpirit:getSoulFireActiviteByBigPoint(self._treeType,bigPoint)
    end
    
    self:updateSoulSpiritFire( self._treeType, bigPoint, smallPoint)

    self:checkTutorial()

end

function QUIDialogSoulSpiritOccultGuide:checkTutorial()
    if app.tutorial then
         if app.tutorial:getStage().soulSpiritOccult == app.tutorial.Guide_Second_Start then
			app.tutorial:startTutorial(app.tutorial.Statge_SoulSpiritOccult)
		end
    end
end


function QUIDialogSoulSpiritOccultGuide:viewDidAppear()
	QUIDialogSoulSpiritOccultGuide.super.viewDidAppear(self)
	self:addBackEvent(false)


    local arr = CCArray:create()
    arr:addObject(CCRotateBy:create(36, 360))
    local arrFade = CCArray:create()
    arrFade:addObject(CCFadeTo:create(3, 60))
    -- arrFade:addObject(CCDelayTime:create(1))
    arrFade:addObject(CCFadeTo:create(3, 255))
	self._ccbOwner.sp_fazheng:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	self._ccbOwner.sp_fazheng:runAction(CCRepeatForever:create(CCSequence:create(arrFade)))

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_occult_mask:getParent(),self._pageWidth, self._pageHeight, self._ccbOwner.node_occult_mask:getPositionX(), 
    self._ccbOwner.node_occult_mask:getPositionY(), handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

end

function QUIDialogSoulSpiritOccultGuide:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        -- self._page:endMove(event.distance.y)
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._pageContent:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._orginalPosition.y then
            offsetY = self._orginalPosition.y
        elseif offsetY > (self._totalHeight - self._pageHeight + self._orginalPosition.y) then
            offsetY = (self._totalHeight - self._pageHeight + self._orginalPosition.y)
        else
        end
        self._pageContent:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

function QUIDialogSoulSpiritOccultGuide:viewWillDisappear()
  	QUIDialogSoulSpiritOccultGuide.super.viewWillDisappear(self)
  	self:removeBackEvent()
end

function QUIDialogSoulSpiritOccultGuide:resetAll()
	self._ccbOwner.tf_prop_1:setString("无")
	self._ccbOwner.tf_prop_2:setString("无")

	if remote.soulSpirit:getOneTeamTwoSoulSprit() then
		self._ccbOwner.node_btn_reset:setVisible(false)
	else
		self._ccbOwner.node_btn_reset:setVisible(true)
	end

end

function QUIDialogSoulSpiritOccultGuide:updateBigPointState()
	for _, bigPointWidget in pairs(self._pointWidgetList) do
		bigPointWidget:showState()
	end
end

function QUIDialogSoulSpiritOccultGuide:initSoulFire()
	for ii,v in pairs(ROTATION_VALUR) do
		self._soulFireWidgetList[ii] = QUIWidgetSoulFire.new()
		self._soulFireWidgetList[ii]:setPosition(v.pos)
		-- self._soulFireWidgetList[ii]:setRotation(v.angle)
		self._ccbOwner.node_child_fire:addChild(self._soulFireWidgetList[ii])
	end
end
function QUIDialogSoulSpiritOccultGuide:initPoint( )
	self._pointWidgetList = {}
	self._curIndex = 0
	local bigPoints = remote.soulSpirit:getSoulFireBigPointByTreeType(self._treeType)
	if bigPoints[1] then
		self._ccbOwner.tf_soulspirit_name:setString(bigPoints[1].name)
	end

 	for index, pointInfo in ipairs(bigPoints) do
 		local soulFirePoint = QUIWidgetSoulSpiritFirePoint.new()
 		soulFirePoint:addEventListener(QUIWidgetSoulSpiritFirePoint.EVENT_POINT_CLICK, handler(self,self.eventBigPoint))
 		soulFirePoint:setPosition(ccp(pointInfo.point_x,pointInfo.point_y))
 		soulFirePoint:setPointInfo(self._treeType,pointInfo)
 		soulFirePoint:showChooseState(false)
 		self._ccbOwner.node_point:addChild(soulFirePoint)
 		self._pointWidgetList[pointInfo.cell_id] = soulFirePoint
 	end
end
function QUIDialogSoulSpiritOccultGuide:showChossBigPoint(bigpoint)
	for _,pointWidget in pairs(self._pointWidgetList) do
		pointWidget:showChooseState(false)
	end
	if self._pointWidgetList[bigpoint] then
		self._pointWidgetList[bigpoint]:showChooseState(true)
	end
end
function QUIDialogSoulSpiritOccultGuide:eventBigPoint(event)
	local bigpoint = event.bigPoint
	-- self:showChossBigPoint(bigpoint)
	if event.name == QUIWidgetSoulSpiritFirePoint.EVENT_POINT_CLICK then		
		local smallPoint = remote.soulSpirit:getSoulFireActiviteByBigPoint(self._treeType,bigpoint)
		self:updateSoulSpiritFire(self._treeType, bigpoint, smallPoint)
		self._pageContent:setPositionY(self._orginalPosition.y)
	end
end

function QUIDialogSoulSpiritOccultGuide:updateSoulSpiritFire(treeNum,bigPoint,childPoint)

	self:resetAll()

	self._treeType = treeNum
	self._bigPoint = bigPoint
	self._childPoint = childPoint

	local bigPointInfo = db:getMianSoulFireInfo(self._treeType,self._bigPoint) or {}
	local bigPointColor = bigPointInfo.color or 1
	for ii,widetFire in pairs(self._soulFireWidgetList) do
		widetFire:setSoulFireInfo(bigPointInfo.color or 1,childPoint > ii)
		if childPoint == ii then
			widetFire:setActionShowSoulFire(bigPointInfo.color or 1)
		end
	end
	local nameColor = QIDEA_QUALITY_COLOR.BLUE
	if bigPointColor == 2 then
		nameColor = QIDEA_QUALITY_COLOR.PURPLE
	elseif bigPointColor == 3 then
		nameColor = QIDEA_QUALITY_COLOR.YELLOW
	else
		nameColor = QIDEA_QUALITY_COLOR.BLUE
	end
	self._ccbOwner.tf_bigPointName:setString(bigPointInfo.cell_name or "")
	self._ccbOwner.tf_bigPointName:setColor(nameColor)

	self._ccbOwner.sp_light_b:setVisible(bigPointColor == 1)
	self._ccbOwner.sp_light_p:setVisible(bigPointColor == 2)
	self._ccbOwner.sp_light_y:setVisible(bigPointColor == 3)

	local allSoulFireNum = remote.soulSpirit:getAllSoulFireNum()
	local activiteFireNum = remote.soulSpirit:getActiviteFireNum()
	self._ccbOwner.tf_cur_count:setString(activiteFireNum.."/"..allSoulFireNum)

	local isUnlock = remote.soulSpirit:checkBigPointCanUpgrade(self._treeType,bigPoint)
	if isUnlock then
		app:getUserData():setUserValueForKey(QUserData.SOULSPIRIT_OCCULT_POINT,bigPoint)
	end

	local precondiTionName = remote.soulSpirit:getPreconditionName(self._treeType,bigPoint)
	self._ccbOwner.tf_unlock_tips:setString(precondiTionName.."升级满后解锁")
	
	self:updateBtnState(isUnlock)	

	self:updateBigPointState()

	local state = remote.soulSpirit:getMainSoulSpiritFireState(self._treeType,bigPoint)

	local smallPoint = remote.soulSpirit:getSoulFireActiviteByBigPoint(self._treeType,bigPoint)
	if smallPoint >= remote.soulSpirit.SMALLPOINT_MAX_NUM then
		self._ccbOwner.node_btn_open:setVisible(false)
		self._ccbOwner.node_max:setVisible(true)
	else
		self._ccbOwner.node_btn_open:setVisible(true)
		self._ccbOwner.node_max:setVisible(false)
	end
	
	if not isUnlock then
		self._ccbOwner.tf_title1:setString("可点燃魂火")
		self._ccbOwner.tf_title2:setString("可激活秘术")
		self._ccbOwner.node_prop_3:setVisible(false)

		local config1 = db:getChildSoulFireInfo(self._treeType,bigPoint,remote.soulSpirit.SMALLPOINT_MAX_NUM -1 )
		local config2 = db:getChildSoulFireInfo(self._treeType,bigPoint,remote.soulSpirit.SMALLPOINT_MAX_NUM)

		if config1 then
			self._ccbOwner.tf_prop_1:setString(config1.cell_desc2 or "")
			self._ccbOwner.tf_prop_1:setColor(COLORS.f)
		end
		if config2 then
			self._ccbOwner.tf_prop_2:setString(config2.cell_desc2 or "")
			self._ccbOwner.tf_prop_2:setColor(COLORS.f)
		end
		self._totalHeight = 170	
	else
		if smallPoint >= remote.soulSpirit.SMALLPOINT_MAX_NUM then
			self._ccbOwner.tf_title1:setString("已点燃魂火")
			self._ccbOwner.tf_title2:setString("已激活秘术")
			self._ccbOwner.node_prop_3:setVisible(false)
		
			local config1 = db:getChildSoulFireInfo(self._treeType,bigPoint,remote.soulSpirit.SMALLPOINT_MAX_NUM -1 )
			local config2 = db:getChildSoulFireInfo(self._treeType,bigPoint,remote.soulSpirit.SMALLPOINT_MAX_NUM)

			if config1 then
				self._ccbOwner.tf_prop_1:setString(config1.cell_desc2 or "")
				self._ccbOwner.tf_prop_1:setColor(COLORS.b)
			end
			if config2 then
				self._ccbOwner.tf_prop_2:setString(config2.cell_desc2 or "")
				self._ccbOwner.tf_prop_2:setColor(COLORS.b)
			end	
			self._totalHeight = 170		
		else
			self._ccbOwner.tf_title1:setString("已点燃魂火")
			self._ccbOwner.tf_title2:setString("下一级魂火")
			self._ccbOwner.tf_title3:setString("可激活秘术")
			self._ccbOwner.node_prop_3:setVisible(true)
			
			local nextChildPoint = childPoint + 1
			local curtentChildInfo = db:getChildSoulFireInfo(self._treeType,bigPoint,childPoint)
			local nextChildInfo = db:getChildSoulFireInfo(self._treeType,bigPoint,nextChildPoint)
			-- local config2 = db:getChildSoulFireInfo(self._treeType,bigPoint,remote.soulSpirit.SMALLPOINT_MAX_NUM)
			if curtentChildInfo then
		    	self._ccbOwner.tf_prop_1:setString(curtentChildInfo.cell_desc2 or "")
		    	self._ccbOwner.tf_prop_1:setColor(COLORS.b)
			end
			local config3 = db:getChildSoulFireInfo(self._treeType,bigPoint,remote.soulSpirit.SMALLPOINT_MAX_NUM)
			if config3 then
				self._ccbOwner.tf_prop_3:setString(config3.cell_desc2 or "")
				self._ccbOwner.tf_prop_3:setColor(COLORS.f)
			end	

	    	if nextChildInfo and nextChildInfo.active_item then
		    	self._ccbOwner.tf_prop_2:setString(nextChildInfo.cell_desc or "")
		    	self._ccbOwner.tf_prop_2:setColor(COLORS.f)

	    		local activeItem = string.split(nextChildInfo.active_item, "^")
	    		self._itemId = activeItem[1]
	    		self._itemNum = activeItem[2]
	   			local currentCount = remote.items:getItemsNumByID(self._itemId)
	   			if currentCount >= tonumber(self._itemNum) then
	   				self._ccbOwner.sp_btn_tips:setVisible(true)
	   			else
	   				self._ccbOwner.sp_btn_tips:setVisible(false)
	   			end
	    		local itemInfo = db:getItemByID(self._itemId)
	    		if itemInfo then
			    	self._ccbOwner.sp_costNum:setVisible(true)
	  				self._ccbOwner.tf_costNum:setVisible(true)
	    			QSetDisplaySpriteByPath(self._ccbOwner.sp_costNum,itemInfo.icon_1)
	    			self._ccbOwner.tf_costNum:setString(self._itemNum)
	    		end
		    else
		    	self._ccbOwner.sp_costNum:setVisible(false)
		  		self._ccbOwner.tf_costNum:setVisible(false)
			end	

			self._totalHeight = 220		
		end
	end

	self:showRightFazhenEffect(self._treeType,bigPoint)

	self:showChossBigPoint(bigPoint)

	self:updateLineState()
end

function QUIDialogSoulSpiritOccultGuide:showRightFazhenEffect( treeType,bigPoint )
	local state = remote.soulSpirit:getMainSoulSpiritFireState(treeType,bigPoint)
	if state == remote.soulSpirit.FIRE_TATE_ACTIVITE then
		local bigPointInfo = db:getMianSoulFireInfo(treeType,bigPoint) or {}
		self._ccbOwner.node_fz_effect:setVisible(true)
		self._ccbOwner.node_fz_effect:removeAllChildren()
		local colorNum = bigPointInfo.color or 1
		local hallEffect = QResPath("soulspirit_fazhen_effect")[colorNum] or {}
    	local fcaAnimation = QUIWidgetFcaAnimation.new(hallEffect[2], "res")
		fcaAnimation:playAnimation("animation", true)
		self._ccbOwner.node_fz_effect:addChild(fcaAnimation)
	else
		self._ccbOwner.node_fz_effect:setVisible(false)
	end
end

function QUIDialogSoulSpiritOccultGuide:beginShowRightFazhe( treeType,bigPoint,smallPoint )
	local bigPointInfo = db:getMianSoulFireInfo(treeType,bigPoint) or {}
	self._ccbOwner.node_fz_effect:setVisible(true)
	self._ccbOwner.node_fz_effect:removeAllChildren()
	local colorNum = bigPointInfo.color or 1
	local hallEffect = QResPath("soulspirit_fazhen_effect")[colorNum] or {}
	local fcaAnimation = QUIWidgetFcaAnimation.new(hallEffect[1], "res")
	fcaAnimation:playAnimation("animation", false)
	self._ccbOwner.node_fz_effect:addChild(fcaAnimation)
	fcaAnimation:setEndCallback(function( )
		fcaAnimation:removeFromParent()
		self:showRightFazhenEffect(treeType,bigPoint)
		
	end)
end

function QUIDialogSoulSpiritOccultGuide:updateLineState()
	for ii = 0, remote.soulSpirit.BIGPOINT_MAX_NUM do
		local isStateOne = remote.soulSpirit:checkBigPointCanUpgrade(self._treeType,ii)
		if isStateOne or ii ==0 then
			for jj=1,remote.soulSpirit.BIGPOINT_MAX_NUM do
				local isStateTwo = remote.soulSpirit:checkBigPointCanUpgrade(self._treeType,jj)
				if isStateTwo then
					if self._ccbOwner["sp_line_light"..ii.."_"..jj] then
						self._ccbOwner["sp_line_light"..ii.."_"..jj]:setVisible(true)
					end
				else
					if self._ccbOwner["sp_line_light"..ii.."_"..jj] then
						self._ccbOwner["sp_line_light"..ii.."_"..jj]:setVisible(false)
					end						
				end
			end
		end
	end
end

function QUIDialogSoulSpiritOccultGuide:updateBtnState(isUnlock)
	if self._isUnlock == isUnlock then
		return
	end
	
	self._isUnlock = isUnlock

	if not self._isUnlock then
		self._ccbOwner.tf_btn_open:setString("未解锁")
		-- self._ccbOwner.node_cost:setVisible(false)
		-- self._ccbOwner.sp_btn_tips:setVisible(false)
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.tf_unlock_tips:setVisible(true)
	else
		self._ccbOwner.tf_btn_open:setString("升  级")
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.tf_unlock_tips:setVisible(false)
		self._ccbOwner.node_cost:setVisible(true)
	end

	if not self._isUnlock then
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	end

end

function QUIDialogSoulSpiritOccultGuide:showSoulFireProp(node,propDic,pointNum)
	if node and q.isEmpty(propDic) == false then
		local showStr = ""
		for key, value in pairs(propDic) do
		    local name = QActorProp._field[key].uiName or QActorProp._field[key].name
		    local isPercent = QActorProp._field[key].isPercent
		    if not isPercent then
		        local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2) 
		        showStr = showStr..name.."+"..value.."\n"
		    end
		end
		node:setString("【魂火"..(pointNum or "").."】".."全队魂灵护佑"..showStr)
	end
end

function QUIDialogSoulSpiritOccultGuide:_onTriggerUpgrade( )
	app.sound:playSound("common_small")
  	
  	if self._isActionEffect then
  		return
  	end

  	if not self._isUnlock then
  		app.tip:floatTip("未达到解锁条件!")
  		return
  	end

	local currentCount = remote.items:getItemsNumByID(self._itemId)
	if tonumber(self._itemNum) and currentCount < tonumber(self._itemNum) then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId, currentCount)
		return
	end

	local childPoint = self._childPoint
	local bigPoint = self._bigPoint
	if self._childPoint < remote.soulSpirit.SMALLPOINT_MAX_NUM then
		childPoint = childPoint + 1
	else
		childPoint = 1
		bigPoint = bigPoint + 1
	end
	local callbackResh = function(mapid,big,small)
		if small == remote.soulSpirit.SMALLPOINT_MAX_NUM then
		    scheduler.performWithDelayGlobal(function()
		    	if self:safeCheck() then
		        	self:beginShowRightFazhe(mapid,big,small)
		        end
		    end, 1)
			if self._pointWidgetList[big] then
				self._pointWidgetList[big]:ShowBaoZhaAnimation()
			end		
		end
		self:updateSoulSpiritFire(mapid,big,small)

		local childSoulFireInfo = db:getChildSoulFireInfo(mapid,big,small)
		if childSoulFireInfo.soul_num_team then
            scheduler.performWithDelayGlobal(function()
            	if self:safeCheck() then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritActiveTeamNum",
						options = { soul_num_team = childSoulFireInfo.soul_num_team}})
				end
            end, 1.5)
		end	
	end

	local callUpgrade = function( )
		self._isActionEffect = true
		remote.soulSpirit:soulSpiritOccultLevelUpRequest(self._treeType,self._bigPoint,childPoint,function(data)
			-- local successTip = app.master.SOULFIRE_MASTER_TIP
			self._isActionEffect = false
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulFireLightSuccess",
				options = { treeType = self._treeType, bigPoint= bigPoint,childPoint=childPoint,successTip = successTip,callback = function()
					if self:safeCheck() then
	                    -- scheduler.performWithDelayGlobal(function()
	                        callbackResh(self._treeType,bigPoint,childPoint)
	                    -- end, 0.5)
					end
				end}})
		end,function()
			self._isActionEffect = false
		end)
	end

	if bigPoint == 5 and childPoint == 10 then --刘常华指定点弹窗提示
		local contentStr = "点击升级1小队魂灵开坑位后将失去重置功能，确认是否继续升级？"
		app:alert({content = contentStr, title = "系统提示", callback = function (state)
	        if state == ALERT_TYPE.CONFIRM then
				callUpgrade()     	
	        end
	    end})		
	else
		callUpgrade()
	end

end

function QUIDialogSoulSpiritOccultGuide:_onTriggerGenre( )
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritAllOccultProp"})
end

function QUIDialogSoulSpiritOccultGuide:_onTriggerLookOccult( )
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritFireProperty",
		options = {treeType = self._treeType,bigPoint = self._bigPoint, childPoint = self._childPoint}})
end

function QUIDialogSoulSpiritOccultGuide:_onTriggerReset( )
	app.sound:playSound("common_small")
	local soulOccultMapInfo = remote.soulSpirit:getSoulSpritOccultMapInfo()
	if q.isEmpty(soulOccultMapInfo) then
		app.tip:floatTip("魂图已经是初始状态!")
		return
	end
	local costToken = db:getConfigurationValue("SOUL_FIRE_RETURN")
	if costToken > remote.user.token then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return		
	end
	local contentStr = string.format("消耗%d钻石重置整个魂图，可以将当前的魂图全部重置为0，并返还所消耗的魂灵精血，是否重置？",costToken)
	app:alert({content = contentStr, title = "系统提示", callback = function (state)
        if state == ALERT_TYPE.CONFIRM then
        	remote.soulSpirit:soulSpiritOccultResetRequest(self._treeType,function(data)
        		if self:safeCheck() then
	    		    local bigPoint = 4 
				    local smallPoint = remote.soulSpirit:getSoulFireActiviteByBigPoint(self._treeType,bigPoint)
				   	app:getUserData():setUserValueForKey(QUserData.SOULSPIRIT_OCCULT_POINT,bigPoint)
				    self:updateSoulSpiritFire( self._treeType, bigPoint, smallPoint)

	        		local awards = {}
	        		if data.awards then
	        			for _,v in pairs(data.awards) do
	        				table.insert(awards, {id = v.id, value = v.count})
	        			end
	        		end
	            	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
	                	options = {compensations = awards, type = 16, subtitle = "重置返还以下道具"}}, {isPopCurrentDialog = false}) 
	            end
        	end)       	
        end
    end})
end

function QUIDialogSoulSpiritOccultGuide:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulSpiritOccultGuide:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulSpiritOccultGuide
