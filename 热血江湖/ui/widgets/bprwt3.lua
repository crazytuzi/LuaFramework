--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2261943,
			sizeY = 0.04861111,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "gz2",
				varName = "text",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				text = "规则说明\n1:玩家需要达到70级并且加入帮派才可参与，等级不足或者无帮派者也可进入龙穴地图。\n2:每周一到周六可以参与龙穴任务，且每周可以完成龙穴任务个数有上限。\n3:不同等级的玩家接取的任务可能在不同层次的龙穴，且每次可以接取多个任务。\n4:接取任务后有完成时间限制，如果到时无法完成则需要放弃重新接取新的任务。\n5:每个龙穴任务有积分，积分有个人男女榜和帮派排行榜。周日结算时参与活动的玩家将会获得奖励",
				color = "FFF54516",
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
