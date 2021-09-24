serverWarTeamMapCfg1=
{
	--地图上的城市相关配置
	--id: 一个用于区分的标识
	--type: 1是主基地, 2是普通据点
	--pos: 在地图上的位置
	--adjoin: 与该城市有道路直接相连的城市
	--roadType: 该城市到目标城市的道路类型, 1是大路, 2是小路
	--distance: 该城市与前面的相邻城市之间的距离, 单位是秒, -1表示虽然相连但是道路是单向的, 无法过去
	--wayPoint: 从该城市到达相邻城市所需要经过的点, 用于播放走过去的动画
	--backway1: 从这个城市有哪些路线通到主基地1
	--backway2: 从这个城市有哪些路线通到主基地2(11号城市)
	--以上两个道路配在这里就可以不用搞寻路, 节约效率
	--每个元素是一个table, table的第一个元素表示大路路线, 第二个元素表示n秒钟(n也是配置)才会出现的小路路线, 这两个table的每一个元素又是一个table表示这条路线经过的所有城市
	cityCfg=
	{
		a1={id="a1",type=1,winPoint=0,pos={544,96},adjoin={"a2","a4"},roadType={1,1},distance={40,30},backway1={{},{}},backway2={{},{}},wayPoint={{{544,96},{352,96},{352,160}},{{544,96},{544,352}}}},
		a2={id="a2",type=2,winPoint=100,pos={320,192},adjoin={"a1","a3","a5"},roadType={1,1,1},distance={40,30,20},backway1={{{"a1"}},{}},backway2={{{"a3","a6","a7","a10","a11"},{3,6,9,10,11},{5,6,7,10,11},{5,6,9,10,11}},{{3,8,11}}},wayPoint={{{352,160},{352,96},{544,96}},{{320,160},{128,160}},{{352,224},{352,384}}}},
		a3={id="a3",type=2,winPoint=100,pos={128,192},adjoin={"a2","a6","a8"},roadType={1,1,2},distance={30,70,-1},backway1={{{"a2","a1"}},{{"a6","a9","a4","a1"}}},backway2={{{"a6","a7","a10","a11"},{"a6","a9","a10","a11"}},{{"a8","a11"}}},wayPoint={{{128,160},{320,160}},{{160,192},{160,544},{320,544}},{{96,192},{96,608}}}},
		a4={id="a4",type=2,winPoint=100,pos={544,352},adjoin={"a1","a9"},roadType={1,2},distance={30,60},backway1={{{"a1"}},{{"a9","a6","a5","a2","a1"},{"a9","a6","a3","a2","a1"}}},backway2={{},{{"a9","a10","a11"},{"a9","a6","a3","a8","a11"}}},wayPoint={{{544,352},{544,96}},{{544,352},{544,768}}}},
		a5={id="a5",type=2,winPoint=100,pos={320,384},adjoin={"a2","a6"},roadType={1,1},distance={20,20},backway1={{{"a2","a1"}},{{"a6","a9","a4","a1"}}},backway2={{{"a6","a7","a10","a11"},{"a6","a9","a10","a11"}},{{"a2","a3","a8","a11"},{"a6","a3","a8","a11"}}},wayPoint={{{352,384},{352,224}},{{288,384},{288,544}}}},
		a6={id="a6",type=2,winPoint=100,pos={320,512},adjoin={"a3","a5","a7","a9"},roadType={1,1,1,1},distance={70,20,20,70},backway1={{{"a3","a2","a1"},{"a5","a2","a1"}},{{"a9","a4","a1"}}},backway2={{{"a7","a10","a11"},{"a9","a10","a11"}},{{"a3","a8","a11"}}},wayPoint={{{320,544},{160,544},{160,192}},{{288,544},{288,384}},{{352,544},{352,640}},{{352,480},{480,480},{480,768}}}},
		a7={id="a7",type=2,winPoint=100,pos={320,640},adjoin={"a6","a10"},roadType={1,1},distance={20,20},backway1={{{"a6","a5","a2","a1"},{"a6","a3","a2","a1"}},{{"a6","a9","a4","a1"},{"a10","a9","a4","a1"}}},backway2={{{"a10","a11"}},{{"a6","a3","a8","a11"}}},wayPoint={{{352,640},{352,544}},{{288,640},{288,768}}}},
		a8={id="a8",type=2,winPoint=100,pos={96,608},adjoin={"a3","a11"},roadType={2,1},distance={60,30},backway1={{},{{"a3","a2","a1"},{"a3","a6","9","a4","a1"}}},backway2={{{"a11"}},{}},wayPoint={{{96,608},{96,192}},{{96,608},{96,864}}}},
		a9={id="a9",type=2,winPoint=100,pos={512,768},adjoin={"a4","a6","a10"},roadType={2,1,1},distance={-1,70,30},backway1={{{"a6","a5","a2","a1"},{"a6","a3","a2","a1"}},{{"a4","a1"}}},backway2={{{"a10","a11"}},{{"a6","a3","a8","a11"}}},wayPoint={{{544,768},{544,352}},{{480,768},{480,480},{352,480}},{{512,800},{352,800}}}},
		a10={id="a10",type=2,winPoint=100,pos={320,800},adjoin={"a7","a9","a11"},roadType={1,1,1},distance={20,30,40},backway1={{{"a7","a6","a3","a2","a1"},{"a7","a6","a5","a2","a1"},{"a9","a6","a3","a2","a1"},{"a9","a6","a5","a2","a1"}},{{"a9","a4","a1"}}},backway2={{{"a11"}},{}},wayPoint={{{288,768},{288,640}},{{352,800},{512,800}},{{288,800},{288,864},{96,864}}}},
		a11={id="a11",type=1,winPoint=0,pos={96,864},adjoin={"a8","a10"},roadType={1,1},distance={30,40},backway1={{},{}},backway2={{},{}},wayPoint={{{96,864},{96,608}},{{96,864},{288,864},{288,800}}}},
	},
	--红方蓝方的主基地ID, 第一个元素是红方主基地, 第二个元素是蓝方主基地
	baseCityID={"a1","a11"},
	--地图上的箭头位置, 用于指示小路
	--每一行是一条路上的一系列箭头, 这些箭头依次亮起然后灭掉来指示方向
	--每一个箭头的前两个元素是坐标, 第三个坐标是方向角度, 角度的值是以x轴为坐标顺时针旋转
	arrowCfg=
	{
		{{64,512,90},{64,416,90},{64,320,90}},
		{{576,480,-90},{576,576,-90},{576,672,-90}},
	},
	--绘制道路的时候用画格子的方法来绘制, 这个表示每个格子的边长
	cellWidth=64,
	--每个格子里面是什么东西, 格子暂定为10x15
	--0: 空格子
	--10: 左右方向的大路
	--11: 上下方向的大路
	--12: 上右方向的大路转角
	--13: 右下方向的大路转角
	--14: 下左方向的大路转角
	--15: 左上方向的大路转角
	--20: 左右方向的小路
	--21: 上下方向的小路
	--22: 上右方向的小路转角
	--23: 右下方向的小路转角
	--24: 下左方向的小路转角
	--25: 左上方向的小路转角
	cellCfg=
	{
		{0,0,0,0,0,0,0,0,0,0},				--第1排
		{0,0,0,0,0,12,10,10,15,0},			--第2排
		{0,0,10,10,10,11,0,0,11,0},			--第3排
		{0,21,11,0,0,11,0,0,11,0},			--第4排
		{0,21,11,0,0,11,0,0,11,0},			--第5排
		{0,21,11,0,0,11,0,0,11,0},			--第6排
		{0,21,11,0,11,0,0,0,21,0},			--第7排
		{0,21,11,0,11,10,10,15,21,0},		--第8排
		{0,21,13,10,10,11,0,11,21,0},		--第9排
		{0,11,0,0,0,11,0,11,21,0},			--第10排
		{0,11,0,0,11,0,0,11,21,0},			--第11排
		{0,11,0,0,11,0,0,11,21,0},			--第12排
		{0,11,0,0,11,10,10,10,0,0},			--第13排
		{0,13,10,10,14,0,0,0,0,0},			--第14排
		{0,0,0,0,0,0,0,0,0,0},				--第15排
	}
}