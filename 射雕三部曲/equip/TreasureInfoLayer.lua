--[[
	文件名:TreasureInfoLayer.lua
	描述：神兵详细信息页面
	创建人：peiyaoqiang
    创建时间：2017.03.15
--]]

local TreasureInfoLayer = class("TreasureInfoLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		treasureInfo: 神兵实例Id，如果不传入该参数，那么只展示一类的神兵的信息
		treasureModelID: 神兵模型Id, 如果 treasureInfo 为有效值，该参数失效
		needOpt: 是否需要操作按钮(强化、进阶、更换), 只有 treasureInfo 为有效值时，该参数才有效
	}
]]
function TreasureInfoLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	params = params or {}

	-- 处理数据
	if params.treasureInfo ~= nil then
		self.mTreasureItem = clone(params.treasureInfo)
		self.mTreasureModelId = self.mTreasureItem.ModelId or self.mTreasureItem.modelId
		self.mNeedOpt = params.needOpt or false
	else
		self.mTreasureModelId = params.treasureModelID
		self.mNeedOpt = false
	end
	self.mTreasureModel = TreasureModel.items[self.mTreasureModelId]

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function TreasureInfoLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	local tempSprite = ui.newSprite("zr_16.jpg")
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(tempSprite)
	
	-- 获取等级数
	self.mTreasureLv = self.mTreasureItem and self.mTreasureItem.Lv or 0

	-- 创建神兵形象
	self:createFigureInfo()

	-- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(self.mCloseBtn)

	-- 获取途径按钮
	if Utility.getQualityColorLv(self.mTreasureModel.quality) >= 3 then
		local tempBtn = ui.newButton({
			normalImage = "tb_34.png",
			clickAction = function()
				LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = self.mTreasureModel.typeID,
		                modelId = self.mTreasureModelId
		            },
		            cleanUp = false,
		        })
			end
		})
		tempBtn:setPosition(580, 690)
		self.mParentLayer:addChild(tempBtn)
	end

	-- 创建详细信息面板
	self:createInfoLayer()

	-- 创建操作按钮
	if self.mNeedOpt then
		self:createOptBtn()
	end
end
-- 神兵详细信息介绍面板
function TreasureInfoLayer:createInfoLayer()
	-- 面板背景
	local mInfoBg = ui.newScale9Sprite("c_19.png",cc.size(640, 650))
	mInfoBg:setAnchorPoint(cc.p(0.5, 0))
	mInfoBg:setPosition(cc.p(320, 0))
	self.mParentLayer:addChild(mInfoBg)

	-- 灰色背景
	local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, self.mNeedOpt and 530 or 590))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(320, 607)
    mInfoBg:addChild(tmpGraySprite)

	-- 神兵名称等基本信息
	self:createTreasureName()

	-- 创建滑动列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 515))
    self.mListView:setItemsMargin(6)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 85)
    --如果不创建底部三个按钮
    if not self.mNeedOpt then
    	self.mListView:setContentSize(cc.size(640, 575))
    	self.mListView:setPosition(320, 25)
    end
    mInfoBg:addChild(self.mListView)

    -- 宝石基本属性
    self:createBaseAtrr()

    -- 宝石进阶属性
    self:createTreasureStepAtrr()

    -- 宝石解锁属性
    self:createTreasureClear()

    -- 宝石羁绊属性
    self:createTreasurePr()

    -- 神兵简介
    self:createTreasureDescribe()

end
-- 神兵名称等基本信息
function TreasureInfoLayer:createTreasureName()
	local colorLv = Utility.getQualityColorLv(self.mTreasureModel.quality)
	local hColor = Utility.getColorValue(colorLv, 2)
	local strName = TR("等级%d %s%s",self.mTreasureLv, hColor, self.mTreasureModel.name)
	if self.mTreasureItem then
		strName = TR("等级%d %s%s%s +%d",self.mTreasureLv, hColor, self.mTreasureModel.name, "#FFFBDE", (self.mTreasureItem.Step or 0))
	end
	Figure.newNameAndStar({
		parent = self.mParentLayer,
		position = cc.p(320, 1120),
		nameText = strName,
		starCount = colorLv,
		})
end

-- 神兵基本属性
function TreasureInfoLayer:createBaseAtrr()
	-- 判断最大强化等级是否为0  若为0则是经验神兵不能强化
	local tempData = {}
	if TreasureModel.items[self.mTreasureModelId].maxLV == 0 then
		tempData = self:getBaseArr(self.mTreasureModelId)
	else
		self:getBaseArr(self.mTreasureModelId,tempData)
		local data = ConfigFunc:getTreasureBaseViewItem(self.mTreasureModelId, self.mTreasureLv)
		for k,v in pairs(data) do
			table.insert(tempData, v)
		end
	end
	local lengh = #tempData
	local num = math.ceil(lengh/2) - 1 
	num = num < 0 and 0 or num
	num = num + 1
	local width  = 590
	local height = 50 + 35 * num
	local bgSprite = self:createAtrrBg(TR("基础属性"), cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)

	-- 添加属性文字
	for i,v in ipairs(tempData) do
		-- 判断锚点 高度
		local mark = i%2 
		mark = (mark ~= 0) and 0 or 1
		local posY = math.ceil(i/2)
		local label = ui.newLabel({
		text = string.format("%s: %s%s", v.name, Enums.Color.eNormalGreenH, v.value),
		color = cc.c3b(0x46, 0x22, 0x0d),
		}) 
		label:setAnchorPoint(cc.p(0,1))
		label:setPosition(cc.p((width / 2) * mark + 50, height - 50 - (posY - 1) * 35))
		bgSprite:addChild(label)
	end
end

-- 几个经验神兵  只显示等级  资质
function TreasureInfoLayer:getBaseArr(treasureModelID,tableData)
	local ret = {}
	local retName  = {TR("等级"), TR("资质")}
	local retValue = {string.format("%s/%s", self.mTreasureItem and self.mTreasureItem.Lv or 0, TreasureModel.items[treasureModelID].maxLV),TreasureModel.items[treasureModelID].quality}
	for i=1,2 do
		local temp = {}
		temp.name  = retName[i]
		temp.value = retValue[i]
		if tableData then
			table.insert(tableData, temp)
		else
			table.insert(ret, temp)
		end
	end
	return tableData and tableData or ret
end
-- 创建神兵进阶属性
function TreasureInfoLayer:createTreasureStepAtrr()
	local stepTreasure = self.mTreasureItem and self.mTreasureItem.Step or 0
	-- 获取数据
	local currStep = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, stepTreasure)
	local nextStep = ConfigFunc:getTreasureStepItem(self.mTreasureModelId, stepTreasure + 1)
	local tempItem = nextStep or currStep
	-- 没有进阶属性就不显示
	if not tempItem or not next(tempItem) then
		return
	end
	-- 显示进阶属性	
	local width  = 590
	local height = 180
	local bgSprite = self:createAtrrBg(TR("进阶属性"),cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)

	--进阶的图标表示
	local tempSize = cc.size(550, 40)
	self.mStepImgNode = cc.Node:create()
    self.mStepImgNode:setIgnoreAnchorPointForPosition(false)
    self.mStepImgNode:setAnchorPoint(cc.p(0.5, 1.0))
    self.mStepImgNode:setContentSize(tempSize)
    self.mStepImgNode:setPosition(295, height - 45)
    bgSprite:addChild(self.mStepImgNode)
    -- 刷新
    self.mStepImgNode.refresh = function()
    	self.mStepImgNode:removeAllChildren()
    	local step = stepTreasure > 10 and (stepTreasure-10) or stepTreasure

    	for index = 1, 10 do
    		local tempSprite = ui.newSprite(index > step and "zr_12.png" or (stepTreasure <= 10 and "zr_13.png" or "zr_08.png"))
    		local detalW = (width - 10 * tempSprite:getContentSize().width) / 11
    		tempSprite:setAnchorPoint(cc.p(0, 0))
    		local posY = 0
    		if index > 10 then
    			index = index - 10
    			posY = -50
    		end
    		tempSprite:setPosition(index * detalW + (index - 1) * tempSprite:getContentSize().width, posY)
    		self.mStepImgNode:addChild(tempSprite)
    	end
    end
    self.mStepImgNode.refresh()

	-- 显示文字
	local index = 1
	for i, name in ipairs({"HP", "AP", "DAMADDR", "DAMCUTR"}) do
		if tempItem[name] and tempItem[name] > 0 then

			local mark = index%2 
			mark = mark ~= 0 and 0 or 1
			local posY = math.ceil(index/2)

			local nameStr = ConfigFunc:getViewNameByFightName(name)
			local attrType = ConfigFunc:getFightAttrEnumByName(name)

			local valueStr = Utility.getAttrViewStr(attrType, currStep[name], false)
			local font = ui.newLabel({
					text = string.format("%s: %s%s", nameStr, Enums.Color.eNormalGreenH, valueStr),
					color = cc.c3b(0x46, 0x22, 0x0d)
				})
			font:setAnchorPoint(cc.p(0,1))
			font:setPosition(cc.p((width / 2) * mark + 50, height - 100 - (posY - 1) * 40))
			bgSprite:addChild(font)
			index = index + 1
		end
	end
end

-- 创建神兵解锁属性
function TreasureInfoLayer:createTreasureClear()
	--数据处理
	local activeItems = ConfigFunc:getTreasureLvActiveItem(self.mTreasureModelId, self.mTreasureLv)
	local fontArr = {}
	for i, item in pairs(activeItems) do
		local viewInfos = ConfigFunc:getTreasureLvActiveViewItem(item)
		local tempList = {}
		local tempColor = (item.needLV > self.mTreasureLv) and "#46220D" or Enums.Color.eNormalGreenH

		for i, viewItem in pairs(viewInfos) do
			table.insert(tempList, string.format("%s%s: %s%s", "#46220D", viewItem.name, tempColor, viewItem.value))
		end
		if item.needLV > self.mTreasureLv then
			table.insert(tempList, TR("  %s(%d级解锁)", tempColor, item.needLV))
		else
			table.insert(tempList, TR("  %s(已解锁属性)", tempColor))
		end
		local text = table.concat(tempList, "    ")
		table.insert(fontArr,i,text)
	end
	-- 没有数据 不显示
	if not next(fontArr) then
		return
	end
	-- 计算显示高度
	local length = #fontArr
	local width  = 590
	local height = 50 + 50 * length
	local bgSprite = self:createAtrrBg(TR("解锁属性"), cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)
	-- 显示
	for i=1,length do
		local tempLabel = ui.newLabel({
				text = fontArr[i],
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		tempLabel:setAnchorPoint(cc.p(0, 1.0))
		tempLabel:setPosition(50, height - 50 * i)
		bgSprite:addChild(tempLabel)
	end
end

-- 创建神兵羁绊属性
function TreasureInfoLayer:createTreasurePr()
	local prHeroModel = TreasureModel.items[self.mTreasureModelId].prHeroModelIds
	-- 没有羁绊属性就不显示
	if not prHeroModel or not next(prHeroModel) then
		return
	end
	local bgSprite = self:createAtrrBg(TR("羁绊"),cc.size(590, 225))
	self.mListView:pushBackCustomItem(bgSprite)

	-- 获取上阵人物信息
	local formationHero = {}
	for key, item in pairs(FormationObj.mSlotHeros) do
        if key ~= "count" then
            formationHero[item.Id] = item
        end
    end
    -- 判断是否需要包含江湖后援团
    for key, item in pairs(FormationObj.mMateHeros) do
        if key ~= "count" then
            formationHero[item.Id] = item
        end
    end
    
	-- 文字显示
	local font = ui.newLabel({
			text = TR("该神兵可与以下侠客形成羁绊"),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 23,
		})
	font:setAnchorPoint(cc.p(0.5, 1))
	font:setPosition(cc.p(320, 150 + 25))
	bgSprite:addChild(font)
	-- 添加羁绊人物表
	local card = {}
	local isMianHeroMale = 0
	local isMianHeroFeMale = 0
	local cardIndex = {}
	for k,v in ipairs(prHeroModel) do
		local card_ = {}
		local formationHeroId = 0
		
		card_.modelId = v
		card_.num = 1
		card_.resourceTypeSub = ResourcetypeSub.eHero
		card_.cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eName,
        }

        -- 判断人物是否在阵容
		for i,format in pairs(formationHero) do
			if format.HeroModelId == v then
				card_.cardShowAttrs = {
		            CardShowAttr.eBorder,
		            CardShowAttr.eName,
		            CardShowAttr.eSelected,
		        }
				formationHeroId = v
			end
		end
		local heroModel = HeroModel.items[v]
		-- 主角显示在第一个
		if heroModel.specialType == Enums.HeroType.eMainHero then
			if v == formationHeroId then
				table.insert(card,1,card_)
			end
		else
			table.insert(card,card_)
		end
	end
	-- 显示列表
	local cardList = ui.createCardList({
			maxViewWidth = 550, -- 显示的最大宽度
        	space = 10, -- 卡牌之间的间距, 默认为 10
        	cardDataList = card,
        })
	cardList:setAnchorPoint(cc.p(0.5, 1.0))
	cardList:setPosition(cc.p(320, 100 + 10 + 25))
	bgSprite:addChild(cardList)
	
	-- 已经上阵的英雄 增加闪光效果
	local cardListItem = cardList.getCardNodeList()
	for k,v in pairs(cardListItem) do
		local attr = v:getAttrControl() 
		if attr[CardShowAttr.eSelected] then
			ui.newEffect({
                parent = v,
                effectName = "effect_ui_liubian",
                position = cc.p(v:getContentSize().width / 2, v:getContentSize().height / 2),
                loop = true,
                endRelease = true,
                speed = 1,
            })
		end
	end
end
-- 创建神兵简介
function TreasureInfoLayer:createTreasureDescribe()
	local introText = TreasureModel.items[self.mTreasureModelId].intro or ""
	local introLabel = ui.newLabel({
			text = introText,
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(550, 0)
		})
	introLabel:setAnchorPoint(cc.p(0.5, 1.0))
	introLabel:setPosition(cc.p(295 + 25, introLabel:getContentSize().height + 15))
	-- 根据文字高度设定背景高度
	local bgSprite = self:createAtrrBg(TR("神兵简介"), cc.size(590, introLabel:getContentSize().height + 60))
	self.mListView:pushBackCustomItem(bgSprite)
	bgSprite:addChild(introLabel)
end

-- 创建每一个属性背景
function TreasureInfoLayer:createAtrrBg(titleText, bgSize)
	local custom_item = ccui.Layout:create()
    custom_item:setIgnoreAnchorPointForPosition(false)
    
	local tmpBgSprite = ui.newNodeBgWithTitle(custom_item, bgSize, titleText)
	local tmpBgSize = tmpBgSprite:getContentSize()

	custom_item:setContentSize(tmpBgSize)
	custom_item:setAnchorPoint(cc.p(0.5, 0.5))
    custom_item:setPosition(cc.p(320, tmpBgSize.height/2))
    tmpBgSprite:setPosition(cc.p(320, tmpBgSize.height/2))

	return custom_item
end

-- 创建神兵形象
function TreasureInfoLayer:createFigureInfo()
	-- 创建神兵图片
	local tempNode = Figure.newTreasure({
		modelId = self.mTreasureModelId, 
		needAction = true,
		viewSize = cc.size(640, 400)
	})
	tempNode:setAnchorPoint(cc.p(0.5, 0))
	tempNode:setPosition(320, 650)
	self.mParentLayer:addChild(tempNode)
end

-- 创建操作按钮
function TreasureInfoLayer:createOptBtn()
	self.optBtnList = {}
	local btnInfos = {
		{
			text = TR("强化"),
			clickAction = function()
				-- 条件判断是否可以强化
				-- todo

				LayerManager.addLayer({
		            name = "equip.TreasureUpLayer",
		            data = {
		                treasureId = self.mTreasureItem.Id, 
		                subPageType = ModuleSub.eTreasureLvUp,
		            },
		        })
			end
		},
		{
			text = TR("进阶"),
			isRedDot = true,
			clickAction = function()
				-- 条件判断是否可以进阶
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eTreasureStepUp , true) then
	                return 
	            end
	            -- 判断是否达到开启等级
	            if self.mTreasureModel.maxStep == 0 then  -- 判断该神兵是否可以进阶
	                ui.showFlashView(TR("该神兵不能进阶"))
	                return 
	            end

				LayerManager.addLayer({
		            name = "equip.TreasureUpLayer",
		            data = {
		                treasureId = self.mTreasureItem.Id,
		                subPageType = ModuleSub.eTreasureStepUp,
		            },
		        })
			end
		},
	}
	-- 如果该神兵已上阵，则还需要更换按钮
	local information, slotId = FormationObj:equipInFormation(self.mTreasureItem.Id)
	if information then
		local tempItem = {
			text = TR("更换"),
			clickAction = function()
                local tempData = {
					slotId = slotId,
	        		resourcetypeSub = self.mTreasureModel.typeID,
				}
				LayerManager.addLayer({
					name = "team.TeamSelectEquipLayer",
					data = tempData
				})
			end
		}
		table.insert(btnInfos, tempItem)
	end

	local tempPosY, spaceX = 40, 200
	local startPosX = (640 - #btnInfos * spaceX) / 2 + spaceX / 2
	for index, item in pairs(btnInfos) do
		item.normalImage = "c_28.png"
		local tempBtn = ui.newButton(item)
		tempBtn:setPosition(startPosX + (index - 1) * spaceX, tempPosY)
		self.mParentLayer:addChild(tempBtn)
		-- 保存功能按钮
		table.insert(self.optBtnList, tempBtn)

		-- 进阶按钮添加小红点
        if item.isRedDot then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eTreasureStepUp, nil, slotId))
            end
            local eventNames = {EventsName.eSlotRedDotPrefix .. tostring(slotId)}
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = eventNames, parent = tempBtn})
        end
	end
end

-- ========================== 新手引导 ===========================
function TreasureInfoLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function TreasureInfoLayer:executeGuide()
	Guide.helper:executeGuide({
		-- 领取神兵升级道具
        [113011] = {nextStep = function(eventID, isGot)
            if isGot then
                -- 领取服务器物品成功执行下一步
                Guide.manager:nextStep(113011)
            end
            self:executeGuide()
        end},
        [11302] = {clickNode = self.optBtnList and self.optBtnList[1]},
    })
end

return TreasureInfoLayer