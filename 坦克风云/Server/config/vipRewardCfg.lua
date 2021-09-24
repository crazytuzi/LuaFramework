--
-- vip vip等级购买礼包
-- User: luoning
-- Date: 15-3-16
-- Time: 下午2:55
--
local vipRewardCfg={
    {id=1,vip=0,sortID=1,price=0,realPrice=40,reward={p={{p849=1,index=1}}},serverReward={props_p849=1},contect={p={{p19=5,index=1},}}},
    {id=2,vip=1,sortID=3,price=0,realPrice=268,reward={p={{p850=1,index=1}}},serverReward={props_p850=1},contect={p={{p601=20,index=1},{p20=1,index=2},{p19=10,index=3},}}},
    {id=3,vip=2,sortID=5,price=0,realPrice=564,reward={p={{p851=1,index=1}}},serverReward={props_p851=1},contect={p={{p447=20,index=1},{p20=3,index=2},{p19=10,index=3},}}},
    {id=4,vip=3,sortID=7,price=0,realPrice=2180,reward={p={{p852=1,index=1}}},serverReward={props_p852=1},contect={h={{s25=20,index=1},},p={{p20=5,index=2},{p19=10,index=3},}}},
    {id=5,vip=4,sortID=9,price=0,realPrice=2260,reward={p={{p853=1,index=1}}},serverReward={props_p853=1},contect={h={{s25=20,index=1},},p={{p20=5,index=2},{p19=20,index=3},}}},
    {id=6,vip=5,sortID=11,price=0,realPrice=3380,reward={p={{p854=1,index=1}}},serverReward={props_p854=1},contect={h={{s25=30,index=1},},p={{p20=10,index=2},{p19=20,index=3},}}},
    {id=7,vip=6,sortID=13,price=0,realPrice=3460,reward={p={{p855=1,index=1}}},serverReward={props_p855=1},contect={h={{s25=30,index=1},},p={{p20=10,index=2},{p19=30,index=3},}}},
    {id=8,vip=7,sortID=15,price=0,realPrice=5500,reward={p={{p856=1,index=1}}},serverReward={props_p856=1},contect={h={{s25=50,index=1},},p={{p20=10,index=2},{p19=40,index=3},}}},
    {id=9,vip=8,sortID=17,price=0,realPrice=5860,reward={p={{p857=1,index=1}}},serverReward={props_p857=1},contect={h={{s25=50,index=1},},p={{p20=20,index=2},{p19=50,index=3},}}},
    {id=10,vip=9,sortID=19,price=0,realPrice=6100,reward={p={{p858=1,index=1}}},serverReward={props_p858=1},contect={h={{s25=50,index=1},},p={{p20=20,index=2},{p19=80,index=3},}}},
    {id=11,vip=10,sortID=21,price=0,realPrice=6540,reward={p={{p859=1,index=1}}},serverReward={props_p859=1},contect={h={{s25=50,index=1},},p={{p20=30,index=2},{p19=100,index=3},}}},
    {id=12,vip=0,sortID=2,price=10,realPrice=28,reward={p={{p838=1,index=1}}},serverReward={props_p838=1},contect={p={{p20=1,index=1},}}},
    {id=13,vip=1,sortID=4,price=20,realPrice=58,reward={p={{p839=1,index=1}}},serverReward={props_p839=1},contect={p={{p47=2,index=1},{p14=1,index=2},}}},
    {id=14,vip=2,sortID=6,price=50,realPrice=140,reward={p={{p840=1,index=1}}},serverReward={props_p840=1},contect={p={{p15=2,index=1},{p20=3,index=2},}}},
    {id=15,vip=3,sortID=8,price=80,realPrice=232,reward={p={{p841=1,index=1}}},serverReward={props_p841=1},contect={p={{p12=2,index=1},{p11=2,index=2},{p601=10,index=3},}}},
    {id=16,vip=4,sortID=10,price=100,realPrice=316,reward={p={{p842=1,index=1}}},serverReward={props_p842=1},contect={p={{p89=1,index=1},{p13=2,index=2},{p446=20,index=3},}}},
    {id=17,vip=5,sortID=12,price=150,realPrice=458,reward={p={{p843=1,index=1}}},serverReward={props_p843=1},contect={p={{p621=20,index=1},{p18=1,index=2}},e={{p6=10,index=3}}}},
    {id=18,vip=6,sortID=14,price=200,realPrice=640,reward={p={{p844=1,index=1}}},serverReward={props_p844=1},contect={p={{p615=10,index=1},{p447=5,index=2},{p621=20,index=3},}}},
    {id=19,vip=7,sortID=16,price=500,realPrice=1360,reward={p={{p845=1,index=1}}},serverReward={props_p845=1},contect={p={{p90=1,index=1},{p631=10,index=2},{p616=10,index=3},}}},
    {id=20,vip=8,sortID=18,price=800,realPrice=2620,reward={p={{p846=1,index=1}}},serverReward={props_p846=1},contect={p={{p270=1,index=1},{p631=30,index=2},{p19=100,index=3},}}},
    {id=21,vip=9,sortID=20,price=1200,realPrice=3600,reward={p={{p847=1,index=1}}},serverReward={props_p847=1},contect={p={{p393=100,index=1},{p395=100,index=2},{p19=200,index=3},}}},
    {id=22,vip=10,sortID=22,price=1500,realPrice=4400,reward={p={{p848=1,index=1}}},serverReward={props_p848=1},contect={p={{p394=100,index=1},{p396=100,index=2},{p19=300,index=3},}}},
	{id=23,vip=11,sortID=23,price=0,realPrice=6800,reward={p={{p4677=1,index=1}}},serverReward={props_p4677=1},contect={h={{s102=50,index=1}},p={{p20=30,index=2},{p19=120,index=3}}}},
	{id=24,vip=12,sortID=25,price=0,realPrice=7240,reward={p={{p4678=1,index=1}}},serverReward={props_p4678=1},contect={h={{s102=50,index=1}},p={{p20=40,index=2},{p19=140,index=3}}}},
	{id=25,vip=13,sortID=27,price=0,realPrice=8400,reward={p={{p4679=1,index=1}}},serverReward={props_p4679=1},contect={h={{s102=60,index=1}},p={{p20=40,index=2},{p19=160,index=3}}}},
	{id=26,vip=14,sortID=29,price=0,realPrice=9840,reward={p={{p4680=1,index=1}}},serverReward={props_p4680=1},contect={h={{s102=70,index=1}},p={{p20=50,index=2},{p19=180,index=3}}}},
	{id=27,vip=15,sortID=31,price=0,realPrice=11000,reward={p={{p4681=1,index=1}}},serverReward={props_p4681=1},contect={h={{s102=80,index=1}},p={{p20=50,index=2},{p19=200,index=3}}}},
	{id=28,vip=11,sortID=24,price=1800,realPrice=6400,reward={p={{p4672=1,index=1}}},serverReward={props_p4672=1},contect={p={{p4852=40,index=1},{p4031=20,index=2},{p4037=100,index=3}}}},
	{id=29,vip=12,sortID=26,price=1900,realPrice=4934,reward={p={{p4673=1,index=1}}},serverReward={props_p4673=1},contect={p={{p482=1,index=1},{p4606=1,index=2},{p4038=150,index=3}}}},
	{id=30,vip=13,sortID=28,price=2500,realPrice=9400,reward={p={{p4674=1,index=1}}},serverReward={props_p4674=1},contect={p={{p4852=60,index=1},{p4031=30,index=2},{p4039=100,index=3}}}},
	{id=31,vip=14,sortID=30,price=1600,realPrice=4734,reward={p={{p4675=1,index=1}}},serverReward={props_p4675=1},contect={p={{p485=1,index=1},{p4606=1,index=2},{p4040=100,index=3}}}},
	{id=32,vip=15,sortID=32,price=4200,realPrice=16050,reward={p={{p4676=1,index=1}}},serverReward={props_p4676=1},contect={p={{p4851=1,index=1},{p4031=60,index=2},{p4041=100,index=3}}}},

}
return vipRewardCfg

