--[[
  JiaYuan
  WangShuai
]]

_G.HomesteadConsts = {};

HomesteadConsts.MainBuild = "MainBuild"; 		-- 主建筑
HomesteadConsts.XunxianBuild = "XunxianBuild"; 	-- 寻仙台
HomesteadConsts.ZongmengBuild = "ZongmengBuild"	-- 宗门任务
HomesteadConsts.julingwan = "julingwan"	-- 聚灵碗

HomesteadConsts.MainViewWH = {
	width = 900,
	height = 500,
}

HomesteadConsts.CompareList = {
	[1] = HomesteadConsts.MainBuild,
	[2] = HomesteadConsts.XunxianBuild,
	[3] = HomesteadConsts.ZongmengBuild,
	[4] = HomesteadConsts.julingwan,
}

HomesteadConsts.CompareServerList = {
	[HomesteadConsts.MainBuild] = 1,
	[HomesteadConsts.XunxianBuild] = 2,
	[HomesteadConsts.ZongmengBuild] = 3,
	[HomesteadConsts.julingwan] = 4,
}

-- 自定义，弹出窗口显示内容
HomesteadConsts.BuildWindow = {
	[HomesteadConsts.MainBuild] = {
		name = HomesteadConsts.MainBuild,
		lenght = 2,
		desc = {"升级","弟子"},
		uilist = {
			[1] = "UIHomesBuildLvlUp",
			[2] = "",
		},
	},
	[HomesteadConsts.XunxianBuild] = {
		name = HomesteadConsts.XunxianBuild,
		lenght = 2,
		desc = {"升级","招募"},
		uilist = {
			[1] = "UIMainXunxian",
			[2] = "",
		},
	},
	[HomesteadConsts.ZongmengBuild] = {
		name = HomesteadConsts.ZongmengBuild,
		lenght = 2,
		desc = {"升级","任务"},
		uilist = {
			[1] = "UIHomesMainQuest",
			[2] = "",
		},
	},
	[HomesteadConsts.julingwan] = {
		name = HomesteadConsts.julingwan,
		lenght = 1,
		desc = {"聚灵","窗口"},
		uilist = {
			[1] = "UILingLiHuiZhangView",
			[2] = "",
		},
	},
};
