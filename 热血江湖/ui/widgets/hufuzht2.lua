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
			sizeX = 0.2442599,
			sizeY = 0.04583333,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "jie",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "wz6",
					varName = "text",
					posX = 0.5,
					posY = -0.1666662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9725934,
					sizeY = 2,
					text = "1.请选择一个灵符进行祭炼\n2.已装备的灵符若需祭炼请先放入背包\n3.祭炼功能可以将灵符提升为更高级的灵符，属性将大幅提升\n4.祭炼成功后，灵符的附加属性将重新随机\n5.祭炼后，灵符必然为绑定的\n6.当前祭炼最高10级\n7.灵符即将开放淬锋功能\n8.灵符即将开启传世功能（祭炼会继承传世属性）",
					color = "FF714730",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FFEFD4B4",
				},
			},
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
