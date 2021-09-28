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
			name = "fk1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4484811,
			sizeY = 0.1539118,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "fs1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "huigui#dt",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "plcs2",
				varName = "btn",
				posX = 0.7582601,
				posY = 0.3409638,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.309947,
				sizeY = 0.4670691,
				image = "chu1#an1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "chu1#an1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ys4",
					varName = "scoreText",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9499696,
					sizeY = 0.9310579,
					text = "10积分",
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk1",
				varName = "award1",
				posX = 0.1020842,
				posY = 0.5154204,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1393593,
				sizeY = 0.7219142,
				image = "huigui#f",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb1",
					varName = "propBg1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8040701,
					sizeY = 0.8040701,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "rank1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.461315,
						sizeY = 1.461315,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp",
							varName = "icon1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8161447,
							sizeY = 0.7434602,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl1",
						varName = "cnt1",
						posX = 0.7109653,
						posY = 0.07662787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn1",
						varName = "btn1",
						posX = 0.5023313,
						posY = 0.5277541,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.159366,
						sizeY = 1.132983,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo1",
					varName = "lock1",
					posX = 0.1710495,
					posY = 0.2075553,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4374999,
					sizeY = 0.4375,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk2",
				varName = "award2",
				posX = 0.2706841,
				posY = 0.5154206,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1393593,
				sizeY = 0.7219142,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb2",
					varName = "propBg2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.928753,
					sizeY = 0.9287531,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "rank2",
						posX = 0.5,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.265137,
						sizeY = 1.265137,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp2",
							varName = "icon2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8161448,
							sizeY = 0.7434601,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "cnt2",
						posX = 0.6572069,
						posY = 0.1334649,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn2",
						varName = "btn2",
						posX = 0.5000004,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.007761,
						sizeY = 0.9943217,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					varName = "lock2",
					posX = 0.2205817,
					posY = 0.2293911,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4374999,
					sizeY = 0.4375,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk3",
				varName = "award3",
				posX = 0.439284,
				posY = 0.5154206,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1393593,
				sizeY = 0.7219142,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb3",
					varName = "propBg3",
					posX = 0.5,
					posY = 0.4821484,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.928753,
					sizeY = 0.9287531,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "rank3",
						posX = 0.5,
						posY = 0.5192207,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.265137,
						sizeY = 1.265137,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp3",
							varName = "icon3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8161448,
							sizeY = 0.7434601,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl3",
						varName = "cnt3",
						posX = 0.6572069,
						posY = 0.1334649,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn3",
						varName = "btn3",
						posX = 0.5,
						posY = 0.519221,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.007761,
						sizeY = 0.9943217,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo3",
					varName = "lock3",
					posX = 0.1956176,
					posY = 0.2096253,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4374999,
					sizeY = 0.4375,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wk4",
				posX = 0.6078839,
				posY = 0.5154206,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1393593,
				sizeY = 0.7219142,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb4",
					varName = "propBg4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.928753,
					sizeY = 0.9287531,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj4",
						varName = "rank4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.265137,
						sizeY = 1.265137,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tp4",
							varName = "icon4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8161448,
							sizeY = 0.7434601,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl4",
						varName = "cnt4",
						posX = 0.6572069,
						posY = 0.1334649,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7242897,
						sizeY = 0.3808914,
						text = "x15",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn4",
						varName = "btn4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.007761,
						sizeY = 0.9943217,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo4",
					varName = "lock4",
					posX = 0.2330489,
					posY = 0.2273056,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4374999,
					sizeY = 0.4375,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "times",
				posX = 0.7582601,
				posY = 0.7432341,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4713047,
				sizeY = 0.496316,
				text = "剩余兑换次数：10次",
				color = "FFF8B981",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
	gy99 = {
	},
	gy100 = {
	},
	gy101 = {
	},
	gy102 = {
	},
	gy103 = {
	},
	gy104 = {
	},
	gy105 = {
	},
	gy106 = {
	},
	gy107 = {
	},
	gy108 = {
	},
	gy109 = {
	},
	gy110 = {
	},
	gy111 = {
	},
	gy112 = {
	},
	gy113 = {
	},
	gy114 = {
	},
	gy115 = {
	},
	gy116 = {
	},
	gy117 = {
	},
	gy118 = {
	},
	gy119 = {
	},
	gy120 = {
	},
	gy121 = {
	},
	gy122 = {
	},
	gy123 = {
	},
	gy124 = {
	},
	gy125 = {
	},
	gy126 = {
	},
	gy127 = {
	},
	gy128 = {
	},
	gy129 = {
	},
	gy130 = {
	},
	gy131 = {
	},
	gy132 = {
	},
	gy133 = {
	},
	gy134 = {
	},
	gy135 = {
	},
	gy136 = {
	},
	gy137 = {
	},
	gy138 = {
	},
	gy139 = {
	},
	gy140 = {
	},
	gy141 = {
	},
	gy142 = {
	},
	gy143 = {
	},
	gy144 = {
	},
	gy145 = {
	},
	gy146 = {
	},
	gy147 = {
	},
	gy148 = {
	},
	gy149 = {
	},
	gy150 = {
	},
	gy151 = {
	},
	gy152 = {
	},
	gy153 = {
	},
	gy154 = {
	},
	gy155 = {
	},
	gy156 = {
	},
	gy157 = {
	},
	gy158 = {
	},
	gy159 = {
	},
	gy160 = {
	},
	gy161 = {
	},
	gy162 = {
	},
	gy163 = {
	},
	gy164 = {
	},
	gy165 = {
	},
	gy166 = {
	},
	gy167 = {
	},
	gy168 = {
	},
	gy169 = {
	},
	gy170 = {
	},
	gy171 = {
	},
	gy172 = {
	},
	gy173 = {
	},
	gy174 = {
	},
	gy175 = {
	},
	gy176 = {
	},
	gy177 = {
	},
	gy178 = {
	},
	gy179 = {
	},
	gy180 = {
	},
	gy181 = {
	},
	gy182 = {
	},
	gy183 = {
	},
	gy184 = {
	},
	gy185 = {
	},
	gy186 = {
	},
	gy187 = {
	},
	gy188 = {
	},
	gy189 = {
	},
	gy190 = {
	},
	gy191 = {
	},
	gy192 = {
	},
	gy193 = {
	},
	gy194 = {
	},
	gy195 = {
	},
	gy196 = {
	},
	gy197 = {
	},
	gy198 = {
	},
	gy199 = {
	},
	gy200 = {
	},
	gy201 = {
	},
	gy202 = {
	},
	gy203 = {
	},
	gy204 = {
	},
	gy205 = {
	},
	gy206 = {
	},
	gy207 = {
	},
	gy208 = {
	},
	gy209 = {
	},
	gy210 = {
	},
	gy211 = {
	},
	gy212 = {
	},
	gy213 = {
	},
	gy214 = {
	},
	gy215 = {
	},
	gy216 = {
	},
	gy217 = {
	},
	gy218 = {
	},
	gy219 = {
	},
	gy220 = {
	},
	gy221 = {
	},
	gy222 = {
	},
	gy223 = {
	},
	gy224 = {
	},
	gy225 = {
	},
	gy226 = {
	},
	gy227 = {
	},
	gy228 = {
	},
	gy229 = {
	},
	gy230 = {
	},
	gy231 = {
	},
	gy232 = {
	},
	gy233 = {
	},
	gy234 = {
	},
	gy235 = {
	},
	gy236 = {
	},
	gy237 = {
	},
	gy238 = {
	},
	gy239 = {
	},
	gy240 = {
	},
	gy241 = {
	},
	gy242 = {
	},
	gy243 = {
	},
	gy244 = {
	},
	gy245 = {
	},
	gy246 = {
	},
	gy247 = {
	},
	gy248 = {
	},
	gy249 = {
	},
	gy250 = {
	},
	gy251 = {
	},
	gy252 = {
	},
	gy253 = {
	},
	gy254 = {
	},
	gy255 = {
	},
	gy256 = {
	},
	gy257 = {
	},
	gy258 = {
	},
	gy259 = {
	},
	gy260 = {
	},
	gy261 = {
	},
	gy262 = {
	},
	gy263 = {
	},
	gy264 = {
	},
	gy265 = {
	},
	gy266 = {
	},
	gy267 = {
	},
	gy268 = {
	},
	gy269 = {
	},
	gy270 = {
	},
	gy271 = {
	},
	gy272 = {
	},
	gy273 = {
	},
	gy274 = {
	},
	gy275 = {
	},
	gy276 = {
	},
	gy277 = {
	},
	gy278 = {
	},
	gy279 = {
	},
	gy280 = {
	},
	gy281 = {
	},
	gy282 = {
	},
	gy283 = {
	},
	gy284 = {
	},
	gy285 = {
	},
	gy286 = {
	},
	gy287 = {
	},
	gy288 = {
	},
	gy289 = {
	},
	gy290 = {
	},
	gy291 = {
	},
	gy292 = {
	},
	gy293 = {
	},
	gy294 = {
	},
	gy295 = {
	},
	gy296 = {
	},
	gy297 = {
	},
	gy298 = {
	},
	gy299 = {
	},
	gy300 = {
	},
	gy301 = {
	},
	gy302 = {
	},
	gy303 = {
	},
	gy304 = {
	},
	gy305 = {
	},
	gy306 = {
	},
	gy307 = {
	},
	gy308 = {
	},
	gy309 = {
	},
	gy310 = {
	},
	gy311 = {
	},
	gy312 = {
	},
	gy313 = {
	},
	gy314 = {
	},
	gy315 = {
	},
	gy316 = {
	},
	gy317 = {
	},
	gy318 = {
	},
	gy319 = {
	},
	gy320 = {
	},
	gy321 = {
	},
	gy322 = {
	},
	gy323 = {
	},
	gy324 = {
	},
	gy325 = {
	},
	gy326 = {
	},
	gy327 = {
	},
	gy328 = {
	},
	gy329 = {
	},
	gy330 = {
	},
	gy331 = {
	},
	gy332 = {
	},
	gy333 = {
	},
	gy334 = {
	},
	gy335 = {
	},
	gy336 = {
	},
	gy337 = {
	},
	gy338 = {
	},
	gy339 = {
	},
	gy340 = {
	},
	gy341 = {
	},
	gy342 = {
	},
	gy343 = {
	},
	gy344 = {
	},
	gy345 = {
	},
	gy346 = {
	},
	gy347 = {
	},
	gy348 = {
	},
	gy349 = {
	},
	gy350 = {
	},
	gy351 = {
	},
	gy352 = {
	},
	gy353 = {
	},
	gy354 = {
	},
	gy355 = {
	},
	gy356 = {
	},
	gy357 = {
	},
	gy358 = {
	},
	gy359 = {
	},
	gy360 = {
	},
	gy361 = {
	},
	gy362 = {
	},
	gy363 = {
	},
	gy364 = {
	},
	gy365 = {
	},
	gy366 = {
	},
	gy367 = {
	},
	gy368 = {
	},
	gy369 = {
	},
	gy370 = {
	},
	gy371 = {
	},
	gy372 = {
	},
	gy373 = {
	},
	gy374 = {
	},
	gy375 = {
	},
	gy376 = {
	},
	gy377 = {
	},
	gy378 = {
	},
	gy379 = {
	},
	gy380 = {
	},
	gy381 = {
	},
	gy382 = {
	},
	gy383 = {
	},
	gy384 = {
	},
	gy385 = {
	},
	gy386 = {
	},
	gy387 = {
	},
	gy388 = {
	},
	gy389 = {
	},
	gy390 = {
	},
	gy391 = {
	},
	gy392 = {
	},
	gy393 = {
	},
	gy394 = {
	},
	gy395 = {
	},
	gy396 = {
	},
	gy397 = {
	},
	gy398 = {
	},
	gy399 = {
	},
	gy400 = {
	},
	gy401 = {
	},
	gy402 = {
	},
	gy403 = {
	},
	gy404 = {
	},
	gy405 = {
	},
	gy406 = {
	},
	gy407 = {
	},
	gy408 = {
	},
	gy409 = {
	},
	gy410 = {
	},
	gy411 = {
	},
	gy412 = {
	},
	gy413 = {
	},
	gy414 = {
	},
	gy415 = {
	},
	gy416 = {
	},
	gy417 = {
	},
	gy418 = {
	},
	gy419 = {
	},
	gy420 = {
	},
	gy421 = {
	},
	gy422 = {
	},
	gy423 = {
	},
	gy424 = {
	},
	gy425 = {
	},
	gy426 = {
	},
	gy427 = {
	},
	gy428 = {
	},
	gy429 = {
	},
	gy430 = {
	},
	gy431 = {
	},
	gy432 = {
	},
	gy433 = {
	},
	gy434 = {
	},
	gy435 = {
	},
	gy436 = {
	},
	gy437 = {
	},
	gy438 = {
	},
	gy439 = {
	},
	gy440 = {
	},
	gy441 = {
	},
	gy442 = {
	},
	gy443 = {
	},
	gy444 = {
	},
	gy445 = {
	},
	gy446 = {
	},
	gy447 = {
	},
	gy448 = {
	},
	gy449 = {
	},
	gy450 = {
	},
	gy451 = {
	},
	gy452 = {
	},
	gy453 = {
	},
	gy454 = {
	},
	gy455 = {
	},
	gy456 = {
	},
	gy457 = {
	},
	gy458 = {
	},
	gy459 = {
	},
	gy460 = {
	},
	gy461 = {
	},
	gy462 = {
	},
	gy463 = {
	},
	gy464 = {
	},
	gy465 = {
	},
	gy466 = {
	},
	gy467 = {
	},
	gy468 = {
	},
	gy469 = {
	},
	gy470 = {
	},
	gy471 = {
	},
	gy472 = {
	},
	gy473 = {
	},
	gy474 = {
	},
	gy475 = {
	},
	gy476 = {
	},
	gy477 = {
	},
	gy478 = {
	},
	gy479 = {
	},
	gy480 = {
	},
	gy481 = {
	},
	gy482 = {
	},
	gy483 = {
	},
	gy484 = {
	},
	gy485 = {
	},
	gy486 = {
	},
	gy487 = {
	},
	gy488 = {
	},
	gy489 = {
	},
	gy490 = {
	},
	gy491 = {
	},
	gy492 = {
	},
	gy493 = {
	},
	gy494 = {
	},
	gy495 = {
	},
	gy496 = {
	},
	gy497 = {
	},
	gy498 = {
	},
	gy499 = {
	},
	gy500 = {
	},
	gy501 = {
	},
	gy502 = {
	},
	gy503 = {
	},
	gy504 = {
	},
	gy505 = {
	},
	gy506 = {
	},
	gy507 = {
	},
	gy508 = {
	},
	gy509 = {
	},
	gy510 = {
	},
	gy511 = {
	},
	gy512 = {
	},
	gy513 = {
	},
	gy514 = {
	},
	gy515 = {
	},
	gy516 = {
	},
	gy517 = {
	},
	gy518 = {
	},
	gy519 = {
	},
	gy520 = {
	},
	gy521 = {
	},
	gy522 = {
	},
	gy523 = {
	},
	gy524 = {
	},
	gy525 = {
	},
	gy526 = {
	},
	gy527 = {
	},
	gy528 = {
	},
	gy529 = {
	},
	gy530 = {
	},
	gy531 = {
	},
	gy532 = {
	},
	gy533 = {
	},
	gy534 = {
	},
	gy535 = {
	},
	gy536 = {
	},
	gy537 = {
	},
	gy538 = {
	},
	gy539 = {
	},
	gy540 = {
	},
	gy541 = {
	},
	gy542 = {
	},
	gy543 = {
	},
	gy544 = {
	},
	gy545 = {
	},
	gy546 = {
	},
	gy547 = {
	},
	gy548 = {
	},
	gy549 = {
	},
	gy550 = {
	},
	gy551 = {
	},
	gy552 = {
	},
	gy553 = {
	},
	gy554 = {
	},
	gy555 = {
	},
	gy556 = {
	},
	gy557 = {
	},
	gy558 = {
	},
	gy559 = {
	},
	gy560 = {
	},
	gy561 = {
	},
	gy562 = {
	},
	gy563 = {
	},
	gy564 = {
	},
	gy565 = {
	},
	gy566 = {
	},
	gy567 = {
	},
	gy568 = {
	},
	gy569 = {
	},
	gy570 = {
	},
	gy571 = {
	},
	gy572 = {
	},
	gy573 = {
	},
	gy574 = {
	},
	gy575 = {
	},
	gy576 = {
	},
	gy577 = {
	},
	gy578 = {
	},
	gy579 = {
	},
	gy580 = {
	},
	gy581 = {
	},
	gy582 = {
	},
	gy583 = {
	},
	gy584 = {
	},
	gy585 = {
	},
	gy586 = {
	},
	gy587 = {
	},
	gy588 = {
	},
	gy589 = {
	},
	gy590 = {
	},
	gy591 = {
	},
	gy592 = {
	},
	gy593 = {
	},
	gy594 = {
	},
	gy595 = {
	},
	gy596 = {
	},
	gy597 = {
	},
	gy598 = {
	},
	gy599 = {
	},
	gy600 = {
	},
	gy601 = {
	},
	gy602 = {
	},
	gy603 = {
	},
	gy604 = {
	},
	gy605 = {
	},
	gy606 = {
	},
	gy607 = {
	},
	gy608 = {
	},
	gy609 = {
	},
	gy610 = {
	},
	gy611 = {
	},
	gy612 = {
	},
	gy613 = {
	},
	gy614 = {
	},
	gy615 = {
	},
	gy616 = {
	},
	gy617 = {
	},
	gy618 = {
	},
	gy619 = {
	},
	gy620 = {
	},
	gy621 = {
	},
	gy622 = {
	},
	gy623 = {
	},
	gy624 = {
	},
	gy625 = {
	},
	gy626 = {
	},
	gy627 = {
	},
	gy628 = {
	},
	gy629 = {
	},
	gy630 = {
	},
	gy631 = {
	},
	gy632 = {
	},
	gy633 = {
	},
	gy634 = {
	},
	gy635 = {
	},
	gy636 = {
	},
	gy637 = {
	},
	gy638 = {
	},
	gy639 = {
	},
	gy640 = {
	},
	gy641 = {
	},
	gy642 = {
	},
	gy643 = {
	},
	gy644 = {
	},
	gy645 = {
	},
	gy646 = {
	},
	gy647 = {
	},
	gy648 = {
	},
	gy649 = {
	},
	gy650 = {
	},
	gy651 = {
	},
	gy652 = {
	},
	gy653 = {
	},
	gy654 = {
	},
	gy655 = {
	},
	gy656 = {
	},
	gy657 = {
	},
	gy658 = {
	},
	gy659 = {
	},
	gy660 = {
	},
	gy661 = {
	},
	gy662 = {
	},
	gy663 = {
	},
	gy664 = {
	},
	gy665 = {
	},
	gy666 = {
	},
	gy667 = {
	},
	gy668 = {
	},
	gy669 = {
	},
	gy670 = {
	},
	gy671 = {
	},
	gy672 = {
	},
	gy673 = {
	},
	gy674 = {
	},
	gy675 = {
	},
	gy676 = {
	},
	gy677 = {
	},
	gy678 = {
	},
	gy679 = {
	},
	gy680 = {
	},
	gy681 = {
	},
	gy682 = {
	},
	gy683 = {
	},
	gy684 = {
	},
	gy685 = {
	},
	gy686 = {
	},
	gy687 = {
	},
	gy688 = {
	},
	gy689 = {
	},
	gy690 = {
	},
	gy691 = {
	},
	gy692 = {
	},
	gy693 = {
	},
	gy694 = {
	},
	gy695 = {
	},
	gy696 = {
	},
	gy697 = {
	},
	gy698 = {
	},
	gy699 = {
	},
	gy700 = {
	},
	gy701 = {
	},
	gy702 = {
	},
	gy703 = {
	},
	gy704 = {
	},
	gy705 = {
	},
	gy706 = {
	},
	gy707 = {
	},
	gy708 = {
	},
	gy709 = {
	},
	gy710 = {
	},
	gy711 = {
	},
	gy712 = {
	},
	gy713 = {
	},
	gy714 = {
	},
	gy715 = {
	},
	gy716 = {
	},
	gy717 = {
	},
	gy718 = {
	},
	gy719 = {
	},
	gy720 = {
	},
	gy721 = {
	},
	gy722 = {
	},
	gy723 = {
	},
	gy724 = {
	},
	gy725 = {
	},
	gy726 = {
	},
	gy727 = {
	},
	gy728 = {
	},
	gy729 = {
	},
	gy730 = {
	},
	gy731 = {
	},
	gy732 = {
	},
	gy733 = {
	},
	gy734 = {
	},
	gy735 = {
	},
	gy736 = {
	},
	gy737 = {
	},
	gy738 = {
	},
	gy739 = {
	},
	gy740 = {
	},
	gy741 = {
	},
	gy742 = {
	},
	gy743 = {
	},
	gy744 = {
	},
	gy745 = {
	},
	gy746 = {
	},
	gy747 = {
	},
	gy748 = {
	},
	gy749 = {
	},
	gy750 = {
	},
	gy751 = {
	},
	gy752 = {
	},
	gy753 = {
	},
	gy754 = {
	},
	gy755 = {
	},
	gy756 = {
	},
	gy757 = {
	},
	gy758 = {
	},
	gy759 = {
	},
	gy760 = {
	},
	gy761 = {
	},
	gy762 = {
	},
	gy763 = {
	},
	gy764 = {
	},
	gy765 = {
	},
	gy766 = {
	},
	gy767 = {
	},
	gy768 = {
	},
	gy769 = {
	},
	gy770 = {
	},
	gy771 = {
	},
	gy772 = {
	},
	gy773 = {
	},
	gy774 = {
	},
	gy775 = {
	},
	gy776 = {
	},
	gy777 = {
	},
	gy778 = {
	},
	gy779 = {
	},
	gy780 = {
	},
	gy781 = {
	},
	gy782 = {
	},
	gy783 = {
	},
	gy784 = {
	},
	gy785 = {
	},
	gy786 = {
	},
	gy787 = {
	},
	gy788 = {
	},
	gy789 = {
	},
	gy790 = {
	},
	gy791 = {
	},
	gy792 = {
	},
	gy793 = {
	},
	gy794 = {
	},
	gy795 = {
	},
	gy796 = {
	},
	gy797 = {
	},
	gy798 = {
	},
	gy799 = {
	},
	gy800 = {
	},
	gy801 = {
	},
	gy802 = {
	},
	gy803 = {
	},
	gy804 = {
	},
	gy805 = {
	},
	gy806 = {
	},
	gy807 = {
	},
	gy808 = {
	},
	gy809 = {
	},
	gy810 = {
	},
	gy811 = {
	},
	gy812 = {
	},
	gy813 = {
	},
	gy814 = {
	},
	gy815 = {
	},
	gy816 = {
	},
	gy817 = {
	},
	gy818 = {
	},
	gy819 = {
	},
	gy820 = {
	},
	gy821 = {
	},
	gy822 = {
	},
	gy823 = {
	},
	gy824 = {
	},
	gy825 = {
	},
	gy826 = {
	},
	gy827 = {
	},
	gy828 = {
	},
	gy829 = {
	},
	gy830 = {
	},
	gy831 = {
	},
	gy832 = {
	},
	gy833 = {
	},
	gy834 = {
	},
	gy835 = {
	},
	gy836 = {
	},
	gy837 = {
	},
	gy838 = {
	},
	gy839 = {
	},
	gy840 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
