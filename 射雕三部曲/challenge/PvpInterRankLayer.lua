--[[
	文件名：PvpInterRankLayer.lua
	文件描述：浑源之战排行榜页面
	创建人：chenqiang
	创建时间：2017.07.31
]]

local PvpInterRankLayer = class("PvpInterRankLayer", function()
	return display.newLayer()
end)

-- 分页类型
local PAGE_TYPE = {
	ourRank = 1, 	-- 个人排行
	ourReward = 2,	-- 个人奖励
}

-- 构造函数
function PvpInterRankLayer:ctor()
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 当前页面类型
    self.mCurrSeletType = PAGE_TYPE.ourRank
    -- 背景大小
    self.mBgSize = cc.size(627, 946)
    self.mViewSize = cc.size(576, 780)
    self.mCellSize = cc.size(576, 130)

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

    self:requestGetRankList()
end

-- 初始化UI
function PvpInterRankLayer:initUI()
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

    -- 提示
    local tipsLabel = ui.newLabel({
    	text = TR("               每14天为一个赛季\n赛季结束日23点-24点结算排名奖励"),
        color = Enums.Color.eBlack,
        size  = 19,
    })
    tipsLabel:setPosition(self.mBgSize.width * 0.7, self.mBgSize.height - 100)
    self.mBgSprite:addChild(tipsLabel)
    tipsLabel:setVisible(false)
    self.mTipsLabel = tipsLabel

    -- 创建ListView
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(self.mViewSize)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(cc.p(self.mBgSize.width * 0.5, 35))
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mBgSprite:addChild(self.mListView)
    -- 创建个人排行
    self.myRankBg = ui.newScale9Sprite("c_25.png", cc.size(550, 54))
    self.myRankBg:setPosition(299, 50)
    self.mBgSprite:addChild(self.myRankBg)
    self.myRankLabel = ui.newLabel({
                text = TR("我的排名: #ffe289%s", TR("未上榜")),
                size = 22,
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            })
    self.myRankLabel:setAnchorPoint(cc.p(0, 0.5))
    self.myRankLabel:setPosition(59, 27)
    self.myRankBg:addChild(self.myRankLabel)
    self.myScoreLabel = ui.newLabel({
                text = TR("积分: #ffe289%d", 0),
                size = 22,
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            })
    self.myScoreLabel:setAnchorPoint(cc.p(0, 0.5))
    self.myScoreLabel:setPosition(369, 27)
    self.myRankBg:addChild(self.myScoreLabel)

    self:createTabView()
end

-- 分页初始化
--[[
    params: MsgBox DIYfunc 的回调参数
--]]
function PvpInterRankLayer:createTabView()
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
end

-- 刷新分页内容
function PvpInterRankLayer:refreshRanView()
	if self.mCurrSeletType == PAGE_TYPE.ourRank then
		self.mTipsLabel:setVisible(false)
        self:refreshListViewForOurRank()
	elseif self.mCurrSeletType == PAGE_TYPE.ourReward then
        self.mIsNoneSprite:setVisible(false)
        self.mTipsLabel:setVisible(true)
		self:refreshListViewForOurReward()
	end
end

-- 刷新排行
function PvpInterRankLayer:refreshListViewForOurRank()
    self.mIsNoneSprite:setVisible(#self.mRankList.PVPinterTopRank <= 0)
	self.mListView:removeAllItems()

    local myInfo = nil
    local myPlayerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
	for index, item in ipairs(self.mRankList.PVPinterTopRank) do
        local cellItem = ccui.Layout:create()
        cellItem:setContentSize(self.mCellSize)
        self.mListView:pushBackCustomItem(cellItem)

        self:refreshRankItem(index, item)
        if item.PlayerId == myPlayerId then
            myInfo = item
        end
    end
    -- 显示个人排行
    self.myRankBg:setVisible(true)
    self.myRankLabel:setString(TR("我的排名: #ffe289%s", myInfo and tostring(myInfo.Rank) or TR("未上榜")))
    self.myScoreLabel:setVisible(myInfo ~= nil)
    if myInfo then
        self.myScoreLabel:setString(TR("积分: #ffe289%d", myInfo.Rate))
    end
    local offsetViewY = 51
    self.mListView:setContentSize(cc.size(self.mViewSize.width, self.mViewSize.height - offsetViewY))
    self.mListView:setPosition(cc.p(self.mBgSize.width * 0.5, 35 + offsetViewY))
end

-- 刷新个人奖励
function PvpInterRankLayer:refreshListViewForOurReward()
	self.mListView:removeAllItems()
    local rewardData = clone(PvpinterSeasonEndRewardModel.items)
    table.sort(rewardData, function(a, b)
        return a.state < b.state
    end)
	for index, item in ipairs(rewardData) do
        local cellItem = ccui.Layout:create()
        cellItem:setContentSize(self.mCellSize)
        self.mListView:pushBackCustomItem(cellItem)

        self:refreshRewardItem(index, item)
    end
    -- 隐藏个人排行
    self.myRankBg:setVisible(false)
    self.mListView:setContentSize(self.mViewSize)
    self.mListView:setPosition(cc.p(self.mBgSize.width * 0.5, 35))
end

-- 创建奖励
function PvpInterRankLayer:refreshRewardItem(index, info)
    local cellItem = self.mListView:getItem(index - 1)
    if not cellItem then
        cellItem = ccui.Layout:create()
        cellItem:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(cellItem, index - 1)
    end
    cellItem:removeAllChildren()

    -- 添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", cc.size(563, self.mCellSize.height))
    backImageSprite:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    cellItem:addChild(backImageSprite)

    local stateRelation = PvpinterStateRelation.items[index]
    -- 头像框
	local rankSprite = ui.newSprite(stateRelation.stateHeadFrame2 .. ".png")
	rankSprite:setPosition(self.mCellSize.width * 0.19, self.mCellSize.height * 0.5)
    rankSprite:setScale(0.45)
    cellItem:addChild(rankSprite)

    local rankSprite2 = ui.newSprite(stateRelation.stateHeadFrame1 .. ".png")
    rankSprite2:setPosition(self.mCellSize.width * 0.45, self.mCellSize.height * 0.5)
    cellItem:addChild(rankSprite2)

    -- 奖励
    local rewardInfo = Utility.analysisStrResList(info.reward)
    for k, v in pairs(rewardInfo) do
    	v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
    end

    local cardList = ui.createCardList({
    	maxViewWidth = 250,
    	space = 5,
    	cardDataList = rewardInfo
    })
    cardList:setAnchorPoint(cc.p(0, 0.5))
    cardList:setPosition(320, self.mCellSize.height / 2)
    cellItem:addChild(cardList)
end

-- 排行列表
function PvpInterRankLayer:refreshRankItem(index, info)
	local cellItem = self.mListView:getItem(index - 1)
    if not cellItem then
        cellItem = ccui.Layout:create()
        cellItem:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(cellItem, index - 1)
    end
    cellItem:removeAllChildren()

    --添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", cc.size(563, self.mCellSize.height))
    backImageSprite:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    cellItem:addChild(backImageSprite)

    -- 排名
    local imageData = {
        [1] = "c_44.png",
        [2] = "c_45.png",
        [3] = "c_46.png",
    }
    if imageData[info.Rank] then
        local rankSprite = ui.newSprite(imageData[info.Rank])
        rankSprite:setPosition(50, self.mCellSize.height / 2)
        cellItem:addChild(rankSprite)
    else
        local rankNumLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = info.Rank,
            fontSize = 30,
            fontColor = Enums.Color.eNormalWhite,
        })
        rankNumLabel:setPosition(50, self.mCellSize.height / 2)
        cellItem:addChild(rankNumLabel)
    end
    
    -- 头像
    local card = CardNode:create({allowClick = false})
    card:setHero({ModelId = info.HeadImageId, pvpInterLv = info.DesignationId, FashionModelID = info.FashionModelId, IllusionModelId = info.IllusionModelId}, {CardShowAttr.eBorder}, nil, info.FashionModelId)
    card:setPosition(140, self.mCellSize.height / 2)
    cellItem:addChild(card)

    -- 名字
    local tempColor = Utility.getQualityColor(Utility.getQualityByModelId(info.HeadImageId), 1)
    local nameLabel = ui.newLabel({
        text = info.Name,
        color = tempColor,
        outlineColor = Enums.Color.eOutlineColor,
        size = 25,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(200, self.mCellSize.height * 0.75)
    cellItem:addChild(nameLabel)

    -- 会员等级
    local vipNode = ui.createVipNode(info.Vip)
    vipNode:setPosition(nameLabel:getContentSize().width+10, nameLabel:getContentSize().height * 0.5 + 2)
    nameLabel:addChild(vipNode)

    -- 服务器名称
    local serverNameLabel = ui.newLabel({
        text = TR("服务器: %s%s", Enums.Color.eNormalYellowH, info.ServerName),
        color = Enums.Color.eBlack,
        anchorPoint = cc.p(0, 0.5),
        x = 200,
        y = self.mCellSize.height * 0.5,
    })
    cellItem:addChild(serverNameLabel)

    --境界
    local tmpstar = ""
    if info.PVPInterState == 6 then
        tempStr = string.format("%s%s%s%d%s", PvpinterStateRelation.items[info.PVPInterState].name,
            TR("境"), Enums.Color.eNormalYellowH, info.Rate, TR("积分"))
    else
        tempStr = string.format("%s%s%s%d%s%d%s", PvpinterStateRelation.items[info.PVPInterState].name, 
            TR("境"), Enums.Color.eNormalYellowH, info.PVPInterStep, TR("阶"), info.PVPInterStar, TR("星"))
    end
    local stateLabel = ui.newLabel({
        text = tempStr,
        color = Enums.Color.eBlack,
        anchorPoint = cc.p(0, 0.5),
        x = 200,
        y = self.mCellSize.height * 0.25,
    })
    cellItem:addChild(stateLabel)

    -- 查看阵容
    local checkBtn = ui.newButton({
    	text = TR("查看布阵"),
    	normalImage = "c_28.png",
    	clickAction = function()
            self:requestGetFormationForRank(info.PlayerId)
    	end
    })
    checkBtn:setPosition(self.mCellSize.width * 0.85, self.mCellSize.height / 2)
    cellItem:addChild(checkBtn)
end

--[[
    params:
        formation: 头像信息
        taoInfo: 道法信息
--]]
function PvpInterRankLayer:showCampLayer(formation, playerName, fashionId)
    local slotCount = 6
    local columnMaxCount = 3
    local rowCount = math.ceil(slotCount / columnMaxCount) + 1
    local originalPosX, originalPosY = 447, 440
    local deltaX, deltaY = 274, 135
    local function DIYFunc(layerObj, bgSprite, bgSize)
        for index = 1, slotCount do
            local x = originalPosX - deltaX * math.floor((index-1) / columnMaxCount)
            local y = originalPosY - deltaY * math.mod(index-1, columnMaxCount)
            local tempSize = cc.size(256, 122)
            -- 背景
            local tempSprite = ui.newScale9Sprite("c_18.png", tempSize)
            tempSprite:setPosition(x, y)
            bgSprite:addChild(tempSprite)

            local tmpBgSprite = ui.newSprite("zr_36.png")
            tmpBgSprite:setPosition(tempSize.width * 0.5, tempSize.height * 0.5)
            tempSprite:addChild(tmpBgSprite)

            -- 头像背景图片
            local heroHeadBgPic = ui.newScale9Sprite("c_83.png", cc.size(140, tempSize.height))
            heroHeadBgPic:setPosition(cc.p(70, tempSize.height * 0.5))
            tempSprite:addChild(heroHeadBgPic)

            -- 模板
            local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 128))
            stencilNode:setContentSize(cc.size(tempSize.width, tempSize.height + 10))
            stencilNode:setIgnoreAnchorPointForPosition(false)
            stencilNode:setAnchorPoint(cc.p(0.5, 0))
            stencilNode:setPosition(cc.p(72, 2))

            -- 创建剪裁
            local clipNode = cc.ClippingNode:create()
            clipNode:setAlphaThreshold(1.0)
            clipNode:setStencil(stencilNode)
            clipNode:setPosition(cc.p(0, 0))
            heroHeadBgPic:addChild(clipNode)

            -- 显示人物半身照
            local heroModelInfo = formation[index] or {}
            local heroModelKey = next(heroModelInfo) or "0"
            local heroModelId = tonumber(heroModelKey)
            if heroModelId == 0 then
                local figureNode = ui.newSprite("c_36.png")
                figureNode:setPosition(tempSize.width * 0.5, 30)
                figureNode:setScale(0.35)
                clipNode:addChild(figureNode)
            else
                local heroBase = HeroModel.items[heroModelId] or {}
                local illusionModelId = ConfigFunc:getIllusionModelId(heroModelInfo[heroModelKey])
                local heroFashionId = ConfigFunc:getHeroFashionModelId(heroModelInfo[heroModelKey])
                Figure.newHero({
                    parent = clipNode,
                    heroModelID = heroModelId,
                    fashionModelID = heroBase.specialType == Enums.HeroType.eMainHero and fashionId,
                    IllusionModelId = illusionModelId,
                    heroFashionId = heroFashionId,
                    position = cc.p(72, -140),
                    scale = 0.2,
                    async = function (figureNode)
                    end,
                })

                -- 显示人物名和等级突破
                local strName = heroBase.name
                if heroBase.specialType == Enums.HeroType.eMainHero then
                    strName = playerName
                elseif illusionModelId and illusionModelId > 0 then
                    strName = IllusionModel.items[illusionModelId].name
                end
                local heroName = ui.newLabel({
                    text = strName,
                    color = Utility.getQualityColor(heroBase.quality, 1),
                    outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                    outlineSize = 2,
                    size = 20,
                })
                heroName:setPosition(190, tempSize.height * 0.5)
                tempSprite:addChild(heroName)
            end
        end
    end
    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(620, 585),
        title = TR("布阵"),
        DIYUiCallback = DIYFunc,
    })
end

-- ================== 请求服务器数据相关函数 ===================
-- 请求排行榜数据
function PvpInterRankLayer:requestGetRankList()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "PVPinter",
        methodName = "GetPVPInterTopRank",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mRankList = response.Value or {}
        	table.sort(self.mRankList.PVPinterTopRank, function(a, b)
        		return a.Rank < b.Rank
        	end)
            self:refreshListViewForOurRank()
        end,
    })
end

-- 查看阵容
function PvpInterRankLayer:requestGetFormationForRank(playerID)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "PVPinter",
        methodName = "GetSlotFormations",
        svrMethodData = {playerID},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            
            local formationInfo = response.Value.FormationInfo
            self:showCampLayer(formationInfo, response.Value.Name, response.Value.FashionModelId)
        end,
    })
end

return PvpInterRankLayer