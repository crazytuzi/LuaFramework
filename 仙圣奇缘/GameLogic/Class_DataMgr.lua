--------------------------------------------------------------------------------------
-- 文件名:	DataMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	游戏数据管理器
-- 应  用:  
---------------------------------------------------------------------------------------

--创建CDataMgr类
Class_DataMgr = class("Class_DataMgr")
Class_DataMgr.__index = Class_DataMgr

--[[
数据层使用规范
1，可以使用通用接口 getCsvConfig()、getCsvConfigByOneKey()、getCsvConfigByTwoKey这三个接口访问策划数据表
2，也可以使用单独的每个CSV脚本的接口，如果新建CSV脚本则自己复制原来的接口代码，替换下名字即可
	a，单Key脚本，参考getMapEctypeSubCsv()
	b，双Key脚本，参考getCardBaseCsv()
	c，以Level为Key的脚本，需要判断下界和上界，参考getCardEvolutePropCsvMaxLevel(),getCardEvolutePropCsv
3，上层逻辑，返回对象命名规范
    a，每个接口已经定义了取出来的对象是什么东西，在上层逻辑命名的时候按照接口定义的来，按照下面规范来
	b，比如:
		local CSV_CardBase = g_DataMgr:getCsvConfigByTwoKey("CardBase", 1, 1)
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(1, 1)
	
]]--

function Class_DataMgr:getCsvConfig(strCsvName)
	local tbCsv = ConfigMgr[strCsvName]
	if not tbCsv then
		cclog("===Class_DataMgr:getCsvConfig error ==="..strCsvName)
		return nil
	end
	
	return tbCsv
end

function Class_DataMgr:getCsvConfigByOneKey(strCsvName, nMainKey)
	local tbCsv = ConfigMgr[strCsvName]
	if not tbCsv then
		cclog("===Class_DataMgr:getCsvConfigByOneKey error ==="..strCsvName)
		return nil
	end
	
	local nMainKey = nMainKey or 0
    tbCsv = tbCsv[nMainKey]
    if not tbCsv then
		cclog(strCsvName.."===Class_DataMgr:getCsvConfigByOneKey error===nMainKey==="..nMainKey)
		return ConfigMgr[strCsvName.."_"][0]
    end
	
    return tbCsv
end

function Class_DataMgr:getCsvConfigByTwoKey(strCsvName, nMainKey, nSubKey)
	local tbCsv = ConfigMgr[strCsvName]
	if not tbCsv then
		cclog("===Class_DataMgr:getCsvConfigByTwoKey error ==="..strCsvName)
		return nil
	end
	
	local nMainKey = nMainKey or 0
	local nSubKey = nSubKey or 0
	
    tbCsv = tbCsv[nMainKey]
    if not tbCsv then
		cclog(strCsvName.."===Class_DataMgr:getCsvConfigByTwoKey error===nMainKey==="..nMainKey)
		if ConfigMgr[strCsvName.."_"][0][0] then
			return ConfigMgr[strCsvName.."_"][0][0]
		else
			return ConfigMgr[strCsvName.."_"][0][1]
		end
    end
	
	tbCsv = tbCsv[nSubKey]
    if not tbCsv then
		cclog(strCsvName.."===Class_DataMgr:getCsvConfigByTwoKey error===nMainKey==="..nMainKey.."===nSubKey==="..nSubKey)
		if ConfigMgr[strCsvName.."_"][0][0] then
			return ConfigMgr[strCsvName.."_"][0][0]
		else
			return ConfigMgr[strCsvName.."_"][0][1]
		end
    end

    return tbCsv
end

----适用于key_allrowkey, key_clientrowkey, unikey1_unikey2
--获取firstkey索引的数据
function Class_DataMgr:getCsvConfig_FirstKeyData(strCsvName, FirstKey)
	local tbCsv = ConfigMgr[strCsvName]
	if not tbCsv then
		cclog("===Class_DataMgr:getCsvConfig_FirstKeyData error ==="..strCsvName)
		return nil
	end
	
	local FirstKey = FirstKey or 0
	
    tbCsv = tbCsv[FirstKey]
    if not tbCsv then
		cclog(strCsvName.."===Class_DataMgr:getCsvConfig_FirstKeyData error===nMainKey==="..FirstKey)
        return ConfigMgr[strCsvName.."_"][0]
    end

    return tbCsv
end

----适用于key_allrowkey, key_clientrowkey, unikey1_unikey2
--获取firstkey和Secondkey的数据
function Class_DataMgr:getCsvConfig_FirstAndSecondKeyData(strCsvName, FirstKey, SecondKey)
	local FirstKey = FirstKey or 0
	local SecondKey = SecondKey or 0

    local tbCsv, tbCsv1, tbCsv2 = {}, nil, nil
	
    local tbCsv1 = ConfigMgr[strCsvName][FirstKey]
	if(not tbCsv1)then
		cclog("===Class_DataMgr"..strCsvName.."======error ===")
		tbCsv1 = ConfigMgr[strCsvName.."_"][0]
	end
	
    tbCsv2 = tbCsv1[SecondKey]
	if(not tbCsv2)then
		cclog("===Class_DataMgr"..strCsvName.."======error ==="..SecondKey)
		if ConfigMgr[strCsvName.."_"][0][0] then 
            tbCsv2 = ConfigMgr[strCsvName.."_"][0][0]
        else
            tbCsv2 = ConfigMgr[strCsvName.."_"][0][1]
        end
	end

    for k, v in pairs(tbCsv1) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
    for k, v in pairs(tbCsv2) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 

	return tbCsv
end

----适用于key_allrowkey, key_clientrowkey, unikey1_unikey2
--获取FirstKey下secondkey索引的数组数据 ，
function Class_DataMgr:getCsvConfig_SecondKeyTableData(strCsvName,FirstKey)
	local tbCsv = ConfigMgr[strCsvName]
	if not tbCsv then
		cclog("===Class_DataMgr:getCsvConfig_SecondKeyTableData error ==="..strCsvName)
		return nil
	end
	
	local FirstKey = FirstKey or 0
	
    tbCsv = tbCsv[FirstKey]
    if not tbCsv then
		cclog(strCsvName.."===Class_DataMgr:getCsvConfig_SecondKeyTableData error===nMainKey==="..FirstKey)
		tbCsv = ConfigMgr[strCsvName.."_"][0]
    end

    local ret = {}
    for k, v in pairs(tbCsv) do
        if type(v) == "table" then ret[k] = v end
    end
    return ret
end

--单Key接口参考，副本子副本
function Class_DataMgr:getMapEctypeSubCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
    local tbCsv = ConfigMgr.MapEctypeSub[nConfigID]
    if not tbCsv then
       cclog("ConfigMgr:getMapEctypeSubCsv error ID "..nConfigID)
	   return ConfigMgr.MapEctypeSub_[0]
    end
    return tbCsv
end

--单Key接口参考，副本
function Class_DataMgr:getMapEctypeCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
    local tbCsv = ConfigMgr.MapEctype[nConfigID]
    if not tbCsv then
       cclog("ConfigMgr:getMapEctypeCsv error ID "..nConfigID)
	   return ConfigMgr.MapEctype_[0]
    end
    return tbCsv
end

--双Key接口参考，获取伙伴基本信息
function Class_DataMgr:getCardBaseCsv(nConfigID, nStarLevel)
	local nConfigID = nConfigID or 0
	local nStarLevel = nStarLevel or 0

    local tbCsv, tbCsv1, tbCsv2 = {}, nil, nil
	
    local tbCsv1 = ConfigMgr.CardBase[nConfigID]
	if(not tbCsv1)then
		cclog("===Class_DataMgr:getCardBaseCsv error ==="..nConfigID)
		tbCsv1 = ConfigMgr.CardBase_[0]
	end
	
    tbCsv2 = tbCsv1[nStarLevel]
	if(not tbCsv2)then
		cclog(nConfigID.."===Class_DataMgr:getCardBaseCsv error ==="..nStarLevel)
		tbCsv2 = ConfigMgr.CardBase_[0][0]
	end

    for k, v in pairs(tbCsv1) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
    for k, v in pairs(tbCsv2) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 

	return tbCsv
end

--Level Key接口参考，获取最大突破等级
function Class_DataMgr:getCardEvolutePropCsvMaxLevel()
    if not self.EvolutePropCsvMaxLevel then
        self.EvolutePropCsvMaxLevel = 0
        for k, v in pairs(ConfigMgr.CardEvoluteProp) do
		    if k > self.EvolutePropCsvMaxLevel then
			    self.EvolutePropCsvMaxLevel = k
		    end
        end
	end
    return self.EvolutePropCsvMaxLevel
end

--Level Key接口参考，获取伙伴突破的脚本配置
function Class_DataMgr:getCardEvolutePropCsv(nEvoluteLevel)
	local nEvoluteLevel = nEvoluteLevel or 0
	
	if nEvoluteLevel <= 0 then --判断nil和下界
		cclog("===Class_DataMgr:CardEvoluteProp error ==="..nEvoluteLevel)
		return ConfigMgr.CardEvoluteProp_[0]
	else
		local tbCsv = ConfigMgr.CardEvoluteProp[nEvoluteLevel]
		if not tbCsv then	--说明上界越界了
			return ConfigMgr.CardEvoluteProp[self:getCardEvolutePropCsvMaxLevel()]
		end
		return tbCsv
	end
end

function Class_DataMgr:getEctypeListByMapBaseID(nBigMapID)

	if not nBigMapID  then
        cclog("ConfigMgr.getEctypeListByMapBaseID error ID ")
		return nil
	end
	
	--初始化一下表格
	if(not self.tbEctypeData)then
		self.tbEctypeData = {}

		local tinsert = table.insert
		local t_MapEctypeNormal = ConfigMgr.MapEctype
		for key, v in pairs(t_MapEctypeNormal) do
			local nMapID = v.MapID
			
			if(not self.tbEctypeData[nMapID])then
				 self.tbEctypeData[nMapID] = {}
			end
			
			if(not self.tbEctypeData[nMapID])then
				self.tbEctypeData[nMapID]= {}
			end
			
			tinsert(self.tbEctypeData[nMapID], key)
		end
		
		local function sortMapEctypeByID(tbDataA, tbDataB)
		    return tbDataA < tbDataB
		end
		
		for key, tbValue in pairs(self.tbEctypeData) do
		    table.sort(tbValue, sortMapEctypeByID)	
		end
	end
	
    local tbCsv = self.tbEctypeData[nBigMapID]
    if not tbCsv then
       cclog("ConfigMgr.tbEctypeData error ID "..nBigMapID)
    end
	
    return tbCsv
end

-- 获取装备
function Class_DataMgr:getEquipCsv(nConfigID, nStarLevel)
	local nConfigID = nConfigID or 0
	local nStarLevel = nStarLevel or 0
	
    local tbCsv = ConfigMgr.Equip[nConfigID]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getEquipCsv error ==="..nConfigID)
		return ConfigMgr.Equip_[0][0]
	end

    tbCsv = tbCsv[nStarLevel]
   	if(not tbCsv)then
		cclog(nConfigID.."===Class_DataMgr:getEquipCsv==="..nStarLevel)
		return ConfigMgr.Equip_[0][0]
	end

	return tbCsv
end

-- 伙伴经验
function Class_DataMgr:getCardExpCsvExpMax(nLevel, bIsLeader)
	local nLevel = nLevel or 0
	
    local tbCsv = ConfigMgr.CardExp[nLevel]
   	if(not tbCsv )then
		cclog("===Class_DataMgr:getCardExpCsvExpMax error ==="..nLevel)
		if bIsLeader then
			return ConfigMgr.CardExp_[0].ExpMaxA
		else
			return ConfigMgr.CardExp_[0].ExpMaxB
		end
	end
	
	if bIsLeader then
		return tbCsv.ExpMaxA
	else
		return tbCsv.ExpMaxB
	end
end

-- 装备强化消耗最大等级
function Class_DataMgr:getEquipStrengthenCostCsvMaxLevel()
    if not self.nEquipStrengthenCostCsvMaxLevel then
        self.nEquipStrengthenCostCsvMaxLevel = 0
	    for k, v in pairs(ConfigMgr.EquipStrengthenCost) do
		    if k > self.nEquipStrengthenCostCsvMaxLevel then
			    self.nEquipStrengthenCostCsvMaxLevel = k
		    end
	    end
    end
	return self.nEquipStrengthenCostCsvMaxLevel
end

-- 装备强化消耗
function Class_DataMgr:getEquipStrengthenCostCsv(nStrengthenLevel)
	local nStrengthenLevel = nStrengthenLevel or 0

	if nStrengthenLevel <= 0 then	--判断nil和下界
		cclog("===Class_DataMgr:getEquipStrengthenCostCsv error ==="..nStrengthenLevel)
		return ConfigMgr.EquipStrengthenCost_[0]
	else
		local tbCsv = ConfigMgr.EquipStrengthenCost[nStrengthenLevel]
		if not tbCsv then	--说明上界越界了
			cclog("===Class_DataMgr:getEquipStrengthenCostCsv error ==="..nStrengthenLevel)
			return ConfigMgr.EquipStrengthenCost[self:getEquipStrengthenCostCsvMaxLevel()]
		end
		return tbCsv
	end
end


-- 异兽
function Class_DataMgr:getCardFateCsv(nConfigID, nLevel)
	local nConfigID = nConfigID or 0

    local tbCsv, tbCsv1, tbCsv2 = {}, nil, nil
	
    local tbCsv1 = ConfigMgr.CardFate[nConfigID] 
    if(not tbCsv1)then
   		cclog("===Class_DataMgr:getCardFateCsv error ==="..nConfigID)
		tbCsv1 = ConfigMgr.CardFate_[0]
	end
    tbCsv2 = tbCsv1[nLevel] 
    if(not tbCsv2)then
   		cclog(nConfigID.."===Class_DataMgr:getCardFateCsv error ==="..nLevel)
		tbCsv2 =  ConfigMgr.CardFate_[0][0]
	end

    for k, v in pairs(tbCsv1) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
    for k, v in pairs(tbCsv2) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
	return tbCsv
end

--异兽格子解锁
function Class_DataMgr:getCardFateReleaseCsvLevel(nPosIndex)
	local nPosIndex = nPosIndex or 0
	
    local tbCsv = ConfigMgr.CardFateRelease[nPosIndex] 
    if(not tbCsv)then
		cclog("===Class_DataMgr:getCardFateReleaseCsvLevel error ==="..nConfigID)
		return ConfigMgr.CardFateRelease_[0] 
	end
	return tbCsv.RealeaseLevel
end

-- 加载出阵伙伴个数控制脚本
function Class_DataMgr:getPlayerTudiPosConfigCsvOpenLevel()
	local tbCsv = ConfigMgr.PlayerTudiPosConfig 
	for k, v in ipairs(tbCsv) do  --注意如果是for k,v in pairs(tbCsv) do 则遍历的不对 k可能不是顺序走
		if (g_Hero:getMasterCardLevel() < tonumber(v.OpenLevel)) then
			return k - 1
		end
	end
	return 6
end

-- 返回技能数据
function Class_DataMgr:getSkillLightEffectCsv(nSkillID)
	local nSkillID = nSkillID or 0
	
    local tbCsv = ConfigMgr.SkillLightEffect[nSkillID] 
    if(not tbCsv  )then
		cclog("===Class_DataMgr:getSkillLightEffectCsv error ==="..nSkillID)
		return ConfigMgr.SkillLightEffect_[0] 
	end
	return tbCsv
end

-- 根据技能ID取伙伴技能基本数据
function Class_DataMgr:getSkillBaseCsv(nSkillID)
	local nSkillID = nSkillID or 0
	
    local tbCsv = ConfigMgr.SkillBase[nSkillID] 
    if(not tbCsv  )then
		cclog("===Class_DataMgr:getSkillBaseCsv error ==="..nSkillID)
		return ConfigMgr.SkillBase_[0] 
	end
	return tbCsv
end

--根据技能id和星级获取升级技能条件
function Class_DataMgr:getCardEvoluteSkillConditionCsv(nSkillID, nLevel)
	local nSkillID = nSkillID or 0
	local nLevel = nLevel or 0
	
    local tbCsv = ConfigMgr.CardEvoluteSkillCondition[nSkillID] 
    if(not tbCsv )then
		cclog(nSkillID.."===Class_DataMgr:getCardEvoluteSkillConditionCsv error ===")
		return ConfigMgr.CardEvoluteSkillCondition_[0] 
	end
    tbCsv = tbCsv[nLevel] 
    if(not tbCsv)then
		cclog(nSkillID.."===Class_DataMgr:getCardEvoluteSkillConditionCsv error nLevel ==="..nLevel)
		return ConfigMgr.CardEvoluteSkillCondition_[0] 
	end
	return tbCsv
end

--获取最大境界等级
function Class_DataMgr:getCardRealmLevelCsvMaxLevel()
    if not self.CardRealmLevelCsvMaxLevel then
        self.CardRealmLevelCsvMaxLevel = 0
        for k, v in pairs(ConfigMgr.CardRealmLevel) do
		    if k > self.CardRealmLevelCsvMaxLevel then
			    self.CardRealmLevelCsvMaxLevel = k
		    end
        end
	end
    return self.CardRealmLevelCsvMaxLevel
end

-- 获取境界的脚本配置
function Class_DataMgr:getCardRealmLevelCsv(nRealmLevevl)
	local nRealmLevevl = nRealmLevevl or 0
	
	if nRealmLevevl <= 0 then --判断nil和下界
		cclog("===Class_DataMgr:CardRealmLevel error ==="..nRealmLevevl)
		return ConfigMgr.CardRealmLevel_[0]
	else
		local tbCsv = ConfigMgr.CardRealmLevel[nRealmLevevl]
		if not tbCsv then	--说明上界越界了
			return ConfigMgr.CardRealmLevel[self:getCardRealmLevelCsvMaxLevel()]
		end
		return tbCsv
	end
end

-- 物品配置
function Class_DataMgr:getItemBaseCsv(nConfigID, nStarLevel)
	local nConfigID = nConfigID or 0
	local nStarLevel = nStarLevel or 0
	
    local tbCsv = ConfigMgr.ItemBase[nConfigID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getItemBaseCsv error ==="..nConfigID)
		return ConfigMgr.ItemBase_[0][0]
	end
    tbCsv = tbCsv[nStarLevel] 
    if(not tbCsv )then
		cclog(nConfigID.."===Class_DataMgr:getItemBaseCsv error ==="..nStarLevel)
		return ConfigMgr.ItemBase_[0][0]
	end
	return tbCsv
end

-- 伙伴组合
function Class_DataMgr:getCardGroupCsv(nGroupID)
	local nGroupID = nGroupID or 0
	
    local tbCsv = ConfigMgr.CardGroup[nGroupID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getCardGroupCsv error ==="..nGroupID)
		return ConfigMgr.CardGroup_[0]
	end
	return tbCsv
end

-- 怪物基本数据
function Class_DataMgr:getMonsterBaseCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
    local tbCsv = ConfigMgr.MonsterBase[nConfigID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getMonsterBaseCsv error ==="..nConfigID)
		return ConfigMgr.MonsterBase_[0]
	end
	return tbCsv
end

-- 获取玩家最大等级
function Class_DataMgr:getPlayerExpCsvMaxLevel()
    if not self.nPlayerExpCsvMaxLevel then
        self.nPlayerExpCsvMaxLevel = 0
        for k, v in pairs(ConfigMgr.PlayerExp) do
		    if k > self.nPlayerExpCsvMaxLevel then
			    self.nPlayerExpCsvMaxLevel = k
		    end
        end
	end
    return self.nPlayerExpCsvMaxLevel
end

-- 玩家基本数据
function Class_DataMgr:getPlayerExpCsv(nLevel)
	local nLevel = nLevel or 0
	
	if nLevel <= 0 then --判断nil和下界
		cclog("===Class_DataMgr:getPlayerExpCsv error ==="..nLevel)
		return ConfigMgr.PlayerExp_[0]
	else
		local tbCsv = ConfigMgr.PlayerExp[nLevel]
		if not tbCsv then	--说明上界越界了
			return ConfigMgr.PlayerExp[self:getPlayerExpCsvMaxLevel()]
		end
		return tbCsv
	end
end

-- 地图基本数据
function Class_DataMgr:getMapBaseCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
    if(not ConfigMgr.MapBase[nConfigID])then
		cclog("===Class_DataMgr:getMapBaseCsv error ==="..nConfigID)
		return ConfigMgr.MapBase_[0]
	end
	return ConfigMgr.MapBase[nConfigID]
end

-- 通过关卡ID获取战斗数据
function Class_DataMgr:getMapBattleCsv(nBattleID)
	local nBattleID = nBattleID or 0
	
    local tbCsv = ConfigMgr.MapBattle[nBattleID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getMapBattleCsv error ==="..nBattleID)
		return ConfigMgr.MapBattle_[0]
	end
	return tbCsv
end

-- 奖励配置
function Class_DataMgr:getActivityRewardCsv(nRewardID, nLevel)
	local nRewardID = nRewardID or 0
	
    local tbCsv = ConfigMgr.getActivityRewardCsv[nRewardID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getActivityRewardCsv error ==="..nRewardID)
		return ConfigMgr.getActivityRewardCsv_[0][0]
	end
    tbCsv = tbCsv[nLevel]
    if(not tbCsv)then
		cclog(nRewardID.."===Class_DataMgr:getActivityRewardCsv error ==="..nLevel)
		return ConfigMgr.getActivityRewardCsv_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getSeverInfoCsvByPlatform()
    local tbServer = {}
    local strKey = "ios"
    if g_Cfg.Platform == kTargetAndroid then
        strKey = "android"
    elseif g_Cfg.Platform == kTargetWindows then
        strKey = "windows"
    end

    for nIndex = 1, #ConfigMgr.SeverInfo  do
        local tbCsv = ConfigMgr.SeverInfo[nIndex]
		if tbCsv and tbCsv[strKey] == 1 then
			table.insert(tbServer,tbCsv)
		end
    end
    return tbServer
end

--服务器配置
function Class_DataMgr:getSeverInfoCsvNew()
	local CSV_SeverInfo = self:getSeverInfoCsvByPlatform()
	local nMaxLen  = #CSV_SeverInfo

    if(not CSV_SeverInfo[nMaxLen])then
		cclog("===Class_DataMgr:getSeverInfoCsvNew error ==="..nMaxLen)
		return nil
	end
    local CSV_ServerInfoItem = CSV_SeverInfo[nMaxLen]
	return CSV_ServerInfoItem, CSV_ServerInfoItem.Index
end


function Class_DataMgr:getSeverInfoCsv(nServerID)  
	local nServerID = nServerID or 0
	
    local tbCsv = ConfigMgr.SeverInfo[nServerID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getSeverInfoCsv error ==="..nServerID)
		return ConfigMgr.SeverInfo_[0]
	end
	return tbCsv
end

--对话配置
function Class_DataMgr:getDialogueCsv(nDialogueID)
	local nDialogueID = nDialogueID or 0
	
	local tbCsv = ConfigMgr.Dialogue[nDialogueID]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getDialogueCsv error ==="..nDialogueID)
		return ConfigMgr.Dialogue_[0]
	end
	return tbCsv
end

--状态数据
function Class_DataMgr:getSkillStatusCsv(nStatusID, nLevel)
	local nStatusID = nStatusID or 0
	local nLevel = nLevel or 0
	
    local tbCsv = ConfigMgr.SkillStatus[nStatusID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getSkillStatusCsv error ==="..nStatusID)
		return ConfigMgr.SkillStatus_[0][0]
	end
    tbCsv = tbCsv[nLevel]
    if(not tbCsv)then
		cclog(nStatusID.."===Class_DataMgr:getSkillStatusCsv error ==="..nLevel)
		return ConfigMgr.SkillStatus_[0][0]
	end
	return tbCsv
end

--效果数据
function Class_DataMgr:getSkillStatusEffectCsv(nEffect, nLevel)
	local nEffect = nEffect or 0
	local nLevel = nLevel or 0
	
    local tbCsv = ConfigMgr.SkillStatusEffect[nEffect]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getSkillStatusEffectCsv error ==="..nEffect)
		return ConfigMgr.SkillStatusEffect_[0]
	end
    tbCsv = tbCsv[nLevel]
    if(not tbCsv)then
		cclog(nEffect.."===Class_DataMgr:getSkillStatusEffectCsv error ==="..nLevel)
		return ConfigMgr.SkillStatusEffect_[0]
	end
	return tbCsv
end

--商城数据
function Class_DataMgr:getShopRechargeCsv(nShopRechargeCsvId)
	local nShopRechargeCsvId = nShopRechargeCsvId or 0
	
    local tbCsv = ConfigMgr.ShopRecharge[nShopRechargeCsvId]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getShopRechargeCsv error ==="..nShopRechargeCsvId)
		return ConfigMgr.ShopRecharge_[0]
	end
	return tbCsv
end

--全局配置
function Class_DataMgr:getGlobalCfgCsv(strKey)
	for k, v in pairs(ConfigMgr.GlobalCfg) do
		if v.Name == strKey then
			return v.Data
		end
	end
    cclog("===Class_DataMgr:getGlobalCfgCsv error ==="..strKey)
end

-- 获取服务端错误码信息
function Class_DataMgr:getMsgContentCsv(nMsgID)
	local nMsgID = nMsgID or 0
	
	local tbCsv = ConfigMgr.MsgContent[nMsgID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getMsgContentCsv error ==="..nMsgID)
		return ConfigMgr.MsgContent_[0]
	end
	return tbCsv
end

--返回结构
function Class_DataMgr:getMsgContentCsvID(strKey)
	for k ,v in pairs(ConfigMgr.MsgContent) do
		if v.Name == strKey then
			return v.ID
		end
	end
    cclog("===Class_DataMgr:getMsgContentCsvID error ==="..strKey)
end

function Class_DataMgr:getGuideCsv(nGuideID)
	local nGuideID = nGuideID or 0
	local tbCsv = ConfigMgr.Guide[nGuideID]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getGuideCsv error ==="..nGuideID)
		return ConfigMgr.Guide_[0]
	end
	return tbCsv
end

function Class_DataMgr:getGuideSequenceCsv(nGuideID, SequenceIndex)
	local nGuideID = nGuideID or 0
	local SequenceIndex = SequenceIndex or 0
	
	local tbCsv = ConfigMgr.Guide[nGuideID]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getGuideSequenceCsv error ==="..nGuideID)
		return ConfigMgr.Guide_[0][0]
	end
	tbCsv = tbCsv[SequenceIndex]
    if(not tbCsv)then
		cclog(nGuideID.."===Class_DataMgr:getGuideSequenceCsv error ==="..SequenceIndex)
		return ConfigMgr.Guide_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getFunctionOpenLevelCsv(nLevel, nKeyIndex)
	local nLevel = nLevel or 0
	local nKeyIndex = nKeyIndex or 0
	local tbCsv = ConfigMgr.FunctionOpenLevel[nLevel]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getFunctionOpenLevelCsv error ==="..nLevel)
		return ConfigMgr.FunctionOpenLevel_[0][0]
	end
	tbCsv = tbCsv[nKeyIndex]
    if(not tbCsv)then
		cclog(nLevel.."===Class_DataMgr:getFunctionOpenLevelCsv error ==="..nKeyIndex)
		return ConfigMgr.FunctionOpenLevel_[0][0]
	end
	return tbCsv
end

local function sortFunctionOpenLevel(tbItemA, tbItemB)
	return tbItemA.OpenLevel < tbItemB.OpenLevel
end

function Class_DataMgr:getFunctionOpenLevelCsvNext()
	local WidgetName = WidgetName or "DEFAULT"
	
	if not self.tbFunctionOpenLevelInSort then
		self.tbFunctionOpenLevelInSort = {}
		for key, value in pairs(ConfigMgr.FunctionOpenLevel) do
			for k, v in pairs(value) do
				if k == 1 then
					table.insert(self.tbFunctionOpenLevelInSort, 
						{
							OpenLevel = key,
							OpenFuncIcon = v.OpenFuncIcon,
							OpenFuncName = v.OpenFuncName,
							OpenFuncNamePic = v.OpenFuncNamePic,
							OpenVipLevel = v.OpenVipLevel,
						}
					)
				end
			end
		end
		table.sort(self.tbFunctionOpenLevelInSort, sortFunctionOpenLevel)
	end
	for nIndex = 1, #self.tbFunctionOpenLevelInSort do
		if g_Hero:getMasterCardLevel() < self.tbFunctionOpenLevelInSort[nIndex].OpenLevel then
			if self.tbFunctionOpenLevelInSort[nIndex].OpenLevel >= 1 then
				if self.tbFunctionOpenLevelInSort[nIndex].OpenVipLevel > 0 then
					if g_VIPBase:getVIPLevelId() < self.tbFunctionOpenLevelInSort[nIndex].OpenVipLevel then
						if self.tbFunctionOpenLevelInSort[nIndex].OpenLevel < 200 then
							return self.tbFunctionOpenLevelInSort[nIndex]
						else
							return {
								OpenLevel = 0,
								OpenFuncIcon = "",
								OpenFuncName = "",
								OpenFuncNamePic = "",
								OpenVipLevel = 0,
							}
						end
					end
				else
					if g_VIPBase:getVIPLevelId() < self.tbFunctionOpenLevelInSort[nIndex].OpenVipLevel then
						if self.tbFunctionOpenLevelInSort[nIndex].OpenLevel < 200 then
							return self.tbFunctionOpenLevelInSort[nIndex]
						else
							return {
								OpenLevel = 0,
								OpenFuncIcon = "",
								OpenFuncName = "",
								OpenFuncNamePic = "",
								OpenVipLevel = 0,
							}
						end
					end
				end
			else
				if self.tbFunctionOpenLevelInSort[nIndex].OpenLevel < 200 then
					return self.tbFunctionOpenLevelInSort[nIndex]
				else
					return {
						OpenLevel = 0,
						OpenFuncIcon = "",
						OpenFuncName = "",
						OpenFuncNamePic = "",
						OpenVipLevel = 0,
					}
				end
			end
		end
	end
	
	return {
		OpenLevel = 0,
		OpenFuncIcon = "",
		OpenFuncName = "",
		OpenFuncNamePic = "",
		OpenVipLevel = 0,
	}
end

function Class_DataMgr:getFunctionOpenLevelCsvByStr(WidgetName)
	local WidgetName = WidgetName or "DEFAULT"
	
	if not self.tbFunctionOpenLevelInStrKey then
		self.tbFunctionOpenLevelInStrKey = {}
		for key, value in pairs(ConfigMgr.FunctionOpenLevel) do
			for k, v in pairs(value) do
				self.tbFunctionOpenLevelInStrKey[v.WidgetName] = {}
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenLevel = key
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].WidgetName = v.WidgetName
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].IsNeedOpenGuide = v.IsNeedOpenGuide
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].IsNeedOpenAni = v.IsNeedOpenAni
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].EndGuideID = v.EndGuideID
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenFuncIcon = v.OpenFuncIcon
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenFuncName = v.OpenFuncName
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenFuncNamePic = v.OpenFuncNamePic
				self.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenVipLevel = v.OpenVipLevel
			end
		end
		self.tbFunctionOpenLevelInStrKey["DEFAULT"] = {}
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenLevel = 0
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].WidgetName = ""
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].IsNeedOpenGuide = 0
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].IsNeedOpenAni = 0
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].EndGuideID = 0
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenFuncIcon = "BtnZhuangBei"
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenFuncName = ""
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenFuncNamePic = "Char_Btn_ZhuangBei"
		self.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenVipLevel = 0
	end
	
	local tbCsv = self.tbFunctionOpenLevelInStrKey[WidgetName]
	if not tbCsv then
		cclog("===Class_DataMgr:getFunctionOpenLevelCsvByStr error ==="..WidgetName)
		return self.tbFunctionOpenLevelInStrKey["DEFAULT"]
	end
	return self.tbFunctionOpenLevelInStrKey[WidgetName]
end

function Class_DataMgr:getShopItemCsv(nShopId)
	local nShopId = nShopId or 0
	
    local tbCsv = ConfigMgr.ShopItem[nShopId]
    if(not tbCsv)then
		cclog("===Class_DataMgr:ShopItem error ==="..nShopId)
		return ConfigMgr.ShopItem_[0]
	end
	return tbCsv
end

function Class_DataMgr:getAtkDestationCsv(nPos)
	local nPos = nPos or 0
	if(not ConfigMgr.AtkDestation[nPos] )then
		cclog("===Class_DataMgr:AtkDestation error ==="..nPos)
		return ConfigMgr.AtkDestation_[0]
	end
	return ConfigMgr.AtkDestation[nPos]
end

function Class_DataMgr:getCardHunPoCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
    local tbCsv = ConfigMgr.CardHunPo[nConfigID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getCardHunPoCsv error ==="..nConfigID)
		return ConfigMgr.CardHunPo_[0]
	end
	return tbCsv
end

function Class_DataMgr:getEquipHeChengMaterialCsv(nMaterialGroupID)
	local nMaterialGroupID = nMaterialGroupID or 0
	local nRefineLevel = nRefineLevel or 0
	
    local tbCsv = ConfigMgr.EquipHeChengMaterial[nMaterialGroupID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getEquipRefineMaterialCsv error ==="..nMaterialGroupID)
		return ConfigMgr.EquipHeChengMaterial_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getEquipWorkMaterialGroupCsv(nMaterialID)
	local nMaterialID = nMaterialID or 0
	
    local tbCsv = ConfigMgr.EquipWorkMaterialGroup[nMaterialID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getEquipWorkMaterialGroupCsv error ==="..nMaterialID)
		return ConfigMgr.EquipWorkMaterialGroup_[0]
	end
	return tbCsv
end

function Class_DataMgr:getEquipPropRandTypeCsv(nPropTypeRandID, nPropID)
	local nPropTypeRandID = nPropTypeRandID or 0
	local nPropID = nPropID or 0
    local tbCsv = ConfigMgr.EquipPropRandType[nPropTypeRandID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getCardSoulCsv error ==="..nPropTypeRandID)
		return ConfigMgr.EquipPropRandType_[0][0]
	end
      
    tbCsv = tbCsv[nPropID] 
    if(not tbCsv )then
		cclog(nPropTypeRandID.."===Class_DataMgr:getCardSoulCsv error ==="..nPropID)
		return ConfigMgr.EquipPropRandType_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getCardSoulCsv(nConfigID, nStarLevel)
	local nConfigID = nConfigID or 0
	local nStarLevel = nStarLevel or 0

    local tbCsv, tbCsv1, tbCsv2 = {}, nil, nil

    local tbCsv1 = ConfigMgr.CardSoul[nConfigID]
    if(not tbCsv1)then
		cclog("===Class_DataMgr:getCardSoulCsv error ==="..nConfigID)
		tbCsv1 = ConfigMgr.CardSoul_[0]
	end
      
    tbCsv2 = tbCsv1[nStarLevel] 
    if(not tbCsv2 )then
		cclog(nConfigID.."===Class_DataMgr:getCardSoulCsv error ==="..nStarLevel)
		tbCsv2 = ConfigMgr.CardSoul_[0][0]
	end

    for k, v in pairs(tbCsv1) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
    for k, v in pairs(tbCsv2) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
	return tbCsv
end

function Class_DataMgr:getCardEvoluteSkillCostCsv(nConfigID, nStarLevel)
	local nConfigID = nConfigID or 0
	local nStarLevel = nStarLevel or 0
	
    local tbCsv = ConfigMgr.CardEvoluteSkillCost[nConfigID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getCardEvoluteSkillCostCsv error ==="..nConfigID)
		return ConfigMgr.CardEvoluteSkillCost_[0][0]
	end
    tbCsv = tbCsv[nStarLevel]
    if(not tbCsv )then
		cclog(nConfigID.."===Class_DataMgr:getCardEvoluteSkillCostCsv error ==="..nStarLevel)
		return ConfigMgr.CardEvoluteSkillCost_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getActivityRegisterCsv(nConfigID)
	local nConfigID = nConfigID or 0

    local tbCsv = ConfigMgr.ActivityRegister[nConfigID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getActivityRegisterCsv error ==="..nConfigID)
		return ConfigMgr.ActivityRegister_[0]
	end
	return tbCsv
end

function Class_DataMgr:getArenaDailyRewardCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
	local tbCsv = ConfigMgr.ArenaDailyReward[nConfigID]
	if (not tbCsv) then
		cclog("===Class_DataMgr:getArenaDailyRewardCsv error ==="..nConfigID)
		return ConfigMgr.ArenaDailyReward_[0]
	end
	return tbCsv
end

function Class_DataMgr:getActivityAssistantCsv(nConfigID)
	local nConfigID = nConfigID or 0
	
	local tbCsv = ConfigMgr.ActivityAssistant[nConfigID]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getActivityAssistantCsv error ==="..nConfigID)
		return ConfigMgr.ActivityAssistant_[0]
	end
	return tbCsv
end

function Class_DataMgr:getActivityRewardCsv(nRewardID, nRewardLevel)
	local nRewardID = nRewardID or 0
	local nRewardLevel = nRewardLevel or 0
	
    local tbCsv = ConfigMgr.ActivityReward[nRewardID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getActivityRewardCsv error ==="..nRewardID)
		return ConfigMgr.ActivityReward_[0][0]
	end
    tbCsv = tbCsv[nRewardLevel]
    if(not tbCsv )then
		cclog(nRewardID.."===Class_DataMgr:getActivityRewardCsv error ==="..nRewardLevel)
		return ConfigMgr.ActivityReward_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getActivityChengJiuCsv(nRewardID, nRewardLevel)
	local nRewardID = nRewardID or 0
	local nRewardLevel = nRewardLevel or 0
	
    local tbCsv = ConfigMgr.ActivityChengJiu[nRewardID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getActivityChengJiuCsv error ==="..nRewardID)
		return ConfigMgr.ActivityChengJiu_[0][0]
	end
    tbCsv = tbCsv[nRewardLevel]
    if(not tbCsv )then
		cclog(nRewardID.."===Class_DataMgr:getActivityChengJiuCsv error ==="..nRewardLevel)
		return ConfigMgr.ActivityChengJiu_[0][0]
	end
	return tbCsv
end

function Class_DataMgr:getActivityBaseCsvByType(nType)
	local nType = nType or 0
	
	local tbCsv = ConfigMgr.ActivityBase[nType]
	if(not tbCsv)then
		cclog("===Class_DataMgr:getActivityBaseCsvByType error ==="..nType)
		return ConfigMgr.ActivityBase_[0]--[1]
	end
	return tbCsv
end

function Class_DataMgr:getActivityWorldBossCsvByMonsterType(nMonsterType)
	local nMonsterType = nMonsterType or 0
	
	for k, v in pairs (ConfigMgr.ActivityWorldBoss) do
		if v.MonsterType == nMonsterType then
			return v
		end
	end
	return ConfigMgr.ActivityWorldBoss_[0]
end


function Class_DataMgr:getQiShuZhenfaCsv(nZhenFaID, nZhenXinIndex)

    return self:getCsvConfig_FirstAndSecondKeyData("QiShuZhenfa", nZhenFaID, nZhenXinIndex)
end

-- 判断农场的等级
function Class_DataMgr:getActivityFarmLevelByExp(nCurExp)
	local nCurExp = nCurExp or 0
	
	local CSV_ActivityFarmLevel = ConfigMgr["ActivityFarmLevel"]
    if not CSV_ActivityFarmLevel then return 0 end

    for nLevel = 1, #CSV_ActivityFarmLevel do
        if nCurExp < CSV_ActivityFarmLevel[nLevel].FarmExp then  
            return nLevel
        end
    end
	
    return #CSV_ActivityFarmLevel
end

--获取最大境界等级
function Class_DataMgr:getActivityFarmLevelCsvMaxLevel()
    if not self.ActivityFarmLevelCsvMaxLevel then
        self.ActivityFarmLevelCsvMaxLevel = 0
        for k, v in pairs(ConfigMgr.ActivityFarmLevel) do
		    if k > self.ActivityFarmLevelCsvMaxLevel then
			    self.ActivityFarmLevelCsvMaxLevel = k
		    end
        end
	end
    return self.ActivityFarmLevelCsvMaxLevel
end

-- 获取境界的脚本配置
function Class_DataMgr:getActivityFarmLevelCsv(nFarmLevel)
	local nFarmLevel = nFarmLevel or 0
	
	if nFarmLevel <= 0 then --判断nil和下界
		cclog("===Class_DataMgr:ActivityFarmLevel error ==="..nFarmLevel)
		return ConfigMgr.ActivityFarmLevel_[0]
	else
		local tbCsv = ConfigMgr.ActivityFarmLevel[nFarmLevel]
		if not tbCsv then	--说明上界越界了
			return ConfigMgr.ActivityFarmLevel[self:getActivityFarmLevelCsvMaxLevel()]
		end
		return tbCsv
	end
end

-- 加载出阵伙伴个数控制脚本
function Class_DataMgr:getActivityFarmFieldOpenCsvNextOpenLevel()
	local tbCsv = ConfigMgr.ActivityFarmFieldOpen
	for k, v in ipairs(tbCsv) do  --注意如果是for k,v in pairs(tbCsv) do 则遍历的不对 k可能不是顺序走
		if (g_Hero:getMasterCardLevel() < tonumber(v.AutoOpenLev)) then
			return v.FieldNum, v.AutoOpenLev
		end
	end
	return 0, 0
end

function Class_DataMgr:getContinuousLoginCsv(nDayIndex)
	local nDayIndex = nDayIndex or 0
	
    local tbCsv = ConfigMgr.ContinuousLogin[nDayIndex]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getContinuousLoginCsv error ==="..nDayIndex)
		return ConfigMgr.ContinuousLogin_[0]
	end
	return tbCsv
end

function Class_DataMgr:getPlayerCreateCsv(nIndex)
	local nIndex = nIndex or 0
	
    local tbCsv = ConfigMgr.PlayerCreate[nIndex]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getPlayerCreateCsv error ==="..nIndex)
		return ConfigMgr.PlayerCreate_[0]
	end
	return tbCsv
end

--获取最大境界等级
function Class_DataMgr:getActivityBaXianLevelCsvMaxLevel()
    if not self.ActivityBaXianLevelCsvMaxLevel then
        self.ActivityBaXianLevelCsvMaxLevel = 0
        for k, v in pairs(ConfigMgr.ActivityBaXianLevel) do
		    if k > self.ActivityBaXianLevelCsvMaxLevel then
			    self.ActivityBaXianLevelCsvMaxLevel = k
		    end
        end
	end
    return self.ActivityBaXianLevelCsvMaxLevel
end

-- 获取境界的脚本配置
function Class_DataMgr:getActivityBaXianLevelCsv(nBaXianLevel)
	local nBaXianLevel = nBaXianLevel or 0
	
	if nBaXianLevel <= 0 then --判断nil和下界
		cclog("===Class_DataMgr:ActivityBaXianLevel error ==="..nBaXianLevel)
		return ConfigMgr.ActivityBaXianLevel_[0]
	else
		local tbCsv = ConfigMgr.ActivityBaXianLevel[nBaXianLevel]
		if not tbCsv then	--说明上界越界了
			return ConfigMgr.ActivityBaXianLevel[self:getActivityBaXianLevelCsvMaxLevel()]
		end
		return tbCsv
	end
end

--获取八仙过海Npc基本信息
function Class_DataMgr:getBXGH_NpcBaseCsv(nNpcID)
	local nNpcID = nNpcID or 0
    local tbCsv = ConfigMgr.ActivityBaXianNpc[nNpcID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:ActivityBaXianNpcCsv error ==="..nNpcID)
		return ConfigMgr.ActivityBaXianNpc_[0]
    end
	return tbCsv
end

--获取八仙过海Npc级别信息
function Class_DataMgr:getBXGH_NpcLvCsv(nNpcID, nNpcLv)
	local nNpcID = nNpcID or 0
	local nNpcLv = nNpcLv or 0

    local tbCsv, tbCsv1, tbCsv2 = {}, nil, nil
	
    local tbCsv1 = ConfigMgr.ActivityBaXianNpc[nNpcID]
    if(not tbCsv1)then
		cclog("===Class_DataMgr:ActivityBaXianNpcCsv error ==="..nNpcID)
		tbCsv1 = ConfigMgr.ActivityBaXianNpc_[0]
	end
    tbCsv2 = tbCsv1[nNpcLv]
    if(not tbCsv2 )then
		cclog(nNpcID.."===Class_DataMgr:ActivityBaXianNpcCsv error ==="..nNpcLv)
		tbCsv2 = ConfigMgr.ActivityBaXianNpc_[0][1]
	end

    for k, v in pairs(tbCsv1) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
    for k, v in pairs(tbCsv2) do
        if type(v) ~= "table" then tbCsv[k] = v end
    end 
	return tbCsv
end

--世界Boss排序好的奖励
local function sortActivityWorldBossReward(tbItemA, tbItemB)
	return tbItemA.Rank < tbItemB.Rank
end

function Class_DataMgr:getActivityWorldBossRewardCsv()	
	if not self.tbActivityWorldBossRewardInSort then
		self.tbActivityWorldBossRewardInSort = {}
		for k, v in pairs (ConfigMgr.ActivityWorldBossReward) do
			table.insert(self.tbActivityWorldBossRewardInSort, v)
		end
		table.sort(self.tbActivityWorldBossRewardInSort, sortActivityWorldBossReward)
	end
	
	return self.tbActivityWorldBossRewardInSort
end

function Class_DataMgr:getItemComposeCsvByMaterialID(nMaterialID, nMaterialStarLevel)	
	if not self.tbItemComposeInMaterialID then
		self.tbItemComposeInMaterialID = {}
		for k1, v1 in pairs(ConfigMgr.ItemCompose) do
			for k2, v2 in pairs(v1) do
				if not self.tbItemComposeInMaterialID[v2.MaterialID1] then
					self.tbItemComposeInMaterialID[v2.MaterialID1] = {}
				end
				if not self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1] then
					self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1] = {}
				end
				self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1].MaterialID1 = v2.MaterialID1
				self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1].MaterialStarLevel1 = v2.MaterialStarLevel1
				self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1].MaterialNum1 = v2.MaterialNum1
				self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1].TargetID = v2.TargetID
				self.tbItemComposeInMaterialID[v2.MaterialID1][v2.MaterialStarLevel1].TargetStarLevel = v2.TargetStarLevel
			end
		end
		self.tbItemComposeInMaterialID[0] = {}
		self.tbItemComposeInMaterialID[0][0] = {}
		self.tbItemComposeInMaterialID[0][0].MaterialID1 = 0
		self.tbItemComposeInMaterialID[0][0].MaterialStarLevel1 = 0
		self.tbItemComposeInMaterialID[0][0].MaterialNum1 = 0
		self.tbItemComposeInMaterialID[0][0].TargetID = 0
		self.tbItemComposeInMaterialID[0][0].TargetStarLevel = 0
	end
	

	
	local nMaterialID = nMaterialID or 0
	local nMaterialStarLevel = nMaterialStarLevel or 0
	
	local tbCsv = self.tbItemComposeInMaterialID[nMaterialID]
    if(not tbCsv)then
		cclog("===Class_DataMgr:getItemComposeCsvByMaterialID error ==="..nMaterialID)
		return self.tbItemComposeInMaterialID[0][0]
	end
    tbCsv = tbCsv[nMaterialStarLevel]
    if(not tbCsv )then
		cclog(nMaterialID.."===Class_DataMgr:getItemComposeCsvByMaterialID error ==="..nMaterialStarLevel)
		return self.tbItemComposeInMaterialID[0][0]
	end
	return tbCsv
end

--商城数据排序

-------------初始化全局的数据管理器对象
g_DataMgr = Class_DataMgr.new()
