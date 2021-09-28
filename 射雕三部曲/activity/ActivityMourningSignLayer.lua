--[[
    文件名：ActivityMourningSignLayer
    描述：悼念签到页面
    创建人：yanghongsheng
    创建时间：2018.10.31
--]]
local ActivityMourningSignLayer = class("ActivityMourningSignLayer", function()
	return display.newLayer()
end)

function ActivityMourningSignLayer:ctor()
	self.mEndTime = 0	-- 活动倒计时
	self.mReceiveList = {}
	self.mRewardConfigList = {}
	self.mSignInfo = {}

	-- 创建标准容器
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

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

	--初始化UI
	self:initUI()

	--获取信息
	self:requestInfo()
end

--初始化UI
function ActivityMourningSignLayer:initUI()
	--创建场景的背景
	local bgSprite = ui.newSprite("jrhd_135.jpg")
	bgSprite:setAnchorPoint(0.5, 1)
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)

	-- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(50, Enums.StardardRootPos.eCloseBtn.y),
        clickAction = function(pSender)
             MsgBoxLayer.addRuleHintLayer(TR("规则"), {
                    TR("1.点亮蜡烛祭奠金庸老先生。"),
                    TR("2.每天只能点亮一次蜡烛。"),
                })
        end
    })
    self.mParentLayer:addChild(ruleBtn)

    -- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 悼念按钮
    local getBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("悼念"),
        position = cc.p(320, 400),
        clickAction = function(pSender)
            self:requestReward()
        end
    })
    self.mParentLayer:addChild(getBtn)
    self.mGetBtn = getBtn

    -- 倒计时
    -- 剩余天数背景
    local timeBgSize = cc.size(350, 54)
    local timeBg = ui.newScale9Sprite("c_25.png", timeBgSize)
    timeBg:setPosition(320, 940)
    self.mParentLayer:addChild(timeBg)
    -- 剩余天数label
    local timeLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    timeLabel:setAnchorPoint(cc.p(0.5, 0.5))
    timeLabel:setPosition(timeBgSize.width*0.5, timeBgSize.height*0.5)
    timeBg:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    --宝箱背景
    local boxBgSprite = ui.newSprite("zr_14.png")
    boxBgSprite:setPosition(320, 255)
    self.mParentLayer:addChild(boxBgSprite)
    self.mCandleTotalLength = boxBgSprite:getContentSize().width
    --宝箱背景
    local boxBgSprite2 = ui.newSprite("zr_15.png")
    boxBgSprite2:setPosition(320, 255)
    self.mParentLayer:addChild(boxBgSprite2)
end

function ActivityMourningSignLayer:createTimeUpdate()

    if self.mTimeLabel.timeUpdate then
        self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
        self.mTimeLabel.timeUpdate = nil
    end

    self.mTimeLabel.timeUpdate = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("倒计时：#ffe74800:00:00"))
            self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
            self.mTimeLabel.timeUpdate = nil
            LayerManager.removeLayer(self)
        end
    end, 1)
end

function ActivityMourningSignLayer:refreshCandle()
    if not self.mCandleParent then
        self.mCandleParent = cc.Node:create()
        self.mParentLayer:addChild(self.mCandleParent)
    end
    self.mCandleParent:removeAllChildren()

    local space = self.mCandleTotalLength / #self.mRewardConfigList
    local posY = 220
    for i, reward in ipairs(self.mRewardConfigList) do
        local isLight = self.mSignInfo.Num >= reward.Num
        local goodsList = Utility.analysisStrResList(reward.Reward)
        local candleBtn = ui.newButton({
                normalImage = isLight and "jrhd_137.png" or "jrhd_136.png",
                clickAction = function ()
                    MsgBoxLayer.addPreviewDropLayer(goodsList, nil, TR("宝箱奖励"))
                end,
            })
        local canleSize = candleBtn:getContentSize()
        candleBtn:setPosition(i*space-canleSize.width*0.5, posY)
        candleBtn:setAnchorPoint(cc.p(0.5, 0))
        self.mCandleParent:addChild(candleBtn)

        candleBtn:setTouchEnabled(not isLight)
    end
end

function ActivityMourningSignLayer:refreshUI()
    -- 刷新按钮
    self.mGetBtn:setEnabled(self.mSignInfo.IfCanSign and not (self.mSignInfo.Num >= #self.mRewardConfigList))
    -- 刷新蜡烛
    self:refreshCandle()
end

--==================网络请求相关==================
-- 请求数据
function ActivityMourningSignLayer:requestInfo()
	HttpClient:request({
        moduleName = "TimedSign",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function (data)
        	if not data or data.Status ~= 0 then 
                return 
            end
            self.mEndTime = data.Value.EndTime
            self.mSignInfo = data.Value.TimedSignInfo

            local receiveInfo = string.splitBySep(data.Value.TimedSignInfo.RewardIdStr or "")
            
            self.mRewardConfigList = data.Value.TimedSignRewardConfig
            table.sort(self.mRewardConfigList, function (reward1, reward2)
                return reward1.Num < reward2.Num
            end )

            self:refreshUI()

            self:createTimeUpdate()
        end,
    })
end

-- 请求领奖
function ActivityMourningSignLayer:requestReward()
	HttpClient:request({
        moduleName = "TimedSign",
        methodName = "Sign",
        svrMethodData = {},
        callback = function(data)
            if not data or data.Status ~= 0 then 
                return 
            end
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self.mSignInfo = data.Value.TimedSignInfo
        	
            self:refreshUI()
        end,
    })
end

return ActivityMourningSignLayer