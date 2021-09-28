--[[
	文件名：BagZhenjueLayer.lua
	描述：内功心法界面
	创建人：yanxingrui
    修改人：lengjiazhi
	创建时间： 2016.6.25
--]]

local BagZhenjueLayer = class("BagZhenjueLayer", function(params)
	return display.newLayer()
end)

-- 构造函数，初始化本页面需要的数据并刷新表格
function BagZhenjueLayer:ctor(params)
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
function BagZhenjueLayer:showBagCount()

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
            MsgBoxLayer.addExpandBagLayer(BagType.eZhenjue,
                function ()
                    self:showBagCount()
                end)
        end,
    })
    -- self.mBuyBtn:setScale(0.7)
    self:addChild(self.mBuyBtn)
    local bagTypeInfo = BagModel.items[BagType.eZhenjue]
    local playerTypeInfo = self:getPlayerBagInfo(BagType.eZhenjue)
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    self.mCountLabel:setString(TR("%d/%d", self:getItemCount(BagType.eZhenjue), playerTypeInfo.Size))
    self.mBuyBtn:setVisible(playerTypeInfo.Size < maxBagSize)

    -- local iconSprite = ui.newSprite("dw_05.png")
    -- iconSprite:setPosition(30,950)
    -- iconSprite:setScale(1.5)
    -- self:addChild(iconSprite)

    if self:getItemCount(BagType.eZhenjue) == 0 then
        local sp = ui.createEmptyHint(TR("暂无内功心法"))
        sp:setPosition(320, 568)
        self:addChild(sp)

        local gotoBtn = ui.newButton({
            text = TR("去获取"),
            normalImage = "c_28.png",
            clickAction = function ()
                LayerManager.showSubModule(ModuleSub.eTeambattle)
            end
            })
        gotoBtn:setPosition(320, 400)
        self:addChild(gotoBtn)
    end
end


-- 根据所选择的card显示相应的属性
function BagZhenjueLayer:showAttrLabel(data)
    if self.mAttrSprite then
        self.mAttrSprite:removeFromParent()
        self.mAttrSprite = nil
    end
    self.mAttrSprite = ui.newScale9Sprite("c_65.png",cc.size(630, 135))
    self.mAttrSprite:setPosition(320, 180)
    self:addChild(self.mAttrSprite)

    --分为内功心法和内功碎片
    if data.ModelId and math.floor(data.ModelId / 10000) == ResourcetypeSub.eNewZhenJue then
        local attrs
        if FormationObj:zhenjueInFormation(data.Id) then
            attrs = {CardShowAttr.eBorder, CardShowAttr.eBattle, CardShowAttr.eZhenjueType, CardShowAttr.eStep}
        else
            attrs = {CardShowAttr.eBorder, CardShowAttr.eZhenjueType, CardShowAttr.eStep}
        end

        -- 属性信息
        local nStepTimes = ZhenjueObj:getTimesOfStep(data)
        local attrList = Utility.analysisStrAttrList(ZhenjueModel.items[data.ModelId].initAttrStr)
        for index, item in pairs(attrList) do
            local nameStr = FightattrName[item.fightattr]
            local baseAttrStr = Utility.getAttrViewStr(item.fightattr, math.floor(item.value * nStepTimes), false)
            local upAttrStr = ""
            if data.UpAttrData[tostring(item.fightattr)] and data.UpAttrData[tostring(item.fightattr)] > 0 then
                upAttrStr = Utility.getAttrViewStr(item.fightattr, data.UpAttrData[tostring(item.fightattr)], false)
            end
           local tempStr = upAttrStr == "" and string.format("%s:%s", nameStr, baseAttrStr) or
                    string.format("%s:%s %s+%s", nameStr, baseAttrStr, Enums.Color.eDarkGreenH, upAttrStr)
            local introLab = ui.newLabel({
                text = tempStr,
                size = 20,
                color = cc.c3b(0x46, 0x22, 0x0d),
                anchorPoint = cc.p(0, 1),
                dimensions = cc.size(300, 0),
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            })
            introLab:setPosition(110 + (index - 1) % 2 * 200, 83 - math.floor((index - 1) / 2) * 28)
            self.mAttrSprite:addChild(introLab)
        end

        -- 装备于哪个英雄
        local _, info = FormationObj:zhenjueInFormation(data.Id)
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

        local card = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eNewZhenJue,
            instanceData = data,
            cardShowAttrs = attrs,
        })
        card:setPosition(55, 65)
        self.mAttrSprite:addChild(card)

        local strName = ZhenjueModel.items[data.ModelId].name
        local nStep = data.Step or 0
        if (nStep > 0) then
            strName = strName .. "+" .. nStep
        end
        local nameLab = ui.newLabel({
            text = strName,
            size = 22,
            color = Utility.getColorValue(ZhenjueModel.items[data.ModelId].colorLV, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            anchorPoint = cc.p(0, 1),
            dimensions = cc.size(300, 0),
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        })
        nameLab:setPosition(110, 113)
        self.mAttrSprite:addChild(nameLab)

        -- 可以洗练
        if ZhenjueModel.items[data.ModelId].upOddsClass > 0 then
            btn1 = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 65),
                text = TR("洗 炼"),
                clickAction = function(sender)
                    local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    self.mParent.mThirdSubTag = BagType.eZhenjue
                    self.mParent.selectId = data.Id
                    self.mParent.viewPos = viewPos
                    -- 进入洗练页面
                    LayerManager.addLayer({
                        name = "zhenjue.ZhenjueExtraLayer",
                        data = {zhenjueId = data.Id},
                    })

                    -- local tempStr = "bag.BagLayer"
                    -- local tempData = LayerManager.getRestoreData(tempStr)
                    -- tempData.subPageType = BagType.eZhenjue
                    -- tempData.thirdSubTag = BagType.eZhenjue
                    
                    -- LayerManager.setRestoreData(tempStr, tempData)
                end
            })
            self.mAttrSprite:addChild(btn1)

            -- 穿透问题
            btn1:setPropagateTouchEvents(false)
        end
    else
        -- 内功心法碎片
        local needNum = GoodsModel.items[data.ModelId].maxNum
        local nowNum = data.Num

        local canHc = false
        if nowNum >= needNum then
            canHc = true
        end

        local att = {CardShowAttr.eBorder, CardShowAttr.eDebris, CardShowAttr.eZhenjueType}
        if canHc then
            table.insert(att, CardShowAttr.eSynthetic)
        end
        local card = CardNode.createCardNode({
            instanceData = data,
            cardShowAttrs = att,
        })
        card:setPosition(55, 65)
        self.mAttrSprite:addChild(card)

        local nameLab = ui.newLabel({
            text = TR(GoodsModel.items[data.ModelId].name),
            size = 22,
            color = Utility.getQualityColor(GoodsModel.items[data.ModelId].quality, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
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
        numLabel:setPosition(110, 70)
        self.mAttrSprite:addChild(numLabel)

        -- 合成处理
        if canHc then
            local upgradeBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 60),
                text = TR("合 成"),
                clickAction = function ()
                    self:requestUpgrade(data, nowNum)
                end
                })
            self.mAttrSprite:addChild(upgradeBtn)
            -- 穿透问题
            upgradeBtn:setPropagateTouchEvents(false)

        else
            -- TODO
            -- 去获取
            local getBtn = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(550, 60),
                text = TR("去获取"),
                clickAction = function ()
                    local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                    self.mParent.mThirdSubTag = BagType.eZhenjue
                    self.mParent.selectId = data.Id
                    self.mParent.viewPos = viewPos
                    local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eTeambattle, true) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eTeambattle)
                    if isOpen then
                        local viewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
                        LayerManager.addLayer({name = "teambattle.TeambattleShop"})

                        -- local tempStr = "bag.BagLayer"
                        -- local tempData = LayerManager.getRestoreData(tempStr)
                        -- tempData.subPageType = BagType.eZhenjue
                        -- tempData.selectId = data.Id
                        -- tempData.viewPos = viewPos
                        -- LayerManager.setRestoreData(tempStr, tempData)
                    end
                end
                })
            self.mAttrSprite:addChild(getBtn)
            -- 穿透问题
            getBtn:setPropagateTouchEvents(false)
        end
    end
end

-- 刷新显示列表
function BagZhenjueLayer:refreshGrid()

    self:showBagCount(self.mCurType)

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

    local isZhenjueDebris

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
            local attrs = {CardShowAttr.eBorder, CardShowAttr.eZhenjueType, CardShowAttr.eStep}

            isZhenjueDebris = false
            local isGoods = Utility.getTypeByModelId(self.mDataList[colIndex].ModelId) == ResourcetypeSub.eNewZhenJueDebris
            if not isGoods then
                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                    if ZhenjueObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                        ZhenjueObj:getNewIdObj():clearNewId(self.mDataList[colIndex].Id)
                        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagZhenjueDebris)
                    end
                end

                if ZhenjueObj:getNewIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eNewCard)
                end
                if FormationObj:zhenjueInFormation(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eBattle)
                end

            elseif isGoods then

                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                    if GoodsObj:getNewZhenjueDebrisIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                        GoodsObj:getNewZhenjueDebrisIdObj():clearNewId(self.mDataList[colIndex].Id)
                        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagZhenjueDebris)
                    end
                end

                table.insert(attrs, CardShowAttr.eDebris, CardShowAttr.eNum)
                isZhenjueDebris = true
                if GoodsObj:getNewZhenjueDebrisIdObj():IdIsNew(self.mDataList[colIndex].Id) then
                    table.insert(attrs, CardShowAttr.eNewCard)
                end
                if self.mDataList[colIndex].Num >=
                    GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum then
                    table.insert(attrs, CardShowAttr.eSynthetic)
                end
            end

            -- 创建显示图片
            local card, Attr = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eNewZhenJue,
                instanceData = self.mDataList[colIndex],
                cardShowAttrs = attrs,
                onClickCallback = function()
                    self:showAttrLabel(self.mDataList[colIndex])
                    self.mGridView:setSelect(colIndex)
                    self.mSelectId = self.mDataList[colIndex].Id
                end,
            })
            if isZhenjueDebris then
                local needNum = GoodsModel.items[self.mDataList[colIndex].ModelId].maxNum
                local nowNum = self.mDataList[colIndex].Num
                Attr[CardShowAttr.eNum].label:setString(string.format("%d/%d",nowNum,needNum))
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

-- 获取对应类的包裹的信息
function BagZhenjueLayer:getPlayerBagInfo(bType)
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
function BagZhenjueLayer:getItemCount()
    local dataCount = #ZhenjueObj:getZhenjueList() + #GoodsObj:getZhenjueDebrisList()
    return dataCount
end

--得到对应数据和背包控件的类型
function BagZhenjueLayer:getItemData()
    local function getQuality(cellData)
        if Utility.getTypeByModelId(cellData.ModelId) == ResourcetypeSub.eNewZhenJueDebris then
            return GoodsModel.items[cellData.ModelId].quality
        elseif Utility.getTypeByModelId(cellData.ModelId) == ResourcetypeSub.eNewZhenJue then
            return ZhenjueModel.items[cellData.ModelId].colorLV
        end
    end

    local itemData

    local zhenjueTab = clone(ZhenjueObj:getZhenjueList())
    local zhenjueDeb = clone(GoodsObj:getZhenjueDebrisList())

    table.insertto(zhenjueTab, zhenjueDeb, -1)

    table.sort(zhenjueTab, function(a, b)
        local isGoodsA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.eNewZhenJueDebris
        local isZhenJueA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.eNewZhenJue
        local isGoodsB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.eNewZhenJueDebris
        local isZhenJueB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.eNewZhenJue
        -- 可以合成的阵诀碎片排在最前面
        if isGoodsA and GoodsModel.items[a.ModelId].maxNum == a.Num and (isZhenJueB or GoodsModel.items[b.ModelId].maxNum ~= b.Num) then
            return true
        elseif isGoodsB and GoodsModel.items[b.ModelId].maxNum == b.Num and (isZhenJueA or GoodsModel.items[a.ModelId].maxNum ~= a.Num) then
            return false
        end

        -- 阵诀排在阵诀碎片前面
        if isZhenJueA and isGoodsB then
            return true
        elseif isZhenJueB and isGoodsA then
            return false
        end


        if isZhenJueA and isZhenJueB then
            -- 上阵的阵诀排在未上阵的阵诀前面
            if FormationObj:zhenjueInFormation(a.Id) and not FormationObj:zhenjueInFormation(b.Id) then
                return true
            elseif not FormationObj:zhenjueInFormation(a.Id) and FormationObj:zhenjueInFormation(b.Id) then
                return false
            end

            -- 高品质阵诀排在前面
            if ZhenjueModel.items[a.ModelId].colorLV ~= ZhenjueModel.items[b.ModelId].colorLV then
                return ZhenjueModel.items[a.ModelId].colorLV > ZhenjueModel.items[b.ModelId].colorLV
            end

            -- 比较模型id
            return a.ModelId > b.ModelId
        elseif isGoodsA and isGoodsB then
            -- -- 高品质碎片排在前面
            if getQuality(a) ~= getQuality(b) then
                return getQuality(a) > getQuality(b)
            end

            -- 比较数量
            if a.Num ~= b.Num then
                return a.Num > b.Num
            end

            -- 比较模型id
            if GoodsModel.items[a.ModelId].ID ~= GoodsModel.items[b.ModelId].ID then
                return GoodsModel.items[a.ModelId].ID < GoodsModel.items[b.ModelId].ID
            end

            return a.Id < b.Id
        end
    end)

    itemData = zhenjueTab

    return itemData
end

-- -- 关闭该页面时执行函数
-- function BagZhenjueLayer:onExit()
--     ZhenjueObj:getNewIdObj():clearNewId()
--     GoodsObj:getNewZhenjueDebrisIdObj():clearNewId()
-- end

----------------------------网络请求---------------------------
-- 内功心法碎片合成
function BagZhenjueLayer:requestUpgrade(data, num)
    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, num},
        callback = function (response)
            self:refreshGrid()
            --MsgBoxLayer.addGameDropLayer(msgText, title, baseDrop, extraDrop, okBtnInfo, closeBtnInfo, needCloseBtn)
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, " ", TR("合成"), {{text = TR("确定")}}, {})
        end
    })

end

return BagZhenjueLayer
