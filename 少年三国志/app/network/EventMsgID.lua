EventMsgID = 
{
--login events
    EVENT_LOGIN_SUCCESS  = "login_success",   --登陆第一步收到登陆成功
    EVENT_RECV_FLUSH_DATA  = "recv_flush_data",  --登陆第二步 收到了flush data,这个时候其实可以准备进入主场景了
    EVENT_ALL_DATA_READY  = "all_day_ready",  --登陆第三步 没有其他事情要做了,进入主场景吧
    EVENT_ENTER_GAME = "ener_game",
    EVENT_UPDATE_UID  = "EVENT_UPDATE_UID",  
    EVENT_UPDATE_ROLE_LIST= "EVENT_UPDATE_ROLE_LIST",  
    EVENT_PLATFORM_LOGIN_OK= "EVENT_PLATFORM_LOGIN_OK",  
    EVENT_FINISH_LOGIN= "EVENT_FINISH_LOGIN",  

    

    EVENT_CREATED_ROLE = "created_role",
    EVENT_UPDATE_SERVER_LIST = "EVENT_UPDATE_SERVER_LIST",
    EVENT_NATIVE_WEIXIN_CALLBACK = "EVENT_NATIVE_WEIXIN_CALLBACK",

    EVENT_GUIDE_MODULE_STEP_ID = "guide_module_step_id",
    EVENT_USER_LEVELUP = "user_level_up",

    EVENT_RECV_ROLE_INFO  = "recv_role_info",
    EVENT_NEED_CREATE_ROLE  = "need_create_role",
    EVENT_NEED_RELOGIN  = "need_relogin",    
    EVENT_MAINTAIN  = "maintain",
    EVENT_BAN_USER  = "EVENT_BAN_USER",
    EVENT_TOKEN_EXPIRED  = "EVENT_TOKEN_EXPIRED",
    EVENT_NOT_ALLOWED  = "EVENT_NOT_ALLOWED",
   EVENT_WRONG_VERSION  = "EVENT_WRONG_VERSION",
   EVENT_SERVER_CROWD  = "EVENT_SERVER_CROWD",   --服务器承载超出
   EVENT_BLACKCARD_USER = "BLACKCARD_USER", --黑卡封禁用户
   EVENT_BLACKCARD_WARNING = "EVENT_BLACKCARD_WARNING", 
   EVENT_ROLE_INFO_CLOSE_CHANGE_NAMEFRAME_BTN_LAYER = "event_role_info_close_change_nameframe_btn_layer", -- 关闭修改头像框、角色名按钮所在弹层
   EVENT_CHANGE_ROLE_NAME_SUCCEED = "event_change_role_name_succeed", -- 改名成功

    EVENT_SPEEDBAR  ="speedbar",
    EVENT_ROLL_NOTICE  ="EVENT_ROLL_NOTICE",

    EVENT_GET_CODEID = "EVENT_GET_CODEID",
    EVENT_GET_CODE = "EVENT_GET_CODE",

--core events
    EVENT_SERVER_TIME_UPDATE  = "server_time_update",
    EVENT_NETWORK_TIMEOUT  = "network_timeout",
    EVENT_NETWORK_ALIVE  = "network_alive",
    EVENT_NETWORK_DEAD  = "network_dead",

    EVENT_MEDIA_PLAY_FINISH = "media_play_finish",
    EVENT_SCENE_CHANGED = "EVENT_SCENE_CHANGED",
    EVENT_QR_CODE = "event_qr_code",
    
-- chat part
    EVENT_RECEIVE_CHAT_MSG = "chat_msg",
    EVENT_RECEIVE_CHAT_REQUEST_RET = "chat_request_ret",
    EVENT_RECEIVE_NOTIFY	= "receive_notify",
    EVENT_MSG_DIRTY_FLAG_CHANGED = "chat_msg_update",

    -- battle
    EVENT_RECEIVE_BATTLE = "battle_msg",
    
    -- friends system
    EVENT_FRIENDS_LIST = "friends_list",
    EVENT_FRIENDS_REQUEST_LIST = "friends_request_list",
    EVENT_FRIENDS_ADD = "friends_add",
    EVENT_FRIENDS_DELETE = "friends_delete",
    EVENT_FRIENDS_CONFIRM = "friends_confirm",
    EVENT_FRIENDS_PRESENT_GIVE = "friends_present_give",
    EVENT_FRIENDS_PRESENT_RECEIVE = "friends_present_receive", 
    EVENT_FRIENDS_ADD_NOTIFY = "friends_add_notify",
    EVENT_FRIENDS_USER_INFO = "friends_user_info",
    EVENT_FRIENDS_REFRESH = "friends_list_refresh",
    EVENT_FRIENDS_CHOOSE_LIST = "friends_list_choose",
    EVENT_FRIENDS_INFO = "friends_info",
    EVENT_FRIENDS_KILL = "friends_kill",
    EVENT_FRIENDS_PLAYINFO = "friends_get_info",
    EVENT_FRIENDS_MAIL = "friends_mail",

    -- vip
    EVENT_VIP_GETVIP = "vip_getvip",
    EVENT_VIP_EXECUTE = "vip_execute",
    EVENT_VIP_RESET = "vip_reset",

    -- dailytask
    EVENT_DAILYTASK_GETDAILYMISSION = "vip_getdailymission",
    EVENT_DAILYTASK_FINISHDAILYMISSION = "vip_finishdailymission",
    EVENT_DAILYTASK_GETDAILYMISSIONAWARD = "vip_getdailymissionaward",
    EVENT_DAILYTASK_FLUSH = "vip_flush",

    --arean
    EVENGT_ARENA_LIST = "arena_list_users", 
    --竞技场排行榜
    EVENT_ARENA_RANKING_LIST = "arena_ranking_list",
    EVENT_ARENA_USER_INFO = "arena_user_info",
    EVENT_ARENA_SAO_DANG = "event_arena_sao_dang",


    --card systeml part
    EVENT_FORMATION_UPDATE = "formation_update",
    EVENT_ADD_TEAM_KNIGHT  = "add_team_knight",
    EVENT_CHANGE_FORMATION = "change_formation",
    EVENT_CHANGE_TEAM_FORMATION = "change_team_formation",
    --arena system
    EVENT_ARENA_LIST = "arena_list_users",
    EVENT_ARENA_CHALLENGE = "arena_challenge",
    
    --tower system
    EVENT_TOWER_INFO = "tower_info",
    EVENT_TOWER_CHALLENGE_REPORT = "tower_battle_report",
    EVENT_TOWER_START_CLEANUP = "tower_start_cleanup",
    EVENT_TOWER_STOP_CLEANUP = "tower_stop_cleanup",
    EVENT_TOWER_RESET = "tower_reset",
    EVENT_TOWER_REFRESH_BUFF = "tower_refresh_buff",
    EVENT_TOWER_GET_BUFF = "tower_get_buff",
    EVENT_TOWER_RANK = "tower_rank",
    EVENT_TOWER_CLEANUP_REPORT_REFRESH = "tower_cleanup_report_refresh",

    --wush system
    EVENT_WUSH_INFO = "wush_info",
    EVENT_WUSH_CHALLENGE_REPORT = "wush_battle_report",
    EVENT_WUSH_RESET = "wush_reset",
    EVENT_WUSH_APPLY_BUFF = "wush_apply_buff",
    EVENT_WUSH_GET_BUFF = "wush_get_buff",
    EVENT_WUSH_RANK = "wush_rank",
    EVENT_WUSH_BUY = "wush_buy",

    --fund
    EVENT_FUND_INFO = "fund_info",
    EVENT_FUND_USER_FUND = "fund_user_fund",
    EVENT_FUND_BUY_FUND = "fund_buy_fund",
    EVENT_FUND_AWARD = "fund_award",
    EVENT_FUND_WEAL = "fund_weal",

    --month fund
    EVENT_MONTH_FUND_BASE_INFO = "event_monthfund_baseinfo",
    EVENT_MONTH_FUND_AWARD_INFO = "event_monthfund_awardinfo",
    EVENT_MONTH_FUND_GET_AWARD = "event_monthfund_getaward",


    --dress
    EVENT_DRESS_UPDATE = "dress_update",
    EVENT_ADD_DRESS = "add_dress",
    EVENT_CLEAR_DRESS = "clear_dress",
    EVENT_GET_DRESS = "get_dress",
    EVENT_DRESS_RECYCLE = "dress_recycle",
    
    -- dugeon
    EVENT_DUNGEON_RECVCHAPTERLIST = "dungeon_recvchapterlist",
    EVENT_DUNGEON_ENTERBATTLE = "dungeon_enterbattle",
    EVENT_DUNGEON_FASTEXECUTESTAGE = "dungeon_fastexecutestage",
    EVENT_DUNGEON_EXECUTESTAGE = "dungeon_executestage",
    EVENT_DUNGEON_GETDUNGEONRANK = "dungeon_getdungeonrank",
    EVENT_DUNGEON_UPDATESTAGE = "dungeon_updatestage",
    EVENT_DUNGEON_GETSTARBOUNS = "dungeon_getstarbouns",
    EVENT_DUNGEON_GETBOUNSSUCC = "dungeon_getbounssucc",
    EVENT_DUNGEON_FINISHSTARBOUNS = "dungeon_finishstarbouns",
    EVENT_DUNGEON_REQUESTBATTLE = "dungeon_requestbattle",
    EVENT_DUNGEON_SECKILL = "dungeon_seckill",
    EVENT_DUNGEON_UPDATETIPS = "dungeon_updatetips",
    EVENT_DUNGEON_SHOWSHAKE = "dungeon_showshake",
    EVENT_DUNGEON_CLOSEENTERLAYER = "dungeon_closeenterlayer",
    EVENT_DUNGEON_CLOSESUBTITLElAYER = "dungeon_closesubtitlelayer",
    EVENT_DUNGEON_DUNGEONRESTSUCC = "dungeon_dungeonrestsucc",
    EVENT_DUNGEON_SHOWNEWCHAPTERACTION = "dungeon_shownewchapter",


    -- hard dugeon
    EVENT_HARD_DUNGEON_RECVCHAPTERLIST = "hard_dungeon_recvchapterlist",
    EVENT_HARD_DUNGEON_ENTERBATTLE = "hard_dungeon_enterbattle",
    EVENT_HARD_DUNGEON_FASTEXECUTESTAGE = "hard_dungeon_fastexecutestage",
    EVENT_HARD_DUNGEON_EXECUTESTAGE = "hard_dungeon_executestage",
    EVENT_HARD_DUNGEON_GETDUNGEONRANK = "hard_dungeon_getdungeonrank",
    EVENT_HARD_DUNGEON_UPDATESTAGE = "hard_dungeon_updatestage",
    EVENT_HARD_DUNGEON_GETSTARBOUNS = "hard_dungeon_getstarbouns",
    EVENT_HARD_DUNGEON_GETBOUNSSUCC = "hard_dungeon_getbounssucc",
    EVENT_HARD_DUNGEON_FINISHSTARBOUNS = "hard_dungeon_finishstarbouns",
    EVENT_HARD_DUNGEON_REQUESTBATTLE = "hard_dungeon_requestbattle",
    EVENT_HARD_DUNGEON_SECKILL = "hard_dungeon_seckill",
    EVENT_HARD_DUNGEON_UPDATETIPS = "hard_dungeon_updatetips",
    EVENT_HARD_DUNGEON_SHOWSHAKE = "hard_dungeon_showshake",
    EVENT_HARD_DUNGEON_CLOSEENTERLAYER = "hard_dungeon_closeenterlayer",
    EVENT_HARD_DUNGEON_CLOSESUBTITLElAYER = "hard_dungeon_closesubtitlelayer",
    EVENT_HARD_DUNGEON_DUNGEONRESTSUCC = "hard_dungeon_dungeonrestsucc",
    EVENT_HARD_DUNGEON_SHOWNEWCHAPTERACTION = "hard_dungeon_shownewchapter",


    --bag
    EVNET_BAG_USE_ITEM = "bag_use_item",

    EVNET_BAG_UPDATE_EQUIPMENT = "bag_update_equipment",

    EVNET_BAG_UPDATE_TREASURE = "bag_update_treasure",
    
    --bagdata has changed
    EVNET_BAG_HAS_CHANGED = "bag_has_changed",
    
    --碎片合成
    EVENT_BAG_FRAGMENT_COMPOUND = "bag_fragment_compound",
    
    
    --EVNET_BAG_SELL_RESULT, maybe  failed or success
    EVNET_BAG_SELL_RESULT = "bag_sell_result",

    -- 碎片出售
    EVENT_BAG_FRAGMENT_SELL_RESULT = "bag_fragment_sell_result",

    --shop
    EVENT_SHOP_INFO = "shop_info",
    EVENT_SHOP_ITEM_BUY_RESULT = "shop_item_buy_result",
    
    --shop 招募信息
    EVENT_SHOP_DROP_KNIGHT_INFO = "shop_drop_knight_info",
    --shop 良品knight 抽卡
    EVENT_SHOP_DROP_GOOD_KNIGHT = "shop_drop_good_knight",
    --shop 极品knight 抽卡
    EVENT_SHOP_DROP_GODLY_KNIGHT = "shop_drop_godly_knight",

    --20连抽
    EVENT_SHOP_DROP_GODLY_KNIGHT_20 = "shop_drop_godly_knight_20",
    --阵营抽将
    EVENT_SHOP_DROP_ZHEN_YING = "event_shop_drop_zhen_ying",

    
    --充值相关
    EVENT_GET_RECHARGE_INFO = "get_recharge_info",
    EVENT_USE_MONTHCARD_INFO = "use_monthcard_info",
    EVENT_RECHARGE_SUCCESS = "recharge_success",
    --活动首充奖励
    EVENT_ACTIVITY_RECHARGE_AWARD = "activity_recharge_award",

    -- hero upgrade
    EVENT_RECEIVE_UPGRADE_KNIGHT = "uprade_knight_result",
    EVENT_RECEIVE_ADVANCED_KNIGHT = "advanced_knight_result",
    EVENT_RECEIVE_TRAINING_KNIGHT  = "training_knight_result",
    EVENT_RECEIVE_SAVE_TRAINING = "save_training_result",
    EVENT_RECEIVE_GIVEUP_TRAINING = "giveup_training_result",
    EVENT_RECEIVE_HALO_KNIGHT   = "halo_knight_result",
    EVENT_RECEIVE_GOD_KNIGHT = "event_receive_god_knight",

    EVENT_RECEIVE_FIGHT_RESOUCES = "fight_resouces",
    EVENT_RECEIVE_ADD_FIGHT_EQUIPMENT = "add_fight_equipment",
    EVENT_RECEIVE_CLEAR_FIGHT_EQUIPMENT = "clear_fight_equipment",
    EVENT_RECEIVE_ADD_FIGHT_TREASURE = "add_fight_treasure",
    EVENT_RECEIVE_CLEAR_FIGHT_TREASURE = "clear_fight_treasure",
    EVENT_EQUIP_DIRTY_FLAG_CHANGED = "equip_dirty_flag_changed",
    EVENT_SET_PET_PRITECT = "event_set_pet_pritect",
    
    --mail
    EVENT_MAIL_CONTENT_READY = "mail_content_ready",
    EVENT_MAIL_NEW_COUNT = "mail_new_count",
    EVENT_MAIL_LIST_UPDATE= "EVENT_MAIL_LIST_UPDATE",

    
    --gift mail
    EVENT_GIFT_MAIL_CONTENT_READY = "gift_mail_content_ready",
    EVENT_GIFT_MAIL_NEW_COUNT = "gift_mail_new_count",
    EVENT_GIFT_MAIL_PROCESS = "gift_mail_process",

    --装备强化精炼升星
    EVENT_EQUIPMENT_STRENGTHEN = "equipment_strengthen",
    EVENT_EQUIPMENT_REFINE = "equipment_refine",
    EVENT_EQUIPMENT_STAR = "equipment_star",
    EVENT_EQUIPMENT_FASTREFINE = "equipment_fastrefine",

    -- skilltree
    EVENT_SKILLTREE_LIST = "skilltree_list",
    EVENT_SKILLTREE_NETMSG = "skilltree_netmsg",
    
    --神秘商店
    EVENT_SECRETSHOP_REFRESH_NUMBER = "secretshop_refresh_number",
    EVENT_SECRETSHOP_REFRESH_INFO = "secretshop_refresh_info",

    -- 剧情副本
    EVENT_STORYDUNGEON_DUNGEONLIST = "storydungeon_dungeonlist",
    EVENT_STORYDUNGEON_EXECUTEBARRIER = "storydungeon_executebarrier",
    EVENT_STORYDUNGEON_GETBARRIERAWARD = "storydungeon_getbarrieraward",
    EVENT_STORYDUNGEON_FINISHSANGUOZHIAWARD = "storydungeon_finishsanguozhiaward",
    EVENT_STORYDUNGEON_REQUESTBATTLE = "storydungeon_requestbattle",
    
    --魔神
    EVENT_MOSHEN_GET_REB = "event_moshen_get_reb",
    EVENT_MOSHEN_ENTER_REBEL_UI = "event_moshen_enter_reb_ui",
    EVENT_MOSHEN_ATTACK_REBEL = "event_moshen_attack_rebel",
    EVENT_MOSHEN_PUBLIC_REBEL = "event_moshen_public_rebel",
    EVENT_MOSHEN_REBEL_RANK = "event_moshen_rebel_rank",
    EVENT_MOSHEN_MY_REBEL_RANK = "event_moshen_my_rebel_rank",
    EVENT_MOSHEN_REFRESH_REBEL = "event_moshen_refresh_rebel",
    EVENT_MOSHEN_CHOOSE_FRIEND = "event_moshen_choose_friend",
    EVENT_MOSHEN_GET_EXPLOIT_AWARD = "event_moshen_get_exploit_award",
    EVENT_MOSHEN_GET_EXPLOIT_AWARD_TYPE = "event_moshen_get_exploit_award_type",
    EVENT_MOSHEN_GET_REBEL_SHOW = "event_moshen_get_rebel_show",
    EVENT_MOSHEN_REFRESH_REBEL_SHOW = "event_moshen_refresh_rebel_show",
    --刷新魔神
    EVENT_MOSHEN_REFRESH_STATUS = "event_moshen_refresh_status",
    
         -- 图鉴
    EVENT_HANDBOOK_GETHANDBOOKINFO = "handbook_gethandbookinfo",
    
    --夺宝奇兵
    EVENT_TREASURE_ROB_LIST = "treasure_fragment_roblist",
    EVENT_TREASURE_ROB_RESULT = "treasure_rob_result",
    EVENT_TREASURE_COMPOSE = "treasure_compose",
    EVENT_TREASURE_FRAGMENT_NUMBER_CHANGE = "treasure_fragment_number_change",
    EVENT_TREASURE_FORBID_BATTLE = "treasure_forbid_battle",  --免战
    EVENT_TREASURE_COMPOSE_BTN_ANIMATION = "treasure_compose_btn_animation",  --合成按钮呼吸效果
    EVENT_TREASURE_ONE_KEY_ROB = "treasure_one_key_rob", -- 一键夺宝
    --宝物养成
            --宝物强化
    EVENT_TREASURE_STRENGTH = "event_treasure_strength",
            --宝物精炼
    EVENT_TREASURE_REFINE = "event_treasure_fefine",
            --宝物熔炼
    EVENT_TREASURE_SMELT = "event_treasure_smelt",
            --宝物铸造
    EVENT_TREASURE_FORGE = "event_treasure_forge",
    
    -- 武将归隐
    EVENT_RECYCLE_KNIGHT = "event_recycle_knight",
    -- 装备重铸
    EVENT_RECYCLE_EQUIPMENT = "event_recycle_equipment",
    --装备重生
    EVENT_RECYCLE_REBORN_EQUIPMENT_PREVIEW = "event_recycle_reborn_equipment_preview",
    EVENT_RECYCLE_REBORN_EQUIPMENT_RESULT = "event_recycle_reborn_equipment_result",
    -- 武将重生
    EVENT_RECYCLE_REBORN = "event_recycle_reborn",
    
    EVENT_RECYCLE_RESULT = "event_recycle_result",
    EVENT_RECYCLE_PREVIEW = "event_recycle_preview",
    
    EVENT_RECYCLE_EQUIPMENT_RESULT = "event_recycle_equipment_result",
    EVENT_RECYCLE_EQUIPMENT_PREVIEW = "event_recycle_equipment_preview",
    
    EVENT_RECYCLE_TREASURE_PREVIEW = "event_recycle_treasure_preview",
    EVENT_RECYCLE_TREASURE_RESULT = "event_recycle_treasure_result",

    EVENT_RECYCLE_PET_RESULT = "event_recycle_pet_result",
    EVENT_RECYCLE_PET_PREVIEW = "event_recycle_pet_preview",
    
    -- 首页
    EVENT_MAINSCENE_CLOSEMOREBTN = "event_mainscene_closebtn",
    EVENT_MAINSCENE_CLOSESHOPSBTN = "event_mainscene_closeshopsbtn",

    EVENT_MAINSCENE_SECRET_SHOP_UPDATED = "EVENT_MAINSCENE_SECRET_SHOP_UPDATED",
    EVENT_MAINSCENE_AWAKEN_SHOP_UPDATED = "EVENT_MAINSCENE_AWAKEN_SHOP_UPDATED",


    --guide
    EVENT_RECEIVE_GUIDE_ID =   "event_receive_guide_id",
    EVENT_RECEIVE_GUIDE_START = "event_guide_start",
    EVENT_RECEIVE_GUIDE_END    = "event_guide_end",

    --战斗结算结束
    EVENT_FINISH_PLAY_FIGHTEND  = "event_finish_play_fightend",

    --夺宝成功通知播放特效
    EVENT_ROB_TREASURE_FRAGMENT_SUCCESS  = "event_rob_treasure_fragment_success",
    
    -- notice
    EVENT_NOTICE = "event_notice",

    -----activity
    EVENT_ACTIVITY_DATA_CAISHEN_UPDATED = "EVENT_ACTIVITY_DATA_CAISHEN_UPDATED", --网络修改了数据
    EVENT_ACTIVITY_FINISH_CAISHEN = "EVENT_ACTIVITY_FINISH_CAISHEN", 
    EVENT_ACTIVITY_DATA_WINE_UPDATED = "EVENT_ACTIVITY_DATA_WINE_UPDATED",--网络修改了数据
    EVENT_ACTIVITY_DATA_DAILY_UPDATED = "EVENT_ACTIVITY_DATA_DAILY_UPDATED",--网络修改了数据
    EVENT_ACTIVITY_FINISH_DAILY = "EVENT_ACTIVITY_FINISH_DAILY",
    EVENT_ACTIVITY_FINISH_WINE = "EVENT_ACTIVITY_FINISH_WINE",
    EVENT_ACTIVITY_UPDATED = "EVENT_ACTIVITY_UPDATED",--活动数据更新
    --可配置活动
    EVENT_CUSTOM_ACTIVITY_INFO = "event_custom_activity_info",
    EVENT_CUSTOM_ACTIVITY_UPDATE = "event_custom_activity_update",
    EVENT_CUSTOM_ACTIVITY_UPDATE_QUEST = "event_custom_activity_update_quest",
    EVENT_CUSTOM_ACTIVITY_GET_AWARD = "event_custom_activity_getaward",

    EVENT_GETRECHARGEBACK = "event_getrechargeback",
    EVENT_RECHARGEBACKGOLD = "event_rechargebackgold",
    EVENT_GETPHONEBINDNOTICE = "event_getphonebindnotice",
    EVENT_VIPDISCOUNTINFO = "event_vipdiscountinfo",
    EVENT_BUYVIPDISCOUNT = "event_buyvipdiscount",
    EVENT_VIPDAILYINFO = "event_VipDailyInfo",
    EVENT_BUYVIPDAILY = "event_BuyVipDaily",
    EVENT_VIPWEEKSHOPINFO = "event_VipWeekShopInfo",
    EVENT_VIPWEEKSHOPBUY = "event_VipWeekShopBuy",

    EVENT_GETSPREADID = "event_GetSpreadId",
    EVENT_REGISTERID = "event_RegisterId",
    EVENT_INVITORGETREWARDINFO = "event_InvitorGetRewardInfo",
    EVENT_INVITORDRAWLVLREWARD = "event_InvitorDrawLvlReward",
    EVENT_INVITORDRAWSCOREREWARD = "event_InvitorDrawScoreReward",
    EVENT_INVITEDDRAWREWARD = "event_InvitedDrawReward",
    EVENT_INVITEDGETDRAWREWARD = "event_InvitedGetDrawReward",
    EVENT_QUERYREGISTERRELATION = "event_QueryRegisterRelation",
    EVENT_GETINVITORNAME = "event_GetInvitorName",

    --圣诞节活动

    EVENT_HOLIDAY_ACTIVITY_INFO = "event_holiday_activity_info",
    EVENT_GET_HOLIDAY_ACTIVITY_AWARD = "event_get_holiday_activity_award",
    
    -- 分享
    EVENT_ACTIVITY_SHARE_INFO = "event_activity_share_info",
    EVENT_ACTIVITY_SHARE_FINISH = "event_activity_share_finish",
    
    -- 手机绑定
    EVENT_ACTIVITY_PHONE_BIND_NOTI = "event_activity_phone_bind_noti",
    
    -- 老玩家回归
    EVENT_GET_OLD_USER_INFO = "event_get_old_user_info",
    EVENT_GET_OLD_USER_VIP_EXP = "event_get_old_user_vip_exp",
    EVENT_GET_OLD_USER_VIP_AWARD = "event_get_old_user_vip_award",
    EVENT_GET_OLD_USER_GIFT = "event_get_old_user_gift",

    -- target
    EVENT_TARGET_INFO = "event_target_info",
    EVENT_TARGET_GET_REWARD = "event_target_get_reward",

    --三国志碎片
    EVENT_GET_MAIN_GROUTH_INFO = "event_get_main_grouth_info",
    EVENT_USE_MAIN_GROUTH_INFO = "event_use_main_grouth_info",

    --礼品码
    EVENT_GIFT_CODE_INFO = "event_gift_code_info",
    
    -- 名人堂
    EVENT_HALLOFFRAME_INFO = "event_hallofframe_info",                  --名人堂
    EVENT_HALLOFFRAME_CONFRIM = "event_hallofframe_confrim",            --点赞
    EVENT_HALLOFFRAME_SIGN = "event_hallofframe_sign",                  --签名
    EVENT_HALLOFFRAME_TOP = "event_hallofframe_top",                    --排行榜

    -- days7 activity
    EVENT_FLUSH_ACTIVITY_INFO  = "event_flush_actitivy_info",
    EVENT_FINISH_ACTIVITY_INFO = "event_finish_activity_info",
    EVENT_DAYS_ACTIVITY_SELL_INFO = "event_activity_sell_info",
    EVENT_PURCHASE_ACTIVITY_SELL = "event_purchase_sell_info",
    
    -- city
    EVENT_CITY_INFO = "event_city_info",
    EVENT_CITY_ATTACK = "event_city_attack",
    EVENT_CITY_PATROL = "event_city_patrol",
    EVENT_CITY_CHECK = "event_city_check",
    EVENT_CITY_AWARD = "event_city_award",
    EVENT_CITY_ASSIST = "event_city_assist",
    EVENT_CITY_ASSISTED = "event_city_assisted",
    EVENT_CITY_ONEKEYREWARD = "event_city_onekeyreward",
    EVENT_CITY_ONEKEYPATROL_SET = "event_city_onekeypatrol_set",
    EVENT_CITY_TECH_UP = "event_city_tech_up",

    --军团
    EVENT_GET_CORP_LIST = "event_get_corp_list",
    EVENT_GET_JOIN_CORP_LIST = "event_get_join_corp_list",
    EVENT_GET_CORP_DETAIL = "event_get_corp_detail",
    EVENT_GET_CORP_MEMBERLIST = "event_get_corp_memberlist",
    EVENT_GET_CORP_HISTORY = "event_get_corp_history",
    EVENT_CREATE_CORP = "event_create_corp",
    EVENT_REQUEST_JOIN_CORP = "event_request_join_corp",
    EVENT_DELETE_JOIN_CORP = "event_delete_join_corp",
    EVENT_QUIT_CORP = "event_quit_corp",
    EVENT_SEARCH_CORP = "event_search_corp",
    EVENT_CONFIRM_JOIN_CORP = "event_confirm_join_corp",
    EVENT_MODIFY_CORP = "event_modify_corp",
    EVENT_DISMISS_CORP_MEMBER = "event_dismiss_corp_member",
    EVENT_GET_CORP_JOIN_MEMBER = "event_get_corp_join_member",
    EVENT_DISMISS_CORP = "event_dismiss_corp",
    EVENT_EXCHANGE_LEADER = "event_exchange_leader",
    EVENT_GET_CORP_STAFF = "event_get_corp_staff",
    EVENT_GET_CORP_WORSHIP = "event_get_corp_worship",
    EVENT_GET_CORP_CONTRIBUTE = "event_get_corp_contribute",
    EVENT_GET_CORP_CONTRIBUTE_AWARD = "event_get_corp_contribute_award",
    EVENT_NOTIFY_CORP_DISMISS = "event_notify_corp_dismiss",

    -- 军团副本
    EVENT_GET_CORP_CHATER_INFO = "event_get_corp_chapter_info",
    EVENT_GET_CORP_DUNGEON_INFO = "event_get_corp_dungeon_info",
    EVENT_EXECUTE_CORP_DUNGEON = "event_execute_corp_dungeon",
    EVENT_SET_CORP_CHAPTER_ID = "event_set_corp_chapter_id",
    EVENT_GET_DUNGEON_AWARD_LIST = "event_get_dungeon_award_list",
    EVENT_GET_DUNGEON_AWARD = "event_get_dungeon_award",
    EVENT_GET_DUNGEON_AWARD_CORP_POINT = "event_get_dungeon_award_corp_point",
    EVENT_GET_DUNGEON_CORP_RANK = "event_get_dungeon_corp_rank",
    EVENT_GET_DUNGEON_CORP_MEMBER_RANK = "event_get_dungeon_corp_member_rank",
    EVENT_GET_FLUSH_CORP_DUNGEON = "event_flush_corp_dungeon",
    EVENT_GET_FLUSH_DUNGEON_AWARD = "event_flush_dungeon_award",
    EVENT_RESET_DUNGEON_COUNT = "event_reset_dongeon_count",

    EVENT_CORP_FLAG_HAVE_APPLY  = "event_corp_flag_have_apply",
    EVENT_CORP_FLAG_CAN_WORSHIP  = "event_corp_flag_can_worship",
    EVENT_CORP_FLAG_CAN_HIT_EGGS  = "event_corp_flag_can_hit_eggs",
    EVENT_CORP_FLAG_HAVE_WORSHIP_AWARD  = "event_corp_flag_have_worship_award",
    EVENT_CORP_GET_CORP_CHAPER_RANK = "event_get_corp_chapter_rank",

    -- 新的军团副本
    EVENT_GET_NEW_CORP_CHATER_INFO = "event_get_new_corp_chapter_info",
    EVENT_GET_NEW_CORP_DUNGEON_INFO = "event_get_new_corp_dungeon_info",
    EVENT_EXECUTE_NEW_CORP_DUNGEON = "event_execute_new_corp_dungeon",
    EVENT_GET_NEW_DUNGEON_AWARD_LIST = "event_get_new_dungeon_award_list",
    EVENT_GET_NEW_DUNGEON_AWARD = "event_get_new_dungeon_award",
    EVENT_GET_NEW_DUNGEON_CORP_MEMBER_RANK = "event_get_new_dungeon_corp_member_rank",
    EVENT_GET_FLUSH_NEW_CORP_DUNGEON = "event_flush_new_corp_dungeon",
    EVENT_GET_FLUSH_NEW_DUNGEON_AWARD = "event_flush_new_dungeon_award",
    EVENT_RESET_NEW_DUNGEON_COUNT = "event_reset_new_dungeon_count",
    EVENT_GET_NEW_CHAPER_AWARD = "event_get_new_chapter_award",
    EVENT_GET_NEW_DUNGEON_AWARD_HINT = "event_get_new_dungeon_award_hint",
    EVENT_CORP_GET_NEW_CORP_CHAPER_RANK = "event_get_new_corp_chapter_rank",
    EVENT_CORP_ROLLBACK = "event_corp_rollback",

    --军团科技
    EVENT_GET_CORP_TECH_INFO = "event_get_crop_tech_info",
    EVENT_DEVELOP_CORP_TECH = "event_develop_crop_tech",
    EVENT_LEARN_CORP_TECH = "event_learn_crop_tech",
    EVENT_CORP_UPLEVEL = "event_crop_uplevel",
    EVENT_CORP_TECH_BROADCAST = "event_crop_tech_broadcast",
    EVENT_CORP_LEVEL_BROADCAST = "event_crop_level_broadcast",

    -- 群英战
    EVENT_CORP_CROSS_REFRESH_APPLY_INFO = "event_corp_cross_refresh_apply_info",
    EVENT_CORP_CROSS_APPLY_BATTLE_STATUS_CHANGE  = "event_corp_cross_apply_battle_status_change",
    EVENT_CORP_CROSS_REFRESH_BATTLE_LIST = "event_corp_cross_refresh_battle_list",
    EVENT_CORP_CROSS_FLUSH_BATTLE_CORP = "event_corp_cross_flush_battle_corp",
    EVENT_CORP_CROSS_REFRESH_ENCOURAGE_INFO = "event_corp_cross_refresh_encourage_info",
    EVENT_CORP_CROSS_FLUSH_ENCOURAGE_INFO = "event_corp_cross_flush_encourage_info",
    EVENT_CORP_CROSS_ENCOURAGE_BATTLE = "event_corp_cross_encourage_battle",
    EVENT_CORP_CROSS_REFRESH_BATTLE_FIELD = "event_corp_cross_refresh_battle_field",
    EVENT_CORP_CROSS_REFRESH_BATTLE_ENEMYS = "event_corp_cross_refresh_battle_enemys",
    EVENT_CORP_CROSS_CHALLENGE_ENEMY = "event_corp_cross_challenge_enemy",
    EVENT_CORP_CROSS_RESET_CHALLENGE_CD = "event_corp_cross_reset_challenge_cd",
    EVENT_CORP_CROSS_SET_BATTLE_FIRE_ON = "event_corp_cross_set_battle_fire_on",
    EVENT_CORP_CROSS_REFRESH_BATTLE_MEMBER_RANK = "event_corp_cross_refresh_battle_member_rank",
    EVENT_CORP_CROSS_BROADCAST_BATTLE_STATUS = "event_corp_cross_broadcast_battle_status",
    EVENT_CORP_CROSS_BROADCAST_BATTLE_FIELD = "event_corp_cross_broadcast_battle_field",
    EVENT_CORP_CROSS_REFRESH_BATTLE_TIMES = "event_corp_cross_refresh_battle_times",
    EVENT_CORP_CROSS_FLUSH_BATTLE_INFO = "event_corp_cross_flush_battle_info",
    EVENT_CORP_CROSS_FLUSH_FIRE_ON = "event_corp_cross_flush_fire_on",
    EVENT_CORP_CROSS_FLUSH_MEMBER_INFO = "event_corp_cross_flush_member_info",

    --军团商店
    EVENT_GET_CORP_SHOP_INFO = "event_get_corp_shop_info",
    EVENT_GET_CORP_SHOP_SHOPPING = "event_get_corp_shop_shoping",
    
    -- 分享事件通知
    EVENT_SHARE_SUCCESS = "event_share_success",

    --轮盘
    EVENT_WHEEL_INFO = "event_wheel_info",
    EVENT_PLAY_WHEEL = "event_play_wheel",
    EVENT_WHEEL_REWARD = "event_wheel_reward",
    EVENT_WHEEL_RANK = "event_wheel_rank",

    --大富翁
    EVENT_RICH_INFO = "event_rich_info",
    EVENT_RICH_MOVE = "event_rich_move",
    EVENT_RICH_REWARD = "event_rich_reward",
    EVENT_RICH_RANK = "event_rich_rank",
    EVENT_RICH_BUY = "event_rich_buy",
    
    -- 觉醒事件相关
    EVENT_AWAKEN_PUTON_ITEM_NOTI = "event_awaken_puton_item_noti",
    EVENT_AWAKEN_COMPOSE_ITEM_NOTI = "event_awaken_compose_item_noti",
    EVENT_FAST_AWAKEN_COMPOSE_ITEM_NOTI = "event_fast_awaken_compose_item_noti",
    EVENT_AWAKEN_KNIGHT_NOTI = "event_awaken_knight_noti",
    
    -- 觉醒商店相关
    EVENT_AWAKEN_SHOP_REFRESH_COUNT_NOTI = "event_awaken_shop_refresh_count_noti",
    EVENT_AWAKEN_SHOP_REFRESH_NOTI = "event_awaken_shop_refresh_noti",

    -- 称号系统
    EVENT_CHANGE_TITLE = "event_change_title",
    
    -- 头像框
    EVENT_AVATAR_FRAME_CHANGE = "event_avatar_frame_change",    --头像改变
    EVENT_AVATAR_FRAME_FUNCTION = "event_avatar_frame_function",



    -- 跨服演武（积分赛）
    EVENT_CROSS_WAR_GET_BATTLE_TIME         = "event_cross_war_get_battle_time",
    EVENT_CROSS_WAR_GET_BATTLE_INFO         = "event_cross_war_get_battle_info",
    EVENT_CROSS_WAR_SELECT_GROUP            = "event_cross_war_select_group",
    EVENT_CROSS_WAR_ENTER_SCORE_MATCH       = "event_cross_war_enter_score_match",
    EVENT_CROSS_WAR_GET_BATTLE_ENEMY        = "event_cross_war_get_battle_enemy",
    EVENT_CROSS_WAR_CHALLENGE_SCORE_ENEMY   = "event_cross_war_challenge_score_enemy",
    EVENT_CROSS_WAR_GET_WINS_AWARD_INFO     = "event_cross_war_get_wins_award_info",
    EVENT_CROSS_WAR_FINISH_WINS_AWARD       = "event_cross_war_finish_wins_award",
    EVENT_CROSS_WAR_GET_BATTLE_RANK         = "event_cross_war_get_battle_rank",
    EVENT_CROSS_WAR_COUNT_RESET             = "event_cross_war_count_reset", -- 购买积分赛挑战和刷新次数
    EVENT_CROSS_WAR_FLUSH_SCORE             = "event_cross_war_flush_score",
    EVENT_CROSS_WAR_FLUSH_SCORE_MATCH_RANK  = "event_cross_war_flush_score_match_rank", -- 自己的排名
    EVENT_CROSS_WAR_GET_SCORE_MATCH_RANK    = "event_cross_war_get_score_Match_rank",   -- 排行榜    

    -- 跨服演武（争霸赛）
    EVENT_CROSS_WAR_GET_ARENA_INFO          = "event_cross_war_get_arena_info",
    EVENT_CROSS_WAR_GET_INVITATION          = "event_cross_war_get_invitation",
    EVENT_CROSS_WAR_GET_BET_INFO            = "event_cross_war_get_bet_info",
    EVENT_CROSS_WAR_GET_BET_LIST            = "event_cross_war_get_bet_list",
    EVENT_CROSS_WAR_BET_SOMEONE             = "event_cross_war_bet_someone",
    EVENT_CROSS_WAR_ADD_BETS                = "event_cross_war_add_bets",
    EVENT_CROSS_WAR_GET_TOP_RANKS           = "event_cross_war_get_top_ranks",
    EVENT_CROSS_WAR_GET_CLOSE_RANKS         = "event_cross_war_get_close_ranks",
    EVENT_CROSS_WAR_GET_SERVER_AWARD_INFO   = "event_cross_war_get_server_award_info",
    EVENT_CROSS_WAR_FINISH_SERVER_AWARD     = "event_cross_war_finish_server_award",
    EVENT_CROSS_WAR_BUY_CHALLENGE           = "event_cross_war_buy_challenge", -- 购买争霸赛挑战次数
    EVENT_CROSS_WAR_CHALLENGE_CHAMPION      = "event_cross_war_challenge_champion",
    EVENT_CROSS_WAR_GET_BET_AWARD           = "event_cross_war_get_bet_award",
    EVENT_CROSS_WAR_FINISH_BET_AWARD        = "event_cross_war_finish_bet_award",
    EVENT_CROSS_WAR_GET_PLAYER_TEAM         = "event_cross_war_get_player_team",

    --限时挑战
    EVENT_TIME_DUNGEON_INSPIRE_SUCC         = "event_time_dungeon_inspire_succ", --鼓舞成功
    EVENT_TIME_DUNGEON_OPEN_BATTLE_SCENE    = "event_time_dungeon_open_battle_scene", -- 打开战斗场景
    EVENT_TIME_DUNGEON_CHECK_HAS_DUNGEON    = "event_time_dungeon_check_has_dungeon", -- GM后台修改了活动

    -- 精英暴动
    EVENT_HARD_RIOT_OPEN_BATTLE_SCENE       = "event_hard_riot_open_battle_scene", --请求战斗
    EVENT_HARD_RIOT_UPDATE_MAIN_LAYER       = "event_hard_riot_update_main_layer", --更新riot主界面,从无到有，从有到无

    -- 世界Boss
    EVENT_REBEL_BOSS_ENTER_MAIN_LAYER       = "event_rebel_boss_enter_main_layer", --进入主界面
    EVENT_REBEL_BOSS_INSPIRE_SUCC           = "event_rebel_boss_inspire_succ", --鼓舞成功
    EVENT_REBEL_BOSS_GET_HONOR_RANK         = "event_rebel_boss_get_honor_rank",  -- 获得荣誉排行榜
    EVENT_REBEL_BOSS_GET_MAX_HARM_RANK      = "event_rebel_boss_get_max_harm_rank",  -- 获得最高伤害排行榜
    EVENT_REBEL_BOSS_REFRESH_REBEL_BOSS     = "event_rebel_boss_refresh_rebel_boss", -- 每3秒或5秒，飞一次伤害值 
    EVENT_REBEL_BOSS_OPEN_BATTLE_SCENE      = "event_rebel_boss_open_battle_scene", --打开战斗
    EVENT_REBEL_BOSS_UPDATE_MAIN_LAYER_EACH_5_SECONDS = "event_rebel_boss_update_main_layer_each_5_seconds", --每隔5秒，更新一下主界面
    EVENT_REBEL_BOSS_PURCHASE_CHALLENGE_TIME_SUCC = "event_rebel_boss_purchase_challenge_time_succ", -- 购买挑战次数成功
    EVENT_REBEL_BOSS_CHOOSE_GROUP_SUCC      = "event_rebel_boss_choose_group_succ", --选择阵营成功
    EVENT_REBEL_BOSS_GET_BOSS_REPORT        = "event_rebel_boss_get_boss_report",
    EVENT_REBEL_BOSS_GET_CLAIMED_AWARD_LIST = "event_rebel_boss_get_claimed_award_list", --
    EVENT_REBEL_BOSS_CLIAM_AWARD_SUCC       = "event_rebel_boss_claim_award_succ", -- 领取奖励成功
    EVENT_REBEL_BOSS_SHOW_AWARD_TIPS        = "event_rebel_boss_show_award_tips", -- 领奖按钮上的红点
    EVENT_REBEL_BOSS_UPDATE_CHALLENGE_TIME_RECOVER = "event_rebel_boss_update_challenge_time_recover", -- 挑战次数恢复时间戳
    EVENT_REBEL_BOSS_SHOW_QUICK_ENTER = "event_rebel_boss_show_quick_enter", --征战界面Boss快捷入口
    EVENT_REBEL_BOSS_UPDATE_MY_HONOR = "event_rebel_boss_update_my_honor", --更新主界面自己的荣誉值及排行
    EVENT_REBEL_BOSS_UPDATE_MY_MAXHARM = "event_rebel_boss_update_my_maxharm", --更新主界面自己的最大伤害值及排行
    EVENT_REBEL_BOSS_UPDATE_MY_LEGION_RANK = "event_rebel_boss_update_my_legion_rank", --更新主界面自己的最大伤害值及排行

    --新手光环
    EVENT_ROOKIE_GET_INFO = "event_rookie_get_info",        --获取新手基本信息
    EVENT_ROOKIE_GET_REWARD = "event_rookie_get_reward",    --获取新手奖励

    -- 限时优惠
    EVENT_TIME_PRIVILEGE_INIT_MAIN_LAYER = "event_time_privilege_init_main_layer",
    EVENT_TIME_PRIVILEGE_GET_AWARD_INFO_SUCC = "event_time_privilege_get_award_info_succ",
    EVENT_TIME_PRIVILEGE_GET_AWARD_SUCC = "event_time_privilege_get_award_succ",
    EVENT_TIME_PRIVILEGE_BUY_GOODS_SUCC = "event_time_privilege_buy_goods_succ",
    EVENT_TIME_PRIVILEGE_GET_OPEN_SERVER_SUCC = "event_time_privilege_get_open_server_succ",
    EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON = "event_time_privilege_main_scene_show_icon",

    -- 争粮战
    EVENT_ROB_RICE_GET_USER_RICE            = "event_rob_rice_get_rice_info",  -- 获取粮草信息
    EVENT_ROB_RICE_UPDATE_USER_RICE         = "event_rob_rice_update_rice",  -- 更新粮草信息，包括对手的
    EVENT_ROB_RICE_FLUSH_RICE_RIVALS        = "event_rob_rice_flush_rice_rivals",  -- 刷新对手   
    EVENT_ROB_RICE_ROB_RICE                 = "event_rob_rice_rob_rice",  -- 抢粮
    EVENT_ROB_RICE_CHANGE_USER_RICE         = "event_rob_rice_change_user_rice",  -- 更新客户端玩家粮草信息
    EVENT_ROB_RICE_RANK_LIST                = "event_rob_rice_rank_list",
    EVENT_ROB_RICE_GET_RICE_ENEMY           = "event_rob_rice_get_rice_enemy",
    EVENT_ROB_RICE_GET_REVENGE_ENEMY        = "event_rob_rice_get_revenge_enemy",
    EVENT_ROB_RICE_BUY_RICE_TOKEN           = "event_rob_rice_buy_rice_token",
    EVENT_ROB_RICE_GET_RICE_ACHIEVEMENT     = "event_rob_rice_get_rice_achievement",
    EVENT_ROB_RICE_GET_RANK_AWARD           = "event_rob_rice_get_rice_rank_award",
    EVENT_ROB_RICE_FLUSH_USER_RANK          = "event_rob_rice_flush_user_rank",
    EVENT_ROB_RICT_NOT_ATTENT               = "event_rob_rice_not_attent",

    -- 武将变身
    EVENT_KNIGHT_TRANSFORM_SELECT_SOURCE_KINGHT_SUCC = "event_knight_transform_select_source_knight_succ", -- 成功选择了一个源武将
    EVENT_KNIGHT_TRANSFORM_SELECT_TARGET_KINGHT_SUCC = "event_knight_transform_select_target_knight_succ", -- 成功选择了一个目标武将
    EVENT_KNIGHT_TRANSFORM_TRANSFORM_SUCC = "event_knight_transform_transform_succ", -- 武将变身成功

    -- 限时抽将
    EVENT_THEME_DROP_ENTER_MAIN_LAYER = "event_theme_drop_enter_main_layer",
    EVENT_THEME_DROP_ASTROLOGY_SUCC = "event_theme_drop_astrology_succ",
    EVENT_THEME_CLAIM_RED_KNIGHT_SUCC = "event_theme_drop_claim_red_knight_succ",
    EVENT_THEME_DROP_UPDATE_SHOP_TIPS = "event_theme_drop_update_shop_tips", -- speedbar上商城的红点

    -- 三国无双精英Boss
    EVENT_WUSH_BOSS_INFO            = "event_wush_boss_info",
    EVENT_WUSH_BOSS_CHALLENGE       = "event_wush_boss_challenge",
    EVENT_WUSH_BOSS_BUY             = "event_wush_boss_buy",

    -- 百战沙场
    EVENT_CRUSADE_UPDATE_BATTLEFIELD_INFO    = "event_crusade_update_battlefield_info",
    EVENT_CRUSADE_UPDATE_BATTLEFIELD_DETAIL  = "event_crusade_update_battlefield_detail",
    EVENT_CRUSADE_CHALLENGE_REPORT           = "event_crusade_challenge_report",
    EVENT_CRUSADE_UPDATE_AWARD_INFO          = "event_crusade_update_award_info",
    EVENT_CRUSADE_GET_AWARD                  = "event_crusade_get_award",
    EVENT_CRUSADE_GET_SHOP_INFO              = "event_crusade_get_shop_info",
    EVENT_CRUSADE_REFRESH_SHOP               = "event_crusade_refresh_shop",
    EVENT_CRUSADE_FLUSH_BATTLEFIELD_INFO     = "event_crusade_flush_battlefield_info",
    EVENT_CRUSADE_GET_RANK                   = "event_crusade_get_rank",
    

    -- 限时团购
    EVENT_GROUPBUY_MAINLAYER_UPDATE = "event_groupbuy_mainlayer_update",
    EVENT_GROUPBUY_DAILY_AWARD_GET  = "event_groupbuy_daily_award_get",
    EVENT_GROUPBUY_DAILY_AWARD_LOAD = "event_groupbuy_daily_award_load",
    EVENT_GROUPBUY_RANK_UPDATE      = "event_groupbuy_rank_update",
    EVENT_GROUPBUY_GET_REWARD       = "event_groupbuy_get_reward",
    EVENT_GROUPBUY_BUY_REWARD       = "event_groupbuy_buy_reward",

    EVENT_PET_GET            = "event_pet_get",
    EVENT_PET_UPLVL       = "event_pet_uplvl",
    EVENT_PET_UPSTAR             = "event_pet_upstar",
    EVENT_PET_UPADDITION             = "event_pet_upaddition",
    EVENT_PET_CHANGE             = "event_pet_change",

    -- 新版日常副本
    EVENT_DUNGEON_DAILY_INFO        = "event_dungeon_daily_info",
    EVENT_DUNGEON_DAILY_CHALLENGE   = "event_dungeon_daily_challenge",

    -- 神将、觉醒、战宠商店，有免费刷新次数
    EVENT_SHOP_HAS_FREE_REFRESH_COUNT = "event_shop_has_free_refresh_count",

    --奇门八卦
    EVENT_TRIGRAMS_UPDATE_INFO = "event_trigrams_update_info",
    EVENT_TRIGRAMS_REFRESH_INFO = "event_trigrams_refresh_info",
    EVENT_TRIGRAMS_PLAY_RESULT = "event_trigrams_play_result",
    EVENT_TRIGRAMS_PLAY_ALL_RESULT= "event_trigrams_play_all",
    EVENT_TRIGRAMS_GET_REWARD= "event_trigrams_get_reward",
    EVENT_TRIGRAMS_UPDATE_RANK= "event_trigrams_update_rank",

    -- 跨服夺帅
    EVENT_CROSS_PVP_GET_SCHEDULE            = "event_cross_pvp_get_schedule",           -- 获取所有比赛时间和赛场配置
    EVENT_CROSS_PVP_GET_BASE_INFO           = "event_cross_pvp_get_base_info",          -- 获取玩家的基本比赛信息
    EVENT_CROSS_PVP_GET_FIELD_INFO          = "event_cross_pvp_get_field_info",         -- 获取赛区信息
    EVENT_CROSS_PVP_APPLY                   = "event_cross_pvp_apply",                  -- 报名完成
    EVENT_CROSS_PVP_GET_LAST_RANK           = "event_cross_pvp_get_last_rank",          -- 获取上一轮比赛排行
    EVENT_CROSS_PVP_GET_REVIEW_INFO         = "event_cross_pvp_get_review_info",        -- 获取上一轮比赛回顾信息
    EVENT_CROSS_PVP_GET_BET_INFO            = "event_cross_pvp_get_bet_info",           -- 获取投注信息
    EVENT_CROSS_PVP_BET_FINISH              = "event_cross_pvp_bet_finish",             -- 投注完成
    EVENT_CROSS_PVP_GET_BET_AWARD           = "event_cross_pvp_get_bet_award",          -- 领取投注奖励完成
    EVENT_CROSS_PVP_GET_BET_RANK            = "event_cross_pvp_get_bet_rank",           -- 拉取投注排行
    EVENT_CROSS_PVP_INSPIRE_SUCC            = "event_cross_pvp_inspire_succ",           -- 一次鼓舞成功
    EVENT_CROSS_PVP_GET_ROLE_SUCC           = "event_cross_pvp_get_role_succ",          -- 角色信息
    EVENT_CROSS_PVP_ENTER_FIGHT_MAIN_LAYER  = "event_cross_pvp_enter_fight_main_layer",
    EVENT_CROSS_PVP_GET_SCORE_RANK_SUCC     = "event_cross_pvp_get_score_rank_succ",    -- 获取积分排行榜
    EVENT_CROSS_PVP_ENTER_FIGHT_END_LAYER   = "event_cross_pvp_enter_fight_end_layer",
    EVENT_CROSS_PVP_UPDATE_ARENA            = "event_cross_pvp_update_arena",           --更新每一个坑位
    EVENT_CROSS_PVP_UPDATE_ARENA_SPECIAL    = "event_cross_pvp_update_arena_special",   --更新每一个坑位, 特殊（坑位被占或人被T）
    EVENT_CROSS_PVP_UPDATE_SELF_SCORE       = "event_crop_pvp_update_self_score",       --战场里，自己的积分变化
    EVENT_CROSS_PVP_FIGHT_SOMEONE_SUCC      = "event_cross_pvp_fight_someone_succ",     --和某人打架，或直接占一个坑
    EVENT_CROSS_PVP_GET_FLOWER_RANK_SUCC    = "event_cross_pvp_get_flower_rank_succ",   -- 获取4个战场的鲜花第一的人
    EVENT_CROSS_PVP_UPDATE_SELF_ROOM_SCORE  = "event_cross_update_self_room_score",
    EVENT_CROSS_PVP_GET_OB_RIGHT_SUCC = "event_corss_pvp_get_ob_right_succ",  --玩家有没有ob权限
    EVENT_CROSS_PVP_GET_PROMOTED_AWARD_SUCC = "event_cross_pvp_get_promoted_award_succ", --领取晋级奖励成功
    EVENT_CROSS_PVP_GET_BULLET_SCREEN_INFO_SUCC = "event_cross_pvp_get_bullet_screen_info_succ",        
    EVENT_CROSS_PVP_SEND_BULLET_SCREEN_SUCC = "event_cross_pvp_send_bullet_screen_succ",    -- 发送弹幕信息成功
    EVENT_CROSS_PVP_GET_BULLET_SCREEN_CONTENT_SUCC = "event_cross_pvp_get_bullet_screen_content_succ", -- 收取到后端flush的弹幕信息成功

    -- 道具合成
    EVENT_ITEM_COMPOSE_RESULT = "event_item_compose_result",

    --中秋活动
    EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY = "event_get_special_holiday_activity",
    EVENT_UPDATE_SPECIAL_HOLIDAY_ACTIVITY = "event_update_special_holiday_activity",
    EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY_REWARD = "event_get_special_holiday_activity_reward",
    EVENT_GET_SPECIAL_HOLIDAY_SALES = "event_get_special_holiday_sales",
    EVENT_BUY_SPECILA_HOLIDAY_SALE = "event_buy_special_holiday_sale",

    -- 过关斩将
    EVENT_EX_DUNGEON_GET_CHAPTER_LIST_SUCC = "event_ex_dungeon_get_chapter_list_succ",
    EVENT_EX_DUNGEON_EXCUTE_STAGE_SUCC = "event_ex_dungeon_excute_stage_succ",
    EVENT_EX_DUNGEON_GET_CHAPTER_AWARD_SUCC = "event_ex_dungeon_get_chapter_award_succ",
    EVENT_EX_DUNGEON_FIRST_ENTER_CHAPTER_SUCC = "event_ex_dungeon_first_enter_chapter_succ",
    EVENT_EX_DUNGEON_BUY_ITEM_SUCC = "event_ex_dungeon_buy_item_succ",

    --每日pvp
    EVENT_TEAMPVPSTATUS = "event_teampvpstatus",
    EVENT_TEAMPVPCREATETEAM= "event_teampvpcreateteam",
    EVENT_TEAMPVPJOINTEAM = "event_teampvpjointeam",
    EVENT_TEAMPVPLEAVE= "event_teampvpleave",
    EVENT_TEAMPVPKICKTEAMMEMBER= "event_teampvpkickteammember",
    EVENT_TEAMPVPSETTEAMONLYINVITED= "event_teampvpsetteamonlyinvited",
    EVENT_TEAMPVPINVITE= "event_teampvpinvite",
    EVENT_TEAMPVPBEINVITED= "event_teampvpbeinvited",
    EVENT_TEAMPVPINVITEDJOINTEAM= "event_teampvpinvitedjointeam",
    EVENT_TEAMPVPINVITECANCELED = "event_teampvpinvitecanceled",
    EVENT_TEAMPVPINVITENPC = "event_teampvpinvitenpc",
    EVENT_TEAMPVPAGREEBATTLE = "event_teampvpagreebattle",
    EVENT_TEAMPVPMATCHOTHERTEAM = "event_teampvpmatchotherteam",
    EVENT_TEAMPVPCHANGEPOSITION = "event_teampvpchangeposition",
    EVENT_TEAMPVPBATTLERESULT = "event_teampvpbattleresult",
    EVENT_TEAMPVPSTOPMATCH = "event_teampvpstopmatch",
    EVENT_TEAMPVPHISTORYBATTLEREPORT = "event_teampvphistorybattlereport",
    EVENT_TEAMPVPHISTORYBATTLEREPORTEND = "event_teampvphistorybattlereportend",
    EVENT_TEAMPVPGETRANK = "event_teampvpgetrank",
    EVENT_TEAMPVPGETUSERINFO = "event_teampvpgetuserinfo",
    EVENT_TEAMPVPBUYAWARDCNT = "event_teampvpbuyawardcnt",
    EVENT_TEAMPVPNOTINTEAM = "event_teampvpnotinteam",
    EVENT_TEAMPVPACCEPTINVITE = "event_teampvpacceptinvite",
    EVENT_TEAMPVPTEAMCOMEFULL = "event_teampvpteamcomefull",
    EVENT_TEAMPVPTEAMCOMENOTFULL = "event_teampvpteamcomenotfull",
    EVENT_TEAMPVPTEAMINMATCH = "event_teampvpteaminmatch",
    EVENT_TEAMPVPTEAMOUTMATCH = "event_teampvpteamoutmatch",
    EVENT_TEAMPVPTEAMCHATMSG = "event_teampvpteamchatmsg",
    EVENT_TEAMPVPTEAMPOPCHAT = "event_teampvpteampopchat",

    --商店标签,方便玩家购买合成所需材料
    EVENT_GetShopTag = "event_getshoptag",
    EVENT_AddShopTag = "event_addshoptag",
    EVENT_DelShopTag = "event_delshoptag",

    -- 开服7日战力榜
    EVENT_SEVEN_DAY_FIGHT_VALUE_RANK_GET_AWARD = "event_seven_day_fight_value_rank_get_award",
    EVENT_SEVEN_DAY_FIGHT_VALUE_RANK_COMP_INFO = "event_seven_day_fight_value_rank_comp_info",

    EVENT_RCARDINFO = "event_rcardinfo",
    EVENT_RCARDPLAY = "event_rcardplay",
    EVENT_RCARDRESET = "event_rcardreset",

    -- 将灵
    EVENT_HERO_SOUL_GET_SOUL_INFO = "event_hero_soul_get_soul_info", -- 拉取将灵基本信息
    EVENT_HERO_SOUL_GET_CHART_RANK = "event_hero_soul_get_chart_rank", -- 拉取阵图排行
    EVENT_HERO_SOUL_GET_SHOP_INFO_SUCC = "event_hero_soul_get_shop_info_succ",  --成功获取到商品信息
    EVENT_HERO_SOUL_REFRESH_SUCC = "event_hero_soul_refresh_succ", --刷新成功
    EVENT_HERO_SOUL_BUY_SUCC = "event_hero_soul_buy_succ",  --购买商品成功

    EVENT_HERO_SOUL_GET_DUNGEON_INFO_SUCC = "event_hero_soul_get_dungeon_info_succ", --进入副本或刷新副本
    EVENT_HERO_SOUL_ACQUIRE_CHALLENGE_SUCC = "event_hero_soul_acquire_challenge_succ", --请求战斗成功

    EVENT_HERO_SOUL_EXTRACT_SUCC = "event_hero_soul_extract_succ",  --点将成功
    EVENT_HERO_SOUL_QIYU_BUY_SUCC = "event_hero_soul_qiyu_buy_succ", -- 奇遇值买将灵

    EVENT_HERO_SOUL_DECOMPOSE = "event_hero_soul_decompose", -- 分解将灵
    EVENT_HERO_SOUL_ACTIVATE_CHART = "event_hero_soul_activate_chart", -- 激活阵图
    EVENT_HERO_SOUL_ACTIVATE_ACHIEVEMENT = "event_hero_soul_activate_achievement", -- 激活成就

    EVENT_HERO_SOUL_SET_FIGHT_BASE = "event_hero_soul_set_fight_base", -- 设置战斗底座

    EVENT_ACTIVITY_FORTUNE_BUY_SUCCEED = "event_activity_fortune_buy_succeed",
    EVENT_ACTIVITY_FORTUNE_GET_BOX_AWARD = "event_activity_fortune_get_box_award",
    EVENT_ACTIVITY_FORTUNE_GET_INFO = "event_activity_fortune_get_info",
}


return EventMsgID

