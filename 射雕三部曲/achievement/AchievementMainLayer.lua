--[[
    文件名：AchievementMainLayer.lua
	描述：成就主页面，管理成就页面
	创建人：yanxingrui
	创建时间：2016.6.7
-- ]]

local AchievementMainLayer = class("AchievementMainLayer", function(params)
    return display.newLayer()
end)

-- 累计登录的 targetID
local totalLoginTargetId = 3
-- 天数按钮状态改变事件名前缀
local AchieveEventNamePrefix = "AchievementLayerDayPrefix"
-- 某活动信息改变的事件名前缀
local TargetEventNamePrefix = "AchievementLayerTargetPrefix"
-- 显示成就类型改变的事件名
local ShowAchieveTypeChange = "AchievementLayerShowAchieveTypeChange"

-- 成就奖励页面数据，其中的配置数据在游戏运行期间只需要解析一次，服务器数据会在进入页面是重新请求
--[[
-- 整理后的数据结构为
    {
        [Enums.AchivementType.eActive] = { -- 活跃达人
            name = TR("活跃达人"),          -- 类型名
            pic = "",            -- 标识图片名
            bgImage = "",         -- 背景图片名
            titleImage = "",      -- 标题图片名
            text = TR("达成任务，我将给予你丰厚的奖励！"),   -- 描述
            targetIdList = {3, 1, 2, 17}, -- 该类型成就奖励包涵的 targetID，每个Id 为 SuccessTargetModel 配置文件的 targetID 字段
            targetInfo = {
                [targetID] = {
                    configItems = { -- 配置条目列表
                        {   -- SuccessTargetRewardRelation 配置表的一个条目
                            targetID = 3,
                            sequence = 1,
                            appearDay = 1,
                            completeCondition1 = 1,
                            completeCondition2 = 0,
                            resourceList = "1606,16060015,1||1606,16060014,1||1602,16020021,1"
                        },
                        ....
                    },

                    serverItem = { -- 对应的服务器数据
                        TargetId: 任务模型Id,
                        ReachedNum: 已达成数量,
                        ReachedMaxNum: 历史达成最大值,
                        Sequence: 玩家最大可领取奖项序号(特殊任务该字段的意义:所有满足条件的奖励项数量, 便于前端小红点计算),
                        DrawNums: 已领取奖励序号集合, 如: 1,3,5
                        SequenceInfo: 特殊奖励项明细信息
                        {
                            1:10,
                            2:10,
                            3:5,
                            ...
                        }
                    },
                }
            },
        }

        [Enums.AchivementType.ePractice] = {  -- 修炼达人
            -- todo
        },
        [Enums.AchivementType.eChallenge] = { -- 挑战达人
            -- todo
        },
        [Enums.AchivementType.eCulture] = { -- 培养达人
            -- todo
        },
        [Enums.AchivementType.eConsumption] = { -- 消费达人
            -- todo
        },
    }
]]
local AchievementPageData = {
    [Enums.AchivementType.eActive] = { -- 活跃达人
        name = TR("活跃达人"),          -- 类型名
        pic = "tb_130.png",            -- 标识图片名
        bgImage = "jc_23.jpg",         -- 背景图片名
        titleImage = "kfdj_06.png",      -- 标题图片名
        text = TR("达成任务，我将给予你#FFED4C丰厚的奖励#F7F4EE！"),   -- 描述
        targetIdList = {3, 1, 2}, -- 累计登录、推图高手、冲级达人、行侠仗义
        targetInfo = {},
    },

    [Enums.AchivementType.ePractice] = {  -- 修炼达人
        name = TR("修炼达人"),          -- 类型名
        pic = "tb_131.png",            -- 标识图片名
        bgImage = "jc_23.jpg",         -- 背景图片名
        titleImage = "kfdj_02.png",      -- 标题图片名
        text = TR("努力修炼，江湖武林将任你驰骋！"),   -- 描述
        targetIdList = { 9, 10, 13, 27}, -- 境界晋升、黑风神宫、巅峰之道、六道天伦
        targetInfo = {},
    },

    [Enums.AchivementType.eChallenge] = { -- 挑战达人
        name = TR("挑战达人"),          -- 类型名
        pic = "tb_132.png",            -- 标识图片名
        bgImage = "jc_23.jpg",         -- 背景图片名
        titleImage = "kfdj_04.png",      -- 标题图片名
        text = TR("与天斗,与地斗,与人斗,其乐无穷！"),   -- 描述
        targetIdList = {11, 14, 18, 17}, -- 寻宝奇兵、决斗高手、精英副本、神装试炼、血刃精英
        targetInfo = {},
    },

    [Enums.AchivementType.eCulture] = { -- 培养达人
        name = TR("培养达人"),          -- 类型名
        pic = "tb_133.png",            -- 标识图片名
        bgImage = "jc_23.jpg",         -- 背景图片名
        titleImage = "kfdj_05.png",      -- 标题图片名
        text = TR("要想马儿跑，就得给他吃草！"),   -- 描述
        targetIdList = {6, 16, 19, 43}, -- 突破高手、黑市刷新、装备进阶
        targetInfo = {},
    },

    [Enums.AchivementType.eConsumption] = { -- 消费达人
        name = TR("消费达人"),           -- 类型名
        pic = "tb_134.png",             -- 标识图片名
        bgImage = "jc_23.jpg",        -- 背景图片名
        titleImage = "kfdj_03.png",      -- 标题图片名
        text = TR("要想变强，可千万别当守财奴！"),   -- 描述
        targetIdList = {23, 24, 4, 25}, -- 耐力超强、体力无限、主宰招募、摇钱进宝
        targetInfo = {},
    },
}

function AchievementMainLayer:ctor()
    -- 成就奖励的服务器数据
    self.mAchievementInfo = {}
    -- 整理成就奖励配置数据
    self:initConfig()
    -- 当前显示成就奖励的类型
    self.mAchievementType = Enums.AchivementType.eActive  -- 活跃达人
    -- 当前显示列表类型
    self.mTargetId = AchievementPageData[self.mAchievementType].targetIdList[1] -- 第一个
    -- 初始化界面
    self:initUI()
    -- 获取玩家7人成就活动信息
    self:getInfoRequest()
end

-- 整理成就奖励配置数据
function AchievementMainLayer:initConfig()
    for achivementType, item in pairs(AchievementPageData) do
        if next(item.targetInfo) then  -- 如果该 targetInfo 不为空表，证明已经解析过配置文件数据（登录时配置表解析一次）
            break
        end

        for _, targetId in pairs(item.targetIdList) do
            item.targetInfo[targetId] = {}
            item.targetInfo[targetId].configItems = {}
            for _, sequenceItem in pairs(SuccessTargetRewardRelation.items[targetId] or {}) do
                for _, targetItem in pairs(sequenceItem) do
                    if targetItem.appearDay >= 8 then
                        table.insert(item.targetInfo[targetId].configItems, targetItem)
                    end
                end
            end
        end
    end
end

-- 初始化页面
function AchievementMainLayer:initUI()
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 初始显示成就页面
    local initItem = AchievementPageData[self.mAchievementType]
    -- 大背景
    local bgSprite = ui.newSprite(AchievementPageData[self.mAchievementType].bgImage)
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    -- 标题
    local plan = ui.newSprite(AchievementPageData[self.mAchievementType].titleImage)
    plan:setAnchorPoint(cc.p(0, 0.5))
    plan:setPosition(0, 890)
    bgSprite:addChild(plan)

    -- 描述的背景图片
    local decBgSize = cc.size(520, 60)
    local decBg = ui.newScale9Sprite("c_145.png", decBgSize)
    decBg:setAnchorPoint(cc.p(0,0.5))
    decBg:setPosition(cc.p(-10, 790))
    self.mParentLayer:addChild(decBg)

    -- -- 背景人物
    -- local mBgSprite2 = ui.newSprite("jc_18.png")
    -- mBgSprite2:setPosition(420, 500)
    -- self.mParentLayer:addChild(mBgSprite2)

    -- 显示描述信息的label
    --local tempSize = decsBgSptire:getContentSize()
    local descLabel = ui.newLabel({
        text = initItem.text,
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
    })
    descLabel:setAnchorPoint(cc.p(0, 0.5))
    descLabel:setPosition(30, 790)
    self.mParentLayer:addChild(descLabel)

    -- 显示奖励列表信息的背景图
     -- 下半部分背景图片大小
    local downBgSize = cc.size(640,700)
    local listBgSprite = ui.newScale9Sprite("c_19.png",downBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(listBgSprite)

    -- 奖励列表背景
    -- listView背景图大小
    local listViewBgSize = cc.size(downBgSize.width*0.95,downBgSize.height*0.796)
    -- listView背景图
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listViewBgSprite:setPosition(320, 105)
    listBgSprite:addChild(listViewBgSprite)

    -- 奖励列表控件
    self.mRewardListView = ccui.ListView:create()
    self.mRewardListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mRewardListView:setBounceEnabled(true)
    self.mRewardListView:setContentSize(cc.size(640, 540))
    self.mRewardListView:setItemsMargin(5)
    self.mRewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0))
    self.mRewardListView:setPosition(320, 114)
    self.mParentLayer:addChild(self.mRewardListView)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        --clickAudio = "",  -- 不需要按钮默认点击声音
        position = cc.p(594, 926),
        clickAction = function(pSender)
            cleanUp = true,
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 当前显示的成就奖励改变后控件显示处理函数
    local function onViewAchieveTypeChange()
        local tempData = AchievementPageData[self.mAchievementType]
        -- 设置背景图片
        bgSprite:setTexture(tempData.bgImage)
        -- 设置标题图片
        plan:setTexture(tempData.titleImage)
        -- 设置描述信息
        descLabel:setString(tempData.text)
    end
    Notification:registerAutoObserver(descLabel, onViewAchieveTypeChange, ShowAchieveTypeChange)

    -- 创建成就奖励类型的列表
    self:createTypeList()

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
end

-- 创建成就奖励类型的列表
function AchievementMainLayer:createTypeList()
    -- 成就类型列表的背景
    local bgSprite = ui.newScale9Sprite("c_69.png", cc.size(600, 145))
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    bgSprite:setPosition(320, 1086)
    self.mParentLayer:addChild(bgSprite)

    local listViewSize = cc.size(560, 120)
    -- 顶部活动按钮导航栏
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.horizontal)
    tempListView:setBounceEnabled(true)
    tempListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    tempListView:setItemsMargin(8)
    tempListView:setAnchorPoint(cc.p(0.5, 0.5))
    tempListView:setPosition(320, 1015)
    tempListView:setContentSize(listViewSize)
    self.mParentLayer:addChild(tempListView)

    local typeList = table.keys(AchievementPageData)
    table.sort(typeList, function(type1, type2)
        return type1 < type2
    end)
    local cellSize = cc.size(110, listViewSize.height)
    for _, achieveType in ipairs(typeList) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        tempListView:pushBackCustomItem(lvItem)

        -- 该类型成就奖励的数据
        local achieveItem = AchievementPageData[achieveType]

        -- 类型按钮
        local tempBtn = ui.newButton({
            normalImage = achieveItem.pic,
            -- text = achieveItem.name,
            -- fontSize = 22,
            -- textColor = cc.c3b(251, 234, 8),            -- #fbea08
            -- outlineColor = cc.c3b(128, 71, 21),         -- #804715
            -- outlineSize = 2,
            -- fixedSize = true,
            -- titlePosRateY = 0.2,
            clickAction = function()
                if self.mAchievementType == achieveType then
                    return
                end
                self.mAchievementType = achieveType

                self:createTabView()
                Notification:postNotification(ShowAchieveTypeChange)
            end
        })
        tempBtn:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempBtn)

        -- 选中标识图片
        local selectSprite = ui.newSprite("c_116.png")
        selectSprite:setPosition(cellSize.width / 2, cellSize.height / 2 + 10)
        lvItem:addChild(selectSprite, -1)
        selectSprite:setVisible(achieveType == self.mAchievementType)
        Notification:registerAutoObserver(selectSprite, function(sprite)
            sprite:setVisible(achieveType == self.mAchievementType)
        end, ShowAchieveTypeChange)

        -- 小红点逻辑
        local function dealRedDotVisible(redDotSprite)
            local haveRedDot = false
            for _, targetId in pairs(achieveItem.targetIdList) do
                haveRedDot = self:targetHaveRedDot(achieveType,targetId)
                if haveRedDot then
                    break
                end

            end
            redDotSprite:setVisible(haveRedDot)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = lvItem, 
            eventName = {AchieveEventNamePrefix, AchieveEventNamePrefix .. tostring(achieveType)}})
    end

    -- 左箭头
    local leftArrow = ui.newButton({
        normalImage = "c_26.png",
        clickAction = function()
        end
    })
    leftArrow:setPosition(20, 1030)
    leftArrow:setScaleX(-1)--setRotation(180)
    self.mParentLayer:addChild(leftArrow)

    -- 右箭头
    local rightArrow = ui.newButton({
        normalImage = "c_26.png",
        clickAction = function()
        end
    })
    rightArrow:setPosition(620, 1030)
    self.mParentLayer:addChild(rightArrow)
end

-- 创建某种成就奖励类型的切换按钮
function AchievementMainLayer:createTabView()
    if not tolua.isnull(self.mDaysAchieveTabView) then
        self.mParentLayer:removeChild(self.mDaysAchieveTabView)
        self.mDaysAchieveTabView = nil
    end
    -- 当前成就信息
    local achieveInfo = AchievementPageData[self.mAchievementType]

    -- 当前天数信息
    local tabBtnInfos = {}
    for _, targetId in ipairs(achieveInfo.targetIdList or {}) do
        --dump(targetId,"==============targetId===============")
        local targetModel = SuccessTargetModel.items[targetId]
        --dump(targetModel,"========targetModel============")
        if targetModel.isUse then
            table.insert(tabBtnInfos, {
                text = targetModel.name,
                tag = targetId
            })
        end
    end
    -- 如果没有条目则不需要创建
    if not next(tabBtnInfos) then
        return
    end

    -- 当前显示子页面类型
    self.mTargetId = achieveInfo.targetIdList[1]
    -- 创建切换子页面的控件
    self.mDaysAchieveTabView = require("common.TabView"):create({
        btnInfos = tabBtnInfos,
        defaultSelectTag = self.mTargetId,
        onSelectChange = function(selBtnTag)
            if self.mTargetId == selBtnTag then
                return
            end
            self.mTargetId = selBtnTag
            -- 刷新奖励信息的列表
            self:refreshListView()
        end
    })
    self.mDaysAchieveTabView:setAnchorPoint(cc.p(0.5, 0))
    self.mDaysAchieveTabView:setPosition(320, 680)
    self.mParentLayer:addChild(self.mDaysAchieveTabView)

    -- 刷新奖励信息的列表
    self:refreshListView()

    -- 小红点逻辑
    for targetId, btnObj in pairs(self.mDaysAchieveTabView:getTabBtns() or {}) do
        local function dealRedDotVisible(redDotSprite)
            local haveRedDot = self:targetHaveRedDot(self.mAchievementType, targetId)
            redDotSprite:setVisible(haveRedDot)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = btnObj, 
            eventName = {TargetEventNamePrefix .. tostring(targetId)}})
    end
end

-- 刷新奖励信息的列表
function AchievementMainLayer:refreshListView()
    self.mRewardListView:removeAllItems()

    -- 列表当前需要显示的数据
    local viewData = AchievementPageData[self.mAchievementType].targetInfo[self.mTargetId]
    if not viewData then
        return
    end

    -- 排序列表数据
    self:sortTargetData(viewData)

    -- 需要显示类型服务器数据
    local serverData = viewData.serverItem
    --
    local cellSize = cc.size(640, 130)
    for index, item in ipairs(viewData.configItems or {}) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mRewardListView:pushBackCustomItem(lvItem)

        --
        local targetModel = SuccessTargetModel.items[item.targetID]
        -- 达成数量
        local reachedNum = serverData.SequenceInfo[tostring(item.sequence)] or serverData.ReachedNum or 0
        -- 达成需要的数量
        local completeCondition = item.completeCondition1

        -- 创建背景
        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(590, 130))
        --bgSprite:setAnchorPoint(0.5, 1)
        bgSprite:setPosition(320, cellSize.height / 2)
        lvItem:addChild(bgSprite)

        -- 创建领取按钮或已领取标识
        if table.indexof(serverData.DrawNums or {}, tostring(item.sequence)) then
            local tempSprite = ui.newSprite("jc_21.png")
            tempSprite:setPosition(cellSize.width - 90, cellSize.height / 2)
            lvItem:addChild(tempSprite)
        else
            local tempBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取"),
                clickAction = function()
                    -- 判断是否可以领取
                    if reachedNum < completeCondition then
                        return
                    end

                    self:drawRewardRequest(item.sequence)
                end
            })
            tempBtn:setPosition(cellSize.width - 100, cellSize.height / 2)
            lvItem:addChild(tempBtn)
            tempBtn:setEnabled(reachedNum >= completeCondition)
        end

        -- -- 创建显示达成条件信息
        -- local textString = string.format(targetModel.reachedIntroFormat, item.completeCondition1, item.completeCondition2)
        -- local rateString = string.format("%s%s%s/%s",
        --     "#39FF6D",
        --     Utility.numberWithUnit(reachedNum),
        --     Enums.Color.eWhiteH,
        --     Utility.numberWithUnit(completeCondition))
        -- local tempLabel = ui.newLabel({
        --     text = string.format("%s\n%s", textString, TR("完成进度")),
        --     size = 22,
        --     anchorPoint = cc.p(0, 0),
        --     x = cellSize.width * 0.045,
        --     y = cellSize.height * 0.4,
        -- })
        -- lvItem:addChild(tempLabel)

        -- local tempLabel2 = ui.newLabel({
        --     text = rateString,
        --     size = 22,
        --     anchorPoint = cc.p(0, 0),
        --     x = cellSize.width * 0.070,
        --     y = cellSize.height * 0.4 - 25,
        -- })
        -- lvItem:addChild(tempLabel2)
        local textString = string.format(targetModel.reachedIntroFormat, item.completeCondition1, item.completeCondition2)

        if item.targetID == 1 then--推图高手模块特殊处理，显示第几篇第几章
            -- local tempStr = ConfigFunc:getFormatNodeInfo({chapterId = item.completeCondition1 + 10})
            textString = string.format(targetModel.reachedIntroFormat, item.completeCondition1, item.completeCondition2)
        end

        local rateString = string.format("%s%s%s/%s",
            reachedNum < completeCondition and Enums.Color.eRedH or "#249029",
            Utility.numberWithUnit(reachedNum),
            "#592817",
            Utility.numberWithUnit(completeCondition))
        local text1 = ui.newLabel({
                text = textString,
                size = 22,
                color = cc.c3b(0x59, 0x28, 0x17),
                dimensions = cc.size(150,0),
                x = 25,
                y = cellSize.height * 0.5 + 20,
            })
        text1:setAnchorPoint(cc.p(0, 0.5))
        bgSprite:addChild(text1)
        local text2 = ui.newLabel({
                text = TR("进度".."%s", rateString),
                size = 22,
                color = cc.c3b(0x59, 0x28, 0x17),
                x = 25,
                y = cellSize.height * 0.5 - 30,
            })
        text2:setAnchorPoint(cc.p(0, 0.5))
        bgSprite:addChild(text2)
        -- local text3 = ui.newLabel({
        --         text = rateString,
        --         size = 22,
        --         x = cellSize.width * 0.21,
        --         y = cellSize.height * 0.5 - 30,
        --     })
        -- lvItem:addChild(text3)

        -- 创建物品列表
        local tempList = Utility.analysisStrResList(item.resourceList)
        for _, rewardItem in pairs(tempList) do
            rewardItem.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        end
        local cardList = ui.createCardList({
            cardDataList = tempList,
            maxViewWidth = 265,
            allowClick = true,
        })
        cardList:setAnchorPoint(cc.p(0, 0.5))
        cardList:setPosition(170, cellSize.height * 0.4)
        bgSprite:addChild(cardList)

        local card = cardList:getCardNodeList()
        for index = 1, #card do
            card[index]:setSwallowTouches(false)
        end
    end
end

-- 排序某奖励类型列表的数据
--[[
-- 参数
    targetData: 其中的字段为 SevenPageData 中一个 targetID 中的内容
    {
        configItems = {}, -- 配置条目列表
        serverItem = {}, -- 对应的服务器数据
    }
]]
function AchievementMainLayer:sortTargetData(targetData)
    targetData = targetData or {}
    -- 该类型服务器数据
    local serverData = targetData.serverItem or {}
    -- 排序列表数据
        -- 能否领取
    local function isGetReward(item)
        -- 达成数量
        local reachedNum = serverData.SequenceInfo[tostring(item.sequence)] or serverData.ReachedNum or 0
        -- 达成需要的数量
        local completeCondition = item.completeCondition1

        return reachedNum >= completeCondition
    end
    -- 是否已领取
    local function isReceived(item)

        if table.indexof(serverData.DrawNums or {}, tostring(item.sequence)) then
            return true
        end
        return false
    end
    -- 对显示的列表数据关于能否领取排序
    table.sort(targetData.configItems or {}, function(item1, item2)
        -- 是否已领取
        if isReceived(item1) ~= isReceived(item2) then
            return not isReceived(item1)
        end
        -- 能否领取
        if isGetReward(item1) ~= isGetReward(item2) then
            return isGetReward(item1)
        end
        -- 比较达成条件1
        if item1.completeCondition1 ~= item2.completeCondition1 then
            return item1.completeCondition1 < item2.completeCondition1
        end
        -- 比较条件2
        if item1.completeCondition2 ~= item2.completeCondition2 then
            return item1.completeCondition2 < item2.completeCondition2
        end
        -- 比较 targetId
        if item1.targetID ~= item2.targetID then
            return item1.targetID < item2.targetID
        end
        -- 比较序号
        if item1.sequence ~= item2.sequence then
            return item1.sequence < item2.sequence
        end

        return false
    end)
end

-- 计算某种奖项是否有小红点
function AchievementMainLayer:targetHaveRedDot(achieveType, targetId)
    local tempData = AchievementPageData[achieveType].targetInfo[targetId]
    if not tempData or not tempData.serverItem then
        return false
    end

    local sequence = tempData.serverItem.Sequence or 0
    local drawCount = tempData.serverItem.DrawNums and #tempData.serverItem.DrawNums or 0
    return sequence > drawCount
end

-- =========================== 网络请求相关接口 ======================
-- 获取玩家成就完成信息的数据请求
function AchievementMainLayer:getInfoRequest()
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 重新整理服务器返回的数据主要是为方便访问 TargetList 的条目
            self.mAchievementInfo = {}
            for key, value in pairs(response.Value or {}) do
                if key == "DrawDay" then
                    self.mAchievementInfo[key] = {}
                    for _, item in pairs(value) do
                        self.mAchievementInfo[key][item.Day] = item
                    end
                elseif key == "TargetList" then
                    self.mAchievementInfo[key] = {}
                    for index, item in pairs(value) do
                        item.DrawNums = string.splitBySep(item.DrawNums or "", ",")
                        self.mAchievementInfo[key][item.TargetId] = item
                    end
                else
                    self.mAchievementInfo[key] = value
                end
            end

            -- 把服务器返回的数据整理到 AchievementPageData 表的 serverItem 中
            for achivementType, item in pairs(AchievementPageData) do
                for _, targetId in pairs(item.targetIdList) do
                    item.targetInfo[targetId] = item.targetInfo[targetId] or {}
                    item.targetInfo[targetId].serverItem = self.mAchievementInfo.TargetList[targetId] or {}
                    item.targetInfo[targetId].serverItem.SequenceInfo = item.targetInfo[targetId].serverItem.SequenceInfo or {}

                    Notification:postNotification(TargetEventNamePrefix .. tostring(targetId))
                end

                Notification:postNotification(AchieveEventNamePrefix)
            end

            -- 创建某种成就奖励类型的切换按钮
            self:createTabView()
        end
    })
end

-- 领取成就奖励奖项的数据请求
--[[
-- 参数
    sequence: 任务序号
]]
function AchievementMainLayer:drawRewardRequest(sequence)
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "DrawReward",
        svrMethodData = {self.mTargetId, sequence},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 显示领取到的奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 把已领取的序号修改到本地缓存的服务端数据中
            local serverItem = self.mAchievementInfo.TargetList[self.mTargetId] or {}
            serverItem.DrawNums = serverItem.DrawNums or {}
            table.insert(serverItem.DrawNums, tostring(sequence))

            -- 刷新奖励信息的列表
            self:refreshListView()

            -- 通知当天按钮状态刷新
            Notification:postNotification(AchieveEventNamePrefix .. tostring(self.mAchievementType))
            -- 通知奖项按钮状态刷新
            Notification:postNotification(TargetEventNamePrefix .. tostring(self.mTargetId))
        end
    })
end

return AchievementMainLayer
