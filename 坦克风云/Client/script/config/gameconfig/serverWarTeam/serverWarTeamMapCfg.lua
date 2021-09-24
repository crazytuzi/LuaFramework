--军团跨服战地图配置
serverWarTeamMapCfg=
{
	--地图上城市相关信息
	--id:城市标识 name:城市名称 icon:城市图标
	--type:城市类型 1:主基地 2:普通据点 3:飞机场
	--winPoint:占领积分
	--pos:地图上位置
	--adjoin:直接相连的城市
	--roadType:路线类型，和相连城市对应 1:大路 2:小路
	--distance:到达相连城市所需时间 单位:秒
	cityCfg={
		a1={id="a1",name="serverwarteam_cityNamea1",icon="localWar_baseDown.png",type=1,winPoint=0,pos={544.5,84.5},movePos={504.5,104.5},adjoin={"a2","a3","a4","a5"},roadType={1,1,1,1},distance={30,30,30,30}},
		a2={id="a2",name="serverwarteam_cityNamea2",icon="serverWarAirport1.png",type=3,winPoint=0,pos={76,111},movePos={76,100},adjoin={"a1","a6"},roadType={1,1},distance={30,5}},
		a3={id="a3",name="serverwarteam_cityNamea3",icon="localWar_cityIn.png",type=2,winPoint=100,pos={205.5,192.5},movePos={185.5,202.5},adjoin={"a1","a6"},roadType={1,1},distance={30,30}},
		a4={id="a4",name="serverwarteam_cityNamea4",icon="serverWarLocalCity5.png",type=2,winPoint=50,pos={558.5,265.5},adjoin={"a1","a13"},roadType={1,2},distance={30,45}},
		a5={id="a5",name="serverwarteam_cityNamea5",icon="localWar_cityIn.png",type=2,winPoint=100,pos={361.5,268.5},movePos={341.5,268.5},adjoin={"a1","a7","a8"},roadType={1,1,1},distance={30,30,30}},
		a6={id="a6",name="serverwarteam_cityNamea6",icon="localWar_cityIn.png",type=2,winPoint=100,pos={168.5,393.5},movePos={188.5,413.5},adjoin={"a3","a8","a9"},roadType={1,1,1},distance={30,30,30}},
		a7={id="a7",name="serverwarteam_cityNamea7",icon="localWar_cityIn.png",type=2,winPoint=100,pos={514.5,403.5},adjoin={"a5","a10"},roadType={1,1},distance={30,30}},
		a8={id="a8",name="serverwarteam_cityNamea8",icon="localWar_capital.png",type=2,winPoint=150,pos={321,468.5},adjoin={"a5","a6","a10","a11"},roadType={1,1,1,1},distance={30,30,30,30}},
		a9={id="a9",name="serverwarteam_cityNamea9",icon="localWar_cityIn.png",type=2,winPoint=100,pos={134.5,587.5},adjoin={"a6","a11"},roadType={1,1},distance={30,30}},
		a10={id="a10",name="serverwarteam_cityNamea10",icon="localWar_cityIn.png",type=2,winPoint=100,pos={485.5,569.5},adjoin={"a7","a8","a13"},roadType={1,1,1},distance={30,30,30}},
		a11={id="a11",name="serverwarteam_cityNamea11",icon="localWar_cityIn.png",type=2,winPoint=100,pos={275.5,709.5},adjoin={"a8","a9","a15"},roadType={1,1,1},distance={30,30,30}},
		a12={id="a12",name="serverwarteam_cityNamea12",icon="serverWarLocalCity5.png",type=2,winPoint=50,pos={77.5,696.5},adjoin={"a3","a15"},roadType={2,1},distance={45,30}},
		a13={id="a13",name="serverwarteam_cityNamea13",icon="localWar_cityIn.png",type=2,winPoint=100,pos={419.5,784.5},adjoin={"a10","a15"},roadType={1,1},distance={30,30}},
		a14={id="a14",name="serverwarteam_cityNamea14",icon="serverWarAirport1.png",type=3,winPoint=0,pos={566,886},movePos={566,880},adjoin={"a10","a15"},roadType={1,1},distance={5,30}},
		a15={id="a15",name="serverwarteam_cityNamea15",icon="localWar_baseUp.png",type=1,winPoint=0,pos={90,889.5},movePos={130,859.5},adjoin={"a11","a12","a13","a14"},roadType={1,1,1,1},distance={30,30,30,30}},
	},	
	--主基地，第一个为红方基地，第二个为蓝方基地
	baseCityID={"a1","a15"},	
	--轰炸减少坦克数量百分比
	bombHpPercent=0.05,
	--飞机场所能轰炸城市的信息
	bomdCity={["a2"]={"a1","a3","a6","a9"},["a14"]={"a7","a10","a13","a15"}},	
	--飞机场所能空降的城市信息，前端特殊处理，后端当成普通道路，前端不显示道路
	flyCity={["a2"]={"a6"},["a14"]={"a10"}},
	--火车站
	railWayCity={"a4","a12"},
	--火车站
	airport={"a2","a14"},
	--机场激活轰炸所需的玩家人数
	flyNeed=3,
	--激活机场空军支援的玩家将持续获得个人贡献
	bombDonate=10,
	--飞机场效果未激活和激活的两帧
	airportSp="serverWarAirport2.png",
}