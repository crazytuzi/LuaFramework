
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobot = class("QUIDialogRobot", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogRobot:ctor(options)
    local ccbFile = "ccb/Dialog_yijiansaodang.ccbi";
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
    }
    QUIDialogRobot.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self._list = options.list
    self._isStartRobot = false
    self:_init()
end

function QUIDialogRobot:_init()
    local item = QUIWidgetItemsBox.new()
    item:setGoodsInfo(self._list[1].itemId, ITEM_TYPE.ITEM, 0)
    self._ccbOwner.node_icon:addChild(item)

    local itemConfig = remote.robot:getItemConfigByID( self._list[1].itemId )
    self._ccbOwner.tf_name:setString(itemConfig.name)
    self._ccbOwner.tf_name:setColor(EQUIPMENT_COLOR[itemConfig.colour])
    -- QPrintTable(self._list)
    self._ccbOwner.tf_count:setString(#self._list)

    if remote.robot:getAutoEnergy() then
        self._ccbOwner.sp_select_1:setVisible(true)
        self._ccbOwner.sp_no_select_1:setVisible(false)
    else
        self._ccbOwner.sp_select_1:setVisible(false)
        self._ccbOwner.sp_no_select_1:setVisible(true)
    end

    if remote.robot:getAutoInvasion() then
        self._ccbOwner.sp_select_2:setVisible(true)
        self._ccbOwner.sp_no_select_2:setVisible(false)
    else
        self._ccbOwner.sp_select_2:setVisible(false)
        self._ccbOwner.sp_no_select_2:setVisible(true)
    end
end

function QUIDialogRobot:viewDidAppear()
    QUIDialogRobot.super.viewDidAppear(self)
end

function QUIDialogRobot:viewWillDisappear()
    QUIDialogRobot.super.viewWillDisappear(self)
end

function QUIDialogRobot:_onTriggerSelect(event, target)
    if target == self._ccbOwner.btn_1 then
        remote.robot:setAutoSoulEnergy( not remote.robot:getAutoEnergy() )
        if remote.robot:getAutoEnergy() then
            self._ccbOwner.sp_select_1:setVisible(true)
            self._ccbOwner.sp_no_select_1:setVisible(false)
        else
            self._ccbOwner.sp_select_1:setVisible(false)
            self._ccbOwner.sp_no_select_1:setVisible(true)
        end
    elseif target == self._ccbOwner.btn_2 then
        remote.robot:setAutoInvasion( not remote.robot:getAutoInvasion() )
        if remote.robot:getAutoInvasion() then
            self._ccbOwner.sp_select_2:setVisible(true)
            self._ccbOwner.sp_no_select_2:setVisible(false)
        else
            self._ccbOwner.sp_select_2:setVisible(false)
            self._ccbOwner.sp_no_select_2:setVisible(true)
        end
    end
end

function QUIDialogRobot:_onTriggerClose()
    self._isStartRobot = false
    self:close()
end

function QUIDialogRobot:_onTriggerCancel()
    self._isStartRobot = false
    self:close()
end

function QUIDialogRobot:_onTriggerConfirm(e)
    table.sort(self._list, function(a,b) return a.id < b.id end)
    if not self:_checkEnergy() then
        app.tip:floatTip("魂师大人，您没有体力进行扫荡～")
        return
    end
    self._isStartRobot = true
    self:close()
end

function QUIDialogRobot:close()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogRobot:viewAnimationOutHandler()
    local callType = self._type
    self:popSelf()

    if self._isStartRobot then
        self:startRobot()
    end
end

function QUIDialogRobot:startRobot()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotInformation",
        options = {list = self._list}})
end

function QUIDialogRobot:_checkEnergy()
    local needEnergy = 0
    local dungeonType = self._list[1].dungeonType
    local energyItemIds = { 25, 26, 27 }
    if dungeonType == 1 then
        needEnergy = 6
    elseif dungeonType == 2 then
        needEnergy = 12
    else
        needEnergy = 6
    end

    if remote.user.energy >= needEnergy then
        return true
    else
        if remote.robot:getAutoEnergy() then
            for _, itemId in pairs(energyItemIds) do
                if remote.items:getItemsNumByID( itemId ) > 0 then
                    return true
                end
            end
        end
        return false
    end
end

function QUIDialogRobot:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogRobot