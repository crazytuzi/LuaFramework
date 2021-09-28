--[[
    文件名: MateInfoView.lua
	描述: 江湖后援团卡槽信息（该页面没有做适配处理，需要创建者考虑适配问题）
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local MateInfoView = class("MateInfoView", function(params)
    return display.newLayer()
end)

-- 初始化函数
--[[
	params: 参数列表
	{
		viewSize: 显示大小
        formationObj: 阵容数据对象
        isViewPrDetail: 是否初始显示上阵人物羁绊详情，默认为false
        clickCallback: 点击江湖后援团卡牌或阵容卡槽的回调 clickCallback(slotIndex, isMateSlot)
	}
--]]
function MateInfoView:ctor(params)
	-- 屏蔽下层点击
	ui.registerSwallowTouch({node = self})

	-- 控件显示大小
	self.mViewSize = params.viewSize
	-- 阵容数据对象
	self.mFormationObj = params.formationObj
	-- 是否初始显示上阵人物羁绊详情
	self.mIsViewPrDetail = params.isViewPrDetail
	-- 点击江湖后援团卡牌的回调
	self.clickCallback = params.clickCallback
	-- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()
	-- 可以开启的江湖后援团总数
	self.mMaxMateCount = self.mFormationObj:getMaxMateCount()
	-- 获取Vip开启卡槽的起始Id
	self.mVipMateStartIndex = self.mFormationObj:getVipMateStartIndex()
	-- 获取Vip开启卡槽的数量
	self.VipMateMaxCount = self.mFormationObj:getVipMateMaxCount()
	-- 显示羁绊详情部分的大小
	self.mPrViewSize = cc.size(384, 580)
	-- 江湖后援团卡槽上的CardNode对象列表
	self.mMateCardList = {}
	-- 阵容所有上阵人物的羁绊信息
	self.mSlotPrInfo = {}
	-- 刷新阵容卡槽人物的羁绊信息
	self:refreshPrInfo()

	self:setContentSize(self.mViewSize)
	self:setIgnoreAnchorPointForPosition(false)

	-- 初始化页面控件
	self:initUI()
	-- 刷新江湖后援团卡槽信息
	self:refreshMateSlot()
end

-- 初始化页面控件
function MateInfoView:initUI()
	-- 使用江湖后援团可激活上阵人物缘分 提示的
	local tempNode = ui.createSpriteAndLabel({
		imgName = "c_25.png",
		scale9Size = cc.size(520, 54),
        labelStr = TR("使用江湖后援团可激活侠客羁绊"),
        fontColor = Enums.Color.eWhite
    })
    tempNode:setPosition(self.mViewSize.width / 2, self.mViewSize.height - 40)
    self:addChild(tempNode)
    -- 感叹号标志
    local tempSprite = ui.newSprite("c_63.png")
    tempSprite:setPosition(60, tempNode:getContentSize().height / 2)
    tempNode:addChild(tempSprite)

    -- 中间的背景
    local centerBgSprite = ui.newScale9Sprite("c_38.png", cc.size(430, 750))
    centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
    centerBgSprite:setPosition(cc.p(self.mViewSize.width / 2, 85))
    self:addChild(centerBgSprite)

    -- 创建江湖后援团卡槽上的卡牌
    for index = 1, self.mMaxMateCount do
    	local tempPos = self:getMateSlotPos(index)
    	-- 创建卡牌
    	local tempCard = CardNode:create({
    		allowClick = true,
    		onClickCallback = function()
    			if self.clickCallback then
    				self.clickCallback(index, true)
    			end
    		end
    	})
    	tempCard:setPosition(tempPos)
    	self:addChild(tempCard)
    	table.insert(self.mMateCardList, tempCard)
    end

 	-- 效果搭配按钮
 	self.mPrViewBtn = ui.newButton({
 		normalImage = self.mIsViewPrDetail and "tb_128.png" or "tb_19.png",
 		clickAction = function()
 			self.mIsViewPrDetail = not self.mIsViewPrDetail
 			if self.mIsViewPrDetail and not self.mPrInfoView then
 				-- 创建效果搭配的详细信息页面
	 			self:createPrInfoView()
 			elseif not self.mIsViewPrDetail and not self.mSlotCardView then
 				-- 创建效果搭配内容页面
	 			self:createSlotCardView()
 			end
 			self.mPrInfoView:setVisible(self.mIsViewPrDetail)
 			self.mSlotCardView:setVisible(not self.mIsViewPrDetail)

 			local tempStr = self.mIsViewPrDetail and "tb_128.png" or "tb_19.png"
 			self.mPrViewBtn:loadTextures(tempStr, tempStr)
 		end
 	})
 	self.mPrViewBtn:setPosition(320, 750)
 	self:addChild(self.mPrViewBtn)

 	if self.mIsViewPrDetail then
	 	-- 创建效果搭配的详细信息页面
	 	self:createPrInfoView()
 	else
	 	-- 创建效果搭配内容页面
	 	self:createSlotCardView()
 	end
end

-- 刷新江湖后援团卡槽信息
function MateInfoView:refreshMateSlot()
	for index, cardNode in pairs(self.mMateCardList) do
		if self.mFormationObj:slotIsOpen(index, true) then
			local slotInfo = self.mFormationObj:getMateSlotInfo(index)
			if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
				local heroInfo = self.mIsMyself and HeroObj:getHero(slotInfo.HeroId) or {
					Id            = slotInfo.HeroId,
                    ModelId       = slotInfo.ModelId,
                    Lv            = slotInfo.Lv,
                    Step          = slotInfo.Step,
                    IllusionModelId = slotInfo.IllusionModelId,
				}
				cardNode:setHero(heroInfo, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel, CardShowAttr.eStep})
			else
				cardNode:setEmpty({}, "c_04.png", nil)
				if self.mIsMyself then
					cardNode:showGlitterAddMark("c_144.png", 1.2)
				end
			end
		else
			local tempStr = TR("未开启")
			if not FormationObj:mateSlotIsVipOpen(index) then -- 非Vip开启的江湖后援团卡槽
				local starCount = self.mFormationObj:getSlotOpenStar(index, true)
				tempStr = TR("拼酒%d\n开启", starCount)
			else  	-- Vip开启的江湖后援团卡槽
				local VipLv = VipSlotRelation.items[index].LV
				tempStr = TR("VIP%d\n开启", VipLv)
			end

			cardNode:setEmpty({}, "c_04.png", "c_35.png")
			local tempSize = cardNode:getContentSize()
			local tempLabel = ui.newLabel({
				text = tempStr,
				size = 18,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                outlineSize = 2,
				align = cc.TEXT_ALIGNMENT_CENTER,
        		valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				dimensions = cc.size(tempSize.width - 10, 0)
			})
			tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
			tempLabel:setPosition(tempSize.width * 0.5, tempSize.height * 0.35)
			cardNode:addChild(tempLabel)
		end
	end
end

-- 刷新阵容卡槽人物的羁绊信息
function MateInfoView:refreshPrInfo()
	local maxSlotCout = self.mFormationObj:getMaxSlotCount()
	for index = 1, maxSlotCout - 1 do
		local tempInfo, prCount = self.mFormationObj:getSlotPrInfo(index, false)
		self.mSlotPrInfo[index] = {
			slotId = index,
			prCount = prCount,
			prInfo = tempInfo,
		}
	end
end

-- 计算江湖后援团卡槽的位置
function MateInfoView:getMateSlotPos(mateIndex)
	local rowCount = math.ceil((self.mMaxMateCount - self.VipMateMaxCount) / 2)  -- 点星开启卡槽的行数
    local vipRowIndex = math.ceil(self.mVipMateStartIndex / 2)  -- VIP开启卡槽所在的行
    local startPosX, startPosY = 55, 785  -- 左上角第一个卡槽的位置
    local spaceX, spaceY = 530, 130  -- 卡槽 X、Y 方向的间距

    -- 计算卡牌的坐标
	local tempPosX, tempPosY = 0, 0
	if self.mFormationObj:mateSlotIsVipOpen(mateIndex) then  -- Vip开启的卡槽
		local tempIndx = mateIndex - self.mVipMateStartIndex + 1
		--tempPosX = startPosX + spaceX / (self.VipMateMaxCount + 1) * tempIndx
		tempPosX = startPosX + (tempIndx - 1) * spaceX
		--
		tempPosY = startPosY - vipRowIndex * spaceY
	else
		local tempIndx = mateIndex < self.mVipMateStartIndex and mateIndex or (mateIndex - self.VipMateMaxCount)

		local col = math.ceil(tempIndx / rowCount)
		tempPosX = startPosX + (col - 1) * spaceX
		--
		local row = math.mod(tempIndx - 1, rowCount) + 1
		tempPosY = startPosY - (row - 1) * spaceY
	end

	return cc.p(tempPosX, tempPosY)
end

-- 创建效果搭配的阵容卡槽卡牌信息
function MateInfoView:createSlotCardView()
	local retNode = cc.Node:create()
	retNode:setContentSize(self.mPrViewSize)
	retNode:setIgnoreAnchorPointForPosition(false)
	retNode:setAnchorPoint(cc.p(0.5, 0))
	retNode:setPosition(320, 177)
	self:addChild(retNode)
	self.mSlotCardView = retNode

	-- 显示达成羁绊个数的控件列表
	local prNodeList = {}

	-- 创建阵容卡槽人物卡牌
	local maxSlotCout = self.mFormationObj:getMaxSlotCount()
	local startPosX, startPosY = 65, 440
	local spaceX, spaceY = 130, 250
	for index = 1, maxSlotCout - 1 do
		local tempPosX = startPosX + math.mod(index - 1, 3) * spaceX
		local tempPosY = startPosY - (math.ceil(index / 3) - 1) * spaceY

		local tempCard = CardNode:create({
			allowClick = true,
			onClickCallback = function()
    			if self.clickCallback then
    				self.clickCallback(index, false)
    			end
    		end
		})
    	tempCard:setPosition(tempPosX, tempPosY)
    	retNode:addChild(tempCard)

    	if self.mFormationObj:slotIsOpen(index) then -- 该阵容卡槽已开启
    		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(index)
    		if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
				local heroInfo = {}
				if self.mIsMyself then
					heroInfo = clone(HeroObj:getHero(slotInfo.HeroId))
					heroInfo.FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
				else
					heroInfo = clone(slotInfo.Hero)
					heroInfo.FashionModelID = self.mFormationObj:getThisPlayerInfo().FashionModelId
				end
				tempCard:setHero(heroInfo, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel, CardShowAttr.eStep})
			else
				tempCard:setEmpty({}, "c_04.png", "c_35.png")
			end
    	else
    		tempCard:setEmpty({}, "c_04.png", "c_35.png")
    	end

    	-- 羁绊达成的个数
    	local tempNode = ui.createSpriteAndLabel({
    		imgName = "c_64.png",
    		fontSize = 20,
    		labelStr = "",
    		fontColor = cc.c3b(0xd1, 0x7b, 0x00)
    	})
    	tempNode:setPosition(tempPosX, tempPosY - 95)
    	retNode:addChild(tempNode)
    	table.insert(prNodeList, tempNode)
	end

	-- 上阵人物达成羁绊的总个数
 	local prCountLabel = ui.newLabel({
        text = TR("上阵侠客激活缘分数量: %s%d%s个", Enums.Color.eYellowH, 0, Enums.Color.eWhiteH),
        size = 24,
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
    })
    prCountLabel:setPosition(self.mPrViewSize.width / 2, 0)
    retNode:addChild(prCountLabel)

	retNode.refresh = function()
		local prCount = 0
		for index = 1, maxSlotCout - 1 do
			local tempNode = prNodeList[index]
			local slotInfo = self.mFormationObj:getSlotInfoBySlotId(index)
    		if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
    			local tempInfo = self.mSlotPrInfo[index]
    			tempNode:setVisible(true)
    			tempNode:setString(TR("%d %s搭配", tempInfo.prCount, "#46220D"))
    			prCount = prCount + tempInfo.prCount
    		else
    			tempNode:setVisible(false)
    		end
		end
		prCountLabel:setString(TR("上阵侠客激活缘分数量: %s%d%s个", Enums.Color.eYellowH, prCount, Enums.Color.eWhiteH))
	end
	retNode.refresh()
end

-- 创建阵容卡槽人物羁绊详情信息
function MateInfoView:createPrInfoView()
	-- 创建显示羁绊详细信息的parent
	local retNode = cc.Node:create()
	retNode:setContentSize(self.mPrViewSize)
	retNode:setIgnoreAnchorPointForPosition(false)
	retNode:setAnchorPoint(cc.p(0.5, 0))
	retNode:setPosition(320, 110)
	self:addChild(retNode)
	self.mPrInfoView = retNode

	-- 详细信息滑动部分
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(self.mPrViewSize)
    scrollView:setDirection(ccui.ScrollViewDir.vertical);
    scrollView:setPosition(0, 0);
    retNode:addChild(scrollView)

    -- 羁绊信息真正的parent
    local prParent = cc.Node:create()
    scrollView:addChild(prParent)

    retNode.refresh = function()
    	prParent:removeAllChildren()
    	local parentPosY = 0
    	local function dealOneSlotPrInfo(slotPr)
    		-- 阵容卡槽信息
    		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(slotPr.slotId)
    		if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
    			return
    		end

    		local heroInfo = {}
    		if self.mIsMyself then
    			heroInfo = HeroObj:getHero(slotInfo.HeroId)
    		else
    			heroInfo = slotInfo.Hero
    		end
    		local name = ConfigFunc:getHeroName(heroInfo.ModelId, {IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
    		if HeroModel.items[heroInfo.ModelId].specialType == Enums.HeroType.eMainHero then
				if not self.mIsMyself then
					name = self.mFormationObj:getThisPlayerInfo().Name
				else
					name = PlayerAttrObj:getPlayerAttrByName("PlayerName")
				end
		    end

    		-- 羁绊信息
		    local tempLabelList, tempLabelHeight = {}, 0
		    for _, prInfo in ipairs(slotPr.prInfo) do
		    	local currColor = prInfo.havePr and Enums.Color.ePrColor or Enums.Color.eNotPrColor
				local currColorH = prInfo.havePr and Enums.Color.ePrColorH or Enums.Color.eNotPrColorH

		    	local tmpNameLabel = ui.newLabel({
					text = prInfo.prName,
					color = currColor,
					size = 22,
				})
				tmpNameLabel:setAnchorPoint(cc.p(0, 1))

				--
				local strText = ""
				for _,v in ipairs(string.splitBySep(prInfo.prIntro, Enums.Color.ePrColorH)) do
					strText = strText .. currColorH .. v
				end
		    	local tmpInfoLabel = ui.newLabel({
					text = strText,
					color = currColor,
					size = 22,
					align = cc.TEXT_ALIGNMENT_LEFT,
		        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		        	dimensions = cc.size(250, 0)
				})
				tmpInfoLabel:setAnchorPoint(cc.p(0, 1))

				local tempHeight = tmpInfoLabel:getContentSize().height
				tempLabelHeight = tempLabelHeight + tempHeight + 10
				table.insert(tempLabelList, {nameLabel = tmpNameLabel, infoLabel = tmpInfoLabel, labelHeight = tempHeight})
		    end

		    -- 缘分背景和标题
		    local tempBgHeight = tempLabelHeight + 113
		    local tempCellSize = cc.size(self.mPrViewSize.width, tempBgHeight)
		  	local tempTitle = string.format("Lv.%d %s %+d", (heroInfo.Lv or 0), name, (heroInfo.Step or 0))
		  	local tempBgSprite = ui.newNodeBgWithTitle(prParent, tempCellSize, tempTitle, cc.p(self.mPrViewSize.width / 2, parentPosY), cc.p(0.5, 1))
		  	parentPosY = parentPosY - tempBgHeight - 10

		    -- 缘分信息
		    local tempLabelPosY = tempBgHeight - 70
		    for i,v in ipairs(tempLabelList) do
		    	v.nameLabel:setPosition(10, tempLabelPosY)
		    	v.infoLabel:setPosition(120, tempLabelPosY)
		    	tempBgSprite:addChild(v.nameLabel)
		    	tempBgSprite:addChild(v.infoLabel)
		    	tempLabelPosY = tempLabelPosY - v.labelHeight - 10
		    end
    	end

    	for index, slotPr in ipairs(self.mSlotPrInfo) do
    		dealOneSlotPrInfo(slotPr)
    	end

		local tempHeight = math.max(self.mPrViewSize.height, math.abs(parentPosY))
		prParent:setPosition(0, tempHeight)
		scrollView:setInnerContainerSize(cc.size(self.mPrViewSize.width, tempHeight))
		scrollView:jumpToTop()
    end
    retNode.refresh()
end

-- 刷新页面
function MateInfoView:refreshView()
	self:refreshMateSlot()
	self:refreshPrInfo()
	if self.mPrInfoView then
		self.mPrInfoView.refresh()
	end
	if self.mSlotCardView then
		self.mSlotCardView.refresh()
	end
end

return MateInfoView
