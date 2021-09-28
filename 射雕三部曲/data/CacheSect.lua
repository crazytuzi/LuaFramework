--[[
文件名:CacheSect.lua
描述：八大门派的数据抽象类型
创建人：peiyaoqiang
创建时间：2017.08.22
--]]

-- 门派数据说明
--[[
-- 服务器返回门派数据格式为
	SectInfo:玩家所有门派信息
    [
        {
            SectId:门派Id
            TotalSectCoin:此门派总声望
            SectCoin:此门派当前声望
            SectRank:门派称号id
            SectRankName:门派称号
            IsJoinIn:是否在此门派中
            InTime:加入此门派时间
            OutTime:退出此门派时间
        }
        ...
    ]
    CurrentSectInfo:玩家当前门派信息
    {
        SectId:门派Id
        TotalSectCoin:此门派总声望
        SectCoin:此门派当前声望
        SectRank:门派称号id
        SectRankName:门派称号
        IsJoinIn:是否在此门派中
        InTime:加入此门派时间
        OutTime:退出此门派时间
    }
    IsJoinIn:是否加入门派
]]

-- 门派Avatar数据说明
--[[
-- 服务器返回门派Avatar数据格式为
    {

    }
]]

local CacheSect = class("CacheSect", {})

function CacheSect:ctor()
    --所有门派信息
    self.mSectInfo = nil
    self.mAllSects = nil --处理后的数据
    --当前门派信息
    self.mCurSectInfo = nil
    --是否加入门派
    self.mIsJoinIn = nil
    --任务信息
    self.mTasksInfo = nil
    --是否退出门派
    self.mIsChangeSect = false
    --迷宫信息
    self.mChamberInfo = nil
    -- 声望榜
    self.mRankInfo = nil
    --是否有可以接的任务
    self.mCanReceiveTask = nil
end

-- 重置门派缓存对象
function CacheSect:reset()
    print("resetCacheSect")
    --所有门派信息
    self.mSectInfo = nil
    self.mAllSects = nil --处理后的数据
    --当前门派信息
    self.mCurSectInfo = nil
    --是否加入门派
    self.mIsJoinIn = nil
    --任务信息
    self.mTasksInfo = nil
    --是否退出门派
    self.mIsChangeSect = false
    --迷宫信息
    self.mChamberInfo = nil
    -- 声望榜
    self.mRankInfo = nil
    --是否有可以接的任务
    self.mCanReceiveTask = nil
end

----------------------------------------------------------------------------------------------------
-- 公开接口：需要修改数据的接口

-- 设置门派缓存数据
--[[
-- 参数 sectData 中的各项参考文件头处的 “门派数据说明”
]]
function CacheSect:updateSectInfo(sectData)
    -- 通知门派信息改变
    Notification:postNotification(EventsName.eSectHomeAll)
end

----------------------------------------------------------------------------------------------------
-- 公开接口：单纯获取信息的接口

-- 获取门派信息
function CacheSect:getSectInfo(callback)
    local function findData()
        local tempData = {}
        tempData.IsJoinIn = self.mIsJoinIn
        tempData.CurrentSectInfo = self.mCurSectInfo
        tempData.SectInfo = self.mAllSects
        tempData.TasksInfo = self.mTasksInfo
        return tempData
    end

    local tempData = findData()
    if tempData.SectInfo then
        if callback then
            callback(tempData)
        end
        return tempData
    else
        self:requestSectInfo(callback)
    end

end

-- 获取玩家的门派声望信息
function CacheSect:getPlayerSectInfo(callback)
    return self.mCurSectInfo
end

function CacheSect:setPlayerSectInfo(info)
    if info == nil then return end

    self.mCurSectInfo = info
end

-- 获取玩家门派职位
--[[
    参数：
    sectId: 门派Id

--]]
--function CacheSect:getSectRank(sectId)
function CacheSect:getSectRank()
     return self.mCurSectInfo.SectRank
end

-- 获取某个门派的声望排行数据
function CacheSect:getRankInfo(sectId)
    return self.mRankInfo[sectId] or {}
end

--获取是否加入门派的状态
function CacheSect:getJoinStatus()
    return self.mIsJoinIn
end

-- 获取门派任务进度信息
function CacheSect:getTasksInfo()
    return self.mTasksInfo or {}
end

-- 获取迷宫信息
function CacheSect:getChamberInfo()
    return self.mChamberInfo or {}
end

-- 获取声望列表
function CacheSect:getSectCoinList()
    local sectCoinList = {}
    sectCoinList.allSect = {}
    for i,v in ipairs(self.mAllSects) do
        sectCoinList.allSect[v.SectId] = v.TotalSectCoin
    end
    sectCoinList.curSectId = self.mCurSectInfo.SectId

    return sectCoinList
end

--获取玩家今日是否退出过门派
function CacheSect:isChangeSect()
    return self.mIsChangeSect or false
end

--获取是否有可以接的任务
function CacheSect:getCanCanReceiveTask()
    return self.mCanReceiveTask
end

--解锁长老
function CacheSect:unLockTeacher(teacherId, callback)
    self:requestUnLock(teacherId, callback)
end

--更新任务进度
function CacheSect:refreshTaskProgress(taskId, callback)
    self:requestRefreshTaskInfo(taskId, callback)
end

--领取任务
function CacheSect:getTask(taskId, callback)
    self:requestGetTask(taskId, 0, callback)
end
--放弃任务
function CacheSect:giveUpTask(taskId, callback)
    self:requestGetTask(taskId, 1, callback)
end
--完成任务
function CacheSect:finishTask(taskId, callback)
    self:requestFinishTask(taskId, callback)
end

--领取迷宫宝箱
function CacheSect:getChamberBox(callback)
    self:requestGetChamberBox(callback)
end

-- 进阶弹窗
function CacheSect:createRankPopLayer()
    -- 是否弹出了弹窗
    local isPopMsg = false
    -- 当前职位高于原职位
    if self.mCurSectInfo.SectRank < self.oldRank then
        PopBgLayer.sectRankAdvanced(self.mCurSectInfo.SectId, self.mCurSectInfo.SectRank)
        isPopMsg = true
    end
    -- 更新原职位
    self.oldRank = self.mCurSectInfo.SectRank
    -- 返回弹窗是否弹出
    return isPopMsg
end

-- -- 获取门派小红点心信息
-- --[[
-- -- 参数
--     keyName: 门派小红点表中的字段名，取值为：“ApplyList”、“PostLack”， “BuildingLv”
-- ]]
-- function CacheSect:getRedInfo(keyName)
--     return self.mGlobalGuildRedInfo[keyName] or false
-- end

----------------------------------------------------------------------------------------------------
-- 私有接口：不建议外部调用

-- ================================== 与缓存数据相关的网络请求 =======================
--[[
    获取玩家所有门派信息
--]]
function CacheSect:requestSectInfo(callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "GetSectInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            dump(response, "getinfo")
            -- self.mSectInfo = response
            self.mAllSects = {}
            for _, sectItem in ipairs(response.Value.SectInfo) do
                self.mAllSects[sectItem.SectId] = sectItem
            end
            self.mCurSectInfo = response.Value.CurrentSectInfo
            self.mIsJoinIn = response.Value.IsJoinIn
            self.mTasksInfo = response.Value.TaskIngList
            self.oldRank = self.mCurSectInfo.SectRank
            --是否退出过门派
            self.mIsChangeSect = response.Value.IsChangeSect
            --迷宫信息
            self.mChamberInfo = response.Value.ChamberInfo
            --
            self.mCanReceiveTask = response.Value.CanReceiveTask

            -- 回调通知调用者
            if callback then
                callback(response.Value)
            end
        end
    })
end


--加入门派
function CacheSect:requestJoinSect(sectId, callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "EnterSect",
        svrMethodData = {sectId},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response, "joinSect")
            self.mCurSectInfo = response.Value.CurrentSectInfo
            self.oldRank = self.mCurSectInfo.SectRank
            self.mIsJoinIn = response.Value.IsJoinIn
            self.mCanReceiveTask = response.Value.CanReceiveTask
            if callback then
                callback(response)
            end
        end
    })
end
--退出门派
function CacheSect:requestExitSect(sectId, callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "ExitSect",
        svrMethodData = {sectId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            self.mCurSectInfo = response.Value.CurrentSectInfo
            self.mIsJoinIn = response.Value.IsJoinIn
            self.mTasksInfo = nil
            self.mChamberInfo = nil
            self.oldRank = nil
            self.mCanReceiveTask = nil

            if callback then
                callback(response)
            end
        end
    })
end
--领取任务
function CacheSect:requestGetTask(taskId, type, callback)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "ReceiveTask",
        svrMethodData = {taskId, type},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            dump(response, "getTask")
            self.mTasksInfo = response.Value.TaskIngList
            self.mCanReceiveTask = response.Value.CanReceiveTask
            if callback then
                callback(response)
            end
        end
    })

end
--完成任务
function CacheSect:requestFinishTask(taskId, callback)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "TaskFinish",
        svrMethodData = {taskId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            dump(response, "finishTask")
            self.mCurSectInfo = response.Value.CurrentSectInfo
            self.mAllSects = {}
            for _, sectItem in ipairs(response.Value.SectInfo) do
                self.mAllSects[sectItem.SectId] = sectItem
            end
            self.mTasksInfo = response.Value.TasksInfo.TaskIngList
            --迷宫信息
            self.mChamberInfo = response.Value.ChamberInfo
            --
            self.mCanReceiveTask = response.Value.TasksInfo.CanReceiveTask

            self:createRankPopLayer()

            if callback then
                callback(response)
            end
        end
    })
end

--领取成就奖励
function CacheSect:requestDrawSectTarget(TargetId, callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "DrawSectTarget",
        svrMethodData = {TargetId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mCurSectInfo = response.Value.CurrentSectInfo

            self:createRankPopLayer()

            if callback then
                callback(response)
            end
        end
    })
end

--更新任务进度
function CacheSect:requestRefreshTaskInfo(taskId, callback)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "UpdateTask",
        svrMethodData = {taskId, 1},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            self.mTasksInfo = response.Value.TaskIngList
            -- dump(response, "refreshTaskProgress")

            if callback then
                callback(response)
            end
        end
    })
end

-- 获取排行榜数据
function CacheSect:requestAllRankInfo(callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "GetSectCoinRankInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 清空排行榜数据
            self.mRankInfo = {}
            -- 更新数据
            for _, v in pairs(response.Value) do
                self.mRankInfo[v.SectId] = v.SectCoinRankInfo
            end
            -- 回调
            if callback then
                callback(response)
            end
        end
    })
end

-- 兑换绝学
function CacheSect:requsetExchangeFashion(sectId, fashionId, callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "ExChangeFashion",
        svrMethodData = {sectId, fashionId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 更新当前门派缓存
            self.mCurSectInfo = response.Value.CurrentSectInfo
            -- 回调
            if callback then
                callback(response)
            end
        end
    })
end

-- 兑换招式
function CacheSect:requsetExchangeBook(shopId, callback)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "ExChangeSectShop",
        svrMethodData = {shopId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
             -- 更新当前门派缓存
            self.mCurSectInfo = response.Value.CurrentSectInfo
            -- 回调
            if callback then
                callback(response)
            end
        end
    })
end

-- 解锁长老
function CacheSect:requestUnLock(teacherId, callback)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "UnLockSect",
        svrMethodData = {teacherId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            dump(response, "解锁长老请求")
            -- 更新当前任务缓存
            self.mTasksInfo = response.Value.TaskIngList
            -- 回调
            if callback then
                callback(response)
            end
        end
    })
end

-- 领取迷宫宝箱
function CacheSect:requestGetChamberBox(callback)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "DrawChamberReward",
        svrMethodData = {},
        callback = function(response)
            -- 判断返回数据
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value, "宝箱数据：")
            -- 飘窗展示奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mChamberInfo = response.Value.ChamberInfo
            -- 回调
            if callback then
                callback(response)
            end
        end,
    })
end

return CacheSect
