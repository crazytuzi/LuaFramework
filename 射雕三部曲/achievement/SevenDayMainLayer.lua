
--[[
    文件名：SevenDayMainLayer.lua
	描述：七日活动主页面
	创建人：yanxingrui
	创建时间：2016.6.12
-- ]]

local SevenDayMainLayer = class("SevenDayMainLayer", function(params)
    return display.newLayer()
end)

-- 开服大奖页面数据，其中的配置数据在游戏运行期间只需要解析一次，服务器数据会在进入页面是重新请求
--[[
-- 整理后的数据结构为
    {
        -- 第一天的开发大奖信息
        [1] = {
            -- SuccessTargetModel 配置文件的 targetID 字段
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
        }
        -- 第二天的开发大奖信息
        [2] = {
            -- todo
        },

        ....
    }
]]
local SevenPageData = {}
-- 需要合并显示targetID
--[[
-- 整理后的数据格式为
    {
        [TargetId] = {TargetId1, TargetId2, ...},
        ...
    }
]]
local MergeTargetInfo = {}

-- 开服大奖的天数
local openRewardCount = 7
-- 累计登录的 targetID
local totalLoginTargetId = 3
-- 天数按钮状态改变事件名前缀
local DayEventNamePrefix = "SevenDayLayerDayPrefix"
-- 某活动信息改变的事件名前缀
local TargetEventNamePrefix = "SevenDayLayerTargetPrefix"
-- 兑换数据改变的事件名
local ExchangeDataChange = "SevenDayLayerExchangeDataChange"

function SevenDayMainLayer:ctor()
    -- 开服大奖的服务器数据
    self.mSevenInfo = {}
    -- 兑换信息
    self.mExchangeInfo = {}
    -- 当前选择天
    self.curDay = 0
    -- 模型相同的targetID
    self.sameModel = {}
    -- 整理开服大奖配置数据
    self:initConfig()
    -- 初始化界面
    self:initUI()
    -- 获取玩家7人成就活动信息
    self:getInfoRequest()
end

-- 整理开服大奖配置数据
function SevenDayMainLayer:initConfig()
    if next(SevenPageData) then -- 已经解析过了（登录时配置表解析一次）
        return
    end

    -- 解析需要合并显示targetID
    MergeTargetInfo = {}
    for targetID, item in pairs(SuccessTargetModel.items) do
        MergeTargetInfo[targetID] = {}
        for _, item2 in pairs(SuccessTargetModel.items) do
            if item.modelID == item2.modelID then
                table.insert(MergeTargetInfo[targetID], item2.targetID)
            end
        end
    end

    for targetID, item in pairs(SuccessTargetRewardRelation.items) do
        for sequenceIndex, sequenceItem in pairs(item) do
            for _, targetItem in pairs(sequenceItem) do
                if targetItem.appearDay <= openRewardCount then
                    if targetID == totalLoginTargetId then
                        for dayIndex = 1, openRewardCount do
                            SevenPageData[dayIndex] = SevenPageData[dayIndex] or {}
                            SevenPageData[dayIndex][targetID] = SevenPageData[dayIndex][targetID] or {}
                            SevenPageData[dayIndex][targetID].configItems = SevenPageData[dayIndex][targetID].configItems or {}
                            --将 七日登录数据加入到 配置条目列表 中
                            table.insert(SevenPageData[dayIndex][targetID].configItems, targetItem)
                        end
                    else    --将第几日出现的配置条目数据加入到对应数据结构中
                        SevenPageData[targetItem.appearDay] = SevenPageData[targetItem.appearDay] or {}
                        SevenPageData[targetItem.appearDay][targetID] = SevenPageData[targetItem.appearDay][targetID] or {}
                        SevenPageData[targetItem.appearDay][targetID].configItems = SevenPageData[targetItem.appearDay][targetID].configItems or {}

                        table.insert(SevenPageData[targetItem.appearDay][targetID].configItems, targetItem)
                    end
                end
            end
        end
    end
end

-- 初始化界面
function SevenDayMainLayer:initUI()
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mChildLayer = ui.newStdLayer()
    self:addChild(self.mChildLayer)

    --大背景
    local topBgSprite1 = ui.newSprite("c_34.jpg")
    topBgSprite1:setPosition(320, 568)
    self.mParentLayer:addChild(topBgSprite1)

    -- 标志图片
    local markSprite = ui.newSprite("kfdj_07.png")
    markSprite:setAnchorPoint(1, 0.5)
    markSprite:setPosition(640, 940)
    topBgSprite1:addChild(markSprite)

    -- 添加英雄半身像
    local heroSprite = ui.newSprite("kfdj_10.png")
    heroSprite:setAnchorPoint(0, 1)
    heroSprite:setPosition(0, 1000)
    topBgSprite1:addChild(heroSprite)

    -- 下半部分背景
    local downBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 575))
    downBgSprite:setPosition(320, 0)
    downBgSprite:setAnchorPoint(0.5, 0)
    self.mParentLayer:addChild(downBgSprite)

    -- 放置显示天数按钮的背景图
    local dayBtnBg = ui.newScale9Sprite("c_17.png", cc.size(370, 240))
    dayBtnBg:setAnchorPoint(cc.p(1, 1))
    dayBtnBg:setPosition(620, 870)
    self.mParentLayer:addChild(dayBtnBg)

    -- 创建第一天——第七天的按钮和进度信息
    self:createDaysInfo()
    -- 创建当前任务完成进度信息
    self:createFinishProgress()
    -- 创建兑换相关信息控件
    self:createExchangeView()
    -- 创建显示某一天的信息的列表控件
    self:createListview()

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

    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 创建第一天——第七天的按钮和进度信息
function SevenDayMainLayer:createDaysInfo()
    -- 按钮选中标识图片""
    local curSelectSprite = ui.newScale9Sprite("c_31.png", cc.size(125, 51))
    curSelectSprite:setVisible(false)
    self.mParentLayer:addChild(curSelectSprite, 1)

    -- --区域背景
    -- local upSprite = ui.newScale9Sprite("jchd_11.png",cc.size(404,294))
    -- upSprite:setPosition(215, 820)
    -- self.mParentLayer:addChild(upSprite)

    -- --分割线
    -- local upLine = ui.newScale9Sprite("kfdj_6.png",cc.size(382,4))
    -- upLine:setPosition(202, 87)
    -- upSprite:addChild(upLine)

    -- 创建1——7天的按钮
    local startPosX, startPosY = 312, 838
    local spaceX, spaceY = 121, 50
    for index = 1, openRewardCount do
        local isLastBtn = index == openRewardCount
        local tempPosX = isLastBtn and 417 or (startPosX + math.mod(index - 1, 3) * spaceX)
        local tempPosY = isLastBtn and 737 or (startPosY - math.floor((index - 1) / 3) * spaceY)

        local btnImg = index < (self.mSevenInfo.Day or 1) and not self.mSevenInfo.DrawDay[index] and "c_82.png" or "c_33.png"
        local btnInfo = {
            normalImage = isLastBtn and "kfdj_01.png" or btnImg,
            position = cc.p(tempPosX, tempPosY),
            text = isLastBtn and TR("%s第7日 集碎片,得传说", Enums.Color.eWhiteH) or TR("第%d天", index),
            fontSize = 24,
            outlineColor = cc.c3b(0x0c, 0x2e, 0x47),
            clickAction = function()
                -- 当天
                local currDay = self.mSevenInfo.Day
                -- 之前的天数
                if index <= currDay then
                    -- 刷新该天任务
                    self.curDay = index
                    self:refreshUI(index)
                    -- 该天是否有奖励未领取
                    if self.mSevenInfo.DrawDay[index] then
                        self:drawTotalRewardView(index)
                    end
                    -- 选中框
                    curSelectSprite:setVisible(true)
                    curSelectSprite:setPosition(tempPosX, tempPosY)
                    if isLastBtn then
                        curSelectSprite:setContentSize(cc.size(300, 51))
                    else
                        curSelectSprite:setContentSize(cc.size(125, 51))
                    end
                -- 之后的天数
                else
                    self:completeRewardPreview(index)
                end
            end,
        }
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setScale(0.85)
        self.mParentLayer:addChild(tempBtn)
        tempBtn.index = index
        local btnSize = tempBtn:getContentSize()

        local selectSprite = ui.newScale9Sprite("c_59.png")
        selectSprite:setVisible(false)
        tempBtn:getExtendNode2():addChild(selectSprite)

        --七日宝箱
        --[[
        if index == openRewardCount then
            -- 当是第七天奖励的时候  将按钮上的字体右移30像素
            tempBtn.mTitleLabel:setPosition(cc.p(30, 0))
            local baoButton = ui.newButton({
                normalImage = "kfdj_12.png",
                --scale = 0.7,
                position = cc.p(btnSize.width * 0.13, btnSize.height * 0.5),
                clickAction = function()
                    -- TODO
                    MsgBoxLayer.addGoodsInfoLayer(16060407)--16060407)
                end
                })
            tempBtn:addChild(baoButton)
            --tempBtn:setPressedActionEnabled(false)  --关闭点击动画
        end--]]

        -- 按钮上的小红点
        local redDotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.85, btnSize.height * 0.8)})
        tempBtn:addChild(redDotSprite)
        redDotSprite:setVisible(false)

        -- 改变按钮的状态
        local function dealDayBtnStatus(btnObj)
            local dayIndex = btnObj.index or 1
            local currDay = self.mSevenInfo.Day or 1
            -- 设置选中框
            if dayIndex == currDay then
                selectSprite:setVisible(true)
                -- selectSprite:setPosition(btnObj:getPosition())
                selectSprite:setPosition(0, 0)
                selectSprite:setContentSize(cc.size(btnSize.width + 6, btnSize.height + 6))
            end

            -- 设置按钮上小红点是否显示
            if dayIndex <= currDay then
                local haveReward = self.mSevenInfo.DrawDay[dayIndex] ~= nil

                local haveRedDot = self:dayHaveRedDot(dayIndex)

                redDotSprite:setVisible(haveRedDot or haveReward)
            else
                redDotSprite:setVisible(false)
            end

            -- 设置按钮的图片显示
            local tempImg = "kfdj_01.png"         --第7天按钮背景图片
            if dayIndex < openRewardCount then
                if dayIndex < currDay then
                    tempImg = "c_33.png"       --已领取背景图片
                else
                    tempImg = "c_82.png"       --1至6天按钮背景图片
                end
            end
            btnObj:loadTextures(tempImg, tempImg)
        end

        -- 注册通知按钮状态改变的事件
        Notification:registerAutoObserver(tempBtn, dealDayBtnStatus, {DayEventNamePrefix .. tostring(index), DayEventNamePrefix})
    end
end

-- 创建当前任务完成进度信息
function SevenDayMainLayer:createFinishProgress()
    local parentSize = cc.size(415, 100)
    -- 管理该部分控件的parent
    if not self.mFinishNode then
        self.mFinishNode = cc.Node:create()
        self.mFinishNode:setIgnoreAnchorPointForPosition(false) --忽略锚点
        self.mFinishNode:setContentSize(parentSize)
        self.mFinishNode:setPosition(10, 629)
        self.mParentLayer:addChild(self.mFinishNode)
    end

    -- 熟悉进度信息显示函数
    local function refreshFinishView()
        self.mFinishNode:removeAllChildren()
        if not next(self.mSevenInfo) then
            return
        end

        local currDay = self.curDay == 0 and self.mSevenInfo.Day or self.curDay
        if currDay > 7 then
            return
        end
        -- 解析数据，确定需要创建的控件
        local needDrawBtn = false -- 是否需要领取奖励的按钮
        local needProg = false -- 是否需要进度控件
        local hintStrList = {} -- 提示信息字符串列表
        if self.mSevenInfo.TargetCount[tostring(currDay)] == nil then return end
        if self.mSevenInfo.TargetCount[tostring(currDay)].FinishTargetCount == self.mSevenInfo.TargetCount[tostring(currDay)].TotalTargetCount then
            if self.mSevenInfo.DrawDay[currDay] then
                needDrawBtn = true
                -- table.insert(hintStrList, TR("%s今日任务全部完成", Enums.Color.eYellowH))
                -- local rewardList = Utility.analysisStrResList(self.mSevenInfo.DrawDay[currDay].RewardInfo)
                -- local tempStr = TR("{kfdj_14.png}%s{%s}%d", Enums.Color.eYellowH, Utility.getResTypeSubImage(ResourcetypeSub.eDiamond),rewardList[1].num)
                -- table.insert(hintStrList, tempStr)
            else
                needProg = true
                table.insert(hintStrList, TR("当前进度:"))
                
                local rewardGold = Utility.analysisStrResList(SuccessTimeModel.items[currDay].resourceList)[1]
                table.insert(hintStrList, TR("{kfdj_15.png}{db_1111.png}%s%s/%s", Enums.Color.eGoldH, rewardGold.num, rewardGold.num))
            end
        else
            needProg = true

            table.insert(hintStrList, TR("当前进度:"))
            local rewardGold = Utility.analysisStrResList(SuccessTimeModel.items[currDay].resourceList)[1]
            local tempStr = TR("{kfdj_13.png} {db_1111.png}%s%s/%s",
                Enums.Color.eGoldH,
                math.floor(rewardGold.num * (self.mSevenInfo.TargetCount[tostring(currDay)].FinishTargetCount / self.mSevenInfo.TargetCount[tostring(currDay)].TotalTargetCount)),
                rewardGold.num
            )
            table.insert(hintStrList, tempStr)
        end

        -- 创建提示信息
        local startPosX, spaceY = 248, 38
        local startPosY = (parentSize.height + #hintStrList * spaceY - spaceY) / 2
        for index, str in ipairs(hintStrList) do
            local tempLabel = ui.newLabel({
                text = str,
                anchorPoint = cc.p(0, 0.5),
                size = 20,
                outlineColor = Enums.Color.eBlack,
            })
            tempLabel:setPosition(startPosX, startPosY - (index - 1) * spaceY - 5)
            self.mFinishNode:addChild(tempLabel)
        end

        -- 创建领取奖励按钮
        if needDrawBtn then
            local drawBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取"),
                position = cc.p(parentSize.width + 130, parentSize.height * 0.49),
                clickAction = function()
                    self:drawTotalRewardView(currDay)
                end
            })
            self.mFinishNode:addChild(drawBtn)

            -- 创建可领取图
            local hintGetSprite = ui.newSprite("kfdj_14.png")
            hintGetSprite:setAnchorPoint(cc.p(0, 0.5))
            hintGetSprite:setPosition(248, startPosY+20)
            self.mFinishNode:addChild(hintGetSprite)
            -- 创建元宝图
            local diamondSprite = ui.newSprite(Utility.getResTypeSubImage(ResourcetypeSub.eDiamond))
            diamondSprite:setAnchorPoint(cc.p(0.5, 0.5))
            diamondSprite:setScale(1.2)
            diamondSprite:setPosition(248+hintGetSprite:getContentSize().width+diamondSprite:getContentSize().width*0.5, startPosY+20)
            self.mFinishNode:addChild(diamondSprite)
            -- 创建数量
            local rewardList = Utility.analysisStrResList(self.mSevenInfo.DrawDay[currDay].RewardInfo)
            local numLabel = ui.newLabel({
                    text = rewardList[1].num,
                    anchorPoint = cc.p(0, 0.5),
                    color = Enums.Color.eYellow,
                    size = 20,
                    outlineColor = Enums.Color.eBlack,
                })
            numLabel:setPosition(248+hintGetSprite:getContentSize().width+diamondSprite:getContentSize().width, startPosY+20)
            self.mFinishNode:addChild(numLabel)

            -- 创建光圈提示特效
            ui.newEffect({
                parent = diamondSprite,
                effectName = "effect_ui_xinshouyindao",
                animation  = "dianji",
                position = cc.p(diamondSprite:getContentSize().width*0.5, diamondSprite:getContentSize().height*0.5),
                loop = true,
            })
            -- 元宝摇动
            ui.setWaveAnimation(diamondSprite, 20, false)
        end

        if needProg then
            local tempBar = require("common.ProgressBar"):create({
                bgImage = "kfdj_09.png",
                barImage = "kfdj_08.png",
                currValue = self.mSevenInfo.TargetCount[tostring(currDay)].FinishTargetCount,
                maxValue = self.mSevenInfo.TargetCount[tostring(currDay)].TotalTargetCount,
                needLabel = true,
                percentView = false,
                size = 20,
                color = Enums.Color.eBrown
            })
            tempBar:setPosition(parentSize.width * 1.13, parentSize.height * 0.65)
            self.mFinishNode:addChild(tempBar)
        end
    end

    self.mFinishNode.refreshView = refreshFinishView

    refreshFinishView()
end

-- 创建兑换相关信息控件
function SevenDayMainLayer:createExchangeView()
    -- --兑换按钮背景
    -- local exchangeBgSprite = ui.newScale9Sprite("jchd_11.png",cc.size(210,142))
    -- exchangeBgSprite:setPosition(525, 750)
    -- self.mParentLayer:addChild(exchangeBgSprite)

    --兑换按钮
    local exchangeBtn = ui.newButton({
        normalImage = "tb_87.png",
        clickAction = function()
            if self.mSevenInfo.Day > 7 then
                ui.showFlashView({text = TR("活动已结束")})
                return
            end
            self:createExchangeLayer()
        end
    })
    exchangeBtn:setPosition(80, 680)
    self.mParentLayer:addChild(exchangeBtn)

    -- --兑换文字描述
    -- local exchangeLabel = ui.newLabel({
    --     text = TR("每日兑换  超值兑换"),
    --     size = 20,
    --     color = cc.c3b(0xFF, 0xDE, 0x86),
    --     outlineColor = cc.c3b(0x5E, 0x1E, 0x11),
    -- })
    -- exchangeLabel:setPosition(104, 22)
    -- exchangeBgSprite:addChild(exchangeLabel)

    local function dealRedDotVisible(redDotSprite)
        local redDotData = false  -- 获取是否需要小红点的逻辑
        if self.mSevenInfo.Day and self.mSevenInfo.Day <= 7 then
            local currDay = self.curDay == 0 and self.mSevenInfo.Day or self.curDay
            for _, item in pairs(self.mExchangeInfo[currDay] or {}) do
                local sequence = item.Sequence
                local tempConfig = SuccessPurchaseModel.items[currDay] and SuccessPurchaseModel.items[currDay][sequence]
                if tempConfig and item.GlobalNum < tempConfig.serverMax and
                    item.PersonalNum < tempConfig.singleMax and
                    item.NeedVipLv <= PlayerAttrObj:getPlayerAttrByName("Vip") and
                    item.NeedLv <= PlayerAttrObj:getPlayerAttrByName("Lv") then
                    redDotData = true
                    break
                end
            end
        end
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = exchangeBtn,
        eventName = {ExchangeDataChange}})
end

-- 创建某一天奖励类型的切换按钮
function SevenDayMainLayer:createDaysTabView()
    if self.mDaysTabView ~= nil then
        self.mDaysTabView:removeFromParent()
        self.mDaysTabView = nil
    end
    if not tolua.isnull(self.mDaysTabView) then
        self.mParentLayer:removeChild(self.mDaysTabView)
        self.mDaysTabView = nil
    end

    -- 当前天数信息
    local tempList = {}
    local tabBtnInfos = {}
    self.sameModel = {}
    for targetID, item in pairs(SevenPageData[self.curDay == 0 and self.mSevenInfo.Day or self.curDay] or {}) do
        local targetModel = SuccessTargetModel.items[targetID]
        if not tempList[targetModel.modelID] then -- 已有同一组的条目在 tabBtnInfos 中了，同一组的只需要显示一个
            tempList[targetModel.modelID] = true
            table.insert(tabBtnInfos, {
                text = targetModel.name,
                tag = targetID
            })
        else
            self.sameModel[targetModel.modelID] = self.sameModel[targetModel.modelID] or {}
            table.insert(self.sameModel[targetModel.modelID], targetID)
        end
    end
    -- 如果没有条目则不需要创建
    if not next(tabBtnInfos) then
        return
    end
    -- 排序切换按钮的顺序
    table.sort(tabBtnInfos, function(item1, item2)
        return item1.tag < item2.tag
    end)


    for key,value in ipairs(tabBtnInfos) do
        if value.tag == 3 then
            table.remove(tabBtnInfos,key)
            table.insert(tabBtnInfos, 1, value)
            break
        end
    end


    -- 当前显示子页面类型
    self.mSubPageType = tabBtnInfos[1].tag
    -- 创建切换子页面的控件
    self.mDaysTabView = require("common.TabView"):create({
        btnInfos = tabBtnInfos,
        btnSize = cc.size(140, 53),
        defaultSelectTag = self.mSubPageType,
        onSelectChange = function(selBtnTag)
            if self.mSubPageType == selBtnTag then
                return
            end

            self.mSubPageType = selBtnTag
            -- 刷新奖励信息的列表
            self:refreshListView()
        end
    })
    self.mDaysTabView:setPosition(320, 600)
    self.mParentLayer:addChild(self.mDaysTabView)

    -- 刷新奖励信息的列表
    self:refreshListView()

    -- 小红点逻辑
    for targetId, btnObj in pairs(self.mDaysTabView:getTabBtns() or {}) do
        local targetModel = SuccessTargetModel.items[targetId]
        local function dealRedDotVisible(redDotSprite)
            local haveRedDot = self:targetHaveRedDot(targetId)
            local isRedDot = false
            if self.sameModel[targetModel.modelID] then
                for _, target in pairs(self.sameModel[targetModel.modelID]) do
                    isRedDot = self:targetHaveRedDot(target)
                    if isRedDot then break end
                end
            end
            redDotSprite:setVisible(haveRedDot or isRedDot)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = btnObj,
            eventName = {TargetEventNamePrefix .. tostring(targetId)}})
    end
end

-- 创建奖励信息的列表控件
function SevenDayMainLayer:createListview()
    -- listView背景图大小
    local downBgSize = cc.size(640,560)
    local listViewBgSize = cc.size(downBgSize.width*0.95,downBgSize.height*0.84)
    -- listView背景图
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 1))
    listViewBgSprite:setPosition(320, 540)
    self.mParentLayer:addChild(listViewBgSprite)

    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(640, 445))
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(320, 535))
    self.mParentLayer:addChild(self.mListView)
end

-- 刷新奖励信息的列表
function SevenDayMainLayer:refreshListView()
    self.mListView:removeAllItems()

    -- 当天的数据信息
    local currDayInfo = SevenPageData[self.curDay == 0 and self.mSevenInfo.Day or self.curDay] or {}
    -- 需要显示的列表数据
    local viewDataList = self:getTargetData()
    if not next(viewDataList) then
        return
    end
    -- 能否领取
    local function isGetReward(item)
        -- 该条目对应的服务器数据
        local serverData = currDayInfo[item.targetID].serverItem
        -- 达成数量
        local reachedNum = serverData.SequenceInfo[tostring(item.sequence)] or serverData.ReachedNum or 0
        -- 达成需要的数量
        local completeCondition = item.targetID == 19 and 4 or item.completeCondition1

        return reachedNum >= completeCondition
    end
    -- 是否已领取
    local function isReceived(item)
        -- 该条目对应的服务器数据
        local serverData = currDayInfo[item.targetID].serverItem

        if table.indexof(serverData.DrawNums or {}, tostring(item.sequence)) then
            return true
        end
        return false
    end
    -- 对显示的列表数据关于能否领取排序
    table.sort(viewDataList, function(item1, item2)
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

    -- 需要显示类型服务器数据
    local cellSize = cc.size(595, 114)
    for index, item in ipairs(viewDataList) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)

        -- 该条目对应的服务器数据
        local serverData = currDayInfo[item.targetID].serverItem

        local targetModel = SuccessTargetModel.items[item.targetID]
        -- 达成数量
        local reachedNum = serverData.SequenceInfo[tostring(item.sequence)] or serverData.ReachedNum or 0
        -- 达成需要的数量
        local completeCondition = item.completeCondition1
        -- 创建背景
        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width , cellSize.height))
        bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(bgSprite)
        -- 创建领取按钮或已领取标识
        if table.indexof(serverData.DrawNums or {}, tostring(item.sequence)) then
            local tempSprite = ui.newSprite("jc_21.png")
            tempSprite:setPosition(cellSize.width - 80, cellSize.height / 2)
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

                    self:drawRewardRequest(item.targetID, item.sequence)
                end
            })
            tempBtn:setPosition(cellSize.width - 80, cellSize.height / 2)
            lvItem:addChild(tempBtn)
            tempBtn:setEnabled(reachedNum >= completeCondition)
        end

        -- 创建显示达成条件信息
        -- local textString = string.format(targetModel.reachedIntroFormat, item.completeCondition1, item.completeCondition2)
        -- local rateString = string.format("%s%s/%s",
        --     "#39FF6D",
        --     Utility.numberWithUnit(reachedNum),
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
            "#249029",
            Utility.numberWithUnit(reachedNum),
            "#592817",
            Utility.numberWithUnit(completeCondition))
        local text1 = ui.newLabel({
                text = textString,
                size = 22,
                align =  cc.TEXT_ALIGNMENT_CENTER,
                color = cc.c3b(0x59, 0x28, 0x17),
                dimensions = cc.size(170,0),
                --x = cellSize.width * 0.21,
                x = 10,
                y = cellSize.height * 0.5 + 20,
            })
        text1:setAnchorPoint(cc.p(0, 0.5))
        lvItem:addChild(text1)
        local text2 = ui.newLabel({
                text = TR("进度 %s", rateString),
                size = 22,
                color = cc.c3b(0x59, 0x28, 0x17),
                -- x = cellSize.width * 0.21,
                -- y = cellSize.height * 0.5,
                x = 95,
                y = cellSize.height * 0.5 - 20,
            })
        lvItem:addChild(text2)
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
            viewHeight = cellSize.height,
            maxViewWidth = 265,
            allowClick = true,
            space = -28,
            isSwallow = false,
        })
        cardList:setAnchorPoint(cc.p(0, 0.5))
        cardList:setPosition(185, cellSize.height * 0.4)
        lvItem:addChild(cardList)

        local card = cardList:getCardNodeList()
        for index = 1, #card do
            card[index]:setScale(0.9)
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
function SevenDayMainLayer:getTargetData(targetData)
    local retData = {}
    local currDayInfo = SevenPageData[self.curDay == 0 and self.mSevenInfo.Day or self.curDay] or {}
    for _, targetId in pairs(MergeTargetInfo[self.mSubPageType or 0] or {}) do
        for _, item in pairs(currDayInfo[targetId] and currDayInfo[targetId].configItems or {}) do
            table.insert(retData, item)
        end
    end

    -- 排序列表数据
    table.sort(retData, function(item1, item2)
        -- 比较是否已领取
        local serverData1 = currDayInfo[item1.targetID] and currDayInfo[item1.targetID].serverItem or {}
        local serverData2 = currDayInfo[item2.targetID] and currDayInfo[item2.targetID].serverItem or {}
        local hadDraw1 = table.indexof(serverData1.DrawNums or {}, tostring(item1.sequence)) ~= false
        local hadDraw2 = table.indexof(serverData2.DrawNums or {}, tostring(item2.sequence)) ~= false
        if hadDraw1 ~= hadDraw2 then
            return hadDraw2
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
    return retData
end

-- 计算某种奖项是否有小红点
function SevenDayMainLayer:targetHaveRedDot(targetId)
    if self.mSevenInfo.Day > 7 then
        return false
    end
    local viewData = SevenPageData[self.curDay == 0 and self.mSevenInfo.Day or self.curDay]
    if not viewData then
        return false
    end
    local serverData = viewData[targetId].serverItem
    if not serverData then
        return false
    end

    local sequence = serverData.Sequence or 0
    local drawCount = serverData.DrawNums and #serverData.DrawNums or 0
    return sequence > drawCount
end

function SevenDayMainLayer:dayHaveRedDot(dayIndex)
    -- 大于七天不显示任务和兑换的小红点
    if self.mSevenInfo.Day > 7 then
        return false
    end
    -- 获取当前数据
    local viewData = SevenPageData[dayIndex]
    if not viewData then
        return false
    end
    -- 任务小红点
    local taskRedDot = false
    for _, v in pairs(viewData) do
        local serverData = v.serverItem
        if serverData then
            local sequence = serverData.Sequence or 0
            local drawCount = serverData.DrawNums and #serverData.DrawNums or 0
            if sequence > drawCount then
                taskRedDot = true
                break
            end
        end
    end
    -- 兑换小红点
    local exchangeRedDot = false
    local currDay = dayIndex
    for _, item in pairs(self.mExchangeInfo[currDay] or {}) do
        local sequence = item.Sequence
        local tempConfig = SuccessPurchaseModel.items[currDay] and SuccessPurchaseModel.items[currDay][sequence]
        if tempConfig and item.GlobalNum < tempConfig.serverMax and
            item.PersonalNum < tempConfig.singleMax and
            item.NeedVipLv <= PlayerAttrObj:getPlayerAttrByName("Vip") and
            item.NeedLv <= PlayerAttrObj:getPlayerAttrByName("Lv") then
            exchangeRedDot = true
            break
        end
    end

    return taskRedDot or exchangeRedDot
end

-- 创建兑换列表页面
function SevenDayMainLayer:createExchangeLayer()
    -- 列表的显示大小
    local listViewSize = cc.size(500, 260)

    -- 玩家当前的VIP等级
    local playerVip = PlayerAttrObj:getPlayerAttrByName("Vip")

    -- 刷新兑换列表条目
    local function refreshExchangeList(listViewObj)
        listViewObj:removeAllChildren()

        local cellSize = cc.size(listViewSize.width, 124)
        local currDay = self.curDay == 0 and self.mSevenInfo.Day or self.curDay
        for _, item in ipairs(self.mExchangeInfo[currDay] or {}) do
            local lvItem = ccui.Layout:create()
            lvItem:setContentSize(cellSize)
            listViewObj:pushBackCustomItem(lvItem)

            -- 该条目对应的配置文件
            local configItem = SuccessPurchaseModel.items[currDay][item.Sequence]

            -- 列表背景图
            local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
            bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
            lvItem:addChild(bgSprite)

            -- 个人可兑换数量
            local tempStr = TR("%s个人可兑换数量:%s%d", Enums.Color.eBrownH,
                    (configItem.singleMax - item.PersonalNum > 0) and "#249029" or Enums.Color.eRedH,
                    configItem.singleMax - item.PersonalNum)
            local tempLabel = ui.newLabel({
                text = tempStr,
                anchorPoint = cc.p(0, 0.5),
                size = 22,
            })
            tempLabel:setPosition(20, cellSize.height * 0.85)
            lvItem:addChild(tempLabel)

            -- 需要物品
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = item.NeedGameResourceList[1].ResourceTypeSub,
                modelId = item.NeedGameResourceList[1].ModelId,
                num = item.NeedGameResourceList[1].Count,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
            })
            tempCard:setAnchorPoint(cc.p(0, 0.5))
            tempCard:setScale(0.8)
            tempCard:setPosition(30, cellSize.height * 0.4)
            lvItem:addChild(tempCard)

            -- 箭头
            local tempSprite = ui.newSprite("bsxy_01.png")
            tempSprite:setPosition(150, cellSize.height * 0.45)
            lvItem:addChild(tempSprite)

            -- 获得物品
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = item.ExchaneGameResourceList[1].ResourceTypeSub,
                modelId = item.ExchaneGameResourceList[1].ModelId,
                num = item.ExchaneGameResourceList[1].Count,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
            })
            tempCard:setAnchorPoint(cc.p(0, 0.5))
            tempCard:setScale(0.8)
            tempCard:setPosition(200, cellSize.height * 0.4)
            lvItem:addChild(tempCard)

            -- 需要VIP等级
            local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
            local needVip = item.NeedVipLv
            local noticeMsg = ""
            if needVip > 0 then
                noticeMsg = TR("%s需VIP%d", needVip > playerVip and "#d17b00" or Enums.Color.eWhiteH, needVip) 
            elseif playerLv < item.NeedLv then
                noticeMsg = TR("%s需等级%d", "#d17b00", item.NeedLv)
            end
            if string.len(noticeMsg) > 0 then
                local needVipLabel = ui.newLabel({
                    text = noticeMsg,
                    align = cc.TEXT_ALIGNMENT_CENTER,
                    size = 22,
                })
                needVipLabel:setPosition(cellSize.width - 70, 105)
                lvItem:addChild(needVipLabel)
            end

            -- 领取按钮
            local exchangeBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("兑换"),
                clickAction = function()
                    for _, needItem in pairs(item.NeedGameResourceList) do
                        if not Utility.isResourceEnough(needItem.ResourceTypeSub, needItem.Count) then
                            return
                        end
                    end

                    self:exchangeRequest(item.Sequence)
                end
            })
            exchangeBtn:setPosition(cellSize.width - 70, cellSize.height * 0.5)
            lvItem:addChild(exchangeBtn)
            exchangeBtn:setEnabled(configItem.singleMax > item.PersonalNum and playerVip >= needVip and playerLv >= item.NeedLv)
        end
    end

    local tempData = {
        bgSize = cc.size(568, 400),
        title = TR("每日限购"),
        btnInfos = {},
        closeBtnInfo = {},
        notNeedBlack = true,
        DIYUiCallback = function(layerObj, bgSprite, bgSize)
            local upSprite = ui.newScale9Sprite("c_17.png", cc.size(listViewSize.width + 15, listViewSize.height + 15))
            upSprite:setPosition(bgSize.width / 2, bgSize.height / 2 - 20)
            bgSprite:addChild(upSprite)

            -- 创建ListView列表
            local listView = ccui.ListView:create()
            listView:setDirection(ccui.ScrollViewDir.vertical)
            listView:setBounceEnabled(true)
            listView:setContentSize(listViewSize)
            listView:setItemsMargin(8) -- 改变两个cell之间的边界
            listView:setGravity(ccui.ListViewGravity.centerVertical)
            listView:setAnchorPoint(cc.p(0.5, 1))
            listView:setPosition(bgSize.width / 2, 307)
            bgSprite:addChild(listView)

            Notification:registerAutoObserver(listView, refreshExchangeList, ExchangeDataChange)
            refreshExchangeList(listView)
        end
    }

    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 完成成就奖励预览
function SevenDayMainLayer:completeRewardPreview(dayIndex)
    -- 完成该天所有任务可以获得的物品
    local rewardGold = Utility.analysisStrResList(SuccessTimeModel.items[dayIndex].resourceList)[1]
    local tempData = {
        bgSize = cc.size(540, 486),
        title = TR("第%d天奖励", dayIndex),
        size = 27,
        notNeedBlack = true,
        color = cc.c3b(0xff, 0xff, 0xff),
        closeBtnInfo = {},
        DIYUiCallback = function(layerObj, bgSprite, bgSize)
            -- 内容的小背景
            local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(470, 325))
            tempSprite:setPosition(bgSize.width / 2, bgSize.height * 0.52)
            bgSprite:addChild(tempSprite)

            -- 完成第x天指定任务，即可领取
            local topSprite = ui.newSprite("kfdj_11.png")
            topSprite:setPosition(bgSize.width / 2, bgSize.height * 0.73)
            bgSprite:addChild(topSprite)

            -- 第x天
            local dayLabel = ui.newNumberLabel{
                imgFile = "c_49.png",
                text = dayIndex,
            }
            dayLabel:setPosition(109, 105)
            topSprite:addChild(dayLabel)

            --元宝图标
            local goldImage = Utility.getResTypeSubImage(ResourcetypeSub.eDiamond)
            local goldLabel = ui.newSprite(goldImage)
            goldLabel:setPosition(80,32)
            topSprite:addChild(goldLabel)

            --元宝数量
            local label = ui.newLabel({
                text = rewardGold.num,
                size = 22,
                x = 140,
                y = 30,
            })
            topSprite:addChild(label)

            -- 第x天登录即可领取以下奖励
            local textLabel = ui.newLabel{
                text = TR("第%d天登录即可领取以下奖励:", dayIndex),
                size = 24,
                -- color = Enums.Color.eBrown,
                outlineColor = Enums.Color.eBlack,
                x = 280,
                y = 240,
            }
            bgSprite:addChild(textLabel)

            -- 登录天数可以获得的奖励列表
            local tempStr = SuccessTargetRewardRelation.items[totalLoginTargetId][dayIndex][dayIndex].resourceList
            local rewardList = Utility.analysisStrResList(tempStr)
            for _, item in pairs(rewardList) do
                item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
            end
            local cardList = ui.createCardList({
                cardDataList = rewardList,
                allowClick = true,
                maxViewWidth = 450,
                space = 15,
            })
            cardList:setAnchorPoint(cc.p(0.5, 0))
            cardList:setPosition(bgSprite:getContentSize().width * 0.5, bgSize.height * 0.20)
            bgSprite:addChild(cardList)
        end
    }

    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 领取某天完成成就奖励的提示
function SevenDayMainLayer:drawTotalRewardView(dayIndex)
    -- 该天完成进度信息
    local dayInfo = self.mSevenInfo.DrawDay and self.mSevenInfo.DrawDay[dayIndex or 0]
    if not dayInfo then
        return
    end
    -- 完成进度比例
    -- if self.mSevenInfo.TargetCount[tostring(dayIndex)] == nil then return end
    -- local finishRate = self.mSevenInfo.TargetCount[tostring(dayIndex)].FinishTargetCount / self.mSevenInfo.TargetCount[tostring(dayIndex)].TotalTargetCount
    -- 完成总任务可以获得的物品
    local rewardList = Utility.analysisStrResList(dayInfo.RewardInfo)
    local rewardDiamond = 0
    for _, item in pairs(rewardList) do
        if item.resourceTypeSub == ResourcetypeSub.eDiamond then
            rewardDiamond = item.num
        end
    end

    -- 领取按钮信息
    local okBtnInfo = {
        normalImage = "c_28.png",
        text = TR("领 取"),
        clickAction = function(layerObj, btnObj)
            if dayIndex <= 7 then
                self:drawTotalRewardRequest(dayIndex, function()
                    if PlayerAttrObj:getPlayerAttrByName("HasDrawSuccessReward") == 0 then
                        LayerManager.removeLayer(layerObj)
                    else
                        LayerManager.removeLayer(self)
                    end
                end)
                return
            end
            MsgBoxLayer.addOKLayer(
                TR("当前领取完成后将关闭开服活动，请注意当前限购是否已兑换，是否确定立即领取？"),
                TR("提示"),
                {
                    {normalImage = "c_28.png",
                    text = TR("确 定"),
                    clickAction = function(layerObj, btnObj)
                        self:drawTotalRewardRequest(dayIndex, function()
                            if PlayerAttrObj:getPlayerAttrByName("HasDrawSuccessReward") == 0 then
                                LayerManager.removeLayer(layerObj)
                            else
                                LayerManager.removeLayer(self)
                            end
                        end)
                    end}
                })
        end,
    }

    local tempData = {
        title = TR("%s第%d天奖励", Enums.Color.eWhiteH, dayIndex),
        msgText = TR("完成进度：%d/%d,可获得%d元宝.", dayInfo.FinishTargetCount, dayInfo.TotalTargetCount, rewardDiamond),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = function(layerObj, bgSprite, bgSize)
            -- 重新设置提示信息的位置
            layerObj.mMsgLabel:setPositionY(bgSize.height - 100)

            local tempSize = cc.size(bgSize.width - 80, 125)
            -- 内容的小背景
            local tempSprite = ui.newScale9Sprite("c_17.png", tempSize)
            tempSprite:setAnchorPoint(cc.p(0.5, 0))
            tempSprite:setPosition(bgSize.width / 2, 92)
            tempSprite:setOpacity(0)
            bgSprite:addChild(tempSprite)

            -- 创建奖励物品列表
            local cardListNode = ui.createCardList({
                maxViewWidth = tempSize.width - 10,
                cardDataList = rewardList,
                allowClick = true,
            })
            cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
            cardListNode:setPosition(tempSize.width / 2, tempSize.height / 2)
            tempSprite:addChild(cardListNode)
        end
    }

    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

function SevenDayMainLayer:refreshUI()
    -- 把服务器返回的数据整理到 SevenPageData 表的 serverItem 中
    local dayItem = SevenPageData[self.curDay == 0 and self.mSevenInfo.Day or self.curDay]
    if dayItem == nil then return end
    for targetId, item in pairs(dayItem) do
        item.serverItem = self.mSevenInfo.TargetList[targetId] or {}
        item.serverItem.SequenceInfo = item.serverItem.SequenceInfo or {}

        Notification:postNotification(TargetEventNamePrefix .. tostring(targetId))
    end

    Notification:postNotification(DayEventNamePrefix)

    -- 刷新进度信息
    self.mFinishNode.refreshView()
    -- 兑换小红点
    Notification:postNotification(ExchangeDataChange)

    -- 创建某一天奖励类型的切换按钮
    if self.mSevenInfo.Day <= 7 then
        self:createDaysTabView()
    else
        if self.mDaysTabView ~= nil then
            self.mDaysTabView:removeFromParent()
            self.mDaysTabView = nil
        end
    end
end

-- =========================== 网络请求相关接口 ======================
-- 获取玩家7日成就完成信息的数据请求
function SevenDayMainLayer:getInfoRequest()
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 获取当前兑换信息的数据请求
            self:getExchangeInfoRequest()
            -- 重新整理服务器返回的数据主要是为方便访问 TargetList 的条目
            self.mSevenInfo = {}
            for key, value in pairs(response.Value or {}) do
                if key == "DrawDay" then
                    self.mSevenInfo[key] = {}
                    for _, item in pairs(value) do
                        self.mSevenInfo[key][item.Day] = item
                    end
                elseif key == "TargetList" then
                    self.mSevenInfo[key] = {}
                    for index, item in pairs(value) do
                        item.DrawNums = string.splitBySep(item.DrawNums or "", ",")
                        self.mSevenInfo[key][item.TargetId] = item
                    end
                else
                    self.mSevenInfo[key] = value
                end
            end
            self.curDay = self.mSevenInfo.Day
            -- 把服务器返回的数据整理到 SevenPageData 表的 serverItem 中

            for dayIndex, dayItem in pairs(SevenPageData) do
                for targetId, item in pairs(dayItem) do
                    item.serverItem = self.mSevenInfo.TargetList[targetId] or {}
                    item.serverItem.SequenceInfo = item.serverItem.SequenceInfo or {}

                    Notification:postNotification(TargetEventNamePrefix .. tostring(targetId))
                end

            end

            Notification:postNotification(DayEventNamePrefix)

            -- 刷新进度信息
            self.mFinishNode.refreshView()

            -- 创建某一天奖励类型的切换按钮
            self:createDaysTabView()
        end
    })
end

-- 领取7日大奖奖项的数据请求
--[[
-- 参数
    sequence: 任务序号
]]
function SevenDayMainLayer:drawRewardRequest(targetId, sequence)
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "DrawReward",
        svrMethodData = {targetId, sequence},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 显示领取到的奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 把已领取的序号修改到本地缓存的服务端数据中
            local serverItem = self.mSevenInfo.TargetList[targetId] or {}
            serverItem.DrawNums = serverItem.DrawNums or {}
            table.insert(serverItem.DrawNums, tostring(sequence))
            -- 进度奖
            for key, value in pairs(response.Value or {}) do
                if key == "DrawDay" then
                    self.mSevenInfo[key] = {}
                    for _, item in pairs(value) do
                        self.mSevenInfo[key][item.Day] = item
                    end
                end
            end
            --实时刷新当前进度条
            self.mSevenInfo.TargetCount  = response.Value.TargetCount

            self.mFinishNode.refreshView()

            -- 刷新奖励信息的列表
            self:refreshListView()
            -- 通知当天按钮状态刷新
            Notification:postNotification(DayEventNamePrefix .. tostring(self.curDay == 0 and self.mSevenInfo.Day or self.curDay))
            -- 通知奖项按钮状态刷新
            Notification:postNotification(TargetEventNamePrefix .. tostring(self.mSubPageType))
        end
    })
end

-- 领取7日大奖每日进度奖励数据请求
function SevenDayMainLayer:drawTotalRewardRequest(dayIndex, callback)
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "DrawTotalReward",
        svrMethodData = {dayIndex},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 把已领取的总奖励信息更新到本地缓存的服务端数据中
            self.mSevenInfo.DrawDay[dayIndex] = nil
            -- 实时刷新当前进度条
            self.mFinishNode.refreshView()
            -- 通知该天按钮状态刷新
            Notification:postNotification(DayEventNamePrefix .. tostring(dayIndex))

            if callback then
                callback()
            end
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end

-- 获取当前兑换信息的数据请求
function SevenDayMainLayer:getExchangeInfoRequest()
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "GetExchangeInfo",
        svrMethodData = {},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end

            --
            self.mExchangeInfo = response.Value.ActivityList or {}
            -- 通知兑换数据发生修改
            Notification:postNotification(ExchangeDataChange)

            Notification:postNotification(DayEventNamePrefix)
        end
    })
end

-- 兑换的数据请求
function SevenDayMainLayer:exchangeRequest(sequence)
    HttpClient:request({
        moduleName = "SuccessTargetInfo",
        methodName = "Exchange",
        svrMethodData = {self.curDay, sequence},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            --
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            --
            local currDay = self.curDay == 0 and self.mSevenInfo.Day or self.curDay
            if self.mExchangeInfo[currDay] then
                self.mExchangeInfo[currDay] = response.Value.ActivityList or {}
            end
            -- 通知兑换数据发生修改
            Notification:postNotification(ExchangeDataChange)
            -- 通知当天按钮状态刷新
            Notification:postNotification(DayEventNamePrefix .. tostring(currDay))
        end
    })
end

return SevenDayMainLayer
