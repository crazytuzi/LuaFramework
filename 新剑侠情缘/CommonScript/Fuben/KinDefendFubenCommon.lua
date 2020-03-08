Fuben.KinDefendMgr = Fuben.KinDefendMgr or {}
local KinDefendMgr = Fuben.KinDefendMgr

KinDefendMgr.Def = {
	nMinLevel = 20,	--最低参与等级
	nJoinMin = 10,	--最低参加人数
	nPrepareTime = 5 * 60,	--准备阶段时间
	nTotalTime = 25 * 60,	--总计时间（含准备阶段）

	szOpenTime = "21:00",	--开启时间，用于提示选择难度
	tbNoticeTime = {"20:30", "20:45", "20:55"},	--提示选难度时间列表

	nMaxConfirmedCount = 6,	--最多可允许x个玩家拥有挑战资格

	tbMapTemplateId = {1074, 1075, 1076},	--难度对应的地图id，从简单到困难
	tbDifficultyNames = {"简单", "普通", "困难"},
	tbSuggestJoinCount = {30, 60, 90},	--难度推荐人数

	tbFenShenRewardBox = {{10154, 2}, {10154, 2}, {10154, 2}}, --每击杀1个分身获得宝箱id和数量（三档难度）
	tbFenShenKillerReward = {	--击杀分身者奖励
		[1] = {	--难度1
			{"item", 10154, 2},
			{"item", 10156, 1},
		},
		[2] = {
			{"item", 10154, 2},
			{"item", 10156, 1},
		},
		[3] = {
			{"item", 10154, 2},
			{"item", 10156, 1},
		},
	},

	tbBossValue = {50000, 70000, 100000},	--boss价值量
	tbFenShenValue = {20000, 30000, 50000},	--单个分身价值量
	tbAuctionMemberRange = {20, 90},	--拍卖奖励价值计算时，参与人数上下限
	tbAuctionSettings = {	--拍卖,需按时间轴，从大到小配
		{"OpenLevel139", {
			{nItemId=3715, nPercent=1/20, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=3716, nPercent=1/10, nValue=1000000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/20, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=1/10, nValue=4050000, bGuarantee=true},
			{nItemId=10128, nPercent=3/20, nValue=4050000, bGuarantee=false},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=3/20, nValue=3000000, bGuarantee=true},
			{nItemId=6150, nPercent=1/20, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6277, nPercent=1/10, nValue=600000, bGuarantee=false, nGroup=1},
		}},
		{"OpenLevel129", {
			{nItemId=3715, nPercent=1/20, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=3716, nPercent=1/10, nValue=1000000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/10, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=1/10, nValue=4050000, bGuarantee=true},
			{nItemId=10128, nPercent=3/20, nValue=4050000, bGuarantee=false},
			{nItemId=2804, nPercent=1/10, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=3/20, nValue=3000000, bGuarantee=true},
			{nItemId=6150, nPercent=1/20, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6277, nPercent=1/10, nValue=600000, bGuarantee=false, nGroup=1},
		}},
		{"OpenLevel119", {
			{nItemId=3715, nPercent=1/10, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=3716, nPercent=1/10, nValue=1000000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/10, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=1/10, nValue=4050000, bGuarantee=true},
			{nItemId=10128, nPercent=3/20, nValue=4050000, bGuarantee=false},
			{nItemId=2804, nPercent=1/10, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=3/20, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=400000, bGuarantee=false, nGroup=1},
		}},
		{"OpenLevel109", {
			{nItemId=3715, nPercent=1/10, nValue=750000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=3/20, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=1/20, nValue=4050000, bGuarantee=true},
			{nItemId=10128, nPercent=3/20, nValue=4050000, bGuarantee=false},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=400000, bGuarantee=false, nGroup=1},
		}},
		{"OpenLevel99", {
			{nItemId=3714, nPercent=1/10, nValue=500000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=3/20, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=1/20, nValue=4050000, bGuarantee=true},
			{nItemId=10128, nPercent=3/20, nValue=4050000, bGuarantee=false},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/20, nValue=400000, bGuarantee=false, nGroup=1},
			{nItemId=6276, nPercent=1/10, nValue=400000, bGuarantee=false, nGroup=1},
		}},
		{"OpenLevel89", {
			{nItemId=3714, nPercent=1/10, nValue=500000, bGuarantee=false, nGroup=1},
			{nItemId=7650, nPercent=1/4, nValue=1350000, bGuarantee=false},
			{nItemId=7648, nPercent=1/20, nValue=4050000, bGuarantee=true},
			{nItemId=10128, nPercent=3/20, nValue=4050000, bGuarantee=false},
			{nItemId=2804, nPercent=3/20, nValue=600000, bGuarantee=false},
			{nItemId=3693, nPercent=1/5, nValue=3000000, bGuarantee=true},
			{nItemId=6149, nPercent=1/20, nValue=200000, bGuarantee=false, nGroup=1},
			{nItemId=6150, nPercent=1/10, nValue=400000, bGuarantee=false, nGroup=1},
		}},
	},

	nReviveMaxTime = 5,	--复活等待时间最大值（秒）
	nDeathSkillId = 1501,	--重伤状态

	nKillCountPerGodSkill = 5,	--击杀多少个npc提供一个无敌技能
	nPickCountPerHealSkill = 5,	--采集多少个npc提供一个回血技能

	tbGoldSkill = {2417, 2, 6, 0, 0},	--无敌技能
	tbHealSkill = {1529, 16, 320, 0, 0},	--回血技能

	nGodSkillInterval = 1,	--无敌技能使用间隔（秒）
	nHealSkillInterval = 1,	--回血技能使用间隔（秒）

	nEnterAreaCD =30,	--进入挑战区域CD

	--各种属性的boss分身名
	tbSeriesBossName = {
	    [1] = "完颜宗翰·金",
	    [2] = "完颜宗翰·木",
	    [3] = "完颜宗翰·水",
	    [4] = "完颜宗翰·火",
	    [5] = "完颜宗翰·土",
	},
}

function KinDefendMgr:CanOperate(pPlayer)
	if not Kin:CanControlFuben(pPlayer.dwID) then
		return false
	end
    return self:IsDefendMap(pPlayer.nMapTemplateId)
end

function KinDefendMgr:IsDefendMap(nMapTemplateId)
	return Lib:IsInArray(self.Def.tbMapTemplateId, nMapTemplateId)
end

function KinDefendMgr:GetDifficultyMapId(nDifficulty)
	return self.Def.tbMapTemplateId[nDifficulty]
end