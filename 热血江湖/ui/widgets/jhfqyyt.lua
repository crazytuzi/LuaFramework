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
			sizeX = 0.2085938,
			sizeY = 0.08194444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.006528,
				sizeY = 0.8528657,
				image = "ty#sld2",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "name",
					posX = 0.371,
					posY = 0.5000454,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3242579,
					sizeY = 0.9195436,
					text = "气血",
					color = "FF634624",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.5148532,
					posY = 0.4736842,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1113974,
					sizeY = 0.7730521,
					image = "cl2#yjt",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "szz",
					varName = "value",
					posX = 0.8037451,
					posY = 0.5000141,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3415465,
					sizeY = 0.8144314,
					text = "28000",
					color = "FF634624",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "icon",
					posX = 0.1202461,
					posY = 0.5058897,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1819491,
					sizeY = 0.9712706,
					image = "zt#qixue",
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
