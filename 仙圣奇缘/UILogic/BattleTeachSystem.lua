--------------------------------------------------------------------------------------
-- 文件名:	BattleTeachSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	战斗教学
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

BattleTeachSystem = class("BattleTeachSystem")
BattleTeachSystem.__index = BattleTeachSystem

function BattleTeachSystem:ctor()
    self.bTeachIng =  false
    self.nSpeedtemp = nil
end

--[[
//战斗场景
message BattleScence
{
    optional uint32 battle_type = 1; // 战斗类型
    optional uint32 mapid = 2; // 副本中就是副本id，竞技场，就是竞技场id
    optional BattleArmyInfo atkarmy = 3; //攻方队伍
    repeated BattleArmyInfo defarmylist = 4; //守方队伍列表
    optional string def_name = 5; // 守方名字
}

    message BattleArmyInfo
{
    repeated BattleCardInfo cardinfo = 1;
    optional uint32 preattack = 2;
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

]]
function BattleTeachSystem:Init()
	CCUserDefault:sharedUserDefault():setBoolForKey("IsAutoFight", false)
	CCUserDefault:sharedUserDefault():setIntegerForKey("nAccelerateSpeed", 1)
	
    self.tabBattleData = zone_pb.BattleScenceNotify()
    self.tabBattleData.mapid = 1997001
	self.tabBattleData.battle_type = macro_pb.Battle_Atk_Type_Player

    local defmsg = common_pb.BattleArmyInfo()
    defmsg.preattack = 0
	
	local CSV_BattleTeach_Card = g_DataMgr:getCsvConfig_FirstKeyData("BattleTeach", 1)
	if CSV_BattleTeach_Card == nil then
		return false
	end

	for nIndex = 1, #CSV_BattleTeach_Card do
		local tbBattleCard = g_copyTab(CSV_BattleTeach_Card[nIndex])
		tbBattleCard.is_card = self:GetCsvBool(CSV_BattleTeach_Card[nIndex].is_card)
		tbBattleCard.is_def = self:GetCsvBool(CSV_BattleTeach_Card[nIndex].is_def)
		tbBattleCard.skill_lv_list = self:GetSkillLv(CSV_BattleTeach_Card[nIndex].skill_lv_list)

		local Card = common_pb.BattleCardInfo()
		self:InitBattleDate(Card, tbBattleCard)

		if Card.is_card then
			self.tabBattleData.atkarmy.preattack = self.tabBattleData.atkarmy.preattack + CSV_BattleTeach_Card[nIndex].preattack
			table.insert(self.tabBattleData.atkarmy.cardinfo, Card)
		else
			defmsg.preattack = defmsg.preattack + CSV_BattleTeach_Card[nIndex].preattack
			table.insert(self.tabBattleData.atkarmy.cardinfo, Card)
		end
	end
	
	local CSV_BattleTeach_Monster = g_DataMgr:getCsvConfig_FirstKeyData("BattleTeach", 2)
	if CSV_BattleTeach_Monster == nil then
		return false
	end

	for nIndex = 1, #CSV_BattleTeach_Monster do
		local tbBattleCard = g_copyTab(CSV_BattleTeach_Monster[nIndex])
		tbBattleCard.is_card = self:GetCsvBool(CSV_BattleTeach_Monster[nIndex].is_card)
		tbBattleCard.is_def = self:GetCsvBool(CSV_BattleTeach_Monster[nIndex].is_def)
		tbBattleCard.skill_lv_list = self:GetSkillLv(CSV_BattleTeach_Monster[nIndex].skill_lv_list)

		local Card = common_pb.BattleCardInfo()
		self:InitBattleDate(Card, tbBattleCard)

		if Card.is_card then
			self.tabBattleData.atkarmy.preattack = self.tabBattleData.atkarmy.preattack + CSV_BattleTeach_Monster[nIndex].preattack
			table.insert(defmsg.cardinfo, Card)
		else
			defmsg.preattack = defmsg.preattack + CSV_BattleTeach_Monster[nIndex].preattack
			table.insert(defmsg.cardinfo, Card)
		end
	end

    table.insert(self.tabBattleData.defarmylist, defmsg)

--    cclog("====== "..tostring(self.tabBattleData))
	
	return true
end

function BattleTeachSystem:Begin()
    self:Init()
    --因为战斗里面的的所有窗口都是依赖这个对象，但是它是在function MainScene:ctor() 里面才初始化的。所以这里先预先初始化
    -- mainWnd = CCDirector:sharedDirector():getRunningScene()
    mainWnd = CCScene:create()

    CCDirector:sharedDirector():pushScene(mainWnd)

    self.bTeachIng =  true

    local function onEnterOrExit(tag)
        if tag == "enter" then
            local function initBattleEndCall(tbBattleScenceInfo)
                proLoadBattleRersouce(tbBattleScenceInfo, self.tabBattleData)
                if g_PlayerGuide:setCurrentGuideSequence(1000, 1) then
                    g_PlayerGuide:showCurrentGuideSequenceNode()
                end
            end
            g_BattleMgr:initBattle(self.tabBattleData, initBattleEndCall)

        elseif tag == "exit" then
            
        end
    end
    mainWnd:registerScriptHandler(onEnterOrExit)
end

function BattleTeachSystem:End()

    for k, v in pairs(TbBattleReport.tbGameFighters_OnWnd) do
        v.CCNode_Skeleton:setSpeed(0.1)
    end

	
    local function BattleTeachOverCallBack()
        g_PlayerGuide:destroyGuide()
        g_RemoveAllBattlePlistResource()

        --[[for k, v in pairs(TbBattleReport.tbGameFighters_OnWnd ) do
            v:release()
        end
        TbBattleReport.tbGameFighters_OnWnd = {}
        TbBattleReport.Mesh:removeAllChildrenWithCleanup(true)
        TbBattleReport = nil
        TbBattleReport = {}]]

        g_WndMgr:closeWnd("Game_Battle")

        g_ClearSpineAnimation()
        g_WndMgr:dumpAnimationResouce()

        CCTextureCache:sharedTextureCache():removeAllTextures()

        CCArmatureDataManager:purge()
        CCAnimationCache:purgeSharedAnimationCache()
        GUIReader:purge()
        CCDirector:sharedDirector():purgeCachedData()
		
		if g_BattleResouce then
			g_BattleResouce:ReleaseCach()
		end
	    collectgarbage("collect")
        
        g_WndMgr:ResetWndEx()
        CCDirector:sharedDirector():popScene() --此方法进入到 startGame
        g_MsgMgr:requestRandomName()

        g_BattleTeachSystem = BattleTeachSystem.new()

        g_StoryScene:SetFormBattleTeachTrue()
    end

    g_StoryScene:OnExitBattleScene(BattleTeachOverCallBack)
end

function BattleTeachSystem:split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function BattleTeachSystem:GetSkillLv(strLv)
	local strbal =  self:split(strLv, '|')
	local arr = {}
	if strbal ~= nil then

		for k, v in pairs(strbal)do

			table.insert(arr, tonumber(v))
		end
	end
	return arr
end

function BattleTeachSystem:IsTeaching()
    return self.bTeachIng
end

function BattleTeachSystem:GetCsvBool(vaule)
	return (vaule == 1) and true or false
end

function BattleTeachSystem:InitBattleDate(CardData, tabInfo)
    CardData.arraypos = tabInfo.arraypos
    CardData.configid = tabInfo.configid 
    CardData.star_lv = tabInfo.star_lv
    CardData.card_lv = tabInfo.card_lv
    CardData.is_card = tabInfo.is_card
    CardData.normal_skill_lv = tabInfo.normal_skill_lv 
    CardData.powerful_skill_lv = tabInfo.powerful_skill_lv
    CardData.hp = tabInfo.hp
    CardData.max_hp = tabInfo.max_hp 
    CardData.sp = tabInfo.sp
    CardData.max_sp = tabInfo.max_sp
    CardData.preattack = tabInfo.preattack

 
    CardData.phy_attack = tabInfo.phy_attack
    CardData.phy_defence = tabInfo.phy_defence
    CardData.mag_attack = tabInfo.mag_attack
    CardData.mag_defence = tabInfo.mag_defence
    CardData.skill_attack = tabInfo.skill_attack
    CardData.skill_defence = tabInfo.skill_defence
    CardData.critical_chance = tabInfo.critical_chance
    CardData.critical_resistance = tabInfo.critical_resistance 
    CardData.critical_strike = tabInfo.critical_strike
    CardData.critical_strikeresistance = tabInfo.critical_strikeresistance
    CardData.hit_change = tabInfo.hit_change
    CardData.dodge_chance = tabInfo.dodge_chance
    CardData.penetrate_chance = tabInfo.penetrate_chance
    CardData.block_chance = tabInfo.block_chance
    CardData.damage_reduction = tabInfo.damage_reduction
    CardData.is_def = tabInfo.is_def
    
    -- CardData.skill_lv_list = tabInfo.skill_lv_list
    for k, v in pairs(tabInfo.skill_lv_list)do
        table.insert(CardData.skill_lv_list, v)
    end

    CardData.cardid = tabInfo.cardid
    CardData.breachlv = tabInfo.breachlv 
    CardData.attend_step = tabInfo.attend_step
end

function BattleTeachSystem:EnterBattleSenceDialogue(CallBack)
    --进入战斗教学场景 对话回调
    CallBack(1110002, 2)
end

function BattleTeachSystem:SkillActtckCall(attackcount ,luaCallback, nAttackPos)
   
    for k, v in pairs(TbBattleReport.tbGameFighters_OnWnd) do
		if k ~= nAttackPos then
			v.CCNode_Skeleton:setSpeed(0.0)
		else
			v.CCNode_Skeleton:setSpeed(0.5)
		end
    end

    local function DialogueCallBack()
        if luaCallback then
            luaCallback()
            if self.nSpeedtemp then
                g_TimeSpeed = self.nSpeedtemp
            end
        end
        
        for k, v in pairs(TbBattleReport.tbGameFighters_OnWnd) do
			v.CCNode_Skeleton:setSpeed(g_nBaseSpeed+g_nSpineIdleAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed * g_nIdleSpeedParam)
		end
    end
    if attackcount > 37 then
        DialogueCallBack()
    else
        if not self.nSpeedtemp then
            self.nSpeedtemp = g_TimeSpeed
        end
		 -- DialogueCallBack()
        g_DialogueData:showDialogueSequence(1110001, attackcount, DialogueCallBack, 100)
    end
    
end

-----------------------------------
g_BattleTeachSystem = BattleTeachSystem.new()