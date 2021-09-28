--[[
    文件名：KillerValleyHelper.lua
    描述：绝情谷Helper（单例）
    创建人：heguanghui
    创建时间：2018.1.22
-- ]]
KillerValleyHelper = {
    socketMgr = nil,
    url = nil,              -- 服务器URL
    heartTick = 0,          -- 心跳计时
    shedulerTick = 0,       -- 每秒计时
    maxBagCount = 6,        -- 包裹最大容量
    playerSpeed = KillervalleyConfig.items[1].speed,        -- 玩家初始移动速度
    flyPropSpeed = KillervalleyConfig.items[1].flyKnifeSpeed,   -- 飞刀的移动速度
    flyPropDistance = KillervalleyConfig.items[1].maxDistance,  -- 飞刀的攻击距离
    enemyReachDistance = KillervalleyConfig.items[1].battleDistance,  -- 可攻击的范围
    trapDistance = KillervalleyConfig.items[1].trapDistance, -- 陷阱触发范围
    playerBoxSize = cc.size(68, 122),  -- 玩家的检测大小

    playerList = {},        -- 所有玩家列表
    packageInfo = {},       -- 地图上的包裹信息
    trapInfo = {},          -- 地图上的陷阱信息
    flyPropList = {},       -- 所有飞刀的列表
    bagGoodsList = {},      -- 玩家背包数据
    selfVisible = true,     -- 自己是否可见(进入建筑时隐藏)
    poisonCircle = {},      -- 毒圈信息
    poisonWarning = {},     -- 毒圈警告信息
}

-- KillerValleyHelper事件集合
KillerValleyHelper.Events = {
    eEnterBattle = "eKillerValleyEnterBattle",  -- 进入战场通知
    eInOutNode = "eKillerValleyInOutNode",      -- 进出半透结点通知
    ePlayerStatus = "eKillerValleyPlayerStatus",-- 玩家状态变化(受伤，加血等)
    ePoisonCircle = "eKillerValleyPoisonCircle",-- 毒圈通知
    ePoisonWarning = "eKillerValleyPoisonWarning",-- 毒圈警告通知
    eHPChanged = "eKillerValleyHPChanged",      -- 玩家血量变化
    eNoticeMsg = "eKillerValleyNoticeMsg",      -- 新消息推送
    ePlayerDeath = "eKillerValleyPlayerDeath",  -- 玩家死亡通知
    eBattleResult = "eKillerValleyBattleResult",-- 战场结束
    eCancelTeam = "eKillerValleyCancelTeam",    -- 某玩家取消了组队
}

-- 玩家特效类型集合
-- 中毒：poisonEff, 绑定到player对象中
-- 隐身：hidingEff, 绑定到player对象中
-- 强体：doubleEff, 绑定到player对象中
-- 攻击范围: reachable, 绑定到player对象中
KillerValleyHelper.HeroStatus = {
    eHurt = 1,      -- 受伤效果
    eTrap = 2,      -- 受陷阱效果
    eBlood = 3,     -- 回血效果
    ePoison = 4,    -- 中毒
    eHiding = 5,    -- 隐身
    eAttrDouble = 6,-- 攻防翻倍
}

-- 进入比赛
function KillerValleyHelper:connect(callFunc)
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
        end,
        connChangeCb = function(msgType)
            if callFunc and (msgType == SocketClient.MSG_TYPE_SOCKET_OPEN or 
                msgType == SocketClient.MSG_TYPE_SOCKET_RECONNECT_OPEN) then
                -- 正常连接socket成功
                callFunc(true)
            elseif msgType == SocketClient.MSG_TYPE_SOCKET_CLOSE then
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
function KillerValleyHelper:dealRecvData(response)
    if response.Code == 0 then
        if type(response.Data) == "userdata" then
            return
        end

        if response.Data and response.Data.InfoName then
            local infoName = response.Data.InfoName
            -- dump(response.Data, "recv data")
            if infoName == "BattleInfo" or infoName == "LoginAgainInfo" then
                self:battleInfoCallback(response.Data)
            elseif infoName == "MoveInfo" then
                self:moveInfoCallback(response.Data)
            elseif infoName == "ShotPropInfo" then
                self:shotPropCallback(response.Data)
            elseif infoName == "HurtPlayerInfo" then
                self:hurtPlayerCallback(response.Data)
            elseif infoName == "FireTrapInfo" then
                self:fireTrapCallback(response.Data)
            elseif infoName == "TrapHurtInfo" then
                self:trapHurtCallback(response.Data)
            elseif infoName == "PickUp" then
                self:pickUpCallback(response.Data)
            elseif infoName == "UseGoods" then
                self:useGoodsCallback(response.Data)
            elseif infoName == "DeadInfo" then
                self:deadInfoCallback(response.Data)
            elseif infoName == "FightResult" then
                self:fightResultCallback(response.Data)
            elseif infoName == "ShrinkageInfo" then
                self:poisonCircleCallback(response.Data)
            elseif infoName == "ShrinkageWarningInfo" then
                self:poisonWarningCallback(response.Data)
            elseif infoName == "FormationInfo" then
                self:formationInfoCallback(response.Data)
            elseif infoName == "AllFormationInfo" then
                self:allFormationInfoCallback(response.Data)
            elseif infoName == "BattleResult" then
                self:battleResultCallback(response.Data)
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
                                data = {autoOpenModule = ModuleSub.eKillerValley}
                            })
                        end
                    },
                    nil,
                    false
                )
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

function KillerValleyHelper:scheduleTime()
    if not self.socketSheduler then
        -- 计算毒圈的掉血比例
        self.poisonRatioList = {}
        for _,value in pairs(KillervalleyShrinkageModel.items) do
            self.poisonRatioList[value.radius] = value.hurtRatio / 10000.0
        end
        -- 创建定时器
        local selfPId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
        self.socketSheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
            if self.socketMgr and self.socketMgr:isConnected() then
                -- 移动人物的位置
                local selfCurPos = nil
                for _, player in ipairs(self.playerList) do
                    if player.Angle >= 0 then
                        local radian = player.Angle * math.pi / 180
                        local cosA = math.cos(radian)
                        local sinA = math.sin(radian)
                        player.CurPos.x = player.CurPos.x + cosA * dt * self.playerSpeed
                        player.CurPos.y = player.CurPos.y + sinA * dt * self.playerSpeed
                        -- 限制人物不能走出边界
                        player.CurPos.x = math.max(player.CurPos.x, 0)
                        player.CurPos.x = math.min(player.CurPos.x, 4080)
                        player.CurPos.y = math.max(player.CurPos.y, 0)
                        player.CurPos.y = math.min(player.CurPos.y, 3900)
                    end
                    -- 保存自己的位置
                    if player.PlayerId == selfPId then
                        selfCurPos = player.CurPos
                    end
                end

                -- 判断自己与其它人之间的位置是否在攻击距离之内
                if selfCurPos then
                    for _, player in ipairs(self.playerList) do
                        -- 保存其它玩家是否在攻击范围内
                        if player.PlayerId ~= selfPId then
                            player.reachable = cc.pGetDistance(selfCurPos, player.CurPos) <= self.enemyReachDistance
                        end
                    end
                end

                -- 飞刀位置移动
                local propCount = #self.flyPropList
                if propCount > 0 then
                    -- 计算所有玩家的当前检测区域
                    for _, player in ipairs(self.playerList) do
                        player.playerBox = cc.rect(player.CurPos.x - self.playerBoxSize.width * 0.5, player.CurPos.y, self.playerBoxSize.width, self.playerBoxSize.height)
                    end
                    for i=propCount,1,-1 do
                        local prop = self.flyPropList[i]
                        if not prop.dirX or not prop.dirY then
                            local radian = prop.Angle * math.pi / 180
                            prop.dirX = math.cos(radian)
                            prop.dirY = math.sin(radian)
                        end
                        -- 飞刀位置移动
                        prop.CurPos.x = prop.CurPos.x + prop.dirX * dt * self.flyPropSpeed
                        prop.CurPos.y = prop.CurPos.y + prop.dirY * dt * self.flyPropSpeed

                        -- 判断是否已击中玩家
                        local isHurtPlayer = false
                        for _, player in ipairs(self.playerList) do
                            local collusion = self:isLineRectIntersect(prop.StartPos, prop.CurPos, player.playerBox)
                            -- 飞刀主人及被击中玩家均发送击中通知(飞刀主人不能是中刀者)
                            if collusion and player.PlayerId ~= prop.PlayerId and (player.PlayerId == selfPId or prop.PlayerId == selfPId) then
                                self:hurtPlayer(prop.PlayerId, player.PlayerId, prop.UniqueId)
                                table.remove(self.flyPropList, i)
                                isHurtPlayer = true
                                break
                            end
                        end
                        -- 如已移动出界，则删除此飞刀
                        if not isHurtPlayer and cc.pGetDistance(prop.CurPos, prop.StartPos) > self.flyPropDistance then
                            table.remove(self.flyPropList, i)
                        end
                    end
                end

                -- 判断陷阱是否击中
                if #self.trapInfo > 0 then
                    for i=#self.trapInfo,1,-1 do
                        local trap = self.trapInfo[i]
                        for _, player in ipairs(self.playerList) do
                            local isContainer = cc.pGetDistance(trap.StartPos, player.CurPos) <= self.trapDistance
                            -- 暂时陷阱对自己不生效
                            if isContainer and player.PlayerId ~= trap.PlayerId and (player.PlayerId == selfPId or trap.PlayerId == selfPId)  then
                                -- 有玩家触发了陷阱
                                self:trapHurt(trap.PlayerId, player.PlayerId, trap.UniqueId)
                                table.remove(self.trapInfo, i)
                                break
                            end
                        end
                    end
                end

                -- 每秒更新内容
                self.shedulerTick = self.shedulerTick + dt
                if self.shedulerTick >= 1 then
                    -- 毒圈时间更新
                    if self.poisonCircle.RemainTime and self.poisonCircle.RemainTime > 0 then
                        self.poisonCircle.RemainTime = self.poisonCircle.RemainTime - 1
                    end
                    if self.poisonWarning.WarningTime and self.poisonWarning.WarningTime > 0 then
                        self.poisonWarning.WarningTime = self.poisonWarning.WarningTime - 1
                    end

                    -- 判断玩家是否在毒圈内
                    if self.poisonCircle.CurPos then
                        local curHurtRatio = self.poisonRatioList[self.poisonCircle.CurRadius]
                        if curHurtRatio then
                            for _, player in ipairs(self.playerList) do
                                local poisonLength = cc.pGetDistance(self.poisonCircle.CurPos, player.CurPos)
                                -- 标记是否正受毒圈伤害
                                player.poisonEff = poisonLength > self.poisonCircle.CurRadius
                                if player.poisonEff then
                                    -- 每秒减去一定比例的血量
                                    for i,heroModelId in ipairs(player.Formations) do
                                        if heroModelId > 0 then
                                            local totalHeroHP = KillervalleyHeroModel.items[heroModelId].HP
                                            player.HPs[i] = player.HPs[i] - totalHeroHP * curHurtRatio
                                            player.HPs[i] = math.max(0, player.HPs[i])
                                        end
                                    end
                                    -- 通知血量改变
                                    Notification:postNotification(KillerValleyHelper.Events.eHPChanged, {PlayerId = player.PlayerId})
                                end
                            end
                        end
                    end

                    -- 道具状态的有效时间变化
                    for _, player in ipairs(self.playerList) do
                        if player.UseGoodsValidTime then
                            for key, time in pairs(player.UseGoodsValidTime) do
                                -- 道具的持续时间不断减少
                                if time > 0 then
                                    player.UseGoodsValidTime[key] = player.UseGoodsValidTime[key] - 1
                                end
                                -- 更新玩家的状态
                                if key == "5" then  -- 强体丹
                                    player.doubleEff = player.UseGoodsValidTime[key] > 0
                                elseif key == "6" then  -- 隐身衣
                                    player.hidingEff = player.UseGoodsValidTime[key] > 0
                                end
                            end
                        end
                    end

                    self.shedulerTick = self.shedulerTick - 1
                end
            end
        end, 0, false)
    end
end

-- 离开比赛
function KillerValleyHelper:leave()
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

function KillerValleyHelper:resetCache()
    -- 清空缓存数据
    self.url = nil
    self.shedulerTick = 0
    self.playerList = {}
    self.selfVisible = true
    self.flyPropList = {}
    self.poisonCircle = {}
    self.poisonWarning = {}
    self.packageInfo = {}
    self.trapInfo = {}
    self.bagGoodsList = {}
end

-- 战场结束，界面关闭时调用此方法，防止数据出错时不断显示战场结算
function KillerValleyHelper:clearUpBattleResult()
    self.battleResultData = nil
end

--[[---------------------------------解析服务端返回的数据---------------------------------------]]

-- 推送类型:首次登陆,推送整个战场的初始信息
--[[
    {
    "InfoName":"BattleInfo",
    "Info:
        {
        "PlayersInfo '类型:([]map[string]interface{})'":
            [
                {
                "Name": "玩家名称" (sting),
                "PlayerId": "玩家id" (string),
                "CurPos" : "玩家当前位置 ([]int32)"       
                "Formations" : "侠客阵容列表"
                "HPs": "侠客当前血量列表"
                }
            ]
        }
    }
--]]
function KillerValleyHelper:battleInfoCallback(data)
    -- 清空缓存
    self:resetCache()
    -- dump(data, "battleInfoCallback")
    self.battleResultData = nil
    -- 开启定时器
    self:scheduleTime()
    -- 构建玩家数据
    self.playerList = data.Info.PlayersInfo or {}
    local selfPId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    for _, player in ipairs(self.playerList) do
        player.CurPos = cc.p(player.CurPos[1], player.CurPos[2])
        player.Angle = player.Angle or -1
        -- 读取玩家的形象
        for _, heroId in ipairs(player.Formations) do
            local heroModel = HeroModel.items[heroId] or {}
            if (heroModel.specialType ~= nil) and (heroModel.specialType == Enums.HeroType.eMainHero) then
                player.ModelId = heroId
                player.ShiZhuangModelId = player.ShiZhuangModelId and player.ShiZhuangModelId or 0
                player.ShiZhuangModelId = player.ShiZhuangModelId == 0 and heroId or player.ShiZhuangModelId
                break
            end
        end
    end
    -- 保存现在地图上的包裹信息
    self.packageInfo = data.Info.PackageInfo or {}
    for _, package in ipairs(self.packageInfo) do
        package.CurPos = cc.p(package.CurPos[1], package.CurPos[2])
    end
    -- 保存背包里的信息
    self.bagGoodsList = data.Info.PlayerGoodsInfo or {}
    -- 保存毒圈信息
    if data.Info.ShrinkageInfo then
        self:poisonCircleCallback({Info={ShrinkageInfo=data.Info.ShrinkageInfo or {}}})
    end
    if data.Info.ShrinkageWarningInfo then
        self:poisonWarningCallback({Info=data.Info.ShrinkageWarningInfo or {}})
    end

    -- 通知进入战场页面
    Notification:postNotification(KillerValleyHelper.Events.eEnterBattle)
    self:autoMatchedNotify()
end

-- 匹配成功提示弹窗
function KillerValleyHelper:autoMatchedNotify()
    local topName = LayerManager.getTopCleanLayerName()
    if not string.find(topName, "killervalley.") then
        local okBtnInfo = {text = TR("进入"), 
            clickAction = function()
                LayerManager.showSubModule(ModuleSub.eKillerValley)
            end}
        MsgBoxLayer.addOKCancelLayer(TR("绝情谷已开启，是否立即进入？"), TR("绝情谷"), okBtnInfo)
    end
end

-- -- 推送类型:玩家发射了道具
function KillerValleyHelper:shotPropCallback(data)
    -- dump(data, "shotPropCallback")
    local dataInfo = data.Info
    dataInfo.StartPos = cc.p(dataInfo.StartPos[1], dataInfo.StartPos[2])
    dataInfo.CurPos = clone(dataInfo.StartPos)
    table.insert(self.flyPropList, dataInfo)
    -- 发射玩家可能需要更新状态(如隐身衣需要去除)
    if dataInfo.UseGoodsValidTime then
        for _,v in ipairs(self.playerList) do
            if v.PlayerId == dataInfo.PlayerId then
                v.UseGoodsValidTime = dataInfo.UseGoodsValidTime
                break
            end
        end
    end
end

-- -- 推送类型:某道具对玩家造成了伤害
function KillerValleyHelper:hurtPlayerCallback(data)
    -- dump(data, "hurtPlayerCallback")
    local dataInfo = data.Info
    -- 通知受伤玩家表现
    Notification:postNotification(KillerValleyHelper.Events.ePlayerStatus, {status = KillerValleyHelper.HeroStatus.eHurt, playerId = dataInfo.HurtPlayerId})
    -- 修改受伤玩家的当前血量
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == dataInfo.HurtPlayerId then
            v.HPs = dataInfo.HurtPlayerHPs
            Notification:postNotification(KillerValleyHelper.Events.eHPChanged, {PlayerId = dataInfo.HurtPlayerId})
            break
        end
    end

    local firePlayerName = self:getPlayerName(dataInfo.FirePlayerId)
    local hurtPlayerName = self:getPlayerName(dataInfo.HurtPlayerId)
    local firePlayerNameColor = self:getPlayerNameColor(dataInfo.FirePlayerId)
    local hurtPlayerNameColor = self:getPlayerNameColor(dataInfo.HurtPlayerId)
    -- 组装推送消息
    if dataInfo.GoodsId then
        if dataInfo.GoodsId == 1 then
            local msgContent = TR("%s%s#ffffff使用飞刀重伤了%s%s#ffffff的一名侠客", firePlayerNameColor, firePlayerName, hurtPlayerNameColor, hurtPlayerName)
            Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
            -- print(TR("%s使用飞刀重伤了%s的一名侠客", firePlayerName, hurtPlayerName))
        elseif dataInfo.GoodsId == 2 then
            local msgContent = TR("%s%s#ffffff丢出冰魄银针，%s%s#ffffff的两名侠客身中剧毒", firePlayerNameColor, firePlayerName, hurtPlayerNameColor, hurtPlayerName)
            Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
            -- print(TR("%s丢出冰魄银针，%s的两名侠客身中剧毒", firePlayerName, hurtPlayerName))
        end
    end
end

-- 推送类型:某玩家使用了陷阱
function KillerValleyHelper:fireTrapCallback(data)
    -- dump(data, "fireTrapCallback")
    local dataInfo = data.Info
    dataInfo.StartPos = cc.p(dataInfo.StartPos[1], dataInfo.StartPos[2])
    -- 添加当前陷阱到列表中
    table.insert(self.trapInfo, dataInfo)

    local firePlayerName = self:getPlayerName(dataInfo.PlayerId)
    local firePlayerNameColor = self:getPlayerNameColor(dataInfo.PlayerId)
    local msgContent = TR("%s%s#ffffff一阵奸笑，悄悄的往地上丢下了一枝情花", firePlayerNameColor, firePlayerName)
    Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
end

-- 推送类型:有玩家踩中了陷阱
function KillerValleyHelper:trapHurtCallback(data)
    -- dump(data, "trapHurtCallback")
    local dataInfo = data.Info
    -- 通知受伤玩家表现
    Notification:postNotification(KillerValleyHelper.Events.ePlayerStatus, {status = KillerValleyHelper.HeroStatus.eTrap, playerId = dataInfo.HurtPlayerId})
    -- 修改受伤玩家的当前血量
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == dataInfo.HurtPlayerId then
            v.HPs = dataInfo.HurtPlayerHPs
            Notification:postNotification(KillerValleyHelper.Events.eHPChanged, {PlayerId = dataInfo.HurtPlayerId})
            break
        end
    end

    local firePlayerName = self:getPlayerName(dataInfo.FirePlayerId)
    local hurtPlayerName = self:getPlayerName(dataInfo.HurtPlayerId)
    local firePlayerNameColor = self:getPlayerNameColor(dataInfo.FirePlayerId)
    local hurtPlayerNameColor = self:getPlayerNameColor(dataInfo.HurtPlayerId)
    local msgContent = TR("%s%s#ffffff一不小心踩中了%s%s#ffffff丢在地上的情花刺，一名侠客身受重伤", hurtPlayerNameColor, hurtPlayerName, firePlayerNameColor, firePlayerName)
    Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
end

-- -- 推送类型:某玩家使用了道具
function KillerValleyHelper:useGoodsCallback(data)
    -- dump(data, "useGoodsCallback")
    local dataInfo = data.Info
    local statusEvent = nil
    if dataInfo.GoodsId == 5 then   -- 强体丹
        statusEvent = KillerValleyHelper.HeroStatus.eAttrDouble
    elseif dataInfo.GoodsId == 6 then -- 夜行衣
        statusEvent = KillerValleyHelper.HeroStatus.eHiding
    elseif dataInfo.GoodsId == 7 then -- 九花玉露丸
        statusEvent = KillerValleyHelper.HeroStatus.eBlood
        -- 更新使用道具的玩家血量并通知改变
        for _, player in ipairs(self.playerList) do
            if player.PlayerId == dataInfo.PlayerId then
                player.HPs = dataInfo.HPs
                Notification:postNotification(KillerValleyHelper.Events.eHPChanged, {PlayerId = dataInfo.PlayerId})
                break
            end
        end
    end
    if statusEvent then
        Notification:postNotification(KillerValleyHelper.Events.ePlayerStatus, 
            {status = statusEvent, playerId = dataInfo.PlayerId, visible = true})
    end
    -- 修改玩家的CD时间
    if dataInfo.UseGoodsValidTime then
        for _, player in ipairs(self.playerList) do
            if player.PlayerId == dataInfo.PlayerId then
                player.UseGoodsValidTime = dataInfo.UseGoodsValidTime
                -- 修改对应玩家的状态
                for key, time in pairs(player.UseGoodsValidTime) do
                    if key == "5" then  -- 强体丹
                        player.doubleEff = time > 0
                    elseif key == "6" then  -- 隐身衣
                        player.hidingEff = time > 0
                    end
                end
                break
            end
        end
    end
end

-- -- 推送类型:某玩家死亡
function KillerValleyHelper:deadInfoCallback(data)
    -- dump(data, "deadInfoCallback")
    local dataInfo = data.Info
    -- 删除死亡玩家的列表
    local deadPlayerName = nil
    for i, player in ipairs(self.playerList) do
        if player.PlayerId == dataInfo.PlayerId then
            deadPlayerName = player.Name
            table.remove(self.playerList, i)
            break
        end
    end
    -- 添加死亡玩家的落地包裹
    dataInfo.PackageInfo.CurPos = cc.p(dataInfo.PackageInfo.CurPos[1], dataInfo.PackageInfo.CurPos[2])
    table.insert(self.packageInfo, dataInfo.PackageInfo)

    -- 死亡消息通知
    if deadPlayerName and dataInfo.DeadEnum == 1 then
        local msgContent = TR("情花瘴太过浓烈，%s%s#ffffff中毒而亡", self:getPlayerNameColor(dataInfo.PlayerId), deadPlayerName)
        Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
    end
    -- 通知死亡玩家ID
    Notification:postNotification(KillerValleyHelper.Events.ePlayerDeath, {playerId = dataInfo.PlayerId, playerName = deadPlayerName})
end

-- 推送类型:包裹被捡
function KillerValleyHelper:pickUpCallback(data)
    -- dump(data, "pickUpCallback")
    local dataInfo = data.Info
    for i,package in ipairs(self.packageInfo) do
        if package.UniqueId == dataInfo.UniqueId then
            if #dataInfo.GoodsId == 0 then
                -- 道具列表为空表示删除此包裹
                table.remove(self.packageInfo, i)
            else
                package.GoodsId = dataInfo.GoodsId
            end
            break
        end
    end
end

-- 推送类型:战斗结果信息
--[[
{
    "InfoName":"FightResult",
    "Info '类型: map[string]interface{}'":
        {
        "attackPlayerId" = "bfbe100b-f828-41f7-9b45-c02ae282cd99",
        "targetPlayerId" = "209f1687-9d32-47db-a4b0-f18ba873b818",
        "isWin" = false,
        "Goods" = {"1" = 10,},
        "HPs" = {
            1 = 1226140,
            2 = 0,
            3 = 0,
            4 = 0,
            5 = 0,
            6 = 0,
            7 = 0,
        },
    }
}
--]]
function KillerValleyHelper:fightResultCallback(data)
    -- dump(data, "fightResultCallback")
    local dataInfo = data.Info
    local winPlayerId = dataInfo.isWin and dataInfo.attackPlayerId or dataInfo.targetPlayerId
    local losePlayerId = dataInfo.isWin and dataInfo.targetPlayerId or dataInfo.attackPlayerId
    -- 查找战斗双方的名字
    local winPlayerName = self:getPlayerName(winPlayerId)
    local losePlayerName = self:getPlayerName(losePlayerId)
    local winPlayerNameColor = self:getPlayerNameColor(winPlayerId)
    local losePlayerNameColor = self:getPlayerNameColor(losePlayerId)
    -- 战斗成功的玩家修改阵容数据
    for _, player in ipairs(self.playerList) do
        if player.PlayerId == winPlayerId then
            player.HPs = dataInfo.HPs
            -- 通知玩家的血量变化
            Notification:postNotification(KillerValleyHelper.Events.eHPChanged, {PlayerId = winPlayerId})
            break
        end
    end
    -- 攻击方修改buff时间，显示隐身衣
    for _, player in ipairs(self.playerList) do
        if player.PlayerId == dataInfo.attackPlayerId then
            player.UseGoodsValidTime = dataInfo.UseGoodsValidTime
            break
        end
    end
    -- 通知玩家事件, 击败消息显示在死亡之前
    local msgContent = TR("%s%s#ffffff击败了%s%s", winPlayerNameColor, winPlayerName, losePlayerNameColor, losePlayerName)
    Notification:postNotification(KillerValleyHelper.Events.eNoticeMsg, msgContent)
    -- 玩家死亡事件处理，自己也显示盒子
    self:deadInfoCallback({Info = {PlayerId = losePlayerId, PackageInfo = dataInfo.PackageInfo}})
end

-- 推送类型:推送生成毒圈信息，Enum(1.将包，2.生成的道具包，3.玩家掉落包)
--[[
    {
    "InfoName":"ShrinkageInfo",
    "Info:
        {
        "ShrinkageInfo '毒圈信息  类型:(map[string]interface{})'":
            {
            "RemainTime": "有效时间 (int32)"
            "CurPos": "毒圈圆心([2]int32)",
            "CurRadius": "半径 (int32)",
            }
        "PackageInfo '包裹信息  类型:([]map[string]interface{})'":
            [
                {
                "UniqueId": "包裹唯一id (sting)",
                "GoodsId": "道具id集合 ([]int32)",
                "CurPos" : "道具产生地点([]int32)"        
                "Enum": "包裹枚举类型 int32"
                }
            ]
        }
    }
--]]
function KillerValleyHelper:poisonCircleCallback(data)
    -- dump(data, "poisonCircleCallback")
    self.poisonCircle = data.Info.ShrinkageInfo
    self.poisonCircle.CurPos = cc.p(self.poisonCircle.CurPos[1], self.poisonCircle.CurPos[2])
    Notification:postNotification(KillerValleyHelper.Events.ePoisonCircle)

    -- 毒圈会刷新包裹
    if data.Info.PackageInfo then
        self.packageInfo = data.Info.PackageInfo
        for _, package in ipairs(self.packageInfo) do
            package.CurPos = cc.p(package.CurPos[1], package.CurPos[2])
        end
    end
end

-- 推送类型:推送毒圈警告信息
--[[
    {
    "InfoName":"ShrinkageWarningInfo",
    "Info '类型: map[string]interface{}'":
        {
        "NextPos": "要生成的毒圈圆心([2]int32)",
        "NextRadius": "要生成的半径 (int32)",
        "WarningTime": "警告时间(int32)",
        }
    }
--]]
function KillerValleyHelper:poisonWarningCallback(data)
    -- dump(data, "poisonWarningCallback")
    self.poisonWarning = data.Info
    self.poisonCircle.RemainTime = self.poisonWarning.WarningTime
    self.poisonWarning.NextPos = cc.p(self.poisonWarning.NextPos[1], self.poisonWarning.NextPos[2])
    Notification:postNotification(KillerValleyHelper.Events.ePoisonWarning)
end

-- 推送类型:推送玩家移动信息
--[[
    {
    "InfoName":"MoveInfo",
    "Info '类型: map[string]interface{}'":
        {
        "PlayerId": "玩家id (int)",
        "CurPos": "玩家当前坐标 ([2]int)",
        "Angle": "玩家要移动角度 (int)"
        }
    }
--]]
function KillerValleyHelper:moveInfoCallback(data)
    -- dump(data, "moveInfoCallback")
    local moveData = data.Info
    -- 修改其它人物的移动信息
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == moveData.PlayerId then
            v.CurPos = cc.p(moveData.CurPos[1], moveData.CurPos[2])
            v.Angle = moveData.Angle
            break
        end
    end
end

-- 推送类型:刷新玩家的信息
--[[
    {
    "InfoName":"FormationInfo",
    "Info '类型: map[string]interface{}'":
        {
        "PlayerId": "玩家id (int)",
        "Formations": "玩家阵容列表[7]",
        "HPs": "玩家的血量列表[7]"
        }
    }
--]]
function KillerValleyHelper:formationInfoCallback(data)
    local playerData = data.Info
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == playerData.PlayerId then
            v.HPs = playerData.HPs
            v.Formations = playerData.Formations
            -- 通知玩家的血量变化
            Notification:postNotification(KillerValleyHelper.Events.eHPChanged, {PlayerId = v.PlayerId})
            break
        end
    end

    -- 如果是捡到了侠客，则弹出布阵界面（只有自己的才需要弹，因为别人布阵自己也会收到消息）
    if (playerData.IsPickUp ~= nil) and (playerData.IsPickUp == true) and (playerData.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
        ui.showFlashView(TR("恭喜您捡到了一个探子，已自动上阵"))

        -- 判断第7个阵位是否有侠客，没有就不弹
        local tmpModelId = playerData.Formations[7]
        if (tmpModelId ~= nil) and (tmpModelId > 0) then
            LayerManager.addLayer({name = "killervalley.DlgSetCampLayer", cleanUp = false})
        end
    end
end

-- 推送类型:刷新玩家的血量
function KillerValleyHelper:allFormationInfoCallback(data)
    for _,playerInfo in ipairs(data.Info.PlayersInfo) do
        local tmpInfo = clone(playerInfo)
        tmpInfo.IsPickUp = false
        self:formationInfoCallback({Info = tmpInfo})
    end
end

-- 推送类型:战场结束
function KillerValleyHelper:battleResultCallback(data)
    -- dump(data, "battleResultCallback")
    self:resetCache()
    self.battleResultData = data.Info
    Notification:postNotification(KillerValleyHelper.Events.eBattleResult)

    -- 断开网络连接
    self:leave()
end

-- --[[---------------------------------KillerValleyHelper数值获取接口---------------------------------------]]

-- 获取包裹里的所有道具数量
function KillerValleyHelper:getBagPropCount()
    local nCount = 0
    for _,v in pairs(self.bagGoodsList or {}) do
        nCount = nCount + tonumber(v)
    end
    return nCount
end

-- 获取包裹剩余的空闲格子数量
function KillerValleyHelper:getBagEmptyCount()
    local emptyCount = self.maxBagCount - self:getBagPropCount()
    if (emptyCount < 0) then
        emptyCount = 0
    end
    return emptyCount
end

-- 添加一个道具
function KillerValleyHelper:addOneProp(modelId)
    local nowCount = self.bagGoodsList[tostring(modelId)]
    if (nowCount == nil) then
        nowCount = 0
    end
    self.bagGoodsList[tostring(modelId)] = (nowCount + 1)
end

-- 删除一个道具
function KillerValleyHelper:delOneProp(modelId)
    local nowCount = self.bagGoodsList[tostring(modelId)]
    if (nowCount == nil) or (nowCount == 0) then
        return
    end
    self.bagGoodsList[tostring(modelId)] = (nowCount - 1)
end

-- --[[---------------------------------set接口---------------------------------------]]

function KillerValleyHelper:setUrl(newUrl)
    if (self.url ~= newUrl) then
        self.url = newUrl
    end
end

function KillerValleyHelper:setSelfVisible(visible)
    self.selfVisible = visible
end

-- 返回指定玩家的数据信息，参数为空时返回自己的信息
function KillerValleyHelper:getPlayerData(playerId)
    playerId = playerId or PlayerAttrObj:getPlayerAttrByName("PlayerId")
    for _,v in ipairs(self.playerList) do
        if v.PlayerId == playerId then
            return clone(v)
        end
    end
end

-- --[[---------------------------------KillerValleyHelper功能区---------------------------------------]]

-- 取消匹配
function KillerValleyHelper:cancelMatch(callFunc, errorFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "Cancel", Parameters = {}}, callFunc)
        return true
    else
        ui.showFlashView(TR("连接已断开"))
        return false
    end
end

-- 玩家移动(资源点)
function KillerValleyHelper:playerMove(angle, callFunc)
    if (self.socketMgr ~= nil) then
        local curPos = nil
        for _,pInfo in ipairs(self.playerList) do
            if pInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                -- 移动状态变化时才调用接口
                if pInfo.Angle ~= angle then
                    pInfo.Angle = angle
                    curPos = pInfo.CurPos
                end
                break
            end
        end
        if curPos then
            self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "Move", Parameters = {math.floor(curPos.x), math.floor(curPos.y), angle}}, callFunc)
        end
    end
end

-- 玩家发射暗器
-- pId:道具的模型ID
function KillerValleyHelper:shotProp(pId, angle)
    if (self.socketMgr ~= nil) then
        local startPos = nil
        for i, pInfo in ipairs(self.playerList) do
            if pInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                startPos = cc.p(pInfo.CurPos.x , pInfo.CurPos.y + self.playerBoxSize.height / 2)
                break
            end
        end
        -- 更新道具的数量
        local function shotActionCallback(retValue)
            if retValue.Code == 0 then
                for key,count in pairs(self.bagGoodsList) do
                    if tonumber(key) == pId and self.bagGoodsList[key] > 0 then
                        self.bagGoodsList[key] = self.bagGoodsList[key] - 1
                        break
                    end
                end
            end
        end
        if startPos then
            self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "ShotProp", Parameters = {pId, {math.floor(startPos.x), math.floor(startPos.y)}, angle}}, shotActionCallback)
        end
    end
end

-- 对玩家造成伤害
-- uId:道具的唯一ID
function KillerValleyHelper:hurtPlayer(ownPlayerId, hurtPlayerId, uId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "HurtPlayer", Parameters = {ownPlayerId, hurtPlayerId, uId}}, callFunc)
    end
end

-- 挑战玩家
function KillerValleyHelper:fightWithEnemy(playerId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "Fight", Parameters = {playerId}}, callFunc)
    end
end

-- 拾取道具
function KillerValleyHelper:pickupProp(packageId, goodList, callFunc)
    if (self.socketMgr ~= nil) then
        goodList = goodList or {-1}
        local retCallFunc = callFunc
        local function pickupCallFunc(retValue)
            if retValue.Code == -10003 then
                -- 包裹不存在时，直接删除此包裹
                for i,package in ipairs(self.packageInfo) do
                    if package.UniqueId == packageId then
                        table.remove(self.packageInfo, i)
                        break
                    end
                end
            end
            if retCallFunc then
                retCallFunc(retValue)
            end
        end
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "PickUp", Parameters = {packageId, goodList}}, pickupCallFunc)
    end
end

-- 使用道具
function KillerValleyHelper:useProp(modelId, callFunc)
    -- 如果自己死了就忽略掉操作
    if (self:getPlayerData() == nil) then
        return
    end

    if (self.socketMgr ~= nil) then
        if modelId == 3 or modelId == 4 then
            -- 陷阱单独的使用接口
            self:fireTrap(modelId, callFunc)
        else
            self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "UseGoods", Parameters = {modelId}}, callFunc)
        end
    end
end

-- 丢弃道具
function KillerValleyHelper:dropProp(modelId, callFunc)
    -- 如果自己死了就忽略掉操作
    if (self:getPlayerData() == nil) then
        return
    end

    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "DropGoods", Parameters = {modelId}}, callFunc)
    end
end

-- 获取玩家的布阵
function KillerValleyHelper:getFormation(playerId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "GetFormation", Parameters = {playerId}}, callFunc)
    end
end

-- 调整玩家的布阵
function KillerValleyHelper:changeFormation(newFormationList, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "ChangeFormation", Parameters = {cjson.encode(newFormationList)}}, callFunc)
    end
end

-- 释放陷阱
function KillerValleyHelper:fireTrap(goodsId, callFunc)
    if (self.socketMgr ~= nil) then
        local selfData = self:getPlayerData()
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "FireTrap", Parameters = {goodsId, {selfData.CurPos.x, selfData.CurPos.y}}}, callFunc)
    end
end

-- 陷阱伤害
function KillerValleyHelper:trapHurt(ownPlayerId, hurtPlayerId, uId, callFunc)
    if (self.socketMgr ~= nil) then
        self.socketMgr:sendMessage({ModuleName = "KillerValley", MethodName = "TrapHurt", Parameters = {ownPlayerId, hurtPlayerId, uId}}, callFunc)
    end
end

-- --[[---------------------------------KillerValleyHelper辅助接口---------------------------------------]]

-- 获取指定PlayerId对应的名字
function KillerValleyHelper:getPlayerName(playerId)
    for _,v in ipairs(self.playerList or {}) do
        if v.PlayerId == playerId then
            return v.Name
        end
    end
    return ""
end

-- 判断线段是否与矩形相交
function KillerValleyHelper:isLineRectIntersect(startPos, endPos, rect)
    -- 判断2条线段是否相交
    local function isLineSegmentsIntersect(p0_x, p0_y, p1_x, p1_y, p2_x, p2_y, p3_x, p3_y)
        local s1_x, s1_y, s2_x, s2_y;
        s1_x = p1_x - p0_x
        s1_y = p1_y - p0_y
        s2_x = p3_x - p2_x
        s2_y = p3_y - p2_y
    
        local m = (-s2_x * s1_y + s1_x * s2_y)
        if m ~= 0 then
            local s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / m
            local t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / m
            return s >= 0 and s <= 1 and t >= 0 and t <= 1
        end
        return false
    end

    local x1, x2, y1, y2 = rect.x, rect.x + rect.width, rect.y, rect.y + rect.height
    local min_x=math.min(startPos.x,endPos.x)
    local max_x=math.max(startPos.x,endPos.x)
    local min_y=math.min(startPos.y,endPos.y)
    local max_y=math.max(startPos.y,endPos.y)
    if (min_x >= x1 and max_x <= x2 and min_y >= y1 and max_y <= y2) then
        -- 线段在矩形内
        return true
    else
        local pointList = {cc.p(x1, y1), cc.p(x2, y1), cc.p(x2, y2), cc.p(x1, y2)}
        for i=1, #pointList do
            -- 判断是否与矩形线段相交
            local p2, p3 = pointList[i], pointList[(i % 4) + 1]
            if isLineSegmentsIntersect(startPos.x, startPos.y, endPos.x, endPos.y, p2.x, p2.y, p3.x, p3.y) then
                return true
            end
        end
    end
    return false
end

-- 根据玩家ID返回滚动时玩家名字显示的颜色
function KillerValleyHelper:getPlayerNameColor(playerId)
    if not playerId then 
        return "#faab00"
    end 
    
    return PlayerAttrObj:isPlayerSelf(playerId) and "#00ffe4" or "#faab00"
end