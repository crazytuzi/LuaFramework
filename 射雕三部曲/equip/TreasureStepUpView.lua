--[[
文件名:TreasureStepUpView.lua
描述：神兵进阶页面
创建人：liaoyuangang
创建时间：2016.06.19
--]]

local TreasureStepUpView = class("TreasureStepUpView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		treasureId: 神兵实例Id
	}
]]
function TreasureStepUpView:ctor(params)
	params = params or {}
	-- 神兵实例Id
	self.mTreasureId = params.treasureId
	-- 该神兵的信息
	self.mTreasureItem = TreasureObj:getTreasure(self.mTreasureId)
	self.mTreasureModelId = self.mTreasureItem.ModelId
	self.mTreasureModel = TreasureModel.items[self.mTreasureModelId]
	-- 消耗道具的信息
	self.mUseGoodsInfo = nil
	-- 消耗同名卡的信息
	self.mUseSameInfo = nil
	-- 消耗铜币的信息
	self.mUseGoldInfo = nil

	-- 选择进阶消耗外功秘籍的过滤条件
	self.mUseTreasureFilter = {
		excludeIdList = {self.mTreasureItem.Id},
		isTreasureStepUp = true
	}

	-- 进阶的默认消耗类型
	self:setDefaultUseType()

    -- 注意：该页面因为是直接被add到TreasureUpLayer上面，不需要再次执行MinScale缩放了
	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function TreasureStepUpView:initUI()
	-- 创建神兵图片
	local tempNode = Figure.newTreasure({
		modelId = self.mTreasureModelId, 
		needAction = true,
		viewSize = cc.size(640, 400)
	})
	tempNode:setAnchorPoint(cc.p(0.5, 0))
	tempNode:setPosition(320, 540)
	self:addChild(tempNode)

	-- 进阶信息的背景
	local tempSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 610))
	tempSprite:setPosition(320, 0)
	tempSprite:setAnchorPoint(cc.p(0.5, 0))
	self:addChild(tempSprite)

	-- 创建进阶数图片标识
	self:createStepImg()
	-- 创建神兵名称等基本信息
	self:createBaseAtrr()
	-- 创建进阶前后的属性
	self:createStepAttr()
	-- 创建进阶消耗
	self:createStepUse()
end

-- 创建装备名称等基本信息
function TreasureStepUpView:createBaseAtrr()
	local hColor = Utility.getQualityColor(self.mTreasureModel.quality, 2)
	_, _, self.mNameLabel = Figure.newNameAndStar({
		parent = self,
		position = cc.p(320, 980),
		nameText = "",
		starCount = Utility.getQualityColorLv(self.mTreasureModel.quality),
		})
	self.mNameLabel.refresh = function (target)
		target:setString(TR("等级%d %s%s%s +%d", self.mTreasureItem.Lv, hColor, self.mTreasureModel.name, "#FFFBDE", self.mTreasureItem.Step))
	end
	self.mNameLabel:refresh()
end

-- 创建进阶数图片标识
function TreasureStepUpView:createStepImg()
	local tempSize = cc.size(640, 40)
	self.mStepImgNode = cc.Node:create()
    self.mStepImgNode:setIgnoreAnchorPointForPosition(false)
    self.mStepImgNode:setAnchorPoint(cc.p(0.5, 0))
    self.mStepImgNode:setContentSize(tempSize)
    self.mStepImgNode:setPosition(320, 600)
    self:addChild(self.mStepImgNode)

    self.mStepImgNode.refresh = function()
    	self.mStepImgNode:removeAllChildren()
    	-- 进阶大于10之后需要减10
    	local step = self.mTreasureItem.Step > 10 and (self.mTreasureItem.Step-10) or self.mTreasureItem.Step
    	for index = 1, 10 do
    		local tempSprite = ui.newSprite(index > step and "zr_12.png" or (self.mTreasureItem.Step <= 10 and "zr_13.png" or "zr_08.png"))
    		tempSprite:setPosition(50 + (index - 1) * 60, 20)
    		self.mStepImgNode:addChild(tempSprite)
    	end
    end
    self.mStepImgNode.refresh()
end

-- 创建进阶前后的属性
function TreasureStepUpView:createStepAttr()
	local tempSize = cc.size(582, 165)
	self.mAttrBgSprite = ccui.Layout:create()
	self.mAttrBgSprite:setContentSize(tempSize)
	self.mAttrBgSprite:setIgnoreAnchorPointForPosition(false)
	self.mAttrBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
	self.mAttrBgSprite:setPosition(320, 500)
	self:addChild(self.mAttrBgSprite)

	local leftPosX, rightPosX = 30, 390
 	ui.newNodeBgWithTitle(self.mAttrBgSprite, cc.size(240, 170), TR("进阶前"), cc.p(tempSize.width * 0.21, 150), cc.p(0.5, 1))
 	ui.newNodeBgWithTitle(self.mAttrBgSprite, cc.size(240, 170), TR("进阶后"), cc.p(tempSize.width * 0.79, 150), cc.p(0.5, 1))

	-- 中间的箭头
	local arrowSprite = ui.newSprite("c_67.png")
	arrowSprite:setPosition(tempSize.width / 2 - 5, 90)
	self.mAttrBgSprite:addChild(arrowSprite)
	
	-- 属性控件列表
	local attrLabelList = {}
	-- 创建一个属性Label
	local function createAttrLabel()
		local tempLabel = ui.newLabel({
			text = "",
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		tempLabel:setAnchorPoint(cc.p(0, 0.5))
		self.mAttrBgSprite:addChild(tempLabel)
		return tempLabel
	end

	-- 已强化到最大阶数的提示
	local maxStepHintLabel = createAttrLabel()

	-- 刷新进阶前后属性
	self.mAttrBgSprite.refresh = function()
		local currStep = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, self.mTreasureItem.Step)
		local nextStep = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, self.mTreasureItem.Step + 1)
		local tempItem = nextStep or currStep
		local useCount = 0
		for _, name in ipairs({"HP", "AP", "DAMADDR", "DAMCUTR"}) do
			if tempItem and tempItem[name] and tempItem[name] > 0 then
				useCount = useCount + 1
				if not attrLabelList[useCount] then
					attrLabelList[useCount] = {}
					-- 左边属性的label
					attrLabelList[useCount].leftLabel = createAttrLabel()
					attrLabelList[useCount].leftLabel:setPosition(leftPosX, 90 - (useCount - 1) * 30)
					attrLabelList[useCount].rightLabel = createAttrLabel()
					attrLabelList[useCount].rightLabel:setPosition(rightPosX, 90 - (useCount - 1) * 30)
				end
				local nameStr = ConfigFunc:getViewNameByFightName(name)
				local attrType = ConfigFunc:getFightAttrEnumByName(name)
				
				-- 左边的Label
				local leftLabel = attrLabelList[useCount].leftLabel
				local valueStr = Utility.getAttrViewStr(attrType, currStep[name], false)
				leftLabel:setString(string.format("%s:%s%s", nameStr,Enums.Color.eNormalYellowH, valueStr))

				-- 右边的label
				local rightLabel = attrLabelList[useCount].rightLabel
				local valueStr = nextStep and Utility.getAttrViewStr(attrType, nextStep[name], false) or ""
				if valueStr and valueStr ~= "" then
					rightLabel:setString(string.format("%s:%s%s", nameStr,Enums.Color.eNormalGreenH, valueStr))
				else
					rightLabel:setString("")
				end
			end
		end

		-- 重新设置箭头的位置
		arrowSprite:setPositionY(90 - useCount * 30 / 2 + 15)

		-- 已强化到最大阶数
		if self.mTreasureModel.maxStep == self.mTreasureItem.Step then
			maxStepHintLabel:setString(TR("已进阶到最大阶数"))
			maxStepHintLabel:setPosition(rightPosX, 90 - useCount * 30 / 2 + 15)
		else
			maxStepHintLabel:setString("")
		end

		-- 把多余的label设置为空
		for index = useCount + 1, #attrLabelList do
			local item = attrLabelList[index]
			item.leftLabel:setString("")
			item.rightLabel:setString("")
		end
	end
	self.mAttrBgSprite.refresh()
end

-- 创建进阶消耗
function TreasureStepUpView:createStepUse()
	local tempSize = cc.size(576, 275)
	self.mUseSprite = ccui.Layout:create()
	self.mUseSprite:setContentSize(tempSize)
	self.mUseSprite:setPosition(320, 395)
	self.mUseSprite:setAnchorPoint(cc.p(0.5, 1))
	self:addChild(self.mUseSprite)

	-- 进阶条件
	local tempPosY = tempSize.height - 18
	local tempBgSprite = ui.newScale9Sprite("c_37.png", cc.size(tempSize.width, 170))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(tempSize.width / 2, tempSize.height - 5)
    self.mUseSprite:addChild(tempBgSprite)

    -- 添加标题
    local tempTitleLabel = ui.newLabel({
        text = TR("进阶条件"),
        size = 24,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x47, 0x50, 0x54),
        outlineSize = 2,
    })
    tempTitleLabel.rawText = titleText
    tempTitleLabel:setPosition(tempSize.width / 2, 148)
    tempBgSprite:addChild(tempTitleLabel)
	
	-- 进阶按钮
	local stepBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("进阶"),
		clickAction = function()
			if self.mTreasureModel.maxStep == self.mTreasureItem.Step then  -- 已强化到最大阶数
				ui.showFlashView(TR("该神兵已经进阶到最大等级"))
				return 
			end
			local nextStep = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, self.mTreasureItem.Step)
			if nextStep.needLV > self.mTreasureItem.Lv then
				ui.showFlashView(TR("神兵需要强化到%d级才能继续进阶", nextStep.needLV))
				return 
			end
			-- 判断铜币需求
			if not Utility.isResourceEnough(self.mUseGoldInfo.resourceTypeSub, self.mUseGoldInfo.num, true) then
				return 
			end
			-- 判断资源需求
			local useInfo = self.mIsUseGoods and self.mUseGoodsInfo or self.mUseSameInfo
			local haveCount = self.mIsUseGoods and GoodsObj:getCountByModelId(self.mUseGoodsInfo.modelId) or TreasureObj:getCountByModelId(self.mUseSameInfo.modelId, self.mUseTreasureFilter)
			if haveCount < useInfo.num then
				local useName = self.mIsUseGoods and Utility.getGoodsName(useInfo.resourceTypeSub, useInfo.modelId) or TreasureModel.items[self.mUseSameInfo.modelId].name
				ui.showFlashView(TR("您缺少足够的材料%s，无法继续进阶", useName))
				return 
			end

			-- 请求服务器进阶数据
			self:requestTreasureStepUp()
		end
	})
	stepBtn:setPosition(tempSize.width / 2, 25)
	self.mUseSprite:addChild(stepBtn)

	-- 消耗铜币
	local useGoldNode = ui.createDaibiView({
		resourceTypeSub = ResourcetypeSub.eGold,
        number = 0,
        showOwned = true,
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	useGoldNode:setAnchorPoint(cc.p(0.5, 0.5))
	useGoldNode:setPosition(tempSize.width / 2, 75)
	self.mUseSprite:addChild(useGoldNode)

	local tempPosY = 135
	local selectHintLabel = ui.newLabel({
		text = TR("或者"),
		color = cc.c3b(0x46, 0x22, 0x0d),
		align = cc.TEXT_ALIGNMENT_CENTER,
	})
	selectHintLabel:setPosition(tempSize.width / 2, tempPosY + 30)
	selectHintLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.mUseSprite:addChild(selectHintLabel)

	-- 消耗同名卡
	local treasureCard = CardNode:create({
		cardShape = Enums.CardShape.eCircle, 
		onClickCallback = function()
			self.mIsUseGoods = false
			self.mUseSprite.refresh()
		end
	})
	treasureCard:setPosition(tempSize.width / 2 - 140, tempPosY + 30)
	self.mUseSprite:addChild(treasureCard)

	-- 消耗精华石
	local goodsCard = CardNode:create({
		cardShape = Enums.CardShape.eCircle, 
		onClickCallback = function()
			if not self.mIsUseGoods then
				self.mIsUseGoods = true
				self.mUseSprite.refresh()
			else
				-- 显示精华石详情
                CardNode.defaultCardClick(self.mUseGoodsInfo)
			end
		end
	})
	goodsCard:setPosition(tempSize.width / 2 + 140, tempPosY + 30)
	self.mUseSprite:addChild(goodsCard)

	-- 需要等级
	local needLvLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			outlineColor = Enums.Color.eOutlineColor,
		})
	needLvLabel:setAnchorPoint(cc.p(1, 0.5))
	needLvLabel:setPosition(tempSize.width-10, 148)
    tempBgSprite:addChild(needLvLabel)

	-- 刷新进阶消耗
	self.mUseSprite.refresh = function()
		needLvLabel:setString("")
		-- 
		if self.mTreasureModel.maxStep == 0 then
			selectHintLabel:setString(TR("该神兵不能进阶"))
			return 
		end

		if self.mTreasureModel.maxStep == self.mTreasureItem.Step then  -- 已强化到最大阶数
			-- 升到满星时不需要显示消耗卡
			treasureCard:setVisible(false) 
			goodsCard:setVisible(false)
			selectHintLabel:setString(TR("已进阶到最大阶数"))
			return 
		end
		selectHintLabel:setString(TR("或者"))

		local stepItem = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, self.mTreasureItem.Step)
		-- 解析消耗信息
		for _, item in pairs(stepItem and stepItem.stepUpUse or {}) do
			if Utility.isPlayerAttr(item.resourceTypeSub) then
				self.mUseGoldInfo = item
			else
				self.mUseGoodsInfo = item
			end
		end
		for _, item in pairs(stepItem and stepItem.stepUpUseSub or {}) do
			if not Utility.isPlayerAttr(item.resourceTypeSub) then
				self.mUseSameInfo = item
			end
		end

		-- 设置消耗的精华石
		self.mUseGoodsInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
		if self.mIsUseGoods then
			table.insert(self.mUseGoodsInfo.cardShowAttrs, CardShowAttr.eSelected)
		end
		local atrrCtr = goodsCard:setCardData(self.mUseGoodsInfo)
		local tempAttr = atrrCtr[CardShowAttr.eNum]
		if tempAttr then
			local haveCount = GoodsObj:getCountByModelId(self.mUseGoodsInfo.modelId)
			local colorStr = haveCount < self.mUseGoodsInfo.num and Enums.Color.eRedH or "#2cf12c"
			tempAttr.label:setString(string.format("%s%d/%d", colorStr, haveCount, self.mUseGoodsInfo.num))
		end

		-- 设置消耗的同名卡
		self.mUseSameInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
		if not self.mIsUseGoods then
			table.insert(self.mUseSameInfo.cardShowAttrs, CardShowAttr.eSelected)
		end
		
		local atrrCtr = treasureCard:setCardData(self.mUseSameInfo)
		local tempAttr = atrrCtr[CardShowAttr.eNum]
		if tempAttr then
			local haveCount = TreasureObj:getCountByModelId(self.mUseSameInfo.modelId, self.mUseTreasureFilter)
			local colorStr = haveCount < self.mUseSameInfo.num and Enums.Color.eRedH or "#2cf12c"
			tempAttr.label:setString(string.format("%s%d/%d", colorStr, haveCount, self.mUseSameInfo.num))
		end

		-- 设置需要消耗掉铜币
		useGoldNode.setNumber(self.mUseGoldInfo.num)

		-- 刷新需要等级显示
		local nextStep = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, self.mTreasureItem.Step)
		local hintStr = TR("需要等级：%s%d", nextStep.needLV > self.mTreasureItem.Lv and Enums.Color.eRedH or Enums.Color.eGreenH,
			nextStep.needLV)
		needLvLabel:setString(hintStr)
	end
	self.mUseSprite.refresh()
end

-- 设置进阶的默认消耗类型
function TreasureStepUpView:setDefaultUseType()
	-- 神兵进阶的消耗信息
	local stepItem = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, self.mTreasureItem.Step)
	if not stepItem then
		self.mIsUseGoods = true
		return 
	end
	
	-- 如果同名卡足够，优先使用神兵
	for _, item in pairs(stepItem and stepItem.stepUpUseSub or {}) do
		if not Utility.isPlayerAttr(item.resourceTypeSub) then
			local haveCount = TreasureObj:getCountByModelId(item.modelId, self.mUseTreasureFilter)
			if haveCount >= item.num then
				self.mIsUseGoods = false
				return 
			end
		end
	end 

	-- 如果同名卡不足，再检查道具
	for _, item in pairs(stepItem and stepItem.stepUpUse or {}) do
		if not Utility.isPlayerAttr(item.resourceTypeSub) then
			local haveCount = GoodsObj:getCountByModelId(item.modelId)
			if haveCount >= item.num then
				self.mIsUseGoods = true
				return 
			end
		end
	end

	-- 如果道具和同名卡都不够，默认选中神兵
	self.mIsUseGoods = false
end

-- 刷新页面
function TreasureStepUpView:refresh()
	-- 刷新进阶信息
	self.mNameLabel:refresh()

	-- 刷新进阶数图片标识
	if self.mStepImgNode then
		self.mStepImgNode.refresh()
	end
	-- 刷新进阶属性
	if self.mAttrBgSprite then
		self.mAttrBgSprite.refresh()
	end
	-- 刷新进阶消耗显示
	if self.mUseSprite then
		self.mUseSprite.refresh()
	end
end

-- ========================= 服务器请求相关函数 ===========================
function TreasureStepUpView:requestTreasureStepUp()
	local useItemList, useIdList = {}, {}
	if self.mIsUseGoods then
		useItem = GoodsObj:findByModelId(self.mUseGoodsInfo.modelId)[1]
		table.insert(useItemList, useItem)
		useIdList = ""
	else
		local tempList = TreasureObj:findByModelId(self.mUseSameInfo.modelId, self.mUseTreasureFilter)
		for index = 1, self.mUseSameInfo.num do
			local tempItem = tempList[index]
			if tempItem then
				table.insert(useItemList, tempItem)
				table.insert(useIdList, tempItem.Id)
			end
		end
	end

	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Treasure",
        methodName = "TreasureStepUp",
		svrMethodData = {self.mTreasureId, useIdList, self.mIsUseGoods and 1 or 0},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end

            -- 合成成果后需要把消耗掉的神兵从缓存中删除
			if not self.mIsUseGoods then
		    	TreasureObj:deleteTreasureItems(useItemList)
            end
            -- 修改被进阶神兵信息
            TreasureObj:modifyTreasureItem(response.Value)
			-- 刷新神兵的数据
			self.mTreasureItem = TreasureObj:getTreasure(self.mTreasureId)

            -- 播放进阶成功的特效
            MqAudio.playEffect("shenbing_jinjie.mp3")
			ui.newEffect({
				parent = self,
				effectName = "effect_ui_shenbingqjinjie",
				position = cc.p(320, 700),
				loop = false,
				endRelease = true,
			})

			-- 如果进阶神兵+10——>+11的时候添加一个特效
			if self.mTreasureItem.Step == 11 then
				MqAudio.playEffect("baowujinjie_1.mp3")
				ui.newEffect({
					parent = self,
					effectName = "effect_ui_baowujinjie",
					position = cc.p(325, 703),
					loop = false,
					endRelease = true,
				})
			end 
						
            -- 刷新页面
            self:refresh()
        end,
    })
end

return TreasureStepUpView