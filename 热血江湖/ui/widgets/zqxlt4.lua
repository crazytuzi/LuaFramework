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
			etype = "Image",
			name = "yblb3",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4009036,
			sizeY = 0.07210371,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "y3",
				posX = 0.2342926,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5256069,
				sizeY = 1.063695,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk4",
					posX = 0.1457027,
					posY = 0.4904726,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1369703,
					sizeY = 0.6690063,
					image = "fj#xz",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "gxan7",
						varName = "select",
						posX = 0.5025076,
						posY = 0.500017,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.062153,
						sizeY = 0.9503471,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "k2",
						varName = "selectImg",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.062153,
						sizeY = 0.9503471,
						image = "chu1#dj",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kkk3",
					posX = 0.7385083,
					posY = 0.4845929,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6265788,
					sizeY = 0.6700305,
					image = "zqxl#di1",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb9",
						varName = "name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.07343,
						sizeY = 1.393533,
						text = "全部属性",
						color = "FFC04000",
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
				etype = "Image",
				name = "dk3",
				posX = 0.8152391,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3581068,
				sizeY = 0.712708,
				image = "zqxl#di1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb10",
					varName = "quality",
					posX = 0.4231418,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.088347,
					sizeY = 1.145833,
					text = "蓝色品质以上",
					color = "FF008080",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dan",
					varName = "list",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0431,
					sizeY = 1.376143,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "xzan3",
						posX = 0.8965913,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1252053,
						sizeY = 0.3731542,
						image = "zqxl#jiantou",
						imageNormal = "zqxl#jiantou",
						disableClick = true,
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
