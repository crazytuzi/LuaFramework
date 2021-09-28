--[[
	文件名：BrewWineLayer.lua
	描述：酿酒界面
	创建人：yanghongsheng
	创建时间： 2018.5.21
--]]

local BrewWineLayer = class("BrewWineLayer", function()
	return display.newLayer()
end)

--[[
	params:
		cbQualitySelect 	筛选回调
]]

function BrewWineLayer:ctor(params)
	params = params or {}
	self.mCbQualitySelect = params.cbQualitySelect

	-- 酿制进度表
	self.mWineProgressList = {}
	-- 当前选中酒的模型id
	self.curWineModelId = nil
	-- 酒材列表
	self.mWineMaterialList = {}
	-- 当前是否有酒引
	self.mIsWineLead = false
	-- 记录筛选条件
	self.mQualitySelList = {}
	
    -- 初始化
    self:initUI()

    -- 请求服务器信息
    self:requestInfo()
end

function BrewWineLayer:initUI()
	-- 主角
	Figure.newHero({
    	parent = self,
    	heroModelID = FormationObj:getSlotInfoBySlotId(1).ModelId,
        fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
		position = cc.p(320, 520),
		scale = 0.3,
		rebornId = rebornId,
		async = function (figureNode)
		end,
	})
	-- 背景
	local bgSprite = ui.newScale9Sprite("mp_23.png", cc.size(640, 530))
	bgSprite:setAnchorPoint(0.5, 0)
	bgSprite:setPosition(320, 115)
	self:addChild(bgSprite)
	-- 酒列表
	self.mWineListView = self:createWineList()
	-- 酿造进度
	self.mWineBar = self:createProgressbar()
	-- 筛选按钮
	local selectBtn = ui.newButton({
		text = TR("筛选"),
		normalImage = "c_33.png",
		clickAction = function ()
			if self.mCbQualitySelect then
				self.mCbQualitySelect({
					refreshCallBack = handler(self, self.refreshWineList),
					boxPosition = cc.p(120, 550),
				})
			end
		end,
	})
	selectBtn:setPosition(115, 530)
	self:addChild(selectBtn)
	-- 酒引
	self.mWineLead = self:createWineLead()
	-- 酒材
	self.mWineMaterial = self:createWineMaterial()
	-- 酿酒按钮
	local wineBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("酿制"),
			position = cc.p(432, 160),
			clickAction = function ()
				self:requestBrewing()
			end,
		})
	self:addChild(wineBtn)

	-- 一键添加按钮
	local oneKeyBtn = ui.newButton({
			normalImage = "cuiti_06.png",
			position = cc.p(548, 257),
			clickAction = function ()
				self:oneKeyAdd()
			end,
		})
	self:addChild(oneKeyBtn)

	-- 刷新酒列表
	self:refreshWineList()
end

-- 创建酿造进度
function BrewWineLayer:createProgressbar()
	-- 父节点
	local parentNode = cc.Node:create()
	parentNode:setAnchorPoint(cc.p(0.5, 0.5))
	parentNode:setPosition(320, 580)
	self:addChild(parentNode)

	local parentWidth = 0
	local parentHight = 30
	-- 酿制进度文本
	local wineLabel = ui.newLabel({
			text = TR("酿制进度"),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	wineLabel:setAnchorPoint(0, 0.5)
	wineLabel:setPosition(0, parentHight*0.5)
	parentNode:addChild(wineLabel)

	parentWidth = parentWidth + wineLabel:getContentSize().width+30
	-- 进度条
	local winebar = require("common.ProgressBar"):create({
	    bgImage = "hj_6.png",
	    barImage = "hj_7.png",
	    currValue = 0,
	    maxValue = 100,
	    needLabel = true,
	    percentView = false,
	    size = 20,
	    color = Enums.Color.eWhite,
	})
	winebar:setAnchorPoint(cc.p(0, 0.5))
	winebar:setPosition(parentWidth, parentHight*0.5)
	parentNode:addChild(winebar)

	parentWidth = parentWidth + winebar:getContentSize().width
	-- 设置父节点大小
	parentNode:setContentSize(parentWidth, parentHight)

	-- 添加进度刷新函数
	winebar.refreshBar = function ()
		local maxValue = BrewingModel.items[self.curWineModelId].needExp
		local currValue = self.mWineProgressList[self.curWineModelId] or 0

		winebar:setMaxValue(maxValue)
		winebar:setCurrValue(currValue)
	end

	return winebar
end

-- 创建酒列表
function BrewWineLayer:createWineList()
	-- 黑背景
	local blackSize = cc.size(528, 161)
	local blackBg = ui.newScale9Sprite("bsxy_10.png", blackSize)
	blackBg:setPosition(320, 420)
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

-- 创建酒引
function BrewWineLayer:createWineLead()
	local parentNode = cc.Node:create()
	parentNode:setPosition(70, 205)
	self:addChild(parentNode)

	-- 刷新函数
	parentNode.refreshWineLead = function ()
		-- 清空子节点
		parentNode:removeAllChildren()
		self.mIsWineLead = true

		-- 酒引文本
		local leadLabel = ui.newLabel({
				text = TR("酒引："),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		leadLabel:setAnchorPoint(cc.p(0, 0))
		leadLabel:setPosition(0, 105)
		parentNode:addChild(leadLabel)

		-- 酒引卡牌
		local resInfo = Utility.analysisStrResList(BrewingModel.items[self.curWineModelId].needGoods)[1]
		if resInfo then
			resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
			local leadCard = CardNode.createCardNode(resInfo)
			leadCard:setPosition(40, 55)
			parentNode:addChild(leadCard)

			local num = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId) or 0
			local progress = self.mWineProgressList[self.curWineModelId] or 0
			leadCard:setGray(progress <= 0 and num <= 0)

			self.mIsWineLead = not (progress <= 0 and num <= 0)
		else
			local noLeadSprite = ui.newSprite("hj_8.png")
			noLeadSprite:setPosition(40, 40)
			parentNode:addChild(noLeadSprite)
		end
	end

	return parentNode
end

-- 创建酒材
function BrewWineLayer:createWineMaterial()
	local parentNode = cc.Node:create()
	parentNode:setPosition(486, 245)
	self:addChild(parentNode)

	parentNode.refreshMaterial = function(materialList)
		-- 清空
		parentNode:removeAllChildren()
		self.mWineMaterialList = {}
		-- 文本
		local textLabel = ui.newLabel({
				text = TR("点击加入酒材："),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		textLabel:setAnchorPoint(cc.p(1, 0.5))
		textLabel:setPosition(0, 80)
		parentNode:addChild(textLabel)

		if materialList and next(materialList) then
			-- 整理药材表
			for modelId, num in pairs(materialList) do
				local resInfo = {}
				resInfo.resourceTypeSub = ResourcetypeSub.eFunctionProps
				resInfo.modelId = modelId
				resInfo.num = num

				table.insert(self.mWineMaterialList, resInfo)
			end

			-- 酒材卡
			local firstResInfo = clone(self.mWineMaterialList[1])
			firstResInfo.onClickCallback = function ()
				local maxValue = BrewingModel.items[self.curWineModelId].needExp
				local currValue = self.mWineProgressList[self.curWineModelId] or 0

				LayerManager.addLayer({
						name = "brew.BrewSelectLayer",
						data = {
							callback = parentNode.refreshMaterial,
							limitExp = maxValue - currValue,
						},
						cleanUp = false,
					})
			end
			local card = CardNode.createCardNode(firstResInfo)
			card:setAnchorPoint(cc.p(1, 0.5))
			card:setPosition(0, 15)
			parentNode:addChild(card)
		else
			-- 酒材卡
			local card = CardNode.createCardNode({
					onClickCallback = function ()
						local maxValue = BrewingModel.items[self.curWineModelId].needExp
						local currValue = self.mWineProgressList[self.curWineModelId] or 0

						LayerManager.addLayer({
								name = "brew.BrewSelectLayer",
								data = {
									callback = parentNode.refreshMaterial,
									limitExp = maxValue - currValue,
								},
								cleanUp = false,
							})
					end,
				})
			card:setEmpty({}, "c_04.png", "c_22.png")
			card:setAnchorPoint(cc.p(1, 0.5))
			card:setPosition(0, 15)
			parentNode:addChild(card)
		end
	end

	return parentNode
end

-- 刷新酒列表
-- 参数：qualityLvList 	品质选择列表([qualityLv] = true)，若为空则没有筛选
function BrewWineLayer:refreshWineList(qualityLvList)
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

		-- 按品质排序
		if goodsInfo1.quality ~= goodsInfo2.quality then
			return goodsInfo1.quality < goodsInfo2.quality
		end

		return items1.ID < items2.ID
	end)
	-- 添加入列表显示
	for _, brewInfo in pairs(wineList) do
		-- 初始化当前选中酒
		if not self.curWineModelId then self.curWineModelId = brewInfo.ID end

		-- 添加列表
		local itemLayout = self:createCell(brewInfo)
		self.mWineListView:pushBackCustomItem(itemLayout)
	end

	-- 刷新当前相关项
	self:refreshItemRelate()
end

-- 创建列表项
function BrewWineLayer:createCell(itemInfo)
	local cellSize = cc.size(105, 120)

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	-- 选中背景
	local selectSprite = ui.newSprite("c_31.png")
	selectSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5+10)
	layout:addChild(selectSprite)
	selectSprite:setVisible(false)
	-- 初始化选中框
	if itemInfo.ID == self.curWineModelId then
		self.beforeSelect = selectSprite
		self.beforeSelect:setVisible(true)
	end
	-- 道具信息
	local goodsInfo = GoodsModel.items[itemInfo.ID] 
	-- 创建卡牌
	local card = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eFunctionProps,
			modelId = goodsInfo.ID,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
			onClickCallback = function ()
				-- 重复选择判断
				if self.curWineModelId == itemInfo.ID then return end
				-- 更新当前酒模型id
				self.curWineModelId = itemInfo.ID
				-- 显示选中框
				selectSprite:setVisible(true)
				-- 更新选中框引用
				if self.beforeSelect and not tolua.isnull(self.beforeSelect) then
					self.beforeSelect:setVisible(false)
				end
				self.beforeSelect = selectSprite

				-- 刷新界面
				self:refreshItemRelate()
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
	end

	layout.refreshNum()

	return layout
end

-- 一键添加酒材
function BrewWineLayer:oneKeyAdd()
	-- 当前需要经验
	local maxValue = BrewingModel.items[self.curWineModelId].needExp
	local currValue = self.mWineProgressList[self.curWineModelId] or 0
	local needExp = maxValue - currValue
	-- 找到当前所有酒材
	-- 遍历配置文件
	local materialList = {}
	for _, materialInfo in pairs(clone(BrewingGoodsExpModel.items)) do
		local num = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, materialInfo.ID) or 0
		if num > 0 then
			materialInfo.num =  num
			table.insert(materialList, materialInfo)
		end
	end
	-- 找到足够经验的同种酒材，若没有足够经验则记录当前总经验最多的酒材
	local maxExp = 0
	local curItem = nil
	for _, materialData in pairs(materialList) do
		local needNum = math.ceil(needExp/materialData.exp)
		if materialData.num >= needNum then
			curItem = {
				resourceTypeSub = ResourcetypeSub.eFunctionProps,
				modelId = materialData.ID,
				num = needNum,
			}
			break
		else
			local curExp = materialData.exp * materialData.num
			if curExp > maxExp then
				maxExp = curExp
				curItem = {
					resourceTypeSub = ResourcetypeSub.eFunctionProps,
					modelId = materialData.ID,
					num = materialData.num,
				}
			end
		end
	end
	-- 将酒材列表传入酒材刷新函数
	if curItem then
		local needMaterialList = {}
		needMaterialList[curItem.modelId] = curItem.num
		self.mWineMaterial.refreshMaterial(needMaterialList)
	else
		ui.showFlashView(TR("您没有可用的酒材"))
	end
end

-- 刷新酒列表数量
function BrewWineLayer:refreshWineListNum()
	for _, item in pairs(self.mWineListView:getItems()) do
		item.refreshNum()
	end
end

-- 刷新酿制进度表
function BrewWineLayer:refreshProgressList(BrewingInfo)
	-- 清空列表
	self.mWineProgressList = {}
	-- 空判断
	if not BrewingInfo or not BrewingInfo.BrewingStr or BrewingInfo.BrewingStr == "" then
		return
	end

	-- 填充列表
	local progressList = Utility.analysisStrAttrList(BrewingInfo.BrewingStr)
	for _, progressInfo in pairs(progressList) do
		self.mWineProgressList[progressInfo.fightattr] = progressInfo.value
	end
end

-- 根据选中项刷新当前进度，酒引等
function BrewWineLayer:refreshItemRelate()
	-- 刷新酒列表数量
	self:refreshWineListNum()
	-- 更新进度条
	self.mWineBar.refreshBar()
	-- 刷新酒引
	self.mWineLead.refreshWineLead()
	-- 刷新酒材
	self.mWineMaterial.refreshMaterial()
end
--------------------------网络相关-------------------
-- 酒的酿制信息
function BrewWineLayer:requestInfo()
	HttpClient:request({
	    moduleName = "Brewing",
	    methodName = "GetInfo",
	    svrMethodData = {},
	    callback = function(response)
	        if not response or response.Status ~= 0 then
	            return
	        end
	        -- 更新进度数据
	        self:refreshProgressList(response.Value.BrewingInfo)
	        -- 更新当前项
	        self:refreshItemRelate()
	    end
    })
end

-- 酿制请求
function BrewWineLayer:requestBrewing()
	-- 酒引判断
	if not self.mIsWineLead then
		ui.showFlashView(TR("酒引不足"))
		return
	end
	-- 酒材判断
	if not next(self.mWineMaterialList) then
		ui.showFlashView(TR("请先选酒材"))
		return
	end

	HttpClient:request({
	    moduleName = "Brewing",
	    methodName = "Brewing",
	    svrMethodData = {self.curWineModelId, self.mWineMaterialList[1].modelId, self.mWineMaterialList[1].num},
	    callback = function(response)
	        if not response or response.Status ~= 0 then
	            return
	        end
	        -- 更新进度数据
	        self:refreshProgressList(response.Value.BrewingInfo)
	        -- 更新当前项
	        self:refreshItemRelate()
	        -- 显示奖励
	        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	    end
    })
end

return BrewWineLayer