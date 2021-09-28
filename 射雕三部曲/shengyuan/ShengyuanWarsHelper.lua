--[[
    文件名：ShengyuanWarsHelper.lua
    描述：圣渊大陆Helper（单例）
    创建人：peiyaoqiang
    创建时间：2016.10.9
    修改人: singoon
    修改时间: 2016.10.11
-- ]]
ShengyuanWarsHelper = {
    socketMgr = nil,
    url = nil,              -- 服务器URL
    heartTick = 0,          -- 心跳计时

    myTeamName = nil,       -- 我所在的阵营
    playerList = {},        -- 队员（飞行器）信息列表, 血量百分比(HPRate)
    AResScore = 0,          -- A阵营资源点
    BResScore = 0,          -- B阵营资源点
    APoLingCount = 0,       -- A阵营五毒散数量
    BPoLingCount = 0,       -- B阵营五毒散数量
    calcResScoreTime = ShengyuanwarsConfig.items[1].pointsOutputTime,  -- 资源点刷新倒计时
    buffRemainTime = ShengyuanwarsBuffModel.items[1].refreshTime,      -- 神符刷新倒计时
    battleProtectTime = 0,  -- 战斗保护时间
    enterProtectTime = 0,   -- 进入据点禁止退出时间
    chatCache = {},         -- 聊天消息列表
    reportList = {},        -- 战绩列表
    rebirthTime = 0,        -- 复活倒计时
    battleResultData = nil, -- 战场结束数据

    -- 资源点列表
    allResList = {},
    -- 当前资源点
    enterResInfo = {},
    -- 当前队伍信息
    myTeamInfo = {},

    -- 玩家拥有的法器列表
    mountList = {},
    currMountModelId = 24010001,
    maxMountModelId = 24010001,
    currMountLv = 1,

    shengyuanTeamState = 0,   -- 0.初始状态 1.组队中 2.匹配中 3.战场中
    shengyuanLeaderId = EMPTY_ENTITY_ID,     -- 队长ID，初始为EMPTY_ENTITY_ID
}

-- 服务器确定阵营名
ShengyuanWarsHelper.teamA = "A"
ShengyuanWarsHelper.teamB = "B"
-- 技能时间，便于和服务器端配合测试(0表示正常状态)
ShengyuanWarsHelper.testTime = 0

ShengyuanWarsHelper.enumAerocraftType = {
    myself = 0,         -- 自己
    teammate = 1,       -- 队友
    enemy = 2,          -- 敌人
}

-- ShengyuanWarsHelper事件集合
ShengyuanWarsHelper.Events = {
    eShengyuanWarsEnterBattle = "eShengyuanWarsEnterBattle",                -- 进入战场通知
    eShengyuanWarsScoreChanged = "eShengyuanWarsScoreChanged",              -- 玩家资源点数变化
    eShengyuanWarsPoLingChanged = "eShengyuanWarsPoLingChanged",            -- 战场五毒散数量变化
    eShengyuanWarsResBuffChanged = "eShengyuanWarsResBuffChanged",          -- 资源点内神符刷新
    eShengyuanWarsPosTargetChanged = "eShengyuanWarsPosTargetChanged",      -- 某玩家的位置变化
    eShengyuanWarsPlayerBuffChanged = "eShengyuanWarsPlayerBuffChanged",    -- 某玩家的BUFF变化
    eShengyuanWarsResInfo = "eShengyuanWarsResInfo",                        -- 资源点状态变化
    eShengyuanWarsEnterOrQuiteRes = "eShengyuanWarsEnterOrQuiteRes",        -- 某玩家进入或退出了资源点
    eShengyuanWarsFightOver = "eShengyuanWarsFightOver",                    -- 通知战斗结束及结果
    eShengyuanWarsChatInfo = "eShengyuanWarsChatInfo",                      -- 聊天消息
    eShengyuanWarsPlayerChatInfo = "eShengyuanWarsPlayerChatInfo",          -- 玩家聊天消息
    eShengyuanWarsFightResult = "eShengyuanWarsFightResult",                -- 战场结束
    eShengyuanWarsCancelTeam = "eShengyuanWarsCancelTeam",                  -- 某玩家取消了组队
    eShengyuanWarsSkillUpdatePre = "eShengyuanWarsSkillUpdatePre",          -- 天阶岛绝技技能更新通知
    eShengyuanWarsSkillReleasePre = "eShengyuanWarsSkillReleasePre",        -- 天阶岛绝技技能释放通知
    eShengyuanWarsSkillBeReleasePre = "eShengyuanWarsSkillBeReleasePre",    -- 天阶岛绝技被释放技能通知
}

-- 进入比赛
function ShengyuanWarsHelper:connect(callFunc, faildFunc)
    if (self.url == nil) then
        return
    end
    self.heartTick = Player.mTimeTick

    -- 防止重复连接
    if (self.socketMgr ~= nil) then
        if callFunc then
            callFunc()
        end
        return
    end

    -- 创建连接对象
    self.socketMgr = require("network.SocketClient"):create({
        serverUrl = self.url,
        recvCallback = function(response)
            self:dealRecvData(response)
            callFunc(response)
        end,
        connChangeCb = function(msgType)
            if msgType == SocketClient.MSG_TYPE_SOCKET_CLOSE then
                -- 断开网络连接
                self:leave()
            end
        end,
    })

    -- 开启心跳倒计时
    self.heartSheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
        if self.socketMgr and self.socketMgr:isConnected() then
            -- 检查是否需要发送心跳包
            if (Player.mTimeTick - self.heartTick) > 30 then
                self.socketMgr:sendMessage({ModuleName = "Player", MethodName = "Beat", Parameters = {}})
                self.heartTick = Player.mTimeTick
            end
        end
    end, 1, false)
end

-- 处理消息
function ShengyuanWarsHelper:dealRecvData(response)
    if response.Code == 0 then
        if type(response.Data) == "userdata" then
            return
        end

        if response.Data and response.Data.InfoName then
            --dump(response, "dealRecvData")
            local infoName = response.Data.InfoName
            if infoName == "BattleInfo" then
                self:battleInfoCallback(response.Data)
            elseif infoName == "RefreshInfo" then
                self:scoreChangedCallback(response.Data)
            elseif infoName == "MoveInfo" then
                self:moveInfoCallback(response.Data)
            elseif infoName == "ResPointStatus" then
                self:resPointStatusCallback(response.Data)
            elseif infoName == "PlayerEnterOrQuite" then
                self:playerEnterOrQuiteCallback(response.Data)
            elseif infoName == "ChatInfo" then
                self:chatInfoCallback(response.Data)
            elseif infoName == "LoginAgainInfo" then
                self:loginAgainInfoCallback(response.Data)
            elseif infoName == "FightInfo" then
                self:fightInfoCallback(response.Data)
            elseif infoName == "ResInfo" then
                self:resPointInfoCallback(response.Data)
            elseif infoName == "BattleResult" then
                self:fightResultCallback(response.Data)
            elseif infoName == "CancelTeam" then
                self:cancelTeamCallback(response.Data)
            elseif infoName == "ResourceOutputInfo" then
                self:resOutputCallback(response.Data)
            elseif infoName == "SkillEffect" then
                self:skillEffectCallback(response.Data)
            elseif infoName == "SocketDisconnect" then
                MsgBoxLayer.addOKLayer(
                    TR("服务器连接已断开，点击确定重新进入"),
                    TR("提示"),
                    {
                        text = TR("确定"),
                        clickAction = function()
                            self:leave()    -- 断网后，重置定时器，socket
                            LayerManager.addLayer({
                                name = "challenge.ChallengeLayer",
                                data = {autoOpenModule = ModuleSub.eShengyuanWars}
                            })
                        end
                    },
                    nil,
                    false
                )
            end
        end
    else
        --提示错误信息
        if response.Code ~= -8811 then
            ui.showFlashView(SocketStates.errorCode[response.Code])
        end
        if response.Code == -8818 then
            -- 神符不存在，清空当前神符
            local tempData = clone(self.enterResInfo)
            tempData.BuffNum = 0
            tempData.Status = 2
            self:resPointInfoCallback({Info = tempData})
            -- 对应据点的神符状态
            for i,v in ipairs(self.allResList) do
                if v.PointId == tempData.PointId then
                    v.Status = tempData.Status
                    break
                end
            end
        end
    end
end

function ShengyuanWarsHelper:scheduleTime()
    if not self.socketSheduler then
        -- 创建定时器
        self.socketSheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
        if self.socketMgr and self.socketMgr:isConnected() and self.myTeamName then
            -- 资源点刷新倒计时
            if self.calcResScoreTime > 0 then
                self.calcResScoreTime = self.calcResScoreTime - 1
            end
            -- 神符刷新倒计时
            if self.buffRemainTime > 0 then
                self.buffRemainTime = self.buffRemainTime - 1
            end
            -- 计算复活剩余时间
            if self.rebirthTime > 0 then
                self.rebirthTime = self.rebirthTime - 1
            end
            -- 战斗保护时间
            if self.battleProtectTime > 0 then
                self.battleProtectTime = self.battleProtectTime - 1
            end
            -- 进入据点禁止退出时间
            if self.enterProtectTime > 0 then
                self.enterProtectTime = self.enterProtectTime - 1
            end
            -- 占领倒计时
            if self.enterResInfo.Time and self.enterResInfo.Time > 0  then
                self.enterResInfo.Time = self.enterResInfo.Time - 1
            end
            -- 所有玩家的位置移动(仅处于移动状态时)
            for _,v in ipairs(self.playerList) do
                if v.Status == 2 then
                    local stepX = v.TargetPos[1] - v.CurPos[1]
                    local stepY = v.TargetPos[2] - v.CurPos[2]
                    local distance = math.sqrt(math.pow(stepX, 2) + math.pow(stepY, 2))
                    if distance < 10 then  -- 快要到达目标时，重设位置(防止永远到不了目标整数位置)
                        v.CurPos[1] = v.TargetPos[1]
                        v.CurPos[2] = v.TargetPos[2]
                    elseif distance > 0 then
                        local speedPerSecond = v.Speed
                        if stepX ~= 0 then
                            v.CurPos[1] = v.CurPos[1] + (speedPerSecond * stepX) / distance
                        end
                        if stepY ~= 0 then
                            v.CurPos[2] = v.CurPos[2] + (speedPerSecond * stepY) / distance
                        end
                    end
                end
                -- 玩家状态消失倒计时
                if v.Buff and next(v.Buff) then
                    local index = 1
                    for buffId,time in pairs(v.Buff) do
                        if time > 0 then
                            v.Buff[buffId] = time - 1
                        elseif time == 0 then
                            v.Buff[buffId] = nil
                            -- 通知玩家状态消失
                            Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPlayerBuffChanged, v.PlayerId)
                        end
                        index = index + 1
                    end
                end
                
                -- 更新技能缓存池[主动] [被动不执行时间减少操作一直存在]
                if v.ReceiveActiveSkillInfo ~= nil then
                    local isNotiUpdate = false
                    for k = #v.ReceiveActiveSkillInfo, 1, -1 do 
                        local tValue = v.ReceiveActiveSkillInfo[k]
                        if tValue.ValidTime - 1 >= 0 then 
                            v.ReceiveActiveSkillInfo[k].ValidTime = v.ReceiveActiveSkillInfo[k].ValidTime - 1
                        else
                            --变更本地飞机属性
                            table.remove(v.ReceiveActiveSkillInfo, k)
                            local tempSpeed = self:removeBuffFromLocalPlayerInfo(tValue.SkillId,v.PlayerId)
                            --dump(TR("本地计算速度值:%f",tempSpeed))
                            isNotiUpdate = true
                        end  
                    end  
                    if isNotiUpdate then
                       --通知更新技能
                       Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsSkillUpdatePre .. v.PlayerId)
                    end
                end

                -- 玩家自身主动技能CD
                if v.ActiveSkillsInfo ~= nil then
                    for k = #v.ActiveSkillsInfo, 1, -1 do 
                        local tValue = v.ActiveSkillsInfo[k]
                        if tValue.ValidTime - 1 >= 0 then 
                            v.ActiveSkillsInfo[k].ValidTime = v.ActiveSkillsInfo[k].ValidTime - 1
                        else
                            v.ActiveSkillsInfo[k].ValidTime = 0 --不执行删除操作
                        end  

                        if tValue.CdTime - 1 >= 0 then 
                            v.ActiveSkillsInfo[k].CdTime = v.ActiveSkillsInfo[k].CdTime - 1
                        else
                            v.ActiveSkillsInfo[k].CdTime = 0 --不执行删除操作
                        end  
                    end 
                end
            end
        end
        end, 1, false)
    end
end

-- 离开比赛
function ShengyuanWarsHelper:leave()
    -- 销毁定时器
    if self.heartSheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.heartSheduler)
        self.heartSheduler = nil
    end
    if self.socketSheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.socketSheduler)
        self.socketSheduler = nil
    end
    if (self.socketMgr ~= nil) then
        -- 关闭socket，删除断线回调
        self.socketMgr:destroy()
        self.socketMgr = nil
    end
end

function ShengyuanWarsHelper:resetCache()
    -- 清空缓存数据
    self.url = nil
    self.myTeamName = nil
    self.playerList = {}
    self.myTeamInfo = {}
    self.AResScore = 0
    self.BResScore = 0
    self.APoLingCount = 0
    self.BPoLingCount = 0
    self.calcResScoreTime = ShengyuanwarsConfig.items[1].pointsOutputTime
    self.buffRemainTime = ShengyuanwarsBuffModel.items[1].refreshTime
    self.battleProtectTime = 0
    self.enterProtectTime = 0
    self.chatCache = {}
    self.reportList = {}
    self.rebirthTime = 0
    self.battleResultData = nil
    self.allResList = {}
    self.enterResInfo = {}
    self.mountList = {}
    self.currMountModelId = 24010001
    self.maxMountModelId = 24010001
    self.currMountLv = 1
    self.currMountSkillInfo = {}
end

-- 战场结束，界面关闭时调用此方法，防止数据出错时不断显示战场结算
function ShengyuanWarsHelper:clearUpBattleResult()
    self.battleResultData = nil
end

--[[---------------------------------解析服务端返回的数据---------------------------------------]]

-- 推送类型:首次登陆,推送整个战场的初始信息
--[[
    {
    "InfoName":"BattleInfo",
    "Info '类型:([]map[string]interface{})'":
        [
            {
            "Name": "玩家名称" (sting),
            "PlayerId": "玩家id" (string),
            "MountModelId": "法宝id" (int),
            "TeamName": "玩家阵营" (string),
            "BornPoint": "出生点id" (int),
            "MountModelLevel": "法宝等级 (level)",

        ]
    "BattlePointInfo '所有点道具详情 (map[string]interface)'":
        [
            {
                "PointId": "资源点id (int)",
                "BuffId": "当前产生的道具id (int)",
                "BuffNum": "当前产生的道具个数 (int)"
            }
        ]
    }
--]]
function ShengyuanWarsHelper:battleInfoCallback(data)
    -- 清空缓存
    self:resetCache()
    -- dump(data, "battleInfoCallback")
    self.battleResultData = nil
    self:splitAllPlayerData(data.Info)
    -- 初始化资源点状态
    self.allResList = data.BattlePointInfo
    -- 获取初始五毒散数量
    for i,v in ipairs(self.allResList) do
        if v.PointId == 1 then
            self.APoLingCount = v.BuffNum
        elseif v.PointId == 7 then
            self.BPoLingCount = v.BuffNum
        end
    end
    -- 开启定时器
    self:scheduleTime()

    -- 通知进入战场页面
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsEnterBattle)
    self:autoMatchedNotify()
end

-- 推送类型:玩家二次登陆后,向玩家推送战场中的所有信息
--[[
    {
    "InfoName":"LoginAgainInfo",
    "Info":
        {
        "ChatInfo '所有玩家聊天的信息 类型:[]map[string]interface{}'":
            [
                {
                "Type":"消息类型 (int'1、聊天消息类型; 2、资源状态类型')",
                "PointId":"资源点id (int)",
                "PlayerId":"玩家id (string)",
                "PlayerName":"玩家名称 (string)",
                "Status":"资源点状态 (int'1、正在占领;2、被占领;3、防守住')"
                },
                {
                "Type":"消息类型 (int'1:聊天消息类型;2:资源状态类型')",
                "Name":"发言玩家名称 (sting)",
                "Content":"发言内容 (string)"
                }
            ],
        "AllPlayerInfo '所有玩家的信息 类型:[]map[string]interface{}'":
            [
                {
                    "PlayerId":"玩家id (string)",
                    "MountModelId":"法宝id (int)",
                    "PlayerName":"玩家名称 (string)",
                    "TeamName": "玩家阵营",
                    "Status":"玩家状态 (int '1:在资源点内; 2:移动中; 3:资源点上')",
                    "CurPos":"当前坐标点 ([2]int)",
                    "CurPointId": "玩家当前所在出入点id",
                    "TargetPos":"目标坐标点 ([2]int)",
                    "BornPoint":"出生点id (int)",
                    "MountModelLevel": "法宝等级 (level)",
                    "ProtectTime":"玩家战斗保护时间 (int)",
                    "EnterProtectTime":"玩家进入据点保护时间 (int)",
                    "Hp": "玩家当前血量 (int)"
                    "TotalHp": "玩家总血量 (int)"
                    "Buff": "道具信息 (map[string]int) key:道具id  value:倒计时"
                }
            ],
        "ResInfo '资源点的道具详情 类型:[]map[string]interface{}'":
            [
                {
                    "PointId":"资源点id (int)",
                    "BuffId": "道具id (int)",
                    "BuffNum": "道具数量 (int)"
                    "Time":"倒计时 (int 单位:秒)"
                    "TeamName":"哪个阵营正在操作该资源点 (string)"
                }
            ]
        "OutPutPointNum 'A,B阵营的资源点产出数量,道具刷新倒计时,资源产出倒计时 类型: map[string]interface{}'":
            {
                "A": "阵营A拥有的资源产出数 (int)",
                "B": "阵营B拥有的资源产出数 (int)",
                "RuneTime": "神符刷新倒计时 (int 单位：秒)",
                "OutputTime": "资源产出倒计时 (int 单位： 秒)"
            },
        }
    }
--]]
function ShengyuanWarsHelper:loginAgainInfoCallback(data)
    -- 清空缓存
    self:resetCache()
    -- dump(data, "loginAgainInfoCallback")
    self.battleResultData = nil
    local dataInfo = data.Info
    self:splitAllPlayerData(dataInfo.AllPlayerInfo)
    -- 当前资源点信息，如存在
    self.allResList = dataInfo.ResInfo
    -- 获取初始五毒散数量
    for i,v in ipairs(self.allResList) do
        if v.PointId == 1 then
            self.APoLingCount = v.BuffNum
        elseif v.PointId == 7 then
            self.BPoLingCount = v.BuffNum
        end
    end
    -- 当前是否在资源点内
    for i,v in ipairs(self.playerList) do
        -- 在资源点内且在相同资源点
        if v.Status == 1 and v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            for _, res in ipairs(self.allResList) do
                if res.PointId == v.CurPointId then
                    self.enterResInfo = clone(res)
                    break
                end
            end
            break
        end
    end

    local pointNum = data.Info.OutPutPointNum
    self.calcResScoreTime = pointNum.OutputTime  -- 资源点刷新倒计时
    self.buffRemainTime = pointNum.RuneTime     -- 神符刷新倒计时
    -- 刷新资源点数量
    self:setResScoreChanged(pointNum)

    -- 开启定时器
    self:scheduleTime()
    -- 通知进入战场页面
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsEnterBattle)
    self:autoMatchedNotify()

    -- 通知聊天消息变化
    if data.Info.ChatInfo then
        for i,v in ipairs(data.Info.ChatInfo) do
            self:addNewChatInfo(v)
        end
        Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsChatInfo)
    end
end

function ShengyuanWarsHelper:autoMatchedNotify()
    local topName = LayerManager.getTopCleanLayerName()
    if not string.find(topName, "shengyuan.") then
        local okBtnInfo = {text = TR("进入"), 
            clickAction = function()
                LayerManager.showSubModule(ModuleSub.eShengyuanWars)
            end}
        MsgBoxLayer.addOKCancelLayer(TR("决战桃花岛已开启，是否立即进入？"), TR("决战桃花岛"), okBtnInfo)
    end
end

function ShengyuanWarsHelper:splitAllPlayerData(info)
    self.playerList = {}
    -- 找到我所在的阵营
    for _,v in pairs(info) do
         if v.ActiveSkillsInfo == nil then
            v.ActiveSkillsInfo = {}
            -- 首次进入游戏时服务器不提供此字段故自行初始化
            for m,n in ipairs(v.SkillIds) do
                local configBuff = ShizhuangBuffModel.items[n]
                if configBuff.buffFireType == 1 then -- 主动
                    local tempData = { SkillId = n,ValidTime = 0,CdTime = 0}
                    table.insert(v.ActiveSkillsInfo,tempData)
                end
            end
        end
        
        if (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
            self.myTeamName = v.TeamName
            break
        end
    end

    -- 读取阵营里的数据
    for _,v in pairs(info) do
        -- 当自己处于B阵营时，所有人坐标翻转
        if v.CurPos then
            v.TargetPos = v.TargetPos
            v.CurPos = v.CurPos
        else
            v.CurPos = self:getCurrentResourcePos(v.BornPoint)
            v.TargetPos = clone(v.CurPos)
        end
        -- 初始时所有人在移动中
        v.Status = v.Status or 2
        v.PlayerType = ShengyuanWarsHelper.enumAerocraftType.enemy
        if (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
            v.PlayerType = ShengyuanWarsHelper.enumAerocraftType.myself
            self.battleProtectTime = v.ProtectTime or 0  -- 战斗保护时间
            self.enterProtectTime = v.EnterProtectTime or 0   -- 进入据点禁止退出时间
        elseif (v.TeamName == self.myTeamName) then
            v.PlayerType = ShengyuanWarsHelper.enumAerocraftType.teammate
        end
        -- 计算血量百分比
        v.HPRate = v.Hp * 100 / v.TotalHp
        table.insert(self.playerList, v)
    end
end

function ShengyuanWarsHelper:getCurrentResourcePos(pointIndex)
    local pointPos = {ShengyuanwarsBuildingModel.items[pointIndex].X, ShengyuanwarsBuildingModel.items[pointIndex].Y}
    return pointPos
end

-- 推送类型:向客户端推送五毒散，神符，资源点积分刷新信息
--[[
    {
    "InfoName":"RefreshInfo",
    "Info  '五毒散，神符，资源点积分刷新  类型: map[string]interface{}'":
        {
            "Type": "Type为1的json格式 消息类型(1:五毒散消息， 2：神符消息，3：资源点积分刷新)  (类型: int)",
            "A": "A阵营刷新的五毒散数量 (类型: int)",
            "B": "B阵营刷新的五毒散数量 (类型: int)",
        };
        {
            "Type": "Type为2的json格式 消息类型(1:五毒散消息， 2：神符消息，3：资源点积分刷新)  (类型: int)",
            "BuffInfo '刷新的神符位置 (类型: map[int]int key代表资源点id, value:代表神符id)':
        };
        {
            "Type": "Type为3的json格式 消息类型(1:五毒散消息， 2：神符消息，3：资源点积分刷新)  (类型: int)",
            "A": 'A阵营的当前积分 (类型: int)':
            "B": 'B阵营的当前积分 (类型: int)':
        }
    }
--]]
function ShengyuanWarsHelper:scoreChangedCallback(data)
    -- dump(data, "scoreChangedCallback")
    local dataInfo = data.Info
    if dataInfo.Type == 1 then
        self.APoLingCount = dataInfo.A
        self.BPoLingCount = dataInfo.B
        -- 通知五毒散数量变化
        Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPoLingChanged)
    elseif dataInfo.Type == 2 then
        for pointId,buffId in pairs(dataInfo.BuffInfo) do
            -- 更新当前资源点内的神符ID
            if self.enterResInfo.PointId == tonumber(pointId) then
                self.enterResInfo.BuffId = buffId
                -- 如神符已被占领，则设置为未占领状态
                if self.enterResInfo.Status == 2 and buffId > 0 then
                    self.enterResInfo.Status = 0
                    self.enterResInfo.BuffNum = 1
                end
            end
            -- 更新所有资源点信息中的buff
            for i,v in ipairs(self.allResList) do
                if tonumber(pointId) == v.PointId then
                    v.Status = 0    -- 神符刷新
                    v.BuffId = buffId
                    break
                end
            end
        end
        -- 通知资源点上神符变化
        Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsResBuffChanged)
    elseif dataInfo.Type == 3 then
        -- 重设资源点倒计时
        self.calcResScoreTime = dataInfo.ResTime
        -- 神符刷新倒计时
        self.buffRemainTime = dataInfo.RuneTime
        self:setResScoreChanged(dataInfo)
    end
end

-- 重设双方当前资源点积分
function ShengyuanWarsHelper:setResScoreChanged(data)
    self.AResScore = data.A
    self.BResScore = data.B
    -- 通知双方积分变化
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsScoreChanged)
end

-- 推送类型:推送玩家移动信息
--[[
    {
    "InfoName":"MoveInfo",
    "Info '类型: map[string]interface{}'":
        {
        "PlayerId": "玩家id (int)",
        "CurPos": "玩家当前坐标 ([2]int)",
        "TargetPos": "玩家目标点坐标 ([2]int)"
        }
    }
--]]
function ShengyuanWarsHelper:moveInfoCallback(data)
    -- dump(data, "moveInfoCallback")
    local moveData = data.Info
    -- 己方或敌方移动事件
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == moveData.PlayerId then
            -- 服务器传来的坐标，不需要翻转
            v.CurPos = moveData.CurPos
            v.TargetPos = moveData.TargetPos
            -- 修改玩家状态为移动
            v.Status = 2
            -- 通知某玩家位置或目标变化
            Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPosTargetChanged)
            break
        end
    end
end

-- 推送类型:推送道具的抢占情况
--[[
    {
    "InfoName":"ResPointStatus",
    "Info '类型: map[string]interface{}'":{
        "PointId":"资源点id (int)",
        "BuffId": "道具id (int)"
        "PlayerId":"当前正在操作资源点的玩家 (string)",
        "Status":"道具状态 (int 1:道具正在占领; 2:道具被占领)",
        "A": "A阵营积分 (int)",
        "B": "B阵营积分 (int)",
        }
    }
--]]
function ShengyuanWarsHelper:resPointStatusCallback(data)
    -- dump(data, "resPointStatusCallback")
    local dataInfo = data.Info
    local handleTeam = ""
    -- 当前正在获取的阵容名
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == dataInfo.PlayerId then
            handleTeam = v.TeamName
            -- 玩家获取神符
            if dataInfo.Status == 2 then
                -- 如获得回复神符，血量变化
                if dataInfo.BuffId == 5 then
                    v.Hp = v.TotalHp
                    v.HPRate = 100
                end
                -- 获得持续神符处理
                v.Buff = v.Buff or {}
                local resBuffId = tostring(dataInfo.BuffId)
                local baseTime = ShengyuanwarsBuffModel.items[tonumber(resBuffId)].buffDuration
                if v.Buff[resBuffId] and v.Buff[resBuffId] > 0 then
                    v.Buff[resBuffId] = v.Buff[resBuffId] + baseTime
                else
                    v.Buff[resBuffId] = baseTime
                    -- 通知玩家获取新神符
                    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPlayerBuffChanged, v.PlayerId)
                end
            end
            break
        end
    end
    if self.enterResInfo.PointId == dataInfo.PointId then
        -- 当前资源点信息
        self.enterResInfo.Status = dataInfo.Status
        self.enterResInfo.TeamName = handleTeam
        -- 有人点下抢占按钮时 倒计时开始 读取配置
        if self.enterResInfo.Status == 1 then
            self.enterResInfo.Time = ShengyuanwarsBuffModel.items[1].getBuffNeedTime
        else
            self.enterResInfo.Time = 0
        end
    end
    -- 更新对应资源点状态
    for i,v in ipairs(self.allResList) do
        if v.PointId == dataInfo.PointId then
            v.BuffId = dataInfo.BuffId
            v.Status = dataInfo.Status
            v.TeamName = handleTeam
            -- 五毒散数量变化
            if dataInfo.PointId == 1 and self.APoLingCount > 0 then
                self.APoLingCount = self.APoLingCount - 1
                v.BuffNum = self.APoLingCount
            elseif dataInfo.PointId == 7 and self.BPoLingCount > 0 then
                self.BPoLingCount = self.BPoLingCount - 1
                v.BuffNum = self.BPoLingCount
            end
            break
        end
    end
    if dataInfo.PointId == 1 or dataInfo.PointId == 7 then
        -- 五毒散数量变化
        Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPoLingChanged)
    else
        -- 推送当前资源点的数据
        Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsResInfo)
    end

    -- 更新占领资源点数量
    self:setResScoreChanged(data.Info)
end

--推送类型:向玩家推送所在资源点内的神符信息
--[[
    {
    "InfoName":"ResInfo",
    "Info  '类型: map[string]interface{}'":
        {
            "PointId":"资源点id (int)",
            "BuffId": "道具id (int)",
            "BuffNum": "道具数量 (int)",
            "Time":"倒计时 (int 单位:秒)"
            "Status":"道具状态 (int 0:道具初始状态 1:道具正在占领; 2:道具被占领)"
            "TeamName":"当前正在操作资源点的阵营 (string)",
        }
    }
--]]
function ShengyuanWarsHelper:resPointInfoCallback(data)
    -- dump(data, "resPointInfoCallback")
    -- 当前资源点信息
    self.enterResInfo = data.Info
    -- 推送当前资源点的数据
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsResInfo)
end

-- 推送类型:推送玩家进入退出资源点信息
--[[
    {
    "InfoName":"PlayerEnterOrQuite",
    "Info  '类型: map[string]interface{}'":{
        "PointId":"资源点id (int)",
        "TeamName": "阵营名称 (string)",
        "PlayerId": "玩家id (string)",
        "IsEnter": "玩家是否进入 (bool)"
        }
    }
--]]
function ShengyuanWarsHelper:playerEnterOrQuiteCallback(data)
    --dump(data, "playerEnterOrQuiteCallback")
    local resData = data.Info

    local function changePlayerStatusFunc(info)
        if info.PlayerId == resData.PlayerId then
            if resData.IsEnter then
                info.Status = 1 -- 进入资源点
                info.CurPointId = resData.PointId -- 当前资源点变化

                -- 进入资源点保护开始计时
                if info.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    self.enterProtectTime = ShengyuanwarsConfig.items[1].enterProtectTime
                end
            else
                info.Status = 3 -- 停留资源点上
                -- 出资源点之后，重设当前位置
                info.CurPos = self:getCurrentResourcePos(resData.PointId)

                -- 当前进入的资源点清空
                if info.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    self.enterResInfo = {}
                end
            end

            -- 通知某玩家位置或目标变化
            Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsEnterOrQuiteRes, resData)
        end
    end

    -- 己方或敌方移动事件
    for _,v in ipairs(self.playerList) do
        changePlayerStatusFunc(v)
    end
end

-- 推送类型:推送阵营聊天信息
--[[
    {
    "InfoName":"ChatInfo",
    "Info  '类型: []map[string]interface{}'":
        [
            {
            "Type":"消息类型 (int'1、聊天消息类型; 2、资源状态类型')",
            "PointId":"资源点id (int)",
            "PlayerId":"玩家id (string)",
            "PlayerName":"玩家名称 (string)",
            "Status":"资源点状态 (int'1、正在占领;2、被占领;3、防守住')"
            },
            {
            "Type":"消息类型 (int'1:聊天消息类型;2:资源状态类型')",
            "Name":"发言玩家名称 (sting)",
            "Content":"发言内容 (string)"
            }
        ]
    }
--]]
function ShengyuanWarsHelper:chatInfoCallback(data)
    -- dump(data, "chatInfoCallback")
    local chatInfo = data.Info
    for i,v in ipairs(chatInfo) do
        self:addNewChatInfo(v)
        -- 玩家聊天消息，特别推送
        if v.Type == 1 then
            Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPlayerChatInfo, v)
        end
    end
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsChatInfo)
end

-- 拼接聊天消息
function ShengyuanWarsHelper:addNewChatInfo(v)
    local postData = {}
    if v.Type == 2 then -- 系统消息
        -- postData.name = TR("系统消息")
        -- --postData.isSelf = (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))
        -- postData.isSelf = false
    elseif v.Type == 1 then -- 玩家聊天消息
        postData.name = v.Name
        postData.message = v.Content
        postData.isSelf = (v.Name == Player.playerName)
    end
    if table.nums(postData) > 0 then
        table.insert(self.chatCache, postData)
    end
end

-- 推送类型:向客户端推送玩家战斗结果
--[[
    {
    "InfoName":"FightInfo",
    "Info  '类型: map[string]interface{}'":
        {
        "attackPlayerId":"攻击方玩家id (string)",
        "attackPlayerKillNum":"攻击方玩家杀人数 (int)",
        "atrackPlayerHp": "攻击方玩家当前血量 (int)"
        "atrackPlayerTotalHp": "攻击方玩家总血量 (int)"
        "targetPlayerId":"目标方玩家id (string)"
        "targetPlayerKillNum":"目标方玩家杀人书 (int)"
        "targetPlayerHp": "目标方玩家当前血量 (int)"
        "targetPlayerTotalHp": "目标方玩家总血量 (int)"
        "isWin":"战斗结果 (bool 'false:失败; true:胜利')",
        "A": "A阵营积分 (int)"，
        "B": "B阵营积分 (int)"，
        }
    }
--]]
function ShengyuanWarsHelper:fightInfoCallback(data)
    -- dump(data, "fightInfoCallback")
    -- 获取死亡的玩家ID
    local deathId = data.Info.isWin and data.Info.targetPlayerId or data.Info.attackPlayerId
    -- 查找存活玩家ID
    local survivalId = data.Info.isWin and data.Info.attackPlayerId or data.Info.targetPlayerId
    -- 死亡后，开始复活倒计时，设置到重生点
    if PlayerAttrObj:getPlayerAttrByName("PlayerId") == deathId then
        self.enterResInfo = {}
        self.rebirthTime = ShengyuanwarsConfig.items[1].rebirthTime
    elseif PlayerAttrObj:getPlayerAttrByName("PlayerId") == survivalId then
        -- 战斗完成保护时间
        self.battleProtectTime = ShengyuanwarsConfig.items[1].protectTime
    end
    for _, player in ipairs(self.playerList) do
        -- 重置该玩家的初始位置
        if player.PlayerId == deathId then
            player.CurPos = self:getCurrentResourcePos(player.BornPoint)
            player.TargetPos = player.CurPos
            player.CurPointId = player.BornPoint
            player.Hp = player.TotalHp
            player.HPRate = 100 -- 血量重置
            player.Status = 2   -- 玩家已死亡，默认处于等待界面
            player.Buff = {}    -- 玩家死亡，所有神符置空（五毒散）
        end
        -- 设置战斗胜利玩家的血量
        if player.PlayerId == survivalId then
            local survivalHP = data.Info.isWin and data.Info.atrackPlayerHp or data.Info.targetPlayerHp
            local survivalTotalHP = data.Info.isWin and data.Info.atrackPlayerTotalHp or data.Info.targetPlayerTotalHp
            player.Hp = survivalHP
            player.TotalHp = survivalTotalHP
            player.HPRate = survivalHP * 100 / survivalTotalHP
            -- 胜利方五毒散消失
            if player.Buff then
                for buffId,time in pairs(player.Buff) do
                    if time == -1 then
                        player.Buff[buffId] = nil
                    end
                end
            end
            -- 通知五毒散消失
            Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsPlayerBuffChanged, player.PlayerId)
        end
    end

    -- 推送战斗完成及结果
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsFightOver, data.Info)

    -- 如果是玩家自己阵亡，就把两个据点从栈里移除，避免查看战报返回后重建
    local tmpDeathId = data.Info.isWin and data.Info.targetPlayerId or data.Info.attackPlayerId
    if tmpDeathId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
        LayerManager.deleteStackItem("shengyuan.ShengyuanWarsStrongholdCenterLayer")
        LayerManager.deleteStackItem("shengyuan.ShengyuanWarsStrongholdLayer")
    end

    -- 检查是否需要提示击杀
    local function checkKillCount(pId, count)
        local pName, pTeamName = nil, nil
        for _, player in ipairs(self.playerList) do
            if player.PlayerId == pId then
                pName = player.PlayerName
                pTeamName = player.TeamName
                break
            end
        end
        local noticeCount = count
        if noticeCount >= 7 then
            noticeCount = 7
        end
        local countMsgTabel = {
            [4]=TR("独步一时！"), 
            [5]=TR("举世无双！！"), 
            [6]=TR("盖世无敌！！！"), 
            [7]=TR("旷古绝伦！！！！"),
        }
        local countMsgItem = countMsgTabel[noticeCount]
        if pName and countMsgItem then
            local strColorH = (pTeamName == self.myTeamName) and Enums.Color.eGreenH or Enums.Color.eRedH
            local campName = (pTeamName == self.myTeamName) and TR("我方") or TR("敌方")
            ui.showFlashView({text = TR("%s%s%s的[%s%s%s]已连斩%d人，%s", 
                strColorH, campName, Enums.Color.eNormalWhiteH, 
                strColorH, pName, Enums.Color.eNormalWhiteH, 
                count, 
                countMsgItem), duration = 3})
        end
    end
    if data.Info.isWin then
        checkKillCount(data.Info.attackPlayerId, data.Info.attackPlayerKillNum)
    else
        checkKillCount(data.Info.targetPlayerId, data.Info.targetPlayerKillNum)
    end

    -- 推送当前资源点积分
    self:setResScoreChanged(data.Info)
end

-- 推送类型:向客户端推送战场结算信息(战场结束)
--[[
    {
    "InfoName":"BattleResult",
    "Info  'A,B阵营的玩家战斗结算信息  类型: map[string] map[string]interface{}'":
        {
        "A '阵营A的战斗结果  类型:map[string]interface{}'":
            [
                {
                "Name": "玩家名字 (string)",
                "ServerName": "服务器名字 (string)",
                "Lv" : "玩家等级 (int)",
                "KillNum": "击杀人数 (int)",
                "OccupyResNum": "占领资源点数量 (int)",
                "Glory": "荣誉值 (int)"
                }
            ],
        "B '阵营B的战斗结果  类型:map[string]interface{}'":
            [
                {
                "Name": "玩家名字 (string)",
                "ServerName": "服务器名字 (string)",
                "Lv" : "玩家等级 (int)",
                "KillNum": "击杀人数 (int)",
                "OccupyResNum": "占领资源点数量 (int)",
                "Glory": "荣誉值 (int)"
                }
            ],
        "WinTeam" : "胜利的队伍 类型(string)"
        "ResourceOutputA":"A阵营的资源点产出数量"
        "ResourceOutputB":"B阵营的资源点产出数量"
        }
    }
--]]
function ShengyuanWarsHelper:fightResultCallback(data)
    -- dump(data, "fightResultCallback")
    -- 校正当前资源点产出
    self.AResScore = data.Info.ResourceOutputA
    self.BResScore = data.Info.ResourceOutputB
    -- 推送战场结束及结果
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsFightResult, data.Info)
    
    -- 比赛已结束，就把两个据点从栈里移除，避免查看战报返回后重建
    LayerManager.deleteStackItem("shengyuan.ShengyuanWarsStrongholdCenterLayer")
    LayerManager.deleteStackItem("shengyuan.ShengyuanWarsStrongholdLayer")

    -- 保存结束的数据
    self.battleResultData = data.Info
    -- 断开网络连接
    self:leave()
end

-- 推送类型:向客户端推送取消组队消息
--[[
    {
    "InfoName":"CancelTeam",
    "Info  '类型: map[string]interface{}'":
        {
        "PlayerId":"谁发起取消组队的玩家id (string)",
        }
    }
--]]
function ShengyuanWarsHelper:cancelTeamCallback(data)
    -- dump(data, "CancelTeam")

    -- 推送战场结束及结果
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsCancelTeam, data.Info)
end

--[[---------------------------------ShengyuanWarsHelper数值获取接口---------------------------------------]]

-- 推送类型:向客户端推送天阶岛飞机绝技信息
--[[{
    "InfoName":"SkillEffect",
    "Info  '技能效果信息  类型: map[string]interface{}'":
            {
            "PlayerId": "技能释放者 (类型: string)":
            "SkillId": "释放的技能id (类型: int)":
            "EffectInfo": "该技能影响的玩家 (类型：[]map[string]interface{})"
            [
                {
                    "PlayerId": "玩家id (string)" 
                    "FinalValue": "改变后玩家的最终值 (float64)"
                }
            ]
            }
    }--]]
function ShengyuanWarsHelper:skillEffectCallback(data) --[只更新主动技能]
    --dump(data, "skillEffectCallback")
    -- 更新本地数据 发送通知更新页面
    local buffInfo = ShizhuangBuffModel.items[data.Info.SkillId] 
    -- 更新释放者主动技能数据
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == data.Info.PlayerId then
            if v.ActiveSkillsInfo ~= nil then
                for m,n in ipairs(v.ActiveSkillsInfo) do
                    if n.SkillId == data.Info.SkillId then
                        n.CdTime = buffInfo.CD + ShengyuanWarsHelper.testTime
                        n.ValidTime = buffInfo.duration + ShengyuanWarsHelper.testTime
                        break
                    end
                end
            end
            break
        end
    end

    --释放者技能通知[通知更新特效相关]
    -- 天阶岛绝技技能释放通知
    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsSkillReleasePre .. data.Info.PlayerId,data.Info)
    

    for i,v in ipairs(self.playerList) do
        for m,n in ipairs(data.Info.EffectInfo) do
            if v.PlayerId == n.PlayerId then
                local insertSkill = { SkillId = data.Info.SkillId, ValidTime = buffInfo.duration + ShengyuanWarsHelper.testTime}
                if v.ReceiveActiveSkillInfo == nil then
                    v.ReceiveActiveSkillInfo = {}
                end
                table.insert(v.ReceiveActiveSkillInfo,insertSkill)
                --通知灵兽行动更新本地数据 [目前只影响速度 后续扩展]
                v.Speed = n.FinalValue
                --通知更新技能列表更新
                Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsSkillUpdatePre .. v.PlayerId)
            end
        end 
    end
end
-- 对外接口：获取玩家拥有的法器列表
function ShengyuanWarsHelper:getMountList(callFunc)
    if (callFunc == nil) then
        return
    end

    if (table.maxn(self.mountList) > 0) then
        callFunc(self.mountList)
    else
        HttpClient:request({
            ModuleName = "ShengYuan",
            methodName = "GetShengyuanWarsMountData",
            callback =function (data)
                if not data or data.Status ~= 0 then
                    return
                end
                self.mountList = clone(data.MountInfo)
                callFunc(self.mountList)
            end
            })
    end
end

-- 对外接口：添加一个新的法器
function ShengyuanWarsHelper:addOneMountItem(item)
    if (item ~= nil) and (item.MountModelId ~= nil) and (item.MountModelId > 0) then
        if (self:isHaveOneMount(item.MountModelId) == false) then
            table.insert(self.mountList, clone(item))
        end
    end
end

-- 对外接口：删除一个法器
function ShengyuanWarsHelper:delOneMountItem(mountModelId)
    -- 招魂幡不能被删除
    if (mountModelId ~= nil) and (mountModelId ~= 24010001) then
        for i,v in ipairs(self.mountList) do
            if (v.MountModelId ~= nil) and (v.MountModelId == mountModelId) then
                table.remove(self.mountList, i)
                break
            end
        end
    end
end

-- 对外接口：判断是否拥有某种法器
function ShengyuanWarsHelper:isHaveOneMount(mountModelId)
    if (mountModelId == nil) then
        return false
    end

    for _,v in pairs(self.mountList) do
        if (v.MountModelId ~= nil) and (v.MountModelId == mountModelId) then
            return true
        end
    end

    return false
end

-- 对外接口：更换玩家上阵的法器
function ShengyuanWarsHelper:changeMyMount(newMountModelId, callFunc)
    if (newMountModelId == nil) then
        return
    end

    HttpClient:request({
        moduleName = "GodDomain",
        methodName = "GodDomainMountCombat",
        data       = {newMountModelId},
        callback =function (data)
            if not data or data.Status ~= 0 then
                return
            end
            self:setMountModelId(newMountModelId)
            self:setCurrMountSkillInfo(data.SlotInfo)
            self:setMaxMountModelId(newMountModelId)

            -- 执行回调
            if (callFunc ~= nil) then
                callFunc()
            end
        end
        })
end

-- 对外接口：保存玩家当前法器技能数据
function ShengyuanWarsHelper:setCurrMountSkillInfo(info)
    self.currMountSkillInfo = info
end

-- 对外接口：获得玩家当前法器技能数据
function ShengyuanWarsHelper:getCurrMountSkillInfo()
    return self.currMountSkillInfo
end

-- 对外接口：保存玩家的法器模型id
function ShengyuanWarsHelper:setMountModelId(mountModelId)
    if (mountModelId ~= nil) then
        self.currMountModelId = mountModelId
    end
end

-- 对外接口：保存玩家的最高品质法器模型id
function ShengyuanWarsHelper:setMaxMountModelId(mountModelId)
    if (mountModelId ~= nil) and self.maxMountModelId < mountModelId then
        self.maxMountModelId = mountModelId
    end
end

-- 对外接口：获取最高品质法器模型id
function ShengyuanWarsHelper:getMaxMountModelId()
    return self.maxMountModelId
end

-- 对外接口：获取玩家的法器模型id
function ShengyuanWarsHelper:getMountModelId()
    return self.currMountModelId
end

-- 对外接口：保存玩家的法器等级
function ShengyuanWarsHelper:setMountLv(mountLv)
    if (mountLv ~= nil) then
        self.currMountLv = mountLv
    end
end

-- 对外接口：获取玩家的法器等级
function ShengyuanWarsHelper:getMountLv()
    return self.currMountLv
end

-- 对外接口：获取所在资源点内玩家信息
function ShengyuanWarsHelper:getEnterResInfo(pointId)
    local enterRes = {A={}, B={}}
    for i,v in ipairs(self.playerList) do
        -- 在资源点内且在相同资源点
        if v.Status == 1 and v.CurPointId == pointId then
            if v.TeamName == ShengyuanWarsHelper.teamA then
                table.insert(enterRes.A, v.PlayerId)
            else
                table.insert(enterRes.B, v.PlayerId)
            end
        end
    end
    return enterRes
end

-- 对外接口：获取玩家队伍信息
function ShengyuanWarsHelper:getTeamInfo()
    return self.myTeamInfo
end

--[[---------------------------------set接口---------------------------------------]]

function ShengyuanWarsHelper:setUrl(newUrl)
    if (self.url ~= newUrl) then
        self.url = newUrl
    end
end

-- 返回指定玩家的数据信息，参数为空时返回自己的信息
function ShengyuanWarsHelper:getPlayerData(playerId)
    playerId = playerId or PlayerAttrObj:getPlayerAttrByName("PlayerId")
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == playerId then
            return clone(v)
        end
    end
end

function ShengyuanWarsHelper:getMountSpeed(modelId, level, playerId)
    if playerId == nil then
        local modelSpeed = GoddomainMountModel.items[modelId] and GoddomainMountModel.items[modelId].speedPro or 1
        local levelSpeed = GoddomainMountLvRelation.items[level] and GoddomainMountLvRelation.items[level].speed or 1
        return modelSpeed * levelSpeed
    else
        for i,v in ipairs(self.playerList) do
            if v.PlayerId == playerId then
            	print(v.PlayerName, "速度", v.Speed)
                return v.Speed
            end
        end
    end
end

function ShengyuanWarsHelper:getSpeedAdd(modelId, level, playerId)
	local modelSpeed = GoddomainMountModel.items[modelId] and GoddomainMountModel.items[modelId].speedPro or 1
    local levelSpeed = GoddomainMountLvRelation.items[level] and GoddomainMountLvRelation.items[level].speed or 1
    local originalSpeed = modelSpeed * levelSpeed

    local playerInfo = nil
    for i,v in ipairs(self.playerList) do
        if v.PlayerId == playerId then
            playerInfo = v
            break
        end
    end

    -- Q版时装速度加成
    if playerInfo and playerInfo.ShizhuangModelIdStr ~= "" then
    	local shizhuangList = string.splitBySep(playerInfo.ShizhuangModelIdStr or "", ",")
    	for _, shizhuangId in pairs(shizhuangList) do
		    local speedAdd = ShizhuangModel.items[tonumber(shizhuangId)].shengyuanSpeedAdd
		    originalSpeed = originalSpeed + speedAdd
		end
	end

    return originalSpeed
end

-- 返回当前玩家的数据信息
function ShengyuanWarsHelper:getSelfData()
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            return v
        end
    end
end

function ShengyuanWarsHelper:getReCalculateBuffValue(playerData,buffType)
    local modelSpeed = GoddomainMountModel.items[playerData.MountModelId] and GoddomainMountModel.items[playerData.MountModelId].speedPro or 1
    local levelSpeed = GoddomainMountLvRelation.items[playerData.MountModelLevel] and GoddomainMountLvRelation.items[playerData.MountModelLevel].speed or 1
    local baseSpeed =  modelSpeed * levelSpeed  -- 基础速度

    -- Q版时装速度加成
    if playerData and playerData.ShizhuangModelIdStr ~= "" then
    	local shizhuangList = string.splitBySep(playerData.ShizhuangModelIdStr or "", ",")
    	for _, shizhuangId in pairs(shizhuangList) do
		    local speedAdd = ShizhuangModel.items[tonumber(shizhuangId)].shengyuanSpeedAdd
		    baseSpeed = baseSpeed + speedAdd
		end
	end

    local realValue = 0  --实际值
    local  percentValue = 0 --影响百分比
    for i,v in ipairs(playerData.ReceiveActiveSkillInfo) do 
        local configBuff = ShizhuangBuffModel.items[v.SkillId]
        if configBuff.buffEffectType  == ShizhuangBuff.eSpeed then
            realValue = realValue + configBuff.changeValue
        end
        if configBuff.buffEffectType  == ShizhuangBuff.eSpeedR then
            percentValue = percentValue + configBuff.changeValue
        end
    end

    for i,v in ipairs(playerData.ReceivePassiveSkills) do
        local configBuff = ShizhuangBuffModel.items[v]
        if configBuff.buffEffectType  == ShizhuangBuff.eSpeed then
            realValue = realValue + configBuff.changeValue
        end
        if configBuff.buffEffectType  == ShizhuangBuff.eSpeedR then
            percentValue =percentValue + configBuff.changeValue
        end
    end
    local realSpeed = baseSpeed*(1+percentValue) + realValue

    -- --速度限制
    -- if realSpeed >  GoddomainConfig.items[1].speedMax then
    --    return GoddomainConfig.items[1].speedMax
    -- end

    -- if realSpeed <  GoddomainConfig.items[1].speedMin then
    --     return GoddomainConfig.items[1].speedMin
    -- end
    return realSpeed
end


--移除指定玩家本地的buff信息[主动] [更新buff影响值][手动计算]
function ShengyuanWarsHelper:removeBuffFromLocalPlayerInfo(buffId,playerId)
    local buffInfo = ShizhuangBuffModel.items[buffId]
    --调用前确认玩家信息中已移除该buff
    for i,v in ipairs(self.playerList) do
        if v.PlayerId == playerId then
            local cValue = self:getReCalculateBuffValue(v,buffInfo.buffEffectType)
            if buffInfo.buffEffectType == ShizhuangBuff.eSpeed or
                buffInfo.buffEffectType == ShizhuangBuff.eSpeedR then  --当前版本只影响速度
                self.playerList[i].Speed = cValue
                return cValue
            end
        end
    end
end

--更新指定玩家本地的buff信息[主动] [更新bufff影响值][不用计算服务器提供]
function ShengyuanWarsHelper:updateBuffFromLocalPlayerInfo(buffId,playerId)
    for i,v in ipairs(self.playerList) do
        if v.PlayerId == playerId then
            return v.Speed
        end
    end
end

-- 返回当前玩家的数据信息
function ShengyuanWarsHelper:rebirth()
    self.rebirthTime = 0
end

-- 设置队伍信息
function ShengyuanWarsHelper:setTeamInfo(data)
    self.myTeamInfo = clone(data)
end

--[[---------------------------------ShengyuanWarsHelper功能区---------------------------------------]]

-- 取消匹配
function ShengyuanWarsHelper:cancelMatch(callFunc, errorFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Cancel", Parameters = {}}, callFunc)
        return true
    else
        ui.showFlashView(TR("连接已断开"))
        return false
    end
end

-- 玩家移动(资源点)
function ShengyuanWarsHelper:playerMove(pointId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Move", Parameters = {pointId}}, callFunc)
    end
end

-- 击杀某个玩家
function ShengyuanWarsHelper:playerFight(playerId, pointId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Fight", Parameters = {playerId, pointId}}, callFunc)
    end
end

-- 查看玩家信息
--[[
{
    "Code '类型:int'": "响应结果的状态值",
    "Message '类型:string'": "响应结果的状态值所对应的描述信息",
    "Data '类型:[]map[string]interface{}'":
        {
            "Formation": "用于展示的英雄信息 (json字符串)"
            "HpAndRp '类型:[]map[string]interface{}'":
            {
                [
                "PosId":"对应英雄的位置 (int)注意:从1开始,不是从0"
                "TotalHp": "总共的hp (int)"
                "HP": "剩余的hp (int)"
                "RP": "rp值　(int)"
                ]
            }
            "FightBrief '战斗简报 类型:[]map[string]interface{}'":
            {
                [
                "AttackName": "攻击方名字 (string)"
                "TargetName": "目标方名字 (string)"
                "IsWin": "攻击方的输赢 (bool)"
                ]
            }
            "SlotFormationInfo":"slotId与posId之间的对应 类型:[]int",
            "Fap": "玩家战斗力"
        }
    }
--]]
function ShengyuanWarsHelper:playerViewInfo(playerId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "ViewMemberInfo", Parameters = {playerId}}, callFunc)
    end
end

-- 玩家释放主动技能
function ShengyuanWarsHelper:playerGiveOffSkill(skillId, callFunc, errorbackFunc)
    if (self.socketMgr ~= nil) then
        -- [[""后期扩展内容技能对象ID]]
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Skill", Parameters = {skillId,""}}, callFunc)
    end
end


--获取玩家本地绝技信息 --安全写法使用线程
function ShengyuanWarsHelper:getLocalPlayerInfo(playerId)
    for _, player in ipairs(self.playerList) do
        if player.PlayerId == playerId then
            return player
        end
    end
end

-- 查看玩家战绩
--[[
    "Data '类型:[]interface{}'":
        [
            {
            "Name":"名字",
            "ServerName":"服务器名称",
            "Lv":"等级",
            "KillNum":"杀人数",
            "OccupyResNum":"占领资源点数量",
            "Glory":"荣誉值"
            "TeamName": "玩家所属阵营名称"
            }
        ]
    }
--]]
function ShengyuanWarsHelper:playerViewBattle(callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "ViewBattleInfo", Parameters = {}}, callFunc)
    end
end

-- 查看玩家战报
--[[
    string:目标玩家的id
    int: 战报索引
--]]
function ShengyuanWarsHelper:viewFightReport(playerId, idx, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "ViewFightReport", Parameters = {playerId, idx}}, callFunc)
    end
end

-- 占领某个资源点(获取神符)
function ShengyuanWarsHelper:occupyPoint(pointId, callFunc)
    if (self.socketMgr ~= nil) then
        local buffId = 0
        -- 查找资源点上对应的buffer id
        for i,v in ipairs(self.allResList) do
            if v.PointId == pointId then
                buffId = v.BuffId
                break
            end
        end
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Occupy", Parameters = {pointId, buffId}}, callFunc)
    end
end

-- 进入某个资源点
function ShengyuanWarsHelper:enterPoint(pointId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Enter", Parameters = {pointId}}, callFunc)
    end
end

-- 退出当前资源点
function ShengyuanWarsHelper:quitPoint(pointId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Quit", Parameters = {pointId}}, callFunc)
    end
end

-- 发起聊天
function ShengyuanWarsHelper:chatToAll(strText, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "ShengYuan", MethodName = "Chat", Parameters = {strText}}, callFunc)
    end
end
