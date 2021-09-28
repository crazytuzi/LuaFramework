--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

function Class_Hero:getTeamAttackPower()
    local nAttackPower = 0
    for i = 1, 6 do
		local tbCardBattle = g_Hero:getBattleCardByIndex(i)
		if(tbCardBattle)then
			nAttackPower = nAttackPower + tbCardBattle:getAttackPower()
		end
	end

    return nAttackPower
end
--总战力
function Class_Hero:getTeamStrength()
    local nTeamStrength = 0
    for i = 1, 6 do
		local tbCardBattle = g_Hero:getBattleCardByIndex(i)
		if(tbCardBattle)then
			nTeamStrength = nTeamStrength + tbCardBattle:getCardStrength()
		end
	end

    return nTeamStrength
end

function Class_Hero:calcCurBattlePower()
    self.nTeamStrength = self:getTeamStrength()
end

function Class_Hero:showTeamStrengthGrowAnimation()
   local nCurBattlePower = self:getTeamStrength()
   -- cclog("===============Class_Hero:showTeamStrengthGrowAnimation============ self.LastFight="..tostring(self.LastFight) .." nCurBattlePower="..tostring(nCurBattlePower))
   if nCurBattlePower ~= self.LastFight then
        g_showTeamStrengthAnimation(self.LastFight, nCurBattlePower)
        self.nTeamStrength = nCurBattlePower
        self.LastFight = nCurBattlePower
	else
		cclog("==================前后战斗力一致不提示动画==================== self.LastFight="..tostring(self.LastFight) .." nCurBattlePower="..tostring(nCurBattlePower))
   end
end

--初始化主角附加属性
function Class_Hero:initMaterAddProps()
	for k, v in pairs (Enum_PropType) do
		self.tbMaterAddProps[v] = 0
	end
	--出战的1~5手，外加6~8替补
	for i = 1, 8 do
		self.tbMaterAddProps.tbZhenXinProps = {
			[i] = {
				ZhenXinPropID1 = 0,
				ZhenXinPropValue1 = 0,
				ZhenXinPropID2 = 0,
				ZhenXinPropValue2 = 0,
			}
		}
	end
end

function Class_Hero:getMasterAddProps()
    return self.tbMaterAddProps
end

--计算主角增加的额外属性
function Class_Hero:calculateMaterAddProps()
	self:initMaterAddProps()
    --计算阵法属性
    local nCurZhenFaCsvID = self:getCurrentZhenFaCsvID()
	local nCurZhenFaLev = self:getZhenFaLevel(nCurZhenFaCsvID)
	local CSV_ZhenFa = self:getCurrentZhenFaCsvByIndex(1)
	local nZhenFaPropID = CSV_ZhenFa.ZhenFaPropID
	local nZhenFaPropValue = CSV_ZhenFa.ZhenFaPropBase + (nCurZhenFaLev-1)*CSV_ZhenFa.ZhenFaPropGrowth
	self.tbMaterAddProps[nZhenFaPropID] = self.tbMaterAddProps[nZhenFaPropID] + nZhenFaPropValue
	
	local nMasterCardLevel = self:getMasterCardLevel()
	--计算战术阵心属性
	local nCurZhanShuCsvID = self:getCurZhanShuCsvID()
	local CSV_ZhanShu = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu", nCurZhanShuCsvID, 1)
	if CSV_ZhanShu.OpenLevel <= nMasterCardLevel then
		for i = 1, 5 do
			local CSV_ZhanShu = self:getCurrentZhanShuCsvByIndex(i)
			local nZhenXinLev = self:getZhanShuZhenXinLev(nCurZhanShuCsvID, i)or 0
			self.tbMaterAddProps.tbZhenXinProps[CSV_ZhanShu.ZhenXinID] = {
				ZhenXinPropID1 = CSV_ZhanShu.ZhenXinPropID1,
				ZhenXinPropValue1 = CSV_ZhanShu.ZhenXinPropBase1 + (nZhenXinLev-1)*CSV_ZhanShu.ZhenXinPropGrowth1,
				ZhenXinPropID2 = CSV_ZhanShu.ZhenXinPropID2,
				ZhenXinPropValue2 = CSV_ZhanShu.ZhenXinPropBase2 + (nZhenXinLev-1)*CSV_ZhanShu.ZhenXinPropGrowth2,
			}
		end
	end

    --计算心法技能属性万分比
    
    local tbQiShuSkill = g_DataMgr:getCsvConfig("QiShuSkill")
    for i = 1, #tbQiShuSkill do
        local tbQiShuSkillItem = tbQiShuSkill[i]
		if tbQiShuSkillItem.OpenLevel > nMasterCardLevel then
            break
        end
        local nQiShuLev = g_Hero:getXinFaLevel(i)
		local nQiShuSkillPropID = tbQiShuSkillItem.PropID
		local nQiShuSkillPropValue = tbQiShuSkillItem.PropBase + (nQiShuLev-1)*tbQiShuSkillItem.PropGrowth
        self.tbMaterAddProps[nQiShuSkillPropID] = self.tbMaterAddProps[nQiShuSkillPropID] + nQiShuSkillPropValue
    end

    --计算仙脉属性万分比
    -- if self.tbXianmaiData then
    if g_XianMaiInfoData:getTableXianmaiData() then
        local nXianMaiLev = g_XianMaiInfoData:getXianmaiLevel()
        if not nXianMaiLev then return end
        local tbXianMai = g_DataMgr:getCsvConfigByOneKey("PlayerXianMai", nXianMaiLev)

        local tbXianMaiActive = g_XianMaiInfoData:getActiveInfo()
        local tbXianMaiPropType = {
			Enum_PropType.HPMax,
			Enum_PropType.PhyAttack,
			Enum_PropType.PhyDefence,
			Enum_PropType.MagAttack,
			Enum_PropType.MagDefence,
			Enum_PropType.SkillAttack,
			Enum_PropType.SkillDefence,
		}
        local tbBasePropName = {"EvoluteHP","EvolutePhyAttack","EvolutePhyDefence","EvoluteMagAttack","EvoluteMagDefence","EvoluteSkillAttack","EvoluteSkillDefence"}
        local tbActivePropName = {"ActivateHP","ActivatePhyAttack","ActivatePhyDefence","ActivateMagAttack","ActivateMagDefence","ActivateSkillAttack","ActivateSkillDefence"}
        --先攻特殊处理一下
        self.tbMaterAddProps[Enum_PropType.Initiative] = self.tbMaterAddProps[Enum_PropType.Initiative] + tbXianMai.Initiative
		
		--仙脉
        for i=1, 7 do
            local nXianMaiPropValue = tbXianMai[tbBasePropName[i]]
            if API_GetBitsByPos(tbXianMaiActive,i) == GAME_XIANMAI_ACTIVATE then	--已激活
                nXianMaiPropValue = nXianMaiPropValue + tbXianMai[tbActivePropName[i]]
			elseif  API_GetBitsByPos(tbXianMaiActive,i) == GAME_XIANMAI_NOT_ACTIVATE then --未激活
				if nXianMaiLev > 1 then
					local tbXianMaiLast = g_DataMgr:getCsvConfigByOneKey("PlayerXianMai", nXianMaiLev - 1)
					nXianMaiPropValue = nXianMaiPropValue + tbXianMaiLast[tbActivePropName[i]]
				end
            end
            self.tbMaterAddProps[tbXianMaiPropType[i]] = self.tbMaterAddProps[tbXianMaiPropType[i]] + nXianMaiPropValue
        end
    end
	
	-- getBuildSkillLevel
	--帮派建筑 技能等级 属性加成
	if g_Guild:getAllBuildSkillLevel() then 
		--炼神塔
		local skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillHp")
		for index = 1, #skillData do 
			local cvsData = skillData[index]
			-- local bIsPercent, nBasePrecent = g_CheckPropIsPercent(cvsData.PropID)
			local propId = cvsData.PropID
			self.tbMaterAddProps[propId] = self.tbMaterAddProps[propId] + g_BuildingElement:getBuildSkillValue(cvsData, 1, index)
			
		end
		
		local skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillDefence")
		for index = 1, #skillData do 
			local cvsData = skillData[index]
			-- local bIsPercent, nBasePrecent = g_CheckPropIsPercent(cvsData.PropID)
			local propId = cvsData.PropID
			self.tbMaterAddProps[propId] = self.tbMaterAddProps[propId] + g_BuildingElement:getBuildSkillValue(cvsData, 2, index)
			
		end		
		
		local skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillAttack")
		for index = 1, #skillData do 
			local cvsData = skillData[index]
			-- local bIsPercent, nBasePrecent = g_CheckPropIsPercent(cvsData.PropID)
			local propId = cvsData.PropID
			self.tbMaterAddProps[propId] = self.tbMaterAddProps[propId] + g_BuildingElement:getBuildSkillValue(cvsData, 3, index)
			
		end
	end
	
	
end

--刷新所有出战伙伴的主角附加属性
function Class_Hero:refreshTeamMemberAddProps(bUpdateGroupProps)
    self:calculateMaterAddProps()
    for i =1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[i]
        if value and value.nServerID > 0 then
		    local tbCard =  self.CardList[value.nServerID]
			
            if tbCard then
				tbCard:reCalculateMasterAddProps()
            end
        end
    end

	g_Hero:showTeamStrengthGrowAnimation()
end

--刷新所有出战伙伴的主角附加属性
function Class_Hero:initTeamMemberAddProps(bUpdateGroupProps)
    self:calculateMaterAddProps()
    for i =1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[i]
        if value and value.nServerID > 0 then
		    local tbCard =  self.CardList[value.nServerID]
            if tbCard then
				tbCard:reCalculateMasterAddProps()
            end
        end
    end
end

--组合附加属性 g_Hero.cardGroupList
function Class_Hero:cardGroupAddProps(flag)
    for key, value in pairs(self.CardList) do
        value:initCardGroupAddProps()
        value:reCalculateBattleProps()
    end
end

function Class_Hero:addTeamMemberExpWithHeroEvent(nAddTeamMemberExp, nMasterCardLevel, nMasterCardExp)
	for nIndex = 1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[nIndex]
        if value and value.nServerID > 0 then
		    local tbCard =  self.CardList[value.nServerID]
            if tbCard then
				if nIndex == 1 then --主角卡
					tbCard:addExpWithHeroEvent(0, nMasterCardLevel, nMasterCardExp)
				else
					tbCard:addExp(nAddTeamMemberExp)
				end
            end
        end
    end
end

function Class_Hero:addTeamMemberExpWithCallEvent(nAddTeamMemberExp, funcBattleResultEndCall, nMasterCardLevel, nMasterCardExp)
	for nIndex = 1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[nIndex]
        if value and value.nServerID > 0 then
		    local tbCard =  self.CardList[value.nServerID]
            if tbCard then
				if nIndex == 1 then --主角卡
					tbCard:addExpWithCallEvent(0, funcBattleResultEndCall, nMasterCardLevel, nMasterCardExp)
				else
					tbCard:addExp(nAddTeamMemberExp)
				end
            end
        end
    end
end

function Class_Hero:addTeamMemberExpWithOpenCheck(nAddTeamMemberExp, nMasterCardLevel, nMasterCardExp)
	for nIndex = 1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[nIndex]
        if value and value.nServerID > 0 then
		    local tbCard =  self.CardList[value.nServerID]
            if tbCard then
				if nIndex == 1 then --主角卡
					tbCard:addExpWithOpenCheck(0, nMasterCardLevel, nMasterCardExp)
				else
					tbCard:addExp(nAddTeamMemberExp)
				end
            end
        end
    end
end