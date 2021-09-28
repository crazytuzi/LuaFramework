--[[
	文件名：BagFashionLayer.lua
	描述：时装碎片背包界面
	创建人：lengjiazhi
	创建时间： 2018.3.9
--]]

local BagFashionLayer = class("BagFashionLayer",function (params)
	return display.newLayer()
end)

function BagFashionLayer:ctor(params)
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
function BagFashionLayer:showBagCount()

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
            MsgBoxLayer.addExpandBagLayer(BagType.eFashionBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    -- self.mBuyBtn:setScale(0.7)
    self:addChild(self.mBuyBtn)
    local bagTypeInfo = BagModel.items[BagType.eFashionBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eFashionBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eFashionBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if self:getItemCount(BagType.eFashionBag) == 0 then
        local sp = ui.createEmptyHint(TR("暂无绝学碎片"))
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
function BagFashionLayer:showAttrLabel(data)
	if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self:addChild(self.mAttrSprite)

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
                self.mParent.mThirdSubTag = BagType.eFashionBag
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

--刷新
function BagFashionLayer:refreshGrid()
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
    local isPetDebris = true

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
            local attrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

            if isSelected then
                table.insert(attrs, CardShowAttr.eSelected)
            end

            -- table.insert(attrs, CardShowAttr.eDebris, CardShowAttr.eNum)

            -- if GoodsObj:getNewPetDebrisIdObj():IdIsNew(self.mDataList[colIndex].Id) then
            --     table.insert(attrs, CardShowAttr.eNewCard)
            -- end
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

            local needNum = GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum
            local nowNum = self.mDataList[colIndex].Num
            Attr[CardShowAttr.eNum].label:setString(string.format("%d/%d",nowNum,needNum))
            if self.mDataList[colIndex].Num >=
                GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum then
                card:setSyntheticMark()
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
function BagFashionLayer:getPlayerBagInfo(bType)
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
function BagFashionLayer:getItemCount()
    local dataCount = #(GoodsObj:getFashionDebrisList())
    return dataCount
end

--得到对应数据和背包控件的类型
function BagFashionLayer:getItemData()
	local function getQuality(cellItem)
		if Utility.getTypeByModelId(cellItem.ModelId) == ResourcetypeSub.ePet then
            return PetModel.items[cellItem.ModelId].quality
        elseif Utility.getTypeByModelId(cellItem.ModelId) == ResourcetypeSub.ePetDebris then
            return GoodsModel.items[cellItem.ModelId].quality
        end
	end
    local itemData

    fashionDebrisData = clone(GoodsObj:getFashionDebrisList())

	table.sort(fashionDebrisData, function (a, b)
        local canComposeA = GoodsModel.items[a.ModelId].maxNum == a.Num
        local canComposeB = GoodsModel.items[b.ModelId].maxNum == b.Num

        -- 可以合成的阵诀碎片排在最前面
        if canComposeA ~= canComposeB then
            return canComposeA
        end

		--高品质碎片排前面
       	if GoodsModel.items[a.ModelId].quality ~= GoodsModel.items[b.ModelId].quality then
            return GoodsModel.items[a.ModelId].quality > GoodsModel.items[b.ModelId].quality
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

	end)
	itemData = fashionDebrisData
	return itemData
end
-------------------------------网络请求-------------------------
-- 碎片合成
function BagFashionLayer:requestUpgrade(data, num)
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, num},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            self:refreshGrid()
            FashionObj:refreshFashionList()
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, " ", TR("合成"), {{text = TR("确定")}}, {})
        end
    })
end

return BagFashionLayer
