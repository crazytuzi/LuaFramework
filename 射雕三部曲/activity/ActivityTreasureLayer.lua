--[[
    文件名：ActivityTreasureLayer.lua
    文件描述：神兵谷
    创建人：yanghongsheng
    创建时间：2018.12.6
]]

local ActivityTreasureLayer = class("ActivityTreasureLayer", function(params)
    return display.newLayer()
end)

local MapPosList = {
    cc.p(189, 343),
    cc.p(152, 285),
    cc.p(108, 223),
    cc.p(64, 154),

    cc.p(131, 108),
    cc.p(175, 181),
    cc.p(214, 248),
    cc.p(251, 309),

    cc.p(347, 331),
    cc.p(316, 272),
    cc.p(281, 207),
    cc.p(244, 137),

    cc.p(316, 91),
    cc.p(352, 166),
    cc.p(383, 235),
    cc.p(413, 296),

    cc.p(506, 319),
    cc.p(482, 259),
    cc.p(456, 194),
    cc.p(426, 122),

    cc.p(506, 75),
    cc.p(534, 151),
    cc.p(555, 220),
    cc.p(578, 283),
}

function ActivityTreasureLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)

    -- 初始化页面控件
    self:initUI()

	self:requestGetInfo()
end

function ActivityTreasureLayer:initUI()
    -- 上部背景
    self.mMapBg = ui.newSprite("sbp_30.png")
    self.mMapBg:setPosition(320, 1136)
    self.mMapBg:setAnchorPoint(cc.p(0.5, 1))
    self.mParentLayer:addChild(self.mMapBg)
	--上部地图
    self:createMap()
    -- 创建下部奖励显示
    self:createDownReward()

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1045),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 1)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(45, 1045),
        clickAction = function()
            self:createProbabilityBox()
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 创建Q版人物模型
    self:createHero()

    -- 活动倒计时
    self.mTimeLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            size = 20,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mTimeLabel:setPosition(320, 940)
    self.mParentLayer:addChild(self.mTimeLabel)

    -- 探索按钮
    self.mExtractBtn = ui.newButton({
            text = TR("探索"),
            normalImage = "c_28.png",
            clickAction = function ()
                if (self.mBaseInfo.FreeNum + self.mBaseInfo.ChargeNum) <= 0 then
                    ui.showFlashView(TR("探索次数不足"))
                    return
                end
                self:requestExtract()
            end
        })
    self.mExtractBtn:setPosition(215, 125)
    self.mParentLayer:addChild(self.mExtractBtn)

    -- 确认选择按钮
    self.mRewardSelectBtn = ui.newButton({
            text = TR("确认选择"),
            normalImage = "c_28.png",
            clickAction = function ()
                -- 轮次奖励
                if self.mBaseInfo.TurnNum >= self.mNeedNumReward then
                    if #self.mSelectList < self.mCurRewardGearInfo.RewardNum then
                        ui.showFlashView(TR("请选择足够的奖励"))
                        return
                    end
                    self:requestGetReward()
                -- 累计奖励
                elseif self.mCurTotalRewardInfo then
                    if #self.mSelectList < self.mCurTotalRewardInfo.RewardNum then
                        ui.showFlashView(TR("请选择足够的奖励"))
                        return
                    end
                    self:requestGetTotalReward()
                end
            end
        })
    self.mRewardSelectBtn:setPosition(440, 125)
    self.mParentLayer:addChild(self.mRewardSelectBtn)

    -- 当前分数
    self.mCurScoreLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mCurScoreLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mCurScoreLabel:setPosition(15, 610)
    self.mParentLayer:addChild(self.mCurScoreLabel)
    -- 总分数
    self.mTotalScoreLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mTotalScoreLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mTotalScoreLabel:setPosition(15, 580)
    self.mParentLayer:addChild(self.mTotalScoreLabel)
    -- 可领取累计积分奖励
    self.mTotalRewardHintLabel = ui.newLabel({
            text = TR("可领取累计积分奖励"),
            color = cc.c3b(0xea, 0x2c, 0x00),
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.mTotalRewardHintLabel:setPosition(620, 570)
    self.mTotalRewardHintLabel:setAnchorPoint(cc.p(1, 0.5))
    self.mParentLayer:addChild(self.mTotalRewardHintLabel)
    -- 剩余次数
    self.mRemainNumLabel = ui.newLabel({
            text = "",
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 18,
        })
    self.mRemainNumLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mRemainNumLabel:setPosition(510, 125)
    self.mParentLayer:addChild(self.mRemainNumLabel)
    -- 还需充值多少
    self.mChargeLabel = ui.newLabel({
            text = "",
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 18,
            dimensions = cc.size(135, 0)
        })
    self.mChargeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mChargeLabel:setPosition(15, 125)
    self.mParentLayer:addChild(self.mChargeLabel)
end

-- 创建地图
function ActivityTreasureLayer:createMap()
    if not self.mMapNode then
        self.mMapNode = cc.Node:create()
        self.mMapBg:addChild(self.mMapNode)
    end
    self.mMapNode:removeAllChildren()

    for i, pos in ipairs(MapPosList) do
        local pieceSprite = ui.newSprite(string.format("sbp_%d.png", i))
        pieceSprite:setPosition(pos)
        self.mMapNode:addChild(pieceSprite)

        pieceSprite:setGray(self.mReceivePieceIdList and self.mReceivePieceIdList[i] or false)

        -- 添加神兵图
        if (not self.mReceivePieceIdList or not self.mReceivePieceIdList[i]) and self.mGoodsConfig then
            local shenbingSprite = ui.newSprite(self.mGoodsConfig[i].Pic)
            shenbingSprite:setPosition(pos)
            shenbingSprite:setScale(0.2)
            self.mMapNode:addChild(shenbingSprite, 1)
        end
    end
end

-- 创建移动的人物模型
function ActivityTreasureLayer:createHero()
    if not self.mHeroNode then
        self.mHeroNode = cc.Node:create()
        self.mMapBg:addChild(self.mHeroNode)
    end
    self.mHeroNode:removeAllChildren()

    -- local QHeroEffectModel = HeroQimageRelation.items[playerModelId]
    local positivePic, backPic = QFashionObj:getQFashionByDressType()
    -- 正面
    self.mHeroNode.positiveHero = ui.newEffect({
        parent = self.mHeroNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = positivePic,
        position = cc.p(0, 0),
        loop = true,
        endRelease = true,
        scale = 0.5,
    })
    -- 背面
    self.mHeroNode.backHero = ui.newEffect({
        parent = self.mHeroNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = backPic,
        position = cc.p(0, 0),
        loop = true,
        endRelease = true,
        scale = 0.5,
    })
    -- 移动
    self.mHeroNode.move = function (heroObj, targetId)
        local targetPos = MapPosList[targetId]
        local curX, curY = heroObj:getPosition()
        -- 上下
        heroObj.positiveHero:setVisible(not (targetPos.y > curY))
        heroObj.backHero:setVisible(targetPos.y > curY)
        -- 左右
        heroObj.positiveHero:setRotationSkewY(targetPos.x > curX and 0 or 180)
        heroObj.backHero:setRotationSkewY(targetPos.x > curX and 0 or 180)
        -- 切成走路
        heroObj.positiveHero:setAnimation(0, "zou", true)
        heroObj.backHero:setAnimation(0, "zou", true)
        -- 创建移动action
        local moveAction = cc.MoveTo:create(2, targetPos)
        local moveEndAction = cc.CallFunc:create(function (heroObj)
            -- 切成待机
            heroObj.positiveHero:setAnimation(0, "daiji", true)
            heroObj.backHero:setAnimation(0, "daiji", true)
            -- 切成正面
            heroObj.positiveHero:setVisible(true)
            heroObj.backHero:setVisible(false)
            -- 解禁探索按钮
            self.mExtractBtn:setEnabled(true)
            -- 飘获得分数
            ui.showFlashView(TR("获得积分%s", self.mGoodsConfig[self.mCurPieceId].GetScore))
            -- 播放特效
            local effectList = {
                [1] = {
                    effect = "effect_ui_shenbingu_s",
                    animation = "tt",
                },
                [2] = {
                    effect = "effect_ui_shenbingu_a",
                    animation = "a2",
                },
                [3] = {
                    effect = "effect_ui_shenbingu_b",
                    animation = "tt",
                },
                [4] = {
                    effect = "effect_ui_shenbingu_c",
                    animation = "c2",
                },
            }
            if self.mGoodsConfig[self.mCurPieceId].Level > 4 then
                self.mGoodsConfig[self.mCurPieceId].Level = 4
            elseif self.mGoodsConfig[self.mCurPieceId].Level < 1 then
                self.mGoodsConfig[self.mCurPieceId].Level = 1
            end
            ui.newEffect({
                parent = self.mMapBg,
                position = targetPos,
                effectName = effectList[self.mGoodsConfig[self.mCurPieceId].Level].effect,
                animation = effectList[self.mGoodsConfig[self.mCurPieceId].Level].animation,
                loop = false,
            })
            -- 更新界面
            self:refreshUI()
        end)

        heroObj:runAction(cc.Sequence:create(moveAction, moveEndAction))
        -- 禁用探索按钮
        self.mExtractBtn:setEnabled(false)

    end
    -- 初始化
    self.mHeroNode.positiveHero:setVisible(true)
    self.mHeroNode.backHero:setVisible(false)
    self.mHeroNode.positiveHero:setAnimation(0, "daiji", true)
    self.mHeroNode.backHero:setAnimation(0, "daiji", true)
    self.mHeroNode:setPosition(MapPosList[self.mCurPieceId or 1])

end

-- 创建下部奖励显示
function ActivityTreasureLayer:createDownReward()
    if not self.mRewardBg then
        self.mRewardBg = ui.newScale9Sprite("c_19.png", cc.size(640, 560))
        self.mRewardBg:setAnchorPoint(cc.p(0.5, 0))
        self.mRewardBg:setPosition(320, 0)
        self.mParentLayer:addChild(self.mRewardBg)
    end
    self.mRewardBg:removeAllChildren()

    -- 创建档位
    local GearsConfig = {
        [1] = {
            pic = "sbp_25.png",
            pos = cc.p(320, 485),
            lvStr = "S",
            effect = "effect_ui_shenbingu_s",
            animation = "s",
        },
        [2] = {
            pic = "sbp_26.png",
            pos = cc.p(320, 390),
            lvStr = "A",
            effect = "effect_ui_shenbingu_a",
            animation = "a",
        },
        [3] = {
            pic = "sbp_27.png",
            pos = cc.p(320, 295),
            lvStr = "B",
            effect = "effect_ui_shenbingu_b",
            animation = "b",
        },
        [4] = {
            pic = "sbp_28.png",
            pos = cc.p(320, 200),
            lvStr = "C",
            effect = "effect_ui_shenbingu_c",
            animation = "c",
        },
    }
    -- 选择奖励列表
    self.mSelectList = {}
    -- 选择框列表
    self.mSelectSpriteList = {}
    local selectNum = 0
    -- 创建档位奖励
    local function createRewardGear(gearId)
        local gearBg = ui.newSprite(GearsConfig[gearId].pic)
        gearBg:setPosition(GearsConfig[gearId].pos)
        self.mRewardBg:addChild(gearBg)
        local bgSize = gearBg:getContentSize()

        -- 奖励列表
        local rewardListView = ccui.ListView:create()
        rewardListView:setDirection(ccui.ScrollViewDir.horizontal)
        rewardListView:setBounceEnabled(true)
        rewardListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
        rewardListView:setItemsMargin(10)
        rewardListView:setAnchorPoint(cc.p(0, 0.5))
        rewardListView:setPosition(110, bgSize.height*0.5)
        rewardListView:setContentSize(cc.size(380, bgSize.height))
        gearBg:addChild(rewardListView)

        for _, rewardInfo in ipairs(self.mGearsRewardConfig[gearId]) do
            local itemSize = cc.size(75, bgSize.height)
            local rewardItem = ccui.Layout:create()
            rewardItem:setContentSize(itemSize)
            rewardListView:pushBackCustomItem(rewardItem)

            local reward = Utility.analysisStrResList(rewardInfo.Reward)[1]
            reward.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
            reward.onClickCallback = function ()
                -- 已选过
                if self.mReceiveRewardIdList[rewardInfo.OrderId] then
                    return
                end
                selectNum = 0
                -- 选择两次移动奖励
                if self.mBaseInfo.TurnNum >= self.mNeedNumReward and gearId == self.mCurRewardGearId then
                    selectNum = self.mCurRewardGearInfo.RewardNum
                -- 选择累计奖励
                elseif not (self.mBaseInfo.TurnNum >= self.mNeedNumReward) and self.mCurTotalRewardInfo and self.mCurTotalRewardInfo.RewardLevel == gearId then
                    selectNum = self.mCurTotalRewardInfo.RewardNum
                -- 不能选择奖励，调用默认
                else
                    CardNode.defaultCardClick(reward)
                    return
                end

                -- 已选择，则取消选择
                if table.indexof(self.mSelectList, rewardInfo.OrderId) then
                    rewardItem.selectSprite:setVisible(false)
                    table.remove(self.mSelectList, table.indexof(self.mSelectList, rewardInfo.OrderId))
                -- 数量已满，则取消第一个选择
                elseif #self.mSelectList >= selectNum then
                    self.mSelectSpriteList[self.mSelectList[1]]:setVisible(false)
                    table.remove(self.mSelectList, 1)
                    table.insert(self.mSelectList, rewardInfo.OrderId)
                    rewardItem.selectSprite:setVisible(true)
                else
                    table.insert(self.mSelectList, rewardInfo.OrderId)
                    rewardItem.selectSprite:setVisible(true)
                end
            end

            local rewardCard = CardNode.createCardNode(reward)
            rewardCard:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            rewardCard:setScale(0.8)
            rewardItem:addChild(rewardCard)
            -- 已领过置灰
            rewardCard:setGray(self.mReceiveRewardIdList[rewardInfo.OrderId] or false)

            -- 选择框
            local selectSprite = ui.newSprite("c_31.png")
            selectSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            selectSprite:setScale(0.8)
            selectSprite:setVisible(false)
            rewardItem:addChild(selectSprite)
            rewardItem.selectSprite = selectSprite
            self.mSelectSpriteList[rewardInfo.OrderId] = selectSprite
        end

        -- 分数提示
        local scoreStrList = {}
        for _, scoreInfo in pairs(self.mGearsScoreConfig) do
            if scoreInfo.RewardLevel == gearId then
                local scoreStr = scoreInfo.MinScore == scoreInfo.MaxScore and TR("%s分", scoreInfo.MaxScore) or TR("%s分-%s分", scoreInfo.MinScore, scoreInfo.MaxScore)
                local numStr = TR("奖励选%s", scoreInfo.RewardNum)
                table.insert(scoreStrList, scoreStr)
                table.insert(scoreStrList, numStr)
            end
        end
        
        local scoreLabel = ui.newLabel({
                text = table.concat(scoreStrList, "\n"),
                size = 18,
                color = cc.c3b(0x46, 0x22, 0x0d),
                align = ui.TEXT_ALIGN_CENTER,
            })
        scoreLabel:setPosition(560, bgSize.height*0.5)
        gearBg:addChild(scoreLabel)

        -- 添加特效
        if self.mBaseInfo.TurnNum >= self.mNeedNumReward then
            if gearId == self.mCurRewardGearId then
                ui.newEffect({
                    parent = gearBg,
                    effectName = GearsConfig[gearId].effect,
                    animation = GearsConfig[gearId].animation,
                    position = cc.p(55, bgSize.height*0.5),
                    loop = true,
                })
                ui.newEffect({
                    parent = gearBg,
                    effectName = "effect_ui_shenbingu_s",
                    animation = "liubian",
                    position = cc.p(bgSize.width*0.5, bgSize.height*0.5),
                    loop = true,
                })
            end
        elseif self.mCurTotalRewardInfo then
            if gearId == self.mCurTotalRewardInfo.RewardLevel then
                ui.newEffect({
                    parent = gearBg,
                    effectName = GearsConfig[gearId].effect,
                    animation = GearsConfig[gearId].animation,
                    position = cc.p(55, bgSize.height*0.5),
                    loop = true,
                })
                ui.newEffect({
                    parent = gearBg,
                    effectName = "effect_ui_shenbingu_s",
                    animation = "liubian",
                    position = cc.p(bgSize.width*0.5, bgSize.height*0.5),
                    loop = true,
                })
            end
        end
    end

    -- 创建四档
    for gearId, _ in pairs(self.mGearsRewardConfig or {}) do
        createRewardGear(gearId)
    end
end

-- 更新时间
function ActivityTreasureLayer:createUpdateTime()
    if self.mSchelTime then
        self.mTimeLabel:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end

    self.mSchelTime = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时：#f8ea3a%s",MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("活动倒计时：#f8ea3a00:00:00"))

            -- 停止倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end

            LayerManager.removeLayer(self)
        end
    end, 1)
end

-- 创建概率显示弹窗
function ActivityTreasureLayer:createProbabilityBox()
    local ruleList = {
        {
            tabName = TR("规则"),
            list = {
                TR("1、每轮神兵谷开启时赠送一次探索机会，点击探索选项，会随机探索神兵谷其中一片区域。"),
                TR("2、每次探索一片区域后都可以获得神兵，神兵将转化为积分，每探索两次结算一次积分，两次的积分总和可在提示的对应积分奖池中选择奖励，领取后道具将置灰，当前轮次不能再 领取。"),
                TR("3.神兵谷中被探索后的区域将置灰，在探索完所有区域前不会再次探索，探索完所有区域后，奖池中的道具将会刷新，地图也会刷新。"),
                TR("4.充值满120,600,1000,1600,2000,4000,6000,10000,12000,14000,16000,18000,20000,24000,26000,30000,32000,36000,38000,44000,46000,52000,54000,60000元宝都可获得一次探索次数，单笔充值最多获得24次探索机会。"),
                TR("5.每轮探索累计探索次数最高24次，抽取完24次后刷新。"),
                TR("6.每次抽取的积分将计入总积分，总积分达到一定时可以在S奖励中任选一件或者两件。"),
                TR("7.每天都会重置一轮新的神兵谷，每轮赠送一次探索次数，神兵谷重置后，充值进度也会重置。"),
            },
        },
    }
    local probabilityTab = {tabName = TR("概率"), list = {}}
    table.insert(ruleList, probabilityTab)
    -- 神兵获取概率
    for _, weaponInfo in pairs(self.mGoodsConfig) do
        local contentList = {}
        -- 神兵图
        table.insert(contentList, {
            customCb = function()
                local tempSprite = ui.newSprite(weaponInfo.Pic)
                tempSprite:setScale(0.2)
                return tempSprite
            end
        })
        -- 掉落概率
        table.insert(contentList, {
            text = TR("    ：掉落概率%d%%，价值积分%s点", weaponInfo.OddsTips, weaponInfo.GetScore),
            formatInfo = {
                color = cc.c3b(0x46, 0x22, 0x0d),
            },
        })

        table.insert(probabilityTab.list, contentList)
    end
    MsgBoxLayer.addTabTextLayer(TR("规则"), ruleList)
end

-- 刷新界面
function ActivityTreasureLayer:refreshUI()
    -- 刷新地图
    self:createMap()
    -- 刷新奖励
    self:createDownReward()
    -- 刷新人物位置
    self:createHero()

    -- 创建活动倒计时
    self:createUpdateTime()

    local isTotalReward = self.mCurTotalRewardInfo and true or false
    -- 探索按钮
    self.mExtractBtn:setEnabled(self.mBaseInfo.TurnNum < self.mNeedNumReward and not isTotalReward)
    -- 选择奖励按钮
    self.mRewardSelectBtn:setEnabled(self.mBaseInfo.TurnNum >= self.mNeedNumReward or isTotalReward)
    -- 如果有累计奖励则飘窗提示
    if isTotalReward then
        ui.showFlashView(TR("累计积分达到%s，可以领取累计奖励", self.mCurTotalRewardInfo.Score))
    end

    -- 当前积分
    self.mCurScoreLabel:setString(TR("当前分数：%s", self.mCurScore))
    -- 总积分
    self.mTotalScoreLabel:setString(TR("总积分：%s%s#F7F5F0/%s", self.mBaseInfo.TotalScore < self.mNextTotalRewardInfo.Score and "#ea2c00" or "#F7F5F0", self.mBaseInfo.TotalScore, self.mNextTotalRewardInfo.Score))
    -- 是否显示可领取累计奖励
    self.mTotalRewardHintLabel:setVisible(self.mCurTotalRewardInfo and true or false)
    -- 剩余次数
    self.mRemainNumLabel:setString(TR("剩余次数：%s", self.mBaseInfo.ChargeNum+self.mBaseInfo.FreeNum))
    -- 还要充值多少
    self.mChargeLabel:setString(self.mNeedCharge ~= 0 and TR("再充值%s元宝可获得一次探索", self.mNeedCharge) or "")
end

function ActivityTreasureLayer:refreshBaseData(GodsoldierInfo)
    self.mBaseInfo = GodsoldierInfo
    -- 已走过的图块id
    self.mReceivePieceIdList = {}
    local tempList = string.splitBySep(self.mBaseInfo.GodsoldierIdStr, ",")
    for _, pieceId in pairs(tempList) do
        self.mReceivePieceIdList[tonumber(pieceId)] = true
    end
    -- hero所在位置
    self.mCurPieceId = 1
    if tempList and next(tempList) then
        self.mCurPieceId = tonumber(tempList[#tempList])
    end
    -- 当前分数
    self.mCurScore = 0
    local scoreList = Utility.analysisStrAttrList(self.mBaseInfo.TurnIdStr)
    for _, scoreInfo in pairs(scoreList) do
        self.mCurScore = self.mCurScore + scoreInfo.value
    end
    -- 当前奖励档位
    self.mCurRewardGearId = 0
    self.mCurRewardGearInfo = nil
    for _, scoreInfo in pairs(self.mGearsScoreConfig) do
        if self.mCurScore >= scoreInfo.MinScore and self.mCurScore <= scoreInfo.MaxScore then
            self.mCurRewardGearId = scoreInfo.RewardLevel
            self.mCurRewardGearInfo = scoreInfo
            break
        end
    end
    -- 领取过的累计奖励
    self.mReceiveTotalRewardList = {}
    local tempList = string.splitBySep(self.mBaseInfo.TotalScoreRewardIdStr, ",")
    for _, score in pairs(tempList) do
        self.mReceiveTotalRewardList[tonumber(score)] = true
    end
    -- 当前累计奖励档位
    self.mCurTotalRewardInfo = nil
    for _, scoreInfo in ipairs(self.mGearsTotalScoreConfig) do
        if scoreInfo.Score <= self.mBaseInfo.TotalScore and not self.mReceiveTotalRewardList[scoreInfo.Score] then
            self.mCurTotalRewardInfo = scoreInfo
            break
        end
    end
    -- 下一个累计奖励
    self.mNextTotalRewardInfo = nil
    for _, scoreInfo in ipairs(self.mGearsTotalScoreConfig) do
        if not self.mReceiveTotalRewardList[scoreInfo.Score] then
            self.mNextTotalRewardInfo = scoreInfo
            break
        end
    end
    if not self.mNextTotalRewardInfo then self.mNextTotalRewardInfo = self.mGearsTotalScoreConfig[#self.mGearsTotalScoreConfig] end
    -- 还需充多少得一次
    self.mNeedCharge = 0
    for _, chargeInfo in ipairs(self.mChargeConfig) do
        if chargeInfo.ChargeNum > self.mBaseInfo.ChargeMoney then
            self.mNeedCharge = chargeInfo.ChargeNum - self.mBaseInfo.ChargeMoney
            break
        end
    end
    -- 领取过的奖励列表
    self.mReceiveRewardIdList = {}
    local tempList = string.splitBySep(self.mBaseInfo.TurnRewardIdStr, ",")
    for _, rewardId in pairs(tempList) do
        self.mReceiveRewardIdList[tonumber(rewardId)] = true
    end
    -- 排序奖励
    for _, gearsRewardList in pairs(self.mGearsRewardConfig) do
        table.sort(gearsRewardList, function (rewardInfo1, rewardInfo2)
            if self.mReceiveRewardIdList[rewardInfo1.OrderId] ~= self.mReceiveRewardIdList[rewardInfo2.OrderId] then
                return not self.mReceiveRewardIdList[rewardInfo1.OrderId]
            end

            return rewardInfo1.OrderId < rewardInfo2.OrderId
        end)
    end
end

function ActivityTreasureLayer:initData(response)
    -- 活动结束时间
    self.mEndTime = response.Value.EndTime
    -- 需要移动几次，可以抽奖
    self.mNeedNumReward = response.Value.SettlementNum
    -- 24块道具显示配置
    self.mGoodsConfig = {}
    for _, pieceInfo in pairs(response.Value.GodsoldierGoodsConfig) do
        self.mGoodsConfig[pieceInfo.OrderId] = pieceInfo
    end
    -- 档位奖励
    self.mGearsRewardConfig = {}
    for _, rewardInfo in pairs(response.Value.GodsoldierRewardConfig) do
        self.mGearsRewardConfig[rewardInfo.Level] = self.mGearsRewardConfig[rewardInfo.Level] or {}
        table.insert(self.mGearsRewardConfig[rewardInfo.Level], rewardInfo)
    end
    -- 档位对应积分
    self.mGearsScoreConfig = response.Value.GodsoldierScoreRewardConfig
    -- 累计积分奖励
    self.mGearsTotalScoreConfig = response.Value.GodsoldierTotalScoreRewardConfig
    -- 排序
    table.sort(self.mGearsTotalScoreConfig, function (scoreInfo1, scoreInfo2)
        return scoreInfo1.Score < scoreInfo2.Score
    end)
    -- 充值配置
    self.mChargeConfig = response.Value.GodsoldierChargeConfig
    -- 排序
    table.sort(self.mChargeConfig, function (chargeInfo1, chargeInfo2)
        return chargeInfo1.ChargeNum < chargeInfo2.ChargeNum
    end)
    -- 基础信息
    self:refreshBaseData(response.Value.GodsoldierInfo)
end

--======================================网络请求=================================
--请求信息
function ActivityTreasureLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedGodsoldier", 
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
            -- dump(data.Value)

        	self:initData(data)

            self:refreshUI()
        end
    })
end
--请求刷新奖励列表
function ActivityTreasureLayer:requestExtract()
	HttpClient:request({
        moduleName = "TimedGodsoldier", 
        methodName = "Extract",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end

            self:refreshBaseData(data.Value.GodsoldierInfo)

            self.mHeroNode:move(self.mCurPieceId)
        end
    })
end

--请求获取奖励
function ActivityTreasureLayer:requestGetReward()
	HttpClient:request({
        moduleName = "TimedGodsoldier", 
        methodName = "DrawSettlementReward",
        svrMethodData = {self.mCurRewardGearId, self.mSelectList},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self:refreshBaseData(data.Value.GodsoldierInfo)

            self:refreshUI()
        end
    })
end

-- 请求累计奖励
function ActivityTreasureLayer:requestGetTotalReward()
    HttpClient:request({
        moduleName = "TimedGodsoldier", 
        methodName = "DrawTotalScoreReward",
        svrMethodData = {self.mCurTotalRewardInfo.Score, self.mSelectList},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self:refreshBaseData(data.Value.GodsoldierInfo)

            self:refreshUI()
        end
    })
end

return ActivityTreasureLayer