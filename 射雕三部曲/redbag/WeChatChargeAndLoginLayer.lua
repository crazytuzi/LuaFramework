--[[
	文件名：WeChatChargeAndLoginLayer.lua
	描述：微信充值登录红包页面
	创建人：libowen
	创建时间：2016.8.5
--]]

local WeChatChargeAndLoginLayer = class("WeChatChargeAndLoginLayer", function()
	return display.newLayer()
end)

-- 构造函数
function WeChatChargeAndLoginLayer:ctor()
	-- 设置大小
	self:setContentSize(cc.size(640, 1136))

	-- 初始化UI
	self:initUI()

	-- 请求服务器，获取活动信息
	self:requestGetInfo()
end

-- 添加UI元素
function WeChatChargeAndLoginLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("jchd_30.png")
	bgSprite:setPosition(320, 568)
	self:addChild(bgSprite)

	--标题icon
	local icon = ui.newSprite("xshd_33.png")
	icon:setPosition(320, 900)
	bgSprite:addChild(icon)

	-- 上面描述背景
    local sp1 = ui.newScale9Sprite("jchd_11.png")
    sp1:setContentSize(cc.size(580, 310))
    sp1:setAnchorPoint(cc.p(0.5, 1))
    sp1:setPosition(cc.p(320, 782))
    bgSprite:addChild(sp1)
	
    local sp = ui.newScale9Sprite("jchd_24.png")
    sp:setCapInsets(cc.rect(74, 10, 4, 26))
    sp:setContentSize(cc.size(570, 50))
    --sp:setAnchorPoint(cc.p(0, 0.5))
    sp:setPosition(cc.p(320, 782))
   	bgSprite:addChild(sp)

   	--活动1
   	local label1 = ui.newLabel({
   		text = TR("活动一：\n特惠首冲  充值任意金额即可获得红包兑换码"),
   		size = 24,
   		color = Enums.Color.eWhite
   	})
   	label1:setAnchorPoint(cc.p(0, 0.5))
   	label1:setPosition(cc.p(70, 710))
   	bgSprite:addChild(label1)

   	--我的兑换码1
   	label1 = ui.newLabel({
   		text = TR("我的兑换码"),
   		size = 24,
   		color = Enums.Color.eWhite
   	})
   	label1:setAnchorPoint(cc.p(0, 0.5))
   	label1:setPosition(cc.p(70, 650))
   	bgSprite:addChild(label1)

   	--兑换码边框
   	local sp = ui.newScale9Sprite("jchd_12.png")
   	sp:setContentSize(cc.size(360, 62))
   	sp:setPosition(cc.p(380, 650))
   	bgSprite:addChild(sp)

   	--活动2
   	self.mLoginDaysLabel = ui.newLabel({
   		text = TR("活动二：\n累计登录  累计登录5天，当前已登录天"),
   		size = 24,
   		color = Enums.Color.eWhite
   	})
   	self.mLoginDaysLabel:setAnchorPoint(cc.p(0, 0.5))
   	self.mLoginDaysLabel:setPosition(cc.p(70, 580))
   	bgSprite:addChild(self.mLoginDaysLabel)

   	--我的兑换码1
   	label2 = ui.newLabel({
   		text = TR("我的兑换码"),
   		size = 24,
   		color = Enums.Color.eWhite
   	})
   	label2:setAnchorPoint(cc.p(0, 0.5))
   	label2:setPosition(cc.p(70, 520))
   	bgSprite:addChild(label2)
   	
   	--兑换码边框
   	local sp1 = ui.newScale9Sprite("jchd_12.png")
   	sp1:setContentSize(cc.size(360, 62))
   	sp1:setPosition(cc.p(380, 520))
   	bgSprite:addChild(sp1)

   	-- 下面描述背景
    local sp2 = ui.newScale9Sprite("jchd_11.png")
    sp2:setContentSize(cc.size(580, 260))
    sp2:setAnchorPoint(cc.p(0.5, 1))
    sp2:setPosition(cc.p(320, 410))
    bgSprite:addChild(sp2)
	
    local sp3 = ui.newScale9Sprite("jchd_24.png")
    sp3:setCapInsets(cc.rect(74, 10, 4, 26))
    sp3:setContentSize(cc.size(570, 50))
    --sp:setAnchorPoint(cc.p(0, 0.5))
    sp3:setPosition(cc.p(320, 410))
   	bgSprite:addChild(sp3)

	-- 活动倒计时
	self.mTimeLabel = ui.newLabel({
		text = TR(""),
		size = 27,
		color = Enums.Color.eSkyBlue,
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

	-- 特惠首充的兑换码
	self.mExchangeLabel1 = ui.newLabel({
		text = TR(""),
		size = 26,
		color = Enums.Color.eGold,
		anchorPoint = cc.p(0.5, 0.5),
		x = 380,
		y = 650,
		align = ui.TEXT_ALIGN_CENTER
	})
	bgSprite:addChild(self.mExchangeLabel1)

	-- 累计登录兑换码
	self.mExchangeLabel2 = ui.newLabel({
		text = TR(""),
		size = 26,
		color = Enums.Color.eGold,
		anchorPoint = cc.p(0.5, 0.5),
		x = 380,
		y = 520,
		align = ui.TEXT_ALIGN_CENTER
	})
	bgSprite:addChild(self.mExchangeLabel2)

	-- -- 累计登录天数
	-- local dayNum = ui.newLabel({
	-- 	text = TR(""),
	-- 	size = 28,
	-- 	color = Enums.Color.eWhite,
	-- 	outlineSize = 2,
	-- 	anchorPoint = cc.p(0.5, 0.5),
	-- 	x = 480,
	-- 	y = 560,
	-- 	align = ui.TEXT_ALIGN_CENTER
	-- })
	-- bgSprite:addChild(dayNum) 

	--活动规则
	local hdgz = ui.newLabel({
		text = TR("活动规则"),
		color = Enums.Color.eSkyBlue,
		size = 24
	})
	hdgz:setPosition(cc.p(320, 410))
	bgSprite:addChild(hdgz)

	local text = {
        [1] = TR("1.活动期间玩家只需充值任意金额即可触发微信"),
        [2] = TR("红包奖励，关注官方公众号\")雪鹰领主\TR("获得随"),
        [3] = TR("机#EDF305 1-100元 #FFFFFF红包或价值 #EDF305 1888元宝 #FFFFFF微信大礼包"),
        [4] = TR("2.每个玩家有两次机会获得微信红包"),
        [5] = TR("3.只有完成特惠首冲活动，才可进行累计登录活动")
    }

    local by = 370
    local space = 40
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
function WeChatChargeAndLoginLayer:updateTime()
    local timeLeft = self.mActivityInfo.EndDate - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时："..MqTime.formatAsDay(timeLeft)))
        print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时：".."00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 活动结束提示
        MsgBoxLayer.addOKLayer(
            TR("微信红包活动已结束"),
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
function WeChatChargeAndLoginLayer:refreshLayer()
	-- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 特惠首充兑换码
    self.mExchangeLabel1:setString(self.mActivityInfo.ValueForCharge == "" and TR("当前未参与活动") or TR(self.mActivityInfo.ValueForCharge))

    -- 累计登录兑换码
    self.mExchangeLabel2:setString(self.mActivityInfo.ValueForLogin == "" and TR("当前未参与活动") or TR(self.mActivityInfo.ValueForLogin))

	-- 累计登录天数
	self.mLoginDaysLabel:setString(TR("活动二：\n累计登录  累计登录5天，当前已登录 %d 天", self.mActivityInfo.LoginDays))    
end 

------------------网络相关--------------------
-- 请求服务器，获取活动信息
function WeChatChargeAndLoginLayer:requestGetInfo()
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

return WeChatChargeAndLoginLayer