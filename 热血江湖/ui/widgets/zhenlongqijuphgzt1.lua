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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6762072,
			sizeY = 0.05150977,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "smz",
				varName = "des",
				posX = 0.5170025,
				posY = 1.792131,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9659908,
				sizeY = 6.514479,
				text = "<c=blue>珍珑棋局活动规则</c>\n\n1:活动开启后可以在<c=green>南林湖天衣</c>处接取任务。\n2:任务共十轮，每轮的奖励略有提升。\n3:每完成一个任务会获得<c=purple>棋力值</c>，在达到一定轮次时，接取任务将会消耗部分<c=purple>棋力值</c>。\n4:本次活动未消耗的<c=purple>棋力值</c>将会累积到下次活动。\n5:当玩家做满十轮任务或<c=purple>棋力值</c>不足时，任务结束。\n6:活动结束后，根据玩家所达到的任务轮次及当次活动所获得的棋力值进行排名；并根据对应排名获得奖励。\n7:活动获得的道具，可以在<c=green>南林湖天衣</c>处兑换丰厚奖励。",
				color = "FF966856",
				vTextAlign = 1,
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
