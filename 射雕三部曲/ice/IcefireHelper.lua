--[[
    文件名：IcefireHelper.lua
    描述：绝情谷Helper（单例）
    创建人：heguanghui
    创建时间：2018.1.22
-- ]]
IcefireHelper = {
    socketMgr = nil,
    url = nil,              -- 服务器URL
    heartTick = 0,          -- 心跳计时
    shedulerTick = 0,       -- 每秒计时
    playerList = {},        -- 玩家信息数据
    bossList = {},          -- boss信息数据
    ownPlayerInfo = {},     -- 玩家自己信息
    joinTeamReqList = {},   -- 请求加入队伍消息列表
}

-- IcefireHelper事件集合
IcefireHelper.Events = {
    ePlayerMove = "eIcefirePlayerMove",  -- 玩家移动事件
    eAddOneHero = "eIcefireAddOneHero",  -- 玩家加入事件
    eDeleteOneHero = "eIcefireDeleteOneHero",  -- 玩家退出事件
    eCreateOneBoss = "eIcefireCreateOneBoss",   -- 创建怪
    eDeleteOneBoss = "eIcefireDeleteOneBoss",   -- 删除怪
    eRefreshOwnInfo = "eIcefireRefreshOwnInfo",   -- 刷新玩家自己信息
    eReqJoinTeam = "eIcefireReqJoinTeam",   -- 请求加入队伍推送
    eRefreshAllPlayers = "eIcefireRefreshAllPlayers",   -- 刷新所有玩家
}


-- 进入比赛
function IcefireHelper:connect(callFunc)
    if (self.url == nil) then
        return
    end
    self.heartTick = Player.mTimeTick

    -- 防止重复连接
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
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
        end,
        connChangeCb = function(msgType)
            if callFunc and (msgType == SocketClient.MSG_TYPE_SOCKET_OPEN or 
                msgType == SocketClient.MSG_TYPE_SOCKET_RECONNECT_OPEN) then
                -- 正常连接socket成功
                callFunc(true)
            elseif msgType == SocketClient.MSG_TYPE_SOCKET_CLOSE then
                -- 重新连接
                print("第一次重连")
                self:reConnect()
                -- 定时重新连接
                local timeCount = 0
                self.reConnUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
                    if self.reConnUpdate and ((self.socketMgr and self.socketMgr:isConnected()) or (timeCount > 60))  then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.reConnUpdate)
                        self.reConnUpdate = nil
                        return
                    end
                    timeCount = timeCount + 3

                    print("重新连接... self.socketMgr", self.socketMgr, self.socketMgr:isConnected())
                    self:reConnect()
                end, 3, false)
            end
        end,
    })

    -- 开启心跳倒计时
    self.heartSheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
        if self.socketMgr and self.socketMgr:isConnected() then
            -- 检查是否需要发送心跳包
            if (Player.mTimeTick - self.heartTick) > 30 then
                print("发送心跳包")
                self.socketMgr:sendMessage({ModuleName = "Player", MethodName = "Beat", Parameters = {}})
                self.heartTick = Player.mTimeTick
            end
        end
    end, 1, false)
end
-- 重新连接
function IcefireHelper:reConnect()
    self:connect(function ( ... )
        self.getChannelUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
            self:getChannelData()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.getChannelUpdate)
            self.getChannelUpdate = nil
        end, 2, false)
    end)
end

-- 处理消息
function IcefireHelper:dealRecvData(response)
    if response.Code == 0 then
        if type(response.Data) == "userdata" then
            return
        end

        if response.Data and response.Data.InfoName then
            local infoName = response.Data.InfoName
            -- dump(response.Data, "recv data")
            if infoName == "MoveInfo" then
                self:moveInfoCallback(response.Data)
            elseif infoName == "PlayerAddChannel" then
                self:addPlayerCallback(response.Data)
            elseif infoName == "PlayerQuitChannel" then
                self:deletePlayerCallback(response.Data)
            elseif infoName == "FightResult" then
                self:fightResultCallback(response.Data)
            elseif infoName == "RefreshBoss" then
                self:refreshBossCallback(response.Data)
            elseif infoName == "BegAddTeam" then
                self:joinTeamReqCallback(response.Data)
            elseif infoName == "AgreeAddTeam" then
                self:dealTeamCallback(response.Data)
            elseif infoName == "RejectAddTeam" then
                self:rejectTeamReqCallback(response.Data)
            elseif infoName == "QuitTeam" then
                self:quitTeamCallback(response.Data)
            elseif infoName == "DeleteMember" then
                self:dealTeamCallback(response.Data)
            elseif infoName == "CancelTeam" then
                self:cancelTeamCallback(response.Data)
            elseif infoName == "ViewPlayerInfo" then
                self:viewPlayerCallback(response.Data)
            elseif infoName == "GetChannelData" then
                self:getChannelDataCallback(response.Data)
            else
                --dump(response.Data, "recv data")
            end
        end
    else
        --提示错误信息(-10006,忽略多次推送时导致道具不存在报错。屏蔽掉"未找到玩家对象")
        if response.Code ~= -10006 and response.Code ~= -1116 then
            local errorStr = SocketStates.errorCode[response.Code] or TR("未知错误，错误码(%d)", response.Code)
            ui.showFlashView(errorStr)
        end
    end
end


-- 离开比赛
function IcefireHelper:leave()
    -- 调用退出
    IcefireHelper:quit()

    -- 销毁定时器
    if self.heartSheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.heartSheduler)
        self.heartSheduler = nil
    end
    if self.socketSheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.socketSheduler)
        self.socketSheduler = nil
    end
    if self.reConnUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.reConnUpdate)
        self.reConnUpdate = nil
    end
    if (self.socketMgr ~= nil) then
        -- 关闭socket，删除断线回调
        self.socketMgr:destroy()
        self.socketMgr = nil
    end

    self:resetCache()
end

function IcefireHelper:resetCache()
    -- 清空缓存数据
    self.url = nil
    self.shedulerTick = 0
    self.playerList = {}
    self.bossList = {}
    self.ownPlayerInfo = {}
    self.joinTeamReqList = {}
end


--[[---------------------------------解析服务端返回的数据---------------------------------------]]
-- 推送类型:推送玩家移动信息
function IcefireHelper:moveInfoCallback(data)
    dump(data, "moveInfoCallback")
    print(string.format("服务走路耗时：%s", data.Info.GetArriveTime-Player:getCurrentTime()))
    Notification:postNotification(IcefireHelper.Events.ePlayerMove, data.Info)
end

-- 推送类型:玩家加入频道
function IcefireHelper:addPlayerCallback(data)
    dump(data, "addPlayerCallback")
    -- 添加新玩家数据
    local isExist = false
    for _, playerInfo in pairs(self.playerList) do
        if playerInfo.PlayerId == data.Info.PlayerId then
            playerInfo = clone(data.Info)
            isExist = true
        end
    end
    if not isExist then
        table.insert(self.playerList, clone(data.Info))
    end
    -- 添加玩家节点
    Notification:postNotification(IcefireHelper.Events.eAddOneHero, data.Info)
end

-- 推送类型:玩家退出频道
function IcefireHelper:deletePlayerCallback(data)
    dump(data, "deletePlayerCallback")
    for i, playerInfo in pairs(self.playerList) do
        if playerInfo.PlayerId == data.Info.PlayerId then
            table.remove(self.playerList, i)
            break
        end
    end
    -- 删除玩家节点
    Notification:postNotification(IcefireHelper.Events.eDeleteOneHero, data.Info)
    -- 若是自己(不活跃服务器会推送)
    if data.Info.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
        self:leave()
        LayerManager.removeTopLayer(true)
    end
end
-- 打boss回调
function IcefireHelper:fightResultCallback(data)
    dump(data, "fightResultCallback")
    -- 显示是否击败boss
    -- if data.Info.IsWin then
    --     ui.showFlashView(TR("击败该Boss!"))
    -- else
    --     ui.showFlashView(TR("遗憾惜败"))
    -- end
    LayerManager.addLayer({
        name = "ice.IcefireResultLayer",
        data = {
            isWin = data.Info.IsWin,
            randNum = data.Info.RandNum,
            bossId = data.Info.BossModelId,
        },
        cleanUp = false,
    })

    -- 刷新玩家自己信息
    self.ownPlayerInfo = data.Info.PlayerInfo
    -- 刷新界面神行值显示
    Notification:postNotification(IcefireHelper.Events.eRefreshOwnInfo)
end
-- 刷新boss回调
function IcefireHelper:refreshBossCallback(data)
    dump(data, "refreshBossCallback")
    -- 刷新boss数据
    for i, bossInfo in pairs(self.bossList) do
        if bossInfo.Id == data.Info.RemoveBossInfo.Id then
            table.remove(self.bossList, i)
        end
    end
    table.insert(self.bossList, data.Info.AddBossInfo)

    Notification:postNotification(IcefireHelper.Events.eCreateOneBoss, data.Info.AddBossInfo)
    Notification:postNotification(IcefireHelper.Events.eDeleteOneBoss, data.Info.RemoveBossInfo)
end
-- 请求加入队伍推送回调
function IcefireHelper:joinTeamReqCallback(data)
    dump(data, "joinTeamReqCallback")
    -- 添加申请加入队伍请求
    self.joinTeamReqList[data.Info.PlayerId] = data.Info
    -- 当前上层页面是请求加入队伍页面
    if LayerManager.getTopCleanLayerName() == "ice.IcefireJoinTeamReqLayer" then
        Notification:postNotification(IcefireHelper.Events.eReqJoinTeam)
    else
        LayerManager.addLayer({name = "ice.IcefireJoinTeamReqLayer", cleanUp = false})
    end
end
-- 处理部分队伍信息
function IcefireHelper:dealTeamCallback(data)
    dump(data, "dealTeamCallback")
    -- 更新自己信息
    self.ownPlayerInfo = clone(data.Info.PlayerInfo)
    -- 刷新队伍显示
    Notification:postNotification(IcefireHelper.Events.eRefreshOwnInfo)
end

-- 被拒绝组队
function IcefireHelper:rejectTeamReqCallback(data)
     dump(data, "rejectTeamReqCallback")
     ui.showFlashView(TR("已被%s拒绝加入队伍", data.Info.Name))
end

-- 退出队伍
function IcefireHelper:quitTeamCallback(data)
    dump(data, "quitTeamCallback")
    -- 更新自己信息
    self.ownPlayerInfo = clone(data.Info.PlayerInfo)
    -- 刷新队伍显示
    Notification:postNotification(IcefireHelper.Events.eRefreshOwnInfo)

    local playerInfo = self:getPlayerData(data.Info.QuitPlayerId)
    if playerInfo and data.Info.QuitPlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
        ui.showFlashView(TR("%s已退出队伍", playerInfo.Name))
    end
end

-- 解散队伍
function IcefireHelper:cancelTeamCallback(data)
    dump(data, "cancelTeamCallback")
    -- 更新自己信息
    self.ownPlayerInfo = clone(data.Info.PlayerInfo)
    -- 刷新队伍显示
    Notification:postNotification(IcefireHelper.Events.eRefreshOwnInfo)

    ui.showFlashView(TR("队长已解散队伍"))
end

-- 查看玩家信息回调
function IcefireHelper:viewPlayerCallback(data)
    dump(data, "viewPlayerCallback")
    for i, playerInfo in pairs(self.playerList) do
        if playerInfo.PlayerId == data.Info.PlayerInfo.PlayerId then
            table.remove(self.playerList, i)
            table.insert(self.playerList, clone(data.Info.PlayerInfo))
        end
    end
    if self.ownPlayerInfo.PlayerId == data.Info.PlayerInfo.PlayerId then
        self.ownPlayerInfo = data.Info.PlayerInfo
    end

    LayerManager.addLayer({name = "ice.IcefirePlayerInfoLayer", data = {playerId = data.Info.PlayerInfo.PlayerId, msgType = 1}, cleanUp = false})
end

-- 获取频道所有玩家
function IcefireHelper:getChannelDataCallback(data)
    dump(data, "viewPlayerCallback")
    -- 设置玩家信息
    IcefireHelper:setOwnPlayerInfo(data.Info.PlayerInfo)
    -- 设置玩家列表信息
    IcefireHelper:setPlayerListInfo(data.Info.ChannelPlayer)
    -- 设置boss信息
    IcefireHelper:setBossListInfo(data.Info.ChannelBossData)

    Notification:postNotification(IcefireHelper.Events.eRefreshAllPlayers)
end

-- --[[---------------------------------set接口---------------------------------------]]
-- 设置服务器ip
function IcefireHelper:setUrl(newUrl)
    if (self.url ~= newUrl) then
        self.url = newUrl
    end
end
-- 设置玩家自己信息
function IcefireHelper:setOwnPlayerInfo(info)
    if info then
        self.ownPlayerInfo = info
    end
end
-- 设置玩家列表信息
function IcefireHelper:setPlayerListInfo(info)
    if info then
        self.playerList = info
    end
end
-- 设置boss列表信息
function IcefireHelper:setBossListInfo(info)
    if info then
        self.bossList = info
    end
end

-- 返回指定玩家的数据信息，参数为空时返回自己的信息
function IcefireHelper:getPlayerData(playerId)
    playerId = playerId or PlayerAttrObj:getPlayerAttrByName("PlayerId")
    -- 自己玩家信息
    if playerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
        return clone(self.ownPlayerInfo)
    end
    -- 其他玩家信息
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == playerId then
            return clone(v)
        end
    end
end

-- --[[---------------------------------IcefireHelper功能区---------------------------------------]]

-- 玩家移动
function IcefireHelper:playerMove(tergetPos, callFunc)
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "Move", Parameters = {tergetPos.x, tergetPos.y}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 打boss
function IcefireHelper:challengeNpc(bossId, callFunc)
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "Fight", Parameters = {bossId}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 请求加入队伍
function IcefireHelper:requestPlayerInfo(playerId)
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "ViewPlayerInfo", Parameters = {playerId}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 请求加入队伍
function IcefireHelper:requestJoinTeam(teamPlayerId)
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "AddTeam", Parameters = {teamPlayerId}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 同意加入队伍
function IcefireHelper:agreeJoinTeam(playerId, isAgree)
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "AgreeAddTeam", Parameters = {playerId, isAgree}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 退出队伍
function IcefireHelper:quitTeam()
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "QuitTeam", Parameters = {}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 解散队伍
function IcefireHelper:cancelTeam()
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "CancelTeam", Parameters = {}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 踢出队伍
function IcefireHelper:deleteMember(playerId)
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "DeleteMember", Parameters = {playerId}}, callFunc)
    else
        ui.showFlashView(TR("连接已断开，正在重新连接"))
        self:reConnect()
    end
end

-- 退出频道
function IcefireHelper:quit()
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "Quit", Parameters = {}}, callFunc)
    end
end

-- 获取频道所有玩家
function IcefireHelper:getChannelData()
    if (self.socketMgr ~= nil) and self.socketMgr:isConnected() then
        self.socketMgr:sendMessage({ModuleName = "Icefire", MethodName = "GetChannelData", Parameters = {}}, callFunc)
    end
end
-- --[[---------------------------------IcefireHelper辅助接口---------------------------------------]]
-- 使用灵石添加神行值
function IcefireHelper:addActionNum(num)
    HttpClient:request({
        moduleName = "IcefireTeamHall",
        methodName = "UseGoods",
        svrMethodData = {num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "UseGoods")
            self.ownPlayerInfo = response.Value.PlayerInfo
            -- 刷新界面神行值显示
            Notification:postNotification(IcefireHelper.Events.eRefreshOwnInfo)
        end
    })
end

-- 获取指定PlayerId对应的名字
function IcefireHelper:getPlayerName(playerId)
    for _,v in ipairs(self.playerList or {}) do
        if v.PlayerId == playerId then
            return v.Name
        end
    end
    return ""
end

-- 求两个点的旋转角度，并返回距离点集合
--[[
    params:
        startPos: 当前位置
        endPos: 目标位置
        step: 集合点间距

    return:
        stepList: 路径集合
--]]
function IcefireHelper.getRotationStepLists(startPos, endPos, step)
    local stepv = step or 30
    local disv = cc.p(startPos.x - endPos.x, startPos.y - endPos.y)
    local dis = math.sqrt(disv.x * disv.x + disv.y * disv.y)
    local angle = math.atan(disv.x / disv.y)

    -- 计算路径列表
    local stepNum = math.ceil(dis / stepv)
    local stepX = (endPos.x - startPos.x) / stepNum
    local stepY = (endPos.y - startPos.y) / stepNum
    local stepList = {}
    for i=1, stepNum do
        if i == stepNum then
            table.insert(stepList, endPos)
        else
            table.insert(stepList, cc.p(startPos.x + i * stepX, startPos.y + i * stepY))
        end
    end

    return stepList
end

-- 创建路线点
function IcefireHelper.createHeroPathDot(heroNode, startPos, endPos, moveTime)
    heroNode.lineNodes = heroNode.lineNodes or {}
    -- 清除原来点
    for _, node in pairs(heroNode.lineNodes) do
        if node and not tolua.isnull(node) then
            node:stopAllActions()
            node:removeFromParent()
        end
    end
    heroNode.lineNodes = {}
    -- 获取点坐标
    local dotPosList = IcefireHelper.getRotationStepLists(startPos, endPos)
    -- 创建点
    for i, pos in ipairs(dotPosList) do
        local dotSprite = ui.newSprite("jzthd_45.png")
        dotSprite:setPosition(pos)
        heroNode:getParent():addChild(dotSprite)

        table.insert(heroNode.lineNodes, dotSprite)

        -- 自动清除点
        Utility.performWithDelay(heroNode, function ( ... )
            dotSprite:removeFromParent()
            dotSprite = nil
        end, i*(moveTime/#dotPosList))
    end
end

-- --[[---------------------------------IcefireHelper界面控件接口---------------------------------------]]
-- 创建heroNode
function IcefireHelper.createHeroNode(heroInfo)
    local heroNode = cc.Node:create()
    if not heroInfo.ShizhuangId or heroInfo.ShizhuangId == 0 then
        heroInfo.ShizhuangId = QFashionObj:getQFashionModelIdByDressType()
    end

    local positivePic, backPic = QFashionObj:getQFashionLargePic(heroInfo.ShizhuangId)
    local effectNames = {positivePic, backPic}
    heroNode.playerSpines = {}
    -- 创建正面和背面的形象
    for _, effectName in ipairs(effectNames) do
        local pSpine = ui.newEffect({
            parent = heroNode,
            anchorPoint = cc.p(0.5, 0.5),
            effectName = effectName,
            loop = true,
            endRelease = true,
            scale = 0.6
        })
        -- pSpine:setVisible(false)
        pSpine:setAnimation(0, "daiji", true)

        table.insert(heroNode.playerSpines, pSpine)
    end
    -- 名字
    local nameLabel = ui.newLabel({
        text = heroInfo.Name,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    nameLabel:setPosition(0, 140)
    heroNode:addChild(nameLabel)
    --点击玩家响应按钮
    local clickBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(80, 150),
        position = cc.p(0, 75),
        clickAction = function()
            -- print("玩家点击响应")
            -- self:requestJoinTeam(heroInfo.PlayerId)
            if heroInfo.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                IcefireHelper:requestPlayerInfo(heroInfo.PlayerId)
            end
        end
    })
    clickBtn:setSwallowTouches(true)
    heroNode:addChild(clickBtn)

    -- 移动状态
    heroNode.moveStatus = function (target, targetPos)
        local curPos = cc.p(target:getPosition())
        -- 左右
        if targetPos.x < curPos.x then
            target.playerSpines[1]:setRotationSkewY(-180)
            target.playerSpines[2]:setRotationSkewY(-180)
        else
            target.playerSpines[1]:setRotationSkewY(0)
            target.playerSpines[2]:setRotationSkewY(0)
        end
        -- 上下
        if targetPos.y < curPos.y then
            target.playerSpines[1]:setVisible(true)
            target.playerSpines[2]:setVisible(false)
        else
            target.playerSpines[1]:setVisible(false)
            target.playerSpines[2]:setVisible(true)
        end
        
        target.playerSpines[1]:setToSetupPose()
        target.playerSpines[1]:setAnimation(0, "zou", true)
        target.playerSpines[2]:setToSetupPose()
        target.playerSpines[2]:setAnimation(0, "zou", true)
    end
    -- 停止状态
    heroNode.stopStatus = function (target)
        target.playerSpines[1]:setToSetupPose()
        target.playerSpines[1]:setAnimation(0, "daiji", true)
        target.playerSpines[2]:setToSetupPose()
        target.playerSpines[2]:setAnimation(0, "daiji", true)

        target.playerSpines[1]:setVisible(true)
        target.playerSpines[2]:setVisible(false)

        target:stopAllActions()

        if target.lineNodes then
            for _, node in pairs(target.lineNodes) do
                if node and not tolua.isnull(node) then
                    node:stopAllActions()
                    node:removeFromParent()
                end
            end
            target.lineNodes = {}
        end
    end
    -- 创建移动动作
    heroNode.move = function (target, curPos, targetPos)
        -- 重设玩家当前位置
        target:setPosition(curPos)
        -- 不移动
        if curPos.x == targetPos.x and curPos.y == targetPos.y then
            -- 待机状态
            target:stopStatus()
            return
        end
        target:stopAllActions()
        -- 移动状态
        target:moveStatus(targetPos)
        -- 创建移动
        local speed = IcefireConfig.items[1].baseSpeed
        local length = cc.pGetLength(cc.pSub(curPos, targetPos))
        local moveTime = length/speed
        target:runAction(cc.Sequence:create({
            cc.MoveTo:create(moveTime, targetPos),
            cc.CallFunc:create(function (node)
                node:stopStatus()
            end)
        }))
        -- 玩家自己创建路线点
        if heroInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") and IcefireHelper.ownPlayerInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            IcefireHelper.createHeroPathDot(target, curPos, targetPos, moveTime)
        end
    end

    -- 初始待机状态
    heroNode:stopStatus()

    return heroNode
end

-- 创建bossNode
function IcefireHelper.createBossNode(bossInfo, callFunc)
    local bossNode = cc.Node:create()

    -- 模型数据
    local bossModel = IcefireBossModel.items[bossInfo.BossId]

    -- 模型动作
    local pSpine = ui.newEffect({
            parent = bossNode,
            anchorPoint = cc.p(0.5, 0.5),
            effectName = bossModel.mountSpineQ,
            loop = true,
            endRelease = true,
            scale = 0.6
        })

    -- 名字
    local nameLabel = ui.newLabel({
        text = bossModel.name,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    nameLabel:setPosition(0, 140)
    bossNode:addChild(nameLabel)

    --点击boss响应按钮
    local clickBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(120, 180),
        position = cc.p(0, 75),
        clickAction = function()
            -- 点击回调
            if callFunc then
                callFunc()
            end
        end
    })
    clickBtn:setSwallowTouches(true)
    bossNode:addChild(clickBtn)


    return bossNode
end