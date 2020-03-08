--常驻活动不挂在Activity下了

FriendRecall.Def = {
	MAIN_ICON_SHOW_TIME = {Lib:ParseDateTime("2017-03-01 00:00:00"), Lib:ParseDateTime("2017-03-28 23:59:59")},
	BEGIN_DATE = 1, --(暂时没用)每月回归开始日期，这个时间段内符合离线标准的玩家回归了才有效
	END_DATE = 31, --每月回归结束日期
	LAST_ONLINE_TIME_LIMIT = 15 * 24 * 60 * 60, --离线多久算老玩家
	AWARD_TIME = 30 * 24 * 60 * 60,		 --福利持续多久
	MAX_RENOWN_WEEKLY = 10000, 	--每周获取名望上限
	MAX_RENOWN_COUNT_WEEKLY = 3,	--每个活动每周最多可以获得几次回归玩家的额外名望奖励
	RENOWN_FRESH_TIME = 4 * 3600; 	--4点刷新累计上限
	MAX_AWARD_PLAYER_COUNT = 100, 	--老玩家召回福利列表上限
	MAX_SHOW_CAN_RECALL_COUNT = 10, --最多显示多少名可召回玩家(按亲密度排序)
	IMITY_LEVEL_LIMIT = 10, 			--好友亲密度等级限制
	RESH_LIST_INTERVAL = 10, 		--列表刷新请求间隔
	IMITY_BONUS = 2,				--亲密度加成100%
	MAX_RECALLED_COUNT  = 5,		--召回次数
	TEAM_BUFF_TIME = 3*24*3600,		--组队buff时间
	TEAM_BUFF_ID = 2317,			--组队buff ID
	RENOWN_VALUE = 				--名望奖励
	{
		["TeamFuben"] = 100,	--组队秘境
		["RandomFuben"] = 100,	--凌绝峰
		["AdventureFuben"] = 100,	--山贼秘窟
		["PunishTask"] = 40,		--惩恶
		["TeamBattle"] = 500,		--通天塔
		["InDifferBattle"] = 500,	--心魔幻境
	},
--------------------------以上为策划配置项--------------------------
	SAVE_GROUP = 61,
	ACTIVITY_VERSION = 101, --版本信息
	RECALL = 102, --是否是召回的老玩家
	AWARD_END_TIME = 103, --福利结束时间
	GET_RENOWN = 104, --累计获取的名望
	RESET_RENOWN_WEEK = 105,--重置名望累计周
	HAVE_RECALL_PLAYER = 106,--有过可召回玩家标记
	TEAM_BATTLE_RENOWN = 107,--每周获取通天塔名望奖励次数
	PUNISH_TASK_RENOWN = 108,--每周获取惩恶名望奖励次数
	TEAM_FUBEN_RENOWN = 109,--每周获取组队秘境名望奖励次数
	RANDOM_FUBEN_RENOWN = 110,--每周获取凌绝峰名望奖励次数
	ADVENTURE_FUBEN_RENOWN = 111,--每周获取山贼秘窟名望奖励次数
	INDIFFER_BATTLE_RENOWN = 112,--每周获取心魔幻境名望奖励次数
}

FriendRecall.Def.RENOWN_SAVE_MAP = 
{
	["TeamFuben"] = FriendRecall.Def.TEAM_FUBEN_RENOWN,
	["RandomFuben"] = FriendRecall.Def.RANDOM_FUBEN_RENOWN,
	["AdventureFuben"] = FriendRecall.Def.ADVENTURE_FUBEN_RENOWN,
	["PunishTask"] = FriendRecall.Def.PUNISH_TASK_RENOWN,
	["TeamBattle"] = FriendRecall.Def.TEAM_BATTLE_RENOWN,
	["InDifferBattle"] = FriendRecall.Def.INDIFFER_BATTLE_RENOWN,
}

FriendRecall.RecallType = 
{
	TEACHER = 1,
	STUDENT = 2,
	FIREND = 3,
	KIN = 4,	
}

FriendRecall.AwardInfo = 
{
	szTitle = [[许久不见，如今安好？
   往日征战江湖的伙伴，是否渐行渐远，如今功成名就，是否想与他们同享喜悦？若有此心，不若行动，通过QQ和微信找到他们，一同再战江湖！]],

   	szDesc = [[
规则&奖励说明
  1、召回次数仅有5次，一旦发送即消耗次数，请谨慎选择
  2、与被召回侠士完成[FFFE0D]组队秘境、凌绝峰、山贼秘窟、惩恶任务、心魔幻境、通天塔[-]时将获得名望，每个活动每周最多3次
  3、与召回玩家组队时将获得属性加成的增益状态（跨服无效）
  4、与召回玩家提升亲密度时将获得100%加成]],

     	tbAward = {{3640, 1}, {3641, 1}, {3642, 1}},
}

FriendRecall.RecalledAwardInfo = 
{
	szTitle = [[侠士重回江湖，实在可喜可贺！如今江湖风云变动，武林福利不减，少侠还需多提升等级，早日重新融入江湖。]],

   	szDesc = [[
规则&奖励说明
     1、侠士只需从好友列表中寻找符合条件的人一起组队，均可享受「重聚江湖」状态
     2、55级以上的侠士可以通过主界面的回归福利按钮领取老玩家回归的奖励
     3、与召回玩家组队时将获得属性加成的增益状态（跨服无效）
     4、与召回玩家提升亲密度时将获得100%加成]],

     	tbAward = {{3640, 1}, {3641, 1}, {3643, 1}},
}

FriendRecall.RecallDesc = 
{
	[FriendRecall.RecallType.TEACHER] = 
	{
		szTitle = "师徒再聚，情缘再续",
		szDesc = "徒儿，许久未见，为师甚是挂念，可要一同再闯江湖？",
	},
	[FriendRecall.RecallType.STUDENT] = 
	{
		szTitle = "一日为师，一世为师",
		szDesc = "师父，十大门派有趣得紧，你何时再带徒儿闯荡江湖？",
	},
	[FriendRecall.RecallType.FIREND] = 
	{
		szTitle = "酒仍暖，人未远",
		szDesc = "好兄弟！话不在多，回来我们再一块大口喝酒，大块吃肉！",
	},
	[FriendRecall.RecallType.KIN] = 
	{
		szTitle = "有你之处，才是江湖",
		szDesc = "如今江湖风云变幻，群豪争霸，正是你回来大展身手之时！",
	},
}

--主界面是否显示图标入口
function FriendRecall:IsInShowMainIcon()
	local nNow = GetTime()
	local nBegin = self.Def.MAIN_ICON_SHOW_TIME[1];
	local nEnd = self.Def.MAIN_ICON_SHOW_TIME[2];

	if not nBegin or not nEnd then
		return false
	end

	return nBegin <= nNow and nNow <= nEnd;
end

function FriendRecall:IsInProcess()
	local nDate = Lib:GetMonthDay()
	return self.Def.BEGIN_DATE <= nDate and nDate <= self.Def.END_DATE;
end

function FriendRecall:IsRecallPlayer(pPlayer)
	return pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.RECALL) == 1;
end

function FriendRecall:IsHaveRecallAward(pPlayer)
	local nEndTime = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.AWARD_END_TIME);
	return nEndTime > 0 and nEndTime > GetTime();
end
