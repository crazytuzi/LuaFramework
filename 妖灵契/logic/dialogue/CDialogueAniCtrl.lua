local CDialogueAniCtrl = class("CDialogueAniCtrl", CCtrlBase)

CDialogueAniCtrl.DialogeAniFilePath = "/Lua/logic/dialogue/dialogueanifile"

CDialogueAniCtrl.DependTable = {
	BoolYesOrNo = {
		list = {
			[0] = { keyName = "否",},
			[1] = { keyName = "是",},
		},
		listName = "选择是或否",
	},
	BoolLeftOrRight = {
		list = {
			[0] = { keyName = "左",},
			[1] = { keyName = "右",},
			[2] = { keyName = "中",},
		},
		listName = "选择左,右,剧中",
	},	
	CommonActions = {
		list = {
			["none"] = {keyName = "无", sort = 1},
			["attack1"] = {keyName = "攻击动作1", sort = 2},
			["attack2"] = {keyName = "攻击动作2", sort = 3},
			["die"] = {keyName = "倒下", sort = 4},
			["run"] = {keyName = "跑步", sort = 5},
		},
		listName = "选择通用动作",
	},
	PivotTable = {
		list = {
			[0] = {keyName = "居中", sort = 1},
			[1] = {keyName = "居上", sort = 2},
			[2] = {keyName = "居下", sort = 3},
			[3] = {keyName = "居左", sort = 4},
			[4] = {keyName = "居右", sort = 5},
		},
		listName = "选择对齐方式",
	},
	Live2DActionsTable = {
		list = {
			["none"] = {keyName = "无", sort = 1},
			["idle_1"] = {keyName = "idle_1", sort = 2},
			["Guide_1"] = {keyName = "Guide_1", sort = 3},
			["Guide_2"] = {keyName = "Guide_2", sort = 4},
			["Guide_3"] = {keyName = "Guide_3", sort = 5},
		},
		listName = "选择live2d动作",
	},	
	SocialEmojiTable = {
		list = {
			["dian"] = {keyName = "点点点", sort = 1},
			["kaixin"] = {keyName = "开心", sort = 2},
			["mengbi"] = {keyName = "蒙蔽", sort = 3},
			["mihu"] = {keyName = "迷糊", sort = 4},
			["shengqi"] = {keyName = "生气", sort = 5},
			["weiqu"] = {keyName = "委屈", sort = 6},
			["wuyu1"] = {keyName = "无语1", sort = 7},
			["wuyu2"] = {keyName = "无语2", sort = 8},
			["wuyu3"] = {keyName = "无语3", sort = 9},
			["zhenjing"] = {keyName = "震惊", sort = 10},
		},
		listName = "选择社交表情",
	},
	LayerAniActionTables = {
		list = {
			["flyout"] = {keyName = "飞出", sort = 1},
			["zhenjing"] = {keyName = "震惊", sort = 2},
			["pengzhuang"] = {keyName = "碰撞", sort = 3},
			["houtui"] = {keyName = "后退", sort = 4},
			["tiaodong"] = {keyName = "跳动", sort = 5},
			["xuanzhuan"] = {keyName = "旋转", sort = 6},
			["yasuo"] = {keyName = "压缩", sort = 7},
		},
		help=[[
			动作说明(动作参数说明)
			1.[飞出]
			飞行方向("you","right"),飞出遗言(默认没有)
			[格式]:right,我还会回来的!

			2.[后退]
			后退的距离,后退时间
			[格式]:50,0.1

			3.[跳动]
			跳动高度，跳动次数
			[格式]:50,2

			4.[旋转]
			旋转圈数,顺时针或逆时针("shun", "ni"),总时间
			[格式]:10,ni,0.3


		]],
		listName = "界面动画动作",
	},
	
	SwitchTextrueTable = {
		list = {
			["none"] = {keyName = "无", sort = 1},
			["guide_white"] = {keyName = "白", sort = 2},
			["guide_black"] = {keyName = "黑", sort = 3},
		},
		listName = "选择过度贴图",
	},

	LayerAddPlayerMode = {
		list = {
			["rotation"] = {keyName = "旋转", sort = 1},
			["fadein"] = {keyName = "淡入", sort = 2},
			["none"] = {keyName = "无", sort = 3},
		},
		listName = "选择过度贴图",
	},
}

CDialogueAniCtrl.CmdConfig = 
{
	[1] = 
	{	
		mainTypeName = "人物指令",
		cmdList = 
		{
			[1] = 
				{ subTypeName = "生成人物", 
				  func = "AddPlayer",
				  args = 
						{	
							[1] = { argName = "人物名称", format = "input", type = "string", defualt = "玩家名称",},
							[2] = { argName = "模型编号", format = "input", type = "number", defualt = "130",},
							[3] = { argName = "出生位置", format = "input", type = "number,number", defualt = "20,20"},
							[4] = { argName = "出生朝向", format = "input", type = "number", defualt = "0"},
							[5] = { argName = "人物动态编号", format = "desLabel", type = "number", defualt = "1", isSpawnIdx = true},
							[6] = { argName = "是否有魔法阵", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},		
						},
				  stringFormat = "名称:[|1|],模型:[|2|],出生位置:[|3|],朝向:[|4|],动态编号:[|5|],是否有魔法阵:[|6|],",
				 },	
			[2] = 
				{ subTypeName = "设置人物位置", 
				  func = "SetPlayerPos",
				  args = 
						{	
							[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
							[2] = { argName = "目标位置", format = "input", type = "number,number", defualt = "20,20"},							
						},
			 	  stringFormat = "名称:[|1|],目标位置:[|2|]",						
				 },		
			[3] = 
				{ subTypeName = "设置人物朝向", 
				  func = "SetPlayerFaceTo",
				  args = 
						{	
							[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
							[2] = { argName = "人物朝向", format = "input", type = "number", defualt = "0"},
						},
			 	  stringFormat = "名称:[|1|],人物朝向:[|2|]",							
				 },	
			[4] = 
			{ subTypeName = "设置人物是否可见", 
			  func = "SetPlayerActive",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "是否可见", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},						
					},
			  stringFormat = "名称:[|1|],是否可见:[|2|]",						
			 },		
			[5] = 
			{ subTypeName = "剧场冒泡说话", 
			  func = "PlayerSay",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "对话内容", format = "input", type = "string", defualt = "输入说话内容", size = {x = 350, y = 60},},						
					},
			  stringFormat = "名称:[|1|],对话内容:[|2|]",					
			 },		
			[6] = 
			{ subTypeName = "人物移动", 
			  func = "PlayerRunto",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "移动目标位置", format = "input", type = "number,number", defualt = "20,20"},
						[3] = { argName = "移动结束朝向", format = "input", type = "number", defualt = "360"},
					},
			  stringFormat = "名称:[|1|],目标位置:[|2|],目标位置:[|3|]",						
			 },		
			 [7] = 
			{ subTypeName = "人物动作", 
			  func = "PlayerDoAction",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "动作名称", format = "depend", type = "string", defualt = "attack1", dependTable = "ActionTables"},						
					},
			  stringFormat = "名称:[|1|],动作名称:[|2|]",
			 },		
			[8] = 
			{ subTypeName = "人物特效", 
			  func = "PlayerDoEffect",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "特效名称", format = "depend", type = "string", defualt = "ui_eff_story_01", dependTable = "StoryEffectTable"},						
						[3] = { argName = "位置偏移", format = "input", type = "number,number,number", defualt = "0,0,0"},
						[4] = { argName = "朝向", format = "input", type = "number,number,number", defualt = "0,0,0"},						
						[5] = { argName = "存在时间", format = "input", type = "number", defualt = "10"},						
					},
			  stringFormat = "名称:[|1|],特效名称:[|2|],位置偏移:[|3|],朝向:[|4|]",
			 },	
			[9] = 
			{ subTypeName = "剧场界面说话", 
			  func = "PlayerUISay",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "对话内容", format = "input", type = "string", defualt = "输入说话内容", size = {x = 350, y = 60},},							
						[3] = { argName = "说话延时", format = "input", type = "number", defualt = "2"},						
						[4] = { argName = "选择左右还是居中", format = "depend", type = "number", defualt = "0", dependTable = "BoolLeftOrRight",},								
						[5] = { argName = "说话完毕是否关闭", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},									
						[6] = { argName = "说话完毕是否暂停", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},		
						[7] = { argName = "是否显示头像", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},		
						[8] = { argName = "对话语音编号", format = "depend", type = "string", defualt = "0", dependTable = "TalkMusicTables",},			
						[9] = { argName = "居中头像是否有spine", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
						[10] = { argName = "spined动作", format = "input_string", type = "string", defualt = "idle"},
						[11] = { argName = "延时显示说话", format = "input", type = "number", defualt = "0"},
						[12] = { argName = "是否淡入", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},
						[13] = { argName = "跳到指定时间", format = "input", type = "number", defualt = "0"},
					},
			  stringFormat = "名称:[|1|],对话内容:[|2|],延时:[|3|],位置:[|4|],关闭:[|5|],暂停:[|6|],头像显示:[|7|],对话语音编号:[|8|],居中头像是否有spine:[|9|] ",
			 },	
			[10] = 
			{ subTypeName = "显示魔法阵", 
			  func = "PlayerShowBottomMagic",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},										
						[2] = { argName = "是否显示魔法阵", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "名称:[|1|],是否显示魔法阵:[|2|]",
			 },	
			[11] = 
			{ subTypeName = "人物技能特效", 
			  func = "PlayerDoSkillMagic",
			  args = 
					{	
						[1] = { argName = "释放者", format = "input", type = "number", defualt = "1"},										
						[2] = { argName = "受击者", format = "input", type = "number", defualt = "1",},										
						[3] = { argName = "模型编号", format = "input", type = "number", defualt = "130",},	
						[4] = { argName = "技能序号", format = "input", type = "number", defualt = "1",},	
					},
			  stringFormat = "释放者:[|1|],受攻者:[|2|],模型编号:[|3|],技能序号:[|3|]",
			 },	
			[12] = 
			{ subTypeName = "Live2D动作", 
			  func = "PlayerLive2dDoAction",
			  args = 
					{	
						[1] = { argName = "live2d动作", format = "depend", type = "string", defualt = "none", dependTable = "Live2DActionsTable",},	
					},
			  stringFormat = "live2d动作:[|1|]",
			 },		
			[13] = 
			{ subTypeName = "社交表情", 
			  func = "PlayerShowSocialEmoji",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},										
						[2] = { argName = "社交表情", format = "depend", type = "string", defualt = "dian", dependTable = "SocialEmojiTable",},	
						[3] = { argName = "是否显示", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "名称:[|1|],社交表情:[|2|],是否显示:[|3|]",
			 },				 		 
		}
	},

	[2] = 
	{
		mainTypeName = "场景剧本设置",
		cmdList = 
		{
			[1] = 
			{ subTypeName = "背景音乐", 
			  func = "SetBgMusic",
			  args = 
					{	
						[1] = { argName = "背景音乐", format = "depend", type = "string", defualt = "bgm_1010", dependTable = "BgMusicTables"},						
						[2] = { argName = "是否播放BGM", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},						
					},
			  stringFormat = "背景音乐:[|1|],是否播放BGM:[|2|]",
			 },			
			[2] = 
			{ subTypeName = "游戏音效", 
			  func = "SetEffectMusic",
			  args = 
					{						
						[1] = { argName = "背景音乐", format = "depend", type = "string", defualt = "ch_1001_1", dependTable = "EffectMusicTables"},						
					},
			  stringFormat = "音效文件:[|1|]",					
			 },		
			[3] = 
			{ subTypeName = "镜头跟随", 
			  func = "SetCameraFollow",
			  args = 
					{	
						[1] = { argName = "跟随对象", format = "depend", type = "number", defualt = "0", dependTable = "CameraFollowTables"},						
						[2] = { argName = "移动时间", format = "input", type = "number", defualt = "0"},						
					},
			  stringFormat = "跟随对象:(|1|),移动时间|2|",
			 },	
			[4] = 
			{ subTypeName = "显示剧情界面", 
			  func = "SetDialogueAniViewActive",
			  args = 
					{							
						[1] = { argName = "是否可见", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},						
						[2] = { argName = "是否显示弹幕", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},						
						[3] = { argName = "结束时是否关闭", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},						
						[4] = { argName = "背景图片", format = "input", type = "string", defualt = "none"},												
						[5] = { argName = "live2d", format = "input", type = "number", defualt = "0",},
						[6] = { argName = "显示遮罩", format = "input", type = "number", defualt = "0",},
						[7] = { argName = "中间贴图", format = "input", type = "string", defualt = "none"},
						[8] = { argName = "中间贴图采用spine动作", format = "input", type = "string", defualt = "none"},
						[9] = { argName = "必须存在界面才执行", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},
					},
			  stringFormat = "是否显示剧情界面:[|1|],是否显示弹幕:[|2|],结束是否关闭:[|3|, 背景图片:[|4|], live2d编号:[|5|],显示遮罩:[|6|],中间贴图:[|7|],spine动作:[|8|]",
			 },		
			[5] = 
			{ subTypeName = "显示Live2D", 
			  func = "SetDialogueAniViewShowLive2D",
			  args = 
					{							
						[1] = { argName = "是否可见", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},						
						[2] = { argName = "live2d编号", format = "input", type = "string", defualt = "1003"},						
					},
			  stringFormat = "是否显示Live2D:[|1|],live2d编号:[|2|],",
			 },		
			[6] = 
			{ subTypeName = "显示起名", 
			  func = "SetDialogueAniViewRename",
			  args = 
					{							
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																		
					},
			  stringFormat = "是否显示:[|1|]",
			 },		
			[7] = 
			{ subTypeName = "显示剧情背景", 
			  func = "SetDialogueAniViewBgTexture",
			  args = 
					{							
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																		
						[2] = { argName = "背景图片", format = "input", type = "string", defualt = "login_main"},												
					},
			  stringFormat = "是否显示:[|1|],背景图片:[|2|],是否剧情开始时显示:[|3|]",
			 },		
			[8] = 
			{ subTypeName = "显示闭眼遮罩", 
			  func = "SetDialogueAniViewCoverMask",
			  args = 
					{							
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																								
						[2] = { argName = "显示动画编号", format = "input", type = "number", defualt = "1",},																														
						[3] = { argName = "显示模糊贴图", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																													
					},
			  stringFormat = "是否显示:[|1|],显示动画编号:[|2|],显示模糊贴图:[|3|]",
			 },			
			[9] = 
			{ subTypeName = "显示遮罩对话", 
			  func = "SetDialogueAniViewCoverMaskSay",
			  args = 
					{							
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																								
						[2] = { argName = "对话内容", format = "input", type = "string", defualt = "好困，别吵!"},																															
						[3] = { argName = "是否居中", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																								
					},	

			  stringFormat = "是否显示:[|1|],对话内容:[|2|],是否居中:[|2|]",
			 },					 	 			 
			[10] = 
			{ subTypeName = "暂停剧情", 
			  func = "SetDialogueAniViewPause",
			  args = 
					{							
						[1] = { argName = "是否暂停", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																		
					},
			  stringFormat = "是否暂停:[|1|]",
			 },		
			[11] = 
			{ subTypeName = "显示恢复播放按钮", 
			  func = "SetDialogueAniViewShowResumeBtn",
			  args = 
					{							
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},												
						[2] = { argName = "恢复播放文本", format = "input", type = "string", defualt = "我要睡觉了……"},						
					},
			  stringFormat = "是否显示:[|1|],恢复播放文本[|2|]",
			 },		
			[12] = 
			{ subTypeName = "结束时触发引导", 
			  func = "SetDialogueAniEndTriggerGuide",
			  args = 
					{													
						[1] = { argName = "引导编号", format = "input", type = "string", defualt = "Open_ZhaoMu_Condition"},						
					},
			  stringFormat = "引导编号:[|1|],",
			 },		
			[13] = 
			{ subTypeName = "结束时触发开篇动画", 
			  func = "SetDialogueAniEndTriggerStoryTask",
			  args = 
					{													
						[1] = { argName = "", format = "input", type = "number", defualt = "10001"},						
					},
			  stringFormat = "开篇动画:[|1|],",
			 },			
			[14] = 
			{ subTypeName = "结束时触发剧场", 
			  func = "SetDialogueAniEndTriggerOtherDialogueAni",
			  args = 
					{													
						[1] = { argName = "", format = "input", type = "number", defualt = "888"},						
					},
			  stringFormat = "剧场编号:[|1|],",
			 },		
			[15] = 
			{ subTypeName = "剧场播放记录", 
			  func = "SetDialogueAniEndFlag",
			  args = 
					{													
						[1] = { argName = "记录标志", format = "input", type = "string", defualt = "welcome_1"},												
						[2] = { argName = "是否立即记录", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "剧场记录标志:[|1|],是否立即记录:[|2|],",
			 },		
			[16] = 
			{ subTypeName = "居中贴图", 
			  func = "SetDialogueMidTexture",
			  args = 
					{													
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},												
						[2] = { argName = "贴图路径", format = "input", type = "string", defualt = "none"},											
					},
			  stringFormat = "是否显示:[|1|],贴图路径:[|2|]",
			 },			
			[17] = 
			{ subTypeName = "设置镜头距离", 
			  func = "SetCameraDistance",
			  args = 
					{													
						[1] = { argName = "目标距离", format = "input", type = "number", defualt = "2.7",},
						[2] = { argName = "时间", format = "input", type = "number", defualt = "0"},											
					},
			  stringFormat = "目标距离:[|1|],时间:[|2|]",
			 },		
			[18] = 
			{ subTypeName = "手机震动", 
			  func = "SetPhoneShake",
			  args = 
					{													
						[1] = { argName = "手机是否震动", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},																		
					},
			  stringFormat = "手机是否震动:[|1|]",
			 },		
			[19] = 
			{ subTypeName = "结束时显示剧情过度界面", 
			  func = "SetDialogueAniEndSwitchBox",
			  args = 
					{													
						[1] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},							
						[2] = { argName = "显示过度贴图", format = "depend", type = "string", defualt = "none", dependTable = "SwitchTextrueTable",},	
						[3] = { argName = "是否立即执行", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},							
						[4] = { argName = "显示时间", format = "input", type = "number", defualt = "0",},							
						[5] = { argName = "是否淡入", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},							
					},
			  stringFormat = "是否显示:[|1|],显示过度黑背景:[|2|],剧情开始时触发:[|3|],显示时间:[|4|],是否淡入:[|5|],",
			 },				
			 [20] = 
			{ subTypeName = "添加场景特效", 
			  func = "AddMapEffect",
			  args = 
					{	
						[1] = { argName = "名字", format = "input", type = "string", defualt = "effect_1"},										
						[2] = { argName = "特效路径", format = "depend", type = "string", defualt = "ui_eff_story_01", dependTable = "StoryEffectTable"},
						[3] = { argName = "位置", format = "input", type = "number,number", defualt = "0,0",},										
						[4] = { argName = "朝向", format = "input", type = "number", defualt = "0",},						
						[5] = { argName = "存在时间", format = "input", type = "number", defualt = "0",},	
						[6] = { argName = "是否是前景特效", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},	
						[7] = { argName = "脱离剧本", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "名字:[|1|],特效路径:[|2|],位置x:[|3|],位置y:[|4|],存在时间:[|5|],是否是前景特效:[|6|]",
			 },				 
			 [21] = 
			{ subTypeName = "添加镜头跟随特效", 
			  func = "AddCamerakEffect",
			  args = 
					{	
						[1] = { argName = "名字", format = "input", type = "string", defualt = "effect_1"},										
						[2] = { argName = "特效路径", format = "depend", type = "string", defualt = "ui_eff_story_01", dependTable = "StoryEffectTable"},
						[3] = { argName = "偏移位置x", format = "input", type = "number", defualt = "0",},										
						[4] = { argName = "偏移位置y", format = "input", type = "number", defualt = "0",},	
						[5] = { argName = "存在时间", format = "input", type = "number", defualt = "0",},	
						[6] = { argName = "是否适配屏幕", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "名字:[|1|],特效路径:[|2|],位置x:[|3|],位置y:[|4|],存在时间:[|5|],适配屏幕:[|6|]",
			 },		
			[22] = 
			{ subTypeName = "特效移动", 
			  func = "DoEffectMoveOption",
			  args = 
					{	
						[1] = { argName = "名字", format = "input", type = "string", defualt = "effect_1"},																
						[2] = { argName = "移动起始位置", format = "input", type = "number,number", defualt = "0,0",},										
						[3] = { argName = "移动结束位置", format = "input", type = "number,number", defualt = "0,0",},	
						[4] = { argName = "时间", format = "input", type = "number", defualt = "0",},							
					},
			  stringFormat = "名字:[|1|],移动起始位置:[|2|],移动结束位置:[|3|],时间:[|4|]",
			 },		
			[23] = 
			{ subTypeName = "界面特效", 
			  func = "AddUIScreenEffect",
			  args = 
					{	
						[1] = { argName = "名字", format = "input", type = "string", defualt = "effect_1"},																
						[2] = { argName = "特效路径", format = "depend", type = "string", defualt = "ui_eff_story_01", dependTable = "StoryEffectTable"},			
						[3] = { argName = "对齐方式", format = "depend", type = "number", defualt = "0", dependTable = "PivotTable"},
						[4] = { argName = "存在时间", format = "input", type = "number", defualt = "0",},										
						[5] = { argName = "坐标偏移", format = "input", type = "number,number", defualt = "0,0",},		
						[6] = { argName = "缩放", format = "input", type = "number,number", defualt = "120,120",},						
						[7] = { argName = "是否置顶", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},	
						[8] = { argName = "是否适配屏幕", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "名字:[|1|],移动起始位置:[|2|],移动结束位置:[|3|],时间:[|4|],坐标偏移:[|5|]缩放:[|6|],是否置顶:[|7|],是否适配屏幕:[|8|]",
			 },		
			[24] = 
			{ subTypeName = "界面醒一醒", 
			  func = "AddUIXingYiXingEffect",
			  args = 
					{	
						[1] = { argName = "贴图路径", format = "input", type = "string", defualt = "bg_xingyixing"},																
						[2] = { argName = "是否显示", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "贴图路径:[|1|],是否显示:[|2|]",
			 },			
			 [25] = 
			{ subTypeName = "隐藏说话窗口", 
			  func = "HideSayWidget",
			  args = 
					{							
						[1] = { argName = "是否隐藏(不会停止语音)", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "是否隐藏:[|1|]",
			 },		
			[26] = 
			{ subTypeName = "结束时切换操作", 
			  func = "SetDialogueAniEndSwitchProcress",
			  args = 
					{																			
						[1] = { argName = "切换处理id", format = "input", type = "number", defualt = "0",},							
					},
			  stringFormat = "切换处理id:[|1|],",
			 },				 
		},
	},
	[3] = 
	{
		mainTypeName = "常驻NPC动画",
		cmdList = 
		{
			[1] = 
			{ subTypeName = "冒泡说话", 
			  func = "GNpcSay",
			  args = 
					{	
						[1] = { argName = "触发距离", format = "input", type = "number", defualt = "2"},													
						[2] = { argName = "说话内容1", format = "input", type = "string", defualt = "空"},	
						[3] = { argName = "概率1", format = "input", type = "number", defualt = "0"},		
						[4] = { argName = "说话内容2", format = "input", type = "string", defualt = "空"},	
						[5] = { argName = "概率2", format = "input", type = "number", defualt = "0"},	
						[6] = { argName = "说话内容3", format = "input", type = "string", defualt = "空"},	
						[7] = { argName = "概率3", format = "input", type = "number", defualt = "0"},	
						[8] = { argName = "说话内容4", format = "input", type = "string", defualt = "空"},	
						[9] = { argName = "概率4", format = "input", type = "number", defualt = "0"},	
						[10] = { argName = "触发时是否朝向主角", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},	
						[11] = { argName = "说话内容1动作", format = "depend", type = "string", defualt = "none", dependTable = "CommonActions",},	
						[12] = { argName = "说话内容2动作", format = "depend", type = "string", defualt = "none", dependTable = "CommonActions",},	
						[13] = { argName = "说话内容3动作", format  = "depend", type = "string", defualt = "none", dependTable = "CommonActions",},	
						[14] = { argName = "说话内容4动作", format = "depend", type = "string", defualt = "none", dependTable = "CommonActions",},	
					},
			  stringFormat = "冒泡说话:距离[|1|],间隔[|2|],内容[|3|],内容[|5|],内容[|7|],内容[|9|]",
			 },						 
		},

	},

	[4] = 
	{
		mainTypeName = "界面动画指令集",
		cmdList = 
		{
			[1] = 
				{ subTypeName = "生成界面人物", 
				  func = "AddLayerAniPlayer",
				  args = 
						{	
							[1] = { argName = "人物名称", format = "input", type = "string", defualt = "玩家名称",},
							[2] = { argName = "模型编号", format = "input", type = "number", defualt = "130",},
							[3] = { argName = "出生位置", format = "input", type = "number,number", defualt = "0,0"},
							[4] = { argName = "出生是否朝右", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},									
							[5] = { argName = "素材是否朝右", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},																
							[6] = { argName = "人物动态编号", format = "desLabel", type = "number", defualt = "1", isSpawnIdx = true},							
							[7] = { argName = "出现方式", format = "depend", type = "string", defualt = "rotation", dependTable = "LayerAddPlayerMode",},	
							[8] = { argName = "层级", format = "input", type = "number", defualt = "10",},	
							[9] = { argName = "缩放和Y偏移", format = "input", type = "number,number", defualt = "1,0",},	
						},
				  stringFormat = "名称:[|1|],模型:[|2|],出生位置:[|3|],朝向:[|4|],素材是否朝右:[|5|],人物动态编号:[|6|],",
				 },		
			[2] = 
				{ subTypeName = "设置界面人物位置", 
				  func = "SetLayerAniPlayerPos",
				  args = 
						{	
							[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
							[2] = { argName = "目标位置", format = "input", type = "number,number", defualt = "100,100"},							
							[3] = { argName = "是否朝右", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},
						},
			 	  stringFormat = "名称:[|1|],目标位置:[|2|],人物朝向:[|3|]",						
				 },	
			[3] = 
				{ subTypeName = "设置界面人物朝向", 
				  func = "SetLayerAniPlayerFaceTo",
				  args = 
						{	
							[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
							[2] = { argName = "是否朝右", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},									
						},
			 	  stringFormat = "名称:[|1|],人物朝向:[|2|]",							
				 },	
			[4] = 
			{ subTypeName = "设置界面人物是否可见", 
			  func = "SetLayerAniPlayerActive",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "是否可见", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},						
						[3] = { argName = "是否渐变", format = "depend", type = "number", defualt = "0", dependTable = "BoolYesOrNo",},						
					},
			  stringFormat = "名称:[|1|],是否可见:[|2|],是否渐变:[|3|]",						
			 },		
			[5] = 
			{ subTypeName = "界面人物冒泡说话", 
			  func = "LayerAniPlayerSay",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "对话内容", format = "input", type = "string", defualt = "输入说话内容", size = {x = 350, y = 60},},						
						[3] = { argName = "说话时间", format = "input", type = "number", defualt = "2"},
					},
			  stringFormat = "名称:[|1|],对话内容:[|2|],对话时间:[|3|]",					
			 },	
			[6] = 
			{ subTypeName = "人物移动", 
			  func = "LayerAniPlayerRunto",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "移动目标位置", format = "input", type = "number,number", defualt = "20,20"},
						[3] = { argName = "是否朝右", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},
					},
			  stringFormat = "名称:[|1|],目标位置:[|2|],目标位置:[|3|]",						
			 },		
			 [7] = 
			{ subTypeName = "界面人物动作", 
			  func = "LayerAniPlayerDoAction",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},
						[2] = { argName = "动作名称", format = "depend", type = "string", defualt = "attack1", dependTable = "LayerAniActionTables"},						
						[3] = { argName = "动作参数", format = "input_string", type = "string", defualt = "none",},
					},
			  help = CDialogueAniCtrl.DependTable.LayerAniActionTables.help,
			  stringFormat = "名称:[|1|],动作名称:[|2|],动作参数:[|3|]",
			 },	
			[8] = 
			{ subTypeName = "界面社交表情", 
			  func = "LayerAniPlayerShowSocialEmoji",
			  args = 
					{	
						[1] = { argName = "人物名称", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},										
						[2] = { argName = "社交表情", format = "depend", type = "string", defualt = "dian", dependTable = "SocialEmojiTable",},	
						[3] = { argName = "是否显示", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},	
					},
			  stringFormat = "名称:[|1|],社交表情:[|2|],是否显示:[|3|]",
			 },		
			[9] = 
			{ subTypeName = "界面镜头缩放", 
			  func = "LayerAniCameraScale",
			  args = 
					{	
						[1] = { argName = "忽略参数", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},										
						[2] = { argName = "是否拉缩镜头", format = "depend", type = "number", defualt = "1", dependTable = "BoolYesOrNo",},
						[3] = { argName = "拉缩中心点", format = "input", type = "number,number", defualt = "0,0",},	
						[4] = { argName = "拉缩时间", format = "input", type = "number", defualt = "1",},
						[5] = { argName = "拉缩倍率", format = "input", type = "number", defualt = "1.7",},
					},
			  stringFormat = "是否拉缩镜头:[|2|],拉缩中心点:[|2|],拉缩时间:[|3|],拉缩倍率:[|3|]",
			 },	
			[10] = 
			{ subTypeName = "设置界面人物层级", 
			  func = "SetLayerAniPlayerDepth",
			  args = 
					{	
						[1] = { argName = "忽略参数", format = "desLabel", type = "number", defualt = "未创建玩家", isPlayerIdx = true,},										
						[2] = { argName = "人物层级", format = "input", type = "number", defualt = "10",},
					},
			  stringFormat = "人物层级:[|2|]",
			 },				 
		},
	},
}

define.DialogueAni = {
	Event = 
	{
		PlayAni = 1,
		EndAni = 2,	
		EndAllAni = 3,	
		PlayAniSpeed = 4,
	},

	TriggerEnum = {
		Nil = 1,
		OutScreen = 2,
		InScreen = 3,
	},
}

CDialogueAniCtrl.StoryType = 
{
	[1] = {name = "普通剧场", type = 0, group = 1, cmdListTable = {1, 2},},
	[2] = {name = "主线剧场", type = 1, group = 1, cmdListTable = {1, 2},},
	[3] = {name = "常驻NPC剧场", type = 2, group = 2, cmdListTable = {3},},
	[4] = {name = "界面剧场", type = 3, group = 3, cmdListTable = {2, 4},},
}

function CDialogueAniCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:InitValue()
end

function CDialogueAniCtrl.InitValue(self)
	self.m_Idx = 1
	if self.m_DialogueUnitiList and next(self.m_DialogueUnitiList) then
		for i = 1, #self.m_DialogueUnitiList do
			local oUnit = self.m_DialogueUnitiList[i]
			if oUnit then
				oUnit:Update(dt)
			end
		end
	end
	self.m_DialogueUnitiList = {}
	self.m_DialogueWaitingList = {}
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
		local oView = CDialogueAniView:GetView()
		if oView then
			oView:CloseView()
		end
	end
	--待播放剧情缓存
	self.m_TaskUnPlayStroyList = {}

	--剧情动画播放结束后，地图加载完毕(地图加载完毕之后，才会继续执行下一段剧情动画)
	self.m_StoryAniMapLoadDone = true

	--出现剧情界面时，隐藏特殊的界面
	self.m_HideView = {}

	self.m_IsPause = false

	self.m_DelayCheckCameraNpcId = nil

	--播放剧情时，需要切换地图的缓存
	self.m_CacheMapInfo = nil 

	self.m_AniPlaySpeed = 1

	self.m_JumpTimeCache = {}

	if self.m_BaseEffectRoot then
		self.m_BaseEffectRoot:Destroy()
		self.m_BaseEffectRoot = nil
	end
	if self.m_SwitchEffectTimer then
		Utils.DelTimer(self.m_SwitchEffectTimer)
		self.m_SwitchEffectTimer = nil
	end
	
	--记录某个普通剧场是一组的
	self.m_GroupAnis = {}

	self.m_ChapterLastLevel = 0
	self.m_ChaterPassDialogueAniId = 0
end

function CDialogueAniCtrl.NewDialogueUnit(self, id, triggerNpc)
	self.m_IsPause = false
	local oUnit = CDialogueAniUnit.New(id, self.m_Idx, triggerNpc)
	oUnit:BuildCmds()
	table.insert(self.m_DialogueUnitiList, oUnit)
	self.m_Idx = self.m_Idx + 1
	oUnit:Start()
	self:CheckUpdateTimer()
	self:OnEvent(define.DialogueAni.Event.PlayAni, id)
end

function CDialogueAniCtrl.Update(self, dt)
	if g_WarCtrl:IsWar() then
		return true
	end
	local hasWaiting = true
	--先判断等待队列有没有可以播放的剧情
	if #self.m_DialogueWaitingList > 0 then
		for i = 1,  #self.m_DialogueWaitingList do		
			local d = self.m_DialogueWaitingList[i]			
			if self:CheckTriggerInScreen(d.triggerNpc) == define.DialogueAni.TriggerEnum.InScreen or 
				((self:IsStroyAniData(d.id) or self:IsLayerAniData(d.id)) and self:StoryAniStartContition()) or g_HouseCtrl:IsInHouse() then
				self:NewDialogueUnit(d.id, d.triggerNpc)			
				table.remove(self.m_DialogueWaitingList, i)			
				break				
			end
		end
	else
		hasWaiting = false
	end

	if #self.m_DialogueUnitiList > 0 then
		if self.m_IsPause == false then
			for i = 1, #self.m_DialogueUnitiList do
				local oUnit = self.m_DialogueUnitiList[i]
				if oUnit then
					oUnit:Update(dt)
				end
			end
		end
	else
		if not hasWaiting then
			return false
		end		
	end
	return true
end

function CDialogueAniCtrl.PlayDialgueAni(self, id, triggerNpc)	
	--检测剧情触发等级
	if not self:CheckTriggerLevel(id) then
		return 
	end

	--该点的触发剧情已经播放时，则忽略这次触发(是同一组的也忽略)
	for i = 1, #self.m_DialogueUnitiList do 
		local oUnit = self.m_DialogueUnitiList[i] 
		local GroupAnis = self.m_GroupAnis[oUnit.m_Id]
		if GroupAnis and next(GroupAnis) then
			for i, v in ipairs(GroupAnis) do
				if v == id then
					return
				end
			end
		end
	end

	--该点的触发剧情在等待队列时，则忽略这次触发(是同一组的也忽略)
	for i = 1, #self.m_DialogueWaitingList do 
		local oUnit = self.m_DialogueWaitingList[i] 
		local GroupAnis = self.m_GroupAnis[oUnit.id]
		if GroupAnis and next(GroupAnis) then
			for i, v in ipairs(GroupAnis) do
				if v == id then
					return
				end
			end
		end
	end

	--如果该剧情是主线剧情，则先停止其他剧情
	if self:IsStroyAniData(id) then
		local mapInfo = self:GetStroyAniMapInfo(id) 
		if mapInfo and self:SwitchDialogueAniMap(mapInfo) then
			self.m_TaskUnPlayStroyList[id] = true				
			return			
		end

		--删除场景的玩家
		g_DialogueAniCtrl:StopAllDialogueAni()
		if tonumber(id) ~= 888 then
			g_MapCtrl:Clear()
			self.m_StoryAniMapLoadDone = false			
			--第一个剧情，不需要淡入
			--g_NotifyCtrl:ShowAniSwitchBlackBg(1, false)
		end		
	end

	--插入等待队列，
	local d = {id = id, triggerNpc = triggerNpc}
	table.insert(self.m_DialogueWaitingList, d)
	table.print(self.m_DialogueWaitingList)
	self:CheckUpdateTimer()
	--self:NewDialogueUnit(id, triggerNpc)
end

--循环播放剧场的时候，检测剧场是不是有同一组
function CDialogueAniCtrl.RePlayDialgueAni(self, id, triggerNpc )
	local anis = self.m_GroupAnis[id]
	if anis and next(anis) then
		if #anis > 1 then			
			local index = table.index(anis, id)
			if index >= #anis then
				index = 1 
			else
				index = index + 1
			end
			self:PlayDialgueAni(anis[index], triggerNpc)
		else
			self:PlayDialgueAni(anis[1], triggerNpc)
		end
	else
		self:PlayDialgueAni(id, triggerNpc)
	end
end

--编辑器中预览剧情，忽略Npctype
function CDialogueAniCtrl.TestPlayDialgueAni(self, id)
	if self:IsStroyAniData(id) then		
		--删除场景的玩家
		g_MapCtrl:Clear()
		g_DialogueAniCtrl:StopAllDialogueAni()
	end
	self:NewDialogueUnit(id)
end

--id 结束剧情的id
--是否由剧情传过来的结束（如果是，则不再处理该剧情的清理）
--isForceEnd 强制停止，忽略离开触发点设置参数
function CDialogueAniCtrl.StopDialgueAni(self, id, isEnd, isForceEnd)
	--如果在等待队列中，则直接删除等待队列的剧情
	for i = 1, #self.m_DialogueWaitingList do
		local d = self.m_DialogueWaitingList[i]
		if d.id == id then
			table.remove(self.m_DialogueWaitingList, i)
		end
	end

	for i = 1, #self.m_DialogueUnitiList do 
		local oUnit = self.m_DialogueUnitiList[i] 
		if oUnit and oUnit.m_Id == id then
			--如果是强制结束，忽略离开触发点设置参数
			if isForceEnd then
				if not isEnd then
					oUnit:End()				
				end			
			else
				if not oUnit:IsTrigger() then
					if not isEnd then
						oUnit:End()				
					end	
				end
			end					
			table.remove(self.m_DialogueUnitiList, i)
			self:OnEvent(define.DialogueAni.Event.EndAni, id)
			break
		end
	end
	self:CheckUpdateTimer()
end

--全部强制停止，忽略离开触发点设置参数
function CDialogueAniCtrl.StopAllDialogueAni(self, isForce)
	self.m_DialogueWaitingList = {}	
	for i = 1, #self.m_DialogueUnitiList do 
		local oUnit = self.m_DialogueUnitiList[i] 
		if oUnit then			
			oUnit:End(isForce)
		end
	end
	self.m_DialogueUnitiList = {}
	self:CheckUpdateTimer()
	self:OnEvent(define.DialogueAni.Event.EndAllAni)
end

function CDialogueAniCtrl.CheckUpdateTimer(self)
	if #self.m_DialogueWaitingList > 0 or #self.m_DialogueUnitiList > 0  then
		if not self.m_Timer then
			self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0.0, 0)
		end
	else
		if self.m_Timer ~= nil then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end
	end
end

function CDialogueAniCtrl.IsDialogueAniRuning(self, id)
	local b = false
	for i = 1, #self.m_DialogueUnitiList do 
		local oUnit = self.m_DialogueUnitiList[i] 
		if oUnit and oUnit.m_Id == id then
			b = oUnit:IsRunning()
		end
	end
	return b
end

--把指令格式化显示字符串
--cmd 目标指令
--idx 如果为不空，则获取对应位置的参数的字符串
function CDialogueAniCtrl.CmdArgsConvertString(self, cmd, idx)
	if not cmd then
		return ""
	end
	local cmdFormat = nil
	local nameList = nil
	local str = ""
	for m , cmdList in ipairs(CDialogueAniCtrl.CmdConfig) do
		if next(cmdList.cmdList) then
			for s, oCmd in ipairs(cmdList.cmdList) do
				if oCmd.func == cmd.func then
					cmdFormat = oCmd
					break
				end
			end
		end
	end
	if cmdFormat and cmdFormat.stringFormat and cmdFormat.stringFormat ~= "" then
		str = cmdFormat.stringFormat
		if #cmdFormat.args > 0 then
			for i = 1, #cmdFormat.args do
				local format = string.format("|%d|", i)
				local temp = ""
				if cmdFormat.args[i] then
					if cmdFormat.args[i].type == "string" then
						if cmd.args[i] and cmd.args[i][1] then
							temp = tostring(cmd.args[i][1]) 
						else
							temp = tostring(cmdFormat.args[i].defualt) 
						end
						
					elseif cmdFormat.args[i].type == "number" then
						if cmdFormat.args[i].isPlayerIdx then
							if not nameList then
								nameList = self:GetAddPlayerNameList()
							end
							temp = nameList[ tonumber(cmd.args[i][1])]						
						else
							if cmd.args[i] and cmd.args[i][1] then
								temp = tostring(cmd.args[i][1]) 
							else
								temp = tostring(cmdFormat.args[i].defualt) 
							end							
						end					
					elseif cmdFormat.args[i].type == "number,number" then
						if (not cmd.args[i]) or ( not cmd.args[i][1]) or ( not cmd.args[i][2] ) then
							temp = tostring(cmdFormat.args[i][1])..","..tostring(cmdFormat.args[i][2])  
						else
							temp = tostring(cmd.args[i][1])..","..tostring(cmd.args[i][2])  
						end						
					elseif cmdFormat.args[i].type == "number,number,number" then
						temp = tostring(cmd.args[i][1])..","..tostring(cmd.args[i][2])..","..tostring(cmd.args[i][3]) 
					end		
				end

				if idx == i then
					return temp
				end			
				str = string.replace(str, format, temp)
			end
		end
	end
	return str
end

function CDialogueAniCtrl.GetAddPlayerNameList(self)
	local t = {}
	local d = nil
	local oView = CEditorDialogueNpcAnimView:GetView()
	if oView then
		d = oView.m_CmdLists
	else
		local id = IOTools.GetClientData("editor_dialogue_ani_id") or 10000	
		local temp = self:GetFileData(id)
		if temp then
			d = temp.DATA
		else
			d = {}
		end
	end

	if d and next(d) and #d > 0 then
		for i = 1 , #d do
			if next(d[i].cmdList) then
				for k, cmd in ipairs(d[i].cmdList) do
					if cmd.func == "AddPlayer" or cmd.func == "AddLayerAniPlayer" then
						table.insert(t, tostring(cmd.args[1][1]))
					end
				end
			end
		end
	end
	return t
end

function CDialogueAniCtrl.GetCurEidtCmdLists(self)
	local t = {}
	local oView = CEditorDialogueNpcAnimView:GetView()
	if oView and oView.m_CmdLists and next(oView.m_CmdLists) and #oView.m_CmdLists > 0 then
		t = oView.m_CmdLists
	end
	return t
end

function CDialogueAniCtrl.GetCurEidtConfig(self)
	local t = {}
	local oView = CEditorDialogueNpcAnimView:GetView()
	if oView and oView.m_CmdLists and next(oView.m_Config) then
		t = oView.m_Config
	end
	return t
end

function CDialogueAniCtrl.GetFileData(self, id)
	local s = string.format("dialoge_ani_%d", id)
	local b, m = pcall(require, "logic.dialogue.dialogueanifile."..s)
	if b then
		return m
	end
end

function CDialogueAniCtrl.CheckTriggerInScreen(self, npcType)
	local b = define.DialogueAni.TriggerEnum.Nil
	local npcId = g_MapCtrl:GetNpcIdByNpcType(npcType)
	if npcId then
		local  npc = g_MapCtrl:GetNpc(npcId)
		if npc then
			local vWorldPos = npc:GetPos()
			local oCam = g_CameraCtrl:GetMainCamera()
			local vViewPos = oCam:WorldToViewportPoint(vWorldPos)
			if vViewPos.x < 1.1 and vViewPos.x > -0.1 and vViewPos.y < 1.1 and vViewPos.y > -0.1 then				
				b = define.DialogueAni.TriggerEnum.InScreen
			else
				b = define.DialogueAni.TriggerEnum.OutScreen
			end
		end
	end
	return b
end

function CDialogueAniCtrl.ResetCtrl(self)
	self:StopAllDialogueAni(true)
	self:InitValue()
end

function CDialogueAniCtrl.IsInPlayStoryAni(self)
	local b = false
	if next(self.m_DialogueUnitiList) then
		for i = 1, #self.m_DialogueUnitiList do 
			local oUnit = self.m_DialogueUnitiList[i] 
			if oUnit and oUnit.m_Config and oUnit.m_Config.isStroy == 1 then			
				b = true
				return b
			end
		end
	end
	if next(self.m_DialogueWaitingList) then
		for i = 1, #self.m_DialogueWaitingList do 
			local d = self.m_DialogueWaitingList[i]	
			if self:IsStroyAniData(d.id) then
				b = true
				return b
			end
		end
	end
	return b
end

--当场景加载完毕，会清理一次所有的剧情，但是在之前可能NPC已经加载完了
--所以在重新检测哪些剧情已经触发
function CDialogueAniCtrl.CheckAllAniWhenMapLoadDone(self)
	-- 如果当前有在播放主线剧情，则忽略 
	if not self:IsInPlayStoryAni() then
		self:StopAllDialogueAni()	
	end


	self.m_StoryAniMapLoadDone = true

	--先判断是否有主线剧情任务
	if next(self.m_TaskUnPlayStroyList) then
		for k, v in pairs(self.m_TaskUnPlayStroyList) do
			self.m_TaskUnPlayStroyList[k] = nil
			self:PlayDialgueAni(k)
			return
		end
	end

	if g_MapCtrl.m_Npcs then
		for k, npc in pairs(g_MapCtrl.m_Npcs) do
			if npc.m_DialogAnimationId then
				self:PlayDialgueAni(npc.m_DialogAnimationId, npc.m_NpcAoi.npctype)
			end
		end
	end
end

--判断是否达成剧情触发等级
function CDialogueAniCtrl.CheckTriggerLevel(self, id)
	local b = true
	--if not CEditorDialogueNpcAnimView:GetView() then
	local t = g_DialogueAniCtrl:GetFileData(id)
	if t then
		local config = t.CONFIG
		if config.minTriggerLevel and config.minTriggerLevel ~= 0 then
			b = g_AttrCtrl.grade >= config.minTriggerLevel
		end			
	end
	--end
	return b
end

--是否是主线剧情剧本
function CDialogueAniCtrl.IsStroyAniData(self, id)
	local b = false
	local t = g_DialogueAniCtrl:GetFileData(id)
	if t and t.CONFIG then
		b = (t.CONFIG.isStroy == 1)
	end
	return b
end

--是否是主线剧情剧本
function CDialogueAniCtrl.IsLayerAniData(self, id)
	local b = false
	local t = g_DialogueAniCtrl:GetFileData(id)
	if t and t.CONFIG then
		b = (t.CONFIG.isStroy == 3)
	end
	return b
end

function CDialogueAniCtrl.InsetUnPlayList(self, storyId, delayPlay)
	if self:StoryAniStartContition() and self.m_StoryAniMapLoadDone == true and delayPlay ~= true then
		self:PlayDialgueAni(storyId)
	else
		self.m_TaskUnPlayStroyList[storyId] = true	
	end
end

function CDialogueAniCtrl.StoryAniStartContition(self)
	local b = false
	if (g_MainMenuCtrl:GetMainmenuViewActive() or CDialogueAniView:GetView() ~= nil ) and not g_MapCtrl:IsWarMap() then 
		b = true
	end
	return b
end

function CDialogueAniCtrl.SetCacheProto(self, b)
	g_NetCtrl:SetCacheProto("dialogueani", b)
	g_NetCtrl:ClearCacheProto("dialogueani", true)	
end

--显示对话界面时，隐藏其他所有界面	
function CDialogueAniCtrl.HideViewsWhenShowDialougeAniView(self)
	local HideViewTable = 
	{
	 	["CAchieveFinishTipsView"] = true,
	 	["CItemQuickUseView"] = true,
	 	["CBottomView"] = true,
	 	["CNotifyView"] = true,
	 	["CDialogueLayerAniView"] = true,
	}
	local t = g_ViewCtrl.m_Views
	if t and next(t) then
		for k, oView in pairs(t) do
			if oView:GetActive() == true and HideViewTable[oView.classname] == nil then
				oView:SetActive(false)
				table.insert(self.m_HideView, oView)
			end
		end
	end
end

function CDialogueAniCtrl.ShowViewsWhenCloseDialougeAniView(self)
	if not next(self.m_HideView) then
		return
	end
	for i = 1, #self.m_HideView do
		local oView = self.m_HideView[i]
		if not Utils.IsNil(oView) and oView:GetActive() == false then
			oView:SetActive(true)
		end
	end
	self.m_HideView = {}
end

--剧本的指令生成常驻NPC指令
function CDialogueAniCtrl.SpawnGlobalNpcDialogueAni(self, d)
	local t = {}
	if d and next(d) then
		t.loop = d.CONFIG.isLoop
		t.interval_time = d.CONFIG.loopTime
		t.type = 2
		local cmdList = {}
		local time = 0 
		for i = 1, #d.DATA do
			local list = d.DATA[i]
			for k = 1, #list.cmdList do
				cmdList[time] = cmdList[time] or {}
				local info = table.copy(list.cmdList[k]) 
				local cmd = {}	
				cmd.args = {}		
				cmd.func = info.func		
				if info.func == "GNpcSay" then
					t.distance = tonumber(info.args[1][1])					
					table.remove(info.args, 1)						
					local temp = {}
					local rare = 0
					for j = 1, 8 do
						if j % 2 == 1 then
							temp = {}
							if info.args[j][1] == "空" then
								break
							else
								temp.str = info.args[j][1]
							end
						else
							temp.rare = temp.rare or 0
							temp.rare = rare + tonumber(info.args[j][1])
							rare = temp.rare
							table.insert(cmd.args, temp)
						end
					end							
					cmd.isFacetoHero = 0
					if info.args[9] and info.args[9][1] then
						cmd.isFacetoHero = tonumber(info.args[9][1])
					end
					cmd.action = {}
					local x = 1
					for j = 10, 13 do
						cmd.action[x] = "none"
						if info.args[j] and info.args[j][1] then
							cmd.action[x] = info.args[j][1]
						end
						x = x + 1
					end	
				end
				table.insert(cmdList[time], cmd)
			end
			time = time + list.delay
		end
		t.cmdList = cmdList
		t.total_time = time

	end

	return t
end

function CDialogueAniCtrl.PauseStoryAni(self)
	self.m_IsPause = true
end

function CDialogueAniCtrl.ResumeStoryAni(self)
	self.m_IsPause = false
end

function CDialogueAniCtrl.IsPause(self)
	return self.m_IsPause
end

--剧场结束时，触发另一段剧场
function CDialogueAniCtrl.UtilsEndPlayOtherDiialoueAni(self, aniId)
	local id = aniId
	local cb = function ()
		self:InsetUnPlayList(id)
	end
	Utils.AddTimer(cb, 0, 0)
end

--获取剧本播放的地图
function CDialogueAniCtrl.GetStroyAniMapInfo(self, id)
	local mapInfo = nil
	local t = g_DialogueAniCtrl:GetFileData(id)
	if t and t.CONFIG then
		if t.CONFIG.mapInfo and t.CONFIG.mapInfo ~= "" then
			local info = string.split(t.CONFIG.mapInfo, ",")
			if #info == 3 then
				mapInfo = {}
				mapInfo.mapId = tonumber(info[1])
				mapInfo.x = tonumber(info[2])
				mapInfo.y = tonumber(info[3])
			end
		end
	end
	return mapInfo
end


--切换地图
function CDialogueAniCtrl.SwitchDialogueAniMap(self, mapInfo)
	if not mapInfo.mapId or mapInfo.mapId == g_MapCtrl:GetMapID() or g_MapCtrl.m_MapLoding == true then
		return
	end
	local sceneid = g_MapCtrl:GetSceneID()
	local mapid = mapInfo.mapId
	local scenename = g_MapCtrl:GetSceneName()
	local eid = 0
	local hero = g_MapCtrl:GetHero()
	if hero then
		eid = hero.m_Eid
	end
	local posinfo = {}
	posinfo.x = mapInfo.x
	posinfo.y = mapInfo.y
	posinfo.z = 0
	g_MapCtrl:ShowScene(sceneid, mapid, scenename)
	g_MapCtrl:EnterScene(eid, posinfo)
	return true
end

function CDialogueAniCtrl.SetDelayCheckDialogueAniCamera(self, npcId)
	self.m_DelayCheckCameraNpcId = npcId
end

function CDialogueAniCtrl.DelayCheckDialogueAniCamera(self)
	if self.m_DelayCheckCameraNpcId then
		local npc = g_MapCtrl:GetDialogueNpc(self.m_DelayCheckCameraNpcId)
		if npc then
			local oCam = g_CameraCtrl:GetMapCamera()
			oCam:Follow(npc.m_Transform)
			oCam:SyncTargetPos()		
			self.m_DelayCheckCameraNpcId = nil	
		end		
	end
end

function CDialogueAniCtrl.SwitchEffect(self, switchId)
	if switchId == 888 then
		g_GuideCtrl:ReqCustomGuideFinish("welcome_three_end")
		nettask.C2GSEnterShow(0, 1)
		g_NotifyCtrl:ShowAniSwitchBlackBg(2)
		local cb = function ( )
			local cb1 = function ()		
				local oHero = g_MapCtrl:GetHero()
				if oHero then
					local pos_info = {x=27,y=25,face_y=125}
					netscene.C2GSFlyToPos(pos_info, 101000)								
				end				
			end
			local cb2 = function ()
				CDialogueAniView:CloseView()
			end
			local oView = CDialogueAniView:GetView()
			if oView then
					g_NotifyCtrl:CloseAniSwitchBox()
					oView:SetBulletActive(false)			
					oView:SetContent()							
					oView:ShowAniBgTexture(false)	
					oView:ShowLive2D(false)
					oView:SetMaskAniMode2Cb(cb1, cb2)
					oView:ShowCoverMask(true, 5)	
					oView:SetDialogueMidTexture(false)			
			else				
				CDialogueAniView:ShowView(function(oView)
					g_NotifyCtrl:CloseAniSwitchBox()
					oView:SetBulletActive(false)			
					oView:SetContent()							
					oView:ShowAniBgTexture(false)	
					oView:ShowLive2D(false)
					oView:SetMaskAniMode2Cb(cb1, cb2)
					oView:ShowCoverMask(true, 5)	
					oView:SetDialogueMidTexture(false)	
				end)
			end
		end
		if self.m_SwitchEffectTimer then
			Utils.DelTimer(self.m_SwitchEffectTimer)
			self.m_SwitchEffectTimer = nil
		end
		self.m_SwitchEffectTimer = Utils.AddTimer(cb, 0, 1)

	elseif switchId == 10509 then 
		g_GuideCtrl:LoadShowWarGuide()						
		-- local function cb()
		-- 	local d = {}		
		-- 	local dialog ={}
		-- 	dialog[1] = 
		-- 	{
		-- 		content = "这里是哪？那边……好像有人……",
		-- 		next = "0",
		-- 		pre_id_list = "0",
		-- 		status = 2,
		-- 		subid = 1,
		-- 		type = 2,
		-- 		ui_mode = 2,
		-- 		voice = 0,
		-- 		hide_back_jump = true,
		-- 	}
		-- 	d.dialog = dialog
		-- 	d.dialog_id = CDialogueCtrl.DIALOUGE_10509_ID
		-- 	d.npcid = 0
		-- 	d.npc_name = "我"
		-- 	d.shape = g_AttrCtrl.model_info.shape
		-- 	local oHero = g_MapCtrl:GetHero()
		-- 	if oHero then
		-- 		oHero:StopWalk()							
		-- 	end				
		-- 	local oView = CDialogueMainView:GetView()
		-- 	if oView then
		-- 		oView:SetContent(d)
		-- 		g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, d)
		-- 	else
		-- 		CDialogueMainView:ShowView(function (oView)
		-- 			oView:SetContent(d)
		-- 			g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, d)
		-- 		end)	
		-- 	end		
		-- end
		-- Utils.AddTimer(cb, 0, 1)
	end
end

function CDialogueAniCtrl.ChangeAniPlaySpeed(self)
	local t = {1, 3}
	local i = table.index(t, self.m_AniPlaySpeed) + 1
	if i > #t then
		i = 1
	end
	self.m_AniPlaySpeed = t[i]

	local dialogueNpcs = g_MapCtrl.m_DialogueNpcs 
	if dialogueNpcs and next(dialogueNpcs) then
		for k, npc in pairs(dialogueNpcs) do
			if npc and npc.m_IsStoryNpc then
				npc:SetMoveSpeed(define.Walker.Move_Speed * self.m_AniPlaySpeed)
			end	
		end
	end
	self:OnEvent(define.DialogueAni.Event.PlayAniSpeed)
end

function CDialogueAniCtrl.GetAniPlaySpeed(self)
	return self.m_AniPlaySpeed
end

function CDialogueAniCtrl.ReSetPlaySpeed(self)
	if self.m_AniPlaySpeed ~= 1 then
		self.m_AniPlaySpeed = 1
	end
	self:OnEvent(define.DialogueAni.Event.PlayAniSpeed)
end

function CDialogueAniCtrl.GetEffctBaseRoot(self)
	if not self.m_BaseEffectRoot then		
		self.m_BaseEffectRoot = CObject.New(UnityEngine.GameObject.New())
		self.m_BaseEffectRoot:SetName("DialogueAniBaseEffectRoot")
	end
	return self.m_BaseEffectRoot
end

function CDialogueAniCtrl.SetDialogueAniJump(self, id, time)
	if id and time and time ~= 0 then
		self.m_JumpTimeCache[id] = time
	end
end

function CDialogueAniCtrl.GetEmojiSprName(self, type)
	local spriteName = "pic_emoji_wuyu_1"
	if type == "dian" then
		spriteName = "pic_emoji_dian"

	elseif type == "kaixin" then
		spriteName = "pic_emoji_kaixin"

	elseif type == "mengbi" then
		spriteName = "pic_emoji_mengbi"

	elseif type == "mihu" then
		spriteName = "pic_emoji_mihu"

	elseif type == "shengqi" then
		spriteName = "pic_emoji_shengqi"

	elseif type == "weiqu" then
		spriteName = "pic_emoji_weiqu"

	elseif type == "wuyu1" then
		spriteName = "pic_emoji_wuyu_1"

	elseif type == "wuyu2" then
		spriteName = "pic_emoji_wuyu_2"

	elseif type == "wuyu3" then
		spriteName = "pic_emoji_wuyu_3"

	elseif type == "zhenjing" then
		spriteName = "pic_emoji_zhenjing"
	end
	return spriteName
end

function CDialogueAniCtrl.GetDialogueAniIdByChapterLevel(self, chapter, level)
	local id = 0
	local d = data.chapterfubendata.Config
	if d[chapter] and d[chapter][level] then
		id = d[chapter][level].pass_dialogueani_id
	end
	return id
end

function CDialogueAniCtrl.CacheChapterAniInfo(self, chapter, level)
	self.m_ChapterLastLevel = chapter * 100 + level
	self.m_ChaterPassDialogueAniId = self:GetDialogueAniIdByChapterLevel(chapter, level)
end

function CDialogueAniCtrl.CheckPlayChaterDialougeAni(self)
	local b = false
	if self.m_ChaterPassDialogueAniId ~= 0 and self.m_ChapterLastLevel ~= 0 then
		local chapter = math.floor(self.m_ChapterLastLevel/100)
		local level = self.m_ChapterLastLevel % 100
		if g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, chapter, level) then
			self:InsetUnPlayList(self.m_ChaterPassDialogueAniId)
			self.m_ChapterLastLevel = 0
			self.m_ChaterPassDialogueAniId = 0
			b = true
		end
	end
	return b
end

function CDialogueAniCtrl.SetDialugeAniGroup(self, anis)
	if anis then
		local t = {}
		for i, v in ipairs(anis) do			
			table.insert(t, tonumber(v))
		end	
		for i, v in ipairs(t) do			
			self.m_GroupAnis[v] = t
		end
	end
end

-----------------------------界面动画处理相关
--界面动画寻路
function CDialogueAniCtrl.FindMapPath(self, s_pos, e_pos, mapId)
	mapId = mapId or 3012
	local navidata = data.dialoguelayeraninvdata.DATA[mapId]
	if not navidata then
		return {}
	end
	printc(">>>>>>>>>>  ", mapId)
	table.print(s_pos)
	table.print(e_pos)

	if not next(s_pos) or not next(e_pos) or (s_pos.x == e_pos.x and s_pos.y == e_pos.y) then
		return {}
	end 
	local open = {}
	local close = {}
	local d = {}
	d.x = s_pos.x
	d.y = s_pos.y 
	d.step = 0
	d.parent = 0

	local isFind = false
	table.insert(open, d)

	local function get_weight_pos(open_list, end_pos)
		local m = nil
		local s = 0
		local dis = 0
		for k, v in pairs(open_list) do
			local tDis = math.abs(end_pos.x - v.x) + math.abs( end_pos.y  - v.y)
			if m == nil then
				m = v
				s = v.step
				dis = tDis
			elseif tDis < dis or (tDis == dis and s > v.step) then
				m = v
				s = v.step	
				dis = tDis			
			end			
		end
		return m
	end
	
	local function del_open_list(pos, open_list)
		for k, v in pairs(open_list) do
			if pos.x == v.x and pos.y == v.y then
				table.remove(open_list, k)				
				break
			end
		end
	end
	local function add_close_list(pos, close_list)
		table.insert(close_list, pos)
	end

	local function get_around_pos_array(pos, navi, b)
		local t = {}
		--八方向
		for _x = -1, 1 do					
			for _y = -1, 1 do			
				if not (_x == 0 and _y == 0 ) then				
					if navi[pos.x + _x] and navi[pos.x + _x][pos.y + _y] == 1 then
						table.insert(t, {x = pos.x + _x, y = pos.y + _y})
					end
				end				
			end			
		end

		--四方向点
		--左侧点
		-- if navi[pos.x - 1] and navi[pos.x - 1][pos.y] == 1 then
		-- 	table.insert(t, {x = pos.x - 1, y = pos.y})
		-- end
		-- --上侧点
		-- if navi[pos.x][pos.y - 1] == 1 then
		-- 	table.insert(t, {x = pos.x, y = pos.y - 1})
		-- end
		-- --右侧点
		-- if navi[pos.x + 1] and navi[pos.x + 1][pos.y] == 1 then
		-- 	table.insert(t, {x = pos.x + 1, y = pos.y})
		-- end
		-- --下侧点
		-- if navi[pos.x][pos.y +1] == 1 then
		-- 	table.insert(t, {x = pos.x, y = pos.y + 1})
		-- end	
		return t
	end

	local function is_not_in_open_and_close(pos, open_list, close_list)
		local b = false
		for k, v in pairs(open_list) do
			if pos.x == v.x and pos.y == v.y then
				b = true
				break
			end
		end
		for k, v in pairs(close_list) do
			if pos.x == v.x and pos.y == v.y then
				b = true
				break
			end
		end
		return b
	end
	local end_find_pos = nil
	local test_idx = 0
	repeat
		test_idx = test_idx + 1
		local cur_pos = get_weight_pos(open, e_pos)
		del_open_list(cur_pos, open)
		add_close_list(cur_pos, close)				
		local t = {}
		--获取该点周围的点
		t = get_around_pos_array(cur_pos, navidata)
		if not next(t) then
			break
		end
		for k, v in pairs(t) do			
			if not is_not_in_open_and_close(v, open, close) then
				local d = {}
				d.x = v.x
				d.y = v.y
				d.step = cur_pos.step + 1
				d.parent = cur_pos.x * 1000 + cur_pos.y
				table.insert(open, d)
				if d.x == e_pos.x and d.y == e_pos.y then
					isFind = true
					end_find_pos = d
					break
				end					
			end
		end		
	until isFind == true	
	
	local way_path = {}
	table.insert(way_path, end_find_pos)
	local is_start_pos = false					
	local cur_d = end_find_pos
	repeat
		local id = cur_d.parent
		local d = nil
		for k, v in pairs(close) do
			if v.x * 1000 + v.y == id then
				d = v
				break
			end
		end		
		table.insert(way_path, d)
		if id == s_pos.x * 1000 + s_pos.y then
			is_start_pos = true				
		end	
		cur_d = d
	until (is_start_pos == true)

	table.sort(way_path, function (a, b)
		return a.step < b.step
	end)	
	return way_path
end

function CDialogueAniCtrl.SaveLayerAniData(self, mapId, navidata)	
	local d = data.dialoguelayeraninvdata
	if not d then
		d = {}
	else
		d = d.DATA
	end
	d[mapId] = navidata
	local s = "module(...)\n-- guidance editor build\n"..table.dump(d, "DATA").."\n"
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/data/dialoguelayeraninvdata.lua"), s)
	g_NotifyCtrl:FloatMsg(string.format("%d地图导航数据生成完毕", mapId))
end

function CDialogueAniCtrl.GetCellNaviPos(self, oPos)
	local pos = {}
	if oPos.x <= 0 then
		pos.y = 30 + math.floor((oPos.x - 10) / 20) + 1
	else
		pos.y = 30 + math.floor((oPos.x + 10) / 20)
	end 
	pos.x = 15 - math.floor(oPos.y / 20) + 1
	return pos
end

function CDialogueAniCtrl.GetCellLayerPos(self, x, y)
	local pos = {x = 0, y = 0}
	y = y - 30
	pos.x = y * 20 - 10
	x = 15 - x + 1
	pos.y = x * 20
	return pos
end
-----------------------------界面动画处理相关

return CDialogueAniCtrl
