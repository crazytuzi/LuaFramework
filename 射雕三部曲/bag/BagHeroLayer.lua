--[[
    文件名：BagHeroLayer.lua
    描述：人物背包界面
    创建人：peiyaoqiang
    创建时间：2017.3.11
-- ]]

-- 预定义量(EnumsConfig.lua中定义)
local TabsConfig = {
    {
        name = TR("侠客"),
        moduleId = ModuleSub.eHero,
    },
    {
        name = TR("侠客碎片"),
        moduleId = ModuleSub.eBagHeroDebris,
    },
    {
        name = TR("幻化侠客"),
        moduleId = ModuleSub.eBagIllusionDebris,
    },
}

local ModulesConfig = {
    [ModuleSub.eHero] = {
        resourceTypeSub = ResourcetypeSub.eHero,         --TR("学员")
        bagModelId = BagType.eHeroBag,                   --人物
        moduleId = ModuleSub.eBagHero,
    },
    [ModuleSub.eBagHeroDebris] = {
        resourceTypeSub = ResourcetypeSub.eHeroDebris,   --TR("学员碎片")
        bagModelId = BagType.eHeroDebrisBag,             --人物碎片
        moduleId = ModuleSub.eBagHeroDebris,
        needRedDot = true,
    },
    [ModuleSub.eBagIllusionDebris] = {
        resourceTypeSub = ResourcetypeSub.eIllusionDebris,--TR("幻化碎片")
        bagModelId = BagType.eIllusionDebrisBag,
        moduleId = ModuleSub.eBagIllusionDebris,
        needRedDot = true,
    },
}

local BagHeroLayer = class("BagHeroLayer",function()
    return display.newLayer()
end)

--[[
    params:
    Table:
    {
        tag:初始选中页面
        id:初始选中物品id
        scrollPos:ScrollView初始位置  --主要用于恢复用
    }
]]
function BagHeroLayer:ctor(params)
    -- 设置初始位置
    self.original = {
        [ModuleSub.eHero] = {},
        [ModuleSub.eBagHeroDebris] = {},
        [ModuleSub.eBagIllusionDebris] = {},
    }
    self.originalTag = params.tag or TabsConfig[1].moduleId
    if self.original[self.originalTag] == nil then
        self.originalTag = ModuleSub.eHero 
    end
    self.original[self.originalTag].id = params.id
    self.original[self.originalTag].pos = params.scrollPos
    self.mParent = params.parent
    self.mPages = {}
    self.mCurTag = 0
    self.mRelations = {}
    self:createLayer()
    -- 跳转到初始页面
    self:changePage(self.mTabs:getCurrTag())

    -- 播放音效
    MqAudio.playEffect("zhuangbei_open.mp3")
end

-- 初始化界面
function BagHeroLayer:createLayer()
    -- 创建该页面的父节点
    self.mParentLayer = display.newLayer()
    self:addChild(self.mParentLayer)

    -- 包裹容量信息背景
    local sprite = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    sprite:setPosition(540, 940)
    self:addChild(sprite)

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
    self:addChild(underGaryBgSprite, -1)


    -- 选中卡牌信息背景
    local sprite = ui.newScale9Sprite("c_65.png", cc.size(625, 135))
    sprite:setPosition(320, 180)
    self:addChild(sprite, -1)
    self.mPanelBg = sprite

    self:initUI()
end

-- 创建UI
function BagHeroLayer:initUI()
    -- 创建标签
    self:createTabs()
end

--- ==================== 标签相关 =======================
-- 创建标签
function BagHeroLayer:createTabs()
    local buttonInfos = {}
    -- 初始化按钮信息
    for i=1, #TabsConfig do
        if ModuleInfoObj:moduleIsOpen(TabsConfig[i].moduleId, false) then
            buttonInfos[i] = {
                text = TR(TabsConfig[i].name),
                tag = TabsConfig[i].moduleId,
                -- outlineColor = Enums.Color.eBlack,
                titlePosRateY = 0.5,
                fontSize = 22,
            }
        end
    end

    -- 创建标签
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        btnSize = cc.size(103, 49),
        viewSize = cc.size(350, 80),
        normalImage = "c_155.png",
        lightedImage = "c_154.png",
        space = 10,
        needLine = false,
        defaultSelectTag = self.originalTag,
        onSelectChange = function (tag)
            self:changePage(tag)
        end,
        allowChangeCallback = function (pageIndex) return true end
    })
    tabLayer:setPosition(Enums.StardardRootPos.eTabView)
    tabLayer:setAnchorPoint(0, 0.5)
    tabLayer:setPosition(10, 945)
    self:addChild(tabLayer)
    self.mTabs = tabLayer

    -- 添加"小红点"
    local buttons = self.mTabs:getTabBtns()
    self:addBadges(buttons)
end

-- 添加徽记
function BagHeroLayer:addBadges(nodes)
    for tag, node in pairs(nodes) do
        -- 小红点
        local moduleId = ModulesConfig[tag].moduleId
        if ModulesConfig[tag].needRedDot then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(moduleId))
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = node,
                eventName = RedDotInfoObj:getEvents(moduleId)})
        end

        -- 新物品标志
        local function dealNewDotVisible(newSprite)
            newSprite:setVisible(RedDotInfoObj:isNewValid(moduleId))
        end
        ui.createAutoBubble({refreshFunc = dealNewDotVisible, isNew = true, parent = node,
            eventName = RedDotInfoObj:getNewEvents(moduleId)})
    end
end

-- 跳转到分页
function BagHeroLayer:changePage(tag)
    if self.mTabs == nil then
        return
    end

    -- 隐藏当前分页
    if self.mPages[self.mCurTag] ~= nil then
        self.mPages[self.mCurTag]:setVisible(false)
    end

    self.mCurTag = tag
    local page = self.mPages[tag]
    if page ~= nil and not page.needReload then
        -- 页面存在
        page:setVisible(true)
    else
        -- 页面不存在
        self:addPage(tag)
    end

    -- 隐藏面板，显示提示
    if #self.mPages[tag].items == 0 then
        self.mPanelBg:setVisible(false)
        if not self.mEmptyHint then
            self.mEmptyHint = ui.createEmptyHint(TR("该包裹中暂时没有物品"))
            self.mEmptyHint:setPosition(320, 568)
            self.mParentLayer:addChild(self.mEmptyHint)
        end
        self.mEmptyHint:setVisible(true)
    else
        self.mPanelBg:setVisible(true)
        if self.mEmptyHint then
            self.mEmptyHint:setVisible(false)
        end
    end
end

--- ==================== 单个Page相关 =======================
-- 预定义常量
local Page = {
    width = 640,
    height = 900,
    x = 0,
    y = 95,
}

-- 添加新分页(如果对应的页面已经存在，先移除后添加)
function BagHeroLayer:addPage(tag)
    -- 容器
    local page = ccui.Layout:create()
    page:setContentSize(Page.width, Page.height)
    page:setPosition(Page.x, Page.y)

    -- 保存
    self:removePage(tag)
    self.mParentLayer:addChild(page)
    self.mPages[tag] = page
    page.items = {}
    page.moduleId = tag
    page.needReload = false

    -- 显示包裹内的卡牌
    self:addCardsView(page)
    self:refreshCards(page)

    -- 包裹容量信息
    page.bagModelId = ModulesConfig[tag].bagModelId
    self:addCapacityView(page)
    self:refreshBagInfo(page)

    -- 显示卡牌详细信息
    self:addCardDetailView(page)
    self:showCardDetail(page, page.curIndex)
end

-- 删除分页
function BagHeroLayer:removePage(tag)
    if self.mPages[tag] ~= nil then
        self.mParentLayer:removeChild(self.mPages[tag])
        self.mPages[tag] = nil
    end
end

-- 添加包裹容量控件
function BagHeroLayer:addCapacityView(page)
    -- 包裹容量信息
    local textView = ui.newLabel({
        text = "",
        color = cc.c3b(0xd1, 0x7b, 0x00),
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
        -- anchorPoint = cc.p(0, 0.5),
        x = 540,
        y = 845,
    })
    page:addChild(textView)
    page.bagInfoLabel = textView

    -- ”扩充“按钮
    local button = ui.newButton({
        normalImage = "gd_27.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(600, 845),
        -- size = cc.size(125, 57),
        -- text = TR("扩充"),
        textColor = Enums.Color.eWhite,
        clickAction = function()
            MsgBoxLayer.addExpandBagLayer(page.bagModelId, function ()
                self:refreshBagInfo(page)
            end)
        end
    })
    -- button:setScale(0.7)
    page:addChild(button)
    page.expandButton = button
end

local BreakButtonPos = cc.p(550, 115)
local UpgradeButtonPos = cc.p(550, 55)
-- 添加卡牌详细信息控件
function BagHeroLayer:addCardDetailView(page)
    local PosX = 135
    -- 创建空的左方头部
    local head = CardNode.createCardNode({
        cardShowAttrs = {},
    })
    head:setPosition(70, 85)
    page:addChild(head)
    page.head = head
    head:setVisible(false)

    -- 创建空的描述信息控件
    if page.moduleId == ModuleSub.eHero then -- 当为人物模块时
        -- 名字控件
        local label = ui.newLabel({
            text = "",
            anchorPoint = cc.p(0, 0),
            color = Enums.Color.eBrown,
            outlineColor = Enums.Color.eBlack,
            x = PosX,
            y = 90,
        })
        page:addChild(label)
        page.heroNameLabel = label

        -- 资质控件
        label = ui.newLabel({
            text = "",
            anchorPoint = cc.p(0, 0),
            color = Enums.Color.eBrown,
            x = PosX,
            y = 52,
        })
        page:addChild(label)
        page.heroQualityLabel = label

        -- 突破按钮
        local button = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(BreakButtonPos.x, BreakButtonPos.y - 25),
            text = TR("突破"),
            clickAction = function()
                self:gotoModule(page, ModuleSub.eHeroStepUp)
            end
        })
        page:addChild(button)
        page.breakButton = button
        button:setVisible(false)

        -- 升级按钮
        local button = ui.newButton({
            normalImage = "c_28.png",
            position = UpgradeButtonPos,
            text = TR("升级"),
            clickAction = function()
                self:gotoModule(page, ModuleSub.eHeroLvUp)
            end
        })
        page:addChild(button)
        page.upgradeButton = button
        button:setVisible(false)
        button:setScale(0)

    else-- 其他模块
        -- 名字控件
        local label = ui.newLabel({
            text = "",
            anchorPoint = cc.p(0, 0),
            color = Enums.Color.eBrown,
            outlineColor = Enums.Color.eBlack,
            x = PosX,
            y = 90,
        })
        page:addChild(label)
        page.debrisNameLabel = label

        -- 数量控件
        label = ui.newLabel({
            text = "",
            anchorPoint = cc.p(0, 0),
            color = Enums.Color.eBrown,
            x = PosX,
            y = 52,
        })
        page:addChild(label)
        page.debrisNumLabel = label

        -- "获取"按钮
        local button = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(550, 80),
            text = TR("去获取"),
            clickAction = function()
                self:gotoDropWay(page)
            end
        })
        page:addChild(button)
        page.obtainButton = button
        button:setVisible(false)

        -- "合成"按钮
        local button = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(550, 80),
            text = TR("合成"),
            clickAction = function()
                self:requestGoodsUse(page)
            end
        })
        page:addChild(button)
        page.compareButton = button
        button:setVisible(false)

        -- "去幻化"按钮
        local button = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(550, 80),
            text = TR("去幻化"),
            clickAction = function()
                self:gotoIllusion()
            end
        })
        page:addChild(button)
        page.gotoIllusionBtn = button
        button:setVisible(false)
    end
end

--- ==================== GridView相关 =======================
-- 添加显示包裹内卡牌的控件
--common/GridView.lua
function BagHeroLayer:addCardsView(page)
    local items = page.items
    local gridView = require("common.GridView"):create({
        viewSize = cc.size(640, 650),
        colCount = 5,
        celHeight = 114,
        selectIndex = nil,
        needDelay = true,
        getCountCb = function()
            return #items
        end,
        createColCb = function(itemParent, index, isSelected)
            local card = self:createCard(page, index, isSelected)
            if card == nil then return end
            card:setPosition(64, 60)
            itemParent:addChild(card)
            itemParent.card = card
        end,
    })
    gridView:setAnchorPoint(0, 1)
    gridView:setPosition(0, 810)
    page:addChild(gridView)
    page.cardsView = gridView
end

-- 创建卡牌
function BagHeroLayer:createCard(page, index, isSelected)
    local data = page.items[index]
    local showAttrs = {CardShowAttr.eBorder}
    local isInFormation = false
    if page.moduleId == ModuleSub.eHero then
        -- 人物
        table.insert(showAttrs, CardShowAttr.eLevel, CardShowAttr.eMedicine)
        if FormationObj:heroInFormation(data.Id) then
            table.insert(showAttrs, CardShowAttr.eBattle)
            isInFormation = true
        end
    elseif page.moduleId == ModuleSub.eBagHeroDebris then
        -- 人物碎片
        table.insert(showAttrs, CardShowAttr.eNum)
        table.insert(showAttrs, CardShowAttr.eDebris)
        showAttrs.needMaxNum = true
        isInFormation = true
    elseif page.moduleId == ModuleSub.eBagIllusionDebris then
        --幻化+幻化碎片
        local isIllusion = Utility.isIllusion(Utility.getTypeByModelId(data.ModelId))
        if not isIllusion then
            table.insert(showAttrs, CardShowAttr.eDebris, CardShowAttr.eNum)
            showAttrs.needMaxNum = true
        end
    end

    -- 是否选中
    if isSelected then
        table.insert(showAttrs, CardShowAttr.eSelected)
    end

    -- 是否是新卡牌
    if page.moduleId == ModuleSub.eHero and HeroObj:getNewIdObj():IdIsNew(data.Id) then
        table.insert(showAttrs, CardShowAttr.eNewCard)
    elseif page.moduleId == ModuleSub.eBagIllusionDebris and IllusionObj:getNewIdObj():IdIsNew(data.Id) then
        table.insert(showAttrs, CardShowAttr.eNewCard)
    end

    local card = CardNode.createCardNode({
        resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
        instanceData = data,
        cardShowAttrs = showAttrs,
        onClickCallback = function(card) -- 选中卡牌时的操作
            -- 是否有新卡片标志
            local attr = card.mShowAttrControl[CardShowAttr.eNewCard]
            if attr and attr.sprite then
                attr.sprite:setVisible(false)
                self:clearNewId(page.moduleId, data.Id)
            end
            page.curIndex = index
            page.cardsView:setSelect(index)

            self:showCardDetail(page, index)
        end,
    })

    local relationStatus = self.mRelations[data.Id]
    if not isInFormation and relationStatus then
        -- 羁绊状态
        if relationStatus ~= Enums.RelationStatus.eNone then
            local relationStr = {
                [Enums.RelationStatus.eIsMember] = TR("缘份"),     -- 推荐
                [Enums.RelationStatus.eTriggerPr] = TR("可激活"),   -- 缘分
                --[Enums.RelationStatus.eSame] = TR("已存在")       -- 相同
            }
            local relationImage = {
                [Enums.RelationStatus.eIsMember] = "c_57.png",     -- 推荐
                [Enums.RelationStatus.eTriggerPr] = "c_58.png",   -- 缘分
                --[Enums.RelationStatus.eSame] = TR("已存在")       -- 相同
            }
            card:createStrImgMark(relationImage[relationStatus], relationStr[relationStatus])
        end
    end

    if page.moduleId == ModuleSub.eBagHeroDebris then--神将碎片可合成时添加 可合成 标示
        local maxNum = GoodsModel.items[data.ModelId].maxNum
        local isEnough = data.Num >= maxNum
        if isEnough then
            card:setSyntheticMark()
        end
    elseif page.moduleId == ModuleSub.eBagIllusionDebris then
        local isIllusion = Utility.isIllusion(Utility.getTypeByModelId(data.ModelId))
        if not isIllusion then
            local maxNum = GoodsModel.items[data.ModelId].maxNum
            local isEnough = data.Num >= maxNum
            if isEnough then
                card:setSyntheticMark()
            end
        end
    end

    return card
end

--- ==================== 刷新相关 =======================
-- 刷新包裹容量信息
function BagHeroLayer:refreshBagInfo(page)
    local bagTypeInfo = BagModel.items[page.bagModelId]
    local bagInfo = BagInfoObj:getBagInfo(page.bagModelId)
    local text = TR("%s/%s", #page.items, bagInfo.Size)
    page.bagInfoLabel:setString(TR(text))
    local maxBagSize = table.nums(BagExpandUseRelation.items) * bagTypeInfo.perExpandSize + bagTypeInfo.initSize
    page.expandButton:setVisible(maxBagSize > bagInfo.Size)
end

-- 刷新页面卡牌
function BagHeroLayer:refreshCards(page)
    -- 删除旧数据
    for i=#page.items, 1, -1 do
        table.remove(page.items, i)
    end

    -- 加载新数据
    local items = self:getItems(page.moduleId)
    for i=1, #items do
        table.insert(page.items, items[i])
    end
    self:sortItems(page.moduleId, page.items)
    page.cardsView:reloadData()

    -- 更改位置
    local originalData = self.original[page.moduleId]
    self:setCardsPos(page, originalData.id, originalData.pos)
    originalData.id = nil
    originalData.pos = nil
end

-- 获取模块卡牌数据
function BagHeroLayer:getItems(moduleId)
    local items = nil
    if moduleId == ModuleSub.eHero then
        -- 人物
        items = clone(HeroObj:getHeroList())
    elseif moduleId == ModuleSub.eBagHeroDebris then
        items = clone(GoodsObj:getHeroDebrisList())
    elseif moduleId == ModuleSub.eBagIllusionDebris then
        items = clone(IllusionObj:getIllusionList({notInFormation = true}))
        local tempIllusionDebris = clone(GoodsObj:getIllusionDebrisList())
        table.insertto(items, tempIllusionDebris, -1)
    end

    for i, data in ipairs(items) do
        local modelId
        if moduleId == ModuleSub.eHero then
            -- 人物
            modelId = data.ModelId
        elseif moduleId == ModuleSub.eBagHeroDebris then
            modelId = GoodsModel.items[data.ModelId].outputModelID
        elseif modelId == ModuleSub.eBagIllusionDebris then
            local isGoods = Utility.getTypeByModelId(data.ModelId) == ResourcetypeSub.eIllusionDebris
            if isGoods then
                modelId = GoodsModel.items[data.ModelId].ID
            else
                modelId = IllusionModel.items[data.ModelId].ID
            end
        end

        -- 羁绊状态
        local relationStatus = FormationObj:getRelationStatus(modelId, ResourcetypeSub.eHero)
        self.mRelations[data.Id] = relationStatus

        if self.mRelations[data.Id] == Enums.RelationStatus.eSame then
            self.mRelations[data.Id] = Enums.RelationStatus.eNone
        end
    end

    return items or {}
end

-- 卡牌排序
function BagHeroLayer:sortItems(moduleId, items)
    if moduleId == ModuleSub.eHero then
        -- 人物
        table.sort(items, function(a, b)
            -- 是否是主角
            local isMainHeroA = HeroModel.items[a.ModelId].specialType == Enums.HeroType.eMainHero
            local isMainHeroB = HeroModel.items[b.ModelId].specialType == Enums.HeroType.eMainHero
            if isMainHeroA ~= isMainHeroB then
                return isMainHeroA
            end

            -- 是否上阵
            local aIsInFormation = FormationObj:heroInFormation(a.Id)
            local bIsInFormation = FormationObj:heroInFormation(b.Id)
            if aIsInFormation and not bIsInFormation then return true end
            if bIsInFormation and not aIsInFormation then return false end
            
            -- 幻化过的神将资质更高，优先靠前
            local isIllusionA = a.IllusionModelId ~= nil and a.IllusionModelId > 0
            local isIllusionB = b.IllusionModelId ~= nil and b.IllusionModelId > 0
            if isIllusionA ~= isIllusionB then
                return isIllusionA
            end

            -- 资质排序
            if HeroModel.items[a.ModelId].quality ~= HeroModel.items[b.ModelId].quality then
                return HeroModel.items[a.ModelId].quality > HeroModel.items[b.ModelId].quality
            end
            -- 缘分
            if self.mRelations[a.Id] ~= self.mRelations[b.Id] then
                return self.mRelations[a.Id] > self.mRelations[b.Id]
            end
            -- 卡牌等级
            if a.Lv ~= b.Lv then return a.Lv > b.Lv end
            -- 卡牌模型
            if a.ModelId ~= b.ModelId then return a.ModelId < b.ModelId end
            return a.Id < b.Id
        end)
    elseif moduleId == ModuleSub.eBagHeroDebris then
        -- 人物碎片
        table.sort(items, function(a, b)
            local aEnough = (a.Num >= GoodsModel.items[a.ModelId].maxNum)
            local bEnough = (b.Num >= GoodsModel.items[b.ModelId].maxNum)
            if aEnough and not bEnough then
                return true
            elseif not aEnough and bEnough then
                return false
            end
            --资质排序
            if GoodsModel.items[a.ModelId].quality ~= GoodsModel.items[b.ModelId].quality then
                return GoodsModel.items[a.ModelId].quality > GoodsModel.items[b.ModelId].quality
            end

            -- 缘分
            if self.mRelations[a.Id] ~= self.mRelations[b.Id] then
                return self.mRelations[a.Id] > self.mRelations[b.Id]
            end
            -- 卡牌数量
            if a.Num ~= b.Num then return a.Num > b.Num end
            -- 卡牌模型
            if a.ModelId ~= b.ModelId then return a.ModelId < b.ModelId end
            return a.Id < b.Id
        end)
    elseif moduleId == ModuleSub.eBagIllusionDebris then
        --幻化和幻化碎片
        table.sort(items, function(a, b)
            local isGoodsA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.eIllusionDebris
            local isIllusionA = Utility.getTypeByModelId(a.ModelId) == ResourcetypeSub.eIllusion
            local isGoodsB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.eIllusionDebris
            local isIllusionB = Utility.getTypeByModelId(b.ModelId) == ResourcetypeSub.eIllusion
            -- 可以合成的碎片排在最前面
            if isGoodsA and GoodsModel.items[a.ModelId].maxNum == a.Num and (isIllusionB or GoodsModel.items[b.ModelId].maxNum ~= b.Num) then
                return true
            elseif isGoodsB and GoodsModel.items[b.ModelId].maxNum == b.Num and (isIllusionA or GoodsModel.items[a.ModelId].maxNum ~= a.Num) then
                return false
            end

            -- 幻化排在幻化碎片前面
            if isIllusionA and isGoodsB then
                return true
            elseif isIllusionB and isGoodsA then
                return false
            end

            if isIllusionA and isIllusionB then
                -- 高品质幻化排在前面
                if IllusionModel.items[a.ModelId].quality ~= IllusionModel.items[b.ModelId].quality then
                    return IllusionModel.items[a.ModelId].quality > IllusionModel.items[b.ModelId].quality
                end

                -- 比较模型id
                return a.ModelId > b.ModelId
            elseif isGoodsA and isGoodsB then
                -- -- 高品质碎片排在前面
                if GoodsModel.items[a.ModelId].quality ~= GoodsModel.items[a.ModelId].quality then
                    return GoodsModel.items[a.ModelId].quality > GoodsModel.items[a.ModelId].quality
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
    end
end

-- 设置初始位置
function BagHeroLayer:setCardsPos(page, originalId, originalPos)
    -- 按ID选中卡牌
    page.curIndex = nil
    if originalId ~= nil then
        for index=1, #page.items do
            if page.items[index].Id == originalId then
                page.curIndex = index
            end
        end
    end

    if page.curIndex == nil and #page.items ~= 0 then page.curIndex = 1 end
    if page.curIndex ~= nil then
        page.cardsView:setSelect(page.curIndex)
    end

    -- 设置滑动位置
    if originalPos ~= nil then
        page.cardsView.mScrollView:getInnerContainer():setPosition(originalPos)
    end
end

--- ==================== 卡牌详细信息相关 =======================
-- 显示选中卡牌信息
function BagHeroLayer:showCardDetail(page, index)
    if index == nil then return end
    if page.moduleId == ModuleSub.eHero then
        -- 人物
        self:showHeroDetail(page, index)
    elseif page.moduleId == ModuleSub.eBagHeroDebris then
        -- 人物碎片
        self:showHeroDebrisDetail(page, index)
    elseif page.moduleId == ModuleSub.eBagIllusionDebris then
        local data = page.items[index]
        local isIllusion = Utility.isIllusion(Utility.getTypeByModelId(data.ModelId))
        if isIllusion then
            self:showIllusionDetail(page, index)
        else
            self:showHeroDebrisDetail(page, index)
        end
    end
end

-- 显示选中人物卡牌信息
function BagHeroLayer:showHeroDetail(page, index)
    local data = page.items[index]
    local heroBase = HeroModel.items[data.ModelId]

    -- 更改头像显示
    local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eMedicine}
    if FormationObj:heroInFormation(data.Id) then
        table.insert(showAttrs, CardShowAttr.eBattle)
    end
    page.head:setHero(data, showAttrs)
    page.head:setVisible(true)

    -- 更改名字显示
    local tempName, tempStep = ConfigFunc:getHeroName(data.ModelId, {heroStep = data.Step, IllusionModelId = data.IllusionModelId, heroFashionId = data.CombatFashionOrder})
    if tempStep > 0 then
        tempName = tempName .. "+".. tempStep
    end
    local tempColorH = Utility.getQualityColor(heroBase.quality, 2)
    local strName = tempColorH .. tempName

    if (data.IllusionModelId ~= nil) and (data.IllusionModelId > 0) then
        strName = strName .. Enums.Color.eNormalWhiteH .. TR("（幻化于%s%s%s）", tempColorH, heroBase.name, Enums.Color.eNormalWhiteH)
    end
    page.heroNameLabel:setString(strName)

    -- 更改资质显示
    page.heroQualityLabel:setString(TR("称号: ") .. Utility.getHeroColorName(heroBase.quality))

    -- 更改按钮显示
    local offsetY = 27
    local breakButtonVisible = true
    local upgradeButtonVisible = true
    local breakButtonPos
    local upgradeButtonPos
    if heroBase.specialType == Enums.HeroType.eMainHero then
        upgradeButtonVisible = false
        breakButtonPos = cc.p(BreakButtonPos.x, BreakButtonPos.y - offsetY)
    else
        local heroStepItem = HeroStepRelation.items[heroBase.stepUpClassID * 1000 + data.Step]
        if not heroStepItem then
            breakButtonVisible = false
            upgradeButtonPos = cc.p(UpgradeButtonPos.x, UpgradeButtonPos.y + offsetY)
        end
    end

    self:playButtonMove(page.breakButton, breakButtonPos or BreakButtonPos)
    self:playButtonMove(page.upgradeButton, upgradeButtonPos or UpgradeButtonPos)

    self:playButtonVisible(page.breakButton, breakButtonVisible)
    self:playButtonVisible(page.upgradeButton, upgradeButtonVisible)
end

-- 显示选中人物碎片卡牌信息
function BagHeroLayer:showHeroDebrisDetail(page, index)
    local data = page.items[index]

    -- 更改头像显示
    page.head:setGoods(data, {CardShowAttr.eBorder, CardShowAttr.eDebris})
    page.head:setVisible(true)

    -- 更改名字显示
    local text = Utility.getQualityColor(GoodsModel.items[data.ModelId].quality, 2)
    text = text .. GoodsModel.items[data.ModelId].name
    page.debrisNameLabel:setString(text)

    -- 更改数量显示
    local maxNum = GoodsModel.items[data.ModelId].maxNum
    text = Enums.Color.eBrownH .. TR("数量:")
    local isEnough = data.Num >= maxNum
    if isEnough then
        text = text .. "#249029" .. data.Num .. "/" .. maxNum .. TR("(可以合成)")
    else
        text = text .. Enums.Color.eRedH .. data.Num .. "/" .. maxNum .. TR("(数量不足)")
    end
    page.debrisNumLabel:setString(TR(text))

    -- 更改按钮显示
    page.obtainButton:setVisible(not isEnough)
    page.compareButton:setVisible(isEnough)
    page.gotoIllusionBtn:setVisible(false)
end

-- 显示选中幻化卡牌信息
function BagHeroLayer:showIllusionDetail(page, index)
    local data = page.items[index]

    -- 更改头像显示
    page.head:setIllusion(data, {CardShowAttr.eBorder})
    page.head:setVisible(true)

    -- 更改名字显示
    local text = Utility.getQualityColor(IllusionModel.items[data.ModelId].quality, 2)
    text = text .. IllusionModel.items[data.ModelId].name
    page.debrisNameLabel:setString(text)
    page.debrisNumLabel:setString("")

    page.gotoIllusionBtn:setVisible(true)
end


--- ==================== 特效相关 =======================
-- 按钮移动
function BagHeroLayer:playButtonMove(button, pos)
    button:setVisible(true)
    local move = cc.MoveTo:create(0.25, pos)
    button:runAction(cc.EaseSineOut:create(move))
end

-- 按钮隐藏或显示
function BagHeroLayer:playButtonVisible(button, visible)
    button:setVisible(true)
    button:setTouchEnabled(visible)
    local move = cc.ScaleTo:create(0.25, visible and 1 or 0)
    button:runAction(cc.EaseSineOut:create(move))
end

-- 突破/升级按钮
function BagHeroLayer:gotoModule(page, moduleId)
    -- local data = {}
    -- for i=1, #page.items do
    --     table.insert(data, page.items[i])
    -- end
    self.mParent.mThirdSubTag = ModuleSub.eHero

    -- 注意：此处禁止传递背包里的全部人物列表，因为培养界面使用模型ID来区分不同人物，如果列表里有相同的模型会出错
    LayerManager.showSubModule(moduleId, {
        heroesData = {page.items[page.curIndex]},
        originalTag = moduleId,
    })
end

-- 去获取页面
function BagHeroLayer:gotoDropWay(page)
    local data = page.items[page.curIndex]
    if page.moduleId == ModuleSub.eBagHeroDebris then
        self.mParent.mThirdSubTag = ModuleSub.eBagHeroDebris
        
        LayerManager.addLayer({
            name = "hero.DropWayLayer",
            data = {
                resourceTypeSub = ModulesConfig[page.moduleId].resourceTypeSub,
                modelId = data.ModelId
            },
            cleanUp = false,
        })
    elseif page.moduleId == ModuleSub.eBagIllusionDebris then
        self.mParent.mThirdSubTag = ModuleSub.eBagIllusionDebris
         LayerManager.addLayer({
            name = "hero.DropWayLayer",
            data = {
                resourceTypeSub = ModulesConfig[page.moduleId].resourceTypeSub,
                modelId = data.ModelId
            },
            cleanUp = false,
        })
    end
end

--去幻化
function BagHeroLayer:gotoIllusion()
    self.mParent.mThirdSubTag = ModuleSub.eBagIllusionDebris
    LayerManager.showSubModule(ModuleSub.eIllusion, {
        originalTag = ModuleSub.eIllusion,
        originalId = FormationObj:getSlotInfoBySlotId(2).HeroId
    })
end

--- ==================== 数据相关 =======================
--
function BagHeroLayer:clearNewId(tag, instanceId)
    if tag == ModuleSub.eHero then
        HeroObj:clearNewId(instanceId)
    elseif tag == ModuleSub.eBagIllusionDebris then
        IllusionObj:clearNewId(instanceId)
    end
end

-- 保存位置
function BagHeroLayer:getRestoreData()
    local tag = self.mCurTag
    local page = self.mPages[tag]

    if #(page.items) == 0 then return {} end

    local restoreData = {
        tag = tag,
        id = page.items[page.curIndex].Id,
        scrollPos = cc.p(page.cardsView.mScrollView:getInnerContainer():getPosition())
    }
    return restoreData
end

-- 退出
function BagHeroLayer:onExit()
    self:clearNewId(ModuleSub.eHero)
    -- self:clearNewId(ModuleSub.eBagIllusionDebris)
end

--- ==================== 服务器数据请求相关 =======================
-- 合成碎片数据请求
function BagHeroLayer:requestGoodsUse(page)
    local data = page.items[page.curIndex]

    HttpClient:request({
        moduleName = "Goods",
        methodName = "GoodsUse",
        svrMethodData = {data.Id, data.ModelId, GoodsModel.items[data.ModelId].maxNum},
        callback = function(response)
            if response.Status == 0 then
                -- 如果是合成人物碎片
                if page.moduleId == ModuleSub.eBagHeroDebris then
                    -- 有可能此时侠客Layer尚未创建
                    if not tolua.isnull(self.mPages[ModuleSub.eHero]) then
                        self.mPages[ModuleSub.eHero].needReload = true
                    end

                    local value = response.Value
                    LayerManager.addLayer({
                        name = "compose.ComposeResultLayer",
                        data = {
                            baseGetGameResourceList = value and value.BaseGetGameResourceList or {},
                            resourceTypeSub = ResourcetypeSub.eHero,
                        },
                        cleanUp = false,
                    })
                elseif page.moduleId == ModuleSub.eBagIllusionDebris then
                    -- 有可能此时侠客Layer尚未创建
                    local value = response.Value
                    LayerManager.addLayer({
                        name = "compose.ComposeResultLayer",
                        data = {
                            baseGetGameResourceList = value and value.BaseGetGameResourceList or {},
                            resourceTypeSub = ResourcetypeSub.eIllusion,
                        },
                        cleanUp = false,
                    })
                end

                page.needReload = true
                self:changePage(page.moduleId)
            end
        end
    })
end
--]]
return BagHeroLayer
