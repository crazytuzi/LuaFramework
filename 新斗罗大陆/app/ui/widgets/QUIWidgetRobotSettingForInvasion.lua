--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
-- 一键扫荡要塞相关设置
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotSettingForInvasion = class("QUIWidgetRobotSettingForInvasion", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetRobotSettingForInvasion:ctor(options)
    local ccbFile = "ccb/Widget_RobotSettingForInvasion.ccbi"
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
    }
    QUIWidgetRobotSettingForInvasion.super.ctor(self,ccbFile,callBacks,options)

    -- self._isSaved = true
    self._bossType = { 1, 2, 3, 4}
    self._doubleFires = {}

    for _, bossType in pairs(self._bossType) do
        self._doubleFires[bossType] = remote.robot:getTmpDoubleFire( bossType )
    end

    self:_init()
end

function QUIWidgetRobotSettingForInvasion:_init()
    for _, bossType in pairs(self._bossType) do
        if self._doubleFires[bossType] then
            self._ccbOwner["sp_select_"..bossType.."1"]:setVisible(false)
            self._ccbOwner["sp_select_"..bossType.."2"]:setVisible(true)
        else
            self._ccbOwner["sp_select_"..bossType.."1"]:setVisible(true)
            self._ccbOwner["sp_select_"..bossType.."2"]:setVisible(false)
        end
    end
    
    self._isShare = remote.robot:getTmpIsShare()
    if self._isShare then
        self._ccbOwner.sp_select_share:setVisible(true)
    else
        self._ccbOwner.sp_select_share:setVisible(false)
    end

    self._autoIntrusionToken = remote.robot:getTmpAutoIntrusionToken()
    if self._autoIntrusionToken then
        self._ccbOwner.sp_select_use:setVisible(true)
    else
        self._ccbOwner.sp_select_use:setVisible(false)
    end
end

function QUIWidgetRobotSettingForInvasion:_onTriggerSelect(event, target)
    -- self._isSaved = false
    
    for _, bossType in pairs(self._bossType) do
        if target == self._ccbOwner["btn_"..bossType.."1"] then
            self:_checkBossSettingBtn( false, bossType )
        elseif target == self._ccbOwner["btn_"..bossType.."2"] then
            self:_checkBossSettingBtn( true, bossType )
        end
    end

    if target == self._ccbOwner.btn_share then
        self._isShare = not self._isShare
        if self._isShare then
            self._ccbOwner.sp_select_share:setVisible(true)
        else
            self._ccbOwner.sp_select_share:setVisible(false)
        end
    end

    if target == self._ccbOwner.btn_use then
        self._autoIntrusionToken = not self._autoIntrusionToken
        if self._autoIntrusionToken then
            self._ccbOwner.sp_select_use:setVisible(true)
        else
            self._ccbOwner.sp_select_use:setVisible(false)
        end
    end

    self:saveSetting()
end

function QUIWidgetRobotSettingForInvasion:_checkBossSettingBtn( isDoubleFire, bossType )
    self._doubleFires[bossType] = isDoubleFire
    self._ccbOwner["sp_select_"..bossType.."1"]:setVisible( not self._doubleFires[bossType] )
    self._ccbOwner["sp_select_"..bossType.."2"]:setVisible( self._doubleFires[bossType] )
end

function QUIWidgetRobotSettingForInvasion:saveSetting( callback )
    -- if not self._isSaved then
        for _, bossType in pairs(self._bossType) do
            remote.robot:setTmpDoubleFire( self._doubleFires[bossType], bossType)
        end
        remote.robot:setTmpIsShare( self._isShare )
        remote.robot:setTmpAutoIntrusionToken( self._autoIntrusionToken )
        -- remote.robot:needInvasionSave()
    -- else
    --     app.tip:floatTip("魂师大人，请选择或修改您的设置再点击保存~")
    --     return
    -- end

    if callback ~= nil then
        callback()
    end
end

function QUIWidgetRobotSettingForInvasion:getContentSize()
    return self._ccbOwner.ly_bg:getContentSize()
end

return QUIWidgetRobotSettingForInvasion