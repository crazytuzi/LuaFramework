--[[
地图转2D坐标配置
lizhuangzhuang
2015年4月29日21:59:24
]]

--[[
美术2D小地图的画法
1.修改config/RenderConfig.lua. showWall=true; showScene=false;
2.进场景Ctrl+Alt+U关闭UI,Ctrl+Alt+B画阻挡.截取最大区域，按边线裁剪
3.将2中的图片旋转-90°
4.将图片缩放致合适尺寸,记下宽高
5.将图片旋转相应角度(r)
6.可将图片进行适当偏离.记下图片中心点和画板中心点的偏移量
]]

--[[
参数说明
r:	地图内默认相机转角(双击默认摄像机，shift+c)(场景编辑器的读出的转角-270,保留两位小数)(如果是负的,去负号)
mW:	美术将场景平面图缩小后的宽
mH:	美术将场景平面图缩小后的高
wOffset:平面图的中心相对于白板中心的偏移
hOffset:平面图的中心相对于白板中心的偏移
]]

_G.Map2D = {
	--新测试地图
	[11000001] = {
		r = 45,
		mW = 684,
		mH = 684,
		wOffset = -60,
		hOffset = -58
	},
	--西岐主城
	[11000010] = {
		r = 45,
		mW = 684,
		mH = 684,
		wOffset = -60,
		hOffset = -58
	},
	--野外地图2鬼镇
	[11000006] = {
		r = 45,
		mW = 617,
		mH = 615,
		wOffset = -28,
		hOffset = -29
	},
	--野外地图1女娲神殿
	[11000007] = {
		r = 45,
		mW = 617,
		mH = 615,
		wOffset = -28,
		hOffset = -29
	},
	--新副本地图
	[11300002] = {
		r = 45,
		mW = 647,
		mH = 645,
		wOffset = 61,
		hOffset = -52
	},
	--新游戏临时地图1
	[11000003] = {
		r = 45,
		mW = 627,
		mH = 624,
		wOffset = 0,
		hOffset = 18
	},
	--新游戏临时地图2
	[11000004] = {
		r = 45,
		mW = 430,
		mH = 430,
		wOffset = 0,
		hOffset = 0
	},
	--新游戏临时地图3
	[11000005] = {
		r = 45,
		mW = 617,
		mH = 615,
		wOffset = -28,
		hOffset = -29
	},
	--挂机副本1
	[11400001] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本2
	[11400002] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本3
	[11400003] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本4
	[11400004] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本5
	[11400005] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本6
	[11400006] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本7
	[11400007] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本8
	[11400008] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本9
	[11400009] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本10
	[11400010] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本11
	[11400011] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本12
	[11400012] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本13
	[11400013] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本14
	[11400014] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本15
	[11400015] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本16
	[11400016] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本17
	[11400017] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本18
	[11400018] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本19
	[11400019] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本20
	[11400020] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本21
	[11400021] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本22
	[11400022] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本23
	[11400023] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本24
	[11400024] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本25
	[11400025] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本26
	[11400026] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本27
	[11400027] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本28
	[11400028] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本29
	[11400029] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本30
	[11400030] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本31
	[11400031] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本32
	[11400032] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本33
	[11400033] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本34
	[11400034] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本35
	[11400035] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本36
	[11400036] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本37
	[11400037] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本38
	[11400038] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本39
	[11400039] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本40
	[11400040] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本41
	[11400041] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本42
	[11400042] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本43
	[11400043] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本44
	[11400044] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本45
	[11400045] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本46
	[11400046] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本47
	[11400047] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本48
	[11400048] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本49
	[11400049] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本50
	[11400050] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本51
	[11400051] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本52
	[11400052] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本53
	[11400053] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本54
	[11400054] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本55
	[11400055] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本56
	[11400056] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},	
	--挂机副本57
	[11400057] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本58
	[11400058] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本59
	[11400059] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本60
	[11400060] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本61
	[11400061] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本62
	[11400062] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本63
	[11400063] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本64
	[11400064] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本65
	[11400065] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本66
	[11400066] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本67
	[11400067] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本68
	[11400068] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本69
	[11400069] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本70
	[11400070] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本71
	[11400071] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本72
	[11400072] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本73
	[11400073] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本74
	[11400074] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本75
	[11400075] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本76
	[11400076] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本77
	[11400077] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本78
	[11400078] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本79
	[11400079] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本80
	[11400080] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本81
	[11400081] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本82
	[11400082] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本83
	[11400083] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本84
	[11400084] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本85
	[11400085] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本86
	[11400086] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本87
	[11400087] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本88
	[11400088] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本89
	[11400089] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本90
	[11400090] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本91
	[11400091] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本92
	[11400092] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本93
	[11400093] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本94
	[11400094] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本95
	[11400095] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本96
	[11400096] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本97
	[11400097] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本98
	[11400098] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本99
	[11400099] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--挂机副本100
	[11400100] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},	
    --远古战场
	[10100000] = {
		r = 45,
		mW = 647,
		mH = 645,
		wOffset = 61,
		hOffset = -52
	},
	--北灵院
	[10100001] = {
		r = 45,
		mW = 692,
		mH = 689,
		wOffset = 57,
		hOffset = -19
	},
	--白龙丘
	[10100002] = {
		r = 45,
		mW = 617,
		mH = 615,
		wOffset = -28,
		hOffset = -29
	},
	--圣灵山
	[10100003] = {
		r = 45,
		mW = 698,
		mH = 698,
		wOffset = 2,
		hOffset = -11
	},
	--遗迹大陆
	[10100004] = {
		r = 45,
		mW = 627,
		mH = 624,
		wOffset = 0,
		hOffset = 18
	},
	--大罗天域
	[10100005] = {
		r = 45,
		mW = 643,
		mH = 641,
		wOffset = -44,
		hOffset = -68
	},
	--龙凤天
	[10100006] = {
		r = 45,
		mW = 474,
		mH = 475,
		wOffset = -2,
		hOffset = -21
	},
	--陨落战场
	[10100007] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = -48,
		hOffset = 33
	},
	--大西天界
	[10100008] = {
		r = 45,
		mW = 511,
		mH = 511,
		wOffset = 0,
		hOffset = -51
	},
	--无尽火域
	[10100009] = {
		r = 45,		
		mW = 513,
		mH = 513,
		wOffset = -36,
		hOffset = 31
	},
	--至尊武境
	[10100010] = {
		r = 45,
		mW = 588,
		mH = 586,
		wOffset = -19,
		hOffset = -3
	},
	--不死之地
	[10100011] = {
		r = 45,
		mW = 585,
		mH = 585,
		wOffset = 42,
		hOffset = -80
	},
	--绝世剑域
	[10100012] = {
		r = 45,
		mW = 701,
		mH = 701,
		wOffset = 15,
		hOffset = -55
	},

	--测试地图
	[10100050] = {
		r = 45,
		mW = 430,
		mH = 430,
		wOffset = 0,
		hOffset = 0
	},
	--测试地图
	[10100051] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--北苍城
	[10200001] = {
		r = 45,
		mW = 545,
		mH = 545,
		wOffset = 2,
		hOffset = -5
	},
	--登录场景
	[10200002] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},
	--旧登陆场景
	[10200003] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},
	--龙魔宫
	[10310001] = {
		r = 45,
		mW = 577,
		mH = 575,
		wOffset = -50,
		hOffset = 0
	},
	--龙魔宫
	[10310101] = {
		r = 45,
		mW = 577,
		mH = 575,
		wOffset = -50,
		hOffset = 0
	},
	--龙魔宫
	[10310201] = {
		r = 45,
		mW = 577,
		mH = 575,
		wOffset = -50,
		hOffset = 0
	},
	--龙魔宫
	[10310301] = {
		r = 45,
		mW = 577,
		mH = 575,
		wOffset = -50,
		hOffset = 0
	},
	--龙魔宫
	[10310401] = {
		r = 45,
		mW = 577,
		mH = 575,
		wOffset = -50,
		hOffset = 0
	},
	--大罗炎池
	[10310002] = {
		r = 45,
		mW = 687,
		mH = 685,
		wOffset = -11,
		hOffset = 0
	},
	--大罗炎池
	[10310102] = {
		r = 45,
		mW = 687,
		mH = 685,
		wOffset = -11,
		hOffset = 0
	},
	--大罗炎池
	[10310202] = {
		r = 45,
		mW = 687,
		mH = 685,
		wOffset = -11,
		hOffset = 0
	},
	--大罗炎池
	[10310302] = {
		r = 45,
		mW = 687,
		mH = 685,
		wOffset = -11,
		hOffset = 0
	},
	--大罗炎池
	[10310402] = {
		r = 45,
		mW = 687,
		mH = 685,
		wOffset = -11,
		hOffset = 0
	},
	--木神殿
	[10310003] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = 0
	},
	--木神殿
	[10310103] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = 0
	},
	--木神殿
	[10310203] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = 0
	},
	--木神殿
	[10310303] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = 0
	},
	--木神殿
	[10310403] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = 0
	},
	--地宫炼狱
	[10320001] = {
		r = 45,
		mW = 764,
		mH = 764,
		wOffset = 0,
		hOffset = 0
	},
	--北苍殿
	[10330001] = {
		r = 45,
		mW = 764,
		mH = 764,
		wOffset = 0,
		hOffset = 0
	},
	--境界突破
	[10340001] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--境界巩固
	[10340002] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--兽魄副本
	[10340003] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
		    --远古战场
	[10340004] = {
		r = 45,
		mW = 647,
		mH = 645,
		wOffset = 61,
		hOffset = -52
	},
	    --远古战场
	[10340005] = {
		r = 45,
		mW = 647,
		mH = 645,
		wOffset = 61,
		hOffset = -52
	},
		--天至尊遗迹
	[10340006] = {
		r = 45,
		mW = 803,
		mH = 805,
		wOffset = 0,
		hOffset = 0
	},
		--灵兽帝国
	[10340007] = {
		r = 45,
		mW = 836,
		mH = 800,
		wOffset = -57,
		hOffset = -38
	},
	--妖火山谷
	[10400001] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--不死祭坛
	[10400002] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--哭嚎废墟
	[10400003] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--青魇沙丘
	[10400004] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--怨灵炼狱
	[10400005] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--杀戮悬崖
	[10400006] = {
		r = 45,
		mW = 729,
		mH = 729,
		wOffset = 0,
		hOffset = 0
	},
	--午夜岛
	[10400007] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = -41,
		hOffset = -37
	},
	--北冥深渊
	[10400008] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = 0,
		hOffset = 0
	},
	--奔雷林地
	[10400009] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = 0,
		hOffset = 0
	},
	--竞技场
	[10400010] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},
	--仙魔战场
	[10400011] = {
		r = 45,
		mW = 444,
		mH = 447,
		wOffset = 0,
		hOffset = 9
	},
	--水果乐园
	[10400012] = {
		r = 45,
		mW = 868,
		mH = 776,
		wOffset = -92,
		hOffset = -93
	},
	--斗破苍穹
	[10400017] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = -41,
		hOffset = -37
	},
	--灵光界
	[10400018] = {
		r = 45,
		mW = 836,
		mH = 800,
		wOffset = -57,
		hOffset = -38
	},
	--灵路
	[10400019] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = -41,
		hOffset = -37
	},
	--帮派试练场
	[10400020] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = -41,
		hOffset = -37
	},
	--遗迹之战
	[10400021] = {
		r = 45,
		mW = 455,
		mH = 456,
		wOffset = 0,
		hOffset = 0
	},
	--上古天宫
	[10400022] = {
		r = 45,
		mW = 423,
		mH = 424,
		wOffset = 0,
		hOffset = 0
	},
	--北苍界
	[10400023] = {
		r = 45,
		mW = 547,
		mH = 546,
		wOffset = -20,
		hOffset = -47
	},
	--水果乐园
	[10400024] = {
		r = 45,
		mW = 868,
		mH = 776,
		wOffset = -92,
		hOffset = -93
	},
	--流水
	[10400025] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},
	--主宰之路1-火猿山谷
	[10400026] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},

	--灵兽墓地
	[10400028] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},
	--帮派圣地
	[10400029] = {
		r = 45,
		mW = 764,
		mH = 764,
		wOffset = 0,
		hOffset = 0
	},	
		--活动北苍城
	[10400030] = {
		r = 45,
		mW = 1270,
		mH = 740,
		wOffset = -60,
		hOffset = -55
	},	
		--福神降临
	[10400031] = {
		r = 45,
		mW = 985,
		mH = 800,
		wOffset = 50,
		hOffset = -53
	},	
		--历练深渊
	[10400032] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},	
	--骑兵魔冢
	[10400033] = {
		r = 45,
		mW = 680,
		mH = 679,
		wOffset = 0,
		hOffset = -40
	},
	--骑兵魔冢准备层
	[10400034] = {
		r = 45,
		mW = 1022,
		mH = 800,
		wOffset = -51,
		hOffset = -40
	},
	--帮派地宫1
	[10400035] = {
		r = 45,
		mW = 444,
		mH = 447,
		wOffset = 0,
		hOffset = 9
	},
		--帮派地宫2
	[10400036] = {
		r = 45,
		mW = 444,
		mH = 447,
		wOffset = 0,
		hOffset = 9
	},
		--帮派地宫3
	[10400037] = {
		r = 45,
		mW = 444,
		mH = 447,
		wOffset = 0,
		hOffset = 9
	},
	--骑兵魔冢2
	[10400038] = {
		r = 45,
		mW = 444,
		mH = 447,
		wOffset = 0,
		hOffset = 9
	},
	--婚礼殿堂
	[10400039] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--火焰魔塔1
	[10400040] = {
		r = 45,
		mW = 1098,
		mH = 1097,
		wOffset = 0,
		hOffset = 41
	},
	--火焰魔塔2
	[10400041] = {
		r = 45,
		mW = 1098,
		mH = 1097,
		wOffset = 0,
		hOffset = 41
	},
	--火焰魔塔3
	[10400042] = {
		r = 45,
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--火焰魔塔4
	[10400043] = {
		r = 45,
		mW = 1032,
		mH = 1031,
		wOffset = -21,
		hOffset = 34
	},
	--寒冰魔塔1
	[10400044] = {
		r = 45,
		mW = 1425,
		mH = 1423,
		wOffset = 123,
		hOffset = -271
	},
	--寒冰魔塔
	[10400045] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--寒冰魔塔
	[10400046] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--寒冰魔塔
	[10400047] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--机关魔塔
	[10400048] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--机关魔塔
	[10400049] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--机关魔塔
	[10400050] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--机关魔塔
	[10400051] = {
		r = 45,
		mW = 944,
		mH = 1855,
		wOffset = 31,
		hOffset = -17
	},
	--火焰魔塔5
	[10400052] = {
		r = 45,
		mW = 1098,
		mH = 1097,
		wOffset = 0,
		hOffset = 41
	},
	--打宝秘境 一层
	[10410001] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--打宝秘境 二层
	[10410002] = {
		r = 45,
		mW = 431,
		mH = 435,
		wOffset = 0,
		hOffset = 4
	},
	--打宝秘境 三层
	[10410003] = {
		r = 45,
		mW = 491,
		mH = 494,
		wOffset = 8,
		hOffset = -9
	},
	--打宝秘境 四层
	[10410004] = {
		r = 45,
		mW = 436,
		mH = 438,
		wOffset = 11,
		hOffset = 0
	},
	--打宝秘境 五层
	[10410005] = {
		r = 45,
		mW = 530,
		mH = 528,
		wOffset = 0,
		hOffset = -27
	},
		--打宝秘境 一层
	[10411001] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--打宝秘境 二层
	[10411002] = {
		r = 45,
		mW = 431,
		mH = 435,
		wOffset = 0,
		hOffset = 4
	},
	--打宝秘境 三层
	[10411003] = {
		r = 45,
		mW = 491,
		mH = 494,
		wOffset = 8,
		hOffset = -9
	},
	--打宝秘境 四层
	[10411004] = {
		r = 45,
		mW = 436,
		mH = 438,
		wOffset = 11,
		hOffset = 0
	},
	--打宝秘境 五层
	[10411005] = {
		r = 45,
		mW = 530,
		mH = 528,
		wOffset = 0,
		hOffset = -27
	},
	--奇遇副本1
	[10350001] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--奇遇副本2
	[10350002] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--奇遇副本3
	[10350003] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--奇遇副本4
	[10350004] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--奇遇副本5
	[10350005] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
		--跨服1V1
	[10320010] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
		--上层遗迹1
	[10420001] = {
		r = 45,
		mW = 527,
		mH = 529,
		wOffset = -7,
		hOffset = -91
	},
		--下层遗迹1
	[10420002] = {
		r = 45,
		mW = 583,
		mH = 584,
		wOffset = -25,
		hOffset = -66
	},
		--死亡圣殿1
	[10420003] = {
		r = 45,
		mW = 470,
		mH = 472,
		wOffset = 23,
		hOffset = -40
	},
		--上层遗迹2
	[10420004] = {
		r = 45,
		mW = 427,
		mH = 426,
		wOffset = 8,
		hOffset = -24
	},
		--下层遗迹2
	[10420005] = {
		r = 45,
		mW = 581,
		mH = 580,
		wOffset = 24,
		hOffset = -70
	},
		--死亡圣殿2
	[10420006] = {
		r = 45,
		mW = 443,
		mH = 323,
		wOffset = -4,
		hOffset = 11
	},
		--上层遗迹3
	[10420007] = {
		r = 45,
		mW = 426,
		mH = 425,
		wOffset = 25,
		hOffset = -16
	},
		--下层遗迹3
	[10420008] = {
		r = 45,
		mW = 518,
		mH = 518,
		wOffset = -27,
		hOffset = -13
	},
		--死亡圣殿3
	[10420009] = {
		r = 45,
		mW = 486,
		mH = 357,
		wOffset = 19,
		hOffset = -3
	},
		--死亡神宫1
	[10420010] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
	},
		--死亡神宫2
	[10420011] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
	},
		--死亡神宫3
	[10420012] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
	},
	--神兽之原
	[10430001] = {
		r = 45,
		mW = 504,
		mH = 507,
		wOffset = -18,
		hOffset = -1
	},
		--跨服擂台战场
	[10430002] = {
		r = 45,
		mW = 460,
		mH = 461,
		wOffset = 0,
		hOffset = 0
	},
		--跨服擂台淘汰
	[10430003] = {
		r = 45,
		mW = 392,
		mH = 393,
		wOffset = 0,
		hOffset = 0
	},
	--新游戏经验副本
	[11300003] = {
		r = 45,
		mW = 795,
		mH = 795,
		wOffset = -41,
		hOffset = -37
		},
	--地宫一层
	[11401001] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
		},
	--地宫二层
	[11401002] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
		},
	--地宫三层
	[11401003] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
		},
	--地宫四层
	[11401004] = {
		r = 45,
		mW = 548,
		mH = 548,
		wOffset = 0,
		hOffset = -8
		},
	--个人BOSS
	[11301001] = {
		r = 45,
		mW = 560,
		mH = 560,
		wOffset = 0,
		hOffset = 0
	},	
		--骑兵魔冢
	[11300004] = {
		r = 45,
		mW = 680,
		mH = 679,
		wOffset = 0,
		hOffset = -40
	},
}