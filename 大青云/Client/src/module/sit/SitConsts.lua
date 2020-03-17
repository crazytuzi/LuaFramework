--[[
打坐 常量定义
郝户
2014年11月11日22:04:57
]]

_G.SitConsts = {};

-- 打坐操作
SitConsts.Oper_Leave = 0;
SitConsts.Oper_Join = 1;

-- 打坐状态
SitConsts.NoneSit  = 0; -- 未打坐
SitConsts.OneSit   = 1; -- 一人打坐
SitConsts.TwoSit   = 2; -- 两仪阵
SitConsts.ThreeSit = 3; -- 三才阵
SitConsts.FourSit  = 4; -- 四象阵

--打坐阵表 [人数] = 打坐阵法名称
SitConsts.FormationMap = {
	[1] = StrConfig['sit001'],
	[2] = StrConfig['sit002'],
	[3] = StrConfig['sit003'],
	[4] = StrConfig['sit004']
}

-- 打坐阵宽高常量
SitConsts.FormationW = 20;
SitConsts.FormationH = 20;

--自动打坐时间
SitConsts.AutoSitTime = 60000;

-- 主城打坐区加成
local majorCityBonus
function SitConsts:GetMajorCityBonus()
	if not majorCityBonus then
		majorCityBonus = t_consts[67].val1
	end
	return majorCityBonus
end

-- 主城打坐区坐标点, 半径
local sitAreaPos
function SitConsts:GetSitAreaPos()
	if not sitAreaPos then
		sitAreaPos = {}
		local configStr = t_consts[67].param
		local t = _G.split( configStr, "#" )
		local t1 = _G.split( t[1], "," )
		local t2 = _G.split( t[2], "," )
		sitAreaPos.x  = tonumber( t1[1] ) -- x坐标
		sitAreaPos.y  = tonumber( t1[2] ) -- y坐标
		sitAreaPos.r  = tonumber( t2[1] ) -- 环形大半径
		sitAreaPos.ri = tonumber( t2[2] ) -- 环形小半径
	end
	return sitAreaPos
end

-- 请求附近打坐最小间隔 1分钟
SitConsts.QueryNearbySitInterval = 60000