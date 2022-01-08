
--[[
******老玩家回归管理类*******
	-- yaojie
	-- 2016/1/12
]]


local PlayBackManager = class("PlayBackManager")

local taskConfig = require("lua.table.t_s_recall_task")
recallConf= require("lua.table.t_s_recall_conf")

PlayBackManager.UPDATETASK = "PlayBackManager.UPDATETASK"
PlayBackManager.LIBAOLINGQUSUCCESS = "PlayBackManager.LIBAOLINGQUSUCCESS"
PlayBackManager.ZHUANGSHULIBAOLINGQUSUCCESS = "PlayBackManager.ZHUANGSHULIBAOLINGQUSUCCESS"
PlayBackManager.ZHAOHUISUCCESS = "PlayBackManager.ZHAOHUISUCCESS"

function PlayBackManager:ctor() 
    self:restart()
    TFDirector:addProto(s2c.RECALL_TASK_LIST, self,self.onReceiveTaskListResult)
    TFDirector:addProto(s2c.GET_RECALL_TASK_REWARD_RESULT, self, self.onReceiveGetRewardResult)
    TFDirector:addProto(s2c.NOTIFY_RECALL_TASK_FINISH, self, self.onNotifyRecallTaskFinishResult)
    TFDirector:addProto(s2c.NOTIFY_NEW_RECALL_TASK, self, self.onNotifyNewRecallTaskResult)
    TFDirector:addProto(s2c.NOTIFY_RECALL_TASK_STEP, self, self.onNotifyRecallTaskStepResult)
    TFDirector:addProto(s2c.RECALL_SUCCESS_NOTIFY, self, self.RecallSuccessNotifyResult)
    TFDirector:addProto(s2c.APPLY_INVITE_CODE_SUCCESS, self, self.ApplyInviteCodeSuccessResult)
    TFDirector:addProto(s2c.MY_BE_RECALLED_INVITE_LIST, self, self.MyBeRecalledInviteList)
    TFDirector:addProto(s2c.MY_ACTIVE_RECALL_INVITE_LIST, self, self.MyActiveRecallInviteList)
    TFDirector:addProto(s2c.RECALL_RETURN_INFO, self, self.RecallReturnInfoResult)
    TFDirector:addProto(s2c.APPLY_RETURN_GIFT_SUCESS, self, self.lingquLibaoSuccess)

    self.taskList       = {}        --所以得任务信息
    self.showTaskList   = {}        --需要显示的任务信息
    self.taskConfig     = taskConfig--任务表配置信息
    self.inviteList     = {}        --邀请列表
    --self.beinviteList   = {}        --被邀请列表
    self.recallReturnInfo = nil     --玩家回归信息
    self.huiguiList     = {}        --已回归的玩家列表
end

function PlayBackManager:restart()
    self.recallReturnInfo   = nil     --玩家回归信息
    --self.taskList           = {}
    --self.showTaskList       = {}
    --self.inviteList         = {}
end

--显示玩家回归主界面
function PlayBackManager:showPlayerBackMainLayer()
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.playerback.PlayerBackMainLayer");  
    AlertManager:show();
end

--显示玩家回归奖励界面
function PlayBackManager:showPlayerBackRewardLayer()
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.playerback.PlayerBackRewardLayer",AlertManager.BLOCK_AND_GRAY,tween); 
    AlertManager:show()
end

--请求任务信息
function PlayBackManager:requestQueryRecallTaskInfo()
    self:getInitalTaskInfo()

    local Msg = {
    }
    TFDirector:send(c2s.QUERY_RECALL_TASK,Msg)
    showLoading()  
end

--返回任务信息 
function PlayBackManager:onReceiveTaskListResult(event)
    hideLoading()
    local list = event.data.tasklist
    --print("-----------onReceiveTaskListResult = ", list)
    --print("self.taskList =",self.taskList)
    if next(list)~= nil then
        for k,v in pairs(list) do
            if self.taskList and self.taskList[v.taskid] ~= nil then
                self.taskList[v.taskid].state     =  v.state
                self.taskList[v.taskid].currstep  =  v.currstep
                self.taskList[v.taskid].totalstep =  v.totalstep
            end
        end
    end
    TFDirector:dispatchGlobalEventWith(PlayBackManager.UPDATETASK,{})
end

--领取奖励请求
function PlayBackManager:getReward(taskid)
    local Msg = {
        taskid,
    }
    TFDirector:send(c2s.GET_RECALL_TASK_REWARD,Msg)
    showLoading()
end

--领取奖励成功
function PlayBackManager:onReceiveGetRewardResult( event )
    hideLoading()
    local taskid = event.data.taskid[1]
    if self.taskList and self.taskList[taskid]~=nil then
        self.taskList[taskid].state = 2
    end
    TFDirector:dispatchGlobalEventWith(PlayBackManager.UPDATETASK,{})
end

--通知成就完成
function PlayBackManager:onNotifyRecallTaskFinishResult( event )
    hideLoading()
    local taskid = event.data.taskid
    if self.taskList and self.taskList[taskid]~=nil then
        self.taskList[taskid].state = 1
    end
    TFDirector:dispatchGlobalEventWith(PlayBackManager.UPDATETASK,{})
end

--新任务(领奖后发送)
function PlayBackManager:onNotifyNewRecallTaskResult( event )
    hideLoading()
    local list = event.data.tasklist
    if next(list)~= nil then
        for k,v in pairs(list) do
            if self.taskList and self.taskList[v.taskid] ~= nil then
                self.taskList[v.taskid].state     =  v.state
                self.taskList[v.taskid].currstep  =  v.currstep
                self.taskList[v.taskid].totalstep =  v.totalstep
            end
        end
    end
    TFDirector:dispatchGlobalEventWith(PlayBackManager.UPDATETASK,{})
end

--通知成就进度变化
function PlayBackManager:onNotifyRecallTaskStepResult( event )
    hideLoading()
    local taskid = event.data.taskid
    if self.taskList and self.taskList[taskid]~=nil then
        self.taskList[taskid].currstep = event.data.currstep
    end

    TFDirector:dispatchGlobalEventWith(PlayBackManager.UPDATETASK,{})
end

--请求召回玩家
function PlayBackManager:requestRecallPlayer(playerId)  
    local Msg = {
        playerId,
    }
    TFDirector:send(c2s.REQUEST_RECALL,Msg)
    showLoading()
end

--召回玩家成功
function PlayBackManager:RecallSuccessNotifyResult(event)
    hideLoading()
    local recalledId = event.data.playerId
    -- toastMessage("召回玩家成功")
    toastMessage(localizable.PlayBackManager_zhaohui_suc)

    local info = {playerId = 0,recalledId = recalledId,luanchTime = 0,inviteCode = "0"}
    table.insert(self.inviteList,info)
    TFDirector:dispatchGlobalEventWith(PlayBackManager.ZHAOHUISUCCESS,{playerId})
end

--提交邀请码
function PlayBackManager:requestApplyRecallInviteCode(inviteCode)
    local Msg = {
        inviteCode,
    }
    TFDirector:send(c2s.APPLY_RECALL_INVITE_CODE,Msg)
    showLoading()
end

--提交邀请码成功
function PlayBackManager:ApplyInviteCodeSuccessResult(event)  
    hideLoading()
    -- toastMessage("提交邀请码成功")
    toastMessage(localizable.PlayBackManager_yaoqing_suc)

    self.recallReturnInfo.fromPlayerId = 1
    TFDirector:dispatchGlobalEventWith(PlayBackManager.LIBAOLINGQUSUCCESS,{})
end

--玩家邀请列表
function PlayBackManager:MyActiveRecallInviteList(event)
    self.inviteList = event.data.invaite
    self.huiguiList = event.data.playerIds
    --toastMessage("发送邀请列表成功")
    --print("self.inviteList =",self.inviteList)
end

-- --玩家被邀请列表
-- function PlayBackManager:MyBeRecalledInviteList(event)
--     self.beinviteList = event.data.invaite
--     print("self.beinviteList =",self.beinviteList)
-- end

--玩家回归信息，填写了邀请码之后信息才会变更
function PlayBackManager:RecallReturnInfoResult(event)
    --print("RecallReturnInfoResult ==== 收到了玩家回归数据",event.data)
    self.recallReturnInfo = event.data
end

--领取礼包
function PlayBackManager:lingquLibao()
    local Msg = {
    }
    TFDirector:send(c2s.APPLY_RETURN_GIFT,Msg)
    showLoading()
end

--领取礼包成功
function PlayBackManager:lingquLibaoSuccess(event)
    hideLoading()
    self.recallReturnInfo.rewardGot = 1
    TFDirector:dispatchGlobalEventWith(PlayBackManager.ZHUANGSHULIBAOLINGQUSUCCESS,{})
end


--前往进行任务
function PlayBackManager:gotoTask(taskdata,showLayer)
    if taskdata == nil then
        return false
    end
    local taskType = taskdata.type
    if taskType == 103 then
        MissionManager:showHomeLayer()
    elseif taskType == 209 then
        local teamLev = MainPlayer:getLevel()
        local openLev = FunctionOpenConfigure:getOpenLevel(101)
        if teamLev < openLev then
            -- toastMessage("团队等级达到"..openLev.."级开启")
            toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
            return false
        end
        EquipmentManager:OpenSmithyMainLaye()
    elseif taskType == 208 then
        local funId = 103
        local teamLev = MainPlayer:getLevel()
        local openLev = FunctionOpenConfigure:getOpenLevel(funId)
        if teamLev < openLev then
            -- toastMessage("团队等级达到"..openLev.."级开启")
            toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
            return false
        end
        EquipmentManager:OpenSmithyMainLaye()
    elseif taskType == 1900 then
        local ishsaGang = FactionManager:isJoinFaction()
        if ishsaGang == false then
            -- toastMessage("未加入帮派，不能祭拜")
            toastMessage(localizable.PlayBackManager_jibai_fail)
            return false
        end
        FactionManager:openFactionFromHomeIcon()
    elseif taskType == 3000 then
        --伏魔录
        local funId = 1101
        local teamLev = MainPlayer:getLevel()
        local openLev = FunctionOpenConfigure:getOpenLevel(funId)
        if teamLev < openLev then
            -- toastMessage("团队等级达到"..openLev.."级开启")
            toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
            return false
        end
        ActivityManager:showLayer(ActivityManager.TAP_FuMoLu)      
    elseif taskType == 3001 then
        local funId = 2101
        local teamLev = MainPlayer:getLevel()
        local openLev = FunctionOpenConfigure:getOpenLevel(funId)
        if teamLev < openLev then
            -- toastMessage("团队等级达到"..openLev.."级开启"))
            toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
            return false
        end     
        ActivityManager:showLayer(ActivityManager.TAP_ShengNongKuang)
    elseif taskType == 3002 then
        --无量山
        local funId = 401
        local teamLev = MainPlayer:getLevel()
        local openLev = FunctionOpenConfigure:getOpenLevel(funId)
        if teamLev < openLev then
            -- toastMessage("团队等级达到"..openLev.."级开启")
            toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
            return false
        end
        ActivityManager:showLayer(ActivityManager.TAP_Climb)
    elseif taskType == 1002 then
        local teamLev = MainPlayer:getLevel()
        local openLev = FunctionOpenConfigure:getOpenLevel(106)
        if teamLev < openLev then
            -- toastMessage("团队等级达到"..openLev.."级开启")
            toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
            return false
        end
        PayManager:showPayHomeLayer();
    end
end

--获得需要显示的任务列表信息
function PlayBackManager:getShowTaskList()
    self.showTaskList = self:checkShowTaskList()
    self.showTaskList = self:getTaskSort(self.showTaskList)
    --print("self.showTaskList ===",self.showTaskList)
    return self.showTaskList
end

--获取初始任务信息
function PlayBackManager:getInitalTaskInfo()
    for v in self.taskConfig:iterator() do
        v.state = 2
        v.taskid = v.id
        v.currstep = 0
        v.totalstep = 100
        self.taskList[v.id] = v
    end
end

--筛选显示的任务列表
function PlayBackManager:checkShowTaskList()
    self.showTaskList = {}
    for m,n in pairs(self.taskList) do
        if n.state ~= 2 then
            table.insert(self.showTaskList,n)
        end
    end
    return self.showTaskList
end

--获得邀请列表
function PlayBackManager:getInviteList()
    return self.inviteList
end

-- --获得被邀请列表
-- function PlayBackManager:getInviteList()
--     return self.beinviteList
-- end

--排序
function PlayBackManager:getTaskSort(list)
    local function cmp1( num1 ,num2 )
        if num1 == 1 then
        return true
        end
        if num2 == 1 then
        return false
        end
        if num1 > num2 then
            return false
        end
        return true
    end

    -- int32 state = 2;     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
    local function cmp(task1, task2)

        if task1.state ~= task2.state then
            return cmp1(task1.state,task2.state)
        end

        if task1.taskid < task2.taskid then
            return true
        end

        return false

    end

    if #list > 1 then
        table.sort(list,cmp)
    end
    return list
end

--老玩家回归条件是否达成
function PlayBackManager:playerBackOpenSatus()
    local isopen = false
    local nowtime = MainPlayer:getNowtime()
    if self.recallReturnInfo~=nil and nowtime < self.recallReturnInfo.backTime + 7*24*3600 then
        isopen = true
    end
    return isopen
end

--获得老玩家回归信息
function PlayBackManager:getRecallReturnInfo()
    return self.recallReturnInfo
end

--是否有奖励
function PlayBackManager:checkRedPoint()
    if self.recallReturnInfo == nil then
        return false
    else
        local rewardGot = self.recallReturnInfo.rewardGot
        local rewardtype = bit_and(rewardGot,1)
        if rewardtype == 0 then
            return true
        end
    end

    for k,v in pairs(self.taskList) do
        if v.state == 1 then
            return true
        end
    end
    return false
end

--是否显示召回按钮
function PlayBackManager:isShowZhaohuiBtn(playerId)
    local nowtime = MainPlayer:getNowtime()
    local iszhaohui = true
    --print("playerId =",playerId)
    --print("self.inviteList =",self.inviteList)
    --print("self.huiguiList =",self.huiguiList)
    if next(self.inviteList) ~= nil then
        for k,v in pairs(self.inviteList) do
            if v.recalledId == playerId then
                iszhaohui = false
            end
        end
    end
    if self.huiguiList == nil or next(self.huiguiList) == nil then
    else
        for k,v in pairs(self.huiguiList) do
            if v == playerId then
                iszhaohui = false
            end 
        end
    end
    return iszhaohui  
end

--是否玩家需要被召回
function PlayBackManager:playerNeedBeCallBack(playerId, level, loginTime)
    local bNeedCallBack = false
    local lastLoginTime = math.floor(loginTime/1000)
    -- 大于15天 并且 离线15天
    local needlevel = recallConf:objectByID(1).min_level
    local days = recallConf:objectByID(1).min_days
    --print("needlevel =",needlevel)
    --print("days =",days)
    if level < needlevel or MainPlayer:getNowtime() < (lastLoginTime + days * 24 * 3600) then
        return bNeedCallBack
    end

    return self:isShowZhaohuiBtn(playerId)
end

return PlayBackManager:new();
