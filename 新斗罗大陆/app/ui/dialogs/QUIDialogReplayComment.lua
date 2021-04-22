--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogReplayComment = class("QUIDialogReplayComment", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QMaskWords = import("...utils.QMaskWords")
local QVIPUtil = import("...utils.QVIPUtil")
local QErrorInfo = import("...utils.QErrorInfo")

local SHARE_SUCCESS = "分享成功"

function QUIDialogReplayComment:ctor(options)
 	local ccbFile = "ccb/Dialog_BattleShare.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogReplayComment.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._ccbOwner.fighter1:setString(string.format("%s", options.fighter1))
    self._ccbOwner.fighter2:setString(string.format("%s", options.fighter2))

    self._comment = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(440, 50)})
    self._comment:setFont(global.font_default, 26)
    self._comment:setMaxLength(20)

    self._comment:setVisible(true)
    self._ccbOwner.comment:addChild(self._comment)
end

function QUIDialogReplayComment:onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function QUIDialogReplayComment:_onTriggerConfirm(event)
    if q.buttonEventShadow(event,self._ccbOwner.button_ok) == false then return end
    app.sound:playSound("common_small")

    -- if not self._comment:getText() or self._comment:getText() =="" then
    --     app.tip:floatTip("分享内容不能为空")
    --     return
    -- end

    if self:getOptions().replayId then
        local msg = ""
        if self:getOptions().replayType == REPORT_TYPE.ARENA then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.ARENA, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.GLORY_TOWER then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.GLORY_TOWER, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.SILVERMINE then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.SILVERMINE, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.PLUNDER then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.PLUNDER, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.GLORY_ARENA then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.GLORY_ARENA, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.STORM_ARENA then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.STORM_ARENA, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.FIGHT_CLUB then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.FIGHT_CLUB, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.MARITIME then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.MARITIME, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.DRAGON_WAR then
            msg = string.format("##g【%s VS %s（宗门）】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.DRAGON_WAR, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.SANCTUARY_WAR then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.SANCTUARY_WAR, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.CONSORTIA_WAR then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.CONSORTIA_WAR, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.SOTO_TEAM then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.SOTO_TEAM, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.MOCK_BATTLE then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.MOCK_BATTLE, self._comment:getText())
        elseif self:getOptions().replayType == REPORT_TYPE.SILVES_ARENA then
            msg = string.format("##g【%s VS %s】（%s）\n ##g%s", self:getOptions().fighter1, self:getOptions().fighter2, BATTLE_NAME.SILVES_ARENA, self._comment:getText())
        else
            assert(false, "unknown report type: "..tostring(self:getOptions().replayType))
        end
        app:getServerChatData():sendMessage(msg, self:getOptions().roomId, nil, nil, nil, {replay=self:getOptions().replayId, replayType = self:getOptions().replayType}, function(errorcode)
            if errorcode == 0 then
                app.tip:floatTip(SHARE_SUCCESS)
            else
                QErrorInfo:handle(errorcode)
            end
        end)

        app:getServerChatData():setEarliestReplaySentTime(q.serverTime())
        self:_onTriggerClose()
    end
end

function QUIDialogReplayComment:_onTriggerCancel(event)
    if q.buttonEventShadow(event,self._ccbOwner.bt_closeTips) == false then return end
    app.sound:playSound("common_small")
    self:_onTriggerClose()
end

function QUIDialogReplayComment:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogReplayComment:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogReplayComment:viewAnimationOutHandler()
    -- We need also to pop up replay share dialog when we close tihs dialog
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogReplayComment