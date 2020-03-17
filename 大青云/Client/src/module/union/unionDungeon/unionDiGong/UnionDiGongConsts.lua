_G.UnionDiGongConsts = {};

UnionDiGongConsts.State_Nil = 0;--无
UnionDiGongConsts.State_ZhanLing = 1;--占领状态
UnionDiGongConsts.State_Bid = 2;--竞标状态
UnionDiGongConsts.State_Waite = 3;--竞标结束后等待状态
UnionDiGongConsts.State_Fight = 4;--争夺状态

UnionDiGongConsts.DGFlagUpPoint = {
 	-- 柱子1
	[1] = {
		x= -265,
		y= 162,
		r = 40,
	},
	-- 柱子2
	[2] = {
		x= 263,
		y= -200,
		r = 40,
	},
}

UnionDiGongConsts.ZhuZiBaseid = 10000079;
UnionDiGongConsts.rate = 10000;