--[[
	文件名：BagTreasureLayer.lua
	描述：神兵包裹界面
	创建人：yanxingrui
    修改人：lengjiazhi
	创建时间： 2016.6.25
--]]

local BagTreasureLayer = class("BagTreasureLayer", function(params)
	return display.newLayer()
end)

-- 构造函数，初始化本页面需要的数据并刷新表格
function BagTreasureLayer:ctor(params)

    self.mSelectId = params and params.selectId 
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
function BagTreasureLayer:showBagCount()

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
            MsgBoxLayer.addExpandBagLayer(BagType.eTreasureBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    self:addChild(self.mBuyBtn)
    -- self.mBuyBtn:setScale(0.7)
    local bagTypeInfo = BagModel.items[BagType.eTreasureBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eTreasureBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eTreasureBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if self:getItemCount(BagType.eTreasureBag) == 0 then
        local sp = ui.createEmptyHint(TR("暂无神兵"))
        sp:setPosition(320, 568)
        self:addChild(sp)

        local gotoBtn = ui.newButton({
            text = TR("去锻造"),
            normalImage = "c_28.png",
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eChallengeGrab)
            end
            })
        gotoBtn:setPosition(320, 400)
        self:addChild(gotoBtn)
    end
end

-- 根据所选择的card显示相应的属性
function BagTreasureLayer:showAttrLabel(data)

    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self:addChild(self.mAttrSprite)

    local name, intro, col, attrs, quality
    local isIn = FormationObj:equipInFormation(data.Id)
    local ResType = Utility.getTypeByModelId(data.ModelId)
    if isIn then
        if data.Lv > 0 then
            attrs = {CardShowAttr.eBorder, CardShowAttr.eBattle, CardShowAttr.eLevel, CardShowAttr.eStep}
        else
            attrs = {CardShowAttr.eBorder, CardShowAttr.eBattle, CardShowAttr.eStep}
        end
    else
        if data.Lv > 0 then
            attrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep}
        else
            attrs = {CardShowAttr.eBorder, CardShowAttr.eStep}
        end
    end
    -- 神兵进阶数
    name = TreasureModel.items[data.ModelId].name
    if data.Step > 0 then
        name = name..string.format(" + %d", data.Step)
    end
    intro = ConfigFunc:getTreasureBaseViewItem(data.ModelId, data.Lv)
    col = Utility.getQualityColor(TreasureModel.items[data.ModelId].quality, 1)
    quality = TreasureModel.items[data.ModelId].quality

    -- local tempModelData = ConfigFunc:getTreasureBaseViewItem(data.ModelId, data.Lv)
    -- for i,v in ipairs(tempModelData) do
    --     local attrLabel = ui.newLabel({
    --     text = string.format("%s%s", v.name, v.value),
    --     size = 19,
    --     anchorPoint = cc.p(0, 1),
    --     dimensions = cc.size(350, 0),
    --     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    --     })
    --     attrLabel:setPosition(115+(i - 1) * 100, 55)
    --     self.mAttrSprite:addChild(attrLabel)
    -- end
    --星星
    local colorLv = Utility.getColorLvByModelId(data.ModelId)
    local starSprite = ui.newStarLevel(colorLv)
    starSprite:setAnchorPoint(0,1)
    starSprite:setPosition(115, 75)
    self.mAttrSprite:addChild(starSprite)

    local card = CardNode.createCardNode({
        instanceData = data,
        cardShowAttrs = attrs,
    })
    card:setPosition(55, 65)
    self.mAttrSprite:addChild(card)

    local nameLab = ui.newLabel({
        text = name,
        size = 22,
        color = col,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        anchorPoint = cc.p(0, 1),
        dimensions = cc.size(350, 0),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    })
    nameLab:setPosition(115, 113)
    self.mAttrSprite:addChild(nameLab)

    -- 装备于哪个英雄
    local _, info = FormationObj:equipInFormation(data.Id)
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
        infoHeroLabel:setPosition(115, 35)
        self.mAttrSprite:addChild(infoHeroLabel)
    end

    -- 强化按钮
    local levelUpBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(550, 65),
        --size = cc.size(135,57),
        text = TR("强 化"),
        clickAction = function(sender)
            local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
            if TreasureModel.items[data.ModelId].maxStep == 0 and
                TreasureModel.items[data.ModelId].maxLv == 0 then
                ui.showFlashView(TR("此神兵不能强化"))
            else
                LayerManager.addLayer({
                    name = "equip.TreasureUpLayer",
                    data = {
                        treasureId = data.Id,
                        subPageType = ModuleSub.eTreasureLvUp,
                    },
                })
            end

            local tempStr = "bag.BagLayer"
            local tempData = LayerManager.getRestoreData(tempStr)
            tempData.subPageType = BagType.eTreasureBag
            tempData.selectId = data.Id
            -- tempData.viewPos = viewPos   
            LayerManager.setRestoreData(tempStr, tempData)
        end
    })
    self.mAttrSprite:addChild(levelUpBtn)
    -- 穿透问题
    levelUpBtn:setPropagateTouchEvents(false)

    -- --合成按钮
    -- local tupoBtn = ui.newButton({
    --     normalImage = "c_28.png",
    --     text = TR("合 成"),
    --     position = cc.p(550, 37),
    --     --size = cc.size(135,57),
    --     clickAction = function (sender)
    --   --       local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
    -- 		-- LayerManager.addLayer({
    --   --       	name = "compose.ComposeLayer",
    --   --       	data = {
    --   --       		moduleSub = ModuleSub.eTreasureCompare,
    --   --       	},
    --   --       })

    --   --       local tempStr = "bag.BagLayer"
    --   --       local tempData = LayerManager.getRestoreData(tempStr)
    --   --       tempData.subPageType = BagType.eTreasureBag
    --   --       tempData.selectId = data.Id
    --   --       tempData.viewPos = viewPos
    --   --       LayerManager.setRestoreData(tempStr, tempData)
    --     end
    -- })
    -- self.mAttrSprite:addChild(tupoBtn)

    -- -- 穿透问题
    -- tupoBtn:setPropagateTouchEvents(false)

end

-- 刷新显示列表
function BagTreasureLayer:refreshGrid()
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

            local attrs = {CardShowAttr.eBorder, CardShowAttr.eStep}

            if FormationObj:equipInFormation(self.mDataList[colIndex].Id) then
                table.insert(attrs, CardShowAttr.eBattle)
            end
            if isSelected then
                table.insert(attrs, CardShowAttr.eSelected)
                if TreasureObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    TreasureObj:getNewIdObj():clearNewId(self.mDataList[colIndex].Id)
                    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagTreasure)
                end
            end

            if TreasureObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                table.insert(attrs, CardShowAttr.eNewCard)
            end

            if self.mDataList[colIndex].Lv > 0 then
                table.insert(attrs, CardShowAttr.eLevel)
            end

            -- 创建显示图片
            local card, Attr = CardNode.createCardNode({
                instanceData = self.mDataList[colIndex],
                cardShowAttrs = attrs,
                onClickCallback = function()
                    self:showAttrLabel(self.mDataList[colIndex])
                    self.mGridView:setSelect(colIndex)
                    self.mSelectId = self.mDataList[colIndex].Id
                end,
            })
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

-- 获取对应类的包裹的信息
function BagTreasureLayer:getPlayerBagInfo()
    local bagModelId = BagType.eTreasureBag
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
function BagTreasureLayer:getItemCount()
    local dataCount = #TreasureObj:getTreasureList()
    print(dataCount,"测试包裹数量")
    return dataCount
end

--得到对应数据和背包控件的类型
function BagTreasureLayer:getItemData()
    local function getQuality(cellData)
        local ResType = Utility.getTypeByModelId(cellData.ModelId)
		if cellData.ModelId and Utility.isEquip(ResType) then
            return EquipModel.items[cellData.ModelId].quality
        elseif cellData.ModelId and Utility.isTreasure(ResType) then
            return TreasureModel.items[cellData.ModelId].quality
        end
    end

    function dataSort(data)
        -- 排序
        table.sort(data, function(a, b)
            -- 上阵的排在前面
            local isIna = FormationObj:equipInFormation(a.Id)
            local isInb = FormationObj:equipInFormation(b.Id)
            if isIna ~= isInb then
                return isIna
            end

            -- 比较资质
            local qualitya = getQuality(a)
            local qualityb = getQuality(b)
            if qualitya ~= qualityb then
                return qualitya > qualityb
            end

            -- 比较进阶
            if a.Step ~= b.Step then
                return a.Step > b.Step
            end

            -- 比较等级
            if a.Lv ~= b.Lv then
                return a.Lv > b.Lv
            end

            -- 最后比较模型Id
            local modelIda = a.ModelId
            local modelIdb = b.ModelId
            if modelIda ~= modelIdb then
                return modelIda > modelIdb
            end

            return a.Id < b.Id
        end)
    end

    local itemData

    -- local equipTreasureTab = clone(EquipObj:getEquipList())
    local treasureTab = clone(TreasureObj:getTreasureList())

    -- dataSort(equipTreasureTab)
    dataSort(treasureTab)

    -- table.insertto(equipTreasureTab, treasureTab, -1)

    itemData = treasureTab
    return itemData
end

-- -- 关闭该页面时执行函数
-- function BagTreasureLayer:onExit()
--     EquipObj:getNewIdObj():clearNewId()
--     TreasureObj:getNewIdObj():clearNewId()
-- end

return BagTreasureLayer
