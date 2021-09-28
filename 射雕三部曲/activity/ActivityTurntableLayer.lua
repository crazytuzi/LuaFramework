--[[
    文件名: ActivityTurntableLayer.lua
	描述: 转盘活动
	创建人: lengjiazhi
	创建时间: 2017.12.12
-- ]]
local ActivityTurntableLayer = class("ActivityTurntableLayer", function (params)
	return display.newLayer()
end)

function ActivityTurntableLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mTouchLayer = ui.newStdLayer()
	self:addChild(self.mTouchLayer)

	self.mTouchNode = ui.registerSwallowTouch({
		node = self.mTouchLayer,
		allowTouch = false,
        })

	self.mOldTargetIdOut = 0
	self.mOldTargetIdIn = 0

	self:initUI()

	self:createTurnTable()
	self:createBottomView()
end

function ActivityTurntableLayer:onEnterTransitionFinish()
	local activityInfo = ActivityObj:getActivityItem(ModuleSub.eTimedLuckyTurntable)[1]
	if activityInfo and Player:getCurrentTime() > activityInfo.EndDate then
		LayerManager.removeLayer(self)
		-- 打开排行榜
		self:openRankShow(true)
	else
	    self:requestGetInfo()
	end
end

function ActivityTurntableLayer:openRankShow(isCleanUp)
	LayerManager.addLayer({
        name = "activity.CommonActivityRankLayer",
        data = {
            moduleName = "TimedLuckyTurntable",
            methodNameRank = "GetTotalRank",
            methodNameReward = "GetTotalRankReward",
            scoreName = TR("积分"),
        },
        cleanUp = isCleanUp,
    })
end

function ActivityTurntableLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("zp_07.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1035),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(45, 1035),
        clickAction = function()
            --如果开启概率显示
            if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
                local contentList = {[1]={}, [2]={}}
                for i,v in ipairs(self.mInnerRewardList) do
                    local list = {}
                    list = Utility.analysisStrResList(v.Reward)
                    list[1].OddsTips = v.OddsTips
                    table.insert(contentList[1], list[1])
                end
                for i,v in ipairs(self.mExternalRewardList) do
                    local list = {}
                    list = Utility.analysisStrResList(v.Reward)
                    list[1].OddsTips = v.OddsTips
                    table.insert(contentList[1], list[1])
                end
                local reuleList = {
                    [1] = TR("1.转盘分为内圈和外圈。"),
                    [2] = TR("2.在外圈有一个奖励为“进入内圈”，抽到“进入内圈”奖励时进入内圈，内圈需要单抽一次。"),
                    [3] = TR("3.内圈只能转动一次，就会回到外圈。"),
                    [4] = TR("4.每次转动转盘会获得积分，积分可用于兑换以及排名。"),
                    [5] = TR("5.每日可以使用幸运点抽取或者转盘券抽取。"),
                    [6] = TR("6.每充值120元宝获得一个幸运点，幸运点在活动结束后会清空，请各位大侠及时抽取！")
                }
                for i,v in ipairs(reuleList) do
                    table.insert(contentList[2], v)
                end
                MsgBoxLayer.addprobabilityLayer(TR("概率详情"), contentList)
            else 
                MsgBoxLayer.addRuleHintLayer(TR("规则"),
                {
                    [1] = TR("1.转盘分为内圈和外圈。"),
                    [2] = TR("2.在外圈有一个奖励为“进入内圈”，抽到“进入内圈”奖励时进入内圈，内圈需要单抽一次。"),
                    [3] = TR("3.内圈只能转动一次，就会回到外圈。"),
                    [4] = TR("4.每次转动转盘会获得积分，积分可用于兑换以及排名。"),
                    [5] = TR("5.每日可以使用幸运点抽取或者转盘券抽取。"),
                    [6] = TR("6.每充值120元宝获得一点幸运点，幸运点在活动结束后会清空，请各位大侠及时抽取！")
                })
            end
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    --排行榜
    local rankBtn = ui.newButton({
    	normalImage = "tb_16.png",
    	position = cc.p(595, 900),
    	clickAction = function()
    		self:openRankShow(false)
    	end
    	})
    self.mParentLayer:addChild(rankBtn)

    --宝箱
    local boxBtn = ui.newButton({
    	normalImage = "tb_215.png",
    	position = cc.p(55, 900),
    	clickAction = function()
    		self:requestGetRewardInfo()
    	end
    	})
    self.mParentLayer:addChild(boxBtn)
    self.mBoxBtn = boxBtn

    --顶部图片
    local tipSprite = ui.newSprite("zp_04.png")
    tipSprite:setPosition(320, 985)
    self.mParentLayer:addChild(tipSprite)

    --跳转按钮
    local changeBtn = ui.newButton({
    	normalImage = "zp_08.png",
    	clickAction = function ()
    		local activityData = ActivityObj:getActivityItem(ModuleSub.eTimedDailyChallenge)
            if activityData then
                LayerManager.showSubModule(ModuleSub.eTimedDailyChallenge)
            else
                ui.showFlashView({text = TR("活动暂未开启")})
            end
    	end
    	})
    changeBtn:setPosition(320, 90)
    self.mParentLayer:addChild(changeBtn)
end

--创建中间转盘
function ActivityTurntableLayer:createTurnTable()
	--外圈
	local outCircle = ui.newSprite("zp_03.png")
	outCircle:setPosition(322, 578)
	self.mParentLayer:addChild(outCircle)

	--外圈选择标识父节点
	local outTagNode = cc.Node:create()
	outTagNode:setContentSize(452, 452)
	outTagNode:setAnchorPoint(0.5, 0.5)
	outTagNode:setPosition(322, 578)
	self.mParentLayer:addChild(outTagNode)
	self.mOutTagNode = outTagNode

	--外圈选中标识
	local outCircleTag = ui.newSprite("zp_06.png")
	outCircleTag:setPosition(226, 415)
	outTagNode:addChild(outCircleTag)

	--外圈奖励父节点
	local outCircleNode = cc.Node:create()
	outCircleNode:setContentSize(452, 452)
	outCircleNode:setAnchorPoint(0.5, 0.5)
	outCircleNode:setPosition(322, 578)
	self.mParentLayer:addChild(outCircleNode)
	self.mOutCircle = outCircleNode

	--内圈
	local insideCircle = ui.newSprite("zp_01.png")
	insideCircle:setPosition(322, 578)
	self.mParentLayer:addChild(insideCircle)
	self.mInsideCircle = insideCircle

	--内圈标签
	local insideCircleTag = cc.Node:create()
	insideCircleTag:setContentSize(cc.size(97, 97))
	insideCircleTag:setAnchorPoint(0.5, 0.5)
	insideCircleTag:setPosition(322, 578)
	self.mParentLayer:addChild(insideCircleTag)
	self.mInsideCircleTag = insideCircleTag

	--箭头
	local insideCircleArrow = ui.newSprite("zp_05.png")
	insideCircleArrow:setPosition(48.5, 97)
	insideCircleTag:addChild(insideCircleArrow)

	--刷新按钮
	local refreshBtn = ui.newButton({
		normalImage = "zp_02.png",
		clickAction = function()
			-- self:testAction(self.mOutCircle)
			local refreshRes = Utility.analysisStrResList(self.mRefreshResource) 
			MsgBoxLayer.addOKLayer(
				TR("刷新奖励需要消耗{%s}%s", Utility.getDaibiImage(refreshRes[1].resourceTypeSub, refreshRes[1].modelId), refreshRes[1].num),
				TR("提示"), 
				{
					{
						text = TR("确定"),
						clickAction = function(layerObj)
							self:requestRefreshReward()
							LayerManager.removeLayer(layerObj)
						end
					},
					{
						text = TR("取消")
					}
				},
				{}
				)
		end
		})
	refreshBtn:setPosition(322, 578)
	self.mParentLayer:addChild(refreshBtn)
end

--创建底部按钮
function ActivityTurntableLayer:createBottomView()
	local turnOneD = ui.newButton({
		normalImage = "c_28.png",
		text = TR("抽一次"),
		clickAction = function()
			self:turnTableCallFun(true, 1, self.mOneDiamond)
		end
		})
	turnOneD:setPosition(90, 240)
	self.mParentLayer:addChild(turnOneD)
    --红点
    turnBubbleOne = ui.createBubble()
    turnBubbleOne:setPosition(cc.p(120, 45))
    turnOneD:addChild(turnBubbleOne)
    turnBubbleOne:setVisible(false)
    self.mTurnBubbleOne = turnBubbleOne

	local turnTenD = ui.newButton({
		normalImage = "c_33.png",
		text = TR("抽十次"),
		clickAction = function()
			self:turnTableCallFun(true, 10, self.mTenDiamond)
		end
		})
	turnTenD:setPosition(90, 145)
	self.mParentLayer:addChild(turnTenD)
    --红点
    turnBubbleTen = ui.createBubble()
    turnBubbleTen:setPosition(cc.p(120, 45))
    turnTenD:addChild(turnBubbleTen)
    turnBubbleTen:setVisible(false)
    self.mTurnBubbleTen = turnBubbleTen

	local turnOneT = ui.newButton({
		normalImage = "c_28.png",
		text = TR("抽一次"),
		clickAction = function()
			self:turnTableCallFun(false, 1, self.mOneResource)
		end
		})
	turnOneT:setPosition(545, 240)
	self.mParentLayer:addChild(turnOneT)

	local turnTenT = ui.newButton({
		normalImage = "c_33.png",
		text = TR("抽十次"),
		clickAction = function()
			self:turnTableCallFun(false, 10, self.mTenResource)
		end
		})
	turnTenT:setPosition(545, 145)
	self.mParentLayer:addChild(turnTenT)
end


--创建数据相关显示
function ActivityTurntableLayer:createInfoView()
	--元宝1次
	-- local tempPrice = Utility.analysisStrResList(self.mOneDiamond)
	-- local priceLabelOneD = ui.newLabel({
 --    	text = TR("{%s} %s",Utility.getDaibiImage(tempPrice[1].resourceTypeSub, tempPrice[1].modelId), tempPrice[1].num),
 --        color = cc.c3b(0xff, 0xff, 0xff),
 --        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
 --        outlineSize = 2,
 --        align = TEXT_ALIGN_CENTER
 --    })
 --    priceLabelOneD:setPosition(90, 193)
 --    self.mParentLayer:addChild(priceLabelOneD)
 --    --元宝10次
 --    local tempPrice = Utility.analysisStrResList(self.mTenDiamond)
	-- local priceLabelTenD = ui.newLabel({
 --    	text = TR("{%s} %s",Utility.getDaibiImage(tempPrice[1].resourceTypeSub, tempPrice[1].modelId), tempPrice[1].num),
 --        color = cc.c3b(0xff, 0xff, 0xff),
 --        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
 --        outlineSize = 2,
 --        align = TEXT_ALIGN_CENTER
 --    })
 --    priceLabelTenD:setPosition(90, 102)
 --    self.mParentLayer:addChild(priceLabelTenD)

    --次数1次
    local priceLabelOneD = ui.newLabel({
        text = TR("幸运点：%s", 1),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = TEXT_ALIGN_CENTER
    })
    priceLabelOneD:setPosition(90, 193)
    self.mParentLayer:addChild(priceLabelOneD)
    --次数10次
    local priceLabelTenD = ui.newLabel({
        text = TR("幸运点：%s", 10),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = TEXT_ALIGN_CENTER
    })
    priceLabelTenD:setPosition(90, 102)
    self.mParentLayer:addChild(priceLabelTenD)


    --道具1次
    local tempPrice = Utility.analysisStrResList(self.mOneResource)
	local priceLabelOneR = ui.newLabel({
    	text = TR("{%s} %s",Utility.getDaibiImage(tempPrice[1].resourceTypeSub, tempPrice[1].modelId), tempPrice[1].num),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = TEXT_ALIGN_CENTER
    })
    priceLabelOneR:setPosition(547, 193)
    self.mParentLayer:addChild(priceLabelOneR)
    --道具10次
    local tempPrice = Utility.analysisStrResList(self.mTenResource)
	local priceLabelTenR = ui.newLabel({
    	text = TR("{%s} %s",Utility.getDaibiImage(tempPrice[1].resourceTypeSub, tempPrice[1].modelId), tempPrice[1].num),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = TEXT_ALIGN_CENTER
    })
    priceLabelTenR:setPosition(547, 102)
    self.mParentLayer:addChild(priceLabelTenR)

    --我的积分
    local myScoreLabel = ui.newLabel({
    	text = TR("我的积分：%s", self.mTotalScore),
    	size = 20,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    myScoreLabel:setAnchorPoint(0, 0.5)
    myScoreLabel:setPosition(15, 845)
    self.mParentLayer:addChild(myScoreLabel)
    self.mMyScoreLabel = myScoreLabel

    --剩余转盘券
    local goodsName = GoodsModel.items[tempPrice[1].modelId].name
    local resCountLabel = ui.newLabel({
    	text = TR("剩余%s：%s%s", goodsName, Enums.Color.eOrangeH, self.mCount),
    	size = 20,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    resCountLabel:setAnchorPoint(0, 0.5)
    resCountLabel:setPosition(465, 40)
    self.mParentLayer:addChild(resCountLabel)
    self.mResCountLabel = resCountLabel

    --剩余抽奖次数
    local leftNumLabel = ui.newLabel({
        text = TR("剩余幸运点：%s%s", Enums.Color.eOrangeH, self.mNum),
        size = 20,
        outlineColor = Enums.Color.eOutlineColor,
        })
    leftNumLabel:setAnchorPoint(0, 0.5)
    leftNumLabel:setPosition(20, 40)
    self.mParentLayer:addChild(leftNumLabel)
    self.mLeftNumLabel = leftNumLabel

    --倒计时
    local timeLabel = ui.newLabel({
    	text = TR("活动倒计时：00:00:00"),
    	size = 20,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    timeLabel:setPosition(320, 900)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

	self:updateTime()
	self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end

--兑换弹窗
function ActivityTurntableLayer:exchangePopView()
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
        text = TR("当前积分：#249029%s#46220d（此积分只用于宝箱兑换）", self.mCanExchangeScore),
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

        local rewardList = Utility.analysisStrResList(v.Reward)

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
                if v.Num > self.mCanExchangeScore then
                    ui.showFlashView(TR("积分不足！"))
                    return
                end
                self:requestExchangeReward(v.Num)
            end
            })
        exchangeBtn:setPosition(450, 80)
        layout:addChild(exchangeBtn)

        local needScore = ui.newLabel({
            text = TR("需要积分：%s%s", Enums.Color.eGoldH, v.Num),
            size = 20,
            outlineColor = Enums.Color.eOutlineColor,
            })
        needScore:setPosition(420, 35)
        layout:addChild(needScore)

        rewardListView:pushBackCustomItem(layout)
    end
end

-- 更新时间
function ActivityTurntableLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动结算倒计时:%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动结算倒计时:%s 00:00:00", Enums.Color.eGreenH))
        
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        LayerManager.removeLayer(self)
    end
end

--刷新宝箱状态
function ActivityTurntableLayer:refreshBox()
    if self.mBoxBtn.flashNode then
        self.mBoxBtn:stopAllActions()
        self.mBoxBtn.flashNode:removeFromParent()
        self.mBoxBtn.flashNode = nil
        self.mBoxBtn:setRotation(0)
    end
    if self.mIsExchange then
        ui.setWaveAnimation(self.mBoxBtn, nil, true)
    end

    if self.mNum > 0 then
        if self.mNum < 10 then
            self.mTurnBubbleOne:setVisible(true)
            self.mTurnBubbleTen:setVisible(false)
        else
            self.mTurnBubbleOne:setVisible(false)
            self.mTurnBubbleTen:setVisible(true)
        end
    else
        self.mTurnBubbleOne:setVisible(false)
        self.mTurnBubbleTen:setVisible(false)
    end
end

--创建外圈奖励
function ActivityTurntableLayer:createRewardView()
	self.mOutCircle:removeAllChildren()
	self.mInsideCircle:removeAllChildren()

	local r = 190
	local startAngle = 90
	self.mOutRewardList = {}
	self.mInsideRewardList = {}
	for i = 1, #self.mExternalRewardList+1 do
		local posX = r*math.cos((i*(-30)+startAngle)*math.pi/180)
		local posY = r*math.sin((i*(-30)+startAngle)*math.pi/180)
		local pos = cc.p(226+posX, 226+posY)

		local tempInfo = self.mExternalRewardList[i]
		if tempInfo then
			local rewardInfo = Utility.analysisStrResList(tempInfo.Reward)
			local rewardCard = CardNode.createCardNode({
			        resourceTypeSub = rewardInfo[1].resourceTypeSub,
			        modelId = rewardInfo[1].modelId,  
			        num = rewardInfo[1].num, 
			        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
			        -- onClickCallback = function()
			        -- 	-- print(i, "iiiii")
			        -- end
				})
			rewardCard:setPosition(pos)
			rewardCard:setScale(0.6)
			self.mOutCircle:addChild(rewardCard)
			self.mOutRewardList[tempInfo.OrderId] = {}
			self.mOutRewardList[tempInfo.OrderId].PosId = i
		else
			local insideSprite = ui.newSprite("zp_09.png")
			insideSprite:setPosition(pos)
			self.mOutCircle:addChild(insideSprite)
			self.mOutRewardList[0] = {}
			self.mOutRewardList[0].PosId = 12
		end
	end

	for i,v in ipairs(self.mInnerRewardList) do
		local posX = 106*math.cos((i*(-60) + 120)*math.pi/180)
		local posY = 106*math.sin((i*(-60) + 120)*math.pi/180)
		local pos = cc.p(154+posX, 157+posY)

		local rewardInfo = Utility.analysisStrResList(v.Reward)
		local rewardCard = CardNode.createCardNode({
		        resourceTypeSub = rewardInfo[1].resourceTypeSub,
		        modelId = rewardInfo[1].modelId,  
		        num = rewardInfo[1].num, 
		        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},    
		        -- onClickCallback = function()
		        -- 	print(i, "iiiii")
		        -- end
			})
		rewardCard:setPosition(pos)
		rewardCard:setScale(0.6)
		self.mInsideCircle:addChild(rewardCard)

		self.mInsideRewardList[v.OrderId] = {}
		self.mInsideRewardList[v.OrderId].PosId = i
	end
	self.mInsideCircleTag:setRotation(0)
	self.mOutTagNode:setRotation(0)

end

--抽奖回调
function ActivityTurntableLayer:turnTableCallFun(turnType, times, price)
	local tempInfo = Utility.analysisStrResList(price)
	if not turnType then
		if self.mCount < tempInfo[1].num then
			ui.showFlashView(TR("道具数量不足"))
			return
		end
	end
	if times ~= 1 then
		if self.mIsInner then
			ui.showFlashView(TR("请先点击抽一次抽取内圈奖励"))
			return
		else
			self:requestLuckyTurntable(turnType, times)
		end
	else
		self:requestLuckyTurntable(turnType, times)
	end
end
--转圈
function ActivityTurntableLayer:turn(isInner, needTurn, targetOrderId, drop)
	if not needTurn then
        ui.ShowRewardGoods(drop)
        if self.mIsInner then
        	MsgBoxLayer.addOKLayer(
        		TR("恭喜您进入内圈，请点击抽一次抽取内圈大奖！"), 
        		TR("提示")
    		)
        end
        return
	end
	if isInner then
		for k,v in pairs(self.mInsideRewardList) do
			if targetOrderId == k then
				self.mTargetId = v.PosId
				self:turnAction(self.mTargetId, drop, true)
			end
		end
	else
		for k,v in pairs(self.mOutRewardList) do
			if targetOrderId == k then
				-- print(targetOrderId, "tag", v.PosId)
				self.mTargetId = v.PosId
				self:turnAction(self.mTargetId, drop, false)
			end
		end
	end
end

function ActivityTurntableLayer:turnAction(posId, drop, isInner)
	local function action(node, angle)
		local createTouchLayer = cc.CallFunc:create(function()
			self.mTouchNode:setSwallowTouches(true)
		end)
		local rotation = cc.RotateTo:create(6, angle + 3600)
		local buffer = cc.EaseExponentialInOut:create(rotation)
		local callFun = cc.CallFunc:create(function()
			node:setRotation(angle)
        	ui.ShowRewardGoods(drop)
			self.mTouchNode:setSwallowTouches(false)
		end)
		local sq = cc.Sequence:create(createTouchLayer, buffer, callFun)
		node:runAction(sq)
	end

	if isInner then
		local tempAngle = (posId%6) * 60 - 30
		action(self.mInsideCircleTag, tempAngle)
		self.mOldTargetIdIn = posId
	else
		local tempAngle = (posId%12) * 30
		action(self.mOutTagNode, tempAngle)
		self.mOldTargetIdOut = posId
	end
end

--=======================================网络请求========================================
--请求信息
function ActivityTurntableLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedLuckyTurntable", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "ReceiveReward")
	        self.mIsInner = data.Value.IsInner
	        self.mEndTime = data.Value.EndTime
	        self.mOneDiamond = data.Value.OneDiamond
	        self.mTenDiamond = data.Value.TenDiamond
	        self.mTenResource = data.Value.TenResource
	        self.mOneResource = data.Value.OneResource
	        self.mTotalScore = data.Value.TotalScore
	        self.mIsExchange = data.Value.IsExchange
	        self.mCount = data.Value.Count
	        self.mRefreshResource = data.Value.RefreshResource
	        self.mInnerRewardList = data.Value.InnerRewardList
	        self.mExternalRewardList = data.Value.ExternalRewardList
            self.mNum = data.Value.Num

	        self.mTuringTag = self.mIsInner

	        self:createInfoView()
	        self:refreshBox()
	        self:createRewardView()
        end
    })
end

--请求兑换信息
function ActivityTurntableLayer:requestGetRewardInfo()
    HttpClient:request({
        moduleName = "TimedLuckyTurntable", 
        methodName = "GetRewardInfo",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            self.mRewardInfo = data.Value.RewardInfo
            self.mCanExchangeScore = data.Value.Score
            self:exchangePopView()
        end
    })
end

--请求兑换
function ActivityTurntableLayer:requestExchangeReward(id)
    HttpClient:request({
        moduleName = "TimedLuckyTurntable", 
        methodName = "Exchange",
        svrMethodData = {id},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            
            self.mCanExchangeScore = data.Value.Score
            self.mCurScoreLabelPop:setString(TR("当前积分：#249029%s#46220d（此积分只用于宝箱兑换）", self.mCanExchangeScore))
	        self.mIsExchange = data.Value.IsExchange
            self:refreshBox()
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

        end
    })
end

--抽奖
function ActivityTurntableLayer:requestLuckyTurntable(type, times)
    HttpClient:request({
        moduleName = "TimedLuckyTurntable", 
        methodName = "LuckyTurntable",
        svrMethodData = {type, times},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
	        self.mTotalScore = data.Value.TotalScore
	        self.mIsExchange = data.Value.IsExchange
	        self.mCount = data.Value.Count
	        self.mCurrentOrderId = data.Value.CurrentOrderId
	        self.mIsInner = data.Value.IsInner
            self.mNum = data.Value.Num

	        self.mMyScoreLabel:setString(TR("我的积分：%s", self.mTotalScore))
	        self.mResCountLabel:setString(TR("剩余转盘券：%s%s", Enums.Color.eOrangeH, self.mCount))
            self.mLeftNumLabel:setString(TR("剩余幸运点：%s%s", Enums.Color.eOrangeH, self.mNum))
            self:refreshBox()

            self:turn(self.mTuringTag, times == 1, self.mCurrentOrderId, data.Value.BaseGetGameResourceList)
            self.mTuringTag = self.mIsInner

        end
    })
end

--刷新奖励
function ActivityTurntableLayer:requestRefreshReward()
    HttpClient:request({
        moduleName = "TimedLuckyTurntable", 
        methodName = "Refresh",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
	        self.mInnerRewardList = data.Value.InnerRewardList
	        self.mExternalRewardList = data.Value.ExternalRewardList
            self:createRewardView()
        end
    })
end

return ActivityTurntableLayer