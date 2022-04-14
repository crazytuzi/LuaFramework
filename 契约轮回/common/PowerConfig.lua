--
-- @Author: LaoY
-- @Date:   2018-10-26 15:32:49
-- 战力公式

--[[
    >=12的值需要在后面加%
]]
PROP_ENUM = {
    [5] = { label = "DEF", sort = 4 },
    [2] = { label = "HP", sort = 2 },
    [6] = { label = "Penetration", sort = 3 },
    [4] = { label = "ATK", sort = 1 },
    [7] = { label = "Accuracy", sort = 5 },
    [8] = { label = "Dodge", sort = 6 },
    [9] = { label = "Crit", sort = 7 },
    [10] = { label = "TEN", sort = 8 },
    [11] = { label = "M. ATK", sort = 9 },
    [12] = { label = "M. DEF", sort = 10 },
    [1] = { label = "Current HP", sort = 11 }, -- 当前生命
    [3] = { label = "Movement speed", sort = 12 }, -- 速度(像素/秒),20的倍数
    [13] = { label = "Attack Boost", sort = 13 }, -- 伤害加深
    [14] = { label = "Damage Reduction", sort = 14 }, -- 伤害减免
    [15] = { label = "Hit Chance", sort = 15 }, -- 命中几率
    [16] = { label = "Dodge Rate", sort = 16 }, -- 闪避几率
    [17] = { label = "Armor", sort = 17 }, -- 护甲几率
    [18] = { label = "Armor Penetration", sort = 18 }, -- 护甲穿透
    [19] = { label = "Block Rate", sort = 19 }, -- 格挡几率
    [20] = { label = "Pierce", sort = 20 }, -- 格挡穿透
    [21] = { label = "Crit Rate", sort = 21 }, -- 暴击几率
    [22] = { label = "Crit Resistance", sort = 22 }, -- 暴击抵抗
    [23] = { label = "Concentrated Strike Rate", sort = 23 }, -- 会心几率
    [24] = { label = "Concentrated Strike Resistance", sort = 24 }, -- 会心抵抗
    [25] = { label = "Crit Damage", sort = 25 }, -- 暴击伤害
    [26] = { label = "Concentrated Strike Damage", sort = 26 }, -- 会心伤害
    [27] = { label = "Increased Skill Damage", sort = 27 }, -- 技能增伤
    [28] = { label = "Skill Damage Reduction", sort = 28 }, -- 技能减伤
    [29] = { label = "Strike Rate", sort = 29 }, -- 重击几率
    [30] = { label = "Chance of Weakening", sort = 30 }, -- 虚弱几率
    [31] = { label = "Crit Damage Reduction", sort = 31 }, -- 暴伤减免
    [32] = { label = "Normal attack bonus", sort = 32 }, -- 普攻加成
    [33] = { label = "Block damage", sort = 33 }, -- 格挡免伤
    [34] = { label = "PVP Damage Resistance", sort = 34 }, -- pvp免伤
    [35] = { label = "PVP Armor", sort = 35 }, -- pvp护甲几率
    [36] = { label = "PVP Armor Penetration", sort = 36 }, -- pvp护甲穿透
    [37] = { label = "Boss Damage Boost", sort = 37 }, -- boss增伤
    [38] = { label = "Monster damage bonus", sort = 38 }, -- 怪物减免
    [39] = { label = "Offensive skill CP", sort = 39 }, -- 怪物减免
    [40] = { label = "Defensive skill CP", sort = 40 }, -- 怪物减免
    [41] = { label = "Damage Reduction", sort = 41 }, -- 怪物减免
    [42] = { label = "PVP Damage Resistance", sort = 42 }, -- 怪物减免
    [43] = { label = "Concentrated skill damage reduction", sort = 43 }, -- 怪物减免
    [45] = { label = "Deathblow", sort = 45 }, -- 致命一击
    [46] = { label = "Absolute Evasion", sort = 46 }, -- 绝对闪避

    [1100] = { label = "Total Attribute Percentage", sort = 31 }, -- 全属性百分比(全局)
    [1102] = { label = "HP Bonus", sort = 32 }, -- 生命加成
    [1104] = { label = "Attack bonus", sort = 33 }, -- 攻击加成
    [1105] = { label = "Defense Bonus", sort = 34 }, -- 防御加成
    [1106] = { label = "Penetration Bonus", sort = 35 }, -- 破甲加成
    [1107] = { label = "Accuracy Bonus", sort = 36 }, -- 命中百分比(全局)
    [1108] = { label = "Dodge Bonus", sort = 37 }, -- 闪避百分比(全局)
    [1109] = { label = "Crit Bonus", sort = 38 }, -- 暴击百分比(全局)
    [1110] = { label = "Tenacity Bonus", sort = 39 }, -- 坚韧百分比(全局)
    [1111] = { label = "Spell Attack Bonus", sort = 40 }, -- 神圣(五行)攻击百分比(全局)
    [1112] = { label = "Spell Defense Bonus", sort = 41 }, -- 神圣(五行)防御百分比(全局)
    [1200] = { label = "Total Attribute Percentage", sort = 42 }, -- 全属性百分比(部分)
    [1202] = { label = "HP", sort = 43 }, -- 血量百分比(部分)
    [1204] = { label = "ATK", sort = 44 }, -- 攻击百分比(部分)
    [1205] = { label = "DEF", sort = 45 }, -- 防御百分比(部分)
    [1206] = { label = "Penetration", sort = 46 }, -- 破甲百分比(部分)
    [1207] = { label = "Accuracy", sort = 47 }, -- 命中百分比(部分)
    [1208] = { label = "Dodge", sort = 48 }, -- 闪避百分比(部分)
    [1209] = { label = "Crit", sort = 49 }, -- 暴击百分比(部分)
    [1210] = { label = "TEN", sort = 50 }, -- 坚韧百分比(部分)
    [1211] = { label = "M. ATK", sort = 51 }, -- 神圣(五行)攻击百分比(部分)
    [1212] = { label = "M. DEF", sort = 52 }, -- 神圣(五行)防御百分比(部分)
    [1302] = { label = "Basic HP", sort = 53 }, -- 血量百分比(基础)
    [1304] = { label = "Basic Attack", sort = 54 }, -- 攻击百分比(基础+-)
    [1305] = { label = "Basic Defense", sort = 55 }, -- 防御百分比(基础)
    [1306] = { label = "Basic Penetration", sort = 56 }, -- 破甲百分比(基础)
    [1404] = { label = "Weapon Attack", sort = 57 }, -- 攻击百分比(武器攻击)
    [1406] = { label = "Weapon Penetration", sort = 58 }, -- 破甲百分比(武器破甲)
    [1502] = { label = "Armor HP", sort = 59 }, -- 防御百分比(防具生命)
    [1505] = { label = "Armor Defense", sort = 60 }, -- 防御百分比(防具防御)
    [1604] = { label = "Accessory Attack", sort = 61 }, -- 攻击百分比(饰品攻击)
    [2000] = { label = "EXP Bonus", sort = 62 }, -- 经验加成
    [2012] = { label = "Divine attributes", sort = 63 },
}

---需要做ID转换的属性配置
PROP_ENUM_EXCHANGE = {
    [41] = 14,
    [42] = 34,
}

---值类型的属性
PROP_ENUM_VALUE_TYPE = {
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
    [2003] = true,
    [2004] = true,
    [2005] = true,
}

-- 对应类型 输出还是生存
local power_type_map = {
    -- 输出侧
    -- 基础
    ["att"] = 1, -- 攻击
    ["wreck"] = 1, -- 破甲
    ["holy_att"] = 1, -- 神圣(五行)攻击
    ["hit"] = 1, -- 命中
    ["crit"] = 1, -- 暴击

    --生存侧
    -- 基础
    ["hpmax"] = 2, -- 生命上限
    ["def"] = 2, -- 防御
    ["miss"] = 2, -- 闪避
    ["holy_def"] = 2, -- 神圣(五行)防御
    ["tough"] = 2, -- 坚韧
}

-- 属性对应战力
-- 基础战力，单个属性可以转化成具体战力，数值需要配置
local power_base_map = {
    ["att"] = 10, -- 攻击
    ["wreck"] = 10, -- 破甲
    ["holy_att"] = 10, -- 神圣(五行)攻击
    ["hit"] = 10, -- 命中
    ["crit"] = 10, -- 暴击

    ["hpmax"] = 0.5, -- 生命上限
    ["def"] = 10, -- 防御
    ["miss"] = 10, -- 闪避
    ["holy_def"] = 10, -- 神圣(五行)防御
    ["tough"] = 10, -- 坚韧
}

local function getValue(map, key, defalut)
    return map[key] or defalut or 0
end
local function getMaxValue(map, key, defalut, max, max_value)
    local value = getValue(map, key, defalut)
    value = value >= max and max_value or value
    return value
end
--[[
	@author LaoY
	@des	字典获取战力
	@ps 	{
		["hpmax"] = 10,		-- 生命上限
		["speed"] = 100,	-- 速度
	}
	@return number
--]]
function GetPowerByMap(map)
    local base_tab = { 0, 0 }
    local rate_tab = { 1, 1 }
    for k, v in pairs(map) do
        if power_base_map[k] then
            base_tab[power_type_map[k]] = v * power_base_map[k] + base_tab[power_type_map[k]]
        end
    end

    -- 技能战力加成
    local fight_skill_rate = 1 + getValue(map, "skill_amp")
    -- 攻击方 技能固定战力
    local fight_skill_power = getValue(map, "skill_att_power")
    -- 暴击加成
    local fight_crit = 1 + getValue(map, "crit_dmg") * (getValue(map, "crit_pro", 1) - 1)
    fight_crit = fight_crit < 1 and 1 or fight_crit
    -- 会心一击
    local fight_heart = 1 + getValue(map, "heart_pro") * (getValue(map, "heart_dmg", 1) - 1) + getValue(map, "block_str") * 0.25
    fight_heart = fight_heart < 1 and 1 or fight_heart
    -- 伤害加成
    local fight_dmg = 1 + getValue(map, "dmg_amp") + getValue(map, "armor_str") * 0.45
    local pet = 1

    local fight_power = base_tab[1]
    fight_power = (fight_power * fight_skill_rate + fight_skill_power) * fight_crit * fight_heart * fight_dmg * pet

    -- 技能战力加成
    local def_skill_rate = 1 + getValue(map, "skill_red")
    -- 防御方 技能固定战力
    local def_skill_power = getValue(map, "skill_def_power")
    -- 暴击抵挡
    local def_crit = 1 + getValue(map, "crit_res")
    -- 伤害减免
    local def_dmg = 1 / (1 - getMaxValue(map, "dmg_red", 0, 1, 0.999))
    -- miss
    local def_miss = 1 / (1 - getMaxValue(map, "miss_pro", 0, 1, 0.999))
    -- 格挡 会心一击抵挡
    local def_block = 1 + getValue(map, "block_pro") * (0.34 + getValue(map, "block_dmg_red")) + getValue(map, "heart_res") * 0.5
    local def_power = base_tab[2]
    def_power = (def_power * def_skill_rate + def_skill_power) * def_crit * def_dmg * def_miss * def_block

    -- local fig_str = string.format("输出侧战力 基础:%s，合计:%s",base_tab[1],fight_power)
    -- local def_str = string.format("生存侧战力 基础:%s，合计:%s",base_tab[2],def_power)
    -- Yzprint(fig_str)
    -- Yzprint(def_str)
    -- Yzprint(fight_power + def_power)

    return math.ceil(fight_power + def_power)
end

--[[
	@author LaoY
	@des	属性序号转化成属性名字
--]]
function IndexToMapKey(index)
    for key, _index in pairs(enum.ATTR) do
        if index == _index then
            key = string.gsub(key, "ATTR_", "")
            key = string.lower(key)
            return key
        end
    end
    return
end

function GetAttrMapIndexByKey(key)
    if not string.find(key, "ATTR_") then
        key = "ATTR_" .. key
    end
    key = string.upper(key)
    return enum.ATTR[key]
end

--[[
	@author LaoY
	@des	列表获取战力
	@ps {
		[2] = 10,	-- 生命上限
		[3] = 100,	-- 速度
	}
--]]
BASE_CAL_TAB = {
    [2] = { 1202, 1102, 1302, 1502 },
    [4] = { 1204, 1104, 1304, 1404, 1604 },
    [5] = { 1205, 1105, 1305, 1505 },
    [6] = { 1206, 1106, 1306, 1406 },
    [7] = { 1207, 1107 },
    [8] = { 1208, 1108 },
    [9] = { 1209, 1109 },
    [10] = { 1210, 1110 },
    [11] = { 1211, 1111 },
    [12] = { 1212, 1112 },
}
function GetPowerByList(list, role_attr)
    local map = {}
    for index, v in pairs(list) do
        local key = IndexToMapKey(index)
        if key then
            map[key] = v
        end
    end

    -- 部分公式的基础数值 还得计算一次
    role_attr = role_attr or RoleInfoModel:GetInstance():GetRoleValue("attr") or {}
    for index, list in pairs(BASE_CAL_TAB) do
        local key = IndexToMapKey(index)
        map[key] = map[key] or 0
        for _,v in pairs(list) do
            local key_1 = IndexToMapKey(v)
            local value = role_attr[key_1] or 0
            map[key] = map[key] * (1 + value / 10000)
        end
    end

    return GetPowerByMap(map),map
end

--[[
	@author LaoY
	@des	列表获取战力
	@ps {
		{2,100},	-- 生命上限
		{3,100},	-- 速度
	}
--]]
function GetPowerByConfigList(list, role_attr)
    local len = #list
    local t = {}
    for i = 1, len do
        local info = list[i]
        t[info[1]] = info[2]
    end
    return GetPowerByList(t, role_attr)
end

--[[
	@author LaoY
	@des	获取中文名字 
	@param1 index 	attr index ps:2
--]]
function GetAttrNameByIndex(index)
    return enumName.ATTR[index]
end

--[[
	@author LaoY
	@des	获取中文名字 
	@param1 key 	attr key ps:hpmax
--]]
function GetAttrNameByKey(key)
    return GetAttrNameByIndex(GetAttrMapIndexByKey(key))
end

---是否为值类型属性
function IsValueTypeProperty(propertyId)
    return PROP_ENUM_VALUE_TYPE[propertyId]
end

---将属性配置转为Table
---配置表中的属性值有人为定义的转换关系
---其中： 41 -> 14, 42 ->34
---方便用的时候统一替换
function AttrConfigString2Table(str)
    local tab = String2Table(str)
    for _, v in ipairs(tab) do
        if type(v) == "table" and type(v[1]) == "number" then
            if PROP_ENUM_EXCHANGE[v[1]] then
                v[1] = PROP_ENUM_EXCHANGE[v[1]]
            end
        end
    end

    return tab
end

--攻击侧战力
function GetAttackPowerByList()
    local list = {4,6,7,9,11,27,39,21,25,23,26,20,13,18,45}
    local role_attr = RoleInfoModel:GetInstance():GetRoleValue("attr")
    local list2 = {}
    local i=1, #list do
        local attr = IndexToMapKey(list[i])
        list2[list[i]] = role_attr[attr]
    end
    return GetPowerByList(list2, role_attr)
end