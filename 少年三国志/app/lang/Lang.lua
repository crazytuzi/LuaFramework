-- Lang
-- 用于定义游戏中显示用的文本

local Lang = 
{

}

local _templates = require("app.lang.LangTemplate")

function Lang:isLangExist(key)
    return _templates[key] ~= nil
end

--使用示例:
--    local str = G_lang:get("LANG_DUNGEON_GET_MONEY", {name="xxxx", money="2323"})
-- 或者 local str = G_lang:get("LANG_DUNGEON_GET_MONEY")

function Lang:get(key, values)
    local tmpl = _templates[key]
    if tmpl == nil then
        __Error("cannot get lang for key :" .. key)
        return key
    end
    
    return self:getByString(tmpl,values)
end

function Lang:initLangSetting( lang )
    local shouldSetLange = false
    if lang == "tw" then
        shouldSetLange = true
    end

    if not shouldSetLange then 
        return 
    end

    Label:registerLangTextHandler(function ( key )
        return "[replace text]"
    end)
end

function Lang:getByString(text, values)
    if text == nil then
        __Error("cannot get lang for key :" .. key)
        return ""
    end
    
    if values ~= nil then
        --replace vars in tmpl
        for k,v in pairs(values) do
            text = string.gsub(text, "#" .. k .. "#", v)            
    end
        
    end
    
    return text
end

function Lang.getKnightTypeStr( typeId )
    local knightType = {
    _templates["LANG_LEIXING_WUGONG"],
    _templates["LANG_LEIXING_FAGONG"],
    _templates["LANG_LEIXING_FANGYU"],
    _templates["LANG_LEIXING_FUZHU"],
    }

    typeId = typeId or 1
    if typeId >= 1 and typeId <= 4 then
        return knightType[typeId]
    else
        return knightType[1]
    end
end

function Lang.getEquipNameByType( typeId )
    typeId = typeId or 0

    local typeList = {
    _templates["LANG_EQUIP_WEAPON"],
    _templates["LANG_EQUIP_CLOTHES"],
    _templates["LANG_EQUIP_PIFENG"],
    _templates["LANG_EQUIP_YAODAI"],
    _templates["LANG_EQUIP_ATTACKEN"],
    _templates["LANG_EQUIP_DEFENSE"],
    _templates["LANG_EXP"],
    }

    if typeId < 1 or typeId > #typeList then
        return ""
    else
        return typeList[typeId]
    end
end

function Lang.getGrowthTypeName( typeId )
    typeId = typeId or 0

    local typeList = {
    [1] =  _templates["LANG_GROWUP_ATTRIBUTE_WUGONG"],
    [2] = _templates["LANG_GROWUP_ATTRIBUTE_MOUGONG"],
    [3] = _templates["LANG_GROWUP_ATTRIBUTE_WUFANG"],
    [4] = _templates["LANG_GROWUP_ATTRIBUTE_MOFANG"], 
    [5] = _templates["LANG_GROWUP_ATTRIBUTE_SHENGMING"],
    [6] =  _templates["LANG_GROWUP_ATTRIBUTE_GONGJI"],
    [7] = _templates["LANG_GROWUP_ATTRIBUTE_WUGONG"],
    [8] = _templates["LANG_GROWUP_ATTRIBUTE_MOUGONG"],
    [9] = _templates["LANG_GROWUP_ATTRIBUTE_WUFANG"],
    [10] = _templates["LANG_GROWUP_ATTRIBUTE_MOFANG"],
    [11] = _templates["LANG_GROWUP_ATTRIBUTE_SHENGMING"],
    [12] = _templates["LANG_GROWUP_ATTRIBUTE_GONGJI"],
    [13] = _templates["LANG_GROWUP_ATTRIBUTE_MINGZHONGLV"],
    [14] = _templates["LANG_GROWUP_ATTRIBUTE_SHANBILV"],
    [15] = _templates["LANG_GROWUP_ATTRIBUTE_BAOJILV"],
    [16] = _templates["LANG_GROWUP_ATTRIBUTE_KANGBAOLV"],
    [17] = _templates["LANG_GROWUP_ATTRIBUTE_SHANGHAIJIACHENG"],
    [18] = _templates["LANG_GROWUP_ATTRIBUTE_SHANGHAIJIANMIAN"],
    [19] = _templates["LANG_GROWUP_ATTRIBUTE_BASE_NUQI"],
    [20] = _templates["LANG_GROWUP_ATTRIBUTE_NUQI_HUIFU"],
    [21] = _templates["LANG_GROWUP_ATTRIBUTE_WUFANG_MOFANG"],
    [22] = _templates["LANG_GROWUP_ATTRIBUTE_PVPZENGSHANG"],
    [23] = _templates["LANG_GROWUP_ATTRIBUTE_PVPJIANSHANG"],
    [24] = _templates["LANG_GROWUP_ATTRIBUTE_WUFANG_MOFANG"],
    [25] = _templates["LANG_GROWUP_EXP"],
    [26] = _templates["LANG_GROWUP_ATTRIBUTE_ALL_ADD"],
    [27] = _templates["LANG_GROWUP_ATTRIBUTE_ATK_UP_TO_WEI"],
    [28] = _templates["LANG_GROWUP_ATTRIBUTE_ATK_UP_TO_SHU"],
    [29] = _templates["LANG_GROWUP_ATTRIBUTE_ATK_UP_TO_WU"],
    [30] = _templates["LANG_GROWUP_ATTRIBUTE_ATK_UP_TO_QUN"],
    [31] = _templates["LANG_GROWUP_ATTRIBUTE_DEF_UP_TO_WEI"],
    [32] = _templates["LANG_GROWUP_ATTRIBUTE_DEF_UP_TO_SHU"],
    [33] = _templates["LANG_GROWUP_ATTRIBUTE_DEF_UP_TO_WU"],
    [34] = _templates["LANG_GROWUP_ATTRIBUTE_DEF_UP_TO_QUN"],
    }

    if typeId < 1 or typeId > #typeList then
        return ""
    else
        return typeList[typeId]
    end
end

function Lang.getGrowthValue( typeId, value )
    if value == nil then
        return ""
    end

    typeId = typeId or 0


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
    [22]= true,
    [23]= true,
    [24]= true,
    [25]= true,
    [26]= true,
    [27]= true,
    [28]= true,
    [29]= true,
    [30]= true,
    [31]= true,
    [32]= true,
    [33]= true,
    [34]= true,
}

    local valueList = {
    [1] = "%d",
    [2] = "%d",
    [3] = "%d",
    [4] = "%d",
    [5] = "%d",
    [6] = "%d",
    [7] = "%.1f%%",
    [8] = "%.1f%%",
    [9] = "%.1f%%",
    [10] = "%.1f%%",
    [11] = "%.1f%%",
    [12] = "%.1f%%",
    [13] = "%.1f%%",
    [14] = "%.1f%%",
    [15] = "%.1f%%",
    [16] = "%.1f%%",
    [17] = "%.1f%%",
    [18] = "%.1f%%",
    [19] = "%d",
    [20] = "%d",
    [21] = "%d",
    [22] = "%.1f%%",
    [23] = "%.1f%%",
    [24] = "%.1f%%",
    [25] = "%.1f%%",
    [26] = "%.1f%%",
    [27] = "%.1f%%",
    [28] = "%.1f%%",
    [29] = "%.1f%%",
    [30] = "%.1f%%",
    [31] = "%.1f%%",
    [32] = "%.1f%%",
    [33] = "%.1f%%",
    [34] = "%.1f%%",
    }

    if typeId < 1 or typeId > #valueList then
        return ""..value
    else
        if isAttrTypeRate[typeId] and value then 
            value = value/10
        end
        return string.format(valueList[typeId], value)
    end
end

function Lang.getPassiveSkillTypeName(typeId, isAbbr)
    typeId = typeId or 0
    local typeList = {
       [1] = _templates[isAbbr and "LANG_GROWUP_ATTRIBUTE_MINGZHONG" or "LANG_GROWUP_ATTRIBUTE_MINGZHONGLV"],
       [2] = _templates[isAbbr and "LANG_GROWUP_ATTRIBUTE_SHANBI" or "LANG_GROWUP_ATTRIBUTE_SHANBILV"],
       [3] = _templates[isAbbr and "LANG_GROWUP_ATTRIBUTE_BAOJI" or "LANG_GROWUP_ATTRIBUTE_BAOJILV"],
       [4] = _templates[isAbbr and "LANG_GROWUP_ATTRIBUTE_KANGBAO" or "LANG_GROWUP_ATTRIBUTE_KANGBAOLV"],
       [5] = _templates[isAbbr and "LANG_GROWUP_ATTRIBUTE_JIASHANG" or "LANG_GROWUP_ATTRIBUTE_SHANGHAIJIACHENG"],
       [6] = _templates[isAbbr and "LANG_GROWUP_ATTRIBUTE_JIANSHANG" or "LANG_GROWUP_ATTRIBUTE_SHANGHAIJIANMIAN"],
       [7] = _templates["LANG_GROWUP_ATTRIBUTE_ATTACK"],
       [8] = _templates["LANG_GROWUP_ATTRIBUTE_DEFENSE"],
       [9] = _templates["LANG_GROWUP_ATTRIBUTE_SHENGMING"],
       [10] = _templates["LANG_GROWUP_ATTRIBUTE_WEI_ADD_HARM"],
       [11] = _templates["LANG_GROWUP_ATTRIBUTE_SHU_ADD_HARM"],
       [12] = _templates["LANG_GROWUP_ATTRIBUTE_WU_ADD_HARM"],
       [13] = _templates["LANG_GROWUP_ATTRIBUTE_QUN_ADD_HARM"],
       [14] = _templates["LANG_GROWUP_ATTRIBUTE_ORIG_ANGER"],
       [15] = _templates["LANG_GROWUP_ATTRIBUTE_ANGER_RECOVER"],
       [16] = _templates["LANG_GROWUP_ATTRIBUTE_ATTACK"],
       [17] = _templates["LANG_GROWUP_ATTRIBUTE_SHENGMING"],
       [18] = _templates["LANG_GROWUP_ATTRIBUTE_DEFENSE"],
       [19] = _templates["LANG_GROWUP_ATTRIBUTE_ATTACK_DEFENSE_HP"],
    }

    if typeId < 1 or typeId > #typeList then
        assert(false, " error typeId = " .. tostring(typeId))
        return ""
    else
        return typeList[typeId]
    end
end


function Lang.getPassiveSkillValue( typeId, value )
    if value == nil then
        return ""
    end

    typeId = typeId or 0


    local isAttrTypeRate = {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [19] = true,
    }

    local valueList = {
        [1] = "%.1f%%",
        [2] = "%.1f%%",
        [3] = "%.1f%%",
        [4] = "%.1f%%",
        [5] = "%.1f%%",
        [6] = "%.1f%%",
        [7] = "%.1f%%",
        [8] = "%.1f%%",
        [9] = "%.1f%%",
        [10] = "%.1f%%",
        [11] = "%.1f%%",
        [12] = "%.1f%%",
        [13] = "%.1f%%",
        [14] = "%d",
        [15] = "%d",
        [16] = "%d",
        [17] = "%d",
        [18] = "%d",
        [19] = "%.1f%%",
    }

    if typeId < 1 or typeId > #valueList then
        assert(false, " error typeId = " .. tostring(typeId))
        return ""..value
    else
        if isAttrTypeRate[typeId] and value then 
            value = value/10
        end
        return string.format(valueList[typeId], value)
    end
end


function Lang.getSkillTypeName( typeId )
    typeId = typeId or 0

    local typeList = {
    [1] =  _templates["LANG_GROWUP_ATTRIBUTE_MINGZHONGLV"],
    [2] = _templates["LANG_GROWUP_ATTRIBUTE_SHANBILV"],
    [3] = _templates["LANG_GROWUP_ATTRIBUTE_BAOJILV"],
    [4] = _templates["LANG_GROWUP_ATTRIBUTE_KANGBAOLV"], 
    [5] = _templates["LANG_GROWUP_ATTRIBUTE_SHANGHAIJIACHENG"],
    [6] =  _templates["LANG_GROWUP_ATTRIBUTE_SHANGHAIJIANMIAN"],
    [9] = _templates["LANG_GROWUP_ATTRIBUTE_SHENGMING"],
    [16] = _templates["LANG_GROWUP_ATTRIBUTE_GONGJI"],
    }

    -- if typeId < 1 or typeId > #typeList then
    --     return ""
    -- else
        return typeList[typeId]
    -- end
end

function Lang.getSkillValue( typeId, value )
    if value == nil then
        return ""
    end

    typeId = typeId or 0

    local valueList = {
    [1] = "%.1f%%",
    [2] = "%.1f%%",
    [3] = "%.1f%%",
    [4] = "%.1f%%",
    [5] = "%.1f%%",
    [6] = "%.1f%%",
    [9] = "%.1f%%",
    [16] = "%d",
    }

    -- if typeId < 1 or typeId > #valueList then
    --     return ""..value
    -- else
        return string.format(valueList[typeId], value)
    -- end
end

function Lang.getJinglianValue( level )
    if not level or level < 1 then
        return _templates["LANG_JING_LIAN_NEVER"] 
    else
      return Lang:get("LANG_JING_LIAN", {level = level})
    end
end

return Lang

