--[[
    文件名: JianghuKillRankLayer.lua
    描述: 江湖杀排行榜界面
    创建人: 杨宏生
    创建时间: 2018.09.25
-- ]]
local JianghuKillRankLayer = class("JianghuKillRankLayer", function(params)
	return display.newLayer()
end)

local BtnTags = {
	eRank = 1,
	eReward = 2,
}

--[[
	params:
		jobId 	玩家当前职业id
]]
function JianghuKillRankLayer:ctor(params)
	self.mJobId = params.jobId or 1
	self.mRankData = {}		-- 排行数据
	self.mRankPage = {}		-- 当前请求服务器页数
	self.mCurForceId = nil
	self.mTotalPage = {}	-- 排行榜总页数
	self.mRewardData = {}
	self.mMyRank = {}
	self.mEndTime = 0
	--屏蔽下层点击
    ui.registerSwallowTouch({node = self})

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

	self:initRewardData()
	self:initUI()

end

function JianghuKillRankLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("zdcj_09.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 列表背景
	local listBg = ui.newScale9Sprite("c_19.png", cc.size(640, 990))
	listBg:setAnchorPoint(cc.p(0.5, 0))
	listBg:setPosition(320, 0)
	self.mParentLayer:addChild(listBg)

	-- 退出按钮
	local closeBtn = ui.newButton({
			normalImage = "c_29.png",
			clickAction = function ()
				LayerManager.removeLayer(self)
			end
		})
	closeBtn:setPosition(595, 1050)
	self.mParentLayer:addChild(closeBtn)

	-- 创建列表
	local blackSize = cc.size(620, 725)
	local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
	blackBg:setPosition(320, 546)
	self.mParentLayer:addChild(blackBg)
	-- 排行列表
	self.mRankListView = ccui.ListView:create()
	self.mRankListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mRankListView:setBounceEnabled(true)
	self.mRankListView:setContentSize(cc.size(blackSize.width-10, blackSize.height-10))
	self.mRankListView:setItemsMargin(5)
	self.mRankListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mRankListView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mRankListView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
	blackBg:addChild(self.mRankListView)
	-- 注册滑动到列表底部监听，获取下一页
	self.isRequestEnd = true
	self.mRankListView:addScrollViewEventListener(function(sender, eventType)
	    if eventType == 6 then -- 触发底部弹性事件(BOUNCE__BOTTOM)
	        if (self.mRankPage[self.mCurForceId] or 0) < (self.mTotalPage[self.mCurForceId] or 1) and self.isRequestEnd then
	            -- 请求数据，添加列表项
	            self.isRequestEnd = false

	            self.mRankPage[self.mCurForceId] = self.mRankPage[self.mCurForceId] or 0
	            self.mRankPage[self.mCurForceId] = self.mRankPage[self.mCurForceId] + 1

	            self:requestRankInfo(self.mCurForceId)
	        end
	    end
	end)

	-- 添加列表项函数
	self.mRankListView.addListItems = function (target, RankList)
	    if not RankList or not next(RankList) then
	        return
	    end

	    for _, rankInfo in ipairs(RankList) do
	        local cellItem = self:createRankItem(rankInfo)
	        target:pushBackCustomItem(cellItem)
	    end

	    -- 将列表跳到当前排名处
	    ui.setListviewItemShow(target, RankList[1].Rank)
	end
	-- 奖励列表
	self.mRewardListView = ccui.ListView:create()
	self.mRewardListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mRewardListView:setBounceEnabled(true)
	self.mRewardListView:setContentSize(cc.size(blackSize.width-10, blackSize.height-10))
	self.mRewardListView:setItemsMargin(5)
	self.mRewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mRewardListView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
	blackBg:addChild(self.mRewardListView)
	-- 填充列表
	self:refreshRewardList()

	-- 胜利大奖页面
	self.mRewardLayer = self:createWinRewardLayer()

	-- 创建其他按钮
	self:createBtnList()

	-- 我的排名
	local rankBgSprite = ui.newScale9Sprite("c_25.png", cc.size(620, 55))
	rankBgSprite:setPosition(320, 140)
	self.mParentLayer:addChild(rankBgSprite)
	self.mMyRankBg = rankBgSprite

	self.mMyRankLabel = ui.newLabel({
			text = TR("我的排名："),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
	self.mMyRankLabel:setAnchorPoint(cc.p(0, 0.5))
	self.mMyRankLabel:setPosition(40, 27)
	rankBgSprite:addChild(self.mMyRankLabel)

	self.mMyJobLabel = ui.newLabel({
			text = TR("我的职业："),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
	self.mMyJobLabel:setAnchorPoint(cc.p(0, 0.5))
	self.mMyJobLabel:setPosition(260, 27)
	rankBgSprite:addChild(self.mMyJobLabel)

	self.mMyScoreLabel = ui.newLabel({
			text = TR("我的积分："),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
	self.mMyScoreLabel:setAnchorPoint(cc.p(0, 0.5))
	self.mMyScoreLabel:setPosition(410, 27)
	rankBgSprite:addChild(self.mMyScoreLabel)

	-- 创建空提示
	self.mEmptyHint = ui.createEmptyHint(TR("暂无排名数据"))
	self.mEmptyHint:setPosition(320, 568)
	self.mParentLayer:addChild(self.mEmptyHint)

	-- 创建赛季结束倒计时
	self.mTimeLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
	self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
	self.mTimeLabel:setPosition(300, 1000)
	self.mParentLayer:addChild(self.mTimeLabel)
end

function JianghuKillRankLayer:initRewardData()
	-- -- 排序
	local tempKeysList = table.keys(JianghukillRankModel.items)
	table.sort(tempKeysList, function(key1, key2)
		return key1 < key2
	end)

	self.mRewardData = {}
	for _, key in ipairs(tempKeysList) do
		table.insert(self.mRewardData, JianghukillRankModel.items[key])
	end
end

-- 创建赛季倒计时
function JianghuKillRankLayer:createTimeUpdate()
	if self.mTimeUpdate then
		self.mTimeLabel:stopAction(self.mTimeUpdate)
		self.mTimeUpdate = nil
	end

	self.mTimeUpdate = Utility.schedule(self.mTimeLabel, function ()
		local timeLeft = self.mEndTime - Player:getCurrentTime()
		if timeLeft > 0 then
			self.mTimeLabel:setString(TR("赛季结束倒计时：%s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
		else
			self.mTimeLabel:setString("")
			self.mTimeLabel:stopAction(self.mTimeUpdate)
			self.mTimeUpdate = nil
		end
	end, 1)
end

function JianghuKillRankLayer:createBtnList()
	local btnList = {
		-- 排行
		{
			normalImage = "tb_16.png",
			position = cc.p(70, 1030),
			tag = BtnTags.eRank,
		},
		-- 奖励
		{
			normalImage = "tb_179.png",
			position = cc.p(170, 1030),
			tag = BtnTags.eReward,
		},
	}

	for i, btnInfo in ipairs(btnList) do
		btnInfo.clickAction = function ()
			-- tabView显示/隐藏
			if self.mCurTabView then
				self.mCurTabView:setVisible(false)
			end

			self.mCurTabView = self:createTabView(btnInfo.tag)
			self.mCurTabView:setVisible(true)

			-- ListView显示/隐藏
			self.mRankListView:setVisible(false)
			self.mRewardListView:setVisible(false)
			self.mRewardLayer:setVisible(false)
			if btnInfo.tag == BtnTags.eRank then
				self.mRankListView:setVisible(true)
			else
				if self.mCurTabView:getCurrTag() == 1 then -- 排行奖励
					self.mRewardListView:setVisible(true)
				else
					self.mRewardLayer:setVisible(true)
				end
			end

			-- 隐藏空显示
			if self.mEmptyHint then
				if btnInfo.tag == BtnTags.eRank and not next(self.mRankData[self.mCurForceId]) then
					self.mEmptyHint:setVisible(true)
				else
					self.mEmptyHint:setVisible(false)
				end
			end
		end

		local tempBtn = ui.newButton(btnInfo)
		self.mParentLayer:addChild(tempBtn)

		-- 刷新排行
		if btnInfo.tag == BtnTags.eRank then
			tempBtn.mClickAction()
		end
	end
end

-- 创建tabview
function JianghuKillRankLayer:createTabView(tag)
	self.mTabList = self.mTabList or {}
	if not self.mTabList[tag] then
		local tabInfoList = {
			[BtnTags.eRank] = {
				{
					text = Enums.JHKCampName[Enums.JHKCampType.eWulinmeng],
					tag = Enums.JHKCampType.eWulinmeng,
				},
				{
					text = Enums.JHKCampName[Enums.JHKCampType.eHuntianjiao],
					tag = Enums.JHKCampType.eHuntianjiao,
				}
			},
			[BtnTags.eReward] = {
				{
					text = TR("排行奖励"),
					tag = 1,
				},
				{
					text = TR("赛季大奖"),
					tag = 2,
				}
			},
		}
		-- 清除势力排行
		tabInfoList[BtnTags.eRank] = {}
		-- 添加职业排行
		for _, jobInfo in ipairs(JianghukillJobModel.items) do
			local jobTab = {text = jobInfo.name, tag = jobInfo.ID}
			table.insert(tabInfoList[BtnTags.eRank], jobTab)
		end
		self.mTabList[tag] = ui.newTabLayer({
	        btnInfos = tabInfoList[tag],
	        isVert = false,
	        needLine = false,
	        defaultSelectTag = tag == BtnTags.eRank and self.mJobId or tabInfoList[tag][1].tag,
	        allowChangeCallback = function(btnTag)
	            return true
	        end,
	        onSelectChange = function(selectBtnTag)
	            self.mSelectedBtn = selectBtnTag
	            if self.mEmptyHint then
	            	self.mEmptyHint:setVisible(false)
	            end
	            if BtnTags.eRank == tag then
	            	self.mCurForceId = selectBtnTag
	                self:refreshRankList(selectBtnTag)
	            elseif BtnTags.eReward == tag then
	            	self.mRewardListView:setVisible(false)
	            	self.mRewardLayer:setVisible(false)
	            	if selectBtnTag == 1 then -- 排行奖励
		                self.mRewardListView:setVisible(true)
	                else
	                	-- self.mRewardListView:removeAllChildren()
	                	self.mRewardLayer:setVisible(true)
	                end
	            end
	        end
        })
        self.mTabList[tag]:setPosition(320, 940)
        self.mParentLayer:addChild(self.mTabList[tag])
	end

	return self.mTabList[tag]
end

function JianghuKillRankLayer:createWinRewardLayer()
	local winRewardLayer = cc.Node:create()
	winRewardLayer:setPosition(0, 0)
	self.mParentLayer:addChild(winRewardLayer)

	-- 提示
	local hintLabel = ui.newLabel({
			text = TR("本赛季至少获得%s荣誉点的玩家才能获取赛季大奖", JianghukillModel.items[1].seasonRewardMin),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
	hintLabel:setPosition(320, 850)
	winRewardLayer:addChild(hintLabel)
	-- 创建大奖显示
	local function createRewardShow(bgImage, hintStr, rewardStr)
		local bgSprite = ui.newSprite(bgImage)
		local bgSize = bgSprite:getContentSize()
		-- 提示背景
		local hintBgSize = cc.size(560, 50)
		local hintBg = ui.newScale9Sprite("c_25.png", hintBgSize)
		hintBg:setPosition(bgSize.width*0.5, 175)
		bgSprite:addChild(hintBg)
		-- 提示文字
		local hintLabel = ui.newLabel({
				text = hintStr,
				color = Enums.Color.eWhite,
				outlineColor = Enums.Color.eOutlineColor,
			})
		hintLabel:setPosition(hintBgSize.width*0.5, hintBgSize.height*0.5)
		hintBg:addChild(hintLabel)
		-- 奖励列表
		local rewardList = Utility.analysisStrResList(rewardStr)
		local resListView = ui.createCardList({
				maxViewWidth = 530,
				cardDataList = rewardList,
				space = 0,
			})
		resListView:setAnchorPoint(cc.p(0.5, 0.5))
		resListView:setPosition(bgSize.width*0.5, 80)
		bgSprite:addChild(resListView)

		return bgSprite
	end
	-- 胜利奖励
	local winReward = createRewardShow("jhs_127.png", TR("赛季结束后发放到获胜势力符合要求的玩家"), JianghukillModel.items[1].seasonWinReward)
	winReward:setPosition(320, 650)
	winRewardLayer:addChild(winReward)
	-- 参与奖励
	local loseReward = createRewardShow("jhs_128.png", TR("赛季结束后发放到失败势力符合要求的玩家"), JianghukillModel.items[1].seasonLoseReward)
	loseReward:setPosition(320, 340)
	winRewardLayer:addChild(loseReward)

	return winRewardLayer
end

function JianghuKillRankLayer:refreshRankList(tag)
	self.mRankListView:removeAllChildren()

	if self.mRankData[tag] then
		if next(self.mRankData[tag]) then
			for i, rankInfo in ipairs(self.mRankData[tag]) do
				local item = self:createRankItem(rankInfo)
				self.mRankListView:pushBackCustomItem(item)
			end
		else
			-- 显示空
        	self.mEmptyHint:setVisible(true)
	    end
	else
		self:requestRankInfo(tag)
	end

end

function JianghuKillRankLayer:refreshRewardList()
	self.mRewardListView:removeAllChildren()

	for i, _ in ipairs(self.mRewardData) do
		local item = self:createRewardItem(i)
		self.mRewardListView:pushBackCustomItem(item)
	end

	self.mRewardListView:jumpToTop()
end

function JianghuKillRankLayer:createRankItem(info)
	local cellSize = cc.size(self.mRankListView:getContentSize().width, 140)
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
	    pvpInterLv = info.PVPInterLv,
	    cardShowAttrs = {CardShowAttr.eBorder},
	    allowClick = false,
	})
	headCard:setPosition(cellSize.width*0.25, cellSize.height*0.55)
	cellItem:addChild(headCard)

	-- 玩家名
	local forceTexture = Enums.JHKSamllPic[info.CampId]
	local nameColor = Utility.getQualityColor(Utility.getQualityByModelId(info.HeadImageId), 1)
	local nameLabel = ui.newLabel({
	        text = forceTexture and "{"..forceTexture.."}"..info.Name or info.Name,
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
	        text = TR("获得荣誉点: #d17b00%s", Utility.numberWithUnit(info.Glory)),
	        color = Enums.Color.eBlack,
	        anchorPoint = cc.p(0, 0.5),
	        x = cellSize.width*0.35+5,
	        y = cellSize.height * 0.3,
	    })
	cellItem:addChild(score)

	-- 战力
	local winLabel = ui.newLabel({
	        text = TR("战力: #249029%s", Utility.numberFapWithUnit(info.Fap)),
	        color = cc.c3b(0x46, 0x22, 0x0d),
	        anchorPoint = cc.p(0, 0.5),
	        x = cellSize.width*0.7,
	        y = cellSize.height * 0.3,
	    })
	cellItem:addChild(winLabel)

	return cellItem
end

function JianghuKillRankLayer:createRewardItem(index)
	local rewardInfo = self.mRewardData[index]
	local rewardStr = rewardInfo.reward

	local cellSize = cc.size(self.mRewardListView:getContentSize().width, 140)
	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	local rankSpriteList = {
        "c_44.png",
        "c_45.png",
        "c_46.png",
    }

    -- 添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", cellSize)
    backImageSprite:setAnchorPoint(cc.p(0.5, 0.5))
    backImageSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    layout:addChild(backImageSprite)

    -- 排名
    local rankTexture = ""
    local rankText = ""
    if rewardInfo.rankMin == rewardInfo.rankMax then
	    rankTexture = rankSpriteList[rewardInfo.rankMin] or "c_47.png"
	    rankText = rankSpriteList[rewardInfo.rankMin] and "" or tostring(rewardInfo.rankMin)
	else
		rankTexture = "c_47.png"
		rankText = rewardInfo.rankMax .. "~" .. rewardInfo.rankMin
	end
	local rankNode = ui.createSpriteAndLabel({
            imgName = rankTexture,
            labelStr = rankText,
            fontSize = 20,
            outlineColor = Enums.Color.eOutlineColor,
        })
    rankNode:setPosition(50, cellSize.height / 2)
    layout:addChild(rankNode)

    -- 创建列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setItemsMargin(10)
    listView:setBounceEnabled(true)
    listView:setSwallowTouches(false)
    listView:setContentSize(cc.size(cellSize.width*0.7, 140))
    listView:setAnchorPoint(cc.p(0, 0.5))
    listView:setPosition(120, cellSize.height / 2 + 10)
    layout:addChild(listView)

    local itemSize = cc.size(120, 140)

    -- 称号奖励
    local jobTitleList = Utility.analysisStrAttrList(rewardInfo.designationShow)
    if jobTitleList and next(jobTitleList) then
    	local titleId = nil
    	for _, jobTitleInfo in pairs(jobTitleList) do
    		if jobTitleInfo.fightattr == self.mJobId then
    			titleId = jobTitleInfo.value
    			break
    		end
    	end
		-- 列表项
		local itemLayout = ccui.Layout:create()
		itemLayout:setContentSize(itemSize)
		listView:pushBackCustomItem(itemLayout)

		local stateRelaition = DesignationPicRelation.items[titleId]
		if stateRelaition and stateRelaition.pic ~= "" then
		    local pvpInterImg = ui.newSprite(stateRelaition.pic .. ".png")
		    pvpInterImg:setPosition(itemSize.width / 2, itemSize.height / 2)
		    pvpInterImg:setScale(0.85)
		    itemLayout:addChild(pvpInterImg)
		end
		if stateRelaition and stateRelaition.effectCode ~= "" then
		    ui.newEffect({
		        parent = itemLayout,
		        effectName = stateRelaition.effectCode,
		        position = cc.p(itemSize.width / 2, itemSize.height / 2),
		        loop = true,
		        endRelease = true,
		        scale = 0.85,
		    })
		end 
    end

    -- 资源奖励
    local rewardList = Utility.analysisStrResList(rewardStr)
    for k, v in pairs(rewardList) do
    	-- 列表项
    	local itemLayout = ccui.Layout:create()
    	itemLayout:setContentSize(itemSize)
    	listView:pushBackCustomItem(itemLayout)
    	-- 创建卡牌
    	v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
    	local card = CardNode.createCardNode(v)
    	card:setPosition(itemSize.width / 2, itemSize.height / 2)
    	itemLayout:addChild(card)
    end

	return layout
end

--===================================网络相关===================================
-- 排行信息
function JianghuKillRankLayer:requestRankInfo(forceId)
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "GetRank",
        svrMethodData = {forceId, self.mRankPage[forceId] or 0},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.isRequestEnd = true
            self.mEndTime = response.Value.EndTime or 0

            local rankInfo = response.Value.RankInfo
            self.mMyRank = response.Value.Rank
            self.mTotalPage[forceId] = response.Value.TotalPage < 4 and response.Value.TotalPage or 4
            -- 排序
            table.sort(rankInfo, function (item1, item2)
            	return item1.Rank < item2.Rank
        	end)
            -- 添加到列表
            self.mRankListView:addListItems(rankInfo)
            -- 添加页面缓存
            self.mRankData[forceId] = self.mRankData[forceId] or {}
            for _, rankItem in ipairs(rankInfo) do
            	table.insert(self.mRankData[forceId], rankItem)
	        end

	        -- 我的排名
	        self.mMyRankLabel:setString(TR("我的排名：%s", self.mMyRank and self.mMyRank.Rank ~= 0 and self.mMyRank.Rank or TR("未上榜")))
	        self.mMyScoreLabel:setString(TR("荣誉点：%s", self.mMyRank and Utility.numberWithUnit(self.mMyRank.Glory or 0)))
	        self.mMyJobLabel:setString(TR("职业：%s", self.mMyRank and JianghukillJobModel.items[self.mMyRank.Type].name or "nil"))

	        -- 显示空
	        if not next(self.mRankData[forceId]) then
	        	self.mEmptyHint:setVisible(true)
	        else
	        	self.mEmptyHint:setVisible(false)
	        end
	        -- 赛季倒计时
	        self:createTimeUpdate()
        end
    })
end

return JianghuKillRankLayer