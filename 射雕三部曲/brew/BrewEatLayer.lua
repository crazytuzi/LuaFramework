--[[
	文件名：BrewEatLayer.lua
	描述：喝酒页面
	创建人：yanghongsheng
	创建时间： 2018.5.21
--]]

local BrewEatLayer = class("BrewEatLayer", function()
	return display.newLayer()
end)

--[[
	params:
		cbQualitySelect 	筛选回调
]]

function BrewEatLayer:ctor(params)
	params = params or {}
	self.mCbQualitySelect = params.cbQualitySelect

	-- 当前人物索引
	self.curHeroIndex = 1
	-- 当前选择酒索引
	self.curWineModelId = nil
	-- 记录筛选条件
	self.mQualitySelList = {}

    -- 初始化
    self:initUI()
end

function BrewEatLayer:initUI()
	-- 阵容view
	self:createTeamView()
	-- 创建角色名
	self.heroInfoNode = self:createHeroInfo()
	self:addChild(self.heroInfoNode)
	-- 背景
	local bgSprite = ui.newScale9Sprite("mp_23.png", cc.size(640, 390))
	bgSprite:setAnchorPoint(0.5, 0)
	bgSprite:setPosition(320, 115)
	self:addChild(bgSprite)
	-- 亲密度进度
	self.mIntimacyBar = self:createProgressbar()
	-- 筛选按钮
	local selectBtn = ui.newButton({
			text = TR("筛选"),
			normalImage = "c_33.png",
			clickAction = function ()
				if self.mCbQualitySelect then
					self.mCbQualitySelect({
						refreshCallBack = handler(self, self.refreshWineList),
						boxPosition = cc.p(120, 407),
					})
				end
			end,
		})
	selectBtn:setPosition(103, 387)
	self:addChild(selectBtn)
	-- 酒列表
	self.mWineListView = self:createWineList()
	self:refreshWineList()
	-- 喝酒按钮
	local eatWineBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("喝酒"),
			clickAction = function ()
				self:eatWine()
			end,
		})
	eatWineBtn:setPosition(cc.p(210, 160))
	self:addChild(eatWineBtn)
	-- 喝酒属性
	local attrBtn = ui.newButton({
			normalImage = "hj_3.png",
			clickAction = function ()
				self:createAttrBox()
			end,
		})
	attrBtn:setPosition(571, 535)
	self:addChild(attrBtn)
	-- 重生按钮
	local rebirthBtn = ui.newButton({
			normalImage = "tb_212.png",
			clickAction = function ()
				self:createRebirthBox()
			end,
		})
	rebirthBtn:setPosition(50, 535)
	self:addChild(rebirthBtn)
	self.mRebirthBtn = rebirthBtn
	-- 重生按钮是否可用
	local tempSlot = self.slotDataList[self.curHeroIndex]
	local heroData = HeroObj:getHero(tempSlot.HeroId)
	self.mRebirthBtn:setEnabled(heroData.FavorInfo and next(heroData.FavorInfo) and true or false)
end

function BrewEatLayer:createTeamView()
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
                IllusionModelId = heroData and heroData.IllusionModelId,
                heroFashionId = heroData and heroData.CombatFashionOrder,
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
			self.mIntimacyBar.refreshBar()

			-- 重生按钮是否可用
			local tempSlot = self.slotDataList[selectIndex+1]
    		local heroData = HeroObj:getHero(tempSlot.HeroId)
			self.mRebirthBtn:setEnabled(heroData.FavorInfo and next(heroData.FavorInfo) and true or false)
        end
    })

	figureView:setAnchorPoint(cc.p(0.5, 1))
	figureView:setPosition(320, 1000)
	self:addChild(figureView)

	-- 左箭头
	local leftArrow = ui.newSprite("c_26.png")
	leftArrow:setRotation(180)
	leftArrow:setPosition(15, bgSize.height*0.7-10)
	figureView:addChild(leftArrow)
	-- 右箭头
	local rightArrow = ui.newSprite("c_26.png")
	rightArrow:setPosition(bgSize.width-15, bgSize.height*0.7-10)
	figureView:addChild(rightArrow)
	
	return figureView
end

-- 创建卡槽人物名称、等级、战力等属性
function BrewEatLayer:createHeroInfo()
	local heroInfoNode = cc.Node:create()

	-- 创建人物的名字
	local _, _, nameNode = Figure.newNameAndStar({
		parent = heroInfoNode,
		position = cc.p(320, 970),
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

-- 创建亲密度进度
function BrewEatLayer:createProgressbar()
	-- 父节点
	local parentNode = cc.Node:create()
	parentNode:setAnchorPoint(cc.p(0.5, 0.5))
	parentNode:setPosition(320, 440)
	self:addChild(parentNode)

	local parentWidth = 0
	local parentHight = 30
	-- 亲密度文本
	local intimacyLabel = ui.newLabel({
			text = TR("亲密度"),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	intimacyLabel:setAnchorPoint(0, 0.5)
	intimacyLabel:setPosition(0, parentHight*0.5)
	parentNode:addChild(intimacyLabel)

	parentWidth = parentWidth + intimacyLabel:getContentSize().width+80
	-- 进度条
	local intimacybar = require("common.ProgressBar"):create({
	    bgImage = "hj_6.png",
	    barImage = "hj_7.png",
	    currValue = 0,
	    maxValue = 100,
	    needLabel = true,
	    percentView = false,
	    size = 20,
	    color = Enums.Color.eWhite,
	})
	intimacybar:setAnchorPoint(cc.p(0, 0.5))
	intimacybar:setPosition(parentWidth, parentHight*0.5)
	parentNode:addChild(intimacybar)

	parentWidth = parentWidth + intimacybar:getContentSize().width
	-- 设置父节点大小
	parentNode:setContentSize(parentWidth, parentHight)

	-- 添加进度刷新函数
	intimacybar.refreshBar = function ()
		local tempSlot = self.slotDataList[self.curHeroIndex]
		local heroData = HeroObj:getHero(tempSlot.HeroId)
		-- 亲密度信息
		local favorInfo = heroData.FavorInfo or {}
		local curLv = favorInfo.FavorLv or 0
		intimacyLabel:setString(TR("亲密度%d级", curLv))

		-- 刷新进度条
		local maxValue, curValue = 0, 0
		if curLv >= (BrewingFavorLvRelation.items_count-1) then
			maxValue = BrewingFavorLvRelation.items[BrewingFavorLvRelation.items_count-1].exp - BrewingFavorLvRelation.items[BrewingFavorLvRelation.items_count-2].exp
			curValue = BrewingFavorLvRelation.items[BrewingFavorLvRelation.items_count-1].exp - BrewingFavorLvRelation.items[BrewingFavorLvRelation.items_count-2].exp
		else
			maxValue = BrewingFavorLvRelation.items[curLv+1].exp - BrewingFavorLvRelation.items[curLv].exp
			curValue = (favorInfo.FavorTotalExp or 0) - BrewingFavorLvRelation.items[curLv].exp
		end

		intimacybar:setMaxValue(maxValue)
		intimacybar:setCurrValue(curValue)
	end

	intimacybar.refreshBar()

	return intimacybar
end

-- 创建酒列表
function BrewEatLayer:createWineList()
	-- 黑背景
	local blackSize = cc.size(528, 161)
	local blackBg = ui.newScale9Sprite("bsxy_10.png", blackSize)
	blackBg:setPosition(320, 275)
	self:addChild(blackBg)
	-- 白背景
	local whiteSize = cc.size(500, 143)
	local whiteBg = ui.newScale9Sprite("c_65.png", whiteSize)
	whiteBg:setPosition(blackSize.width*0.5, blackSize.height*0.5)
	blackBg:addChild(whiteBg)
	-- 左箭头
	local leftArrow = ui.newSprite("c_26.png")
	leftArrow:setRotation(180)
	leftArrow:setPosition(15, whiteSize.height*0.5)
	whiteBg:addChild(leftArrow)
	-- 右箭头
	local rightArrow = ui.newSprite("c_26.png")
	rightArrow:setPosition(whiteSize.width-15, whiteSize.height*0.5)
	whiteBg:addChild(rightArrow)
	-- 列表
	local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(405, whiteSize.height))
    listView:setItemsMargin(5)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(whiteSize.width*0.5, whiteSize.height*0.5)
    whiteBg:addChild(listView)

    return listView
end

-- 重生弹窗
function BrewEatLayer:createRebirthBox()
	local tempSlot = self.slotDataList[self.curHeroIndex]
	local heroData = HeroObj:getHero(tempSlot.HeroId)
	if not heroData.FavorInfo or not heroData.FavorInfo.DrinkStr or heroData.FavorInfo.DrinkStr == "" then
		ui.showFlashView(TR("该侠客没有喝酒"))
		return
	end

	-- 计算重生花费
	local useResText = string.format("{%s}100", Utility.getDaibiImage(ResourcetypeSub.eDiamond))
	
	-- 计算资源返还
	local getResList = {}
	local resList = Utility.analysisStrAttrList(heroData.FavorInfo.DrinkStr)
	for _, resInfo in pairs(resList) do
		local tempInfo = {}
		tempInfo.resourceTypeSub = ResourcetypeSub.eFunctionProps
		tempInfo.modelId = resInfo.fightattr
		tempInfo.num = resInfo.value

		table.insert(getResList, tempInfo)
	end
	
	local function createHintBox(parent, bgSprite, bgSize)
	    -- 花费提示
	    local useLabel = ui.newLabel({
	            text = TR("是否花费%s返还以下物品?", useResText),
	            color = Enums.Color.eWhite,
	            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	        })
	    useLabel:setAnchorPoint(0.5, 0.5)
	    useLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
	    bgSprite:addChild(useLabel)
	    -- 黑背景
	    local blackBg = ui.newScale9Sprite("c_17.png", cc.size(bgSize.width-50, 150))
	    blackBg:setPosition(bgSize.width*0.5, bgSize.height*0.5)
	    bgSprite:addChild(blackBg)
	    -- 列表
	    local listView = ccui.ListView:create()
	    listView:setDirection(ccui.ScrollViewDir.horizontal)
	    -- listView:setBounceEnabled(true)
	    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
	    listView:setAnchorPoint(cc.p(0.5, 0.5))
	    listView:setPosition(blackBg:getContentSize().width*0.5, blackBg:getContentSize().height*0.5)
	    blackBg:addChild(listView)

	    local cellSize = cc.size(100, blackBg:getContentSize().height)

	    -- 列表宽度
	    local listWidth = 0

	    -- 添加其他返还
	    for _, resInfo in pairs(getResList) do
	        local itemCell = ccui.Layout:create()
	        itemCell:setContentSize(cellSize)
	        listView:pushBackCustomItem(itemCell)

	        resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
	        local resCard = CardNode.createCardNode(resInfo)
	        resCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
	        itemCell:addChild(resCard)

	        listWidth = listWidth + cellSize.width
	    end

	    -- 设置列表大小
	    local maxWidth = blackBg:getContentSize().width-10
	    listView:setContentSize(cc.size(listWidth < maxWidth and listWidth or maxWidth, cellSize.height))
	end
	
	self.rebirthBoxLayer = LayerManager.addLayer({
	    name = "commonLayer.MsgBoxLayer",
	    cleanUp = false,
	    data = {
	        notNeedBlack = true,
	        bgSize = cc.size(600, 400),
	        title = TR("重生"),
	        btnInfos = {
	            {
	                text = TR("确定"),
	                normalImage = "c_28.png",
	                clickAction = function ()
	                    self:requestRebirthWine()
	                    LayerManager.removeLayer(self.rebirthBoxLayer)
	                end,
	            },
	            {
	                text = TR("取消"),
	                normalImage = "c_28.png",
	                clickAction = function ()
	                    LayerManager.removeLayer(self.rebirthBoxLayer)
	                end,
	            },
	        },
	        DIYUiCallback = createHintBox,
	        closeBtnInfo = {}
	    }
	})
end

-- 属性查看弹窗
function BrewEatLayer:createAttrBox()
	local function DIYfunc(boxRoot, bgSprite, bgSize)
        local attrBgSize = cc.size(bgSize.width*0.9, (bgSize.height-180))
        local attrBgSprite = ui.newScale9Sprite("c_38.png", attrBgSize)
        attrBgSprite:setAnchorPoint(0.5, 0)
        attrBgSprite:setPosition(bgSize.width/2, 100)
        bgSprite:addChild(attrBgSprite)

        local labelHight = attrBgSize.height-20
        local labelWidth = attrBgSize.width*0.9 - 35
        for _, tempSlot in pairs(self.slotDataList) do
        	local heroData = HeroObj:getHero(tempSlot.HeroId)
        	local favorLv = heroData.FavorInfo and heroData.FavorInfo.FavorLv or 0
        	local descText = ConfigFunc:getHeroName(tempSlot.ModelId, {heroStep = heroData.Step, IllusionModelId = heroData.IllusionModelId, heroFashionId = heroData.CombatFashionOrder})

        	local attrStr = self:getAttrStr(favorLv)
        	if favorLv > 0 then
        		descText = descText .. TR("亲密度%s%d%s级：%s", Enums.Color.eYellowH, favorLv, Enums.Color.eWhiteH, attrStr)
        	else
        		descText = descText .. TR("亲密度%s0%s级：无属性加成", Enums.Color.eYellowH, Enums.Color.eWhiteH)
        	end

        	local attrLabel = ui.newLabel({
        			text = descText,
        			size = 24,
        			color = Enums.Color.eWhite,
        			outlineColor = Enums.Color.eOutlineColor,
        			dimensions = cc.size(labelWidth, 0)
        		})
        	attrLabel:setAnchorPoint(cc.p(0, 1))
        	attrLabel:setPosition(20, labelHight)
        	attrBgSprite:addChild(attrLabel)

        	labelHight = labelHight - attrLabel:getContentSize().height - 15 
        end
    end

    -- 创建对话框
    local boxSize = cc.size(581, 685)
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

function BrewEatLayer:getAttrStr(favorLv)
	local attrStr = BrewingFavorLvRelation.items[favorLv].totalAttrStr
	local attrList = Utility.analysisStrAttrList(attrStr)

	local attrStrList = {}
	for _, item in pairs(attrList) do
		local nameStr = FightattrName[item.fightattr]
		local baseAttrStr = Utility.getAttrViewStr(item.fightattr, item.value, true)

		local str = Enums.Color.eWhiteH .. nameStr .. Enums.Color.eYellowH .. baseAttrStr
		table.insert(attrStrList, str)
	end

	return table.concat(attrStrList, "，")
end

-- 刷新酒列表
-- 参数：qualityLvList 	品质选择列表([qualityLv] = true)，若为空则没有筛选
function BrewEatLayer:refreshWineList(qualityLvList)
	self.curWineModelId = nil
	self.mQualitySelList = {}
	self.mWineListView:removeAllChildren()
	-- 酒列表
	local wineList = {}
	-- 筛选选择的品质
	if qualityLvList and next(qualityLvList) then
		for _, brewInfo in pairs(BrewingModel.items) do
			local goodsInfo = GoodsModel.items[brewInfo.ID]
			local qualityLv = Utility.getQualityColorLv(goodsInfo.quality)
			if qualityLvList[qualityLv] then
				table.insert(wineList, brewInfo)
			end
		end
		self.mQualitySelList = clone(qualityLvList)
	-- 没有筛选
	else
		for _, brewInfo in pairs(BrewingModel.items) do
			table.insert(wineList, brewInfo)
		end
	end
	-- 排序
	table.sort(wineList, function (items1, items2)
		local goodsInfo1 = GoodsModel.items[items1.ID] 
		local goodsInfo2 = GoodsModel.items[items2.ID]

		local num1 = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, goodsInfo1.ID) or 0
		local num2 = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, goodsInfo2.ID) or 0

		-- 按有没有排序
		if (num1 > 0) ~= (num2 > 0) then
			return (num1 > 0)
		end

		-- 按品质排序
		if goodsInfo1.quality ~= goodsInfo2.quality then
			return goodsInfo1.quality < goodsInfo2.quality
		end

		return items1.ID < items2.ID
	end)
	-- 添加入列表显示
	for _, brewInfo in pairs(wineList) do
		local itemLayout = self:createCell(brewInfo)
		self.mWineListView:pushBackCustomItem(itemLayout)
	end
end

-- 创建列表项
function BrewEatLayer:createCell(itemInfo)
	local cellSize = cc.size(105, 120)

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	-- 选中背景
	local selectSprite = ui.newSprite("c_31.png")
	selectSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5+10)
	layout:addChild(selectSprite)
	selectSprite:setVisible(false)
	-- 道具信息
	local goodsInfo = GoodsModel.items[itemInfo.ID] 
	-- 创建卡牌
	local card = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eFunctionProps,
			modelId = goodsInfo.ID,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
			onClickCallback = function ()
				local num = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, goodsInfo.ID) or 0
				-- 有数量才可选
				if num > 0 then
					if self.curWineModelId == goodsInfo.ID then return end
					self.curWineModelId = goodsInfo.ID
					selectSprite:setVisible(true)
					if self.beforeSelect and not tolua.isnull(self.beforeSelect) then
						self.beforeSelect:setVisible(false)
					end
					self.beforeSelect = selectSprite
				else
					CardNode.defaultCardClick({
							resourceTypeSub = ResourcetypeSub.eFunctionProps,
							modelId = goodsInfo.ID,
						})
				end
			end,
		})
	card:setPosition(cellSize.width*0.5, cellSize.height*0.5+10)
	layout:addChild(card)
	-- 数量显示
	local numLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			size = 20,
		})
	numLabel:setPosition(card:getContentSize().width*0.5, 15)
	card:addChild(numLabel)

	-- 刷新数量显示函数
	layout.refreshNum = function ()
		local num = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, goodsInfo.ID) or 0
		numLabel:setString(num)

		if num <= 0 then
			card:setGray(true)
		else
			card:setGray(false)
		end
	end

	layout.refreshNum()

	return layout
end

-- 刷新酒列表数量
function BrewEatLayer:refreshWineListNum()
	for _, item in pairs(self.mWineListView:getItems()) do
		item.refreshNum()
	end
end

-- 刷新页面
function BrewEatLayer:refreshUI()
	-- 刷新进度
	self.mIntimacyBar.refreshBar()
	-- 刷新酒数量
	self:refreshWineListNum()

	-- 重生按钮是否可用
	local tempSlot = self.slotDataList[self.curHeroIndex]
	local heroData = HeroObj:getHero(tempSlot.HeroId)
	self.mRebirthBtn:setEnabled(heroData.FavorInfo and next(heroData.FavorInfo) and true or false)
end

-------------------------网络相关---------------------
-- 喝酒
function BrewEatLayer:eatWine()
	if not self.curWineModelId then
		ui.showFlashView(TR("请选择要喝的酒"))
		return
	end
	local heroId = self.slotDataList[self.curHeroIndex].HeroId
	local heroInfo = HeroObj:getHero(heroId)
	local num = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, self.curWineModelId) or 0

	if heroInfo.FavorInfo.FavorLv and heroInfo.FavorInfo.FavorLv >= BrewingFavorLvRelation.items_count-1 then
		ui.showFlashView(TR("亲密度已满"))
		return
	end

	if num <= 0 then return end

	if num > 1 then
		self.useNumBox = MsgBoxLayer.addUseGoodsCountLayer(TR("喝酒"), self.curWineModelId, num, function (selCount)
			HttpClient:request({
			    moduleName = "Brewing",
			    methodName = "Drink",
			    svrMethodData = {heroId, self.curWineModelId, selCount},
			    callback = function(response)
			        if not response or response.Status ~= 0 then
			            return
			        end
			        -- 刷新人物缓存
			        HeroObj:modifyHeroItem(response.Value.HeroInfo)
			        -- 刷新界面
			        self:refreshUI()
			    end
		    })

		    LayerManager.removeLayer(self.useNumBox)
		end)
	else
		HttpClient:request({
		    moduleName = "Brewing",
		    methodName = "Drink",
		    svrMethodData = {heroId, self.curWineModelId, 1},
		    callback = function(response)
		        if not response or response.Status ~= 0 then
		            return
		        end
		        -- 刷新人物缓存
		        HeroObj:modifyHeroItem(response.Value.HeroInfo)
		        -- 刷新界面
		        self:refreshUI()
		    end
	    })
	end
end

-- 重生
function BrewEatLayer:requestRebirthWine()
	local heroId = self.slotDataList[self.curHeroIndex].HeroId
	HttpClient:request({
	    moduleName = "Brewing",
	    methodName = "Rebirth",
	    svrMethodData = {heroId},
	    callback = function(response)
	        if not response or response.Status ~= 0 then
	            return
	        end
	        -- 刷新人物缓存
	        HeroObj:modifyHeroItem(response.Value.HeroInfo)
	        -- 刷新界面
	        self:refreshUI()
	        -- 显示奖励
	        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	    end
    })
end

return BrewEatLayer