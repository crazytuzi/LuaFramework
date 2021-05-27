
-- 任务状态
TaskState = {
	None = -1,				-- 无
	Accept = 0,				-- 进行中(可用)\未接
	NotComplete = 1,		-- 未完成\进行中\已接未交
	Complete = 2,			-- 完成\可交\完成未交\
	Unacceptable = 3,		-- 不进行中
	Submit = 4,           	-- 已交\不存在\已消失
	CanBuy = 5,				-- 可购买
	CanFind = 6,		    -- 可寻找
}

TaskNodeName = {
	iconbar = "iconbar", --一般图标节点
	MainuiRoleBar ="MainuiRoleBar", --人物节点
	Vipbar = "btn_vip", --Vip节点
}

--[[ 任务配置
--txt_content txt_content2 文本替换:
	<target_color> 颜色
	<cur_value> 当前目标完成值
	<target_value> 目标值
	<name> 目标名称
	<id> 目标id
	<npc_name> 任务的npc名称
	<task_title> 任务标题

--touch_command 点击命令:
	{npc = 1} 跑去跟npc对话
	{monster = 1} 根据任务打怪
	{submit_task = 1} 点击完成任务，领取奖励
	{view_link = "Role#Inner"} 打开界面 角色#内功
	{transfer = 78} 根据ChuansongPoint配置的ncpid
	{fuben_id = 78} 根据副本id进入副本

--TaskConfig 格式:
	[任务id] = {
		txt_content = {[任务状态] = "<task_title>",},
		txt_content2 = {[任务状态] = "与{color;1eff00;<npc_name>}对话",},
		touch_command = {[任务状态] = {npc = 1},}
	},

-- 例子:
	[2] = { -- 任务id为2
		txt_content = {[-1] = "<task_title>"}, 												-- txt_content为第一行显示的文本 <task_title>显示标题文本
		txt_content2 = {																	-- txt_content为第二行显示的文本
			[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", 		-- 任务状态为"进行中" 时显示 击杀：鸡（0/3）
			[2] = "与{color;1eff00;<npc_name>}对话",										-- 任务状态为"可交" 时显示 与XXX对话
		}, 
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}}, 							-- 点击后执行命令 任务状态为"进行中" 时 会进行打根据任务打怪	任务状态为"可交" 时 会跑去和npc对话
	},
--]]


--特效id 使用特效一致 使用枚举
TASK_EFFECT_ID = {
	COMPLETE = 313,	--已完成
}

TaskConfig = {
	[1] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[-1] = {npc = 1}},
		showTipDesc = 1,
		
	},
	[2] = {
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "回复{color;1eff00;<npc_name>}"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 2,
	},
	[3] = {
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 3,
	},
	[4] = {
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
	},
	[5] = {
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 4,
	},
	[6] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},
	[7] = {--激活战宠
		txt_content = {[1] = "<task_title>{color;ff0000;(0/1)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "点击领取{color;00ff00;战宠}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "TaskZhanChongEffect",view_index = 1, view_node = TaskNodeName.iconbar,view_link1 ="TaskNewXiTongGuide",view_node_name = "ZhanjiangView", view_def = "ZhanjiangView#ZhangChongView"}, [2] = {submit_task = 1}},
		
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		showTipDesc = 5,
	},
	[8] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},
	[9] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},
	[10] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		showTipDesc = 6,
	},
	[11] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},
	[12] = {
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 7,
	},
	[13] = {
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 8,
	},	
	[14] = {--尸王殿
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {fuben_id = 105}, [2] = {npc = 1}},
		showTipDesc = 9,
    },
	[15] = {--提升战宠
		txt_content = {[1] = "<task_title>{color;ff0000;(0/1)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "点击打开{color;00ff00;战宠}面板", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "ZhanjiangView#ZhangChongView"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		showTipDesc = 10,
    },
	[16] = {--得以相助
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		showTipDesc = 11,
	},
	[17] = {--千钧一发
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 12,
	},
	[18] = {--得以相助
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},
	[19] = {--激战红名村
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {fuben_id = 111}, [2] = {npc = 1}},
    },
	[20] = {--得以相助
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		showTipDesc = 13,
	},
	[21] = {--受人之托
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 14,
	},
	[22] = {--偶遇迷路女
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
	},
	[23] = {--斩杀触龙神
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {fuben_id = 107}, [2] = {npc = 1}},
		showTipDesc = 15,
    },
	[24] = {--提升战宠
		txt_content = {[1] = "<task_title>{color;ff0000;(0/1)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "点击打开{color;00ff00;战宠}面板", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "ZhanjiangView#ZhangChongView"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		showTipDesc = 16,
    },
	[25] = {
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		finish_open_view = {view_link = "TaskNewXiTongGuide",view_index = 2, view_node = TaskNodeName.Vipbar},
		showTipDesc = 17,
    },
	[26] = {--击杀VIP守卫
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "点击前往VIP闯关副本", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = { [2] = {npc = 1}},
		showTipDesc = 18,
	},
	[27] = {--击杀VIP守卫
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "点击前往VIP1专属BOSS", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {view_link = "NewlyBossView#Wild#Specially"},[2] = {npc = 1}},
		showTipDesc = 18,
	},
	[28] = {--激活钻石萌宠
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "激活一只钻石萌宠", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {view_link = "DiamondPet"},[2] = {npc = 1}},
		showTipDesc = 18,
	},
	[29] = {--挖掘怪物
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "挖掘一只怪物", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {fuben_id = 114}, [2] = {npc = 1}},
		showTipDesc = 18,
	},
    [30] = {--升级至200级
		txt_content = {[1] = "<task_title>{color;ff0000;}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "等级达到200级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "GuideLevelUp"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		showTipDesc = 20,
	},
	[31] = {--骷髅成灾
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
		showTipDesc = 21,
	},
	[32] = {--骷髅成灾
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {monster = 1}, [2] = {npc = 1}},
	},
	[33] = {--遇险白野猪
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {fuben_id = 108}, [2] = {npc = 1}},
		showTipDesc = 22,
    },
	[34] = {--回收一次装备
		txt_content = {[1] = "<task_title>{color;ff0000;(0/1)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "{color;00ff00;点击回收装备}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "MainBagView#BagView"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		showTipDesc = 23,
	},
	[35] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1 ,view_pos = "Shop#Prop"}},
    },
	[36] = {--升级至250级
		txt_content = {[1] = "<task_title>{color;ff0000;}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "等级达到250级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "GuideLevelUp"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		showTipDesc = 25,
	},
    [37] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		showTipDesc = 26,
    },
	[38] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		showTipDesc = 27,
    },
	[39] = {--穿戴装备
		txt_content = {[1] = "<task_title>{color;ff0000;}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴:220级以上装备{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "TaskEquipGetGuide"},[2] = {npc = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
	},
	[40] = {--重温沙城
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:敌方行会成员", [2] = "点击领取奖励"},
		touch_command = {[1] = {fuben_id = 109,view_link = "TaskShaChengGuide", view_index = 5}, [2] = {npc = 1}},
		finish_open_view = {view_link = "TaskShaChengResultGuide"},
		showTipDesc = 28,
    },
    [41] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
    },
	[42] = {--击杀VIP守卫
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀:<name>{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[2] = {npc = 1}},
		showTipDesc = 18,
	},
	[43] = {--穿戴装备
		txt_content = {[1] = "<task_title>{color;ff0000;}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴:280级以上装备{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "TaskEquipGetGuide"},[2] = {npc = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
	},

 	[44] = {--升级至300级
		txt_content = {[1] = "<task_title>{color;ff0000;}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "等级提升至300级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "GuideLevelUp"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
	},
 	[45] = {--转生至1转
		txt_content = {[1] = "<task_title>{color;ff0000;(<cur_value>/<target_value>)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "点击前往转生", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#ZhuanSheng"},[2] = {submit_task = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
		finish_open_view = {view_link = "TaskNewXiTongGuide",view_index = 4, view_node = TaskNodeName.MainuiRoleBar, view_def = "Role#ZhuanSheng"},
		showTipDesc = 31,
	}, 
 	[46] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
		--showTipDesc = 32,
    },
 
 	[47] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
    },
 	[48] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
    }, 
	[49] = {--穿戴装备
		txt_content = {[1] = "<task_title>{color;ff0000;}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴:1转以上装备{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "TaskEquipGetGuide"},[2] = {npc = 1}},
		effect_id_cfg = {complete = TASK_EFFECT_ID.COMPLETE},
	},

 	[50] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	

 	[51] = {--降妖除魔
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "当日完成除魔任务{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {npc = {id = 83 , scene_id = 2 ,x = 65, y = 129}},[2] = {npc = 1}},
	},
 	[52] = {--炼丹之术
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "成功合成等级丹{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "MainBagView#ComspoePanel"},[2] = {npc = 1}},
	},
 	[53] = {--小孩的噩梦
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀300级BOSS{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {view_link = "NewlyBossView#Wild"}, [2] = {npc = 1}},
	},	
 	[54] = {--装备回收
		txt_content = {[1] = "<task_title>{color;ff0000;(0/1)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "{color;00ff00;点击回收装备}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "MainBagView#BagView"},[2] = {submit_task = 1}},
	},
 	[55] = {--封神称谓
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "{color;00ff00;成功提升封神到5级}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#Deify"},[2] = {submit_task = 1}},
	},	
	[56] = {--拜见天师
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[57] = {--拜见城主
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[58] = {--英雄豪杰
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "{color;00ff00;成功加入行会}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Guild"},[2] = {submit_task = 1}},
	},	
	[59] = {--行会建设
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "进行行会捐献{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Guild#GuildView#GuildBuild"}, [2] = {npc = 1}},
	},	
	[60] = {--重金悬赏
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "完成行会悬赏{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Guild#OfferView"}, [2] = {npc = 1}},
	},	
	[61] = {--小金库
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "拥有元宝{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Recycle"}, [2] = {npc = 1}},
	},	
	[62] = {--转生突破
		txt_content = {[1] = "<task_title>{color;ff0000;(<cur_value>/<target_value>)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升转生至{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#ZhuanSheng"},[2] = {submit_task = 1}},
	},	
	[63] = {--炼丹传闻
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[64] = {--丹圣之地
		txt_content = {[1] = "<task_title>{color;ff0000;(<cur_value>/<target_value>)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "挑战经验副本{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {npc = {id = 80 , scene_id = 2 ,x = 129, y = 71}},[2] = {submit_task = 1}},
	},	
	[65] = {--熟练炼丹
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[66] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[67] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[68] = {--神器副本
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "挑战宝石副本{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {npc = {id = 80 , scene_id = 2 ,x = 129, y = 71}},[2] = {submit_task = 1}},
	},	
	[69] = {--神器宝石
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升宝石至3星{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "GodFurnace#GemStone"},[2] = {npc = 1}},
	},	
	[70] = {--神器魂珠
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升魂珠至3星{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "GodFurnace#DragonSpirit"},[2] = {npc = 1}},
	},	
	[71] = {--
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[72] = {--神器切割
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "完成切割任务{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "QieGeView#QieGe"},[2] = {npc = 1}},
	},	
	[73] = {--神器切割
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升切割等级至2阶{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "QieGeView#QieGe"},[2] = {npc = 1}},
	},	
	[74] = {--VIP提升
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到3级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	[75] = {--守护神装
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴守护神装5件{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "GuardEquip"},[2] = {npc = 1}},
	},	
	[76] = {--藏经阁传说
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[77] = {--消灭怪物
		txt_content = {[1] = "<task_title>{color;00ff00;(进行中)}",[2] ="<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "击杀藏经阁怪物5只{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {npc = {id = 249 , scene_id = 2 ,x = 77, y = 122}}, [2] = {npc = 1}},
	},	
	[78] = {--天书任务
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "当天完成天书任务5次{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {npc = {id = 249 , scene_id = 2 ,x = 77, y = 122}},[2] = {npc = 1}},
	},	
	[79] = {--了解技能
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[80] = {--提升技能
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升刺杀剑法到2级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Skill"},[2] = {npc = 1}},
	},	
	[81] = {--突破试炼
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关试炼关卡第10关{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Trial"},[2] = {npc = 1}},
	},	
	[82] = {--黄金矿洞
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[83] = {--血战矿洞
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "开始挖矿一次{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#DigOre"},[2] = {npc = 1}},
	},	
	[84] = {--拜别城主
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[85] = {--遨游大陆
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "当日活跃度达600{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Activity#Active"},[2] = {npc = 1}},
	},	
	[86] = {--荣耀回归
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "领取第二天登陆奖励{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "LoginReward"},[2] = {npc = 1}},
	},	
	[87] = {--每日祈福
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "成功祈福一次{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Investment#Blessing"},[2] = {npc = 1}},
	},	
	[88] = {--转生修炼
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升转生到3级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#ZhuanSheng"},[2] = {npc = 1}},
	},	
	[89] = {--战宠相伴
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升战宠等级至4阶{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "ZhanjiangView"},[2] = {npc = 1}},
	},	
	[90] = {--切割神兵
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升切割等级至3阶{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "QieGeView#QieGe"},[2] = {npc = 1}},
	},	
	[91] = {--战神之鼓
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升战鼓等级至2阶{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Prestige"},[2] = {npc = 1}},
	},	
	[92] = {--提升装备
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴3转装备3件{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "NewlyBossView#Wild"},[2] = {npc = 1}},
	},	
	[93] = {--提升等级
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升等级至400级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#Level"},[2] = {npc = 1}},
	},	
	[94] = {--VIP提升
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到4级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	[95] = {--开启分身
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "激活切割神兵-血饮{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "QieGeView#Shenbi"},[2] = {npc = 1}},
	},	
	[96] = {--热血神靴
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴[热血1☆战神鞋子]{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "ZsTaskView"},[2] = {npc = 1}},
	},	
	[97] = {--转生等级
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升转生到4级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#ZhuanSheng"},[2] = {npc = 1}},
	},	
	[98] = {--开启战纹
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[99] = {--挑战通天塔
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关通天塔15层{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Babel"},[2] = {npc = 1}},
	},	
	[100] = {--穿戴战纹
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "镶嵌战纹装备3个{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Babel"},[2] = {npc = 1}},
	},	
	[101] = {--神圣特戒
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴[神圣特戒]{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "ZsTaskView"},[2] = {npc = 1}},
	},	
	[102] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升转生到6级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Role#ZhuanSheng"},[2] = {npc = 1}},
	},	
	[103] = {--开启星魂
		txt_content = {[-1] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "与{color;1eff00;<npc_name>}对话"},
		touch_command = {[1] = {npc = 1}},
	},	
	[104] = {--星魂装备
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴星魂装备2件{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Horoscope#HoroscopeView"},[2] = {npc = 1}},
	},	
	[105] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到5级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	[106] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关试炼关卡第40关{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Trial"},[2] = {npc = 1}},
	},	
	[107] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关通天塔30层{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Babel"},[2] = {npc = 1}},
	},	
	[108] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "穿戴星魂装备6件{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Horoscope#HoroscopeView"},[2] = {npc = 1}},
	},	
	[109] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到9级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	[110] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关试炼关卡第60关{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Trial"},[2] = {npc = 1}},
	},	
	[111] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关通天塔45层{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Babel"},[2] = {npc = 1}},
	},	
	[112] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到6级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	[113] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关试炼关卡第80关{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Trial"},[2] = {npc = 1}},
	},	
	[114] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关通天塔60层{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Babel"},[2] = {npc = 1}},
	},	
	[115] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到7级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	[116] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关试炼关卡第100关{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Trial"},[2] = {npc = 1}},
	},	
	[117] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "通关通天塔80层{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Experiment#Babel"},[2] = {npc = 1}},
	},	
	[118] = {--
		txt_content = {[1] = "<task_title>{color;ff0000;(进行中)}", [2] = "<task_title>{color;00ff00;(已完成)}"},
		txt_content2 = {[1] = "提升VIP到8级{color;<target_color>;(<cur_value>/<target_value>)}", [2] = "点击领取奖励"},
		touch_command = {[1] = {view_link = "Vip"},[2] = {npc = 1}},
	},	
	
}


-- 任务错误码
TaskErrorCode = {
	Succ = 0,						--	成功
	NoQuest = 1,					--	用户没有指定的任务在身
	CanNotFinish=2,					--	用户还没达到完成任务的条件
	GetAward=3,						--	领取不到奖励，通常是由于背包不够大
	GetAwardPara = 4,				--	领取的奖励不合符要求，比如本职业不能领取本物品
	NotGiveUp=5,					--	本任务不能放弃
	NoQuestItem =6,					--	没有指定的正在进行的任务的类型
	Doing =7,						--	正在做这个任务，不能新增
	NewCond = 8,					--	没达到接受任务的条件
	MainFinish = 9,					--	主线任务已做了一次，不能再接
	RepeatMax = 10,					--	已经超过了每日可做的最大次数
	Interval = 11,					--	周期任务只能做一次
	Parent = 12,					--	父任务没完成
	ExcludeTree = 13,				--	子任务正在进行中，不能接这个任务
	Skill = 14,						--	不能学习这个技能
	NotAutoCompleteQuest = 15,		--	不是一个自动完成的任务
	QuestFull = 16,					--	任务已满
	Err = 127,						--	内部错误，不用显示给用户看
}

-- 任务目标
TaskTarget = {
	-- 0 杀怪类、
	Monster = 0,					--  id == 0 则为任意怪
	KillLevelMonster = 1,			-- 杀指定等级的怪(id:为怪物等级)
	SceneKillAnyMon = 2,			-- 指定场景任意怪(id:为场景id)
	KillBoss = 3 ,					-- 击杀BOSS(id为BOSS ID, 0则不指定, count为 数量)

	Collect = 4,					--   收集类(id:为物品id)
	ActorLevel = 5,					-- 角色的等级达标

	-- 帮派类
	GuildLevel = 6,					-- 角色所在帮派等级(id:帮派等级)
	EnterGuild = 7,					-- 1）加入帮派情况(id:为1）

	FinishQuestTypeCnt = 8,			-- 完成指定任务类型(id:为任务类型)

	KillOtherCamp = 9,				-- 杀敌对阵营玩家(id:为1)
	
	ClientEvent	= 10,				-- 客户端触发的:(id:为1是一键换装)
	-- 探索类
	SearchScene = 11,				-- 到达的场景ID(id:为场景id)

	Entrust = 12,					-- 任务委托扩展分类

	RandCircle		= 13,			-- 随机环任务

	-- 副本类型
	EnterFubenQuest = 14,			-- 副本任务完成条件为进入副本(id:副id)
	GetAwardFubenQuest = 15,		-- 副本任务完成条件为领取奖励(id:副id)

	RandomTarget = 16,				-- 目标随机

	-- 升一级类型
	UpLevel = 17,					-- 升一级(id:类型 count:表示升级几次 类型（1 左边特戒 2 右边特戒 3 龙符 4 护盾 5 宝石 6 龙魂 7 铸魂 8 官职 9 内功 10 boss纹章 11 试炼征途)

	-- 操作类型
	Operation = 18,					-- 操作一次(id:类型 count:表示操作次数 类型（ 1 装备熔炼 2 翅膀 3 强化装备  4 经脉)

	-- 达到类
	Achieve = 19,					-- 达到类(id:类型 count:达到的级数 类型（1 转生 2 试炼关卡)

	-- 完成类
	Complete = 20,					-- 完成类(id:类型 count:完成次数 类型(1 除魔 ）
	
	-- 自定义需求，id为在此需求表中唯一的非0值（最大值为65000），
	-- count为需要完成的数量，data值为自定义需求的名称；自定义需求需要通过脚本来增加完成的值； 
	Customize = 127,
	NoTarget = 256,-- 空需求
	TimeOut = 0xffff	-- 超时
}

--达到类的类型
QuestAchieveType = {
	qtAchCricle = 1,			--转生
	qtAchTrialLevel = 2,			--试炼关卡
}
QuestAchieveTypeCfg = {
	[1] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Role#ZhuanSheng"},		--转生
	[2] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "ShiLian"},		--试炼关卡
}

--完成类的类型
QuestCompleteType = {
	qtComExceptMagic = 1,		--除魔(脚本处理)
}

--操作一次的类型
QuestOperationType = {
	qtOpEquipMelting = 1,		--装备熔炼(脚本处理)
	qtOpSwing = 2,					--翅膀
	qtOpEquipStrong = 3,			--强化装备
	qtOpMeridian = 4,				--经脉(脚本处理)
}
QuestOperationTypeCfg = {
	[1] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Recycle"},		--装备熔炼(脚本处理)
	[2] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Wing"},			--翅膀
	[3] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Equipment#Strength"},		--强化装备
	[4] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Meridians"},			--经脉(脚本处理)
}

--升一级的类型
QuestUpLevelType = {
	qtUpLvLeftSpecialRing = 1,		--左边特戒
	qtUpLvRightSpecialRing = 2,		--右边特戒
	qtUpLvTheDragon = 3,			--龙符
	qtUpLvShield = 4,				--护盾
	qtUpLvGemStone = 5,				--宝石
	qtUpLvDragonSpirit = 6,			--龙魂
	qtUpLvMoldingSoul = 7,			--铸魂
	qtUpLvoffice = 8,				--官职(脚本处理)
	qtUpLvInner = 9,				--内功
	qtUpLvBossArms = 10,			--boss纹章
	qtUpLvJourney = 11,				--试炼征途
}
QuestUpLevelTypeCfg = {
	[1] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "SpecialRing"},
	[2] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "SpecialRing"},
	[3] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "GodFurnace#TheDragon"},
	[4] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "GodFurnace#Shield"},
	[5] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "GodFurnace#GemStone"},
	[6] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "GodFurnace#DragonSpirit"},
	[7] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Equipment#MoldingSoul"},
	[8] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Office"},
	[9] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Role#Inner"},
	[10] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Boss#BossIntegral"},
	[11] = {name = "{color;<target_color>;(<cur_value>/<target_value>)}", view_link = "Zhengtu"},
}

ClientEvent = {
	ceOneKeyChangeEquip = 1,		--一键换装
}

-- 任务激活的条件
TaskCondition = {
	Level = 0,						-- 0、角色等级
	GuildLevel = 1,					-- 1、帮派等级
	Job = 2,						-- 2、职业分类
	MenPai = 3,						-- 3、门派分类
	SceneId = 4,					-- 4、所在场景
	Kill = 5,						-- 5、杀戮值
	ZhanHun = 6,					-- 6、战魂值
	PreQuest = 7,					-- 7、前置任务
	Item = 8,						-- 8、身上携带物品
	ItemCount = 9,					-- 9、物品数量
	UserItem = 10,					-- 10、对应道具ID,输入道具ID，玩家双击该道具后添加任务(zac:这种是通过物品获得任务）
	MulMp = 11,						-- 11、多个门派可以接的任务
	MulParent = 12,					-- 12、支持两个前置任务
	Sex = 13,						-- 13、性别
	MaxConition,					-- 配置文件的值不能超过这个
}

-- 任务的类型
TaskType = {
	Main = 0,						-- 主线任务
	Sub = 1,						-- 支线任务
	Fuben = 2,						-- 副本任务
	Day = 3,						-- 日常任务
	Guild = 4,						-- 帮派任务
	Challenge = 5,					-- 挑战任务
	Rnd = 6,						-- 奇遇任务
	Recommended = 7,				-- 活动推介
	ZyQuest = 8,					-- 阵营任务
	Equip = 9,						-- 装备
	Exp = 10,						-- 经验
	Coin = 11,						-- 金币
	Book = 12,						-- 天书任务
	Rich = 13,						-- 财富闯关任务
	MaxQuestType,					-- 最大值
}

--日常任务id
DailyTaskType = 
{
	TYPE_XYCM = 4000,			--降妖除魔
	TYPE_FMTF = 4001,			--封魔塔防
	TYPE_FSYB = 4002,			--护送押镖
	TYPE_CLFB = 4003,			--材料副本
	TYPE_YZCG = 4004,			--勇闯天关
	TYPE_WZAD = 4005,			--未知暗殿
	TYPE_BOOSZJ = 4006,			--BOSS之家
	TYPE_TZBOSS = 4007,			--挑战BOSS
	TYPE_XXGJ = 4008,			--休闲挂机
	TYPE_RHBQ = 4009,			--如何变强
	TYPE_DRFB = 4010,			--多人副本
}

TaskFlushOptType = {
	NoneOpt	= 0,					-- 无任务操作
	UseCoin	= 1,					-- 用金币刷星
	UseYb	= 2,					-- 用元宝刷星

	OpenUi = 0,						-- 打开界面
	UpdateData = 1,					-- 更新信息
	InitData = 2,					-- 初始化
}

-- 任务奖励类型
TaskRewardType = {
	Item = 0,					-- 物品或者装备 id:物品ID count:物品数量 quality:物品品质 strong:强化等级 bind:绑定状态 param:物品指针 
	Exp = 2,						-- 角色经验值 count:经验值 param:如果是任务，这个就填写任务的ID，其他的话填关键的有意义的参数，如果没有就填写0
	BindMoney = 5,					-- 绑定银两 count:绑定银两值
	Money = 6,						-- 银两	count:银两
	BindYb = 7,						-- 绑定元宝 count:绑定元宝
	Yuanbao =15,					-- 元宝 count:元宝
	AddExp = 20,					-- 按经验配置表加经验 id:奖励库ID count:普通加成率 quality:vip加成率 加成率使用以1000为基数的整形 即n/1000
	Plumage = 44,					-- 精羽毛 (羽毛)
	ItemSex = 52,					-- 跟据性别奖励物品 {男,女}
	ItemJob = 53,					-- 跟据职业奖励物品 {战士, 法师, 道士}
	ItemSexJob = 54,				-- 跟据性别和职业奖励物品 { 男:{战士, 法师, 道士}, 女:{战士, 法师, 道士}}
	NeiGongExp = 57,				-- 内功经验
	Material = 63,					-- 各种材料(前端占位)
	AllEquip = 64,					-- 各类装备(前端占位)
}


TaskMonsterAttr = {
	[226] = {[OBJ_ATTR.ACTOR_OFFICE] = 60, 
		guild_name = Language.Task.SpecialMonsterGuildName[226], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 9 + bit:_lshift(1, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(0, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[227] = {[OBJ_ATTR.ACTOR_OFFICE] = 40, 
		guild_name = Language.Task.SpecialMonsterGuildName[227], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 14,
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(0, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[228] = {[OBJ_ATTR.ACTOR_OFFICE] = 70, 
		guild_name = Language.Task.SpecialMonsterGuildName[228], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 15 + bit:_lshift(2, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(0, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[229] = {[OBJ_ATTR.ACTOR_OFFICE] = 55, 
		guild_name = Language.Task.SpecialMonsterGuildName[229], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 13,
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(0, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[230] = {[OBJ_ATTR.ACTOR_OFFICE] = 80, 
		guild_name = Language.Task.SpecialMonsterGuildName[230], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 26,
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(0, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[231] = {[OBJ_ATTR.ACTOR_OFFICE] = 60, 
		guild_name = Language.Task.SpecialMonsterGuildName[231], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 6,
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(0, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[219] = {[OBJ_ATTR.ACTOR_OFFICE] = 100, 
		guild_name = Language.Task.SpecialMonsterGuildName[219], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 30 + bit:_lshift(4, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(20, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[220] = {[OBJ_ATTR.ACTOR_OFFICE] = 85, 
		guild_name = Language.Task.SpecialMonsterGuildName[220], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 29 + bit:_lshift(26, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(13, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[221] = {[OBJ_ATTR.ACTOR_OFFICE] = 95, 
		guild_name = Language.Task.SpecialMonsterGuildName[221], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 29 + bit:_lshift(5, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(16, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[222] = {[OBJ_ATTR.ACTOR_OFFICE] = 80, 
		guild_name = Language.Task.SpecialMonsterGuildName[222], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 29 + bit:_lshift(10, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(9, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[223] = {[OBJ_ATTR.ACTOR_OFFICE] = 90, 
		guild_name = Language.Task.SpecialMonsterGuildName[223], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 29 + bit:_lshift(3, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(11, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
	[224] = {[OBJ_ATTR.ACTOR_OFFICE] = 70, 
		guild_name = Language.Task.SpecialMonsterGuildName[224], 
		[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 29 + bit:_lshift(12, 0xff),
		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = bit:_lshift(10, 0xffff),
		[OBJ_ATTR.ACTOR_PROF] = 1},
}
