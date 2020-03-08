Npc.KIND = {
	none = -1,
	normal = 0,
	player = 1,
	dialoger = 2,
	partner = 3,
	silencer = 4,
	num = 5,
}

Npc.Series = {
	[1] = "金",
	[2] = "木",
	[3] = "水",
	[4] = "火",
	[5] = "土",
}

Npc.tbSeriesRelation = {
-- 克制五行, 被克制五行
    {2, 4},
    {5, 1},
    {4, 5},
    {1, 3},
    {3, 2},
}

Npc.SeriesColor = {
	[1] = "F8CE26";
	[2] = "2CC517";
	[3] = "32B3DD";
	[4] = "F4480D";
	[5] = "87683D";
};

-- 与NpcDefine.h当中的枚举保持一致
Npc.Doing = {
	none            = 0,
	stand           = 1,
	run             = 2,
	skill           = 3,
	jump            = 4,
	death           = 5,
	revive          = 6,
	knockback       = 7,
	force_attack    = 8,
	rand_move       = 9,
	runattack       = 10,
	ctrl_run_attack = 11,
	common          = 12,
	runattackmany   = 13,
	float           = 14,
	sit             = 15,
	do_attach       = 16,
}
Npc.ActionId =
{
    act_none  = 0,
    act_stand = 1,
    act_run   = 2,
    act_death = 3,
    act_bat   = 4,
    act_drag  = 5,
    act_qg 	  = 6, 
    act_fightstand =7,
    act_float = 8,
    act_byhit =9,
    act_walk  =10,
    act_presit=11,
    act_sit   =12,
    
    st01 = 13;
    at01 = 16,
};

-- 与NpcRelation.h当中的枚举保持一致
Npc.RELATION =
{
	self     = 0,
	obj      = 1,
	npc      = 2,
	player   = 3,
	hide     = 4,
	enemy    = 5,
	team     = 6,
	kin      = 7,
	npc_call = 17,
	hide_grass= 18,
	num      = 19,
};

Npc.RELATION_TYPE =
{
	Must = 1;
	Allow = 2;
	Forbid = 3;
}

Npc.DIALOG_DISTANCE = 250;

--npc 状态 和 skiidefine.h 中枚举一样
Npc.STATE = {
	HURT			= 0;		-- 受伤动作状态
	ZHICAN 			= 1;		-- 致残
	SLOWALL			= 2;		-- 迟缓状态
	PALSY			= 3;		-- 麻痹状态
	STUN			= 4;		-- 眩晕状态

	FIXED			= 5; 		-- 定身
	WEAK			= 6;		-- 虚弱状态
	BURN			= 7;		-- 灼伤状态
	SLOWRUN			= 8;		-- 减跑速状态
	FREEZE			= 9;		-- 冻结状态
	CONFUSE			= 10;		-- 混乱状态
	KNOCK			= 11;		-- 击退状态
	DRAG			= 12;		-- 拉回
	SILENCE			= 13;		-- 沉默
	FLOAT			= 14;		-- 浮空
	SELFFREEZE		= 15;		-- 冰箱
	SLEEP			= 16;		-- 睡眠
	KNOCK2			= 17;		-- 击退
	NOJUMP 			= 18; 		-- 禁用轻功
	FORCEATK 		= 19; 		-- 嘲讽
	DRAGFLOAT 		= 20; 		-- 空中拉到地上
	NPC_HURT 		= 21;   	-- Npc受伤
	NPC_KNOCK		= 22;		-- Npc击退

	NPC_HIDE        = 23;       --隐身
	SHIELD          = 24,		--护盾状态
	FIX_SHIELD      = 25,	    --固定护盾状态
}


Npc.FIGHT_MODE =
{
	emFightMode_None = 0,			--非战斗状态
	emFightMode_Fight = 1,			--战斗状态
	emFightMode_Death = 2,			--幽灵状态，和所有Npc（包括玩家）都是非敌对关系，但是表现为战斗状态
};

Npc.ActEventNameType =
{
	act_cast_skill = 1,
	act_play_effect = 2,
	act_clear_effect = 3,
	act_unbind_effect = 4,
	act_event_print = 5,
	act_event_play_shake = 6,
	act_event_stop_shake = 7,
	act_link_init = 8,
	act_cast_link_skill = 9,
	act_event_move_pos = 10,
	act_event_instant_dir = 11,
	act_cross_fade = 12,
	act_use_last_act = 13,
	act_play_scene_effect = 14,
	act_npc_change_size = 15,
	act_open_scene_gray = 16,
	act_close_scene_gray = 17,
};


Npc.CampTypeDef =
{
	camp_type_player = 0,
	camp_type_npc    = 1,
	camp_type_neutrality = 2, --中立
	camp_type_song   = 3, --宋
	camp_type_jin    = 4, --金
}

Npc.tbCampTypeName =
{
	[Npc.CampTypeDef.camp_type_neutrality] = "中立";
	[Npc.CampTypeDef.camp_type_song]       = "宋";
	[Npc.CampTypeDef.camp_type_jin]        = "金";
}
if version_vn or version_th or version_kor then
	Npc.tbCampTypeName[Npc.CampTypeDef.camp_type_song]       = "宋方";
	Npc.tbCampTypeName[Npc.CampTypeDef.camp_type_jin]        = "金方";
end


Npc.NpcResPartsDef =
{
	npc_part_body = 0,
	npc_part_weapon = 1,
	npc_part_wing = 2,
	npc_part_horse = 3,
	npc_part_head = 4,
	npc_part_back = 5,
	npc_res_part_count = 6,
};

Npc.NpcPartLayerDef =
{
	npc_part_layer_base = 0,
	npc_part_layer_effect = 1,
	npc_part_layer_count = 2,
};

Npc.emNPC_FLYCHAR_ADD_EXP = 8;

Npc.MAX_NPC_LEVEL = 255; --Npc最大等级

Npc.NpcActionModeType =
{
	act_mode_none = 0,
	act_mode_ride = 1,
};

Npc.AttachType =
{
	npc_attach_type_none = 0,
	npc_attach_npc_pos = 1,  --挂在其他npc上 参数1：NpcID，2：X 3：Y
	npc_attach_npc_horse = 2, --挂在其他npc马上  参数1：NpcID，2：马插槽ID
	npc_attach_npc_self = 3, --挂在自己身上 参数1：马插槽 X, y
};

Npc.nMaxAwardLen = 1400; --野外打怪Npc的奖励范围（经验、掉落）

Npc.nDialogSoundScale = 300	-- NPC说话的音量缩放(100为原始大小，500为原始大小的5倍，依次类推)

Npc.tbActionBQNpcID = --可以播放表情的NpcID
{
	[2353] = 1,
	[2354] = 1,
	[2355] = 1,
	[2356] = 1,
	[2357] = 1,
	[2358] = 1,
	[2359] = 1,
	[2360] = 1,
	[2361] = 1,
};

Npc.tbForbidTrapDoing = --禁止踩trap的动作，一般用于副本或地图中踩trap释放轻功
{
	[Npc.Doing.skill] = true,
	[Npc.Doing.ctrl_run_attack] = true,
}

Npc.tbDropReazon = {
	["QSHL_DOUBLE_SMALL"] = 1, --皇陵小怪
	["QSHL_DOUBLE_BIG"]   = 2, --皇陵精英
	["BHT_DOUBLE_ALL"]    = 3, --白虎
}