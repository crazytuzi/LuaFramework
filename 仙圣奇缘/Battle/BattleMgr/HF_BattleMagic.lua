--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-17 15:51
-- 版  本:	1.0
-- 描  述:	攻击对象处理
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--单体攻击
function CBattleMgr:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr, fAreaDamageParam)
    if not nDefencePosInBattleMgr then
        SendError("客户端战斗调试===nDefencePosInBattleMgr Is Nil===")
    end
	local tbActioncardlist = self:addActioncardlist()
	local nEumnBattleSide = eumn_battle_side.attack
	if tbFighterList_Def.is_def then
		nEumnBattleSide = eumn_battle_side.defence
	end
	
	tbActioncardlist.affectinfo = (nEumnBattleSide*10) + nDefencePosInBattleMgr
	local GameObj_Defencer = tbFighterList_Def.tbCardList[nDefencePosInBattleMgr]
	if not GameObj_Defencer then return false end
	if GameObj_Defencer.hp <= 0 then SendError("客户端战斗调试======why kill a dead body????=====") end

	local bRepeatedHit = GameObj_Attacker:isRepeatedHit()
    local bFitSkill = GameObj_Attacker:isFitSkill()
	local bIsHit = self:handleHitTarget(GameObj_Attacker, GameObj_Defencer, bRepeatedHit, bFitSkill)
	if bIsHit then
		local nDamage = self:calculateTotalDamage(GameObj_Attacker, GameObj_Defencer, fAreaDamageParam)
		local bBlock = false
		if not GameObj_Attacker:isCureSkill() and not bFitSkill and not bRepeatedHit then
			bBlock = self:handleBlockTarget(GameObj_Attacker, GameObj_Defencer)
			if bBlock then
				nDamage = nDamage / 2 
			end
		end
		nDamage = math.floor(nDamage)
		GameObj_Defencer:setLostHp(nDamage)
		if bBlock then
			self:handleRestrike(GameObj_Attacker, GameObj_Defencer)
		elseif bRepeatedHit then
			self:handleRepeatedAttack(GameObj_Attacker, GameObj_Defencer)
		elseif bFitSkill then
			self:handleUnionAttack(GameObj_Attacker, GameObj_Defencer, nDefencePosInBattleMgr)
		end
		tbActioncardlist.damage = nDamage
		
		if (self.battle_type ==  macro_pb.Battle_Atk_Type_WorldBoss or self.battle_type ==  macro_pb.Battle_Atk_Type_GuildWorldBoss)
			and GameObj_Defencer.is_def then
			self:handleWorldBossDrop(nDamage)
		end
		
		local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
		
		if GameObj_Defencer.hp <= 0 then
			self:handleFighterDie(GameObj_Defencer, false, nEumnBattleSide, nDefencePosInBattleMgr)
		elseif tbCurrentSkill and tbCurrentSkill.TargetStatusID > 0 then
			local nRandom = math.random(1, g_BasePercent)
			 if nRandom <= tbCurrentSkill.TargetStatusProba then
				 tbActioncardlist.target_status = tbCurrentSkill.TargetStatusID
				 tbActioncardlist.target_statusLv = tbCurrentSkill.TargetStatusLevel
				 --状态添加
				 GameObj_Defencer.effectmgr:addStatus(GameObj_Attacker, GameObj_Defencer, tbCurrentSkill.TargetStatusID, tbCurrentSkill.TargetStatusLevel)
			 end
		 end
	

		if not GameObj_Attacker:isPowerSkill() and GameObj_Attacker.is_def ~= GameObj_Defencer.is_def then
			GameObj_Defencer:addMana(self.hit_add_mana)
		end
	end
	
	--自己打自己时，这里不填气势
	if GameObj_Attacker.is_def ~= GameObj_Defencer.is_def 
		or GameObj_Attacker.apos ~= GameObj_Defencer.apos then
		tbActioncardlist.def_sp = GameObj_Defencer.mana
	end

            
    --更新怒气上限
    tbActioncardlist.maxSp = GameObj_Defencer:get_maxMana()
    --更新血量上限
    tbActioncardlist.maxHp = GameObj_Defencer:get_maxhp()

	return bIsHit
end

--攻击一排
function CBattleMgr:MagicHitLine(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	
	--统计受击目标数量
	local nCount = 0
	for i = 3, 1, -1 do
		local nAffectPos = math.floor((nDefencePosInBattleMgr-1)/3) * 3 + i
		local GameObj_Defencer = tbFighterList_Def.tbCardList[nAffectPos] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 and GameObj_Defencer.attend_step <= self.nCurrentRound then
			nCount = nCount + 1
		end
	end
	
	local fAreaDamageParam = 1.0
	if nCount == 3 then
		fAreaDamageParam = 1.0
	elseif nCount == 2 then
		fAreaDamageParam = 1.2
	else
		fAreaDamageParam = 1.5
	end
	
	for i = 3, 1, -1 do
		local nAffectPos = math.floor((nDefencePosInBattleMgr-1)/3) * 3 + i
		local GameObj_Defencer = tbFighterList_Def.tbCardList[nAffectPos] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 and GameObj_Defencer.attend_step <= self.nCurrentRound then
			local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nAffectPos, fAreaDamageParam)
			if bIsHit then
				bRet = bIsHit
			end
		end
	end
	return bRet
end

--攻击一列
function CBattleMgr:MagicHitRow(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	
	--统计受击目标数量
	local nCount = 0
	for i = 1, 3 do
		local nAffectPos = math.mod((nDefencePosInBattleMgr-1), 3) + (i-1)*3 +1
		local GameObj_Defencer = tbFighterList_Def.tbCardList[nAffectPos] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 and GameObj_Defencer.attend_step <= self.nCurrentRound  then
			nCount = nCount + 1
		end
	end
	
	local fAreaDamageParam = 1.0
	if nCount == 3 then
		fAreaDamageParam = 1.0
	elseif nCount == 2 then
		fAreaDamageParam = 1.2
	else
		fAreaDamageParam = 1.5
	end
	
	for i = 1, 3 do
		local nAffectPos = math.mod((nDefencePosInBattleMgr-1), 3) + (i-1)*3 +1
		local GameObj_Defencer = tbFighterList_Def.tbCardList[nAffectPos] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 and GameObj_Defencer.attend_step <= self.nCurrentRound  then
			local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nAffectPos, fAreaDamageParam)
			if bIsHit then
				bRet = bIsHit
			end
		end
	end
	return bRet
end

--攻击前排
function CBattleMgr:MagicHitFront(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	for i = 1, 3 do
		for j = 3, 1, -1 do
			local nAffectPos = (i-1)*3 + j
			local GameObj_Defencer = tbFighterList_Def.tbCardList[nAffectPos] 
			if GameObj_Defencer and GameObj_Defencer.hp > 0 then
				local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nAffectPos)
				if bIsHit then
					bRet = bIsHit
				end
				break
			end
		end
	end
	return bRet
end

--攻击后排
function CBattleMgr:MagicHitBack(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	for i = 1, 3 do
		for j = 1, 3 do
			local nAffectPos = (i-1)*3 + j
			local GameObj_Defencer = tbFighterList_Def.tbCardList[nAffectPos] 
			if GameObj_Defencer and GameObj_Defencer.hp > 0 then
				local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nAffectPos)
				if bIsHit then
					bRet = bIsHit
				end
				break
			end
		end
	end
	return bRet
end

local function sortByFewHp(tbADefPos, tbBDefPos)
	return tbBDefPos.hp > tbADefPos.hp
end

--攻击残血的n个
function CBattleMgr:MagicHitFewHP(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	local tbDefPosList = {}
	for i = 1, 9 do
		local GameObj_Defencer = tbFighterList_Def.tbCardList[i] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 then
			local tbDefPos = {}
			tbDefPos.hp = GameObj_Defencer.hp
			tbDefPos.apos = GameObj_Defencer.apos
			table.insert(tbDefPosList, tbDefPos)
		end
	end
	table.sort(tbDefPosList, sortByFewHp)
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbDefPosList)
	for i = 1, nChooseNum do 
		local tbDefPos = tbDefPosList[i]
		if tbDefPos and tbDefPos.hp > 0 then 
			local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, tbDefPos.apos)
			if bIsHit then
				bRet = bIsHit
			end
		end
	end
	return bRet
end

--攻击全体
function CBattleMgr:MagicHitAll(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	for i = 1, 9 do
		local GameObj_Defencer = tbFighterList_Def.tbCardList[i] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 then
			local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, GameObj_Defencer.apos)
			if bIsHit then
				bRet = bIsHit
			end
		end
	end
	return bRet
end

--攻击随机的n个
function CBattleMgr:MagicHitRandom(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	local tbDefPosList = {}
	for i = 1, 9 do
		local GameObj_Defencer = tbFighterList_Def.tbCardList[i] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 then
			table.insert(tbDefPosList, GameObj_Defencer.apos)
		end
	end
	
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbDefPosList)
	for i = 1, nChooseNum do 
		local nLen = #tbDefPosList
		local nRandom = math.random(1, nLen)
		local GameObj_Defencer = tbFighterList_Def.tbCardList[tbDefPosList[nRandom]] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 then
			local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, tbDefPosList[nRandom])
			if bIsHit then
				bRet = bIsHit
			end
		end
		table.remove(tbDefPosList, nRandom)
	end
	return bRet
end

local function sortByHigherMana(tbADefPos, tbBDefPos)
	return tbADefPos.mana > tbBDefPos.mana
end

--攻击气势最高的n个
function CBattleMgr:MagicHigherMana(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	local tbDefPosList = {}
	for i = 1, 9 do
		local GameObj_Defencer = tbFighterList_Def.tbCardList[i] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 then
			local tbDefPos = {}
			tbDefPos.mana = GameObj_Defencer.mana
			tbDefPos.apos = GameObj_Defencer.apos
			table.insert(tbDefPosList, tbDefPos)
		end
	end
	table.sort(tbDefPosList, sortByHigherMana)
	
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbDefPosList)
	for i = 1, nChooseNum do 
		local tbDefPos = tbDefPosList[i]
		local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, tbDefPos.apos)
		if bIsHit then
			bRet = bIsHit
		end
	end
	return bRet
end

--攻击残血百分比的n个
function CBattleMgr:MagicHitFewPrecentHP(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	local bRet = false
	local tbDefPosList = {}
	for i = 1, 9 do
		local GameObj_Defencer = tbFighterList_Def.tbCardList[i] 
		if GameObj_Defencer and GameObj_Defencer.hp > 0 then
			local tbDefPos = {}
			tbDefPos.hp = GameObj_Defencer.hp/GameObj_Defencer.max_hp
			tbDefPos.apos = GameObj_Defencer.apos
			table.insert(tbDefPosList, tbDefPos)
		end
	end
	table.sort(tbDefPosList, sortByFewHp)
	
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbDefPosList)
	for i = 1, nChooseNum do 
		local tbDefPos = tbDefPosList[i]
		if tbDefPos and tbDefPos.hp > 0 then 
			local bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, tbDefPos.apos)
			if bIsHit then
				bRet = bIsHit
			end
		end
	end
	return bRet
end