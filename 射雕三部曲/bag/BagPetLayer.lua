--[[
	文件名：BagPetLayer.lua
	描述：外功背包界面
	创建人：lengjiazhi
	创建时间： 2017.4.21
--]]

local BagPetLayer = class("BagPetLayer",function (params)
	return display.newLayer()
end)

function BagPetLayer:ctor(params)
	self.mSelectId = params and params.selectId 
    self.mParent = params.parent 
    self.mDataList = {}
    self.mViewPos = params.viewPos 

    -- 包裹空间文字背景图片
    local countBack = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    countBack:setPosition(540, 940)
    self:addChild(countBack)

    countWordLabel = ui.newLabel({
        text = TR("包裹空间"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    countWordLabel:setAnchorPoint(cc.p(0, 0.5))
    countWordLabel:setPosition(390, 940)
    self:addChild(countWordLabel)

    local underGaryBgSprite = ui.newScale9Sprite("c_24.png", cc.size(626, 660))
    underGaryBgSprite:setPosition(320, 578)
    self:addChild(underGaryBgSprite)

    self:refreshGrid()
end

-- 显示包裹数量
function BagPetLayer:showBagCount()

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
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    -- self.mCountLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mCountLabel:setPosition(540, 940)
    self:addChild(self.mCountLabel)

    --扩充按钮
    self.mBuyBtn = ui.newButton({
        -- text = TR("扩充"),
        normalImage = "gd_27.png",
        position = cc.p(600, 940),
        -- size = cc.size(125, 57),
        clickAction = function()
            MsgBoxLayer.addExpandBagLayer(BagType.ePetBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    -- self.mBuyBtn:setScale(0.7)
    self:addChild(self.mBuyBtn)
    local bagTypeInfo = BagModel.items[BagType.ePetBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.ePetBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.ePetBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if self:getItemCount(BagType.ePetBag) == 0 then
        local sp = ui.createEmptyHint(TR("暂无外功秘籍"))
        sp:setPosition(320, 568)
        self:addChild(sp)

        local gotoBtn = ui.newButton({
            text = TR("去获取"),
            normalImage = "c_28.png",
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eExpedition)
            end
            })
        gotoBtn:setPosition(320, 400)
        self:addChild(gotoBtn)
    end
end

-- 根据所选择的card显示相应的属性
function BagPetLayer:showAttrLabel(data)
	if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self:addChild(self.mAttrSprite)

    --外功
    if data.ModelId and math.floor(data.ModelId / 10000) == ResourcetypeSub.ePet then
    	local petAttrInfo = Utility.getPetAttrs(PetObj:getPet(data.Id))
        local tempToPercent = {}
        for k,v in pairs(petAttrInfo) do
            table.insert(tempToPercent, k , v)
            local needPercent = ConfigFunc:fightAttrIsPercentByValue(k)
            if needPercent then
                local tempV = tostring(tonumber(v) / 100) .. "%"
                table.insert(tempToPercent, k , tempV)
            end
        end
        -- dump(tempToPercent)

        local attrs
        if FormationObj:petInFormation(data.Id) then
            attrs = {CardShowAttr.eBorder, CardShowAttr.eBattle, CardShowAttr.eStep}
        else
            attrs = {CardShowAttr.eBorder, CardShowAttr.eStep}
        end

        -- 装备于哪个英雄
        local _, info = FormationObj:petInFormation(data.Id)
        if info then
            local slotInfo = FormationObj:getSlotInfoBySlotId(info)

            local heroDetialInfo = HeroObj:getHero(slotInfo.HeroId)
            local infoHeroName 
            if heroDetialInfo and heroDetialInfo.IllusionModelId ~= 0 then
                infoHeroName = IllusionModel.items[heroDetialInfo.IllusionModelId].name
            else
                infoHeroName = HeroModel.items[slotInfo.ModelId].name
            end
            local heroModel = HeroModel.items[slotInfo.ModelId]

            local nameColor = Utility.getQualityColor(heroModel.quality, 2)
            local infoHeroLabel = ui.newLabel({
                text = TR("[装备于%s%s%s]", nameColor, infoHeroName, "#46220D"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
                anchorPoint = cc.p(0, 1),
                dimensions = cc.size(300, 0),
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            })
            infoHeroLabel:setPosition(110, 30)
            self.mAttrSprite:addChild(infoHeroLabel)
        end
        --头像
        local card = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.ePet,
            instanceData = data,
            cardShowAttrs = attrs,
        })
        card:setPosition(55, 65)
        card:setCardLevel(data.Lv)
        self.mAttrSprite:addChild(card)

        --名字
        local nameLab = ui.newLabel({
            text = TR(PetModel.items[data.ModelId].name),
            size = 22,
            color = Utility.getQualityColor(PetModel.items[data.ModelId].quality, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            anchorPoint = cc.p(0, 1),
            dimensions = cc.size(300, 0),
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        })
        nameLab:setPosition(110, 113)
        self.mAttrSprite:addChild(nameLab)

        local attrLabelList = {}
        local startPosX = 110
        local startPosY = 70
        for i,v in pairs(tempToPercent) do
        	local attrLabel = ui.newLabel({
        		text = TR("%s +%s%s",FightattrName[i], Enums.Color.eDarkGreenH, v),
        		color = Enums.Color.eBlack,
                size = 18,
        		})
        	attrLabel:setAnchorPoint(0, 0.5)
        	table.insert(attrLabelList, attrLabel)
        	-- self.mAttrSprite:addChild(attrLabel)
        end
        local attrListView = ccui.ListView:create()
        attrListView:setDirection(ccui.ScrollViewDir.vertical)
        attrListView:setBounceEnabled(true)
        attrListView:setContentSize(cc.size(450, 50))
        attrListView:setGravity(ccui.ListViewGravity.centerHorizontal)
        attrListView:setAnchorPoint(cc.p(0.5, 1))
        attrListView:setPosition(260, 85)
        self.mAttrSprite:addChild(attrListView)

        local attrLabels = {}
        local tempAttrLabel = {}
        for i,v in ipairs(attrLabelList) do
            table.insert(tempAttrLabel, v)
            if i%3 == 0 then
                table.insert(attrLabels, tempAttrLabel)
                tempAttrLabel = {}
            end
        end
        if #tempAttrLabel ~= 0 then
            table.insert(attrLabels, tempAttrLabel)
        end    
        for i = 1, #attrLabels do
            local layout = ccui.Layout:create()
            layout:setContentSize(280, 20)
            for i,v in ipairs(attrLabels[i]) do
                v:setPosition((i-1)* 120, 10)
                layout:addChild(v)
            end

            attrListView:pushBackCustomItem(layout)
        end

        --升级按钮
        local lvUpBtn = ui.newButton({
        	text = TR("升级"),
        	normalImage = "c_28.png",
        	clickAction = function ()
                local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                self.mParent.mThirdSubTag = BagType.ePetBag
                self.mParent.selectId = data.Id
                self.mParent.viewPos = viewPos
        		LayerManager.addLayer({
                    name = "pet.PetUpgradeLayer",
                    data = {
                        petList = {data},
                        currIndex = 1,
                    },
                })
                -- local tempStr = "bag.BagLayer"
                -- local tempData = LayerManager.getRestoreData(tempStr)
                -- tempData.subPageType = BagType.eZhenjue
                -- tempData.thirdSubTag = BagType.ePetBag
                -- tempData.selectId = data.Id
                -- tempData.viewPos = viewPos
                -- LayerManager.setRestoreData(tempStr, tempData)
        	end,
        })
        lvUpBtn:setPosition(550, 65)
        self.mAttrSprite:addChild(lvUpBtn)

        --参悟按钮
        if PetModel.items[data.ModelId].quality > 3 then
        	local learnBtn = ui.newButton({
        		text = TR("参悟"),
        		normalImage = "c_28.png",
        		clickAction = function ()
                    local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    self.mParent.mThirdSubTag = BagType.ePetBag
                    self.mParent.selectId = data.Id
                    self.mParent.viewPos = viewPos
    			    LayerManager.addLayer({
                        name = "pet.PetUpgradeLayer",
                        data = {
                            petList = {data},
                            currIndex = 1,
                            pageType = ModuleSub.ePetActiveTal,
                        },
                    })
                    -- local tempStr = "bag.BagLayer"
                    -- local tempData = LayerManager.getRestoreData(tempStr)
                    -- tempData.subPageType = BagType.eZhenjue
                    -- tempData.thirdSubTag = BagType.ePetBag
                    -- tempData.selectId = data.Id
                    -- tempData.viewPos = viewPos
                    -- LayerManager.setRestoreData(tempStr, tempData)
                end,
    		    })
        	learnBtn:setPosition(550, 32)
        	lvUpBtn:setPosition(550, 94)
        	self.mAttrSprite:addChild(learnBtn)
        	--穿透问题
        	learnBtn:setPropagateTouchEvents(false)
        end
    	--穿透问题
        lvUpBtn:setPropagateTouchEvents(false)
    --宠物碎片
    else
    	local needNum = GoodsModel.items[data.ModelId].maxNum
        local nowNum = data.Num

        local canHc = false
        if nowNum >= needNum then
            canHc = true
        end

        local att = {CardShowAttr.eBorder, CardShowAttr.eDebris}
        local card = CardNode.createCardNode({
            instanceData = data,
            cardShowAttrs = att,
        })
        card:setPosition(55, 65)
        self.mAttrSprite:addChild(card)
        if canHc then
            card:setSyntheticMark()
        end

        local nameLab = ui.newLabel({
            text = TR(GoodsModel.items[data.ModelId].name),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            size = 22,
            color = Utility.getQualityColor(GoodsModel.items[data.ModelId].quality, 1),
            anchorPoint = cc.p(0, 1),
            dimensions = cc.size(300, 0),
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        })

        nameLab:setPosition(110, 113)
        self.mAttrSprite:addChild(nameLab)

        -- 数量
        local numLabel = ui.newLabel({
            text = TR("数量: %d/%d", nowNum, needNum)..(canHc and TR("(已满)") or TR("(数量不足)")),
            size = 20,
            color = canHc and Enums.Color.eDarkGreen or Enums.Color.eDarkGreen,
        })
        numLabel:setAnchorPoint(cc.p(0, 1))
        numLabel:setPosition(120, 70)
        self.mAttrSprite:addChild(numLabel)

        if canHc then
            local upgradeBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                text = TR("合 成"),
                clickAction = function ()
                    self:requestUpgrade(data, nowNum)
                end
                })
            self.mAttrSprite:addChild(upgradeBtn)
            -- 穿透问题
            upgradeBtn:setPropagateTouchEvents(false)

        else
            -- 去获取
            local getBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                text = TR("去获取"),
                clickAction = function ()
                    local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    self.mParent.mThirdSubTag = BagType.ePetBag
                    self.mParent.selectId = data.Id
                    self.mParent.viewPos = viewPos
                    if not ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
                        return
                    end
                    LayerManager.showSubModule(ModuleSub.eExpedition)
                end
                })
            self.mAttrSprite:addChild(getBtn)
            getBtn:setPropagateTouchEvents(false)
        end
    end


end

--刷新
function BagPetLayer:refreshGrid()
	self:showBagCount()

    -- 清空之前的显示列表
    if self.mGridView then
        self.mGridView:removeFromParent()
        self.mGridView = nil
    end

    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end

    -- 得到对应包裹里的数据
    self.mDataList = self:getItemData()
    local isPetDebris

    if #self.mDataList > 0 then
        self.mGridView = require("common.GridView"):create({
        viewSize = cc.size(640, 645),
        colCount = 5,
        celHeight = 114,
        selectIndex = 1,
        needDelay = true,
        getCountCb = function()
            return #self.mDataList
        end,
        createColCb = function(itemParent, colIndex, isSelected)
            local attrs = {CardShowAttr.eBorder}

            isPetDebris = false
            local isGoods = (Utility.getTypeByModelId(self.mDataList[colIndex].ModelId) == ResourcetypeSub.ePetDebris)
            if not isGoods then
            	table.insert(attrs, CardShowAttr.eLevel, CardShowAttr.eStep)
                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                    if PetObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                        PetObj:getNewIdObj():clearNewId(self.mDataList[colIndex].Id)
                        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagPets)
                    end
                end

                if PetObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eNewCard)
                end
                if FormationObj:petInFormation(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eBattle)
                end
            elseif isGoods then
                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                    if GoodsObj:getNewPetDebrisIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                        GoodsObj:getNewPetDebrisIdObj():clearNewId(self.mDataList[colIndex].Id)
                        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagPets)
                    end
                end

                table.insert(attrs, CardShowAttr.eDebris, CardShowAttr.eNum)
                isPetDebris = true
                if GoodsObj:getNewPetDebrisIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eNewCard)
                end
            end
            -- 创建显示图片
            local card, Attr = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.ePet,
                instanceData = self.mDataList[colIndex],
                cardShowAttrs = attrs,
                onClickCallback = function()
                    self:showAttrLabel(self.mDataList[colIndex])
                    self.mGridView:setSelect(colIndex)
                    self.mSelectId = self.mDataList[colIndex].Id
                end,
            })
            if isPetDebris then
                local needNum = GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum
                local nowNum = self.mDataList[colIndex].Num
                Attr[CardShowAttr.eNum].label:setString(string.format("%d/%d",nowNum,needNum))
                if self.mDataList[colIndex].Num >=
                    GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum then
                    card:setSyntheticMark()
                end
            else
                card:setCardLevel(self.mDataList[colIndex].Lv)
            end
            card:setPosition(64, 60)
            itemParent:addChild(card)
        end,
        })

        self.mGridView:setPosition(320, 580)
        self:addChild(self.mGridView)

        local selIndex = 1
        for index, value in ipairs(self.mDataList) do
            if value.Id == self.mSelectId then
                selIndex = index
            end
        end
        self.mGridView:setSelect(selIndex)
        self:showAttrLabel(self.mDataList[selIndex])
        if selIndex == 1 then
            self.mViewPos = nil
        end
        if self.mViewPos then
            self.mGridView.mScrollView:getInnerContainer():setPosition(self.mViewPos)
        end
    end
end
--------------------数据处理-------------------------
-- 获取对应类的包裹的信息
function BagPetLayer:getPlayerBagInfo(bType)
    local bagModelId = bType
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
function BagPetLayer:getItemCount()
    local dataCount = #PetObj:getPetList() + #GoodsObj:getPetDebrisList()
    return dataCount
end

--得到对应数据和背包控件的类型
function BagPetLayer:getItemData()
	local function getQuality(cellItem)
		if Utility.getTypeByModelId(cellItem.ModelId) == ResourcetypeSub.ePet then
            return PetModel.items[cellItem.ModelId].quality
        elseif Utility.getTypeByModelId(cellItem.ModelId) == ResourcetypeSub.ePetDebris then
            return GoodsModel.items[cellItem.ModelId].quality
        end
	end
    local itemData
	local petdataList = clone(PetObj:getPetList())
	local petDebrisList = clone(GoodsObj:getPetDebrisList())

	table.insertto(petdataList, petDebrisList, -1)
	table.sort(petdataList, function (a, b)
		local isGoodA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.ePetDebris and true or false
		local isGoodB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.ePetDebris and true or false
		local isPetA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.ePet and true or false
		local isPetB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.ePet and true or false

        -- 可以合成的阵诀碎片排在最前面
        if isGoodA and GoodsModel.items[a.ModelId].maxNum == a.Num and (isPetB or GoodsModel.items[b.ModelId].maxNum ~= b.Num) then
            return true
        elseif isGoodB and GoodsModel.items[b.ModelId].maxNum == b.Num and (isPetA or GoodsModel.items[a.ModelId].maxNum ~= a.Num) then
            return false
        end

		--宠物排在碎片前面
		if isPetA and isGoodB then
			return true
		elseif isPetB and isGoodA then
			return false
		end

		if isPetA and isPetB then
            -- 上阵的阵诀排在未上阵的阵诀前面
            if FormationObj:petInFormation(a.Id) and not FormationObj:petInFormation(b.Id) then
                return true
            elseif not FormationObj:petInFormation(a.Id) and FormationObj:petInFormation(b.Id) then
                return false
            end
			--高品质宠物排前面
			if getQuality(a) ~= getQuality(b) then
				return getQuality(a) > getQuality(b)
			end
            --等级高的在前面
            if a.Lv ~= b.Lv then
                return a.Lv > b.Lv
            end
			return a.ModelId > b.ModelId
		elseif isGoodA and isGoodB then
			--高品质碎片排前面
           	if getQuality(a) ~= getQuality(b) then
                return getQuality(a) > getQuality(b)
            end

            --比较数量
            if a.Num ~= b.Num then
            	return a.Num > b.Num
            end

            --比较模型Id
            if a.ModelId ~= b.ModelId then
            	return a.ModelId < b.ModelId
            end

            return a.Id < b.Id
		end
	end)
	itemData = petdataList
	return itemData
end
-------------------------------网络请求-------------------------
-- 宠物碎片合成
function BagPetLayer:requestUpgrade(data, num)
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, num},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            self:refreshGrid()
            --MsgBoxLayer.addGameDropLayer(msgText, title, baseDrop, extraDrop, okBtnInfo, closeBtnInfo, needCloseBtn)
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, " ", TR("合成"), {{text = TR("确定")}}, {})
        end
    })
end

return BagPetLayer
