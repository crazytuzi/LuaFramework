--[[
    文件名：BagImprintLayer.lua
    描述：宝石包裹界面
    创建人：yanghongsheng
    创建时间： 2019.5.29
--]]

local BagImprintLayer = class("BagImprintLayer", function(params)
    return display.newLayer()
end)

-- 构造函数，初始化本页面需要的数据并刷新表格
function BagImprintLayer:ctor(params)
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
function BagImprintLayer:showBagCount()

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
            MsgBoxLayer.addExpandBagLayer(BagType.eGemBag,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    self:addChild(self.mBuyBtn)
    -- self.mBuyBtn:setScale(0.7)
    local bagTypeInfo = BagModel.items[BagType.eGemBag]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eGemBag)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eGemBag), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    if self:getItemCount(BagType.eGemBag) == 0 then
        local sp = ui.createEmptyHint(TR("暂无宝石"))
        sp:setPosition(320, 568)
        self:addChild(sp)

        local gotoBtn = ui.newButton({
            text = TR("去冰火岛"),
            normalImage = "c_28.png",
            clickAction = function ()
                LayerManager.addLayer({name = "practice.PracticeLayer"})
            end
            })
        gotoBtn:setPosition(320, 400)
        self:addChild(gotoBtn)
    end
end

-- 根据所选择的card显示相应的属性
function BagImprintLayer:showAttrLabel(data)

    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self:addChild(self.mAttrSprite)

    local name, intro, col, attrs, quality
    local isIn = FormationObj:imprintInFormation(data.Id)
    local ResType = Utility.getTypeByModelId(data.ModelId)
    attrs = {CardShowAttr.eBorder, CardShowAttr.eLevel}
    if isIn then
       table.insert(attrs, CardShowAttr.eBattle) 
    end
    -- 神兵进阶数
    name = ImprintModel.items[data.ModelId].name
    intro = "暂无"
    col = Utility.getQualityColor(ImprintModel.items[data.ModelId].quality, 1)
    quality = ImprintModel.items[data.ModelId].quality
    --星星
    local colorLv = Utility.getColorLvByModelId(data.ModelId)
    local starSprite = ui.newStarLevel(ImprintModel.items[data.ModelId].stars)
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

    -- 强化按钮
    local imprintBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(550, 65),
        --size = cc.size(135,57),
        text = TR("去镶嵌"),
        clickAction = function(sender)
            LayerManager.addLayer({
                name = "hero.ImprintMainLayer",
            })

            local tempStr = "bag.BagLayer"
            local tempData = LayerManager.getRestoreData(tempStr)
            tempData.subPageType = BagType.eGemBag
            tempData.selectId = data.Id
            -- tempData.viewPos = viewPos   
            LayerManager.setRestoreData(tempStr, tempData)
        end
    })
    self.mAttrSprite:addChild(imprintBtn)
    -- 穿透问题
    imprintBtn:setPropagateTouchEvents(false)

    -- --合成按钮
    -- local tupoBtn = ui.newButton({
    --     normalImage = "c_28.png",
    --     text = TR("合 成"),
    --     position = cc.p(550, 37),
    --     --size = cc.size(135,57),
    --     clickAction = function (sender)
    --   --       local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
    --      -- LayerManager.addLayer({
    --   --         name = "compose.ComposeLayer",
    --   --         data = {
    --   --             moduleSub = ModuleSub.eTreasureCompare,
    --   --         },
    --   --       })

    --   --       local tempStr = "bag.BagLayer"
    --   --       local tempData = LayerManager.getRestoreData(tempStr)
    --   --       tempData.subPageType = BagType.eGemBag
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
function BagImprintLayer:refreshGrid()
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

            local attrs = {CardShowAttr.eBorder}

            if FormationObj:imprintInFormation(self.mDataList[colIndex].Id) then
                table.insert(attrs, CardShowAttr.eBattle)
            end
            if isSelected then
                table.insert(attrs, CardShowAttr.eSelected)
                if ImprintObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    ImprintObj:getNewIdObj():clearNewId(self.mDataList[colIndex].Id)
                    -- Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagTreasure)
                end
            end

            if ImprintObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
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
                    if self.mSelectId == self.mDataList[colIndex].Id then
                        MsgBoxLayer.showImprintIntroLayer({
                            imprintId = self.mSelectId,
                            lockCallback = function ()
                                self.mDataList = self:getItemData()
                                self.mGridView:refreshCell(colIndex)
                            end,
                        })
                        return
                    end
                    self:showAttrLabel(self.mDataList[colIndex])
                    self.mGridView:setSelect(colIndex)
                    self.mSelectId = self.mDataList[colIndex].Id
                end,
            })
            card:setPosition(64, 60)
            itemParent:addChild(card)

            -- 添加锁定图
            if self.mDataList[colIndex].IsLock then
                local lockSprite = ui.newSprite("c_35.png")
                lockSprite:setPosition(64, 60)
                itemParent:addChild(lockSprite)
            end

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
function BagImprintLayer:getPlayerBagInfo()
    local bagModelId = BagType.eGemBag
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
function BagImprintLayer:getItemCount()
    local dataCount = #ImprintObj:getImprintList()
    print(dataCount,"测试包裹数量")
    return dataCount
end

--得到对应数据和背包控件的类型
function BagImprintLayer:getItemData()
    local function getQuality(cellData)
        return ImprintModel.items[cellData.ModelId].quality
    end

    function dataSort(data)
        -- 排序
        table.sort(data, function(a, b)
            -- 上阵的排在前面
            local isIna = FormationObj:imprintInFormation(a.Id)
            local isInb = FormationObj:imprintInFormation(b.Id)
            if isIna ~= isInb then
                return isIna
            end

            -- 比较资质
            local qualitya = getQuality(a)
            local qualityb = getQuality(b)
            if qualitya ~= qualityb then
                return qualitya > qualityb
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
    local treasureTab = clone(ImprintObj:getImprintList())

    -- dataSort(equipTreasureTab)
    dataSort(treasureTab)

    -- table.insertto(equipTreasureTab, treasureTab, -1)

    itemData = treasureTab
    return itemData
end

-- -- 关闭该页面时执行函数
-- function BagImprintLayer:onExit()
--     EquipObj:getNewIdObj():clearNewId()
--     ImprintObj:getNewIdObj():clearNewId()
-- end

return BagImprintLayer
