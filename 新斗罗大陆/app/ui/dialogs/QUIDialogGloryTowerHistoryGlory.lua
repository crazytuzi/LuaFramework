-- @Author: xurui
-- @Date:   2016-08-18 14:48:15
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 11:10:27
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryTowerHistoryGlory = class("QUIDialogGloryTowerHistoryGlory", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGloryTowerHistoryGlory = import("..widgets.QUIWidgetGloryTowerHistoryGlory")
local QUIDialogGloryTowerChooseSeason = import("..dialogs.QUIDialogGloryTowerChooseSeason")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIDialogGloryTowerHistoryGlory.Tiers = 1
QUIDialogGloryTowerHistoryGlory.GloryArena = 2

function QUIDialogGloryTowerHistoryGlory:ctor(options)
	local ccbFile = "ccb/Dialog_GloryTower_ryq.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTiers", callback = handler(self, self._onTriggerTiers)},
		{ccbCallbackName = "onTriggerArena", callback = handler(self, self._onTriggerArena)},
		{ccbCallbackName = "onTriggerChooseSeason", callback = handler(self, self._onTriggerChooseSeason)},
	}
	QUIDialogGloryTowerHistoryGlory.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
    
    CalculateUIBgSize(self._ccbOwner.sp_GloryArena_bg)
	
    if not options then
    	options = {}
    end

    self._data = options.data or {}
    self._historyType = options.historyType or QUIDialogGloryTowerHistoryGlory.Tiers

    if math.abs(display.height - UI_DESIGN_HEIGHT) < 55 then
		self._ccbOwner.node_bg:setPositionY(self._ccbOwner.node_bg:getPositionY()-55)
		self._ccbOwner.node_fighter_1:setPositionY(self._ccbOwner.node_fighter_1:getPositionY()-55)
		self._ccbOwner.node_fighter_2:setPositionY(self._ccbOwner.node_fighter_2:getPositionY()-55)
		self._ccbOwner.node_fighter_3:setPositionY(self._ccbOwner.node_fighter_3:getPositionY()-55)
	end

    self._fighter = {}

    self._tiersData = {}
    self._arenaData = {}
    self._seasonInfo = {}
    self._seasonNO = 0

    local nowTime = q.serverTime() - 30 * MIN
    local nowDateTable = q.date("*t", nowTime)

    local beginTime = 0
    if nowDateTable.wday < 2 then
    	beginTime = nowTime - 6 * DAY - nowDateTable.hour*HOUR - nowDateTable.min*MIN - nowDateTable.sec
    else
    	beginTime = nowTime - (nowDateTable.wday - 2) * DAY - nowDateTable.hour*HOUR - nowDateTable.min*MIN - nowDateTable.sec
    end

  
    self._curBeginTime = beginTime

    local maxTiersSeason = 0
    local maxArenaSeason = 0

    for k,v in pairs(self._data) do
    	if tonumber(v.type) == 2 then
    		if maxArenaSeason < v.seasonNO then
    			maxArenaSeason = v.seasonNO
    		end
    		table.insert( self._arenaData, v )
    	else
    		if maxTiersSeason < v.seasonNO then
    			maxTiersSeason = v.seasonNO
    		end
    		table.insert( self._tiersData, v )
    	end
    end

    local maxSeason = maxTiersSeason > maxArenaSeason and maxTiersSeason or maxArenaSeason

    if remote.tower:isTowerFightStage() then
    	self._curSeason = maxSeason
    else
    	self._curSeason = maxSeason + 1
    end

    if self._curSeason < 1 then
    	self._curSeason = 1
    end


    for k,v in pairs(self._arenaData) do
		v.beginDateStr = q.timeToYearMonthDay( beginTime - (self._curSeason - v.seasonNO)*7*DAY )
		v.endDateStr = q.timeToYearMonthDay( beginTime - (self._curSeason - v.seasonNO - 1)*7*DAY -1)
    end

    for k,v in pairs(self._tiersData) do
    	v.beginDateStr = q.timeToYearMonthDay( beginTime - (self._curSeason - v.seasonNO)*7*DAY)
		v.endDateStr = q.timeToYearMonthDay( beginTime - (self._curSeason - v.seasonNO - 1)*7*DAY -1)
    end

    table.sort(self._tiersData, function ( a,b )
    	-- body
    	return a.seasonNO > b.seasonNO
    end )

    table.sort(self._arenaData, function ( a,b )
    	-- body
    	return a.seasonNO > b.seasonNO
    end )


-- 
end


function QUIDialogGloryTowerHistoryGlory:fillInfo(  )
	-- body
	self._seasonInfo = {}
	if self._historyType == QUIDialogGloryTowerHistoryGlory.Tiers then
		-- if self._seasonNO == 0 and #self._tiersData ~= 0 then
		-- 	self._seasonNO = self._tiersData[1].seasonNO
		-- end

		for k , v in pairs(self._tiersData) do
			if self._seasonNO == v.seasonNO then
				self._seasonInfo = v
				return 
			end
		end

		if #self._tiersData == 0 then
			self._seasonInfo.beginDateStr = q.timeToYearMonthDay(self._curBeginTime)
			self._seasonInfo.endDateStr = q.timeToYearMonthDay(self._curBeginTime + 7*DAY - 1)
			self._seasonInfo.seasonNO = self._curSeason
			self._seasonInfo.gloryFighters = {}
			return
		else
			self._seasonNO = self._tiersData[1].seasonNO
			for k , v in pairs(self._tiersData) do
				if self._seasonNO == v.seasonNO then
					self._seasonInfo = v
					return 
				end
			end
		end
	else
		-- if self._seasonNO == 0 and #self._arenaData ~= 0 then
		-- 	self._seasonNO = self._arenaData[1].seasonNO
		-- end

		for k , v in pairs(self._arenaData) do
			if self._seasonNO == v.seasonNO then
				self._seasonInfo = v
				return 
			end
		end

		if #self._arenaData == 0 then
			self._seasonInfo.beginDateStr = q.timeToYearMonthDay(self._curBeginTime)
			self._seasonInfo.endDateStr = q.timeToYearMonthDay(self._curBeginTime + 7*DAY - 1)
			self._seasonInfo.seasonNO = self._curSeason
			self._seasonInfo.gloryFighters = {}
			return
		else
			self._seasonNO = self._arenaData[1].seasonNO
			for k , v in pairs(self._arenaData) do
				if self._seasonNO == v.seasonNO then
					self._seasonInfo = v
					return 
				end
			end
		end
	end
end

function QUIDialogGloryTowerHistoryGlory:viewDidAppear()
	QUIDialogGloryTowerHistoryGlory.super.viewDidAppear(self)

    self:setInfo()

  	self:addBackEvent(false)
end

function QUIDialogGloryTowerHistoryGlory:viewWillDisappear()
	QUIDialogGloryTowerHistoryGlory.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogGloryTowerHistoryGlory:setInfo(refresh)
	self:fillInfo()
	self:setBtnState()
	self._ccbOwner.node_btn_choose:setVisible(true)
	self._ccbOwner.tf_season_time:setVisible(true)



	self:setSeasonInfo()
end 




function QUIDialogGloryTowerHistoryGlory:setSeasonInfo()
	self._ccbOwner.tf_season_time:setString(string.format("%s~%s 第%s赛季", self._seasonInfo.beginDateStr, self._seasonInfo.endDateStr, self._seasonInfo.seasonNO))

	for i = 1, 3 do
		if self._fighter[i] ~= nil then
			self._fighter[i]:removeFromParent()
			self._fighter[i] = nil
		end


		if self._fighter[i] == nil then
			self._fighter[i] = QUIWidgetGloryTowerHistoryGlory.new()
			self._ccbOwner["node_fighter_"..i]:addChild(self._fighter[i])
		end
		
        local effect = QUIWidgetAnimationPlayer.new()
        self._fighter[i]:addChild(effect)
        -- effect:retain()
        effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
            effect:removeFromParent()
            -- effect:release()
            effect = nil
        end)
		self._fighter[i]:setFighterInfo(self._seasonInfo.gloryFighters[i], i, self._historyType)
	end
end


function QUIDialogGloryTowerHistoryGlory:setBtnState()
	self._ccbOwner.btn_tiers:setHighlighted(false)
	self._ccbOwner.btn_tiers:setEnabled(true)
	self._ccbOwner.btn_arena:setHighlighted(false)
	self._ccbOwner.btn_arena:setEnabled(true)

	if self._historyType == QUIDialogGloryTowerHistoryGlory.Tiers then
		self._ccbOwner.btn_tiers:setHighlighted(true)
		self._ccbOwner.btn_tiers:setEnabled(false)
	elseif self._historyType == QUIDialogGloryTowerHistoryGlory.GloryArena then
		self._ccbOwner.btn_arena:setHighlighted(true)
		self._ccbOwner.btn_arena:setEnabled(false)
	end
end 

function QUIDialogGloryTowerHistoryGlory:_onTriggerTiers()
	if self._historyType == QUIDialogGloryTowerHistoryGlory.Tiers then return end
    app.sound:playSound("common_menu")

	self._historyType = QUIDialogGloryTowerHistoryGlory.Tiers
	self:setInfo()
end

function QUIDialogGloryTowerHistoryGlory:_onTriggerArena()
	if self._historyType == QUIDialogGloryTowerHistoryGlory.GloryArena then return end
    app.sound:playSound("common_menu")
	
	self._historyType = QUIDialogGloryTowerHistoryGlory.GloryArena

	self:setInfo()
end

function QUIDialogGloryTowerHistoryGlory:_onTriggerChooseSeason(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_choose) == false then return end
	app.sound:playSound("common_small")
	local data = self._historyType == 1 and self._tiersData or self._arenaData
		
	if #data == 0 then
		app.tip:floatTip("虚位以待，敬请期待~")
		return
	end

	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryTowerChooseSeason", options = {data = self._historyType == 1 and self._tiersData or self._arenaData, seasonNO = self._seasonNO}}, {isPopCurrentDialog = false})
	dialog:addEventListener(QUIDialogGloryTowerChooseSeason.EVENT_CILCK_CONFIRM, handler(self, self._clickChooseConfirm))
end

function QUIDialogGloryTowerHistoryGlory:_clickChooseConfirm(event)
	if event.seasonInfo == nil then return end
	if self._seasonNO == event.seasonInfo.seasonNO then return end

	self._seasonNO = event.seasonInfo.seasonNO
	self:setInfo()
end

function QUIDialogGloryTowerHistoryGlory:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogGloryTowerHistoryGlory