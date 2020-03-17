CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil

CurrentSceneScript.BossID = nil
CurrentSceneScript.BossHp = nil
CurrentSceneScript.NoticeType = 0
CurrentSceneScript.WorldLevel = 0
CurrentSceneScript.HpNotice_WorldHuman = {} -- Boss血剩余到一定阶段时，给世界内所有玩家发的通知
CurrentSceneScript.HpNotice_SceneHuman = {} -- Boss血剩余到一定阶段时，给当前活动场景内所有玩家发的通知

CurrentSceneScript.rewardStage_table =
{
	-- {Boss血量剩余阶段, 通知ID}
	{9,	11678}, -- 血量小于等于10%，第9阶段
	{8,	11677}, -- 血量小于等于20%，第8阶段
	{7,	11676}, -- 血量小于等于30%，第7阶段
	{6,	11675}, -- 血量小于等于40%，第6阶段
	{5,	11674}, -- 血量小于等于50%，第5阶段
	{4,	11673}, -- 血量小于等于60%，第4阶段
	{3,	11672}, -- 血量小于等于70%，第3阶段
	{2,	11671}, -- 血量小于等于80%，第2阶段
	{1,	11670}, -- 血量小于等于90%，第1阶段
}

-- 玩家属性常量枚举 EStatType :
CurrentSceneScript.EStatType_Hp = 19
CurrentSceneScript.EStatType_MaxHp = 20

-- 服务端返回: 金币BOSS技能通知 --- 特效类型：SC_GoldBossNotice.type
CurrentSceneScript.EffectType_A_A = 1 -- A区域A技能
CurrentSceneScript.EffectType_A_B = 2 -- A区域B技能
CurrentSceneScript.EffectType_B_A = 3 -- B区域A技能
CurrentSceneScript.EffectType_B_B = 4 -- B区域B技能
CurrentSceneScript.EffectType_BossHurt = 5 -- BOSS受伤

CurrentSceneScript.eBossInfoNotify_Self = 1		-- 只给玩家自己推送Boss血量通知
CurrentSceneScript.eBossInfoNotify_Scene = 2	-- 给场景内所有玩家推送Boss血量通知
-----------------------------------------------------------

-- 在C++中调用的脚本函数，需要注册一个事件
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.SModObjects = self.Scene:GetModObjects()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter") -- SCENE_EVENT_HUMAN_ENTER_WORLD
    _RegSceneEventHandler(SceneEvents.HumanLeaveWorld,"OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.StartGoldBoss, "StartGoldBoss")
	_RegSceneEventHandler(SceneEvents.MonsterHited, "OnMonsterHited") -- SCENE_EVENT_MONSTER_BEHIT
	_RegSceneEventHandler(SceneEvents.HumanTeleport, "OnHumanTeleport")
	_RegSceneEventHandler(SceneEvents.MonsterKilled, "OnMonsterKilled") -- SCENE_EVENT_MONSTER_KILLED
end

function CurrentSceneScript:Cleanup()
end

function CurrentSceneScript:OnHumanEnter(human)
	if human == nil then
		return
	end
	
	if self.BossID == nil then
		return
	end
	
	local monster = self.SModObjects:GetMonsterByTid(self.BossID)
	if monster == nil then
		return
	end
	
	local hp = monster:GetIntAttr(self.EStatType_Hp)
	human:GetModGoldBoss():SendUpdateGoldBossInfoNotify(hp, self.eBossInfoNotify_Self)
end

function CurrentSceneScript:OnHumanLeave(human)
	if human == nil then
		return
	end
end

function CurrentSceneScript:StartGoldBoss()
	self.WorldLevel = self.Scene:GetModScript():GetWorldLvl()

	-- 根据策划要求，如果取不到全服等级，则取这个服最大玩家等级
	-- 如果还取不到，就取第一个
	if self.WorldLevel == 0 then
		self.WorldLevel = self.Scene:GetModScript():GetMaxHumanLvl()
	end
	if self.WorldLevel == 0 then
		self.WorldLevel = 1
	end

	local bossID = GoldbossConfig[tostring(self.WorldLevel)]['bossID']

	if bossID == nil then
		return
	end

	local goldBossParConfig = GoldbossparConfig['1']
	local bossEnter = goldBossParConfig['boss_enter']

	local positionConfig = PositionConfig[tostring(bossEnter)]
	local positionArray = split(positionConfig['pos'], ',')

	self.Scene:GetModSpawn():Spawn(bossID, tonumber(positionArray[2]), tonumber(positionArray[3]), tonumber(positionArray[4]))

	-- 财神BOSS会每20秒（暂定）对随机一个区域释放一个技能
	-- 2015/10/12：根据策划需求暂时屏蔽
	-- self.SModScript:CreateTimer(20, "OnBossSkillTimer")
	-- self.SModScript:CreateTimer(15, "OnBossSkillReadyTimer")

	--必要的其它初始化
	for i = 1, 3 do self.HpNotice_WorldHuman[i] = false end
	for i = 1, 9 do self.HpNotice_SceneHuman[i] = false end
	
	self.BossID = bossID
end

-- Boss血剩余到一定阶段时，给场景内所有玩家发奖励
function CurrentSceneScript:OnMonsterHpRemain(stage)
	if stage == nil then
		return
	end

	-- 判断是否是在活动对应场景mapID
	local goldBossMapId = GoldbossparConfig['1']['mapid']
	if self.Scene:GetBaseMapID() ~= goldBossMapId then
		return
	end

	for k, v in pairs(self.Humans) do
		v:GetModGoldBoss():OnMonsterHpRemain(self.WorldLevel, stage)
	end
end

-- 注意：真正的Boss扣血，都在cpp代码中而不是脚本中处理
function CurrentSceneScript:OnMonsterHited(monster, human)
	if monster == nil or human == nil then
		return
	end

	-- 判断是否是在活动对应场景mapID
	local goldBossMapId = GoldbossparConfig['1']['mapid']
	if self.Scene:GetBaseMapID() ~= goldBossMapId then
		return
	end

	local maxHp = monster:GetIntAttr(self.EStatType_MaxHp)
	local hp = monster:GetIntAttr(self.EStatType_Hp)

	if self.BossHp == nil then
		self.BossHp = maxHp
	end

	local deltaHp = self.BossHp - hp
	human:GetModGoldBoss():OnMonsterHited(self.WorldLevel, deltaHp)

	self.BossHp = hp
	self.Scene:GetModScript():SendGoldBossNotice(human, self.EffectType_BossHurt)
	
	human:GetModGoldBoss():SendUpdateGoldBossInfoNotify(hp, self.eBossInfoNotify_Scene)

	local percent = hp / maxHp
	if maxHp <= 0 then
		return
	end

	-- 通知全服玩家Boss血量剩余值
	if percent <= 0.1 then
		if self.HpNotice_WorldHuman[1] == false then
			_SendNotice(11669)
			self.HpNotice_WorldHuman[1] = true
		end
	elseif percent <= 0.3 then
		if self.HpNotice_WorldHuman[2] == false then
			_SendNotice(11668)
			self.HpNotice_WorldHuman[2] = true
		end
	elseif percent <= 0.5 then
		if self.HpNotice_WorldHuman[3] == false then
			_SendNotice(11667)
			self.HpNotice_WorldHuman[3] = true
		end
	end

	-- Boss血量发放：90#80#70#60#50#40#30#20#10#0
	local cfgStage_HP = GoldbossparConfig['1']['reward_hp_lv_set']
	local cfgStage_HP_table = split(cfgStage_HP, '#')

	-- 通知Boss场景内玩家Boss血量剩余值，一共分9个阶段
	for k,v in pairs(self.rewardStage_table) do
		local info = v
		local stage = tonumber(info[1])
		local noticeid = tonumber(info[2])
		local cfg_per = tonumber(cfgStage_HP_table[stage])/100

		if percent <= cfg_per then
			if self.HpNotice_SceneHuman[stage] == false then
				_SendNotice(noticeid, "", self.Scene:GetGameMapID())
				self:OnMonsterHpRemain(stage)
				self.HpNotice_SceneHuman[stage] = true
				break
			end
		end
	end
end

-- 2015/10/12：根据策划需求暂时屏蔽
function CurrentSceneScript:OnBossSkillTimer()
	local goldBossParConfig = GoldbossparConfig['1']

	-- 判断是否是在活动对应场景mapID
	local goldBossMapId = goldBossParConfig['mapid']
	if self.Scene:GetBaseMapID() ~= goldBossMapId then
		return
	end

	local markA = goldBossParConfig['mark_A']
	local markB = goldBossParConfig['mark_B']

	local positionConfigA = PositionConfig[tostring(markA)]
	local positionArrayA = split(positionConfigA['pos'], ',')

	local positionConfigB = PositionConfig[tostring(markB)]
	local positionArrayB = split(positionConfigB['pos'], ',')

	if self.NoticeType == self.EffectType_A_A then
		self.Scene:GetModScript():OnBossSkill(6010003, tonumber(positionArrayA[2]), tonumber(positionArrayA[3]))
	end

	if self.NoticeType == self.EffectType_A_B then
		self.Scene:GetModScript():OnBossSkill(6010004, tonumber(positionArrayB[2]), tonumber(positionArrayB[3]))
	end

	if self.NoticeType == self.EffectType_B_A then
		self.Scene:GetModScript():OnBossSkill(6010003, tonumber(positionArrayA[2]), tonumber(positionArrayA[3]))
	end

	if self.NoticeType == self.EffectType_B_B then
		self.Scene:GetModScript():OnBossSkill(6010004, tonumber(positionArrayB[2]), tonumber(positionArrayB[3]))
	end

	self.SModScript:CreateTimer(20, "OnBossSkillTimer")
	self.SModScript:CreateTimer(15, "OnBossSkillReadyTimer")
end

-- 2015/10/12：根据策划需求暂时屏蔽
function CurrentSceneScript:OnBossSkillReadyTimer()
	-- 判断是否是在活动对应场景mapID
	local goldBossMapId = GoldbossparConfig['1']['mapid']
	if self.Scene:GetBaseMapID() ~= goldBossMapId then
		return
	end

	local randArea = math.random(1, 2)
	local randSkill = math.random(1, 2)

	if randArea == 1 then
		if randSkill == 1 then
			self.NoticeType = self.EffectType_A_A
		else
			self.NoticeType = self.EffectType_A_B
		end
	else
		if randSkill == 1 then
			self.NoticeType = self.EffectType_B_A
		else
			self.NoticeType = self.EffectType_B_B
		end
	end

	for k, v in pairs(self.Humans) do
		self.Scene:GetModScript():SendGoldBossNotice(v, self.NoticeType)
	end
end

function CurrentSceneScript:OnHumanTeleport(human, x, z)
	if human == nil or x == nil or z == nil then
		return
	end
end

function CurrentSceneScript:OnMonsterKilled(monster,killer,tid)
	if monster == nil or killer == nil or tid == nil then
		return
	end
	
	-- 判断是否是在活动对应场景mapID
	local goldBossMapId = GoldbossparConfig['1']['mapid']
	if self.Scene:GetBaseMapID() ~= goldBossMapId then
		return
	end

	for k, v in pairs(self.Humans) do
		v:GetModGoldBoss():OnMonsterKilled(self.WorldLevel)
	end
	
	_SendNotice(11679, "", self.Scene:GetGameMapID())
end