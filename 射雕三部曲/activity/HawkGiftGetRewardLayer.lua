--[[
    文件名: HawkGiftGetRewardLayer.lua
	描述: 储钱罐活动-领取界面
	创建人: lengjiazhi
	创建时间: 2017.12.21
-- ]]
local HawkGiftGetRewardLayer = class("HawkGiftGetRewardLayer", function (params)
	return display.newLayer()
end)

function HawkGiftGetRewardLayer:ctor(params)
    self.mTotalReward = params.totalReward
    self.mIsOut = params.isOut or false

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
    self:requestGetInfo()
end

function HawkGiftGetRewardLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("xn_12.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1035),
        clickAction = function(pSender)
            if self.mIsOut then
                LayerManager.addLayer({
                    name = "home.HomeLayer"
                    })
            else
                LayerManager.removeLayer(self)
            end
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
                [1] = TR("1.充值1元可获得1积分。"),
                [2] = TR("2.用积分兑换不同价值宝物赠予神雕，可以获得相应的神雕回礼。"),
                [3] = TR("3.神雕会在收到礼物的时候立即回赠您一份大礼。"),
                [4] = TR("4.送礼当日起，每天也可以在神雕回礼界面领取神雕的回礼，持续7天。"),
                [5] = TR("5.每种礼物只能赠予神雕一次。"),
                [6] = TR("6.神雕的回礼需要您每日领取一次，如果您当日没有领取回礼，回礼就会被神雕自己吃掉！")
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    -- local underBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 700))
    -- underBgSprite:setAnchorPoint(0.5, 0)
    -- underBgSprite:setPosition(320, 0)
    -- self.mParentLayer:addChild(underBgSprite)

    -- local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(608, 563))
    -- grayBgSprite:setPosition(320, 322)
    -- self.mParentLayer:addChild(grayBgSprite)

    local tipLabel = ui.newLabel({
        text = TR("{%s}在神雕的送礼活动中，赠与#ce6e2e神雕礼物#46220d，可领取#ce6e2e神雕回礼#46220d，每次#ce6e2e神雕回礼#46220d都会有不同的惊喜哟！","c_63.png"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        dimensions = cc.size(545, 0)
        })
    tipLabel:setPosition(320, 685)
    self.mParentLayer:addChild(tipLabel)

    -- 奖励列表控件
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(600, 510))
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(320, 392)
    self.mParentLayer:addChild(rewardListView)

    self.mRewardListView = rewardListView

end
local BoxPicInfo = {
    [1] = {
        final = "xn_08.png",
    },
    [2] = {
        final = "xn_09.png",
    },
    [3] = {
        final = "xn_10.png",
    },
    [4] = {
        final = "xn_11.png",
    },
}
function HawkGiftGetRewardLayer:refreshRewardView()
    self.mRewardListView:removeAllChildren()
    for i,v in ipairs(self.mBoxList) do
        local layout = ccui.Layout:create()
        layout:setContentSize(600, 130)

        local bgSprite = ui.newSprite("xn_13.png")
        bgSprite:setPosition(300, 65)
        layout:addChild(bgSprite)

        local finalBox = ui.newButton({
            normalImage = BoxPicInfo[i].final,
            clickAction = function()
               self:finalRewardPop(self.mTotalReward[i].RewardList) 
            end
            })
        finalBox:setPosition(83, 66)
        layout:addChild(finalBox)

        local tipLabelN = ui.newLabel({
            text = TR("您没有在神雕送礼中赠予神雕礼物，无法获得回礼。"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(350, 0),
            size = 21,
            })
        tipLabelN:setAnchorPoint(0, 0.5)
        tipLabelN:setPosition(150, 65)
        layout:addChild(tipLabelN)

        if v.RewardStatus == 0 or v.RewardStatus == 3 then
            if v.RewardStatus == 3 then
                tipLabelN:setString(TR("神雕回礼已经结束。"))
            end
        else
            tipLabelN:setVisible(false)

            local tipLabel = ui.newLabel({
                text = TR("这是神雕回赠给您的礼物，快快领取吧！"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 18,
                })
            tipLabel:setAnchorPoint(0, 0.5)
            tipLabel:setPosition(140, 106)
            layout:addChild(tipLabel)

            local rewardInfo = Utility.analysisStrResList(v.Reward)
            for i,v in ipairs(rewardInfo) do
                rewardInfo[i].cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
            end
            local cardList = ui.createCardList({
                    maxViewWidth = 360, -- 显示的最大宽度
                    viewHeight = 95, -- 显示的高度，默认为120
                    space = 1, -- 卡牌之间的间距, 默认为 10
                    cardDataList = rewardInfo,
                })
            cardList:setAnchorPoint(0, 0.5)
            cardList:setScale(0.75)
            cardList:setPosition(145, 50)
            layout:addChild(cardList)

            local getBtn = ui.newButton({
                text = TR("领取"),
                normalImage = "c_28.png",
                clickAction = function()
                    self:requestGetReturnReward(v.OrderId)
                end
                })
            getBtn:setPosition(495, 55)
            layout:addChild(getBtn)
            if v.RewardStatus == 2 then
                getBtn:setTitleText(TR("已领取"))
                getBtn:setEnabled(false)
            end

        end
        self.mRewardListView:pushBackCustomItem(layout)
    end
end

--最终宝箱弹窗
function HawkGiftGetRewardLayer:finalRewardPop(rewardInfo)
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

--=======================================网络请求========================================
--请求信息
function HawkGiftGetRewardLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedHawkgift", 
        methodName = "GetRewardInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "data")
            self.mBoxList = data.Value

            self:refreshRewardView()

        end
    })
end

--请求信息
function HawkGiftGetRewardLayer:requestGetReturnReward(id)
    HttpClient:request({
        moduleName = "TimedHawkgift", 
        methodName = "GetReturnReward",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "data")
            self.mBoxList = data.Value.RewardList
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            

            self:refreshRewardView()

        end
    })
end

return HawkGiftGetRewardLayer