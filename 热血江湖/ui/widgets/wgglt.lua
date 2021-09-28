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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.2101562,
			sizeY = 0.1313477,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "ab",
				varName = "bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zz",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "wg2#jnd",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "skill_name",
					posX = 0.6473348,
					posY = 0.5215794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6482524,
					sizeY = 0.6977946,
					text = "武功名字",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "s",
					varName = "skill_score",
					posX = 0.8813606,
					posY = 0.5215798,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.206775,
					sizeY = 0.6066844,
					image = "pf#you",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnk",
				posX = 0.1697024,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2901338,
				sizeY = 0.7401898,
				image = "jn#jnbai",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "skill_icon",
				posX = 0.1697024,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2112719,
				sizeY = 0.5815777,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "select_icon",
				posX = 0.5079597,
				posY = 0.5335994,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9787444,
				sizeY = 0.9750987,
				image = "h#xzk",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.9886054,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06836771,
					sizeY = 0.2385718,
					image = "chu1#jt2",
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
