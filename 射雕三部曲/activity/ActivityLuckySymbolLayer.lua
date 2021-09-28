--[[
    文件名: ActivityLuckySymbolLayer.lua
	描述: 钱庄(招财树)页面, 模块Id为：ModuleSub.eLuckySymbol
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityLuckySymbolLayer = class("ActivityLuckySymbolLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivityLuckySymbolLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 铜币列表
    self.mFishes = {}
    -- 激活特效列表
    self.mLiangs = {}

	-- 初始化页面控件
	self:initUI()

	if not self.mLayerData then  -- 证明是第一次进入该页面
		-- 请求数据
		self:requestZcsf()
	else
        -- 刷新数据
		self:refreshLayer()
	end
end

-- 获取恢复数据
function ActivityLuckySymbolLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityLuckySymbolLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("jc_33.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    local bgSize = bgSprite:getContentSize()
    -- local bgSprite = self.mParentLayer
    -- self.mBgSprite = bgSprite

    -- 人物特效
    self.heroEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "ui_effect_qianzhuan",
            position = cc.p(332, 568),
            loop = true,
            endRelease = true
        })
    self.heroEffect:addAnimation(0, "daiji", true)
    -- 背景图2
    local bg2Sprite = ui.newSprite("jc_34.png")
    bg2Sprite:setPosition(320, 568)
    self.mParentLayer:addChild(bg2Sprite)
    self.mBgSprite = bg2Sprite

    -- 下面背景图
    local bottomSprite = ui.newScale9Sprite("c_39.png", cc.size(304,210))
    bottomSprite:setPosition(320, 290)
    self.mBgSprite:addChild(bottomSprite)
    -- -- 聚宝盆
    -- self.mPenEffect = ui.newEffect({
    --     parent = bgSprite,
    --     effectName = "effect_ui_zhaocaishu",
    --     animation = "daiji",
    --     scale = 0.9,
    --     position = cc.p(320, 370),
    --     loop = true,
    --     endRelease = false,
    -- })

    -- --需要元宝背景
    -- local sp = ui.newSprite("jchd_09.png")
    -- sp:setPosition(cc.p(320, 265))
    -- bgSprite:addChild(sp)

    -- 需要元宝个数
    self.needDiamondNum = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eDiamond,
        number = 100,
        fontColor = Enums.Color.eGold,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 1,
    })
    self.needDiamondNum:setPosition(320, 210)
    self.mBgSprite:addChild(self.needDiamondNum)

    -- 倒计时标签
    self.mCurrentAdditionLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
    })
    self.mCurrentAdditionLabel:setPosition(320, 124)
    self.mBgSprite:addChild(self.mCurrentAdditionLabel, 1)
    self.mCurrentAdditionLabel:setVisible(false)

    -- 下次招财获得
    local nextTimeBonusLabel = ui.newLabel({
        text = TR("下次招财获得:"),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        size = 22,
    })
    nextTimeBonusLabel:setAnchorPoint(cc.p(1, 0.5))
    nextTimeBonusLabel:setPosition(345, 360)
    self.mBgSprite:addChild(nextTimeBonusLabel)

    --下次招募获得金钱
    local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    self.mNextTimeBonusNumberLabel = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eGold,
        number = ZcsfTypeModel.items[1].rawGold * currLv,
        fontColor = Enums.Color.eGold,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
    })
    self.mNextTimeBonusNumberLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mNextTimeBonusNumberLabel:setPosition(cc.p(355, 360))
    self.mBgSprite:addChild(self.mNextTimeBonusNumberLabel)

    -- 保底收益背景图
    local topSprite = ui.newScale9Sprite("c_25.png", cc.size(366, 54))
	topSprite:setPosition(320, 925)
    self.mBgSprite:addChild(topSprite)
    self.mTopSprite = topSprite

    -- 保底收益
    self.mBaoDiLabel = ui.newLabel({
        text = TR("保底收益:"),
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mBaoDiLabel:setPosition(topSprite:getContentSize().width * 0.35, topSprite:getContentSize().height * 0.5)
    topSprite:addChild(self.mBaoDiLabel)

    -- 招财按钮
    local chargeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("招财"),
        clickAction = function()
            -- 需要元宝
            local id = self.mLayerData.ZcNum + 1
            if id >= 10 then
                id = 10
            end
            local diamondNum = ZcsfUseRelation.items[id].useDiamond
            local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond, diamondNum, true)
            if isEnough then
                self:requestZcsfZC()
            end
        end
    })
    chargeBtn:setAnchorPoint(cc.p(0.5, 0))
    chargeBtn:setPosition(320, 230)
    self.mBgSprite:addChild(chargeBtn)

    -- 剩余次数
    self.mRemainNumLabel = ui.newLabel({
        text = TR("剩余次数: %d", 1),
        color = Enums.Color.eWhite,
        size = 22,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
    })
    self.mRemainNumLabel:setAnchorPoint(cc.p(0.5, 0))
    self.mRemainNumLabel:setPosition(320, 290)
    self.mBgSprite:addChild(self.mRemainNumLabel)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    -- 创建铜币资源
    -- self:createFishes()
end

-- 创建铜币资源
function ActivityLuckySymbolLayer:createFishes()
	self.fishInfo = {
        {
            skeleton = "jingbi_04",
        },
        {
            skeleton = "jingbi_05",
        },
        {
            skeleton = "jingbi_03",
        },
        {
            skeleton = "jingbi_02",
        },
        {
            skeleton = "jingbi_01",
        },
    }

    for k, info in ipairs(self.fishInfo) do
        local bindingLoad = self.mPenEffect:bindBoneNode(info.skeleton)
        self.mBindingLoad = bindingLoad
        bindingLoad:setName("R")

        local flashEffect = ui.newEffect({
            parent = bindingLoad,
            effectName = "effect_ui_zhaocaishu",
            animation = "jingbi",
            loop = true,
            endRelease = false,
        })
        table.insert(self.mFishes, flashEffect)

        local liangEffect = ui.newEffect({
            parent = bindingLoad,
            effectName = "effect_ui_zhaocaishu",
            animation = "jingbi",
            loop = true,
            endRelease = false,
        })
        liangEffect:setVisible(false)
        table.insert(self.mLiangs, liangEffect)

        if k <= 3 then
            flashEffect:setRotationSkewY(180)
            liangEffect:setRotationSkewY(180)
        end
    end
end

--刷新数据
function ActivityLuckySymbolLayer:refreshLayer()
	-- 需要元宝
    local id = self.mLayerData.ZcNum + 1
    if id >= 10 then
        id = 10
    end
    self.needDiamondNum.setNumber(ZcsfUseRelation.items[id].useDiamond)

    -- 剩余次数
    local currVipLv = PlayerAttrObj:getPlayerAttrByName("Vip")
    local remainNum = VipModel.items[currVipLv].ZCSFMaxNum - self.mLayerData.ZcNum
    self.mRemainNumLabel:setString(TR("剩余次数:%s%d", Enums.Color.eNormalWhiteH, remainNum))

    -- 保底数量
    if self.mBaoDi then
        self.mBaoDi:removeFromParent()
    end

    local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    self.mBaoDi = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eGold,
        number = ZcsfTypeModel.items[1].rawGold * currLv,
        fontColor = Enums.Color.eGold,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
    })
    self.mBaoDi:setAnchorPoint(cc.p(0, 0.5))
    self.mBaoDi:setPosition(self.mTopSprite:getContentSize().width * 0.5, self.mTopSprite:getContentSize().height * 0.5)
    self.mTopSprite:addChild(self.mBaoDi)

    if self.mLayerData.ActiveSF > 0 then
        -- 倒计时
        self.schelTime = Utility.schedule(self, self.upTime, 1.0)
        self.mCurrentAdditionLabel:setVisible(true)

        -- for i = 1, 5 do
        --     self.mFishes[i]:setVisible(false)
        --     self.mLiangs[i]:setVisible(true)
        -- end
    end

    -- 修改下次获得铜币数量
    local bonusLevel = (self.mLayerData.ActiveSF and self.mLayerData.ActiveSF > 0) and self.mLayerData.ActiveSF or 1
    local bonusNumber = ZcsfTypeModel.items[bonusLevel].rawGold * currLv
    self.mNextTimeBonusNumberLabel.setNumber(bonusNumber)
end

-- 掉币
function ActivityLuckySymbolLayer:playZCEffect()
    -- 声音
    MqAudio.playEffect("activity_caishen.mp3")
    -- 切换动作
    self.heroEffect:setAnimation(0, "diu", false)
    self.heroEffect:addAnimation(0, "daiji", true)
end

--倒计时显示
function ActivityLuckySymbolLayer:upTime()
    local remainTime = self.mLayerData.LoseEffTime - Player:getCurrentTime()
    self.mCurrentAdditionLabel:setString(TR("(铜币加成%s后消失)", MqTime.formatAsHour(remainTime)))
    self.mCurrentAdditionLabel:setVisible(remainTime > 0)

    if self.mLayerData.LoseEffTime - Player:getCurrentTime() == 0 then
        -- 到达系统自动刷新时间
        self:requestZcsf()
    end
end

------------------------网络相关---------------------------
--获取玩家招财符信息
function ActivityLuckySymbolLayer:requestZcsf()
    HttpClient:request({
        moduleName = "Zcsf",
        methodName = "ZcsfInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	if not response.Value or response.Status ~= 0 then
                return
            end

            self.mLayerData = response.Value
            -- 更新数据
            self:refreshLayer()
	    end
	})
end

--获取玩家招财信息和显示玩家获取的奖励列表
function ActivityLuckySymbolLayer:requestZcsfZC()
	HttpClient:request({
        moduleName = "Zcsf",
        methodName = "ZC",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
        	if not response.Value or response.Status ~= 0 then
                return
            end

            local value = response.Value
            self.mLayerData = value.ZcsfInfo

            -- 播放动画效果
            self:playZCEffect()
            -- 提示获得的铜币
            ui.showFlashView(TR("获得%d%s", value.GoldInfo.Gold, Utility.getGoodsName(ResourcetypeSub.eGold)))

            -- 更新数据
            self:refreshLayer()
	    end
	})
end

return ActivityLuckySymbolLayer
