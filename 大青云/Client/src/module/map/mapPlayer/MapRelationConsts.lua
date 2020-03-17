--[[
地图需显示图标的玩家:常量
2015年6月5日11:41:40
haohu
]]

_G.MapRelationConsts = {}

--------------------------------地图玩家类型----------------------------

MapRelationConsts.TeamCaptain = 1 -- 队长1
MapRelationConsts.Teammate    = 2 -- 队员2
MapRelationConsts.Gangster    = 3 -- 帮主3
MapRelationConsts.Gang        = 4 -- 帮派成员4
MapRelationConsts.BCJ         = 5 -- 北仓界高分成员
MapRelationConsts.DG_Flag     = 6 -- 帮派地宫旗帜

-- 有重叠身份时,地图图标的优先级, 数字越大越优先
MapRelationConsts.Priority = {
	[ MapRelationConsts.BCJ ]         = 1, -- 北仓界
	[ MapRelationConsts.Gang ]        = 2, -- 帮派成员4
	[ MapRelationConsts.Gangster ]    = 3, -- 帮主3
	[ MapRelationConsts.Teammate ]    = 4, -- 队员2
	[ MapRelationConsts.TeamCaptain ] = 5, -- 队长1
	[ MapRelationConsts.DG_Flag ]     = 6, -- 地宫旗帜
}