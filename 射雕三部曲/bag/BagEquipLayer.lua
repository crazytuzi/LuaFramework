--[[
	文件名：BagEquipLayer.lua
	描述：装备子界面
	创建人：lengjiazhi
	创建时间：2017.5.9
--]]
local BagEquipLayer = class("BagEquipLayer", function (params)
	return display.newLayer()
end)


function BagEquipLayer:ctor(params)
	self.mParent = params.parent
	self.mSelectStatus = { --保存菜单选择状态
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
	}

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
	local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(622, 814))
    underBgSprite:setPosition(320, 910)
    underBgSprite:setAnchorPoint(0.5, 1)
    self:addChild(underBgSprite)

	self:showBagCount()
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
	self:addChild(selectBtn, 1000)
	local temp = true --控制展示或者关闭菜单
	local offset
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
			self.mSelBgSprite = ui.newScale9Sprite("zb_05.png", cc.size(82, 150)) --（82, 150）
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
					text = TR("%s品质",Utility.getColorName(i)),
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
                -- 透明按钮
                local touchBtn = ui.newButton({
                    normalImage = "c_83.png",
                    size = cc.size(138, 20),
                    clickAction = function()
                        if self.mSelectStatus[i] then
                            self.mSelectStatus[i] = false
                        else
                            self.mSelectStatus[i] = true
                        end
                        self:refreshList()
                        checkBtn:setCheckState(self.mSelectStatus[i])
                    end
                })
                touchBtn:setPosition(69, 10)
                layout:addChild(touchBtn)
				selectList:pushBackCustomItem(layout)
			end
		end

		self.mSelBgSprite:runAction(showAction)
	end)

end

--显示包裹空间
function BagEquipLayer:showBagCount()
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
            MsgBoxLayer.addExpandBagLayer(BagType.eEquipBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    self:addChild(self.mBuyBtn)
    -- self.mBuyBtn:setScale(0.8)
    local bagTypeInfo = BagModel.items[BagType.eEquipBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eEquipBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eEquipBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if self:getItemCount(BagType.eEquipBag) == 0 then
        local sp = ui.createEmptyHint(TR("没有装备！"))
        sp:setPosition(320, 500)
        self:addChild(sp)
    end
end
-- 刷新装备列表
function BagEquipLayer:refreshList()
	self.mData = self:getItemData()

	if self.mEquipList then
		self.mEquipList:removeFromParent()
		self.mEquipList = nil
	end

	self.mEquipList = ccui.ListView:create()
	self.mEquipList:setPosition(320, 906)
	self.mEquipList:setAnchorPoint(0.5, 1)
	self.mEquipList:setContentSize(630, 800)
	-- self.mEquipList:setItemsMargin(5)
	self.mEquipList:setDirection(ccui.ScrollViewDir.vertical)
	self.mEquipList:setBounceEnabled(true)
	self:addChild(self.mEquipList)

	for i,v in ipairs(self.mData) do
		self.mEquipList:pushBackCustomItem(self:createItem(i))
	end
end
-- 创建单个装备条目
function BagEquipLayer:createItem(index)
	local tempInfo = self.mData[index]
	local layout = ccui.Layout:create()
	layout:setContentSize(626, 130)
	--背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 122))
	bgSprite:setPosition(315, 65)
	layout:addChild(bgSprite)
	--前往按钮
	local lvUpBtn = ui.newButton({
		text = TR("前往培养"),
		normalImage = "c_28.png",
		clickAction = function ()
			self.mParent.mThirdSubTag = BagType.eEquipBag
			LayerManager.addLayer({
                name = "equip.EquipUpLayer",
                data = {
                    equipId = tempInfo.Id,
                    defaultTag = ModuleSub.eEquipLvUp,
                },
            })
		end
		})
	lvUpBtn:setPosition(539, 65)
	layout:addChild(lvUpBtn)
	--头像
	local attrs
    local isIn = FormationObj:equipInFormation(tempInfo.Id)
    if isIn then
        if tempInfo.Lv > 0 then
            attrs = {CardShowAttr.eBorder, CardShowAttr.eBattle, CardShowAttr.eLevel}
        else
            attrs = {CardShowAttr.eBorder, CardShowAttr.eBattle}
        end
    else
        if tempInfo.Lv > 0 then
            attrs = {CardShowAttr.eBorder, CardShowAttr.eLevel}
        else
            attrs = {CardShowAttr.eBorder}
        end
    end
	local card = CardNode.createCardNode({
        instanceData = tempInfo,
        cardShowAttrs = attrs,
		})
	card:setPosition(84, 65)
	layout:addChild(card)
	--名字
	local nameStr = EquipModel.items[tempInfo.ModelId].name
	if tempInfo.Step > 0 then
		nameStr = nameStr..string.format(" + %d", tempInfo.Step)
	end
	local nameColor = Utility.getQualityColor(EquipModel.items[tempInfo.ModelId].quality, 1)
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

    -- 装备于哪个英雄
    local _, info = FormationObj:equipInFormation(tempInfo.Id)
    if info then
        local slotInfo = FormationObj:getSlotInfoBySlotId(info)
        local heroDetialInfo = HeroObj:getHero(slotInfo.HeroId)
        local infoHeroName 
        if heroDetialInfo and heroDetialInfo.IllusionModelId ~= 0 then
            infoHeroName = IllusionModel.items[heroDetialInfo.IllusionModelId].name
        else
            infoHeroName = HeroModel.items[slotInfo.ModelId].name
        end

        local infoHeroQualityColor = Utility.getQualityColor(HeroModel.items[slotInfo.ModelId].quality, 2)
        local infoHeroLabel = ui.newLabel({
            text = TR("[装备于%s%s%s]", infoHeroQualityColor, infoHeroName, "#46220D"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
            anchorPoint = cc.p(0, 1),
            dimensions = cc.size(350, 0),
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        })
        infoHeroLabel:setPosition(145, 40)
        layout:addChild(infoHeroLabel)
    end
    --星星
    local star = Figure.newEquipStarLevel({
	 	guid = tempInfo.Id,
	 	})
    if star then
    	star:setPosition(140, 65)
    	layout:addChild(star)
	 	star:setAnchorPoint(0, 0.5)
    end

	return layout
end

-- 获取对应类的包裹的信息
function BagEquipLayer:getPlayerBagInfo()
    local bagModelId = BagType.eEquipBag
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
function BagEquipLayer:getItemCount()
    local dataCount = #EquipObj:getEquipList()
    return dataCount
end

-- 获取装备数据
function BagEquipLayer:getItemData()
	local equipData = clone(EquipObj:getEquipList())

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
			local colorLv = Utility.getQualityColorLv(EquipModel.items[v.ModelId].quality)
			for m,n in ipairs(selectColor) do
				if n == colorLv then
					table.insert(finalList, v)
				end
			end
		end
	end


	table.sort(finalList, function (a, b)
		local isInA = FormationObj:equipInFormation(a.Id)
		local isInB = FormationObj:equipInFormation(b.Id)
		--上阵
		if isInA ~= isInB then
			return isInA
		end
		--资质
		local qualityA = EquipModel.items[a.ModelId].quality
		local qualityB = EquipModel.items[b.ModelId].quality
		if qualityA ~= qualityB then
			return qualityA > qualityB
		end
		--强化星级
		if a.Step ~= b.Step then
			return a.Step > b.Step
		end
		--等级
		if a.Lv ~= b.Lv then
			return a.Lv > b.Lv
		end
		--模型ID
		return a.ModelId > b.ModelId
	end)

	return finalList
end


return BagEquipLayer
