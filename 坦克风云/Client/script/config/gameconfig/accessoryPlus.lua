local accessoryPlus={
    --红配晋升(id--配件表红配的id，grade--晋升等级，needOwn--晋升需求自身红配片数量，needOther--晋升需求通用红配片数量，lvUp--晋升后提升强化等级（强化增长依旧保持红配原强化数值），rankUp--提升改造等级（改造对应属性读原配件lua）refineUp--提升精炼等级上限等级（对应属性读原配件精炼lua），attType--加成属性（1:attack 2:hp 3:armor 4:arp），attEffect--生效方式（1：百分比  2：固定值)，att--晋升获取的属性值，refineId--精炼库，strength--强度值（累加），cost--晋升消耗道具（前端），serverCost--晋升消耗道具（后端）PS所有提升等级均为在红配基础上的提升等级，具体提升等级只读取当前值加在红配版本上限即可）
    [1]={
        a129={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f4",lvUp=0,rankUp=1,attType={2},attEffect={1},att={18},refineId=1,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a130={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f8",lvUp=0,rankUp=1,attType={1},attEffect={1},att={18},refineId=2,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a131={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f12",lvUp=0,rankUp=1,attType={3},attEffect={2},att={10.8},refineId=3,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a132={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f16",lvUp=0,rankUp=1,attType={4},attEffect={2},att={10.8},refineId=4,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a133={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f68",lvUp=0,rankUp=1,attType={2,3},attEffect={1,2},att={10.8,6.48},refineId=5,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a134={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f72",lvUp=0,rankUp=1,attType={1,4},attEffect={1,2},att={10.8,6.48},refineId=6,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a135={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f100",lvUp=0,rankUp=1,attType={2,1},attEffect={1,1},att={10.8,10.8},refineId=7,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a136={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f104",lvUp=0,rankUp=1,attType={4,3},attEffect={2,2},att={6.48,6.48},refineId=8,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a137={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f20",lvUp=0,rankUp=1,attType={2},attEffect={1},att={18},refineId=9,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a138={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f24",lvUp=0,rankUp=1,attType={1},attEffect={1},att={18},refineId=10,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a139={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f28",lvUp=0,rankUp=1,attType={3},attEffect={2},att={10.8},refineId=11,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a140={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f32",lvUp=0,rankUp=1,attType={4},attEffect={2},att={10.8},refineId=12,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a141={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f76",lvUp=0,rankUp=1,attType={2,3},attEffect={1,2},att={10.8,6.48},refineId=13,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a142={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f80",lvUp=0,rankUp=1,attType={1,4},attEffect={1,2},att={10.8,6.48},refineId=14,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a143={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f108",lvUp=0,rankUp=1,attType={2,1},attEffect={1,1},att={10.8,10.8},refineId=15,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a144={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f112",lvUp=0,rankUp=1,attType={4,3},attEffect={2,2},att={6.48,6.48},refineId=16,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a145={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f36",lvUp=0,rankUp=1,attType={2},attEffect={1},att={18},refineId=17,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a146={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f40",lvUp=0,rankUp=1,attType={1},attEffect={1},att={18},refineId=18,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a147={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f44",lvUp=0,rankUp=1,attType={3},attEffect={2},att={10.8},refineId=19,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a148={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f48",lvUp=0,rankUp=1,attType={4},attEffect={2},att={10.8},refineId=20,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a149={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f84",lvUp=0,rankUp=1,attType={2,3},attEffect={1,2},att={10.8,6.48},refineId=21,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a150={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f88",lvUp=0,rankUp=1,attType={1,4},attEffect={1,2},att={10.8,6.48},refineId=22,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a151={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f116",lvUp=0,rankUp=1,attType={2,1},attEffect={1,1},att={10.8,10.8},refineId=23,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a152={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f120",lvUp=0,rankUp=1,attType={4,3},attEffect={2,2},att={6.48,6.48},refineId=24,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a153={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f52",lvUp=0,rankUp=1,attType={2},attEffect={1},att={18},refineId=25,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a154={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f56",lvUp=0,rankUp=1,attType={1},attEffect={1},att={18},refineId=26,strength=144,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a155={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f60",lvUp=0,rankUp=1,attType={3},attEffect={2},att={10.8},refineId=27,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a156={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f64",lvUp=0,rankUp=1,attType={4},attEffect={2},att={10.8},refineId=28,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a157={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f92",lvUp=0,rankUp=1,attType={2,3},attEffect={1,2},att={10.8,6.48},refineId=29,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a158={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f96",lvUp=0,rankUp=1,attType={1,4},attEffect={1,2},att={10.8,6.48},refineId=30,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a159={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f124",lvUp=0,rankUp=1,attType={2,1},attEffect={1,1},att={10.8,10.8},refineId=31,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
        a160={grade=1,needOwn=4,needOther=8,needOrange=10,orangeId="f128",lvUp=0,rankUp=1,attType={4,3},attEffect={2,2},att={6.48,6.48},refineId=32,strength=216,cost={e={{p12=500,index=1}}},serverCost={p12=500}},
    },
    [2]={
        a129={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f4",lvUp=5,rankUp=1,attType={2},attEffect={1},att={21.6},refineId=1,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a130={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f8",lvUp=5,rankUp=1,attType={1},attEffect={1},att={21.6},refineId=2,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a131={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f12",lvUp=5,rankUp=1,attType={3},attEffect={2},att={12.96},refineId=3,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a132={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f16",lvUp=5,rankUp=1,attType={4},attEffect={2},att={12.96},refineId=4,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a133={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f68",lvUp=5,rankUp=1,attType={2,3},attEffect={1,2},att={12.96,7.78},refineId=5,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a134={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f72",lvUp=5,rankUp=1,attType={1,4},attEffect={1,2},att={12.96,7.78},refineId=6,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a135={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f100",lvUp=5,rankUp=1,attType={2,1},attEffect={1,1},att={12.96,12.96},refineId=7,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a136={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f104",lvUp=5,rankUp=1,attType={4,3},attEffect={2,2},att={7.78,7.78},refineId=8,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a137={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f20",lvUp=5,rankUp=1,attType={2},attEffect={1},att={21.6},refineId=9,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a138={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f24",lvUp=5,rankUp=1,attType={1},attEffect={1},att={21.6},refineId=10,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a139={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f28",lvUp=5,rankUp=1,attType={3},attEffect={2},att={12.96},refineId=11,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a140={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f32",lvUp=5,rankUp=1,attType={4},attEffect={2},att={12.96},refineId=12,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a141={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f76",lvUp=5,rankUp=1,attType={2,3},attEffect={1,2},att={12.96,7.78},refineId=13,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a142={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f80",lvUp=5,rankUp=1,attType={1,4},attEffect={1,2},att={12.96,7.78},refineId=14,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a143={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f108",lvUp=5,rankUp=1,attType={2,1},attEffect={1,1},att={12.96,12.96},refineId=15,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a144={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f112",lvUp=5,rankUp=1,attType={4,3},attEffect={2,2},att={7.78,7.78},refineId=16,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a145={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f36",lvUp=5,rankUp=1,attType={2},attEffect={1},att={21.6},refineId=17,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a146={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f40",lvUp=5,rankUp=1,attType={1},attEffect={1},att={21.6},refineId=18,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a147={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f44",lvUp=5,rankUp=1,attType={3},attEffect={2},att={12.96},refineId=19,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a148={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f48",lvUp=5,rankUp=1,attType={4},attEffect={2},att={12.96},refineId=20,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a149={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f84",lvUp=5,rankUp=1,attType={2,3},attEffect={1,2},att={12.96,7.78},refineId=21,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a150={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f88",lvUp=5,rankUp=1,attType={1,4},attEffect={1,2},att={12.96,7.78},refineId=22,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a151={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f116",lvUp=5,rankUp=1,attType={2,1},attEffect={1,1},att={12.96,12.96},refineId=23,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a152={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f120",lvUp=5,rankUp=1,attType={4,3},attEffect={2,2},att={7.78,7.78},refineId=24,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a153={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f52",lvUp=5,rankUp=1,attType={2},attEffect={1},att={21.6},refineId=25,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a154={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f56",lvUp=5,rankUp=1,attType={1},attEffect={1},att={21.6},refineId=26,strength=173,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a155={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f60",lvUp=5,rankUp=1,attType={3},attEffect={2},att={12.96},refineId=27,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a156={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f64",lvUp=5,rankUp=1,attType={4},attEffect={2},att={12.96},refineId=28,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a157={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f92",lvUp=5,rankUp=1,attType={2,3},attEffect={1,2},att={12.96,7.78},refineId=29,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a158={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f96",lvUp=5,rankUp=1,attType={1,4},attEffect={1,2},att={12.96,7.78},refineId=30,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a159={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f124",lvUp=5,rankUp=1,attType={2,1},attEffect={1,1},att={12.96,12.96},refineId=31,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
        a160={grade=2,needOwn=8,needOther=16,needOrange=20,orangeId="f128",lvUp=5,rankUp=1,attType={4,3},attEffect={2,2},att={7.78,7.78},refineId=32,strength=259,cost={e={{p12=1000,index=1}}},serverCost={p12=1000}},
    },
    [3]={
        a129={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f4",lvUp=5,rankUp=2,attType={2},attEffect={1},att={25.2},refineId=1,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a130={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f8",lvUp=5,rankUp=2,attType={1},attEffect={1},att={25.2},refineId=2,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a131={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f12",lvUp=5,rankUp=2,attType={3},attEffect={2},att={15.12},refineId=3,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a132={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f16",lvUp=5,rankUp=2,attType={4},attEffect={2},att={15.12},refineId=4,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a133={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f68",lvUp=5,rankUp=2,attType={2,3},attEffect={1,2},att={15.12,9.07},refineId=5,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a134={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f72",lvUp=5,rankUp=2,attType={1,4},attEffect={1,2},att={15.12,9.07},refineId=6,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a135={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f100",lvUp=5,rankUp=2,attType={2,1},attEffect={1,1},att={15.12,15.12},refineId=7,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a136={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f104",lvUp=5,rankUp=2,attType={4,3},attEffect={2,2},att={9.07,9.07},refineId=8,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a137={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f20",lvUp=5,rankUp=2,attType={2},attEffect={1},att={25.2},refineId=9,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a138={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f24",lvUp=5,rankUp=2,attType={1},attEffect={1},att={25.2},refineId=10,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a139={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f28",lvUp=5,rankUp=2,attType={3},attEffect={2},att={15.12},refineId=11,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a140={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f32",lvUp=5,rankUp=2,attType={4},attEffect={2},att={15.12},refineId=12,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a141={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f76",lvUp=5,rankUp=2,attType={2,3},attEffect={1,2},att={15.12,9.07},refineId=13,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a142={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f80",lvUp=5,rankUp=2,attType={1,4},attEffect={1,2},att={15.12,9.07},refineId=14,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a143={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f108",lvUp=5,rankUp=2,attType={2,1},attEffect={1,1},att={15.12,15.12},refineId=15,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a144={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f112",lvUp=5,rankUp=2,attType={4,3},attEffect={2,2},att={9.07,9.07},refineId=16,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a145={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f36",lvUp=5,rankUp=2,attType={2},attEffect={1},att={25.2},refineId=17,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a146={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f40",lvUp=5,rankUp=2,attType={1},attEffect={1},att={25.2},refineId=18,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a147={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f44",lvUp=5,rankUp=2,attType={3},attEffect={2},att={15.12},refineId=19,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a148={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f48",lvUp=5,rankUp=2,attType={4},attEffect={2},att={15.12},refineId=20,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a149={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f84",lvUp=5,rankUp=2,attType={2,3},attEffect={1,2},att={15.12,9.07},refineId=21,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a150={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f88",lvUp=5,rankUp=2,attType={1,4},attEffect={1,2},att={15.12,9.07},refineId=22,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a151={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f116",lvUp=5,rankUp=2,attType={2,1},attEffect={1,1},att={15.12,15.12},refineId=23,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a152={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f120",lvUp=5,rankUp=2,attType={4,3},attEffect={2,2},att={9.07,9.07},refineId=24,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a153={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f52",lvUp=5,rankUp=2,attType={2},attEffect={1},att={25.2},refineId=25,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a154={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f56",lvUp=5,rankUp=2,attType={1},attEffect={1},att={25.2},refineId=26,strength=202,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a155={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f60",lvUp=5,rankUp=2,attType={3},attEffect={2},att={15.12},refineId=27,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a156={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f64",lvUp=5,rankUp=2,attType={4},attEffect={2},att={15.12},refineId=28,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a157={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f92",lvUp=5,rankUp=2,attType={2,3},attEffect={1,2},att={15.12,9.07},refineId=29,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a158={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f96",lvUp=5,rankUp=2,attType={1,4},attEffect={1,2},att={15.12,9.07},refineId=30,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a159={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f124",lvUp=5,rankUp=2,attType={2,1},attEffect={1,1},att={15.12,15.12},refineId=31,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
        a160={grade=3,needOwn=16,needOther=24,needOrange=30,orangeId="f128",lvUp=5,rankUp=2,attType={4,3},attEffect={2,2},att={9.07,9.07},refineId=32,strength=302,cost={e={{p12=2000,index=1}}},serverCost={p12=2000}},
    },
    [4]={
        a129={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f4",lvUp=10,rankUp=2,attType={2},attEffect={1},att={28.8},refineId=1,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a130={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f8",lvUp=10,rankUp=2,attType={1},attEffect={1},att={28.8},refineId=2,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a131={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f12",lvUp=10,rankUp=2,attType={3},attEffect={2},att={17.28},refineId=3,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a132={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f16",lvUp=10,rankUp=2,attType={4},attEffect={2},att={17.28},refineId=4,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a133={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f68",lvUp=10,rankUp=2,attType={2,3},attEffect={1,2},att={17.28,10.37},refineId=5,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a134={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f72",lvUp=10,rankUp=2,attType={1,4},attEffect={1,2},att={17.28,10.37},refineId=6,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a135={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f100",lvUp=10,rankUp=2,attType={2,1},attEffect={1,1},att={17.28,17.28},refineId=7,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a136={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f104",lvUp=10,rankUp=2,attType={4,3},attEffect={2,2},att={10.37,10.37},refineId=8,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a137={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f20",lvUp=10,rankUp=2,attType={2},attEffect={1},att={28.8},refineId=9,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a138={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f24",lvUp=10,rankUp=2,attType={1},attEffect={1},att={28.8},refineId=10,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a139={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f28",lvUp=10,rankUp=2,attType={3},attEffect={2},att={17.28},refineId=11,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a140={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f32",lvUp=10,rankUp=2,attType={4},attEffect={2},att={17.28},refineId=12,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a141={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f76",lvUp=10,rankUp=2,attType={2,3},attEffect={1,2},att={17.28,10.37},refineId=13,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a142={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f80",lvUp=10,rankUp=2,attType={1,4},attEffect={1,2},att={17.28,10.37},refineId=14,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a143={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f108",lvUp=10,rankUp=2,attType={2,1},attEffect={1,1},att={17.28,17.28},refineId=15,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a144={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f112",lvUp=10,rankUp=2,attType={4,3},attEffect={2,2},att={10.37,10.37},refineId=16,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a145={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f36",lvUp=10,rankUp=2,attType={2},attEffect={1},att={28.8},refineId=17,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a146={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f40",lvUp=10,rankUp=2,attType={1},attEffect={1},att={28.8},refineId=18,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a147={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f44",lvUp=10,rankUp=2,attType={3},attEffect={2},att={17.28},refineId=19,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a148={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f48",lvUp=10,rankUp=2,attType={4},attEffect={2},att={17.28},refineId=20,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a149={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f84",lvUp=10,rankUp=2,attType={2,3},attEffect={1,2},att={17.28,10.37},refineId=21,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a150={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f88",lvUp=10,rankUp=2,attType={1,4},attEffect={1,2},att={17.28,10.37},refineId=22,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a151={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f116",lvUp=10,rankUp=2,attType={2,1},attEffect={1,1},att={17.28,17.28},refineId=23,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a152={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f120",lvUp=10,rankUp=2,attType={4,3},attEffect={2,2},att={10.37,10.37},refineId=24,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a153={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f52",lvUp=10,rankUp=2,attType={2},attEffect={1},att={28.8},refineId=25,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a154={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f56",lvUp=10,rankUp=2,attType={1},attEffect={1},att={28.8},refineId=26,strength=230,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a155={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f60",lvUp=10,rankUp=2,attType={3},attEffect={2},att={17.28},refineId=27,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a156={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f64",lvUp=10,rankUp=2,attType={4},attEffect={2},att={17.28},refineId=28,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a157={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f92",lvUp=10,rankUp=2,attType={2,3},attEffect={1,2},att={17.28,10.37},refineId=29,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a158={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f96",lvUp=10,rankUp=2,attType={1,4},attEffect={1,2},att={17.28,10.37},refineId=30,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a159={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f124",lvUp=10,rankUp=2,attType={2,1},attEffect={1,1},att={17.28,17.28},refineId=31,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
        a160={grade=4,needOwn=24,needOther=32,needOrange=40,orangeId="f128",lvUp=10,rankUp=2,attType={4,3},attEffect={2,2},att={10.37,10.37},refineId=32,strength=346,cost={e={{p12=3000,index=1}}},serverCost={p12=3000}},
    },
    [5]={
        a129={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f4",lvUp=10,rankUp=3,attType={2},attEffect={1},att={32.4},refineId=1,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a130={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f8",lvUp=10,rankUp=3,attType={1},attEffect={1},att={32.4},refineId=2,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a131={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f12",lvUp=10,rankUp=3,attType={3},attEffect={2},att={19.44},refineId=3,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a132={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f16",lvUp=10,rankUp=3,attType={4},attEffect={2},att={19.44},refineId=4,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a133={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f68",lvUp=10,rankUp=3,attType={2,3},attEffect={1,2},att={19.44,11.66},refineId=5,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a134={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f72",lvUp=10,rankUp=3,attType={1,4},attEffect={1,2},att={19.44,11.66},refineId=6,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a135={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f100",lvUp=10,rankUp=3,attType={2,1},attEffect={1,1},att={19.44,19.44},refineId=7,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a136={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f104",lvUp=10,rankUp=3,attType={4,3},attEffect={2,2},att={11.66,11.66},refineId=8,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a137={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f20",lvUp=10,rankUp=3,attType={2},attEffect={1},att={32.4},refineId=9,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a138={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f24",lvUp=10,rankUp=3,attType={1},attEffect={1},att={32.4},refineId=10,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a139={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f28",lvUp=10,rankUp=3,attType={3},attEffect={2},att={19.44},refineId=11,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a140={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f32",lvUp=10,rankUp=3,attType={4},attEffect={2},att={19.44},refineId=12,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a141={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f76",lvUp=10,rankUp=3,attType={2,3},attEffect={1,2},att={19.44,11.66},refineId=13,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a142={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f80",lvUp=10,rankUp=3,attType={1,4},attEffect={1,2},att={19.44,11.66},refineId=14,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a143={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f108",lvUp=10,rankUp=3,attType={2,1},attEffect={1,1},att={19.44,19.44},refineId=15,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a144={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f112",lvUp=10,rankUp=3,attType={4,3},attEffect={2,2},att={11.66,11.66},refineId=16,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a145={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f36",lvUp=10,rankUp=3,attType={2},attEffect={1},att={32.4},refineId=17,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a146={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f40",lvUp=10,rankUp=3,attType={1},attEffect={1},att={32.4},refineId=18,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a147={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f44",lvUp=10,rankUp=3,attType={3},attEffect={2},att={19.44},refineId=19,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a148={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f48",lvUp=10,rankUp=3,attType={4},attEffect={2},att={19.44},refineId=20,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a149={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f84",lvUp=10,rankUp=3,attType={2,3},attEffect={1,2},att={19.44,11.66},refineId=21,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a150={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f88",lvUp=10,rankUp=3,attType={1,4},attEffect={1,2},att={19.44,11.66},refineId=22,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a151={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f116",lvUp=10,rankUp=3,attType={2,1},attEffect={1,1},att={19.44,19.44},refineId=23,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a152={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f120",lvUp=10,rankUp=3,attType={4,3},attEffect={2,2},att={11.66,11.66},refineId=24,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a153={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f52",lvUp=10,rankUp=3,attType={2},attEffect={1},att={32.4},refineId=25,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a154={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f56",lvUp=10,rankUp=3,attType={1},attEffect={1},att={32.4},refineId=26,strength=259,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a155={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f60",lvUp=10,rankUp=3,attType={3},attEffect={2},att={19.44},refineId=27,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a156={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f64",lvUp=10,rankUp=3,attType={4},attEffect={2},att={19.44},refineId=28,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a157={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f92",lvUp=10,rankUp=3,attType={2,3},attEffect={1,2},att={19.44,11.66},refineId=29,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a158={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f96",lvUp=10,rankUp=3,attType={1,4},attEffect={1,2},att={19.44,11.66},refineId=30,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a159={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f124",lvUp=10,rankUp=3,attType={2,1},attEffect={1,1},att={19.44,19.44},refineId=31,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
        a160={grade=5,needOwn=32,needOther=40,needOrange=50,orangeId="f128",lvUp=10,rankUp=3,attType={4,3},attEffect={2,2},att={11.66,11.66},refineId=32,strength=389,cost={e={{p12=4000,index=1}}},serverCost={p12=4000}},
    },
}

return accessoryPlus
