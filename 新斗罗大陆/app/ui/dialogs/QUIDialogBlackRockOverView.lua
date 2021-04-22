-- @Author: liaoxianbo
-- @Date:   2019-06-20 17:41:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-07 18:58:29
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockOverView = class("QUIDialogBlackRockOverView", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetBlackRockOverView = import("..widgets.QUIWidgetBlackRockOverView")
local QListView = import("...views.QListView")

QUIDialogBlackRockOverView.SHOW_PROJECT_HUNLIN = "SHOW_PROJECT_HUNLIN"
QUIDialogBlackRockOverView.SHOW_PROJECT_NPC = "SHOW_PROJECT_NPC"
QUIDialogBlackRockOverView.TOTAL_HERO_FRAME = 15

function QUIDialogBlackRockOverView:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Overview.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogBlackRockOverView.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page.topBar:showWithMount()

	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width
    self:setOptType(QUIDialogBlackRockOverView.SHOW_PROJECT_HUNLIN)
end

function QUIDialogBlackRockOverView:viewDidAppear()
	QUIDialogBlackRockOverView.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:initView()

	if not (self._isReborn or self._isRecycle) then
		self:listItemRunOutAction()
	end
end

function QUIDialogBlackRockOverView:viewWillDisappear()
  	QUIDialogBlackRockOverView.super.viewWillDisappear(self)

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

function QUIDialogBlackRockOverView:initView()
	self._ccbOwner.tf_title:setString("守卫魂灵")
	self._ccbOwner.node_btn:setVisible(false)
end

function QUIDialogBlackRockOverView:setOptType(optType)
	self._tuJianList = {}
	if optType == QUIDialogBlackRockOverView.SHOW_PROJECT_HUNLIN then
		self._tuJianList = remote.blackrock:getBlackNpcList()
		self:updateBlackList()
	else
	end
end

function QUIDialogBlackRockOverView:updateBlackList( )
	self._data = {}
	for _, id in ipairs(self._tuJianList) do
    	local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
		local tbl = {}
		tbl.id = id
		tbl.heroId = 0
        tbl.grade = 0
        tbl.level = 0
        tbl.exp = 0
        tbl.force = 0
        tbl.isCommon = false
        tbl.isHave = false
        tbl.aptitude = characterConfig.aptitude

        local myRandomBlackInfo = remote.blackrock:getIsRandomBlackSourSpritById(id)
	    if myRandomBlackInfo then
	    	tbl.isHave = true
	    else
	    	local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, 0)
	    	if gradeConfig then
		    	local haveNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
	        	if haveNum >= gradeConfig.soul_gem_count then
	        		tbl.isCommon = true
	        	end
	        end
		end

 		table.insert(self._data, tbl)
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

				if a.aptitude ~= b.aptitude then
					return a.aptitude > b.aptitude
				elseif aHaveNum ~= bHaveNum then
					return aHaveNum > bHaveNum
				else
					return a.id > b.id
				end
			else
    			if self._isSelect and a.heroId ~= b.heroId and (a.heroId == 0 or b.heroId == 0) then
                	return a.heroId == 0
                elseif a.force ~= b.force then
					return a.force > b.force
				elseif a.aptitude ~= b.aptitude then
    				return a.aptitude > b.aptitude
    			elseif a.grade ~= b.grade then
    				return a.grade > b.grade
    			elseif a.level ~= b.level then
    				return a.level > b.level
				else
					return a.id > b.id
				end
			end
		end)

	self:initListView()
	self._ccbOwner.node_no:setVisible(#self._data == 0)
end

function QUIDialogBlackRockOverView:initListView()
	self._multiItems = 4
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        multiItems = self._multiItems,
	        spaceX = 12,
	        spaceY = 10,
	        enableShadow = false,
	        -- topShadow = self._ccbOwner.topShadow,
	        -- bottomShadow = self._ccbOwner.bottomShadow,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogBlackRockOverView:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetBlackRockOverView.new()
    	item:addEventListener(QUIWidgetBlackRockOverView.EVENT_CLICK, handler(self, self._clickMount))
    	item:addEventListener(QUIWidgetBlackRockOverView.EVENT_PIECE, handler(self, self._clickMount))
    	item:addEventListener(QUIWidgetBlackRockOverView.EVENT_COMPOSE, handler(self, self._clickMount))
    	isCacheNode = false
    end
    item:setInfo(itemData, self._actorId ~= nil )
    info.item = item
    info.size = item:getContentSize()
   
    list:registerBtnHandler(index, "btn_banner", "_onTriggerClick") 

    return isCacheNode
end

function QUIDialogBlackRockOverView:listItemRunOutAction()
	if self._isListItemRuning == true then return end
	self._listView:setCanNotTouchMove(true)
	self._isListItemRuning = true
	for i = 1, QUIDialogBlackRockOverView.TOTAL_HERO_FRAME do
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

function QUIDialogBlackRockOverView:listItemRunInAction()
	self._isListItemRuning = true
	local time = 0.17
	local i = 1
	local maxIndex = QUIDialogBlackRockOverView.TOTAL_HERO_FRAME / (QUIDialogBlackRockOverView.TOTAL_HERO_FRAME / self._multiItems)
	self.func2 = function()
		if i <= maxIndex then
			local item1 = self._listView:getItemByIndex(i)
			local item2 = self._listView:getItemByIndex(i + self._multiItems)
			local item3 = self._listView:getItemByIndex(i + self._multiItems*2)

			if item1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(item1, time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(time, ccp(-self._sheetLeyoutWidth, 0))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				item1:runAction(CCSequence:create(array2))
			end

			if item2 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(item2, time)
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
						makeNodeFadeToOpacity(item3, time)
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

function QUIDialogBlackRockOverView:runTo(mountId, callback)
	if self._listView then
		for i, value in ipairs(self._data) do
			if value.mountId == mountId then
				self._listView:startScrollToIndex(i, nil, 40, callback);
				return true
			end
		end
		return true
	end
	return false
end

function QUIDialogBlackRockOverView:_clickMount(event)
	if self._isListItemRuning then return end
	app.sound:playSound("common_small")
	local id = event.info.id
	if event.name == QUIWidgetBlackRockOverView.EVENT_CLICK then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackSoulSpiritDetail", 
	        	options={id = id, soulSpiritList = self._data}})
	end	
end

-- function QUIDialogBlackRockOverView:_backClickHandler()
--     self:_onTriggerClose()
-- end

-- function QUIDialogBlackRockOverView:_onTriggerClose()
--   	app.sound:playSound("common_close")
-- 	self:playEffectOut()
-- end

-- function QUIDialogBlackRockOverView:viewAnimationOutHandler()
-- 	local callback = self._callBack

-- 	self:popSelf()

-- 	if callback then
-- 		callback()
-- 	end
-- end

return QUIDialogBlackRockOverView
