--[[
    文件名：ShengyuanWarsUiHelper.lua
    描述：决战桃花岛的UI助手，封装一些通用的UI显示
    创建人：peiyaoqiang
    创建时间：2017.8.29
-- ]]
ShengyuanWarsUiHelper = {}

-- 据点里的飞机显示位置
ShengyuanWarsUiHelper.planePos = {
    -- 我方飞机
    ["Our"] = {
        cc.p(64, 230), cc.p(192, 230), cc.p(320, 230), cc.p(448, 230), cc.p(576, 230),
        cc.p(64, 30), cc.p(192, 30), cc.p(320, 30), cc.p(448, 30), cc.p(576, 30),
    },
    -- 敌方飞机
    ["Enemy"] = {
        cc.p(64, 800), cc.p(192, 800), cc.p(320, 800), cc.p(448, 800), cc.p(576, 800),
        cc.p(64, 600), cc.p(192, 600), cc.p(320, 600), cc.p(448, 600), cc.p(576, 600),
    },
}

-- 据点里显示的阵营枚举
ShengyuanWarsUiHelper.sideType = {
    Our   = 1,
    Enemy = 2,
}

-- 据点里显示的飞机node子标签
ShengyuanWarsUiHelper.playerTag = {
    PoLing = 1,        -- 五毒散
    ShuangBei = 3,     -- 双倍
    ShiXue = 4,        -- 嗜血
    XueTiao = 9        -- 血条
}

-- 小船的显示方向
ShengyuanWarsUiHelper.directionTag = {
    eRightUp = 1,       -- 右上
    eRightDown = 2,     -- 右下
    eLeftUp = 3,        -- 左上
    eLeftDown = 4,      -- 左下
}

----------------------------------------------------------------------------------------------------
-- 辅助类的接口

-- 将服务器返回的坐标转换为本地坐标
function ShengyuanWarsUiHelper:convertServerPos(pos)
    if pos.x and pos.y then
        return pos
    else
        return cc.p(pos[1], pos[2])
    end
end

-- 获取一个空白node
function ShengyuanWarsUiHelper:getOneEmptyNode(parent)
    local tmpNode = cc.Node:create()
    parent:addChild(tmpNode)
    return tmpNode
end

-- 获取相对中间位置的偏移量
function ShengyuanWarsUiHelper:getOffsetByMidel(index, maxIndex, itemWidth)
    if  maxIndex%2 == 0 then
        local midIndex = maxIndex/2
        if index <= midIndex then
            return - (itemWidth/2 + (midIndex - index) * itemWidth)
        else
            return itemWidth/2 + (index - (midIndex+1)) * itemWidth
        end
    else
        local midIndex = math.floor(maxIndex/2)+1

        return (itemWidth)*(midIndex-index)
    end
end

-- 判断该资源点占领玩家所在的阵营
function ShengyuanWarsUiHelper:checkPlayerSide()
    local enterResTeamName = ShengyuanWarsHelper.enterResInfo.TeamName

    if ShengyuanWarsHelper.myTeamName and (ShengyuanWarsHelper.myTeamName == ShengyuanWarsHelper.teamB) then
        return (enterResTeamName == ShengyuanWarsHelper.teamA) and ShengyuanWarsUiHelper.sideType.Enemy or ShengyuanWarsUiHelper.sideType.Our
    else
        return (enterResTeamName == ShengyuanWarsHelper.teamA) and ShengyuanWarsUiHelper.sideType.Our or ShengyuanWarsUiHelper.sideType.Enemy
    end
end

-- 求两个点的旋转角度，并返回距离点集合
--[[
    params:
    startPos: 当前位置
    endPos: 目标位置
    step: 集合点间距

    return:
    degree: 旋转角度
    stepList: 路径集合
--]]
function ShengyuanWarsUiHelper:getRotationStepLists(startPos, endPos, step)
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

    local calcAngle = (startPos.y < endPos.y) and ((angle * 180) / math.pi) or ((angle * 180) / math.pi + 180)
    return calcAngle, stepList
end

----------------------------------------------------------------------------------------------------
-- 界面相关的接口

-- 进入据点页面
function ShengyuanWarsUiHelper:enterStronghold(pointId)
    if (pointId == 4) then
        LayerManager.addLayer({name = "shengyuan.ShengyuanWarsStrongholdCenterLayer",})
    else
        LayerManager.addLayer({name = "shengyuan.ShengyuanWarsStrongholdLayer",})
    end
end

-- 弹出聊天页面
function ShengyuanWarsUiHelper:showChatPopLayer()
    LayerManager.addLayer({
        name    = "shengyuan.ShengyuanWarsDlgChatLayer", 
        data    = {}, 
        cleanUp = false,
        zOrder  = Enums.ZOrderType.ePopLayer,
        })
end

-- 弹出人物查看页面
function ShengyuanWarsUiHelper:showLookPopLayer(heroInfo)
    LayerManager.addLayer({
        name    = "shengyuan.ShengyuanWarsDlgLookLayer", 
        data    = {AeroInfo = heroInfo}, 
        zOrder  = Enums.ZOrderType.ePopLayer, 
        cleanUp = false
        })
end

-- 弹出比赛结束后的结算页面
function ShengyuanWarsUiHelper:showEndPopLayer(endData)
    LayerManager.addLayer({
        name    = "shengyuan.ShengyuanWarsEndPopLayer",
        data    = {pageInfo = endData},
        cleanUp = false,
        zOrder  = Enums.ZOrderType.ePopLayer,
        })
end

-- 弹出玩家阵亡后的复活界面
function ShengyuanWarsUiHelper:showRebirthPopLayer()
    LayerManager.addLayer({
        name    = "shengyuan.ShengyuanWarsRebirthPopLayer",
        cleanUp = false,
        zOrder  = Enums.ZOrderType.ePopLayer + 1,
        })
end

-- 游戏结束退出战场
--[[
    reEnter : 是否重新进入桃花岛首页，默认为false，只在比赛结束的时候才设为true，否则进入桃花岛首页后又会自动进入战场
--]]
function ShengyuanWarsUiHelper:exitGame(reEnter)
    local autoParams = nil
    if (reEnter ~= nil) and (reEnter == true) then
        autoParams = ModuleSub.eShengyuanWars
    end
    LayerManager.addLayer({
        name = "challenge.ChallengeLayer",
        data = {autoOpenModule = autoParams}
    })
end

-- 添加聊天的快捷弹窗
function ShengyuanWarsUiHelper:addChatPopupLabel(bindNode, pos)
    -- 不用删除了，每次执行这个创建的时候，bindNode都是新的
    -- 创建聊天背景
    -- if not tolua.isnull(ShengyuanWarsUiHelper.chatPopupSprite) then
    --     ShengyuanWarsUiHelper.chatPopupSprite:removeFromParent()
    --     ShengyuanWarsUiHelper.chatPopupSprite = nil
    -- end
    local chatPopupSprite = ui.newScale9Sprite("lt_11.png", cc.size(640, 120))
    chatPopupSprite:setAnchorPoint(cc.p(0.5, 1))
    chatPopupSprite:setPosition(pos)
    chatPopupSprite:setVisible(false)
    bindNode:addChild(chatPopupSprite)
    ShengyuanWarsUiHelper.chatPopupSprite = chatPopupSprite
        
    -- 清空所有label
    ShengyuanWarsUiHelper.chatPopupList = {}
    
    -- 注册通知
    Notification:registerAutoObserver(ShengyuanWarsUiHelper.chatPopupSprite, function(node, info)
        ShengyuanWarsUiHelper.chatPopupSprite:stopAllActions()
        ShengyuanWarsUiHelper.chatPopupSprite:setVisible(true)

        --
        local function createNewChatLabel(info, index)
            local chatLabel = ui.newLabel({text = "", color = cc.c3b(0x46, 0x22, 0x0d),})
            chatLabel.resetPos = function (target, tmpIndex)
                target:setPosition(cc.p(30, 120 - 25 - (tmpIndex-1)*35))
            end
            chatLabel.resetText = function (target, tmpInfo)
                target:setString(string.format("%s:%s", tmpInfo.Name, tmpInfo.Content))
            end
            chatLabel:setAnchorPoint(cc.p(0, 0.5))
            chatLabel:resetPos(index)
            chatLabel:resetText(info)
            ShengyuanWarsUiHelper.chatPopupSprite:addChild(chatLabel)
            return chatLabel
        end

        --
        ShengyuanWarsUiHelper.chatPopupList = ShengyuanWarsUiHelper.chatPopupList or {}
        if #ShengyuanWarsUiHelper.chatPopupList < 3 then
            table.insert(ShengyuanWarsUiHelper.chatPopupList, createNewChatLabel(info, #ShengyuanWarsUiHelper.chatPopupList + 1))
        else
            for i,v in ipairs(ShengyuanWarsUiHelper.chatPopupList) do
                v:resetPos((i == 1) and 3 or (i-1))
            end
            -- 将最上部label放到最下面
            local frontLabel = ShengyuanWarsUiHelper.chatPopupList[1]
            table.remove(ShengyuanWarsUiHelper.chatPopupList, 1)
            frontLabel:resetText(info)
            table.insert(ShengyuanWarsUiHelper.chatPopupList, frontLabel)
        end

        -- 显示一定时间后消失
        ShengyuanWarsUiHelper.chatPopupSprite:runAction(cc.Sequence:create({cc.DelayTime:create(3), cc.Hide:create()}))
    end, {ShengyuanWarsHelper.Events.eShengyuanWarsPlayerChatInfo})
end

-- 弹出击杀之后的飘窗提示文字
function ShengyuanWarsUiHelper:showKillFlash(target, playerId)
    local playerInfo = ShengyuanWarsHelper:getPlayerData(playerId)
    if playerInfo.CurPointId ~= target.mCurPointId then 
        return 
    end

    -- 找到属于玩家的飞机
    local function findPlayerNode(planeList)
        local tmpNode = nil
        for _, v in ipairs(planeList) do
            if v.Id == playerId then
                tmpNode = v.plan
                break
            end
        end
        return tmpNode
    end
    local node = findPlayerNode(target.mOurPlane) or findPlayerNode(target.mEnemyPlane)
    if (node == nil) then
        return
    end
    
    -- 创建文字背景
    local nodeSize = node:getContentSize()
    local sprite = ui.newSprite("jzthd_69.png")
    sprite:setPosition(nodeSize.width*0.5, nodeSize.height*0.5)
    node:addChild(sprite)
    
    -- 执行动画
    sprite:runAction(cc.Sequence:create({cc.MoveBy:create(2, cc.p(0, 30)), cc.CallFunc:create(function()
            sprite:removeFromParent()
        end)}))
end

----------------------------------------------------------------------------------------------------
-- UI相关的接口

-- 创建战场/据点页面的顶部信息栏
function ShengyuanWarsUiHelper:addTopInfoBar(params)
    local topBgSprite = ui.newSprite("jzthd_11.png")
    local topBgSize = topBgSprite:getContentSize()
    topBgSprite:setAnchorPoint(cc.p(0.5, 1))
    topBgSprite:setPosition(params.pos or cc.p(320, 1136))
    topBgSprite:setScale(params.scale or 1)
    params.parent:addChild(topBgSprite)

    -- 关闭按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(1, 0.5),
        position = cc.p(topBgSize.width - 5, topBgSize.height * 0.5),
        clickAction = params.closeAction
    })
    topBgSprite:addChild(btnClose)

    -- 聊天按钮
    local btnChat = ui.newButton({
        normalImage = "tb_32.png",
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(10, topBgSize.height * 0.5),
        clickAction = function()
            ShengyuanWarsUiHelper:showChatPopLayer()
        end
    })
    topBgSprite:addChild(btnChat)

    -- 对外接口：显示资源信息Label
    local needScore = ShengyuanwarsConfig.items[1].winNeedPoint
    topBgSprite.addResLabel = function (target, percent)
        local label = ui.newLabel({
            text = "", 
            color = Enums.Color.eNormalWhite, 
            size = 20, 
            x = topBgSize.width * percent.x, 
            y = topBgSize.height * percent.y, 
            outlineColor = Enums.Color.eBlack
        })
        label:setAnchorPoint(cc.p(0, 0.5))
        target:addChild(label)

        label.resetResString = function (target, isOur)
            if (isOur == true) then
                target:setString(TR("我方积分: %s%d/%d", Enums.Color.eGreenH, (ShengyuanWarsHelper.myTeamName == ShengyuanWarsHelper.teamB) and ShengyuanWarsHelper.BResScore or ShengyuanWarsHelper.AResScore, needScore))
            else
                target:setString(TR("敌方积分: %s%d/%d", Enums.Color.eRedH, (ShengyuanWarsHelper.myTeamName == ShengyuanWarsHelper.teamB) and ShengyuanWarsHelper.AResScore or ShengyuanWarsHelper.BResScore, needScore))
            end
        end

        label.resetBuffString = function (target, isBuff)
            if (isBuff == true) then
                target:setString(TR("神符刷新倒计时: %s%ds", Enums.Color.eNormalYellowH, ShengyuanWarsHelper.buffRemainTime))
            else
                target:setString(TR("积分获取倒计时: %s%ds", Enums.Color.eNormalYellowH, ShengyuanWarsHelper.calcResScoreTime))
            end
        end

        return label
    end

    -- 自动弹出玩家聊天内容
    self:addChatPopupLabel(topBgSprite, cc.p(topBgSize.width * 0.5, 0))
    
    return topBgSprite
end

-- 创建Q版小人
--[[
    leaderModelId   : 主角模型ID
    fashionModelId  : 时装ID，优先读取该参数
--]]
function ShengyuanWarsUiHelper:createPlayerFigure(params)
    local effectZheng, effectFan = nil, nil     -- 正面、反面
    if (params.fashionModelId ~= nil) then
    else
        local playerModelId = params.leaderModelId or FormationObj:getSlotInfoBySlotId(1).ModelId
        playerModelId = playerModelId == 0 and FormationObj:getSlotInfoBySlotId(1).ModelId or playerModelId
        effectZheng, effectFan = QFashionObj:getQFashionLargePic(playerModelId)
    end
    if (effectZheng == nil) then
        return nil
    end
    local figure = ui.newEffect({
        parent = params.parent,
        effectName = effectZheng,
        animation = "daiji",
        scale = params.scale or 1,
        position = params.pos,
        loop = true,
        endRelease = false,
    })

    return figure
end

-- 创建据点里的飞机显示
--[[
    playerId : 玩家id
    {
    clickAction     : 点击事件，如果没有则不能点击
    showName        : 是否显示名字，默认为true
    showHpRate      : 显示血条，默认为true
    showShenfu      : 显示神符列表，默认为false
    showCtrlBtn     : 显示操作按钮，默认为false
    direction       : 人物方向，默认是朝右边
    scale           : 人物缩放，默认为0.5
    }
    LeaderModelId   : 可选，人物形象Q版小人Id
--]]
function ShengyuanWarsUiHelper:createHero(playerId, params, LeaderModelId)
    local playerInfo = nil
    if (playerId ~= nil) then
        playerInfo = ShengyuanWarsHelper:getPlayerData(playerId)
    end
    params = params or {}

    -- 创建（原始大小默认为160*225，根据scale进行缩放）
    local tmpScale = params.scale or 0.5
    local width = 160 * tmpScale
    local height = 225 * tmpScale
    local node = cc.Node:create()
    node:setAnchorPoint(cc.p(0.5, 0))
    node:setContentSize(cc.size(width, height))
    
    local fashionId = playerInfo and playerInfo.ShizhuangModelId or LeaderModelId
    fashionId = fashionId == 0 and playerInfo.LeaderModelId or fashionId
    -- 显示小人
    local figure = self:createPlayerFigure({
        leaderModelId = fashionId,
        parent = node,
        scale = tmpScale,
    })
    if (params.direction ~= nil) then
        if (params.direction == ShengyuanWarsUiHelper.directionTag.eLeftDown) or (params.direction == ShengyuanWarsUiHelper.directionTag.eLeftUp) then
            figure:setRotationSkewY(180)
        end
    end
    figure:setPosition(width * 0.5, 0)
    node.figure = figure
    
    -- 添加点击区域
    if params.clickAction then
        ui.newButton({
            normalImage = "c_83.png",
            size = cc.size(width, height),
            position = cc.p(width*0.5, height*0.5),
            clickAction = params.clickAction,
        }):addTo(node)
    end

    -- 显示名字
    local nameColor = Enums.Color.eNormalWhite      -- 队友显示默认的白色
    if (playerInfo ~= nil) then
        if (PlayerAttrObj:getPlayerAttrByName("PlayerId") == playerId) then
            nameColor = Enums.Color.eGreen          -- 自己显示绿色
        elseif (ShengyuanWarsHelper.myTeamName ~= playerInfo.TeamName) then
            nameColor = Enums.Color.eRed            -- 敌方显示红色
        end
    end
    local nameLabel = ui.newLabel({
        text = (playerInfo == nil) and "" or (playerInfo.PlayerName or playerInfo.Name),
        size = 22,
        color = nameColor,
        outlineColor = Enums.Color.eBlack,
        x = width / 2,
        y = height + 10,
    })
    nameLabel:setAnchorPoint(cc.p(0.5, 0))
    nameLabel:setVisible((playerInfo ~= nil) and (params.showName == nil) or (params.showName == true))
    node:addChild(nameLabel)
    
    -- 显示血条
    local hpBar = require("common.ProgressBar"):create({
        bgImage = "jzthd_17.png",
        barImage = "jzthd_16.png",
        currValue = 0,
        maxValue = 1,
        needLabel = false,
    })
    hpBar:setAnchorPoint(cc.p(0.5, 0))
    hpBar:setPosition(width * 0.5, height)
    hpBar:setTag(ShengyuanWarsUiHelper.playerTag.XueTiao)
    node:addChild(hpBar)
    node.hpBar = hpBar

    -- 对外接口：刷新血条
    node.refreshHpBar = function (target)
        playerInfo = ShengyuanWarsHelper:getPlayerData(playerId)
        target.hpBar:setMaxValue(playerInfo.TotalHp or 1)
        target.hpBar:setCurrValue(playerInfo.Hp or 0)
    end
    if (playerInfo ~= nil) and ((params.showHpRate == nil) or (params.showHpRate == true)) then
        node:refreshHpBar()
    else
        node.hpBar:setVisible(false)
    end
    
    -- 对外接口：显示/隐藏神符图片
    node.refreshBuff = function (target, isVisible)
        playerInfo = ShengyuanWarsHelper:getPlayerData(playerId)
        for _,v in ipairs({ShengyuanWarsUiHelper.playerTag.PoLing, ShengyuanWarsUiHelper.playerTag.ShuangBei, ShengyuanWarsUiHelper.playerTag.ShiXue}) do
            if node:getChildByTag(v) then 
                node:getChildByTag(v):removeFromParent()
            end
        end
        if (not playerInfo.Buff) or (isVisible == false) then 
            return 
        end
        local function addShenfuSprite(tag, pos)
            local tmpSprite = ui.newSprite(ShengyuanwarsBuffModel.items[tag].insidePic .. ".png")
            tmpSprite:setAnchorPoint(cc.p(0.5, 1))
            tmpSprite:setPosition(pos)
            tmpSprite:setTag(tag)
            node:addChild(tmpSprite, 1)
        end

        -- 读取需要添加的珠子
        local xPosList = {
            [2] = {width*0.35, width*0.65},
            [3] = {width*0.5, width*0.2, width * 0.8},
        }
        local addList = {}
        if playerInfo.Buff["1"] and playerInfo.Buff["1"] == -1 then 
            table.insert(addList, ShengyuanWarsUiHelper.playerTag.PoLing)
        end
        if playerInfo.Buff["3"] and playerInfo.Buff["3"] > 0 then 
            table.insert(addList, ShengyuanWarsUiHelper.playerTag.ShuangBei)
        end
        if playerInfo.Buff["4"] and playerInfo.Buff["4"] > 0 then 
            table.insert(addList, ShengyuanWarsUiHelper.playerTag.ShiXue)
        end
        -- 依次添加
        local xPos = (#addList == 2) and xPosList[2] or xPosList[3]
        for i,v in ipairs(addList) do
            addShenfuSprite(v, cc.p(xPos[i], height - 2))
        end
    end
    if playerInfo then
        node:refreshBuff(params.showShenfu)
    end
    
    -- 显示挑战按钮
    local lookPosX = width * 0.5     -- 查看按钮的位置
    local btnFight = nil
    if (playerInfo ~= nil) and ShengyuanWarsHelper.myTeamName and (ShengyuanWarsHelper.myTeamName ~= playerInfo.TeamName) then
        -- 不是我方的玩家，才显示挑战按钮
        btnFight = ui.newButton({
            normalImage = "jzthd_46.png",
            position = cc.p(width * 0.75, height - 50),
            clickAction = function ()
                ShengyuanWarsHelper:playerFight(playerId, ShengyuanWarsHelper.enterResInfo.PointId, function(info)
                    end)
            end
        })
        node:addChild(btnFight, 1)
        lookPosX = width * 0.25
    end

    -- 显示查看按钮
    local btnLook = ui.newButton({
        normalImage = "jzthd_47.png",
        position = cc.p(lookPosX, height - 50),
        clickAction = function ()
            local clickItem = {ModelId = playerInfo.MountModelId, Guid = playerInfo.PlayerId, Name = (playerInfo.PlayerName or playerInfo.Name)}
            ShengyuanWarsUiHelper:showLookPopLayer(clickItem)
        end
    })
    node:addChild(btnLook, 1)

    -- 对外接口：显示/隐藏操作按钮
    node.showCtrlBtn = function (target, isVisible)
        node.isShowVisible = (isVisible ~= nil) and (isVisible == true)
        btnLook:setVisible(node.isShowVisible)
        if btnFight then
            btnFight:setVisible(node.isShowVisible)
        end
    end
    node:showCtrlBtn((playerInfo ~= nil) and params.showCtrlBtn)
    
    -- 对外接口：人物走路/停止
    node.heroRun = function (target, isRun)
        if (isRun ~= nil) and (isRun == true) then
            if (target.figure.isRunn == nil) or (target.figure.isRunn == false) then
                target.figure.isRunn = true
                target.figure:setToSetupPose()
                target.figure:setAnimation(0, "zou", true)
            end
        else
            if (target.figure.isRunn ~= nil) and (target.figure.isRunn == true) then
                target.figure.isRunn = false
                target.figure:setAnimation(0, "daiji", true)
            end
        end
    end

    return node
end

-- 创建小船
--[[
    {
    MountModelId        : 必选，对应的小船
    PlayerId            : 可选，玩家ID，默认显示Q版小人
    LeaderModelId       : 可选，玩家主角Q版形象Id
    showWave            : 可选，是否显示波浪动画，默认为true
    direction           : 可选，小船的方向，默认是 ShengyuanWarsUiHelper.directionTag.eRightUp
    }
    clickCallback       : 可选，点击回调
--]]
function ShengyuanWarsUiHelper:createBoat(item, clickCallback)
    -- 处理参数
    local mountInfo = GoddomainMountModel.items[item.MountModelId] or {}
    if (mountInfo.pic == nil) or (mountInfo.backPic == nil) then
        return nil
    end
    
    local nodeSize = cc.size(10, 10)
    local retNode = ui.newScale9Sprite("c_83.png", nodeSize)
    
    -- 在不同方向情况下人物的站位偏移
    local heroRateList = {
        [ShengyuanWarsUiHelper.directionTag.eRightUp] = {[25010001] = {x = 0.65, y = 0.25}, [25010002] = {x = 0.61, y = 0.26}, [25010003] = {x = 0.75, y = 0.35}, [25010004] = {x = 0.6, y = 0.3}, [25010005] = {x = 0.75, y = 0.4}, [25010006] = {x = 0.75, y = 0.35}},
        [ShengyuanWarsUiHelper.directionTag.eRightDown] = {[25010001] = {x = 0.65, y = 0.18}, [25010002] = {x = 0.6, y = 0.16}, [25010003] = {x = 0.75, y = 0.16}, [25010004] = {x = 0.7, y = 0.2}, [25010005] = {x = 0.69, y = 0.2}, [25010006] = {x = 0.7, y = 0.2}},
        [ShengyuanWarsUiHelper.directionTag.eLeftUp] = {[25010001] = {x = 0.4, y = 0.25}, [25010002] = {x = 0.4, y = 0.26}, [25010003] = {x = 0.25, y = 0.35}, [25010004] = {x = 0.35, y = 0.31}, [25010005] = {x = 0.25, y = 0.4}, [25010006] = {x = 0.25, y = 0.35}},
        [ShengyuanWarsUiHelper.directionTag.eLeftDown] = {[25010001] = {x = 0.37, y = 0.16}, [25010002] = {x = 0.41, y = 0.16}, [25010003] = {x = 0.25, y = 0.15}, [25010004] = {x = 0.3, y = 0.2}, [25010005] = {x = 0.33, y = 0.2}, [25010006] = {x = 0.25, y = 0.2}},
    }
    -- 在不同方向情况下波浪的位置偏移
    local waveRateList = {
        [ShengyuanWarsUiHelper.directionTag.eRightUp] = {[25010001] = {x = 0.32, y = 0.15}, [25010002] = {x = 0.35, y = 0.15}, [25010003] = {x = 0.35, y = 0.2}, [25010004] = {x = 0.35, y = 0.2}, [25010005] = {x = 0.4, y = 0.25}, [25010006] = {x = 0.4, y = 0.25}},
        [ShengyuanWarsUiHelper.directionTag.eRightDown] = {[25010001] = {x = 0.2, y = 0.35}, [25010002] = {x = 0.25, y = 0.3}, [25010003] = {x = 0.3, y = 0.35}, [25010004] = {x = 0.35, y = 0.35}, [25010005] = {x = 0.3, y = 0.35}, [25010006] = {x = 0.2, y = 0.3}},
        [ShengyuanWarsUiHelper.directionTag.eLeftUp] = {[25010001] = {x = 0.75, y = 0.14}, [25010002] = {x = 0.7, y = 0.15}, [25010003] = {x = 0.75, y = 0.18}, [25010004] = {x = 0.7, y = 0.2}, [25010005] = {x = 0.7, y = 0.25}, [25010006] = {x = 0.65, y = 0.2}},
        [ShengyuanWarsUiHelper.directionTag.eLeftDown] = {[25010001] = {x = 0.85, y = 0.36}, [25010002] = {x = 0.85, y = 0.32}, [25010003] = {x = 0.75, y = 0.38}, [25010004] = {x = 0.75, y = 0.4}, [25010005] = {x = 0.72, y = 0.35}, [25010006] = {x = 0.75, y = 0.33}},
    }
    -- 刷新buff
    local function refreshBuff()
    	local playerInfo = ShengyuanWarsHelper:getPlayerData(item.PlayerId)
    	if not playerInfo then return end

    	-- 屏蔽特效显示
		if retNode.skillEffect001 and not tolua.isnull(retNode.skillEffect001) then retNode.skillEffect001:setVisible(false) end
		
		-- 添加特效
    	for _, skillInfo in pairs(playerInfo.ReceiveActiveSkillInfo or {}) do
    		-- 加速光圈
    		if skillInfo.SkillId == 11001001 or skillInfo.SkillId == 11001002 then
    			-- 创建特效
    			if not retNode.skillEffect001 or tolua.isnull(retNode.skillEffect001) then
    				retNode.skillEffect001 = ui.newEffect({
    					parent = retNode,
    					effectName = "effect_ui_taohuadao",
    					animation = "guangquan",
    					loop = true,
    					zorder = -1,
    					position = cc.p(90, 60)
    				})
    			end
    			-- 显示/隐藏特效
				retNode.skillEffect001:setVisible(skillInfo.ValidTime > 0)
                retNode.skillEffect001:setScale(skillInfo.SkillId == 11001002 and 0.8 or 1)
    		end
    	end
    end

    -- 刷新小船
    local function refreshBoat(direction)
        -- 设置方向
        if (retNode.direction ~= nil) and (retNode.direction == direction) then
            return
        end
        retNode.direction = direction

        -- 重建船体
        local boatImg, skewY = nil, 0
        if (direction == ShengyuanWarsUiHelper.directionTag.eLeftDown) or (direction == ShengyuanWarsUiHelper.directionTag.eRightDown) then
            boatImg = mountInfo.pic .. ".png"
            skewY = (direction == ShengyuanWarsUiHelper.directionTag.eLeftDown) and 0 or 180
        else
            boatImg = mountInfo.backPic .. ".png"
            skewY = (direction == ShengyuanWarsUiHelper.directionTag.eRightUp) and 0 or 180
        end
        local boatSprite = ui.newSprite(boatImg)
        boatSprite:setRotationSkewY(skewY)
        
        -- 重设node
        nodeSize = boatSprite:getContentSize()
        retNode:removeAllChildren()
        retNode:setContentSize(nodeSize)
        
        -- 重建波浪
        local animationName = nil
        if (direction == ShengyuanWarsUiHelper.directionTag.eLeftDown) or (direction == ShengyuanWarsUiHelper.directionTag.eRightDown) then
            animationName = "qian"
            skewY = (direction == ShengyuanWarsUiHelper.directionTag.eLeftDown) and 0 or 180
        else
            animationName = "hou"
            skewY = (direction == ShengyuanWarsUiHelper.directionTag.eRightUp) and 0 or 180
        end
        local waveRate = waveRateList[direction][item.MountModelId]
        retNode.waveEffect = ui.newEffect({
            parent = retNode,
            effectName = "effect_ui_chuanshuibo",
            animation = animationName,
            position = cc.p(nodeSize.width * waveRate.x, nodeSize.height * waveRate.y),
            loop = true,
        })
        retNode.waveEffect:setRotationSkewY(skewY)

        -- 添加船体
        boatSprite:setPosition(nodeSize.width * 0.5, nodeSize.height * 0.5)
        retNode:addChild(boatSprite)
        retNode.boatSprite = boatSprite

        item.ShizhuangModelId = item.ShizhuangModelId or item.LeaderModelId or QFashionObj:getQFashionModelIdByDressType(1)
        -- 船头站立的小人
        local heroNode = ShengyuanWarsUiHelper:createHero(item.PlayerId, {scale = 0.5, direction = direction, clickAction = clickCallback}, item.ShizhuangModelId or nil)
        local heroRate = heroRateList[direction][item.MountModelId]
        heroNode:setPosition(nodeSize.width * heroRate.x, nodeSize.height * heroRate.y)
        retNode:addChild(heroNode)
        retNode.heroNode = heroNode
        retNode.heroRate = heroRate
    end
    refreshBoat(item.direction or ShengyuanWarsUiHelper.directionTag.eRightUp)

    -- 封装直接旋转的接口
    retNode.resetRotate = function (target, rotate)
        local newRotate = rotate
        if (newRotate < 0) then
            newRotate = newRotate + 360
        end
        if (newRotate >= 360) then
            newRotate = newRotate % 360
        end
        if (newRotate <= 90) then
            refreshBoat(ShengyuanWarsUiHelper.directionTag.eRightUp)
        elseif (newRotate <= 180) then
            refreshBoat(ShengyuanWarsUiHelper.directionTag.eRightDown)
        elseif (newRotate <= 270) then
            refreshBoat(ShengyuanWarsUiHelper.directionTag.eLeftDown)
        else
            refreshBoat(ShengyuanWarsUiHelper.directionTag.eLeftUp)
        end

        -- 刷新buff
        refreshBuff()
    end

    -- buff特效刷新
    retNode.refreshBuff = function (target)
    	refreshBuff()
    end

    -- 初始化刷新buff
    refreshBuff()

    return retNode
end

----------------------------------------------------------------------------------------------------
-- 下面是专门处理据点页面飞机缓存的一些辅助接口

-- 辅助接口：在人物列表里查找某个玩家是否存在
local function findItemInPlayerList(tmpList, tmpId)
    local flag = false
    for _, id in ipairs(tmpList or {}) do
        if tmpId == id then
            flag = true
            break
        end
    end
    return flag
end

-- 辅助接口：删除某个显示的飞机
local function delOnePlaneNode(planeList, delId)
    for _, planInfo in ipairs(planeList or {}) do
        if planInfo.Id == delId then
            planInfo.plan:removeFromParent()
            planInfo.plan = nil
            planInfo.Id = nil
            break
        end
    end
end

-- 辅助接口：获取飞机数量
local function getPlaneCount(planeList)
    local count = 0
    for _, planInfo in ipairs(planeList) do
        if planInfo.Id ~= nil then
            count = count + 1
        end
    end
    return count
end

-- 获得应该添加的id列表
function ShengyuanWarsUiHelper:getTeamAddList(currPlayerList, lastPlayerList)
    local list = {}

    for _, cid in ipairs(currPlayerList or {}) do
        local flag = findItemInPlayerList(lastPlayerList, cid)
        if not flag then
            table.insert(list, cid)
        end
    end

    return list
end

-- 获得应该删除的id列表
function ShengyuanWarsUiHelper:getTeamDelList(currPlayerList, lastPlayerList)
    local list = {}

    for _, cid in ipairs(lastPlayerList or {}) do
        local flag = findItemInPlayerList(currPlayerList, cid)
        if not flag then
            table.insert(list, cid)
        end
    end

    return list
end

-- 删除应该被删除的飞机
function ShengyuanWarsUiHelper:deletePlaneInTeam(planeList, delList)
    if next(delList) == nil then
        return
    end

    for _, did in ipairs(delList) do
        delOnePlaneNode(planeList, did)
    end
end

-- 添加飞机
function ShengyuanWarsUiHelper:addPlaneToTeam(target, planeList, addlist, posList)
    if next(addlist) == nil then
        return
    end
    
    -- 补空位
    local remainList = clone(addlist)
    local index = 1
    for k, planInfo in ipairs(planeList) do
        if (planInfo.Id == nil) and addlist[index] then
            planInfo.Id = addlist[index]
            planInfo.plan = target:addPlane(planInfo.Id, posList[k])
            index = index + 1
            table.remove(remainList, 1)
        end
    end
    if next(remainList) == nil then 
        return 
    end
    
    -- 往后加
    local planeNum = getPlaneCount(planeList)
    for k, id in ipairs(remainList) do
        local posid = planeNum + k
        local planInfo = {}
        planInfo.Id = id
        planInfo.plan = target:addPlane(planInfo.Id, posList[posid])
        table.insert(planeList, planInfo)
    end
end

-- 创建技能图标
--[[
params:
	parent 		-- 父节点(必须)
	range 		-- 范围(0:城外,1:城中)(必须)
	pos 		-- 坐标（默认cc.p(540, 200))
	callback 	-- 技能点击回调
]]
function ShengyuanWarsUiHelper:createSKillBtn(params)
	local pos = params.pos or cc.p(540, 200)

	local ownPlayerInfo = ShengyuanWarsHelper:getPlayerData()
	local shizhuangModelId = ownPlayerInfo and ownPlayerInfo.ShizhuangModelId or 0
	local shizhuangModel = ShizhuangModel.items[shizhuangModelId]
	-- 没有时装
	if not shizhuangModel then
		return
	end
	-- 时装没技能或不是主动技能
	local buffModel = ShizhuangBuffModel.items[shizhuangModel.shengyuanSkill]
	if not buffModel or buffModel.buffFireType ~= 1 or (buffModel.useRange ~= 2 and buffModel.useRange ~= params.range) then
		return
	end

	-- 创建技能按钮
	local skillBtn = ui.newButton({
		normalImage = shizhuangModel.skillPic..".png",
		clickAction = function () end,
	})
	skillBtn:setPosition(pos)
	params.parent:addChild(skillBtn, 10)

	-- 冷却状态
	local function skillCdState(cdTime)
		-- 置灰
		skillBtn:setEnabled(false)
		-- 冷却进度
		local maskSprite = ui.newSprite("syzb_58.png")
		local configCD = buffModel.CD + ShengyuanWarsHelper.testTime
        local progress = cc.ProgressTimer:create(maskSprite)
        progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        progress:setReverseDirection(true)
        progress:setMidpoint(cc.p(0.5,0.5))
        progress:setPosition(cc.p(0,0))
        progress:setPercentage((cdTime*1.0/configCD)*100)
        skillBtn:getExtendNode2():addChild(progress,99)

        -- 进度动作
        local tKillCD = cdTime -- 技能Cd[配置] 临时+300秒  
        local to1 = cc.Sequence:create(cc.ProgressTo:create(tKillCD, 0), cc.CallFunc:create(function ()
        	skillBtn:setEnabled(true)
            progress:removeFromParent()
        end))
        progress:runAction(to1)

        -- 冷却数字显示
        local cdLabel = ui.newLabel({
            text = TR("%d",tKillCD),
            size = 32,
            outlineColor = Enums.Color.eBlack,
        })
        cdLabel:setAnchorPoint(0.5, 0.5)
        cdLabel:setPosition(cc.p(51,51))
        progress:addChild(cdLabel)
        cdLabel.time = tKillCD
        Utility.schedule(cdLabel, function ()
            cdLabel.time = cdLabel.time - 1
            cdLabel:setString(TR("%d", cdLabel.time))   
        end, 1.0)
	end

	-- 释放技能回调
	skillBtn:setClickAction(function()
		-- 释放技能
		ShengyuanWarsHelper:playerGiveOffSkill(shizhuangModel.shengyuanSkill, function (response)
			if response.Code < 0 then
				ui.showFlashView(TR("技能冷却中"))
				return
			end
			-- 进入冷却状态
			skillCdState(buffModel.CD + ShengyuanWarsHelper.testTime)

			if params.callback then
				params.callback(shizhuangModel.shengyuanSkill)
			end
		end)
	end)

	-- 初始化按钮状态
	local skillInfo = nil
	for _, skillsInfo in pairs(ownPlayerInfo.ActiveSkillsInfo) do
		if skillsInfo.SkillId == buffModel.buffID then
			skillInfo = skillsInfo
		end
	end

	if skillInfo and skillInfo.CdTime > 0 then
		skillCdState(ownPlayerInfo.ActiveSkillsInfo[1].CdTime)
	end
	-- skillCdState(math.floor(buffModel.CD*0.5))

	return skillBtn
end

function ShengyuanWarsUiHelper:getWaterWaveShader()
    local cache = cc.GLProgramCache:getInstance()
    local name = "MQ_ShaderWaterWave"
    local shader = cache:getGLProgram(name)

    if not shader then
        shader = cc.GLProgram:createWithByteArrays(
            -- vertex shader
            [[
                attribute vec4 a_position;
                attribute vec2 a_texCoord;

                #ifdef GL_ES
                varying mediump vec2 v_texCoord;
                #else
                varying vec2 v_texCoord;
                #endif

                void main()
                {
                    gl_Position = CC_PMatrix * a_position;
                    v_texCoord = a_texCoord;
                }
            ]],
            -- fragment shader
            [[
                varying vec2 v_texCoord;
                uniform sampler2D u_normalMap;

                vec3 waveNormal(vec2 p) {
                    vec3 normal = texture2D(u_normalMap, p).xyz;
                    normal = -1.0 + normal * 2.0;
                    return normalize(normal);
                }

                void main()
                {
                    float timeFactor = 0.1;     // 波动频率
                    float offsetFactor = 0.15;  // 波动幅度
                    float refractionFactor = 0.7;  
                       
                    // simple UV animation  
                    vec3 normal = waveNormal(v_texCoord + vec2(CC_Time.y * timeFactor, CC_Time.x * timeFactor));  
                       
                    // simple calculate refraction UV offset  
                    vec2 p = -1.0 + 2.0 * v_texCoord;  
                    vec3 eyePos = vec3(0, 0, 10); //眼睛位置 位于中心点正上方  
                    vec3 inVec = normalize(vec3(p, 0) - eyePos);  
                    vec3 refractVec = refract(inVec, normal, refractionFactor);  //根据入射向量，法线，折射系数计算折射向量
                    vec2 v_texCoordN = v_texCoord;
                    v_texCoordN += refractVec.xy * offsetFactor;    
                    //v_texCoordN.x -= CC_Time.y*timeFactor *0.6; //移动水面贴图，可选
                       
                    gl_FragColor = texture2D(CC_Texture0, v_texCoordN);  
                }
            ]]
        )
        cache:addGLProgram(shader, name)
    end

    return shader
end

-- 创建水波背景
function ShengyuanWarsUiHelper:createWaveWaterSprite(imageName)
    local waveSprite = ui.newSprite(imageName)
    local normalTexture = cc.Director:getInstance():getTextureCache():addImage("jzthd_80.jpg")
    normalTexture:setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    -- 创建wave program
    local waveShader = self:getWaterWaveShader()
    local programState = cc.GLProgramState:create(waveShader)
    programState:setUniformTexture("u_normalMap", normalTexture:getName())
    waveSprite:setGLProgramState(programState)

    return waveSprite
end

----------------------------------------------------------------------------------------------------