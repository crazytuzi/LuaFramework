
GuildRewardCfg =
{
	opendays = 1,
	level = 300,
	circle = 0,
	quest = {nQId = 60, targetType = 20, id = 2, count = 1,},
	tasks =
	{
		-- 	desc = "进行行会捐献（元宝、钻石均可）",
		--  view_pos = {view_def = "ViewDef.Guild", npc_id = 10, boss_cfg = {type = 1, boss_id = 111}},
		[1] =
		{
			desc = "进行行会捐献",
			condition = {10,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.Guild.GuildView.GuildBuild", npc_id = nil, boss_cfg = nil},
		},
		[2] =
		{
			desc = "击杀500级以上BOSS",
			condition = {1,4,500,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.NewlyBossView", npc_id = nil, boss_cfg = nil},
		},
		[3] =
		{
			desc = "在元宝商城购买道具",
			condition = {1,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.Shop.Bind_yuan", npc_id = nil, boss_cfg = nil},
		},
		[4] =
		{
			desc = "参与探索宝藏",
			condition = {3,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.Explore", npc_id = nil, boss_cfg = nil},
		},
		[5] =
		{
			desc = "在钻石商城购买道具",
			condition = {1,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.Shop.Prop", npc_id = nil, boss_cfg = nil},
		},
		[6] =
		{
			desc = "进行一次充值",
			condition = {1,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.ZsVip.Recharge", npc_id = nil, boss_cfg = nil},
		},
		[7] =
		{
			desc = "前往沙城夺取战旗",
			condition = {1,4,{1786,},},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = nil, npc_id = nil, boss_cfg = {type = 15, boss_id = 1786},},
		},
		[8] =
		{
			desc = "击杀其他行会玩家",
			condition = {1,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = nil, npc_id = nil, boss_cfg = nil},
		},
		[9] =
		{
			desc = "进行BOSS挖掘",
			condition = {5,},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = "ViewDef.DiamondPet", npc_id = nil, boss_cfg = nil},
		},
		[10] =
		{
			desc = "劫镖",
			condition = {1,17},
			integral = 100,
			onkeyFinish = {opendays = 2, consumes = {{type = 15, id = 0, count = 300, bind = 0},},},
			awards = {{type = 0, id = 22, count = 5, bind = 1},{type = 6, id = 0, count = 100000, bind = 0},{type = 3, id = 0, count = 10000, bind = 0},{type = 27, id = 0, count = 10, bind = 0},},
			view_pos = {view_def = nil, npc_id = 20, boss_cfg = nil},
		},
	},
	integralawards =
	{
		{integral = 200, awards = {{type = 0, id = 268, count = 1, bind = 1},},},
		{integral = 400, awards = {{type = 0, id = 268, count = 1, bind = 1},},},
		{integral = 600, awards = {{type = 0, id = 268, count = 1, bind = 1},},},
		{integral = 1000, awards = {{type = 0, id = 268, count = 2, bind = 1},},},
	},
}