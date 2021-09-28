--[[
    文件名：ImprintMainLayer.lua
    描述：宝石镶嵌界面
    创建人：yanghongsheng
    创建时间：2019.5.27
-- ]]
local ImprintMainLayer = class("ImprintMainLayer", function()
    return display.newLayer()
end)

--[[
    参数
        slotId  人物卡槽id
        partId  装备部位id
--]]

function ImprintMainLayer:ctor(params)
    self.mSlotId = params.slotId or 1
    self.mPartId = params.partId

    ui.registerSwallowTouch({node = self})
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 初始化页面控件
    self:initUI()

end

function ImprintMainLayer:initUI()
    -- 背景图片
    local bgLayer = ui.newSprite("bs_2.jpg")
    bgLayer:setAnchorPoint(cc.p(0.5, 0.5))
    bgLayer:setPosition(320, 568)
    self.mParentLayer:addChild(bgLayer)
    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(594, 1045)
    self.mParentLayer:addChild(self.mCloseBtn, 1)

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer("规则",
            {
                TR("1.不同颜色的宝石代表不同的宝石套装。"),
                TR("2.同一侠客身上镶嵌同色宝石达到一定时，激活套装属性。"),
                TR("3.宝石可以通过吸收其他宝石进行强化。"),
                TR("4.宝石每强化一级，基础属性固定提升，每强化四级，额外属性其中之一概率提升"),
            })
        end
    })
    ruleBtn:setPosition(55, 1045)
    self.mParentLayer:addChild(ruleBtn, 1)

    -- 宝石商店
    local shopBtn = ui.newButton({
        normalImage = "bs_1.png",
        clickAction = function()
            LayerManager.addLayer({name = "ice.IcefireShopLayer", cleanUp = false})
        end
    })
    shopBtn:setPosition(325, 750)
    self.mParentLayer:addChild(shopBtn, 1)

    local nameBg = ui.newScale9Sprite("c_25.png", cc.size(450, 50))
    nameBg:setPosition(320, 1000)
    self.mParentLayer:addChild(nameBg)
    -- hero名字
    self.mHeroNameLabel = ui.newLabel({
        text = "",
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    self.mHeroNameLabel:setPosition(320, 1000)
    self.mParentLayer:addChild(self.mHeroNameLabel)
    self.mHeroNameLabel.refreshLabel = function (target)
        local slotInfo = FormationObj:getSlotInfoBySlotId(self.mSlotId)
        local haveHero = Utility.isEntityId(slotInfo.HeroId)
        
        if haveHero then
            local heroInfo = HeroObj:getHero(slotInfo.HeroId)
            local tempModel = HeroModel.items[slotInfo.ModelId]
            local strName, tempStep = ConfigFunc:getHeroName(slotInfo.ModelId, {heroStep = heroInfo.Step, IllusionModelId = heroInfo.IllusionModelId})
            local strText = TR("等级%d  %s%s",
                heroInfo.Lv,
                Utility.getQualityColor(tempModel.quality, 2),
                strName)
            if (tempStep > 0) then
                strText = strText .. Enums.Color.eYellowH .. "  +" .. tempStep
            end
            target:setString(strText)
        else
            target:setString(TR("无"))
        end
    end
    self.mHeroNameLabel:refreshLabel()

    -- 底部背景
    local downSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 535))
    downSprite:setAnchorPoint(cc.p(0.5, 0))
    downSprite:setPosition(320, 0)
    self.mParentLayer:addChild(downSprite)
    self.mDownBg = downSprite

    -- 创建滑动控件
    self.mImprintSliderView = self:createSliderView()

    -- tab分页
    self:createTabLayer()
end

-- 创建滑动控件
function ImprintMainLayer:createSliderView()
    local sliderSize = cc.size(640, 430)
    local imprintView = ui.newSliderTableView({
        width = sliderSize.width,
        height = sliderSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.mSlotId-1,
        itemCountOfSlider = function(sliderView)
            return #FormationObj:getSlotInfos()
        end,
        itemSizeOfSlider = function(sliderView)
            return sliderSize.width, sliderSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            self:refreshImprintShow(itemNode, index)
        end,
        selectItemChanged = function(sliderView, selectIndex)
            self.mSlotId = selectIndex + 1
            sliderView:refreshItem(selectIndex)
            self.mHeroNameLabel:refreshLabel()
        end
    })
    imprintView:setAnchorPoint(cc.p(0.5, 0.5))
    imprintView:setPosition(320, 810)
    self.mParentLayer:addChild(imprintView)

    return imprintView
end

-- 创建分页
function ImprintMainLayer:createTabLayer()
    local buttonInfos = {
        {
            text = TR("信息"),
            tag = 1,
        },
        {
            text = TR("强化"),
            tag = 2,
        },
        {
            text = TR("替换"),
            tag = 3,
        },
    }
    self.mTabTag = 1

    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        viewSize = cc.size(640, 80),
        isVert = false,
        btnSize = cc.size(130, 50),
        space = 14,
        needLine = false,
        defaultSelectTag = self.mTabTag,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            self.mTabTag = selectBtnTag
            self.mConditionList = {}
            self:refreshDownLayer()
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(320, 520)
    self.mParentLayer:addChild(tabLayer)

    return tabLayer
end

-- 刷新六个部位宝石卡槽
function ImprintMainLayer:refreshImprintShow(parent, index)
    local slotId = index + 1
    parent:removeAllChildren()
    -- 部位类型
    local imprintTypeList = {
        [ResourcetypeSub.eClothes] = {
            pos = cc.p(200, 305),
        },
        [ResourcetypeSub.eNecklace] = {
            pos = cc.p(460, 67),
        },
        [ResourcetypeSub.eShoe] = {
            pos = cc.p(200, 67),
        },
        [ResourcetypeSub.eWeapon] = {
            pos = cc.p(495, 182),
        },
        [ResourcetypeSub.eHelmet] = {
            pos = cc.p(460, 305),
        },
        [ResourcetypeSub.ePants] = {
            pos = cc.p(152, 182),
        },
    }
    -- 重置选择部位
    if self.mPartId and self.mSlotId == slotId then
        local imprintInfo = FormationObj:getSlotImprint(slotId, self.mPartId)
        if not imprintInfo or not next(imprintInfo) then
            self.mPartId = nil
        end
    end
    -- 创建卡牌
    for partType, partInfo in pairs(imprintTypeList) do
        local imprintInfo = FormationObj:getSlotImprint(slotId, partType)
        local imprintCard = nil
        -- 有宝石
        if imprintInfo and next(imprintInfo) then
            -- 选择框
            local selectSprite = ui.newSprite("c_31.png")
            selectSprite:setPosition(partInfo.pos)
            parent:addChild(selectSprite)
            selectSprite:setVisible(false)
            -- 卸下提示
            local unCombatLabel = ui.newLabel({
                text = TR("点击卸下"),
                size = 18,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
            unCombatLabel:setPosition(partInfo.pos)
            parent:addChild(unCombatLabel, 1)
            unCombatLabel:setVisible(false)

            -- 初始化选择部位
            if not self.mPartId and self.mSlotId == slotId then
                self.mPartId = partType
                selectSprite:setVisible(true)
                unCombatLabel:setVisible(true)
                self.mBeforeSprite = selectSprite
                self.mUnCombatLabel = unCombatLabel
            elseif self.mPartId == partType and self.mSlotId == slotId then
                selectSprite:setVisible(true)
                unCombatLabel:setVisible(true)
                self.mUnCombatLabel = unCombatLabel
                self.mBeforeSprite = selectSprite
            end
            -- 卡牌
            imprintCard = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eImprint,
                instanceData = imprintInfo,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel},
                onClickCallback = function ()
                    if self.mPartId == partType then
                        MsgBoxLayer.showImprintIntroLayer({
                            imprintId = imprintInfo.Id,
                            slotId = self.mSlotId,
                            btnInfos = {
                                {
                                    text = TR("卸下"),
                                    clickAction = function (layerObj)
                                        self.requestUnCombatImprint(self, self.mSlotId, partType)
                                        LayerManager.removeLayer(layerObj)
                                    end
                                }
                            },
                        })
                        return
                    end
                    self.mPartId = partType

                    if self.mBeforeSprite then
                        self.mBeforeSprite:setVisible(false)
                    end
                    self.mBeforeSprite = selectSprite
                    selectSprite:setVisible(true)

                    if self.mUnCombatLabel then
                        self.mUnCombatLabel:setVisible(false)
                    end
                    self.mUnCombatLabel = unCombatLabel
                    unCombatLabel:setVisible(true)

                    self:refreshDownLayer()
                end
            })
        else
            imprintCard = CardNode.createCardNode({
                onClickCallback = function ()
                    LayerManager.addLayer({
                        name = "hero.ImprintSelectLayer",
                        data = {
                            slotId = self.mSlotId,
                            part = partType,
                            callback = function ()
                                self.mPartId = partType
                                self:refreshImprintShow(parent, index)
                            end
                        },
                        cleanUp = false,
                    })
                end
            })
            imprintCard:setEmptyEquip({}, partType)
            -- 有可上阵宝石
            if ImprintObj:isHaveCanCombat(partType) then
                local addSprite = ui.newSprite("c_22.png")
                local cardSize = imprintCard:getContentSize()
                addSprite:setPosition(cardSize.width*0.5, cardSize.height*0.5)
                imprintCard:addChild(addSprite)
                addSprite:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.ScaleTo:create(1, 0.7), cc.ScaleTo:create(1, 1)})))
            end
        end
        imprintCard:setPosition(partInfo.pos)
        parent:addChild(imprintCard)
    end

    if self.mSlotId == slotId then
        self:refreshDownLayer()
    end
end

-- 刷新底部显示
function ImprintMainLayer:refreshDownLayer()
    if self.mTabTag == 1 then
        self:refreshAttrInfoLayer()
    elseif self.mTabTag == 2 then
        self.mConditionList.isUnLock = true
        self:refreshLvLayer()
    elseif self.mTabTag == 3 then
        self.mConditionList.partsCond = {}
        if self.mPartId then
            self.mConditionList.partsCond[self.mPartId] = true
        end
        self:refreshReplaceLayer()
    end
end

-- 刷新属性信息底部显示
function ImprintMainLayer:refreshAttrInfoLayer()
    self.mDownBg:removeAllChildren()
    if not self.mSlotId then return end
    -- 黑背景
    local listBgSize = cc.size(620, 400)
    local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
    listBg:setAnchorPoint(cc.p(0.5, 0))
    listBg:setPosition(320, 100)
    self.mDownBg:addChild(listBg)
    -- 宝石列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-10))
    listView:setItemsMargin(6)
    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(listView)
    -- 属性
    local attrList = ImprintObj:getSlotAllAttr(self.mSlotId)
    local col = 3
    local space = 185
    local itemHight = math.ceil(#attrList/col)*30
    if itemHight <= 0 then
        itemHight = 120
    else
        itemHight = itemHight + 80
    end
    local itemLayout = ccui.Layout:create()
    local itemSize = cc.size(listView:getContentSize().width, itemHight)
    itemLayout:setContentSize(itemSize)
    listView:pushBackCustomItem(itemLayout)

    local bgSprite = ui.newScale9Sprite("c_54.png", itemSize)
    bgSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
    itemLayout:addChild(bgSprite)

    local titleLabel = ui.newLabel({
        text = TR("属性提升"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    titleLabel:setPosition(itemSize.width*0.5, itemSize.height-20)
    itemLayout:addChild(titleLabel)

    if next(attrList) then
        for i = 1, math.ceil(#attrList/col) do
            for j = 1, col do
                local index = (i-1)*col+j
                local attrInfo = attrList[index]
                if not attrInfo then break end

                local attrLabel = ui.newLabel({
                    text = FightattrName[attrInfo.fightattr].."#258711"..Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value, true),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 20,
                })
                attrLabel:setAnchorPoint(cc.p(0, 0.5))
                attrLabel:setPosition((j-1)*space+35, itemHight-(i-1)*30-60)
                itemLayout:addChild(attrLabel)
            end
        end
    else
        local tempLabel = ui.newLabel({
            text = TR("无属性"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
        tempLabel:setPosition(35, itemHight-60)
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        itemLayout:addChild(tempLabel)
    end

    -- 套装
    local suitAttrList = ImprintObj:getSlotActiveSuit(self.mSlotId)
    local attrLabelList = {}
    local itemHight = 80
    if next(suitAttrList) then
        for _, suitAttrInfo in ipairs(suitAttrList) do
            local attrLabel = ui.newLabel({
                text = TR("%s：%s", suitAttrInfo.name, TalModel.items[suitAttrInfo.talId].intro),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
            table.insert(attrLabelList, attrLabel)
            itemHight = itemHight + attrLabel:getContentSize().height+10
        end
    else
        local attrLabel = ui.newLabel({
            text = TR("暂未激活套装属性"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
        table.insert(attrLabelList, attrLabel)
        itemHight = itemHight + attrLabel:getContentSize().height+10
    end

    local itemLayout = ccui.Layout:create()
    local itemSize = cc.size(listView:getContentSize().width, itemHight)
    itemLayout:setContentSize(itemSize)
    listView:pushBackCustomItem(itemLayout)

    local bgSprite = ui.newScale9Sprite("c_54.png", itemSize)
    bgSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
    itemLayout:addChild(bgSprite)

    local titleLabel = ui.newLabel({
        text = TR("套装属性"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    titleLabel:setPosition(itemSize.width*0.5, itemSize.height-20)
    itemLayout:addChild(titleLabel)

    for i, attrLabel in ipairs(attrLabelList) do
        attrLabel:setAnchorPoint(cc.p(0, 0.5))
        attrLabel:setPosition(20, itemHight-60-(i-1)*37)
        itemLayout:addChild(attrLabel)
    end
end

-- 刷新强化底部显示
function ImprintMainLayer:refreshLvLayer()
    self.mDownBg:removeAllChildren()
    local useSelectList = {}

    if not self.mPartId or not self.mSlotId then
        local emptyHint = ui.createEmptyHint(TR("无需要强化的宝石"))
        emptyHint:setPosition(320, 300)
        self.mDownBg:addChild(emptyHint)
        return
    end

    -- 经验预进度条
    local preExpProgress = require("common.ProgressBar"):create({
        bgImage = "zr_14.png",
        barImage = "zr_37.png",
        currValue = 0,
        maxValue = 100,
        barType = ProgressBarType.eHorizontal,
    })
    preExpProgress:setAnchorPoint(cc.p(0.5, 0.5))
    preExpProgress:setPosition(320, 490)
    self.mDownBg:addChild(preExpProgress)

    -- 经验进度条
    local expProgress = require("common.ProgressBar"):create({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        needHideBg = true,
        currValue = 0,
        maxValue = 100,
        barType = ProgressBarType.eHorizontal,
    })
    expProgress:setAnchorPoint(cc.p(0.5, 0.5))
    expProgress:setPosition(320, 490)
    self.mDownBg:addChild(expProgress)

    -- 进度的提示信息
    progLabel = ui.newLabel({
        text = "",
        size = 18,
        outlineColor = Enums.Color.eOutlineColor,
        outlineSize = 2,
    })
    local progSize = expProgress:getContentSize()
    progLabel:setPosition(progSize.width*0.5, progSize.height*0.5)
    progLabel:setAnchorPoint(cc.p(0.5, 0.5))
    expProgress:addChild(progLabel)

    -- 刷新进度显示
    local function refreshProgShow(preExp)
        -- 宝石数据
        local imprintInfo = FormationObj:getSlotImprint(self.mSlotId, self.mPartId)
        local imprintModel = ImprintModel.items[imprintInfo.ModelId]
        local preExp = preExp or 0
        -- 当前/下级经验
        local nextLvTotalExp = nil
        if ImprintLvRelation.items[imprintModel.stars][imprintInfo.Lv+1] then
            nextLvTotalExp = ImprintLvRelation.items[imprintModel.stars][imprintInfo.Lv+1].totalExp
        end
        local curLvTotalExp = ImprintLvRelation.items[imprintModel.stars][imprintInfo.Lv].totalExp
        local curExp = nextLvTotalExp and imprintInfo.TotalExp-curLvTotalExp or curLvTotalExp
        local nextExp = nextLvTotalExp and nextLvTotalExp-curLvTotalExp or curLvTotalExp
        -- 经验进度
        expProgress:setMaxValue(nextExp)
        expProgress:setCurrValue(curExp)
        -- 预经验进度
        preExpProgress:setMaxValue(nextExp)
        preExpProgress:setCurrValue(curExp+preExp)

        -- 能升到等级
        local canUpLv = imprintInfo.Lv
        local lvList = table.keys(ImprintLvRelation.items[imprintModel.stars])
        table.sort(lvList, function (lv1, lv2)
            return lv1 < lv2
        end)
        for i, lv in ipairs(lvList) do
            if imprintInfo.Lv < lv and preExp+imprintInfo.TotalExp >= ImprintLvRelation.items[imprintModel.stars][lv].totalExp then
                canUpLv = lv
            end
        end
        if curExp == nextExp then
            progLabel:setString(TR("%s级 已满级", imprintInfo.Lv))
        elseif canUpLv > imprintInfo.Lv then
            local currCount = curExp/nextExp*100
            progLabel:setString(TR("%s级 当前经验: %.2f%%%s(可升至%d级)", imprintInfo.Lv, currCount, Enums.Color.eYellowH, canUpLv))
        elseif preExp > 0 then
            local currCount = curExp/nextExp*100
            local nextCount = (curExp+preExp)/nextExp*100
            progLabel:setString(TR("%s级 当前经验: %.2f%%%s(可升至%d%%)", imprintInfo.Lv, currCount, Enums.Color.eYellowH, nextCount))
        else
            local currCount = curExp/nextExp*100
            progLabel:setString(TR("%s级 当前经验: %.2f%%", imprintInfo.Lv, currCount))
        end
    end

    refreshProgShow()

    -- 计算所有选中宝石经验
    local function calculatePreExp()
        local allPreExp = 0
        for Id, isSelected in pairs(useSelectList) do
            if isSelected then
                local imprintInfo = ImprintObj:getImprint(Id)
                allPreExp = allPreExp + imprintInfo.TotalExp

                local imprintModel = ImprintModel.items[imprintInfo.ModelId]
                allPreExp = allPreExp + imprintModel.exp
            end
        end
        return allPreExp
    end

    -- 创建子项
    local function creatItem(parent, imprintInfo)
        local parentSize = parent:getContentSize()

        local imprintCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eImprint,
            instanceData = imprintInfo,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eName},
            onClickCallback = function ()
                if useSelectList[imprintInfo.Id] then
                    useSelectList[imprintInfo.Id] = nil
                    parent.selectSprite:setVisible(false)
                else
                    -- 判断是否满级
                    local lvImprintInfo = FormationObj:getSlotImprint(self.mSlotId, self.mPartId)
                    local preExp = calculatePreExp()
                    local curTotalExp = lvImprintInfo.TotalExp+preExp
                    local imprintModel = ImprintModel.items[lvImprintInfo.ModelId]
                    local imprintLvModel = ImprintLvRelation.items[imprintModel.stars]
                    local needTotalExp = imprintLvModel[table.maxn(imprintLvModel)].totalExp
                    local isFinishUpLv = needTotalExp <= curTotalExp
                    if isFinishUpLv then
                        ui.showFlashView(TR("当前宝石等级已满，无法继续升级"))
                        return
                    end
                    -- 加入选择列表
                    useSelectList[imprintInfo.Id] = true
                    parent.selectSprite:setVisible(true)
                end

                refreshProgShow(calculatePreExp())
            end
        })
        imprintCard:setPosition(parentSize.width*0.5, 75)
        parent:addChild(imprintCard)

        parent.selectSprite = ui.newSprite("zy_19.png")
        parent.selectSprite:setPosition(parentSize.width*0.5, 75)
        parent:addChild(parent.selectSprite)
        parent.selectSprite:setVisible(false)
    end

    -- gridView
    self:createGridView({
        createItemCallback = creatItem,
        size = cc.size(625, 300),
        celHeight = 130,
        screenCondition = self.mConditionList,
        sortFunc = function (imprintList)
            local tempList = clone(imprintList)
            table.sort(tempList, function(imprintInfo1, imprintInfo2)
                local imprintModel1 = ImprintModel.items[imprintInfo1.ModelId]
                local imprintModel2 = ImprintModel.items[imprintInfo2.ModelId]

                if imprintModel1.quality ~= imprintModel2.quality then
                    return imprintModel1.quality < imprintModel2.quality
                end

                if imprintInfo1.TotalExp ~= imprintInfo2.TotalExp then
                    return imprintInfo1.TotalExp < imprintInfo2.TotalExp
                end

                if imprintModel1.suitId ~= imprintModel2.suitId then
                    return imprintModel1.suitId < imprintModel2.suitId
                end

                if imprintModel1.equipTypeID ~= imprintModel2.equipTypeID then
                    return imprintModel1.equipTypeID < imprintModel2.equipTypeID
                end
            end)

            return tempList
        end,
    })

    -- 强化按钮
    local lvUpBtn = ui.newButton({
        text = TR("强化"),
        normalImage = "c_28.png",
        clickAction = function ()
            local useIdList = table.keys(useSelectList)
            if not useIdList or not next(useIdList) then
                ui.showFlashView("请选择消耗的宝石")
                return
            end
            local imprintInfo = FormationObj:getSlotImprint(self.mSlotId, self.mPartId)
            local stars = ImprintModel.items[imprintInfo.ModelId].stars
            if not ImprintLvRelation.items[stars][imprintInfo.Lv+1] then
                ui.showFlashView("该宝石已满级")
                return
            end

            self:requestUpLv(imprintInfo.Id, useIdList)
        end
    })
    lvUpBtn:setPosition(200, 130)
    self.mDownBg:addChild(lvUpBtn)

    -- 筛选按钮
    local selectBtn = ui.newButton({
        text = TR("筛选"),
        normalImage = "c_28.png",
        clickAction = function ()
            self:createSelectBox({
                pos = cc.p(440, 160),
            })
        end
    })
    selectBtn:setPosition(440, 130)
    self.mDownBg:addChild(selectBtn)
end

-- 刷新替换底部显示
function ImprintMainLayer:refreshReplaceLayer()
    self.mDownBg:removeAllChildren()

    -- 创建子项
    local function creatItem(parent, imprintInfo)
        local parentSize = parent:getContentSize()

        local imprintCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eImprint,
            instanceData = imprintInfo,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel},
            onClickCallback = function ()
                MsgBoxLayer.showImprintIntroLayer({
                    imprintId = imprintInfo.Id,
                    slotId = self.mSlotId,
                })
            end
        })
        imprintCard:setPosition(parentSize.width*0.5, 95)
        parent:addChild(imprintCard)

        -- 替换按钮
        local replaceBtn = ui.newButton({
            normalImage = "c_33.png",
            text = TR("替换"),
            clickAction = function ( ... )
                if not self.mPartId then
                    ui.showFlashView(TR("请选择替换部位的宝石"))
                    return
                end
                self:requestReplaceImprint(self.mSlotId, self.mPartId, imprintInfo.Id)
            end
        })
        replaceBtn:setScale(0.7)
        replaceBtn:setPosition(parentSize.width*0.5, 25)
        parent:addChild(replaceBtn)
    end

    -- gridView
    self:createGridView({
        createItemCallback = creatItem,
        size = cc.size(625, 330),
        celHeight = 150,
        screenCondition = self.mConditionList,
        sortFunc = function (imprintList)
            local tempList = clone(imprintList)
            table.sort(tempList, function(imprintInfo1, imprintInfo2)
                local imprintModel1 = ImprintModel.items[imprintInfo1.ModelId]
                local imprintModel2 = ImprintModel.items[imprintInfo2.ModelId]

                if imprintModel1.quality ~= imprintModel2.quality then
                    return imprintModel1.quality > imprintModel2.quality
                end

                if imprintInfo1.TotalExp ~= imprintInfo2.TotalExp then
                    return imprintInfo1.TotalExp > imprintInfo2.TotalExp
                end

                if imprintModel1.suitId ~= imprintModel2.suitId then
                    return imprintModel1.suitId < imprintModel2.suitId
                end

                if imprintModel1.equipTypeID ~= imprintModel2.equipTypeID then
                    return imprintModel1.equipTypeID < imprintModel2.equipTypeID
                end
            end)

            return tempList
        end
    })

    -- 筛选按钮
    local selectBtn = ui.newButton({
        text = TR("筛选"),
        normalImage = "c_28.png",
        clickAction = function ()
            self:createSelectBox({
                pos = cc.p(320, 160),
                boxType = 1,
            })
        end
    })
    selectBtn:setPosition(320, 130)
    self.mDownBg:addChild(selectBtn)
end

--[[
params:
    createItemCallback  -- 创建子项回调
    celHeight           -- 子项高度
    screenCondition = { -- 筛选条件
        
    }
    size                -- 大小
    sortFunc            -- 排序
]]
function ImprintMainLayer:createGridView(params)
    local imprintList = self.getImprintList(params.screenCondition)
    if params.sortFunc then
        imprintList = params.sortFunc(imprintList)
    end
    -- 背景
    local bgSprite = ui.newScale9Sprite("c_17.png", params.size)
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(320, 170)
    self.mDownBg:addChild(bgSprite)
    -- gridView
    local gridView = require("common.GridView"):create({
            viewSize = params.size,
            colCount = 4,
            celHeight = params.celHeight,
            selectIndex = 1,
            -- needDelay = true,
            getCountCb = function()
                return #imprintList
            end,
            createColCb = function(itemParent, colIndex)
                params.createItemCallback(itemParent, imprintList[colIndex], isSelected)
            end,
        })
    gridView:setAnchorPoint(cc.p(0.5, 0.5))
    gridView:setPosition(params.size.width*0.5, params.size.height*0.5)
    bgSprite:addChild(gridView)
    -- 空提示
    if not next(imprintList) then
        local emptyHint = ui.createEmptyHint(TR("无符合条件的宝石"))
        emptyHint:setPosition(params.size.width*0.5, params.size.height*0.5)
        bgSprite:addChild(emptyHint)
    end
end

--[[
params: -- 筛选条件
    lvCond = {
        [1] = true, -- 未升级
        [2] = true, -- 已升级
    }
    starsCond = {
        [3] = true,  -- 3星宝石
        [4] = true,  -- 4星宝石
        [5] = true,  -- 5星宝石
        [6] = true,  -- 6星宝石
    },
    partsCond = {
        [ResourcetypeSub.eWeapon] = true,  -- "武器"
        [ResourcetypeSub.eHelmet] = true,  -- "头部"
        [ResourcetypeSub.eClothes] = true, -- "衣服"
        [ResourcetypeSub.eNecklace] = true,-- "项链"
        [ResourcetypeSub.ePants] = true,   -- "裤子"
        [ResourcetypeSub.eShoe] = true,    -- "鞋子"
    },
    isUnLock,       -- 是否需要过滤掉锁定的宝石
]]
function ImprintMainLayer.getImprintList(params)
    local imprintList = ImprintObj:getImprintList({notInFormation = true, isUnLock = params.isUnLock})
    -- 没有条件
    if not params or not next(params) then
        return imprintList
    end
    local isNotCond = true          -- 不要条件
    local isNotStarsCond = true     -- 不要星数条件
    local isNotPartsCond = true     -- 不要部位条件
    local isNotLvCond = true        -- 不要是否升级条件
    for _, isTrue in pairs(params.starsCond or {}) do
        if isTrue then
            isNotCond = false
            isNotStarsCond = false
            break
        end
    end
    for _, isTrue in pairs(params.partsCond or {}) do
        if isTrue then
            isNotCond = false
            isNotPartsCond = false
            break
        end
    end
    for _, isTrue in pairs(params.lvCond or {}) do
        if isTrue then
            isNotCond = false
            isNotLvCond = false
            break
        end
    end
    
    if isNotCond then
        return imprintList
    end

    local function isPassStarsCond(imprintInfo)
        if not isNotStarsCond then
            local imprintModel = ImprintModel.items[imprintInfo.ModelId]
            return params.starsCond[imprintModel.stars]
        end

        return true
    end

    local function isPassPartsCond(imprintInfo)
        if not isNotPartsCond then
            local imprintModel = ImprintModel.items[imprintInfo.ModelId]
            return params.partsCond[imprintModel.equipTypeID]
        end

        return true
    end

    local function isLvCond(imprintInfo)
        if not isNotLvCond then
            local isUpLv = imprintInfo.Lv > 0
            local condition = isUpLv and 2 or 1
            return params.lvCond[condition]
        end
        return true
    end

    -- 筛选
    local tempList = {}
    for _, imprintInfo in pairs(imprintList) do
        if isPassStarsCond(imprintInfo) and isPassPartsCond(imprintInfo) and isLvCond(imprintInfo) then
            table.insert(tempList, imprintInfo)
        end
    end
    return tempList
end

-- 创建筛选盒子
--[[
params:
    pos         位置
    boxType     类型（1：星数筛选，2：部位筛选 3：都有）
]]
function ImprintMainLayer:createSelectBox(params)
    -- 是否升级条件
    local lvCond = {1, 2}
    -- 星数条件
    local starsCond = {3, 4, 5, 6}
    -- 部位条件
    partsCond = {ResourcetypeSub.eWeapon, ResourcetypeSub.eHelmet, ResourcetypeSub.eClothes, ResourcetypeSub.eNecklace, ResourcetypeSub.ePants, ResourcetypeSub.eShoe}

    -- 是否已打开选择盒
    if self.isOpenBox then return end
    self.isOpenBox = true
    -- 添加一个当前最上层的层
    local touchLayer = ui.newStdLayer()
    self:addChild(touchLayer, 999)
    -- 添加选择盒背景
    local selBgSprite = ui.newScale9Sprite("gd_01.png", cc.size(100, 100))
    selBgSprite:setAnchorPoint(0.5, 0)
    selBgSprite:setPosition(params.pos)
    selBgSprite:setScale(0.1)
    touchLayer:addChild(selBgSprite)
    -- 播放变大动画
    local scale = cc.ScaleTo:create(0.2, 1)
    selBgSprite:runAction(scale)
    -- 关闭选择盒
    local function closeBox()
        local callfunDelete = cc.CallFunc:create(function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end)
        local scale = cc.ScaleTo:create(0.2, 0.1)
        selBgSprite:runAction(cc.Sequence:create(scale, callfunDelete))
    end
    -- 注册触摸监听关闭选择盒
    ui.registerSwallowTouch({
        node = touchLayer,
        allowTouch = true,
        endedEvent = function(touch, event)
            closeBox()
        end
    })

    -- 创建选择列表
    local function createCheckBoxList(cellSize, listType)
        -- 列表view
        local selectList = ccui.ListView:create()
        selectList:setDirection(ccui.ScrollViewDir.vertical)
        -- 列表高度计数
        local listHight = 0

        local tempList = {}
        local conditionList = nil
        if listType == 1 then
            tempList = starsCond
            self.mConditionList.starsCond = self.mConditionList.starsCond or {}
            conditionList = self.mConditionList.starsCond
        elseif listType == 2 then
            tempList = partsCond
            self.mConditionList.partsCond = self.mConditionList.partsCond or {}
            conditionList = self.mConditionList.partsCond
        elseif listType == 3 then
            tempList = lvCond
            self.mConditionList.lvCond = self.mConditionList.lvCond or {}
            conditionList = self.mConditionList.lvCond
        end

        for i, condition in ipairs(tempList) do
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            local cellSprite = ui.newScale9Sprite("zl_09.png", cc.size(cellSize.width, cellSize.height-5))
            cellSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(cellSprite)

            local condStr = ""
            if listType == 1 then
                condStr = TR("%s星", condition)
            elseif listType == 2 then
                condStr = ResourcetypeSubName[condition]
            elseif listType == 3 then
                condStr = condition == 1 and TR("未升级") or TR("已升级")
            end
            local checkBtn = ui.newCheckbox({
                text = condStr,
                isRevert = true,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                callback = function(pSender)
                    layout.cancelOrSelect()
                end
                })
            checkBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(checkBtn)
            layout.checkBtn = checkBtn

            layout.checkBtn:setCheckState(conditionList[condition] and true or false)
            
            -- 透明按钮（点击列表项改变复选框状态）
            local touchBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cellSize,
                clickAction = function()
                    layout.cancelOrSelect()
                end
            })
            touchBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellSprite:addChild(touchBtn)

            -- 选择或取消
            layout.cancelOrSelect = function ()
                conditionList[condition] = not conditionList[condition]
                layout.checkBtn:setCheckState(conditionList[condition] and true or false)
            end
            
            -- 加入列表
            selectList:pushBackCustomItem(layout)
            -- 列表长度计数
            listHight = listHight + cellSize.height
        end
        -- 设置列表大小
        selectList:setContentSize(cellSize.width, listHight+10)

        return selectList
    end
    local bgSize = nil
    if params.boxType == 1 or params.boxType == 2 then
        -- 创建列表
        local selectListView1 = createCheckBoxList(cc.size(200, 50), params.boxType)
        local selectListView2 = createCheckBoxList(cc.size(200, 50), 3)
        local listSize1 = selectListView1:getContentSize()
        local listSize2 = selectListView2:getContentSize()
        -- 重设背景图大小
        bgSize = cc.size(listSize1.width+40, listSize2.height+listSize1.height+100)
        selBgSprite:setContentSize(bgSize)
        -- 设置列表位置
        selectListView1:setAnchorPoint(cc.p(0.5, 0))
        selectListView1:setPosition(bgSize.width*0.5, 60)
        selBgSprite:addChild(selectListView1)

        selectListView2:setAnchorPoint(cc.p(0.5, 0))
        selectListView2:setPosition(bgSize.width*0.5, 50+listSize1.height)
        selBgSprite:addChild(selectListView2)
    else
        -- 创建列表
        local starsListView = createCheckBoxList(cc.size(200, 50), 1)
        local partsListView = createCheckBoxList(cc.size(200, 50), 2)
        local upLvListView = createCheckBoxList(cc.size(200, 50), 3)
        local starsListSize = starsListView:getContentSize()
        local partsListSize = partsListView:getContentSize()
        local upLvListSize = upLvListView:getContentSize()
        local listSize = starsListSize.height > partsListSize.height and starsListSize or partsListSize

        -- 重设背景图大小
        bgSize = cc.size(starsListSize.width+partsListSize.width+60, listSize.height+100)
        selBgSprite:setContentSize(bgSize)
        -- 设置列表位置
        starsListView:setAnchorPoint(cc.p(0, 0))
        starsListView:setPosition(15, 60)
        selBgSprite:addChild(starsListView)
        upLvListView:setAnchorPoint(cc.p(0, 0))
        upLvListView:setPosition(15, 50+starsListSize.height)
        selBgSprite:addChild(upLvListView)
        partsListView:setAnchorPoint(cc.p(0, 0))
        partsListView:setPosition(30+starsListSize.width, 60)
        selBgSprite:addChild(partsListView)
        -- 超框
        local offestX = bgSize.width*0.5+params.pos.x-640
        if  offestX > 0 then
            selBgSprite:setPosition(params.pos.x-offestX-10, params.pos.y)
        end
    end

    -- 关闭按钮
    local closeButton = ui.newButton({
        normalImage = "zl_10.png",
        clickAction = function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end
    })
    closeButton:setPosition(bgSize.width * 0.87, bgSize.height-25)
    selBgSprite:addChild(closeButton)

    -- 确定按钮
    local confirmButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确认"),
        clickAction = function()
            self:refreshDownLayer()
            -- 关闭选择盒
            closeBox()
        end
    })
    confirmButton:setScale(0.9)
    confirmButton:setPosition(bgSize.width * 0.5, 40)
    selBgSprite:addChild(confirmButton)
end

--===========================================网络请求=========================================

-- 卸下宝石
function ImprintMainLayer:requestUnCombatImprint(slotId, partId)
    local resTypeList = {
        ResourcetypeSub.eWeapon,  -- "武器"
        ResourcetypeSub.eHelmet,  -- "头部"
        ResourcetypeSub.eClothes, -- "衣服"
        ResourcetypeSub.eNecklace,-- "项链"
        ResourcetypeSub.ePants,   -- "裤子"
        ResourcetypeSub.eShoe,    -- "鞋子"
    }
    local ret = {slotId}
    for _, resType in ipairs(resTypeList) do
        if resType == partId then
            table.insert(ret, EMPTY_ENTITY_ID)
        else
            table.insert(ret, "")
        end
    end

    HttpClient:request({
        moduleName = "Slot",
        methodName = "OneKeyImprintCombat",
        svrMethodData = ret,
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.mImprintSliderView:refreshItem(slotId-1)
        end
    })
end

-- 替换宝石
function ImprintMainLayer:requestReplaceImprint(slotId, partId, imprintId)
    local resTypeList = {
        ResourcetypeSub.eWeapon,  -- "武器"
        ResourcetypeSub.eHelmet,  -- "头部"
        ResourcetypeSub.eClothes, -- "衣服"
        ResourcetypeSub.eNecklace,-- "项链"
        ResourcetypeSub.ePants,   -- "裤子"
        ResourcetypeSub.eShoe,    -- "鞋子"
    }
    local ret = {slotId}
    for _, resType in ipairs(resTypeList) do
        if resType == partId then
            table.insert(ret, imprintId)
        else
            table.insert(ret, "")
        end
    end

    HttpClient:request({
        moduleName = "Slot",
        methodName = "OneKeyImprintCombat",
        svrMethodData = ret,
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.mImprintSliderView:refreshItem(slotId-1)
        end
    })
end

-- 升级
function ImprintMainLayer:requestUpLv(id, useIdList)
    HttpClient:request({
        moduleName = "Imprint",
        methodName = "LvUp",
        svrMethodData = {id, useIdList},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end

            ImprintObj:setImprintList(response.Value.ImprintInfo)
            self.mImprintSliderView:refreshItem(self.mSlotId-1)
        end
    })
end

return ImprintMainLayer