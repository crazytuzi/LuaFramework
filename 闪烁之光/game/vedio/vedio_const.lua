VedioConst = VedioConst or {}

VedioConst.Tab_Index = {
	Arena = 1,     -- 竞技场
	Champion = 2,  -- 冠军赛
	Solo = 3, 	   -- 切磋
	Guildwar = 4,  -- 公会战
	Ladder = 5,    -- 天梯
	Elite = 6, 	   -- 段位赛
	Crosschampion = 7, -- 周冠军赛
	Newhero = 97,  -- 新英雄集锦
	Hot = 98, 	   -- 每周热门
}

VedioConst.Color = {
	Atk = cc.c3b(168, 46, 26),
	Def = cc.c3b(39,134,188)
}

VedioConst.Cham_Name = {
	[2] = TI18N("决赛"),
	[4] = TI18N("半决赛"),
	[8] = TI18N("8强赛"),
	[16] = TI18N("16强赛"),
	[32] = TI18N("32强赛"),
	[64] = TI18N("64强赛"),
	[128] = TI18N("选拔赛"),
	[256] = TI18N("选拔赛"),
}

-- 个人录像类型
VedioConst.MyVedio_Type = {
	Myself = 1,    -- 我自己的录像记录
	Collect = 99,  -- 我收藏的录像记录
}

-- 录像大厅一次请求的数据量
VedioConst.ReqVedioDataNum = 30

-- 左侧英雄站位转换(显示的index转为服务端数据的index)
--[[
服务端pos:
	9,6,3
	8,5,2
	7,4,1
]]
VedioConst.Left_Role_Battle_Index = {
	[1] = 9,
	[2] = 6,
	[3] = 3,
	[4] = 8,
	[5] = 5,
	[6] = 2,
	[7] = 7,
	[8] = 4,
	[9] = 1,
}

-- 右侧英雄站位转换(显示的index转为服务端数据的index)
--[[
服务端pos:
	3,6,9
	2,5,8
	1,4,7
]]
VedioConst.Right_Role_Battle_Index = {
	[1] = 3,
	[2] = 6,
	[3] = 9,
	[4] = 2,
	[5] = 5,
	[6] = 8,
	[7] = 1,
	[8] = 4,
	[9] = 7,
}


--分享按钮类型
VedioConst.Share_Btn_Type = {
	eGuildBtn = 1, --公会分享
	eWorldBtn = 2, --世界分享
	eCrossBtn = 3, --跨服分享
}

