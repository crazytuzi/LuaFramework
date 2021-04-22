
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroOverview = class(".QUIDialogHeroOverview", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QUIWidgetHeroDetailFrame = import("..widgets.QUIWidgetHeroDetailFrame")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroFrame = import("..widgets.QUIWidgetHeroFrame")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
-- local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView")

QUIDialogHeroOverview.TOTAL_HERO_FRAME = 7

QUIDialogHeroOverview.SELECT_CLICK = "SELECT_CLICK"

-- 魂师总览界面
function QUIDialogHeroOverview:ctor(options)
	local ccbFile = "ccb/Dialog_HeroOverview1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHandBook", 			callback = handler(self, QUIDialogHeroOverview._onTriggerHandBook)},
		{ccbCallbackName = "onTriggerFashion", 				callback = handler(self, QUIDialogHeroOverview._onTriggerFashion)},
	}
	QUIDialogHeroOverview.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_fashion)

	self._isPreHeat = options and options.preheat or false
	if not self._isPreHeat then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page.setManyUIVisible then page:setManyUIVisible() end
		if page.topBar then
	    	page.topBar:showWithStyle({TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE})
	    end
   end

   	--全面屏适配
	self._ccbOwner.sheet:setPositionX(-display.ui_width / 2)
	local size = self._ccbOwner.sheet_layout:getContentSize()
	size.width = display.ui_width
	self._ccbOwner.sheet_layout:setContentSize(size)
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	--初始化事件监听器
	self._eventProxy = QNotificationCenter.new()

	self._nativeActorIds = remote.herosUtil:getShowHerosKey()
	self._actorIds = self._nativeActorIds
	self._haveHerosID = remote.herosUtil:getHaveHero()
	self._datas = {}

	self._itemBoxAniamtion = false
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	
	-- 魂师重生界面 1.隐藏未召唤魂师 2.点击魂师退出当前界面
	if options ~= nil then
		self._heroReborn = options.heroReborn
		self._heroRecycle = options.heroRecycle
		self._mountEquip = options.mountEquip
		self._soulSpiritEquip = options.soulSpiritEquip
		self._exchangeModel = options.exchangeModel
	end
	-- 是否选择英雄
	self._isSelect = self._heroReborn or self._heroRecycle or self._mountEquip or self._soulSpiritEquip
	self._isFrist = false
	self._isMove = false
	self._heroClient = {}

	self:_selectTab()
end

function QUIDialogHeroOverview:viewDidAppear()
	QUIDialogHeroOverview.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
    self._remoteProxy:addEventListener(QRemote.TEAMS_UPDATE_EVENT, handler(self, self.onEvent))

    self._itemsProxy = cc.EventProxy.new(remote.items)
    self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	self:addBackEvent()

	self:_updateRedTips()
end

function QUIDialogHeroOverview:viewWillDisappear()
	QUIDialogHeroOverview.super.viewWillDisappear(self)
    self._remoteProxy:removeAllEventListeners()
    self._itemsProxy:removeAllEventListeners()
	self:removeBackEvent()

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

	if self._timeScheduler1 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler1)
		self._timeScheduler1 = nil
	end

	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end
end

function QUIDialogHeroOverview:_updateRedTips()
	self._ccbOwner.sp_handbook_red_tips:setVisible(remote.handBook:checkRedTips())
	self._ccbOwner.sp_fashion_red_tips:setVisible(remote.fashion:checkRedTips())
end

-- 更新魂师数据
function QUIDialogHeroOverview:_onHeroDataUpdate()
	self._nativeActorIds = remote.herosUtil:getShowHerosKey()
	self._actorIds = self._nativeActorIds
	self:_filterHerosByTalent()
	self._haveHerosID = {}
	self._noExistHeros = {}
	self._synthesisHeros = {}

	local lockConfig = app.unlock:getConfigByKey("UNLOCK_ZUOQI") or {}
    local mountLevel = lockConfig.hero_level or 0
	for _, actorId in ipairs(self._actorIds) do
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		if heroInfo ~= nil then
			if self._exchangeModel then
				-- 这个模式必定是万能碎片，于是需要判断是不是已经到最高升星级别了。
				local nextGrade = db:getGradeByHeroActorLevel(actorId, heroInfo.grade + 1)
				if nextGrade then
					local soulGemCount = nextGrade.soul_gem_count or 0
					local devourConsume = nextGrade.super_devour_consume or 0
					-- 不显示ss
					if soulGemCount > 0 then--or devourConsume > 0
						table.insert(self._haveHerosID, actorId)
					end
				end
			elseif self._mountEquip then
				if heroInfo.level >= mountLevel then
					table.insert(self._haveHerosID, actorId)
				end
			elseif self._heroRecycle then
					-- 分解只显示B—A+魂师
				local characher = db:getCharacterByID(actorId)
				printf("characher.aptitude"..characher.aptitude)
				if characher.aptitude < tonumber(APTITUDE.S) then
					table.insert(self._haveHerosID, actorId)
				end	
			else
				table.insert(self._haveHerosID, actorId)
			end
		else
			if not self._exchangeModel then
				local gradeInfo = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId, 0)
				local currentGemCount = remote.items:getItemsNumByID(gradeInfo.soul_gem)
				-- can summon the hero
				if currentGemCount >= gradeInfo.soul_gem_count then
					table.insert(self._synthesisHeros, actorId)
				else
					table.insert(self._noExistHeros, actorId)
				end
			end
		end
	end

	table.sort(self._synthesisHeros, function (a, b)
		local gradeInfoA = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(a, 0)
		local gradeInfoB = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(b, 0)
		local gemCountA = remote.items:getItemsNumByID(gradeInfoA.soul_gem)
		local gemCountB = remote.items:getItemsNumByID(gradeInfoB.soul_gem)

		if gemCountA ~= gemCountB then
			return gemCountA > gemCountB
		else
			return a > b
		end
	end)

	table.sort(self._haveHerosID, function (a, b)
		local heroPropA = remote.herosUtil:createHeroPropById(a)
		local heroPropB = remote.herosUtil:createHeroPropById(b)

		if heroPropA and heroPropB then
			local attackA = heroPropA:getBattleForce()
			local attackB = heroPropB:getBattleForce()
			if attackA ~= attackB then
				return attackA > attackB
			end
		end

		local characherA = QStaticDatabase:sharedDatabase():getCharacterByID(a)
		local characherB = QStaticDatabase:sharedDatabase():getCharacterByID(b)
		if characherA ~= nil and characherB ~= nil then
			return characherA.grade > characherB.grade
		else
			return a > b
		end
	end)

	table.sort(self._noExistHeros, function (a, b)
		local characherA = QStaticDatabase:sharedDatabase():getCharacterByID(a)
		local characherB = QStaticDatabase:sharedDatabase():getCharacterByID(b)
		local gradeInfoA = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(a, 0)
		local gradeInfoB = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(b, 0)
		local gemCountA = remote.items:getItemsNumByID(gradeInfoA.soul_gem)
		local gemCountB = remote.items:getItemsNumByID(gradeInfoB.soul_gem)
		
		if characherA.aptitude ~= characherB.aptitude then
			return characherA.aptitude > characherB.aptitude
		else
			if gemCountA ~= gemCountB then
				return gemCountA > gemCountB
			else
				return a > b
			end
		end
	end)
end

function QUIDialogHeroOverview:initListView( ... )
	-- body
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._datas[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetHeroDetailFrame.new()

	            	isCacheNode = false
	            end
	            item:setInfo({actorId = itemData})
	            info.item = item
	            info.size = item:getContentSize()
	            list:registerBtnHandler(index, "button_heroOverView", handler(self, self._clickHeroFrameHandler))
	            return isCacheNode
	        end,
	        curOriginOffset = 10,
	        spaceX = -5,
	        enableShadow = false,
	        isVertical = false,
	        totalNumber = #self._datas,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listView:reload({totalNumber = #self._datas})
	end

end

function QUIDialogHeroOverview:itemBoxRunOutAction()
	if self._itemBoxAniamtion == true then return end
	self._listView:setCanNotTouchMove(true)
	self._itemBoxAniamtion = true
	for index = 1,QUIDialogHeroOverview.TOTAL_HERO_FRAME do
		local itemBox1
		if self._listView then
			itemBox1 = self._listView:getItemByIndex(index)
		end
		if itemBox1 ~= nil then
			local posx,posy = itemBox1:getPosition()
			itemBox1:setPosition(ccp(posx+self._itemWidth,posy))	
		end
	end

	self.func1 = function()
		self._checkItemScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:itemBoxRunInAction()
			end
		end, 0.02)
	end
	self.func1()
end 

function QUIDialogHeroOverview:itemBoxRunInAction()
	self._itemBoxAniamtion = true
	self.time = 0.15
	local index = 1
	self.func2 = function()
		if index <= QUIDialogHeroOverview.TOTAL_HERO_FRAME then
			local itemBox1 = self._listView:getItemByIndex(index)
			if itemBox1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(itemBox1, self.time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(self.time, ccp(-self._itemWidth,0))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				itemBox1:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler2 = scheduler.performWithDelayGlobal(self.func2, 0.05)
		else
			self.func3 = function()
				self._timeScheduler1 = scheduler.performWithDelayGlobal(function()
					if self:safeCheck() then
						self._itemBoxAniamtion = false
						self._listView:setCanNotTouchMove(false)
					end
				end, 0.1)
			end
			self.func3()

		end
	end
	self.func2()
end 

--切换table后调用
function QUIDialogHeroOverview:_updateCurrentPage()
	self:_onHeroDataUpdate()
	self._heroClient = {}
	self._datas = {}
	
	local row = 0
	local rowDistance = -8
	local totalWidth = 0
	local totalHeight = 0
	local offsetX = -5
	local offsetY = 38

	if self._isSelect then
		for i = 1, #self._haveHerosID do
			if self._heroRecycle then
				local characher = db:getCharacterByID(self._haveHerosID[i])
				if characher.aptitude ~= APTITUDE.SS then
					table.insert(self._datas, self._haveHerosID[i])
					table.insert(self._actorIds, self._haveHerosID[i])
				end
			else
				table.insert(self._datas, self._haveHerosID[i])
				table.insert(self._actorIds, self._haveHerosID[i])
			end
		end
	else
		local part_one = {} -- 可以合成的ss魂师 或者 未收集的魂师
		local part_third = {} -- 可以合成的已收集非ss魂师

		for i = 1, #self._synthesisHeros do 
			local isCollected = remote.herosUtil:checkHeroHavePast(self._synthesisHeros[i])
			local characher = db:getCharacterByID(self._synthesisHeros[i])
			if not isCollected or characher.aptitude >= APTITUDE.SS then
				table.insert(part_one, self._synthesisHeros[i])
			else
				table.insert(part_third, self._synthesisHeros[i])
			end
		end


		for i = 1, #part_one do 
			table.insert(self._datas, part_one[i])
			table.insert(self._actorIds, part_one[i])
		end

		for i = 1, #self._haveHerosID do 
			table.insert(self._datas, self._haveHerosID[i])
			table.insert(self._actorIds, self._haveHerosID[i])
		end

		for i = 1, #part_third do 
			table.insert(self._datas, part_third[i])
			table.insert(self._actorIds, part_third[i])
		end

		for i = 1, #self._noExistHeros do 
			table.insert(self._datas, self._noExistHeros[i])
			table.insert(self._actorIds, self._noExistHeros[i])
		end
	end

	-- self:initListView()
end

-- filter 魂师根据魂师的天赋
function QUIDialogHeroOverview:_filterHerosByTalent()
	if self.tab == QUIDialogHeroOverview.TAB_ALL then
		-- 显示全部魂师不做任何filter
		return 
	end

	local db = QStaticDatabase:sharedDatabase()

	if self._actorIds ~= nil then
		local result = {}

		for _, actorId in ipairs(self._actorIds) do
			local _, genre = db:getHeroGenreById(actorId)

			if self.tab == QUIDialogHeroOverview.TAB_TANK then
				if genre == 1 then
					result[#result + 1] = actorId
				end
			elseif self.tab == QUIDialogHeroOverview.TAB_HEAL then
				if genre == 2 then
					result[#result + 1] = actorId
				end
			elseif self.tab == QUIDialogHeroOverview.TAB_PHYSICAL then
				if genre == 3 then
					result[#result + 1] = actorId
				end
			elseif self.tab == QUIDialogHeroOverview.TAB_MAGIC then
				if genre == 4 then
					result[#result + 1] = actorId
				end
			end
		end
		self._actorIds = result
		return 
	end
	return 
end
 
-- 选择tab
function QUIDialogHeroOverview:_selectTab(isSound)
	if isSound == true then
		app.sound:playSound("common_switch")
	end

	self:_updateCurrentPage()

	self:initListView()

	if not self._heroReborn or not self._heroRecycle then
		self:itemBoxRunOutAction()
	end
end

function QUIDialogHeroOverview:runTo(actorId, callback)
	if self._listView then
		for i, value in ipairs(self._datas) do
			if value == actorId then
				self._listView:startScrollToIndex(i, nil, 40, callback);
				return true
			end
		end
		return true
	end
	return false
end

function QUIDialogHeroOverview:getActorIds()
	return self._actorIds or {}
end

-- 处理各种touch event
function QUIDialogHeroOverview:onEvent(event)
	if event == nil or event.name == nil or self._isMove or self._itemBoxAniamtion then
        return
    end

    if event.name == QRemote.HERO_UPDATE_EVENT or event.name == remote.items.ITEMS_UPDATE_EVENT or event.name == QRemote.TEAMS_UPDATE_EVENT then
		self:_updateCurrentPage()
	elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
		if self._listView then
			self._listView:refreshData()
		end
	elseif event.name == QUIWidgetHeroFrame.EVENT_HERO_FRAMES_CLICK then
  		if self._exchangeModel then
			local pos = 0
			for i, actorId in ipairs(self._haveHerosID) do
				if actorId == event.actorId then
					pos = i
					break
				end
			end
			local heroInfo = remote.herosUtil:getHeroByID(event.actorId)
	  		if pos > 0 and heroInfo ~= nil then
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
				 	options = {hero = self._haveHerosID, pos = pos}})
				self._dialogScheduler = scheduler.performWithDelayGlobal(function()
		    			local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(event.actorId, heroInfo.grade+1)
		    			local needSoulNum = gradeConfig.soul_gem_count or 10
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogExchangeHeroSoul",
							options = {actorId = event.actorId, needNum = needSoulNum}})
					end, 0)
			end
			return
		end
    end
end

function QUIDialogHeroOverview:_clickHeroFrameHandler( x, y, touchNode, listView )
	app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectActorId = self._datas[touchIndex]
	self:selectHeroByActorId(selectActorId)
end

-- 选择英雄
function QUIDialogHeroOverview:selectHero(actorId)		
	local closeFun = function()
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogHeroOverview.SELECT_CLICK, actorId = actorId})
	end

	if self._mountEquip and remote.mount.mountHeroShow then
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		if heroInfo.zuoqi then
			local callback = function(state, isSelect)
				if state == ALERT_TYPE.CONFIRM then
	               	if isSelect then
	            		remote.mount.mountHeroShow = false
	            	end
	               	closeFun()
	            end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这名魂师已经装备了其他暗器，是否替换？"}})
			return
		end
	elseif self._soulSpiritEquip and remote.soulSpirit.soulSpiritHeroShow then
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		if heroInfo.soulSpirit then
			local callback = function(state, isSelect)
				if state == ALERT_TYPE.CONFIRM then
	               	if isSelect then
	            		remote.soulSpirit.soulSpiritHeroShow = false
	            	end
	               	closeFun()
	            end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSelectAlert",
				options = {callback = callback, desc = "这名魂师已经被其他魂灵护佑了，是否替换？"}})
			return
		end
	end
	
	closeFun()
end

function QUIDialogHeroOverview:selectHeroByActorId(selectActorId)
	-- 选择英雄
	if self._isSelect then
		self:selectHero(selectActorId)
		return
	end

	local pos = 0
	for i, actorId in ipairs(self._haveHerosID) do
		if actorId == selectActorId then
			pos = i
			break
		end

	end
	if pos > 0 and remote.herosUtil:getHeroByID(selectActorId) ~= nil then
		local hero_info_dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
		 options = {hero = self._haveHerosID, pos = pos}})
		if self._exchangeModel then
			local heroInfo = remote.herosUtil:getHeroByID(selectActorId)
			self._dialogScheduler = scheduler.performWithDelayGlobal(function()
    			local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(selectActorId, heroInfo.grade+1)
    			local needSoulNum = gradeConfig.soul_gem_count or 10
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogExchangeHeroSoul",
					options = {actorId = selectActorId, needNum = needSoulNum}})
			end, 0)
		end
	else
		local characher = QStaticDatabase:sharedDatabase():getCharacterByID(selectActorId)
		local grade_info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(selectActorId, characher.grade or 0)
		local soulGemId = grade_info.soul_gem
		local currentGemCount = remote.items:getItemsNumByID(soulGemId)
		local needGemCount = QStaticDatabase:sharedDatabase():getNeedSoulByHeroActorLevel(selectActorId, characher.grade or 0)

		-- can summon the hero
		if currentGemCount >= needGemCount then
			local displayInfo = QStaticDatabase:sharedDatabase():getCharacterByID(selectActorId)
			app:getClient():summonHero(selectActorId,function()
					if self:safeCheck() then
						self:_updateCurrentPage()
						self:initListView()
					end
		            local heroInfo = remote.herosUtil:getHeroByID(selectActorId)
		            local godSkillGrade = heroInfo.godSkillGrade or 0
		            if godSkillGrade > 0 then
		                local valueTbl = {}
		                valueTbl[selectActorId] = godSkillGrade
		                remote.activity:updateLocalDataByType(711, valueTbl)
		            end
		    		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHeroCard", 
		        		options={actorId = selectActorId, callBack = function()
					        	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
								if page.class.__cname == "QUIPageMainMenu" then
									page:buildLayer()
									page:checkGuiad()
								end
				        	end}})
				end)
		else
			app.tip:itemTip(ITEM_TYPE.HERO, selectActorId, true)
		end
	end
end

function QUIDialogHeroOverview:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogHeroOverview:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogHeroOverview:_onTriggerHandBook(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_handBook) == false then return end
    app.sound:playSound("common_small")
	remote.handBook:openDialog()
end

function QUIDialogHeroOverview:_onTriggerFashion()
	app.sound:playSound("common_small")
	remote.fashion:openDialog()
end

function QUIDialogHeroOverview:showEffect(frame, isShow)
	if frame.isEffectShow == isShow then 
		return 
	end
	if isShow == false then
		frame.isEffectShow = isShow
		if frame.effect ~= nil then
			frame.effect:disappear()
			frame.effect:removeFromParentAndCleanup(true)
			frame.effect = nil
		end
	end
end

function QUIDialogHeroOverview:showSabcEffect(frame, isShow)
	if frame.isSabcEffectShow == isShow then 
		return 
	end
	if isShow == false then
		frame.isSabcEffectShow = isShow
		if frame.sabcEffect ~= nil then
			frame.sabcEffect:disappear()
			frame.sabcEffect:removeFromParentAndCleanup(true)
			frame.sabcEffect = nil
		end
	elseif isShow == true then
		local characher = QStaticDatabase:sharedDatabase():getCharacterByID(frame.actorId)
	    if not characher or not characher.aptitude then return end
	    local sabc = characher.aptitude
	    local ccbFile = ""
	    local scale = 1
	    local offsetX = 0
	    local offsetY = 0
	    if sabc == 20 then
	    	-- S
	    	ccbFile = "effects/star_light_s.ccbi"
	    	scale = 0.35
	    	offsetX = -172
	    	offsetY = 105
		elseif sabc == 15 or sabc == 18 then
			-- A or A+
			ccbFile = "effects/star_light_a.ccbi"
			scale = 0.45
			offsetX = -172
			offsetY = 100
		end
		if ccbFile ~= "" then
			local effect = QUIWidgetAnimationPlayer.new()
			effect:playAnimation(ccbFile,nil,nil,false)
			effect:setScale(scale)
			self._sp:addChild(effect)
			frame.sabcEffect = effect
			frame.isSabcEffectShow = isShow
			frame.sabcEffect:setPosition(ccp(frame.posX + offsetX, frame.posY + offsetY))
		end
	end
end

return QUIDialogHeroOverview
