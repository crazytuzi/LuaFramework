Fuben.LingJueFengWeek = Fuben.LingJueFengWeek or {};
local LingJueFengWeek = Fuben.LingJueFengWeek;

LingJueFengWeek.emSTATE_IN_FUBEN = 1;
LingJueFengWeek.emSTATE_END_FUBEN = 2;
LingJueFengWeek.emSTATE_SELECT_FACTION = 3;


----------------------策划填写-----------------------
LingJueFengWeek.NLIMIT_LEVEL = 80;			--最小参与活动等级
LingJueFengWeek.NLIMIT_MEMBERS = 3;			--活动队伍人数
LingJueFengWeek.TOTAL_LEVEL = 7;			--活动总通关数目
LingJueFengWeek.NLIMIT_FAILED_TIME = 2;		--每日允许失败次数
LingJueFengWeek.COUNTDOWN_TIME = 20;		--确认框倒计时
LingJueFengWeek.STAY_FUBEN_TIME = 60;		--结束停留副本时长
LingJueFengWeek.RANDOM_FACTION_TIME = 60;	--随机门派时间
LingJueFengWeek.CLEAR_MAP_TIME = 180;		--清空地图时间
LingJueFengWeek.LIFE_NUMS = 3;				--单关可用复活次数;
LingJueFengWeek.NFUBEN_LEVEL = 3;			--副本基准难度值;
LingJueFengWeek.COST_LEVEL = 4;				--副本消费复活基本等级;
--变身强度
LingJueFengWeek.tbDefaultAvatar = 
{
	nLevel = 130,
	szEquipKey = "ZhaoQin89",
	szInsetKey = "ZhaoQin89",
	nStrengthLevel = 80,
	tbBookType = {9,10,11,12}
}


LingJueFengWeek.szOpenMailTitle = "决战凌绝峰开启";
LingJueFengWeek.szOpenMailContent = "[FFFE0D]天下英雄出我辈，一入江湖岁月催[-]。  \n[FFFE0D]决战领绝峰[-]活动已经开启，少侠需要组成[FFFE0D]3人战队[-]进行挑战，挑战共分[FFFE0D]7层[-]，每层挑战前可以自由选择[FFFE0D]相同强度的任意职业[-]，每通关一层可获得相应奖励，通关速度还将进入全服排行榜。  \n注：活动每周内[FFFE0D]不限次数进入[-]，每天失败上限为[FFFE0D]2[-]次，每周一刷新通关层数、战队和排行榜。";
LingJueFengWeek.szNoFightTeamTips = "凌绝峰险峻异常，请大侠先组建好战队再前来挑战";
LingJueFengWeek.szNoChanceTips = "凌绝峰过于凶险,不如养精蓄锐,明日再战！";
LingJueFengWeek.szTrySignUpTeamTips = "【决战凌绝峰】\n[FFFE0D]%s[-]邀请你组建战队[FFFE0D]【%s】[-]\n[FFFE0D](本周内,无法退出或更改战队)[-]\n(%%d秒后自动拒绝)";
LingJueFengWeek.szActKeyName = "决战凌绝峰"
-- --发奖
-- LingJueFengWeek.tbRankAward             = {
-- 									{1, 	{{"item", 10298, 1}}},	--1
-- 									{10, 	{{"item", 10299, 1}}},	--2-10
-- 								}
--每层发
LingJueFengWeek.tbLevelAward = {
	[1] = {{"item",224,1}, {"BasicExp", 30}},
	[2] = {{"item",224,2}, {"BasicExp", 40}},
	[3] = {{"item",224,3}, {"BasicExp", 40}},
	[4] = {{"Energy",10000}, {"BasicExp", 50}},
	[5] = {{"Energy",15000}, {"BasicExp", 50}},
	[6] = {{"item",10591,1}, {"BasicExp", 60}},
	[7] = {{"item",10592,1}, {"BasicExp", 70}},
}

LingJueFengWeek.tbAwardsId = {{"Item",1346},{"Energy",0},{"Item",224},{"Item",2804}};

LingJueFengWeek.szIntroducesTitle = "[FFFE0D]天下英雄出我辈，一入江湖岁月催[-]";
LingJueFengWeek.szIntroducesTxt = "  决战凌绝峰全天开放，每天有[FFFE0D]2次[-]失败机会\n  决战凌绝峰共分7层，少侠必须组建[FFFE0D]3人[-]战队进行战斗\n  玩家自由选择相同强度职业进行挑战，每登上一层可获得相应奖励\n  战队通关时间将进入排行榜进行展示，[FFFE0D]一周[-]重置一次\n[FFFE0D]注[-]：战队和通关层数每周重置一次，战队组建后不可解散或者换人\n";

LingJueFengWeek.nRedBagEventId = 243;

LingJueFengWeek.szPassRoomMailText = "恭喜少侠所在战队成功通关第%d层，武林盟特此奖励，祝少侠武运昌隆！";
LingJueFengWeek.szPassRoomMailTitle = "决战凌绝峰奖励";

LingJueFengWeek.szFactionDescription = "1、任意选择不重复职业\n2、中途退出挑战不计算失败次数\n3、挑战全程开启语音\n4、每个房间可以重新选择职业";

function LingJueFengWeek:GetValue(nLevel,nTime,nLost)
	local nValue = nLevel * 1000000 + (10000 - nTime) * 30 + (20 - nLost);
	return nValue;
end

function LingJueFengWeek:GetLevel(nValue)
	return math.floor(nValue / 1000000);
end

----------------------------------------------------


LingJueFengWeek.ASK_ENTER_FUBEN = 1;
LingJueFengWeek.ASK_SIGN_UP_TEAM = 2;

function LingJueFengWeek:GetTeamCaptainId(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then return end;

	local dwTeamID = pPlayer.dwTeamID;
	local tbTeam = TeamMgr:GetTeamById(dwTeamID)
	local nCaptainId = tbTeam:GetCaptainId();
	return nCaptainId;
end

function LingJueFengWeek:GetTeamMember(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then return end;
	local dwTeamID = pPlayer.dwTeamID;
	if dwTeamID == 0 or dwTeamID == nil then return end;
	local tbMember = TeamMgr:GetMembers(dwTeamID);
	return tbMember;
end

