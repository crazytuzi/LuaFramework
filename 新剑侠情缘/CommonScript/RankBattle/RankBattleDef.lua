--服务器判定时间，超过则出结果
RankBattle.BATTLE_TIME_OUT = 90;	-- 战斗超时

--竞技场地图
RankBattle.FIGHT_MAP = 1003

RankBattle.FIGHT_TYPE_NPC = 1
RankBattle.FIGHT_TYPE_PLAYER = 2

--战斗时锁定视角的点
RankBattle.ENTER_POINT = {1900, 2450}
RankBattle.CAMERA_PARAM =
{
	16.7, 34.87, 48.5,
	40, 90, 0
}

--默认排名
RankBattle.DEF_NO = 2001
RankBattle.tbActDefNo =
{
	["OpenLevel39"] = 2001;
	["OpenLevel69"] = 1521;
	["OpenLevel89"] = 1021;
	["OpenLevel99"] = 901;
	["OpenLevel109"] = 781;
	["OpenLevel119"] = 721;
	["OpenLevel129"] = 601;
	["OpenLevel139"] = 521;
}
RankBattle.DEF_ROOM_NO = 95
RankBattle.tbActRoomNo =
{
	["OpenLevel39"] = 95;
	["OpenLevel69"] = 89;
	["OpenLevel89"] = 82;
	["OpenLevel99"] = 80;
	["OpenLevel109"] = 78;
	["OpenLevel119"] = 77;
	["OpenLevel129"] = 75;
	["OpenLevel139"] = 73;
}
RankBattle.DEF_TIMER_AWARD = 500		-- 默认时间奖励

--购买次数价格
RankBattle.BUY_TIMES_COST =	100

--刷新对手时间间隔
RankBattle.FRESH_CD_TIME = 	5

--每次刷新对手消耗元宝
RankBattle.REFRESH_GOLD = 20

--战斗持续时间，时间到则攻方负
RankBattle.BATTLE_TIME = 60		-- 战斗时间

RankBattle.STATUE_ID = 1		-- 雕像ID

RankBattle.NPC_AI = "Setting/Npc/Ai/RankBattle.ini";

RankBattle.tbAWARD_TIME = {22} -- 奖励时间，这里仅仅是UI判断发奖时间，实际时间在ScheduleTask

-- 单场奖励货币
RankBattle.BATTLE_AWARD_TYPE =  "Honor"
RankBattle.WIN_AWARD = 12;
RankBattle.LOST_AWARD = 8;

--RankBattle.GOLD_BOX_ID = 2178				-- 黄金宝箱ID
--RankBattle.SLV_BOX_ID = 2179				-- 白银宝箱ID
RankBattle.AWARD_ITEM =
{
	{"OpenLevel39", 2178, 2179},			--3级家具
	{"OpenLevel79", 4465, 4466},			--不产家具
	{"OpenDay99", 2178, 2179},				--3级家具
	{"OpenLevel99", 4465, 4466},			--不产家具
	{"OpenDay224", 4591, 4592},				--4级家具
	{"OpenLevel119", 4465, 4466},			--不产家具
	{"OpenDay399", 4593, 4594},				--5级家具
}

RankBattle.GOLD_BOX_VALUE = 1000		-- 黄金宝箱兑换价值
RankBattle.SLV_BOX_VALUE = 500			-- 白银宝箱兑换价值
RankBattle.GOLD_BOX_REQUIRE_NO = 100	-- 黄金宝箱兑换排名要求

-- 定时奖励货币类型
RankBattle.TIME_AWARD_TYPE = "BasicExp";	-- 基准经验



RankBattle.AWARD_ASYNC_VALUE = 43;

RankBattle.tbNPC_POS =
{
	{	-- 我方点
		{2600, 2758,},
		{2038, 2778,},
		{1500, 2765,},
		{2600, 3087,},
		{2047, 3078,},
		{1500, 3052,},

	},
	{	-- 敌方点
		{1500, 1556,},
		{2020, 1547,},
		{2600, 1552,},
		{1500, 1225,},
		{2047, 1225,},
		{2600, 1225,},
	}
}

--优先攻击目标
RankBattle.LOCK_TARGET =
{
	{3, 6, 2, 5, 1, 4},	-- 1号位
	{2, 5, 3, 6, 1, 4},	-- 2号位
	{1, 4, 2, 5, 3, 6},	-- 3号位
	{3, 6, 2, 5, 1, 4},	-- 4号位
	{2, 5, 3, 6, 1, 4},	-- 5号位
	{1, 4, 2, 5, 3, 6},	-- 6号位
}

RankBattle.NO_LIMIT_RANK = 5;

RankBattle.SAVE_GROUP = 91
RankBattle.nBestRankSaveIdx = 1
RankBattle.nRankActVersionSaveIdx = 3
RankBattle.nRankActBestRank = 4
RankBattle.nSendQualifiFlag = 5
RankBattle.nRankActBestRankVersion = 6

RankBattle.RANK_AWARD_SAVE_GROUP = 189
RankBattle.MAX_SAVE_RANK_AWARD = 250
RankBattle.tbActRankAward =
{
--10446	称号·星移斗转（30天）
--10288	小金猪

	[1] = {
			nLowRank = 1,
			nHighRank = 1,
			tbAward = {
				-- 时间轴从小到大，且得有保底最小时间轴
				{"OpenLevel39", {{"item", 10446, 1},{"item", 10288, 1},{"Contrib", 15000}}};
				{"OpenLevel109", {{"item", 10446, 1},{"item", 10288, 1},{"item", 2804, 30,0,true}}};
			},
		};
	[2] = {
			nLowRank = 2,
			nHighRank = 3,
			tbAward = {
				{"OpenLevel39", {{"item", 10447, 1},{"Contrib", 10000}}};
				{"OpenLevel109", {{"item", 10447, 1},{"item", 2804, 20,0,true}}};
			},
		};
	[3] = {
			nLowRank = 4,
			nHighRank = 10,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 5000}}};
				{"OpenLevel109", {{"item", 2804, 10,0,true}}};
			},
		};
	[4] = {
			nLowRank = 11,
			nHighRank = 30,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 4000}}};
				{"OpenLevel109", {{"Contrib", 5000}}};
			},
		};
	[5] = {
			nLowRank = 31,
			nHighRank = 50,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 3000}}};
			},
		};
	[6] = {
			nLowRank = 51,
			nHighRank = 100,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 2000}}};
			},
		};
	[7] = {
			nLowRank = 101,
			nHighRank = 200,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 1500}}};
			},
		};
	[8] = {
			nLowRank = 201,
			nHighRank = 300,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 1000}}};
			},
		};
	[9] = {
			nLowRank = 301,
			nHighRank = 400,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 1000}}};
			},
		};
	[10] = {
			nLowRank = 401,
			nHighRank = 500,
			tbAward = {
				{"OpenLevel39", {{"Contrib", 500}}};
			},
		};
}

RankBattle.tbActMsg =
{
	{"OpenLevel39", {szContent =
	[[
		[FFFE0D]武神殿重置了！[-]
		星移斗转，钧天七曜，为了让诸位大侠尽情体验各大门派武功，特重置武神殿。
		重置后，首次达到或超过如下名次可以额外获得如下奖励。
		第[FFFE0D]1[-]名    [FF578C][url=openwnd:称号·星移斗转, ItemTips, "Item", nil, 10446][-]，[11ADF6][url=openwnd:小金猪, ItemTips, "Item", nil, 10288][-]，贡献：15000
		第[FFFE0D]3[-]名    [AA62FC][url=openwnd:称号·钧天七曜, ItemTips, "Item", nil, 10447][-]，贡献：10000
		第[FFFE0D]10[-]名   贡献：5000
		第[FFFE0D]30[-]名   贡献：4000
		第[FFFE0D]50[-]名   贡献：3000
		第[FFFE0D]100[-]名  贡献：2000
		第[FFFE0D]200[-]名  贡献：1500
		第[FFFE0D]300[-]名  贡献：1000
		第[FFFE0D]400[-]名  贡献：1000
		第[FFFE0D]500[-]名  贡献：500
	]]
	}};
	{"OpenLevel109", {szContent =
	[[
		[FFFE0D]武神殿重置了！[-]
		星移斗转，钧天七曜，为了让诸位大侠尽情体验各大门派武功，特重置武神殿。
		重置后，首次达到或超过如下名次可以额外获得如下奖励。
		第[FFFE0D]1[-]名   	[FF578C][url=openwnd:称号·星移斗转, ItemTips, "Item", nil, 10446][-]，[11ADF6][url=openwnd:小金猪, ItemTips, "Item", nil, 10288][-]，[FF8F06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]*30
		第[FFFE0D]3[-]名   	[AA62FC][url=openwnd:称号·钧天七曜, ItemTips, "Item", nil, 10447][-]，[FF8F06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]*20
		第[FFFE0D]10[-]名  	[FF8F06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]*10
		第[FFFE0D]30[-]名  	贡献：5000
		第[FFFE0D]50[-]名  	贡献：3000
		第[FFFE0D]100[-]名  贡献：2000
		第[FFFE0D]200[-]名  贡献：1500
		第[FFFE0D]300[-]名  贡献：1000
		第[FFFE0D]400[-]名  贡献：1000
		第[FFFE0D]500[-]名  贡献：500
	]]
	}};
}

function RankBattle:GetDefNo()
	local nDefNo = self.nActDefNo
	if MODULE_GAMESERVER then
		local szTimeFrame = RankBattle:GetActTimeFrame()
    	nDefNo = RankBattle.tbActDefNo[szTimeFrame]
    end
    return nDefNo or RankBattle.DEF_NO
end
