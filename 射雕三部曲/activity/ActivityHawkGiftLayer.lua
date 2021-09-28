--[[
    文件名: ActivityHawkGiftLayer.lua
	描述: 储钱罐活动-主界面
	创建人: lengjiazhi
	创建时间: 2017.12.21
-- ]]
local ActivityHawkGiftLayer = class("ActivityHawkGiftLayer", function (params)
	return display.newLayer()
end)

function ActivityHawkGiftLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
	self:requestGetInfo()
end

function ActivityHawkGiftLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("xn_01.png")
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
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.充值1元宝可获得1积分。"),
                [2] = TR("2.用积分兑换不同价值宝物赠予神雕，可以获得相应的神雕回礼。"),
                [3] = TR("3.神雕会在收到礼物的时候立即回赠您一份大礼。"),
                [4] = TR("4.送礼当日起，每天也可以在神雕回礼界面领取神雕的回礼，持续7天。"),
                [5] = TR("5.每种礼物只能赠予神雕一次。"),
                [6] = TR("6.神雕的回礼需要您每日领取一次，如果您当日没有领取回礼，回礼就会被神雕自己吃掉！")
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

 	--跳转按钮
    local changeBtn = ui.newButton({
    	normalImage = "xn_14.png",
    	clickAction = function ()
    		LayerManager.addLayer({
    			name = "activity.HawkGiftGetRewardLayer",
    			data = {totalReward = self.mBoxList}
			})
    	end
    	})
    changeBtn:setPosition(485, 820)
    self.mParentLayer:addChild(changeBtn)
    self.mChangeBtn = changeBtn

    -- 充值按钮
    local chargeBtn = ui.newButton({
        normalImage = "tb_21.png",
        position = cc.p(552, 703),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    self.mParentLayer:addChild(chargeBtn)

    local ruleLabel = ui.newLabel({
    	text = TR("活动期间，每充值1元宝获得1积分，集齐一定积分兑换宝物赠与神雕，神雕每天会进行回礼，持续7天。"),
    	color = cc.c3b(0x46, 0x22, 0x0d),
    	dimensions = cc.size(410, 0),
    	size = 21,
    	})
    ruleLabel:setAnchorPoint(0, 0.5)
    ruleLabel:setPosition(60, 700)
    self.mParentLayer:addChild(ruleLabel)

    local myScoreLabel = ui.newLabel({
    	text = TR("我的积分：%s%s", Enums.Color.eOrangeH, 200000),
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    myScoreLabel:setPosition(320, 95)
    self.mParentLayer:addChild(myScoreLabel)
    self.mMyScoreLabel = myScoreLabel

    local timeLabel = ui.newLabel({
    	text = TR("请在送礼活动结束前送礼，送礼倒计时：00:00:00"),
    	color = cc.c3b(0xef, 0xd9, 0xc4),
    	})
    timeLabel:setPosition(320, 35)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    -- 奖励列表控件
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(550, 520))
    -- rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(320, 385)
    self.mParentLayer:addChild(rewardListView)

    self.mRewardListView = rewardListView

end

local BoxPicInfo = {
	[1] = {
		start = "xn_04.png",
		final = "xn_08.png",
		egg = "dj_50261.png",
	},
	[2] = {
		start = "xn_05.png",
		final = "xn_09.png",
		egg = "dj_50260.png",
	},
	[3] = {
		start = "xn_06.png",
		final = "xn_10.png",
		egg = "dj_50259.png",
	},
	[4] = {
		start = "xn_07.png",
		final = "xn_11.png",
		egg = "dj_50262.png",
	},
}
--刷新列表
function ActivityHawkGiftLayer:refreshListView()
	self.mStartBoxList = {}
    self.mTipList = {}
    self.mHaveSendList = {}
	for i,v in ipairs(self.mBoxList) do
        local layout = ccui.Layout:create()
        layout:setContentSize(550, 130)

        local bgSprite = ui.newSprite("xn_03.png")
        bgSprite:setPosition(275, 65)
        layout:addChild(bgSprite)

        local tipLabelS = ui.newLabel({
        	text = TR("送礼立即获得："),
        	color = cc.c3b(0x46, 0x22, 0x0d),
        	size = 20,
        	})
        tipLabelS:setAnchorPoint(0, 0.5)
        tipLabelS:setPosition(128, 102)
        layout:addChild(tipLabelS)

        --立即领取的宝箱按钮
        local startBox = ui.newButton({
        	normalImage = BoxPicInfo[i].start,
        	clickAction = function()
        		self:showBoxView(v.OrderId)
        	end
        	})
        startBox:setPosition(274, 57)
        layout:addChild(startBox)

        table.insert(self.mStartBoxList, startBox)

        local tipLabelF = ui.newLabel({
        	text = TR("七日奖励预览: "),
        	color = cc.c3b(0x46, 0x22, 0x0d),
        	size = 20,
        	})
        tipLabelF:setAnchorPoint(0, 0.5)
        tipLabelF:setPosition(343, 102)
        layout:addChild(tipLabelF)

        --最终宝箱
        local finalBox = ui.newButton({
        	normalImage = BoxPicInfo[i].final,
        	clickAction = function()
        		self:finalRewardPop(v.RewardList)
        	end
        	})
        finalBox:setPosition(489, 57)
        layout:addChild(finalBox)

        --蛋
        local eggSprite = ui.newSprite(BoxPicInfo[i].egg)
        eggSprite:setPosition(70, 76)
        layout:addChild(eggSprite)

        --提示文字带背景
        local tipLabel = ui.createLabelWithBg({
        		bgFilename = "xn_02.png",
		        labelStr = TR("点击送礼"),
		        fontSize = 20,
		        alignType = ui.TEXT_ALIGN_CENTER,
        	})
        tipLabel:setPosition(70, 40)
        layout:addChild(tipLabel)
        table.insert(self.mTipList, tipLabel)

        --需要的积分
        local needScoreLabel = ui.newLabel({
        	text = TR("积分：%s", v.NeedScore),
        	color = cc.c3b(0x46, 0x22, 0x0d),
        	size = 18,
        	})
        needScoreLabel:setPosition(70, 15)
        layout:addChild(needScoreLabel)

        --已领取标识
        local haveSendSprite = ui.newSprite("c_171.png")
        haveSendSprite:setPosition(70, 45)
        layout:addChild(haveSendSprite)
        table.insert(self.mHaveSendList, haveSendSprite)

        --透明送礼按钮
        local saveBtn = ui.newButton({
        	normalImage = "c_83.png",
        	size = cc.size(104, 116),
        	clickAction = function()
        		self:saveSureView(v.OrderId)
        	end
        	})
        saveBtn:setPosition(70, 65)
        layout:addChild(saveBtn)

        self.mRewardListView:pushBackCustomItem(layout)
    end
end

--最终宝箱弹窗
function ActivityHawkGiftLayer:finalRewardPop(rewardInfo)
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(568, 736),
        title = TR("最终奖励"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

     -- 奖励列表控件
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.vertical)
    tempListView:setBounceEnabled(true)
    tempListView:setContentSize(cc.size(530, 640))
    tempListView:setItemsMargin(5)
    tempListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    tempListView:setAnchorPoint(cc.p(0.5, 0.5))
    tempListView:setPosition(284, 350)
    self.mPopBgSprite:addChild(tempListView)

    for i,v in ipairs(rewardInfo) do
    	local layout = ccui.Layout:create()
    	layout:setContentSize(520, 180)

    	local bgSprite = ui.newScale9Sprite("c_54.png", cc.size(520, 180))
    	bgSprite:setPosition(260, 90)
    	layout:addChild(bgSprite)

    	local daysLabel = ui.newLabel({
    		text = TR("第%s天", v.Day),
    		outlineColor = Enums.Color.eOutlineColor,
    		size = 26,
    		})
    	daysLabel:setPosition(260, 160)
    	layout:addChild(daysLabel)

    	local tempReward = Utility.analysisStrResList(v.Reward)
    	local cardList = ui.createCardList({
	    		maxViewWidth = 500, -- 显示的最大宽度
		        viewHeight = 120, -- 显示的高度，默认为120
		        space = 10, -- 卡牌之间的间距, 默认为 10
	        	cardDataList = tempReward,
    		})
    	cardList:setAnchorPoint(0.5, 0.5)
    	cardList:setPosition(260, 70)
    	layout:addChild(cardList)

    	tempListView:pushBackCustomItem(layout)
    end
end

--1次宝箱弹窗
function ActivityHawkGiftLayer:showBoxView(OrderId)
	local info = self.mBoxList[OrderId]
	local rewardList = Utility.analysisStrResList(info.Reward)
	local btnInfo
	if info.RewardStatus ~= 1 then
		btnInfo = {
			text = TR("确定"),
			clickAction = function(layerObj)
				LayerManager.removeLayer(layerObj)
			end
		}
	else
		btnInfo = {
			text = TR("领取"),
			clickAction = function(layerObj)
				self:requestReward(OrderId)
				LayerManager.removeLayer(layerObj)
			end
		}
	end
	MsgBoxLayer.addPreviewDropLayer(
		rewardList, 
		TR("可获得以下物品"), 
		TR("宝箱"), 
		{
			btnInfo
		}, 
		{})
end

--送礼确认框
function ActivityHawkGiftLayer:saveSureView(OrderId)
	local info = self.mBoxList[OrderId]

	if info.IsActive then
		ui.showFlashView(TR("您已经赠送过该礼物了"))
		return
	end

	MsgBoxLayer.addOKCancelLayer(
		TR("您确定要花费%s%s%s积分给神雕赠送礼物吗？", Enums.Color.eOrangeH, info.NeedScore, Enums.Color.eNormalWhiteH),
		TR("提示"),
		{
			text = TR("确定"),
			clickAction = function(layerObj)
				if self.mTotalScore < info.NeedScore then
					ui.showFlashView(TR("积分不足"))
					return
				end
				self:requestActive(info.OrderId)
				LayerManager.removeLayer(layerObj)
			end
		})
end

-- 更新时间
function ActivityHawkGiftLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    -- dump(timeLeft, "timeLeft")
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("请在送礼活动结束前送礼，送礼倒计时：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("请在送礼活动结束前送礼，送礼倒计时：%s00:00:00", Enums.Color.eGreenH))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        LayerManager.addLayer({
   			name = "activity.HawkGiftGetRewardLayer",
			data = {totalReward = self.mBoxList, isOut = true}
		})
    end
end

--刷新宝箱状态
function ActivityHawkGiftLayer:refreshStartBox()
	for i,v in ipairs(self.mStartBoxList) do
		if v.flashNode then
	        v:stopAllActions()
	        v.flashNode:removeFromParent()
	        v.flashNode = nil
	        v:setRotation(0)
	    end
	    if self.mBoxList[i].RewardStatus == 1 then
	        ui.setWaveAnimation(v, nil, true)
	    end
	end

    for i,v in ipairs(self.mBoxList) do
        if v.IsActive then
            self.mTipList[i]:setVisible(false)
            self.mHaveSendList[i]:setVisible(true)
        else
            self.mTipList[i]:setVisible(true)
            self.mHaveSendList[i]:setVisible(false)
        end
    end
end

--小红点
function ActivityHawkGiftLayer:createReddot()
	if self.mHaveReward then
		local function dealReddot(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eCommonHoliday16))
		end
		ui.createAutoBubble({parent = self.mChangeBtn,eventName = RedDotInfoObj:getEvents(ModuleSub.eCommonHoliday16), refreshFunc = dealReddot})
	end
end

--=======================================网络请求========================================
--请求信息
function ActivityHawkGiftLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedHawkgift", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	       	-- dump(data, "data")
	       	self.mEndTime = data.Value.ChargeDaysEndTime
	       	self.mTotalScore = data.Value.TotalScore
	       	self.mBoxList = data.Value.BoxList
	       	self.mHaveReward = data.Value.HaveReward
	       	self.mIsDateOut = data.Value.IsDateOuts

	       	self:createReddot()
			self:refreshListView()
			self.mMyScoreLabel:setString(TR("我的积分：%s%s", Enums.Color.eOrangeH, self.mTotalScore))
			self:refreshStartBox()

            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end

            self:updateTime()
            if not tolua.isnull(self) then
		      self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
            end
        end
    })
end

--请求激活档位
function ActivityHawkGiftLayer:requestActive(id)
	HttpClient:request({
        moduleName = "TimedHawkgift", 
        methodName = "Active",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	       	-- dump(data, "data")
	       	
	       	self.mTotalScore = data.Value.TotalScore
	       	self.mBoxList = data.Value.BoxList
			self:refreshStartBox()

			self.mMyScoreLabel:setString(TR("我的积分：%s%s", Enums.Color.eOrangeH, self.mTotalScore))

        end
    })
end

--请求领取单个宝箱
function ActivityHawkGiftLayer:requestReward(id)
	HttpClient:request({
        moduleName = "TimedHawkgift", 
        methodName = "Reward",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
	       	-- dump(data, "data")

	        if data.Status ~= 0 then
	        	return
	        end
	       	-- dump(data, "data")
	       	
	       	self.mTotalScore = data.Value.TotalScore
	       	self.mBoxList = data.Value.BoxList
			self:refreshStartBox()


			self.mMyScoreLabel:setString(TR("我的积分：%s%s", Enums.Color.eOrangeH, self.mTotalScore))

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)


        end
    })
end

return ActivityHawkGiftLayer