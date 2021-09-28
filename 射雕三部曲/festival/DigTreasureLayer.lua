--[[
    文件名: DigTreasureLayer.lua
	描述: 挖宝活动
	创建人: lengjiazhi
	创建时间: 2018.6.11
-- ]]
local DigTreasureLayer = class("DigTreasureLayer", function (params)
	return display.newLayer()
end)

function DigTreasureLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mTouchLayer = ui.newStdLayer()
	self:addChild(self.mTouchLayer)

	-- self.mTouchNode = ui.registerSwallowTouch({
	-- 	node = self.mTouchLayer,
	-- 	allowTouch = false,
 --        })

	self.mOldTargetIdOut = 0
	self.mOldTargetIdIn = 0

	self:initUI()

	self:createBottomView()
end

function DigTreasureLayer:onEnterTransitionFinish()
	local activityInfo = ActivityObj:getActivityItem(ModuleSub.eTimedDigTreasure)[1]
	if activityInfo and Player:getCurrentTime() > activityInfo.EndDate then
		LayerManager.removeLayer(self)
		-- 打开排行榜
		self:openRankShow(true)
	else
		self:requestGetInfo()
	end
end

function DigTreasureLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("jrhd_111.jpg")
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
                for i,v in ipairs(self.mInnerRewardInfo) do
                    local list = {}
                    list = Utility.analysisStrResList(v.Reward)
                    list[1].OddsTips = v.OddsTips
                    table.insert(contentList[1], list[1])
                end
                for i,v in ipairs(self.mRewardInfo) do
                    local list = {}
                    list = Utility.analysisStrResList(v.Reward)
                    list[1].OddsTips = v.OddsTips
                    table.insert(contentList[1], list[1])
                end
                local reuleList = {
                    [1] = TR("1.点击金锄挖宝或者铁锄挖宝可以在密地中进行一次挖宝。"),
                    [2] = TR("2.每次挖宝可以随机获得一个物品。"),
                    [3] = TR("3.挖宝物品种类可通过“藏宝预览”查看。"),
                    [4] = TR("4.铁锄头可以通过参与每日挑战活动获得。"),
                    [5] = TR("5.金锄头通过充值获得，每充值120元宝获得一个金锄头，活动结束后金锄头会清空，请及时使用。"),
                    [6] = TR("6.每次挖宝可以获得挖宝积分，挖宝积分达到一定时可以兑换宝箱奖励。"),
                    [7] = TR("7.挖宝积分会累计到排行榜进行排行，排行达到一定时可以领取排行奖励。"),
                    [8] = TR("8.挖宝中有概率获得稀有称号。"),
                    [9] = TR("9.挖宝途中可以消耗元宝选择更换地区挖宝，不同的地区奖励也会不同。"),
                    [10] = TR("10.挖宝有概率挖出秘境，挖出秘境后必须先进入秘境挖宝，秘境中的奖励可以刷新。"),
                }
                for i,v in ipairs(reuleList) do
                    table.insert(contentList[2], v)
                end
                MsgBoxLayer.addprobabilityLayer(TR("概率详情"), contentList)
            else 
                MsgBoxLayer.addRuleHintLayer(TR("规则"),
                {
                    [1] = TR("1.点击金锄挖宝或者铁锄挖宝可以在密地中进行一次挖宝。"),
                    [2] = TR("2.每次挖宝可以随机获得一个物品。"),
                    [3] = TR("3.挖宝物品种类可通过“藏宝预览”查看。"),
                    [4] = TR("4.铁锄头可以通过参与每日挑战活动获得。"),
                    [5] = TR("5.金锄头通过充值获得，每充值120元宝获得一个金锄头，活动结束后金锄头会清空，请及时使用。"),
                    [6] = TR("6.每次挖宝可以获得挖宝积分，挖宝积分达到一定时可以兑换宝箱奖励。"),
                    [7] = TR("7.挖宝积分会累计到排行榜进行排行，排行达到一定时可以领取排行奖励。"),
                    [8] = TR("8.挖宝中有概率获得稀有称号。"),
                    [9] = TR("9.挖宝途中可以消耗元宝选择更换地区挖宝，不同的地区奖励也会不同。"),
                    [10] = TR("10.挖宝有概率挖出秘境，挖出秘境后必须先进入秘境挖宝，秘境中的奖励可以刷新。"),
                })
            end
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    --排行榜
    local rankBtn = ui.newButton({
    	normalImage = "tb_16.png",
    	position = cc.p(595, 840),
    	clickAction = function()
    		self:openRankShow(false)
    	end
    	})
    self.mParentLayer:addChild(rankBtn)

    --宝箱
    local boxBtn = ui.newButton({
    	normalImage = "jrhd_109.png",
    	position = cc.p(578, 390),
    	clickAction = function()
    		self:requestGetRewardInfo()
    	end
    	})
    self.mParentLayer:addChild(boxBtn)
    self.mBoxBtn = boxBtn

    --提示文字
    local tipLabel = ui.newLabel({
        text = TR("在该地区挖宝有机会获得以下奖励"),
        color = Enums.Color.eBlack,
        -- size = 20,
        align = TEXT_ALIGN_CENTER
    })
    tipLabel:setPosition(320, 240)
    self.mParentLayer:addChild(tipLabel)

    local arrow = ui.newSprite("c_77.png")
    arrow:setPosition(600, 750)
    self.mParentLayer:addChild(arrow, 10)
    self.mArrow = arrow


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
end

--创建底部按钮
function DigTreasureLayer:createBottomView()
	local turnGold = ui.newButton({
		normalImage = "c_28.png",
		text = TR("金锄挖宝"),
		clickAction = function()
            self:turnTableCallFun(true)
		end
		})
	turnGold:setPosition(220, 340)
	self.mParentLayer:addChild(turnGold)
    --红点
    turnBubbleGold = ui.createBubble()
    turnBubbleGold:setPosition(cc.p(120, 45))
    turnGold:addChild(turnBubbleGold)
    turnBubbleGold:setVisible(false)
    self.mTurnBubbleGold = turnBubbleGold

	local turnIron = ui.newButton({
		normalImage = "c_33.png",
		text = TR("铁锄挖宝"),
		clickAction = function()
            self:turnTableCallFun(false)
		end
		})
	turnIron:setPosition(420, 340)
	self.mParentLayer:addChild(turnIron)

    --红点
    turnBubbleIron = ui.createBubble()
    turnBubbleIron:setPosition(cc.p(120, 45))
    turnIron:addChild(turnBubbleIron)
    turnBubbleIron:setVisible(false)
    self.mTurnBubbleIron = turnBubbleIron


    --刷新奖励按钮
    local refreshBtn = ui.newButton({
        normalImage = "jrhd_116.png",
        -- text = TR("更换地区"),
        clickAction = function()
            local refreshRes = Utility.analysisStrResList(self.mExternalRefreshResource) 
            MsgBoxLayer.addOKLayer(
                TR("更换地区需要消耗{%s}%s", Utility.getDaibiImage(refreshRes[1].resourceTypeSub, refreshRes[1].modelId), refreshRes[1].num),
                TR("提示"), 
                {
                    {
                        text = TR("确定"),
                        clickAction = function(layerObj)
                            self:requestRefresh(false)
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
    refreshBtn:setPosition(565, 260)
    self.mParentLayer:addChild(refreshBtn, 10)

    --内圈进入按钮
    local innerBtn = ui.newButton({
        normalImage = "jrhd_114.png",
        clickAction = function ()
            self:innerPopView()
        end
        })
    innerBtn:setPosition(400, 650)
    self.mParentLayer:addChild(innerBtn)
    self.mInnerBtn = innerBtn

    local scale1 = cc.ScaleTo:create(0.3, 1.2)
    local scale2 = cc.ScaleTo:create(0.3, 1)
    local scale3 = cc.ScaleTo:create(0.3, 0.9)
    local sq = cc.Sequence:create(scale1, scale2, scale3, scale2)
    local rep = cc.RepeatForever:create(sq)
    innerBtn:runAction(rep)
end


--创建数据相关显示
function DigTreasureLayer:createInfoView()
    --金锄头数量
    local goldNumLabel = ui.newLabel({
        text = TR("剩余金锄头：%s", self.mNum),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        size = 20,
        align = TEXT_ALIGN_CENTER
    })
    goldNumLabel:setPosition(220, 300)
    self.mParentLayer:addChild(goldNumLabel)
    self.mGoldNumLabel = goldNumLabel

    --铁锄头数量
	local ironNumLabel = ui.newLabel({
    	text = TR("剩余铁锄头：%s", self.mCount),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        size = 20,
        align = TEXT_ALIGN_CENTER
    })
    ironNumLabel:setPosition(420, 300)
    self.mParentLayer:addChild(ironNumLabel)
    self.mIronNumLabel = ironNumLabel

    --我的积分
    local myScoreLabel = ui.newLabel({
    	text = TR("当前挖宝积分：%s", self.mTotalScore),
    	size = 20,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    -- myScoreLabel:setAnchorPoint(0, 0.5)
    myScoreLabel:setPosition(320, 400)
    self.mParentLayer:addChild(myScoreLabel)
    self.mMyScoreLabel = myScoreLabel

    --倒计时
    local timeLabel = ui.newLabel({
    	text = TR("活动倒计时：00:00:00"),
    	size = 20,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    timeLabel:setPosition(320, 840)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

	self:updateTime()
	self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    local rewardList = self:handleData(self.mRewardInfo)
    local cardList = ui.createCardList({
            maxViewWidth = 520,
            viewHeight = 100,
            space = 5, 
            cardDataList = rewardList
        })
    cardList:setAnchorPoint(0.5, 0.5)
    cardList:setPosition(320, 170)
    self.mParentLayer:addChild(cardList)
    self.mExternalCardList = cardList
end

--处理数据
function DigTreasureLayer:handleData(rewardInfo)
    local showList = {}
    local rewardList = {}
    for i,v in ipairs(rewardInfo) do
        if v.IsShow then
            table.insert(showList, v.Reward)
        end
    end
    for i,v in ipairs(showList) do
        local tempReward = Utility.analysisStrResList(v)[1]
        tempReward.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        table.insert(rewardList, tempReward)
    end
    return rewardList
end

--挖宝次数选择弹窗
function DigTreasureLayer:digCountPopView(maxNum, tipStr, isGoods)
    local selectCount = 0
    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(600, 410),
        title = TR("选择挖宝次数"),
        btnInfos = {
            {
                text = TR("确定"),
                clickAction = function(layerObj)
                    self:requestDigTreasure(isGoods, selectCount, false)
                    LayerManager.removeLayer(layerObj)
                end
            },
            {
                text = TR("取消"),
                clickAction = function(layerObj)
                    LayerManager.removeLayer(layerObj)
                end
            },
        },
        DIYUiCallback = function(layerObj, mBgSprite, mBgSize)
            local numLabel = ui.newLabel({
                text = TR("当前拥有%s%s,请选择挖宝次数", tipStr, maxNum),
                size = 20,
                color = Enums.Color.eBlack,
                })
            numLabel:setAnchorPoint(0, 0.5)
            numLabel:setPosition(mBgSize.width * 0.05, mBgSize.height * 0.78)
            mBgSprite:addChild(numLabel)

            if isGoods then
                local tempSprite = ui.newSprite("jrhd_113.png")
                tempSprite:setPosition(mBgSize.width * 0.5, mBgSize.height * 0.55)
                mBgSprite:addChild(tempSprite)
            else
                local tempSprite = CardNode.createCardNode({
                    resourcetypeSub = 1605,
                    modelId = 16050346,  
                    cardShowAttrs = {CardShowAttr.eBorder}
                })
                tempSprite:setPosition(mBgSize.width * 0.5, mBgSize.height * 0.55)
                mBgSprite:addChild(tempSprite)
            end

            local selectMax = maxNum <= 10 and maxNum or 10

            local selectCountView = require("common.SelectCountView"):create({
                maxCount = selectMax,
                viewSize = cc.size(540, 150),
                changeCallback = function(count)
                    selectCount = count
                end
            })
            selectCountView:setPosition(mBgSize.width / 2, 130)
            mBgSprite:addChild(selectCountView)
        end
    })
end

--兑换弹窗
function DigTreasureLayer:exchangePopView()
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

    for i,v in ipairs(self.mBoxRewardInfo) do
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
function DigTreasureLayer:updateTime()
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
function DigTreasureLayer:refreshBox()
    if self.mBoxBtn.flashNode then
        self.mBoxBtn:stopAllActions()
        self.mBoxBtn.flashNode:removeFromParent()
        self.mBoxBtn.flashNode = nil
        self.mBoxBtn:setRotation(0)
    end
    if self.mIsExchange then
        ui.setWaveAnimation(self.mBoxBtn, nil, true)
    end

    self.mTurnBubbleIron:setVisible(self.mCount > 0)
    self.mTurnBubbleGold:setVisible(self.mNum > 0)

end

--抽奖回调
function DigTreasureLayer:turnTableCallFun(isGoods)
    if self.mIsInner then
        ui.showFlashView(TR("请先挖取秘境中的宝物"))
        return
    end
    local tipStr
    local maxNum
    if isGoods then
        tipStr = TR("金锄头")
        maxNum = self.mNum
    else
        tipStr = TR("铁锄头")
        maxNum = self.mCount
    end
    if maxNum > 1 then
        self:digCountPopView(maxNum, tipStr, isGoods)
    elseif maxNum <= 0 then
        ui.showFlashView(TR("%s数量不足", tipStr))
    else
        self:requestDigTreasure(isGoods, 1, false)
    end
end

--称号弹窗
function DigTreasureLayer:DesignationPopView(id)
    local info = DesignationPicRelation.items[id]
    --黑底
    local blackBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    blackBg:setContentSize(640, 1136)
    blackBg:setPosition(0, 0)
    self.mParentLayer:addChild(blackBg, 10000)
    --背景图
    local bgSprite = ui.newSprite("jrhd_112.png")
    bgSprite:setPosition(320, 610)
    blackBg:addChild(bgSprite)

    bgSprite:setScale(0.1)

    --称号名字
    local DesignationName = ui.newLabel({
        text = info.name,
        size = 24,
        color = Enums.Color.eOrange,
        outlineColor = Enums.Color.eBlack,
        })
    DesignationName:setPosition(400, 290)
    bgSprite:addChild(DesignationName)
    --称号图片
    local DesignationPic = ui.newSprite(info.pic..".png")
    DesignationPic:setPosition(385, 205)
    bgSprite:addChild(DesignationPic)

    --返回按钮
    local backBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function ()
            blackBg:removeFromParent()
            blackBg = nil
        end
        })
    backBtn:setPosition(554, 376)
    bgSprite:addChild(backBtn)

    local action = cc.ScaleTo:create(0.3, 1)

    bgSprite:runAction(action)
end

--内圈弹窗
function DigTreasureLayer:innerPopView()
    --弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 782),
        title = TR("世外桃源"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    local PopBgSprite = popLayer.mBgSprite

    local sprite = ui.newSprite("jrhd_115.png")
    sprite:setPosition(299, 480)
    PopBgSprite:addChild(sprite)

    local tipLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        bgSize = cc.size(537, 42),       
        labelStr = TR("恭喜触发世外桃源!!!"),
        fontSize = 22,    
        outlineColor = Enums.Color.eOutlineColor, 
        alignType = ui.TEXT_ALIGN_CENTER,   
        })
    tipLabel:setPosition(299, 695)
    PopBgSprite:addChild(tipLabel)

    local rewardLabel = ui.newLabel({
        text = TR("世外桃源中可以挖出以下奖励："),
        outlineColor = Enums.Color.eBlack,
        size = 22,
        })
    rewardLabel:setAnchorPoint(0, 0.5)
    rewardLabel:setPosition(30, 265)
    PopBgSprite:addChild(rewardLabel)
    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(544, 118))
    grayBgSprite:setPosition(299, 180)
    PopBgSprite:addChild(grayBgSprite)

    local goldDigBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("金锄挖宝"),
        clickAction = function ()
            LayerManager.removeLayer(popLayer)
            self:requestDigTreasure(true, 1, true)
        end
        })
    goldDigBtn:setPosition(110, 55)
    PopBgSprite:addChild(goldDigBtn)

    --金锄头数量
    local goldNumLabel = ui.newLabel({
        text = TR("剩余金锄头：%s", self.mNum),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        size = 20,
        align = TEXT_ALIGN_CENTER
    })
    goldNumLabel:setPosition(110, 100)
    PopBgSprite:addChild(goldNumLabel)

    local refreshBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("刷新奖励"),
        clickAction = function ()
            self:requestRefresh(true)
        end
        })
    refreshBtn:setPosition(300, 55)
    PopBgSprite:addChild(refreshBtn)

    local refreshRes = Utility.analysisStrResList(self.mInnerRefreshResource)
    local refreshCostLabel = ui.newLabel({
        text = string.format("{%s}%s", Utility.getDaibiImage(refreshRes[1].resourceTypeSub, refreshRes[1].modelId), refreshRes[1].num),
        outlineColor = Enums.Color.eOutlineColor,
        })
    refreshCostLabel:setPosition(299, 100)
    PopBgSprite:addChild(refreshCostLabel)

    local ironDigBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("铁锄挖宝"),
        clickAction = function ()
            LayerManager.removeLayer(popLayer)
            self:requestDigTreasure(false, 1, true)
        end
        })
    ironDigBtn:setPosition(490, 55)
    PopBgSprite:addChild(ironDigBtn)

        --铁锄头数量
    local ironNumLabel = ui.newLabel({
        text = TR("剩余铁锄头：%s", self.mCount),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        size = 20,
        align = TEXT_ALIGN_CENTER
    })
    ironNumLabel:setPosition(490, 100)
    PopBgSprite:addChild(ironNumLabel)

    local rewardList = self:handleData(self.mInnerRewardInfo)
    local cardList = ui.createCardList({
            maxViewWidth = 500,
            viewHeight = 100,
            space = 5, 
            cardDataList = rewardList
        })
    cardList:setAnchorPoint(0.5, 0.5)
    cardList:setPosition(299, 175)
    PopBgSprite:addChild(cardList)
    self.mInnerCardList = cardList
end

function DigTreasureLayer:openRankShow(isCleanUp)
	LayerManager.addLayer({
        name = "activity.CommonActivityRankLayer",
        data = {
            moduleName = "TimedDigTreasure",
            methodNameRank = "GetRank",
            methodNameReward = "GetRankReward",
            scoreName = TR("积分"),
        },
        cleanUp = isCleanUp,
    })
end

function DigTreasureLayer:randDomArrowPos()
    local posX = math.random(80, 600)
    local posY = math.random(450, 700)
    self.mArrow:setPosition(posX, posY)
end
--=======================================网络请求========================================
--请求信息
function DigTreasureLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedDigTreasure", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
            -- dump(data, "data")
            self.mDigTreasureInfo = data.Value.DigTreasureInfo
	        self.mEndTime = data.Value.EndTime
	        self.mTotalScore = data.Value.DigTreasureInfo.TotalScore
	        self.mIsExchange = data.Value.DigTreasureInfo.IsExchange
	        self.mCount = data.Value.DigTreasureInfo.Count
            self.mNum = data.Value.DigTreasureInfo.Num
            self.mRewardInfo = data.Value.ExternalRewardInfo
            self.mInnerRefreshResource = data.Value.DigTreasureInfo.InnerRefreshResource
            self.mExternalRefreshResource = data.Value.DigTreasureInfo.ExternalRefreshResource
            self.mIsInner = data.Value.DigTreasureInfo.IsInner
            self.mInnerRewardInfo = data.Value.InnerRewardInfo

	        self:createInfoView()
	        self:refreshBox()
            self.mInnerBtn:setVisible(self.mIsInner)
            self:randDomArrowPos()
        end
    })
end

--请求兑换信息
function DigTreasureLayer:requestGetRewardInfo()
    HttpClient:request({
        moduleName = "TimedDigTreasure", 
        methodName = "GetRewardInfo",
        svrMethodData = {},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data)
            self.mBoxRewardInfo = data.Value.RewardInfo
            self.mCanExchangeScore = data.Value.Score
            self:exchangePopView()
        end
    })
end

--请求兑换
function DigTreasureLayer:requestExchangeReward(id)
    HttpClient:request({
        moduleName = "TimedDigTreasure", 
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
function DigTreasureLayer:requestDigTreasure(type, times, isInner)
    HttpClient:request({
        moduleName = "TimedDigTreasure", 
        methodName = "Dig",
        svrMethodData = {type, times, isInner},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "dig")
            local effect = ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_wabaotexiao",
                position = cc.p(320, 568),
                loop = false,
            })

            self.mDigTreasureInfo = data.Value.DigTreasureInfo
            self.mTotalScore = data.Value.DigTreasureInfo.TotalScore
            self.mIsExchange = data.Value.DigTreasureInfo.IsExchange
            self.mCount = data.Value.DigTreasureInfo.Count
            self.mNum = data.Value.DigTreasureInfo.Num
            self.mIsInner = data.Value.DigTreasureInfo.IsInner

	        self.mMyScoreLabel:setString(TR("我的积分：%s", self.mTotalScore))
	        self.mIronNumLabel:setString(TR("剩余铁锄头：%s", self.mCount))
            self.mGoldNumLabel:setString(TR("剩余金锄头：%s", self.mNum))
            self:refreshBox()
            self.mInnerBtn:setVisible(self.mIsInner)

            if data.Value.DesignationId > 0 then
                self:DesignationPopView(data.Value.DesignationId) 
            end

            if data.Value.BaseGetGameResourceList then
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)    
            end
        end
    })
end

--刷新奖励
function DigTreasureLayer:requestRefresh(isInner)
    HttpClient:request({
        moduleName = "TimedDigTreasure", 
        methodName = "Refresh",
        svrMethodData = {isInner},
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "data")
            if isInner then
                self.mInnerRewardInfo = data.Value.Reward
                self.mInnerCardList.refreshList(self:handleData(self.mInnerRewardInfo))
            else
                self.mRewardInfo = data.Value.Reward
                self.mExternalCardList.refreshList(self:handleData(self.mRewardInfo))
                self:randDomArrowPos()
            end
        end
    })
end

return DigTreasureLayer