--[[
排行榜 
wangshuai
]]

_G.RankListConsts = {};

RankListConsts.LvlRank = 1;  -- 等级
RankListConsts.FigRank = 2;  -- 战力
RankListConsts.ZuoRank = 3;  -- 坐骑
RankListConsts.jingJie = 4;  -- 境界
--RankListConsts.Lingshou = 5;  -- 灵兽
-- RankListConsts.LingZhen = 6;  -- 灵阵
--RankListConsts.JixianBoss = 7;  -- 极限挑战boss
--RankListConsts.JixianMonster = 8;  -- 极限挑战monster
RankListConsts.Shengbing = 9;  -- 神兵
RankListConsts.LingQi = 10; --法宝
RankListConsts.Armor = 11; --宝甲
RankListConsts.MingYu = 12;	--玉佩
--RankListConsts.NewTianShen = 13;	--天神

RankListConsts.AllRankNum = 13;
RankListConsts.ranline=3 --显示模型
-- 排行榜文字坐标信息
RankListConsts.TabPage={
	[1] = "200,390,555",--StrConfig["ranktab001"],
	[2] = "200,360,440,555",--StrConfig["ranktab002"],
	[3] = "200,400,550",--StrConfig["ranktab003"],
	[4] = "180,380,550",--StrConfig["ranktab003"],
	-- [5] = "180,380,550",--StrConfig["ranktab003"],
	-- [6] = "180,380,550",--StrConfig["ranktab003"],
	-- [7] = "180,380,550",--StrConfig["ranktab003"],
	-- [8] = "180,380,550",--StrConfig["ranktab003"],
	-- [9] = "180,380,550",--StrConfig["ranktab003"],
	[9] = "200,400,550",
	[10] = "200,400,550",
	[11] = "200,400,550",
	[12] = "200,400,550",
	--[13] = "200,400,550",
}

RankListConsts.RankName={
	[1] = "firstLvlName",
	[2] = "firstPowerName",
	[3] = "firstMountName",
	[4] = "firstJingjiName",
	[9] = "firstShengbingName",
	[10] = "firstLingQiName",
	[11] = "firstArmorName",
	[12] = "firstMingYuName",
	--[13] = "firstTianShenName",
	--[5] = "lingshouName",
	-- [6] = "lingzhenName",
	--[7] = "jxtzBossName",
	--[8] = "jxtzMonsterName",
}

-- 显示顺序 
RankListConsts.OpenOrder = {
							[1] = RankListConsts.ZuoRank,
							[2] = RankListConsts.FigRank,
							[3] = RankListConsts.LvlRank,
							[4] = RankListConsts.jingJie,
							[5] = RankListConsts.Shengbing,
							[6] = RankListConsts.LingQi,
							[7] = RankListConsts.Armor,
							[8] = RankListConsts.MingYu,
							--[9] = RankListConsts.NewTianShen,
							--[5] = RankListConsts.Lingshou,
							-- [6] = RankListConsts.LingZhen,
							--[7] = RankListConsts.JixianBoss,
							--[8] = RankListConsts.JixianMonster,
							-- [9] = RankListConsts.Shengbing,
}

-- item显示顺序 
RankListConsts.itemOpenOrder = {
							[1] = RankListConsts.FigRank,
							[2] = RankListConsts.LvlRank,
							[3] = RankListConsts.ZuoRank,
							[4] = RankListConsts.jingJie,
							[9] = RankListConsts.Shengbing,
							[10] = RankListConsts.LingQi,
							[11] = RankListConsts.Armor,
							[12] = RankListConsts.MingYu,
							--[13] = RankListConsts.NewTianShen,
							--[5] = RankListConsts.Lingshou,
							-- [6] = RankListConsts.LingZhen,
							-- [7] = RankListConsts.Shengbing,
							--[8] = RankListConsts.JixianBoss,
							--[9] = RankListConsts.JixianMonster,
}

RankListConsts.RanklistOpenLvl = 90;--排行榜开启等级
RankListConsts.RankAllServerOpenLvl = 230;--跨服排行榜开启等级