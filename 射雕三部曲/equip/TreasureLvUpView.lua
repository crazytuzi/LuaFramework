--[[
	文件名:TreasureLvUpView.lua
	描述：神兵强化页面
	创建人：liaoyuangang
	创建时间：2016.06.19
--]]

local TreasureLvUpView = class("TreasureLvUpView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		treasureId: 神兵实例Id
		useDataList: 作为神兵强化消耗神兵列表
	}
]]
function TreasureLvUpView:ctor(params)
	params = params or {}
	-- 神兵实例Id
	self.mTreasureId = params.treasureId
	-- 作为神兵强化消耗神兵列表
	self.mUseDataList = params.useDataList or {}
	-- 检查消耗物品列表
	for index = #self.mUseDataList, 1, -1 do
		local tempItem = self.mUseDataList[index]
		if tempItem.ModelId and not TreasureObj:getTreasure(tempItem.Id) then
			table.remove(self.mUseDataList, index)
		end
	end

	-- 该神兵的信息
	self.mTreasureItem = TreasureObj:getTreasure(self.mTreasureId)
	self.mTreasureModelId = self.mTreasureItem.ModelId
	self.mTreasureModel = TreasureModel.items[self.mTreasureModelId]

	-- 注意：该页面因为是直接被add到TreasureUpLayer上面，不需要再次执行MinScale缩放了
	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function TreasureLvUpView:initUI()
	-- 创建神兵图片
	local tempNode = Figure.newTreasure({
		modelId = self.mTreasureModelId,
		needAction = true,
		viewSize = cc.size(640, 400)
	})
	tempNode:setAnchorPoint(cc.p(0.5, 0))
	tempNode:setPosition(320, 540)
	self:addChild(tempNode)

	-- 强化信息的背景
	local tempSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 610))
	tempSprite:setPosition(320, 0)
	tempSprite:setAnchorPoint(cc.p(0.5, 0))
	self:addChild(tempSprite)

	-- 创建装备名称等基本信息
	self:createBaseAtrr()
	-- 创建强化消耗的神兵卡槽列表
	self:createUseCardList()
	-- 创建强化属性信息
	self:createLvAttr()
end

function TreasureLvUpView:getRestoreData()
    local retData = {}

    retData.treasureId = self.mTreasureId
    retData.useDataList = self.mUseDataList

    return retData
end

-- 创建装备名称等基本信息
function TreasureLvUpView:createBaseAtrr()
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

-- 创建强化消耗的神兵卡槽列表
function TreasureLvUpView:createUseCardList()
	local tempSize = cc.size(582, 145)
	self.mUseBgSprite = ccui.Layout:create()
	self.mUseBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
	self.mUseBgSprite:setContentSize(tempSize)
	self.mUseBgSprite:setPosition(320, 510)
	self:addChild(self.mUseBgSprite)

	-- 卡牌列表
	local cardList = {}
	local spaceX, tempPosY = 120, tempSize.height - 45
	local startPosX = (tempSize.width - 5 * spaceX) / 2 + spaceX / 2
	for index = 1, 5 do
		local tempCard = CardNode:create({
			cardShape = Enums.CardShape.eCircle,
			onClickCallback = function()
				if self.mTreasureModel.maxLV == 0 then
					ui.showFlashView(TR("该神兵不能强化"))
					return
				end

				LayerManager.addLayer({
	        		name = "commonLayer.SelectLayer",
	        		data = {
	        			selectType = Enums.SelectType.eTreasureLvUp,
	        			resourcetypeSub = self.mTreasureModel.typeID,
	        			oldSelList = self.mUseDataList,
	        			excludeIdList = {self.mTreasureItem.Id},
	        			callback = function(selectLayer, selectItemList, resourcetype)
	        				local tempData = LayerManager.getRestoreData("equip.TreasureUpLayer") or {}
	        				tempData.subPageData = tempData.subPageData or {}
	        				tempData.subPageData[ModuleSub.eTreasureLvUp] = tempData.subPageData[ModuleSub.eTreasureLvUp] or {}
	        				tempData.subPageData[ModuleSub.eTreasureLvUp].useDataList = selectItemList
	        				LayerManager.setRestoreData("equip.TreasureUpLayer", tempData)

	        				-- 删除装备选择页面
	        				LayerManager.removeLayer(selectLayer)
	        			end
	        		},
	        	})
			end
		})
		tempCard:setPosition(startPosX + (index - 1) * spaceX, tempPosY)
		self.mUseBgSprite:addChild(tempCard)
		tempCard:setScale(0.9)
		table.insert(cardList, tempCard)
	end

	local progPos = cc.p(tempSize.width / 2, 24)

	-- 创建强化进度条(当前进度)
	local currProg = require("common.ProgressBar").new({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        currValue = 20,
        maxValue = 100,
        barType = ProgressBarType.eHorizontal,
    })
    currProg:setAnchorPoint(cc.p(0.5, 0.5))
    currProg:setPosition(progPos)
    self.mUseBgSprite:addChild(currProg)

    -- 进度的提示信息
    local progLabel = ui.newLabel({
		text = "",
		size = 18,
		outlineColor = Enums.Color.eOutlineColor,
		outlineSize = 2,
	})
	progLabel:setPosition(progPos)
	progLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.mUseBgSprite:addChild(progLabel)

	-- 刷新消耗卡牌列表
	self.mUseBgSprite.refresh = function()
		-- 刷新卡牌显示
		for index, cardNode in pairs(cardList) do
			local tempData = self.mUseDataList[index]
			if tempData then
				cardNode:setTreasure(tempData)
			else
				cardNode:setEmpty({}, "c_04.png")
				cardNode:showGlitterAddMark("c_22.png", 1.2)
			end
		end

		-- 刷新强化进度条
		local useExp = self:getAddExp()

		local currInfo = ConfigFunc.getTreasureExpProg(self.mTreasureModelId, self.mTreasureItem.EXP, self.mTreasureItem.Lv)
		local nextInfo = ConfigFunc.getTreasureExpProg(self.mTreasureModelId, self.mTreasureItem.EXP + useExp, self.mTreasureItem.Lv)
		-- 设置进度
		currProg:setMaxValue(currInfo.nextMaxExp)
		currProg:setCurrValue(currInfo.nextExp)
		-- 设置提示信息
		local currCount = currInfo.nextMaxExp ~= 0 and math.floor(currInfo.nextExp / currInfo.nextMaxExp * 100) or 0
		if useExp > 0 then
			if nextInfo.Lv > self.mTreasureItem.Lv then
				progLabel:setString(TR("当前经验: %d%%%s(可升至%d级)", currCount, Enums.Color.eYellowH, nextInfo.Lv))
			else
				local nextCount = nextInfo.nextMaxExp ~= 0 and math.floor(nextInfo.nextExp / nextInfo.nextMaxExp * 100) or 0
				progLabel:setString(TR("当前经验: %d%%%s(可升至%d%%)", currCount, Enums.Color.eYellowH, nextCount))
			end
		else
			progLabel:setString(TR("当前经验: %d%%", currCount))
		end
	end
	self.mUseBgSprite.refresh()
end

-- 创建强化属性信息
function TreasureLvUpView:createLvAttr()
	local tempSize = cc.size(582, 300)
	self.mAttrBgSprite = ccui.Layout:create()
	self.mAttrBgSprite:setContentSize(tempSize)
	self.mAttrBgSprite:setAnchorPoint(cc.p(0.5, 1))
	self.mAttrBgSprite:setPosition(320, 390)
	self:addChild(self.mAttrBgSprite)

 	local baseBgSprite = ui.newNodeBgWithTitle(self.mAttrBgSprite, cc.size(590, 114), TR("基础属性"), cc.p(tempSize.width / 2, tempSize.height + 50), cc.p(0.5, 1))
 	local activeBgSprite = ui.newNodeBgWithTitle(self.mAttrBgSprite, cc.size(590, 114), TR("解锁属性"), cc.p(tempSize.width / 2, tempSize.height - 70), cc.p(0.5, 1))

	-- 自动放入按钮
	local autoSelbtnPos = cc.p(tempSize.width / 2 - 150, tempSize.height - 250)
	local autoSelBtn = ui.newButton({
		normalImage = "c_33.png",
		text = TR("自动放入"),
		clickAction = function()
			if self.mTreasureModel.maxLV == 0 then
				ui.showFlashView(TR("该神兵不能强化"))
				return
			end

			local tempList = TreasureObj:getTreasureList({
				isTreasureLvUp = true,
				resourcetypeSub = self.mTreasureModel.typeID,
				excludeIdList = {self.mTreasureItem.Id},
				excludeModelIdList = {14010301, 14010302}, -- 用于人物突破的基础神兵
				maxColorLv = 3,
			})
			table.sort(tempList, function(item1, item2)
				local model1 = TreasureModel.items[item1.ModelId]
				local model2 = TreasureModel.items[item2.ModelId]
				if model1.quality ~= model2.quality then
					return model1.quality < model2.quality
				end
				if item1.Lv ~= item2.Lv then
					return item1.Lv < item2.Lv
				end

				return item1.ModelId < item2.ModelId
			end)

			-- 新手引导时仅放入一个道具，避免超过玩家等级
            local _, _, eventID = Guide.manager:getGuideInfo()
			self.mUseDataList = {}
			for index = 1, (eventID == 113021) and 1 or 5 do
				if tempList[index] then
					table.insert(self.mUseDataList, tempList[index])
				end
			end
			-- 刷新页面
			self:refresh()

            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 113021 then
                -- 不删除引导界面，后续还在此界面引导
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end
		end
	})
	autoSelBtn:setPosition(autoSelbtnPos)
	self.mAttrBgSprite:addChild(autoSelBtn)
	-- 保存按钮，引导使用
	self.autoSelBtn = autoSelBtn

	-- 当前可获得的经验数
	local expAddLabel = ui.newLabel({
		text = TR("获得经验: %d", 0),
        color = cc.c3b(0x46, 0x22, 0x0d),
	})
	expAddLabel:setAnchorPoint(cc.p(0.5, 0.5))
	expAddLabel:setPosition(autoSelbtnPos.x, autoSelbtnPos.y + 45)
	self.mAttrBgSprite:addChild(expAddLabel)

	-- 强化按钮
	local lvUpBtnPos = cc.p(tempSize.width / 2 + 150, tempSize.height - 250)
	local lvUpBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("强化"),
		clickAction = function()
			if self.mTreasureModel.maxLV == 0 then
				ui.showFlashView(TR("该神兵不能强化"))
				return
			end

			if not TreasureLvRelation.items[self.mTreasureItem.Lv + 1] then
				ui.showFlashView(TR("该神兵已经强化到最高等级"))
				return
			end
			-- 判断强化后是否操作主角等级
			local useExp = self:getAddExp()
			local nextInfo = ConfigFunc.getTreasureExpProg(self.mTreasureModelId,
				self.mTreasureItem.EXP + useExp, self.mTreasureItem.Lv)
			local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
			if self.mTreasureItem.Lv >= playerLv or nextInfo.Lv > playerLv then
				ui.showFlashView(TR("神兵等级不能超过主角等级"))
				return
			end
			-- 判断铜币需求
			if not Utility.isResourceEnough(ResourcetypeSub.eGold, useExp, true) then
            	--[[--------新手引导容错处理--------]]--
            	local _, _, eventID = Guide.manager:getGuideInfo()
            	if eventID == 11303 then
            		Guide.helper:guideError(eventID, -1)
           		end
				return
			end

			if #self.mUseDataList == 0 then
				ui.showFlashView(TR("您尚未选择可用的材料，无法继续强化"))
				return
			end

			self:requestTreasureLvUp()
		end
	})
	lvUpBtn:setPosition(lvUpBtnPos)
	self.mAttrBgSprite:addChild(lvUpBtn)
	-- 保存按钮，引导使用
	self.lvUpBtn = lvUpBtn

	-- 需要消耗掉铜币数
	local useGoldNode = ui.createDaibiView({
		resourceTypeSub = ResourcetypeSub.eGold,
        number = 0,
        showOwned = true,
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	useGoldNode:setAnchorPoint(cc.p(0.5, 0.5))
	useGoldNode:setPosition(lvUpBtnPos.x, lvUpBtnPos.y + 45)
	self.mAttrBgSprite:addChild(useGoldNode)

	-- 刷新强化属性
	self.mAttrBgSprite.refresh = function()
		-- 可获得的经验
		local useExp = self:getAddExp()
		expAddLabel:setString(TR("获得经验:%d", useExp))
		-- 需要的铜币
		useGoldNode.setNumber(useExp)

		local currLv = self.mTreasureItem.Lv
		local nextInfo = ConfigFunc.getTreasureExpProg(self.mTreasureModelId, self.mTreasureItem.EXP + useExp, currLv)

		-- 设置基础属性
		baseBgSprite:clearAllChildren()
		local function createOneAttr(name, valueStr, pos, addStr)
			-- 当前值
			local currLabel = ui.newLabel({
				text = string.format("%s:%s%s", name,Enums.Color.eNormalYellowH, valueStr),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
			currLabel:setAnchorPoint(cc.p(0, 0.5))
			currLabel:setPosition(pos)
			baseBgSprite:addChild(currLabel)

			if addStr and addStr ~= "" then
				local currLabelSize = currLabel:getContentSize()
				local addLabel = ui.newLabel({
					text = addStr,
					color = Enums.Color.eNormalGreen,
					align = cc.TEXT_ALIGNMENT_CENTER,
				})
				baseBgSprite:addChild(addLabel)
				local addLabelSize = addLabel:getContentSize()
				addLabel:setPosition(pos.x + currLabelSize.width + addLabelSize.width / 2 + 10, pos.y)

				addLabel:runAction(cc.RepeatForever:create(cc.Sequence:create({
					cc.ScaleTo:create(1, 1.1),
					cc.ScaleTo:create(1, 0.9),
				})))
			end
		end
		-- 等级
		local currLvAtrr = ConfigFunc:getTreasureLvItem(self.mTreasureModelId, currLv)
		if currLv ~= nextInfo.Lv then
			createOneAttr(TR("等级"), tostring(currLv), cc.p(30, 52), string.format("(+%d)", nextInfo.Lv - currLv))
			local nextLvAttr = ConfigFunc:getTreasureLvItem(self.mTreasureModelId, nextInfo.Lv)
			local tempPosX = 0
			for index, item in ipairs({"AP", "HP"}) do
				local nCurrValue = currLvAtrr[item] or 0
				local nNextValue = nextLvAttr[item] or 0
				if nNextValue > 0 then
					local nameStr = ConfigFunc:getViewNameByFightName(item)
					local attrType = ConfigFunc:getFightAttrEnumByName(item)
					local currValueStr = Utility.getAttrViewStr(attrType, nCurrValue, false)
					local nextValueStr = Utility.getAttrViewStr(attrType, (nNextValue - nCurrValue))
					createOneAttr(nameStr, currValueStr, cc.p(30 + tempPosX, 22), string.format("(%s)", nextValueStr))
					tempPosX = tempPosX + 260
				end
			end
		else
			createOneAttr(TR("等级"), tostring(currLv), cc.p(30, 52))
			local tempPosX = 0
			for index, item in ipairs({"AP", "HP"}) do
				local nCurrValue = currLvAtrr[item] or 0
				if nCurrValue > 0 then
					local nameStr = ConfigFunc:getViewNameByFightName(item)
					local attrType = ConfigFunc:getFightAttrEnumByName(item)
					local currValueStr = Utility.getAttrViewStr(attrType, nCurrValue, false)
					createOneAttr(nameStr, currValueStr, cc.p(30 + tempPosX, 22))

					tempPosX = tempPosX + 260
				end
			end
		end

		-- 设置解锁属性
		activeBgSprite:clearAllChildren()
		local activeItems = ConfigFunc:getTreasureLvActiveItem(self.mTreasureModelId, currLv)
		for _, item in pairs(activeItems) do
			local viewInfos = ConfigFunc:getTreasureLvActiveViewItem(item)
			local tempList = {}
			local tempColor = (item.needLV > currLv) and "#46220D" or Enums.Color.eNormalGreenH
			local yPos = (item.needLV > currLv) and 22 or 52

			for _, viewItem in pairs(viewInfos) do
				table.insert(tempList, string.format("%s%s: %s%s  ", "#46220D", viewItem.name, tempColor, viewItem.value))
			end
			if item.needLV > currLv then
				table.insert(tempList, TR("  %s(%d级解锁)", tempColor, item.needLV))
			else
				table.insert(tempList, TR("  %s(已解锁属性)", tempColor))
			end
			local tempLabel = ui.newLabel({
				text = table.concat(tempList, "  "),
				size = 22,
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
			tempLabel:setAnchorPoint(cc.p(0, 0.5))
			tempLabel:setPosition(30, yPos)
			activeBgSprite:addChild(tempLabel)
		end
	end
	self.mAttrBgSprite.refresh()
end

-- 获取当前选中的消耗神兵的总经验
function TreasureLvUpView:getAddExp()
	local useExp = 0
	for _, item in pairs(self.mUseDataList) do
		local tempModel = TreasureModel.items[item.ModelId]
		useExp = useExp + tempModel.baseExp + item.EXP
	end
	return useExp
end

-- 刷新页面
function TreasureLvUpView:refresh()
	-- 刷新等级信息
	self.mNameLabel:refresh()

	-- 刷新消耗卡牌信息
	if self.mUseBgSprite then
		self.mUseBgSprite.refresh()
	end

	-- 刷新强化属性
	if self.mAttrBgSprite then
		self.mAttrBgSprite.refresh()
	end
end

-- ============================ 服务器数据请求相关函数 ==========================

function TreasureLvUpView:requestTreasureLvUp()
	local tempList = {}
	for _, item in pairs(self.mUseDataList) do
		table.insert(tempList, item.Id)
	end

	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Treasure",
        methodName = "TreasureLvUp",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11303),
        svrMethodData = {self.mTreasureId, tempList},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11303 then
            	Guide.manager:removeGuideLayer()
                Guide.manager:nextStep(eventID)
            end

            -- 合成成果后需要把消耗掉的神兵从缓存中删除
            if not self.mIsUseGoods then
		    	TreasureObj:deleteTreasureItems(self.mUseDataList)
		    	self.mUseDataList = {}
            end
            -- 修改被进阶神兵信息
            TreasureObj:modifyTreasureItem(response.Value)
            -- 刷新神兵的数据
			self.mTreasureItem = TreasureObj:getTreasure(self.mTreasureId)

            -- 播放进阶成功的特效
            MqAudio.playEffect("shenbing_qianghua.mp3")
			ui.newEffect({
				parent = self,
				effectName = "effect_ui_shenbingqianghua",
				position = cc.p(320, 700),
				loop = false,
				endRelease = true,
			})
            -- 刷新页面
            self:refresh()
        end,
    })
end

-- ========================== 新手引导 ===========================
function TreasureLvUpView:onEnterTransitionFinish()
    self:executeGuide()
end

function TreasureLvUpView:executeGuide()
	Guide.helper:executeGuide({
		-- 自动放入按钮
        [113021] = {clickNode = self.autoSelBtn},
        -- 强化按钮
        [11303] = {clickNode = self.lvUpBtn},
    })
end

return TreasureLvUpView
