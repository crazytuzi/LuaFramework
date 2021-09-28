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
			name = "sss",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0828125,
			sizeY = 0.1303402,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djd",
				varName = "rank",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8867924,
				sizeY = 1.001652,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.4999913,
					posY = 0.5212367,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8071734,
					sizeY = 0.8284316,
					image = "items#xueping1.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo2",
					varName = "itemLock",
					posX = 0.219095,
					posY = 0.2364059,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.3723404,
					sizeY = 0.3723405,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hs",
					posX = 0.4999909,
					posY = 0.5212369,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8071734,
					sizeY = 0.8284316,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "aa1",
					varName = "count",
					posX = 0.4946668,
					posY = 0.3182163,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8284188,
					sizeY = 0.4566891,
					text = "1000",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 2,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dj",
					varName = "itemBtn",
					posX = 0.5001239,
					posY = 0.505312,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.136436,
					sizeY = 0.9240141,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
