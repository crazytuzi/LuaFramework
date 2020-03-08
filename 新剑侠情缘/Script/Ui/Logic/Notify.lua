-----------------------------------------------------
--文件名		：	uinotify.lua
--创建者		：
--创建时间		：
--功能描述		：	界面事件。
------------------------------------------------------

-- 消息类型枚举，与ClientScene.h中的 EVENT_NOTIFY 枚举值必须一致，
-- 否则界面不能正确响应Core抛出的事件
UiNotify.emNOTIFY_GAME_INIT_FINISH			= 0;
UiNotify.emNOTIFY_GATEWAY_CONNECT			= 1;
UiNotify.emNOTIFY_GATEWAY_CONNECT_LOST		= 2;
UiNotify.emNOTIFY_SERVER_LIST_DONE			= 3;
UiNotify.emNOTIFY_SERVER_CONNECT			= 4;
UiNotify.emNOTIFY_SERVER_CONNECT_LOST		= 5;
UiNotify.emNOTIFY_SYNC_ROLE_LIST_DONE		= 6;
UiNotify.emNOTIFY_SYNC_PLAYER_DATA_END		= 7;
UiNotify.emNOTIFY_CREATE_ROLE_RESPOND		= 8;
UiNotify.emNOTIFY_CHANGE_PK_MODE			= 9;
UiNotify.emNOTIFY_CHANGE_FIGHT_STATE		= 10;
UiNotify.emNOTIFY_RECONNECT_FAILED			= 11;
UiNotify.emNOTIFY_CHANGE_PLAYER_NAME        = 12; --改变玩家的名称
UiNotify.emNOTIFY_CHANGE_PLAYER_HP          = 13; --改变玩家的血量
UiNotify.emNOTIFY_CHANGE_PLAYER_EXP         = 14; --改变玩家的EXP
UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL       = 15; --改变玩家的EXP
UiNotify.emNOTIFY_CHAT_NEW_MSG              = 16; --来新的聊天消息了..
UiNotify.emNOTIFY_CHAT_COLOR_MSG            = 17; --更新彩聊
UiNotify.emNOTIFY_SYNC_ITEM					= 18;
UiNotify.emNOTIFY_DEL_ITEM 					= 19;
UiNotify.emNOTIFY_CONNECT_SERVER 			= 20;
UiNotify.emNOTIFY_CONNECT_SERVER_END		= 21;
UiNotify.emNOTIFY_WND_OPENED				= 22;	-- 打开界面
UiNotify.emNOTIFY_WND_CLOSED				= 23;	-- 关闭界面
UiNotify.emNOTIFY_SKILL_LEVELUP 			= 24;
UiNotify.emNOTIFY_TEAM_UPDATE				= 25; -- 队伍数据改变
UiNotify.emNOTIFY_QUICK_TEAM_UPDATE			= 26; -- 快速组队
UiNotify.emNoTIFY_SKILL_CD                  = 27;   --更新技能CD
UiNotify.emNOTIFY_MAP_LOADED				= 28;
UiNotify.emNOTIFY_MAP_LEAVE					= 29;
UiNotify.emNoTIFY_NEW_PRIVATE_MSG			= 30; 	--新的好友密聊消息
UiNotify.emNoTIFY_SYNC_FRIEND_REQUEST		= 31;	--同步了好友数据里是好友申请的 todo 其他同类型的也可以放一起
UiNotify.emNoTIFY_SYNC_FRIEND_DATA			= 32;	--更新好友数据时
UiNotify.emNOTIFY_SYNC_PARTNER_ADD			= 33;	-- 新增同伴
UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE		= 34;	-- 改变同伴数据
UiNotify.emNOTIFY_SYNC_PARTNER_DELETE		= 35;	-- 删除同伴
UiNotify.emNOTIFY_SYNC_PARTNER_POS			= 36;	-- 更改同伴出战
UiNotify.emNOTIFY_SYNC_FLY_CHAR             = 37;
UiNotify.emNOTIFY_NPC_DEATH                 = 38;
UiNotify.emNOTIFY_CHANGE_FEATURE			= 39;	-- 更改角色外观
UiNotify.emNOTIFY_UPDATE_SERVER_LIST		= 40;
UiNotify.emNOTIFY_ADD_SKILL                 = 41;
UiNotify.emNOTIFY_SYNC_KIN_DATA				= 42;
UiNotify.emNOTIFY_SYNC_ACC_SER_INFO			= 43;   -- 各帐号在各区服的等级信息
UiNotify.emNOTIFY_SYNC_RANK					= 44;	-- 更新竞技场数据
UiNotify.emNOTIFY_SYNC_BATTLEARRAY			= 45;	-- 更新布阵信息
UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER    = 46;   -- 改变了功力的加成
UiNotify.emNOTIFY_CHANGE_MONEY 				= 47; 	-- 金钱发生改变
UiNotify.emNOTIFY_UI_AUTO_HIDE				= 48;	-- UI 自动隐藏
UiNotify.emNOTIFY_SYNC_BOSS_DATA			= 49;
UiNotify.emNOTIFY_GATEWAY_HANDED			= 50;
UiNotify.emNOTIFY_IFLY_IAT_RESULT			= 52;
UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG		= 53;	-- 新的提示处理消息
UiNotify.emNOTIFY_NOTIFY_NEW_MAIL			= 54;	-- 新的邮件
UiNotify.emNOTIFY_SYNC_MAIL_DATA			= 55;	-- 新的邮件
UiNotify.emNOTIFY_LOAD_RES_FINISH			= 56;	-- 加载完资源
UiNotify.emNOTIFY_FUBEN_SECTION_PANEL		= 57;	-- 关卡UI
UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE		= 59;	-- 副本指引信息改动
UiNotify.emNOTIFY_CHANGE_AUTOFIGHT			= 60;	-- 自动战斗状态改变
UiNotify.emNOTIFY_BOSS_ROB_BATTLE			= 61;	-- 武林盟主异步战斗通知
UiNotify.emNOTIFY_SYNC_EVERYDAY_TARGET		= 62;	-- 每日目标同步
UiNotify.emNOTIFY_UPDATE_TITLE				= 63;
UiNotify.emNOTIFY_CARD_PICKING				= 64;
UiNotify.emNOTIFY_CENTER_MSG				= 65;	-- 中屏信息
UiNotify.emNOTIFY_UPDATE_TASK				= 66;	-- 任务更新
UiNotify.emNOTIFY_CHANGE_VIP_LEVEL			= 66;	--vip等级变化
UiNotify.emNOTIFY_SYNC_SHOP_WARE			= 67;	--同步商店货物
UiNotify.emNOTIFY_SHOP_BUY_RESULT			= 68;	--商店购买结果
UiNotify.emNOTIFY_SHOP_SELL_RESULT			= 69;	--商店出售结果
UiNotify.emNOTIFY_PRAY_SYNC					= 70;	--祈福同步
UiNotify.emNOTIFY_PRAY_ANI_CON				= 71;	--祈福动画控制
UiNotify.emNOTIFY_UPDATE_COLORMSG_COUNT		= 72;	--更新彩聊次数
UiNotify.emNOTIFY_ANIMATION_FINISH			= 73;
UiNotify.emNOTIFY_ADD_SPECIAL_STATE         = 74;
UiNotify.emNOTIFY_REMOVE_SPECIAL_STATE      = 75;
UiNotify.emNOTIFY_CHANGE_PORTRAIT			= 76;	--更改玩家头像
UiNotify.emNOTIFY_ADD_PORTRAIT				= 77;	--增加玩家头像
UiNotify.emNOTIFY_SYNC_BATTLE_REPORT		= 78;	--同步战报数据
UiNotify.emNOTIFY_GET_DEBRIS				= 79; 	--获取装备碎片时
UiNotify.emNOTIFY_DEBRIS_UPDATE				= 80; 	--装备碎片界面更新
UiNotify.emNOTIFY_SYNC_DEBRIS_ROB_DATA		= 81; 	--同步了碎片抢夺列表数据
UiNotify.emNOTIFY_ON_DEBRIS_CARD_AWARD		= 82; 	--获得了碎片翻牌奖励时
UiNotify.emNOTIFY_HOME_TASK_FOLD			= 83; 	--显示隐藏主界面 任务按钮 --todo 废弃 已没用到
UiNotify.emNOTIFY_MAP_EXPLORE_PANEL			= 84;	--地图探索UI
UiNotify.emNOTIFY_RECHARGE_PANEL			= 85;	--更新充值界面
UiNotify.emNOTIFY_SYNC_BATTLE_OPEN			= 86;	--同步战场开启信息
UiNotify.emNoTIFY_SYNC_COMMERCE_DATA		= 87;	--同步商会任务数据
UiNotify.emNoTIFY_SYNC_COMMERCE_HELP		= 88;	--同步商会任务求助信息
UiNotify.emNOTIFY_SHAPE_SHIFT               = 89;
UiNotify.emNOTIFY_REMOVE_SHAPE_SHIFT        = 90;
UiNotify.emNOTIFY_WELFARE_UPDATE			= 91;	--活动更新通知
UiNotify.emNOTIFY_PRIVATE_MSG_NUM_CHANGE	= 92;	--私聊消息数量变化，不是获得新消息
UiNotify.emNOTIFY_STRENGTHEN_RESULT 		= 93; 	--强化变动
UiNotify.emNOTIFY_INSET_RESULT 				= 94;	--镶嵌变动
UiNotify.emNOTIFY_COMBINE_RESULT 			= 95;	--合成结果
UiNotify.emNOTIFY_SYNC_CALENDAR_REDPOINT	= 96;	--日历红点通知
UiNotify.emNOTIFY_SYNC_RANKBOARD_DATA		= 97;	--同步排行榜数据
UiNotify.emNOTIFY_HELPER_GET_STRANGER		= 98;	--获取陌生人数据
UiNotify.emNOTIFY_HELPER_GET_SYNCDATA		= 99;	--助战选择回调
UiNotify.emNOTIFY_ACTIVITY_QUESTION_UPDATE	= 100;	--答题活动数据更新
UiNotify.emNOTIFY_MONEYTREE_RESPOND			= 101;	--摇钱树活动回包
UiNotify.emNOTIFY_TASK_FINISH				= 102;	--完成任务
UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS		= 103;	--购买次数成功
UiNotify.emNOTIFY_PARTNER_FAMILIAR_MAX 		= 104;	--同伴亲密度达到满值
UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC 	= 105;	--成就数据更新
UiNotify.emNOTIFY_NEED_ACCOUT_ACTIVE	 	= 106;	--需要帐号激活
UiNotify.emNOTYFY_SYNC_ITEMS_BEGIN			= 107;	--开始批量同步道具
UiNotify.emNOTYFY_SYNC_ITEMS_END			= 108;	--开始批量同步道具
UiNotify.emNOTIFY_ONCOMPOSE_CALLBACK 		= 109;	--同伴碎片合成回调
UiNotify.emNOTIFY_ON_CLOSE_DIALOG	 		= 110;	--关闭剧情对话时
UiNotify.emNOTIFY_PARTNER_FAMILIAR_CHANGE 	= 111;	--同伴亲密度改变										******* 废弃
UiNotify.emNOTIFY_MAP_ENTER					= 112;  --进入地图时
UiNotify.emNOTIFY_ACTIVE_RUNTIME_DATA		= 113;	--活动实时数据（各个活动共用）
UiNotify.emNOTIFY_KINGATHER_UPDATE 			= 114;	--家族篝火ui数据刷新
UiNotify.emNOTIFY_GET_STAR_AWARD			= 115;	--领取关卡星级奖励
UiNotify.emNOTIFY_FINISH_PERSONALFUBEN		= 116;	--完成关卡
UiNotify.emNOTIFY_ACTIVITY_STATE_UPDATE		= 117; 	--活动状态改变
UiNotify.emNOTIFY_PERSONALFUBEN_TIMES_CHANGE = 118; --关卡次数改动
UiNotify.emNoTIFY_PERSONALFUBEN_ANI_OVER 	= 119;	--副本动画完毕，播放升级动画
UiNotify.emNOTIFY_MONEYTREE_DATA_UPDATE 	= 120;  --摇钱树数据修改
UiNotify.emNOTIFY_FORBIDDEN_OPERATION 		= 121;  --禁止操作
UiNotify.emNOTIFY_NEED_CLIENT_UPDATE		= 122;  --客户端需要更新
UiNotify.emNOTIFY_ADD_SKILL_STATE			= 123;	--添加BUFF
UiNotify.emNOTIFY_REMOVE_SKILL_STATE		= 124;	--移除BUFF
UiNotify.emNOTIFY_CLOSE_TO_NCP				= 125;	--靠近Npc
UiNotify.emNOTIFY_CHANGE_CAMP				= 126;  --改变阵营
UiNotify.emNOTIFY_RECORD_BEGIN				= 127;
UiNotify.emNOTIFY_RECORD_END				= 128;
UiNotify.emNOTIFY_VOICE_RECORD_VOLUME_CHANG	= 129; --语音输入时声音大小变化
UiNotify.emNOTIFY_VOICE_PLAY_VOLUME_CHANG	= 130; --播放语音时声音大小变化
UiNotify.emNOTIFY_VOICE_PLAY_START			= 131; --开始播放语音
UiNotify.emNOTIFY_VOICE_PLAY_END			= 132; --播放语音结束
UiNotify.emNOTIFY_FIGHT_POWER_CHANGE		= 133; --战斗力变化时
UiNotify.emNOTIFY_DROP_ITEM_TYPE			= 134;
UiNotify.emNOTIFY_UPDATE_JUBAOPEN			= 135; --更新聚宝盆
UiNotify.emNOTIFY_SYNC_KIN_BATTLE_DATA		= 136; --家族战数据同步事件
UiNotify.emNOTIFY_SWEEP_OVER				= 137; --副本扫荡完毕
UiNotify.emNOTIFY_TEAM_BATTLE_KILL_INFO		= 138; --通天塔本顶部击杀显示
UiNotify.emNOTIFY_TEAM_BATTLE_TIME			= 139; --通天塔顶部倒计时
UiNotify.emNOTIFY_FACTION_TOP_CHANGE		= 140; --门派竞技16强更新
UiNotify.emNOTIFY_TEAM_BATTLE_HIDE_SCORE	= 141; --隐藏通天塔比分
UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE		= 142; --动态聊天频道变更
UiNotify.emNOTIFY_SHOW_DIALOG				= 143; --开始显示对话
UiNotify.emNOTIFY_PG_INIT					= 144;
UiNotify.emNOTIFY_PG_CLOSE					= 145;
UiNotify.emNOTIFY_PG_PARTNER_DEATH			= 146;
UiNotify.emNOTIFY_PG_PARTNER_NPC_CHANGE		= 147;
UiNotify.emNOTIFY_PG_PARTNER_SWITCH_GROUP	= 148;
UiNotify.emNOTIFY_MISSION_AWARD_ONRESULT	= 149;
UiNotify.emNOTIFY_MISSION_AWARD_UPDATE		= 150;
UiNotify.emNOTIFY_TASK_HAS_CHANGE			= 151;
UiNotify.emNOTIFY_UPDATE_FUBEN_SCROE		= 152;
UiNotify.emNOTIFY_QYHLEFT_INFO_UPDATE		= 153;
UiNotify.emNOTIFY_LOGINAWARDS_CALLBACK		= 154;
UiNotify.emNOTIFY_CHANGE_ACTION_MODE		= 155;
UiNotify.emNOTIFY_NEED_ACCOUT_REG	 		= 156;	--需要帐号注册
UiNotify.emNOTIFY_FORBIDDEN_PARTNER			= 157;
UiNotify.emNOTIFY_SYN_MAP_ALL_POS			= 158;  --同步地图的所有玩家位置
UiNotify.emNOTIFY_MS_ITEM_LIST_CHANGE		= 159;	--摆摊物品列表更新
UiNotify.emNOTIFY_MS_MY_ITEM_LIST_CHANGE	= 160;	--摆摊我的出售列表更新
UiNotify.emNOTIFY_LOGIN_QUEUE_NOTIFY 		= 161;	--排队位置同步
UiNotify.emNOTIFY_LOGIN_HAND_SHAKE_END 		= 162;	--登录握手结束
UiNotify.emNOTIFY_FAKE_JOYSTICK_GUIDING		= 163;	--设置假摇杆指引状态
UiNotify.emNOTIFY_FAKE_JOYSTICK_STATE		= 164;	--设置假摇杆状态
UiNotify.emNOTIFY_SYNC_AUCTION_DATA			= 165;	--同步家族数据
UiNotify.emNOTIFY_FUBEN_STOP_ENDTIME		= 166;	--暂停副本倒计时
UiNotify.emNOTIFY_VALUE_COMPOSE_FINISH		= 167;	--碎片合成成功
UiNotify.emNOTIFY_SYNC_PLAYER_SET_POS 		= 168; --设置位置
UiNotify.emNOTIFY_SYNC_KIN_TRAIN_MAT 		= 169;  --家族试炼物资同步
UiNotify.emNOTIFY_LOGIN_SERVER_UNAVAILABLE 	= 170;
UiNotify.emNOTIFY_UPDATE_SURVEY_STATE		= 171;	--问卷调查的状态更新
UiNotify.emNOTIFY_SYNC_NEARBY_TEAMS			= 172;	--同步附近队伍
UiNotify.emNOTIFY_CHANGE_SIT                = 173;
UiNotify.emNOTIFY_SYNC_DATA                 = 175;
UiNotify.emNOTIFY_GROUP_INFO                = 176;	--QQ或微信 群信息通知.
UiNotify.emNOTIFY_ONHOOK_GET_EXP_FINISH     = 177;	-- 离线挂机领取经验完成
UiNotify.emNOTIFY_REDBAG_DATA_REFRESH		= 178;	--红包信息变更
UiNotify.emNOTIFY_REDBAG_SINGLE_UPDATE		= 179;	--更新单个红包
UiNotify.emNOTIFY_SEND_GIFT_SUCCESS		    = 180;	-- 送花送草成功
UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH		= 181;	-- 送花送草成功
UiNotify.emNOTIFY_MS_ITEM_SOLD				= 182;	--摆摊物品卖出
UiNotify.emNoTIFY_FUBEN_PROGRESS_REFRESH	= 183;  --副本进度刷新
UiNotify.emNOTIFY_LOGIN_SERVER_FAIL			= 184; --登录world_server失败
UiNotify.emNOTIFY_CHAT_ROOM_STATUS			= 185; --通知实时语音可用状态
UiNotify.emNOTIFY_SYNC_QQ_BULUO_URL			= 186; -- 同步部落url
UiNotify.emNOTIFY_ON_HOME_TASK_FOLD			= 187; -- 主界面任务栏收起/展开事件
UiNotify.emNOTIFY_SHOWTEAM_NO_TASK 			= 188; --任务队伍ui(HomeScreenTask)禁止任务按钮操作
UiNotify.emNOTIFY_REFRESH_MESSAGE_BOX		= 189; --请求更新MessageBox内容
UiNotify.emNOTIFY_SUPPLEMENT_RSP 			= 190; --补领回包
UiNotify.emNOTIFY_EQUIP_MAKE_RSP			= 191;	--兵甲坊打造成功
UiNotify.emNOTIFY_LEADER_INFO_CHANGE		= 192;	-- 领袖信息改变
UiNotify.emNOTIFY_SURVEY_SEL_INPUT_CHANGE	= 193;	--问卷调查选择填空内容改变
UiNotify.emNOTIFY_MARKET_STALL_REFRESH_ALL	= 194;	--服务器更新摆摊数据
UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE    	= 195;	--更新传功进度条
UiNotify.emNOTIFY_FORBID_STATE_CHANGE    	= 196;	--零收益处罚
UiNotify.emNOTIFY_UPDATE_QQ_VIP_INFO		= 197;	-- QQ会员相关更新
UiNotify.emNOTIFY_NEW_REDBAG				= 198;	--收到新红包
UiNotify.emNOTIFY_PARTNER_REINITDATA		= 199;	--同步是否有已洗髓同伴
UiNotify.emNOTIFY_UPDATE_PLAT_FRIEND_INFO	= 200;	--同步同玩好友信息
UiNotify.emNOTIFY_ONSYNC_NEWINFORMATION 	= 201; --同步最新消息
UiNotify.emNOTIFY_ONACTIVITY_STATE_CHANGE	= 202;	--活动状态修改
UiNotify.emNOTIFY_GUIDE_RANGE_CHANGE 		= 203;  --引导范围修改
UiNotify.emNOTIFY_MS_GET_AVG_PRICE			= 204;	--摆摊获取平均价格
UiNotify.emNOTIFY_SHARE_PHOTO				= 205;	--截图分享
UiNotify.emNOTIFY_PARTNER_GRADE_LEVELUP		= 206;	--同伴突破
UiNotify.emNOTIFY_ONSYNC_MONKEY				= 207;	--同步大师兄数据
UiNotify.emNOTIFY_PLAT_SHARE_RESULT			= 208;	--平台分享结果
UiNotify.emNOTIFY_PANDORA_REFRESH_ICON    	= 209;	--精细化运营入口刷新
UiNotify.emNOTIFY_ONSYNC_DOMAIN_REPORT	    = 210;	--同步领土战战报
UiNotify.emNOTIFY_ONSYNC_DOMAIN_SUPPLY	    = 211;	--同步领土战物资
UiNotify.emNOTIFY_ONSYNC_DOMAIN_BASE	    = 212;	--同步领土战占领信息
UiNotify.emNOTIFY_ONSYNC_LEVEL_RANK		    = 213;	--同步等级排行活动信息
UiNotify.emNOTIFY_CHAT_DEL_PRIVATE		    = 214;	--删除密聊
UiNotify.emNOTIFY_PRECISE_CAST		    	= 215;	--开始/结束精准操作释放技能
UiNotify.emNOTIFY_PRECISE_TOUCH_UP	    	= 216;	--精准操作抬起手指
UiNotify.emNOTIFY_ONLINE_ONHOOK_STATE       = 217;  --同步在线托管状态
UiNotify.emNOTIFY_CHANGE_SAVE_BATTERY_MODE  = 218;  --改变省电模式状态
UiNotify.emNOTIFY_SYN_ARENA_DATA 			= 219;  --同步擂台擂主数据
UiNotify.emNOTIFY_SYN_ARENA_APPLY_DATA 		= 220;  --同步擂台申请数据
UiNotify.emNOTIFY_SYN_ARENA_DMAGE_DATA 		= 221;  --同步擂台玩家得分伤害
UiNotify.emNOTIFY_SYN_ARENA_TIME_DATA 		= 222;  --更新擂台时间
UiNotify.emNOTIFY_SYN_PLAYER_APPLY_ARENA_DATA  = 223;  --更新玩家申请擂台数据
UiNotify.emNOTIFY_REFRESH_WATCH  		    = 224;  --刷新观战
UiNotify.emNOTIFY_REFRESH_QYH_BTN       	= 225;  --QYHLeavePanel按钮刷新
UiNotify.emNOTIFY_CHANGE_FIGHTPARTNER_ID    = 226;  --
UiNotify.emNOTIFY_REFRESH_QYH_BTN_TEXIAO    = 227;  --QYHLeavePanel按钮特效刷新
UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST	= 228;	--师徒更新寻找徒弟列表
UiNotify.emNOTIFY_TS_REFRESH_APPLY_LIST		= 229;	--师徒更新申请列表
UiNotify.emNOTIFY_TS_REFRESH_TARGET_WITH	= 230;	--师徒更新目标进度
UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS	= 231;	--师徒更新对方状态（目标、解散等）
UiNotify.emNOTIFY_TS_REFRESH_MAIN_INFO		= 232;	--师徒更新数据
UiNotify.emNOTIFY_TS_REFRESH_TEACHER_LIST	= 233;	--师徒更新寻找师父列表
UiNotify.emNOTIFY_DMG_RANK_UPDATE			= 234;	--BOSS输出排行数据刷新
UiNotify.emNOTIFY_XGSDK_CALLBACK			= 235;	--西瓜sdk相关的回调
UiNotify.emNoTIFY_RENOWN_SHOP_REFRESH		= 236;	--名望商店刷新
UiNotify.emNOTIFY_EQUIP_EVOLUTION			= 237;	--装备进化
UiNotify.emNOTIFY_EQUIP_TRAIN_ATTRIB		= 238;	--装备属性养成
UiNotify.emNOTIFY_IMPERIAL_TOMB_BOSS_STATUS	= 239;	--秦始皇BOSS状态刷新
UiNotify.emNOTIFY_PRIVILEGE_CALLBACK 		= 240;  --回归奖励
UiNotify.emNOTIFY_DATI_DATA_CHANGE 		    = 241;  --答题ui数据变更
UiNotify.emNOTIFY_SEND_BLESS_CHANGE 		= 242;  --送祝福数据改变时
UiNotify.emNOTIFY_SET_PLAYER_NAME 			= 243;  --设置其他玩家名字时
UiNotify.emNOTIFY_SKILL_USE_POINT 			= 244;  --技能使用豆
UiNotify.emNOTIFY_INDIFFER_BATTLE_FACTION	= 245;  --心魔幻境改门派成功
UiNotify.emNOTIFY_INDIFFER_BATTLE_UI		= 246;  --心魔幻境界面数据
UiNotify.emNOTIFY_CHANG_ROLE_WARN			= 247;  --头像上切换显示警告
UiNotify.emNOTIFY_WEEKEND_QUIZ_SYN			= 248;  --周末答题同步
UiNotify.emNOTIFY_CHAT_THEME_OVERDUE		= 249;  --主题过期重置
UiNotify.emNOTIFY_ADD_SKILL_SLOT			= 250;  --添加技能插槽
UiNotify.emNOTIFY_REMOVE_SKILL_SLOT			= 251;  --移除技能插槽
UiNotify.emNOTIFY_NO_OPERATE_UPDATE			= 252;  --没有操作事件，如果没有操作，则每隔一段时间提示一次，暂定20s
UiNotify.emNOTIFY_CHAT_CROSS_HOST			= 253;  --主播频道更新
UiNotify.emNOTIFY_WISHACT_DATA_CHANGED		= 254;  --许愿活动数据更新
UiNotify.emNOTIFY_BREAK_GENERALPROCESS		= 255;  --中断通用读条
UiNotify.emNOTIFY_AUTO_SKILL_CHANGED		= 256;  --自动战斗技能改变了
UiNotify.emNOTIFY_UPDATE_RECALL_LIST		= 257;  --刷新召回玩家列表
UiNotify.emNOTIFY_UPDATE_RECALL_COUNT		= 258;  --刷新召回次数
UiNotify.emNOTIFY_UPDATE_RECALL_BUTTON		= 259;  --刷新主界面召回图标
UiNotify.emNOTIFY_ON_USE_ITEM				= 260;	--使用物品
UiNotify.emNOTIFY_PG_PARTNER_AWARENESS		= 261;	--同伴觉醒
UiNotify.emNOTIFY_QINGRENJIE_TEXIAO			= 262;	--情人节ui相关
UiNotify.emNOTIFY_MS_HAS_LOWER_PRICE		= 263;	--购买摆摊物品时，有更低价的物品通知
UiNotify.emNOTIFY_LEVELUP_ASK4HELP_RSP 		= 264;  --请求直升丹求助回包
UiNotify.emNOTIFY_WOMAN_SYNDATA 			= 265;  --标签同步数据

UiNotify.emNOTIFY_CLICKOBJ					= 266;  --拖动
UiNotify.emNOTIFY_REPOBJSIMPLETAP			= 267;  --家具点击事件
UiNotify.emNOTIFY_REPOBJLONGTAPSTART		= 268;  --家具长按
UiNotify.emNOTIFY_REPOBJTOUCHUP				= 269;  --家具长按结束
UiNotify.emNOTIFY_PUT_DECORATION			= 270;  --摆放家具
UiNotify.emNOTIFY_SYNC_FURNITURE			= 271;  --同步家具仓库信息
UiNotify.emNOTIFY_SYNC_HOUSE_ACCESS			= 272;  --同步进入家园权限
UiNotify.emNOTIFY_SYNC_MAKE_FURNITURE 		= 273;  --同步家具制作结果
UiNotify.emNOTIFY_SYNC_SWITCH_PLACE 		= 274;  --家园切换室内和室外场景
UiNotify.emNOTIFY_SYNC_HOUSE_INFO 			= 275;  --同步家园基础信息
UiNotify.emNOTIFY_DELETE_DECORATION			= 276;  --删除物件
UiNotify.emNOTIFY_ZHEN_YUAN_MAKE 			= 277;  --真元打造
UiNotify.emNOTIFY_ROOMER_CHECKIN 			= 278;  --入住家园
UiNotify.emNOTIFY_ROOMER_CHECKOUT 			= 279;  --撤离家园
UiNotify.emNOTIFY_SYNC_FRIEND_PLANT 		= 280;  --好友种植数据同步完成
UiNotify.emNOTIFY_SYNC_PLANT 				= 281;  --家园种植数据同步完成
UiNotify.emNOTIFY_PLANT_CURE_FINISHED 		= 282;  --养护完成
UiNotify.emNOTIFY_HOUSE_LEVELUP 			= 283;  --家园升级
UiNotify.emNOTIFY_SYNC_HOUSE_FRIEND_LIST 	= 284;  --同步家园好友数据完成
UiNotify.emNOTIFY_SYNC_MAP_FURNITURE 		= 285;  --同步家园场景家具
UiNotify.emNOTIFY_SYNC_HAS_HOUSE			= 286;  --同步家园状态
UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP			= 287;  --登入成功
UiNotify.emNOTIFY_ARBOR_CURE_OK		    	= 288;  --种树治疗成功
UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD	    	= 289;  --投票奖励兑换成功
UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST	    = 290;  --获取参加美女评选的好友名单
UiNotify.emNOTIFY_SYNC_EXT_COMFORTLEVEL 	= 291;  --同步舒适等级加成
UiNotify.emNOTIFY_SYNC_WEATHER_CHANGE 		= 292;  --天气改变通知
UiNotify.emNOTIFY_DECORATION_CHANGE 		= 293;  --摆放出来的家具有改动事件
UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_CLOSE	= 294;	-- 副本指引信息改动关闭离开按钮
UiNotify.emNOTIFY_WEDDING_DRESS_CHANGE		= 295;	--婚服状态改变
UiNotify.emNOTIFY_SYNC_XUEWEI_LEVELUP		= 296;	-- 冲穴陈功提示
UiNotify.emNOTIFY_SYNC_LOTTERY_DATA			= 297;	-- 同步抽奖数据
UiNotify.emNOTIFY_SYNC_WEDDING_WELCOME		= 298;	-- 同步婚礼请柬数据
UiNotify.emNOTIFY_SYNC_WEDDING_SCHEDULE		= 299;	-- 同步婚礼排期数据
UiNotify.emNOTIFY_WEDDING_CASHGIFT_CHANGE   = 300;	--结婚，礼金数据更新
UiNotify.emNOTIFY_SYNC_WEDDING_MAP			= 301;	-- 同步所有正在举行的婚礼数据
UiNotify.emNOTIFY_WEDDING_DATE_SELECT_FINISH= 302;	-- 选好婚礼日期
UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_WEDDING_BTN	= 303;	-- 副本指引信息改动结婚相关按钮
UiNotify.emNOTIFY_SYNC_VIEW_RELATION	    = 304;	-- 同步关系普数据
UiNotify.emNOTIFY_CLICK_LINK_NPC 			= 305;	--点击npc寻路链接
UiNotify.emNOTIFY_CAMERA_SETTING_CHANGE		= 306;	-- 手势摄像机参数变化
UiNotify.emNOTIFY_VIEW_STATE_CHANGE 		= 307;	-- 调整视角状态变化
UiNotify.emNOTIFY_VIEW_ASSIST_BTN_CHANGE 	= 308;	-- 显示隐藏视角按钮
UiNotify.emNOTIFY_DOUBLE_FLY_BTN_CHANGE 	= 309;	-- 显示隐藏双飞按钮
UiNotify.emNOTIFY_DOUBLE_FLY_COUNTDOWN		= 310;	-- 显示双飞按钮倒计时
UiNotify.emNOTIFY_NPCVOICE_PLAY_END			= 311;	-- npc语音播放结束
UiNotify.emNOTIFY_LOCK_TO_NPC 				= 312;	-- 任务推近镜头至npc
UiNotify.emNOTIFY_LOCK_TO_NPC_CONFIRM 		= 313;	-- 任务推近镜头至npc
UiNotify.emNOTIFY_SHARE_PHOTO_END			= 314;	--截图分享结束
UiNotify.emNOTIFY_SYNC_WULINDASHI_SECTION	= 315;	-- 武林大事阶段同步
UiNotify.emNOTIFY_ON_BATTERY_STATE_CHANGE	= 316;	-- 设备电池状态变化(是否在充电)
UiNotify.emNOTIFY_QQ_INVITE_UNREG_UPDATE	= 317;	-- 手Q邀请未注册好友通知
UiNotify.emNOTIFY_JUE_YAO_STATE_CHANGE      = 318;  -- 诀要状态变化
UiNotify.emNOTIFY_ZHEN_FA_STRENGTH_RESULT   = 319;  -- 阵法强化结果
UiNotify.emNOTIFY_NYC_WISHLIST_CHANGE		= 320;	--双旦活动许愿列表更新
UiNotify.emNOTIFY_QYHCROSS_SYN_MATCH_DATA	= 321;	-- 跨服群英会同步排行信息
UiNotify.emNOTIFY_QYHCROSS_CHOOSE_FACTION	= 322;	-- 跨服群英会同步选择门派信息
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_STATE	= 323;	--同步跨服城战阶段信息
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_AID_BRIEF           = 324;	--跨服城战助战简要信息刷新
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_AID_LIST            = 325;	--跨服城战家族助战列表刷新
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_COUNT = 326;	--跨服城战王城中玩家数量
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_RIGHT = 327;	--跨服城战王城进入资格
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_OUTER_OCCUPY_INFO   = 328;	--跨服城战外城占领状况
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_OCCUPY_INFO    = 329;	--跨服城战王城占领情况
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_KIN_INFO        = 330;	--跨服城战家族排行
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_PLAYER_INFO     = 331;	--跨服城战玩家排行
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_SELF_INFO           = 332;	--跨服城战自己积分
UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_CAMP_INFO           = 333;	--跨服城战王城营地信息
UiNotify.emNOTIFY_SYNC_LABA_ACT_MATERIAL_DATA           = 334;	--同步腊八节腊八粥数据
UiNotify.emNOTIFY_SYNC_LABA_ACT_FRIEND_DATA             = 335;	--同步腊八节腊八粥好友标识数据
UiNotify.emNOTIFY_SYNC_LABA_ACT_ASSIST_DATA             = 336 			-- 同步腊八节腊八粥玩家协助数据
UiNotify.emNOTIFY_SHOW_CHAT_INPUT                       = 337 			--打开聊天界面输入界面
UiNotify.emNOTIFY_REFRESH_MN_RANK                       = 338	--刷新年兽排行
UiNotify.emNOTIFY_NEWYEAR_QA_ACT                        = 339 			--新年答题活动UI
UiNotify.emNOTIFY_CHOUJIANG_CHECK_DATA                  = 340 	-- 新年抽奖
UiNotify.emNOTIFY_PET_FEED_REFRESH                      = 341	--宠物喂养
UiNotify.emNOTIFY_SYNC_MAGICBOWL                        = 342	--同步聚宝盆
UiNotify.emNOTIFY_SUPERVIP_CHANGE                       = 343	--超R标记
UiNotify.emNOTIFY_JINGMAI_DATA_CHANGE                   = 344  -- 经脉数据改变
UiNotify.emNOTIFY_FUBEN_JOIN_COUNT_CHANGE               = 345	--副本中人数变化
UiNotify.emNOTIFY_REFRESH_DACNE_ACT_UI                  = 346	--跳舞界面ui更新
UiNotify.emNOTIFY_FUBEN_DEATH_COUNT_CHANGE              = 347	--副本中死亡次数变化
UiNotify.emNOTIFY_KEY_QUEST_FUBEN_UPDATE                = 348	--小队寻宝界面更新
UiNotify.emNOTIFY_PARTNER_CARD_POS_UNLOCK               = 349	--门客位解锁
UiNotify.emNOTIFY_PARTNER_CARD_UP_POS                   = 350 -- 上阵门客
UiNotify.emNOTIFY_PARTNER_CARD_DWON_POS                 = 351 -- 下阵门客
UiNotify.emNOTIFY_PARTNER_CARD_UP_GRADE                 = 352	--门客升级
UiNotify.emNOTIFY_PARTNER_CARD_ADD                      = 353	--获得门客
UiNotify.emNOTIFY_PARTNER_CARD_SYN_HOUSE_CARD           = 354	--同步门客入住数据
UiNotify.emNOTIFY_PARTNER_CARD_ADD_STATE                = 355	--门客拜访派遣成功
UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_LIFE_CHANGE        = 356	--门客心魔血量变化
UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_COUNT_CHANGE       = 357	--门客心魔次数变化
UiNotify.emNOTIFY_PARTNER_CARD_SSYN_DEVIL               = 358	--同步，门客心魔数据
UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_MSG_CHANGE         = 359	--门客心魔操作信息变化
UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_END                = 360	--门客心魔结束
UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD                = 361	--领取派遣奖励
UiNotify.emNOTIFY_PARTNER_CARD_SYN_ACT_DATA             = 362	--同步活动数据
UiNotify.emNOTIFY_PARTNER_CARD_DISMISS_CARD             = 363	--遣散门客
UiNotify.emNOTIFY_PARTNER_CARD_SYN_PICK_DATA            = 364	--同步门客抽卡数据
UiNotify.emNOTIFY_PARTNER_CARD_DATA_CHANGE              = 365 	-- 门客数据刷新
UiNotify.emNOTIFY_TEAM_BATTLE_SYN_DATA                  = 366 	-- 同步通天塔数据
UiNotify.emNOTIFY_REFRESH_PARTNER_GRALLERY              = 367 -- 更新图鉴界面
UiNotify.emNOTIFY_REFRESH_HEAD_UI                       = 368 -- 显示隐藏HeadUi
UiNotify.emNOTIFY_WEDDING_PROCESS_CHANGE                = 369 		-- 婚礼流程变化
UiNotify.emNOTIFY_SYNC_KDP_DATA                         = 370;	--同步家族聚餐任务数据
UiNotify.emNOTIFY_SYNC_KDP_HELP                         = 371;	--同步家族聚餐任务求助信息
UiNotify.emNOTIFY_SYNC_RECOMMOND_LOVER                  = 372;	-- 同步推荐情缘玩家
UiNotify.emNOTIFY_LOVER_TASK_STATE_CHANGE               = 373 -- 情缘任务状态改变
UiNotify.emNOTIFY_FIGHT_POWER_RECOMMEND                 = 374; --推荐战斗力数据更新时
UiNotify.emNOTIFY_HOUSE_PEACH_SYNC_DATA                 = 375; --家园桃花树数据更新
UiNotify.emNOTIFY_FLOW_TASK_QUESTION		= 376; --分流任务问题
UiNotify.emNOTIFY_ON_NPC_DIALOG							= 377; --与npc对话
UiNotify.emNOTIFY_REFRESH_SHANGSHENGDIAN_DATA			= 378	--刷新我要上盛典活动的数据
UiNotify.emNOTIFY_ON_SYN_MATERIAL_COLLECT_DATA			= 379; --同步酿酒数据
UiNotify.emNOTIFY_SYNC_YXJQ_DATA						= 380; --同步银杏寄情数据
UiNotify.emNOTIFY_KICK_PLAYER                           = 381; --踢人界面踢人成功
UiNotify.emNOTIFY_REFRESH_DUMPLINGBANQUET_RANK          = 382; --同步饺子宴排行
UiNotify.emNOTIFY_REFRESH_DUMPLINGBANQUET_CURRENTSTAGEINFO = 383; --同步饺子宴阶段实时信息
UiNotify.emNOTIFY_SETINGREDIENTS                           = 384; --同步饺子宴当前食材信息
UiNotify.emNOTIFY_REFRESH_DRJ_FUDAI_ACT					= 385; --同步冬日祭福袋活动信息
UiNotify.emNOTIFY_DAXUEZHANG_SINGLE_RANK_DATA           = 385; --同步打雪仗单人排名信息
UiNotify.emNOTIFY_SWITCH_TOP_BUTTON_UP           			= 386; --隐藏topbutton
UiNotify.emNOTIFY_CHANGE_BIGFACE                        = 387; --更换半身像
UiNotify.emNOTIFY_REUNION_DATA_UPDATE                   = 388; --重逢功能数据刷新
UiNotify.emNoTIFY_LJF_WEEK_UPDATE                       = 389; --决战凌绝峰数据更新
UiNotify.emNOTIFY_LTZ_SYN_DATA           				= 390; --领土战同步数据
UiNotify.emNOTIFY_PARTNERCARD_CHANGE_EXP           		= 391; --门客经验变动
UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA				= 392; --同步大醉江湖梦一场数据
UiNotify.emNOTIFY_SYNC_ANNIVERSARYJIYU_DATA				= 393; --同步周年寄语活动数据
UiNotify.emNOTIFY_SYNC_CHANGBAI_REPORT_DATA				= 394; --同步长白之巅战报信息
UiNotify.emNOTIFY_CHANGBAI_FACTION						= 395; --长白之巅选门派
UiNotify.emNOTIFY_SYNC_WAROFFIREANDICE_CHOOSE_ROLE_NUM  = 396; --同步灭火大作战选择角色人数
UiNotify.emNOTIFY_SYNC_CHANGBAI_MATCH_TIME				= 397; --同步长白之巅准备倒计时
UiNotify.emNOTIFY_HOUSE_PARROT_UPDATE                   = 398; --鹦鹉家具信息更新
UiNotify.emNoTIFY_SYNC_FOKU_BATTLE                      = 399; --佛窟之战。
UiNotify.emNOTIFY_CHANGBAI_UPDATE_RANK_SCORE			= 400; --长白之巅更新分数和排名
UiNotify.emNOTIFY_COOK_REFRESH                          = 401; --烹饪
UiNotify.emNOTIFY_COOK_AUTOPUT                          = 402; --烹饪：自动备菜
UiNotify.emNOTIFY_CHANGBAI_REVIVE_TIME					= 403; --长白之巅复活时间
UiNotify.emNOTIFY_PARTNER_REINIT_SYN_DATA				= 404; --同步洗髓数据
UiNotify.emNOTIFY_CHANGEWEAPON							= 405; --切换武器
UiNotify.emNOTIFY_SYNC_KINCHAOSFIGHT_DATA				= 406; --同步家族大乱斗数据
UiNotify.emNOTIFY_PI_FENG_SYNC_DATA						= 407; --同步披风数据
UiNotify.emNOTIFY_CHANGE_MAP_NAME						= 408; --动态修改小地图的名字
UiNotify.emNOTIFY_HUNTING_MOVE                          = 409; --打猎开始移动准星
UiNotify.emNOTIFY_HUNTING_STOP                          = 410; --打猎结束移动准星
UiNotify.emNOTIFY_SECRETCARD_SYNC_DATA                  = 411; --挑战秘卷同步数据
UiNotify.emNoTIFY_COOK_FISH_TRAP                        = 412; --触发烹饪钓鱼trap
UiNotify.emNOTIFY_COOK_COST_MATERIAL                    = 413; --烹饪消耗食材
UiNotify.emNOTIFY_NEW_PHOTO_STATE_EVENT                 = 414; --新拍照加边框特效水印贴纸事件
UiNotify.emNOTIFY_TJMZ_SYNC_DATA						= 415; --天机迷阵同步数据
UiNotify.emNOTIFY_COOK_FISH_STATE_CHANGE                = 416; --钓鱼状态改变

function UiNotify:Init()
	self.tbCallback = {};	-- 注册函数表
end

if not UiNotify.tbCallback then
	UiNotify:Init();
end

-- 注册事件函数，当有nEvent事件产生时，回调tbTable的fnProc函数
function UiNotify:RegistNotify(nEvent, fnProc, tbTable)
	assert(tbTable, string.format("nEvent:%s,", tostring(nEvent)));
	assert(nEvent, string.format("UiGroup:%s, nEvent:%s,",
	tostring(tbTable.UI_NAME), tostring(nEvent)));
	assert(fnProc);

	local tbCallback = self.tbCallback[nEvent];
	if (not tbCallback) then
		tbCallback = {};
		self.tbCallback[nEvent] = tbCallback;
	else
		if (tbCallback[tostring(tbTable)]) then	-- 重复注册，则失败
			Log(debug.traceback())
			return;
		end
	end
	if type(tbTable) == "table" then
		tbCallback[tostring(tbTable)] = { tbSelf = tbTable, fnProc = fnProc };
	end
end

-- 反注册事件
function UiNotify:UnRegistNotify(nEvent, tbTable)
	local tbCallback = self.tbCallback[nEvent];
	if tbCallback and tbCallback[tostring(tbTable)] then
		tbCallback[tostring(tbTable)] = nil;
	else
		print("UiNotify:UnRegistNotify", nEvent, tbTable.UI_NAME or tostring(tbTable))
	end
end


-- 事件接口，有任何事件程序都会调用该函数，并将参数传入
function UiNotify.OnNotify(nEvent, ...)
	local arg = {...};
	if UiNotify.tbCallback[nEvent] then
		for szKey, tb in pairs(UiNotify.tbCallback[nEvent]) do	-- 遍历注册函数的表，调用注册了的函数
			local szUiName = tb.tbSelf.UI_NAME;
			if (not szUiName) or Ui:WindowVisible(szUiName) == 1 then	-- 不是窗口则响应，是窗口则被打开才接消息
				tb.fnProc(tb.tbSelf, unpack(arg));
			end
		end
	end
end





