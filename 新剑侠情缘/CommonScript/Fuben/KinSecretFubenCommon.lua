Fuben.KinSecretMgr = Fuben.KinSecretMgr or {}
local KinSecretMgr = Fuben.KinSecretMgr

KinSecretMgr.Def = {
	nMaxCountPerKin = 3,	--每个家族最多同时开启数目
	nMinLevel = 20,	--最低参与等级
	nJoinMin = 0,	--最低参加人数
	nJoinMax = 50,	--最多参加人数
	nPrepareTime = 180,	--准备阶段时间
	nTotalTime = 25*60,	--总计时间（含准备阶段）
	nMapTemplateId = 1073, --地图ID

	tbRoomNames = {"天", "地", "人"},

	nAoeAvoidBuffDelayAdd = 4,	--延迟多久添加躲避AOE伤害buff
	tbAoeAvoidBuff = {3766, 1, 3},	--被选中玩家躲避AOE伤害buff，{buffid, 等级, 持续（秒）}
	tbAoeSkillCfg = {5101, 18}, --AOE技能，{id, 等级}

	nPick2DelayCheck = 8,	--延迟多久检查玩家距离
	nPick2DistanceA = 800,	--同极真气，最小距离
	nPick2DistanceB = 300,	--异极真气，最大距离
	nPick2DeathDropNpcId = 2932,	--玩家死亡掉落npc id
	szPick2DeathDropNpcGrp = "dushui",	--玩家死亡掉落npc的group

	nLevelRewardBoxId = 7647,	--通关获得的宝箱id
	tbLevelRewardBoxCount = {1, 3, 5},	--关卡奖励宝箱数

	tbLevelValue = {50000, 80000, 120000},	--关卡价值量
	tbAuctionSettings = {	--拍卖,需按时间轴，从大到小配
		{"OpenLevel129", {
			{nItemId=3715, nPercent=1/20, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=3716, nPercent=1/10, nValue=1000000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/10, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=3/20, nValue=4050000, bGuarantee=true},
			{nItemId=2804, nPercent=1/4, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=3/20, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=200000, bGuarantee=false, nGroup=1},
			--{3715, 1/10, 750000}, {3716, 1/10, 1000000}, {7650, 1/5, 1350000}, {7648, 3/20, 4050000, true}, {2804, 1/10, 600000}, {3693, 3/20, 3000000, true}, {6149, 1/20, 200000}, {6150, 1/20, 200000}, {6276, 1/10, 200000},
		}},
		{"OpenLevel119", {
			{nItemId=3715, nPercent=1/10, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=3716, nPercent=1/10, nValue=1000000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/5, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=3/20, nValue=4050000, bGuarantee=true},
			{nItemId=2804, nPercent=1/10, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=3/20, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=200000, bGuarantee=false, nGroup=1},
			--{3715, 1/10, 750000}, {3716, 1/10, 1000000}, {7650, 1/5, 1350000}, {7648, 3/20, 4050000, true}, {2804, 1/10, 600000}, {3693, 3/20, 3000000, true}, {6149, 1/20, 200000}, {6150, 1/20, 200000}, {6276, 1/10, 200000},
		}},
		{"OpenLevel109", {
			{nItemId=3715, nPercent=1/10, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/5, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=3/20, nValue=4050000, bGuarantee=true},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=200000, bGuarantee=false, nGroup=1},
			--{3715, 1/10, 750000}, {7650, 1/5, 1350000}, {7648, 3/20, 4050000, true}, {2804, 3/20, 600000}, {3693, 1/5, 3000000, true}, {6149, 1/20, 200000}, {6150, 1/20, 200000}, {6276, 1/10, 200000},
		}},
		{"OpenLevel99", {
			{nItemId=3714, nPercent=1/10, nValue=500000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/5, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=3/20, nValue=4050000, bGuarantee=true},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=200000, bGuarantee=false, nGroup=1},
			--{3714, 1/10, 500000}, {7650, 1/5, 1350000}, {7648, 3/20, 4050000, true}, {2804, 3/20, 600000}, {3693, 1/5, 3000000, true}, {6149, 1/20, 200000}, {6150, 1/20, 200000}, {6276, 1/10, 200000},
		}},
		{"OpenLevel89", {
			{nItemId=3714, nPercent=1/10, nValue=500000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/4, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=3/20, nValue=4050000, bGuarantee=true},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/10, nValue=200000, bGuarantee=false, nGroup=1},
			--{3714, 1/10, 500000}, {7650, 1/4, 1350000}, {7648, 3/20, 4050000, true}, {2804, 3/20, 600000}, {3693, 1/5, 3000000, true}, {6149, 1/20, 200000}, {6150, 1/10, 200000},
		}},
		{"OpenLevel79", {
			{nItemId=3714, nPercent=1/5, nValue=500000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/4, nValue=1350000, bGuarantee=false},
			{nItemId=2804, nPercent=1/5, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=3/20, nValue=200000, bGuarantee=false, nGroup=1},
			--{3714, 1/5, 500000}, {7650, 1/4, 1350000}, {2804, 1/5, 600000}, {3693, 1/5, 3000000, true}, {6149, 3/20, 200000},
			}},
	},

	nReviveAddTime = 5,	--复活等待时间随死亡次数递增(秒)
	nReviveMaxTime = 5,	--复活等待时间最大值（秒）
	nDeathSkillId = 1501,	--重伤状态

	nPlayerDieBossAddBuffId = 5113,	--玩家死亡给boss加的buff id
	nPlayerDieBossAddBuffMaxLvl = 50,	--玩家死亡给boss加buff的最高等级

	tbRoomBosses = {	--关卡boss配置，用于重置关卡，参见TestFuben:AddNpc
		[1] = { {1, 1, 31, "BOSS1", "boss1_1", false, 1, 0, 0, 0} },
		[2] = { {2, 1, 41, "BOSS2", "boss2_1", false, 16, 0, 0, 0} },
		[3] = { {3, 1, 0, "BOSS3A", "boss3_1", false, 16, 0, 0, 0},
				{4, 1, 0, "BOSS3B", "boss3_2", false, 16, 0, 0, 0} },
	},

	tbTrapIn = {
		in_j = "jin",
		in_m = "mu",
		in_s = "shui",
		in_h = "huo",
		in_t = "tu",
	},

	tbTrapOut = {
		out_j = "jin",
		out_m = "mu",
		out_s = "shui",
		out_h = "huo",
		out_t = "tu",
	},

	tbBoss2PlayerAoeBuff = {3766, 5},	--第二个boss释放AOE技能时玩家躲避buff {id, 持续时间}
	nBoss2ChangeBuffDelay = 5,	--第二个boss改变五行属性等待时间（秒）
	tbBoss2HpCfg = {	--第二关boss血量事件
		{90, "jin", 5100, "锐金之力助我！", "杨影枫变为[FFFE0D]金[-]系护体状态，快将其诱导至[FFFE0D]火[-]系法阵中"},	--百分比，类型，称号，喊话，黑条提示
		{70, "mu", 5101, "巨木之力助我！", "杨影枫变为[FFFE0D]木[-]系护体状态，快将其诱导至[FFFE0D]金[-]系法阵中"},
		{50, "shui", 5102, "洪水之力助我！", "杨影枫变为[FFFE0D]水[-]系护体状态，快将其诱导至[FFFE0D]土[-]系法阵中"},
		{30, "huo", 5103, "烈火之力助我！", "杨影枫变为[FFFE0D]火[-]系护体状态，快将其诱导至[FFFE0D]水[-]系法阵中"},
		{10, "tu", 5104, "厚土之力助我！", "杨影枫变为[FFFE0D]土[-]系护体状态，快将其诱导至[FFFE0D]木[-]系法阵中"},
		{60, "aoe", nil, "看我这招潇湘剑雨！", "快躲入自己职业对应的五行法阵中去！"},
		{20, "aoe", nil, "看我这招潇湘剑雨！", "快躲入自己职业对应的五行法阵中去！"},
	},

	nBoss2AoePrepareSkillId = 1523,	--第二个boss aoe预警技能

	nBoss2AoeSkillId = 5115,	--第二个boss aoe技能
	nBoss2AoeSkillDelay = 8,	--第二个boss aoe技能蓄力时间
	tbBoss2Buffs = {	--第二个boss x系护体buff，{buffid, 等级}
		jin = {5104, 20},
		mu = {5105, 20},
		shui = {5106, 20},
		huo = {5107, 20},
		tu = {5108, 20},
	},

	--第三关boss点名时给玩家加的buff, {ID, 持续时间（秒）}
	tbBoss3PlayerBuffA = {5109, 5},		--A
	tbBoss3PlayerBuffB = {5110, 5},		--B

	nBoss3ABuff = {5111, 20},	--第三关boss A buff {id, level}
	nBoss3BBuff = {5112, 20},	--第三关boss B buff
	nBoss3ACrazyBuff = {5114, 1},	--第三关boss A狂暴Buff

	nKickWaitTime = 10,	--踢人等待时间
}

function KinSecretMgr:CanKick(pPlayer)
	if not Kin:CanControlFuben(pPlayer.dwID) then
		return false
	end
    return pPlayer.nMapTemplateId==self.Def.nMapTemplateId
end