--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-24 12:03
-- 版  本:	1.0
-- 描  述:	合击
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--合击的单次攻击
function CBattleMgr:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAttackPosInBattleMgr]
	GameObj_Attacker:setCurrentUseSkill(eumn_skill_index.restrike_skill) -- 设置为普通攻击
	local damage = self:calculateDamage(GameObj_Attacker, GameObj_Defencer)
	GameObj_Defencer:setLostHp(damage)
	if GameObj_Defencer.hp <= 0 then
		local nEumnBattleSide = eumn_battle_side.attack
		if GameObj_Defencer.is_def then
			nEumnBattleSide = eumn_battle_side.defence
		end
		--self:handleFighterDie(GameObj_Defencer, false, nEumnBattleSide, GameObj_Defencer.apos)
	end
	self:addFitDamage(nAttackPosInBattleMgr, damage)
end

--同一排合击
function CBattleMgr:FitHitLine(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	for i = 3, 1, -1 do
		local nAffectPos = math.floor((nAttackPosInBattleMgr-1)/3) * 3 + i
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAffectPos] 
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, nAffectPos)
		end
	end
end

--同一列合击
function CBattleMgr:FitHitRow(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	for i = 1, 3 do
		local nAffectPos = math.mod((nAttackPosInBattleMgr-1), 3) + (i-1)*3 +1
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAffectPos] 
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, nAffectPos)
		end
	end
end

--前排合击
function CBattleMgr:FitHitFront(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	for i = 1, 3 do
		for j = 3, 1, -1 do
			local nAffectPos = (i-1)*3 + j
			local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAffectPos]
			if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
				self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, nAffectPos)
                break
			end
		end
	end
end

--后排合击
function CBattleMgr:FitHitBack(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	for i = 1, 3 do
		for j = 1, 3 do
			local nAffectPos = (i-1)*3 + j
			local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAffectPos]
			if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
				self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, nAffectPos)
                break
			end
		end
	end
end

local function sortByFewHp(tbADefPos, tbBDefPos)
	return tbADefPos.hp < tbBDefPos.hp
end

--残血的n个合击
function CBattleMgr:FitHitFewHP(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	local bRet = false
	local tbFitPosList = {}
	for i = 1, 9 do
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[i]
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			local tbDefPos = {}
			tbDefPos.hp = GameObj_Attacker.hp
			tbDefPos.apos = GameObj_Attacker.apos
			table.insert(tbFitPosList, tbDefPos)
		end
	end
	table.sort(tbFitPosList, sortByFewHp)
	local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAttackPosInBattleMgr]
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbFitPosList)
	for i = 1, nChooseNum do 
		local tbFitPos = tbFitPosList[i]
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[tbFitPos.apos]
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, tbFitPos.apos)
		end
	end
end

--全体合击
function CBattleMgr:FitHitAll(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	for i = 1, 9 do
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[i]
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		end
	end
end

--随机的n个合击
function CBattleMgr:FitHitRandom(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	local tbFitPosList = {}
	for i = 1, 9 do
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[i] 
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			table.insert(tbFitPosList, GameObj_Attacker.apos)
		end
	end
	
    local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAttackPosInBattleMgr]
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbFitPosList)
	for i = 1, nChooseNum do 
		local nLen = #tbFitPosList
		local nRandom = math.random(1, nLen)
		if GameObj_Defencer.hp > 0 and tbFitPosList[nRandom] ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, tbFitPosList[nRandom])
		end
		table.remove(tbFitPosList, nRandom)
	end
end

local function sortByHigherMana(tbADefPos, tbBDefPos)
	return tbBDefPos.mana < tbADefPos.mana
end

--气势最高的n个合击
function CBattleMgr:FitHigherMana(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	local tbFitPosList = {}
	for i = 1, 9 do
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[i] 
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			local tbDefPos = {}
			tbDefPos.mana = GameObj_Attacker.mana
			tbDefPos.apos = GameObj_Attacker.apos
			table.insert(tbFitPosList, tbDefPos)
		end
	end
	table.sort(tbFitPosList, sortByHigherMana)
	local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAttackPosInBattleMgr] 
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbFitPosList)
	for i = 1, nChooseNum do 
		local tbFitPos = tbFitPosList[i]
		if GameObj_Defencer.hp > 0 and tbFitPos.apos ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, tbFitPos.apos)
		end
	end
end

--残血百分比的n个合击
function CBattleMgr:FitFewPrecentHP(tbFighterList_Atk, GameObj_Defencer, nAttackPosInBattleMgr)
	local tbFitPosList = {}
	for i = 1, 9 do
		local GameObj_Attacker = tbFighterList_Atk.tbCardList[i] 
		if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.apos ~= nAttackPosInBattleMgr then
			local tbDefPos = {}
			tbDefPos.hp = GameObj_Attacker.hp/GameObj_Attacker.max_hp
			tbDefPos.apos = GameObj_Attacker.apos
			table.insert(tbFitPosList, tbDefPos)
		end
	end
	table.sort(tbFitPosList, sortByFewHp)
	
	local GameObj_Attacker = tbFighterList_Atk.tbCardList[nAttackPosInBattleMgr] 
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nChooseNum = math.min(tbCurrentSkill.ObjectNum, #tbFitPosList)
	for i = 1, nChooseNum do 
		local tbDefPos = tbFitPosList[i]
		if tbDefPos.apos ~= nAttackPosInBattleMgr then
			self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, tbDefPos.apos)
		end
	end
end
