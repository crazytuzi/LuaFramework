-- 
-- Kumo.Wang
-- 魂灵主界面
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritOverView = class("QUIDialogSoulSpiritOverView", QUIDialog)

local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSoulSpiritOverView = import("..widgets.QUIWidgetSoulSpiritOverView")
local QActorProp = import("...models.QActorProp")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogSoulSpiritOverView.MOUNT_CLICK = "MOUNT_CLICK"
QUIDialogSoulSpiritOverView.TOTAL_HERO_FRAME = 15

function QUIDialogSoulSpiritOverView:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Overview.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerCombination",	callback = handler(self, self._onTriggerCombination)},
		{ccbCallbackName = "onTriggerSoulSpiritGuide",	callback = handler(self, self._onTriggerSoulSpiritGuide)},
		{ccbCallbackName = "onTriggerGo",	callback = handler(self, self._onTriggerGo)},
	}
	QUIDialogSoulSpiritOverView.super.ctor(self,ccbFile,callBacks,options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page.topBar:showWithSoulSpirit()
    CalculateUIBgSize(self._ccbOwner.sp_bg)
    CalculateUIBgSize(self._ccbOwner.sp_mask)

    q.setButtonEnableShadow(self._ccbOwner.btn_soul_guide)
	if options then
		self._heroId = options.heroId
		self._isRecycle = options.isRecycle
		self._isReborn = options.isReborn
	end
	self._isSelect = false
	if self._heroId or self._isRecycle or self._isReborn then
		self._isSelect = true
	end

	self._data = {}
	self._isListItemRuning = false

	self._multiItems = 5
	self._spaceX = 10
	local width = 188
	local totalWidth = width * self._multiItems + self._spaceX * (self._multiItems)
	self._ccbOwner.sheet_layout:setContentSize(totalWidth, self._ccbOwner.sheet_layout:getContentSize().height - 77)
-- print("QUIDialogSoulSpiritOverView:ctor(options) ", self._ccbOwner.sheet_layout:getContentSize().width, self._ccbOwner.sheet_layout:getContentSize().height)
	self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.sp_red_tips:setVisible(false)

	q.setButtonEnableShadow(self._ccbOwner.btn_go)
end

function QUIDialogSoulSpiritOverView:viewDidAppear()
    QUIDialogSoulSpiritOverView.super.viewDidAppear(self)
    self:addBackEvent(true)

    self:updateSoulSpirit()
    
	if not (self._isReborn or self._isRecycle) then
		self:listItemRunOutAction()
	end
end

function QUIDialogSoulSpiritOverView:viewWillDisappear()
    QUIDialogSoulSpiritOverView.super.viewWillDisappear(self)
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

function QUIDialogSoulSpiritOverView:updateSoulSpirit()
	local allSoulSpiritIdList = remote.soulSpirit:getAllSoulSpiritIdList()
	local mySoulSpiritInfoList = remote.soulSpirit:getMySoulSpiritInfoList()

	self._data = {}
	if self._heroId then
	    local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
	    local heroSoulSpiritInfo = clone(heroInfo.soulSpirit)
	    for _, info in pairs(mySoulSpiritInfoList) do
	        heroInfo.soulSpirit = {}
	        local oldHeroModel = QActorProp.new(heroInfo)
	        local oldBattleForce = math.ceil(oldHeroModel:getBattleForce(true))
	     
	        heroInfo.soulSpirit = info
	        heroInfo.soulSpirit.soulSpiritMapInfo = remote.soulSpirit:getSoulSpritOccultMapInfo() or {}
	        
	        local newHeroModel = QActorProp.new(heroInfo)
	        local newBattleForce = math.ceil(newHeroModel:getBattleForce(true))
	        
	        local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(info.id)
	        local tbl = {}
	        tbl.id = info.id
			tbl.heroId = info.heroId
	        tbl.grade = info.grade
	        tbl.level = info.level
	        tbl.awaken_level = info.awaken_level or 0
	        tbl.exp = info.exp
	        tbl.force = newBattleForce - oldBattleForce
	        tbl.isCommon = false
	        tbl.isHave = true
	        tbl.isSelect = self._isSelect
	        tbl.aptitude = characterConfig.aptitude

	        if not heroSoulSpiritInfo or heroSoulSpiritInfo.id ~= info.id then
	        	table.insert(self._data, tbl)
	        end
	    end
	    heroInfo.soulSpirit = heroSoulSpiritInfo
	    if #self._data == 0 then
	    	app.tip:floatTip("没有可以护佑的魂灵~")
	    end
	elseif self._isReborn then
		for _, info in pairs(mySoulSpiritInfoList) do
			local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(info.id)
			local tbl = {}
	        tbl.isCommon = false
	        tbl.isHave = true
	        tbl.heroId = info.heroId
	        tbl.id = info.id
	        tbl.grade = info.grade
	        tbl.level = info.level
	        tbl.awaken_level = info.awaken_level or 0
	        tbl.force = 0
	        tbl.isSelect = self._isSelect
	        tbl.aptitude = characterConfig.aptitude
	        -- if (not tbl.heroId or tbl.heroId == 0) and (tbl.level ~= 1 or tbl.grade ~= 0) then
	        if not tbl.heroId or tbl.heroId == 0 then
	        	table.insert(self._data, tbl)
	        end
	    end
	    if #self._data == 0 then
	    	app.tip:floatTip("没有可以重生的魂灵~")
	    end
	elseif self._isRecycle then
		for _, info in pairs(mySoulSpiritInfoList) do
			local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(info.id)
			local tbl = {}
	        tbl.isCommon = false
	        tbl.isHave = true
	        tbl.heroId = info.heroId
	        tbl.id = info.id
	        tbl.grade = info.grade
	        tbl.awaken_level = info.awaken_level or 0
	        tbl.level = info.level
	        tbl.force = 0
	        tbl.isSelect = self._isSelect
	        tbl.aptitude = characterConfig.aptitude
	        if not tbl.heroId or tbl.heroId == 0 then
	       	 	table.insert(self._data, tbl)
	       	end
	    end
	    if #self._data == 0 then
	    	app.tip:floatTip("没有可以分解的魂灵~")
	    end
	else
		for _, id in ipairs(allSoulSpiritIdList) do
			if not db:checkHeroShields(id) then
		    	local characterConfig = db:getCharacterByID(id)
				local tbl = {}
				tbl.id = id
				tbl.heroId = 0
		        tbl.grade = 0
		        tbl.level = 0
		        tbl.exp = 0
		        tbl.force = 0
		        tbl.isCommon = false
		        tbl.isHave = false
		        tbl.isSelect = self._isSelect
		        tbl.aptitude = characterConfig.aptitude
		        tbl.isCollege = false
		        local mySoulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
			    if mySoulSpiritInfo then
			    	tbl.isHave = true
		        	tbl.heroId = mySoulSpiritInfo.heroId
		        	tbl.grade = mySoulSpiritInfo.grade
			        tbl.level = mySoulSpiritInfo.level
		        	tbl.exp = mySoulSpiritInfo.exp
		        	tbl.awaken_level = mySoulSpiritInfo.awaken_level or 0
			    else
			    	local gradeConfig = db:getGradeByHeroActorLevel(id, 0)
			    	if gradeConfig then
				    	local haveNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
			        	if haveNum >= gradeConfig.soul_gem_count then
			        		tbl.isCommon = true
			        	end
			        end
			        local historySoulInfo = remote.soulSpirit:getMySoulSpiritHistoryInfoById(id)
			        if historySoulInfo then
			         	tbl.isCollege = (historySoulInfo.level>0 or historySoulInfo.grade > 0)
			        end
				end
				table.insert(self._data, tbl)
			end
		end
	end

	table.sort( self._data, function(a, b)
			if a.isCommon ~= b.isCommon then
				return a.isCommon == true
			elseif a.isHave ~= b.isHave then
				return a.isHave == true
			elseif a.isHave == false and b.isHave == false then
				local aConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(a.id, 0)
				local aHaveNum = 0
				if aConfig then
					aHaveNum = remote.items:getItemsNumByID(aConfig.soul_gem)
				end

				local bConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(b.id, 0)
				local bHaveNum = 0
				if bConfig then
					bHaveNum = remote.items:getItemsNumByID(bConfig.soul_gem)
				end
				if a.isCommon == true then
					if a.aptitude ~= b.aptitude then
						return a.aptitude > b.aptitude
					elseif aHaveNum ~= bHaveNum then
						return aHaveNum > bHaveNum
					else
						return a.id > b.id
					end
				else
					if a.isCollege ~= b.isCollege then
						return a.isCollege == false 
					elseif a.aptitude ~= b.aptitude then
						return a.aptitude > b.aptitude
					elseif aHaveNum ~= bHaveNum then
						return aHaveNum > bHaveNum
					else
						return a.id > b.id
					end					
				end
			else
				if self._isSelect and a.heroId ~= b.heroId and (a.heroId == 0 or b.heroId == 0) then
					return a.heroId == 0
				elseif a.aptitude ~= b.aptitude then
					return a.aptitude > b.aptitude
				elseif a.grade ~= b.grade then
					return a.grade > b.grade
				elseif a.awaken_level ~= b.awaken_level then
					return a.awaken_level > b.awaken_level
				elseif a.level ~= b.level then
					return a.level > b.level
				else
					return a.id > b.id
				end
    -- 			if self._isSelect and a.heroId ~= b.heroId and (a.heroId == 0 or b.heroId == 0) then
    --             	return a.heroId == 0
    --             elseif a.force ~= b.force then
				-- 	return a.force > b.force
				-- elseif a.aptitude ~= b.aptitude then
    -- 				return a.aptitude > b.aptitude
    -- 			elseif a.grade ~= b.grade then
    -- 				return a.grade > b.grade
    -- 			elseif a.level ~= b.level then
    -- 				return a.level > b.level
				-- else
				-- 	return a.id > b.id
				-- end
			end
		end)

	self._ccbOwner.node_btn:setVisible(not self._isSelect)
	self:initListView()
	self._ccbOwner.node_no:setVisible(#self._data == 0)

	local redTips = remote.soulSpirit:checkCombinationRedTips()
	self._ccbOwner.sp_red_tips:setVisible(redTips)

	local occultRedTips = remote.soulSpirit:checkSoulSpiritOccultRedTips()
	self._ccbOwner.sp_grade_tips:setVisible(occultRedTips)
end

function QUIDialogSoulSpiritOverView:initListView()
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        isVertical = true,
	        multiItems = self._multiItems,
	        spaceX = self._spaceX,
	        curOriginOffset = 20,
	        spaceY = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,  
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogSoulSpiritOverView:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetSoulSpiritOverView.new()
    	item:addEventListener(QUIWidgetSoulSpiritOverView.EVENT_CLICK, handler(self, self._clickSoulSpiritWidget))
    	item:addEventListener(QUIWidgetSoulSpiritOverView.EVENT_PIECE, handler(self, self._clickSoulSpiritWidget))
    	item:addEventListener(QUIWidgetSoulSpiritOverView.EVENT_COMPOSE, handler(self, self._clickSoulSpiritWidget))
    	isCacheNode = false
    end
    item:setInfo(itemData, self._heroId ~= nil )
    info.item = item
    info.size = item:getContentSize()
   
    list:registerBtnHandler(index, "btn_banner", "_onTriggerClick") 

    return isCacheNode
end

function QUIDialogSoulSpiritOverView:listItemRunOutAction()
	if self._isListItemRuning == true then return end
	self._listView:setCanNotTouchMove(true)
	self._isListItemRuning = true
	for i = 1, QUIDialogSoulSpiritOverView.TOTAL_HERO_FRAME do
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

function QUIDialogSoulSpiritOverView:listItemRunInAction()
	self._isListItemRuning = true
	local time = 0.17
	local i = 1
	local maxIndex = QUIDialogSoulSpiritOverView.TOTAL_HERO_FRAME / (QUIDialogSoulSpiritOverView.TOTAL_HERO_FRAME / self._multiItems)
	self.func2 = function()
		if i <= maxIndex then
			local item1 = self._listView:getItemByIndex(i)
			local item2 = self._listView:getItemByIndex(i + self._multiItems)
			local item3 = self._listView:getItemByIndex(i + self._multiItems * 2)

			if item1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						-- makeNodeFadeToOpacity(item1, time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				item1:runAction(CCSequence:create(array2))
			end

			if item2 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						-- makeNodeFadeToOpacity(item2, time)
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

function QUIDialogSoulSpiritOverView:runTo(id, callback)
	if self._listView then
		for i, value in ipairs(self._data) do
			if value.id == id then
				self._listView:startScrollToIndex(i, nil, 40, callback);
				return true
			end
		end
		return true
	end
	return false
end

function QUIDialogSoulSpiritOverView:selectSoulSpirit(id, heroId)		
	local closeFun = function()
		self:viewAnimationOutHandler()
		remote.soulSpirit:soulSpiritEquipRequest(heroId, id, true, function()
	    	remote.soulSpirit:dispatchEvent({name = remote.soulSpirit.EVENT_WEAR, id = id, heroId = heroId})
		end)
	end

	if remote.soulSpirit.heroSoulSpiritShow then
		local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
		if soulSpiritInfo.heroId and soulSpiritInfo.heroId ~= 0 then
			local callback = function(state, isSelect)
				if state == ALERT_TYPE.CONFIRM then
	               	if isSelect then
	            		remote.soulSpirit.heroSoulSpiritShow = false
	            	end
	               	closeFun()
	            end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这个魂灵已经护佑在其他魂师身上了，是否替换？"}, {isPopCurrentDialog = false}})
		else
			closeFun()
		end
	else
		closeFun()
	end
end

function QUIDialogSoulSpiritOverView:_clickSoulSpiritWidget(event)
	if self._isListItemRuning then return end
	app.sound:playSound("common_small")
	local id = event.info.id
	print("event.name = ", event.name)
	if event.name == QUIWidgetSoulSpiritOverView.EVENT_CLICK then
		if self._heroId then
			self:selectSoulSpirit(id, self._heroId)
		elseif self._isReborn or self._isRecycle then
			self:viewAnimationOutHandler()
			local soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(id)
			remote.soulSpirit:dispatchEvent({name = remote.soulSpirit.EVENT_SELECTED_SOULSPIRIT, soulSpirit = soulSpirit})
		else
			local tbl = {}
			for _, value in ipairs(self._data) do
				if value.isHave then
					table.insert(tbl, value.id)
				end
			end
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritDetail", 
	        	options={id = id, soulSpiritIdList = tbl}})
		end
	elseif event.name == QUIWidgetSoulSpiritOverView.EVENT_PIECE then
		app.tip:itemTip(ITEM_TYPE.SOUL_SPIRIT, id, true)
		
	elseif event.name == QUIWidgetSoulSpiritOverView.EVENT_COMPOSE then
		local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, 0)
    	if gradeConfig then
	    	if remote.user.money < gradeConfig.money then
	    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
	    		return
	    	end
        end
		remote.soulSpirit:soulSpiritGradeUpdateRequest(id, function(data)
				if self:safeCheck()	then
					local info = data.soulSpirit and data.soulSpirit[1] or {}
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritComposeSuccess", 
			        	options= {id = info.id, callBack = handler(self, self.updateSoulSpirit)}}, {isPopCurrentDialog = false})
				end
			end)
	end
end

function QUIDialogSoulSpiritOverView:_onTriggerCombination(event)
	if self._isListItemRuning then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_combination) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritCombination"})
end

function QUIDialogSoulSpiritOverView:_onTriggerSoulSpiritGuide( )
	if self._isListItemRuning then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOccultGuide"})
end
function QUIDialogSoulSpiritOverView:_onTriggerGo(event)
    app.sound:playSound("common_small")
	remote.blackrock:openDialog()
end

return QUIDialogSoulSpiritOverView