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
			name = "k1",
			posX = 0.5,
			posY = 0.4760808,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.775,
			sizeY = 0.678747,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "wz",
				varName = "text",
				posX = 0.5180221,
				posY = 0.9627392,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9639558,
				sizeY = 0.1031687,
				text = "竞技场规则：",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FF2E1410",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz1",
				posX = 0.5186178,
				posY = 0.860594,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.1432378,
				text = "1、竞技场战斗模式分手动/自动模式，均可设置；自动攻击，玩家、佣兵可以自动释放武功，但宠物不会主动释放大招，神兵武功不会主动释放。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz2",
				posX = 0.5186178,
				posY = 0.7173562,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.1432378,
				text = "2、竞技场默认为自动，10秒后播放倒计时前置动画，此期间不可移动和释放武功，玩家在10秒之内没有设定攻击模式，则预设为自动攻击模式。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz3",
				posX = 0.5186178,
				posY = 0.6099278,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "3、竞技场中，玩家需要进行防守阵容的布阵，提高防守阵容可以有效的保护自己的排名。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz4",
				posX = 0.5186177,
				posY = 0.538309,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "4、每个玩家每天的挑战次数为10次，每天5:00重置。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz5",
				posX = 0.5186178,
				posY = 0.4666906,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "5、玩家每天挑战时间间隔为5分钟。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz6",
				posX = 0.5186178,
				posY = 0.3950717,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "6、竞技场每次显示4个对手，通过“换一换”按钮刷新对手。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz7",
				posX = 0.5186178,
				posY = 0.2876433,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.1432378,
				text = "7、竞技场每次战斗，胜利获得3点积分，失败获得1点积分，每天通过累积积分换取竞技场积分奖励。每日积分在5：00重置。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz8",
				posX = 0.5186178,
				posY = 0.1802157,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "8、竞技场中，挑战高于自己排名的玩家成功后，排名互换。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz9",
				posX = 0.5186178,
				posY = 0.1085964,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "9、竞技场挑战有时间限制，进攻方在规定时间内无法击败防守方，则判定进攻失败。",
				color = "FF43261D",
				fontSize = 22,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "gz10",
				posX = 0.5186178,
				posY = 0.03697727,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9510571,
				sizeY = 0.07161889,
				text = "10、竞技场每日排名结算时间为21：00；根据当日最终排名发放奖励。",
				color = "FF43261D",
				fontSize = 22,
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
