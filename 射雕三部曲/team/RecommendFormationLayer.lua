--[[
    文件名：RecommendFormationLayer.lua
    描述：  推荐阵容页面
    创建人: peiyaoqiang
    创建时间: 2017.03.08
-- ]]
local RecommendFormationLayer = class("RecommendFormationLayer", function(params)
    return display.newLayer()
end)

-- 标签
local TabPageTags = {
    eTabFormationType1 = 1,            -- 阵容类型1
    eTabFormationType2 = 2,            -- 阵容类型2
    eTabFormationType3 = 3,            -- 阵容类型3
}

-- 领取状态
local FormationStatusTags = {
    eFormationDone = 1,   -- 完成未领取
    eFormationUnDo = 2,   -- 未完成
    eFormationFinish = 3, -- 完成领取结束
}

-- 初始化
function RecommendFormationLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 背景
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(bgSprite)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(closeBtn, 1)

    -- 初始标签
    self.mSubPageType = 1
    self:requestFormationInfo()
end

-- 创建界面ui
function RecommendFormationLayer:refreshUI()
    -- 标签
    local tableViewInfo = {
        btnInfos = {
            {
                text = TR("倚天"),
                tag  = TabPageTags.eTabFormationType1
            },
            {
                text = TR("神雕"),
                tag  = TabPageTags.eTabFormationType2
            },
            {
                text = TR("射雕"),
                tag  = TabPageTags.eTabFormationType3
            },
         },
        viewSize = cc.size(640, 80),
        space = 15,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mSubPageType == selectBtnTag then
                return
            end
            
            self.mSubPageType = selectBtnTag
            self:selectAction(selectBtnTag) 
        end
    }   
    self.mTableView = ui.newTabLayer(tableViewInfo)
    self.mTableView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(self.mTableView)

    local formationInfo = self.mAllFormationInfo
    -- 添加小红点
    local btnInfo = self.mTableView:getTabBtns()
    for k, btn in pairs(btnInfo) do
        btn:removeAllChildren()
        -- 遍历缓存数据
        local data = formationInfo[k].singelFInfo
        for i,info in pairs(data) do
            -- 判断是否可以领取
            if self.mFormationGetStatus[info.ID] == FormationStatusTags.eFormationDone then
                local tempSize = btn:getContentSize()
                local tempSprite = ui.createBubble()
                tempSprite:setPosition(tempSize.width - 15, tempSize.height)
                btn:addChild(tempSprite)    
            end
        end
    end

    -- listView背景图大小
    local listViewBgSize = cc.size(630,870)
    -- listView背景图
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listViewBgSprite:setPosition(320, 105)
    self.mParentLayer:addChild(listViewBgSprite)

    -- 初始化列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(630, 850))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(20)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 115)
    self.mParentLayer:addChild(self.mListView)

    -- 默认显示第一个标签
    self:selectAction(TabPageTags.eTabFormationType1)
end

-- 解析配置表数据
function RecommendFormationLayer:parseTabModelData()
	-- body
	local formationInfo = SuccessRecommendRelation.items

    self.mFormationType1 = {}
    self.mFormationType2 = {}
    self.mFormationType3 = {}

    local allFormation = {
        [1] = {formationId = "1" , singelFInfo = self.mFormationType1, titleText = TR("倚天")},
        [2] = {formationId = "2" , singelFInfo = self.mFormationType2, titleText = TR("神雕")},
        [3] = {formationId = "3" , singelFInfo = self.mFormationType3, titleText = TR("射雕")},
    }
    for i,v in ipairs(allFormation) do
        for j, k in ipairs(formationInfo) do
            if string.find(k.lineupID, v.formationId) ~= nil then
                table.insert(v.singelFInfo,k)
            end
        end
    end
    self.mAllFormationInfo = allFormation
end

-- 点击选择标签回调
function RecommendFormationLayer:selectAction(onSelectChange)
	self.mListView:removeAllChildren()

    local data = self.mAllFormationInfo[onSelectChange].singelFInfo
    
	-- 添加数据
    for i = 1, #data do
        self.mListView:pushBackCustomItem(self:createCellView(i, data[i]))
    end
    self.mListView:jumpToTop()
end

-- 创建listview数据
--[[---------网络相关-----------]]
function RecommendFormationLayer:createCellView(index, data)
    -- 创建custom_item
    local width = 630
    local height = 320
    local cellSize = cc.size(620, height)
    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cellSize)
    
    -- 创建背景
    local cellSprite = ui.newNodeBgWithTitle(custom_item, cellSize, data.name, cc.p(315, height / 2))
    
    -- 判断是否存在英雄
    local function isExistHero(heroId)
        local isExist = true
        -- Note:从配置数据获取总的配置数据与玩家拥有人物进行对比
        for k,v in pairs(self.mHeroIdList) do
            if (v == heroId) then
                isExist = false
                break
            end
        end
        return isExist
    end

    -- 头像列表
    local heroIdTable = string.split(data.recommend, ",")
    local cardData = {}
    for i=1, #heroIdTable do
        local cardHeard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = tonumber(heroIdTable[i]), 
            cardShowAttrs = {
                CardShowAttr.eBorder,
                CardShowAttr.eName,
            },
            needGray = isExistHero(tonumber(heroIdTable[i])),
        })
        local detalX = (width - cardHeard:getContentSize().width * 5) / 6
        local posX = (2 * i - 1) * cardHeard:getContentSize().width / 2 + detalX * i
        cardHeard:setPosition(cc.p(posX, 220))
        custom_item:addChild(cardHeard)
    end

    -- 获取奖励的背景
    local goodBarBgSize = cc.size(cellSize.width - 20, 120)
    local goodBarBgSprite = ui.newScale9Sprite("c_24.png", goodBarBgSize)
    goodBarBgSprite:setPosition(cc.p(cellSize.width / 2, cellSize.height - 240))
    cellSprite:addChild(goodBarBgSprite)

    -- 获取奖励的内容
    local tempData = Utility.analysisStrResList(data.reward)
    local goodData = {}
    for k,v in pairs(tempData) do
        local data = {}
        data.modelId = v.modelId
        data.resourceTypeSub = v.resourceTypeSub
        data.num = v.num
        data.cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eNum,
        }
        table.insert(goodData, data)
    end

    -- 物品列表
    local goodList = ui.createCardList({
        maxViewWidth = 400,
        viewHeight = 120,  
        space = 10,        
        cardDataList = goodData,
        isSwallow = false,
    })
    goodList:setAnchorPoint(cc.p(0, 0.5))
    goodList:setIgnoreAnchorPointForPosition(false)
    goodList:setPosition(cc.p(10, goodBarBgSize.height / 2 - 12))
    goodBarBgSprite:addChild(goodList)

    -- 确定按钮状态 
    local btnText = nil
    local btnRedDot = true
    if self.mFormationGetStatus[data.ID] == FormationStatusTags.eFormationFinish then
        btnText = TR("已领取")
        btnRedDot = false
    else
        btnText = TR("领 取")
        -- 添加小红点
        btnRedDot = true 
    end

    local isEnable = false
    if self.mFormationGetStatus[data.ID] == FormationStatusTags.eFormationDone then
       isEnable = true
    end
    -- 显示兑换按钮
    local exchangeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = btnText,
        outlineColor = Enums.Color.eBlack,
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(goodBarBgSize.width * 0.85, goodBarBgSize.height / 2 - 25),
        clickAction = function()
            -- 领取的网络数据
            self:requestGetFormationReward(data.ID)
        end,
    })
    goodBarBgSprite:addChild(exchangeBtn, 1)
    exchangeBtn:setEnabled(isEnable)

    -- 添加小红点
    if isEnable == true then
        local tempSize = exchangeBtn:getContentSize()
        local tempSprite = ui.createBubble()
        tempSprite:setPosition(tempSize.width - 15, tempSize.height - 10)
        exchangeBtn:addChild(tempSprite)
    end

    -- 添加描述文字
    local font = ui.newLabel({
        text = TR("集齐即可领取"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    font:setAnchorPoint(cc.p(0.5, 0.5))
    font:setPosition(cc.p(goodBarBgSize.width * 0.85, goodBarBgSize.height / 2 + 25))
    goodBarBgSprite:addChild(font)

    return custom_item
end

-- 刷新关联按钮状态
function RecommendFormationLayer:refreshButtonStatus(formationId)
    -- 遍历所有按钮找出关联ID按钮
    self.mFormationGetStatus[formationId] = FormationStatusTags.eFormationFinish
    for i,v in ipairs(self.mAllFormationInfo) do
        for j, k in ipairs(self.mAllFormationInfo[i].singelFInfo) do
            if k.ID == formationId then
                -- 刷新按钮的页面
                self:selectAction(i)
                -- 刷新小红点逻辑
                local formationInfo = self.mAllFormationInfo
                -- 添加小红点
                local btnInfo = self.mTableView:getTabBtns()
                for k,btn in pairs(btnInfo) do
                    btn:removeAllChildren()
                    -- 遍历缓存数据
                    local data = formationInfo[k].singelFInfo
                    for i,info in pairs(data) do
                        -- 判断是否可以领取
                        if self.mFormationGetStatus[info.ID] == FormationStatusTags.eFormationDone then
                            btn:removeAllChildren()
                            local tempSize = btn:getContentSize()
                            local tempSprite = ui.createBubble()
                            tempSprite:setPosition(tempSize.width - 15, tempSize.height)
                            btn:addChild(tempSprite)    
                        end
                    end
                end

            end
        end
    end
end

-- 获取推荐阵容的数据
function RecommendFormationLayer:requestFormationInfo()
	HttpClient:request({
        moduleName = "RecommendLineupRec",
        methodName = "GetRecommendLineupInfo",
        svrMethodData = {},
        callback = function(data)  
            if tolua.isnull(self) or tolua.isnull(self.mParentLayer) then
                return
            end

            -- 判断返回数据
            if not data or data.Status ~= 0 then 
                return
            end
            local dataInfo = data.Value

            -- 记录已拥有的侠客
            self.mHeroIdList = {}
            for index,value in pairs(dataInfo.HandBookInfo) do
                if value.HandBookType == 3 then
                    local data = value.HandBookList
                    for k,v in pairs(data) do
                        table.insert(self.mHeroIdList, v)
                    end
                end
            end

            -- 记录领取情况
            self.mFormationGetStatus = {} -- [[客户端只会在进入该层时获取一次状态信息此后操作均为客户端自行维护]]
            for i = 1, SuccessRecommendRelation.items_count do
                self.mFormationGetStatus[i] = FormationStatusTags.eFormationUnDo
            end

            for k,v in pairs(dataInfo.RecommendLineupInfo.CanRewardIdList) do
                self.mFormationGetStatus[v] = FormationStatusTags.eFormationDone
            end

            for k,v in pairs(dataInfo.RecommendLineupInfo.RewardedIdList) do
                self.mFormationGetStatus[v] = FormationStatusTags.eFormationFinish
            end
            
            -- 解析配置表数据
            self:parseTabModelData()
            -- 刷新界面
            self:refreshUI()
        end,
    })
end

-- 请求领取奖励
function RecommendFormationLayer:requestGetFormationReward(formationId)
	HttpClient:request({
        moduleName = "RecommendLineupRec",
        methodName = "ReceiveRecommendLineup",
        svrMethodData = {formationId},
        callback = function(data)  
            -- 判断返回数据
            if data.Status ~= 0 then 
                return
            end
            local dataInfo = data.Value

            ui.ShowRewardGoods(dataInfo.BaseGetGameResourceList)

            -- 刷新按钮
            self:refreshButtonStatus(formationId)
        end,
    })
end

return RecommendFormationLayer