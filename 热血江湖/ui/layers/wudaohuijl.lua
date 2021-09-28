--version = 1
local l_fileType = "layer"

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
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "jia",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.6094829,
					posY = 0.497853,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6615281,
					sizeY = 0.8447595,
					image = "wdhbj2#wdhbj2",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn",
						posX = 0.5001569,
						posY = 0.05718518,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.000684,
						sizeY = 0.1048074,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "das",
					posX = 0.6094288,
					posY = 0.4610078,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6470147,
					sizeY = 0.5948082,
					image = "wdh#db",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ye1",
					varName = "tab1",
					posX = 0.3559664,
					posY = 0.1217686,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1420555,
					sizeY = 0.07423194,
					image = "wdh#fy2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					imageNormal = "wdh#fy2",
					imagePressed = "wdh#fy1",
					imageDisable = "wdh#fy2",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8468764,
						sizeY = 0.9547563,
						text = "锦标赛奖励",
						color = "FFD55500",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ye2",
					varName = "tab2",
					posX = 0.514792,
					posY = 0.1217686,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1762204,
					sizeY = 0.07423194,
					image = "wdh#fy2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					imageNormal = "wdh#fy2",
					imagePressed = "wdh#fy1",
					imageDisable = "wdh#fy2",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8468764,
						sizeY = 0.9547563,
						text = "本服个人荣誉奖",
						color = "FFD55500",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dw",
					varName = "myTeam",
					posX = 0.8776544,
					posY = 0.1227032,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1121106,
					sizeY = 0.08165514,
					image = "bpz#hh",
					imageNormal = "bpz#hh",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zdz",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8393403,
						sizeY = 0.7905699,
						text = "我的战队",
						color = "FF6A3514",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFF3D26C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.6099309,
					posY = 0.4615262,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6426169,
					sizeY = 0.5869533,
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
