--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogReplayShare = class("QUIDialogReplayShare", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local NO_UNION_ERROR = "您未加入宗门"
local NO_CHANNEL_ERROR = "该频道尚未建立"

function QUIDialogReplayShare:ctor(options)
 	local ccbFile = "ccb/Dialog_society_share.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerGlobal", callback = handler(self, QUIDialogReplayShare._onTriggerGlobal)},
        {ccbCallbackName = "onTriggerUnion", callback = handler(self, QUIDialogReplayShare._onTriggerUnion)},
    }
    QUIDialogReplayShare.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
    self._reportType = options.reportType or ""

    self:_initBGAndBtn()
end

-- 关闭对话框
function QUIDialogReplayShare:_initBGAndBtn()

    -- if self._reportType == REPORT_TYPE.SILVES_ARENA then
    --     self._ccbOwner.node_btn_shareToWold:setVisible(true)
    --     self._ccbOwner.node_btn_shareToUnion:setVisible(true)

    --     self._ccbOwner.node_btn_shareToWold:setPosition(0, 0)
    --     self._ccbOwner.node_btn_shareToUnion:setPosition(0,80)
    --     self._ccbOwner.node_btn_shareToWold:setContentSize(CCSize(307,280))
    -- else
        self._ccbOwner.node_btn_shareToWold:setVisible(true)
        self._ccbOwner.node_btn_shareToUnion:setVisible(true)

        self._ccbOwner.node_btn_shareToWold:setPosition(0, 40)
        self._ccbOwner.node_btn_shareToUnion:setPosition(0,-40)
        self._ccbOwner.node_btn_shareToWold:setContentSize(CCSize(307,210))
    -- end
end

function QUIDialogReplayShare:_onTriggerUnion(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_shareToUnion) == false then return end
    app.sound:playSound("common_small")
    if remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
        if app:getServerChatData():canSendMessage(2) then
            print(" self:getOptions().isFight, matchingId = self:getOptions().matchingId ",self:getOptions().isFight,self:getOptions().matchingId)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayComment", 
                options = {roomId = 2, fighter1 = self:getOptions().myNickName, fighter2 = self:getOptions().rivalName, 
                replayId = self:getOptions().replayId, replayType = self:getOptions().replayType}})
        else
            app.tip:floatTip(NO_CHANNEL_ERROR)
        end
    else
        app.tip:floatTip(NO_UNION_ERROR)
    end
end

function QUIDialogReplayShare:_onTriggerGlobal(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_shareToWold) == false then return end
    app.sound:playSound("common_small")
    if app:getServerChatData():canSendMessage(1) then 
        print(" self:getOptions().isFight, matchingId = self:getOptions().matchingId ",self:getOptions().isFight,self:getOptions().matchingId)
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayComment", 
            options = {roomId = 1, fighter1 = self:getOptions().myNickName, fighter2 = self:getOptions().rivalName, 
            replayId = self:getOptions().replayId, replayType = self:getOptions().replayType}})
    else
        app.tip:floatTip(NO_CHANNEL_ERROR)
    end
end

function QUIDialogReplayShare:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogReplayShare:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogReplayShare:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogReplayShare