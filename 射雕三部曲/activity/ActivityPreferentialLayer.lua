--[[
	文件名:ActivityPreferentialLayer.lua
	描述：限时特惠
	创建人：yanghongsheng
    创建时间：2018.12.17
--]]

local ActivityPreferentialLayer = class("ActivityPreferentialLayer", function(params)
    return display.newLayer()
end)


function ActivityPreferentialLayer:ctor()
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgImage = "jrhd_156.png",
    	closeImg = "c_175.png",
        title = "",
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()

	-- 请求服务器
	self:requestInfo()
end

function ActivityPreferentialLayer:initUI()
	-- 活动倒计时
	local timeBg = ui.newScale9Sprite("c_103.png", cc.size(345, 44))
	timeBg:setAnchorPoint(cc.p(0, 0.5))
	timeBg:setPosition(-15, 100)
	self.mBgSprite:addChild(timeBg)

	self.mTimeLabel = ui.newLabel({
	        text = "活动倒计时：00:00:00",
	        color = Enums.Color.eWhite,
	        outlineColor = Enums.Color.eOutlineColor,
	        size = 20,
	    })
	self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
	self.mTimeLabel:setPosition(45, timeBg:getContentSize().height*0.5)
	timeBg:addChild(self.mTimeLabel)
	-- 充值满提示
	self.mChargeNumLabel = ui.newLabel({
			text = "充值满：996元宝可领取",
	        color = Enums.Color.eWhite,
	        outlineColor = Enums.Color.eOutlineColor,
	        size = 25,
		})
	self.mChargeNumLabel:setPosition(450, 140)
	self.mBgSprite:addChild(self.mChargeNumLabel)
	-- 还需多少提示
	self.mNeedChargeLabel = ui.newLabel({
			text = "还需996元宝可获取一次领奖",
	        color = Enums.Color.eWhite,
	        outlineColor = Enums.Color.eOutlineColor,
	        dimensions = cc.size(80, 0),
	        size = 18,
		})
	self.mNeedChargeLabel:setPosition(585, 80)
	self.mBgSprite:addChild(self.mNeedChargeLabel)
	-- 领取按钮
	local getBtn = ui.newButton({
			normalImage = "fx_11.png",
            text = TR("领  取"),
            clickAction = function()
                if self.mBaseInfo.RemainNum <= 0 then
                	ui.showFlashView(TR("领奖次数不足"))
                	return
                end
            	self:requestReward()
            end
		})
	getBtn:setPosition(450, 90)
	self.mBgSprite:addChild(getBtn)
	self.mGetBtn = getBtn
	-- 可领取次数
	self.mGetNumLabel = ui.newLabel({
			text = "可领取次数：5次",
			color = Enums.Color.eWhite,
	        outlineColor = Enums.Color.eOutlineColor,
	        size = 24,
		})
	self.mGetNumLabel:setPosition(450, 40)
	self.mBgSprite:addChild(self.mGetNumLabel)
end

function ActivityPreferentialLayer:createRewardList()
	if self.mRewardView then
		self.mRewardView:removeFromParent()
		self.mRewardView = nil
	end

	local rewardList = Utility.analysisStrResList(self.mBaseInfo.Reward)
	for _, rewardInfo in pairs(rewardList) do
		rewardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
	end
	self.mRewardView = ui.createCardList({
			maxViewWidth = 320,
			cardDataList = rewardList,
		})
	self.mRewardView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mRewardView:setPosition(450, 220)
	self.mBgSprite:addChild(self.mRewardView)
end

-- 创建倒计时
function ActivityPreferentialLayer:createTimeUpdate()
    if self.timeUpdate then
        self.mTimeLabel:stopAction(self.timeUpdate)
        self.timeUpdate = nil
    end

    self.timeUpdate = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时:  #ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:stopAction(self.timeUpdate)
            self.timeUpdate = nil
            self.mTimeLabel:setString(TR("活动倒计时:  #ffe748%00:00:00"))
        end
    end, 1.0)
end


function ActivityPreferentialLayer:refreshLayer()
	-- 修改背景图
	local activityInfo = ActivityObj:getActivityItem(ModuleSub.eCommonHoliday28)[1]
	if activityInfo.ExtraInfo.Pic and activityInfo.ExtraInfo.Pic ~= "" then
		self.mBgSprite:setTexture(activityInfo.ExtraInfo.Pic)
	end
	-- 创建倒计时
	self:createTimeUpdate()
	-- 充值满提示
	self.mChargeNumLabel:setString(TR("充值满：#ffe748%d%s元宝可领取", self.mBaseInfo.ChargeNum, Enums.Color.eWhiteH))
	-- 还需多少提示
	if self.mBaseInfo.NeedChargeNum ~= self.mBaseInfo.ChargeNum and self.mBaseInfo.NeedChargeNum ~= 0 then
		self.mNeedChargeLabel:setString(TR("还需#ffe748%d%s元宝可获取一次领奖", self.mBaseInfo.NeedChargeNum, Enums.Color.eWhiteH))
	else
		self.mNeedChargeLabel:setString("")
	end
	-- 已领取次数
	local hadGetNum = self.mBaseInfo.TotalNum-self.mBaseInfo.RemainNum
	-- 可领取次数
	self.mGetNumLabel:setString(TR("可领取：#ffe748%d/%d%s次", self.mBaseInfo.RemainNum, self.mBaseInfo.MaxNum-hadGetNum, Enums.Color.eWhiteH))
	-- 领取按钮
	self.mGetBtn:setEnabled(self.mBaseInfo.MaxNum > hadGetNum)
end

-----------------------网络相关---------------------
-- 请求信息
function ActivityPreferentialLayer:requestInfo()
	HttpClient:request({
        moduleName = "TimedPreferentialInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mEndTime = response.Value.EndTime
            self.mBaseInfo = response.Value.Info
            self:refreshLayer()
            self:createRewardList()
        end
	})
end

-- 领取奖励
function ActivityPreferentialLayer:requestReward()
		HttpClient:request({
	        moduleName = "TimedPreferentialInfo",
	        methodName = "GetReward",
	        svrMethodData = {},
	        callback = function(response)
	            if not response or response.Status ~= 0 then
	                return
	            end
	            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

	            self.mBaseInfo = response.Value.Info
	            self:refreshLayer()
	        end
		})
end

return ActivityPreferentialLayer