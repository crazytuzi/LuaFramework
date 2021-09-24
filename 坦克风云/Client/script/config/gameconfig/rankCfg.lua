--新版军衔配置
rankCfg=
{
	--各个军衔的详细配置
	--id: 军衔ID
	--name: 军衔名称
	--icon: 军衔图标
	--lv: 获得该军衔需要达到的等级
	--honorAdd: 军衔的每日声望奖励
	--point: 达到军衔所需的战功
	--troops: 军衔提供的部队数加成
	--attAdd: 军衔提供的属性加成百分比,是一个table,第一个元素表示增加的攻击,第二个元素表示增加的血量
	--ranking: 前几个军衔除了有战功要求之外还有排名要求,ranking表示该军衔的排名范围,[100,80]表示排名在100~80名内属于此军衔
	--helpNum：援建次数
	--helpValue：援建效果
	rank=	
	{	
	{id=1,name="military_rank_1",icon="military_rank_1.png",lv=0,honorAdd=50,point=0,ranking={},troops=0,attAdd={0,0},helpNum=4,helpValue=30},
	{id=2,name="military_rank_2",icon="military_rank_2.png",lv=5,honorAdd=100,point=100,ranking={},troops=5,attAdd={0,0},helpNum=6,helpValue=40},
	{id=3,name="military_rank_3",icon="military_rank_3.png",lv=10,honorAdd=150,point=1000,ranking={},troops=10,attAdd={0,0},helpNum=8,helpValue=50},
	{id=4,name="military_rank_4",icon="military_rank_4.png",lv=15,honorAdd=200,point=5000,ranking={},troops=15,attAdd={0,0},helpNum=10,helpValue=60},
	{id=5,name="military_rank_5",icon="military_rank_5.png",lv=20,honorAdd=250,point=20000,ranking={},troops=20,attAdd={0,0},helpNum=12,helpValue=75},
	{id=6,name="military_rank_6",icon="military_rank_6.png",lv=25,honorAdd=300,point=60000,ranking={},troops=25,attAdd={0,0},helpNum=15,helpValue=90},
	{id=7,name="military_rank_7",icon="military_rank_7.png",lv=30,honorAdd=350,point=120000,ranking={},troops=30,attAdd={0,0},helpNum=18,helpValue=120},
	{id=8,name="military_rank_8",icon="military_rank_8.png",lv=35,honorAdd=400,point=250000,ranking={},troops=35,attAdd={0,0},helpNum=21,helpValue=150},
	{id=9,name="military_rank_9",icon="military_rank_9.png",lv=40,honorAdd=450,point=500000,ranking={},troops=40,attAdd={0,0},helpNum=24,helpValue=180},
	{id=10,name="military_rank_10",icon="military_rank_10.png",lv=45,honorAdd=500,point=1000000,ranking={},troops=45,attAdd={0,0},helpNum=27,helpValue=210},
	{id=11,name="military_rank_11",icon="military_rank_11.png",lv=50,honorAdd=550,point=2000000,ranking={},troops=50,attAdd={0,0},helpNum=30,helpValue=240},
	{id=12,name="military_rank_12",icon="military_rank_12.png",lv=50,honorAdd=575,point=2500000,ranking={61,100},troops=50,attAdd={0,0.05},helpNum=30,helpValue=250},
	{id=13,name="military_rank_13",icon="military_rank_13.png",lv=50,honorAdd=600,point=3000000,ranking={36,60},troops=50,attAdd={0,0.1},helpNum=30,helpValue=260},
	{id=14,name="military_rank_14",icon="military_rank_14.png",lv=50,honorAdd=625,point=3500000,ranking={21,35},troops=50,attAdd={0,0.15},helpNum=30,helpValue=270},
	{id=15,name="military_rank_15",icon="military_rank_15.png",lv=50,honorAdd=650,point=4000000,ranking={12,20},troops=50,attAdd={0,0.2},helpNum=30,helpValue=280},
	{id=16,name="military_rank_16",icon="military_rank_16.png",lv=50,honorAdd=675,point=4500000,ranking={7,11},troops=50,attAdd={0,0.25},helpNum=30,helpValue=290},
	{id=17,name="military_rank_17",icon="military_rank_17.png",lv=50,honorAdd=700,point=5000000,ranking={4,6},troops=50,attAdd={0.05,0.25},helpNum=30,helpValue=300},
	{id=18,name="military_rank_18",icon="military_rank_18.png",lv=50,honorAdd=725,point=5500000,ranking={3,3},troops=50,attAdd={0.1,0.25},helpNum=30,helpValue=320},
	{id=19,name="military_rank_19",icon="military_rank_19.png",lv=50,honorAdd=750,point=6000000,ranking={2,2},troops=50,attAdd={0.15,0.25},helpNum=30,helpValue=340},
	{id=20,name="military_rank_20",icon="military_rank_20.png",lv=50,honorAdd=800,point=7000000,ranking={1,1},troops=50,attAdd={0.25,0.25},helpNum=30,helpValue=360},




	},
	--每日的战功衰减比例
	pointDecrease=0.01,
	--排行榜的长度,后台用
	listLength=100,
	--每天几点刷排行榜, 第一个元素是时, 第二个元素是分
	refreshTime={3,0},
	--计算战功是否衰减的最小值	
	minPoint=2000000,
	--计算进前100名需要的最小战功
	minRankPoint=2500000,
	--没进前100但是战功到了军衔的值 ，但是军衔还是默认没有名次的那挡！
	minRank=11,
	--聊天是否显示军衔，军衔大于或等于此值都显示
	chatShowRank=12,
}