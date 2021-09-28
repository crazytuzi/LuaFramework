--[[
    文件名：ActivityZhengDianMiaoSha.lua
    文件描述：限时活动-整点秒杀
    创建人：lengjiazhi
    创建时间：2017.11.07
]]

local ActivityZhengDianMiaoSha = class("ActivityZhengDianMiaoSha",function()
    return display.newLayer()
end)

function ActivityZhengDianMiaoSha:ctor()
	self:requestGetInfo()
	self:initUI()
end

function ActivityZhengDianMiaoSha:initUI()
	--屏蔽下层触控
    ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefreshLayer = ui.newStdLayer()
	self:addChild(self.mRefreshLayer)

	local garyBgSprite = ui.newScale9Sprite("c_17.png", cc.size(640, 1136))
	garyBgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(garyBgSprite)

	local bgSprite = ui.newSprite("jrhd_36.png")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	local buyBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("抢"),
		clickAction = function()
			self:requestBuy()
		end
		})
	buyBtn:setPosition(320, 365)
	self.mParentLayer:addChild(buyBtn)
	self.mBuyBtn = buyBtn

    --创建返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        fontSize = 24,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(cc.p(580, 830))
    self.mParentLayer:addChild(closeBtn)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(65, 865),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.活动期间早上10:00到晚上10：00开启全服抢购，抢购期间秒杀道具不定时上架，库存有限，抢完即止。"),
                [2] = TR("2.每位用户每轮抢购最多可抢购1次，每轮抢购倒计时结束后，直接进入下一轮抢购。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    local arrowL = ui.newSprite("c_26.png")
    arrowL:setPosition(115, 510)
    self.mParentLayer:addChild(arrowL)
    arrowL:setRotation(180)

    local arrowR = ui.newSprite("c_26.png")
    arrowR:setPosition(535, 510)
    self.mParentLayer:addChild(arrowR)

    local perViewBtn = ui.newButton({
        normalImage = "c_79.png",
        clickAction = function()
            self:createPopView()
        end
        })
    perViewBtn:setPosition(535, 610)
    self.mParentLayer:addChild(perViewBtn)
end

function ActivityZhengDianMiaoSha:createPopView()
    --弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(586, 760),
        title = TR("秒杀预览"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    local garyBgSprite = ui.newScale9Sprite("c_17.png", cc.size(530, 600))
    garyBgSprite:setPosition(293, 390)
    self.mPopBgSprite:addChild(garyBgSprite)

    local cancleBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        clickAction = function ()
            LayerManager.removeLayer(self.mPopLayer)
        end
        })
    cancleBtn:setPosition(293, 55)
    self.mPopBgSprite:addChild(cancleBtn)

    -- 奖励列表控件
    local tempLIstView = ccui.ListView:create()
    tempLIstView:setDirection(ccui.ScrollViewDir.vertical)
    tempLIstView:setBounceEnabled(true)
    tempLIstView:setContentSize(cc.size(580, 590))
    tempLIstView:setItemsMargin(5)
    tempLIstView:setGravity(ccui.ListViewGravity.centerHorizontal)
    tempLIstView:setAnchorPoint(cc.p(0.5, 1))
    tempLIstView:setPosition(293, 685)
    self.mPopBgSprite:addChild(tempLIstView)

    for i,v in ipairs(self.mPerReward) do
        local goodsList = Utility.analysisStrResList(v)

        local layout = ccui.Layout:create()
        layout:setContentSize(520, 180)

        local bgSprite = ui.newScale9Sprite("c_54.png", cc.size(518, 180))
        bgSprite:setPosition(260, 90)
        layout:addChild(bgSprite)

        local rankLabel = ui.newLabel({
            text = TR("第 %s 轮", i),
            outlineColor = Enums.Color.eOutlineColor,
            size = 24,
            })
        rankLabel:setPosition(260, 160)
        layout:addChild(rankLabel)

        local cardList = ui.createCardList({
                maxViewWidth = 500, -- 显示的最大宽度
                viewHeight = 120, -- 显示的高度，默认为120
                space = 10, -- 卡牌之间的间距, 默认为 10
                cardDataList = goodsList
            })
        cardList:setPosition(260, 70)
        cardList:setAnchorPoint(0.5, 0.5)
        layout:addChild(cardList)

        tempLIstView:pushBackCustomItem(layout)
    end

end

--中间信息展示
function ActivityZhengDianMiaoSha:infoView()
	self.mRefreshLayer:removeAllChildren()

	--库存数量
	local leftNumLabel = ui.newLabel({
		text = TR("库存：#18fefb%s", self.mRewardInfo.GlobalNum),
		-- color = ,
		outlineColor = cc.c3b(0x4c, 0x08, 0x08),
		size = 20,
		})
	leftNumLabel:setAnchorPoint(0, 0.5)
	leftNumLabel:setPosition(405, 410)
	self.mRefreshLayer:addChild(leftNumLabel)

	--活动倒计时
	local timeLabel = ui.newLabel({
		text = TR("活动倒计时："),
		color = cc.c3b(0xf5, 0xf3, 0x66),
		size = 20,
		outlineColor = cc.c3b(0x4c, 0x08, 0x08),
		})
	timeLabel:setPosition(235, 680)
	timeLabel:setAnchorPoint(0, 0.5)
	self.mRefreshLayer:addChild(timeLabel)
	self.mTimeLabel = timeLabel

	--下一次刷新倒计时
	local refreshTimeLabel = ui.newLabel({
		text = "00:00",
		color = cc.c3b(0xf8, 0x33, 0x34),
		size = 18,
		})
	refreshTimeLabel:setAnchorPoint(0, 0.5)
	refreshTimeLabel:setPosition(215, 320)
	self.mRefreshLayer:addChild(refreshTimeLabel)
	self.mRefreshTimeLabel = refreshTimeLabel

	--价格
	local priceLabel = ui.newLabel({
		text = self.mRewardInfo.NeedNum,
		outlineColor = cc.c3b(0x4c, 0x08, 0x08),
		size = 20,
		})
	priceLabel:setAnchorPoint(0, 0.5)
	priceLabel:setPosition(300, 410)
	self.mRefreshLayer:addChild(priceLabel)

	--奖励列表
	local goodsList = Utility.analysisStrResList(self.mRewardInfo.GetResource)
	local rewardView = ui.createCardList({
			maxViewWidth = 370, 
	        viewHeight = 120, 
	        space = 10, 
	        cardDataList = goodsList
		})
	rewardView:setPosition(320, 510)
	rewardView:setAnchorPoint(0.5, 0.5)
	self.mRefreshLayer:addChild(rewardView)

	self.mBuyBtn:setEnabled(self.mRewardInfo.CanDrawBuyReward)

    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

end

-- 更新时间
function ActivityZhengDianMiaoSha:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    local refreshTimeLeft = self.mRewardInfo.StartTime - Player:getCurrentTime()

    if not self.mRewardInfo.IsCurrent and self.mRewardInfo.StartTime ~= 0 then
        if refreshTimeLeft > 0 then
        	self.mRefreshTimeLabel:setString(TR("距离下次开抢还有：#0679fb%s", MqTime.formatAsDay(refreshTimeLeft)))
        else
        	-- 停止倒计时
	        if self.mSchelTime then
	            self:stopAction(self.mSchelTime)
	            self.mSchelTime = nil
	        end
        	self:requestGetInfo()
        end
    else
    	self.mRefreshTimeLabel:setVisible(false)
    end

    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时：%s",MqTime.formatAsDay(timeLeft)))
        -- print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时：00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        ui.showFlashView(TR("活动已经结束"))
        LayerManager.removeLayer(self)
    end
end

--=======================================网络请求==========================================
--请求信息
function ActivityZhengDianMiaoSha:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedZhengdianMiaosha",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
            	if response.Status == -10702 then
            		LayerManager.removeLayer(self)
            	end
                return
            end
            -- dump(response)
            self.mRewardInfo = response.Value.RewardInfo[1]
            self.mEndTime = response.Value.EndDate
            self.mPerReward = response.Value.PerReward
            self:infoView()
        end
    })
end

--请求信息
function ActivityZhengDianMiaoSha:requestBuy()
    HttpClient:request({
        moduleName = "TimedZhengdianMiaosha",
        methodName = "Exhange",
        svrMethodData = {self.mRewardInfo.NumberId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response)
            self.mRewardInfo = response.Value.RewardInfo[1]
            self.mEndTime = response.Value.EndDate
            self:infoView()
            if response.Value.BaseGetGameResourceList then
            	ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            else
            	ui.showFlashView(TR("商品已售空，请等待下一次秒杀开启"))
            end
        end
    })
end

return ActivityZhengDianMiaoSha