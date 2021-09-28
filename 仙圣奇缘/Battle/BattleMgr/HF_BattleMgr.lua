--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-15 14:51
-- 版  本:	1.0
-- 描  述:	战斗处理, 计算出战斗表现所需要的数据
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

CBattleMgr = class("CBattleMgr")
CBattleMgr.__index = CBattleMgr


--[[

// 掉落物品简要信息,怪物死亡时，客户端表现用的
message SimpleDropInfo
{
	optional uint32 drop_item_type = 1; // 掉落类型
	optional uint32 drop_item_num = 2; // 掉落数量，资源类需要
	optional uint32 drop_item_config_id = 3;
	optional uint32 drop_item_star_lv = 4;
}

// 战斗卡牌信息
message BattleCardInfo
{
	required uint32 arraypos = 1;//在9宫格中的位置,10,11,12为等待
	required uint32 configid = 2; //卡牌配置id
	optional uint32 star_lv = 3; // 星级
	optional uint32 card_lv = 4; // 等级
	optional bool is_card = 5; // 是否是卡牌
	optional uint32 normal_skill_lv = 6; // 普通技能等级
	optional uint32 powerful_skill_lv = 7; // 绝技技能等级
	optional uint32 hp = 8;  
	required uint32 max_hp = 9; 
	optional uint32 sp = 10; // 气势
	optional uint32 max_sp = 11; // 气势上限
	optional uint32 preattack = 12; // 先攻值

	//战斗二级属性
	optional uint32 phy_attack = 13; // 武力攻击
	optional uint32 phy_defence = 14; // 武力防御
	optional uint32 mag_attack = 15; // 法术攻击
	optional uint32 mag_defence = 16; // 法术防御
	optional uint32 skill_attack = 17; // 绝技攻击
	optional uint32 skill_defence = 18; // 绝技防御
	optional uint32 critical_chance = 19; // 暴击(几率)
	optional uint32 critical_resistance = 20; // 韧性(几率)
	optional uint32 critical_strike = 21; // 必杀(几率)
	optional uint32 critical_strikeresistance = 22; // 刚毅(几率)
	optional uint32 hit_change = 23; // 命中(几率)
	optional uint32 dodge_chance = 24; // 闪避(几率)
	optional uint32 penetrate_chance = 25; // 穿透(几率)
	optional uint32 block_chance = 26; // 格挡(几率)
	optional uint32 damage_reduction = 27; // 伤害减免(百分比)
	optional bool is_def = 28; //是否防守方
	
	repeated SimpleDropInfo die_drop_info = 29; // 死亡时掉落简要信息，表现用
	repeated uint32 skill_lv_list = 30; // 技能等级
	optional uint32 cardid = 31; // cardid
	optional uint32 breachlv = 32; // 突破等级
	optional uint32 attend_step = 33; // 参与阶段
}

message BattleArmyInfo
{
	repeated BattleCardInfo cardinfo = 1;
	optional uint32 preattack = 2;
}

// 战斗场景通知
message BattleScenceNotify
{
	optional uint32 battle_type = 1; // 战斗类型
	optional uint32 mapid = 2; // 副本中就是副本id，竞技场，就是竞技场id
	optional BattleArmyInfo atkarmy = 3; //攻方队伍
	repeated BattleArmyInfo defarmylist = 4; //守方队伍列表
	optional string def_name = 5; // 守方名字
}
]]

eumn_battle_side = {
	attack = 0,
	defence = 1
}

eumn_skill_index = {
	normal_skill = 1,
	power_skilla = 2,
	power_skillb = 3,
	power_skillc = 4,
	restrike_skill = 5,
}

function CBattleMgr:getBattleType()
	return self.battle_type
end

function CBattleMgr:getDefenceSideName()
	return self.def_name or "no name"
end

function CBattleMgr:initBattle(tbServerMsg, initBattleEndCall)
	g_BattleDamage:resetBattleDamage()

	self.battle_type = tbServerMsg.battle_type --副本类型
	self.mapid = tbServerMsg.mapid --副本配置id不是地图id，别被命名搞混了，如果是普通、高手、宗师副本的话就是指MapEctypeSub的配置id
	self.isFirst = tbServerMsg.is_first --是否第一次打这个副本
	
	--初始化攻击方战斗单位列表，如果有npc的话也加到攻击方战斗列表
	self.tbFighterList_Atk = {}
	self.tbFighterList_Atk = self:buildFighterListInfo(tbServerMsg.atkarmy)
	--初始化npc列表
	self.tbFighterList_Npc = self:buildNpcFighterListInfo(tbServerMsg.atkarmy)	
	
	--统计攻击方出战人数
    self.nAttackSideCount = 0
    for k,v in pairs(self.tbFighterList_Atk.tbCardList) do
        self.nAttackSideCount = self.nAttackSideCount + 1
    end
	
	--守方队伍数据, 可能有几波
	self.tbFighterList_AllRoundDef = {}
	for k, v in ipairs(tbServerMsg.defarmylist) do
		local tbFighterList_Def = self:buildFighterListInfo(v, true)
		table.insert(self.tbFighterList_AllRoundDef, tbFighterList_Def)
	end
	
	--守方名字，如果是副本就是副本名字，如果是pk就是玩家的名字
	self.def_name = tbServerMsg.def_name
	
	--当前波次
	self.nCurrentRound = 0
	
	--把npc插入到攻击方战斗列表里面
    self:addNpcFighters()
	
	--当前行动次数
	self.nTurnNo = 0
	
	--构造攻击顺序
	self.nCurrentSequence = 1
	self:buildAttackFightersSequence()
	
	--普攻、被攻击等增加的怒气值
	self.hit_add_mana = g_DataMgr:getGlobalCfgCsv("hit_add_mana")
	--怒气值上限
	self.mana_limit = g_DataMgr:getGlobalCfgCsv("mana_limit")
	
	self.tbServerMsg = tbServerMsg
	if initBattleEndCall then
		-- 数据接口
		-- local tbBattleScenceInfo = {}
		-- tbBattleScenceInfo.battle_type = self.battle_type
		-- tbBattleScenceInfo.mapid = self.mapid
		-- tbBattleScenceInfo.atkarmy = {}
		-- tbBattleScenceInfo.atkarmy.cardinfo = self:getFighterInfoListBySide(eumn_battle_side.attack)
		-- tbBattleScenceInfo.def_name = self.def_name
		local tbBattleScenceInfo = self:getBattleScenceInfo()
		initBattleEndCall(tbBattleScenceInfo)
	end
end

local function sortSequenceByPreAttackValue(tbSequenceA, tbSequenceB)
	local nACPos = (tbSequenceA.atkno*10) + tbServerToClientPosConvert[tbSequenceA.apos]
	local nBCPos = (tbSequenceB.atkno*10) + tbServerToClientPosConvert[tbSequenceB.apos]
	if tbSequenceA.preattack == tbSequenceB.preattack then
		return nACPos < nBCPos
	else
		return tbSequenceA.preattack > tbSequenceB.preattack
	end
end

function CBattleMgr:resetAttackerNextRound()
	self.nCurrentRound = self.nCurrentRound + 1

    if self.nCurrentRound > #self.tbFighterList_AllRoundDef then
        self.nCurrentRound = #self.tbFighterList_AllRoundDef
    end
	
	local tbFighterList_Atk = self:getFighterListBySide(eumn_battle_side.attack)
	for key, value  in pairs(tbFighterList_Atk.tbCardList) do
		if value.hp > 0 then
			value.effectmgr:clear()
			value.hp = value.max_hp
			value.mana = value.init_mana or value.mana
		end
	end
	
	self:buildAllFightersSequence(true)
	self.nCurrentSequence = 1
	self.nCurrentTurn = 1
end

function CBattleMgr:getFighter(nEumnBattleSide, nPosInBattleMgr)
	if nEumnBattleSide == eumn_battle_side.attack then
		if self.tbFighterList_Atk and self.tbFighterList_Atk.tbCardList then
			return self.tbFighterList_Atk.tbCardList[nPosInBattleMgr]
		end
	elseif nEumnBattleSide == eumn_battle_side.defence then
		if self.tbFighterList_AllRoundDef then
			return self.tbFighterList_AllRoundDef[self.nCurrentRound].tbCardList[nPosInBattleMgr]
		end
	else
		SendError("客户端战斗调试=======there is error nEumnBattleSide, must be 0 or 1")
	end
end

function CBattleMgr:GetBattleStarLv()
    local nLive = 0
    if self.tbFighterList_Atk == nil then return nLive end

    for k,v in pairs(self.tbFighterList_Atk.tbCardList) do
        nLive = nLive + 1
    end
    
	if self.battle_type == macro_pb.Battle_Atk_Type_Jing_Ying_pass then  --精英副本 20150702 by zgj
		local nDead 	= self.nAttackSideCount - nLive
		local nMaxStar = 3 --最大星星数
		return (nDead >= nMaxStar and 1) or ( nMaxStar - nDead)
	else
		return nLive > 0 and 1 or 0
	end
end

function CBattleMgr:setFighter(nEumnBattleSide, nPosInBattleMgr, GameObj_Fighter)
	if nEumnBattleSide == eumn_battle_side.attack then
		self.tbFighterList_Atk.tbCardList[nPosInBattleMgr] = GameObj_Fighter
	elseif nEumnBattleSide == eumn_battle_side.defence then
		self.tbFighterList_AllRoundDef[self.nCurrentRound].tbCardList[nPosInBattleMgr] = GameObj_Fighter
	else
		SendError("客户端战斗调试=========there is error nEumnBattleSide type, must be 0 or 1")
	end
	if GameObj_Fighter then
		GameObj_Fighter.apos = nPosInBattleMgr
	end
end

function CBattleMgr:getFighterListBySide(nEumnBattleSide)
	if nEumnBattleSide == eumn_battle_side.attack then
		return self.tbFighterList_Atk
	elseif nEumnBattleSide == eumn_battle_side.defence then
		if self.tbFighterList_AllRoundDef then
			return self.tbFighterList_AllRoundDef[self.nCurrentRound]
		else
			return {}
		end
	else
		return {}
	end
	return {}
end

function CBattleMgr:checkFightersAllDie(nEumnBattleSide)
	local tbFighterList = self:getFighterListBySide(nEumnBattleSide)

	if not tbFighterList then
		return true
	end

	tbFighterList.tbCardList = tbFighterList.tbCardList or {}
	
	for key, value in pairs(tbFighterList.tbCardList) do
		if value.hp > 0 then
			return false
		end
	end
	
	return true
end

-- 获得行动的伙伴
function CBattleMgr:getCurrentActionFighter()
	local tbFighterSequence = self.tbFighterSequenceList[self.nCurrentSequence]
	return self:getFighter(tbFighterSequence.atkno, tbFighterSequence.apos)
end

--单构造攻方顺序
function CBattleMgr:buildAttackFightersSequence()
	self.tbFighterSequenceList = {}
	local nAtkSlot = 1
	while nAtkSlot <= macro_pb.MAX_ARRY_SLOT_NUM do
		for nPosOnClient = nAtkSlot, macro_pb.MAX_ARRY_SLOT_NUM do
			nAtkSlot = nPosOnClient + 1
			local  nPosOnServer = tbClientToServerPosConvert[nPosOnClient]
			local GameObj_Fighter = self:getFighter(0, nPosOnServer)
			if (GameObj_Fighter and GameObj_Fighter.hp > 0 and GameObj_Fighter.attend_step <= self.nCurrentRound) then
				local tbFighterSequence = {}
				tbFighterSequence.atkno = 0
				tbFighterSequence.apos = nPosOnServer
				tbFighterSequence.cardid = GameObj_Fighter.cardid
				table.insert(self.tbFighterSequenceList, tbFighterSequence)
				break
			end
		end
	end
end

--构造防守顺序
function CBattleMgr:buildAllFightersSequence()
	self.tbFighterSequenceList = {}
	
	local nAtkSlot = 1
	local nDefSlot = 1
	local cardnum = 0
    --取防守方數據
    local tbFighterList_Def = self:getFighterListBySide(eumn_battle_side.defence)
	
	if tbFighterList_Def and tbFighterList_Def.preattack then
		while nAtkSlot <= macro_pb.MAX_ARRY_SLOT_NUM or nDefSlot <= macro_pb.MAX_ARRY_SLOT_NUM do
			if self.tbFighterList_Atk.preattack >= tbFighterList_Def.preattack then
				for nPosOnClient = nAtkSlot, macro_pb.MAX_ARRY_SLOT_NUM do
					nAtkSlot = nPosOnClient + 1
					local  nPosOnServer = tbClientToServerPosConvert[nPosOnClient]
					local GameObj_Attacker = self:getFighter(eumn_battle_side.attack, nPosOnServer)
					if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.attend_step <= self.nCurrentRound then
						local tbFighterSequence = {}
						tbFighterSequence.atkno = 0
						tbFighterSequence.apos = nPosOnServer
						tbFighterSequence.cardid = GameObj_Attacker.cardid
						table.insert(self.tbFighterSequenceList, tbFighterSequence)
						break
					end
				end
				for nPosOnClient = nDefSlot, macro_pb.MAX_ARRY_SLOT_NUM do
					nDefSlot = nPosOnClient + 1
					local  nPosOnServer = tbClientToServerPosConvert[nPosOnClient]
					local GameObj_Defencer = self:getFighter(eumn_battle_side.defence, nPosOnServer)
					if GameObj_Defencer and GameObj_Defencer.hp > 0 then
						local tbFighterSequence = {}
						tbFighterSequence.atkno = 1
						tbFighterSequence.apos = nPosOnServer
						table.insert(self.tbFighterSequenceList, tbFighterSequence)
						break
					end
				end
			else
				for nPosOnClient = nDefSlot, macro_pb.MAX_ARRY_SLOT_NUM do
					nDefSlot = nPosOnClient + 1
					local  nPosOnServer = tbClientToServerPosConvert[nPosOnClient]
					local GameObj_Defencer = self:getFighter(eumn_battle_side.defence, nPosOnServer)
					if GameObj_Defencer and GameObj_Defencer.hp > 0 then
						local tbFighterSequence = {}
						tbFighterSequence.atkno = 1
						tbFighterSequence.apos = nPosOnServer
						table.insert(self.tbFighterSequenceList, tbFighterSequence)
						break
					end
				end
				for nPosOnClient = nAtkSlot, macro_pb.MAX_ARRY_SLOT_NUM do
					nAtkSlot = nPosOnClient + 1
					local  nPosOnServer = tbClientToServerPosConvert[nPosOnClient]
					local GameObj_Attacker = self:getFighter(eumn_battle_side.attack, nPosOnServer)
					if GameObj_Attacker and GameObj_Attacker.hp > 0 and GameObj_Attacker.attend_step <= self.nCurrentRound then
						local tbFighterSequence = {}
						tbFighterSequence.atkno = 0
						tbFighterSequence.apos = nPosOnServer
						tbFighterSequence.cardid = GameObj_Attacker.cardid
						table.insert(self.tbFighterSequenceList, tbFighterSequence)
						break
					end
				end
			end
		end
	else
		SendError("客户端战斗调试====CBattleMgr:buildAllFightersSequence====tbFighterList_Def or tbFighterList_Def.preattack is nil")
	end
	
	--[[
		--攻方
		for key, value in pairs(self.tbFighterList_Atk.tbCardList) do
			if value.apos >= 1 and value.apos <= 9 then
				local tbAtkData = {}
				tbAtkData.atkno = 0
				tbAtkData.apos = value.apos
				tbAtkData.preattack = value.preattack
				table.insert(self.tbFighterSequenceList, tbAtkData)
			end
		end
		
		--守方
		local tbCurDefCardArmy = self.tbFighterList_AllRoundDef[self.nCurrentRound].tbCardList
		for key, value in pairs(tbCurDefCardArmy) do
			if value.apos >= 1 and value.apos <= 9 then
				local tbAtkData = {}
				tbAtkData.atkno = 1
				tbAtkData.apos = value.apos
				tbAtkData.preattack = value.preattack
				table.insert(self.tbFighterSequenceList, tbAtkData)
			end
		end

		table.sort(self.tbFighterSequenceList, sortSequenceByPreAttackValue)
	--]]
end

--构造某一方的战斗队伍
--bDef true 代表 怪物
function CBattleMgr:buildFighterListInfo(tbFightersInfo, bDef)
	local tbFighterList = {}
	tbFighterList.is_def = bDef
	tbFighterList.preattack = tbFightersInfo.preattack
    tbFighterList.tbCardList = {}
	self.nMagicPofessionCount = 0
	self.nDefenceSideCount = 0

	for key, value in ipairs(tbFightersInfo.cardinfo) do
		local tbBattleCard = CBattleCard:new()
		tbBattleCard:initBattleCard(value)
		if not bDef and tbBattleCard.is_card then --解析卡牌
			tbFighterList.tbCardList[value.arraypos] = tbBattleCard
			if tbBattleCard.profession == 4 then
				self.nMagicPofessionCount = self.nMagicPofessionCount + 1
			end
		elseif bDef then--解析怪物数据
			tbFighterList.tbCardList[value.arraypos] = tbBattleCard
			self.nDefenceSideCount = self.nDefenceSideCount + 1
		end
	end
	return tbFighterList
end

--构造攻方的npc
function CBattleMgr:buildNpcFighterListInfo(tbFightersInfo)
	local tbFighterList_Npc = {}
	tbFighterList_Npc.is_def = false --非防守方
	tbFighterList_Npc.preattack = tbFightersInfo.preattack
    tbFighterList_Npc.tbCardList = {}
	
	for key, value in ipairs(tbFightersInfo.cardinfo) do
		local tbBattleCard = CBattleCard:new()
		tbBattleCard:initBattleCard(value)
		if not tbBattleCard.is_card then
			tbFighterList_Npc.tbCardList[value.arraypos] = tbBattleCard
		end
	end

	return tbFighterList_Npc
end


function CBattleMgr:getBattleScenceInfo()
	local tbBattleScenceInfo = {}
	tbBattleScenceInfo.battle_type = self.battle_type
	tbBattleScenceInfo.mapid = self.mapid
    tbBattleScenceInfo.atkarmy = {}
	tbBattleScenceInfo.atkarmy.cardinfo = self:getFighterInfoListBySide(eumn_battle_side.attack)
	tbBattleScenceInfo.def_name = self.def_name
	return tbBattleScenceInfo
end

function CBattleMgr:getFighterInfoListBySide(nEumnBattleSide)
	local tbFighterList_OnSide = {}

	local tbFighterList = self:getFighterListBySide(nEumnBattleSide)

	if not tbFighterList or not tbFighterList.tbCardList then
		return tbFighterList_OnSide
	end
	for k, v in pairs(tbFighterList.tbCardList) do
		local tbFighterInfo = self:getFighterInfo(v)
		if not tbFighterInfo.is_def and not tbFighterInfo.is_card and tbFighterInfo.attend_step > self.nCurrentRound then
        else
            table.insert(tbFighterList_OnSide, tbFighterInfo)
		end
	end
	
	return tbFighterList_OnSide
end

function CBattleMgr:getFighterInfo(GameObj_Fighter)
	local tbFighterInfo = {}

	tbFighterInfo.arraypos = GameObj_Fighter.apos
	tbFighterInfo.configid = GameObj_Fighter.cfgid
	tbFighterInfo.star_lv = GameObj_Fighter.star
	tbFighterInfo.card_lv = GameObj_Fighter.card_lv
	tbFighterInfo.is_card = GameObj_Fighter.is_card
	tbFighterInfo.normal_skill_lv = GameObj_Fighter.normal_skill_lv
	tbFighterInfo.powerful_skill_lv = GameObj_Fighter.powerful_skill_lv
	tbFighterInfo.init_hp = GameObj_Fighter.hp
	tbFighterInfo.max_hp = GameObj_Fighter.max_hp
	tbFighterInfo.init_sp = GameObj_Fighter.mana
	tbFighterInfo.max_sp = GameObj_Fighter.max_mana
    tbFighterInfo.breachlv = GameObj_Fighter.breachlv
	tbFighterInfo.attend_step = GameObj_Fighter.attend_step
	tbFighterInfo.is_def = GameObj_Fighter.is_def
	tbFighterInfo.cardid = GameObj_Fighter.cardid
	
	return tbFighterInfo
end

function CBattleMgr:getCurrentActionFighterInfo(tbFighterSequence)
	local GameObj_Fighter = self:getCurrentActionFighter()
	local nCurrentSkillIndex = GameObj_Fighter:getCurrentSkillIndex()
	return (nCurrentSkillIndex*100) + (tbFighterSequence.atkno*10) + tbFighterSequence.apos;
end

function CBattleMgr:getValidSeqNo(nStart, nEnd)
    for i = nStart, nEnd do
		local tbAtkSeq = self.tbFighterSequenceList[i]
		local GameObj_Fighter = self:getFighter(tbAtkSeq.atkno, tbAtkSeq.apos)
		if GameObj_Fighter and GameObj_Fighter.hp > 0 then
			self.nCurrentSequence = i
            return i
		end
	end
end

function CBattleMgr:updateNextAtkSeq()
    local bFind = nil
    for i = self.nCurrentSequence, #self.tbFighterSequenceList do
		local tbAtkSeq = self.tbFighterSequenceList[i]
		local GameObj_Fighter = self:getFighter(tbAtkSeq.atkno, tbAtkSeq.apos)
		if GameObj_Fighter and GameObj_Fighter.hp > 0 then
			self.nCurrentSequence = i
            bFind = true
			break
		end
	end
    if not bFind then
        for i = 1, self.nCurrentSequence do
		    local tbAtkSeq = self.tbFighterSequenceList[i]
		    local GameObj_Fighter = self:getFighter(tbAtkSeq.atkno, tbAtkSeq.apos)
		    if GameObj_Fighter and GameObj_Fighter.hp > 0 then
			    self.nCurrentSequence = i
                bFind = true
			    break
		    end
	    end
    end
end


--战斗行为
function CBattleMgr:initFigterActions()
	self.tbBattleTurn = {}
	
	local tbFighterSequence = self.tbFighterSequenceList[self.nCurrentSequence]
	self.nTurnNo = self.nTurnNo + 1
	self.tbBattleTurn.turnno = self.nTurnNo
	local GameObj_Attacker = self:getCurrentActionFighter()
	
	local bUseSkill = GameObj_Attacker:isCanSkill()
	
	local bSkip = nil
	if GameObj_Attacker:isSkip() then
		bSkip = true
		self.tbBattleTurn.actioninfo = self:getCurrentActionFighterInfo(tbFighterSequence)
	elseif bUseSkill then --绝技攻击
		self:handleAttackTarget()
	else --普通攻击
		self:handleAttackTarget()
	end
	
	if GameObj_Attacker.hp > 0 then
		GameObj_Attacker.effectmgr:onAction(GameObj_Attacker)
	end
	
	--吸血
	if not bSkip then
		GameObj_Attacker.effectmgr:HandlerSuckBlood(GameObj_Attacker)
	end
	GameObj_Attacker.effectmgr:onTurn(GameObj_Attacker)
	
	return self.tbBattleTurn
end

--攻击,普通攻击也包含在里面
function CBattleMgr:handleAttackTarget()
	local GameObj_Attacker = self:getCurrentActionFighter()
	
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local tbFighterSequence = self.tbFighterSequenceList[self.nCurrentSequence]
	
	self.tbBattleTurn.actioninfo = self:getCurrentActionFighterInfo(tbFighterSequence)
	
	local nEumnBattleSide = 1 - tbFighterSequence.atkno
	if tbCurrentSkill.Object == macro_pb.Skill_Atk_Area_Self then
		nEumnBattleSide = tbFighterSequence.atkno
	end
	
	local nDefencePosInBattleMgr = -1
	local tbFighterList_Def = self:getFighterListBySide(nEumnBattleSide)
	local tbFighterList_Atk = self:getFighterListBySide(tbFighterSequence.atkno)
	if tbFighterSequence.atkno == nEumnBattleSide then
		nDefencePosInBattleMgr = GameObj_Attacker:getSelfAtkDestation(tbFighterList_Atk, tbFighterList_Def)
	else
		nDefencePosInBattleMgr, nEumnBattleSide = GameObj_Attacker:getAtkDestationCsv(tbFighterList_Atk, tbFighterList_Def)
	end
	
	if nDefencePosInBattleMgr < 1 or nDefencePosInBattleMgr > 9 then
		SendError("客户端战斗调试=======Error Happen!defapos:"..nDefencePosInBattleMgr)
		return
	end
	
	--己方状态
	if tbCurrentSkill.SelfStatusID and tbCurrentSkill.SelfStatusID > 0 and g_isRandomInRange(tbCurrentSkill.SelfStatusProba, g_BasePercent) then
		-- local id = 63;
		-- local lv = 1;
		-- self.tbBattleTurn.self_status = id
		-- self.tbBattleTurn.self_statusLv = tbCurrentSkill.SelfStatusLevel
		-- GameObj_Attacker.effectmgr:addStatus(GameObj_Attacker, GameObj_Attacker, id, lv)
		self.tbBattleTurn.self_status = tbCurrentSkill.SelfStatusID
		self.tbBattleTurn.self_statusLv = tbCurrentSkill.SelfStatusLevel
		GameObj_Attacker.effectmgr:addStatus(GameObj_Attacker, GameObj_Attacker, tbCurrentSkill.SelfStatusID, tbCurrentSkill.SelfStatusLevel)

	end
	
	GameObj_Attacker:updateHitMana()
	if GameObj_Attacker:isPowerSkill() then
		GameObj_Attacker:reduceMana(tbCurrentSkill.NeedEnergy)
	end
	
	local bIsHit = false
	if tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_Single then
		if tbFighterList_Def and tbFighterList_Def.tbCardList[nDefencePosInBattleMgr].hp > 0 then
			bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
		else
			SendError("客户端战斗调试=======macro_pb.Skill_Atk_Area_Single:"..nDefencePosInBattleMgr)
		end
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_DoubleHit then
		if tbFighterList_Def and tbFighterList_Def.tbCardList[nDefencePosInBattleMgr].hp > 0 then
			bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
		else
			SendError("客户端战斗调试=======macro_pb.Skill_Atk_Area_DoubleHit:"..nDefencePosInBattleMgr)
		end
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_TripleHit then
		if tbFighterList_Def and tbFighterList_Def.tbCardList[nDefencePosInBattleMgr].hp > 0 then
			bIsHit = self:MagicHitSingle(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
		else
			SendError("客户端战斗调试=======macro_pb.Skill_Atk_Area_TripleHit:"..nDefencePosInBattleMgr)
		end
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_Line then
		bIsHit = self:MagicHitLine(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
		
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_Row then
		bIsHit = self:MagicHitRow(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_All then
		bIsHit = self:MagicHitAll(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_FrontRow then
		bIsHit = self:MagicHitFront(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_BackRow then
		bIsHit = self:MagicHitBack(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_FewHP then
		bIsHit = self:MagicHitFewHP(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_Random then
		bIsHit = self:MagicHitRandom(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_HigherMana then
		bIsHit = self:MagicHigherMana(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	elseif tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_FewPrecentHP then
		bIsHit = self:MagicHitFewPrecentHP(GameObj_Attacker, tbFighterList_Def, nDefencePosInBattleMgr)
	
	else
		SendError("客户端战斗调试==========Skill Areatype Error skillid:"..(tbCurrentSkill.ID).." atkarea: "..tbCurrentSkill.AttackArea)
		return
	end

	if bIsHit and not GameObj_Attacker:isPowerSkill() then		
		if self:getBattleType() == macro_pb.Battle_Atk_Type_WorldBoss
			or self:getBattleType() == macro_pb.Battle_Atk_Type_SceneBoss
			or self:getBattleType() == macro_pb.Battle_Atk_Type_GuildWorldBoss
			or self:getBattleType() == macro_pb.Battle_Atk_Type_GuildSceneBoss
		then
			if not GameObj_Attacker.is_card then
				if GameObj_Attacker.profession == 4 then
					GameObj_Attacker:addMana(self.hit_add_mana)
				else
					if self.nMagicPofessionCount and self.nMagicPofessionCount > 0 then
						GameObj_Attacker:addMana(self.hit_add_mana*self.nMagicPofessionCount)
					else
						GameObj_Attacker:addMana(self.hit_add_mana)
					end
				end
			else
				GameObj_Attacker:addMana(self.hit_add_mana)
			end
		else
			GameObj_Attacker:addMana(self.hit_add_mana)
		end
	end
	
	self.tbBattleTurn.aursue_atk = tbCurrentSkill.PursueAttack
	
	self.tbBattleTurn.sp = GameObj_Attacker.mana
end

--计算命中
function CBattleMgr:checkIsHit(GameObj_Attacker, GameObj_Defencer)
    if not GameObj_Defencer then return false end
	
	local nHitChance_Atk = 0
	local nDodgeChance_Def = 0
	local nBattleType = self:getBattleType()
	
	if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or nBattleType == macro_pb.Battle_Atk_Type_Player
		or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
	then
		nHitChance_Atk = math.floor(GameObj_Attacker:get_hit_change() * g_BasePercent / GameObj_Defencer:get_rate_factor()) --真实的万分比
		nDodgeChance_Def = math.floor(GameObj_Defencer:get_dodge_chance() * g_BasePercent / GameObj_Attacker:get_rate_factor()) --真实的万分比
	else
		nHitChance_Atk = math.floor(GameObj_Attacker:get_hit_change()) --真实的万分比
		nDodgeChance_Def = math.floor(GameObj_Defencer:get_dodge_chance()) --真实的万分比
	end
	
	if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or nBattleType == macro_pb.Battle_Atk_Type_Player
		or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
	then
		if GameObj_Defencer.is_def then --被攻击的卡牌是右边防守方
			if self.nDefenceSideCount < self.nAttackSideCount then --判断防守方人数是否不足, 人数过少降低闪避, 避免剑灵攒怒气人少打人多
				nDodgeChance_Def = math.max(nDodgeChance_Def - (self.nAttackSideCount - self.nDefenceSideCount) * 1500, 0)
			end
		else --被攻击的卡牌是左边攻击方
			if self.nAttackSideCount < self.nDefenceSideCount then --判断防守方人数是否不足, 人数过少降低闪避, 避免剑灵攒怒气人少打人多
				nDodgeChance_Def = math.max(nDodgeChance_Def - (self.nDefenceSideCount - self.nAttackSideCount) * 1500, 0)
			end
		end
	end
	
	nDodgeChance = nDodgeChance_Def - nHitChance_Atk
	if nDodgeChance > 0 then
		nDodgeChance = nDodgeChance*10000/(nDodgeChance+10000) --闪避率衰减
	end
	
	nHitChance = g_DataMgr:getGlobalCfgCsv("base_hit_precent") - nDodgeChance
	nHitChance = math.min(10000, nHitChance)
	nHitChance = math.max(g_DataMgr:getGlobalCfgCsv("min_hit_precent"), nHitChance)
	local nRandom = math.random(1, 10000)
	return nRandom <= nHitChance
end

function CBattleMgr:handleHitTarget(GameObj_Attacker, GameObj_Defencer, bRepeatedHit, bFitSkill)
	--连击，合击，必命中
	if bRepeatedHit or bFitSkill then
		return true
	end

	if GameObj_Attacker:isCureSkill() then
		return true
	end
	
	if not self:checkIsHit(GameObj_Attacker, GameObj_Defencer) then
		self:addDamagetype(macro_pb.Battle_Effect_Miss)
  
		if GameObj_Defencer and GameObj_Defencer.profession == macro_pb.ProfessionType_JianLin then
			GameObj_Defencer:addMana(self.hit_add_mana) --剑灵闪避增加怒气
		end
		return false
	end
	
	return true
end

--计算伤害
function CBattleMgr:calculateDamage(GameObj_Attacker, GameObj_Defencer, bHitBack, fAreaDamageParam)
	local fAreaDamageParam = fAreaDamageParam or 1
	local tbCurrentSkill = nil
	if bHitBack then
		tbCurrentSkill = GameObj_Attacker:getCommonSkill()
	else
		tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	end
	local nBaseDamage = tbCurrentSkill.BaseDamage
	local nCurSkillIdx = GameObj_Attacker:getCurrentSkillIndex()
	if nCurSkillIdx > 1 and nCurSkillIdx < 5 then
		local tbEvoluteAdd = GameObj_Attacker:getSkillAddProp(nCurSkillIdx - 1)
        if tbEvoluteAdd then
		    local nSkillLv = GameObj_Attacker:getSkillLv(nCurSkillIdx - 1)
		    nBaseDamage = nBaseDamage + tbEvoluteAdd.DamageBase + (tbEvoluteAdd.DamageGrow * nSkillLv)
        end
	end
	local nDamagePercent = tbCurrentSkill.DamagePercent
	local nDamage = 0
	local nFormulaType = tbCurrentSkill.FormulaType
	if nFormulaType == macro_pb.FormulaType_Damage_Abs then
		nDamage = nBaseDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Damage_Phy then
		local src_atk = GameObj_Attacker:get_phy_attack()
		local tar_def = GameObj_Defencer:get_phy_defence()
		nDamage = math.max(src_atk - tar_def, src_atk*0.15) + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Damage_Mag then
		local src_atk = GameObj_Attacker:get_mag_attack()
		local tar_def = GameObj_Defencer:get_mag_defence()
		nDamage = math.max(src_atk - tar_def, src_atk*0.15) + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Damage_Phy_Skill then
		local src_phy_atk = GameObj_Attacker:get_phy_attack()
		local tar_phy_def = GameObj_Defencer:get_phy_defence()
		local src_ski_atk = GameObj_Attacker:get_skill_attack()
		local tar_ski_def = GameObj_Defencer:get_skill_defence()
		nDamage = math.max(src_phy_atk - tar_phy_def, src_phy_atk*0.15) + math.max(src_ski_atk - tar_ski_def, src_ski_atk*0.15) + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Damage_Mag_Skill then
		local src_mag_atk = GameObj_Attacker:get_mag_attack()
		local tar_mag_def = GameObj_Defencer:get_mag_defence()
		local src_ski_atk = GameObj_Attacker:get_skill_attack()
		local tar_ski_def = GameObj_Defencer:get_skill_defence()
		nDamage = math.max(src_mag_atk - tar_mag_def, src_mag_atk*0.15) + math.max(src_ski_atk - tar_ski_def, src_ski_atk*0.15) + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Cure_Abs then
		nDamage = nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Cure_Phy then
		nDamage = GameObj_Attacker:get_phy_attack() + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Cure_Mag then
		nDamage = GameObj_Attacker:get_mag_attack() + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Cure_Phy_Skill then
		nDamage = GameObj_Attacker:get_phy_attack() + GameObj_Attacker:get_skill_attack() + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	elseif nFormulaType == macro_pb.FormulaType_Cure_Mag_Skill then
		nDamage = GameObj_Attacker:get_mag_attack() + GameObj_Attacker:get_skill_attack() + nBaseDamage
		nDamage = nDamage * (g_BasePercent + nDamagePercent)/g_BasePercent
	else
		SendError("客户端战斗调试=======error type :"..nFormulaType)
		return 0
	end
	
	--纵向技能乘以区域系数
	nDamage = nDamage * fAreaDamageParam
	
	--伤害计算出后 减去免伤伤害
	local nDamageReduction = math.min(GameObj_Defencer:get_damage_reduction(), g_BasePercent) -- 免伤不能高于100%
	nDamage = nDamage * (g_BasePercent - nDamageReduction)/g_BasePercent
	
	--取整
	nDamage = math.floor(nDamage)
	--保护, 至此伤害不能为负数
	nDamage = math.max(10, nDamage)

	--修改攻击 测试使用
	-- if not GameObj_Defencer.is_def then
	    -- nDamage = 9999999999999
    -- end
	
	if GameObj_Attacker:isCureSkill() then
		return -nDamage
	end
	
	return nDamage
end

--暴击
function CBattleMgr:handleCriticalStrikeTarget(GameObj_Attacker, GameObj_Defencer, nDamage)
	local nCriticalChance_Atk = 0
	local nCriticalResistance_Def = 0
	local nBattleType = self:getBattleType()
	
	if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or nBattleType == macro_pb.Battle_Atk_Type_Player
		or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
	then
		nCriticalChance_Atk = math.floor(GameObj_Attacker:get_critical_chance() * g_BasePercent / GameObj_Defencer:get_rate_factor()) --真实的万分比
		nCriticalResistance_Def = math.floor(GameObj_Defencer:get_critical_resistance() * g_BasePercent / GameObj_Attacker:get_rate_factor()) --真实的万分比
	else
		nCriticalChance_Atk = math.floor(GameObj_Attacker:get_critical_chance()) --真实的万分比
		nCriticalResistance_Def = math.floor(GameObj_Defencer:get_critical_resistance()) --真实的万分比
	end
	
	if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or nBattleType == macro_pb.Battle_Atk_Type_Player
		or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
	then
		if GameObj_Attacker.is_def then --攻击方在右边
			if self.nDefenceSideCount < self.nAttackSideCount then --判断右边人数是否不足, 人数过少降低暴击, 避免剑灵不断攒怒气人少打人多
				nCriticalChance_Atk = math.max(nCriticalChance_Atk - (self.nAttackSideCount - self.nDefenceSideCount) * 750, 0)
			end
		else --攻击方在左边
			if self.nAttackSideCount < self.nDefenceSideCount then --判断防守方人数是否不足, 人数过少降低闪避, 避免剑灵不断攒怒气人少打人多
				nCriticalChance_Atk = math.max(nCriticalChance_Atk - (self.nDefenceSideCount - self.nAttackSideCount) * 750, 0)
			end
		end
	end
	
	local nCriticalChance = 500 + (nCriticalChance_Atk - nCriticalResistance_Def)
	nCriticalChance = math.min(nCriticalChance, g_BasePercent)
	nCriticalChance = math.max(nCriticalChance, 500)
	local nRandom = math.random(1, g_BasePercent)
	if nRandom <= nCriticalChance then
		local nCriticalStrike_Atk = 0
		local nCriticalStrikeresistance_Def = 0
		
		if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
			or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
			or nBattleType == macro_pb.Battle_Atk_Type_Player
			or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
			or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
		then
			nCriticalStrike_Atk = math.floor(GameObj_Attacker:get_critical_strike() * g_BasePercent / GameObj_Defencer:get_rate_factor()) --真实的万分比
			nCriticalStrikeresistance_Def = math.floor(GameObj_Defencer:get_critical_strikeresistance() * g_BasePercent / GameObj_Attacker:get_rate_factor()) --真实的万分比
		else
			nCriticalStrike_Atk = math.floor(GameObj_Attacker:get_critical_strike()) --真实的万分比
			nCriticalStrikeresistance_Def = math.floor(GameObj_Defencer:get_critical_strikeresistance()) --真实的万分比
		end
		
		local nCriticalStrike = nCriticalStrike_Atk
		if not GameObj_Attacker:isCureSkill() then
			nCriticalStrike = nCriticalStrike_Atk - nCriticalStrikeresistance_Def
		end
		nCriticalStrike = math.min(nCriticalStrike, 60000)
		nCriticalStrike = math.max(nCriticalStrike, 0)
		nDamage = nDamage * (g_BasePercent * 2 + nCriticalStrike)/ g_BasePercent
		self:addDamagetype(macro_pb.Battle_Effect_Crit)
		if GameObj_Attacker.profession == macro_pb.ProfessionType_FeiYu then
			GameObj_Attacker:addMana(self.hit_add_mana)
		end
	end
    return nDamage
end

function CBattleMgr:calculateTotalDamage(GameObj_Attacker, GameObj_Defencer)
	local nDamage = self:calculateDamage(GameObj_Attacker, GameObj_Defencer, fAreaDamageParam)
	nDamage = self:handleCriticalStrikeTarget(GameObj_Attacker, GameObj_Defencer, nDamage)
	if not GameObj_Attacker:isCureSkill() then
		--狂怒
		nDamage = GameObj_Attacker.effectmgr:HandlerFury(GameObj_Attacker, nDamage)
		
		--血祭  百分比提高伤害
		nDamage = GameObj_Attacker.effectmgr:HandlerImproveDamage(GameObj_Attacker, nDamage)
		
		--处理偷怒气
--		GameObj_Attacker.effectmgr:HandlerStealMana(GameObj_Attacker, GameObj_Defencer)
		
		--处理消除怒气
--		GameObj_Attacker.effectmgr:HandlerRemoveMana(GameObj_Attacker, GameObj_Defencer)
		
		--处理守备
		nDamage = GameObj_Defencer.effectmgr:HandlerDefend(GameObj_Attacker, nDamage)

	end
	
	-- 新手引导保护，如果导致死亡的攻击降低伤害
	if self.battle_type and self.battle_type == macro_pb.Battle_Atk_Type_normal_pass then
		if g_PlayerGuide:checkIsInGuide() and g_PlayerGuide:checkIsInGuide() <= g_nForceGuideMaxID then
			if GameObj_Defencer.is_card then
				if (GameObj_Defencer.hp - nDamage) <= 0 then
					nDamage = math.max(GameObj_Defencer.hp/2, 0)
				end
			end
		end
	end

	return nDamage
end

--处理格挡
function CBattleMgr:handleBlockTarget(GameObj_Attacker, GameObj_Defencer)
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	--群攻也可以格挡，但是不反击
	--法术也可以格挡了
	if not GameObj_Attacker:isCureSkill() 
	and (tbCurrentSkill.FormulaType == macro_pb.FormulaType_Damage_Phy
	or tbCurrentSkill.FormulaType == macro_pb.FormulaType_Damage_Mag
	or tbCurrentSkill.FormulaType == macro_pb.FormulaType_Damage_Phy_Skill
	or tbCurrentSkill.FormulaType == macro_pb.FormulaType_Damage_Mag_Skill
	) then
		local nPenetrateChance_Atk = 0
		local nBlockChance_Def = 0
		local nBattleType = self:getBattleType()
		
		if nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
			or nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
			or nBattleType == macro_pb.Battle_Atk_Type_Player
			or nBattleType == macro_pb.Battle_Atk_Type_BaXian_Rob
			or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
		then
			nPenetrateChance_Atk = math.floor(GameObj_Attacker:get_penetrate_chance() * g_BasePercent / GameObj_Defencer:get_rate_factor()) --真实的万分比
			nBlockChance_Def = math.floor(GameObj_Defencer:get_block_chance() * g_BasePercent / GameObj_Attacker:get_rate_factor()) --真实的万分比
		else
			nPenetrateChance_Atk = math.floor(GameObj_Attacker:get_penetrate_chance()) --真实的万分比
			nBlockChance_Def = math.floor(GameObj_Defencer:get_block_chance()) --真实的万分比
		end
	
		local nBlockChance = (nBlockChance_Def - nPenetrateChance_Atk)
		nBlockChance = math.min(nBlockChance, g_BasePercent)
		nBlockChance = math.max(nBlockChance, 0)
		local nRandom = math.random(1, g_BasePercent)
		if nRandom <= nBlockChance then
			self:addDamagetype(macro_pb.Battle_Effect_Block)
			if GameObj_Defencer.profession == macro_pb.ProfessionType_WuSeng then
				GameObj_Defencer:addMana(self.hit_add_mana)
			end
			return true
		end
	end
	return false
end

--世界boss，边打边掉钱
function CBattleMgr:handleWorldBossDrop(nDamage, bEffect)
	local tbSimpleDrop = self:addDie_drop_info(bEffect)
	tbSimpleDrop.drop_item_type = macro_pb.ITEM_TYPE_GOLDS
	local fCoinsParam = g_DataMgr:getGlobalCfgCsv("worldboss_coins_param")/g_BasePercent
	tbSimpleDrop.drop_item_num = math.floor(nDamage/fCoinsParam)
end

function CBattleMgr:handleFighterDieDrop(GameObj_Attacker, bEffect)
	if bEffect then
		self.tbBattleTurn.die_drop_info = GameObj_Attacker:getDieDrop()
	else
		local tbActioncardList = self:getCurrentActioncardList()
		tbActioncardList.die_drop_info = GameObj_Attacker:getDieDrop()
	end
end

--替补规则
function CBattleMgr:handleFighterSubstitution(nEumnBattleSide, nDeadPos, bEffect)
	local GameObj_DeadFigther = self:getFighter(nEumnBattleSide, nDeadPos)
	
	local GameObj_SubFighter = nil
	local nSubstitutionPos = nil
	for i = 10, 12 do 
		GameObj_SubFighter = self:getFighter(nEumnBattleSide, i)
		if GameObj_SubFighter then
			nSubstitutionPos = i
			break
		end
	end
	
	if GameObj_SubFighter and nSubstitutionPos then --替补交换信息
		if bEffect then
			self.tbBattleTurn.die_sub_apos = GameObj_SubFighter.apos
		else
			local tbActioncardList = self:getCurrentActioncardList()
			tbActioncardList.die_sub_apos = GameObj_SubFighter.apos
		end
		self:setFighter(nEumnBattleSide, nDeadPos, GameObj_SubFighter)
		self:setFighter(nEumnBattleSide, nSubstitutionPos, nil)
	else
		self:setFighter(nEumnBattleSide, nDeadPos, nil)
	end
	
end

--伤害数字动画
function CBattleMgr:handleBleedDamage(GameObj_Defencer, nDamageType, nDamageValue)
	if nDamageValue ~= nil and nDamageValue ~= 0 then
		local tbBeDamage = self:addBe_damage()
		tbBeDamage.be_damage_type = nDamageType
		nDamageValue = math.floor(nDamageValue)
		tbBeDamage.be_damage_data = nDamageValue
		GameObj_Defencer:setLostHp(nDamageValue)
	end
	
	if self.battle_type 
        and (self.battle_type == macro_pb.Battle_Atk_Type_WorldBoss 
            or self.battle_type == macro_pb.Battle_Atk_Type_GuildWorldBoss)
		and GameObj_Defencer.is_def == true then
		self:handleWorldBossDrop(nDamageValue, true)
	end
	
	if GameObj_Defencer.hp <= 0 then
		self:handleFighterDie(GameObj_Defencer, true)
	end
end


function CBattleMgr:handleFighterDie(GameObj_DeadFigther, bEffect, nEumnBattleSide, nDeadPos)
	if GameObj_DeadFigther:isDieDrop() then
		self:handleFighterDieDrop(GameObj_DeadFigther, bEffect)
	end
	
	if bEffect then
		nEumnBattleSide = math.mod(math.floor(self.tbBattleTurn.actioninfo / 10), 10) 
		nDeadPos = math.mod(self.tbBattleTurn.actioninfo, 10)
	end
	
	self:handleFighterSubstitution(nEumnBattleSide, nDeadPos, bEffect)
end

--反击计算
function CBattleMgr:handleRestrike(GameObj_Attacker, GameObj_Defencer)
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	
	--单体攻击才可以被反击
	if tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_Single and tbCurrentSkill.Object == macro_pb.Skill_Atk_Object_Enemy and GameObj_Defencer.hp > 0 then
		GameObj_Defencer:setCurrentUseSkill(eumn_skill_index.restrike_skill) -- 设置为反击技能
		local nRestrikeDamage = self:calculateDamage(GameObj_Defencer, GameObj_Attacker) / 2
		self:handleBleedDamage(GameObj_Attacker, macro_pb.Battle_Effect_Hit_Back, nRestrikeDamage)
	end
end

--连击
function CBattleMgr:handleRepeatedAttack(GameObj_Attacker, GameObj_Defencer)
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	local nRepeatCounts = 1
	if tbCurrentSkill.AttackArea == macro_pb.Skill_Atk_Area_TripleHit then
		nRepeatCounts = 2
	end

	for i = 1, nRepeatCounts do
		if GameObj_Defencer.hp > 0 then
			local nDamage = self:calculateDamage(GameObj_Attacker, GameObj_Defencer)
			GameObj_Defencer:setLostHp(nDamage)
			self:addRepeatedDamage(nDamage)
		end
	end
end

--合计计算
function CBattleMgr:handleUnionAttack(GameObj_Attacker, GameObj_Defencer, nDefencePosInBattleMgr)
	local tbCurrentSkill = GameObj_Attacker:getCurrentSkill()
	if GameObj_Attacker:isFitSkill() and GameObj_Defencer.hp > 0 then
		local nEumnBattleSide  = eumn_battle_side.attack
		if GameObj_Attacker.is_def then
			nEumnBattleSide = eumn_battle_side.defence
		end
		local tbFighterList_Atk = self:getFighterListBySide(nEumnBattleSide)
		
		if tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_Self then
			local nUnionAttackPos = -1
			local nMaxSequence = #self.tbFighterSequenceList
			for i = self.nCurrentSequence, nMaxSequence do
				local tbAttackerSequence = self.tbFighterSequenceList[i]
				if tbAttackerSequence.atkno == nEumnBattleSide then
					local GameObj_Fighter = self:getFighter(tbAttackerSequence.atkno, tbAttackerSequence.apos)
					if GameObj_Fighter and GameObj_Fighter.hp > 0 and GameObj_Fighter.apos ~= GameObj_Attacker.apos then
						nUnionAttackPos = GameObj_Fighter.apos
						break
					end
				end
			end
			if nUnionAttackPos < 0 then
				for i = 1, self.nCurrentSequence -1  do
					local tbAttackerSequence = self.tbFighterSequenceList[i]
					if tbAttackerSequence.atkno == nEumnBattleSide then
						local GameObj_Fighter = self:getFighter(tbAttackerSequence.atkno, tbAttackerSequence.apos)
						if GameObj_Fighter and GameObj_Fighter.hp > 0 and GameObj_Fighter.apos ~= GameObj_Attacker.apos then
							nUnionAttackPos = GameObj_Fighter.apos
							break
						end
					end
				end
			end
			if nUnionAttackPos > 0 and nUnionAttackPos ~= GameObj_Attacker.apos then
				self:FitHitSingle(tbFighterList_Atk, GameObj_Defencer, nUnionAttackPos)
			end
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_Line then
			self:FitHitLine(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
			
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_Row then
			self:FitHitRow(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_All then
			self:FitHitAll(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_FrontRow then
			self:FitHitFront(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_BackRow then
			self:FitHitBack(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_FewHP then
			self:FitHitFewHP(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_Random then
			self:FitHitRandom(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_HigherMana then
			self:FitHigherMana(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		elseif tbCurrentSkill.UnionAttackType == macro_pb.Skill_Atk_Area_FewPrecentHP then
			self:FitFewPrecentHP(tbFighterList_Atk, GameObj_Defencer, GameObj_Attacker.apos)
		
		else
			SendError("客户端战斗调试=========Skill Fittype Error skillid:"..(tbCurrentSkill.ID).." atkarea: "..tbCurrentSkill.UnionAttackType)
			return
		end
	end

end
--对话是否要展示
function CBattleMgr:getIsFirstInThisBattle()
	if g_BattleTeachSystem and g_BattleTeachSystem:IsTeaching() then
		return true
	else
		if g_Hero.isF then
			return g_Hero.isF
		end
	end
	
	return self.isFirst
end

function CBattleMgr:setIsFirstInThisBattle(flag)
	self.isFirst = flag
end

function CBattleMgr:reNewBattleData()
	g_BattleMgr = CBattleMgr.new()
end

function CBattleMgr:getBattleSideAndPosInBattleMgr(nPos)
    if nPos and nPos >10 then
        return eumn_battle_side.defence, nPos - 10
    else
        return eumn_battle_side.attack, nPos
    end
end

function CBattleMgr:getFighterHpByPos(nPos)
	local nEumnBattleSide, nPosInBattleMgr = self:getBattleSideAndPosInBattleMgr(nPos)
	local GameObj_Fighter = self:getFighter(nEumnBattleSide, nPosInBattleMgr)
	if GameObj_Fighter then
		return GameObj_Fighter.hp
	end
	return 0
end

function CBattleMgr:checkFighterIsDeadByPos(nPos, nUniqueId)
	local nEumnBattleSide, nPosInBattleMgr = self:getBattleSideAndPosInBattleMgr(nPos)
	local GameObj_Fighter = self:getFighter(nEumnBattleSide, nPosInBattleMgr)
	if GameObj_Fighter ~= nil and GameObj_Fighter ~= {} then
		if nUniqueId == GameObj_Fighter.unique_id then
			if GameObj_Fighter.hp <= 0 then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		return true
	end
	return true
end


--------------------------------------------------初始化全局的对象
g_BattleMgr = CBattleMgr.new()

