--[[
	文件名：BossInfoLayer.lua
	文件描述：BOSS详情界面
	创建人：chenqiang
	创建时间：2017-03-03
]]

local BossInfoLayer = class("BossInfoLayer", function()
	return cc.LayerColor:create()
end)

-- 构造函数
--[[
-- 参数 params
	{
		bossId: boss的ID
	}
]]
function BossInfoLayer:ctor(params)
	-- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})
    -- 参数
	params = params or {}
	self.mBossId = params.bossId or nil
	self.mCurrentIndex = 1
	-- 是否改变头像的位置
	self.mIsChangePos = true
	-- 最大挑战次数
	local vipLv = PlayerAttrObj:getPlayerAttrByName("Vip")
	self.mMaxAttackNum = VipModel.items[vipLv].attackLuckBossMaxNum

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 当前页面背景呈现暗淡
    self:setOpacity(100)

	self:initUI()

	-- 请求BOSS列表信息
	self:requestGetBossList()
end

-- 整理boss数据，对boss进行排序
function BossInfoLayer:handlerData()
	table.sort(self.mBossList, function(item1, item2)
		if item1.PlayerId ~= item2.PlayerId then
			local myPlayerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
			if item1.PlayerId ~= myPlayerId then
				return false
			end

			if item2.PlayerId ~= myPlayerId then
				return true
			end

			return false
		end

		return false
	end)

	if Utility.isEntityId(self.mBossId) then
		for index, bossInfo in ipairs(self.mBossList) do
			if bossInfo.Id == self.mBossId then
				self.mCurrentIndex = index
				break
			end
		end
	end
end

-- 初始化页面控件
function BossInfoLayer:initUI()
	-- 设置背景大小
    local bgWidth = 598
    local bgHeight = 930
    -- 背景
    self.mBgSize = cc.size(bgWidth, bgHeight)
    self.mBgSprite = ui.newScale9Sprite("c_30.png", self.mBgSize)
    self.mBgSprite:setPosition(320, 600)
    self.mParentLayer:addChild(self.mBgSprite)

	-- title
    local titleSprite = ui.newLabel({
        text = TR("击杀恶徒"),
        size = 30,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        outlineSize = 2,
    })
    titleSprite:setAnchorPoint(cc.p(0.5, 1.0))
    titleSprite:setPosition(320, 1050)
    self.mParentLayer:addChild(titleSprite)

    -- 关闭按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1040),
        clickAction = function()
        	Notification:postNotification(EventsName.eBattleBoss)
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(mCloseBtn, 1)


    -- 添加动作助手
	-- ui.showPopAction(self.mBgSprite)
end

-- 延时构造
function BossInfoLayer:delayInit()
	self.mBgSprite:removeAllChildren()
	-- 整理boss数据
    self:handlerData()
    -- 创建boss相关信息
    self:createBossInfo()
    -- 创建boss图标列表
    self:createBossList()
    -- 创建左右滑动的控件
    self:createSliderView()

    Utility.performWithDelay(self, function()
    	-- 执行新手引导
    	self:executeGuide()
    end, 0.5)
end

-- 保存页面数据
function BossInfoLayer:getRestoreData()
	local retData = {
		bossId = self.mBossId,
	}

	return retData
end

local listViewSize = cc.size(516, 130)
-- 创建顶部BOSS列表
function BossInfoLayer:createBossList()
	self.mBossListView = ccui.ListView:create()
	self.mBossListView:setDirection(ccui.ScrollViewDir.horizontal)
	self.mBossListView:setBounceEnabled(true)
	self.mBossListView:setContentSize(listViewSize)
	self.mBossListView:setAnchorPoint(cc.p(0.5, 1))
	self.mBossListView:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 70)
	self.mBossListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
	self.mBgSprite:addChild(self.mBossListView)

	self:refreshBossList()
end

-- 刷新BOSS列表
function BossInfoLayer:refreshBossList()
	self.mBossListView:removeAllChildren()

	local spaceX = 10
	local cardSize = ui.getImageSize("c_04.png")
	local cellSize = cc.size(cardSize.width + spaceX, 140)

	for index, item in ipairs(self.mBossList) do
		local showAttrs = {CardShowAttr.eBorder}

		local cellItem = ccui.Layout:create()
		cellItem:setContentSize(cellSize)
		self.mBossListView:pushBackCustomItem(cellItem)

		local tempCard = require("common.CardNode").new({
			allowClick = true,
			onClickCallback = function()
				self.mCurrentIndex = index
				self.mIsChangePos = false
	            self.mBossSliderView:setSelectItemIndex(index - 1)
			end
		})
		tempCard:setPosition(cellSize.width / 2, cellSize.height * 0.6)
		tempCard:setHero({Id = item.Id, ModelId = item.BossModelId}, showAttrs)
		cellItem:addChild(tempCard)

		-- 自己的恶徒显示"必掉"标签
		local isMyself = item.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
		if isMyself then
			tempCard:createStrImgMark("c_57.png", TR("必掉"), 22)
		end

		-- boss 逃走时间
		local awayTimeLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eBlack,
			size = 18,
		})
		awayTimeLabel:setAnchorPoint(cc.p(0.5, 1))
		awayTimeLabel:setPosition(cellSize.width / 2, cellSize.height * 0.23)
		cellItem:addChild(awayTimeLabel)
		awayTimeLabel:stopAllActions()
		Utility.schedule(awayTimeLabel, function()
			local tempCout = item.AwayTime - Player:getCurrentTime()
			if tempCout < 0 then
				self:requestGetBossList()
			else
				awayTimeLabel:setString(string.format("%s", MqTime.formatAsHour(tempCout)))
			end
		end, 1)

		-- 高亮边框
		local selectBorder = ui.newSprite("c_31.png")
		selectBorder:setPosition(cellSize.width / 2, cellSize.height * 0.6)
		selectBorder:setVisible(false)
		cellItem:addChild(selectBorder)
		cellItem.select = selectBorder
	end

	self:changeBossItem(self.mCurrentIndex)
end

-- 创建左右滑动的控件
function BossInfoLayer:createSliderView()
	-- 滑动控件背景
	local sliderBgSprite = ui.newSprite("xxzy_03.png")
	sliderBgSprite:setAnchorPoint(cc.p(0.5, 1))
	sliderBgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 200)
	self.mBgSprite:addChild(sliderBgSprite)

	-- 滑动控件
	self.mBossSliderView = ui.newSliderTableView({
		width = 569,
		height = 459,
		isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.mCurrentIndex - 1,
        itemCountOfSlider = function(sliderView)
            return #self.mBossList
        end,
        itemSizeOfSlider = function(sliderView)
            return 569, 459
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
			self:createBossFigureInfo(itemNode, index)
    	end,
        selectItemChanged = function(sliderView, selectIndex)
            local index = selectIndex + 1
            self.mCurrentIndex = index

            self:changeBossItem(self.mCurrentIndex)
            self:changeView()
        end
	})
	self.mBossSliderView:setPosition(285, 230)
    sliderBgSprite:addChild(self.mBossSliderView)

    -- 创建购买次数按钮
    local buyBtn = ui.newButton({
    	normalImage = "tb_125.png",
		clickAction = function()
			self:showBuyBossCount()
		end
    })
    buyBtn:setPosition(500, 50)
    sliderBgSprite:addChild(buyBtn)
end

-- 创建BOSS形象
function BossInfoLayer:createBossFigureInfo(parent, index)
	local bossInfo = self.mBossList[index + 1]
	local tempModel = HeroModel.items[bossInfo.BossModelId]
	if tempModel then
		-- 形象
		local tempFigure = Figure.newHero({
			parent = parent,
			heroModelID = bossInfo.BossModelId,
			position = cc.p(285, 30),
			scale = 0.22,
		})

		-- BOSS的主人
		local isMyself = bossInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
		local playerName = isMyself and TR("我") or bossInfo.PlayerName
		local nameLabel = ui.newLabel({
			text = TR("%s%s%s搜捕到的恶徒", Enums.Color.eYellowH, playerName, Enums.Color.eNormalWhiteH),
			color = Enums.Color.eNormalWhite,
			outlineColor = Enums.Color.eBlack,
			outlineSize = 2,
		})
		nameLabel:setAnchorPoint(cc.p(0.5, 0))
		nameLabel:setPosition(285, 390)
		parent:addChild(nameLabel)

		-- 击杀boss的进度条
		local bossProg = require("common.ProgressBar").new({
	        bgImage = "xxzy_01.png",
	        barImage = "xxzy_02.png",
	        currValue = 0,
	        maxValue =  100,
	        barType = ProgressBarType.eHorizontal,
	        color = Enums.Color.eWhite,
	        needLabel = true,
	        percentView = true,
	        outlineColor = cc.c3b(0x18, 0x33, 0x0a),
	        outlineSize = 2,
	        size = 18,
	        -- contentSize = cc.size(431, 40),
	    })
	    bossProg:setAnchorPoint(cc.p(0.5, 1))
	    bossProg:setPosition(285, 390)
	    parent:addChild(bossProg)
	    -- boss 血量进度
		bossProg:setMaxValue(bossInfo.TotalHP)
		bossProg:setCurrValue(bossInfo.CurHP, 0)
	end
end

-- 创建boss相关信息
function BossInfoLayer:createBossInfo()
	local titleBgSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 54))
	titleBgSprite:setPosition(299, self.mBgSize.height - 665)
	self.mBgSprite:addChild(titleBgSprite)

	-- 背景大小
	local titleBgSize = titleBgSprite:getContentSize()
	local titleLabel = ui.newLabel({
		text = TR("击杀自己的恶徒掉落: "),
		color = cc.c3b(0xf7, 0xf5, 0xf0),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	titleLabel:setAnchorPoint(cc.p(0, 0.5))
	titleLabel:setPosition(85, titleBgSize.height * 0.5)
	titleBgSprite:addChild(titleLabel)

	-- 逃跑时间
	local awayTimeLabel = ui.newLabel({
		text = TR("逃跑时间: "),
		color = cc.c3b(0xf7, 0xf5, 0xf0),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	awayTimeLabel:setAnchorPoint(cc.p(1, 0.5))
	awayTimeLabel:setPosition(titleBgSize.width * 0.75, titleBgSize.height * 0.5)
	titleBgSprite:addChild(awayTimeLabel)

	local timeLabel = ui.newLabel({
		text = string.format("%s", "00:00:00"),
		color = cc.c3b(0xf4,0xe1,0x10),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	})
	timeLabel:setAnchorPoint(cc.p(0, 0.5))
	timeLabel:setPosition(titleBgSize.width * 0.75, titleBgSize.height * 0.5)
	titleBgSprite:addChild(timeLabel)
	self.mTimeLabel = timeLabel

	-- 掉落资源
	self.mDropResource = ui.createCardList({
		maxViewWidth = 220,
		cardShape = Enums.CardShape.eSquare,
		allowClick = true,
		space = -15,
	})
	self.mDropResource:setAnchorPoint(cc.p(0, 0.5))
	self.mDropResource:setPosition(20, self.mBgSize.height - 755)
	self.mBgSprite:addChild(self.mDropResource)
	-- 描述
	local white, lightYellow = Enums.Color.eWhiteH, Enums.Color.eYellowH
	local nextBoss = self.mBattleInfo.NextBoss
	local tempModel = HeroModel.items[nextBoss.BossModelId]

	local tempStr = TR("再击杀%s%d%s次自己的恶徒可触发%s%s", lightYellow, nextBoss.NCount, white, lightYellow, tempModel.name)
	if nextBoss.NCount <= 0 then
		tempStr = TR("下次遭遇的恶徒必定为%s%s", lightYellow, tempModel.name)
	end
	local tempNode = ui.newLabel({
		text = tempStr,
		color = Enums.Color.eWhite,
		size = 18,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
	})
	tempNode:setAnchorPoint(cc.p(0, 0.5))
	tempNode:setPosition(self.mBgSize.width * 0.40, self.mBgSize.height - 710)
	self.mBgSprite:addChild(tempNode)

	-- 积分翻倍提示
	local tempLabel = ui.newLabel({
		text = TR("每天12-14点,18-20点击杀恶徒可获得双倍积分"),
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		size = 18,
		dimensions = cc.size(310, 0)
	})
	tempLabel:setAnchorPoint(cc.p(0, 0.5))
	tempLabel:setPosition(self.mBgSize.width * 0.40, self.mBgSize.height - 750)
	self.mBgSprite:addChild(tempLabel)

	-- 创建战役信息
	self:createBattleInfo()
end

-- 创建显示boss战役信息
function BossInfoLayer:createBattleInfo()
	-- 剩余次数
	self.mFreeLabel = ui.newLabel({
		text = TR("剩余次数:%s%d/%d", "#a8ff5b", self.mBattleInfo.AttackNum, self.mMaxAttackNum),
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		size = 20,
	})
	self.mFreeLabel:setAnchorPoint(cc.p(0, 0.5))
	self.mFreeLabel:setPosition(60, self.mBgSize.height - 815)
	self.mBgSprite:addChild(self.mFreeLabel)

	-- 恢复时间
	local restoreLabel = ui.newLabel({
		text = TR("恢复时间:%s%s", "#a8ff5b", "00:00:00"),
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		size = 20,
	})
	restoreLabel:setAnchorPoint(cc.p(0, 0.5))
	restoreLabel:setPosition(320, self.mBgSize.height - 815)
	self.mBgSprite:addChild(restoreLabel)
	Utility.schedule(restoreLabel, function()
		local tempCount = self.mBattleInfo.RecoverTime - Player:getCurrentTime()
		if tempCount < 0 then
			if self.mBattleInfo.AttackNum < self.mMaxAttackNum then
				self:requestGetBossList()
			else
				restoreLabel:setString(TR("恢复时间:%s挑战次数已满", "#a8ff5b"))
			end
		else
			local tempStr = MqTime.formatAsHour(tempCount)
			restoreLabel:setString(TR("恢复时间:%s%s", "#a8ff5b", tempStr))
		end
	end, 1)
end

-- 创建操作按钮
function BossInfoLayer:createOptBtn()
	if tolua.isnull(self.mOptLayer) then
		self.mOptLayer = ccui.Layout:create()
		self.mOptLayer:setContentSize(cc.size(586, 100))
		self.mOptLayer:setIgnoreAnchorPointForPosition(false)
		self.mOptLayer:setAnchorPoint(cc.p(0.5, 0))
		self.mOptLayer:setPosition(293, 0)
		self.mBgSprite:addChild(self.mOptLayer)
	end
	self.mOptLayer:removeAllChildren()

	self.mOptBtnInfos = {
		{
			normalImage = "c_28.png",
			text = TR("全服邀请"),
			isMyBoss = true,
			size = ButtonSize[4],
			clickAction = function()
				-- 好友助阵的服务器请求
				self:requestFriendHelp(self.mBossList[self.mCurrentIndex].Id)
			end
		},
		{
			normalImage = "c_28.png",
			text = TR("战斗"),
			clickAudio = "sound_dianjikaizhan.mp3",
			size = ButtonSize[4],
			clickAction = function()
				local needVit = VitConfig.items[1].perUseNum
			    -- 判断挑战次数是否足够
			    if self.mBattleInfo.AttackNum < 1 then
			        self:showBuyBossCount()
			        return false
			    end
			    -- 判断体力是否足够
			    -- if not Utility.isResourceEnough(ResourcetypeSub.eVIT, needVit, true) then
			    -- 	return false
			    -- end

			    -- 获取战斗前信息的服务器请求
				self:requestGetFightInfo(self.mBossList[self.mCurrentIndex].Id, false)
			end
		},
		{
			normalImage = "c_33.png",
			text = TR("奋力一击"),
			clickAudio = "sound_dianjikaizhan.mp3",
			size = ButtonSize[4],
			clickAction = function()
				-- 全力一击消耗倍数
				local attackUse = LuckbossConfig.items[1].alloutAttackUseR / 10000
				local needVit = VitConfig.items[1].perUseNum * attackUse
				-- 判断挑战次数是否足够
				if self.mBattleInfo.AttackNum < attackUse then
				    self:showBuyBossCount()
				    return false
				end
				-- 判断体力是否足够
				-- if not Utility.isResourceEnough(ResourcetypeSub.eVIT, needVit, true) then
				-- 	return false
				-- end

				-- 奋力一击的提示
				local hintStr = TR("奋力一击将消耗%s%d%s次挑战次数，获得%s%d%s倍属性提升，是否继续？",
					Enums.Color.eRedH, attackUse, Enums.Color.eNormalWhiteH,
					Enums.Color.eRedH, attackUse, Enums.Color.eNormalWhiteH)

				local okBtnInfo = {
					text = TR("继续"),
					clickAction = function(layerObj, btnObj)
						LayerManager.removeLayer(layerObj)
						-- 获取战斗前信息的服务器请求
						self:requestGetFightInfo(self.mBossList[self.mCurrentIndex].Id, true)
					end
				}
				--x关闭按钮
				local cancelBtnInfo = {
					clickAction = function(layerObj, btnObj)
						LayerManager.removeLayer(layerObj)
					end
				}
				local hintLayer = MsgBoxLayer.addOKLayer(hintStr, TR("提示"), {okBtnInfo}, cancelBtnInfo)
				-- 保存引导使用
				self.hitOkBtn = hintLayer:getBottomBtns()[1]

				-- 执行下一步引导
            	local _, _, eventID = Guide.manager:getGuideInfo()
            	if eventID == 11307 then
					Guide.manager:nextStep(eventID)
					Utility.performWithDelay(self.hitOkBtn, handler(self, self.executeGuide), 0.25)
				end
			end
		},
	}
	for index, btnInfo in pairs(self.mOptBtnInfos) do
		local tempBtn = ui.newButton(btnInfo)
		tempBtn:setScale(0.85)
		self.mOptLayer:addChild(tempBtn)
		btnInfo.btnObj = tempBtn
	end

	-- 改变控件显示函数
	self:changeView()
end

-- 改变控件显示函数
function BossInfoLayer:changeView()
	local bossInfo = self.mBossList[self.mCurrentIndex]
	-- 是否是玩家自己的boss
	local isMyBoss = bossInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
	-- 按钮的显示状态
	local tempCount = isMyBoss and #self.mOptBtnInfos or (#self.mOptBtnInfos - 1)
	local tempSpace = isMyBoss and 180 or 240
	local startPosX = (586 - tempCount * tempSpace) / 2  + tempSpace / 2
	local tempPosY = 65
	local viewIndex = 1
	for index, btnInfo in ipairs(self.mOptBtnInfos) do
		btnInfo.btnObj:setVisible(not btnInfo.isMyBoss or isMyBoss)
		btnInfo.btnObj:setPosition(startPosX + (viewIndex - 1) * tempSpace, tempPosY)

		if not btnInfo.isMyBoss or isMyBoss then
			viewIndex = viewIndex + 1
		end
	end

	-- 逃走时间
	self.mTimeLabel:stopAllActions()
	Utility.schedule(self.mTimeLabel, function()
		local tempCout = bossInfo.AwayTime - Player:getCurrentTime()
		self.mTimeLabel:setString(string.format("%s", MqTime.formatAsHour(tempCout)))
	end, 1)
	-- 掉落资源
	local cardList, resData = {}, {}
	local showAttrs = {CardShowAttr.eBorder}
	local resTable = {
		{
			resourceTypeSub = 1120,
			modelId = 0,
			num = 1,
		},
		{
			resourceTypeSub = bossInfo.DropResource.TypeId,
			modelId = bossInfo.DropResource.ModelId,
			num = bossInfo.DropResource.Num,
		}
	}
	for _, item in ipairs(resTable) do
		resData.resourceTypeSub = item.resourceTypeSub
		resData.modelId = item.modelId
		resData.num = item.num
		resData.cardShowAttrs = showAttrs

		table.insert(cardList, resData)
		resData = {}
	end
	-- 刷新掉落列表
	self.mDropResource.refreshList(cardList)
	-- 获取掉落card列表
	local cardInfos = self.mDropResource.getCardNodeList()
	for index, tempCard in ipairs(cardInfos) do
		tempCard:setScale(0.9)
		tempCard:createStrImgMark("c_57.png", TR("必掉"), 22)
	end
end

-- 改变选择的BOSS
function BossInfoLayer:changeBossItem(index)
	for idx, _ in ipairs(self.mBossList) do
		local tempItem = self.mBossListView:getItem(idx - 1)
		tempItem.select:setVisible(false)
	end

	local cellItem = self.mBossListView:getItem(index - 1)
	if cellItem then
		cellItem.select:setVisible(self.mCurrentIndex == index)
		if self.mIsChangePos then
			ui.setListviewItemShow(self.mBossListView, index)
		end
		self.mIsChangePos = true
	end

	-- 创建操作按钮
	self:createOptBtn()
end

-- 购买次数的提示
function BossInfoLayer:showBuyBossCount()
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

--================================网络请求相关===============================

-- 获取boss列表 服务器数据请求
function BossInfoLayer:requestGetBossList()
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
            if #self.mBossList == 0 then
            	Notification:postNotification(EventsName.eBattleBoss)
            	LayerManager.removeLayer(self)
            	ui.showFlashView(TR("恶徒已经伏诛"))
            	return
            end
			-- 延迟初始化页面
			self:delayInit()
        end,
    })
end

-- 购买挑战次数
function BossInfoLayer:requestBuyCount(buyCount)
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

            local tempStr = TR("剩余次数:%s%d/%d", "#a8ff5b", self.mBattleInfo.AttackNum, self.mMaxAttackNum)
            self.mFreeLabel:setString(tempStr)

            ui.showFlashView(TR("购买成功"))
        end,
    })
end

-- 获取战斗前信息的服务器请求
function BossInfoLayer:requestGetFightInfo(bossId, isFullFight)
	-- 保存进入战斗的BOSSID
	self.mBossId = bossId

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "GetFightInfo",
        svrMethodData = {bossId, isFullFight},
		guideInfo = Guide.helper:tryGetGuideSaveInfo(113071),
        callbackNode = self,
        callback = function(response)
        	if response.Status == -1731 then
            	self:requestGetBossList()
            end
            if not response or response.Status ~= 0 then
            	return
            end

			-- 执行下一步引导
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 113071 then
            	Guide.manager:removeGuideLayer()
				Guide.manager:nextStep(eventID)
			end

            local value = response.Value
            -- 战斗控制参数
            local controlParams = Utility.getBattleControl(ModuleSub.eBattleBoss)
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    map = Utility.getBattleBgFile(ModuleSub.eBattleBoss),
                    startPet = {
                        fspView = false
                    },
                    callback = function(ret)
                        CheckPve.BattleBoss(bossId, isFullFight, ret)

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
		                    controlParams.trustee.changeTrusteeState(ret.trustee)
		                end
                    end
                }
            })
        end,
    })
end

-- 好友助阵的服务器请求
function BossInfoLayer:requestFriendHelp(bossId)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "FriendHelp",
        svrMethodData = {bossId},
        callbackNode = self,
        callback = function(response)
        	if response.Status == -1724 then
        		self:requestGetBossList()
        	end
            if not response or response.Status ~= 0 then
            	return
            end

            ui.showFlashView(TR("全服邀战消息发送成功"))
        end,
    })
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function BossInfoLayer:executeGuide()
    Guide.helper:executeGuide({
    	-- 点击奋力一击
        [11307] = {clickNode = self.mOptBtnInfos[3].btnObj},
        -- 点击继续
        [113071] = {clickNode = self.hitOkBtn, hintPos = cc.p(display.cx, 160 * Adapter.MinScale)}
    })
end

return BossInfoLayer
