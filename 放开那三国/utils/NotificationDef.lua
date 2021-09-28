-- FileName : NotificationDef.lua
-- Author   : YangRui
-- Date     : 2015-12-30
-- Purpose  : 通知key的定义文件

module("NotificationDef", package.seeall)

-- 吃烧鸡
kChickenTab = {
	-- 中午吃鸡腿
	ChickenEnergyNoon    = "chicken_energy_key_noon",
	-- 晚上吃鸡腿
	ChickenEnergyEvening = "chicken_energy_key_evening",
	-- 夜宵吃烧鸡
	ChickenEnergyNight   = "chicken_energy_key_night",
}
-- 体力回满
kEnergyRestoreTab = {
	-- 体力回复满
	EnergyRestoreFull = "key_energy_restore_full",
}
-- 长时间未登录
kLongTimeTab = {
	-- 长时间未登录通知
	LongTimeNoSee = "key_long_time_no_see",
}
-- 世界Boss
kWorldBossTab = {
	-- 世界boss开始通知
	StartWorldBoss = "key_start_world_boss",
}
-- 城池资源战
kCityTab = {
	-- 城池资源战报名推送
	CityResWarSign  = "key_city_resources_war_sign",
	-- 城池资源战进入战场推送
	CityResWarEnter = "key_city_resources_war_enter",
}
-- 擂台赛
kOlympicTab = {
	-- 擂台赛报名推送
	OlympicReg      = "key_olympic_register",
	-- 擂台赛4强推送
	OlympicFour     = "key_olympic_four",
	-- 擂台赛冠军推送
	OlympicChampion = "key_olympic_champion",
}
-- 跨服赛
kLordWarTab = {
	-- 跨服赛开始报名
	Register      = "kufu_" .. 2,
	-- 服内海选赛开始
	InnerAudition = "kufu_" .. 3,
	-- 服内16强晋级赛开始
	Inner32To16   = "kufu_" .. 4,
	-- 服内8强晋级赛开始
	Inner16To8    = "kufu_" .. 5,
	-- 服内4强晋级赛开始
	Inner8To4     = "kufu_" .. 6,
	-- 服内半决赛开始
	Inner4To2     = "kufu_" .. 7,
	-- 服内决赛开始
	Inner2To1     = "kufu_" .. 8,
	-- 服内产生冠军
	InnerWinner   = "kufu_" .. 100,
	-- 跨服海选赛开始
	CrossAudition = "kufu_" .. 9,
	-- 跨服16强晋级赛开始
	Cross32To16   = "kufu_" .. 10,
	-- 跨服8强晋级赛开始
	Cross16To8    = "kufu_" .. 11,
	-- 跨服4强晋级赛开始
	Cross8To4     = "kufu_" .. 12,
	-- 跨服半决赛开始
	Cross4To2     = "kufu_" .. 13,
	-- 跨服决赛开始
	Cross2To1     = "kufu_" .. 14,
	-- 跨服产生冠军
	CrossWinner   = "kufu_" .. 101,
}
