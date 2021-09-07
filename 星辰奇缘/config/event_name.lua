-- 全局事件
-- 模块内部事件可以使用EventLib类处理
event_name = event_name or {}

event_name.gamestart_before_init = "gamestart_before_init"
event_name.gamestart_end_init = "gamestart_end_init"

event_name.socket_connect = "socket_connect"
event_name.socket_disconnect = "socket_disconnect"
event_name.socket_reconnect = "socket_disconnect"

event_name.logined = "logined"
event_name.world_lev_change = "world_lev_change"

event_name.self_loaded = "self_loaded"

--系统重新激活
event_name.sleepmanager_onresume = "sleepmanager_onresume"

-- 系统设置改变
event_name.setting_change = "setting_change"

-- 跨服状态改变
event_name.cross_type_change = "cross_type_change"

event_name.role_name_change = "role_name_change"
--角色属性变化
event_name.role_attr_change = "role_attr_change"
--角色加点方案改变
event_name.role_attr_option_change = "role_attr_option_change"
-- 角色资产变化
event_name.role_asset_change = "role_asset_change"
-- 角色经验变化
event_name.role_exp_change = "role_exp_change"
-- 角色等级变化
event_name.role_level_change = "role_level_change"
-- 角色event变化
event_name.role_event_change = "role_event_change"
-- 角色status变化
event_name.role_status_change = "role_status_change"
-- 角色ride变化
event_name.role_ride_change = "role_ride_change"
-- 角色looks变化
event_name.role_looks_change = "role_looks_change"
-- 角色翅膀变化
event_name.role_wings_change = "role_wings_change"
-- 出战宠物变化
event_name.battlepet_update = "battlepet_update"
-- 宠物更新
event_name.pet_update = "pet_update"
--宠物符石更新
event_name.pet_stone_update = "pet_stone_update"
-- 技能更新
event_name.skill_update = "skill_update"
-- 主界面Canvas加载完成
event_name.mainui_loaded = "mainui"
-- 点击地图
event_name.map_click = "map_click"
-- 开始场景跳转
event_name.start_scene_load = "start_scene_load"
-- 场景跳转完成
event_name.scene_load = "scene_load"
-- 场景Npc列表更新
event_name.npc_list_update = "npc_list_update"
-- 背包道具变化
event_name.backpack_item_change = "backpack_item_change"
-- 装备道具变化
event_name.equip_item_change = "equip_item_change"
-- 任务更新
event_name.quest_update = "quest_update"
-- 队伍创建
event_name.team_create = "team_create"
-- 队伍离开
event_name.team_leave = "team_leave"
-- 组队大厅更新
event_name.team_hall_update = "team_hall_update"
-- 队伍列表更新，邀请，申请
event_name.team_list_update = "team_list_update"
event_name.team_match_list = "team_match_list"
-- 队伍取消匹配
event_name.team_update_match = "team_update_match"
-- 队伍队员状态更新
event_name.team_update = "team_update"
-- 队伍信息更新
event_name.team_info_update = "team_info_update"
-- 队伍位置改变
event_name.team_position_change = "team_position_change"
-- 阵法更新
event_name.formation_update = "formation_update"
-- 阵法守护位置改变
event_name.guard_position_change = "guard_position_change"
-- 阵法，守护换位置
event_name.guard_position_change = "guard_position_change"
-- 守护招募成功
event_name.guard_recruit_success = "guard_recruit_success"
-- 阵法升级
event_name.formation_levelup = "formation_levelup"

--段位赛匹配状态更新
event_name.qualify_state_update = "qualify_state_update"
--段位赛剩余时间更新
event_name.qualify_time_update = "qualify_time_update"
-- 战斗结束
event_name.end_fight = "end_fight"
-- 服务端战斗结束
event_name.server_end_fight = "server_end_fight"
-- 战斗开始
event_name.begin_fight = "begin_fight"
-- 战斗回合开始
event_name.begin_fight_round = "begin_fight_round"
-- 锻造重铸装备属性请求返回
event_name.equip_strength_attr_back = "equip_strength_attr_back"
-- 装备洗练属性请求返回
event_name.equip_strength_trans_attr_back = "equip_strength_trans_attr_back"
--锻造装备右边属性返回
event_name.equip_build_attr_back = "equip_build_attr_back"
-- 装备强化材料放入
event_name.equip_strength_materail_put = "equip_strength_materail_put"
-- 宠物卸下装备
event_name.petgemoff = "petgemoff"
-- 宠物替换装备
event_name.petgemreplace = "petgemreplace"
-- 极寒试炼更新
event_name.trial_update = "trial_update"
-- 成功加入公会
event_name.enter_guild_succ = "enter_guild_succ"
-- 离开公会
event_name.leave_guild_succ = "leave_guild_succ"
-- 藏宝图更新
event_name.treasuremap_update = "treasuremap_update"
-- 藏宝图指南针更新
event_name.treasuremap_compass_update = "treasuremap_compass_update"
-- 主UI图标加载完
event_name.mainui_btn_init = "mainui_btn_init"
-- 主UI提示加载完
event_name.mainui_notice_init = "mainui_notice_init"
-- 主UI提示更新
event_name.mainui_notice_update = "mainui_notice_update"
--称号更新
event_name.honor_update = "honor_update"
--生活技能数据更新
event_name.life_skill_update = "life_skill_update"
--传送到某个场景成功
event_name.trasport_success = "trasport_success"
--玩家身上的Buff更新
event_name.buff_update = "buff_update"
--追踪面板加载完成
event_name.trace_quest_loaded = "trace_quest_loaded"
--追踪面板隐藏
event_name.trace_quest_hide = "trace_quest_hide"
--追踪面板显示
event_name.trace_quest_show = "trace_quest_show"
--掉落途径开始寻路npc
event_name.drop_findnpc = "drop_findnpc"
-- 采集取消通知
event_name.cancel_colletion = "cancel_colletion"
-- 有公会成员数据更新
event_name.guild_member_update = "guild_member_update"
-- 同场景传送成功
event_name.current_trasport_succ = "current_trasport_succ"
-- 仓库道具变化
event_name.store_item_change = "store_item_change"
-- 家园仓库道具变化
event_name.home_store_item_change = "home_store_item_change"
--宠物仓库数据变化
event_name.petstore_update = "pet_store_update"
-- 自定义键盘返回
event_name.input_dialog_callback = "input_dialog_callback"
-- 活动变化
event_name.campaign_change = "campaign_change"
--套娃数据更新
event_name.dolls_data_update = "dolls_data_update"
--套娃打开
event_name.dolls_open_back = "dolls_open_back"
--周年兑换活动数据变更
event_name.cake_exchange_data_update = "cake_exchange_data_update"
-- 在线奖励发生变化
event_name.onlinereward_change = "onlinereward_change"
-- 配偶信息返回
event_name.lover_data = "lover_data"
-- 典礼数据更新
event_name.marry_data_update = "marry_data_update"
--公会战数据更新
event_name.guild_fight_data_update = "guild_fight_data_update"
--公会战状态更新
event_name.guild_fight_status_update = "guild_fight_status_update"
-- 塔奖励更新
event_name.tower_reward_update = "tower_reward_update"
-- 特权等级变化
event_name.privilege_lev_change = "privilege_lev_change"
-- 小聊天窗大小改变
event_name.chat_mini_size_change = "chat_mini_size_change"
-- 大聊天窗显示隐藏
event_name.chat_main_show = "chat_main_show"
-- 大聊天窗置顶面版更新
event_name.chat_main_top_update = "chat_main_top_update"
-- 公会宝箱库存发生变化
event_name.guild_box_count_change = "guild_box_count_change"
-- 限制特惠时间发生变化
event_name.limit_time_privilege_change = "limit_time_privilege_change"
--师徒信息更新
event_name.teahcer_student_info_change = "teahcer_student_info_change"
--成员战绩信息变化
event_name.guild_war_role = "guild_war_role"
--好友变化
event_name.friend_update = "friend_update"
--公会精英战活动信息变化
event_name.guildfight_elite_acitveinfo_change = "guildfight_elite_acitveinfo_change"
--公会精英战领队信息变化
event_name.guildfight_elite_leaderinfo_change = "guildfight_elite_leaderinfo_change"
--公会精英对战信息变化
event_name.guild_elite_war_match_info_change = "guild_elite_war_match_info_change"
--空间主题更新
event_name.zone_theme_update = "zone_theme_update"
--空间相框更新
event_name.zone_frame_update = "zone_frame_update"
--空间徽章更新
event_name.zone_badge_update = "zone_badge_update"
--空间荣耀更新
event_name.zone_bigbadge_update = "zone_bigbadge_update"
--每日祝福更新
event_name.daily_horoscope_update = "daily_horoscope_update"
--每日祝福更新特效
event_name.daily_horoscope_effect_update = "daily_horoscope_effect_update"
--装备重铸值变化
event_name.equip_build_resetval_update = "equip_build_resetval_update"
--装备洗练保存成功
event_name.equip_build_resetval_save_ok = "equip_build_resetval_save_ok"
--彩蛋数据更新
event_name.mystical_eggs_info_update = "mystical_eggs_info_update"
--彩蛋投掷更新
event_name.mystical_eggs_roll_update = "mystical_eggs_roll_update"
--福袋数据更新
event_name.welfare_bags_info_update = "welfare_bags_info_update"
--领取活动奖励成功
event_name.get_campaign_reward_success = "get_campaign_reward_success"
--跨服组队状态改变
event_name.team_cross_change = "team_cross_change"
--符石洗炼成功
event_name.pet_stone_wash_succ = "pet_stone_wash_succ"
--符石洗炼保存成功
event_name.pet_stone_wash_save_succ = "pet_stone_wash_save_succ"
--神器洗练成功
event_name.equip_dianhua_success = "equip_dianhua_success"
--装备备用属性请求成功
event_name.equip_last_lev_attr_back = "equip_last_lev_attr_back"
--武道会排行榜数据变化
event_name.no1world_rank_data_change = "no1world_rank_data_change"
--装备备用属性更新
event_name.equip_last_lev_attr_update = "equip_last_lev_attr_update"
--人物加点方案预览返回
event_name.role_point_preview_back = "role_point_preview_back"
--水果种植更新
event_name.summer_fruit_plant_update = "summer_fruit_plant_update"
--暑期登录更新
event_name.summer_login_update = "summer_login_update"
--家园 canvas创建完成
event_name.home_canvas_inited = "home_canvas_inited"
--家园 家具出库
event_name.home_warehouse_out = "home_warehouse_out"
--家园 家具仓库更新
event_name.home_warehouse_update = "home_warehouse_update"
--家园 家具建筑更新
event_name.home_build_update = "home_build_update"
--家园 家具商店更新
event_name.home_shop_update = "home_shop_update"
--家园 基础信息更新
event_name.home_base_update = "home_base_update"
--家园 宠物训练更新
event_name.home_train_info_update = "home_train_info_update"
--家园 使用次数更新
event_name.home_use_info_update = "home_use_info_update"
--家园 好友、公会成员信息更新
event_name.home_visit_info_update = "home_use_info_update"

event_name.role_point_preview_back = "role_point_preview_back"
--捉迷藏领奖刷新
event_name.seek_child_finish_refresh = "seek_child_finish_refresh"
-- 好声音列表更新
event_name.sing_list_update = "sing_list_update"
-- 好声音关注列表更新
event_name.sing_follow_update = "sing_follow_update"
-- 好声音排行榜列表更新
event_name.sing_ranklist_update = "sing_ranklist_update"
-- 好声音音频播放状态
event_name.sing_playing_status = "sing_playing_status"
-- 家园豌豆信息更新
event_name.home_bean_info_update = "home_base_update"
-- 更新家园正在编辑家具数量
event_name.home_eidt_num_update = "home_eidt_num_update"
-- 更新现金礼包界面信息
event_name.update_cash_gift_info = "update_cash_gift_info"
-- 一闷夺宝主界面更新
event_name.lottery_main_update = "lottery_main_update"
-- 一闷夺宝已揭晓更新
event_name.lottery_over_update = "lottery_over_update"
-- 夺宝关注更新
event_name.lottery_focus_update = "lottery_focus_update"
-- 后台活动更新
event_name.backend_campaign_change = "backend_campaign_change"
-- 一元夺宝我的号码列表更新
event_name.lottery_my_num_update = "lottery_my_num_update"
-- 幻化手册切换自动幻化
event_name.handbook_autochange = "handbook_autochange"
-- 幻化手册信息更新
event_name.handbook_infoupdate = "handbook_infoupdate"
-- 金币市场数据更新
event_name.market_gold_update = "market_gold_update"
-- 月度礼包
event_name.monthly_gift_change = "monthly_gift_change"
-- 宠物学习技能书
event_name.pet_sure_useskillbook = "pet_sure_useskillbook"
-- 幻化手册商城列表更新
event_name.handbook_shopupdate = "handbook_shopupdate"
-- 月度礼包
event_name.monthly_gift_change = "monthly_gift_change"
-- 分享信息更新
event_name.share_info_update = "share_info_update"
-- 分享奖励更新
event_name.share_reward_update = "share_reward_update"
-- 自定义头像更新
event_name.custom_portrait_update = "custom_portrait_update"
-- 国庆活动保卫蛋糕数据更新
event_name.nationalday_defense_update = "nationalday_defense_update"
-- 国庆抽奖奖池更新
event_name.nationalday_rewardpool_update = "nationalday_rewardpool_update"
-- 国庆抽奖结果更新
event_name.nationalday_rewardresult_update = "nationalday_rewardresult_update"
-- 国庆十连抽事件
event_name.nationalday_roll10 = "nationalday_roll10"

-- 双11团购数据更新
event_name.double_eleven_groupbuy_update = "double_eleven_groupbuy_update"

-- 转职成功通知（纯通知，不做数据处理）
event_name.change_classes_success = "change_classes_success"
-- 转职价格
event_name.change_classes_price = "change_classes_price"
-- 职业改变了(做数据处理)
event_name.change_classes = "change_classes"
-- 宝石转换成功通知
event_name.gem_change_success = "gem_change_success"
-- 宝物转换成功通知
event_name.talis_change_success = "talis_change_success"
-- 万圣节南瓜精活动排行更新
event_name.halloween_rank_update = "halloween_rank_update"
-- 万圣节南瓜精活动死亡倒计时
event_name.halloween_self_dead_tips = "halloween_self_dead_tips"
-- 万圣节南瓜精活动匹配更新
event_name.halloween_match_update = "halloween_match_update"
-- 诸神之战信息战队信息更新
event_name.godswar_team_update = "godswar_team_update"
-- 诸神之战可邀请列表更新
event_name.godswar_apply_update = "godswar_apply_update"
-- 诸神之战战队列表更新
event_name.godswar_list_update = "godswar_list_update"
-- 诸神之战分组列表更新
event_name.godswar_match_update = "godswar_match_update"
-- 诸神之战历史数据更新
event_name.godswar_history_update = "godswar_history_update"
-- 诸神之战历史选择届数更新
event_name.godswar_his_select_seasom_update = "godswar_his_select_seasom_update"
-- 诸神之战下拉更新
event_name.godswar_select_update = "godswar_select_update"
-- 诸神之战对手信息更新
event_name.godswar_fighter_update = "godswar_fighter_update"
-- 诸神之战准备状态变化
event_name.godswar_ready_update = "godswar_ready_update"
-- 诸神之战倒计时变化
event_name.godswar_time_update = "godswar_time_update"
-- 诸神之战战斗结果更新
event_name.godswar_fightresult_update = "godswar_fightresult_update"
-- 诸神之战录像数据更新
event_name.godswar_video_update = "godswar_video_update"
-- 诸神投票更新
event_name.godswar_vote_update = "godswar_vote_update"
event_name.godswar_vote_success = "godswar_vote_success"
-- 结拜状态变化
event_name.sworn_status_change = "sworn_status_change"
-- 守护星阵数据更新
event_name.shouhu_wakeup_update = "shouhu_wakeup_update"
-- 守护星阵点亮
event_name.shouhu_wakeup_point_light = "shouhu_wakeup_point_light"
-- 七天登陆目标个数奖励领取进度
event_name.seven_day_target_upgrade = "seven_day_target_upgrade"
-- 七天登陆累计充值数变更
event_name.seven_day_charge_upgrade = "seven_day_charge_upgrade"
-- 七天登陆半价购买数量变更
event_name.seven_day_halfprice_upgrade = "seven_day_halfprice_upgrade"
--装备精炼保存成功
event_name.equip_dianhua_save_success = "equip_dianhua_save_success"
-- 装备宝石镶嵌任务完成
event_name.guide_equip_stone_end = "guide_equip_stone_end"
-- 通用匹配系统状态改变
event_name.match_status_change = "match_status_change"
-- 通用匹配系统匹配出结果
event_name.match_has_result = "match_has_result"
-- 通用匹配系统次数更新
event_name.match_times_change = "match_times_change"
-- 日程改变
event_name.agenda_update = "agenda_update"
-- 活跃度更新，需客户端请求
event_name.active_point_update = "active_point_update"
-- 战斗发弹幕cd触发
event_name.combat_danmaku_cd = "combat_danmaku_cd"
-- 法宝变化
event_name.talisman_item_change = "talisman_item_change"
-- 幸运转盘已领取Id变化
event_name.luckey_chest_own_id_change = "luckey_chest_own_id_change "
-- 防沉迷配置变更
event_name.indulge_change = "indulge_change"
-- 商城购买结果
event_name.shop_buy_result = "shop_buy_result"
-- 妖狐剑心活动单位更新
event_name.fox_unit_update = "fox_unit_update"
-- 亲密度排行榜更新
event_name.intimacy_update = "intimacy_update"
-- 我的亲密度信息更新
event_name.intimacy_my_data_update = "intimacy_my_data_update"
-- 我的亲密度奖励信息更新
event_name.intimacy_reward_data_update = "intimacy_reward_data_update"
-- 活动每日领取红点检测
event_name.campaign_get_update = "campaign_get_update"

-- 排行榜活动排行榜更新
event_name.campaign_rank_update = "campaign_rank_update"
-- 我的排行榜活动信息更新
event_name.campaign_rank_my_data_update = "campaign_rank_my_data_update"
-- 世界等级活动时间变更
event_name.campaign_rank_time_update = "campaign_rank_time_update"
-- 我的排行榜活动奖励信息更新
event_name.campaign_rank_reward_data_update = "campaign_rank_reward_data_update"
--星座驾照信息更新
event_name.constellation_profile_update = "constellation_profile_update"
-- 经验模型更新
event_name.exp_mode_change = "exp_mode_change"
-- 战斗更新
event_name.fight_change = "fight_change"
-- 获取制定角色信息
event_name.update_charactor_info = "update_charactor_info"

--tip界面隐藏
event_name.tips_close = "tips_close"

--tip界面点击（按钮除外）区域的隐藏
event_name.tips_cancel_close= "tips_cancel_close"

event_name.camp_red_change = "red_change"
-- 新表情数据更新
event_name.new_face_update = "new_face_update"
-- 家具出售
event_name.home_item_sell = "home_item_sell"
-- 适应iPhone X的屏幕尺寸
event_name.adapt_iphonex = "adapt_iphonex"
-- 观战支持率
event_name.combat_watch_vote = "combat_watch_vote"
-- 观战技能
event_name.combat_watch_skill = "combat_watch_skill"
-- 下载奖励
event_name.download_reward = "download_reward"

-- 聊天信息发送成功(或因屏蔽字失败)
event_name.message_send_success = "message_send_success"