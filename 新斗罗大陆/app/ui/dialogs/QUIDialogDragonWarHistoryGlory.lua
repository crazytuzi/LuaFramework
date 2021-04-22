-- 
-- zxs
-- 荣誉墙
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonWarHistoryGlory = class("QUIDialogDragonWarHistoryGlory", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetDragonWarHistoryGlory = import("..widgets.dragon.QUIWidgetDragonWarHistoryGlory")
local QUIDialogGloryTowerChooseSeason = import("..dialogs.QUIDialogGloryTowerChooseSeason")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogDragonWarHistoryGlory:ctor(options)
	local ccbFile = "ccb/Dialog_GloryTower_ryq.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChooseSeason", callback = handler(self, self._onTriggerChooseSeason)},
	}
	QUIDialogDragonWarHistoryGlory.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
    
    CalculateUIBgSize(self._ccbOwner.sp_GloryArena_bg)
  
    self._ccbOwner.node_bg:setPositionY(0)
    self._data = options.data or {}
    self._fighter = {}

    self._seasonInfo = {}
    local maxSeason = 1
    for k, v in pairs(self._data) do
		if maxSeason <= v.seasonNO then
			maxSeason = v.seasonNO
			self._seasonInfo = v
		end
	end
    self._seasonNO = self._seasonInfo.seasonNO

	self._ccbOwner.node_dragonwar:setVisible(true)
	self._ccbOwner.btn_tiers:setVisible(false)
	self._ccbOwner.btn_arena:setVisible(false)
end

function QUIDialogDragonWarHistoryGlory:viewDidAppear()
	QUIDialogDragonWarHistoryGlory.super.viewDidAppear(self)
  	self:addBackEvent(false)

    self:setInfo()
end

function QUIDialogDragonWarHistoryGlory:viewWillDisappear()
	QUIDialogDragonWarHistoryGlory.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogDragonWarHistoryGlory:setInfo(refresh)
	self._ccbOwner.node_btn_choose:setVisible(true)
	self._ccbOwner.tf_season_time:setVisible(true)

	self:setSeasonInfo()
end 

function QUIDialogDragonWarHistoryGlory:setSeasonInfo()
	for k, v in pairs(self._data) do
		if self._seasonNO == v.seasonNO then
			self._seasonInfo = v
			break
		end
	end

	local startAt = self._seasonInfo.seasonStartAt/1000
	local endAt = self._seasonInfo.seasonEndAt/1000
	self._ccbOwner.tf_season_time:setString(string.format("%s~%s 第%s赛季", q.timeToYearMonthDay(startAt), q.timeToYearMonthDay(endAt), self._seasonInfo.seasonNO or 1))

    local consortiaInfo = self._seasonInfo.consortiaInfo
	for i = 1, 3 do
		if self._fighter[i] ~= nil then
			self._fighter[i]:removeFromParent()
			self._fighter[i] = nil
		end

		if self._fighter[i] == nil then
			self._fighter[i] = QUIWidgetDragonWarHistoryGlory.new()
			self._ccbOwner["node_fighter_"..i]:addChild(self._fighter[i])
		end
		
        local effect = QUIWidgetAnimationPlayer.new()
        self._fighter[i]:addChild(effect)
        effect:setPositionY(-70)
        effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
            effect:removeFromParent()
            effect = nil
        end)

		self._fighter[i]:setFighterInfo(consortiaInfo[i], i)
	end
end

function QUIDialogDragonWarHistoryGlory:_onTriggerChooseSeason(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_choose) == false then return end
	app.sound:playSound("common_small")
	local data = self._data
	if #data == 0 then
		app.tip:floatTip("虚位以待，敬请期待~")
		return
	end

	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGloryTowerChooseSeason", 
		options = {data = self._data, seasonNO = self._seasonNO}}, {isPopCurrentDialog = false})
	dialog:addEventListener(QUIDialogGloryTowerChooseSeason.EVENT_CILCK_CONFIRM, handler(self, self._clickChooseConfirm))
end

function QUIDialogDragonWarHistoryGlory:_clickChooseConfirm(event)
	if event.seasonInfo == nil then return end
	if self._seasonNO == event.seasonInfo.seasonNO then return end

	self._seasonNO = event.seasonInfo.seasonNO
	self:setInfo()
end

function QUIDialogDragonWarHistoryGlory:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogDragonWarHistoryGlory