
--定义和SDK相关的平台Id
local AllPlatforms = {
	Demo = 0,

	--Android
	happyos             = 101, --嗨皮欧 北美 101
	mojing_102 			= 102, --魔鲸 欧洲 102
	mojing_103 			= 103, --魔鲸 欧洲 103
    mojing_104          = 104,
    mojing_105          = 105,
    mojing_106          = 106,
    mojing_107          = 107,
    mojing_108          = 108,
    mojing_109          = 109,
    mojing_110          = 110,
    mojing_111          = 111,
    mojing_112          = 112,
    mojing_113          = 113,
    mojing_114          = 114,
    mojing_115          = 115,
    mojing_116          = 116,
    mojing_117          = 117,
	mojing_120          = 120,
	mojing_121          = 121,
	mojing_122          = 122,
	mojing_123          = 123,
    mojing_125          = 125,
    mojing_126          = 126,
	mojing_1124          = 1124,
	mojing_1127          = 1127,
	mojing_1128          = 1128,
	mojing_1129          = 1129,
	yingpai               = 201, --国内安卓 硬派
	xinxin               = 202, --国内安卓 欣欣
	funcat               = 203, --国内BT

	--iOS
	mojing_301          = 301, --魔鲸 ios 301
	mojing_302 			= 302, --魔鲸 ios 302
	mojing_303 			= 303, --魔鲸 ios 303
	mojing_304 			= 304, --魔鲸 ios 304
	mojing_305 			= 305, --魔鲸 ios 305
	mojing_306 			= 306, --魔鲸 ios 306
	mojing_307 			= 307, --魔鲸 ios 307
	mojing_308 			= 308, --魔鲸 ios 308
	mojing_309 			= 309, --魔鲸 ios 309
	mojing_311 			= 311, --魔鲸 ios 311
	mojing_312 			= 312, --魔鲸 ios 312
	mojing_313 			= 313, --魔鲸 ios 313
	mojing_314 			= 314, --魔鲸 ios 314
	mojing_315 			= 315, --魔鲸 ios 315
	mojing_316 			= 316, --魔鲸 ios 316
	mojing_317 			= 317, --魔鲸 ios 317
	mojing_318 			= 318, --魔鲸 ios 318
	mojing_321 			= 321, --魔鲸 ios 321
	mojing_322 			= 322, --魔鲸 ios 322
	mojing_323 			= 323, --魔鲸 ios 323
	mojing_324 			= 324, --魔鲸 ios 324
	mojing_325 			= 325, --魔鲸 ios 325
}

local platformId = device.getPlatformId()

if      platformId == AllPlatforms.Demo then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	-- CHANNEL_NAME                = "release2" -- 渠道名为release2可以跳过登录验证进入正式服
	CHANNEL_NAME                = "demo" -- 渠道名
	GAME_NAME                   = "闪烁宝可梦"             -- 游戏名
	PLATFORM_NAME               = "demo"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = false                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = true
	PLATFORM_PROJECT_INFO = "口袋对决  版号信息\n出版物号：ISBN 978-7-498-03739-8\n出版单位：北京中科奥科技有限公司\n批准文号：新广出审[2018]179号\n著作权人：深圳市鑫星互动科技有限公司\n软著登记号：2017SR579229"
	CHARGE_CONFIG_TYPE			="zh"					--充值类配置表文件名添加后缀

elseif  platformId == AllPlatforms.happyos then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "happyos"                -- 渠道名
	GAME_NAME                   = "Shining Elves"             -- 游戏名
	PLATFORM_NAME               = "happyos"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 1

elseif  platformId == AllPlatforms.mojing_301 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_301"                -- 渠道名
	GAME_NAME                   = "Shining Elves"             -- 游戏名
	PLATFORM_NAME               = "mojing_301"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_302 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_302"                -- 渠道名
	GAME_NAME                   = "Magic Era"             -- 游戏名
	PLATFORM_NAME               = "mojing_302"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_303 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_303"                -- 渠道名
	GAME_NAME                   = "Monster Evolution"             -- 游戏名
	PLATFORM_NAME               = "mojing_303"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_304 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_304"                -- 渠道名
	GAME_NAME                   = "Monster Mania"             -- 游戏名
	PLATFORM_NAME               = "mojing_304"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_305 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_305"                -- 渠道名
	GAME_NAME                   = "Eudemons Land"             -- 游戏名
	PLATFORM_NAME               = "mojing_305"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_306 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_306"                -- 渠道名
	GAME_NAME                   = "My Evolution Journey"             -- 游戏名
	PLATFORM_NAME               = "mojing_306"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_307 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_307"                -- 渠道名
	GAME_NAME                   = "Little Summoners"             -- 游戏名
	PLATFORM_NAME               = "mojing_307"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_308 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_308"                -- 渠道名
	GAME_NAME                   = "Poke Storm"             -- 游戏名
	PLATFORM_NAME               = "mojing_308"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_309 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_309"                -- 渠道名
	GAME_NAME                   = "Mystery Mainland"             -- 游戏名
	PLATFORM_NAME               = "mojing_309"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_311 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_311"                -- 渠道名
	GAME_NAME                   = "Evolve! Monsters"             -- 游戏名
	PLATFORM_NAME               = "mojing_311"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_312 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_312"                -- 渠道名
	GAME_NAME                   = "Awaken Monster"             -- 游戏名
	PLATFORM_NAME               = "mojing_312"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_313 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_313"                -- 渠道名
	GAME_NAME                   = "Capsule Elves"             -- 游戏名
	PLATFORM_NAME               = "mojing_313"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_314 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_314"                -- 渠道名
	GAME_NAME                   = "Talesmon Legend"             -- 游戏名
	PLATFORM_NAME               = "mojing_314"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_315 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_315"                -- 渠道名
	GAME_NAME                   = "Taming Master"             -- 游戏名
	PLATFORM_NAME               = "mojing_315"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_316 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_316"                -- 渠道名
	GAME_NAME                   = "Call Of Monster"             -- 游戏名
	PLATFORM_NAME               = "mojing_316"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_317 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_317"                -- 渠道名
	GAME_NAME                   = "Monster Anabasis"             -- 游戏名
	PLATFORM_NAME               = "mojing_317"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_318 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_318"                -- 渠道名
	GAME_NAME                   = "Brave Tamers"             -- 游戏名
	PLATFORM_NAME               = "mojing_318"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_321 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "shanshuo321"                -- 渠道名
	GAME_NAME                   = "Trainer Squad"             -- 游戏名
	PLATFORM_NAME               = "shanshuo321"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_322 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "shanshuo322"                -- 渠道名
	GAME_NAME                   = "Monster Contract"             -- 游戏名
	PLATFORM_NAME               = "shanshuo322"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_323 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "shanshuo323"                -- 渠道名
	GAME_NAME                   = "Magic Call"             -- 游戏名
	PLATFORM_NAME               = "shanshuo323"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_324 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "shanshuo324"                -- 渠道名
	GAME_NAME                   = "Pocket Evolution"             -- 游戏名
	PLATFORM_NAME               = "shanshuo324"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_325 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "shanshuo325"                -- 渠道名
	GAME_NAME                   = "Monster Journey"             -- 游戏名
	PLATFORM_NAME               = "shanshuo325"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_102 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_102"                -- 渠道名
	GAME_NAME                   = "Magic Era"             -- 游戏名
	PLATFORM_NAME               = "mojing_102"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_103 then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "mojing_103"                -- 渠道名
	GAME_NAME                   = "Monster Tales"             -- 游戏名
	PLATFORM_NAME               = "mojing_103"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_104 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_104"                -- 渠道名
    GAME_NAME                   = "Monster Evolution"             -- 游戏名
    PLATFORM_NAME               = "mojing_104"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_105 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_105"                -- 渠道名
    GAME_NAME                   = "Monster Quest"             -- 游戏名
    PLATFORM_NAME               = "mojing_105"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_106 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_106"                -- 渠道名
    GAME_NAME                   = "Monster Mania"             -- 游戏名
    PLATFORM_NAME               = "mojing_106"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_107 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_107"                -- 渠道名
    GAME_NAME                   = "Poke Storm"             -- 游戏名
    PLATFORM_NAME               = "mojing_107"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_108 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_108"                -- 渠道名
    GAME_NAME                   = "My Evolution Journey"             -- 游戏名
    PLATFORM_NAME               = "mojing_108"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_109 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_109"                -- 渠道名
    GAME_NAME                   = "Trainer Alliance"             -- 游戏名
    PLATFORM_NAME               = "mojing_109"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_110 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_110"                -- 渠道名
    GAME_NAME                   = "Fairy Fantasy"             -- 游戏名
    PLATFORM_NAME               = "mojing_110"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_111 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_111"                -- 渠道名
    GAME_NAME                   = "Little Summoners"             -- 游戏名
    PLATFORM_NAME               = "mojing_111"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_112 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_112"                -- 渠道名
    GAME_NAME                   = "Monster Stadium"             -- 游戏名
    PLATFORM_NAME               = "mojing_112"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_113 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_113"                -- 渠道名
    GAME_NAME                   = "Mystery Mainland"             -- 游戏名
    PLATFORM_NAME               = "mojing_113"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_114 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_114"                -- 渠道名
    GAME_NAME                   = "Monster Clash"             -- 游戏名
    PLATFORM_NAME               = "mojing_114"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_115 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_115"                -- 渠道名
    GAME_NAME                   = "Evolve! Monsters"             -- 游戏名
    PLATFORM_NAME               = "mojing_115"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_116 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_116"                -- 渠道名
    GAME_NAME                   = "Capsule Elves"             -- 游戏名
    PLATFORM_NAME               = "mojing_116"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_117 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_117"                -- 渠道名
    GAME_NAME                   = "Monster Legions"             -- 游戏名
    PLATFORM_NAME               = "mojing_117"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_120 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_120"                -- 渠道名
    GAME_NAME                   = "Brave Trainer"             -- 游戏名
    PLATFORM_NAME               = "mojing_120"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_121 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_121"                -- 渠道名
    GAME_NAME                   = "Tamers Legend"             -- 游戏名
    PLATFORM_NAME               = "mojing_121"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_122 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_122"                -- 渠道名
    GAME_NAME                   = "Tapymon Story"             -- 游戏名
    PLATFORM_NAME               = "mojing_122"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_123 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "shanshuo001"                -- 渠道名
    GAME_NAME                   = "Monster Realm"             -- 游戏名
    PLATFORM_NAME               = "shanshuo001"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_1124 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "shanshuo124"                -- 渠道名
    GAME_NAME                   = "Monster Contract"             -- 游戏名
    PLATFORM_NAME               = "shanshuo124"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_125 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_125"                -- 渠道名
    GAME_NAME                   = "Magic Call"             -- 游戏名
    PLATFORM_NAME               = "mojing_125"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_126 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "mojing_126"                -- 渠道名
    GAME_NAME                   = "Trainer Union"             -- 游戏名
    PLATFORM_NAME               = "mojing_126"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_1127 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "shanshuo127"                -- 渠道名
    GAME_NAME                   = "Pocket Evolution"             -- 游戏名
    PLATFORM_NAME               = "shanshuo127"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_1128 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "shanshuo128"                -- 渠道名
    GAME_NAME                   = "Monster Journey"             -- 游戏名
    PLATFORM_NAME               = "shanshuo128"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.mojing_1129 then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "shanshuo129"                -- 渠道名
    GAME_NAME                   = "Magic Monster Trainer"             -- 游戏名
    PLATFORM_NAME               = "shanshuo129"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
elseif  platformId == AllPlatforms.yingpai then

	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "yingpai"                -- 渠道名
	GAME_NAME                   = "小精灵"             -- 游戏名
	PLATFORM_NAME               = "yingpai"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
	CHARGE_CONFIG_TYPE			="zh"					--充值类配置表文件名添加后缀
    PLATFORM_PROJECT_INFO = "妖怪宝可萌  版号信息\n出版物号：ISBN 978-7-7979-4290-4\n出版单位：天津电子出版社有限公司\n批准文号：新广出审[2017]726号"

elseif  platformId == AllPlatforms.xinxin then
	GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
	CHANNEL_NAME                = "xinxin"                -- 渠道名
	GAME_NAME                   = "口袋对决"             -- 游戏名
	PLATFORM_NAME               = "xinxin"                -- 平台名，决定读取的cdn，注册服地址之类的。
	IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
	CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
	CHARGE_CONFIG_TYPE			="zh"					--充值类配置表文件名添加后缀
	PLATFORM_PROJECT_INFO = "口袋对决  版号信息\n出版物号：ISBN 978-7-498-03739-8\n出版单位：北京中科奥科技有限公司\n批准文号：新广出审[2018]179号\n著作权人：深圳市鑫星互动科技有限公司\n软著登记号：2017SR579229"
	GAME_PROTO_URL = "http://sh.8ttoo.com/mzsm/ylznew/yhxy.html"	--用户协议
	GAME_PRIVATE_URL = "http://sh.8ttoo.com/mzsm/ylznew/yszc.html"	--隐私指引
elseif  platformId == AllPlatforms.funcat then

    GAME_CODE                   = "sszg"                -- 游戏标识(一个游戏唯一值 不能修改)
    CHANNEL_NAME                = "funcat"                -- 渠道名
    GAME_NAME                   = "闪烁小精灵"             -- 游戏名
    PLATFORM_NAME               = "funcat"                -- 平台名，决定读取的cdn，注册服地址之类的。
    IS_PLATFORM_LOGIN           = true                 -- 是否平台登录
    CALL_SDK_SWITCH_ACCOUNT     = 2 					--专用模式，等待sdk切换账号回调
    CHARGE_CONFIG_TYPE			="zh"					--充值类配置表文件名添加后缀

end