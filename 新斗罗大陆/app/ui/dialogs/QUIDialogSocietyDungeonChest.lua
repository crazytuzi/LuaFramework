--
-- Author: Kumo.Wang
-- Date: Mon May 23 17:21:30 2016
-- Boss击杀宝箱主界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonChest = class("QUIDialogSocietyDungeonChest", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSocietyDungeonBossHead = import("..widgets.QUIWidgetSocietyDungeonBossHead")
local QUIWidgetSocietyDungeonChest = import("..widgets.QUIWidgetSocietyDungeonChest")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIViewController = import("..QUIViewController")
-- local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")

local BOSS_LINEDISTANCE = 10
local BOSS_ROWDISTANCE = 0

local CHEST_TOPDISTANCE = 10
local CHEST_LEFTDISTANCE = 142
local CHEST_LINEDISTANCE = 50
local CHEST_ROWDISTANCE = 120

local MAX_BOSS_ROW = 1
local MAX_CHEST_ROW = 3

function QUIDialogSocietyDungeonChest:ctor(options)
	local ccbFile = "ccb/Dialog_society_fuben_baoxiang.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, QUIDialogSocietyDungeonChest._onTriggerPreview)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonChest._onTriggerClose)},
	}
	QUIDialogSocietyDungeonChest.super.ctor(self, ccbFile, callBacks, options)
	self._ccbOwner.frame_tf_title:setString("宗门宝箱")

	self.isAnimation = true
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._callBack = options.callBack

	self._bossList = {}
	self._chestList = {}
	self._chapter = remote.union:getShowChapter()
	self._wave = options.wave or 1

	self._totalBossHeight = 0
	self._totalBossWidth = 0
	self._totalChestHeight = 0
	self._totalChestWidth = 0

    ------------------------------------------------------------------------------------------------------------------------------------

	self._bossHeight = self._ccbOwner.sheet_layout_boss:getContentSize().height
    self._bossWidth = self._ccbOwner.sheet_layout_boss:getContentSize().width

    self._scrollBossView = QScrollView.new(self._ccbOwner.sheet_boss, CCSize(self._bossWidth, self._bossHeight), { sensitiveDistance = 10, isNoTouch = false})
    self._scrollBossViewProxy = cc.EventProxy.new(self._scrollBossView)
    self._scrollBossViewProxy:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onBossEvent))
    self._scrollBossViewProxy:addEventListener(QScrollView.GESTURE_END, handler(self, self._onBossEvent))
    self._scrollBossViewProxy:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onBossEvent))
    self._scrollBossView:setVerticalBounce(true)
    self._scrollBossView:setGradient(false)

------------------------------------------------------------------------------------------------------------------------------------

	self._chestHeight = self._ccbOwner.sheet_layout_chest:getContentSize().height
    self._chestWidth = self._ccbOwner.sheet_layout_chest:getContentSize().width

    self._scrollChestView = QScrollView.new(self._ccbOwner.sheet_chest, CCSize(self._chestWidth, self._chestHeight), {sensitiveDistance = 10})
    self._scrollChestViewroxy = cc.EventProxy.new(self._scrollChestView)
    self._scrollChestViewroxy:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onChestEvent))
    self._scrollChestViewroxy:addEventListener(QScrollView.GESTURE_END, handler(self, self._onChestEvent))
    self._scrollChestViewroxy:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onChestEvent))

    self._scrollChestView:setVerticalBounce(true)
    self._scrollChestView:setGradient(false)

------------------------------------------------------------------------------------------------------------------------------------


	self:_init()
end

function QUIDialogSocietyDungeonChest:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonChest:viewDidAppear()
	QUIDialogSocietyDungeonChest.super.viewDidAppear(self)

end

function QUIDialogSocietyDungeonChest:viewWillDisappear()
	QUIDialogSocietyDungeonChest.super.viewWillDisappear(self)

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	self._scrollBossViewProxy:removeAllEventListeners()
	self._scrollBossView:clear()
    self._scrollChestViewroxy:removeAllEventListeners()
    self._scrollChestView:clear()

    if self._schedulerQScrollView then
        scheduler.unscheduleGlobal(self._schedulerQScrollView)
        self._schedulerQScrollView = nil
    end

    if self._lockScheduler then
		scheduler.unscheduleGlobal(self._lockScheduler)
		self._lockScheduler = nil
	end
end

function QUIDialogSocietyDungeonChest:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSocietyDungeonChest:_onTriggerClose()
	app.sound:playSound("common_cancel")
	if self._isLock then return end
	if self._callBack then
		self._callBack()
	end
   	self:playEffectOut()
end

function QUIDialogSocietyDungeonChest:_onTriggerPreview()
	app.sound:playSound("common_cancel")
	if self._isLock then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonChestPreview", 
		options = {chapter = self._chapter, wave = self._wave}}, {isPopCurrentDialog = false})
end

function QUIDialogSocietyDungeonChest:_onBossEvent( event )
	if event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	elseif event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_END then
		if self._schedulerQScrollView then
            scheduler.unscheduleGlobal(self._schedulerQScrollView)
            self._schedulerQScrollView = nil
        end
		self._schedulerQScrollView = scheduler.performWithDelayGlobal(function() 
	        self._isMoving = false 
	        if self._schedulerQScrollView then
	            scheduler.unscheduleGlobal(self._schedulerQScrollView)
	            self._schedulerQScrollView = nil
	        end
	    end, 0.5)
	end
end

function QUIDialogSocietyDungeonChest:_onChestEvent( event )
	if event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	elseif event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_END then
		if self._schedulerQScrollView then
            scheduler.unscheduleGlobal(self._schedulerQScrollView)
            self._schedulerQScrollView = nil
        end
		self._schedulerQScrollView = scheduler.performWithDelayGlobal(function() 
	        self._isMoving = false 
	        if self._schedulerQScrollView then
	            scheduler.unscheduleGlobal(self._schedulerQScrollView)
	            self._schedulerQScrollView = nil
	        end
	    end, 0.5)
	end
end

function QUIDialogSocietyDungeonChest:_onEvent( event )
	-- print("QUIDialogSocietyDungeonChest:_onEvent()", event.name)

	if event.name == QUIWidgetSocietyDungeonBossHead.EVENT_CLICK then
		if self._isMoving then return end

		if self._wave ~= event.wave then
			if self._lockScheduler then
				scheduler.unscheduleGlobal(self._lockScheduler)
				self._lockScheduler = nil
			end
			self._isLock = false
			self._wave = event.wave
			-- print("[Kumo] QUIWidgetSocietyDungeonBossHead.EVENT_CLICK ", self._wave, event.wave)
			self:_updateBossBtnState() 
			self:_initChestList()
		end
	elseif event.name == QUIWidgetSocietyDungeonChest.EVENT_CLICK then
		if self._isMoving then return end
		if not self._isInTime then
			-- local startTime = remote.union:getSocietyDungeonStartTime()
			-- local endTime = remote.union:getSocietyDungeonEndTime()
			app.tip:floatTip("当前时段无法领取")
			return
		end
		-- print("[Kumo] QUIWidgetSocietyDungeonChest.EVENT_CLICK ", event.wave, event.index)
		if self:_isBossDead() then
			if remote.union:isReceived( event.wave,  self._chapter) then
				app.tip:floatTip("魂师大人，这个BOSS的击杀宝箱您已经领取过了")
			else
				if self._lockScheduler then
					scheduler.unscheduleGlobal(self._lockScheduler)
					self._lockScheduler = nil
				end
				self._isLock = true
				self._lockScheduler = scheduler.performWithDelayGlobal(function() self._isLock = false end, 5)

				local oldItems = clone(remote.items:getOldItems())
				remote.union:unionGetWaveRewardRequest(event.wave, event.index, event.chapter, function ( response )
					-- 开启宝箱成功，播放获奖界面动画，更新宝箱的状态
					if response.isConsortiaBossBoxTaken then
						self._isLock = false
						app.tip:floatTip("魂师大人，这个宝箱已经被别人先领取了")
						if self:safeCheck() then
							self:_updateChestState()
						end
					else
						self._awards = {}
					    local tbl = {}
					    local wallet = {}
					    local items = {}

						if response and response.items then 
					    	items = response.items
					    	tbl = self:_mergeAwards(response.items)
					    end
					    for _,value in pairs(tbl) do
					    	local oldCount = self:_getOldItemsNumByID(oldItems, value.id)
					        table.insert(self._awards, {id = value.id, typeName = ITEM_TYPE.ITEM, count = value.count - oldCount})
					    end 

					    remote.user:update( wallet )
					    remote.items:setItems( items ) 
						remote.union:sendReceivedChestSuccess()
						
						if self:safeCheck() then
							self:_updateChestState(event.index)
							self:_updateBossBtnState()
						end
					end
				end)
			end
		else
			local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
			local character = QStaticDatabase.sharedDatabase():getCharacterByID(scoietyWaveConfig.boss)
			app.tip:floatTip("击杀BOSS"..character.name.."后才能开启宝箱")
		end
	elseif event.name == QUIWidgetSocietyDungeonChest.EVENT_OPENED then
		if self._isMoving then return end
		if self._awards and table.nums(self._awards) > 0 then
			local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		        options = {awards = self._awards, callBack = nil}}, {isPopCurrentDialog = false} )
		    dialog:setTitle("恭喜您获得宝藏奖励")
		    if self._lockScheduler then
				scheduler.unscheduleGlobal(self._lockScheduler)
				self._lockScheduler = nil
			end
			self._lockScheduler = scheduler.performWithDelayGlobal(function() self._isLock = false end, 1)
		end

	end
end

function QUIDialogSocietyDungeonChest:_getOldItemsNumByID( oldItems, id )
	if q.isEmpty(oldItems) then return 0 end

	for _, item in pairs(oldItems) do
		if tonumber(item.type) == tonumber(id) then
			return item.count
		end
	end

	return 0
end

function QUIDialogSocietyDungeonChest:_mergeAwards( awards )
	if not awards or table.nums(awards) == 0 then return end

	local tbl = {}
	for _, value in pairs( awards ) do
		local key = value.type or value.typeName
		key = tostring(value.type)
		if not tbl[key] then
			tbl[key] = {id = value.type, count = value.count}
		else
			tbl[key].count = tbl[key].count + value.count
		end
	end

	return tbl
end

function QUIDialogSocietyDungeonChest:_init()
	self:_initBossHeadList()
	self:_initChestList()

	-- 和时间有关的数据
	self:_updateTime()
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIDialogSocietyDungeonChest:_initBossHeadList()
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if not bossList or #bossList == 0 then return end

	local row = 0
	local height = 0
	local width = 0
	local line = 0
	self._scrollBossView:clear()
	self._totalBossHeight = 0

	for _, value in pairs(bossList) do
		local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(value.wave, value.chapter)
		if scoietyWaveConfig and scoietyWaveConfig.sociaty_box then
			local head = QUIWidgetSocietyDungeonBossHead.new(value)
			head:addEventListener(QUIWidgetSocietyDungeonBossHead.EVENT_CLICK, handler(self, self._onEvent))
			self._scrollBossView:addItemBox(head)
			-- table.insert( self._bossList, head )
			self._bossList[value.wave] = head

			height = head:getHeight()
			width = head:getWidth()
			local positionX = BOSS_ROWDISTANCE * (row + 1)
			local positionY = -(height * line + BOSS_LINEDISTANCE * (line + 1))
			head:setPosition(ccp(positionX, positionY))

			row = row + 1
			if row % MAX_BOSS_ROW == 0 then
				line = line + 1
				row = 0
			end
		end
	end
	self._totalBossHeight = self._totalBossHeight + (height + BOSS_LINEDISTANCE) * (line + 0)
	self._totalBossWidth = self._totalBossWidth + (width + BOSS_ROWDISTANCE) * MAX_BOSS_ROW
	self._scrollBossView:setRect(0, -self._totalBossHeight, 0, -self._totalBossWidth)

	if self._wave == 5 or self._wave == 6 then
		self._scrollBossView:runToBottom()
	end
	self:_updateBossBtnState() 
end

function QUIDialogSocietyDungeonChest:_initChestList()
	local row = 0
	local height = 0
	local width = 0
	local line = 0
	self._scrollChestView:clear()

	local maxLevel = QStaticDatabase.sharedDatabase():getMaxSocietyLevel()
	local count = QStaticDatabase.sharedDatabase():getSocietyMemberLimitByLevel(maxLevel)
	self._totalChestHeight = 0
	local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	local isBoss = scoietyWaveConfig.is_final_boss and true or false
	for i = 1, count, 1 do
		local chest = QUIWidgetSocietyDungeonChest.new( {index = i, wave = self._wave, chapter = self._chapter, isBoss = isBoss} )
		chest:addEventListener(QUIWidgetSocietyDungeonChest.EVENT_CLICK, handler(self, self._onEvent))
		chest:addEventListener(QUIWidgetSocietyDungeonChest.EVENT_OPENED, handler(self, self._onEvent))
		self._scrollChestView:addItemBox(chest)
		-- table.insert( self._chestList, chest )
		self._chestList[i] = chest

		height = chest:getHeight()
		width = chest:getWidth()
		local positionX = (width + CHEST_ROWDISTANCE) * row + CHEST_LEFTDISTANCE
		local positionY = -((height + CHEST_LINEDISTANCE) * line + CHEST_TOPDISTANCE)
		chest:setPosition(ccp(positionX, positionY))

		row = row + 1
		if row % MAX_CHEST_ROW == 0 then
			line = line + 1
			row = 0
		end
	end

	if row == 0 and line > 0 then
		line = line - 1
	end

	self._totalChestHeight = self._totalChestHeight + (height + CHEST_LINEDISTANCE) * (line + 1) + CHEST_TOPDISTANCE
	self._totalChestWidth = self._totalChestWidth + (width + CHEST_ROWDISTANCE) * MAX_CHEST_ROW + CHEST_LEFTDISTANCE
	self._scrollChestView:setRect(0, -self._totalChestHeight, 0, -self._totalChestWidth)

	self:_updateChestState()
end

-- 一些时间上的设定
-- 10:00 ~ 22:00 可击杀BOSS
-- 10:00 ~ 5:00 击杀BOSS之后可以领取宝箱
-- 5:00 刷新宝箱
-- 总结下来，宝箱的领取条件只有一个，BOSS死亡！
function QUIDialogSocietyDungeonChest:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	if curTimeTbl.hour < startTime and curTimeTbl.hour >= 5 then
		self._isInTime = false
		self._ccbOwner.tf_info:setString("宗门副本开启时间为 "..startTime.."：00 至 "..endTime.."：00")
	else
		self._isInTime = true
		local isDead = self:_isBossDead()
		local maxH = endTime - 1
		local h,m,s = 0,0,0
		h = maxH - curTimeTbl.hour
		m = 59 - curTimeTbl.min
		s = 60 - curTimeTbl.sec
		local timeStr = string.format("%02d:%02d:%02d", h, m, s)
		-- print("===============")
		-- print(string.format("%02d:%02d:%02d", curTimeTbl.hour, curTimeTbl.min, curTimeTbl.sec))
		-- print(timeStr)
		-- print("===============")
		
		if isDead then
			self._ccbOwner.tf_info:setString("每日5点重置，请尽快领取")
			-- self._ccbOwner.tf_info:setString(timeStr.."后消失，请尽快领取")
		else
			if h < 0 then 
				self._ccbOwner.tf_info:setString("很遗憾，BOSS未能在规定时间内被击杀")
			else
				self._ccbOwner.tf_info:setString(timeStr.."内击杀，可以领取")
			end
		end
	end
end

function QUIDialogSocietyDungeonChest:_updateBossBtnState()
	for _, head in pairs(self._bossList) do
		head:update(self._wave)
	end

	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if bossList and #bossList > 0 then
		for _, boss in pairs(bossList) do
			if self._bossList[boss.wave] then
				self._bossList[boss.wave]:updateHp(boss.bossHp)
			end
		end
	end
end

function QUIDialogSocietyDungeonChest:_updateChestState( curIndex )
	local bossList = remote.union:getConsortiaBossList(self._chapter)

	for _, boss in pairs(bossList or {}) do
		if boss.wave == self._wave then
			if boss.bossAwardList and #boss.bossAwardList > 0 then
				-- 有宝箱被开启
				for _, value in pairs(boss.bossAwardList) do
					if value.boxId == curIndex then
						self._chestList[value.boxId]:openChest(value)
					else
						self._chestList[value.boxId]:update(value)
					end
				end
			else
				for _, chest in pairs(self._chestList) do
					chest:update()
				end
			end
		end
	end
end

function QUIDialogSocietyDungeonChest:_isBossDead()
	local bossList = remote.union:getConsortiaBossList(self._chapter)

	if not bossList or #bossList == 0 then return false end

	for _, boss in pairs(bossList) do
		-- print("[Kumo] QUIDialogSocietyDungeonChest:_isBossDead() ", boss.wave, self._wave, boss.bossHp)
		if boss.wave == self._wave and boss.bossHp == 0 then
			return true
		end
	end

	return false
end

function QUIDialogSocietyDungeonChest:_isInTheTime()
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	if curTimeTbl.hour < startTime and curTimeTbl.hour >= 5 then
		return false
	else
		return true
	end
end

return QUIDialogSocietyDungeonChest