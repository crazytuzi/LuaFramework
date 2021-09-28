--[[
	文件名：TeambattleOutPutViewLayer.lua
	描述：西漠查看产出界面
	创建人：yanxingrui
	创建时间： 2016.7.27
--]]

local TeambattleOutPutViewLayer = class("TeambattleOutPutViewLayer", function (params)
	return display.newLayer()
end)


function TeambattleOutPutViewLayer:ctor(params)
    -- 屏蔽下层界面
	ui.registerSwallowTouch({node = self})

	-- 数据
	self.mConfig = params.config or {}    -- 节点配置
    self.mHoldInfo = {}                   -- 节点镇守信息

    -- 该页面的Parent
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 创建顶部资源
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond},
        currentLayerType = Enums.MainNav.ePractice,
    })
    self:addChild(topResource)

    self.mCallback = params.callBack

	-- 获取镇守信息
    self:getHoldInfo()
end

function TeambattleOutPutViewLayer:upTime()
    local timeLeft = self.mHoldInfo.HoldEndTime - Player:getCurrentTime()

	if timeLeft > 0 then
        -- 按钮状态
        self.mGetRewardBtn:setEnabled(false)
    	-- 剩余时间
    	self.mRemainTimeLabel:setString(TR("%s镇守中：%s", Enums.Color.eNormalGreenH, MqTime.formatAsHour(timeLeft)))

    else
    	-- 按钮状态
    	self.mGetRewardBtn:setEnabled(true)

        -- 剩余时间
        self.mRemainTimeLabel:setVisible(false)
    end
end

-- 初始化页面控件
function TeambattleOutPutViewLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("jsxy_02.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 人物模型
	local hero = Figure.newHero({
		heroModelID = self.mHoldInfo.HeroModelID,
		scale = 0.3,
	})
	hero:setPosition(320, 480)
	self.mParentLayer:addChild(hero)

	-- 镇守者名字
	local nameSprite = ui.newScale9Sprite("c_25.png", cc.size(300, 45))
	nameSprite:setPosition(320, 1020)
	self.mParentLayer:addChild(nameSprite)

    local heroColor = Utility.getQualityColor(HeroModel.items[self.mHoldInfo.HeroModelID].quality, 2)
	local nameLabel = ui.newLabel({
		text = TR("镇守者:  %s%s",heroColor, HeroModel.items[self.mHoldInfo.HeroModelID].name),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        font = _FONT_PANGWA,
        outlineSize = 2,
	})
	nameLabel:setPosition(nameSprite:getContentSize().width / 2, nameSprite:getContentSize().height / 2)
	nameSprite:addChild(nameLabel)

	-- 产出道具
    local goodsSize = cc.size(580, 150)
	local goodsSprite = ui.newScale9Sprite("c_65.png", goodsSize)
	goodsSprite:setPosition(320, 250)
	self.mParentLayer:addChild(goodsSprite)

	-- 镇守该节点，有概率产出下列道具：
	local goodsLabel = ui.newLabel({
        text = TR("镇守该节点，有概率产出下列道具"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
	goodsLabel:setPosition(goodsSize.width/2, 130)
	goodsSprite:addChild(goodsLabel)

	local holdDrop = {}
    for k, v in ipairs(TeambattleHoldDropoddsRelation.items) do
        if tonumber(v.nodeModelID) == self.mConfig.ID and v.dropResource ~= "" then
            table.insert(holdDrop, v.dropResource)
        end
    end

	-- 奖励栏
	local cardlist = {}
	for i = 1,#holdDrop do
		local headerInfo = Utility.analysisStrResList(holdDrop[i])[1]
        local card = {
            resourceTypeSub = headerInfo.resourceTypeSub,
            modelId = headerInfo.modelId,
            num = headerInfo.num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        }
        table.insert(cardlist, card)
	end

	local rewardList = ui.createCardList({
		maxViewWidth = 520,
		cardShape = Enums.CardShape.eCircle,
		cardDataList = cardlist,
	})
	rewardList:setAnchorPoint(cc.p(0.5, 0.5))
	rewardList:setPosition(goodsSize.width/2, 50)
	goodsSprite:addChild(rewardList)


	-- 当前镇守累计奖励栏
	local rewardsSprite = ui.newSprite("jsxy_04.png")
	rewardsSprite:setPosition(320, 405)
	self.mParentLayer:addChild(rewardsSprite)
    local rewardSize = rewardsSprite:getContentSize()

	-- 镇守该节点，有概率产出下列道具：
	local rewardsLabel = ui.newLabel({
        text = TR("当前镇守累计奖励"),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 1,
    })
	rewardsLabel:setPosition(rewardSize.width/2, 125)
	rewardsSprite:addChild(rewardsLabel)

	local leiJiList = {}
    for k, oneTimeReward in ipairs(self.mHoldInfo.HoldRewardResource) do
        for _, reward in ipairs(oneTimeReward) do
            local isHave = false
            for k, v in ipairs(leiJiList) do
                if v.ResourceTypeSub == reward.ResourceTypeSub and v.ModelId == reward.ModelId then
                    v.Count = v.Count + reward.Count
                    isHave = true
                end
            end

            if isHave then
            else
                table.insert(leiJiList, reward)
            end
        end
    end

	-- 奖励栏
	local cardlist = {}
	for i = 1,#leiJiList do
		local headerInfo = leiJiList[i]
        local card = {
            resourceTypeSub = headerInfo.ResourceTypeSub,
            modelId = headerInfo.ModelId,
            num = headerInfo.Count,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        }
        table.insert(cardlist, card)
	end

	local rewardList = ui.createCardList({
		maxViewWidth = 520,
		cardShape = Enums.CardShape.eCircle,
		cardDataList = cardlist,
	})
	rewardList:setAnchorPoint(cc.p(0.5, 0.5))
	rewardList:setPosition(rewardSize.width/2, 50)
	rewardsSprite:addChild(rewardList)

	-- 领取奖励按钮
    self.mGetRewardBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取奖励"),
        clickAction = function()
            self:receive(self.mConfig.ID)
        end
    })
    self.mGetRewardBtn:setPosition(320, 145)
    self.mGetRewardBtn:setEnabled(false)
    self.mParentLayer:addChild(self.mGetRewardBtn)

    -- 剩余时间
    self.mRemainTimeLabel = ui.newLabel({
        text = "",
        outlineColor = Enums.Color.eBlack,
        font = _FONT_PANGWA,
        size = 20,
        outlineSize = 2,
    })
    self.mRemainTimeLabel:setPosition(320, 980)
    self.mParentLayer:addChild(self.mRemainTimeLabel)

    local timeLeft = self.mHoldInfo.HoldEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        -- 按钮状态
        self.mGetRewardBtn:setEnabled(false)
        local timeLeft = MqTime.formatAsHour(timeLeft)
        -- 剩余时间
        self.mRemainTimeLabel:setString(TR("镇守中： %s%s", Enums.Color.eNormalGreenH, timeLeft))
    else
        -- 按钮状态
        self.mGetRewardBtn:setEnabled(true)
        -- 剩余时间
        self.mRemainTimeLabel:setVisible(false)
    end

    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end


-----------------------------------网络请求----------------
-- 获取镇守信息
function TeambattleOutPutViewLayer:getHoldInfo()
	HttpClient:request({
        moduleName = "TeambattleHoldinfo",
        methodName = "GetHoldInfo",
        callbackNode = self,
        svrMethodData = {self.mConfig.ID},
        callback = function (response)
            if response.Status == 0 then
                self.mHoldInfo = response.Value.HoldInfo or {}

                -- 初始化界面
                self:initUI()

                -- 倒计时
                self.schelTime = Utility.schedule(self, self.upTime, 1.0)
            end
        end
    })
end

-- 领取巡逻奖励
-- id: 节点ID，必要
function TeambattleOutPutViewLayer:receive(id)
    HttpClient:request({
        moduleName = "TeambattleHoldinfo",
        methodName = "DrawHoldReward",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (response)
            if response.Status == 0 then
                print("领取成功")

                if self.mCallback then
                    self.mCallback()
                end
                -- 关闭窗口
                LayerManager.removeLayer(self)

                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            end
        end
    })
end

return TeambattleOutPutViewLayer
