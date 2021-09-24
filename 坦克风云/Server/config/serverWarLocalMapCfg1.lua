 --群雄争霸的地图配置1
local serverWarLocalMapCfg1=
{
 --地图上的城市相关配置
 --id: 一个用于区分的标识
 --type: 1是普通据点, 2是主基地 3鹰巢
 --pos: 在地图上的位置
 --adjoin: 与该城市有道路直接相连的城市
 --roadType: 该城市到目标城市的道路类型, 1是大路, 2是后开启的路
 --distance: 该城市与前面的相邻城市之间的距离, 单位是秒, -1表示虽然相连但是道路是单向的, 无法过去
cityCfg=
{
a1={id="a1",name="serverWarLocal_city3",icon="serverWarLocalCity4.png",pos={605,1782},adjoin={"a5"},roadType={1},distance={10},winPoint=30,landType=3,type=1},
a2={id="a2",name="serverWarLocal_city2",icon="serverWarLocalCity1.png",pos={1005,1782},adjoin={"a1","a3","a6"},roadType={1,1,1},distance={20,20,10},winPoint=0,landType=6,type=2},
a3={id="a3",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1403,1782},adjoin={"a7"},roadType={1},distance={10},winPoint=50,landType=5,type=1},
a4={id="a4",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={403,1579},adjoin={"a11"},roadType={1},distance={10},winPoint=80,landType=6,type=1},
a5={id="a5",name="serverWarLocal_city10",icon="serverWarLocalCity9.png",pos={605,1579},adjoin={"a1","a6","a11"},roadType={1,1,1},distance={10,20,10},buff={[102]=0.05,[103]=0.05,[104]=0.05,[105]=0.05},winPoint=0,landType=4,type=1},
a6={id="a6",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1002,1579},adjoin={"a5","a7","a12"},roadType={1,1,1},distance={20,20,10},winPoint=50,landType=5,type=1},
a7={id="a7",name="serverWarLocal_city4",icon="serverWarLocalCity5.png",pos={1403,1579},adjoin={"a3","a6","a13","a10","a36","a39"},roadType={1,1,1,1,1,1},distance={10,20,10,10,10,10},winPoint=0,landType=4,type=1},
a8={id="a8",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={1599,1579},adjoin={"a13"},roadType={1},distance={10},winPoint=80,landType=6,type=1},
a9={id="a9",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={209,1416},adjoin={"a10"},roadType={1},distance={10},winPoint=50,landType=5,type=1},
a10={id="a10",name="serverWarLocal_city5",icon="serverWarLocalCity5.png",pos={403,1416},adjoin={"a9","a11","a20","a7","a36","a39"},roadType={1,1,1,1,1,1},distance={10,10,20,10,10,10},winPoint=0,landType=2,type=1},
a11={id="a11",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={605,1416},adjoin={"a4","a5","a10","a12","a21"},roadType={1,1,1,1,1},distance={10,10,10,20,20},winPoint=50,landType=2,type=1},
a12={id="a12",name="serverWarLocal_city7",icon="serverWarLocalCity8.png",pos={1002,1416},adjoin={"a6","a11","a13","a17"},roadType={1,1,1,1},distance={10,20,20,10},buff2={[201]=30,[202]=30},winPoint=0,landType=4,type=1},
a13={id="a13",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1403,1416},adjoin={"a7","a8","a12","a14","a25"},roadType={1,1,1,1,1},distance={10,10,20,10,20},winPoint=50,landType=1,type=1},
a14={id="a14",name="serverWarLocal_city10",icon="serverWarLocalCity9.png",pos={1599,1416},adjoin={"a13","a15","a26"},roadType={1,1,1},distance={10,10,20},buff={[102]=0.05,[103]=0.05,[104]=0.05,[105]=0.05},winPoint=0,landType=1,type=1},
a15={id="a15",name="serverWarLocal_city3",icon="serverWarLocalCity4.png",pos={1802,1416},adjoin={"a14"},roadType={1},distance={10},winPoint=30,landType=3,type=1},
a16={id="a16",name="serverWarLocal_city8",icon="serverWarLocalCity7.png",pos={805,1221},adjoin={"a17","a22"},roadType={1,1},distance={10,10},buff1={[1]=0.25},winPoint=0,landType=3,type=1},
a17={id="a17",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={1002,1221},adjoin={"a12","a16","a18","a23"},roadType={1,1,1,2},distance={10,10,10,10},winPoint=80,landType=2,type=1},
a18={id="a18",name="serverWarLocal_city6",icon="serverWarLocalCity6.png",pos={1201,1221},adjoin={"a17","a24"},roadType={1,1},distance={10,10},buff={[100]=0.1,[109]=0.1},winPoint=0,landType=5,type=1},
a19={id="a19",name="serverWarLocal_city2",icon="serverWarLocalCity1.png",pos={209,1019},adjoin={"a9","a20","a31"},roadType={1,1,1},distance={20,10,20},winPoint=0,landType=6,type=2},
a20={id="a20",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={403,1019},adjoin={"a10","a21","a32"},roadType={1,1,1},distance={20,10,20},winPoint=50,landType=3,type=1},
a21={id="a21",name="serverWarLocal_city12",icon="serverWarLocalCity8.png",pos={605,1019},adjoin={"a11","a20","a22","a33"},roadType={1,1,1,1},distance={20,10,10,20},buff2={[201]=30,[202]=30},winPoint=0,landType=4,type=1},
a22={id="a22",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={805,1019},adjoin={"a16","a21","a23","a28"},roadType={1,1,2,1},distance={10,10,10,10},winPoint=80,landType=1,type=1},
a23={id="a23",name="serverWarLocal_city13",icon="serverWarLocalCity10.png",pos={1006,1019},adjoin={"a17","a22","a24","a29"},roadType={2,2,2,2},distance={10,10,10,10},winPoint=50,landType=6,type=3},
a24={id="a24",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={1201,1019},adjoin={"a18","a23","a25","a30"},roadType={1,2,1,1},distance={10,10,10,10},winPoint=80,landType=1,type=1},
a25={id="a25",name="serverWarLocal_city14",icon="serverWarLocalCity8.png",pos={1403,1019},adjoin={"a13","a24","a26","a35"},roadType={1,1,1,1},distance={20,10,10,20},buff2={[201]=30,[202]=30},winPoint=0,landType=4,type=1},
a26={id="a26",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1599,1019},adjoin={"a14","a25","a36"},roadType={1,1,1},distance={20,10,20},winPoint=50,landType=3,type=1},
a27={id="a27",name="serverWarLocal_city2",icon="serverWarLocalCity1.png",pos={1802,1019},adjoin={"a15","a26","a37"},roadType={1,1,1},distance={20,10,20},winPoint=0,landType=6,type=2},
a28={id="a28",name="serverWarLocal_city6",icon="serverWarLocalCity6.png",pos={805,821},adjoin={"a22","a29"},roadType={1,1},distance={10,10},buff={[100]=0.1,[109]=0.1},winPoint=0,landType=5,type=1},
a29={id="a29",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={1002,821},adjoin={"a23","a28","a30","a34"},roadType={2,1,1,1},distance={10,10,10,10},winPoint=80,landType=2,type=1},
a30={id="a30",name="serverWarLocal_city8",icon="serverWarLocalCity7.png",pos={1201,821},adjoin={"a24","a29"},roadType={1,1},distance={10,10},buff1={[1]=0.25},winPoint=0,landType=3,type=1},
a31={id="a31",name="serverWarLocal_city3",icon="serverWarLocalCity4.png",pos={209,621},adjoin={"a32"},roadType={1},distance={20},winPoint=30,landType=3,type=1},
a32={id="a32",name="serverWarLocal_city10",icon="serverWarLocalCity9.png",pos={403,621},adjoin={"a20","a31","a33"},roadType={1,1,1},distance={20,10,10},buff={[102]=0.05,[103]=0.05,[104]=0.05,[105]=0.05},winPoint=0,landType=1,type=1},
a33={id="a33",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={605,621},adjoin={"a21","a32","a34","a38","a39"},roadType={1,1,1,1,1},distance={20,10,20,10,10},winPoint=50,landType=1,type=1},
a34={id="a34",name="serverWarLocal_city16",icon="serverWarLocalCity8.png",pos={1002,621},adjoin={"a29","a33","a35","a40"},roadType={1,1,1,1},distance={10,20,20,10},buff2={[201]=30,[202]=30},winPoint=0,landType=4,type=1},
a35={id="a35",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1404,621},adjoin={"a25","a34","a36","a41","a42"},roadType={1,1,1,1,1},distance={20,20,10,10,10},winPoint=50,landType=2,type=1},
a36={id="a36",name="serverWarLocal_city17",icon="serverWarLocalCity5.png",pos={1599,621},adjoin={"a26","a35","a37","a7","a10","a39"},roadType={1,1,1,1,1,1},distance={20,10,10,10,10,10},winPoint=0,landType=2,type=1},
a37={id="a37",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1802,621},adjoin={"a36"},roadType={1},distance={10},winPoint=50,landType=5,type=1},
a38={id="a38",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={403,475},adjoin={"a33"},roadType={1},distance={10},winPoint=80,landType=6,type=1},
a39={id="a39",name="serverWarLocal_city18",icon="serverWarLocalCity5.png",pos={605,475},adjoin={"a33","a40","a43","a7","a10","a36"},roadType={1,1,1,1,1,1},distance={10,20,10,10,10,10},winPoint=0,landType=4,type=1},
a40={id="a40",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={1002,475},adjoin={"a34","a39","a41"},roadType={1,1,1},distance={10,20,20},winPoint=50,landType=5,type=1},
a41={id="a41",name="serverWarLocal_city10",icon="serverWarLocalCity9.png",pos={1404,475},adjoin={"a35","a40","a45"},roadType={1,1,1},distance={10,20,10},buff={[102]=0.05,[103]=0.05,[104]=0.05,[105]=0.05},winPoint=0,landType=4,type=1},
a42={id="a42",name="serverWarLocal_city9",icon="serverWarLocalCity2.png",pos={1599,475},adjoin={"a35"},roadType={1},distance={10},winPoint=80,landType=6,type=1},
a43={id="a43",name="serverWarLocal_city1",icon="serverWarLocalCity3.png",pos={605,278},adjoin={"a39"},roadType={1},distance={10},winPoint=50,landType=5,type=1},
a44={id="a44",name="serverWarLocal_city2",icon="serverWarLocalCity1.png",pos={1006,278},adjoin={"a40","a43","a45"},roadType={1,1,1},distance={20,10,20},winPoint=0,landType=6,type=2},
a45={id="a45",name="serverWarLocal_city3",icon="serverWarLocalCity4.png",pos={1404,278},adjoin={"a41"},roadType={1},distance={10},winPoint=30,landType=3,type=1},
},
 --4方的主基地ID, 第n个元素是n方主基地
baseCityID={"a2","a19","a27","a44"},
bossCity="a23",
 --车站配置,如果是在这几个车站之间移动的话图标要变成火车
railWayStation={"a7","a10","a36","a39"},
 --战斗检索的顺序  
sortCity={"a1","a2","a3","a4","a5","a6","a7","a8","a9","a10","a11","a12","a13","a14","a15","a16","a17","a18","a19","a20","a21","a22","a23","a24","a25","a26","a27","a28","a29","a30","a31","a32","a33","a34","a35","a36","a37","a38","a39","a40","a41","a42","a43","a44","a45"},
}

return serverWarLocalMapCfg1