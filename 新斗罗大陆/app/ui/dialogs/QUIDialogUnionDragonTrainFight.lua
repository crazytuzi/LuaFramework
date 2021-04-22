
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogUnionDragonTrainFight = class("QUIDialogUnionDragonTrainFight", QUIDialog)

local QUnionDragonTaskArrangement = import("...arrangement.QUnionDragonTaskArrangement")

function QUIDialogUnionDragonTrainFight:ctor(options)
    local ccbFile = "ccb/Dialog_Society_Dragon_Task_Fight.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogUnionDragonTrainFight.super.ctor(self,ccbFile,callBacks,options)
    self._ccbOwner.frame_tf_title:setString("")
    
    self._id = options.id

    self:_init()
end

function QUIDialogUnionDragonTrainFight:viewDidAppear()
    QUIDialogUnionDragonTrainFight.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainFight:viewWillDisappear()
    QUIDialogUnionDragonTrainFight.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonTrainFight:_init()
    local taskInfo = remote.dragon:getTaskInfoById( self._id )
    if taskInfo then
        self._ccbOwner.frame_tf_title:setString(taskInfo.name)
        self._ccbOwner.tf_taskExplain:setString(taskInfo.description)
    end
end

function QUIDialogUnionDragonTrainFight:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    if app.sound ~= nil then
        app.sound:playSound("common_small")
    end

    if remote.dragon:getTaskCompleteState() then
        app.tip:floatTip("今日任务已完成")
        return
    end

    local unionDragonTaskArrangement = QUnionDragonTaskArrangement.new({taskId = self._id})
    unionDragonTaskArrangement:startBattle()
end

function QUIDialogUnionDragonTrainFight:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if app.sound ~= nil and e then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogUnionDragonTrainFight:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainFight:viewAnimationOutHandler()
    local options = self:getOptions()
    local callBack = options.callBack
    self:popSelf()

    if callBack ~= nil then
        callBack()
    end
end

return QUIDialogUnionDragonTrainFight