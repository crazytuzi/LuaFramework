
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobotInvasionSetting = class("QUIDialogRobotInvasionSetting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogRobotInvasionSetting:ctor(options)
    local ccbFile = "ccb/Dialog_Panjun_zidongjisha.ccbi";
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerSave", callback = handler(self, self._onTriggerSave)},
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
    }
    QUIDialogRobotInvasionSetting.super.ctor(self,ccbFile,callBacks,options)

    self._isSaved = true
    self._ccbOwner.tf_btn_save:setString("关  闭")
    self._bossType = { 1, 2, 3}
    self._doubleFires = {}

    for _, bossType in pairs(self._bossType) do
        self._doubleFires[bossType] = remote.robot:getDoubleFire( bossType )
    end

    self:_init()
end

function QUIDialogRobotInvasionSetting:_init()
    for _, bossType in pairs(self._bossType) do
        if self._doubleFires[bossType] then
            self._ccbOwner["sp_select_"..bossType.."1"]:setVisible(false)
            self._ccbOwner["sp_no_select_"..bossType.."1"]:setVisible(true)
            self._ccbOwner["sp_select_"..bossType.."2"]:setVisible(true)
            self._ccbOwner["sp_no_select_"..bossType.."2"]:setVisible(false)
        else
            self._ccbOwner["sp_select_"..bossType.."1"]:setVisible(true)
            self._ccbOwner["sp_no_select_"..bossType.."1"]:setVisible(false)
            self._ccbOwner["sp_select_"..bossType.."2"]:setVisible(false)
            self._ccbOwner["sp_no_select_"..bossType.."2"]:setVisible(true)
        end
    end
    
    self._isShare = remote.robot:getIsShare()
    if self._isShare then
        self._ccbOwner.sp_select_share:setVisible(true)
        self._ccbOwner.sp_no_select_share:setVisible(false)
    else
        self._ccbOwner.sp_select_share:setVisible(false)
        self._ccbOwner.sp_no_select_share:setVisible(true)
    end

    self._autoIntrusionToken = remote.robot:getAutoIntrusionToken()
    if self._autoIntrusionToken then
        self._ccbOwner.sp_select_use:setVisible(true)
        self._ccbOwner.sp_no_select_use:setVisible(false)
    else
        self._ccbOwner.sp_select_use:setVisible(false)
        self._ccbOwner.sp_no_select_use:setVisible(true)
    end
end

function QUIDialogRobotInvasionSetting:viewDidAppear()
    QUIDialogRobotInvasionSetting.super.viewDidAppear(self)
end

function QUIDialogRobotInvasionSetting:viewWillDisappear()
    QUIDialogRobotInvasionSetting.super.viewWillDisappear(self)
end

function QUIDialogRobotInvasionSetting:_onTriggerSelect(event, target)
    self._isSaved = false
    self._ccbOwner.tf_btn_save:setString("保存方案")
    
    for _, bossType in pairs(self._bossType) do
        if target == self._ccbOwner["btn_"..bossType.."1"] then
            self:_checkBossSettingBtn( false, bossType )
            return
        elseif target == self._ccbOwner["btn_"..bossType.."2"] then
            self:_checkBossSettingBtn( true, bossType )
            return
        end
    end

    if target == self._ccbOwner.btn_share then
        self._isShare = not self._isShare
        if self._isShare then
            self._ccbOwner.sp_select_share:setVisible(true)
            self._ccbOwner.sp_no_select_share:setVisible(false)
        else
            self._ccbOwner.sp_select_share:setVisible(false)
            self._ccbOwner.sp_no_select_share:setVisible(true)
        end
    end

    if target == self._ccbOwner.btn_use then
        self._autoIntrusionToken = not self._autoIntrusionToken
        if self._autoIntrusionToken then
            self._ccbOwner.sp_select_use:setVisible(true)
            self._ccbOwner.sp_no_select_use:setVisible(false)
        else
            self._ccbOwner.sp_select_use:setVisible(false)
            self._ccbOwner.sp_no_select_use:setVisible(true)
        end
    end

end

function QUIDialogRobotInvasionSetting:_checkBossSettingBtn( isDoubleFire, bossType )
    self._doubleFires[bossType] = isDoubleFire
    self._ccbOwner["sp_select_"..bossType.."1"]:setVisible( not self._doubleFires[bossType] )
    self._ccbOwner["sp_no_select_"..bossType.."1"]:setVisible( self._doubleFires[bossType] )
    self._ccbOwner["sp_select_"..bossType.."2"]:setVisible( self._doubleFires[bossType] )
    self._ccbOwner["sp_no_select_"..bossType.."2"]:setVisible( not self._doubleFires[bossType] )
end

function QUIDialogRobotInvasionSetting:_onTriggerClose()
    self:close()
end

function QUIDialogRobotInvasionSetting:_onTriggerSave()
    if not self._isSaved then
        for _, bossType in pairs(self._bossType) do
            remote.robot:setDoubleFire( self._doubleFires[bossType], bossType)
        end
        remote.robot:setIsShare( self._isShare )
        remote.robot:setAutoIntrusionToken( self._autoIntrusionToken )
        remote.robot:needInvasionSave()
        app.tip:floatTip("成功保存方案")
        self._isSaved = true
        self._ccbOwner.tf_btn_save:setString("关  闭")
    else
        self:close()
    end
end

function QUIDialogRobotInvasionSetting:close()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogRobotInvasionSetting:viewAnimationOutHandler()
    self:popSelf()
end

return QUIDialogRobotInvasionSetting