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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.234375,
			sizeY = 0.06944445,
			alphaCascade = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dms",
				posX = 0.5619683,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8627296,
				sizeY = 0.6399999,
				image = "h#dpsd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "LoadingBar",
				name = "jdt",
				varName = "bar",
				posX = 0.5736157,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8394332,
				sizeY = 0.6399999,
				image = "zd#dps",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wc",
				varName = "rank",
				posX = 0.2586261,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1729666,
				sizeY = 1.386983,
				text = "50",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wc2",
				varName = "name",
				posX = 0.5746782,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.624184,
				sizeY = 1.386983,
				text = "名字四五个字",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wc3",
				varName = "damage",
				posX = 0.891688,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3875629,
				sizeY = 1.386983,
				text = "888.2w",
				color = "FFC31C1C",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "txd",
				varName = "head_bg",
				posX = 0.08066202,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.175862,
				sizeY = 0.8999999,
				image = "zdtx#txd",
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "head_icon",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7210885,
					sizeY = 1.110169,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
