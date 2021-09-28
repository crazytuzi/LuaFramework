--[[
	文件名：BlessingExchangLayer.lua
	描述：祝福任务宝箱界面
	创建人：yanghongsheng
	创建时间： 2017.8.20
--]]

local BlessingExchangLayer = class("BlessingExchangLayer", function(params)
	return display.newLayer()
end)


function BlessingExchangLayer:ctor(params)
	-- 当前积分
	self.curScore = 0
	-- 奖励列表
	self.mRewardInfoList = {}
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 736),
        title = TR("积分兑换"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()

	-- 请求数据
	self:requestInfo()
end

function BlessingExchangLayer:initUI()
	local curScoreLabel = ui.newLabel({
	    text = TR("当前积分：#249029%s#46220d（此积分只用于宝箱兑换）", self.curScore),
	    color = cc.c3b(0x46, 0x22, 0x0d),
	    size = 22,
	    })
	curScoreLabel:setAnchorPoint(0, 0.5)
	curScoreLabel:setPosition(30, 640)
	self.mBgSprite:addChild(curScoreLabel)
	self.mCurScoreLabel = curScoreLabel

	--灰色底板
	local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(539, 576))
	grayBgSprite:setPosition(299, 325)
	self.mBgSprite:addChild(grayBgSprite)

	-- 奖励列表控件
	local rewardListView = ccui.ListView:create()
	rewardListView:setDirection(ccui.ScrollViewDir.vertical)
	rewardListView:setBounceEnabled(true)
	rewardListView:setContentSize(cc.size(530, 555))
	rewardListView:setItemsMargin(5)
	rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
	rewardListView:setPosition(299, 325)
	self.mBgSprite:addChild(rewardListView)
	self.mRewardListView = rewardListView
end

function BlessingExchangLayer:refreshUI()
	-- 刷新当前积分
	self.mCurScoreLabel:setString(TR("当前积分：#249029%s#46220d（此积分只用于宝箱兑换）", self.curScore))
	-- 刷新列表
	for i, _ in ipairs(self.mRewardInfoList) do
		self:refreshItem(i)
	end
end

function BlessingExchangLayer:refreshItem(index)
	-- 大小
	local cellSize = cc.size(530, 140)
	-- layout
	local cellItem = self.mRewardListView:getItem(index - 1)
	if not cellItem then
	    cellItem = ccui.Layout:create()
	    cellItem:setContentSize(cellSize)
	    self.mRewardListView:pushBackCustomItem(cellItem)
	end
	cellItem:removeAllChildren()
	-- 数据
	local itemInfo = self.mRewardInfoList[index]
	-- 背景
	local itemBgSprite = ui.newScale9Sprite("c_18.png", cc.size(526, 136))
	itemBgSprite:setPosition(265, 70)
	cellItem:addChild(itemBgSprite)
	-- 奖励
	local rewardList = Utility.analysisStrResList(itemInfo.Reward)
	local cardListView = ui.createCardList({
	    maxViewWidth = 350,
	    viewHeight = 120,
	    space = 10, 
	    cardDataList = rewardList
	    })
	cardListView:setAnchorPoint(0, 0.5)
	cardListView:setPosition(20, 70)
	cellItem:addChild(cardListView)
	-- 兑换
	local exchangeBtn = ui.newButton({
	    normalImage = "c_28.png",
	    text = TR("兑换"),
	    clickAction = function()
	        if itemInfo.Num > self.curScore then
	            ui.showFlashView(TR("积分不足！"))
	            return
	        end
	        self:requestExchange(itemInfo.Num)
	    end
	    })
	exchangeBtn:setPosition(450, 80)
	cellItem:addChild(exchangeBtn)
	-- 积分
	local needScore = ui.newLabel({
	    text = TR("需要积分：%s%s", Enums.Color.eGoldH, itemInfo.Num),
	    size = 20,
	    outlineColor = Enums.Color.eOutlineColor,
	    })
	needScore:setPosition(420, 35)
	cellItem:addChild(needScore)
end

--=======================================网络请求========================================
-- 请求数据
function BlessingExchangLayer:requestInfo()
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "GetRewardInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            self.curScore = data.Value.Score
            self.mRewardInfoList = data.Value.RewardInfo
            table.sort(self.mRewardInfoList, function (item1, item2)
            	return item1.Num < item2.Num
        	end)

            self:refreshUI()
        end
    })
end

-- 请求兑换
function BlessingExchangLayer:requestExchange(needScore)
    HttpClient:request({
        moduleName = "TimedBlessingTaskBase",
        methodName = "Exchange",
        svrMethodData = {needScore},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self.curScore = data.Value.Score
            self.mRewardInfoList = data.Value.RewardInfo
            table.sort(self.mRewardInfoList, function (item1, item2)
            	return item1.Num < item2.Num
        	end)

            self:refreshUI()
        end
    })
end

return BlessingExchangLayer