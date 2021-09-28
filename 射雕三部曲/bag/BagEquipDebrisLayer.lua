--[[
	文件名：BagEquipDebrisLayer.lua
	描述：装备碎片界面
	创建人：lengjiazhi
	创建时间：2017.5.9
--]]
local BagEquipDebrisLayer = class("BagEquipDebrisLayer", function (params)
	return display.newLayer()
end)

function BagEquipDebrisLayer:ctor(params)
	self.mParent = params.parent
	self.mFristChooseTag = 3

	self.mSelectStatus = { --保存菜单选择状态
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
	}
	self.mSelCount = 0 -- 合成选择数量

	-- 包裹空间文字背景图片
    local countBack = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    countBack:setPosition(420, 940)
    self:addChild(countBack)

    countWordLabel = ui.newLabel({
        text = TR("包裹空间"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    countWordLabel:setAnchorPoint(cc.p(0, 0.5))
    countWordLabel:setPosition(270, 940)
    self:addChild(countWordLabel)

	--灰色底板
	local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(622, 714))
	underBgSprite:setPosition(320, 910)
	underBgSprite:setAnchorPoint(0.5, 1)
	self:addChild(underBgSprite)
	
	self:showBagCount()
	-- self:getItemData()
	self:refreshList()

	--选择菜单按钮
	local selectBtn = ui.newButton({
		normalImage = "bg_01.png",
		text = TR("筛选"),
        fontSize = 22,
        outlineColor = cc.c3b(0x18, 0x7e, 0x6d),
		-- size = cc.size(80, 34),
		-- clickAction = function()

		-- end
		})
	selectBtn:setPosition(572, 940)
	self:addChild(selectBtn, 10)
	local temp = true --控制展示或者关闭菜单
	local triangle = ui.newSprite("bg_02.png") --三角形箭头
	triangle:setRotation(90)
	triangle:setPosition(84, 22)
	selectBtn:addChild(triangle)
	selectBtn:setClickAction(function(pSender)
		pSender:setEnabled(false)
		local showAction
		local touchLayer = display.newLayer()
		touchLayer:setPosition(0,0)
		self:addChild(touchLayer, 10000)
		ui.registerSwallowTouch({
			node = touchLayer,
			allowTouch = true,
	        endedEvent = function(touch, event)
	        	offset = 1
				temp = true
				local callfunDelete = cc.CallFunc:create(function()
					if self.mSelBgSprite then
						self.mSelBgSprite:removeFromParent()
						self.mSelBgSprite = nil
					end
				end)
				local callfunCT = cc.CallFunc:create(function()
					pSender:setEnabled(true)
					touchLayer:removeFromParent()
				end)
				local scale = cc.ScaleTo:create(0.3, 1)
				showAction = cc.Sequence:create(scale, callfunDelete, callfunCT)
				triangle:setRotation(offset*90)
				self.mSelBgSprite:runAction(showAction)
	        end
			})
		if temp then
			offset = 0
			temp = false
			local callfunCT = cc.CallFunc:create(function()
				pSender:setEnabled(true)
			end)
			local scale = cc.ScaleTo:create(0.3, 2)
			showAction = cc.Sequence:create(scale, callfunCT)
		end
		triangle:setRotation(offset*90)

		if not self.mSelBgSprite then
			--菜单背景
			self.mSelBgSprite = ui.newScale9Sprite("zb_05.png", cc.size(82, 150)) --(82, 150)
			self.mSelBgSprite:setAnchorPoint(0.5, 1)
			self.mSelBgSprite:setPosition(550, 920)
			touchLayer:addChild(self.mSelBgSprite)
			local bgSize = self.mSelBgSprite:getContentSize()
			--菜单列表
			local selectList = ccui.ListView:create()
			selectList:setPosition(bgSize.width * 0.5, bgSize.height)
			selectList:setAnchorPoint(0.5, 1)
			selectList:setContentSize(bgSize.width - 10, bgSize.height - 5)
			selectList:setDirection(ccui.ScrollViewDir.vertical)
			selectList:setBounceEnabled(true)
			self.mSelBgSprite:addChild(selectList)

			for i = 1, #self.mSelectStatus do
				local layout = ccui.Layout:create()
				layout:setContentSize(138, 20)
				local color = Utility.getColorValue(i, 1)
				local checkBtn = ui.newCheckbox({
					text = TR("%s品质", Utility.getColorName(i)),
					textColor = color,
			        outlineColor = Enums.Color.eBlack,
			        outlineSize = 2,
					callback = function(pSenderC)
						if self.mSelectStatus[i] then
							self.mSelectStatus[i] = false
						else
							self.mSelectStatus[i] = true
						end
						self:refreshList()
					end
					})
				checkBtn:setPosition(70, 10)
				layout:addChild(checkBtn)
				checkBtn:setCheckState(self.mSelectStatus[i])

				layout:setScale(0.5)
				selectList:pushBackCustomItem(layout)
			end
		end

		self.mSelBgSprite:runAction(showAction)
	end)
	self:createBottomView()

end

--创建下方操作按钮
function BagEquipDebrisLayer:createBottomView()
	local chooseBtn = ui.newButton({
		normalImage = "c_155.png",
		size = cc.size(170, 50),
		titlePosRateX = 0.6,
		text = TR("优先%s%s", Utility.getColorValue(self.mFristChooseTag, 2), Utility.getColorName(self.mFristChooseTag)),
		clickAction = function()
			self:createChooseNode()
			self.mChooseTriangel:setRotation(180)
		end
	})
	chooseBtn:setPosition(320, 135)
	self:addChild(chooseBtn)
	self.mChooseBtn = chooseBtn

	local chooseTriangleBg = ui.newSprite("c_60.png")
	chooseTriangleBg:setPosition(25, 25)
	chooseBtn:addChild(chooseTriangleBg)

	local chooseTriangle = ui.newSprite("c_158.png")
	chooseTriangle:setPosition(25, 25)
	chooseBtn:addChild(chooseTriangle)
	self.mChooseTriangel = chooseTriangle


	local oneKeyExchangeBtn = ui.newButton({
		text = TR("一键兑换"),
		normalImage = "c_28.png",
		clickAction = function ()
			if PlayerAttrObj:getPlayerAttrByName("Lv") < ModuleSubModel.items[ModuleSub.eBDDShop].openLv then
				ui.showFlashView(TR("%s级开启装备兑换功能", ModuleSubModel.items[ModuleSub.eBDDShop].openLv))
				return
			end
			self:requestOneKeyExchange()
		end
		})
	oneKeyExchangeBtn:setPosition(515, 135)
	self:addChild(oneKeyExchangeBtn)
end

--创建下方选择框
function BagEquipDebrisLayer:createChooseNode()
 	local tempLayer = cc.Layer:create()
    display.getRunningScene():addChild(tempLayer, Enums.ZOrderType.ePopLayer)

    -- 组册触摸事件
	ui.registerSwallowTouch({
		node = tempLayer,
		allowTouch = true,
		beganEvent = function(touch, event)
	    	return true
	    end,
	    endedEvent = function(touch, event)
	    	tempLayer:removeFromParent()
	    	self.mChooseTriangel:setRotation(0)
	    end,
	})

    -- 创建一键选择筛选条件按钮
    local btnInfos= {
    	{
    		text = TR("优先%s蓝色", Utility.getColorValue(3, 2)),
    		chooseTag = 3,
    	},
    	{
    		text = TR("优先%s紫色", Utility.getColorValue(4, 2)),
    		chooseTag = 4,
    	},
    	-- {
    	-- 	text = TR("优先%s橙色", Utility.getColorValue(5, 2)),
    	-- 	chooseTag = 5,
    	-- },
    	-- {
    	-- 	text = TR("优先%s红色", Utility.getColorValue(6, 2)),
    	-- 	chooseTag = 6,
    	-- },
	}
	if PlayerAttrObj:getPlayerAttrByName("Lv") > 35 then
		local tempInfo = {
			text = TR("优先%s橙色", Utility.getColorValue(5, 2)),
    		chooseTag = 5,
    	}
		table.insert(btnInfos, tempInfo)
	end

	local startPos = self.mChooseBtn:getParent():convertToWorldSpace(cc.p(self.mChooseBtn:getPosition()))
    for index, item in ipairs(btnInfos) do
        item.normalImage = "bg_06.png"
        item.size = cc.size(170, 50)
        item.titlePosRateX = 0.6
        item.clickAction = function()
        	self.mFristChooseTag = item.chooseTag
        	self.mChooseBtn:setTitleText(item.text)
        	-- Notification:postNotification(ExtraEventName.eExtraCountChange)
        	self.mChooseTriangel:setRotation(0)
        	tempLayer:removeFromParent()
        end
        local tempBtn = ui.newButton(item)
        -- tempBtn:setScale(Adapter.MinScale)
        tempBtn:setPosition(startPos.x, startPos.y + 50 * index * Adapter.MinScale)
        tempLayer:addChild(tempBtn)
    end
end

--显示包裹空间
function BagEquipDebrisLayer:showBagCount()
    if self.mCountLabel then
        self.mCountLabel:removeFromParent()
        self.mCountLabel = nil
    end

    if self.mBuyBtn then
        self.mBuyBtn:removeFromParent()
        self.mBuyBtn = nil
    end

    -- 添加数量显示
    self.mCountLabel = ui.newLabel({
        text = TR("%d/%d", 0, 0),
        color = cc.c3b(0xd1, 0x7b, 0x00),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),s
        size = 22,
    })
    -- self.mCountLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mCountLabel:setPosition(410, 940)
    self:addChild(self.mCountLabel)
    self.mBuyBtn = ui.newButton({
        -- text = TR("扩充"),
        normalImage = "gd_27.png",
        position = cc.p(480, 940),
        -- size = cc.size(125, 57),
        clickAction = function()
            MsgBoxLayer.addExpandBagLayer(BagType.eEquipDebrisBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    self:addChild(self.mBuyBtn)
    -- self.mBuyBtn:setScale(0.8)
    local bagTypeInfo = BagModel.items[BagType.eEquipDebrisBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eEquipDebrisBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eEquipDebrisBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if self:getItemCount(BagType.eEquipDebrisBag) == 0 then
        local sp = ui.createEmptyHint(TR("没有装备！"))
        sp:setPosition(320, 500)
        self:addChild(sp)
    end
end
-- 刷新装备列表
function BagEquipDebrisLayer:refreshList()
	self.mData = self:getItemData()

	if self.mEquipList then
		self.mEquipList:removeFromParent()
		self.mEquipList = nil
	end

	self.mEquipList = ccui.ListView:create()
	self.mEquipList:setPosition(320, 906)
	self.mEquipList:setAnchorPoint(0.5, 1)
	self.mEquipList:setContentSize(630, 700)
	-- self.mEquipList:setItemsMargin(5)
	self.mEquipList:setDirection(ccui.ScrollViewDir.vertical)
	self.mEquipList:setBounceEnabled(true)
	self:addChild(self.mEquipList)

	for i,v in ipairs(self.mData) do
		self.mEquipList:pushBackCustomItem(self:createItem(i))
	end
end
-- 创建单个装备条目
function BagEquipDebrisLayer:createItem(index)
	local tempInfo = self.mData[index]
	local maxNum = GoodsModel.items[tempInfo.ModelId].maxNum
	local outEquipModel = EquipModel.items[GoodsModel.items[tempInfo.ModelId].outputModelID]

	local layout = ccui.Layout:create()
	layout:setContentSize(626, 130)
	--背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 122))
	bgSprite:setPosition(315, 65)
	layout:addChild(bgSprite)
	--前往按钮
	local lvUpBtn = ui.newButton({
		text = TR("合成"),
		normalImage = "c_28.png",
		})
	lvUpBtn:setPosition(539, 65)
	layout:addChild(lvUpBtn)

	local isGroup = outEquipModel.equipGroupID ~= 0 
	--头像
	local attrs
 	if tempInfo.Num >= maxNum then
 		attrs = {CardShowAttr.eBorder, CardShowAttr.eSynthetic}
 		lvUpBtn.mTitleLabel:setString(TR("合成"))
 		lvUpBtn:setClickAction(function()
 			self:composeView(tempInfo)
 		end)
 	else
 		attrs = {CardShowAttr.eBorder}
 		lvUpBtn.mTitleLabel:setString(isGroup and TR("去获取") or TR("兑换"))
 		lvUpBtn:setClickAction(function()
 			if isGroup then
	 			self.mParent.mThirdSubTag = BagType.eEquipDebrisBag
	 			LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = Utility.getTypeByModelId(tempInfo.ModelId),
		                modelId = tempInfo.ModelId
		            },
		            cleanUp = false,
		        })
	 		else
	 			if PlayerAttrObj:getPlayerAttrByName("Lv") < ModuleSubModel.items[ModuleSub.eBDDShop].openLv then
					ui.showFlashView(TR("%s级开启装备兑换功能", ModuleSubModel.items[ModuleSub.eBDDShop].openLv))
					return
				end
	 			self:exchangeCallback(tempInfo)
	 		end
 		end)
 	end
	local card = CardNode.createCardNode({
        instanceData = tempInfo,
        cardShowAttrs = attrs,
		})
	card:setPosition(84, 65)
	layout:addChild(card)
	--名字
	local nameStr = GoodsModel.items[tempInfo.ModelId].name
	local nameColor = Utility.getQualityColor(GoodsModel.items[tempInfo.ModelId].quality, 1)
	local nameLabel = ui.newLabel({
		text = nameStr,
		size = 22,
		color = nameColor,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
		})
	nameLabel:setAnchorPoint(0, 0.5)
	nameLabel:setPosition(145, 100)
	layout:addChild(nameLabel)

	local numBar = require("common.ProgressBar"):create({
		bgImage = "gd_12.png",   -- 背景图片
        barImage = "gd_11.png",  -- 进度图片
        currValue = tempInfo.Num,  -- 当前进度
        maxValue = maxNum, -- 最大值
        needLabel = true,
        color = Enums.Color.eWhite,
        size = 22,
		})
	numBar:setPosition(290, 52)
	layout:addChild(numBar)
	return layout
end

--兑换回调
function BagEquipDebrisLayer:exchangeCallback(tempInfo)
	local curLv = PlayerAttrObj:getPlayerAttrByName("Lv")
	local goodsInfo = GoodsModel.items[tempInfo.ModelId]
	local costInfo = BddEquipPreviewRelation.items[tempInfo.ModelId]
	local price = Utility.analysisStrResList(costInfo.price)
	if curLv < costInfo.limitLv then
		ui.showFlashView(TR("等级达到%s才能兑换这个装备", costInfo.limitLv))
		return
	end

    local maxNum = self.getMaxCostInfo(price)
    local params = {
           title = TR("兑换"),
           modelID = goodsInfo.ID,
           typeID = goodsInfo.typeID,
           coinList = price,
           maxNum = maxNum > 0 and maxNum or 1,
           oKCallBack = function(exchangeCount, layerObj, btnObj)
               LayerManager.removeLayer(layerObj)
               	for _, resInfo in pairs(price) do
               		if not Utility.isResourceEnough(resInfo.resourceTypeSub, resInfo.num*exchangeCount, true) then
               			return
               		end
               	end

               	self:requestExchange(costInfo.shopId, exchangeCount)
           end,
       }

    MsgBoxLayer.addExchangeGoodsListCountLayer(params)
end

-- 找出最少资源
function BagEquipDebrisLayer.getMaxCostInfo(costList)
    -- 获取资源消耗列表中第一项
    local costInfo = clone(costList[1])
    -- 获取玩家拥有的该项资源数量
    local playerCoinNum = Utility.getOwnedGoodsCount(costInfo.resourceTypeSub, costInfo.modelId)
    -- 获取该项资源最多可兑换的道具的数量
    local min = math.floor(playerCoinNum / costInfo.num)
    -- 遍历资源消耗列表获取最多可兑换的道具的数量
    for _, v in pairs(costList) do
        playerCoinNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
        local tempMin = math.floor(playerCoinNum / v.num)
        if min > tempMin then
            min = tempMin
            costInfo = v
        end
    end

    return min
end

-- 合成弹窗
function BagEquipDebrisLayer:composeView(info)
	local equipModelId = GoodsModel.items[info.ModelId].outputModelID
	local equipInfo = EquipModel.items[equipModelId]
	local maxNum = GoodsModel.items[info.ModelId].maxNum
	if math.floor(info.Num/maxNum) == 1 then
		self:requestCompose(info, maxNum)
		return
	end
	local popLayer = LayerManager.addLayer({
            name = "commonLayer.PopBgLayer",
            data = {
                bgSize = cc.size(550, 500),
                title = TR("装备合成"),
            },
            cleanUp = false,
        })
	local popbgSprite = popLayer.mBgSprite
	local bgSize = popbgSprite:getContentSize()
	self.mPopLayer = popLayer

	--头像
	local card = CardNode.createCardNode({
        resourceTypeSub = Utility.getTypeByModelId(equipInfo.ID),
        modelId = equipInfo.ID,
		cardShowAttrs = {CardShowAttr.eBorder}
		})
	card:setPosition(bgSize.width * 0.15, bgSize.height * 0.75)
	popbgSprite:addChild(card)

	--名字
	local nameColor = Utility.getQualityColor(equipInfo.quality, 1)
	local nameLabel = ui.newLabel({
		text = equipInfo.name,
		size = 21,
		color = nameColor,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
		})
	nameLabel:setAnchorPoint(0, 0.5)
	nameLabel:setPosition(bgSize.width * 0.25, bgSize.height * 0.82)
	popbgSprite:addChild(nameLabel)

    --星星
    local star = Figure.newEquipStarLevel({
	 	modelId = equipInfo.ID,
	 	})
    if star then
    	star:setPosition(bgSize.width * 0.25, bgSize.height * 0.75)
    	popbgSprite:addChild(star)
	 	star:setAnchorPoint(0, 0.5)
    end
    --当前拥有数量
    local nowHaveNum = ui.newLabel({
    	text = TR("当前拥有：%s/%s", info.Num, maxNum),
    	size = 21,
    	color = Enums.Color.eBlack,
    	})
    nowHaveNum:setAnchorPoint(0, 0.5)
    nowHaveNum:setPosition(bgSize.width * 0.25, bgSize.height * 0.68)
    popbgSprite:addChild(nowHaveNum)

    --灰色背景
    local greyBgsprite = ui.newScale9Sprite("c_17.png",cc.size(492, 215))
    greyBgsprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.42)
    popbgSprite:addChild(greyBgsprite)

    --属性背景板
    local attrBgSprite = ui.newScale9Sprite("c_18.png",cc.size(475, 125))
    attrBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
    popbgSprite:addChild(attrBgSprite)

    --提示
    local tipLabel = ui.newLabel({
    	text = TR("合成后装备属性："),
    	size = 23,
    	color = Enums.Color.eRed,
    	})
    tipLabel:setAnchorPoint(0, 0.5)
    tipLabel:setPosition(bgSize.width * 0.1, bgSize.height * 0.58)
    popbgSprite:addChild(tipLabel)
    --属性显示
    local attrStr = ""
    if equipInfo.AP > 0 then
    	attrStr = attrStr..TR("攻击：")..equipInfo.AP.."     "
    end
    if equipInfo.HP > 0 then
    	attrStr = attrStr..TR("血量：").. equipInfo.HP.."     "
	end
	if equipInfo.DEF > 0 then
		attrStr = attrStr..TR("防御：").. equipInfo.DEF.."     "
	end
	local attrLable = ui.newLabel({
		text = attrStr,
		color = Enums.Color.eBlack,
		size = 22,
		})
	attrLable:setAnchorPoint(0, 0.5)
	attrLable:setPosition(bgSize.width * 0.1, bgSize.height * 0.48)
	popbgSprite:addChild(attrLable)

	--选择数量控件
	local maxSelNum = math.floor(info.Num/maxNum)
	local selectCountView = require("common.SelectCountView"):create({
		currSelCount = 1,
		maxCount = maxSelNum,
		viewSize = cc.size(500, 200),
		changeCallback = function(selCount)
			self.mSelCount = selCount
		end
		})
	selectCountView:setPosition(bgSize.width * 0.5, bgSize.height * 0.28)
	popbgSprite:addChild(selectCountView)

	--合成按钮
	local composeBtn = ui.newButton({
		text = TR("合成"),
		normalImage = "c_28.png",
		clickAction = function ()
			self:requestCompose(info, self.mSelCount * maxNum)
			LayerManager.removeLayer(self.mPopLayer)
		end
		})
	composeBtn:setPosition(bgSize.width * 0.5, bgSize.height * 0.12)
	popbgSprite:addChild(composeBtn)
end

-- 获取对应类的包裹的信息
function BagEquipDebrisLayer:getPlayerBagInfo()
    local bagModelId = BagType.eEquipDebrisBag
    local playerTypeInfo = {}
    for i, v in ipairs(BagInfoObj:getAllBagInfo()) do
        if v.BagModelId == bagModelId then
            playerTypeInfo = v
            break
        end
    end
    return playerTypeInfo
end

-- 得到对用type的包裹物品的数量
function BagEquipDebrisLayer:getItemCount()
    local dataCount = #GoodsObj:getEquipDebrisList()
    return dataCount
end

-- 获取装备数据
function BagEquipDebrisLayer:getItemData()
	local equipData = clone(GoodsObj:getEquipDebrisList())

	local selectColor = {}
	for i,v in ipairs(self.mSelectStatus) do
		if v then
			table.insert(selectColor, i)
		end
	end
	local finalList = {}
	if next(selectColor) == nil then
		for i,v in ipairs(equipData) do
			table.insert(finalList, v)
		end
	else
		for _,v in ipairs(equipData) do
			local colorLv = Utility.getQualityColorLv(GoodsModel.items[v.ModelId].quality)
			for m,n in ipairs(selectColor) do
				if n == colorLv then
					table.insert(finalList, v)
				end
			end
		end
	end

	table.sort(finalList, function (a, b)
		--是否可以合成
		local isFullA = a.Num >= GoodsModel.items[a.ModelId].maxNum and true or false
		local isFullB = b.Num >= GoodsModel.items[b.ModelId].maxNum and true or false
		if isFullA ~= isFullB then
			return isFullA
		end
		--资质
		local qualityA = GoodsModel.items[a.ModelId].quality
		local qualityB = GoodsModel.items[b.ModelId].quality
		if qualityA ~= qualityB then
			return qualityA > qualityB
		end
		--碎片数量
		if a.Num ~= b.Num then
			return a.Num > b.Num
		end
		--模型ID
		return a.ModelId > b.ModelId
	end)

	return finalList
end
--============================================网络相关============================================
function BagEquipDebrisLayer:requestCompose(data, num)
	HttpClient:request({
       moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, num},
        callback = function (response)
	        if response.Status ~= 0 then
	        	return
	        end
        	-- if self.mPopLayer then
        	-- 	self.mPopLayer:removeFromParent()
        	-- 	self.mPopLayer = nil
        	-- end
            self:refreshList()
            self:showBagCount()
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
      --   	LayerManager.addLayer({
      --   		name = "bag.EquipDebrisComposeLayer",
	    	-- 	data = {
	    	-- 		baseGetGameResourceList = response.Value and response.Value.BaseGetGameResourceList or {}
	    	-- 	},
	    	-- 	cleanUp = false,
    		-- })
        end
    })
end


-- 请求当前兑换信息
function BagEquipDebrisLayer:requestExchange(modelId, propNum)
	HttpClient:request({
        moduleName = "BddEquipExchangeInfo",
        methodName = "Exchange",
        svrMethodData = {modelId, propNum},
        callback = function(response)
            if not response or response.Status ~= 0 then
                 return
            end
            self:refreshList()
            self:showBagCount()
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end

--一键兑换
function BagEquipDebrisLayer:requestOneKeyExchange()
	HttpClient:request({
       moduleName = "BddEquipExchangeInfo",
        methodName = "ExchangeOneKey",
        svrMethodData = {self.mFristChooseTag},
        callback = function (response)
        	dump(response)
	        if response.Status ~= 0 then
	        	return
	        end
	        self:refreshList()
            self:showBagCount()
	        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	    end
    })
end

return BagEquipDebrisLayer
