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
				etype = "Image",
				name = "z2",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
				image = "a",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.6260608,
					posY = 0.4901731,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6629893,
					sizeY = 0.8735304,
					image = "h#d5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
					alpha = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "wz",
						varName = "text",
						posX = 0.5,
						posY = 0.5301992,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4696533,
						sizeY = 0.3089187,
						text = "此活动尚未开放",
						color = "FF43261D",
						fontSize = 26,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.7023053,
						posY = 0.240154,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.638692,
						sizeY = 0.470785,
						image = "hua1#hua1",
					},
				},
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
