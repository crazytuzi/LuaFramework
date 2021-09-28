-- Filename: HeroAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 武将数据

require "script/model/hero/HeroModel"

module("HeroAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
    local heroInfo = HeroModel.getHeroByHid(p_hid)
    local heroAffix = getHeroAllAffixByInfo(heroInfo)
    return heroAffix
end

--[[
	@des 	: 根据武将信息得到武将属性
	@parm 	: 武将信息
	@ret 	: {
		affixId => affixValue
	}
--]]
function getHeroAllAffixByInfo( p_heroInfo )
    local isOnFormation = HeroPublicLua.isOnFormation(p_heroInfo.hid)
    local affix = {}
    -- 武将属性 = 武将本身属性 + 天赋属性 + 觉醒能力 + 名将属性 + 天命属性 + 时装属性 + 时装屋属性 + 装备属性 + 战魂属性 + 神兵属性 + 神兵录属性 + 宠物属性 + 宝物属性 + 羁绊属性 + 阵法属性
    RecordTime("1", 0)
    affix[1] = getHeroAffixByInfo(p_heroInfo)
    RecordTime("1", 1)
    
    printTable("武将属性",affix[1])
    --天赋属性
    RecordTime("2", 0)
    affix[2] = getHeroTalentAffixByInfo(p_heroInfo)
    RecordTime("2", 1)
    
    printTable("天赋属性",affix[2])
    --觉醒能力
    RecordTime("3", 0)
    affix[3] = getHeroAwakenAffixByHeroInfo(p_heroInfo)
    RecordTime("3", 1)
    
    printTable("觉醒能力",affix[3])
    --名将属性
    RecordTime("4", 0)
    require "script/model/affix/AllStarAffixModel"
    affix[4] = AllStarAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("4", 1)
    
    printTable("名将属性",affix[4])
    --天命属性
    RecordTime("5", 0)
    require "script/model/affix/DestinyAffixModel"
    affix[5] = DestinyAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("5", 1)
    
    printTable("天命属性",affix[5])
    --时装属性
    RecordTime("6", 0)
    require "script/model/affix/DressAffixModel"
    affix[6] = DressAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("6", 1)
    
    printTable("时装属性",affix[6])
    --装备属性
    RecordTime("7", 0)
    require "script/model/affix/EquipAffixModel"
    affix[7] = EquipAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("7", 1)
    
    printTable("装备属性",affix[7])
    --战魂属性
    RecordTime("8", 0)
    require "script/model/affix/FightSoulAffixModel"
    affix[8] = FightSoulAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("8", 1)
    
    printTable("战魂属性",affix[8])
    --神兵属性
    RecordTime("9", 0)
    require "script/model/affix/GodWeaponAffixModel"
    affix[9] = GodWeaponAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("9", 1)
    
    printTable("神兵属性",affix[9])
    --宝物属性
    RecordTime("10", 0)
    require "script/model/affix/TreasAffixModel"
    affix[10] = TreasAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("10", 1)
    
    printTable("宝物属性",affix[10])
    --羁绊属性
    RecordTime("11", 0)
    require "script/model/affix/UnionAffixModel"
    affix[11] = UnionAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("11", 1)
    
    printTable("羁绊属性",affix[11])
    --TODO : 缓存，提出来
    if isOnFormation then
        --神兵录属性
        RecordTime("12", 0)
        require "script/model/affix/GodWeaponBookAffixModel"
        affix[12] = GodWeaponBookAffixModel.getAffixByHid(p_heroInfo.hid)
        RecordTime("12", 1)
        
        printTable("神兵录属性",affix[12])
        --宠物属性
        RecordTime("13", 0)
        require "script/model/affix/PetAffixModel"
        affix[13] = PetAffixModel.getAffixByHid(p_heroInfo.hid)
        RecordTime("13", 1)
        
        printTable("宠物属性",affix[13])
        -- 阵法属性
        RecordTime("14", 0)
        require "script/model/affix/WarfAffixModel"
        affix[14] = WarfAffixModel.getAffixByHid(p_heroInfo.hid)
        RecordTime("14", 1)
        
        printTable("阵法属性",affix[14])
        --第二套小伙伴
        RecordTime("15", 0)
        require "script/model/affix/SecondFriendAffixModel"
        affix[15] = SecondFriendAffixModel.getAffixByHid()
        RecordTime("15", 1)
        
        printTable("第二套小伙伴",affix[15])
        --时装屋属性
        RecordTime("16", 0)
        require "script/model/affix/DressRoomAffixModel"
        affix[16] = DressRoomAffixModel.getAffixByHid(p_heroInfo.hid)
        RecordTime("16", 1)
        
        printTable("时装屋属性",affix[16])
        --忠义厅属性
        RecordTime("17", 0)
        require "script/model/affix/LoyaltyAffixModel"
        affix[17] = LoyaltyAffixModel.getAffixByHid(p_heroInfo.hid)
        RecordTime("17", 1)
        
        printTable("忠义厅属性",affix[17])
        --时装套装
        RecordTime("18", 0)
        require "script/model/affix/FashionSuitAffixModel"
        affix[18] = FashionSuitAffixModel.getAffixByHid(p_heroInfo.hid)
        RecordTime("18", 1)
        
        printTable("时装套装",affix[18])
        --锦囊
        RecordTime("19", 0)
        require "script/ui/pocket/PocketData"
        affix[19] = PocketData.getPocketFightPower(p_heroInfo.hid)
        RecordTime("19", 1)
    	
        --宠物图鉴
        RecordTime("20", 0)
        require "script/ui/pet/PetData"
    	affix[20] = PetData.getExtenseAffixes()
        RecordTime("20", 1)

        --第二觉醒属性
        RecordTime("21", 0)
        require "script/model/affix/SecondAwakeAffix"
        affix[21] = SecondAwakeAffix.getAffixByHid(p_heroInfo.hid)
        RecordTime("21", 1)

        --称号属性加成
        RecordTime("22", 0)
        require "script/ui/title/TitleData"
        affix[22] = TitleData.getGotTitleAttrInfo()
        RecordTime("22", 1)

        --兵符录属性
        RecordTime("23", 0)
        require "script/ui/tally/preview/TallyPreviewData"
        affix[23] = TallyPreviewData.getAddAffixMap(p_heroInfo.hid)
        RecordTime("23", 1)

        --军团科技大厅
        RecordTime("24", 0)
        require "script/ui/guild/guildskill/GuildSkillData"
        affix[24] = GuildSkillData.getGuildSkillAttrInfo()
        RecordTime("24", 1)

        --时装解锁属性
        RecordTime("25", 0)
        require "script/model/affix/DressAffixModel"
        affix[25] = DressAffixModel.getUnLockAffix()
        RecordTime("25", 1)

        --战车属性
        RecordTime("26", 0)
        require "script/ui/chariot/ChariotMainData" 
        affix[26] = ChariotMainData.getChariotAllAttrInfo()
        RecordTime("26", 1)

        --武将幻化
        require "script/ui/turnedSys/HeroTurnedData" 
        affix[27] = HeroTurnedData.getAllTurnAttrInfo()
    end
    --主角星魂
    RecordTime("28", 0)
    require "script/model/affix/AthenaAffixModel"
    affix[28] = AthenaAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("28", 1)
    
    --丹药属性
    RecordTime("29", 0)
    require "script/model/affix/PillAffixModel"
    affix[29] = PillAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("29", 1)

    --兵符属性
    RecordTime("30", 0)
    require "script/model/affix/TallyAffixModel"
    affix[30] = TallyAffixModel.getAffixByHid(p_heroInfo.hid)
    RecordTime("30", 1)
    
    --称号属性加成
    RecordTime("31", 0)
    require "script/ui/title/TitleData"
    affix[31] = TitleData.getEquipTitleAttrInfoByHid(p_heroInfo.hid)
    RecordTime("31", 1)
    
    --武将天命战斗力加成
    RecordTime("32", 0)
    require "script/ui/redcarddestiny/RedCardDestinyData"
    affix[32] = RedCardDestinyData.getTotalAttForFightForce(p_heroInfo)
    RecordTime("32", 1)

    printTable("["..p_heroInfo.htid.."] affix :", affix)

    --TODO: TABLE INSERT kv
    local heroAffix = {}
    for i,v in pairs(affix) do
        for id,value in pairs(v) do
            if heroAffix[tonumber(id)] == nil then
                heroAffix[tonumber(id)] = value
            else
                heroAffix[tonumber(id)] = heroAffix[tonumber(id)] + value
            end
        end
    end
    return heroAffix
end


--[[
	@des: 根据属性字段得到英雄属性id
	@parm: string-属性字段
	@ret: int-属性id  
--]]
function getHeroAffixIdByDesStr( p_AffixStr )
    local affixDes = {
        -- 生命id
        base_hp                = 1,
        -- 统帅
        base_command           = 6,
        -- 武将基础武力
        base_strength          = 7,
        -- 武将基础智力
        base_intelligence      = 8,
        -- 武将基础通用攻击
        base_general_attack    = 9,
        -- 英雄基础物理攻击
        base_physical_attack   = 2,
        -- 英雄基础魔法攻击
        base_magic_attack      = 3,
        -- 英雄基础物理防御
        base_physical_defend   = 4,
        -- 英雄基础魔法防御
        base_magic_defend      = 5,
        -- 英雄基础最终伤害
        base_damage            = 29,
        -- 英雄基础最终免伤
        base_ignore_damage     = 30,
        -- 武将暴击率基础值
        base_critical          = 26,
        -- 武将暴击伤害倍数
        base_critical_multiple = 75,
        -- 武将基础命中
        base_hit               = 21,
        -- 武将基础闪避
        base_dodge             = 28,
        -- 武将基础格挡率
        base_block             = 27,
    }
    return affixDes[p_AffixStr]
end

--[[
	@des  :计算武将本身属性和武将的等级以及进阶等级有关
	@parm :p_hid
	@ret  :属性tab
--]]
function getHeroAffix( p_hid )
    local heroInfo 	  = HeroModel.getHeroByHid(tostring(p_hid))
    local heroAffix   = getHeroAffixByInfo(heroInfo)
    return heroAffix
end

--[[
	@des 	: 根据武将信息得到武将属性
	@parm 	: p_heroInfo 后端武将信息结构
	@ret 	: {
		affixId => value
	}
--]]
function getHeroAffixByInfo( p_heroInfo )
    require "db/DB_Heroes"
    require "script/model/hero/HeroModel"
    require "script/model/hero/AffixConfig"
    local heroInfo 	  = p_heroInfo
    local dbInfo  = DB_Heroes.getDataById(heroInfo.htid)

    --@param p_affixNum 属性基础值
    --@param p_affixGrow 属性成长值
    local calculateAffix = function ( p_affixNum, p_affixGrow )
        --属性值总和 =基础值*(1+进阶基础值系数/10000*进阶次数) + int(进阶次数/200*成长值)*( 进阶初始等级*2+进阶间隔等级*(进阶次数-1) ) + (武将等级-1)*属性成长值/100
        --基础值 + 基础值*(1+进阶基础值系数/10000*进阶次数)
        local baseNum = tonumber(p_affixNum)
        local gropNum = tonumber(p_affixGrow)
        local level   = tonumber(heroInfo.level)
        local evolveLevel = tonumber(heroInfo.evolve_level)


        local retAffix = baseNum*(1 + dbInfo.advanced_base_coefficient/10000*evolveLevel)
        --int(进阶次数/200*成长值)*( 进阶初始等级*2+进阶间隔等级*(进阶次数-1) )
        retAffix = retAffix + (evolveLevel/200*gropNum)*(dbInfo.advanced_begin_lv*2+dbInfo.advanced_interval_lv*(evolveLevel-1) - 2)
        retAffix = retAffix + (level - 1)*gropNum/100
        return math.floor(retAffix)
    end

    local heroBaseAffix = getHeroBaseAffixByHtid(heroInfo.htid)

    local affix = {}
    -- base_hp				武将基础生命
    affix[getHeroAffixIdByDesStr("base_hp")]                = calculateAffix(tonumber(dbInfo.base_hp), tonumber(dbInfo.hp_grow))
    -- base_command			武将基础统帅
    affix[getHeroAffixIdByDesStr("base_command")]           = tonumber(dbInfo.base_command)
    -- base_strength		武将基础武力
    affix[getHeroAffixIdByDesStr("base_strength")]          = tonumber(dbInfo.base_strength)
    -- base_intelligence	武将基础智力
    affix[getHeroAffixIdByDesStr("base_intelligence")]      = tonumber(dbInfo.base_intelligence)
    -- base_general_attack	武将基础通用攻击
    affix[getHeroAffixIdByDesStr("base_general_attack")]    = calculateAffix(tonumber(dbInfo.base_general_attack), tonumber(dbInfo.general_attack_grow))
    -- base_physical_attack	武将基础物理攻击
    affix[getHeroAffixIdByDesStr("base_physical_attack")]   = calculateAffix(tonumber(dbInfo.base_physical_attack), tonumber(dbInfo.physical_attack_grow))
    -- base_magic_attack	武将基础法术攻击
    affix[getHeroAffixIdByDesStr("base_magic_attack")]      = calculateAffix(tonumber(dbInfo.base_magic_attack), tonumber(dbInfo.magic_attack_grow))
    -- base_physical_defend	武将基础物理防御
    affix[getHeroAffixIdByDesStr("base_physical_defend")]   = calculateAffix(tonumber(dbInfo.base_physical_defend), tonumber(dbInfo.physical_defend_grow))
    -- base_magic_defend	武将基础法术防御
    affix[getHeroAffixIdByDesStr("base_magic_defend")]      = calculateAffix(tonumber(dbInfo.base_magic_defend), tonumber(dbInfo.magic_defend_grow))
    -- base_damage			武将基础最终伤害
    affix[getHeroAffixIdByDesStr("base_damage")]            = tonumber(dbInfo.base_damage)
    -- base_ignore_damage	武将基础最终免伤
    affix[getHeroAffixIdByDesStr("base_ignore_damage")]     = tonumber(dbInfo.base_ignore_damage)
    -- 武将暴击率基础值
    affix[getHeroAffixIdByDesStr("base_critical")]          = tonumber(dbInfo.base_critical)
    -- 武将暴击伤害倍数
    affix[getHeroAffixIdByDesStr("base_critical_multiple")] = tonumber(dbInfo.base_critical_multiple)
    -- 武将基础命中
    affix[getHeroAffixIdByDesStr("base_hit")]               = tonumber(dbInfo.base_hit)
    -- 武将基础闪避
    affix[getHeroAffixIdByDesStr("base_dodge")]             = tonumber(dbInfo.base_dodge)
    -- 武将基础格挡率
    affix[getHeroAffixIdByDesStr("base_block")]             = tonumber(dbInfo.base_block)

    return affix
end



--[[
	@des:得到卡牌的基础属性
	@parm:p_htid
	@ret:{
		affixId => value
		...
	}
--]]
function getHeroBaseAffixByHtid( p_htid )
    local heroDBInfo  = DB_Heroes.getDataById(p_htid)
    local retTable = {}
    -- 生命id
    retTable[getHeroAffixIdByDesStr("base_hp")]                = tonumber(heroDBInfo.base_hp)
    -- 统帅
    retTable[getHeroAffixIdByDesStr("base_command")]           = tonumber(heroDBInfo.base_command)
    -- 武将基础武力
    retTable[getHeroAffixIdByDesStr("base_strength")]          = tonumber(heroDBInfo.base_strength)
    -- 武将基础智力
    retTable[getHeroAffixIdByDesStr("base_intelligence")]      = tonumber(heroDBInfo.base_intelligence)
    -- 武将基础通用攻击
    retTable[getHeroAffixIdByDesStr("base_general_attack")]    = tonumber(heroDBInfo.base_general_attack)
    -- 英雄基础物理攻击
    retTable[getHeroAffixIdByDesStr("base_physical_attack")]   = tonumber(heroDBInfo.base_physical_attack)
    -- 英雄基础魔法攻击
    retTable[getHeroAffixIdByDesStr("base_magic_attack")]      = tonumber(heroDBInfo.base_magic_attack)
    -- 英雄基础物理防御
    retTable[getHeroAffixIdByDesStr("base_physical_defend")]   = tonumber(heroDBInfo.base_physical_defend)
    -- 英雄基础魔法防御
    retTable[getHeroAffixIdByDesStr("base_magic_defend")]      = tonumber(heroDBInfo.base_magic_defend)
    -- 英雄基础最终伤害
    retTable[getHeroAffixIdByDesStr("base_damage")]            = tonumber(heroDBInfo.base_damage)
    -- 英雄基础最终免伤
    retTable[getHeroAffixIdByDesStr("base_ignore_damage")]     = tonumber(heroDBInfo.base_ignore_damage)
    -- 武将暴击率基础值
    retTable[getHeroAffixIdByDesStr("base_critical")]          = tonumber(heroDBInfo.base_critical)
    -- 武将暴击伤害倍数
    retTable[getHeroAffixIdByDesStr("base_critical_multiple")] = tonumber(heroDBInfo.base_critical_multiple)
    -- 武将基础命中
    retTable[getHeroAffixIdByDesStr("base_hit")]               = tonumber(heroDBInfo.base_hit)
    -- 武将基础闪避
    retTable[getHeroAffixIdByDesStr("base_dodge")]             = tonumber(heroDBInfo.base_dodge)
    -- 武将基础格挡率
    retTable[getHeroAffixIdByDesStr("base_block")]             = tonumber(heroDBInfo.base_block)
    return retTable
end

--[[
	@des:得到武将的基础天赋属性
	@parm:p_htid 武将tid
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getHeroBaseTalentAffixByHtid( p_htid )
    local dbInfo = DB_Heroes.getDataById(p_htid)
    local awakeIds = string.split(dbInfo.awake_id, ",")
    local retTable = {}
    for k,v in pairs(awakeIds) do
        local affixs = getAffixByTelentId(v)
        for k1,v1 in pairs(affixs) do
            if retTable[k1] == nil then
                retTable[k1] = v1
            else
                retTable[k1] = retTable[k1] + v1
            end
        end
    end
    return retTable
end

--[[
	@des:得到武将的天赋属性
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getHeroTalentAffixByHid( p_hid )
    local heroInfo 	= HeroModel.getHeroByHid(tostring(p_hid))
    local retTable  = getHeroTalentAffixByInfo(heroInfo)
    return retTable
end

--[[
    @des:得到武将开启的天赋
    @ret:{}
--]]
function getOpenTalentAffixIds( p_heroInfo )
    local telentIds = {}
    local heroInfo       = p_heroInfo
    local heroDBInfo  = DB_Heroes.getDataById(heroInfo.htid)
    --强化等级
    local level       = tonumber(heroInfo.level)
    --进阶等级
    local evolveLevel = tonumber(heroInfo.evolve_level)
    local awakeIds = string.split(heroDBInfo.grow_awake_id, ",")
    local retTable = getHeroBaseTalentAffixByHtid(heroInfo.htid)
    for k,v in pairs(awakeIds) do
        local values = string.split(v, "|")
        if not table.isEmpty(values) then
            local needType = tonumber(values[1])
            local needLevel = tonumber(values[2])
            local telentId = tonumber(values[3])
            if (needType == 1 and level >= needLevel) or (needType == 2 and evolveLevel >= needLevel) then
                table.insert(telentIds, telentId)
            end
        end
    end
    --装备的天赋id
    if p_heroInfo.masterTalent then
        for k,v in pairs(p_heroInfo.masterTalent) do
            table.insert(telentIds, v)
        end
    end
    --天命天赋
    local destinyAwake = string.split(heroDBInfo.destinyAwake, ",")
    local destiny = tonumber(heroInfo.destiny) or 0
    for k,v in pairs(destinyAwake) do
        local vInfo = string.split(v, "|")
        needNum = tonumber(vInfo[1])
        awakeId = tonumber(vInfo[2])
        if destiny >= needNum then
            table.insert(telentIds, awakeId)
        end
    end
    return telentIds
end

--[[
	@des:得到武将的天赋属性
	@parm: p_hid 武将信息
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getHeroTalentAffixByInfo( p_heroInfo )
    local heroInfo 	  = p_heroInfo
    local retTable = getHeroBaseTalentAffixByHtid(heroInfo.htid)
    local telentIds = getOpenTalentAffixIds(heroInfo)
    for k,v in pairs(telentIds) do
        local affixs = getAffixByTelentId(v)
        for k1,v1 in pairs(affixs) do
            if retTable[k1] == nil then
                retTable[k1] = v1
            else
                retTable[k1] = retTable[k1] + v1
            end
        end 
    end
    return retTable
end

--[[
	@des:得到天赋的属性
	@parm: 天赋id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByTelentId( p_id )
    require "db/DB_Awake_ability"
    local awakeInfo 	= DB_Awake_ability.getDataById(p_id)
    local affixIds  	= string.split(awakeInfo.attri_ids, ",")
    local affixValus 	= string.split(awakeInfo.attri_values, ",")

    local retTable 		= {}
    for k,v in pairs(affixIds) do
        retTable[tonumber(v)] =  tonumber(affixValus[k])
    end
    return retTable
end


--[[
	@des 	: 得到武将觉醒能力属性
	@parm 	: p_heroInfo
--]]
function getHeroAwakenAffixByHeroInfo( p_heroInfo )

    --得到武将的觉醒能力和开启的进阶等级
    local heroDBInfo = DB_Heroes.getDataById(p_heroInfo.htid)
    local configAwakenMap = {}
    local awakenConfigs = string.split(heroDBInfo.hero_copy_id, ",")
    for i=1,#awakenConfigs do
        local infos                          = string.split(awakenConfigs[i], "|")
        -- 去掉武将列传相关 20160407 lgx
        -- local heroCopyId                     = tonumber(infos[1])	--武将列传副本id
        -- local pos                            = tonumber(infos[2])	--觉醒能力位置
        local pos                            = tonumber(i)          --觉醒能力位置
        local neeedPotential                 = tonumber(infos[1])   --开启需要武将品质
        local needEvolveLevel                = tonumber(infos[2])	--开启需要进阶等级
        configAwakenMap[pos]			     = {}
        configAwakenMap[pos].neeedPotential  = neeedPotential
        configAwakenMap[pos].needEvolveLevel = needEvolveLevel
        -- configAwakenMap[pos].heroCopyId      = heroCopyId
    end

    local affixTable = {}
    local heroInfo = p_heroInfo
    if(heroInfo["talent"] ~= nil and heroInfo["talent"]["confirmed"] ~= nil) then
        for key,value in pairs(heroInfo["talent"]["confirmed"]) do
            local isSealed = false
            if(heroInfo["talent"]["sealed"] ~= nil and heroInfo["talent"]["sealed"][key] ~= nil and heroInfo["talent"]["sealed"][key] ~= 0) then
                isSealed = true
            end
            --到达觉醒能力开启等级
            if tonumber(heroDBInfo.potential) > configAwakenMap[tonumber(key)].neeedPotential or (tonumber(heroDBInfo.potential) == configAwakenMap[tonumber(key)].neeedPotential and tonumber(p_heroInfo.evolve_level) >= configAwakenMap[tonumber(key)].needEvolveLevel) then
                --没有被锁定
                if(isSealed == false) then
                    require "db/DB_Hero_refreshgift"
                    local talentInfo = DB_Hero_refreshgift.getDataById(value)
                    if(talentInfo ~= nil) then
                        local attri_ids  = string.split(talentInfo.attri_ids, "|")
                        if(table.count(attri_ids) >=2) then
                            local affixId    = tonumber(attri_ids[1])
                            local affixValue = tonumber(attri_ids[2])
                            if(affixTable[affixId] == nil) then
                                affixTable[affixId] = tonumber(affixValue)
                            else
                                affixTable[affixId] = affixTable[affixId] + tonumber(affixValue)
                            end
                        end
                    end
                end
            end
        end
    end
    return affixTable
end


--[[
	@des 	:得到英雄的觉醒属性
	@parm 	:hid
	@ret  	:属性table
--]]
function getHeroAwakenAffix(p_hid)
    local heroInfo = HeroModel.getHeroByHid(tostring(p_hid))
    local affixTable = getHeroAwakenAffixByHeroInfo(heroInfo)
    return affixTable
end

