local MergeEquipment = {}

MergeEquipment.__index = MergeEquipment


require("app.cfg.equipment_suit_info")
require("app.cfg.equipment_skill_info")
require("app.cfg.equipment_star_info")

local EquipmentConst = require("app.const.EquipmentConst")

--装备子类型
MergeEquipment.SUBTYPE  = {
    EQUIP =1, -- 正常装备
    TREASURE =2 -- 宝物
}

--是否穿戴中
function MergeEquipment.isWearing(obj)
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        if G_Me.formationData:getWearTreasureKnightId(obj.id) ~= 0 then
            return true
        end
    else
        --equiment
        if G_Me.formationData:getWearEquipmentKnightId(obj.id) ~= 0 then
            return true
        end
    end
    return false
end

--谁穿着
function MergeEquipment.getWearingKnightId(obj)
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        return G_Me.formationData:getWearTreasureKnightId(obj.id)
    else
        --equiment
        return G_Me.formationData:getWearEquipmentKnightId(obj.id)
    end
    return 0
end

--取得baseInfo
function MergeEquipment.getInfo(obj)
    if obj._baseInfo == nil then
        if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
            --treasure
           obj._baseInfo = treasure_info.get(obj.base_id)
        else
            --equiment
            obj._baseInfo = equipment_info.get(obj.base_id)
        end
    end
    return obj._baseInfo
    
end

--置空baseInfo（宝物铸造会更改宝物品质，因此info需要变，此时需要将此info置空，以使下次能读取到正确的info）
function MergeEquipment.resetInfo(obj)
    obj._baseInfo = nil
end

--装备部位名字
function MergeEquipment.getTypeName(obj)
    local baseInfo = obj:getInfo()

    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return G_lang.getEquipNameByType(baseInfo.type+4)
    else
        --equiment
        return G_lang.getEquipNameByType(baseInfo.type)
    end
end

--装备类型图片
function MergeEquipment.getTypePic(obj)
    local baseInfo = obj:getInfo()
    local name = {"list_yinzhang_wuqi.png","list_yinzhang_kuijia.png","list_yinzhang_toukui.png","list_yinzhang_yaodai.png",
    "list_yinzhang_gongji.png","list_yinzhang_fangyu.png","list_yinzhang_jingyan.png"}
    local index = 0

    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        index = baseInfo.type+4
    else
        --equiment
        index = baseInfo.type
    end

    return "ui/text/txt/"..name[index]
end

--装备部位图片
function MergeEquipment.getTypeImagePath(obj)
    local baseInfo = obj:getInfo()

    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return G_Path.getTreasureTypeImage(baseInfo.type)
    else
        --equiment
        return G_Path.getEquipmentTypeImage(baseInfo.type)
    end
end

--是equipment还是treasure
function MergeEquipment.isEquipment(obj)
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return false
    else
        --equiment
        return true
    end
end



--[[
1.  物攻 +x （数值）；
2.  法攻 +x （数值）；
3.  物防 +x （数值）；
4.  法防 +x （数值）；
5.  生命 +x （数值）；
6.  攻击 +x （数值）；；
7.  物攻 +x% （百分比）；
8.  法攻 +x% （百分比）；
9.  物防 +x% （百分比）；
10. 法防 +x% （百分比）；
11. 生命 +x% （百分比）；
12. 攻击 +x% （百分比）；
13. 命中率 +x% （百分比）；
14. 闪避率 +x% （百分比）；
15. 暴击率 +x% （百分比）；
16. 抗暴率 +x% （百分比）；
17. 伤害加成 +x% （百分比）；
18. 伤害减免 +x% （百分比）；
19. 增加经验 +x （数值）；
22. PVP伤害加成 +x% （百分比）；
23. PVP伤害减免 +x% （百分比）；
]]

local isAttrTypeRate = {
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18]= true,
    [22] = true,
    [23]= true,
}

function MergeEquipment.isAttrTypeRate(type)
    return isAttrTypeRate[type]
end


--取得强化属性列表,返回数组, 
--{
-- {  type: 属性类型, typeString:属性类型的名字, value: 属性值,  valueString: 属性值文本} ,  
-- {  type: 属性类型, typeString:属性类型的名字, value: 属性值,  valueString: 属性值文本} , 
--}
--equipment有1条强化属性
--宝物有 2条强化属性
function MergeEquipment.getStrengthAttrs(obj, level)
    return MergeEquipment.getAttrs(obj, "strength", level)
   
end

--取得强化属性列表,返回数组, 
--{
-- {  type: 属性类型, typeString:属性类型的名字, value: 属性值,  valueString: 属性值文本} ,  
-- {  type: 属性类型, typeString:属性类型的名字, value: 属性值,  valueString: 属性值文本} , 
--}
--通常来说 equipment有2条洗练属性, 
--宝物有2条精炼属性
function MergeEquipment.getRefineAttrs(obj, level)
    return MergeEquipment.getAttrs(obj, "refine", level)
end

--取得升星属性列表,返回数组, 
--{
-- {  type: 属性类型, typeString:属性类型的名字, value: 属性值,  valueString: 属性值文本} ,  
-- {  type: 属性类型, typeString:属性类型的名字, value: 属性值,  valueString: 属性值文本} , 
--}
function MergeEquipment.getStarAttrs(obj, level)
    return MergeEquipment.getAttrs(obj, "star", level)
end

--category是指强化还是精炼
function MergeEquipment.getAttrs(obj, category, level)
    local attrs = {}
    local baseInfo = obj:getInfo()

  

    if category == "strength" then
        if level == nil then
            level = obj.level
        end

        if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
            --treasure
            if baseInfo.strength_type_1 ~= 0 then
                table.insert(attrs, {  type= baseInfo.strength_type_1, value= baseInfo.strength_value_1+(level-1)*baseInfo.strength_growth_1 })
            end
            if baseInfo.strength_type_2 ~= 0 then
                table.insert(attrs, {  type= baseInfo.strength_type_2, value= baseInfo.strength_value_2+(level-1)*baseInfo.strength_growth_2 })
            end
        else
            --equiment
            if baseInfo.strength_type ~= 0 then
               table.insert(attrs, {  type= baseInfo.strength_type, value= baseInfo.strength_value+(level-1)*baseInfo.strength_growth })
           end
        end
    elseif category == "refine" then
        if level == nil then
            level = obj.refining_level
        end

        if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
            --treasure
            --fuck ziye, 怎么叫advance了, 应该统一 refining啊, 紫夜没鸡鸡
            if baseInfo.advance_type_1 ~= 0 then
               table.insert(attrs, {  type= baseInfo.advance_type_1, value= baseInfo.advance_value_1+(level-1)*baseInfo.advance_growth_1 })
            end


            if baseInfo.advance_type_2 ~= 0 then
               table.insert(attrs, {  type= baseInfo.advance_type_2, value= baseInfo.advance_value_2+(level-1)*baseInfo.advance_growth_2 })
            end
        else
            --equiment
           if baseInfo.refining_type_1 ~= 0 then
               table.insert(attrs, {  type= baseInfo.refining_type_1, value= baseInfo.refining_value_1+(level-1)*baseInfo.refining_growth_1 })
           end


           if baseInfo.refining_type_2 ~= 0 then
               table.insert(attrs, {  type= baseInfo.refining_type_2, value=baseInfo.refining_value_2+(level-1)*baseInfo.refining_growth_2 })
           end
        end

    elseif category == "star" then

        if level == nil then
            level = obj.star
        end

        if obj.subtype == MergeEquipment.SUBTYPE.EQUIP then
            local equipmentStarInfo = equipment_star_info.get(level, baseInfo.equip_star_id)

            if equipmentStarInfo then

                --equiment
                if equipmentStarInfo.star_type1 > 0 then
                    obj.star_exp = obj.star_exp or 0
                    local value
                    if equipmentStarInfo.total_exp > 0 then
                        value = equipmentStarInfo.star_value1 + math.floor(obj.star_exp / equipmentStarInfo.total_exp * equipmentStarInfo.bar_value)
                    else
                        value = equipmentStarInfo.star_value1
                    end
                    table.insert(attrs, {  type= equipmentStarInfo.star_type1, value= value})
                end
            end
        end

    end



    --现在需要为type和value赋予 文本
    for i=1,#attrs do
        local attr = attrs[i]
        local type,value,typeString,valueString = MergeEquipment.convertAttrTypeAndValue(attr.type, attr.value)

        attr.value = value 

        attr.valueString = valueString
        attr.typeString = typeString
    end

    return attrs
end

function MergeEquipment.getAllAttrs(...)
    local resultAttr = {}
    local attrs = {...}
    for i = 1, #attrs do
        local attrInfo = attrs[i]
        for j = 1, #attrInfo do
            local attr = attrInfo[j]
            if resultAttr[attr.type] == nil then
                resultAttr[attr.type] = attr.value
            else
                resultAttr[attr.type] = resultAttr[attr.type] + attr.value
            end
        end

    end

    local tempAttrs = {}
    for k, v in pairs(resultAttr) do
        if v ~= 0 then
            tempAttrs[#tempAttrs + 1] = {type = k, value = v}
        end
    end

    local function sort(a, b)
        return a.type < b.type
    end

    table.sort(tempAttrs, sort)

    resultAttr = tempAttrs

    for i=1,#resultAttr do
        local attr = resultAttr[i]
        local type,value,typeString,valueString = MergeEquipment.convertAttrTypeAndValue(attr.type, attr.value)

        attr.value = value 

        attr.valueString = valueString
        attr.typeString = typeString
    end

    return resultAttr
end

function MergeEquipment.convertAttrTypeAndValue(type, value)
    -- if isAttrTypeRate[type] ~= nil then
    --     --比率型,那么value是千分比啊, 让它变百分比吧
    --     value = value / 10
    -- end

    local  valueString =  G_lang.getGrowthValue(type, value)
    local  typeString = G_lang.getGrowthTypeName(type)    
    return type, value, typeString, valueString    
end

function MergeEquipment.convertAttrTypeAndValueObject(type, value)    
    local type, value, typeString, valueString  = MergeEquipment.convertAttrTypeAndValue(type, value)
    return {type=type, value=value, typeString = typeString,valueString=valueString}
end


function MergeEquipment.convertPassiveSkillTypeAndValue(type, value)
    local  valueString =  G_lang.getPassiveSkillValue(type, value)
    local  typeString = G_lang.getPassiveSkillTypeName(type)    
    return type, value, typeString, valueString  
end



--从level强化到level+1需要的银两
function MergeEquipment.getStrengthEquipmentMoney(obj, level)
    local baseInfo = obj:getInfo()
    --只有equpment才能调用
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        --强化宝物需要银两吗??
       return 0
    else
        --equiment
        if level == nil then
            level = obj.level
        end

        local m = math.ceil( baseInfo.money * math.pow(level, 1.6))
        return m
    end

end


--最高强化等级 
function MergeEquipment.getMaxStrengthLevel(obj)
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        --写死上限80
       return 80
    else
        --equiment
        --当前装备可升级上限 = 主角等级*2
        return G_Me.userData.level * 2
    end
    
end

-- --下一个强化等级
-- function MergeEquipment.getNextStrengthLevel(obj)

--     return math.min( obj.level + 1 ,  obj:getMaxStrengthLevel() )
-- end

--下一个精炼等级
function MergeEquipment.getNextRefineLevel(obj)

    return math.min( obj.refining_level + 1 ,  obj:getMaxRefineLevel() )
end

function MergeEquipment.getNextStarLevel(obj)

    return math.min( obj.star + 1 ,  obj:getMaxStarLevel() )
end


--由于服务器存储的是总的refine exp,所以当前等级的refine exp需要去掉之前那些等级的exp
function MergeEquipment.getLeftRefineExp(obj)
    local total =  obj.refining_exp
    local level = obj.refining_level
    for i=0,level-1 do
        total = total - obj:getRefineNextLevelExp(i)
    end

    return total
end


--最大精炼等级
function MergeEquipment.getMaxRefineLevel(obj)
    --todo 写死 
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return 20
    else
        --equiment
        return 50
    end
    
end

--获得图标地址
function MergeEquipment.getIcon(obj)
    local baseInfo = obj:getInfo()
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return G_Path.getTreasureIcon(baseInfo.res_id)
    else
        --equiment
        return G_Path.getEquipmentIcon(baseInfo.res_id)
    end
end


--获得大图地址
function MergeEquipment.getPic(obj)
    local baseInfo = obj:getInfo()
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return G_Path.getTreasurePic(baseInfo.res_id)
    else
        --equiment
        return G_Path.getEquipmentPic(baseInfo.res_id)
    end
end

--精炼等级title图片
function MergeEquipment.getRefineLevelPic(obj)
    local baseInfo = obj:getInfo()
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
       return G_Path.getTreasurePic(baseInfo.res_id)
    else
        --equiment
        return G_Path.getEquipmentPic(baseInfo.res_id)
    end
end

--当前精炼等级升级所需要的经验
function MergeEquipment.getRefineNextLevelExp(obj, level)
    if level == nil then
        level = obj.refining_level
    end

    local baseInfo = obj:getInfo()
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        --宝物不是通过EXP 进行精炼的
       return 0
    else
        --equiment
        --level级装备精炼到level+1级，需求经验=int（（int(0.27*（level+1）^2+1)*50）*refining_exp/1000）
        local exp = math.floor((math.floor(0.27*  math.pow((level+1), 2)+1)*50)*baseInfo.refining_exp/1000)
        return exp
    end
end

--由于服务器存储的是总的exp,所以当前等级的exp需要去掉之前那些等级的exp
function MergeEquipment.getLeftStrengthExp(obj)
    local total =  obj.exp or 0
    local level = obj.level or 1
    for i=0,level-1 do
        total = total - obj:getStrengthNextLevelExp(i)
    end

    return total
end

--当前宝物等级强化所需要的经验
function MergeEquipment.getStrengthNextLevelExp(obj, level)
    if level == nil then
        level = obj.level or 0
    end

    if level == 0 then 
        return 0 
    end

    local baseInfo = obj:getInfo()
    --每级升级所需经验 = 初始需求经验值 + （lv ^2 ）* 需求经验成长值
    --need_exp := upgrade_treasure.base_info.Exp + (current_level ^ 2)*upgrade_treasure.base_info.ExpGrowth
    local exp = baseInfo.exp + ( level * level) * baseInfo.exp_growth
    return exp
end

--当前宝物强化到满级所需要的经验
function MergeEquipment.getStrengthLeftExp(obj)

    local maxLevel = obj:getMaxStrengthLevel()
    local baseInfo = obj:getInfo()
    local totalExp = 0

    for i=1,maxLevel-1 do
        totalExp = totalExp + obj:getStrengthNextLevelExp(i)
    end
    
    local exp = totalExp - obj.exp
    return exp
end

--当前宝物强化所需要的银两
function MergeEquipment.getStrengthMoney(obj,exp)
    return exp
end

--是经验宝物
function MergeEquipment.isForStrength(obj)
    return not obj:isEquipment() and obj:getInfo().type == 3
end

function MergeEquipment.getSupplyExp(obj)


     local baseInfo = obj:getInfo()
    if obj.subtype == MergeEquipment.SUBTYPE.TREASURE then
        --treasure
        --宝物不是通过EXP 进行精炼的
       return obj.exp + baseInfo.supply_exp
    else
        return 0
    end
end


--从一堆equpment list里得到这些equipment构成了哪些套装属性
--{ 
--   {id=equipment_suite_info.id, count=满足几件装备, attrs={type, value ...列表}}, 
--   {id=equipment_suite_info.id, count=满足几件装备, attrs={type, value ...列表}},
--  }
function MergeEquipment.getSuitListFromEquipmentList(equipments)

    
    local hasSuits = {}
    for i, equipment in ipairs(equipments) do 
        local info = equipment:getInfo()
        if hasSuits[info.suit_id] == nil then
            hasSuits[info.suit_id] = {count=0, equipmentIds = {}}
        end

        if hasSuits[info.suit_id].equipmentIds[info.id] == nil then
           hasSuits[info.suit_id].equipmentIds[info.id] = true
           hasSuits[info.suit_id].count = hasSuits[info.suit_id].count + 1
        end

    end

    local suits = {}
    for suitid, info in pairs(hasSuits) do 
        local suit = {}
        suit.count = info.count
        suit.id = suitid 
        suit.attrs = {}
        local suite_record = equipment_suit_info.get(suit.id)
        local type,value,typeString, valueString = MergeEquipment.convertAttrTypeAndValue(type1, value1)
        
        if suit.count >= 2 then
            table.insert(suit.attrs, MergeEquipment.convertAttrTypeAndValueObject(suite_record.two_suit_type_1, suite_record.two_suit_value_1))
            table.insert(suit.attrs, MergeEquipment.convertAttrTypeAndValueObject(suite_record.two_suit_type_2, suite_record.two_suit_value_2))


        end

        if suit.count >= 3 then
            table.insert(suit.attrs, MergeEquipment.convertAttrTypeAndValueObject(suite_record.three_suit_type_1, suite_record.three_suit_value_1))
            table.insert(suit.attrs, MergeEquipment.convertAttrTypeAndValueObject(suite_record.three_suit_type_2, suite_record.three_suit_value_2))

        end

        if suit.count >= 4 then

            table.insert(suit.attrs, MergeEquipment.convertAttrTypeAndValueObject(suite_record.four_suit_type_1, suite_record.four_suit_value_1))
            table.insert(suit.attrs, MergeEquipment.convertAttrTypeAndValueObject(suite_record.four_suit_type_2, suite_record.four_suit_value_2))
          
        end

        table.insert(suits, suit)


    end
    return suits
end

--初始化技能面板
function MergeEquipment.initSkill(baseInfo,refining_level,panel,title,widthOffset,fontSize)
    if baseInfo.potentiality < 23 then
        return 0
    end

    if title then 
        title:retain()
    end
    panel:removeAllChildren()
    local height = 5
    local size = panel:getSize()
    local has = false
    widthOffset = widthOffset or 15
    fontSize = fontSize or 22
    for i = 20, 1,-1 do 
        if equipment_info.hasKey("equipment_skill_"..i) then
            local skillId = baseInfo["equipment_skill_"..i]
            if skillId > 0 then
                local info = equipment_skill_info.get(skillId)
                local str = "["..info.name.."]  "..info.directions
                local label = GlobalFunc.createGameLabel(str,fontSize,
                    refining_level >= info.open_value and Colors.activeSkill or Colors.inActiveSkill,
                    nil,CCSizeMake(size.width - widthOffset, 0), true)
                local labelSize = label:getSize()

                label:setPosition(ccp(size.width/2, height + labelSize.height/2))
                panel:addChild(label)
                height = height + labelSize.height
                has = true
            end
        end
    end
    if not has then
        return 0
    end

    height = height + 5
    if title then 
        local titleSize = title:getSize()
        panel:addChild(title)
        title:release()
        title:setPosition(ccp(size.width/2, height + titleSize.height/2))
        height = height + titleSize.height
    end
    panel:setSize(CCSizeMake(size.width, height+5))

    return height
end

function MergeEquipment.getSkillTxt(obj)
    local list = {}
    local baseInfo = obj:getInfo()
    for i = 1, 20 do 
        if equipment_info.hasKey("equipment_skill_"..i) then
            local skillId = baseInfo["equipment_skill_"..i]
            if skillId > 0 then
                local info = equipment_skill_info.get(skillId)
                local str = "["..info.name.."]  "..info.directions
                local color = obj.refining_level >= info.open_value and Colors.activeSkill or Colors.inActiveSkill
                table.insert(list,#list+1,{content=str,color=color})
            end
        end
    end
    return list
end


--------------------------------- 装备升星 ---------------------------------

function MergeEquipment.getMaxStarLevel(obj)
    if obj then
        local info = obj:getInfo()
        if info.potentiality >= EquipmentConst.Star_Potentiality_FiveStar_Value then
            return EquipmentConst.Star_MAX_LEVEL
        else
            return EquipmentConst.Star_CHENG_MAX_LEVEL
        end
    end

    return EquipmentConst.Star_MAX_LEVEL
end

return MergeEquipment