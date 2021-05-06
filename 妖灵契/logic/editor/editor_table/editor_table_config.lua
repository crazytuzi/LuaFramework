module(..., package.seeall)

select =
{
	bool_type = {
		{true, "是"},
		{false, "否"},
		{nil, "无"}
	},
	effect_type = {
		{"dlg", "对话框"},
		{"texture", "图片"},
		{"focus_ui", "高光按钮"},
		{"focus_pos", "高光位置"},
		{"click_ui", "提示点击按钮"},
		{"teach_guide", "教学界面"},
		{"focus_common", "高光通用"},
		{"open", "开启"},
		{"spine", "spine模式"},
		{"none", "空处理"},
		{"hide_click_event", "隐藏点击区域"},
		{"bigdlg", "大对话框模式"},
		{"textdlg", "纯文本对话框模式"},

	},
	ui_key = {
		{"", "不设置"},
		{"mainmenu_operate_btn", "主界面操作按钮"},
		{"mainmenu_house_btn", "主界面宅邸按钮"},
		{"operate_drawcard_btn", "招募按钮"},
		{"operate_arena_btn", "比武场按钮"},		
		{"operate_map_book_btn", "图鉴按钮"},	
		{"operate_pata_btn", "地牢按钮"},		
		{"operate_org_btn", "公会按钮"},	
		{"operate_welfare_btn", "福利按钮"},							
		{"operate_skill_btn", "技能按钮"},	
		{"operate_arnea_btn", "竞技按钮"},									
		{"draw_wl_card", "武灵卡牌"},
		{"draw_wh_card", "武魂卡牌"},
		{"draw_wh_card_again", "武魂卡牌确认按钮"},
		{"drawcard_close_rt", "抽卡主界面关闭按钮右上"},
		{"drawcard_close_lb", "抽卡主界面关闭按钮左下"},
		{"close_wh_result_rt", "王者抽卡结果界面关闭按钮右上"},
		{"close_wh_result_lb", "王者抽卡结果界面关闭按钮左下"},
		{"war_order_all",  "指令完成按钮"},
		{"close_wl_result_rt", "勇者关闭抽取结果右上"},
		{"close_wl_result_lb", "勇者关闭抽取结果左下"},
		{"skill_point_label", "技能点文字"},
		{"skill_switch_btn", "切换流派按钮"},
		{"skill_learn_btn", "学习技能按钮"},
		{"skill_des_other_label", "技能其他描述文本"},	
		{"skill_skillbtn_1", "技能界面技能1按钮"},
		{"skill_skillbtn_2", "技能界面技能2按钮"},
		{"skill_skillbtn_3", "技能界面技能3按钮"},
		{"skill_skillbtn_4", "技能界面技能4按钮"},
		{"skill_skillbtn_5", "技能界面技能5按钮"},
		{"skill_skillbtn_6", "技能界面技能6按钮"},
		{"yuejian_help_btn", "月见帮助按钮"},
		{"pata_monster_texture", "地牢怪物模型"},
		{"arena_help_btn", "竞技场帮助按钮"},
		{"arena_fight_btn", "竞技场战斗按钮"},		
		{"confirm_ok_btn", "确认按钮"},
		{"confirm_cancel_btn", "取消按钮"},
		{"mainmenu_schedule_btn", "主界面日程按钮"},
		{"mainmenu_powerguide_btn", "主界面游戏精灵按钮"},
		{"mainmenu_anlei_btn", "主界面暗雷按钮"},
		{"mainmenu_dailycultivate_btn", "主界面每日修行按钮"},
		{"mainmenu_loginreward_btn", "主界面7日登陆"},		
		{"mainmenu_partner_btn", "主界伙伴按钮"},	
		{"mainmenu_xmqq_task_nv_btn", "主界面小萌请求任务导航按钮"},
		{"mainmenu_minimap_btn", "主界面地图按钮"},
		{"mainmenu_drawcard_btn", "主界面抽卡按钮"},		
		{"mainmenu_forge_btn", "主界面装备按钮"},
		{"mainmenu_hunt_btn", "主界面猎魂按钮"},
		{"partner_upgrade_list_1_1_partner_btn", "伙伴界面培育伙伴列表1-1格子"},			
		{"partner_upgrade_add_partner_btn", "伙伴界面培育添加伙伴按钮"},	
		{"partner_upgrade_ok_btn", "伙伴界面培育确定按钮"},	
		{"partner_upgrade_close_btn", "伙伴界面培育关闭按钮"},	
		{"partner_main_breed_btn", "伙伴界面伙伴培育按钮"},	
		{"partner_equip_tab_btn", "伙伴界面伙伴符文标签"},	
		{"partner_lineup_tab_btn", "伙伴界面伙伴上阵标签"},
		{"partner_yuling_tab_btn", "伙伴界面伙伴御灵标签"},
		{"partner_lineup_pos_2_btn", "伙伴上阵位置3按钮"},	
		{"partner_lineup_pos_3_btn", "伙伴上阵位置3按钮"},	
		{"partner_lineup_pos_4_btn", "伙伴上阵位置4按钮"},	
		{"partner_equip_box_add_1", "伙伴符文界面1号符文格子添加按钮"},	
		{"partner_equip_box_item_1", "伙伴符文界面1号符文格子符文按钮"},	
		{"partner_equip_change_type_btn", "伙伴符文类型切换"},
		{"partner_equip_list_1_1_fuwen_btn", "伙伴符文列表第一个符文"},
		{"partner_equip_strong_1_1_fuwen_btn", "伙伴符文强化列表第一个符文"},
		{"partner_equip_strong_ok_btn", "伙伴符文强化确定按钮"},
		{"partner_equip_rightpage_btn", "伙伴符文界面右侧翻页按钮"},
		{"partner_equip_type_label", "伙伴符文界面套装符文描述文本"},
		{"partner_equip_replace_btn", "伙伴符文tips界面替换按钮"},
		{"partner_equip_strong_btn", "伙伴符文tips界面强化按钮"},
		{"partner_cost_buy_fuwen_btn", "购买界面符文购买按钮"},
		{"partner_equip_buy_fuwen_btn", "伙伴符文购买按钮"},
		{"partner_equip_1_1_fuwen_btn", "伙伴符文列表1_1位置符文按钮"},
		{"partner_equip_left_pos_1_add_btn", "伙伴符文1，左侧添加按钮"},
		{"partner_equip_left_pos_1_fuwen_btn", "伙伴符文1，左侧符文按钮"},
		{"partner_equip_left_pos_1_add_btn", "伙伴符文2，左侧添加按钮"},
		{"partner_equip_left_pos_1_fuwen_btn", "伙伴符文2，左侧符文按钮"},
		{"partner_equip_strong_page_upgrade", "伙伴符文强化界面，强化按钮"},
		{"partner_draw_partner_1_1_btn", "招募界面1-1格子"},
		{"partner_draw_partner_confirm_btn", "招募界面 招募按钮"},
		{"partner_draw_partner_close_btn", "招募界面 关闭按钮"},
		{"partner_left_list_501_partner", "伙伴主界面 阿坊伙伴按钮"},
		{"partner_soul_type_1_fast_bg", "伙伴御灵界面 类型第一个背景"},
		{"partner_soul_type_1_box_btn", "伙伴御灵界面 类型第一个按钮"},
		{"partner_soul_type_1_fast_equip_btn", "伙伴御灵界面 类型第一个快速装备按钮"},
		{"partner_chip_compose_show_btn", "伙伴合成入口"},
		{"partner_chip_compose_tips_btn", "伙伴提示合成"},
		{"partner_choose_partner_403", "伙伴选择界面蛇姬伙伴"},		
		{"partner_choose_partner_301", "伙伴选择界面祁连伙伴"},		
		{"partner_choose_partner_501", "伙伴选择界面阿坊伙伴"},	
		{"partner_choose_partner_502", "伙伴选择界面马面面伙伴"},	
		{"partner_gain_close_btn", "伙伴获得界面 关闭按钮"},	
		{"schedule_award_box_1_btn", "冒险活跃度奖励1"},	
		{"schedule_allday_go_btn", "日常全天活动前往按钮"},		
		{"war_first_speed_box", "第一个行动头像"},
		{"war_two_speed_box", "第二个行动头像"},
		{"yuejian_monster_2", "月见第二个模型"},
		{"task_nv_btn", "任务导航"},
		{"hunt_partner_soul_1_1_btn", "猎魂 列表1_1 按钮"},
		{"hunt_partner_soul_list_1_btn", "猎魂 选择猎魂按钮"},		
		{"house_touch_btn", "宅邸抚摸按钮"},
		{"house_back_btn", "宅邸返回按钮"},			
		{"house_main_door_btn", "宅邸厨房入口"},	
		{"house_cooker_idx_1_btn", "宅邸厨师1按钮"},	
		{"house_cooker_work_1_btn", "宅邸厨师1工作按钮"},	
		{"house_cooker_back_btn", "宅邸厨房返回按钮"},	
		{"house_main_buff_btn", "宅邸buff按钮"},	
		{"house_main_buff_sprite", "宅邸buff提示背景"},	
		{"schedule_everydya_reward_label", "日常每日必做奖励文字"},	
		{"war_auto_skill_box1", "自动战斗技能按钮1"},
		{"war_auto_skill_box2", "自动战斗技能按钮2"},
		{"war_auto_skill_box3", "自动战斗技能按钮3"},
		{"war_auto_skill_box4", "自动战斗技能按钮4"},
		{"war_auto_skill_box5", "自动战斗技能按钮5"},
		{"war_select_auto_skill_box1", "自动战斗选择技能按钮1"},
		{"war_select_auto_skill_box2", "自动战斗选择技能按钮2"},
		{"war_replace_btn", "战斗加速按钮"},
		{"war_speed_btn", "战斗替换伙伴按钮"},
		{"war_speed_tips_bg", "战斗速度进度背景"},
		{"war_fore_bg_sprite", "战斗火焰背景"},
		{"map_world_map_btn", "地图界面切换世界地图按钮"},
		{"map_world_map_city_2_btn", "世界地图城市2按钮"},
		{"mapbook_partner_box", "图鉴伙伴入口"},
		{"mapbook_main_close_lb", "图鉴主界面返回左下"},
		{"mapbook_world_box", "图鉴世界之源入口"},
		{"mapbook_world_city_1_btn", "图鉴世界地图城市1按钮"},
		{"mapbook_world_city_award_btn", "图鉴世界地图城市奖励按钮"},	
		{"mapbook_world_main_close", "图鉴世界地图返回按钮"},	
		{"mapbook_world_main_city_close", "图鉴世界地图城市返回按钮"},		
		{"mapbook_partner_Photo_tab", "图鉴伙伴传记标签入口"},
		{"mapbook_partner_photo_1", "图鉴伙伴重华入口"},		
		{"mapbook_person_1007_reward_btn", "图鉴人物李铁蛋奖励按钮"},		
		{"mapbook_reward_view_1007_go_btn     ", "图鉴奖励提示界面前往按钮"},		
		{"pefunben_start_btn", "异空流放开始按钮"},
		{"linlianview_go_btn", "历练界面一键发车按钮"},
		{"mainmenu_team_btn", "主界面组队按钮"},
		{"teammain_handybuild_btn", "组队界面快捷组队按钮"},
		{"teamhandybuild_target_btn", "便捷组队组队目标按钮"},
		{"teamtarget_minglei_btn", "组队目标明雷按钮"},	
		{"chapter_fuben_btn_1", "剧情副本第一章"},	
		{"chapter_fuben_btn_2", "剧情副本第二章"},	
		{"chapter_fuben_btn_3", "剧情副本第三章"},	
		{"chapter_fuben_reward_btn_3", "剧情副本奖励3按钮"},	
		{"chapter_fuben_fight_btn", "剧情副本挑战按钮"},	
		{"forge_strength_fast_strength_btn", "装备强化一键强化按钮"},
		{"forge_gem_fast_mix_btn", "装备宝石一键融合按钮"},	
		{"forge_equip_pos_1", "装备装备部位1按钮"},	
		{"convoy_refresh_btn", "运镖刷新按钮"},	
		{"convoy_start_btn", "运镖开始按钮"},	
		{"equipfuben_auto_btn", "装备副本自动副本按钮"},			
		{"quickusew_use_btn", "快捷使用界面使用按钮"},
		{"dialogue_right_btn_1", "任务对话界面右侧第一个按钮"},
		{"mainmenu_nv_task_10003_btn", "任务列表 10003 任务按钮"},
	},
	condition = {
		{"", "不设置"},
		{"drawcard_main_show", "抽卡主界面"},
		{"drawcard_result_show", "抽卡结果界面"},
		{"teach_view_show", "教学界面开启"},
		{"teach_view_hide", "教学界面关闭"},
		{"house_view_show", "宅邸界面显示"},
		{"operate_view_show", "操作按钮界面显示"},
	},
	cmd_name ={
		{"Skill", "法术(施法id-受击id列表-法术id—法术编号)"},
		{"Damage", "伤害(id-暴击(1是0否)-伤害"},
		{"Chat", "说话(id-内容)"},
		{"Wait", "等待(等待时间)"},
		{"GoBack", "归位(id)"},
		{"WarriorStatus", "战士状态(id-存活{1是2否})"},
		{"BoutStart", "回合开始(回合数)"},
		{"BoutEnd", "回合结束(回合数)"},
	}
}

select_func = 
{
	texture_name = function() 
		local list = IOTools.GetFiles(IOTools.GetGameResPath("/Texture/Guide"), "*.png", true)
		local newList = {}
		for i, sPath in ipairs(list) do
			table.insert(newList, IOTools.GetFileName(sPath, false))
		end
		table.sort(newList)
		return newList
	end,
	ui_effect = function()
		return {"", "Finger","Finger1","Finger2", "Rect"}
	end,
	dlg_sprite = function()
		return {"pic_zhiying_ditu_1", "pic_zhiying_ditu_2"}
	end,
	dlg_tips_sprite = function ()
		return {"guide_3",}
	end,
	guide_voice_list_1 = function ()
	return {
			"guide_mxm_001_0",
			"guide_mxm_003_3",
			"house_mxm_001_1",
			"house_mxm_001_2",
			"house_mxm_001_3",
			"house_mxm_002_1",
			"house_mxm_002_2",
			"house_mxm_002_3",
			"house_mxm_003_1",
			"house_mxm_003_2",
			"house_mxm_004_1",
			"guide_mxm_001_1",
			"house_mxm_004_2",
			"house_mxm_005_1",
			"house_mxm_005_2",
			"house_mxm_006_1",
			"house_mxm_006_2",
			"house_mxm_007_1",
			"house_mxm_007_2",
			"house_mxm_008_1",
			"house_mxm_008_2",
			"house_mxm_009_1",
			"guide_mxm_001_2",
			"house_mxm_009_2",
			"house_mxm_010_1",
			"house_mxm_010_2",
			"guide_mxm_001_3",
			"guide_mxm_001_4",
			"guide_mxm_002_0",
			"guide_mxm_002_1",
			"guide_mxm_003_1",
			"guide_mxm_003_2",
			"guide_mxm_002_2",
			"guide_mxm_002_3",
			"guide_mxm_003_4",			
		}
	end,
	guide_voice_list_2 = function ()
	return {
			"guide_mxm_001_0",
			"guide_mxm_003_3",
			"house_mxm_001_1",
			"house_mxm_001_2",
			"house_mxm_001_3",
			"house_mxm_002_1",
			"house_mxm_002_2",
			"house_mxm_002_3",
			"house_mxm_003_1",
			"house_mxm_003_2",
			"house_mxm_004_1",
			"guide_mxm_001_1",
			"house_mxm_004_2",
			"house_mxm_005_1",
			"house_mxm_005_2",
			"house_mxm_006_1",
			"house_mxm_006_2",
			"house_mxm_007_1",
			"house_mxm_007_2",
			"house_mxm_008_1",
			"house_mxm_008_2",
			"house_mxm_009_1",
			"guide_mxm_001_2",
			"house_mxm_009_2",
			"house_mxm_010_1",
			"house_mxm_010_2",
			"guide_mxm_001_3",
			"guide_mxm_001_4",
			"guide_mxm_002_0",
			"guide_mxm_002_1",
			"guide_mxm_003_1",
			"guide_mxm_003_2",
			"guide_mxm_002_2",
			"guide_mxm_002_3",
			"guide_mxm_003_4",
		}
	end,	
	spine_left_shape = function ()
		return {" ", "1752"}
	end	,
	spine_right_shape = function ()
		return {" ", "1752"}
	end	,	
	spine_left_motion = function ()
		return {"chashou", "dazhaohu", "jushou", "idle"}
	end	,	
	spine_right_motion = function ()
		return {"chashou", "dazhaohu", "jushou", "idle"}
	end	,	
}

arg = {}
arg.template = {
	sel_type = {
		key = "sel_type",
		name = "主类型",
		select_update = function ()
			local list = {}
			for k, v in pairs(data_config) do
				table.insert(list, k)
			end
			table.sort(list)
			return list
		end,
		wrap  = function (s)
			if data_config[s] then
				return data_config[s].name
			else
				return s
			end
		end,
		default = "magic",
		change_refresh = true,
	},
	sel_key = {
		key = "sel_key",
		name = "子类型",
		select_update = function ()
			local oView = CEditorTableView:GetView()
			local list = {}
			for k, v in pairs(data_config[oView.m_UserCache.sel_type].modify_table) do
				table.insert(list, k)
			end
			table.sort(list)
			return list
		end,
		wrap = function(sOri)
			local oView = CEditorTableView:GetView()
			local sNew = data_config[oView.m_UserCache.sel_type].modify_table[sOri].name
			if sNew then
				return sNew
			else
				return sOri
			end
		end,
		change_refresh = true,
	},
}

dict_open = function(sKey, sName, sFunc, sTrigger)
	local d = {
			key = sKey,
			name = sName,
			preview_func = function(dNew)
				data.guidedata[sKey] = dNew
				data.guidedata.FuncMap[sFunc] = function()
					return true
				end
				g_GuideCtrl:LoginInit({})
				g_GuideCtrl:TriggerCheck(sTrigger)
			end,
	}
	return d
end

dict_view = function (sKey, sName, cls)
	local d = {
				key = sKey,
				name = sName,
				preview_func = function(dNew)
					data.guidedata[sKey] = dNew
					cls:CloseView()
					g_GuideCtrl:LoginInit({})
					cls:ShowView()
				end,
			}
	return d
end


data_config = {
	guide ={
		name="新手引导",
		path="/Lua/logic/data/guidedata.lua",
		modify_table = {
			War1 = {
				key = "War1",
				name = "战斗1引导",
				preview_func = function(dNew)
					g_GuideCtrl:LoginInit({})
					war_id = warsimulate.war_id
					data.guidedata.War1 = dNew
					warsimulate.Start(1, 302, 2100, 10001)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
				end,
			},
			War2 = {
				key = "War2",
				name = "战斗2引导",
				preview_func = function(dNew)
					g_GuideCtrl:LoginInit({})
					war_id = warsimulate.war_id
					data.guidedata.War2 = dNew
					warsimulate.Start(1, 302, 2100, 10004)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {40402, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 6, name="test", parid=9002, pos = 3, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
				end,
			},
			-- War3 = {
			-- 	key = "War3",
			-- 	name = "竞技场手动教学",
			-- 	preview_func = function(dNew)
			-- 		g_GuideCtrl:LoginInit({})
			-- 		war_id = warsimulate.war_id
			-- 		data.guidedata.War2 = dNew
			-- 		warsimulate.Start(1, 302, 2100, 10004)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {40402, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 6, name="test", parid=9002, pos = 3, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
			-- 	end,
			-- },
			WarAutoWar = {
				key = "WarAutoWar",
				name = "自动战斗",
				preview_func = function(dNew)
					g_GuideCtrl:LoginInit({})
					war_id = warsimulate.war_id
					data.guidedata.War2 = dNew
					warsimulate.Start(1, 302, 2100, 10004)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {40402, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 6, name="test", parid=9002, pos = 3, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
				end,
			},	
			War4 = {
				key = "War4",
				name = "怒气技能",
				preview_func = function(dNew)
					g_GuideCtrl:LoginInit({})
					war_id = warsimulate.war_id
					data.guidedata.War2 = dNew
					warsimulate.Start(1, 302, 2100, 10004)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {40402, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 6, name="test", parid=9002, pos = 3, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
					netwar.GS2CWarAddWarrior(t)
					netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
				end,
			},			
			-- WarReplace = {
			-- 	key = "WarReplace",
			-- 	name = "战斗替换伙伴",
			-- 	preview_func = function(dNew)
			-- 		g_GuideCtrl:LoginInit({})
			-- 		war_id = warsimulate.war_id
			-- 		data.guidedata.War2 = dNew
			-- 		warsimulate.Start(1, 302, 2100, 10004)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {40402, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 6, name="test", parid=9002, pos = 3, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
			-- 		netwar.GS2CWarAddWarrior(t)
			-- 		netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
			-- 	end,
			-- },
			--StoryDlg = {key = "StoryDlg",name = "剧情对话框",},
			--Skill = {key = "Skill",name = "技能",},
			--Pata = {key = "Pata",name = "爬塔",},

			Open_ZhaoMu = dict_open("Open_ZhaoMu", "招募1(1/4)", "luckdraw_open", "grade"),
			DrawCard = dict_view("DrawCard", "招募1(2/4)", CPartnerHireView),
			DrawCardLineUp_MainMenu = dict_view("DrawCardLineUp_MainMenu", "招募1 伙伴上阵(3/4)", CMainMenuView),
			DrawCardLineUp_PartnerMain = dict_view("DrawCardLineUp_PartnerMain", "招募1 伙伴上阵(4/4)", CPartnerMainView),

			Open_ZhaoMu_Two = dict_open("Open_ZhaoMu_Two", "招募2(1/4)", "luckdraw_open", "grade"),
			DrawCard_Two = dict_view("DrawCard_Two", "招募1(2/4)", CPartnerHireView),
			DrawCardLineUp_Two_MainMenu = dict_view("DrawCardLineUp_Two_MainMenu", "招募2 伙伴上阵(3/4)", CMainMenuView),
			DrawCardLineUp_Two_PartnerMain = dict_view("DrawCardLineUp_Two_PartnerMain", "招募2 伙伴上阵(4/4)", CPartnerMainView),			

			Open_ZhaoMu_Three = dict_open("Open_ZhaoMu_Three", "招募3(1/5)", "luckdraw_open", "grade"),
			DrawCard_Three = dict_view("DrawCard_Three", "招募3(2/5)", CPartnerHireView),
			Partner_HBPY_MainMenu = dict_view("Partner_HBPY_MainMenu", "招募3 伙伴培育(3/5)", CMainMenuView),
			Partner_HPPY_PartnerMain = dict_view("Partner_HPPY_PartnerMain", "招募3 伙伴培育(4/5)", CPartnerMainView),		
			DrawCardLineUp_Three_PartnerMain = dict_view("DrawCardLineUp_Three_PartnerMain", "招募3 伙伴上阵(5/5)", CPartnerMainView),		

			Partner_FWCD_One_MainMenu = dict_view("Partner_FWCD_One_MainMenu", "符文穿戴1(1/2)", CMainMenuView),
			Partner_FWCD_One_PartnerMain = dict_view("Partner_FWCD_One_PartnerMain", "符文穿戴1(2/2)", CPartnerMainView),

			Partner_FWCD_Two_MainMenu = dict_view("Partner_FWCD_Two_MainMenu", "符文穿戴1(1/2)", CMainMenuView),
			Partner_FWCD_Two_PartnerMain = dict_view("Partner_FWCD_Two_PartnerMain", "符文穿戴2(2/2)", CPartnerMainView),

			Partner_FWQH_MainMenu = dict_view("Partner_FWQH_MainMenu", "符文强化(1/2)", CMainMenuView),
			Partner_FWQH_PartnerMain = dict_view("Partner_FWQH_PartnerMain", "符文强化(2/2)", CPartnerMainView),

			Skill = dict_view("Skill", "切换流派(1/1)", CSkillMainView),

			Open_Skill_Three = dict_open("Open_Skill_Three", "主角第3技能(1/2)", "luckdraw_open", "grade"),
			Skill_Three = dict_view("Skill_Three", "主角第3技能(2/2)", CSkillMainView),		

			Open_Skill_Four = dict_open("Open_Skill_Four", "主角第4技能(1/2)", "luckdraw_open", "grade"),
			Skill_Four = dict_view("Skill_Four", "主角第4技能(2/2)", CSkillMainView),										

			MapSwitchMainmenu = dict_view("MapSwitchMainmenu", "地图跳转(1/2)", CMainMenuView),
			MapSwitchMapView = dict_view("MapSwitchMapView", "地图跳转(2/2)", CMapMainView),			
					
			Open_House = dict_open("Open_House", "宅邸开放(1/6)", "house_open", "grade"),
			HouseView = dict_view("HouseView", "宅邸开放(2/6)", CHouseMainView),
			HouseTwoView = dict_view("HouseView", "宅邸开放(3/6)", CHouseMainView),			
			HouseTeaartView = dict_view("HouseTeaartView", "宅邸开放(5/6)", CTeaartView),

			TeamMainView_HandyBuild = dict_view("TeamMainView_HandyBuild", "快捷组队指引(1/1)", CTeamTargetSetView),

			HuntPartnerSoulView = dict_view("HuntPartnerSoulView", "猎灵(1/3)", HuntPartnerSoulView),
			Open_Yuling = dict_view("Open_Yuling", "猎灵(2/3)", CMainMenuView),
			Yuling_PartnerMain = dict_view("Yuling_PartnerMain", "猎灵(3/3)", CPartnerMainView),

			Open_Achieve = dict_open("Open_Achieve", "成就(1/2)", "achieve_open", "grade"),
			Open_Pefuben = dict_open("Open_Pefuben", "御灵副本(1/1)", "yikong_open", "grade"),
			Open_Shimen = dict_open("Open_Pvp", "师门任务(1/1)", "equipfuben_open", "grade"),							
			Open_Convoy = dict_open("Open_Convoy", "帝都宅急便(1/1)", "equipfuben_open", "grade"),							
			Open_Pata = dict_open("Open_Pata", "地牢(1/1)", "pata_open", "grade"),
			Open_Travel = dict_open("Open_Pata", "游历(1/1)", "travel_open", "grade"),
			Open_Org = dict_open("Open_Org", "工会开启(1/1)", "org_open", "grade"),	
			Open_Travel = dict_open("Open_Travel", "游历(1/1)", "schedule_open", "grade"),
			Open_FieldBoss = dict_open("Open_FieldBoss", "人形讨伐(1/1)", "schedule_open", "grade"),
			Open_YJFuben = dict_open("Open_YJFuben", "梦魇狩猎(1/1)", "schedule_open", "grade"),
			Open_Schedule = dict_open("Open_Org", "日程开放(1/1)", "schedule_open", "grade"),
			Open_Arena = dict_open("Open_Arena", "竞技场(1/1)", "arena_open", "grade"),
			Open_EqualArena = dict_open("Open_EqualArena", "公平比武(1/1)", "arena_open", "grade"),
			Open_Trapmine = dict_open("Open_Trapmine", "探索开启(1/1)", "trapmine_open", "grade"),
			Open_MingLei = dict_open("Open_MingLei", "喵萌茶会开启(1/1)", "minglei_open", "grade"),
			Open_MapBook = dict_open("Open_MapBook", "图鉴开启(1/1)", "mapbook_open", "grade"),			
			Open_Lilian = dict_open("Open_Lilian", "每日修行开启(1/1)", "lilian_open", "grade"),						
			Open_Equipfuben = dict_open("Open_Equipfuben", "装备副本开启(1/1)", "equip_fb", "grade"),
			Open_Forge = dict_open("Open_Forge", "装备打造开启(1/1)", "forge_open", "grade"),
			Open_Forge_composite = dict_open("Open_Forge_composite", "装备合成开启(1/1)", "forge_open", "grade"),
		
		},
		modify_key = {
			start_condition = {name="触发条件", select_type="condition"},
			continue_condition = {name="继续条件", select_type="condition"},
			ui_key = {name="ui名"},
			effect_tips_enum = {name="提示类型"},
			texture_name ={name="图片名"},
			guide_list = 
			{
				name="指引列表",
				list_type = true, 
				default_value={
					leave_team="",
					click_continue=false,
					click_continue_time=0,
					continue_condition="",
					effect_list={},
					start_condition="",
					need_guide_view = true,
					force_hide_continue_label=false,
					is_cache_step=false
				},
			},
			click_continue = {name="点击继续"},
			force_hide_continue_label = {name="隐藏点击继续文本"},
			effect_list = {
				name="指引效果",
				list_type = true,
				type_arginfo = {
					key = "value_type",
					name = "指引类型",
					select_type = "effect_type",
					default = "???",
				},
			},
			near_pos = {name="距离指引位置"},
			x = {},
			y = {},
			w = {name="宽度"},
			h = {name="高度"},
			text_list = {
						name="文字列表", 
						list_type = true,
						default_value=" "},
			fixed_pos = {name="固定位置"},
			ui_effect = {name="指引特效"},
			play_tween = {name="显示动画"},
			dlg_is_left = {name="是否居左"},
			dlg_is_flip = {name="是否朝后"},
			spine_left_shape = {name="左侧人物"},			
			spine_right_shape = {name="右侧人物"},
			spine_left_motion = {name="左侧动作"},
			spine_right_motion = {name="右侧动作"},
			guide_voice_list_1 = {name="语音1"},
			guide_voice_list_2 = {name="语音2"},			
			aplha= {name="透明度"},
			side_list = {
						name="左右侧说话对象", 
						list_type = true,
						default_value="0"},			
			dlg_sprite = {name="对话框图"},
			flip_y = {name="y轴翻转"},
			-- guide_key = {},
			effect_type = {name="类型", wrap="effect_type"},
			teach_id = {name="教学id"},
			sprite_name = {name="spritename",},
			open_text = {name="文字"},
			focus_ui_size = {name="ui高光大小"},
			need_guide_view = {name="需要指引界面"},
			next_tip = {name="下页标签", select_type="bool_type", default=nil,}
		},
		value_default = {
			["texture"] = {
					ui_key=[[]],
					near_pos={x=0, y=0},
					fixed_pos={x=0,y=0,},
					flip_y=false,
					play_tween=true,
					texture_name=[[guide_1.png]],
					effect_type=[[texture]],
				},
			["dlg"]={
					ui_key=[[]],
					near_pos={x=0, y=0},
					dlg_sprite=[[pic_zhiying_ditu_1]],
					dlg_tips_sprite=[[guide_3]],
					fixed_pos={x=0,y=0,},
					dlg_is_left=true,
					play_tween=true,
					text_list={
					},
					effect_type=[[dlg]],
					aplha=255,
				},
			["textdlg"]={
					ui_key=[[]],
					near_pos={x=0, y=0},
					fixed_pos={x=0,y=0,},
					dlg_is_left=true,
					play_tween=true,
					text_list={
					},
					effect_type=[[textdlg]],
					aplha=255,
				},				
			["bigdlg"]={
					ui_key=[[]],
					near_pos={x=0, y=0},
					fixed_pos={x=0,y=0,},
					dlg_is_left=true,
					dlg_is_flip=false,
					play_tween=true,
					text_list={
					},
					effect_type=[[bigdlg]],
					aplha=255,
				},				
			["spine"]={
					ui_key=[[]],
					spine_left_shape=[[1001]],
					spine_right_shape=[[1002]],						
					text_list={
					},
					side_list={
					},
					guide_voice_list_1=[[0]],
					guide_voice_list_2=[[0]],			
					effect_type=[[spine]],
					spine_left_motion=[[idle]],
					spine_right_motion=[[idle]],	
					aplha=255,
				},
			["none"]={			
					effect_type=[[none]],
				},		
			["focus_ui"]={
						aplha=255,
						focus_ui_size=1.2, 
						effect_type="focus_ui", 
						ui_key="draw_wl_card", 
						ui_effect="Finger",
						effect_tips_enum=0,
						effect_offset_pos={x=0,y=0},
						mode=1,
						},
			["focus_pos"]={
						aplha=255,
						h=0.12,
						pos_func=[[war1_pos2]],
						effect_type=[[focus_pos]],
						ui_effect=[[Finger]],
						w=0.07,
						effect_tips_enum=1,
						},
			["click_ui"]={
						near_pos={x=0,y=0}, 
						offset_pos={x=0,y=0},
						effect_type=[[click_ui]],
						ui_effect=[[Finger]],
						ui_key=[[请选择]],
						aplha=255,
						effect_tips_enum=1,
						view_name=[[]]
						},
			["hide_click_event"]={},
			["hide_focus_box"]={},
			["teach_guide"]={effect_type=[[teach_guide]], teach_id = 30007},
			["focus_common"]={effect_type=[[focus_common]],x=0.5,y=0.5,w=1,h=1},		
			["open"] = {
					effect_type="open", 
					ui_key="mainmenu_operate_btn", 
					sprite_name = "btn_bwcrk2017",
					open_text='竞技场',
				},
		},
		before_dump = function(t)
			for _, dGuide in ipairs(t.guide_list) do
				local list = {}
				for _, dEffect in ipairs(dGuide.effect_list) do
					for k, v in pairs(dEffect) do
						if k == "ui_key" then
							if not table.index(list, v) then
								table.insert(list, v)
							end
						end
					end
					dEffect.guide_key = nil
				end
				dGuide.necessary_ui_list = list
			end
		end
	},
	notice={
		name="公告",
		path="/Lua/logic/data/noticedata.lua",
		modify_table = {
			Content = {
				key = "Content",
				name = "内容",
			},
		},
		modify_key = {
			contents = {default_value={title="填写标题", text = "填写内容"}, list_type = true,},
			pic = {name="pic"},
			text = {name="text"},
			title = {name="title"},
		},
		before_dump = function(t)
			printc("生成json格式:\n\r", cjson.encode(t))
			return t
		end,
	},
	showwar={
		name="战斗演示",
		path="/Lua/logic/data/showwardata.lua",
		modify_table = {
			Boss = {
				key = "Boss",
				name = "Boss战",
				preview_func = function(dNew)
					g_ShowWarCtrl:LoadShowWar("Boss")
				end,
			},
		},
		modify_key = {
			wid = {name="战士id"},
			name = {name="名字",},
			pos = {name="站位",},
			camp = {name="阵营",},
			shape = {name="造型",},
			weapon = {name="武器",},
			partner = {name="是否伙伴",},
			cmd_name = {name="指令名", select_type="cmd_name"},
			warrior_list = {
				name="战士列表",
				list_type = true,
				default_value = {
					wid = 1,
					name = "名字",
					pos = 1,
					camp = 1,
					shape = 130,
					weapon = 0,
					partner = 0,
				},
			},
			cmd_list = {
				name="指令列表", 
				list_type = true,
				default_value = {
					cmd_name = "",
					arg_list = {},
				}
			},
			arg_list = {
				name="参数列表", 
				list_type = true,
				default_value = "",
			},
		},
		value_default = {
		},
		before_dump = function(t)
			return t
		end,
	}
}