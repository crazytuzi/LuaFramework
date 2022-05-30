
PartnersummonConst = PartnersummonConst or {}

PartnersummonConst.God_Effect_Id = 
{
	[50002] = 600,
	[50004] = 601,
}

PartnersummonConst.God_Bg_Id = 
{
	[50002] = 100,
	[50004] = 200,
}

PartnersummonConst.Summon_Type = {
	Normal = 100, 	-- 普通召唤
	Friend = 200, 	-- 友情召唤
	Advanced = 300, -- 高级召唤
	Score = 400, 	-- 积分召唤
}

-- 服务端给的召唤卡库数据类型定义
PartnersummonConst.Recruit_Key = {
	Free_Count = 4, -- 当前可以免费刷新次数
	Free_Time = 5,  -- 下次免费刷新时间
}

-- 召唤按钮状态
PartnersummonConst.Status = {
	Free = 1, -- 免费召唤
	Item = 2, -- 道具召唤
	Gold = 3, -- 钻石召唤
	special = 4, -- 特殊道具召唤
}

PartnersummonConst.Gain_Show_Type = {
	Common_Show  = 1,    -- 普通召唤显示
	Skin_show    = 2,    -- 皮肤召唤显示
}

PartnersummonConst.Good_Bg = {
	[100] = "partnersummon_image_5",
	[200] = "partnersummon_image_6",
	[300] = "partnersummon_image_7",
}

PartnersummonConst.Gain_Skill_Pos = {
	[1] = {{x = 368, y = 327}},
	[2] = {{ x = 270, y = 327 }, { x = 466, y = 327 }},
	[3] = {{ x = 170, y = 327 }, { x = 368, y = 327 }, { x = 566, y = 327 }},
	[4] = {{ x = 66, y = 327 }, {x = 262, y = 327}, { x = 458, y = 327 }, { x = 654, y = 327 }}
}

PartnersummonConst.Normal_Id = 10401    -- 普通召唤道具
PartnersummonConst.Advanced_special_Id = 10409	-- 特权订阅高级召唤道具
PartnersummonConst.Advanced_Id = 10403	-- 高级召唤道具

PartnersummonConst.Outline_Color_1 = cc.c4b(88, 38, 29, 255) -- 5星金色UI文字描边颜色
PartnersummonConst.Outline_Color_2 = cc.c4b(46, 47, 55, 255) -- 4星灰色UI文字描边颜色