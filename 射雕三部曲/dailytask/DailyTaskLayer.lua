--[[
	文件名：DailyTaskLayer.lua
	描述：任务页面
	创建人：peiyaoqiang
	创建时间：2017.12.22
--]]
local DailyTaskLayer = class("DailyTaskLayer", function(params)
    return display.newLayer()
end)

-- 已领取状体的宝箱图片名
local gChestHImageName = {
    "r_10.png",
    "r_11.png",
    "r_12.png",
    "r_13.png",
    "r_14.png",
}
local gChestCloseImageName = {
    "r_09.png",
    "r_08.png",
    "r_07.png",
    "r_06.png",
    "r_05.png",
}
local gLayerTab = {
    daily = 1,  -- 每日
    week = 2,   -- 每周
}
local gWeekReddotEventName = "gWeekReddotEventName"

-- 构造函数
--[[
	params:
	Table params:
	{
		exitCallBacak		-- 当前layer退出时的回调函数
        scrollPos           -- 页面跳转时，listview滑动的位置，用于页面恢复
	}
--]]
function DailyTaskLayer:ctor(params)
    self.mExitCallBack = params.exitCallBacak
    self.mScrollPos = params.scrollPos
    self.mCurrTab = 1

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("任务"),
        bgSize = cc.size(640, 983),
        closeImg = "c_29.png",
        closeAction = function()
            if self.mExitCallBack then
                self.mExitCallBack()
            end
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite

    -- 初始化UI
    self:initUI()
end

function DailyTaskLayer:initUI()
    local tabConfig = {
        {tag = gLayerTab.daily, text = TR("每日任务")},
        {tag = gLayerTab.week, text = TR("每周任务")},
    }
    local tabLayer = ui.newTabLayer({
        viewSize = cc.size(600, 80),
        btnInfos = tabConfig,
        defaultSelectTag = self.mCurrTab,
        needLine = true,
        onSelectChange = function(tag)
            if (self.mCurrTab ~= tag) then
                self.mCurrTab = tag
                self:refreshView()
            end
        end,
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(cc.p(320, 932))
    self.mBgSprite:addChild(tabLayer)

    -- 每周任务的小红点
    local function dealStepUpRedDotVisible(redDotSprite)
        local isShowReddot = false
        for _,v in pairs(self.weekRewardInfo or {}) do
            if (v.Status == 1) then
                isShowReddot = true
                break
            end
        end
        redDotSprite:setVisible(isShowReddot)
    end
    ui.createAutoBubble({parent = tabLayer:getTabBtnByTag(gLayerTab.week), eventName = {gWeekReddotEventName}, refreshFunc = dealStepUpRedDotVisible})

    -- 显示Tab内容背景
    local viewNodeSize = cc.size(590, 835)
    local viewBgNode = cc.Node:create()
    viewBgNode:setContentSize(viewNodeSize)
    viewBgNode:setAnchorPoint(cc.p(0.5, 0))
    viewBgNode:setPosition(320, 20)
    self.mBgSprite:addChild(viewBgNode)
    
    self.viewBgNode = viewBgNode
    self.viewBgSize = viewNodeSize
    self:refreshView()
end

-- 刷新界面
function DailyTaskLayer:refreshView()
    self.viewBgNode:removeAllChildren()
    self.boxList = {}

    -- 切换界面
    if (self.mCurrTab == gLayerTab.daily) then
        self:showDailyTask()
    else
        self:showWeekTask()
    end

    -- 获取任务数据
    self:requestGetDaliyTaskInfo()
end

-- 显示每日任务
function DailyTaskLayer:showDailyTask()
    local bgSprite = self.viewBgNode
    local bgSize = self.viewBgSize

    self.mTaskRewardConfig = {}     -- 任务奖励配置信息表，从DailytaskRewardModel.lua中读取
    self.mPlayerTaskInfo = {}       -- 玩家日常任务信息，请求服务器成功时返回该数据
    self.mChestBtnList = {}         -- 宝箱按钮列表
    self.mRpLv = 0                  -- 用于计算宝箱经验奖励的等级系数
    self.mProgressBar = nil

    -- 读取奖励配置，并按照所需积分进行排序
    for _,v in pairs(DailytaskRewardModel.items) do
        table.insert(self.mTaskRewardConfig, clone(v))
    end
    table.sort(self.mTaskRewardConfig, function(a, b)
        return a.needCredit < b.needCredit
    end)

    -- 描述文字
    local tempNode = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        scale9Size = cc.size(520, 54),
        labelStr = TR("完成每日任务，可以获得大量帮派资金"),
        fontColor = Enums.Color.eWhite
    })
    tempNode:setPosition(bgSize.width / 2, bgSize.height - 32)
    bgSprite:addChild(tempNode)

    -- 添加宝箱
    for i=1, DailytaskRewardModel.items_count do
        -- 未打开的宝箱
        local chestBtn = ui.newButton({
            normalImage = gChestCloseImageName[i],
            anchorPoint = cc.p(0.5, 0),
            position = cc.p(i * 110 - 35, 690),
            clickAction = function() end
        })
        bgSprite:addChild(chestBtn)
        table.insert(self.mChestBtnList, chestBtn)

        -- 宝箱上的积分
        local integralLabel = ui.createSpriteAndLabel({
            imgName = "r_03.png",
            labelStr = self.mTaskRewardConfig[i].needCredit,
            fontSize = 20,
            outlineColor = Enums.Color.eBlack,
        })
        integralLabel:setPosition(cc.p(i * 110 - 35, 685))
        integralLabel:setAnchorPoint(cc.p(0.5, 0))
        bgSprite:addChild(integralLabel)
    end

    -- 列表背景
    local listBgSize = cc.size(bgSize.width - 10, 630)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(bgSize.width / 2, 5)
    bgSprite:addChild(listBgSprite)

    -- 任务列表
    local mTaskListView = ccui.ListView:create()
    mTaskListView:setDirection(ccui.ScrollViewDir.vertical)
    mTaskListView:setBounceEnabled(true)
    mTaskListView:setContentSize(cc.size(listBgSize.width - 20, listBgSize.height - 20))
    mTaskListView:setGravity(ccui.ListViewGravity.centerVertical)
    mTaskListView:setAnchorPoint(cc.p(0.5, 0.5))
    mTaskListView:setPosition(cc.p(listBgSize.width / 2, listBgSize.height / 2))
    mTaskListView:setItemsMargin(5)
    mTaskListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listBgSprite:addChild(mTaskListView)
    self.mTaskListView = mTaskListView

    -- 额外加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(true, true)
    if attrLabel then
        attrLabel:setPosition(540, bgSize.height - 30)
        bgSprite:addChild(attrLabel)
    end
end

-- 显示每周任务
function DailyTaskLayer:showWeekTask()
    local bgSprite = self.viewBgNode
    local bgSize = self.viewBgSize

    -- 页面背景
    local tmpBgSprite = ui.newSprite("r_21.jpg")
    tmpBgSprite:setPosition(bgSize.width / 2, bgSize.height / 2)
    bgSprite:addChild(tmpBgSprite)

    -- 文字背景
    local textBgSize = cc.size(bgSize.width - 20, 80)
    local textBgSprite = ui.newScale9Sprite("c_145.png", textBgSize)
    textBgSprite:setPosition(bgSize.width / 2, bgSize.height - 60)
    bgSprite:addChild(textBgSprite)

    -- 提示文字
    local function addTmpLabel(strText, yPos)
        local label = ui.newLabel({
            text = strText,
            size = 20,
            x = textBgSize.width / 2,
            y = yPos,
        })
        textBgSprite:addChild(label)
        return label
    end
    addTmpLabel(TR("做每日任务可获得每周任务的积分，每周日24:00重置"), textBgSize.height * 0.7)
    self.scoreLabel = addTmpLabel("", textBgSize.height * 0.3)
    self.scoreLabel.refreshLabel = function (target)
        target:setString(TR("本周已累计获得任务积分: %s%s", Enums.Color.eNormalYellowH, self.currWeekScore or 0))
    end
    self.scoreLabel:refreshLabel()
    
    -- 宝箱配置
    self.boxConfig = {
        {imgClose = "r_19.png", imgOpen = "r_15.png", pos = cc.p(bgSize.width - 150, bgSize.height * 0.5 - 220)},
        {imgClose = "r_18.png", imgOpen = "r_16.png", pos = cc.p(bgSize.width - 100, bgSize.height * 0.5 - 20)},
        {imgClose = "r_20.png", imgOpen = "r_17.png", pos = cc.p(bgSize.width - 150, bgSize.height * 0.5 + 180)},
    }
end

----------------------------------------------------------------------------------------------------
-- 每日任务相关

-- 对获取的数据整理排序，然后刷新ListView
function DailyTaskLayer:refreshListView()
    -- 任务数据排序, 排列顺序依次为：可领取、不可领取、已领取
    table.sort(self.mPlayerTaskInfo.TasksInfo, function(a, b)
        --是否可以领取积分（true／false）
        if a.CanDrawCredit ~= b.CanDrawCredit then
            return a.CanDrawCredit
        end
        --是否已完成（false/true）
        if a.Status ~= b.Status then
            return b.Status
        end
        --普通玩家是否达到开启等级
        if a.openLv and b.openLv and a.openLv ~= b.openLv then
            return a.openLv < b.openLv
        end
        return false
    end)

    -- 重新添加所有任务
    self.mTaskListView:removeAllItems()
    self.taskBtnList = {}

    local width, height = 560, 150
    local function addElementsToCell(cell, index)
        local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
        cellBgSprite:setPosition(width * 0.5, height * 0.5)
        cell:addChild(cellBgSprite)

        -- 延迟执行添加条目具体信息
        Utility.performWithDelay(cellBgSprite, function()
            self:addIndex(cellBgSprite, index, width, height)
        end, (index < 6) and 0 or (0.01 * index))
    end

    for i=1, #self.mPlayerTaskInfo.TasksInfo do
        local taskModel = DailytaskModel.items[self.mPlayerTaskInfo.TasksInfo[i].Id]
        if ModuleInfoObj:moduleIsOpen(taskModel.moduleID, false) then
            local customCell = ccui.Layout:create()
            customCell:setContentSize(cc.size(width, height))
            addElementsToCell(customCell, i)
            self.mTaskListView:pushBackCustomItem(customCell)
        end
    end

    -- 从其他页面回来，需要滚动到上次的位置
    if self.mScrollPos then
        Utility.performWithDelay(self, function()
            self.mTaskListView:setInnerContainerPosition(self.mScrollPos)
            self.mScrollPos = nil
        end, 0.01)
    end
end

function DailyTaskLayer:addIndex(node, index, mcellWidth, mcellHeight)
    local itemInfo = self.mPlayerTaskInfo.TasksInfo[index]  -- 任务数据信息
    local itemConfig = DailytaskModel.items[itemInfo.Id]    -- 任务配置信息
    
    -- 完成进度
    local progress = (itemInfo.Num > itemConfig.loopNum) and itemConfig.loopNum or itemInfo.Num
    local descLabel = ui.newLabel({
        text = itemConfig.intro,
        size = 24,
        anchorPoint = cc.p(0, 0.5),
        x = 25,
        y = mcellHeight * 0.8,
        color = Enums.Color.eBlack
    })
    node:addChild(descLabel)
    --
    local posX = descLabel:getContentSize().width
    local progresslabel = ui.newLabel({
        text = TR("进度: %d/%d", progress, itemConfig.loopNum),
        size = 18,
        anchorPoint = cc.p(0.5, 0.5),
        x = mcellWidth - 80 ,
        y = mcellHeight * 0.62,
        color = Enums.Color.eNormalYellow
    })
    node:addChild(progresslabel)

    -- 处理奖励，有些奖励需要单独创建
    local tmpBaseExp = DailytaskExpRelation.items[self.mRpLv].baseEXP
    local jiangliList = Utility.analysisStrResList(itemConfig.resourceList)
    table.insert(jiangliList, 1, {["resourceTypeSub"] = ResourcetypeSub.eGuildActivity, ["modelId"] = 0, ["num"] = itemConfig.outputCredit}) -- 活跃度
    table.insert(jiangliList, 2, {["resourceTypeSub"] = ResourcetypeSub.eGuildMoney, ["modelId"] = 0, ["num"] = itemConfig.outputGuildFund}) --帮派资金
    table.insert(jiangliList, 3, {["resourceTypeSub"] = ResourcetypeSub.eEXP, ["modelId"] = 0, ["num"] = itemConfig.playerEXPFactor * tmpBaseExp}) --经验奖励

    --创建奖励列表
    local tempCard = ui.createCardList({
        maxViewWidth = 420,     --显示的最大宽度
        viewHeight = 120,       --显示的高度，默认为120
        space = -20,
        cardShowAttrs = {},
        cardDataList = jiangliList,
        allowClick = true,
        isSwallow = false,
    })
    tempCard:setScale(0.9)
    tempCard:setPosition(cc.p(10, -8))
    node:addChild(tempCard)
    
    -- 前往/领取按钮; Status任务是否完成; CanDrawCredit是否可以领取积分
    if itemInfo.CanDrawCredit == false and itemInfo.Status == false then
        local btnGo = ui.newButton({
            normalImage = "c_28.png",
            text = TR("前往"),
            position = cc.p(mcellWidth - 80, mcellHeight * 0.38),
            clickAction = function()
                if (itemConfig.moduleID == ModuleSub.eTrader) then          -- 限时商店
                    if RedDotInfoObj:isValid(itemConfig.moduleID) then
                        LayerManager.addLayer({name = "shop.LimitStoreLayer", cleanUp = false})
                    else
                        ui.showFlashView({text = TR("限时商店暂未开启")})
                    end
                elseif (itemConfig.moduleID == ModuleSub.eHeroLvUp) then    -- 神将强化
                    LayerManager.showSubModule(itemConfig.moduleID, {originalId = FormationObj:getSlotInfoBySlotId(2).HeroId})
                elseif (itemConfig.moduleID == ModuleSub.eFormation) then   -- 内功洗练
                    LayerManager.showSubModule(ModuleSub.eZhenjueExtra)
                elseif (itemConfig.moduleID == ModuleSub.eSect) then        -- 八大门派
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eSect, true) then
                        return false
                    end
                    SectObj:getSectInfo(function(response)
                        if response.IsJoinIn then
                            LayerManager.addLayer({name = "sect.SectLayer", data = {}})
                        else
                            LayerManager.addLayer({name = "sect.SectSelectLayer", data = {}})
                        end
                    end)
                else
                    -- 记录滑动位置，用于页面恢复
                    self.mScrollPos = self.mTaskListView:getInnerContainerPosition()
                    LayerManager.showSubModule(itemConfig.moduleID)
                end
            end
        })
        node:addChild(btnGo)
        table.insert(self.taskBtnList, btnGo) -- 保存按钮，引导使用
    elseif itemInfo.CanDrawCredit == true and itemInfo.Status == true then
        local btnGet = ui.newButton({
            normalImage = "c_33.png",
            text = TR("领取"),
            position = cc.p(mcellWidth - 80, mcellHeight * 0.38),
            clickAction = function()
                self:requestGetCredit(itemInfo.Id, index)
            end
        })
        node:addChild(btnGet)
        table.insert(self.taskBtnList, btnGet) -- 保存按钮，引导使用
        
        if itemInfo.Message ~= nil  then
            progresslabel:setString(string.format("%s%s",Enums.Color.eNormalGreenH, itemInfo.Message))
        end
    elseif itemInfo.CanDrawCredit == false and itemInfo.Status == true then
        local haveDoneSprite = ui.newSprite("jc_21.png")
        haveDoneSprite:setPosition(mcellWidth - 80, mcellHeight * 0.38)
        node:addChild(haveDoneSprite)
        
        if itemInfo.Message ~= nil then
            progresslabel:setString(string.format("%s%s",Enums.Color.eNormalGreenH, itemInfo.Message))
        end
    end

    -- 设置card的吞噬事件为false
    local cardList = tempCard.getCardNodeList()
    for _, item in ipairs(cardList) do
        item:setSwallowTouches(false)
        item.mShowAttrControl[CardShowAttr.eName].label:setVisible(false)
    end
end

-- 刷新进度条及宝箱状态
function DailyTaskLayer:refreshProgressBarAndChests()
    -- 创建进度条
    if not self.mProgressBar then
        -- 计算总积分
        local totalValue = 0
        for _, v in ipairs(self.mPlayerTaskInfo.TasksInfo or {}) do
            local item = DailytaskModel.items[v.Id]
            if item then
                totalValue = totalValue + item.outputCredit
            end
        end
        self.mProgressBar = require("common.ProgressBar"):create({
            bgImage = "r_02.png",
            barImage = "r_01.png",
            contentSize = cc.size(566, 28),
            currValue = 0,
            maxValue = totalValue,
            needLabel = true,
            size = 20,
            color = Enums.Color.eWhite,
            outlineColor = Enums.Color.eBlack
        })
        self.mProgressBar:setPosition(cc.p(self.viewBgSize.width / 2, 660))
        self.viewBgNode:addChild(self.mProgressBar)
    end
    self.mProgressBar:setCurrValue(self.mPlayerTaskInfo.TotalCredit)
    
    -- 刷新宝箱状态
    for _,v in ipairs(self.mChestBtnList) do
        if v.flashNode then
            v:stopAllActions()
            v.flashNode:removeFromParent()
            v.flashNode = nil
            v:setRotation(0)
        end
    end
    for i,v in ipairs(self.mPlayerTaskInfo.RewardInfo or {}) do
        if v.Status == 1 then
            ui.setWaveAnimation(self.mChestBtnList[i], 7.5, true, cc.p(40, 40))
        elseif v.Status == 2 then
            self.mChestBtnList[i]:loadTextures(gChestHImageName[i], gChestHImageName[i])
        end
    end

    -- 刷新宝箱按钮点击事件
    for i,chestBtn in ipairs(self.mChestBtnList) do
        chestBtn:setClickAction(function()
            local chestReward = Utility.analysisStrResList(self.mTaskRewardConfig[i].resourceList) -- 宝箱奖励列表
            for _,v in ipairs(chestReward) do
                v.cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eBorder, CardShowAttr.eNum}
            end

            -- 按钮配置信息
            local btnInfo = {
                text = (self.mPlayerTaskInfo.RewardInfo[i].Status == 1) and TR("领取") or TR("确定"),
                size = 22,
                color = cc.c3b(0xff, 0xff, 0xff),
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                    if self.mPlayerTaskInfo.RewardInfo[i].Status == 1 then
                        self.mChestBtnList[i]:stopAllActions()
                        self.mChestBtnList[i].flashNode:removeFromParent()
                        self.mChestBtnList[i].flashNode = nil
                        self:requestDrawDailyReward(i)
                    end
                end
            }
            
            --关闭按钮
            local mCloseBtn = {
                clickAction = function(layerObj, btnObj)
                    if self.mExitCallBack then
                        self.mExitCallBack()
                    end
                    LayerManager.removeLayer(layerObj)
                end
            }

            -- 弹出奖励页面
            MsgBoxLayer.addPreviewDropLayer(
                chestReward,
                TR("可获得以下奖励"),
                TR("宝箱奖励"),
                {btnInfo},
                mCloseBtn
            )
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- 每周任务相关

-- 刷新每周任务的宝箱状态
function DailyTaskLayer:refreshWeekBox()
    if (self.mCurrTab == gLayerTab.daily) then
        return
    end
    if (self.boxConfig == nil) or (self.weekRewardInfo == nil) then
        return
    end

    -- 删除以前的宝箱
    if (self.boxList ~= nil) then
        for _,v in ipairs(self.boxList) do
            v:removeFromParent()
        end
    end

    -- 读取宝箱奖励
    local rewardList = {}
    for _,v in pairs(DailytaskWeekReward.items) do
        table.insert(rewardList, clone(v))
    end
    table.sort(rewardList, function (a, b)
            return a.needCredit < b.needCredit
        end)

    -- 刷新宝箱
    self.boxList = {}
    for i,v in ipairs(self.boxConfig) do
        local item = self.weekRewardInfo[i] or {}
        local button = ui.newButton({
            normalImage = (item.Status == 2) and v.imgOpen or v.imgClose,
            position = v.pos,
            clickAction = function()
                local chestReward = Utility.analysisStrResList(rewardList[i].resourceList) -- 宝箱奖励列表
                for _,v in ipairs(chestReward) do
                    v.cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eBorder, CardShowAttr.eNum}
                end

                -- 按钮配置信息
                local btnInfo = {
                    text = (item.Status == 1) and TR("领取") or TR("确定"),
                    size = 22,
                    color = cc.c3b(0xff, 0xff, 0xff),
                    clickAction = function(layerObj, btnObj)
                        LayerManager.removeLayer(layerObj)
                        if (item.Status == 1) then
                            self:requestDrawWeekReward(i)
                        end
                    end
                }

                --关闭按钮
                local mCloseBtn = {
                    clickAction = function(layerObj, btnObj)
                        if self.mExitCallBack then
                            self.mExitCallBack()
                        end
                        LayerManager.removeLayer(layerObj)
                    end
                }
                -- 弹出奖励页面
                MsgBoxLayer.addPreviewDropLayer(
                    chestReward,
                    TR("可获得以下奖励"),
                    TR("宝箱奖励"),
                    {btnInfo},
                    mCloseBtn
                )
            end
        })
        local btnSize = button:getContentSize()
        self.viewBgNode:addChild(button)
        table.insert(self.boxList, button)

        -- 领取条件
        local nameSprite = ui.newSprite("wgcw_32.png")
        local nameSize = nameSprite:getContentSize()
        nameSprite:setPosition(btnSize.width * 0.55, 10)
        button:addChild(nameSprite)

        local nameLabel = ui.newLabel({
            text = TR("%s分%s可领取", item.NeedCredit, Enums.Color.eNormalWhiteH),
            color = Enums.Color.eYellow,
            size = 20,
        })
        nameLabel:setAnchorPoint(cc.p(0, 0.5))
        nameLabel:setPosition(5, nameSize.height * 0.5)
        nameSprite:addChild(nameLabel)

        -- 宝箱的小红点
        if (item.Status == 1) then
            local redSprite = ui.createBubble({position = cc.p(btnSize.width * 0.8, btnSize.height * 0.8)})
            button:addChild(redSprite)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- 网络接口

-- 获取每日任务的数据
function DailyTaskLayer:requestGetDaliyTaskInfo()
    HttpClient:request({
        moduleName = "DailyTaskInfo",
        methodName = "GetDaliyTaskInfo",
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 刷新每周任务的小红点
            self.weekRewardInfo = clone(data.Value.WeekRewardInfo)
            Notification:postNotification(gWeekReddotEventName)

            -- 区分每日任务和每周任务
            if (self.mCurrTab == gLayerTab.daily) then
                -- 保存数据
                self.mPlayerTaskInfo = data.Value
                self.mRpLv = data.Value.RPlayerLv
                
                -- 刷新进度条及宝箱状态
                self:refreshProgressBarAndChests()

                -- 刷新ListView
                for _,v in pairs(self.mPlayerTaskInfo.TasksInfo or {}) do
                    local item = DailytaskModel.items[v.Id]
                    if item then
                        --判断模块是否达到开放等级，返回一个是否已开启和一个表结构。
                        local isOpen, backData = ModuleInfoObj:modulePlayerIsOpen(item.moduleID)
                        v.openLv = backData.openLv  -- 普通玩家的开启等级
                    end
                end
                self:refreshListView()

                -- 开启任务引导(有弹出动画)
                Utility.performWithDelay(self, handler(self, self.executeGuide), 0.25)
            else
                -- 保存数据
                self.currWeekScore = data.Value.TotalWeekCredit
                
                -- 刷新界面
                self.scoreLabel:refreshLabel()
                self:refreshWeekBox()
            end
        end
    })
end

-- 领取每日任务的积分
--[[
    params:
    id:                         -- 任务id
    index                       -- 当前cell的索引号
--]]
function DailyTaskLayer:requestGetCredit(id, index)
    HttpClient:request({
        moduleName = "DailyTaskInfo",
        methodName = "GetCredit",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 刷新每周任务的小红点
            self.weekRewardInfo = clone(data.Value.WeekRewardInfo)
            Notification:postNotification(gWeekReddotEventName)

            -- 更新数据
            self.mPlayerTaskInfo.TotalCredit = data.Value.TotalCredit
            self.mPlayerTaskInfo.TasksInfo = data.Value.TasksInfo
            self.mPlayerTaskInfo.RewardInfo = data.Value.RewardInfo

            -- 刷新ListView
            self:refreshListView()
            -- 刷新进度条及宝箱状态
            self:refreshProgressBarAndChests()

            -- 积分领取动画
            local rewardCredit = data.Value.TotalCredit - self.mPlayerTaskInfo.TotalCredit
            local rewardCard = CardNode:create()
            rewardCard:setCardData({resourceTypeSub = ResourcetypeSub.eGuildActivity, modelId = 0, num = rewardCredit})
            rewardCard:setPosition(cc.p(100, 475))
            rewardCard:runAction(cc.Sequence:create({
                cc.Spawn:create(cc.MoveTo:create(0.75, cc.p(310, 735)), cc.ScaleTo:create(0.75, 0.1)),
                cc.CallFunc:create(function ()
                    rewardCard:removeFromParent()
                end),
            }))
            self.mBgSprite:addChild(rewardCard)
            -- 飘窗显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            -- 检测是否升级
            PlayerAttrObj:showUpdateLayer()
        end
    })
end

-- 领取每日任务的宝箱奖励
--[[
    params:
    index               -- 宝箱序号
--]]
function DailyTaskLayer:requestDrawDailyReward(index)
    HttpClient:request({
        moduleName = "DailyTaskInfo",
        methodName = "DrawReward",
        svrMethodData = {self.mPlayerTaskInfo.RewardInfo[index].NeedCredit},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data or data.Status ~= 0 then
                return
            end
            -- 修改宝箱状态
            self.mPlayerTaskInfo.RewardInfo[index].Status = 2
            -- 刷新进度条及宝箱状态
            self:refreshProgressBarAndChests()
            -- 飘窗显示,领取的宝箱奖品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            -- 检查是否升级
            PlayerAttrObj:showUpdateLayer()
        end
    })
end

-- 领取每周任务的宝箱奖励
--[[
    params:
    index               -- 宝箱序号
--]]
function DailyTaskLayer:requestDrawWeekReward(index)
    HttpClient:request({
        moduleName = "DailyTaskInfo",
        methodName = "DrawWeekReward",
        svrMethodData = {self.weekRewardInfo[index].NeedCredit},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data or data.Status ~= 0 then
                return
            end
            -- 修改宝箱状态
            self.weekRewardInfo[index].Status = 2
            self:refreshWeekBox()
            -- 飘窗显示,领取的宝箱奖品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            -- 检查是否升级
            PlayerAttrObj:showUpdateLayer()
        end
    })
end

----------------------------------------------------------------------------------------------------

-- 数据恢复
function DailyTaskLayer:getRestoreData()
    local retData = {
        scrollPos = self.mScrollPos
    }
    return retData
end

function DailyTaskLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向第一个任务按钮
        [803] = {clickNode = self.taskBtnList[1]},
    })
end

return DailyTaskLayer
