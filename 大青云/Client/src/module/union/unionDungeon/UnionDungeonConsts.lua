_G.UnionDungeonConsts = {};

UnionDungeonConsts.NumDungeonsOnePage = 3; --一页显示3个帮派副本

-- 帮派副本标签页的子标签页
UnionDungeonConsts.TabList = "TabList"; --副本总览界面作子标签页处理
UnionDungeonConsts.TabHell = "TabHell";
UnionDungeonConsts.WarActi = "WarActi";
UnionDungeonConsts.CityWarActi = "CityWarActi";
UnionDungeonConsts.UnionBossActi = "UnionBossActi";
UnionDungeonConsts.UnionDiGongActi = "UnionDiGongActi";

-- 帮派副本对应表 id = [tabName]
UnionDungeonConsts.UnionDungeonMap = {
	[1] = UnionDungeonConsts.TabHell;
	[2] = UnionDungeonConsts.WarActi;
	[3] = UnionDungeonConsts.CityWarActi;
	[4] = UnionDungeonConsts.UnionBossActi;
	[5] = UnionDungeonConsts.UnionDiGongActi;
}

-- 帮派副本规则说明 id = [ruleStr]
UnionDungeonConsts.RuleMap = {
	[1] = StrConfig['union403'],
	[2] = StrConfig['union404'],
	[3] = StrConfig['union405'],
	[4] = StrConfig['union407'],
	[5] = StrConfig['union408'],
}

-- 帮派副本ID
UnionDungeonConsts.ID_Hell = 1
UnionDungeonConsts.ID_WarActi = 2
UnionDungeonConsts.ID_DiGong = 5