--剧情阶段触发
S_STEP_TRIGGER = {
	ENTER_SCENE					= "enter_scene",			-- 进入场景
	CG_START   					= "cg_start",				-- cg开始
	CG_END   					= "cg_end",					-- cg结束
	S_STEP_END 					= "s_step_end",				-- 服务器阶段结束
	INTERACTIVE_END				= "interactive_end",		-- 交互结束
	DIALOG_END					= "dialog_end",				-- 对话结束
	MOVE_INTO_AREA 				= "move_into_area",			-- 移动到某个区域(参数:x##y##width##height)
	FIGHT_END					= "fight_end",				-- 战斗结束（参数：fight_id)
	CLOCK_END					= "clock_end",				-- 时钟结束
	RECEIVED_TASK				= "received_task",			-- 接受任务（参数：任务id)
	ROLE_LEVEL					= "role_level",				-- 角色等级达到 (参数: level)
	GATHER_END					= "gather_end",				-- 采集结束 (参数：采集物id)
	BE_ATTACKED					= "be_attacked",			-- 被攻击 (参数: robert_id)
	ROBERT_DIE					= "robert_die",				-- 机器人死亡(参数:robert_id)
}

-- 剧情阶段操作
-- 参数robert_id 如果是为0，则代表是主角

-- 1. 关于战斗说明
-- 机器人只会在战事开启时才会发生攻击行为，战事结束后将停止攻击。
-- 一场战事通过fight_start开始，于fight_stop或者战斗人员死亡结束

-- 2. 关于改变外观说明
-- 其实就是角色里的的appearance字段。看ProtocolStruct.ReadRoleAppearance()
-- (外观类型为：fashion_wuqi, fashion_body, mount_used_imageid, wing_used_imageid, halo_used_imageid 等)

-- 3. 关于delay_do的说明
-- 延迟几秒做某件事，如 delay_do##2##cg_start##cg

-- 4. 关于条件语句
-- if trigger then operate;operate   trigger是触发条件，operate是执行，多个执行用分号

S_STEP_OPERATE = {
	CG_START 					= "cg_start",				-- cg开始 (播放cg, 参数：bgatherundle_name##asset_name)
	S_STEP_START				= "s_step_start",			-- 请求服务器阶段开始 (参数：服务器step)
	INTERACTIVE_START			= "interactive_start",		-- 交互开始
	DIALOG_START				= "dialog_start",			-- 对话开始 （参数： npc_id)
	EXIT_FB						= "exit_fb",				-- 退出副本
	SET_ROLE_POS				= "set_role_pos",			-- 设置角色位置(设置主角位置，通知服务器，参数：x##y)
	GIRL_SAY					= "girl_say",				-- 美女说话 (参数：内容##时间))
	CREATE_ROBERT				= "create_roberts",			-- 创建机器人(可同时创建多个，参数：机器人id##机器人id##机器人id)
	DEL_ROBERT					= "del_roberts",			-- 移除机器人(可同时删除多个，参数：机器人id##机器人id##机器人id)
	ROBERT_SAY					= "robert_say",				-- 机器人说话(在头上出现泡泡，参数：robert_id##内容##时间)
	ROBERT_MOVE					= "robert_move",			-- 机器人移动到目标点(参数:robert_id##x##y)
	ROBERT_ATK_TARGET			= "robert_atk_target",		-- 给机器人设定目标，在一场战斗进行中时，会攻击目标直至死亡（参数：robert_id##target_robert_id)
	FIGHT_START					= "fight_start",			-- 开始一场战斗(所有机器人进入战斗状态， 参数指定哪些机器人死亡则战斗结束，参数：机器人id##机器人id##机器人id)
	FIGHT_STOP					= "fight_stop",				-- 结束一场战斗
	CHANGE_APPEARANCE			= "change_appearance",		-- 改变机器人外观（参数:robert_id##外观类型##外观值)
	CHANGE_TITLE				= "change_title",			-- 改变机器人头顶称号（参数:robert_id##称号id)
	CHANGE_MOVE_SPEED			= "change_move_speed",		-- 改变移动速度(参数：robert_id##速度)
	CHANGE_HUSONG_COLOR			= "change_husong_color",	-- 更改护送颜色(参数：robert_id##husong_color)
	CHANGE_MAXHP				= "change_maxhp",			-- 改变最大血量(参数:robert_id##max_hp)
	CHANGE_GONGJI				= "change_gongji",			-- 改变攻击力(参数:robert_id##mingongji##maxgongji)
	CHANGE_AOE_RANGE			= "change_aoe_range",		-- 改变aoe范围(参数:robert_id##aoe_range)
	CLOCK_START					= "clock_start",			-- 时钟开始（参数: time)
	S_DROP						= "s_drop",					-- 服务端掉落物品，服务器掉落后副本将会通关成功 (参数:x##y)
	S_FB_PASS_SUCC				= "s_fb_pass_succ",			-- 服务器副本通关成功(下次将不可再进)
	NEXT_STEP					= "next_step",				-- 执行下一步(无参数)
	FORCE_DO					= "force_do",				-- 强制做某件事(参数：robert_id##时间##do_type##do相关参数)
	STOP_FORCE_DO				= "stop_force_do",			-- 停止强制(参数:robert_id)
	START_GATHER				= "start_gather",			-- 开始采集(参数:robert_id##gather_id)
	CREATE_AIR_RECT_WALL		= "create_air_rect_wall",	-- 生成空气墙(参数:x##y##width##height)
	DEL_AIR_RECT_WALL			= "del_air_rect_wall",		-- 移除空气墙(参数:x##y##width##height)
	SET_SCENE_ELEMENT_ACT 		= "set_scene_element_act",	-- 设置场景元素是否激活(参数：场景元素路径##是否激活(如Detail/Effects/barrier##1))
	SHOW_COUNTDOWN_TIME			= "show_countdown_time",	-- 显示倒计时(参数: time)
	SHOW_MESSAGE				= "show_message",			-- 显示传闻,支持html（参数：内容##显示时间）
	CREATE_GATHER				= "create_gather",			-- 创建采集物(参数：采集物id##采集时间##x##y)
	CREATE_NPC					= "create_npc",				-- 创建NPC(参数：npc_id##x##y##rotation_y)
	DEL_NPC						= "del_npc",				-- 删除NPC(参数: npc_id)
	PLAY_AUDIO					= "play_audio",				-- 播放音效（参数：bundle_name##asset_name)
	PLAY_EFFECT					= "play_effect",			-- 播放简单特效，以指定robert为中心点 (参数: bundle_name##asset_name##robert_id##offest_x##offest_y##offest_z)
	PLAY_AROUND_EFFECT			= "play_around_effect",		-- 在机器人周围播放特效，以指定robert为中心点 (参数: bundle_name##asset_name##robert_id##width##height##count)
	CREATE_EFFECT_OBJ			= "create_effect_obj",		-- 创建特效对象，在某个指位置播放(参数：effect_id)
	DEL_EFFECT_OBJ				= "del_effect_obj",			-- 删除特效对象(effect_id)
	AUTO_TASK					= "auto_task",				-- 自动任务(无参数)
	AUTO_GUAJI					= "auto_guaji",				-- 自动挂机(无参数)
	MOVE_ARROW_TO				= "move_arrow_to",			-- 脚底箭头指定某个点（参数：x##y)
	FUN_GUIDE					= "fun_guide",				-- 功能引导(参数: guide_name)
	DEL_MOVE_ARROW				= "del_move_arrow",			-- 移除移动箭头(无参数)
	DELAY_DO					= "delay_do",				-- 延迟做某件事(参数:时间##操作...)
	CODE_IF_THEN				= "code_if_then",			-- 编码开启条件语句(参数:if .. then ..)
	DEL_CODE					= "del_code",				-- 删除编码(无参数)
	ROBERT_ROTATE_TO 			= "rotate_to",				-- 机器人转向到某个角度(参数:robert_id##angle)
	TIME_SCALE 					= "time_scale",				-- 慢镜头
}

-- 交互类型
S_INTERACTIVE_TYPE = {
	FETCH_HUSONG_REWARD 		= "fetch_husong_reward",	-- 领取奖励（打开领励面板，点击后交互完成）
	WING_OPEN_DOOR				= "wing_open_door",			-- 羽翼剧情副本打开门，点击后交互完成
	DISTRIBUTE_RED_PACKET		= "distribute_red_packet",	-- 派发红包 （弹出发红包面板，点击后交互完成)
	SHOW_VICTORY				= "show_victory",			-- 显示胜利面板，参数(1或2或3)（点击后交互完成)
	SHOW_HELP					= "show_help",				-- 显示求救
	SHOW_ATTACK					= "show_attack",			-- 显示击杀
	SHOW_ATTACK_BACK			= "show_attack_back",		-- 显示击杀back
}

-- 强制做某件事类型
S_FORCE_DO_TYPE = {
	F_MOVE_TO 					= "f_move_to",				-- 强制移动到某地（参数:x##y)
	F_ATTACK_TARGET				= "f_attack_target",		-- 强制攻击目标(参数:robert_id2##robert_id3)
	F_GATHER					= "f_gather",				-- 强制采集（参数:gather_id)
}
