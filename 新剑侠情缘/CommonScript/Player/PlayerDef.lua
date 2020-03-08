
Player.MODE_PEACE 	= 0; --和平
Player.MODE_PK 		= 1; -- PK
Player.MODE_KILLER 	= 2; --屠杀
Player.MODE_CUSTOM 	= 3; --自定义模式
Player.MODE_CAMP    = 4; --阵营模式
Player.MODE_EXCERCISE = 5; -- 切磋模式

Player.CHANGE_PEACE_CD = 60

Player.IMMEDIATE_SAVE_GOLD_LINE = 20000; -- 当元宝改变大于这个值时则立即存盘

Player.PK_EXCERCISE_DISTANCE = 1200		-- 切磋申请距离校验
Player.PK_EXCERCISE_READY 	= 1;
Player.PK_EXCERCISE_GO 		= 2;
Player.PK_EXCERCISE_END 	= 3;

Player.EXCERCISE_WIN_BUFF	= 1059;
Player.EXCERCISE_LOSE_BUFF	= 1060;

Player.QQ_VIPINFO_SAVEGROUP       = 86;
Player.QQ_VIPINFO_VIP_BEGIN       = 1;
Player.QQ_VIPINFO_VIP_END         = 2;
Player.QQ_VIPINFO_SVIP_BEGIN      = 3;
Player.QQ_VIPINFO_SVIP_END        = 4;

Player.TX_LAUNCH_SAVE_GROUP       = 86;
Player.TX_LAUNCH_PRIVILEGE_TYPE   = 5; -- 登入特权类型, qq or wx， 1 or 2
Player.TX_LAUNCH_PRIVILEGE_DAY = 6; -- 登入特权过期时间

Player.ONLINE_TIME_GROUP           = 86;
Player.ONLINE_YESTERDAY_DAY        = 11;
Player.ONLINE_YESTERDAY_ONLINETIME = 12;

Player.QQVIP_NONE = 0;
Player.QQVIP_VIP  = 1;
Player.QQVIP_SVIP = 2;
Player.QQVIP_VIP_AWARD_RATE = 0.1;
Player.QQVIP_SVIP_AWARD_RATE = 0.15;

--头衔等级
Player.tbHonorLevelSetting = LoadTabFile("Setting/Player/HonorLevel.tab", "sdddddssdssdddd", "Level",
                             {"Name", "Level", "MainLevel", "StarLevel", "FightLevel", "PowerValue", "ImgPrefix", "Atlas", "NeedPower", "TimeFrame", "RepairTimeFrame",
                             "NeedFubenStar", "ItemID", "ItemCount", "IsNotice"});


Player.tbHeadStateBuff =
{
    nAutoPathID = 1009;
    nAutoFightID = 1010;
    nFollowFightID = 1011;
    nWaBaoID = 1012;
    nItemDungeon = 1012;
};

Player.HEAD_STATE_TIME = 60 * 60 * 24;
Player.nFocusPetTime = 5; --秒

--欠款能力衰减
Player.DebtAttrDebuff =
{
	{nAmount = 10000, nLevel = 1},
	{nAmount = 30000, nLevel = 2},
}

--欠款战力衰减
Player.DebtFightPowerDebuff =
{
	--{nDuration = 持续时间(秒), nPercent = 战力衰减百分比},
	{nDuration = 3*24*60*60, nPercent = 5},
	{nDuration = 5*24*60*60, nPercent = 7},
	{nDuration = 7*24*60*60, nPercent = 10},
	{nDuration = 15*24*60*60, nPercent = 15},
	{nDuration = 20*24*60*60, nPercent = 20},
}
--欠款战力衰减buff 每级衰减多少
Player.DEBT_FIGHT_POWER_REDUCE_PER_LEVEL = 50000
--能力衰减达到几级时才开始计算战力衰减累计时间
Player.DEBT_FIGHT_POWER_NEED_LEVEL = 2

Player.SAVE_GROUP_LOGIN = 138;
Player.SAVE_KEY_LoginTime = 1; --登录事件最后设置的登录时间，之前可用于做上次登录时间

Player.PRISON_EXPIRE_SAVE_GROUP = 149;
Player.PRISON_EXPIRE_SAVE_KEY   = 1;
Player.PRISON_BUFF_ID           = 2325;

Player.SEX_NONE = 0;
Player.SEX_MALE = 1;
Player.SEX_FEMALE = 2;
Player.SEX_NAME = {
	[Player.SEX_NONE]	 = "中";
	[Player.SEX_MALE]	 = "男";
	[Player.SEX_FEMALE]	 = "女";
}

Player.tbBoyFaction =
{
	[7] = "少林",
	[9] = "唐门",
	[13] = "藏剑",
}

Player.tbGirlFaction =
{
	[2] = "峨嵋",
	[3] = "桃花",
	[8] = "翠烟",
	[12]= "五毒",
	[14]= "长歌",
}

--ui只显示一个性别的门派
Player.tbForceShowFaction =
{
	[Player.SEX_MALE] = {
		[7] = "少林",
	};
	[Player.SEX_FEMALE] = {
		[2] = "峨嵋",
		[3] = "桃花",
		[8] = "翠烟",
	};
};

Mail.AUTO_TAKE_TIME_INTERVAL = 24*3600*5;
Mail.MAX_SAVE_MAIL_COUNT = 400;
