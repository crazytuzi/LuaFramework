-- 这里输入文本最好使用两个中括号[[]] 防止转义字符造成的富文本打字机换行后对齐的问题
--[[
 格式:
 通用字段:
 func:要执行的命令, 
 key:jump命令来跳转的目标的标记, 可以随便写 要与jump对应
 donext: 立刻执行下一条命令,

 命令:
 changeBg:修改背景图  参数:name:文件名 这里已经把路径设定好了,直接写文件名就可以
 changeBgFadeIn:淡入淡出的方式替换背景图,效果是旧背景图淡出随后新背景图淡入.参数name:新背景图文件名,用法同上,fadeIntime 新图淡入的时间 fadeOuttime旧图淡出的时间
 speak:播放文字, 参数:name是名字框的名字 支持富文本,word:要说的话,speed打字机速度,如果不写的话那就是立刻全部播放
 hideDialog:隐藏对话框
 showDialog:显示对话框
 jump:跳转到指定行, 参数:to: 跳转的行的key值 这个暂时感觉用不上先放着如果要做随机剧情或者选择啥的 可以用这个
 sound:播放音效 src: 声音id
 music:播放音乐 src: 声音id
 stopMusic:停止播放音乐
 finish:播放完毕
--]]

return
{
	xuzhang = --我改了
	{
		{func = "playMp4",src = "res/video/xzvideo.mp4",startBuriedPoint = 20010}, -- 播放视频
		{func = "hideDialog", donext = true},
		{func = "playCCB",key = "start", name = "Page_login_dlopen37.ccbi", donext = true},
		{func = "music", src = "battle_1", donext = true}, -- 播放背景音乐并立刻执行下一条
		{func = "delay",time = 1},
		{func = "playCCBText", src = "Dialog_xuzhang1.ccbi", sound = "xuzhang_pangbai1_1", finishDoNext = true, startBuriedPoint = 20030, finish_delay = 7.6},
		{func = "hideDialog", donext = true},
		{func = "playCCB", name = "Page_login_dlopen42.ccbi", donext = true}, -- 更换背景并立刻执行下一条
		{func = "delay",time = 1},
		{func = "showDialog", donext = true},
		{func = "playCCBText", src = "Dialog_xuzhang1_1.ccbi", sound = "xuzhang_pangbai1_2", finishDoNext = true, finish_delay = 4},
		{func = "playCCB", name = "Page_login_dlopen33.ccbi", donext = true}, -- 更换背景并立刻执行下一条
		{func = "speak", name = "唐门掌门", word = [[唐三，前面就是鬼见愁！你已经无路可退，还不束手就擒！]], sound = "zhanglao_talk1", startBuriedPoint = 20031},-- 播放文字
		{func = "playCCB", name = "Page_login_dlopen34.ccbi", donext = true},-- 更换背景
		{func = "speak", name = "唐三", word = [[我知道，偷入内门，偷学本门绝学罪不可恕。]], sound = "tangsan_xz1", startBuriedPoint = 20032},-- 播放文字并立刻执行下一条
		{func = "speak", name = "唐三", word = [[但唐三可以对天发誓，从未忘本！以前没有，以后也没有。]], sound = "tangsan_xz2"},
		{func = "playCCB", name = "Page_login_dlopen44.ccbi", donext = true, loop = false},-- 更换背景
		{func = "speak", name = "唐三", word = [[佛怒唐莲算是唐三最后留给本门的礼物。]], sound = "tangsan_xz4", startBuriedPoint = 20035}, --播放文字
		{func = "playCCB", name = "Page_login_dlopen43.ccbi", donext = true, loop = false},-- 更换背景
		{func = "speak", name = "唐三", word = [[生是唐门的人，死是唐门的鬼。就让我骨化于这巴蜀自然之中吧。]], sound = "tangsan_xz3", startBuriedPoint = 20035}, --播放文字
		{func = "hideDialog", donext = true},
		{func = "playCCB", name = "Page_login_dlopen38.ccbi", loop = false, donext = true, startBuriedPoint = 20036},
		{func = "delay",time = 3.5},
		{func = "playCCBText", src = "Dialog_xuzhang4.ccbi", sound = "xuzhang_pangbai2", finishDoNext = true, startBuriedPoint = 20037, finish_delay = 4},
		{func = "playCCB", name = "Page_login_dlopen45.ccbi", donext = true},-- 更换背景并立刻执行下一条 
		{func = "playCCB", name = "Page_login_dlopen45.ccbi", donext = true},
		{func = "delay",time = 4.5},
		{func = "playCCBText", src = "Dialog_xuzhang2.ccbi", sound = "xuzhang_pangbai3", finishDoNext = true, startBuriedPoint = 20038, finish_delay = 14},
		-- {func = "stopMusic", donext = true}, --停止音乐并立刻执行下一条
		-- {func = "music", src = "main_interface", donext = true},
		{func = "fadeInPlayCCB", name = "Page_login_dlopen46.ccbi", loop = true, finishDoNext = true},
		{func = "delay",time = 1},
		{func = "playCCBText", src = "Dialog_xuzhang3.ccbi", sound = "xuzhang_pangbai4", finishDoNext = true, startBuriedPoint = 20043, finish_delay = 12},
		-- {func = "playCCB", name = "Page_login_dlopen46.ccbi", loop = true, donext = true}, 
		-- {func = "jump", to = "start", skipKey = true},-- 跳转到开头 
		{func = "finish"} --结束
	},
	guanqia1 =
	{
		{func = "changeBgFadeIn",key = "start", name = "dl_open_1.jpg", fadeOuttime = 0, fadeIntime = 0.5, finishDoNext = true , left_frame= "dl_open_1_1.jpg", right_frame= "dl_open_1_2.jpg"}, -- 更换背景并立刻执行下一条
		{func = "music", src = "main_interface", donext = true},
		{func = "speak", name = "小舞", word = [[三哥，我累了，我们找个地方住下吧？]], sound = "xiaowu_fb4_1", startBuriedPoint = 20802},-- 播放文字
		{func = "speak", name = "唐三", word = [[好，听你的！]], sound = "tangsan_fb4_1", startBuriedPoint = 20803},
		{func = "speak", name = "小舞", word = [[就这吧，玫瑰酒店～]], sound = "xiaowu_fb4_2", startBuriedPoint = 20804},
		{func = "changeBg", name = "dl_open_2.jpg", donext = true, left_frame= "dl_open_2_1.jpg", right_frame= "dl_open_2_2.jpg"},
		{func = "speak", name = "唐三", word = [[你好，麻烦给我们开两间房。]], sound = "tangsan_fb4_2", startBuriedPoint = 20805},
		{func = "speak", name = "服务生", word = [[实在抱歉，我们只剩一间房了。]], sound = "fuwusheng_talk1", startBuriedPoint = 20806},
		{func = "speak", name = "唐三", word = [[好，那么麻烦你帮我们开这间房吧。]], sound = "tangsan_fb4_3", startBuriedPoint = 20807},
		{func = "changeBg", name = "dl_open_3.jpg", donext = true, left_frame= "dl_open_3_1.jpg", right_frame= "dl_open_3_2.jpg"},
		{func = "speak", name = "戴沐白", word = [[慢着！我说，这间房应该属于我的吧！]], sound = "daimubai_talk1", startBuriedPoint = 20808},
		{func = "speak", name = "唐三", word = [[这位大哥，似乎是我们先来的！]], sound = "tangsan_fb4_4", startBuriedPoint = 20809},
		{func = "speak", name = "戴沐白", word = [[那又怎样？]], sound = "daimubai_talk2", startBuriedPoint = 20810},
		{func = "speak", name = "小舞", word = [[不怎么样，让你滚蛋！]], sound = "xiaowu_fb4_3", startBuriedPoint = 20811},
		{func = "finish", skipKey = true, skipBuriedPoint = 20801} --结束
	},
	guanqia2 =
	{
		{func = "playMp4",src = "res/video/1_4video.mp4", startBuriedPoint = 20860},	
		{func = "changeBgFadeIn",key = "start", name = "dl_open_4.jpg", fadeOuttime = 0, fadeIntime = 0.5, finishDoNext = true, left_frame= "dl_open_4_1.jpg", right_frame= "dl_open_4_2.jpg"},
		{func = "music", src = "main_interface", donext = true}, -- 更换背景并立刻执行下一条
		{func = "speak", name = "戴沐白", word = [[废武魂蓝银草能修炼到这种程度，也算不错了。]], sound = "daimubai_talk3", startBuriedPoint = 20871},-- 播放文字
		{func = "speak", name = "唐三", word = [[斗罗大陆上没有废物的武魂，只有废物的魂师！]], sound = "tangsan_fb4_5", startBuriedPoint = 20872},
		{func = "speak", name = "戴沐白", word = [[我想，我们很快会再见面的。到了史莱克，报我邪眸白虎戴沐白的名字！]], sound = "daimubai_talk4", startBuriedPoint = 20873},
		{func = "finish", skipKey = true, skipBuriedPoint = 20870} --结束
	},
	guanqia3 =
	{
		{func = "changeBgFadeIn",key = "start", name = "dl_open_14.jpg", fadeOuttime = 0, fadeIntime = 0.5, finishDoNext = true, left_frame= "dl_open_14_1.jpg", right_frame= "dl_open_14_2.jpg"}, -- 更换背景并立刻执行下一条
		{func = "music", src = "main_interface", donext = true},
		{func = "speak", name = "小舞", word = [[三哥你看，史莱克学院，终于到了～]], sound = "xiaowu_fb6_1"},
		{func = "speak", name = "唐三", word = [[嗯，不知道老师推荐的史莱克学院到底有多厉害！]], sound = "tangsan_yd1"},
		{func = "changeBg", name = "dl_open_15.jpg", donext = true, left_frame= "dl_open_15_1.jpg", right_frame= "dl_open_15_2.jpg"},
		{func = "speak", name = "龙纹棍考官", word = [[你们知不知道史莱克这三个字的含义？]], sound = "jiulonggun_talk1"},
		{func = "speak", name = "龙纹棍考官", word = [[史莱克是一种怪物，我们史莱克学院的含义，就是怪物学院！]], sound = "jiulonggun_talk2"},
		{func = "speak", name = "龙纹棍考官", word = [[我们这里只收怪物，不收普通人！]], sound = "jiulonggun_talk3"},
		{func = "stopMusic", donext = true}, --停止音乐并立刻执行下一条
		{func = "playMp4",src = "res/video/1_6video.mp4"},
		{func = "changeBgFadeIn",key = "start", name = "dl_open_19.jpg", fadeOuttime = 0, fadeIntime = 0.5, donext = true, left_frame= "dl_open_19_1.jpg", right_frame= "dl_open_19_2.jpg"},
		{func = "music", src = "main_interface", donext = true},
		{func = "speak", name = "小舞", word = [[不愧是大师推荐的学院，果然不一样！]], sound = "xiaowu_fb6_2"},-- 播放文字
		{func = "speak", name = "唐三", word = [[我们也赶快去报名吧！]], sound = "tangsan_fb6_1"},-- 播放文字
		{func = "music", src = "battle_1", donext = true},
		{func = "finish"} --结束
	},
	guanqia4 =
	{
		{func = "changeBgFadeIn",key = "start", name = "dl_open_16.jpg", fadeOuttime = 0, fadeIntime = 0.5, finishDoNext = true, left_frame= "dl_open_16_1.jpg", right_frame= "dl_open_16_2.jpg"}, -- 更换背景并立刻执行下一条
		{func = "music", src = "main_interface", donext = true},
		{func = "speak", name = "戴沐白", word = [[赵老师，我带人来进行第四关考核了。]], sound = "daimubai_talk5"},-- 播放文字
		{func = "speak", name = "赵无极", word = [[嗯？有来第四关的了？看来今年的小怪物不少嘛。]], sound = "zhaowuji_talk1"},
		{func = "speak", name = "戴沐白", word = [[而且，他们还都是免除了第二三关测试的！]], sound = "daimubai_talk6"},
		{func = "changeBg", name = "dl_open_17.jpg", donext = true, left_frame= "dl_open_17_1.jpg", right_frame= "dl_open_17_2.jpg"},
		{func = "speak", name = "赵无极", word = [[哦？不错不错。那我就亲自陪你们玩玩吧。]], sound = "zhaowuji_talk2"},
		{func = "speak", name = "赵无极", word = [[我叫赵无极，只要你们能抵挡住我的攻击一炷香，就算你们过关。]], sound = "zhaowuji_talk3"},
		{func = "changeBg", name = "dl_open_18.jpg", donext = true, left_frame= "dl_open_18_1.jpg", right_frame= "dl_open_18_2.jpg"},
		{func = "speak", name = "戴沐白", word = [[没想到赵老师竟然要亲自出手，他可是七十六级魂圣！]], sound = "daimubai_talk7"},
		{func = "speak", name = "戴沐白", word = [[赵老师的武魂是大力金刚熊，在学院里有不动明王的绰号。]], sound = "daimubai_talk8"},
		{func = "speak", name = "唐三/小舞", word = [[看来我们只有相互配合，奋力一搏了！]], sound = "tangsan_fb8_1"},
		{func = "music", src = "battle_2", donext = true},
		{func = "finish"} --结束
	},
	guanqia5 =
	{
		{func = "playMp4",src = "res/video/1_8video.mp4"},	
		{func = "changeBgFadeIn",key = "start", name = "dl_open_25.jpg", fadeOuttime = 0, fadeIntime = 0.5, finishDoNext = true, left_frame= "dl_open_25_1.jpg", right_frame= "dl_open_25_2.jpg"}, -- 更换背景并立刻执行下一条
		{func = "music", src = "main_interface", donext = true},
		{func = "speak", name = "赵无极", word = [[竟然让我使用了第六魂技，这场比试，算你们过关了!]], sound = "zhaowuji_talk4"},-- 播放文字
		{func = "finish"} --结束
	},
	guanqia6 =
	{
		{func = "changeBgFadeIn",key = "start", name = "dl_open_13.jpg", fadeOuttime = 0, fadeIntime = 0.5, finishDoNext = true, left_frame= "dl_open_13_1.jpg", right_frame= "dl_open_13_2.jpg"}, -- 更换背景并立刻执行下一条
		{func = "music", src = "main_interface", donext = true},
		{func = "speak", name = "弗兰德", word = [[我是史莱克学院院长弗兰德，恭喜你们通过考核，请交一千万金魂币作为择校费！]], sound = "fulande_talk1"},-- 播放文字
		{func = "speak", name = "小舞", word = [[怪老头，你你你……你抢钱！]], sound = "xiaowu_fb12_1"},
		{func = "speak", name = "弗兰德", word = [[嘿嘿，不交钱，就和我切磋切磋。如果赢了，也一样算你们通过。]], sound = "fulande_talk2"},
		{func = "finish"} --结束
	},
}