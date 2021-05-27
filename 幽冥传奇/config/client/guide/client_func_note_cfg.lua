ClientFuncNoteState = 
{
	Normal = 0, --没有动作状态
	Noteing = 1,--正在预告状态
	Open = 2,--正在开放状态
}

ClientFuncNoteCfg = 
{
	
	{   --神炉
		id = 1,                               --预告id
		max_level = 45,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {38,41}},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 42,op = ClientOpType.Equ},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_COMPOSE_BTN,is_modal = true},                     --开启指引动作
		icon = 7,                             --系统图标icon
		mainui_icon = 1,
		open_level = 42,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}神炉系统包括血符、神盾、宝石和魂珠。\n{flag}血符增加人物的生命值。\n{flag}神盾增加人物的物理防御和魔法防御。\n{flag}武魂增加人物的物理攻击和魔法攻击。\n{flag}灵珠增加人物的暴击几率和暴击伤害。",
	},
	{   --战神
		id = 2,                               --预告id
		max_level = 24,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {10,23}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 24,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ZHANSHEN_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 2,
		icon = 5,                             --系统图标icon
		open_level = 24,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}英雄总共有战士、法师和道士三种职业。\n{flag}战士英雄独当一面，对于刷BOSS有大大帮助。\n{flag}法师英雄刷怪效率高，对于打怪升级有大大帮助。\n{flag}道士英雄辅助技能多，对于PK打架有大大帮助。",
	},
    {   --锻造
		id = 3,                               --预告id
		max_level = 50,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {24,49}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 50,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_EQUIPBOOST_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 3,
		icon = 8,                             --系统图标icon
		open_level = 50,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}锻造系统包括强化、注灵和合成。\n{flag}强化能够使到装备的属性大幅度提升，越高级的装备可以强化的星阶越高。\n{flag}注灵能够增加装备的属性。\n{flag}合成能够将5件相同的低级装备合成1件高级装备。",
	},
   --[[ {   --成就
		id = 4,                               --预告id
		max_level = 50,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {37,49}},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 50,op = ClientOpType.Equ},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_LILIAN_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 4,
		icon = 10,                             --系统图标icon
		open_level = 50,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}完成各类事件能够获得成就值和物品奖励\n{flag}成就值能够升级勋章，勋章可以提升人物属性",
	},]]
	{   --BOSS
		id = 5,                               --预告id
		max_level = 62,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {58,61}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 62,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_BOSS_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 5,
		icon = 2,                             --系统图标icon
		open_level = 62,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}BOSS系统包括野外BOSS、装备BOSS、玛雅神殿、打宝BOSS和兽魂。\n{flag}击杀BOSS，掉落装备，敢杀就敢爆。\n{flag}兽魂可以通过抽取图腾增加人物的属性。",
	},
	{   --行会
		id = 6,                               --预告id
		max_level = 65,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {62,64}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 65,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ZHENGBA_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 6,
		icon = 27,                             --系统图标icon
		open_level = 65,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}参与沙城争霸，首先你必须加入行会！\n{flag}加入行会可以参与沙城攻城战与土城争夺等活动。\n{flag}加入行会可以享受抢红包功能。",
	},
	{   --寻宝
		id = 7,                               --预告id
		max_level = 68,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {65,67}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 68,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_XUNBAO_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 7,
		icon = 21,                             --系统图标icon
		open_level = 68,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}超珍稀的极品装备就在这里，无需多言！",
	},
	--[[{   --寄售
		id = 8,                               --预告id
		max_level = 64,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {62,63}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 65,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_JISHOU_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 8,
		icon = 14,                             --系统图标icon
		open_level = 65,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}玩家可以通过寄售卖出自己不需要的物品。\n{flag}玩家可以通过寄售买到自己需要的物品。",
	},]]
	{   --转生
		id = 9,                               --预告id
		max_level = 80,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {70,79}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 80,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ROLE_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 13,
		icon = 68,                             --系统图标icon
		open_level = 80,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}人物转生可以提升人物属性和等级上限\n{flag}英雄转生可以提升英雄属性和等级上限。",
	},
	
	{   --翅膀
		id = 11,                               --预告id
		max_level = 58,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{
			{type = ClientGuideConditionType.RoleLevel,value = {50,57}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpLevel,value = 58,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ROLE_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 11,
		icon = 23,                             --系统图标icon
		open_level = 58,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		desc = "{flag}激活翅膀，属性飞涨。\n{flag}酷炫外形，秀，天秀，李天秀，蒂花之秀，造化钟神秀…",
	},
	--[[{   --特戒
		id = 12,                               --预告id
		max_level = 120,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{   {type = ClientGuideConditionType.RoleLevel,value = {80,120}},
			{type = ClientGuideConditionType.RoleCircle,value = 4,op = ClientOpType.Low},
			
		},
		open_conditions =                     --开启条件
		{
			
			{type = ClientGuideConditionType.UpCircle,value = 4,op = ClientOpType.HighEqu},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_COMPOSE_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 12,
		icon = 42,                             --系统图标icon
		open_level = 80,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		mainui_desc = "四转开启",
		desc = "{flag}特戒包括麻痹戒指、复活戒指和护体戒指。\n{flag}战士可拥有麻痹戒指和复活戒指，法师和道士则拥有护体戒指和复活戒指。",
	},
	{   --魂石
		id = 11,                               --预告id
		max_level = 100,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{   
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.HighEqu},
			{type = ClientGuideConditionType.OpenServerDay,value = 3,op = ClientOpType.Low},
		},
		open_conditions =                     --开启条件
		{
			{type = ClientGuideConditionType.UpServerDay,value = 3,op = ClientOpType.HighEqu},
			
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_EQUIPBOOST_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 10,
		icon = 40,                             --系统图标icon
		open_level = 80,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		mainui_desc = "开服第3天开启",
		desc = "{flag}魂石包括生命魂石、魔防魂石、物防魂石、攻击魂石和暴击魂石。\n{flag}迷幻魔城是魂石的重要产出副本。",
	},
	{   --魂石
		id = 12,                               --预告id
		max_level = 100,                       --预告存在的最大等级，只是作为优化性能检测,不作为激活条件
		note_conditions =                     --预告条件
		{   {type = ClientGuideConditionType.RoleLevel,value = {80,100}},
			{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
			{type = ClientGuideConditionType.OpenServerDay,value = 3,op = ClientOpType.HighEqu},
		},
		open_conditions =                     --开启条件
		{
			
			{type = ClientGuideConditionType.UpCircle,value = 1,op = ClientOpType.HighEqu},
		},
		open_action = {type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_EQUIPBOOST_BTN,is_modal = true},                     --开启指引动作
		mainui_icon = 10,
		icon = 40,                             --系统图标icon
		open_level = 80,                      --开启等级，作为文本显示
		state = ClientFuncNoteState.Normal,
		mainui_desc = "一转开启",
		desc = "{flag}魂石包括生命魂石、魔防魂石、物防魂石、攻击魂石和暴击魂石。\n{flag}迷幻魔城是魂石的重要产出副本。",
	},]]
}