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
			name = "jnj1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7453125,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "jnm1",
				varName = "selectName",
				posX = 0.25,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5,
				sizeY = 1,
				text = "上次登入：",
				color = "FF745226",
				fontSize = 24,
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd",
				posX = 0.75,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zts1",
					posX = 0.1687678,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07966457,
					sizeY = 0.7799999,
					image = "fwq#baoman",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jnm2",
						posX = 3.325269,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.180966,
						sizeY = 1,
						text = "-爆满",
						color = "FF745226",
						fontSize = 22,
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zts2",
					posX = 0.4523686,
					posY = 0.5000001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07966457,
					sizeY = 0.7799999,
					image = "fwq#new",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jnm3",
						posX = 3.325269,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.180966,
						sizeY = 1,
						text = "-新服",
						color = "FF745226",
						fontSize = 22,
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zts3",
					posX = 0.7359694,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07966457,
					sizeY = 0.7799999,
					image = "fwq#weihu",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jnm4",
						posX = 3.325269,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 4.180966,
						sizeY = 1,
						text = "-维护",
						color = "FF745226",
						fontSize = 22,
						fontOutlineSize = 2,
						vTextAlign = 1,
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
