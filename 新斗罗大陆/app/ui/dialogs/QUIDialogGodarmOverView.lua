-- @Author: liaoxianbo
-- @Date:   2019-12-23 17:53:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-22 11:55:12
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmOverView = class("QUIDialogGodarmOverView", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGodarmOverView = import("..widgets.QUIWidgetGodarmOverView")
local QListView = import("...views.QListView")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogGodarmOverView.GODARM_CLICK = "GODARM_CLICK"
QUIDialogGodarmOverView.TOTAL_HERO_FRAME = 15

function QUIDialogGodarmOverView:ctor(options)
	local ccbFile = "ccb/Dialog_GodArm_Overview.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerCombination",	callback = handler(self, self._onTriggerCombination)},
		{ccbCallbackName = "onTriggerGo",	callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogGodarmOverView.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page.topBar:showWithHeroOverView()
	CalculateUIBgSize(self._ccbOwner.sp_bg)
	CalculateUIBgSize(self._ccbOwner.sp_mask)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._isReborn = options.isReborn
    	self._isRecly = options.isRecly
    end
	self._godarmList = {}
	self._isListItemRuning = false

	self._multiItems = 5
	self._spaceX = 10
	local width = 188
	local totalWidth = width * self._multiItems + self._spaceX * (self._multiItems )
	self._ccbOwner.sheet_layout:setContentSize(totalWidth, self._ccbOwner.sheet_layout:getContentSize().height - 77)
	self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._ccbOwner.node_no:setVisible(false)
end

function QUIDialogGodarmOverView:viewDidAppear()
	QUIDialogGodarmOverView.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:updateGodarm()

	self:listItemRunOutAction()
end

function QUIDialogGodarmOverView:viewWillDisappear()
  	QUIDialogGodarmOverView.super.viewWillDisappear(self)

	self:removeBackEvent()
	if self._listItemRunInScheduler ~= nil then
		scheduler.unscheduleGlobal(self._listItemRunInScheduler)
		self._listItemRunInScheduler = nil
	end

	if self._listItemRunOutScheduler ~= nil then
		scheduler.unscheduleGlobal(self._listItemRunOutScheduler)
		self._listItemRunOutScheduler = nil
	end

end

function QUIDialogGodarmOverView:updateGodarm()
	local allGodarms = remote.godarm:getAllGodarmList()
	local haveGodarms = remote.godarm:getHaveGodarmList()

	self._godarmList = {}
	if self._isRecly then
		for _, info in pairs(haveGodarms) do
			local godarmConfig = db:getCharacterByID(info.id)
	        if godarmConfig.aptitude ~= APTITUDE.SS then
	        	local godarmInfo = {}
	        	godarmInfo.godarmId = info.id
	        	godarmInfo.isHave = true
	        	godarmInfo.grade = info.grade
	        	godarmInfo.level = info.level
	       	 	table.insert(self._godarmList, godarmInfo)
	       	end
	    end		
	elseif self._isReborn then
		for _, info in pairs(haveGodarms) do
        	local godarmInfo = {}
        	godarmInfo.godarmId = info.id
        	godarmInfo.isHave = true
        	godarmInfo.grade = info.grade
        	godarmInfo.level = info.level	        	
        	table.insert(self._godarmList, godarmInfo)
		end
	else
		for i, godarmId in ipairs(allGodarms) do
	    	local godarmConfig = db:getCharacterByID(godarmId)
			local godarmInfo = {}
			godarmInfo.godarmId = godarmId
	        godarmInfo.isCommon = false
	        godarmInfo.isHave = false
	        godarmInfo.aptitude = godarmConfig.aptitude
			godarmInfo.force = 0

		    if haveGodarms[godarmId] then
		    	godarmInfo.isHave = true
	        	godarmInfo.grade = haveGodarms[godarmId].grade
		        godarmInfo.level = haveGodarms[godarmId].level
		    else
		    	local config = db:getGradeByHeroActorLevel(godarmId, 0)
		    	local haveNum = remote.items:getItemsNumByID(config.soul_gem)
	        	if haveNum >= config.soul_gem_count then
	        		godarmInfo.isCommon = true
	        	end
			end
			table.insert(self._godarmList, godarmInfo)
		end
	end
	table.sort( self._godarmList, function(a, b)
			if a.isCommon ~= b.isCommon then
				return a.isCommon == true
			elseif a.isHave ~= b.isHave then
				return a.isHave == true
			elseif a.isHave == false and b.isHave == false then
				local aConfig = db:getGradeByHeroActorLevel(a.godarmId, 0)
				local aHaveNum = remote.items:getItemsNumByID(aConfig.soul_gem)

				local bConfig = db:getGradeByHeroActorLevel(b.godarmId, 0)
				local bHaveNum = remote.items:getItemsNumByID(bConfig.soul_gem)

				if a.aptitude ~= b.aptitude then
					return a.aptitude > b.aptitude
				else
					return aHaveNum > bHaveNum
				end
			else
				if a.aptitude ~= b.aptitude then
    				return a.aptitude > b.aptitude
    			elseif a.grade ~= b.grade then
    				return a.grade > b.grade
    			elseif a.level and b.level and a.level ~= b.level then
    				return a.level > b.level
    			else
					return a.godarmId > b.godarmId
				end
			end
		end)	
	self:initListView()
	self._ccbOwner.node_no:setVisible(#self._godarmList == 0)
end

function QUIDialogGodarmOverView:initListView()
	self._multiItems = 5
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        isVertical = true,
	        multiItems = self._multiItems,
	        spaceX = self._spaceX,
	        spaceY = 10,
	        curOriginOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,  
	        totalNumber = #self._godarmList,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._godarmList})
	end
end


function QUIDialogGodarmOverView:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._godarmList[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetGodarmOverView.new()
    	item:addEventListener(QUIWidgetGodarmOverView.GODARM_EVENT_CLICK, handler(self, self._clickGodarm))
    	item:addEventListener(QUIWidgetGodarmOverView.GODARM_EVENT_PIECE, handler(self, self._clickGodarm))
    	item:addEventListener(QUIWidgetGodarmOverView.GODARM_EVENT_COMPOSE, handler(self, self._clickGodarm))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
   
    list:registerBtnHandler(index, "btn_banner", "_onTriggerClick") 

    return isCacheNode
end

function QUIDialogGodarmOverView:listItemRunOutAction()
	if self._isListItemRuning == true then return end
	self._listView:setCanNotTouchMove(true)
	self._isListItemRuning = true
	for i = 1, QUIDialogGodarmOverView.TOTAL_HERO_FRAME do
		local item
		if self._listView then
			item = self._listView:getItemByIndex(i)
		end
		if item ~= nil then
			local posx, posy = item:getPosition()
			item:setPosition(ccp(posx + self._sheetLeyoutWidth, posy))	
		end 
	end

	self.func1 = function()
		self._listItemRunInScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:listItemRunInAction()
			end
		end, 0.2)
	end
	self.func1()
end 

function QUIDialogGodarmOverView:listItemRunInAction()
	self._isListItemRuning = true
	local time = 0.17
	local i = 1
	local maxIndex = QUIDialogGodarmOverView.TOTAL_HERO_FRAME / (QUIDialogGodarmOverView.TOTAL_HERO_FRAME / self._multiItems)
	self.func2 = function()
		if i <= maxIndex then
			local item1 = self._listView:getItemByIndex(i)
			local item2 = self._listView:getItemByIndex(i + self._multiItems)
			local item3 = self._listView:getItemByIndex(i + self._multiItems * 2)

			if item1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						--makeNodeFadeToOpacity(item1, time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				item1:runAction(CCSequence:create(array2))
			end

			if item2 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						--makeNodeFadeToOpacity(item2, time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

				local array2 = CCArray:create()
				array2:addObject(CCDelayTime:create(0.08))
				array2:addObject(CCSpawn:create(array1))
				item2:runAction(CCSequence:create(array2))
			end

			if item3 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						--makeNodeFadeToOpacity(item3, time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

				local array2 = CCArray:create()
				array2:addObject(CCDelayTime:create(0.16))
				array2:addObject(CCSpawn:create(array1))
				item3:runAction(CCSequence:create(array2))
			end

			i = i + 1
			self._listItemRunOutScheduler = scheduler.performWithDelayGlobal(self.func2, 0.05)
		else
			self._isListItemRuning = false
			self._listView:setCanNotTouchMove(false)
		end
	end
	self.func2()
end 

function QUIDialogGodarmOverView:runTo(id, callback)
	if self._listView then
		for i, value in ipairs(self._godarmList) do
			if value.id == id then
				self._listView:startScrollToIndex(i, nil, 40, callback);
				return true
			end
		end
		return true
	end
	return false
end

function QUIDialogGodarmOverView:_clickGodarm(event)
	if self._isListItemRuning then return end
	if not app.unlock:getUnlockGodarm(true) then return end

	app.sound:playSound("common_small")
	QPrintTable(event.info)
	local godarmId = event.info.godarmId

	if event.name == QUIWidgetGodarmOverView.GODARM_EVENT_CLICK then
		if self._isReborn or self._isRecly then
			self:viewAnimationOutHandler()
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogGodarmOverView.GODARM_CLICK, godarmId = godarmId})
		else
			local godArmIds = self:getGodArmIds()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmInfomation", 
	        	options={godarmId = godarmId , godArmIds = godArmIds  }}, {isPopCurrentDialog = true})
		end
	elseif event.name == QUIWidgetGodarmOverView.GODARM_EVENT_PIECE then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodArmDetailInfoNew", 
	        	options={godarmId = godarmId}}, {isPopCurrentDialog = false})
	elseif event.name == QUIWidgetGodarmOverView.GODARM_EVENT_COMPOSE then
		remote.godarm:godarmGradeUpRequest(godarmId,function()
			-- 弹恭喜获得
			local godArmInfo = remote.godarm:getGodarmById(godarmId)
            local godArmGrade = godArmInfo.grade or 0
            printInfo("~~~~~~ godArmGrade == %s ~~~~~~", godArmGrade)
            local valueTbl = {}
        	valueTbl[godarmId] = godArmGrade + 1
            remote.activity:updateLocalDataByType(713, valueTbl)
            
			if self:safeCheck()	then
				local data = {godarmId = godarmId, grade = 0}
				self:commonSuccess(data)
			end
		end,function( )
			app.tip:floatTip("合成失败")
		end)
	end
end


function QUIDialogGodarmOverView:getGodArmIds()
	local ids = {}
	for i,v in ipairs(self._godarmList) do
		if v.isHave then
	    	local godArmId = v.godarmId
			table.insert(ids, godArmId)
		end
	end
	return ids
end

function QUIDialogGodarmOverView:commonSuccess(data)
	if self:safeCheck()	then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShowGodarmInfo", 
        	options= {godarmId = data.godarmId, callBack = function()
        		-- app.tip:creatMountCombinationTip(data.actorId)
        		if self:safeCheck() then
        			self:updateGodarm()
        		end
        	end}}, {isPopCurrentDialog = true})
	end
end

function QUIDialogGodarmOverView:_onTriggerCombination(event)
	if self._isListItemRuning then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_combination) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmCollectProperty"})
end

function QUIDialogGodarmOverView:_onTriggerGo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    app.sound:playSound("common_small")
    remote.totemChallenge:openDialog()
end

return QUIDialogGodarmOverView
