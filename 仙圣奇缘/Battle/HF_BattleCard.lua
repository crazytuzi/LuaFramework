--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-15 15:03
-- 版  本:	1.0
-- 描  述:	战斗伙伴
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CBattleCard = class("CBattleCard")
CBattleCard.__index = CBattleCard

function CBattleCard:initBattleCard(tbCardInfo)
	self.apos = tbCardInfo.arraypos
	self.cfgid = tbCardInfo.configid
	self.star = tbCardInfo.star_lv
	self.card_lv = tbCardInfo.card_lv
	self.is_card = tbCardInfo.is_card
	self.normal_skill_lv = tbCardInfo.normal_skill_lv or 1
	self.powerful_skill_lv = tbCardInfo.powerful_skill_lv or 1
	
	self.hp = tbCardInfo.hp
	self.max_hp = tbCardInfo.max_hp
	self.mana = tbCardInfo.sp
	self.max_mana = tbCardInfo.max_sp
	self.phy_attack = tbCardInfo.phy_attack or 0
	self.phy_defence = tbCardInfo.phy_defence or 0
	self.mag_attack = tbCardInfo.mag_attack or 0
	self.mag_defence = tbCardInfo.mag_defence or 0
	self.skill_attack = tbCardInfo.skill_attack or 0
	self.skill_defence = tbCardInfo.skill_defence or 0
	self.critical_chance = tbCardInfo.critical_chance or 0
	self.critical_resistance = tbCardInfo.critical_resistance or 0
	self.critical_strike = tbCardInfo.critical_strike or 0
	self.critical_strikeresistance = tbCardInfo.critical_strikeresistance or 0
	self.hit_change = tbCardInfo.hit_change or 0
	self.dodge_chance = tbCardInfo.dodge_chance or 0
	self.penetrate_chance = tbCardInfo.penetrate_chance or 0
	self.block_chance = tbCardInfo.block_chance or 0
	self.damage_reduction = tbCardInfo.damage_reduction or 0
	
	self.preattack = tbCardInfo.preattack
    self.is_def = tbCardInfo.is_def
	self.breachlv = tbCardInfo.breachlv or 1
	self.attend_step = tbCardInfo.attend_step or 0
	
	self.unique_id = 0
	if self.is_def == false then
		self.unique_id = self.apos
	else
		self.unique_id = 100 + self.apos
	end
	
	local Csv_CardExp = g_DataMgr:getCsvConfigByOneKey("CardExp", self.card_lv)
	self.rate_factor = Csv_CardExp.RateFactor
	

	self.lv_list = {}
	for i = 1, #tbCardInfo.skill_lv_list do
		table.insert(self.lv_list, tbCardInfo.skill_lv_list[i])
	end
	if not self.is_def then
		self.init_mana = tbCardInfo.sp
		self.cardid = tbCardInfo.cardid
	end
	
	self.die_drop_info = {}
	
	if tbCardInfo.die_drop_info ~= nil then
		for key2, value2 in ipairs(tbCardInfo.die_drop_info) do
			local tbdie_drop_info = {}
			tbdie_drop_info.drop_item_type = value2.drop_item_type
			tbdie_drop_info.drop_item_num = value2.drop_item_num
			tbdie_drop_info.drop_item_config_id = value2.drop_item_config_id
			tbdie_drop_info.drop_item_star_lv = value2.drop_item_star_lv
			table.insert(self.die_drop_info, tbdie_drop_info)
		end
	end
	
	self.use_skill_index = 1
	if self.is_card then
		self:initCardSkill()
	else
		self:initMonsterSkill()
	end
	--累计掉血
	self.losthp = 0
	
	self.effectmgr = CEffectMgr:new()
	self.effectmgr:clear()
	
	-- self:showBattleCardProp()
end

function CBattleCard:isDieDrop()
	return #self.die_drop_info > 0
end

--技能等级
function CBattleCard:getSkillLv(nIndex)
	return self.lv_list[nIndex] or 0
end

function CBattleCard:getSkillAddProp(nIndex)
	return self.tbSkillEvolute[nIndex]
end

function CBattleCard:isDie()
	return self.hp <= 0
end

function CBattleCard:getDieDrop()
	return self.die_drop_info
end

--血量上限
function CBattleCard:get_maxhp()
	return self.max_hp 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_MaxHP) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_MaxHP) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_HPMaxPercent) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_HPMaxPercent)
end

--怒气上限
function CBattleCard:get_maxMana()
	return self.max_mana 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_MaxMana) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_MaxMana) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_ManaMaxPercent) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_ManaMaxPercent) 
end

--武力攻击
function CBattleCard:get_phy_attack()
	return self.phy_attack 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_PhyAtk) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_PhyAtk) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_PhyAttackPercent) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_PhyAttackPercent) 
end

--物理防御
function CBattleCard:get_phy_defence()
	return self.phy_defence 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_PhyDef) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_PhyDef) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_PhyDefencePercent) 
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_PhyDefencePercent) 
end

--法术攻击
function CBattleCard:get_mag_attack()
	return self.mag_attack 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_MagAtk)            --增加法术攻击属性
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_MagAtk)         --减少法术攻击属性

	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_MagAttackPercent)   --增加法术攻击万分比属性
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_MagAttackPercent) --减少法术攻击万分比属性
end

--法术防御
function CBattleCard:get_mag_defence()
	return self.mag_defence 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_MagDef)            --减少法术防御属性
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_MagDef)               --增加法术防御属性

    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_MagDefencePercent)     --增加法术防御万分比属性
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_MagDefencePercent)  --减少法术防御万分比属性
end

--绝技攻击
function CBattleCard:get_skill_attack()
	return self.skill_attack 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_SkillAtk)              --增加绝技攻击属性
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_SkillAtk)           --减少绝技攻击属性

	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_SkillAttackPercent)     --增加绝技攻击万分比属性
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_SkillAttackPercent)  --减少绝技攻击万分比属性
end

--绝技防御
function CBattleCard:get_skill_defence()
	return self.skill_defence 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_SkillDef)              --增加绝技防御属性 19
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_SkillDef)           --减少绝技防御属性 20

	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_SkillDefencePercent)   --增加绝技防御万分比属性 51
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_SkillDefencePercent) --减少绝技防御万分比属性 52
end

function CBattleCard:get_critical_chance()
	return self.critical_chance 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_CriticalChance)    --增加暴击属性 21
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_CriticalChance) --减少暴击属性 22
end

--韧性
function CBattleCard:get_critical_resistance()
	return self.critical_resistance 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_CriticalResistance) --增加韧性属性 23
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_CriticalResistance) --减少韧性属性 24
end

--必杀
function CBattleCard:get_critical_strike()
	return self.critical_strike 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_CriticalStrike) --增加必杀属性 25
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_CriticalStrike) --减少必杀属性 26
end

--刚毅
function CBattleCard:get_critical_strikeresistance()
	return self.critical_strikeresistance 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_CriticalStrikeResistance)  --增加刚毅属性 27
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_CriticalStrikeResistance) --减少刚毅属性 28
end

--命中
function CBattleCard:get_hit_change()
	return self.hit_change 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_HitChance)     --增加命中属性 29
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_HitChance)  --减少命中属性 30
end

--闪避
function CBattleCard:get_dodge_chance()
	return self.dodge_chance 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_DodgeChance)   --增加闪避属性 31
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_DodgeChance) --减少闪避属性 32
end

--减少穿刺属性
function CBattleCard:get_penetrate_chance()
	return self.penetrate_chance 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_PenetrateChance)       --增加穿刺属性 33
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_PenetrateChance)    --减少穿刺属性  34
end

--格挡
function CBattleCard:get_block_chance()
	return self.block_chance 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_BlockChance)       --增加格挡属性 35
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_BlockChance)    --减少格挡属性 36
end

--免伤
function CBattleCard:get_damage_reduction()
	return self.damage_reduction 
    + self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Add_Damage_Reduction) --增加万分比免伤
	+ self.effectmgr:GetEffectData(macro_pb.Skill_Effect_Reduce_Damage_Reduction) --减少万分比免伤
end

function CBattleCard:get_rate_factor()
	return self.rate_factor
end

--
function CBattleCard:getHitMana()
	return self.hit_mana or 0
end

function CBattleCard:updateHitMana(nMana)
	self.hit_mana = self.mana
end

--调整血量
function CBattleCard:setLostHp(nDamage)
	if not nDamage or nDamage == 0 or self.hp <= 0 then
		return
	end

	local nOldHP = self.hp
	self.hp = self.hp - nDamage
	self.hp = math.max(self.hp, 0)
	self.hp = math.min(self.hp, self:get_maxhp())
	
    local nHP = self.losthp + nOldHP - self.hp
	self.losthp = nHP
	self.losthp = math.max(self.losthp, 0)
	self.losthp = math.min(self.losthp, self:get_maxhp())
end

--获取掉血总量
function CBattleCard:getLostHP()
	return self.losthp
end

--调整怒气
function CBattleCard:addMana(nSp)
	self.mana = self.mana + nSp
--	self.mana = math.min(self.mana, g_BattleMgr.mana_limit * 2) 
    self.mana = math.min(self.mana, self.max_mana) 
    
end

function CBattleCard:reduceMana(nMana)
	self.mana = self.mana - nMana
	self.mana = math.max(0, self.mana)
end


--是否能使用技能
function CBattleCard:isCanSkill()
	if self.effectmgr:isSilence(self) then
		return true
	end
	return self.mana >= 100
end

--是否略过这回合
function CBattleCard:isSkip()
	if self.effectmgr:isDizzy() then
		return true
	end
	return false
end

--是否治疗技能
function CBattleCard:isCureSkill()
	local tbCurrentSkill = self:getCurrentSkill()
	return tbCurrentSkill.FormulaType >= macro_pb.FormulaType_Cure_Abs and tbCurrentSkill.FormulaType <= macro_pb.FormulaType_Cure_Mag_Skill
end

--是否合击技能
function CBattleCard:isFitSkill()
	local tbCurrentSkill = self:getCurrentSkill()
	if tbCurrentSkill.Object == macro_pb.Skill_Atk_Object_Enemy 
		and (not tbCurrentSkill.AttackArea or tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_Single)
		and tbCurrentSkill.FitType and tbCurrentSkill.FitType > 0 then
		return true
	else
		return false
	end
end

--是否连击技能
function CBattleCard:isRepeatedHit()
	local tbCurrentSkill = self:getCurrentSkill()
	if tbCurrentSkill.Object == macro_pb.Skill_Atk_Object_Enemy 
		and (tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_DoubleHit
		or tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_TripleHit) then
		return true
	else
		return false
	end
	
end

--是否绝技
function CBattleCard:isPowerSkill()
	return self.use_skill_index > 1 and self.use_skill_index <= 4
end

--当前使用的技能
function CBattleCard:getCurrentSkill()
	return self.tbCurrentSkill[self.use_skill_index]
end

--当前技能索引
function CBattleCard:getCurrentSkillIndex()
	return self.use_skill_index
end


--普通攻击技能
function CBattleCard:getCommonSkill()
	return self.tbCurrentSkill[1]
end


--设置下次行动使用技能
function CBattleCard:setCurrentUseSkill(nIndex)
	self.use_skill_index = nIndex
end

--初始化技能
function CBattleCard:initCardSkill()
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(self.cfgid, self.star)
	self.tbCurrentSkill = {}
	self.profession = CSV_CardBase.Profession
	self.tbCurrentSkill[1] = g_DataMgr:getSkillBaseCsv(CSV_CardBase.NormalSkillID, CSV_CardBase.NormalSkillLevel)
	self.tbCurrentSkill[2] = g_DataMgr:getSkillBaseCsv(CSV_CardBase.PowerfulSkillID1, CSV_CardBase.PowerfulSkillLevel1)
	self.tbCurrentSkill[3] = g_DataMgr:getSkillBaseCsv(CSV_CardBase.PowerfulSkillID2, CSV_CardBase.PowerfulSkillLevel2)
	self.tbCurrentSkill[4] = g_DataMgr:getSkillBaseCsv(CSV_CardBase.PowerfulSkillID3, CSV_CardBase.PowerfulSkillLevel3)
	self.tbCurrentSkill[5] = g_DataMgr:getSkillBaseCsv(CSV_CardBase.RestrikeSkillID, CSV_CardBase.RestrikeSkillLevel)
	self.tbSkillEvolute = {}

	self.tbSkillEvolute[1] = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",CSV_CardBase.PowerfulSkillID1) 
	self.tbSkillEvolute[2] = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",CSV_CardBase.PowerfulSkillID2)  
	self.tbSkillEvolute[3] = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",CSV_CardBase.PowerfulSkillID3)
end

function CBattleCard:initMonsterSkill()
	local tbMonsterBase = g_DataMgr:getMonsterBaseCsv(self.cfgid)
	self.tbCurrentSkill = {}
	self.profession = tbMonsterBase.Profession
	
	if g_BattleMgr and (g_BattleMgr:getBattleType() == macro_pb.Battle_Atk_Type_WorldBoss
		or g_BattleMgr:getBattleType() == macro_pb.Battle_Atk_Type_SceneBoss
		or g_BattleMgr:getBattleType() == macro_pb.Battle_Atk_Type_GuildWorldBoss
		or g_BattleMgr:getBattleType() == macro_pb.Battle_Atk_Type_GuildSceneBoss)
	then
		self.tbCurrentSkill[1] = g_DataMgr:getSkillBaseCsv(tbMonsterBase.RestrikeSkillID, tbMonsterBase.NormalSkillLevel)
	else
		self.tbCurrentSkill[1] = g_DataMgr:getSkillBaseCsv(tbMonsterBase.NormalSkillID, tbMonsterBase.NormalSkillLevel)
	end
	self.tbCurrentSkill[2] = g_DataMgr:getSkillBaseCsv(tbMonsterBase.PowerfulSkillID1, tbMonsterBase.PowerfulSkillLevel1)
	self.tbCurrentSkill[3] = g_DataMgr:getSkillBaseCsv(tbMonsterBase.PowerfulSkillID2, tbMonsterBase.PowerfulSkillLevel2)
	self.tbCurrentSkill[4] = g_DataMgr:getSkillBaseCsv(tbMonsterBase.PowerfulSkillID3, tbMonsterBase.PowerfulSkillLevel3)
	self.tbCurrentSkill[5] = g_DataMgr:getSkillBaseCsv(tbMonsterBase.RestrikeSkillID, tbMonsterBase.RestrikeSkillLevel)
	self.tbSkillEvolute = {}
end

--攻击己方，治疗，增益状态之类的
function CBattleCard:getSelfAtkDestation(tbAttackerList, tbDefencerList)
	local tbCurSkill = self:getCurrentSkill()
	if tbCurSkill.AttackArea == macro_pb.Skill_Atk_Area_Self then
		return self.apos
	else
		return self:getAtkDestationCsv(tbAttackerList, tbDefencerList)
	end
end

--攻击敌方
function CBattleCard:getAtkDestationCsv(tbAttackerList, tbDefencerList)
	local nEumnBattleSide = 0
	if tbDefencerList.is_def then
		nEumnBattleSide = 1
	end

	--混乱
	if self.effectmgr:isConfused(self) then
		for i=1, macro_pb.MAX_ARRY_SLOT_NUM do
			local tbCard = tbAttackerList.tbCardList[i]
			if tbCard and tbCard.hp > 0 and tbCard.apos ~= self.apos then
				if tbAttackerList.is_def then
					nEumnBattleSide = 1
				else
					nEumnBattleSide = 0
				end
			
				return tbCard.apos, nEumnBattleSide
			end
		end
	end
	
	--狂暴
	if self.effectmgr:isFrenzy(self) then
		for i=1, macro_pb.MAX_ARRY_SLOT_NUM do
			local tbCard = tbDefencerList.tbCardList[i]
			if tbCard and tbCard.hp > 0 and tbCard.apos ~= self.apos then
				return tbCard.apos, nEumnBattleSide
			end
		end
	end

	local Csv_AtkDestation = g_DataMgr:getAtkDestationCsv(self.apos)
    local tbDefPos = {}
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos1)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos2)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos3)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos4)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos5)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos6)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos7)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos8)
    table.insert(tbDefPos, Csv_AtkDestation.DefArrayPos9)

	for k, v in pairs(tbDefPos) do
		if TbBattleReport ~= nil and TbBattleReport ~= {} then
			if TbBattleReport.tbGameFighters_OnWnd ~= nil and TbBattleReport.tbGameFighters_OnWnd ~= {} then
				if nEumnBattleSide == 1 then
					local nPos = v + 10
					if TbBattleReport.tbGameFighters_OnWnd[nPos] ~= nil and TbBattleReport.tbGameFighters_OnWnd[nPos] ~= {} then
						local GameObj_Defencer = tbDefencerList.tbCardList[v]
						if GameObj_Defencer and GameObj_Defencer.hp > 0 then
							return GameObj_Defencer.apos, nEumnBattleSide
						end
					end
				else
					local nPos = v
					if TbBattleReport.tbGameFighters_OnWnd[nPos] ~= nil and TbBattleReport.tbGameFighters_OnWnd[nPos] ~= {} then
						local GameObj_Defencer = tbDefencerList.tbCardList[v]
						if GameObj_Defencer and GameObj_Defencer.hp > 0 then
							return GameObj_Defencer.apos, nEumnBattleSide
						end
					end
				end
			else
				SendError("客户端战斗调试====CBattleCard:getAtkDestationCsv=====TbBattleReport.tbGameFighters_OnWnd is nil or empty")
			end
		else
			SendError("客户端战斗调试====CBattleCard:getAtkDestationCsv=====TbBattleReport is nil or empty")
		end
	end
	return -1, nEumnBattleSide
end

--卡牌名字
function CBattleCard:getName()
	local tbCsvBase = nil
	if self.is_def == false then
		tbCsvBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("CardBase", self.cfgid, self.star)
	else
		tbCsvBase = g_DataMgr:getCsvConfig_FirstKeyData("MonsterBase", self.cfgid)
	end
	return tbCsvBase.Name or ""
end

--打印属性
function CBattleCard:showBattleCardProp()
	local tbCsvBase = nil
	if self.is_def == false then
		tbCsvBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("CardBase", self.cfgid, self.star)
	else
		tbCsvBase = g_DataMgr:getCsvConfig_FirstKeyData("MonsterBase", self.cfgid)
	end

	cclog("======服务端下发属性值======当前卡牌:"..tbCsvBase.Name)
	cclog("======服务端下发属性值======当前生命:"..self.hp)
	cclog("======服务端下发属性值======当前生命:"..self.hp)
	cclog("======服务端下发属性值======生命上限:"..self.max_hp)
	cclog("======服务端下发属性值======当前怒气:"..self.mana)
	cclog("======服务端下发属性值======怒气上限:"..self.max_mana)
	cclog("======服务端下发属性值======物理攻击:"..self.phy_attack)
	cclog("======服务端下发属性值======物理防御:"..self.phy_defence)
	cclog("======服务端下发属性值======法术攻击:"..self.mag_attack)
	cclog("======服务端下发属性值======法术防御:"..self.mag_defence)
	cclog("======服务端下发属性值======绝技攻击:"..self.skill_attack)
	cclog("======服务端下发属性值======绝技防御:"..self.skill_defence)
	cclog("======服务端下发属性值======暴击:"..self.critical_chance)
	cclog("======服务端下发属性值======韧性:"..self.critical_resistance)
	cclog("======服务端下发属性值======必杀:"..self.critical_strike)
	cclog("======服务端下发属性值======刚毅:"..self.critical_strikeresistance)
	cclog("======服务端下发属性值======命中:"..self.hit_change)
	cclog("======服务端下发属性值======闪避:"..self.dodge_chance)
	cclog("======服务端下发属性值======破击:"..self.penetrate_chance)
	cclog("======服务端下发属性值======格挡:"..self.block_chance)
	cclog("======服务端下发属性值======self.unique_id:"..self.unique_id)
end



