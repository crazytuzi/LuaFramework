-- 全局事件定义：主要是通用模块中的事件，比如游戏进程、本玩家动作及状态改变、场景选中对象、商城购买物品道具等
-- 基础模块是指在两个其它模块以上中会调用到的功能，例如购买物品道具，很多地方都会用到

SystemEventType =
{
	GAME_PAUSE = "game_pause",
	GAME_FOCUS = "game_focus",
}

-- 登入游戏相关事件
LoginEventType =
{
	LOGIN_SERVER_CONNECTED = "login_server_connected",					-- 登录服连接结果反馈(is_succ)
	LOGIN_SERVER_DISCONNECTED = "login_server_disconnected",			-- 登录服断开连接

	GAME_SERVER_CONNECTED = "game_server_connected",					-- 游戏服连接结果反馈(is_succ)
	GAME_SERVER_DISCONNECTED = "game_server_disconnected",				-- 游戏服断开连接

	CROSS_SERVER_CONNECTED = "cross_server_connected",					-- 跨服连接结果反馈(is_succ)
	CROSS_SERVER_DISCONNECTED = "cross_server_disconnected",			-- 跨服断开连接

	ENTER_GAME_SERVER_SUCC = "enter_game_server_succ",					-- 登录游戏服成功
	RECV_MAIN_ROLE_INFO = "recv_main_role_info",						-- 收到主角信息

	START_OPENING_ANIMATION = "start_opening_animation",				-- 开始开场剧情
	END_OPENING_ANIMATION = "end_opening_animation",					-- 结束开场剧情

	CREATE_ROLE = "CREATE_ROLE",										-- 创建角色
	LOGOUT = "LOGOUT",													-- 角色登陆

	RETURN_ORIGINAL_SERVER = "return_original_server" 					-- 跨服返回原服
}

-- 场景对象相关事件
ObjectEventType =
{
	OBJ_CREATE = "obj_create",											-- 对象创建(obj)
	OBJ_DEAD = "obj_dead",												-- 对象死亡(obj)
	OBJ_DELETE = "obj_delete",											-- 对象被删除(obj)
	BE_SELECT = "be_select",											-- 对象被选中(obj, select_type)
	TARGET_HP_CHANGE = "target_hp_change",								-- 对象血量变化(obj)
	TEAM_HP_CHANGE = "team_hp_change",									-- 附近队友血量变化(obj)

	MAIN_ROLE_MOVE_START = "main_role_move_start",						-- 主角开始移动（包括移动中重新发起移动）
	MAIN_ROLE_MOVE_END = "main_role_move_end",							-- 主角移动结束
	MAIN_ROLE_POS_CHANGE = "main_role_pos_change",						-- 主角位置改变(x, y)
	MAIN_ROLE_RESET_POS = "main_role_reset_pos",						-- 主角位置重置
	MAIN_ROLE_USE_SKILL = "main_role_use_skill",						-- 主角使用技能(skill_id)
	MAIN_ROLE_DEAD = "main_role_dead",									-- 主角死亡(main_role)
	MAIN_ROLE_REALIVE = "main_role_realive",							-- 主角复活(main_role)
	MAIN_ROLE_APPERANCE_CHANGE = "main_role_apperance_change",			-- 主角形象改变
	MAIN_ROLE_BE_HIT = "MAIN_ROLE_BE_HIT",								-- 主角被打
	MAIN_ROLE_DO_HIT = "MAIN_ROLE_DO_HIT",								-- 主角攻击
	MAIN_ROLE_EXP_CHANGE = "MAIN_ROLE_EXP_CHANGE",						-- 主角经验改变
	MAIN_ROLE_ENTER_IDLE_STATE = "main_role_enter_idle_state",			-- 主角进入idle状态
	MAIN_ROLE_STOP_IDLE_STATE = "main_role_stop_idle_state",			-- 主角离开idle状态
	START_GATHER = "start_gather",										-- 采集开始(role)
	STOP_GATHER = "stop_gather",										-- 采集结束(role)
	GATHER_TIMER = "gather_timer",										-- 主角采集时间
	OTHER_ROLE_START_GATHER = "other_role_start_gather",				-- 其他人采集开始
	OTHER_ROLE_STOP_GATHER = "other_role_stop_gather",					-- 其他人采集结束
	ENTER_FIGHT = "enter_fight",										-- 主角进入战斗状态
	EXIT_FIGHT = "exit_fight",											-- 主角离开战斗状态
	SPECIAL_SHIELD_CHANGE = "special_shield_change",					-- 护盾变化
	MAIN_ROLE_AUTO_XUNLU = "main_role_auto_xunlu",						-- 自动寻路

	MAIN_ROLE_CHANGE_AREA_TYPE = "main_role_change_area_type",			-- 玩家改变场景区域的类型，如离开安全区

	FIGHT_EFFECT_CHANGE = "fight_effect_change",						-- 战斗Effect变更(is_main_role)
	CAN_NOT_FIND_THE_WAY = "can't find the way",						-- 无法找到路径
	HEAD_CHANGE = "head_change",										-- 主角头像改变
	TEMP_HEAD_CHANGE = "temp_head_change",								-- 主角头像改变(临时)
	LEVEL_CHANGE = "level_change",										-- 主角等级改变
	CLICK_SHUANGXIU = "click_shuangxiu",								-- 对象点击双修事件
	GUILD_HEAD_CHANGE = "guild_head_change",							-- 公会头像改变
	CLICK_KF_MINING = "click_kf_mining", 								-- 跨服挖矿点击事件
	FRAME_CHANGE = "frame_change",										-- 头像框改变
}

-- 场景相关事件
SceneEventType =
{
	SCENE_LOADING_STATE_ENTER = "scene_loading_state_enter",			-- 进入场景加载事件
	SCENE_LOADING_STATE_QUIT = "scene_loading_state_quit",				-- 场景加载结束
	UI_SCENE_LOADING_STATE_QUIT = "ui_scene_loading_state_quit",		-- UI场景加载结束
	SHOW_MAINUI_RIGHT_UP_VIEW = "show_mainui_right_up_view"	,			-- 主界面右上界面显示
	OBJ_ENTER_LEVEL_ROLE = "obj_enter_level_role",						-- 物体进入、离开角色视野
	SCENE_ALL_LOAD_COMPLETE = "scene_all_load_complete",				-- 场景所有加载完成(主场景和细节场景)
}

-- Touch相关事件
LayerEventType =
{
	KEYBOARD_RELEASED = "keyboard_released",							-- 按键事件
	TOUCH_BEGAN = "touch_began",										-- 触摸事件 按下
	TOUCH_MOVED = "touch_moved",										-- 触摸事件 移动
	TOUCH_ENDED = "touch_ended",										-- 触摸事件 抬起
	TOUCH_CANCELLED = "touch_cancelled",								-- 触摸事件 取消
	LINE_GESTURE = "line_gesture",										-- 线性手势(方向 0123==上右下左)
	ACCELEROMETER = "accelerometer",									-- 加速计事件(x, y, z)
}

-- 主界面相关事件
MainUIEventType =
{
	MAIN_HEAD_CLICK = "main_head_click",
	MAIN_BTN_STATE = "main_btn_state",
	ROLE_SKILL_CHANGE = "role_skill_change",
	NEW_CHAT_CHANGE = "new_chat_change",
	MAINUI_OPEN_COMLETE = "mainui_open_complete",

	MAIN_FUNC_OPEN = "main_func_open",									-- 主界面功能开放
	CHANGE_RED_POINT = "change_red_point",								-- 改变主界面红点
	SHOW_OR_HIDE_OTHER_BUTTON = "show_or_hide_other_button",			-- 显示或隐藏系统图标
	SHOW_OR_HIDE_REBATE_BUTTON = "show_or_hide_rebate_button",			-- 显示或隐藏百倍返利按钮
	SHOW_OR_HIDE_SHRINK_BUTTON = "show_or_hide_shrink_button",			-- 显示或隐藏收缩按钮
	PORTRAIT_TOGGLE_CHANGE = "portrait_toggle_change",					-- 显示或隐藏左上角图标
	MAINUI_CLEAR_TASK_TOGGLE = "mainui_clear_task_toggle",				-- 取消任务栏选择
	SHOW_OR_HIDE_TOP_RIGHT_BUTTON = "show_or_hide_top_right_button",	-- 显示或隐藏右上角列表
	SHOW_OR_HIDE_MODE_LIST = "show_or_hide_mode_list",					-- 显示或隐藏模式列表
	SHOW_OR_HIDE_DAFUHAO_INFO = "show_or_hide_dafuhao_info",			-- 显示或隐藏大富豪面板
	SHRINK_DAFUHAO_INFO = "shrink_dafuhao_info",						-- 收起大富豪面板
	FIGHT_STATE_BUTTON = "fight_state_button",							-- 战斗收缩按钮(右下角)
	CHNAGE_FIGHT_STATE_BTN = "chnage_fight_state_btn",					-- 改变战斗收缩按钮操作

	CHAT_VIEW_HIGHT_CHANGE = "chat_view_hight_change",					-- 主界面聊天框高度改变
	CHANGE_MAINUI_BUTTON = "change_mainui_button",						-- 主界面按钮改变
	CLICK_SKILL_BUTTON = "click_skill_button",							-- 按下技能键

	JINJIE_EQUIP_SKILL_CHANGE = "jinjie_equip_skill_change",			-- 进阶装备技能改变
	OPEN_NEAR_VIEW = "mainui_open_near_view",							-- 打开附件玩家界面
	CLICK_AUTO_BUTTON = "click_auto_button",							-- 点击挂机按钮
	CUR_TASK_CHANGE = "cur_task_change",								-- 当前任务更换
	CHAT_TOP_BUTTON_MOVE = "chat_top_button_move",						-- 聊天功能小图标移动
	PLAYER_BUTTON_VISIBLE = "player_button_visible",					-- 系统功能图标动画完毕事件
	TOP_RIGHT_BUTTON_VISIBLE = "top_right_button_visible",				-- 右上角功能图标动画完毕事件
	INIT_ICON_LIST = "init_icon_list",									-- 初始化主界面图标
	OTHER_INFO_CHANGE = "other_info_change",							-- 左边面板第三标签改变
}

KnapsackEventType = {
	KNAPSACK_EXTEND_BAG = "knapsack_extend_bag",						-- 背包拓展
	KNAPSACK_EXTEND_STORAGE = "knapsack_extend_storage",				-- 仓库拓展
	KNAPSACK_LECK_ITEM = "knapsack_leck_item",							-- 物品不足
	KNAPSACK_COLDDOWN_CHANGE = "knapsack_colddown_change",				-- 物品CD变更
}

SettingEventType = {
	SHIELD_OTHERS = "shield_others",									--屏蔽其他玩家
	SELF_SKILL_EFFECT = "self_skill_effect",							--屏蔽自己技能特效
	SHIELD_SAME_CAMP = "shield_same_camp",								--屏蔽友方玩家
	SKILL_EFFECT = "skill_effect",										--屏蔽他人技能特效
	CLOSE_BG_MUSIC = "close_bg_music",									--关闭背景音乐
	CLOSE_SOUND_EFFECT = "close_sound_effect",							--关闭音效
	FLOWER_EFFECT = "flower_effect",									--屏蔽送花特效
	FRIEND_REQUEST = "friend_request", 									--拒绝好友邀请
	STRANGER_CHAT = "stranger_chat", 									--拒绝陌生私聊
	CLOSE_TITLE = "close_title",	 									--屏蔽称号显示
	CLOSE_HEARSAY = "close_hearsay",									--屏蔽传闻
	CLOSE_GODDESS = "close_goddess",									--屏蔽女神
	AUTO_RELEASE_SKILL = "auto_release_skill",							--自动释放技能
	AUTO_RELEASE_ANGER = "auto_release_anger",							--自动释放怒气技能
	CLOSE_SHOCK_SCREEN = "close_shock_screen",							--关闭震屏效果
	AUTO_PICK_PROPERTY = "auto_pick_property",							--自动拾取道具
	AUTO_RECYCLE_EQUIP = "auto_recycle_equip",							--自动回收装备
	-- USE_NOTBLIND_EQUIP = "use_notblind_equip",						--只消耗非绑定装备
	SHIELD_ENEMY = "shield_enemy",										--屏蔽怪物
	SHIELD_SPIRIT = "shield_spirit",									--屏蔽精灵
	CLOSE_WEATHWE = "close_weather",									--关闭天气
	AUTO_RECYCLE_BLUE = "shield_spirit",								--自动回收蓝色
	AUTO_RECYCLE_PURPLE = "shield_spirit",								--自动回收紫色
	AUTO_RECYCLE_ORANGE = "shield_spirit",								--自动回收橙色
	AUTO_RECYCLE_RED = "shield_spirit",									--自动回收红色
	AUTO_LUCK_SCREEN = "luck_screen",									--锁屏
	AUTO_RELEASE_GODDESS_SKILL = "auto_release_goddess_skill",			--自动释放女神技能
	AUTO_USE_FLY_SHOE = "auto_use_fly_shoe",							--自动使用小飞鞋
	SHIELD_APPERANCE = "shield_apperance",								--屏蔽外观(头饰，麒麟臂等)
	AUTO_USE_GENERAL_SKILL = "auto_use_general_skill",					--自动释放天神技能

	AUTO_PICK_COLOR = "auto_pick_color",
	AUTO_RECYCLE_COLOR = "auto_recycle_color",
	GUAJI_SETTING_CHANGE = "guaji_setting_change",						-- 挂机设置改变
	MAIN_CAMERA_MODE_CHANGE = "main_camera_change",						-- 摄像机镜头改变
	MAIN_CAMERA_SETTING_CHANGE = "main_camera_setting_change",			-- 摄像机镜头参数改变
}

OtherEventType = {
	ROLE_ONLINE_CHANGE = "role_online_change",							-- 其它玩家在线信息改变
	DAY_COUNT_CHANGE = "day_count_change",								-- 每日计数改变(day_counter_id, -1表示全部)
	PASS_DAY = "pass_day",												-- 换天时发送
	TEAM_INFO_CHANGE = "team_info_change",								-- 队伍信息改变
	WORLD_LEVEL_CHANGE = "world_level_change",							-- 世界等级改变
	GUAJI_TYPE_CHANGE = "guaji_type_change",							-- 挂机类型改变
	TASK_CHANGE = "task_change",										-- 任务改变
	CAMP_BOSS_CHANGE = "camp_boss_change",								-- 阵营普通夺宝
	CAMP_STATUE_CHANGE = "camp_statue_change",							-- 阵营雕像信息
	ACTIVITY_CHANGE = "activity_change",								-- 活动改变
	FUBEN_COUNTDOWN = "fuben_countdown",								-- 副本倒计时
	FUBEN_QUIT = "fuben_quit",											-- 副本离开
	CAVE_BOSS_CHANGE = "cave_boss_change",								-- 洞窟boss改变
	MOUNT_INFO_CHANGE = "mount_info_change",
	OPERATE_RESULT = "operate_result",									-- 操作结果
	WAREHOUSE_FLUSH_VIEW = "warehouse_flush_view",						-- 刷新仓库
	RECYCLE_FLUSH_CONTENT = "recycle_flush_content",					-- 刷新回收面板
	OPEN_RECYCLE_VIEW = "open_recycle_view",							-- 打开回收面板
	FLUSH_BAG_GRID = "flush_bag_grid",									-- 刷新背包面板
	FLUSH_MAGIC_BAG = "flush_magic_bag",								-- 刷新魔器背包
	FLUSH_RESOLVE_EVENT = "flush_resolve_event",						-- 刷新天神武器分解面板
	ROLE_LEVEL_UP = "role_level_up",									-- 角色等级改变
	TASK_WINDOW = "task_window",										-- 任务对话框
	TURN_COMPLETE = "turn_complete",									-- 转盘结束
	USE_PROP_SUCCE = "use_prop_succe",									-- 使用物品成功
	CLOSE_FUBEN_FAIL_VIEW = "close_fuben_fail_view",					-- 关闭副本失败面板
	RoleInfo = "role_info",												-- 角色信息返回（通过id查询的）
	ROLE_ISONLINE_CHANGE = "role_isonline_change",						-- 玩家上下线通知
	BLACK_LIST_CHANGE = "black_list_change",							-- 黑名单列表发生改变
	GUILD_MEMBER_INFO_CHANGE = "guild_member_info_change",				-- 公会成员信息改变
	RANDOM_INFO_CHANGE = "random_info_change",							-- 随机在线玩家列表改变
	FRIEND_INFO_CHANGE = "friend_info_change",							-- 好友信息改变
	REPAIR_STATE_CHANGE = "repair_state_change",						-- 双修状态改变
	DAFUHAO_INFO_CHANGE = "dafuhao_info_change",						-- 大富豪信息改变
	EQUIP_DATA_CHANGE = "equip_data_change",							-- 装备数据改变
	ROBERT_ATTACK_ROBERT = "robert_attack_robert",						-- 机器人攻击机器人时
	ROBERT_DIE = "robert_die",											-- 机器人死亡
	RANK_CHANGE = "rank_change",										-- 排行榜信息改变
	BEST_RANK_CHANGE = "best_rank_change",								-- 顶级玩家信息改变

	VIRTUAL_TASK_CHANGE = "virtual_task_change",						-- 虚拟任务改变
	ROLE_NAME_INFO = "role_name_info",									-- 角色信息查询返回（通过名字查询的）
	VIEW_CLOSE = "view_close",											-- 界面关闭
	VIEW_OPEN = "view_open",											-- 界面打开
	POWER_CHANGE_VIEW_OPEN = "power_change_view_open",					-- 战力变化面板打开关闭
	RANDOW_ACTIVITY = "random_activity",								-- 随机活动返回
	MOVE_BY_CLICK = "move_by_click",									-- 玩家手动控制主角移动
	JUMP_STATE_CHANGE = "jump_state_change",							-- 主角跳跃状态改变
	PLAYER_MIESHI_SKILL_CHANGE = "player_mieshi_skill_change",			-- 角色面板灭世技能等级发生改变

	FPS_SAMPLE_RESULT = "fps_sample_result",							-- 帧频采样结果
	SHENGDI_FUBEN_INFO_CHANGE = "shengdi_fuben_info_change",			-- 圣地副本信息改变
	HUNQI_XILIAN_STUFF_SELECT = "hunqi_xilian_stuff_select",			-- 魂器洗练材料选择

	FLUSH_SHENYIN_BAG = "flush_shenyin_bag",                            -- 刷新神印背包
	FLUSH_RECYCLE_SHENYIN_BAG = "flush_recycle_shenyin_bag",            -- 刷新神印回收背包
	FLUSH_RECYCLE_SHENYIN_COLOR = "flush_recycle_shenyin_color",        -- 刷新神印回收颜色选择
}

AdvanceEquipupType = {
	MOUT_EQUIPUP_CHANGE = "mount_equipup_change",						-- 进阶坐骑装备升级
	WING_EQUIPUP_CHANGE = "wing_equipup_change",						-- 进阶羽翼装备升级
	HALO_EQUIPUP_CHANGE = "halo_equipup_change",						-- 进阶光环装备升级
	SHENGONG_EQUIPUP_CHANGE = "shengong_equipup_change",				-- 进阶神弓装备升级
	SHENYI_EQUIPUP_CHANGE = "shenyi_equipup_change",					-- 进阶神翼装备升级
}

--测试，在仓库面板点击关闭按钮，显示 角色穿着 面板
WarehouseEventType = {
	ROLE_DRESS_CONTENT = "role_dress_content",							--显示角色穿着面板
}

BagFlushEventType = {
	BAG_FLUSH_CONTENT = "bag_flush_content"
}

MountSetAttrEventType = {
	SET_MOUNT_ATTR = "set_mount_attr"
}
--在回收面板点击回收按钮
RecycleEventType = {
	CLOSE_RECYCLE_CONTENT = "close_recycle_content"
}

--功能开启
OpenFunEventType = {
	OPEN_TRIGGER = "open_trigger",							-- 功能开启有变化触发
}

FinishedOpenFun = "finished_open_fun" 						--完成功能开启

--水晶采集无敌状态有变化
ShuiJingBuffTrigger = "shui_jing_buff_trigger"

--聊天相关
ChatEventType = {
	SPECIAL_CHAT_TARGET_CHANGE = "special_chat_target_change",				--特殊聊天对象改变
	VOICE_SWITCH = "voice_switch",											-- 语音聊天开关
}

AvaterType = {
	FORBID_AVATER_CHANGE = "forbid_avater_change",						--禁止更换头像变化
}

ScoreChangeEvent = "score_change"            					-- 积分变化

FuBenEventType = {
	FUBEN_INFO_CHANGE = "fuben_info_change",						--副本信息变化
}