--[[
    文件名: TopChallengeLayer.lua
	描述: 巅峰挑战
	创建人: lengjiazhi
	创建时间: 2017.09.22
-- ]]
local TopChallengeLayer = class("TopChallengeLayer", function (params)
	return display.newLayer()
end)

function TopChallengeLayer:ctor()

	ui.registerSwallowTouch({node = self})
	self.mSelectId = 1
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefreshLayer = ui.newStdLayer()
	self:addChild(self.mRefreshLayer)

	self:initUI()
	self:createDaysBtns()
	self:createBottomView()
end

function TopChallengeLayer:onEnterTransitionFinish()
	local activityInfo = ActivityObj:getActivityItem(ModuleSub.eTimedChallenge)[1]
	if activityInfo and Player:getCurrentTime() > activityInfo.EndDate then
		LayerManager.removeLayer(self)
		-- 打开排行榜
		self:openRankShow(true)
	else
	    self:requestGetInfo()
	end
end

function TopChallengeLayer:openRankShow(isCleanUp)
	LayerManager.addLayer({
		name = "activity.CommonActivityRankLayer",
        data = {
            moduleName = "TimedScore",
            methodNameRank = "GetTotalRank",
            methodNameReward = "GetTotalRankReward",
            scoreName = TR("积分"),
        },
		cleanUp = isCleanUp,
	})
end

function TopChallengeLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("jrhd_93.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1075),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(55, 1075),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.巅峰挑战活动一天一轮，为单服比拼，根据排名发放奖励。"),
                [2] = TR("2.巅峰挑战采用挑战形式，完成当日指定挑战可获得积分。"),
                [3] = TR("3.玩家每轮的积分会累计，然后参与总榜排名"),
                [4] = TR("4.全服比拼根据总积分高低进行排名，每小时刷新一次。"),
                [5] = TR("5.每轮达到一定积分可领取积分宝箱。"),
                [6] = TR("6.结算前5分钟不会获得积分。"),
                [7] = TR("7.每充值20元宝获得1积分。"),
                [8] = TR("8.单服排行榜上榜积分，最低为100积分。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    --排行榜
    local rankBtn = ui.newButton({
    	normalImage = "tb_216.png",
    	position = cc.p(55, 707),
    	clickAction = function()
    		self:openRankShow(false)
    	end
    	})
    self.mParentLayer:addChild(rankBtn)

    --宝箱
    local boxBtn = ui.newButton({
    	normalImage = "tb_260.png",
    	position = cc.p(55, 617),
    	clickAction = function()
    		self:createBoxPop()
    	end
    	})
    self.mParentLayer:addChild(boxBtn)
    self.mBoxBtn = boxBtn

    --倒计时背景
    -- local timeBgSprite = ui.newSprite("jrhd_91.png")
    -- timeBgSprite:setPosition(504, 610)
    -- self.mParentLayer:addChild(timeBgSprite)

    --本轮倒计时
    local todayEndLabel = ui.newLabel({
    	text = TR("本轮结算倒计时:#ff720010天00:00:00"),
        outlineColor = Enums.Color.eBlack,
    	size = 18,
    	})
    todayEndLabel:setAnchorPoint(0, 0.5)
    todayEndLabel:setPosition(396, 620)
    self.mParentLayer:addChild(todayEndLabel)
    self.mTodayEndLabel = todayEndLabel

    --活动倒计时
    local activityEndLabel = ui.newLabel({
    	text = TR("活动结算倒计时:#ffea0010天00:00:00"),
    	size = 18,
        outlineColor = Enums.Color.eBlack,
    	})
    activityEndLabel:setAnchorPoint(0, 0.5)
    activityEndLabel:setPosition(396, 595)
    self.mParentLayer:addChild(activityEndLabel)
    self.mActivityEndLabel = activityEndLabel
end

-- 更新时间
function TopChallengeLayer:updateTime()
    local timeLeft = self.mActivityEndTime - Player:getCurrentTime()
    local timeLeftToday = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mActivityEndLabel:setString(TR("活动结算倒计时:#ffea00%s",MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mActivityEndLabel:setString(TR("活动结算倒计时:#ffea00 00:00:00"))
        self.mTodayEndLabel:setString(TR("本轮结算倒计时:#ff7200 00:00:00"))
        
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        LayerManager.removeLayer(self)
    end
    if timeLeftToday > 0 then
        self.mTodayEndLabel:setString(TR("本轮结算倒计时:#ff7200%s",MqTime.formatAsDay(timeLeftToday)))
    else
    	-- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        self:requestGetInfo()
    end
end

local btnPosList = {
	[1] = {
		pos = cc.p(515, 898),
		picLight = "jrhd_71.png",
		picNormal = "jrhd_77.png",
		},
	[2] = {
		pos = cc.p(450, 828),
		picLight = "jrhd_72.png",
		picNormal = "jrhd_78.png",
		},
	[3] = {
		pos = cc.p(580, 828),
		picLight = "jrhd_73.png",
		picNormal = "jrhd_79.png",
		},
	[4] = {
		pos = cc.p(515, 760),
		picLight = "jrhd_74.png",
		picNormal = "jrhd_80.png",
		},
	[5] = {
		pos = cc.p(450, 695),
		picLight = "jrhd_75.png",
		picNormal = "jrhd_81.png",
		},
	[6] = {
		pos = cc.p(580, 695),
		picLight = "jrhd_76.png",
		picNormal = "jrhd_82.png",
		},
	}

function TopChallengeLayer:createDaysBtns()
	self.mBtnList = {}
	for i,v in ipairs(btnPosList) do
		local btn = ui.newButton({
			normalImage = v.picNormal,
			position = v.pos,
			clickAction = function()
				if self.mSelectId == i then
					return
				end
				self:requestGetDailyInfo(i)
			end
			})
		self.mParentLayer:addChild(btn)
		table.insert(self.mBtnList, btn)
	end
end

--创建下方底板
function TopChallengeLayer:createBottomView()
	--下方背景板
	local bgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 440))
	bgSprite:setAnchorPoint(0.5, 0)
	bgSprite:setPosition(320, 0)
	self.mParentLayer:addChild(bgSprite)
	
	--灰色底板
	local garySprite = ui.newScale9Sprite("c_17.png", cc.size(604, 340))
	garySprite:setPosition(320, 225)
	self.mParentLayer:addChild(garySprite)
	
	--任务底板
	local goldBgSprite = ui.newScale9Sprite("qxp_10.png")
	goldBgSprite:setPosition(320, 505)
	self.mParentLayer:addChild(goldBgSprite)
	
	--任务图标
	local tipSprite = ui.newSprite("jrhd_70.png")
	tipSprite:setPosition(320, 568)
	self.mParentLayer:addChild(tipSprite)
	
	--个人信息底板
	local myInfoBgSprite = ui.newScale9Sprite("c_17.png", cc.size(650, 40))
	myInfoBgSprite:setPosition(320, 30)
	self.mParentLayer:addChild(myInfoBgSprite)

   --下方排行榜
    local rankListView = ccui.ListView:create()
    rankListView:setDirection(ccui.ScrollViewDir.vertical)
    rankListView:setBounceEnabled(true)
    rankListView:setContentSize(cc.size(600, 330))
    rankListView:setItemsMargin(5)
    rankListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rankListView:setAnchorPoint(cc.p(0.5, 0))
    rankListView:setPosition(320, 60)
    self.mParentLayer:addChild(rankListView)
    self.mRankListView = rankListView
end

--创建数据显示
function TopChallengeLayer:createInfoView()
	-- 滑动控件
    local listSize = cc.size(590, 120)
    local listView = ccui.ListView:create()
    listView:setItemsMargin(5)
    listView:setDirection(ccui.ListViewDirection.vertical)
    listView:setBounceEnabled(true)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(320, 480)
    self.mRefreshLayer:addChild(listView)

    -- --根据积分创建树的图片
    -- local treePic
    -- if self.mPlayerInfo.TotalScore >= 0 and self.mPlayerInfo.TotalScore < 1500 then
    --     treePic = "jrhd_94.png"
    -- elseif self.mPlayerInfo.TotalScore >= 1500 and self.mPlayerInfo.TotalScore < 3000 then
    --     treePic = "jrhd_97.png"
    -- elseif self.mPlayerInfo.TotalScore >= 3000 and self.mPlayerInfo.TotalScore < 5000 then
    --     treePic = "jrhd_96.png"
    -- elseif self.mPlayerInfo.TotalScore >= 5000 then
    --     treePic = "jrhd_95.png"
    -- end

    -- local treeSprite = ui.newSprite(treePic)
    -- treeSprite:setPosition(320, 568)
    -- self.mRefreshLayer:addChild(treeSprite)

    local maxHeight = 0
    for i, v in pairs(self.mTaskInfo) do
    	local ModelName = ModuleSubModel.items[v.Id].name
        local lvItem = ccui.Layout:create()
        local tempLabel = ui.newLabel({
            text = TR("%d.完成一次#00dc1a%s%s挑战  #ffc000+%s积分", i,ModelName, Enums.Color.eNormalWhiteH, v.Score),
            dimensions = cc.size(listSize.width, 0),
            outlineColor = cc.c3b(0x1e, 0x1e, 0x53),
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        local cellSize = tempLabel:getContentSize()
        tempLabel:setPosition(70, cellSize.height / 2)
        lvItem:addChild(tempLabel)

        lvItem:setContentSize(cellSize)
        listView:pushBackCustomItem(lvItem)

        maxHeight = maxHeight + cellSize.height + 5
    end

    if maxHeight < listSize.height then
        listView:setTouchEnabled(false)
    end
    listView:setContentSize(cc.size(listSize.width, math.min(maxHeight, listSize.height)))

    local myRankLabel = ui.newLabel({
    	text = TR("我的排名：%s%s", Enums.Color.eRedH, self.mPlayerInfo.MyRank == 0 and TR("未上榜") or self.mPlayerInfo.MyRank),
    	size = 21,
    	outlineColor = cc.c3b(0x1e, 0x1e, 0x53),
	})
	myRankLabel:setAnchorPoint(0, 0.5)
	myRankLabel:setPosition(40, 30)
	self.mRefreshLayer:addChild(myRankLabel)

	local myRankLabel = ui.newLabel({
    	text = TR("我的积分：%s%s", Enums.Color.eGreenH, self.mPlayerInfo.DailyScore),
    	size = 21,
    	outlineColor = cc.c3b(0x1e, 0x1e, 0x53),
	})
	myRankLabel:setAnchorPoint(0, 0.5)
	myRankLabel:setPosition(392, 30)
	self.mRefreshLayer:addChild(myRankLabel)
end

--创建宝箱弹窗
function TopChallengeLayer:createBoxPop()
	--弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 720),
        title = TR("积分宝箱"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(539, 560))
    grayBgSprite:setPosition(299, 372)
    self.mPopBgSprite:addChild(grayBgSprite)


    local onekeyBtn = ui.newButton({
    		normalImage = "c_33.png",
    		text = TR("一键领取"),
    		clickAction = function()
    			self:requestGetOneKeyReward()
    		end
    	})
    onekeyBtn:setPosition(299, 55)
    self.mPopBgSprite:addChild(onekeyBtn)


    -- 奖励列表控件
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(550, 545))
    rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0))
    rewardListView:setPosition(299, 102)
    self.mPopBgSprite:addChild(rewardListView)

    self.mGetBtnList = {}
    for i, v in ipairs(self.mRewardConfigList) do
    	local layout = ccui.Layout:create()
    	layout:setContentSize(550, 170)

    	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(530, 170))
    	bgSprite:setPosition(275, 85)
    	layout:addChild(bgSprite)

    	local getBtn = ui.newButton({
    		normalImage = "c_28.png",
    		text = TR("领取"),
    		clickAction = function(pSender)
    			pSender:setEnabled(false)
    			self:requestGetReward(v.Num, pSender)
    		end
    		})
    	getBtn:setPosition(460, 85)
    	layout:addChild(getBtn)
    	getBtn:setEnabled(false)
    	table.insert(self.mGetBtnList, getBtn)

    	if v.IsReward == 1 then
    		getBtn:setEnabled(true)
        elseif v.IsReward == 2 then
            getBtn:setTitleText(TR("已领取"))        
    	end

    	local rewardList = Utility.analysisStrResList(v.Reward)
        local cardList = ui.createCardList({
	        	maxViewWidth = 350	, -- 显示的最大宽度
		        viewHeight = 120, -- 显示的高度，默认为120
		        space = 10, -- 卡牌之间的间距, 默认为 10
		        cardDataList = rewardList
        	})
        cardList:setAnchorPoint(0, 0.5)
        cardList:setPosition(20, 70)
        layout:addChild(cardList)

        local tipLabel = ui.newLabel({
        	text = TR("积分达到%s", v.Num),
        	size = 22,
        	color = cc.c3b(0x46, 0x22, 0x0d),
        	})
        tipLabel:setAnchorPoint(0, 0.5)
        tipLabel:setPosition(20, 150)
        layout:addChild(tipLabel)

    	rewardListView:pushBackCustomItem(layout)
    end
end

--切换页签
function TopChallengeLayer:changeBtnState()
	for i,v in ipairs(self.mBtnList) do
		if i > self.mOrderId then
			v:setClickAction(function()

			end)
		else
			v:setClickAction(function()
				if self.mSelectId == i then
					return
				end
				self:requestGetDailyInfo(i)
			end)
		end

		if i == self.mSelectId then
			v:loadTextures(btnPosList[i].picLight, btnPosList[i].picLight)
		else
			v:loadTextures(btnPosList[i].picNormal, btnPosList[i].picNormal)
		end
	end
end

--刷新排行榜
function TopChallengeLayer:refreshRankView()
	self.mRankListView:removeAllChildren()

	for i,v in ipairs(self.mDailyRank) do
		local layout = ccui.Layout:create()
		layout:setContentSize(600, 124)

		--背景图
		local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(590, 124))
		bgSprite:setPosition(300, 62)
		layout:addChild(bgSprite)

		-- 排名
        local rankLabel = ui.createLabelWithBg({
            bgFilename = "c_47.png",
            labelStr = v.Rank,
            fontSize = 20,
            alignType = ui.TEXT_ALIGN_CENTER,
            outlineColor = Enums.Color.eBlack,
            -- offset = -5,
        })

        rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
        rankLabel:setPosition(cc.p(60, 65))
        layout:addChild(rankLabel)

        if v.Rank <= 3 then
            local picName = nil
            if v.Rank == 1 then
                picName = "c_44.png"
            elseif v.Rank == 2 then
                picName = "c_45.png"
            elseif  v.Rank == 3 then
                picName = "c_46.png"
            end

            local spr = ui.newSprite(picName)
            spr:setAnchorPoint(cc.p(0.5, 0.5))
            spr:setPosition(rankLabel:getPosition())
            layout:addChild(spr)
            -- spr:setScale(0.6)

            rankLabel:setVisible(false)
        end

        --头像
        local headCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = v.HeadImageId, 
            IllusionModelId = v.IllusionModelId,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        headCard:setPosition(160, 65)
        layout:addChild(headCard)

        --名字
        local nameLabel = ui.newLabel({
            text = v.PlayerName,
            color = cc.c3b(0xd1,0x7b, 0x00),
            size = 22,
            -- outlineColor = Enums.Color.eBlack
            })
        nameLabel:setAnchorPoint(0, 0.5)
        nameLabel:setPosition(220, 95)
        layout:addChild(nameLabel)

        --积分
        local scoreLabel = ui.newLabel({
            text = TR("积分：#249029%s#46220d", v.Score),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 21,
            })
        scoreLabel:setAnchorPoint(0, 0.5)
        scoreLabel:setPosition(220, 35)
        layout:addChild(scoreLabel)

        --等级
        local scoreLabel = ui.newLabel({
            text = TR("等级：#d17b00%s", v.Lv),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 21,
            })
        scoreLabel:setAnchorPoint(0, 0.5)
        scoreLabel:setPosition(220, 65)
        layout:addChild(scoreLabel)

        local rewardList = Utility.analysisStrResList(v.Reward)
        for i,v in ipairs(rewardList) do
        	v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        end
        local cardList = ui.createCardList({
	        	maxViewWidth = 210	, -- 显示的最大宽度
		        viewHeight = 100, -- 显示的高度，默认为120
		        space = 3, -- 卡牌之间的间距, 默认为 10
		        cardDataList = rewardList
        	})
        cardList:setAnchorPoint(0, 0.5)
        cardList:setPosition(365, 62)
        layout:addChild(cardList)

	    self.mRankListView:pushBackCustomItem(layout)
	end
end

--刷新宝箱状态
function TopChallengeLayer:refreshBoxState()
	if self.mBoxBtn.flashNode then
		self.mBoxBtn:stopAllActions()
        self.mBoxBtn.flashNode:removeFromParent()
        self.mBoxBtn.flashNode = nil
        self.mBoxBtn:setRotation(0)
    end
    if self.mCanReward then
    	ui.setWaveAnimation(self.mBoxBtn)
    end
end
--=======================================网络请求========================================
--请求信息
function TopChallengeLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedScore", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "ReceiveReward")
	        self.mRefreshLayer:removeAllChildren()

	        self.mOrderId = data.Value.OrderId
	        self.mTaskInfo = data.Value.ModuleId
	        self.mCanReward = data.Value.CanReward
	        self.mActivityEndTime = data.Value.ActivityEndTime
	        self.mPlayerInfo = data.Value.PlayerInfo
	        self.mDailyRank = data.Value.DailyRank
	        self.mRewardConfigList = data.Value.RewardConfigList
	        self.mEndTime = data.Value.EndTime
	        self.mSelectId = self.mOrderId
	        self:changeBtnState()
	        self:createInfoView()
	        self:refreshRankView()
	        self:refreshBoxState()


          	self:updateTime()
			self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
        end
    })
end

--请求单日信息
function TopChallengeLayer:requestGetDailyInfo(tag)
	HttpClient:request({
        moduleName = "TimedScore", 
        methodName = "GetDailyInfo",
        svrMethodData = {tag},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data)
	        self.TaskInfo = data.Value.ModuleId

	        self.mDailyRank = data.Value.DailyRank

	        self.mSelectId = tag
	        -- dump(self.mSelectId, "ReceiveReward")

	        self:changeBtnState()
	        self:refreshRankView()

        end
    })
end

--请求单个领取
function TopChallengeLayer:requestGetReward(num, btnObj)
	HttpClient:request({
        moduleName = "TimedScore", 
        methodName = "GetReward",
        svrMethodData = {num},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data)
	        self.mCanReward = data.Value.CanReward
	        self.mRewardConfigList = data.Value.RewardConfigList
            btnObj:setTitleText(TR("已领取"))
	        
	        self:refreshBoxState()
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList, true)

        end
    })
end

--请求一键领取
function TopChallengeLayer:requestGetOneKeyReward()
	HttpClient:request({
        moduleName = "TimedScore", 
        methodName = "OneKeyReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
        	-- dump(data)
	        if data.Status ~= 0 then
	        	return
	        end
	        self.mCanReward = data.Value.CanReward
	        self.mRewardConfigList = data.Value.RewardConfigList
	        

	        if not next(data.Value.BaseGetGameResourceList[1]) then
                ui.showFlashView(TR("无物品可领取"))
            else
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList, true)
                for i,v in ipairs(self.mRewardConfigList) do
                    self.mGetBtnList[i]:setEnabled(false)
                    if v.IsReward == 2 then
                        self.mGetBtnList[i]:setTitleText(TR("已领取"))
                    end
                end
	        	self:refreshBoxState()
            end
        end
    })
end



return TopChallengeLayer