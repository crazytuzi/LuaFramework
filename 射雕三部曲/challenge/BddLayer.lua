--[[
    文件名：BddLayer.lua
    描述：神装塔（比武招亲）
    创建人：yanghongsheng
    创建时间：2017.4.20
-- ]]


local BddLayer = class("BddLayer",function()
    return display.newLayer()
end)

local limitStoreHadShow = false

--[[
    参数注释
    params{
        isAction 是否运行动画效果
        curNode  当前节点
    }
]]
function BddLayer:ctor(params)
    self.mIsAction = params.isAction
    self.mCurNode = params.curNode
    --父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 星级宝库当前选中index
    self.curSelBtnTag = 1
    -- 历史最高星数
    self.historyMaxNum = 0

    self:initUI() --初始化UI
    self:requestInfo() --请求数据
end

-- 提取数据
function BddLayer:getRestoreData()
    local nodeId = nil
    if self.mCurFloorData then
        nodeId = self.mCurFloorData.NodeId
    end

    local retData = {
        isAction = self.mIsAction,
        curNode = nodeId
    }

    return retData
end

--初始化UI
function BddLayer:initUI()
    --背景
    local bgSprite = ui.newSprite("bwzq_03.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    bgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite

    -- 红飘带（特效）
    local redBgEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_biwuzhaoqin",
            position = cc.p(320, 570),
            loop = true,
        })

    -- 层数背景
    local floorBg = ui.newSprite("bwzq_10.png")
    floorBg:setPosition(320, 1000)
    self.mParentLayer:addChild(floorBg)

    --当前层数
    local floorLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x51, 0x18, 0x0d),
        size = 26,
        x = 320,
        y = 1045,
    })
    self.mParentLayer:addChild(floorLabel)
    self.mFloorLabel = floorLabel

    --历史最高
    local maxLabel = ui.newLabel({
        text = "",
        size = 22,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0xe0, 0xe0, 0xe0),
        outlineColor = cc.c3b(0x35, 0x35, 0x35),
        outlineSize = 2,
    })
    maxLabel:setPosition(120, 1000)
    self.mParentLayer:addChild(maxLabel)
    self.mMaxLabel = maxLabel
    --本次挑战
    local challengeLabel = ui.newLabel({
        text = "",
        size = 22,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0xff, 0xe8, 0x7f),
        outlineColor = cc.c3b(0x35, 0x35, 0x35),
        outlineSize = 2,
    })
    challengeLabel:setPosition(120, 960)
    self.mParentLayer:addChild(challengeLabel)
    self.mChallengeLabel = challengeLabel
    -- 抽奖星数
    local luckdrawLabel = ui.newLabel({
        text = "",
        size = 22,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0xe0, 0xe0, 0xe0),
        outlineColor = cc.c3b(0x35, 0x35, 0x35),
        outlineSize = 2,
    })
    luckdrawLabel:setPosition(360, 1000)
    self.mParentLayer:addChild(luckdrawLabel)
    self.luckdrawLabel = luckdrawLabel

    -- 推荐战力显示
    self.mRecommendLabel = ui.newFAPView(0, false)
    self.mRecommendLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRecommendLabel:setPosition(320, 480)
    self.mParentLayer:addChild(self.mRecommendLabel, 10)
   -- ui.showPopAction(self.mRecommendLabel)

    --底部背景
    local bottomSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 460))
    self.mParentLayer:addChild(bottomSprite)
    bottomSprite:setAnchorPoint(cc.p(0.5, 0))
    bottomSprite:setPosition(320, 0)

    --条件背景
    local conditionBg = ui.newScale9Sprite("c_17.png", cc.size(600,220))
    conditionBg:setAnchorPoint(cc.p(0.5, 1))
    conditionBg:setPosition(320, bottomSprite:getContentSize().height-40)
    bottomSprite:addChild(conditionBg)
    local conditionWhiteBg = ui.newScale9Sprite("c_54.png", cc.size(590,210))
    conditionWhiteBg:setAnchorPoint(cc.p(0.5, 0.5))
    conditionWhiteBg:setPosition(conditionBg:getContentSize().width*0.5, conditionBg:getContentSize().height*0.5)
    conditionBg:addChild(conditionWhiteBg)

    -- "通关条件"Label
    local conditionLabel = ui.newLabel({
        text = TR("满星通关条件"),
        size = 24,
        color = cc.c3b(0xfa, 0xf6, 0xf1),
        outlineColor = cc.c3b(0x8c, 0x49, 0x38),
        outlineSize = 2,
    })
    conditionLabel:setAnchorPoint(cc.p(0.5, 1))
    conditionLabel:setPosition(conditionWhiteBg:getContentSize().width*0.5, conditionWhiteBg:getContentSize().height-5)
    conditionWhiteBg:addChild(conditionLabel)

    -- 重置次数
    local resetNumLabel = ui.newLabel({
        text = "",
        size = 20,
        color = Enums.Color.eBlack
    })
    resetNumLabel:setAnchorPoint(cc.p(0.5, 0.5))
    resetNumLabel:setPosition(150, 180)
    bottomSprite:addChild(resetNumLabel)
    self.resetNumLabel = resetNumLabel

    -- 重置按钮
    local resetBtn = ui.newButton({
        normalImage = "c_33.png",
        --disabledImage = "c_82.png",
        text = TR("重置"),
        clickAction = function()
            local text = ""
            local info = BddResetUseRelation.items[self.mFloorData.Info.ResetCount + 1]
            if not info then
                text = TR("今日重置次数已达上限")
                ui.showFlashView({text = text})
                -- self:requestReset()
            elseif info.useDiamond == 0 then
                text = TR("本次重置免费")
                ui.showFlashView({text = text})
                self:requestReset()
            else
                local hintText = TR("消耗%d%s重置", info.useDiamond, ResourcetypeSubName[ResourcetypeSub.eDiamond])
                self.resetHintBox = MsgBoxLayer.addOKLayer(
                        hintText,
                        TR("提示"),
                        {
                            {
                                text = TR("确定"),
                                normalImage = "c_28.png",
                                clickAction = function ()
                                    LayerManager.removeLayer(self.resetHintBox)
                                    text = hintText
                                    ui.showFlashView({text = text})
                                    self:requestReset()
                                end
                            },
                        },
                        {}
                    )

            end
        end
    })
    resetBtn:setPosition(150, 140)
    bottomSprite:addChild(resetBtn)
    self.resetBtn = resetBtn

    -- 挑战按钮
    local challengeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("挑战"),
        clickAction = function()
            if self.isMaxFloor then
                ui.showFlashView({text = TR("你已完成所有关卡")})
                return
            end
            self:requestGetFightInfo(self.mCurFloorData.NodeId)
        end
    })
    challengeBtn:setPosition(450, 140)
    bottomSprite:addChild(challengeBtn)
    self.challengeBtn = challengeBtn

    -- 下一关按钮
    local nextFightBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("下一关"),
        clickAction = function()
            self.nextHintLayer = MsgBoxLayer.addOKLayer(TR("进入下一关后，无法回到继续挑战本关，是否确定进入？"),
                TR("提示"),
                {
                    {
                        text = TR("确定"),
                        normalImage = "c_28.png",
                        clickAction = function ()
                            self:requestGoNext()
                            LayerManager.removeLayer(self.nextHintLayer)
                            self.nextHintLayer = nil
                        end
                    }
                },
                {})
        end
    })
    nextFightBtn:setPosition(450, 140)
    bottomSprite:addChild(nextFightBtn)
    self.mNextFight = nextFightBtn

    -- 扫荡按钮
    local sweepBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("一键登顶"),
        clickAction = function()
            self:requestOneKeyMax()
        end
    })
    sweepBtn:setPosition(320, 140)
    bottomSprite:addChild(sweepBtn)
    self.sweepBtn = sweepBtn
    -- 排行榜
    local rankBtn = ui.newButton({
        normalImage = "tb_16.png",
        clickAction = function()
            LayerManager.addLayer({
                    name = "challenge.BddRankLayer",
                })
        end
    })
    rankBtn:setPosition(580, 910)
    self.mParentLayer:addChild(rankBtn)
    -- 神装塔商店
    local shopBtn = ui.newButton({
        normalImage = "bwzq_12.png",
        clickAction = function()
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 115105 then
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end

            self:showShopChangeBox()
        end
    })
    shopBtn:setPosition(580, 815)
    self.mParentLayer:addChild(shopBtn)
    -- 添加小红点
    local eventNames = RedDotInfoObj:getEvents(ModuleSub.ePracticeBloodyDemonDomain)
    local totalKeys = {"Shop_1", "Shop_2", "Shop_3"}
    for _,v in ipairs(totalKeys) do
        table.insert(eventNames, EventsName.eRedDotPrefix .. ModuleSub.ePracticeBloodyDemonDomain .. v)
    end
    local function dealRedDotVisible(newSprite)
        local isVisible = false
        for _,v in ipairs(totalKeys) do
            local subVisible = RedDotInfoObj:isValid(ModuleSub.ePracticeBloodyDemonDomain, v)
            if subVisible then
                isVisible = true
                break
            end
        end
        newSprite:setVisible(isVisible)
    end
    ui.createAutoBubble({parent = shopBtn, refreshFunc = dealRedDotVisible, eventName = eventNames})
    -- 保存按钮，引导使用
    self.shopBtn = shopBtn

    -- 布阵
    local campBtn = ui.newButton({
        normalImage = "tb_11.png",
        clickAction = function()
            LayerManager.addLayer({
                    cleanUp = false,
                    name = "team.CampLayer",
                })
        end
    })
    campBtn:setPosition(580, 720)
    self.mParentLayer:addChild(campBtn)
    self.campBtn = campBtn

    -- 兑换
    local conversionBtn = ui.newButton({
        normalImage = "tb_43.png",
        clickAction = function()
            LayerManager.addLayer({
                    name = "challenge.BddExchangeLayer",
                    cleanUp = false,
                    data = {
                        historyMaxNum = self.historyMaxNum
                    }
                })
        end
    })
    conversionBtn:setPosition(580, 625)
    self.mParentLayer:addChild(conversionBtn)

    -- 规则
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function()
            local rule = {
                [1] = TR("1.每次挑战中达成一个目标即可获得1颗星星（星星可累计，达成目标越多，获得星星越多）"),
                [2] = TR("2.累积的星星可以在比武招亲星级宝库中进行抽奖"),
                [3] = TR("3.达成挑战关卡所有通关条件后即可进入下一关，进入下一关后无法返回之前的关卡"),
                [4] = TR("4.挑战关卡失败或未达到满星通关，则停留在当前关卡，可选择再次挑战或直接进入下一关"),
                [5] = TR("5.玩家每日可免费重置一次比武招亲"),
            }
            MsgBoxLayer.addRuleHintLayer(
                    TR("规则"),
                    rule
                )
        end
    })
    ruleBtn:setPosition(50, 1050)
    self.mParentLayer:addChild(ruleBtn)

    -- 返回
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(590, 1050)
    self.mParentLayer:addChild(closeBtn)

    -- 通关条件list
    local listView = ccui.ListView:create()
    self.mListViewSize = cc.size(400, 150)
    listView:setItemsMargin(5)
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setContentSize(self.mListViewSize)
    listView:setPosition(50, 210)
    listView:setAnchorPoint(cc.p(0, 0))
    listView:setChildrenActionType(0)
    self.mParentLayer:addChild(listView)
    self.mConditionList = listView

    -- 满星首通
    local maxStarSprite = ui.newSprite("bwzq_04.png")
    maxStarSprite:setPosition(480, 300)
    bottomSprite:addChild(maxStarSprite)

    local maxStarCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eDiamond
        })
    maxStarCard:setPosition(550, 300)
    bottomSprite:addChild(maxStarCard)
    self.maxStarCard = maxStarCard

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eVIT,
        }
    })
    self:addChild(topResource)
end


-- 显示一键登顶对话框
function BddLayer:showOneKeyMaxBox(params)
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 背景
        local blackBg = ui.newScale9Sprite("c_17.png", cc.size(532, 550))
        blackBg:setPosition(bgSize.width*0.5, bgSize.height*0.51)
        bgSprite:addChild(blackBg)
        -- 奖励列表
        local listViewSize = cc.size(520, 540)
        local passList = ccui.ListView:create()
        passList:setDirection(ccui.ScrollViewDir.vertical)
        passList:setBounceEnabled(true)
        passList:setContentSize(listViewSize)
        passList:setAnchorPoint(cc.p(0.5, 0.5))
        passList:setPosition(blackBg:getContentSize().width*0.5, blackBg:getContentSize().height*0.5)
        blackBg:addChild(passList)

        local createCell = function(floorNum)
            local cellSize = cc.size(listViewSize.width, 180)
            local cellItem = ccui.Layout:create()
            cellItem:setContentSize(cellSize)

            -- 背景
            local cellBg = ui.newScale9Sprite("c_54.png", cellSize)
            cellBg:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellItem:addChild(cellBg)
            -- title
            local titleLabel = ui.newLabel({
                    text = TR("第%d层", floorNum-10),
                    color = Enums.Color.eNormalWhite,
                    outlineColor = Enums.Color.eRed,
                    size = 24
                })
            titleLabel:setPosition(cellSize.width*0.5, cellSize.height*0.88)
            cellItem:addChild(titleLabel)
            -- 本层挑战
            local starCountLabel = ui.newLabel({
                    text = TR("本层挑战：%s%d {c_75.png}",
                            "#d38212",
                            BddClearanceModel.items_count),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 24,
                })
            starCountLabel:setAnchorPoint(cc.p(0, 0))
            starCountLabel:setPosition(cellSize.width*0.05, cellSize.height*0.5)
            cellItem:addChild(starCountLabel)
            -- 本轮挑战
            local curCountLabel = ui.newLabel({
                text = TR("本轮挑战：%s%d {c_75.png}",
                            "#d38212",
                            BddClearanceModel.items_count*(floorNum-10)),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
            })
            curCountLabel:setAnchorPoint(cc.p(0, 0))
            curCountLabel:setPosition(cellSize.width*0.05, cellSize.height*0.15)
            cellItem:addChild(curCountLabel)
            -- 奖励列表
            local rewardList = self:getNodeRewardList(params.RewardInfo[tostring(floorNum)])
            local cardList = ui.createCardList({
                    maxViewWidth = 150,
                    space = -5,
                    cardDataList = rewardList,
                    allowClick = true
                })
            cardList:setSwallowTouches(false)
            cardList:setAnchorPoint(cc.p(0, 0.5))
            cardList:setPosition(cellSize.width*0.45, cellSize.height*0.4)
            cellItem:addChild(cardList)
            -- 完美通关
            local perfectSprite = ui.newSprite("bwzq_01.png")
            perfectSprite:setPosition(cellSize.width*0.87, cellSize.height*0.4)
            cellItem:addChild(perfectSprite)

            return cellItem
        end

        if params.Info.MaxThreeNode < BddNodeModel.items[11].ID then return end

        for i = BddNodeModel.items[11].ID, params.Info.MaxThreeNode do
            local cellItem = createCell(i)
            passList:pushBackCustomItem(cellItem)
        end
        local function action(item)
            item:setScale(0)
            local scale = cc.ScaleTo:create(0.5, 1)
            item:runAction(scale)
        end
        self.listviewAction(passList, action)
    end

    -- 创建对话框
    local boxSize = cc.size(600, 720)
    self.showOneKeyMaxLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = boxSize,
            title = TR("一键登顶"),
            btnInfos = {
                {
                    text = TR("登顶完成"),
                    normalImage = "c_28.png",
                    fontSize = 22,
                    outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
                }
            },
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end
function BddLayer.listviewAction(listObj, action, dt)
    if not listObj then
        return
    end
    if not action then
        return
    end
    if not dt then
        dt = 0.5
    end

    -- 设置动画效果
    listObj:forceDoLayout()
    local innerNode = listObj:getInnerContainer()
    local listSize = listObj:getContentSize()
    local innerSize = innerNode:getContentSize()
    local innerX, innerY = innerNode:getPosition()

    local listCount = 0
    local curItem = listObj:getItem(listCount)
    while curItem do
        curItem:setVisible(false)
        -- 动画配置
        local actionList = {
            -- 延时
            cc.DelayTime:create(listCount*dt),
            -- 动作
            cc.CallFunc:create(function(curItem)
                curItem:setVisible(true)
                action(curItem)
                local x, y = curItem:getPosition()
                local offestY = innerSize.height - y
                if offestY > listSize.height then
                    local moveInner = cc.MoveTo:create(0.25, cc.p(innerX, -y))
                    innerNode:runAction(moveInner)
                end
            end)
        }
        -- 执行动作
        curItem:runAction(cc.Sequence:create(actionList))
        -- 更新循环变量
        listCount = listCount + 1
        curItem = listObj:getItem(listCount)
    end
end
-- 合并奖励
function BddLayer:getNodeRewardList(List)
    if not List then return end

    local rewardList = {}
    for k, v in pairs(List) do
        local reward = rewardList[v.ModelId]
        if reward then
            reward.num = reward.num + v.Count
        else
            local item = {}
            item.resourceTypeSub = v.ResourceTypeSub
            item.modelId = v.ModelId
            item.num = v.Count
            rewardList[v.ModelId] = item
        end
    end

    local temList = {}
    local count = 1
    for _, v in pairs(rewardList) do
        temList[count] = v
        count = count + 1
    end
    return temList
end

function BddLayer:createBox(tag)
    local boxEffectList = {
        [1] = "effect_tongbaoxiang",
        [2] = "effect_yinbaoxiang",
        [3] = "effect_jingbaoxiang",
    }
    if self.boxBgSprite == nil then return end
    local boxBgSize = self.boxBgSprite:getContentSize()
    local rewardBoxEffect = ui.newEffect({
            parent = self.boxBgSprite,
            effectName = boxEffectList[tag],
            position = cc.p(boxBgSize.width*0.3, boxBgSize.height*0.52),
            scale = 0.5,
        })
    return rewardBoxEffect
end

-- 显示星级宝库对话框
function BddLayer:showShopChangeBox()
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 刷新tab
        local refreshTab = function(selBtnTag)
            -- 背景
            if not self.boxBgSprite then
                self.boxBgSprite = ui.newSprite("bwzq_09.png")
                self.boxBgSprite:setPosition(bgSize.width*0.5, bgSize.height*0.55-5)
                bgSprite:addChild(self.boxBgSprite)
            end
            local boxBgSize = self.boxBgSprite:getContentSize()
            -- 宝箱图
            if not self.rewardBoxEffect then
                self.rewardBoxEffect = self:createBox(selBtnTag)
            end

            --提示字体
            local wordColor
            if self.historyMaxNum < BddChangeShopRelation.items[selBtnTag].highStarsNum then
                wordColor = Enums.Color.eRedH
            else
                wordColor = "#2cf12c"
            end
            local labelInfo = TR("需要达到最高{%s}%s%d", "c_75.png", wordColor, BddChangeShopRelation.items[selBtnTag].highStarsNum)
            if self.mLabel then
                self.mLabel:removeFromParent(true)
                self.mLabel = nil
            end
            if not self.mLabel then
                self.mLabel = ui.newLabel({
                    text = labelInfo,
                    size = 20,
                    -- color = cc.c3b(0x46,0x22,0x0d),
                })
                self.mLabel:setAnchorPoint(cc.p(0, 0.5))
                self.mLabel:setPosition(80, bgSize.height / 2 - 130)
                bgSprite:addChild(self.mLabel)
            end


            -- 奖励列表
            if not self.rewardBoxList then
                local listViewSize = cc.size(boxBgSize.width*0.5, boxBgSize.height*0.75)
                self.rewardBoxList = ccui.ListView:create()
                self.rewardBoxList:setDirection(ccui.ScrollViewDir.vertical)
                self.rewardBoxList:setBounceEnabled(true)
                self.rewardBoxList:setContentSize(listViewSize)
                self.rewardBoxList:setAnchorPoint(cc.p(0.5, 0.5))
                self.rewardBoxList:setPosition(boxBgSize.width*0.75, boxBgSize.height*0.42)
                self.boxBgSprite:addChild(self.rewardBoxList)
            end
            -- 抽一次消耗label
            if not self.luckdrawOnceLabel then
                self.luckdrawOnceLabel = ui.newLabel({
                        text = TR("{%s}%d/%d", "c_75.png", 100, 30),
                        size = 20,
                        color = cc.c3b(0x46,0x22,0x0d),
                    })
                self.luckdrawOnceLabel:setAnchorPoint(cc.p(0.5, 0.5))
                self.luckdrawOnceLabel:setPosition(bgSize.width*0.25, bgSize.height*0.18)
                bgSprite:addChild(self.luckdrawOnceLabel)
            end
            -- 抽十次消耗label
            if not self.luckdrawTenLabel then
                self.luckdrawTenLabel = ui.newLabel({
                        text = TR("{%s}%d", "c_75.png", 300),
                        size = 20,
                        color = cc.c3b(0x46,0x22,0x0d),
                    })
                self.luckdrawTenLabel:setAnchorPoint(cc.p(0.5, 0.5))
                self.luckdrawTenLabel:setPosition(bgSize.width*0.75, bgSize.height*0.18)
                bgSprite:addChild(self.luckdrawTenLabel)
            end
            -- 抽一次按钮
            if self.luckdrawOnceBtn then
                self.luckdrawOnceBtn:removeFromParent(true)
                self.luckdrawOnceBtn = nil
            end
            if not self.luckdrawOnceBtn then
                self.luckdrawOnceBtn = ui.newButton({
                        normalImage = "c_28.png",
                        text = TR("抽一次"),
                        clickAction = function ()
                            self:requestLuckDraw(selBtnTag, 1)
                        end
                    })
                self.luckdrawOnceBtn:setAnchorPoint(cc.p(0.5, 0.5))
                self.luckdrawOnceBtn:setPosition(bgSize.width*0.25, bgSize.height*0.1)
                bgSprite:addChild(self.luckdrawOnceBtn)
                self.luckdrawOnceBtn:setEnabled(false)

                if self.mFloorData.Info.MaxStarCount >= BddChangeShopRelation.items[selBtnTag].highStarsNum then
                    self.luckdrawOnceBtn:setEnabled(true)
                end
            end
            -- 抽十次按钮
            if self.luckdrawTenBtn then
                self.luckdrawTenBtn:removeFromParent(true)
                self.luckdrawTenBtn = nil
            end
            if not self.luckdrawTenBtn then
                self.luckdrawTenBtn = ui.newButton({
                        normalImage = "c_33.png",
                        text = TR("抽十次"),
                        clickAction = function ()
                            self:requestLuckDraw(selBtnTag, 10)
                        end
                    })
                self.luckdrawTenBtn:setAnchorPoint(cc.p(0.5, 0.5))
                self.luckdrawTenBtn:setPosition(bgSize.width*0.75, bgSize.height*0.1)
                bgSprite:addChild(self.luckdrawTenBtn)
                self.luckdrawTenBtn:setEnabled(false)

                if self.mFloorData.Info.MaxStarCount >= BddChangeShopRelation.items[selBtnTag].highStarsNum then
                    self.luckdrawTenBtn:setEnabled(true)
                end
            end

            -- 刷新tab数据
            self:refreshChangeShop(selBtnTag)
        end
        -- 创建tabView
        local btnInfos = {
            [1] = {
                tag = 1,
                text = TR("普通宝库"),
                fontSize = 24,
                subKey = "Shop_1",
            },
            [2] = {
                tag = 2,
                text = TR("高级宝库"),
                fontSize = 24,
                subKey = "Shop_2",
            },
            [3] = {
                tag = 3,
                text = TR("超级宝库"),
                fontSize = 24,
                subKey = "Shop_3",
            },
        }

        -- if self.mFloorData.Info.MaxStarCount > BddChangeShopRelation.items[2].highStarsNum then
        --     table.insert(btnInfos, {tag = 2, text = TR("高级宝库"), fontSize = 24})
        -- elseif self.mFloorData.Info.MaxStarCount > BddChangeShopRelation.items[3].highStarsNum then
        --     table.insert(btnInfos, {tag = 2, text = TR("超级宝库"), fontSize = 24})
        -- end

        local tabView = require("common.TabView"):create({
                btnInfos = btnInfos,
                defaultSelectTag = 1,
                viewSize = cc.size(bgSize.width*0.9, 60),
                needLine = false,
                onSelectChange = function (selBtnTag)
                    refreshTab(selBtnTag)
                end
            })
        tabView:setAnchorPoint(cc.p(0.5, 0))
        tabView:setPosition(bgSize.width*0.5, bgSize.height*0.8)
        bgSprite:addChild(tabView)

        for _,v in ipairs(btnInfos) do
            local redKey = v.subKey
            local function dealRedDotVisible(newSprite)
                newSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.ePracticeBloodyDemonDomain, redKey))
            end
            ui.createAutoBubble({parent = tabView:getTabBtnByTag(v.tag), refreshFunc = dealRedDotVisible,
                eventName = RedDotInfoObj:getEvents(ModuleSub.ePracticeBloodyDemonDomain, redKey)})
        end
    end

    -- 创建对话框
    local boxSize = cc.size(600, 650)
    self.showStarRewardLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = boxSize,
            title = TR("星级宝库"),
            btnInfos = {},
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {
                    clickAction = function ()
                        LayerManager.removeLayer(self.showStarRewardLayer)
                        self.boxBgSprite = nil
                        self.rewardBoxEffect = nil
                        self.rewardBoxList = nil
                        self.luckdrawOnceLabel = nil
                        self.luckdrawTenLabel = nil
                        self.luckdrawOnceBtn = nil
                        self.luckdrawTenBtn = nil
                        self.mLabel = nil
                    end
                }
            }
    })
end

--[[
    描述：刷新星级宝库弹窗
]]
function BddLayer:refreshChangeShop(tag)
    self.curSelBtnTag = tag
    -- 保底次数
    local maxTimes = self.mFloorData.Info.ChangeShopInfo[tostring(tag)]
    -- 抽奖数据
    local pageData = BddChangeShopRelation.items[tag]
    -- 必得装备颜色
    local colorData = BddChangeIntervalRelation.items[tag]
    -- 刷新箱子
    if self.rewardBoxEffect ~= nil then
        self.rewardBoxEffect:removeFromParent()
        self.rewardBoxEffect = nil
    end
    self.rewardBoxEffect = self:createBox(tag)
    -- 更新星数消耗
    self:refreshChangeShopStarNum(tag)
    -- 抽一次按钮重置函数
    self.luckdrawOnceBtn:setClickAction(function()
        self:requestLuckDraw(tag, 1)
    end)
    -- 抽十次按钮重置函数
    self.luckdrawTenBtn:setClickAction(function()
        self:requestLuckDraw(tag, 10)
    end)
    -- 移除列表项
    self.rewardBoxList:removeAllItems()
    -- 奖励列表
    local rewardListData = string.splitBySep(pageData.outShowAll, ",")
    -- 排序
    table.sort(rewardListData, function (item1, item2)
        -- 装备碎片数据
        local modelData1 = GoodsModel.items[tonumber(item1)]
        local modelData2 = GoodsModel.items[tonumber(item2)]
        -- 碎片合成后对应装备数据
        local equipModel1 = EquipModel.items[modelData1.outputModelID]
        local equipModel2 = EquipModel.items[modelData2.outputModelID]

        -- 品质
        if modelData1.quality ~= modelData2.quality then
            return modelData1.quality > modelData2.quality
        end

        -- 套装
        if (equipModel1.equipGroupID > 0) ~= (equipModel2.equipGroupID > 0) then
            return equipModel1.equipGroupID > 0
        end

        return modelData1.ID > modelData2.ID
    end)
    -- 一排n个
    local colNum = 2
    -- 循环次数
    local cycleCount = #rewardListData%colNum == 0 and #rewardListData/colNum or #rewardListData/colNum+1
    -- 一项cell大小
    local cellSize = cc.size(self.rewardBoxList:getContentSize().width, 120)
    -- 卡牌x坐标
    local PosX = {
        [1] = cellSize.width*0.25,
        [2] = cellSize.width*0.7,
    }
    for i = 0, cycleCount-1 do
        local cellItem = ccui.Layout:create()
        cellItem:setContentSize(cellSize)
        self.rewardBoxList:pushBackCustomItem(cellItem)
        for j = 1, colNum do
            local equipModelID = tonumber(rewardListData[i*colNum + j])
            if equipModelID then
                -- 创建卡
                local cardShowAttrs = {CardShowAttr.eBorder,CardShowAttr.eDebris}
                local card = CardNode.createCardNode({
                        modelId = equipModelID,
                        resourceTypeSub = ResourcetypeSub.eEquipmentDebris,
                        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eDebris}
                    })
                card:setPosition(PosX[j], cellSize.height*0.5+10)
                -- 创建卡名
                local name = Utility.getGoodsName(ResourcetypeSub.eEquipmentDebris, equipModelID)
                local colorLv = Utility.getColorLvByModelId(equipModelID, ResourcetypeSub.eEquipmentDebris)
                local color = Utility.getColorValue(colorLv, 1)
                local cardName = ui.newLabel({
                        text = name,
                        color = color,
                        size = 13,
                    })
                cardName:setAnchorPoint(cc.p(0.5, 0))
                cardName:setPosition(card:getContentSize().width*0.5, -15)
                card:addChild(cardName)
                -- 添加卡到行
                cellItem:addChild(card)
            end
        end
    end
end

-- 更新星级宝库星数消耗
function BddLayer:refreshChangeShopStarNum(tag)
    -- 抽奖数据
    local pageData = BddChangeShopRelation.items[tag]
    -- 抽一次消耗
    self.luckdrawOnceLabel:setString(TR("{%s}%d/%d", "c_75.png", self.mFloorData.Info.CanUserStarCount, pageData.oneChangesNum))
    -- 抽十次消耗
    self.luckdrawTenLabel:setString(TR("{%s}%d", "c_75.png", pageData.tenChangeNum))
    -- 必得装备颜色
    local colorData = BddChangeIntervalRelation.items[tag]
    -- 保底次数
    local maxTimes = self.mFloorData.Info.ChangeShopInfo[tostring(tag)]
end

-- 刷新当前层数据
function BddLayer:refreshCurFloorData()
    -- 当前挑战对象数据
    for k, v in ipairs(self.mFloorData.NodeInfo) do
        if v.IsCurrent then
            self.mCurFloorData = v
            return true
        end
    end

    return false
end

--刷新页面
--[[
    needAction:是否需要动作
--]]
function BddLayer:refreshLayer()
    -- 创建挑战人物
    self:createHero()
    -- 人物出现动画
    --if not self.mIsAction then
        self:showHeroAction()
        self.mIsAction = true
    --end

    -- 推荐战力显示
    self.mRecommendLabel.setFAP(BddNodeModel.items[self.mCurFloorData.NodeId].proposeFAP)
    -- 是否有限时商店
    -- self:showLimitStore()

    --刷新通关条件
    self:refreshClearance()
    self.mConditionList:forceDoLayout()
    local innerNode = self.mConditionList:getInnerContainer()
    local listSize = self.mConditionList:getContentSize()
    local innerSize = innerNode:getContentSize()
    local innerX, innerY = innerNode:getPosition()

    local listCount = 0
    local curItem = self.mConditionList:getItem(listCount)

    -- 刷新首通奖励
    local rewardList = Utility.analysisStrResList(BddNodeModel.items[self.mCurFloorData.NodeId].firstAllStarDrop)
    self.maxStarCard:setCardData(rewardList[1])

    -- 当前层数
    local curFloorNum = self.mCurFloorData.NodeId - 10
    self.mFloorLabel:setString(TR("第%d层", curFloorNum))

    -- 重置次数
    local playerVipLv = PlayerAttrObj:getPlayerAttrByName("Vip")
    local resetNum =  VipModel.items[playerVipLv].resetBDDNum - self.mFloorData.Info.ResetCount
    if resetNum <= 0 then
        resetNum = 0
    end
    self.resetNumLabel:setString(TR("今日重置次数:%d", resetNum))

    -- 是否为最高层
    -- self.isMaxFloor = curFloorNum >= BddNodeModel.items_count
    self.isMaxFloor = self.mFloorData.Info.CurNodeId == 0


    -- 按钮显示
    -- 满星且是顶层
    if self.isMaxFloor and self.mCurFloorData.StarCount >= BddClearanceModel.items_count then
        -- 显示重置按钮
        self.resetBtn:setVisible(true)
        self.resetBtn:setEnabled(true)
        -- 显示挑战按钮
        self.challengeBtn:setVisible(true)
        self.challengeBtn:setPosition(450, 140)
        -- 显示下一关按钮
        self.mNextFight:setVisible(false)
        -- 隐藏扫荡按钮
        self.sweepBtn:setVisible(false)
    -- 没有星
    elseif self.mCurFloorData.StarCount <= 0 then
        -- 如果在第一层且有完美通关的节点
        if self.mFloorData.Info.StarCount <= 0 and self.mFloorData.Info.MaxThreeNode ~= 0 then
            -- 隐藏重置按钮
            self.resetBtn:setVisible(false)
            -- 隐藏挑战按钮
            self.challengeBtn:setVisible(false)
            -- 隐藏下一关按钮
            self.mNextFight:setVisible(false)
            -- 显示扫荡按钮
            self.sweepBtn:setVisible(true)
        else
            -- 显示重置按钮
            self.resetBtn:setVisible(true)
            self.resetBtn:setEnabled(true)
            -- 显示挑战按钮
            self.challengeBtn:setVisible(true)
            self.challengeBtn:setPosition(450, 140)
            -- 显示下一关按钮
            self.mNextFight:setVisible(false)
            -- 隐藏扫荡按钮
            self.sweepBtn:setVisible(false)

            -- 在第一层禁用重置
            if self.mFloorData.Info.StarCount <= 0 then
                self.resetBtn:setEnabled(false)
            end
        end
    else
        -- 显示重置按钮
        self.resetBtn:setVisible(true)
        self.resetBtn:setEnabled(true)
        -- 显示挑战按钮
        self.challengeBtn:setVisible(true)
        self.challengeBtn:setPosition(300, 140)
        if self.mFloorData.Info.CurNodeId ~= BddNodeModel.items_count + 10 then
            -- 显示下一关按钮
            self.mNextFight:setVisible(true)
            self.mNextFight:setPosition(450, 140)
        else
            -- 隐藏下一关按钮
            self.mNextFight:setVisible(false)
            self.challengeBtn:setPosition(450, 140)
        end
        -- 隐藏扫荡按钮
        self.sweepBtn:setVisible(false)
    end

    self:refreshStarNum()
end

function BddLayer:refreshStarNum()
    --历史最高星数
    local text = TR("历史最高：%d {%s}", self.mFloorData.Info.MaxStarCount, "c_75.png")
    self.mMaxLabel:setString(text)
    self.historyMaxNum = self.mFloorData.Info.MaxStarCount

    --本次总共星数
    local text = TR("本次挑战：%d {%s}", self.mFloorData.Info.StarCount, "c_75.png")
    self.mChallengeLabel:setString(text)

    -- 抽奖星数
    local text = TR("抽奖星数：%d {%s}", self.mFloorData.Info.CanUserStarCount, "c_75.png")
    self.luckdrawLabel:setString(text)
end

function BddLayer:createHero()
    -- 人物数据
    local heroData = BddNodeModel.items[self.mCurFloorData.NodeId]

    if self.mHeroFigure then
        self.mHeroFigure:removeFromParent()
        self.mHeroFigure = nil
    end
    -- 人物形象
    self.mHeroFigure = Figure.newHero({
        parent = self.mParentLayer,
        heroModelID = tonumber(heroData.pic),
        anchorPoint = (cc.p(0.5, 0)),
        position = cc.p(320, 540),
        scale = 0.3,
        needRace = false,
    })
    self.mHeroFigure:setOpacity(0)

end
-- 显示英雄动画
function BddLayer:showHeroAction()
    -- 英雄出现特效
    ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_biwuzhaoqinrenwuchuxian",
        position = cc.p(320, 600),
        scale = 1,
        loop = false,
        endRelease = true,
    })
    self.mHeroFigure:runAction(cc.FadeIn:create(1.5))
    -- 出场音效
    MqAudio.playEffect("biwu.mp3")
end

--刷新通关条件
function BddLayer:refreshClearance()
    --移除之前所有元素
    self.mConditionList:removeAllItems()
    --分解当前关卡条件
    local strType = BddNodeModel.items[self.mCurFloorData.NodeId].starTypeStr
    local strInfo = string.splitBySep(strType, ",")
    --条件容器
    local typeInfo = {}
    for k, v in ipairs(strInfo) do
        v = string.splitBySep(v, "|")
        table.insert(typeInfo, v)
    end
    --胜利通关条件
    table.insert(typeInfo, 1, {1, 1})

    --分解服务器返回的关卡通关条件
    local starData = self.mCurFloorData.StarTypeStr
    starData = string.splitBySep(starData, ",")
    --条件
    local starInfo = {}
    for k, v in ipairs(starData) do
        v = string.splitBySep(v, "|")
        table.insert(starInfo, v)
    end

    --创建条件
    for k, v in ipairs(typeInfo) do
        --层
        local layout = ccui.Layout:create()
        self.mConditionList:pushBackCustomItem(layout)
        --描述
        --条件1特殊处理
        local text = ""
        if v[1] == 1 then
            text = BddClearanceModel.items[tonumber(v[1])].description
        elseif tonumber(v[1]) == 2 then
            text = string.format(BddClearanceModel.items[tonumber(v[1])].description, tostring(v[2].."%"))
        else
            text = string.format(BddClearanceModel.items[tonumber(v[1])].description, tostring(v[2]))
        end

        local desLabel = ui.newLabel({
            text = text,
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
            dimensions = cc.size(self.mListViewSize.width - 150, 40)
        })
        desLabel:setAnchorPoint(cc.p(0, 0.5))
        layout:setContentSize(self.mListViewSize.width - 10, desLabel:getContentSize().height - 10)
        desLabel:setPosition(50, layout:getContentSize().height - 15)
        layout:addChild(desLabel)

        --星星
        local starSprite = ui.newSprite("c_75.png")
        layout:addChild(starSprite)
        starSprite:setPosition(30, layout:getContentSize().height - 15)

        --星星是否需要置灰 表中的配置与服务器的返回进行比较
        local isGray = true
        for k1, v1 in ipairs(starInfo) do
            if v1[1] == v[1] and v1[2] == v[2] then
                isGray = false
                break
            end
        end
        if v[1] == 1 and self.mCurFloorData.StarCount >= 1 then
            isGray = false
        end
        starSprite:setGray(isGray)
        -- 文字颜色
        if isGray then
            desLabel:setColor(cc.c3b(0x5f, 0x5f, 0x5f))
        else
            desLabel:setColor(cc.c3b(0x46, 0x22, 0x0b))
        end
    end
end

-- 限时商店
function BddLayer:showLimitStore()
    -- 是否有限时商店
    local traderTime = PlayerAttrObj:getPlayerAttrByName("TraderTime")
    traderTime = PlayerAttrObj:getPlayerAttrByName("TraderTime") - Player:getCurrentTime()
    if traderTime > 0 then
        self:requestGetInfo()
    else
        self.mLimitStoreButton:setVisible(false)
        self.mLimitTimeLabel:setVisible(false)

        -- 当存在计划时
        if self.mLimitStoreAction ~= nil then
            self.mLimitTimeLabel:stopAction(self.mLimitStoreAction)
            self.mLimitStoreAction = nil
        end
    end
end

-----------------服务器相关----------------
--获取关卡数据
function BddLayer:requestInfo()
    HttpClient:request({
        moduleName = "BddInfo",
        methodName = "Info",
        svrMethodData = {},
        callback = function(response)
            if response.Status ~= 0 then
                LayerManager.removeLayer(self)
                return
            end

            -- 更新数据
            self.mFloorData = response.Value
            -- 更新当前层数据
            self:refreshCurFloorData()
            -- 刷新界面
            self:refreshLayer()

            -- 刷新界面后再启动引导
            self:executeGuide()
        end
    })
end

-- 抽奖
function BddLayer:requestLuckDraw(type, times)
    -- 判断是否达到抽奖要求
    local needStarNum = BddChangeShopRelation.items[type].highStarsNum
    local luckName = BddChangeShopRelation.items[type].name
    if self.mFloorData.Info.MaxStarCount < needStarNum then
        ui.showFlashView({text = TR("进行%s需要最高星数达到#d38212%d{c_75.png}",luckName, needStarNum)})
        return
    end

    HttpClient:request({
        moduleName = "BddInfo",
        methodName = "ShopChange",
        svrMethodData = {type, times},
        callback = function(response)
            if response.Status ~= 0 then return end
            -- dump(response.Value)
            -- 显示奖品
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 刷新
            self.mFloorData.Info = response.Value.Info
            self:refreshChangeShopStarNum(self.curSelBtnTag)
            self:refreshStarNum()
        end
    })
end

-- 一键登顶
function BddLayer:requestOneKeyMax()
    HttpClient:request({
        moduleName = "BddInfo",
        methodName = "OneKeyMax",
        svrMethodData = {},
        callback = function(response)
            if response.Status ~= 0 then return end
            -- 显示登顶box
            self:showOneKeyMaxBox(response.Value)
            -- 更新数据
            self.mFloorData.Info = response.Value.Info
            self.mFloorData.NodeInfo = response.Value.NodeInfo
            -- 更新当前层数据
            self:refreshCurFloorData()
            -- 刷新界面
            self:refreshLayer()
        end
    })
end

--进入下关
function BddLayer:requestGoNext()
    HttpClient:request({
        moduleName = "BddInfo",
        methodName = "GoNext",
        svrMethodData = {},
        callback = function(response)
            if response.Status ~= 0 then return end
            self.mFloorData.Info = response.Value.Info
            self.mFloorData.NodeInfo = response.Value.NodeInfo
            -- 更新当前层数据
            self:refreshCurFloorData()
            -- 刷新界面
            self:refreshLayer()
        end
    })
end

--重置
function BddLayer:requestReset()
    HttpClient:request({
        moduleName = "BddInfo",
        methodName = "Reset",
        svrMethodData = {},
        callback = function(response)
            if response.Status ~= 0 and response.Status ~= -5523  then
                return
            end
            if response.Status == -5523 then
                ui.showFlashView({text = TR("尚有星数奖励未领取")})
                self:showShopChangeBox()
                return
            end
            -- 更新数据
            self.mFloorData = response.Value
            -- 更新当前层数据
            self:refreshCurFloorData()
            -- 刷新界面
            self:refreshLayer()
        end
    })
end

--获取战斗数据
function BddLayer:requestGetFightInfo(nodeId)
    HttpClient:request({
        moduleName = "BddInfo",
        methodName = "GetFightInfo",
        svrMethodData = {nodeId},
        guideInfo = Guide.helper:tryGetGuideSaveInfo(115103),
        callback = function(response)
            if response.Status ~= 0 then return end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 115103 then
                Guide.manager:removeGuideLayer()
                Guide.manager:nextStep(eventID)
            end

            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.ePracticeBloodyDemonDomain, self.mCurFloorData.MaxStarCount >= BddClearanceModel.items_count)
            local battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = response.Value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    challengeStr = BddNodeModel.items[self.mCurFloorData.NodeId].starTypeStr,
                    map = Utility.getBattleBgFile(ModuleSub.ePracticeBloodyDemonDomain),
                    callback = function(retData)
                        --本地战斗完成,进行校验
                        CheckPve.bdd(retData, nodeId)
                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })

        end
    })
end


-- 获取限时商店信息
function BddLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TraderInfo",
        methodName = "GetInfo",
        callback = function(response)
            if response.Status ~= 0 then return end

            if not response.Value.IsOpen then
                return
            end

            -- 当存在计划时
            if self.mLimitStoreAction ~= nil then
                self.mLimitTimeLabel:stopAction(self.mLimitStoreAction)
                self.mLimitStoreAction = nil
            end

            -- 时间
            local endTime = response.Value.OpenDate
            self.mLimitStoreAction = Utility.schedule(self, function()
                local interval = endTime - Player:getCurrentTime()
                if interval > 0 then
                    -- 当免战时间还有剩余时
                    self.mLimitStoreButton:setVisible(true)
                    self.mLimitTimeLabel:setVisible(true)
                    self.mLimitTimeLabel:setString(MqTime.formatAsHour(interval))
                else
                    self.mLimitTimeLabel:setVisible(false)
                    self.mLimitStoreButton:setVisible(false)
                    self.mLimitTimeLabel:stopAction(self.mLimitStoreAction)
                    self.mLimitStoreAction = nil
                end
            end, 1)
        end,
    })
end

----[[---------------------新手引导---------------------]]--
-- 执行新手引导
function BddLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 115107 then
        -- 兑换商店弹出有动画
        Utility.performWithDelay(self.mParentLayer, function()
            Guide.helper:executeGuide({
                [115107] = {clickNode = self.showStarRewardLayer and self.showStarRewardLayer.mCloseBtn},
            })
        end, 0.25)
    else
        Guide.helper:executeGuide({
            -- 点击挑战按钮
            [115103] = {clickNode = self.challengeBtn},
            -- 指向兑换商店
            [115105] = {clickNode = self.shopBtn},
        })
    end
end

return BddLayer
