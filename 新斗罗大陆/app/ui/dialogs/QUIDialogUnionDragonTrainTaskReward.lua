
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogUnionDragonTrainTaskReward = class("QUIDialogUnionDragonTrainTaskReward", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")


function QUIDialogUnionDragonTrainTaskReward:ctor(options)
    local ccbFile = "ccb/Dialog_Society_Dragon_Task_Reward.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerReceive", callback = handler(self, self._onTriggerReceive)},
    }
    QUIDialogUnionDragonTrainTaskReward.super.ctor(self,ccbFile,callBacks,options)
    self._ccbOwner.frame_tf_title:setString("任务完成")   

    self._id = options.id

    self:_init()
end

function QUIDialogUnionDragonTrainTaskReward:viewDidAppear()
    QUIDialogUnionDragonTrainTaskReward.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainTaskReward:viewWillDisappear()
    QUIDialogUnionDragonTrainTaskReward.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonTrainTaskReward:_resetAll()
    local index = 1
    while true do
        local node = self._ccbOwner["node_"..index]
        if node then
            node:removeAllChildren()
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogUnionDragonTrainTaskReward:_init()
    self:_resetAll()

    local dragonInfo = remote.dragon:getDragonInfo()
    local taskCompleteCount = dragonInfo.taskCompleteCount or 0
    local level = remote.union.consortia.level or 1
    local memberLimit = db:getSocietyMemberLimitByLevel(level) or 1
    if taskCompleteCount >= memberLimit then
        self._ccbOwner.tf_limit_tips:setString("本日宗门武魂任务经验已达上限")
        self._ccbOwner.tf_limit_tips:setVisible(true)
    else
        self._ccbOwner.tf_limit_tips:setVisible(false)
    end

    local taskConfig = remote.dragon:getTaskInfoById(self._id)
    self._ccbOwner.tf_explain:setString("魂师大人！您已经成功完成了"..taskConfig.name.."任务，\n请领取您的奖励：")

    local index = 1
    if taskConfig then
        if taskConfig.lucky_draw then
            local luckyDrawConfig = remote.dragon:getLuckyDrawById(taskConfig.lucky_draw)
            while true do
                if luckyDrawConfig[index] then
                    local id = luckyDrawConfig[index].id
                    local typeName = luckyDrawConfig[index].typeName
                    local count = luckyDrawConfig[index].count
                    local node = self._ccbOwner["node_"..index]
                    -- print(id, typeName, count, node)
                    if node and typeName then
                        local itemBox = QUIWidgetItemsBox.new()
                        itemBox:setPromptIsOpen(true)
                        itemBox:resetAll()
                        itemBox:setGoodsInfo(id, typeName, count)
                        node:removeAllChildren()
                        node:addChild(itemBox)
                        node:setVisible(true)
                        index = index + 1
                    else
                        break
                    end
                else
                    break
                end
            end
        end
        if taskConfig.dragon_exp then
            local node = self._ccbOwner["node_"..index]
            if node then
                local itemBox = QUIWidgetItemsBox.new()
                itemBox:setPromptIsOpen(true)
                itemBox:resetAll()
                itemBox:setGoodsInfo(remote.dragon.EXP_RESOURCE_ID, remote.dragon.EXP_RESOURCE_TYPE, taskConfig.dragon_exp)
                node:addChild(itemBox)
                node:setVisible(true)
                index = index + 1
            end
        else
            index = index - 1
        end

        if taskConfig.dragon_exp and remote.union:isDragonTrainBuff() then
            local node = self._ccbOwner["node_"..index]
            if node then
                local itemBox = QUIWidgetItemsBox.new()
                itemBox:setPromptIsOpen(true)
                itemBox:resetAll()
                itemBox:setGoodsInfo(remote.dragon.EXP_RESOURCE_ID, remote.dragon.EXP_RESOURCE_TYPE, taskConfig.dragon_exp)
                itemBox:setAwardName("神赐加成")
                node:addChild(itemBox)
                node:setVisible(true)
            end
        end
    end

    if index == 1 then
        self._ccbOwner.node_item:setPositionX(130)
    elseif index == 2 then
        self._ccbOwner.node_item:setPositionX(64)
    elseif index == 3 then
        self._ccbOwner.node_item:setPositionX(0)
    else
        self._ccbOwner.node_item:setPositionX(0)
    end

    index = 1
    while true do
        local node = self._ccbOwner["node_receive"..index]
        if node then
            node:setVisible(true)
            self:_initBtnInfo(index)
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogUnionDragonTrainTaskReward:_initBtnInfo(i)
    local taskMultipleInfo = remote.dragon:getTaskMultipleInfoByIndex(i)
    if taskMultipleInfo then 
        if taskMultipleInfo.multiple and taskMultipleInfo.multiple > 1 then
            self._ccbOwner["tf_receive"..i]:setString("领取"..taskMultipleInfo.multiple.."倍")
        else
            self._ccbOwner["tf_receive"..i]:setString("领  取")
        end
        if taskMultipleInfo.consume and taskMultipleInfo.consume > 0 then
            self._ccbOwner["node_consume"..i]:setVisible(true)
            self._ccbOwner["tf_consume"..i]:setString(taskMultipleInfo.consume)
        else
            self._ccbOwner["node_consume"..i]:setVisible(false)
        end
    else
        self._ccbOwner["tf_receive"..i]:setString("领  取")
        self._ccbOwner["node_consume"..i]:setVisible(false)
    end
end

function QUIDialogUnionDragonTrainTaskReward:_onTriggerReceive(e, target)
    if q.buttonEventShadow(e, target) == false then return end
    if app.sound ~= nil then
        app.sound:playSound("common_small")
    end
    if not remote.dragon:getTaskCompleteState() or remote.dragon:getTaskEndState() then return end

    local index = 1
    while true do
        local btn = self._ccbOwner["btn_receive"..index]
        if btn then
            if btn == target then
                remote.dragon:consortiaDragonGetTaskProgressRequest(index, false, self:safeHandler(function(data)
                        self._isGetTaskReward = true
                        if data and data.error == "NO_ERROR" and data.prizes then
                            if data.consortiaGetDragonInfoResponse then
                                local dragonExp = data.consortiaGetDragonInfoResponse.dragonExp
                                if dragonExp and dragonExp ~= "" then
                                    local tbl = string.split(dragonExp, "^")
                                    table.insert(data.prizes, {id = remote.dragon.EXP_RESOURCE_ID, type = remote.dragon.EXP_RESOURCE_TYPE, count = tonumber(tbl[2])})
                                end
                                self._rewardData = data.prizes
                            end
                        end
                        self:_onTriggerClose()
                    end))
                break
            end
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogUnionDragonTrainTaskReward:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if app.sound ~= nil and e then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogUnionDragonTrainTaskReward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainTaskReward:viewAnimationOutHandler()
    local options = self:getOptions()
    local callBack = options.callBack
    self:popSelf()

    if callBack ~= nil then
        callBack()
    end

    if self._isGetTaskReward then
        if self._rewardData then
            remote.dragon:showRewardForDialog(self._rewardData)
        else
            remote.dragon:dispatchTaskRewardShowEndEvent()
        end
    end
end

return QUIDialogUnionDragonTrainTaskReward