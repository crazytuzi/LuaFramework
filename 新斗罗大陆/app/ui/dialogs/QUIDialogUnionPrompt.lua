--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionPrompt = class("QUIDialogUnionPrompt", QUIDialog)

local QUnionAvatar = import("...utils.QUnionAvatar")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogUnionPrompt:ctor(options)
 	local ccbFile = "ccb/Dialog_society_prompt.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogUnionPrompt._onTriggerClose)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogUnionPrompt._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogUnionPrompt._onTriggerCancel)},

    }
    QUIDialogUnionPrompt.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._ccbOwner.id:setString(options.info.id or "")
    local notice = ""

    if options.isShenqing then
        self._ccbOwner.node_info:setVisible(false)
        self._ccbOwner.node_shenqing:setVisible(true)
    else
        self._ccbOwner.node_info:setVisible(true)
        self._ccbOwner.node_shenqing:setVisible(false)
    end

    self._sid = options.sid
    
    if not options.info.notice or options.info.notice == "" then
        notice = string.format("尊敬的魂师大人，%s欢迎您的加入！~",options.info.name or "")
    else
        notice = options.info.notice
    end
    self._ccbOwner.annoucement:setString(notice)
    self._ccbOwner.memberCount:setString(options.info.memberCount or "")
    self._ccbOwner.leader:setString(options.info.presidentName or "")
    local rank
    if options.info.rank then
        rank = options.info.rank + 1
    end
    self._ccbOwner.rank:setString(rank or "")

    self._ccbOwner.node_item:addChild(QUnionAvatar.new(options.info.icon))
end

function QUIDialogUnionPrompt:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogUnionPrompt:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if e ~= nil then
        app.sound:playSound("common_small")
    end
    self:playEffectOut()
end

function QUIDialogUnionPrompt:_onTriggerConfirm(event) 
    if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end
    app.sound:playSound("common_small")
    remote.union:unionApplyRequest(self._sid, function (data)
        self:_onTriggerClose()
        if data.consortia.apply then
            app.tip:floatTip("申请成功！") 
        else
            app.tip:floatTip("加入成功！") 
            remote.union:unionOpenRequest()
        end
    end)
end

function QUIDialogUnionPrompt:_onTriggerCancel(event)
    if q.buttonEventShadow(event, self._ccbOwner.bt_cancel) == false then return end
    app.sound:playSound("common_small")
    self:_onTriggerClose()
end

function QUIDialogUnionPrompt:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogUnionPrompt