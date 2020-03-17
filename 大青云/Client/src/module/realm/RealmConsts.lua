--[[
常量
zhangshuhui
2015年4月1日18:31:00
]]

_G.RealmConsts = {};

--挑战时间
RealmConsts.timemax = 300;
--境界等阶上限
RealmConsts.ordermax = #t_jingjie;
--星最高等级
RealmConsts.xingmax = 9;
--巩固等级上限
RealmConsts.strenthenmax = 5;
--巩固消耗道具数量
RealmConsts.toolmax = 3;
--挑战结束后倒计时
RealmConsts.resulttimemax = 30;

--境界突破副本id
RealmConsts.dungeonid = 10340001;

RealmConsts.Attrs = {"att", "def", "hp", "defcri", "cri"};

--一键提示灵石数量
RealmConsts.TOOLMAX = 100;

local realmMaxLvl
function RealmConsts:GetMaxLevel()
	local maxLvl = 0
	if not realmMaxLvl then
		for level, cfg in pairs( _G.t_jingjie ) do
			maxLvl = math.max( level, maxLvl )
		end
		realmMaxLvl = maxLvl
	end
	return realmMaxLvl
end