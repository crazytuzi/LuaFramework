--[[
	文件名：QuenchEatMedicineLayer.lua
	描述：服丹界面
	创建人：yanghongsheng
	创建时间： 2017.12.6
--]]

local QuenchEatMedicineLayer = class("QuenchEatMedicineLayer", function()
	return display.newLayer()
end)

function QuenchEatMedicineLayer:ctor()
	-- 当前角色卡槽Id
	self.curHeroIndex = 1
	-- 药材丹药列表
	self.mPelletList = {}
	-- 初始化丹药列表
	self:refreshData()
    -- 卡槽缓存
    self.slotDataList = {}
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    -- 初始化
    self:initUI()
end

-- 刷新丹药列表
function QuenchEatMedicineLayer:refreshData()
	-- 药材丹药列表
    self.mPelletList = GoodsObj:getQuenchList(true)
    -- 排除药材
    local tempList = {}
    for _, value in pairs(self.mPelletList) do
    	if MedicineAttrRelation.items[value.ModelId] then
    		table.insert(tempList, value)
    	end
    end
    self.mPelletList = tempList
    -- 排序
    table.sort(self.mPelletList, function (item1, item2)
    	local goodsInfo1 = GoodsModel.items[item1.ModelId]
    	local goodsInfo2 = GoodsModel.items[item2.ModelId]

    	if goodsInfo1.quality ~= goodsInfo2.quality then
    		return goodsInfo1.quality < goodsInfo2.quality
    	end

    	return item1.ModelId < item2.ModelId
    end)
    
end

function QuenchEatMedicineLayer:initUI()
	-- 上背景
	local bgLayer = ui.newSprite("zr_18.jpg")
	bgLayer:setAnchorPoint(cc.p(0.5, 1))
	bgLayer:setPosition(320, 1136)
	self.mParentLayer:addChild(bgLayer)

	-- 下背景
	local bgLayer2 = ui.newScale9Sprite("c_19.png", cc.size(640, 568))
	bgLayer2:setAnchorPoint(cc.p(0.5, 0))
	bgLayer2:setPosition(320, 0)
	self.mParentLayer:addChild(bgLayer2)

	-- 创建角色view
	local herosView = self:createHerosView()
	herosView:setAnchorPoint(cc.p(0.5, 1))
	herosView:setPosition(320, 1136)
	self.mParentLayer:addChild(herosView)

	-- 提示滑动箭头
	local leftArrow = ui.newSprite("c_26.png")
	leftArrow:setRotation(180)
	leftArrow:setPosition(20, bgLayer:getContentSize().height*0.5+568)
	self.mParentLayer:addChild(leftArrow)
	self.leftArrow = leftArrow

	local rightArrow = ui.newSprite("c_26.png")
	rightArrow:setPosition(640-20, bgLayer:getContentSize().height*0.5+568)
	self.mParentLayer:addChild(rightArrow)
	self.rightArrow = rightArrow

	-- 创建角色名
	self.heroInfoNode = self:createHeroInfo()
	self.mParentLayer:addChild(self.heroInfoNode)

	-- 提示箭头
	local hintArrow = ui.newSprite("c_43.png")
	hintArrow:setRotation(180)
	hintArrow:setPosition(320, bgLayer2:getContentSize().height-40)
	bgLayer2:addChild(hintArrow)
	self.hintArrow = hintArrow
	-- 提示信息
	local hintLabel = ui.newLabel({
			text = TR("重生不返还已服用的丹药"),
			color = Enums.Color.eRed,
			outlineColor = Enums.Color.eOutlineColor,
		})
	hintLabel:setAnchorPoint(cc.p(0, 0.5))
	hintLabel:setPosition(360, bgLayer2:getContentSize().height-43)
	bgLayer2:addChild(hintLabel)
	self.hintLabel = hintLabel
	-- 创建列表
	self.mMedicineListView = self:createListView()
	self:refreshList()
	-- 创建空提示
	local emptyHint = ui.createEmptyHint(TR("还没有丹药"))
	emptyHint:setPosition(cc.p(320, 350))
	self.mParentLayer:addChild(emptyHint)
	self.emptyHint = emptyHint
	-- 属性加成查看按钮
	local attrLookBtn = ui.newButton({
			normalImage = "cuiti_04.png",
			position = cc.p(590, 610),
			clickAction = function ()
				self:createAttrBox()
			end,
		})
	self.mParentLayer:addChild(attrLookBtn)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
        	LayerManager.setRestoreData("quench.QuenchAlchemyLayer", {})
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    self:refreshHintArrow()
    self:refreshUI()
end

-- 刷新界面
function QuenchEatMedicineLayer:refreshUI()
	if self.mPelletList and next(self.mPelletList) then
		self.hintArrow:setVisible(true)
		self.hintLabel:setVisible(true)
		self.mMedicineListView:setVisible(true)
		self.emptyHint:setVisible(false)
	else
		self.hintArrow:setVisible(false)
		self.hintLabel:setVisible(false)
		self.mMedicineListView:setVisible(false)
		self.emptyHint:setVisible(true)
	end
end

-- 刷新左右箭头
function QuenchEatMedicineLayer:refreshHintArrow()
	if self.slotDataList[self.curHeroIndex-1] then
		self.leftArrow:setVisible(true)
	else
		self.leftArrow:setVisible(false)
	end

	if self.slotDataList[self.curHeroIndex+1] then
		self.rightArrow:setVisible(true)
	else
		self.rightArrow:setVisible(false)
	end
end

-- 创建hero滑窗
function QuenchEatMedicineLayer:createHerosView()
	local bgSize = ui.getImageSize("zr_18.jpg")
	-- hero列表
	self.slotDataList = {}
	for _, slotInfo in pairs(FormationObj:getSlotInfos()) do
		if Utility.isEntityId(slotInfo.HeroId) then
			table.insert(self.slotDataList, slotInfo)
		end
	end

	local figureView = ui.newSliderTableView({
        width = bgSize.width,
        height = bgSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.curHeroIndex-1,
        itemCountOfSlider = function(sliderView)
        	return #self.slotDataList
        end,
        itemSizeOfSlider = function(sliderView)
            return bgSize.width, bgSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local tempSlot = self.slotDataList[index+1]
    		local heroData = HeroObj:getHero(tempSlot.HeroId)
            local tmpFashionId = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
    		local rebornId = nil
    		if heroData and heroData.RebornId and (heroData.RebornId % 1000) > 0 then
    			rebornId = heroData.RebornId
    		end

    		Figure.newHero({
            	parent = itemNode,
            	heroModelID = tempSlot.ModelId,
                fashionModelID = tmpFashionId,
                heroFashionId = heroData.CombatFashionOrder,
                IllusionModelId = heroData and heroData.IllusionModelId,
        		position = cc.p(bgSize.width / 2, 100),
        		scale = 0.3,
        		rebornId = rebornId,
        		async = function (figureNode)
        		end,
        		needRace = true,
        	})
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	self.curHeroIndex = selectIndex+1
			self.heroInfoNode.refresh()
        	self:refreshList()
        	self:refreshHintArrow()
        end
    })
	
	return figureView
end

-- 创建卡槽人物名称、等级、战力等属性
function QuenchEatMedicineLayer:createHeroInfo()
	local heroInfoNode = cc.Node:create()

	-- 创建人物的名字
	local _, _, nameNode = Figure.newNameAndStar({
		parent = heroInfoNode,
		position = cc.p(320, 1120),
		})


	-- 刷新人物信息（名字、战力、星数）
	heroInfoNode.refresh = function()
		local slotInfo = FormationObj:getSlotInfoBySlotId(self.curHeroIndex)
		local haveHero = Utility.isEntityId(slotInfo.HeroId)
		heroInfoNode:setVisible(haveHero)

		if haveHero then
			local heroInfo = HeroObj:getHero(slotInfo.HeroId)
			local tempModel = HeroModel.items[slotInfo.ModelId]
			local strName, tempStep = ConfigFunc:getHeroName(slotInfo.ModelId, {heroStep = heroInfo.Step, IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
			local strText = TR("等级%d  %s%s",
				heroInfo.Lv,
				Utility.getQualityColor(tempModel.quality, 2),
				strName)
			if (tempStep > 0) then
				strText = strText .. Enums.Color.eYellowH .. "  +" .. tempStep
			end
			nameNode:setString(strText)
		end
	end
	heroInfoNode.refresh()

	return heroInfoNode
end

-- 创建丹药列表
function QuenchEatMedicineLayer:createListView()
	local listBgSize = cc.size(620, 400)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setPosition(cc.p(320, 310))
	self.mParentLayer:addChild(listBg)

	local listview = ccui.ListView:create()
    listview:setDirection(ccui.ScrollViewDir.vertical)
    listview:setBounceEnabled(true)
    listview:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-10))
    listview:setItemsMargin(5)
    listview:setSwallowTouches(false)
    listview:setAnchorPoint(cc.p(0.5, 0.5))
    listview:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(listview)

    return listview
end

-- 获取hero吃丹得到的属性加成
function QuenchEatMedicineLayer:getHeroAddAttr(eatList)
	if not eatList or not next(eatList) then return {} end

	local attrStrList = {}
	local allAttrList = {}
	for modelId, num in pairs(eatList) do
		local pelletAttrInfo = MedicineAttrRelation.items[tonumber(modelId)]
		local attrList = Utility.analysisStrAttrList(pelletAttrInfo.perAttr)
		local eatNum = math.floor(num/pelletAttrInfo.needNum)
		local attrString = ""
		for _, attr in pairs(attrList) do
			attr.value = attr.value*eatNum
			if allAttrList[attr.fightattr] then
				allAttrList[attr.fightattr].value = allAttrList[attr.fightattr].value + attr.value
			else
				allAttrList[attr.fightattr] = attr
			end
		end
	end
	-- 排序
	local tempList = {}
	for _, attr in pairs(allAttrList) do
		table.insert(tempList, attr)
	end
	table.sort(tempList, function (attr1, attr2)
		return attr1.fightattr < attr2.fightattr
	end)
	allAttrList = tempList
	
	for _, attr in pairs(allAttrList) do
		local text = FightattrName[attr.fightattr] .. Utility.getAttrViewStr(attr.fightattr, attr.value)
		table.insert(attrStrList, text)
	end

	return attrStrList
end

-- 创建属性加成显示弹窗
function QuenchEatMedicineLayer:createAttrBox()
	local heroInfo = HeroObj:getHero(self.slotDataList[self.curHeroIndex].HeroId)

	local function DIYfunc(boxRoot, bgSprite, bgSize)
        local hintLabel = ui.newLabel({
        		text = TR("已服用的丹药获得以下属性加成"),
        		color = cc.c3b(0x46, 0x22, 0x0d),
        		size = 22,
        	})
        hintLabel:setPosition(bgSize.width*0.5, bgSize.height*0.78)
        bgSprite:addChild(hintLabel)

        local attrBgSize = cc.size(522, 170)
        local attrBgSprite = ui.newScale9Sprite("c_65.png", attrBgSize)
        attrBgSprite:setPosition(bgSize.width*0.5, bgSize.height*0.5)
        bgSprite:addChild(attrBgSprite)

        local attrStrList = self:getHeroAddAttr(heroInfo.MedicineStrInfo)
        if next(attrStrList) then
	        for i, text in ipairs(attrStrList) do
	        	local attrLabel = ui.newLabel({
	        			text = text,
	        			size = 20,
	        			color = cc.c3b(0x46, 0x22, 0x0d),
	        		})
	        	attrLabel:setAnchorPoint(cc.p(0, 0))
	        	local x, y = (i-1)%3, math.floor((i-1)/3)
	        	attrLabel:setPosition(x*170+20, 140-y*30)
	        	attrBgSprite:addChild(attrLabel)
	        end
	    else
	    	local emptyHint = ui.newLabel({
	    			text = TR("暂无任何属性加成"),
	    			color = cc.c3b(0x46, 0x22, 0x0d),
	    			size = 24,
	    		})
	    	emptyHint:setAnchorPoint(cc.p(0.5, 0.5))
	    	emptyHint:setPosition(attrBgSize.width*0.5, attrBgSize.height*0.5)
	    	attrBgSprite:addChild(emptyHint)
	    end
    end

    -- 创建对话框
    local boxSize = cc.size(600, 400)
    self.showOneKeyMaxLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = boxSize,
            title = TR("属性加成"),
            btnInfos = {
                {
                    text = TR("确定"),
                }
            },
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end

-- 刷新丹药列表
function QuenchEatMedicineLayer:refreshList()
	local function createCell(itemData)
		local goodsInfo = GoodsModel.items[itemData.ModelId]
		local heroInfo = HeroObj:getHero(self.slotDataList[self.curHeroIndex].HeroId)
		local attrInfo = MedicineAttrRelation.items[itemData.ModelId]
		local cellSize = cc.size(self.mMedicineListView:getContentSize().width, 140)

		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)

		local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
		bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		layout:addChild(bgSprite)

		local pelletCard = CardNode.createCardNode({instanceData = itemData})
		pelletCard:setPosition(cellSize.width*0.11, cellSize.height*0.55)
		layout:addChild(pelletCard)

		local colorLv = Utility.getQualityColorLv(goodsInfo.quality)
		local eatNum = math.floor((heroInfo.MedicineStrInfo[tostring(itemData.ModelId)] or 0)/attrInfo.needNum)
		local pelletName = ui.newLabel({
				text = string.format("%s  #249029（%d / %d）", goodsInfo.name, eatNum, attrInfo.activationTimes),
				color = Utility.getColorValue(colorLv, 1),
				outlineColor = Enums.Color.eOutlineColor,
			})
		pelletName:setAnchorPoint(cc.p(0, 0.5))
		pelletName:setPosition(cellSize.width*0.21, cellSize.height*0.75)
		layout:addChild(pelletName)

		local attrList = Utility.analysisStrAttrList(attrInfo.perAttr)
		local attrString = ""
		for _, attr in pairs(attrList) do
			attrString = attrString .. FightattrName[attr.fightattr] .. Utility.getAttrViewStr(attr.fightattr, attr.value)
		end
		local attrLabel = ui.newLabel({
				text = TR("每颗丹药效果: %s", attrString),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		attrLabel:setAnchorPoint(cc.p(0, 0.5))
		attrLabel:setPosition(cellSize.width*0.21, cellSize.height*0.4)
		layout:addChild(attrLabel)

		if eatNum < attrInfo.activationTimes then
			local eatBtn = ui.newButton({
					normalImage = "c_28.png",
					text = TR("服用"),
					clickAction = function ()
						if itemData.Num < attrInfo.needNum then
							ui.showFlashView({text = TR("丹药数量不足")})
							return
						end
						local haveNum = math.floor(itemData.Num/attrInfo.needNum)
						local limitNum = attrInfo.activationTimes - eatNum
						local maxNum = haveNum < limitNum and haveNum or limitNum
						if haveNum == 1 and limitNum >=1 then
							self:requestEat(self.slotDataList[self.curHeroIndex].HeroId, itemData.ModelId, haveNum*attrInfo.needNum)
						else
							layout.msgBox = MsgBoxLayer.addUseGoodsCountLayer(TR("服用%s", goodsInfo.name), itemData.ModelId, maxNum, function(selCount)
								self:requestEat(self.slotDataList[self.curHeroIndex].HeroId, itemData.ModelId, selCount*attrInfo.needNum)
								LayerManager.removeLayer(layout.msgBox)
							end)
						end
					end
				})
			eatBtn:setPosition(cellSize.width*0.85, cellSize.height*0.5)
			layout:addChild(eatBtn)
		else
			local limitLabel = ui.createSpriteAndLabel({
                imgName = "c_156.png",
                labelStr = TR("已达上限"),
                fontSize = 24,
            })
	        limitLabel:setPosition(cellSize.width*0.85, cellSize.height*0.5)
	        layout:addChild(limitLabel)
		end

		return layout
	end

	-- 清空列表
	if not self.mMedicineListView then return end
	self.mMedicineListView:removeAllChildren()

	-- 判断是否达到服用上限
	local function isReachLimit(modelId)
		local heroInfo = HeroObj:getHero(self.slotDataList[self.curHeroIndex].HeroId)
		local attrInfo = MedicineAttrRelation.items[modelId]
		local eatNum = math.floor((heroInfo.MedicineStrInfo[tostring(modelId)] or 0)/attrInfo.needNum)
		return eatNum >= attrInfo.activationTimes
	end
	-- 按是否达到服用上限排序
	table.sort(self.mPelletList, function(item1, item2)
		local isItem1 = isReachLimit(item1.ModelId)
		local isItem2 = isReachLimit(item2.ModelId)
		local goodsInfo1 = GoodsModel.items[item1.ModelId]
		local goodsInfo2 = GoodsModel.items[item2.ModelId]

		-- 是否达到上限
		if isItem1 ~= isItem2 then
			return not isItem1
		end

		-- 品质（从低到高）
		if goodsInfo1.quality ~= goodsInfo2.quality then
			return goodsInfo1.quality < goodsInfo2.quality
		end

		return item1.ModelId < item2.ModelId
	end)
	-- 更新列表
	for _, pelletInfo in pairs(self.mPelletList) do
		local item = createCell(pelletInfo)
		self.mMedicineListView:pushBackCustomItem(item)
	end
	-- 跳到列表顶部
	self.mMedicineListView:jumpToTop()
end

--=========================服务器相关============================
-- 吃丹
function QuenchEatMedicineLayer:requestEat(heroId, modelId, num)
		HttpClient:request({
	        moduleName = "QuenchInfo",
	        methodName = "TakeMedicine",
	        svrMethodData = {heroId, modelId, num},
	        callback = function(response)
	            if response and response.Status ~= 0 then
	                return
	            end
	            HeroObj:modifyHeroItem(response.Value)
	            self:refreshData()
	            self:refreshList()
	            self:refreshUI()
	        end
	    })
end

return QuenchEatMedicineLayer