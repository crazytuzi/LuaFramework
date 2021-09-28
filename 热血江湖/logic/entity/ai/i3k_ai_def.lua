----------------------------------------------------------------
eAType_BASE							=   0;
eAType_IDLE							=   5;
eAType_IDLE_NPC						=  10;
eAType_IDLE_STAND					=  11;
eAType_IDLE_JUST_STAND				=  12;
eAType_GUARD						=  13;
eAType_AUTO_NORMALATTACK			=  14;
eAType_AUTOFIGHT_FIND_WAY			=  15;
eAType_AUTOFIGHT_SKILL				=  16;
eAType_AUTOFIGHT_STUNT_SKILL		=  17;
eAType_AUTOFIGHT_MISSION_SKILL		=  18;
eAType_AUTOFIGHT_CATCH_SKILL		=  19 --驭灵自动战斗，战斗ai需要往这个后面挨着放
eAType_AUTOFIGHT_CAST_FIND_TARGET	=  20
eAType_MERCENARY_AUTO_FIND_TARGET	=  21;
eAType_MOVE							=  22;
eAType_SKILLENTITY_MOVE				=  23;
eAType_NETWORK_SKILLENTITY_MOVE		=  24;
eAType_AUTO_MOVE					=  30;
eAType_NETWORK_MOVE					=  31;
eAType_FOLLOW						=  40;
eAType_FOLLOW_ARENA					=  41;
eAType_ATTACK						=  50;
eAType_NETWORK_ATTACK				=  51;
eAType_Blink						=  55;
eAType_MANUAL_ATTACK				=  60;
eAType_FIND_TARGET					=  70;
eAType_AUTOFIGHT_FIND_TARGET		=  71;
eAType_ARENA_MERCENARY_FIND_TARGET	=  72;
eAType_AUTO_SKILL					=  80;
eAType_MANUAL_SKILL					=  90;
eAType_FORCE_FOLLOW					= 100;
eAType_FEAR							= 105;
eAType_SPA							= 110;
--eAType_RUSH						= 119;
eAType_SHIFT						= 131;
eAType_RETREAT						= 121;
eAType_DEAD							= 130;
eAType_DEAD_MERCENARY				= 135;
eAType_DEAD_REVIVE					= 140;
eAType_NETWORK_CACHE				= 190;
eAType_AUTOFIGHT_MERCENARY_SKILL	= 199;
eAType_AUTO_SUPERMODE 				= 200;
eAType_AUTOFIGHT_TRIGGER_SKILL		= 201;
eAType_PRECOMMOND					= 300;
eAType_AUTOFIGHT_RETURN				= 310;
eAType_PET_CHECK_ALIVE				= 500;
eAType_DAMAGE_CAR					= 501;
eAType_CHECK_WATER                  = 502;
eAType_CHECK_AREA                   = 503; --check区域
eAType_CHECK_HOUSE_WALL				= 504;
eAType_CHECK_FLYING					= 505; --检查飞升灵虚
eAType_CHECK_ARRIVAL_TARGET			= 506 --检测是否到地点
eAType_CHECK_FINDWAY_STATE			= 507 --公主出嫁检测是否寻路动态目标状态

------------------------------------------------------
eAI_Priority_Low	= 0;
eAI_Priority_High	= 1;

------------------------------------------------------
i3k_ai_tbl =
{
	[eAType_BASE]						= { script = "i3k_ai_base",							priority = eAI_Priority_High },
	[eAType_GUARD]						= { script = "i3k_ai_guard",						priority = eAI_Priority_Low },
	[eAType_IDLE_STAND]					= { script = "i3k_ai_idle_stand",					priority = eAI_Priority_High },
	[eAType_IDLE_JUST_STAND]			= { script = "i3k_ai_idle_just_stand",				priority = eAI_Priority_High },
	[eAType_IDLE]						= { script = "i3k_ai_idle",							priority = eAI_Priority_High },
	[eAType_MOVE]						= { script = "i3k_ai_move",							priority = eAI_Priority_High },
	[eAType_AUTO_MOVE]					= { script = "i3k_ai_auto_move",					priority = eAI_Priority_High },
	[eAType_FOLLOW]						= { script = "i3k_ai_follow",						priority = eAI_Priority_Low },
	[eAType_FOLLOW_ARENA]				= { script = "i3k_ai_follow_arena",					priority = eAI_Priority_Low },
	[eAType_MERCENARY_AUTO_FIND_TARGET]	= { script = "i3k_ai_mercenary_auto_find_target",	priority = eAI_Priority_Low },
	[eAType_Blink]						= { script = "i3k_ai_blink",						priority = eAI_Priority_Low },
	[eAType_ATTACK]						= { script = "i3k_ai_attack",						priority = eAI_Priority_Low },
	[eAType_NETWORK_ATTACK]				= { script = "i3k_ai_network_attack",				priority = eAI_Priority_Low },
	[eAType_MANUAL_ATTACK]				= { script = "i3k_ai_manual_attack",				priority = eAI_Priority_Low },
	[eAType_FIND_TARGET]				= { script = "i3k_ai_find_target",					priority = eAI_Priority_Low },
	[eAType_ARENA_MERCENARY_FIND_TARGET]= { script = "i3k_ai_arena_mercenary_find_target",	priority = eAI_Priority_Low },
	[eAType_AUTO_SKILL]					= { script = "i3k_ai_auto_skill",					priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_SKILL]			= { script = "i3k_ai_autofight_special_skill",		priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_TRIGGER_SKILL]	= { script = "i3k_ai_autofight_trigger_skill",		priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_STUNT_SKILL]		= { script = "i3k_ai_autofight_stunt_skill",		priority = eAI_Priority_Low },
	[eAType_MANUAL_SKILL]				= { script = "i3k_ai_manual_skill",					priority = eAI_Priority_Low },
	[eAType_FORCE_FOLLOW]				= { script = "i3k_ai_force_follow",					priority = eAI_Priority_Low },
	[eAType_FEAR]						= { script = "i3k_ai_fear",							priority = eAI_Priority_Low },
	[eAType_SPA]						= { script = "i3k_ai_spa",							priority = eAI_Priority_Low },
	[eAType_SHIFT]						= { script = "i3k_ai_shift",						priority = eAI_Priority_Low },
	[eAType_RETREAT]					= { script = "i3k_ai_retreat",						priority = eAI_Priority_Low },
	[eAType_DEAD]						= { script = "i3k_ai_dead",							priority = eAI_Priority_High },
	[eAType_DEAD_MERCENARY]				= { script = "i3k_ai_dead_mercenary",				priority = eAI_Priority_High },
	[eAType_DEAD_REVIVE]				= { script = "i3k_ai_dead_revive",					priority = eAI_Priority_High },
	[eAType_NETWORK_MOVE]				= { script = "i3k_ai_network_auto_move",			priority = eAI_Priority_High },
	[eAType_NETWORK_CACHE]				= { script = "i3k_ai_network_cache",				priority = eAI_Priority_High },
	[eAType_PET_CHECK_ALIVE]			= { script = "i3k_ai_pet_check_alive",				priority = eAI_Priority_Low },
	[eAType_IDLE_NPC]					= { script = "i3k_ai_idle_npc",						priority = eAI_Priority_High },
	[eAType_AUTOFIGHT_MERCENARY_SKILL]	= { script = "i3k_ai_autofight_mercenary_skill",	priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_FIND_TARGET]		= { script = "i3k_ai_autofight_find_target",		priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_FIND_WAY]			= { script = "i3k_ai_autofight_find_way",			priority = eAI_Priority_Low },
	[eAType_PRECOMMOND]					= { script = "i3k_ai_precommond",					priority = eAI_Priority_Low },
	[eAType_AUTO_NORMALATTACK]			= { script = "i3k_ai_auto_normalattack",			priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_RETURN]			= { script = "i3k_ai_autofight_return",				priority = eAI_Priority_Low },
	[eAType_SKILLENTITY_MOVE]			= { script = "i3k_ai_skillentity_move",				priority = eAI_Priority_Low },
	[eAType_NETWORK_SKILLENTITY_MOVE]	= { script = "i3k_ai_network_skillentity_move",		priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_MISSION_SKILL]	= { script = "i3k_ai_autofight_mission_skill",		priority = eAI_Priority_Low },
	[eAType_AUTOFIGHT_CAST_FIND_TARGET]	= { script = "i3k_ai_autofight_cast_find_target",	priority = eAI_Priority_Low },
	[eAType_DAMAGE_CAR]					= { script = "i3k_ai_damage_car",					priority = eAI_Priority_Low },
	[eAType_AUTO_SUPERMODE]				= { script = "i3k_ai_auto_supermode",				priority = eAI_Priority_Low },
    [eAType_CHECK_WATER]				= { script = "i3k_ai_check_water",				    priority = eAI_Priority_Low },
    [eAType_CHECK_AREA]					= { script = "i3k_ai_check_area",				    priority = eAI_Priority_Low },
	[eAType_CHECK_HOUSE_WALL]			= { script = "i3k_ai_check_house_wall",				priority = eAI_Priority_Low },
	[eAType_CHECK_FLYING]				= { script = "i3k_ai_check_flying",					priority = eAI_Priority_Low },
	[eAType_CHECK_ARRIVAL_TARGET]		= { script = "i3k_ai_check_arrival_target",			priority = eAI_Priority_Low },
	[eAType_CHECK_FINDWAY_STATE]		= { script = "i3k_ai_check_findway_state",			priority = eAI_Priority_Low },	
	[eAType_AUTOFIGHT_CATCH_SKILL]		= { script = "i3k_ai_autofight_catch_skill",		priority = eAI_Priority_Low },
};

