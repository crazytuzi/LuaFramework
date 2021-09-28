--[[
    文件名：ConfigFunc
	描述：获取配置文件中某些属性的函数，其目的是为了避免配置表字段修改后可以在这些函数中统一修改。
	创建人：liaoyuangang
	创建时间：2014.06.09
-- ]]

require("Config.EnumsConfig")

ConfigFunc = {}

--- 注意：大家在添加函数的时候务必遵循以下几点
--- 1、先查看是否已有相关的函数，避免添加功能重复的函数
--- 2、添加到该文件的函数务必要规范、整洁
--- 3、添加函数时务必添加到对应代码区域内
--- 4、如果添加的函数没有相应的代码区域，需要自己在文件尾部添加相应的代码区域开始标识
--- 5、代码区域以标识 “-- ======== 配置文件名 (简短注释) ==========” 开始，遇到下一个该标识结束。标识中务必写上配置文件名

-- ================ HeroModel.lua ( 获取人物模型配置表属性的接口 )============================
--- 根据人物模型Id获取人物的名字，如果没有找到该人物，则返回空
function ConfigFunc:getHeroName(heroModelId, params)
    require("Config.HeroModel")
    if not heroModelId then
        return "", 0
    end
    local tempModel = HeroModel.items[heroModelId]
    if (tempModel == nil) or (tempModel.name == nil) then
        return "", 0
    end

    local tempName = tempModel.name
    local tempParams = params or {}
    if (tempParams.playerName ~= nil) and (tempModel.specialType == Enums.HeroType.eMainHero) then
        tempName = tempParams.playerName
    -- elseif (tempParams.heroFashionId ~= nil) and HeroFashionRelation.items[tempParams.heroFashionId] then
    --     tempName = HeroFashionRelation.items[tempParams.heroFashionId].fashionName
    elseif (tempParams.IllusionModelId ~= nil) then
        local illusionModel = IllusionModel.items[tempParams.IllusionModelId]
        if (illusionModel ~= nil) and (illusionModel.name ~= nil) then
            tempName = illusionModel.name
        end
    end
    
    local tmpStep = tempParams.heroStep or 0
    if (tmpStep > 20) then
        return (TR("无极") .. "·" .. tempName), (tmpStep - 20)
    elseif (tmpStep > 15) then
        return (TR("武圣") .. "·" .. tempName), (tmpStep - 15)
    elseif (tmpStep > 10) then
        return (TR("武尊") .. "·" .. tempName), (tmpStep - 10)
    else
        return tempName, tmpStep
    end
end

--- 根据人物模型Id获取人物的大图片，如果没有找到该人物，则返回空
function ConfigFunc:getHeroLargePic(heroModelId, heroStep)
    require("Config.HeroModel")
    if not heroModelId then
        return ""
    end
    heroStep = heroStep or 0

    local tempModel = HeroModel.items[heroModelId]
    local figureName = tempModel and tempModel.largePic or ""
    
    return figureName
end

--- 根据人物模型Id获取人物的头像图片，如果没有找到该人物，则返回空
function ConfigFunc:getHeroSmallPic(heroModelId, heroStep)
    require("Config.FashionModel")
    if not heroModelId then
        return ""
    end
    heroStep = heroStep or 0

    local tempModel = HeroModel.items[heroModelId]
    local fashionModel = FashionModel.items[heroModelId]
    local tempName = tempModel and tempModel.smallPic or (fashionModel and fashionModel.smallPic or "")

    return (tempName == "") and tempName or (tempName .. ".png")
end

--- 修改主角人物的名字
function ConfigFunc:modifyMainHeroName(newName)
    require("Config.HeroModel")
    if not newName then
        newName = Player.mPlayerAttrObj:getPlayerAttrByName("PlayerName")
    end
    for _, item in pairs(HeroModel.items) do
        if item.specialType == Enums.HeroType.eMainHero then  -- 255 表示的是主角
            item.name = newName
        end
    end
end

-- 获取人物的声音文件
--[[
-- 参数
    heroModelId: 主将模型ID
    isSkillAudio: 是否技能音效，默认为 false
-- 返回值:
    返回声音文件路径
--]]
function ConfigFunc:getHeroAudioPath(heroModelId, isSkillAudio)
    local tempModel = HeroModel.items[heroModelId or 0]
    if not tempModel then
        return 
    end

    -- 如果是主角，需要判断是否穿戴时装
    if tempModel.specialType == Enums.HeroType.eMainHero then
        local modelId = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
        local fashionModel = FashionModel.items[modelId]
        if fashionModel then
            local skillSound, staySound = Utility.getHeroSound(fashionModel)
            if isSkillAudio == true then
                return skillSound .. ".mp3"
            else

                return Utility.randomStayAudio(staySound)
            end
        end
    end

    local skillSound, staySound = Utility.getHeroSound(fashionModel)
    if isSkillAudio == true then
        return skillSound .. ".mp3"
    else
        return Utility.randomStayAudio(staySound)
    end
end

-- 判断人物是否为神将
function ConfigFunc:heroIsShenjiang(heroModelId)
    if not heroModelId then
        return false
    end
    local tempModel = HeroModel.items[heroModelId]
    if not tempModel then
        return false
    end

    return tempModel.quality > 15
end

-- 判断人物是否为主角
function ConfigFunc:heroIsMain(heroModelId)
    local tempModel = HeroModel.items[heroModelId]
    if not tempModel then
        return false
    end

    return tempModel.specialType == Enums.HeroType.eMainHero
end

-- ================ HeroLvRelation.lua (获取人物等级关系表属性的接口) =========================
-- 等级属性= 基础属性 + 成长属性*(等级-1);  (注:人物初始为1级)
--- 根据人物 heroModelID 和 LV 获取 人物升级2级属性
--[[
-- 返回值：
    {
        HP = 0,  -- 血量
        AP = 0,   -- 攻击
        DEF = 0,  -- 防御
    }
 ]]
function ConfigFunc:getHeroLvAttr(heroModelId, heroLv, ingnoreBase)
    local ret = {HP = 0, AP = 0, DEF = 0,}
    local heroItem = HeroModel.items[heroModelId]
    if not heroItem then
        return ret
    end
    heroLv = heroLv or 1
    ret.HP = math.floor(heroItem.HPUp * (heroLv - 1))
    ret.AP = math.floor(heroItem.APUp * (heroLv - 1))
    ret.DEF = math.floor(heroItem.DEFUp * (heroLv - 1))
    if (ingnoreBase == nil) or (ingnoreBase == false) then
        ret.HP = ret.HP + heroItem.HPBase
        ret.AP = ret.AP + heroItem.APBase
        ret.DEF = ret.DEF + heroItem.DEFBase
    end
    return ret
end

--- 根据人物 heroModelID 和 LV 获取人物的经验总值 EXPTotal
function ConfigFunc:getHeroEXPTotal(heroModelId, heroLv)
    local heroItem = HeroModel.items[heroModelId]
    if not heroItem then
        return 0
    end
    heroLv = heroLv or 1
    local heroLvItem = HeroLvRelation.items[heroItem.valueLv * 1000 + heroLv]
    return heroLvItem and heroLvItem.EXPTotal or 0
end

--- 根据人物 heroModelID 获取最大等级
function ConfigFunc:getHeroMaxLv(heroModelId)
    return 100
end

-- =============== HeroStepRelation.lua (获取人物进阶关系表属性的接口) ========================
-- 进阶属性=b_hero_step_r.AttrUpR * 基础属性;
--- 根据人物 heroModelID 和 step 获取人物进阶属性
--[[
-- 返回值：
    {
        needLV = 0, -- 需要人物升级的等级
        stepUpUse = "", -- 进阶消耗
        FSP = 0, -- 先手值
        HP = 0,  -- 血量
        AP = 0,   -- 攻击
        DEF = 0,  -- 防御
    }
 ]]
function ConfigFunc:getHeroStepAttr(heroModelId, heroStep, illusionModelId)
    local heroItem = HeroModel.items[heroModelId]
    if not heroItem then
        return
    end
    heroStep = heroStep or 0
    local heroStepItem = HeroStepRelation.items[heroItem.stepUpClassID * 1000 + heroStep]
    if (heroStep >= 20) and (illusionModelId ~= nil) and (illusionModelId > 0) then
        heroStepItem = IllusionTalRelation.items[illusionModelId][heroStep]
    end
    if not heroStepItem then
        return
    end
    local ret = {}

    ret.needLV = heroStepItem.needLv
    ret.stepUpUse = heroStepItem.upUse
    ret.FSP = heroStepItem.FSP
    ret.HP = math.floor(heroStepItem.attrUpR * heroItem.HPBase)
    ret.AP = math.floor(heroStepItem.attrUpR * heroItem.APBase)
    ret.DEF = math.floor(heroStepItem.attrUpR * heroItem.DEFBase)

    -- 进阶消耗同名卡
    if heroStepItem.useNum and heroStepItem.useNum > 0 then
        local tempStr = string.format("1201,%d,%d", heroModelId, heroStepItem.useNum)
        if ret.stepUpUse and ret.stepUpUse ~= "" then
            ret.stepUpUse = ret.stepUpUse .. "||".. tempStr
        else
            ret.stepUpUse = tempStr
        end
    end

    -- 进阶消耗特殊道具
    if heroStepItem.useSpecialNum and heroStepItem.useSpecialNum > 0 then
        local tempModelId = tonumber(heroItem.specialGoodsID)
        local tempType = math.floor(tempModelId / 10000)
        local tempStr = string.format("%d,%d,%d", tempType, tempModelId, heroStepItem.useSpecialNum)
        if ret.stepUpUse and ret.stepUpUse ~= "" then
            ret.stepUpUse = ret.stepUpUse .. "||".. tempStr
        else
            ret.stepUpUse = tempStr
        end
    end

    return ret
end

-- ================ EquipModel.lua ( 获取装备模型配置表属性的接口 )============================

--- 根据装备套装Id获取套装成员列表
--[[
-- 参数
    groupId: 装备套装Id
-- 返回值：
    {
        [ResourcetypeSub] = {EquipModelId, ...}, -- ResourcetypeSub 取值为：eWeapon、eHelmet、eClothes、eNecklace, ePants, eShoe
        ...
    }
 ]]
function ConfigFunc:getEquipGroupList(groupId)
    if not groupId then
        return {}
    end
    if not self.mEquipGroup then
        self.mEquipGroup = {}
        require("Config.EquipModel")
        for modelId, item in pairs(EquipModel.items) do
            local tempGroupId = item.equipGroupID
            if tempGroupId > 0 then
                if not self.mEquipGroup[tempGroupId] then
                    self.mEquipGroup[tempGroupId] = {}
                end
                local typeID = item.typeID
                if not self.mEquipGroup[tempGroupId][typeID] then
                    self.mEquipGroup[tempGroupId][typeID] = {}
                end
                table.insert(self.mEquipGroup[tempGroupId][typeID], modelId)
            end
        end
    end
    local ret = clone(self.mEquipGroup[groupId] or {})
    return ret
end

--- 获取装备的基础属性显示
--[[
-- 参数
     equipModelId: 装备的模型Id
     equipLv：装备等级
-- 返回值：
    {
        {
            name: 名称
            value: 值的字符串形式
        },

        {
            name: 名称
            value: 值的字符串形式
        }
        ...
    }
 ]]
function ConfigFunc:getEquipBaseViewItem(equipModelId, equipLv)
    local tempModel = EquipModel.items[equipModelId]
    if not tempModel then
        return {}
    end
    equipLv = equipLv or 0
    local ret = {}

    -- 二级属性
    local tempAP = tempModel and (tempModel.AP + tempModel.APUP * equipLv) or 0
    if tempAP > 0 then
        table.insert(ret, {name = TR("攻击"), value = tonumber(tempAP)})
    end
    local tempDEF = tempModel and (tempModel.DEF + tempModel.DEFUP * equipLv) or 0
    if tempDEF > 0 then
        table.insert(ret, {name = TR("防御"), value = tonumber(tempDEF)})
    end
    local tempHP = tempModel and (tempModel.HP + tempModel.HPUP * equipLv) or 0
    if tempHP > 0 then
        table.insert(ret, {name = TR("血量"), value = tonumber(tempHP)})
    end

   -- 三级属性
    -- "命中", "闪避", "暴击", "抗暴", "格挡", "破击", "必杀", "守护"
    local attrNameList = {"HIT", "DOD", "CRI", "TEN", "BLO", "BOG", "CRID", "TEND" }
    for _, item in ipairs(attrNameList) do
        if tempModel[item] and tempModel[item] > 0 then
            local tempName = FightattrName[ConfigFunc:getFightAttrEnumByName(item)]
            table.insert(ret, {name = tempName, value = string.format("+%s%%", string.floatToStr(tempModel[item]))})
        end
    end

    return ret
end

--- 获取与主角搭配属性显示
--[[
-- 参数
     equipModelId: 装备的模型Id
     equipLv：装备等级
-- 返回值：
    {
        {
            name: 名称
            value: 值的字符串形式
        },

        {
            name: 名称
            value: 值的字符串形式
        }
        ...
    }
 ]]
function ConfigFunc:getEquipBaseHeroViewItem(equipModelId)
    local tempModel = EquipModel.items[equipModelId]
    if not tempModel then
        return {}
    end
    local ret = {}

    local tempList = {}
    if tempModel.APRHero > 0 then
        table.insert(ret, {name = TR("攻击"), value = string.format("+%s%%", string.floatToStr(tempModel.APRHero / 100))})
    end
    if tempModel.DEFRHero > 0 then
        table.insert(ret, {name = TR("防御"), value = string.format("+%s%%", string.floatToStr(tempModel.DEFRHero / 100))})
    end
    if tempModel.HPRHero > 0 then
        table.insert(ret, {name = TR("血量"), value = string.format("+%s%%", string.floatToStr(tempModel.HPRHero / 100))})
    end
    return ret
end

--- 获取装备的进阶属性显示
--[[
-- 参数
     equipModelId: 装备的模型Id
     equipStep: 装备进阶等级
-- 返回值：
    {
        {
            name: 名称
            value: 值的字符串形式
        },

        {
            name: 名称
            value: 值的字符串形式
        }
        ...
    }
 ]]
function ConfigFunc:getEquipStepViewItem(equipModelId, equipStep)
    equipStep = equipStep or 0
    local tempModel = EquipModel.items[equipModelId]
    local tempStep = EquipStepRelation.items[equipModelId] and EquipStepRelation.items[equipModelId][equipStep]
    if not tempStep then
        return {}
    end

    --local ret = {}
    local tempCount = tempModel.itemLv + tempStep.itemLv
    local ret = {{name = TR("品级"), value = tostring(tempCount)}}

    if (tempStep.AP and tempStep.AP > 0) then-- 攻击
        table.insert(ret, {name = TR("攻击"), value = string.format("%d", tempStep.AP)})
    end
    if (tempStep.DEF and tempStep.DEF > 0) then -- 防御
        table.insert(ret, {name = TR("防御"), value = string.format("%d", tempStep.DEF)})
    end
    if (tempStep.HP and tempStep.HP > 0) then  -- 血量
        table.insert(ret, {name = TR("血量"), value = string.format("%d", tempStep.HP)})
    end
    if (tempStep.APR and tempStep.APR > 0) then  -- 攻击
        table.insert(ret, {name = TR("攻击"), value = string.format("+%s%%", string.floatToStr(tempStep.APR / 100))})
    end
    if (tempStep.DEFR and tempStep.DEFR > 0) then-- 防御
        table.insert(ret, {name = TR("防御"), value = string.format("+%s%%", string.floatToStr(tempStep.DEFR / 100))})
    end
    if (tempStep.HPR and tempStep.HPR > 0) then -- 血量
        table.insert(ret, {name = TR("血量"), value = string.format("+%s%%", string.floatToStr(tempStep.HPR / 100))})
    end

    return ret
 end

-- ================ EquipGroupActiveRelation.lua(获取装备套装配置表属性的接口) ======================
--- 获取装备套装描述
--[[
-- 参数
    equipGroupID: 套装Id
    attrEndStr: 属性表述需要添加的后缀，默认为空
    haveGroupCount: 同一卡槽上的数量
-- 返回值
    {
        {
            needNum: 激活需要数量
            introList = {  -- 属性描述列表
                "血量＋1000",
                "攻击＋1000",
                ...
            }
        },
        ...
    }
 ]]
function ConfigFunc:getEquipGroupIntro(equipGroupID, attrEndStr, haveGroupCount)
    require("Config.EquipGroupActiveRelation")
    local tempGrpAct = EquipGroupActiveRelation.items[equipGroupID or 0]
    if not tempGrpAct then
        return {}
    end
    local attrNameList = {
        "AP", -- "攻击值",
        "DEF", -- "防御值",
        "HP", -- "生命值",
        "APR", -- = "生命加成%",
        "HPR", -- = "攻击加成%",
        "DEFR", -- = "防御加成%",
        "RP", -- = "怒气",
        "FSP", -- = "速度",
        "DAMADD", -- = "伤害",
        "DAMCUT", -- = "免伤",
        "HIT", -- = "命中",
        "DOD", -- = "闪避",
        "CRI", -- = "暴击",
        "TEN", -- = "抗暴",
        "BLO", -- = "格挡",
        "BOG", -- = "破击",
        "CRID", -- = "必杀",
        "TEND", -- = "守护"
    }
    local ret = {}
    for index = 1, 6 do
        local tempActItem = tempGrpAct[index]
        if tempActItem then
            local retItem = {}
            local isActive = haveGroupCount and haveGroupCount >= index
            retItem.needNum = index
            retItem.introList = {}
            table.insert(ret, retItem)
            for _, key in ipairs(attrNameList) do
                local item = tempActItem[key]
                local fightAttrEnum = ConfigFunc:getFightAttrEnumByName(key)
                if fightAttrEnum > 0 and type(item) == "number" and item ~= 0 then
                    local fightName = isActive and string.format("{083978}%s{1C7A00}", FightattrName[fightAttrEnum]) or FightattrName[fightAttrEnum]
                    if ConfigFunc:fightAttrIsPercentByName(key) then
                        local tempStr = string.format("%s:%+d%%%s", fightName, item / 100, attrEndStr or "")
                        table.insert(retItem.introList, tempStr)
                    elseif ConfigFunc:fightAttrIsThirdAttr(key) then
                        local tempStr = string.format("%s:%+d", fightName, item)
                        table.insert(retItem.introList, tempStr)
                    else
                        local tempStr = string.format("%s:%+d%s", fightName, item, attrEndStr or "")
                        table.insert(retItem.introList, tempStr)
                    end
                end
            end
        end
    end

    return ret
end

-- ================ TreasureModel.lua ( 获取神兵模型配置表属性的接口 ) ============================

--- 获取神兵的基础属性
function ConfigFunc:getTreasureBaseAttr(treasureModelID, treasureLv)
    local tempModel = TreasureModel.items[treasureModelID]
    if not tempModel then
        return {}
    end
    treasureLv = treasureLv or 0
    local ret = {
        AP = tempModel.APBase * (treasureLv * tempModel.upR  + 1),
        HP = tempModel.HPBase * (treasureLv * tempModel.upR  + 1),
    }
    return ret
end

--- 获取神兵的额外属性
function ConfigFunc:getTreasureExtraAttr(treasureModelID)
    local tempModel = TreasureModel.items[treasureModelID]
    if not tempModel then
        return {}
    end
    local ret = {}
    local extraAttrStr = string.splitBySep(tempModel.extraAttrStr, ",")
    for _, item in pairs(extraAttrStr) do
        local tempList = string.splitBySep(item, "|")
        if #tempList == 2 then
            local name = ConfigFunc:getFightNameByEnum(tonumber(tempList[1]))
            ret[name] = tonumber(tempList[2])
        end
    end
    return ret
end

--- 获取神兵的基础属性显示
--[[
-- 参数
     treasureModelID: 神兵的模型Id
     treasureLv：神兵当前的等级
-- 返回值：
    {
        {
            name: 名称
            value: 值的字符串形式
        },

        {
            name: 名称
            value: 值的字符串形式
        }
        ...
    }
 ]]
function ConfigFunc:getTreasureBaseViewItem(treasureModelID, treasureLv)
    local baseAttr = ConfigFunc:getTreasureBaseAttr(treasureModelID, treasureLv)
    local extraAttr = ConfigFunc:getTreasureExtraAttr(treasureModelID)

    local ret = {}
    local attrNameList = {"AP", "DEF", "HP", "HIT", "DOD", "CRI", "TEN", "BLO", "BOG", "CRID", "TEND" }
    for index = 1, #attrNameList do
        local tempName = attrNameList[index]
        local tempValue = extraAttr[tempName] or 0
        -- 累加神兵升级的属性，目前只有 {"AP", "HP" }
        if baseAttr[tempName] then
            tempValue = tempValue + baseAttr[tempName]
        end
        if tempValue > 0 then
            local tempItem = {}
            tempItem.name = FightattrName[ConfigFunc:getFightAttrEnumByName(tempName)]
            tempItem.value = Utility.getAttrViewStr(tempName, tempValue, false)
            table.insert(ret, tempItem)
        end
    end

    return ret
end

-- ================ TreasureLvRelation.lua (神兵等级关系表相关接口) =======================================
-- 根据神兵 treasureModelID 和 LV 获取相关属性
--[[
-- 返回值
    {
        AP = 0,         -- 攻击
        HP = 0,         -- 血量
        EXPTotal = 0,   -- 经验总值
    }
 ]]
function ConfigFunc:getTreasureLvItem(treasureModelID, lv)
    local ret = {AP = 0, HP = 0,  EXPTotal = 0}
    local treasureItem = TreasureModel.items[treasureModelID]
    if not treasureItem then
        return ret
    end

    local extraAttr = ConfigFunc:getTreasureExtraAttr(treasureModelID)
    local tempValueAP = extraAttr["AP"] or 0
    local tempValueHP = extraAttr["HP"] or 0
    
    lv = lv or 0
    local tempLvItem = TreasureLvRelation.items[lv]
    local baseExp = tempLvItem and tempLvItem.baseExpTotal or 0
    ret.AP = treasureItem.APBase * (lv * treasureItem.upR + 1) + tempValueAP
    ret.HP = treasureItem.HPBase * (lv * treasureItem.upR + 1) + tempValueHP
    ret.EXPTotal = treasureItem.expR * baseExp

    return ret
end

-- 解析神兵总经验对应的等级和该等级的经验进度值
--[[
-- 参数 
    treasureModelID: 神兵模型Id
    EXPTotal: 总经验
    beginLv: 开启计算的等级，默认为 0
-- 返回值
    {
        Lv: 总经验对应的等级
        nextExp: 升到下一级的经验值
        nextMaxExp: 升到下一级需要的经验最大值
    }
]]
function ConfigFunc.getTreasureExpProg(treasureModelID, EXPTotal, beginLv)
    local ret = {Lv = beginLv or 0, nextExp = 0, nextMaxExp = 0}
    local modelItem = TreasureModel.items[treasureModelID]
    if not modelItem or modelItem.maxLV == 0 then
        return ret
    end

    while true do
        local currItem = TreasureLvRelation.items[ret.Lv]
        local nextItem = TreasureLvRelation.items[ret.Lv + 1]
        local currTotal = modelItem.expR * (currItem and currItem.baseExpTotal or 0)
        local nextTotal = modelItem.expR * (nextItem and nextItem.baseExpTotal or 0)
        
        if EXPTotal < nextTotal then
            ret.nextExp = EXPTotal - currTotal
            ret.nextMaxExp = nextTotal - currTotal
            break
        end
        if (nextItem == nil) then
            break
        end
        ret.Lv = ret.Lv + 1
    end

    return ret
end

-- ================ TreasureLvActiveRelation.lua (神兵解锁属性配置表相关借口) ==============================
--- 获取距离神兵当前等级最靠近的解锁属性（一条以解锁的，一条未解锁的）
--[[
-- 参数
     treasureModelID: 神兵的模型Id
     treasureLv：神兵当前的等级
-- 返回值
     {
        item1, -- 数据为 TreasureLvActiveRelation.items 中单个条目的内容
        ...
     }
 ]]
function ConfigFunc:getTreasureLvActiveItem(treasureModelID, treasureLv)   
    local modelItem = TreasureModel.items[treasureModelID]
    if not modelItem or modelItem.activeAttrEnumIDs == nil or modelItem.activeAttrEnumIDs == "" then
        return {}
    end
    treasureLv = treasureLv or 0

    -- 读取可解锁的属性列表
    local activeAttrEnumNames = {}
    for _,v in ipairs(string.split(modelItem.activeAttrEnumIDs, ",")) do
        table.insert(activeAttrEnumNames, ConfigFunc:getFightNameByEnum(tonumber(v)))
    end

    local tempInt = modelItem.typeID * 1000000 + modelItem.valueLv * 1000
    -- 获取解锁的条目
    local function getUnLockItem()
        for lv = treasureLv, 0, -1 do
            local tempItem = TreasureLvActiveRelation.items[tempInt + lv]
            if tempItem then
                return tempItem
            end
        end
    end
    -- 获取未解锁的条目
    local function getLockItem()
        for lv = treasureLv + 1, 100 do
            local tempItem = TreasureLvActiveRelation.items[tempInt + lv]
            if tempItem then
                return tempItem
            end
        end
    end
    -- 根据 TreasureLvActiveRelation item 获取相应属性
    local function getActiveAttrItem(activeItem)
        local tempRet = {}
        tempRet.treasureModelID = activeItem.ID
        tempRet.needLV = activeItem.Lv
        for _,v in ipairs(activeAttrEnumNames) do
            tempRet[v] = activeItem.totalAttrUpVal
        end
        
        return tempRet
    end

    local unlockItem = getUnLockItem()
    local lockItem = getLockItem()

    local ret = {}
    if unlockItem then
        table.insert(ret, getActiveAttrItem(unlockItem))
    end
    if lockItem then
        table.insert(ret, getActiveAttrItem(lockItem))
    end
    return ret
end

--- 获取神兵解锁属性的显示形式
--[[
-- 参数
     treasureLvActiveItem: TreasureLvActiveRelation.items 中单个条目的内容
-- 返回值：
    {
        {
            name: 名称
            value: 值的字符串形式
        },

        {
            name: 名称
            value: 值的字符串形式
        }
        ...
    }
 ]]
function ConfigFunc:getTreasureLvActiveViewItem(treasureLvActiveItem)
    if not treasureLvActiveItem or type(treasureLvActiveItem) ~= 'table' then
        return {}
    end
    local ret = {}
    for key, value in pairs(treasureLvActiveItem) do
        if type(value) == "number" and value > 0 then
            local tempValue = Utility.getAttrViewStr(key, value)
            if tempValue and tempValue ~= "" then
                local tempItem = {}
                tempItem.name = FightattrName[ConfigFunc:getFightAttrEnumByName(key)]
                tempItem.value = tempValue
                table.insert(ret, tempItem)
            end
        end
    end
    return ret
end

-- ================ TreasureStepRelation.lua (神兵进阶属性配置表相关借口) ==================================

-- 根据神兵 treasureModelID 和 step 获取相关属性
--[[
--  返回值
    {
        needLV = 0,
        HP = 0,
        AP = 0,
        DAMADDR = 0,
        DAMCUTR = 0,
        stepUpUse = "1112,0,50000||1605,16050020,1",
        stepUpUseSub = "1112,0,50000||1402,14021109,1"
    }
 ]]
function ConfigFunc:getTreasureStepItem(treasureModelID, step)
    local modelItem = TreasureModel.items[treasureModelID]
    if not modelItem then
        return
    end

    -- 
    step = step or 0
    local ret = {needLV = 100, HP = 0, AP = 0, DAMADDR = 0, DAMCUTR = 0, stepUpUse = {}, stepUpUseSub = {}}

    -- 解析进阶属性
    local tempId = modelItem.typeID * 100000 + modelItem.valueLv * 1000 + step
    local stepAttrItem = TreasureStepAttrRelation.items[tempId]
    local stepUpAttrStr = string.splitBySep(stepAttrItem and stepAttrItem.totalAttrStr or "", ",")
    for _, item in pairs(stepUpAttrStr) do
        local tempList = string.splitBySep(item, "|")
        if #tempList == 2 then
            local name = ConfigFunc:getFightNameByEnum(tonumber(tempList[1]))
            ret[name] = tonumber(tempList[2])
        end
    end

    -- 解析进阶消耗和需要的强化等级
    local tempId = modelItem.valueLv * 1000 + step  -- ID = "#ID=(价等*1000+阶数)",
    local stepItem = TreasureStepRelation.items[tempId]
    if stepItem then
        ret.needLV = stepItem.needLv
        local alwaysUse = Utility.analysisStrResList(stepItem.upUseExtraStr)

        ret.stepUpUse = clone(alwaysUse)
        ret.stepUpUseSub = clone(alwaysUse)
        -- 进阶消耗(精华石)
        local tempList = Utility.analysisStrResList(stepItem.upUseBaseSubStr)
        for _, item in pairs(tempList) do
            table.insert(ret.stepUpUse, item)
        end
        -- 进阶消耗替代品(同名卡）
        table.insert(ret.stepUpUseSub, {resourcetypeSub = modelItem.typeID, modelId = modelItem.ID, num = stepItem.upUseBaseCardNum})
        return ret
    end
end

-- ================ PrModel.lua ( 获取羁绊模型配置表属性的接口 )============================

--- 根据羁绊模型Item获取羁绊的成员
--[[
-- 参数
    prModelItem: 羁绊模型表 PrModel 中的条目
-- 返回值：
    { -- 达成羁绊需要该表的每项中至少有一个元素都存在
        { --
            modelId: 模型Id
            ...
        },

        ....
    }
 ]]
function ConfigFunc:getPrMember(prModelItem)
    if not prModelItem or not prModelItem.member then
        return {}
    end

    local ret = {}
    local tempList = string.splitBySep(prModelItem.member, ",")
    for _, item in pairs(tempList) do
        local tempItem = {}
        local memberList = string.splitBySep(item, "|")
        for _, memberId in pairs(memberList) do
            table.insert(tempItem, tonumber(memberId))
        end
        if #tempItem > 0 then
            table.insert(ret, tempItem)
        end
    end
    return ret
end

-- ================ HeroPrRelation.lua ( 获取人物羁绊模型配置表属性的接口 )============================
--- 根据人物模型Id获取人物的羁绊信息
--[[
-- 参数：
    heroModelId：主将模型Id
-- 返回值列表中每个条目为：
    {
        ID = "#ID",
        name = "名称",
        intro = "简介",
        member = "羁绊成员",
        typeID = "成员资源类型ID",
        APR = "攻击加成%",
        HPR = "生命加成%",
        DEFR = "防御加成%"
    }
]]
function ConfigFunc:getHeroPrInfos(heroModelId)
    require("Config.PrModel")
    require("Config.HeroPrRelation")

    local ret = {}
    if (HeroPrRelation.items[heroModelId]) then
        for index, item in pairs(HeroPrRelation.items[heroModelId]) do
            if PrModel.items[item.PRModelId] then
                table.insert(ret, clone(PrModel.items[item.PRModelId]))
            end
        end
    end
    table.sort(ret, function(item1, item2)
        return item1.ID < item2.ID
    end)
    return ret
end

-- ================ GoodsModel.lua ( 获取物品模型配置表属性的接口 )============================
--- 根据物品模型Id获取物品的名字，如果没有找到该物品，则返回空
function ConfigFunc:getGoodsName(GoodsModelId)
    require("Config.GoodsModel")
    if not GoodsModelId then
        return ""
    end
    local tempItem = GoodsModel.items[GoodsModelId]
    if not tempItem then
        return ""
    end
    return tempItem.name
end

-- ================ EnumsConfig.lua ( 配置目录枚举文件相关的接口 )============================
--- 根据FightAttr的英文名称获取其枚举值, 如: "HP" --> 201
function ConfigFunc:getFightAttrEnumByName(fightAttrName)
    if not fightAttrName then
        return 0
    end

    local tempStr = "e"..fightAttrName
    if Fightattr[tempStr] then
        return Fightattr[tempStr]
    end
    return 0
end

--- 根据FightAttr枚举值获取属性英文名 如： 201 －－> "HP"
function ConfigFunc:getFightNameByEnum(fightAttr)
    for key, value in pairs(Fightattr) do
        if value == fightAttr then
            local strLen = string.len(key)
            return string.sub(key, 2, strLen)
        end
    end
end

-- 根据 Fightattr 英文名 获取 Fightattr 中文名 如： "HP" --> "血量"
function ConfigFunc:getViewNameByFightName(fightAttrName)
    local tempEnum = self:getFightAttrEnumByName(fightAttrName)

    if not tempEnum or tempEnum == 0 then
        local tempList = {
            PetFSP = TR("先手"),
            FSP = TR("先手"),
        }
        return tempList[fightAttrName] or ""
    else
        return FightattrName[tempEnum] or ""
    end
end

--- 根据FightAttr的英文名称判断FightAttr是不是百分比
function ConfigFunc:fightAttrIsPercentByName(fightAttrName)
    if type(fightAttrName) ~= "string" then
        return false
    end
    -- 单独处理这个特殊的属性
    if (fightAttrName == "eSTR") then
        return false
    end
    return string.sub(fightAttrName, -1) == "R"
end

--- 根据FightAttr的名字值判断FightAttr是不是百分比
function ConfigFunc:fightAttrIsPercentByValue(fightAttrValue)
    if (fightAttrValue == nil) or (type(fightAttrValue) ~= "number") then
        return false
    end
    local tmpList = {
        Fightattr.eAPR, Fightattr.eHPR, Fightattr.eDEFR, 
        Fightattr.eCPR, Fightattr.eBCPR, 
        Fightattr.eDAMADDR, Fightattr.eDAMCUTR, 
        Fightattr.eRADAMADDR, Fightattr.eRADAMCUTR,
        Fightattr.eRBDAMADDR, Fightattr.eRBDAMCUTR, 
        Fightattr.eRCDAMADDR, Fightattr.eRCDAMCUTR, 
        Fightattr.eRDDAMADDR, Fightattr.eRDDAMCUTR,
        Fightattr.ePVPDAMADDR, Fightattr.ePVPDAMCUTR, 
        Fightattr.eAPHeroR, Fightattr.eHPHeroR, Fightattr.eDEFHeroR, Fightattr.eAPToHPHeroR,
        Fightattr.ePetGrowR
    }
    for _,v in ipairs(tmpList) do
        if (v == fightAttrValue) then
            return true
        end
    end
    return false
end

--- 根据FightAttr是否是三级属性
function ConfigFunc:fightAttrIsThirdAttr(fightAttrName)
    if fightAttrName == "HIT"
            or fightAttrName == "DOD"
            or fightAttrName == "CRI"
            or fightAttrName == "TEN"
            or fightAttrName == "BLO"
            or fightAttrName == "BOG"
            or fightAttrName == "CRID"
            or fightAttrName == "TEND" then
        return true
    end
    return false
end

-- ================== FunctionOpenModel.lua (升级开启模块列表配置文件相关接口) ==================
-- 根据人物等级获取开启的模块列表
--[[
-- 参数：
    playerLv: 玩家等级
-- 返回值：
    返回值为一个列表，其中每个条目为配置文件 FunctionOpenModel 中的一个条目 或 {}
    {
        ID = 1,
        type = 1,
        openLv = 5,
        moduleName = "月签到",
        intro = "每月签到，就可领取丰厚奖励，更有厉害人物等你哦",
        modulePic = "tb_121",
        moduleID = ""
    }
--]]
function ConfigFunc:getOpenModuleInfo(playerLv)
    local ret = {}

    local tempList = {
        { -- type == 1 的类型
            configItemList = clone(FunctionOpenModel.items[1] or {}), -- 该类型的配置数据列表
            needCount = 2, -- 该类型需要的条目数
        },
        -- { -- type == 2 的类型
        --     configItemList = clone(FunctionOpenModel.items[2] or {}),
        --     needCount = 1, 
        -- },
        { -- type == 3 的类型
            configItemList = clone(FunctionOpenModel.items[3] or {}),
            needCount = 1, 
        },
    }

    if playerLv >= 25 then  -- type == 2 的类型
        table.insert(tempList, 2, {
            configItemList = clone(FunctionOpenModel.items[2] or {}),
            needCount = 1, 
        })
    end
    
    for idx, item in ipairs(tempList) do
        -- 排序
        table.sort(item.configItemList, function(data1, data2)
            return data1.openLv < data2.openLv
        end)

        -- 需要获取数据的起始index, 默认一个很大的数
        local startIndex = 1000000 
        for index, configItem in ipairs(item.configItemList) do
            if configItem.openLv >= playerLv then
                startIndex = index
                break
            end
        end

        -- 
        for index = startIndex, startIndex + (item.needCount - 1) do 
            table.insert(ret, item.configItemList[index] or {})
        end
    end

    return ret
end

-- ================== ModuleSubModel.lua (升级开启模块列表配置文件相关接口) ==================
-- 根据可否进入培养共鸣页面
--[[
-- 参数：
    无
-- 返回值：
    返回值为bool类型，为true表明可以进入培养共鸣，为false表示任何共鸣均未开放
--]]
function ConfigFunc:canEnterEquipMaster()
    -- 按照需求等级的大小排序
    local moduleIdList = {ModuleSub.eEquipStarUpMaster, ModuleSub.eEquipStepUpMaster}
    table.sort(moduleIdList, function (a, b)
            local aModel = ModuleSubModel.items[a]
            local bModel = ModuleSubModel.items[b]
            return aModel.openLv < bModel.openLv
        end)

    -- 只要有任意一个模块开放，就可进入
    local isCan = false
    for _,v in ipairs(moduleIdList) do
        if (ModuleInfoObj:modulePlayerIsOpen(v, false) == true) then
            isCan = true
            break
        end
    end

    -- 如果不能进入，则提示最小的等级需求
    if (isCan == false) then
        ModuleInfoObj:modulePlayerIsOpen(moduleIdList[1], true)
    end

    return isCan
end

-- ================== EquipGroupModel.lua (装备套装列表配置文件相关接口) ==================
-- 根据装备模型Id和实例Id获取套装中的其他模型Id，
--[[
    参数：
        equipModelId： 装备模型Id
        equipId: 装备实例Id，如果为nil则不判断该装备是否已上阵
        slotEquipModels: 如果该装备已上阵，该参数为该卡槽上的所有装备模型Id，如果为nil，则获取玩家自己阵容该卡槽的装备模型Id列表
    返回值：模型Id列表
    {
        modelId ,  -- modelId 为模型id
        ...
    }
--]]
function ConfigFunc:getGroupModelIds(equipModelId, equipId, slotEquipModels)
    if not equipModelId then
        print("ConfigFunc:getGroupModelIds param equipModelId is nil, so return empty")
        return {}
    end

    require("Config.EquipModel")
    local tempModelItem = EquipModel.items[equipModelId]
    if not tempModelItem or not tempModelItem.equipGroupID or tempModelItem.equipGroupID < 1  then
        print("ConfigFunc:getGroupModelIds invalid equipModelId or this equip groupId < 1, so return empty ")
        return {}
    end
    local groupModelList = ConfigFunc:getEquipGroupList(tempModelItem.equipGroupID)
    if not groupModelList then
        print("ConfigFunc:getGroupModelIds , not found EquipGroupModel item, so return empty")
        return {}
    end

    local typeIdList = {ResourcetypeSub.eWeapon, ResourcetypeSub.eHelmet, ResourcetypeSub.eClothes, ResourcetypeSub.eNecklace, ResourcetypeSub.ePants, ResourcetypeSub.eShoe}
    local ret = {}
    for index = 1, #typeIdList do
        local tempModels = groupModelList[typeIdList[index]]
        if typeIdList[index] == tempModelItem.typeID then  -- 与传入模型Id 的装备相同时，使用传入的模型Id
            table.insert(ret, equipModelId)
        elseif tempModels and #tempModels > 0 then
            if #tempModels == 1 then   -- 如果套装列表中某类型装备只有一个ModelId可供选择，则直接使用这个即可
                table.insert(ret, tempModels[1])
            elseif #tempModels > 1 then -- 如果套装列表中某类型装备有多个，则需要找出最合适的一个。
                if Utility.isEntityId(equipId) then -- 如果传入的装备实例id是无效值，则取该类型装备备选列表中的第一个
                    require("Data.Player")
                    local information, slotId = slotEquipModels ~= nil, nil
                    if not information then
                        information, slotId = Player:equipInFormation(equipId)
                        slotEquipModels = Player:getFormationEquipModel(slotId)
                    end
                    if information then
                        local found = false
                        for _, groupModelId in pairs(tempModels) do
                            if slotEquipModels[groupModelId] then
                                found = true
                                table.insert(ret, groupModelId)  --
                                break
                            end
                        end
                        if not found then  -- 如果该卡槽上上阵的装备不是套装中的任何一个，则使用套装列表中该类型列表的第一个
                            table.insert(ret, tempModels[1])
                        end
                    else  -- 未上阵也使用套装列表中该类型列表的第一个
                        table.insert(ret, tempModels[1])
                    end
                else
                    for _, w in ipairs(tempModels) do
                        local item = EquipModel.items[w]
                        if item.valueLv == tempModelItem.valueLv then
                            table.insert(ret, w)
                            break
                        end
                    end
                    --table.insert(ret, tempModels[1])
                end
            end
        end
    end
    return ret
end

-- 返回道具基本模型
function ConfigFunc:getItemBaseModel(modelID)
    local itemBase = nil
    if (modelID == nil) then
        return nil
    end

    local itemId = tonumber(modelID)
    local aType = math.floor(itemId / 10000)
    local bType = math.floor(aType / 100)
    if (bType == Resourcetype.eHero) then
        -- 队员
        itemBase = HeroModel.items[itemId]
    elseif (bType == Resourcetype.eEquipment) then
        -- 装备
        itemBase = EquipModel.items[itemId]
    elseif (bType == Resourcetype.eTreasure)then
        -- 神兵
        itemBase = TreasureModel.items[itemId]
    elseif (bType == Resourcetype.eDebris)then
        -- 碎片
        if (aType == ResourcetypeSub.eHeroDebris) then              -- 人物碎片
            itemBase = GoodsModel.items[itemId]
        elseif (aType == ResourcetypeSub.eEquipmentDebris) then     -- 装备碎片
            itemBase = GoodsModel.items[itemId]
        elseif ((aType == ResourcetypeSub.eBookDebris) or (aType == ResourcetypeSub.eHorseDebris)) then          -- 卡牌碎片或徽章碎片
            itemBase = TreasureDebrisModel.items[itemId]
        elseif (aType == ResourcetypeSub.eNewZhenJueDebris) then
            itemBase = GoodsModel.items[itemId]
        else
            itemBase = GoodsModel.items[itemId]
        end
    elseif (bType == Resourcetype.eProps)then
        -- 道具
        itemBase = GoodsModel.items[itemId]
    elseif (bType == Resourcetype.eNewZhenJue) then
        -- 内功心法
        itemBase = ZhenjueModel.items[itemId]
    elseif (bType == Resourcetype.eFashion) then
        -- 时装
        itemBase = FashionModel.items[itemId]
    elseif bType == Resourcetype.ePet then  -- 外功秘籍
        itemBase = PetModel.items[itemId]
    elseif bType == Resourcetype.eZhenYuan then
        itemBase = ZhenyuanModel.items[itemId]
    elseif bType == Resourcetype.eImprint then  -- 宝石
        itemBase = ImprintModel.items[itemId]
    end
    return clone(itemBase)
end

-- =================== PetTalTreeModel.lua (宠物天赋数节点模型表) ============
-- 整理宠物天赋树节点信息, 整理后的数据结构为
--[[
    {
        [valueLv] = {  -- valueLv 是 PetTalTreeModel 配置表中的“价等”字段
            [layer] = {  -- layer是 PetTalTreeModel 配置表中的“层数”字段
                {
                    ID = 3011,
                    valueLv = 3,
                    name = "伤害",
                    layer = 1,
                    node = 1,
                    ifActive = false,
                    totalNum = 1,
                    perAttrStr = "201|1000",
                    perExtraAtkDamage = 0,
                    perExtraAtkFactorR = 0,
                    perExp = "10|11|12|13|14",
                    perUseStr = "1605,16050001,100",
                    intro = "xxx",
                    pic = ""
                },
                ....

            }
        }
    }
]]
function ConfigFunc:dealPetTalTreeModel()
    if self.mPetTalTree then
        return
    end
    self.mPetTalTree = {}
    for _, item in pairs(PetTalTreeModel.items) do
        self.mPetTalTree[item.valueLv] = self.mPetTalTree[item.valueLv] or {}
        self.mPetTalTree[item.valueLv][item.layer] = self.mPetTalTree[item.valueLv][item.layer] or {}
        table.insert(self.mPetTalTree[item.valueLv][item.layer], item)
    end

    -- 对宠物天赋树中每层数据进行排序
    for _, valueLvItems in pairs(self.mPetTalTree) do
        for _, layerItems in pairs(valueLvItems) do
            table.sort(layerItems, function(item1, item2)
                return item1.node < item2.node
            end)
        end
    end
end

-- 获取 宠物天赋数节点模型表 中某价等 或某价等的某一层的配置节点数据
--[[
-- 参数
    valueLv: 需要获取节点的价等
    layer: 需要获取节点的层树，如果该字段为nil，表示获取该价等的所有层的数据
-- 返回值
    layer 为nil时返回:
        {
            [layer] = {
                节点数据1,
                节点数据2,
                ...
            }
        }
    layer 不为nil时返回:
        {
            节点数据1,
            节点数据2,
            ...
        }
]]
function ConfigFunc:getPetTalTreeNode(valueLv, layer)
    -- 整理宠物天赋树节点信息
    self:dealPetTalTreeModel()

    local tempList = self.mPetTalTree[valueLv or 0] or {}
    if layer then
        return tempList[layer] or {}
    else
        return tempList
    end
end

-- =================== BattleNodeDropRelation.lua (战斗节点掉落关系表相关接口) ===============
-- 整理节点掉落物品信息
function ConfigFunc:dealBattleNodeDropInfo()
    if self.mBattleNodeDrop then -- 已经整理过了
        return
    end
    self.mBattleNodeDrop = {nodeList = {}, outList = {}, resTypeList = {}}

    for _, item in pairs(BattleNodeDropRelation.items) do
        local nodeList = self.mBattleNodeDrop.nodeList
        local outList = self.mBattleNodeDrop.outList
        local resTypeList = self.mBattleNodeDrop.resTypeList

        nodeList[item.nodeModelID] = nodeList[item.nodeModelID] or {}
        outList[item.modelID] = outList[item.modelID] or {}
        resTypeList[item.typeID] = resTypeList[item.typeID] or {}

        table.insert(nodeList[item.nodeModelID], item)
        table.insert(outList[item.modelID], item)
        table.insert(resTypeList[item.typeID], item)
    end
end

-- 获取某个战斗节点的物品掉落
--[[
-- 参数
    battleNodeId: 副本节点模型Id
-- 返回值
    {
        {
            resourceTypeSub = nil,  -- 物品资源类型
            modelId = nil, -- 物品资源模型Id
            num = 0, -- 物品数量
        }
        ...
    }
]]
function ConfigFunc:getBattleNodeDrop(battleNodeId)
    self:dealBattleNodeDropInfo()
    
    local ret = {}
    for _, item in pairs(self.mBattleNodeDrop.nodeList[battleNodeId] or {}) do
        table.insert(ret, {
            resourceTypeSub = item.typeID,  -- 物品资源类型
            modelId = item.modelID, -- 物品资源模型Id
            num = item.num, -- 物品数量
        })
    end

    return ret
end

-- 根据物品模型Id物品掉落的节点
--[[
-- 参数
    modelId: 物品模块Id
-- 返回值
    {
        BattleNodeDropRelation 配置表中的条目
        ...
    }
]]
function ConfigFunc:getDropNodeByModelId(modelId)
    self:dealBattleNodeDropInfo()

    return self.mBattleNodeDrop.outList[modelId] or {}
end

-- 根据资源类型获取获取物品掉落的节点
--[[
-- 参数
    resourcetypeSubList: 资源类型列表，格式如下
    {
        ResourcetypeSub.eWeapon,
        ....
    }
-- 返回值
    {
        BattleNodeDropRelation 配置表中的条目
        ...
    }
]]
function ConfigFunc:getDropNodeByType(resourcetypeSubList)
    self:dealBattleNodeDropInfo()
    local ret = {}

    local typeList = (type(resourcetypeSubList) == "table") and resourcetypeSubList or {resourcetypeSubList}
    for _, resType in pairs(typeList) do
        for _, item in pairs(self.mBattleNodeDrop.resTypeList[resType] or {}) do
            table.insert(ret, item)
        end
    end

    return ret
end

-- ==================== BattleChapterModel.lua (战斗篇章节点关系相关接口) =============================

-- 根据章节Id获取该章节下配置的节点信息
function ConfigFunc:getChapterNodeInfo(chapterId)
    local ret = {}
    for item, nodeInfo in pairs(BattleNodeModel.items) do
        if nodeInfo.chapterModelID == chapterId then
            table.insert(ret, nodeInfo)
        end
    end

    -- 排序
    table.sort(ret, function(item1, item2)
        return item1.ID < item2.ID
    end)

    return ret
end

-- 根据节点ID返回该节点所在的章、节信息
--[[
-- 参数(只传章节ID返回xx篇xx章；只传节点ID返回xx章xx节。传一个参数即可)
    params:
        chapterId: 章节ID
        nodeId: 节点ID
-- 返回值
    tempStr: 返回所在位置字符串（xx章xx节）
    chapterNum: 所在章节
    nodeNum: 所在节点
]]
function ConfigFunc:getFormatNodeInfo(params)
    local tempStr = ""
    -- 节点所在的章节ID
    local chapterId = params.chapterId or BattleNodeModel.items[params.nodeId].chapterModelID

    local chapterNum = chapterId - 10, nodeNum
    tempStr = TR("第%d章", chapterNum)

    if params.nodeId then
        -- 该章节下的节点信息
        local nodeList = ConfigFunc:getChapterNodeInfo(chapterId)
        for index, item in ipairs(nodeList) do
            if item.ID == params.nodeId then
                nodeNum = index
                break
            end
        end
        tempStr = TR("第%d章 第%d节", chapterNum, nodeNum)
    end

    return tempStr, chapterNum, nodeNum
end

-- ==================== EquipStepTeamRelation.lua/EquipStarTeamRelation.lua =============================
-- 装备锻造/升星共鸣相关接口

-- 返回某个阵容对应的装备培养共鸣等级
--[[
    -- 返回值，内容为空表示该部位未激活共鸣
    {
        [ResourcetypeSub.eClothes] = {StarLv = 1, StepLv = 1},
        [ResourcetypeSub.eHelmet] = {StarLv = 1},
        [ResourcetypeSub.ePants] = {StepLv = 1},
        [ResourcetypeSub.eWeapon] = {},
        [ResourcetypeSub.eShoe] = nil,
        [ResourcetypeSub.eNecklace] = {StarLv = 0, StepLv = 0},
    }
--]]
function ConfigFunc:getMasterLv(slotInfos)
    if (slotInfos == nil) then
        return nil
    end

    -- 判断上阵是否满6人
    for i=1,6 do
        local tmpSlotInfo = slotInfos[i] or {}
        if (not Utility.isEntityId(tmpSlotInfo.HeroId)) then
            return nil
        end
    end

    -- 读取某种装备类型的共鸣等级信息
    local function getMasterLvOfType(equipType)
        -- 判断是否穿戴了6件装备
        for i=1,6 do
            local tmpSlotInfo = slotInfos[i] or {}
            local equipInfo = tmpSlotInfo[Utility.getEquipTypeString(equipType)]
            if (not equipInfo) or (not Utility.isEntityId(equipInfo.Id)) or (not EquipObj:getEquip(equipInfo.Id)) then
                return 0, 0
            end
        end

        -- 读取6件装备的信息
        local allEquipInfos = {}
        for i=1,6 do
            local tmpEquipInfo = {}
            local tmpSlotInfo = slotInfos[i] or {}
            local equipInfo = tmpSlotInfo[Utility.getEquipTypeString(equipType)]
            tmpEquipInfo.itemInfo = clone(EquipObj:getEquip(equipInfo.Id))
            tmpEquipInfo.baseInfo = clone(EquipModel.items[equipInfo.ModelId])
            table.insert(allEquipInfos, tmpEquipInfo)
        end

        -- 读取锻造共鸣等级
        local function readMasterStepLv()
            -- 判断品质是否符合需求
            for _,v in ipairs(allEquipInfos) do
                if (v.baseInfo.valueLv < 3) then
                    return 0
                end
            end

            -- 读取配置
            local stepConfigs = {}
            for _,v in pairs(EquipStepTeamRelation.items) do
                table.insert(stepConfigs, clone(v))
            end
            table.sort(stepConfigs, function (a, b)
                    return a.Lv < b.Lv
                end)

            -- 找出当前最小的Step
            local maxNum = table.maxn(EquipStepTeamRelation.items)
            local minStep = EquipStepTeamRelation.items[maxNum].needStep
            for _,v in ipairs(allEquipInfos) do
                if (minStep > v.itemInfo.Step) then
                    minStep = v.itemInfo.Step
                end
            end

            -- 读取当前共鸣等级
            local currLv = 0
            for _,v in ipairs(stepConfigs) do
                if (minStep >= v.needStep) then
                    currLv = v.Lv
                end
            end
            return currLv
        end

        -- 读取升星共鸣等级
        local function readMasterStarLv()
            -- 判断品质是否符合需求
            for i,v in ipairs(allEquipInfos) do
                if (v.baseInfo.valueLv < 5) then
                    return 0
                end
            end

            -- 读取配置
            local starConfigs = {}
            for _,v in pairs(EquipStarTeamRelation.items) do
                table.insert(starConfigs, clone(v))
            end
            table.sort(starConfigs, function (a, b)
                    return a.Lv < b.Lv
                end)

            -- 找出当前最小的ID
            local minId = table.maxn(EquipStarTeamRelation.items)
            for _,v in ipairs(allEquipInfos) do
                local tmpId = (v.baseInfo.valueLv * 100) + v.itemInfo.Star
                if (minId > tmpId) then
                    minId = tmpId
                end
            end

            -- 读取当前共鸣等级
            local currLv = 0
            for _,v in ipairs(starConfigs) do
                if (minId >= v.ID) then
                    currLv = v.Lv
                end
            end
            return currLv
        end

        return readMasterStepLv(), readMasterStarLv()
    end

    -- 读取所有装备的共鸣
    local equipTypeList = {ResourcetypeSub.eClothes, ResourcetypeSub.eHelmet, ResourcetypeSub.ePants, ResourcetypeSub.eWeapon, ResourcetypeSub.eShoe, ResourcetypeSub.eNecklace}
    local ret = {}
    for _,v in ipairs(equipTypeList) do
        local stepLv, starLv = getMasterLvOfType(v)
        ret[v] = {StepLv = stepLv, StarLv = starLv}
    end
    return ret
end

-- ========================================= RebornLvModel.lua ==============================================
-- 获取带有转生属性的所有条目
--[[
-- 返回值
    {
        item1: RebornLvModel 配置表中的条目
    }
--]]
function ConfigFunc:getRebornLvItems()
    local retList = {}
    for _, item in pairs(RebornLvModel.items) do
        if item.step == 0 and item.rebornNum > 0 then
            table.insert(retList, item)
        end
    end
    table.sort(retList, function(item1, item2)
        return item1.ID < item2.ID
    end)
    return retList
end

-- 根据RebornLvModel.ID获取对应classID类型的所有转生属性(RebornLvModel.classID分类筛选)
--[[
-- 参数:
    rebornId: 转生等级模型Id
-- 返回值
    {
        item1: RebornLvModel 配置表中的条目
    }
--]]
function ConfigFunc:getRebornAttrInfosById(rebornId)
    local rebornModel = RebornLvModel.items[rebornId or 0]
    if not rebornModel then
        return {}
    end

    local retList = {}
    for _, item in ipairs(ConfigFunc:getRebornLvItems()) do
        if item.classID == rebornModel.classID then
            table.insert(retList, clone(item))
        end
    end

    return retList
end

-- 根据周卡返回加成label
--[[
-- 参数:
    isSplitEnter: 是否添加\n, 默认为false
    isOnlyExp: 是否只显示经验, 默认为false
-- 返回值
    {
        item1: 创建的label
    }
--]]
function ConfigFunc:getMonthAddAttrStr(isSplitEnter, isOnlyExp)
    local statusList = PlayerAttrObj:getPlayerAttrByName("ActiveCardId")
    local addStrList = {TR("%s金币+%d%%", Enums.Color.eOrangeH, CardAddRelation.items[1][2201].goldAddR / 100), TR("%s经验+%d%%", Enums.Color.eGreenH, CardAddRelation.items[2][2201].expAddR / 100)}
    local retString = ""
    for _,validId in ipairs(statusList or {}) do
        if not isOnlyExp or validId ~= 1 then
            retString = retString .. addStrList[validId]
            -- 添加间隔符
            if validId < 2 then
                retString = isSplitEnter and retString .. "\n" or retString .. "    "
            end
        end
    end
    if string.len(retString) > 0 then
        local titleNode = ui.newLabel({
            text = retString,
            size = 18,
            outlineColor = cc.c3b(0x23, 0x23, 0x23),
            outlineSize = 2,
        })
        return titleNode
    end
end

-- ========================================= 代金券相关 ======================================================
--参数 物品信息
--返回值 代金券状态 1:可以使用 0:过期 -1:无效代金券
function ConfigFunc:getVoucherStatus(data)

    local voucherStatus
    if next(data.GoodsVoucherConfig) == nil then
        voucherStatus = -1
        return voucherStatus 
    end 

    --参数处理
    local getTime = data.Crdate                 --道具获得时间戳
    -- local ChargeMoney = data.ChargeMoney          --已充值金额
    local item = data.GoodsVoucherConfig         --道具代金券配置信息
    local useIntraday = item.UseIntraday and 1 or 0        --是否当天使用:1表示当天使用，0表示不当天使用
    local useVoucherLimit = item.UseVoucherLimit --使用限制额度
    local startTime = item.UseStartTime         --开始时间
    local endTime = item.UseEndTime              --结束时间
    local validTime = item.ValidTime             --有效时间
    local curTime = Player:getCurrentTime()      --当前时间

    if startTime < 946656000 or endTime > 1577808000 then
        voucherStatus = -1
    end


    if useIntraday == 1 then 
        if curTime < getTime + validTime * 3600 then
            voucherStatus = 1
        else
            voucherStatus = 0
        end
    else
        local getTimeDays = os.date("*t",getTime)
        local totalscends = getTimeDays.hour * 3600 + getTimeDays.min * 60 + getTimeDays.sec 
        local nextgetTime = getTime - totalscends + 24 * 3600
        if curTime < nextgetTime + validTime * 3600 then
            voucherStatus = 1
        else
            voucherStatus = 0
        end
    end


    return voucherStatus
end

-- ================ ZhenyuanSlotRelation.lua (真元相关接口) =======================================
-- 获取某个真元卡槽是否已开启
--[[
-- 返回值
    bool: 是否开启
 ]]
function ConfigFunc:getZhenyuanGridIsOpen(heroId, index)
    if (heroId == nil) then
        return false
    end
    
    local heroData = HeroObj:getHero(heroId)
    if (heroData == nil) then
        return false
    end
    
    local maxNum = ZhenyuanSlotRelation.items[heroData.QuenchStep or 0].slotNum
    return (maxNum >= index)
end

-- 获取某个真元卡槽需要的开启条件
--[[
-- 返回值
    nCuiti: 需要淬体几重才能开启某个卡槽
 ]]
function ConfigFunc:getZhenyuanGridOpenConfig(index)
    -- 生成一个升序的条件列表
    local tmpList = {}
    for _,v in pairs(ZhenyuanSlotRelation.items) do
        table.insert(tmpList, clone(v))
    end
    table.sort(tmpList, function (a, b)
            return a.quenchStepLv < b.quenchStepLv
        end)

    -- 查找开放卡槽所需的最小条件
    for _,v in ipairs(tmpList) do
        if (index <= v.slotNum) then
            return v.quenchStepLv
        end
    end
    return 0
end

-- ================ ZhenyuanModel.lua (真元相关接口) =======================================
-- 根据真元模型ID和等级获取加成属性
--[[
-- 返回值
    {
        AP = 0,         -- 攻击
        HP = 0,         -- 血量
        EXPTotal = 0,   -- 经验总值
    }
 ]]
function ConfigFunc:getZhenyuanLvAttr(modelId, lv)
    local zhenyuanModel = ZhenyuanModel.items[modelId]
    if (zhenyuanModel == nil) then
        return {}
    end
    local retList = {}
    local baseAtrrList = Utility.analysisStrAttrList(zhenyuanModel.basicAttr)
    local upAtrrList = Utility.analysisStrAttrList(zhenyuanModel.attrUP)
    local function findAttrUpValue(attrKey)
        local attrValue = 0
        for _,v in ipairs(upAtrrList) do
            if (v.fightattr == attrKey) then
                attrValue = v.value
                break
            end
        end
        return attrValue
    end
    for _,v in ipairs(baseAtrrList) do
        local newValue = v.value + (lv * findAttrUpValue(v.fightattr))
        table.insert(retList, {fightattr = v.fightattr, value = newValue})
    end
    return retList
end

-- ================ IllusionModel.lua (幻化相关接口) =======================================
-- 通过模型图片名找幻化modelId
function ConfigFunc:getIllusionModelId(figureName)
    for _, v in pairs(IllusionModel.items) do
        if v.largePic == figureName then
            return v.modelId
        end
    end
    for _, v in pairs(HeroFashionRelation.items) do
        if v.largePic == figureName then
            return v.modelId
        end
    end
    return 0
end

-- 通过模型图片名找幻化modelId
function ConfigFunc:getHeroFashionModelId(figureName)
    for _, v in pairs(HeroFashionRelation.items) do
        if v.largePic == figureName then
            return v.Id
        end
    end
    return 0
end

-- 通过模型图片名找时装modelId
function ConfigFunc:getFashionModelId(figureName)
    for fashionModelId, v in pairs(FashionModel.items) do
        if v.actionPic == figureName then
            return fashionModelId
        end
    end
    return 0
end
-- ================ FashionStepRelation.lua (绝学进阶相关) =======================================
-- 计算进阶后的基本属性
function ConfigFunc:getBaseAttrByStep(modelId, step)
    local fashionModel = FashionModel.items[modelId]
    if (fashionModel == nil) then
        return {}
    end

    --
    local retList = {}
    for _,v in ipairs(string.split(fashionModel.baseAttrStr, ",")) do
        table.insert(retList, string.split(v, "|"))
    end
    if (step > 0) then
        local stepInfo = FashionStepRelation.items[modelId][step]
        local attrStepList = {}
        for _,v in ipairs(string.split(stepInfo.attrStr, ",")) do
            table.insert(attrStepList, string.split(v, "|"))
        end
        local function addToBaseAttr(item)
            local isFind = false
            for _,v in ipairs(retList) do
                if (v[1] == item[1]) then
                    v[2] = v[2] + item[2]
                    isFind = true
                    break
                end
            end
            if (isFind == false) then
                table.insert(retList, item)
            end
        end
        for _,attr in ipairs(attrStepList) do
            addToBaseAttr(attr)
        end
    end

    return retList
end