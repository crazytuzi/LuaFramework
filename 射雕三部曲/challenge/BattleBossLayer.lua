--[[
	文件名：BattleBossLayer.lua
	描述：行侠仗义页面
	创建人：chenqiang
	创建时间：2017-03-02
]]

local BattleBossLayer = class("BattleBossLayer", function()
	return display.newLayer()
end)

-- 小红点子模块定义
local BossRedDot =
{
	eExchange = "Exchange",
	eSearchBoss = "Goods",
	eBattle = "CanBattle"
}
local tempConfig = Utility.analysisStrResList(LuckbossConfig.items[1].triggerBOSSGoods)
local CASTMODELID = tempConfig[1].modelId

-- 构造函数
function BattleBossLayer:ctor()


	-- 最大挑战次数
	local vipLv = PlayerAttrObj:getPlayerAttrByName("Vip")
	self.mMaxAttackNum = VipModel.items[vipLv].attackLuckBossMaxNum

	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
        	{
				resourceTypeSub = ResourcetypeSub.eFunctionProps,
				modelId = CASTMODELID
			},
			ResourcetypeSub.eVIT,
			ResourcetypeSub.eDiamond
		}
    })
    self:addChild(tempLayer)

	-- 初始化页面控件
	self:initUI()
	-- 注册刷新BOSS信息的事件
	-- Notification:registerAutoObserver(self.mParentLayer, function ()
 --        self:requestGetBossList()
 --    end, EventsName.eBattleBoss)
    -- 请求BOSS列表
	self:requestGetBossList()
end

-- 初始化页面控件
function BattleBossLayer:initUI()
	-- 创建背景
	local bgSprite = ui.newSprite("xxzy_04.jpg")
	bgSprite:setAnchorPoint(0.5, 1)
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)
end

-- 延迟初始化页面
function BattleBossLayer:dealyInitUI()
	-- 清楚原来的控件
	self.mParentLayer:removeAllChildren()

	-- 创建背景
	self.mBgSprite = ui.newSprite("xxzy_04.jpg")
	self.mBgSprite:setAnchorPoint(0.5, 1)
	self.mBgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(self.mBgSprite)

	-- 创建基座
	-- local baseSprite = ui.newSprite("emlx_9.png")
	-- baseSprite:setPosition(320, 500)
	-- self.mBgSprite:addChild(baseSprite)

	self:initBossUI()
end

-- 初始化BOSS页面控件
function BattleBossLayer:initBossUI()
	-- 再击杀boss次数激活高级boss的提示
	local white, lightYellow = Enums.Color.eWhiteH, Enums.Color.eGoldH
	local nextBoss = self.mBattleInfo.NextBoss
	local tempModel = HeroModel.items[nextBoss.BossModelId]

	local tempStr = TR("再击杀%s%d%s次自己的恶徒可触发%s%s", lightYellow, nextBoss.NCount, white, lightYellow, tempModel.name)
	if nextBoss.NCount <= 0 then
		tempStr = TR("下次遭遇的恶徒必定为%s%s", lightYellow, tempModel.name)
	end
	local tempNode = ui.createSpriteAndLabel({
		imgName = "c_25.png",
		scale9Size = cc.size(600, 54),
		labelStr = tempStr,
		fontColor = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	tempNode:setAnchorPoint(cc.p(0.5, 0.5))
	tempNode:setPosition(320, 1045)
	self.mParentLayer:addChild(tempNode)

	-- 积分翻倍提示
	local tempLabel = ui.newLabel({
		text = TR("每天12-14点,18-20点击杀恶徒可获得双倍积分"),
		color = cc.c3b(0x2c, 0xf1, 0x2c),
		outlineColor = Enums.Color.eShadowColor,
		outlineSize = 2,
	})
	tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
	tempLabel:setPosition(320 , 1005)
	self.mParentLayer:addChild(tempLabel)

	-- 创建关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(580, 1040)
	self.mParentLayer:addChild(self.mCloseBtn)

	-- boss形象
	local tempFigure = Figure.newHero({
		parent = self.mBgSprite,
    	heroModelID = nextBoss.BossModelId,
		position = cc.p(320, 500),
		scale = 0.3,
	})

	-- 掉落预览的背景
	local prewBgSize = cc.size(640, 530)
	local prewBgSprite = ui.newScale9Sprite("c_19.png", prewBgSize)
	prewBgSprite:setAnchorPoint(cc.p(0.5, 0))
	prewBgSprite:setPosition(320, 0)
	self.mParentLayer:addChild(prewBgSprite)

	-- 掉落预览标题背景
	local prewTitleSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 54))
	prewTitleSprite:setAnchorPoint(cc.p(0.5, 1))
	prewTitleSprite:setPosition(320, prewBgSize.height - 25)
	prewBgSprite:addChild(prewTitleSprite)
	-- 掉落标题
	local titleLabel = ui.newLabel({
		text = TR("击杀必定掉落以下一种神兵的锻造图:"),
		color = Enums.Color.eGold,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
	titleLabel:setPosition(320, prewBgSize.height - 53)
	prewBgSprite:addChild(titleLabel)

	-- 掉落预览列表
	local tempList = self:getDropPrewList()

	-- 有缘分的排在前面
	local tempTriggerList = {}
	for index, item in pairs(tempList) do
		local treasueModel = TreasureModel.items[item.modelId]
		if treasueModel then
			local tempStatus = FormationObj:getRelationStatus(treasueModel.ID, treasueModel.typeID)
			if tempStatus == Enums.RelationStatus.eTriggerPr then  -- 和上阵人物有羁绊搭配
				table.insert(tempTriggerList, 1, item)
			else
				table.insert(tempTriggerList, item)
			end
		end
	end

	local gridView = require("common.GridView"):create({
		viewSize = cc.size(prewBgSize.width - 20, 220),
		celHeight = 110,
		colCount = 6,
		getCountCb = function()
			return #tempTriggerList
		end,
		createColCb = function(itemParent, colIndex)
			local parentSize = itemParent:getContentSize()
			local itemData = tempTriggerList[colIndex]
			itemData.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
			itemData.cardShape = Enums.CardShape.eCircle
			itemData.allowClick = true

			local tempCard = CardNode.createCardNode(itemData)
		    tempCard:setPosition(parentSize.width * 0.5, parentSize.height * 0.6)
		    tempCard:setScale(0.9)
		    itemParent:addChild(tempCard)

		    -- 显示和上阵主将搭配的标记
		    local treasueModel = TreasureModel.items[itemData.modelId]
		    if treasueModel then
			    local tempStatus = FormationObj:getRelationStatus(treasueModel.ID, treasueModel.typeID)
			    if tempStatus == Enums.RelationStatus.eTriggerPr then  -- 和上阵人物有羁绊搭配
			        tempCard:createStrImgMark("c_57.png", TR("缘分"), 22)
			    end
		    end
		end
	})
	gridView:setAnchorPoint(cc.p(0.5, 1))
	gridView:setPosition(prewBgSize.width / 2, prewBgSize.height - 85)
	prewBgSprite:addChild(gridView)

	-- 创建奖励预览按钮
	self:createRewardStoreBtn()
	-- 创建购买次数按钮
	self:createBuyCountBtn()
	-- 创建操作按钮
	self:createOptBtn()
end

-- 创建奖励兑换按钮
function BattleBossLayer:createRewardStoreBtn()
	local btnInfos = {
		{ -- 奖励兑换
			normalImage = "tb_29.png",
			moduleId = ModuleSub.eBattleBoss,
			moduleSubId = BossRedDot.eExchange,
			clickAction = function()
				LayerManager.addLayer({
					name = "challenge.BossRewardLayer",
					data = {
						battleInfo = self.mBattleInfo,
					},
					cleanUp = false,
					needRestore = true,
				})
			end,
		},
	}
	for index, btnInfo in ipairs(btnInfos) do
		local tempBtn = ui.newButton(btnInfo)
		tempBtn:setPosition(580, 930)
		self.mParentLayer:addChild(tempBtn)

		-- 小红点逻辑
		if btnInfo.moduleId then
			local function dealRedDotVisible(redDotSprite)
				local redDotData = RedDotInfoObj:isValid(btnInfo.moduleId, btnInfo.moduleSubId)
				print("xxxxxxxxx", type(redDotData), redDotData)
				redDotSprite:setVisible(redDotData)
			end
        	ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = tempBtn,
        	    eventName = RedDotInfoObj:getEvents(btnInfo.moduleId, btnInfo.moduleSubId)})
		end
	end
end

-- 创建购买次数按钮
function BattleBossLayer:createBuyCountBtn()
    local buyBtn = ui.newButton({
    	normalImage = "tb_125.png",
		clickAction = function()
			self:showBuyBossCount()
		end
    })
    buyBtn:setPosition(580, 830)
    self.mParentLayer:addChild(buyBtn)
end

-- 创建操作按钮
function BattleBossLayer:createOptBtn()
	local btnInfos = {
		{ -- 搜捕恶徒
			normalImage = "c_33.png",
			text = TR("搜捕恶徒"),
			clickAction = function()
				local goodsNum = GoodsObj:getCountByModelId(CASTMODELID)

				-- -----------------------新手引导(防止出错)-------------------------
				local guideId, _, eventId = Guide.manager:getGuideInfo()
				if eventId == 11306 and goodsNum < 1 then
					Guide.manager:saveGuideStep(guideId, 999, nil, true) -- 跳过整个引导
					Guide.manager:removeGuideLayer()
					return
				end
				-- -------------------------------------------------------------
				if goodsNum < 1 then
					LayerManager.addLayer({
			            name = "hero.DropWayLayer",
			            data = {
			                resourceTypeSub = 1605,
			                modelId = CASTMODELID
			            },
			            cleanUp = false,
			        })
				else
					self:requestTriggerBoss()
				end
			end,
			moduleId = ModuleSub.eBattleBoss,
			moduleSubId = BossRedDot.eSearchBoss
		},
		{ -- 击杀恶徒
			normalImage = "c_28.png",
			text = TR("击杀恶徒"),
			clickAction = function()
				if #self.mBossList == 0 then
					ui.showFlashView(TR("暂无恶徒"))
				else
					LayerManager.addLayer({
						name = "challenge.BossInfoLayer",
						cleanUp = false,
						needRestore = true,
					})
				end
			end,
			moduleId = ModuleSub.eBattleBoss,
			moduleSubId = BossRedDot.eBattle
		}
	}
	local tempSpace = 240
	local startPosX = (640 - #btnInfos * tempSpace) / 2  + tempSpace / 2
	local tempPosY = 150
	for index, btnInfo in ipairs(btnInfos) do
		local tempBtn = ui.newButton(btnInfo)
		tempBtn:setPosition(startPosX + (index - 1) * tempSpace, tempPosY)
		self.mParentLayer:addChild(tempBtn)

		if index == 1 then
			self.mSearchBtn = tempBtn
		elseif index == 2 then
			self.mAssistBtn = tempBtn
		end

		-- 添加界面两个按钮的小红点信息
        local function dealRedDotVisible(redDotSprite)
            local redDotData = RedDotInfoObj:isValid(btnInfo.moduleId, btnInfo.moduleSubId)
            redDotSprite:setVisible(redDotData)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = tempBtn,
            eventName = RedDotInfoObj:getEvents(btnInfo.moduleId, btnInfo.moduleSubId)})
	end

	-- 消耗资源
	local btnSize = self.mSearchBtn:getContentSize()
	local costLabel = ui.newLabel({
		text = TR("消耗: "),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		size = 20,
	})
	costLabel:setAnchorPoint(cc.p(1, 0))
	costLabel:setPosition(btnSize.width * 0.5, btnSize.height + 5)
	self.mSearchBtn:addChild(costLabel)
	-- 创建代币
	local costDaibi, daibiLabel = ui.createDaibiView({
		resourceTypeSub = 1605,
		goodsModelId = CASTMODELID,
		fontSize = 20,
		number = 1,
		fontColor = cc.c3b(0xff, 0xed, 0x4c),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	costDaibi:setAnchorPoint(cc.p(0, 0))
	costDaibi:setPosition(btnSize.width * 0.5, btnSize.height - 2)
	self.mSearchBtn:addChild(costDaibi)
	self.mCostDaibi = costDaibi
	self.mDaibiLabel = daibiLabel
	local goodsNum = GoodsObj:getCountByModelId(CASTMODELID)
	if goodsNum < 1 then
		daibiLabel:setTextColor(Enums.Color.eRed)
	end	

	-- 剩余次数
	local btnSize = self.mAssistBtn:getContentSize()
	self.mFreeLabel = ui.newLabel({
		text = TR("剩余次数:%s%d/%d", "#a8ff5b", self.mBattleInfo.AttackNum, self.mMaxAttackNum),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		size = 20,
	})
	self.mFreeLabel:setAnchorPoint(cc.p(0.5, 0))
	self.mFreeLabel:setPosition(btnSize.width * 0.5, btnSize.height + 5)
	self.mAssistBtn:addChild(self.mFreeLabel)
end

-- 获取掉落预览列表
function BattleBossLayer:getDropPrewList()
	local nextBoss = self.mBattleInfo.NextBoss
	local bossModel = LuckbossModel.items[nextBoss and nextBoss.BossModelId or 0]

	if not bossModel then
		return {}
	end

	local ret = {}
	local tempList = string.splitBySep(bossModel.outShowAll, ",")
	for _, item in pairs(tempList or {}) do
		local tempModel = TreasureModel.items[tonumber(item)]
		if tempModel then
			table.insert(ret, {
				resourceTypeSub = tempModel.typeID,
	            modelId = tempModel.ID,
			})
		end
	end

	return ret
end

-- 购买次数的提示
function BattleBossLayer:showBuyBossCount()
	local vipLevel = PlayerAttrObj:getPlayerAttrByName("Vip")
	local maxCount = VipModel.items[vipLevel].allowBuyLuckBossFightNum - self.mBattleInfo.BuyCount
	if maxCount <= 0 then
		if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
            ui.showFlashView(TR("购买次数不足，提升VIP等级可增加每日购买次数"))
        else
            ui.showFlashView(TR("达到今日购买上限"))
        end
		return
	end
	-- 购买挑战次数提示框
	MsgBoxLayer.buyBossCountHintLayer(self.mBattleInfo.BuyCount, maxCount, function(buyCount)
		self:requestBuyCount(buyCount)
	end)
end


--==============================网络请求相关================================

-- 获取boss列表 服务器数据请求
function BattleBossLayer:requestGetBossList()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "GetBossList",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end
            local value = response.Value

            self.mBattleInfo = value.BattleInfo

            self.mBossList = response.Value.BossList

			-- 延迟初始化页面
			self:dealyInitUI()

			-- 执行新手引导
    		self:executeGuide()
        end,
    })
end

-- 触发恶徒
function BattleBossLayer:requestTriggerBoss()
	HttpClient:request({
		svrType = HttpSvrType.eGame,
		moduleName = "BossBattle",
		methodName = "SearchBoss",
		svrMethodData = {},
		guideInfo = Guide.helper:tryGetGuideSaveInfo(11306),
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			-- 执行下一步引导
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11306 then
            	Guide.manager:removeGuideLayer()
				Guide.manager:nextStep(eventID)
			end
			local goodsNum = GoodsObj:getCountByModelId(CASTMODELID)
			if goodsNum < 1 then
				self.mDaibiLabel:setTextColor(Enums.Color.eRed)
			end
			-- self.mCostDaibi.setNumber(1)
			-- 触发的BOSS信息
			self.mTriggerBoss = response.Value.BossInfo
			-- 将触发的BOSS插入BOSS列表
			table.insert(self.mBossList, self.mTriggerBoss)

			LayerManager.addLayer({
				name = "challenge.BossAppearLayer",
				data = {
					bossId = response.Value.BossId
				},
				cleanUp = false,
			})
		end
	})
end

-- 购买挑战次数
function BattleBossLayer:requestBuyCount(buyCount)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "BuyCount",
        svrMethodData = {buyCount},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end
            local value = response.Value or {}

            self.mBattleInfo.BuyCount = value.BuyCount or 0
            self.mBattleInfo.AttackNum = value.AttackNum or self.mBattleInfo.AttackNum

            local tempStr = TR("剩余次数:%s%d/%d", Enums.Color.eNormalGreenH, self.mBattleInfo.AttackNum, self.mMaxAttackNum)
            self.mFreeLabel:setString(tempStr)

            ui.showFlashView(TR("购买成功"))
        end,
    })
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function BattleBossLayer:executeGuide()
	Guide.helper:executeGuide({
        -- 点击“搜捕恶徒”按钮
        [11306] = {clickNode = self.mSearchBtn},
    })
end

return BattleBossLayer
