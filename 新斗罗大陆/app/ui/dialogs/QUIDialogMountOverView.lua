-- 
-- zxs
-- 暗器主界面
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountOverView = class("QUIDialogMountOverView", QUIDialog)

local QListView = import("...views.QListView")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetMountOverView = import("..widgets.mount.QUIWidgetMountOverView")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")

QUIDialogMountOverView.MOUNT_CLICK = "MOUNT_CLICK"
QUIDialogMountOverView.TOTAL_HERO_FRAME = 15

function QUIDialogMountOverView:ctor(options)
	-- local ccbFile = "ccb/Dialog_Weapon_zonglan_01.ccbi"
	local ccbFile = "ccb/Dialog_Mount_Overview.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerCombination",	callback = handler(self, self._onTriggerCombination)},
		{ccbCallbackName = "onTriggerSoulGuide",	callback = handler(self, self._onTriggerSoulGuide)},
		{ccbCallbackName = "onTriggerGo",	callback = handler(self, self._onTriggerGo)},
	}
	QUIDialogMountOverView.super.ctor(self,ccbFile,callBacks,options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page.topBar:showWithMount()
    CalculateUIBgSize(self._ccbOwner.sp_bg)
    CalculateUIBgSize(self._ccbOwner.sp_mask)

	if options then
		self._actorId = options.actorId
		self._mountId = options.mountId
		self._isRecycle = options.isRecycle
		self._isReborn = options.isReborn
		self._callback = options.callback
	end
	self._isSelect = false
	if self._actorId or self._mountId or self._isRecycle or self._isReborn then
		self._isSelect = true
	end

	self._mountList = {}
	self._isListItemRuning = false
	-- local height = display.height + self._ccbOwner.sheet:getPositionY()
	-- self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width
	-- self._ccbOwner.sheet_layout:setPositionY(-height)
	-- self._ccbOwner.sheet_layout:setContentSize(CCSize(self._sheetLeyoutWidth, height))
	-- self._ccbOwner.node_no:setVisible(false)
	self._multiItems = 5
	self._spaceX = 10
	local width = 188
	local totalWidth = width * self._multiItems + self._spaceX * (self._multiItems )
	self._ccbOwner.sheet_layout:setContentSize(totalWidth, self._ccbOwner.sheet_layout:getContentSize().height - 77)
-- print("QUIDialogSoulSpiritOverView:ctor(options) ", self._ccbOwner.sheet_layout:getContentSize().width, self._ccbOwner.sheet_layout:getContentSize().height)
	self._sheetLeyoutWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.sp_grade_tips:setVisible(false)
end

function QUIDialogMountOverView:viewDidAppear()
    QUIDialogMountOverView.super.viewDidAppear(self)
    self:addBackEvent(true)

	self._eventProxy = cc.EventProxy.new(remote.mount)
    self._eventProxy:addEventListener(remote.mount.EVENT_UPDATE, handler(self,self.updateMountEvent))

    self:updateMount()
    
	if not (self._isReborn or self._isRecycle) then
		self:listItemRunOutAction()
	end
end

function QUIDialogMountOverView:viewWillDisappear()
    QUIDialogMountOverView.super.viewWillDisappear(self)
    self:removeBackEvent()

	self._eventProxy:removeAllEventListeners()

	if self._listItemRunInScheduler ~= nil then
		scheduler.unscheduleGlobal(self._listItemRunInScheduler)
		self._listItemRunInScheduler = nil
	end

	if self._listItemRunOutScheduler ~= nil then
		scheduler.unscheduleGlobal(self._listItemRunOutScheduler)
		self._listItemRunOutScheduler = nil
	end
end

function QUIDialogMountOverView:updateMountEvent(event)
	self:updateMount()
end

function QUIDialogMountOverView:checkRedTips()
	self._ccbOwner.sp_grade_tips:setVisible(remote.mount:checkSoulGuideRedTip())
end

function QUIDialogMountOverView:getShowMountInfo(info)
	local mountConfig = db:getCharacterByID(info.zuoqiId)
	local mount = {}
    mount.isCommon = false
    mount.isHave = true
    mount.actorId = info.actorId
    mount.mountId = info.zuoqiId
    mount.grade = info.grade
    mount.enhanceLevel = info.enhanceLevel
    mount.reformLevel = info.reformLevel
    mount.superZuoqiId = info.superZuoqiId
    mount.wearZuoqiInfo = info.wearZuoqiInfo
    mount.graveLevel = info.grave_level
    mount.force = 0
    mount.aptitude = mountConfig.aptitude

    return mount
end

function QUIDialogMountOverView:updateMount()
	local allMounts = remote.mount:getAllMounts()
	local haveMounts = clone(remote.mount:getMountMap())

	self._mountList = {} 
	if self._actorId then
	    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	    local oldMountInfo = clone(heroInfo.zuoqi)
	    for _, info in pairs(haveMounts) do
	    	local id = info.zuoqiId 
	    	local characher = db:getCharacterByID(id)
	    	if not characher.zuoqi_pj then -- 装备暗器时剔除暗器配件
		        heroInfo.zuoqi = {}
		        local oldHeroModel = QActorProp.new(heroInfo)
		        local oldBattleForce = math.ceil(oldHeroModel:getBattleForce(true))

		        heroInfo.zuoqi = info
		        local newHeroModel = QActorProp.new(heroInfo)
		        local newBattleForce = math.ceil(newHeroModel:getBattleForce(true))
		        
		        local mount = self:getShowMountInfo(info)
		        mount.force = newBattleForce - oldBattleForce

		        if oldMountInfo then
		        	if oldMountInfo.zuoqiId ~= info.zuoqiId then
		        		table.insert(self._mountList, mount)
		        	end
		        else
		        	table.insert(self._mountList, mount)
		        end
	    	end
	    end
	    heroInfo.zuoqi = oldMountInfo
	elseif self._isReborn then
		for _, info in pairs(haveMounts) do
			local mount = self:getShowMountInfo(info)
			local reformLevel = mount.reformLevel or 0
			local superZuoqiId = mount.superZuoqiId or 0
			local graveLevel = mount.graveLevel or 0
	        if mount.actorId == 0 and superZuoqiId == 0 and 
	        	(mount.enhanceLevel ~= 1 or mount.grade ~= 0 or reformLevel > 0 or graveLevel ~= 0) then
	        	table.insert(self._mountList, mount)
	        end
	    end
	elseif self._isRecycle then
		for _, info in pairs(haveMounts) do
			local mount = self:getShowMountInfo(info)
			local superZuoqiId = mount.superZuoqiId or 0
	        if mount.aptitude ~= APTITUDE.SSR and mount.actorId == 0 and superZuoqiId == 0 then
	       	 	table.insert(self._mountList, mount)
	       	end
	    end
	elseif self._mountId then
		for _, info in pairs(haveMounts) do
			local mount = self:getShowMountInfo(info)
			local superZuoqiId = mount.superZuoqiId or 0
	        if mount.aptitude == APTITUDE.S and superZuoqiId == 0 and mount.mountId ~= self._mountId then
	       	 	table.insert(self._mountList, mount)
	       	end
	    end
	else
		for i, mountId in ipairs(allMounts) do
			if not db:checkHeroShields(mountId) then
		    	local mountConfig = db:getCharacterByID(mountId)
				local mount = {}
				mount.mountId = mountId
		        mount.isCommon = false
		        mount.isHave = false
		        mount.actorId = 0
		        mount.aptitude = mountConfig.aptitude
				mount.force = 0

			    if haveMounts[mountId] then
			    	mount.isHave = true
		        	mount.actorId = haveMounts[mountId].actorId
		        	mount.grade = haveMounts[mountId].grade
			        mount.enhanceLevel = haveMounts[mountId].enhanceLevel
			        mount.reformLevel = haveMounts[mountId].reformLevel
			        mount.superZuoqiId = haveMounts[mountId].superZuoqiId
    				mount.wearZuoqiInfo = haveMounts[mountId].wearZuoqiInfo
			    else
			    	local config = db:getGradeByHeroActorLevel(mountId, 0)
			    	local haveNum = remote.items:getItemsNumByID(config.soul_gem)
		        	if haveNum >= config.soul_gem_count then
		        		mount.isCommon = true
		        	end
				end
				table.insert(self._mountList, mount)
			end
		end
	end

	table.sort( self._mountList, function(a, b)
			if a.isCommon ~= b.isCommon then
				return a.isCommon == true
			elseif a.isHave ~= b.isHave then
				return a.isHave == true
			elseif a.isHave == false and b.isHave == false then
				local aConfig = db:getGradeByHeroActorLevel(a.mountId, 0)
				local aHaveNum = remote.items:getItemsNumByID(aConfig.soul_gem)

				local bConfig = db:getGradeByHeroActorLevel(b.mountId, 0)
				local bHaveNum = remote.items:getItemsNumByID(bConfig.soul_gem)

				if a.aptitude ~= b.aptitude then
					return a.aptitude > b.aptitude
				else
					return aHaveNum > bHaveNum
				end
			else
    			if self._isSelect and a.actorId ~= b.actorId and (a.actorId == 0 or b.actorId == 0) then
                	return a.actorId == 0
                elseif a.force ~= b.force then
					return a.force > b.force
				elseif a.aptitude ~= b.aptitude then
    				return a.aptitude > b.aptitude
    			elseif a.grade ~= b.grade then
    				return a.grade > b.grade
    			elseif a.reformLevel and b.reformLevel and a.reformLevel ~= b.reformLevel then
    				return a.reformLevel > b.reformLevel
				elseif a.enhanceLevel ~= b.enhanceLevel then
    				return a.enhanceLevel > b.enhanceLevel
    			else
					return a.mountId > b.mountId
				end
			end
		end)

	self:initListView()
	self:checkRedTips()
	self._ccbOwner.node_no:setVisible(#self._mountList == 0)
end

function QUIDialogMountOverView:initListView()
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
	        totalNumber = #self._mountList,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._mountList})
	end
end

function QUIDialogMountOverView:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._mountList[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
		item = QUIWidgetMountOverView.new()
    	item:addEventListener(QUIWidgetMountOverView.MOUNT_EVENT_CLICK, handler(self, self._clickMount))
    	item:addEventListener(QUIWidgetMountOverView.MOUNT_EVENT_PIECE, handler(self, self._clickMount))
    	item:addEventListener(QUIWidgetMountOverView.MOUNT_EVENT_COMPOSE, handler(self, self._clickMount))
    	isCacheNode = false
    end
    item:setInfo(itemData, self._actorId ~= nil )
    info.item = item
    info.size = item:getContentSize()
   
    list:registerBtnHandler(index, "btn_banner", "_onTriggerClick") 

    return isCacheNode
end


function QUIDialogMountOverView:listItemRunOutAction()
	if self._isListItemRuning == true then return end
	self._listView:setCanNotTouchMove(true)
	self._isListItemRuning = true
	for i = 1, QUIDialogMountOverView.TOTAL_HERO_FRAME do
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

function QUIDialogMountOverView:listItemRunInAction()
	self._isListItemRuning = true
	local time = 0.17
	local i = 1
	local maxIndex = QUIDialogMountOverView.TOTAL_HERO_FRAME / (QUIDialogMountOverView.TOTAL_HERO_FRAME / self._multiItems)
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

function QUIDialogMountOverView:runTo(mountId, callback)
	if self._listView then
		for i, value in ipairs(self._mountList) do
			if value.mountId == mountId then
				self._listView:startScrollToIndex(i, nil, 40, callback);
				return true
			end
		end
		return true
	end
	return false
end

-- 选择英雄
function QUIDialogMountOverView:selectMount(mountId, actorId)		
	local closeFun = function()
		self:viewAnimationOutHandler()
		remote.mount:mountWareRequest(mountId, actorId, function ()
	    	remote.mount:dispatchEvent({name = remote.mount.EVENT_WEAR, mountId = mountId})
            remote.mount:dispatchEvent({name = remote.mount.EVENT_REFRESH_FORCE})
		end)
	end

	if remote.mount.heroMountShow then
		local callback = function(state, isSelect)
			if state == ALERT_TYPE.CONFIRM then
               	if isSelect then
            		remote.mount.heroMountShow = false
            	end
               	closeFun()
            end
		end
		local mountInfo = remote.mount:getMountById(mountId)
		if mountInfo.superMountId and mountInfo.superMountId ~= 0 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这个暗器已经佩戴在在其他魂导器上了，是否替换？"}, {isPopCurrentDialog = false}})
		elseif mountInfo.actorId and mountInfo.actorId ~= 0 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这个暗器已经装备在其他魂师身上了，是否替换？"}, {isPopCurrentDialog = false}})
		else
			closeFun()
		end
	else
		closeFun()
	end
end

-- 选择英雄
function QUIDialogMountOverView:selectWearMount(mountId, superMountId)		
	local closeFun = function()
		self:viewAnimationOutHandler()
		remote.mount:superMountWearRequest(mountId, superMountId, true, function ()
	    	remote.mount:dispatchEvent({name = remote.mount.EVENT_WEAR_MOUNT, mountId = mountId})
		end)
	end

	if remote.mount.mountMountShow then
		local callback = function(state, isSelect)
			if state == ALERT_TYPE.CONFIRM then
               	if isSelect then
            		remote.mount.mountMountShow = false
            	end
               	closeFun()
            end
		end
		local mountInfo = remote.mount:getMountById(mountId)
		if mountInfo.superMountId and mountInfo.superMountId ~= 0 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这个暗器已经佩戴在在其他魂导器上了，是否替换？"}, {isPopCurrentDialog = false}})
		elseif mountInfo.actorId and mountInfo.actorId ~= 0 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这个暗器已经装备在其他魂师身上了，是否替换？"}, {isPopCurrentDialog = false}})
		else
			closeFun()
		end
	else
		closeFun()
	end
end

function QUIDialogMountOverView:_clickMount(event)
	if self._isListItemRuning then return end
	app.sound:playSound("common_small")
	
	local mountId = event.info.mountId
	if event.name == QUIWidgetMountOverView.MOUNT_EVENT_CLICK then
		if self._actorId then
			self:selectMount(mountId, self._actorId)
		elseif self._isReborn or self._isRecycle then
			self:viewAnimationOutHandler()
			local mount = remote.mount:getMountById(mountId)
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogMountOverView.MOUNT_CLICK, mount = mount})
		elseif self._mountId then
			self:selectWearMount(mountId, self._mountId)
		else
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountInformation", 
	        	options={mountId = mountId}})
		end

	elseif event.name == QUIWidgetMountOverView.MOUNT_EVENT_PIECE then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountDetailInfoNew", 
	        	options={mountId = mountId}}, {isPopCurrentDialog = false})
	elseif event.name == QUIWidgetMountOverView.MOUNT_EVENT_COMPOSE then
		local combineCallback = function(data)
			remote.mount:mountCombineRequest(mountId,function()
				local mountConfig = db:getCharacterByID(mountId)
				if mountConfig.aptitude == APTITUDE.SS then
					local mountInfo = remote.mount:getMountById(mountId)
					local valueTbl = {}
		            valueTbl[mountId] = mountInfo.grade + 1
		            remote.activity:updateLocalDataByType(712, valueTbl)
		        end
				if self:safeCheck()	then
					local data = {actorId = mountId, grade = 0}
					self:commonSuccess(data)
				end
			end)
		end
		combineCallback()
	end
end

function QUIDialogMountOverView:commonSuccess(data)
	if self:safeCheck()	then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShowMountInfo", 
        	options= {actorId = data.actorId, isMount = true, callBack = function()
        		app.tip:creatMountCombinationTip(data.actorId)
        	end}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogMountOverView:_onTriggerCombination(event)
	if self._isListItemRuning then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_combination) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountCombination"})
end

function QUIDialogMountOverView:_onTriggerSoulGuide(event)
	if self._isListItemRuning then return end
	if q.buttonEventShadow(event, self._ccbOwner.btn_soul_guide) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSoulGuide"})
end


function QUIDialogMountOverView:_onTriggerGo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    app.sound:playSound("common_small")
    remote.metalCity:openDialog()
end

return QUIDialogMountOverView