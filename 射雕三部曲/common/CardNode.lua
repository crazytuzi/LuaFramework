--[[
    文件名：CardNode
    描述：卡牌显示对象，可以创建主将大卡、主将小卡、装备大卡、装备小卡、道具、商品...
    创建人：peiyaoqiang
    创建时间：2017.03.02
--]]

-- 卡牌需要显示属性的枚举
CardShowAttr = {
    eBorder = -2, -- 卡牌资质框
    eBgHero = -1, -- 显示一个人物背景
    eAddMark = 0, -- 空卡牌的加号标识
    eSelected = 1, -- 选中标识
    eDebris = 2, -- 碎片标识
    eBattle = 3, -- 已上阵标识
    eName = 4, -- 卡牌的名称或人物属性名称
    eSynthetic = 5, -- 可合成标识
    eLevel = 7, -- 卡牌强化等级
    eStep = 8, -- 卡牌进阶等级
    eStar = 9, -- 卡牌星星
    eQuality = 10, -- 显示资质
    eNum = 12, -- 数量
    ePercent = 13, -- 内功心法的洗炼进度百分比
    eZhenjueType = 15, -- 内功心法的类型标识
    eNewCard = 16, -- 新卡牌标识
    eMedicine = 17, -- 吃丹标识
}

--[[
--
 ]]
CardNode = class("CardNode", function()
    return ccui.Layout:create()
end)

-- 卡牌默认点击事件函数
local defaultCardClick
--
local shareTextureCache = cc.Director:getInstance():getTextureCache()
-- 小卡的默认大小的参考图片
local defSmallSizeRef = "c_04.png"

--[[
-- params参数说明
    {
        cardShape: 卡牌的形状，取值在Enums.lua 文件的 Enums.CardShape中定义，默认为：Enums.CardShape.eCircle
        allowClick = false, --是否可点击, 默认为false
        nameColor = nil,    -- 卡牌名字的颜色，默认为: Enums.Color.eCoffee
        touchCallback = nil,
        onClickCallback = nil,  -- 点击事件回调
        nameNeedRoll = true,-- 名字超长是否自动滚动
    }
]]--
function CardNode:ctor(params)
    params = params or {}
    self.mCardShape = params.cardShape or Enums.CardShape.eCircle
    self.mNameColor = params.nameColor or Enums.Color.eCoffee
    self.mAllowClick = params.allowClick
    self.onClickCallback = params.onClickCallback
    self.nameNeedRoll = (params.nameNeedRoll ~= false)

    -- 记录当前卡牌是否为灰色卡牌
    self.mIsGray = false


    -- 显示卡牌属性的控件列表，以枚举 CardShowAttr 中的值作为下标
    self.mShowAttrControl = {}

    local tempSize = ui.getImageSize(defSmallSizeRef)
    self.mWidth, self.mHeight = tempSize.width, tempSize.height
    self:setContentSize(tempSize)
    --
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setIgnoreAnchorPointForPosition(false)

    self:setOnTouch(params.touchCallback)
end

-- 创建通用类型CardNode辅助函数
--[[
-- 参数params中的各项为：
    {
        resourceTypeSub = nil, -- 资源类型
        modelId = nil,  -- 模型Id
        fashionModelID = nil或0, -- 时装Id, 仅hero时有效
        num = nil, -- 资源数量
        nameColor = nil, -- 卡牌名字的颜色，默认为: Enums.Color.eCoffee
        cardShowAttrs = {}, -- 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
        instanceData = {}, -- 卡牌的具体数据（人物、装备、道具、碎片、主角技能、星宿等在缓存中的数据）
        needGray: 是否需要显示为灰色， 默认为false

        cardShape: 卡牌的形状，取值在Enums.lua 文件的 Enums.CardShape中定义，默认为：Enums.CardShape.eSquare
        allowClick = nil, --是否可点击
        specialName = "", -- 卡牌显示的特殊名称
        onClickCallback = nil, --点击回调函数，默认为卡牌点击展示其属性
    }
-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
]]
function CardNode.createCardNode(params)
    local ret = CardNode:create({
        cardShape = params.cardShape,
        nameColor = params.nameColor,
        allowClick = params.allowClick,
        onClickCallback = params.onClickCallback,
    })
    local retAttr = ret:setCardData(params)

    return ret, retAttr
end

-- 设置卡牌数据
--[[
-- 参数params中的各项为：
    {
        resourceTypeSub = nil, -- 资源类型
        modelId = nil,  -- 模型Id
        fashionModelID = nil或0, -- 时装Id, 仅hero时有效
        num = nil, -- 资源数量
        imgName: 当为空卡牌时的图片名，默认为 cardNode默认的图片
        extraImgName: 当为空卡牌时的额外图片名，默认为 cardNode默认的图片
        cardShowAttrs = {}, -- 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
        instanceData = {}, -- 卡牌的具体数据（人物、装备、道具、碎片、主角技能、星宿等在缓存中的数据）
        specialName = "", -- 卡牌显示的特殊名称
        needGray: 是否需要显示为灰色， 默认为false

        onClickCallback = nil
    }
-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
]]
function CardNode:setCardData(params)
    local resType = params.resourceTypeSub or params.resourcetypeSub or params.ResourceTypeSub or params.ResourcetypeSub
    local num = params.num or params.Num or params.count or params.Count
    local modelId = params.modelId or params.ModelId or params.modelID or params.ModelID
    local PvpInterLv = params.pvpInterLv or params.PVPInterLv
    local instanceData = params.instanceData
    if Utility.isHero(resType) or Utility.isHeroInstance(instanceData) then    -- "人物"
        if not (instanceData and (instanceData.ModelID or instanceData.ModelId)) then
            instanceData = {ModelId = modelId, Num = num, pvpInterLv = PvpInterLv}
        end
        instanceData.FashionModelID = params.fashionModelID
        if (params.IllusionModelId ~= nil) and (params.IllusionModelId > 0) then
            instanceData.IllusionModelId = params.IllusionModelId
        end
        self:setHero(instanceData, params.cardShowAttrs, params.specialName)
    elseif Utility.isEquip(resType) or Utility.isEquipInstance(instanceData) then  -- "装备"
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setEquipment(instanceData, params.cardShowAttrs)
        else
            self:setEquipment({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isTreasure(resType) or Utility.isTreasureInstance(instanceData) then  -- 神兵
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setTreasure(instanceData, params.cardShowAttrs)
        else
            self:setTreasure({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif  Utility.isGoods(resType, true) or Utility.isGoodsInstance(instanceData, true) then   -- 包含人物碎片和装备碎片的goods
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setGoods(instanceData, params.cardShowAttrs)
        else
            self:setGoods({GoodsModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isTresureDebris(resType) or Utility.isTresureDebrisInstance(instanceData) then    -- "神兵碎片"
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setTreasureDebris(instanceData, params.cardShowAttrs)
        else
            self:setTreasureDebris({TreasureDebrisModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isZhenjue(resType) then  -- 内功心法
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setZhenjue(instanceData, params.cardShowAttrs)
        else
            self:setZhenjue({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isZhenyuan(resType) then  -- 真元
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setZhenyuan(instanceData, params.cardShowAttrs)
        else
            self:setZhenyuan({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isPet(resType) then  -- 外功秘籍
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setPet(instanceData, params.cardShowAttrs)
        else
            self:setPet({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isPlayerAttr(resType) or resType == ResourcetypeSub.eRawGold then -- 玩家属性
        self:setPlayerAttr({ResourceTypeSub = resType, Num = num}, params.cardShowAttrs)
    elseif Utility.isSectBook(resType) then -- 门派招式
        self:setSectBook(modelId, params.cardShowAttrs)
    elseif Utility.isFashion(resType) then -- 时装绝学
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setFashion(instanceData, params.cardShowAttrs)
        else
            self:setFashion({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isIllusion(resType) then -- 幻化
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setIllusion(instanceData, params.cardShowAttrs)
        else
            self:setIllusion({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isZhenshou(resType) or Utility.isZhenshouInstance(instanceData) then -- 珍兽
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setZhenshou(instanceData, params.cardShowAttrs)
        else
            self:setZhenshou({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isShiZhuang(resType) or Utility.isShiZhuangInstance(instanceData) then -- Q版时装
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setQFashion(instanceData, params.cardShowAttrs)
        else
            self:setQFashion({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif Utility.isImprint(resType) or Utility.isImprintInstance(instanceData) then -- 宝石
        if instanceData and (instanceData.ModelID or instanceData.ModelId) then
            self:setImprint(instanceData, params.cardShowAttrs)
        else
            self:setImprint({ModelId = modelId, Num = num}, params.cardShowAttrs)
        end
    elseif HeroFashionRelation.items[modelId] then -- 侠客时装头像
        if not (instanceData and (instanceData.ModelID or instanceData.ModelId)) then
            instanceData = {ModelId = modelId, Num = num, pvpInterLv = PvpInterLv}
        end
        instanceData.FashionModelID = params.fashionModelID
        if (params.IllusionModelId ~= nil) and (params.IllusionModelId > 0) then
            instanceData.IllusionModelId = params.IllusionModelId
        end
        self:setHero(instanceData, params.cardShowAttrs, params.specialName)
    else
        self.mInstanceData = params
        self:setEmpty(params.cardShowAttrs, params.imgName, params.extraImgName)
    end

    if params.onClickCallback then
        self:setClickCallback(params.onClickCallback)
    end

    -- 如果需要灰色显示，则设置为灰色
    self:setGray(params.needGray == true)

    return self.mShowAttrControl
end

--- 设置卡牌为主将
--[[
-- 参数:
    heroInfo: 人物属性数据，其中的字段为：
        {
            Id = "",       -- 实例Id(可选参数)，
            ModelId = 12010001, -- 模型Id(如果该字段为nil或为0，表示空卡牌)
            FashionModelID = nil或0， -- 时装id
            IllusionModelId = nil或0， -- 幻化id
            Lv = 1, -- 等级
            Step = 1, -- 品阶
            ...

            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        },

    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
    specialHeroName = nil, -- 特殊人物的名称，比如主角的名称是玩家名

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setHero(heroInfo, cardShowAttrs, specialHeroName)
    self.mResourceTypeSub = ResourcetypeSub.eHero
    self.mModelId = heroInfo and (heroInfo.ModelId or heroInfo.ModelID or heroInfo.HeroModelId) or 0
    self.mInstanceData = heroInfo
    self:removeCardChild()

    -- 侠客时装头像还是用原来的
    if HeroFashionRelation.items[self.mModelId] then
        self.mModelId = HeroFashionRelation.items[self.mModelId].modelId
    end

    -- 有时候玩家修改了头像，服务器会直接传递绝学或幻化的模型ID，这里需要处理
    local tmpResType = math.floor(self.mModelId / 10000)
    local tempModel = HeroModel.items[self.mModelId]
    local tempQuality, cardImg = 0, nil
    local tempIsMainHero = false

    if Utility.isFashion(tmpResType) then 
        -- 直接传入时装绝学
        tempQuality = FashionModel.items[self.mModelId].quality
        cardImg = ConfigFunc:getHeroSmallPic(self.mModelId, heroInfo.Step)
    elseif Utility.isIllusion(tmpResType) then
        -- 直接传入幻化
        tempQuality = IllusionConfig.items[1].needHeroQuality
        cardImg = IllusionModel.items[self.mModelId].smallPic .. ".png"
    else
        -- 直接传入侠客
        if not tempModel then
            self:setError(heroInfo.ModelId)
            return self.mShowAttrControl
        end
        tempQuality = tempModel.quality
        tempIsMainHero = (tempModel.specialType == Enums.HeroType.eMainHero)
        if (heroInfo.FashionModelID ~= nil) and (heroInfo.FashionModelID > 0) and (tempIsMainHero == true) then
            cardImg = ConfigFunc:getHeroSmallPic(heroInfo.FashionModelID, heroInfo.Step)
        else
            local illusionModel = IllusionModel.items[(heroInfo.IllusionModelId or 0)] or {}
            cardImg = (illusionModel.smallPic ~= nil) and (illusionModel.smallPic .. ".png") or ConfigFunc:getHeroSmallPic(self.mModelId, heroInfo.Step)
        end
    end
    self:setCardImage(cardImg, heroInfo.pvpInterLv)
    
    -- 设置需要显示的卡牌属性
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            if ConfigFunc:heroIsShenjiang(self.mModelId) then
                self:setCardBorder(tempQuality, nil, "c_09.png")
                self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), Utility.getQualityColorLv(tempQuality))
            else
                self:setCardBorder(tempQuality)
            end
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = specialHeroName
            if not tempName or tempName == "" then
                tempName = ConfigFunc:getHeroName(self.mModelId)

                -- 单独处理主角和幻化
                if (tempIsMainHero == true) then
                    local mainSlot = FormationObj:getSlotInfoBySlotId(1)
                    if heroInfo.Id and heroInfo.Id == mainSlot.HeroId then
                        tempName = PlayerAttrObj:getPlayerAttrByName("PlayerName")
                    end
                else
                    local illusionModel = IllusionModel.items[(heroInfo.IllusionModelId or 0)]
                    if (illusionModel ~= nil) and (illusionModel.name ~= nil) then
                        tempName = illusionModel.name
                    end
                end
            end
            self:setCardName(tempName, tempQuality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(heroInfo.Num and heroInfo.Num > 0 and heroInfo.Num or nil)
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eLevel then -- 卡牌强化等级
            self:setCardLevel(heroInfo.Lv)
        elseif item == CardShowAttr.eStep then -- 卡牌进阶等级
            self:setCardStep(heroInfo.Step)
        elseif item == CardShowAttr.eQuality then
            self:setCardQuality(tempQuality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eMedicine then
            if next(heroInfo.MedicineStrInfo) then
               self:setMedicineTag() 
            end
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置卡牌为goods（包含道具、装备碎片，但不包含神兵碎片）
--[[
-- 参数：
    goodsInfo: goods属性数据，其中字段为：
        {
            Id = "", -- 实体Id
            GoodsModelId = 0, -- 道具模型Id
            Num = 0, -- 数量
        }

    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setGoods(goodsInfo, cardShowAttrs)
    self.mModelId = goodsInfo and (goodsInfo.GoodsModelId or goodsInfo.ModelId or goodsInfo.ModelID) or 0
    self.mInstanceData = goodsInfo
    self:removeCardChild()

    local tempModel
    if math.floor(self.mModelId / 100000) == 169 then
        tempModel = GoodsVoucherModel.items[self.mModelId]
    else
        tempModel = GoodsModel.items[self.mModelId]
    end
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = tempModel.typeID

    local heroModel = nil
    -- 默认需要显示资质框
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
    if Utility.isDebris(tempModel.typeID) then
        if not table.indexof(cardShowAttrs, CardShowAttr.eDebris) then
            table.insert(cardShowAttrs, CardShowAttr.eDebris)
        end
        if Utility.isHeroDebris(tempModel.typeID) then
            heroModel = HeroModel.items[tempModel.outputModelID]
        end
    end

    -- 设置道具图片
    self:setCardImage(tempModel.pic .. ".png") -- 设置人物图像

    -- 设置需要显示的卡牌属性
    -- 资源类型
    local resType = math.floor(tempModel.typeID / 100)
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            if Utility.isHeroDebris(tempModel.typeID) then
                if ConfigFunc:heroIsShenjiang(heroModel.ID) then
                    self:setCardBorder(tempModel.quality, nil, "c_09.png")
                    self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), Utility.getQualityColorLv(tempModel.quality))
                else
                    self:setCardBorder(tempModel.quality)
                end
            elseif Utility.isEquipDebris(tempModel.typeID) then
                local equipModel = EquipModel.items[tempModel.outputModelID]

                if equipModel.equipGroupID > 0 then
                    self:setCardBorder(tempModel.quality)
                    self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), Utility.getQualityColorLv(tempModel.quality))
                else
                    self:setCardBorder(tempModel.quality)
                end
            else
                self:setCardBorder(tempModel.quality)
            end
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            self:setCardName(tempModel.name, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            if Utility.isDebris(tempModel.typeID) and cardShowAttrs.needMaxNum then
                self:setCardCount(goodsInfo.Num, tempModel.maxNum)
            else
                self:setCardCount(goodsInfo.Num)
            end
        elseif item == CardShowAttr.eDebris then -- 碎片标识
            if Utility.isDebris(tempModel.typeID) then
                self:setDebrisMark()
            end
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eSynthetic then -- 可合成标识
            if Utility.isDebris(tempModel.typeID) and goodsInfo.Num and goodsInfo.Num >= tempModel.maxNum then
                self:setSyntheticMark()
            end
        elseif item == CardShowAttr.eQuality then
            self:setCardQuality(tempModel.quality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 奖状 道具左上角显示标识
    if tempModel.typeID == ResourcetypeSub.eDiploma then
        -- local tempSprite = ui.newSprite("sx_15.png")
        -- tempSprite:setAnchorPoint(cc.p(0, 1))
        -- tempSprite:setPosition(cc.p(0, self.mHeight))
        -- self:addChild(tempSprite, CardShowAttr.eDebris)
    end

    -- 淬体丹药列表
    local cuitiTable = {
        [16110305] = true,
        [16110306] = true,
        [16110605] = true,
        [16110606] = true,
        [16111005] = true,
        [16111006] = true,
        [16111305] = true,
        [16111306] = true,
        [16112005] = true,
        [16112006] = true,
        [16112505] = true,
        [16112506] = true,
    }
    -- 淬体丹药加溜边
    if cuitiTable[self.mModelId] then
        self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), Utility.getQualityColorLv(tempModel.quality))
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

-- 设置卡牌为神兵碎片
--[[
-- 参数：
    treasureDebrisInfo: 神兵碎片属性数据，其中字段为：
        {
            Id = "", -- 实体ID
            TreasureDebrisModelId = 0, -- 神兵碎片模型Id
            Num = 0, -- 数量
        }

    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setTreasureDebris(treasureDebrisInfo, cardShowAttrs)
    self.mModelId = treasureDebrisInfo and (treasureDebrisInfo.TreasureDebrisModelId or treasureDebrisInfo.ModelId or treasureDebrisInfo.ModelID) or 0
    self.mInstanceData = treasureDebrisInfo
    self:removeCardChild()

    local tempModel = TreasureDebrisModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = tempModel.typeID

    -- 设置神兵碎片的图像
    self:setCardImage(tempModel.pic .. ".png")

    -- 神兵碎片对应的神兵
    local treasureModel = TreasureModel.items[tempModel.treasureModelID]
    -- 设置需要显示的卡牌属性
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(treasureModel and treasureModel.quality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            self:setCardName(tempModel.name, treasureModel and treasureModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(treasureDebrisInfo.Num)
        elseif item == CardShowAttr.eDebris then -- 碎片标识
            self:setDebrisMark()
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eQuality then
            self:setCardQuality(treasureModel and treasureModel.quality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置物品道具卡牌(道具、人物碎片、装备碎片、徽章碎片、兵书碎片)
--[[
-- 参数
    resourcetypeSub：物品道具的资源类型(道具或碎片, 默认为道具)
    propsInfo:
        当 resourcetypeSub 不为 eBookDebris和 eHorseDebris 时，其中当字段为：
        {
            Id = "", -- 实体Id
            GoodsModelId = 0, -- 道具模型Id
            Num = 0, -- 数量
        },
        当 resourcetypeSub 为 eBookDebris 或 eHorseDebris 时，其中当字段为：
        {
            Id = "", -- 实体ID
            TreasureDebrisModelId = 0, -- 神兵碎片模型Id
            Num = 0, -- 数量
        }

    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setProps(propsInfo, resourcetypeSub, cardShowAttrs)
    if not propsInfo then
        return self.mShowAttrControl
    end

    if Utility.isTresureDebris(resourcetypeSub) then
        self:setTreasureDebris(propsInfo, cardShowAttrs)
    else
        self:setGoods(propsInfo, cardShowAttrs)
    end

    return self.mShowAttrControl
end

--- 设置装备卡牌
--[[
-- 参数
    equipInfo: 装备属性数据，其中包含的字段为：
        {
            Id = "", -- 实体Id
            ModelId = 0, -- 模型Id
            Lv = 0, -- 强化等级
            Step = 0, -- 进阶等级
            Gold = 0, -- 炼化时返还的铜币数
            EquipPrefixId = 0, -- 前缀模型Id

            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        }

   cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setEquipment(equipInfo, cardShowAttrs)
    self.mModelId = equipInfo and (equipInfo.ModelId or equipInfo.EquipModelId or equipInfo.ModelID) or 0
    self.mInstanceData = equipInfo
    self:removeCardChild()

    local tempModel = EquipModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = tempModel.typeID

    -- 设置装备图片
    self:setCardImage(tempModel.minPic .. ".png")

    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            if equipInfo.EquipPrefixId then
                local preModel = EquipPrefixModel.items[equipInfo.EquipPrefixId]
                if preModel then
                   tempName = string.format("%s.%s", preModel.name, tempModel.name)
                end
            end
            self:setCardName(tempName, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(equipInfo.Num and equipInfo.Num > 0 and equipInfo.Num or nil)
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eLevel then -- 卡牌强化等级
            self:setCardLevel(equipInfo.Lv)
        elseif item == CardShowAttr.eStep then -- 卡牌进阶等级
            self:setCardStep(equipInfo.Step)
        elseif item == CardShowAttr.eStar then -- 卡牌星星
            self:setCardStar()
        elseif item == CardShowAttr.eQuality then
            self:setCardQuality(tempModel.quality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end
    -- 套装特效
    if tempModel.equipGroupID > 0 then
        self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), Utility.getQualityColorLv(tempModel.quality))
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置神兵卡牌
--[[
-- 参数
    treasureInfo: 神兵属性，其中包含的字段为：
        {
            Id = "", -- 实体Id
            ModelID = 0, -- 模型Id
            Lv = 0, -- 强化等级(LV)
            Step = 0, -- 精炼等级(Step)

            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        }

    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setTreasure(treasureInfo, cardShowAttrs)
    self.mModelId = treasureInfo and (treasureInfo.ModelId or treasureInfo.ModelID or treasureInfo.TreasureModelId) or 0
    self.mInstanceData = treasureInfo
    self:removeCardChild()

    local tempModel = TreasureModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = tempModel.typeID

    -- 设置神兵图片
    self:setCardImage(tempModel.minPic .. ".png")

    -- 设置需要显示的卡牌属性
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            self:setCardName(tempModel.name, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(treasureInfo.Num and treasureInfo.Num > 0 and treasureInfo.Num or nil)
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eLevel then -- 卡牌强化等级
            self:setCardLevel(treasureInfo.Lv)
        elseif item == CardShowAttr.eStep then -- 卡牌进阶等级
            self:setCardStep(treasureInfo.Step)
        elseif item == CardShowAttr.eQuality then
            self:setCardQuality(tempModel.quality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    -- 添加溜边特效
    self:setTresureLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), tempModel.valueLv)

    return self.mShowAttrControl
end

-- 设置内功心法卡牌
--[[
-- 参数
    zhenjueInfo: 内功心法信息，其中包含的字段为:
        {
            Id:实体Id
            ModelId:内功心法模型Id
            TempUpAttrData:
            UpAttrData:
            UpAttrRecord:
        }
    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
]]
function CardNode:setZhenjue(zhenjueInfo, cardShowAttrs)
    self.mResourceTypeSub = ResourcetypeSub.eNewZhenJue
    self.mModelId = zhenjueInfo and (zhenjueInfo.ModelId or zhenjueInfo.ModelID or zhenjueInfo.ZhenjueModelId) or 0
    self.mInstanceData = zhenjueInfo
    self:removeCardChild()

    local tempModel = ZhenjueModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end

    -- 设置内功心法图片
    self:setCardImage(tempModel.icon .. ".png")
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eZhenjueType}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.colorLV)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            self:setCardName(tempModel.name, tempModel.colorLV)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(zhenjueInfo and zhenjueInfo.Num and zhenjueInfo.Num > 0 and zhenjueInfo.Num or nil)
        elseif item == CardShowAttr.eStep then
            -- 因为内功心法的下方会显示洗炼进度，所以把进阶等级显示到右上角
            local nStep = 0
            if (zhenjueInfo ~= nil) and (zhenjueInfo.Step ~= nil) then
                nStep = zhenjueInfo.Step
            end
            self:setCardStep(nStep, cc.p(1, 1), cc.p(self.mWidth - 10, self.mHeight - 8))
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eZhenjueType then -- 内功心法类型标识
            local viewInfo = Utility.getZhenjueViewInfo(tempModel.typeID)
            if viewInfo then
                local tempSprite = ui.newSprite(viewInfo.typeImg)
                tempSprite:setPosition(self.mWidth * 0.2, self.mHeight * 0.8)
                self:addChild(tempSprite, CardShowAttr.eZhenjueType)
            end
        end
    end

    -- 洗炼进度百分比
    local retPercent = ZhenjueObj:calcPercent(zhenjueInfo.Id)
    if (retPercent > 0) then
        local percentLabel = ui.newLabel({
            text = string.format("%.1f%%", retPercent * 100),
            color = cc.c3b(0xfd, 0xfa, 0xf1),
            outlineColor = Enums.Color.eBlack,
            size = 20,
        })
        percentLabel:setPosition(self.mWidth / 2, 15)
        self:addChild(percentLabel, CardShowAttr.ePercent)
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

-- 设置真元卡牌
--[[
-- 参数
    zhenyuanInfo: 内功心法信息，其中包含的字段为:
        {
            Id:实体Id
            ModelId:内功心法模型Id
            Lv:
            Exp:
            Num:
        }
    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
]]
function CardNode:setZhenyuan(zhenyuanInfo, cardShowAttrs)
    self.mResourceTypeSub = ResourcetypeSub.eZhenYuan
    self.mModelId = zhenyuanInfo and (zhenyuanInfo.ModelId or zhenyuanInfo.ModelID) or 0
    self.mInstanceData = zhenyuanInfo
    self:removeCardChild()

    local tempModel = ZhenyuanModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end

    -- 设置真元图片
    self.mBgSprite = ui.newEffect({
        parent = self,
        effectName = tempModel.minPic,
        scale = 0.25,
        position = cc.p(self.mWidth / 2, self.mHeight / 2),
        loop = true,
        endRelease = true,
    })
    self.mBgSprite:setTimeScale(0.7)

    -- 真元资质框
    local qualityBorder = nil
    if self.mCardShape == Enums.CardShape.eCircle then
        qualityBorder = "zy_12.png"
    end
    
    -- 设置需要显示的卡牌属性
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    for _, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality, nil, qualityBorder)
        elseif item == CardShowAttr.eName then -- 名称
            self:setCardName(tempModel.name, tempModel.quality)
        elseif item == CardShowAttr.eLevel then -- 等级
            local nLv = (zhenyuanInfo ~= nil) and zhenyuanInfo.Lv or 0
            self:setCardLevel(nLv)
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eNum then 
            self:setCardCount(zhenyuanInfo.Num or 1)
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

-- 设置外功秘籍卡牌
--[[
-- 参数
    petInfo: 外功秘籍信息，其中包含的字段为:
        {
            Id         = "027fc40f-b064-4b8c-883f-4c3be91149d1"
            ModelId    = 23010102
            Lv         = 1
            ...
        }
    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
]]
function CardNode:setPet(petInfo, cardShowAttrs)
    self.mResourceTypeSub = ResourcetypeSub.ePet
    self.mModelId = petInfo and (petInfo.ModelId and petInfo.ModelID or petInfo.ModelId) or 0
    self.mInstanceData = petInfo
    self:removeCardChild()

    local tempModel = PetModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end

    -- 设置外功秘籍图片
    self:setCardImage(tempModel.minPic .. ".png")
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    local colorLv = Utility.getQualityColorLv(tempModel.quality)
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(colorLv)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, colorLv)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(petInfo.Num and petInfo.Num > 0 and petInfo.Num or nil)
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eLevel then -- 等级
            self:setCardLevel(petInfo.Lv)
        elseif item == CardShowAttr.eStep then -- 参悟
            local petLayer = (petInfo.TotalNum or 0) - (petInfo.CanUseTalNum or 0)
            if (petLayer > 0) then
                self:setCardStep(petLayer)
            end
        end
    end
    -- 套装特效
    if tempModel.valueLv >= 6 then
        self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), tempModel.valueLv)
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

-- 设置珍兽卡牌
--[[
-- 参数
    zhenshouInfo: 外功秘籍信息，其中包含的字段为:
        {
           "Step" = 0, --进阶数
            "Lv" = 0, --珍兽等级
            "ModelId" = 21010001, --模型id
            "Id" = "af945377-d0f7-44f5-a3fb-ab6216388390", --实例id
            "IsCombat" = false, --是否上阵
        }
    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
]]
function CardNode:setZhenshou(zhenshouInfo, cardShowAttrs)
    self.mResourceTypeSub = ResourcetypeSub.eZhenshou
    self.mModelId = zhenshouInfo and (zhenshouInfo.ModelId and zhenshouInfo.ModelID or zhenshouInfo.ModelId) or 0
    self.mInstanceData = zhenshouInfo
    self:removeCardChild()
    local tempModel = ZhenshouModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end

    -- 设置珍兽图片
    self:setCardImage(tempModel.smallPic .. ".png")
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    local colorLv = Utility.getQualityColorLv(tempModel.quality)
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(zhenshouInfo.Num and zhenshouInfo.Num > 0 and zhenshouInfo.Num or nil)
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eLevel then -- 等级
            self:setCardLevel(zhenshouInfo.Lv)
        elseif item == CardShowAttr.eStep then -- 升星
            self:setCardStep(zhenshouInfo.Step)
        end
    end
    -- -- 套装特效
    -- if tempModel.colorLv >= 6 then
    --     self:setLiubianEffect(self, cc.p(self.mWidth / 2, self.mHeight / 2), tempModel.colorLv)
    -- end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置人物天赋卡牌
--[[
-- 参数

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setTalent(skillModelId, cardShowAttrs)
    self.mResourceTypeSub = 0
    self.mModelId = skillModelId
    self.mInstanceData = nil
    self:removeCardChild()

    local talentBase = TeacherTalPic.items[skillModelId]
    -- local imageBase = TeacherTalPic.items[skillModelId]
    if not talentBase then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    local tempQuality = talentBase.quality

    -- 设置图腾图片
    self:setCardImage(talentBase.talPic .. ".png")
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempQuality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, tempQuality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置门派招式卡牌
--[[
-- 参数

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setSectBook(bookModelId, cardShowAttrs)
    self.mResourceTypeSub = ResourcetypeSub.eSectBook
    self.mModelId = bookModelId
    self.mInstanceData = nil
    self:removeCardChild()

    local bookData = SectBookModel.items[bookModelId]
    -- local imageBase = TeacherTalPic.items[bookModelId]
    if not bookData then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    local tempQuality = bookData.quality
    -- 设置图腾图片
    self:setCardImage(bookData.smallPic .. ".png")
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempQuality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = bookData.name
            self:setCardName(tempName, tempQuality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置绝学卡牌
--[[
-- 参数
    fashInfo: 装备属性数据，其中包含的字段为：
        {
            Id = "", -- 实体Id
            ModelId = 0, -- 模型Id
            Step = 0, -- 进阶等级

            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        }

   cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setFashion(fashInfo, cardShowAttrs)
    self.mModelId = fashInfo and (fashInfo.ModelId or fashInfo.FashionModelId or fashInfo.ModelID) or 0
    self.mInstanceData = fashInfo
    self:removeCardChild()

    local tempModel = FashionModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = tempModel.typeID

    -- 设置装备图片
    self:setCardImage(tempModel.smallPic .. ".png")

    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(fashInfo.Num and fashInfo.Num > 0 and fashInfo.Num or nil)
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eStep then -- 卡牌进阶等级
            self:setCardStep(fashInfo.Step, cc.p(0, 1), cc.p(10, self.mHeight - 8))
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置Q版时装卡牌
--[[
-- 参数
    fashInfo: 装备属性数据，其中包含的字段为：
        {
            Id = "", -- 实体Id
            ModelId = 0, -- 模型Id
            Step = 0, -- 进阶等级

            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        }

   cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setQFashion(fashInfo, cardShowAttrs)
    self.mModelId = fashInfo and (fashInfo.ModelId or fashInfo.ShiZhuangModelId or fashInfo.ModelID) or 0
    self.mInstanceData = fashInfo
    self:removeCardChild()

    local tempModel = ShizhuangModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = tempModel.typeID

    -- 设置装备图片
    self:setCardImage(tempModel.smallPic .. ".png")

    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(fashInfo.Num and fashInfo.Num > 0 and fashInfo.Num or nil)
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eStep then -- 卡牌进阶等级
            self:setCardStep(fashInfo.Step, cc.p(0, 1), cc.p(10, self.mHeight - 8))
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置幻化卡牌
--[[
-- 参数
    illusionInfo: 装备属性数据，其中包含的字段为：
        {
            Id = "", -- 实体Id
            ModelId = 0, -- 模型Id

            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        }

   cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setIllusion(illusionInfo, cardShowAttrs)
    self.mModelId = illusionInfo and (illusionInfo.ModelId or illusionInfo.IllusionModelId or illusionInfo.ModelID) or 0
    self.mInstanceData = illusionInfo
    self:removeCardChild()

    -- 侠客时装头像还是用原来的
    if HeroFashionRelation.items[self.mModelId] then
        self.mModelId = HeroFashionRelation.items[self.mModelId].modelId
    end

    local tempModel = IllusionModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = ResourcetypeSub.eIllusion

    -- 设置装备图片
    self:setCardImage(tempModel.smallPic .. ".png", illusionInfo.pvpInterLv)

    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)  
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(illusionInfo.Num and illusionInfo.Num > 0 and illusionInfo.Num or nil)
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

-- 显示宝石
--[[
-- 参数
    imprintInfo: 宝石属性数据，其中包含的字段为：
        {
            Id = "", -- 实体Id
            ModelId = 0, -- 模型Id
            Lv = 0, -- 强化等级
            --- 特殊字段
            Num = 0,   -- 没有具体实例Id的情况下可以传入数量
        }

   cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setImprint(imprintInfo, cardShowAttrs)
    self.mModelId = imprintInfo and (imprintInfo.ModelId or imprintInfo.IllusionModelId or imprintInfo.ModelID) or 0
    self.mInstanceData = imprintInfo
    self:removeCardChild()

    local tempModel = ImprintModel.items[self.mModelId]
    if not tempModel then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    self.mResourceTypeSub = ResourcetypeSub.eImprint

    -- 设置装备图片
    self:setCardImage(tempModel.pic .. ".png")

    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempModel.quality)  
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = tempModel.name
            self:setCardName(tempName, tempModel.quality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(imprintInfo.Num and imprintInfo.Num > 0 and imprintInfo.Num or nil)
        elseif item == CardShowAttr.eBattle then -- 已上阵标识
            self:setBattleMark()
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        elseif item == CardShowAttr.eNewCard then -- 新卡牌标识
            self:setNewCardMark()
        elseif item == CardShowAttr.eLevel then -- 卡牌强化等级
            self:setCardLevel(imprintInfo.Lv)
        elseif item == CardShowAttr.eStep then -- 卡牌进阶等级
            self:setCardStep(imprintInfo.Step)
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end


--- 显示技能图标
--[[
-- 参数
    {
        modelId:    模型ID，用于从 AttackModel 里读取属性
        icon:       图标
        isSkill:    是否是技攻，默认为false普攻
        notShowSkill:  是否显示技／普图，默认false显示
    }

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setSkillAttack(params, cardShowAttrs)
    self.mModelId = params.modelId
    self.mInstanceData = nil
    self:removeCardChild()

    local itemData = AttackModel.items[self.mModelId]
    if not itemData then
        self:setError(self.mModelId)
        return self.mShowAttrControl
    end
    local tempQuality = 15          -- 没有配置，统一显示为橙色
    -- 设置图腾图片
    self:setCardImage(params.icon)

    -- 设置需要显示的卡牌属性
    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder}
    for _, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempQuality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            local tempName = itemData.name
            self:setCardName(tempName, tempQuality)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 显示分类小图
    local skillIcon = "c_71.png"
    if (params.isSkill ~= nil) and (params.isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(1, 0))
    skillSprite:setPosition(self.mWidth - 5, 5)
    skillSprite:setVisible(not params.notShowSkill)
    self:addChild(skillSprite, CardShowAttr.eName)

    return self.mShowAttrControl
end

--- 设置玩家属性
--[[
-- 参数
    playerAttr: 玩家某属性值，其中包含的字段为：
        {
            ResourceTypeSub:资源类型
            Num:数量
        }

    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setPlayerAttr(playerAttr, cardShowAttrs)
    self.mResourceTypeSub = playerAttr.ResourceTypeSub
    self.mModelId = 0
    self.mInstanceData = playerAttr
    self:removeCardChild()

    if not playerAttr or not playerAttr.ResourceTypeSub then
        return self.mShowAttrControl
    end

    local tempPlayerAttr
    if playerAttr.ResourceTypeSub == ResourcetypeSub.eRawGold then  -- 原始铜币 需要特殊处理
        tempPlayerAttr = clone(playerAttr)
        tempPlayerAttr.ResourceTypeSub = ResourcetypeSub.eGold
        tempPlayerAttr.Num = tempPlayerAttr.Num * PlayerAttrObj:getPlayerAttrByName("Lv")
    else
        tempPlayerAttr = playerAttr
    end

    local cardImg = Utility.getResTypeSubImage(tempPlayerAttr.ResourceTypeSub, true)
    self:setCardImage(cardImg) -- 设置人物图像

    -- 玩家属性对应的资质框，默认为金色
    local tempQuality = Utility.getPlayerAttrQuality(tempPlayerAttr.ResourceTypeSub)

    cardShowAttrs = cardShowAttrs or {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs) do
        if item == CardShowAttr.eBorder then -- 卡牌资质框
            self:setCardBorder(tempQuality)
        elseif item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            self:setCardName(ResourcetypeSubName[tempPlayerAttr.ResourceTypeSub], tempQuality)
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(tempPlayerAttr.Num)
        elseif item == CardShowAttr.eSelected then
            self:setSelectedImg()
        end
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置为空卡牌
--[[
-- 参数
    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
    imgName: 需要显示的图片名字
    extraImgName: 而外需要显示的图片

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setEmpty(cardShowAttrs, imgName, extraImgName)
    self.mResourceTypeSub = 0
    self.mModelId = 0
    --self.mInstanceData = nil
    self:removeCardChild()

    self:setCardImage(imgName) -- 设置道具图像
    -- 设置需要显示的卡牌属性
    for inex, item in pairs(cardShowAttrs or {}) do
        if item == CardShowAttr.eName then -- 卡牌的名称或人物属性名称
            self:setCardName(TR("未添加"))
        elseif item == CardShowAttr.eAddMark then
            self:setAddMark()
        elseif item == CardShowAttr.eSelected then
           self:setSelectedImg()
        elseif item == CardShowAttr.eNum then   -- 数量
            self:setCardCount(self.mInstanceData and self.mInstanceData.num or 0)
        elseif item == CardShowAttr.eBgHero then
            self:setBgHero()
        end
    end
    if extraImgName then
        self:setCardExtraImg(extraImgName)
    end

    -- 如果之前已被设置为灰色，则需要设置新创建对象为灰色
    if self.mIsGray then
        self:setGray(self.mIsGray)
    end

    return self.mShowAttrControl
end

--- 设置为空的装备/神兵/外功秘籍卡牌
--[[
-- 参数
    cardShowAttrs: 卡牌上需要显示的属性，枚举 CardShowAttr 值的集合
    resTypeSub: 装备的子类型

-- 返回值，需要显示属性控件列表，用枚举 CardShowAttr 值作为下标，格式为：
    {
        [CardShowAttr值] = {
            sprite = nil,   -- 如果属性有图片标识或背景，则用这个字段存放 CCSprite
            label = nil,    -- 如果属性需要文字显示，则用这个字段存放显示文字的label
            node = nil,     -- 如果属性需要多个控件表示（比如星级），则多个控件会放在一个node上，
        }
    }
 ]]
function CardNode:setEmptyEquip(cardShowAttrs, resTypeSub)
    local emptyImgList = {
        [ResourcetypeSub.eClothes] = "c_108.png",
        [ResourcetypeSub.eHelmet] = "c_107.png",
        [ResourcetypeSub.ePants] = "c_109.png",
        [ResourcetypeSub.eWeapon] = "c_111.png",
        [ResourcetypeSub.eShoe] = "c_110.png",
        [ResourcetypeSub.eNecklace] = "c_112.png",
        [ResourcetypeSub.eBook] = "c_114.png",
        [ResourcetypeSub.ePet] = "c_113.png",
    }
    local imgName = "c_04.png"
    return self:setEmpty(cardShowAttrs, imgName, emptyImgList[resTypeSub])
end

--- 设置神兵和外功的特殊背景框
--[[
-- 参数
    quality: 品质
 ]]
function CardNode:setTreasureBorder(nQuality)
    local tmpControl = self.mShowAttrControl[100] or {}
    if (tmpControl.sprite ~= nil) then
        tmpControl.sprite:removeFromParent()
        tmpControl.sprite = nil
    end

    local borderImgList = {
        [1] = "zr_22.png",
        [2] = "zr_23.png",
        [3] = "zr_24.png",
        [4] = "zr_25.png",
        [5] = "zr_26.png",
        [6] = "zr_27.png",
        [7] = "zr_28.png",
    }
    local nColor = Utility.getColorLvByModelId(self.mModelId)
    if (nColor == nil) or (nColor < 1) or (nColor > 7) then
        nColor = 1
    end
    local tmpSprite = ui.newSprite(borderImgList[nColor])
    tmpSprite:setPosition(self.mWidth * 0.5, self.mHeight * 0.5)
    self:addChild(tmpSprite, CardShowAttr.eAddMark)
    tmpControl.sprite = tmpSprite
end

--- 获取卡牌的显示大小
function CardNode:getContentSize()
    return cc.size(self.mWidth, self.mHeight)
end

-- 设置卡牌是否为灰色
function CardNode:setGray(needGray)
    self.mIsGray = needGray

    if self.mBgSprite and self.mBgSprite.setGray then
        self.mBgSprite:setGray(needGray)
    end
    if self.mQualitySprite then
        self.mQualitySprite:setGray(needGray)
    end

    if self.mPvpInterSprite then
        self.mPvpInterSprite:setGray(needGray)
    end

    if self.mPvpInterEffect then
        if needGray then
            self.mPvpInterEffect:setColor(cc.c3b(150, 150, 150))
        else
            self.mPvpInterEffect:setColor(cc.c3b(255, 255, 255))
        end
    end
end

--- 设置点击的回调函数
function CardNode:setClickCallback(onClickCallback)
    self.onClickCallback = onClickCallback
end

--- 返回卡牌属性
function CardNode:getAttrControl()
    return self.mShowAttrControl
end

--- ============================ 私有函数区域 ============================

-- 设置触摸事件
function CardNode:setOnTouch(touchCallback)
    self:setTouchEnabled(true)

    local beginPos
    self:addTouchEventListener(function(sender, eventType)
        if touchCallback then
            touchCallback(sender, eventType)
        end

        if eventType == ccui.TouchEventType.began then
            beginPos = sender:getTouchBeganPosition()
        elseif eventType == ccui.TouchEventType.ended then
            local endPos = sender:getTouchEndPosition()
            local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
            if distance < (20 * Adapter.MinScale) then
                if self.mAllowClick == false then
                    return
                end

                if self.onClickCallback then
                    self.onClickCallback(sender, eventType)
                else
                    local tempData = {
                        resourceTypeSub = self.mResourceTypeSub,
                        modelId = self.mModelId,
                        instanceData = self.mInstanceData,
                    }
                    defaultCardClick(tempData)
                end
            end
        end
    end)
end

-- 删除所有子控件
function CardNode:removeCardChild()
    self:removeAllChildren()
    self.mShowAttrControl = {}
    self.mBgSprite = nil
    self.mFigureNode = nil
    self.mExtraSprite = nil
    self.mQualitySprite = nil
end

-- 设置错误卡牌内容
function CardNode:setError(errorInfo)
    self:setCardImage(defSmallSizeRef)

    local tempLabel = ui.newLabel({
        text = errorInfo,
        color = Enums.Color.eRed,
        size = 18,
    })
    tempLabel:setPosition(self.mWidth / 2, self.mHeight / 2)
    self:addChild(tempLabel, CardShowAttr.eName)
end

-- 获取卡牌的形状
function CardNode:getCardShape()
    local ret = self.mCardShape
    if Utility.isHero(self.mResourceTypeSub) or Utility.isHeroDebris(self.mResourceTypeSub) then
        ret = Enums.CardShape.eSquare
    elseif self.mResourceTypeSub == ResourcetypeSub.eNewZhenJue or self.mResourceTypeSub == ResourcetypeSub.ePet then
        -- Todo
        ret = Enums.CardShape.eSquare
    else
        ret =  Enums.CardShape.eSquare
    end

    return ret
end

-- 根据卡牌的资质获取资质小边框图片
function CardNode:getQualitySmallImage(quality)
    -- 内功心法和外功秘籍只有颜色值，没有资质
    if  self.mResourceTypeSub == ResourcetypeSub.eNewZhenJue or 
        self.mResourceTypeSub == ResourcetypeSub.ePet then
        return Utility.getBorderImg(quality, self:getCardShape())
    else
        local tempModel = QualityModel.items[quality]
        local colorLv = tempModel and tempModel.colorLV or 1
        return Utility.getBorderImg(colorLv, self:getCardShape())
    end
end

-- 设置卡牌的物品图片
function CardNode:setCardImage(imageName, pvpInterLv)
    if not Utility.isFileExist(imageName) then
        local tempLabel = ui.newLabel({text = imageName, color =  Enums.Color.eRed})
        tempLabel:setPosition(self.mWidth / 2, self.mHeight / 2)
        self:addChild(tempLabel, CardShowAttr.eBgHero)
        return
    end

    self.mBgSprite = ui.newSprite(imageName)
    self.mBgSprite:setPosition(cc.p(self.mWidth / 2, self.mHeight / 2))
    self:addChild(self.mBgSprite)

    if self.mResourceTypeSub == ResourcetypeSub.eHero or self.mResourceTypeSub == ResourcetypeSub.eIllusion then
        -- 跨服战等级头像框/境界/称号
        if pvpInterLv and pvpInterLv > 0 then
            local stateRelaition = DesignationPicRelation.items[pvpInterLv]
            if stateRelaition and stateRelaition.pic ~= "" then
                local pvpInterImg = ui.newSprite(stateRelaition.pic .. ".png")
                pvpInterImg:setPosition(self.mWidth / 2, self.mHeight / 2)
                pvpInterImg:setScale(0.85)
                self:addChild(pvpInterImg, CardShowAttr.eName)
                self.mPvpInterSprite = pvpInterImg
            end
            if stateRelaition and stateRelaition.effectCode ~= "" then
                self.mPvpInterEffect = ui.newEffect({
                    parent = self,
                    effectName = stateRelaition.effectCode,
                    position = cc.p(self.mWidth / 2, self.mHeight / 2),
                    zorder = CardShowAttr.eName,
                    loop = true,
                    endRelease = true,
                    scale = 0.85,
                })
            end 
        end
    end
end

-- 设置卡牌额外的图片
function CardNode:setCardExtraImg(extraImg)
    if not extraImg then
        self.mExtraSprite = nil
        return
    end

    self.mExtraSprite = ui.newSprite(extraImg)
    self.mExtraSprite:setPosition(cc.p(self.mWidth / 2, self.mHeight / 2))
    self:addChild(self.mExtraSprite)
end

-- 设置卡牌的资质
function CardNode:setCardBorder(quality, scale, specifiedImage)
    local tempImg = specifiedImage or self:getQualitySmallImage(quality)
    if not tempImg or tempImg == "" then
        return
    end

    self.mQualitySprite = ui.newSprite(tempImg)
    self.mQualitySprite:setPosition(cc.p(self.mWidth / 2, self.mHeight / 2))
    self.mQualitySprite:setScale(scale or 1)
    self:addChild(self.mQualitySprite, CardShowAttr.eBorder)

    self.mShowAttrControl[CardShowAttr.eBorder] = {}
    self.mShowAttrControl[CardShowAttr.eBorder].sprite = self.mQualitySprite
end

-- 设置卡牌的添加标识
function CardNode:setAddMark()
    local tempSprite = ui.newSprite("c_22.png")
    tempSprite:setPosition(cc.p(self.mWidth / 2, self.mHeight / 2))
    self:addChild(tempSprite)

    self.mShowAttrControl[CardShowAttr.eAddMark] = {}
    self.mShowAttrControl[CardShowAttr.eAddMark].sprite = tempSprite
end

-- 显示闪烁的加号
function CardNode:showGlitterAddMark(img, toScale)
    ui.createGlitterSprite({
        filename = img or "c_144.png",
        parent = self,
        position = cc.p(self.mWidth / 2, self.mHeight / 2),
        actionScale = toScale or 1.2,
    })
end

-- 设置卡牌的名字
function CardNode:setCardName(name, quality, offSetPosY)
    local tempColor
    -- 内功心法、外功秘籍、外功秘籍技能只有颜色值，没有资质
    if self.mResourceTypeSub == ResourcetypeSub.eNewZhenJue or self.mResourceTypeSub == ResourcetypeSub.ePet then
        tempColor = Utility.getColorValue(quality, 1)
    else
        tempColor =  Utility.getQualityColor(quality, 1)
    end
    
    local tempLabel = ui.newLabel({
        text = name,
        size = 18,
        color = tempColor or self.mNameColor,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        align = ui.TEXT_ALIGN_CENTER,
        valign = ui.TEXT_VALIGN_TOP,
        x = self.mWidth / 2,
        y = offSetPosY or 0,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 1))
    self:addChild(tempLabel, CardShowAttr.eName)

    -- label滚动显示
    if self.nameNeedRoll then
        local backSize = cc.size(96, 96)
        local clipSize = cc.size(backSize.width * 1.13, backSize.height)
        ui.createLabelClipRoll({label = tempLabel, dimensions = clipSize, anchorPoint = cc.p(0.5, 0), position = cc.p(backSize.width / 2, -25)})
    end

    self.mShowAttrControl[CardShowAttr.eName] = {}
    self.mShowAttrControl[CardShowAttr.eName].label = tempLabel
end

-- 设置卡牌的等级
function CardNode:setCardLevel(level)
    if level == nil or level <= 0 then  -- 如果等级小于0则不显示
        return
    end
    local tempSprite = ui.newSprite("c_147.png")
    tempSprite:setAnchorPoint(cc.p(0, 1))
    tempSprite:setPosition(cc.p(4, self.mHeight - 3))
    self:addChild(tempSprite, CardShowAttr.eLevel)

    local tempLabel = ui.newLabel({
        text = level,
        size = 18,
        color = cc.c3b(0xfd, 0xfa, 0xf1),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        align = ui.TEXT_ALIGN_RIGHT,
        valign = ui.TEXT_VALIGN_CENTER,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 1))
    tempLabel:setPosition(cc.p(22, self.mHeight - 2))
    self:addChild(tempLabel, CardShowAttr.eLevel)

    self.mShowAttrControl[CardShowAttr.eLevel] = {}
    self.mShowAttrControl[CardShowAttr.eLevel].sprite = tempSprite
    self.mShowAttrControl[CardShowAttr.eLevel].label = tempLabel
end

-- 设置卡牌的品阶
function CardNode:setCardStep(step, anchor, pos)
    if step == nil or step <= 0 then  -- 如果阶数为0则不显示
        return
    end

    -- 部分头像需要特殊的显示位置，比如绝学和内功心法
    if (anchor ~= nil) and (pos ~= nil) then
        local tempLabel = ui.newLabel({
            text = string.format("+%d", step),
            size = 18,
            color = cc.c3b(0xce, 0xff, 0xaa),
            outlineColor = cc.c3b(0x62, 0x2f, 0x09),
        })
        tempLabel:setAnchorPoint(anchor)
        tempLabel:setPosition(pos)
        self:addChild(tempLabel)

        self.mShowAttrControl[CardShowAttr.eStep] = {}
        self.mShowAttrControl[CardShowAttr.eStep].label = tempLabel
        return
    end

    -- 默认显示在右下角
    local strText, textColor = string.format("+%d", step), cc.c3b(0xce, 0xff, 0xaa)
    local textSize = 16
    if Utility.isEquip(self.mResourceTypeSub) then
        strText, textColor = TR("%d阶", step), cc.c3b(0xff, 0xf8, 0xe0)
    elseif (Utility.isHero(self.mResourceTypeSub)) then
        if (step > 20) then
            strText, textSize = TR("无极+%d", (step - 20)), 14
        elseif (step > 15) then
            strText, textSize = TR("武圣+%d", (step - 15)), 14
        elseif (step > 10) then
            strText, textSize = TR("武尊+%d", (step - 10)), 14
        end
    end

    -- 显示底图
    local tempSprite = ui.newSprite("c_148.png")
    tempSprite:setAnchorPoint(cc.p(1, 0))
    tempSprite:setPosition(cc.p(self.mWidth - 2, 2))
    self:addChild(tempSprite, CardShowAttr.eStep)

    local tempLabel = ui.newLabel({
        text = strText,
        size = textSize,
        color = textColor,
        outlineColor = cc.c3b(0x62, 0x2f, 0x09),
        outlineSize = 2,
        align = ui.TEXT_ALIGN_CENTER,
        valign = ui.TEXT_VALIGN_BOTTOM,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 0))
    tempLabel:setPosition(cc.p(self.mWidth - 25, 0))
    self:addChild(tempLabel, CardShowAttr.eStep)

    self.mShowAttrControl[CardShowAttr.eStep] = {}
    self.mShowAttrControl[CardShowAttr.eStep].sprite = tempSprite
    self.mShowAttrControl[CardShowAttr.eStep].label = tempLabel
end

-- 设置卡牌数量
function CardNode:setCardCount(count, maxNum)
    if not count or count < 0 then
        return
    end
    local countStr = Utility.numberWithUnit(count)
    local maxNumStr = Utility.numberWithUnit(maxNum or 0)
    local viewStr = maxNum and string.format("%s/%s", countStr, maxNumStr) or countStr
    local tempLabel = ui.newLabel({
        text = viewStr,
        size = 18,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        align = ui.TEXT_ALIGN_CENTER,
        valign = ui.TEXT_VALIGN_BOTTOM,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 0))
    tempLabel:setPosition(cc.p(self.mWidth / 2, 5))
    self:addChild(tempLabel, CardShowAttr.eNum)

    self.mShowAttrControl[CardShowAttr.eNum] = {}
    self.mShowAttrControl[CardShowAttr.eNum].label = tempLabel

    return self.mShowAttrControl[CardShowAttr.eNum].label
end

-- 设置卡牌的碎片标识
function CardNode:setDebrisMark()
    local tempSprite = ui.newSprite("c_56.png")
    tempSprite:setAnchorPoint(cc.p(0, 1))
    tempSprite:setPosition(cc.p(0, self.mHeight))
    self:addChild(tempSprite, CardShowAttr.eDebris)

    self.mShowAttrControl[CardShowAttr.eDebris] = {}
    self.mShowAttrControl[CardShowAttr.eDebris].sprite = tempSprite
end

-- 设置新卡牌标识
function CardNode:setNewCardMark()
    local tempSprite = ui.createNewSprite({})
    tempSprite:setAnchorPoint(cc.p(0.5, 0.5))
    tempSprite:setPosition(cc.p(20, self.mHeight - 20))
    self:addChild(tempSprite, CardShowAttr.eNewCard)

    self.mShowAttrControl[CardShowAttr.eNewCard] = {}
    self.mShowAttrControl[CardShowAttr.eNewCard].sprite = tempSprite
end

-- 创建带背景的字符串角标
function CardNode:createStrImgMark(imgFile, strText, textSize, color)
    local tempSprite, tempLabel = ui.createStrImgMark(imgFile or "c_58.png", strText, color or Enums.Color.eWhite, textSize or 18)
    tempSprite:setRotation(90)
    tempSprite:setScale(0.8)
    tempSprite:setPosition(self.mWidth - 33, self.mHeight - 33)
    self:addChild(tempSprite, 99)

    return tempSprite, tempLabel
end

-- 设置可以合成标识
function CardNode:setSyntheticMark()
    local tempSprite, tempLabel = self:createStrImgMark("c_62.png", TR("可合成"))
    
    self.mShowAttrControl[CardShowAttr.eSynthetic] = {}
    self.mShowAttrControl[CardShowAttr.eSynthetic].sprite = tempSprite
    self.mShowAttrControl[CardShowAttr.eSynthetic].label = tempLabel
end

-- 设置已上阵标识
function CardNode:setBattleMark()
    -- 幻化图片不一样
    local image = self.mResourceTypeSub == ResourcetypeSub.eIllusion and "c_172.png" or "c_32.png"
    local tempSprite, tempLabel = ui.createStrImgMark(image, "")
    tempSprite:setPosition(self.mWidth - 17, self.mHeight - 17)
    tempSprite:setRotation(60)
    self:addChild(tempSprite, CardShowAttr.eBattle)

    self.mShowAttrControl[CardShowAttr.eBattle] = {}
    self.mShowAttrControl[CardShowAttr.eBattle].sprite = tempSprite
    self.mShowAttrControl[CardShowAttr.eBattle].label = tempLabel
end

-- 设置星星
function CardNode:setCardStar()
    local retNode = Figure.newEquipStarLevel({
        parent = self,
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(self.mWidth / 2, 0),
        info = self.mInstanceData,
        })
    if (retNode ~= nil) then
        retNode:setScale(0.7)
    end

    self.mShowAttrControl[CardShowAttr.eStar] = {}
    self.mShowAttrControl[CardShowAttr.eStar].node = retNode
end

-- 设置资质
function CardNode:setCardQuality(quality)
    local tempStr = TR("资质%d", quality or 0)
    local tempLabel = ui.newLabel({
        text = tempStr,
        size = 19,
        color = Utility.getQualityColor(quality, 1),
        align = ui.TEXT_ALIGN_CENTER,
        valign = ui.TEXT_VALIGN_CENTER,
        x = self.mWidth - 25,
        y = self.mHeight - 10,
    })
    tempLabel:setRotation(30)
    self:addChild(tempLabel, CardShowAttr.eQuality)
    self.mShowAttrControl[CardShowAttr.eQuality] = {}
    self.mShowAttrControl[CardShowAttr.eQuality].label = tempLabel
end

-- 设置选中标识
function CardNode:setSelectedImg(scale)
    local tempList = {
        [Enums.CardShape.eSquare]  = "c_31.png", -- 四边形
        [Enums.CardShape.eCircle]  = "c_116.png", -- 圆形
        [Enums.CardShape.eHexagon] = "c_31.png", -- 六边形  -- Todo
    }
    local tempShape = self:getCardShape()
    local tempSprite = ui.newSprite(tempList[tempShape] or "c_31.png")
    tempSprite:setPosition(cc.p(self.mWidth / 2, self.mHeight / 2))
    tempSprite:setScale(scale or 1)
    self:addChild(tempSprite, CardShowAttr.eSelected)

    self.mShowAttrControl[CardShowAttr.eSelected] = {}
    self.mShowAttrControl[CardShowAttr.eSelected].sprite = tempSprite
end

-- 设置阵容头像的人物背景
function CardNode:setBgHero()
    local tempSprite = ui.newSprite("zr_19.png")
    tempSprite:setAnchorPoint(cc.p(0.5, 0.5))
    tempSprite:setPosition(cc.p(self.mWidth / 2, self.mHeight / 2))
    self:addChild(tempSprite)

    self.mShowAttrControl[CardShowAttr.eBgHero] = {}
    self.mShowAttrControl[CardShowAttr.eBgHero].sprite = tempSprite
end

-- 设置吃丹的标识
function CardNode:setMedicineTag()
    local tempSprite = ui.newSprite("zr_08.png")
    tempSprite:setAnchorPoint(cc.p(0.5, 0.5))
    tempSprite:setPosition(cc.p(self.mWidth * 0.1, self.mHeight * 0.1))
    self:addChild(tempSprite)

    self.mShowAttrControl[CardShowAttr.eMedicine] = {}
    self.mShowAttrControl[CardShowAttr.eMedicine].sprite = tempSprite
end

-- 设置溜边特效
function CardNode:setLiubianEffect(parent, pos, colorLv)
    local strEffectName = nil
    if (colorLv ~= nil) and (colorLv > 1) then
        local effectNameList = {
            [2] = "effect_ui_tiaozhuangshanguang_lv",
            [3] = "effect_ui_tiaozhuangshanguang_lan",
            [4] = "effect_ui_tiaozhuangshanguang_zi",
            [5] = "effect_ui_tiaozhuangshanguang_cheng",
            [6] = "effect_ui_tiaozhuangshanguang_hong",
            [7] = "effect_ui_jinzhuangtexiao",
        }
        strEffectName = effectNameList[colorLv] or effectNameList[7]
    end
    if (strEffectName ~= nil) then
        ui.newEffect({
            parent = parent,
            effectName = strEffectName,
            position = pos,
            loop = true,
            endRelease = true,
        })
    end
end

-- 设置神兵溜边特效
function CardNode:setTresureLiubianEffect(parent, pos, colorLv)
    local strEffectName = nil
    if (colorLv ~= nil) and (colorLv > 1) then
        local effectNameList = {
            [6] = "effect_ui_zhujueshenbing_chengse",
            [7] = "effect_ui_zhujueshenbing_hongse",
        }
        strEffectName = effectNameList[colorLv]
    end
    if (strEffectName ~= nil) then
        ui.newEffect({
            parent = parent,
            effectName = strEffectName,
            position = pos,
            loop = true,
            endRelease = true,
        })
    end
end

-- 装备显示星级
function CardNode:showEquipStar(equipInfo)
    if (equipInfo == nil) then
        return
    end
    local lightStarImg, grayStarImg = "c_75.png", "c_102.png"
    local imgSize = ui.getImageSize(lightStarImg)
    local maxStarCount = 0              -- 该装备的最大星星数量
    local lightStarCount = equipInfo.Star or 0
    local space = 0
    if (equipInfo.ModelId ~= nil) and (equipInfo.ModelId > 0) then
        local equipBase = EquipModel.items[equipInfo.ModelId] or {}
        maxStarCount = equipBase.starMax or 0
    end
    if (maxStarCount == 0) then
        return
    end
    if (lightStarCount == 0) then
        -- 临时加的，如果没升星过，就不显示了
        return
    end

    -- 显示背景
    local retNode = cc.Node:create()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setContentSize(cc.size(imgSize.width, maxStarCount * imgSize.height + (maxStarCount - 1) * space))
    retNode:setAnchorPoint(cc.p(0, 1))
    retNode:setPosition(cc.p(10, self.mHeight - 25))
    retNode:setScale(0.45)
    self:addChild(retNode, CardShowAttr.eStar)
    self.mShowAttrControl[CardShowAttr.eStar] = {}
    self.mShowAttrControl[CardShowAttr.eStar].node = retNode
    
    -- 创建星星
    for i = 1, maxStarCount do
        local tempPosX = imgSize.width / 2
        local tempPosY = imgSize.height / 2 + (i - 1) * (imgSize.height + space)

        -- 创建星星图片
        local tempSprite =  ui.newSprite((lightStarCount >= i) and lightStarImg or grayStarImg)
        tempSprite:setPosition(tempPosX, tempPosY)
        retNode:addChild(tempSprite)
    end
end

--- 显示玩家物品信息（人物、装备、神兵、道具）
--[[
--  参数
    params = {
        resourceTypeSub： 资源类型
        modelId: 资源模型Id
        instanceData = {}, -- 卡牌的具体数据（人物、装备、道具、碎片、主角技能、星宿等在缓存中的数据）
    }
 ]]
defaultCardClick = function(params)
    local resType = params and params.resourceTypeSub
    local instanceData = params.instanceData
    if Utility.isHero(resType) or Utility.isHeroInstance(instanceData) then    -- "人物"
        local modelId = instanceData and instanceData.ModelId or params.modelId
        LayerManager.addLayer({
            name = "hero.HeroInfoLayer",
            data = {
                heroId = instanceData and instanceData.Id,
                heroModelId = modelId,
            },
            cleanUp = false
        })
    elseif Utility.isEquip(resType) or Utility.isEquipInstance(instanceData) then  -- "装备"
        local modelId = instanceData and instanceData.ModelId or params.modelId
        LayerManager.addLayer({
            name = "equip.EquipInfoLayer",
            data = {
                equipId = instanceData and instanceData.Id,
                equipModelId = modelId,
            },
            cleanUp = false
        })
    elseif Utility.isEquipDebris(resType)then                                   -- "装备碎片"
        local modelId = instanceData and instanceData.ModelId or params.modelId
        local equipModelId = GoodsModel.items[modelId].outputModelID
        LayerManager.addLayer({
            name = "equip.EquipInfoLayer",
            data = {
                equipModelId = equipModelId,
            },
            cleanUp = false
        })
    elseif Utility.isTreasure(resType) or Utility.isTreasureInstance(instanceData) then  -- 神兵
        local modelId = instanceData and instanceData.ModelID or params.modelId
        local tempId = instanceData and instanceData.Id or nil
        LayerManager.addLayer({
            name = "equip.TreasureInfoLayer",
            data = {
                treasureInfo = tempId and TreasureObj:getTreasure(tempId) or nil,
                treasureModelID = modelId
            },
            cleanUp = false
        })
    elseif Utility.isHeroDebris(resType) or Utility.isHeroDebrisInstance(instanceData) then    -- "人物碎片"
        local modelId = instanceData and instanceData.GoodsModelId or params.modelId
        local heroDebris = GoodsModel.items[modelId]
        LayerManager.addLayer({
            name = "hero.HeroInfoLayer",
            data = {
                heroModelId = heroDebris.outputModelID
            },
            cleanUp = false
        })
    elseif  Utility.isGoods(resType) or Utility.isGoodsInstance(instanceData) or Utility.isIllusionDebris(resType) then   -- 除碎片以外的goods(幻化碎片在儿显示简介)
        local modelId = instanceData and instanceData.GoodsModelId or params.modelId
        if math.floor(modelId / 100000) == 169 then
            LayerManager.addLayer({
                name = "bag.VoucherLayer",
                data = {
                    modelId = modelId,
                    Id = instanceData.Id
                },
                cleanUp = false
            })
        else
            MsgBoxLayer.addGoodsInfoLayer(modelId, nil, true)
        end
    elseif Utility.isTresureDebris(resType) or Utility.isTresureDebrisInstance(instanceData) then    -- "神兵碎片"
        local modelId = instanceData and instanceData.TreasureDebrisModelId or params.modelId
        MsgBoxLayer.addTreasureDebrisInfoLayer(modelId, nil, true)
    elseif Utility.isImprint(resType) or Utility.isImprintInstance(instanceData) then -- 宝石
        local modelId = params.modelId
        local imprintModel = ImprintModel.items[modelId]
        MsgBoxLayer.showImprintIntroLayer({imprintId = instanceData and instanceData.Id or nil, imprintModelId = modelId})
        
    elseif Utility.isZhenjue(resType) then -- 内功心法
        local modelId = instanceData and instanceData.ModelId or params.modelId
        LayerManager.addLayer({
            name = "zhenjue.ZhenjueInfoLayer",
            data = {
                zhenjueInfo = (instanceData ~= nil) and instanceData or nil,
                modelId = modelId
            },
            cleanUp = false
        })
    elseif Utility.isZhenjueDebris(resType) then -- 内功心法碎片
        local modelId = instanceData and instanceData.ModelId or params.modelId
        local zhenjueDebris = GoodsModel.items[modelId]
        LayerManager.addLayer({
            name = "zhenjue.ZhenjueInfoLayer",
            data = {
                modelId = zhenjueDebris.outputModelID
            },
            cleanUp = false
        })
    elseif Utility.isZhenyuan(resType) then -- 真元
        local modelId = instanceData and instanceData.ModelId or params.modelId
        LayerManager.addLayer({
            name = "zhenyuan.ZhenyuanInfoLayer",
            data = {
                zhenyuanInfo = (instanceData ~= nil) and instanceData or nil,
                modelId = modelId
            },
            cleanUp = false
        })
    elseif Utility.isPet(resType) then -- 宠物
        local modelId = instanceData and instanceData.ModelId or params.modelId
            -- 如果有实例Id
            if instanceData and instanceData.Id then
                LayerManager.addLayer({
                    name = "pet.PetInfoLayer",
                    data = {
                       petId = instanceData.Id,
                       petList = {instanceData},
                    },
                    cleanUp = false
                })
            else
                LayerManager.addLayer({
                    name = "pet.PetInfoLayer",
                    data = {
                       modelId = params.modelId,
                    },
                    cleanUp = false
                })
            end
    elseif Utility.isPetDebris(resType) then -- 宠物碎片
        local modelId = params.modelId
        local PetModelId = GoodsModel.items[modelId].outputModelID
         LayerManager.addLayer({
                name = "pet.PetInfoLayer",
                data = {
                   modelId = PetModelId,
                },
                cleanUp = false
            })
    elseif Utility.isPlayerAttr(resType) then -- 玩家属性
        local tempStr = Utility.getGoodsIntro(resType)
        -- 其他道具信息DIY函数
        local function DIYInfoFunction(layer, layerBgSprite, layerSize)
            -- 创建物品的头像
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = resType, -- 资源类型
                modelId = 0,  -- 模型Id
                allowClick = false,
            })
            tempCard:setPosition(layerSize.width / 2, layerSize.height - 130)
            layerBgSprite:addChild(tempCard)

            -- 创建碎片的简介
            local tempLabel = ui.newLabel({
                text = tempStr == "" and TR("神秘物品，暂无介绍") or tempStr,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                align = ui.TEXT_ALIGN_CENTER,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions = cc.size(layerSize.width - 80, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 1))
            tempLabel:setPosition(layerSize.width / 2, layerSize.height - 210)
            layerBgSprite:addChild(tempLabel)
        end

        MsgBoxLayer.addDIYLayer({
            msgText = "",
            title = TR("物品详情"),
            bgSize = cc.size(572, 380),
            DIYUiCallback = DIYInfoFunction
        })
    elseif Utility.isSectBook(resType) then -- 门派招式
        local bookData = SectBookModel.items[params.modelId]
        -- 其他道具信息DIY函数
        local function DIYInfoFunction(layer, layerBgSprite, layerSize)
            -- 创建物品的头像
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = resType, -- 资源类型
                modelId = params.modelId,  -- 模型Id
                allowClick = false,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
            })
            tempCard:setPosition(layerSize.width / 2, layerSize.height - 130)
            layerBgSprite:addChild(tempCard)
            -- 简介string
            local introStr = ""
            if bookData.attrStr ~= "" and bookData.attrStr ~= nil then
                local attrList = Utility.analysisStrFashionAttrList(bookData.attrStr)
                local attrStrList = {}
                for _, v in pairs(attrList) do
                    local tempStr = Utility.getRangeStr(v.range)
                    tempStr = tempStr .. FightattrName[v.fightattr]
                    tempStr = tempStr .. "+" .. tostring(v.value)
                    table.insert(attrStrList, tempStr)
                end
                local introTempStr = table.concat(attrStrList, ",")
                introStr = TR("学习后，可获得以下属性：\r\n%s", introTempStr)
            elseif bookData.TALModelID ~= 0 and bookData.TALModelID ~= nil then
                local introTempStr = TalModel.items[bookData.TALModelID].intro
                introStr = TR("装备该招式，主角可获得以下属性：\r\n%s", introTempStr)
            else
                introStr = bookData.intro
            end

            -- 创建简介
            local tempLabel = ui.newLabel({
                text = introStr,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                align = ui.TEXT_ALIGN_CENTER,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions = cc.size(layerSize.width - 80, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 1))
            tempLabel:setPosition(layerSize.width / 2, layerSize.height - 210)
            layerBgSprite:addChild(tempLabel)
        end

        MsgBoxLayer.addDIYLayer({
            msgText = "",
            title = TR("物品详情"),
            bgSize = cc.size(572, 380),
            DIYUiCallback = DIYInfoFunction
        })
    elseif Utility.isFashion(resType) then -- 时装绝学
        local tempStr = FashionModel.items[params.modelId].intro
        -- 其他道具信息DIY函数
        local function DIYInfoFunction(layer, layerBgSprite, layerSize)
            -- 创建物品的头像
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = resType, -- 资源类型
                modelId = params.modelId,  -- 模型Id
                allowClick = false,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
            })
            tempCard:setPosition(layerSize.width / 2, layerSize.height - 130)
            layerBgSprite:addChild(tempCard)

            -- 创建碎片的简介
            local tempLabel = ui.newLabel({
                text = tempStr == "" and TR("神秘物品，暂无介绍") or tempStr,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                align = ui.TEXT_ALIGN_CENTER,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions = cc.size(layerSize.width - 80, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 1))
            tempLabel:setPosition(layerSize.width / 2, layerSize.height - 210)
            layerBgSprite:addChild(tempLabel)
        end

        MsgBoxLayer.addDIYLayer({
            msgText = "",
            title = TR("物品详情"),
            bgSize = cc.size(572, 380),
            DIYUiCallback = DIYInfoFunction
        })
    elseif Utility.isZhenshou(resType) then -- 珍兽
        local modelId = params.modelId
        if ZhenshouModel.items[params.modelId].isShow == 0 then
            ui.showFlashView(TR("该珍兽还没开放"))
            return
        end
         LayerManager.addLayer({
                name = "zhenshou.ZhenshouInfoLayer",
                data = {
                   modelId = params.modelId,
                },
                cleanUp = false,
            })
    elseif Utility.isZhenshouDebris(resType) then -- 珍兽碎片
        local modelId = params.modelId
        local zhoushouModelId = GoodsModel.items[modelId].outputModelID
        if ZhenshouModel.items[zhoushouModelId].isShow == 0 then
            ui.showFlashView(TR("该珍兽还没开放"))
            return
        end
         LayerManager.addLayer({
                name = "zhenshou.ZhenshouInfoLayer",
                data = {
                   modelId = zhoushouModelId,
                },
                cleanUp = false,
            })
    end
end

function CardNode.defaultCardClick(params)
    defaultCardClick(params)
end

return CardNode
