
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogUnionDragonTrainQA = class("QUIDialogUnionDragonTrainQA", QUIDialog)

function QUIDialogUnionDragonTrainQA:ctor(options)
    local ccbFile = "ccb/Dialog_Society_Dragon_Task_QA.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerAnswer", callback = handler(self, self._onTriggerAnswer)},
    }
    QUIDialogUnionDragonTrainQA.super.ctor(self,ccbFile,callBacks,options)

    self._id = options.id

    self:_init()
end

function QUIDialogUnionDragonTrainQA:viewDidAppear()
    QUIDialogUnionDragonTrainQA.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainQA:viewWillDisappear()
    QUIDialogUnionDragonTrainQA.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonTrainQA:_init()
    local taskInfo = remote.dragon:getTaskInfoById( self._id )
    if taskInfo then
        -- self._ccbOwner.tf_title:setString(taskInfo.name)
        self._ccbOwner.tf_taskExplain:setString(taskInfo.description)
    end

    local myTaskInfo = remote.dragon:getMyTaskInfo()
    self._qaIndex = myTaskInfo.answerCount + 1
    -- print("self._qaIndex = ", self._qaIndex )
    self:_update()
end

function QUIDialogUnionDragonTrainQA:_update()
    self:_resetBtn()
    
    local myTaskInfo = remote.dragon:getMyTaskInfo()

    local num = tonumber(remote.dragon:getTaskCompleteRequirementById(self._id)) - myTaskInfo.correctCount
    if num < 0 then num = 0 end
    -- self._ccbOwner.tf_progress:setString("今日还需培育仙品"..num.."次")
    self._ccbOwner.tf_progress:setString(num)
    if num == 0 or remote.dragon:getTaskCompleteState() then
        self:_onTriggerClose()
        return
    end
    
    if myTaskInfo.answerCount == self._qaIndex then
        -- 已答题
        self:_showAnswer()
    else
        self:_updateQuestion()
    end
end

function QUIDialogUnionDragonTrainQA:_showAnswer()
    -- app.tip:floatTip("继续下一题")
    self._qaIndex = self._qaIndex + 1
    self:_updateQuestion()
end

function QUIDialogUnionDragonTrainQA:_updateQuestion()
    local qaInfo = remote.dragon:updateQAInfoByIndex( self._qaIndex )
    QPrintTable(qaInfo)
    if qaInfo and qaInfo.qId and (not self._qId or self._qId ~= qaInfo.qId) then
        local qaConfig = remote.dragon:getQAConfigById(qaInfo.qId)
        self._ccbOwner.tf_question:setString(qaConfig.question)
        local answerTbl = string.split(qaConfig.all_answer, ";")
        for index, value in ipairs(answerTbl) do
            if value == qaConfig.answer_name then
                self._answerIndex = index
            end
            self._ccbOwner["tf_answer_"..index]:setString(value)
        end
        self._qId = qaInfo.qId
        self._ccbOwner.node_btn:setVisible(true)
    else
        self._ccbOwner.tf_question:setString("今天已经浪费太多次培养机会了，请明天再来吧")
        self._ccbOwner.node_btn:setVisible(false)
    end
end

function QUIDialogUnionDragonTrainQA:_resetBtn()
    local index = 1
    while true do
        local btn = self._ccbOwner["btn_answer_"..index]
        if btn then
            btn:setHighlighted(false)
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogUnionDragonTrainQA:_onTriggerAnswer(e, target)
    if q.buttonEventShadow(e, target) == false then return end
    if app.sound ~= nil then
        app.sound:playSound("common_small")
    end

    self:_resetBtn()
    local index = 1
    while true do
        local btn = self._ccbOwner["btn_answer_"..index]
        if btn then
            if btn == target then
                self._selectedAnswerIndex = index
                btn:setHighlighted(true)
                break
            end
            index = index + 1
        else
            break
        end
    end

    if self._selectedAnswerIndex and self._selectedAnswerIndex > 0 then
        local param = self._ccbOwner["tf_answer_"..self._selectedAnswerIndex]:getString()
        -- print(" param = ", param)
        remote.dragon:consortiaDragonDoTaskRequest(self._id, param, self:safeHandler(function(data)
                if data and data.error == "NO_ERROR" and data.consortiaGetDragonInfoResponse then
                    if remote.dragon:getTaskCompleteState() then
                        app.tip:floatTip("任务完成")
                    elseif data.consortiaGetDragonInfoResponse.answerCorrect then
                        app.tip:floatTip("仙草好像茁壮成长了一点")
                    else
                        app.tip:floatTip("好像什么都没有发生呢")
                    end
                end
                self:_update()
            end))
    end
end

function QUIDialogUnionDragonTrainQA:_onTriggerClose(e)
    if app.sound ~= nil and e then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogUnionDragonTrainQA:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainQA:viewAnimationOutHandler()
    local options = self:getOptions()
    local callBack = options.callBack
    self:popSelf()

    if callBack ~= nil then
        callBack()
    end
end

return QUIDialogUnionDragonTrainQA