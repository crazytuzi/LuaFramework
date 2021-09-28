----------------------------------------------------------------
module(..., package.seeall)

local require = require;

require("i3k_global");


----------------------------------------------------------------
local i3k_db_map =
{
	i3k_db_common					= { path = "i3k_db_common" },
	i3k_db_combat_maps				= { path = "i3k_db_combat_maps", },
	i3k_db_generals					= { path = "i3k_db_generals", },
	i3k_db_general_fashion			= { path = "i3k_db_generals", },
	i3k_db_fashion_res				= { path = "i3k_db_generals", },
	i3k_db_models					= { path = "i3k_db_models" },
	i3k_db_models_actions			= { path = "i3k_db_models_actions"},
	--[[
	i3k_db_skills					= { path = "i3k_db_skills", binary = true },
	i3k_db_skill_datas				= { path = "i3k_db_skills", binary = true },
	i3k_db_state					= { path = "i3k_db_skills", binary = true },
	]]
	i3k_db_skills					= { path = "i3k_db_skills", },
	i3k_db_skill_datas				= { path = "i3k_db_skill_datas", },
	i3k_db_state					= { path = "i3k_db_skills", },
	i3k_db_skill_vfx				= { path = "i3k_db_skill_vfx", },
	i3k_db_skill_talent				= { path = "i3k_db_skill_talent", },
	i3k_db_skins					= { path = "i3k_db_skins", },
	i3k_db_buff						= { path = "i3k_db_buff", },
	i3k_db_prop_id					= { path = "i3k_db_properties", },
	i3k_db_effects					= { path = "i3k_db_effects", },
	i3k_db_state_affect				= { path = "i3k_db_state_affect", },
	i3k_db_sound					= { path = "i3k_db_sound", },
	i3k_db_pets						= { path = "i3k_db_pets", },
	i3k_db_mercenaries				= { path = "i3k_db_mercenaries", },
	i3k_db_spawn_area				= { path = "i3k_db_dungeon", },
	i3k_db_spawn_point				= { path = "i3k_db_dungeon", },
	i3k_db_npc_area					= { path = "i3k_db_dungeon", },
	i3k_db_resourcepoint_area		= { path = "i3k_db_dungeon", },
	i3k_db_transfer_point			= { path = "i3k_db_dungeon", },
	i3k_db_mapbuff					= { path = "i3k_db_dungeon", },
	i3k_db_trap_exchange			= { path = "i3k_db_trap_exchange", },
	i3k_db_icons					= { path = "i3k_db_icons", },
	i3k_db_traps_base				= { path = "i3k_db_traps_base", },
	i3k_db_traps_external			= { path = "i3k_db_traps_external", },
	i3k_db_monsters					= { path = "i3k_db_monsters", },
	i3k_db_monsters_damageodds		= { path = "i3k_db_monsters", },
	i3k_db_equips					= { path = "i3k_db_equips", },
	i3k_db_new_item					= { path = "i3k_db_new_item", },
	i3k_db_diamond					= { path = "i3k_db_diamond", },
	i3k_db_diamond_bless			= { path = "i3k_db_diamond_bless", },
	i3k_db_base_item				= { path = "i3k_db_base_item", },
	i3k_db_streng_equip				= { path = "i3k_db_streng_equip", },
	i3k_db_streng_equip_break		= { path = "i3k_db_streng_equip", },
	i3k_db_string					= { path = "i3k_db_string", },
	i3k_db_up_star					= { path = "i3k_db_up_star", },
	i3k_db_up_star_percent			= { path = "i3k_db_up_star", },
	i3k_db_common_award_property	= { path = "i3k_db_common_award_property", },
	i3k_db_xinfa					= { path = "i3k_db_xinfa", },
	i3k_db_xinfa_data				= { path = "i3k_db_xinfa_data", },
	i3k_db_zhuanzhi					= { path = "i3k_db_zhuanzhi", },
	i3k_db_ai_trigger				= { path = "i3k_db_trigger", },
	i3k_db_trigger_event			= { path = "i3k_db_trigger", },
	i3k_db_trigger_behavior			= { path = "i3k_db_trigger", },
	i3k_db_gift_bag					= { path = "i3k_db_gift_bag", },
	i3k_db_single_consume			= { path = "i3k_db_single_consume", },
	i3k_db_exp						= { path = "i3k_db_exp", },
	i3k_db_server_limit				= { path = "i3k_db_server_limit", },
	i3k_db_npc						= { path = "i3k_db_npc", },
	i3k_db_shen_bing				= { path = "i3k_db_shen_bing", },
	i3k_db_shen_bing_uplvl			= { path = "i3k_db_shen_bing_uplvl", },
	i3k_db_shen_bing_upstar			= { path = "i3k_db_shen_bing_upstar", },
	i3k_db_resourcepoint			= { path = "i3k_db_resourcepoint", },
	i3k_db_suicong_relation			= { path = "i3k_db_suicong_relation", },
	i3k_db_suicong_uplvl			= { path = "i3k_db_suicong_uplvl", },
	i3k_db_suicong_skillUplvl		= { path = "i3k_db_suicong_skillUplvl"},
	i3k_db_suicong_upstar			= { path = "i3k_db_suicong_upstar", },
	i3k_db_suicong_transfer			= { path = "i3k_db_suicong_transfer", },
	i3k_db_suicong_breakdata		= { path = "i3k_db_suicong_breakdata", },
	i3k_db_suicong_spirits			= { path = "i3k_db_suicong_spirits" },
	i3k_db_suicong_exploit			= { path = "i3k_db_suicong_exploit"},
	i3k_db_equip_part				= { path = "i3k_db_equip_part", },
	i3k_db_upStar_attribute			= {	path = "i3k_db_equip_part"},
	i3k_db_main_line_task			= { path = "i3k_db_main_line_task", },
	i3k_db_weapon_task				= { path = "i3k_db_weapon_task", },
	i3k_db_pet_task					= { path = "i3k_db_pet_task", },
	i3k_db_xinfa_book				= { path = "i3k_db_xinfa_book", },
	i3k_db_suit_equip				= { path = "i3k_db_suit_equip", },
	i3k_db_find_path_data			= { path = "i3k_db_find_path_data", },
	i3k_db_faction_uplvl			= { path = "i3k_db_faction_uplvl", },
	i3k_db_faction_skill			= { path = "i3k_db_faction_skill", },
	i3k_db_faction_worship_exp		= { path = "i3k_db_faction_worship_exp", },
	i3k_db_faction_worship			= { path = "i3k_db_faction_worship", },
	i3k_db_faction_dine				= { path = "i3k_db_faction_dine", },
	i3k_db_faction_store			= { path = "i3k_db_faction_store", },
	i3k_db_faction_store_refresh	= { path = "i3k_db_faction_store_refresh", },
	i3k_db_faction_dungeon			= { path = "i3k_db_faction_dungeon", },
	i3k_db_faction_team_dungeon			= { path = "i3k_db_faction_team_dungeon", },
	i3k_db_faction_team_dungeon_rank_award			= { path = "i3k_db_faction_team_dungeon_rank_award", },
	i3k_db_dungeon_base				= { path = "i3k_db_dungeon_base", },
	i3k_db_monster_map				= { path = "i3k_db_dungeon_base", },
	i3k_db_npc_map					= { path = "i3k_db_dungeon_base", },
	i3k_db_res_map					= { path = "i3k_db_dungeon_base", },
	i3k_db_new_dungeon				= { path = "i3k_db_new_dungeon", },
	i3k_db_field_map				= { path = "i3k_db_field_map", },
	i3k_db_fightsp					= { path = "i3k_db_fightsp", },
	i3k_db_fightpet					= { path = "i3k_db_fightsp", },
	i3k_db_summoned					= { path = "i3k_db_fightsp", },
	i3k_db_dailyTask				= { path = "i3k_db_dailyTask", },
	i3k_db_mapbuff_base				= { path = "i3k_db_mapbuff_base", },
	i3k_db_role_surname				= { path = "i3k_db_role_name", },
	i3k_db_role_given_name_male		= { path = "i3k_db_role_name", },
	i3k_db_role_given_name_female	= { path = "i3k_db_role_name", },
	i3k_db_base_head				= { path = "i3k_db_head", },
	i3k_db_head						= { path = "i3k_db_head", },
	i3k_db_personal_icon			= { path = "i3k_db_head", },
	i3k_db_head_frame				= { path = "i3k_db_head", },
	i3k_db_create_kungfu_base		= { path = "i3k_db_create_kungfu_base", },
	i3k_db_create_kungfu_args		= { path = "i3k_db_create_kungfu_args", },
	i3k_db_faction_task				= { path = "i3k_db_faction_task", },
	i3k_db_create_kungfu_showargs	= { path = "i3k_db_create_kungfu_showargs", },
	i3k_db_create_kungfu_score		= { path = "i3k_db_kungfu_score", },
	i3k_db_kungfu_slot				= { path = "i3k_db_kungfu_slot", },
	i3k_db_kungfu_args				= { path = "i3k_db_kungfu_args", },
	i3k_db_kungfu_vip				= { path = "i3k_db_kungfu_vip", },
	i3k_db_arenaRobot				= { path = "i3k_db_arenaRobot", },
	i3k_db_arena					= { path = "i3k_db_arena", },
	i3k_db_arenaShopCost			= { path = "i3k_db_arenaShop", },
	i3k_db_arenaShop				= { path = "i3k_db_arenaShop", },
	i3k_db_fameShopCfg              = { path = "i3k_db_fameShop", },
	i3k_db_fameShopCost             = { path = "i3k_db_fameShop", },
	i3k_db_fameShop                 = { path = "i3k_db_fameShop", },
	i3k_db_faction_icons			= { path = "i3k_db_faction_icons", },
	i3k_db_pkpunish					= { path = "i3k_db_pkpunish", },
	--i3k_db_filter_rule				= { path = "i3k_db_filter_rule", },
	i3k_db_challengeTask			= { path = "i3k_db_challengeTask", },
	i3k_db_evaluation				= { path = "i3k_db_challengeTask", },
	i3k_db_clan_production_up_lvl	= { path = "i3k_db_clan_production", },
	i3k_db_clan_separation			= { path = "i3k_db_clan_production", },
	i3k_db_producetion_args			= { path = "i3k_db_clan_production", },
	i3k_db_productioninfo			= { path = "i3k_db_clan_production", },
	i3k_db_clan_recycle_base_info   = { path = "i3k_db_clan_production", },
	i3k_db_recycle_lvl_and_drop		= { path = "i3k_db_clan_production",},
	i3k_db_rank_reward				= { path = "i3k_db_arena_reward", },
	i3k_db_score_reward 			= { path = "i3k_db_arena_reward", },
	i3k_db_rank_best_reward			= { path = "i3k_db_arena_reward", },
	i3k_db_clan_mine_args			= { path = "i3k_db_clan_mine_args", },
	i3k_db_clan_child_name			= { path = "i3k_db_clan_child_name", },
	i3k_db_clan_mine_up_lvl			= { path = "i3k_db_clan_mine_up_lvl", },
	i3k_db_channel_pay				= { path = "i3k_db_channel_pay", },
	i3k_db_channels					= { path = "i3k_db_channel_pay", },
	i3k_db_channel_area				= { path = "i3k_db_channel_pay",},
	i3k_db_faction_access			= { path = "i3k_db_faction_access", },
	i3k_db_activity					= { path = "i3k_db_activity", },
	i3k_db_activity_cfg				= { path = "i3k_db_activity_cfg", },
	i3k_db_world_boss				= { path = "i3k_db_world_boss", },
	i3k_db_dialogue					= { path = "i3k_db_dialogue", },
	i3k_db_chat_dialogue			= { path = "i3k_db_chat_dialogue", },
	i3k_db_sign						= { path = "i3k_db_sign", },
	i3k_db_drugshop					= { path = "i3k_db_drugshop", },
	i3k_db_auction_type				= {path = "i3k_db_auction_type",},
	i3k_db_auction_2v2_req 			= {path = "i3k_db_auction_type"},
	i3k_db_auction_special			= {path = "i3k_db_auction_type"},
	i3k_db_steed_cfg				= {path = "i3k_db_steed_cfg"},
	i3k_db_steed_huanhua			= {path = "i3k_db_steed_cfg"},
	i3k_db_steed_star				= {path = "i3k_db_steed_cfg"},
	i3k_db_steed_common				= {path = "i3k_db_steed_cfg"},
	i3k_steed_lvl_propLock			= {path = "i3k_db_steed_cfg"},
	i3k_db_steed_practice			= {path = "i3k_db_steed_practice"},
	i3k_db_steed_Properties_ui		= {path = "i3k_db_steed_practice"},
	i3k_db_steed_lvl				= {path = "i3k_db_steed_lvl"},
	i3k_db_steed_effect				= {path = "i3k_db_steed_cfg"},
	i3k_db_steed_skill				= {path = "i3k_db_steed_skill"},
	i3k_db_steed_skill_cfg			= {path = "i3k_db_steed_skill_cfg"},
	i3k_db_clan_presgite			= {path = "i3k_db_clan_presgite"},
	i3k_db_hostel_npc				= {path = "i3k_db_hostel_npc"},
	i3k_db_treasure					= {path = "i3k_db_treasure"},
	i3k_db_treasure_chip			= {path = "i3k_db_treasure"},
	i3k_db_spot_list				= {path = "i3k_db_treasure"},
	i3k_db_clue						= {path = "i3k_db_treasure"},
	i3k_db_collection				= {path = "i3k_db_treasure"},
	i3k_db_treasure_base			= {path = "i3k_db_treasure_base"},
	i3k_db_npc_prestige				= {path = "i3k_db_treasure_base"},
	i3k_db_little_activity	        = {path = "i3k_db_little_activity"},
	i3k_db_fashion_dress			= {path = "i3k_db_fashion_dress"},
	i3k_db_friends_award			= {path = "i3k_db_friends_award"},
	i3k_db_fashion_reflect			= {path = "i3k_db_fashion_reflect"},
	i3k_db_create_kungfu_showargs_new	= {path = "i3k_db_create_kungfu_showargs_new"},
	i3k_db_fashion_dress_skin		= {path = "i3k_db_fashion_dress"},
	i3k_db_fashion_wardrobe			= {path = "i3k_db_fashion_dress"},
	i3k_db_fashion_base_info		= {path = "i3k_db_fashion_dress"},
	i3k_db_fashion_prop_max			= {path = "i3k_db_fashion_dress"},
	i3k_db_missionmode_cfg			= {path = "i3k_db_missionmode_cfg"},
	i3k_db_loading_first			= {path = "i3k_db_loading_first"},
	i3k_db_loading_tips				= {path = "i3k_db_loading_tips"},
	i3k_db_loading_icon				= {path = "i3k_db_loading_icon"},
	i3k_db_leadtrigger				= {path = "i3k_db_leadtrigger"},
	i3k_db_leadtrigger_event		= {path = "i3k_db_leadtrigger"},
	i3k_db_leadtrigger_behavior		= {path = "i3k_db_leadtrigger"},
	i3k_db_charm_name				= {path = "i3k_db_charm_name"},
	i3k_db_title_base				= {path = "i3k_db_title_base"},
	i3k_db_sendflower_chat 			= {path = "i3k_db_sendflower_chat"},
	i3k_db_answer_questions_activity			= {path = "i3k_db_answer_questions_activity"},
	i3k_db_question_bank 			= {path = "i3k_db_question_bank"},
	i3k_db_leadtriggerUI			= {path = "i3k_db_leadtriggerUI"},
	i3k_db_missionnpcs				= {path = "i3k_db_missionmode_cfg"},
	i3k_db_missionnpcs				= {path = "i3k_db_missionmode_cfg"},
	i3k_db_lucky_wheel				= {path = "i3k_db_lucky_wheel"},
	i3k_db_equip_effect				= {path = "i3k_db_equip_effect"},
	i3k_db_tournament				= {path = "i3k_db_tournament"},
	i3k_db_tournament_weapon_skills = {path = "i3k_db_tournament"},
	i3k_db_social					= {path = "i3k_db_social"},
	i3k_db_cfg_res_version 			= {path = "i3k_db_cfg_res_version"},
	i3k_db_tournament_base			= {path = "i3k_db_tournament_base"},
	i3k_db_offline_exp 				= {path = "i3k_db_offline_exp"},
	i3k_db_LongYin_arg 				= {path = "i3k_db_LongYin_arg"},
	i3k_db_LongYin_UpLvl 			= {path = "i3k_db_LongYin_UpLvl"},
	i3k_db_LongYin_UpSkill 			= {path = "i3k_db_LongYin_UpSkill"},
	i3k_db_LongYin_lock 			= {path = "i3k_db_LongYin_UpSkill"},
	i3k_db_LongYin_ban 				= {path = "i3k_db_LongYin_UpSkill"},
	i3k_db_rank_list  				= {path = "i3k_db_rank_list"},
	i3k_db_rank_list_name  			= {path = "i3k_db_rank_list_name"},
	i3k_db_tournament_shop		= {path = "i3k_db_tournament_shop"},
	i3k_db_tournament_shop_base	= {path = "i3k_db_tournament_shop"},
	i3k_db_lead_text		= {path = "i3k_db_lead_text"},
	i3k_db_taoist				= {path = "i3k_db_taoist"},
	i3k_db_taoist_level_cfg		= {path = "i3k_db_taoist"},
	i3k_db_experience_args  = {path = "i3k_db_experience_args"},
	i3k_db_experience_library = {path = "i3k_db_experience_library"},
	i3k_db_experience_canwu  = {path = "i3k_db_experience_canwu"},
	i3k_db_function_open_cfg  = {path = "i3k_db_function_open"},
	i3k_db_function_open  = {path = "i3k_db_function_open"},
	i3k_db_leadplot = {path = "i3k_db_leadplot"},
	i3k_db_leadplot_event  = {path = "i3k_db_leadplot_event"},
	i3k_db_preView_cfg  = {path = "i3k_db_preView"},
	i3k_db_preView_event  = {path = "i3k_db_preView"},
	i3k_db_fengce				= {path = "i3k_db_fengce"},
	i3k_db_fengce_name			= {path = "i3k_db_fengce_name"},
	i3k_db_fengce_survey		= {path = "i3k_db_fengce_survey"},
	i3k_db_sceneFlash			= {path = "i3k_db_sceneFlash"},
	i3k_db_plotFlash			= {path = "i3k_db_plotFlash"},
	i3k_db_title_icon			= {path = "i3k_db_title_base"},
	i3k_db_scene_icons			= {path = "i3k_db_scene_icons"},
	i3k_db_npc_function_show	= {path = "i3k_db_npc_function_show"},
	i3k_db_mercenaryAchievement		= {path = "i3k_db_mercenaryAchievement"},
	i3k_db_subline_task			= {path = "i3k_db_subline_task"},
	i3k_db_exskills				= {path = "i3k_db_exskills"},
	i3k_db_from_task			= {path = "i3k_db_from_task"},
	i3k_db_climbing_tower   			= {path = "i3k_db_climbing_tower"},
	i3k_db_climbing_tower_prestige   	= {path = "i3k_db_climbing_tower_prestige"},
	i3k_db_climbing_tower_fb   		 	= {path = "i3k_db_climbing_tower_fb"},
	i3k_db_climbing_tower_datas    		= {path = "i3k_db_climbing_tower_datas"},
	i3k_db_climbing_tower_args    		= {path = "i3k_db_climbing_tower_args"},
	i3k_db_secretarea_task    			= {path = "i3k_db_secretarea_task"},
	i3k_db_escort_wish    				= {path = "i3k_db_escort_wish"},
	i3k_db_escort_car   				= {path = "i3k_db_escort_car_quality"},
	i3k_db_escort    					= {path = "i3k_db_escort"},
	i3k_db_escort_task    				= {path = "i3k_db_escort_task"},
	i3k_db_escort_path					= {path = "i3k_db_escort_path"},
	i3k_db_roleTitle_type				= {path = "i3k_db_roleTitle_type"},
	i3k_db_boss_level_color				= {path = "i3k_db_boss_level_color"},
	i3k_db_forcewar						= {path = "i3k_db_forcewar"},
	i3k_db_forcewar_base				= {path = "i3k_db_forcewar_base"},
	i3k_db_forcewar_fb					= {path = "i3k_db_forcewar_fb"},
	i3k_db_tournament_fb				= {path = "i3k_db_tournament_fb"},
	i3k_db_roll_notice					= {path = "i3k_db_roll_notice"},
	i3k_db_escort_store_refresh			= {path = "i3k_db_escort_refresh"},
	i3k_db_escort_store					= {path = "i3k_db_escort_store"},
	i3k_db_seven_keep_activity			= {path = "i3k_db_seven_keep_activity"},
	i3k_db_task_leadUI					= {path = "i3k_db_task_leadUI"},
	i3k_db_compound						= {path = "i3k_db_compound"},
	i3k_db_bill_board                   = {path = "i3k_db_bill_board"},
	i3k_db_bill_board_reqlvl            = {path = "i3k_db_bill_board_reqlvl"},
	i3k_db_schedule						= {path = "i3k_db_schedule"},
	i3k_db_under_wear_cfg				= {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_update			= {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_upStage			= {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_wuxun			    = {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_alone			    = {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_slot              = {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_rune_lang	        = {path = "i3k_db_under_wear_cfg"},
	i3k_db_under_wear_rune_wish         = {path = "i3k_db_under_wear_cfg"},
	i3k_db_rune_lang_upgrade			= {path = "i3k_db_under_wear_cfg"},

	i3k_db_image_effect					= {path = "i3k_db_image_effect"},
	i3k_db_image_effect_dynamic			= {path = "i3k_db_image_effect"},
	i3k_db_new_player_guide_init        = {path = "i3k_db_new_player_guide_init"},
	i3k_db_new_player_guide_lead        = {path = "i3k_db_new_player_guide_lead"},
	i3k_db_new_player_guide_effect      = {path = "i3k_db_new_player_guide_effect"},
	i3k_db_new_player_guide_cfg     	= {path = "i3k_db_new_player_guide_cfg"},
	i3k_db_scene_trigger				= {path = "i3k_db_scene_trigger"},
	i3k_db_task_question                = {path = "i3k_db_task_question"},

	i3k_db_marry_rules				    = {path = "i3k_db_marry_cfg"},
	i3k_db_marry_grade				    = {path = "i3k_db_marry_cfg"},
	i3k_db_marry_gift_bag_drop		 	= {path = "i3k_db_marry_cfg"},
	i3k_db_parade_gift_bag_drop			= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_wendding				= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_thieves				= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_levels				    = {path = "i3k_db_marry_cfg"},
	i3k_db_marry_attribute				= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_skills				    = {path = "i3k_db_marry_cfg"},
	i3k_db_marryTaskCfg					= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_car					= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_reserve				= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_line					= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_title					= {path = "i3k_db_marry_cfg"},
	i3k_db_marry_card					= {path = "i3k_db_marry_cfg"},
	i3k_db_push_service 				= {path = "i3k_db_push_service"},
	i3k_db_npc_exchange                 = {path = "i3k_db_npc_exchange"},
	i3k_db_npc_exchange_cfg				= {path = "i3k_db_npc_exchange"},
	i3k_db_shen_bing_upskill            = {path = "i3k_db_shen_bing_upskill"},
	i3k_db_shen_bing_talent             = {path = "i3k_db_shen_bing_talent"},
	i3k_db_shen_bing_talent_buy         = {path = "i3k_db_shen_bing_talent_buy"},
	i3k_db_shen_bing_talent_init        = {path = "i3k_db_shen_bing_talent_init"},
	i3k_db_shen_bing_unique_skill       = {path = "i3k_db_shen_bing_unique_skill"},
	i3k_db_grab_red_envelope		    = {path = "i3k_db_grab_red_envelope_cfg"},
	i3k_db_faction_rob_flag 			= {path = "i3k_db_faction_rob_flag"},
	i3k_db_marry_seriesTask				= {path = "i3k_db_marry_seriesTask"},
	i3k_db_marry_loopTask				= {path = "i3k_db_marry_loopTask"},
	i3k_db_faction_map_flag				= {path = "i3k_db_faction_map_flag"},
	i3k_db_fame			                = {path = "i3k_db_fame"},
	i3k_db_fame_typeDesc			    = {path = "i3k_db_fame_TypeDesc"},
	i3k_db_fame_condition			    = {path = "i3k_db_fame_condition"},
	i3k_db_strengthen_self		    	= {path = "i3k_db_strengthen_self"},
	i3k_db_month_card_award		    	= {path = "i3k_db_month_card_award"},
	i3k_db_drop_cfg				        = {path = "i3k_db_drop_cfg"},
	i3k_db_jingying_guai				= {path = "i3k_db_jingying_guai"},
	i3k_db_huodong_kuang				= {path = "i3k_db_huodong_kuang"},
	i3k_db_activity_wipe				= {path = "i3k_db_activity_wipe"},
	i3k_db_chuanjiabao					= {path = "i3k_db_chuanjiabao"},
	i3k_db_faction_power				= {path = "i3k_db_faction_power"},
	i3k_db_martialFeat_Shop				= {path = "i3k_db_martialFeat_Shop"},
	i3k_db_weapon_npc					= {path = "i3k_db_weapon_npc"},
	i3k_db_activitychallenge			= {path = "i3k_db_activitychallenge"},
	i3k_db_MapCopy_Dialogue				= {path = "i3k_db_MapCopy_Dialogue"},
	i3k_db_experience_universe			= {path = "i3k_db_experience_universe"},
	i3k_db_equips_legends_1				= {path = "i3k_db_equips_legends_1"},
	i3k_db_equips_legends_2				= {path = "i3k_db_equips_legends_1"},
	i3k_db_equips_legends_3				= {path = "i3k_db_equips_legends_1"},
	i3k_db_flashsale_icons				= {path = "i3k_db_flashsale_icons"},
	i3k_db_retrieve_act					= {path = "i3k_db_retrieve_act"},
	i3k_db_auction_lvl_select 			= {path = "i3k_db_auction_type"},
	i3k_db_auction_search_equip			= {path = "i3k_db_auction_search_equip"},
	i3k_db_auction_search_gen			= {path = "i3k_db_auction_search_gen"},
	i3k_db_auction_search_item			= {path = "i3k_db_auction_search_item"},
	i3k_db_auction_search_xinfa			= {path = "i3k_db_auction_search_xinfa"},
	i3k_db_auction_select_equip			= {path = "i3k_db_auction_select_equip"},
	i3k_db_auction_select_item			= {path = "i3k_db_auction_select_item"},
	i3k_db_auction_select_xinfa			= {path = "i3k_db_auction_select_xinfa"},
	i3k_db_demonhole_base				= {path = "i3k_db_demonhole_base"},
	i3k_db_demonhole					= {path = "i3k_db_demonhole"},
	i3k_db_steleAct						= {path = "i3k_db_steleAct"},
	i3k_db_rightHeart					= {path = "i3k_db_rightHeart"},
	i3k_db_rightHeart2					= {path = "i3k_db_rightHeart2"},
	i3k_db_demonhole_fb					= {path = "i3k_db_demonhole_fb"},
	i3k_db_annunciate					= {path = "i3k_db_annunciate"},
	i3k_db_fight_npc					= {path = "i3k_db_fight_npc"},
	i3k_db_fight_npc_fb					= {path = "i3k_db_fight_npc_fb"},
	i3k_db_annunciate_dungeon			= {path = "i3k_db_annunciate_dungeon"},
	i3k_db_luckyStar					= {path = "i3k_db_luckyStar"},
	i3k_db_arder_pet					= {path = "i3k_db_arder_pet"},
	i3k_db_npc_transfer                 = {path = "i3k_db_npc_transfer"},
	i3k_db_special_card					= {path = "i3k_db_special_card"},
	i3k_db_master_cfg                   = {path = "i3k_db_master_cfg"},
	i3k_db_master_store                 = {path = "i3k_db_master_store"},
	i3k_db_master_store_refresh         = {path = "i3k_db_master_store_refresh"},
	i3k_db_defend_cfg					= {path = "i3k_db_defend_cfg"},
	i3k_db_pray_activity 				= {path = "i3k_db_pray_activity"},
	i3k_db_pray_activity_rewards        = {path = "i3k_db_pray_activity_rewards"},
	i3k_db_NpcDungeon					= {path = "i3k_db_NpcDungeon"},
	i3k_db_activity_imgs				= {path = "i3k_db_activity_imgs"},
	i3k_db_defend_fb					= {path = "i3k_db_defend_fb"},
	i3k_db_dungeonSkill					= {path = "i3k_db_dungeonSkill"},
	i3k_db_calendar					    = {path = "i3k_db_calendar"},
	i3k_db_calendar_detail				= {path = "i3k_db_calendar_detail"},
	i3k_db_exptree_common               = {path = "i3k_db_exptree_common"},
	i3k_db_exptree_level				= {path = "i3k_db_exptree_level"},
	i3k_db_equip_refine				    = {path = "i3k_db_equip_refine"},
	i3k_db_faction_fightgroup			= {path = "i3k_db_faction_fightgroup"},
	i3k_db_faction_fight_cfg			= {path = "i3k_db_faction_fight_cfg"},
	i3k_db_faction_fight_openday        = {path = "i3k_db_faction_fight_cfg"},
	i3k_db_rank_list_other				= {path = "i3k_db_rank_list"},
	i3k_db_rank_list_fentang			= {path = "i3k_db_rank_list"},
	i3k_db_rank_list_fightteam			= {path = "i3k_db_rank_list"},
	i3k_db_rank_list_name_other			= {path = "i3k_db_rank_list_name"},
	i3k_db_rank_list_name_fentang		= {path = "i3k_db_rank_list_name"},
	i3k_db_factionFight_dungon			= {path = "i3k_db_factionFight_dungon"},
	i3k_db_qieCuo_dungon 				= {path = "i3k_db_qieCuo_dungon"},
	i3k_db_fiveEnd_activity				= {path = "i3k_db_fiveEnd_activity"},
	i3k_db_role_return					= {path = "i3k_db_role_return"},
	i3k_db_word_exchange_cfg			= {path = "i3k_db_word_exchange"},
	i3k_db_word_exchange_require		= {path = "i3k_db_word_exchange"},
	i3k_db_word_exchange_reward			= {path = "i3k_db_word_exchange"},
    i3k_db_spring		                = {path = "i3k_db_spring"},
    i3k_db_epic_task 					= {path = "i3k_db_epic_task"},
    i3k_db_epic_cfg						= {path = "i3k_db_epic_task"},
	i3k_db_bottle						= {path = "i3k_db_bottle"},
	i3k_db_bottle_msg					= {path = "i3k_db_bottle"},
	i3k_db_pet_race_store				= {path = "i3k_db_pet_race_store"},
	i3k_db_pet_race_store_refresh  		= {path = "i3k_db_pet_race_store_refresh"},
    i3k_db_debrisRecycle                = {path = "i3k_db_debrisRecycle"},
	i3k_db_debrisRecycle_times          = {path = "i3k_db_debrisRecycle_times"},
	i3k_db_emoji_cfg					= {path = "i3k_db_emoji"},
	i3k_db_emoji						= {path = "i3k_db_emoji"},
	i3k_db_qiling_cfg					= {path = "i3k_db_qiling"},
	i3k_db_qiling_type					= {path = "i3k_db_qiling"},
	i3k_db_qiling_nodes					= {path = "i3k_db_qiling"},
	i3k_db_qiling_trans					= {path = "i3k_db_qiling"},
	i3k_db_qiling_skill					= {path = "i3k_db_qiling"},
	i3k_db_star_soul					= {path = "i3k_db_martial_soul"},
	i3k_db_martial_soul_part 			= {path = "i3k_db_martial_soul"},
	i3k_db_martial_soul_level			= {path = "i3k_db_martial_soul"},
	i3k_db_martial_soul_rank 			= {path = "i3k_db_martial_soul"},
	i3k_db_martial_soul_display			= {path = "i3k_db_martial_soul"},
	i3k_db_martial_soul_cfg				= {path = "i3k_db_martial_soul"},
	i3k_db_woodenTripod                 = {path = "i3k_db_woodenTripod"},
	i3k_db_woodenTripod_cfg             = {path = "i3k_db_woodenTripod_cfg"},
	i3k_db_fight_line_buff				= {path = "i3k_db_fight_line_buff"},
	i3k_db_national_activity_cfg		= {path = "i3k_db_national_activity"},
	i3k_db_national_cheer_reward		= {path = "i3k_db_national_activity"},
	i3k_db_national_cheer_rank			= {path = "i3k_db_national_activity"},
	i3k_db_national_lucky_reward		= {path = "i3k_db_national_activity"},
	i3k_db_faction_garrison				= {path = "i3k_db_faction_garrison"},
	i3k_db_faction_boss					= {path = "i3k_db_faction_garrison"},
	i3k_db_faction_boss_donation		= {path = "i3k_db_faction_garrison"},
	i3k_db_faction_dragon				= {path = "i3k_db_faction_garrison"},
	i3k_db_faction_garrsion_minimap		= {path = "i3k_db_faction_garrison"},
	i3k_db_faction_spirit				= {path = "i3k_db_faction_garrison"},
	i3k_db_findMooncake				    = {path = "i3k_db_findMooncake"},
	i3k_db_dice_entrance_cfg			= {path = "i3k_db_findMooncake"},
	i3k_db_dice_cfg						= {path = "i3k_db_dice"},
	i3k_db_dice							= {path = "i3k_db_dice"},
	i3k_db_dice_get						= {path = "i3k_db_dice"},
	i3k_db_dice_monster					= {path = "i3k_db_dice"},
	i3k_db_dice_exchange				= {path = "i3k_db_dice"},
	i3k_db_dice_flower					= {path = "i3k_db_dice"},
	i3k_db_dice_event					= {path = "i3k_db_dice"},
	i3k_db_national_exchange			= {path = "i3k_db_national_activity"},
	i3k_db_longyun_reward				= {path = "i3k_db_faction_garrison"},
	i3k_db_faction_garrsion_boss		= {path = "i3k_db_faction_garrison"},
	i3k_db_activity_icons				= {path = "i3k_db_activity_icons"},
	i3k_db_call_back_common				= {path = "i3k_db_call_back"},
	i3k_db_call_back_login				= {path = "i3k_db_call_back"},
	i3k_db_call_back_active				= {path = "i3k_db_call_back"},
	i3k_db_call_back_pay				= {path = "i3k_db_call_back"},
	i3k_db_call_back_count				= {path = "i3k_db_call_back"},
	i3k_db_call_back_mission_count		= {path = "i3k_db_call_back"},
	i3k_db_mercenariea_waken_cfg		= {path = "i3k_db_mercenariea_waken"},
	i3k_db_mercenariea_waken_property	= {path = "i3k_db_mercenariea_waken"},
	i3k_db_mercenariea_waken_task		= {path = "i3k_db_mercenariea_waken"},
	i3k_db_pet_awken					= {path = "i3k_db_pet_awken"},
	i3k_db_pet_waken_item				= {path = "i3k_db_waken_task_item"},
	i3k_db_bid_cfg						= {path = "i3k_db_bid"},
	i3k_db_bid_items					= {path = "i3k_db_bid"},
	i3k_db_bid_add_items				= {path = "i3k_db_bid"},
	i3k_db_chatBubble					= {path = "i3k_db_chatBubble"},
	i3k_db_robber_monster_base			= {path = "i3k_db_robber_monster"},
	i3k_db_robber_monster_cfg			= {path = "i3k_db_robber_monster"},
	i3k_db_robber_monster_type			= {path = "i3k_db_robber_monster"},
	i3k_db_robber_monster_task			= {path = "i3k_db_robber_monster"},
	i3k_db_robber_monster_pos			= {path = "i3k_db_robber_monster"},
	i3k_db_robber_monster_types			= {path = "i3k_db_robber_monster"},
	i3k_db_robber_monster_behaviors		= {path = "i3k_db_robber_monster"},
	i3k_db_faction_salary_cfg			= {path = "i3k_db_faction_salary"},
	i3k_db_meridians					= {path = "i3k_db_meridians"},
	i3k_db_fightTeam_base				= {path = "i3k_db_fight_team"},
	i3k_db_fightTeam_explain			= {path = "i3k_db_fight_team"},
	i3k_db_fightTeam_tournament_reward	= {path = "i3k_db_fight_team"},
	i3k_db_fightTeam_honor_reward		= {path = "i3k_db_fight_team"},
	i3k_db_fight_team_fb				= {path = "i3k_db_fight_team_fb"},
	i3k_db_question_daily_bank 			= {path = "i3k_db_question_bank"},
	i3k_db_activity_show				= {path = "i3k_db_activity_show"},
	i3k_db_escort_skin			        = {path = "i3k_db_escort_skin"},
	i3k_db_christmas_wish_cfg			= {path = "i3k_db_christams_wish"},
	i3k_db_christmas_wish_bgImg			= {path = "i3k_db_christams_wish"},
	i3k_db_npc_christmas_wish			= {path = "i3k_db_christams_wish"},
	i3k_db_weekTask						= {path = "i3k_db_weekTask"},
	i3k_db_equip_transform				= {path = "i3k_db_equip_transform"},
	i3k_db_equip_transform_cfg          = {path = "i3k_db_equip_transform"},
	i3k_db_upgrade_purcharse_cfg		= {path = "i3k_db_upgrade_purcharse"},
	i3k_db_steed_breakCfg				= {path = "i3k_db_steed_breakCfg"},
	i3k_db_ride_mapped_action			= {path = "i3k_db_ride_mapped_action"},
	i3k_db_steed_fight_base				= {path = "i3k_db_steed_fight"},
	i3k_db_steed_fight_up_prop			= {path = "i3k_db_steed_fight"},
	i3k_db_steed_fight_award_prop		= {path = "i3k_db_steed_fight"},
	i3k_db_steed_fight_spirit			= {path = "i3k_db_steed_fight"},
	i3k_db_steed_fight_spirit_rank		= {path = "i3k_db_steed_fight"},
	i3k_db_steed_fight_spirit_skill		= {path = "i3k_db_steed_fight"},
	i3k_db_steed_fight_spirit_buff_mapped = {path = "i3k_db_steed_fight"},
	i3k_db_show_love_item				= {path = "i3k_db_show_love_item"},
	i3k_db_show_love_item_pos			= {path = "i3k_db_show_love_item"},
	i3k_db_statueExp_cfg			= {path = "i3k_db_statueExp_cfg"},
	i3k_db_fight_team_champion		= {path = "i3k_db_statueExp_cfg"},
	i3k_db_adventure					= {path = "i3k_db_adventure"},
	i3k_db_dragon_hole_task				= {path = "i3k_db_dragon_hole_task"},
	i3k_db_dragon_hole_cfg				= {path = "i3k_db_dragon_hole_cfg"},
	i3k_db_newYear_red					= {path = "i3k_db_newYear_red"},
	i3k_db_lucky_pack_cfg				= {path = "i3k_db_lucky_pack"},
	i3k_db_lucky_pack_task				= {path = "i3k_db_lucky_pack"},
	i3k_db_lucky_pack_reward			= {path = "i3k_db_lucky_pack"},
	i3k_db_dengmi_common				= {path = "i3k_db_dengmi"},
	i3k_db_dengmi_content				= {path = "i3k_db_dengmi"},
	i3k_db_dengmi_role_award				= {path = "i3k_db_dengmi"},
	i3k_db_dengmi_world_award				= {path = "i3k_db_dengmi"},
	i3k_db_dragon_hole_award			= {path = "i3k_db_dragon_hole_cfg"},
	i3k_db_dragon_hole_sect_award		= {path = "i3k_db_dragon_hole_cfg"},
	i3k_db_limitTask					= {path = "i3k_db_limitTask"},
	i3k_db_bagua_cfg					= {path = "i3k_db_bagua"},
	i3k_db_bagua_part					= {path = "i3k_db_bagua"},
	i3k_db_bagua_prop_stone				= {path = "i3k_db_bagua"},
	i3k_db_bagua_stone					= {path = "i3k_db_bagua"},
	i3k_db_bagua_affix					= {path = "i3k_db_bagua"},
	i3k_db_bagua_suit_prop				= {path = "i3k_db_bagua"},
	i3k_db_bagua_streng					= {path = "i3k_db_bagua"},
	i3k_db_bagua_yilue_Attr				= {path = "i3k_db_bagua"},
	i3k_db_bagua_yilue_pointCfg			= {path = "i3k_db_bagua"},
	i3k_db_bagua_yilue_skill			= {path = "i3k_db_bagua"},
	i3k_db_puzzle						= {path = "i3k_db_puzzle"},
	i3k_db_diglett_position				= {path = "i3k_db_findMooncake"},
	i3k_db_crossRealmPVE_shareCfg       = {path = "i3k_db_crossRealmPVE_shareCfg"},
	i3k_db_peaceMapMonster              = {path = "i3k_db_crossRealmPVE"},
	i3k_db_battleMapMonster             = {path = "i3k_db_crossRealmPVE"},
	i3k_db_crossRealmPVE_cfg            = {path = "i3k_db_crossRealmPVE"},
	i3k_db_crossRealmPVE_fb             = {path = "i3k_db_crossRealmPVE_fb"},
	i3k_db_peaceMapSmallMonsterReward  	= {path = "i3k_db_crossRealmPVE"},
	i3k_db_peaceMapBossReward  			= {path = "i3k_db_crossRealmPVE"},
	i3k_db_battleMapbossReward       	= {path = "i3k_db_crossRealmPVE"},
	i3k_db_battleMapSuperBossReward  	= {path = "i3k_db_crossRealmPVE"},
	i3k_db_factionBusiness				= {path = "i3k_db_factionBusiness"},
	i3k_db_factionBusiness_task			= {path = "i3k_db_factionBusiness_task"},
	i3k_db_career_gift_bag				= {path = "i3k_db_gift_bag"},
	i3k_db_millions_answer_cfg			= {path = "i3k_db_millions_answer"},
	i3k_db_millions_answer_reward		= {path = "i3k_db_millions_answer"},
	i3k_db_millions_answer_question		= {path = "i3k_db_millions_answer"},
	i3k_db_Divinationcfg				= {path = "i3k_db_Divination"},
	i3k_db_DivinationTextID				= {path = "i3k_db_Divination"},
	i3k_db_DivinationLuckyID			= {path = "i3k_db_Divination"},
	i3k_db_five_trans					= {path = "i3k_db_five_trans"},
	i3k_db_destiny_roll					= {path = "i3k_db_five_trans"},
	i3k_db_five_trans_other				= {path = "i3k_db_five_trans"},
	i3k_db_single_challenge_cfg			= {path = "i3k_db_single_challenge"},
	i3k_db_single_challenge_group		= {path = "i3k_db_single_challenge"},
	i3k_db_single_challenge_buff		= {path = "i3k_db_single_challenge"},
	i3k_db_pigeon_post					= {path = "i3k_db_pigeon_post"},
	i3k_db_mood_diary_cfg				= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_decorate			= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_gift				= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_constellation_fate= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_hobby				= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_sex				= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_constellation_test= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_constellation_test_result	= {path = "i3k_db_mood_diary"},
	i3k_db_mood_diary_constellation		= {path = "i3k_db_mood_diary"},
	i3k_db_longyin_sprite				= {path = "i3k_db_longyin_sprite"},
	i3k_db_longyin_sprite_addPoint		= {path = "i3k_db_longyin_sprite"},
	i3k_db_longyin_sprite_born			= {path = "i3k_db_longyin_sprite"},
	i3k_db_longyin_sprite_reset			= {path = "i3k_db_longyin_sprite"},
	i3k_db_longyin_sprite_buy_point		= {path = "i3k_db_longyin_sprite"},
	i3k_db_rightHeart_target_info		= {path = "i3k_db_rightHeart"},
	i3k_db_home_land_base				= {path = "i3k_db_home_land"},
	i3k_db_home_land_lvl				= {path = "i3k_db_home_land"},
	i3k_db_home_land_corp				= {path = "i3k_db_home_land"},
	i3k_db_home_land_plant_lvl			= {path = "i3k_db_home_land"},
	i3k_db_home_land_fish_master		= {path = "i3k_db_home_land"},
	i3k_db_home_land_land_lvl			= {path = "i3k_db_home_land"},
	i3k_db_home_land_pool_lvl			= {path = "i3k_db_home_land"},
	i3k_db_home_land_fishArea			= {path = "i3k_db_home_land"},
	i3k_db_home_land_equip				= {path = "i3k_db_home_land"},
	i3k_db_home_land_equip_put_pos		= {path = "i3k_db_home_land"},
	i3k_db_home_land_house				= {path = "i3k_db_home_land"},
	i3k_db_home_land_minimap			= {path = "i3k_db_home_land"},
	i3k_db_faction_assist				= {path = "i3k_db_faction_assist"},
	i3k_db_power_reputation				= {path = "i3k_db_power_reputation"},
	i3k_db_power_reputation_npc			= {path = "i3k_db_power_reputation"},
	i3k_db_power_reputation_task		= {path = "i3k_db_power_reputation"},
	i3k_db_power_reputation_commit		= {path = "i3k_db_power_reputation"},
	i3k_db_power_reputation_level		= {path = "i3k_db_power_reputation"},
	i3k_db_activity_perfect				= {path = "i3k_db_activity_show"},
	i3k_db_activity_world				= {path = "i3k_db_activity_show"},
	i3k_db_chess_board_cfg				= {path = "i3k_db_chess_board"},
	i3k_db_chess_board_awards			= {path = "i3k_db_chess_board"},
	i3k_db_chess_board_other_awards		= {path = "i3k_db_chess_board"},
	i3k_db_chess_task_info				= {path = "i3k_db_chess_board"},
	i3k_db_chess_task					= {path = "i3k_db_chess_task"},
	i3k_db_world_cup_team				= {path = "i3k_db_world_cup"},
	i3k_db_world_cup_group_name			= {path = "i3k_db_world_cup"},
	i3k_db_world_cup_wager				= {path = "i3k_db_world_cup"},
	i3k_db_world_cup_other				= {path = "i3k_db_world_cup"},
	i3k_db_verse						= {path = "i3k_db_puzzle"},
	i3k_db_verse_content				= {path = "i3k_db_puzzle"},
	i3k_db_find_difference				= {path = "i3k_db_puzzle"},
	i3k_db_xinjue 						= {path = "i3k_db_xinjue"},
	i3k_db_xinjue_level					= {path = "i3k_db_xinjue"},
	i3k_db_xinjue_skills 				= {path = "i3k_db_xinjue"},
	i3k_db_xinjue_damage 				= {path = "i3k_db_xinjue"},
	i3k_db_anqi_base 					= {path = "i3k_db_anqi"},
	i3k_db_anqi_grade 					= {path = "i3k_db_anqi"},
	i3k_db_anqi_level 					= {path = "i3k_db_anqi"},
	i3k_db_anqi_skill 					= {path = "i3k_db_anqi"},
	i3k_db_anqi_common 					= {path = "i3k_db_anqi"},
	i3k_db_anqi_tips					= {path = "i3k_db_anqi"},
	i3k_db_anqi_skin 					= {path = "i3k_db_anqi"},
	i3k_db_anqi_gradeName 				= {path = "i3k_db_anqi"},
	i3k_db_world_map 					= {path = "i3k_db_world_map"},
	i3k_db_not_filed_map				= {path = "i3k_db_world_map"},
	i3k_db_donateInfo 					= {path = "i3k_db_family_donate"},
	i3k_db_basicdonateInfo 				= {path = "i3k_db_family_donate"},
	i3k_db_spirit_boss					= {path = "i3k_db_spirit_boss"},
	i3k_db_defenceWar_cfg				= {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_time				= {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_reward			= {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_city				= {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_architectureskills = {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_minimap_icons		= {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_trans				= {path = "i3k_db_defenceWar"},
	i3k_db_defenceWar_dungeon			= {path = "i3k_db_defenceWar_dungeon"},
	i3k_db_partner_base					= {path = "i3k_db_partner"},
	i3k_db_partner_details				= {path = "i3k_db_partner"},
	i3k_db_partner_welcome_desc			= {path = "i3k_db_partner"},
	i3k_db_out_cast						= {path = "i3k_db_out_cast"},
	i3k_db_out_cast_base				= {path = "i3k_db_out_cast"},
	i3k_db_out_cast_task				= {path = "i3k_db_out_cast_task"},

	i3k_db_home_land_production			= {path = "i3k_db_home_land"},
	i3k_db_equip_temper_base  			= {path = "i3k_db_equips_temper"},
	i3k_db_equip_temper_skill 			= {path = "i3k_db_equips_temper"},
	i3k_db_illegal_char					= {path = "i3k_db_illegal_char"},
	i3k_db_home_land_floor_furniture	= {path = "i3k_db_home_land"},
	i3k_db_home_land_wall_furniture		= {path = "i3k_db_home_land"},
	i3k_db_home_land_hang_furniture		= {path = "i3k_db_home_land"},
	i3k_db_home_land_carpet_furniture	= {path = "i3k_db_home_land"},
	i3k_db_shen_bing_others 			= {path = "i3k_db_shen_bing_talent_init"},
	i3k_db_shen_bing_awake				= {path = "i3k_db_shen_bing_awake"},
	i3k_db_shen_bing_bing_hun_skill		= {path = "i3k_db_shen_bing_bing_hun_skill"},
	i3k_db_shen_bing_shen_yao			= {path = "i3k_db_shen_bing_bing_hun_skill"},
	i3k_db_timing_activity              = {path = "i3k_db_timingactivity"},
	i3k_db_timing_activity_exchange     = {path = "i3k_db_timingactivity"},
	i3k_db_pass_exam_gift_cfg			= {path = "i3k_db_pass_exam_gift"},
	i3k_db_pass_exam_gift_reward		= {path = "i3k_db_pass_exam_gift"},
	i3k_db_illusory_dungeon_cfg			= {path = "i3k_db_illusory_dungeon_cfg"},
	i3k_db_illusory_dungeon 			= {path = "i3k_db_illusory_dungeon"},
	i3k_db_home_land_house_skin			= {path = "i3k_db_home_land"},
	i3k_db_marry_achievement_common		= {path = "i3k_db_marry_achievement"},
	i3k_db_marry_achievement			= {path = "i3k_db_marry_achievement"},
	i3k_db_marry_achieveRewards			= {path = "i3k_db_marry_achievement"},
	i3k_db_medicine_cfg					= {path = "i3k_db_medicine_cfg",},
	i3k_db_pet_equips					= {path = "i3k_db_pet_equips",},
	i3k_db_PetDungeonBase				= {path = "i3k_db_pet_dungeon",},
	i3k_db_PetDungeonMaps				= {path = "i3k_db_pet_dungeon",},
	i3k_db_PetDungeonGathers			= {path = "i3k_db_pet_dungeon",},
	i3k_db_PetDungeonEvents				= {path = "i3k_db_pet_dungeon",},
	i3k_db_PetDungeonTasks				= {path = "i3k_db_pet_dungeon",},
	i3k_db_pet_equips_cfg				= {path = "i3k_db_pet_equips_cfg",},
	i3k_db_pet_equips_group				= {path = "i3k_db_pet_equips_cfg",},
	i3k_db_pet_equips_part				= {path = "i3k_db_pet_equips_cfg",},
	i3k_db_pet_equips_up_lvl			= {path = "i3k_db_pet_equips_up_lvl",},
	i3k_db_pet_skill					= {path = "i3k_db_pet_skill",},
	i3k_db_pet_skill_up_lvl				= {path = "i3k_db_pet_skill_up_lvl",},
	i3k_db_pet_dungeon_Map				= {path = "i3k_db_pet_dungeon_Map",},
	i3k_db_desert_generals				= {path = "i3k_db_desert_Battle",},
	i3k_db_desert_battle_base			= {path = "i3k_db_desert_Battle",},
	i3k_db_desert_resInfo				= {path = "i3k_db_desert_Battle",},
	i3k_db_desert_battle_map			= {path = "i3k_db_desert_Battle",},
	i3k_db_desert_battle_show_award		= {path = "i3k_db_desert_Battle",},
	i3k_db_desert_battle_poisonCircle	= {path = "i3k_db_desert_Battle",},
	i3k_db_desert_battle_items			= {path = "i3k_db_desert_battle_items",},
	i3k_db_desert_battle_equips			= {path = "i3k_db_desert_battle_equips",},
	i3k_db_desert_battle_equip_part		= {path = "i3k_db_desert_battle_equip_cfg",},
	i3k_db_desert_battle_equip_rank		= {path = "i3k_db_desert_battle_equip_cfg",},
	i3k_db_desert_battle_equip_roleType	= {path = "i3k_db_desert_battle_equip_cfg",},
	i3k_db_desert_battle_xinfa_cfg		= {path = "i3k_db_desert_battle_xinfa_cfg",},
	i3k_db_desert_rank 					= {path = "i3k_db_desert_Battle",},
	i3k_db_sworn_system					= {path = "i3k_db_sworn_system",},
	i3k_db_sworn_title_orderSeats		= {path = "i3k_db_sworn_system",},
	i3k_db_sworn_value					= {path = "i3k_db_sworn_system",},
	i3k_db_sworn_actRewards				= {path = "i3k_db_sworn_system",},
	i3k_db_week_limit_reward_cfg		= {path = "i3k_db_week_limit_reward",},
	i3k_db_week_limit_reward_drop		= {path = "i3k_db_week_limit_reward",},
	i3k_db_desert_battle_out_cfg		= {path = "i3k_db_desert_Battle",},
	i3k_db_wujue 						= {path = "i3k_db_wujue"},
	i3k_db_wujue_level					= {path = "i3k_db_wujue"},
	i3k_db_wujue_break					= {path = "i3k_db_wujue"},
	i3k_db_wujue_skill					= {path = "i3k_db_wujue"},
	i3k_db_wujue_soul					= {path = "i3k_db_wujue"},
	i3k_db_metamorphosis				= {path = "i3k_db_metamorphosis"},
	i3k_db_maze_battle					= {path = "i3k_db_maze_battle"},
	i3k_db_maze_transfer_point			= {path = "i3k_db_maze_battle"},
	i3k_db_maze_resourcepoint			= {path = "i3k_db_maze_battle"},
	i3k_db_maze_Area					= {path = "i3k_db_maze_battle"},
	i3k_db_maze_Map						= {path = "i3k_db_maze_Map"},
	i3k_db_maze_difficulty				= {path = "i3k_db_maze_battle"},
	i3k_db_team_buff 					= {path = "i3k_db_team_buff"},
	i3k_db_practice_door_common			= {path = "i3k_db_practice_door"},
	i3k_db_practice_door_award			= {path = "i3k_db_practice_door"},
	i3k_db_dungeon_practice_door 		= {path = "i3k_db_dungeon_practice_door"},
	i3k_db_festival_cfg					= {path = "i3k_db_festival_task"},
	i3k_db_festival_task				= {path = "i3k_db_festival_task"},
	i3k_db_practice_door_addition_threshold = {path = "i3k_db_practice_door"},
	i3k_db_five_contend_hegemony		= {path = "i3k_db_five_contend_hegemony"},
	i3k_db_scene_mine_cfg				= {path = "i3k_db_missionmode_cfg"},
	i3k_db_ling_qian 					= {path = "i3k_db_ling_qian"},
	i3k_db_ling_qian_award				= {path = "i3k_db_ling_qian"},
	i3k_db_steed_equip_cfg				= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip					= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip_suit				= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip_stove			= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip_refine			= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip_step				= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip_quality			= {path = "i3k_db_steed_equip"},
	i3k_db_steed_equip_part				= {path = "i3k_db_steed_equip"},
	i3k_db_bagua_sacrifice_compound		= {path = "i3k_db_bagua"},
	i3k_db_bagua_sacrifice_split		= {path = "i3k_db_bagua"},
	i3k_db_shake_tree 					= {path = "i3k_db_shake_tree"},
	i3k_db_home_pet 					= {path = "i3k_db_home_pet"},
	i3k_db_home_pet_pos					= {path = "i3k_db_home_pet"},
	i3k_db_home_pet_play				= {path = "i3k_db_home_pet"},
	i3k_db_answer_open_time				= {path = "i3k_db_five_contend_hegemony"},
	i3k_db_at_any_moment				= {path = "i3k_db_at_any_moment"},
	i3k_db_pet_guard					= {path = "i3k_db_pet_guard"},
	i3k_db_pet_guard_base_cfg 			= {path = "i3k_db_pet_guard"},
	i3k_db_pet_guard_level 				= {path = "i3k_db_pet_guard"},
	i3k_db_pet_guard_potential 			= {path = "i3k_db_pet_guard"},
	i3k_db_pet_guard_precondition		= {path = "i3k_db_pet_guard"},
	i3k_db_pet_guard_skills				= {path = "i3k_db_pet_guard"},
	i3k_db_princess_marry				= {path = "i3k_db_princess_marry"},
	i3k_db_princess_Config				= {path = "i3k_db_princess_marry"},
	i3k_db_princess_eventStage			= {path = "i3k_db_princess_marry"},
	i3k_db_princess_win_reward			= {path = "i3k_db_princess_marry"},
	i3k_db_princess_fail_reward			= {path = "i3k_db_princess_marry"},
	i3k_db_chess_generals				= {path = "i3k_db_tournament"},
	i3k_db_dance 						= {path = "i3k_db_dance"},
	i3k_db_dance_stage 					= {path = "i3k_db_dance"},
	i3k_db_dance_map 					= {path = "i3k_db_dance"},
	i3k_db_role_flying					= {path = "i3k_db_role_flying"},
	i3k_db_flying_position				= {path = "i3k_db_role_flying"},
	i3k_db_ring_mission					= {path = "i3k_db_role_flying"},
	i3k_db_feisheng_misc				= {path = "i3k_db_role_flying"},
	i3k_db_feet_effect					= {path = "i3k_db_feet_effect"},
	i3k_db_dance_npc_action				= {path = "i3k_db_dance"},
	i3k_db_jubilee_base					= {path = "i3k_db_jubilee"},-- 周年活动
	i3k_db_jubilee_npcs					= {path = "i3k_db_jubilee"},-- 周年活动npc移动
	i3k_db_jubilee_tasks				= {path = "i3k_db_jubilee"},-- 周年庆阶段2任务
	i3k_db_practice_week_award 			= {path = "i3k_db_practice_week_award"},
	i3k_db_escort_luck_draw				= {path = "i3k_db_escort_luck_draw"}, --运镖抽奖
	i3k_db_gem_exchange 				= {path = "i3k_db_gem_exchange"}, --宝石转化
	i3k_db_bagua_affix_priview			= {path = "i3k_db_bagua"},
	i3k_db_MMRewards					= {path = "i3k_db_mm_rewards_preview"},	--神机藏海奖励预览
	i3k_db_want_improve_classPage 		= {path = "i3k_db_want_improve"},--我要提升
	i3k_db_want_improve_strong 			= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_strongChild 	= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_strongParam 	= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_recommendPower 	= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_recommendFuncID = {path = "i3k_db_want_improve"},
	i3k_db_want_improve_wantResources 	= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_outChannel 		= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_winJump 		= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_judgeCfg 		= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_progressBarCfg 	= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_btnNameEnum 	= {path = "i3k_db_want_improve"},
	i3k_db_want_improve_otherRules 		= {path = "i3k_db_want_improve"},
	i3k_db_magic_machine 				= {path = "i3k_db_magic_machine"},
	i3k_db_magic_machine_area 			= {path = "i3k_db_magic_machine"},
	i3k_db_move_road_points 			= {path = "i3k_db_magic_machine"},
	i3k_db_magic_machine_miniMap 		= {path = "i3k_db_magic_machine"},
	i3k_db_magic_machine_miniShowCfg 	= {path = "i3k_db_magic_machine"},
	i3k_db_video_data					= {path = "i3k_db_video_data"},
	i3k_db_tournament_week_reward       = {path = "i3k_db_tournament"},
	i3k_db_cardPacket					= {path = "i3k_db_cardPacket"},
	i3k_db_cardPacket_card				= {path = "i3k_db_cardPacket"},
	i3k_db_cardPacket_cardBack			= {path = "i3k_db_cardPacket"},
	i3k_db_homeland_guard_cfg			= {path = "i3k_db_homeland_guard"},
	i3k_db_homeland_guard_base 			= {path = "i3k_db_homeland_guard"},
	i3k_db_homeland_guard_batch 		= {path = "i3k_db_homeland_guard"},
	i3k_db_homeland_guard_reward		= {path = "i3k_db_homeland_guard"},
	i3k_db_steed_sort_practice			= {path = "i3k_db_steed_practice"},
	i3k_db_five_elements				= {path = "i3k_db_five_elements"},
	i3k_db_faction_photo		 		= {path = "i3k_db_faction_photo"},
	i3k_db_faction_photo_position 		= {path = "i3k_db_faction_photo"},
	i3k_db_knightly_detective_common	= {path = "i3k_db_knightly_detective"},
	i3k_db_knightly_detective_members	= {path = "i3k_db_knightly_detective"},
	i3k_db_knightly_detective_ringleader = {path = "i3k_db_knightly_detective"},
	i3k_db_knightly_detective_tasks		= {path = "i3k_db_knightly_detective"},
	i3K_db_timing_activity_pray_txt		= {path = "i3K_db_timing_activity_pray_txt"},
	i3k_db_swordsman_circle_cfg			= {path = "i3k_db_swordsman_circle"},
	i3k_db_swordsman_circle_npc			= {path = "i3k_db_swordsman_circle"},
	i3k_db_swordsman_circle_tasks		= {path = "i3k_db_swordsman_circle"},
	i3k_db_swordsman_circle_reward		= {path = "i3k_db_swordsman_circle"},
	i3k_db_swordsman_circle_daily_reward= {path = "i3k_db_swordsman_circle"},
	i3k_db_npc_deliver_letters			= {path = "i3k_db_missionmode_cfg"},
	i3k_db_choose_items_reward			= {path = "i3k_db_missionmode_cfg"},
	i3k_db_war_zone_map_type			= {path = "i3k_db_war_zone_map"},
	i3k_db_war_zone_map_card			= {path = "i3k_db_war_zone_map"},
	i3k_db_war_zone_map_fb				= {path = "i3k_db_war_zone_map"},
	i3k_db_war_zone_map_cfg				= {path = "i3k_db_war_zone_map"},
	i3k_db_war_zone_map_task			= {path = "i3k_db_war_zone_map"},
	i3k_db_war_zone_map_efect			= {path = "i3k_db_war_zone_map"},
	i3k_db_war_zone_map_monster			= {path = "i3k_db_war_zone_map"},
	i3k_db_array_stone_common			= {path = "i3k_db_array_stone"},
	i3k_db_array_stone_unlock_hole		= {path = "i3k_db_array_stone"},
	i3k_db_array_stone_level			= {path = "i3k_db_array_stone"},
	i3k_db_array_stone_cfg				= {path = "i3k_db_array_stone"},
	i3k_db_array_stone_suit				= {path = "i3k_db_array_stone"},
	i3k_db_array_stone_suit_group		= {path = "i3k_db_array_stone"},
	i3k_db_fightTeam_group_name			= {path = "i3k_db_fight_team"},
	i3k_db_statueExp_power_cfg			= {path = "i3k_db_statueExp_cfg"},
	i3k_db_statueExp_fight_cfg			= {path = "i3k_db_statueExp_cfg"},
	i3k_db_array_stone_suit_need_list	= {path = "i3k_db_array_stone"},
	i3k_db_longevity_pavilion  			= {path = "i3k_db_longevity_pavilion"},
	i3k_db_longevity_pavilion_dugeon  	= {path = "i3k_db_longevity_pavilion"},
	i3k_db_longevity_pavilion_task  	= {path = "i3k_db_longevity_pavilion"},
	i3k_db_longevity_pavilion_win_reward= {path = "i3k_db_longevity_pavilion"},
	i3k_db_longevity_pavilion_fail_reward= {path = "i3k_db_longevity_pavilion"},
	i3k_db_longevity_pavilion_special_reward = {path = "i3k_db_longevity_pavilion"},
	i3k_db_longevity_pavilion_dugeon_cfg = {path = "i3k_db_longevity_pavilion"},
	i3k_db_catch_spirit_base 			= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_dungeon 		= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_skills 			= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_position 		= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_monster 		= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_monster_list 	= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_fragment	 	= {path = "i3k_db_catch_spirit"},
	i3k_db_catch_spirit_exchange 		= {path = "i3k_db_catch_spirit"},
	i3k_db_spy_story_base				= {path = "i3k_db_spy_story"},
	i3k_db_spy_story_generals			= {path = "i3k_db_spy_story"},
	i3k_db_spy_story_reward				= {path = "i3k_db_spy_story"},
	i3k_db_spy_story_map				= {path = "i3k_db_spy_story"},
	i3k_db_spy_story_task				= {path = "i3k_db_spy_story"},
	i3k_db_spy_story_find_point			= {path = "i3k_db_spy_story"},
	i3k_db_wzClassLand					= {path = "i3k_db_wzClassLand"},
	i3k_db_wzClassLand_land				= {path = "i3k_db_wzClassLand"},
	i3k_db_wzClassLand_prop				= {path = "i3k_db_wzClassLand"},
	i3k_db_wzClassLand_task				= {path = "i3k_db_wzClassLand"},
	i3k_db_biography_career_common		= {path = "i3k_db_wzClassLand"},
	i3k_db_biography_animate_common		= {path = "i3k_db_biography_animate"},
	i3k_db_biography_animate_cfg		= {path = "i3k_db_biography_animate"},
	i3k_db_monster_special_actions		= {path = "i3k_db_generals"},
	i3k_db_first_clear_reward			= {path = "i3k_db_first_clear_reward"},
	i3k_db_spring_roll					= {path = "i3k_db_spring_roll"},
	i3k_db_new_festival_npc				= {path = "i3k_db_new_festival"},
	i3k_db_new_festival_task			= {path = "i3k_db_new_festival"},
	i3k_db_new_festival_info			= {path = "i3k_db_new_festival_commit"},
	i3k_db_new_festival_commit_Items	= {path = "i3k_db_new_festival_commit"},
	i3k_db_new_festival_commit_person	= {path = "i3k_db_new_festival_commit"},
	i3k_db_new_festival_commit_server	= {path = "i3k_db_new_festival_commit"},
	i3k_db_commecoin_cfg				= {path = "i3k_db_commemorate_coin"},
	i3k_db_commecoin_addValueNode		= {path = "i3k_db_commemorate_coin"},
	i3k_db_commecoin_changewoods		= {path = "i3k_db_commemorate_coin"},
	i3k_db_commecoin_musttochange		= {path = "i3k_db_commemorate_coin"},
}


----------------------------------------------------------------
function i3k_db_cleanup_dynamicdb()
    local cleanMap = {"i3k_db_buff", "i3k_db_equips", "i3k_db_skills"}
    local result = {}
local dbpath = "script/gamedb/"
    for k, v in ipairs(cleanMap) do
        local path = i3k_db_map[v]
        if path ~= nil and not path.binary then
            collectgarbage("collect")
            local r = {before = 0, after = 0}
            r.before = collectgarbage("count")
            --忽略i3k_db_leadtriggerUI
            i3k_game_unload_script(v, "script/gamedb/" .. path.path)
            collectgarbage("collect")
            r.after = collectgarbage("count")
            result[v] = r
        end
    end
    return result
end

function i3k_db_delay_get_db(name, db)
	if type(db) == "table" then
		local mt = { __index  = function(table, key)
			local _name = name .. '.' .. key;

			local _db = { };--Extend.get_table(_name);
			if _db then
				rawset(table, key, _db);

				i3k_db_delay_get_db(_name, _db);

				return _db;
			end

			return nil;
		end };
		setmetatable(db, mt);

		return true;
	end

	return false;
end

function i3k_db_create()
	-- preload binary db file
	for k, v in pairs(i3k_db_map) do
		if v.binary then
			if v.path ==  "i3k_db_leadtriggerUI" or v.path ==  "i3k_db_task_leadUI" then
				g_i3k_game_handler:LoadGameDB(k, "script/logic/" .. v.path .. ".db");
			else
				g_i3k_game_handler:LoadGameDB(k, "script/gamedb/" .. v.path .. ".db");
			end
		end
	end

	local mt = { __index = function(_, key)
		local script = i3k_db_map[key];
		if script then
			if script.binary then
				local found, table, db = Extend.get_db(key);
				if found then
					rawset(_G, key, db);

					if not table then
						i3k_db_delay_get_db(key, db);
					end

					return db;
				end
			else
				if script.path == "i3k_db_leadtriggerUI" or script.path == "i3k_db_task_leadUI" then
					require("script/logic/" .. script.path);
				else
					require("script/gamedb/" .. script.path);
				end
			end
		end

		return rawget(_G, key);
	end };
	setmetatable(_G, mt);

	--[[
	for k, v in pairs(i3k_db_map) do
		require("gamedb/" .. v.path);
	end
	]]

	i3k_db_common_item_tbl =
	{
		[g_COMMON_ITEM_TYPE_EQUIP] = i3k_db_equips,
		[g_COMMON_ITEM_TYPE_BASE] = i3k_db_base_item,
		[g_COMMON_ITEM_TYPE_ITEM] = i3k_db_new_item,
		[g_COMMON_ITEM_TYPE_GEM] = i3k_db_diamond,
		[g_COMMON_ITEM_TYPE_BOOK] = i3k_db_xinfa_book,
		[g_COMMON_ITEM_TYPE_PET_EQUIP] = i3k_db_pet_equips,
		[g_COMMON_ITEM_TYPE_DESERT_EQUIP] = i3k_db_desert_battle_equips,
		[g_COMMON_ITEM_TYPE_DESERT_ITEM] = i3k_db_desert_battle_items,
		[g_COMMON_ITEM_TYPE_HORSE_EQUIP] = i3k_db_steed_equip,
	};
	
	i3k_db_all_furniture_info =
	{
		[g_HOUSE_FLOOR_FURNITURE] = i3k_db_home_land_floor_furniture,
		[g_HOUSE_WALL_FURNITURE] = i3k_db_home_land_wall_furniture,
		[g_HOUSE_HANG_FURNITURE] = i3k_db_home_land_hang_furniture,
		[g_HOUSE_CARPET_FURNITURE] = i3k_db_home_land_carpet_furniture,
	}

	i3k_db_check()
end

-- 在打开游戏客户端增加一个检查，如果有特殊的db需要引用的关系出错，那么直接报错
function i3k_db_check()
	local size1 = #i3k_db_auction_select_equip[1]
	local generals = #i3k_db_generals
	if size1 ~= generals then
		error("db check failed, please check datatools/pylib/e_auction_select_equip.py\n\t\t\t\t\t#generals="..generals .." #i3k_db_auction_select_equip[1]=".. size1)
	end

	local size2 = #i3k_db_auction_select_xinfa[18]
	if size2 ~= generals then
		error("db check failed, please check datatools/pylib/e_auction_select_xinfa.py\n\t\t\t\t\t#generals="..generals .." #i3k_db_auction_select_xinfa[18]=".. size2)
	end

end

function i3k_db_reload()
	for k, v in pairs(i3k_db_map) do
		if v.path ==  "i3k_db_leadtriggerUI" or v.path == "i3k_db_task_leadUI" then
			i3k_game_unload_script(k, "logic/" .. v.path);
		else
			i3k_game_unload_script(k, "gamedb/" .. v.path);
		end
	end
end

-- return { { pid, value }, ...},attribute:附加属性值，qLv:强化等级，sLv升级 ,  ...  smething锤炼
function i3k_db_get_equip_props(eid, attribute, qLv, sLv, refine, smelting)
	local props = { };
	-- 基础
	-- 附加
	-- 升星
	-- ...

	props.base = { }
	props.attribute = { }
	props.refine = {}
	props.smeltingProps = {}

	local equip_t = i3k_db_equips[math.abs(tonumber(eid))]

	local ext_properties = equip_t.equip_t

	local base_attribute = equip_t.properties
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(equip_t.partID);

	for k,v in pairs(base_attribute) do
		if tonumber(v.type) ~= 0 then
			local temp = {}
			temp.pid = v.type
			temp.value = v.value
			temp.value_break = 0
			if i3k_db_streng_equip[strengGroup][qLv].props[v.type] then
				temp.value = temp.value +  i3k_db_streng_equip[strengGroup][math.min(80,qLv)].props[v.type] or 0
				temp.value_break = qLv > 80 and  i3k_db_streng_equip[strengGroup][qLv].props[v.type] - i3k_db_streng_equip[strengGroup][80].props[v.type] or 0
			end
			if v.rankFactor and v.rankFactor == 1 then
				local per = 0;
				local addCount = 0;
				if v.type and v.type ~= 0 then
					per = i3k_db_up_star_percent[v.type].upPercent[sLv + 1] / 10000
					addCount = i3k_db_up_star_percent[v.type].upValue[sLv + 1]
				end
				temp.value = temp.value*(1 + per) + addCount
				temp.value_break = temp.value_break*(1 + per)
			end
			table.insert(props.base,temp)
		end
	end
	if attribute then
		for k,v in pairs(attribute) do
			local exprop = equip_t.ext_properties[k];
			if exprop then
				if exprop.type == 1 then
					local id = exprop.args
					local temp = {}
					temp.pid = id
					temp.value = v
					table.insert(props.attribute,temp)
				end
			end
		end
	end

	if refine then
		for k, v in pairs(refine) do
			local temp = {}
			temp.pid = v.id
			temp.value = v.value
			table.insert(props.refine, temp)
		end
	end

	if smelting then
		for k, v in ipairs(smelting) do
			table.insert(props.smeltingProps, {pid = v.id, value = v.value})
		end
	end
	return props;
end

function i3k_db_get_talent_props(tid, tlvl)
	local props = { };
	local datas = i3k_db_xinfa_data[tid];
	if datas then
		for k = 0, tlvl do
			local data = datas[k];
			if data then
				if not props[data.attribute1] then
					props[data.attribute1] = 0;
				end
				props[data.attribute1] = props[data.attribute1] + data.value1;

				if not props[data.attribute2] then
					props[data.attribute2] = 0;
				end
				props[data.attribute2] = props[data.attribute2] + data.value2;
			end
		end
	end

	return props;
end

function i3k_db_get_talent_effector(tid, tlvl)
	local datas = i3k_db_xinfa_data[tid];
	if datas then
		local data = datas[tlvl];
		if data then
			local talents = { };
			for k, v in ipairs(data.effectID) do
				table.insert(talents, i3k_db_skill_talent[v]);
			end

			return talents;
		end
	end

	return nil;
end

function i3k_db_get_general(g_class)
	return i3k_db_generals[g_class];
end

function i3k_db_get_general_fashion(g_class, g_gender)
	local gcfg = i3k_db_get_general(g_class);
	if gcfg then
		local fid = gcfg.fashion[g_gender];
		if fid then
			return i3k_db_general_fashion[fid];
		end
	end

	return nil;
end

function i3k_db_get_general_fashion_hair_res(fashion)
	local res = { };

	if fashion then
		for k, v in ipairs(fashion.hairSkin) do
			if v > 0 then
				local rcfg = i3k_db_fashion_res[v];
				if rcfg then
					table.insert(res, rcfg);
				end
			end
		end
	end

	return res;
end

function i3k_db_get_general_fashion_face_res(fashion)
	local res = { };

	if fashion then
		for k, v in ipairs(fashion.faceSkin) do
			if v > 0 then
				local rcfg = i3k_db_fashion_res[v];
				if rcfg then
					table.insert(res, rcfg);
				end
			end
		end
	end

	return res;
end

function i3k_db_get_general_fashion_body_res(fashion,formType)
	local res = { };
	formType = formType or eBaseFrom
	if fashion then
		local t = {}
		if formType == eBaseFrom then
			t = fashion.bodySkin
		elseif formType == eFullFrom then
			t = fashion.zhengBodySkin
		elseif formType == eFashFrom  then
			t = fashion.fastionBodySkin
		elseif formType == eXieForm then
			t = fashion.xieBodySkin
		end

		for k, v in ipairs(t) do
			if v > 0 then
				table.insert(res, v);
			end
		end
	end

	return res;
end

function i3k_db_get_general_faction_head_res(fashion,formType)
	local res = { };
	formType = formType or eBaseFrom
	if fashion then
		local t = {}
		if formType == eFullFrom then
			t = fashion.zhengHeadSkin
		elseif formType == eFashFrom  then
			t = fashion.fastionHeadSkin
		elseif formType == eXieForm then
			t = fashion.xieHeadSkin
		end

		for k, v in ipairs(t) do
			if v > 0 then
				table.insert(res, v);
			end
		end
	end

	return res[1];
end

function i3k_db_get_general_fashion_weapon_res(fashion,formType)
	local res = { };
	formType = formType or eBaseFrom
	if fashion then
		local t = {}
		if formType == eBaseFrom then
			t = fashion.weaponSkin
		elseif formType == eFullFrom then
			t = fashion.zhengweaponSkin
		elseif formType == eFashFrom  then
			t = fashion.fastionweaponSkin
		elseif formType == eXieForm then
			t = fashion.xieWeaponSkin
		end
		for k, v in ipairs(t) do
			if v > 0 then
				table.insert(res, v);
			end
		end
	end

	return res;
end

function i3k_db_get_random_name(gender)
	local sid = i3k_engine_get_rnd_u(1, #i3k_db_role_surname);
	local sname = i3k_db_role_surname[sid];

	local gname = nil;
	if gender == 1 then
		local gid = i3k_engine_get_rnd_u(1, #i3k_db_role_given_name_male);
		gname = i3k_db_role_given_name_male[gid];
	else
		local gid = i3k_engine_get_rnd_u(1, #i3k_db_role_given_name_female);
		gname = i3k_db_role_given_name_female[gid];
	end

	if sname and gname then
		return true, sname .. gname;
	end

	return false, "";
end

eHeadShapeCircie	= 1;
eHeadShapeQuadrate	= 2;
-- shape == 1: circle, == 2: quadrate
function i3k_db_get_head_icon(gender, face, hair, shape)
	for k, v in pairs(i3k_db_base_head) do
		if v.gender == gender and v.face == face and v.hair == hair then
			local hcfg = i3k_db_head[v.iconID];
			if hcfg then
				if shape == eHeadShapeCircie then
					return hcfg.iconC;
				elseif shape == eHeadShapeQuadrate then
					return hcfg.iconR;
				end
			end

			return -1;
		end
	end

	return -1;
end

function i3k_db_get_head_icon_ex(id, shape)
	local hcfg = i3k_db_head[id];
	if hcfg then
		if shape == eHeadShapeCircie then
			return hcfg.iconC;
		elseif shape == eHeadShapeQuadrate then
			return hcfg.iconR;
		end
	end

	return -1;
end


--任务类型对应的文本配置表中的描述
local task_desc = {
	[1] = 16,
	[2] = 17,
	[3] = 18,
	[4] = 19,
	[5] = 20,
	[6] = 21,
	[7] = 22,
	[8] = 23,
	[9] = 24,
	[10] = 25,
	[11] = 161,
	[12] = 21,
	[13] = 337,
	[14] = 337,
	[15] = 336,
	[16] = 336,
	[17] = 23,
}

--获取通用配置
function i3k_db_get_common_cfg()
	return i3k_db_common
end

--获取动用是否显示社交配置
function i3k_db_get_is_open_dazuocfg(mapType)
	local mapTypeList = i3k_db_common.dazuocfg.mapmodes
	for	_, v in ipairs(mapTypeList) do
		if v == mapType then
			return true
		end
	end
	return false
end

--获取基础物品的配置
function i3k_db_get_base_item_cfg(id)
	return i3k_db_base_item[id < 0 and -id or id]
end


--获取道具物品的配置
function i3k_db_get_other_item_cfg(id)
	return i3k_db_new_item[id < 0 and -id or id]
end

--获取宝石物品的配置
function i3k_db_get_gem_item_cfg(id)
	return i3k_db_diamond[id < 0 and -id or id]
end

--获取心法书物品的配置
function i3k_db_get_book_item_cfg(id)
	return i3k_db_xinfa_book[id < 0 and -id or id]
end

--获取装备物品的配置
function i3k_db_get_equip_item_cfg(id)
	return i3k_db_equips[id < 0 and -id or id]
end

-- 获取宠物装备物品的配置
function i3k_db_get_pet_equip_item_cfg(id)
	return i3k_db_pet_equips[id < 0 and -id or id]
end

-- 获取荒漠装备物品的配置
function i3k_db_get_desert_equip_item_cfg(id)
	return i3k_db_desert_battle_equips[id < 0 and -id or id]
end
-- 获取荒漠道具物品的配置
function i3k_db_get_desert_item_cfg(id)
	return i3k_db_desert_battle_items[id < 0 and -id or id]
end
-- 获取骑战装备物品的配置
function i3k_db_get_steed_equip_item_cfg(id)
	return i3k_db_steed_equip[id < 0 and -id or id]
end
-- 获取自定义称号物品的配置
function i3k_db_get_diy_text_title_item_cfg(id)
	return i3k_db_diy_text_title.diy_text_items[id < 0 and -id or id]
end
function i3k_db_get_common_item_type(id)
	local realId = id < 0 and -id or id;
	local plane = realId > 10000000 and 0 or math.floor(realId/65536) + 1
	return plane, realId
end

--获取通用物品的配置
function i3k_db_get_common_item_cfg(id)
	local plane, realId = i3k_db_get_common_item_type(id)
	local isFlyEquip
	if g_COMMON_ITEM_TYPE_EQUIP == plane then
		isFlyEquip = g_i3k_game_context:isFlyEquip(i3k_db_common_item_tbl[plane][realId].partID)
	end
	local dbs = i3k_db_common_item_tbl[plane]
	return dbs and dbs[realId], isFlyEquip
end


--获取通用物品名字
function i3k_db_get_common_item_name(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.name or ""
end

--获取通用物品描述
function i3k_db_get_common_item_desc(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.desc or ""
end

--获取通用物品icon path
function i3k_db_get_common_item_icon_path(id,female)
	local db = i3k_db_get_common_item_cfg(id)
	return i3k_db_get_icon_path(db and (female and db.iconFemale or db.icon) or 0)
end

--获取通用物品模型 Id
function i3k_db_get_common_item_model(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.model or 0
end

--获取通用物品级值
function i3k_db_get_common_item_rank(id)
	local db, isFlyEquip = i3k_db_get_common_item_cfg(id)
	return db and db.rank or 0, isFlyEquip
end

--获取通用物品品级对应的外框icon path
function i3k_db_get_common_item_rank_frame_icon_path(id)
	local rank, isFlyEquip = i3k_db_get_common_item_rank(id)
	return g_i3k_get_icon_frame_path_by_rank(rank, isFlyEquip)
end


--获取通用物品等级需求
function i3k_db_get_common_item_level_require(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.levelReq or 0
end

--获取通用物品获取途径
function i3k_db_get_common_item_source(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.get_way or ""
end

--获取通用物品出售卖出所得
function i3k_db_get_common_item_sell_count(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.sellItem or 0
end

--获取通用物品是否可售卖
function i3k_db_get_common_item_can_sale(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.canSale==1
end

--获取背包物品堆叠上限
function i3k_db_get_bag_item_stack_max(id)
	local plane, realId = i3k_db_get_common_item_type(id)
	if plane == 0 then
		return 1
	elseif plane == 1 then
		return 0
	else
		local dbs = i3k_db_common_item_tbl[plane]
		local db = dbs and dbs[realId]
		return db and db.stack_max or -1
	end
end

--获取背包物品排序数
function i3k_db_get_bag_item_order(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.sortid or 0
end

--判断背包道具是否可以在背包使用
function i3k_db_get_bag_item_useable(id)
	local cfg = i3k_db_get_other_item_cfg(id)
	if cfg then
		return cfg.is_use ~= 0
	else
		return nil
	end
end

--帮派共享道具每次申请次个数
function i3k_db_get_common_item_apply_count(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.applyNum or 1
end


--判断背包道具是否为时装道具
function i3k_db_get_bag_item_fashion_able(id)
	local db = i3k_db_get_other_item_cfg(id)
	return db and db.type == UseItemFashion
end

--背包限制使用次数道具使用次数信息
function i3k_db_get_bag_item_limit_times(id)
	return i3k_db_get_other_item_cfg(id).vipDayBuyTimes
end

--判断背包道具是否为限制使用道具
function i3k_db_get_bag_item_limitable(id)
	local cfg = i3k_db_get_other_item_cfg(id)
	if cfg then
		return next(cfg.vipDayBuyTimes) ~= nil
	else
		return nil
	end
end

--判断背包道具是否可以跳转ui
function i3k_db_get_bag_item_jumpUIID(id)
	local cfg = i3k_db_get_other_item_cfg(id)
	if cfg and cfg.jumpUIID ~= 0 then
		return cfg.jumpUIID
	else
		return nil
	end
end

--获取道具的类型绑定和非绑定
function i3k_db_get_common_item_is_free_type(id)
	return id < 0 and "非绑定" or "绑定"
end

--判断背包道具是否可以存入仓库
function i3k_db_get_bag_item_warehouseType(id, wHouseType)
	local db = i3k_db_get_common_item_cfg(id)
	if wHouseType == g_HOMELAND_WAREHOUSE then
		return db and db.warehouseType == g_CAN_PUTIN_HOMELAN_WAREHUOSE
	end
	return db and db.warehouseType == g_CAN_PUTIN_WAREHUOSE
end

--返回背包道具是否满足vip限制, 以及所需vip等级
function i3k_db_get_bag_item_is_need_viplvl(id)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local cfg = i3k_db_get_other_item_cfg(id)
	return vipLvl >= cfg.vip_need_level, cfg.vip_need_level
end

--返回背包道具每日限制使用所剩次数
function i3k_db_get_day_use_item_day_use_times(id)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local timesTb = i3k_db_get_bag_item_limit_times(id)
	if next(timesTb) == nil then
		return nil
	end
	local leftTimes = timesTb[vipLvl+1] - g_i3k_game_context:GetDayUseItemTimes(id) - g_i3k_game_context:GetDayUseItemTimes(-id)
	local maxAddTimes = timesTb[#i3k_db_kungfu_vip+1] - timesTb[vipLvl+1]
	local needLvl = i3k_db_get_day_use_item_need_vip_lvl(timesTb, vipLvl+1)
	return leftTimes, maxAddTimes, needLvl
end

function i3k_db_get_day_use_item_need_vip_lvl(timesTb, vipLvl)
	for i, e in ipairs (timesTb) do
		if e > timesTb[vipLvl] then
			return i - 1
		end
	end
	return -1;
end

--返回背包道具限制使用物品的消耗道具信息(id, count)
function i3k_db_get_day_use_consume_info(id)
	local cfg = i3k_db_get_other_item_cfg(id)
	return cfg.args2, cfg.args3
end

--返回背包道具每日限制使用次数
function i3k_db_get_day_use_item_times(id)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local timesTb = i3k_db_get_bag_item_limit_times(id)
	if next(timesTb) == nil then
		return 0
	end
	local canUseTimes = timesTb[vipLvl + 1]
	return canUseTimes
end

--获取可以赠送的道具
function i3k_db_get_can_giveItem()
	local size, allItems = g_i3k_game_context:GetBagInfo()
	local item = {}
	for k,v in pairs(allItems) do
		local cfg = i3k_db_get_other_item_cfg(k)
		if cfg and cfg.isCanGive == 1 and k < 0 then
			table.insert(item, v)
		end
	end
	return item
end

--获取扩展背包价格
function i3k_db_get_bag_extend_price(expandTimes, wHouseType)
	local wareHouseCfg = i3k_db_common.warehouse
	local bagCfg = i3k_db_common.bag
	local price = wHouseType and wareHouseCfg["price" .. wHouseType] or bagCfg.price
	local priceValue = 0
	if expandTimes == 0 then
		priceValue = price[1]
	else
		priceValue = price[expandTimes] or price[#price]
	end
	local expandCount = wHouseType and wareHouseCfg.expandCount or bagCfg.expandCount
	return priceValue, expandCount
end

--获取扩展背包物品数量
function i3k_db_get_bag_extend_itemCount(expandTimes, wHouseType)
	local wareHouseCfg = i3k_db_common.warehouse
	local bagCfg = i3k_db_common.bag
	local price = wHouseType and wareHouseCfg["useItemCount" .. wHouseType] or bagCfg.useItemCount
	local priceValue = 0
	if expandTimes == 0 then
		priceValue = price[1]
	else
		priceValue = price[expandTimes] or price[#price]
	end
	local expandCount = wHouseType and wareHouseCfg.expandCount or bagCfg.expandCount
	return priceValue, expandCount
end

--获取背包物品占用格子信息 { id=id, [1] = {count=100, guid=nil}, [2] = {count=90, guid=nil}} | { id=id, [1] = {count=1, guid="xxxx_43287_432"}, [2] = {count=1, guid="xxxx_5435_76645"}}
function i3k_db_get_bag_item_cell_info(gameItem)
	local cells = { id = gameItem.id }
	local equips = {}
	for k, v in pairs(gameItem.equips) do
		table.insert(equips, k)
	end
	local stack_max = g_i3k_db.i3k_db_get_bag_item_stack_max(gameItem.id)
	local cellSize = g_i3k_get_use_bag_cell_size(gameItem.count, stack_max)
	local count = gameItem.count
	for k = 1, cellSize do
		local cellItemCount = count - stack_max < 0 and count or stack_max
		table.insert(cells, {count=cellItemCount, guid=equips[k]})
		count = count - cellItemCount
	end
	return cells
end

function i3k_db_sort_bag_items(items)
	local sortItems = {}
	for k,v in pairs(items) do
		table.insert(sortItems, v)
	end
	table.sort(sortItems,function (a,b)
		return a.sortId < b.sortId
	end)
	return sortItems
end

function i3k_db_checkHasItemByCfg(cfgItems)
	for i, value in ipairs(cfgItems) do
		if value.itemCount ~= 0 then
			return true
		end
	end
	return false
end

-- 配置表的物品格式转换格式
function i3k_db_cfgItemsToItems(cfgItems)
	local items = {}
	for i, value in ipairs(cfgItems) do
		if value.itemCount ~= 0  then
			table.insert(items, {id = value.itemID, count = value.itemCount})
		end
	end
	return items
end

-- 配置表的物品格式转换为哈希表格式
function i3k_db_cfgItemsToHashItems(cfgItems)
	local items = {}
	for i, value in ipairs(cfgItems) do
		items[value.itemID] = {id = value.itemID, count = value.itemCount}
	end
	return items
end

function i3k_db_cfgItemsToHashItems_safe(cfgItems)
	local items = cfgItems and (cfgItems.needItems or cfgItems)
	if items then
		return i3k_db.i3k_db_cfgItemsToHashItems(items)
	end
	return {}
end

-- 配置物品数组数据结构转换为@IsBagEnough 所需的数据结构(itemID itemCount)
function i3k_db_cfg_items_to_BagEnougMap(cfgItems)
	local items = {}
	for _, e in ipairs(cfgItems) do
		items[e.itemID] = (items[e.itemID] or 0) + e.itemCount
	end
	return items
end
-- 配置物品数组数据结构转换为@IsBagEnough 所需的数据结构(id count)
function i3k_db_cfg_items_to_BagEnougMap2(cfgItems)
	local items = {}
	for _, e in ipairs(cfgItems) do
		if e.id ~= 0 then
			items[e.id] = (items[e.id] or 0) + e.count
		end
	end
	return items
end


--获取图标路径
function i3k_db_get_icon_path(id)
	local db = i3k_db_icons[id];

	return db and db.path or "";
end

--获取称号图标路径
function i3k_db_get_title_icon_path(id)
	local db = i3k_db_title_icon[id]
	local iconID = db and db.sceneIconID or 0
	return i3k_db_get_scene_icon_path(iconID)
end

--获取场景图标路径
function i3k_db_get_scene_icon_path(id)
	local db = i3k_db_scene_icons[id];
	return db and db.path or ""
end

--根绝id获取角色、怪物、佣兵、Npc头像id
function i3k_db_get_head_icon_id(id)
	local target = i3k_db_mercenaries[id] or i3k_db_monsters[id]
	if target then
		return target.icon
	else
		target = i3k_db_npc[id]
		if target then
			target = i3k_db_monsters[target.monsterID]
			return target.icon or 0
		end
	end
	return 0
end

--根据头像Id获取角色、怪物、佣兵头像路径
function i3k_db_get_head_icon_path(id, square)
	local db = i3k_db_head[id]
	return i3k_db_get_icon_path(db and (square and db.iconR or db.iconC) or 0)
end

--获取佣兵总数
function i3k_db_get_pet_count()
	local count =0
	for k,v in pairs(i3k_db_mercenaries) do
		count = count+v.isOpen --add by jxw
	end
	return count
end

--根据佣兵Id获取佣兵的配置信息
function i3k_db_get_pet_cfg(id)
	return i3k_db_mercenaries[id]
end

--获取佣兵转职配置表
function i3k_db_get_pet_transfer_cfg(lvl)
	return i3k_db_suicong_transfer[lvl]
end

--获取佣兵升级配置表
function i3k_db_get_pet_uplvl_cfg(lvl)
	return i3k_db_suicong_uplvl[lvl]
end

--获取佣兵升星配置表
function i3k_db_get_pet_upstar_cfg(id,starlvl)
	return i3k_db_suicong_upstar[id][starlvl]
end

--获取佣兵亲密度配置表
function i3k_db_get_pet_relation_cfg(petID, lvl)
	return i3k_db_suicong_relation[petID][lvl]
end

--获取等级表
function i3k_db_get_level_cfg(level)
	return i3k_db_exp[level]
end

--根据任务id获取主线任务配置
function i3k_db_get_main_task_cfg(id)
	return i3k_db_main_line_task[id]
end
--姻缘任务
function i3k_db_marry_task(taskID, groupID)
	if groupID and groupID ~= 0 then
		return i3k_db_marry_seriesTask[groupID][taskID]
	else
		return i3k_db_marry_loopTask[taskID]
	end
end

--史诗任务
function i3k_db_epic_task_cfg(seriesID, groupID, id)
	return i3k_db_epic_task[seriesID][groupID][id]
end

function i3k_db_find_nextMapPointID(startId,endId)
	local pointID = i3k_db_find_path_data[startId][endId].posID[1]
	return pointID
end

function i3k_db_getPointdata(pointID)
	return i3k_db_transfer_point[pointID]
end

function i3k_db_find_target_map_cost(fromMapId, toMapId)
	local findPath = i3k_db_find_path_data[fromMapId]
	if findPath and findPath[toMapId] then
		if fromMapId == toMapId then
			return 0
		else
			local pointID = i3k_db_find_nextMapPointID(fromMapId,toMapId)
			local nextmapID = i3k_db_transfer_point[pointID].transmapID
			return 1 + i3k_db_find_target_map_cost(nextmapID, toMapId)
		end
	end
	return 0
end
--db相关功能函数，计算从某一世界地图到多个目标地图中最近的目标地图Id, targetMaps是目标地图的k v table, k是mapId， v是position
function i3k_db_find_nearest_map(srcMapId, targetMaps)
	local nearestMapId = nil
	local nearestMapPos = nil
	local nearestMapCost = nil
	for k, v in pairs(targetMaps) do
		local cost = i3k_db_find_target_map_cost(srcMapId, v)
		if cost and (not nearestMapCost or cost < nearestMapCost) then
			nearestMapCost = cost
			nearestMapId = v
			nearestMapPos = k
		end
	end
	return nearestMapId, nearestMapPos
end

--计算求出在同一个地图中距离英雄最近的npc的位置
function i3k_db_find_nearest_position(num,maptb)
	local mappos = nil
		if num == 1 then
			for k, v in pairs(maptb) do
				mappos = k
			end
		elseif num >= 2 then
			local playerPos = g_i3k_game_context:GetPlayerPos()
			local pos = nil
			local small = nil
			local chazhitb = {}--存一个key是差值，value是pos的table
			for k, v in pairs(maptb) do--比较求出最小值
				pos = i3k_vec3_dist(playerPos, k)
				if small == nil then
					small = pos
				else
					if small <= pos then
						small = small
					else
						small = pos
					end
				end
				chazhitb[pos] = k
			end
			mappos = chazhitb[small]
		end
	return mappos
end
--db相关功能函数，计算从某一世界地图到多个目标地图中最近的目标地图Id, targetMaps是目标地图的k v table, k是mapId， v是position
--[[function i3k_db_find_nearest_map(srcMapId, targetMaps)
	local nearestMapId = nil
	local nearestMapPos = nil
	local pathdb = i3k_db_find_path_data[srcMapId]
	if pathdb then
		local nearestMapCost = nil
		local maptb = {}
		local num = 0
		for k, v in pairs(targetMaps) do
			if v == srcMapId then
				maptb[k] =  v
				num = num + 1
			else
				local db = pathdb[v]
				local cost = db and table.getn(db.posID)
				if cost and (not nearestMapCost or cost < nearestMapCost) then
					nearestMapCost = cost
					nearestMapId = v
					nearestMapPos = k
				end
			end
		end
		if num >=1 then
			nearestMapId = srcMapId
			nearestMapPos = i3k_db_find_nearest_position(num,maptb)
		end
	end
	return nearestMapId, nearestMapPos
end--]]

--根据NPC功能id返回具有参数功能的npc列表
function i3k_db_get_npcs_id_by_funcId(fid)
	local npcs = {}
	for k,v in pairs(i3k_db_npc) do
		for i=1,#v.FunctionID do
			if fid == v.FunctionID[i] then
				table.insert(npcs,v.ID)
			end
		end
	end
	return npcs;
end

function i3k_db_get_all_npcs_map_id_by_funcId(fid)
	local mapsPos = {}
	local npcsId = i3k_db_get_npcs_id_by_funcId(fid)
	for i, e in ipairs(npcsId) do
		local mapId = g_i3k_db.i3k_db_get_npc_map_id(e)
		local pos = g_i3k_db.i3k_db_get_npc_pos(e)
--		local mapId, pos = i3k_db_get_npc_map_position(e)
		if mapId ~= nil then
			mapsPos[pos] = mapId
		end
	end
	return mapsPos
end

--根据npcId获取对应的npc点和坐标
function i3k_db_get_npc_point_by_Id(npcid)
	local mapId = g_i3k_db.i3k_db_get_npc_map_id(npcid);
	local npcAreaIDs = i3k_db_dungeon_base[mapId].npcs
	if npcAreaIDs ~= nil then
		for k1,v1 in ipairs(npcAreaIDs) do
			if i3k_db_npc_area[v1].NPCID == npcid then
				return v1, i3k_db_npc_area[v1].pos
			end
		end
	end
end
--根据位置获取npcid
function i3k_db_get_npc_id_by_pos(mapId,pos)
	local npcAreaIDs = i3k_db_dungeon_base[mapId].npcs
	for k,v in pairs(npcAreaIDs) do
		local tab = i3k_db_npc_area[v]
		if tab then
			if tab.pos.x == pos.x and tab.pos.y == pos.y then
				return tab.NPCID
			end
		end
	end
end

function i3k_db_get_npc_map_by_npc_point(npcPoint)
	for k,v in pairs(i3k_db_dungeon_base) do
		if v.npcs ~= nil then
			for i, e in ipairs(v.npcs) do
				if e == npcPoint then
					return v.id
				end
			end
		end
	end
end

--根据npc点获取npc坐标
function i3k_db_get_npc_postion_by_npc_point(npcPoint)
	return i3k_db_npc_area[npcPoint].pos
end
--根据npc点获取npcid
function i3k_db_get_npc_id_by_npc_point(npcPoint)
	return i3k_db_npc_area[npcPoint].NPCID
end

--根据npcid获取npc点Id
function i3k_db_getNpcAreaId_By_npcId(npcId,mapID)
	local npcAreaId = npcId
	local ids = i3k_db_dungeon_base[mapID].npcs
	for k,v in pairs(ids) do
		if i3k_db_npc_area[v].NPCID == npcId then
			npcAreaId = v
		end
	end
	return npcAreaId
end

--根据npcid获取目标所在的所有地图和坐标
function i3k_db_get_npc_map_position(npcid)
	local point, pos = i3k_db_get_npc_point_by_Id(npcid)
	if point ~= nil then
		return i3k_db_get_npc_map_by_npc_point(point), pos
	end
end

function i3k_db_get_npc_modelID(npcid)
	local monsterID = i3k_db_npc[npcid].monsterID
	local modelID = i3k_db_monsters[monsterID].modelID
	if modelID == 433 then --空的模型ID
		return -1
	else
		return modelID
	end
end

--获取神兵的总数
function i3k_db_get_weapon_count()
	local count = 0
	for k,v in pairs(i3k_db_shen_bing) do
		if v.canUse then --add by jxw
			count = count+1
		end
	end
	return count
end

--获取神兵任务的配置
function i3k_db_get_weapon_task_cfg(id,loop)
	if loop and loop >= 0 and id and id > 0 then
		return i3k_db_weapon_task[loop][id]
	end
end

--获取佣兵任务的配置
function i3k_db_get_pet_task_cfg(id)
	--if id == 0 then
	--	return i3k_db_pet_task[1]
	--end
	return i3k_db_pet_task[id]
end

--获取帮派任务的配置
function i3k_db_get_faction_task_cfg(id)
	return i3k_db_faction_task[id]
end
--获取支线任务配置
function i3k_db_get_subline_task_cfg(groupId,taskId)
	return i3k_db_subline_task[groupId][taskId]
end
function i3k_db_get_five_unique_task_cfg(id)
	return i3k_db_secretarea_task[id]
end
--获取支线任务中每一任务组的第一条
function i3k_db_get_subline_conditionTasks()
	local taskGroup = {}
	local t = g_i3k_game_context:getSubLineTask()
	local exclusionTask = i3k_db_common.changeProfession.exclusionTask
	local exclusion = {}

	for _ , v in ipairs(exclusionTask) do
		for k,_ in pairs(t) do
			if v[1] == k then
				exclusion[v[2]] = 1
				break
			elseif v[2] == k then
				exclusion[v[1]] = 1
				break
			end
		end
	end

	for k,v in pairs(i3k_db_subline_task) do
		if t[k] == nil and not exclusion[k] then
			table.insert(taskGroup,v[1])
		end
	end
	return taskGroup
end

function i3k_db_get_scene_trigger_cfg(id)
	return i3k_db_scene_trigger.cfg[id]
end

function i3k_db_get_scene_trigger_monster_cfg(id)
	local pointID = i3k_db_scene_trigger.cfg[id].arg1
	return pointID,i3k_db_scene_trigger.monster[pointID]
end

function i3k_db_checkMainTaskKillTarget(cfg)
	local tr_cfg = i3k_db_scene_trigger.cfg
	local target = nil
	local effList = cfg.effectIdList or {}
	for i,v in ipairs(effList) do
		if v < 0 and tr_cfg[v].effectType == 6 then
			target = v
			break
		end
	end

	if target then
		local pointID, monster = i3k_db_get_scene_trigger_monster_cfg(target)
		return monster.pos, monster.mapId, false, monster.monsterId,pointID
	else
		return i3k_db_get_monster_pos(cfg.arg1), i3k_db_get_monster_map_id(cfg.arg1), true
	end
end

--判断怪物是不是BOSS
function i3k_db_get_monster_is_boss(id)
	local boss = i3k_db_monsters[id].boss or 0
	return boss~=0
end

function i3k_db_get_monster_head_icon_path(id)
	return i3k_db_get_head_icon_path(i3k_db_monsters[id].icon, false)
end

function i3k_db_get_monster_name(id)
	return i3k_db_monsters[id] and i3k_db_monsters[id].name
end

function i3k_db_get_monster_is_armor(id)
	local armorType = i3k_db_monsters[id].ArmorType or 0;
	return armorType ~= 0
end

--获取怪物的全名
function i3k_db_get_monster_sect_name(id, showName)
	assert(i3k_db_monsters_damageodds[i3k_db_monsters[id].race] ~= nil, "怪物ID:"..id .." 怪物类型配置错误:".. i3k_db_monsters[id].race)
	local raceName = i3k_db_monsters_damageodds[i3k_db_monsters[id].race].desc
	local monsterName = i3k_db_monsters[id].name
	return i3k_get_string(192, raceName, showName or monsterName)
end

--获取怪物等级+名字
function i3k_db_get_monster_lvl_name(id)
	local monsterCfg = i3k_db_monsters[id]
	local lvl = monsterCfg and monsterCfg.level
	local monsterName = i3k_db_monsters[id].name
	return i3k_get_string(192, string.format("%d级", lvl), monsterName)
end

--返回数组表，表储存生成点信息（cfg）和生成点（point）。按怪等级排序
--#1.有怪的区域
function i3k_db_get_monsters(mstAreas)	
	local points = {}
	for i,v in pairs(mstAreas) do
		local monsterPointTable = i3k_db_spawn_area[v].spawnPoints
		for j,k in pairs(monsterPointTable) do
			local pointCfg = i3k_db_spawn_point[k]
			local monsterId = pointCfg.monsters[1]
			local isHave = false
			for _,t in pairs(points) do	--寻找并忽略相同的怪
				if t.cfg.monsters[1] == monsterId then
					isHave = true
					break	
				end
			end
			if not isHave then
				table.insert(points,  {["cfg"] = pointCfg, ["point"]= k})
			end
		end
	end
	table.sort(points, function(a, b)
		local aLvl = g_i3k_db.i3k_db_get_monster_lvl(a.cfg.monsters[1])
		local bLvl = g_i3k_db.i3k_db_get_monster_lvl(b.cfg.monsters[1])
		return aLvl < bLvl
	end)
	return points
end
--获取怪物等级
function i3k_db_get_monster_lvl(id)
	return i3k_db_monsters[id] and i3k_db_monsters[id].level
end
--获取怪物模型
function i3k_db_get_monster_modelID(monsterID)
	return i3k_db_monsters[monsterID].modelID
end

--db相关功能函数，计算添加addExp经验后能达到的等级和最终的经验值
function i3k_db_get_level_exp_on_add_exp(curLvl, curExp, addExp, isAuto)
	local outExp = g_i3k_game_context:GetOutExp()
	if isAuto then
		curExp = outExp + curExp
		outExp = 0
	else
		curExp = curExp + addExp
	end
	local maxLvl = #i3k_db_exp
	for i = curLvl+1,maxLvl do
		local cfg = i3k_db_exp[i]
		if curExp >= cfg.value then
			if curLvl == i3k_db_get_sever_limit_lvl() then
				outExp = outExp + curExp - cfg.value
				curExp = cfg.value
				local mulValue = (i3k_db_server_limit.multiple - 1) * cfg.value
				if outExp >= mulValue then
					outExp = mulValue
				end
			else
				curExp = curExp - cfg.value
				curLvl = curLvl + 1
			end
		else
			break
		end
	end
	if curLvl >= maxLvl then
		curLvl = maxLvl
		curExp = 0
	end
	return curLvl, curExp, outExp
end

--db相关功能函数，计算从旧等级升至新等级后添加的体力值
function i3k_db_get_levelup_add_vit(oldlvl, newlvl)
	local addVitValue = 0
	for lvl = oldlvl + 1,  newlvl do
		addVitValue = addVitValue + i3k_db_exp[lvl].levelUpAddVit
	end
	return addVitValue
end

-- 获取服务器封印等级
function i3k_db_get_sever_limit_lvl()
	if g_i3k_game_context:isSealBreak() then
		return i3k_db_server_limit.breakSealCfg.newSealLevel
	else
		return i3k_db_server_limit.sealLevel
	end
end

-- 获取额外存储经验最大值
function i3k_db_get_max_out_exp()
	local limitLvl = i3k_db_get_sever_limit_lvl()
	return (i3k_db_server_limit.multiple - 1) * i3k_db_exp[limitLvl + 1].value
end

-- 获取当前冲关等级差配置
function i3k_db_rush_lvl_cfg()
	local cfg
	local roleLvl = g_i3k_game_context:GetLevel()
	local rushLvl = g_i3k_game_context:GetSpeedUpLvl()
	if rushLvl - roleLvl <= 0 then
		return cfg
	end
	local rushLvlCfg = i3k_db_server_limit.rushLevelExpPlus
	for i, e in ipairs(i3k_db_sort_rush_lvl(rushLvlCfg)) do
		if rushLvl - roleLvl >= e then
			cfg = rushLvlCfg[e]
		end
	end
	return cfg
end

-- 排序冲关等级配置
function i3k_db_sort_rush_lvl(cfg)
	local data = {}
	for k, v in pairs(cfg) do
		table.insert(data, k)
	end
	table.sort(data, function (a,b)
		return a < b
	end)
	return data
end

-- 获取配置的最小的冲关等级
function i3k_db_get_min_rush_lvl()
	local data = i3k_db_sort_rush_lvl(i3k_db_server_limit.rushLevelExpPlus)
	return data[1] or 0
end

-- 获取配置的最大的冲关等级
function i3k_db_get_max_rush_lvl()
	local data = i3k_db_sort_rush_lvl(i3k_db_server_limit.rushLevelExpPlus)
	return data[#data]
end

-- 使用经验丹能到达的限制的最高等级（受服务器冲关等级，服务器封印等级限制）
function i3k_db_get_can_achieve_lvl()
	if i3k_db_get_limit_condition() then
		return i3k_db_get_sever_limit_lvl()
	end
	local rushLvl = g_i3k_game_context:GetSpeedUpLvl()
	if rushLvl - g_i3k_game_context:GetLevel() >= i3k_db_get_min_rush_lvl() then
		return rushLvl - i3k_db_rush_lvl_cfg().levelLess + 1
	end
end

-- 大于最小冲关等级差，小于封印等级
function i3k_db_get_limit_condition()
	local roleLvl = g_i3k_game_context:GetLevel()
	return g_i3k_game_context:GetSpeedUpLvl() - roleLvl < g_i3k_db.i3k_db_get_min_rush_lvl() and roleLvl < g_i3k_db.i3k_db_get_sever_limit_lvl()
end

--服务器等级相关，计算使用经验丹addExp经验后能达到的等级和最终的经验值
function i3k_db_get_level_exp_on_use_item(curLvl, curExp, addExp)
	curExp = curExp + addExp
	local maxLvl = #i3k_db_exp
	local achieveLvl = i3k_db_get_can_achieve_lvl()
	for i = curLvl+1,maxLvl do
		local cfg = i3k_db_exp[i]
		if curExp >= cfg.value then
			curExp = curExp - cfg.value
			if curLvl ~= achieveLvl then
				curLvl = curLvl + 1
			else
				break
			end
		else
			break
		end
	end
	if curLvl >= maxLvl then
		curLvl = maxLvl
		curExp = 0
	end
	return curLvl, curExp
end


--相关功能函数，根据佣兵友好度计算佣兵的友好度等级
function i3k_db_get_pet_fri_lvl_by_value(petID, value)
	local old_lvl = 1
	local need_exp = 0
	-- repeat
		-- local suicong_relation = i3k_db_suicong_relation[old_lvl + 1]
	-- until suicong_relation == nil
	while i3k_db_suicong_relation[petID][old_lvl + 1] do
		need_exp = i3k_db_suicong_relation[petID][old_lvl + 1].needCount
		if need_exp > value then
			break
		else
			old_lvl = old_lvl + 1
			value = value - need_exp
		end
	end
	return old_lvl,value
end


function i3k_db_get_channel_pay_cfg(gameAppId, channel)
	local channelCfg = nil
	for i, e in pairs(i3k_db_channel_area) do
		if e.channle_str == channel then
			channelCfg = e
			break
		end
	end
	if not channelCfg then
		for i, e in pairs(i3k_db_channel_area) do
			if e.channle_str == gameAppId then
				channelCfg = e
				break
			end
		end
	end
	return channelCfg and i3k_db_channel_pay[channelCfg.payID] or nil
end

function i3k_db_get_chanllenge_task_cfg(type, seq)
	local chTaskCfg = i3k_db_challengeTask
	local group = chTaskCfg[type]
	if not group then
		return
	end
	return group[seq]
end

--任务拼的描述(isLight控制任务文字颜色高亮)
function i3k_db_get_task_desc(taskType, arg1, arg2, value, isFinished, specializedDesc, isLight)
	local targetDesc = ""
	local color = g_i3k_get_task_cond_color(isFinished)
	if isLight ~= nil and not isLight then
		color = g_i3k_get_cond_color(isFinished)
	end
	if taskType == g_TASK_KILL then
		targetDesc = g_i3k_make_color_string(string.format("%s：%s/%s", i3k_db_monsters[arg1].name, value, arg2), color,true)
	elseif taskType == g_TASK_COLLECT then
		targetDesc = g_i3k_make_color_string(string.format("%s：%s/%s", i3k_db_resourcepoint[arg1].name, value, arg2), color,true)
	elseif taskType == g_TASK_USE_ITEM_AT_POINT then
		targetDesc = g_i3k_make_color_string(i3k_db_get_common_item_name(arg1), color,true)
	elseif taskType == g_TASK_TOATL_DAYS then
		targetDesc = g_i3k_make_color_string(arg1, color,true)
	elseif taskType == g_TASK_REACH_LEVEL then
		targetDesc = g_i3k_make_color_string(arg1, color,true)
	elseif taskType == g_TASK_NPC_DIALOGUE then
--		targetDesc = g_i3k_make_color_string(i3k_db_monsters[i3k_db_npc[arg1].monsterID].name, color,true)
		targetDesc = g_i3k_make_color_string(i3k_db_npc[arg1].remarkName, color,true)
	elseif taskType == g_TASK_NEW_NPC_DIALOGUE then
		targetDesc = g_i3k_make_color_string(i3k_db_npc[arg1].remarkName, color,true)
	elseif taskType == g_TASK_USE_ITEM then
		local cnt = g_i3k_game_context:GetCommonItemCanUseCount(arg1)
		value = isFinished and arg2 or cnt
		value = cnt > arg2 and arg2 or value
		color = g_i3k_get_task_cond_color(value >= arg2)
		targetDesc = g_i3k_make_color_string(string.format("%s：%s/%s",i3k_db_get_common_item_name(arg1),value, arg2), color,true)
	elseif taskType == g_TASK_GET_TO_FUBEN then
		targetDesc = g_i3k_make_color_string(string.format("%s：%s/%s", i3k_db_new_dungeon[arg1].name, value, arg2), color,true)
	elseif taskType == g_TASK_GET_PET_COUNT then
		targetDesc = g_i3k_make_color_string(arg1, color,true)
	elseif taskType == g_TASK_POWER_COUNT then
		targetDesc = g_i3k_make_color_string(arg1, color,true)
	elseif taskType == g_TASK_TRANSFER then
		targetDesc = g_i3k_make_color_string(arg1, color,true)
	elseif taskType == g_TASK_CLEARANCE_ACTIVITYPAD then--活动副本
		targetDesc = g_i3k_make_color_string(i3k_db_activity[arg1].name, color,true)
	elseif taskType == g_TASK_PERSONAL_ARENA then--参与个人竞技场
		value = g_i3k_game_context:GetArenaEnterTimes()
		value = value > arg1 and arg1 or value
		targetDesc = g_i3k_make_color_string(string.format("个人竞技场：%s/%s", value, arg1), color,true)
	elseif taskType == g_TASK_SHAPESHIFTING then--护送Npc
		targetDesc = g_i3k_make_color_string(string.format("%s",i3k_db_npc[arg1].remarkName), color,true)
	elseif taskType == g_TASK_CONVOY then--运送物件
		targetDesc = g_i3k_make_color_string(string.format("%s",i3k_db_get_common_item_name(arg1)), color,true)
	elseif taskType == g_TASK_ANSWER_PROBLEME then --回答问题
		return string.format("回答<c=%s>%s</c>的问题",color,i3k_db_npc[arg1].remarkName)
	elseif taskType == g_TASK_JOIN_FACTION then
		return g_i3k_make_color_string(string.format("%s","加入帮派"), color,true)
	elseif taskType == g_TASK_GATE_POINT then
		targetDesc = g_i3k_make_color_string(i3k_db_transfer_point[arg1].Tips, color,true)
	elseif taskType == g_TASK_ENTER_FUBEN then
		return string.format("参与<c=%s>%s：%s/%s</c>",color,i3k_db_new_dungeon[arg1].name, value, arg2)
	elseif taskType == g_TASK_TOMORROW then
		return isFinished and "点击完成" or i3k_get_string(17138)
	elseif taskType == g_TASK_FIND_DIFFERENCE then
		return isFinished and i3k_get_string(17256) or i3k_get_string(17255)
	elseif taskType == g_TASK_PUZZLE_PICTURE then
		return isFinished and i3k_get_string(17258) or i3k_get_string(17257)
	elseif taskType == g_TASK_PLAY_SOCIALACT then
		return isFinished and i3k_get_string(17260) or i3k_get_string(17259, i3k_db_social[arg1].name, i3k_db_generals[arg2].name)
	elseif taskType == g_TASK_SORT_VERSE then
		return isFinished and i3k_get_string(17262) or i3k_get_string(17261)
	elseif taskType == g_TASK_LUCKYCHANCE then
		return isFinished and i3k_get_string(17264) or i3k_get_string(17263)
	elseif taskType == g_TASK_ANY_MOMENT_DUNGEON then
		return isFinished and string.format("<c=hlgreen>%s：1/1</c>", i3k_db_at_any_moment[arg1].desc) or string.format("<c=hlred>%s：0/1</c>", i3k_db_at_any_moment[arg1].desc)
	elseif taskType == g_TASK_SCENE_MINE then
		local mapID = i3k_db_scene_mine_cfg[arg1].mapID
		local totalValue = #i3k_db_scene_mine_cfg[arg1].mineIDs
		local curValue = i3k_db_get_finished_point_count(value, totalValue)
		return isFinished and i3k_get_string(17260) or i3k_get_string(17811, i3k_db_field_map[mapID].desc, curValue, totalValue)
	elseif taskType == g_TASK_NPC_SOCIAL_ACTION then
		return isFinished and i3k_get_string(17260) or i3k_get_string(17812, i3k_db_npc[arg1].remarkName, i3k_db_social[arg2].name)
	elseif taskType == g_TASK_ROLE_FLYING then
		return isFinished and "<c=hlgreen>完成飞升</c>" or "<c=hlred>完成飞升</c>"
	elseif taskType == g_TASK_OWN_WEAPON then
		return g_i3k_make_color_string(i3k_get_string(18316, i3k_db_shen_bing[arg1].name), color, true)
	elseif taskType == g_TASK_OWN_HORSE then
		return g_i3k_make_color_string(i3k_get_string(18317, i3k_db_steed_huanhua[i3k_db_steed_cfg[arg1].huanhuaInitId].name), color, true)
	elseif taskType == g_TASK_OWN_PET then
		return g_i3k_make_color_string(i3k_get_string(18318, i3k_db_mercenaries[arg1].name), color, true)
	elseif taskType == g_TASK_TEAM_WITH_ISOMERISM then
		return g_i3k_make_color_string(i3k_get_string(18319), color, true)
	elseif taskType == g_TASK_CHANGE_ITEM then
		return g_i3k_make_color_string(i3k_get_string(18315), color, true)
	elseif taskType == g_TASK_DELIVER_LETTERS then
		local totalValue = #i3k_db_npc_deliver_letters[arg1].npcList
		local curValue = i3k_db_get_finished_point_count(value, totalValue)
		return g_i3k_make_color_string(i3k_get_string(18285, curValue, totalValue), color, true)
		--return isFinished and i3k_get_string(17260) or i3k_get_string(17811, "11", curValue, totalValue)
	end
	if specializedDesc then
		if arg2 and arg2 ~= 0 then
			targetDesc = g_i3k_make_color_string(string.format("：%s/%s", value, arg2), color,true)
		end
		if taskType == g_TASK_GATE_POINT or taskType ==  g_TASK_USE_ITEM_AT_POINT or taskType ==  g_TASK_SHAPESHIFTING or taskType ==  g_TASK_CONVOY  or taskType ==  g_TASK_NPC_DIALOGUE or taskType == g_TASK_NEW_NPC_DIALOGUE then
			return specializedDesc
		end
		local specialiDesc = string.format("%s%s",specializedDesc,targetDesc)
		return specialiDesc
	end
	return i3k_get_string(task_desc[taskType], targetDesc)
end

function i3k_db_get_task_specialized_desc(cfg,isFinished)
	if cfg.getTaskDesc and cfg.getTaskDesc ~= "0.0" then
		isFinished = g_i3k_get_task_cond_color(isFinished)
		return g_i3k_make_color_string(cfg.getTaskDesc, isFinished, true)
	end
end

function i3k_db_get_faction_task_specialized_desc(taskId,isFinished)
	local main_task_cfg = i3k_db_get_faction_task_cfg(taskId)
	if main_task_cfg.getTaskDesc ~= "0.0" then
		isFinished = g_i3k_get_cond_color(isFinished)
		return g_i3k_make_color_string(main_task_cfg.getTaskDesc, isFinished)
	end

end

function i3k_db_get_task_finish_reward_desc(cfg)
	if cfg.finishTaskDesc and cfg.finishTaskDesc ~= "0.0" then
		return cfg.finishTaskDesc
	end
	local npcId = cfg.finishTaskNpcID
	if npcId and npcId ~= 0 then
		local name = i3k_db_npc[npcId].remarkName
		return i3k_get_string(72,name)
	end
end

function i3k_db_get_faction_task_finish_reward_desc(taskId)
	local faction_task_cfg = i3k_db_get_faction_task_cfg(taskId)
	local npcId = faction_task_cfg.finishTaskNpcID
	if npcId ~= 0 then
		local name = i3k_db_npc[npcId].remarkName
		return i3k_get_string(72,name)
	end
end

--支线任务描述
--[[function i3k_db_get_subline_task_specialized_desc(taskId,isFinished)
	local main_task_cfg = i3k_db_get_subline_task_cfg(taskId)
	if main_task_cfg.getTaskDesc ~= "0.0" then
		isFinished = g_i3k_get_cond_color(isFinished)
		return g_i3k_make_color_string(main_task_cfg.getTaskDesc, isFinished)
	end
end--]]

function i3k_db_get_subline_task_finish_reward_desc(groupId,taskId)
	local cfg = i3k_db_get_subline_task_cfg(groupId,taskId)
	local npcId = cfg.finishTaskNpcID
	if npcId ~= 0 then
		local name = i3k_db_npc[npcId].remarkName
		return i3k_get_string(72,name)
	end
end

function i3k_db_get_life_task_finish_reward_desc(petID, taskId)
	local cfg = i3k_db_from_task[petID][taskId]
	local npcId = cfg.completeNpcID
	if npcId ~= 0 then
		local name = i3k_db_npc[npcId].remarkName
		return i3k_get_string(72,name)
	end
end

function i3k_db_get_outcast_task_finish_reward_desc(petID, taskId)
	local cfg = i3k_db_getOutCastTaskCfgByTaskID(petID, taskId)
	local npcId = cfg.completeNpcID
	if npcId ~= 0 then
		local name = i3k_db_npc[npcId].remarkName
		return i3k_get_string(72,name)
	end
end

function i3k_db_get_Secretarea_task_finish_reward_desc(taskId)
	local secretarea_task_cfg = i3k_db_secretarea_task[taskId]--i3k_db_get_main_task_cfg(taskId)
	--local npcId = secretarea_task_cfg.finishTaskNpcID

end

local function getFourDialog(cfg, prefixStr)
	local t = {}
	local moduleIds = {}
	for i = 1 , 4 do
		local tmp_dialog = string.format("%s%d", prefixStr, i)
		local keyName = string.format("%sIcon",tmp_dialog)
		local dialogId = cfg[tmp_dialog]
		if dialogId ~= 0 then
			local str = i3k_db_dialogue[dialogId]
			for k,v in ipairs(str) do
				table.insert(t,v)
				table.insert(moduleIds, cfg[keyName])
			end
		end
	end
	return t, moduleIds
end
--获取婚姻任务接取对白
function i3k_db_get_mrg_task_start_desc(id, groupID)
	local cfg = i3k_db_marry_task(id, groupID)
	return getFourDialog(cfg, "getTaskDialogue")
end
function i3k_db_get_mrg_task_finish_desc(id, groupID)
	local cfg = i3k_db_marry_task(id, groupID)
	return getFourDialog(cfg, "finishTaskDialogue")
end
--获取主线任务接取对白
function i3k_db_get_task_start_desc(cfg)
	--local main_task_cfg = i3k_db_get_main_task_cfg(id)
	return getFourDialog(cfg, "getTaskDialogue")
end

--答题对白
function i3k_db_get_main_task_Question(qid, isRight)
	local cfg = i3k_db_task_question.taskCfg[qid]
	if isRight then
		return getFourDialog(cfg, "rightTaskDialogue")
	else
		return getFourDialog(cfg, "failTaskDialogue")
	end
end

--获取主线任务完成对白
function i3k_db_get_task_finish_desc(cfg)
	--local main_task_cfg = i3k_db_get_main_task_cfg(id)
	return getFourDialog(cfg, "finishTaskDialogue")
end

---获取支线任务接取对白
function i3k_db_get_subline_task_get_desc(groupId,taskid)
	local subline_task_cfg = i3k_db_get_subline_task_cfg(groupId,taskid)
	return getFourDialog(subline_task_cfg, "getTaskDialogue")
end

---获取支线任务完成对白
function i3k_db_get_subline_task_finish_desc(groupId,taskid)
	local subline_task_cfg = i3k_db_get_subline_task_cfg(groupId,taskid)

	return getFourDialog(subline_task_cfg, "finishTaskDialogue")
end

--获取身世任务接取对白
function i3k_db_get_life_task_get_desc(petID, taskID)
	local life_task_cfg = i3k_db_from_task[petID][taskID]
	local t = {}
	local moduleIds = {}
	for i=1,4 do
		local tmp_dialog = string.format("talkID%s",i)
		local keyName = "talkModel" .. i
		local dialog = life_task_cfg[tmp_dialog]
		if dialog ~= 0 then
			local str = i3k_db_dialogue[dialog]
			for k,v in ipairs(str) do
				table.insert(t,v)
				table.insert(moduleIds,life_task_cfg[keyName])
			end
		end
	end
	return t,moduleIds
end

--获取身世任务的完成对白
function i3k_db_get_life_task_finish_desc(petID, taskid)
	local life_task_cfg = i3k_db_from_task[petID][taskid]
	local t = {}
	local moduleIds = {}
	for i=1,4 do
		local tmp_dialog = string.format("completeTalk%s",i)
		local keyName = "completeModel" .. i
		local dialog = life_task_cfg[tmp_dialog]
		if dialog ~= 0 then
			local str = i3k_db_dialogue[dialog]
			for k,v in ipairs(str) do
				table.insert(t,v)
				table.insert(moduleIds,life_task_cfg[keyName])
			end
		end
	end
	return t,moduleIds
end

--获取帮派任务完成对白
function i3k_db_get_faction_task_finish_desc(cfg)
	local t = {}
	if cfg.type == g_TASK_NEW_NPC_DIALOGUE then
		return i3k_db_dialogue[cfg.arg2]
	end
	for i=1,4 do
		local tmp_desc = string.format("finishTaskDialogue%s",i)
		local finishTaskDialogue = cfg[tmp_desc]
		if finishTaskDialogue ~= "0.0" then
			table.insert(t,finishTaskDialogue)
		end
	end
	return t
end

--获取宗门任务的配置数据
function i3k_db_get_clan_task_cfg(id)
	return i3k_db_clan_task[id]
end

--获取宗门任务的参数
function i3k_db_get_clan_task_args()
	return i3k_db_clan_task_args
end


--获取宗门声望先关的配置表
function i3k_db_get_clan_presgite_cfg()
	return i3k_db_clan_presgite
end


--获取技能图标
function i3k_db_get_skill_icon_path(id)
	local skill = i3k_db_skills[id]
	return skill and i3k_db_get_icon_path(skill.icon) or 0
end

--获取人物技能的等级最大值
function i3k_db_get_skill_MaxLevel(typeId)
	--每个技能的最大级别（其实就是角色等级上限）
	local one_skill_max_level = 0
	--初始技能个数（4个）
	local init_skill_num = 0
	--转职技能个数（每转职加2个，共3转）
	local trans_skill_num = 0
	--绝技的数量
	local unique_skill_num = 0
	if i3k_db_exp then
		one_skill_max_level = #i3k_db_exp
	end
	if i3k_db_generals and i3k_db_generals[1] and i3k_db_generals[1].skills then
		init_skill_num = #i3k_db_generals[1].skills
	end
	if i3k_db_zhuanzhi and i3k_db_zhuanzhi[1] then
		trans_skill_num = #i3k_db_zhuanzhi[1] * 2
	end
	if i3k_db_exskills then
		unique_skill_num = #i3k_db_exskills
	end
	--每个技能的最大级别* （初始数+转职数+绝技数）
	return one_skill_max_level * (init_skill_num + trans_skill_num + unique_skill_num);
end

--获取初始四个技能解锁所需等级
function i3k_db_get_skill_unlock_level(skills)
	local needLvlTable = {}
	for i,v in ipairs(skills) do
		local needLevel = i3k_db_skill_datas[v][1].studyLvl
		table.insert(needLvlTable, needLevel)
	end
	return needLvlTable
end

--先领任务返回对应目标所在mapID
function i3k_db_GlobalWorldTask_GetTarget_MapID(cfg)
	local monsterMapId = 0
	--确认任务目标的所在地图
	if cfg.type == g_TASK_KILL then
		monsterMapId = g_i3k_db.i3k_db_get_monster_map_id(cfg.arg1)
	elseif cfg.type == g_TASK_COLLECT then
		monsterMapId = g_i3k_db.i3k_db_get_res_map_id(cfg.arg1)
	elseif cfg.type == g_TASK_NEW_NPC_DIALOGUE then
		monsterMapId = g_i3k_db.i3k_db_get_npc_map_id(cfg.arg1)
	end
	return monsterMapId
end
--获取默认的帮派图标
function i3k_db_get_faction_auto_icon()

	return i3k_db_faction_icons[1].faction_id
end


function i3k_db_get_max_fight_sp(ctype)
	return i3k_db_fightsp[ctype].overlays
end

function i3k_db_get_character_default_skills(ctype)
	return i3k_db_generals[ctype].skills
end

function i3k_db_get_character_dodge_skill(ctype)
	return i3k_db_generals[ctype].dodgeSkill
end

function i3k_db_get_monster_map_id(mid)
	assert(i3k_db_monster_map[mid] ~= nil, "怪物ID:"..mid.." 没有在副本配置表中配置")
	return i3k_db_monster_map[mid].mapid;
end

function i3k_db_get_monster_pos(mid)
	assert(i3k_db_monster_map[mid] ~= nil, "怪物ID:"..mid.." 没有在副本配置表中配置")
	return i3k_db_monster_map[mid].pos;
end

function i3k_db_get_npc_map_id(nid)
	assert(i3k_db_npc_map[nid] ~= nil, "npcID:"..nid.." 没有在副本配置表中配置")
	return i3k_db_npc_map[nid].mapid;
end

function i3k_db_get_npc_pos(nid)
	assert(i3k_db_npc_map[nid] ~= nil, "npcID:"..nid.." 没有在副本配置表中配置")
	return i3k_db_npc_map[nid].pos;
end

function i3k_db_get_res_map_id(rid)
	return i3k_db_res_map[rid].mapid;
end

function i3k_db_get_res_pos(rid)
	return i3k_db_res_map[rid].pos;
end

--返回摇钱树vip等级对应的日购买金币次数
function i3k_db_get_day_buy_coin_times(vipLvl)
	return i3k_db_kungfu_vip[vipLvl].buyCoinTimes
end

--返回摇钱树购买次数对应的价格以及相同价格下可买次数
function i3k_db_get_buy_coin_price_AND_times(times)
	local priceTab = i3k_db_common.buyCoin.price
	local DiamondType = 1
	local totalDiamond = g_i3k_game_context:GetCommonItemCanUseCount(DiamondType)
	local price = 0
	local count = 1
	if times >= #priceTab then
		local vipLvl = g_i3k_game_context:GetVipLevel()
		local totalTimes = i3k_db_kungfu_vip[vipLvl].buyCoinTimes
		count = totalTimes - times > 10 and 10 or totalTimes - times + 1
		price = priceTab[#priceTab]
	else
		for i = times,#priceTab do
			if priceTab[i] == priceTab[i+1] then
				count = count + 1
			else
				break
			end
		end
		price = priceTab[times]
	end
	if totalDiamond < price * count then -- 当玩家总元宝不足购买这么多次的时候
		local fmod = math.fmod(totalDiamond , price)
		count = (totalDiamond - fmod ) / price
	end
	return price , count
end

--返回摇钱树角色购买次数下,继续买可获得的金币数
function i3k_db_get_buy_coin_amount(baseTimes,buyTimes)
	local getCoinCount = 0
	local Times = baseTimes+1
	for i=1,buyTimes do
		getCoinCount = i3k_db_get_add_coin_count(Times) + getCoinCount
		Times = Times + 1
	end
	return getCoinCount
end

--使用元宝购买铜钱相关
function i3k_db_get_add_coin_count(number)
	local lvl = g_i3k_game_context:GetLevel()
	local baseCoin =  i3k_db_common.buyCoin.baseCoin
	local roleIncrement = i3k_db_common.buyCoin.roleIncrement
	local timesIncrement = i3k_db_common.buyCoin.timesIncrement
	local addCoinCount = baseCoin + roleIncrement * lvl + timesIncrement * number
	return addCoinCount
end

function i3k_db_get_buy_coin_price()
	return i3k_db_common.buyCoin.price
end

function i3k_db_get_buy_coin_correct_pirce(times)
	local price = i3k_db_get_buy_coin_price()
	return price[number+1] or price[#price]
end

function i3k_db_get_buy_coin_needDiamond_count(scrollData)
	local needDiamond = 0
	for i=1,#scrollData do
		needDiamond = needDiamond + scrollData[i].needDiamond
	end
	return needDiamond
end

-- 套装相关
function i3k_db_get_suitEquip_effect_data(equipData,tmp)
	local _temp_t = g_i3k_game_context:GetHaveSuitEquipData()
	local effect_data = _temp_t.data1
	local effect_count = 0
	for k,v in ipairs (equipData) do
		local tmp = v
		if effect_data[tmp.id] then
			if #effect_data[tmp.id] == tmp.count then
				effect_count = effect_count + 1
			end
		end
	end
	return effect_count
end

function i3k_db_get_attribute_name(_attribute)
	return  i3k_db_prop_id[_attribute].desc
end

function i3k_db_get_attribute_text_color(_attribute)
	return i3k_db_prop_id[_attribute].textColor
end

function i3k_db_get_attribute_icon(_attribute)

	local id = i3k_db_prop_id[_attribute].icon

	return id and i3k_db_get_icon_path(id) or 0
end

function i3k_db_get_attribute_value_color(_attribute)
	return i3k_db_prop_id[_attribute].valuColor
end

function i3k_db_get_suitEquip_lastOne(id)
	for k,v in pairs(i3k_db_suit_equip) do
		if v[id] then
			return v[id] or {}
		end
	end
	return {}
end

--获取套装已拥装备有个数
function i3k_db_get_suitEquip_have_count(id)
	local _temp_t = g_i3k_game_context:GetHaveSuitEquipData()
	local effect_data = _temp_t.data1
	local have_count = 0
	if effect_data and effect_data[id] then
		have_count = #effect_data[id]
	end
	return have_count
end

--通过套装id获得只缺一件套装ID
function i3k_db_get_suitEquip_last_id(suitId)
	local _temp_t = g_i3k_game_context:GetHaveSuitEquipData()
	local effect_data = _temp_t.data1
	local allEquip = i3k_db_get_suit_equip_data(suitId)
	local tmp = {}
	for i, e in pairs(effect_data) do
		if i == suitId then
			tmp = e
		end
	end
	local t = {}
	for i, e in pairs(tmp) do
		t[e] = true
	end
	for i, e in pairs(allEquip) do
		if not t[e] then
			return e
		end
	end
end

--获取所有套装信息
function i3k_db_get_all_suit_data(suitId)
	local suitData = {}
	for i, e in pairs(i3k_db_suit_equip) do
		for j, v in pairs(e) do
			table.insert(suitData, v)
		end
	end
	table.sort(suitData, function (a,b)
		return a.id < b.id
	end)
	return suitData[suitId]
end

--通过套装id获取套装所包含装备
function i3k_db_get_suit_equip_data(suitId)
	local allEquip = {}
	local cfg = i3k_db_get_all_suit_data(suitId)
	for i=1, i3k_db_common.equip.equipPropCount do
		local partID = string.format("part%sID", i)
		if cfg[partID] ~= 0 then
			table.insert(allEquip, cfg[partID])
		end
	end
	return allEquip
end

--获取宗门的参数配置表
function i3k_db_get_clan_args_cfg()
	return i3k_db_clan_args
end

--获取宗门基础配置表
function i3k_db_get_clan_base_cfg()
	return i3k_db_clan
end


function i3k_db_get_mail_title_text(mailType, additional, title)
	if mailType==-1 then
		if additional then
			local mapCfg = i3k_db_dungeon_base[additional[1]]
			if mapCfg.openType==g_FIELD then
				return i3k_get_string(756, mapCfg.name)
			end
		end
		return i3k_get_string(232)
	elseif mailType==0 then
		return i3k_get_string(225)
	elseif mailType==1 then
		return string.format("系统信件")
	elseif mailType==3 then
		return i3k_get_string(223)
	elseif mailType==4 then
		return i3k_get_string(221)
	elseif mailType==5 then
		return i3k_get_string(226)
	elseif mailType==6 then
		return i3k_get_string(228)
	elseif mailType==7 then
		return i3k_get_string(316)
	elseif mailType==8 then
		return string.format("正邪道场信件")
	elseif mailType==9 then
		return string.format("运镖信件")
	elseif mailType==10 then
		return i3k_get_string(608)
	elseif mailType==11 then
		return i3k_get_string(1565)
	elseif mailType == 12 then
		return i3k_get_string(696)
	elseif mailType == 13 then
		return i3k_get_string(704)
	elseif mailType == 14 then
		return i3k_get_string(706)
	elseif mailType == 15 then
		return i3k_get_string(708)
	elseif mailType == 16 then
		return i3k_get_string(710)
	elseif mailType == 17 then
		return string.format("错过的大餐")
	elseif mailType == 18 then
		return i3k_get_string(749)
	elseif mailType == 19 then
		return i3k_get_string(751)
	elseif mailType == 20 then
		return i3k_get_string(758)
	elseif mailType == 21 then
		return i3k_get_string(762)
	elseif mailType == 22 then
		return i3k_get_string(15179)
	elseif mailType == 23 then
		return i3k_get_string(892)
	elseif mailType == 24 then
		return i3k_get_string(907)
	elseif mailType == 25 then
		return i3k_get_string(3051)
	elseif mailType == 26 then
		return "传世装备"
	elseif mailType == 27 then  --带标题邮件 or 应用宝邮件
		return title ~= "" and title or "应用宝邮件"
	elseif mailType == 28 then
		return "拜师成功"
	elseif mailType == 29 then
		return "拒绝出师"
	elseif mailType == 30 then
		return "徒弟出师奖励"
	elseif mailType == 31 then
		return "出师奖励"
	elseif mailType == 32 then
		return "师傅除名"
	elseif mailType == 33 then
	   return i3k_get_string(15448)
	elseif mailType == 34 then
	   return i3k_get_string(15452)
	elseif mailType == 35 then
	   return i3k_get_string(15450)
	elseif mailType == 36 then
	   return i3k_get_string(15454)
  	elseif mailType == 37 then
  		if additional then
	  		local battleState = additional[1]  --1胜，2平或负，3轮空
			if battleState == 1 then
				return i3k_get_string(1010)
			elseif battleState == 2 then
				return i3k_get_string(1012)
			elseif battleState == 3 then
				return i3k_get_string(1014)
			end
  		end
  		return i3k_get_string(1020)
   	elseif mailType == 38 then
   		return i3k_get_string(1016)
   	elseif mailType == 39 then
   		return i3k_get_string(1018)
	elseif mailType == 40 then
		return "回归奖励"
	elseif mailType == 41 then
		return i3k_get_string(15583)
	elseif mailType == 42 then
		return "宠物赛跑"
	elseif mailType == 43 then
		return i3k_get_string(16380)
	elseif mailType == 44 then
		return i3k_get_string(16384)
	elseif mailType == 45 then
		return i3k_get_string(16761)
	elseif mailType == 46 then
		return i3k_get_string(16661)
	elseif mailType == 47 then
		return i3k_get_string(16719)
	elseif mailType == 49 then
		return i3k_get_string(16857)
	elseif mailType == 50 then
		return "个人龙穴奖励"
	elseif mailType == 51 then
		return "帮派龙穴奖励"
	elseif mailType == 52 then
		return i3k_get_string(5042)
	elseif mailType == 53 then
		return i3k_get_string(5044)
	elseif mailType == 54 then
		return i3k_get_string(16997)
	elseif mailType == 55 then
		return "任务补领奖励"
	elseif mailType == 56 then
		return "精灵旅行奖励"
	elseif mailType == 57 then --sectShare帮派仓库分享
		return i3k_get_string(1353)
	elseif mailType == 58 then
		return i3k_get_string(17155)
	elseif mailType == 59 then
		return i3k_get_string(17222)
	elseif mailType == 60 then
		return i3k_get_string(17223)
	elseif mailType == 61 then
		return i3k_get_string(1424)
	elseif mailType == 62 then --家园邮件
		return "钓鱼奖励"
	elseif mailType == 63 then
		return "珍珑棋局奖励"
	elseif mailType == 64 then
		return i3k_get_string(5346)
	elseif mailType == 65 then
		return i3k_get_string(5250)
	elseif mailType == 66 then
		return "伙伴充值返回红利"
	elseif mailType == 67 then
		return i3k_get_string(5254)
	elseif mailType == 68 then
		return i3k_get_string(5171)
	elseif mailType == 69 then
		return i3k_get_string(17446)
	elseif mailType == 70 then
		return i3k_get_string(17475)
	elseif mailType == 71 then
		return "家俱回收"
	elseif mailType == 72 then
		return i3k_get_string(17641)
	elseif mailType == 73 then
		return i3k_get_string(17643)
	elseif mailType == 74 then
		return i3k_get_string(5431)
	elseif mailType == 75 then
		return i3k_get_string(17860)
	elseif mailType == 76 then
		return i3k_get_string(17855)
	elseif mailType == -3 then
		return i3k_get_string(5439)
	elseif mailType == 78 then
		return i3k_get_string(17901)
	elseif mailType == 79 then
		return i3k_get_string(1690)
	elseif mailType == 81 then
		return i3k_get_string(18120)
	elseif mailType == 82 then
		return i3k_get_string(18121)
	elseif mailType == 83 then
		return i3k_get_string(18260)
	elseif mailType == 84 then
		return i3k_get_string(18277)
	elseif mailType == 85 then
		return i3k_get_string(1819)
	elseif mailType == 86 then
		return i3k_get_string(18569)
	elseif mailType == 87 then
		return i3k_get_string(18571)
	elseif mailType == 88 then
		return i3k_get_string(18573)
	elseif mailType == 89 then
		return i3k_get_string(18575)
	elseif mailType == 90 then
		return i3k_get_string(18579)
	elseif mailType == 91 then
		return i3k_get_string(18613)
	elseif mailType == 93 then
		local specialCardId = additional[2]
		local type = additional[1]
		local cfg = i3k_db_special_card[specialCardId]
		if type == 1 then
			return i3k_get_string(cfg.buyTip.title)
	 	else
	 		return i3k_get_string(cfg.outDateTip.title)
	 	end
	elseif mailType == 94 then
		return "美食节"
	elseif mailType == 95 then
		return i3k_get_string(5931)
	elseif mailType == 96 then
		return i3k_get_string(19050)
	elseif mailType == 97 then
		return i3k_get_string(19063)
	elseif mailType == 98 then
		return i3k_get_string(19065)
	elseif mailType == 99 then
		return i3k_get_string(19067)
	else
		return string.format("%s", "其他信件")
	end
end

function i3k_db_get_mail_content_text(mailType, additional, sendTime, content)
	if mailType==-1 then
		return i3k_get_string(233, i3k_db_dungeon_base[additional[1]].name)
	elseif mailType==3 then
		local date = os.date("%Y-%m-%d", g_i3k_get_GMTtime(sendTime))
		return i3k_get_string(224, i3k_db_get_common_item_name(additional[1]), date)
	elseif mailType==4 then
		local date = os.date("%Y-%m-%d", g_i3k_get_GMTtime(sendTime))
		return i3k_get_string(222, date, additional[1])
	elseif mailType==5 then
		return i3k_get_string(227, i3k_db_get_common_item_name(additional[1]))
	elseif mailType==6 then
		return i3k_get_string(229, i3k_db_get_common_item_name(additional[1]), additional[2], additional[3])
	elseif mailType==7 then
		return i3k_get_string(317, additional[1])
	elseif mailType==9 then
		return i3k_get_string(1665)
	elseif mailType==11 then
		return i3k_get_string(1564);
	elseif mailType == 12 then
		return i3k_get_string(697, content)
	elseif mailType == 13 then
		return i3k_get_string(705, math.floor(additional[1]/100))
	elseif mailType == 14 then
		local h = math.floor(additional[1]/3600);
		local m = math.modf(additional[1] % 3600 / 60)
		local s = math.modf(additional[1] % 3600 % 60)
		if h ~= 0 then
			m = h * 60 + m
		end
		local str1 = s == 0 and m .. "分钟" or m .. "分钟" .. s .. "秒"
		return i3k_get_string(707, str1, math.floor(additional[2]/100))
	elseif mailType == 15 then
		return i3k_get_string(709, math.floor(additional[1]/100), additional[2])
	elseif mailType == 16 then
		local h = math.floor(additional[1]/3600);
		local m = math.modf(additional[1] % 3600 / 60)
		local s = math.modf(additional[1] % 3600 % 60)
		if h ~= 0 then
			m = h * 60 + m
		end
		local str1 = s == 0 and m .. "分钟" or m .. "分钟" .. s .. "秒"
		return i3k_get_string(711, str1, math.floor(additional[3]/100), additional[2])
	elseif mailType == 17 then
		local date = os.date("%m月%d日", g_i3k_get_GMTtime(additional[1]))
		local str = {"中午", "傍晚", "夜晚"}
		return i3k_get_string(2000, date, str[additional[2]])
	elseif mailType == 18 then
		local arg = string.split(content, "|")
		return i3k_get_string(750, arg[1], arg[2])
	elseif mailType == 19 then
		return i3k_get_string(752)
	elseif mailType == 20 then
		local mapID = additional[1]
		local time = i3k_db_faction_rob_flag.faction_rob_flag.faction_award_time
		local h = math.floor(time/3600);
		local m = math.modf(time % 3600 / 60)
		local str1 = m == 0 and h .. "小时" or h .. "小时" .. m .. "分钟"
		return i3k_get_string(759, i3k_db_dungeon_base[mapID].desc, str1)
	elseif mailType == 21 then
		local mapID = additional[1]
		return i3k_get_string(763, i3k_db_dungeon_base[mapID].desc)
	elseif mailType == 22 then
		return i3k_get_string(15180,i3k_db_get_common_item_name(additional[1]),additional[2],additional[3],i3k_db_get_common_item_name(additional[1]),additional[4])
	elseif mailType == 23 then
		if additional[1] > 0 then
			return i3k_get_string(893,additional[1])
		else
			return i3k_get_string(894)
		end
	elseif mailType == 24 then
		if additional[1] > 0 then
			return i3k_get_string(905,additional[1])
		else
			return i3k_get_string(906)
		end
	elseif mailType == 25 then
		return i3k_get_string(3052, content)
	elseif mailType == 27 then  --带标题邮件 or 应用宝邮件
		return content or ""
	elseif mailType == 28 then -- 拜师成功邮件
		local arg = string.split(content, "|") --roleid|name
		return i3k_get_string(5006,arg[2])
	elseif mailType == 29 then -- 拒绝出师
		return i3k_get_string(5007)
	elseif mailType == 30 then -- 师傅获得的出师奖励
		local arg = string.split(content, "|")
		return i3k_get_string(5004,arg[2])
	elseif mailType == 31 then -- 徒弟获得的出师奖励
		return i3k_get_string(5005)
	elseif mailType == 32 then -- 被师傅除名
		local arg = string.split(content, "|") --roleid|name
		return i3k_get_string(5010,arg[2])
	elseif mailType == 33 then -- 充值排行奖励邮件
		return i3k_get_string(15449, additional[1])
	elseif mailType == 34 then -- 充值排行提醒邮件
		return i3k_get_string(15453, additional[1])
	elseif mailType == 35 then -- 消费排行奖励邮件
		return i3k_get_string(15451, additional[1])
	elseif mailType == 36 then -- 消费排行提醒邮件
		return i3k_get_string(15455, additional[1])
	elseif mailType == 37 then -- 帮派战结束奖励
		local battleState = additional[1]  --1胜，2平或负，3轮空
		if battleState == 1 then
			return i3k_get_string(1011)
		elseif battleState == 2 then
			return i3k_get_string(1013)
		elseif battleState == 3 then
			return i3k_get_string(1015)
		end
	elseif mailType == 38 then -- 帮派战排行帮主奖励
		return i3k_get_string(1017, additional[1])
	elseif mailType == 39 then -- 帮派战排行奖励
		return i3k_get_string(1019, additional[1])
	elseif mailType == 40 then --回归奖励
		return i3k_get_string(3128, content, additional[1], additional[1] * i3k_db_role_return.common.pay_rate / 10000)
	elseif mailType == 41 then --开心对对碰奖励
		return i3k_get_string(15584)
	elseif mailType == 42 then
		local petID = tonumber(additional[1])
		local petNameID = i3k_db_common.petRacePets[petID].name
		return i3k_get_string(16010, i3k_get_string(petNameID))
	elseif mailType == 43 then --国庆加油奖励
		return i3k_get_string(16381, additional[1])
	elseif mailType == 44 then --国庆加油幸运者奖励
		return i3k_get_string(16382, i3k_db_national_activity_cfg.lucky_dog_pos)
	elseif mailType == 45 then --龙运发奖
		local text = additional[1] == 1 and "超级" or "普通"
		return i3k_get_string(16762, text)
	elseif mailType == 46 then --驻地伏魔
		return i3k_get_string(16662)
	elseif mailType == 47 then --帮派红包退回
		return i3k_get_string(16720)
	elseif mailType == 49 then -- 拍卖会
		return i3k_get_string(16858)
	elseif mailType == 50 then -- 个人龙穴奖励
		return string.format("恭喜获得第%s名", additional[1])
	elseif mailType == 51 then -- 个人龙穴奖励
		return string.format("恭喜本帮获得第%s名", additional[1])
	elseif mailType == 52 then
		return i3k_get_string(5043, os.date("%Y年%m月%d日", g_i3k_get_GMTtime(additional[1])))
	elseif mailType == 53 then
		return i3k_get_string(5045, os.date("%Y年%m月%d日", g_i3k_get_GMTtime(additional[1])))
	elseif mailType == 54 then -- 福袋升级奖励
		return i3k_get_string(16998)
	elseif mailType == 54 then -- 福袋升级奖励
		return "限时任务奖励"
	elseif mailType == 56 then
		return i3k_get_string(17090)
	elseif mailType == 57 then --sectShare帮派仓库分享
		return i3k_get_string(1351)
	elseif mailType == 58 then --百万答题奖励
		if additional[1] == 0 then  --全部阵亡
			return i3k_get_string(17157)
		else
			return i3k_get_string(17156)
		end
	elseif mailType == 59 then --单人闯关buff奖励
		--local exploreId = additional[1]
		--local groupId = additional[2]
		--local buffId = additional[3]
		return i3k_get_string(17224)
	elseif mailType == 60 then --单人闯关通关奖励
		--local mapId = additional[1]
		return i3k_get_string(17225)
	elseif mailType == 61 then --世界杯
		return i3k_db_get_world_cup_mail_str(additional)
	elseif mailType == 62 then --家园邮件
		return "钓鱼奖励,请注意查收啊"
	elseif mailType == 63 then
		if additional[1] == 0 then
			return i3k_get_string(17295)
		else
			return string.format("您在本次棋局探索中排名%s, 获得以下奖励", additional[1])
		end
	elseif mailType == 64 then --城战周奖励邮件
		local cityID = additional[1]
		return i3k_get_string(5347, i3k_db_defenceWar_city[cityID].name)
	elseif mailType == 65 then --城战占城/夺城积分邮件
		local score = additional[1]
		if additional[2] == 1 then  --夺城
			return i3k_get_string(5253, score)
		else
			return i3k_get_string(5251, score)
		end
	elseif mailType == 66 then --伙伴邮件
		return string.format("充值返回红利")
	elseif mailType == 67 then --城战竞标结果邮件
		local cityID = additional[1]
		if additional[2] == 1 then  --竞标成功
			return i3k_get_string(5255, i3k_db_defenceWar_city[cityID].name)
		else
			return i3k_get_string(5257, i3k_db_defenceWar_city[cityID].name)
		end
	elseif mailType == 68 then --城战占城资格邮件
		return i3k_get_string(5172, i3k_db_defenceWar_cfg.factionLvl)
	elseif mailType == 69 then --登科有礼背包满时奖励
		return i3k_get_string(17447)
	elseif mailType == 70 then --驻地精灵
		local count = additional[1]
		return count > 0 and i3k_get_string(17477, count) or i3k_get_string(17476)
	elseif mailType == 71 then
		return "地毯家俱已回收，请查收道具"
	elseif mailType == 72 then
		return i3k_get_string(17642, g_i3k_game_context:GetRoleName(), additional[1])
	elseif mailType == 73 then
		return i3k_get_string(17644, g_i3k_game_context:GetRoleName(), additional[1])
	elseif mailType == 74 then
		return i3k_get_string(5432, i3k_get_string(additional[1]))
	elseif mailType == 75 then
		local cfg = i3k_db_five_contend_hegemony.npcRole
		if additional[1] == additional[2] then	
			return i3k_get_string(17861, cfg[additional[1]].name)
		else
			return i3k_get_string(17862, cfg[additional[1]].name)
		end
	elseif mailType == 76 then
		return i3k_get_string(17856)
	elseif mailType == -3 then
		return i3k_get_string(5440, i3k_db_dungeon_base[additional[1]].name)
	elseif mailType == 78 then
		local grade = additional[1]
		local name = i3k_db_marry_grade[grade].marryGradeName
		return i3k_get_string(17902, name)
	elseif mailType == 79 then
	elseif mailType == 81 then
		local score = additional[1]
		return i3k_get_string(18122, score)
	elseif mailType == 82 then
		return i3k_get_string(18123)
	elseif mailType == 83 then
		if additional[1] ~= 1 then
			return i3k_get_string(18261)
		else
			return i3k_get_string(18262)
		end
	elseif mailType == 84 then
		return i3k_get_string(18278)
	elseif mailType == 85 then
		local id = additional[1]
		local name = i3k_db_fightTeam_group_name[id].name
		return i3k_get_string(1820,name)
	elseif mailType == 86 then
		return i3k_get_string(18570)
	elseif mailType == 87 then
		return i3k_get_string(18572)
	elseif mailType == 88 then
		return i3k_get_string(18574)
	elseif mailType == 89 then
		return i3k_get_string(18576)
	elseif mailType == 90 then
		return i3k_get_string(18580)
	elseif mailType == 91 then
		if additional[1] == 0 then
			return i3k_get_string(18615)
		else
			return i3k_get_string(18614, i3k_db_catch_spirit_fragment[additional[2]].name)
		end
	elseif mailType == 92 then  
		--
	elseif mailType == 93 then
		local specialCardId = additional[2]
		local type = additional[1]
		local cfg = i3k_db_special_card[specialCardId]
		local outDayNum = additional[3]
		if type == 1 then
			return i3k_get_string(cfg.buyTip.content)
	 	else
	 		return i3k_get_string(cfg.outDateTip.content, cfg.name, outDayNum + 1)
	 	end
	elseif mailType == 94 then --美食节
		local rank = additional[1]
	elseif mailType == 95 then --焱脊
		local desc
		if additional[1] == 1  then --焱脊阵营arg1阵营arg2 胜负
			if additional[2] == 1  then
				desc = 5932
			else
				desc = 5934
			end
		else
			if additional[2] == 1 then
				desc = 5933
			else
				desc = 5935
			end
		end
		return i3k_get_string(desc)
	elseif mailType == 96 then
		return i3k_get_string(19051)
	elseif mailType == 97 then
		return i3k_get_string(19064)
	elseif mailType == 98 then
		return i3k_get_string(19066)
	elseif mailType == 99 then
		return i3k_get_string(19068)
	else
		return nil
	end
end

--获取宝石升级下级所需材料
function  i3k_db_get_gem_need_info(gemId)
	local gemCfg = i3k_db_get_gem_item_cfg(gemId)
	local temp = {}
	table.insert(temp, {id = g_BASE_ITEM_GEM_ENERGY, count = gemCfg.upgrade_consume_energy})
	for i=1, 2 do
		local itemId = string.format("update_consume%s_id", i)
		local itemCount = string.format("update_consume%s_count", i)
		if gemCfg[itemId] ~= 0 then
			table.insert(temp, {id = gemCfg[itemId], count = gemCfg[itemCount]})
		end
	end
	return temp, gemCfg.updated_id, gemCfg.level
end

--获取同类型所有宝石
function i3k_db_get_gem_from_type(gemType)
	local tmp = {}
	for i, e in pairs(i3k_db_diamond) do
		if e.type == gemType then
			table.insert(tmp, e)
		end
	end
	table.sort(tmp, function(a, b)
		return a.level < b.level
	end)
	return tmp
end



--获取属性名字
function i3k_db_get_property_name(id)
	return i3k_db_prop_id[id].desc or ""
end

--获取属性icon
function i3k_db_get_property_icon(id)
	return i3k_db_prop_id[id].icon or 144
end

--获取装备类别
function i3k_db_get_equip_type(id)
	local db = i3k_db_equips[math.abs(id)]
	return i3k_db_equip_part[db.partID]
end

--获取装备所需职业
function i3k_db_get_equip_occupation(id)
	local db = i3k_db_equips[math.abs(id)]
	return i3k_db_generals[db.roleType]
end

--获取装备转职需求
function i3k_db_get_equip_trans(id)
	local db = i3k_db_equips[math.abs(id)]
	return db and db.C_require
end

-- 获取装备正邪需求
function i3k_db_get_equip_bwtype(id)
	local db = i3k_db_equips[math.abs(id)]
	return db and db.M_require
end

--获取装备强化组
function i3k_db_get_equip_streng_group(id)
	local db = i3k_db_equip_part[math.abs(id)]
	return db and db.equipStreng
end

--获取装备升星组
function i3k_db_get_equip_upStar_group(id)
	local db = i3k_db_equip_part[math.abs(id)]
	return db and db.equipUpStar
end

--获取寄售行最高单价
function i3k_db_get_auction_max_price(id)
	local db = i3k_db_get_common_item_cfg(math.abs(id))
	return db and db.auction_max_price
end

--获取寄售行推荐价格
function i3k_db_get_auction_recommend_price(id)
	local db = i3k_db_get_common_item_cfg(math.abs(id))
	return db and db.RecommendPrice
end

--获取寄售行物品类型
function i3k_db_get_auction_item_type(id)
	local db = i3k_db_get_common_item_cfg(id)
	if db then
		return db.auction_type or db.partID
	end
end

--获取音效路径
function i3k_db_get_sound_path(id)
	local db = i3k_db_sound[id]
	return db and db.path or ""
end

--获取技能显示信息
function i3k_db_get_skill_info(skillId)
	local role_type = g_i3k_game_context:GetRoleType()
	local class_info1 = i3k_db_zhuanzhi[role_type][1][0]
	local class_info2 = i3k_db_zhuanzhi[role_type][2][1]
	local class_info3 = i3k_db_zhuanzhi[role_type][2][2]
	local class_info4 = i3k_db_zhuanzhi[role_type][3][1]
	local class_info5 = i3k_db_zhuanzhi[role_type][3][2]
	local class_info6 = i3k_db_zhuanzhi[role_type][4][1]
	local class_info7 = i3k_db_zhuanzhi[role_type][4][2]
	local class_info8 = i3k_db_zhuanzhi[role_type][5][1]
	local class_info9 = i3k_db_zhuanzhi[role_type][5][2]
	if skillId == class_info1.skill1 or skillId == class_info1.skill2 then
		return string.format("一转")
	elseif skillId == class_info2.skill1 or skillId == class_info2.skill2 then
		return string.format("二转正")
	elseif skillId == class_info3.skill1 or skillId == class_info3.skill2 then
		return string.format("二转邪")
	elseif skillId == class_info4.skill1 or skillId == class_info4.skill2 then
		return string.format("三转正")
	elseif skillId == class_info5.skill1 or skillId == class_info5.skill2 then
		return string.format("三转邪")
	elseif skillId == class_info6.skill1 or skillId == class_info6.skill2 then
		return string.format("四转正")
	elseif skillId == class_info7.skill1 or skillId == class_info7.skill2 then
		return string.format("四转邪")
	elseif skillId == class_info8.skill1 or skillId == class_info8.skill2 then
		return string.format("五转正")
	elseif skillId == class_info9.skill1 or skillId == class_info9.skill2 then
		return string.format("五转邪")
	else
		return ""
	end
end

--获取属性奖励达成个数
function i3k_db_get_property_reward_count(strengType)
	local temp = {}
	local _tp = {}
	local inlay = {}
	local wEquips = g_i3k_game_context:GetWearEquips()
	for k,v in ipairs (i3k_db_common_award_property) do
		if v.type == strengType and  strengType == 1 then
			local items = {}
			for i=1, i3k_db_common.equip.equipPropCount do
				if wEquips[i].equip and wEquips[i].eqGrowLvl >= v.args then
					items[i] = true
				end
			end
			temp[v.args] = items
		elseif v.type == strengType and  strengType == 2 then
			local items = {}
			for i=1, i3k_db_common.equip.equipPropCount do
				if wEquips[i].equip and wEquips[i].eqEvoLvl >= v.args then
					items[i] = true
				end
			end
			_tp[v.args] = items
		elseif v.type == strengType and strengType == 3 then
			local items = {}
			local slotCount = 0
			for i=1, i3k_db_common.equip.equipPropCount do
				local slot = wEquips[i].slot
				if wEquips[i].equip then
					for j, e in pairs(slot) do
						local diamondCfg = g_i3k_db.i3k_db_get_gem_item_cfg(e)
						if diamondCfg and diamondCfg.level >= v.args then
							slotCount = slotCount + 1
						end
					end
					if slotCount == 4 then
						items[i] = true
					end
					slotCount = 0
				end
			end
			inlay[v.args] = items
		end
	end
	if strengType == 1 then
		return temp
	elseif strengType == 2 then
		return _tp
	elseif strengType == 3 then
		return inlay
	end
end

function i3k_db_get_property_reward_tag(strengType, lvl)
	local tag = nil
	for k,v in ipairs (i3k_db_common_award_property) do
		if v.type == strengType then
			if lvl < v.args then
				break
			end

			tag = "+" .. v.args
		end
	end

	return tag
end

--获取角色装备所有强化等级
function i3k_db_get_role_allStreng_level()
	local wearEquip = g_i3k_game_context:GetWearEquips()
	local allStrengLevel = 0
	for i=1, i3k_db_common.equip.equipPropCount do
		if wearEquip[i].equip and g_i3k_game_context:GetEquipStrengLevel(i) then
			allStrengLevel = allStrengLevel + g_i3k_game_context:GetEquipStrengLevel(i)
		end
	end
	return allStrengLevel
end

function i3k_db_get_streng_reward_info_for_type(sCount)
	local temp = {}
	local fId = {}
	local rCount = {}
	for nType = sCount or 1, sCount or 3 do
		local fCount = 0
		local cfg = i3k_db_get_property_reward_count(nType)
		for _,v in ipairs (i3k_db_common_award_property) do
			if v.type == nType then
				fCount = fCount + 1
				if table.nums(cfg[v.args]) == 6 or fCount == 1 then
					fId[nType] = v.id
					rCount[nType] = table.nums(cfg[v.args])
				end
				if sCount then
					if table.nums(cfg[v.args]) ~= 6 then
						fId[nType] = v.id
						rCount[nType] = table.nums(cfg[v.args])
						break
					end
				end
			end
		end
		if sCount then
			if not fId[sCount] then
				for _,v in ipairs(i3k_db_common_award_property) do
					if table.nums(cfg[v.args]) == 6 then
						fId[nType] = v.id
						rCount[nType] = table.nums(cfg[v.args])
					end
				end
			end
		end
	end

	for nType = sCount or 1, sCount or 3 do
		local data = {}
		for _,v in ipairs (i3k_db_common_award_property) do
			if v.type == nType then
				for i=1, 4 do
					local proID = string.format("pro%sID",i)
					local proValue = string.format("pro%sValue",i)
					local property = v[proID]
					local propertyValue = v[proValue]
					if property ~= 0 then
						if data[property] then
							data[property] = { id = property, value = data[property].value + propertyValue}
						else
							data[property] = { id = property, value = propertyValue}
						end
					end
				end
				if v.id == fId[nType] then
					temp[nType] = {desc = v.desc, count = rCount[nType], cfg = v, property = sCount and {} or data}
					break
				end
			end
		end
	end
	return temp
end

function i3k_db_get_pets_is_auto_revive()
	local mapType = i3k_game_get_map_type()
	return mapType and mapType ==g_FIELD or mapType==g_BASE_DUNGEON or mapType==g_ACTIVITY or mapType == g_TOWER or mapType == g_TOURNAMENT
end

--判断使用礼物包时背包格子是否可用 num--礼物包的个数
function i3k_db_get_open_gift_is_enough(id, num)
	local tmp = {}
	local itemsData = {}
	local giftID = g_i3k_db.i3k_db_get_other_item_cfg(id).args1
	local cfg = i3k_db_gift_bag[giftID]
	if cfg and cfg.giftInfo then
		for i, v in ipairs(cfg.giftInfo) do
			local gid = v.itemID
			local gcount = v.itemCount
			if gid and gcount then
				if gid == g_BASE_ITEM_DIAMOND or  gid == -g_BASE_ITEM_DIAMOND or gid == g_BASE_ITEM_COIN or gid == -g_BASE_ITEM_COIN then
					itemsData[gid] = gcount * num
				else
					if gid ~= 0 then
						local count = tmp[gid]
						count = count and count + gcount or gcount
						tmp[gid] = count * num

						local count2 = itemsData[gid]
						count2 = count2 and count2 + gcount or gcount
						itemsData[gid] = count2 * num
					end
				end
			end
		end
	end
	return g_i3k_game_context:IsBagEnough(tmp), itemsData
end

--获得使用物品获得道具信息
function i3k_db_get_use_item_gain_item(id, useCount)
	local gainItems = {}
	local itemCfg = i3k_db_get_other_item_cfg(id)
	if itemCfg.type == UseItemDiamond then
		local itemid = itemCfg.args2 == 1 and -g_BASE_ITEM_DIAMOND or g_BASE_ITEM_DIAMOND
		table.insert(gainItems, {id = itemid, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemCoin then
		local itemid = itemCfg.args2 == 1 and -g_BASE_ITEM_COIN or g_BASE_ITEM_COIN
		table.insert(gainItems, {id = itemid, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemGift then
		local isEnough, giftItems = i3k_db_get_open_gift_is_enough(id, useCount)
		for k, v in pairs(giftItems) do
			table.insert(gainItems, {id = k, count = v})
		end
	elseif itemCfg.type == UseItemEquipEnergy then
		table.insert(gainItems, {id = g_BASE_ITEM_EQUIP_ENERGY, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemGemEnergy then
		table.insert(gainItems, {id = g_BASE_ITEM_GEM_ENERGY, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemBookSpiration then
		table.insert(gainItems, {id = g_BASE_ITEM_BOOK_ENERGY, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemVit then
		table.insert(gainItems, {id = g_BASE_ITEM_VIT, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemExp then
		table.insert(gainItems, {id = g_BASE_ITEM_EXP, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemWeaponSoul then
		table.insert(gainItems, {id = g_BASE_ITEM_WEAPONSOUL, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemSpiritBoss then
		table.insert(gainItems, {id = g_BASE_ITEM_SPIRIT_BOSS, count = itemCfg.args1 * useCount})
	elseif itemCfg.type == UseItemRegular then
		table.insert(gainItems, {id = g_i3k_db.i3k_db_get_reward_items_id(), count = itemCfg.args2 * useCount})
	elseif itemCfg.type == UseItemNewPower then
		table.insert(gainItems, {id = i3k_db_power_reputation[itemCfg.args1].itemID, count = itemCfg.args2 * useCount})
	end
	return gainItems
end

--获取是否显示消耗锁
function i3k_db_get_consume_lock_visible(id)
	return id == g_BASE_ITEM_DIAMOND or id == g_BASE_ITEM_COIN
end

--获取品质边框是否隐藏
function i3k_db_get_rank_border_Hide(id)
	return g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_DIY_TEXT_TITLE
end
--装备能量 宝石能量 悟性不显示锁头（礼包，任务奖励界面，其他待添加界面）
function i3k_db_get_reward_lock_visible(id)
	if id == g_BASE_ITEM_EQUIP_ENERGY or id == g_BASE_ITEM_GEM_ENERGY or id == g_BASE_ITEM_BOOK_ENERGY or id == g_BASE_ITEM_VIT  or id == g_BASE_ITEM_EXP or id==g_BASE_ITEM_VIP or id == g_BASE_ITEM_FEISHENG_EXP then
		return false
	else
		return id > 0
	end
end

--获取正邪描述
function i3k_db_get_transfer_desc()
	local transfer = g_i3k_game_context:GetTransformBWtype()
	if transfer == 0 then
		return string.format("中立"), string.format("ff23c3ff")
	elseif transfer == 1 then
		return string.format("正派"), string.format("fffbea5e")
	elseif transfer == 2 then
		return string.format("邪派"), string.format("fff13010")
	end
end

--获取时装配置
function i3k_db_get_fashion_cfg(id)
	return i3k_db_fashion_dress[id < 0 and -id or id]
end

--获取时装表现配置
function i3k_db_get_fashion_reflect(id)
	return i3k_db_fashion_reflect[id]
end

--根据时装类型获取所有的时装信息
function i3k_db_get_fashion_from_type(showType)
	local tmp = {}
	for i, e in pairs(i3k_db_fashion_dress) do
		if e.isOpen ~= 0 then
			if e.fashionType == 1 then
				if e.fashionType == showType then
					if i3k_db_get_is_show_form_gameAppID(e) then
						table.insert(tmp, e)
					end
				end
			else
				if (e.sex == 0 and showType ~= 1) or e.fashionType == showType then
					if i3k_db_get_is_show_form_gameAppID(e) then
						table.insert(tmp, e)
					end
				end
			end
		end
	end

	return tmp
end

--根据人物当前性别和时装性别
function i3k_db_get_fashion_by_sex(id)
	local fashionSex = i3k_db_fashion_dress[id].sex
	local gender = g_i3k_game_context:GetRoleGender()
	if fashionSex == 0 or fashionSex == gender then
		return true;
	end
	return false
end

function i3k_db_get_is_show_form_gameAppID(cfg)
	local gameAppID = i3k_get_gameAppID()
	for i, e in ipairs(cfg.appIdIsShow) do
		if gameAppID == e then
			return false
		end
	end
	return true
end

--判断是否已激活改时装
function i3k_db_get_fashion_is_have(fashionID)
	local allFashion = g_i3k_game_context:GetAllFashions()
	for i, v in ipairs(allFashion) do
		if v.id == fashionID then
			return true
		end
	end
	return false
end

--判断改时装是否正在装备
function i3k_db_get_fashion_is_wear(fashionID)
	local curFashion = g_i3k_game_context:GetWearFashionData()
	local cfg = i3k_db_get_fashion_cfg(fashionID)
	return curFashion[cfg.fashionType] == fashionID
end

function i3k_db_get_flying_is_wear()
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	local limit_level = 6
	if flyingLevel >= limit_level then
		return true
	end
	return false
end
--获取时装属性
function i3k_db_get_fashion_property(fashionID)
	local tmp = {}
	local cfg = i3k_db_get_fashion_cfg(fashionID)
	for i=1, 4 do
		local proId = string.format("property%sId", i)
		local proValue = string.format("property%sValue", i)
		local propertyId = cfg[proId]
		local propertyValue = cfg[proValue]
		if propertyId ~= 0 and propertyValue ~= 0 then
			tmp[propertyId] = propertyValue
		end
	end
	return tmp
end

--判断是否显示购买按钮
function i3k_db_get_isShow_btn(id)
	local tmp = {}
	local tab = {i3k_db_new_item, i3k_db_base_item}
	for i=1, #tab do
		for k,v in pairs(tab[i]) do
			if math.abs(id) == k and v.showBuyBtn == 1 then
				tmp.showBuyBtn = v.showBuyBtn
				tmp.isBound = v.isBound
				tmp.showType = v.showType
				tmp.showLevel = v.showLevel
				tmp.id = v.id
				break
			end
		end
	end
	if next(tmp) then
		return tmp
	end
	return false
end

--获取战力方法()
-- is_desert 是否是决战荒漠计算战力
function i3k_db_get_battle_power(db, need_convert, is_pet, is_desert)
	--need_convert : 是否需要转换，针对 10000代表100%的属性，会将整数转化为实际值
	local power = 0
	for i,v in pairs(i3k_db_prop_id) do
		local plus = is_pet and v.plusPet or v.plusRole
		if is_desert then
			plus = v.plusDesert
		end
		if db[i] and plus ~= 0 then
			local val = db[i]
			if need_convert and i3k_db_prop_id[i].txtFormat == 1 then
				val = val / 10000
			end
			power = plus * val + power
		end
	end
	return math.floor(power)
	--[[local hp           = db[ePropID_maxHP] or 0 --气血
	local atk          = db[ePropID_atkN] or 0 --攻击
	local def          = db[ePropID_defN] or 0 --防御
	local aim          = db[ePropID_atr] or 0 --命中
	local dodge        = db[ePropID_ctr] or 0 --躲闪
	local cri          = db[ePropID_acrN] or 0 --暴击
	local res          = db[ePropID_tou] or 0 --韧性
	local god_dmg      = db[ePropID_atkH] or 0 --神圣伤害
	local xinfa_dmg    = db[ePropID_atkC] or 0 --心法伤害
	local xinfa_def    = db[ePropID_defC] or 0 --心法防御
	local weapon_dmg   = db[ePropID_atkW] or 0 --神兵伤害
	local weapon_def   = db[ePropID_defW] or 0 --神兵防御
	local dmg_increase = db[ePropID_mercenarydmgTo] or 0 --伤害提升
	local dmg_decrease = db[ePropID_mercenarydmgBy] or 0 --受伤害减少
	local internal_force = db[ePropID_internalForces] or 0 --内力
	local dex            = db[ePropID_dex] or 0 --身法
	power = 2*(atk + def) + 0.223 * hp + 0.9*(god_dmg + xinfa_dmg + xinfa_def + weapon_dmg + weapon_def) + 4 * (aim + dodge + cri + res) + 138 * dmg_increase + 483 * dmg_decrease + 3 * (internal_force + dex)
	return math.floor(power)--]]
end

--通过配置获取装备基础属性
function i3k_db_get_equip_base_property(id)
	local tmp = {}
	local cfg = i3k_db_get_equip_item_cfg(id)
	local properties = cfg.properties
	for i, e in pairs(properties) do
		if e.type ~= 0 and e.value ~= 0 then
			table.insert(tmp, {id = e.type, value = e.value})
		end
	end
	return tmp
end

function i3k_db_is_private_dungeon(mapId)
	if i3k_db_new_dungeon[mapId] then
		return i3k_db_new_dungeon[mapId].openType == 0
	end

	return false
end

--判断当前副本是否可进入
function i3k_db_get_dungeon_can_enter(mapId)
	local db = i3k_db_new_dungeon[mapId]
	return db and true or (i3k_game_get_time() >= g_i3k_get_day_time(db.startTime) and i3k_game_get_time() <= g_i3k_get_day_time(db.endTime))
end

--获取副本开启时间
function i3k_db_get_dungeon_start_time(mapId)
	local startTime = i3k_db_new_dungeon[mapId].startTime
	local hour = math.modf(startTime/3600)
	local minute = math.modf(startTime%3600/60)
	local second = math.modf(startTime-hour*3600-60*minute)
	hour = hour == 0 and string.format("00") or hour
	minute = minute == 0 and string.format("00") or minute
	second = second == 0 and string.format("00") or second
	return string.format("%s:%s:%s", hour, minute, second)
end

--一键装备时非绑定的装备的描述
function i3k_db_get_free_equip_desc(best_equip)
	local str = ""
	for k, v in pairs(best_equip) do
		if k < 0 then
			str = str == "" and string.format("%s", i3k_db_get_common_item_name(k)) or string.format("%s，%s", str, i3k_db_get_common_item_name(k))
		end
	end
	return str
end

--获取属性对应显示图标
function i3k_db_get_property_icon_path(id)
	local db = i3k_db_prop_id[id]
	return db and i3k_db_get_icon_path(db.icon) or ""
end

--获取好友受赠奖励数据
function i3k_db_get_friends_award(id)
	return i3k_db_friends_award[id]
end

--获取头像设置表
function i3k_db_get_friends_icon()
	return i3k_db_personal_icon
end

function i3k_db_get_general_class_icon(gclass)
	local db = i3k_db_generals[gclass];
	if db then
		return i3k_db_get_icon_path(db.classImg);
	end

	return '';
end

--通过魅力值获取魅力等级和称号
function i3k_db_get_charm_name(value, gender)
	if value <= i3k_db_charm_name[1].charmValue then
		local cfg = i3k_db_charm_name[1]
		local needValue = value < i3k_db_charm_name[1].charmValue and i3k_db_charm_name[1].charmValue or i3k_db_charm_name[2].charmValue - cfg.charmValue
		local level = value == i3k_db_charm_name[1].charmValue and 2 or 1
		local tmp = value < i3k_db_charm_name[1].charmValue and i3k_db_charm_name[1] or i3k_db_charm_name[2]
		local titleCfg = gender == 1 and i3k_db_title_base[tmp.menNameId] or i3k_db_title_base[tmp.womenNameId]
		return level, needValue, titleCfg
	end
	for i = 1, #i3k_db_charm_name do
		local cfg = i3k_db_charm_name[i]
		local nextCfg = i3k_db_charm_name[i+1]
		local titleCfg = gender == 1 and i3k_db_title_base[cfg.menNameId] or i3k_db_title_base[cfg.womenNameId]
		if not nextCfg then
			return #i3k_db_charm_name, i3k_db_charm_name[#i3k_db_charm_name].charmValue, titleCfg
		end
		if value > cfg.charmValue and value < nextCfg.charmValue then
			return i+1, nextCfg.charmValue - cfg.charmValue, titleCfg
		elseif value == cfg.charmValue then
			return i+1, nextCfg.charmValue - cfg.charmValue, titleCfg
		end
	end
end

--根据现在魅力值获取当前等级的魅力值
function i3k_db_get_now_charm_value(value)
	if value < i3k_db_charm_name[1].charmValue then
		return value
	end
	if value >= i3k_db_charm_name[#i3k_db_charm_name].charmValue then
		return i3k_db_charm_name[#i3k_db_charm_name].charmValue
	end
	for i = 1, #i3k_db_charm_name do
		local cfg = i3k_db_charm_name[i]
		if value - cfg.charmValue < 0 then
			return value - i3k_db_charm_name[i-1].charmValue
		end
	end
end

--获取随从可到达的最大等级
function i3k_db_pet_can_up_level(id)
	local transfer = g_i3k_game_context:getPetTransfer(id)
	local need_lvl = 0
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	if trs_cfg then
		need_lvl = trs_cfg.maxLvl
		local roleLvl = g_i3k_game_context:GetLevel()
		return math.min(need_lvl, g_i3k_game_context:GetLevel())
	else
		need_lvl = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer).maxLvl
		return math.max(need_lvl, g_i3k_game_context:GetLevel())
	end
end

--获取随从元宝升级所需的元宝数
function i3k_db_get_pet_need_diamond(id, level)
	local nowLvl = g_i3k_game_context:getPetLevel(id)
	local totalDiamond = 0
	for i = nowLvl + 1, level do
		totalDiamond = totalDiamond + i3k_db_get_pet_uplvl_cfg(i).diamondCount
	end
	return totalDiamond
end

--获取副本id
function i3k_db_get_finish_dungeon_id(mapId)
	local dungeon_cfg_data = g_i3k_game_context:GetCacheDungeonCfgData()
	local groupCfg = {}
	for k, v in ipairs(dungeon_cfg_data) do
		if k == i3k_db_new_dungeon[mapId].teamid then
			groupCfg = v
		end
	end
	local tb = {}
	for k, v in pairs(groupCfg) do
		table.insert(tb, {diff = k})
	end
	table.sort(tb, function (a, b)
		return a.diff < b.diff
	end)
	return i3k_db_new_dungeon[mapId].difficulty ~= tb[#tb].diff
end

--装备特效id是否被玩家设置过(幻灵系统)
function i3k_db_get_equip_effect_id_show(equipId, roleType, pos, qLv, starlvl, effectInfo)
	if pos == eEquipWeapon and effectInfo and effectInfo.evoLvl > 0 then
		starlvl = effectInfo.evoLvl
	end
	return i3k_db_get_equip_effect_id(equipId, roleType, pos, qLv, starlvl)
end

--通过部位强化升星等级获取装备特效ID
function i3k_db_get_equip_effect_id(equipId, roleType, pos, qLv, starlvl)
	local tmp = {}
	local effectIds = {}
	for i = 1, #i3k_db_equip_effect do
		local cfg = i3k_db_equip_effect[i]
		if roleType == cfg.classType and cfg.posType == pos then
			if qLv >= cfg.strengLower and qLv <= cfg.strengUpper and starlvl >= cfg.starLower and starlvl <= cfg.starUpper and equipId then
				table.insert(tmp, cfg)
			end
		end
	end
	for i, e in pairs(tmp) do
		--[[local equips = g_i3k_game_context:GetWearEquips()
		if equips[pos] then--]]
			local level = i3k_db_get_common_item_level_require(equipId)
			local levelTable = i3k_db_equip_effect[i].levelTable
			for index, v in ipairs(levelTable) do
				if levelTable[index+1] and level>=v and level<levelTable[index+1] then
					local effectId1 = e.effectIdTable[index]~=0 and e.effectIdTable[index] or false
					local effectId2 = e.effectIdTable2[index]~=0 and e.effectIdTable2[index] or false
					if effectId1 then
						effectIds[effectId1] = true
					end
					if effectId2 then
						effectIds[effectId2] = true
					end
					return effectIds
				end
			end
		--end
	end
	return false
end

--获取当前离线经验的最大值
function i3k_db_get_offline_max_exp()
	local curLvl = g_i3k_game_context:GetLevel()
	local baseExp = i3k_db_exp[curLvl].offlineExp
	local multiples = i3k_db_offline_exp.multiples
	local maxLongTime = i3k_db_offline_exp.maxLongTime
	return baseExp * multiples * maxLongTime
end

function i3k_db_get_hero_skill_translevel(id,skillid)
	local cfg = i3k_db_generals[id]
	if cfg then
		for k,v in pairs(cfg.attacks) do
			if v == skillid then
				return 0;
			end
		end
		for k,v in pairs(cfg.skills) do
			if v == skillid then
				return 0;
			end
		end
		if cfg.dodgeSkill == skillid then
			return 0;
		end
	end
	local cfg = i3k_db_zhuanzhi[id]
	if cfg then
		for k,v in pairs(cfg) do
			for k1,v1 in pairs(v) do
				if v1.skill1 == skillid or v1.skill2 == skillid then
					return k
				end
			end
		end
	end
	return -1;
end

--获取pk系统配置
function i3k_db_get_pk_cfg(pkValue)
	local tb= i3k_db_pkpunish
	table.sort(tb, function (a,b)
		return a.upline < b.upline
	end)
	local pkData = {}
	for k, v in pairs(tb) do
		table.insert(pkData, v)
	end
	local cfg
	for i = 1, #pkData do
		if pkValue <= pkData[i].upline then
			cfg = pkData[i]
			break
		end
	end
	return cfg
end

-- 限制使用高级挂机善恶值
function i3k_db_get_limit_superonhook_pk_value()
	local limitSuperOnHookPKValue = i3k_db_common.autoFight.limitSuperOnHookPKValue
	return limitSuperOnHookPKValue
end

--获取参悟的配置
function i3k_db_get_canwu_args(id, lvl)
	return i3k_db_experience_canwu[id][lvl]
end

--获取模型的path路径
function i3k_db_get_model_path(id)
	return i3k_db_models[id] and i3k_db_models[id].path or ""
end

--获取称号的类型（永久或时效）
function i3k_db_get_roleTitle_type(time, myProfession)
	local isHave = g_i3k_game_context:GetAllRoleTitle()
	--[[
	local tmpTime = {}
	local tmpForever = {}
	for k,v in ipairs(i3k_db_title_base) do
		if v.time > 0 then
			table.insert(tmpTime, v)
		else
			table.insert(tmpForever, v)
		end
		if isHave then

		else

		end
	end]]
	local tmp = i3k_db_title_base
	local newTmp1 = {}
	local newTmp2 = {}
	if isHave then
		local index = 0
		local newIndex = 0
		--for k,v in pairs(isHave) do
			for i,j in pairs(i3k_db_title_base) do
				if isHave[j.id] == nil and (j.professionTitle == 0 or myProfession == j.professionTitle) then
					index = index + 1
					newTmp1[index] = j
				elseif isHave[j.id] then
					newIndex = newIndex + 1
					newTmp2[newIndex] = j
				end
			end
		--end
		if time > 0 then
			return newTmp2
		else
			return newTmp1
		end
	else
		if time > 0 then
			return nil
		else
			return tmp
		end
	end

end

--获取当前id是否是永久称号
function i3k_db_is_permanent_title(id)
	for k,v in pairs(i3k_db_title_base) do
		if id == v.id then
			if v.time < 0 then
				return 1
			end
		end
	end
	return 0
end

function i3k_db_get_fromTask_info(petID, taskID)
	return i3k_db_from_task[petID][taskID]
end

--获取上一个身世任务的信息
function i3k_db_get_last_fromTask_info(petID,taskID)
	if taskID == 0 then
		return nil
	end
	if taskID == i3k_db_from_task[petID][1].taskID then
		return nil
	end
	local tmp = {}
	for k,v in ipairs(i3k_db_from_task[petID]) do
		if taskID == v.taskID then
			tmp.petID = i3k_db_from_task[petID][k-1].petID
			tmp.taskID = i3k_db_from_task[petID][k-1].taskID
			return tmp
		end
	end
end

--获取下一个身世任务的信息
function i3k_db_get_next_fromTask_info(petID, taskID)
	local tmp = {}
	for k,v in ipairs(i3k_db_from_task[petID]) do
		if taskID == v.taskID then
			tmp.petID = i3k_db_from_task[petID][k+1].petID
			tmp.taskID = i3k_db_from_task[petID][k+1].taskID
			return tmp
		end

	end

end

--根据怪物等级获取怪物等级颜色
function i3k_db_get_monster_level_color(level)
	local roleLvl = g_i3k_game_context:GetLevel()
	local diff = roleLvl - level
	local info = {}
	for i, e in pairs(i3k_db_boss_level_color) do
		table.insert(info, e)
	end
	table.sort(info, function(a, b)
		return a.lowerLevel < b.lowerLevel
	end)
	for i, e in pairs(info) do
		if diff <= e.lowerLevel then
			return e.textColor
		end
	end
end

function i3k_db_get_roll_notice_text(noticeType, arg)
	local cfg = i3k_db_roll_notice[noticeType]
	if cfg then
		local str = cfg.text
		if noticeType==5 then--转职
			local transName = i3k_db_zhuanzhi[tonumber(arg[3])][tonumber(arg[4])][tonumber(arg[2])].name
			local typeStr = ""
			if tonumber(arg[2])==1 then
				typeStr = "正派"
			elseif tonumber(arg[2])==2 then
				typeStr = "邪派"
			end
			str = string.format(str, arg[1], typeStr, transName)
		elseif noticeType==6 or noticeType==7 or noticeType==4 or noticeType==12 then--4:装备强化、6:创建帮派、7:帮派升级、12:结婚公告
			str = string.format(str, arg[1], arg[2])
		elseif noticeType == 3 then--装备升星
			local equips = g_i3k_game_context:GetWearEquips()
			local index  = tonumber(arg[2])
			local equipId = equips[index] and equips[index].equip and equips[index].equip.equip_id
			local name = equipId and i3k_db_equips[equipId].name or ""
			str = string.format(str, arg[1], name, arg[3])
		elseif noticeType == 1 then--坐骑升星
			local index  = tonumber(arg[2])
			local huanhuaID = i3k_db_steed_cfg[index].huanhuaInitId
			local name = i3k_db_steed_huanhua[huanhuaID].name
			str = string.format(str, arg[1], name, arg[3])
		elseif noticeType == 2 then--神兵升星
			local index  = tonumber(arg[2])
			local name = i3k_db_shen_bing[index].name or ""
			str = string.format(str, arg[1], name, arg[3])
		elseif noticeType == 8 then--随从升星
			local id = tonumber(arg[2])
			local name = i3k_db_mercenaries[id] and i3k_db_mercenaries[id].name
			str = string.format(str, arg[1], name, arg[3])
		elseif noticeType == 9 then--发布布告
			str = string.format(str, arg[1] ~= "" and arg[1] or i3k_get_string(1555))
		elseif noticeType == 10 then --刷新世界BOSS
			local bossNameStr
			for i,v in ipairs(arg) do
				if i~=#arg then
					local name = i3k_db_world_boss[tonumber(v)].name
					bossNameStr = bossNameStr or string.format(name)
					if i~=1 then
						bossNameStr = string.format("%s、%s", bossNameStr, name)
					end
				end
			end
			--bossNameStr = "<t=1>"..bossNameStr.."</c></t>"
			str = string.format(str, bossNameStr)
		elseif noticeType == 11 then --世界BOSS被击杀
			local bossId = tonumber(arg[1])
			local bossName = i3k_db_world_boss[bossId].name
			str = string.format(str, bossName, arg[2])
		elseif noticeType == 16 then -- 燃放烟花
			local mapName = i3k_db_dungeon_base[tonumber(arg[2])].desc
			local fireworkName = g_i3k_db.i3k_db_get_common_item_name(tonumber(arg[3]))
			str = string.format(str, arg[1], fireworkName)
		elseif noticeType >=18 and  noticeType <=21 then -- 抢红包
			str = string.format(str, arg[1])
			if g_i3k_game_context:GetLevel() < i3k_db_grab_red_envelope.startLevel then
				str = str..i3k_get_string(15345, i3k_db_grab_red_envelope.startLevel)
			end
		elseif noticeType == 22 then --竞技场获得第一名
			str = string.format(str, arg[1])
		elseif noticeType == 23 then --竞技场前两千名，获得胜利
			str = string.format(str, arg[1], arg[2], arg[3])
		elseif noticeType == 24 then --副本中获得橙装
			local mapName = i3k_db_dungeon_base[tonumber(arg[2])].name
			local monsterName = i3k_db_get_monster_name(tonumber(arg[3]))
			local equipName = i3k_db_get_common_item_name(tonumber(arg[4]))
			str = string.format(str, arg[1], mapName, monsterName, equipName)
		elseif noticeType == 25 then -- 帮派夺旗
			local sectName = arg[1]
			local mapName = i3k_db_dungeon_base[tonumber(arg[2])].name
			str = string.format(str, sectName, mapName)
		elseif noticeType == 26 then
			local mapName = i3k_db_dungeon_base[tonumber(arg[3])].name
			str = string.format(str, arg[2], mapName,arg[4])
		elseif noticeType == 27 then
			local mapName = i3k_db_dungeon_base[tonumber(arg[2])].name
			local npcName = i3k_db_npc[tonumber(arg[1])].remarkName
			str = string.format(str, npcName, mapName)
		elseif noticeType == 28 then
			str = string.format(str, tonumber(arg[1]))
		elseif noticeType == 29 then -- 传世装备
			local equipCfg = i3k_db_get_equip_item_cfg(tonumber(arg[3]))
			local equipName = equipCfg.name
			local color = i3k_db_get_legendEquip_color(equipCfg)
			str = string.format(str, color)
			str = string.format(str, arg[1],  equipName)
		elseif noticeType == 30 then
			str = string.format(str, arg[1], i3k_db_common.pk.reducePkNum)
		elseif noticeType == 31 then
			local mineCfg = i3k_db_resourcepoint[tonumber(arg[1])]
			local mapName = i3k_db_dungeon_base[tonumber(arg[2])].name
			local itemName = mineCfg.nTool > 0 and i3k_db_new_item[mineCfg.nTool].name or ""
			str = string.format(str, mineCfg.name, mapName, itemName)
		elseif noticeType == 32 then -- 宠物赛跑开始
		elseif noticeType == 33 then -- 宠物赛跑结果
			local id = tonumber(arg[1])
			local petNameID = i3k_db_common.petRacePets[id].name
			str = string.format(str, i3k_get_string(petNameID))
		elseif noticeType == 34 then -- 国庆加油幸运者
			str = string.format(str, arg[1])
		elseif noticeType == 35 then -- 江洋大盗
			local robberName = i3k_db_robber_monster_cfg[tonumber(arg[1])].name
			local mapID = i3k_db_robber_monster_pos[tonumber(arg[3])].mapID
			local mapDesc = i3k_db_dungeon_base[mapID].desc
			str = string.format(str, robberName, mapDesc)
		elseif noticeType == 36 then -- 服务器封印等级
			local itemName = i3k_db_get_common_item_name(i3k_db_server_limit.breakSealCfg.getRewardId)
			str = string.format(str, arg[1], itemName)
		elseif noticeType == 37 then -- 服务器封印等级
			local id = tonumber(arg[2])
			str = string.format(str, arg[1], i3k_db_adventure.head[id].name)
		elseif noticeType == 38 then
			local monsterID = i3k_db_battleMapMonster[tonumber(arg[3])].monsterID
			local monsterName = g_i3k_db.i3k_db_get_monster_name(monsterID)
			local superMonsterName = g_i3k_db.i3k_db_get_monster_name(i3k_db_crossRealmPVE_cfg.battleMapSuperBoss.superBossEggID)
			str = string.format(str, arg[2], monsterName, superMonsterName)
		elseif noticeType == 39 then
			local cfg = i3k_db_crossRealmPVE_cfg.battleMapSuperBoss
			local monsterID = tonumber(arg[4]) == 0 and cfg.superBossEggID or cfg.superBossID
			local monsterName = g_i3k_db.i3k_db_get_monster_name(monsterID)
			str = string.format(str, monsterName, arg[2], arg[3])
		elseif noticeType == 40 then
		elseif noticeType == 41 then
			str = string.format(str, arg[1], arg[2])
		elseif noticeType == 42 then -- 城战
			local cityID = tonumber(arg[3])
			local cityName = i3k_db_defenceWar_city[cityID].name
			str = string.format(str, arg[2], cityName)
		elseif noticeType == 43 then
			local level = i3k_db_defenceWar_cfg.factionLvl
			str = string.format(str, level)
		elseif noticeType == 44 then
		elseif noticeType == 45 then
			local cityID = tonumber(arg[1])
			local cityName = i3k_db_defenceWar_city[cityID].name
			str = string.format(str, cityName)
		elseif noticeType == 46 then
			str = string.format(str, arg[1], arg[2], i3k_db_desert_battle_base.killScore)
		elseif noticeType == 47 then
			str = string.format(str, arg[1], arg[2], i3k_db_desert_battle_base.outScore)
		elseif noticeType == 48 then
			local name = ""
			local fristName = true
			for k, v in ipairs(arg) do
				if fristName then
					name = name..v
					fristName = false
				else
					name = name.."、"..v
				end
			end
			str = string.format(str, name)
		elseif noticeType == 49 then -- 周年舞会
		elseif noticeType == 51 then -- 战地卡片
			local str1 = ""
			local cards = string.split(arg[4], ",")
			local grade = i3k_db_war_zone_map_cfg.cardGrade
			for k,v in ipairs(cards) do
				local cfg = i3k_db_war_zone_map_card[tonumber(v)]
				str1 = str1 .. ",".. i3k_get_string(grade[cfg.grade].logDesc) .. cfg.name
			end
			local zoneName = i3k_game_get_server_name_from_role_id(tonumber(arg[1]))
			str = string.format(str, zoneName == "unknow" and arg[2] or arg[2] .. "(" .. zoneName .. ")", g_i3k_db.i3k_db_get_monster_name(tonumber(arg[3])), str1)
		elseif noticeType == 52 then -- 战地卡片 
			local str1 = ""
			local cards = string.split(arg[5], ",")
			local grade = i3k_db_war_zone_map_cfg.cardGrade
			for k,v in ipairs(cards) do
				local cfg = i3k_db_war_zone_map_card[tonumber(v)]
				str1 = str1 .. ",".. i3k_get_string(grade[cfg.grade].logDesc) .. cfg.name
			end
			local zoneName1 = i3k_game_get_server_name_from_role_id(tonumber(arg[1]))
			local zoneName2 = i3k_game_get_server_name_from_role_id(tonumber(arg[3]))
			str = string.format(str, zoneName1 == "unknow" and arg[2] or arg[2].."(" .. zoneName1 .. ")", zoneName2 == "unknow" and arg[4] or arg[4].."(" .. zoneName2 .. ")", str1)
		end
		return str
	end
end

function i3k_db_get_legendEquip_color(equipCfg)
	local colorOrange = "<c=FFBB8400>"
	local colorPurple = "<c=FF862290>"
	local rank = equipCfg.rank -- 4
	return rank == g_RANK_VALUE_PURPLE and colorPurple or colorOrange
end

function i3k_db_get_roll_notice_title(noticeType)
	if noticeType==0 then
		return string.format("系统公告")
	else
		return i3k_db_roll_notice[noticeType] and i3k_db_roll_notice[noticeType].title
	end
end

function i3k_db_get_gold_or_ag_map(mapID)
	if mapID == i3k_db_forcewar_base.otherData.goldFuben then
		return "进入黄金副本"
	elseif mapID == i3k_db_forcewar_base.otherData.AgFuben then
		return "进入白银副本"
	end

	return nil
end



function i3k_db_get_map_entity_color()
	local world = i3k_game_get_world()
	if world then
		local mapId = g_i3k_game_context:GetWorldMapID()
		return i3k_db_dungeon_base[mapId].entityColor
	end
	return nil
end

function i3k_db_bill_board_get_zf_id(i)
	local zm_fm = i3k_db_bill_board[i].zm_fm
	local id = i3k_db_bill_board[i].id

	local t = {zm_fm,id}

	return t
end


--获取符文之语id
function i3k_db_get_rune_word(slots)
	for i,v in ipairs(i3k_db_under_wear_rune_lang) do
		local id1 = v.slotRuneId1
		local id2 = v.slotRuneId2
		local id3 = v.slotRuneId3
		local id4 = v.slotRuneId4
		local id5 = v.slotRuneId5
		local id6 = v.slotRuneId6
		local matchCount = 0
		for _,runeId in ipairs(slots) do
			runeId = math.abs(runeId)
			if runeId~=0 and (runeId==id1 or runeId==id2 or runeId==id3 or runeId==id4 or runeId==id5 or runeId==id6) then
				matchCount = matchCount + 1
				if matchCount==6 then
					return i
				end
			else
				break
			end
		end
	end
	return 0
end

function i3k_db_get_rune_lang_attr(id, lvl)
	if lvl == 0 then
		local r = i3k_db_under_wear_rune_lang[id]
		return {
			{id = r.attrId1, value = r.attrValue1}, {id = r.attrId2, value = r.attrValue2}, {id = r.attrId3, value = r.attrValue3},
			{id = r.attrId4, value = r.attrValue4}, {id = r.attrId5, value = r.attrValue5}, {id = r.attrId6, value = r.attrValue6},
			{id = r.attrId7, value = r.attrValue7}, {id = r.attrId8, value = r.attrValue8}, {id = r.attrId9, value = r.attrValue9},
			{id = r.attrId10, value = r.attrValue10},
		}
	else
		local cfg = i3k_db_rune_lang_upgrade[id][lvl]
		return cfg and cfg.attribute
	end
end

--得到符文有序列表
function i3k_db_get_fuWen_sortList()
	local sortList = {}
	for k,v in pairs(i3k_db_under_wear_rune) do
		table.insert(sortList, v)
	end
	table.sort(sortList,function (a,b)
		return a.runeId < b.runeId
	end)
	return sortList
end
--获取统一模型id
function i3k_db_get_unify_model_id(classType, gender, showType)
	local cfg
	local mapType = i3k_game_get_map_type()

	if mapType == g_FORCE_WAR then
		cfg = i3k_db_common.general
	elseif mapType == g_DEMON_HOLE then
		cfg = i3k_db_demonhole_base
	elseif mapType == g_FACTION_WAR then
		cfg = i3k_db_faction_fight_cfg.other
	elseif mapType == g_DEFENCE_WAR then
		cfg = i3k_db_defenceWar_cfg.group[showType]
	elseif mapType == g_MAZE_BATTLE then
		cfg = i3k_db_maze_battle
	end

	local modelID

	if gender == 1 and showType == 1 then --男正(男蓝)
		modelID = cfg.menDecentModel[classType]
	elseif gender == 2 and showType == 1 then --女正(女蓝)
		modelID = cfg.womenDecentModel[classType]
	elseif gender == 1 and showType == 2 then --男邪(男红)
		if mapType == g_DEFENCE_WAR then
			modelID = cfg.menDecentModel[classType]
		else
			modelID = cfg.menEvilModel[classType]
		end
	elseif gender == 2 and showType == 2 then --女邪(女红)
		if mapType == g_DEFENCE_WAR then
			modelID = cfg.womenDecentModel[classType]
		else
			modelID = cfg.womenEvilModel[classType]
		end
	elseif gender == 1 and showType == 3 then -- 城战男三方
		modelID = cfg.menDecentModel[classType]
	elseif gender == 2 and showType == 3 then -- 城战女三方
		modelID = cfg.womenDecentModel[classType]
	end
	return modelID
end

--db相关功能函数，计算添加offlinePoint经验后能达到的等级和最终的经验值
function i3k_db_get_level_exp_on_add_offline_point(curLvl, curExp, addPoint)
	curExp = curExp + addPoint
	local maxLvl = #i3k_db_activity_wipe
	for i = curLvl+1,maxLvl do
		local cfg = i3k_db_activity_wipe[i]
		if curExp >= cfg.expArgs then
			curExp = curExp - cfg.expArgs
			curLvl = curLvl + 1
		else
			break
		end
	end
	if curLvl >= maxLvl then
		curLvl = maxLvl
		curExp = 0
	end
	return curLvl,curExp
end

-- 获取挂机精灵等级可扫荡活动副本
function i3k_db_get_need_wizard_lvl(groupID)
	local wizardLvl = g_i3k_game_context:GetOfflineWizardLevel()
	for _, e in ipairs(i3k_db_activity_wipe[wizardLvl].groupIds) do
		if e == groupID then
			return false
		end
	end
	for i, e in ipairs(i3k_db_activity_wipe) do
		for _, n in ipairs(e.groupIds) do
			if n == groupID then
				return i
			end
		end
	end
	return false
end

function i3k_db_get_reward_test_first_finish_status(questionID)
	return questionID == i3k_db_fengce.baseData.lastQuestionID
end

function i3k_db_get_reward_test_second_finish_status(questionID)
	return questionID == i3k_db_fengce.baseData.lastQuestionID2
end

function i3k_db_get_tournament_type(mapID)
	return i3k_db_tournament_fb[mapID] and i3k_db_tournament_fb[mapID].tournamentType or 0
end

-- 判断搜索的字符串是否合法
function i3k_db_test_auction_search_valid(str, type)
	-- 过滤掉符号
	-- TODO 根据部位，确定搜索的db文件
	local checkSymbol = function(str)
		if string.find(str, "%p+") then -- 标点
			return false
		elseif string.find(str, "%s+") then -- 空白字符
			return true
		elseif string.find(str, "《") then
			return false
		elseif string.find(str, "》") then
			return false
		elseif string.find(str, "（") then
			return false
		elseif string.find(str, "）") then
			return false
		end
		return true
	end
	local checkStrLen = function(str)
		return string.len(str) ~= 3 -- utf8单个汉字长度为3字节
	end

	local checkDB = function(str)
		for k, v in pairs(g_auction_search) do
			for i, e in ipairs(v)do
				local dbName = "i3k_db_auction_search_"..k
				local array = _G[dbName][type]
				if array then
					for p, q in pairs(array)do -- q not used
						if string.find(p, str) then
							return p
						end
					end
				end
			end
		end
		return false
	end

	if checkSymbol(str) then
		if checkStrLen(str) then
			if checkDB(str) then
				return true
			else
				-- g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3020))
				g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15193, i3k_db_auction_type[type].name, str))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3018))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3019))
	end
	return false
end

function i3k_db_get_auction_select_level()
	return i3k_db_auction_lvl_select
end

-- 获取分包资源，地图对应的分包号
function i3k_db_get_ext_pack_id(mapID)
	-- 副本配置表中的id到战役地图表的一个转换
	local cfgMapID = i3k_db_dungeon_base[mapID].mapID
	return i3k_db_combat_maps[cfgMapID].package
end
function i3k_db_get_mapcfg_id_by_name(mapName)
	for _, v in pairs(i3k_db_combat_maps) do
		if mapName == v.path then
			return v.id
		end
	end
end
function i3k_db_get_ext_pack_reward_cfg(packageID)
	return i3k_db_common.expPackCfg.rewards[packageID]
end
function i3k_db_get_ext_pack_level_require(packageID)
	return i3k_db_common.expPackCfg.level[packageID]
end
-- 获取分包下载的最大分包id
function i3k_db_get_ext_pack_max_id()
	local maxID = 0
	if g_i3k_download_mode then
		for _, v in pairs(i3k_db_combat_maps) do
			if v.package > maxID then
				maxID = v.package
			end
		end
	end
	return maxID
end
-- -- 返回分包下载的情况(2017.5.11 弃用)
-- function i3k_db_get_ext_pack_states()
-- 	local maxID = i3k_db_get_ext_pack_max_id()
-- 	local result = {}
-- 	for i=1, maxID do
-- 		local state = g_i3k_download_mgr:getExtPackState(i)
-- 		result[i] = state == EXT_PACK_STATE_DONE and true or nil
-- 	end
-- 	return result
-- end

-- new 返回分包下载的情况
function i3k_db_get_ext_pack_states_new()
	local result = {}
	for k, v in pairs(i3k_db_combat_maps) do
		if not g_i3k_download_mode then -- 如果不是分包
			result[k] = true
		else
			local packID = v.package
			local state = g_i3k_download_mgr:getExtPackState(packID)
			result[k] = state == EXT_PACK_STATE_DONE and true or nil
		end
	end
	return result
end

-- 返回是否有未下载的分包
function i3k_db_get_show_download_pack()
	if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
        if not g_i3k_download_mgr:getIsWin32Debug() then
            return false
        end
    end
	local maxID = i3k_db_get_ext_pack_max_id()
	for i=1, maxID do
		local state = g_i3k_download_mgr:getExtPackState(i)
		if state ~= EXT_PACK_STATE_DONE then
			return true
		end
	end
	return false
end

function i3k_db_get_ext_pack_reward_icon_id(packID)
	local rewardCfg = g_i3k_db.i3k_db_get_ext_pack_reward_cfg(packID)
	local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(rewardCfg.id)
	return g_i3k_db.i3k_db_get_icon_path(itemCfg.icon)
end

function i3k_db_get_is_pve_maptype()
	local mapType = i3k_game_get_map_type()
	for _, e in ipairs(i3k_db_common.rolerevive.pveMapType) do
		if e == mapType then
			return true
		end
	end
	return false
end

function i3k_db_get_is_show_dungeon_desc()
	local mapId = g_i3k_game_context:GetWorldMapID()
	if not i3k_db_new_dungeon[mapId] then
		return false
	end
	local tagDesc = i3k_db_new_dungeon[mapId].tagDesc
	for i, e in pairs(tagDesc) do
		if e ~= 0 then
			return true
		end
	end
	return false
end


-- 获取开启结束时间
function i3k_db_get_activity_open_close_time(openTimes)
	local openTime = 0
	local closeTime = 0

	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y",  timeStamp)
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local isInTime = false

	for _, e in ipairs(openTimes) do
		local open = string.split(e.startTime, ":")
		local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
		local closeTimeStamp = openTimeStamp + e.lifeTime
		if timeStamp > openTimeStamp and timeStamp < closeTimeStamp then
			openTime = openTimeStamp
			closeTime = closeTimeStamp
			isInTime = true
		end
	end
	return openTime, closeTime, isInTime
end


-- 是否为伏魔洞钥匙npc
function i3k_db_get_is_demonhole_key_npc(id)
	for _, e in ipairs(i3k_db_npc[id].FunctionID) do
		if e == TASK_FUNCTION_DEMONHOLE_KEY then
			return true
		end
	end
	return false
end
-- 获取副本最大时长
function i3k_db_get_activity_max_time(openTimes)
	local openTime, closeTime, isInTime = i3k_db_get_activity_open_close_time(openTimes)
	return isInTime and closeTime - openTime or 0
end

-- 是否为变性npc
function i3k_db_get_is_change_gender_npc(id)
	local functionID = i3k_db_npc[id].FunctionID[1]
	if functionID == TASK_FUNCTION_Degeneration then
		return true
	end
	return false;
end

-- 获取当前vip等级是否消耗传送符 TODO
function i3k_db_get_trans_vip_lvl(vipLvl)
	local cfg = i3k_db_kungfu_vip[vipLvl]
	return cfg.transNeedItem == 0
end

-- 获取退帮惩罚时间(次数)
function i3k_db_get_faction_kick_punish_time(times)
	if times <= 0 then
		return 0
	end
	local tab = i3k_db_common.faction.punishTime
	if times > #tab then
		return tab[#tab]
	end
	return tab[times]
end

-- 秒钟转换为xx小时xx分
function i3k_db_seconds2hour(seconds)
	local int, float = math.modf(seconds / 3600)
	if float == 0 then
		return int.."小时"
	else
		return string.format("%d%s%d%s",int,"小时",float / 60,"分钟")
	end
end

-- 获取设置自动变身vip等级
function i3k_db_get_auto_super_vip_lvl()
	for i, e in ipairs(i3k_db_kungfu_vip) do
		if e.openAutoSuperMode ~= 0 then
			return i
		end
	end
	return 0
end

-- 根据副本类型确定死亡后是否弹复活界面
function i3k_db_get_is_open_revive_ui()
	local open = true
	local mapType = i3k_game_get_map_type()
	for _, e in ipairs(i3k_db_common.wipe.notReviveMapType) do
		if e == mapType then
			open = false
			break
		end
	end
	return open
end

-- 根据副本类型确定是否可自动吃药
function i3k_db_get_is_can_auto_drug()
	local autoDrug = true
	local mapType = i3k_game_get_map_type()
	for _, e in ipairs(i3k_db_common.wipe.notAutoDrugMapType) do
		if e == mapType then
			autoDrug = false
			break
		end
	end
	if mapType == g_FIELD then
		local mapId = g_i3k_game_context:GetWorldMapID()
		if i3k_db_field_map[mapId].showBloodPool == 0 then
			autoDrug = false
		end
	elseif mapType == g_TOURNAMENT then
		local tType = g_i3k_db.i3k_db_get_tournament_type(g_i3k_game_context:GetWorldMapID())
		if i3k_db_tournament[tType] then
			autoDrug = i3k_db_tournament[tType].canUseDrugs == 1
		end
	end

	return autoDrug
end

-- 获取等级对应的传世装备打造消耗物品列表
function i3k_db_get_legend_consume_items_list(equipLevel, quality, partID)
	local maxLevel = 100000 -- 定义一个最大等级
	for k, _ in pairs(i3k_db_equips_legends_consume2) do
		if equipLevel <= k and maxLevel > k then
			maxLevel = k
		end
	end
	return i3k_db_equips_legends_consume2[maxLevel][quality][partID]
end


-- 根据绝技道具id是否拥有该技能
function i3k_db_get_isown_from_itemid(itemId)
	local allUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
	local skills = i3k_db_exskills[itemCfg.args1].skills
	local skillID = skills[g_i3k_game_context:GetRoleType()]
	return allUniqueSkill[skillID]
end

function i3k_db_get_library_max_level(libraryID)
	for i,v in pairs(i3k_db_experience_library) do
		if v[1].libraryID == libraryID then
			return #v
		end
	end
	return 15
end

-- 守卫活动获取配置
function i3k_db_get_defend_cfg_from_npcid(NPCID)
	for k, v in pairs(i3k_db_defend_cfg) do
		if v.NPCID == NPCID then
			return v
		end
	end
	return nil
end

-- 获取地图中npc列表，是否有特殊的图片id
function i3k_db_get_npc_minimap_img(npcID)
	local cfg = i3k_db_npc[npcID]
	if cfg then
		local festivalIcon = g_i3k_game_context:getFestivalNpcHeadIcon(cfg, "taskTipColor")
		if festivalIcon and festivalIcon ~= 0 then
			return festivalIcon
		else
			local index = cfg.FunctionID[1]
			if index and index ~= 0 and i3k_db_npc_function_show[index] then
				local mapIconID = i3k_db_npc_function_show[index].mapIconID
				return mapIconID ~= 0 and mapIconID or nil
			end
		end
	end
	return nil
end
function i3k_db_get_npc_list_function(npcID)
	local cfg = i3k_db_npc[npcID]
	if cfg then
		return cfg.npcFunction
	end
	return ""
end

-- 获取会武elo名称
function i3k_db_get_tournament_elo_name(tournamentType, score)
	local cfg = i3k_db_tournament_base
	local eloCfg = {}
	local name = ""
	if tournamentType == g_TOURNAMENT_4V4 then
		eloCfg = i3k_db_tournament_base.elo_4v4
	elseif tournamentType == g_TOURNAMENT_2V2 then
		eloCfg = i3k_db_tournament_base.elo_2v2
	elseif tournamentType == g_TOURNAMENT_WEAPON then
		eloCfg = i3k_db_tournament_base.elo_4v4v4
	elseif tournamentType == g_TOURNAMENT_CHUHAN then
		eloCfg = i3k_db_tournament_base.elo_4v4_chess
	end
	if score <= eloCfg[1].score then
		name = eloCfg[1].scoreName
		return name
	end
	if score > eloCfg[#eloCfg-1].score then
		name = eloCfg[#eloCfg].scoreName
		return name
	end
	for i, e in ipairs(eloCfg) do
		if score >= e.score+1 and score <= eloCfg[i+1].score then
			name = eloCfg[i+1].scoreName
		end
	end
	return name
end

-- 获取势力战副本时间
function i3k_db_get_forcewar_max_time(mapID)
	local maxTime = -1
	for i,v in ipairs(i3k_db_forcewar) do
		for _, b in ipairs(v.mapId) do
			if mapID == b then
				maxTime = v.maxTime
				break
			end
		end
		if maxTime ~= -1 then
			break
		end
	end
	return maxTime
end

function i3k_db_get_longyin_ban(index)
	return i3k_db_LongYin_ban[index]
end
function i3k_db_get_longyin_lock(index)
	return i3k_db_LongYin_lock[index]
end

--[[
--获取活动日历配置
function i3k_db_get_calendar(year, month, day)
	for i,v in ipairs(i3k_db_calendar) do
		local startDate = string.split(v.startDay, ".")
		if #startDate >= 2 then
			local startYear = tonumber(startDate[1])
			local startMonth = tonumber(startDate[2])
			if startYear == year and startMonth == month then
				return v["day" .. day]
			end
		end
	end
	return {}
end
--]]

function i3k_db_getItemFilter(id)
	return i3k_db_new_item[math.abs(id)] and i3k_db_new_item[math.abs(id)].filter or 10
end

function i3k_db_get_auction_buy_limit_days()
	local openDay = i3k_game_get_server_opened_days()
	local index = 999999
	local max = 0
	local serverID = i3k_game_get_server_id() or 0
	local flag =  false
	for _, v in ipairs(i3k_db_auction_special) do
		if serverID == v then
			flag = true
		end
	end
	for k, _ in pairs(i3k_db_auction_2v2_req) do
		if k >= openDay then
			if k < index then
				index = k
			end
		end
		if k > max then
			max = k
		end
	end
	if flag then
		return i3k_db_auction_2v2_req[index][2] or i3k_db_auction_2v2_req[max][2]
	else
		return i3k_db_auction_2v2_req[index][1] or i3k_db_auction_2v2_req[max][1]
	end
end

-- 通过宝石类型获取宝石祝福配置
function i3k_db_get_diamond_bless_cfg(gemType)
	return i3k_db_diamond_bless[gemType]
end

-- 获取帮派战开始时间和结束时间
function i3k_db_get_faction_fight_time_check()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	--[[local weekCheck = false
	for i, e in ipairs(i3k_db_faction_fight_cfg.commonrule.openday) do
		if e == week then
			weekCheck = true
		end
	end
	if not weekCheck then
		return false
	end--]]
    if not i3k_db_is_open_bangpaizhan() then return false end
	local startTime = i3k_db_faction_fight_cfg.startTime
	local endTime = i3k_db_faction_fight_cfg.endTime
	local deltBefore = i3k_db_faction_fight_cfg.commonrule.pushBegin
	local deltEnd = i3k_db_faction_fight_cfg.commonrule.pushEnd
	local curtime = math.modf(i3k_game_get_time())
	local pushBegin = g_i3k_get_day_time(startTime) - deltBefore
	local pushEnd = g_i3k_get_day_time(endTime) + deltEnd

	return pushBegin < curtime and curtime < pushEnd
end

--获取分堂开启等级
function i3k_db_get_fightGroupLevel()
	for _,v in ipairs(i3k_db_faction_uplvl) do
		if v.fightGroupCount > 0 then
			return v.level
		end
	end
	return #i3k_db_faction_uplvl + 1;
end

-- 获取是否需要同步副本中的伤害
function i3k_db_check_sync_mapcopy()
	local mapType = i3k_game_get_map_type()
	for i, e in ipairs(i3k_db_common.wipe.showDamage) do
		if mapType == e then
			return true
		end
	end
	return false
end

---------------装备淬锋相关------------------------
-- 根据装备id，判断该装备的稀有度是否具备淬锋的条件
function i3k_db_check_equip_can_sharpen(equipID)
	local itype = g_i3k_db.i3k_db_get_common_item_type(equipID)
	local rank = g_i3k_db.i3k_db_get_common_item_rank(equipID)
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	if itype == g_COMMON_ITEM_TYPE_EQUIP and rank >= g_RANK_VALUE_PURPLE then
		local flag = false
		for i, v in ipairs(cfg.ext_properties) do
			if v.minVal ~= v.maxVal then
				flag = true
			end
		end
		return flag
	end

	return false
end

-- 获取背包/已装备的 符合淬锋稀有度条件的装备, args1 部位
function i3k_db_get_equip_sharpen_list(part)
	local equips = {}
	local wearEquips = g_i3k_game_context:GetWearEquips()
	local bagEquips = g_i3k_game_context:GetAllBagEquips()
	for i, v in ipairs(wearEquips) do
		if v.equip then -- 有装备
			if g_i3k_db.i3k_db_get_equip_item_cfg(v.equip.equip_id).partID == part then
	           if i3k_db_check_equip_can_sharpen(v.equip.equip_id) then
				  table.insert(equips, {id = v.equip.equip_id, guid = v.equip.equip_guid, inBag = false})
			   end
			end
		end
	end
	for i, v in ipairs(bagEquips) do
		if g_i3k_db.i3k_db_get_equip_item_cfg(v.id).partID == part then
	       if i3k_db_check_equip_can_sharpen(v.id) then
			  table.insert(equips, {id = v.id, guid = v.guid, inBag = true})
		   end
		end
	end
	return equips
end

-- 判断装备是否淬锋满了
function i3k_db_check_equip_sharpen_full(equipID, guid)
	-- TODO 背包
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	local equipData = g_i3k_game_context:GetBagEquip(equipID, guid)
	if equipData then
		local abt = equipData.attribute
		local flag = false
        for i, v in ipairs(abt) do
		    if abt[i] < i3k_db_get_equip_ext_prop_sharpen_max(equipID, i) then
			   flag = true
			end
	    end
		return flag
    else
	-- 身上装备
	    local wearEquips = g_i3k_game_context:GetWearEquips()
		local w_equip = {}
		for i, v in ipairs(wearEquips) do
			if v.equip.equip_id == equipID and v.equip.equip_guid == guid then
				w_equip = v.equip
			end
		end
		local abt = w_equip.attribute
		local flag = false
        for i, v in ipairs(abt) do
		    if abt[i] < i3k_db_get_equip_ext_prop_sharpen_max(equipID, i) then
			   flag = true
			end
	    end
		return flag
    end
	return false
end

-- 获取淬锋消耗的道具
function i3k_db_get_equip_sharpen_need_items(part, lock_count)
	local items = {}
	local item1 = i3k_db_common.equipSharpen.needItem1
	local count1 = i3k_db_common.equipSharpen.itemCount1[part]
	local item2 = i3k_db_common.equipSharpen.needItem2
	local count2 = i3k_db_common.equipSharpen.itemCount2[part]
	local lockItem = i3k_db_common.equipSharpen.lockID[part]
	local lockCount = i3k_db_common.equipSharpen.lockCount
	table.insert(items, {id = item1[part], count = count1})
	table.insert(items, {id = item2[part], count = count2})
	if lock_count > 0 then
		table.insert(items, {id = lockItem , count = lockCount[lock_count]})
	end
	return items
end
function i3k_db_get_equip_trans_need_items(transID, equipID)
	local items = {}
	local transData = i3k_db_equip_transform[transID][equipID]
	if transData then
		local item1 = transData.itemId1
		local count1 = transData.itemCount1
		local item2 = transData.itemId2
		local count2 = transData.itemCount2
		local item3 = transData.itemId3
		local count3 = transData.itemCount3
		items[item1] = count1
		items[item2] = count2
		items[item3] = count3
	end
	return items
end

function i3k_db_get_equip_sharpen_cfg()
	return i3k_db_common.equipSharpen
end

-- 获取装备附加属性淬锋最大值
function i3k_db_get_equip_ext_prop_sharpen_max(equipID, extPropIndex)
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	if cfg then
		local extProp = cfg.ext_properties[extPropIndex];
		if extProp and extProp.type == 1 then -- type 1 means prop
			local res = extProp.maxVal * i3k_db_common.equipSharpen.topRate[cfg.partID];
			return i3k_integer(res);
		end
	end
	return nil;
end
-- 装备当前附加属性，是否达到淬锋最大值
function i3k_db_is_equip_ext_prop_sharpen_max(equipID, extPropIndex, equipVal)
	local maxVal = g_i3k_db.i3k_db_get_equip_ext_prop_sharpen_max(equipID,extPropIndex)
	if maxVal then
		return equipVal == maxVal
	end
	return false;
end

---------------------------------------------

-- 根据副本类型获取是否打开玩家菜单
function i3k_db_get_is_open_role_menu()
	for _, e in ipairs(i3k_db_common.wipe.notHeadTipsMapType) do
		if e == i3k_game_get_map_type() then
			return false
		end
	end
	return true
end

-- 获取技能类型
function i3k_db_get_skill_type(skillID)
	return i3k_db_skills[skillID].type
end


--------------------------------------------
--获取对对碰兑换的基础奖励（按等级）
function i3k_db_get_exchange_word_base_reward()
	local roleLvl = g_i3k_game_context:GetLevel()
	for i, v in ipairs(i3k_db_word_exchange_reward) do
		if v.level_limit >= roleLvl then
			return v.base_rewards
		end
	end
	return i3k_db_word_exchange_reward[#i3k_db_word_exchange_reward].base_rewards
end

-- 获取小龟赛跑开始的冒泡文字
function i3k_db_get_pet_race_start_str()
	local list = {16013, 16017, 16018}
	local index = math.random(#list)
	return i3k_get_string(list[index])
end

function i3k_db_get_pet_race_finish_str()
	return i3k_get_string(16016)
end

function i3k_db_get_pet_race_buff_str()
	local list = {16014, 16015, 16019, 16020}
	local index = math.random(#list)
	return i3k_get_string(list[index])
end

------------------大富翁 ---------------------
-- 根据时间判断当前开启的活动id，不在时间范围内则为空
function i3k_db_open_dice_activity_id()
	for k, v in ipairs(i3k_db_dice_cfg) do
		local checkDate = g_i3k_db.i3k_db_check_dice_date(k)
		local checkWeek = g_i3k_db.i3k_db_check_dice_week(k)
		local checkTime = g_i3k_db.i3k_db_check_dice_time(k)
		if checkDate and checkWeek and checkTime then
			return k
		end
	end
	return nil
end
-- 是否在日期范围内
function i3k_db_check_dice_date(id)
	-- local nowTime = i3k_game_get_time()
	local startTime = i3k_db_dice_cfg[id].startDay
	local endTime = i3k_db_dice_cfg[id].endDay
	-- return startTime < nowTime and nowTime < endTime
	return g_i3k_checkIsInDate(startTime, endTime)
end
-- 是否在当天的活动时间内
function i3k_db_check_dice_time(id)
	local nowTime = i3k_game_get_time() % 86400
	local beginTime = i3k_db_dice_cfg[id].startTime
	local endTime = i3k_db_dice_cfg[id].endTime
	return beginTime < nowTime and nowTime < endTime
end
-- 是否在指定的星期几
function i3k_db_check_dice_week(id)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local days = i3k_db_dice_cfg[id].days
	return g_i3k_game_context:vectorContain(days, week)
end

-- 获取当前位置的类型
function i3k_db_get_dice_event(groupID, id)
	if not i3k_db_dice[groupID] then
		error("groupID = "..groupID..", id = "..id)
	end
	local cfg = i3k_db_dice[groupID][id]
	return cfg.eventID, cfg.args
end
function i3k_db_dice_handle_event(groupID, nodeID, info)
	local eventTable =
	{
		[DICE_EVENT_NIL] = { func = g_i3k_game_context.handleDiceEventNil },
		[DICE_EVENT_EXP] = { func = g_i3k_game_context.handleDiceEventExp },
		[DICE_EVENT_ITEM] = { func = g_i3k_game_context.handleDiceEventItem },
		[DICE_EVENT_TRADE] = { func = g_i3k_game_context.handleDiceEventTrade },
		[DICE_EVENT_MONSTER] = { func = g_i3k_game_context.handleDiceEventMonster },
		[DICE_EVENT_FLOWER] = { func = g_i3k_game_context.handleDiceEventFlower },
		[DICE_EVENT_THROW] = { func = g_i3k_game_context.handleDiceEventThrow },
		[DICE_EVENT_SLOW] = { func = g_i3k_game_context.handleDiceEventSlow },
		[DICE_EVENT_THREE] = { func = g_i3k_game_context.handleDiceEventThree },
		[DICE_EVENT_DEDUCT] = { func = g_i3k_game_context.handleDiceEventDeduct },
		[DICE_EVENT_MONEY] = { func = g_i3k_game_context.handleDiceEventMoney },
		[DICE_EVENT_VIT] = { func = g_i3k_game_context.handleDiceEventVit },
	}
	local eventID, args = g_i3k_db.i3k_db_get_dice_event(groupID, nodeID)
	local func = eventTable[eventID].func
	func(g_i3k_game_context, args, groupID, info)
end
---------------------------------------------

------------------找你妹---------------------
-- 根据时间判断当前开启的活动id，不在时间范围内则为空
function i3k_db_open_findMooncake_activity_id()
	for k, v in ipairs(i3k_db_findMooncake) do
		local checkDate = g_i3k_db.i3k_db_check_findMooncake_date(k)
		local checkTime = g_i3k_db.i3k_db_check_findMooncake_time(k)
		if checkDate and checkTime then
			return k
		end
	end
	return nil
end
--判断两种游戏类型的分别开启
function i3k_db_open_hit_diglett_id(gameType)
	for k, v in ipairs(i3k_db_findMooncake) do
		if v.gameType == gameType then
			local checkDate = g_i3k_db.i3k_db_check_findMooncake_date(k)
			local checkTime = g_i3k_db.i3k_db_check_findMooncake_time(k)
			if checkDate and checkTime then
				return k
			end
		end
	end
	return nil
end
--判断此id玩法是否开启
function i3k_db_get_findMooncake_is_open_by_id(id)
	local checkDate = g_i3k_db.i3k_db_check_findMooncake_date(id)
	local checkTime = g_i3k_db.i3k_db_check_findMooncake_time(id)
	return checkDate and checkTime
end
-- 是否在日期范围内
function i3k_db_check_findMooncake_date(id)
	local nowTime = i3k_game_get_time()
	local startTime = i3k_db_findMooncake[id].openDate
	local endTime = i3k_db_findMooncake[id].closeDate
	--return startTime < nowTime and nowTime < endTime
	return g_i3k_checkIsInDate(startTime, endTime)
end
-- 是否在当天的活动时间内
function i3k_db_check_findMooncake_time(id)
	local nowTime = i3k_game_get_time() % 86400
	local beginTime = i3k_db_findMooncake[id].startTime
	local endTime = i3k_db_findMooncake[id].endTime
	return beginTime < nowTime and nowTime < endTime
end

---------------------------------------------------------

----------------------服务器等级封印开启------------------
function i3k_db_open_breakSeal_id()
	local checkDate = g_i3k_db.i3k_db_check_breakSeal_date()
	local checkTime = g_i3k_db.i3k_db_check_breakSeal_time()
	if checkDate and checkTime then
		return true
	else
		return false
	end
end

function i3k_db_check_breakSeal_date()
	local nowTime = i3k_game_get_time()
    nowTime = nowTime - nowTime%86400
    local gmtTime = g_i3k_get_GMTtime(nowTime)
    return i3k_db_server_limit.breakSealCfg.openDay <= gmtTime
end

function i3k_db_check_breakSeal_time()
	local nowTime = i3k_game_get_time() % 86400
	local beginTime = i3k_db_server_limit.breakSealCfg.openTime
	return beginTime < nowTime
end
---------------------------------------------------------------------
function i3k_db_get_DivorcTime(divorcTime)
	local time = divorcTime + i3k_db_marry_rules.divorcePunishmentTime - i3k_game_get_time()
	local str = ""
	if time > 0 then
		local day = math.modf(time/86400)
		if day > 0 then
			str = str.. day.."天"
		end

		local hour = math.modf((time%86400)/3600)
		if hour > 0 then
			str = str.. hour.."时"
		end

		local min = math.modf((time%3600)/60)
		if min > 0 then
			str = str.. min.."分"
		end

		local sec = time%60
		if day == 0 and sec > 0 then
			str = str.. sec.."秒"
		end
	end
	return str
end

function i3k_db_is_weapon_unique_skill_has_aitrigger(weaponID)
	local cfg = i3k_db_shen_bing_unique_skill[weaponID]
	for i,v in pairs(cfg) do
		if v.uniqueSkillType == 9 then --类型9，神兵特技挂载AI
			return true
		end
	end
	return false
end
function i3k_db_is_weapon_unique_skill_change_model(weaponID)
	local cfg = i3k_db_shen_bing_unique_skill[weaponID]
	for i,v in pairs(cfg) do
		if v.uniqueSkillType == 10 then --类型10，神兵特技可解锁进阶形象
			return true
		end
	end
	return false
end

-- 允许上坐骑的地图
function i3k_db_get_is_can_ride_frome_mapType()
	local mapIDs = i3k_db_steed_common.MapIDs
	local maptype = i3k_game_get_map_type()
	return maptype and mapIDs[maptype] or false
end

function i3k_get_head_cfg_form_frameId(frameId)
    return i3k_db_head_frame[frameId] or nil
end

function i3k_db_get_bid_item_cfg(id)
	local db = i3k_db_bid_items
	return db[id]
end

-- 根据组id，获取补货时间的索引id，可以获取时间;default return nil
function i3k_db_get_add_bid_time_id(groupID, curDayTime)
	for k, v in ipairs(i3k_db_bid_add_items) do
		for i, e in ipairs(v.groupID) do
			if e == groupID and v.time > curDayTime then
				return k, v.time - curDayTime
			end
		end
	end
end

-- 获取拍卖行补货剩余时间
-- 默认返回临近的最近时间的补货时间，如果没有找到返回0
function i3k_db_get_add_bid_item_last_time(groupID)
	local res = 0
	local curDayTime = i3k_game_get_time() % 86400
	local dbGroupID, lastTime = g_i3k_db.i3k_db_get_add_bid_time_id(groupID, curDayTime)
	if dbGroupID then
		res = lastTime
	end
	return res
end


-- 排序 uiType：1 战队， 2战斗左侧 观战, 3 战队查看
function i3k_db_sort_fightteam_member(members, leaderID, uiType)
	local tmp = {}
	for k, v in pairs(members) do
		local overview = {}
		if uiType == 1 then
			overview = v.overview
		elseif  uiType == 2 then
			overview = v.profile.overview
		elseif uiType == 3 then
			overview = v
		end
		local order = overview.id
		if overview.id == leaderID then
			order = overview.id + 10^8
		else
			order = (10 - overview.type) * 10^6
		end
		if uiType == 2 then -- 战斗左侧不显示自己
			if overview.id ~= g_i3k_game_context:GetRoleId() then
				table.insert(tmp, {details = v, order = order})
			end
		else
			table.insert(tmp, {details = v, order = order})
		end
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

-- 获取武道会时间描述信息
function i3k_db_get_stage_time_desc(stage)
	local strings = {}
	local season = g_i3k_game_context:getFightTeamSchedule()
	for k,v in ipairs(i3k_db_fightTeam_explain) do
		local stringsIndex = k
		local config = season[k+1]
		--内容
		if k == 1 then
			--开始
			local createTime = g_i3k_get_ActDateStr(season[1])
			local startString =
				g_i3k_get_ActDateStr(config.startTime)
				.."至"
				..g_i3k_get_ActDateStr(config.endTime)
				.."每日:"
				..g_i3k_get_show_short_time(config.dayStartTime)
				.."-"
				..g_i3k_get_show_short_time(config.dayEndTime)
			strings[stringsIndex] = startString
		elseif k == 8 then
			strings[stringsIndex] = ""--g_i3k_get_show_time(season[k].resultTime)
		else
			local string1 = g_i3k_get_ActDateStr(config.startJoinTime).." "
			local string2 = g_i3k_get_show_short_time(config.startJoinTime).."签到,"
			local string3 = g_i3k_get_show_short_time(config.startFightTime).."开战,"
			local string4 = g_i3k_get_show_short_time(config.resultTime).."结束"
			strings[stringsIndex] = string.format("%s%s%s%s", string1,string2,string3,string4)
		end
	end
	return strings[stage] or "时间描述"
end

function i3k_db_get_fight_team_record(nowState)
	local str = {}
	local events = g_i3k_game_context:getFightTeamEvents()
	if events and #events > 0 then
		for i, e in ipairs(events) do
			local desc = ""
			local cfg = i3k_db_fightTeam_explain[e.eventID]
			local timeDesc = g_i3k_get_ActDateStr(e.time)
			if cfg then
				local winLoseDesc = e.iArg1 == f_FIGHT_RESULT_WIN and cfg.winDesc or cfg.failDesc
				if e.eventID == f_FIGHTTEAM_STAGE_QUALIFY then
					desc = string.format(winLoseDesc, timeDesc, e.iArg2)
				else
					desc = string.format(winLoseDesc, timeDesc)
				end
			elseif e.eventID == g_FIGHT_TEAM_EVENTID then -- 100 进入64强事件
				local c = i3k_db_fightTeam_explain[f_FIGHTTEAM_STAGE_QUALIFY]
				desc = string.format(c.enterDesc, timeDesc)
			end
			desc = desc.."\n"
			str[i] = desc
		end
		if nowState then
			local eventData = events[#events]
			local id = 0
			if eventData.eventID == g_FIGHT_TEAM_EVENTID then -- 100 进入64强事件
				id = 2 --进入六十四强事件 用第二个赛事阶段描述
			elseif eventData.eventID == f_FIGHTTEAM_STAGE_QUALIFY then
				id = eventData.eventID
			else
				id = eventData.iArg1 == f_FIGHT_RESULT_WIN and eventData.eventID + 1 or eventData.eventID
				id = id > #i3k_db_fightTeam_explain and #i3k_db_fightTeam_explain or id
			end
			return id, i3k_db_fightTeam_explain[id].fightTeamState
		else
			return table.concat(str)
		end
	end
	if nowState then
		return f_FIGHTTEAM_STAGE_QUALIFY, i3k_db_fightTeam_explain[f_FIGHTTEAM_STAGE_QUALIFY].fightTeamState
	else
		return i3k_get_string(1204)
	end
end

function i3k_db_check_equip_level(equipID)
	local equipLevelProp = g_i3k_game_context:getRoleEquipLevel()
	local roleLevel = g_i3k_game_context:GetLevel()
	local role_type = g_i3k_game_context:GetRoleType() -- 职业， 刀客剑客等
	local transform = g_i3k_game_context:GetTransformLvl() -- 专职等级 12345
	local bwType = g_i3k_game_context:GetTransformBWtype() -- 正邪 1正 2邪
	local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipID)
	local levelReq = equip_cfg.levelReq

	-- 专职等级判断
	if equipLevelProp == 0 and transform < equip_cfg.C_require then
		return false
	end
	-- 先判断职业
	if equip_cfg.roleType ~= 0 and equip_cfg.roleType ~= role_type then
		return false
	end
	-- 判断正邪
	if equip_cfg.M_require ~= 0 and equip_cfg.M_require ~= bwType then
		return false
	end
	-- 算一下等级
	local req = roleLevel +  equipLevelProp - levelReq
	return req >= 0
end

function i3k_db_get_factionFlag_high_level_map_id(id)
	local mapIDs = i3k_db_faction_rob_flag.faction_rob_flag.highLevelMaps   --{ 3706 , 3705 , 955}
	for k, v in ipairs(mapIDs) do
		if v == id then
			return true
		end
	end
	return false
end

--判断渠道是否在活动配置表内，0是全渠道
function i3k_db_get_is_channel_effective(channelTbl)
	if #channelTbl == 1 and channelTbl[1] == 0 then
		return true
	end
	local selfChannel = tonumber(i3k_game_get_channel_name())
	for k,v in ipairs(channelTbl) do
		if v == selfChannel then
			return true
		end
	end
	return false
end

-- 根据当前时间，获取需要显示的活动个数以及配置信息
function i3k_db_get_activity_show_list()
	local cfg = i3k_db_activity_show
	local result = {}
	local time = i3k_game_get_time()
	local curGmt = g_i3k_get_GMTtime(time)
	for k, v in ipairs(cfg) do
		local startTime = v.startDate + v.startTime
		local endTime = v.endDate + v.endTime
		--加一个渠道的判断
		local isChannelEffective = i3k_db_get_is_channel_effective(v.effectiveChannel)
		if startTime < curGmt and curGmt < endTime and isChannelEffective then
			table.insert(result, k)
		end
	end
	return result
end
-- 获取每日登陆需要弹窗的活动id
function i3k_db_get_activity_show_list_dayLogin()
	local list = g_i3k_db.i3k_db_get_activity_show_list()
	local cfg = i3k_db_activity_show
	local result = {}
	for k, v in ipairs(list) do
		if cfg[v].dayFirstLogin == 1 then
			table.insert(result, v)
		end
	end
	return result
end

-- 获得随机且不重复的数字列表,size必须小于等于maxRand
function i3k_db_get_no_repeat_randrom_number(size, maxRand)
	local function getRand(tab)
		local rand = i3k_engine_get_rnd_u(1, maxRand)
		if not g_i3k_game_context:vectorContain(tab, rand) then
			return rand
		else
			return getRand(tab)
		end
	end

	local result = {}
	for i = 1, size do
		local rand = getRand(result)
		table.insert(result, rand)
	end
	return result
end

--查看礼包道具是否开启N选n功能
function i3k_db_get_gift_bag_is_open_select(id)
	local giftID = g_i3k_db.i3k_db_get_other_item_cfg(id).args1
	local giftType = i3k_db_gift_bag[giftID] and i3k_db_gift_bag[giftID].giftType or 0
	if giftType == 1 then
		return true
	end
	return false
end

--获得礼包道具的包含的所有道具
function i3k_db_get_gift_bag_all_items(id, count)
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
	local giftID = itemCfg.args1
	local result = {}
	if itemCfg.type == UseItemGodEquip then
		local cfg = i3k_db_career_gift_bag[giftID]
		local career = g_i3k_game_context:GetRoleType()
		if cfg and cfg.giftInfo then
			for _, v in ipairs(cfg.giftInfo) do
				if v.itemID[career] ~= 0 and v.itemCount ~= 0 then
					table.insert(result, {id = v.itemID[career], count = v.itemCount * count})
				end
			end
		end
	else
		local cfg = i3k_db_gift_bag[giftID]
		if cfg and cfg.giftInfo then
			for i, v in ipairs(cfg.giftInfo) do
				if v.itemID ~= 0 and v.itemCount ~= 0 then
					table.insert(result, {id = v.itemID, count = v.itemCount * count})
				end
			end
		end

	end
	return result
end

--计算打开N选n礼包背包空间是否足够
function i3k_db_get_open_n_select_gift_is_enough(items)
	local tmp = {}
	for _, v in ipairs(items) do
		local gid = v.id
		local gcount = v.count
		if gid and gid ~= 0 and gcount and gcount ~= 0 then
			if math.abs(gid) ~= g_BASE_ITEM_DIAMOND and math.abs(gid) ~= g_BASE_ITEM_COIN then
				if not tmp[gid] then
					tmp[gid] = gcount
				else
					tmp[gid] = tmp[gid] + gcount
				end
			end
		end
	end
	return g_i3k_game_context:IsBagEnough(tmp)
end

-- 获取骑战映射动作
function i3k_db_get_ride_mapped_action(actionName)
    local skillReplaceAct = i3k_db_ride_mapped_action
    if skillReplaceAct[actionName] then
        return skillReplaceAct[actionName].playerRideAction, skillReplaceAct[actionName].horseAction
    end
    return nil
end

----------------------------------------------------------------------------
--星魂功能

--根据id和等级获取当前副星的配置
function xinghun_getSubStarConfig(id,level)
	for k,v in ipairs(i3k_db_chuanjiabao.subStarLevel) do
        if v.id == id and v.level == level then
            return v
        end
    end
    return nil
end

--获取当前副星的等级上限
function xinghun_getSubStarMaxLevel()
	local levelLimit = 0
	local heirloomData = g_i3k_game_context:getHeirloomData()
	if heirloomData then
		local rank = heirloomData.starSpirit.rank;
		if rank > 0 then
			levelLimit = i3k_db_chuanjiabao.starStage[rank].subStarLevelLimit
		end
	end

	return levelLimit
end

--获取一条星魂升阶配置
function i3k_db_get_one_star_up_stage_cfg(stage)
	for _, v in ipairs(i3k_db_chuanjiabao.starStage) do
		if v.stage == stage then
			return v
		end
	end
	return nil
end

--获取某个辅星升级配置的数量
function i3k_db_get_sub_star_up_cfg_num(id)
	local num = 0
	for _, v in ipairs(i3k_db_chuanjiabao.subStarLevel) do
		if v.id == id then
			num = num + 1
		end
	end
	return num
end

--获取某个职业所对应的主星配置
function i3k_db_get_main_star_up_cfg(roleType, level)
	local mainStarId = 0
	for _, v in ipairs(i3k_db_chuanjiabao.star) do
		if v.roleType == roleType then
			 mainStarId = v.goodMainStarId
			 break
		end
	end

	for _, v in ipairs(i3k_db_chuanjiabao.mainStarLevel) do
		if v.id == mainStarId and v.level == level then
			return v
		end
	end
	return nil
end

--获取主星属性对应的描述
function i3k_db_get_main_star_prop_desc(id)
	for _, v in pairs(i3k_db_chuanjiabao.mainStarPropDesc) do
		if v.id == id then
			return v.desc
		end
	end
	return " "
end

-- 判断背包里是否有示爱道具
function i3k_db_check_have_show_love_items()
	local typeNormalID = i3k_db_show_love_item.typeNormalID
	local typeLuxuryID = i3k_db_show_love_item.typeLuxuryID
	local count1 = g_i3k_game_context:GetCommonItemCanUseCount(typeNormalID)
	local count2 = g_i3k_game_context:GetCommonItemCanUseCount(typeLuxuryID)
	if count1 <= 0 and count2 <= 0 then
		return false
	end
	return true
end

--龙穴任务配置
function i3k_db_get_dragon_task_cfg(taskId)
	local taskCfg = i3k_db_dragon_hole_task[taskId]
	return taskCfg
end

--判断是否是龙穴传送npc
function i3k_db_get_is_dragon_hole_npc(id)
	if id >= 60030 and id <= 60036 then
		return true
	end
	return false
end

--判断是否在龙穴任务时间内
function i3k_db_is_in_dragon_task_time()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local days = i3k_db_dragon_hole_cfg.openData
	if g_i3k_game_context:vectorContain(days, week) then
		local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
		local startTime = string.split(i3k_db_dragon_hole_cfg.startTime, ":")
		local endTime = string.split(i3k_db_dragon_hole_cfg.endTime, ":")
		local year = os.date("%Y", timeStamp)
		local month = os.date("%m", timeStamp)
		local day = os.date("%d", timeStamp)
		local startTimeStamp = os.time({year = year, month = month, day = day, hour = startTime[1], min = startTime[2], sec = startTime[3]})
		local endTimeStamp = os.time({year = year, month = month, day = day, hour = endTime[1], min = endTime[2], sec = endTime[3]})
		if timeStamp >= startTimeStamp and timeStamp <= endTimeStamp then
			return true
		end
	end
	return false
end

--判断龙穴任务是否在有效期内
function i3k_db_is_valid_dragon_task(reciveTime)
	local timeStamp = i3k_game_get_time()
	if timeStamp - reciveTime > i3k_db_dragon_hole_cfg.lastTime then
		return false
	else
		return i3k_db_dragon_hole_cfg.lastTime - timeStamp + reciveTime
	end
end

--获取龙穴任务完成对话
function i3k_db_get_dragon_task_finish_desc(id)
	local t = {}
	if cfg.type == g_TASK_NEW_NPC_DIALOGUE then
		return i3k_db_dialogue[cfg.arg2]
	end
end

function i3k_db_check_show_love_item_mapID(mapID)
	for k, v in pairs(i3k_db_show_love_item_pos) do
		if k == mapID then
			return true
		end
	end
	return false
end

-- 检查示爱道具使用范围
function i3k_db_check_use_show_love_item_pos()
	local hero = i3k_game_get_player_hero()
	local curPos = hero._curPosE
	local curMapID = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_show_love_item_pos[curMapID]
	if not cfg then
		return false
	end
	-- 计算两个坐标的距离是否小于半径
	local fun = function(posA, posB, r)
		return i3k_vec3_dist_2d(posA, posB) <= r
	end

	for k, v in ipairs(cfg.pos) do
		if fun(v, curPos, cfg.radius) then
			return true
		end
	end
	return false
end

-- 是否显示龙魂币直购（同拍卖行显示规则一致）
function i3k_db_check_gragon_coin_is_open()
	local cfg = i3k_db_bid_cfg

	local startDate = cfg.startDate
	local endDate = cfg.endDate
	local time = i3k_game_get_time()
	if g_i3k_get_GMTtime(time) < startDate or g_i3k_get_GMTtime(time) > endDate then
		return false
	end

	local nowTime = i3k_game_get_time() % 86400
	local beginTime = cfg.startTime - cfg.aheadSecond  --龙魂币比拍卖行预先开放
	local endTime = cfg.endTime
	if beginTime > nowTime or nowTime > endTime then
		return false
	end

	local roleLevel = g_i3k_game_context:GetLevel()
	local vipLevel = g_i3k_game_context:GetVipLevel()
	if roleLevel < cfg.needLevel then
		return false
	end
	if vipLevel < cfg.needVipLevel then
		return false
	end

	return true
end

function i3k_db_check_dengmi_is_open()
	local cfg = i3k_db_dengmi_common
	local time = g_i3k_get_GMTtime(i3k_game_get_time())
	if time < cfg.visibleDate or time > cfg.disableDate + 86400 then
		return false
	end
	return true
end

function i3k_db_get_dengmi_ui_state()
	local cfg = i3k_db_dengmi_common
	local time = g_i3k_get_GMTtime(i3k_game_get_time())
	local startTime = cfg.startDate + cfg.startTime --开始时间
	local endTime = cfg.endDate + cfg.endTime --结束时间

	if time >= startTime and time <= endTime then
		return g_TYPE_VALID
	elseif time > endTime then
		return g_TYPE_END
	end
	return g_TYPE_PRE
end

-- 是否显示新春福袋
function i3k_db_check_lucky_pack_is_open()
	local cfg = i3k_db_lucky_pack_cfg
	local time = g_i3k_get_GMTtime(i3k_game_get_time())
	if time < cfg.validTime or time > cfg.invalidTime + 86400 then
		return false
	end
	return true
end

-- 根据时间获得新春福袋ui类型
function i3k_db_get_lucky_pack_ui_type()
	local cfg = i3k_db_lucky_pack_cfg
	local time = g_i3k_get_GMTtime(i3k_game_get_time())
	local startTime = cfg.openDate + cfg.openTime --开始时间
	local endTime = cfg.closeDate + cfg.closeTime --结束时间

	if time >= startTime and time <= endTime then
		return g_TYPE_VALID
	elseif time > endTime then
		return g_TYPE_END
	end
	return g_TYPE_PRE
end

-- items是一个数组 {{itemID = .., itemCount = ..,} }
function i3k_db_get_item_is_enough_up(items)
	local num = 0
	local count = 0
	for _, e in ipairs(items) do
		if e.itemID ~= 0 then
			count = count + 1
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)
			if canUseCount >= e.itemCount then
				num = num + 1
			end
		end
	end
	return num == count
end

--获取八卦强化数据
function i3k_db_get_bagua_strength_data(lvl)
	for i, v in ipairs(i3k_db_bagua_streng) do
		if i == lvl then
			return v
		end
	end
	return nil
end

--获取八卦信息(名称和icon)
function i3k_db_get_bagua_info(partID)
	for i, v in ipairs(i3k_db_bagua_part) do
		if i == partID then
			return v
		end
	end
	return nil
end

--获取八卦品质(词缀数量0-3)
function i3k_db_get_bagua_rank(additionProp)
	if additionProp then
		return #additionProp + 1
	end
	return 1
end

--获取可萃取八卦的词缀id
function i3k_db_get_bagua_extractID(additionProp)
	if additionProp then
		for _, v in ipairs(additionProp) do
			if i3k_db_bagua_affix[v].isExtract == 1 then
				return v
			end
		end
	end
	return 0
end

--获取八卦品质icon path
function i3k_db_get_bagua_rank_icon(rank)
	if rank then
		local iconId = i3k_db_bagua_cfg.gradeIcon[rank]
		return i3k_db_get_icon_path(iconId)
	end
	return i3k_db_get_icon_path(i3k_db_bagua_cfg.gradeIcon[1])
end

function i3k_db_get_prop_stone(propId,quality)
	for i,v in ipairs(i3k_db_bagua_prop_stone) do
		if v.propID == propId and v.propQuality == quality then
			return v
		end
	end
	return nil
end

--帮派仓库贡献道具描述 @param map[id, count]
function i3k_db_get_award_item_desc(items)
	local str = ""
	for k, v in pairs(items) do
		local itemName = i3k_db_get_common_item_name(k)
		str = str == "" and string.format("%s*%s", itemName, v) or string.format("%s、 %s*%s", str, itemName, v)
	end
	return str
end

function i3k_db_get_award_item_isDonate(items)
	for k, v in pairs(items) do
		if i3k_db_new_item[k].defaultScore == 0 then
			return true
		end
	end

	return false
end

-- 帮派仓库记录
function i3k_db_get_faction_warehouse_event_desc(eventInfo)
	local str = ""
	local awardItemDesc = g_i3k_db.i3k_db_get_award_item_desc(eventInfo.items)
	if eventInfo.eventID == eFactionWhPeaceAward then
		str = i3k_get_string(1331, eventInfo.sArg, awardItemDesc)
	elseif eventInfo.eventID == eFactionWhBattleBossAward then
		local monsterID = i3k_db_battleMapMonster[eventInfo.iArg].monsterID
		local monsterName = g_i3k_db.i3k_db_get_monster_name(monsterID)
		str = tonumber(eventInfo.sArg) == 0 and i3k_get_string(1349, monsterName, awardItemDesc) or i3k_get_string(1332, monsterName, eventInfo.sArg, awardItemDesc)
	elseif eventInfo.eventID == eFactionWhBattleSuperBossAward then
		local cfg = i3k_db_crossRealmPVE_cfg.battleMapSuperBoss
		local monsterID = eventInfo.iArg == 0 and cfg.superBossEggID or cfg.superBossID
		local monsterName = g_i3k_db.i3k_db_get_monster_name(monsterID)
		str = i3k_get_string(1333, monsterName, awardItemDesc)
	elseif eventInfo.eventID == eFactionWhAllotAward then
		local value = g_i3k_db.i3k_db_get_award_item_isDonate(eventInfo.items)

		if value and eventInfo.sArg ~= g_i3k_game_context:GetRoleName() then
			str = i3k_get_string(1334, i3k_get_string(1450), awardItemDesc)
		else
			str = i3k_get_string(1334, eventInfo.sArg, awardItemDesc)
		end
	elseif eventInfo.eventID == eFactionWhPirceChange then
		local arg = string.split(eventInfo.sArg, "|") -- arg[1] roleName arg[2] 道具ID arg[3] 点数
		str = i3k_get_string(1335, arg[1], i3k_db_get_common_item_name(tonumber(arg[2])), arg[3])
	elseif eventInfo.eventID == eFactionWhFactionDonate then
		str = i3k_get_string(1451, eventInfo.sArg, awardItemDesc)
	end

	return str
end


--判断是否开启百万答题（开启则科举关闭）
function i3k_db_get_millions_answer_is_open()
	return g_i3k_db.i3k_db_get_open_answer_type() == g_ANSWER_TYPE_MILLIONS
end

--判断是否显示百万答题
function i3k_db_get_millions_answer_is_show()
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	local isOpen = g_i3k_db.i3k_db_get_millions_answer_is_open()

	local pushTime = i3k_db_millions_answer_cfg.openTime - i3k_db_millions_answer_cfg.pushTime
	local showTime = i3k_db_millions_answer_cfg.rewardTime + i3k_db_millions_answer_cfg.showTime
	local isShow = g_i3k_checkIsInTodayTime(pushTime, showTime)
	return isOpen and isShow
end

--获取百万答题题目
function i3k_db_get_millions_answer_question(groupId, id)
	for _, v in ipairs(i3k_db_millions_answer_question) do
		if v.groupId == groupId and v.id == id then
			return v
		end
	end
	return nil
end

-- 获取五转需要的等级
function i3k_db_get_five_trans_level_requre()
	return i3k_db_zhuanzhi[1][5][1].needLV
end

--获取武绝按钮的显示等级
function i3k_db_get_wujue_level_require()
	return i3k_db_wujue.showLevel
end
--获取气功(心法)的显示等级
function i3k_db_get_qigong_level_require()
	return i3k_db_common.functionHide.xinfaHideLvl
end
--获取经脉的显示等级
function i3k_db_get_meridian_level_require()
	return i3k_db_meridians.common.limitLvl
end
function i3k_db_get_sub_task_last_task_name(id)
	local cfg = i3k_db_subline_task[id]
	return cfg[#cfg].name
end

-- 获取头像，index，正邪，男女
function i3k_db_get_five_trans_headicon(index)
	local cfg = i3k_db_five_trans[index]
	local bwType = g_i3k_game_context:GetTransformBWtype()
	local isFemale = g_i3k_game_context:IsFemaleRole()
	local id = 1
	if bwType == 1 then
		if not isFemale then
			id = 1
		else
			id = 2
		end
	elseif bwType == 2 then
		if not isFemale then
			id = 3
		else
			id = 4
		end
	end
	return cfg.rewards[id]
end

-- 区别心法和技能的一个标志(负数为心法，正数为技能)
function i3k_db_get_fiveTrans_skill_xinfa_tag(tag)
	return -tag
end
-- 与上面函数相反，输出作为输入，输入作为输出
function i3k_db_get_five_trans_xinfa_ID(tag)
	return -tag
end
function i3k_db_get_five_trans_is_skill(tag)
	return tag > 0
end
-- 五转技能互斥  需求：五转和三转的冲突
function i3k_db_check_skill_mutex(s1, pos)
	local roleSkills = g_i3k_game_context:GetRoleSelectSkills()
	for k, v in ipairs(roleSkills) do
		if k ~= pos then -- 和其它的3个技能比较
			local mutexSkillID = i3k_db_skills[s1].mutexSkillID
			if mutexSkillID ~= 0 and mutexSkillID == v then
				return true, v
			end
		end
	end
	return false
end

-- 职业心法书可装备数量
function i3k_db_get_professional_xinfa_count()
	local dbCount = i3k_db_common.spiritBook.zhiyeCount
	local info = g_i3k_game_context:getFiveTrans() -- 服务器同步过来的是从0开始为1阶
	local fiveTransCount = i3k_db_five_trans[info.level] and i3k_db_five_trans[info.level].extBookCount or 0
	return dbCount + fiveTransCount
end

function i3k_db_get_single_challenge_groupInfo(curMapGroup)
	for _, v in ipairs(i3k_db_single_challenge_group) do
		if v.groupId == curMapGroup then
			return v
		end
	end
	return nil
end

function i3k_db_get_single_challenge_buffInfo(buffId)
	for _, v in ipairs(i3k_db_single_challenge_buff) do
		if v.buffId == buffId then
			return v
		end
	end
	return nil
end

--单人闯关副本是否显示文本
function i3k_db_single_challenge_dungeon(mapId)
	if i3k_db_rightHeart2[mapId] and i3k_db_rightHeart2[mapId].challengeTargetDesc > 0 then
		return true
	end
	return false
end
----------------------- 魂玉附灵 ----------------------
function i3k_db_get_hunyu_fuling_level()
	return i3k_db_LongYin_arg.fuling -- fuling = {showLevel = 78, openLevel = 80},
end
function i3k_db_fuling_stars_by_curLevel(level)
	if not i3k_db_longyin_sprite[level] then
		return 0
	end
	return i3k_db_longyin_sprite[level].stars
end
function i3k_db_get_fuling_props(curLevel)
	local result = {}
	if not i3k_db_longyin_sprite[curLevel] then
		return {}
	end
	local props = i3k_db_longyin_sprite[curLevel].props
	for k, v in ipairs(props) do
		local id = v.id
		local count = v.count
		if not result[id] then
			result[id] = count
		else
			result[id] = result[id] + count
		end
	end
	return result
end
function i3k_db_get_fuling_nextLevel_props(curLevel)
	local result = {}
	if curLevel == #i3k_db_longyin_sprite then
		return result
	end
	local props = i3k_db_longyin_sprite[curLevel + 1].props
	for k, v in ipairs(props) do
		local id = v.id
		local count = v.count
		if not result[id] then
			result[id] = count
		else
			result[id] = result[id] + count
		end
	end
	return result
end

-- 返回small中存在的属性，但是big中不存在的那部分
function i3k_db_get_props_min(big, small)
	local result = {}
	for k, v in pairs(small) do
		if not big[k] then
			result[k] = v
		end
	end
	return result
end

function i3k_db_get_fuling_consumes(curLevel)
	if not i3k_db_longyin_sprite[curLevel] then
		return {} -- 超了范围了
	end
	return i3k_db_longyin_sprite[curLevel].comsumes
end

function i3k_db_get_fuling_success_rate(curLevel)
	if not i3k_db_longyin_sprite[curLevel] then
		return 0
	end
	local rate = i3k_db_longyin_sprite[curLevel].successRate
	return rate / 100
end

function i3k_db_get_fuling_must_success_times(curLevel)
	if not i3k_db_longyin_sprite[curLevel] then
		return 0
	end
	local times = i3k_db_longyin_sprite[curLevel].mustSuccessTimes
	return times
end
-- function i3k_db_get_fuling_name(curLevel)
-- 	if curLevel == 0 then
-- 		return "一阶"
-- 	end
-- 	if not i3k_db_longyin_sprite[curLevel] then
-- 		return ""
-- 	end
-- 	local name = i3k_db_longyin_sprite[curLevel].name
-- 	return name
-- end

function i3k_db_get_fuling_icon(curLevel)
	if curLevel == 0 then
		return i3k_db_longyin_sprite[1].icon
	end
	return i3k_db_longyin_sprite[curLevel].icon
end

function i3k_db_get_fuling_available_points(curLevel)
	if curLevel == 0 then
		return 0
	end
	if curLevel > #i3k_db_longyin_sprite then
		return i3k_db_longyin_sprite[#i3k_db_longyin_sprite].pointsAvailable
	end
	local points = i3k_db_longyin_sprite[curLevel].pointsAvailable
	return points
end
function i3k_db_get_fuling_upLimit_points(curLevel)
	if curLevel == 0 then
		return 0
	end
	if curLevel > #i3k_db_longyin_sprite then
		return i3k_db_longyin_sprite[#i3k_db_longyin_sprite].pointsUp
	end
	local points = i3k_db_longyin_sprite[curLevel].pointsUp
	return points
end

function i3k_db_get_wuxing_props(index, points)
	local cfg = i3k_db_longyin_sprite_addPoint[index][points]
	local result = {}
	if not cfg then
		return {}
	end

	local preID = g_i3k_db.i3k_db_get_wuxing_pre_index(index)
	local wuxingID = g_i3k_db.i3k_db_get_wuxing_index(preID, #i3k_db_longyin_sprite_addPoint)
	local percent =  g_i3k_game_context:getXiangshengPercent(wuxingID)

	for k, v in ipairs(cfg.props) do
		local id = v.id
		local count = v.count
		if not result[id] then
			result[id] = math.floor(count * (1 + percent))
		else
			result[id] = result[id] + math.floor(count * (1 + percent))
		end
	end
	return result
end
function i3k_db_get_wuxing_next_level_props(index, points)
	local cfg = i3k_db_longyin_sprite_addPoint[index]
	if not cfg[points + 1] then
		return {}
	end
	local result = {}

	local preID = g_i3k_db.i3k_db_get_wuxing_pre_index(index)
	local wuxingID = g_i3k_db.i3k_db_get_wuxing_index(preID, #i3k_db_longyin_sprite_addPoint)
	local percent =  g_i3k_game_context:getXiangshengPercent(wuxingID)

	for k, v in ipairs(cfg[points + 1].props) do
		local id = v.id
		local count = v.count
		if not result[id] then
			result[id] = math.floor(count * (1 + percent))
		else
			result[id] = result[id] + math.floor(count * (1 + percent))
		end
	end
	return result
end

function i3k_db_get_wuxing_index(id, size)
	local a = id
	local b = (id == size) and 1 or id + 1
	return a * 10 + b
end

function i3k_db_get_wuxing_pre_index(id)
	 return id - 1 == 0 and #i3k_db_longyin_sprite_addPoint or id - 1
end

-- return 2 icon id
function i3k_db_get_wuxing_xiangsheng_icons(id, size)
	local a = id
	local b = (id == size) and 1 or id + 1
	local icon1 = i3k_db_longyin_sprite_addPoint[a][1].icon
	local icon2 = i3k_db_longyin_sprite_addPoint[b][1].icon
	return icon1, icon2
end

-- k,v 结构的两个表做加和
function i3k_db_merge_props(a, b)
	local result = {}
	for k, v in pairs(b) do
		if not result[k] then
			result[k] = v
		else
			result[k] = result[k] + v
		end
	end
	for k, v in pairs(a) do
		if not result[k] then
			result[k] = v
		else
			result[k] = result[k] + v
		end
	end
	return result
end
-- props: k, v； return a array
function i3k_db_sort_props(props)
	local result = {}
	for k, v in pairs(props) do
		table.insert(result, {id = k, value = v})
	end
	table.sort(result, function(a, b)
		return a.id < b.id
	end)
	return result
end

function i3k_db_get_other_fuling_props(fuling)
	if not fuling then
		return {}
	end

	local level = fuling.curLvl
	local props = g_i3k_db.i3k_db_get_fuling_props(level)

	local props2 = {}
	for k, v in pairs(fuling.addPoints) do
		local cfg = i3k_db_longyin_sprite_addPoint[k]
		local props = cfg[v].props
		for i, e in ipairs(props) do
			local id = e.id
			local count = e.count
			if not props2[id] then
				props2[id] = count
			else
				props2[id] = props2[id] + count
			end
		end
	end

	local props3 = {}
	for k, v in pairs(fuling.upEachOther) do
		local cfg = i3k_db_longyin_sprite_born[k]
		local type = cfg[v].effectType -- 这种类型的，对应 i3k_db_longyin_sprite_addPoint 表中的属性
		local percent = cfg[v].effectCount / 10000
		local level2 = fuling.addPoints[type] -- 可能为空
		if level2 then
			local props = i3k_db_longyin_sprite_addPoint[type][level2].props
			if props then
				for i, e in ipairs(props) do
					local id = e.id
					local count = e.count
					if not props3[id] then
						props3[id] = math.floor(count * percent)
					else
						props3[id] = props3[id] + math.floor(count * percent)
					end
				end
			end
		end
	end

	local m1 = g_i3k_db.i3k_db_merge_props(props, props2)
	local m2 = g_i3k_db.i3k_db_merge_props(m1, props3)
	return m2
end

function i3k_db_fuling_stage_by_curLevel(level)
	if not i3k_db_longyin_sprite[level] then
		return 0
	end
	return i3k_db_longyin_sprite[level].fulingStage
end
-- 获得当前可购买分配点的数量(buyPointCnt>=1)
function i3k_db_fuling_can_add_point(buyPointCnt)
	if buyPointCnt == 1 then
		return i3k_db_longyin_sprite_buy_point[buyPointCnt].totalBuyPoints
	end
	local preBuyPoints = i3k_db_longyin_sprite_buy_point[buyPointCnt - 1].totalBuyPoints
	local nextBuyPoints = i3k_db_longyin_sprite_buy_point[buyPointCnt].totalBuyPoints
	return nextBuyPoints - preBuyPoints
end
-- 获得当前已购买分配点的数量(buyPointCnt>=0)
function i3k_db_fuling_have_buy_points(buyPointCnt)
	if buyPointCnt == 0 then
		return 0
	end
	buyPointCnt = buyPointCnt >= #i3k_db_longyin_sprite_buy_point and #i3k_db_longyin_sprite_buy_point or buyPointCnt
	local haveBuyPoint = i3k_db_longyin_sprite_buy_point[buyPointCnt].totalBuyPoints
	return haveBuyPoint
end
-- 获得最大购买分配点的数量
function i3k_db_fuling_max_buy_points()
	local maxBuyPointCnt = #i3k_db_longyin_sprite_buy_point
	return i3k_db_longyin_sprite_buy_point[maxBuyPointCnt].totalBuyPoints
end
---------------------------------------------
--帮派助战开启限制
function i3k_db_is_faction_assist_open()
	local roleLevel = g_i3k_game_context:GetLevel()
	local factionLevel = g_i3k_game_context:getSectFactionLevel()
	if roleLevel >= i3k_db_faction_assist.needPlayerLvl and factionLevel >= i3k_db_faction_assist.needFactionLvl then
		return true
	end
	return false
end
--帮派战是否在开启时间
function i3k_db_is_open_bangpaizhan()
	local data=i3k_db_get_bangpaizhan_Starttime(true)
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	return data.year == year and data.month == month and data.day == day
end
--返回帮派战开启时间
function i3k_db_get_bangpaizhan_Starttime(isgetday)
	local data=i3k_db_faction_fight_openday
    local endTime = string.split(i3k_db_faction_fight_cfg.timebucket[#i3k_db_faction_fight_cfg.timebucket].endfight, ":")
	local timeNow= g_i3k_get_GMTtime(i3k_game_get_time())
	for k ,v  in ipairs(data) do
		local dataY = string.sub(v.openday, 1, 4)
        local dataMon = string.sub(v.openday, 6, 7)
        local dataD = string.sub(v.openday, 9, 10)
		local timedata= os.time({year = dataY, month = dataMon, day = dataD, hour = isgetday and 23 or endTime[1], min =isgetday and 59 or endTime[2], sec =isgetday and 59 or endTime[3] })
		if timeNow<=timedata then
			return {year=dataY,month=dataMon,day=dataD}
		end
	end
	return {year=string.sub(data[#data].openday, 1, 4),month=string.sub(data[#data].openday, 6, 7),day=string.sub(data[#data].openday, 9, 10)}
end
-------势力声望 begin-----------------------------
function i3k_db_get_npc_icon_by_id(id)
	local mosterid = i3k_db_npc[id].monsterID
	local iconId = g_i3k_db.i3k_db_get_head_icon_id(id)
	return g_i3k_db.i3k_db_get_head_icon_path(iconId)
end

function i3k_db_get_power_reputation_info(index)
	local cfg = i3k_db_power_reputation[index]
	local npcLeaderCfg = i3k_db_npc[cfg.npcLeader]
	local npcLeader =
	{
		icon = g_i3k_db.i3k_db_get_npc_icon_by_id(cfg.npcLeader),
		name = npcLeaderCfg.remarkName,
	}

	local npcSupportCfg = i3k_db_npc[cfg.npcSupport]
	local npcSupport =
	{
		icon = g_i3k_db.i3k_db_get_npc_icon_by_id(cfg.npcSupport), -- i3k_db_monsters[npcSupportCfg.monsterID].icon,
		name = npcSupportCfg.remarkName,
		functionName = i3k_get_string(17282),--"军需官",
		transNpcID = cfg.npcTeleport,
	}
	local npcCommitTrans ={}
	if cfg.npcCommitTrans ~= 0 then
	local npcCommitTransCfg = i3k_db_npc[cfg.npcCommitTrans]
		npcCommitTrans =
	{
		icon = g_i3k_db.i3k_db_get_npc_icon_by_id(cfg.npcCommitTrans), -- i3k_db_monsters[npcCommitTransCfg.monsterID].icon,
		name = npcCommitTransCfg.remarkName,
		functionName = i3k_get_string(17281), --"捐赠npc",
		transNpcID = cfg.npcCommitTrans,
	}
	else
	end
	local npcTaskTransCfg = i3k_db_npc[cfg.npcTaskTrans]
	local npcTaskTrans =
	{
		icon = g_i3k_db.i3k_db_get_npc_icon_by_id(cfg.npcTaskTrans), -- i3k_db_monsters[npcTaskTransCfg.monsterID].icon,
		name = npcTaskTransCfg.remarkName,
		functionName = i3k_get_string(17280), --"任务npc",
		transNpcID = cfg.npcTaskTrans,
	}

	local res =
	{
		name = cfg.name,
		desc = cfg.desc,
		icon = cfg.icon,
		npcTeleport = cfg.npcTeleport,
		npcLeader = npcLeader,
		npcs = {npcSupport, npcCommitTrans, npcTaskTrans},
		desc2 = cfg.desc2,
	}

	return res
end

-- 根据npcid，获取对应的势力（如果为空，则配置的有问题）
function i3k_db_power_rep_get_type_by_npcid(npcID)
	for k, v in ipairs(i3k_db_power_reputation_npc) do
		if v.npcID == npcID  then
			return v.powerSide
		end
	end
	error("npc power side not found:"..npcID)
	return nil
end

function i3k_db_power_rep_get_task_npcs(powerSide)
	local npcs = {}
	for k, v in ipairs(i3k_db_power_reputation_npc) do
		if v.powerSide == powerSide and v.taskGroupID ~= 0 then
			table.insert(npcs, v.npcID)
		end
	end
	return npcs
end

-- 根据npcid，获取对应的任务库分组，再根据同步的信息，获取对应任务库的配置
function i3k_db_power_rep_get_taskCfg_by_npcid(npcID)
	local taskGroupID = g_i3k_db.i3k_db_power_rep_get_task_groupID(npcID)
	local info = g_i3k_game_context:getPowerRep()
	local taskID = info.tasks[taskGroupID].id
	local cfg = i3k_db_power_reputation_task[taskGroupID][taskID]
	return cfg
end
function i3k_db_power_rep_get_task_groupID(npcID)
	local taskGroupID = nil
	for k, v in ipairs(i3k_db_power_reputation_npc) do
		if npcID == v.npcID then
			taskGroupID = v.taskGroupID
			break
		end
	end
	assert(taskGroupID ~= nil, "npc:"..npcID.." 对应的任务分组id没找到,请检查 势力声望表.xlsx")
	return taskGroupID
end


-- 获取声望值对应的等级配置
function i3k_db_power_rep_get_level(value)
	if value <= i3k_db_power_reputation_level[1].min then
		return 1
	end

	if value >= i3k_db_power_reputation_level[#i3k_db_power_reputation_level].max then
		return #i3k_db_power_reputation_level
	end

	for k, v in ipairs(i3k_db_power_reputation_level) do
		if v.min <= value and value <= v.max then
			return k
		end
	end
end

function i3k_db_power_rep_get_text_and_levelName(value)
	local level = g_i3k_db.i3k_db_power_rep_get_level(value)
	local levelCfg = i3k_db_power_reputation_level[level]
	local levelName = levelCfg.name
	local levelMin = levelCfg.min
	local levelMax = levelCfg.max
	local color = levelCfg.textColor
	local percent = math.floor((value - levelMin ) / (levelMax - levelMin + 1) * 100)
	if percent > 100 then
		percent = 100
	end
	local cur = (value - levelMin ) > 0 and (value - levelMin ) or 0
	local text =  cur .."/".. (levelMax - levelMin + 1)
	return {text = text, percent = percent, levelName = levelName, color = color}
end

-- 将势力声望任务的db进行一个格式转换
function i3k_db_power_rep_convert_db(powerRepTaskCfg)
	local cfg = {type = powerRepTaskCfg.taskConditionType, arg1 = powerRepTaskCfg.args[1], arg2 = powerRepTaskCfg.args[2],
		arg3 = powerRepTaskCfg.args[3], arg4 = powerRepTaskCfg.args[4], arg5 = powerRepTaskCfg.args[5], finishTaskDesc = "0.0", finishTaskNpcID = powerRepTaskCfg.npcID} -- 重新组织下数据结构
	return cfg
end

function i3k_db_power_rep_get_taskCfg_by_hash(hash)
	local groupID, id = g_i3k_db.i3k_db_get_power_rep_task_real_id(hash)
	local taskCfg = i3k_db_power_reputation_task[groupID][id]
	return taskCfg
end

function i3k_db_power_rep_get_commit_cfg(powerSide, id)
	return i3k_db_power_reputation_commit[powerSide][id]
end

function i3k_db_power_rep_get_open_min_level()
	local level = 999
	for k, v in ipairs(i3k_db_power_reputation) do
		if v.openLevel < level then
			level = v.openLevel
		end
	end
	return level
end

function i3k_db_power_rep_get_against_powerSide(powerSide)
	return i3k_db_power_reputation[powerSide].againstID
end

function i3k_db_power_rep_get_npcID_by_group(groupID)
	for k, v in ipairs(i3k_db_power_reputation_npc) do
		if v.taskGroupID == groupID then
			local openLevel = i3k_db_power_reputation[v.powerSide].openLevel
			return v.npcID, openLevel
		end
	end
end

function i3k_db_power_rep_check_npc_in_list(list, npcID)
	for k, v in ipairs(list) do
		if v.npcID == npcID then
			return true, v.show
		end
	end
	return false, false
end

function i3k_db_power_rep_get_itemID(powerSide)
	return i3k_db_power_reputation[powerSide].itemID
end

--------------------------------------
---------520活动 结婚打折-----------------------
function i3k_db_get_is_weeding_discount()
	local cfg = i3k_db_common.weddingDiscount
	local startDate = cfg.openDate
	local endDate = cfg.endDate
	local time = i3k_game_get_time()
	if g_i3k_get_GMTtime(time) < startDate or g_i3k_get_GMTtime(time) > endDate then
		return false
	end
	return true
end

function i3k_db_get_weeding_discount()
	local cfg = i3k_db_common.weddingDiscount
	local res = {}
	for k, v in pairs(cfg.discountID) do
		res[v] = cfg.discountPercent[v]
	end
	return res
end

function i3k_db_get_is_activity_perfect_open(id)
	local cfg = i3k_db_activity_perfect[id]
	local startDate = cfg.openDate
	local endDate = cfg.endDate
	local time = i3k_game_get_time()
	if g_i3k_get_GMTtime(time) < startDate or g_i3k_get_GMTtime(time) > endDate then
		return false
	end
	return true
end

function i3k_db_get_is_activity_perfect_can_get_reward(id)
	return true
	-- local cfg = i3k_db_activity_perfect[id]
	-- local dayStartTime = cfg.dayTimeStart
	-- local dayEndTime = cfg.dayTimeEnd
	-- return g_i3k_checkIsInTodayTime(dayStartTime, dayEndTime)
end

function i3k_db_get_is_activity_world_can_get_reward(id)
	return true
	-- local cfg = i3k_db_activity_world[id]
	-- local dayStartTime = cfg.dayTimeStart
	-- local dayEndTime = cfg.dayTimeEnd
	-- return g_i3k_checkIsInTodayTime(dayStartTime, dayEndTime)
end

function i3k_db_get_is_activity_world_open(id)
	local cfg = i3k_db_activity_world[id]
	local startDate = cfg.openDate
	local endDate = cfg.endDate
	local time = i3k_game_get_time()
	if g_i3k_get_GMTtime(time) < startDate or g_i3k_get_GMTtime(time) > endDate then
		return false
	end
	return true
end
--------------------------------------

--判断是否在珍珑棋局任务时间内
function i3k_db_is_in_chess_task_time()
	if g_i3k_checkIsInDate(i3k_db_chess_board_cfg.openDate, i3k_db_chess_board_cfg.closeDate - 86400) then
		local week = g_i3k_get_week(g_i3k_get_day(i3k_game_get_time()))
		for k, v in ipairs(i3k_db_chess_board_cfg.openWeekday) do
			if v == week then
				return g_i3k_checkIsInTodayTime(i3k_db_chess_board_cfg.openTime, i3k_db_chess_board_cfg.openTime + i3k_db_chess_board_cfg.continue)
			end
		end
	end
end

--获取珍珑棋局剩余时间
function i3k_db_get_chess_task_left_time()
	local nowTime = i3k_game_get_time()%86400
	return i3k_db_chess_board_cfg.continue + i3k_db_chess_board_cfg.openTime - nowTime
end

-- 通过经脉ID获取经脉气海
function i3k_db_get_geasea_from_meridianID(meridianID, holes)
	local cfg = i3k_db_meridians
	local geaSea = 0
	local meridiansCfg = cfg.meridians[meridianID]
	local acupIds = meridiansCfg.acupuncturePointIds
	for i, e in ipairs(acupIds) do
		if i == #acupIds then
			geaSea = geaSea + holes[e].energy * holes[acupIds[1]].energy
		else
			geaSea = geaSea + holes[e].energy * holes[acupIds[i + 1]].energy
		end
	end
	return math.floor( math.sqrt(geaSea) * cfg.common.areasFactor)
end

function i3k_db_is_fashion_match_wear_bwtype(id, bwtype)
	local cfg = i3k_db_fashion_dress[id]
	if cfg then
		return cfg.wearBWType == 0 or cfg.wearBWType == bwtype
	end
	return false
end

--[[
-- 数据结构参考
growInfo = {
	--growTime = 0,  -- 原本的成长时间
	plantLvlReduceTime = 0, -- 因种植等级减少的时间
	waterTimes = 0,   -- 这个状态的浇水次数
	waterReduceTime = 0, -- 因浇水减少的时间
	realGrowTime = 0, -- 计算后的该阶段成长时间
	timeStamp = 0,   -- 此状态结束时间戳
	curLeftTime = 0, -- 计算时距离此状态结束还剩余的时间
}
--]]
-- 读表判断当前的家园作物的状态
function i3k_db_getCurPlantStep(plant, plantCfg)
	if not plantCfg then
		plantCfg = i3k_db_home_land_corp[plant.id]
	end

	local state = g_CROP_STATE_MATURE
	local time = i3k_game_get_time() -- 获取当前时间
	local cfg = i3k_db_home_land_base.plantCfg
	local plc = i3k_db_home_land_plant_lvl[plant.plantLevel]-- 获取玩家种植等级

	local setNewTime = function(growTime, curState)
		local growInfo = {}
		--growInfo.growTime = growTime -- 暂时没有用
		growInfo.plantLvlReduceTime = growTime * plc.reduceTimePercent / 10000.0
		growInfo.waterTimes = g_i3k_game_context:getWaterTimes(plant, curState)
		growInfo.waterReduceTime = math.max(growTime * cfg.waterDecreaseTimeRate / 10000.0, cfg.waterDecreaseMinTime) * growInfo.waterTimes
		growInfo.realGrowTime = growTime - (growInfo.plantLvlReduceTime + growInfo.waterReduceTime)

		return growInfo
	end

	local seedInfo = setNewTime(plantCfg.seedlingTime, g_CROP_STATE_SEED)
	seedInfo.timeStamp = plant.plantTime + seedInfo.realGrowTime
	seedInfo.curLeftTime = seedInfo.timeStamp - time

	local strongInfo = setNewTime(plantCfg.strongTime, g_CROP_STATE_STRONG)
	strongInfo.timeStamp = plant.plantTime + seedInfo.realGrowTime + strongInfo.realGrowTime
	strongInfo.curLeftTime = strongInfo.timeStamp - time

	if (time < seedInfo.timeStamp) then
		state = g_CROP_STATE_SEED
	elseif (time < strongInfo.timeStamp) then
		state = g_CROP_STATE_STRONG
	else
		state = g_CROP_STATE_MATURE
	end
	return state, seedInfo, strongInfo
end

-- 获取拼接植物名字
function i3k_db_getCropNameByState(ground, state)
	local name = ""
	if state == g_CROP_STATE_LOCK then
		name = i3k_get_string(5105)
	elseif state == g_CROP_STATE_UNLOCK then
		name = i3k_get_string(5106)
	elseif state == g_CROP_STATE_SEED then
		name = ground._plantCfg.corpName.." - "..i3k_get_string(5107)
	elseif state == g_CROP_STATE_STRONG then
		name = ground._plantCfg.corpName.." - "..i3k_get_string(5108)
	elseif state == g_CROP_STATE_MATURE then
		name = ground._plantCfg.corpName.." - "..i3k_get_string(5109)
	end
	return name
end

-- 获取当前土地等级解锁的植物
function i3k_db_getUnlockCropByGround(ground, level)
	local itemCfgs = {}
	local groundType, groundLevel = ground.groundType, level or ground.level
	for id, cfg in pairs(i3k_db_home_land_corp) do
		if groundType then
			if groundType == cfg.corpType and groundLevel >= cfg.groundLvlLimit then
				table.insert(itemCfgs, cfg)
			end
		elseif groundLevel >= cfg.groundLvlLimit then
			table.insert(itemCfgs, cfg)
		end
	end
	return itemCfgs
end

-- 获取当前种植等级解锁的植物
function i3k_db_getUnlockCropByPoint(ground, level)
	local itemCfgs = {}
	local groundType, groundLevel = ground.groundType, level or ground.level
	for id, cfg in pairs(i3k_db_home_land_corp) do
		if groundType then
			if groundType == cfg.corpType and groundLevel >= cfg.plantLvlLimit then
				table.insert(itemCfgs, cfg)
			end
		elseif groundLevel >= cfg.plantLvlLimit then
			table.insert(itemCfgs, cfg)
		end
	end
	return itemCfgs
end

function i3k_db_getUnlockCropNameByGround(ground, level)
	local desc = ""
	local t = i3k_db.i3k_db_getUnlockCropByGround(ground, level)
	for index = 1, #t - 1, 1 do
		desc = desc..t[index].corpName.."、"
	end
	local last = t[#t]
	if last then
		desc = desc..last.corpName
	end
	if desc == "" then
		desc = i3k_get_string(15443)
	end
 	return desc
end

function i3k_db_getUnlockCropNameByPoint(ground, level)
	local desc = ""
	local t = i3k_db.i3k_db_getUnlockCropByPoint(ground, level)
	for index = 1, #t - 1, 1 do
		desc = desc..t[index].corpName.."、"
	end
	local last = t[#t]
	if last then
		desc = desc..last.corpName
	end
	if desc == "" then
		desc = i3k_get_string(15443)
	end
 	return desc
end

-- 获取当前必然掉落的钓鱼奖励
function i3k_db_getUnlockFishName(level)
	local desc = ""
	local cfg = i3k_db_home_land_fish_master[level]
	local t = cfg and cfg.dropItems
	if t then
		for index = 1, #t - 1, 1 do
--[[			local dropCfg = i3k_db_drop_cfg[dropId]
			if dropCfg then
				desc = desc..g_i3k_db.i3k_db_get_common_item_name(dropCfg.dropid).."、"
			end--]]
			desc = desc..g_i3k_db.i3k_db_get_common_item_name(t[index]).."、"
		end
		local last = t[#t]
		if last then
			desc = desc..g_i3k_db.i3k_db_get_common_item_name(last)
		end
	end

	if desc == "" then
		desc = i3k_get_string(15443)
	end
 	return desc
end

-- 判断浇水是否已达上限
function i3k_db_checkWaterCropTimesLimit(ground, state)
	if not state then
		state = self:i3k_db_getCurPlantStep(ground.curPlant)
	end
	local times = g_i3k_game_context:getWaterTimes(ground.curPlant, state)
	if state == g_CROP_STATE_SEED then
		return times >= i3k_db_home_land_base.baseCfg.seedWaterLimit, times, i3k_db_home_land_base.baseCfg.seedWaterLimit
	elseif state == g_CROP_STATE_STRONG then
		return times >= i3k_db_home_land_base.baseCfg.strongWaterLimit, times, i3k_db_home_land_base.baseCfg.strongWaterLimit
	end
	return true, 0, 0
end

-- 获取操作cd
function i3k_db_getWaterLeftTime(plant)
	return plant.lastWaterTime + i3k_db_home_land_base.plantCfg.waterCD - i3k_game_get_time()
end

function i3k_db_getCareLeftTime(plant)
	return plant.lastNurseTime + i3k_db_home_land_base.plantCfg.careCD - i3k_game_get_time()
end

function i3k_db_getHarvestLeftTime(plant)
	return plant.lastHarvestTime + i3k_db_home_land_base.plantCfg.harvestCD - i3k_game_get_time()
end

function i3k_db_getStealLeftTime(plant)
	return plant.lastStealTime + i3k_db_home_land_base.plantCfg.stealCD - i3k_game_get_time()
end

-- 判断是否超过cd
function i3k_db_checkCanWaterCrop(ground)
	return i3k_game_get_time() > ground.curPlant.lastWaterTime + i3k_db_home_land_base.plantCfg.waterCD
end

function i3k_db_checkCanCareCrop(ground)
	return i3k_game_get_time() > ground.curPlant.lastNurseTime + i3k_db_home_land_base.plantCfg.careCD
end

function i3k_db_checkCanHarvestCrop(ground)
	return i3k_game_get_time() > ground.curPlant.lastHarvestTime + i3k_db_home_land_base.plantCfg.harvestCD
end

function i3k_db_checkCanStealCrop(ground)
	return i3k_game_get_time() > ground.curPlant.lastStealTime + i3k_db_home_land_base.plantCfg.stealCD
end

-- 判断收获次数是否超过
function i3k_db_checkHarvestFinished(ground)
	return ground.curPlant.harvestTimes >= i3k_db_home_land_base.plantCfg.harvestTimes
end

-- 判断护理次数是否超过
function i3k_db_checkCareFinished(ground)
	return ground.curPlant.nurseTimes >= i3k_db_home_land_base.plantCfg.careMaxTimes
end

-- 收获次数获取
function i3k_db_getHarvestTimes(ground)
	return ground.curPlant.harvestTimes, i3k_db_home_land_base.plantCfg.harvestTimes
end

-- 护理次数获取
function i3k_db_getCareTimes(ground)
	return ground.curPlant.nurseTimes, i3k_db_home_land_base.plantCfg.careMaxTimes
end

-- 根据地块等级获取地块的模型id
function i3k_db_getGroundEmptyModelID(groundId)
	local groundCfg = i3k_db_home_land_plantArea[groundId] or i3k_db_home_land_plantArea[1]
	return groundCfg.emptyModelID
end

-- shapeType: 1 圆点区域检测 2 矩形检测
-- function: 判断传入位置是否在区域中，返回区域类型
--return arg1: 区域类型; arg2:区域朝向点,可为空
function i3k_db_get_area_type_arg(pos)
	--checkAreaWorldType radius说明： 所有区域检测半径一样配置
	local checkAreaWorldType = {
		[g_HOME_LAND] 	= {
			[1] = {areaCfg = function() return i3k_db_home_land_fishArea end, areaType = g_HOMELAND_FISH_AREA, shapeType = 1},
		},
		[g_MAGIC_MACHINE]	= {
			[1] = {areaCfg = function() 
					local route = g_i3k_game_context:getMagicMachineRouteId()
					return i3k_db_move_road_points[route] and i3k_db_move_road_points[route].arrayPoints
				end, areaType = g_GODMACHINE_NPC_PATH_AREA, shapeType = 1, radius = i3k_db_magic_machine.machinePosRadius},
			[2] = {areaCfg = function() return {i3k_db_magic_machine.rectanglePoints} end, areaType = g_GODMACHINE_SLOW_AREA, shapeType = 2},
		},
		[g_SPY_STORY] = {
			[1] = {
				areaCfg = function () return i3k_db_spy_story_base.rectanglePoints end, areaType = g_SPY_STORY_AREA, shapeType = 2, 
			}
		}
	}
	local worldType = g_i3k_game_context:GetWorldMapType()
	local checkCfg = checkAreaWorldType[worldType]
	if checkCfg then
		for _, e1 in ipairs(checkCfg) do
			local cfg = e1.areaCfg()
			if cfg then
				if e1.shapeType == 1 then				
					for _, e2 in ipairs(cfg) do					
						local radis = e2.radius or e1.radius										
						local posVec = i3k_vec3(e2.pos[1], e2.pos[2], e2.pos[3])
						local distance = i3k_vec3_dist(posVec, pos)
						if distance <= radis then
							return e1.areaType, e2.facePos						
						end
					end
				elseif e1.shapeType == 2 then
					for i,v in ipairs(cfg) do
						local isInRect = i3k_math_is_in_rect(v[1], v[2], v[3], v[4], pos)
					if isInRect then
						return e1.areaType
						end
					end
				end
			end			
		end
	elseif worldType == g_CATCH_SPIRIT then
		local points = g_i3k_game_context:getCatchSpiritPoint()
		local pointCD = g_i3k_game_context:getCatchSpiritPointCD()
		for k, _ in pairs(points) do
			local catchPos = i3k_db_catch_spirit_position[k].pos
			local posVec = i3k_vec3(catchPos[1], catchPos[2], catchPos[3])
			local distance = i3k_vec3_dist(posVec, pos)
			if distance < i3k_db_catch_spirit_position[k].radius / 100 then
				if i3k_game_get_time() - (pointCD[k] or 0) > i3k_db_catch_spirit_base.dungeon.callCold then
					return g_CATCH_SPIRIT_AREA
				end
			end
		end
	end

	return g_NOTIN_ANY_AREA
end
-- 通过配置路径点，获取移动点时间等信息
function i3k_db_get_move_point_info(points, speed)
	local movePointInfo = {}
	for i = 1, #points do
		local point = points[i]
		local nextPoint = points[i + 1]
		if nextPoint then
			local dis = i3k_vec3_dist(point, nextPoint)
			local time = dis / speed
			table.insert(movePointInfo, {point = point, nextPoint = nextPoint, time = time})
		end
	end
	return movePointInfo
end

-- 获取家园装备配置
function i3k_db_get_homeLandEquipCfg(equipID)
	return i3k_db_home_land_equip[equipID]
end

-- 家园事件
function i3k_db_get_home_land_event_desc(eventInfo)
	local dbCorp = i3k_db_home_land_corp
	local str = ""
	local eventType = eventInfo.type
	local iArgs = eventInfo.iArgs
	local vArgs = eventInfo.vArgs
	if eventType == g_HOMELAND_HISTORY_NURSE_OTHER then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17298, vArgs[1], dbCorp[corpID].corpName)
	elseif eventType == g_HOMELAND_HISTORY_NURSE_SELF then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17299, dbCorp[corpID].corpName)
	elseif eventType == g_HOMELAND_HISTORY_WATER_OTHER then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17300, vArgs[1], dbCorp[corpID].corpName)
	elseif eventType == g_HOMELAND_HISTORY_WATER_SELF then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17301, dbCorp[corpID].corpName)
	elseif eventType == g_HOMELAND_HISTORY_STEAL then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17302, vArgs[1], dbCorp[corpID].corpName, iArgs[2])
	elseif eventType == g_HOMELAND_HISTORY_DECORATE then
		--TODO 欢乐装备表未添加 少一个参数 增强加人气值
		local equipID = tonumber(iArgs[1]) -- 欢乐装备ID
		-- str = i3k_get_string(17303, vArgs[1], equipName, iArgs[2])
	elseif eventType == g_HOMELAND_HISTORY_HARVEST then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17304, dbCorp[corpID].corpName)
	elseif eventType == g_HOMELAND_HISTORY_EX_HARVEST then
		local corpID = tonumber(iArgs[1]) -- 作物id
		local exItemID = tonumber(iArgs[2]) -- 额外收获作物id
		local itemName =  g_i3k_db.i3k_db_get_common_item_name(exItemID)
		local exNumber = tonumber(iArgs[3]) -- 额外收获作物数量
		str = i3k_get_string(17305, dbCorp[corpID].corpName, itemName, exNumber)
	elseif eventType == g_HOMELAND_HISTORY_REMOVE then
		local corpID = tonumber(iArgs[1]) -- 作物id
		str = i3k_get_string(17306, dbCorp[corpID].corpName)
	elseif eventType == g_HOMELAND_HISTORY_ACTION_SELF then
		if iArgs[4] == 1 then
			str = i3k_get_string(17873, vArgs[1], vArgs[1], iArgs[3])
		else
			str = i3k_get_string(17872, vArgs[1], vArgs[1], iArgs[3])
		end
	elseif eventType == g_HOMELAND_HISTORY_ACTION_OTHER then
		if iArgs[4] == 1 then
			str = i3k_get_string(17875, vArgs[2], vArgs[1], vArgs[1], iArgs[3])
		else
			str = i3k_get_string(17874, vArgs[2], vArgs[1], vArgs[1], iArgs[3])
		end
	elseif eventType == g_HOMELAND_HISTORY_MOOD_REWARD then
		str = i3k_get_string(17876, vArgs[1])
	elseif eventType == g_HOMELAND_HISTORY_ACTION_PATCH then
		if iArgs[1] == 1 then
			str = i3k_get_string(17878)
		else
			str = i3k_get_string(17877)
		end
	end
	return str
end

function i3k_db_get_mood_diary_effect_uiid(itemID, popularity)
	for k, v in ipairs(i3k_db_mood_diary_gift) do
		if v.itemID == itemID then
			if v.animateUIId ~= 0 then
				return v.animateUIId
			end
		end
	end
	if i3k_db_mood_diary_cfg.showAnimateCondition <= popularity then
		return eUIID_MoodDiaryEffect
	end
end

--获取世界杯邮件描述
function i3k_db_get_world_cup_mail_str(additional)
	local des
	for i = 1, #i3k_db_world_cup_wager do
		if additional[1] == i3k_db_world_cup_wager[i].rank then
			des = i3k_db_world_cup_wager[i].des
			break
		end
	end
	return i3k_get_string(additional[3] == i3k_db_world_cup_other.wagerCoin and 1407 or 1406, i3k_db_world_cup_team[additional[2]].name, des, additional[3])
end

--判断世界杯这个国家开奖状态
function i3k_db_get_state_of_country(countryId,countryInfo)
	local shiji_record = countryInfo[countryId].record
	local yazhu_record = g_i3k_game_context:getWorldCupCountry(countryId).record
	local getOpenTime = function(record) --获取对应档次的开奖时间
		if record == g_WORLD_CUP_32 then
			return i3k_db_world_cup_other.returnCoinDate
		end
		for i = 1,#i3k_db_world_cup_wager do
			if i3k_db_world_cup_wager[i].rank == record then
				return i3k_db_world_cup_wager[i].date
			end
		end
	end
	local publish_time = getOpenTime(math.max(shiji_record,yazhu_record))--开奖日期 --取押注档位开奖日期和实际名次档位开奖日期的最小值，作为开奖日期，开奖日期之前不会告知结果（就算后端传过来结果也不显示）
	if g_i3k_get_GMTtime(i3k_game_get_time()) < publish_time then
		return 0
	else
		return shiji_record == yazhu_record and 1 or 2
	end
end

--判断是否已激活该坐骑
function i3k_db_get_steed_is_have(steedID)
	local steedInfo = g_i3k_game_context:getAllSteedInfo()
	if next(steedInfo) ~= nil then
		for _, v in pairs(steedInfo) do
			if v.id == steedID then
				return true
			end
		end
	end
	return false
end

--判断是不是单人坐骑(单人返回1，多人返回2, 获取失败返回0)
function i3k_db_get_steed_type(id)
	if i3k_db_steed_cfg[id] then
		local count = i3k_db_steed_cfg[id].rideCount
		return count > 1 and g_MORE_STEED or g_SINGLE_STEED
	else
		return 0
	end
end

function i3k_db_get_steed_count()
	local cnt = 0
	for k, v in pairs(i3k_db_steed_cfg) do
		if v.isShow == 1 then
			cnt = cnt + 1
		end
	end
	return cnt
end
--获取所有坐骑形象ID
function i3k_db_get_all_steed_spiritID()
	local baseSpiritID = {}
	local addSpiritID = {}
	for i, e in pairs(i3k_db_steed_fight_spirit_show) do
		if e.spiritType == 1 then
			table.insert(baseSpiritID, i)
		end

		if e.spiritType == 2 then
			table.insert(addSpiritID, i)
		end
	end

	table.sort(baseSpiritID)
	table.sort(addSpiritID)
	return baseSpiritID, addSpiritID
end



--------------心决---------------------------------
function i3k_db_check_use_items(list)
	for k,v in pairs(list) do
		local hava = g_i3k_game_context:GetCommonItemCanUseCount(v.id or v.itemId)
		if hava < v.count or v.itemCount then
			return false
		end
	end
	return true
end
--判断能否突破
function i3k_db_check_xinjue_consume_break()
	local level = g_i3k_game_context:getXinjueGrade() + 1
	if i3k_db_xinjue_level[level] then
		local consume = i3k_db_xinjue_level[level].breakConsume
		return i3k_db_check_use_items(consume)
	end
end
--判断能否修心
function i3k_db_check_xinjue_consume_fix()
	local level = g_i3k_game_context:getXinjueGrade()
	local consume = i3k_db_xinjue_level[level].fixConsume
	return i3k_db_check_use_items(consume)
end

-- 返回一个map，在context中存一份，在计算技能等级差的时候就直接索引就好了
function i3k_db_get_xinjue_monster_level_map()
	local cfg = i3k_db_xinjue.levels
	local min = 9999
	local max = 0
	for k, v in pairs(cfg) do
		if k < min then	min = k	end
		if k > max then	max = k	end
	end

	local res = {min = min, max = max, mapping = {}}
	local temp
	for i = max, min,-1 do
		if cfg[i] then
			res.mapping[i] = cfg[i]
			temp = cfg[i]
		else
			res.mapping[i] = temp
		end
	end
	return res
end

function i3k_db_get_monster_xinjue_grade(monsterID)
	local info = g_i3k_game_context:getXinjueLevelMapping()
	local monsterLevel = i3k_db_monsters[monsterID].level
	if monsterLevel < info.min then
		return 0
	end
	if monsterLevel > info.max then
		return info.mapping[info.max]
	end
	return info.mapping[monsterLevel]
end

function i3k_db_get_xinjue_level_min(monsterID)
	local xinjueLevel = g_i3k_game_context:getXinjueGrade() or 0
	local monsterLevel = g_i3k_db.i3k_db_get_monster_xinjue_grade(monsterID)
	local d_value = i3k_db_xinjue.d_value
	if monsterLevel > xinjueLevel then
		return 0
	end
	local value = xinjueLevel - monsterLevel
	return  value > d_value and d_value or value
end

function i3k_db_get_xinjue_monster_damage_percent(monsterID)
	local isBoss = g_i3k_db.i3k_db_get_monster_is_boss(monsterID)
	local level = g_i3k_db.i3k_db_get_xinjue_level_min(monsterID)
	if level == 0 then
		return 0
	end
	local cfg = i3k_db_xinjue_damage
	if isBoss then
		return cfg[level].toBoss / 10000
	else
		return cfg[level].toMonster / 10000
	end
end

-------------------------------------------------

--是否展示任务箭头的基础条件（等级和是否是新手引导状态）
function i3k_db_is_can_show_task_guide()
	if g_i3k_game_context:GetLevel() > i3k_db_common.taskGuide.needLevel then
		return false
	end
	if g_i3k_game_context:IsInLeadMode() then
		return false
	end
	return true
end

--Vip礼包
function i3k_db_check_vipGiftBgDiscount_date()
	local nowData = i3k_game_get_time()
	local nowTime = nowData % 86400
	local level = g_i3k_game_context:GetVipLevel()
	local endTime = i3k_db_kungfu_vip[level].discountCloseDate
    nowData = nowData - nowTime
    local gmtTime = g_i3k_get_GMTtime(nowData)

	if endTime > gmtTime then
		return true
	elseif endTime < gmtTime then
		return false
	else
		return nowTime < 86340
	end
end

-----------------------------------------
function i3k_db_check_world_map_open(mapID)
	local db = i3k_db_world_map.unOpenMaps
	for k, v in ipairs(db) do
		if mapID == v then
			return false
		end
	end
	return true
end


function i3k_db_get_search_items_count(newTab)
	local COUNT = 0
	local itemCount = table.nums(newTab)
	local currentItemIndex = 1
	while currentItemIndex <= itemCount  do
		local e = newTab[currentItemIndex]
		currentItemIndex = currentItemIndex + 1
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local item_cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
		COUNT=COUNT+item_cell_count
	end
	return COUNT
end

--暗器系统
--根据暗器ID获取暗器当前的被动技能
function i3k_db_get_anqi_now_skill(wid)
	local allSkill = {}
	local skillData = i3k_db_anqi_skill[wid]
	local skillLib = g_i3k_game_context:GetSkillLib(wid)

	for skillID, skillLvl in pairs(skillLib) do
		local t =
		{
			skillID = skillID,
			skillLvl = skillLvl,
			skillData = skillData[skillID][skillLvl]
		}
		table.insert(allSkill, t)
	end
	return allSkill
end

--从表里查找一个暗器的被动技能
function i3k_db_get_one_anqi_skill(wid, skillID, skillLvl)
	local skillTop = i3k_db_anqi_skill[wid]
	local skillMid = skillTop[skillID]
	return skillMid[skillLvl]
end

--获取一个暗器的所有被动技能（没有的默认等级为1）
function i3k_db_get_one_anqi_all_skill_by_skillLib(wid, skillLib)
	local skillCfg = i3k_db_anqi_skill[wid]
	local defaultLvl = 1
	for skillID, v in pairs(skillCfg) do
		if not skillLib[skillID] then
			skillLib[skillID] = defaultLvl
		end
	end
	return skillLib
end

--排序暗器被动技能
function i3k_db_sort_anqi_skill(skill)
	table.sort(skill, function(a, b)
		local sortA = a.skillData.grade * 100 + a.skillID
		local sortB = a.skillData.grade * 100 + b.skillID
		return sortA > sortB
	end)
	return skill
end

--根据暗器ID获取暗器基础配置
function i3k_db_get_one_anqi_skill_base_cfg(wid)
	local baseCfg = i3k_db_anqi_base[wid]
	return baseCfg
end

--根据暗器ID和加值获取暗器升品配置
function i3k_db_get_one_anqi_skill_up_grade_cfg(wid)
	local rankValue = g_i3k_game_context:GetHideWeaponRankValue(wid)
	local gradeCfg = i3k_db_anqi_grade[wid]
	return gradeCfg[rankValue]
end

--根据暗器ID和技能槽的位置获取需要的品质
function i3k_db_get_one_anqi_change_skill_need_grade(wid, slotIndex)
	local gradeCfg = i3k_db_anqi_grade[wid]
	for _, v in pairs(gradeCfg) do
		if v.slotCount == slotIndex then
			return v.level
		end
	end
	return 0

end

function i3k_db_get_anqi_grade_name(grade)
	if not i3k_db_anqi_gradeName[grade] then
		return nil
	end
	local name = i3k_db_anqi_gradeName[grade].name
	return name
end

function i3k_db_get_anqi_grade_img(grade)
	if not i3k_db_anqi_gradeName[grade] then
		return nil
	end
	local img = i3k_db_anqi_gradeName[grade].img
	return img
end

-- 根据暗器的加值，获取品质
function i3k_db_get_anqi_grade_by_addValue(anqiID, addValue)
	local gradeCfg = i3k_db_anqi_grade[anqiID][addValue]
	return gradeCfg.level
end

-- 根据暗器的加值，获取已解锁被动技能槽数
function i3k_db_get_anqi_slotCount_by_addValue(anqiID, addValue)
	local gradeCfg = i3k_db_anqi_grade[anqiID][addValue]
	return gradeCfg.slotCount
end

-- 根据暗器的id，返回显示的等级名字
function i3k_db_get_anqi_grade_name_by_id(id)
	local weapon = g_i3k_game_context:getHideWeaponByID(id)
	local gradeName
	if not weapon then
		gradeName = "未解锁"
	else
		local grade = g_i3k_db.i3k_db_get_anqi_grade_by_addValue(id, weapon.rankValue)
		gradeName = g_i3k_db.i3k_db_get_anqi_grade_name(grade)
	end
	return gradeName
end

-- 根据暗器心法 要领ID获取要领数据
function i3k_db_get_anqi_xinfa_yaoling_DB_by_idAndLv(id)
	local learn = g_i3k_game_context:getHideWeaponXinfaInfo()
	if learn then
		local data = learn.learnPoints[id]
		local level =  data and data.level or 1
		local propDB = i3k_db_anqi_xinfa_essential[id].essentialData[level]
		return propDB
	end
end



function i3k_db_get_anqi_img(id)
	local weapon = g_i3k_game_context:getHideWeaponByID(id)
	local img
	if not weapon then
		img = i3k_db_anqi_common.unlockImg
	else
		local grade = g_i3k_db.i3k_db_get_anqi_grade_by_addValue(id, weapon.rankValue)
		img = g_i3k_db.i3k_db_get_anqi_grade_img(grade)
	end
	return img
end


--获取搜索后的物品
function i3k_db_get_items_after_search(bagItems,keyWord)
	local newTab={}
	for k,v in pairs(bagItems) do
		local name = g_i3k_db.i3k_db_get_common_item_name(k)
		local match_ret =string.match(name,keyWord)
		  if match_ret and g_i3k_db.i3k_db_get_bag_item_stack_max(v.id)>0 then
			table.insert(newTab,v)
		  end
    end
	return newTab
end
--根据暗器主动技能获取需要的暗器等级
function i3k_db_get_one_anqi_active_skill_level_limit(level)
	local limitCfg = i3k_db_anqi_common.levelLimit
	local nextLvl = (level + 1) <= #limitCfg and (level + 1) or #limitCfg
	return limitCfg[nextLvl] and limitCfg[nextLvl].value or 0
end

function i3k_db_get_anqi_props_show_list(propsNow, propsNext)
	local props = {}
	for k, v in ipairs(propsNow) do
		local name = i3k_db_prop_id[v.id].desc
		local toValue  = 0
		if not propsNext then
			toValue = nil
		end
		props[v.id] = {id = v.id, name = name, from = v.count, to = toValue, showBtn = false}
	end
	if propsNext then
		for k, v in ipairs(propsNext) do
			if props[v.id] then
				props[v.id].to = v.count
			else
				local name = i3k_db_prop_id[v.id].desc
				props[v.id] = {id = v.id, name = name, from = 0, to = v.count, showBtn = false}
			end
		end
	end
	local res = {}
	for k, v in pairs(props) do
		if v.from ~= 0 and v.to ~= 0 then
			table.insert(res, v)
		end
	end
	table.sort(res, function(a, b)
		return a.id < b.id
	end)
	return res
end
-- 获取升品所需奖励的显示列表
function i3k_db_get_up_grade_list(anqiID, addValue)
	local function get_rate_show(value)
		if not value then
			return nil
		end
		return (value / 10000 * 100) .. "%"
	end

	local cfgNow = i3k_db_anqi_grade[anqiID][addValue]
	local cfgNext = i3k_db_anqi_grade[anqiID][addValue + 1]
	if not cfgNext then
		cfgNext = {} -- 空table
	end

	local totalFightRateNow = cfgNow.fightRate
	local totalAgainstRateNow = cfgNow.againstRate
	local totalFightRateNext = cfgNext.fightRate
	local totalAgainstRateNext = cfgNext.againstRate

	local skinLib = g_i3k_game_context:GetAnqiSkinLib(anqiID)
	for skinID, v in pairs(skinLib) do
		if v then
			local skinCfg = i3k_db_get_anqi_skin_by_skinID(skinID)
			totalFightRateNow = totalFightRateNow + skinCfg.skinFightRate
			totalAgainstRateNow = totalAgainstRateNow + skinCfg.skinAgainstRate
			if totalFightRateNext then
				totalFightRateNext = totalFightRateNext + skinCfg.skinFightRate
			end
			if totalAgainstRateNext then
				totalAgainstRateNext = totalAgainstRateNext + skinCfg.skinAgainstRate
			end
		end
	end

	local nowLevelName = i3k_db_get_anqi_grade_name(cfgNow.level)
	local nextLevelName = i3k_db_get_anqi_grade_name(cfgNext.level)
	local nowLevelImg = i3k_db_get_anqi_grade_img(cfgNow.level)
	local nextLevelImg = i3k_db_get_anqi_grade_img(cfgNext.level)
	local grade = { name = i3k_get_string(17307), from = nowLevelName, to = nextLevelName, showBtn = false, nowLevelImg = nowLevelImg, nextLevelImg = nextLevelImg} -- 暗器品质
	local slot = { name = i3k_get_string(17308), from = cfgNow.slotCount, to = cfgNext.slotCount, showBtn = false} -- 被动插槽数量
	local fightRate = {name = i3k_get_string(17309), from = get_rate_show(totalFightRateNow), to = get_rate_show(totalFightRateNext), showBtn = false} -- 命中加成
	local againstRate = {name = i3k_get_string(17310), from = get_rate_show(totalAgainstRateNow), to = get_rate_show(totalAgainstRateNext), showBtn = true } -- 识破加成
	local skillLevel = {name = i3k_get_string(17311), from = cfgNow.skillAddLevel, to = cfgNext.skillAddLevel, showBtn = false} -- 技能等级加成
	-- local power = {name = "战力加成", from = cfgNow.power, to = cfgNext.power } -- 战力加成
	local props = g_i3k_db.i3k_db_get_anqi_props_show_list(cfgNow.props, cfgNext.props)
	local res =
	{
		[1] = grade,
		[2] = slot,
		[3] = fightRate,
		[4] = againstRate,
		[5] = skillLevel,
	}
	for k, v in ipairs(props) do
		table.insert(res, v)
	end
	return res
end

function i3k_db_get_anqi_up_star_info(anqiID, level)
	local cfgNow = i3k_db_anqi_level[anqiID][level]
	local cfgNext = i3k_db_anqi_level[anqiID][level + 1]
	if not cfgNext then
		return nil -- 满级
	end
	local needLevel = cfgNext.roleLevel
	local needExp = cfgNext.exp
	local props = g_i3k_db.i3k_db_get_anqi_props_show_list(cfgNow.props, cfgNext.props)
	local res =
	{
		needLevel = needLevel,
		needExp = needExp,
		props = props,
	}
	return res
end

-- 优先消耗count1，其次消耗count2，共total个
function i3k_db_get_anqi_consume_count(count1, count2, total)
	local temp
	if count1 < total then
		temp = count1 -- 第一个不足
	else
		temp = total
	end

	return temp, total - temp
end

function i3k_db_get_anqi_consume_count_with_unlock(item1, item2, count)
	item1 = math.abs(item1)
	item2 = math.abs(item2)
	local haveCount1 = g_i3k_game_context:GetCommonItemCanUseCount(item1)
	local haveCount2 = g_i3k_game_context:GetCommonItemCanUseCount(item2)
	local count1 , count2 = i3k_db_get_anqi_consume_count(haveCount1, haveCount2, count)
	local addCount1 = g_i3k_game_context:GetCommonItemCount(item1) -- 绑定
	local addCount2 = g_i3k_game_context:GetCommonItemCount(item2)

	local items = {}
	if count1 > addCount1 then
		items[item1] = addCount1
		items[-item1] = count1 - addCount1
	else
		items[item1] = count1
	end

	if count2 > addCount2 then
		items[item2] = addCount2
		items[-item2] = count2 - addCount2
	else
		items[item2] = count2
	end

	for k, v in pairs(items) do
		i3k_log("==="..k.." "..v)
		if v == 0 then
			items[k] = nil
		end
	end
	return items
end

-- 根据总的经验值，来获取目前对应的等级和该等级的经验
function i3k_db_get_anqi_level_and_exp(anqiID, exp)
	local cfg = i3k_db_anqi_level[anqiID]
	local temp = 0
	local level
	for k, v in ipairs(cfg) do
		temp = temp + v.exp
		level = k
		if temp > exp then
			break
		end
	end

	local curExp = exp - (temp - cfg[level].exp)
	return curExp, level - 1
end


-- 根据经验计算下对应暗器的等级
function i3k_db_get_anqi_level_by_exp(anqiID, addExp)
	local addAllExp = i3k_db_get_anqi_cur_exp(anqiID) --当前所有的经验
	local nextAllExp = addAllExp + addExp -- 加上之后的总经验
	return i3k_db_get_anqi_level_and_exp(anqiID, nextAllExp)
end

-- 获取暗器初始化的时候，暗器被动技能库对应的初始等级列表
function i3k_db_get_anqi_init_skillLib(anqiID)
	local cfg = i3k_db_anqi_skill[anqiID]
	local res = {}
	for k, v in pairs(cfg) do
		res[k] = 1
	end
	return res
end

-- 获取当前等级和当前等级的经验值，共的总经验
function i3k_db_get_anqi_cur_exp(anqiID)
	local curExp = g_i3k_game_context:getHideWeaponExp(anqiID)
	local level = g_i3k_game_context:getHideWeaponLevel(anqiID)
	i3k_log("cur anqi level = "..level.." curExp = "..curExp)
	local cfg = i3k_db_anqi_level[anqiID]
	local expBefore = 0
	for k, v in ipairs(cfg) do
		if k <= level then
			expBefore = expBefore + v.exp
		end
	end
	return expBefore + curExp
end

-- 使用最大数量的消耗道具，最大可以到多少级
function i3k_db_get_can_up_level_to_level(anqiID)
	local cfg = i3k_db_anqi_level[anqiID]
	local roleLevel = g_i3k_game_context:GetLevel()
	local itemList = i3k_db_anqi_common.items
	local itemCanUseCount = {}
	local totalExp = 0 -- 升级道具可以提供的总的经验
	for k, v in ipairs(itemList) do
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v)
		local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(v)
		itemCanUseCount[v] = {haveCount = haveCount , exp = itemCfg.args1 }
		totalExp = totalExp + haveCount * itemCfg.args1
	end
	local curExp = i3k_db_get_anqi_cur_exp(anqiID)
	local level = 1 -- 初始等级
	local totalExpCount = 0 -- 所有等级的总经验
	for k, v in ipairs(cfg) do
		totalExpCount = totalExpCount + v.exp
		if roleLevel >= v.roleLevel and totalExpCount - curExp <= totalExp then
			level = k
		end
	end
	return level
end

-- 获取一键升级，可以使用道具的数量
function i3k_db_get_up_level_canUse_count(anqiID)
	local level = i3k_db_get_can_up_level_to_level(anqiID)
	i3k_log(" level = " .. level)
	local cfg = i3k_db_anqi_level[anqiID][level]
	local curExp = i3k_db_get_anqi_cur_exp(anqiID)
	local totalLevelExp = 0
	for k, v in ipairs(i3k_db_anqi_level[anqiID])do
		if k <= level + 1 then
			totalLevelExp = totalLevelExp + v.exp
		end
	end
	local leftExp = totalLevelExp - curExp
	i3k_log("totalLevelExp = "..totalLevelExp.." curExp = "..curExp.." leftExp = "..leftExp)
	if leftExp < 0 then
		error("i3k_db_get_up_level_canUse_count, less than 0, "..leftExp)
	end
	local itemList = i3k_db_anqi_common.items
	local itemUseCount = {}
	for i = #itemList, 1, -1 do
		local v = itemList[i]
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v)
		local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(v)
		local perExp = itemCfg.args1
		local maxCount = math.floor(leftExp / perExp)
		if maxCount <= haveCount then
			itemUseCount[v] = maxCount
			leftExp = leftExp - maxCount * perExp
		else
			itemUseCount[v] = haveCount
			leftExp = leftExp - haveCount * perExp
		end
	end

	local curAnqiLevel = g_i3k_game_context:getHideWeaponLevel(anqiID)
	local cfg2 = i3k_db_anqi_level[anqiID][curAnqiLevel + 1]
	if cfg2 then
		local roleLevel = g_i3k_game_context:GetLevel()
		if cfg2.roleLevel > roleLevel then -- 不允许升级至下一级，0经验
			for k, v in ipairs(itemList) do
				local count = itemUseCount[v]
				if count > 0 then
					itemUseCount[v] = count - 1 
					break
				end
			end
		end
	end

	return itemUseCount
end

function i3k_db_get_up_level_canUse_count_with_unlock(anqiID)
	local items = i3k_db_get_up_level_canUse_count(anqiID)
	local res = {}
	for k, v in pairs(items) do
		local addCount = g_i3k_game_context:GetCommonItemCount(k) -- 绑定
		if addCount < v then
			res[k] = addCount
			res[-k] = v - addCount
		else
			res[k] = v
		end

	end

	return res
end
--得到赏金任务的 普通奖励列表 额外奖励列表
function i3k_db_get_globalWorldTask_rewardLists(taskID)
	local normalList = {}
	local superList = {}
	local roleLevel = g_i3k_game_context:GetLevel()
	local rtype = g_i3k_game_context:GetRoleType()
	local taskCfg = i3k_db_war_zone_map_task[taskID]
	local exp = i3k_db_exp[roleLevel].globalWorldTask
	--普通奖励
	table.insert(normalList, {id = g_BASE_ITEM_EXP, count = exp * taskCfg.expNomalValue})
	table.insert(normalList, {id = taskCfg.awardIds1[rtype], count = taskCfg.awardCount1})
	table.insert(normalList, {id = taskCfg.awardIds2[rtype], count = taskCfg.awardCount2})
	--额外奖励
	table.insert(superList, {id = g_BASE_ITEM_EXP, count = exp * taskCfg.expSeniorValue})
	table.insert(superList, {id = taskCfg.awardSeniorIds1[rtype], count = taskCfg.awardSeniorCount1})
	table.insert(superList, {id = taskCfg.awardSeniorIds2[rtype], count = taskCfg.awardSeniorCount2})
	return normalList, superList
end
--得到元灵碎片炼化对应奖励
function i3k_db_get_spiritsFragment_rewardLists(id, count)
	local isOnlyShow = false --仅仅做展示
	local rList = {}
	local roleLevel = g_i3k_game_context:GetLevel()
	local exp = i3k_db_exp[roleLevel].spiritsFragment
	local rewardData = {}
	if count < i3k_db_catch_spirit_base.spiritFragment.lianhuaNeedCount then
		isOnlyShow = true
		--这里随便从表里拿一组数据
		for rid,_ in pairs(i3k_db_catch_spirit_exchange) do
			for rcount,_ in pairs(i3k_db_catch_spirit_exchange[rid]) do
					id = rid
					count = rcount
				break
			end
			break
		end
	end
	rewardData = i3k_db_catch_spirit_exchange[id][count]
	if rewardData then
		table.insert(rList, {id = g_BASE_ITEM_EXP, count = exp * rewardData.experience})
		for i,v in ipairs(rewardData.rewards) do
			table.insert(rList, {id = v.id, count = v.count})
		end
	end
	return rList, isOnlyShow
end
--得到元灵碎片顺序列表
function i3k_db_get_spiritsFragment_all_List()
	local sList = {}
	for k,v in pairs(i3k_db_catch_spirit_fragment) do
		v.id = k
		table.insert(sList, v)
	end
	table.sort(sList, function(a, b)
			return a.id < b.id
		end)
	return sList
end

-- 获取被动技能底图
function i3k_db_get_anqi_slot_cfg(grade)
	local cfg = i3k_db_anqi_common.skillSlot
	return cfg[grade]
end

-- 获取解锁被动技能槽index（123），需要达到多少品
function i3k_db_get_anqi_unlock_slot_need_grade(anqiID, index)
	local cfg = i3k_db_anqi_grade[anqiID]
	for k, v in ipairs(cfg) do
		if v.slotCount == index then
			return v.level
		end
	end
	return 0
end

-- 获取被动技能的图标
function i3k_db_get_anqi_possitive_skill_icon(anqiID, skillID)
	local cfg = i3k_db_anqi_skill[anqiID][skillID]
	assert(cfg ~= nil, anqiID.." "..skillID)
	return cfg[1].icon
end

-- 通过技能id，获取暗器的id
function i3k_db_get_anqi_id_by_skillID(skillID)
	for k, v in ipairs(i3k_db_anqi_base) do
		if v.skillID == skillID then
			return k
		end
	end
end

function i3k_db_get_anqi_count()
	return table.nums(i3k_db_anqi_base)
end
-- 获取暗器皮肤ID（vector）
function i3k_db_get_anqi_skinID_by_anqiID(anqiID)
	local anqiCfg = i3k_db_anqi_base[anqiID]
	if anqiCfg then
		return anqiCfg.skinID
	end
	return {}
end

-- 获取暗器皮肤db
function i3k_db_get_anqi_skin_by_skinID(skinID)
	return i3k_db_anqi_skin[skinID]
end

--根据暗器id获取暗器幻化显示图标或者为幻化图标
function i3k_db_get_anqi_skin_showId_by_skinID(anqiID)
	local curSkinID = g_i3k_game_context:GetAnqiCurSkin(anqiID)
	if curSkinID ~= 0 then
		local skinCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(curSkinID)
		return skinCfg and g_i3k_db.i3k_db_get_icon_path(skinCfg.listIcon)
	end
end
--根据暗器id获取暗器幻化技能图标或者未幻化图标
function i3k_db_get_anqi_skin_skillId_by_skinID(anqiID, skillId)
	local curSkinID = g_i3k_game_context:GetAnqiCurSkin(anqiID)
	if curSkinID ~= 0 then
		local skinCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(curSkinID)
		return skinCfg and g_i3k_db.i3k_db_get_icon_path(skinCfg.skillIcon)
	else
		return g_i3k_db.i3k_db_get_skill_icon_path(skillId)
	end
	return ""
end
-- 巨灵攻城相关
--	@function: 距离上一个排名区间还有多少名
	-- bossID 		巨灵boosID
	-- selfRank		自己排名
function i3k_db_get_spiritBoss_rank_desc(bossID, selfRank)
	local rank = 1
	local idx = 1 -- 第几个奖励挡位
	local cfg = i3k_db_spirit_boss.rankRewards
	local rankingCfg = cfg[bossID]
	for i, e in ipairs(rankingCfg) do
		if selfRank > e then
			rank = e
			idx = i
		end
	end
	return selfRank - rank
end


----------------城战 begin-----------------------
function i3k_db_get_current_time_in_range(startTime, endTime)
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	return startTime <= curTime and curTime <= endTime
end

--根据当前时间获得当前城战是第几期
function i3k_db_get_defence_war_batchID()
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	for batchID, cfg in ipairs(i3k_db_defenceWar_time) do
		if curTime <= cfg.endTime then
			return batchID
		end
	end
	return nil
end

--pve延迟时间
function i3k_db_get_defence_war_pve_delayTime()
	local delayTime = i3k_db_defenceWar_cfg.delayTime

	local citySign = g_i3k_game_context:getCitySign()
	local delayInfo = g_i3k_game_context:getDelayInfo()

	local signCityID = i3k_db_get_defence_war_mySignCityID(citySign)
	local pveDelayIndex = signCityID and delayInfo[signCityID] or nil
	return pveDelayIndex and delayTime[pveDelayIndex] or 0
end

--pvp延迟时间
function i3k_db_get_defence_war_pvp_delayTime()
	local delayTime = i3k_db_defenceWar_cfg.delayTime

	local cityBid = g_i3k_game_context:getCityBid()
	local delayInfo = g_i3k_game_context:getDelayInfo()

	local bidCityID = g_i3k_game_context:getDefenceWarCurrentCityState() --获取自己占据的城池
	if not bidCityID then
		bidCityID = i3k_db_get_defence_war_myBidCityID(cityBid)
	end
	local pvpDelayIndex = bidCityID and delayInfo[bidCityID] or nil
	return pvpDelayIndex and delayTime[pvpDelayIndex] or 0
end

-- 根据当前的时间，获取现在处于什么样的状态
function i3k_db_get_defence_war_state()
	local batchID = i3k_db_get_defence_war_batchID()
	if not batchID then
		return g_DEFENCE_WAR_STATE_NONE
	end
	local fightTime = i3k_db_defenceWar_cfg.fightTotalTime

	--延迟战斗的时间
	local pveDelayTime = i3k_db_get_defence_war_pve_delayTime()
	local pvpDelayTime = i3k_db_get_defence_war_pvp_delayTime()

	local cfg = i3k_db_defenceWar_time[batchID]
	local A1 = cfg.startTime
	local A2 = cfg.signEndTime
	local B1 = cfg.captureStartTime + pveDelayTime
	local B2 = B1 + fightTime
	local C1 = cfg.bidStartTime
	local C2 = cfg.bidEndTime
	local D1 = cfg.grabStartTime + pvpDelayTime
	local D2 = D1 + fightTime
	local E  = cfg.endTime

	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())

	local isSignWait	= i3k_db_get_current_time_in_range(curTime, A1)
	local isSignUp	 	= i3k_db_get_current_time_in_range(A1, A2)
	local isPveWait		= i3k_db_get_current_time_in_range(A2, B1)
	local isPve 		= i3k_db_get_current_time_in_range(B1, B2)
	local isNoFight 	= i3k_db_get_current_time_in_range(B2, C1)
	local isBid 		= i3k_db_get_current_time_in_range(C1, C2)
	local isBidShow	 	= i3k_db_get_current_time_in_range(C2, D1)
	local isPvp 		= i3k_db_get_current_time_in_range(D1, D2)
	local isPeace 		= i3k_db_get_current_time_in_range(D2, E)

	if isSignWait then return g_DEFENCE_WAR_STATE_SIGN_WAIT
	elseif isSignUp then return g_DEFENCE_WAR_STATE_SIGN_UP
	elseif isPveWait then return g_DEFENCE_WAR_STATE_PVE_WAIT
	elseif isPve then return g_DEFENCE_WAR_STATE_PVE
	elseif isNoFight then return g_DEFENCE_WAR_STATE_NO_FIGHT
	elseif isBid then return g_DEFENCE_WAR_STATE_BID
	elseif isBidShow then return g_DEFENCE_WAR_STATE_BID_SHOW
	elseif isPvp then return g_DEFENCE_WAR_STATE_PVP
	elseif isPeace then return g_DEFENCE_WAR_STATE_PEACE end

	return g_DEFENCE_WAR_STATE_NONE -- default
end

-- 获取当前城战的时间描述
function i3k_db_get_defence_war_desc(warState, descFormat)
	local batchID = i3k_db_get_defence_war_batchID()
	local descStr = ""
	if batchID then
		local cfg = i3k_db_defenceWar_time[batchID]
		if warState == g_DEFENCE_WAR_STATE_SIGN_WAIT then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.startTime), g_i3k_get_MonthAndDayTime(cfg.signEndTime))
		elseif warState == g_DEFENCE_WAR_STATE_SIGN_UP then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.signEndTime))
		elseif warState == g_DEFENCE_WAR_STATE_PVE_WAIT then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.captureStartTime))
		elseif warState == g_DEFENCE_WAR_STATE_PVE then
			local fightTime = i3k_db_defenceWar_cfg.fightTotalTime
			local captureEndTime = cfg.captureStartTime + fightTime
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.captureStartTime), g_i3k_get_MonthAndDayTime(captureEndTime))
		elseif warState == g_DEFENCE_WAR_STATE_NO_FIGHT then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.bidStartTime))
		elseif warState == g_DEFENCE_WAR_STATE_BID then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.bidStartTime), g_i3k_get_MonthAndDayTime(cfg.bidEndTime))
		elseif warState == g_DEFENCE_WAR_STATE_BID_SHOW then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.grabStartTime))
		elseif warState == g_DEFENCE_WAR_STATE_PVP then
			local fightTime = i3k_db_defenceWar_cfg.fightTotalTime
			local grabEndTime = cfg.grabStartTime + fightTime
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.grabStartTime), g_i3k_get_MonthAndDayTime(grabEndTime))
		elseif warState == g_DEFENCE_WAR_STATE_PEACE then
			descStr = string.format(descFormat, g_i3k_get_MonthAndDayTime(cfg.endTime))
		end
	end
	return descStr
end

function i3k_db_get_defence_war_city_sizeStr_by_grade(grade)
	if grade == 1 then
		return "大型"
	elseif grade == 2 then
		return "中型"
	elseif grade == 3 then
		return "小型"
	else
		return ""
	end
end

-- 坐标转换，参考势力战
function i3k_db_parase_position_list(list)
	local res = {}
	for k, v in ipairs(list) do
		local statuesID = v.info.id;
		local cfgID = v.info.cfgID;
		local x = v.info.position.x;
		local y = v.info.position.y;
		local z = v.info.position.z;
		local position = {x = x / 100, y = y / 100, z = z / 100}
		local world = i3k_game_get_world()
		local mapId = world._cfg.id
		res[k] = {mapId = mapId, pos = i3k_vec3_to_engine(position), forceType = v.forceType}
	end
	return res
end

-- npc对话框，根据配置的参数，来获取需要显示的传送的npc列表
function i3k_db_get_defence_war_npcs(npcID)
	if not i3k_db_npc[npcID] then
		error(npcID)
	end
	local npcsCfg = i3k_db_npc[npcID].exchangeId
	local res = {}
	for k, v in ipairs(npcsCfg) do
		local npcIDImpl = i3k_db_defenceWar_trans[v]
		table.insert(res, {transID = v, cfg = npcIDImpl})
	end
	return res
end

-- 根据同步的数据，获取我当前报名的城市id，没有返回nil
function i3k_db_get_defence_war_mySignCityID(citys)
	for k, v in pairs(citys) do
		if v == g_DEFENCE_WAR_SIGN_MINE then
			return k
		end
	end
	return nil
end

-- 获取我当前竞标的城市id，没有返回nil
function i3k_db_get_defence_war_myBidCityID(citys)
	for k, v in pairs(citys) do
		if v == g_DEFENCE_WAR_BID_MINE then
			return k
		end
	end
	return nil
end

function i3k_db_get_defence_war_delayTime(id)
	if id == 0 then
		return 0
	else
		return i3k_db_defenceWar_cfg.delayTime[id]
	end
end

function i3k_db_get_defence_war_bid_word(errorCode)
	local t =
	{
		[g_DEFENCE_WAR_BID_EMPTY] = "无主城池",
		[g_DEFENCE_WAR_BID_NONE] = i3k_get_string(5180),
		[g_DEFENCE_WAR_BID_OTHER] = i3k_get_string(5179),
		[g_DEFENCE_WAR_BID_MINE] = "本帮派已竞标",
	}
	return t[errorCode]
end

-- sectInfo 为已经占领了城的帮派信息
function i3k_db_get_defence_war_bid_word2(errorCode, otherBidState, myPrice)
	if g_i3k_game_context:getDefenceWarCurrentCityState() then
		return i3k_get_string(5289) --我帮派此轮需要守城
	end

	if errorCode == g_DEFENCE_WAR_BID_MINE then
		local chiefId = g_i3k_game_context:GetFactionChiefID()
		return chiefId and chiefId == g_i3k_game_context:GetRoleId() and i3k_get_string(5224, myPrice) or i3k_get_string(5292)  -- 对本诚出价
	else
		if otherBidState == 0 then
			return i3k_get_string(5223) -- 未竞标任何城
		else
			return i3k_get_string(5225, myPrice) -- 对其它城出价
		end
	end
end

-- true:第二阶段，false:第一阶段
function i3k_db_get_defenceWar_is_pvp(arg)
	return arg == 1
end

----------------城战 end ----------------------

--判断装备能否突破
function i3k_db_can_equip_break(group, tp_level)
	local consume = i3k_db_streng_equip_break[group][tp_level].consume
	return i3k_db_check_use_items(consume)
end

function i3k_db_getOutCastTaskCfgByTaskID(id, taskID)
	for index, cfg in pairs(i3k_db_out_cast_task) do
		if cfg.outCastID == id and cfg.taskID == taskID then
			return cfg
		end
	end
	return {}
end

--获取外传任务接取对白
function i3k_db_get_out_cast_task_get_desc(taskID)
	local task_cfg = i3k_db_out_cast_task[taskID]
	local t = {}
	local moduleIds = {}
	for i=1,4 do
		local tmp_dialog = string.format("talkID%s",i)
		local keyName = "talkModel" .. i
		local dialog = task_cfg[tmp_dialog]
		if dialog ~= 0 then
			local str = i3k_db_dialogue[dialog]
			for k,v in ipairs(str) do
				table.insert(t,v)
				table.insert(moduleIds,task_cfg[keyName])
			end
		end
	end
	return t,moduleIds
end

--获取外传任务的完成对白
function i3k_db_get_out_cast_task_finish_desc(taskID)
	local task_cfg = i3k_db_out_cast_task[taskID]
	local t = {}
	local moduleIds = {}
	for i=1,4 do
		local tmp_dialog = string.format("completeTalk%s",i)
		local keyName = "completeModel" .. i
		local dialog = task_cfg[tmp_dialog]
		if dialog ~= 0 then
			local str = i3k_db_dialogue[dialog]
			for k,v in ipairs(str) do
				table.insert(t,v)
				table.insert(moduleIds,task_cfg[keyName])
			end
		end
	end
	return t,moduleIds
end

--获取装备部位获取描述
function i3k_db_get_equip_gain_resource_desc(partid)
	local data = i3k_db_equip_part[partid]
	local str = ""

	if data then
		str = string.format("部位：%s\n%s", data.partName, data.obtainResources)
	end

	return str
end

--判断这个神兵有没有召唤分身的特技
function i3k_db_get_weapon_has_clone(id)
	if not id then return false end
	local cfg = i3k_db_shen_bing_unique_skill[id]
	for k, v in pairs(cfg) do
		if v.uniqueSkillType == e_WEAPON_TYPE_CALL_CLONE then
			return true
		end
	end
	return false
end


--获取装备锤炼是否开启
function i3k_db_get_equip_temper_open()
	return g_i3k_game_context:GetLevel() >= i3k_db_equip_temper_base.openLevel
end

--判断装备锤炼是否应该显示
function i3k_db_get_equip_temper_show()
	return g_i3k_game_context:GetLevel() >= i3k_db_equip_temper_base.showLevel
end

--判断这个装备能否锤炼 （没有考虑到部位能否锤炼）
function i3k_db_get_equip_can_temper_by_id(equip_id)
	if not equip_id then return; end
	local cfg = i3k_db_get_equip_item_cfg(equip_id)
	return cfg and cfg.temperSkillsLevel
end

--判断这个位置的装备能否锤炼
function i3k_db_get_equip_can_temper_by_pos(partID)
	local wEquip = g_i3k_game_context:GetWearEquips()[partID]
	if wEquip then
		return i3k_db_get_equip_can_temper(wEquip.equip.equip_id)
	end
	return false
end

--判断这个装备是否可以锤炼(最终的)
function i3k_db_get_equip_can_temper(equipID)
	local cfg = i3k_db_get_equip_item_cfg(equipID)
	return i3k_db_equip_temper_base.partDetail[cfg.partID].isOpen == 1 and cfg.temperSkillsLevel
end

--判断这个位置能否锤炼
function i3k_db_get_part_can_temper(partID)
	return i3k_db_equip_temper_base.partDetail[partID].isOpen == 1
end

--获取装备锤炼属性是几星的
function i3k_db_get_equip_temper_prop_star(propID, propValue)
	local propStarThreshold = i3k_db_equip_temper_base.propStarThreshold[propID]
	for i, v in ipairs(propStarThreshold) do
		if propValue >= v.min and propValue <= v.max then
			return i, v
		end
	end
	local length = #propStarThreshold
	return length, propStarThreshold[length]
end

--获取该装备等级解锁锤炼所需材料
function i3k_db_get_equip_temper_unlock_consume_by_id(equip_id)
	local cfg = i3k_db_get_equip_item_cfg(equip_id)
	local equip_level = cfg.levelReq
	for i, v in ipairs(i3k_db_equip_temper_base.unlockConsume) do
		if equip_level <= v.level then
			return v.consume
		end
	end
end

--根据装备锤炼的技能集合 获取宝石属性提升的系数
function i3k_db_get_equip_bless_increase_ratio_by_skill_set(hammerSkill)
	if hammerSkill then
		for i, v in pairs(hammerSkill) do
			local skillCfg = i3k_db_equip_temper_skill[i][v]
		 	if skillCfg.skillType == g_EQUIP_SKILL_TYPE_GEM_STRENGTHEN then
		 		return skillCfg.args[1]/10000
		 	end
		end
	end
	return 0
end

--家园放生获取物品放生所得
function i3k_db_get_homeland_release_count(id)
	local db = i3k_db_get_common_item_cfg(id)
	return db and db.args1 or 0
end

--通过帮派技能等级获取城战表里工程车/箭塔对应的基础血量和显示ID
function i3k_db_get_defence_war_ShowID(skillid, level)
	local cfg = i3k_db_faction_skill[skillid][level]

	if cfg then
		local id = cfg.defenceWarFactionSkillID
		return i3k_db_defenceWar_architectureskills[id]
	end

	return nil
end

--通过坐标点计算出房屋地板的位置
function i3k_db_get_house_floor_pos(pos)
	local level = g_i3k_game_context:getCurHouseLevel()
	local houseData = i3k_db_home_land_house[level]
	local width = math.floor((houseData.startPos.x - pos.x) / i3k_db_home_land_base.houseFurniture.size.width)
	local length = math.floor((houseData.startPos.z - pos.z) / i3k_db_home_land_base.houseFurniture.size.length)
	return width, length
end

--地面家具转向
function i3k_db_get_turn_furniture_direction(turn, curDirection)
	local direction = 1
	if turn == g_TURN_LEFT then
		direction = (curDirection + 3) % 4
	else
		direction = (curDirection + 1) % 4
	end
	if direction == 0 then
		direction = 4
	end
	return direction
end

--地面家具移动
function i3k_db_get_move_furniture_position(moveDirection, curChooseFurniture)
	if moveDirection == g_MOVE_DIRECTION_LEFT then
		curChooseFurniture.positionX = curChooseFurniture.positionX + 1
	elseif moveDirection == g_MOVE_DIRECTION_RIGHT then
		curChooseFurniture.positionX = curChooseFurniture.positionX - 1
	elseif moveDirection == g_MOVE_DIRECTION_UP then
		curChooseFurniture.positionY = curChooseFurniture.positionY - 1
	else
		curChooseFurniture.positionY = curChooseFurniture.positionY + 1
	end
	return i3k_db_get_adjust_furniture_position(curChooseFurniture)
end

--地面家具调整坐标
function i3k_db_get_adjust_furniture_position(curChooseFurniture)
	local positionX, positionY = curChooseFurniture.positionX, curChooseFurniture.positionY
	local level = g_i3k_game_context:getCurHouseLevel()
	local houseData = i3k_db_home_land_house[level]
	local furniture = i3k_db_get_furniture_data(curChooseFurniture.furnitureType, curChooseFurniture.furnitureId)
	local length = furniture.occupyLength
	local width = furniture.occupyWidth
	if curChooseFurniture.direction == 2 or curChooseFurniture.direction == 4 then
		length = furniture.occupyWidth
		width = furniture.occupyLength
	end
	if positionX < 0 then
		positionX = 0
	end
	if positionX + width > houseData.houseWidth then
		positionX = houseData.houseWidth - width
	end
	if positionY < 0 then
		positionY = 0
	end
	if positionY + length > houseData.houseLength then
		positionY = houseData.houseLength - length
	end
	return positionX, positionY
end

--获取墙面家具移动坐标
function i3k_db_get_wall_furniture_move_position(direction, curChooseFurniture)
	local position = 0
	local level = g_i3k_game_context:getCurHouseLevel()
	local wallCfg = i3k_db_home_land_house[level].wallCfg[curChooseFurniture.wallIndex]
	local pendant = i3k_db_home_land_wall_furniture[curChooseFurniture.id]
	if wallCfg.wallType == 1 then
		if direction == g_MOVE_DIRECTION_LEFT then
			position = curChooseFurniture.position + i3k_db_home_land_base.houseFurniture.size.length
		elseif direction == g_MOVE_DIRECTION_RIGHT then
			position = curChooseFurniture.position - i3k_db_home_land_base.houseFurniture.size.length
		end
	else
		if direction == g_MOVE_DIRECTION_LEFT then
			position = curChooseFurniture.position - i3k_db_home_land_base.houseFurniture.size.width
		elseif direction == g_MOVE_DIRECTION_RIGHT then
			position = curChooseFurniture.position + i3k_db_home_land_base.houseFurniture.size.width
		end
	end
	if position < 0 then
		position = 0
	end
	if position > wallCfg.toPos - wallCfg.fromPos - pendant.length then
		position = wallCfg.toPos - wallCfg.fromPos - pendant.length
	end
	return position
end

--房屋区域
function i3k_db_get_house_wall_arena(curPos)
	for _, e in ipairs(i3k_db_home_land_wall_area) do
		local posVec = i3k_vec3(e.position.x, e.position.y, e.position.z)
		local distance = i3k_vec3_dist(posVec, curPos)
		if distance <= e.radius then
		    return g_HOUSE_WALL_AREA, e.wallType
		end
	end
	return g_HOUSE_OTHER_AREA
end

---符语铸锭----
--判断该符文是否支持快速添加
function i3k_db_check_rune_canFastAdd(id)
	local list = i3k_db_under_wear_alone.zhuDingCanotFastAddRune
	for k,v in pairs(list) do
		if id == v then
			return false
		end
	end
	return true
end
function i3k_db_get_rune_zhuDing_attr(id, lvl)
	if lvl ~= 0 then
		local cfg = i3k_db_rune_zhuDing[id][lvl]
		return cfg and cfg.attribute
	end
	return {}
end
--------------神兵觉醒-------------
--判断神兵觉醒能否显示
function i3k_db_get_weapon_awake_is_show(weaponID)
	local roleLvl = g_i3k_game_context:GetLevel()
	if roleLvl < i3k_db_shen_bing_others.awakeShowLvl then return false end
	local cfg = i3k_db_shen_bing_awake[weaponID]
	if cfg and cfg.openAwake == 1 then
		return true
	else
		return false
	end
end

--判断神兵觉醒是否开启
function i3k_db_get_weapon_awake_is_open(weaponID, roleLvl)
	if roleLvl < i3k_db_shen_bing_others.awakeOpenLvl then return false end
	local cfg = i3k_db_shen_bing_awake[weaponID]
	if cfg and cfg.openAwake == 1 then
		return true
	else
		return false
	end
end
--判断当前神兵使用的技能
function i3k_db_get_cur_weapon_awake_skill_name(id)
	local cfg = i3k_db_shen_bing_awake[id]
	if cfg then
	for i, v in ipairs(cfg.showSkills) do
		local skillCfg = i3k_db_shen_bing_bing_hun_skill[v][1]  --1等级
		if skillCfg.skillType == 2 then     --兵魂技能类型2加经验
			return skillCfg.name
			end
		end
	end
	return ""
end
--定期活动------------------
--根据当前时间获得当前定期任务id
function i3k_db_get_timing_activity_id()
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	for ID, cfg in ipairs(i3k_db_timing_activity.openday) do
		if curTime <= cfg.receivetime then
			return ID
		end
	end
	return nil
end

--定期活动
function i3k_db_get_reward_items_id()
	local id= i3k_db_get_timing_activity_id()
	if id then
		return i3k_db_timing_activity.openday[id].rewardItemsId
	end
end
--定期活动时间返回
function i3k_db_get_timing_activity_state()
	local id= i3k_db_get_timing_activity_id()
	if not id then return g_TIMINGACTIVITY_STATE_NONE end
	local cfg = i3k_db_timing_activity.openday[id]
	local A1 = cfg.previewtime
	local A2 = cfg.opentime
	local B1 = cfg.endtime
	local B2 = cfg.receivetime
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	local isnone	= i3k_db_get_current_time_in_range(curTime, A1)
	local ispreview	 	= i3k_db_get_current_time_in_range(A1, A2)
	local isOpen		= i3k_db_get_current_time_in_range(A2, B1)
	local isreceive 	= i3k_db_get_current_time_in_range(B1, B2)
	if isnone then return g_TIMINGACTIVITY_STATE_NONE
	elseif ispreview then return g_TIMINGACTIVITY_STATE_PREVIEW
	elseif isOpen then return g_TIMINGACTIVITY_STATE_OPEN
	elseif isreceive then return g_TIMINGACTIVITY_STATE_RECEIVE
	end
	return g_TIMINGACTIVITY_STATE_NONE
end

--定期活动计算当前阶段value
function i3k_db_get_timing_activity_reward_value( num, index, timingActivityInfo)
	if  not timingActivityInfo or timingActivityInfo.id ==0 then return 0 end
	local cfgActRewards = i3k_db_timing_activity.actRewards[timingActivityInfo.id]
	local upCfgValues = cfgActRewards[index - 1] and cfgActRewards[index - 1].actValue or 0
	local curValues = timingActivityInfo.totalScore  - upCfgValues
	local curCfgValues = cfgActRewards[index].actValue - upCfgValues
    local value = 1 / num * curValues / curCfgValues
	return value
end

--定期活动任务排序
function i3k_db_timing_activity_tasks_sort(showdailyTasks)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local visuallist = i3k_db_timing_activity.tasks[timingActivityInfo.id]
	local heroLvl = g_i3k_game_context:GetLevel()
	local res = {}
	for k, v in ipairs(visuallist) do
		if heroLvl >= v.openlevel then
			local t = showdailyTasks[v.id]
			if t and t.rewards and t.rewards == 1 then -- 已经达成
				table.insert(res, {id = k, cfg = v, done = true, times = t.times, rewards = t.rewards})
			else
				table.insert(res, {id = k, cfg = v, done = false, times = t.times, rewards = t.rewards})
			end
		end
	end
	table.sort(res, function(a, b)
		if a.done == b.done then
			return a.id < b.id
		else
			return a.done == false
		end
	end)
	return res
end

--定期根据宝箱数算出宝箱显示层级和开始结束值
function i3k_db_get_rewards_show_cfg(rewardsState)
	local SCHEDULE_ONE = 1
	local SCHEDULE_TWO = 2
	local REWARDS_COUNT_ONE = 5
    local REWARDS_COUNT_TWO = 10
	local scheduleType = SCHEDULE_TWO
	local startNum, endNum
	if #rewardsState == REWARDS_COUNT_ONE then
		scheduleType = SCHEDULE_ONE
		startNum = 1
		endNum = #rewardsState
	else
		for i=1,(#rewardsState / 2) do
			if rewardsState[i] ~= REWARD_STATE_FINISH then
				scheduleType = SCHEDULE_ONE
				break
			end
		end
		if scheduleType == SCHEDULE_ONE then
			startNum = 1
			endNum = #rewardsState / 2
		else
			startNum = #rewardsState / 2 + 1
			endNum = #rewardsState
		end
	end
	return startNum, endNum, scheduleType
end

--是否在春节活动时间
function i3k_db_is_spring_festival_npc_time()
	local cfg = i3k_db_newYear_red.gift
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	for _, v in ipairs(cfg) do
		if curTime >= v.date + v.startTime and curTime <= v.date + v.endTime then
			return true
		end

	end
	return false
end

--根据rewardID随机一个骰子组合
function i3k_db_get_passExamGift_diceList(rewardID)
	local cfg = i3k_db_pass_exam_gift_reward[rewardID]
	if cfg then
		local diceRewardArray = cfg.diceRewardArray
		local sid = i3k_engine_get_rnd_u(1, #diceRewardArray)
		return diceRewardArray[sid]
	end
	return nil
end

function i3k_db.i3k_db_get_weapon_deform(gender, weaponID, form)
	local wcfg = i3k_db_shen_bing[weaponID];
	local aWakeCfg = i3k_db_shen_bing_awake[weaponID]
	local form = form or g_WEAPON_FORM_NORMAL
	local gender = gender or eGENDER_MALE
	if gender == eGENDER_MALE then
		if form == g_WEAPON_FORM_NORMAL then
			return wcfg.changeType, wcfg.changeArgs
		elseif form == g_WEAPON_FORM_ADVANCED then
			return wcfg.changeType, wcfg.manModuleID
		elseif form == g_WEAPON_FORM_AWAKE then
			return aWakeCfg.changeType, aWakeCfg.awakeModleMale
		end
	else
		if form == g_WEAPON_FORM_NORMAL then
			return wcfg.changeType, wcfg.changeArgsF
		elseif form == g_WEAPON_FORM_ADVANCED then
			return wcfg.changeType, wcfg.womanModuleID
		elseif form == g_WEAPON_FORM_AWAKE then
			return aWakeCfg.changeType, aWakeCfg.awakeModleFemale
		end
	end
end

--驻地精灵是否符合开启时间
function i3k_db_get_faction_spirit_is_open()
	local week = g_i3k_get_week(g_i3k_get_day(i3k_game_get_time()))
	local openDay = i3k_db_faction_spirit.spiritCfg.openDay
	local openTime = i3k_db_faction_spirit.spiritCfg.openTime
	local lifeTime = i3k_db_faction_spirit.spiritCfg.lifeTime
	for _, v in ipairs(openDay) do
		if v == week then
			return g_i3k_checkIsInTodayTime(openTime, openTime + lifeTime)
		end
	end
	return false
end

--击杀精灵所在祝福加成
function i3k_db_get_faction_spirit_get_addexp(count)
	local cfgRewards = i3k_db_faction_spirit.blessingRewards
	local maxID = 0
	for k,v in ipairs(cfgRewards) do
		if count < v.spiritCount then
			return  maxID, cfgRewards[maxID]
		end
		maxID = k
	end
	return maxID, cfgRewards[maxID]
end

--获取精灵最小获取奖励数量
function i3k_db_get_faction_spirit_get_min_count()
	local cfg = i3k_db_faction_spirit.blessingRewards[1]
	return cfg.spiritCount
end

--判断是否需要屏蔽怪物伤害冒字和tab
function i3k_db_shield_hurt_title(id)
	local monsterId = i3k_db_faction_spirit.spiritCfg.monsterId
	return  id  ~= monsterId
end


--获取所有种类的家具
function i3k_db_get_all_furniture()
	return i3k_db_all_furniture_info
end

function i3k_db_get_furniture_data(furnitureType, id)
	return i3k_db_all_furniture_info[furnitureType][id]
end

--宠物装备
--根据分组获得宠物数据
function i3k_db_get_pet_cfg_data_by_group(group)
	local petCfgData = {}
	for _, v in ipairs(i3k_db_mercenaries) do
		if v.isOpen ~= 0 and group == v.petGroup then
			table.insert(petCfgData, v)
		end
	end
	return petCfgData
end

--获取当前野外出战宠物的分组
function i3k_db_get_cur_field_pet_group()
	local fieldPetID = g_i3k_game_context:getFieldPetID()
	for _, v in ipairs(i3k_db_mercenaries) do
		if v.isOpen ~= 0 and fieldPetID == v.id then
			return v.petGroup
		end
	end
	local allPet = g_i3k_game_context:GetAllYongBing()
	for k, v in pairs(allPet) do
		if i3k_db_mercenaries[k].isOpen ~= 0 then
			return i3k_db_mercenaries[k].petGroup
		end
	end
	return 1
end

--某个分组是否拥有至少一个宠物
function i3k_db_get_is_have_one_pet_in_group(group)
	local petCfgData = g_i3k_db.i3k_db_get_pet_cfg_data_by_group(group)
	for _, v in ipairs(petCfgData) do
		if g_i3k_game_context:IsHavePet(v.id) then
			return true
		end
	end
	return false
end

--某个分组所有宠物的最大等级
function i3k_db_get_pet_max_level_in_group(group)
	local maxLvl = 0
	local petCfgData = g_i3k_db.i3k_db_get_pet_cfg_data_by_group(group)
	for _, v in ipairs(petCfgData) do
		local petLvl = g_i3k_game_context:getPetLevel(v.id)
		if petLvl > maxLvl then
			maxLvl = petLvl
		end
	end
	return maxLvl
end

--某个等级宠物装备升级数据
function i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, level)
	for _, v in ipairs(i3k_db_pet_equips_up_lvl) do
		if v.group == upGroupID and v.level == level then
			return v
		end
	end
	return nil
end

--某个等级宠物装备升级最大等级
function i3k_db_get_pet_equip_up_max_lvl(upGroupID)
	local maxLvl = 0
	for _, v in ipairs(i3k_db_pet_equips_up_lvl) do
		if v.group == upGroupID and v.level > 0 then
			maxLvl = maxLvl + 1
		end
	end
	return maxLvl
end

--某个宠物装备是否有升级限制
function i3k_db_get_pet_equip_is_have_limit_and_skillCnt(group, partID, nextLevel)
	local upGroupID = i3k_db_pet_equips_part[partID].group
	local nextUpLvlCfg = g_i3k_db.i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, nextLevel)

	local needSkillCnt = nextUpLvlCfg.skillCnt
	local needSkillLvl = nextUpLvlCfg.skillLvl

	local skillCnt = 0
	local petCfgData = g_i3k_db.i3k_db_get_pet_cfg_data_by_group(group)
	for _, v in ipairs(petCfgData) do
		local trainSkills = g_i3k_game_context:GetPetTrainSkillsData(v.id)
		for skillID, skillLvl in pairs(trainSkills) do
			if skillLvl >= needSkillLvl then
				skillCnt = skillCnt + 1
			end
		end
	end
	return skillCnt < needSkillCnt, skillCnt
end

--某个宠物装备是否有试炼技能
function i3k_db_get_pet_equip_is_have_skill(equipCfg)
	local skillCnt = 0
	for _, v in ipairs(equipCfg.skills) do
		if v.skillID ~= 0 and v.skillLvl ~= 0 then
			skillCnt = skillCnt + 1
		end
	end
	return skillCnt > 0
end

--获取宠物试炼技能配置
function i3k_db_get_pet_equip_skill_up_cfg(skillID, skillLvl)
	for _, v in ipairs(i3k_db_pet_skill_up_lvl) do
		if v.skillID == skillID and v.level == skillLvl then
			return v
		end
	end
	return nil
end

--某个试炼技能升级最大等级
function i3k_db_get_pet_equip_skill_max_lvl(skillID)
	local maxLvl = 0
	for _, v in ipairs(i3k_db_pet_skill_up_lvl) do
		if v.skillID == skillID and v.level > 0 then
			maxLvl = maxLvl + 1
		end
	end
	return maxLvl
end

--宠物试炼
function i3k_db_get_NpcID_By_TaskID(taskID)
	for k, v in ipairs(i3k_db_PetDungeonTasks) do
		if k == taskID then
			return v.npcID
		end
	end
	
	return 0
end

function i3k_db_get_TaskID_By_NpcID(npcID)
	for k, v in ipairs(i3k_db_PetDungeonTasks) do
		if v.npcID == npcID then
			return k
		end
	end
	
	return 0
end

function i3k_db_get_PetDungeonGathers_By_MapID(mapid)
	local gathers = {}
	
	for _, v in ipairs(i3k_db_PetDungeonGathers) do
		if v.mapOwner == mapid then
			table.insert(gathers, v)
		end
	end
	
	return gathers
end

function i3k_db_get_PetDungeonGather_By_MiniID(miniID)
	local gathers = g_i3k_db.i3k_db_get_PetDungeonGathers_By_MapID(g_i3k_game_context:getpetDungeonMapIndex())
	
	for _, v in ipairs(gathers) do
		if v.mineId == miniID then
			return v
		end
	end
	
	return nil
end

--通过宠物ID获取小队名字
function i3k_db_get_PetGroupName_By_PetID(petID)
	local groupID = i3k_db_mercenaries[petID].petGroup
	return i3k_db_pet_equips_group[groupID]
end

--end=======

--获取快速完成任务的cfg
function i3k_db_get_quick_finish_task_cfg(taskType)
	if taskType then
		return i3k_db_common.quicklyFinishTask[taskType]
	else
		return i3k_db_common.quicklyFinishTask
	end
end


--获取每周限时宝箱奖励内容
function i3k_db_get_week_box_drop_reward(dropID)
	local reward = i3k_db_week_limit_reward_drop[dropID]
	if reward then
		return reward.dropReward
	end
	return {}
end
--决战荒漠当前安全区的信息
function i3k_db_get_desert_battle_poisonCircle()
	local circleInfo = g_i3k_game_context:getPoisonCircleInfo()
	if not circleInfo or circleInfo.round == 0 then 
		return nil 
	end

	local safeInfo = {pos = {}, radius = 0}
	local poisonInfo = {pos = {}, radius = 0}
	local cfg = i3k_db_desert_battle_poisonCircle.poisonCircle
	-- local cfgPoint = i3k_db_desert_battle_poisonCircle.circlePoint
	local first = i3k_db_desert_battle_poisonCircle.firstRadius
	safeInfo.pos =  i3k_logic_pos_to_world_pos(circleInfo.safeOrigin)
	safeInfo.radius = cfg[circleInfo.round].radius
	poisonInfo.pos = i3k_logic_pos_to_world_pos(circleInfo.round == 1 and first.pos or circleInfo.poisonOrigin)
	poisonInfo.radius = circleInfo.round == 1 and first.radius or cfg[circleInfo.round - 1].radius

	local roundEndTime = circleInfo.roundEndTime
	local surplusTime = roundEndTime - i3k_game_get_time()
	
	local cfgTime = cfg[circleInfo.round] 				
	local needTime = cfgTime.endTime - cfgTime.startTime
	local sleepTime = surplusTime - needTime
	if surplusTime <= 0 then
		poisonInfo = safeInfo
	elseif sleepTime > 0 then
		return safeInfo, poisonInfo, surplusTime
	else
		-- 计算新半径
		--local cfgTime = cfg[circleInfo.round] 				
		--local needTime = cfgTime.endTime - cfgTime.startTime
		local distance = poisonInfo.radius - safeInfo.radius
		local surplusDistance = (distance / needTime) * surplusTime
		poisonInfo.radius = safeInfo.radius + surplusDistance

		--计算新圆心
		local distancePos = i3k_vec3_dist(poisonInfo.pos, safeInfo.pos)
		local curDistance =  (distancePos / needTime) * surplusTime
		local offset = distancePos - curDistance
		local moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(safeInfo.pos, poisonInfo.pos));
		poisonInfo.pos = i3k_vec3_2_int(i3k_vec3_add1(poisonInfo.pos, i3k_vec3_mul2(moveDir, offset)))
	end
	return safeInfo, poisonInfo, surplusTime
end

--获取等待时间
function i3k_db_get_poisonCircle_sleepTime()
	local circleInfo = g_i3k_game_context:getPoisonCircleInfo()
	if circleInfo and circleInfo.round ~= 0 then
		local cfg = i3k_db_desert_battle_poisonCircle.poisonCircle
		local roundNum = #i3k_db_desert_battle_poisonCircle.poisonCircle
		local roundEndTime = circleInfo.roundEndTime
		local cfgTime = cfg[circleInfo.round] 
		local surplusTime = roundEndTime - i3k_game_get_time()
		local needTime = cfgTime.endTime - cfgTime.startTime	
		local sleepTime = surplusTime - needTime
		
		--显示安全区时间
		local needStartTime = cfgTime.endTime - cfgTime.safeTime
		local startTime = surplusTime - needStartTime
		if roundNum == circleInfo.round and surplusTime <= 0  then 
			return nil, nil
		end
		return sleepTime, startTime
	end
	return nil, nil
end

--前往安全区
function i3k_db_is_safety_zone()
	local hero = i3k_game_get_player_hero()
	local safeInfo = g_i3k_db.i3k_db_get_desert_battle_poisonCircle()
	if not safeInfo then
		return  g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17628))
	end
	local safePos = safeInfo.pos
	if hero and safePos then
		local heroPos = hero:GetCurPos()
		local distance = i3k_vec3_dist(i3k_logic_pos_to_world_pos(heroPos), safePos)
		if distance <= safeInfo.radius then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17627))
		end
		local targetMapId = g_i3k_game_context:GetWorldMapID()
		g_i3k_game_context:setMiniMapTargetPosMapID(targetMapId)
		g_i3k_game_context:SeachPathWithMap(targetMapId, safePos, nil, nil,nil, nil, nil, nil, g_FindWayTips_State)

	end
end

function i3k_db_get_desertSpeed_info(safeInfo, poisonInfo, time)
	local x = (safeInfo.pos.x - poisonInfo.pos.x) / time
	local z = (safeInfo.pos.z - poisonInfo.pos.z) / time
	local r = (safeInfo.radius - poisonInfo.radius) / time
	return {x = x, y = 0, z = z, radius = r}
end

--获取荒漠背包最大格子数
function i3k_db_desert_bag_cell_max_num()
	local bagRow = i3k_db_desert_battle_base.bagRow
	return bagRow * g_DESEET_BAG_ROW_NUM
end

--根据荒漠装备心法类型获得装备心法ID
function i3k_db_get_desert_xinfaID_by_xinfaType(xinfaType)
	for id, v in ipairs(i3k_db_desert_battle_xinfa_cfg) do
		for _, n in ipairs(v.xinfaType) do
			if n == xinfaType then
				return id
			end
		end
	end
	return nil
end

function i3k_db_get_desert_enough_xinfa_count(curXinfaID)
	local count = 0
	local wEquip = g_i3k_game_context:GetDesertBattleEquipData()
	for _, id in pairs(wEquip) do
		local equipCfg = i3k_db_get_desert_equip_item_cfg(id)
		if equipCfg.xinfaType ~= 0 then
			local equipXinfaID = i3k_db_get_desert_xinfaID_by_xinfaType(equipCfg.xinfaType)
			if equipXinfaID and equipXinfaID == curXinfaID then
				count = count + 1
			end
		end
	end
	return count
end

--判断宝箱状态
function i3k_desert_resource_can_open(ID)
	local resInfo = g_i3k_game_context:GetDesertBattleResInfo()
	if resInfo and resInfo.gatheredIDs then
		for _,v in ipairs(resInfo.gatheredIDs) do
			if v == ID then
				return false, resInfo.refreshTime
			end
		end
	end
	return true
end

--获取宝箱时间
function  i3k_desert_resource_open_state(time)
	local curTime = i3k_game_get_time()
	if curTime > time then
		return false
	end
	local needTime = time - curTime
	local txtTime = i3k_get_string(17603, i3k_get_time_show_text_simple(needTime))
	return txtTime
end

--判断那些副本可以更新属性。
function i3k_is_can_update_property()
	local mapType = i3k_game_get_map_type()

	if not mapType then
		return false
	end

	--会武特殊
	if mapType == g_TOURNAMENT then
		local world = i3k_game_get_world()
		local tType = g_i3k_db.i3k_db_get_tournament_type(world._cfg.id)
		if tType == g_TOURNAMENT_CHUHAN then
			return false
		end
	end
	local mapTb = 
	{
			[g_Life] = true,
			[g_Pet_Waken] = true,
			[g_PET_ACTIVITY_DUNGEON] = true,
			[g_DESERT_BATTLE] = true,
		[g_SPY_STORY]	= true,
		[g_BIOGIAPHY_CAREER] = true,
	}

	return not mapTb[mapType]
end
------------武诀--------------------
-- ui中的技能按钮的序号，与配置的db中的技能需要的映射关系。
-- 根据配置id，获取对应的ui中的id
function i3k_db_get_wujue_skill_ui_id(id)
	local list = {1, 2, 3, 4, 5, 6, 7, 8} -- 写死的字段
	return list[id]
end

-- 获取武决 活跃度对应经验
function i3k_db_get_wujue_active_exp(from, to)
	for i,v in ipairs(i3k_db_wujue.sort_levels)do
		--判断是否在同一个区间
		if from >= (i3k_db_wujue.sort_levels[i - 1] or 0 ) and to <= v then
			local rank = g_i3k_game_context:getWujueRank()
			local expRate = i3k_db_wujue_break[rank].expRate
			return i3k_db_wujue.levels[v] * (to - from) * (1 + expRate / 10000)
		end
	end
	--跨区间了 或者都到最大不该获取经验了
	for i,v in ipairs(i3k_db_wujue.sort_levels) do
		if v > from and v <= to then --找到跨的哪个坎
			return i3k_db_get_wujue_active_exp(from, v) + i3k_db_get_wujue_active_exp(v, to)
		end
	end
	return 0 --都到最大了
end

--武决 获取经验后应该升到多少级 多少经验 --当前等级 --加过后的经验
function i3k_db_get_wujue_level_exp(level, exp)
	local rank = g_i3k_game_context:getWujueRank()
	local levelTop = i3k_db_wujue_break[rank].levelTop
	local nextLevelCfg = i3k_db_wujue_level[level + 1]
	if not nextLevelCfg then
		return level, exp
	end
	local nextLevelNeedExp = nextLevelCfg.needExp
	if level < levelTop then
		if exp < nextLevelNeedExp then
			return level, exp
		else
			return i3k_db_get_wujue_level_exp(level + 1, exp - nextLevelNeedExp)
		end
	else
		local maxLevelExp = nextLevelNeedExp * i3k_db_wujue.maxExpWhenMax --上限那一级的最高存储经验
		return level, math.min(exp, maxLevelExp)
	end
end

--武决 是否达到限制的最大经验值
function i3k_db_wujue_can_get_exp()
	local data = g_i3k_game_context:getWujueData()
	local breakCfg = i3k_db_wujue_break[data.rank]
	local nextLevelCfg = i3k_db_wujue_level[data.level + 1]
	if data.level < breakCfg.levelTop then
		return true
	end
	if data.level == breakCfg.levelTop and data.exp < nextLevelCfg.needExp * i3k_db_wujue.maxExpWhenMax then
		return true
	end
	return false
end

function i3k_db_wujue_consume_items(items, at)
	for i, v in ipairs(items) do
		g_i3k_game_context:UseCommonItem(v.id, v.count, at)
	end
end

function i3k_db_wujue_consume_is_enough(items)
	for i, v in ipairs(items) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return false
		end
	end
	return true
end

function i3k_db_wujue_on_key_use_item()
	if not i3k_db_wujue_can_get_exp() then
		g_i3k_ui_mgr:PopupTipMessage("武诀等级已达上限，无法继续使用")
		return
	end
	local data = g_i3k_game_context:getWujueData()
	local level,exp,rank = data.level,data.exp,data.rank
	local totalExp = 0--升到限制等级需要多少经验
	while level < i3k_db_wujue_break[rank].levelTop do
		totalExp = i3k_db_wujue_level[level + 1].needExp + totalExp - exp
		exp = 0
		level = level + 1
	end
	if i3k_db_wujue_level[level + 1] then
		totalExp = totalExp + i3k_db_wujue_level[level + 1].needExp * i3k_db_wujue.maxExpWhenMax - exp
	end
	local canUseItems = {}
	for k, v in pairs(i3k_db_new_item) do
		if v.type == UseItemWuJueExp then
			table.insert(canUseItems,{id = k, exp = v.args1, count = g_i3k_game_context:GetCommonItemCanUseCount(k)})
		end
	end
	table.sort(canUseItems, function(a,b)
		return a.exp < b.exp
	end)
	local record = {}
	for i, v in ipairs(canUseItems) do
		if v.exp * v.count >= totalExp then
			if math.ceil(totalExp / v.exp) ~= 0 then
				record[v.id] = math.ceil(totalExp / v.exp)
				break
			end
		else
			if v.count ~= 0 then
				record[v.id] = v.count
				totalExp = totalExp - v.exp * v.count
			end
		end
	end
	if next(record) then
		i3k_sbean.useWujueExpItems(record)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
	end
end

function i3k_db_get_wujue_level_prop(level)--不传是当前等级的
	local wujueLevel = level or g_i3k_game_context:getWujueLevel()
	return i3k_db_wujue_level[wujueLevel] and i3k_db_wujue_level[wujueLevel].props
end

function i3k_db_get_wujue_skill_prop(skillID, lvl)
	local skillLvl = lvl or g_i3k_game_context:getWujueSkillLevel(skillID)
	if skillLvl > 0 then
		return i3k_db_wujue_skill[skillID][skillLvl]
	end
end
--判断武决潜魂状态 升星还是升阶还是未激活还是max
function i3k_db_get_wujue_soul_state(soulId, lvl)
	if lvl == 0 then
		return g_WUJUE_SOUL_STATE_UNLOCK
	end
	local soulDataCfg = i3k_db_wujue_soul[soulId][lvl]
	local curRank = soulDataCfg.rank
	local nextLvlCfg = i3k_db_wujue_soul[soulId][lvl + 1]
	if not nextLvlCfg then
		return g_WUJUE_SOUL_STATE_MAX
	else
		local nextRank = nextLvlCfg.rank
		if curRank == nextRank then
			return g_WUJUE_SOUL_STATE_UP_STAR
		else
			return g_WUJUE_SOUL_STATE_UP_RANK
		end
	end
end
function i3k_db_get_wujue_soul_props(soulId, lvl)
	local soulCfg = i3k_db_wujue_soul[soulId][lvl]
	return soulCfg and soulCfg.props or {}
end
function i3k_db_get_wujue_all_soul_props(soulLvlsMap)
	local t = {}
	for id, _ in ipairs(i3k_db_wujue.soulCfg) do
		for _, prop in ipairs(i3k_db_get_wujue_soul_props(id, soulLvlsMap[id] or 0)) do
			local pid = prop.id
			local val = prop.value
			t[pid] = (t[pid] or 0) + val
		end
	end
	return t
end
-------------武诀end-----------------
---------幻形-------------------------
function i3k_db_get_metamorphosis_count()
	return table.nums(i3k_db_metamorphosis)
end
--判断是否已激活该幻形
function i3k_db_get_metamorphosis_is_have(metamorphosisID)
	local allMetamorphosis = g_i3k_game_context:GetActivationMetamorphosis()
	if not allMetamorphosis then return false end
	for i, v in pairs(allMetamorphosis ) do
		if i == metamorphosisID then
			return true
		end
	end
	return false
end

--判断改时装是否正在装备
function i3k_db_get_metamorphosis_is_wear(metamorphosisID)
	local curFashion = g_i3k_game_context:GetCurMetamorphosis()
	return curFashion == metamorphosisID
end

--获取幻形配置
function i3k_db_get_metamorphosis_cfg(id)
	return i3k_db_metamorphosis[id < 0 and -id or id]
end

--获取幻形属性
function i3k_db_get_metamorphosis_property(metamorphosisID)
	local tmp = {}
	local cfg = i3k_db_get_metamorphosis_cfg(metamorphosisID)
	for i=1, 2 do
		local proId = string.format("property%sId", i)
		local proValue = string.format("property%sValue", i)
		local propertyId = cfg[proId]
		local propertyValue = cfg[proValue]
		if propertyId ~= 0 and propertyValue ~= 0 then
			tmp[propertyId] = propertyValue
		end
	end
	return tmp
end

--判断背包道具是否为幻形道具
function i3k_db_get_bag_item_metamorphosis_able(id)
	local db = i3k_db_get_other_item_cfg(id)
	return db and db.type == UseItemMetamorphosis
end

-------------幻形end---------------------

------------结拜--------------------
function i3k_db_get_title_orderSeatId_bySelfIndex(cell_index, gender, isBigger)
	for k, v in pairs(i3k_db_sworn_title_orderSeats) do
		if v.order == cell_index and v.gender == gender and v.isBigger == isBigger then
			return v
		end
	end
end
------------结拜end--------------------

-- 翻翻乐随机模型ID组合
-- size必须小于等于(maxRand - minRand + 1 - memoryCardFourNum) * needCardTwo + memoryCardFourNum * needCardFour
function i3k_db_get_repeat_randrom_number(size, minRand, maxRand, needCardTwo, needCardFour, memoryCardFourNum)
	local fourRandMap = {}
	local function getRand(tab)
		local rand = i3k_engine_get_rnd_u(minRand, maxRand)
		if i3k_db_get_vector_same_number_count(tab, rand) < needCardTwo then
			return rand
		else
			fourRandMap[rand] = (fourRandMap[rand] or 0) + 1
			if i3k_db_get_vector_same_number_count(tab, rand) < needCardFour and table.nums(fourRandMap) <= memoryCardFourNum then
				return rand
			else
				fourRandMap[rand] = (fourRandMap[rand] - 1 > 0) and (fourRandMap[rand] - 1) or nil
				return getRand(tab)
			end
		end
	end
	local result = {}
	for i = 1, size do
		local rand = getRand(result)
		table.insert(result, rand)
	end
	return result
end
function i3k_db_get_vector_same_number_count(vector, rand)
	local sameCount = 0
	for _, v in ipairs(vector) do
		if v == rand then
			sameCount = sameCount + 1
		end
	end
	return sameCount
end
--天魔迷宫  获得传送点
function i3k_db_get_maze_transfer_points()
	local cfg = i3k_db_maze_Map[g_i3k_game_context:GetWorldMapID()]
	local points = {}
	if cfg then
		for _, v in ipairs(cfg.AreaId) do
			local area = i3k_db_maze_Area[v]
			if area then
				for _, s in ipairs(area.transferID) do
					table.insert(points, s)
				end
			end
		end
	end
	return points
end

function i3k_db_get_maze_transfer_points_cfg(id, mapype)
	local numID = tonumber(id)

	if mapype == g_MAZE_BATTLE then
		return i3k_db_maze_transfer_point[numID]
	else
		return i3k_db_transfer_point[numID]
	end
end

function i3k_db_get_maze_mine_isIn_Area(id)
	local mazeData = g_i3k_game_context:getBattleMazeData()

	if not mazeData then
		return false
	end

	local cfg = i3k_db_maze_Area[mazeData.curZoneID]

	if cfg then
		for _, v in ipairs(cfg.resourcesID) do
			local resCfg = i3k_db_maze_resourcepoint[v]

			if resCfg and resCfg.ResourcepointID == id then
				return true
			end
		end
	end

	return false
end

--检查天魔迷宫的传送
function i3k_db_get_maze_transferPonit_isIn_Area(id)
	local mazeData = g_i3k_game_context:getBattleMazeData()
	if not mazeData then
		return false
	end
	local cfg = i3k_db_maze_Area[mazeData.curZoneID]
	if cfg then
		for _, v in ipairs(cfg.transferID) do
			if v == id then
				return true
			end
		end
	end
	return false
end
function i3k_db_get_maze_cur_zone_name(id)
	if not id then
		return ""
	end
	
	local cfg = i3k_db_maze_Area[id]
	
	if cfg then
		return i3k_get_string(cfg.nameid)
	end
	
	return ""
end
function i3k_db_get_maze_can_defeat(id)
	local cfg = i3k_db_maze_Map[id]
	if not cfg then
		return 0
	end
	local dcfg = i3k_db_maze_difficulty[cfg.defType]
	if not dcfg then
		return 0
	end
	return dcfg.defeatNum
end
--end
--节日限时任务是否开放
function i3k_db_is_in_festival_task(id)
	local info = i3k_db_festival_cfg[id]
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local openTime = string.split(info.openTime, ":")
	local closeTime = string.split(info.closeTime, ":")
	if timeStamp >= (info.openDate + openTime[1] * 3600 + openTime[2] * 60 + openTime[3]) and timeStamp <= (info.closeDate + closeTime[1] * 3600 + closeTime[2] * 60 + closeTime[3]) then
		return true
	else
		return false
	end
end

--[[function i3k_db_get_festival_limit_id()
	for k, v in pairs(i3k_db_festival_cfg) do
		if i3k_db_is_in_festival_task(k) then
			return k
		end
	end
	return 0
end--]]

function i3k_db_get_festival_end_time(id)
	local info = i3k_db_festival_cfg[id]
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local closeTime = string.split(info.closeTime, ":")
	local endTime = info.closeDate + closeTime[1] * 3600 + closeTime[2] * 60 + closeTime[3]
	if timeStamp <= endTime then
		local endDate = os.date("*t", endTime)
		local nowDate = os.date("*t", timeStamp)
		if endDate.year == nowDate.year then
			return i3k_get_string(17810, endDate.month, endDate.day, info.closeTime), true
		else
			return i3k_get_string(17809, endDate.year, endDate.month, endDate.day, info.closeTime), true
		end
	else
		return "", false
	end
end

function i3k_db_get_festival_limit_time(id)
	local info = i3k_db_festival_cfg[id]
	local startDate = os.date("*t", info.openDate)
	local endDate = os.date("*t", info.closeDate)
	return i3k_get_string(17801, startDate.year, startDate.month, startDate.day, info.openTime, endDate.year, endDate.month, endDate.day, info.closeTime)
end

-- 计算一个支线任务的id范围，之前是直接（*1000），这样浪费了太多的范围，导致也不方便扩展，重构出来下面3个方法。
-- 1. hash加密
-- 2. hash解密
-- 3. 检查范围
-- 后面要是拓展的话，也是类似的方法吧，封装3个方法
function i3k_db_get_subline_task_hash_id(id)
	local hashID = id + 1000
	if not g_i3k_db.i3k_db_check_subline_task_by_hash_id(hashID) then
		error("not in range, id:"..id)
	end
	return hashID
end

function i3k_db_get_subline_task_real_id(hashID)
	if not g_i3k_db.i3k_db_check_subline_task_by_hash_id(hashID) then
		error("not in range, hashID:"..hashID)
	end
	return hashID - 1000
end

function i3k_db_check_subline_task_by_hash_id(hashID)
	return 1000 < hashID and hashID < 2000
end
----------------------------------------
-- 势力声望任务也跟上面类似，搞一下，从2000开始
-- 其中 groupID 和 id 都是在（0, 100)范围内, 最小值101(1,1)，最大值9999(99,99)
-- 再加上10000，不会和上面的千位冲突，故最终的范围为(10101, 19999)
function i3k_db_get_power_rep_task_hash_id(groupID, id)
	local hashID = groupID * 100 + id + 10000
	if not g_i3k_db.i3k_db_check_power_rep_task_by_hash_id(hashID) then
		error("not in range, group:"..groupID.." id:"..id)
	end
	return hashID
end

function i3k_db_get_power_rep_task_real_id(hashID)
	if not g_i3k_db.i3k_db_check_power_rep_task_by_hash_id(hashID) then
		error("not in range, hashID:"..hashID)
	end
	local value = hashID - 10000
	local groupID = math.modf(value / 100)
	local id = value - groupID * 100
	return groupID, id
end

function i3k_db_check_power_rep_task_by_hash_id(hashID)
	return 10000 + 1 * 100 + 1 <= hashID and hashID <= 10000 + 99 * 100 + 99
end

function i3k_db_get_festival_task_hash_id(groupID, id)
	local hashID = groupID * 100 + id + 20000
	if not g_i3k_db.i3k_db_check_festival_task_by_hash_id(hashID) then
		error("not in range, group:"..groupID.." id:"..id)
	end
	return hashID
end

function i3k_db_get_festival_task_real_id(hashID)
	if not g_i3k_db.i3k_db_check_festival_task_by_hash_id(hashID) then
		error("not in range, hashID:"..hashID)
	end
	local value = hashID - 20000
	local groupID = math.modf(value / 100)
	local id = value - groupID * 100
	return groupID, id
end

function i3k_db_check_festival_task_by_hash_id(hashID)
	if hashID then
		return 20101 <= hashID and hashID <= 29999
	end
end

--获取节日限时任务接取对白
function i3k_db_get_festival_task_get_desc(groupId, taskId)
	local task_cfg = i3k_db_festival_task[groupId][taskId]
	return getFourDialog(task_cfg, "getTaskDialogue")
end

--获取节日限时任务完成对白
function i3k_db_get_festival_task_finish_desc(groupId, taskId)
	local task_cfg = i3k_db_festival_task[groupId][taskId]
	return getFourDialog(task_cfg, "finishTaskDialogue")
end

--修炼之门 获取这个buff该获得多少加成 percent是百分比
function i3k_db_get_practice_door_extra_buff_addition(buffType, buffCount)
	if buffCount <= 0 then
		return 0
	end
	local cfg = i3k_db_team_buff[buffType]
	local value --每个buff加多少加成
	if cfg.refBuffID == 0 then
		value = cfg.value
	else
		value = i3k_db_buff[cfg.refBuffID].affectValue
	end
	local total = 0
	for i=1,buffCount do
		local factor = 10000
		local thresholdCfg = i3k_db_practice_door_addition_threshold[1]
		for i,v in ipairs(i3k_db_practice_door_addition_threshold) do
			if total < v.threshold / 100 then
				thresholdCfg = v
				break
			end
		end
		if buffType == g_TEAM_BUFF_RESULT_EXP then
			factor = thresholdCfg.expAdd
		elseif buffType == g_TEAM_BUFF_RESULT_COIN then
			factor = thresholdCfg.coinAdd
		elseif buffType == g_TEAM_BUFF_RESULT_ITEM then
			factor = thresholdCfg.itemAdd
		end
		total = total + math.ceil(value / 100 * factor / 10000)
	end
	return total
end

--任务新类型 布置场景 start--

function i3k_db_convert_index_to_value(index)
	if index <= 0 then
		return 1
	end
	return 2 ^ (index - 1)
end


function i3k_db_get_table_by_shifting_value(curValue, totalNum)
	local result = {}
	while curValue > 0 do
		table.insert(result, curValue % 2)
		curValue = math.floor(curValue / 2)
	end
	for i = 1, totalNum do
		if not result[i] then
			result[i] = 0
		end
	end
	return result
end

function i3k_db_get_finished_point_count(value, totalValue)
	local result = i3k_db_get_table_by_shifting_value(value, totalValue)
	local placeValue = 0
	for _, v in ipairs(result) do
		if v == 1 then
			placeValue = placeValue + 1
		end
	end
	return placeValue
end
function i3k_db_get_scene_mine_index(taskPointId, mineID)
	local cfg = i3k_db_scene_mine_cfg[taskPointId]
	for index, v in ipairs(cfg.mineIDs) do
		local resourcepointID = i3k_db_resourcepoint_area[v].ResourcepointID
		if resourcepointID == mineID then
			return index
		end
	end
	return nil
end
function i3k_db_get_scene_mine_have_place(value, taskPointId, mineId)
	local sceneMineCfg = i3k_db_scene_mine_cfg[taskPointId]
	local result = i3k_db_get_table_by_shifting_value(value, #sceneMineCfg.mineIDs)

	for i, v in ipairs(result) do
		local id = sceneMineCfg.mineIDs[i]
		local resourcepointID = i3k_db_resourcepoint_area[id].ResourcepointID
		if resourcepointID == mineId then
			return v == 1
		end
	end
	return false
end

--获取矿产ID
function i3k_db_get_cur_scene_mineId(taskPointId, value)
	local sceneMineCfg = i3k_db_scene_mine_cfg[taskPointId]
	local result = i3k_db_get_table_by_shifting_value(value, #sceneMineCfg.mineIDs)

	for i, v in ipairs(result) do
		if v == 0 then
			return sceneMineCfg.mineIDs[i]
		end
	end
	return sceneMineCfg.mineIDs[1]
end

function i3k_db_get_scene_mineInfo(taskPointId, value)
	local mineId = i3k_db_get_cur_scene_mineId(taskPointId, value)
	return i3k_db_resourcepoint_area[mineId].pos, i3k_db_resourcepoint_area[mineId].ResourcepointID

end
----end---

-------------五绝争霸------------------
--返回当前开启答题类型
function i3k_db_get_open_answer_type()
	local year, month, day = g_i3k_get_YearAndDayAndTime1(i3k_game_get_time())
	local dataCfg = i3k_db_answer_open_time
	for k, v in ipairs(dataCfg) do
		if v.year == year and v.month == month then
			return v["day"..day].answerType
		end
	end
	return 0
end
--获取五绝争霸状态
function i3k_db_get_five_Contend_hegemony_state()
	local cfg = i3k_db_five_contend_hegemony.cfg
	--local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	local curTime = i3k_game_get_time()
	local isOpen = g_i3k_db.i3k_db_get_open_answer_type() == g_ANSWER_TYPE_HEGEMONY
	local openTime = g_i3k_get_day_time(cfg.openTime)
	local PreselectionTime = openTime + cfg.PreselectionTime
	local activityTime = PreselectionTime + (cfg.actionTime + cfg.guessingTime)*cfg.roundCount
	local showTime = activityTime + cfg.showTime
	if not isOpen or curTime < openTime or curTime > showTime then return g_FIVE_CONTEND_HEGEMONY_NONE end
	if curTime < PreselectionTime then return  g_FIVE_CONTEND_HEGEMONY_PRESELECTION end
	if curTime < activityTime then return  g_FIVE_CONTEND_HEGEMONY_ACTIVITY end
	if curTime < showTime then return  g_FIVE_CONTEND_HEGEMONY_SHOW end
end
---------骑战装备begin---------------
function i3k_db_get_steed_equip_part_name(equipID)
	local cfg = i3k_db_get_common_item_cfg(equipID)
	local partID = cfg.partID
	return i3k_db_steed_equip_part[partID].name
end
-- 根据一个装备id，来获取整个套装的id
function i3k_db_get_steed_equip_all(equipID)
	local cfg = i3k_db_get_common_item_cfg(equipID)
	local suitCfg = i3k_db_steed_equip_suit[cfg.suitID]
	return suitCfg.parts
end
function i3k_db_get_steed_equip_need_show_suitIdAndCount(wEquip, suitData)
	local suitMap = {}
	for _, equipID in pairs(wEquip) do
		local equipCfg = i3k_db_get_steed_equip_item_cfg(equipID)
		local suitID = equipCfg.suitID
		suitMap[suitID] = (suitMap[suitID] or 0) + 1
	end
	local suitVector = {}
	for suitID, count in pairs(suitMap) do
		local suitCfg = i3k_db_steed_equip_suit[suitID]
		table.insert(suitVector, {suitID = suitID, count = count, priority = suitCfg.priority})
	end
	table.sort(suitVector, function(a, b)
		--套装数量多的优先显示（5000->max）
		local countA = a.count * 5000
		local countB = b.count * 5000

		--未激活的套装优先显示（1000-2000）
		local activateA = suitData[a.suitID] and 1000 or 2000
		local activateB = suitData[b.suitID] and 1000 or 2000

		--优先级小的优先显示（1-50）
		local priorityA = a.priority
		local priorityB = b.priority

		return (countA + activateA + priorityB) > (countB + activateB + priorityA)
	end)

	if suitVector[1] then
		return suitVector[1].suitID, suitVector[1].count
	end
	return nil
end

function i3k_db_get_steed_equip_suit_need_equip(suitID)
	local sortSuitEquip = {}
	local suitEquip = i3k_db_steed_equip_suit[suitID].parts
	for _, equipID in ipairs(suitEquip) do
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
		sortSuitEquip[equipCfg.partID] = equipID
	end
	return sortSuitEquip
end

function i3k_db_get_steed_equip_power(equipID)
	local cfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local props = {}
	for k, v in ipairs(cfg.props) do
		props[v.id] = v.count
	end
	local power = g_i3k_db.i3k_db_get_battle_power(props, true)
	return power
end

function i3k_db_get_steed_step_name(equipID)
	local itemcfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local stepID = itemcfg.stepID
	local cfg = i3k_db_steed_equip_step[stepID]
	return cfg.name
end

-- 参数为一个map，返回一个根据key值排好序的list
function i3k_db_map_to_array(map)
	local res = {}
	for k, v in pairs(map) do
		local t = v
		t.id = k
		table.insert(res, t)
	end

	table.sort(res, function(a, b)
		return a.id < b.id
	end)
	return res
end

-- 参数为一个map，返回一个根据key值排好序的list,去掉key为0的值
function i3k_db_map_to_array2(map)
	local res = {}
	for k, v in pairs(map) do
		if k ~= 0 then
			local t = v
			t.id = k
			table.insert(res, t)
		end
	end

	table.sort(res, function(a, b)
		return a.id < b.id
	end)
	return res
end

-- 获取锻造配置
function i3k_db_get_steed_equip_duanzao_cfg(step, quality)
	local cfgID = step * 10 + quality
	local cfg = i3k_db_steed_equip_refine[cfgID]
	if not cfg then
		error("骑战装备表-锻造消耗 缺少配置 阶位元:"..step.." 品质:"..quality)
	end
	return cfg
end

-- 获取熔炉经验进度条等数值
function i3k_db_get_steed_equip_stove_value(level, exp)
	local db = i3k_db_steed_equip_stove
	local nextCfg = db[level + 1]
	local overTopPer = 0
	if not nextCfg then
		nextCfg = db[level]
	end
	if level + 1 == #db then
		local MAX_TIMES = i3k_db_steed_equip_cfg.maxMultiple -- 最大容量倍数
		overTopPer = (exp - nextCfg) / (MAX_TIMES * nextCfg) * 100
	end
	return {percent = exp / nextCfg * 100, barText = exp.."/"..nextCfg, overTopPer = overTopPer}
end

function i3k_db_get_steed_equip_stove_new_cfg(lvl, exp, addExp)
	local MAX_TIMES = i3k_db_steed_equip_cfg.maxMultiple -- 最大容量倍数
	local db = i3k_db_steed_equip_stove
	local totalExp = exp + addExp
	local level = lvl
	if level < #db - 1 then
		for i = level, #db - 1 do
			if db[i + 1] and totalExp >= db[i + 1] then
				totalExp = totalExp - db[i + 1]
				level = level + 1
			end
		end
	end
	if level >= #db then
		level = #db - 1
	end
	if exp >= db[#db] * MAX_TIMES then
		totalExp = db[#db] * MAX_TIMES
	end
	return {lvl = level, exp = totalExp}
end

-------------------------
--八卦祭品获取拆分获得物品id
function i3k_db_get_bagua_sacriface_gain_id_count(id)
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)

	if item_cfg.args5 ~= 0 then
		local cfg = i3k_db_bagua_sacrifice_split[item_cfg.args5]
		return cfg.gainId, cfg.gainNum
	end

	return 0, 0
end

--得到套装祭品
function i3k_db_get_bagua_suit_sacriface(suitId)
	local items = {}

	for _, v in ipairs(i3k_db_bagua_sacrifice_compound) do
		if v.suitId == suitId then
			table.insert(items, v)
		end
	end

	return items
end

--得到需要祭品套装
function i3k_db_get_bagua_sacriface_suit()
	local items = {}

	for _, v in ipairs(i3k_db_bagua_sacrifice_compound) do
		items[v.suitId] = true
	end

	return items
end
--end

--摇一摇活动start--
function i3k_db_get_shake_tree_activityID()
	for id, cfg in ipairs(i3k_db_shake_tree) do
		if g_i3k_checkIsInDateByTimeStampTime(cfg.startTime, cfg.endTime) then
			return id
		end
	end
	return nil
end
--摇一摇活动end--

--获取类型19神兵特技兵主冷却时长
function i3k_db_get_weapon_isHava_manualSkill(weaponId)
	local info = i3k_db_shen_bing_unique_skill[weaponId]

	if info then
		for _, v in pairs(info) do
			if v.uniqueSkillType == 19 then --变身后拥有【兵主】技能
				local parameters = v.parameters

				if g_i3k_game_context:isMaxWeaponStar(weaponId) then
					parameters = v.manparameters
				end

				return parameters
			end
		end
	end

	return false
end
--end

--获取家园宠物心情值对应的配置
function i3k_db_get_home_pet_mood_icon(mood)
	for k, v in ipairs(i3k_db_home_pet.mood) do
		if mood <= v.needMood then
			return v
		end
	end
	return i3k_db_home_pet.mood[#i3k_db_home_pet.mood]
end
--获取随时副本开始对话和模型
function i3k_db_get_at_any_moment_dialogue(mapId)
	local dialogues = {}
	local models = {}
	for _, v in ipairs(i3k_db_at_any_moment[mapId].startDialogue) do
		for i, j in ipairs(i3k_db_dialogue[v]) do
			table.insert(dialogues, j)
			if i3k_db_action_sound[v] then
				if i3k_db_action_sound[v].modelId[i] then
					table.insert(models, i3k_db_action_sound[v].modelId[i])
				else
					table.insert(models, 0)
				end
			else
				table.insert(models, 0)
			end
		end
	end
	return dialogues, models
end
--检查是否进入灵虚范围
function i3k_db_check_enter_flying_arena(curPos)
	local flyingData = g_i3k_game_context:getRoleFlyingData()
	if flyingData then
		for k, v in pairs(flyingData) do
			if v.isOpen ~= 1 then
				for i, j in ipairs(i3k_db_role_flying[k].flyPosId) do
					if not (v.finishMaps and v.finishMaps[j]) then
						local posData = i3k_db_at_any_moment[j]
						if g_i3k_game_context:GetWorldMapID() == posData.mapId then
							local posVec = i3k_vec3(posData.position[1], posData.position[2], posData.position[3])
							if i3k_vec3_dist(posVec, curPos) <= 5 then
								return j
							end
						end
					end
				end
			end
		end
	end
end
-- 通过武魂外显类型获取配置
function i3k_get_martialsoul_skin_by_type(skinType)
	local skinInfo = {};
	for k, v in pairs(i3k_db_martial_soul_display) do
		if v.diaplayType == skinType then
			table.insert(skinInfo, {id = k, data = v})
		end
	end
	return skinInfo
end
function i3k_db_get_martialsoul_rank_desc()
	local rankDesc = {}
	for _, e in ipairs(i3k_db_martial_soul_rank) do
		if e.displayID > 0 then
			table.insert(rankDesc, e);
		end
	end
	table.sort(rankDesc, function(d1, d2)
		return d1.displayID < d2.displayID
	end)
	return rankDesc
end
function i3k_db_check_world_boss_time(bossID)
	local cfg = i3k_db_world_boss[bossID]
	local startTime = cfg.startT
	local endTime = cfg.endT
	local nowTime = g_i3k_get_GMTtime(i3k_game_get_time())
	return startTime <= nowTime and nowTime <= endTime
end
---------周年舞会-------------
-- 是否在日期范围内
function i3k_db_check_dance_date()
	local startTime = i3k_db_dance.base.startDate
	local endTime = i3k_db_dance.base.endDate
	return g_i3k_checkIsInDate(startTime, endTime)
end
-- 是否在当天的活动时间内
function i3k_db_check_dance_time()
	local nowTime = i3k_game_get_time() % 86400
	for k, v in ipairs(i3k_db_dance.dance) do
		if v.time < nowTime and nowTime < v.time + v.length then
			return true
		end
	end
	return false
end
function i3k_db_check_in_dance_time()
	if i3k_db_check_dance_date() then
		return i3k_db_check_dance_time()
	end
	return false
end
function i3k_db_check_dance_npc(mapID, npcID)
	local cfg = i3k_db_dance_map[mapID]
	if not cfg then
		return false
	end
	if cfg.setNpcs then
		return cfg.setNpcs[npcID]
	end
end
-- 获取周年舞会npc的冒泡文字
function i3k_db_get_dance_pop_text()
	local list = i3k_db_dance_stage.popText
	local index = math.random(#list)
	return i3k_get_string(list[index])
end
-- -- 是否在舞会地图范围(不要每帧都调用)，延迟几秒调用一次
-- function i3k_db_check_in_dance_area(coord)
-- 	local mapID = g_i3k_game_context:GetWorldMapID()
-- 	local cfg = i3k_db_dance_map[mapID]
-- 	if not cfg then
-- 		return false
-- 	end
-- 	local function checkArea(x, z, r, curPointX, curPointZ)
-- 		local a = curPointX
-- 		local b = curPointZ
-- 		return r * r > math.abs((a - x)*(a - x) + (b - z)*(b - z))
-- 	end
-- 	return checkArea(cfg.point[1], cfg.point[3], cfg.radius/100, coord.x, coord.z)
-- end

--公主出嫁
function i3k_db_get_princess_marry_eventConfig(groupId, eventId)
	for _, v in ipairs(i3k_db_princess_eventStage) do
		if groupId == v.groupId and v.id == eventId then
			return v
		end
	end
end

function i3k_db_get_princess_marry_getGroupId()
	local mapid = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_princess_Config[mapid]
	return cfg.groupId
end

function i3k_db_get_princess_marry_reward(rank, cfg)
	for _, v in ipairs(cfg) do
		if v.rank == rank then
			return v.reward
		end
	end
end

function i3k_db_get_princess_marry_current_range(startTime, endTime)
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	return startTime <= curTime and curTime <= endTime
end
--end

------------------------------
-----守护灵兽
function i3k_db_get_pet_guard_use_items()
	local items = {}
	for k, v in pairs(i3k_db_new_item) do
		if v.type == UseItemPetGuard then
			table.insert(items, v)
		end
	end
	table.sort(items, function(a,b) return a.args1 < b.args1 end)
	return items
end

function i3k_db_get_pet_guard_one_key_use_items(petGuardId)
	local items = i3k_db_get_pet_guard_use_items()
	table.sort(items, function(a,b) return a.args1 > b.args1 end)
	local useItems = {}
	local lvl = g_i3k_game_context:GetPetGuardLevel(petGuardId)
	local maxPetLvl = g_i3k_game_context:GetPetsMaxLevel()
	local exp = g_i3k_game_context:GetPetGuardExp(petGuardId)
	local maxPetGuardLvl
	local cfg = i3k_db_pet_guard_level[petGuardId]
	for i = lvl, #cfg do--找到能升到的最大等级
		if maxPetLvl >= cfg[i].maxLvl then
			maxPetGuardLvl = i
		end
	end
	local maxCanGetExp = (cfg[lvl + 1] and cfg[lvl + 1].needExp or cfg[lvl].needExp) - exp --升到下一级所需要的经验
	for i = lvl + 1, maxPetGuardLvl, 1 do--从下一级开始升到最大等级所需要的经验
		if cfg[i + 1] then
			maxCanGetExp = maxCanGetExp + cfg[i + 1].needExp
		end
	end
	if maxPetGuardLvl ~= #cfg then --如果不是最大级不是满级 是升不到这个级别的 -1点经验方便计算
		maxCanGetExp = math.max(0, maxCanGetExp -1)
	end
	for i, v in ipairs(items) do
		local id = v.id
		local itemCfg = i3k_db_get_other_item_cfg(id)
		local cnt = g_i3k_game_context:GetCommonItemCanUseCount(id)
		local canUseCnt = math.floor(maxCanGetExp / itemCfg.args1)
		local useCnt = math.min(cnt, canUseCnt)
		maxCanGetExp = maxCanGetExp - useCnt * itemCfg.args1
		if useCnt > 0 then
			useItems[v.id] = useCnt
		end
	end
	return useItems
end

function i3k_db_get_pet_guard_can_one_key_use_item(petGuardId)
	local items = i3k_db_get_pet_guard_use_items()
	local haveId
	for k, v in pairs(items) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) ~= 0 then
			haveId = v.id
			break
		end
	end
	if haveId then
		return i3k_db_get_pet_guard_can_use_item(petGuardId, haveId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17959))
		return false
	end
end

function i3k_db_get_pet_guard_can_use_item(petGuardId, itemId)
	if g_i3k_game_context:GetCommonItemCanUseCount(itemId) == 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "PopupTipMessage", i3k_get_string(1092))--update里被调用 不能直接Popup
		return false
	end
	local lvl = g_i3k_game_context:GetPetGuardLevel(petGuardId)
	local exp = g_i3k_game_context:GetPetGuardExp(petGuardId)
	local cfg = i3k_db_pet_guard_level[petGuardId]
	local nextCfg = cfg[lvl + 1] or cfg[lvl]
	local itemCfg = i3k_db_get_other_item_cfg(itemId)
	if itemCfg.args1 >= nextCfg.needExp - exp and g_i3k_game_context:GetPetsMaxLevel() < nextCfg.maxLvl then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PetGuard, "PopupTipMessage", i3k_get_string(17948))
		return false
	end
	return true
end

function i3k_db_get_pet_guards_props()
	local props = {}
	for k, v in pairs(g_i3k_game_context:GetActivePetGuards()) do
		for k2, v2 in pairs(i3k_db_get_pet_guard_props(v.id)) do
			props[k2] = (props[k2] or 0 ) + v2
		end
	end
	return props
end

function i3k_db_get_pet_guard_props(petGuardId)
	local props = {}
	if g_i3k_game_context:IsPetGuardActive(petGuardId) then
		local lvl = g_i3k_game_context:GetPetGuardLevel(petGuardId)
		for k, v in pairs(i3k_db_pet_guard_level[petGuardId][lvl].props) do
	 		props[v.id] = v.value
		end
		local latents = g_i3k_game_context:GetPetGuardLatents(petGuardId)
		local isAllPotentialUnlock = i3k_db_get_is_pet_guard_potential_all_unlock(petGuardId)
		local allUnlockRatio = isAllPotentialUnlock and (i3k_db_pet_guard_base_cfg.allPotentialUnlockRatio / 10000) or 1
		if latents then
			for i, v in pairs(latents) do
				local cfg = i3k_db_pet_guard_potential[petGuardId][v]
				for i, v2 in pairs(cfg.props) do
					props[v2.id] = (props[v2.id] or 0) + v2.value * allUnlockRatio
				end
			end
		end
	end
	return props
end

function i3k_db_pet_guard_pet_props()
	local props = {}
	for k, v in pairs(i3k_db_get_pet_guards_props()) do
		props[k] = v * i3k_db_pet_guard_base_cfg.propLvlUpAddToPet / 10000
	end
	--附加心法属性
	if g_i3k_game_context:GetCurPetGuard() ~= 0 then
		local petGuardId = g_i3k_game_context:GetCurPetGuard()
		local cfg = i3k_db_pet_guard[petGuardId]
		for i=1,4,1 do
			local skillId = cfg["skillId"..i]
			local skillLvl = i3k_db_get_pet_guard_skill_lvl(skillId)
			local skillCfg = i3k_db_pet_guard_skills[skillId][skillLvl]
			local xinfaIds = skillCfg.xinfaId
			for _,xinfa in ipairs(xinfaIds) do
				local xinfaCfg = i3k_db_skill_talent[xinfa]
				if xinfaCfg.type == 1 and xinfaCfg.args.vtype == 1 then--加属性的心法
					local args = xinfaCfg.args
					props[args.pid] = (props[args.pid] or 0) + args.value
				end
			end
		end
	end
	return props
end

function i3k_db_get_pet_guard_skill_lvl(skillId)
	local active = g_i3k_game_context:GetActivePetGuards()
	local total = 1
	if active and next(active) then
		for petGuardId, petGuard in pairs(active) do
			for __, latent in ipairs(petGuard.latents) do
				local cfg = i3k_db_pet_guard_potential[petGuardId][latent]
				if cfg.skillId == skillId then
					total = total + 1
				end
			end
		end
	end
	return total
end

--守护灵兽潜能是否能显示解锁按钮 ui-显示
function i3k_db_get_pet_guard_potential_can_unlock(petGuardId, potentialId)
	local latents = g_i3k_game_context:GetPetGuardLatents(petGuardId)
	local cfg = i3k_db_pet_guard_potential[petGuardId][potentialId]
	local isPreUnlock = true
	for i, v in pairs(cfg.unlockPotentialGroupId) do
		if not i3k_db_get_pet_guard_potential_is_unlock(petGuardId, v) then
			isPreUnlock = false
			break
		end
	end
	if isPreUnlock or cfg.unlockPotentialGroupId[1] == 0 then--前提解锁了
		local condCfg = i3k_db_pet_guard_precondition[cfg.unlockConditionId]
		local process = i3k_db_get_pet_guard_potential_unlock_process(petGuardId, potentialId)
		if cfg.isCanQuickUnlock == 1 then
			return process
		else
			return process >= 1
		end
	end
	return false
end
--道具足够
function i3k_db_get_pet_guard_potential_can_real_unlock(petGuardId, potentialId)
	local process = i3k_db_get_pet_guard_potential_unlock_process(petGuardId, potentialId)
	if process >= 1 then
		return true
	else
		local needCount = i3k_db_pet_guard_potential[petGuardId][potentialId].needCount
		needCount = math.ceil(needCount * math.pow(1 - process, i3k_db_pet_guard_base_cfg.itemCountRatio))
		local commonCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_pet_guard_base_cfg.preUnlockNeedItemId)
		local have = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_pet_guard[petGuardId].needItemId)
		if needCount <= commonCount + have then
			return true
		end
	end
	return false
end

function i3k_db_get_pet_guard_potential_is_unlock(petGuardId, potentialId)
	local latents = g_i3k_game_context:GetPetGuardLatents(petGuardId)
	if latents then
		for k, v in pairs(latents) do
			if v == potentialId then
				return true
			end
		end
	end
	return false
end

--守护灵兽潜能解锁进度
function i3k_db_get_pet_guard_potential_unlock_process(petGuardId, potentialId)
	local cfg = i3k_db_pet_guard_potential[petGuardId][potentialId]
	local condCfg = i3k_db_pet_guard_precondition[cfg.unlockConditionId]
	local type = condCfg.type
	local process = 0
	if type == 1 then
		process = g_i3k_game_context:GetPetGuardLevel(petGuardId) / condCfg.targetArg
	elseif type == 2 then
		process = g_i3k_game_context:getPetDungeonSkillLevel(condCfg.args[1], false, false) / condCfg.targetArg
	elseif type == 3 then
		local skillList = i3k_db_mercenaries[condCfg.args[1]].skillList
		local skillsData = g_i3k_game_context:GetPetTrainSkillsData(condCfg.args[1])
		local maxLvl = 0
		for k,v in pairs(skillList) do
			if (skillsData[v] or 0) > maxLvl then
				maxLvl = skillsData[v]
			end
		end
		process = maxLvl / condCfg.targetArg
	elseif type == 4 then
		process = #(g_i3k_game_context:GetPetGuardLatents(petGuardId) or {}) / condCfg.targetArg
	elseif type == 5 then
		process = g_i3k_game_context:getBattlePower(condCfg.args[1]) / condCfg.targetArg
	elseif type == 6 then
		local upLvls = g_i3k_game_context:GetPetEquipsLvlData(condCfg.args[1])
		local upLvl = upLvls and upLvls[condCfg.args[2]] or 0
		process = upLvl / condCfg.targetArg
	end
	return process
end

function i3k_db_pet_guard_main_red()
	for k, v in pairs(i3k_db_pet_guard) do
		if i3k_db_pet_guard_red(k) then
			return true
		end
	end
	return false
end

function i3k_db_pet_guard_red(petGuardId)
	local active = g_i3k_game_context:IsPetGuardActive(petGuardId)
	if active then
		if i3k_db_pet_guard_potential_red(petGuardId) then--潜能红点
			return true
		else--能否使用道具激活
			return next(i3k_db_get_pet_guard_one_key_use_items(petGuardId)) ~= nil
		end
	else--未激活判断能否激活
		local cfg = i3k_db_pet_guard[petGuardId]
		return g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemId) >= cfg.needItemCount
	end
end

function i3k_db_pet_guard_potential_red(petGuardId)
	if not g_i3k_game_context:IsPetGuardActive(petGuardId) then
		return false
	end
	local cfg = i3k_db_pet_guard_potential[petGuardId]
	for k, v in pairs(cfg) do
		local unlock = i3k_db_get_pet_guard_potential_is_unlock(petGuardId, k)
		if not unlock then
			--前置节点判断
			local canUnlock = i3k_db_get_pet_guard_potential_can_unlock(petGuardId, k)
			if canUnlock then
				local process = i3k_db_get_pet_guard_potential_unlock_process(petGuardId, k)
				if process >= 1 then
					return true
				elseif i3k_db_get_pet_guard_potential_can_real_unlock(petGuardId, k) then
			return true
				end
			end
		end
	end
	return false
end

function i3k_db_get_is_pet_guard_potential_all_unlock(petGuardId)
	local latents = g_i3k_game_context:GetPetGuardLatents(petGuardId) or {}
	return #latents == 20 --有20个就是全部解锁了
end

function i3k_db_cardPacket_get_card_back_cfg(id)
	local db = i3k_db_cardPacket_cardBack
	return db[id + 1]
end
function i3k_db_cardPacket_get_card_cfg(id)
	for k, v in pairs(i3k_db_cardPacket_card) do
		for i, e in pairs(v) do
			if e.id == id then
				return e
			end
		end
	end
end
function i3k_db_cardPacket_get_cards_list(set)
	local res = {}
	for k, v in pairs(set) do
		local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(k)
		table.insert(res, cfg)
	end
	table.sort(res, function(a, b) return a.id < b.id end)
	return res
end
function i3k_db_cardPacket_get_unlock_desc(id)
	local cfg = i3k_db_cardPacket_get_card_cfg(id)
	local type = cfg.type
	local strID = i3k_db_cardPacket.unlockTypes[type]
	local str = ""
	if type == g_CARD_PACKET.TYPE_ITEM then
		local itemID = cfg.args[1]
		local name = i3k_db_get_common_item_name(itemID)
		str = i3k_get_string(strID, name)
	elseif type == g_CARD_PACKET.TYPE_WEAPON then
		local weaponID = cfg.args[1]
		local needLevel = cfg.args[2]
		local weaponCfg = i3k_db_shen_bing[weaponID]
		str = i3k_get_string(strID, weaponCfg.name, needLevel)
	elseif type == g_CARD_PACKET.TYPE_MAIN_TASK then
		local taskID = cfg.args[1]
		local taskCfg = i3k_db_main_line_task[taskID]
		str = i3k_get_string(strID, taskCfg.name)
	elseif type == g_CARD_PACKET.TYPE_CHENGJIU then
		local groupID = cfg.args[1]
		local taskID = cfg.args[2]
		local taskCfg = i3k_db_challengeTask[groupID][taskID]
		str = i3k_get_string(strID, taskCfg.title)
	elseif type == g_CARD_PACKET.TYPE_QIYUAN then
		local taskID = cfg.args[1]
		local taskCfg = i3k_db_adventure.head[taskID]
		str = i3k_get_string(strID, taskCfg.name)
	end
	return str
end
--  https://blog.csdn.net/yu121380/article/details/80410854
-- 弧度 = 角度 * pi / 180
-- 角度 = 弧度 * 180 / pi
function i3k_db_math_sin(angle)
	return math.sin(angle * math.pi / 180)
end
function i3k_db_math_asin(sin)
	local angle = math.asin(sin) * 180 / math.pi
	return angle
end
--潜能x y 坐标 转为 ui 下标
function i3k_db_get_pet_guard_potential_ui_map(x,y)
	return (x - 1) * 5 + y
end
function i3k_db_is_skillId_pet_skill(petId, skillId)
	local cfg = i3k_db_mercenaries[petId]
	if not cfg then
		return
	end
	local isSkill = false
	for i,v in ipairs(cfg.skills) do
		if v == skillId then
			isSkill = true
			break
		end
	end
	if not isSkill then
		isSkill = cfg.ultraSkill == skillId
	end
	return isSkill
end

-- 周年活动 --
function i3k_db_get_jubilee_task_cfg(taskID)
	return i3k_db_jubilee_tasks[taskID]
end

--获取周年庆任务接取对白
function i3k_db_get_jubilee_task_get_desc(taskId)
	local task_cfg = i3k_db_get_jubilee_task_cfg(taskId)
	return getFourDialog(task_cfg, "getTaskDialogue")
end

--获取周年庆任务完成对白
function i3k_db_get_jubilee_task_finish_desc(taskId)
	local task_cfg = i3k_db_get_jubilee_task_cfg(taskId)
	return getFourDialog(task_cfg, "finishTaskDialogue")
end

-- 获取当前处于周年活动的什么阶段
function i3k_db_get_jubilee_stage()
	local cfg = i3k_db_jubilee_base.commonCfg
	local nowTime = g_i3k_get_GMTtime(i3k_game_get_time())
	if nowTime < cfg.startTimeData1 then
		return g_JUBILEE_NOT_OPEN
	end

	if nowTime >= cfg.startTimeData1 and nowTime <= cfg.startTimeData2 then
		return g_JUBILEE_STAGE1
	end

	if nowTime >= cfg.startTimeData2 and nowTime <= cfg.startTimeData3 then
		return g_JUBILEE_STAGE2
	end

	local countdownTime = i3k_db_jubilee_base.stage3.countdownTime
	if nowTime >= cfg.startTimeData3 and nowTime <= cfg.endTimeData then
		if nowTime >= cfg.startTimeData3 and nowTime < cfg.startTimeData3 +  countdownTime then
			return g_JUBILEE_COUNTDOWN
		end

		if nowTime > cfg.startTimeData3 +  countdownTime then
			return g_JUBILEE_COUNTDOWN_END
		end

		return g_JUBILEE_STAGE3
	end

	return g_JUBILEE_END
end

-- 周年活动 阶段3特殊loading图
function i3k_db_get_jubilee_loadingIcon_text()
	-- local roleLvl = g_i3k_game_context:GetLevel() or 1
	-- if roleLvl < i3k_db_jubilee_base.commonCfg.joinLevel then
	-- 	return nil, nil
	-- end

	-- local stage3Cfg = i3k_db_jubilee_base.stage3
	-- local stage = i3k_db_get_jubilee_stage()
	-- if stage == g_JUBILEE_COUNTDOWN then
	-- 	return stage3Cfg.beforeLoadingIcon, i3k_get_string(stage3Cfg.beforeLoadingTxt)
	-- end

	-- if stage == g_JUBILEE_COUNTDOWN_END or stage == g_JUBILEE_STAGE3 then
	-- 	local times = g_i3k_game_context:GetubileeStep3MineralTimes()
	-- 	local dayLimitTimes = stage3Cfg.dayLimitTimes
	-- 	return stage3Cfg.afterLoadingIcon, i3k_get_string(stage3Cfg.afterLoadingTxt, dayLimitTimes - times, dayLimitTimes)
	-- end

	return nil, nil
end

--楚汉之争

--通过变身id获取属性id
function i3k_db_chess_get_props_for_model(forceType, forceArm)
	local cfg = i3k_db_chess_generals
	for k, v in ipairs(cfg) do
		if v.camp == forceType and v.arms == forceArm then
			return v.id
		end
	end
	return nil
end

--获取特殊头像
function i3k_db_get_chu_han_head_icon(roleId)
	local roleData = g_i3k_game_context:GetChuHanFightAllRoleInfo()

	if roleData then
		local info = roleData[roleId]
		if info then
			local id = g_i3k_db.i3k_db_chess_get_props_for_model(info.forceType, info.arm)
			if id then
				return i3k_db_chess_generals[id].classImg or 0
			end
		end
	end
	return 0
end

--获取头像
function i3k_db_get_role_head_icon(roleId, headIcon, square)

	local icon = headIcon
	if i3k_get_is_tournament_chu_han() then
		icon = g_i3k_db.i3k_db_get_chu_han_head_icon(roleId)
	end
	return g_i3k_db.i3k_db_get_head_icon_path(icon, square)
end

function i3k_db_check_ignore_channel(channel)
	local cfg = i3k_db_common.trainingCfg.ignoreChannels
	for k, v in ipairs(cfg) do
		if v == channel then
			return true
		end
	end
	return false
end

--宝石转化
function i3k_db_get_gem_exchange_cfg(id)
	for _, v in ipairs(i3k_db_gem_exchange) do
		if v.gemId == id then
			return v
		end
	end
end	
--end
---------神斗--------
function i3k_db_get_shen_dou_red()
	local level = g_i3k_game_context:GetLevel()
	if level < i3k_db_martial_soul_cfg.shenDouOpenLvl then
		return false
	end
	local curStar = g_i3k_game_context:GetCurStar()
	if curStar and (curStar / 100 < i3k_db_martial_soul_cfg.needEquipStarGear) then
		return false
	end
	local curLvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	if curLvl < #i3k_db_matrail_soul_shen_dou_level then--没到最大级
		local nextCfg = i3k_db_matrail_soul_shen_dou_level[curLvl + 1]
		local consume = nextCfg.consume
		local canUp = true
		for i,v in ipairs(consume) do
			canUp = g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= (v.count)
			if not canUp then
				break
			end
		end
		if canUp then
			return true
		end
	end
	--技能能否升级	
	for i, v in ipairs(i3k_db_matrail_soul_shen_dou_xing_shu) do
		if i3k_db_get_shen_dou_skill_can_level_up(i) then
			return true
		end
	end
	return false
end
function i3k_db_get_shen_dou_skill_can_level_up(skillId)
	local skillLvl = g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(skillId)
	if skillLvl == #i3k_db_matrail_soul_shen_dou_xing_shu[skillId] then return false end
	local curLvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	local rank = math.modf(curLvl / i3k_db_martial_soul_cfg.nodeCount)
	local nextCfg = i3k_db_matrail_soul_shen_dou_xing_shu[skillId][skillLvl + 1]
	if rank < nextCfg.needGrade then return false end
	if nextCfg.needStarLevel ~= 0 then
		local activeStars = g_i3k_game_context:GetActiveStars()
		local have = false
		for k,v in pairs(activeStars) do
			if k / 100 >= nextCfg.needStarLevel then
				have = true
				break
			end
		end
		if not have then return false end
	end
	if next(nextCfg.needXinShu) then
		for i, v in ipairs(nextCfg.needXinShu) do
			if g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(v.id) < v.level then
				return false
			end
		end
	end
	for i,v in ipairs(nextCfg.consume) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return false
		end
	end
	return true
end
function i3k_db_get_shen_dou_prop()
	local curStar = g_i3k_game_context:GetCurStar()
	local lvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	if not i3k_db_star_soul[curStar] or lvl == 0 then
		return {}
	end
	local cfg = i3k_db_matrail_soul_shen_dou_level[lvl]
	local curStar = g_i3k_game_context:GetCurStar()
	local type = i3k_db_star_soul[curStar].type
	local props = cfg.props[type]
	local tempProps = {}
	for i,v in ipairs(props) do
		tempProps[v.id] = math.modf(v.value * (1 + i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_GOD_STAR_ID)))
	end
	return tempProps
end
--神斗技能 提升属性 系数
function i3k_db_get_shen_dou_skill_prop_ratio(skillId, targetLvl)
	local lvl = targetLvl or g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(skillId)
	local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[skillId][lvl]
	return cfg and cfg.args1 / 10000 or 0
end
--返回二维数组，第一维索引为词缀类型，第二维索引为词缀顺序
function i3k_db_get_affix_info()
	return i3k_db_bagua_affix_priview
end
--我要变强 计算当前战力与推荐战力比较后的等级
function i3k_db_get_power_rank()
	local ratio = g_i3k_game_context:GetRolePower() / i3k_db_want_improve_recommendPower[g_i3k_game_context:GetLevel()].power
	for k,v in ipairs(i3k_db_want_improve_judgeCfg) do
		if ratio >= v.minValue/100 then
			return k
		end
	end
	return 0
end
--我要提升 拿到对应等级对应属性的最高配置数值计算达成进度
function i3k_db_get_WantImprove_LevelParam(paramID)
	local level = g_i3k_game_context:GetLevel()
	local param = i3k_db_want_improve_strongParam[paramID][level]
	return param
end
--神机藏海获取副本等级
function i3k_db_get_magic_machine_mapLvl()
	local roleLvl = g_i3k_game_context:GetLevel()
	local lvlCfg = i3k_db_magic_machine.lvl2map
	local maplvl = lvlCfg[#lvlCfg].uprLmt 
	if roleLvl >= maplvl then
		return maplvl
	end
	for _, v in ipairs(lvlCfg) do
		if v.uprLmt >= roleLvl then
			return v.uprLmt
		end
	end
end
--神机藏海end
--获取格式化好的时间
---#1 GMT时间
function i3k_db_get_format_time(time)
	local timetb = os.date("*t", time)
	for k, v in pairs(timetb) do
		local sv = tostring(v)
		if string.len(sv) == 1 then
			if sv ~= '0' then
				timetb[k] = '0'..sv
			else
				timetb.day = timetb.day..' '	
			end
		end
	end
	return string.format("%s.%s.%s %s:%s:%s", timetb.year, timetb.month, timetb.day, timetb.hour, timetb.min, timetb.sec)
end
--获取会武常奖励列表或可以领取 true列表 false可以领取
function i3k_db_get_tournament_week_reward_list(isReward)
	local items = {}
	local rewardInfo = {}
	local info = g_i3k_game_context:getTournamentWeekRewardInfo()
	for k, v in  ipairs(i3k_db_tournament_week_reward) do
		if info.reward and info.reward[v.needTimes] then
		else
			if isReward then
				v.isReward = info.weekTimes >=  v.needTimes
				table.insert(rewardInfo, v)
			else				
				if info.weekTimes >=  v.needTimes then
					items[v.needTimes] = 1
				end	
			end
		end
	end
	return isReward and rewardInfo or items
end
function i3k_db_rcsCompare(a, b)
	local i = 1
	while a[i] and b[i] and a[i] == b[i] do
		i = i + 1
	end
	if not a[i] or not b[i] or a[i] == b[i] then
		return 0
	elseif a[i] > b[i] then
		return 1
	else
		return -1
	end
end
local function loopCompare(a, b, i)
	if not a[i] or not b[i] then
		return 0
	end
	if a[i] > b[i] then
		return 1
	elseif a[i] < b[i] then
		return -1
	else
		return loopCompare(a, b, i + 1)
	end
end
--递归比较数组里元素大小，直到找到大于或小于或没有元素为止
--#1、2数组 #3比较的数组元素下标位置
--returns #1 大于1，小于-1，相等0
function i3k_db_rcsCompare(a, b)
	return loopCompare(a, b, 1)
end
--比较日期，精确到日
--#1、2 包含year、month、day字段的表
--returns #1 大于1，小于-1，相等0
function i3k_db_date_compare(a, b)
	return i3k_db_rcsCompare({a.year, a.month, a.day}, {b.year, b.month, b.day})
end
--计算op到right的距离和ed到left的距离，单位为天，参数均为日期表
--之所以不用秒来比较是为了重置统一距离计算起始位置
--return #1 op到right的距离 #2 ed到left的距离，
local function checkBoundary(left, right, op, ed)
	local rd = os.time({year = op.year, month = op.month, day = op.day}) - os.time({year = right.year, month = right.month, day = right.day})
	local ld = os.time({year = ed.year, month = ed.month, day = ed.day}) - os.time({year = left.year, month = left.month, day = left.day})
	return math.floor(rd / 86400 + 0.5), math.floor(ld / 86400 + 0.5)
end
function i3k_db_truncate(n, a, b)
	if n > b then return b end
	if n < a then return a end
	return n
end
-- 吧数组里的所有字符串转成number
-- #数字文本数组
local function allToNum(strs)
	local nums = {}
	for _, v in ipairs(strs) do
		table.insert(nums, tonumber(v))
	end
	return nums
end
local DAYSEC = 24 * 60 * 60
--获取本周日历活动
function i3k_db_get_calendar_activity()
	local time = g_i3k_get_GMTtime(i3k_game_get_time())
	local days = {} 
	for i = 1, 7 do
		table.insert(days,{activitys = {}, date = time + DAYSEC * (i - 1)})
	end
	for i, v in ipairs(i3k_db_schedule.cfg) do
		if v.showInCld == 1 then
			local l, r = i3k_db_open_date_filter(days, v, 1, 7)
			l, r = i3k_db_open_week_filter(days, v, l, r)
			if r >= l then
				local avaWds = {}	
				for idx = l, r do
					avaWds[os.date("*t", days[idx].date).wday - 1] = days[idx]
				end
				local openDay = i3k_db_get_open_day(v)
				for _, wd in ipairs(openDay) do
					if avaWds[wd] then
						table.insert(avaWds[wd].activitys, v)
					end
				end
			end
		end
	end
	
	for _, v in ipairs(days) do
		table.sort(v.activitys, function(a, b)
			local aBegin = string.split(a.actTime, ';')
			local bBegin = string.split(b.actTime, ';')
			aBegin = string.split(aBegin[1], ':')
			bBegin = string.split(bBegin[1], ':')
			return a.actTime == "-1.0" and b.actTime ~= "-1.0" or i3k_db_rcsCompare(allToNum(aBegin), allToNum(bBegin)) < 0 
		end)
	end
	return days
end
--计算左右天数。
--#1左边初始天数 #2右边初始天数
--#3开始日期时间戳，必须为当天零点 #4结束日期时间戳，必须为当天零点
--return #1边界左边天数 #2边界右边天数
function i3k_db_day_filter(days, l, r, bg, ed)
	return  math.max(r - math.floor((days[r].date - bg) / DAYSEC), l), math.min(l + 1 + math.floor((ed - days[l].date - 1) / DAYSEC), r)
end
function i3k_db_open_date_filter(days, cfg, l, r)
	if r >= l then
		local op = cfg.openDate or days[l].date
		local ed = cfg.closeDate or days[r].date
		return i3k_db_day_filter(days, l, r, op, ed)
	end
	return l, r
end
function i3k_db_gang_fight_week()
	local t = {}
	for i, v in ipairs(i3k_db_faction_fight_openday) do
		local dy = v.openday
		dy = string.split(dy, '-')
		local dt = os.time({year = dy[1], month = dy[2], day = dy[3], hour = 0, min = 0, sec = 0})
		local dist = os.date("*t", dt).wday - 2
		if dist == -1 then dist = 6 end
		table.insert(t, {bg = dt - DAYSEC * dist, ed = dt + (6 - dist) * DAYSEC})
	end
	return t
end
function i3k_db_open_week_filter(days, cfg, l, r)
	if r >= l then
		--帮派战
		if cfg.typeNum == g_SCHEDULE_TYPE_SECTFIGHT then
			local weeks = i3k_db_gang_fight_week()
			for i, v in ipairs(weeks) do
				local lt = l
				local rt = r
				lt, rt = i3k_db_day_filter(days, lt, rt, v.bg, v.ed)
				if rt >= lt then
					return lt, rt
				end
			end
			return l, l - 1
		end
	end
	return l, r
end
--获取活动开放日，有些开放逻辑不在日程表，可在这里单独处理
function i3k_db_get_open_day(cfg)
	if cfg.typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2 then
		local justiceHeartMapID = i3k_db_common.wipe.justiceHeartMapID
		for key, val in ipairs(justiceHeartMapID) do
			if (cfg.mapID == val) then
				return g_i3k_db.i3k_db_get_justiceHeart_info(cfg.mapID)
			end
		end
	end
	return cfg.actDay
end
function i3k_db_get_job_name(role_type, transform, bwType)
	if transform == 0 then
		return i3k_db_generals[role_type].name
	else
		return i3k_db_zhuanzhi[role_type][transform][bwType].name
	end
end
------家园守卫战start------------------------
--得到家园守卫战怪物最大波数
function i3k_db_get_homeland_guard_popMsg(count)
	local mapId = g_i3k_game_context:GetWorldMapID()
	if i3k_db_homeland_guard_batch[mapId] then
		return i3k_db_homeland_guard_batch[mapId][count]
	end
	return 0
end
--家园保卫战技能公CD
function i3k_db_get_homeland_guard_shareTotalCool()
	return i3k_db_homeland_guard_cfg.skillShareTime * 1000 
end
------家园守卫战end------------------------
-----鬼岛驭灵start-----------
--先灵碎片：随机获取一个怪物ID
function i3k_db_get_random_monsterModelID()
	local random = i3k_engine_get_rnd_u(1, #i3k_db_catch_spirit_monster_list)
	local monsterID = i3k_db_catch_spirit_monster_list[random]
	if i3k_db_catch_spirit_monster[monsterID].fragmentId == -1 then
		return i3k_db_get_random_monsterModelID()
	else
		return i3k_db_monsters[monsterID].modelID, monsterID
	end
end
function i3k_db_get_StrengthenSelf_Slider_Info(precent)
	for k, v in ipairs(i3k_db_want_improve_progressBarCfg) do
		if precent >= v.minValue then
			return v
		end
	end
	return nil
end
--获取兽穴活动开放日期
function i3k_db_get_justiceHeart_info(ID)
	local data = g_i3k_db.i3k_db_reset_justiceHeart_info()
	return data[ID] or {}
end
--更新兽穴活动开放日期
function i3k_db_reset_justiceHeart_info()
	local result = {}
	local mapID = i3k_db_common.wipe.justiceHeartMapID
	local openTime = i3k_db_common.wipe.justiceHeartOpenTime
	local week_day = 7
	for i = 1, week_day do
		local isOpen = i3k_get_activity_is_open_offset(openTime, i-1)
		local week = math.mod(g_i3k_get_week(g_i3k_get_day(i3k_game_get_time())+i-1), 7)
		if isOpen then
			local openId = (g_i3k_get_day(i3k_game_get_time())+i) % #mapID
			openId = openId == 0 and #mapID or openId
			local justiceHeart_mapID = mapID[openId]
			if not result[justiceHeart_mapID] then
				result[justiceHeart_mapID] = {}
			end
			table.insert(result[justiceHeart_mapID], week)
		end
	end
	return result
end
--坐骑自动洗练
function i3k_db_can_auto_refhine(lvl)
	return i3k_db_steed_common.autoRefine.refhineNeddLeve <= lvl
end
--坐骑洗练品质框
function i3k_db_can_auto_refhine_quality(value, cfg)
	if not cfg or not value then return g_RANK_VALUE_WHITE end
	local ratio = (value - cfg.minValue)/(cfg.maxValue - cfg.minValue)
	if ratio >= 0 and ratio < 0.2 then
		return g_RANK_VALUE_WHITE
	elseif ratio >= 0.2 and ratio < 0.4 then
		return g_RANK_VALUE_GREEN
	elseif ratio >= 0.4 and ratio < 0.6 then
		return g_RANK_VALUE_BLUE
	elseif ratio >= 0.6 and ratio < 0.8 then
	     return g_RANK_VALUE_PURPLE
	elseif ratio >= 0.8 and ratio < 1 then
		return g_RANK_VALUE_ORANGE
	elseif ratio >= 1 then
		return g_RANK_VALUE_MAX
	end
	return g_RANK_VALUE_WHITE
end
function i3k_db_auto_refhine_user_cfg(steedId)
	local user_cfg = g_i3k_game_context:GetUserCfg()
	local setCfg = user_cfg:GetSteedAutoRefine()[steedId] or {}
	local cfg = {}
	--{"01234567", "01234567", "01234567", "01234567", "01234567"}
	for _, v in ipairs(setCfg) do
		local item = {}
		local count = string.len(v)
		for i = 2, count do
			local lvl = string.sub(v, i, i)
			table.insert(item, checknumber(lvl))
		end
		table.insert(cfg, item)
	end
	return cfg
end
function i3k_db_auto_refhine_data_to_user_cfg(cfg)
	--{{5,4,3,0}, {5,4,3,0}, {0, 0, 0, 0}, {0,0,0,5}, {5,0,0,5},} 
	local conver = {}
	for _, v in ipairs(cfg) do	
		table.insert(v, 1, 1)
		local str = table.concat(v, "")
		table.insert(conver, str)
	end
	return conver
end
function i3k_db_get_color_outColor(rank)
	local tb = 
	{
		[g_RANK_VALUE_UNKNOWN] = {"ffb7b7b7", "ffaa654a"},
		[g_RANK_VALUE_BLUE] = {"ff0dc3ff", "ffaa654a"},
		[g_RANK_VALUE_PURPLE] = {"ff8a5cff", "ffaa654a"},
		[g_RANK_VALUE_ORANGE] = {"ffff7e2d", "ffaa654a"},
	}
	return tb[rank] or {"", ""} 
end
--end
--根据npc副本组ID拿到索引对应的mapID
function i3k_db_get_npcMapID_by_groupID(groupId)
	local level = g_i3k_game_context:GetTeamLevelAvg()
	local mapId = 0
	print("当前队伍的平均等级："..level)
	assert(i3k_db_NpcDungeon_ladder[groupId] ~= nil,"该副本组id："..groupId.."对应分组没有找到，请检查NPC副本配置表")
	local sortTable = {}
	for k,v in pairs(i3k_db_NpcDungeon_ladder[groupId]) do
		local item = {}
		item.lvl = k
		item.mapId = v.mapID
		table.insert(sortTable, item)
	end
	table.sort(sortTable, function(a,b) return a.lvl < b.lvl end)
	for _,value in ipairs(sortTable) do
		if level >= value.lvl then
			mapId = value.mapId
		else
			break
		end
	end
	print("进入副本的mapid："..mapId)
	return mapId
end
--拳师切换姿态CD
function i3k_db_get_CombatTypeCD()
	local cdArg = 0
	local hero = i3k_game_get_player_hero()
	if hero then
		cdArg = hero:GetPropertyValue(ePropID_CombatTypeCD)
	end
	return (i3k_db_common.general.combatTypeCD - cdArg) / 1000 
end
-- 五行轮转
function i3k_db_get_five_element_can_enter()
	local cfg = i3k_db_five_elements
	local openTime = cfg.activityDate
	local dayStartTime = cfg.time.openTime
	local datEndTime = dayStartTime + cfg.time.durationTime
	local isInTodayTime = g_i3k_checkIsInTodayTime(dayStartTime, datEndTime) --当天
	local isOpenDay = i3k_get_activity_is_open(cfg.openDay) -- 周
	local isOpenData =  g_i3k_checkIsInDateByTimeStampTime(openTime.openDate, openTime.endDate) -- 活动日期
	return isOpenData and isOpenDay and isInTodayTime
end
function i3k_db_get_five_element_time(mapID)
	return i3k_db_five_elements.mapDetail[mapID].mapOpenTime
end
-- 帮派合照
function i3k_db_get_faction_photo_pos_cfg(count)
	local index = 1
	for k, v in ipairs(i3k_db_faction_photo_position) do
		if v.countMax >= count then
			return v
		else
			index = index + 1
		end
	end
	error("could not found cfg, count = ".. count)
end
function i3k_db_get_faction_photo_positions(count)
	local cfg  = i3k_db_get_faction_photo_pos_cfg(count)
	return cfg.positions
end
--合照排序
function i3k_db_get_faction_photo_sort(tmp_members)
	local chiefId = g_i3k_game_context:GetFactionChiefID()
	local deputy = g_i3k_game_context:GetFactionDeputyID()
	local elder = g_i3k_game_context:GetFactionElderID()
	local elite = g_i3k_game_context:GetFactionEliteID()
	local tmp_info = {}
	for k,v in pairs(tmp_members) do
		local id = nil
		if not v.role or not v.role.id then
			id = k
		else
			id = v.role.id
		end
		if id == chiefId then
			v.sortID = eFactionOwner
		elseif deputy[id] then
			v.sortID = eFactionSencondOwner
		elseif elder[id] then
			v.sortID = eFactionElder
		elseif elite[id] then
			v.sortID = eFactionElite
		else
			v.sortID = eFactionPeple
		end
		v.id = id
		if not v.role or not v.role.fightPower then
			v.role = {}
			v.role.fightPower = v.overview.fightPower
		end
		table.insert(tmp_info, v)
	end
	table.sort(tmp_info,function (a,b)
		if a.sortID ~= b.sortID then
			return a.sortID < b.sortID
		else
			return a.role.fightPower > b.role.fightPower
		end
	end)
	return tmp_info
end
--计算场景间距 
function get_take_photo_scene_size(count)
	local cfg  = i3k_db_get_faction_photo_pos_cfg(count)
	return math.max(cfg.maxRowCount,i3k_db_faction_photo.cfgBase.sceneSize)
end
--计算分辨率
function get_take_photo_width_height()
	local cfg = i3k_db_faction_photo.cfgBase.photoSize
	if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
		return cfg[1].photoHeight, cfg[1].photoWidth
	end
	local height = g_i3k_game_handler:GetViewHeight()
	for k, v in ipairs(cfg) do
		if v.photoHeight <= height then
			return v.photoHeight, v.photoWidth
		end
	end	
	return cfg[#cfg].photoHeight, cfg[#cfg].photoWidth
end
function getTitleIndex(swornValue)
	local index = 0
	for k, v in ipairs(i3k_db_sworn_value) do
		if swornValue < v.swornValue then
			break
		else
			index = k
		end
	end
	return index
end
--金兰成就进度条
function getBarPerc(destIndex, value)
	if not destIndex then 
		return 100
	else
		local dest = i3k_db_achi_point_reward[destIndex].objective
		local begin
		if destIndex == 1 then
			begin = 0
		else
			begin = i3k_db_achi_point_reward[destIndex - 1].objective
		end
		local factor = 100 / #i3k_db_achi_point_reward
		local perc = (destIndex - 1) * factor
		local locPerc = (value - begin) / (dest - begin)
		local perc = perc + factor * locPerc
		return perc
	end
end
--兑换购买道具性别检测
function i3k_db_prop_gender_qualify(id)
	if id == 0 or not id then return true end--不检测
	local cfg = i3k_db_get_other_item_cfg(id)
	if cfg then	
		if cfg.type == UseItemFashion or cfg.type == UseItemHeadPreview then
			return cfg.args2 == 0 and true or cfg.args2 == g_i3k_game_context:GetRoleGender()
		end
	end
	return true 
end
--end
function i3k_db_get_FSR_rewards(id)
	local t = g_i3k_game_context:GetRoleType()
	local cfg = i3k_db_ring_mission[id]
	local rwds = {}
	for _, v in pairs(cfg.rewards) do
		if v.id[1] > 0 then
			table.insert(rwds, {id = v.id[t], count = v.count})
		end
	end
	table.insert(rwds, {id = 1002, count = cfg.giveExp})
	return rwds
end
--江湖侠探获取成员列表
function i3k_db_get_detective_member_list(bossId)
	local members = {}
	if bossId and bossId ~= 0 then
		local difficulty = i3k_db_knightly_detective_ringleader[bossId].difficulty
		local groupId = i3k_db_knightly_detective_ringleader[bossId].groupId
		for k, v in pairs(i3k_db_knightly_detective_members) do
			if v.difficulty == difficulty and v.groupId == groupId then
				table.insert(members, k)
			end
		end
	end
	return members
end
function i3k_db_get_sort_detective_member(bossId)
	local members = i3k_db_get_detective_member_list(bossId)
	local memberClone = i3k_clone(members)
	--math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	math.randomseed(g_i3k_game_context:GetRoleId())
	for i = 1, #members do
		if i + 1 < #members then
			local num = math.random(i + 1, #members)
			memberClone[i], memberClone[num] = memberClone[num], memberClone[i]
		else
			if memberClone[i] == members[i] then
				local num = math.random(1, i - 1)
				memberClone[i], memberClone[num] = memberClone[num], memberClone[i]
			end
		end
	end
	return memberClone
end
function i3k_db_get_knightly_detective_task_cfg(taskId)
	return i3k_db_knightly_detective_tasks[taskId]
end
function i3k_db_check_item_haveCount_isShow(itemID)
	if math.abs(itemID) == g_BASE_ITEM_DIAMOND or math.abs(itemID) == g_BASE_ITEM_COIN then
		return false
	else
		return true
	end
end
--npc送信
function i3k_db_get_deliver_npc_index(id, value)
	local npcCfg = i3k_db_npc_deliver_letters[id]
	local result = i3k_db_get_table_by_shifting_value(value, #npcCfg.npcList)
	for k, v in ipairs(result) do
		if v == 0 then
			return k, npcCfg.npcList[k], npcCfg.dialogueList[k]
		end
	end
	return 1, npcCfg.npcList[1], npcCfg.dialogueList[1]
end
--符语铸锭判断加的经验可以升到多少级以及所剩经验
function i3k_db_FuYuZhuDing_CheckCanUpLevel(langId, curExp ,addExp, level)
	local curlevel = level
	local maxExp =  i3k_db_rune_zhuDing[langId][curlevel + 1].upNeedExp			 --获得下一等级所需经验
	local expOffset = curExp + addExp - maxExp 										 --得到当前溢出经验
	if expOffset >= 0 then      --如果触发升级
		curlevel = curlevel + 1     	 --等级+1
		if curlevel < #i3k_db_rune_zhuDing[langId] then	    	 --没有到满级，继续判定
			return i3k_db_FuYuZhuDing_CheckCanUpLevel(langId, 0, expOffset,curlevel)
		else 							 --满级则返回结果
			return curlevel, expOffset
		end
	else 							 --没有触发升级，返回结果	
		return curlevel, curExp + addExp
	end
end
--[[function i3k_db_get_deliver_npc_is_finish(id, value, npcId)
	local npcCfg = i3k_db_npc_deliver_letters[id]
	local result = i3k_db_get_table_by_shifting_value(value, #npcCfg.npcList)
	for k, v in ipairs(result) do
		if npcId == npcCfg.npcList[k] then
			return v == 1, k
		end
	end
	return false, nil
end--]]
function i3k_db_get_array_stone_level(experience)
	for k, v in ipairs(i3k_db_array_stone_level) do
		if experience < v.needExp then
			return k
		end
	end
	return #i3k_db_array_stone_level
end
--密文是否在某个言诀组里
function i3k_db_is_in_stone_suit_group(stoneId, groupId)
	local suitCfg = i3k_db_array_stone_suit[i3k_db_array_stone_suit_group[groupId].includeSuit[1]]
	if suitCfg.suitType == g_ARRAY_STONE_SUIT_SUFFIX then
		--后缀
		if table.indexof(suitCfg.needStoneType, i3k_db_array_stone_cfg[stoneId].suffixId) then
			return true
		end
	else
		--前缀
		if table.indexof(suitCfg.needStoneType, i3k_db_array_stone_cfg[stoneId].prefixId) then
			return true
		end
	end
	return false
end
--获取组合言诀类型中已达成数量，参数equips是密文id组成的数组
function i3k_db_get_combine_suit_count(equips, suitId)
	local suitCfg = i3k_db_array_stone_suit[suitId]
	local suitTable = {}
	for k, v in ipairs(suitCfg.needStoneType) do
		for i, j in ipairs(equips) do
			if j ~= 0 and i3k_db_array_stone_cfg[j].prefixId == v then
				suitTable[v] = true
				break
			end
		end
	end
	return table.nums(suitTable)
end
function i3k_db_get_is_finish_stone_suit(stoneList, suitId)
	local isFinish = false
	local count = #stoneList
	local suitCfg = i3k_db_array_stone_suit[suitId]
	if suitCfg.suitType == g_ARRAY_STONE_SUIT_COEXIST then
		if #stoneList >= suitCfg.minCount then
			isFinish = true
		end
	elseif suitCfg.suitType == g_ARRAY_STONE_SUIT_ONLY then
		if #stoneList == suitCfg.minCount then
			isFinish = true
		end
	elseif suitCfg.suitType == g_ARRAY_STONE_SUIT_COMBINE then
		count = i3k_db_get_combine_suit_count(stoneList, suitId)
		if count >= suitCfg.minCount then
			isFinish = true
		end
	elseif suitCfg.suitType == g_ARRAY_STONE_SUIT_SUFFIX then
		if #stoneList >= suitCfg.minCount then
			isFinish = true
		end
	end
	return isFinish, count
end
--取套装等级，只有满足套装条件才能调用这个方法
function i3k_db_get_stone_suit_level(stoneList, suitId)
	local suitCfg = i3k_db_array_stone_suit[suitId]
	if suitCfg.suitType == g_ARRAY_STONE_SUIT_COMBINE then
		local suitTable = {}
		for k, v in ipairs(suitCfg.needStoneType) do
			for i, j in ipairs(stoneList) do
				if i3k_db_array_stone_cfg[j].prefixId == v then
					if not suitTable[v] then
						suitTable[v] = 1
					end
					if i3k_db_array_stone_cfg[j].level > suitTable[v] then
						suitTable[v] = i3k_db_array_stone_cfg[j].level
					end
				end
			end
		end
		local level = i3k_db_array_stone_common.maxStoneLevel
		for k, v in pairs(suitTable) do
			if level > v then
				level = v
			end
		end
		return level
	else
		local levelTable = {}
		for k, v in ipairs(stoneList) do
			table.insert(levelTable, i3k_db_array_stone_cfg[v].level)
		end
		table.sort(levelTable, function (a, b)
			return a > b
		end)
		return levelTable[suitCfg.minCount]
	end
end
function i3k_db_get_array_stone_suit_desc(suitId, level)
	local suitCfg = i3k_db_array_stone_suit[suitId]
	local suitProp = {}
	for k, v in ipairs(suitCfg.additionProperty) do
		table.insert(suitProp, v.value[level] / 100)
	end
	for k, v in ipairs(suitCfg.suitProperty) do
		table.insert(suitProp, v.value[level])
	end
	return string.format(suitCfg.desc, suitProp[1], suitProp[2], suitProp[3], suitProp[4], suitProp[5], suitProp[6], suitProp[7], suitProp[8], suitProp[9], suitProp[10])
end
function i3k_db_get_array_stone_one_key_use_items(curExp, haveItems)
	table.sort(haveItems, function(a, b) return a.energy < b.energy end)
	local maxNeedExp = i3k_db_array_stone_level[#i3k_db_array_stone_level - 1].needExp - curExp
	local record = {}
	for i, v in ipairs(haveItems) do
		for ii = 1, v.count do
			if maxNeedExp > 0 then
				record[v.id] = record[v.id] and record[v.id] + 1 or 1
				maxNeedExp = maxNeedExp - v.energy
			else
				break
			end
		end
		if maxNeedExp <= 0 then break end
	end
	return record
end
--战区卡片日志
function i3k_db_get_war_zone_card_log_str(info)
	local cfg = i3k_db_war_zone_map_card
	local str = ""
	if info.event == g_WAR_ZONE_CARD_EVENT_TYPE_GET_MONSTERID then
		str = i3k_get_string(5746, g_i3k_db.i3k_db_get_monster_name(info.arg1))  --击败怪物获得
	elseif info.event == g_WAR_ZONE_CARD_EVENT_TYPE_GET_PLAYER then
		local zoneName = i3k_game_get_server_name_from_role_id(info.arg1)
		str = i3k_get_string(5796, zoneName == "unknow" and info.strArg1 or info.strArg1 .. "(" .. zoneName ..")" ) --击败玩家获得
	elseif info.event == g_WAR_ZONE_CARD_EVENT_TYPE_PLAYER then
		local zoneName = i3k_game_get_server_name_from_role_id(info.arg1)
		str = i3k_get_string(5797, zoneName == "unknow" and info.strArg1 or info.strArg1 .. "(" .. zoneName ..")" ) --击败玩家获得
	elseif info.event == g_WAR_ZONE_CARD_EVENT_TYPE_RECOVERY then
		str = i3k_get_string(5749) --系统回收
	elseif info.event == g_WAR_ZONE_CARD_EVENT_TYPE_PLAYER_MONSTERID then
		local zoneName = i3k_game_get_server_name_from_role_id(info.arg1)
		str = i3k_get_string(5798, zoneName == "unknow" and  info.strArg1 or info.strArg1 .. "(" .. zoneName .. ")" , g_i3k_db.i3k_db_get_monster_name(info.arg2))
	elseif info.event == g_WAR_ZONE_CARD_EVENT_TYPE_PLAYER_PLAYER then
		local zoneName1 = i3k_game_get_server_name_from_role_id(info.arg1)
		local zoneName2 = i3k_game_get_server_name_from_role_id(info.arg2)
		str = i3k_get_string(5799, zoneName1 == "unknow" and info.strArg1 or info.strArg1 .. "(" .. zoneName1 .. ")", zoneName2 == "unknow" and info.strArg2 or info.strArg2 .. "(" .. zoneName2 .. ")")	--玩家击败玩家获得
	end
	local grade = i3k_db_war_zone_map_cfg.cardGrade
	local  str1 = ""
	for k,v in ipairs(info.cards) do
		local cfg = i3k_db_war_zone_map_card[v]
		str1 = str1 .. ",".. i3k_get_string(grade[cfg.grade].logDesc) .. " " .. cfg.name
	end
	return isRollNotice and str .."|"..str1 or str .. str1
end
--个人卡红点
function i3k_db_get_war_zone_card_personal_red()
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	if table.nums(cardInfo.card.bag) == 0 then--or table.nums(cardInfo.card.inUse) >= i3k_db_war_zone_map_cfg.personalUseMax then
		return false 
	end
	for k,v in pairs(cardInfo.card.bag) do
		local cfg = i3k_db_war_zone_map_card[k]
		local times = cardInfo.card2DaySectDrawCount[k] or cardInfo.card2DayUseCount[k] or 0
		if times < cfg.dayUseTimes then
			if cfg.buffId == 0 then
				return true
			elseif table.nums(cardInfo.card.inUse) < i3k_db_war_zone_map_cfg.personalUseMax then
				local isMax = true
				for i,j in pairs(cardInfo.card.inUse) do
					local cfgInUse = i3k_db_war_zone_map_card[i]
					if cfg.mutexGroupId == cfgInUse.mutexGroupId and cfg.grade <= cfgInUse.grade then
						isMax = false
						break
					end
				end
				if isMax then return true end
			end
		end
	end
	return false
end
--buff卡是否可以用
function i3k_db_get_war_zone_card_buff_is_show(id)
	local cfg = i3k_db_war_zone_map_card[id]
	if cfg then
		local world = i3k_game_get_world()
		if world then
			for i,v in ipairs(cfg.invalidMap) do
				if world._cfg.id == v then
					return false
				end
			end
		end
	end
	return true
end
--buff卡效果描述
function i3k_db_get_war_zone_card_efect_desc(id)
	local cfg = i3k_db_war_zone_map_card[id]	
	local str = ""
	local effectInfo = {
		[g_WAR_ZONE_CARD_EFECT_TYPE_WEAPON] = {cfg = i3k_db_shen_bing, arg = "name"},
		[g_WAR_ZONE_CARD_EFECT_TYPE_DEVIL]	= {cfg = i3k_db_world_boss, arg = "monsterId", cfg2 = i3k_db_monsters, arg2 = "name"},
		[g_WAR_ZONE_CARD_EFECT_TYPE_PROP_ADD] = {cfg = i3k_db_prop_id, arg = "desc"},
	}
	local efectCfg = i3k_db_war_zone_map_efect[cfg.cardType]
	if cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_EXP then
		str = i3k_get_string(cfg.effectDesc, cfg.effectArg.arg1/100 .. "%")
	elseif cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_WEAPON or cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_DEVIL then
		if cfg.effectArg.arg1 == -1 then
			str = i3k_get_string(cfg.effectDesc, cfg.effectArg.arg2/100 .. "%")
		else
			local effectCur = effectInfo[cfg.cardType]
			local str1 = i3k_db.i3k_db_get_war_zone_card_efect_name_desc(cfg, effectCur)
			str = i3k_get_string(cfg.effectDesc, str1, cfg.effectArg.arg2/100 .. "%")
		end
	elseif cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_PROP_ADD then
		local effectCur = effectInfo[cfg.cardType]
		local str1 = i3k_db.i3k_db_get_war_zone_card_efect_name_desc(cfg, effectCur)
		local strTable = string.split(str1, ",")
		local str2 = ""
		if efectCfg and efectCfg[cfg.effectArg.arg1].values then 
			for i,v in ipairs(efectCfg[cfg.effectArg.arg1].values) do
				if efectCfg[cfg.effectArg.arg1].type[i] == 2 then 
					str2 = str2 .. i3k_get_string(5768, strTable[i], v/100 .."%") .. "\n"
				else
					str2 = str2 .. strTable[i]..":" .. v .."\n"
				end
			end
		end
		str = str2
	elseif cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_VIP_ADD then
		local roleVipLvl = g_i3k_game_context:GetVipLevel()
		local efectData = efectCfg[cfg.effectArg.arg1]
		local curIndex = i3k_db.i3k_db_get_card_effect_cur_index(efectData, roleVipLvl)
		if efectData.values[curIndex] == 0 then
			str = i3k_get_string(5763, roleVipLvl, efectData.type[curIndex])
		else
			str = i3k_get_string(5762, roleVipLvl, efectData.values[curIndex], efectData.type[curIndex])
		end
	elseif cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_OFFLINE_EXP then
		local roleLvl = g_i3k_game_context:GetLevel()
		local curIndex = 0
		local str1 = ""
		local str2 = ""
		if efectCfg and efectCfg[cfg.effectArg.arg1].idGroup then
			local efectData = efectCfg[cfg.effectArg.arg1]
			local lvls = efectData.idGroup
			for i,v in ipairs(lvls) do
			 	if v >= roleLvl then
			 		curIndex = i
			 		break
			 	end
			end 
			curIndex = curIndex == 0 and #lvls or curIndex
			local start = lvls[curIndex - 1] or 1 
			str1 = (start > 1 and start + 1 or 1) .. "-" .. lvls[curIndex]
			str2 = efectData.values[curIndex]
		end
		str = i3k_get_string(cfg.effectDesc, str1, str2)
	elseif cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_REWARD then
		str = i3k_get_string(cfg.effectDesc)
	end
	return str
end
function i3k_db_get_war_zone_card_efect_name_desc(cardCfg, cfgInfo)
	local efectAgrs = i3k_db_war_zone_map_efect[cardCfg.cardType]
	local str1 = ""
	if efectAgrs and efectAgrs[cardCfg.effectArg.arg1] and efectAgrs[cardCfg.effectArg.arg1].idGroup then
		for i,v in ipairs(efectAgrs[cardCfg.effectArg.arg1].idGroup) do
			local values = cfgInfo.cfg[v]
			if values then
				if cfgInfo.cfg1 then
					values =  cfgInfo.cfg1[cfgInfo.arg]
					if values then
						str1 = str1 .. values[cfgInfo.arg1] .. ","
					end
				else
					str1 = str1 .. values[cfgInfo.arg] .. ","
				end
			end
		end
	end
	return str1
end
function i3k_db_get_fightTeam_group_name(id)
	local db = i3k_db_fightTeam_group_name
	return db[id].name
end
-- 根据 tournament_teamgroup_sync_res 的数据结构修改，封装一个函数
function i3k_db_trans_teamgroup(res, id)
	if id == g_FIGHT_TEAM_WUHUANG then
		return {
			groups = res.kingGroups,
			finalGroup = res.kingGinalGroup
		}
	elseif id == g_FIGHT_TEAM_WUDI then
		return {
			groups = res.emperorGroups,
			finalGroup = res.emperorFinalGroup
		}
	end
end
function i3k_db_get_war_zone_card_grade_count(grade)
	local cfgCount = 0
	local bagCount = 0
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	local bag = cardInfo.card.bag
	for k,v in pairs(i3k_db_war_zone_map_card) do
		if v.grade == grade then
			if bag[k] then
				bagCount = bagCount + 1
			end
			cfgCount = cfgCount + 1
		end
	end
	return string.format("(%d/%d)", bagCount, cfgCount)
end
function i3k_db_get_card_tip(id)
	local cfg = i3k_db_war_zone_map_card[id]
	local efectAgrs = i3k_db_war_zone_map_efect[cfg.cardType]
	local str = ""
	if cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_VIP_ADD then
		local roleVipLvl = g_i3k_game_context:GetVipLevel()
		local efectData = efectAgrs[cfg.effectArg.arg1]
		local curIndex = i3k_db.i3k_db_get_card_effect_cur_index(efectData, roleVipLvl)
		if efectData.values[curIndex] == 0 then
			str = i3k_get_string(5598, efectData.type[curIndex])
		else
			str = i3k_get_string(5597, efectData.values[curIndex], efectData.type[curIndex])
		end
	elseif cfg.cardType == g_WAR_ZONE_CARD_EFECT_TYPE_OFFLINE_EXP then
		local roleLvl = g_i3k_game_context:GetLevel()
		local efectData = efectAgrs[cfg.effectArg.arg1]
		local curIndex = i3k_db.i3k_db_get_card_effect_cur_index(efectData, roleLvl)
		str = i3k_get_string(5604, efectData.values[curIndex])
	else
		str = i3k_get_string(5729)
	end
	return str
end
function i3k_db_get_card_effect_cur_index(effectData, curlevel)
	local curIndex = 0
	local lvls = effectData.idGroup
	for i,v in ipairs(lvls) do
	 	if v >= curlevel then
	 		curIndex = i
	 		break
	 	end
	end
	return curIndex == 0 and #lvls or curIndex
end
--------------------万寿阁---------------------------
function i3k_db_get_longevity_pavilion_reward(rank, cfg)
	for _, v in ipairs(cfg) do
		if v.rank == rank then
			return v.reward
		end
	end
end
function i3k_db_get_longevity_pavilion_task_cfg()
	local mapId = g_i3k_game_context:GetWorldMapID()
	return i3k_db_longevity_pavilion_dugeon[mapId]
end
function i3k_db_get_longevity_pavilion_lvl()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_longevity_pavilion.lvlStage
	for i,v in ipairs(cfg) do
		if v.mapId == mapId then
			return v.level
		end
	end
end
function i3k_db_get_longevity_pavilion_mapId()
	local heroLvl = g_i3k_game_context:GetLevel()
	local cfg = i3k_db_longevity_pavilion.lvlStage
	local curMap = cfg[#cfg].mapId
	for i,v in ipairs(cfg) do
		if v.level >= heroLvl then
			return v.mapId
		end
	end
	return curMap
end
function i3k_db_get_longevity_pavilion_battle_desc(stage)
	local desc = {
		[2] = 18565,
		[3] = 18566,
		--[3] = 18567, --第三阶段有参数
	}
	return i3k_get_string(desc[stage])
end
function i3k_db_longevity_pavilion_boss_desc_tip()
	local battleInfo = g_i3k_game_context:getLongevityPavilionBattleInfo()
	if battleInfo.stage == 3 then
		local cfg = g_i3k_db.i3k_db_get_longevity_pavilion_task_cfg()
		local tips = nil
		for k,v in pairs(cfg[battleInfo.stage].taskGroup) do
			if battleInfo.task[v] then
				if not tips then
					local taskCfg = i3k_db_longevity_pavilion_task[v]
					local name = i3k_db_monsters[taskCfg.arg1].name
					tips = i3k_get_string(18567, name)
				else
					tips = nil
				end
			end
		end
		return tips
	end
end
------------获取屏蔽检测范围
function i3k_db_get_detection_block_range(cfg)
	local isDetectionBlock = cfg and cfg.isDetectionBlock == 1  --1不检测阻挡
	return isDetectionBlock and 0 --  检测范围设置
end
-----------密探风云------------------------------------------
--获取密探风云模型
function i3k_db_get_spy_story_modelID(gender, cfg)
	if gender == 1 then
		return cfg.modelNanID
	else
		return cfg.modelNvID
	end
end

--获取密探风云对话数据
function i3k_db_get_spy_dialogue_npc_data(id)
	local mapType = i3k_game_get_map_type()
	if mapType == g_SPY_STORY then
		local data = g_i3k_game_context:getSpyDialogueNpcData()
		if data then
			return data.npcId == id and data
		end
	end
	return false
end

function i3k_db_get_activity_add_times_cfg()
	if g_COMMON_ITEM_ADD_ACTIVITY_TIMES_ID then
		return i3k_db_new_item[g_COMMON_ITEM_ADD_ACTIVITY_TIMES_ID]
	else
		for k,v in pairs(i3k_db_new_item) do
			if v.type == g_COMMON_ITEM_TYPE_ADD_ACTIVITY_TIMES then
				g_COMMON_ITEM_ADD_ACTIVITY_TIMES_ID = v.id
				return v
			end
		end
	end
end

function i3k_db_check_now_activity_is_open()
	local t = os.date("*t", g_i3k_get_GMTtime(i3k_game_get_time()))
	local dbTime = i3k_db_activity[1].openTime
	local openTime = string.sub(dbTime, 1, #dbTime - 3)
	local hour = tonumber(string.sub(openTime, 1, #openTime - 3))
	local min = tonumber(string.sub(openTime, #openTime - 1, #openTime))
	if t.hour == hour then
		if t.min < min then
			return false
		end
	end
	return true
end

--返回地图中npc信息列表
function i3k_db_get_npc_list_info(mapId)
	local Npcs = i3k_db_dungeon_base[mapId].npcs
	if #Npcs > 0 then
		return i3k_db_sortRightNpcList(Npcs)
	end
	return nil
end

--返回地图中怪物信息列表
function i3k_db_get_monsters_list_info(mapId)
	local haveMonsterArea = i3k_db_dungeon_base[mapId].areas
	if #haveMonsterArea > 0 then
		return i3k_db_get_monsters(haveMonsterArea)
	end
	return nil
end

--返回地图中特殊怪物信息列表，邪灵怪
function i3k_db_get_specal_monsters_list_info(mapId)
	local worlMpaID = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_war_zone_map_fb[worlMpaID]
	if cfg and #cfg.monstersID > 0 then
		return cfg.monstersID
	end
	return nil
end


function i3k_db_sortRightNpcList(list)
	local tableFirst = {}
	local tableSecond = {}
	for i, v in ipairs(list) do
		local npc = i3k_db_npc[i3k_db_npc_area[v].NPCID]
		local desc = g_i3k_db.i3k_db_get_npc_list_function(npc.ID)
		if desc ~= "" then
			table.insert(tableFirst, v)
		else
			table.insert(tableSecond, v)
		end
	end
	table.sort(tableFirst, function(a, b)
		return a < b
	end)
	table.sort(tableSecond, function(a, b)
		return a < b
	end)
	for i, v in ipairs(tableSecond) do
		table.insert(tableFirst, v)
	end
	return tableFirst
end
--------------背包提示-------------------------------
function i3k_db_get_is_bag_auto_sale_tips()
	local Cfg = i3k_db_common.bagAutoSaleTips
	local heroLvl = g_i3k_game_context:GetLevel()
	if heroLvl < Cfg.level then
		return false
	end
	if g_i3k_game_context:getBagAutoSaleEquipTips() then
		return false
	end
	local cfg = g_i3k_game_context:GetUserCfg()
	if cfg:GetAutoSaleEquip() then 
		return false
	end
	local count = g_i3k_game_context:GetBagSize() - g_i3k_game_context:GetBagUseCell()
	if count > Cfg.count then
		return false
	end
	return true
end
function i3k_db_get_treasure_num()
	return table.nums(i3k_db_treasure)
end
-- 获取切磋赛需要替换模型
function i3k_db_get_dual_meet_replace_model()
	local mapType = i3k_game_get_map_type()
	if mapType == g_COMPETITION then
		local mapID = g_i3k_game_context:GetWorldMapID()
		local cfg = i3k_db_dual_meet.mapCfg[mapID]
		return cfg.moduleID == 1
	end
	return false
end
-- 获取切磋赛替换模型
function i3k_db_get_dual_meet_model_id(classType, gender, campType)
	local cfg = i3k_db_dual_meet.campCfg
	return cfg[gender][campType][classType]
end
function i3k_db_get_competition_mapID_form_num(num)
	local cfg = i3k_db_dual_meet.gameMapScale
	return cfg[num]
end
-- 获取地图是否设置特效等级
function i3k_get_map_default_effect_lvl()
	local mapID = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_dungeon_base[mapID]
	return cfg.effectLvl
end
function i3k_db_get_gift_bag_items(itemID)
	local cfg = i3k_db_get_other_item_cfg(itemID)
	if cfg and cfg.type == UseItemGift then
		local args1 = cfg.args1
		local giftbagCfg = i3k_db_gift_bag[args1]
		if giftbagCfg then 
			local items = giftbagCfg.giftInfo
			return items
		end
	end
	return
end
-- 检查类型为7的道具，使用时候跳转是否为14，根据这一条件来判断是否是这个类型的
function i3k_db_check_item_use_as_weapon(itemID)
	local weaponID = g_i3k_db.i3k_db_get_weapon_id_use_item(itemID)
	return weaponID
end
function i3k_db_get_weapon_id_use_item(itemID)
	for k, v in ipairs(i3k_db_shen_bing)do
		if v.itemid == itemID then
			return v.id
		end
	end
end
function i3k_db_get_heirloom_spirit_value(level)
	local cfg = i3k_db_heirloom_spirit_level[level]
	local nextCfg = i3k_db_heirloom_spirit_level[level + 1]
	local otherProps =
	{
		{name = i3k_get_string(18971), keyWord = "talentPoints", value = 0, nextValue = 0, icon = 10317},
		{name = i3k_get_string(18972), keyWord = "recoverRate", value = 0, nextValue = 0, icon = 10318},
		{name = i3k_get_string(18973), keyWord = "energyMax", value = 0, nextValue = 0, icon = 10319},
	}
	for k, v in ipairs(otherProps) do
		v.value = cfg[v.keyWord]
		if nextCfg then
			v.nextValue = nextCfg[v.keyWord]
		end
	end
	return otherProps
end
--计算一键恢复血量需要用那些药品
function i3k_db_getprops_addhpfull(item_tab, differenceNum, now_HPIncrease)
	local useTab = {}
	for _, v in ipairs(item_tab) do
		local increaseHP = v.cfgHp * (1 + now_HPIncrease)
		local num = differenceNum > v.count * increaseHP and v.count or math.floor(differenceNum / increaseHP)
		differenceNum = differenceNum - increaseHP * num
		table.insert(useTab, {id = v.id, count = num})
	end
	return useTab, differenceNum
end

-----------新节日活动-------------------=======

-- 新节日任务也跟上面类似，搞一下，从30101开始
-- 其中 groupID 和 id 都是在（0, 100)范围内, 最小值101(1,1)，最大值9999(99,99)
-- 再加上30000，不会和上面的千位冲突，故最终的范围为(30101, 39999)
function i3k_db_get_new_festival_task_hash_id(id)
	local hashID = id + 30000
	if not g_i3k_db.i3k_db_check_new_festival_task_by_hash_id(hashID) then
		error("not in range, group:"..groupID.." id:"..id)
	end
	return hashID
end
function i3k_db_check_new_festival_task_by_hash_id(hashID)
	-- return 30000 + 1 * 100 + 1 <= hashID and hashID <= 30000 + 99 * 100 + 99
	return 30000 < hashID and hashID < 40000
end

function i3k_db_new_festival_task_groupID(npcId)
	local taskGroupID = nil
	for k, v in ipairs(i3k_db_new_festival_npc) do
		if npcId == v.npcId then
			taskGroupID = v.taskGoroupId
			break
		end
	end
	assert(taskGroupID ~= nil, "npc:"..npcId.." 对应的任务分组id没找到,请检查 势力声望表.xlsx")
	return taskGroupID
	
end

-- 根据npcid，获取对应的任务库分组，再根据同步的信息，获取对应任务库的配置
function i3k_db_new_festival_get_taskCfg_by_npcid(npcID)
	local info = g_i3k_game_context:getNewFestival_task(npcID)
	local cfg = i3k_db_new_festival_task[info.id]
	return cfg
end

-- 根据npcid，获取对应的任务（如果为空，则配置的有问题）
function i3k_db_new_festival_get_type_by_npcid(npcID)
	for k, v in ipairs(i3k_db_power_reputation_npc) do
		if v.npcID == npcID  then
			return v.powerSide
		end
	end
	error("npc power side not found:"..npcID)
	return nil
end


--是否在新节日活动时间内
function i3k_db_is_in_new_festival_task(id)
	local info = i3k_db_new_festival_info
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	return timeStamp >= info.openData and timeStamp <= info.closeData
end

--
function i3k_db_new_festival_get_taskCfg_by_hash(hash)
	local id = g_i3k_db.i3k_db_get_new_festival_task_real_id(hash)
	local taskCfg = i3k_db_new_festival_task[id]
	return taskCfg
end

function i3k_db_get_new_festival_task_real_id(hashID)
	-- return 30000 + 1 * 100 + 1 <= hashID and hashID <= 30000 + 99 * 100 + 99
	return hashID - 30000
end
function i3k_db_task_info_convert_db(TaskCfg)
	local cfg = {type = TaskCfg.taskConditionType, arg1 = TaskCfg.args[1], arg2 = TaskCfg.args[2],
		arg3 = TaskCfg.args[3], arg4 = TaskCfg.args[4], arg5 = TaskCfg.args[5], finishTaskDesc = "0.0", id = TaskCfg.id } -- 重新组织下数据结构
	return cfg
end

function i3k_db_get_new_festival_task_finish_desc(cfg)
	local talk = {}
	local model = {}
	local talks = i3k_db_new_festival_task[cfg.id].talks
	for i=1,#talks do
		local finishTaskDialogue = i3k_db_dialogue[talks[i].stringId] and i3k_db_dialogue[talks[i].stringId][1] or {}
		local modelid = talks[i].modeId
		if finishTaskDialogue ~= "0.0" then
			table.insert(talk,finishTaskDialogue)
		end
		if modelid then 
			table.insert(model,modelid) 
		end

	end
	return talk, model
end

--npc是否在显示时间内
function i3k_db_get_npc_is_show(npcId)
	local npcCfg = i3k_db_npc[npcId]
	return g_i3k_db.i3k_db_check_npc_show_time(npcCfg)
end

function i3k_db_check_npc_show_time(npcCfg)
	if npcCfg.showTime and npcCfg.showTime > 0 then
		local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
		return npcCfg.showTime<= timeStamp and timeStamp <= npcCfg.hideTime
	end
	return true
end
-----------新节日活动  END -------------------

-------------鼠年纪念金币---------------
function i3k_db_get_JNBbox_state(index, holdReward, takeReward)
	local canTake = false	--能否领取
	local isTaked = false	--是否已领取
	if holdReward[index] then
		canTake = true
	end
	if takeReward[index] then
		isTaked = true
	end
	if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_commecoin_cfg.buyConfig.getPropId) >= i3k_db_commecoin_addValueNode[index].needCoinNums then
		if g_i3k_get_GMTtime(i3k_game_get_time()) >= i3k_db_commecoin_addValueNode[index].addValueTimeNode then
			canTake = true
		end
	end
	return canTake, isTaked
end
function i3k_db_get_JdtPercent_prop(indexx)
	local defaultValue = i3k_db_commecoin_cfg.exchangeConfig.unitChangeScale
	local prop = (i3k_db_commecoin_addValueNode[indexx].scaleValue - defaultValue)/(i3k_db_commecoin_cfg.exchangeConfig.maxScaleValue - defaultValue)
	return prop
end
--判断消耗纪念币后是否有可能错过宝箱
function i3k_db_isMissBox_UseCoin(num)
	local nowTime = g_i3k_get_GMTtime(i3k_game_get_time())
	local jnbCount = g_i3k_game_context:GetBagItemCount(i3k_db_commecoin_cfg.buyConfig.getPropId)
	local indexjd = -1
	for k, v in ipairs(i3k_db_commecoin_addValueNode) do
		if v.isHadBox == 1 and nowTime < v.addValueTimeNode then
			if jnbCount >= v.needCoinNums and jnbCount - num < v.needCoinNums then
				if indexjd == -1 or i3k_db_commecoin_addValueNode[indexjd].needCoinNums < v.needCoinNums then
					indexjd = k
				end
			end
		end
	end
	return indexjd
end
--得到当前纪念币兑换的比例节点
function i3k_db_getCoin_changeScale()
	local nowtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local count = #i3k_db_commecoin_addValueNode
	for i = 2, count do
		if nowtime < i3k_db_commecoin_addValueNode[i].addValueTimeNode then
			return i - 1
		end
	end
	return count
end
