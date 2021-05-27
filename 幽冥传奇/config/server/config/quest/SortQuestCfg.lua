
QuestStateList =
{
	Accept = 0,
	NotComplete = 1,
	Submit = 2,
	Unacceptable = 3,
	Complete = 4,
	CanBuy = 5,
	CanFind = 6,
}
QuestType =
{
	qtMain = 0,
	qtSub1 = 1,
	qtFuben = 2,
	qtDay = 3,
	qtGuild = 4,
	qtChallenge = 5,
	qtRnd = 6,
	qtRecommended = 7,
	qtZyQuest = 8,
	qtEquip = 9,
	qtExp = 10,
	qtCoin = 11,
	qtBook = 12,
	qtRich = 13,
	qtSpecial = 14,
	qtSub2 = 15,
	qtMaxQuestType =16,
}
Normal_QuestWeight =
{
	[0] = 10,
	[3] = 20,
	[1] = 30,
    [15] = 40,
	[2] = 50,
	[4] = 60,
	[5] = 70,
	[6] = 80,
	[7] = 90,
	[8] = 100,
	[9] = 110,
	[10] = 120,
	[11] = 130,
	[12] = 140,
	[13] = 150,
	[14] = 160,
}
Special_QuestWeight =
{
	[53] =
	{
		{weight=11, chokeLev=52,},
	},
	[62] =
	{
		{weight=11, chokeLev=61,},
	},
	[75] =
	{
		{weight=11, chokeLev=70,},
	},
	[79] =
	{
		{weight=11, chokeLev=72,},
	},
	[82] =
	{
		{weight=11, chokeLev=74,},
	},
	[85] =
	{
		{weight=11, chokeLev=76,},
	},
	[89] =
	{
		{weight=11, chokeLev=78,},
	},
	[91] =
	{
		{weight=11, chokeLev=80,},
	},
	[94] =
	{
		{weight=11, chokeLev=81,},
	},
	[98] =
	{
		{weight=11, chokeLev=82,},
	},
	[102] =
	{
		{weight=11, chokeLev=83,},
	},
	[106] =
	{
		{weight=11, chokeLev=84,},
	},
	[110] =
	{
		{weight=11, chokeLev=85,},
	},
	[4000] =
	{
		{weight=-9, minUseTms=1,},
		{weight=32, minbuyTms=1,},
		{weight=32, minFindTms=1,},
	},
	[4001] = {
	    {weight=-3, refer={Qid =4000, State =5,},},
		{weight=2, minUseTms=1,minFindTms=1},
		{weight=2, minUseTms=1,},
	},
	[4002] = {
	    {weight=-1, refer={Qid =4003, State =4,},minFindTms=1},
		{weight=4, minUseTms=1,},
	},
	[4003] = {
	    {weight=-2, refer={Qid =4001, State =4,},minUseTms=1},
		{weight=3, minUseTms=1,},
	},
	[4004] = {
		{weight=25, effect=1},
    },
	[4005] = {
	    {weight=2, refer={Qid =4002, State =4,},minUseTms=1},
		{weight=24, effect=1},
    },
     [4006] = {
    	{weight=27, effect=1},
    },
	[4007] = {
		{weight=26, effect=1},
    },
	[4008] = {
		{weight=35, effect=1},
    },
	[4009] = {
		{weight=38, effect=1},
    },
	[4010] = {
           {weight=27, effect=1},
	},
	[4011] = {
           {weight=28, effect=1},
	},
	[3000] = {
           {weight=20, effect=1},
	},
	[3001] = {
           {weight=20, effect=1},
	},
	[3002] = {
           {weight=20, effect=1},
	},
	[3003] = {
           {weight=20, effect=1},
	},
	[3004] = {
           {weight=20, effect=1},
	},
	[3005] = {
           {weight=20, effect=1},
	},
	[3006] = {
           {weight=20, effect=1},
	},
	[3007] = {
           {weight=11, effect=1},
	},
	[3008] = {
           {weight=11, effect=1},
	},
	[3009] = {
           {weight=11, effect=1},
	},
	[3010] = {
           {weight=11, effect=1},
	},
	[3011] = {
           {weight=11, effect=1},
	},
	[3012] = {
           {weight=11, effect=1},
	},
	[3013] = {
           {weight=11, effect=1},
	},
	[3014] = {
           {weight=11, effect=1},
	},
	[3015] = {
           {weight=11, effect=1},
	},
}
