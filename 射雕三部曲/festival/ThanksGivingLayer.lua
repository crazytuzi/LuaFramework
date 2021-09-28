--[[
    文件名: ThanksGivingLayer.lua
	描述: 国庆活动——铸倚天
	创建人: lengjiazhi
	创建时间: 2017.09.22
-- ]]
local ThanksGivingLayer = class("ThanksGivingLayer", function (params)
	return display.newLayer()
end)

function ThanksGivingLayer:ctor(params)

	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData


	self.mBoxBtnList = {}
	self.mFoodList = {}
	self:requestGetInfo()	

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefreshLayer = ui.newStdLayer()
	self:addChild(self.mRefreshLayer)

	self:initUI()

end

-- 初始化ui
function ThanksGivingLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("jrhd_37.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--倚天剑图片
	local swordSprite = ui.newSprite("jrhd_40.png")
	swordSprite:setPosition(320, 268)
	self.mParentLayer:addChild(swordSprite)

	local tipSprite = ui.newSprite("jrhd_38.png")
	tipSprite:setPosition(320, 480)
	self.mParentLayer:addChild(tipSprite, 100)

	--规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(60, 920),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer("规则",
            {
                [1] = TR("1.活动期间，全体玩家都可参与本活动，并通过积分进行排名，在活动结束时根据排名来发放对应的排名奖励。"),
                [2] = TR("2.积分可通过捐献食材和充值获得，不同食材对应的积分不同，美食小果=2积分，美食苹果=5积分，美食玉米=10积分，美食南瓜=20积分，充值20元宝=1积分。"),
                [3] = TR("3.食材可以通过限时掉落活动来获取，全服积分和个人积分达到一定后，即可享用全服盛宴，并获得超值奖励！"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 920),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    --排行榜
    local rankBtn = ui.newButton({
    	normalImage = "tb_16.png",
    	clickAction = function ()
    		LayerManager.addLayer({
    			name = "activity.CommonActivityRankLayer",
                data = {
                    moduleName = "TimedPolaroid",
                    methodNameRank = "GetRankInfo",
                    methodNameReward = "GetRankRewardInfo",
                    scoreName = TR("积分"),
                },
    			cleanUp = false,
			})
    	end
    	})
    rankBtn:setPosition(540, 165)
    self.mParentLayer:addChild(rankBtn)

	local noteLabel = ui.newLabel({
		text = TR("活动结束前一个小时停止捐献\n且获得的积分也不会计入排行"),
		size = 22,
		outlineColor = Enums.Color.eBlack,
	})
	noteLabel:setAnchorPoint(cc.p(0.5, 1))
	noteLabel:setPosition(470, 490)
	self.mParentLayer:addChild(noteLabel, 100)


	self:createFoodView()
end

--创建显示信息的部分
function ThanksGivingLayer:createInfoView()

	local timeBgSprite = ui.newScale9Sprite("c_25.png", cc.size(410, 45))
	timeBgSprite:setPosition(320, 925)
	self.mRefreshLayer:addChild(timeBgSprite)
	local timeBgSpriteSize = timeBgSprite:getContentSize()
	local timeLabel = ui.newLabel({
		text = TR("活动未开启"),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	timeLabel:setPosition(timeBgSpriteSize.width / 2, timeBgSpriteSize.height / 2)
	timeBgSprite:addChild(timeLabel)
	self.mTimeLable = timeLabel

	local totalMakeLabel = ui.newLabel({
		text = TR("全服积分：%s", self.mGlobalNum),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	totalMakeLabel:setPosition(320, 890)
	self.mRefreshLayer:addChild(totalMakeLabel)

	local ScoreBar = require("common.ProgressBar"):create({
            bgImage = "zr_14.png",
            barImage = "zr_15.png",
            currValue = self.mCurProgress,
            maxValue = 100,
        })
	ScoreBar:setPosition(320, 795)
	self.mRefreshLayer:addChild(ScoreBar)

	self:updateTime()
	self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

	self:createRewardView()
	self:goodsView()
end

--捐献物品部分
function ThanksGivingLayer:goodsView()

	table.sort( self.mGoodsInfo, function (a, b)
		if a.ModelId ~= b.ModelId then
			return a.ModelId < b.ModelId
		end
		-- return true
	end)

	local bgSprite = ui.newSprite("jrhd_39.png")
	bgSprite:setPosition(320, 640)
	self.mRefreshLayer:addChild(bgSprite)

    -- 物品列表
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.horizontal)
    tempListView:setBounceEnabled(true)
    tempListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    tempListView:setItemsMargin(5)
    tempListView:setAnchorPoint(cc.p(0.5, 0.5))
    tempListView:setPosition(320, 640)
    tempListView:setTouchEnabled(false)
    tempListView:setContentSize(490, 190)
    self.mRefreshLayer:addChild(tempListView)

    for i,v in ipairs(self.mGoodsInfo) do
    	local layout = ccui.Layout:create()
    	layout:setContentSize(120, 180)

    	local card = CardNode.createCardNode({
    		resourceTypeSub = Utility.getTypeByModelId(v.ModelId, true), -- 资源类型
	        modelId = v.ModelId,  -- 模型Id
	        num = v.ExchangeCount,
	        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
    		})
    	card:setPosition(60, 100)
    	layout:addChild(card)

    	local donateBtn = ui.newButton({
    		text = TR("捐献"),
    		normalImage = "c_28.png",
    		size = cc.size(95, 45),
    		fontSize = 18,
    		clickAction = function ()
    			if self.mEndTime - Player:getCurrentTime() < 3600 then
    				ui.showFlashView("积分结算中")
    				return
    			end
    			self:requestDonate(v.ModelId, v.ExchangeCount)
    		end
    		})
    	donateBtn:setPosition(60, 15)
    	layout:addChild(donateBtn)

    	if v.ExchangeCount <= 0 then
    		donateBtn:setEnabled(false)
    	end

    	tempListView:pushBackCustomItem(layout)
    end

	local myScoreLabel = ui.newLabel({
		text = TR("个人积分：%s%s", Enums.Color.eOrangeH, self.mPersonNum),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	myScoreLabel:setPosition(475, 500)
	self.mRefreshLayer:addChild(myScoreLabel)

end

local boxPicOpen = {
	"jrhd_43.png",
    "jrhd_48.png",
    "jrhd_51.png",
    "jrhd_46.png",
    "jrhd_45.png",
}

local boxPicClose = {
    "jrhd_42.png",
    "jrhd_49.png",
    "jrhd_50.png",
    "jrhd_47.png",
    "jrhd_44.png",
}

local dishes = {
	[1] = {
		pos = cc.p(514, 285),
		pic = "jrhd_52.png", --莓子
		zOrder = 4,
		}, 
	[2] = {
		pos = cc.p(142, 310),
		pic = "jrhd_58.png", --派
		zOrder = 3,
		},
	[3] = {
		pos = cc.p(456, 389),
		pic = "jrhd_60.png", --玉米
		zOrder = 2,
		},
	[4] = {
		pos = cc.p(253, 405),
		pic = "jrhd_56.png",--南瓜
		zOrder = 1,
		},
	[5] = {
		pos = cc.p(317, 208),
		pic = "jrhd_54.png", --鸡
		zOrder = 5,
		},
}

--创建美食展示
function ThanksGivingLayer:createFoodView()
	for i,v in ipairs(dishes) do
		local foodSprite = ui.newSprite(v.pic)
		foodSprite:setPosition(v.pos)
		self.mParentLayer:addChild(foodSprite, v.zOrder)
		foodSprite:setScale(0.5)

		table.insert(self.mFoodList, foodSprite)
	end
end

--创建奖励宝箱
function ThanksGivingLayer:createRewardView()
	if #self.mBoxBtnList ~= 0 then
		for i,v in ipairs(self.mBoxBtnList) do
			v:removeFromParent()
			v = nil
		end
	end

	self.mBoxBtnList = {}
	local stepOff = 470 / (#self.mRewardInfo - 1)
	for i,v in ipairs(self.mRewardInfo) do
		local node = cc.Node:create()
		node:setPosition(i*stepOff, 825)
		if #self.mRewardInfo == 1 then
			node:setPosition(585, 825)
		end
		self.mRefreshLayer:addChild(node)

		local boxBtn = ui.newButton({
			normalImage = boxPicClose[i] or "r_05.png",
			clickAction = function()
				self:showRewardPop(v)
			end
			})
		boxBtn:setScale(0.95)
		boxBtn:setPosition(0, 10)
		node:addChild(boxBtn)

		local needBgSprite = ui.createLabelWithBg({
			bgFilename = "r_03.png",
	        labelStr = Utility.numberWithUnit(v.NeedGlobalNum),
	        fontSize = 20,
	        alignType = ui.TEXT_ALIGN_CENTER,
	        outlineColor = Enums.Color.eBlack,
	        offset = -5,
		})
		needBgSprite:setPosition(0, -20)
		node:addChild(needBgSprite)

		table.insert(self.mBoxBtnList, boxBtn)
	end
	self:refreshBoxStatus()
end

--宝箱弹窗
function ThanksGivingLayer:showRewardPop(info)
	local function DIYFuncion(layer, layerBgSprite, layerSize)
		local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(420, 175))
		grayBgSprite:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.6)
		layerBgSprite:addChild(grayBgSprite)

		local tempRewardList = {}
		for i,v in ipairs(info.RewardList) do
			tempRewardList[i] = {}
			tempRewardList[i].resourceTypeSub = v.ResourceTypeSub
			tempRewardList[i].modelId = v.ModelId
			tempRewardList[i].num = v.Count
		end

		--奖励列表
		local rewardList = ui.createCardList({
			maxViewWidth = 370,
	        viewHeight = 120,
	        space = 10,
	        cardDataList = tempRewardList,
	        allowClick = false, 
	        needArrows = true, 
		})
		rewardList:setAnchorPoint(cc.p(0.5, 0.5))
		rewardList:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.6)
		layerBgSprite:addChild(rewardList)

		local tipLabelGloble = ui.newLabel({
			text = TR("全服积分达到%s可领取", Utility.numberWithUnit(info.NeedGlobalNum)),
			size = 20,
			color = Enums.Color.eNormalWhite,
        	outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			})
		tipLabelGloble:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.32)
		layerBgSprite:addChild(tipLabelGloble)

		local tipLabelPerson = ui.newLabel({
			text = TR("个人积分达到%s可领取", Utility.numberWithUnit(info.NeedPersonNum)),
			size = 20,
			color = Enums.Color.eNormalWhite,
        	outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			})
		tipLabelPerson:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.25)
		layerBgSprite:addChild(tipLabelPerson)

		local getBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("领取"),
			clickAction = function(pSender)
				LayerManager.removeLayer(layer)
				self:requestGetReward()
			end
		})
		getBtn:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.13)
		layerBgSprite:addChild(getBtn)

		if info.NeedGlobalNum > self.mGlobalNum then
			tipLabelGloble:setString(TR("%s全服积分达到%s可领取", Enums.Color.eRedH, Utility.numberWithUnit(info.NeedGlobalNum)))
			getBtn:setEnabled(false)
		end
		if info.NeedPersonNum > self.mPersonNum then
			tipLabelPerson:setString(TR("%s个人积分达到%s可领取", Enums.Color.eRedH, Utility.numberWithUnit(info.NeedPersonNum)))
			getBtn:setEnabled(false)
		end

		if info.Status == 2 then
			getBtn:setTitleText("已领取")
			getBtn:setEnabled(false)
		end
	end

	MsgBoxLayer.addDIYLayer({
	 	title = TR("全服奖励"),
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        btnInfos = {},
        notNeedBlack = true,
        bgSize = cc.size(490, 380)
		})
end

--刷新宝箱状态
function ThanksGivingLayer:refreshBoxStatus()
	for i,v in ipairs(self.mBoxBtnList) do
		if not tolua.isnull(v) then
			if v.flashNode then
				v:stopAllActions()
				v:setRotation(0)
				v.flashNode:removeFromParent()
				v.flashNode = nil
			end
		end
	end
	for i,v in ipairs(self.mRewardInfo) do
		local openPic = boxPicOpen[i] or "r_14"
		if v.Status == 1 then
			ui.setWaveAnimation(self.mBoxBtnList[i])
		elseif v.Status == 2 then
			self.mBoxBtnList[i]:loadTextures(openPic, openPic)
		end
	end
end

-- 活动倒计时
function ThanksGivingLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLable:setString(TR("活动剩余时间：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLable:setString(TR("00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
    end
end
--刷新美食显示
function ThanksGivingLayer:refreshFoodView()
	for i,v in ipairs(self.mRewardInfo) do
		if self.mGlobalNum < v.NeedGlobalNum then
			self.mFoodList[i]:setVisible(false)
		else
			self.mFoodList[i]:setVisible(true)
		end
	end
end

-- 获取恢复数据
function ThanksGivingLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 处理进度条数据
function ThanksGivingLayer:handleProgressData()
	local tempTotal = 100
	local oneStep = 100 / #self.mRewardInfo
	local LastNeedNum = self.mRewardInfo[self.mOrderId] and self.mRewardInfo[self.mOrderId].NeedGlobalNum or 0
	local curNeedNum = self.mRewardInfo[self.mOrderId + 1] and self.mRewardInfo[self.mOrderId + 1].NeedGlobalNum or self.mMaxGlobalCfgNum

	local oneStepPerL = self.mGlobalNum - LastNeedNum
	local oneStepPerN = curNeedNum - LastNeedNum
	local curPro = self.mOrderId * oneStep + oneStepPerL/oneStepPerN * oneStep

	self.mCurProgress = curPro
end

--====================================网络接口=========================================
--获取信息
function ThanksGivingLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        -- dump(data, "ssssss")
	        if data.Status ~= 0 then
	        	-- ui.showFlashView("活动未开启")
	        	return
	        end
	        self.mRewardInfo = data.Value.RewardInfo
	        self.mGlobalNum = data.Value.GlobalNum
	        self.mPersonNum = data.Value.PersonNum
	        self.mMaxGlobalCfgNum = data.Value.MaxGlobalCfgNum
	        self.mEndTime = data.Value.EndDate
	        self.mOrderId = data.Value.OrderId
	        self.mScaleNum = data.Value.Scale
	        self.mGoodsInfo = data.Value.GoodsInfo
	        self:handleProgressData()
	        self:createInfoView()
	        self:refreshFoodView()
        end
    })
end

--领取宝箱(一键领取)
function ThanksGivingLayer:requestGetReward()
	HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "ReceiveReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "ReceiveReward")
	        self.mRewardInfo = data.Value.RewardInfo
	        self.mGlobalNum = data.Value.GlobalNum
	        self.mPersonNum = data.Value.PersonNum
	        self.mMaxGlobalCfgNum = data.Value.MaxGlobalCfgNum
	        self:createRewardView()

	        ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

--请求捐献
function ThanksGivingLayer:requestDonate(modelId, num)
	HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "Exchange",
        svrMethodData = {modelId, num},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end

	        ui.showFlashView("捐赠成功")

	        self.mRefreshLayer:removeAllChildren()
	        -- 停止倒计时
        	if self.mSchelTime then
            	self:stopAction(self.mSchelTime)
            	self.mSchelTime = nil
        	end
        	self.mBoxBtnList = {}

	        self.mRewardInfo = data.Value.RewardInfo
	        self.mGlobalNum = data.Value.GlobalNum
	        self.mPersonNum = data.Value.PersonNum
	        self.mMaxGlobalCfgNum = data.Value.MaxGlobalCfgNum
	        self.mEndTime = data.Value.EndDate
	        self.mOrderId = data.Value.OrderId
	        self.mScaleNum = data.Value.Scale
	        self.mGoodsInfo = data.Value.GoodsInfo
	        self:handleProgressData()
	        self:createInfoView()
	        self:refreshFoodView()

	        -- ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return ThanksGivingLayer