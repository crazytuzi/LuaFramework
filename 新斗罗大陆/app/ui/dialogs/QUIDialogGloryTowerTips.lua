--
-- Author: xurui
-- Date: 2015-07-08 17:16:21
--
local QUIDialog = import(".QUIDialog")
local QUIDialogGloryTowerTips = class("QUIDialogGloryTowerTips", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGloryTowerTips:ctor(options)
  	local ccbFile = "ccb/Dialog_GloryTower_Duanweishengji.ccbi"
  	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
  	QUIDialogGloryTowerTips.super.ctor(self, ccbFile, callBacks, options)
  
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)

    self._callFunc = options.callFunc
    self._lastFloor = options.lastFloor or 1
    self._floor = options.floor or 1
    self._successTip = options.successTip

    self:setGloryIcon()

    self._animationIsDone = false
    self._scheduler = scheduler.performWithDelayGlobal(function()
            self._animationIsDone = true
        end, 3)
    app.sound:playSound("glory_grow_up")

    self._isSelected = false
    self:showSelectState()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
end

function QUIDialogGloryTowerTips:viewDidAppear()
    QUIDialogGloryTowerTips.super.viewDidAppear(self)
end

function QUIDialogGloryTowerTips:viewWillDisappear()
    QUIDialogGloryTowerTips.super.viewWillDisappear(self)
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogGloryTowerTips:setGloryIcon()
    local oldFloor = QUIWidgetFloorIcon.new({floor = self._lastFloor, isLarge = false, iconType = "tower"})
    oldFloor:setScale(1.2)
    self._ccbOwner.tower_lv_old:removeAllChildren()
    self._ccbOwner.tower_lv_old:addChild(oldFloor)

    local newFloor = QUIWidgetFloorIcon.new({floor = self._floor, isLarge = false, iconType = "tower"})
    newFloor:setScale(1.2)
    self._ccbOwner.tower_lv_new:removeAllChildren()
    self._ccbOwner.tower_lv_new:addChild(newFloor)
end

function QUIDialogGloryTowerTips:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGloryTowerTips:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGloryTowerTips:_backClickHandler()
    if self._animationIsDone then
        self:_onTriggerClose()
    end
end

function QUIDialogGloryTowerTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogGloryTowerTips:viewAnimationOutHandler()
    if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end

    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._callFunc then
        self._callFunc()
    end
end


return QUIDialogGloryTowerTips