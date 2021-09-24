 --军功商店
 --pShop是普通坦克商店
 --aShop是活动坦克商店
 --buynum全服购买限制price军功币消耗rank军衔限制
local shop={
 -- 商店刷新时间
reftime={12,18},
pShopItems=
{
    i1={id="i1",rank=5,buynum=200,price=20000,reward={o={{a10004=2}}},serverReward={troops_a10004=2}},
    i2={id="i2",rank=6,buynum=200,price=20000,reward={o={{a10014=2}}},serverReward={troops_a10014=2}},
    i3={id="i3",rank=7,buynum=200,price=20000,reward={o={{a10024=2}}},serverReward={troops_a10024=2}},
    i4={id="i4",rank=8,buynum=200,price=40000,reward={o={{a10034=2}}},serverReward={troops_a10034=2}},
    i5={id="i5",rank=9,buynum=100,price=60000,reward={o={{a10005=2}}},serverReward={troops_a10005=2}},
    i6={id="i6",rank=10,buynum=100,price=80000,reward={o={{a10015=2}}},serverReward={troops_a10015=2}},
    i7={id="i7",rank=11,buynum=100,price=80000,reward={o={{a10025=2}}},serverReward={troops_a10025=2}},
    i8={id="i8",rank=11,buynum=100,price=100000,reward={o={{a10035=2}}},serverReward={troops_a10035=2}},
    i9={id="i9",rank=11,buynum=50,price=140000,reward={o={{a10006=2}}},serverReward={troops_a10006=2}},
    i10={id="i10",rank=11,buynum=50,price=160000,reward={o={{a10016=2}}},serverReward={troops_a10016=2}},
    i11={id="i11",rank=11,buynum=50,price=180000,reward={o={{a10026=2}}},serverReward={troops_a10026=2}},
    i12={id="i12",rank=11,buynum=50,price=180000,reward={o={{a10036=2}}},serverReward={troops_a10036=2}},
    i13={id="i13",rank=11,buynum=20,price=200000,reward={o={{a10007=2}}},serverReward={troops_a10007=2}},
    i14={id="i14",rank=11,buynum=20,price=200000,reward={o={{a10017=2}}},serverReward={troops_a10017=2}},
    i15={id="i15",rank=11,buynum=20,price=220000,reward={o={{a10027=2}}},serverReward={troops_a10027=2}},
    i16={id="i16",rank=11,buynum=20,price=240000,reward={o={{a10037=2}}},serverReward={troops_a10037=2}},
},
aShopItems=
{
    a1={id="a1",rank=7,buynum=20,price=60000,reward={o={{a10043=1}}},serverReward={troops_a10043=1}},
    a2={id="a2",rank=7,buynum=20,price=60000,reward={o={{a10053=1}}},serverReward={troops_a10053=1}},
    a3={id="a3",rank=7,buynum=20,price=60000,reward={o={{a10063=1}}},serverReward={troops_a10063=1}},
    a4={id="a4",rank=7,buynum=20,price=60000,reward={o={{a10073=1}}},serverReward={troops_a10073=1}},
    a5={id="a5",rank=7,buynum=20,price=60000,reward={o={{a10082=1}}},serverReward={troops_a10082=1}},
    a6={id="a6",rank=7,buynum=20,price=50000,reward={o={{a10093=1}}},serverReward={troops_a10093=1}},
    a7={id="a7",rank=7,buynum=20,price=60000,reward={o={{a10113=1}}},serverReward={troops_a10113=1}},
    a8={id="a8",rank=7,buynum=20,price=60000,reward={o={{a10123=1}}},serverReward={troops_a10123=1}},
    a9={id="a9",rank=9,buynum=5,price=70000,reward={o={{a10044=1}}},serverReward={troops_a10044=1}},
    a10={id="a10",rank=9,buynum=5,price=70000,reward={o={{a10054=1}}},serverReward={troops_a10054=1}},
    a11={id="a11",rank=9,buynum=5,price=70000,reward={o={{a10064=1}}},serverReward={troops_a10064=1}},
    a12={id="a12",rank=9,buynum=5,price=70000,reward={o={{a10074=1}}},serverReward={troops_a10074=1}},
},
--开放时间 0 就是周日
opentime={6,0},
}
return shop