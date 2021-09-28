--[[
    文件名: IcefireMapLayer.lua
    描述: 冰火岛大地图
    创建人: yanghongsheng
    创建时间: 2019.07.22
-- ]]
local IcefireMapLayer = class("IcefireMapLayer", function(params)
    return display.newLayer()
end)

--[[
    参数:
--]]
function IcefireMapLayer:ctor(params)
    self.playerNodes = {}
    self.bossNodes = {}
    self.selfPlayerNode = nil
    --父节点标准层
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --返回按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1080),
        clickAction = function ()
            -- 断开连接
            IcefireHelper:leave()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn, 1)
    --规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(50, 1080),
        clickAction = function ()
            MsgBoxLayer.addRuleHintLayer("规则",
            {
                TR("1.每天可消耗神行值进入冰火岛中探索。"),
                TR("2.击败冰火岛中的守卫和护法可获得宝石奖励，护法获得高级奖励概率更高。"),
                TR("3.冰火岛之中可以与全服玩家组队一同探索。"),
                TR("4.每次发起攻击消耗20点神行值。"),
            })
        end
    })
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 频道
    local channelBgSize = cc.size(355, 45)
    local channelBg = ui.newScale9Sprite("c_25.png", channelBgSize)
    channelBg:setPosition(320, 1080)
    self.mParentLayer:addChild(channelBg, 1)
    local channelLabel = ui.newLabel({
        text = TR("冰火岛频道%s", IcefireHelper.ownPlayerInfo.ChannelId),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    channelLabel:setPosition(channelBgSize.width*0.5, channelBgSize.height*0.5)
    channelBg:addChild(channelLabel)

    -- 神行值显示
    self.mActionNumLabel = ui.newLabel({
        text = TR("神行值：%s", IcefireHelper.ownPlayerInfo.ActionNum),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    self.mActionNumLabel:setPosition(320, 1000)
    self.mParentLayer:addChild(self.mActionNumLabel, 1)

    -- 神行值添加按钮
    self.mActionAddBtn = ui.newButton({
        normalImage = "c_21.png",
        clickAction = function ()
            self:createAddActionBox()
        end
    })
    local x,y = self.mActionNumLabel:getPosition()
    self.mActionAddBtn:setPosition(x+self.mActionNumLabel:getContentSize().width*0.5+30, y)
    self.mParentLayer:addChild(self.mActionAddBtn, 1)

    -- 神行值恢复倒计时
    self.mActionNextLabel = ui.newLabel({
        text = "",
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    self.mActionNextLabel:setPosition(320, 960)
    self.mParentLayer:addChild(self.mActionNextLabel, 1)
    -- 神行值恢复倒计时
    self:createActionUpdate()

    -- 查看申请
    local lookReqBtn = ui.newButton({
        normalImage = "tb_148.png",
        -- text = TR("查看申请"),
        clickAction = function ( ... )
            LayerManager.addLayer({name = "ice.IcefireJoinTeamReqLayer", cleanUp = false})
        end
    })
    lookReqBtn:setPosition(570, 450)
    self.mParentLayer:addChild(lookReqBtn, 1)
    self.mLookReqBtn = lookReqBtn
    -- 组队加成
    self.mTeamAddLabel = ui.newLabel({
        text = "",
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        dimensions = cc.size(120, 0),
    })
    self.mTeamAddLabel:setAnchorPoint(cc.p(1, 0))
    self.mParentLayer:addChild(self.mTeamAddLabel, 1)

    -- 创建队伍信息
    self:createTeamHeads()

    -- 创建地图背景
    self:createBigMap()

    -- 创建所有人物
    self:createAllHeros()
    -- 创建所有boss
    self:createAllBoss()

    -- 添加地图更新事件
    Utility.schedule(self.mParentLayer, handler(self, self.updateWorldSchedule), 0)

    -- 注册玩家移动事件
    Notification:registerAutoObserver(self, function (node, moveInfo)
        self:playerMove(moveInfo)
    end, {IcefireHelper.Events.ePlayerMove})
    -- 注册玩家加入事件
    Notification:registerAutoObserver(self, function (node, playerInfo)
        self:addPlayer(playerInfo)
    end, {IcefireHelper.Events.eAddOneHero})
    -- 注册玩家退出事件
    Notification:registerAutoObserver(self, function (node, playerInfo)
        self:deletePlayer(playerInfo)
    end, {IcefireHelper.Events.eDeleteOneHero})
    -- 注册boss刷新事件
    Notification:registerAutoObserver(self, function (node, bossInfo)
        self:createOneBoss(bossInfo)
    end, {IcefireHelper.Events.eCreateOneBoss})
    Notification:registerAutoObserver(self, function (node, bossInfo)
        self:deleteOneBoss(bossInfo)
    end, {IcefireHelper.Events.eDeleteOneBoss})
    -- 注册刷新玩家自己信息
    Notification:registerAutoObserver(self, function (node)
        self:refreshOwnPlayer()
    end, {IcefireHelper.Events.eRefreshOwnInfo})
    -- 注册刷新所有玩家
    Notification:registerAutoObserver(self, function (node)
        self:createAllHeros()
        self:createAllBoss()
        self:refreshOwnPlayer()
    end, {IcefireHelper.Events.eRefreshAllPlayers})
end

--创建地图
function IcefireMapLayer:createBigMap()
    -- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.both)
    worldView:setSwallowTouches(false)
    -- worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.mWorldView = worldView

    -- 创建背景
    local bgSprite = ui.newSprite("bhd_1.jpg")
    bgSprite:setAnchorPoint(0, 0)
    bgSprite:setPosition(0, 0)
    self.mWorldView:setInnerContainerSize(bgSprite:getContentSize())
    self.mWorldView:addChild(bgSprite, -2)
    self.mMapBg = bgSprite
    self.mMapSize = bgSprite:getContentSize()

    -- 创建移动触摸监听
    self.isTouchScrolled = false
    self.touchedPos = nil
    --设置能触摸
    self:setTouchEnabled(true)
    local onTouchsEvent = function(eventType, touch)
        --[[
            eventType:触摸事件类型.
            touchs:多点触摸的数组表，它的大小=n点触摸*3
        ]]

        if eventType == "began" then
            self.isTouchScrolled = false
            self.touchedPos = cc.p(touch[1], touch[2])

            self.touchedPos = self.mMapBg:convertToNodeSpace(self.touchedPos)

            if self.touchedPos and not self.isMoveCdTime then
                -- 队长才能移动
                if IcefireHelper.ownPlayerInfo.LeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    ui.showFlashView(TR("队长才能移动"))
                    return
                end

                print("调移动".."("..self.touchedPos.x..","..self.touchedPos.y..")")
                IcefireHelper:playerMove(self.touchedPos)
                -- 播放点击特效
                ui.newEffect({
                    parent = self.mMapBg,
                    effectName = "effect_ui_dianji",
                    zorder = 1,
                    position = self.touchedPos,
                    loop = false,
                    endRelease = true,
                })
                -- 进入移动cd时间（防止频繁点击移动）
                self.isMoveCdTime = true
                Utility.performWithDelay(self.mMapBg, function ()
                    self.isMoveCdTime = false
                end, 0.5)
            end

            return true
        end
    end
    self:registerScriptTouchHandler(onTouchsEvent, true)

    -- ui.registerSwallowTouch({
    --     node = self.mMapBg,
    --     allowTouch = false,
    --     beganEvent = function (touch, event)
    --         self.isTouchScrolled = false
    --         self.touchedPos = touch:getLocation()

    --         self.touchedPos = self.mMapBg:convertToNodeSpace(self.touchedPos)

    --         return true
    --     end,
    --     movedEvent = function (touch, event)
    --         local movedPos = touch:getLocation()
    --         -- 如移动距离过大，则认为是滑动事件
    --         if self.touchedPos and cc.pGetLength(cc.pSub(movedPos, self.touchedPos)) > 8 then
    --             self.isTouchScrolled = true
    --         end
    --     end,
    --     endedEvent = function (touch, event)
    --         if self.touchedPos and not self.isTouchScrolled and not self.isMoveCdTime then
    --             -- 队长才能移动
    --             if IcefireHelper.ownPlayerInfo.LeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
    --                 ui.showFlashView(TR("队长才能移动"))
    --                 return
    --             end

    --             print("调移动".."("..self.touchedPos.x..","..self.touchedPos.y..")")
    --             IcefireHelper:playerMove(self.touchedPos)
    --             -- 播放点击特效
    --             ui.newEffect({
    --                 parent = self.mMapBg,
    --                 effectName = "effect_ui_dianji",
    --                 zorder = 1,
    --                 position = self.touchedPos,
    --                 loop = false,
    --                 endRelease = true,
    --             })
    --             -- 进入移动cd时间（防止频繁点击移动）
    --             self.isMoveCdTime = true
    --             Utility.performWithDelay(self.mMapBg, function ()
    --                 self.isMoveCdTime = false
    --             end, 1)
    --         end
    --     end,
    -- })
end

-- 创建队伍玩家头像显示
function IcefireMapLayer:createTeamHeads()
    -- 创建头像父节点
    if not self.mTeamHeadParent then
        self.mTeamHeadParent = cc.Node:create()
        self.mParentLayer:addChild(self.mTeamHeadParent, 1)
    end
    -- 删除头像显示
    self.mTeamHeadParent:removeAllChildren()

    -- 队伍成员
    local teamPlayerList = string.splitBySep(IcefireHelper.ownPlayerInfo.TeamPlayerIdList or "", ",")
    -- 剔除自己
    for i, playerId in pairs(teamPlayerList) do
        if playerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            table.remove(teamPlayerList, i)
            break
        end
    end

    -- 是否显示查看申请
    self.mLookReqBtn:setVisible(IcefireHelper.ownPlayerInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))
    self.mTeamAddLabel:setString("")

    -- 无队伍
    if not next(teamPlayerList) then return end
    -- 是否是队长
    local isHead = IcefireHelper.ownPlayerInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
    -- 创建队伍玩家头像
    for i, playerId in ipairs(teamPlayerList) do
        local playerInfo = IcefireHelper:getPlayerData(playerId)
        -- 头像
        local headCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = playerInfo.HeadImageId,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = true,
            onClickCallback = function ()
                LayerManager.addLayer({name = "ice.IcefirePlayerInfoLayer", data = {playerId = playerInfo.PlayerId, msgType = isHead and 2 or 3}, cleanUp = false})
            end
        })
        headCard:setPosition(570, i*110)
        self.mTeamHeadParent:addChild(headCard)
    end
    -- 创建退出队伍按钮
    if not isHead then
        local quitTeamBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("退出队伍"),
            clickAction = function ()
                IcefireHelper:quitTeam()
            end
        })
        quitTeamBtn:setPosition(570, #teamPlayerList*110+80)
        self.mTeamHeadParent:addChild(quitTeamBtn)
    else
        local quitTeamBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("解散队伍"),
            clickAction = function ()
                IcefireHelper:cancelTeam()
            end
        })
        quitTeamBtn:setPosition(570, #teamPlayerList*110+80)
        self.mTeamHeadParent:addChild(quitTeamBtn)
    end

    -- 组队加成
    local addR = IcefireTeamaddModel.items[#teamPlayerList+1].addR
    addR = (addR/10000-1)*100
    if addR > 0 then
        self.mTeamAddLabel:setString(TR("组队奖励加成#ffe748%s%%", addR))
    end
    self.mTeamAddLabel:setPosition(630, #teamPlayerList*110+80+30)
end

-- 创建所有人物
function IcefireMapLayer:createAllHeros()
    -- 创建其他玩家
    for _,pInfo in ipairs(IcefireHelper.playerList) do
        self:createOneHero(pInfo)
    end
    -- 创建自己
    self:createOneHero(IcefireHelper.ownPlayerInfo)
end

-- 创建所有boss
function IcefireMapLayer:createAllBoss()
    for _,bInfo in ipairs(IcefireHelper.bossList) do
        self:createOneBoss(bInfo)
    end
end

-- 创建一个玩家节点
function IcefireMapLayer:createOneHero(heroInfo)
    -- 删除原来节点
    if self.playerNodes[heroInfo.PlayerId] and not tolua.isnull(self.playerNodes[heroInfo.PlayerId]) then
        self.playerNodes[heroInfo.PlayerId]:removeFromParent()
        self.playerNodes[heroInfo.PlayerId] = nil
    end

    local heroNode = IcefireHelper.createHeroNode(heroInfo)
    self.mMapBg:addChild(heroNode)
    self.playerNodes[heroInfo.PlayerId] = heroNode
    -- 当前坐标
    local pos = cc.p(heroInfo.CurPos[1], heroInfo.CurPos[2])
    heroNode:setPosition(pos)
    -- 移动
    if heroInfo.TargetPos then
        heroNode:move(pos, cc.p(heroInfo.TargetPos[1], heroInfo.TargetPos[2]))
    else
        heroNode:move(pos, pos)
    end
    -- 保存自身结点
    if PlayerAttrObj:getPlayerAttrByName("PlayerId") == heroInfo.PlayerId then
        self.selfPlayerNode = heroNode
        -- 地图移动到自己这儿
        local viewPercent = cc.p((pos.x - 320)/24, (self.mMapSize.height - pos.y - 568)/18)
        self.mWorldView:scrollToPercentBothDirection(viewPercent, 0, true)
    end
end

-- 删除一个玩家节点
function IcefireMapLayer:deleteOneHero(heroInfo)
    if self.playerNodes[heroInfo.PlayerId] then
        self.playerNodes[heroInfo.PlayerId]:removeFromParent()
        self.playerNodes[heroInfo.PlayerId] = nil
    end
end

-- 创建一个boss节点
function IcefireMapLayer:createOneBoss(bossInfo)
    local pos = string.splitBySep(bossInfo.Location, ",")
    pos = cc.p(tonumber(pos[1]), tonumber(pos[2]))

    local bossNode = IcefireHelper.createBossNode(bossInfo, function ()
        -- 队长才能打怪
        if IcefireHelper.ownPlayerInfo.LeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            ui.showFlashView(TR("队长才能打怪"))
            return
        end
        -- 判断距离
        local playerPos = cc.p(self.selfPlayerNode:getPosition())
        local length = cc.pGetLength(cc.pSub(playerPos, pos))
        if length > IcefireConfig.items[1].battleDistance then
            ui.showFlashView(TR("距离太远了！"))
            local distance = IcefireConfig.items[1].battleDistance*0.5
            local disv = cc.p(playerPos.x - pos.x, playerPos.y - pos.y)
            local dis = math.sqrt(disv.x * disv.x + disv.y * disv.y)
            local stepNum = math.ceil(dis / distance)
            local stepX = (pos.x - playerPos.x) / stepNum
            local stepY = (pos.y - playerPos.y) / stepNum
            local tempPos = cc.p(pos.x, pos.y)
            tempPos.x = pos.x - stepX
            tempPos.y = pos.y - stepY
            -- 玩家移动到boss位置
            IcefireHelper:playerMove(tempPos)
            return
        end
        -- 神行值不足
        local needActionNum = IcefireBossModel.items[bossInfo.BossId].needActionNum
        if IcefireHelper.ownPlayerInfo.ActionNum < needActionNum then
            ui.showFlashView(TR("神行值不足！"))
            return
        end

        
        -- 进入打bosscd时间（防止频繁点击移动）
        if self.isAttackCdTime then
            ui.showFlashView(TR("正在攻击，请等待战斗结果"))
            return
        end
        
        self.isAttackCdTime = true
        Utility.performWithDelay(self.mMapBg, function ()
            self.isAttackCdTime = false
        end, 1)
        -- 挑战boss
        IcefireHelper:challengeNpc(bossInfo.Id)
    end)
    bossNode:setPosition(pos)
    self.mMapBg:addChild(bossNode)

    self.bossNodes[bossInfo.Id] = bossNode
end

-- 删除一个boss节点
function IcefireMapLayer:deleteOneBoss(bossInfo)
    if self.bossNodes[bossInfo.Id] then
        self.bossNodes[bossInfo.Id]:removeFromParent()
        self.bossNodes[bossInfo.Id] = nil
    end
end

-- 时时刷新地图信息
function IcefireMapLayer:updateWorldSchedule()
    -- 刷新地图上玩家和boss层级
    for _, playerNode in pairs(self.playerNodes) do
        local y = playerNode:getPositionY()
        playerNode:setLocalZOrder(self.mMapSize.height-y)
    end
    for _, bossNode in pairs(self.bossNodes) do
        local y = bossNode:getPositionY()
        bossNode:setLocalZOrder(self.mMapSize.height-y)
    end

    -- 刷新视角
    local pos = cc.p(self.selfPlayerNode:getPosition())
    local viewPercent = cc.p((pos.x - 320)/24, (self.mMapSize.height - pos.y - 568)/18)
    self.mWorldView:scrollToPercentBothDirection(viewPercent, 0, true)
end

-- 玩家移动回调
function IcefireMapLayer:playerMove(moveInfo)
    if self.playerNodes[moveInfo.PlayerId] then
        self.playerNodes[moveInfo.PlayerId]:move(cc.p(moveInfo.CurPos[1], moveInfo.CurPos[2]), cc.p(moveInfo.TargetPos[1], moveInfo.TargetPos[2]))
    end
end

-- 玩家加入回调
function IcefireMapLayer:addPlayer(playerInfo)
    self:createOneHero(playerInfo)
end

-- 玩家退出回调
function IcefireMapLayer:deletePlayer(playerInfo)
    self:deleteOneHero(playerInfo)
end

-- 刷新玩家自己信息
function IcefireMapLayer:refreshOwnPlayer()
    -- 刷新神行值显示
    self.mActionNumLabel:setString(TR("神行值：%s", IcefireHelper.ownPlayerInfo.ActionNum))
    -- 刷新位置
    local pos = cc.p(IcefireHelper.ownPlayerInfo.CurPos[1], IcefireHelper.ownPlayerInfo.CurPos[2])
    self.selfPlayerNode:setPosition(pos)
    if IcefireHelper.ownPlayerInfo.TargetPos then
        self.selfPlayerNode:move(pos, cc.p(IcefireHelper.ownPlayerInfo.TargetPos[1], IcefireHelper.ownPlayerInfo.TargetPos[2]))
    end
    -- 刷新队伍显示
    self:createTeamHeads()
    -- 神行值恢复倒计时
    self:createActionUpdate()
end

-- 创建神行值恢复倒计时
function IcefireMapLayer:createActionUpdate()
    if self.timeUpdate then
        self.mActionNextLabel:stopAction(self.timeUpdate)
        self.timeUpdate = nil
    end

    self.timeUpdate = Utility.schedule(self.mActionNextLabel, function ()
        local timeLeft = IcefireHelper.ownPlayerInfo.NextActionTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mActionNextLabel:setString(TR("神行值恢复时间:  #ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            if IcefireHelper.ownPlayerInfo.ActionNum < IcefireConfig.items[1].maxActionNum then
                IcefireHelper.ownPlayerInfo.ActionNum = IcefireHelper.ownPlayerInfo.ActionNum + 1
                self.mActionNumLabel:setString(TR("神行值：%s", IcefireHelper.ownPlayerInfo.ActionNum))
            end
            -- 神行值是否满
            if IcefireHelper.ownPlayerInfo.ActionNum < IcefireConfig.items[1].maxActionNum then
                IcefireHelper.ownPlayerInfo.NextActionTime = Player:getCurrentTime() + IcefireConfig.items[1].actionNumRestore
            else
                self.mActionNextLabel:stopAction(self.timeUpdate)
                self.timeUpdate = nil
                self.mActionNextLabel:setString("")
            end
        end
    end, 1.0)
end

-- 使用灵石添加神行值弹窗
function IcefireMapLayer:createAddActionBox()
    local goodsId = IcefireConfig.items[1].goodsId
    local typeId = Utility.getTypeByModelId(goodsId)
    local price = IcefireConfig.items[1].goodsAddActionNum
    local ownNum = Utility.getOwnedGoodsCount(typeId, goodsId)
    local needActionNum = IcefireConfig.items[1].maxActionNum-IcefireHelper.ownPlayerInfo.ActionNum
    if ownNum <= 0 then
        ui.showFlashView(TR("%s不足", Utility.getGoodsName(typeId, goodsId)))
        return
    end

    -- if needActionNum < price then
    --     ui.showFlashView(TR("神行值已接近上限"))
    --     return
    -- end

    local maxNum = math.floor(needActionNum/price)
    -- maxNum = maxNum < ownNum and maxNum or ownNum
    maxNum = ownNum

    MsgBoxLayer.addUseGoodsCountLayer(TR("使用%s", Utility.getGoodsName(typeId, goodsId)), goodsId, maxNum, function (selCount, layerObj, btnObj)
        IcefireHelper:addActionNum(selCount)
        LayerManager.removeLayer(layerObj)
    end)
end

return IcefireMapLayer