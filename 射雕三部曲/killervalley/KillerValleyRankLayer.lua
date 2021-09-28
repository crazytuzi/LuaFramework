--[[
	文件名：KillerValleyRankLayer.lua
	文件描述：绝情谷排行榜页面
	创建人：yanghongsheng
	创建时间：2018.01.24
]]

local KillerValleyRankLayer = class("KillerValleyRankLayer", function()
	return display.newLayer()
end)

-- 分页类型
local PAGE_TYPE = {
	ourRank = 1, 	-- 个人排行
	ourReward = 2,	-- 个人奖励
}

-- 赛季类型
local SeasonType = {
    eNow = 0, -- 当前赛季
    eOld = 1, -- 上个赛季
}

-- 构造函数
function KillerValleyRankLayer:ctor()
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 当前页面类型
    self.mCurrSeletType = PAGE_TYPE.ourRank
    -- 赛季(默认当前赛季)
    self.mSeasonType = SeasonType.eNow
    -- 当前页数
    self.mCurrPage = 1
    -- 当前请求列表已经结束
    self.isRequestEnd = true

    -- 背景大小
    self.mBgSize = cc.size(627, 946)
    self.mViewSize = cc.size(563, 780)
    self.mCellSize = cc.size(563, 130)

    local popBgLayer = require("commonLayer.PopBgLayer").new({
        bgSize = self.mBgSize,
        title = TR("排行榜"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(popBgLayer)

    -- 背景对象
    self.mBgSprite = popBgLayer.mBgSprite

    -- 初始化页面控件
    self:initUI()
end

-- 初始化UI
function KillerValleyRankLayer:initUI()
	-- 背景
    local backImageSprite = ui.newScale9Sprite("c_17.png", cc.size(576, 790))
    backImageSprite:setAnchorPoint(cc.p(0.5, 0))
    backImageSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(backImageSprite)

    -- 暂无排行
    local tempSprite = ui.createEmptyHint(TR("暂无排行信息"))
    tempSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.5)
    self.mBgSprite:addChild(tempSprite)
    tempSprite:setVisible(false)
    self.mIsNoneSprite = tempSprite

    -- 创建个人排行
    self.myRankBg = ui.newScale9Sprite("c_25.png", cc.size(550, 54))
    self.myRankBg:setPosition(299, 50)
    self.mBgSprite:addChild(self.myRankBg)
    self.myRankLabel = ui.newLabel({
                text = TR("我的排名: #ffe289%s", TR("未上榜")),
                size = 22,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
    self.myRankLabel:setAnchorPoint(cc.p(0, 0.5))
    self.myRankLabel:setPosition(59, 27)
    self.myRankBg:addChild(self.myRankLabel)
    self.myScoreLabel = ui.newLabel({
                text = TR("积分: #ffe289%d", 0),
                size = 22,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
    self.myScoreLabel:setAnchorPoint(cc.p(0, 0.5))
    self.myScoreLabel:setPosition(250, 27)
    self.myRankBg:addChild(self.myScoreLabel)

    self:createTabView()
end

-- 分页初始化
--[[
    params: MsgBox DIYfunc 的回调参数
--]]
function KillerValleyRankLayer:createTabView()
    -- 创建Tab 按钮info
    local btnInfo = {
    	[1] = {
    		text = TR("个人排名"),
    		tag = PAGE_TYPE.ourRank,
    	},
    	[2] = {
    		text = TR("个人奖励"),
    		tag = PAGE_TYPE.ourReward,
    	}
	}

    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = btnInfo,
        viewSize = cc.size(500, 70),
        isVert = false,
        btnSize = cc.size(130, 50),
        space = 0,
        needLine = false,
        defaultSelectTag = PAGE_TYPE.ourRank,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
        	if self.mCurrSeletType == selectBtnTag then
        		return
        	end
            
        	self.mCurrSeletType = selectBtnTag

            self:refreshRanView()
        end
    })
    tabLayer:setAnchorPoint(cc.p(0, 1))
    tabLayer:setPosition(15, self.mBgSize.height - 65)
    self.mBgSprite:addChild(tabLayer)
    self.mTabLayer = tabLayer

    -- 初始化默认分页
    self:refreshRanView()
end

-- 刷新分页内容
function KillerValleyRankLayer:refreshRanView()
    if self.mCurLayer and not tolua.isnull(self.mCurLayer) then
        self.mCurLayer:setVisible(false)
    end

	if self.mCurrSeletType == PAGE_TYPE.ourRank then
        self.myRankBg:setVisible(true)
        self.mCurLayer = self:createRankLayer()
	elseif self.mCurrSeletType == PAGE_TYPE.ourReward then
        self.myRankBg:setVisible(false)
        self.mIsNoneSprite:setVisible(false)
		self.mCurLayer = self:createRewardLayer()
	end
end

-- 创建个人排行页面
function KillerValleyRankLayer:createRankLayer()
    -- 创建页面父节点
    if not self.mRankParent or tolua.isnull(self.mRankParent) then
        self.mRankParent = cc.Node:create()
        self.mRankParent:setPosition(0, 0)
        self.mBgSprite:addChild(self.mRankParent)

        -- 创建ListView
        local rankListView = ccui.ListView:create()
        rankListView:setContentSize(cc.size(self.mViewSize.width, self.mViewSize.height-50))
        rankListView:setAnchorPoint(cc.p(0.5, 0))
        rankListView:setPosition(cc.p(self.mBgSize.width * 0.5, 85))
        rankListView:setItemsMargin(5)
        rankListView:setDirection(ccui.ListViewDirection.vertical)
        rankListView:setBounceEnabled(true)
        self.mRankParent:addChild(rankListView)

        -- 请求数据，添加列表项
        self:requestGetRankList()

        -- 注册滑动到列表底部监听，获取下一页
        rankListView:addScrollViewEventListener(function(sender, eventType)
            if eventType == 6 then -- 触发底部弹性事件(BOUNCE__BOTTOM)
                if self.mCurrPage < (self.mTotalPage or 0) and self.isRequestEnd then
                    self.mCurrPage = self.mCurrPage + 1
                    -- 请求数据，添加列表项
                    self.isRequestEnd = false
                    self:requestGetRankList()
                end
            end
        end)

        -- 添加列表项函数
        self.mRankParent.addListItems = function (RankList)
            if not RankList or not next(RankList) then
                return
            end

            for _, rankInfo in ipairs(RankList) do
                local cellItem = self:createRankItem(rankInfo)
                rankListView:pushBackCustomItem(cellItem)
            end

            -- 将列表跳到当前排名处
            ui.setListviewItemShow(rankListView, RankList[1].Rank)
        end
    end

    self.mIsNoneSprite:setVisible(self.isEmpty)

    self.mRankParent:setVisible(true)

    return self.mRankParent
end

-- 添加排名列表项
function KillerValleyRankLayer:addListItems(RankList)
    if self.mRankParent and not tolua.isnull(self.mRankParent) then
        self.mRankParent.addListItems(RankList)
    end
end

-- 创建个人奖励页面
function KillerValleyRankLayer:createRewardLayer()
    -- 创建页面父节点
    if not self.mRewardParent or tolua.isnull(self.mRewardParent) then
        self.mRewardParent = cc.Node:create()
        self.mRewardParent:setPosition(0, 0)
        self.mBgSprite:addChild(self.mRewardParent)

        -- 创建ListView
        local rewardListView = ccui.ListView:create()
        rewardListView:setContentSize(self.mViewSize)
        rewardListView:setAnchorPoint(cc.p(0.5, 0))
        rewardListView:setPosition(cc.p(self.mBgSize.width * 0.5, 35))
        rewardListView:setItemsMargin(5)
        rewardListView:setDirection(ccui.ListViewDirection.vertical)
        rewardListView:setBounceEnabled(true)
        self.mRewardParent:addChild(rewardListView)

        local rankData = clone(KillervalleyRankRewardRelation.items)
        -- 整理数据
        local tempList = {}
        for rankMin, rewardData in pairs(rankData) do
            for rankMax, rewardInfo in pairs(rewardData) do
                table.insert(tempList, rewardInfo)
            end
        end
        -- 排序
        rankData = tempList
        table.sort(rankData, function (item1, item2)
            return item1.rankMin < item2.rankMin
        end)
        -- 刷新列表
        for i, rewardInfo in ipairs(rankData) do
            local cellItem = self:createRewardItem(rewardInfo)
            rewardListView:pushBackCustomItem(cellItem)
        end
    end

    self.mRewardParent:setVisible(true)

    return self.mRewardParent
end

-- 创建排名项
function KillerValleyRankLayer:createRankItem(info)
    local cellSize = cc.size(self.mCellSize.width, 140)
    local cellItem = ccui.Layout:create()
    cellItem:setContentSize(cellSize)

    local rankSpriteList = {
        "c_44.png",
        "c_45.png",
        "c_46.png",
    }

    -- 添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", cellSize)
    backImageSprite:setAnchorPoint(cc.p(0.5, 0.5))
    backImageSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    cellItem:addChild(backImageSprite)

    -- 排名
    local rankTexture = rankSpriteList[info.Rank] or "c_47.png"
    local rankText = rankSpriteList[info.Rank] and "" or tostring(info.Rank)
    local rankNode = ui.createSpriteAndLabel({
            imgName = rankTexture,
            labelStr = rankText,
            fontSize = 20,
            outlineColor = Enums.Color.eOutlineColor,
        })
    rankNode:setPosition(50, cellSize.height / 2)
    cellItem:addChild(rankNode)

    if info.HeadImageId == 0 then
        info.HeadImageId = 12010001
    end

    -- 创建头像
    local headCard = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = info.HeadImageId,
        fashionModelID = info.FashionModelId,
        IllusionModelId = info.IllusionModelId,
        pvpInterLv = info.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        allowClick = false,
    })
    headCard:setPosition(cellSize.width*0.25, cellSize.height*0.55)
    cellItem:addChild(headCard)

    -- 玩家名
    local nameColor = Utility.getQualityColor(Utility.getQualityByModelId(info.HeadImageId), 1)
    local nameLabel = ui.newLabel({
            text = info.PlayerName,
            color = nameColor,
            outlineColor = Enums.Color.eOutlineColor,
            size = 25,
        })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(cellSize.width*0.35+5, cellSize.height*0.8)
    cellItem:addChild(nameLabel)

    -- 服务器名称
    local serverNameLabel = ui.newLabel({
        text = TR("区服: %s%s", Enums.Color.eNormalYellowH, info.Zone),
        color = Enums.Color.eBlack,
        anchorPoint = cc.p(0, 0.5),
        x = cellSize.width*0.35+5,
        y = cellSize.height * 0.55,
    })
    cellItem:addChild(serverNameLabel)

    -- 获得积分
    local score = ui.newLabel({
            text = TR("获得积分: #d17b00%d", info.SeasonFightScore),
            color = Enums.Color.eBlack,
            anchorPoint = cc.p(0, 0.5),
            x = cellSize.width*0.35+5,
            y = cellSize.height * 0.3,
        })
    cellItem:addChild(score)

    -- 胜场
    local winLabel = ui.newLabel({
            text = TR("胜: #249029%d", info.SeasonWinCount),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            size = 25,
            x = cellSize.width*0.75,
            y = cellSize.height * 0.8,
        })
    cellItem:addChild(winLabel)

    -- 负场
    local loseNum = info.SeasonChallengeNum-info.SeasonWinCount
    local loseLabel = ui.newLabel({
            text = TR("负: #44AC06%d", loseNum >= 0 and loseNum or 0),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            size = 25,
            x = cellSize.width*0.75,
            y = cellSize.height * 0.55,
        })
    cellItem:addChild(loseLabel)

    -- 胜率
    local winRatio = ui.newLabel({
            text = TR("胜率: #44AC06%d%%", info.WinRatio*100),
            color = Enums.Color.eBlack,
            anchorPoint = cc.p(0, 0.5),
            size = 25,
            x = cellSize.width*0.75,
            y = cellSize.height * 0.2,
        })
    cellItem:addChild(winRatio)

    return cellItem
end

-- 创建奖励项
function KillerValleyRankLayer:createRewardItem(info)
    local cellItem = ccui.Layout:create()
    cellItem:setContentSize(self.mCellSize)

    local rankSpriteList = {
        "c_44.png",
        "c_45.png",
        "c_46.png",
    }

    -- 添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", self.mCellSize)
    backImageSprite:setAnchorPoint(cc.p(0.5, 0.5))
    backImageSprite:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    cellItem:addChild(backImageSprite)

    -- 排名
    local rankSprite = "c_47.png"
    local rankText = info.rankMin .. "~" .. info.rankMax
    if info.rankMin == info.rankMax and rankSpriteList[info.rankMin] then
        rankSprite = rankSpriteList[info.rankMin]
        rankText = ""
    end
    local rankNode = ui.createSpriteAndLabel({
            imgName = rankSprite,
            labelStr = rankText,
            fontSize = 18,
            outlineColor = Enums.Color.eOutlineColor,
        })
    rankNode:setPosition(80, self.mCellSize.height / 2)
    cellItem:addChild(rankNode)

    -- 奖励
    local rewardInfo = Utility.analysisStrResList(info.reward)
    for k, v in pairs(rewardInfo) do
    	v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
    end

    local cardList = ui.createCardList({
    	maxViewWidth = self.mCellSize.width*0.7,
    	cardDataList = rewardInfo,
        isSwallow = false,
    })
    cardList:setAnchorPoint(cc.p(0, 0.5))
    cardList:setPosition(150, self.mCellSize.height / 2)
    cellItem:addChild(cardList)

    return cellItem
end


-- ================== 请求服务器数据相关函数 ===================
-- 请求排行榜数据
function KillerValleyRankLayer:requestGetRankList()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "KillerValley",
        methodName = "GetPersonRankTotalPage",
        svrMethodData = {self.mSeasonType, self.mCurrPage},
        callbackNode = self,
        callback = function(response)
            -- 请求数据结束
            self.isRequestEnd = true

            if not response or response.Status ~= 0 then
                return
            end
            -- 总页数
            self.mTotalPage = response.Value.TotalPage
            -- 排行数据
            local rankData = clone(response.Value.PageInfo)
            -- 玩家自己信息
            self.mOwnRankInfo = response.Value.MyRank or {}
            self.myRankLabel:setString(TR("我的排名: #ffe289%s", self.mOwnRankInfo.Rank and self.mOwnRankInfo.Rank~=0 and self.mOwnRankInfo.Rank or TR("未上榜")))
            self.myScoreLabel:setString(TR("#46220d积分: #ffe289%d  #46220d胜: #ffe289%d  #46220d负: #ffe289%d", 
                    self.mOwnRankInfo.SeasonFightScore or 0,
                    self.mOwnRankInfo.SeasonWinCount or 0,
                    (self.mOwnRankInfo.SeasonChallengeNum - self.mOwnRankInfo.SeasonWinCount) or 0
                ))

            -- 添加列表项
            if rankData and next(rankData) then
                local tempList = {}
                for _, rankInfo in pairs(rankData) do
                    table.insert(tempList, rankInfo)
                end
                rankData = tempList
                -- 排序
                table.sort(rankData, function (item1, item2)
                    return item1.Rank < item2.Rank
                end)
                
                self:addListItems(rankData or {})
            else
                self.isEmpty = true
                self.mIsNoneSprite:setVisible(true)
            end
        end,
    })
end

return KillerValleyRankLayer