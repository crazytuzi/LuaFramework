--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-18 11:53
-- 版  本:	1.0
-- 描  述:	战斗外部接口
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--外部接口,当前战斗状态， 0表示当前波次继续，1表示当前波次结束， 2 表示战斗结束
enum_battle_state = {
	current_round_continue = 0,
	current_round_end = 1,
	battle_end = 2,
}

--获取当前攻击顺序
function CBattleMgr:getFighterSequenceList()
	local nLen = #self.tbFighterSequenceList
	
    local tbFighterSequenceList = {}

	for i = self.nCurrentSequence, nLen do
		local tbFighterSequence = self.tbFighterSequenceList[i]
		local GameObj_Fighter = self:getFighter(tbFighterSequence.atkno, tbFighterSequence.apos)
		if GameObj_Fighter and GameObj_Fighter.hp > 0 then
			table.insert(tbFighterSequenceList, tbFighterSequence)
		end
	end
	
	if self.nCurrentSequence > 1 then
		for i = 1, self.nCurrentSequence do
			local tbFighterSequence = self.tbFighterSequenceList[i]
			local GameObj_Fighter = self:getFighter(tbFighterSequence.atkno, tbFighterSequence.apos)
			if GameObj_Fighter and GameObj_Fighter.hp > 0 then
				table.insert(tbFighterSequenceList, tbFighterSequence)
			end
		end
	end

	return tbFighterSequenceList
end

--战斗中重新设置阵型
function CBattleMgr:resetArrayPos(tbGameFighterIdListInPos)
	local tbTmpCardList = {}
	
	--先将伙伴存起来
	for nPosInBattleMgr, GameObj_Attacker in pairs(self.tbFighterList_Atk.tbCardList) do
		tbTmpCardList[GameObj_Attacker.cardid] = GameObj_Attacker
		if nPosInBattleMgr >= 1 and nPosInBattleMgr <= 9 then
			self.tbFighterList_Atk.tbCardList[nPosInBattleMgr] = nil
		end
	end

	for nPosInBattleMgr, nFighterId in pairs(tbGameFighterIdListInPos) do
		local GameObj_Attacker = tbTmpCardList[nFighterId]
        GameObj_Attacker.apos = nPosInBattleMgr
		self.tbFighterList_Atk.tbCardList[nPosInBattleMgr] = GameObj_Attacker
	end
	
	self:buildAllFightersSequence()
end


--外部接口,当前伙伴是否可选择技能
function CBattleMgr:isCurCardChooseSkill()
local ka3 = CListenFunction:new("待机测试 卡顿 isCurCardChooseSkill")
	local GameObj_Fighter = self:getCurrentActionFighter()
	local tbEffectMgr = GameObj_Fighter.effectmgr
	local b = tbEffectMgr:isDizzy() or tbEffectMgr:isConfused() or tbEffectMgr:isFrenzy() or tbEffectMgr:isSilence()
	ka3:delete()
	return b
end

--外部接口,当前伙伴是否略过
function CBattleMgr:onCardAction()
    
end

--外部接口,直接获取行动的数据
function CBattleMgr:calcBattleTurn()
	local nLen = #self.tbFighterSequenceList
	
    self:initFigterActions()
	
	self.nCurrentSequence = self.nCurrentSequence + 1

    local nOldSeq = self.nCurrentSequence
	
	self:updateNextAtkSeq()
    if self.nCurrentSequence < nOldSeq then
		self.nCurrentTurn = self.nCurrentTurn + 1
		if self.nCurrentTurn <= g_DataMgr:getGlobalCfgCsv("max_turn_num") then
			self.tbBattleTurn.new_round_num = self.nCurrentTurn
		end
    end
	
	return self.tbBattleTurn
end

function CBattleMgr:getBattleTurn()
	return self.tbBattleTurn
end

--伙伴是否死亡
function CBattleMgr:isFighterDead(nEumnBattleSide, nPosInBattleMgr)
	local GameObj_Fighter = self:getFighter(nEumnBattleSide, nPosInBattleMgr)
	if GameObj_Fighter then
		return GameObj_Fighter.hp > 0
	end
end

--外部接口,当前战斗状态， 0表示当前波次继续，1表示当前波次结束， 2 表示战斗结束
function CBattleMgr:getBattleState()
	if self:checkFightersAllDie(eumn_battle_side.attack) or self.nCurrentTurn > g_DataMgr:getGlobalCfgCsv("max_turn_num") then
		return enum_battle_state.battle_end
	end

	local isDefencersAllDie = self:checkFightersAllDie(eumn_battle_side.defence)
	if isDefencersAllDie then
		if self.nCurrentRound == #self.tbFighterList_AllRoundDef then
			return enum_battle_state.battle_end
		else
			return enum_battle_state.current_round_end
		end
	end
	
	return enum_battle_state.current_round_continue
end

--外部接口，获取下一波次的怪物数据
function CBattleMgr:initDefenceFighterNextRound()
	self:resetAttackerNextRound()
	return self:getFighterInfoListBySide(eumn_battle_side.defence)
end

--外部接口，添加攻方的npc
function CBattleMgr:addNpcFighters()
	for k, v in pairs(self.tbFighterList_Npc.tbCardList) do
		if v.attend_step == self.nCurrentRound and not self.tbFighterList_Atk[k] then
			self.tbFighterList_Atk.tbCardList[k] = v
		end
	end
end

--外部接口，获取下一波次玩家卡牌数据
function CBattleMgr:initNpcFightersNextRound()
	local tbFighterList_OnSide = {}
	
	local tbFighterList_Atk = self:getFighterListBySide(eumn_battle_side.attack)
	
	for k, v in pairs(tbFighterList_Atk.tbCardList) do
		local GameObj_Attacker = self:getFighterInfo(v)
		local bWhetherInsertNpc = false
		if not GameObj_Attacker.is_card and GameObj_Attacker.attend_step == self.nCurrentRound then
			bWhetherInsertNpc = true
		end
		if bWhetherInsertNpc then
			table.insert(tbFighterList_OnSide, GameObj_Attacker)
		end
	end
	
	return tbFighterList_OnSide
end

--外部接口，获取波次数
function CBattleMgr:getCurrentRound()
    return self.nCurrentRound
end

--设置某张伙伴使用的技能
function CBattleMgr:setFighterUseSkillIndex(nEumnBattleSide, nPosInBattleMgr, nIndex)
    local GameObj_Fighter = self:getFighter(nEumnBattleSide, nPosInBattleMgr)
	GameObj_Fighter:setCurrentUseSkill(nIndex)
end

function CBattleMgr:getFighterUseSkillIndex(nEumnBattleSide, nPosInBattleMgr)
    local GameObj_Fighter = self:getFighter(nEumnBattleSide, nPosInBattleMgr)
    return GameObj_Fighter:getCurrentSkillIndex()
end

--获取伙伴技能等级
function CBattleMgr:getFighterUseSkillLevel(nEumnBattleSide, nPosInBattleMgr, nIndex)
    local GameObj_Fighter = self:getFighter(nEumnBattleSide, nPosInBattleMgr)
	if GameObj_Fighter then
		return GameObj_Fighter:getSkillLv(nIndex)
	end
	return 1
end

--外部接口，获取战斗结果
function CBattleMgr:sendBattleResult(waitForBattleResultCall)
	local nBattleState = self:getBattleState()
	if nBattleState ~= enum_battle_state.battle_end then
		error("战斗还没结束！")
	end
	if not waitForBattleResultCall then
		error("回调函数为空啊！")
	end

	self.tbBattleTurn = nil

	--战斗结果数据
	local tbBattleResult = {}
	
	local bDefDie = self:checkFightersAllDie(1)
	if not bDefDie then
		tbBattleResult.iswin = false
	else
		tbBattleResult.iswin = true
	end

	if not bDefDie and 
		self.battle_type ~= macro_pb.Battle_Atk_Type_WorldBoss and 
		self.battle_type ~= macro_pb.Battle_Atk_Type_SceneBoss and
		self.battle_type ~= macro_pb.Battle_Atk_Type_GuildWorldBoss and 
		self.battle_type ~= macro_pb.Battle_Atk_Type_GuildSceneBoss and 
		self.battle_type ~= macro_pb.Battle_Atk_Type_BaXian_Rob and
		self.battle_type ~= macro_pb.Battle_Atk_Type_ArenaPlayer  and
		self.battle_type ~= macro_pb.Battle_Atk_Type_CrossArenaPlayer then --防守边没死光,马上返回

    	gTalkingData:onFailed(self.mapid, TDMission_Cause.TDMission_Cause_Faile)
	    waitForBattleResultCall(tbBattleResult, nStarScore)
	    return
	end

	if tbBattleResult.iswin == true then
 		gTalkingData:onCompleted(self.mapid)
 	else
 		gTalkingData:onFailed(self.mapid, TDMission_Cause.TDMission_Cause_Faile)
	end
	
	self.battleresultfun = waitForBattleResultCall
	
	local tbResult = {}
	tbResult.iswin = tbBattleResult.iswin
	tbResult.battletype = self.battle_type
	tbResult.mapid = self.mapid
	tbResult.damage = 0
	if self.battle_type == macro_pb.Battle_Atk_Type_WorldBoss or
	   self.battle_type == macro_pb.Battle_Atk_Type_SceneBoss or
	   	self.battle_type == macro_pb.Battle_Atk_Type_GuildWorldBoss or 
		self.battle_type == macro_pb.Battle_Atk_Type_GuildSceneBoss then
		local tbFighterList_Def = self:getFighterListBySide(eumn_battle_side.defence)
		local tbBossCard = nil
		for key, value in pairs(tbFighterList_Def.tbCardList) do
			tbBossCard = value
			break
		end
		tbResult.damage = g_BattleDamage:GetDamage()
	end

	--当前的星星数 （精英副本一共有3颗星星 死一个 少一颗 只到1）
	tbResult.star_num = self:GetBattleStarLv()

	--没有战斗结果的 就请求服务器 走正常流程 否则 就是 必胜流程
	if g_BattleDamage:SendBattleResultDate() then
		g_MsgMgr:sendBattleRequest(tbResult)
	end
end

--外部接口，战斗结果返回
function CBattleMgr:recvBattleResult(msgData)
    local nStarScore = g_BattleMgr:GetBattleStarLv()

	if self.battleresultfun then
		self.battleresultfun(msgData.battle_result, nStarScore)
	else
        local msg = zone_pb.BattleResultNotify()
        msg.battle_result.iswin = true
        waitForBattleResultCall(msg.battle_result, 1)
	end
	self:reNewBattleData()
end

--外部接口，重置数据
function CBattleMgr:resetBattle(initBattleEndCall)
	self:initBattle(self.tbServerMsg, initBattleEndCall)
end






