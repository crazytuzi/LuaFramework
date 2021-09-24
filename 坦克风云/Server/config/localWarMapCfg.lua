--区域战的地图配置
local localWarMapCfg=
{
    --地图上的城市相关配置
    --id: 一个用于区分的标识
    --type: 1是主基地, 2是普通据点, 3是王城
    --pos: 在地图上的位置
    --adjoin: 与该城市相邻的城市
    --distance: 该城市与前面的相邻城市之间的距离, 单位是秒
    --buff: 该城市提供的buff, key是buff类型, value是buff的值
    --hp: 城市的血量
    --landType: 城市地形
    cityCfg=
    {
        a1={id="a1",type=1,icon="localWar_baseUp.png",pos={295.5,1086.5},adjoin={"a2","a5"},distance={10,10},buff={},hp=1,landType=6},
        a2={id="a2",type=2,icon="localWar_cityOut.png",pos={451,1242},adjoin={"a1","a3","a6"},distance={10,10,10},buff={[102]=0.05,[103]=0.05},hp=0,landType=1},
        a3={id="a3",type=2,icon="localWar_cityOut.png",pos={762,1242},adjoin={"a2","a4","a7"},distance={10,10,10},buff={[104]=0.05,[105]=0.05},hp=0,landType=2},
        a4={id="a4",type=1,icon="localWar_baseUp.png",pos={917.5,1086.5},adjoin={"a3","a8"},distance={10,10},buff={},hp=1,landType=6},
        a5={id="a5",type=2,icon="localWar_cityOut.png",pos={140,931},adjoin={"a1","a6","a9"},distance={10,10,10},buff={[104]=0.05,[105]=0.05},hp=0,landType=3},
        a6={id="a6",type=2,icon="localWar_cityIn.png",pos={451,931},adjoin={"a2","a5","a7","a10","a17"},distance={10,10,10,10,10},buff={[109]=0.1},hp=0,landType=5},
        a7={id="a7",type=2,icon="localWar_cityIn.png",pos={762,931},adjoin={"a3","a6","a8","a11","a17"},distance={10,10,10,10,10},buff={[109]=0.1},hp=0,landType=5},
        a8={id="a8",type=2,icon="localWar_cityOut.png",pos={1073,931},adjoin={"a4","a7","a12"},distance={10,10,10},buff={[102]=0.05,[103]=0.05},hp=0,landType=4},
        a9={id="a9",type=2,icon="localWar_cityOut.png",pos={140,619},adjoin={"a5","a10","a13"},distance={10,10,10},buff={[102]=0.05,[103]=0.05},hp=0,landType=4},
        a10={id="a10",type=2,icon="localWar_cityIn.png",pos={451,619},adjoin={"a6","a9","a11","a14","a17"},distance={10,10,10,10,10},buff={[109]=0.1},hp=0,landType=5},
        a11={id="a11",type=2,icon="localWar_cityIn.png",pos={762,619},adjoin={"a7","a10","a12","a15","a17"},distance={10,10,10,10,10},buff={[109]=0.1},hp=0,landType=5},
        a12={id="a12",type=2,icon="localWar_cityOut.png",pos={1073,619},adjoin={"a8","a11","a16"},distance={10,10,10},buff={[104]=0.05,[105]=0.05},hp=0,landType=3},
        a13={id="a13",type=1,icon="localWar_baseDown.png",pos={295.5,463.5},adjoin={"a9","a14"},distance={10,10},buff={},hp=1,landType=6},
        a14={id="a14",type=2,icon="localWar_cityOut.png",pos={451,308},adjoin={"a10","a13","a15"},distance={10,10,10},buff={[104]=0.05,[105]=0.05},hp=0,landType=2},
        a15={id="a15",type=2,icon="localWar_cityOut.png",pos={762,308},adjoin={"a11","a14","a16"},distance={10,10,10},buff={[102]=0.05,[103]=0.05},hp=0,landType=1},
        a16={id="a16",type=1,icon="localWar_baseDown.png",pos={917.5,463.5},adjoin={"a12","a15"},distance={10,10},buff={},hp=1,landType=6},
        a17={id="a17",type=3,icon="localWar_capital.png",pos={606.5,775},adjoin={"a6","a7","a10","a11"},distance={10,10,10,10},buff={},hp=1000,landType=6},
        a18={id="a18",type=2,icon="localWar_homeUp.png",pos={140,1242},adjoin={"a1","a2","a5"},distance={10,10,10},buff={},hp=0,landType=6},
        a19={id="a19",type=2,icon="localWar_homeUp.png",pos={1073,1242},adjoin={"a3","a4","a8"},distance={10,10,10},buff={},hp=0,landType=6},
        a20={id="a20",type=2,icon="localWar_homeDown.png",pos={140,308},adjoin={"a9","a13","a14"},distance={10,10,10},buff={},hp=0,landType=6},
        a21={id="a21",type=2,icon="localWar_homeDown.png",pos={1073.5,308},adjoin={"a12","a15","a16"},distance={10,10,10},buff={},hp=0,landType=6},
    },
    --四个主基地ID
    baseCityID={"a1","a16","a4","a13"},
    --主基地有人报名的时候的血量,无人报名或被攻占后用cityCfg里配的血量
    baseCityHp=400,
    --出生点ID
    homeID={a1="a18",a16="a21",a4="a19",a13="a20",a17="a17"},
    capitalID="a17",
    --扫据点的顺序
    sortCity={"a17","a1","a16","a4","a13","a2","a3","a5","a6","a7","a8","a9","a10","a11","a12","a14","a15"},
}

return localWarMapCfg