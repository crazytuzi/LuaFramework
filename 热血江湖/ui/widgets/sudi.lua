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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.734375,
			sizeY = 0.7027778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "haoyou",
				varName = "ShouChong",
				posX = 0.5,
				posY = 0.4384252,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8768503,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "sudi_scroll",
					posX = 0.5,
					posY = 0.5029584,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.988269,
					sizeY = 0.9687634,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "msd",
					varName = "msd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4265957,
					sizeY = 0.859331,
					image = "hw1#hw1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "msdz",
						varName = "desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.643701,
						sizeY = 0.5920502,
						text = "没有任何宿敌",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "yq1",
				varName = "sudi",
				posX = 0.1144637,
				posY = 0.9379995,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1638298,
				sizeY = 0.1146245,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "yqz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.816794,
					sizeY = 0.9236839,
					text = "宿 敌",
					color = "FF966856",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "yq2",
				varName = "heimingdan",
				posX = 0.2836079,
				posY = 0.9379995,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1638298,
				sizeY = 0.1146245,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "yqz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.816794,
					sizeY = 0.9236839,
					text = "黑名单",
					color = "FF966856",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "gxd",
				varName = "blackListAutoDel",
				posX = 0.5063726,
				posY = 0.9380138,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03191489,
				sizeY = 0.05928854,
				image = "chu1#gxd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "autoDelMark",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.266667,
					sizeY = 1.133333,
					image = "chu1#dj",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gxan",
					varName = "autoDel",
					posX = 0.9822711,
					posY = 0.5125865,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.494702,
					sizeY = 1.422866,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "gxwz",
					varName = "autoDelDesc",
					posX = 8.187115,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 13.24537,
					sizeY = 2.720722,
					text = "自动删除连续14天未登录的宿敌",
					color = "FF966856",
					vTextAlign = 1,
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
