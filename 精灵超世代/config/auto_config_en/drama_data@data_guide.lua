-- this file is generated by program!
-- don't change it manaully.
-- source file: drama_data.xls

Config = Config or {} 
Config.DramaData = Config.DramaData or {}
Config.DramaData.data_guide_key_depth = 1
Config.DramaData.data_guide_length = 52
Config.DramaData.data_guide_lan = "en"
Config.DramaData.data_guide = {
	[10010] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"dec_1001",-20,0,0,100},{"checkstatus","centercity",5,0.3},{"name",0.3,"guidesign_build_5",1,0,0,0,1,0,0,"dec_1002",-210,0,1,100,"d_1002"},{"summon",0.3},{"name",0.3,"guildsign_summon_1_1",0,1,0,0,1,0,0,"",0,0,0,0},{"summonresult",4},{"name",0.3,"guildsign_summon_comfirm_btn",0,0,1,0,1,0,0,"",0,0,0,0,"d_1003"}},{{"emptystep"},{"checkstatus","centercity",5,0.3},{"name",0.3,"guidesign_build_5",1,0,0,0,1,0,0,"dec_1002",-210,0,1,100,"d_1002"},{"summon",0.3},{"name",0.3,"guildsign_summon_1_1",0,1,0,0,1,0,0,"",0,0,0,0},{"summonresult",4},{"name",0.3,"guildsign_summon_comfirm_btn",0,0,1,0,1,0,0,"",0,0,0,0,"d_1003"}}}}},desc="Capture Pokémon Guide",id=10010,is_close=0,over_step=5,skip=1,special_step={}},
	[10030] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1004"},{"partnergofight",0.3},{"name",0.3,"hero_40403",1,0,0,0,1,0,0,"dec_1003",0,0,0,100,"d_1005"},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"dec_1004",0,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1004"},{"partnergofight",0.3},{"name",0.3,"hero_40403",1,0,0,0,1,0,0,"dec_1003",0,0,0,100,"d_1005"},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"dec_1004",0,0,0,100}}}}},desc="Push the first level of guidance",id=10030,is_close=0,over_step=0,skip=1,special_step={}},
	[10040] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.3,"guidesign_battle_reward_btn",0,0,0,0,1,0,0,"",0,0,0,100},{"battletoppassrewards",0.3},{"tag",0.3,10010,0,1,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.3},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.3},{"name",0.3,"guidesign_battle_reward_btn",0,0,0,0,1,0,0,"",0,0,0,100},{"battletoppassrewards",0.3},{"tag",0.3,10010,0,1,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.3},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Guide to receive clearance rewards",id=10040,is_close=0,over_step=6,skip=1,special_step={}},
	[10050] = {act={{"mainui",0.1},{"name",0.1,"mainui_tab_3",0,0,0,0,1,0,0,"",0,0,0,0},{"backpack",0.2},{"name",0.1,"tab_btn_3",0,0,0,0,1,0,0,"dec_1005",0,0,0,100},{"name",0.3,"item_24804",0,0,0,0,1,0,0,"",-70,0,1,100},{"comptipsview",0.2},{"name",0.3,"com_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.2},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1008"}},desc="Pokémon Synthesis Guide",id=10050,is_close=0,over_step=7,skip=1,special_step={}},
	[10060] = {act={{"conditonstatus","partner",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.1,"hero_10405",1,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"level_up_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"level_up_btn",0,1,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.1,"hero_10405",1,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"level_up_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"level_up_btn",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Pokémon upgrade guide",id=10060,is_close=0,over_step=0,skip=1,special_step={}},
	[10070] = {act={{"conditonstatus","partnereinfoview",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"key_up_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1011"}},{{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.1,"hero_10405",1,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"key_up_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1011"}}}}},desc="Equipment wear guide",id=10070,is_close=0,over_step=0,skip=1,special_step={}},
	[10080] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1010"},{"partnergofight",0.3},{"name",0.3,"hero_10405",1,0,0,0,1,0,0,"",0,0,0,100},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1010"},{"partnergofight",0.3},{"name",0.3,"hero_10405",1,0,0,0,1,0,0,"",0,0,0,100},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}}}}},desc="Push the second level of guidance",id=10080,is_close=0,over_step=0,skip=1,special_step={}},
	[10090] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"dec_1001",-20,0,0,100},{"checkstatus","centercity",10,0.3},{"name",0.3,"guidesign_build_10",1,0,0,0,1,0,0,"",-210,0,1,100},{"varietystoreview",0.3},{"name",0.3,"buy_btn_4",0,1,0,0,1,0,-80,"dec_1006",0,-160,0,100}},{{"emptystep"},{"checkstatus","centercity",10,0.3},{"name",0.3,"guidesign_build_10",1,0,0,0,1,0,0,"",-210,0,1,100},{"varietystoreview",0.3},{"name",0.3,"buy_btn_4",0,1,0,0,1,0,-80,"dec_1006",0,-160,0,100}}}}},desc="Catch the ball buying guide",id=10090,is_close=0,over_step=0,skip=1,special_step={}},
	[10100] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"dec_1001",-20,0,0,100},{"checkstatus","centercity",5,0.3},{"name",0.3,"guidesign_build_5",1,0,0,0,1,0,0,"",-210,0,1,100},{"summon",0.3},{"name",0.3,"guildsign_summon_3_1",0,1,0,0,1,0,0,"dec_1007",0,0,0,100},{"summonresult",4},{"name",0.3,"guildsign_summon_next_btn",0,0,0,0,1,0,-550,"",0,0,0,0},{"name",0.3,"guildsign_summon_comfirm_btn",0,0,1,0,1,0,0,"",0,0,0,0}},{{"emptystep"},{"checkstatus","centercity",5,0.3},{"name",0.3,"guidesign_build_5",1,0,0,0,1,0,0,"",-210,0,1,100},{"summon",0.3},{"name",0.3,"guildsign_summon_3_1",0,1,0,0,1,0,0,"dec_1007",0,0,0,100},{"summonresult",4},{"name",0.3,"guildsign_summon_next_btn",0,0,0,0,1,0,-550,"",0,0,0,0},{"name",0.3,"guildsign_summon_comfirm_btn",0,0,1,0,1,0,0,"",0,0,0,0}}}}},desc="Second capture guide",id=10100,is_close=0,over_step=5,skip=1,special_step={}},
	[10120] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.2},{"name",0.3,"guidesign_battle_quick_btn",0,0,0,0,1,0,0,"dec_1008",0,0,0,100},{"battlequickview",0.6},{"name",0.1,"guidesign_quick_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1023"},{"battletophookrewards",0.3},{"name",0.3,"guidesign_rewards_quick_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"battlequickview",0.1},{"name",0.1,"close_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.2},{"name",0.3,"guidesign_battle_quick_btn",0,0,0,0,1,0,0,"dec_1008",0,0,0,100},{"battlequickview",0.6},{"name",0.1,"guidesign_quick_btn",0,0,0,0,1,0,0,"",0,0,0,0,"d_1023"},{"battletophookrewards",0.3},{"name",0.3,"guidesign_rewards_quick_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"battlequickview",0.1},{"name",0.1,"close_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Quick combat guidance",id=10120,is_close=0,over_step=6,skip=1,special_step={}},
	[10130] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"partnergofight",0.3},{"name",0.3,"hero_30405",1,0,0,0,1,0,0,"",0,0,0,100},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"partnergofight",0.3},{"name",0.3,"hero_30405",1,0,0,0,1,0,0,"",0,0,0,100},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}}}}},desc="Push the third level of guidance",id=10130,is_close=0,over_step=0,skip=1,special_step={}},
	[10140] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.2},{"name",0.3,"hallows_stage",0,0,0,0,1,0,0,"",0,0,1,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.2},{"name",0.3,"hallows_stage",0,0,0,0,1,0,0,"",0,0,1,100}}}}},desc="Trainer interface guidance",id=10140,is_close=0,over_step=0,skip=1,special_step={}},
	[10141] = {act={{"conditonstatus","hallowspreview",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"hallows_1",0,0,0,0,1,0,0,"",0,0,1,100,"d_1020"}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"hallows_stage",0,0,0,0,1,0,0,"",0,0,1,100},{"hallowspreview",0.2},{"name",0.3,"hallows_1",0,0,0,0,1,0,0,"",0,0,1,100,"d_1020"}}}}},desc="Trainer task guidance",id=10141,is_close=0,over_step=0,skip=1,special_step={}},
	[10150] = {act={{"conditonstatus","hallowswindow",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"get_btn_101",0,0,0,0,1,0,0,"",0,0,1,100,"d_1021"}},{{"mainui",0.1},{"name",0.1,"mainui_tab_7",0,0,0,0,1,0,0,"",0,0,0,0},{"hallowswindow",0.2},{"name",0.3,"get_btn_101",0,0,0,0,1,0,0,"",0,0,1,100,"d_1021"}}}}},desc="Task reward guidance",id=10150,is_close=0,over_step=0,skip=1,special_step={}},
	[10151] = {act={{"conditonstatus","hallowswindow",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"goto_btn_102",0,0,0,0,1,0,0,"dec_1009",0,0,1,100,"d_1022"}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.2},{"name",0.3,"hallows_stage",0,0,0,0,1,0,0,"",0,0,1,100},{"hallowswindow",0.2},{"name",0.3,"goto_btn_102",0,0,0,0,1,0,0,"dec_1009",0,0,1,100,"d_1022"}}}}},desc="Task jump guide (below level 5)",id=10151,is_close=0,over_step=0,skip=1,special_step={}},
	[10152] = {act={{"conditonstatus","hallowswindow",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"get_btn_102",0,0,0,0,1,0,0,"dec_1010",0,0,1,100},{"getitemview",0.2},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"mainui",0.1},{"name",0.3,"mainui_tab_4",0,0,0,0,1,0,0,"",-20,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.2},{"name",0.3,"hallows_stage",0,0,0,0,1,0,0,"",0,0,1,100},{"hallowswindow",0.2},{"name",0.3,"get_btn_102",0,0,0,0,1,0,0,"dec_1010",0,0,1,100},{"getitemview",0.2},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"mainui",0.1},{"name",0.3,"mainui_tab_4",0,0,0,0,1,0,0,"",-20,0,0,100}}}}},desc="Task jump guidance (level 5 and above)",id=10152,is_close=0,over_step=6,skip=1,special_step={}},
	[10160] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"dec_1011",0,0,0,100},{"partnergofight",0.3},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"dec_1011",0,0,0,100},{"partnergofight",0.3},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}}}}},desc="Push the fourth level to guide (under level 5)",id=10160,is_close=0,over_step=0,skip=1,special_step={}},
	[10161] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"dec_1011",0,0,0,100},{"partnergofight",0.3},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"dec_1011",0,0,0,100},{"partnergofight",0.3},{"name",0.3,"fight_btn",0,0,0,0,1,0,0,"",0,0,0,100}}}}},desc="Push the fourth level to guide (above level 5)",id=10161,is_close=0,over_step=0,skip=1,special_step={}},
	[10165] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.2},{"name",0.3,"resources_model",0,0,0,0,1,-150,0,"dec_1012",-150,-20,0,100},{"battletophookrewards",0.3},{"name",0.3,"guidesign_rewards_quick_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.2},{"name",0.3,"resources_model",0,0,0,0,1,-150,0,"dec_1012",-150,-20,0,100},{"battletophookrewards",0.3},{"name",0.3,"guidesign_rewards_quick_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Get on-hook income guidance",id=10165,is_close=0,over_step=0,skip=1,special_step={}},
	[10170] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Push the fifth level to guide",id=10170,is_close=0,over_step=0,skip=1,special_step={}},
	[10172] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.2},{"name",0.3,"hero_btn",0,0,0,0,1,0,0,"",0,0,0,100},{"strongerview",0.6},{"name",0.1,"go_btn_1",0,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"level_up_btn",0,1,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.2},{"name",0.3,"hero_btn",0,0,0,0,1,0,0,"",0,0,0,100},{"strongerview",0.6},{"name",0.1,"go_btn_1",0,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"level_up_btn",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Stronger upgrade guide",id=10172,is_close=0,over_step=0,skip=1,special_step={}},
	[10175] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"name",0.1,"icon_login_day",0,0,0,0,1,0,0,"",0,0,0,0},{"sevenloginview",0.5},{"name",2.1,"get_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"icon_login_day",0,0,0,0,1,0,0,"",0,0,0,0},{"sevenloginview",0.5},{"name",2.1,"get_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Seven-day login reward guide",id=10175,is_close=0,over_step=0,skip=1,special_step={}},
	[10177] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"name",0.1,"icon_welfare",0,0,0,0,1,0,0,"",0,0,0,0},{"welfareview",0.5},{"name",0.5,"sign_btn_1",0,0,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.2},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"icon_welfare",0,0,0,0,1,0,0,"",0,0,0,0},{"welfareview",0.5},{"name",0.5,"sign_btn_1",0,0,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.2},{"name",0.3,"confirm_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Daily sign-in guide",id=10177,is_close=0,over_step=0,skip=1,special_step={}},
	[10179] = {act={{"conditonstatus","welfareview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.3,"guildsign_battle_boss_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Push the sixth level to guide",id=10179,is_close=0,over_step=0,skip=1,special_step={}},
	[10180] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"checkstatus","centercity",3,0.3},{"name",0.3,"guidesign_build_3",1,0,0,0,1,0,0,"",0,0,1,0},{"arenaloopview",0.3},{"tag",0.1,1001}},{{"emptystep"},{"checkstatus","centercity",3,0.3},{"name",0.3,"guidesign_build_3",1,0,0,0,1,0,0,"",-140,0,1,0},{"arenaloopview",0.3},{"tag",0.1,1001}}}}},desc="Arena guide",id=10180,is_close=0,over_step=0,skip=1,special_step={}},
	[10182] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"name",0.1,"icon_dial",0,0,0,0,1,0,0,"",0,0,0,0},{"treasureview",0.1},{"name",0.1,"btn_treasure_1",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"icon_dial",0,0,0,0,1,0,0,"",0,0,0,0},{"treasureview",0.1},{"name",0.1,"btn_treasure_1",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Treasure hunting guide",id=10182,is_close=0,over_step=0,skip=1,special_step={}},
	[10185] = {act={{"conditonstatus","battlesceneview",0.1,{{{"emptystep"},{"emptystep"},{"battletopscene",0.1},{"name",0.1,"guidesign_tipsqingbao",0,0,0,0,1,0,0,"",0,0,0,0},{"voyageview",0.3},{"name",0.3,"get_btn_1",1,0,0,0,1,0,0,"",0,0,0,100},{"voyagedispatchview",0.3},{"name",0.3,"quick_btn",0,0,0,0,1,0,0,"",0,0,0,100},{"name",0.3,"dispatch_btn",0,0,0,0,1,0,0,"",0,0,0,100}},{{"mainui",0.1},{"name",0.1,"mainui_tab_4",0,0,0,0,1,0,0,"",0,0,0,0},{"battletopscene",0.1},{"name",0.1,"guidesign_tipsqingbao",0,0,0,0,1,0,0,"",0,0,0,0},{"voyageview",0.3},{"name",0.3,"get_btn_1",1,0,0,0,1,0,0,"",0,0,0,100},{"voyagedispatchview",0.3},{"name",0.3,"quick_btn",0,0,0,0,1,0,0,"",0,0,0,100},{"name",0.3,"dispatch_btn",0,0,0,0,1,0,0,"",0,0,0,100}}}}},desc="Adventure guide",id=10185,is_close=0,over_step=0,skip=1,special_step={}},
	[10187] = {act={{"openview","firstrecharge",0.3}},desc="Old version of the first charge guide",id=10187,is_close=0,over_step=0,skip=1,special_step={}},
	[10190] = {act={{"mainui",0.1},{"name",0.1,"mainui_tab_5",0,0,0,0,1,0,0,"",0,0,0,0},{"esecsiceview",0.2},{"name",0.1,"guide_activity_item_1",0,0,0,0,1,0,0,"",0,0,0,100},{"stonedunview",0.2},{"name",0.3,"stone_change_btn_101",0,0,0,0,1,0,0,"",0,0,0,0}},desc="Gold coin copy guide",id=10190,is_close=0,over_step=0,skip=1,special_step={}},
	[10192] = {act={{"openview","newfirstrecharge",0.3}},desc="New version of the first charge guide",id=10192,is_close=0,over_step=0,skip=1,special_step={}},
	[10194] = {act={{"openview","newfirstrecharge1",0.3}},desc="New version 2 first charge guide (cover Ouka)",id=10194,is_close=0,over_step=0,skip=1,special_step={}},
	[10197] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,100},{"checkstatus","centercity",1,0.3},{"name",0.3,"guidesign_build_1",1,0,0,0,1,0,0,"",-210,0,1,100},{"areascene",0.3},{"name",0.3,"guide_build_2",0,1,0,0,1,0,0,"",0,0,0,0}},{{"emptystep"},{"checkstatus","centercity",1,0.3},{"name",0.3,"guidesign_build_1",1,0,0,0,1,0,0,"",-210,0,1,100},{"areascene",0.3},{"name",0.3,"guide_build_2",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Grocery store buying guide (removed from commercial street, obsolete)",id=10197,is_close=0,over_step=0,skip=1,special_step={}},
	[10200] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"checkstatus","centercity",4,0.3},{"name",0.3,"guidesign_build_4",1,0,0,0,1,0,0,"",0,0,1,0},{"startowerview",0.2},{"name",0.1,"guildsign_startower_1",1,0,0,0,1,0,0,"dec_1013~",0,0,0,100},{"startowerchallengeview",0.2},{"name",0.1,"btn1",0,0,0,0,1,0,0,"",0,0,0,0}},{{"emptystep"},{"checkstatus","centercity",4,0.3},{"name",0.3,"guidesign_build_4",1,0,0,0,1,0,0,"",0,0,1,0},{"startowerview",0.2},{"name",0.1,"guildsign_startower_1",1,0,0,0,1,0,0,"dec_1013~",0,0,0,100},{"startowerchallengeview",0.2},{"name",0.1,"btn1",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Sky Tower Guide",id=10200,is_close=0,over_step=0,skip=1,special_step={}},
	[10210] = {act={{"mainui",0.1},{"name",0.8,"mainui_tab_6",0,0,0,0,1,0,0,"",0,0,0,0}},desc="Guild Guidance",id=10210,is_close=0,over_step=0,skip=1,special_step={}},
	[10220] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"checkstatus","centercity",8,0.3},{"name",0.3,"guidesign_build_8",1,0,0,0,1,0,0,"",0,0,1,0},{"seerpalaceview",0.2},{"name",0.5,"guide_card_1",0,0,0,0,1,0,0,"",0,0,0,100}},{{"emptystep"},{"checkstatus","centercity",8,0.3},{"name",0.8,"guidesign_build_8",1,0,0,0,1,0,0,"",-140,0,1,0},{"seerpalaceview",0.2},{"name",0.5,"guide_card_1",0,0,0,0,1,0,0,"",0,0,0,100}}}}},desc="Hunting zone guidance",id=10220,is_close=0,over_step=0,skip=1,special_step={}},
	[10222] = {act={{"openview","limittimeview",0.3}},desc="Hunting package pop-up guide",id=10222,is_close=0,over_step=0,skip=1,special_step={}},
	[10250] = {act={{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.3,"embattle_btn",0,0,0,0,1,0,0,"",0,0,0,100}},desc="Trainer wear guide",id=10250,is_close=0,over_step=0,skip=1,special_step={}},
	[10300] = {act={{"homeworldunlockkey",0.3},{"name",0.3,"goto_home_world_btn",0,0,0,0,1,0,0,"",0,0,0,0}},desc="Get the park key guide",id=10300,is_close=0,over_step=1,skip=1,special_step={}},
	[10310] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",0,0,0,0},{"checkstatus","centercity",14,0.3},{"name",0.3,"guidesign_build_14",1,0,0,0,1,0,0,"",0,0,1,0}},{{"emptystep"},{"checkstatus","centercity",14,0.3},{"name",0.3,"guidesign_build_14",1,0,0,0,1,0,0,"",0,0,1,0}}}}},desc="Paradise entry guide",id=10310,is_close=0,over_step=0,skip=1,special_step={}},
	[10330] = {act={{"conditonstatus","homeworldscene",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.1,"guide_shop_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"homeworldshop",0.3},{"name",0.3,"guide_btn_shop_4",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_shop_item_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"homeworldshopbuy",0.3},{"name",0.3,"guide_buy_btn",0,1,0,0,1,0,0,"dec_1014",0,0,0,0},{"homeworldshop",0.3},{"name",0.3,"guide_close_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"checkstatus","centercity",14,0.3},{"name",0.3,"guidesign_build_14",1,0,0,0,1,0,0,"",0,0,1,0},{"homeworldscene",0.3},{"name",0.1,"guide_shop_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"homeworldshop",0.3},{"name",0.3,"guide_btn_shop_4",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_shop_item_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"homeworldshopbuy",0.3},{"name",0.3,"guide_buy_btn",0,1,0,0,1,0,0,"dec_1014",0,0,0,0},{"homeworldshop",0.3},{"name",0.3,"guide_close_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Buying furniture guide",id=10330,is_close=0,over_step=9,skip=1,special_step={}},
	[10340] = {act={{"conditonstatus","homeworldscene",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.1,"guide_edit_btn",0,0,0,0,1,0,0,"dec_1015",0,0,0,0},{"name",0.3,"guide_btn_my_unit_4",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_my_unit_200104",0,0,0,0,1,0,0,"dec_1016",0,0,0,0},{"name",0.3,"guide_save_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"checkstatus","centercity",14,0.3},{"name",0.3,"guidesign_build_14",1,0,0,0,1,0,0,"",0,0,1,0},{"homeworldscene",0.3},{"name",0.1,"guide_edit_btn",0,0,0,0,1,0,0,"dec_1015",0,0,0,0},{"name",0.3,"guide_btn_my_unit_4",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_my_unit_200104",0,0,0,0,1,0,0,"dec_1016",0,0,0,0},{"name",0.3,"guide_save_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Place furniture guide",id=10340,is_close=0,over_step=0,skip=1,special_step={}},
	[10350] = {act={{"conditonstatus","homeworldscene",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.1,"guide_edit_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_furniture_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_dir_btn_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_confirm_btn_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_save_btn",0,0,0,0,1,0,0,"",0,0,0,0}},{{"checkstatus","centercity",14,0.3},{"name",0.3,"guidesign_build_14",1,0,0,0,1,0,0,"",0,0,1,0},{"homeworldscene",0.3},{"name",0.1,"guide_edit_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_furniture_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_dir_btn_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_confirm_btn_200104",0,0,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_save_btn",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Adjust the furniture guide",id=10350,is_close=0,over_step=0,skip=1,special_step={}},
	[10360] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",-20,0,0,0},{"name",0.1,"guide_effect_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"trainingcampview",0.5},{"name",2.1,"training_btn_1",0,0,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"guide_effect_btn",0,0,0,0,1,0,0,"",0,0,0,0},{"trainingcampview",0.5},{"name",2.1,"training_btn_1",0,0,0,0,1,0,0,"",0,0,0,0}}}}},desc="Novice Boot Camp Guide",id=10360,is_close=0,over_step=0,skip=1,special_step={}},
	[10370] = {act={{"mainui",0.1},{"name",0.1,"mainui_tab_5",0,0,0,0,1,0,0,"",0,0,0,0},{"esecsiceview",0.2},{"name",0.1,"guide_activity_item_3",0,0,0,0,1,0,0,"",0,0,0,100}},desc="Plane Battle Guidance",id=10370,is_close=0,over_step=0,skip=1,special_step={}},
	[10380] = {act={{"conditonstatus","partner",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"tab_btn_3",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_add_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"elfinSelectview",0.1},{"name",0.3,"guide_select_btn",0,1,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.3,"tab_btn_3",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_add_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"elfinSelectview",0.1},{"name",0.3,"guide_select_btn",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Wizard guide",id=10380,is_close=0,over_step=0,skip=1,special_step={}},
	[10382] = {act={{"conditonstatus","partner",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.3,"guide_tab_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_wish_btn",0,1,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.3,"tab_btn_3",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_tab_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_wish_btn",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Wizard capture guide",id=10382,is_close=0,over_step=0,skip=1,special_step={}},
	[10390] = {act={{"conditonstatus","partner",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.1,"hero_1",1,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"holy_equip_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_dungeon_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"heavenmainview",0.3},{"name",0.3,"guide_extract_btn_1",0,1,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.3},{"name",0.3,"guide_close_btn",0,1,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.1,"hero_1",1,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"holy_equip_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guide_dungeon_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"heavenmainview",0.3},{"name",0.3,"guide_extract_btn_1",0,1,0,0,1,0,0,"",0,0,0,0},{"getitemview",0.3},{"name",0.3,"guide_close_btn",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Jewelry prayer guide",id=10390,is_close=0,over_step=9,skip=1,special_step={}},
	[10400] = {act={{"conditonstatus","heavenmainview",0.1,{{{"emptystep"},{"emptystep"},{"emptystep"},{"emptystep"},{"name",0.1,"guide_close_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.1,"guidehloye_equip_item_1",1,0,0,0,1,0,0,"",0,0,0,0},{"equipclothview",0.3},{"name",0.1,"guildsign_equip_list_item_1",0,1,0,0,1,0,0,"",0,0,0,0}},{{"mainui",0.1},{"name",0.1,"mainui_tab_2",0,0,0,0,1,0,0,"",0,0,0,0},{"partner",0.3},{"name",0.1,"hero_1",1,0,0,0,1,0,0,"",0,0,0,0},{"partnereinfoview",0.3},{"name",0.3,"holy_equip_btn",0,1,0,0,1,0,0,"",0,0,0,0},{"name",0.3,"guidehloye_equip_item_1",0,1,0,0,1,0,0,"",0,0,0,0},{"equipclothview",0.3},{"name",0.1,"guildsign_equip_list_item_1",0,1,0,0,1,0,0,"",0,0,0,0}}}}},desc="Accessory wear guide",id=10400,is_close=0,over_step=0,skip=0,special_step={}},
	[10410] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",0,0,0,100},{"checkstatus","centercity",11,0.3},{"name",0.3,"guidesign_build_11",1,0,0,0,1,0,0,"",0,0,1,100},{"adventureactivityview",0.3},{"name",0.3,"guildadventure_activity_item_3",0,1,0,0,1,150,0,"",0,0,0,0}},{{"emptystep"},{"checkstatus","centercity",11,0.3},{"name",0.3,"guidesign_build_11",1,0,0,0,1,0,0,"",0,0,1,100},{"adventureactivityview",0.3},{"name",0.3,"guildadventure_activity_item_3",0,1,0,0,1,150,0,"",0,0,0,0}}}}},desc="Accessory copy guide",id=10410,is_close=0,over_step=0,skip=0,special_step={}},
	[10420] = {act={{"conditonstatus","checkmainui",0.1,{{{"name",0.3,"mainui_tab_1",0,0,0,0,1,0,0,"",0,0,0,100},{"checkstatus","centercity",15,0.3},{"name",0.3,"guidesign_build_15",1,0,0,0,1,0,0,"",0,0,1,100},{"heroresonateiew",0.3},{"name",1,"hero_1",0,1,0,0,1,0,0,"",0,0,0,100}},{{"emptystep"},{"checkstatus","centercity",15,0.3},{"name",0.3,"guidesign_build_15",1,0,0,0,1,0,0,"",0,0,1,100},{"heroresonateiew",0.3},{"name",1,"hero_1",0,1,0,0,1,0,0,"",0,0,0,100}}}}},desc="Force Crystal Guidance",id=10420,is_close=0,over_step=0,skip=0,special_step={}},
	[20010] = {act={{"openview","newfirstrecharge2",0.3}},desc="New version 3 first charge guide (Palkia)",id=20010,is_close=0,over_step=0,skip=1,special_step={}},
	[20020] = {act={{"openview","newfirstrecharge3",0.3}},desc="The new version of 4 first charge guide (Kyogre & Palkia)",id=20020,is_close=0,over_step=0,skip=1,special_step={}},
}
