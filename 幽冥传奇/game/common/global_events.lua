--全局事件定义：主要是通用模块中的事件，比如游戏进程、本玩家动作及状态改变、场景选中对象、商城购买物品道具等
--基础模块是指在两个其它模块以上中会调用到的功能，例如购买物品道具，很多地方都会用到

-- 应用相关事件
AppEventType = {
	ENTER_BACKGROUND = "enter_background",			-- 进入后台
	ENTER_FOREGROUND = "enter_foreground",			-- 进入前台
	GAME_START_COMPLETE =  "game_start_complete"	-- 游戏启动完毕
}

--登入游戏相关事件
LoginEventType = 
{
	LOGIN_SERVER_CONNECTED = "login_server_connected",						-- 登录服连接结果反馈(is_succ)
	LOGIN_SERVER_DISCONNECTED = "login_server_disconnected",				-- 登录服断开连接
	GAME_SERVER_CONNECTED = "game_server_connected",						-- 游戏服连接结果反馈(is_succ)
	GAME_SERVER_DISCONNECTED = "game_server_disconnected",					-- 游戏服断开连接
	ENTER_GAME_SERVER_SUCC = "enter_game_server_succ",						-- 登录游戏服成功
	LOADING_COMPLETED = "loading_completed",								-- 加载完成
	RECV_MAIN_ROLE_INFO = "recv_main_role_info",							-- 收到主角信息
	START_OPENING_ANIMATION = "start_opening_animation",					-- 开始开场剧情
	END_OPENING_ANIMATION = "end_opening_animation",						-- 结束开场剧情
	NOTICE_VIEW = "notice_view",
}

--场景对象相关事件
ObjectEventType =
{
	OBJ_CREATE = "obj_create",								-- 对象创建(obj)
	OBJ_DEAD = "obj_dead",									-- 对象死亡(obj)
	OBJ_DELETE = "obj_delete",								-- 对象被删除(obj)

	MAIN_ROLE_MOVE_START = "main_role_move_start",					-- 主角开始移动（包括移动中重新发起移动）
	MAIN_ROLE_MOVE_END = "main_role_move_end",						-- 主角移动结束
	MAIN_ROLE_POS_CHANGE = "main_role_pos_change",					-- 主角位置改变(x, y)
	MAIN_ROLE_USE_SKILL = "main_role_use_skill",					-- 主角使用技能(skill_id)
	MAIN_ROLE_DEAD = "main_role_dead",								-- 主角死亡(main_role)
	MAIN_ROLE_REALIVE = "main_role_realive",						-- 主角复活(main_role)
	MAIN_ROLE_APPERANCE_CHANGE = "main_role_apperance_change",		-- 主角形象改变
	MAIN_ROLE_LEARN_BISHA = "main_role_learn_bisha",				-- 主角习得必杀技能

	BE_SELECT = "be_select",										-- 对象被选中
	OBJ_ATTR_CHANGE = "obj_attr_change",							-- 对象属性改变
	OBJ_BUFF_CHANGE = "obj_buff_change",							-- 对象buff改变

	MAIN_ROLE_PK_MODE_CHANGE = "main_role_pk_mode_change",			-- 主角pk模式改变
	MAX_ANGER_VAL_CHANGE = "max_anger_val_change",					-- 主角怒气总值改变
}

--场景相关事件
SceneEventType =
{
	SCENE_LOADING_STATE_ENTER = "scene_loading_state_enter",			-- 进入场景加载事件
	SCENE_LOADING_STATE_QUIT = "scene_loading_state_quit",				-- 场景加载结束
	SCENE_CHANGE_COMPLETE = "scene_change_complete",					-- 场景改变事件
	SCENE_AREA_ATTR_CHANGE = "scene_area_attr_change",					-- 场景区域属性变化
	SCENE_FPS_SHIELD = "scene_fps_shield",								-- 场景区域是否根据fps自动屏蔽
	SCENE_HAS_FPS_SHIELD = "scene_has_fps_shield",						-- 场景区域是否有根据fps自动屏蔽
}

--Touch相关事件
LayerEventType =
{
	KEYBOARD_RELEASED = "keyboard_released",					-- 按键事件
	TOUCH_BEGAN = "touch_began",								-- 触摸事件 按下
	TOUCH_MOVED = "touch_moved",								-- 触摸事件 移动
	TOUCH_ENDED = "touch_ended",								-- 触摸事件 抬起
	TOUCH_CANCELLED = "touch_cancelled",						-- 触摸事件 取消
	LINE_GESTURE = "line_gesture",								-- 线性手势(方向 0123==上右下左)
	ACCELEROMETER = "accelerometer",							-- 加速计事件(x, y, z)
}

--主界面相关事件
MainUIEventType =
{
	MAIN_BTN_STATE = "main_btn_state",
	CHAT_CHANGE = "chat_change",
	TASK_SHOW_TYPE_CHANGE = "task_show_type_change",						-- 导航窗口显示内容
	TASK_OTHER_DATA_CHANGE = "task_other_data_change",						-- 导航窗口其它内容
	CHAT_REMIND_CHANGE = "chat_remind_change",								-- 聊天提醒改变
	PRIVILEGE_VIEW_SHOW_IN_FORESHOW = "privilege_view_show_in_foreshow",	-- 特权卡图标显示在预告区域
	UI_SCALE_CHANGE = "ui_scale_change",									-- 主界面大小因数变化
	TASK_BAR_VIS = "TASK_BAR_VIS",											-- 任务栏显示
	BONFIRE_BAR_VIS = "BONFIRE_BAR_VIS",									-- "未知暗殿"篝火双倍栏显示
	SET_TIPS_UI_VIS = "set_tips_ui_vis",									-- 设置小图标显示
	UPDATE_BRILLIANT_ICON = "update_brilliant_icon",						-- 更新运营活动图标显示
	UPDATE_RARETREASURE_ICON = "UPDATE_RARETREASURE_ICON", 					-- 更新龙皇秘宝图标显示
	UPDATE_ZSTASK_ICON = "UPDATE_ZSTASK_ICON", 								-- 更新钻石任务图标显示
}

KnapsackEventType = {
	KNAPSACK_EXTEND_BAG = "knapsack_extend_bag",						-- 背包拓展
	KNAPSACK_EXTEND_STORAGE = "knapsack_extend_storage",				-- 仓库拓展
	KNAPSACK_LECK_ITEM = "knapsack_leck_item",							-- 物品不足
	KNAPSACK_ITEM_USE = "knapsack_item_use",							-- 物品使用成功
	KNAPSACK_COMPOSE_EQUIP = "knapsack_compose_equip",					-- 装备合成
	KNAPSACK_ITEM_DELETE = "knapsack_item_delete"   	                -- 装备合成
}

SettingEventType = {
	SYSTEM_SETTING_CHANGE = "system_setting_change",					-- 系统设置改变
	GUAJI_SETTING_CHANGE = "guaji_setting_change",						-- 挂机设置改变
	SKILL_BAR_CHANGE = "skill_bar_change",								-- 主界面技能栏改变
	AUTO_SKILL_CHANGE = "auto_skill_change",							-- 自动使用技能改变
	FASHION_SAVE_CHANGE = "fashion_save_change",					    -- 时装衣服
}

--主角数据初始化完成相关事件
MainRoleDataInitEventType = {
	ALL_DATA = "all_data",								-- 称号、装备 数据
	TITLE_DATA = "title_data",							-- 称号数据
	EQUIP_DATA = "equip_data",							-- 装备数据
}

OtherEventType = {
	PASS_DAY = "pass_day",											-- 换天时发送
	FIRST_LOGIN = "first_login",									-- 当天第一次登陆
	TEAM_INFO_CHANGE = "team_info_change",							-- 队伍信息改变
	WORLD_LEVEL_CHANGE = "world_level_change",						-- 世界等级改变
	EQUIP_STRENGTHEN_CHANGE = "equip_strengthen_change",			-- 装备强化改变
	EQUIP_SHENZHU_CHANGE = "equip_shenzhu_change",					-- 装备神铸改变
	GUAJI_TYPE_CHANGE = "guaji_type_change",						-- 挂机类型改变
	SETTING_GUAJI_TYPE_SHOW = "setting_guaji_type_show",			-- 设置挂机类型显示
	TARGET_HEAD_CHANGE = "target_head_change",						-- 目标头像改变
	RERATION_INFO_CHANGE = "reration_info_change",					-- 关系信息改变
	STRENGTH_INFO_CHANGE = "strength_info_change",					-- 强化信息改变
	INIT_SKILL_LIST = "init_skill_list",							-- 初始化技能列表
	GUILDMEMBER_CHANGE = "guildmember_change",						-- 帮派成员改变
	REMIND_CAHANGE = "remind_cahange",								-- 功能提醒数据改变
	REMINDGROUP_CAHANGE = "remindgroup_cahange",					-- 功能提醒数据组改变
	AREA_SKILL_ID_CHANGE = "area_skill_id_change",					-- 区域技能id改变
	SUCCESS_ESCORT = "success_escort",								-- 成功交镖
	OPEN_DAY_CHANGE = "open_day_change",							-- 开服天数改变
	COMBINED_DAY_CHANGE = "combined_day_change",					-- 合服天数改变
	XUELIAN_INFO_CHANGE = "xuelian_info_change",					-- 血炼信息改变
	GUILDLEVEL_CHANGE = "guildlevel_change",						-- 行会等级改变
	GUILD_CREATED = "guild_created",								-- 创建了行会
	STORY_END = "story_end",										-- 剧情结束
	MOLDINGSOUL_INFO_CHANGE = "moldingsoul_info_change",			-- 铸魂信息改变
	APOTHEOSIS_INFO_CHANGE = "apotheosis_info_change",				-- 封神信息改变
	STONE_INLAY_INFO_CHANGE = "stone_inlay_info_change",			-- 宝石镶嵌改变
	REFINED_INFO_CHANGE = "refined_info_change",					-- 祭炼信息改变
	ENTER_ESCORT_VALID = "enter_escort_valid",						-- 主角进入押镖有效范围
	OUT_ESCORT_VALID = "out_escort_valid",							-- 主角离开押镖有效范围
	FIRST_FLOOR_RESULT = "first_floor_result",						-- 多人副本第一层结果
	FIRST_FLOOR_KILL_COUNT = "first_floor_kill_count",				-- 多人副本第一层击杀数量
	USER_TOUCH_SKILL_ICON = "user_touch_skill_icon",				-- 玩家触摸技能
	SEND_CHAT_DATA = "send_chat_data",								-- 发送聊天数据
	CREATE_ROLE_SUCC = "create_role_succ",							-- 成功创建角色
	MAIN_ROLE_LEVEL_CHANGE = "main_role_level_change",				-- 主角等级变化
	MAIN_ROLE_CHANGE_NAME = "main_role_change_name",				-- 主角更改名字
	MAIN_ROLE_CIRCLE_CHANGE = "main_role_circle_change", 			-- 主角转生变化

	TODAY_CHARGE_GOLD_CHANGE = "today_charge_gold_change",			-- 今日充值的元宝数变化
	TODAY_CONSUME_GOLD_CHANGE = "today_consume_gold_change",		-- 今日消费的元宝数变化
	GAME_COND_CHANGE = "game_cond_change",							-- 游戏逻辑条件状态变化

	PRACTICE_BLESS_CHANGE = "practice_bless_change",				--试炼副本祝福值修改
	CAILIAO_INFO_CHANGE = "cailiao_info_change",					--材料副本信息
	BAG_STONE_CHANGED = "bag_stone_changed",						-- 背包宝石变化
	GODFURNACE_ACTIVE = "godfurnace_active",						-- 神炉装备激活
	GODFURNACE_UP_SUCCED = "godfurnace_up_succed",					-- 神炉装备升级成功
	STRENGTH_1KEY_SUCC = "strength_1key_succ",

	OPEN_DAY_GET = "open_day_get",									--开服天数下发处理数据
	
	EXCAVATE_BOSS = "excavateboss",									-- 可挖掘boss的出现和消失
	FINISH_FUBEN = "finish_fuben",									-- 完成副本
	SHENZHU_INFO_CHANGE = "shenzhu_info_change", 					-- 神铸信息改变
}

GameObjEvent = {
	REMOVE_ALL_LISTEN = "remove_all_listen",		-- 取消所有监听
}

NewFashionEvent = {
	FaShionAdd = "FaShion_Add",
	FaShionDelete = "FaShion_Delete",
	FaShionUpdate = "FaShion_Update",
}

ZHANGUDUIHUANEVENT = {
	RESULT = "RESULT",
}

QIEGE_EVENT = {
	UpGrade_Result = "UpGrade_Result",
	GetRewardInfo = "GetRewardInfo",
	QieGeShenBinUp = "QieGeShenBinUp",
}

OPEN_VIEW_EVENT = {
	OpenEvent = "OpenEvent",
	BAOSHI_COMPOSE_EVENT = "BaoShiComposeEvent",
	REXUEEVENTBTN = "rexue_event_btn",
}

GRAP_REDENVELOPE_EVENT = {
	GetGrapRedEnvlope = "GetGrapRedEnvlope",
}

TIYAN_SHEN_BIn_EVENT = {
	TIYAN_SKILL_TiME = "TIYAN_SKILL_TiME",
}


JI_YAN_FUBEN_EVENT = {
	SKILL_NUM_CHANGE = "SKILL_NUM_CHANGE", --杀怪数量变化
	SKILL_BO_CHANGE  = "SKILL_BO_CHANGE", --杀怪波数发生变化
	DATA_CHANGE = "DATA_CHANGE", --数据发生变化
}

TIANSHUTASK_EVENT = {
	NUM_CHANGE = "NUM_CHANGE",  --次数发生变化
}

USE_NUM_EVENT = {
	NUM_CHANGE = "NUM_CHANGE",
}

BABEL_EVENET = {
	DATA_CHANGE = "DATA_CHANGE",
	RANKING_DATA_CHANGE = "RANKING_DATA_CHANGE",
	CHOUJIANG_DATA_CHANGE = "CHOUJIANG_DATA_CHANGE",
}

JINJIE_EVENT = {
	NOSHU_CHANGE = "NOSHU_CHANGE",
	YUSU_UP_CHANGE = "YUSU_UP_CHANGE",
	SHENGSHOU_UP_ENENT = "SHENGSHOU_UP_ENENT",
}

--炼狱
LIAN_FUBEN_EVENT = {
	SKILL_NUM_CHANGE = "SKILL_NUM_CHANGE", --杀怪数量变化
	SKILL_BO_CHANGE  = "SKILL_BO_CHANGE", --杀怪波数发生变化
	DATA_CHANGE = "DATA_CHANGE",
}
