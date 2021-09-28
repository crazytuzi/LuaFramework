--[[
    文件名：Figure
    描述：创建人物、装备、神兵... 动画形象，创建头像使用 CardNode
    创建人：peiyaoqiang
    创建时间：2015.4.13
-- ]]
Figure = {}

--显示人物/装备等物品的名字和星级
--[[
    params:
        parent          父窗体，可选参数，不传的话需要调用者自己add显示
        anchorPoint     显示锚点，可选参数，默认cc.p(0.5, 1)
        position        显示位置，可选参数，默认cc.p(320, 1000)
        nameText        物体显示名字
        starCount       物体的星级
    return:
        retNode:        显示的Node，可调整位置
        mStarNode:      可修改星级显示
        mNameLabel:     可修改名字显示
--]]
function Figure.newNameAndStar(params)
    local retNode = cc.Node:create()
    local nodeSize = cc.size(640, 90)
    retNode:setContentSize(nodeSize)
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(params.anchorPoint or cc.p(0.5, 1))
    retNode:setPosition(params.position or cc.p(320, 1000))
    if params.parent then
        params.parent:addChild(retNode)
    end

    local mStarNode = ui.newStarLevel(params.starCount)
    mStarNode:setAnchorPoint(cc.p(0.5, 1))
    mStarNode:setPosition(nodeSize.width / 2, nodeSize.height)
    retNode:addChild(mStarNode)

    -- 装备的名字
    local mNameLabel = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        labelStr = params.nameText or "",
        fontSize = 24,
        fontColor = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        outlineSize = 2,
    })
    mNameLabel:setAnchorPoint(cc.p(0.5, 1))
    mNameLabel:setPosition(nodeSize.width / 2, nodeSize.height - 34)
    retNode:addChild(mNameLabel)

    return retNode, mStarNode, mNameLabel
end

--显示人物的阵营和品质
function Figure.newHeroRaceAndQuality(heroModelId)
    if (heroModelId == nil) then
        return nil
    end

    local raceImg = nil
    if (HeroModel.items[heroModelId].specialType == Enums.HeroType.eMainHero) then
        raceImg = "c_140.png"
    else
        raceImg = Utility.getHeroRaceImg(heroModelId)
    end
    if (raceImg == nil) then
        return nil
    end

    -- 显示阵营
    local retBgSprite = ui.newSprite(raceImg)
    local retBgSize = retBgSprite:getContentSize()

    -- 显示品质
    local typeImg = Utility.getHeroTypeImg(heroModelId)
    if (typeImg ~= nil) then
        local typeSprite = ui.newSprite(typeImg)
        typeSprite:setPosition(cc.p(retBgSize.width * 0.45, 55))
        retBgSprite:addChild(typeSprite)
    end

    return retBgSprite
end

--显示装备的星级
--[[
    params:
        parent          父窗体，可选参数，不传的话需要调用者自己add显示
        anchorPoint     显示锚点，可选参数，默认cc.p(0.5, 0.5)
        position        显示位置，可选参数，默认cc.p(0, 0)

        info            装备的内容信息，可选参数，如果有该参数，则忽略guid和modelId
        guid            装备的实体ID，可选参数，如果同时存在modelId，则忽略modelId
        modelId         装备的模型ID，可选参数，但是它和guid必须至少有一个
        isTujian        是否图鉴状态，可选参数，默认是false。图鉴状态下显示星星全亮。
    return:
        retNode:        显示的Node
--]]
function Figure.newEquipStarLevel(params)
    if (params.info == nil) and (params.guid == nil) and (params.modelId == nil) then
        return
    end

    -- 初始化
    local lightStarImg, grayStarImg = "c_75.png", "c_102.png"
    local imgSize = ui.getImageSize(lightStarImg)
    local maxStarCount = 0              -- 该装备的最大星星数量
    local space = 2

    -- 读取装备可升到的最大星级
    local equipModelId = params.modelId
    if (params.info ~= nil) then
        equipModelId = params.info.ModelId
    elseif (params.guid ~= nil) then
        local equipInfo = EquipObj:getEquip(params.guid) or {}
        equipModelId = equipInfo.ModelId
    end
    if (equipModelId ~= nil) and (equipModelId > 0) then
        local equipBase = EquipModel.items[equipModelId] or {}
        maxStarCount = equipBase.starMax or 0
    end
    if (maxStarCount == 0) then
        return
    end

    -- 显示背景
    local retNode = cc.Node:create()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setContentSize(cc.size(maxStarCount * imgSize.width + (maxStarCount - 1) * space, imgSize.height))
    if params.anchorPoint then
        retNode:setAnchorPoint(params.anchorPoint)
    end
    if params.position then
        retNode:setPosition(params.position)
    end
    if params.parent then
        params.parent:addChild(retNode)
    end

    -- 刷新星星显示
    retNode.refresh = function()
        retNode:removeAllChildren()

        -- 读取装备的当前星级
        if (params.info ~= nil) then
            -- 通过玩家传入的数据读取
            lightStarCount = params.info.Star or 0
        elseif (params.guid ~= nil) then
            -- 通过服务器的返回值读取
            local equipInfo = EquipObj:getEquip(params.guid) or {}
            lightStarCount = equipInfo.Star or 0
        else
            -- 图鉴里的装备直接显示最大星级
            lightStarCount = params.isTujian and maxStarCount or 0
        end

        -- 创建星星
        for i = 1, maxStarCount do
            local tempPosX = imgSize.width / 2 + (i - 1) * (imgSize.width + space)
            local tempPosY = imgSize.height / 2

            -- 创建星星图片
            local tempSprite =  ui.newSprite((lightStarCount >= i) and lightStarImg or grayStarImg)
            tempSprite:setPosition(tempPosX, tempPosY)
            retNode:addChild(tempSprite)
        end
    end
    retNode.refresh()

    return retNode
end

--创建人物形象
--[[
    params:
        heroModelID     队员id
        fashionModelID  时装id（如果传nil或0，就不显示；其他时候，如果当前人物是主角，就用时装替代显示）
        IllusionModelId 幻化id（如果传nil或0，就不显示）
        heroFashionId   侠客时装id
        figureName      形象名称（和队员id二选一）
        parent          父节点
        position        坐标
        scale           缩放
        zorder          排序
        buttonAction    按钮事件（通ContrlButton的clickAction）
        swallow         是否吞并事件
        needAction      是否显示动画效果，默认为 true
        needRace        是否需要显示阵营标识，默认为false, 只有 heroModelID 参数有效时该参数才有效
        async           异步模式（函数）

        rebornId        转生ID，当rebornId不为空时，显示转生等级，优先级高于needType
    return:
        figure: 人物对象
            figure 可能还会有以下字段
            figure.typeSprite:  人物类型标识图片
            figure.raceSprite: 人物阵营标识图片
            figure.button: 点击事件的按钮
--]]
function Figure.newHero(params)
    require("common.SkeletonAnimation")
    require("common.ConfigFunc")
    local filename = nil
    

    if (params.figureName ~= nil) and (params.figureName ~= "") then
        filename = params.figureName
    else
        if params.heroFashionId and (HeroFashionRelation.items[params.heroFashionId] ~= nil) then
            filename = HeroFashionRelation.items[params.heroFashionId].largePic
        elseif (params.IllusionModelId ~= nil) and (IllusionModel.items[params.IllusionModelId] ~= nil) then
            filename = IllusionModel.items[params.IllusionModelId].largePic
        elseif (params.heroModelID ~= nil) then
            local tmpResType = math.floor(params.heroModelID / 10000)
            if HeroFashionRelation.items[params.heroModelID] then
                filename = HeroFashionRelation.items[params.heroModelID].largePic
            elseif Utility.isFashion(tmpResType) then 
                -- 直接传入时装绝学
                filename = FashionModel.items[params.heroModelID].actionPic
            elseif Utility.isIllusion(tmpResType) then
                -- 直接传入幻化
                filename = IllusionModel.items[params.heroModelID].largePic
            else
                -- 直接传入侠客
                local heroModel = HeroModel.items[params.heroModelID] or {}
                local fashionModel = FashionModel.items[(params.fashionModelID or 0)] or {}
                if (heroModel.specialType == Enums.HeroType.eMainHero) and (fashionModel.actionPic ~= nil) then
                    filename = fashionModel.actionPic
                else
                    filename = heroModel.largePic
                end
            end
        end
    end
    if (filename == nil) then
        return
    end
    

    local function setup( figureNode )
        figureNode.filename = filename
        if params.needAction ~= false then
            SkeletonAnimation.action({skeleton = figureNode, action = "daiji" , loop = true})
        end

        if not g_skill_editor and figureNode then
            -- 设置皮肤
            local shieldLv = Utility.isNeedShield()
            SkeletonAnimation.update({skeleton = figureNode, skin = shieldLv and "skin_02" or "skin_01"})
        end

        -- 是否显示转生等级
        if params.rebornId then
            local tempSprite = ui.createRebornLevel(params.rebornId)
            tempSprite:setScale(1 / (params.scale or 1))
            tempSprite:setPosition(450, 1150)
            figureNode:addChild(tempSprite, 1)
            figureNode.rebornSprite = tempSprite
        end

        -- 是否需要显示阵营标识
        if params.needRace  and params.heroModelID then
            local tempSprite = Figure.newHeroRaceAndQuality(params.heroModelID)
            if (tempSprite ~= nil) then
                tempSprite:setScale(1 / (params.scale or 1))
                tempSprite:setPosition(-510, 1200)
                figureNode:addChild(tempSprite)
                figureNode.raceSprite = tempSprite
            end
        end
        
        local pButton = ui.newButton({
            normalImage = "c_83.png",
            clickAction = params.buttonAction,
        })
        figureNode:addChild(pButton)
        figureNode.button = pButton
        pButton:setSwallowTouches(params.swallow or false) -- 默认不吞并事件

        Utility.performWithDelay(pButton , function(time)
            -- 形象的显示区域
            local figureRect = figureNode:getBoundingBox()
            --
            local scale = figureNode:getScale()
            if scale then
                figureRect.width = figureRect.width / scale
                figureRect.height = figureRect.height / scale
            end
            --
            -- 形象的参考坐标
            local referPos = cc.p(figureRect.x + figureRect.width / 2, figureRect.y)
            -- 设置按钮的属性
            pButton:setScale9Enabled(true)
            pButton:setContentSize(cc.size(figureRect.width, figureRect.height))
            -- pButton:setPosition(referPos.x, referPos.y + figureRect.height / 2)
            pButton:setPosition(0, figureRect.height / 2)
        end , 0.001)
    end

    -- 创建形象
    if params.async then
        SkeletonAnimation.create({
            file = filename,
            parent = params.parent,
            position = params.position,
            scale = params.scale,
            zorder = params.zorder,
            loadEvent = params.loadEvent,
            async = function( figureNode )
                setup(figureNode)
                params.async(figureNode)
            end
        })
    else
        local figureNode = SkeletonAnimation.create({
            file = filename,
            parent = params.parent,
            position = params.position,
            scale = params.scale,
            zorder = params.zorder,
            loadEvent = params.loadEvent
        })
        setup(figureNode)
        return figureNode
    end
end

-- 创建装备大图片(包含神兵)
--[[
-- params 中的各项为：
    {
        modelId: 装备模型Id
        needAction: 是否需要上下浮动的效果,默认为false
        viewSize: 显示的大小
        clickCallback: 点击事件回调函数
    }
-- 返回值
    返回一个node对象，并且提供 node:changeEquip(modelId) 函数以改变显示的装备
]]
function Figure.newEquip(params)
    local tempSize = params.viewSize or cc.size(640, 550)
    local retLayer = display.newLayer()
    retLayer:setContentSize(tempSize)
    retLayer:setAnchorPoint(cc.p(0.5, 0.5))
    retLayer:setIgnoreAnchorPointForPosition(false)

    local function refreshLayer(imgStr, colorLv)
        if not Utility.isFileExist(imgStr) then
            return
        end

        -- 装备的图片
        if params.needAction then
            local tempSprite = ui.createFloatSprite(imgStr, cc.p(tempSize.width / 2, tempSize.height / 2))
            retLayer:addChild(tempSprite, 1)
        else
            local tempSprite = ui.newSprite(imgStr)
            tempSprite:setPosition(tempSize.width / 2, tempSize.height / 2)
            retLayer:addChild(tempSprite, 1)
        end

        local tempQuad = ui.createFloatParticle(colorLv)
        tempQuad:setPosition(tempSize.width / 2, 0)
        retLayer:addChild(tempQuad)
    end

    -- 改变显示的装备
    retLayer.changeEquip = function(target, modelId)
        target:removeAllChildren()

        local imgStr = nil
        local colorLv = 1
        local tempModel = EquipModel.items[modelId]
        if tempModel then
            imgStr = tempModel.pic .. ".png"
            colorLv = Utility.getQualityColorLv(tempModel.quality)
        end
        
        if imgStr then
            refreshLayer(imgStr, colorLv)
            if params.clickCallback then
                local tempBtn = ui.newButton({
                    normalImage = "c_83.png",
                    size = ui.getImageSize(imgStr),
                    clickAction = function()
                        params.clickCallback()
                    end,
                })
                tempBtn:setPosition(tempSize.width / 2, tempSize.height / 2)
                retLayer:addChild(tempBtn)
            end
        end
    end
    retLayer:changeEquip(params.modelId)

    return retLayer
end

-- 创建神兵大图片
--[[
-- params 中的各项为：
    {
        modelId: 神兵模型Id
        needAction: 是否需要上下浮动的效果,默认为false
        viewSize: 显示的大小
        clickCallback: 点击事件回调函数
    }
-- 返回值
    返回一个node对象，并且提供 node:changeTreasure(modelId) 函数以改变显示的神兵
]]
function Figure.newTreasure(params)
    local tempSize = params.viewSize or cc.size(640, 550)
    local retLayer = display.newLayer()
    retLayer:setContentSize(tempSize)
    retLayer:setAnchorPoint(cc.p(0.5, 0.5))
    retLayer:setIgnoreAnchorPointForPosition(false)

    -- 特殊处理神兵特效id列表（来自射雕2的红色神兵）
    local specTreModelIdList = {
        [14011803] = true,
        [14011804] = true,
        [14011805] = true,
        [14011806] = true,
        [14011807] = true,
        [14011808] = true,
        [14011809] = true,
        [14011810] = true,
        [14011811] = true,
        [14011812] = true,
        [14011813] = true,
        [14011814] = true,
        [14011815] = true,
        [14011816] = true,
    }

    -- 改变显示的神兵
    retLayer.changeTreasure = function(target, modelId)
        target:removeAllChildren()

        local tempModel = TreasureModel.items[modelId]
        if tempModel == nil then
            return
        end

        -- 读取图片等配置
        local imgStr = tempModel.pic .. ".png"
        local effectStr = tempModel.effectCode
        local colorLv = Utility.getQualityColorLv(tempModel.quality)
        if not Utility.isFileExist(imgStr) then
            return
        end

        -- 特殊处理
        if specTreModelIdList[modelId] then
            tempSprite = ui.newSprite(imgStr)
            local imgSize = tempSprite:getContentSize()
            local tempPos = cc.p(tempSize.width / 2, tempSize.height / 2)

            -- 创建特效图
            local tuEffect = ui.newEffect({
                    parent = target,
                    position = tempPos,
                    effectName = effectStr,
                    animation = "03_tu",
                    loop = true,
                })
            -- 创建裁剪区
            local clippingNode = cc.ClippingNode:create()
            clippingNode:setAlphaThreshold(0.5)
            clippingNode:setPosition(5, -15)
            tuEffect:addChild(clippingNode)
            -- 创建扫光特效
            ui.newEffect({
                    parent = clippingNode,
                    effectName = effectStr,
                    animation = "02_guang",
                    loop = true,
                })
            -- 创建模版
            clippingNode:setStencil(tempSprite)

            -- 浮动
            if params.needAction then
                local moveAction1 = cc.MoveTo:create(1.3, cc.p(tempPos.x, tempPos.y + 20))
                local moveAction2 = cc.MoveTo:create(1.3, cc.p(tempPos.x, tempPos.y + 10))
                local moveAction3 = cc.MoveTo:create(1.3, cc.p(tempPos.x, tempPos.y))
                tuEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.EaseSineIn:create(moveAction2),
                    cc.EaseSineOut:create(moveAction1),
                    cc.EaseSineIn:create(moveAction2),
                    cc.EaseSineOut:create(moveAction3)
                )))
            end
        else
            -- 显示神兵的图片
            local tempSprite = nil
            local tempPos = cc.p(tempSize.width / 2, tempSize.height / 2)
            if params.needAction then
                tempSprite = ui.createFloatSprite(imgStr, tempPos)
            else
                tempSprite = ui.newSprite(imgStr)
                tempSprite:setPosition(tempPos)
            end
            target:addChild(tempSprite, 1)

            -- 显示神兵独有的特效
            local spriteSize = tempSprite:getContentSize()
            ui.newEffect({
                parent = tempSprite,
                effectName = effectStr,
                position = cc.p(spriteSize.width * 0.5, spriteSize.width * 0.5),
                loop = true,
                endRelease = false,
            })
        end

        -- 显示粒子气泡效果
        local tempQuad = ui.createFloatParticle(colorLv)
        tempQuad:setPosition(tempSize.width / 2, 0)
        target:addChild(tempQuad)

        -- 添加点击事件处理
        if params.clickCallback then
            local tempBtn = ui.newButton({
                normalImage = "c_83.png",
                size = ui.getImageSize(imgStr),
                clickAction = function()
                    params.clickCallback()
                end,
            })
            tempBtn:setPosition(tempSize.width / 2, tempSize.height / 2)
            retLayer:addChild(tempBtn)
        end
    end
    retLayer:changeTreasure(params.modelId)

    return retLayer
end

-- 创建内功心法大图片
--[[
-- params 中的各项为：
    {
        modelId: 内功心法模型Id
        needAction: 是否需要上下浮动的效果,默认为false
        viewSize: 显示的大小
        clickCallback: 点击事件回调函数
    }
-- 返回值
    返回一个node对象，并且提供 node:changeZhenjue(modelId) 函数以改变显示的内功心法
]]
function Figure.newZhenjue(params)
    local tempSize = params.viewSize or cc.size(640, 420)
    local retLayer = display.newLayer()
    retLayer:setContentSize(tempSize)
    retLayer:setAnchorPoint(cc.p(0.5, 0.5))
    retLayer:setIgnoreAnchorPointForPosition(false)

    --
    local function refreshLayer(imgStr, colorLv)
        if not Utility.isFileExist(imgStr) then
            return
        end

        -- 内功心法的图片
        if params.needAction then
            local tempSprite = ui.createFloatSprite(imgStr, cc.p(tempSize.width / 2, tempSize.height / 2))
            retLayer:addChild(tempSprite)
        else
            local tempSprite = ui.newSprite(imgStr)
            tempSprite:setPosition(tempSize.width / 2, tempSize.height / 2)
            retLayer:addChild(tempSprite)
        end

        local tempQuad = ui.createFloatParticle(colorLv)
        tempQuad:setPosition(tempSize.width / 2, 0)
        retLayer:addChild(tempQuad)
    end

    -- 改变显示的内功心法
    retLayer.changeZhenjue = function(target, modelId)
        target:removeAllChildren()

        local imgStr = nil
        local colorLv = 1

        local tempModel = ZhenjueModel.items[modelId or 0]
        if tempModel then
            imgStr = tempModel.pic .. ".png"
            colorLv = tempModel.colorLV
        end

        --imgStr = "zb_10201.png"
        if imgStr then
            refreshLayer(imgStr, colorLv)
            if params.clickCallback then
                local tempBtn = ui.newButton({
                    normalImage = "c_83.png",
                    size = ui.getImageSize(imgStr),
                    clickAction = function()
                        params.clickCallback()
                    end,
                })
                tempBtn:setPosition(tempSize.width / 2, tempSize.height / 2)
                retLayer:addChild(tempBtn)
            end
        end
    end
    retLayer:changeZhenjue(params.modelId)

    return retLayer
end

-- 创建外功秘籍大图片
--[[
-- params 中的各项为：
    {
        petId: 外功秘籍实例Id
        modelId: 外功秘籍模型Id, 如果 petId 为有效值，该参数失效
        needAction: 是否需要上下浮动的效果,默认为false
        viewSize: 显示的大小, 默认为 cc.size(640, 440), 名称、星级的显示位置会参考该大小
        clickCallback: 点击事件回调函数
    }
-- 返回值
    返回一个node对象，并且提供 node:changePet(modelId) 函数以改变显示的外功秘籍
]]
function Figure.newPet(params)
    local viewSize = params.viewSize or cc.size(640, 540)
    local retLayer = display.newLayer()
    retLayer:setContentSize(viewSize)
    retLayer:setAnchorPoint(cc.p(0.5, 0.5))
    retLayer:setIgnoreAnchorPointForPosition(false)

    -- 改变显示的外功秘籍
    retLayer.changePet = function(target, petId, modelId)
        target:removeAllChildren()

        -- 整理外功秘籍信息
        local petInfo = Utility.isEntityId(petId) and PetObj:getPet(petId)
        local petModel = PetModel.items[petInfo and petInfo.ModelId or modelId]
        local imgStr = petModel.pic .. ".png"
        if not Utility.isFileExist(imgStr) then
            return
        end

        -- 显示外功秘籍图片及其效果
        if params.needAction then
            local tempSprite = ui.createFloatSprite(imgStr, cc.p(viewSize.width / 2, 0))
            tempSprite:setAnchorPoint(cc.p(0.5, 0))
            retLayer:addChild(tempSprite)
        else
            local tempSprite = ui.newSprite(imgStr)
            tempSprite:setAnchorPoint(cc.p(0.5, 0))
            tempSprite:setPosition(viewSize.width / 2, 0)
            retLayer:addChild(tempSprite)
        end

        local tempQuad = ui.createFloatParticle(Utility.getQualityColorLv(petModel.quality))
        tempQuad:setPosition(viewSize.width / 2, 0)
        retLayer:addChild(tempQuad)

        -- 判断是否需要点击回调
        if params.clickCallback then
            local tempBtn = ui.newButton({
                normalImage = "c_83.png",
                size = ui.getImageSize(imgStr),
                clickAction = function()
                    params.clickCallback()
                end,
            })
            tempBtn:setAnchorPoint(cc.p(0.5, 0))
            tempBtn:setPosition(viewSize.width / 2, 0)
            retLayer:addChild(tempBtn)
        end
    end
    retLayer:changePet(params.petId, params.modelId)

    return retLayer
end

-- 创建真元大图片
--[[
-- params 中的各项为：
    {
        zhenyuanId: 真元实例Id
        modelId: 真元模型Id, 如果 zhenyuanId 为有效值，该参数失效
        needAction: 是否需要上下浮动的效果,默认为false
        viewSize: 显示的大小, 默认为 cc.size(640, 440), 名称、星级的显示位置会参考该大小
        clickCallback: 点击事件回调函数
    }
-- 返回值
    返回一个node对象，并且提供 node:changeZhenyuan(modelId) 函数以改变显示的真元
]]
function Figure.newZhenyuan(params)
    local viewSize = params.viewSize or cc.size(640, 540)
    local retLayer = display.newLayer()
    retLayer:setContentSize(viewSize)
    retLayer:setAnchorPoint(cc.p(0.5, 0.5))
    retLayer:setIgnoreAnchorPointForPosition(false)

    -- 改变显示的真元
    retLayer.changeZhenyuan = function(target, zhenyuanId, modelId)
        target:removeAllChildren()

        -- 整理真元信息
        local zhenyuanInfo = Utility.isEntityId(zhenyuanId) and ZhenyuanObj:getZhenyuan(zhenyuanId)
        local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo and zhenyuanInfo.ModelId or modelId]
        local imgStr = "c_83.png"

        -- 创建一个上下浮动的透明节点，将真元特效添加到该节点上
        if params.needAction then
            local tempSprite = ui.createFloatSprite(imgStr, cc.p(viewSize.width / 2, viewSize.height / 2))
            tempSprite:setAnchorPoint(cc.p(0.5, 0))
            retLayer:addChild(tempSprite)
            
            -- 真元特效
            local zhenyuanEffect = ui.newEffect({
                    parent = tempSprite,
                    effectName = zhenyuanModel.minPic,
                    position = cc.p(0, 0),
                    loop = true,
                    endRelease = true,
                })
            zhenyuanEffect:setTimeScale(0.7)
        else
            -- 真元特效
            local zhenyuanEffect = ui.newEffect({
                    parent = retLayer,
                    effectName = zhenyuanModel.minPic,
                    position = cc.p(viewSize.width / 2, viewSize.height / 2),
                    loop = true,
                    endRelease = true,
                })
            zhenyuanEffect:setTimeScale(0.7)
        end
        
        local tempQuad = ui.createFloatParticle(Utility.getQualityColorLv(zhenyuanModel.quality))
        tempQuad:setPosition(viewSize.width / 2, 0)
        retLayer:addChild(tempQuad)

        -- 判断是否需要点击回调
        if params.clickCallback then
            local tempBtn = ui.newButton({
                normalImage = "c_83.png",
                size = ui.getImageSize(imgStr),
                clickAction = function()
                    params.clickCallback()
                end,
            })
            tempBtn:setAnchorPoint(cc.p(0.5, 0))
            tempBtn:setPosition(viewSize.width / 2, 0)
            retLayer:addChild(tempBtn)
        end
    end
    retLayer:changeZhenyuan(params.zhenyuanId, params.modelId)

    return retLayer
end

-- 创建珍兽
--[[
-- params 中的各项为：
    {
        zhenshouId: 珍兽实例Id
        modelId: 珍兽模型Id, 如果 zhenshouId 为有效值，该参数失效
        needAction: 是否需要上下浮动的效果,默认为false
        needParticle: 是否需要上浮粒子,默认为false
        viewSize: 显示的大小, 默认为 cc.size(640, 440), 名称、星级的显示位置会参考该大小
        clickCallback: 点击事件回调函数
    }
-- 返回值
    返回一个node对象，并且提供 node:changeZhenshou(modelId) 函数以改变显示的珍兽
]]
function Figure.newZhenshou(params)
    local viewSize = params.viewSize or cc.size(640, 540)
    local retLayer = display.newLayer()
    retLayer:setContentSize(viewSize)
    retLayer:setAnchorPoint(cc.p(0.5, 0.5))
    retLayer:setIgnoreAnchorPointForPosition(false)

    -- 改变显示的珍兽
    retLayer.changeZhenshou = function(target, zhenshouId, modelId)
        target:removeAllChildren()

        -- 整理珍兽信息
        local zhenshouInfo = Utility.isEntityId(zhenshouId) and ZhenshouObj:getZhenshou(zhenshouId)
        local zhenshouModel = ZhenshouModel.items[zhenshouInfo and zhenshouInfo.ModelId or modelId]
        local imgStr = "c_83.png"

        -- 创建一个上下浮动的透明节点，将珍兽特效添加到该节点上
        if params.needAction then
            local tempSprite = ui.createFloatSprite(imgStr, cc.p(viewSize.width / 2, viewSize.height / 2))
            tempSprite:setAnchorPoint(cc.p(0.5, 0))
            retLayer:addChild(tempSprite)
            
            -- 珍兽特效
            local zhenshouEffect = ui.newEffect({
                    parent = tempSprite,
                    effectName = zhenshouModel.bigPic,
                    animation = "daiji",
                    position = cc.p(viewSize.width / 2, 100),
                    loop = true,
                    endRelease = true,
                    scale = 0.6,
                })
            zhenshouEffect:setTimeScale(0.7)
        else
            -- 珍兽特效
            local zhenshouEffect = ui.newEffect({
                    parent = retLayer,
                    effectName = zhenshouModel.bigPic,
                    animation = "daiji",
                    position = cc.p(viewSize.width / 2, 100),
                    loop = true,
                    endRelease = true,
                    scale = 0.6,
                })
            zhenshouEffect:setTimeScale(0.7)
        end
        
        if params.needParticle then
            local tempQuad = ui.createFloatParticle(Utility.getQualityColorLv(zhenshouModel.quality))
            tempQuad:setPosition(viewSize.width / 2, 0)
            retLayer:addChild(tempQuad)
        end

        -- 判断是否需要点击回调
        if params.clickCallback then
            local tempBtn = ui.newButton({
                normalImage = "c_83.png",
                size = viewSize,
                clickAction = function()
                    params.clickCallback()
                end,
            })
            tempBtn:setAnchorPoint(cc.p(0.5, 0))
            tempBtn:setPosition(viewSize.width / 2, 0)
            retLayer:addChild(tempBtn)
        end
    end
    retLayer:changeZhenshou(params.zhenshouId, params.modelId)

    return retLayer
end
