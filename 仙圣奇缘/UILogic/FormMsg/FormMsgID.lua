--------------------------------------------------------------------------------------
-- 文件名:	FormMsgSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	lixu
-- 日  期:	2015-5-6
-- 版  本:	1.0
-- 描  述:	定义界面逻辑消息组id 
-- 应  用:   
---------------------------------------------------------------------------------------

-------------------------------WndMsg--------------------------------------
FormMsg_Client_WndMgrBeg	= 20

FormMsg_Client_WndMgr_OpenWnd		= FormMsg_Client_WndMgrBeg + 1

-------------------------------客户端网络建链--------------------------------------
FormMsg_ClientNet_Beg 		= 50

FormMsg_ClientNet_ConnectSucc			= FormMsg_ClientNet_Beg + 1 		--客户端建链成功

FormMsg_ClientNet_ConnectStack			= FormMsg_ClientNet_Beg + 2 		--服务器建链顺序处理 第一次链接平台 接入平台后 登入账号服 请求 角色列表

FormMsg_ClientNet_RequestRegistAccout 	= FormMsg_ClientNet_Beg + 3 		--点击注册账号

FormMsg_ClientNet_AccountSuccond 		= FormMsg_ClientNet_Beg + 4 			--账号成功 （注册 或则 创建）

FormMsg_ClientNet_LogOut 				= FormMsg_ClientNet_Beg + 5 		--账号注销

FormMsg_ClientNet_OnClickLogin			= FormMsg_ClientNet_Beg + 6 		--点击登入按钮 （要切换建链）

FormMsg_ClientNet_CloseTcp				= FormMsg_ClientNet_Beg + 7			--服务器主动断开客户端链接

FormMsg_ClientNet_OpenServerForm		= FormMsg_ClientNet_Beg + 8			--打开服务器列表

FormMsg_ClientNet_AccountRegistSuccond  = FormMsg_ClientNet_Beg + 9		
	
FormMsg_ClientNet_End					= FormMsg_ClientNet_Beg + 30

------------------------------副本界面消息--------------------------------------
FormMsg_EctypeForm_Beg 		= 100

FormMsg_EctypeForm_GetStarRewardBox_SUC  		= 	FormMsg_EctypeForm_Beg + 1	--领取星级礼包成功返回

FormMsg_EctypeForm_UpdateEctypeStarNum  		= 	FormMsg_EctypeForm_Beg + 2	--更新星星数

FormMsg_EctypeForm_DateGetSuc  					= 	FormMsg_EctypeForm_Beg + 3	--更新星星数

FormMsg_EctypeForm_EctypeList					= 	FormMsg_EctypeForm_Beg + 4	--打开副本选择界面

FormMsg_EctypeForm_End 		= 130

----------------------------------感悟界面----------------------------------
FormMsg_InspireForm_Beg 			= 140

FormMsg_InspireForm_Eliminate   	= FormMsg_InspireForm_Beg + 1					--响应服务器消除

FormMsg_InspireForm_ActionOver		= FormMsg_InspireForm_Beg + 2					--动画播放结束通知EliminateSystem

FormMsg_InspireForm_ComparisonColor = FormMsg_InspireForm_Beg + 3

FormMsg_InspireForm_OpenWnd			= FormMsg_InspireForm_Beg + 4

FormMsg_InspireForm_InsertLog		= FormMsg_InspireForm_Beg + 5

FormMsg_InspireForm_End 		= 150

------------------------------战斗加载界面内存过渡-----------------------------------
FormMsg_BattleLoading_Beg			= 170
FormMsg_BattleLoading_Loading		= FormMsg_BattleLoading_Beg + 1
FormMsg_BattleLoading_Member		= FormMsg_BattleLoading_Beg + 2

------------------------------神秘商店界面消息--------------------------------------
FormMsg_ShopSecretForm_Beg 		= 200

FormMsg_ShopSecretForm_RefreshNewItem  		= 	FormMsg_ShopSecretForm_Beg + 1	--刷新一个新物品

FormMsg_ShopSecretForm_RefreshAllItem    	= 	FormMsg_ShopSecretForm_Beg + 2	--刷新所有新物品

FormMsg_ShopSecretForm_BuyItem          	= 	FormMsg_ShopSecretForm_Beg + 3	--购买物品

FormMsg_ShopSecretForm_End 		= 210

------------------------------邮箱界面消息--------------------------------------
FormMsg_MailBox_beg		= 220

FormMsg_MailBox_Info  		= 	FormMsg_MailBox_beg + 1	--更新邮箱信息

-------------------------------掉落物品选择关卡界面消息--------------------

FormMsg_ItemDropGuide_Beg = 260

FormMsg_ItemDropGuide_Date = FormMsg_ItemDropGuide_Beg + 1 --

FormMsg_ItemDropGuide_Drop = FormMsg_ItemDropGuide_Beg + 2 --掉落界面

-- FormMsg_ItemDropGuide_Close = FormMsg_ItemDropGuide_Beg + 3 --关闭掉落界面

FormMsg_ItemDropGuide_End = 270

----------------------------渡劫界面----------------
FormMsg_BattBuZhenDuJie_Beg = 271

FormMsg_BattBuZhenDuJie_Wnd = FormMsg_BattBuZhenDuJie_Beg + 1

FormMsg_BattBuZhenDuJie_End = 280

----------------------------主界面消息----------------
FormMsg_MainForm_Beg = 290
FormMsg_MainForm_Refresh = FormMsg_MainForm_Beg + 1 			--刷新 382

------------------------------游戏内公告消息--------------------------------------
FormMsg_GameNotice_Beg		= 320

FormMsg_GameNotice_ActionOver		= FormMsg_GameNotice_Beg + 1	--只在主界面显示的公告播放完毕 参数 上一次的现实状态

FormMsg_GameNotice_NoticeMainWnd	= FormMsg_GameNotice_Beg + 2	--通知主界面 

FormMsg_GameNotice_End		= 330



------------------------------八仙过海系统消息--------------------------------------
FormMsg_BXGH_Beg		= 350
FormMsg_BXGH_UpdataView		    = FormMsg_BXGH_Beg + 1  --刷新护送界面UI
FormMsg_BXGH_showNpcInfoView    = FormMsg_BXGH_Beg + 2  --打开NPC详细信息界面=======
FormMsg_BXGH_UpdataNpcList      = FormMsg_BXGH_Beg + 3  --更新打劫Npc列表
FormMsg_BXGH_RefreshNpc         = FormMsg_BXGH_Beg + 4  --刷新要护送的npc
FormMsg_BXGH_UpdataRobTimes     = FormMsg_BXGH_Beg + 5  --更新打劫次数
FormMsg_BXGH_AddNpc             = FormMsg_BXGH_Beg + 6  --增加npc
FormMsg_BXGH_DecNpc             = FormMsg_BXGH_Beg + 7  --减少npc
FormMsg_BXGH_DecNpc_DaJie       = FormMsg_BXGH_Beg + 8  --减少npc_打劫界面
FormMsg_BXGH_Updata_DaJieCD     = FormMsg_BXGH_Beg + 9  --更新打劫cd时间
------------------------------移动系统相关消息--------------------------------------
FormMsg_Movement_Beg		= 360

FormMsg_Movement_Cursor			= FormMsg_Movement_Beg + 1	--通知光标变化

------------------------------新世界BOSS消息--------------------------------------
FormMsg_WorldBoss2_Beg		= 370

FormMsg_WorldBoss2_BossInfo		= FormMsg_WorldBoss2_Beg + 1	--通知BOSS名字，血量

FormMsg_WorldBoss2_Rank			= FormMsg_WorldBoss2_Beg + 2	--通知排名变化

FormMsg_WorldBoss2_Block		= FormMsg_WorldBoss2_Beg + 3	--通知阻挡变化

FormMsg_WorldBoss2_CD			= FormMsg_WorldBoss2_Beg + 4	--通知CD变化

FormMsg_WorldBoss1_GuWu			= FormMsg_WorldBoss2_Beg + 5	--通知boos1鼓舞变化

FormMsg_WorldBoss2_GuWu			= FormMsg_WorldBoss2_Beg + 6	--通知boos2鼓舞变化

FormMsg_WorldBoss2_ClearCD      = FormMsg_WorldBoss2_Beg + 7   --清楚CD

FormMsg_WorldBoss2_End		= 390


------------------------------神龙上供消息--------------------------------------
FormMsg_DragonPray_Beg		= 400

FormMsg_DragonPray_Info		= FormMsg_DragonPray_Beg + 1	--通知界面刷新

FormMsg_WorldBoss2_End		= 410

----------------------------转盘-------------------
FormMsg_Turn_Beg		= 420

FormMsg_Turn_Info	= FormMsg_Turn_Beg + 1	--通知界面刷新

FormMsg_Turn_End		= 430
-------------------------猎命-----------------------

FormMsg_HuntFate_Beg		= 440

FormMsg_HuntFate_Info	= FormMsg_HuntFate_Beg + 1	--猎妖响应

FormMsg_HuntFate_OneHarvest	= FormMsg_HuntFate_Beg + 2	--单个拾取响应
FormMsg_HuntFate_OneKeyHarvest	= FormMsg_HuntFate_Beg + 3	--一键拾取响应

FormMsg_HuntFate_OneSell	= FormMsg_HuntFate_Beg + 4	--单个出售响应
FormMsg_HuntFate_OneKeySell	= FormMsg_HuntFate_Beg + 5	--一键出售响应

FormMsg_HuntFate_OneKeyHuntFate	= FormMsg_HuntFate_Beg + 6	--一键猎妖响应

FormMsg_HuntFate_FolieHuntFate	= FormMsg_HuntFate_Beg + 7	--狂暴猎妖响应
FormMsg_HuntFate_YuanBaoHuntFate	= FormMsg_HuntFate_Beg + 8	--元宝八连抽

FormMsg_HuntFate_End		= 450

-----------------------------

---------------------装备合成--------
FormMsg_Compose_Beg		= 460
FormMsg_Compose_Response = FormMsg_Compose_Beg + 1

FormMsg_Compose_Strength = FormMsg_Compose_Beg + 2
FormMsg_Compose_End		= 470

---------------------开服活动--------
FormMsg_ServerOpenTask_Beg		= 480
FormMsg_ServerOpenTask_Reward 	= FormMsg_ServerOpenTask_Beg + 1 --奖励刷新
FormMsg_ServerOpenTask_End		= 490

------------------------------帮派--------------------------
FormMsg_Group_Beg				=	500
-- FormMsg_GroupRank_Beg 				= FormMsg_Group_Beg + 1 --帮派列表 在排名功能时
FormMsg_Group_End				= 510
------------------------------充值界面--------------------------
FormMsg_ReCharge_Beg            = 550
FormMsg_ReCharge_UpdataWnd      = FormMsg_ReCharge_Beg + 1 --刷新充值界面


-----------------------------聊天之公告界面----------------------------------
FormMsg_ChatNotice_Beg			= 580
FormMsg_ChatNotice_UpdataForm   = FormMsg_ChatNotice_Beg + 1
FormMsg_ChatNotice_End 			= FormMsg_ChatNotice_Beg + 10

------------------------------神龙上供（帮派)消息--------------------------------------
FormMsg_DragonPrayGuild_Beg		= 590

FormMsg_DragonPrayGuild_Pray	= FormMsg_DragonPrayGuild_Beg + 1	--掷骰子刷新

FormMsg_DragonPrayGuild_End		= 600


------------------------------facebook邀请和分享消息--------------------------------------
FormMsg_Facebook_Beg		= 650
FormMsg_Facebook_updateInvite	= FormMsg_Facebook_Beg + 1	--邀请奖励刷新
FormMsg_Facebook_updateShare	= FormMsg_Facebook_Beg + 2	--分享奖励刷新
FormMsg_Facebook_End		= 660


------------------------------召唤日志--------------------------------------
FormMsg_Summon_Beg		= 670
FormMsg_Summon_updateData	= FormMsg_Summon_Beg + 1	--邀请奖励刷新
FormMsg_Summon_End		= 680

------------------------------跨服--------------------------------------
FormMsg_ArenaKuaFa_Beg		= 690
FormMsg_ArenaKuaFuaOpenWnd	= FormMsg_ArenaKuaFa_Beg + 1	--跨服挑战信息 打开跨服界面
FormMsg_ArenaKuaFuaRankListUpdate	= FormMsg_ArenaKuaFa_Beg + 1	--跨服挑战信息 打开跨服界面
FormMsg_ArenaKuaFa_End		= 810

