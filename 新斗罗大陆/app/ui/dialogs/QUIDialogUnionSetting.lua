--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionSetting = class("QUIDialogUnionSetting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")

function QUIDialogUnionSetting:ctor(options)
 	local ccbFile = "ccb/Dialog_society_union_Setting.ccbi"
    local callBacks = {
    
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogUnionSetting._onTriggerCancel)},

        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogUnionSetting._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerAuthLeft", callback = handler(self, QUIDialogUnionSetting._onTriggerAuthLeft)},
        {ccbCallbackName = "onTriggerAuthRight", callback = handler(self, QUIDialogUnionSetting._onTriggerAuthRight)},
        {ccbCallbackName = "onTriggerMinLeft", callback = handler(self, QUIDialogUnionSetting._onTriggerMinLeft)},
        {ccbCallbackName = "onTriggerMinRight", callback = handler(self, QUIDialogUnionSetting._onTriggerMinRight)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogUnionSetting._onTriggerClose)},
    }
    QUIDialogUnionSetting.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._unionIcon = remote.union.consortia.icon
    self._authorize = remote.union.consortia.authorize or 0
    self._applyPowerLimit = (remote.union.consortia.applyPowerLimit or 0 )/10000


    self._ccbOwner.frame_tf_title:setString("限制设置")
    self._minLimitLevel = app.unlock:getConfigByKey("UNLOCK_UNION").team_level

    self._editBoxForceLimit = ui.newEditBox({ image = "ui/none.png", listener = function(eventname,sender)
            self:editboxHandle(eventname,sender) 
        end, size = CCSize(278, 40), })

    self._editBoxForceLimit:setAnchorPoint(ccp(0, 0.5))
    self._editBoxForceLimit:setPlaceHolder("输入最低战力(单位万)")
    self._editBoxForceLimit:setFont(global.font_default, 20)
    self._editBoxForceLimit:setFontColor(COLORS.k)
    self._editBoxForceLimit:setMaxLength(8)
    self._ccbOwner.input:addChild(self._editBoxForceLimit)

    self:setInfo()
end
function QUIDialogUnionSetting:editboxHandle(strEventName,sender)
    self._num = 0
    local text = self._editBoxForceLimit:getText()
    local numText = string.gsub(text, "万", "")
    local numStr = tonumber(numText)

    if numStr then
        if numText == text and self._num ~= 0 then
            self._num = math.floor(self._num / 10)
        else
            self._num = numStr
        end
    else
        
    end

    self:changeEditBox()
end

function QUIDialogUnionSetting:changeEditBox()
    if self._num > 0 then
        self._editBoxForceLimit:setText(self._num.."万")
    else
        self._editBoxForceLimit:setText(0)
    end      --输入内容改变时调用 
end

function QUIDialogUnionSetting:setInfo()
    local unionAvatar = QUnionAvatar.new(remote.union.consortia.icon, false, false)
    unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)
    self._ccbOwner.node_item:removeAllChildren()
    self._ccbOwner.node_item:addChild(unionAvatar)

    self._ccbOwner.name:setString(remote.union.consortia.name)
    self:setLimitLabel()
    self._ccbOwner.level:setString(remote.union.consortia.applyTeamLevel or "")

    if self._editBoxForceLimit and self._applyPowerLimit > 0 then
        self._editBoxForceLimit:setText(self._applyPowerLimit.."万")
    end
end

-- function QUIDialogUnionSetting:_onTriggerIcon()
--     app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionHead", 
--         options = {type = 1, newAvatarSelected = function (icon)
--             local avatarId, frameId = QUnionAvatar:getAvatarFrameId(self._unionIcon)
--             local newAvatar = QUnionAvatar:getAvatar(icon, frameId)
--             self._ccbOwner.node_item:removeAllChildren()
--             self._ccbOwner.node_item:addChild(QUnionAvatar.new(newAvatar, false, false))
--             self._unionIcon = newAvatar
--         end}}, {isPopCurrentDialog = false})
-- end

-- function QUIDialogUnionSetting:_onTriggerFrame()
--     app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionHead", 
--         options = {type = 2, newAvatarSelected = function (icon)
--             local avatarId, frameId = QUnionAvatar:getAvatarFrameId(self._unionIcon)
--             local newAvatar = QUnionAvatar:getAvatar(avatarId, icon)
--             self._ccbOwner.node_item:removeAllChildren()
--             self._ccbOwner.node_item:addChild(QUnionAvatar.new(newAvatar, false, false))
--             self._unionIcon = newAvatar
--         end}}, {isPopCurrentDialog = false})
-- end

-- function QUIDialogUnionSetting:_onTriggerName()
--     app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
--         options = {type = QUIDialogUnionAnnouncement.TYPE_UNION_NAME, confirmCallback = function (newName)
--             self._ccbOwner.name:setString(newName)
--             self._name = newName
--         end}}, {isPopCurrentDialog = false})
-- end
function QUIDialogUnionSetting:setLimitLabel(  )
    -- body
    if self._authorize == 1 then
        self._ccbOwner.authorize:setString("需申请")    
    elseif self._authorize == 2 then
        self._ccbOwner.authorize:setString("自由加入")  
    else
        self._ccbOwner.authorize:setString("禁止加入")  
    end
end

function QUIDialogUnionSetting:_onTriggerAuthLeft()
    app.sound:playSound("common_switch")
    if self._authorize <= 1 then
        self._authorize = self._authorize + 3
    end
    self._authorize = self._authorize -1
    self:setLimitLabel()
end

function QUIDialogUnionSetting:_onTriggerAuthRight()
    app.sound:playSound("common_switch")
    if self._authorize >= 3 then
        self._authorize = self._authorize - 3
    end
    self._authorize = self._authorize + 1
    self:setLimitLabel()
end

function QUIDialogUnionSetting:_onTriggerMinLeft()
    app.sound:playSound("common_switch")
    self._minLevel = (self._minLevel or remote.union.consortia.applyTeamLevel)
    if self._minLevel <= self._minLimitLevel then
        self._minLevel = 99
    else
        self._minLevel = self._minLevel - 1
    end

    self._ccbOwner.level:setString(self._minLevel)
end

function QUIDialogUnionSetting:_onTriggerMinRight()
    app.sound:playSound("common_switch")
    self._minLevel = (self._minLevel or remote.union.consortia.applyTeamLevel)
    if self._minLevel >= 99 then
        self._minLevel = self._minLimitLevel
    else
        self._minLevel = self._minLevel + 1
    end
    self._ccbOwner.level:setString(self._minLevel)
end

function QUIDialogUnionSetting:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
    local teamForceLimit = 0
    if self._editBoxForceLimit then
        local teamForceStr= self._editBoxForceLimit:getText()
        teamForceStr = string.gsub(teamForceStr, "万", "")
        teamForceLimit = tonumber( teamForceStr ) or 0
    end    
    teamForceLimit = teamForceLimit * 10000

    if teamForceLimit > remote.union.FORCE_LIMIT then
        app.tip:floatTip("战力限制太高了～")
        return 
    end

    app.sound:playSound("common_confirm")
    remote.union:unionUpdateSettingRequest(self._minLevel or remote.union.consortia.applyTeamLevel, 
                                            self._authorize == nil and remote.union.consortia.authorize or self._authorize, 
                                            self._name or remote.union.consortia.name,
                                            self._unionIcon or remote.union.consortia.icon,
                                            teamForceLimit,
                                            function ()
                                                if self:getOptions().confirmCallback then
                                                    self:getOptions().confirmCallback()
                                                end

                                                self:_onTriggerClose()
                                            end)
end

function QUIDialogUnionSetting:_onTriggerCancel(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
    self:_onTriggerClose()
end

function QUIDialogUnionSetting:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogUnionSetting:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogUnionSetting:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogUnionSetting 