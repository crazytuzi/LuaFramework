--[[
	文件名：WeChatWorldCelebrationLayer.lua
	描述：微信普天同庆红包页面
	创建人：libowen
	创建时间：2016.8.5
--]]

local WeChatWorldCelebrationLayer = class("WeChatWorldCelebrationLayer", function()
	return display.newLayer()
end)

-- 构造函数
function WeChatWorldCelebrationLayer:ctor()
	-- 设置大小
	self:setContentSize(cc.size(640, 1136))

	-- 初始化UI
	self:initUI()

	-- 请求服务器，获取活动信息
	self:requestGetInfo()
end

-- 添加UI元素
function WeChatWorldCelebrationLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("jchd_30.png")
	bgSprite:setPosition(320, 568)
	self:addChild(bgSprite)

    --标题icon
    local icon = ui.newSprite("xshd_32.png")
    icon:setPosition(320, 890)
    bgSprite:addChild(icon)

    -- 描述边框1
    local sp1 = ui.newScale9Sprite("jchd_11.png")
    --sp1:setCapInsets(cc.rect(74, 10, 4, 26))
    sp1:setContentSize(cc.size(580, 490))
    sp1:setAnchorPoint(cc.p(0.5, 1))
    sp1:setPosition(cc.p(320, 782))
    bgSprite:addChild(sp1)

    -- 描述边框
    local sp = ui.newScale9Sprite("jchd_24.png")
    sp:setCapInsets(cc.rect(74, 10, 4, 26))
    sp:setContentSize(cc.size(570, 50))
    --sp:setAnchorPoint(cc.p(0, 0.5))
    sp:setPosition(cc.p(320, 782))
    bgSprite:addChild(sp)

	-- 活动倒计时
	self.mTimeLabel = ui.newLabel({
		text = TR(""),
		size = 27,
		color = Enums.Color.eSkyBlue,
		--outlineColor = Enums.Color.eBlack,
		--outlineSize = 2,
		anchorPoint = cc.p(0.5, 0.5),
		x = 320,
		y = 782
	})
	bgSprite:addChild(self.mTimeLabel)

    -- 充值按钮
    local chargeBtn = ui.newButton({
        -- normalImage = "xshd_1.png",
        normalImage = "tb_18.png",
        position = cc.p(580, 920),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    bgSprite:addChild(chargeBtn)

    local text = {
        [1] = TR("活动一："),
        [2] = TR("1.活动期间玩家首次充值#EDF305 648元 #FFFFFF可获得\")至尊令\"",
        [3] = TR("并触发全服微信普天同庆红包好礼。"),
        [4] = TR("1.普天同庆礼包波阿汉随机#EDF305 1-10元 #FFFFFF现金，可用兑换"),
        [5] = TR("码与官方公众号\")雪鹰领主\TR("兑换奖励。"),
        [6] = TR("3.每次普天同庆礼包仅限前100名领取。")
    }

    local by = 680
    local space = 50
    for k, v in ipairs(text) do
        --介绍
        local des = ui.newLabel({
            text = TR(v),
            color = Enums.Color.eWhite,
            size = 24,
        })
        des:setAnchorPoint(cc.p(0, 1))
        des:setPosition(cc.p(60, by - (k - 1) * space))
        bgSprite:addChild(des)
    end
end

-- 活动倒计时
function WeChatWorldCelebrationLayer:updateTime()
    local timeLeft = self.mActivityInfo.EndDate - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时：" .. MqTime.formatAsDay(timeLeft)))
        print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时：00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 活动结束提示
        MsgBoxLayer.addOKLayer(
            TR("普天同庆活动已结束"),
            TR("提示"),
            {
                text = TR("确定"),
                clickAction = function()
                    LayerManager.addLayer({
                        name = "home.HomeLayer",
                        data = {}
                    })
                end
            },
            nil,
            false
        )
    end
end 

-- 获取数据后，刷新页面
function WeChatWorldCelebrationLayer:refreshLayer()
	-- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end 

------------------网络相关--------------------
-- 请求服务器，获取活动信息
function WeChatWorldCelebrationLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "WechatChargeandlogin",
        methodName = "GetInfo",
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetInfo", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mActivityInfo = data.Value

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

return WeChatWorldCelebrationLayer