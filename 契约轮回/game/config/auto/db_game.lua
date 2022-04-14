-- Automatically generated, do not edit
Config = Config or {}
Config.db_game = {
 ["village"]  = {key=[[village]], val=[[{11001}]], desc=[[Novice Village]]},
 ["capital"]  = {key=[[capital]], val=[[{11003}]], desc=[[Main City]]},
 ["init_money"]  = {key=[[init_money]], val=[[{[{90010004,0}]}]], desc=[[Initial Currency]]},
 ["newbie"]  = {key=[[newbie]], val=[[{1}]], desc=[[Novice Protection Level]]},
 ["newbie_60007"]  = {key=[[newbie_60007]], val=[[{{6474,8131}}]], desc=[[Novice: Spider Dungeon]]},
 ["newbie_scene"]  = {key=[[newbie_scene]], val=[[{1}]], desc=[[Novice: Map Resource]]},
 ["role_amount"]  = {key=[[role_amount]], val=[[{4}]], desc=[[Max Characters]]},
 ["role_name"]  = {key=[[role_name]], val=[[{{1,20}}]], desc=[[Role Name Length]]},
 ["role_speed"]  = {key=[[role_speed]], val=[[{445}]], desc=[[Original Speed]]},
 ["mail_last"]  = {key=[[mail_last]], val=[[{20}]], desc=[[Save Time]]},
 ["mail_amount"]  = {key=[[mail_amount]], val=[[{150}]], desc=[[Max Mails]]},
 ["gray_crime"]  = {key=[[gray_crime]], val=[[{10}]], desc=[[Grey Name: Crime Value]]},
 ["red_crime"]  = {key=[[red_crime]], val=[[{20}]], desc=[[Red Name: Crime Value]]},
 ["guild_name"]  = {key=[[guild_name]], val=[[{{2,12}}]], desc=[[Guild Name Length]]},
 ["guild_notice"]  = {key=[[guild_notice]], val=[[{"Dear Players: \n1. Everyone in the guild has benefits, you can receive it every day (baby has extra benefits) \n2. The guild warehouse can exchange gears with others \n3. Team leader challenge, loot gear materials \n4. Don't miss the guild activities, in addition to producing a lot of  bound diamond/gears"}]], desc=[[Default Guild Notice]]},
 ["guild_apply"]  = {key=[[guild_apply]], val=[[{5}]], desc=[[Max guild applications]]},
 ["guild_impeach"]  = {key=[[guild_impeach]], val=[[{172800}]], desc=[[Report Time]]},
 ["guild_demise"]  = {key=[[guild_demise]], val=[[{172800}]], desc=[[Auto-transfer Time]]},
 ["guild_grain"]  = {key=[[guild_grain]], val=[[{100}]], desc=[[1 Food=1 Fund]]},
 ["guild_modify"]  = {key=[[guild_modify]], val=[[{{999999, [{90010004,10}]}}]], desc=[[Edit Notice]]},
 ["guild_rename"]  = {key=[[guild_rename]], val=[[{[{11003,1}]}]], desc=[[Guild Rename Cost]]},
 ["guild_quit_limit"]  = {key=[[guild_quit_limit]], val=[[{[10221,12003]}]], desc=[[Exit Limit]]},
 ["equip_suite_color"]  = {key=[[equip_suite_color]], val=[[{2}]], desc=[[Min Requirement for Set Quality]]},
 ["equip_suite_star"]  = {key=[[equip_suite_star]], val=[[{2}]], desc=[[Min Requirement for Set Stars]]},
 ["wing_openlv"]  = {key=[[wing_openlv]], val=[[{40}]], desc=[[Wing Unlock Level]]},
 ["talis_openlv"]  = {key=[[talis_openlv]], val=[[{85}]], desc=[[Talisman Unlock Level]]},
 ["weapon_openlv"]  = {key=[[weapon_openlv]], val=[[{180}]], desc=[[Artifact Unlock Level]]},
 ["boss_tired"]  = {key=[[boss_tired]], val=[[{3}]], desc=[[Max World Boss Fatigue]]},
 ["boss_anger"]  = {key=[[boss_anger]], val=[[{100}]], desc=[[Max Field Boss Fatigue]]},
 ["boss_anger_kill"]  = {key=[[boss_anger_kill]], val=[[{10}]], desc=[[Death Rage (Field&Pet Boss)]]},
 ["boss_anger_interval"]  = {key=[[boss_anger_interval]], val=[[{60}]], desc=[[+X Rage/s]]},
 ["boss_anger_increase"]  = {key=[[boss_anger_increase]], val=[[{1}]], desc=[[+X Rage/times]]},
 ["boss_anger_kickout"]  = {key=[[boss_anger_kickout]], val=[[{30}]], desc=[[Exit Map Rage]]},
 ["revive_tired"]  = {key=[[revive_tired]], val=[[{60}]], desc=[[Fatigue Revive CD]]},
 ["beast_tired"]  = {key=[[beast_tired]], val=[[{3}]], desc=[[Max Beast Island Boss Fatigue]]},
 ["beast_collect"]  = {key=[[beast_collect]], val=[[{2}]], desc=[[Max Crystal (L) Collections]]},
 ["beast_collect2"]  = {key=[[beast_collect2]], val=[[{20}]], desc=[[Max Crystal (S) Collections]]},
 ["jobtitle_openlv"]  = {key=[[jobtitle_openlv]], val=[[{110}]], desc=[[Unlock Level]]},
 ["target_openlv"]  = {key=[[target_openlv]], val=[[{40}]], desc=[[Opening level]]},
 ["mchunt_last"]  = {key=[[mchunt_last]], val=[[{900}]], desc=[[Treasure Hunt Time]]},
 ["mchunt_power_max"]  = {key=[[mchunt_power_max]], val=[[{400}]], desc=[[Max Star Power]]},
 ["mchunt_power_gap"]  = {key=[[mchunt_power_gap]], val=[[{3600}]], desc=[[Star Power Interval]]},
 ["mchunt_power_add"]  = {key=[[mchunt_power_add]], val=[[{8}]], desc=[[+ Star Power/times]]},
 ["mchunt_skip"]  = {key=[[mchunt_skip]], val=[[{240}]], desc=[[Unlock: Pass by]]},
 ["mchunt_maxtimes"]  = {key=[[mchunt_maxtimes]], val=[[{9999}]], desc=[[Max Treasure Huntings]]},
 ["market_last"]  = {key=[[market_last]], val=[[{86400}]], desc=[[Sale Time]]},
 ["drop_unlock"]  = {key=[[drop_unlock]], val=[[{30}]], desc=[[Unguard the scene after how many seconds have dropped]]},
 ["drop_remove"]  = {key=[[drop_remove]], val=[[{120}]], desc=[[The scene is removed after how many seconds have dropped]]},
 ["drop_gap"]  = {key=[[drop_gap]], val=[[{65}]], desc=[[Drop CD]]},
 ["drop_round1"]  = {key=[[drop_round1]], val=[[{{4,0,[{0,2},{-2,0},{0,-2},{2,0}]}}]], desc=[[Drop Circle 1]]},
 ["drop_round2"]  = {key=[[drop_round2]], val=[[{{8,0,[{-2,2},{-3,1},{-3,-1},{-2,-2},{2,-2},{3,-1},{3,1},{3,2}]}}]], desc=[[Drop Circle 2]]},
 ["drop_round3"]  = {key=[[drop_round3]], val=[[{{14,0,[{-3,3},{-4,2},{-4,0},{-4,-2},{-3,-3},{3,-3},{4,-2},{4,0},{4,2},{3,3},{-1,3},{1,3},{1,-3},{-1,-3}]}}]], desc=[[Drop Circle 3]]},
 ["drop_round4"]  = {key=[[drop_round4]], val=[[{{18,0,[{-4,4},{-5,3},{-5,-3},{-4,-4},{4,-4},{5,-3},{5,3},{4,4},{-5,-1},{-5,1},{5,1},{5,-1},{2,4},{-2,4},{2,-4},{-2,-4},{0,4},{0,-4}]}}]], desc=[[Drop Circle 4]]},
 ["drop_round5"]  = {key=[[drop_round5]], val=[[{{12,0,[{-7,1},{-7,-1},{7,1},{7,-1},{-6,2},{-6,0},{-6,-2},{6,2},{6,0},{6,-2}]}}]], desc=[[Drop Circle 5]]},
 ["daily_openlv"]  = {key=[[daily_openlv]], val=[[{54}]], desc=[[Unlock Level for Daily Quest]]},
 ["assist_honor"]  = {key=[[assist_honor]], val=[[{2000}]], desc=[[Assist Glory]]},
 ["assist_honor_limit"]  = {key=[[assist_honor_limit]], val=[[{6000}]], desc=[[Assist Glory Cap]]},
 ["assist_intimacy"]  = {key=[[assist_intimacy]], val=[[{10}]], desc=[[Assist Intimacy]]},
 ["assist_intimacy_limit"]  = {key=[[assist_intimacy_limit]], val=[[{30}]], desc=[[Assist Intimacy Cap]]},
 ["guildwar_daily_reward"]  = {key=[[guildwar_daily_reward]], val=[[{[{10015,1,1},{15062,1,1},{90010005,500000,1}]}]], desc=[[Daily reward for Guild War]]},
 ["guildwar_chief_buff"]  = {key=[[guildwar_chief_buff]], val=[[{120510001}]], desc=[[Leader Buff for Guild War]]},
 ["guildwar_chief_reward"]  = {key=[[guildwar_chief_reward]], val=[[{[{46025,1,1},{13500,1,1}]}]], desc=[[Display Leader Rewards]]},
 ["guildwar_chief_reward2"]  = {key=[[guildwar_chief_reward2]], val=[[{[{46025,1,1},{13500,1,1}]}]], desc=[[Leader Rewards]]},
 ["guildwar_zone_name"]  = {key=[[guildwar_zone_name]], val=[[{[{1,"God"}, {2,"Saint"}, {3,"Heaven"}, {4,"Earth"}, {5,"Common"}]}]], desc=[[Zone Name]]},
 ["guildwar_score_occupy"]  = {key=[[guildwar_score_occupy]], val=[[{500}]], desc=[[Personal Pts for Occupation]]},
 ["guildwar_score_kill"]  = {key=[[guildwar_score_kill]], val=[[{100}]], desc=[[Personal Pts]]},
 ["guildwar_score_winner"]  = {key=[[guildwar_score_winner]], val=[[{2000}]], desc=[[Personal Pts]]},
 ["guildwar_score_max"]  = {key=[[guildwar_score_max]], val=[[{5000}]], desc=[[Guild War Winner Pts]]},
 ["guildwar_score_notify"]  = {key=[[guildwar_score_notify]], val=[[{[1000,2000,3500,4500]}]], desc=[[Guild War Notice Pts]]},
 ["guildwar_show_reward"]  = {key=[[guildwar_show_reward]], val=[[{[{53102,1,1},{46025,1,1},{13500,1,1}]}]], desc=[[Display Guild War Rewards]]},
 ["guildwar_join"]  = {key=[[guildwar_join]], val=[[{7200}]], desc=[[Guild War Time]]},
 ["afk_logout"]  = {key=[[afk_logout]], val=[[{300}]], desc=[[Auto idle]]},
 ["afk_max_time"]  = {key=[[afk_max_time]], val=[[{72000}]], desc=[[Max Idle Time]]},
 ["smelt_lv"]  = {key=[[smelt_lv]], val=[[{70}]], desc=[[Smelt Level]]},
 ["guild_house_enter_time"]  = {key=[[guild_house_enter_time]], val=[[{900}]], desc=[[Join Time]]},
 ["guild_question_num"]  = {key=[[guild_question_num]], val=[[{20}]], desc=[[Quests]]},
 ["guild_house_loop_exp"]  = {key=[[guild_house_loop_exp]], val=[[{{90010018,120}}]], desc=[[EXP earned every 10 sec in preparation scene]]},
 ["guild_house_boss_coord"]  = {key=[[guild_house_boss_coord]], val=[[{{3800,3500}}]], desc=[[Boss coordinate]]},
 ["qes_right_reward"]  = {key=[[qes_right_reward]], val=[[{[{90010019,720}]}]], desc=[[Right Reward]]},
 ["qes_wrong_reward"]  = {key=[[qes_wrong_reward]], val=[[{[{90010019,360}]}]], desc=[[Wrong Reward]]},
 ["vip_mcard"]  = {key=[[vip_mcard]], val=[[{{90010003,300}}]], desc=[[Monthly Card Cost:]]},
 ["vip_exppool_auto"]  = {key=[[vip_exppool_auto]], val=[[{300}]], desc=[[Auto-claim Exp]]},
 ["vip_rebate"]  = {key=[[vip_rebate]], val=[[{604800}]], desc=[[Return Time]]},
 ["guild_guard_join"]  = {key=[[guild_guard_join]], val=[[{0}]], desc=[[Time requirement for joining guild guard (seconds)]]},
 ["guild_guard_succ"]  = {key=[[guild_guard_succ]], val=[[{[{90010019,9600}]}]], desc=[[Success Rewards]]},
 ["guild_guard_fail"]  = {key=[[guild_guard_fail]], val=[[{[{90010019,4800}]}]], desc=[[Failure Reward]]},
 ["guild_guard_assault_interval"]  = {key=[[guild_guard_assault_interval]], val=[[{300}]], desc=[[Attack interval (sec)]]},
 ["guild_guard_assault_total"]  = {key=[[guild_guard_assault_total]], val=[[{4}]], desc=[[Attack Waves]]},
 ["guild_guard_main_id"]  = {key=[[guild_guard_main_id]], val=[[{30381003}]], desc=[[Core NPC ID]]},
 ["dunge_magic"]  = {key=[[dunge_magic]], val=[[{200}]], desc=[[Highest Floor]]},
 ["first_dunge_equip"]  = {key=[[first_dunge_equip]], val=[[{{1111004}}]], desc=[[Quest Id]]},
 ["wake_cost"]  = {key=[[wake_cost]], val=[[{[300,600,1000]}]], desc=[[Quick Awaken Cost]]},
 ["dunge_worldboss"]  = {key=[[dunge_worldboss]], val=[[{1109003}]], desc=[[World Boss Quest ID]]},
 ["magiccard_com"]  = {key=[[magiccard_com]], val=[[{51}]], desc=[[Unlock Floor]]},
 ["level_max"]  = {key=[[level_max]], val=[[{370}]], desc=[[Peak Level]]},
 ["role_rename"]  = {key=[[role_rename]], val=[[{[{11002,1}]}]], desc=[[Rename Cost]]},
 ["world_chat_lv"]  = {key=[[world_chat_lv]], val=[[{100}]], desc=[[You need X to talk in the world channel]]},
 ["realname_timeout"]  = {key=[[realname_timeout]], val=[[{18000}]], desc=[[Earnings halved]]},
 ["realname_trigger_buff"]  = {key=[[realname_trigger_buff]], val=[[{130150016}]], desc=[[Countdown Buff]]},
 ["realname_decay_buff"]  = {key=[[realname_decay_buff]], val=[[{130150017}]], desc=[[Earnings halved Buff]]},
 ["dunge_merge_cost"]  = {key=[[dunge_merge_cost]], val=[[{[{90010004,5}]}]], desc=[[Combine Stage Unite Price]]},
 ["meleewar_max_damage"]  = {key=[[meleewar_max_damage]], val=[[{75}]], desc=[[Max DMG]]},
 ["dunge_god_escape"]  = {key=[[dunge_god_escape]], val=[[{{289,548}}]], desc=[[end point]]},
 ["shop_boss"]  = {key=[[shop_boss]], val=[[{{-250,-50}}]], desc=[[Boss Position]]},
 ["shop_boss_scene"]  = {key=[[shop_boss_scene]], val=[[{{312,401,402,403,405,307,406}}]], desc=[[Boss Position 【World Boss, Home Boss, personal Boss and so on】]]},
 ["boss_drop_limit"]  = {key=[[boss_drop_limit]], val=[[{[]}]], desc=[[NO Drop if player level - boss level >=100]]},
 ["timeboss_rank_times"]  = {key=[[timeboss_rank_times]], val=[[{3}]], desc=[[Daily Ranks]]},
 ["timeboss_join_times"]  = {key=[[timeboss_join_times]], val=[[{3}]], desc=[[Daily Battles]]},
 ["timeboss_shield_reduce"]  = {key=[[timeboss_shield_reduce]], val=[[{10000}]], desc=[[Shield Value]]},
 ["timeboss_shield_injure"]  = {key=[[timeboss_shield_injure]], val=[[{{500,3}}]], desc=[[HP Value]]},
 ["timeboss_dice_last"]  = {key=[[timeboss_dice_last]], val=[[{10}]], desc=[[Dice Time]]},
 ["timeboss_box_owner"]  = {key=[[timeboss_box_owner]], val=[[{3}]], desc=[[Obtain Chest]]},
 ["timeboss_shield_num"]  = {key=[[timeboss_shield_num]], val=[[{200000}]], desc=[[Sheild Value]]},
 ["max_anger"]  = {key=[[max_anger ]], val=[[{100}]], desc=[[Max Rage]]},
 ["siegeboss_shield_reduce"]  = {key=[[siegeboss_shield_reduce]], val=[[{10000}]], desc=[[Shield Value]]},
 ["siegeboss_shield_injure"]  = {key=[[siegeboss_shield_injure]], val=[[{{500,3}}]], desc=[[HP Value]]},
 ["siegeboss_shield_num"]  = {key=[[siegeboss_shield_num]], val=[[{200000}]], desc=[[Sheild Value]]},
 ["siegeboss_max_blood"]  = {key=[[siegeboss_max_blood]], val=[[{85}]], desc=[[Not over 5%]]},
 ["siegewar_win_score"]  = {key=[[siegewar_win_score]], val=[[{115}]], desc=[[Siege War Winner Pts]]},
 ["siegeboss_tired"]  = {key=[[siegeboss_tired]], val=[[{8}]], desc=[[Siege War Fatigue]]},
 ["siegewar_occupy_reward"]  = {key=[[siegewar_occupy_reward]], val=[[{200}]], desc=[[Siege War Rewarded Level]]},
 ["siegewar_divide"]  = {key=[[siegewar_divide]], val=[[{[{1,{2,11}},{2,{12,22}},{3,{23,27}}]}]], desc=[[夺城战3阶段时间，配置格式[{1, {最小开服天数,最大开服天数}}]，对应siegeboss里的divide字段]]},
 ["support"]  = {key=[[support]], val=[[{{-170,-50}}]], desc=[[请求支援图标出现的位置]]},
 ["support_boss"]  = {key=[[support_boss]], val=[[{{401,402,405,406}}]], desc=[[请求支援出现的子场景【世界首领，首领之家，幻之岛，跨服BOSS】]]},
 ["merge_delete"]  = {key=[[merge_delete]], val=[[{[{level,100}, {vip,2}, {login,7}]}]], desc=[[低于level, vip，且大于login天未登录的玩家将被删除]]},
 ["welfare_misc"]  = {key=[[welfare_misc]], val=[[{[{1,[{90010004,150},{10015,1},{90010005,1000000}]},{2,[{90010004,30},{54112,1},{90010005,500000}]},{3,[{90010004,50},{11006,1},{90010005,500000}]},{4,[{90010004,500}]},{5,[{10017,1},{11006,10},{90010004,200},{90010005,2000000}]}]}]], desc=[[1=评论、2=分享、3=点赞、4=绑定、5=累计注册奖励]]},
 ["throne_unlock_score"]  = {key=[[throne_unlock_score]], val=[[{100}]], desc=[[Throne of Star-Needed points to unlock Pegasus]]},
 ["market_monitor"]  = {key=[[market_monitor]], val=[[{{5000, 5000}}]], desc=[[市场交易数额监控 {获得钻石数,消耗钻石数}]]},
 ["market_money"]  = {key=[[market_money]], val=[[{[{twkr,90010035},{twft,90010035},{twen,90010035},{tanwan,90010035},{r2vn,90010035}]}]], desc=[[市场交易货币]]},
 ["richman_dice"]  = {key=[[richman_dice]], val=[[{[{1,200},{2,200},{3,400},{4,600},{5,450},{6,280}]}]], desc=[[Richman Dice Weight]]},
 ["richman_dice_limit"]  = {key=[[richman_dice_limit]], val=[[{[{1,4},{2,4},{3,4},{4,4},{5,4},{6,4},{7,4},{8,4},{9,4},{10,4},{11,4},{12,4},{13,4},{14,4},{15,4}]}]], desc=[[Richman Dice Upper Limit]]},
 ["richman_dice_mend"]  = {key=[[richman_dice_mend]], val=[[{[{1,300},{2,300},{3,300},{4,500},{5,500},{6,500},{7,800},{8,800},{9,800},{10,800},{11,1000},{12,1000},{13,1000},{14,1000},{15,1000},{16,1500},{17,1500},{18,1500},{19,1500},{20,1500},{21,1500},{22,1500},{23,1500},{24,1500},{25,1500},{26,1500},{27,1500},{28,1500},{29,1500},{30,1500},{31,1500},{32,1500},{33,1500},{34,1500},{35,1500},{36,1500},{37,1500},{38,1500},{39,1500},{40,1500},{41,1500},{42,1500},{43,1500},{44,1500},{45,1500},{46,1500},{47,1500},{48,1500},{49,1500},{50,1500},{51,1500},{52,1500},{53,1500},{54,1500},{55,1500},{56,1500},{57,1500},{58,1500},{59,1500},{60,1500}]}]], desc=[[Richman Dice Resign Price]]},
 ["cgw_base_score"]  = {key=[[cgw_base_score]], val=[[{1000}]], desc=[[  初始分数]]},
 ["cgw_book_times1"]  = {key=[[cgw_book_times1]], val=[[{3}]], desc=[[  可预约次数]]},
 ["cgw_book_times2"]  = {key=[[cgw_book_times2]], val=[[{5}]], desc=[[  可被预约次数]]},
 ["cgw_creeps"]  = {key=[[cgw_creeps]], val=[[{[{20702011,874,2091},{20702013,2693,3130},{20702012,3855,4132}]}]], desc=[[{怪物id, x, y}]]},
 ["cgw_repair"]  = {key=[[cgw_repair]], val=[[{[{20702014,20702011},{20702015,20702012}]}]], desc=[[{采集物id, 水晶id}]]},
 ["cgw_book_score"]  = {key=[[cgw_book_score]], val=[[{[{1,200},{2,250},{3,300},{4,350},{5,400}]}]], desc=[[{第几次被预约,所需积分}]]},
 ["cgw_merge_reward"]  = {key=[[cgw_merge_reward]], val=[[{[{90010011,10000},{13170,15}]}]], desc=[[Server Merge Rimbursement]]},
 ["cgw_divide_reward"]  = {key=[[cgw_divide_reward]], val=[[{[{90010011,10000},{13170,15}]}]], desc=[[Cross Month Rimbursement]]},
 ["luckluck"]  = {key=[[luckluck]], val=[[{8}]], desc=[[幸运转盘最大数]]},
 ["fissure_refresh_boss"]  = {key=[[fissure_refresh_boss]], val=[[{[{20901011, [20901001,20901002]},{20901012, [20901003,20901004]},{20901013, [20901001,20901002,20901003,20901004]},{20901014, [20901001,20901002,20901003,20901004]},{20901015, [20901005,20901006]},{20901016, [20901007,20901008]},{20901017, [20901005,20901006,20901007,20901008]},{20901018, [20901005,20901006,20901007,20901008]},{20902011, [20902001,20902002]},{20902012, [20902003,20902004]},{20902013, [20902001,20902002,20902003,20902004]},{20902014, [20902001,20902002,20902003,20902004]},{20902015, [20902005,20902006]},{20902016, [20902007,20902008]},{20902017, [20902005,20902006,20902007,20902008]},{20902018, [20902005,20902006,20902007,20902008]}]}]], desc=[[Time Rift Hiden Boss Refresh Requirements]]},
 ["flop_gift"]  = {key=[[flop_gift]], val=[[{[101,402,403]}]], desc=[[翻牌好礼-背包满后清包再抽]]}
}
