KinBattle.Foku = KinBattle.Foku or {};
local Foku = KinBattle.Foku;
----------------------------------------基础定义----------------------------------------

Foku.GROUP_A = 1;		 -- 精英赛场 1
Foku.GROUP_B = 2;		 -- 普通赛场 2

--同步客户端信息类型

Foku.MSG_TYPE_PRE = 0			--准备场数据同步
Foku.MSG_TYPE_FIGHT_INIT = 1;	--战斗场初始化
Foku.MSG_TYPE_SCORE = 2;		--战斗场分数更新
Foku.MSG_TYPE_END = 3;			--结束更新
Foku.MSG_TYPE_SKILL = 4;		--技能刷新
Foku.MSG_TYPE_DOWNTIME = 5;		--倒计时刷新
Foku.MSG_TYPE_SLZ_SKILL = 6;	--更新普通场的舍利子和技能书
Foku.MSG_TYPE_GROUP_A = 7;		--精英场信息
Foku.MSG_TYPE_APPLY = 8;		--叹号推送
Foku.MSG_TYPE_BASEMSG = 9;		--活动基本信息
Foku.MSG_TYPE_KINDATA = 10;		--家族参战信息

Foku.KIN_DOWN_TIME = 20;		--倒计时长;
Foku.GAME_TOTAL_TIME = 20 * 60	--活动总时长20分钟
Foku.KIN_MAX_SCORE = 10000;		--获胜积分;
Foku.nNPC_SLZ = 3734;
Foku.SLZ_2_SKILL = 8;			--普通场8个舍利子 换一个技能道具。
Foku.MAP_PREPARE_TIME = 300;		--准备场准备时间;

Foku.tbSkills = {{5451,10,1},{5452,10,1},{5453,20,10},{5454,30,10},{5455,5,1}};

Foku.nPreMapTD_A = 6202;
Foku.nPreMapTD_B = 6203;
Foku.nFightMapTID_A = 6204;
Foku.nFightMapTID_B = 6205;

Foku.TIP_TYPE_DOWNTIME1 = 1;
Foku.TIP_TYPE_DOWNTIME2 = 2;
Foku.TIP_TYPE_SLZ 		= 3;
Foku.TIP_TYPE_FLAG_ATTACK = 4;
Foku.TIP_TYPE_FLAG_DEATH = 5;
Foku.TIP_TYPE_ME_DEATH = 6;
Foku.TIP_TYPE_FLAG_OCCUPY = 7;

Foku.tbMAP_UI = 
{
	[Foku.nPreMapTD_A] = {"QYHLeftInfo","QYHLeavePanel"},
	[Foku.nPreMapTD_B] = {"QYHLeftInfo","QYHLeavePanel"},
	[Foku.nFightMapTID_A] = {"FKBattleInfoA"},
	[Foku.nFightMapTID_B] = {"FKBattleInfoB"},
}


--复活旗
Foku.nNPC_Flag = 3733;				--复活旗子ID;
Foku.tbFlag_Pos = 				--旗子坐标
{
	{4399, 8532},
	{4432, 5537},
	{9632, 5342},
	{9615, 8476},
	{6900, 10315},
	{6762, 3634},
}

Foku.tbFlag_Revive = 				--旗子对应复活坐标（必须一一对应）
{
	{4152, 8770,"龙飞旗",1},
	{4179, 5219,"虎翼旗",2},
	{9849, 5077,"鸟翔旗",3},
	{9894, 8818,"蛇蟠旗",4},
	{6977, 10678,"天覆旗",5},
	{6773, 3259,"地载旗",6},
}

Foku.szMainPanel_DescribeTxt = [[
[FFFE0D]介绍：[-]
·龙门之争分为[FFFE0D]精英赛场[-]和[FFFE0D]普通赛场[-]，是一个与其他服务器同水平的家族热血对战的活动。
·活动期间每天[FFFE0D]19:55[-]开始报名，[FFFE0D]20:00[-]活动正式开始。
·[FFFE0D]精英赛场[-]最多同时进入[FFFE0D]3支[-]队伍，且需经[FFFE0D]家族领袖/族长/副族长/指挥[-]同意。[FFFE0D]精英赛场[-]中玩家采集并持有地图中刷新的[FFFE0D]天龙珠[-]可为己方提供积分，处于越靠近地图的中心位置获得的积分越高，玩家死亡会掉落[FFFE0D]天龙珠[-]并扣除积分。少侠的目标是不惜一切代价提高自己家族积分然后获得胜利！
·[FFFE0D]普通赛场[-]允许任何家族成员进入。[FFFE0D]普通赛场[-]中玩家需收集[FFFE0D]天龙珠[-]，为[FFFE0D]精英赛场[-]中本家族成员提供[FFFE0D]不溃、复苏、潜行、疾行、无敌[-]等强力技能。
]];



function Foku:GetUrlFlagName(nIdx)
	local tbTmp = Foku.tbFlag_Revive[nIdx];
	local szUrl = string.format("[FFFE0D][url=npc:%s, %d, %d][-]",tbTmp[3],tbTmp[1],tbTmp[2]) or "1";
	return szUrl;
end

function Foku:ChangeGameState(nGameState)
	Log("[INFO]","Foku","ChangeGameState",self.nGameState,"->",nGameState);
	self.nGameState = nGameState;
end

function Foku:SyncMsg(nPlayerId,tbInfo)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then return end;
	pPlayer.CallClientScript("KinBattle.Foku:SyncMsgClient",tbInfo);
end

