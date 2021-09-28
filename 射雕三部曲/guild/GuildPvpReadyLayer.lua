--[[
    文件名: GuildPvpReadyLayer
    描述: 帮派战的准备和决战页面
    创建人: peiyaoqiang
    创建时间: 2018.01.03
-- ]]

local GuildPvpReadyLayer = class("GuildPvpReadyLayer",function()
	return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
    {
    }
]]
function GuildPvpReadyLayer:ctor(params)
    -- 读取参数
    params = params or {}
    self.ourScrollPos = params.ourScrollPos
    self.enemyScrollPos = params.enemyScrollPos
    self.nowIsEnemy = params.defaultShowEnemy
    self.playerOfAutoCamp = params.autoCampPlayer
    self.campFromDlgPop = params.campFromDlgPop
    self.mPlayerNodeList = {}
    self.isBattleDay = false
    
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer, 1)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    
    -- 初始化页面
    self:initUI()

    -- 获取帮派战的信息
    self:requestGetBattleInfo()

    -- 注册积分变化事件
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        if (self.titleBgNode == nil) or (data == nil) then
            return
        end
        local ourPlayerList = GuildObj:getGuildBattlePlayerInfo()
        local enemyPlayerList = GuildObj:getMatchGuildBattlePlayerInfo()
        if (self.titleBgNode.oursProgress ~= nil) then
            self.titleBgNode.oursProgress:refreshShow(enemyPlayerList)
            self.titleBgNode.enemyProgress:refreshShow(ourPlayerList)
        end
        if (self.titleBgNode.oursStarLabel ~= nil) then
            self.titleBgNode.oursStarLabel:setString(GuildObj:calcStarNum(enemyPlayerList))
            self.titleBgNode.enemyStarLabel:setString(GuildObj:calcStarNum(ourPlayerList))
        end
        if (self.mPlayerNodeList[data.PlayerId] ~= nil) then
            self.mPlayerNodeList[data.PlayerId]:refreshStarNode(data.Score or 0)
        end
    end,
    {EventsName.eGuildBattleScore})
end

-- 初始化页面
function GuildPvpReadyLayer:initUI()
    local btnList = {
        { -- 关闭
        normalImage = "c_29.png",
        position = cc.p(604, 1040),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
        },
        { -- 规则
        normalImage = "c_72.png",
        position = cc.p(36, 1040),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("一、准备日"),
                TR("1.每两周为一个赛季，共7轮帮派战"),
                TR("2.一个准备日和决战日即为一轮帮派战"),
                TR("3.帮派战报名时间为：每日的0点到23:30"),
                TR("4.准备日23:30到次日8:00为读取玩家阵容信息时间，请不要在该时间段内进行人物、装备下阵等降战力的操作"),
                TR("5.报名成功的帮派可在准备日进行招募佣兵和布阵等操作以应对即将到来的对手"),
                TR("6.如果在准备日报名帮派战，则次日即可开战；如果在决战日报名帮派战，则提前进入下一轮准备日阶段，需要等到下一轮决战日才能开战"),
                TR("7.帮主和副帮主可以给帮派成员招募佣兵和布阵，其他帮派成员只能给自己招募佣兵和布阵"),
                " ",
                TR("二、决战日"),
                TR("1.决战日的时候可选择对方帮派任意成员进行挑战或切磋，但同一个玩家只能对其进行一次挑战或切磋"),
                TR("2.击败对方任意3个角色可得1颗星，击败对方主角可再得1颗星，全灭对方的话可得3颗星，只要获得至少1可星即为战斗胜利"),
                TR("3.只能挑战尚未被3星的敌帮成员，已经被3星的敌帮成员只能和其进行切磋"),
                TR("4.每次帮派战每个玩家都有2次挑战和5次切磋机会"),
                TR("5.每次挑战和切磋都能获得帮派战积分和帮派武技，数量多少和本次挑战的敌帮成员序号以及获得的星级评价有关"),
                " ",
                TR("三、结算"),
                TR("1.帮派战胜负根据本次帮派战的总星数比分判定，获得总星数多的帮派胜利"),
                TR("2.胜利的帮派每人可额外获得积分和帮派武技（本轮帮派战没有获得积分的成员不会额外获得任何奖励）"),
                TR("3.帮派战中获得的帮派武技会在帮派战结束后通过领奖中心发放，发奖期间退出或加入其它帮派将不会收到帮派武技奖励"),
                TR("4.个人排行按照本赛季个人在帮派战获得的积分排名，帮派排行则是帮派所有人获得的积分累计排行，排行奖励会在赛季结束时发放"),
            })
        end
        },
        { -- 排行榜
        normalImage = "tb_16.png",
        position = cc.p(60, 330),
        clickAction = function()
            LayerManager.addLayer({name = "guild.GuildPvpRankLayer", cleanUp = true,})
        end
        },
        { -- 战利品
        normalImage = "tb_240.png",
        position = cc.p(60, 430),
        clickAction = function()
            self:battleRewardClickAction()
        end
        },
        { -- 往期战报
        normalImage = "tb_198.png",
        position = cc.p(60, 230),
        clickAction = function ()
            LayerManager.addLayer({
                    name = "guild.GuildPvpReportLayer",
                    cleanUp = false,
                })
        end,
        },
        { -- 防守布阵
        normalImage = "tb_11.png",
        position = cc.p(60, 530),
        clickAction = function ()
            local ourPlayerList = GuildObj:getGuildBattlePlayerInfo()
            for _,v in pairs(ourPlayerList) do
                if (v.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
                    self:playerCamp(v)
                    break
                end
            end
        end,
        },
    }
    for _,v in ipairs(btnList) do
       local button = ui.newButton(v)
       self.mParentLayer:addChild(button, 1)
    end

    -- 创建标题栏
    self:createTitleNode()

    -- 创建空白的人物列表和切换按钮，先全部隐藏不显示
    local function lookEnemyAction()
        local xOffset = (self.nowIsEnemy == true) and 640 or -640
        self.nowIsEnemy = (not self.nowIsEnemy)
        self.ourScrollView:runAction(cc.MoveBy:create(0.3, cc.p(xOffset, 0)))
        self.enemyScrollView:runAction(cc.MoveBy:create(0.3, cc.p(xOffset, 0)))
        self.ourLookBtn:setVisible(self.nowIsEnemy)
        self.enemyLookBtn:setVisible(not self.nowIsEnemy)
    end
    local function createLookButton(img, posX)
        local button = ui.newButton({
            normalImage = img,
            position = cc.p(posX, 600),
            clickAction = lookEnemyAction,
        })
        button:setVisible(false)
        self.mParentLayer:addChild(button, 1)
        return button
    end
    -- 我方人物列表
    self.ourScrollView = self:createPlayerScroll(false)
    if (self.ourScrollPos ~= nil) then
        self.ourScrollView:getInnerContainer():setPosition(self.ourScrollPos)
    end
    -- 敌方人物列表
    self.enemyScrollView = self:createPlayerScroll(true)
    if (self.enemyScrollPos ~= nil) then
        self.enemyScrollView:getInnerContainer():setPosition(self.enemyScrollPos)
    end
    -- 帮派切换按钮
    self.ourLookBtn = createLookButton("bpz_13.png", 36)
    self.enemyLookBtn = createLookButton("bpz_14.png", 604)
end

-- 刷新页面
function GuildPvpReadyLayer:refreshUI()
    -- 显示查看敌人的按钮
    self.enemyLookBtn:setVisible(false)
    self.ourLookBtn:setVisible(false)
    if (self.isBattleDay == true) then
        -- 决战日默认显示敌方帮派（如果它不是nil，说明页面重建的时候有参数传入，此时不要修改）
        if (self.nowIsEnemy == nil) then
            self.nowIsEnemy = true
        end
        -- 显示切换查看的按钮
        self.enemyLookBtn:setVisible(not self.nowIsEnemy)
        self.ourLookBtn:setVisible(self.nowIsEnemy)
        -- 切换帮派人物列表的位置
        if (self.nowIsEnemy == true) then
            self.ourScrollView:setPositionX(320 - 640)
            self.enemyScrollView:setPositionX(320)
        end
    else
        -- 准备日不让显示敌人帮派
        self.nowIsEnemy = false
    end
    
    -- 刷新标题
    self.titleBgNode:refreshShow(self.mBattleInfo)
end

-- 获取恢复数据
function GuildPvpReadyLayer:getRestoreData()
    local retData = {
        defaultShowEnemy = self.nowIsEnemy,
        ourScrollPos = cc.p(self.ourScrollView:getInnerContainer():getPosition()),
        enemyScrollPos = cc.p(self.enemyScrollView:getInnerContainer():getPosition()),
        autoCampPlayer = self.playerOfAutoCamp,
        campFromDlgPop = self.campFromDlgPop,
    }

    return retData
end

----------------------------------------------------------------------------------------------------

-- 创建标题栏
function GuildPvpReadyLayer:createTitleNode()
    -- 辅助接口：创建Label
    local function addTitleLabel(strText, fontSize, anchor, pos)
        local label = ui.newLabel({
            text = strText,
            size = fontSize or 20,
        })
        label:setAnchorPoint(anchor)
        label:setPosition(pos)
        self.titleBgNode:addChild(label)
        return label
    end
    -- 辅助接口：创建进度条
    local function addProgressBar(barImg, anchor, pos)
        local progressBar = require("common.ProgressBar").new({
            contentSize = cc.size(175, 25),
            bgImage = "c_83.png",
            barImage = barImg,
            currValue = 0,
            maxValue = 1,
            barType = ProgressBarType.eHorizontal,
            })
        progressBar:setAnchorPoint(anchor)
        progressBar:setPosition(pos)
        progressBar.refreshShow = function (target, newList)
            if (newList ~= nil) then
                target:setMaxValue(3 * table.nums(newList)) -- 每个玩家最多3颗星
                target:setCurrValue(GuildObj:calcStarNum(newList))
            end
        end
        self.titleBgNode:addChild(progressBar)
        return progressBar
    end

    -- 标题栏Node
    if (self.titleBgNode == nil) then
        self.titleBgNode = cc.Node:create()
        self.mParentLayer:addChild(self.titleBgNode, 1)
    end
    self.titleBgNode.refreshShow = function (target, info)
        target:removeAllChildren()
        target.oursProgress, target.enemyProgress = nil, nil
        target.oursStarLabel, target.enemyStarLabel = nil, nil
        if (info == nil) then
            return
        end

        -- 刷新内容
        if (self.isBattleDay == true) then
            local progressBgSprite = ui.newSprite("bpz_15.png")
            progressBgSprite:setPosition(320, 1013)
            target:addChild(progressBgSprite)

            -- 我方的进度条
            target.oursProgress = addProgressBar("bpz_17.png", cc.p(0, 0.5), cc.p(79, 1012))
            target.oursProgress:setMidpoint(cc.p(1, 0))
            target.oursProgress:refreshShow(info.MatchGuildBattlePlayerInfo)
            -- 敌方的进度条
            target.enemyProgress = addProgressBar("bpz_16.png", cc.p(1, 0.5), cc.p(560, 1012))
            target.enemyProgress:refreshShow(info.GuildBattlePlayerInfo)
            
            -- 积分黑色背景
            local blackBgSprite = ui.newSprite("c_55.png")
            blackBgSprite:setScaleX(9)
            blackBgSprite:setScaleY(1.5)
            blackBgSprite:setPosition(320, 980)
            target:addChild(blackBgSprite)

            -- 显示星星图案
            for _,v in ipairs({240, 400}) do
                local starSprite = ui.newSprite("c_75.png")
                starSprite:setScale(0.8)
                starSprite:setPosition(v, 980)
                target:addChild(starSprite, 1)
            end

            -- 显示星星数量
            local function addStarLabel(num, anchor, pos)
                local label = ui.newLabel({
                    text = num,
                    size = 18,
                    outlineColor = cc.c3b(0x0F, 0x0F, 0x0F),
                })
                label:setAnchorPoint(anchor)
                label:setPosition(pos)
                target:addChild(label)
                return label
            end
            target.oursStarLabel = addStarLabel(GuildObj:calcStarNum(info.MatchGuildBattlePlayerInfo), cc.p(1, 0.5), cc.p(225, 979))
            target.enemyStarLabel = addStarLabel(GuildObj:calcStarNum(info.GuildBattlePlayerInfo), cc.p(0, 0.5), cc.p(415, 979))

            -- 显示挑战和切磋次数
            local function addNumLabel(strName, curNum, pos)
                local label = ui.newLabel({
                    text = strName .. ((curNum > 0) and Enums.Color.eGreenH or Enums.Color.eRedH) .. " " .. curNum,
                    size = 20,
                    outlineColor = cc.c3b(0x0F, 0x0F, 0x0F),
                })
                label:setAnchorPoint(cc.p(0, 0.5))
                label:setPosition(pos)
                target:addChild(label)
            end
            addNumLabel(TR("我的挑战次数:"), info.PlayerGuildBattleInfo.ChallengeNum, cc.p(10, 950))
            addNumLabel(TR("我的切磋次数:"), info.PlayerGuildBattleInfo.RollingNum, cc.p(10, 920))
        end

        -- 标题背景
        local titleBgSprite = ui.newSprite("bpz_09.png")
        titleBgSprite:setPosition(320, 995)
        target:addChild(titleBgSprite)

        -- 标题Label
        local timerLabel = addTitleLabel("", 18, cc.p(0.5, 0.5), cc.p(320, 989))
        local endTime = info.FightEndTime or 0
        if not self.isBattleDay then
            endTime = info.EnrollEndTime or 0
        end
        Utility.schedule(timerLabel, function()
            local lastTime = endTime - Player:getCurrentTime()
            if (lastTime > 0) then
                timerLabel:setString(Enums.Color.eGreenH .. MqTime.formatAsHour(lastTime))
            else
                -- 倒计时结束后不让进入，最后半个小时为匹配和结算时间
                LayerManager.removeLayer(self)
                ui.showFlashView(TR("正在匹配对手或结算奖励，请稍后"))
            end
        end, 0.5)
        addTitleLabel((self.isBattleDay == true) and TR("决战日") or TR("准备日"), 20, cc.p(0.5, 0.5), cc.p(320, 1012))

        -- 名字背景
        local titleBgSprite = ui.newSprite("bpz_08.png")
        titleBgSprite:setPosition(320, 1050)
        target:addChild(titleBgSprite)

        -- 帮派名字
        local myGuildInfo = GuildObj:getGuildInfo() or {}
        local myGuildName = TR("等级%s %s%s", myGuildInfo.Lv, Enums.Color.eYellowH, myGuildInfo.Name)
        if (self.isBattleDay == true) then
            -- 显示VS标志
            local vsSprite = ui.newSprite("zdjs_07.png")
            vsSprite:setScale(0.7)
            vsSprite:setPosition(320, 1055)
            target:addChild(vsSprite)

            -- 显示自己和敌方的帮派名
            local enemyGuildInfo = info.MatchGuildInfo or {}
            local enemyGuildName = TR("等级%s %s%s", enemyGuildInfo.Lv or "", Enums.Color.eYellowH, enemyGuildInfo.GuildName or "")
            addTitleLabel(myGuildName, 20, cc.p(0, 0.5), cc.p(100, 1050))
            addTitleLabel(enemyGuildName, 20, cc.p(1, 0.5), cc.p(540, 1050))
        else
            -- 显示自己的帮派名
            addTitleLabel(myGuildName, 22, cc.p(0.5, 0.5), cc.p(320, 1050))
        end
    end
end

-- 创建人物滚动页
function GuildPvpReadyLayer:createPlayerScroll(isEnemy)
    local xPos = (isEnemy == true) and (320 + 640) or 320
    local headerBgImg, headerPosList = "klxs1.jpg", {cc.p(450, 180), cc.p(320, 0)}
    local bottomBgImg, bottomPosList = "klxs2.jpg", {cc.p(540, 950), cc.p(300, 880), cc.p(470, 690), cc.p(310, 570), cc.p(160, 400), cc.p(250, 160), cc.p(440, 20)}
    local headerImgHeight, bottomImgHeight = ui.getImageSize(headerBgImg).height, ui.getImageSize(bottomBgImg).height

    -- 创建可拖动的区域
    local bgScrollView = ccui.ScrollView:create()
    bgScrollView:setContentSize(cc.size(640, 1136))
    bgScrollView:setInnerContainerSize(cc.size(640, 1136))
    bgScrollView:setAnchorPoint(cc.p(0.5, 1))
    bgScrollView:setPosition(cc.p(xPos, 1136))
    bgScrollView:setDirection(ccui.ScrollViewDir.vertical)
    self.mParentLayer:addChild(bgScrollView)

    -- 刷新列表显示
    bgScrollView.refreshShow = function (target, newList)
        local playerCount = table.nums(newList)
        if (playerCount < 5) then
            playerCount = 5 -- 帮派成员数量不可能小于5，这里是为了在初始化的时候至少显示两张图作为背景
        end
        local bottomImgCount = math.ceil((playerCount - 2) / 7)     -- 需要几张底部背景图才够显示
        local emptyNum = MqMath.modEx(playerCount-2, 7) + 1         -- 最后一张底部背景图剩余几个空位
        local scrollHeight = headerImgHeight + bottomImgHeight * bottomImgCount + 70
        local emptyItem = bottomPosList[emptyNum]
        if (emptyItem ~= nil) then
            scrollHeight = scrollHeight - emptyItem.y
        end
        if (scrollHeight < 1136) then
            scrollHeight = 1136
        end
        target:setInnerContainerSize(cc.size(640, scrollHeight))
        target:removeAllChildren()

        -- 添加顶部的背景图
        local function addScrollImg(posY, img)
            local tmpSprite = ui.newSprite(img)
            tmpSprite:setAnchorPoint(cc.p(0.5, 1))
            tmpSprite:setPosition(cc.p(320, posY))
            target:addChild(tmpSprite)
        end
        addScrollImg(scrollHeight, headerBgImg)

        -- 添加底部的背景图
        local tmpPosY = scrollHeight - headerImgHeight
        for i=1,bottomImgCount do
            addScrollImg(tmpPosY, bottomBgImg)
            tmpPosY = tmpPosY - bottomImgHeight
        end

        -- 添加人物
        local function addPlayerFigure(playerInfo, playerPos)
            -- Figure.newHero({
            --     parent = target,
            --     heroModelID = playerInfo.HeadImageId,
            --     fashionModelID = playerInfo.FashionModelId, 
            --     position = playerPos,
            --     scale = 0.15,
            --     async = function(figureNode)
            --         if (isEnemy == true) then -- 敌方人物面朝左边
            --             figureNode:setRotationSkewY(180)
            --         end
            --     end,
            --     buttonAction = function ()
            --         if (isEnemy == true) then
            --             self:enemyPlayerClickAction(playerInfo)
            --         else
            --             self:ourPlayerClickAction(playerInfo)
            --         end
            --     end
            -- })
            -- 创建底部圆圈
            local circleSprite = ui.newSprite("xjd_05.png")
            circleSprite:setPosition(playerPos)
            target:addChild(circleSprite)
            -- 创建头像卡牌
            local headCard = CardNode.createCardNode({
                    resourceTypeSub = ResourcetypeSub.eHero,
                    modelId = playerInfo.HeadImageId,
                    fashionModelID = playerInfo.FashionModelId,
                    cardShowAttrs = {CardShowAttr.eBorder},
                    allowClick = false,
                })
            headCard:setPosition(playerPos.x, playerPos.y+70)
            target:addChild(headCard)
            -- 创建图片框架
            local headBgBtn = ui.newButton({
                normalImage = "xjd_02.png",
                clickAction = function ()
                    if (isEnemy == true) then
                        self:enemyPlayerClickAction(playerInfo)
                    else
                        self:ourPlayerClickAction(playerInfo)
                    end
                end,
            })
            headBgBtn:setAnchorPoint(cc.p(0.5, 0))
            headBgBtn:setPosition(playerPos)
            target:addChild(headBgBtn)

            -- 名字背景和Label
            local nameLabel = ui.newLabel({
                text = playerInfo.Name,
                size = 18,
                color = (playerInfo.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId")) and Enums.Color.eGreen or Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x0F, 0x0F, 0x0F),
            })
            local labelSize = nameLabel:getContentSize()
            local nameBgSize = cc.size(labelSize.width + 30, labelSize.height + 8)
            if (nameBgSize.width < 80) then
                nameBgSize.width = 80
            end
            local nameBgSprite = ui.newScale9Sprite("bpz_37.png", nameBgSize)
            nameBgSprite:setPosition(playerPos.x+20, playerPos.y-30)
            target:addChild(nameBgSprite, 1)

            nameLabel:setPosition(nameBgSize.width / 2, nameBgSize.height / 2)
            nameBgSprite:addChild(nameLabel)

            -- 序号背景和Label
            local orderBgSprite = ui.newSprite("bpz_36.png")
            orderBgSprite:setPosition(-10, 12)
            nameBgSprite:addChild(orderBgSprite)

            local orderLabel = ui.newLabel({
                text = playerInfo.Order,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            orderLabel:setPosition(21, 23)
            orderBgSprite:addChild(orderLabel)
           
            -- 显示战力
            local fapLabelWithBg = ui.createLabelWithBg({
                bgFilename = "c_23.png",
                labelStr = Utility.numberFapWithUnit(playerInfo.FAP),
                fontSize = 18,
                outlineColor = cc.c3b(0x0F, 0x0F, 0x0F),
                alignType = ui.TEXT_ALIGN_CENTER,
            })
            fapLabelWithBg:setPosition(playerPos.x+18, playerPos.y)
            target:addChild(fapLabelWithBg, 1)

            local fapSprite = ui.newSprite("c_127.png")
            fapSprite:setPosition(playerPos.x - 37, playerPos.y)
            target:addChild(fapSprite, 1)

            -- 刷新星星和挑战标记
            self.mPlayerNodeList[playerInfo.Id] = {starNode = {}, flagSprite = nil, 
                refreshStarNode = function (node, newStarNum)
                    -- 清除以前的星星
                    for _,v in ipairs(node.starNode) do
                        v:removeFromParent()
                    end
                    node.starNode = {}
                    -- 清除以前的挑战标记
                    if (node.flagSprite ~= nil) then
                        node.flagSprite:removeFromParent()
                        node.flagSprite = nil
                    end

                    -- 创建新的星星
                    if (self.isBattleDay == true) then
                        for i=1,3 do
                            local starImg = (i <= newStarNum) and "c_75.png" or "c_102.png"
                            local xpos = playerPos.x + (i-2)*30
                            local starSprite = ui.newSprite(starImg)
                            starSprite:setScale(0.9)
                            starSprite:setPosition(xpos, playerPos.y + 140)
                            target:addChild(starSprite, 1)
                            table.insert(node.starNode, starSprite)
                        end

                        -- 创建新的挑战标记
                        local flagImg = nil
                        if (isEnemy == true) and (self:isAlreadyFightHim(playerInfo) == false) then
                            if (newStarNum < 3) then         -- 对方没死
                                if (self.mBattleInfo.PlayerGuildBattleInfo.ChallengeNum > 0) then
                                    flagImg = "bpz_06.png"
                                end
                            elseif (newStarNum == 3) then    -- 对方已死
                                if (self.mBattleInfo.PlayerGuildBattleInfo.RollingNum > 0) then
                                    flagImg = "bpz_07.png"
                                end
                            end
                        end
                        if (flagImg ~= nil) then
                            node.flagSprite = ui.newSprite(flagImg)
                            node.flagSprite:setPosition(playerPos.x + 10, playerPos.y + 100)
                            target:addChild(node.flagSprite, 1)
                        end
                    end
                end,
            }
            self.mPlayerNodeList[playerInfo.Id]:refreshStarNode(playerInfo.Star or 0)
        end
        for i,v in ipairs(newList) do
            local tempPos = (i <= 2) and headerPosList[i] or bottomPosList[MqMath.modEx(i-2, 7)]
            local basePosY = (i <= 2) and (scrollHeight - headerImgHeight) or (scrollHeight - headerImgHeight - bottomImgHeight*math.ceil((i-2)/7))
            addPlayerFigure(v, cc.p(tempPos.x, tempPos.y + basePosY))
        end
    end
    bgScrollView:refreshShow({})
    
    return bgScrollView
end

----------------------------------------------------------------------------------------------------

-- 给某个玩家布阵
--[[
    fromDlgPop 表示是否从查看人物信息的对话框里打开布阵的，默认为false
--]]
function GuildPvpReadyLayer:playerCamp(playerInfo, fromDlgPop)
    local strTitle, isLookCamp = TR("查看布阵"), true
    local myPostId = GuildObj:getPlayerGuildInfo().PostId
    if (playerInfo.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId")) or (myPostId == 34001001) or (myPostId == 34001002) then
        -- 自己只能给自己布阵；帮主或副帮主可以给所有人布阵
        strTitle, isLookCamp = self.isBattleDay and TR("进攻布阵") or TR("防守布阵"), false
    end
    -- 机器人只能查看布阵
    if GuildbattleRobotModel.items[playerInfo.Id] then
        strTitle, isLookCamp = TR("查看布阵"), true
    end

    self:requestPlayerGetFormation(playerInfo.Id, 
        function (responseData)
            local paramsData = {
                titleText = strTitle, isLookCamp = isLookCamp, playerId = playerInfo.Id, playerName = playerInfo.Name, 
                FormationData = responseData.TargetFormationInfo, 
                exchangeCallBack = function (retFormationList)
                    local exchangeParams = {playerInfo.Id}
                    for _,v in ipairs(retFormationList) do
                        table.insert(exchangeParams, v.Formation)
                    end
                    self:requestPlayerSetFormation(exchangeParams)
                end,
                recruitCallBack = function ()
                    self.playerOfAutoCamp = clone(playerInfo)
                    self.campFromDlgPop = fromDlgPop
                    LayerManager.addLayer({name = "guild.GuildPvpRecruiteLayer", data = {targetId = playerInfo.Id}})
                end,
            }
            LayerManager.addLayer({
                name = "guild.GuildPvpComCampLayer",
                data = paramsData,
                cleanUp = false,
            })
        end)
end

-- 我方人物点击处理
function GuildPvpReadyLayer:ourPlayerClickAction(playerInfo)
    if (self.isBattleDay == true) then
        -- 决战日：查看玩家信息
        local paramsArray = {isEnemy = false, heroInfo = playerInfo, guildId = GuildObj:getGuildInfo().Id, 
            campCallBack = function ()
                self:playerCamp(playerInfo, true)
            end,
        }
        LayerManager.addLayer({
            name = "guild.GuildPvpDlgPopLayer",
            data = paramsArray,
            cleanUp = false,
        })
    else
        -- 准备日：直接打开布阵
        self:playerCamp(playerInfo)
    end
end

-- 敌方人物点击处理
function GuildPvpReadyLayer:enemyPlayerClickAction(playerInfo)
    local enemyGuildInfo = self.mBattleInfo.MatchGuildInfo or {}
    LayerManager.addLayer({
            name = "guild.GuildPvpDlgPopLayer",
            data = {isEnemy = true, heroInfo = playerInfo, guildId = enemyGuildInfo.GuildId},
            cleanUp = false,
        })
end

-- 战利品按钮点击处理
function GuildPvpReadyLayer:battleRewardClickAction()
    -- 信息DIY函数
    local function DIYRewardInfoLayer(layer, layerBgSprite, layerSize)
        -- 黑色背景框
        local blackSize = cc.size(layerSize.width*0.9, 150)
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerSize.width/2, 95)
        layerBgSprite:addChild(blackBg)
        -- 创建物品列表
        local rewardInfo = GuildbattleConfig.items[1].baseResource
        local tempList = Utility.analysisStrResList(rewardInfo)
        for _, rewardItem in pairs(tempList) do
            rewardItem.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
        end
        -- 奖励数量更新为自己获取的积分
        local mySocre = 0
        if (self.mBattleInfo ~= nil) and (self.mBattleInfo.PlayerGuildBattleInfo ~= nil) then
            mySocre = self.mBattleInfo.PlayerGuildBattleInfo.Score or 0
        end
        for i,v in ipairs(tempList) do
            if v.num ~= nil then 
                v.num = mySocre
            end     
        end
        -- 添加奖励
        local cardList = ui.createCardList({
            cardDataList = tempList,
            maxViewWidth = blackSize.width*0.9,
            allowClick = true,
        })
        cardList:setAnchorPoint(cc.p(0.5, 0.5))
        cardList:setPosition(blackSize.width/2, blackSize.height/2)
        blackBg:addChild(cardList)
        -- 创建提示内容
        local guildInfo = GuildObj:getGuildInfo()
        local extNum = (guildInfo.Lv) * 10 -- 额外奖励数量 = 帮派等级*10
        local function addInfoLabel(strText, yPos)
            local label = ui.newLabel({
                text = strText, color = cc.c3b(0x46, 0x22, 0x0d), size = 20
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(50, yPos)
            layerBgSprite:addChild(label, 1)
        end
        addInfoLabel(TR("以下是您在本次帮派战中获得的战利品"), layerSize.height-82)
        addInfoLabel(TR("帮派战获胜可额外获得%s%s*%d%s和%s帮派积分*%d", "#CA7624", ResourcetypeSubName[ResourcetypeSub.eGuildGongfuCoin], extNum, "#462206", "#CA7624", extNum), layerSize.height-110)
        addInfoLabel(TR("奖励会在帮派战结束后发到领奖中心"), layerSize.height-138)
    end
    local tempData = {
        title = TR("战利品"),
        bgSize = cc.size(572, 400),
        closeBtnInfo = {},
        DIYUiCallback = DIYRewardInfoLayer,
        notNeedBlack = true,
    }
    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 判断是否挑战过某个玩家
function GuildPvpReadyLayer:isAlreadyFightHim(enemyInfo)
    local battleInfo = self.mBattleInfo.PlayerGuildBattleInfo or {}
    local battleList = battleInfo.BattleNodeIdStr or {}
    -- 只要在挑战记录表里存在，不管是否挑战成功，都不能再次挑战和切磋了
    return (battleList[tostring(enemyInfo.Order)] ~= nil)
end

----------------------------------------------------------------------------------------------------
-- 请求服务器数据相关函数

-- 获取成员信息
function GuildPvpReadyLayer:requestGetBattleInfo()
    HttpClient:request({
        moduleName = "Guild",
        methodName = "GetGuildBattleInfo",
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 缓存数据
            local respData = clone(response.Value)
            GuildObj:updateGuildBattleInfo(respData)

            -- 刷新界面
            self.mBattleInfo = respData
            self.mPlayerNodeList = {} -- 刷新人物列表前需要调用
            
            -- 如果在决战日报名，需要到下个决战日才能参赛，此时不会返回帮派信息
            if (respData.MatchGuildInfo ~= nil) and (respData.MatchGuildInfo.GuildId ~= nil) then
                self.isBattleDay = respData.IsFightDay
            else
                self.isBattleDay = false
            end
            self.titleBgNode:refreshShow(respData)
            self.ourScrollView:refreshShow(respData.GuildBattlePlayerInfo)
            self.enemyScrollView:refreshShow(respData.MatchGuildBattlePlayerInfo)

            -- 刷新界面
            self:refreshUI()
            
            -- 恢复人物列表的位置
            if (self.ourScrollPos ~= nil) then
                self.ourScrollView:getInnerContainer():setPosition(self.ourScrollPos)
            end
            if (self.enemyScrollPos ~= nil) then
                self.enemyScrollView:getInnerContainer():setPosition(self.enemyScrollPos)
            end
            -- 自动打开玩家的布阵
            if (self.playerOfAutoCamp ~= nil) then
                if (self.campFromDlgPop ~= nil) and (self.campFromDlgPop == true) then
                    self:ourPlayerClickAction(self.playerOfAutoCamp)
                end
                self:playerCamp(self.playerOfAutoCamp)
                self.playerOfAutoCamp = nil
                self.campFromDlgPop = nil
            end
        end,
    })
end

-- 获取某个玩家的布阵
function GuildPvpReadyLayer:requestPlayerGetFormation(playerId, callFunc)
    HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "GetFormationInfo",
        svrMethodData = {playerId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            callFunc(response.Value)
        end,
    })
end

-- 修改某个玩家的布阵
function GuildPvpReadyLayer:requestPlayerSetFormation(params)
    HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "FormationChang",
        svrMethodData = params,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("修改布阵成功"))
        end,
    })
end

-- 测试接口，其他人不要调用
function GuildPvpReadyLayer:requestScoreForTest()
    local newList = {}
    for _,v in pairs(GuildObj:getGuildBattlePlayerInfo()) do
        if (v.Star < 3) then
            table.insert(newList, v)
        end
    end
    for _,v in pairs(GuildObj:getMatchGuildBattlePlayerInfo()) do
        if (v.Star < 3) then
            table.insert(newList, v)
        end
    end
    local count = table.nums(newList)
    if (count == 0) then
        ui.showFlashView(TR("所有的星星都满了"))
        return
    end
    local tmpItem = newList[math.random(1, count)] or newList[1]
    HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "GuildBattleScoreTest",
        svrMethodData = {tmpItem.Id, tmpItem.Star + 1},
        callback = function(response)
        end,
    })
end

return GuildPvpReadyLayer