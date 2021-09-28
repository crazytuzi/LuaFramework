--[[
	文件名：ShengyuanWarsMapLayer.lua
	描述：圣渊大陆地图
	创建人：peiyaoqiang
	创建时间：2017.08.31
--]]

local ShengyuanWarsMapLayer = class("ShengyuanWarsMapLayer", function(params)
    return display.newLayer()
end)

----------------------------------------------------------------------------------------------------

--[[
    params:
    Table params:
    {
        subType: 默认显示的子页面
        subData: 传给子页面的参数
    }
--]]
function ShengyuanWarsMapLayer:ctor(params)
    -- 公共资源
    self.footholdNodeList = {}          -- 据点列表
    self.aerocraftNodeList = {}         -- 飞行器列表
    self.footholdRectList = {}          -- 保存据点的可视区域

    -- 初始化界面恢复参数
    local isDeadth = ShengyuanWarsHelper.rebirthTime and (ShengyuanWarsHelper.rebirthTime > 0)
    local restorePos = nil
    if (params ~= nil) and (not isDeadth) then
        restorePos = params.restorePos
    end

    -- 创建背景
    local bgSprite = ShengyuanWarsUiHelper:createWaveWaterSprite("jzthd_13.jpg")
    local tmpBgSize = bgSprite:getContentSize()
    local bgSize = cc.size(tmpBgSize.width * Adapter.WidthScale, tmpBgSize.height * Adapter.WidthScale)
    bgSprite:setScale(Adapter.WidthScale)
    self.bgSprite = bgSprite
    self.bgSize = bgSize

    -- 创建可拖动区域
    local bgScrollView = ccui.ScrollView:create()
    bgScrollView:setContentSize(display.size)
    bgScrollView:setInnerContainerSize(bgSize)
    bgScrollView:setAnchorPoint(cc.p(0.5, 0.5))
    bgScrollView:setPosition(cc.p(display.cx, display.cy))
    bgScrollView:setDirection(ccui.ScrollViewDir.both)
    self:addChild(bgScrollView)
    self.bgScrollView = bgScrollView

    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.5))
    bgScrollView:addChild(bgSprite)

    -- 自动居中显示
    Utility.performWithDelay(bgSprite, function ()
            if (restorePos ~= nil) then
                bgScrollView:getInnerContainer():setPosition(restorePos)
            else
                local maxOffset = cc.p(display.width - bgSize.width, display.height - bgSize.height)
                local strMyTeam = ShengyuanWarsHelper.myTeamName or ""
                if (strMyTeam == "A") then
                    bgScrollView:getInnerContainer():setPosition(cc.p(0, 0))
                elseif (strMyTeam == "B") then
                    bgScrollView:getInnerContainer():setPosition(maxOffset)
                else
                    bgScrollView:getInnerContainer():setPosition(cc.p(maxOffset.x * 0.5, maxOffset.y * 0.5))
                end
            end
        end, 0.0001)

    -- 创建UI
    self:setUI()

    -- 判断比赛是否已经结束
    if (ShengyuanWarsHelper.battleResultData ~= nil) then
        ShengyuanWarsUiHelper:showEndPopLayer(ShengyuanWarsHelper.battleResultData)
        return
    end

    -- 判断当前玩家是否在据点里
    if next(ShengyuanWarsHelper.enterResInfo) then
        Utility.performWithDelay(bgSprite, function ()
            ShengyuanWarsUiHelper:enterStronghold(ShengyuanWarsHelper.enterResInfo.PointId)
        end, 0.01)
        return
    end

    -- 读取玩家所在的阵营（为nil说明还没收到推送信息）
    if (ShengyuanWarsHelper.myTeamName ~= nil) then
        -- 显示据点和飞行器
        self:refreshFoothold()
        self:refreshAerocraft()

        -- 调用一次移动接口
        for _,v in pairs(ShengyuanWarsHelper.playerList) do
            local nodeItem = self.aerocraftNodeList[v.PlayerId]
            if (nodeItem) then
            	nodeItem.PlayerId = v.PlayerId
                nodeItem:resetDestPos(ShengyuanWarsUiHelper:convertServerPos(v.CurPos), ShengyuanWarsUiHelper:convertServerPos(v.TargetPos))
            end
        end

        -- 刷新五毒散和神符
        self:refreshPolingCount()
        self:refreshShenfuCount()
        self:refreshPointState()
    end

    self:registerScriptHandler(function(eventType)
        if eventType == "enterTransitionFinish" then
            -- 判断是否要弹出复活页面
            if isDeadth then
                ShengyuanWarsUiHelper:showRebirthPopLayer()
            end
        end
    end)
end

function ShengyuanWarsMapLayer:setUI()
    -- 创建导航栏
    local topBgSprite = ShengyuanWarsUiHelper:addTopInfoBar(
        {
            parent = self, 
            pos = cc.p(display.cx, display.cy + 568*Adapter.MinScale), 
            scale = Adapter.MinScale,
            closeAction = function ()
                ShengyuanWarsUiHelper:exitGame()
            end
        })
    self.ourResLabel =          topBgSprite:addResLabel(cc.p(0.2, 0.75))
    self.otherResLabel =        topBgSprite:addResLabel(cc.p(0.55, 0.75))
    self.resRemainTimeLabel =   topBgSprite:addResLabel(cc.p(0.2, 0.5))
    self.buffRemainTimeLabel =  topBgSprite:addResLabel(cc.p(0.2, 0.25))
    self.topBgSprite = topBgSprite

    -- 创建底部技能栏
    local buttomBgSprite = cc.LayerColor:create(cc.c4b(100, 100, 0 , 0))
    local buttomBgSize = cc.size(640,120)
    buttomBgSprite:setContentSize(buttomBgSize)
    buttomBgSprite:setAnchorPoint(cc.p(0,0))
    buttomBgSprite:setPosition(cc.p(0,0))
    buttomBgSprite:setScale(Adapter.MinScale)
    self:addChild(buttomBgSprite)
    -- 创建技能图标
    ShengyuanWarsUiHelper:createSKillBtn({parent = buttomBgSprite, range = 0})

    -- 重置资源Label显示
    local function resetResLabel()
        self.ourResLabel:resetResString(true)
        self.otherResLabel:resetResString(false)
    end

    -- 倒计时刷新回调
    local function valueActionUpdate(dt)
        resetResLabel()

        self.resRemainTimeLabel:resetBuffString(false)
        self.buffRemainTimeLabel:resetBuffString(true)
    end
    valueActionUpdate(nil)

    -- 显示倒计时
    Utility.schedule(self.topBgSprite, valueActionUpdate, 0.2)
    
    ------------------------------------------------------------
    -- 注册相关的通知事件
    local function registerNotificationCallback(events, action)
        Notification:registerAutoObserver(ShengyuanWarsUiHelper:getOneEmptyNode(self), action, events)
    end

    -- 某个玩家的位置发生变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsPosTargetChanged}, 
        function ()
            for _,v in pairs(ShengyuanWarsHelper.playerList) do
                local nodeItem = self.aerocraftNodeList[v.PlayerId]
                if (nodeItem ~= nil) then
                	nodeItem.PlayerId = v.PlayerId
                    nodeItem:resetDestPos(ShengyuanWarsUiHelper:convertServerPos(v.CurPos), ShengyuanWarsUiHelper:convertServerPos(v.TargetPos))
                    if nodeItem.aeroNode.heroNode.refreshHpBar then     -- 同时刷新血条
                        nodeItem.aeroNode.heroNode:refreshHpBar()
                    end
                end
            end
        end)

    -- 有玩家进入或离开资源点
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsEnterOrQuiteRes}, 
        function (node, resData)
            for _,v in pairs(ShengyuanWarsHelper.playerList) do
                local nodeItem = self.aerocraftNodeList[v.PlayerId]
                if (nodeItem ~= nil) then
                    if (v.Status == 1) then
                        if nodeItem:enterOneFoothold(resData) then
                            break
                        end
                    else
                        nodeItem:leaveFoothold()
                    end
                    if nodeItem.aeroNode.heroNode.refreshHpBar then     -- 同时刷新血条
                        nodeItem.aeroNode.heroNode:refreshHpBar()
                    end
                end
            end
        end)
    
    -- 积分发生变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsScoreChanged}, 
        function ()
            resetResLabel()
        end)

    -- 五毒散发生变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsPoLingChanged}, 
        function ()
            self:refreshPolingCount()
        end)
    
    -- 神符出现刷新
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsResBuffChanged}, 
        function ()
            self:refreshShenfuCount()
        end)
    
    -- 资源点状态发生变化
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsResInfo}, 
        function ()
            self:refreshPointState()
        end)
    
    -- 比赛结束
    registerNotificationCallback({ShengyuanWarsHelper.Events.eShengyuanWarsFightResult}, 
        function(node, info)
            ShengyuanWarsUiHelper:showEndPopLayer(info)
            
            -- 停止倒计时
            self.topBgSprite:stopAllActions()
            resetResLabel()
            self.resRemainTimeLabel:setString(TR("本场比赛已结束"))
        end)
end

-- 刷新据点
function ShengyuanWarsMapLayer:refreshFoothold()
    self.footholdNodeList = {}

    -- 据点按钮事件
    local function footholdClickAction(fhId)
        if (fhId == nil) then
            return
        end

        -- 读取据点信息
        local fhItem = self.footholdNodeList[fhId]
        if (fhItem == nil) then
            return
        end

        -- 读取玩家的法宝信息
        local myAerocraft = self:getMyAerocraft()
        if (myAerocraft == nil) then
            return
        end

        -- 找到自己所在的位置
        local myCurPos, myDstPos = nil, nil
        for _,v in pairs(ShengyuanWarsHelper.playerList) do
            if (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
                myCurPos = ShengyuanWarsUiHelper:convertServerPos(v.CurPos)
                myDstPos = ShengyuanWarsUiHelper:convertServerPos(v.TargetPos)
                break
            end
        end
        if (myCurPos == nil) then
            return
        end

        -- 如果当前位置和据点位置相同
        if (myCurPos.x == fhItem.nodePos.x) and (myCurPos.y == fhItem.nodePos.y) then
            -- 非出生点才能允许进入
            if (fhItem.nodeType ~= 1 and fhItem.nodeType ~= 7) then
                ShengyuanWarsHelper:enterPoint(fhId, nil)
            end
        else
            -- 判断目标位置是否就是当前据点，防止重复点击
            if (myDstPos.x ~= fhItem.nodePos.x) or (myDstPos.y ~= fhItem.nodePos.y) then
                myAerocraft:leaveFoothold()
                ShengyuanWarsHelper:playerMove(fhId, nil)
            end
        end
    end

    -- 重新创建所有据点
    for _,v in pairs(ShengyuanWarsHelper.allResList) do
        if (v.PointId ~= nil) and (self.footholdNodeList[v.PointId] == nil) then
            local resBaseInfo = ShengyuanwarsBuildingModel.items[v.PointId]
            local tmpNode = self:createOneFoothold(resBaseInfo, cc.p(resBaseInfo.X, resBaseInfo.Y), function ()
                    footholdClickAction(v.PointId)
                end)
            self.footholdNodeList[v.PointId] = tmpNode
        end
    end
end

-- 刷新飞行器
function ShengyuanWarsMapLayer:refreshAerocraft()
    -- 清空之前的飞行器
    for _,v in pairs(self.aerocraftNodeList) do
        if (v.aeroNode ~= nil) then
            v.aeroNode:removeFromParent()
            v.aeroNode = nil
        end
    end
    self.aerocraftNodeList = {}

    -- 飞行器点击事件
    local function aerocraftClickAction(acId)
        if (acId == nil) then
            return
        end

        -- 读取飞行器信息
        local acItem = self.aerocraftNodeList[acId]
        if (acItem == nil) or (acItem.aeroNode == nil) then
            return
        end

        -- 在飞行器的边缘显示出“查看”按钮，同时显示出运动轨迹线
        acItem:showPathline(not acItem.isPathline)
    end

    -- 重新创建所有飞行器
    for _,v in pairs(ShengyuanWarsHelper.playerList) do
        local aeroItem = self:createOneAerocraft(v, ShengyuanWarsUiHelper:convertServerPos(v.CurPos), function ()
                aerocraftClickAction(v.PlayerId)
            end)
        self.aerocraftNodeList[v.PlayerId] = aeroItem
    end
end

----------------------------------------------------------------------------------------------------

-- 辅助函数：创建一个据点
function ShengyuanWarsMapLayer:createOneFoothold(item, pos, clickCallback)
    local tempItem = {nodeId = item.Id, nodePos = pos, nodeType = item.type}
    local btnFoothold = nil
    local bgImgList = {[1] = {img = "jzthd_52.png", pos = cc.p(190, 170)}, [7] = {img = "jzthd_51.png", pos = cc.p(840, 1200)}}
    local tmpBgImg = bgImgList[item.Id]
    local rectSize = cc.size(0, 0)
    local rectPos = cc.p(0, 0)
    if tmpBgImg then
        -- 出生点：静态底图+静态按钮
        local tmpBgSprite = ui.newSprite(tmpBgImg.img)
        tmpBgSprite:setPosition(tmpBgImg.pos)
        self.bgSprite:addChild(tmpBgSprite, 0)

        -- 可点击的码头
        btnFoothold = ui.newButton({
            normalImage = item.pic .. ".png",
            position = pos,
            clickAction = clickCallback,
        })
        self.bgSprite:addChild(btnFoothold, 0)

        rectSize = btnFoothold:getContentSize()
        rectPos = cc.p(pos.x - rectSize.width/2, pos.y - rectSize.height/2)
    else
        -- 其他点：动态底图+透明按钮
        local showScale = (item.Id == 4) and 0.6 or 0.8
        ui.newEffect({
            parent = self.bgSprite,
            effectName = "effect_ui_taohua_jing",
            animation = item.pic,
            position = pos,
            scale = showScale,
            zorder = 0,
            loop = true,
        })

        -- 方便点击的透明按钮
        rectSize = (item.Id == 4) and cc.size(300, 250) or cc.size(160, 150)
        rectPos = cc.p(pos.x - rectSize.width/2, pos.y - rectSize.height/2 + 20)
        btnFoothold = ui.newButton({
            normalImage = "c_83.png",
            size = rectSize,
            anchorPoint = cc.p(0, 0),
            position = rectPos,
            clickAction = clickCallback,
        })
        self.bgSprite:addChild(btnFoothold, 1)
    end
    btnFoothold:setSwallowTouches(false)

    -- 把当前位置的rect保存起来，方便检测船只和岛屿的接触
    local showRect = {
        x = rectPos.x + rectSize.width * 0.15, 
        y = rectPos.y + rectSize.height * 0.15, 
        width = rectSize.width * 0.7, 
        height = rectSize.height * 0.7
    }
    table.insert(self.footholdRectList, showRect)

    -- 不能往对方的出生点飞行
    if (ShengyuanWarsHelper.myTeamName == "A" and item.Id == 7) or (ShengyuanWarsHelper.myTeamName == "B" and item.Id == 1) then
        btnFoothold:setEnabled(false)
        btnFoothold:setBright(true)
    end

    -- 显示五毒散数量和拾取按钮
    if ((ShengyuanWarsHelper.myTeamName == "A") and (item.Id == 1)) or ((ShengyuanWarsHelper.myTeamName == "B") and (item.Id == 7)) then
        local btnSize = btnFoothold:getContentSize()
        local centerX, centerY = btnSize.width/2, btnSize.height/2
        local ap1, ap2, ap3 = cc.p(1, 0.5), cc.p(0.5, 0.5), cc.p(0, 0.5)
        local ps1, ps2, ps3 = cc.p(centerX+200, centerY-60), cc.p(centerX+290, centerY-25), cc.p(centerX+270, centerY-70)
        if (item.Id == 7) then
            ap1, ap2, ap3 = cc.p(0, 0.5), cc.p(0, 0.5), cc.p(0, 0.5)
            ps1, ps2, ps3 = cc.p(centerX+20, centerY-200), cc.p(centerX+95, centerY-175), cc.p(centerX+90, centerY-220)
        end

        -- 辅助接口：当前玩家返回出生点
        local function gotoHome()
            if (item.Id ~= 1) and (item.Id ~= 7) then
                return false
            end

            local myAerocraft = self:getMyAerocraft()
            if (myAerocraft == nil) then
                return false
            end
            -- 找到自己所在的位置
            local myCurPos, myDstPos = nil, nil
            for _,v in pairs(ShengyuanWarsHelper.playerList) do
                if (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
                    myCurPos = ShengyuanWarsUiHelper:convertServerPos(v.CurPos)
                    myDstPos = ShengyuanWarsUiHelper:convertServerPos(v.TargetPos)
                    break
                end
            end
            if (myCurPos == nil) then
                return false
            end

            -- 判断是否已经在出生点了
            if (myCurPos.x == pos.x) and (myCurPos.y == pos.y) then
                return false
            end

            -- 返回出生点
            if (myDstPos.x ~= pos.x) or (myDstPos.y ~= pos.y) then
                myAerocraft:leaveFoothold()
                ShengyuanWarsHelper:playerMove(item.Id, nil)
            end

            return true
        end
        local function getPolingAction()
            -- 玩家要先返回出生点
            if (gotoHome() == true) then
                return
            end

            -- 拿取五毒散
            if (tempItem.polingCount > 0) then
                ShengyuanWarsHelper:occupyPoint(item.Id,
                    function (responseData)
                        if (responseData.Code >= 0) then
                            ui.showFlashView(TR("成功携带了一个五毒散"))
                        end
                    end)
            else
                ui.showFlashView(TR("暂时没有五毒散了，请等待刷新"))
            end
        end

        -- 显示五毒散的图片
        local polingEffect = ui.newEffect({
            parent = btnFoothold,
            effectName = "effect_ui_taohua_jing",
            animation = "jiutang",
            scale = 0.8,
            position = ps1,
            loop = true,
        })
        Utility.performWithDelay(btnFoothold, function(time)
            local polingRect = polingEffect:getBoundingBox()
            local tmpGetBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cc.size(polingRect.width * 0.8, polingRect.height * 0.8),
                anchorPoint = cc.p(0.5, 0.5),
                position = cc.p(polingRect.width * 0.1, polingRect.height * 0.1),
                clickAction = getPolingAction,
            })
            tmpGetBtn:setSwallowTouches(false)
            polingEffect:addChild(tmpGetBtn)
        end, 0.001)
        
        -- 五毒散的数量
        local polingLabel = ui.newLabel({
            text = "x0",
            size = 30,
            x = ps2.x, y = ps2.y,
            color = cc.c3b(0xFF, 0x00, 0x00),
            outlineColor = Enums.Color.eBlack, 
        })
        polingLabel:setAnchorPoint(ap2)
        btnFoothold:addChild(polingLabel)

        tempItem.polingLabel = polingLabel
        tempItem.polingCount = 0

        -- 五毒散的拾取按钮
        local polingGetBtn = ui.newButton({
            normalImage = "jzthd_09.png",
            anchorPoint = ap3,
            position = ps3,
            clickAction = getPolingAction,
        })
        polingGetBtn:setSwallowTouches(false)
        btnFoothold:addChild(polingGetBtn)
    end

    -- 中心战场显示占领提示
    if (item.Id == 4) then
        local centerSprite = ui.createFloatSprite("jzthd_71.png", cc.p(0, 80))
        btnFoothold:getExtendNode2():addChild(centerSprite)
    end

    -- 对外接口：显示神符
    tempItem.resetShenfu = function(target, newShenfu)
        if (target.shenfu ~= nil) and (target.shenfu == newShenfu) then
            return
        end

        -- 删除之前的神符动画
        if (target.shenfuEffect ~= nil) then
            target.shenfuEffect:removeFromParent()
            target.shenfuEffect = nil
        end

        -- 重建神符动画
        local shenfuItem = ShengyuanwarsBuffModel.items[newShenfu]
        if (shenfuItem ~= nil) then
            target.shenfuEffect = ui.newEffect({
                parent = btnFoothold:getExtendNode2(),
                effectName = "effect_ui_taohuadao",
                animation = shenfuItem.outsideSpine,
                scale = 0.75,
                loop = true,
                endRelease = false,
                position = cc.p(0, 120),
            })
        end
        target.shenfu = newShenfu
    end

    -- 对外接口：保存五毒散数量
    tempItem.resetPolingCount = function(target, newCount)
        target.polingCount = newCount
        if (newCount > 0) then
            target.polingLabel:setString("#00FF00x" .. newCount)
        else
            target.polingLabel:setString("#FF0000x0")
        end
    end

    return tempItem
end

-- 辅助函数：创建一个飞行器
function ShengyuanWarsMapLayer:createOneAerocraft(item, pos, clickCallback)
    -- 是否需要被隐藏
    local isNeedHide = false
    for _,v in pairs(ShengyuanWarsHelper.playerList) do
        if (v.PlayerId == item.PlayerId) then
            isNeedHide = (v.Status == 1)
            break
        end
    end

    -- 辅助接口：显示/隐藏小船
    local function hideAeroBoat(nodeItem, allowRun)
        if self:isAeroInterRect(nodeItem) then
            if nodeItem.boatSprite:isVisible() then
                nodeItem.boatSprite:setVisible(false)
                nodeItem.waveEffect:setVisible(false)
                -- 船隐藏时，取消晃动动画（直上直下时效果不甚好）
                -- if nodeItem.waveAction then
                --     nodeItem:stopAction(nodeItem.waveAction)
                --     nodeItem.waveAction = nil
                -- end
            end
            if (allowRun == nil) or (allowRun == true) then
                nodeItem.heroNode:heroRun(true)
            end
        else
            if not nodeItem.boatSprite:isVisible() then
                nodeItem.boatSprite:setVisible(true)
                nodeItem.waveEffect:setVisible(true)
                nodeItem.heroNode:heroRun(false)
                -- 船显示时，显示晃动动画（直上直下时效果不甚好）
                -- nodeItem.waveAction = nodeItem:runAction(cc.RepeatForever:create(cc.Sequence:create({
                --     cc.MoveBy:create(1.5, cc.p(0, 8)), cc.MoveBy:create(1.5, cc.p(0, -8))
                --     })))
            end
        end
    end

    -- 添加小船
    local config = clone(item)
    if (item.TeamName == ShengyuanWarsHelper.teamB) then
        config.direction = ShengyuanWarsUiHelper.directionTag.eLeftDown
    end
    local effectNode = ShengyuanWarsUiHelper:createBoat(config, clickCallback)
    if (effectNode == nil) then
        return
    end
    effectNode:setAnchorPoint(effectNode.heroRate)
    effectNode:setPosition(pos)
    effectNode:setVisible((not isNeedHide))
    self.bgSprite:addChild(effectNode, 3)
    hideAeroBoat(effectNode, false)

    -- 保存属性
    local tempItem = {ModelId = item.MountModelId, Guid = item.PlayerId, Name = item.PlayerName, Type = item.PlayerType, Level = item.MountModelLevel}
    tempItem.aeroNode = effectNode
    tempItem.destPos = nil              -- 飞行的目标位置
    tempItem.lineNodes = {}             -- 轨迹线节点列表
    tempItem.isPathline = false         -- 是否显示轨迹线：默认不显示
    
    -- 初始化旋转角度
    local tmpCurPos, tmpDstPos = ShengyuanWarsUiHelper:convertServerPos(item.CurPos), ShengyuanWarsUiHelper:convertServerPos(item.TargetPos)
    if (tmpCurPos.x ~= tmpDstPos.x) or (tmpCurPos.y ~= tmpDstPos.y) then
        local tmpRotate = ShengyuanWarsUiHelper:getRotationStepLists(tmpCurPos, tmpDstPos)
        effectNode:resetRotate(tmpRotate)
    end
    
    -- 对外接口：是否自己的飞行器
    tempItem.isMyself = function(target)
        return (target.Guid == PlayerAttrObj:getPlayerAttrByName("PlayerId"))
    end

    -- 对外接口：飞行到某个坐标
    tempItem.resetDestPos = function(target, newCurPos, newDestPos)
        -- 判断是否重复
        if (target.destPos ~= nil) and (target.destPos.x == newDestPos.x) and (target.destPos.y == newDestPos.y) then
            return
        end
        
        -- 保存飞行器的目标位置
        target.aeroNode:setPosition(newCurPos)
        target.destPos = newDestPos

        -- 停止之前的移动动画和轨迹线
        if (target.moveAction ~= nil) then
            target.aeroNode:stopAction(target.moveAction)
            target.moveAction = nil
        end
        for _,v in pairs(target.lineNodes or {}) do
            if (v.node ~= nil) then
                v.node:removeFromParent()
                v.node = nil
            end
        end
        target.lineNodes = {}

        -- 判断起点和终点位置是否相同
        if (newCurPos.x == newDestPos.x) and (newCurPos.y == newDestPos.y) then
            return
        end

        -- 读取轨迹线用到的图片
        local pathlineDotImg = "jzthd_42.png"
        if (target.Type == ShengyuanWarsHelper.enumAerocraftType.enemy) then
            pathlineDotImg = "jzthd_43.png"
        elseif (target.Type == ShengyuanWarsHelper.enumAerocraftType.myself) then
            pathlineDotImg = "jzthd_45.png"
        end

        -- 计算两点之间的动画节点
        local curPos, endPos = newCurPos, newDestPos
        local newRotate, nodePosList = ShengyuanWarsUiHelper:getRotationStepLists(curPos, endPos)
        local distance = math.sqrt(math.pow(endPos.x - curPos.x, 2) + math.pow(endPos.y - curPos.y, 2))
        local time = (distance/ShengyuanWarsHelper:getMountSpeed(target.ModelId, target.Level, target.PlayerId))/table.maxn(nodePosList)

        -- 先旋转，因为旋转会重建小船，导致size发生变化
        target.aeroNode:resetRotate(newRotate)
        target.aeroNode:setAnchorPoint(target.aeroNode.heroRate)
        hideAeroBoat(target.aeroNode, false)

        -- 创建轨迹点列表
        for i,v in ipairs(nodePosList) do
            local nodeSprite = ui.newSprite(pathlineDotImg)
            nodeSprite:setPosition(v)
            nodeSprite:setVisible(target.isPathline)
            self.bgSprite:addChild(nodeSprite, 2)
            target.lineNodes[i] = {node = nodeSprite}
        end
        
        -- 生成飞行动画
        local array = {}
        for i,v in ipairs(nodePosList) do
            local tmpIdx = i
            table.insert(array, cc.CallFunc:create(function ()
                hideAeroBoat(target.aeroNode)
            end))
            table.insert(array, cc.MoveTo:create(time, v))
            table.insert(array, cc.CallFunc:create(function ()
                target.lineNodes[tmpIdx].node:removeFromParent()
                target.lineNodes[tmpIdx].node = nil
                -- 重设船的zorder, 将下面的船zorder提高
                local _, posY = target.aeroNode:getPosition()
                target.aeroNode:setLocalZOrder(self.bgSize.height - posY)
            end))
        end
        table.insert(array, cc.CallFunc:create(function ()
                hideAeroBoat(target.aeroNode, false)
                -- 设置动画结束
                target.moveAction = nil
            end))

        -- 执行移动的动画
        target.moveAction = target.aeroNode:runAction(cc.Sequence:create(array))
        
        -- 如果是自己，则自动显示出轨迹线
        if (target:isMyself() == true) then
            target:showPathline(true)
        end
    end

    -- 对外接口：更新速度
    tempItem.updateSpeed = function (target)
    	local newCurPos = cc.p(target.aeroNode:getPositionX(),target.aeroNode:getPositionY())
        if (target.destPos ~= nil) and (target.destPos.x == newCurPos.x) and (target.destPos.y == newCurPos.y) then
            return
        end
        -- 停止之前的移动动画和轨迹线
        if (target.moveAction ~= nil) then
            target.aeroNode:stopAction(target.moveAction)
            target.moveAction = nil
        end
        for _,v in pairs(target.lineNodes or {}) do
            if (v.node ~= nil) then
                v.node:removeFromParent()
                v.node = nil
            end
        end
        target.lineNodes = {}

        -- 读取轨迹线用到的图片
        local pathlineDotImg = "jzthd_42.png"
        if (target.Type == ShengyuanWarsHelper.enumAerocraftType.enemy) then
            pathlineDotImg = "jzthd_43.png"
        elseif (target.Type == ShengyuanWarsHelper.enumAerocraftType.myself) then
            pathlineDotImg = "jzthd_45.png"
        end

        -- 计算两点之间的动画节点
        local curPos, endPos = newCurPos, target.destPos
        local newRotate, nodePosList = ShengyuanWarsUiHelper:getRotationStepLists(curPos, endPos)
        local distance = math.sqrt(math.pow(endPos.x - curPos.x, 2) + math.pow(endPos.y - curPos.y, 2))
        local time = (distance/ShengyuanWarsHelper:getMountSpeed(target.ModelId, target.Level, target.PlayerId))/table.maxn(nodePosList)

        -- 先旋转，因为旋转会重建小船，导致size发生变化
        target.aeroNode:resetRotate(newRotate)
        target.aeroNode:setAnchorPoint(target.aeroNode.heroRate)
        hideAeroBoat(target.aeroNode, false)

        -- 创建轨迹点列表
        for i,v in ipairs(nodePosList) do
            local nodeSprite = ui.newSprite(pathlineDotImg)
            nodeSprite:setPosition(v)
            nodeSprite:setVisible(target.isPathline)
            self.bgSprite:addChild(nodeSprite, 2)
            target.lineNodes[i] = {node = nodeSprite}
        end
        
        -- 生成飞行动画
        local array = {}
        for i,v in ipairs(nodePosList) do
            local tmpIdx = i
            table.insert(array, cc.CallFunc:create(function ()
                hideAeroBoat(target.aeroNode)
            end))
            table.insert(array, cc.MoveTo:create(time, v))
            table.insert(array, cc.CallFunc:create(function ()
                target.lineNodes[tmpIdx].node:removeFromParent()
                target.lineNodes[tmpIdx].node = nil
                -- 重设船的zorder, 将下面的船zorder提高
                local _, posY = target.aeroNode:getPosition()
                target.aeroNode:setLocalZOrder(self.bgSize.height - posY)
            end))
        end
        table.insert(array, cc.CallFunc:create(function ()
                hideAeroBoat(target.aeroNode, false)
                -- 设置动画结束
                target.moveAction = nil
            end))

        -- 执行移动的动画
        target.moveAction = target.aeroNode:runAction(cc.Sequence:create(array))
        
        -- 如果是自己，则自动显示出轨迹线
        if (target:isMyself() == true) then
            target:showPathline(true)
        end
    end

    -- 对外接口：进入某个据点
    tempItem.enterOneFoothold = function(target, resData)
        -- 隐藏飞行器
        target.aeroNode:setVisible(false)

        -- 如果是玩家自己，则切换到占领界面
        if (target:isMyself() == true) then
            local tmpX, tmpY = self.bgScrollView:getInnerContainer():getPosition()
            self.restoreData = cc.p(tmpX, tmpY)
            ShengyuanWarsUiHelper:enterStronghold(resData.PointId)
            return true
        end
    end

    -- 对外接口：退出当前据点
    tempItem.leaveFoothold = function(target)
        target.aeroNode:setVisible(true)
    end

    -- 对外接口：显示/隐藏轨迹线
    tempItem.showPathline = function(target, visible)
        -- 创建查看按钮
        if tolua.isnull(target.lookButton) then
            local heroSize = target.aeroNode:getContentSize()
            local button = ui.newButton({
                normalImage = "jzthd_47.png",
                position = cc.p(heroSize.width * 0.5, heroSize.height * 0.2),
                clickAction = function ()
                    ShengyuanWarsUiHelper:showLookPopLayer(target)
                    -- 查看之后自动隐藏
                    target:showPathline((not visible))
                end
            })
            button:setVisible(visible)
            target.aeroNode:addChild(button, 2)
            target.lookButton = button
        end
        target.lookButton:setVisible(visible)

        -- 处理轨迹线
        if (target.isPathline == visible) then
            return
        end
        target.isPathline = visible
        
        -- 自己的轨迹线一直显示
        local isVisible = visible
        if (target:isMyself() == true) then
            isVisible = true
        end
        
        -- 隐藏/显示所有轨迹点
        for _,v in pairs(target.lineNodes or {}) do
            if (v.node ~= nil) then
                v.node:setVisible(isVisible)
            end
        end
    end

    -- 注册速度修改事件
    Notification:registerAutoObserver(self, function ()
    	tempItem:updateSpeed()
    	tempItem.aeroNode:refreshBuff()
    end, {ShengyuanWarsHelper.Events.eShengyuanWarsSkillUpdatePre .. item.PlayerId})

    return tempItem
end

----------------------------------------------------------------------------------------------------

-- 获取玩家自己的飞行器信息
function ShengyuanWarsMapLayer:getMyAerocraft()
    local retItem = nil
    for _,v in pairs(self.aerocraftNodeList) do
        if (v:isMyself() == true) then
            retItem = v
            break
        end
    end

    return retItem
end

-- 刷新五毒散的数量
function ShengyuanWarsMapLayer:refreshPolingCount()
    local function setPolingCount(fhId, count)
        local fhItem = self.footholdNodeList[fhId]
        fhItem:resetPolingCount(count)
    end
    if (ShengyuanWarsHelper.myTeamName == "A") then
        setPolingCount(1, ShengyuanWarsHelper.APoLingCount)
    else
        setPolingCount(7, ShengyuanWarsHelper.BPoLingCount)
    end
end

-- 刷新神符的显示
function ShengyuanWarsMapLayer:refreshShenfuCount()
    for _,v in pairs(ShengyuanWarsHelper.allResList) do
        if (v.PointId == 2) or (v.PointId == 3) or (v.PointId == 5) or (v.PointId == 6) then
            local fhItem = self.footholdNodeList[v.PointId]
            fhItem:resetShenfu((v.Status == 2) and -1 or v.BuffId)
        end
    end
end

-- 刷新据点的状态
function ShengyuanWarsMapLayer:refreshPointState()
    for _,v in pairs(ShengyuanWarsHelper.allResList) do
        if (v.PointId == 2) or (v.PointId == 3) or (v.PointId == 5) or (v.PointId == 6) then
            local fhItem = self.footholdNodeList[v.PointId]
            -- 状态为2时，表示神符已经不存在了
            if v.Status and v.Status > 1 then
                fhItem:resetShenfu(-1)
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- 判断小船是否与某个据点碰撞
function ShengyuanWarsMapLayer:isAeroInterRect(aeroNode)
    local heroNode = aeroNode.heroNode
    local worldPos = heroNode:getParent():convertToWorldSpace(cc.p(heroNode:getPosition()))
    local checkPos = self.bgSprite:convertToNodeSpace(worldPos)
    local ret = false
    for _,v in ipairs(self.footholdRectList) do
        if cc.rectContainsPoint(v, checkPos) then
            ret = true
            break
        end
    end
    return ret
end

-- 获取恢复数据
function ShengyuanWarsMapLayer:getRestoreData()
    local retData = {
        restorePos = self.restoreData,
    }

    return retData
end

----------------------------------------------------------------------------------------------------

return ShengyuanWarsMapLayer
