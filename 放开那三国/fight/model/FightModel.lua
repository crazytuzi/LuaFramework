-- FileName: FightModel.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗武将信息模型


module("FightModel", package.seeall)

local _fightConfig = { 
    copyId     = nil,	--副本id
    baseId     = nil,	--据点id
    level      = nil,	--等级
    bType      = nil,	--战斗类型
    bModel     = nil, 	--战斗模式
    bIndex     = nil,	--战斗回合次数
    isFirst    = nil,   --是否首次战斗次据点
    autoBattle = nil,   --是否自动战斗
    formation  = nil,   --玩家整容阵型
    battleFmt  = nil,   --当前战斗阵型
    result     = nil,   --战斗结果
    silver     = nil,   --银币
    exp        = nil,   --经验
    soul       = nil,   --战魂
    doBattleInfo = nil, --战斗回调信息
    deadEffs  = {},
}

local _itemArray = {}
local _heroArray = {}

--[[
    @des:   初始化本场战斗数据
    @parm:  pCopyId 副本id
    @parm:  pBaseId 据点id
    @parm:  pLevel  战斗难度等级
    @parm:  pType   战斗类型
--]]
function initModel( pCopyId, pBaseId, pLevel, pType )
    _fightConfig = {}
    _fightConfig.deadEffs  = {}
	_fightConfig.copyId = pCopyId
	_fightConfig.baseId = pBaseId
	_fightConfig.level  = pLevel or 0
	_fightConfig.bType	= pType or BattleType.NORMAL
    _fightConfig.autoBattle = true
    _itemArray = {}
    _heroArray = {}
    --初始化部队信息
    initArmyArray()
    --初始化阵容
    initFormation()
    --是否第一战斗此据点
    isFirstEnter()
    printTable("_fightConfig",_fightConfig)
end

--[[
    @des: 得到当前据点部队
--]]
function initArmyArray()
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(_fightConfig.baseId)
    local levelStr = nil
    if(_fightConfig.level==1) then
        levelStr = "simple"
    elseif(_fightConfig.level==2) then
        levelStr = "normal"
    elseif(_fightConfig.level==3) then
        levelStr = "hard"
    else
        levelStr = "simple"
    end
    local armyIds = nil
    if(_fightConfig.level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
        if armyIds == nil then
            armyIds = sh["army_ids_" .. levelStr]
        end
    else
        armyIds = sh["army_ids_" .. levelStr]
    end
    local armyIdArray = lua_string_split(armyIds,",")
    _fightConfig.armyIds = armyIdArray
    printTable("_fightConfig.armyIds", _fightConfig.armyIds)
end

--[[
    @des:初始化阵容
--]]
function initFormation()
    _fightConfig.formation = DataCache.getFormationInfo()
    if _fightConfig.formation == nil then
        _fightConfig.formation = getHerolist()
    end
end

--[[
    @des:判断是否第一次进入
--]]
function isFirstEnter()
    local baseId = _fightConfig.baseId
    local level  = _fightConfig.level
    if baseId and level then
        require "script/model/DataCache"
        local normalCopyList = DataCache.getNormalCopyData()
        local currentStar = 0
        for cNum=1,#normalCopyList do
            local copy_info = normalCopyList[cNum].va_copy_info
            if(copy_info~=nil and copy_info.progress~=nil and copy_info.progress["" .. baseId]~=nil)then
                currentStar = tonumber(copy_info.progress["" .. baseId])==nil and 0 or tonumber(copy_info.progress["" .. baseId])-2
                break
            end
        end
        if((currentStar>=level and level>0))then
            _fightConfig.isFirst = false
        else
            _fightConfig.isFirst = true
        end
        return _fightConfig.isFirst
    end
    return false
end


--[[
    @des:判断是否通过该副本
--]]
function getIsFirstEnter( ... )
    return _fightConfig.isFirst
end

--[[
	@des: 设置战斗模式
	ret:  number 
--]]
function setbModel( pModel )
	_fightConfig.bModel = pModel
end

--[[
	@des: 得到战斗模式
	ret:  number 
--]]
function getbModel()
	return _fightConfig.bModel or BattleModel.COPY
end

--[[
    @des: 设置战斗模式
    ret:  number 
--]]
function setbType( pType )
    _fightConfig.bType = pType
end

--[[
    @des: 得到战斗模式
    ret:  number 
--]]
function getbType()
    return _fightConfig.bType or BattleType.NORMAL
end

--[[
    @des: 设置副本id
    ret:  number 
--]]
function setCopyId( pCopyId )
    _fightConfig.copyId = pCopyId
end

--[[
    @des: 得到副本id
    ret:  number 
--]]
function getCopyId()
    return _fightConfig.copyId
end

--[[
    @des: 设置据点id
    ret:  number 
--]]
function setBaseId( pBaseId )
    _fightConfig.baseId = pbaseId
end

--[[
    @des: 得到据点id
    ret:  number 
--]]
function getBaseId()
    return _fightConfig.baseId
end

--[[
    @des: 得到据点等级
    ret:  number 
--]]
function getBaseLv()
    return tonumber(_fightConfig.level)
end

--[[
    @des: 设置战斗托管
    ret:  number 
--]]
function setAutoBattle( pAuto )
    _fightConfig.autoBattle = pAuto
end

--[[
    @des: 得到战斗托管
    ret:  number 
--]]
function getAutoBattle()
    return _fightConfig.autoBattle
end

--[[
    @des: 设置战斗托管
    ret:  number 
--]]
function setFormation( pFormation )
    _fightConfig.formation = pFormation
end

--[[
    @des: 得到战斗托管
    ret:  number 
--]]
function getFormation()
    return _fightConfig.formation
end

--[[
    @des:得到玩家阵营
--]]
function getPalyerFormation()
    local fmt = nil
    local bType = getbType()
    if getBaseLv() ~= 0 or bType ~= BattleType.NORMAL then
        fmt = getFormation()
    else
        fmt = getHerolist()
    end
    return fmt
end

--[[
    @des:得到当前战斗阵型
--]]
function getBattleFormation( )
    return _fightConfig.battleFmt
end

--[[
    @des:设置当前战斗阵型
--]]
function setBattleFormation( pFmt )
    _fightConfig.battleFmt = pFmt
end

--[[
    @des: 得到当前据点部队数量
    ret:  number 
--]]
function getArmyCount()
    return table.count(_fightConfig.armyIds)
end

--[[
    @des:添加战斗获得物品
    @parm:pItemArray 物品组
--]]
function addItem( pItemInfo )
    if pItemInfo then
        for k,v in pairs(pItemInfo) do
            table.insert(_itemArray, v)
        end
    end
end

--[[
    @des:得到物品列表
--]]
function getItemArray()
    if _itemArray then
        return _itemArray
    else
        return {}
    end
end

--[[
    @des:添加战斗获得武将
    @parm:pItemArray 武将组
--]]
function addHero( pHeroInfo )
    if pHeroInfo then
        for k,v in pairs(pHeroInfo) do
            table.insert(_heroArray, v)
        end
    end
end

--[[
    @des:得到武将
--]]
function getHeroArray()
    if _heroArray then
        return _heroArray
    else
        return {}
    end
end

--[[
    @des:得到战斗结果
    @ret: true 战斗胜利 false 失败或平局
--]]
function getResult()
    local result = _fightConfig.result
    if  string.upper(result) == "E" or string.upper(result) == "F" then
        return false
    else
        return true
    end    
end

--[[
    @des:设置战斗结果
    @parm: pResult 战斗结果
--]]
function setResult( pResult )
    _fightConfig.result = pResult
end

--[[
    @des:得到银币
--]]
function getSilver()
    return _fightConfig.sliver or 0
end
--[[
    @des:设置银币
--]]
function addSilver( pNum )
    local num = tonumber(pNum) or 0
    _fightConfig.sliver = _fightConfig.sliver or 0
    _fightConfig.sliver = _fightConfig.sliver + num
end
--[[
    @des:经验数量
--]]
function getExpNum()
    return _fightConfig.exp or 0
end
--[[
    @des:设置经验数量
--]]
function addExpNum( pNum )
    local num = tonumber(pNum) or 0
    _fightConfig.exp = _fightConfig.exp or 0
    _fightConfig.exp = _fightConfig.exp + num
end
--[[
    @des:得到战魂
--]]
function getSoul()
    return _fightConfig.soul or 0
end
--[[
    @des:设置战魂
--]]
function addSoul( pNum )
    local num = tonumber(pNum) or 0
    _fightConfig.soul = _fightConfig.soul or 0
    _fightConfig.soul = _fightConfig.soul + num
end

--[[
    @des:设置战斗结束数据
--]]
function setDoBattleInfo( pBattleInfo )
    _fightConfig.doBattleInfo = pBattleInfo
end

--[[
    @des:得到战斗返回信息
--]]
function getDoBattleInfo()
    return _fightConfig.doBattleInfo
end

--[[
    @des:得到死亡掉落卡牌
--]]
function isDropCard( pHid )
    local doBattleInfo = getDoBattleInfo()
    if doBattleInfo then
        if doBattleInfo.reward.hero then
            for k,v in pairs(doBattleInfo.reward.hero) do
                if tonumber(v.mstId) == tonumber(pHid) then
                    return true
                end
            end
        end
    end
    return false
end

--[[
    @des:npc战斗中需要主角位置
--]]
function getHerolist()
    local armyIndex = FightMainLoop.getArmyIndex()
    local armyInfo = getArmyInfoByIndex(armyIndex)
    local mainHid = HeroModel.getNecessaryHero().hid
    local npcFmt = {}
    local bType  = FightModel.getbType()
    if getBaseLv() == 0 and  bType == BattleType.NORMAL then
        local npcTeam = DB_Team.getDataById(armyInfo.monster_group_npc)
        local monsterIdArray = lua_string_split(npcTeam.monsterID,",")
        for i=0,5 do
            if tonumber(monsterIdArray[i+1]) == 1 then
                npcFmt[i] = tonumber(mainHid)
            else
                npcFmt[i] = tonumber(monsterIdArray[i+1] or 0)
            end
        end
    else
        local fmtAry = FightModel.getFormation()
        for k,v in pairs(fmtAry) do
            if tonumber(v) == tonumber(mainHid) then
                npcFmt[k] = tonumber(mainHid)
                break
            end
        end
    end
    return npcFmt
end

--[[
    @des:根据部队索引得到部队id
    @parm:pArmyIndex 部队索引
--]]
function getArmyIdByIndex( pArmyIndex )
    local armyIdArray = _fightConfig.armyIds
    printTable("armyIdArray", armyIdArray)
    print("pArmyIndex", pArmyIndex)
    return armyIdArray[pArmyIndex]
end

--[[
    @des:根据部队索引得到部队id
    @parm:pArmyIndex 部队索引
--]]
function getArmyInfoByIndex( pArmyIndex )
    local armyId =  getArmyIdByIndex(pArmyIndex)
    require "db/DB_Army"
    local armyInfo = DB_Army.getDataById(armyId)
    return armyInfo
end

--[[
    @des:得到部队hid数组
--]]
function getHidsByArmyIndex( pArmyIndex )
    local armyInfo = getArmyInfoByIndex(pArmyIndex)
    if not armyInfo.monster_group then
      error("error armyInfo")
      return
    end
    local teamInfo = DB_Team.getDataById(armyInfo.monster_group)
    local groups = string.split(teamInfo.monsterID, ",")
    return  groups
end

--[[
	@des: 得到战斗背景图片名称
	@parm:battleType
--]]
function getBgName()
	local bgName = nil
    local names = nil
	if _fightConfig.bModel == BattleModel.COPY then
		require "db/DB_Stronghold"
		bgName = DB_Stronghold.getDataById(_fightConfig.baseId).fire_scene
        names = string.sub(bgName,1,string.len(bgName)-4)
	end
    print("getBgName",names)
	return bgName 
end

--[[
    @des:得到据点初始位置
--]]
function getStartPos()
    require "db/DB_Stronghold"
    if not _fightConfig.baseId then
        return 0
    end
    local baseInfo = DB_Stronghold.getDataById(_fightConfig.baseId)
    if not baseInfo.startposition then
        return 1
    else
        return tonumber(baseInfo.startposition)
    end
end

--[[
    @des:得到战斗的背景音乐
--]]
function getFightMusic()
    require "db/DB_Stronghold"
    if _fightConfig.baseId then
        local baseInfo = DB_Stronghold.getDataById(_fightConfig.baseId)
        return baseInfo.fire_music
    end
    return "music01.mp3"
end

--[[
    @des:添加死亡特效
--]]
function addDeadEff( pEffect )
    table.insert(_fightConfig.deadEffs, pEffect)
end

--[[
    @des:得到所有死亡特效
--]]
function getDeadEffs( ... )
    return _fightConfig.deadEffs or {}
end

--[[
    @des: 是否能跳过战斗
    @ret: 返回true 则可以跳过本次战斗，否则不能跳过
--]]
function canSkipBattle()
    require "db/DB_Vip"
    require "db/DB_Normal_config"
    require "script/model/user/UserModel"
    local userVipLevel  = tonumber(UserModel.getVipLevel())
    local userLevel     = UserModel.getHeroLevel()
    local userVipInfo   = DB_Vip.getDataById(tostring(vipLevel))
    local configInfo    = DB_Normal_config.getDataById("1")

    local needVipLevel  = 0
    local needUserLevel = 0
    local message       = nil
    local skipResult    = nil
    local copyType      = FightModel.getbType()
    if(copyType == BattleType.NORMAL) then
        --普通副本
        local i = 1
        for k,v in pairs(DB_Vip.Vip) do
            local vInfo = DB_Vip.getDataById(tostring(i))
            if(tonumber(vInfo["isSkipFight"]) ~= 0) then
                needVipLevel     = tonumber(vInfo.level)
                needUserLevel    = tonumber(vInfo["isSkipFight"])
                break
            end
            i = i+1
        end
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("key_1181").. needUserLevel .. GetLocalizeStringBy("key_2067")
        if(userLevel >= needUserLevel and userVipLevel >= needVipLevel) then
            skipResult = true
        else
            AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(copyType == BattleType.ELITE) then
        --精英副本
        local skipFightInfo = string.split(configInfo.eliteisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(copyType == BattleType.ACTIVITY) then
        --活动副本
        local skipFightInfo = string.split(configInfo.activitycopyisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(copyType == BattleType.TOWER) then
        --试炼塔
        local skipFightInfo = string.split(configInfo.TesttowerisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(copyType == BattleType.MYSICAL_FLOOR) then
        --神秘层
        local skipFightInfo = string.split(configInfo.MysicalTowerisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(copyType == BattleType.HERO) then
        -- 武将列传
        local skipFightInfo = string.split(configInfo.GeneralsbiographyisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            AnimationTip.showTip(message)
            skipResult = false
        end
    else
        skipResult = true
    end
    return skipResult
end

