--[[
    文件名：Utility.lua
    描述：功能函数模块
    创建人：shuaixitao
    创建时间：2015.12.21
-- ]]

Utility = {}

-- 空实例Id
EMPTY_ENTITY_ID = "00000000-0000-0000-0000-000000000000"
-- 无效的数字，服务器可能传一个很大的负数，表示该值是无效值
INVALID_NUMBER = -2147483648
--
NULL = setmetatable({}, {
    __index= function(obj, key)
        --error("attended to index null value")
    end,
    __newindex= function(obj, key, val)
        --error("attended to modify null value")
    end,
    __metatable= false,
})

--创建延时执行函数
--[[
-- 参数：
    node:       需要的参数，父节点
    callback:   需要的参数，回调方法
    delay:      需要的参数，延时时间
--]]
function Utility.performWithDelay(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
    return sequence
end

--创建定时函数
--[[
-- 参数：
    node:       需要的参数，父节点
    callback:   需要的参数，回调方法
    delay:      需要的参数，延时时间
--]]
function Utility.schedule(node, callback, delay)
    local sequence = cc.Sequence:create(cc.CallFunc:create(callback), cc.DelayTime:create(delay))
    local action = cc.RepeatForever:create(sequence)
    node:runAction(action)
    return action
end

-- 检查实例Id是否有效, 由于侠客、装备、神兵、物品等的实例Id是GUID, 因此用该函数用于
--[[
--参数：
    entityId: 实例Id
]]
function Utility.isEntityId(entityId)
    entityId = entityId or ""

    -- 如果是字符串类型，字符串长度为36等guid
    if (type(entityId) == "string" and string.len(entityId) == string.len(EMPTY_ENTITY_ID) and entityId ~= EMPTY_ENTITY_ID) then
        return true
    end
    if (type(entityId) == "number" and entityId > 0) then
        return true
    end
    return false
end

-- 检查传入值是否为空（空表或空字符串）
function Utility.valueIsEmpty(value)
    if not value or type(value) == "string" and value == "" or
        type(value) == "table" and next(value) == nil then
        return true
    end
    return false
end

-- 判断文件是否存在
function Utility.isFileExist(fileName)
    local tempUtils = cc.FileUtils:getInstance()
    if tempUtils:isFileExist(fileName) then
        return true
    else
        local tempStr = tempUtils:fullPathForFilename(fileName)
        return tempUtils:isFileExist(tempStr)
    end
end

--- 数字超过一定数量后，采用以万为单位显示
--[[
参数:
    num: 需要处理的字符串
    decimals: 需要保留的小数位数
    unit: 单位字符，默认为: "万"
    needPlus: 是否需要带符号
 ]]
function Utility.numberWithUnit(num, decimals, unit, needPlus)
    if num >= 100000 then
        local unitName = (num >= 1000000000) and TR("亿") or TR("万")
        local unitNum = (num >= 1000000000) and (num / 100000000) or (num / 10000)
        if decimals and decimals > 0 then
            local tempStr = needPlus and "%+." or "%."
            tempStr =tempStr .. tostring(decimals) .. "f" .. (unit or unitName)
            return string.format(tempStr, unitNum)
        else
            local tempStr = needPlus and "%+d" or "%d"
            tempStr = tempStr .. (unit or unitName)
            return string.format(tempStr, math.floor(unitNum))
        end
    else
        if needPlus then
            return string.format("%+d", num)
        else
            return tostring(num)
        end
    end
end

--- 战力超过一定数量后，采用以万为单位显示，超过100亿用亿显示保留2位小数
--[[
参数:
    num: 需要处理的字符串
    unit: 单位字符，默认为: "万"
    needPlus: 是否需要带符号
 ]]
function Utility.numberFapWithUnit(num, unit, needPlus)
    if num >= 100000 then
        local unitName = (num >= 10000000000) and TR("亿") or TR("万")
        local unitNum = (num >= 10000000000) and (num / 100000000) or (num / 10000)
        if num >= 10000000000 then
            decimals = 2
            local tempStr = needPlus and "%+." or "%."
            tempStr =tempStr .. tostring(decimals) .. "f" .. (unit or unitName)
            return string.format(tempStr, unitNum)
        else
            local tempStr = needPlus and "%+d" or "%d"
            tempStr = tempStr .. (unit or unitName)
            return string.format(tempStr, math.floor(unitNum))
        end
    else
        if needPlus then
            return string.format("%+d", num)
        else
            return tostring(num)
        end
    end
end

--- 转化存储大小为带单位的显示字符串
--[[
-- 参数:
    btye: 字节数

-- 返回:
    str, {数字, 单位}
]]
function Utility.btyeToViewStr(bytes, si, carry)
    local function _convert_auto()
        local thresh = si and 1000 or 1024
        if math.abs(bytes) < thresh then
            return string.format("%s B", bytes), {bytes, 'B'}
        end
        local units = {'kB','MB','GB','TB','PB','EB','ZB','YB'}
        local u = 0;
        while (math.abs(bytes) >= thresh and u < #units) do
            bytes = bytes / thresh
            u = u + 1
        end
        return string.format("%.02f %s", bytes, units[u]), {bytes, units[u]}
    end

    local function _convert_2_carry(bytes, size, carry)
        local units = {
            ['B'] = 0,
            ['kB'] = 1,
            ['MB'] = 2,
            ['GB'] = 4,
            ['TB'] = 5,
            ['PB'] = 5,
            ['EB'] = 6,
            ['ZB'] = 7,
            ['YB'] = 8}
        local thresh = si and 1000 or 1024

        local u = units[carry]
        if not u then
            return
        end

        for i = 1, u do
            bytes = bytes / thresh
        end
        return string.format("%.02f %s", bytes, units[u]), {bytes, units[u]}
    end

    if not carry then
        return _convert_auto(bytes, si)
    else
        return _convert_2_carry(bytes, si, carry)
    end
end

--- 获取玩家属性的 Quality
function Utility.getPlayerAttrQuality(resourceTypeSub)
    local tempList = {
        [ResourcetypeSub.eEXP] = 17,             --- "经验值"
        [ResourcetypeSub.eVIT] = 17,             --- "体力值"
        [ResourcetypeSub.eSTA] = 17,             --- "耐力值"
        [ResourcetypeSub.eVIPEXP] = 17,       --- "VIP经验值"
        [ResourcetypeSub.eDiamond] = 17,     --- "元宝"
        [ResourcetypeSub.eGold] = 11,           --- "铜币"
        [ResourcetypeSub.eContribution] = 17, --- "贡献"
        [ResourcetypeSub.ePVPCoin] = 17,     --- "声望"
        [ResourcetypeSub.eHeroCoin] = 17,   --- "宝贝果实"
        [ResourcetypeSub.eHeroExp] = 11,     --- "战魂"
        [ResourcetypeSub.eGDDHCoin] = 17,   --- "豪侠令"
        [ResourcetypeSub.eBossCoin] = 17,   --- "Boss积分"
        [ResourcetypeSub.eMerit] = 17,         --- "战功"
        [ResourcetypeSub.eHonor] = 17,    -- "荣誉"
        [ResourcetypeSub.eRedBagFund] = 17,    -- "红包基金"
        [ResourcetypeSub.ePetEXP] = 17,    -- "妖灵"
        [ResourcetypeSub.ePetCoin] = 17,    -- "外功秘籍令"
        [ResourcetypeSub.eGodDomainGlory] = 17,  -- "神域争霸荣誉点"
        [ResourcetypeSub.eGuildActivity] = 17,   --- "活跃度"
        [ResourcetypeSub.eGuildMoney] = 17,     --- "帮派资金"
        [ResourcetypeSub.eTaoZhuangCoin] = 17,   -- 神域争霸荣誉点
        [ResourcetypeSub.eRebornCoin] = 17,    -- "感悟灵晶"
        [ResourcetypeSub.eXrxsStar] = 17,    -- "赏金点"
        [ResourcetypeSub.eHuiGen] = 17,    -- "慧根"
        [ResourcetypeSub.eRebornCoin] = 17,    -- "真气"

    }
    return tempList[resourceTypeSub] or 11
end

-- 根据colorLv获取颜色的名称
--[[
--参数
    colorLv：颜色等级(1、2、3、4、5、6、7、8)
-- ]]
function Utility.getColorName(colorLv)
    local tempList = {TR("白色"), TR("绿色"), TR("蓝色"), TR("紫色"), TR("橙色"), TR("红色"), TR("金色"), TR("暗金色")}
    colorLv = colorLv or 1

    local tempColorLv = colorLv
    if (colorLv < 1) then
        tempColorLv = 1
    end
    if (colorLv > 8) then
        tempColorLv = 8
    end
    return tempList[tempColorLv]
end

-- 根据colorLv获取侠客的名称（仅限人物使用）
--[[
--参数
    colorLv：颜色等级(1、2、3、4、5、6、7)
-- ]]
function Utility.getHeroColorName(quality)
    if (quality < 3) then
        return ""
    end
    local tempList = {
        [3] = TR("侠客"),
        [6] = TR("大侠"),
        [10] = TR("豪侠"),
        [13] = TR("宗师"),
        [15] = TR("神话"),
        [18] = TR("传说")
    }
    return tempList[quality] or tempList[18]
end

--- 获取颜色等级对应的颜色值
--[[
--参数
    colorLv：颜色等级(1、2、3、4、5、6、7、8)
    colorType: 获取颜色的返回形式,1 表示返回值是 、“cc.c3b(x,x,x)” 形式，2 表示 返回值为 “#XXXXXX” 形式
-- ]]
function Utility.getColorValue(colorLv, colorType)
    local colorList
    if colorType and (colorType == 1) then
        colorList = {Enums.Color.eWhite, Enums.Color.eGreen, Enums.Color.eBlue,
            Enums.Color.ePurple, Enums.Color.eOrange, Enums.Color.eRed, Enums.Color.eGold, Enums.Color.eDullGold}
    else
        colorList = {Enums.Color.eWhiteH, Enums.Color.eGreenH, Enums.Color.eBlueH,
            Enums.Color.ePurpleH, Enums.Color.eOrangeH, Enums.Color.eRedH, Enums.Color.eGoldH, Enums.Color.eDullGoldH}
    end

    colorLv = colorLv or 1
    local tempColorLv = colorLv < 1 and 1 or colorLv > 8 and 8 or colorLv

    return colorList[tempColorLv]
end

-- 根据颜色品质获取边框的图片名
--[[
-- 参数
    colorLv: 颜色等级
    cardShape: 卡牌的形状，取值在Enums.lua 文件的 Enums.CardShape中定义，默认为：Enums.CardShape.eSquare
]]
function Utility.getBorderImg(colorLv, cardShape)
    colorLv = colorLv or 1
    colorLv = colorLv > 7 and 7 or colorLv
    colorLv = colorLv < 1 and 1 or colorLv

    -- 不同形状的头像边框
    local shapeList = {
        [Enums.CardShape.eSquare]  = { -- 四边形
            [1] = "c_04.png",
            [2] = "c_05.png",
            [3] = "c_06.png",
            [4] = "c_07.png",
            [5] = "c_08.png",
            [6] = "c_09.png",
            [7] = "c_10.png",
        },
        [Enums.CardShape.eCircle]  = { -- 圆形
            [1] = "c_04.png",
            [2] = "c_05.png",
            [3] = "c_06.png",
            [4] = "c_07.png",
            [5] = "c_08.png",
            [6] = "c_09.png",
            [7] = "c_10.png",
        },
        [Enums.CardShape.eHexagon] = { -- 六边形
            [1] = "c_04.png",
            [2] = "c_05.png",
            [3] = "c_06.png",
            [4] = "c_07.png",
            [5] = "c_08.png",
            [6] = "c_09.png",
            [7] = "c_10.png",
        },
    }
    local tempList = shapeList[cardShape or Enums.CardShape.eSquare] or shapeList[Enums.CardShape.eSquare]
    return tempList[colorLv]
end

---获取资质获取对应的颜色
--[[
--参数
    quality：侠客、装备、神兵、道具等的资质
    colorType: 获取颜色的返回形式,1 表示返回值是 “cc.c3b(x,x,x)” 形式，2 表示 返回值为 “{XXXXXX}” 形式
-- ]]
function Utility.getQualityColor(quality, colorType)
    local tempModel = QualityModel.items[quality or 5]
    if not tempModel or not tempModel.colorLV then
        return Utility.getColorValue(1, colorType)
    end
    -- 暂时没有暗金色装备，将品质大于27的装备设置为金色装备
    local tempColor = tempModel.colorLV > 7 and 7 or tempModel.colorLV
    return Utility.getColorValue(tempColor, colorType)
end

--- 根据资质获取颜色等级数值
--[[
-- 参数：
    quality: 资质
]]
function Utility.getQualityColorLv(quality)
    if not quality then
        return 1
    end
    local tempModel = QualityModel.items[quality]
    if not tempModel or not tempModel.colorLV then
        return 1
    end
    local tempColorLv = tempModel.colorLV < 1 and 1 or tempModel.colorLV > 7 and 7 or tempModel.colorLV
    return tempColorLv
end

-- 根据模型ID获取物品的模型信息
--[[
-- 参数
    modelId: 物品的模型Id
    resourceTypeSub: 玩家属性类型枚举，在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
-- 返回值
    物品的模型信息
]]
function Utility.getModelByModelId(modelId, resourceTypeSub)
    modelId = modelId or 0
    resourceTypeSub = resourceTypeSub or math.floor(modelId / 10000)

    if Utility.isHero(resourceTypeSub) then  -- 侠客
        return HeroModel.items[modelId]
    elseif Utility.isEquip(resourceTypeSub) then -- 装备
        return EquipModel.items[modelId]
    elseif Utility.isTreasure(resourceTypeSub) then -- 神兵
        return TreasureModel.items[modelId]
    elseif Utility.isGoods(resourceTypeSub, true) then -- 道具
        return GoodsModel.items[modelId]
    elseif Utility.isTresureDebris(resourceTypeSub) then -- 神兵碎片
        return TreasureDebrisModel.items[modelId]
    elseif Utility.isZhenjue(resourceTypeSub) then -- 内功心法
        return ZhenjueModel.items[modelId]
    elseif Utility.isPet(resourceTypeSub) then  -- 外功秘籍
        return PetModel.items[modelId]
    elseif Utility.isFashion(resourceTypeSub) then  -- 时装
        return FashionModel.items[modelId]
    elseif Utility.isIllusion(resourceTypeSub) then  -- 幻化
        return IllusionModel.items[modelId]    
    elseif Utility.isImprint(resourceTypeSub) then  -- 宝石
        return ImprintModel.items[modelId]    
    end

    return nil
end

-- 根据模型ID获取物品的颜色等级
--[[
-- 参数
    modelId: 物品的模型Id
    resourceTypeSub: 玩家属性类型枚举，在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
-- 返回值
    物品的 ColorLv
]]
function Utility.getColorLvByModelId(modelId, resourceTypeSub)
    modelId = modelId or 0
    resourceTypeSub = resourceTypeSub or math.floor(modelId / 10000)

    if Utility.isHero(resourceTypeSub) then  -- 侠客
        local tempModel = HeroModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isEquip(resourceTypeSub) then -- 装备
        local tempModel = EquipModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isTreasure(resourceTypeSub) then -- 神兵
        local tempModel = TreasureModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isGoods(resourceTypeSub, true) then -- 道具
        local tempModel = GoodsModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isTresureDebris(resourceTypeSub) then -- 神兵碎片
        local tempModel = TreasureDebrisModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isZhenjue(resourceTypeSub) then -- 内功心法
        local tempModel = ZhenjueModel.items[modelId]
        return tempModel and tempModel.colorLV or 1
    elseif Utility.isPet(resourceTypeSub) then  -- 外功秘籍
        local tempModel = PetModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isFashion(resourceTypeSub) then  -- 时装
        local tempModel = FashionModel.items[modelId]
        return tempModel and tempModel.colorLV or 1
    elseif Utility.isIllusion(resourceTypeSub) then  -- 幻化
        local tempModel = IllusionModel.items[modelId]
        return tempModel and tempModel.colorLV or 1    
    elseif Utility.isPlayerAttr(resourceTypeSub) then  -- 玩家属性
        local tempQuality = Utility.getPlayerAttrQuality(resourceTypeSub)
        return Utility.getQualityColorLv(tempQuality)
    elseif Utility.isZhenshou(resourceTypeSub) then --珍兽
        local tempModel = ZhenshouModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isShiZhuang(resourceTypeSub) then --Q版时装
        local tempModel = ShizhuangModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    elseif Utility.isImprint(resourceTypeSub) then --宝石
        local tempModel = ImprintModel.items[modelId]
        return Utility.getQualityColorLv(tempModel and tempModel.quality)
    end

    return 1
end

--根据模型ID获取物品的资质
function Utility.getQualityByModelId(modelId, resourceTypeSub)
    modelId = modelId or 0
    resourceTypeSub = resourceTypeSub or math.floor(modelId / 10000)

    if Utility.isHero(resourceTypeSub) then  -- 侠客
        local tempModel = HeroModel.items[modelId]
        return tempModel.quality
    elseif Utility.isEquip(resourceTypeSub) then -- 装备
        local tempModel = EquipModel.items[modelId]
        return tempModel.quality
    elseif Utility.isTreasure(resourceTypeSub) then -- 神兵
        local tempModel = TreasureModel.items[modelId]
        return tempModel.quality
    elseif Utility.isGoods(resourceTypeSub, true) then -- 道具
        local tempModel = GoodsModel.items[modelId]
        return tempModel.quality
    elseif Utility.isTresureDebris(resourceTypeSub) then -- 神兵碎片
        local tempModel = TreasureDebrisModel.items[modelId]
        return tempModel.quality
    elseif Utility.isZhenjue(resourceTypeSub) then -- 内功心法
        local tempModel = ZhenjueModel.items[modelId]
        return tempModel.quality
    elseif Utility.isPet(resourceTypeSub) then  -- 外功秘籍
        local tempModel = PetModel.items[modelId]
        return tempModel.quality
    elseif Utility.isFashion(resourceTypeSub) then  -- 时装
        local tempModel = FashionModel.items[modelId]
        return tempModel.quality   
    elseif Utility.isIllusion(resourceTypeSub) then  -- 幻化
        local tempModel = IllusionModel.items[modelId]
        return tempModel.quality       
    elseif Utility.isPlayerAttr(resourceTypeSub) then  -- 玩家属性
        local tempQuality = Utility.getPlayerAttrQuality(resourceTypeSub)
        return tempQuality
    elseif HeroFashionRelation.items[modelId] then -- 侠客时装
        return Utility.getQualityByModelId(HeroFashionRelation.items[modelId].modelId)
    elseif Utility.isImprint(resourceTypeSub) then -- 宝石
        local tempModel = ImprintModel.items[modelId]
        return tempModel.quality
    end
    return 1
end

--[[ 获取玩家属性标识图片名
参数:
    @resourceTypeSub：玩家属性类型枚举，在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
    @needCardImg: 是否是用于卡牌展示的图片,默认为false，
-- 返回值
    对应资源的显示图片文件名
 --]]
function Utility.getResTypeSubImage(resourceTypeSub, needCardImg)
    local image

    -- 如果是原始铜钱类型，直接使用铜钱的图片
    resourceTypeSub = (resourceTypeSub == ResourcetypeSub.eRawGold) and ResourcetypeSub.eGold or resourceTypeSub

    if needCardImg then
        image = string.format("dj_%d.png", resourceTypeSub)
    else
        image = string.format("db_%d.png", resourceTypeSub)
    end
    return image
end

-- 获取代币图片（包括玩家属性代表和道具代币）
--[[
-- 参数
    resourceTypeSub：玩家资源类型枚举，在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
    goodsModelId: 如果类型不是玩家属性，则需要传入模型Id
]]
function Utility.getDaibiImage(resourceTypeSub, goodsModelId)
    local ret = "db_1116.png"
    -- 如果是原始铜钱类型，直接使用铜钱的图片
    resourceTypeSub = (resourceTypeSub == ResourcetypeSub.eRawGold) and ResourcetypeSub.eGold or resourceTypeSub
    --
    if Utility.isPlayerAttr(resourceTypeSub) then
        ret = Utility.getResTypeSubImage(resourceTypeSub)
    elseif Utility.isGoods(resourceTypeSub, true) and goodsModelId then
        local tempId = math.mod(goodsModelId, 16000000)
        ret = string.format("db_%d.png", tempId)
    end

    -- 判断一下是否存在
    if not Utility.isFileExist(ret) then
        ret = "db_1113.png"
    end
    return ret
end

--- 根据资源类型和模型Id获取物品的名称
--[[
-- 参数:
    resourceTypeSub: 资源类型, 在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
    modelID: 物品modelID
返回值:
    对应资源类型的名称
--]]
function Utility.getGoodsName(resourceTypeSub, modelID)
    local ret = ""
    resourceTypeSub = tonumber(resourceTypeSub)
    modelID = tonumber(modelID)

    if resourceTypeSub == ResourcetypeSub.eHero then    -- "侠客"
        ret = HeroModel.items[modelID] and HeroModel.items[modelID].name
    elseif Utility.isEquip(resourceTypeSub) then     -- 装备
        ret = EquipModel.items[modelID] and EquipModel.items[modelID].name
    elseif Utility.isTreasure(resourceTypeSub) then  -- 神兵
        ret = TreasureModel.items[modelID] and TreasureModel.items[modelID].name
    elseif Utility.isGoods(resourceTypeSub, true) then     -- goods
        ret = GoodsModel.items[modelID] and GoodsModel.items[modelID].name
    elseif Utility.isTresureDebris(resourceTypeSub) then    -- "神兵碎片"
        ret = TreasureDebrisModel.items[modelID] and TreasureDebrisModel.items[modelID].name
    elseif Utility.isZhenjue(resourceTypeSub) then  -- 内功心法
        ret = ZhenjueModel.items[modelID].name
    elseif Utility.isPet(resourceTypeSub) then  -- 外功秘籍
        ret = PetModel.items[modelID].name
    elseif Utility.isFashion(resourceTypeSub) then  -- 时装
        ret = FashionModel.items[modelID].name
    elseif Utility.isIllusion(resourceTypeSub) then  -- 幻化
        ret = IllusionModel.items[modelID].name    
    elseif Utility.isSectBook(resourceTypeSub) then  -- 门派招式
        ret = SectBookModel.items[modelID].name
    elseif Utility.isZhenyuan(resourceTypeSub) then 
        ret = ZhenyuanModel.items[modelID].name    
    elseif Utility.isZhenshou(resourceTypeSub) then --珍兽
        ret = ZhenshouModel.items[modelID].name    
    elseif Utility.isImprint(resourceTypeSub) then --宝石
        ret = ImprintModel.items[modelID].name    
    else  -- 玩家属性
        ret = ResourcetypeSubName[resourceTypeSub]
    end
    if not ret then
        ret = ""
    end

    return ret
end

--- 根据资源类型和模型Id获取物品的简介
--[[
-- 参数:
    resourceTypeSub: 资源类型, 在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
    modelID: 物品modelID
返回值:
    对应资源类型的简介
--]]
function Utility.getGoodsIntro(resourceTypeSub, modelID)
    local ret = ""
    resourceTypeSub = tonumber(resourceTypeSub)
    modelID = tonumber(modelID)

    if resourceTypeSub == ResourcetypeSub.eHero then    -- "侠客"
        ret = HeroModel.items[modelID] and HeroModel.items[modelID].intro
    elseif Utility.isEquip(resourceTypeSub) then     -- 装备
        ret = EquipModel.items[modelID] and EquipModel.items[modelID].intro
    elseif Utility.isTreasure(resourceTypeSub) then  -- 神兵
        ret = TreasureModel.items[modelID] and TreasureModel.items[modelID].intro
    elseif Utility.isGoods(resourceTypeSub, true) then     -- goods
        ret = GoodsModel.items[modelID] and GoodsModel.items[modelID].intro
    elseif Utility.isTresureDebris(resourceTypeSub) then    -- "神兵碎片"
        ret = TreasureDebrisModel.items[modelID] and TreasureDebrisModel.items[modelID].intro
    elseif Utility.isZhenjue(resourceTypeSub) then  -- 内功心法
        ret = ZhenjueModel.items[modelID].intro
    elseif Utility.isPet(resourceTypeSub) then  -- 外功秘籍
        ret = PetModel.items[modelID].intro
    elseif Utility.isFashion(resourceTypeSub) then  -- 时装
        ret = FashionModel.items[modelID].intro
    elseif Utility.isIllusion(resourceTypeSub) then  -- 幻化
        ret = IllusionModel.items[modelID].intro    
    elseif Utility.isZhenyuan(resourceTypeSub) then -- 真元
        ret = ZhenyuanModel.items[modelID].intro    
    else  -- 玩家属性
        local tempList = {
            [ResourcetypeSub.eEXP] = TR("可用于主角升级."),             -- "经验值"
            [ResourcetypeSub.eVIT] = TR("部分游戏关卡挑战必须消耗代币."),     -- "体力值"
            [ResourcetypeSub.eSTA] = TR("部分游戏必须消耗代币."),        -- "耐力值"
            [ResourcetypeSub.eVIPEXP] = TR("使用可获得VIP经验，提升VIP等级."),   -- "VIP经验值"
            [ResourcetypeSub.eDiamond] = TR("游戏硬通货币，可选购各种商品."), -- "元宝"
            [ResourcetypeSub.eGold] = TR("游戏通用货币，可用于侠客培养消耗."),    -- "铜币"
            [ResourcetypeSub.ePVPCoin] = TR("挑战华山论剑所获得的代币，价值极大."),   -- "华山令"
            [ResourcetypeSub.eHeroCoin] = TR("聚宝阁兑换道具."),                -- "神魂"
            [ResourcetypeSub.eHeroExp] = TR("侠客升级所需经验."),            -- "灵晶"
            [ResourcetypeSub.eGDDHCoin] = TR("武林大会商店兑换所需代币."),         -- "豪侠令"
            [ResourcetypeSub.eBossCoin] = TR("挑战武林高手获得积分，积分越多奖励越丰厚."),    -- "积分"
            [ResourcetypeSub.eMerit] = TR("用于比武招亲兑换装备，分解装备可获得."),                 -- "玄金"
            [ResourcetypeSub.ePetCoin] = TR("外功秘籍商城兑换所使用的代币."),    -- "外功秘籍令"
            [ResourcetypeSub.eContribution] = TR("建设帮派和每日任务所得，可用于帮派商店兑换."),  -- "贡献"
            [ResourcetypeSub.ePetEXP] = TR("外功秘籍升级所需消耗珍贵材料."), -- "妖灵"
            [ResourcetypeSub.eHonor] = TR("荣誉"),        -- "荣誉"  -- todo
            [ResourcetypeSub.eRedBagFund] = TR("红包基金"),   -- "红包基金" -- todo
            [ResourcetypeSub.eGuildActivity] = TR("完成每日任务获得活跃度，可用于领取活跃宝箱."),-- "活跃度"
            [ResourcetypeSub.eGuildMoney] = TR("用于帮派建筑升级."),     -- "公会资金"
            [ResourcetypeSub.eXrxsStar] = TR("用于江湖悬赏中领取悬赏和提升官阶."),     -- "赏金点"
            [ResourcetypeSub.eTaoZhuangCoin] = TR("用于比武招亲兑换装备，分解套装可获得."),  -- 天玉
            [ResourcetypeSub.eRebornCoin] = TR("真元之气，可用于打通经脉."),  -- 真气
            [ResourcetypeSub.eActivetyCoin] = TR("用于铸倚天活动排名和铸造倚天剑."),  -- 铸造值
            [ResourcetypeSub.eGodDomainGlory] = TR("用于桃花岛商店兑换."),  -- 落英铃
            [ResourcetypeSub.eGuildGongfuCoin] = TR("用于学习帮派秘籍，可通过帮派战获得."),  -- 帮派武技
            [ResourcetypeSub.eMedicineCoin] = TR("提取丹药精华制成的材料，可以到药材商店换取物品."),  -- 药元
            [ResourcetypeSub.eLoveFlower] = TR("绝情谷独有的情花，看似美丽，却蕴含剧毒，可以用于绝情谷商店兑换."),  -- 情花
            [ResourcetypeSub.eYinQi] = TR("用于提升阴属性内力."),  -- 阴气
            [ResourcetypeSub.eYangQi] = TR("用于提升阳属性内力."),  -- 阳气
            [ResourcetypeSub.eXieQi] = TR("用于提升邪属性内力."),  -- 邪气
            [ResourcetypeSub.eHonorCoin] = TR("用于江湖杀商店兑换."),  -- 江湖杀荣誉点
            [ResourcetypeSub.eZslyCoin] = TR("可在珍兽商店兑换兽粮和珍兽，分解珍兽可获得。"),  -- 兽魂
            [ResourcetypeSub.eZhenshouExp] = TR("用于珍兽升级。"),  -- 兽粮
            [ResourcetypeSub.eZhenshouCoin] = TR("可在珍兽商店兑换高级珍兽。"),  -- 兽粮
        }
        ret = tempList[resourceTypeSub] or ""
    end
    if not ret then
        ret = ""
    end

    return ret
end

--- 根据资源类型和模型Id获取玩家拥有物品的数量
--[[
-- 参数:
    resourceTypeSub: 资源类型, 在“EnumsConfig.lua”文件中的 “ResourcetypeSub”定义
    modelID: 物品modelID
    notInFormation: 是否只计算未上阵的物品，默认为true
返回值:
    对应资源类型的名称
--]]
function Utility.getOwnedGoodsCount(resourceTypeSub, modelID, notInFormation)
    local ret = 0
    resourceTypeSub = tonumber(resourceTypeSub)
    modelID = tonumber(modelID)

    if resourceTypeSub == ResourcetypeSub.eHero then    -- "侠客"
        ret = HeroObj:getCountByModelId(modelID, {notInFormation = notInFormation ~= false})
    elseif Utility.isEquip(resourceTypeSub) then     -- 装备
        ret = EquipObj:getCountByModelId(modelID, {notInFormation = notInFormation ~= false})
    elseif Utility.isTreasure(resourceTypeSub) then  -- 神兵
        ret = TreasureObj:getCountByModelId(modelID, {notInFormation = notInFormation ~= false})
    elseif Utility.isGoods(resourceTypeSub, true) then     -- goods
        ret = GoodsObj:getCountByModelId(modelID)
    elseif Utility.isTresureDebris(resourceTypeSub) then    -- "神兵碎片"
        ret = TreasureDebrisObj:getCountByModelId(modelID)
    elseif Utility.isZhenjue(resourceTypeSub) then  -- 内功心法
        ret = ZhenjueObj:getCountByModelId(modelID)
    elseif Utility.isPet(resourceTypeSub) then  -- 外功秘籍
        ret = PetObj:getCountByModelId(modelID)
    elseif Utility.isIllusion(resourceTypeSub) then  -- 幻化
        ret = IllusionObj:getCountByModelId(modelID)    
    elseif Utility.isFashion(resourceTypeSub) then  -- 时装
        -- Todo
    elseif Utility.isZhenshou(resourceTypeSub) then --珍兽
        ret = ZhenshouObj:getCountByModelId(modelID, {notInFormation = notInFormation ~= false})    
    elseif Utility.isImprint(resourceTypeSub) then --宝石
        ret = ImprintObj:getCountByModelId(modelID, {notInFormation = notInFormation ~= false})
    else
        ret = PlayerAttrObj:getPlayerAttr(resourceTypeSub)
    end

    return ret
end

-- 获取侠客的阵营的图片.
--[[
-- 参数
    modelId: 侠客模型Id
]]
function Utility.getHeroRaceImg(modelId)
    local tempModel = HeroModel.items[modelId or 0]
    if not tempModel then
        return nil
    end

    local raceList = {
        [Enums.HeroRace.eRace0] = "c_143.png",   -- 江湖
        [Enums.HeroRace.eRace1] = "c_99.png",    -- 射雕
        [Enums.HeroRace.eRace2] = "c_100.png",   -- 神雕
        [Enums.HeroRace.eRace3] = "c_101.png",   -- 倚天
    }

    return raceList[tempModel.raceID]
end

-- 根据阵营Id获取阵营名字
--[[
-- 参数
    raceId：阵营ID， 取值为 Enums.lua文件的 Enums.HeroRace 枚举，数据来源为侠客模型表的raceID字段 或 服务器指定接口
-- 返回值
    如果是公共阵营、怪物、主角，则返回：“”
]]
function Utility.getRaceNameById(raceId)
    local tempList = {
        [Enums.HeroRace.eRace0] = TR("江湖"), --
        [Enums.HeroRace.eRace1] = TR("倚天"), --
        [Enums.HeroRace.eRace2] = TR("神雕"), --
        [Enums.HeroRace.eRace3] = TR("射雕"), --
    }

    return tempList[raceId or 0] or ""
end

-- 获取侠客类型的图片(神将、猛将)
--[[
-- 参数
    heroModelId: 侠客模型Id
]]
function Utility.getHeroTypeImg(heroModelId)
    local heroBase = HeroModel.items[heroModelId or 0]
    if (heroBase == nil) or (heroBase.quality == nil) or (heroBase.quality < 3) then
        return nil
    end

    local imgList = {
        [3] = "c_129.png",
        [6] = "c_130.png",
        [10] = "c_131.png",
        [13] = "c_132.png",
        [15] = "c_133.png",
        [18] = "c_134.png"
    }
    return imgList[heroBase.quality] or imgList[18]
end

-- 获取内功心法的类型标识信息
--[[
-- 参数
    typeId: 内功心法类型Id （1\2\3）
-- 返回值
    {
        typeImg = "", -- 内功心法类typeImg型标识图片
        emptyImg = "", -- 空卡槽图片
        typeName = "", -- 类型的名称
    }
]]
function Utility.getZhenjueViewInfo(typeId)
    local tempList = {
        [1] = {
            typeImg = "c_120.png",
            emptyImg = "c_123.png",
            typeName = TR("防御"),
        },
        [2] = {
            typeImg = "c_118.png",
            emptyImg = "c_121.png",
            typeName = TR("攻击"),
        },
        [3] = {
            typeImg = "c_119.png",
            emptyImg = "c_122.png",
            typeName = TR("辅助"),
        },
    }
    return tempList[typeId or 1] or {}
end

--- 判断资源类型是否是玩家属性
function Utility.isPlayerAttr(resourceTypeSub)
    local tempType = Utility.getTypeBySubType(resourceTypeSub)
    return tempType == Resourcetype.ePlayerAttr
end

--- 判断资源类型是否是侠客
function Utility.isHero(resourceTypeSub)
    if resourceTypeSub == ResourcetypeSub.eHero then
        return true
    end
    return false
end

--- 根据物品实例对象判断是否是侠客类型
function Utility.isHeroInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isHero(tempType)
end

--- 判断资源类型是否是侠客碎片
function Utility.isHeroDebris(resourceTypeSub)
    if resourceTypeSub == ResourcetypeSub.eHeroDebris then
        return true
    end

    return false
end

--- 根据物品实例对象判断是否是侠客碎片类型
function Utility.isHeroDebrisInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isHeroDebris(tempType)
end

--- 判断资源类型是否是装备
function Utility.isEquip(resourceTypeSub)
    local tempType = Utility.getTypeBySubType(resourceTypeSub)
    return tempType == Resourcetype.eEquipment
end

--- 判断资源类型是否是装备碎片
function Utility.isEquipDebris(resourceTypeSub)
    -- local tempType = Utility.getTypeBySubType(resourceTypeSub)
    if  resourceTypeSub == ResourcetypeSub.eEquipmentDebris then
        return true
    end
    return false
end

--- 根据物品实例对象判断是否是装备类型
function Utility.isEquipInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isEquip(tempType)
end

--- 判断资源类型是否是神兵
function Utility.isTreasure(resourceTypeSub)
    if resourceTypeSub == Resourcetype.eTreasure or
        resourceTypeSub == ResourcetypeSub.eBook or
        resourceTypeSub == ResourcetypeSub.eHorse then
        return true
    end
    return false
end

--- 根据物品实例对象判断是否是神兵类型
function Utility.isTreasureInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isTreasure(tempType)
end

--- 判断资源类型是否为神兵碎片
function Utility.isTresureDebris(resourceTypeSub)
    if resourceTypeSub == ResourcetypeSub.eBookDebris or        -- "兵书碎片"
            resourceTypeSub == ResourcetypeSub.eHorseDebris then    -- "徽章碎片"
        return true
    end
    return false
end

--- 根据物品实例对象判断是否是神兵碎片类型
function Utility.isTresureDebrisInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isTresureDebris(tempType)
end

--- 判断资源类型是否为goodes
--[[
-- 参数
    containDebris：是否判断装备碎片和侠客碎片
 ]]
function Utility.isGoods(resourceTypeSub, containDebris)
    local tempType = Utility.getTypeBySubType(resourceTypeSub)
    if containDebris then
        return tempType == Resourcetype.eProps or Utility.isDebris(resourceTypeSub, false)
    else
        return tempType == Resourcetype.eProps
    end
end

--- 根据物品实例对象判断是否是道具类型
--[[
-- 参数
    instanceData: 道具实体对象
    containDebris：是否判断装备碎片和侠客碎片
 ]]
function Utility.isGoodsInstance(instanceData, containDebris)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isGoods(tempType, containDebris)
end

--- 判断资源类型是否为内功心法
function Utility.isZhenjue(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eNewZhenJue
end

--- 判断资源类型是否为真元
function Utility.isZhenyuan(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eZhenYuan
end

--- 判断资源类型是否为内功心法碎片
function Utility.isZhenjueDebris(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eNewZhenJueDebris
end

-- 判断资源类型是否为秘籍
function Utility.isPet(resourceTypeSub)
    return (resourceTypeSub == ResourcetypeSub.ePet) or (resourceTypeSub == Resourcetype.ePet)
end

-- 判断资源类型是否为外功秘籍碎片
function Utility.isPetDebris(resourceTypeSub)
    return (resourceTypeSub == ResourcetypeSub.ePetDebris)
end

-- 判断资源类型是否为门派招式
function Utility.isSectBook(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eSectBook
end

-- 判断资源类型是否为时装
function Utility.isFashion(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eFashionClothes
end

-- 判断资源类型是否为幻化
function Utility.isIllusion(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eIllusion
end

-- 判断资源类型是否为幻化碎片
function Utility.isIllusionDebris(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eIllusionDebris
end

-- 判断资源类型是否是珍兽
function Utility.isZhenshou(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eZhenshou
end

-- 判断资源类型是否为珍兽碎片
function Utility.isZhenshouDebris(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eZhenshouDebris
end

--- 根据物品实例对象判断是否是珍兽类型
function Utility.isZhenshouInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isZhenshou(tempType)
end

-- 判断资源类型是否为Q版时装
function Utility.isShiZhuang(resourceTypeSub)
	return resourceTypeSub == ResourcetypeSub.eShiZhuang
end

-- 判断资源类型是否为Q版时装
function Utility.isShiZhuangDebris(resourceTypeSub)
	return resourceTypeSub == ResourcetypeSub.eShiZhuangDebris
end

--- 根据物品实例对象判断是否是Q版时装
function Utility.isShiZhuangInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isShiZhuang(tempType)
end

-- 判断资源类型是否为宝石
function Utility.isImprint(resourceTypeSub)
    return resourceTypeSub == ResourcetypeSub.eImprint
end

--- 根据物品实例对象判断是否是宝石
function Utility.isImprintInstance(instanceData)
    if not instanceData then
        return false
    end
    local tempType = Utility.getTypeByModelId(instanceData.ModelID or instanceData.ModelId)
    return Utility.isImprint(tempType)
end

-- 判断资源类型是否为碎片
function Utility.isDebris(resourceTypeSub, containTreasureDebris)
    local tempType = Utility.getTypeBySubType(resourceTypeSub)
    if not containTreasureDebris then
        return (tempType == Resourcetype.eDebris) and not Utility.isTresureDebris(resourceTypeSub)
    else
        return tempType == Resourcetype.eDebris
    end
end

-- 同步客服端和服务器的Avatar信息,
-- 请求成功后，相关数据通过avatar部分返回，不会返回其他数据。
function Utility.syncAvatarData(callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Player",
        methodName = "AvatarInfo",
        svrMethodData = {},
        needWait = false,
        callback = function(response)
            if callback then
                callback()
            end
        end,
    })
end

-- 获取战斗控制信息
-- 玩家操作按钮显示控制信息以及是否执行这些操作的回调: 针对[跳过]、[托管]和使用[技能]的控制
--[[
-- 参数
    moduleId:[MUST] 模块ID, 在EnumsConfig.lua中定义的ModuleSub表
    isPass:[OPTION] 标记战斗节点是否已通过,目前仅在普通副本中使用
    extraParam = {}, [OPTION] 额外参数，作为扩展字段
---
-- 返回值
    {   skip{
            display 是否显示跳过按钮(bool)
            func    跳过功能能否执行的条件函数（返回TRUE则执行托管）
            tips    跳过完成条件的提示
        },
        tuoguan{
            display         是否显示托管按钮(bool)
            state           当前托管状态(bool)
                            TRUE：托管，FALSE：非托管，NIL：上一次托管状态
            func            托管功能能否执行的条件函数（返回TRUE则执行托管）
        }
        skill{
            state           能否手动使用技能(bool)
        }
    }
==========================以上新旧战斗  以下是新战斗==============================
    skip {
            viewable        是否显示跳过按钮(bool)
            clickable       控制跳过按钮是否可用点击的功能函数，不可点时在界面上表现为按钮置灰
                            clickable = function(round当前回合数)
                                return true 返回true表示跳过按钮可点
                            end
            executable      用于控制跳过功能能否执行的条件函数,在点击跳过按钮时判断。
                            condition = function(round当前回合数)
                                return true 返回true表示执行跳过功能
                            end
        }
    trustee {
        viewable        是否显示托管按钮，与托管状态无关(bool)
        state           当前托管状态bd.trusteeState(见BattleDefine.lua)
                        bd = {
                            -- 托管状态定义
                            trusteeState = {
                                eNormal            = 1, -- 正常
                                eSpeedUp           = 2, -- 加速
                                eSpeedUpAndTrustee = 3, -- 加速托管
                            },
                        }

        executable      用于控制托管功能是否执行的函数,在点击托管按钮时判断。
                        executable = function()
                            return true 返回true表示执行托管按钮功能
                        end
    }
    skill {
        viewable        技能条是否显示(bool),也表示是否可以手动放技能
    }
 ]]
function Utility.getBattleControl(moduleId, isPass, extraParam)
    -- 记录所有模块的托管状态
    Utility.mTrusteeState = Utility.mTrusteeState or {}

    local result = {}
    local skip = {}
    local trustee = {}
    local skill = {state = true}
    local player = PlayerAttrObj:getPlayerInfo()

    if moduleId == ModuleSub.eBattleNormal then -- 普通战役
        skip.viewable = true
        skip.clickable = function(round)
            if round >= 6 then
                return true
            end
            local item = ModuleSubModel.items[ModuleSub.eSkip]
            local skipPlayerLv, skipVipLv = item.openLv, item.advancedOpenVIPLv
            local tempAllow = isPass or (player.Vip >= skipVipLv or player.Lv >= skipPlayerLv)
            return tempAllow, skipPlayerLv, skipVipLv
        end
        skip.executable = function(round)
            local tempAllow, skipPlayerLv, skipVipLv = skip.clickable(round)
            if not tempAllow then
                if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
                    ui.showFlashView(TR("通关一次或首充后可跳过"))
                else
                    ui.showFlashView(TR("通关一次后可跳过"))
                end
            end
            return tempAllow
        end
        -- 托管
        trustee.viewable = true
        if AutoFightObj:getAutoFight() then
            trustee.state = Enums.trustee.eSpeedUpAndTrustee
        else
            trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eNormal
        end
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.eBattleElite then -- 精英战役
        skip.viewable = true
        skip.clickable = function(round)
            if round >= 6 then
                return true
            end
            --模块是否开放
            return ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eSkipBattleElite, false)
        end
        skip.executable = function(round)
            if round >= 6 then
                return true
            end
            --模块是否开放
            return ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eSkipBattleElite, true)
        end
        --
        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId]
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.eBattleBoss then -- 行侠仗义
        skip.viewable = true
        skip.clickable = function(round)
            return ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eSkipBattleElite, false)
        end
        skip.executable = function(round)
            return ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleBossSkip, true)
        end
        --
        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId]
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.eChallengeGrab then  -- 神兵锻造
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable
        ---
        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eChallengeArena then  -- 华山论剑
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eShengyuanWars then  -- 决战桃花岛
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eChallengeWrestle then  -- 武林大会
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable
        ---
        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        skill.viewable = false
    elseif moduleId == ModuleSub.eXrxs then -- 江湖悬赏
        skip.viewable = true
        skip.clickable = function(round)
            if round >= 6 then
                return true
            end
            --模块是否开放
            return ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eGGZJSkip, false)
        end
        skip.executable = function(round)
            if round >= 6 then
                return true
            end
            return ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eGGZJSkip, true)
        end
        ---
        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId]
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.ePracticeBloodyDemonDomain then  -- 比武招亲
        skip.viewable = true
        skip.clickable = function(round)
            if round >= 6 then
                return true
            end
            local tempAllow = isPass
            return tempAllow
        end
        skip.executable = function(round)
            local tempAllow = skip.clickable(round)
            if not tempAllow then
                ui.showFlashView(TR("满星通关一次后可以跳过"))
            end
            return tempAllow
        end
        ---
        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId]
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.eXXBZ then --
        skip.viewable = false
        ---
        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId]
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.eTeambattle then --守卫襄阳
        skip.viewable = true
        skip.clickable = function(round)
            return isPass
        end
        skip.executable = function(round)
            local tempAllow = skip.clickable(round)
            if not tempAllow then
                ui.showFlashView(TR("通关一次后可以跳过"))
            end
            return tempAllow
        end
        -- 托管
        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        skill.viewable = false
    elseif moduleId == ModuleSub.ePVPInter then
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable
        ---
        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eQuickExpMeetCompare then -- 猎魔比拼
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId]
        trustee.executable = function()
            return true
        end
    elseif moduleId == ModuleSub.eQuickExpMeetChallenge then -- 闯荡-主宰挑战
        skip.viewable = true
        skip.executable = function()
            return true
        end
        skip.clickable = function() return true end

        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        trustee.executable = function()
            return true
        end

        skill.viewable = true
    elseif moduleId == ModuleSub.eSectTask then --门派战斗任务
        skip.viewable = true
        skip.executable = function()
            return true
        end
        skip.clickable = function() return true end

        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        trustee.executable = function()
            return true
        end

        skill.viewable = true
    elseif moduleId == ModuleSub.eWhosTheGod then  -- 武林盟主战报
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eGuildBattle then  -- 帮派战
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eKillerValley then  -- 绝情谷
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eJiangHuKill then --江湖杀
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == Enums.ClientModuld.eStudy then -- 聊天切磋
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    elseif moduleId == ModuleSub.eZhenshouLaoyu then  -- 珍兽牢狱
        skip.viewable = true
        skip.clickable = function(round)
            if round >= 6 then
                return true
            end
            local tempAllow = isPass
            return tempAllow
        end
        skip.executable = function(round)
            local tempAllow = skip.clickable(round)
            if not tempAllow then
                ui.showFlashView(TR("通关一次后可以跳过"))
            end
            return tempAllow
        end
        trustee.viewable = true
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        skill.viewable = true
    elseif moduleId == ModuleSub.eSectPalace then -- 门派地宫
        skip.viewable = true
        skip.executable = function() return true end
        skip.clickable = skip.executable

        trustee.viewable = false
        trustee.state = Utility.mTrusteeState[moduleId] or Enums.trustee.eSpeedUpAndTrustee
        --
        skill.viewable = false
    end

    trustee.changeTrusteeState = function(newStats)
        Utility.mTrusteeState[moduleId] = newStats
    end

    result.skip = skip
    result.trustee = trustee
    result.skill = skill

    return result
end
-- 获取战斗地图背景图
--[[
-- 参数
    moduleId:           -- 模块ID, 在EnumsConfig.lua中定义的ModuleSub表
    extraParam = {     -- 额外参数，作为扩展字：目前只有普通战役和精英战役会使用到
        fightNodeId = nil, -- 战斗节点Id
    }
]]
function Utility.getBattleBgFile(moduleId, extraParam)
    local bgImgId = 11
    if moduleId == ModuleSub.eBattleNormal then -- 普通战役
        bgImgId = extraParam and extraParam.fightNodeId
    elseif moduleId == ModuleSub.eBattleElite then -- 精英战役
        bgImgId = extraParam and extraParam.fightNodeId
    elseif moduleId == ModuleSub.eBattleBoss then -- 行侠仗义
        bgImgId = 108
    elseif moduleId == ModuleSub.eChallengeGrab then  -- 神兵锻造
        bgImgId = 101
    elseif moduleId == ModuleSub.eChallengeArena then  -- 华山论剑
        bgImgId = 102
    elseif moduleId == ModuleSub.eChallengeWrestle then  -- 武林大会
        bgImgId = 104
    elseif moduleId == ModuleSub.eXrxs then  -- 江湖悬赏
        bgImgId = 103
    elseif  moduleId == ModuleSub.ePracticeBloodyDemonDomain then  --比武招亲
        bgImgId = 105
    elseif  moduleId == ModuleSub.eGuildBattle then  --帮派战
        bgImgId = 105
    elseif moduleId == ModuleSub.eTeambattle then -- 守卫襄阳
        bgImgId = extraParam and extraParam.fightNodeId
    end


    local tempItem = FightBgRelation.items[bgImgId or 11]
    local ret = tempItem and tempItem.bgPic or "ldtl_44.jpg"
    if not Utility.isFileExist(ret) then
        ret = "ldtl_44.jpg"
    end
    return ret
end

-- 获取当前是否是debug版本
function Utility.isDebugVersion()
    local platform = IPlatform:getInstance()
    local debugModel = tonumber(platform:getConfigItem("Debug"))
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local godModel = tonumber(platform:getConfigItem("GodModel"))
        debugModel = godModel and (godModel > 0) and 1 or 0
    end

    return debugModel and (debugModel > 0)
end

--- 解析字符串形式的资源列表为table的形式
--[[
-- 参数：
    resListStr: 字符串形式的资源列表，格式为：资源类型,模型Id,数量|| 资源类型,模型Id,数量||.... (例如："1111,0,20||1112,0,20000||1605,16000025,20")
-- 返回值的形式为：
    {
        {
            resourceTypeSub = 1111, -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
            modelId = 0, -- 模型Id，如果是玩家属性资源，模型Id为0
            num = 20,  -- 数量
        },
        ...
    }
 ]]
function Utility.analysisStrResList(resListStr)
    local ret = {}

    if type(resListStr) == "string" then
        local itemList = string.split(resListStr, "||")
        for index, item in pairs(itemList) do
            local tempList = string.split(item, ",")
            if #tempList == 3 then
                local tempItem = {}
                tempItem.resourceTypeSub = tonumber(tempList[1])
                tempItem.modelId = tonumber(tempList[2])
                tempItem.num = tonumber(tempList[3])

                table.insert(ret, tempItem)
            end
        end
    end

    return ret
end

--- 解析字符串形式的属性列表为table的形式
--[[
-- 参数：
    resListStr: 字符串形式的资源列表，格式为：属性|数值,属性|数值… (例如："431|370,303|130")
-- 返回值的形式为：
    {
        {
            fightattr = 0, -- 属性Id ，在  EnumsConfig.lua 文件中 Fightattr 定义
            value = 20,  -- 属性数值
        },
        ...
    }
]]
function Utility.analysisStrAttrList(attrListStr)
    local ret = {}
    if type(attrListStr) == "string" then
        local itemList = string.split(attrListStr, ",")
        for index, item in pairs(itemList) do
            local tempList = string.split(item, "|")
            if #tempList == 2 then
                local tempItem = {}
                tempItem.fightattr = tonumber(tempList[1])
                tempItem.value = tonumber(tempList[2])

                table.insert(ret, tempItem)
            end
        end
    end

    return ret
end

--- 解析字符串形式的时装属性列表为table的形式
--[[
-- 参数：
    resListStr: 字符串形式的资源列表，格式为：范围||属性|数值,范围||属性|数值… (例如："2||201|104,2||201|100")
-- 返回值的形式为：
    {
        {
            range = 2,     -- 1:主角 2:全体 6:前排 7:后排
            fightattr = 0, -- 属性Id ，在  EnumsConfig.lua 文件中 Fightattr 定义
            value = 20,    -- 属性数值
        },
        ...
    }
]]
function Utility.analysisStrFashionAttrList(attrListStr)
    local ret = {}
    if type(attrListStr) == "string" then
        local itemList = string.split(attrListStr, ",")
        for index, item in pairs(itemList) do
            local tempList = string.split(item, "||")
            if #tempList == 2 then
                local tempItem = {}
                tempItem.range = tonumber(tempList[1])
                local attrItem = Utility.analysisStrAttrList(tempList[2])
                tempItem.fightattr = attrItem[1].fightattr
                tempItem.value = attrItem[1].value
                table.insert(ret, tempItem)
            end
        end
    end

    return ret
end

-- 获取属性范围字符串
-- 1:主角 2:全体 6:前排 7:后排
function Utility.getRangeStr(range)
    if range == 1 then
        return TR("主角")
    elseif range == 2 then
        return TR("全体")
    elseif range == 6 then
        return TR("前排")
    elseif range == 7 then
        return TR("后排")
    end
    return ""
end

--- 内部解析单条掉落信息
function Utility.analysisItemBaseDrop(baseItem)
    local oneRet = {}

    --玩家属性
    local attList = {}
    --道具
    local goodList = {}
    --碎片
    local debrisList = {}

    --基础属性的显示
    if baseItem.PlayerAttr then
        for j, v2 in pairs(baseItem.PlayerAttr) do
            if not attList[v2.ResourceTypeSub] then
                attList[v2.ResourceTypeSub] = v2.Num
            else
                attList[v2.ResourceTypeSub] = attList[v2.ResourceTypeSub] + v2.Num
            end
        end
    end

    --获得的侠客
    if baseItem.Hero then
        for j, v2 in pairs(baseItem.Hero) do
            local tempData = {}
            tempData.resourceTypeSub = ResourcetypeSub.eHero
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2
            table.insert(oneRet, tempData)
        end
    end

    --获得装备
    if baseItem.Equip then
        for j, v2 in pairs(baseItem.Equip) do
            local tempModel = EquipModel.items[v2.ModelId]

            local tempData = {}
            tempData.resourceTypeSub = tempModel.typeID
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2
            table.insert(oneRet, tempData)
        end
    end
    --获得神兵
    if baseItem.Treasure then
        for j, v2 in pairs(baseItem.Treasure) do
            local tempModel = TreasureModel.items[v2.ModelId]

            local tempData = {}
            tempData.resourceTypeSub = tempModel.typeID
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2
            if v2.Num then
                tempData.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
            end
            table.insert(oneRet, tempData)
        end
    end

    --获得神兵碎片
    if baseItem.TreasureDebris then
        for j, v2 in pairs(baseItem.TreasureDebris) do
            if not debrisList[v2.ModelId] then
                local tempData = {}
                tempData.ResourceTypeSub = v2.ResourceTypeSub
                tempData.Num = v2.Num
                debrisList[v2.ModelId] = tempData
            else
                debrisList[v2.ModelId].Num = debrisList[v2.ModelId].Num + v2.Num
            end
        end
    end
    --获得道具
    if baseItem.Goods then
        for j, v2 in pairs(baseItem.Goods) do
            if not goodList[v2.ModelId] then
                local tempData = {}

                tempData.ResourceTypeSub = v2.ResourceTypeSub
                tempData.Num = v2.Num
                goodList[v2.ModelId] = tempData
            else
                goodList[v2.ModelId].Num = goodList[v2.ModelId].Num + v2.Num
            end
        end
    end

    -- 内功心法
    if baseItem.NewZhenJue then
        for j, v2 in pairs(baseItem.NewZhenJue) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eNewZhenJue
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end

    -- 秘籍
    if baseItem.Pet then
        for j, v2 in pairs(baseItem.Pet) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.ePet
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end

    -- 时装
    if baseItem.FashionClothes then
        for j, v2 in pairs(baseItem.FashionClothes) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eFashionClothes
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end
    
    --获得铸剑道具
    if baseItem.PolaroidGoods then
        for j, v2 in pairs(baseItem.PolaroidGoods) do
            if not goodList[v2.ModelId] then
                local tempData = {}

                tempData.ResourceTypeSub = v2.ResourceTypeSub
                tempData.Num = v2.Num
                goodList[v2.ModelId] = tempData
            else
                goodList[v2.ModelId].Num = goodList[v2.ModelId].Num + v2.Num
            end
        end
    end

    --获得真元
    if baseItem.ZhenYuan then
        for j, v2 in pairs(baseItem.ZhenYuan) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eZhenYuan
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end

    --获取幻化将
    if baseItem.Illusion then
        for j, v2 in pairs(baseItem.Illusion) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eIllusion
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end

    --获取珍兽
    if baseItem.ZhenShou then
        for j, v2 in pairs(baseItem.ZhenShou) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eZhenshou
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end
    --获取Q版时装
    if baseItem.ShiZhuang then
        for j, v2 in pairs(baseItem.ShiZhuang) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eShiZhuang
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end
    --获取宝石
    if baseItem.Imprint then
        for j, v2 in pairs(baseItem.Imprint) do
            local tempData = {}

            tempData.resourceTypeSub = ResourcetypeSub.eImprint
            tempData.modelId = v2.ModelId
            tempData.instanceData = v2

            table.insert(oneRet, tempData)
        end
    end

    for i, v in pairs(attList) do
        local tempData = {}
        tempData.resourceTypeSub = i
        tempData.num = v
    
        table.insert(oneRet, tempData)
    end
    for i, v in pairs(goodList) do
        local tempData = {}
        tempData.resourceTypeSub = v.ResourceTypeSub
        tempData.modelId = i
        tempData.num = v.Num
        table.insert(oneRet, tempData)
    end
    for i, v in pairs(debrisList) do
        local tempData = {}
        tempData.resourceTypeSub = v.ResourceTypeSub
        tempData.modelId = i
        tempData.num = v.Num
        table.insert(oneRet, tempData)
    end

    return oneRet
end

--- 解析基础物品掉落列表
--[[
-- 参数
    baseDrop: 网络请求返回的 Value.BaseGetGameResourceList
-- 返回值的形式为：
    {
        -- 一次基础掉落
        {
            { －－ 单个物品的数据
                resourceTypeSub: -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
                modelId: -- 模型Id，如果是玩家属性资源，模型Id为0
                num: -- 数量
                instanceData: 物品的相信信息
            },
            ...
        },
        ...
    }
]]
function Utility.analysisBaseDrop(baseDrop)
    local ret = {}

    for index, baseItem in pairs(baseDrop or {}) do
        table.insert(ret, Utility.analysisItemBaseDrop(baseItem))
    end

    return ret
end

--- 解析掉落物品列表
--[[
-- 参数
    baseDrop: 网络请求返回的 Value.BaseGetGameResourceList
    extraDrop:{} 网络请求返回的 Value.ExtraGetGameResource
-- 返回值的形式为：
    {
        {
            resourceTypeSub: -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
            modelId: -- 模型Id，如果是玩家属性资源，模型Id为0
            num: -- 数量
            instanceData: 物品的相信信息
        },
        ...
    }
]]
function Utility.analysisGameDrop(baseDrop, extraDrop)
    local ret = {}

    -- 解析base drop
    local ret_list = Utility.analysisBaseDrop(baseDrop)
    for i,vret in ipairs(ret_list) do
        table.insertto(ret, vret)
    end

    -- 解析extra drop
    local ext_list = Utility.analysisItemBaseDrop(extraDrop or {})
    table.insertto(ret, ext_list)
    return ret
end

-- 拆分掉落物品中的 经验，钱币，将魂 到新表中
--[[
-- 参数
    dropList: 中的每项为
        {
            resourceTypeSub: -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
            modelId: -- 模型Id，如果是玩家属性资源，模型Id为0
            num: -- 数量
            instanceData: 物品的相信信息
        }
    resTypeList: 需要分拆分的物品类型列表
-- 返回值
    第一个返回值: 被拆分出来的物品，
    第二个返回值: 掉落的经验数
]]
function Utility.splitDropPlayerAttr(dropList, resTypeList)
    local addExp = 0  -- 掉落的经验值
    local attrList = {}
    --dump(resTypeList, "resTypeList:")
    for index = #dropList, 1, -1 do
        local item = dropList[index]
        --dump(item, "dropList item:")
        if table.indexof(resTypeList or {}, item.resourceTypeSub) then
            if item.resourceTypeSub == ResourcetypeSub.eEXP then
                addExp = item.num
            end

            table.insert(attrList, item)
            table.remove(dropList, index)
        end
    end

    return attrList, addExp
end

-- 解析副本节点的坐标
--[[
-- 参数
    pointsStr: 坐标节点的字符串，格式为：“111,111”
    offset:偏移量
-- 返回值
    返回坐标格式： cc.p(111, 111)
]]
function Utility.analysisPoints(pointsStr, offset)
    local posList = string.splitBySep(pointsStr, ",")
    local posX = tonumber(posList[1] or "0") + (offset and offset.x or 0)
    local posY = tonumber(posList[2] or "0") + (offset and offset.y or 0 )
    return cc.p(posX, posY)
end

-- 判断玩家属性是否足够（目前支持判断元宝、铜币...）
--[[
-- 参数:
    resourceTypeSub: 资源类型，取值在 EnumsConfig.lua 文件中 ResourcetypeSub 的定义
    needCount: 如果该参数为有效值，并且大于等于0，则需要判断是否足够，否则直接提示该资源不足
    needShowMsg: 当不足时是否需要弹框提示，默认为需要
    modelId: 资源模型id
--]]
function Utility.isResourceEnough(resourceTypeSub, needCount, needShowMsg, modelId)
    if not resourceTypeSub then
        return nil
    end

    if needCount then
    	local ownNum = Utility.getOwnedGoodsCount(resourceTypeSub, modelId or 0)
    	if ownNum >= needCount then
            return true
        end
    end

    -- 不足时的提示信息
    if needShowMsg ~= false then
        if resourceTypeSub == ResourcetypeSub.eGold then -- 判断铜币是否足够
            MsgBoxLayer.addGetGoldHintLayer()
        elseif resourceTypeSub == ResourcetypeSub.eDiamond then -- 判断元宝是否足够
            MsgBoxLayer.addGetDiamondHintLayer()
        elseif resourceTypeSub == ResourcetypeSub.eVIT or resourceTypeSub == ResourcetypeSub.eSTA then -- 体力或耐力不足
            MsgBoxLayer.addGetStaOrVitHintLayer(resourceTypeSub, needCount)
        elseif resourceTypeSub == ResourcetypeSub.eMerit or resourceTypeSub == ResourcetypeSub.eTaoZhuangCoin then --玄金或天玉
            local function oneKeyRefineEquip(colorLv)
                HttpClient:request({
                    moduleName = "Equip",
                    methodName = "EquipDecomposeOneKey",
                    svrMethodData = {colorLv},
                    callback = function(data)
                        if data.Status ~= 0 then
                            return
                        end
                        MsgBoxLayer.addGameDropLayer(data.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})

                        local list = EquipObj:getEquipList({isRefine = true, maxColorLv = colorLv[1],})
                        -- 排出主角套装
                        local tempList = {}
                        for i, equipInfo in pairs(list) do
                            if EquipModel.items[equipInfo.ModelId].ifLead ~= 1 then
                                table.insert(tempList, equipInfo)
                            end
                        end
                        list = tempList
                        
                        EquipObj:deleteEquipItems(list)
                    end
                })
            end
            local msgLayer
            local tempInfoList = {
                {
                    hintStr = TR("              分解多余装备获取{%s}和{%s}", Utility.getDaibiImage(ResourcetypeSub.eMerit), Utility.getDaibiImage(ResourcetypeSub.eTaoZhuangCoin))
                },
                {
                -- 分解蓝色装备
                    hintStr = TR("%s自动分解%s蓝色%s及%s蓝色%s以下装备", Enums.Color.eWhiteH, Enums.Color.eBlueH,
                        Enums.Color.eWhiteH, Enums.Color.eBlueH, Enums.Color.eWhiteH),
                    btnInfo = {
                        text = TR("分解"),
                        clickAction = function (pSender)
                            oneKeyRefineEquip({3, 2, 1})
                            LayerManager.removeLayer(msgLayer)
                        end
                    }
                },

                {
                -- 分解紫色装备
                    hintStr = TR("%s自动分解%s紫色%s及%s紫色%s以下装备", Enums.Color.eWhiteH, Enums.Color.ePurpleH,
                        Enums.Color.eWhiteH, Enums.Color.ePurpleH, Enums.Color.eWhiteH),
                    btnInfo = {
                        text = TR("分解"),
                        clickAction = function (pSender)
                            oneKeyRefineEquip({4, 3, 2, 1})
                            LayerManager.removeLayer(msgLayer)
                        end
                    },
                },
            }
            msgLayer = MsgBoxLayer.addOneKeyRefineChoiceLayer(tempInfoList, TR("选择"))
        elseif resourceTypeSub == ResourcetypeSub.eRebornCoin then
            if ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, false) then
                local textStr = TR("%s不足，是否前往%s[守卫光明顶]%s获取? ", Utility.getGoodsName(resourceTypeSub), Enums.Color.eGreenH, Enums.Color.eNormalWhiteH)
                local okBtnInfo = {
                    text = TR("前往"),
                    clickAction = function(msgLayer, btnObj)
                        LayerManager.addLayer({
                            name = "challenge.ExpediDifficultyLayer",
                        })
                    end
                }
                local cancelBtnInfo = {
                    text = TR("取消"),
                }
                MsgBoxLayer.addOKCancelLayer(textStr, TR("资源不足"), okBtnInfo, cancelBtnInfo)
            else
                ui.showFlashView(TR("%s不足", Utility.getGoodsName(resourceTypeSub)))
            end
        else--其他类型资源不足
            ui.showFlashView(TR("%s不足", Utility.getGoodsName(resourceTypeSub, modelId or 0)))
        end
    end

    return false
end

-- 判断背包是否有空位
--[[
-- 参数
    checkTypeList: 需要检查的背包类型列表，背包类型在 EnumsConfig.lua 中的 BagType 定义， 默认为 BagType 的所有类型
        传值如：{BagType.eHeroBag, BagType.eHeroDebrisBag, ...}
    needShowMsg: 如果背包已满时是否需要提示，默认为需要
-- 返回值
    第一个返回值：如果需要检查的背包都有空位 返回 true， 否则返回 false
    第二个返回值：已满的背包类型列表
]]
function Utility.checkBagSpace(checkTypeList, needShowMsg)
    local msgBox = nil -- 提示信息窗体对象
    local typeList = checkTypeList or {BagType.eHeroBag, BagType.eHeroDebrisBag, BagType.eGoodsBag, BagType.eEquipBag, BagType.eZhenjue, BagType.eEquipDebrisBag, BagType.eTreasureBag}
    local function formatStr(bagModel, useCount, bagSize, customText)
        return TR("您的%s%s%s背包已满(%s%s%s/%s%s%s)，请先%s或扩充您的背包",
                    Enums.Color.eGreenH, bagModel.name, Enums.Color.eNormalWhiteH, 
                    Enums.Color.eRedH, useCount, Enums.Color.eNormalWhiteH,
                    Enums.Color.eGreenH, bagSize, Enums.Color.eNormalWhiteH, 
                    customText)
    end

    local bagConfig = {
        [BagType.eHeroBag] = { -- 侠客
            okBtnInfo = {
                text = TR("归隐"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eDisassemble)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eHeroBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eHeroBag).Size
                local unBattleHeroList = HeroObj:getHeroList({notInFormation = true, })
                local text = formatStr(tempModel, #unBattleHeroList, bagSize, TR("归隐多余的%s%s%s", Enums.Color.eGreenH, tempModel.name, Enums.Color.eNormalWhiteH))

                return #unBattleHeroList >= bagSize, text
            end
        },
        [BagType.eHeroDebrisBag] = { -- 侠客碎片
            okBtnInfo = {
                text = TR("整理"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eHero)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eHeroDebrisBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eHeroDebrisBag).Size
                local props = GoodsObj:getHeroDebrisList()

                -- 显示提示时内容
                local text = formatStr(tempModel, #props, bagSize, TR("合成"))
                return #props >= bagSize, text
            end
        },
        [BagType.eGoodsBag] = { -- 道具
            okBtnInfo = {
                text = TR("整理"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eBagProps)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eGoodsBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eGoodsBag).Size
                local props = GoodsObj:getPropsList()

                -- 显示提示时内容
                local text = formatStr(tempModel, #props, bagSize, TR("整理背包"))
                return #props >= bagSize, text
            end
        },
        [BagType.eEquipBag] = { -- 装备
            okBtnInfo = {
                text = TR("分解"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eDisassemble)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eEquipBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eEquipBag).Size
                local equipList = EquipObj:getEquipList({notInFormation = true, })
                local useCount = #equipList
                local text = formatStr(tempModel, useCount, bagSize, TR("分解多余的%s%s%s", Enums.Color.eGreenH, tempModel.name, Enums.Color.eNormalWhiteH))
                return useCount >= bagSize, text
            end
        },
        [BagType.eZhenjue] = { -- 内功心法
            okBtnInfo = {
                text = TR("分解"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eDisassemble)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eZhenjue]
                local bagSize = BagInfoObj:getBagInfo(BagType.eZhenjue).Size

                return false
            end
        },
        [BagType.eEquipDebrisBag] = { -- 装备碎片
            okBtnInfo = {
                text = TR("碎片合成"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eBagEquipDebris)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eEquipDebrisBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eEquipDebrisBag).Size
                local equipDebrisList = GoodsObj:getEquipDebrisList()
                local useCount = #equipDebrisList

                local text = formatStr(tempModel, useCount, bagSize, TR("合成多余的%s%s%s", Enums.Color.eGreenH, tempModel.name, Enums.Color.eNormalWhiteH))
                return useCount >= bagSize, text
            end
        },
        [BagType.eTreasureBag] = { -- 神兵
            okBtnInfo = {
                text = TR("分解"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eDisassemble)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eTreasureBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eTreasureBag).Size
                local treasureList =TreasureObj:getTreasureList()
                local useCount = #treasureList

                local text = formatStr(tempModel, useCount, bagSize, TR("合成多余的%s%s%s", Enums.Color.eGreenH, tempModel.name, Enums.Color.eNormalWhiteH))
                return useCount >= bagSize, text
            end
        },
        [BagType.eGemBag] = { -- 宝石
            okBtnInfo = {
                text = TR("去强化"),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eImprint)
                end
            },
            checkFunc = function() -- 返回是否已满，如果已满，还会返回提示信息
                local tempModel = BagModel.items[BagType.eGemBag]
                local bagSize = BagInfoObj:getBagInfo(BagType.eGemBag).Size
                local imprintList = ImprintObj:getImprintList()
                local useCount = #imprintList

                local text = formatStr(tempModel, useCount, bagSize, TR("使用多余的%s%s%s强化", Enums.Color.eGreenH, tempModel.name, Enums.Color.eNormalWhiteH))
                return useCount >= bagSize, text
            end
        },
    }

    local fullBag = {types = {}, hintList = {}}
    for _, bagType in pairs(typeList) do
        local tempItem = bagConfig[bagType]
        if tempItem then
            local isFull, fullMsg = tempItem.checkFunc()
            if isFull then
                table.insert(fullBag.types, bagType)
                table.insert(fullBag.hintList, fullMsg)
            end
        end
    end
    -- 如果需要背包满的提示
    if #fullBag.types > 0 and needShowMsg ~= false then
        local tempItem = bagConfig[fullBag.types[1]]
        local msgText = fullBag.hintList[1]

        local expandBtnInfo = {
            normalImage = "c_28.png", --新添加的按钮图片
            text = TR("扩展"),
            clickAction = function()
                if not tolua.isnull(msgBox) then
                    LayerManager.removeLayer(msgBox)
                    msgBox = nil
                end
                MsgBoxLayer.addExpandBagLayer(fullBag.types[1], function()
                    Utility.checkBagSpace(checkTypeList, needShowMsg)
                end)
            end
        }
        --添加取消本页面
        local closeBtnInfo = {
            clickAction = function(layerObj,btnObj)
                LayerManager.removeLayer(layerObj)
            end
        }
        local okBtnInfo = tempItem.okBtnInfo or expandBtnInfo
        local cancelBtnInfo
        if tempItem.okBtnInfo then
            cancelBtnInfo = closeBtnInfo
        end

        msgBox = MsgBoxLayer.addOKLayer(msgText, TR("背包"), {okBtnInfo,expandBtnInfo}, cancelBtnInfo)
    end

    return #fullBag.types == 0, fullBag.types
end

--- 根据属性类型获取属性值用于显示的字符串
--[[
-- 参数
    attrType: 属性的内容, 可以是 枚举 Fightattr 中的值，也可以是属性名称
    attrValue: 属性值
    needPlus: 是否需要正负符号，默认为true
-- 返回值
    返回属性值用于显示的字符串
 ]]
function Utility.getAttrViewStr(attrType, attrValue, needPlus)
    if not attrType or not attrValue then
        return "0"
    end
    local tempType
    if type(attrType) == "string" then
        if not Fightattr["e"..attrType] then
            return ""
        end
        tempType = math.floor(Fightattr["e"..attrType] / 100)
    else
        tempType = math.floor(attrType / 100)
    end

    if tempType == 2 then -- 二级属性
        local formatStr = (needPlus ~= false) and "%+d" or "%d"
        return string.format(formatStr, attrValue)
    elseif tempType == 3 then -- 三级属性
        local formatStr = (needPlus ~= false) and "%+d" or "%d"
        return string.format(formatStr, attrValue)
    else -- 四级属性或更高属性
        local typeName
        if type(attrType) == "string" then
            typeName = attrType
        else
            for key, value in pairs(Fightattr) do
                if value == attrType then
                    typeName = key
                    break
                end
            end
        end
        if ConfigFunc:fightAttrIsPercentByName(typeName) then
            local formatStr = (needPlus ~= false) and "+%.1f%%" or "%.1f%%"
            return string.format(formatStr, attrValue / 100)
        else
            local formatStr = (needPlus ~= false) and "%+d" or "%d"
            return string.format(formatStr, attrValue)
        end
    end
end

--查看其他玩家的阵容
--[[
    playerId: 玩家的ID
    isPvpinter: 是否是跨服战排行榜中的玩家阵容(跨服玩家的阵容)
--]]
function Utility.showPlayerTeam(playerId, isPvpinter)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = isPvpinter and "PVPinter" or "Slot",
        methodName = isPvpinter and "GetSlotFormations" or "SlotFormations",
        svrMethodData = {playerId},
        callbackNode = nil,
        callback = function(response)
            if not response or response.Status ~= 0 then -- 获取玩家初始化数据第一部分失败
                return
            end
            local value = response.Value
            --dump(value.MateInfos, "value.MateInfos:")

            -- 创建其他玩家阵容数据对象
            local tempObj = require("data.CacheFormation"):create()
            tempObj:setFormation(value.SlotInfos, value.MateInfos)
            tempObj:setOtherPlayerInfo(value.PlayerInfo)
            LayerManager.addLayer({
                name = "team.OtherTeamLayer",
                -- cleanUp = false,
                data = {
                    formationObj = tempObj,
                },
            })
        end,
    })
end

-- 显示组队邀请或助阵页面
function Utility.showTeambattleInvitedLayer()
    -- 获取邀请信息
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TeambattleInfo",
        methodName = "GetInviteInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 修改主队副本邀请的状态
            PlayerAttrObj:changeAttr({TeamBattleStatus = Enums.TeamBattleStatus.eNone})
            Notification:postNotification(EventsName.eSocketPushPrefix .. ModuleSub.eTeambattleInvite)

            local tempList = {}
            for _, item in ipairs(response.Value and response.Value.InviteInfo or {}) do
                if item.IsDateOut ~= 1 then  -- IsDateOut:是否已过期(1:过期,0:未过期)
                    table.insert(tempList, item)
                end
            end
            if #tempList == 0 then
                ui.showFlashView(TR("已经没有组队邀请的队伍了～"))
                return
            end

            -- 打开组队列表
            LayerManager.addLayer({
                name = "teambattle.TeambattleInvitedLayer",
                data = {
                    dataList = tempList,
                },
                cleanUp = false,
            })
        end,
    })
end

-- 获取内功心法铜币洗炼的消耗
--[[
-- 参数
    upAttrCount: 需要洗炼的次数
-- 返回值
    {
        {
            resourceTypeSub = 1111, -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
            modelId = 0, -- 模型Id，如果是玩家属性资源，模型Id为0
            num = 20,  -- 数量
        },
        ...
    }
]]
function Utility.getZhenjueGoldUpAttrUse(upAttrCount)
    local extraNum = PlayerAttrObj:getPlayerAttrByName("ExtraNum") or 0
    local useList = {}
    for index = extraNum + 1, extraNum + upAttrCount do
        local tempIndex = math.min(index, ZhenjueUpattruse1Relation.items_count)
        local tempItem = ZhenjueUpattruse1Relation.items[tempIndex]

        local tempList = Utility.analysisStrResList(tempItem and tempItem.upAttrUse1 or "")
        for _, item in pairs(tempList) do
            local tempKey = item.modelId ~= 0 and item.modelId or item.resourceTypeSub
            local oldItem = useList[tempKey]
            if oldItem then
                oldItem.num = oldItem.num + item.num
            else
                useList[tempKey] = item
            end
        end
    end

    return table.values(useList)
end

-- 获取物品的途径信息
--[[
-- 参数
    resourceTypeSub: 资源类型
    modelId: 资源模型Id
    retCallback: 获取信息的回调函数，回调函数的参数和该函数的返回值一致
-- 返回值
    第一个返回值:
        表示是否异步返回信息，True 表示异步返回， false表示同步返回
    第二个返回值:
        {
            {
                moduleID: 产出的模块Id
                moduleName: 产出模块的名称
                chapterModelId: 普通副本产出的章节模型Id，只有在普通副本产出时才有该返回值
                chapterIsOpen: 普通副本产出的章节是否已开启，如果第一个返回值为true，则需要根据回调函数返回值获得最终状态
            },
            ....
        }
]]
function Utility.getResourceDropWay(resourceTypeSub, modelId, retCallback)
    local needMaxCount = 999  -- 需要产出信息最大个数

    -- 单独从活动产出的特殊道具
    if  (modelId == 16050283) or                            -- 龙元
        (modelId == 28010003) or (modelId == 15080003) or   -- 斗酒神僧幻化及其碎片
        -- (modelId == 28010006) or (modelId == 15080006) or   -- 少林三渡幻化及其碎片
        (modelId == 28010004) or (modelId == 15080004) or   -- 黄裳幻化及其碎片
        (modelId == 28010005) or (modelId == 15080005) or   -- 达摩祖师幻化及其碎片
        (modelId == 28010006) or (modelId == 15080006) or   -- 三渡幻化及其碎片
        (modelId == 28010007) or (modelId == 15080007) or   -- 峨眉掌门周芷若幻化及其碎片
        (modelId == 28010008) or (modelId == 15080008) or   -- 明教教主张无忌幻化及其碎片
        (modelId == 28010009) or (modelId == 15080009) or   -- 玉女素心小龙女幻化及其碎片
        (modelId == 28010010) or (modelId == 15080010) or   -- 西狂杨过幻化及其碎片
        (modelId == 28010011) or (modelId == 15080011) or   -- 蓉儿幻化及其碎片
        (modelId == 28010012) or (modelId == 15080012) or   -- 北侠郭靖幻化及其碎片
        (modelId == 28010013) or (modelId == 15080013) or   -- 日月魔主幻化及其碎片
        (modelId == 28010014) or (modelId == 15080014) or   -- 令狐师兄幻化及其碎片
        (modelId == 16050383) or (modelId == 16050382) or   -- 完美静心丸及卓越静心丸
        (modelId == 21010005) or (modelId == 15090005) or   -- 九尾灵狐及九尾灵狐碎片
        (modelId == 21010007) or (modelId == 15090007) or   -- 年兽及年兽碎片
        (modelId == 21010008) or (modelId == 15090008) or   -- 闪电貂及闪电貂碎片
        (modelId == 21010009) or (modelId == 15090009) or   -- 莽牯朱蛤及莽牯朱蛤碎片
        (modelId == 21010010) or (modelId == 15090010) or   -- 五毒雷蝎及五毒雷蝎碎片
        (modelId == 21010011) or (modelId == 15090011) or   -- 九色鹿及九色鹿碎片
        -- 倚天剑，屠龙刀，青光利剑，痴情，蛇形铁鞭，静心缘，龙鳞手套，射日神弓，绿玉杖，酒葫芦，归一剑，碧海玉萧，太极拂尘，至死不渝，降魔杵，凌虚龙珠
        (modelId == 14011804) or (modelId == 14011805) or
        (modelId == 14011806) or (modelId == 14011807) or
        (modelId == 14011808) or (modelId == 14011809) or
        (modelId == 14011810) or (modelId == 14011811) or
        (modelId == 14011812) or (modelId == 14011813) or
        (modelId == 14011814) or (modelId == 14011815) or
        (modelId == 14011803) or (modelId == 14011801) or
        (modelId == 14011802) or (modelId == 14011816) or   -- 所有红色神兵
        (modelId == 16050366) or                          -- 绝学参悟丹
        (modelId == 16050092) or (modelId == 16050093)  then  -- 十年珍兽内丹,百年珍兽内丹
        local ret = {{
            moduleID = -1,
            moduleName = TR("活动产出"),
        }}
        if retCallback then
            retCallback(ret)
        end
        return false, ret
    end

    -- 辅助接口：读取从副本里的产出
    local function getWayOfBattle(flag, modelConfig)
        local itemOutNodeList, debrisOutNodeList = {}, {}
        local chapterIdList = {}
        if flag then
            itemOutNodeList = ConfigFunc:getDropNodeByModelId(modelId)
            local itemModel = modelConfig[modelId]
            if #itemModel.debrisModelIds > 0 then
                debrisOutNodeList = ConfigFunc:getDropNodeByModelId(itemModel.debrisModelIds[1])
            end
        else
            debrisOutNodeList = ConfigFunc:getDropNodeByModelId(modelId)
            local goodsModel = GoodsModel.items[modelId]
            itemOutNodeList = ConfigFunc:getDropNodeByModelId(goodsModel.outputModelID)
        end
        for _, list in pairs({itemOutNodeList, debrisOutNodeList}) do
            for _, nodeItem in pairs(list) do
                local tempId = math.floor(nodeItem.nodeModelID / 100)
                local oldId = chapterIdList[tempId]
                chapterIdList[tempId] = oldId and math.min(nodeItem.nodeModelID, oldId) or nodeItem.nodeModelID
            end
        end
        -- 排序产出章节Id
        table.sort(chapterIdList, function(id1, id2)
            return id1 < id2
        end)
        return chapterIdList
    end

    -- 辅助接口：处理副本的产出返回值
    -- 参数isBackOrder表示是否逆序，如果该参数为true，则需要先copy副本产出，再copy其他产出
    local function dealReturnData(otherWay, chapterIdList, battleInfo, isBackOrder)
        local retCount = #otherWay
        if retCount >= needMaxCount then
            return otherWay
        end

        local retData = {}
        if (isBackOrder == false) then
            -- 读取其他产出途径
            retData = clone(otherWay)
        end
        for chapterId, nodeId in pairs(chapterIdList) do
            local chapterIsOpen = battleInfo and battleInfo.MaxNodeId > nodeId
            if chapterIsOpen == nil then chapterIsOpen = nil end
            local tempItem = {
                moduleID = ModuleSub.eBattleNormal,
                moduleName  = TR("普通副本"),
                chapterModelId = chapterId,
                nodeModelId = nodeId,
                chapterIsOpen = chapterIsOpen,
            }
            table.insert(retData, tempItem)

            -- 给其他产出途径预留位置
            local nowCount = #retData
            if (isBackOrder == true) then
                nowCount = #retData + retCount
            end
            if nowCount >= needMaxCount then
                break
            end
        end
        if (isBackOrder == true) then
            -- 读取其他产出途径
            for _,v in ipairs(otherWay) do
                table.insert(retData, clone(v))
            end
        end
        return retData
    end

    -- 侠客和侠客碎片
    if Utility.isHero(resourceTypeSub) or Utility.isHeroDebris(resourceTypeSub) then
        local dropWay = {}

        -- 整理侠客或对应碎片在其它模块产出信息
        for _, item in pairs(DropWayHeroRelation.items) do
            local tempModel = GoodsModel.items[item.ID]
            if (modelId == item.ID) or (tempModel and (modelId == tempModel.outputModelID)) then
                local tempItem = {
                    moduleID = item.moduleID,
                    moduleName  = item.moduleName,
                }
                table.insert(dropWay, tempItem)
            end
        end

        local chapterIdList = getWayOfBattle(Utility.isHero(resourceTypeSub), HeroModel.items)
        local battleInfo = BattleObj:getBattleInfo(function(cbData)
            retCallback(dealReturnData(dropWay, chapterIdList, cbData, false))
        end)
        local isAsync = battleInfo == nil and #chapterIdList > 0 and #dropWay < needMaxCount
        return isAsync, dealReturnData(dropWay, chapterIdList, battleInfo, false)
    else
        -- 幻化将跟随幻化碎片的获取途径
        local newTypeSub = resourceTypeSub
        local newModelId = modelId
        if (newTypeSub == ResourcetypeSub.eIllusion) then
            newTypeSub = ResourcetypeSub.eIllusionDebris
            for _,v in pairs(GoodsModel.items) do
                if (v.outputModelID == modelId) then
                    newModelId = v.ID
                    break
                end
            end
        end

        -- 模型id指定产出方式
        local specialList = {}
        local normalList = {}
        for _, item in pairs(DropWayTypeRelation.items) do
            if item.typeID == newTypeSub then
                local tempItem = {
                    moduleID = item.moduleID,
                    moduleName  = item.moduleName,
                }
                if item.modelID > 0 then
                    if item.modelID == newModelId then
                        table.insert(specialList, tempItem)
                    end
                else
                    table.insert(normalList, tempItem)
                end
            end
        end
        local ret = next(specialList) and specialList or normalList

        -- 装备和碎片有些还可以从副本里产出
        if Utility.isEquip(newTypeSub) or Utility.isEquipDebris(newTypeSub) then
            local chapterIdList = getWayOfBattle(Utility.isEquip(newTypeSub), EquipModel.items)
            local battleInfo = BattleObj:getBattleInfo(function(cbData)
                retCallback(dealReturnData(ret, chapterIdList, cbData, true))
            end)
            local isAsync = battleInfo == nil and #chapterIdList > 0 and #ret < needMaxCount
            return isAsync, dealReturnData(ret, chapterIdList, battleInfo, true)
        else
            if retCallback then
                retCallback(ret)
            end
            return false, ret
        end
    end
end

-- 获取绝学的途径
function Utility.getFashionWay(fashionModelId)
    local wayModule = FashionModel.items[fashionModelId].moduleID
    if (wayModule == ModuleSub.eGuildBook) then
        -- 从帮派秘籍获取
        if not Utility.isEntityId(GuildObj:getGuildInfo().Id) then
            ui.showFlashView(TR("需加入帮派后在帮派秘籍处学习"))
            return
        end
        if (table.nums(GuildObj:getGuildBuildInfo()) > 0) then
            LayerManager.addLayer({name = "guild.GuildBookHomeLayer"})
        else
            HttpClient:request({
                svrType = HttpSvrType.eGame,
                moduleName = "Guild",
                methodName = "GetGuildInfo",
                svrMethodData = {},
                callbackNode = self,
                callback = function(response)
                    if not response or response.Status ~= 0 then
                        ui.showFlashView(TR("获取帮派详细信息出错"))
                    else
                        GuildObj:updateGuildInfo(response.Value)
                        LayerManager.addLayer({name = "guild.GuildBookHomeLayer"})
                    end
                end,
            })
        end
    elseif (wayModule == ModuleSub.eExpedition) then
        -- 从光明顶获取
        if not ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
            return
        end
        LayerManager.addLayer({name = "challenge.ExpediDifficultyLayer",})
    else
        -- 只能通过活动获取
        local needSectInfo = nil
        for _,v in pairs(SectModel.items) do
            local tmpStrList = string.split(v.fashionInfo, ",")
            if (tonumber(tmpStrList[1]) == fashionModelId) then
                needSectInfo = clone(v)
                break
            end
        end
        if (needSectInfo == nil) then
            ui.showFlashView(TR("该绝学需通过参与活动获得"))
            return
        end
        -- 从八大门派获取
        SectObj:getSectInfo(function(response)
            local currSectInfo = response.CurrentSectInfo or {}
            local currSectId = currSectInfo.SectId or 0
            if (currSectId ~= needSectInfo.ID) then
                ui.showFlashView(TR("获取该绝学需要加入门派:%s%s", Enums.Color.eYellowH, needSectInfo.name))
            else
                LayerManager.addLayer({
                    name = "sect.SectBookLayer",
                    data = {}
                })
            end
        end)
    end
end

-- 弹出各种材料的获取途径
function Utility.showResLackLayer(resourceTypeSub, modelId)
    if (resourceTypeSub == ResourcetypeSub.eGold) then
        -- 铜钱
        MsgBoxLayer.addGetGoldHintLayer()
    elseif (resourceTypeSub == ResourcetypeSub.eDiamond) then
        -- 元宝
        MsgBoxLayer.addGetDiamondHintLayer()
    else
        -- 其他
        LayerManager.addLayer({
            name = "hero.DropWayLayer",
            data = {
                resourceTypeSub = resourceTypeSub,
                modelId = modelId
            },
            cleanUp = false,
        })
    end
end

-- 弹出拜师礼物的获取途径（单独处理）
function Utility.showTeacherLikeGiftWay(resourceTypeSub, modelId)
    -- 判断某个材料是否已在拜师礼物列表里
    local function isResInTeacherGiftList(resModelId)
        local retHave = false
        for _,v in ipairs(Utility.teacherLikeGiftList or {}) do
            if (v == resModelId) then
                retHave = true
                break
            end
        end
        return retHave
    end

    -- 第一次访问，则处理拜师材料列表
    if (Utility.teacherLikeGiftList == nil) then
        Utility.teacherLikeGiftList = {}

        for _,v in pairs(TeacherModel.items) do
            for _,strId in ipairs(string.split(v.likeGiftStr, ",")) do
                if (isResInTeacherGiftList(tonumber(strId)) == false) then
                    table.insert(Utility.teacherLikeGiftList, tonumber(strId))
                end
            end
        end
    end

    -- 弹出提示
    LayerManager.addLayer({
        name = "hero.DropWayLayer",
        data = {
            isTeacherGift = true
        },
        cleanUp = false,
    })
end

-- 提交调试信息函数
function Utility.launchStepInfo(step, subStep, extInfo)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        --[[local version = IPlatform:getInstance():getConfigItem("Version")
        if version ~= nil and  version ~= "" and tonumber(version) ~= nil and tonumber(version) >= 175 then
            IPlatform:getInstance():stepInfo(step, subStep, extInfo)
        end]]--
        IPlatform:getInstance():stepInfo(step, subStep, extInfo)
    end
end

---根据modelId,得到资源的类型
--[[
-- 参数：
    modelId:模型Id
    getSubType: 是否是获取资源子类型，默认为true
-- 返回值
    getSubType ~= false时：物品资源的子类型，在 EnumsConfig.lua 文件的 ResourcetypeSub 中定义
    getSubType == false时：物品资源的大类型，在 EnumsConfig.lua 文件的 Resourcetype 中定义
]]
function Utility.getTypeByModelId(modelId, getSubType)
    local modelId = modelId or 0
    if getSubType ~= false then
        return math.floor(modelId / 10000)
    else
        return math.floor(modelId / 1000000)
    end
end

--根据moduleId,得到模块图标
--[[
-- 参数
    moduleId:模块id
-- 返回
    模块图标
]]
function Utility.getModuleIcon(moduleId)
    local modelId = moduleId or 0
    return ModuleSubModel.items[moduleId].pic
end

-- 根据资源子类型获取资源主类型
--[[
-- 参数：
    resourceTypeSub:物品资源的子类型，在 EnumsConfig.lua 文件的 ResourcetypeSub 中定义
-- 返回值
    物品资源的大类型，在 EnumsConfig.lua 文件的 Resourcetype 中定义
]]
function Utility.getTypeBySubType(resourceTypeSub)
    return math.floor((resourceTypeSub or 0) / 100)
end

-- 获取当前是否需要屏蔽
--[[
-- 返回值
    nil或false 表示不需要屏蔽，其它值都是需要屏蔽
]]
function Utility.isNeedShield()
    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eShield) then
        return true
    else
        return false
    end
end

-- 根据宠物实例信息获取技能描述
-- 参数：petData 宠物实例数据
-- 参数：calcTalent 是否计算天赋，默认为true
-- 参数：colors 颜色值列表，例：{Enums.Color.eRedH, Enums.Color.eBrownH}
function Utility.getPetSkillDes(petData, calcTalent, colors)
    local model = PetModel.items[petData.ModelId]
    calcTalent = (calcTalent ~= false)

    -- 计算系数(与设计文档一致)
    local n = model.atkFactor
    local m = 0
    local e = 0

    -- 天赋
    if calcTalent and petData.TalentInfoList then
        for i, talentInfo in ipairs(petData.TalentInfoList) do
            -- 单个天赋
            local talentModel = PetTalTreeModel.items[talentInfo.TalentID]
            m = m + talentModel.perExtraAtkFactorR * talentInfo.TalentNum
            e = e + talentModel.perExtraAtkDamage * talentInfo.TalentNum
        end
    end

    -- 描述
    local origin = model.atkIntroTemplate or TR("未知技能：%s")

    local value = (n*(1+m/100)) .. "%"
    if e > 0 then
        value = value .. "+" .. e
    end

    -- 颜色
    if colors then
        value = colors[1] .. value .. colors[2]
    end

    local des = TR(origin, value)

    -- 额外BUFF
    if calcTalent and petData.BuffId and petData.BuffId ~= "" then
        local buffModel = PetExtraBuffRelation.items[petData.ModelId]
        if buffModel then
            for i, info in pairs(buffModel) do
                if info.buffIDs == petData.BuffId then
                    des = des .. "; " .. info.intro
                    break
                end
            end
        end
    end

    return des
end

-- 根据宠物实例信息获取属性
function Utility.getPetAttrs(petData, calcTalent)
    -- 模型
    local model = PetModel.items[petData.ModelId]
    calcTalent = calcTalent ~= false

    local ret = {}
    -- 升级属性
    local lvFactor = 1 + model.upR * ((petData.Lv or 1) - 1)
    ret[Fightattr.eAP] = model.APBase * lvFactor -- 攻
    ret[Fightattr.eDEF] = model.DEFBase * lvFactor -- 防
    ret[Fightattr.eHP] = model.HPBase * lvFactor -- 血
    -- print(model.HPBase, lvFactor, calcTalent)

    -- 天赋属性
    if calcTalent and petData.TalentInfoList then
        for i, talentInfo in ipairs(petData.TalentInfoList) do
            -- 单个天赋
            local talentModel = PetTalTreeModel.items[talentInfo.TalentID]
            local attrs = Utility.analysisStrAttrList(talentModel.perAttrStr)
            --dump(attrs, "attrs")
            for j, attr in ipairs(attrs) do
                if not ret[attr.fightattr] then ret[attr.fightattr] = 0 end
                ret[attr.fightattr] = ret[attr.fightattr] + attr.value * talentInfo.TalentNum
            end
        end
    end

    return ret
end

-- 解析这样的属性加成字符串 "401|1,402|1,403|1"
function Utility.analyzeAttrAddString(string)
    local retArray = {}
    local extraAttrStr = string.splitBySep(string or "", ",")
    for _, item in pairs(extraAttrStr) do
        local tempList = string.splitBySep(item, "|")
        local attrType, attrValue = tonumber(tempList[1]), tonumber(tempList[2])
        if ConfigFunc:fightAttrIsPercentByValue(attrType) then
            table.insert(retArray, {name = FightattrName[attrType], attrKey = attrType, value = string.format("%.2f%%", attrValue/100)})
        else
            table.insert(retArray, {name = FightattrName[attrType], attrKey = attrType, value = tostring(attrValue)})
        end
    end
    return retArray
end

-- 获取原待机音效中的随机一个
function Utility.randomStayAudio(originName)
    if #originName > 0 then
        local audioList = string.splitBySep(originName, ",")
        local curAudio = audioList[math.random(1, #audioList)]
        return curAudio .. ".mp3"
    end
end

-- 信息统计使用
function Utility.cpInvoke(type)

end

-- 获取装备类型对应的字符串
function Utility.getEquipTypeString(equipType)
    local mEquipTypeNameList = {
        [ResourcetypeSub.eHelmet] = "Helmet",
        [ResourcetypeSub.eWeapon] = "Weapon",
        [ResourcetypeSub.eNecklace] = "Necklace",
        [ResourcetypeSub.eClothes] = "Clothes",
        [ResourcetypeSub.ePants] = "Pants",
        [ResourcetypeSub.eShoe] = "Shoes",
        [ResourcetypeSub.eBook] = "Book",
    }
    return mEquipTypeNameList[equipType]
end

-- 获取宝石类型对应的字符串
function Utility.getImprintTypeString(imprintType)
    local mImprintTypeNameList = {
        [ResourcetypeSub.eHelmet] = "HelmetImprint",
        [ResourcetypeSub.eWeapon] = "WeaponImprint",
        [ResourcetypeSub.eNecklace] = "NecklaceImprint",
        [ResourcetypeSub.eClothes] = "ClothesImprint",
        [ResourcetypeSub.ePants] = "PantsImprint",
        [ResourcetypeSub.eShoe] = "ShoesImprint",
    }
    return mImprintTypeNameList[imprintType]
end

-- 判断当前经脉共鸣激活的层数
function Utility.getActiveRebornLv()
    local slotInfos = FormationObj:getSlotInfos()
    local rebornItemList = {}
    for _, item in pairs(FormationObj:getSlotInfos()) do
        if Utility.isEntityId(item.HeroId) then
            local heroData = HeroObj:getHero(item.HeroId)
            local lvItem = nil
            if item.RebornLvModelId and item.RebornLvModelId > 0 then
                lvItem = RebornLvModel.items[item.RebornLvModelId]
            else
                local heroData = HeroObj:getHero(item.HeroId)
                lvItem = RebornLvModel.items[heroData.RebornId or 0]
            end

            if lvItem then
                table.insert(rebornItemList, lvItem)
            end  
        end
    end

    if #rebornItemList < 6 then -- 激活转身的上阵人物需要6人
        return 0
    end

    local retLv
    for _, item in pairs(rebornItemList) do
        retLv = not retLv and item.rebornNum or math.min(retLv, item.rebornNum)
    end

    return retLv
end

-- 读取淬体名
function Utility.getQuenchName(nQuench)
    local nTemp = nQuench or 0
    local numberStrList = {
        [0] = TR("淬体零重"), 
        [1] = TR("淬体一重"), 
        [2] = TR("淬体二重"), 
        [3] = TR("淬体三重"), 
        [4] = TR("淬体四重"), 
        [5] = TR("淬体五重"), 
        [6] = TR("淬体六重")
    }
    return numberStrList[nTemp]
end

-- 判断人物是否在小伙伴中上阵
--参数 modelId 人物的模型ID
function Utility.isHeroInMate(modelId)
    local mateInfo = FormationObj:getMateInfo()
    for i,v in ipairs(mateInfo) do
        if modelId == v.ModelId then
            return true
        end
    end
    return false
end

--获取主将的形象图，可能是主将ID或幻化ID
function Utility.getHeroStaticPic(modelId)
    if HeroFashionRelation.items[modelId] then
        modelId = HeroFashionRelation.items[modelId].modelId
    end

    if Utility.isIllusion(Utility.getTypeByModelId(modelId)) then
        return IllusionModel.items[modelId].staticPic..".png"
    else
        return HeroModel.items[modelId].staticPic..".png"
    end
end

--获取10~99999数字对应的数字图片参数字符
function Utility.getNumPicChar(num)
    if math.abs(num) < 10 or math.abs(num) > 99999 then
        return num
    end

    local unitList = {
        ":",        -- 十
        ";",        -- 百
        "<",        -- 千
        "=",        -- 万
    }

    local CUnitList = {
        TR("十"),
        TR("百"),
        TR("千"),
        TR("万"),
    }

    local CNumberList = {
        [0] = TR("零"),
        [1] = TR("一"),
        [2] = TR("二"),
        [3] = TR("三"),
        [4] = TR("四"),
        [5] = TR("五"),
        [6] = TR("六"),
        [7] = TR("七"),
        [8] = TR("八"),
        [9] = TR("九"),
    }

    local numStrList = {}
    local unitCount = 0
    while num > 0 do
        -- 当前个位数
        local lastNum = num % 10
        table.insert(numStrList, 1, {lastNum, unitCount})

        num = math.floor(num/10)
        unitCount = unitCount + 1
    end

    local numStr = ""
    local cNumStr = ""
    for i, unitNum in ipairs(numStrList) do
        -- 是一个10位数
        if i == 1 and unitNum[1] == 1 and unitNum[2] == 1 then
            numStr = numStr .. unitList[1]
            cNumStr = cNumStr .. CUnitList[1]
        -- 0没单位
        elseif unitNum[1] == 0 then
            local lastChar = string.sub(numStr, -1, -1)
            if lastChar ~= "0" then
                numStr = numStr .. 0
                cNumStr = cNumStr .. CNumberList[0]
            end
        else
            numStr = numStr .. unitNum[1] .. (unitList[unitNum[2]] or "")
            cNumStr = cNumStr .. CNumberList[unitNum[1]] .. (CUnitList[unitNum[2]] or "")
        end
    end

    local lastChar = string.sub(numStr, -1, -1)
    if lastChar == "0" then
        numStr = string.sub(numStr, 1, -2)
        cNumStr = string.sub(cNumStr, 1, -2)
    end

    return numStr, cNumStr
end

--江湖杀获取职业图标
function Utility.getJHKJobPic(jobId)
    if not jobId then
        return
    end
    local picList = {
        [1] = "jhs_72.png", --豪杰
        [2] = "jhs_71.png", --刺客
        [3] = "jhs_73.png", --书生
        [4] = "jhs_74.png", --镖师
    }
    return picList[jobId] or "jhs_72.png"
end

-- 获取剧情引导音效文件
-- 获取音效文件
function Utility.getMusicFile(fileId)
    local fileModel = PersonPeiyin.items[fileId]
    if not fileModel then return end

    local musictype = Utility.getMusicType()
    if musictype == Enums.MusicType.eML then
        -- 男主角
        if Utility.getPlayerSex() then
            return fileModel.male
        -- 女主角
        else
            return fileModel.female and fileModel.female ~= "" and fileModel.female or fileModel.male
        end
    elseif musictype == Enums.MusicType.eHK then
        -- 男主角
        if Utility.getPlayerSex() then
            return fileModel.yueMale
        -- 女主角
        else
            return fileModel.yueFemale and fileModel.yueFemale ~= "" and fileModel.yueFemale or fileModel.yueMale
        end
    end
end

-- 获取战斗引导音效文件
function Utility.getBattleMusicFile(musicInfo)
    if not musicInfo then return end

    local musictype = Utility.getMusicType()

    if musictype == Enums.MusicType.eML then
        -- 男主角
        if Utility.getPlayerSex() then
            return musicInfo.sound_default
        -- 女主角
        else
            return musicInfo.sound_female and musicInfo.sound_female ~= "" and musicInfo.sound_female or musicInfo.sound_default
        end
    elseif musictype == Enums.MusicType.eHK then
        -- 男主角
        if Utility.getPlayerSex() then
            return musicInfo.sound_tw
        -- 女主角
        else
            return musicInfo.sound_n_tw and musicInfo.sound_n_tw ~= "" and musicInfo.sound_n_tw or musicInfo.sound_tw
        end
    end
end

-- 人物喊话音效字段
-- heroModel 人物模型数据（可以传模型id）
-- 返回人物技能音效，人物喊话音效
function Utility.getHeroSound(heroModel)
    if type(heroModel) == "number" then
        heroModel = IllusionModel.items[heroModel] or FashionModel.items[heroModel] or HeroModel.items[heroModel]
    end
    if not heroModel then return end

    local musictype = Utility.getMusicType()

    local skillSound, staySound = nil, nil

    if musictype == Enums.MusicType.eML then
        skillSound, staySound = heroModel.skillSound, heroModel.staySound
    elseif musictype == Enums.MusicType.eHK then
        skillSound, staySound = heroModel.skillSoundTW, heroModel.staySoundTW
    end

    return skillSound, staySound
end

-- 获取引导事件音效文件
function Utility.getEventSound(eventModel)
    local musictype = Utility.getMusicType()
    local sound = nil
    if musictype == Enums.MusicType.eML then
        sound = eventModel.sound
    elseif musictype == Enums.MusicType.eHK then
        sound = eventModel.twSound
    end

    return sound
end

-- 获取合体技汉化音效文件
function Utility.getJointSkilSound(heroModel)
    if type(heroModel) == "number" then
        heroModel = IllusionModel.items[heroModel] or FashionModel.items[heroModel] or HeroModel.items[heroModel]
    end
    if not heroModel then return end

    local musictype = Utility.getMusicType()
    local sound = nil
    if musictype == Enums.MusicType.eML then
        sound = heroModel.jointSkillSound
    elseif musictype == Enums.MusicType.eHK then
        sound = heroModel.jointSkillSoundTW
    end

    return sound
end

-- 玩家主角男女(true: 男  false: 女)
function Utility.getPlayerSex()
    -- 主角模型id
    local playerHeroModelId = FormationObj:getSlotInfoBySlotId(1).ModelId

    return not Utility.getModelSex(playerHeroModelId)
end
-- 通过模型id判断主角男女
-- 返回 true：女， false：男
function Utility.getModelSex(modelId)
    -- 女主角模型
    local femaleList = {12010019, 12010020, 12010021, 12010022, 12010023, 12010024}

    if table.indexof(femaleList, modelId) then
        return true
    end

    return false
end

-- 获取当前音效类型（1:国语 2:港台）
function Utility.getMusicType()
    local musictype = LocalData:getGameDataValue("MusicType")
    if not musictype then
        -- 港台渠道，默认粤语
        if IPlatform:getInstance():getConfigItem("PartnerID") == "9401" or
            IPlatform:getInstance():getConfigItem("PartnerID") == "9901" or
            IPlatform:getInstance():getConfigItem("PartnerID") == "9902" then
            musictype = Enums.MusicType.eHK
        else
            musictype = Enums.MusicType.eML
        end
    end

    LocalData:saveGameDataValue("MusicType", musictype)

    return musictype
end

-- 设置当前音效类型（1:国语 2:港台）
function Utility.setMusicType(musictype)
    LocalData:saveGameDataValue("MusicType", musictype)
end

-- 通过vip等级返回字符串会员或尊享
function Utility.getVipStr(vipLv)
    local textStr = TR("会员%d", vipLv)
    local vipStep = Utility.getVipStep()
    if vipLv > vipStep then
        textStr = TR("尊享%d", vipLv-vipStep)
    end

    return textStr
end

-- 获取vip会员，尊享分界线
function Utility.getVipStep()
    return 26
end

-- 乱序
function Utility.shuffle(t)
    if type(t)~="table" then
        return
    end
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end