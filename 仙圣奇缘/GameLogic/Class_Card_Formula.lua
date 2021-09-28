--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	卡牌属性公式业务层逻辑
-- 应  用:
---------------------------------------------------------------------------------------

function Class_Card:initProfessParams()
	local nProfession = self.tbCsvBase.Profession
	local nStarLevel = self.nStarLevel
	self.tbProfessParams = {}
	self.tbProfessParams.hpmax_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).hpmax_moduls/g_BasePercent
	self.tbProfessParams.force_attack_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).force_attack_moduls/g_BasePercent
	self.tbProfessParams.force_defence_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).force_defence_moduls/g_BasePercent
	self.tbProfessParams.magic_attack_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).magic_attack_moduls/g_BasePercent
	self.tbProfessParams.magic_defence_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).magic_defence_moduls/g_BasePercent
	self.tbProfessParams.skill_attack_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).skill_attack_moduls/g_BasePercent
	self.tbProfessParams.skill_defence_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).skill_defence_moduls/g_BasePercent
	self.tbProfessParams.realm_hpmax_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).skill_defence_moduls/g_BasePercent
	self.tbProfessParams.realm_forcepoints_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).realm_forcepoints_moduls/g_BasePercent
	self.tbProfessParams.realm_magicpoints_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).realm_magicpoints_moduls/g_BasePercent
	self.tbProfessParams.realm_skillpoints_moduls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", nProfession, nStarLevel).realm_skillpoints_moduls/g_BasePercent

	return self.tbProfessParams
end

--重新计算装备基础属性
function Class_Card:reCalculateLevelProps()
	self:reCalculateBattlePropByType(Enum_PropType.HPMax)
	self:reCalculateBattlePropByType(Enum_PropType.PhyAttack)
	self:reCalculateBattlePropByType(Enum_PropType.PhyDefence)
	self:reCalculateBattlePropByType(Enum_PropType.MagAttack)
	self:reCalculateBattlePropByType(Enum_PropType.MagDefence)
	self:reCalculateBattlePropByType(Enum_PropType.SkillAttack)
	self:reCalculateBattlePropByType(Enum_PropType.SkillDefence)
	
	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end


--计算武力ForcePoints
--伙伴的武力=CardBase.csv配置初始武力绝对值*(1+伙伴突破等级对应一级属性倍数)+境界附加武力绝对值+丹药增加的武力绝对值+上香增加的武力绝对值
function Class_Card:getForcePoints()
	return self.ForcePoints
end

--计算法术MagicPoints
--伙伴的法术=CardBase.csv配置初始法术绝对值*(1+伙伴突破等级对应一级属性倍数)+境界附加法术绝对值+丹药增加的法术绝对值+上香增加的法术绝对值
function Class_Card:getMagicPoints()
	return self.MagicPoints
end

--计算绝技SkillPoints
--伙伴的绝技=CardBase.csv配置初始绝技绝对值*(1+伙伴突破等级对应一级属性倍数)+境界附加绝技绝对值+丹药增加的绝技绝对值+上香增加的绝技绝对值
function Class_Card:getSkillPoints()
	return self.SkillPoints
end

--重新计算伙伴基础属性
function Class_Card:reCalculateBaseProps()
	self:reCalculateForcePoints()
	self:reCalculateMagicPoints()
	self:reCalculateSkillPoints()
	
	self:reCalculateBattlePropByType(Enum_PropType.HPMax)
	self:reCalculateBattlePropByType(Enum_PropType.PhyAttack)
	self:reCalculateBattlePropByType(Enum_PropType.PhyDefence)
	self:reCalculateBattlePropByType(Enum_PropType.MagAttack)
	self:reCalculateBattlePropByType(Enum_PropType.MagDefence)
	self:reCalculateBattlePropByType(Enum_PropType.SkillAttack)
	self:reCalculateBattlePropByType(Enum_PropType.SkillDefence)

	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end

function Class_Card:reCalculateForcePoints()
	-- cclog("====基础武力====self.tbCsvBase.ForcePoints======="..self.tbCsvBase.ForcePoints)
	-- cclog("====突破百分比====self.tbCsvCardEvoluteProp.BasePropPercent======="..self.tbCsvCardEvoluteProp.BasePropPercent)
	-- cclog("====渡劫武力====self.tbCsvCardRealmLevel.ForcePoints======="..self.tbCsvCardRealmLevel.ForcePoints)
	-- cclog("====丹药武力====self.tbDanYaoProps.ForcePoints======="..self.tbDanYaoProps.ForcePoints)
	-- cclog("====上香武力====self.tbShangXiangProps.ForcePoints======="..self.tbShangXiangProps.ForcePoints)
	self.ForcePoints = self.tbCsvBase.ForcePoints
		* (g_BasePercent + self.tbCsvCardEvoluteProp.BasePropPercent)/g_BasePercent
		+ self.tbCsvCardRealmLevel.ForcePoints 
		+ self.tbDanYaoProps.ForcePoints --补充丹药增加的附加属性
		+ self.tbShangXiangProps.ForcePoints --上香
	self.ForcePoints = math.floor(self.ForcePoints)
end

function Class_Card:reCalculateMagicPoints()
	-- cclog("====基础法术====self.tbCsvBase.MagicPoints======="..self.tbCsvBase.MagicPoints)
	-- cclog("====突破百分比====self.tbCsvCardEvoluteProp.BasePropPercent======="..self.tbCsvCardEvoluteProp.BasePropPercent)
	-- cclog("====渡劫法术====self.tbCsvCardRealmLevel.MagicPoints======="..self.tbCsvCardRealmLevel.MagicPoints)
	-- cclog("====丹药法术====self.tbDanYaoProps.MagicPoints======="..self.tbDanYaoProps.MagicPoints)
	-- cclog("====上香法术====self.tbShangXiangProps.MagicPoints======="..self.tbShangXiangProps.MagicPoints)
	self.MagicPoints = self.tbCsvBase.MagicPoints
		* (g_BasePercent + self.tbCsvCardEvoluteProp.BasePropPercent)/g_BasePercent
		+ self.tbCsvCardRealmLevel.MagicPoints 
		+ self.tbDanYaoProps.MagicPoints --补充丹药增加的附加属性
		+ self.tbShangXiangProps.MagicPoints --上香
	self.MagicPoints = math.floor(self.MagicPoints)
end

function Class_Card:reCalculateSkillPoints()
	-- cclog("====基础绝技====self.tbCsvBase.SkillPoints======="..self.tbCsvBase.SkillPoints)
	-- cclog("====突破百分比====self.tbCsvCardEvoluteProp.BasePropPercent======="..self.tbCsvCardEvoluteProp.BasePropPercent)
	-- cclog("====渡劫绝技====self.tbCsvCardRealmLevel.SkillPoints======="..self.tbCsvCardRealmLevel.SkillPoints)
	-- cclog("====丹药绝技====self.tbDanYaoProps.SkillPoints======="..self.tbDanYaoProps.SkillPoints)
	-- cclog("====上香绝技====self.tbShangXiangProps.SkillPoints======="..self.tbShangXiangProps.SkillPoints)
	self.SkillPoints = self.tbCsvBase.SkillPoints
		* (g_BasePercent + self.tbCsvCardEvoluteProp.BasePropPercent)/g_BasePercent
		+ self.tbCsvCardRealmLevel.SkillPoints 
		+ self.tbDanYaoProps.SkillPoints --补充丹药增加的附加属性
		+ self.tbShangXiangProps.SkillPoints --上香
	self.SkillPoints = math.floor(self.SkillPoints)
end

--计算丹药一级属性
function Class_Card:initDanYaoProps()
	self.tbDanYaoProps = {
		[Enum_PropType.HPMax] = 0,
		[Enum_PropType.PhyAttack] = 0,
		[Enum_PropType.PhyDefence] = 0,
		[Enum_PropType.MagAttack] = 0,
		[Enum_PropType.MagDefence] = 0,
		[Enum_PropType.SkillAttack] = 0,
		[Enum_PropType.SkillDefence] = 0,
		ForcePoints = 0, --武力
		MagicPoints = 0, --法术
		SkillPoints = 0,--绝技
	}
	
	local tbDanYaoList =  self:getDanyaoLvList() --丹药列表
	
	local nDanYaoType = 0
	for nSkillIndex, tbDanYaoLevel in ipairs(tbDanYaoList) do
		for nDanYaoIndex, nDanYaoLevel in ipairs(tbDanYaoLevel) do
			nDanYaoType = nDanYaoType + 1
			if nDanYaoLevel > 0 then
				local CSV_CardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao", nDanYaoType ,nDanYaoLevel)
				if CSV_CardEvoluteDanYao.BasePropType == macro_pb.BPT_FOCRE_POINT then 
					self.tbDanYaoProps.ForcePoints = self.tbDanYaoProps.ForcePoints + CSV_CardEvoluteDanYao.BasePoints
				elseif CSV_CardEvoluteDanYao.BasePropType == macro_pb.BPT_MAGIC_POINT then 
					self.tbDanYaoProps.MagicPoints = self.tbDanYaoProps.MagicPoints + CSV_CardEvoluteDanYao.BasePoints
				elseif CSV_CardEvoluteDanYao.BasePropType == macro_pb.BPT_SKILL_POINT then
					self.tbDanYaoProps.SkillPoints = self.tbDanYaoProps.SkillPoints + CSV_CardEvoluteDanYao.BasePoints
				end
				
				local nDanYaoBattlePropType = Enum_EquipDanYaoPropType[nDanYaoType]
				self.tbDanYaoProps[nDanYaoBattlePropType] = self.tbDanYaoProps[nDanYaoBattlePropType] + CSV_CardEvoluteDanYao.MainProp
			else
				-- do nothing
			end
		end
	end
	
	return self.tbDanYaoProps
end

--重新计算装备基础属性
function Class_Card:reCalculateDanYaoProps(nSkillIndex, nDanYaoIndex)
	if not self.tbDanYaoProps then
		self:initDanYaoProps()
	end
	
	local PowerfulSkillID = self.tbCsvBase["PowerfulSkillID"..nSkillIndex]
	local CSV_CardEvoluteSkillCondition = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition", PowerfulSkillID)
	local nDanYaoType = CSV_CardEvoluteSkillCondition["NeedDanYaoID"..nDanYaoIndex]
	local nDanYaoLevel = self:getDanyaoLevel(nSkillIndex, nDanYaoIndex)
	local CSV_CardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao", nDanYaoType, nDanYaoLevel)
	local CSV_CardEvoluteDanYaoLast = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao", nDanYaoType, nDanYaoLevel - 1)
	
	local nBattlePropType1 = 0
	local nBattlePropType2 = 0
	if CSV_CardEvoluteDanYao.BasePropType == macro_pb.BPT_FOCRE_POINT then 
		self.tbDanYaoProps.ForcePoints = self.tbDanYaoProps.ForcePoints + (CSV_CardEvoluteDanYao.BasePoints - CSV_CardEvoluteDanYaoLast.BasePoints)
		self:reCalculateForcePoints()
		nBattlePropType1 = Enum_PropType.PhyAttack
		nBattlePropType2 = Enum_PropType.PhyDefence
	elseif CSV_CardEvoluteDanYao.BasePropType == macro_pb.BPT_MAGIC_POINT then 
		self.tbDanYaoProps.MagicPoints = self.tbDanYaoProps.MagicPoints + (CSV_CardEvoluteDanYao.BasePoints - CSV_CardEvoluteDanYaoLast.BasePoints)
		self:reCalculateMagicPoints()
		nBattlePropType1 = Enum_PropType.MagAttack
		nBattlePropType2 = Enum_PropType.MagDefence
	elseif CSV_CardEvoluteDanYao.BasePropType == macro_pb.BPT_SKILL_POINT then
		self.tbDanYaoProps.SkillPoints = self.tbDanYaoProps.SkillPoints + (CSV_CardEvoluteDanYao.BasePoints - CSV_CardEvoluteDanYaoLast.BasePoints)
		self:reCalculateSkillPoints()
		nBattlePropType1 = Enum_PropType.SkillAttack
		nBattlePropType2 = Enum_PropType.SkillDefence
	end
	
	local nDanYaoBattlePropType = Enum_EquipDanYaoPropType[nDanYaoType]
	self.tbDanYaoProps[nDanYaoBattlePropType] = self.tbDanYaoProps[nDanYaoBattlePropType] + (CSV_CardEvoluteDanYao.MainProp - CSV_CardEvoluteDanYaoLast.MainProp)
	if nBattlePropType1 ~= 0 and nBattlePropType2 ~= 0 then 
	    self:reCalculateBattlePropByType(nBattlePropType1)
	    self:reCalculateBattlePropByType(nBattlePropType2)
	end
	if nDanYaoBattlePropType ~= nPropType1 and nDanYaoBattlePropType ~= nBattlePropType2 then
		self:reCalculateBattlePropByType(nDanYaoBattlePropType)
	end
	
	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end

function Class_Card:initShangXiangProps()
	self.tbShangXiangProps = {
		HPMax = 0,
		ForcePoints = 0, --武力
		MagicPoints = 0, --法术
		SkillPoints = 0,--绝技
	}
	local GameObj_ShangXiang = self:getCSXiangData()
	if GameObj_ShangXiang then 
		local tbPropValue = GameObj_ShangXiang:getAccuPropValue()
		self.tbShangXiangProps.HPMax = tbPropValue[1]
		self.tbShangXiangProps.ForcePoints = tbPropValue[2]
		self.tbShangXiangProps.MagicPoints = tbPropValue[3]
		self.tbShangXiangProps.SkillPoints = tbPropValue[4]
	end

	return self.tbShangXiangProps
end

--重新计算装备基础属性
function Class_Card:reCalculateShangXiangProps()
	if not self.tbShangXiangProps then
		self:initShangXiangProps()
	end
	
	local GameObj_ShangXiang = self:getCSXiangData()
	if GameObj_ShangXiang then 
		local tbPropValue = GameObj_ShangXiang:getAccuPropValue()
		self.tbShangXiangProps.HPMax = tbPropValue[1]
		self.tbShangXiangProps.ForcePoints = tbPropValue[2]
		self.tbShangXiangProps.MagicPoints = tbPropValue[3]
		self.tbShangXiangProps.SkillPoints = tbPropValue[4]
	end
	
	self:reCalculateForcePoints()
	self:reCalculateMagicPoints()
	self:reCalculateSkillPoints()

	self:reCalculateBattlePropByType(Enum_PropType.HPMax)
	self:reCalculateBattlePropByType(Enum_PropType.PhyAttack)
	self:reCalculateBattlePropByType(Enum_PropType.PhyDefence)
	self:reCalculateBattlePropByType(Enum_PropType.MagAttack)
	self:reCalculateBattlePropByType(Enum_PropType.MagDefence)
	self:reCalculateBattlePropByType(Enum_PropType.SkillAttack)
	self:reCalculateBattlePropByType(Enum_PropType.SkillDefence)

	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end

--初始化装备基础属性
function Class_Card:initEquipMainProps()
	self.tbEquipMainProps = {}
	for k, v in pairs (Enum_EquipMainPropType) do
		self.tbEquipMainProps[v] = 0
	end
	--计算伙伴的所有装备的主属性
	for i = 1, #self.tbEquipIdList do
		if self.tbEquipIdList[i] > 0 then
			local tbEquip = g_Hero:getEquipObjByServID(self.tbEquipIdList[i])
			if(tbEquip)then
				local tbEquipBase = tbEquip:getCsvBase()
				if(tbEquipBase)then
					local nEquipSubType = tonumber(tbEquipBase.SubType)
					local nEquipMainPropType = Enum_EquipMainPropType[nEquipSubType]
					local nMainPropValue = g_GetEquipMainProp(tbEquipBase, tbEquip.nRefineLevel, tbEquip:getStrengthenLev())
					self.tbEquipMainProps[nEquipMainPropType] = nMainPropValue
				end
			end
		end
	end
end

--重新计算装备基础属性
function Class_Card:reCalculateEquipMainProps(GameObj_EquipTarget)
	if not self.tbEquipMainProps then
		self:initEquipMainProps()
	end

	--装备主属性不会重复直接覆盖
	local CSV_Equip = GameObj_EquipTarget:getCsvBase()
	local nEquipMainPropType = Enum_EquipMainPropType[tonumber(CSV_Equip.SubType)]
	local nMainPropValue = g_GetEquipMainProp(CSV_Equip, GameObj_EquipTarget.nRefineLevel, GameObj_EquipTarget:getStrengthenLev())
	self.tbEquipMainProps[nEquipMainPropType] = nMainPropValue
	self:reCalculateBattlePropByType(nEquipMainPropType)
	
	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end




function Class_Card:groupProps(groupNum)
     for k, v in pairs(groupNum) do 
		--是否拥有的这张卡牌
		if not g_Hero.cardGroupList[v] then
			return false
		end
	end
	return true
end

--初始化计算组合附加属性
function Class_Card:initCardGroupAddProps()
	self.tbCardGroupAddProps = {}
	for k, v in pairs (Enum_PropType) do
		self.tbCardGroupAddProps[v] = 0
	end
	--计算组合属性
	for nCardGroupIndex = 1, 4 do
		local nCardGroupCsvID = self.tbCsvBase["CardGroupID"..nCardGroupIndex]
		if nCardGroupCsvID > 0 then
			local CSV_CardGroup = g_DataMgr:getCsvConfigByOneKey("CardGroup", nCardGroupCsvID)
            local groupNum = {}
	        --每一个组合最多5个
	        for i = 1, 5 do
		        local cardId = CSV_CardGroup["CardID"..i]
		        if cardId ~= 0 then 
			        table.insert(groupNum, cardId)
		        end
	        end
			if self:groupProps(groupNum) then
				self.tbCardGroupAddProps[CSV_CardGroup.PropType] = self.tbCardGroupAddProps[CSV_CardGroup.PropType] + CSV_CardGroup.PropValue
			end
		end
	end
end

--计算添加新的卡牌后，前面的卡牌有缘分可以激活的在没有激活的情况下 去激活和计算
function Class_Card:absentCardGroupAddProps()
    --增添了新卡牌，卡牌的组合数组
    for key, groupCombinationId in pairs(self.groupCombination) do 
        for index, groupId in pairs(groupCombinationId) do
            local cardGruop = g_Hero.cardGroupList[groupId]
            if cardGruop and groupId ~= self.tbCsvBase.ID then 
                for cardGruopIndex, cardGruopIdValue in pairs(cardGruop.groupCombination) do 
                    local CSV_CardGroup = g_DataMgr:getCsvConfigByOneKey("CardGroup", cardGruop.groupCsv[cardGruopIndex])
                    if cardGruop:groupProps(cardGruopIdValue) then
                        cardGruop.tbCardGroupAddProps[CSV_CardGroup.PropType] = cardGruop.tbCardGroupAddProps[CSV_CardGroup.PropType] + CSV_CardGroup.PropValue
                    end
                    cardGruop:reCalculateBattleProps()
                end
            end
        end
    end
end

function Class_Card:decomposeCardGroup()
    for index = 1, 4 do
		local nCardGroupCsvID = self.tbCsvBase["CardGroupID"..index]
		if nCardGroupCsvID > 0 then
			local CSV_CardGroup = g_DataMgr:getCsvConfigByOneKey("CardGroup", nCardGroupCsvID)
	        for i = 1, 5 do
		        local cardId = CSV_CardGroup["CardID"..i]
		        if cardId ~= 0 then
                    local card = g_Hero.cardGroupList[cardId] 
                    if card then 
                        card.tbCardGroupAddProps[CSV_CardGroup.PropType]  = 0
                        card:reCalculateBattleProps()
                    end
		        end
	        end
        end
    end
    g_Hero.cardGroupList[self.tbCsvBase.ID] = nil
end


--初始化装备附加属性
function Class_Card:initCardEquipAddProps()
	self.tbCardEquipAddProps = {}
	for k, v in pairs (Enum_PropType) do
		self.tbCardEquipAddProps[v] = 0
	end

	--计算伙伴的所有装备属性
	for i = 1, #self.tbEquipIdList do
		local GameObj_Equip = g_Hero:getEquipObjByServID(self.tbEquipIdList[i])
		if GameObj_Equip then
			--装备的附加属性
			local tbPops = GameObj_Equip:getEquipTbProp()
			for k, v in pairs(tbPops) do
				self.tbCardEquipAddProps[v.Prop_Type] = self.tbCardEquipAddProps[v.Prop_Type] + v.Prop_Value
			end
		end
	end
end

--重新计算卡牌身上的装备附加属性
function Class_Card:reCalculateCardEquipAddProps(nRandomPropTypeNew, nRandomPropValueNew, nRandomPropTypeOld, nRandomPropValueOld)
	if not self.tbCardEquipAddProps then
		self:initCardEquipAddProps()
	end
	
	self.tbCardEquipAddProps[nRandomPropTypeOld] = self.tbCardEquipAddProps[nRandomPropTypeOld] - nRandomPropValueOld
	self.tbCardEquipAddProps[nRandomPropTypeNew] = self.tbCardEquipAddProps[nRandomPropTypeNew] + nRandomPropValueNew
	self:reCalculateBattlePropByType(nRandomPropTypeOld)
	if nRandomPropTypeNew ~= nRandomPropTypeOld then
		self:reCalculateBattlePropByType(nRandomPropTypeNew)
	end
	
	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end

--重新计算卡牌身上的装备主属性、附加属性
function Class_Card:reCalculateCardEquipAllProps(strOperation, GameObj_EquipOld, GameObj_EquipNew)

	if strOperation == "Dress" then
		local CSV_EquipNew = GameObj_EquipNew:getCsvBase()
		local nEquipMainPropTypeNew = Enum_EquipMainPropType[tonumber(CSV_EquipNew.SubType)]
		self.tbEquipMainProps[nEquipMainPropTypeNew] = g_GetEquipMainProp(CSV_EquipNew, GameObj_EquipNew.nRefineLevel, GameObj_EquipNew:getStrengthenLev())
		local tbUpdateType = {}
		tbUpdateType[nEquipMainPropTypeNew] = 1
		local tbRealmPropNew = GameObj_EquipNew:getEquipTbProp()
		for k, v in pairs (tbRealmPropNew) do
			self.tbCardEquipAddProps[v.Prop_Type] = self.tbCardEquipAddProps[v.Prop_Type] + v.Prop_Value
			tbUpdateType[v.Prop_Type] = 1
		end
		
		for k, v in pairs (tbUpdateType) do
			self:reCalculateBattlePropByType(k)	
		end
	elseif strOperation == "Undress" then
		local CSV_EquipOld = GameObj_EquipOld:getCsvBase()
		local nEquipMainPropTypeOld = Enum_EquipMainPropType[tonumber(CSV_EquipOld.SubType)]
		self.tbEquipMainProps[nEquipMainPropTypeOld] = 0
		local tbUpdateType = {}
		tbUpdateType[nEquipMainPropTypeOld] = 1
		local tbRealmPropOld = GameObj_EquipOld:getEquipTbProp()
		for k, v in pairs(tbRealmPropOld) do
			self.tbCardEquipAddProps[v.Prop_Type] = self.tbCardEquipAddProps[v.Prop_Type] - v.Prop_Value
			tbUpdateType[v.Prop_Type] = 1
		end
		
		for k, v in pairs (tbUpdateType) do
			self:reCalculateBattlePropByType(k)	
		end
	elseif strOperation == "Exchange" then
		local CSV_EquipOld = GameObj_EquipOld:getCsvBase()
		local nEquipMainPropTypeOld = Enum_EquipMainPropType[tonumber(CSV_EquipOld.SubType)]
		self.tbEquipMainProps[nEquipMainPropTypeOld] = 0
		local tbUpdateType = {}
		tbUpdateType[nEquipMainPropTypeOld] = 1
		local tbRealmPropOld = GameObj_EquipOld:getEquipTbProp()
		for k, v in pairs(tbRealmPropOld) do
			self.tbCardEquipAddProps[v.Prop_Type] = self.tbCardEquipAddProps[v.Prop_Type] - v.Prop_Value
			tbUpdateType[v.Prop_Type] = 1
		end
		
		local CSV_EquipNew = GameObj_EquipNew:getCsvBase()
		local nEquipMainPropTypeNew = Enum_EquipMainPropType[tonumber(CSV_EquipNew.SubType)]
		self.tbEquipMainProps[nEquipMainPropTypeNew] = g_GetEquipMainProp(CSV_EquipNew, GameObj_EquipNew.nRefineLevel, GameObj_EquipNew:getStrengthenLev())

		tbUpdateType[nEquipMainPropTypeNew] = 1
		local tbRealmPropNew = GameObj_EquipNew:getEquipTbProp()
		for k, v in pairs (tbRealmPropNew) do
			self.tbCardEquipAddProps[v.Prop_Type] = self.tbCardEquipAddProps[v.Prop_Type] + v.Prop_Value
			tbUpdateType[v.Prop_Type] = 1
		end
		
		for k, v in pairs (tbUpdateType) do
			self:reCalculateBattlePropByType(k)	
		end
	end
	
	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end


--初始化异兽属性
function Class_Card:initFateProps()
	self.tbFateProps = {}
	for k, v in pairs (Enum_FatePropType) do
		self.tbFateProps[v] = 0
	end
	for i=1, #self.tbFateIdList do
		if self.tbFateIdList[i] > 0 then
			local tbFate = g_Hero:getFateInfoByID(self.tbFateIdList[i])
			if(tbFate)then
				local CSV_CardFate = tbFate:getCardFateCsv()
				if(CSV_CardFate)then
					local nType = tonumber(CSV_CardFate.Type)
					local nFatePropType = Enum_FatePropType[nType]
					self.tbFateProps[nFatePropType] = CSV_CardFate.PropValue
				end
			end
		end
	end
end

--重新计算异兽属性
function Class_Card:reCalculateFateProps(strOperation, GameObj_FateOld, GameObj_FateNew)
	if not self.tbFateProps then
		self:initFateProps()
	end
	
	--妖兽属性是不会重复的
	if strOperation == "Upgrade" then
		local CSV_CardFateOld = GameObj_FateOld:getCardFateCsv()
		local nFatePropTypeOld = Enum_FatePropType[tonumber(CSV_CardFateOld.Type)]
		self.tbFateProps[nFatePropTypeOld] = CSV_CardFateOld.PropValue
		self:reCalculateBattlePropByType(nFatePropTypeOld)
	elseif strOperation == "Dress" then
		local CSV_CardFateNew = GameObj_FateNew:getCardFateCsv()
		local nFatePropTypeNew = Enum_FatePropType[tonumber(CSV_CardFateNew.Type)]
		self.tbFateProps[nFatePropTypeNew] = CSV_CardFateNew.PropValue
		self:reCalculateBattlePropByType(nFatePropTypeNew)
	elseif strOperation == "Undress" then
		local CSV_CardFateOld = GameObj_FateOld:getCardFateCsv()
		local nFatePropTypeOld = Enum_FatePropType[tonumber(CSV_CardFateOld.Type)]
		self.tbFateProps[nFatePropTypeOld] = 0
		self:reCalculateBattlePropByType(nFatePropTypeOld)
	elseif strOperation == "Exchange" then
		local CSV_CardFateOld = GameObj_FateOld:getCardFateCsv()
		local nFatePropTypeOld = Enum_FatePropType[tonumber(CSV_CardFateOld.Type)]
		self.tbFateProps[nFatePropTypeOld] = 0
		self:reCalculateBattlePropByType(nFatePropTypeOld)
		
		local CSV_CardFateNew = GameObj_FateNew:getCardFateCsv()
		local nFatePropTypeNew = Enum_FatePropType[tonumber(CSV_CardFateNew.Type)]
		self.tbFateProps[nFatePropTypeNew] = CSV_CardFateNew.PropValue
		self:reCalculateBattlePropByType(nFatePropTypeNew)
	end
	
	if self:checkIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end

--初始化主角附加的额外属性
function Class_Card:initMasterAddProps()
	self.tbMasterAddProps = {}
	for k, v in pairs (Enum_PropType) do
		self.tbMasterAddProps[v] = 0
	end

	--出战伙伴附带主角附加属性、
	if self:checkIsInBattle() then
		local tbMaterAddProps = g_Hero:getMasterAddProps()

		for k, v in pairs (Enum_PropType) do
			self.tbMasterAddProps[v] = self.tbMasterAddProps[v] + tbMaterAddProps[v]
		end

		--计算阵心属性
		local nChuShouIndex = g_Hero:getBuZhenPosByCardID(self.nServerID)
		if nChuShouIndex > 0 and  nChuShouIndex <= 5 then
			local tbZhenXinProp = tbMaterAddProps.tbZhenXinProps[nChuShouIndex]
			if tbZhenXinProp then
				self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID1] = self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID1] + tbZhenXinProp.ZhenXinPropValue1
				self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID2] = self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID2] + tbZhenXinProp.ZhenXinPropValue2
			end
		end
	end
end

--重新计算附加属性
function Class_Card:reCalculateMasterAddProps()
	self.tbMasterAddProps = {}
	for k, v in pairs (Enum_PropType) do
		self.tbMasterAddProps[v] = 0
	end

	--出战伙伴附带主角附加属性
	if self:checkIsInBattle() then
		local tbMaterAddProps = g_Hero:getMasterAddProps()

		for k, v in pairs (Enum_PropType) do
			self.tbMasterAddProps[v] = self.tbMasterAddProps[v] + tbMaterAddProps[v]
		end

		--计算阵心属性
		local nChuShouIndex = g_Hero:getBuZhenPosByCardID(self.nServerID)
		if nChuShouIndex > 0 and  nChuShouIndex <= 5 then
			local tbZhenXinProp = tbMaterAddProps.tbZhenXinProps[nChuShouIndex]
			if tbZhenXinProp then
				self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID1] = self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID1] + tbZhenXinProp.ZhenXinPropValue1
				self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID2] = self.tbMasterAddProps[tbZhenXinProp.ZhenXinPropID2] + tbZhenXinProp.ZhenXinPropValue2
			end
		end
	end
	
--	 if bUpdateGroupProps then
--        --组合附加属性
--        self:initCardGroupAddProps()
--	 end

	self:reCalculateBattleProps()
end

--完全重新计算伙伴的数据
function Class_Card:initCardPropAll()
	self:initProfessParams()
	self:initDanYaoProps()
	self:initShangXiangProps()
	self:initEquipMainProps()
	
    self:initCardGroupAddProps()

	self:initCardEquipAddProps()
	self:initFateProps()
	self:initMasterAddProps()
	
	self:reCalculateForcePoints()
	self:reCalculateMagicPoints()
	self:reCalculateSkillPoints()
	self:reCalculateBattleProps()
	
end

--计算伙伴的战斗属性，即二级属性
function Class_Card:reCalculateBattleProps()
	self:reCalculateBattlePropByType(Enum_PropType.HPMax)
   
	self:reCalculateBattlePropByType(Enum_PropType.PhyAttack)
	self:reCalculateBattlePropByType(Enum_PropType.PhyDefence)
	self:reCalculateBattlePropByType(Enum_PropType.MagAttack)
	self:reCalculateBattlePropByType(Enum_PropType.MagDefence)
	self:reCalculateBattlePropByType(Enum_PropType.SkillAttack)
	self:reCalculateBattlePropByType(Enum_PropType.SkillDefence)
	
	self:reCalculateBattlePropByType(Enum_PropType.CriticalChance)
	self:reCalculateBattlePropByType(Enum_PropType.CriticalResistance)
	self:reCalculateBattlePropByType(Enum_PropType.CriticalStrike)
	self:reCalculateBattlePropByType(Enum_PropType.CriticalStrikeResistance)
	self:reCalculateBattlePropByType(Enum_PropType.HitChance)
	self:reCalculateBattlePropByType(Enum_PropType.DodgeChance)
	self:reCalculateBattlePropByType(Enum_PropType.PenetrateChance)
	self:reCalculateBattlePropByType(Enum_PropType.BlockChance)
end

function Class_Card:reCalculateHPMax()
	--nBaseHPMax = (卡牌基础生命+卡牌成长*等级)*(1+突破等级生命倍数)+境界增加生命值*境界生命值系数+丹药增加生命值+上香增加生命值
	local nBaseHPMax = (self.tbCsvBase.BaseHPMax + self.tbCsvBase.HPMaxGrow*self.nLevel)
						* (g_BasePercent + self.tbCsvCardEvoluteProp.BaseHPPercent)/g_BasePercent
						+ self.tbCsvCardRealmLevel.HPMax*self.tbProfessParams.realm_hpmax_moduls
						+ self.tbDanYaoProps[Enum_PropType.HPMax]	--丹药增加的生命上限
						+ self.tbShangXiangProps.HPMax	--上香增加的生命上限
	--伙伴的生命上限 = (nBaseHPMax + 装备主属性生命值)*(1+附加生命属性倍数)+异兽主属性生命值+附加生命属性
	self.HPMax = (nBaseHPMax*self.tbProfessParams.hpmax_moduls + self.tbEquipMainProps[Enum_PropType.HPMax])
					*(g_BasePercent
						+ self.tbCardEquipAddProps[Enum_PropType.HPMaxPercent]
						+ self.tbCardGroupAddProps[Enum_PropType.HPMaxPercent]
						+ self.tbMasterAddProps[Enum_PropType.HPMaxPercent]
					)/g_BasePercent
					+ self.tbFateProps[Enum_PropType.HPMax]
					+ self.tbCardEquipAddProps[Enum_PropType.HPMax]
					+ self.tbCardGroupAddProps[Enum_PropType.HPMax]
					+ self.tbMasterAddProps[Enum_PropType.HPMax]
	self.HPMax = math.floor(self.HPMax)
end

function Class_Card:reCalculatePhyAttack()
	-- 物理攻击=(卡牌基础物理攻击+丹药增加物理攻击+武力*等级*武力参数+装备主属性物理攻击)*(1+附加物理攻击倍数)+异兽物理攻击+附加物理攻击
	-- cclog("====基础物攻====self.tbCsvBase.BasePhyAttack======="..self.tbCsvBase.BasePhyAttack)
	-- cclog("====丹药物攻====self.tbDanYaoProps[Enum_PropType.PhyAttack]======="..self.tbDanYaoProps[Enum_PropType.PhyAttack])
	-- cclog("====武力====self.ForcePoints======="..self.ForcePoints)
	-- cclog("====伙伴等级====self.nLevel======="..self.nLevel)
	-- cclog("====物攻系数====self.tbProfessParams.force_attack_moduls======="..self.tbProfessParams.force_attack_moduls)
	-- cclog("====装备附加物攻百分比====self.tbCardEquipAddProps[Enum_PropType.PhyAttackPercent]======="..self.tbCardEquipAddProps[Enum_PropType.PhyAttackPercent])
	-- cclog("====组合附加物攻百分比====self.tbCardGroupAddProps[Enum_PropType.PhyAttackPercent]======="..self.tbCardGroupAddProps[Enum_PropType.PhyAttackPercent])
	-- cclog("====主角附加物攻百分比====self.tbMasterAddProps[Enum_PropType.PhyAttackPercent]======="..self.tbMasterAddProps[Enum_PropType.PhyAttackPercent])
	-- cclog("====装备主属性物攻====self.tbEquipMainProps[Enum_PropType.PhyAttack]======="..self.tbEquipMainProps[Enum_PropType.PhyAttack])
	-- cclog("====妖兽主属性物攻====self.tbFateProps[Enum_PropType.PhyAttack]======="..self.tbFateProps[Enum_PropType.PhyAttack])
	-- cclog("====装备附加属性物攻====self.tbCardEquipAddProps[Enum_PropType.PhyAttack]======="..self.tbCardEquipAddProps[Enum_PropType.PhyAttack])
	-- cclog("====组合附加属性物攻====self.tbCardGroupAddProps[Enum_PropType.PhyAttack]======="..self.tbCardGroupAddProps[Enum_PropType.PhyAttack])
	-- cclog("====主角附加属性物攻====self.tbMasterAddProps[Enum_PropType.PhyAttack]======="..self.tbMasterAddProps[Enum_PropType.PhyAttack])

	self.PhyAttack = (self.tbCsvBase.BasePhyAttack + self.tbDanYaoProps[Enum_PropType.PhyAttack] + self.ForcePoints*self.nLevel*self.tbProfessParams.force_attack_moduls + self.tbEquipMainProps[Enum_PropType.PhyAttack])
		*(g_BasePercent
			+ self.tbCardEquipAddProps[Enum_PropType.PhyAttackPercent]
			+ self.tbCardGroupAddProps[Enum_PropType.PhyAttackPercent]
			+ self.tbMasterAddProps[Enum_PropType.PhyAttackPercent]
			+ self.tbCardEquipAddProps[Enum_PropType.AllAttackPercent]
			+ self.tbCardGroupAddProps[Enum_PropType.AllAttackPercent]
			+ self.tbMasterAddProps[Enum_PropType.AllAttackPercent]
		)/g_BasePercent
		+ self.tbFateProps[Enum_PropType.PhyAttack]
		+ self.tbCardEquipAddProps[Enum_PropType.PhyAttack]
		+ self.tbCardGroupAddProps[Enum_PropType.PhyAttack]
		+ self.tbMasterAddProps[Enum_PropType.PhyAttack]
		+ self.tbCardEquipAddProps[Enum_PropType.AllAttack]
		+ self.tbCardGroupAddProps[Enum_PropType.AllAttack]
		+ self.tbMasterAddProps[Enum_PropType.AllAttack]
	self.PhyAttack = math.floor(self.PhyAttack)

end

function Class_Card:reCalculatePhyDefence()
	--物理防御=(卡牌基础物理防御+丹药增加物理防御+武力*等级*武力参数+装备主属性物理防御)*(1+附加物理防御倍数)+异兽物理防御+附加物理防御
	-- cclog("====基础物防====self.tbCsvBase.BasePhyDefence======="..self.tbCsvBase.BasePhyDefence)
	-- cclog("====丹药物防====self.tbDanYaoProps[Enum_PropType.PhyDefence]======="..self.tbDanYaoProps[Enum_PropType.PhyDefence])
	-- cclog("====武力====self.ForcePoints======="..self.ForcePoints)
	-- cclog("====伙伴等级====self.nLevel======="..self.nLevel)
	-- cclog("====物防系数====self.tbProfessParams.force_defence_moduls======="..self.tbProfessParams.force_defence_moduls)
	-- cclog("====装备附加物防百分比====self.tbCardEquipAddProps[Enum_PropType.PhyDefencePercent]======="..self.tbCardEquipAddProps[Enum_PropType.PhyDefencePercent])
	-- cclog("====组合附加物防百分比====self.tbCardGroupAddProps[Enum_PropType.PhyDefencePercent]======="..self.tbCardGroupAddProps[Enum_PropType.PhyDefencePercent])
	-- cclog("====主角附加物防百分比====self.tbMasterAddProps[Enum_PropType.PhyDefencePercent]======="..self.tbMasterAddProps[Enum_PropType.PhyDefencePercent])
	-- cclog("====装备主属性物防====self.tbEquipMainProps[Enum_PropType.PhyDefence]======="..self.tbEquipMainProps[Enum_PropType.PhyDefence])
	-- cclog("====妖兽主属性物防====self.tbFateProps[Enum_PropType.PhyDefence]======="..self.tbFateProps[Enum_PropType.PhyDefence])
	-- cclog("====装备附加属性物防====self.tbCardEquipAddProps[Enum_PropType.PhyDefence]======="..self.tbCardEquipAddProps[Enum_PropType.PhyDefence])
	-- cclog("====组合附加属性物防====self.tbCardGroupAddProps[Enum_PropType.PhyDefence]======="..self.tbCardGroupAddProps[Enum_PropType.PhyDefence])
	-- cclog("====主角附加属性物防=====self.tbMasterAddProps[Enum_PropType.PhyDefence]======="..self.tbMasterAddProps[Enum_PropType.PhyDefence])
	self.PhyDefence = (self.tbCsvBase.BasePhyDefence + self.tbDanYaoProps[Enum_PropType.PhyDefence] + self.ForcePoints*self.nLevel*self.tbProfessParams.force_defence_moduls + self.tbEquipMainProps[Enum_PropType.PhyDefence])
		*(g_BasePercent
			+ self.tbCardEquipAddProps[Enum_PropType.PhyDefencePercent]
			+ self.tbCardGroupAddProps[Enum_PropType.PhyDefencePercent]
			+ self.tbMasterAddProps[Enum_PropType.PhyDefencePercent]
			+ self.tbCardEquipAddProps[Enum_PropType.AllDefencePercent]
			+ self.tbCardGroupAddProps[Enum_PropType.AllDefencePercent]
			+ self.tbMasterAddProps[Enum_PropType.AllDefencePercent]
		)/g_BasePercent
		+ self.tbFateProps[Enum_PropType.PhyDefence]
		+ self.tbCardEquipAddProps[Enum_PropType.PhyDefence]
		+ self.tbCardGroupAddProps[Enum_PropType.PhyDefence]
		+ self.tbMasterAddProps[Enum_PropType.PhyDefence]
		+ self.tbCardEquipAddProps[Enum_PropType.AllDefence]
		+ self.tbCardGroupAddProps[Enum_PropType.AllDefence]
		+ self.tbMasterAddProps[Enum_PropType.AllDefence]
	self.PhyDefence = math.floor(self.PhyDefence)
end

function Class_Card:reCalculateMagAttack()
	--法术攻击=(卡牌基础法术攻击+丹药增加法术攻击+武力*等级*武力参数+装备主属性法术攻击)*(1+附加法术攻击倍数)+异兽法术攻击+附加法术攻击
	self.MagAttack = (self.tbCsvBase.BaseMagAttack + self.tbDanYaoProps[Enum_PropType.MagAttack] + self.MagicPoints*self.nLevel*self.tbProfessParams.magic_attack_moduls + self.tbEquipMainProps[Enum_PropType.MagAttack])
		*(g_BasePercent
			+ self.tbCardEquipAddProps[Enum_PropType.MagAttackPercent]
			+ self.tbCardGroupAddProps[Enum_PropType.MagAttackPercent]
			+ self.tbMasterAddProps[Enum_PropType.MagAttackPercent]
			+ self.tbCardEquipAddProps[Enum_PropType.AllAttackPercent]
			+ self.tbCardGroupAddProps[Enum_PropType.AllAttackPercent]
			+ self.tbMasterAddProps[Enum_PropType.AllAttackPercent]
		)/g_BasePercent
		+ self.tbFateProps[Enum_PropType.MagAttack]
		+ self.tbCardEquipAddProps[Enum_PropType.MagAttack]
		+ self.tbCardGroupAddProps[Enum_PropType.MagAttack]
		+ self.tbMasterAddProps[Enum_PropType.MagAttack]
		+ self.tbCardEquipAddProps[Enum_PropType.AllAttack]
		+ self.tbCardGroupAddProps[Enum_PropType.AllAttack]
		+ self.tbMasterAddProps[Enum_PropType.AllAttack]
	self.MagAttack = math.floor(self.MagAttack)
end

function Class_Card:reCalculateMagDefence()
	--法术防御=(卡牌基础法术防御+丹药增加法术防御+武力*等级*武力参数+装备主属性法术防御)*(1+附加法术防御倍数)+异兽法术防御+附加法术防御
	self.MagDefence = (self.tbCsvBase.BaseMagDefence + self.tbDanYaoProps[Enum_PropType.MagDefence] + self.MagicPoints*self.nLevel*self.tbProfessParams.magic_defence_moduls + self.tbEquipMainProps[Enum_PropType.MagDefence])
		*(g_BasePercent
			+ self.tbCardEquipAddProps[Enum_PropType.MagDefencePercent]
			+ self.tbCardGroupAddProps[Enum_PropType.MagDefencePercent]
			+ self.tbMasterAddProps[Enum_PropType.MagDefencePercent]
			+ self.tbCardEquipAddProps[Enum_PropType.AllDefencePercent]
			+ self.tbCardGroupAddProps[Enum_PropType.AllDefencePercent]
			+ self.tbMasterAddProps[Enum_PropType.AllDefencePercent]
		)/g_BasePercent
		+ self.tbFateProps[Enum_PropType.MagDefence]
		+ self.tbCardEquipAddProps[Enum_PropType.MagDefence]
		+ self.tbCardGroupAddProps[Enum_PropType.MagDefence]
		+ self.tbMasterAddProps[Enum_PropType.MagDefence]
		+ self.tbCardEquipAddProps[Enum_PropType.AllDefence]
		+ self.tbCardGroupAddProps[Enum_PropType.AllDefence]
		+ self.tbMasterAddProps[Enum_PropType.AllDefence]
	self.MagDefence = math.floor(self.MagDefence)
end

function Class_Card:reCalculateSkillAttack()
	--绝技攻击=(卡牌基础绝技攻击+丹药增加绝技攻击+武力*等级*武力参数+装备主属性绝技攻击)*(1+附加绝技攻击倍数)+异兽绝技攻击+附加绝技攻击
	self.SkillAttack = (self.tbCsvBase.BaseSkillAttack + self.tbDanYaoProps[Enum_PropType.SkillAttack] + self.SkillPoints*self.nLevel*self.tbProfessParams.skill_attack_moduls + self.tbEquipMainProps[Enum_PropType.SkillAttack])
		*(g_BasePercent
			+ self.tbCardEquipAddProps[Enum_PropType.SkillAttackPercent]
			+ self.tbCardGroupAddProps[Enum_PropType.SkillAttackPercent]
			+ self.tbMasterAddProps[Enum_PropType.SkillAttackPercent]
			+ self.tbCardEquipAddProps[Enum_PropType.AllAttackPercent]
			+ self.tbCardGroupAddProps[Enum_PropType.AllAttackPercent]
			+ self.tbMasterAddProps[Enum_PropType.AllAttackPercent]
		)/g_BasePercent
		+ self.tbFateProps[Enum_PropType.SkillAttack]
		+ self.tbCardEquipAddProps[Enum_PropType.SkillAttack]
		+ self.tbCardGroupAddProps[Enum_PropType.SkillAttack]
		+ self.tbMasterAddProps[Enum_PropType.SkillAttack]
		+ self.tbCardEquipAddProps[Enum_PropType.AllAttack]
		+ self.tbCardGroupAddProps[Enum_PropType.AllAttack]
		+ self.tbMasterAddProps[Enum_PropType.AllAttack]
	self.SkillAttack = math.floor(self.SkillAttack)
end

function Class_Card:reCalculateSkillDefence()
	--绝技防御=(卡牌基础绝技防御+丹药增加绝技防御+武力*等级*武力参数+装备主属性绝技攻击)*(1+附加绝技防御倍数)+异兽绝技防御+附加绝技防御
	self.SkillDefence = (self.tbCsvBase.BaseSkillDefence + self.tbDanYaoProps[Enum_PropType.SkillDefence] + self.SkillPoints*self.nLevel*self.tbProfessParams.skill_defence_moduls+ self.tbEquipMainProps[Enum_PropType.SkillDefence])
		*(g_BasePercent
			+ self.tbCardEquipAddProps[Enum_PropType.SkillDefencePercent]
			+ self.tbCardGroupAddProps[Enum_PropType.SkillDefencePercent]
			+ self.tbMasterAddProps[Enum_PropType.SkillDefencePercent]
			+ self.tbCardEquipAddProps[Enum_PropType.AllDefencePercent]
			+ self.tbCardGroupAddProps[Enum_PropType.AllDefencePercent]
			+ self.tbMasterAddProps[Enum_PropType.AllDefencePercent]
		)/g_BasePercent
		+ self.tbFateProps[Enum_PropType.SkillDefence]
		+ self.tbCardEquipAddProps[Enum_PropType.SkillDefence]
		+ self.tbCardGroupAddProps[Enum_PropType.SkillDefence]
		+ self.tbMasterAddProps[Enum_PropType.SkillDefence]
		+ self.tbCardEquipAddProps[Enum_PropType.AllDefence]
		+ self.tbCardGroupAddProps[Enum_PropType.AllDefence]
		+ self.tbMasterAddProps[Enum_PropType.AllDefence]
	self.SkillDefence = math.floor(self.SkillDefence)
end

function Class_Card:reCalculateCriticalChance()
	-- cclog("====基础暴击===="..self.tbCsvBase.CriticalChance)
	-- cclog("====妖兽暴击===="..self.tbFateProps[Enum_PropType.CriticalChance])
	-- cclog("====装备附加暴击===="..self.tbCardEquipAddProps[Enum_PropType.CriticalChance])
	-- cclog("====组合暴击===="..self.tbCardGroupAddProps[Enum_PropType.CriticalChance])
	-- cclog("====主角附加暴击===="..self.tbMasterAddProps[Enum_PropType.CriticalChance])
	self.CriticalChance = self.tbCsvBase.CriticalChance
		+ self.tbFateProps[Enum_PropType.CriticalChance]
		+ self.tbCardEquipAddProps[Enum_PropType.CriticalChance]
		+ self.tbCardGroupAddProps[Enum_PropType.CriticalChance]
		+ self.tbMasterAddProps[Enum_PropType.CriticalChance]
end

function Class_Card:reCalculateCriticalResistance()
	-- cclog("====基础韧性===="..self.tbCsvBase.CriticalResistance)
	-- cclog("====妖兽韧性===="..self.tbFateProps[Enum_PropType.CriticalResistance])
	-- cclog("====装备附加韧性===="..self.tbCardEquipAddProps[Enum_PropType.CriticalResistance])
	-- cclog("====组合韧性===="..self.tbCardGroupAddProps[Enum_PropType.CriticalResistance])
	-- cclog("====主角附加韧性===="..self.tbMasterAddProps[Enum_PropType.CriticalResistance])
	self.CriticalResistance = self.tbCsvBase.CriticalResistance
		+ self.tbFateProps[Enum_PropType.CriticalResistance]
		+ self.tbCardEquipAddProps[Enum_PropType.CriticalResistance]
		+ self.tbCardGroupAddProps[Enum_PropType.CriticalResistance]
		+ self.tbMasterAddProps[Enum_PropType.CriticalResistance]
end


function Class_Card:reCalculateCriticalStrike()
	-- cclog("====基础必杀===="..self.tbCsvBase.CriticalStrike)
	-- cclog("====妖兽必杀===="..self.tbFateProps[Enum_PropType.CriticalStrike])
	-- cclog("====装备附加必杀===="..self.tbCardEquipAddProps[Enum_PropType.CriticalStrike])
	-- cclog("====组合必杀===="..self.tbCardGroupAddProps[Enum_PropType.CriticalStrike])
	-- cclog("====主角附加必杀===="..self.tbMasterAddProps[Enum_PropType.CriticalStrike])
	self.CriticalStrike = self.tbCsvBase.CriticalStrike
		+ self.tbFateProps[Enum_PropType.CriticalStrike]
		+ self.tbCardEquipAddProps[Enum_PropType.CriticalStrike]
		+ self.tbCardGroupAddProps[Enum_PropType.CriticalStrike]
		+ self.tbMasterAddProps[Enum_PropType.CriticalStrike]
end

function Class_Card:reCalculateCriticalStrikeResistance()
	-- cclog("====基础刚毅===="..self.tbCsvBase.CriticalStrikeResistance)
	-- cclog("====妖兽刚毅===="..self.tbFateProps[Enum_PropType.CriticalStrikeResistance])
	-- cclog("====装备附加刚毅===="..self.tbCardEquipAddProps[Enum_PropType.CriticalStrikeResistance])
	-- cclog("====组合刚毅===="..self.tbCardGroupAddProps[Enum_PropType.CriticalStrikeResistance])
	-- cclog("====主角附加刚毅===="..self.tbMasterAddProps[Enum_PropType.CriticalStrikeResistance])
	self.CriticalStrikeResistance = self.tbCsvBase.CriticalStrikeResistance
		+ self.tbFateProps[Enum_PropType.CriticalStrikeResistance]
		+ self.tbCardEquipAddProps[Enum_PropType.CriticalStrikeResistance]
		+ self.tbCardGroupAddProps[Enum_PropType.CriticalStrikeResistance]
		+ self.tbMasterAddProps[Enum_PropType.CriticalStrikeResistance]
end

function Class_Card:reCalculateHitChance()
	-- cclog("====基础命中===="..self.tbCsvBase.HitChance)
	-- cclog("====妖兽命中===="..self.tbFateProps[Enum_PropType.HitChance])
	-- cclog("====装备附加命中===="..self.tbCardEquipAddProps[Enum_PropType.HitChance])
	-- cclog("====组合命中===="..self.tbCardGroupAddProps[Enum_PropType.HitChance])
	-- cclog("====主角附加命中===="..self.tbMasterAddProps[Enum_PropType.HitChance])
	self.HitChance = self.tbCsvBase.HitChance
		+ self.tbFateProps[Enum_PropType.HitChance]
		+ self.tbCardEquipAddProps[Enum_PropType.HitChance]
		+ self.tbCardGroupAddProps[Enum_PropType.HitChance]
		+ self.tbMasterAddProps[Enum_PropType.HitChance]
end

function Class_Card:reCalculateDodgeChance()
	-- cclog("====基础闪避===="..self.tbCsvBase.DodgeChance)
	-- cclog("====妖兽闪避===="..self.tbFateProps[Enum_PropType.DodgeChance])
	-- cclog("====装备附加闪避===="..self.tbCardEquipAddProps[Enum_PropType.DodgeChance])
	-- cclog("====组合闪避===="..self.tbCardGroupAddProps[Enum_PropType.DodgeChance])
	-- cclog("====主角附加闪避===="..self.tbMasterAddProps[Enum_PropType.DodgeChance])
	self.DodgeChance = self.tbCsvBase.DodgeChance
		+ self.tbFateProps[Enum_PropType.DodgeChance]
		+ self.tbCardEquipAddProps[Enum_PropType.DodgeChance]
		+ self.tbCardGroupAddProps[Enum_PropType.DodgeChance]
		+ self.tbMasterAddProps[Enum_PropType.DodgeChance]
end

function Class_Card:reCalculatePenetrateChance()
	-- cclog("====基础破击===="..self.tbCsvBase.PenetrateChance)
	-- cclog("====妖兽破击===="..self.tbFateProps[Enum_PropType.PenetrateChance])
	-- cclog("====装备附加破击===="..self.tbCardEquipAddProps[Enum_PropType.PenetrateChance])
	-- cclog("====组合破击===="..self.tbCardGroupAddProps[Enum_PropType.PenetrateChance])
	-- cclog("====主角附加破击===="..self.tbMasterAddProps[Enum_PropType.PenetrateChance])
	self.PenetrateChance = self.tbCsvBase.PenetrateChance
		+ self.tbFateProps[Enum_PropType.PenetrateChance]
		+ self.tbCardEquipAddProps[Enum_PropType.PenetrateChance]
		+ self.tbCardGroupAddProps[Enum_PropType.PenetrateChance]
		+ self.tbMasterAddProps[Enum_PropType.PenetrateChance]
end

function Class_Card:reCalculateBlockChance()
	-- cclog("====基础格挡===="..self.tbCsvBase.BlockChance)
	-- cclog("====妖兽格挡===="..self.tbFateProps[Enum_PropType.BlockChance])
	-- cclog("====装备附加格挡===="..self.tbCardEquipAddProps[Enum_PropType.BlockChance])
	-- cclog("====组合格挡===="..self.tbCardGroupAddProps[Enum_PropType.BlockChance])
	-- cclog("====主角附加格挡===="..self.tbMasterAddProps[Enum_PropType.BlockChance])
	self.BlockChance = self.tbCsvBase.BlockChance
		+ self.tbFateProps[Enum_PropType.BlockChance]
		+ self.tbCardEquipAddProps[Enum_PropType.BlockChance]
		+ self.tbCardGroupAddProps[Enum_PropType.BlockChance]
		+ self.tbMasterAddProps[Enum_PropType.BlockChance]
end

function Class_Card:reCalculateBattlePropByType(nPropType)
	if not self.tbCalculatePropFunc then
		self.tbCalculatePropFunc = {}
		self.tbCalculatePropFunc[Enum_PropType.HPMax] = handler(self, self.reCalculateHPMax)
		self.tbCalculatePropFunc[Enum_PropType.PhyAttack] = handler(self, self.reCalculatePhyAttack)
		self.tbCalculatePropFunc[Enum_PropType.PhyDefence] = handler(self, self.reCalculatePhyDefence)
		self.tbCalculatePropFunc[Enum_PropType.MagAttack] = handler(self, self.reCalculateMagAttack)
		self.tbCalculatePropFunc[Enum_PropType.MagDefence] = handler(self, self.reCalculateMagDefence)
		self.tbCalculatePropFunc[Enum_PropType.SkillAttack] = handler(self, self.reCalculateSkillAttack)
		self.tbCalculatePropFunc[Enum_PropType.SkillDefence] = handler(self, self.reCalculateSkillDefence)
		self.tbCalculatePropFunc[Enum_PropType.CriticalChance] = handler(self, self.reCalculateCriticalChance)
		self.tbCalculatePropFunc[Enum_PropType.CriticalResistance] = handler(self, self.reCalculateCriticalResistance)
		self.tbCalculatePropFunc[Enum_PropType.CriticalStrike] = handler(self, self.reCalculateCriticalStrike)
		self.tbCalculatePropFunc[Enum_PropType.CriticalStrikeResistance] = handler(self, self.reCalculateCriticalStrikeResistance)
		self.tbCalculatePropFunc[Enum_PropType.HitChance] = handler(self, self.reCalculateHitChance)
		self.tbCalculatePropFunc[Enum_PropType.DodgeChance] = handler(self, self.reCalculateDodgeChance)
		self.tbCalculatePropFunc[Enum_PropType.PenetrateChance] = handler(self, self.reCalculatePenetrateChance)
		self.tbCalculatePropFunc[Enum_PropType.BlockChance] = handler(self, self.reCalculateBlockChance)
		self.tbCalculatePropFunc[Enum_PropType.ManaMaxPercent] = nil
		self.tbCalculatePropFunc[Enum_PropType.HPMaxPercent] = handler(self, self.reCalculateHPMax)
		self.tbCalculatePropFunc[Enum_PropType.PhyAttackPercent] = handler(self, self.reCalculatePhyAttack)
		self.tbCalculatePropFunc[Enum_PropType.PhyDefencePercent] = handler(self, self.reCalculatePhyDefence)
		self.tbCalculatePropFunc[Enum_PropType.MagAttackPercent] = handler(self, self.reCalculateMagAttack)
		self.tbCalculatePropFunc[Enum_PropType.MagDefencePercent] = handler(self, self.reCalculateMagDefence)
		self.tbCalculatePropFunc[Enum_PropType.SkillAttackPercent] = handler(self, self.reCalculateSkillAttack)
		self.tbCalculatePropFunc[Enum_PropType.SkillDefencePercent] = handler(self, self.reCalculateSkillDefence)
	end
	self.tbCalculatePropFunc[nPropType]()
end

--获取生命上限HPMax
function Class_Card:getHPMax()
	return self.HPMax
end

--获取气势上限HPMax
function Class_Card:getManaMax()
	return self.ManaMax
end

--获取物理攻击PhyAttack
function Class_Card:getPhyAttack()
	return self.PhyAttack
end

--获取物理防御PhyDefence
function Class_Card:getPhyDefence()
	return self.PhyDefence
end

--获取法术攻击MagAttack
function Class_Card:getMagAttack()
	return self.MagAttack
end

--获取法术防御MagDefence
function Class_Card:getMagDefence()
	return self.MagDefence
end

--获取绝技攻击SkillAttack
function Class_Card:getSkillAttack()
	return self.SkillAttack
end

--获取绝技防御SkillDefence
function Class_Card:getSkillDefence()
	return self.SkillDefence
end

--获取暴击CriticalChance
function Class_Card:getCriticalChance()
	return self.CriticalChance
end

--获取韧性CriticalResistance
function Class_Card:getCriticalResistance()
	return self.CriticalResistance
end

--获取必杀CriticalStrike
function Class_Card:getCriticalStrike()
	return self.CriticalStrike
end

--获取刚毅CriticalStrikeResistance
function Class_Card:getCriticalStrikeResistance()
	return self.CriticalStrikeResistance
end

--获取命中HitChance
function Class_Card:getHitChance()
	return self.HitChance
end

--获取闪避DodgeChance
function Class_Card:getDodgeChance()
	return self.DodgeChance
end

--获取破击PenetrateChance
function Class_Card:getPenetrateChance()
	return self.PenetrateChance
end

--获取格挡BlockChance
function Class_Card:getBlockChance()
	return self.BlockChance
end

--个人先攻值 = 伙伴Level*5 + 伙伴境界Level*50 + (武力+绝技+法术)/3 + 装备强化等级总和*2 + 装备星等*50 + 伙伴属性附加的先攻值 + 命力/10
function Class_Card:getAttackPower()
	if self.preattack and self.preattack > 0 then
		return self.preattack
	end


	-- cclog("==============客户端自己计算卡牌先攻值=================")
	-- local nStrongthenLev = 0
	-- local nStarLevel = 0
	-- local nRefineLevel = 0
	-- for i =1, #self.tbEquipIdList do
		-- local nEquipID = self.tbEquipIdList[i]
		-- local GameObj_Equip = g_Hero:getEquipObjByServID(nEquipID)
		-- if GameObj_Equip then
			-- nStrongthenLev = nStrongthenLev + GameObj_Equip:getStrengthenLev()
			-- nStarLevel = nStarLevel + GameObj_Equip:getStarLevel()
			-- nRefineLevel = nRefineLevel + GameObj_Equip:getRefineLev()
		-- end
	-- end

	-- return  self.nLevel*5
			-- + self.nEvoluteLevel*50
			-- + self.nStarLevel*100
			-- + self.nRealmLevel*50
			-- + self.MagicPoints
			-- + self.ForcePoints
			-- + self.SkillPoints
			-- + nStrongthenLev*2
			-- + nStarLevel*50
			-- + nRefineLevel*50
			-- + math.floor(self:getFateExp()/100)
			-- + self.tbMasterAddProps[Enum_PropType.Initiative]
	return 0
end

--个人战斗力 = 生命上限+(物理攻击+法术攻击+绝技攻击)*(1+暴击+必杀+命中+破击)+(物理防御+法术防御+绝技防御)*(1+韧性+刚毅+闪避+格挡)
function Class_Card:getCardStrength()
	if self.fight_point and self.fight_point > 0 then
		return self.fight_point
	end

	-- cclog("=============客户端自己计算卡牌战斗力================")
	-- local Csv_CardExp = g_DataMgr:getCsvConfigByOneKey("CardExp", self.nLevel)
	-- local tbCsvBase = self.tbCsvBase
	-- return math.floor(
		-- self.HPMax
		-- +(self.PhyAttack+self.MagAttack+self.SkillAttack)
		-- *(1
			-- +(self.CriticalChance+self.CriticalStrike+self.HitChance+self.PenetrateChance)/g_BasePercent
			-- +(tbCsvBase.CriticalChance+tbCsvBase.CriticalStrike+tbCsvBase.HitChance+tbCsvBase.PenetrateChance)/g_BasePercent
		-- )
		-- +(self.PhyDefence+self.MagDefence+self.SkillDefence)
		-- *(1
			-- +(self.CriticalResistance+self.CriticalStrikeResistance+self.DodgeChance+self.BlockChance)/g_BasePercent
			-- +(tbCsvBase.CriticalResistance+tbCsvBase.CriticalStrikeResistance+tbCsvBase.DodgeChance+tbCsvBase.BlockChance)/g_BasePercent
		-- )
	-- )
	return 0
end