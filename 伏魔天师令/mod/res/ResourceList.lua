Cfg = Cfg or {}
Cfg.mapSpinePngNameArray={}

Cfg.firstGameUseSkill={
	[1]={11010,11020,11030,11050},
	[2]={12010,12020,12030,12040},
	[3]={13010,13020,13050,13030},
	[4]={14010,14020,14030,14040},
	[5]={15020,15030,15040,15010},
	mount_skill=40131,
}

--长期保存的资源
Cfg.UI_NeverRelease=1
--首次进入加载的cnf
Cfg.CNF_FirstGame=2
--登陆界面资源
Cfg.UI_AccountLogin=3
--选择服务器
Cfg.UI_SelectSeverScene=10
--主场景
Cfg.UI_StageResources=21
--战斗场景
Cfg.UI_BattleStageResources=22
--战斗结算
Cfg.UI_BattleResView=23
--npc对话
Cfg.UI_CTaskDialogView=31
--护送美人
Cfg.UI_CEscortBeautyView=32
--天下第一 报名界面
Cfg.UI_CKingOfFlightApplyLayer=33
--副本
Cfg.UI_CCopyMapLayer=34
--组队页面
Cfg.UI_CBuildTeamLayer=33
--迷宫兑换界面
Cfg.UI_CExchangeLayer=36
--霸气查看界面
Cfg.UI_VindictiveCheckRoleView=37
--三国基金 领取面板
Cfg.UI_FundViewGetView=38
--三国基金 购买面板
Cfg.UI_FundViewBuyView=39
--跨服天下第一 报名
Cfg.UI_CKFtxdyBaoMingLayer=40
--跨服天下第一
Cfg.UI_CKFtxdyView=41
--三界争锋 子界面（初赛、决赛）
Cfg.UI_SubStriveView=42
-- 战力对比
Cfg.UI_BattleCompareView=43



Cfg.ResList=Cfg.ResList or {}
Cfg.ResList.GetList = function (sceneId, fileList)

	fileList =fileList or {}

	if sceneId==nil or Cfg.ResList[sceneId]==nil then
		return fileList
	end

	for _,fileName in ipairs(Cfg.ResList[sceneId]) do
		fileList[fileName]=fileName
		-- table.insert(fileList,fileName)
	end
	return fileList
end

Cfg.ResList[Cfg.UI_NeverRelease]=
{
	-- 注意:按图片的面积 从大往下排
	"ui/general.plist",
	"ui/general_fs.plist",
	"ui/battle.plist",
    "icon/icon2500.plist",
    "icon/icon5000.plist",
    "icon/icon7500.plist",
    "icon/head.plist",
    "ui/general32.plist",
    "anim/effect_scelectbtn.plist",
    "anim/effect_load.plist",
    "anim/dead_effect.plist",
    -- "ui/bg/view_bg.jpg",
}
Cfg.ResList[Cfg.CNF_FirstGame]=
{
	"spine_res_cnf",
	
	"errorcode_cnf",
	"broadcast_cnf",
	"goods_cnf",
	"goods_box_cnf",

	--创建角色需要用到
	"skill_collider_cnf",
    "skill_ai_collider_cnf",
	"skill_skin_cnf",
	"skill_cnf",
	"player_init_cnf",
	"skill_buff_cnf",
	"skill_effect_cnf",
	"skill_ai_cnf",

	"scene1_cnf",
	"scene2_cnf",
	"scene_monster_cnf",
	"scene_npc_cnf",
	"scene_door_cnf",
	"scene_copy_cnf",
	"scene_drama_cnf",

	"vitro_cnf",
	"trap_cnf",
	"icon_drop_cnf",
	"character_pos_cnf",
	"partner_init_cnf",

	--聊天所需表
	"mount_cnf", --坐骑
	"mount_des_cnf",
	"meiren_des_cnf", --美人
	"wing_des_cnf", --宠物
	"wing_link_cnf",
	"title_cnf", --称号
	"fight_gas_total_cnf",--聊天(霸气) 
	
	"wingskin_cnf",--翅膀

	--购买体力
	"energy_buy_cnf",
	"tasks_cnf",

	"sys_open_show_cnf",
	"sys_open_info_cnf",
	"sys_open_array_cnf", --主场景功能图标排序
	
	"vip_cnf",
	--新手指引
	"guide_cnf",

	"paly_des_cnf",
	"lv_reward_cnf",

	"unzip_desc_cnf",

	"sales_total_cnf",
	"feather_quality_cnf",
	"mibao_cnf",
}

--scene资源列表 
-- 登陆界面资源
Cfg.ResList[Cfg.UI_AccountLogin]=
{
	-- "Update/app_login.plist",
}

-- 选择服务器 资源!!!!!
Cfg.ResList[Cfg.UI_SelectSeverScene]=
{
	"ui/ui_login.plist",
	"ui/ui_login32.plist",
	"ui/bg/bg_role_list.jpg",
	"ui/bg/login_gonggao.jpg",
	"player_init_cnf",
}

--进入主场景加载资源
Cfg.ResList[Cfg.UI_StageResources]=
{
	
}

--进入战斗场景加载资源
Cfg.ResList[Cfg.UI_BattleStageResources]=
{
	
}

--npc对话
Cfg.ResList[Cfg.UI_CTaskDialogView]=
{
	
}

Cfg.ResList[Cfg.UI_CCopyMapLayer]=                -- 副本
{
	-- "ui/ui_copy.plist",
	"ui/ui_shop.plist",
	"copy_chap_cnf",
	"copy_times_pay_cnf",
	"copy_reward_cnf",
	"ui/ui_copynew.plist",
	"ui/ui_copynew32.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_TEAM]=                -- 群仙诛邪
{
	"ui/ui_copy.plist",
	"copy_chap_cnf",
	"copy_times_pay_cnf",
	"copy_reward_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_CHATTING]=    --聊天
{
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_ROLE]=                       --人物      10012
{
    "ui/role_ui.plist",
    "ui/ui_beauty.plist",
    "matrix_cnf",
    "ui/bg/role_dazuobg.png",
    "ui/gaf/loong.png",
    "ui/gaf/choose.png",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_BAG]=                    --背包     10040
{
	-- "UI/backpage_ui.plist",
	"partner_lv_cnf",
	"pearl_com_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_GANGS]=                  --门派 10190 CONST_FUNC_OPEN_UNION
{
	"ui/ui_clan.plist",
 --    "anim/effects_bplucky.plist",
	"ui/ui_gonglue.plist",
	"clan_active_all_cnf",
	"clan_level_cnf",
	"active_cnf",
	"clan_qifu_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_FRIEND]=                 --好友      10110
{
	-- "UI/friend_ui.plist"
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_STRATEGY]=                  --游戏攻略   10003    
{
	"ui/ui_gonglue.plist",
	"gl_vitality_cnf",
	"gl_vitality_box_cnf",
	"gl_strong_cnf",
	"gl_calendar_cnf",
	"gl_strong_id_cnf",
	"ui/bg/gonglve_gril.jpg"
}


Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SETING]=                 --系统设置      11010 CONST_FUNC_OPEN_SETING
{
	"ui/bg/qrcode_weixin.jpg",
    "ui/ui_setting.plist",
    "weixin_cnf",
}


Cfg.ResList[_G.Const.CONST_FUNC_OPEN_TASK]=             --任务      10013
{
	"ui/ui_task.plist",
	"task_reward_cnf"
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_MALL]=             --邮件      
{
	"ui/ui_mail.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_RECHARGE]=             --充值      
{
	"ui/ui_vip.plist",
    "vip_show_cnf",
    "weagod_rmb_cnf",
    "privilege_cnf",
    "privilege_type_cnf",
    "mall_class_cnf",
    "yueka_cnf",
    "ui/bg/recharge_zzshop.png",
    "ui/bg/recharge_zcpx.jpg"
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_WELFARE]=             --福利      
{
	"ui/ui_welfare.plist",
	"sign_cnf",
	"online_reward_cnf",
	"player_lv_reward_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SHOP]=             --商城      
{
	"mall_class_cnf",
	"ui/ui_shop.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SHOP_SHENQI]=             --商城      
{
	"mall_class_cnf",
	"ui/ui_shop.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_MOUNT]=             --坐骑      
{
	"ui/ui_mount.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SMITHY]=             --湛卢坊      
{
	"equip_make_cnf",
	"equip_enchant_cnf",
	"anim/task_strenglose.plist",
    "ui/role_ui.plist",
    "pearl_last_id_cnf",
    "ui/bg/equip_gembg.png",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_REBATE]=             --精彩返利      
{
	"ui/ui_advert.plist",
	"ui/ui_shop.plist",
    "sales_sub_cnf",
    "zhuanpan_cnf",
    "ui/bg/rebate_czfl.jpg",
    "ui/bg/rebate_jjfb.jpg",
    "ui/bg/rebate_tlfb.jpg",
    "ui/bg/rebate_logo.png",
    "ui/bg/rebate_logo1.png",
    "ui/bg/rebate_yqfb.jpg",
    "ui/bg/rebate_cwfh.jpg",
    "ui/bg/rebate_zqfh.jpg",
    "ui/bg/rebate_yxbd.jpg",
    "ui/bg/rebate_nfzp.jpg",
    "ui/bg/rebate_fcfl.jpg",
    "ui/bg/feast_tsbg.jpg",
    "ui/bg/rebate_cbsb.png",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_PARTNER]=             --灵妖 
{
	"ui/ui_partner.plist",
    "partner_lv_up_cnf",
    "partner_lv_cnf",
    "partner_cheer_cnf",
    "partner_quality_cnf",
    "copy_chap_cnf",
    "scene_copy_cnf",
    "ui/bg/partner_tipsbg.jpg",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_DAEMON]=               -- 仙宠
{
	"ui/bg/daemon_bg1.jpg",
	"ui/bg/daemon_bg2.jpg",
	"ui/ui_daemon.plist",
	"partner_get_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_GAMBLE]=				-- 翻翻乐
{
	"ui/ui_gamble.plist",
	"flsh_reward_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_ARENA]=				-- 竞技场
{	
	"ui/arena.plist",
	"map/jjc_ui.jpg"
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_LYJJ]=				-- 灵妖竞技
{	
	"ui/arena.plist",
	"ui/ui_partner.plist",
	"ui/bg/lingyao_bg.jpg"
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_TOWER]=				-- 通天浮图
{
	"ui/bg/bg_futu.jpg",
	"ui/ui_futu.plist",
	"copy_chap_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SURRENDER]=				-- 降魔之路
{
	"ui/bg/bg_futu.jpg",
	"ui/ui_challenge.plist",
	"ui/ui_copy.plist",
	"wing_cnf",
	"wing_link_cnf",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_JINGXIU]=				--  浮屠静修
{
	"hero_tower_cnf",
	"ui/ui_futu.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_WING]=					-- 宠物
{
	"wing_cnf",
	"wing_des_cnf",
	"wing_link_cnf",
	"ui/ui_mount.plist",
	"ui/bg/really_bg.jpg",
	"ui/bg/really_dins1.jpg",
	"ui/bg/really_dins2.jpg",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_MYTH]=					-- 群雄争霸——封神之战
{
	"ui/ui_expidit.plist",
	"grade_up_cnf",
	"ui/bg/expidit_baseMap.jpg",
	"ui/bg/expidit_Yingzi.png",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_LUCKY]=      					-- 祈福
{
    "weagod_buy_cnf",
    "weagod_cnf",
    "ui/bg/yaoqianshu.jpg",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_BOSS]=      					-- 世界Boss
{
	"world_boss_desc_cnf",
    "ui/ui_worldboss.plist",
    "ui/bg/boss_doudawang.jpg",
    "ui/bg/boss_heixiongjing.jpg"
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_MOIL]=      					-- 奴仆
{
    "ui/servant.plist",
    "moil_exp_cnf",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SEVENDAY]=      				-- 开服7日
{
	"achieve_must_cnf",
	"ui/bg/seven_activity1.png",
	"ui/bg/seven_activity2.png",
	"ui/bg/seven_activity3.png",
	"ui/bg/seven_activity4.png",
	"ui/bg/seven_activity5.png",
	"ui/bg/seven_activity6.png",
	"ui/bg/seven_activity7.png",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_EXAMINATION] = 				--  御前科举
{
	"keju_cnf",
	"ui/ui_Keju.plist",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_STRIVE] = 						--  三界争锋
{
	"ui/arena.plist",
	"ui/ui_strive.plist",
	"ui/bg/welkin_3.jpg",
	"ui/bg/expidit_Yingzi.png",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SHEN] = 						--  两仪八卦
{
	"ui/bg/ui_soul_rotate.png",
	"ui/bg/ui_soul_wuXingZhen.png",
	"ui/bg/ui_soul_rightbg.png",
	"ui/ui_soul.plist",
	"ui/ui_fightgas.plist",
	"fight_gas_grasp_cnf",
	"fight_gas_open_cnf",
	"fight_gas_kong_cnf",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_HOLIDAY] = 					--  节日活动
{
	"gala_total_cnf",
	"gala_turn_cnf",
	"gala_point_cnf",
	"gala_rank_cnf",
	"collect_cnf",
	"ui/ui_feast.plist",
	"ui/ui_advert.plist",
	"ui/bg/feast_bg.jpg",
	"ui/bg/feast_tsbg.jpg",
	"ui/bg/feast_upbg.png",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_DEMONS] = 						--  无尽心魔  -- 一骑当千
{
	"ui/ui_Demons.plist",
	"thousand_rank_cnf",
	"thousand_role_cnf",
	"thousand_jifen_cnf",
}
Cfg.ResList[_G.Const.CONST_FUNC_OPEN_WELKIN] = 						--  大闹天宫
{
	"ui/ui_welkin_first.plist",
	"ui/ui_strive.plist",
	"ui/bg/welkin.jpg",
	"ui/bg/welkin_2.jpg",
	"ui/bg/welkin_3.jpg",
	"ui/bg/expidit_Yingzi.png",
	"conquest_cnf",
	"scores_cnf",
	"final_battle_cnf",
}
Cfg.ResList[_G.Const.CONST_MAP_WELKIN_FIRST]=Cfg.ResList[_G.Const.CONST_FUNC_OPEN_WELKIN]
Cfg.ResList[_G.Const.CONST_MAP_WELKIN_BATTLE]=Cfg.ResList[_G.Const.CONST_FUNC_OPEN_WELKIN]
Cfg.ResList[_G.Const.CONST_MAP_WELKIN_ONLY]=Cfg.ResList[_G.Const.CONST_FUNC_OPEN_WELKIN]

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_AUCTION]=             			-- 竞拍      
{
	"ui/ui_auction.plist",
	"ui/bg/aution_bg.png",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_QILING]=             			-- 武器      
{
	"wuqi_cnf",
	"wuqi_dz_cnf",
	"ui/bg/qiling_rightbg.jpg",
	"ui/bg/qiling_leftbg.jpg",
	"ui/ui_qiling.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_FEATHER]=             			-- 翅膀     
{	
	"feather_cnf",
	"feather_des_cnf",
	"feather_quality_cnf",
	"ui/ui_mount.plist",
	"ui/bg/feather_bg.jpg",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_JEWELLERY]=             			-- 珍宝      
{
	"hidden_make_cnf",
	"hidden_treasure_cnf",
	"ui/bg/treasure_dins.jpg",
	"ui/bg/treasure_out.png",
	"ui/ui_treasure.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_RUSH]=             --限时抢购      
{
	"ui/ui_timeshop.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_CARDS]=             			-- 对对牌      
{
	"match_card_cnf",
	"match_card_pic_cnf",
	"ui/battle_res32.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_ARTIFACT]=             			-- 神器      
{
	"ui/ui_artifact.plist",
	"magic_price_cnf",
	"equip_make_cnf",
	"magic_des_cnf",
	"ui/bg/artifact_bg.jpg",
	"ui/bg/artifact_viewbg.jpg",
	"ui/gaf/sq_9105.png",
	"ui/gaf/sq_9205.png",
	"ui/gaf/sq_9305.png",
	"ui/gaf/sq_9405.png",
	"ui/gaf/sq_9505.png",
	"ui/gaf/sq_9605.png",
	"ui/gaf/sq_9705.png",
	"ui/gaf/sq_9805.png",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_BEAUTY]=             			-- 美人      
{
	"meiren_cnf",
	"meiren_class_cnf",
	"meiren_des_cnf",
	"ui/bg/beauty_bg.jpg",
	"ui/bg/beauty_dins.jpg",
	"ui/ui_beauty.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_SRSC]=             		-- 每日充值      
{
	"sales_sub_cnf",
	"ui/ui_everyday.plist",
	"ui/bg/bg_everyday.png",
	"ui/bg/everyday_reward1.png",
	"ui/bg/everyday_reward2.png",
	"ui/bg/everyday_reward3.png",
	-- "anim/task_recharge.plist"
}

Cfg.ResList[Cfg.UI_BattleCompareView] = 						-- 战力对比
{
	"ui/ui_expidit.plist",
	"ui/ui_strive.plist",
	"ui/ui_BattleComparison.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_BOX]=         				-- 秘宝活动      
{	
	"ui/bg/box_no1.png",
	"ui/bg/box_no2.png",
	"ui/bg/box_no3.png",
	"ui/ui_mail.plist",
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_DAOJIE] = 
{
	-- "ui/ui_copy.plist",                   -- 道劫
	"copy_chap_cnf",
	"copy_reward_cnf",
	"ui/ui_copy.plist",
	"ui/ui_icon.plist",
	"copy_times_pay_cnf",
	"vip_cnf",
    
}

Cfg.ResList[_G.Const.CONST_FUNC_OPEN_CHENGJIU] = 
{
	"ui/ui_achieve.plist",
	"achieve_cnf",
}

Cfg.IconResList={
	[_G.Const.CONST_FUNC_OPEN_ROLE] = "main_icon_role.png", --角色
	[_G.Const.CONST_FUNC_OPEN_BAG] = "main_icon_bag.png", --背包
	[_G.Const.CONST_FUNC_OPEN_GANGS] = "main_icon_clan.png", --门派
	[_G.Const.CONST_FUNC_OPEN_TASK] = "main_icon_task.png", --任务
	[_G.Const.CONST_FUNC_OPEN_SETING] = "main_icon_setting.png", --系统设置
	[_G.Const.CONST_FUNC_OPEN_PARTNER] = "main_icon_protect.png", --灵妖
	[_G.Const.CONST_FUNC_OPEN_DAEMON] = "main_icon_partner.png", --仙宠
	[_G.Const.CONST_FUNC_OPEN_MALL] = "main_icon_email.png", --邮件
	[_G.Const.CONST_FUNC_OPEN_WELFARE] = "main_icon_invest.png", --福利
	[_G.Const.CONST_FUNC_OPEN_SHOP] = "main_icon_shop.png", --商城
	[_G.Const.CONST_FUNC_OPEN_SHOP_SHENQI] = "main_icon_shop.png", --兑换商城
	[_G.Const.CONST_FUNC_OPEN_MOUNT] = "main_icon_vehicle.png", --坐骑
	[_G.Const.CONST_FUNC_OPEN_SMITHY] = "main_icon_weapon.png", --湛卢坊
	[_G.Const.CONST_FUNC_OPEN_SHEN]="main_icon_bagua.png",--卦象
	[_G.Const.CONST_FUNC_OPEN_ARTIFACT]="main_icon_box.png",--神兵
	[_G.Const.CONST_FUNC_OPEN_BEAUTY]="main_icon_meiren.png",--女儿国
	[_G.Const.CONST_FUNC_OPEN_JEWELLERY]="main_icon_zhenbao.png",--珍宝
	[_G.Const.CONST_FUNC_OPEN_WING]="main_icon_soulsoul.png",--宠物
	[_G.Const.CONST_FUNC_OPEN_PAIHANG] = "main_icon_deification.png", --排行
	[_G.Const.CONST_FUNC_OPEN_DUEL]="main_iconbig_jingji.png",--竞技
	[_G.Const.CONST_FUNC_OPEN_DEKARON]="main_iconbig_tiaozhan.png",--挑战
	[_G.Const.CONST_FUNC_OPEN_ACTIVITY]="main_iconbig_huodong.png",--活动
	[_G.Const.CONST_FUNC_OPEN_TIME] = "main_icon_shopping_rush.png", --限时活动(主界面)
    [_G.Const.CONST_FUNC_OPEN_ENARGY]="main_icon_power.png",--体力领取
	[_G.Const.CONST_FUNC_OPEN_STRATEGY]="main_icon_regulation.png", --游戏攻略
	[_G.Const.CONST_FUNC_OPEN_FRIEND]="main_icon_friend.png",--好友
	[_G.Const.CONST_FUNC_OPEN_RECHARGE]="main_icon_pay.png",--充值
	[_G.Const.CONST_FUNC_OPEN_GAMBLE] = "main_icon_box.png", 		--翻翻乐
    [_G.Const.CONST_PUBLIC_KEY_EXPEDIT]= "main_icon_combat.png", 	--群雄争霸-跨服远征
 	[_G.Const.CONST_FUNC_OPEN_JINGXIU] = "main_icon_box.png", --浮屠静修
 	[_G.Const.CONST_FUNC_OPEN_LUCKY] = "main_icon_treasure.png", --招财
    [_G.Const.CONST_FUNC_OPEN_MOIL] = "main_icon_slave.png", --竞技场(苦工)
    
    [_G.Const.CONST_FUNC_OPEN_ARENA] = "main_icon_combat_2.png",
    [_G.Const.CONST_FUNC_OPEN_MYTH] = "main_icon_deification.png",
    [_G.Const.CONST_FUNC_OPEN_TOWER] = "main_icon_futu.png",
    [_G.Const.CONST_FUNC_OPEN_SURRENDER] = "main_icon_good_places.png",
    [_G.Const.CONST_FUNC_OPEN_ARTIFACT] = "main_icon_garment.png",

    --[_G.Const.CONST_FUNC_OPEN_EXAMINATION_DAILY] = "main_icon_top_up_3.png", --每日充值
    [_G.Const.CONST_FUNC_OPEN_SRSC] = "main_icon_top_up_3.png", --三日首充

    -- 大活动
    [_G.Const.CONST_FUNC_OPEN_HOLIDAY]="main_icon_jieri.png", --节日活动
    [_G.Const.CONST_FUNC_OPEN_REBATE]="main_icon_rebate.png", --精彩返利
    [_G.Const.CONST_FUNC_OPEN_GANGS_KING]="main_icon_zhanshan.png", --第一门派
    [_G.Const.CONST_FUNC_OPEN_SEVENDAY]="main_icon_gift.png", 	--开服七日
    [_G.Const.CONST_FUNC_OPEN_DEMONS]="main_icon_Demons.png", -- 一骑当千 -- 无尽心魔
    [_G.Const.CONST_FUNC_OPEN_EXAMINATION]="main_icon_examinations.png", -- 御前科举

    [_G.Const.CONST_FUNC_OPEN_GANGS_WAR]="main_icon_dongfuzhan.png", --门派大战
    [_G.Const.CONST_FUNC_OPEN_GANGS_DEFEND]="main_icon_shengshou.png", --门派塔防
    [_G.Const.CONST_FUNC_OPEN_AUCTION]="main_icon_auction.png",--拍卖
    [_G.Const.CONST_FUNC_OPEN_RUSH]="main_icon_shopping_rush.png",--限时抢购
    [_G.Const.CONST_FUNC_OPEN_BOSS_SHIJIE]="main_icon_yaowang.png",--世界boss
    [_G.Const.CONST_FUNC_OPEN_BOSS_CHENGZHEN]="main_icon_yaowang.png",--城镇boss
    [_G.Const.CONST_FUNC_OPEN_STRIVE]="main_icon_contend.png",--三界争锋
    [_G.Const.CONST_FUNC_OPEN_WELKIN_ONLY]="main_icon_dzsj.png", --大闹天宫-太清混元
    [_G.Const.CONST_FUNC_OPEN_GANGS_BOSS]="main_icon_shouhu.png", --门派BOSS
    [_G.Const.CONST_FUNC_OPEN_QILING]="main_icon_qiling.png", --武器
    [_G.Const.CONST_FUNC_OPEN_FEATHER]="main_icon_feather.png", --翅膀
    [_G.Const.CONST_FUNC_OPEN_BOX]="main_icon_mibao.png", --秘宝活动
    [_G.Const.CONST_FUNC_OPEN_CHENGJIU]="main_icon_achieve.png", --成就
    [_G.Const.CONST_FUNC_OPEN_DAOJIE]="main_icon_daojie.png", --成就
    [_G.Const.CONST_FUNC_OPEN_LYJJ]="main_icon_lingyaodao.png", --灵妖竞技
}

Cfg.SoundEffectNoUnLoad=
{
	ui_sys_click=true,
	ui_sys_clickoff=true,
}