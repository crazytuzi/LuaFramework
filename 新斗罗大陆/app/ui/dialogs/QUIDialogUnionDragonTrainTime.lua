
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogUnionDragonTrainTime = class("QUIDialogUnionDragonTrainTime", QUIDialog)

function QUIDialogUnionDragonTrainTime:ctor(options)
    local ccbFile = "ccb/Dialog_Society_Dragon_Task_Time.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogUnionDragonTrainTime.super.ctor(self,ccbFile,callBacks,options)
    self._ccbOwner.frame_tf_title:setString("")

    self._id = options.id

    self:_init()
end

function QUIDialogUnionDragonTrainTime:viewDidAppear()
    QUIDialogUnionDragonTrainTime.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainTime:viewWillDisappear()
    QUIDialogUnionDragonTrainTime.super.viewWillDisappear(self)

    if self._countDownScheduler then
        scheduler.unscheduleGlobal(self._countDownScheduler)
        self._countDownScheduler = nil
    end
end

function QUIDialogUnionDragonTrainTime:_init()
    local taskInfo = remote.dragon:getTaskInfoById( self._id )
    if taskInfo then
        self._ccbOwner.frame_tf_title:setString(taskInfo.name)
        self._ccbOwner.tf_taskExplain:setString(taskInfo.description)
    end

    -- 和时间有关的数据
    self:_updateCountDown()
    if self._countDownScheduler then
        scheduler.unscheduleGlobal(self._countDownScheduler)
        self._countDownScheduler = nil
    end
    self._countDownScheduler = scheduler.scheduleGlobal(function ()
        self:_updateCountDown()
    end, 1)
end

function QUIDialogUnionDragonTrainTime:_updateCountDown()
    local isStart, isComplete, countDownStr = remote.dragon:updateTimeByStartAt()
    self._isDoing = isStart
    if isStart and isComplete then
        if self._countDownScheduler then
            scheduler.unscheduleGlobal(self._countDownScheduler)
            self._countDownScheduler = nil
        end
        remote.dragon:setTaskCompleteState(true)
    end
    if isStart then
        self._ccbOwner.tf_do_explain:setString("打扫底座剩余：")
        self._ccbOwner.tf_countdown:setString(countDownStr)
        self._ccbOwner.tf_countdown:setVisible(true)
    else
        self._ccbOwner.tf_do_explain:setString("打扫底座需要等待30分钟")
        self._ccbOwner.tf_countdown:setVisible(false)
    end
    self._ccbOwner.node_btn:setVisible(not isStart)
end

function QUIDialogUnionDragonTrainTime:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    if app.sound ~= nil then
        app.sound:playSound("common_small")
    end
    if self._isDoing then 
        app.tip:floatTip("正在打扫中")
        return
    end
    remote.dragon:consortiaDragonDoTaskRequest(self._id)
end

function QUIDialogUnionDragonTrainTime:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if app.sound ~= nil and e then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogUnionDragonTrainTime:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainTime:viewAnimationOutHandler()
    local options = self:getOptions()
    local callBack = options.callBack
    self:popSelf()

    if callBack ~= nil then
        callBack()
    end
end

return QUIDialogUnionDragonTrainTime