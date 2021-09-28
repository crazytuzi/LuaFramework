--[[
    文件名：ForgingDigOreLayer.lua
    描述：锻造-挖矿界面
    创建人：yanghongsheng
    创建时间：2017.4.6
--]]

local ForgingDigOreLayer = class("ForgingDigOreLayer", function()
    return display.newLayer()
end)

--[[
    params = {
        debrisModelId       碎片模型ID
    }
]]
local ENEMY_ZORDER = 1
function ForgingDigOreLayer:ctor(params)
    -- 获取参数
    self.debrisModelId   =  params.debrisModelId

    if not self.debrisModelId then return end
    -- 宝物名字
    local treasureModelID = TreasureDebrisModel.items[self.debrisModelId].treasureModelID
    self.mQuality = TreasureDebrisModel.items[self.debrisModelId].quality
    self.mOreFrame = ""
    if self.mQuality == 3 then
        self.mOreFrame = "c_05.png"
    elseif self.mQuality == 6 then
        self.mOreFrame = "c_06.png"
    elseif self.mQuality == 8 then
        self.mOreFrame = "c_07.png"
    elseif self.mQuality == 10 then
        self.mOreFrame = "c_07.png"
    elseif self.mQuality == 13 then
        self.mOreFrame = "c_08.png"
    elseif self.mQuality == 16 then
        self.mOreFrame = "c_08.png"
    elseif self.mQuality == 18 then
        self.mOreFrame = "c_09.png"
    end

    self.oreName = TreasureModel.items[treasureModelID].name
    -- 类中全局的前向声明（方便查找）
    self.mParentLayer = nil -- 容器
    self.mapBg = nil        -- 背景图
    self.oreNumLabel = nil  -- 存矿石数的label
    -- 现有矿石数
    self.nowOreNum = 0
    -- 需要
    self.needOreNum = 0
    -- 矿石列表(存界面上的矿石按钮)
    self.oreList = {}
    -- 玩家图
    self.playerSpine = nil
    self.playerSpine1 = nil
    self.mHeroNode = nil
    -- 一次挖矿的开采次数
    self.exploitCount = 1
    --设置待机和挖矿tag（1待机，0挖矿）
    self.mOverActionTag = 0
    self.mRotTag = 0
    self.mCount = 1
    self.mAnimationStop = 0

    self.mEnemyTable = {}

    self:initUI()

    -- 获取抢夺列表
    self:requestLootInfo()
    -- 获取免战数据
    self:requestGetTreasureLootProtectInfo()
    -- 初始化寻路
    self.starWorld = require("common.AStar").new({"challenge.ForgingWorld"})


    --随即隐藏矿点
    self.mRandTag = 0
    self:setTouchMoveEvent()
end

function ForgingDigOreLayer:onEnter()
end

function ForgingDigOreLayer:onExit()
    if self.mForging then
        MqAudio.stopEffect(self.mForging)
    end
end


function ForgingDigOreLayer:initUI()
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.both)
    worldView:setSwallowTouches(false)
    worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.worldView = worldView

    -- 创建背景
    local spriteBg = ui.newSprite("dz_10.jpg")
    spriteBg:setAnchorPoint(0, 0)
    spriteBg:setPosition(0, 0)
    self.worldView:setInnerContainerSize(spriteBg:getContentSize())
    self.worldView:addChild(spriteBg, -2)
    self.mapBg = spriteBg

    self.curViewPosition = cc.p(50, 50)
    self.worldView:scrollToPercentBothDirection(self.curViewPosition, 0, true)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource, 4)

    -- 创建退出按钮
    local button = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(600,1020),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(button, 5)
    self.closeBtn = button

    local oreCard = self:createOreCard(self.mOreFrame, "dz_16.png")
    oreCard:setPosition(100, 1030)
    self.mParentLayer:addChild(oreCard)
    -- 创建矿石数量label
    -- 创建label背景
    local numLabelBgSize = cc.size(80, 24)
    local numLabelBg = ui.newScale9Sprite("c_55.png", numLabelBgSize)
    numLabelBg:setPosition(oreCard:getContentSize().width*0.5, 20)
    oreCard:addChild(numLabelBg)
    -- 创建num label
    local numLabel = ui.newLabel({
            text = TR("%d/%d", 0, 0),
            size = 20,
            color = Enums.Color.eWhite,
        })
    numLabel:setAnchorPoint(cc.p(0.5, 0.5))
    numLabel:setPosition(numLabelBgSize.width*0.5, numLabelBgSize.height*0.5)
    numLabelBg:addChild(numLabel)
    self.oreNumLabel = numLabel
    self:refreshOreNum()
    self.oreNumLabel:setString(TR("%d/%d", self.nowOreNum, self.needOreNum))
    self.setCurOreNum = self.nowOreNum

    -- 创建免战按钮
    local freeWarBtn = ui.newButton({
            normalImage = "c_33.png",
            text = TR("免战"),
            anchorPoint = cc.p(0.5, 0.5),
            position = cc.p(100,930),
            clickAction = function()
                self:createProtectLayer()
            end
        })
    self.mParentLayer:addChild(freeWarBtn)

    local buttonPosX, buttonPosY = freeWarBtn:getPosition()
    -- 创建免战文本容器
    local label = ui.newLabel({
        text = TR("免战时间"),
        color = Enums.Color.eNormalGreen,
        outlineColor = Enums.Color.eNormalWhite,
        anchorPoint = cc.p(0.5, 0.5),
        outlineSize = 1,
        size = 22,
        x = buttonPosX,
        y = buttonPosY - 40,
    })
    label:setVisible(false)
    self.mParentLayer:addChild(label)
    self.mProtectHintLabel = label

    -- 创建免战时间容器
    local label = ui.newLabel({
        text = "",
        anchorPoint = cc.p(0.5, 0.5),
        size = 22,
        outlineColor = Enums.Color.eBlack,
        x = buttonPosX,
        y = buttonPosY - 70,
    })
    self.mParentLayer:addChild(label)
    self.mProtectTimeLabel = label

    -- 创建矿石点
    self:refreshOrePoint()

    -- 创建玩家node
    self.mHeroNode = cc.Node:create()
    self.mHeroNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.mHeroNode:setContentSize(120, 180)
    self.mHeroNode:setPosition(cc.p(640, 1136))
    self.mapBg:addChild(self.mHeroNode)
    self.mHeroNode:setLocalZOrder(ENEMY_ZORDER)


    -- local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    -- HeroQimageRelation.items[playerModelId].positivePic
    local positivePic, backPic = QFashionObj:getQFashionByDressType()
    self.playerSpine = ui.newEffect({
        parent = self.mHeroNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = positivePic,
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
        scale = 0.6
    })
    self.playerSpine:setAnimation(0, "daiji", true)
    self.playerSpine1 = ui.newEffect({
        parent = self.mHeroNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = backPic,
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
        scale = 0.6
    })
    self.playerSpine1:setVisible(false)

    -- 脚底特效
    ui.newEffect({
        parent = self.mHeroNode,
        effectName = "effect_ui_renwuguangquan_Qban",
        zorder = -1,
        animation = "guangquan",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
    })
    -- 上面特效
    ui.newEffect({
        parent = self.mHeroNode,
        effectName = "effect_ui_renwuguangquan_Qban",
        animation = "guangdian",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(self.mHeroNode:getContentSize().width / 2, self.mHeroNode:getContentSize().height / 2),
        loop = true,
        endRelease = true,
    })

    -- local arrowSp = ui.newSprite("dz_18.png")
    -- arrowSp:setPosition(self.mHeroNode:getContentSize().width*0.5, self.mHeroNode:getContentSize().height + 50)
    -- self.mHeroNode:addChild(arrowSp)
end

--[[
    描述：创建矿石卡片
]]
function ForgingDigOreLayer:createOreCard(image, extraImg)
    local card = CardNode:create({})
    card:setCardData({
        imgName = image,
        extraImgName = extraImg,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
    })
    card.mShowAttrControl[CardShowAttr.eName].label:setVisible(false)
    card:setCardName(TR(Enums.Color.ePurpleH .. TR("%s矿石"), self.oreName))

    return card
end
--[[
    描述：创建矿石
    参数：position 坐标
         image      图
]]
function ForgingDigOreLayer:createOre(position, image, index, isVisble)
    local buttonOre = ui.newButton({
        normalImage = image,
        anchorPoint = cc.p(0.6, 0.4),
        position = position,
        clickAction = function (pSender)
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11206 then
                Guide.manager:nextStep(eventID)
                -- 屏蔽界面操作
                Guide.manager:showGuideLayer({})
            end

            pSender:scheduleUpdate(
            function(dt)
                local x, y = self.mHeroNode:getPosition()
                local lenth = cc.pGetLength(cc.pSub(cc.p(x, y), position))
                if lenth <= 100 then
                    self:playerArrived()
                    if x < position.x then
                        self.playerSpine:setRotationSkewY(0)
                       self.playerSpine1:setRotationSkewY(0)
                   else
                       self.playerSpine:setRotationSkewY(180)
                       self.playerSpine1:setRotationSkewY(180)
                    end
                    self:PopupOreHint(index)
                    pSender:unscheduleUpdate()

                    --[[--------新手引导--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 11207 then
                        Utility.performWithDelay(self.mParentLayer, handler(self, self.executeGuide), 0.25)
                    end
                end
            end
         )
    end
    })
    self.mapBg:addChild(buttonOre)

    return buttonOre
end

-- 得到最近矿点
function ForgingDigOreLayer:getMinDisOre()
    return self.oreList[17]
end

--[[
    描述：创建人物
    参数：position 坐标
         image      图
]]
function ForgingDigOreLayer:createHero(position, image, targetInfo, modelTag)
    -- 人物图
    local enemyNode = cc.Node:create()
    enemyNode:setAnchorPoint(cc.p(0.5, 0.5))
    enemyNode:setContentSize(120, 180)
    enemyNode:setPosition(position)
    self.mapBg:addChild(enemyNode)
    enemyNode:setLocalZOrder(ENEMY_ZORDER)

    local playerModel = ui.newEffect({
        parent = enemyNode,
        effectName = image,
        position = cc.p(60, 20),
        loop = true,
        endRelease = true,
        scale = 0.6,
    })
    playerModel:setName(string.format("playerModel%d", modelTag))

    local nodeButton = ui.newButton({
            normalImage = "",
            anchorPoint = cc.p(0.5, 0.5),
            size = cc.size(120, 180),
            position = cc.p(60, 90),
            clickAction = function()
                self:PopupLootHint(targetInfo)
            end
    })
    enemyNode:addChild(nodeButton)

    local nameBgSprite = ui.newSprite("dz_17.png")
    nameBgSprite:setPosition(enemyNode:getPositionX(), enemyNode:getPositionY() + 100)
    self.mapBg:addChild(nameBgSprite)
    nameBgSprite:setTag(100 + modelTag)
    -- 人物名
    local nameLabel = ui.newLabel({
        text = TR("%s\n{c_127.png}%s", targetInfo.Name, Utility.numberFapWithUnit(targetInfo.FAP or 0)),
        align = ui.TEXT_ALIGN_CENTER,
        size = 20,
        color = Enums.Color.eBlack,
        })
    nameLabel:setPosition(nameBgSprite:getContentSize().width / 2 + 30, nameBgSprite:getContentSize().height / 2)
    nameBgSprite:addChild(nameLabel)

    --等级
    local lvLabel = ui.newLabel({
        text = TR("LV.%d", targetInfo.Lv),
        size = 20,
        color = cc.c3b(0x15, 0x5b, 0x10),
        anchorPoint = cc.p(0, 0.5),
        })
    lvLabel:setPosition(30, nameBgSprite:getContentSize().height / 2 - 15)
    nameBgSprite:addChild(lvLabel)

    --抢夺获取概率
    local dropTag = targetInfo.LootProEnum
    local dropText = nil
    local dropColor = nil
    if dropTag == 1 then
        dropText = TR("极高")
        dropColor = cc.c3b(0xff, 0xf4, 0x4c)
    elseif dropTag == 2 then
        dropText = TR("较高")
        dropColor = cc.c3b(0xff, 0xa1, 0x5c)
    elseif dropTag == 3 then
        dropText = TR("一般")
        dropColor = cc.c3b(0x57, 0xe1, 0xff)
    elseif dropTag == 4 then
        dropText = TR("较低")
        dropColor = cc.c3b(0x58, 0xff, 0x5c)
    elseif dropTag == 5 then
        dropText = TR("极低")
        dropColor = cc.c3b(0xd4, 0xd4, 0xd4)
    end

    local dropLabel = ui.newLabel({
        text = dropText,
        size = 22,
        color = dropColor,
        outlineColor = cc.c3b(0x4a, 0x4a, 0x4a),
        outlineSize = 2,
        anchorPoint = cc.p(0, 0.5),
        })
    dropLabel:setPosition(40, nameBgSprite:getContentSize().height / 2 + 15)
    nameBgSprite:addChild(dropLabel)

    return enemyNode
end

--[[
   描述：多次挖矿需要弹窗
]]
function ForgingDigOreLayer:startExploitOres(index, rewardList, getOreNum)
    local buttonOre = self.oreList[index]
    self.mAnimationStop = 0
    buttonOre:setTouchEnabled(true)
    buttonOre:stopAllActions()
    buttonOre:setVisible(false)
    self.playerSpine:setOpacity(255)
    self.playerSpine1:setOpacity(255)
    buttonOre = nil
    if self.mOverActionTag == 1 then
        self.playerSpine:setAnimation(0, "daiji", true)
        self.playerSpine1:setAnimation(0, "daiji", true)
        self.isWakuang = false
    end
    self.oreNumLabel:setString(TR("%d/%d", self.nowOreNum, self.needOreNum))
    self.setCurOreNum = self.nowOreNum
end


--[[
   描述：单词挖矿不需要弹窗
]]
function ForgingDigOreLayer:startExploitOre(index, rewardList, getOreNum)
    local buttonOre = self.oreList[index]
    -- 进度条
    local progressBar = require("common.ProgressBar").new({
        bgImage = "cdjh_34.png",
        barImage = "cdjh_35.png",
        currValue = 0,
        maxValue = 2,
        barType = ProgressBarType.eHorizontal,
    })
    progressBar:setScale(0.5)
    progressBar:setAnchorPoint(cc.p(0.5, 0.5))
    progressBar:setPosition(buttonOre:getContentSize().width*0.5, buttonOre:getContentSize().height*0.2)
    progressBar:setTag(1)
    buttonOre:addChild(progressBar)
    buttonOre:setTouchEnabled(false)

    local timerCount = 0
    local curTime = 0
    Utility.schedule(buttonOre,function()
        curTime = curTime + 1
        progressBar:setVisible(true)
        progressBar:setCurrValue(curTime)
        if curTime > 2 then
            progressBar:setVisible(false)
            progressBar:setCurrValue(0)
            curTime = 0
        end
        if progressBar:getCurrValue() == 2 then
            self:showReward(buttonOre, rewardList.GetExpInfo[1], rewardList.BaseGetGameResourceList, rewardList)
        end

        if self.mAnimationStop == self.mCount then
            self.mAnimationStop = 0
            if timerCount > rewardList.MiningTime  then
                --self:addGameDropLayer(rewardList.BaseGetGameResourceList, getOreNum)
                buttonOre:setTouchEnabled(true)
                buttonOre:stopAllActions()
                buttonOre:setVisible(false)
                self.playerSpine:setOpacity(255)
                self.playerSpine1:setOpacity(255)
                buttonOre = nil
                if self.mOverActionTag == 1 then
                    self.playerSpine:setAnimation(0, "daiji", true)
                    self.playerSpine1:setAnimation(0, "daiji", true)
                    self.isWakuang = false
                    if self.mForging then
                        MqAudio.stopEffect(self.mForging)
                        self.mForging = nil
                    end

                    --[[--------新手引导--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 11209 then
                        self:executeGuide()
                    end
                end
                --self.oreNumLabel:setString(TR("%d/%d", self.nowOreNum, self.needOreNum))
                self.setCurOreNum = self.nowOreNum
                if self.nowOreNum >= self.needOreNum then
                    LayerManager.removeLayer(self)
                    -- 检查是否升级
                    PlayerAttrObj:showUpdateLayer()
                end
            end
        end
        timerCount = timerCount + 1
    end,
    1)
end

function ForgingDigOreLayer:showReward(node, cardData, baseDrop, rewardList)
    local oreCard = CardNode.createCardNode({
        imgName = self.mOreFrame,
        extraImgName = "dz_16.png",
        num = cardData.GetExp,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
    })
    oreCard:setPosition(cc.p(50, 150))
    node:addChild(oreCard)
    oreCard:setScale(0.6)
    oreCard:setCardName(self.oreName)
    oreCard:setCardName(TR(Enums.Color.ePurpleH .. TR("%s矿石"), self.oreName))
    --oreCard:setCardName(TR("%s矿石碎片", Enums.Color.eBlueH))

    oreCard:runAction(cc.Sequence:create(
                        cc.Spawn:create(
                           cc.JumpBy:create(1, cc.p(-200, 100), 200, 1),
                           cc.FadeTo:create(1, 0)
                       ),
                       cc.CallFunc:create(function()
                           if oreCard then
                              oreCard:removeFromParent(true)
                           end
                       end)
                     ))


    local expCard = CardNode.createCardNode({
        resourceTypeSub = baseDrop[1].PlayerAttr[1].ResourceTypeSub,
        modelId = baseDrop[1].PlayerAttr[1].ModelId,
        num = math.floor(baseDrop[1].PlayerAttr[1].Num / self.mCount),
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
    })
    expCard:setPosition(cc.p(50, 150))
    node:addChild(expCard)
    expCard:setScale(0.6)

    expCard:runAction(cc.Sequence:create(
                        cc.Spawn:create(
                           cc.MoveBy:create(0.6, cc.p(0, 100)),
                           cc.FadeTo:create(0.6, 0)
                       ),
                       cc.CallFunc:create(function()
                           if expCard then
                              expCard:removeFromParent(true)
                           end
                       end)
                     ))

    local goodsCard = CardNode.createCardNode({
        resourceTypeSub = baseDrop[1].PlayerAttr[2].ResourceTypeSub,
        modelId = baseDrop[1].PlayerAttr[2].ModelId,
        num = math.floor(baseDrop[1].PlayerAttr[2].Num / self.mCount),
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
    })
    goodsCard:setPosition(cc.p(50, 150))
    node:addChild(goodsCard)
    goodsCard:setScale(0.6)

    goodsCard:runAction(cc.Sequence:create(
                        cc.Spawn:create(
                           cc.JumpBy:create(1.0, cc.p(200, 100), 200, 1),
                           cc.FadeTo:create(1, 0)
                       ),
                       cc.CallFunc:create(function()
                           if goodsCard then
                              goodsCard:removeFromParent(true)
                           end
                           self.mAnimationStop = self.mAnimationStop + 1

                           self.setCurOreNum = self.setCurOreNum + rewardList.GetExpInfo[self.mAnimationStop].GetExp
                           self.oreNumLabel:setString(TR("%d/%d", self.setCurOreNum, self.needOreNum))
                       end)
                     ))

end


--获得奖励的列表
--- 物品掉落提示窗体
--[[
-- 参数
    baseDrop:       必传参数，基础掉落物品列表，在网络请求返回的 Value.BaseGetGameResourceList
    getOreNump:矿石数
]]
function ForgingDigOreLayer:addGameDropLayer(baseDrop, getOreNump)
    -- 物品掉落提示窗体的DIY函数
    local function DIYFuncion(box, bgSprite, bgSize)
        -- 重新设置提示信息的位置
        local tempLabel = box:getMsgLabel()
        tempLabel:setAnchorPoint(cc.p(0.5, 1))
        tempLabel:setPosition(bgSize.width / 2, bgSize.height - 90)

        local dataList = {}
        local oreData = {
            imgName = self.mOreFrame,
            extraImgName = "dz_16.png",
            num = getOreNump,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        }
        table.insert(dataList, 1, oreData)

        --经验奖励
        local expReward = {
            --资源类型
            ["resourceTypeSub"] = baseDrop[1].PlayerAttr[1].ResourceTypeSub,
            --模型ID
            ["modelId"] = baseDrop[1].PlayerAttr[1].ModelId,
            --数量
            ["num"] = baseDrop[1].PlayerAttr[1].Num,
        }
        table.insert(dataList, 2, expReward)

        --金币奖励
        local GoldsReward = {
            --资源类型
            ["resourceTypeSub"] = baseDrop[1].PlayerAttr[2].ResourceTypeSub,
            --模型ID
            ["modelId"] = baseDrop[1].PlayerAttr[2].ModelId,
            --数量
            ["num"] = baseDrop[1].PlayerAttr[2].Num,
        }
        table.insert(dataList, 3, GoldsReward)

        -- 创建奖励物品列表
        local cardListNode = ui.createCardList({
            maxViewWidth = bgSize.width - 60,
            space = 15,
            cardDataList = dataList,
            allowClick = true,
            needArrows = true,
        })
        cardListNode:setAnchorPoint(cc.p(0.5, 0))
        cardListNode:setPosition(bgSize.width / 2 , 120)
        bgSprite:addChild(cardListNode)

        --cardListNode.getCardNodeList()[1]:setCardName(TR("%s矿石碎片", Enums.Color.eBlueH))
        cardListNode.getCardNodeList()[1]:setCardName(TR(Enums.Color.ePurpleH .. TR("%s矿石"), self.oreName))


    end

    local tempData = {
        bgSize = cc.size(572, 400),
        title = TR("奖励"),
        msgText = TR("获得以下物品"),
        --btnInfos = next(btnInfos or {}) and btnInfos or {{text = TR("确定"),}, },
        DIYUiCallback = DIYFuncion,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
        needRestore = true
    })
end

--[[
    描述：刷新拥有矿石数
]]
function ForgingDigOreLayer:refreshOreNum()
    local debrisModel = nil
    for _, item in pairs(TreasureDebrisObj.mTreasureDebrisList) do
        if item.TreasureDebrisModelId == self.debrisModelId then
            debrisModel = item
            break
        end
    end
    if debrisModel then
        local nowNum = debrisModel.TotalExp
        local needNum = TreasureDebrisModel.items[self.debrisModelId].needExp
        self.nowOreNum = nowNum
        self.needOreNum = needNum
    end
end

--[[
    描述：刷新矿石点
]]
function ForgingDigOreLayer:refreshOrePoint()
    -- 矿石位置点
    self.mRandTag = 0
    local oreData = {
        [1] = {
            subScreen = 1,
            isVisble = 1,
            position = cc.p(451, 2146),
            image = "dz_04.png"
        },
        [2] = {
            subScreen = 1,
            isVisble = 1,
            position = cc.p(200, 2040),
            image = "dz_05.png"
        },
        [3] = {
            subScreen = 1,
            isVisble = 1,
            position = cc.p(148, 1779),
            image = "dz_06.png"
        },
        [4] = {
            subScreen = 1,
            isVisble = 1,
            position = cc.p(126, 1474),
            image = "dz_04.png"
        },
        [5] = {
            subScreen = 1,
            isVisble = 1,
            position = cc.p(285, 1233),
            image = "dz_05.png"
        },
        [6] = {
            subScreen = 2,
            isVisble = 1,
            position = cc.p(996, 2050),
            image = "dz_04.png"
        },
        [7] = {
            subScreen = 2,
            isVisble = 1,
            position = cc.p(1160, 1700),
            image = "dz_05.png"
        },
        [8] = {
            subScreen = 2,
            isVisble = 1,
            position = cc.p(852, 1866),
            image = "dz_06.png"
        },
        [9] = {
            subScreen = 2,
            isVisble = 1,
            position = cc.p(722, 1650),
            image = "dz_04.png"
        },
        [10] = {
            subScreen = 2,
            isVisble = 1,
            position = cc.p(1005, 1492),
            image = "dz_05.png"
        },
        [11] = {
            subScreen = 3,
            isVisble = 1,
            position = cc.p(322, 817),
            image = "dz_04.png"
        },
        [12] = {
            subScreen = 3,
            isVisble = 1,
            position = cc.p(541, 739),
            image = "dz_05.png"
        },
        [13] = {
            subScreen = 3,
            isVisble = 1,
            position = cc.p(180, 480),
            image = "dz_06.png"
        },
        [14] = {
            subScreen = 3,
            isVisble = 1,
            position = cc.p(436, 440),
            image = "dz_04.png"
        },
        [15] = {
            subScreen = 3,
            isVisble = 1,
            position = cc.p(220, 100),
            image = "dz_05.png"
        },
        [16] = {
            subScreen = 4,
            isVisble = 1,
            position = cc.p(1190, 1030),
            image = "dz_04.png"
        },
        [17] = {
            subScreen = 4,
            isVisble = 1,
            position = cc.p(560, 1050),
            image = "dz_06.png"
        },
        [18] = {
            subScreen = 4,
            isVisble = 1,
            position = cc.p(830, 740),
            image = "dz_05.png"
        },
        [19] = {
            subScreen = 4,
            isVisble = 1,
            position = cc.p(1043, 280),
            image = "dz_04.png"
        },
        [20] = {
            subScreen = 4,
            isVisble = 1,
            position = cc.p(790, 220),
            image = "dz_05.png"
        },
    }
    self.mOreTable = oreData
    -- 创建矿石
    for i=1, #oreData do
        self.oreList[i] = self:createOre(oreData[i].position, oreData[i].image, i, oreData[i].isVisble)
    end

    for i=5,#self.oreList, 5 do
        local x, y
        if i / 5 == 1 then
            x, y = 1, 5
        elseif i / 5 == 2 then
            x, y = 6, 10
        elseif i / 5 == 3 then
            x, y = 11, 15
        elseif i / 5 == 4 then
            x, y = 16, 20
        end

        local visible1 = math.random(x, y)
        if visible1 == 3 or visible1 == 10 then
            visible1 = math.random(x, y)
        end
        local visible2 = math.random(x, y)
        if visible2 == 3 or visible2 == 10 then
            visible1 = math.random(x, y)
        end
        while visible1 == visible2 do
            visible1 = math.random(x, y)
            visible2 = math.random(x, y)
        end
        self.oreList[visible1]:setVisible(false)
        self.oreList[visible2]:setVisible(false)
    end
    self.oreList[4]:setVisible(true)
    self.oreList[10]:setVisible(true)
    self.oreList[15]:setVisible(false)
    self.oreList[17]:setVisible(true)
end

--[[
    描述：刷新抢夺人物
    参数：response.Value
]]
function ForgingDigOreLayer:refreshHero(data)
    local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    -- 其他玩家位置点
    local heroData = {
        [1] = {
            position = cc.p(380, 2000),
            animationTag = 1 --1走 2挖矿 3待机
        },
        [2] = {
            position = cc.p(30, 1500),
            animationTag = 2 --1走 2挖矿 3待机
        },
        [3] = {
            position = cc.p(350, 1350),
            animationTag = 3 --1走 2挖矿 3待机
        },
        [4] = {
            position = cc.p(1150, 2150),
            animationTag = 3 --1走 2挖矿 3待机
        },
        [5] = {
            position = cc.p(800, 1800),
                animationTag = 1 --1走 2挖矿 3待机
        },
        [6] = {
            position = cc.p(930, 1500),
            animationTag = 2 --1走 2挖矿 3待机
        },
        [7] = {
            position = cc.p(320, 550),
            animationTag = 1 --1走 2挖矿 3待机
        },
        [8] = {
            position = cc.p(850, 400),
            animationTag = 3 --1走 2挖矿 3待机
        }
    }

    function RandomIndex(tabNum,indexNum)
        indexNum = indexNum or tabNum
        local t = {}
        local rt = {}
        for i = 1,indexNum do
            local ri = math.random(1,tabNum + 1 - i)
            local v = ri
            for j = 1,tabNum do
                if not t[j] then
                    ri = ri - 1
                    if ri == 0 then
                        table.insert(rt,j)
                        t[j] = true
                    end
                end
            end
        end
        return rt
    end
    local count = #data
    -- 创建人物
    local tab = {}
    for i=1,count do
        table.insert(tab, i)
    end
    local srand = RandomIndex(count, count)
    for i = 1, count do
        local randomNum = srand[i]
        local modelId = data[i].LeaderModelId or 12010002
        local positivePic = QFashionObj:getQFashionLargePic(modelId)
        local modelNode = self:createHero(heroData[randomNum].position,
                        positivePic,
                        data[i],
                        i)
        self.mEnemyTable[i] = modelNode
        modelNode:setLocalZOrder(ENEMY_ZORDER)

        self:otherPlayerAction(modelNode, heroData[randomNum].animationTag, i)
    end
end

--其他玩家行为（1:发呆，2:挖矿，3:行走）
--[[
    params说明：
     node:地图上玩家的模型
]]
function ForgingDigOreLayer:otherPlayerAction(node, animationTag, nameLabelTag)
    --local count = #params
    --local randomNum = math.random(1, 3)
    local acitonMan = node:getChildByName(string.format("playerModel%d", nameLabelTag))
    if animationTag == 1 then --行走
        local nameLabel = self.mapBg:getChildByTag(100 + nameLabelTag)
        acitonMan:addAnimation(0, "zou", true)
        self.mapBg:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.CallFunc:create(function()
                        acitonMan:addAnimation(0, "zou", true)
                    end),
                     cc.CallFunc:create(function()
                         node:runAction(cc.MoveBy:create(5, cc.p(200, 0)))
                         nameLabel:runAction(cc.MoveBy:create(5, cc.p(200, 0)))
                     end),
                     cc.DelayTime:create(5.0),
                     cc.CallFunc:create(function()
                         node:setRotationSkewY(-180)
                         acitonMan:addAnimation(0, "daiji", true)
                     end),
                     cc.DelayTime:create(2.0),
                     cc.CallFunc:create(function()
                         acitonMan:addAnimation(0, "zou", true)
                     end),
                     --cc.MoveBy:create(3, cc.p(-200, 0)),
                     cc.CallFunc:create(function()
                         node:runAction(cc.MoveBy:create(3, cc.p(-200, 0)))
                         nameLabel:runAction(cc.MoveBy:create(3, cc.p(-200, 0)))
                     end),
                     cc.DelayTime:create(3.0),
                     cc.CallFunc:create(function()
                         node:setRotationSkewY(360)
                         acitonMan:addAnimation(0, "daiji", true)
                     end),
                     cc.DelayTime:create(2.0)
                )
            )
        )
    elseif animationTag == 2 then--挖矿
        acitonMan:addAnimation(0, "wakuang", true)
    elseif animationTag == 3 then--待机
        acitonMan:addAnimation(0, "daiji", true)
    end
end



--[[
    描述：挖矿弹窗
]]
function ForgingDigOreLayer:PopupOreHint(index)
    self.mCount = 1
    local maxBtnTag = false
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        self.mSureBox = boxRoot
        local upSprite = ui.newSprite("dz_08.png")
        upSprite:setAnchorPoint(cc.p(0.5, 1))
        upSprite:setPosition(cc.p(bgSize.width / 2, bgSize.height + 85))
        bgSprite:addChild(upSprite, -1)

        local midSprite = ui.newSprite("dz_07.png")
        midSprite:setAnchorPoint(cc.p(0.5, 1))
        midSprite:setPosition(cc.p(bgSize.width / 2, bgSize.height - 71))
        bgSprite:addChild(midSprite, -1)

        local underSprite = ui.newSprite("dz_09.png")
        underSprite:setAnchorPoint(cc.p(0.5, 1))
        underSprite:setPosition(cc.p(bgSize.width / 2, bgSize.height - 240))
        bgSprite:addChild(underSprite, -1)

        --创建横线
        local line = ui.newSprite("dz_19.png")
        line:setAnchorPoint(cc.p(0.5, 0.5))
        line:setPosition(cc.p(bgSize.width / 2, bgSize.height - 140))
        bgSprite:addChild(line, -1)


        --创建次数label
        local coutLabel = ui.createSpriteAndLabel({
            imgName = "dz_15.png",
            scale9Size = cc.size(300, 30),
            labelStr = TR("请输入挖矿次数"),
            fontSize = 24,
            fontColor = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x5d, 0x28, 0x11),
            outlineSize = 1,
            alignType =  ui.TEXT_ALIGN_CENTER,
        })
        coutLabel:setAnchorPoint(cc.p(0.5, 0.5))
        coutLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - 170))
        bgSprite:addChild(coutLabel)

        --挖矿次数
        self.mCoutIntBg = ui.newScale9Sprite("c_24.png", cc.size(100, 30))
        self.mCoutIntBg:setPosition(cc.p(bgSize.width / 2, bgSize.height - 220))
        bgSprite:addChild(self.mCoutIntBg)

        self.mIntLabel = ui.newLabel({
            text = 1,
            size = 20,
            scale = 1,
            color = cc.c3b(0x48, 0x48, 0x48),
            x = self.mCoutIntBg:getContentSize().width / 2,
            y = self.mCoutIntBg:getContentSize().height / 2,
            anchorPoint = cc.p(0.5, 0.5),
        })
        self.mCoutIntBg:addChild(self.mIntLabel)

        --创建加减号
        local minusBtn = ui.newButton({
            normalImage = "gd_28.png",
            position = cc.p(bgSize.width / 2 - 75, bgSize.height - 220),
        })
        bgSprite:addChild(minusBtn)
        --减号长按和单击
        require("challenge.LongClick"):create({
            node = minusBtn,
            callBack = function()
                maxBtnTag = false
                self.mCount = self.mCount - 1
                if self.mCount <= 1 then
                    self.mCount = 1
                end
                self.mIntLabel:setString(self.mCount)
                self.mTipsLabel:setString(
                                TR("预计耗时 %s%d秒         %s消耗{%s}%s%d",
                                "#9f3029",
                                self.mCount * 2,
                                Enums.Color.eBlackH,
                                Utility.getResTypeSubImage(ResourcetypeSub.eSTA),
                                "#9f3029",
                                self.mCount * 2))
            end,
        })

        --创建最小
        local minBtn = ui.newButton({
            normalImage = "gd_33.png",
            position = cc.p(bgSize.width / 2 - 120, bgSize.height - 220),
            clickAction = function()
                self.mIntLabel:setString(1)
                self.mCount = 1
                maxBtnTag = false
            end
        })
        bgSprite:addChild(minBtn)


        local plusBtn = ui.newButton({
            normalImage = "gd_27.png",
            position = cc.p(bgSize.width / 2 + 75, bgSize.height - 220),
        })
        bgSprite:addChild(plusBtn)

        --加号长按和单击
        require("challenge.LongClick"):create({
            node = plusBtn,
            callBack = function()
                if self.mCount >= 10 then
                    self.mCount = 10
                    ui.showFlashView(TR("最多只能挖取10次"))
                    return
                end
                self.mCount = self.mCount + 1
                self.mIntLabel:setString(self.mCount)
                self.mTipsLabel:setString(
                                TR("预计耗时 %s%d秒         %s消耗{%s}%s%d",
                                "#9f3029",
                                self.mCount * 2,
                                Enums.Color.eBlackH,
                                Utility.getResTypeSubImage(ResourcetypeSub.eSTA),
                                "#9f3029",
                                self.mCount * 2))
                local count = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA) / 2
                if count < self.mCount then
                    Utility.isResourceEnough(ResourcetypeSub.eSTA, self.mCount * 2, true)
                    return
                end
            end,
        })

        --创建最大
        local maxBtn = ui.newButton({
            normalImage = "gd_32.png",
            position = cc.p(bgSize.width / 2 + 120, bgSize.height - 220),
            clickAction = function()
                if maxBtnTag == false then
                    local count = math.floor(PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA) / 2)
                    if count >= 10 then
                        self.mIntLabel:setString(10)
                        self.mCount = 10
                    else
                        if count == 0 then
                            self.mCount = count + 1
                        else
                            self.mCount = count
                        end
                        self.mIntLabel:setString(self.mCount)
                        Utility.isResourceEnough(ResourcetypeSub.eSTA, self.mCount * 2, true)
                    end
                    maxBtnTag = true
                else
                    Utility.isResourceEnough(ResourcetypeSub.eSTA, 10 * 2, true)
                end

            end
        })
        bgSprite:addChild(maxBtn)

        --预计产出
        local produceLabel = ui.newLabel({
                text = TR("本次采集预计可获得："),
                size = 24,
                color = cc.c3b(0x2d, 0x2a, 0x25),
            })
        produceLabel:setAnchorPoint(cc.p(0.5, 0.5))
        produceLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height))
        bgSprite:addChild(produceLabel)

        -- 加成
        local attrLabel = ConfigFunc:getMonthAddAttrStr(true)
        if attrLabel then
            attrLabel:setPosition(cc.p(bgSize.width-30 , bgSize.height))
            bgSprite:addChild(attrLabel)
        end

        -- 预计消耗
        self.mTipsLabel = ui.newLabel({
            text = TR("预计耗时 %s%d秒         %s消耗{%s}%s%d",
                        "#9f3029",
                        self.mCount * 2,
                        Enums.Color.eBlackH,
                        Utility.getResTypeSubImage(ResourcetypeSub.eSTA),
                        "#9f3029",
                        self.mCount * 2),
            size = 20,
            color = Enums.Color.eBlack,
            align = ui.TEXT_ALIGN_CENTER,
        })
        self.mTipsLabel:setPosition(cc.p(bgSize.width / 2, 85))
        bgSprite:addChild(self.mTipsLabel)
        self.mTipsLabel:setVisible(false)

        local dataList = {}
        local oreData = {
            imgName = self.mOreFrame,
            extraImgName = "dz_16.png",
            num = 4,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        }
        table.insert(dataList, 1, oreData)

        --经验奖励
        local expReward = {
            --资源类型
            ["resourceTypeSub"] = ResourcetypeSub.eEXP,
            --模型ID
            ["modelId"] = 0,
            --数量
            ["num"] = 800,
        }
        table.insert(dataList, 2, expReward)

        --金币奖励
        local GoldsReward = {
            --资源类型
            ["resourceTypeSub"] = ResourcetypeSub.eGold,
            --模型ID
            ["modelId"] = 0,
            --数量
            ["num"] = 100,
        }
        table.insert(dataList, 3, GoldsReward)

        --创建奖励列表
        local tempCard = ui.createCardList({
            maxViewWidth = 405,     --显示的最大宽度
            viewHeight = 120,       --显示的高度，默认为120
            space = 0,
            cardShowAttrs = {},
            cardDataList = dataList,
            allowClick = false,
            isSwallow = false,
        })
        tempCard:setAnchorPoint(cc.p(0.5, 0.5))
        tempCard:setScale(0.8)
        tempCard:setPosition(cc.p(bgSize.width / 2, bgSize.height - 80))
        bgSprite:addChild(tempCard)

        --创建横线
        local line2 = ui.newSprite("dz_20.png")
        line2:setAnchorPoint(cc.p(0.5, 0.5))
        line2:setPosition(cc.p(bgSize.width / 2, 150))
        bgSprite:addChild(line2, -1)

        --确定按钮
        self.popOkButton = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            clickAction = function()
                -- 次数
                LayerManager.removeLayer(self.mSureBox)
                if PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA) < 2 then
                    --ui.showFlashView(TR("耐力不足"))
                        Utility.isResourceEnough(ResourcetypeSub.eSTA, self.mCount * 2, true)
                    return
                end
                self:requestForgeDebris(index, self.mCount)
                if self.mOverActionTag == 0 then
                    self.playerSpine:setToSetupPose()
                    self.playerSpine1:setToSetupPose()
                    if self.mCount == 1 then
                        self.playerSpine:setAnimation(0, "wakuang", true)
                        self.playerSpine1:setAnimation(0, "wakuang", true)
                        if not self.mForging then
                            self.mForging =  MqAudio.playEffect("forging_dig.mp3", true)
                        end

                    end
                    self.isWakuang = true
                    self.mOverActionTag = 1
                end
            end
        })
        self.popOkButton:setPosition(bgSize.width * 0.75, 110)
        bgSprite:addChild(self.popOkButton)

        tempCard.getCardNodeList()[1]:setCardName(TR(Enums.Color.ePurpleH .. TR("%s矿石"), self.oreName))

        local cardList = tempCard.getCardNodeList()
        for _, item in ipairs(cardList) do
            item.mShowAttrControl[CardShowAttr.eNum].label:setVisible(false)
        end
    end

    local boxSize = cc.size(380, 400)
    local msgLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgImage = "c_83.png",
            bgSize = boxSize,   --背景size
            title = "",     --标题
            btnInfos = {},      --按钮列表
            DIYUiCallback = DIYfunc,    --DIY回调
            notNeedBlack = "",
            closeBtnInfo = {
                normalImage = "c_33.png",
                 text = TR("取消"),
                position = cc.p(boxSize.width * 0.25, 110),
                clickAction = function()
                    LayerManager.removeLayer(self.mSureBox)
                end
            }
        },
    })
end

--[[
    描述：抢夺弹窗
]]
function ForgingDigOreLayer:PopupLootHint(targetInfo)
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        self.mSureBox = boxRoot
        local upSprite = ui.newSprite("dz_08.png")
        upSprite:setAnchorPoint(cc.p(0.5, 1))
        upSprite:setPosition(cc.p(bgSize.width / 2, bgSize.height))
        bgSprite:addChild(upSprite, -1)

        local underSprite = ui.newSprite("dz_09.png")
        underSprite:setAnchorPoint(cc.p(0.5, 1))
        underSprite:setPosition(cc.p(bgSize.width / 2, bgSize.height - 185))
        bgSprite:addChild(underSprite, -1)

        --创建次数label
        local coutLabel = ui.createSpriteAndLabel({
            imgName = "dz_15.png",
            scale9Size = cc.size(300, 30),
            labelStr = TR("是否对该玩家进行抢夺？"),
            fontSize = 24,
            fontColor = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x5d, 0x28, 0x11),
            outlineSize = 1,
            alignType =  ui.TEXT_ALIGN_CENTER,
        })
        coutLabel:setAnchorPoint(cc.p(0.5, 0.5))
        coutLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - 70))
        bgSprite:addChild(coutLabel)

        -- 获得数量
        self.mTipsLabel = ui.newLabel({
            text = TR("%s预计可抢夺4—10块矿石",
                        Enums.Color.eBlackH),
            size = 22,
            color = Enums.Color.eBlack,
            align = ui.TEXT_ALIGN_CENTER,
        })
        self.mTipsLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - 120))
        bgSprite:addChild(self.mTipsLabel)

        --创建横线
        local line2 = ui.newSprite("dz_20.png")
        line2:setAnchorPoint(cc.p(0.5, 0.5))
        line2:setPosition(cc.p(bgSize.width / 2, bgSize.height  - 160))
        bgSprite:addChild(line2, -1)

        -- 预计消耗
        self.mTipsLabel = ui.newLabel({
            text = TR("%s消耗{%s}%s%d",
                        Enums.Color.eBlackH,
                        Utility.getResTypeSubImage(ResourcetypeSub.eSTA),
                        "#9f3029",
                        2),
            size = 22,
            color = Enums.Color.eBlack,
            align = ui.TEXT_ALIGN_CENTER,
        })
        self.mTipsLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - 190))
        bgSprite:addChild(self.mTipsLabel)

        --确定按钮
        self.popOkButton = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            clickAction = function()
                self:requestLootTarget(targetInfo)
                LayerManager.removeLayer(self.mSureBox)
            end
        })
        self.popOkButton:setPosition(bgSize.width * 0.75, bgSize.height - 240)
        bgSprite:addChild(self.popOkButton)
    end

    -- 创建弹窗
    local boxSize = cc.size(380, 400)
    local msgLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgImage = "c_83.png",
            bgSize = boxSize,   --背景size
            title = "",     --标题
            btnInfos = {},      --按钮列表
            DIYUiCallback = DIYfunc,    --DIY回调
            notNeedBlack = "",
            closeBtnInfo = {
                normalImage = "c_33.png",
                 text = TR("取消"),
                position = cc.p(boxSize.width * 0.25, boxSize.height - 240),
                clickAction = function()
                    LayerManager.removeLayer(self.mSureBox)
                end
            }
        },
    })
end


-- 免战时间
function ForgingDigOreLayer:showProtectInfo(endTime)
    local interval = endTime - Player:getCurrentTime()
    if interval > 0 then
        -- 当存在免战时间时
        if self.mProtectAction ~= nil then
            self.mProtectTimeLabel:stopAction(self.mProtectAction)
            self.mProtectAction = nil
        end

        self.mProtectTimeLabel:setString(MqTime.formatAsHour(interval))
        self.mProtectHintLabel:setVisible(true)
        self.mIsProtect = true

        -- 计划任务
        self.mProtectAction = Utility.schedule(self.mProtectTimeLabel, function()
            interval = endTime - Player:getCurrentTime()
            if interval >= 0 then
                -- 当免战时间还有剩余时
                self.mProtectTimeLabel:setString(MqTime.formatAsHour(interval))
            else
                self.mProtectTimeLabel:stopAction(self.mProtectAction)
                self.mProtectAction = nil
                self.mProtectTimeLabel:setString("")
                self.mProtectHintLabel:setVisible(false)
                self.mIsProtect = false
            end
        end, 1)
    else
        self.mProtectTimeLabel:setString("")
        self.mProtectHintLabel:setVisible(false)
        self.mIsProtect = false
    end
end

-- 免战对话框
function ForgingDigOreLayer:createProtectLayer()
    local lootConfig = TreasureLootConfig.items[1]
    local resInfo = Utility.analysisStrResList(lootConfig.protectUseResource)[1]

    local function DIYNormalFunction(layer, layerBgSprite, layerSize)
        -- 重新设置提示内容的位置
        layer.mMsgLabel:setPosition(layerSize.width / 2, 230)

        local labelInfo = {
            color = Enums.Color.eNormalWhite,
            anchorPoint = cc.p(0.5, 1),
            size = 22,
            x = layerSize.width/2,
            y = layerSize.height - 80,
        }

        -- 提示文本
        labelInfo.text = TR("单次可免战%d小时，效果可叠加。免战期间抢夺其他玩家解除免战。",
            math.floor(lootConfig.perProtectTime/3600))
        labelInfo.dimensions = cc.size(layerSize.width - 80, 0)
        layerBgSprite:addChild(ui.newLabel(labelInfo))

        -- 消耗文本
        labelInfo.text = TR("消耗   {%s} %s%d%s   或   {%s} %s%d",
            Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId),
            Enums.Color.eNormalGreenH, resInfo.num, Enums.Color.eNormalWhiteH,
            Utility.getDaibiImage(ResourcetypeSub.eDiamond),
            Enums.Color.eNormalGreenH, lootConfig.protectUseDiamond
        )
        labelInfo.anchorPoint = cc.p(0, 1)
        labelInfo.x = layerSize.width * 0.25
        labelInfo.y = labelInfo.y - 72
        layerBgSprite:addChild(ui.newLabel(labelInfo))

        -- 拥有文本
        local num = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
        labelInfo.text = TR("拥有   {%s} %s%d",
            Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId),
            Enums.Color.eNormalGreenH, num
        )
        labelInfo.anchorPoint = cc.p(0, 1)
        labelInfo.x = layerSize.width * 0.25
        labelInfo.y = labelInfo.y - 46
        layerBgSprite:addChild(ui.newLabel(labelInfo))
    end

    -- 确定按钮
    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function()
            if Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId) >= resInfo.num then
                self:requestTreasureLootProtect(1)
            elseif Utility.isResourceEnough(ResourcetypeSub.eDiamond, lootConfig.protectUseDiamond, true) then
                self:requestTreasureLootProtect(2)
            end
        end
    }
    -- 创建窗口
    local tempData = {
        bgSize = cc.size(572, 350),
        title = TR("免战"),
        msgText = "",
        btnInfos = {okBtnInfo, {text = TR("取消")}},
        closeBtnInfo = {},
        DIYUiCallback = DIYNormalFunction,
    }
    self.mPopLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 切换骨骼动作
function ForgingDigOreLayer:changeSkelAction(effectObj, animationName, loop)
    effectObj:setToSetupPose()
    
    SkeletonAnimation.action({
        skeleton = effectObj,
        action = animationName,
        loop = loop,
    })
end


--===========================主角移动===========================

-- 人物移动位置设置
function ForgingDigOreLayer:actionFuc(stepList)
    if #stepList <= 1 then
        return
    end
    --设置骨骼为行走
    self:changeSkelAction(self.playerSpine, "zou", true)
    self:changeSkelAction(self.playerSpine1, "zou", true)
    -- 开始移动
    self.mHeroNode:scheduleUpdate(function(dt)
        --角色位置
        local playerPos = cc.p(self.mHeroNode:getPosition())
        local isArrived, nextPos, up, angle, isAlpha = self.starWorld:getCurrentStepInfo(playerPos, 150, dt)
        self.mHeroNode:setPosition(nextPos)
        --角色的方向并相应的隐藏骨骼
        if up then
            self.playerSpine1:setVisible(true)
            self.playerSpine:setVisible(false)
        else
            self.playerSpine1:setVisible(false)
            self.playerSpine:setVisible(true)
        end
        --角色转向
        self.playerSpine:setRotationSkewY(angle)
        self.playerSpine1:setRotationSkewY(angle)

        --当遇到矿石的时候，主角设置半透明
        for key, value in pairs(self.mOreTable) do
            if math.abs(playerPos.x - value.position.x) < 60 and math.abs(playerPos.y - value.position.y) < 60 and self.oreList[key]:isVisible() then
                isAlpha = 1
                break
            end
        end

        --设置半透明
        if isAlpha then
            self.playerSpine:setOpacity(100)
            self.playerSpine1:setOpacity(100)
        else
            self.playerSpine:setOpacity(255)
            self.playerSpine1:setOpacity(255)
        end

       -- 更新地图随人物移动
        self.curViewPosition.x = self.curViewPosition.x + (nextPos.x - playerPos.x)/6.40
        self.curViewPosition.y = self.curViewPosition.y - (nextPos.y - playerPos.y)/11.36
        --滚动层滚动
        self.worldView:scrollToPercentBothDirection(self.curViewPosition, 0, true)

        --当与其他玩家发生碰撞时降低或者增加层级，避免踩到别人。显得太假
        for i=1,#self.mEnemyTable do
            if math.abs(playerPos.x - self.mEnemyTable[i]:getPositionX()) < 50 then
                if playerPos.y > self.mEnemyTable[i]:getPositionY() then
                    self.mHeroNode:setLocalZOrder(ENEMY_ZORDER - 1)
                end

                if playerPos.y < self.mEnemyTable[i]:getPositionY() then
                    self.mHeroNode:setLocalZOrder(ENEMY_ZORDER + 1)
                end
            end
        end
        self.mOverActionTag = 0
        --到达制定地点并播放相应动作
        if isArrived then
            self:playerArrived()
        end
    end)
end

--到达目标位置需要发生的动作（挖矿和待机）
function ForgingDigOreLayer:playerArrived()
    self.mHeroNode:unscheduleUpdate()
    if self.mOverActionTag == 0 then
        self.playerSpine:setToSetupPose()
        self.playerSpine:setAnimation(0, "daiji", true)
        self.playerSpine1:setToSetupPose()
        self.playerSpine1:setAnimation(0, "daiji", true)
        if self.mForging then
            MqAudio.stopEffect(self.mForging)
            self.mForging = nil
        end
    else
        self.playerSpine:addAnimation(0, "wakuang", true)
        self.playerSpine1:addAnimation(0, "wakuang", true)
        self.isWakuang = true
        if not self.mForging then
            self.mForging =  MqAudio.playEffect("forging_dig.mp3", true)
        end
    end
end

--移动触摸函数
function ForgingDigOreLayer:setTouchMoveEvent()

    self.isTouchScrolled = false
    self.touchedPos = nil
    local moveTouchListenner = ui.registerSwallowTouch({
        node = self.worldView,
        allowTouch = false,
        beganEvent = function (touch, event)
            self.isTouchScrolled = false
            self.touchedPos = touch:getLocation()

            local targetPos = self.mapBg:convertToNodeSpace(self.touchedPos)
            local canMovecheckPos = self.starWorld:getPixelCollusion(targetPos)


            if self.mClickEffect then
                self.mClickEffect:removeFromParent(true)
                self.mClickEffect = nil
            end
            if canMovecheckPos ~= 2 then
                self.mClickEffect = ui.newEffect({
                        parent = self.mapBg,
                        effectName = "effect_ui_dianji",
                        zorder = 1,
                        position = self.mapBg:convertToNodeSpace(self.touchedPos),
                        loop = false,
                        endRelease = true,
                        endListener = function()
                            self.mClickEffect = nil
                        end
                    })
            end

            return true
        end,
        movedEvent = function (touch, event)
            local movedPos = touch:getLocation()
            -- 如移动距离过大，则认为是滑动事件
            if self.touchedPos and cc.pGetLength(cc.pSub(movedPos, self.touchedPos)) > 8 then
                self.isTouchScrolled = true
            end
        end,
        endedEvent = function (touch, event)
            -- 滑动事件完成，不响应点击移动事件
            if self.touchedPos and not self.isTouchScrolled and not self.isWakuang then
                local endPos = touch:getLocation()
                local targetPos = self.mapBg:convertToNodeSpace(endPos)
                local startPos = cc.p(self.mHeroNode:getPosition())

                local heroformPos = self:posTransform(startPos)
                local targetformPos = self:posTransform(targetPos)

                if heroformPos.x == targetformPos.x and heroformPos.y == targetformPos.y then
                    return
                end
                self:move(startPos, targetPos)
            end
        end,
        })
end

-- 主角移动
function ForgingDigOreLayer:move(startPos, dPos)
    -- 获取目标点tag
    local isCouldMove = self.starWorld:getPixelCollusion(dPos)
    -- 可以移动区
    if isCouldMove == 0 or isCouldMove == 1 then
        self:moveAction(startPos, dPos)
    -- 非移动区
    else
        -- 找到可移动且距离主角最短的点
        local heroformPos = self:posTransform(startPos)
        local centerformPos = self:posTransform(dPos)
        local endPos = self:getMovePos(centerformPos, heroformPos)
        -- 找到该点
        if endPos ~= nil then
            self:moveAction(startPos, endPos)
        else
            ui.showFlashView({text = TR("不可移动区太大")})
        end
    end
    self.touchedPos = nil
end
-- 移动动作
function ForgingDigOreLayer:moveAction(startPos, targetPos)
    local moveWayList = {}
    local canMovecheckPos = self.starWorld:getPixelCollusion(targetPos)
    if canMovecheckPos == 2 then
        print("障碍点", canMovecheckPos)
    else
        moveWayList = self.starWorld:calcTrack(startPos, targetPos)
    end
    self:actionFuc(moveWayList)
end


-- 以某点为中心找出离主角最短且可移动的点
function ForgingDigOreLayer:getMovePos(centerPos, heroPos)
    for circleNum = 1, 3 do
        -- 可移动点列表
        local canMovePosList = {}
        -- 遍历外围
        for i = -circleNum, circleNum do
            for j = -circleNum, circleNum do
                --剔除内围
                if math.abs(i) == circleNum or math.abs(j) == circleNum then
                    -- 坐标
                    local y = centerPos.y + i
                    local x = centerPos.x + j
                    -- 获取这点的tag
                    local curPos = self:formTransPos(cc.p(x, y))
                    local isCouldMove = self.starWorld:getPixelCollusion(curPos)
                    -- 可移动点
                    if (isCouldMove == 0 or isCouldMove == 1) and curPos.x > 0 and curPos.y > 0 then
                        table.insert(canMovePosList, curPos)
                    end
                end
            end
        end
        -- 列表不空
        if #canMovePosList > 0 then
            -- 找出最短点
            local minDis = cc.pGetLength(cc.pSub(canMovePosList[1], heroPos))
            local minIndex = 1
            for i = 1, #canMovePosList do
                local curDis = cc.pGetLength(cc.pSub(canMovePosList[i], heroPos))
                if minDis > curDis then
                    min = curDis
                    minIndex = i
                end
            end
            local endPos = clone(canMovePosList[minIndex])
            return endPos
        end
    end
    return nil
end

function ForgingDigOreLayer:formTransPos(indexPos)
    local itemSize = self.starWorld.itemSize
    return {x = (indexPos.x-0.5) * itemSize, y = (indexPos.y-0.5) * itemSize}
end

function ForgingDigOreLayer:posTransform(position)
    local itemSize = self.starWorld.itemSize
    local curPos = {x = math.ceil((position.x+0.5) / itemSize), y = math.ceil((position.y+0.5) / itemSize)}
    return curPos
end

function ForgingDigOreLayer.isRange(center, pos2, distance)
    if math.abs(center.x - pos2.x) < distance and math.abs(center.y - pos2.y) < distance then
        return true
    end
    return false
end

-------------------服务器请求相关---------------------
-- 多次挖矿
function ForgingDigOreLayer:requestForgeDebris(index, num)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TreasureDebris",
        methodName = "MiningForCount",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11207),
        svrMethodData = {self.debrisModelId, num},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11207 then
                -- 清空上一步内容，屏蔽操作
                Guide.manager:showGuideLayer({})
                Guide.manager:nextStep(eventID)
            end
            local oreNum = 0
            for key,valus in ipairs(response.Value.GetExpInfo) do
                oreNum = valus.GetExp + oreNum
            end

            self:refreshOreNum()


            if num == 1 then
                self:startExploitOre(index, response.Value, oreNum)
            else
                local debrisModel = nil
                for _, item in pairs(TreasureDebrisObj.mTreasureDebrisList) do
                    if item.TreasureDebrisModelId == self.debrisModelId then
                        debrisModel = item
                        break
                    end
                end
                local lastNum = debrisModel.TotalExp - oreNum
                local needNum = TreasureDebrisModel.items[self.debrisModelId].needExp
                local sendNum = needNum - lastNum
                self:startExploitOres(index, response.Value, oreNum)

                LayerManager.addLayer({
                    name = "challenge.ForgingDigOreShowUi",
                    data = {dropBaseInfo = response.Value, parentLayer = self, needore = sendNum, ctCount = num, pageType = 0, name = self.oreName, quality = self.mQuality},
                    cleanUp = false,
                })

            end
        end
    })
end

-- 获取抢夺列表
function ForgingDigOreLayer:requestLootInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TreasureDebris",
        methodName = "GetTreasureDebrisTargetList",
        svrMethodData = {self.debrisModelId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
                -- 初始化界面
            self:refreshHero(response.Value.TreasureLootTeamInfo)
        end
    })
end

-- 抢夺目标
function ForgingDigOreLayer:requestLootTarget(targetInfo)
    -- 次数
    local count = math.floor(PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA) / 2)
    if count <= 0 then
        MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eSTA, 2)
        return
    end

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TreasureDebris",
        methodName = "TreasureLoot",
        svrMethodData = {targetInfo.LootPlayerId, self.debrisModelId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 刷新矿石
            self:refreshOreNum()

            if self.nowOreNum >= self.needOreNum then
                LayerManager.removeLayer(self)
            end

            if response.Value.IfTargetCanLoot == false then
                ui.showFlashView(TR("对方处于免战中"))
                return
            end

            -- 战斗信息
            local value = response.Value

            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eChallengeGrab)
            -- 调用战斗页面
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eChallengeGrab),
                    callback = function(retData)
                        PvpResult.showPvpResultLayer(
                            ModuleSub.eChallengeGrab,
                            value,
                            {
                                PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
                                FAP = PlayerAttrObj:getPlayerAttrByName("FAP"),
                            },
                            {
                                PlayerName = targetInfo.Name,
                                FAP = targetInfo.FAP,
                                PlayerId = targetInfo.LootPlayerId,
                            }
                        )

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
        end
    })
end

-- 请求免战信息
function ForgingDigOreLayer:requestGetTreasureLootProtectInfo()
    HttpClient:request({
        moduleName = "TreasureLootProtect",
        methodName = "GetTreasureLootProtectInfo",
        callback = function(response)
            if response.Status == 0 then
                local endTime = response.Value.EndTime
                self:showProtectInfo(endTime)
                -- 开启新手引导， 刚进来时有地图移动动画
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 11206 then
                    Guide.manager:showGuideLayer({})
                    Utility.performWithDelay(self.mParentLayer, handler(self, self.executeGuide), 0)
                end
            end
        end
    })
end

-- 请求免战
function ForgingDigOreLayer:requestTreasureLootProtect(type)
    HttpClient:request({
        moduleName = "TreasureLootProtect",
        methodName = "TreasureLootProtect",
        svrMethodData = {type},
        callback = function(response)
            if response.Status == 0 then
                local endTime = response.Value.EndTime
                self:showProtectInfo(endTime)

                -- 移除弹窗
                if self.mPopLayer ~= nil and self.mPopLayer:getParent() ~= nil then
                    LayerManager.removeLayer(self.mPopLayer)
                end
                self.mPopLayer = nil

                ui.showFlashView(TR("购买成功"))
            end
        end
    })
end

-- ========================== 新手引导 ===========================
function ForgingDigOreLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向最近的一个矿
        [11206] = {clickNode = self:getMinDisOre()},
        -- 指向确定挖矿
        [11207] = {clickNode = self.popOkButton},
        -- 返回按钮
        [11209] = {clickNode = self.closeBtn},
    })
end

return ForgingDigOreLayer
