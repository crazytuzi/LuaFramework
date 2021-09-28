--[[
    文件名: CacheBattle.lua
    创建人: liaoyuangang
    创建时间: 2016-06-5
    描述: 副本相关数据
--]]

-- 副本数据说明
--[[
-- 服务器返回的副本数据格式为：
    {
        [PlayerId] = {  -- 某个玩家的副本服务器缓存数据
            TriggerInfo = {  -- 副本触发信息
                BossId = nil, -- 当前战斗出发的BossId
                NewChapterId = nil, -- 最新的新开章节模型Id
                IsTriggerTrader = false, -- 是否触发了限时商店
                obtainStar = false, -- 当前战斗获得星星
            }

            BattleInfo: 战役信息
            {
                MaxChapterId: 当前进行到的最大章节
                MaxNodeId: 当前进行进行到的最大节点
                StarCount: 玩家星数（StarCount-UsedStarCount）
                HasBoss: 如果存在boss，则为true，否则为false
            }

            ChapterList = { -- 章节列表
                [ChapterModelId] = {
                    ChapterModelId: 章节模型Id
                    StarCount：星数
                    IfPass：是否通关
                    IfDrawBoxA：是否已领取宝箱A(根据以下3个字段来判断是否需要在战役的列表中给予领取宝箱的提示)
                    IfDrawBoxB：是否已领取宝箱B
                    IfDrawBoxC：是否已领取宝箱C
                    CanDrawRoadBoxA：地下宝箱A的领取状态（0：不能领取，1：能够领取，2：已经领取）
                    CanDrawRoadBoxB：地下宝箱B的领取状态
                    CanDrawRoadBoxC：地下宝箱C的领取状态

                    NodeList = {  -- "节点列表"
                        [NodeModelId] = {
                            NodeModelId: 节点模型Id
                            Flag：节点状态（0：未解锁；1：可挑战；2：已通过；）
                            StarCount：星数
                            FightCount：当天挑战次数，0点重置
                            FightTime：上次挑战时间的时间戳
                            ResetFightCount：重置挑战次数，0点重置
                            ResetFightTime：重置挑战时间的时间戳
                        }
                        ...
                    }
                }

                ...
            }
        }

        ...
    }
]]

-- 章节宝箱信息说明
--[[
-- 宝箱信息格式如下
    {
        StarBox = {
            {
                index = 1, -- 宝箱的序号，
                boxType  = Enums.BattleBoxType.eStarBox,  -- 宝箱类型， 在 Enums.BattleBoxType 中定义
                ifDraw = false, -- 是否已领取
                boxId = 121, -- 宝箱Id
                starCount = 3, -- 拥有的宝箱星数
                needStar = 3, -- 开启宝箱需要的星数
            },
            ...
        },

        RoadBox = {
            {
                index = 1, -- 宝箱的序号，
                boxType  = Enums.BattleBoxType.eRoadBox,  -- 宝箱类型， 在 Enums.BattleBoxType 中定义
                status = Enums.RewardStatus.eNotAllow,  -- 宝箱状态， 在 Enums.RewardStatus 中定义
                boxId = 121, -- 宝箱Id
                points = "628,191", -- 宝箱在地图中的位置
            }
            ...
        }
    }
]]

local CacheBattle = class("CacheBattle", {})

-- 副本缓存数据类构造函数
function CacheBattle:ctor()
    -- 服务器返回的副本数据信息，详细说明参考文件头处的 “副本数据说明”
    self.mDataList = {}

    -- 整理所有章节的节点模型Id列表
    self.mAllNodeIdList = {}
    -- 整理节点模型Id
    require("Config.BattleNodeModel")
    for key, item in pairs(BattleNodeModel.items) do
        self.mAllNodeIdList[item.chapterModelID] = self.mAllNodeIdList[item.chapterModelID] or {}
        table.insert(self.mAllNodeIdList[item.chapterModelID], key)
    end
    -- 排序 节点模型Id
    for _, nodeIdList in pairs(self.mAllNodeIdList) do
        table.sort(nodeIdList, function(nodeId1, nodeId2)
            return nodeId1 < nodeId2
        end)
    end
end

-- ========================= 该模块内使用的函数 ================================
-- 当前的登录玩家的 playerId
local function getPlayerId()
    return PlayerAttrObj:getPlayerAttrByName("PlayerId")
end

-- 把获取节点战斗结果数据更新到缓存中
function CacheBattle:dealFightData(chapterId, nodeId, fightValue)
    local playerId = getPlayerId()
    self.mDataList[playerId] = self.mDataList[playerId] or {}
    local chapterList = self.mDataList[playerId].ChapterList
    local battleInfo = self.mDataList[playerId].BattleInfo
    self.mDataList[playerId].TriggerInfo = self.mDataList[playerId].TriggerInfo or {}
    local triggerInfo = self.mDataList[playerId].TriggerInfo

    -- 处理一个节点的数据
    local function dealOneNodeInfo(newNodeInfo)
        local tempNodeId = newNodeInfo.NodeModelId
        chapterList[chapterId] = chapterList[chapterId] or {}
        chapterList[chapterId].NodeList = chapterList[chapterId].NodeList or {}
        chapterList[chapterId].NodeList[tempNodeId] = chapterList[chapterId].NodeList[tempNodeId] or {}
        local oldNodeInfo = chapterList[chapterId].NodeList[tempNodeId]

        -- 判断是否新得到星星
        local oldStarCount = oldNodeInfo.StarCount or 0
        if oldStarCount < newNodeInfo.StarCount  then
            triggerInfo.obtainStar = true
        end
        -- 把新节点数据更新到缓存中
        for key, value in pairs(newNodeInfo) do
            oldNodeInfo[key] = value
        end
    end

    -- 处理一个章节的数据
    local function dealOneChapterInfo(chapterInfo)
        local tempChapterId = chapterInfo.ChapterModelId
        chapterList[tempChapterId] = chapterList[tempChapterId] or {}
        for key, value in pairs(chapterInfo) do
            if key ~= "NodeList" then
                chapterList[tempChapterId][key] = value
            end
        end

        if chapterInfo.NodeList then
            chapterList[tempChapterId].NodeList = chapterList[tempChapterId].NodeList or {}
            for _, nodeInfo in pairs(chapterInfo.NodeList) do
                chapterList[tempChapterId].NodeList[nodeInfo.NodeModelId] = nodeInfo
            end
        end
    end

    -- 修改缓存数据
    if fightValue.CurrentNode then -- 当前节点信息
        dealOneNodeInfo(fightValue.CurrentNode)
    end
    if fightValue.CurrentChapter then -- 当前章节信息
        dealOneChapterInfo(fightValue.CurrentChapter)
    end
    if fightValue.NextNode then -- 下一个节点信息
        dealOneNodeInfo(fightValue.NextNode)
        -- 更新 “战役信息 BattleInfo” 中的 “MaxNodeId” 字段
        battleInfo.MaxNodeId = math.max(battleInfo.MaxNodeId, fightValue.NextNode.NodeModelId)
    end
    if fightValue.NextChapter then -- 下一章节信息
        dealOneChapterInfo(fightValue.NextChapter)

        -- 更新 “战役信息 BattleInfo” 中的 “MaxChapterId” 字段
        local nextModelId = fightValue.NextChapter.ChapterModelId
        if nextModelId > battleInfo.MaxChapterId then  -- 如果下一章节Id大于当前最大章节Id
            triggerInfo.NewChapterId = nextModelId
        end
        battleInfo.MaxChapterId = math.max(battleInfo.MaxChapterId, nextModelId)

        -- 更新 “战役信息 BattleInfo” 中的 “MaxNodeId” 字段
        local nextNodeId = self.mAllNodeIdList[nextModelId] and self.mAllNodeIdList[nextModelId][1]
        if nextNodeId then
            battleInfo.MaxNodeId = math.max(battleInfo.MaxNodeId, nextNodeId)
        end

        -- 更新下一章节的节点信息
        -- todo
    end
    if fightValue.BossId then -- 触发了Boss
        triggerInfo.BossId = fightValue.BossId
    end
    if fightValue.IsTriggerTrader then -- 触发了限时商店
        triggerInfo.IsTriggerTrader = fightValue.IsTriggerTrader
    end
end

-- 检查章节信息是否过期
function CacheBattle:checkChapterTimeOut(chapterInfo, battleInfo)
    -- 如果没有该章节信息，或章节信息中没有节点信息，或者没有对应的更新时间戳，都认为已过期
    if not chapterInfo or not chapterInfo.NodeList or not chapterInfo.TimeTick then
        return false
    end

    local currTime = Player:getCurrentTime()
    -- 如果更新时间和当前时间没有在同一天，也认为过去
    if not MqTime.isSameDay(currTime, chapterInfo.TimeTick) then
        return false
    end

    -- 如果章节Id是最大章节Id，还需要判断是否有最大节点Id的信息
    local chapterId = chapterInfo.ChapterModelId
    if chapterId == battleInfo.MaxChapterId then
        local haveMaxNodeInfo = false
        for _, nodeInfo in pairs(chapterInfo.NodeList) do
            if battleInfo.MaxNodeId == nodeInfo.NodeModelId then
                haveMaxNodeInfo = true
                break
            end
        end
        if not haveMaxNodeInfo then
            return false
        end
    end

    -- 其它判断条件
    -- Todo

    return true
end

-- ========================== 对外公开的接口 =====================================

-- 获取所有章节的节点模型Id列表
--[[
-- 返回值的格式为：
    {
        [chapterModelId] = {
            NodeModelId1,
            NodeModelId2
            ...
        }
        ...
    }
]]
function CacheBattle:getAllNodeIdList()
    return self.mAllNodeIdList
end

-- 获取战役信息
--[[
-- 参数
    callback: 用于返回数据的回调函数，callback(BattleInfo)
-- 返回值，返回值的数据格式参考 文件头处的 “副本数据说明” 中的 “战役信息” 部分
    如果缓存里有相关的信息，通过函数返回值和回调函数返回相关信息
    如果没有，则需要使用回调函数异步返回
]]
function CacheBattle:getBattleInfo(callback)
    -- 查找相关信息
    local function findData()
        local playerId = getPlayerId()
        local tempInfo = self.mDataList[playerId]
        return tempInfo and tempInfo.BattleInfo
    end

    -- 先查找缓存中是否有相关信息
    local tempData = findData()
    if tempData then
        if callback then
            callback(tempData)
        end
        return tempData
    end

    if not callback then
        return
    end

    -- 获取玩家战役信息的服务器请求
    self:requestBattleInfo(true, false, function(response)
        local tempData = findData()
        if tempData then
            callback(tempData)
        end
    end)
end

-- 获取所有章节以及章节中的节点信息
--[[
-- 参数
    callback: 用于返回数据的回调函数，callback(ChapterList)
-- 返回值，返回值的数据格式参考 文件头处的 “副本数据说明” 中的 “章节列表” 部分
]]
function CacheBattle:getAllChapterInfo(callback)
    self:requestAllChapterInfo(function(response)
        local playerId = getPlayerId()
        local tempInfo = self.mDataList[playerId]
        callback(tempInfo.ChapterList)
    end)
end

-- 获取章节列表信息
--[[
-- 参数
    callback: 用于返回数据的回调函数，callback(ChapterList)
-- 返回值，返回值的数据格式参考 文件头处的 “副本数据说明” 中的 “章节列表” 部分
    如果缓存里有相关的信息，通过函数返回值和回调函数返回相关信息
    如果没有，则需要使用回调函数异步返回
]]
function CacheBattle:getChapterList(callback)
    -- 查找相关信息
    local function findData()
        local playerId = getPlayerId()
        local tempInfo = self.mDataList[playerId]
        return tempInfo and tempInfo.ChapterList
    end

    -- 先查找缓存中是否有相关信息
    local tempData = findData()
    if tempData then
        if callback then
            callback(tempData)
        end
        return tempData
    end

    if not callback then
        return
    end

    -- 获取玩家战役信息的服务器请求
    self:requestBattleInfo(false, true, function(response)
        local tempData = findData()
        callback(tempData)
    end)
end

-- 获取某个章节的节点列表
--[[
-- 参数
    chapterId: 章节Id
    callback: 用于返回数据的回调函数，callback(nodeList)
-- 返回值，返回值的数据格式参考 文件头处的 “副本数据说明” 中的 “节点列表 ” 部分
    如果缓存里有相关的信息，通过函数返回值和回调函数返回相关信息
    如果没有，则需要使用回调函数异步返回
]]
function CacheBattle:getNodeList(chapterId, callback)
    -- 查找相关信息
    local function findData()
        local playerId = getPlayerId()
        local tempInfo = self.mDataList[playerId]

        if tempInfo and tempInfo.ChapterList and self:checkNodeList(tempInfo.ChapterList[chapterId].NodeList) then
            return tempInfo.ChapterList[chapterId].NodeList
        end
    end

    -- 先查找缓存中是否有相关信息
    local tempData = findData()
    if tempData then
        if callback then
            callback(tempData)
        end
        return tempData
    end

    if not callback then
        return
    end

    self:requestAllChapterInfo(function(response)
        local tempData = findData()
        callback(tempData)
    end)
end

-- 获取某个章节的宝箱信息
--[[
-- 参数
    chapterId: 章节模型Id
    needStarBox: 是否需要星数宝箱
    needRoadBox: 是否需要路边宝箱
-- 返回值的格式参考 文件头处的 “章节宝箱信息说明”
    如果缓存里有相关的信息，通过函数返回值和回调函数返回相关信息
    如果没有，则需要使用回调函数异步返回
]]
function CacheBattle:getBoxData(chapterId, needStarBox, needRoadBox)
    local retData = {StarBox = {}, RoadBox = {}}

    local playerId = getPlayerId()
    local tempInfo = self.mDataList[playerId]
    local chapterData = tempInfo and tempInfo.ChapterList and tempInfo.ChapterList[chapterId]
    if not chapterData then
        return retData
    end

    local chapterModel = BattleChapterModel.items[chapterId]

    -- 需要获取星数宝箱信息
    if needStarBox then
        local tempList = {
            {
                statusName = "IfDrawBoxA",
                boxIdName = "boxAID",
                needStarName = "boxANeedStar",
            },
            {
                statusName = "IfDrawBoxB",
                boxIdName = "boxBID",
                needStarName = "boxBNeedStar",
            },
            {
                statusName = "IfDrawBoxC",
                boxIdName = "boxCID",
                needStarName = "boxCNeedStar",
            }
        }
        for index, item in ipairs(tempList) do
            if chapterModel[item.boxIdName] > 0 then
                table.insert(retData.StarBox, {
                    index = index,
                    boxType  = Enums.BattleBoxType.eStarBox,
                    ifDraw = chapterData[item.statusName],
                    boxId = chapterModel[item.boxIdName],
                    starCount = chapterData.StarCount,
                    needStar = chapterModel[item.needStarName],
                })
            end
        end
    end

    -- 需要获取路边宝箱信息
    if needRoadBox then
        -- 整理路上宝箱数据, 宝箱状态枚举在Enums.RewardStatus 中定义(0：不能领取，1：能够领取，2：已经领取)
        local tempList = {
            {
                statusName = "CanDrawRoadBoxA",
                boxIdName = "roadBoxAID",
                pointsName = "APoints",
            },
            {
                statusName = "CanDrawRoadBoxB",
                boxIdName = "roadBoxBID",
                pointsName = "BPoints",
            },
            {
                statusName = "CanDrawRoadBoxC",
                boxIdName = "roadBoxCID",
                pointsName = "CPoints",
            }
        }
        for index, item in ipairs(tempList) do
            if chapterModel[item.boxIdName] > 0 then
                table.insert(retData.RoadBox, {
                    index = index,
                    boxType  = Enums.BattleBoxType.eRoadBox,
                    status = chapterData[item.statusName],
                    boxId = chapterModel[item.boxIdName],
                    points = Utility.analysisPoints(chapterModel[item.pointsName]),
                })
            end
        end
    end

    return retData
end

-- 获取一个章节节点信息
--[[
-- 参数
    chapterId: 章节模型Id
    nodeId: 节点模型Id
]]
function CacheBattle:getNodeInfo(chapterId, nodeId)
    local playerId = getPlayerId()
    local tempInfo = self.mDataList[playerId]
    local nodeList = tempInfo and tempInfo.ChapterList and tempInfo.ChapterList[chapterId].NodeList
    return  nodeList and nodeList[nodeId]
end

-- 获取触发的bossId
function CacheBattle:getTriggerBossId()
    local playerId = getPlayerId()
    local triggerInfo = self.mDataList[playerId] and self.mDataList[playerId].TriggerInfo

    return triggerInfo and triggerInfo.BossId
end

-- 重置触发的BossId
function CacheBattle:clearTriggerBossId()
    local playerId = getPlayerId()
    local triggerInfo = self.mDataList[playerId] and self.mDataList[playerId].TriggerInfo
    if not triggerInfo then
        return
    end

    triggerInfo.BossId = nil
end

-- 获取新开章节模型Id
function CacheBattle:getTriggerNewChapterId()
    local playerId = getPlayerId()
    local triggerInfo = self.mDataList[playerId] and self.mDataList[playerId].TriggerInfo

    return triggerInfo and triggerInfo.NewChapterId
end

-- 重置新开章节模型Id
function CacheBattle:clearTriggerNewChapterId()
    local playerId = getPlayerId()
    local triggerInfo = self.mDataList[playerId] and self.mDataList[playerId].TriggerInfo
    if not triggerInfo then
        return
    end

    triggerInfo.NewChapterId = nil
end

-- 通过Avatar信息改变章节信息
function CacheBattle:insertChapterInfo(chapterInfo)
    local chapterModelId = chapterInfo and chapterInfo.ChapterModelId
    if not chapterModelId then
        return
    end

    local playerId = getPlayerId()
    self.mDataList[playerId] = self.mDataList[playerId] or {}
    local battleInfo = self.mDataList[playerId].BattleInfo
    if not battleInfo then
        --还未获取过副本信息，不需要插入
        return
    end

    -- 更新开启的最大章节模型Id
    battleInfo.MaxChapterId = math.max(battleInfo.MaxChapterId, chapterModelId)

    -- 更新 “战役信息 BattleInfo” 中的 “MaxNodeId” 字段
    local nextNodeId = self.mAllNodeIdList[chapterModelId] and self.mAllNodeIdList[chapterModelId][1]
    if nextNodeId then
        battleInfo.MaxNodeId = math.max(battleInfo.MaxNodeId, nextNodeId)
    end

    -- 通知章节信息改变
    Notification:postNotification(EventsName.eBattleChapterPrefix .. tostring(chapterInfo.ChapterModelId))
end

-- 获取当前正在挑战普通副本节点的模型Id
function CacheBattle:getFightNodeModelId()
    return self.mCurrFightNodeModelId
end

-- ================================== 与缓存数据相关的网络请求 =======================

-- 获取玩家战役信息的服务器请求
--[[
-- 参数
    needBattleInfo: 是否需要战役信息
    needChapterInfo: 是否需要章节列表信息
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestBattleInfo(needBattleInfo, needChapterInfo, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "GetBattleInfo",
        svrMethodData = {needBattleInfo and true or false, needChapterInfo and true or false},
        callback = function(response)
            if response and response.Status == 0 then
                local value = response.Value
                -- 更新缓存数据
                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                -- 战役信息
                if value.BattleInfo then
                    self.mDataList[playerId].BattleInfo = value.BattleInfo
                end
                -- 章节列表信息
                if value.ChapterList then
                    self.mDataList[playerId].ChapterList = self.mDataList[playerId].ChapterList or {}
                    local chapterList = self.mDataList[playerId].ChapterList
                    for _, item in pairs(value.ChapterList) do
                        chapterList[item.ChapterModelId] = chapterList[item.ChapterModelId] or {}
                        for key, value in pairs(item) do
                            if key ~= "NodeList" then
                                chapterList[item.ChapterModelId][key] = value
                            end
                        end

                        -- 通知章节信息改变
                        Notification:postNotification(EventsName.eBattleChapterPrefix .. tostring(item.ChapterModelId))
                    end
                end
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 获取节点列表的服务器请求
--[[
-- 参数
    chapterId: 章节Id
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requesttNodeList(chapterId, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "GetNodeList",
        svrMethodData = {chapterId},
        callback = function(response)
            if response and response.Status == 0 then
                local value = response.Value
                -- 更新缓存数据
                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                self.mDataList[playerId].ChapterList = self.mDataList[playerId].ChapterList or {}
                local chapterList = self.mDataList[playerId].ChapterList
                chapterList[chapterId] = chapterList[chapterId] or {}
                -- 记录获取该章节信息的时间，用于校验是否需要重新获取节点数据
                chapterList[chapterId].TimeTick = response.TimeTick
                --
                chapterList[chapterId].NodeList = chapterList[chapterId].NodeList or {}
                for _, item in pairs(response.Value) do
                    chapterList[chapterId].NodeList[item.NodeModelId] = item

                    -- 通知节点信息改变
                    Notification:postNotification(EventsName.eBattleNodePrefix .. tostring(item.NodeModelId))
                end
                -- 通知节点信息改变
                Notification:postNotification(EventsName.eBattleNodePrefix)
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 获取全部开通的章节信息
--[[
-- 参数
    callback: 回调函数，获取成功后调用 callback(response)
    chapterIdList: 需要获取信息的章节Id列表, 如果为nil，则获取所有的章节信息
]]
function CacheBattle:requestAllChapterInfo(callback, chapterIdList)
    local playerId = getPlayerId()
    self.mDataList[playerId] = self.mDataList[playerId] or {}
    self.mDataList[playerId].NodeInfo = self.mDataList[playerId].NodeInfo or {}

    self:getBattleInfo(function(battleInfo)
        -- 当前服务器的时间
        local currTime = Player:getCurrentTime()
        local IdList = {}
        local oldChapterList = self.mDataList[playerId].ChapterList or {}
        if chapterIdList then
            for _, chapterId in pairs(chapterIdList) do
                if chapterId <= battleInfo.MaxChapterId then
                    local oldChapter = oldChapterList[chapterId]
                    if not self:checkChapterTimeOut(oldChapter, battleInfo) then
                        table.insert(IdList, chapterId)
                    end
                end
            end
        else
            for chapterId, item in pairs(BattleChapterModel.items) do
                if chapterId <= battleInfo.MaxChapterId then
                    local oldChapter = oldChapterList[chapterId]
                    if not self:checkChapterTimeOut(oldChapter, battleInfo) then
                        table.insert(IdList, chapterId)
                    end
                end
            end
        end

        if #IdList == 0 then
            if callback then
                callback({Status = 0})
            end
            return
        end

        HttpClient:request({
            svrType = HttpSvrType.eGame,
            moduleName = "Battle",
            methodName = "AllChapterInfo",
            svrMethodData = {IdList},
            callback = function(response)
                if response and response.Status == 0 then
                    local value = response.Value
                    -- 更新缓存数据
                    self.mDataList[playerId].ChapterList = self.mDataList[playerId].ChapterList or {}
                    local chapterList = self.mDataList[playerId].ChapterList
                    for _, chapterItem  in pairs(response.Value) do
                        chapterList[chapterItem.ChapterModelId] = {}
                        -- 记录获取该章节信息的时间，用于校验是否需要重新获取节点数据
                        chapterList[chapterItem.ChapterModelId].TimeTick = response.TimeTick
                        for key, value in pairs(chapterItem) do
                            if key ~= "NodeList" then
                                chapterList[chapterItem.ChapterModelId][key] = value
                            end
                        end
                        chapterList[chapterItem.ChapterModelId].NodeList = {}
                        local nodeList = chapterList[chapterItem.ChapterModelId].NodeList
                        for _, nodeItem in pairs(chapterItem.NodeList) do
                            nodeList[nodeItem.NodeModelId] = nodeItem
                        end

                        -- 通知章节信息改变
                        Notification:postNotification(EventsName.eBattleChapterPrefix .. tostring(chapterItem.ChapterModelId))
                    end
                    -- 通知章节信息改变
                    Notification:postNotification(EventsName.eBattleChapterPrefix)
                end

                -- 回调通知调用者
                if callback then
                    callback(response)
                end
            end,
        })
    end)
end

-- 领取章节的宝箱 数据请求
--[[
-- 参数
    chapterId: 章节模型Id
    boxId: 宝箱id
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestDrawBox(chapterId, boxId, callback)
    HttpClient:request({
        svrType       = HttpSvrType.eGame,
        moduleName    = "Battle",
        methodName    = "DrawBox",
        guideInfo     = Guide.helper:tryGetGuideSaveInfo(137),
        svrMethodData = {chapterId, boxId},
        callback      = function(response)
            if response and response.Status == 0 then
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 137 then
                    Guide.manager:removeGuideLayer()
                    Guide.manager:nextStep(eventID)
                end

                -- 更新缓存数据
                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                local tempData = self.mDataList[playerId].ChapterList[chapterId]
                for key, value in pairs(response.Value.Chapter) do
                    tempData[key] = value
                end

                -- 通知章节信息改变
                Notification:postNotification(EventsName.eBattleChapterPrefix .. tostring(chapterId))
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 领取章节的地下宝箱数据请求
--[[
-- 参数
    chapterId: 章节模型Id
    boxId: 地下宝箱id
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestDrawRoadBox(chapterId, boxId, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "DrawRoadBox",
        guideInfo = nil,
        svrMethodData = {chapterId, boxId},
        callback = function(response)
            if response and response.Status == 0 then

                local value = response.Value
                -- 更新缓存数据
                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                local tempData = self.mDataList[playerId].ChapterList[chapterId]
                for Key, value in pairs(value.Chapter) do
                    tempData[Key] = value
                end

                -- 通知章节信息改变
                Notification:postNotification(EventsName.eBattleChapterPrefix .. tostring(chapterId))
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 一键领取章节宝箱数据请求
--[[
-- 参数
    chapterIdList: 章节模型Id
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestOneKeyDrawBoxs(chapterIdList, callback)
    -- local boxData = self:getBoxData(chapterId, true, true)
    --dump(boxData, "boxData:")
    -- local svrBoxInfo = {}
    -- -- 星级宝箱
    -- for _, item in pairs(boxData.StarBox) do
    --     if not item.ifDraw and item.starCount >= item.needStar then
    --         svrBoxInfo["1"] = svrBoxInfo["1"] or {}
    --         table.insert(svrBoxInfo["1"], item.boxId)
    --     end
    -- end
    -- -- 路边宝箱
    -- for _, item in pairs(boxData.RoadBox) do
    --     if item.status == Enums.RewardStatus.eAllowDraw then
    --         svrBoxInfo["2"] = svrBoxInfo["2"] or {}
    --         table.insert(svrBoxInfo["2"], item.boxId)
    --     end
    -- end

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "OneKeyDrawBoxs",
        svrMethodData = {chapterIdList},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}

                for _, chapterId in pairs(chapterIdList) do
                    local tempData = self.mDataList[playerId].ChapterList[chapterId]
                    local tempChapterInfo = {}
                    for Key, value in pairs(response.Value.ChapterList) do
                        if chapterId == value.ChapterModelId then
                            tempChapterInfo = value
                            break
                        end
                    end
                    for index, item in pairs(tempChapterInfo) do
                        tempData[index] = item
                    end

                    -- 通知章节信息改变
                    Notification:postNotification(EventsName.eBattleChapterPrefix .. tostring(chapterId))
                end
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 获取战斗前数据信息请求
--[[
    chapterId: 章节模型Id
    nodeId: 节点模型Id
    starLv:节点星数难度
    guideInfo: 引导信息
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestFightInfo(chapterId, nodeId, starLv, guideInfo, recordData, callback)
    print("chapterId, nodeId, starLv:", chapterId, nodeId, starLv)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "GetFightInfo",
        guideInfo  = recordData,
        svrMethodData = {chapterId, nodeId, starLv},
        callback = function(response)
            -- 回调通知调用者
            if callback then
                callback(response)
            end
            if not response or response.Status ~= 0 then
                return
            end

            -- 进入战斗页面
            local value = response.Value
            -- 战斗节点信息
            local nodeInfo = self:getNodeInfo(chapterId, nodeId)
            -- 战斗数据
            local fightData, guideSkipData
            -- 第一次挑战该节点
            if nodeInfo.Flag == 1 then
                local guideType = BattleNodeModel.items[nodeId].guideType
                -- 1: 全剧情;  2:半剧情
                if guideType == 1 or guideType == 2 then
                    local modelFile = string.format("ComBattle.BattleGuideConfig.BattleScript%d", nodeId)
                    local tempStr = string.format("ComBattle/BattleGuideConfig/BattleScript%d", nodeId)
                    if Utility.isFileExist(tempStr..".lua") or Utility.isFileExist(tempStr..".luac") then
                        fightData = require(modelFile) or value.FightInfo
                        guideSkipData = {
                            viewable = true,
                            clickable = function()
                                return true
                            end,
                            executable = function()
                                return true
                            end
                        }
                    else
                        fightData = value.FightInfo
                    end
                else
                    fightData = value.FightInfo
                end
            else
                fightData = value.FightInfo
            end

            -- 调用战斗页面
            local function callBattleLayer()
                self.mCurrFightNodeModelId = nodeId
                -- 战斗控制参数
                local controlParams = Utility.getBattleControl(ModuleSub.eBattleNormal, nodeInfo.StarCount >= starLv)
                LayerManager.addLayer({
                    name = "ComBattle.BattleLayer",
                    data = {
                        data = fightData,
                        skip = guideSkipData or controlParams.skip,
                        trustee = controlParams.trustee,
                        map = Utility.getBattleBgFile(ModuleSub.eBattleNormal, {fightNodeId = nodeId}),
                        callback = function(ret)
                            --dump(ret, "CacheBattle:requestFightInfo fight result:")
                            CheckPve.battleNormal(chapterId, nodeId, starLv, ret, guideInfo)

                            -- 战斗跳过时，打点
                            if PlayerAttrObj:getPlayerAttrByName("Lv") < 9 then
                                HttpClient:hitPoint(self.mCurrFightNodeModelId + 100000, ret.isskip and 1 or 0)
                            end
                            self.mCurrFightNodeModelId = nil

                            -- 缓存托管状态
                            if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                                controlParams.trustee.changeTrusteeState(ret.trustee)
                            end
                        end
                    }
                })
            end

            local guideID, ordinal, eventID = Guide.manager:getGuideInfoByType(GuideTriggerType.eBattleNodeOrdinalStar, nodeId)
            if eventID then
                -- 有战斗前引导，先进行引导再进入战斗
                Guide.manager:showBeforeBattleGuide(nodeId, function()
                    callBattleLayer()
                end)
            else
                callBattleLayer()
            end
        end,
    })
end

-- 挑战节点数据请求(战斗完成后，向服务器获取战斗结果和产出掉落)
--[[
-- 参数
    chapterId: 章节模型Id
    nodeId: 节点模型Id
    starLv: 节点星数难度
    fightResult: 战斗结果
    fightStr: 战斗过程产生的操作数据
    isJump: 是否跳过战斗
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestFight(chapterId, nodeId, starLv, fightResult, fightStr, isJump, guideInfo, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "Fight",
        guideInfo = guideInfo,
        svrMethodData = {chapterId, nodeId, starLv, fightResult, fightStr or "", isJump},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local value = response.Value
                self:dealFightData(chapterId, nodeId, value)
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 挑战节点数据请求(托管，直接返回战斗结果)
--[[
-- 参数
    chapterId: 章节模型Id
    nodeId: 节点模型Id
    starLv: 节点星数难度
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestHiAutoFight(chapterId, nodeId, starLv, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "HiAutoFight",
        svrMethodData = {chapterId, nodeId, starLv},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local value = response.Value
                self:dealFightData(chapterId, nodeId, value)
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end

            -- 检查是否升级 Todo: 好的方式是调用者在适当的时候检查升级
            PlayerAttrObj:showUpdateLayer()
        end,
    })
end

-- 连战节点数据请求
--[[
-- 参数
    chapterId: 章节模型Id
    nodeId: 节点模型Id
    starLv: 节点星数难度
    conCount: 连战次数
    useType: 消耗资源类型，在Enums.BattleFightUse 中定义 2(道具)，3(元宝)
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestConFight(chapterId, nodeId, starLv, conCount, useType, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "ConFight",
        svrMethodData = {chapterId, nodeId, starLv, conCount, useType},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local value = response.Value

                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                if value.BattleInfo then
                    self.mDataList[playerId].BattleInfo = value.BattleInfo
                    -- 通知战役信息改变
                    Notification:postNotification(EventsName.eBattleInfo)
                end

                -- 是否需要在这里处理触发的boss（BossId）？？？？

                -- 应该还会改变该节点的信息，
                local nodeInfo = self.mDataList[playerId].ChapterList[chapterId].NodeList[nodeId]
                nodeInfo.FightCount = nodeInfo.FightCount + conCount

                -- 通知该节点信息已经改变
                Notification:postNotification(EventsName.eBattleNodePrefix .. tostring(nodeId))
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- 重置节点挑战次数 数据请求
--[[
-- 参数
    chapterId: 章节模型Id
    nodeId: 节点模型Id
    useType: 消耗资源类型，在Enums.BattleFightUse 中定义 2(道具)，3(元宝)
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestResetCount(chapterId, nodeId, useType, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Battle",
        methodName = "ResetCount",
        svrMethodData = {chapterId, nodeId, useType},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local playerId = getPlayerId()
                local nodeInfo = self.mDataList[playerId].ChapterList[chapterId].NodeList
                nodeInfo[nodeId] = nodeInfo[nodeId] or {}
                local tempNode = nodeInfo[nodeId]
                for key, value in pairs(response.Value) do
                    tempNode[key] = value
                end

                -- 通知该节点信息已经改变
                Notification:postNotification(EventsName.eBattleNodePrefix .. tostring(nodeId))
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

-- ======================== 精英副本与缓存数据相关的网络请求 =========================
-- 挑战精英副本节点数据请求(战斗完成后，向服务器获取战斗结果和产出掉落)
--[[
-- 参数
    nodeId: 节点模型Id
    fightResult: 战斗结果
    fightStr: 战斗过程产生的操作数据
    isJump: 是否跳过战斗
    callback: 回调函数，获取成功后调用 callback(response)
]]
function CacheBattle:requestEliteFight(nodeId, fightResult, fightStr, isJump, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Elitebattle",
        methodName = "Fight",
        svrMethodData = {nodeId, fightResult, fightStr, isJump},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local value = response.Value

                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                self.mDataList[playerId].TriggerInfo = self.mDataList[playerId].TriggerInfo or {}
                local triggerInfo = self.mDataList[playerId].TriggerInfo
                triggerInfo.BossId = value.BossId  -- 触发boss
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end
    })
end

-- 扫荡精英副本节点数据请求
--[[
-- 参数
    nodeId: 节点ID
    callback: 扫荡完成后回调函数
]]
function CacheBattle:requestEliteSweep(nodeId, count, callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Elitebattle",
        methodName = "OnekeySweep",
        svrMethodData = {nodeId, count},
        callback = function(response)
            if response and response.Status == 0 then
                -- 更新缓存数据
                local value = response.Value

                local playerId = getPlayerId()
                self.mDataList[playerId] = self.mDataList[playerId] or {}
                self.mDataList[playerId].TriggerInfo = self.mDataList[playerId].TriggerInfo or {}
                local triggerInfo = self.mDataList[playerId].TriggerInfo
                triggerInfo.BossId = value.BossId  -- 触发boss
            end

            -- 回调通知调用者
            if callback then
                callback(response)
            end
        end,
    })
end

return CacheBattle
