--[[
    文件名：ActivityGroupBuy.lua
    文件描述：限时团购活动
    创建人：lengjiazhi
    创建时间：2017.10.31
]]

local ActivityGroupBuy = class("ActivityGroupBuy", function(params)
    return display.newLayer()
end)

function ActivityGroupBuy:ctor(params)

    params = params or {}
    -- 活动实体Id列表
    self.mActivityIdList = params.activityIdList
    -- 该活动的主模块Id
    self.mParentModuleId = params.parentModuleId
    -- 该页面的数据信息
    self.mLayerData = params.cacheData

	-- 数据初始化
	self.mActivityId = params.activityIdList[1]         -- 只有一个活动Id

	self.mCurSelectId = 1

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefreshLayer = ui.newStdLayer()
	self:addChild(self.mRefreshLayer)

	self:initUI()

	self:requestGetInfo()
end

function ActivityGroupBuy:initUI()
	--背景图
	local bgSprite = ui.newSprite("xshd_33.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返还提示
	local giveBackTip = ui.newSprite("xshd_34.png")
	giveBackTip:setPosition(345, 750)
	self.mParentLayer:addChild(giveBackTip)

	--返还提示
	local tipLabel = ui.newLabel({
		text = TR("团购结束后，差价将通过领奖中心返还"),
		color = cc.c3b(0xeb, 0xff, 0xc9),
		outlineColor = cc.c3b(0x2b, 0x66, 0x14),
		size = 20,
		})
	tipLabel:setAnchorPoint(0, 0.5)
	tipLabel:setPosition(285, 650)
	self.mParentLayer:addChild(tipLabel)

	--剩余时间
	local timeLabel = ui.newLabel({
		text = TR("团购剩余时间：00:00:00"),
		color = cc.c3b(0xeb, 0xff, 0xc9),
		outlineColor = cc.c3b(0x2b, 0x66, 0x14),
		size = 20,
		})
	timeLabel:setAnchorPoint(0, 0.5)
	timeLabel:setPosition(285, 680)
	self.mParentLayer:addChild(timeLabel)
	self.mTimeLabel = timeLabel

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(45, 957),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.在团购过程中参与团购的人数>=折扣需求人数后即可达成折扣"),
                [2] = TR("2.以原价购买道具，系统在活动结束时根据最后达成的折扣返还元宝差值"),
                [3] = TR("3.返还的元宝通过领奖中心领取"),
                [4] = TR("4.团购每消耗1元宝获得1积分，积分可在积分兑换中兑换奖励"),
                [5] = TR("5.若按最终折扣购买则没有返还"),
        	})
        end})
    bgSprite:addChild(ruleBtn, 1)

    self:groupView()
end

-- 更新时间
function ActivityGroupBuy:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("团购剩余时间：%s",MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("团购剩余时间：00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 重新进入提示
        MsgBoxLayer.addOKLayer(
            TR("%s活动已结束，请重新进入", self.mActivityIdList[1].Name),
            TR("提示"),
            {
                normalImage = "c_28.png",
            },
            {
                normalImage = "c_29.png",
                clickAction = function()
                    LayerManager.addLayer({
                        name = "activity.ActivityMainLayer",
                        data = {moduleId = ModuleSub.eTimedActivity},
                    })
                end
            }
        )
    end
end

--中间团购信息
function ActivityGroupBuy:groupView()
	local tempBar = require("common.ProgressBar"):create({
    	bgImage = "xshd_36.png",
        barImage = "xshd_37.png",
        currValue = 0,
        maxValue = 0,
        needLabel = false,
        percentView = false,
        size = 20,
        color = Enums.Color.eBrown
    })
    tempBar:setPosition(320, 570)
    self.mParentLayer:addChild(tempBar)
    self.mTempBar = tempBar

    --购买人数
    local buyNumLabel = ui.newLabel({
    	text = TR("当前已购买人数："),
    	color = cc.c3b(0x50, 0x1b, 0x1b),
    	size = 22,
    	})
    buyNumLabel:setAnchorPoint(0, 0.5)
    buyNumLabel:setPosition(25, 535)
    self.mParentLayer:addChild(buyNumLabel)
    self.mBuyNumLabel = buyNumLabel

    local backNumLabel = ui.newNumberLabel({
	 	text = "123",
        imgFile = "xshd_35.png",
    	})
    backNumLabel:setPosition(495, 750)
    backNumLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(backNumLabel)
    self.mBackNumLabel = backNumLabel


end

--下方信息
function ActivityGroupBuy:createBottomView()

    --宝箱
    local boxBtn = ui.newButton({
        normalImage = "xshd_41.png",
        clickAction = function()
            self:requestGetRewardInfo()
        end
        })
    boxBtn:setPosition(105, 750)
    self.mParentLayer:addChild(boxBtn)
    self.mBoxBtn = boxBtn

    --当前积分
    local curScoreLabel = ui.newLabel({
        text = TR("当前积分：%s", self.mCurScore),
        color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x2b, 0x66, 0x14),
        size = 20,
        })
    curScoreLabel:setAnchorPoint(0, 0.5)
    curScoreLabel:setPosition(45, 650)
    self.mParentLayer:addChild(curScoreLabel)
    self.mCurScoreLabel = curScoreLabel

	local bgSprite = ui.newSprite("jsxy_04.png")
	bgSprite:setPosition(320, 210)
	self.mParentLayer:addChild(bgSprite)

	self.mBottomBtnList = {}

	local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.horizontal)
    tempListView:setBounceEnabled(true)
    tempListView:setAnchorPoint(cc.p(0.5, 0.5))
    tempListView:setPosition(320, 210)
    tempListView:setContentSize(cc.size(500, 170))
    self.mParentLayer:addChild(tempListView)

	for i,v in ipairs(self.mGoodsInfo) do
		local layout = ccui.Layout:create()
		layout:setContentSize(124, 165)

		local rewardInfo = Utility.analysisStrResList(v.SellResource)
		local groupCard = CardNode.createCardNode({
			resourceTypeSub = rewardInfo[1].resourceTypeSub, -- 资源类型
        	modelId = rewardInfo[1].modelId,  -- 模型Id
        	cardShowAttrs = {CardShowAttr.eBorder}
			})
		-- groupCard:setEmpty()
		groupCard:setClickCallback(function()
			if self.mCurSelectId == i then
				return
			end
			self.mCurSelectId = i
			self.mBottomBtnList[i].arrow:setVisible(true)
			self.mBottomBtnList[i].selectPic:setVisible(true)
			for k, item in ipairs(self.mBottomBtnList) do
				if k ~= i then
					item.arrow:setVisible(false)
					item.selectPic:setVisible(false)
				end
			end
			self:requestGetGroupInfo(i)
		end)
		groupCard:setPosition(62, 90)
		layout:addChild(groupCard)

		local arrow = ui.newSprite("c_43.png")
		arrow:setRotation(180)
		arrow:setPosition(62, 155)
		layout:addChild(arrow)
		layout.arrow = arrow

		local selectPic = ui.newSprite("c_31.png")
		selectPic:setPosition(62, 90)
		layout:addChild(selectPic)
		layout.selectPic = selectPic

		local nameColor = Utility.getColorValue(Utility.getColorLvByModelId(rewardInfo[1].modelId), 1)
		local nameLabel = ui.newLabel({
			text = v.Name,
			color = nameColor,
    	    outlineColor = Enums.Color.eBlack,
			size = 18,
			})
		nameLabel:setPosition(62, 25)
		layout:addChild(nameLabel)

        tempListView:pushBackCustomItem(layout)

        table.insert(self.mBottomBtnList, layout)
	end

	for k, item in ipairs(self.mBottomBtnList) do
		if k ~= self.mCurSelectId then
			item.arrow:setVisible(false)
			item.selectPic:setVisible(false)
		else
			item.arrow:setVisible(true)
			item.selectPic:setVisible(true)
		end
	end

	--左箭头
	local arrowL = ui.newSprite("c_26.png")
	arrowL:setPosition(38, 220)
	self.mParentLayer:addChild(arrowL)
	arrowL:setRotation(180)

	--右箭头
	local arrowR = ui.newSprite("c_26.png")
	arrowR:setPosition(590, 220)
	self.mParentLayer:addChild(arrowR)
end

-- 根据数据刷新
function ActivityGroupBuy:refreshView()
	self.mRefreshLayer:removeAllChildren()

	for i = 1, #self.mDiscountInfo-1 do
		local stepOff = 588 * (self.mDiscountInfo[i].Num / self.mDiscountInfo[#self.mDiscountInfo].Num)
		local discountLabel = ui.newLabel({
			text = TR("%s折", self.mDiscountInfo[i].Discount*10),
			color = self.mCurGroupInfo.CurrNum < self.mDiscountInfo[i].Num and cc.c3b(0xe3, 0x61, 0x01) or cc.c3b(0x24, 0x90, 0x29),
			size = 20,
			})
		discountLabel:setPosition(30 + stepOff, 590)
		self.mRefreshLayer:addChild(discountLabel)
	end
	--最终折扣
	local discountLabelE = ui.newLabel({
		text = TR("%s折", self.mDiscountInfo[#self.mDiscountInfo].Discount*10),
		color = self.mCurGroupInfo.CurrNum < self.mDiscountInfo[#self.mDiscountInfo].Num and cc.c3b(0xe3, 0x61, 0x01) or cc.c3b(0x24, 0x90, 0x29),
		size = 20,
		})
	discountLabelE:setPosition(592, 590)
	self.mRefreshLayer:addChild(discountLabelE)

	self.mBuyNumLabel:setString(TR("当前已购买人数：%s", self.mCurGroupInfo.CurrNum))
	self.mTempBar:setMaxValue(self.mDiscountInfo[#self.mDiscountInfo].Num)
	self.mTempBar:setCurrValue(self.mCurGroupInfo.CurrNum)

	local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.horizontal)
    tempListView:setBounceEnabled(true)
    tempListView:setAnchorPoint(cc.p(0.5, 0.5))
    tempListView:setPosition(250, 445)
    tempListView:setContentSize(cc.size(450, 150))
    self.mRefreshLayer:addChild(tempListView)

    local goodsList = Utility.analysisStrResList(self.mCurGroupInfo.SellResource)
    
    for i,v in ipairs(goodsList) do
    	local layout = ccui.Layout:create()
    	layout:setContentSize(122, 148)

    	local bgSprite = ui.newSprite("xshd_40.png")
    	bgSprite:setPosition(61, 74)
    	layout:addChild(bgSprite)

    	local goodsCard = CardNode.createCardNode({
    		resourceTypeSub = v.resourceTypeSub,
    		modelId = v.modelId,
    		num = v.num,
    		})
    	goodsCard:setPosition(61, 84)
    	layout:addChild(goodsCard)

    	tempListView:pushBackCustomItem(layout)
    end

    --原价
    local price = Utility.analysisStrResList(self.mCurGroupInfo.BuyUseResource)
    local oldPriceLable = ui.newLabel({
    	text = TR("原价:{%s}%s", Utility.getDaibiImage(price[1].resourceTypeSub), price[1].num),
    	color = cc.c3b(0x50, 0x1b, 0x1b),
    	size = 20,
    	})
    oldPriceLable:setAnchorPoint(0, 0.5)
    oldPriceLable:setPosition(485, 515)
    self.mRefreshLayer:addChild(oldPriceLable)
    --现价
    local curPriceLable = ui.newLabel({
    	text = TR("现价:{%s}%s", Utility.getDaibiImage(price[1].resourceTypeSub), price[1].num * self.mCurGroupInfo.CurrDiscount),
    	color = cc.c3b(0xb8, 0x47, 0x20),
    	size = 20,
    	})
    curPriceLable:setAnchorPoint(0, 0.5)
    curPriceLable:setPosition(485, 475)
    self.mRefreshLayer:addChild(curPriceLable)

	local discountPrice 
	if self.mCurGroupInfo.IfCanBuy then
		discountPrice = 0
	else
		discountPrice = self.mCurGroupInfo.ReturnRatio
	end
	self.mBackNumLabel:setString(discountPrice)


    --红线
    local redline = ui.newSprite("cdjh_14.png")
    redline:setPosition(565, 515)
    self.mRefreshLayer:addChild(redline)

    --购买按钮
    local buyBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("购买"),
    	clickAction = function()
    		self:requestGroupBuy(self.mCurSelectId)
    	end
    	})
    buyBtn:setPosition(550, 410)
    self.mRefreshLayer:addChild(buyBtn)
    buyBtn:setEnabled(self.mCurGroupInfo.IfCanBuy)
end

-- 获取恢复数据
function ActivityGroupBuy:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}
	return retData
end

--兑换弹窗
function ActivityGroupBuy:exchangePopView()
    --弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 736),
        title = TR("积分兑换"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    local curScoreLabel = ui.newLabel({
        text = TR("当前积分：#249029%s", self.mCurScore),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
        })
    curScoreLabel:setAnchorPoint(0, 0.5)
    curScoreLabel:setPosition(30, 640)
    self.mPopBgSprite:addChild(curScoreLabel)
    self.mCurScoreLabelPop = curScoreLabel

    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(539, 576))
    grayBgSprite:setPosition(299, 325)
    self.mPopBgSprite:addChild(grayBgSprite)

    -- 奖励列表控件
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(530, 555))
    rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(299, 325)
    self.mPopBgSprite:addChild(rewardListView)

    for i,v in ipairs(self.mRewardInfo) do
        local layout = ccui.Layout:create()
        layout:setContentSize(530, 140)

        local itemBgSprite = ui.newScale9Sprite("c_18.png", cc.size(526, 136))
        itemBgSprite:setPosition(265, 70)
        layout:addChild(itemBgSprite)

        local rewardList = Utility.analysisStrResList(v.RewardResource)

        local cardListView = ui.createCardList({
            maxViewWidth = 350,
            viewHeight = 120,
            space = 10, 
            cardDataList = rewardList
            })
        cardListView:setAnchorPoint(0, 0.5)
        cardListView:setPosition(20, 70)
        layout:addChild(cardListView)

        local exchangeBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("兑换"),
            clickAction = function()
                if v.NeedScore > self.mCurScore then
                    ui.showFlashView(TR("积分不足！"))
                    return
                end
                self:requestExchangeReward(v.Id)
            end
            })
        exchangeBtn:setPosition(450, 80)
        layout:addChild(exchangeBtn)

        local needScore = ui.newLabel({
            text = TR("需要积分：%s%s", Enums.Color.eGoldH, v.NeedScore),
            size = 20,
            outlineColor = Enums.Color.eOutlineColor,
            })
        needScore:setPosition(420, 35)
        layout:addChild(needScore)

        rewardListView:pushBackCustomItem(layout)
    end
end

--刷新宝箱状态
function ActivityGroupBuy:refreshBox()
    if self.mBoxBtn.flashNode then
        self.mBoxBtn:stopAllActions()
        self.mBoxBtn.flashNode:removeFromParent()
        self.mBoxBtn.flashNode = nil
        self.mBoxBtn:setRotation(0)
    end
    if self.mCurScore >= self.mNeedScoreMin then
        ui.setWaveAnimation(self.mBoxBtn, nil, true)
    end
end
--======================================网络请求=================================
--请求信息
function ActivityGroupBuy:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedGroupBuy", 
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data.Value)
        	self.mEndTime = data.Value.EndDate
        	self.mGoodsInfo = data.Value.GoodsInfo
            self.mCurScore = data.Value.Score
            self.mNeedScoreMin = data.Value.NeedScoreMin
        	self:createBottomView()
            self:refreshBox()

    		-- 刷新时间，开始倒计时
		    if self.mSchelTime then
		        self:stopAction(self.mSchelTime)
		        self.mSchelTime = nil
		    end
		    self:updateTime()
		    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

        	self:requestGetGroupInfo(1)
        end
    })
end
--请求单个团购信息
function ActivityGroupBuy:requestGetGroupInfo(id)
	HttpClient:request({
        moduleName = "TimedGroupBuy", 
        methodName = "GetGroupInfo",
        svrMethodData = {id},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        self.mCurGroupInfo = data.Value.GoodsInfo
	        self.mDiscountInfo = data.Value.GoodsInfo.DiscountInfo
	        self:refreshView()
        end
    })
end

--请求购买
function ActivityGroupBuy:requestGroupBuy(id)
	HttpClient:request({
        moduleName = "TimedGroupBuy", 
        methodName = "GroupBuy",
        svrMethodData = {id},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        self.mCurGroupInfo = data.Value.GoodsInfo
	        self.mDiscountInfo = data.Value.GoodsInfo.DiscountInfo
            self.mCurScore = data.Value.Score
            self.mCurScoreLabel:setString(TR("当前积分：%s", self.mCurScore))
            self:refreshBox()
	        self:refreshView()
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

--请求兑换信息
function ActivityGroupBuy:requestGetRewardInfo()
    HttpClient:request({
        moduleName = "TimedGroupBuy", 
        methodName = "GetRewardInfo",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            self.mRewardInfo = data.Value.RewardInfo
            self:exchangePopView()
        end
    })
end

--请求兑换
function ActivityGroupBuy:requestExchangeReward(id)
    HttpClient:request({
        moduleName = "TimedGroupBuy", 
        methodName = "ExchangeReward",
        svrMethodData = {id},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            self.mCurScore = data.Value.Score
            self.mCurScoreLabelPop:setString(TR("当前积分：#249029%s", self.mCurScore))
            self.mCurScoreLabel:setString(TR("当前积分：%s", self.mCurScore))
            self:refreshBox()
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

        end
    })
end
return ActivityGroupBuy