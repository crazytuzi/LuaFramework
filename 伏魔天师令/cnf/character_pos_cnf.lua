_G.Cfg.wing_pos =
{
 [10001] ={ wing_x=0,wing_y=150,mwing_x=0,mwing_y=150,rwing_x=-35,rwing_y=180,rmwing_x=0,rmwing_y=220},
 [10002] ={ wing_x=0,wing_y=150,mwing_x=0,mwing_y=150,rwing_x=-35,rwing_y=180,rmwing_x=0,rmwing_y=220},
 [10003] ={ wing_x=0,wing_y=150,mwing_x=0,mwing_y=150,rwing_x=-30,rwing_y=200,rmwing_x=0,rmwing_y=220},
}


_G.Cfg.pet_pos=
{
 -- 娉婷孙姬
 [50101] ={ midle_x=0,midle_y=22,mmove_x=0,mmove_y=0},
 -- 闭月貂蝉
 [50106] ={ midle_x=0,midle_y=18,mmove_x=0,mmove_y=0},
 -- 碧玉大乔
 [50111] ={ midle_x=0,midle_y=16,mmove_x=0,mmove_y=0},
 -- 碧玉小乔
 [50116] ={ midle_x=0,midle_y=22,mmove_x=2,mmove_y=0},
 -- 才女文姬
 [50121] ={ midle_x=0,midle_y=20,mmove_x=2,mmove_y=0},
 -- 洛仙甄宓
 [50126] ={ midle_x=0,midle_y=22,mmove_x=2,mmove_y=0},
 -- 战姬月英
 [50131] ={ midle_x=0,midle_y=22,mmove_x=0,mmove_y=0},
}

_G.Cfg.mount_texiao=
{   
    --        1: 特效都存在 2: 只移动存在 3: 只站立存在 4: 一直站立 5: 一直移动 6: 一直idle2
    [40101] = { tx1={ type=1, z=1 , nScale=1, posx=0 } },
    [40106] = { tx1={ type=1, z=1 , nScale=1, posx=0 } },
    [40111] = { tx1={ type=1, z=1 , nScale=1, posx=0 } },
    [40116] = { tx1={ type=1, z=1 , nScale=1, posx=0 } },
    [40121] = { tx1={ type=1, z=-1, nScale=1, posx=0 } },
    [40126] = { tx1={ type=2, z=1 , nScale=1, posx=0 } },
    [40131] = { tx1={ type=1, z=1 , nScale=1, posx=0 }, tx2={ type=3, z=1, nScale=1, posx=0 } },
    [40136] = { tx1={ type=1, z=1, nScale=1, posx=0 }, mapEffect={ type=6 ,nScale = 1}, particle= "mount_effect" },
}

_G.Cfg.mount_battle={
	[40101]={id=50005,buff=341,icon=40101},
	[40106]={id=50010,buff=341,icon=40106},
	[40111]={id=50015,buff=341,icon=40111},
	[40116]={id=50020,buff=341,icon=40116},
	[40121]={id=50025,buff=341,icon=40121},
	[40126]={id=50030,buff=341,icon=40126},
	[40131]={id=50035,buff=341,icon=40131},
	[40136]={id=50040,buff=341,icon=40136},
}

_G.Cfg.mount_attack={
	[48110]=0.2,
	[48210]=0.2,
	[48310]=0.2,
	[48410]=0.2,
	[48510]=0.2,
	[48610]=0.2,
	[48710]=0.2,
	[48810]=0.2,

}

_G.Cfg.mount_pos=
{
	-- zorder: -1->人物在上层， 1->坐骑在上层
    [10001]={
	-- 小绵羊
	[40101]={ idle_x=0, idle_y=0,  move_x=0,  move_y=0, height=50, zorder=-1, id=50005},
	-- 烈火战车
	[40106]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=20, zorder=-1, id=50010},
	-- 正义先锋
	[40111]={ idle_x=0, idle_y=0,move_x=0,  move_y=0, height=45, zorder=-1, id=50010},
	-- 蝙蝠战车
	[40116]={ idle_x=0, idle_y=0,move_x=0, move_y=0, height=0, zorder=-1, id=50010},
	-- 狂暴蜥蜴
	[40121]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=40, zorder=-1},
	-- 疾风神鹿
	[40126]={ idle_x=0, idle_y=0, move_x=0, move_y=0, height=70, zorder=-1},
	-- 机甲巨兽
	[40131 ]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=40, zorder=-1},
	-- 战斗暴龙
	[40136]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=70, zorder=-1},

    },
    [10002]={
	-- 小绵羊
	[40101]={ idle_x=0, idle_y=0,  move_x=0,  move_y=0, height=30, zorder=-1},
	-- 烈火战车
	[40106]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=20, zorder=-1},
	-- 正义先锋
	[40111]={ idle_x=0, idle_y=0,move_x=0,  move_y=0, height=30, zorder=-1},
	-- 蝙蝠战车
	[40116]={ idle_x=0, idle_y=0,move_x=0, move_y=0, height=-50, zorder=-1},
	-- 狂暴蜥蜴
	[40121]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=20, zorder=-1},
	-- 疾风神鹿
	[40126]={ idle_x=0, idle_y=0, move_x=0, move_y=0, height=70, zorder=-1},
	-- 机甲巨兽
	[40131]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=30, zorder=-1},
	-- 战斗暴龙
	[40136]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=70, zorder=-1},

    },
    [10003]={
	-- 天火赤鹿
	[40101]={ idle_x=0, idle_y=0,  move_x=0,  move_y=0, height=60, zorder=-1},
	-- 踏天龙马
	[40106]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=56, zorder=-1},
	-- 上古灵兔
	[40111]={ idle_x=0, idle_y=0,move_x=0,  move_y=0, height=40, zorder=-1},
	-- 嗜酒熊猫
	[40116]={ idle_x=0, idle_y=0,move_x=0, move_y=0, height=58, zorder=-1},
	-- 九尾玉狐
	[40121]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=45, zorder=-1},
	-- 噬天白虎
	[40126]={ idle_x=0, idle_y=0, move_x=0, move_y=0, height=56, zorder=-1},
	-- 紫炎角兽
	[40131]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=50, zorder=-1},
	-- 霜雪凤凰
	[40136]={ idle_x=0, idle_y=0, move_x=0,  move_y=0, height=85, zorder=-1},

    },
    [10004]={
	-- 天火赤鹿
	[40101]={ idle_x=22, idle_y=25,  move_x=22,  move_y=25, height=60, zorder=-1},
	-- 踏天龙马
	[40106]={ idle_x=0, idle_y=25, move_x=0,  move_y=30, height=60, zorder=-1},
	-- 上古灵兔
	[40111]={ idle_x=15, idle_y=15,move_x=25,  move_y=35, height=40, zorder=-1},
	-- 嗜酒熊猫
	[40116]={ idle_x=0, idle_y=20,move_x=0, move_y=30, height=60, zorder=-1},
	-- 九尾玉狐
	[40121]={ idle_x=12, idle_y=5, move_x=25,  move_y=5, height=40, zorder=-1},
	-- 噬天白虎
	[40126]={ idle_x=0, idle_y=20, move_x=0, move_y=30, height=30, zorder=-1},
	-- 紫炎角兽
	[40131]={ idle_x=-25, idle_y=20, move_x=-15,  move_y=40, height=60, zorder=-1},
	-- 霜雪凤凰
	[40136]={ idle_x=0, idle_y=-1, move_x=-10,  move_y=-1, height=0, zorder=-1},

    },
    [10005]={
	-- 天火赤鹿
	[40101]={ idle_x=22, idle_y=-15,  move_x=22,  move_y=-20, height=51, zorder=-1},
	-- 踏天龙马
	[40106]={ idle_x=0, idle_y=-15, move_x=0,  move_y=-15, height=51, zorder=-1},
	-- 上古灵兔
	[40111]={ idle_x=15, idle_y=-20,move_x=6,  move_y=-20, height=46, zorder=-1},
	-- 嗜酒熊猫
	[40116]={ idle_x=0, idle_y=-35,move_x=0, move_y=-35, height=46, zorder=-1},
	-- 九尾玉狐
	[40121]={ idle_x=12, idle_y=-25, move_x=7,  move_y=-25, height=42, zorder=-1},
	-- 噬天白虎
	[40126]={ idle_x=0, idle_y=-20, move_x=15, move_y=-5, height=51, zorder=-1},
	-- 紫炎角兽
	[40131]={ idle_x=-20, idle_y=-22, move_x=-15,  move_y=-15, height=50, zorder=-1},
	-- 霜雪凤凰
	[40136]={ idle_x=12, idle_y=16, move_x=18,  move_y=10, height=85, zorder=-1},

    },
}

_G.Cfg.feather_pos={
	[10001]={
		[44105]=20,
		[44110]=20,
		[44115]=20,
		[44120]=20,
		[44125]=20,
		[44130]=20,
		[44135]=20,
		[44140]=20,
	},
	[10002]={
		[44105]=20,
		[44110]=20,
		[44115]=20,
		[44120]=20,
		[44125]=20,
		[44130]=20,
		[44135]=20,
		[44140]=20,
	},
	[10003]={
		[44105]=20,
		[44110]=20,
		[44115]=20,
		[44120]=20,
		[44125]=20,
		[44130]=20,
		[44135]=20,
		[44140]=20,
	},
	[10004]={
		[44105]=20,
		[44110]=20,
		[44115]=20,
		[44120]=20,
		[44125]=20,
		[44130]=20,
		[44135]=20,
		[44140]=20,
	},
	[10005]={
		[44105]=20,
		[44110]=20,
		[44115]=20,
		[44120]=20,
		[44125]=20,
		[44130]=20,
		[44135]=20,
		[44140]=20,
	},
}

