--[[
    文件名：ZhenshouMainLayer.lua
    描述：英雄突破界面
    创建人：peiyaoqiang
    创建时间：2017.3.11
-- ]]
local ZhenshouMainLayer = class("ZhenshouMainLayer", function()
    return display.newLayer()
end)

--[[
	参数
	selectIndex: 初始选择的id
--]]

function ZhenshouMainLayer:ctor(params)
  	ui.registerSwallowTouch({node = self})

  	self.mSelectIndex = params.selectIndex or 1
  	self.mBottomTag = 1
  	self.mTopSlotList = {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --升级界面父节点
    self.mLvUpNode = cc.Node:create()
    self.mParentLayer:addChild(self.mLvUpNode, 2)

    --升星界面父节点
    self.mStepUpNode = cc.Node:create()
    self.mParentLayer:addChild(self.mStepUpNode, 2)

    --详情界面父节点
    self.mInfoNode = cc.Node:create()
    self.mParentLayer:addChild(self.mInfoNode, 2)

    -- 初始化页面控件
	self:initUI()
    self.mFightZhenshouId = PlayerAttrObj:getPlayerAttrByName("FightZhenshouId")

    ZhenshouSlotObj:getSlotInfo(function(slotInfo)
  		self.mSlotInfo = slotInfo.CombatStr
  		self.mOpenedNum = slotInfo.SlotNum

		self:createTopView()
	    self:createOptBtns()
	    self:createSliderView()

        -- 执行新手引导
        Utility.performWithDelay(self, function ( ... )
            -- 添加已上阵珍兽容错
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10064 and self.mSlotInfo[1].ZhenShouId ~= EMPTY_ENTITY_ID then
                -- 跳过两步
                Guide.manager:nextStep(10064, false)
                Guide.manager:nextStep(10065, true)
                self:executeGuide()
            else
                self:executeGuide()
            end
        end, 0.01)
  	end)
end

function ZhenshouMainLayer:initUI()
	-- 背景图片
	local bgLayer = ui.newSprite("zs_01.png")
	bgLayer:setAnchorPoint(cc.p(0.5, 1))
	bgLayer:setPosition(320, 1136)
	self.mParentLayer:addChild(bgLayer)	

	-- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(594, 950)
	self.mParentLayer:addChild(self.mCloseBtn, 1)

	-- 规则按钮
	local ruleBtn = ui.newButton({
		normalImage = "c_72.png",
		clickAction = function()
			MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.85级开启珍兽系统"),
                [2] = TR("2.珍兽可以上阵后，该珍兽的所有属性会附加到全体上阵侠客。"),
                [3] = TR("3.珍兽升级可以提升属性，升星可以提升技能强度并且获得新天赋。"),
                [4] = TR("4.上阵的珍兽中可以设置一个出战，出战的珍兽可以在战斗中释放技能。"),
        	})
		end
	})
	ruleBtn:setPosition(55, 950)
	self.mParentLayer:addChild(ruleBtn, 1)

	-- 获取途径按钮
	self.mGetWayBtn = ui.newButton({
		normalImage = "zs_03.png",
		clickAction = function()
			if self.mSlotInfo[self.mSelectIndex].ZhenShouId ~= EMPTY_ENTITY_ID then
				local zhenshouInfo = ZhenshouObj:getZhenshou(self.mSlotInfo[self.mSelectIndex].ZhenShouId)
	    		local zhenshouModel = ZhenshouModel.items[zhenshouInfo.ModelId]
				LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = Utility.getTypeByModelId(zhenshouModel.modelId),
		                modelId = zhenshouModel.modelId,
		            },
		            cleanUp = false,
		        })
			end
		end
	})
	self.mGetWayBtn:setPosition(580, 615)
	self.mParentLayer:addChild(self.mGetWayBtn, 1)
	-- self.mGetWayBtn:setVisible(false)

	local bottomBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 555))
	bottomBgSprite:setAnchorPoint(0.5, 0)
	bottomBgSprite:setPosition(320, 0)
	self.mParentLayer:addChild(bottomBgSprite)

	local emptyLabel = ui.newLabel({
    		text = TR("请 先 上 阵 珍 兽"),
    		color = Enums.Color.eRed,
    		size = 34,
    		outlineColor = Enums.Color.eOutlineColor,
    		})
    	emptyLabel:setPosition(320, 270)
	self.mParentLayer:addChild(emptyLabel)
	self.mEmptyLabel = emptyLabel

	local bagBtn = ui.newButton({
		normalImage = "zs_05.png",
		clickAction = function()
			LayerManager.addLayer({
				name = "zhenshou.ZhenshouBagLayer",
				-- data = {}
			})
		end
		})
	bagBtn:setPosition(65, 670)
	self.mParentLayer:addChild(bagBtn, 1)

 	local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eZhenshou, "ZhenshouCompose")
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshou, "ZhenshouCompose"), parent = bagBtn})

	local changeBtn = ui.newButton({
		normalImage = "zs_02.png",
		clickAction = function()
			LayerManager.addLayer({
    			name = "zhenshou.ZhenshouSelectLayer",
    			data = {slotId = self.mSelectIndex}
			})
		end
		})
	changeBtn:setPosition(475, 615)
	self.mParentLayer:addChild(changeBtn, 1)
	self.mChangeBtn = changeBtn

    --出战按钮
    local fightBtn = ui.newButton({
        normalImage = "zs_06.png",
        clickAction = function()
            local zhenShouId = self.mSlotInfo[self.mSelectIndex].ZhenShouId
            self:requestChooseFight(zhenShouId)
        end
        })
    fightBtn:setPosition(580, 715)
    self.mParentLayer:addChild(fightBtn, 1)
    self.mFightBtn = fightBtn
    --已出战提示
    local fightTipSprite = ui.newSprite("zs_07.png")
    fightTipSprite:setPosition(580, 715)
    self.mParentLayer:addChild(fightTipSprite, 1)
    self.mFightTipSprite = fightTipSprite

	 --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eZhenshouExp, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    self:createReddotView()
end

--创建顶部
function ZhenshouMainLayer:createTopView()
	local topBgSprite = ui.newSprite("c_01.png")
	topBgSprite:setPosition(320, 1030)
	self.mParentLayer:addChild(topBgSprite)

	local arrowR = ui.newSprite("c_26.png")
	arrowR:setPosition(610, 70)
	topBgSprite:addChild(arrowR)

	local arrowL = ui.newSprite("c_26.png")
	arrowL:setPosition(30, 70)
	arrowL:setRotation(180)
	topBgSprite:addChild(arrowL)

	local slotListView = ccui.ListView:create()
    slotListView:setDirection(ccui.ListViewDirection.horizontal)
    slotListView:setBounceEnabled(true)
    slotListView:setAnchorPoint(cc.p(0.5, 0.5))
    slotListView:setPosition(320, 65)
    slotListView:setContentSize(cc.size(540, 120))
    topBgSprite:addChild(slotListView)

    self.mSlotListView = slotListView

	local slotMaxNum = ZhenshouSlotModel.items_count

	for i = 1, slotMaxNum do
		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(110, 110))

		local tempCard = CardNode.createCardNode({})
		tempCard:setPosition(60, 60)
		layout:addChild(tempCard)
		table.insert(self.mTopSlotList, tempCard)

		local shenxingReddotNode = cc.Node:create()
		shenxingReddotNode:setContentSize(110, 110)
		layout:addChild(shenxingReddotNode)

		local subKeyId = "StepUpInfo" .. i
    	local function dealRedDotVisible(redDotSprite)
    	    local redDotData = RedDotInfoObj:isValid(ModuleSub.eZhenshou, subKeyId)
    	    redDotSprite:setVisible(redDotData)
    	end
    	ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = shenxingReddotNode,
    		eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshou, subKeyId)})

		slotListView:pushBackCustomItem(layout)

		local subKeyId = "LvUpInfo" .. i
    	local function dealRedDotVisible(redDotSprite)
    	    local redDotData = RedDotInfoObj:isValid(ModuleSub.eZhenshou, subKeyId)
    	    redDotSprite:setVisible(redDotData)
    	end
    	ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = layout,
    		eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshou, subKeyId)})
	end
	self:refreshTopList()
end

--创建操作按钮
function ZhenshouMainLayer:createOptBtns()
	local tabBtns = {
		[1] = {
			text = TR("升级"),
			tag = 1,
		},
		[2] = {
			text = TR("升星"),
			tag = 2,
		},
		[3] = {
			text = TR("详情"),
			tag = 3,
		},
	}
	local tabView = ui.newTabLayer({
		btnInfos = tabBtns,
		-- needLine = false,
		onSelectChange = function(tag)
			self.mBottomTag = tag
			self:refreshBottom()
		end
	})
	tabView:setPosition(320, 580)
	self.mParentLayer:addChild(tabView)
end

--创建滑动控件
function ZhenshouMainLayer:createSliderView()
    local nameNode, nameLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        bgSize = cc.size(240, 50),
        labelStr = "",
        alignType = ui.TEXT_ALIGN_CENTER,
        outlineColor = Enums.Color.eOutlineColor,
	})
	nameNode:setPosition(320, 620)
	self.mParentLayer:addChild(nameNode)
	self.mNameNode = nameNode
	self.mNameLabel = nameLabel

	local starLabel = ui.newZhenshouStar(1)
	starLabel:setPosition(320, 655)
	self.mParentLayer:addChild(starLabel, 1)
	self.mStarLabel = starLabel

	-- 创建人物列表
    local slider = ui.newSliderTableView({
        width = 640,
        height = 400,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = defaultSelectIndex,
        itemCountOfSlider = function(sliderView)
            return self.mOpenedNum
        end,
        itemSizeOfSlider = function(sliderView)
            return 640, 400
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local slotInfo = self.mSlotInfo[index+1]
        	if slotInfo.ZhenShouId == EMPTY_ENTITY_ID then
	            local tempSprite = ui.createGlitterSprite({
	            	filename = "c_22.png",
	            	actionScale = 1.5,
	            	})
	            tempSprite:setPosition(320, 200)
	            itemNode:addChild(tempSprite)

	            local pureBtn = ui.newButton({
	            	normalImage = "c_83.png",
	            	size = cc.size(380, 300),
	            	clickAction = function()
	            		LayerManager.addLayer({
	            			name = "zhenshou.ZhenshouSelectLayer",
	            			data = {slotId = self.mSelectIndex}
            			})
	            	end
	            	})
	            pureBtn:setPosition(320, 200)
	            itemNode:addChild(pureBtn)
                if index+1 == 1 then
                    self.mAddBtn = pureBtn
                end
	        else
	        	local zhenshouFigure = Figure.newZhenshou({
	        		zhenshouId = slotInfo.ZhenShouId,
	        		clickCallback = function()
	        			LayerManager.addLayer({
                           name = "zhenshou.ZhenshouInfoLayer",
                           data = {
                              zhenshouId = slotInfo.ZhenShouId,
                           },
                       })
	        		end
	        		})
	        	zhenshouFigure:setPosition(320, 260)
	            itemNode:addChild(zhenshouFigure)
	        end
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	self.mSelectIndex = selectIndex + 1
        	self:refreshDataView(true)
        end
    })
    slider:setPosition(320, 800)
    self.mParentLayer:addChild(slider)
    self.mSliderView = slider

    self:refreshDataView()
end

--升级界面展示
function ZhenshouMainLayer:createLvUpView()
	self.mLvUpNode:removeAllChildren()
	self.mLvUpNode:setVisible(true)

	if self.mSlotInfo[self.mSelectIndex].ZhenShouId == EMPTY_ENTITY_ID then
		return
	end
	local zhenshouInfo = ZhenshouObj:getZhenshou(self.mSlotInfo[self.mSelectIndex].ZhenShouId)
    local zhenshouModel = ZhenshouModel.items[zhenshouInfo.ModelId]
    
    --获取当前等级的属性加成和下一阶属性加成
    local function getLvAttr(zhenshouInfo)
    	local curModel = ZhenshouLvupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Lv]
    	local nextModel = ZhenshouLvupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Lv+1]
        local zhenshouLvList = table.keys(ZhenshouLvupModel.items[zhenshouInfo.ModelId])
        table.sort(zhenshouLvList, function(lv1, lv2)
            return lv1 < lv2
        end)
    	local curAttr = {}
    	local nextAttr = {}

    	local curAddAttr = {}
        for i = 1, table.indexof(zhenshouLvList, zhenshouInfo.Lv) do
            local lvModel = ZhenshouLvupModel.items[zhenshouInfo.ModelId][zhenshouLvList[i]]
            local attrList = Utility.analysisStrAttrList(lvModel.addAttrStr)
            for _, attrInfo in pairs(attrList) do
                if curAddAttr[attrInfo.fightattr] then
                    curAddAttr[attrInfo.fightattr].value = curAddAttr[attrInfo.fightattr].value + attrInfo.value
                else
                    curAddAttr[attrInfo.fightattr] = attrInfo
                end
            end
        end
        curAddAttr = table.values(curAddAttr)

    	for i,v in ipairs(curAddAttr) do
            local nameStr = FightattrName[v.fightattr]
            local attrStr = Utility.getAttrViewStr(v.fightattr, v.value, true)
    		local tempStr = TR("全体%s : #d17b00%s", nameStr, attrStr)
    		table.insert(curAttr, tempStr)
    	end
    	if curModel.baseDamageAdd ~= 0 then
    		local baseDamageStr = TR("珍兽伤害 ：#d17b00+%s", curModel.baseDamageAdd)
    		table.insert(curAttr, baseDamageStr)
    	end
    	if nextModel then
    		local nextAddAttr = {}
            for i = 1, table.indexof(zhenshouLvList, zhenshouInfo.Lv+1) do
            local lvModel = ZhenshouLvupModel.items[zhenshouInfo.ModelId][zhenshouLvList[i]]
            local attrList = Utility.analysisStrAttrList(lvModel.addAttrStr)
            for _, attrInfo in pairs(attrList) do
                if nextAddAttr[attrInfo.fightattr] then
                    nextAddAttr[attrInfo.fightattr].value = nextAddAttr[attrInfo.fightattr].value + attrInfo.value
                else
                    nextAddAttr[attrInfo.fightattr] = attrInfo
                end
            end
        end
        nextAddAttr = table.values(nextAddAttr)

	    	for i,v in ipairs(nextAddAttr) do
                local nameStr = FightattrName[v.fightattr]
                local attrStr = Utility.getAttrViewStr(v.fightattr, v.value, true)
	    		local tempStr = TR("全体%s : #258711%s", nameStr, attrStr)
	    		table.insert(nextAttr, tempStr)
	    	end
	    	if nextModel.baseDamageAdd ~= 0 then
	    		local baseDamageStr = TR("珍兽伤害 ：#258711+%s", nextModel.baseDamageAdd)
	    		table.insert(nextAttr, baseDamageStr)
	    	end
	    end

    	return curAttr, nextAttr
    end

    --判断当前是否可以升级
    local function isMaxLv()
    	local curMaxLv = ZhenshouLvstepMatchModel.items[zhenshouModel.quality][zhenshouInfo.Step].maxLv

    	if zhenshouInfo.Lv >= curMaxLv then
    		return true
    	else
    		return false
    	end
    end 

    local curAttr, nextAttr = getLvAttr(zhenshouInfo)
    local isMaxLv = isMaxLv()

    local nextLv = next(nextAttr) == nil and "??" or zhenshouInfo.Lv+1
	-- 属性信息背景框
    local tempBgSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 250))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 475)
    self.mLvUpNode:addChild(tempBgSprite)

    -- 等级信息背景框
    _, self.currLvLabel = ui.newNodeBgWithTitle(self.mLvUpNode, cc.size(250, 220), TR("当前等级 #d17b00%s", zhenshouInfo.Lv), cc.p(150, 465), cc.p(0.5, 1))
    _, self.nextLvLabel = ui.newNodeBgWithTitle(self.mLvUpNode, cc.size(250, 220), TR("下一级 #37ff40%s", nextLv), cc.p(490, 465), cc.p(0.5, 1))

    -- 箭头
    local sprite = ui.newSprite("c_67.png")
    sprite:setPosition(315, 355)
    self.mLvUpNode:addChild(sprite)

    local tempLabel = ui.newLabel({
		text = TR("当前等级上限：%s", ZhenshouLvstepMatchModel.items[zhenshouModel.quality][zhenshouInfo.Step].maxLv),
		color = Enums.Color.eBlack,
		-- outlineColor = Enums.Color.eOutlineColor,
		})
	tempLabel:setAnchorPoint(0, 0.5)
	tempLabel:setPosition(30, 495)
	self.mLvUpNode:addChild(tempLabel, 1)

    local costInfo = Utility.analysisStrResList(ZhenshouLvupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Lv].lvupNeedStr)
    local function checkCostEnough()
    	for i,v in ipairs(costInfo) do
    		local haveNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
    		if haveNum < v.num then
				LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = v.resourceTypeSub,
		                modelId = v.modelId,
		            },
		            cleanUp = false,
		        })
    			return false
    		end
    	end
    	return true
    end 

    -- 创建"升一次"按钮
    local lvUpBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(480, 140),
        text = TR("升级"),
        clickAction = function()
        	if not isMaxLv then
        		if checkCostEnough() then
            		self:requestLvUp(zhenshouInfo.Id)
            	end
            else
            	ui.showFlashView(TR("已经达到最大等级，请先升星提升最大等级"))
            end
        end
    })
    self.mLvUpNode:addChild(lvUpBtn)

    -- 创建"升十次"按钮
    local onkeyBtn = ui.newButton({
        normalImage = "c_33.png",
        position = cc.p(160, 140),
        text = TR("一键升级"),
        clickAction = function()
        	if not isMaxLv then
        		if checkCostEnough() then
            		self:requestOneKeyLvUp(zhenshouInfo.Id)
            	end
            else
            	ui.showFlashView(TR("已经达到最大等级，请先升星提升最大等级"))
            end
        end
    })
    self.mLvUpNode:addChild(onkeyBtn)


    local startY = 440
    --当前阶属性显示
    for i,v in ipairs(curAttr) do
    	local tempLabel = ui.newLabel({
    		text = v,
    		color = Enums.Color.eBlack,
    		-- outlineColor = Enums.Color.eOutlineColor,
    		})
    	tempLabel:setAnchorPoint(0, 0.5)
    	tempLabel:setPosition(50, startY - i*35)
    	self.mLvUpNode:addChild(tempLabel, 1)
    end

    --下一阶属性显示
    for i,v in ipairs(nextAttr) do
    	local tempLabel = ui.newLabel({
    		text = v,
    		color = Enums.Color.eBlack,
    		-- outlineColor = Enums.Color.eOutlineColor,
    		})
    	tempLabel:setAnchorPoint(0, 0.5)
    	tempLabel:setPosition(390, startY - i*35)
    	self.mLvUpNode:addChild(tempLabel, 1)
    end

    --满级显示
    if next(nextAttr) == nil then
    	local tempLabel = ui.newLabel({
    		text = TR("已满级"),
    		color = Enums.Color.eBlack,
    		-- outlineColor = Enums.Color.eOutlineColor,
    		})
    	tempLabel:setAnchorPoint(0, 0.5)
    	tempLabel:setPosition(460, startY - 85)
    	self.mLvUpNode:addChild(tempLabel, 1)
    end

    if isMaxLv then
    	onkeyBtn:setVisible(false)
    	lvUpBtn:setVisible(false)

    	local tipLabel = ui.newLabel({
	    	text = TR("珍兽已满级，请前往升星"),
	    	color = Enums.Color.eRed,
	    	size = 26,
	    	})
	    tipLabel:setPosition(320, 160)
	    self.mLvUpNode:addChild(tipLabel)
    else
	    --升级消耗
	    local costStr = ""
	    for i,v in ipairs(costInfo) do
	    	local haveNum = Utility.getOwnedGoodsCount(costInfo[i].resourceTypeSub, costInfo[i].modelId)
	    	local color = haveNum >= v.num and "" or Enums.Color.eRedH
	    	local imgStr = string.format("{%s}%s%s", Utility.getDaibiImage(v.resourceTypeSub), color, Utility.numberWithUnit(v.num))
	    	costStr = costStr .. imgStr
	    end
	    local costLabel = ui.newLabel({
	    	text = costStr,
	    	color = Enums.Color.eBlack,
	    	})
	    costLabel:setPosition(480, 190)
	    self.mLvUpNode:addChild(costLabel)
	end
end

--升星界面展示
function ZhenshouMainLayer:createStepUpView()
	self.mStepUpNode:removeAllChildren()
	self.mStepUpNode:setVisible(true)

	if self.mSlotInfo[self.mSelectIndex].ZhenShouId == EMPTY_ENTITY_ID then
		return
	end

	local zhenshouInfo = ZhenshouObj:getZhenshou(self.mSlotInfo[self.mSelectIndex].ZhenShouId)
    local zhenshouModel = ZhenshouModel.items[zhenshouInfo.ModelId]
	
	local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(620, 350))
	bgSprite:setPosition(320, 345)
	self.mStepUpNode:addChild(bgSprite)

	local stepUpListView = ccui.ListView:create()
    stepUpListView:setDirection(ccui.ListViewDirection.vertical)
    stepUpListView:setBounceEnabled(true)
    stepUpListView:setAnchorPoint(cc.p(0.5, 0.5))
    stepUpListView:setPosition(320, 345)
    stepUpListView:setContentSize(cc.size(610, 340))
    self.mStepUpNode:addChild(stepUpListView)

    --整理显示变化的属性
    local function stepUpChangeValue()
    	local curModel = ZhenshouStepupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Step]
    	local nextModel = ZhenshouStepupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Step+1]
    	local curValue = {}
    	local nextValue = {}

    	local stepNum = TR("升星等级：#d17b00%s", zhenshouInfo.Step)
    	table.insert(curValue, stepNum)
    	local baseAtkFactorC = TR("普攻伤害：#d17b00+%s%%", curModel.baseAtkFactor/10) 
    	table.insert(curValue, baseAtkFactorC)
    	local skillAtkFactorC = TR("技攻伤害：#d17b00+%s%%", curModel.skillAtkFactor/10) 
    	table.insert(curValue, skillAtkFactorC)
    	local skillOddsRC = TR("技能释放概率：#d17b00%s%%", curModel.skillOddsR/100)  
    	table.insert(curValue, skillOddsRC)

    	if nextModel then
    		local stepNum = TR("#258711%s", zhenshouInfo.Step+1)
			table.insert(nextValue, stepNum)
	    	local baseAtkFactorN = TR("#258711+%s%%", nextModel.baseAtkFactor/10) 
	    	table.insert(nextValue, baseAtkFactorN)
	    	local skillAtkFactorN = TR("#258711+%s%%", nextModel.skillAtkFactor/10) 
	    	table.insert(nextValue, skillAtkFactorN)
	    	local skillOddsRN = TR("#258711%s%%", nextModel.skillOddsR/100)  
	    	table.insert(nextValue, skillOddsRN)
	    end

	    return curValue, nextValue
    end

    --整理直接获取的属性
    local function stepUpAtrr()
    	local nextModel = ZhenshouStepupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Step+1]
    	if not nextModel then
    		local addAttr = TR("无")
            local skillBuff = TR("无")
    		return addAttr, skillBuff
    	end

    	local nextAddAttr = Utility.analyzeAttrAddString(nextModel.addAttrStr)

    	local addAttr = ""
    	for i,v in ipairs(nextAddAttr) do
    		local tempStr = TR("全体%s +%s", v.name, v.value)
    		if i < #nextAddAttr then
    			tempStr = tempStr.."；"
    		end
    		addAttr = addAttr..tempStr
    	end
        local zsLvModel = ZhenshouLvupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Lv+1]
        -- 技攻
        local atkStr = (nextModel.skillAtkFactor/10).."%"
        atkStr = atkStr .. "+" .. math.ceil(zsLvModel.baseDamageAdd*nextModel.skillAtkAddR/10000)
        specialIntro = string.format(nextModel.skillAtkIntro, atkStr)
        if nextModel.skillAtkEffectBuffID ~= "" then
            specialIntro = specialIntro .. "，" .. nextModel.skillAtkEffectIntro
        end
        -- 触发概率
        specialIntro = specialIntro .. TR("%s（%s星激活）", Enums.Color.eRedH, zhenshouInfo.Step+1)

    	return addAttr, specialIntro
    end

    local curValue, nextValue = stepUpChangeValue()
    local attrStr, skillBuff = stepUpAtrr()
    --创建升星详情
    local function stepUpAttrView()
    	local layout = ccui.Layout:create()
    	layout:setContentSize(610, 270)
    	local bgSprite = ui.newScale9Sprite("c_54.png", cc.size(610, 270))
    	bgSprite:setPosition(305, 135)
    	layout:addChild(bgSprite)

    	local titleLable = ui.newLabel({
    		text = TR("升星详情"),
    		size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x72, 0x25, 0x13),
            outlineSize = 2,
		})
		titleLable:setPosition(305, 250)
		layout:addChild(titleLable)

    	local startY = 240
    	for i,v in ipairs(curValue) do
    		local tempLabel = ui.newLabel({
	    		text = v,
	    		color = Enums.Color.eBlack,
	    		size = 20,
	    		-- outlineColor = Enums.Color.eOutlineColor,
	    		})
	    	tempLabel:setAnchorPoint(0, 0.5)
	    	tempLabel:setPosition(30, startY - i*25)
	    	layout:addChild(tempLabel)
    	end

        local skillBuffLabel = ui.newLabel({
            text = TR("{c_63.png}技能强化：%s", skillBuff),
            color = cc.c3b(0xd1, 0x7b, 0x00),
            size = 20,
            dimensions = cc.size(550, 0)
            -- outlineColor = Enums.Color.eOutlineColor,
            })
        skillBuffLabel:setAnchorPoint(0, 0.5)
        skillBuffLabel:setPosition(30, 90)
        layout:addChild(skillBuffLabel)

    	local getAttrLabel = ui.newLabel({
    		text = TR("{c_63.png}新天赋：%s", attrStr),
    		color = cc.c3b(0xd1, 0x7b, 0x00),
    		size = 20,
    		-- outlineColor = Enums.Color.eOutlineColor,
    		})
    	getAttrLabel:setAnchorPoint(0, 0.5)
    	getAttrLabel:setPosition(30, 30)
    	layout:addChild(getAttrLabel)

    	if next(nextValue) ~= nil then
	    	for i,v in ipairs(nextValue) do
	    		local tempLabel = ui.newLabel({
		    		text = v,
		    		color = Enums.Color.eBlack,
		    		size = 20,
		    		-- outlineColor = Enums.Color.eOutlineColor,
		    		})
		    	tempLabel:setAnchorPoint(0, 0.5)
		    	tempLabel:setPosition(470, startY - i*25)
		    	layout:addChild(tempLabel)
	    	end

	    	-- 箭头
		    local sprite = ui.newSprite("c_67.png")
		    sprite:setPosition(305, 180)
		    layout:addChild(sprite)
		else
			local tempLabel = ui.newLabel({
	    		text = TR("已满星"),
	    		color = Enums.Color.eBlack,
	    		-- outlineColor = Enums.Color.eOutlineColor,
	    		})
	    	tempLabel:setAnchorPoint(0, 0.5)
	    	tempLabel:setPosition(450, startY - 65)
	    	layout:addChild(tempLabel, 1)
		end

	    stepUpListView:pushBackCustomItem(layout)
    end

    --手动筛选可以被消耗升星的珍兽
    local function selectCostId(targetModelId, num)
    	local selectList = ZhenshouObj:getZhenshouList({isResolve = true})
    	local idList = {}
    	for i,v in ipairs(selectList) do
    		local hadNum = #idList
    		if hadNum >= num then
    			break
    		end
    		if v.ModelId == targetModelId then
    			table.insert(idList, v.Id)
    		end
    	end
    	return idList
    end

    -- 是否达到升星等级
    local function canStepUp()
        local quality = ZhenshouModel.items[zhenshouInfo.ModelId].quality
        local curMaxLv = ZhenshouLvstepMatchModel.items[quality][zhenshouInfo.Step].maxLv

        if zhenshouInfo.Lv >= curMaxLv then
            return true
        else
            return false
        end
    end

    -- 消耗材料类型
    local USEZHENSHOU = 1   -- 消耗珍兽
    local USEMEDICINE = 2   -- 消耗丹
    self.mSelectUseType = self.mSelectUseType or USEZHENSHOU    -- 选择消耗类型
    self.mUseResList = {}   -- 消耗列表
    --创建升星消耗
    local function stepUpCostView()
    	if zhenshouInfo.Step >= #ZhenshouStepupModel.items[zhenshouInfo.ModelId] then
    		return
    	end
        -- 相同基础消耗
        local curModel = ZhenshouStepupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Step]
        local costStr = Utility.analysisStrResList(curModel.stepUpNeedStr)
        -- 消耗同名卡
        local tempSameItem = {
            resourceTypeSub = ResourcetypeSub.eZhenshou,
            modelId = zhenshouInfo.ModelId,
            num = curModel.stepUpNeedZhenShouNum
        }
        self.mUseResList[USEZHENSHOU] = clone(costStr)
        table.insert(self.mUseResList[USEZHENSHOU], tempSameItem)
        -- 消耗丹药
        local replaceStr = ZhenshouModel.items[zhenshouInfo.ModelId].replaceStr
        if replaceStr ~= "" then
            self.mUseResList[USEMEDICINE] = clone(costStr)
            local medicineInfoList = Utility.analysisStrResList(replaceStr)
            for _, medicineInfo in pairs(medicineInfoList) do
                medicineInfo.num = medicineInfo.num*curModel.stepUpNeedZhenShouNum
                table.insert(self.mUseResList[USEMEDICINE], medicineInfo)
            end
        end
        -- 添加点击函数
        for useType, costList in pairs(self.mUseResList) do
            local isCanUseMedicine = self.mUseResList[USEMEDICINE] and true or false
        	for i,v in ipairs(costList) do
        		v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eSelected}
        		v.onClickCallback = function()
                    -- 有替代材料
                    if isCanUseMedicine then
                        -- 已选中
                        if self.mSelectUseType == useType then
                            LayerManager.addLayer({
                                name = "hero.DropWayLayer",
                                data = {
                                    resourceTypeSub = v.resourceTypeSub,
                                    modelId = v.modelId
                                },
                                cleanUp = false,
                            })
                        else
                            local beforeUseType = self.mSelectUseType
                            self.mSelectUseType = useType
                            -- 更新选择框显示
                            for _, selectSprite in pairs(self.mSeleSpriteList[beforeUseType]) do
                                selectSprite:setVisible(false)
                            end
                            for _, selectSprite in pairs(self.mSeleSpriteList[self.mSelectUseType]) do
                                selectSprite:setVisible(true)
                            end
                        end
                    -- 没替代材料
                    else
            			LayerManager.addLayer({
            				name = "hero.DropWayLayer",
            				data = {
            					resourceTypeSub = v.resourceTypeSub,
            					modelId = v.modelId
            				},
            				cleanUp = false,
        				})
                    end
        		end
        	end
        end
        -- 创建消耗显示函数
        self.mSeleSpriteList = {}   -- 选择框列表
        local function createCardList(cardListSize, pos, useType)
            local resList = self.mUseResList[useType]
            if not resList or not next(resList) then return end

            local cardList = ui.createCardList({
                    maxViewWidth = cardListSize.width,
                    viewHeight = cardListSize.height, 
                    cardDataList = resList,
                })
            cardList:setAnchorPoint(0.5, 0.5)
            cardList:setPosition(pos)

            local cards = cardList.getCardNodeList()
            for i,v in ipairs(cards) do
                -- 数字label
                local haveNum = Utility.getOwnedGoodsCount(resList[i].resourceTypeSub, resList[i].modelId, true)
                local color = haveNum >= resList[i].num and Enums.Color.eGreenH or Enums.Color.eRedH
                v.mShowAttrControl[CardShowAttr.eNum].label:setString(string.format("%s%s/%s", color, haveNum, resList[i].num))
                -- 选择框
                if self.mUseResList[USEMEDICINE] then
                    v.mShowAttrControl[CardShowAttr.eSelected].sprite:setVisible(useType == self.mSelectUseType)
                    self.mSeleSpriteList[useType] = self.mSeleSpriteList[useType] or {}
                    table.insert(self.mSeleSpriteList[useType], v.mShowAttrControl[CardShowAttr.eSelected].sprite)
                else
                    v.mShowAttrControl[CardShowAttr.eSelected].sprite:setVisible(false)
                end
            end

            return cardList
        end

    	local layout = ccui.Layout:create()
    	layout:setContentSize(610, 160)
        stepUpListView:pushBackCustomItem(layout)

    	local bgSprite = ui.newScale9Sprite("c_54.png", cc.size(610, 160))
    	bgSprite:setPosition(305, 70)
    	layout:addChild(bgSprite)

    	local titleLable = ui.newLabel({
    		text = TR("升星消耗"),
    		size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x72, 0x25, 0x13),
            outlineSize = 2,
		})
		titleLable:setPosition(305, 130)
		layout:addChild(titleLable)

        local isCanUseMedicine = self.mUseResList[USEMEDICINE] and true or false
        -- 有替代消耗材料
        if isCanUseMedicine then
            -- 珍兽同名卡消耗显示
            local cardList = createCardList(cc.size(270, 130), cc.p(150, 40), USEZHENSHOU)
            layout:addChild(cardList)
            -- 替代消耗材料显示
            local cardList = createCardList(cc.size(270, 130), cc.p(460, 40), USEMEDICINE)
            layout:addChild(cardList)
            -- 或
            local orLabel = ui.newLabel({
                    text = TR("或"),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 30,
                })
            orLabel:setPosition(305, 60)
            layout:addChild(orLabel)
        else
            -- 珍兽同名卡消耗显示
            local cardList = createCardList(cc.size(340, 120), cc.p(320, 40), USEZHENSHOU)
            layout:addChild(cardList)
        end
    end

    -- 升星消耗是否足够
    local function checkCostEnough()
		for i,v in ipairs(self.mUseResList[self.mSelectUseType]) do
			local haveNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
			if haveNum < v.num then
					LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = v.resourceTypeSub,
		                modelId = v.modelId,
		            },
		            cleanUp = false,
		        })
				return false
			end
		end
		return true
	end

    -- 创建显示layout
    stepUpAttrView()
    stepUpCostView() 

    -- 创建升星按钮
    if next(nextValue) ~= nil then
    	local curModel = ZhenshouStepupModel.items[zhenshouInfo.ModelId][zhenshouInfo.Step]
    	if not canStepUp() then
    		local tipLabel = ui.newLabel({
		    	text = TR("珍兽未满级，不能升星"),
		    	color = Enums.Color.eRed,
		    	size = 26,
		    	})
		    tipLabel:setPosition(320, 135)
		    self.mStepUpNode:addChild(tipLabel)
    	else
		    -- 创建"升一次"按钮
		    local button = ui.newButton({
		        normalImage = "c_28.png",
		        position = cc.p(320, 135),
		        text = TR("升星"),
		        clickAction = function()
		        	if canStepUp() then
		        		if checkCostEnough() then
                            if self.mSelectUseType == USEZHENSHOU then  -- 消耗珍兽
    			        		local idList = selectCostId(zhenshouInfo.ModelId, curModel.stepUpNeedZhenShouNum)
                                if not idList or #idList < curModel.stepUpNeedZhenShouNum then
                                    ui.showFlashView(TR("有培养过的珍兽，请先重生"))
                                    return
                                end
    			            	self:requestStepUp(zhenshouInfo.Id, idList, false)
                            else    -- 消耗替代材料
                                self:requestStepUp(zhenshouInfo.Id, {}, true)
                            end
			            end
		            else
		            	ui.showFlashView(TR("需要达到最大等级才能升星，请先提升珍兽等级"))
		            end
		        end
		    })
		    self.mStepUpNode:addChild(button)
		    --铜币消耗
		    local costCoinStr = Utility.analysisStrResList(curModel.stepUpNeedCoin) 
		    local haveNum = Utility.getOwnedGoodsCount(costCoinStr[1].resourceTypeSub, costCoinStr[1].modelId)
		    local color = haveNum >= costCoinStr[1].num and "" or Enums.Color.eRedH
		    local costCoinLabel = ui.newLabel({
		    	text = string.format("{%s}%s%s", Utility.getDaibiImage(costCoinStr[1].resourceTypeSub), color, Utility.numberWithUnit(costCoinStr[1].num)),
		    	color = Enums.Color.eBlack,
		    	})
		    costCoinLabel:setAnchorPoint(0, 0.5)
		    costCoinLabel:setPosition(400, 135)
		    self.mStepUpNode:addChild(costCoinLabel)
		end
	else
		--满星显示
		local maxStarSprite = ui.newSprite("zb_25.png")
		maxStarSprite:setPosition(320, 135)
		self.mStepUpNode:addChild(maxStarSprite)
	end
end

--详情界面展示
function ZhenshouMainLayer:createInfoView()
	self.mInfoNode:removeAllChildren()
	self.mInfoNode:setVisible(true)

	if self.mSlotInfo[self.mSelectIndex].ZhenShouId == EMPTY_ENTITY_ID then
		return
	end

	local infoView = require("zhenshou.ZhenshouInfoLayer").createZhenshouDetail({
		parent = self.mInfoNode,
		size = cc.size(620, 420),
		zhenshouId = self.mSlotInfo[self.mSelectIndex].ZhenShouId
	})
	infoView:setPosition(320, 520)
end

--刷新顶部列表
function ZhenshouMainLayer:refreshTopList()
	for i, tempCard in ipairs(self.mTopSlotList) do
		if self.mSlotInfo[i] then
			if self.mSlotInfo[i].ZhenShouId == EMPTY_ENTITY_ID then
				tempCard:setEmpty({CardShowAttr.eSelected}, "c_04.png")
				tempCard:showGlitterAddMark()
				tempCard:setClickCallback(function()
					self.mSelectIndex = i
					self:refreshDataView()
					LayerManager.addLayer({
            			name = "zhenshou.ZhenshouSelectLayer",
            			data = {slotId = self.mSelectIndex}
        			})
				end)
				tempCard:setGray(false)
			else
				local zhenshouInfo = ZhenshouObj:getZhenshou(self.mSlotInfo[i].ZhenShouId)
				local attr = {
					CardShowAttr.eBorder,
					CardShowAttr.eSelected,
					CardShowAttr.eLevel,
					CardShowAttr.eStep,
				}
				tempCard:setZhenshou(zhenshouInfo, attr)
				tempCard:setClickCallback(function()
					if i == self.mSelectIndex then
						return
					end
					self.mSelectIndex = i
					self:refreshDataView()
				end)
			end
		else
			local tempSlotModel = ZhenshouSlotModel.items[i]
			tempCard:setEmpty({CardShowAttr.eSelected}, "c_04.png")
			tempCard:setClickCallback(function()
				local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
				if currLv >= tempSlotModel.needLv then
					if self.mOpenedNum + 1 == i then
						self:openSlotMsgBox(tempSlotModel.needStr, self.mOpenedNum + 1)
					else
						ui.showFlashView(TR("请先开启前面的槽位"))
					end
				else
					ui.showFlashView(TR("槽位开启等级不足"))
				end
			end)

			local tipLabel = ui.newLabel({
				text = TR("%s级开启", tempSlotModel.needLv),
				dimensions = cc.size(50, 0),
				outlineColor = Enums.Color.eOutlineColor,
			})
			tipLabel:setPosition(50, 50)
			tempCard:addChild(tipLabel)
			tempCard:setGray(true)
		end
	end
end

--选中刷新
function ZhenshouMainLayer:refreshDataView(isSlider)
	for i, tempCard in ipairs(self.mTopSlotList) do
		tempCard.mShowAttrControl[CardShowAttr.eSelected].sprite:setVisible(i == self.mSelectIndex)
	end
	--通过滑动刷新界面时不调用滑动函数
	if not isSlider then
		self.mSliderView:setSelectItemIndex(self.mSelectIndex-1)
	end
	self.mChangeBtn:setVisible(self.mSlotInfo[self.mSelectIndex].ZhenShouId ~= EMPTY_ENTITY_ID)
	self.mGetWayBtn:setVisible(self.mSlotInfo[self.mSelectIndex].ZhenShouId ~= EMPTY_ENTITY_ID)
	self.mEmptyLabel:setVisible(self.mSlotInfo[self.mSelectIndex].ZhenShouId == EMPTY_ENTITY_ID)

    if self.mSlotInfo[self.mSelectIndex].ZhenShouId ~= EMPTY_ENTITY_ID then
        self.mFightTipSprite:setVisible(self.mFightZhenshouId == self.mSlotInfo[self.mSelectIndex].ZhenShouId)
        self.mFightBtn:setVisible(self.mFightZhenshouId ~= self.mSlotInfo[self.mSelectIndex].ZhenShouId)
    else
        self.mFightBtn:setVisible(false)
        self.mFightTipSprite:setVisible(false)
    end

	ui.setListviewItemShow(self.mSlotListView, self.mSelectIndex)

	if self.mSlotInfo[self.mSelectIndex].ZhenShouId ~= EMPTY_ENTITY_ID then
		local zhenshouInfo = ZhenshouObj:getZhenshou(self.mSlotInfo[self.mSelectIndex].ZhenShouId)
	    local zhenshouModel = ZhenshouModel.items[zhenshouInfo.ModelId]
	    local color =  Utility.getQualityColor(zhenshouModel.quality, 2)
	    self.mNameLabel:setString(TR("等级%s %s%s", zhenshouInfo.Lv, color, zhenshouModel.name))
	    self.mStarLabel.setStarLevel(zhenshouInfo.Step)
	    self.mStarLabel:setVisible(true)
	    self.mNameNode:setVisible(true)
	else
		self.mNameLabel:setString("")
		self.mStarLabel:setVisible(false)
	    self.mNameNode:setVisible(false)		
	end
	self:refreshBottom()

	for i,v in ipairs(self.mReddotList) do
		v:setVisible(self.mSelectIndex == i)
	end
end

--刷新底部视图
function ZhenshouMainLayer:refreshBottom()
	self.mLvUpNode:setVisible(false)
	self.mStepUpNode:setVisible(false)
	self.mInfoNode:setVisible(false)
	if self.mBottomTag == 1 then
		self:createLvUpView()
	elseif self.mBottomTag == 2 then
		self:createStepUpView()
	elseif self.mBottomTag == 3 then
		self:createInfoView()
	end
end

--开启卡槽弹窗
function ZhenshouMainLayer:openSlotMsgBox(needStr, openId)
	local needInfo = Utility.analysisStrResList(needStr)
	local msgLayer = MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(500, 350),
        title = TR("开启槽位"),
        closeBtnInfo = {},
        btnInfos = {
        	{
	        	normalImage = "c_28.png",
	        	text = TR("确定"),
	        	clickAction = function(layerObj)
	        		LayerManager.removeLayer(layerObj)
	        		self:requestOpenSlot(openId)
	        	end
        	}
	    },
        DIYUiCallback = function(layerObj, mBgSprite, mBgSize)
        	local grayBg = ui.newScale9Sprite("c_17.png", cc.size(450, 150))
        	grayBg:setPosition(250, 170)
        	mBgSprite:addChild(grayBg)

        	local tipLabel = ui.newLabel({
        		text = TR("是否花费以下物品开启槽位？"),
        		outlineColor = Enums.Color.eOutlineColor,
        		})
        	tipLabel:setPosition(250, 270)
        	mBgSprite:addChild(tipLabel)

        	local cardList = ui.createCardList({
    		 	maxViewWidth = 400,
		        viewHeight = 120, 
		        space = 10, 
		        cardDataList = needInfo,
    		})
    		cardList:setAnchorPoint(0.5, 0.5)
    		cardList:setPosition(250, 170)
    		mBgSprite:addChild(cardList)
    		local cards = cardList.getCardNodeList()
    		for i,v in ipairs(cards) do
    			local haveNum = Utility.getOwnedGoodsCount(needInfo[i].resourceTypeSub, needInfo[i].modelId)
    			local color = haveNum >= needInfo[i].num and Enums.Color.eGreenH or Enums.Color.eRedH
    			v.mShowAttrControl[CardShowAttr.eNum].label:setString(string.format("%s%s/%s", color, haveNum, needInfo[i].num))
    		end
        end,
        notNeedBlack = true
	})
end

function ZhenshouMainLayer:getRestoreData()
	local retData = {
		selectIndex = self.mSelectIndex,
	}

	return retData
end

--创建小红点显示
function ZhenshouMainLayer:createReddotView()
	local slotNum = ZhenshouSlotModel.items_count
	self.mReddotList = {}
	for i = 1, slotNum do
		local tempNode = cc.Node:create()
		self.mParentLayer:addChild(tempNode, 1000)

		local lvSprite = ui.newScale9Sprite("c_83.png",cc.size(110, 50))
		lvSprite:setPosition(70, 574)
		tempNode:addChild(lvSprite)

		local subKeyId = "LvUpInfo" .. i
    	local function dealRedDotVisible(redDotSprite)
    	    local redDotData = RedDotInfoObj:isValid(ModuleSub.eZhenshou, subKeyId)
    	    redDotSprite:setVisible(redDotData)
    	end
    	ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = lvSprite,
    		eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshou, subKeyId)})

		local stepSprite = ui.newScale9Sprite("c_83.png",cc.size(110, 50))
		stepSprite:setPosition(202, 574)
		tempNode:addChild(stepSprite)

		local subKeyId = "StepUpInfo" .. i
    	local function dealRedDotVisible(redDotSprite)
    	    local redDotData = RedDotInfoObj:isValid(ModuleSub.eZhenshou, subKeyId)
    	    redDotSprite:setVisible(redDotData)
    	end
    	ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = stepSprite,
    		eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshou, subKeyId)})

		table.insert(self.mReddotList, tempNode)
	end
end

--===========================================网络请求=========================================
-- 开启卡槽请求
function ZhenshouMainLayer:requestOpenSlot(openId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZhenshouSlot",
        methodName = "OpenSlot",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
          	-- dump(response, "kqkc")
      	  	if not response or response.Status ~= 0 then
                return
            end

          	ZhenshouSlotObj:setZhenshouSlot(response.Value.ZhenShouSlotInfo)
          	self.mSlotInfo = response.Value.ZhenShouSlotInfo.CombatStr
  			self.mOpenedNum = response.Value.ZhenShouSlotInfo.SlotNum
  			self.mSelectIndex = openId

  			self.mSliderView:reloadData()

  			self:refreshTopList()
  			self:refreshDataView()
        end,
    })
end

-- 升级请求
function ZhenshouMainLayer:requestLvUp(zhenshouId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Zhenshou",
        methodName = "LvUp",
        svrMethodData = {zhenshouId},
        callbackNode = self,
        callback = function(response)
          	if not response or response.Status ~= 0 then
                return
            end
          	-- dump(response, "LvUp")
          	ZhenshouObj:modifyZhenshouItem(response.Value.ZhenShouInfo)
          	self:refreshTopList()
  			self:refreshDataView()
            -- 播放特效
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_ruwushengji",
                position = cc.p(320, 650),
                scale = 0.8,
                loop = false,
                zorder = zorder or 1,
            })
        end,
    })
end

-- 一键升级请求
function ZhenshouMainLayer:requestOneKeyLvUp(zhenshouId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Zhenshou",
        methodName = "OneKeyLvUp",
        svrMethodData = {zhenshouId},
        callbackNode = self,
        callback = function(response)
          	if not response or response.Status ~= 0 then
                return
            end
          	-- dump(response, "OneKeyLvUp")
          	ZhenshouObj:modifyZhenshouItem(response.Value.ZhenShouInfo)
          	self:refreshTopList()
  			self:refreshDataView()
            -- 播放特效
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_ruwushengji",
                position = cc.p(320, 650),
                scale = 0.8,
                loop = false,
                zorder = zorder or 1,
            })
        end,
    })
end

-- 升星请求
function ZhenshouMainLayer:requestStepUp(zhenshouId, idList, isUseZhenshou)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Zhenshou",
        methodName = "StepUp",
        svrMethodData = {zhenshouId, idList, isUseZhenshou},
        callbackNode = self,
        callback = function(response)
          	-- dump(response, "StepUp")
      	  	if not response or response.Status ~= 0 then
                return
            end
            ZhenshouObj:modifyZhenshouItem(response.Value.ZhenShouInfo)
            for i,v in ipairs(idList) do
            	ZhenshouObj:deleteZhenshouById(v)
            end
          	self:refreshTopList()
  			self:refreshDataView()
            -- 播放特效
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_ruwutupo",
                position = cc.p(320, 650),
                scale = 0.8,
                loop = false,
                zorder = zorder or 1,
            })
        end,
    })
end

-- 出战请求
function ZhenshouMainLayer:requestChooseFight(zhenshouId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZhenshouSlot",
        methodName = "ChooseFight",
        svrMethodData = {zhenshouId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- ZhenshouObj:modifyZhenshouItem(response.Value.ZhenShouInfo)
            local info = {FightZhenshouId = response.Value.ZhenShouSlotInfo.FightZhenshouId}
            PlayerAttrObj:changeAttr(info)

            self.mFightZhenshouId = response.Value.ZhenShouSlotInfo.FightZhenshouId
            self:refreshDataView()
        end,
    })
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function ZhenshouMainLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向选择珍兽界面
        [10064] = {clickNode = self.mAddBtn},
        -- 指向首页图标
        [10066] = {clickNode = self.mCommonLayer:getNavBtnObj(Enums.MainNav.eHome)},
    })
end

return ZhenshouMainLayer