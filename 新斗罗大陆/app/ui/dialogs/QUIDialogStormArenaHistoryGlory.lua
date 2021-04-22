
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStormArenaHistoryGlory = class("QUIDialogStormArenaHistoryGlory", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetStormArenaHistoryGlory = import("..widgets.QUIWidgetStormArenaHistoryGlory")
local QUIDialogStormArenaChooseSeason = import("..dialogs.QUIDialogStormArenaChooseSeason")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIDialogStormArenaHistoryGlory.Tiers = 1
QUIDialogStormArenaHistoryGlory.Location = 2

function QUIDialogStormArenaHistoryGlory:ctor(options)
	local ccbFile = "ccb/Dialog_GloryTower_ryq.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTiers", callback = handler(self, self._onTriggerTiers)},
		{ccbCallbackName = "onTriggerArena", callback = handler(self, self._onTriggerArena)},
		{ccbCallbackName = "onTriggerChooseSeason", callback = handler(self, self._onTriggerChooseSeason)},
	}
	QUIDialogStormArenaHistoryGlory.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
    
    CalculateUIBgSize(self._ccbOwner.sp_GloryArena_bg)
	
    if not options then
    	options = {}
    end

    self._data = options.data or {}
    remote.stormArena.seasonNO = self._data.seasonNO
    self._isAllServersHistory = remote.stormArena.isAllServersHistory

    if math.abs(display.height - UI_DESIGN_HEIGHT) < 55 then
		self._ccbOwner.node_bg:setPositionY(self._ccbOwner.node_bg:getPositionY()-55)
	end

    self._fighterWidgets = {}

    if self._data and self._data.gloryFighterInfo and #self._data.gloryFighterInfo > 0 then
	    table.sort(self._data.gloryFighterInfo, function(a, b)
	    		return a.rank < b.rank
	    	end)
	end

	self._ccbOwner.btn_tiers:setVisible(false)
	self._ccbOwner.btn_arena:setVisible(false)
end

function QUIDialogStormArenaHistoryGlory:viewDidAppear()
	QUIDialogStormArenaHistoryGlory.super.viewDidAppear(self)

    self:setInfo()

  	self:addBackEvent(false)
end

function QUIDialogStormArenaHistoryGlory:viewWillDisappear()
	QUIDialogStormArenaHistoryGlory.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogStormArenaHistoryGlory:setInfo()
	-- self:setBtnState()
	self._ccbOwner.node_btn_choose:setVisible(true)
	self._ccbOwner.tf_season_time:setVisible(true)

	self:setSeasonInfo()
end 

function QUIDialogStormArenaHistoryGlory:setSeasonInfo()
	if self._data.seasonNO and tonumber(self._data.seasonNO) ~= 0 then
		local seasonTbl = remote.stormArena:getSeasonInfoBySeasonNO(self._data.seasonNO) or {}
		local startTimeAt = 0
		local endTimeAt = 0
		if not seasonTbl or #seasonTbl == 0 then
			startTimeAt = self._data.seasonStartAt / 1000
			endTimeAt = remote.stormArena:getSeasonEndTimeAt( self._data.seasonStartAt )
		else
			startTimeAt = seasonTbl.seasonStartAt / 1000
			endTimeAt = seasonTbl.seasonEndAt / 1000
		end
		local startStr = remote.stormArena:formatDate( startTimeAt )
		local endStr = remote.stormArena:formatDate( endTimeAt )
		self._ccbOwner.tf_season_time:setString(string.format("%s~%s 第%s赛季", startStr, endStr, self._data.seasonNO))
	else
		self._ccbOwner.tf_season_time:setString("")
	end

	for i = 1, 3, 1 do
		if self._fighterWidgets[i] ~= nil then
			self._fighterWidgets[i]:removeFromParent()
			self._fighterWidgets[i] = nil
		end

		if self._fighterWidgets[i] == nil then
			self._fighterWidgets[i] = QUIWidgetStormArenaHistoryGlory.new()
			self._ccbOwner["node_fighter_"..i]:addChild(self._fighterWidgets[i])
		end
		
        local effect = QUIWidgetAnimationPlayer.new()
        self._fighterWidgets[i]:addChild(effect)
        -- effect:retain()
        effect:playAnimation("effects/ChooseHero.ccbi", nil, function ()
            effect:removeFromParent()
            -- effect:release()
            effect = nil
        end)
        if self._data and self._data.gloryFighterInfo and #self._data.gloryFighterInfo > 0 then
			self._fighterWidgets[i]:setFighterInfo(self._data.gloryFighterInfo[i], i)
		else
			self._fighterWidgets[i]:setFighterInfo(nil, i)
		end
	end
end


function QUIDialogStormArenaHistoryGlory:setBtnState()
	self._ccbOwner.btn_tiers:setHighlighted(false)
	self._ccbOwner.btn_tiers:setEnabled(true)
	self._ccbOwner.btn_arena:setHighlighted(false)
	self._ccbOwner.btn_arena:setEnabled(true)

	if self._isAllServersHistory then
		self._ccbOwner.btn_tiers:setHighlighted(true)
		self._ccbOwner.btn_tiers:setEnabled(false)
	else
		self._ccbOwner.btn_arena:setHighlighted(true)
		self._ccbOwner.btn_arena:setEnabled(false)
	end
end 

function QUIDialogStormArenaHistoryGlory:_onTriggerTiers()
	if self._isAllServersHistory == true then return end
    app.sound:playSound("common_menu")
    remote.stormArena.isAllServersHistory = true
   	self._isAllServersHistory = true

	remote.stormArena:stormGetGloryWallInfoRequest(remote.stormArena.seasonNO, remote.stormArena.isAllServersHistory, function(data)
    		-- QPrintTable(data)
    		self._data = data.stormGetGloryWallInfoResponse
    		self:setInfo()
    	end)
end

function QUIDialogStormArenaHistoryGlory:_onTriggerArena()
	if self._isAllServersHistory == false then return end
    app.sound:playSound("common_menu")
	remote.stormArena.isAllServersHistory = false
   	self._isAllServersHistory = false

	remote.stormArena:stormGetGloryWallInfoRequest(remote.stormArena.seasonNO, remote.stormArena.isAllServersHistory, function(data)
    		self._data = data.stormGetGloryWallInfoResponse
    		self:setInfo()
    	end)
	
end

function QUIDialogStormArenaHistoryGlory:_onTriggerChooseSeason(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_choose) == false then return end
	app.sound:playSound("common_small")

	local data = remote.stormArena:getSeasonInfo()
	if #data == 0 then
		app.tip:floatTip("虚位以待，敬请期待~")
		return
	end

	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaChooseSeason"}, {isPopCurrentDialog = false})
	dialog:addEventListener(QUIDialogStormArenaChooseSeason.EVENT_CILCK_CONFIRM, handler(self, self._clickChooseConfirm))
end

function QUIDialogStormArenaHistoryGlory:_clickChooseConfirm(event)
	if event == nil then return end
	if remote.stormArena.seasonNO == event.seasonInfo.seasonNo then return end

	remote.stormArena.seasonNO = event.seasonInfo.seasonNo
	remote.stormArena:stormGetGloryWallInfoRequest(remote.stormArena.seasonNO, remote.stormArena.isAllServersHistory, function(data)
    		-- QPrintTable(data)
    		self._data = data.stormGetGloryWallInfoResponse
    		self:setInfo()
    	end)
end

function QUIDialogStormArenaHistoryGlory:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogStormArenaHistoryGlory