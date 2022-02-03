GameModule = {
	"base.baseclass"
	, "base.common_ui"							--面板的最基础父类
	, "base.baseview"
	, "base.basecontroller"

	, "file_update"
	, "call_function"
	, "sdk_function"
	, "cli_log"

-------------全局工具----------
	, "util.pathtool"
	, "util.util"
	, "util.gamemath"
	, "util.heap"
	, "util.list"
	, "util.astar"
	, "util.debug"
	, "util.string_util"
	, "util.array"
	, "util.time_tool"
	, "util.tile_util"
	, "util.map_util"
	, "util.sorttool"
	, "util.cc_util"
	, "util.fix_array"	
	, "util.filter"
	, "util.cocos_tool"                           -- cocos相关

-------------全局常量-----------
	, "sys.global_const_define"
	, "sys.global_time_ticket"
	, "sys.global_message_mgr"
	, "sys.global_keybord_event"
	, "sys.word_censor"
	, "sys.net.smartsocket"
	, "sys.net.proto_mgr"
	, "sys.net.gamenet"
	, "sys.render_mgr"
	, "sys.jump_controller"
	, "sys.sys_controller"
	, "sys.sys_env"
	, "sys.role_env"


-------------通用接口-----------
	, "common.common_function"
	, "common.save_local_data"
	, "common.audio_manager"
	, "common.view_manager"
	, "common.global_event"
	, "common.common_define"
	, "common.common_alert"
	, "common.custom_event"							--自定义事件
	, "common.ui_template"							--编辑器生成的窗体
	, "common.custom_button"						--自定义按钮
	, "common.custom_page_view"                     --自定义翻页容器
	, "common.buff_vo" 								-- buff基础数据结构
	, "common.debug_tool"
	, "common.debug_value"
	, "common.error_msg"
	, "common.gm_cmd"
	, "common.spine_renderer"  
	, "common.tab_select_bar"                       -- 标签页的控件
	, "common.tab_select_btn"                       -- 有选中状态的按钮
	, "common.radio_button"                         -- 单选按钮
	, "common.radio_group"                          -- 单选按钮组
	, "common.player_head"
	, "common.queue_manager"						--队列加载资源,防止一次性加载
	, "common.common_goods_type"                    --通用物品
	, "common.money_tool"                           --计算万位钱
	, "common.common_num_bar"                       --数字加减控件
	, "common.action_help"                          --一些通用动作集成
	-- , "common.cocostudio.cocos_tab"             	--cocos中编辑的tab
	-- , "common.custom_combox"						--自定义下拉框
	, "common.resources_cache"
	, "common.resources_load"
	, "common.resources_load_mgr"
	, "common.common_scrollview"
	, "common.common_scrollview_single"
	, "common.adjust_bezier_panel"
	, "common.gm_adjust_config_panel"

-------------一些纯数据结构类的-----------
	, "game.role.base_role"
	, "game.role.role_event"
	, "game.role.looks_vo"
	, "game.role.role_vo"
	, "game.role.role_calculate"
	, "game.role.role_const"
	
--------------功能类------------
	, "game.scene.main_scene_controller"	
	, "game.scene.element.scene_obj"
	, "game.scene.scene_event"
	, "game.scene.scene_const"
	, "game.scene.map_tile"
	
	, "game.role.role_controller"					--主角相关
	, "game.role.role_model"	

	, "game.login.login_event"
	, "game.login.login_controller"
	, "game.login.login_model"
	, "game.login.login_platform"

	, "game.common_ui.commonui_controller"   --通用ui控制类

	--剧情
	, "game.story.story_controller"
	, "game.story.story_model"
	, "game.story.story_event"

	, "game.chat.chat_controller"					--聊天
	, "game.chat.chat_model"
	, "game.chat.chat_event"
	, "game.chat.chat_const"
	, "game.chat.chat_vo"	
	, "game.chat.chat_help"	
	, "game.chat.chat_mgr"
	, "game.chat.voice_mgr"
	, "game.chat.for_loop"
	, "game.chat.ref.ref_controller"

	, "game.mainui.mainui_event"
	, "game.mainui.mainui_const"
	, "game.mainui.mainui_controller"	
	, "game.mainui.mainui_model"
	, "game.mainui.tencentcos"

	--引导相关
	, "game.guide.guide_event"
	, "game.guide.guide_model"
	, "game.guide.guide_controller"

	--战斗相关
	, "game.battle.battle_controller"
	, "game.battle.battle_event"
	, "game.battle.battle_model"
	, "game.battle.new_view.skill_act"
	, "game.battle.battle_loop2"
	, "game.battle.battle_const"
	, "game.battle.battle_hook_model"
	, "game.battle.battle_result_mgr"
	, "game.battle.battle_result_mgr"
	, "game.battle.battle_result_return_mgr"

	--战斗剧情副本
	, "game.battle_drama.battle_drama_controller"
	, "game.battle_drama.battle_drama_event"
	, "game.battle_drama.battle_drama_model"
	
	--好友模块
	, "game.friend.friend_vo"
	, "game.friend.friend_controller"
	, "game.friend.friend_event"
	, "game.friend.friend_model"
	, "game.friend.friend_const"	

	--邮件
	, "game.mail.mail_event"
	, "game.mail.mail_controller"	
	, "game.mail.mail_model"
	, "game.mail.mail_vo"

	-- 小图标提示
	, "game.prompt.prompt_constants"
	, "game.prompt.prompt_controller"
	, "game.prompt.prompt_event"
	, "game.prompt.prompt_model"

	--背包模块
	, "game.backpack.backpack_event"
	, "game.backpack.backpack_controller"	
	, "game.backpack.backpack_model"
	, "game.backpack.backpack_const"
	, "game.backpack.goods_vo"

	--任务相关
	, "game.task.task_event"
	, "game.task.task_const"
	, "game.task.task_controller"
	, "game.task.task_model"
	, "game.task.task_vo"

	--tips模块
	, "game.tips.tips_event"
	, "game.tips.tips_controller"
	, "game.tips.tips_model"
	, "game.tips.tips_manager"

	--竖版新伙伴
	, "game.partner.partner_event"
	, "game.partner.partner_const"
	, "game.partner.partner_calculate"

	--竖版新伙伴(新) hero --by lwc
	, "game.hero.hero_event"
	, "game.hero.hero_model"
	, "game.hero.hero_controller"
	, "game.hero.hero_const"
	, "game.hero.hero_vo"
	, "game.hero.hero_calculate"

	--萌宠功能 --by lwc
	, "game.homepet.homepet_event"
	, "game.homepet.homepet_model"
	, "game.homepet.homepet_controller"
	, "game.homepet.homepet_const"
	, "game.homepet.homepet_vo"

	--星命塔模块
	, "game.startower.startower_controller"
	, "game.startower.startower_event"
	, "game.startower.startower_model"
	
	--公告模块
	, "game.notice.notice_controller"
	, "game.notice.notice_event"
	, "game.notice.notice_model"

	--商城模块
	, "game.mall.mall_const"
	, "game.mall.mall_event"
	, "game.mall.mall_model"
	, "game.mall.mall_controller"

	--图书馆模块
	, "game.pokedex.pokedex_event"
	, "game.pokedex.pokedex_model"
	, "game.pokedex.pokedex_controller"

	--排行榜
	, "game.rank.rank_event"
	, "game.rank.rank_constant"
	, "game.rank.rank_model"
	, "game.rank.rank_controller"

	-- 弹幕
	, "game.barrage.barrage_event"
	, "game.barrage.barrage_model"
	, "game.barrage.barrage_controller"

	-- 竞技场
	, "game.arena.arena_controller"
	, "game.arena.arena_event"
	, "game.arena.arena_model"
	, "game.arena.arena_champion_model"

	-- 组队竞技场
	, "game.arenateam.arenateam_controller"
	, "game.arenateam.arenateam_event"
	, "game.arenateam.arenateam_model"
	, "game.arenateam.arenateam_const"

	--新的竖版召唤
	, "game.partnersummon.partnersummon_controller"
	, "game.partnersummon.partnersummon_event"
	, "game.partnersummon.partnersummon_model"
	, "game.partnersummon.partnersummon_const"

	--新的竖版召唤
	, "game.newpartnersummon.newpartnersummon_controller"
	, "game.newpartnersummon.newpartnersummon_event"
	, "game.newpartnersummon.newpartnersummon_model"
	, "game.newpartnersummon.newpartnersummon_const"

	--竖版星命占卜系统 已弃用
	-- , "game.augury.augury_controller"
	-- , "game.augury.augury_event"
	-- , "game.augury.augury_model" 

	--查看模块，暂时只有英雄查看
	, "game.look.look_controller"
	, "game.look.look_event"
	, "game.look.look_model"
	--vip
	, "game.vip.vip_controller"
	, "game.vip.vip_model"
	, "game.vip.vip_event"
	
	--世界地图
	, "game.worldmap.worldmap_controller"
	, "game.worldmap.worldmap_event"
	, "game.worldmap.worldmap_model"

	--联盟部分
	, "game.guild.guild_controller"
	, "game.guild.guild_event"
	, "game.guild.guild_model" 
	, "game.guild.guild_const"
	--公会宝库
	, "game.guildmarketplace.guildmarketplace_controller"
	, "game.guildmarketplace.guildmarketplace_event"
	, "game.guildmarketplace.guildmarketplace_model" 
	, "game.guildmarketplace.guildmarketplace_const"
	--公会秘境
	, "game.guildsecretarea.guildsecretarea_controller"
	, "game.guildsecretarea.guildsecretarea_event"
	, "game.guildsecretarea.guildsecretarea_model" 
	, "game.guildsecretarea.guildsecretarea_const"

	--联盟红包部分
	, "game.redbag.redbag_controller"
	, "game.redbag.redbag_event"
	, "game.redbag.redbag_model" 

	--神界探险
	, "game.adventure.adventure_controller"
	, "game.adventure.adventure_event"
	, "game.adventure.adventure_ui_model"
	--市场
	, "game.market.market_controller"
	, "game.market.market_event"
	, "game.market.market_model"
	--联盟副本
	, "game.guildboss.guildboss_const"
	, "game.guildboss.guildboss_controller" 
	, "game.guildboss.guildboss_event" 
	, "game.guildboss.guildboss_model" 
	--金银币兑换 神格许愿
	, "game.exchange.exchange_controller"
	, "game.exchange.exchange_model"
	, "game.exchange.exchange_event"
	--福利模块
	, "game.welfare.welfare_controller"
	, "game.welfare.welfare_model"
	, "game.welfare.welfare_event"
	, "game.welfare.welfare_constants"
	-- 联盟技能
	, "game.guildskill.guildskill_event"
	, "game.guildskill.guildskill_const"
	, "game.guildskill.guildskill_model" 
	, "game.guildskill.guildskill_controller"
	--活动
	, "game.action.action_controller"
	, "game.action.action_model"
	, "game.action.action_event"
	, "game.action.action_constants"

	--开学季活动boss
	, "game.actiontermbegins.actiontermbegins_controller"
	, "game.actiontermbegins.actiontermbegins_model"
	, "game.actiontermbegins.actiontermbegins_event"
	, "game.actiontermbegins.actiontermbegins_constants"

	--年兽活动
	, "game.actionyearmonster.actionyearmonster_controller"
	, "game.actionyearmonster.actionyearmonster_model"
	, "game.actionyearmonster.actionyearmonster_event"
	, "game.actionyearmonster.actionyearmonster_constants"
	, "game.actionyearmonster.actionyearmonster_evt_vo"

	--巅峰竞技场 冠军赛
	, "game.arenapeakchampion.arenapeakchampion_controller"
	, "game.arenapeakchampion.arenapeakchampion_model"
	, "game.arenapeakchampion.arenapeakchampion_event"
	, "game.arenapeakchampion.arenapeakchampion_constants"

	-- 多人竞技场
	, "game.arenamanypeople.arenamanypeople_controller"
	, "game.arenamanypeople.arenamanypeople_event"
	, "game.arenamanypeople.arenamanypeople_model"
	, "game.arenamanypeople.arenamanypeople_const"
	
	--回归活动
	, "game.returnaction.returnaction_controller"
	, "game.returnaction.returnaction_model"
	, "game.returnaction.returnaction_event"
	, "game.returnaction.returnaction_constants"

	--活动的限时试炼之境
	, "game.limitexercise.limitexercise_controller"
	, "game.limitexercise.limitexercise_model"
	, "game.limitexercise.limitexercise_event"
	, "game.limitexercise.limitexercise_constants"

	--每日活动
	, "game.daycharge.daycharge_controller"
	, "game.daycharge.daycharge_model"
	, "game.daycharge.daycharge_event"

	--活跃活动
	, "game.animate_action.animate_action_controller"
	, "game.animate_action.animate_action_model"
	, "game.animate_action.animate_action_event"
	, "game.animate_action.animate_action_constants"

	--节日活动
	, "game.festivalaction.festivalaction_controller"
	, "game.festivalaction.festivalaction_model"
	, "game.festivalaction.festivalaction_event"
	, "game.festivalaction.festivalaction_constants"

	--限时钜惠礼包
	, "game.limittime.limittimeaction_controller"
	, "game.limittime.limittimeaction_model"
	, "game.limittime.limittimeaction_event"
	, "game.limittime.limittimeaction_constants"

	-- RFM个人推送礼包
	, 'game.rfmpersonalgift.rfm_personnal_gift_controller'
	, 'game.rfmpersonalgift.rfm_personnal_gift_event'


	--七天目标
	, "game.sevengoal.seven_goal_controller"
	, "game.sevengoal.seven_goal_model"
	, "game.sevengoal.seven_goal_event"
	, "game.sevengoal.seven_goal_constants"
	-- 联盟远航
	--[[, "game.guildvoyage.guildvoyage_const"
	, "game.guildvoyage.guildvoyage_event"
	, "game.guildvoyage.guildvoyage_model"
	, "game.guildvoyage.guildvoyage_controller"--]]
	-- 联盟战
	, "game.guildwar.guildwar_const"
	, "game.guildwar.guildwar_event"
	, "game.guildwar.guildwar_model"
	, "game.guildwar.guildwar_controller"
	--我要变强
	, "game.stronger.stronger_controller"
	, "game.stronger.stronger_model"
	, "game.stronger.stronger_event"

	-- 橙装制作和进阶
	, "game.equipmake.equipmake_const"
	, "game.equipmake.equipmake_event"
	, "game.equipmake.equipmake_model"
	, "game.equipmake.equipmake_controller"

	--无尽试炼
	, "game.endless_trail.endless_trail_controller"
	, "game.endless_trail.endless_trail_event"
	, "game.endless_trail.endless_trail_model"

	-- 护送
	, "game.escort.escort_controller"
	, "game.escort.escort_event"
	, "game.escort.escort_model"

	--限时活动面板
	, "game.activity.activity_controller"
	, "game.activity.activity_event"
	, "game.activity.activity_model"
	, "game.activity.activity_const"

	--英雄远征
	, "game.heroexpedit.heroexpedit_controller"
	, "game.heroexpedit.heroexpedit_event"
	, "game.heroexpedit.heroexpedit_model"

	--试炼之门
	, "game.esecsice.esecsice_controller"
	, "game.esecsice.esecsice_event"
	, "game.esecsice.esecsice_model"
	, "game.esecsice.esecsice_const"

	--副本活动
	, "game.stone_dungeon.stone_dungeon_controller"
	, "game.stone_dungeon.stone_dungeon_event"
	, "game.stone_dungeon.stone_dungeon_model"

	--众神战场
	, "game.godbattle.godbattle_const"
	, "game.godbattle.godbattle_controller"
	, "game.godbattle.godbattle_event"
	, "game.godbattle.godbattle_model"

	-- 升级
	, "game.levupgrade.levupgrade_controller"
	, "game.levupgrade.levupgrade_event"
	, "game.levupgrade.levupgrade_model"

	-- 圣器系统
	, "game.hallows.hallows_controller"
	, "game.hallows.hallows_event"
	, "game.hallows.hallows_model"
	, "game.hallows.hallows_const"
	, "game.hallows.hallows_vo"

	--荣耀神殿玩法
	, "game.primus.primus_controller"
	, "game.primus.primus_event"
	, "game.primus.primus_model"

	--精英赛
	, "game.elitematch.elitematch_event"
	, "game.elitematch.elitematch_model"
	, "game.elitematch.elitematch_controller"
	, "game.elitematch.elitematch_const"

	--跨服天梯
	, "game.ladder.ladder_controller"
	, "game.ladder.ladder_event"
	, "game.ladder.ladder_model"
	, "game.ladder.ladder_const"

		--跨服时空 --bg lwc
	, "game.crossshow.crossshow_controller"
	, "game.crossshow.crossshow_event"
	, "game.crossshow.crossshow_model"
	-- , "game.crossshow.crossshow_const"

	--锻造房
	, "game.forgehouse.forgehouse_controller"
	, "game.forgehouse.forgehouse_event"
	, "game.forgehouse.forgehouse_model"
	, "game.forgehouse.forgehouse_const"

	--礼包浏览
	, "game.onlinegift.onlinegift_controller"
	, "game.onlinegift.onlinegift_event"
	, "game.onlinegift.onlinegift_model"

	--自由移动场景
	, "game.rolescene.rolescene_controller"
	, "game.rolescene.rolescene_event"
	, "game.rolescene.rolescene_model"
	, "game.rolescene.rolescene_npc"
	, "game.rolescene.rolescene_obj"
	, "game.rolescene.rolescene_vo"
	, "game.rolescene.rolescene_player"
	, "game.rolescene.rolescene_const"

	--先知殿
	, "game.seerpalace.seerpalace_controller"
	, "game.seerpalace.seerpalace_event"
	, "game.seerpalace.seerpalace_model"
	, "game.seerpalace.seerpalace_const"

	--远航商人
	, "game.voyage.voyage_controller"
	, "game.voyage.voyage_event"
	, "game.voyage.voyage_model"
	, "game.voyage.voyage_const"
	, "game.voyage.voyage_order_vo"

	--录像馆
	, "game.vedio.vedio_controller"
	, "game.vedio.vedio_event"
	, "game.vedio.vedio_model"
	, "game.vedio.vedio_const"

	-- 限时召唤
	, "game.timesummon.timesummon_controller"
	, "game.timesummon.timesummon_event"
	, "game.timesummon.timesummon_model"
	, "game.timesummon.timesummon_const"

	-- 精英召唤
	, "game.elitesummon.elitesummon_controller"
	, "game.elitesummon.elitesummon_event"
	, "game.elitesummon.elitesummon_model"
	, "game.elitesummon.elitesummon_const"

	--邀请码
	, "game.invitecode.invitecode_controller"
	, "game.invitecode.invitecode_event"
	, "game.invitecode.invitecode_model"

	-- 跨服战场
	, "game.crossground.crossground_controller"
	, "game.crossground.crossground_event"
	, "game.crossground.crossground_model"
	, "game.crossground.crossground_const"

	-- 冒险活动入口
	, "game.adventureactivity.adventureactivity_controller"
	, "game.adventureactivity.adventureactivity_event"
	, "game.adventureactivity.adventureactivity_model"
	, "game.adventureactivity.adventureactivity_const"

	-- 元素神殿
	, "game.element.element_controller"
	, "game.element.element_event"
	, "game.element.element_model"
	, "game.element.element_const"

	-- 圣物
	, "game.halidom.halidom_controller"
	, "game.halidom.halidom_event"
	, "game.halidom.halidom_model"
	, "game.halidom.halidom_const"
	, "game.halidom.halidom_vo"

	-- 精灵
	, "game.elfin.elfin_controller"
	, "game.elfin.elfin_event"
	, "game.elfin.elfin_model"
	, "game.elfin.elfin_const"
	, "game.elfin.elfin_hatch_vo"

	--新版首充
	, "game.newfirstcharge.newfirstcharge_controller"
	, "game.newfirstcharge.newfirstcharge_event"
	, "game.newfirstcharge.newfirstcharge_model"

	-- 转盘活动
	, "game.dial_action.dial_action_controller"
	, "game.dial_action.dial_action_event"
	, "game.dial_action.dial_action_model"
	, "game.dial_action.dial_action_const"

	-- 花火大会活动
	, "game.petard_action.petard_action_controller"
	, "game.petard_action.petard_action_event"
	, "game.petard_action.petard_action_model"
	, "game.petard_action.petard_action_const"

	-- 砸金蛋活动
	, "game.smashegg.smashegg_controller"
	, "game.smashegg.smashegg_event"
	, "game.smashegg.smashegg_model"
	, "game.smashegg.smashegg_const"

	--合服相关
	, "game.mergeserver.mergeserver_controller"
	, "game.mergeserver.mergeserver_event"
	, "game.mergeserver.mergeserver_model"
	
	-- 天界副本
	, "game.heaven.heaven_controller"
	, "game.heaven.heaven_event"
	, "game.heaven.heaven_model"
	, "game.heaven.heaven_const"
	, "game.heaven.heaven_chapter_vo"
	, "game.heaven.heaven_customs_vo"

	--限时招募
	, "game.recruithero.recruithero_controller"
	, "game.recruithero.recruithero_event"
	, "game.recruithero.recruithero_model"

	--战令活动
	, "game.orderaction.orderaction_constants"
	, "game.orderaction.orderaction_controller"
	, "game.orderaction.orderaction_event"
	, "game.orderaction.orderaction_model"

	--全新战令
	, "game.neworderaction.neworderaction_constants"
	, "game.neworderaction.neworderaction_controller"
	, "game.neworderaction.neworderaction_event"
	, "game.neworderaction.neworderaction_model"

	--神装商店
	, "game.suitshop.suitshop_controller"
	, "game.suitshop.suitshop_event"
	, "game.suitshop.suitshop_model"

	-- 跨服竞技场
	, "game.crossarena.crossarena_controller"
	, "game.crossarena.crossarena_event"
	, "game.crossarena.crossarena_model"
	, "game.crossarena.crossarena_const"

	-- 家园
	, "game.homeworld.homeworld_controller"
	, "game.homeworld.homeworld_event"
	, "game.homeworld.homeworld_model"
	, "game.homeworld.homeworld_const"
	, "game.homeworld.home_tile"
	, "game.homeworld.furniture_vo"

	-- 跨服冠军赛
	, "game.crosschampion.crosschampion_controller"
	, "game.crosschampion.crosschampion_event"
	, "game.crosschampion.crosschampion_model"

	-- 大富翁
	, "game.monopoly.monopoly_controller"
	, "game.monopoly.monopoly_event"
	, "game.monopoly.monopoly_model"
	, "game.monopoly.monopoly_const"
	, "game.monopoly.monopoly_grid_vo"
	, "game.monopoly.monopoly_tile"

	-- 验证码
	, "game.verificationcode.verificationcode_controller"
	, "game.verificationcode.verificationcode_event"
	, "game.verificationcode.verificationcode_model"

	-- 冒险奇遇
	, "game.encounter.encounter_controller"
	, "game.encounter.encounter_event"
	, "game.encounter.encounter_model"
	, "game.encounter.encounter_const"

	-- 区场景（商业区等）
	, "game.area_scene.area_scene_controller"
	, "game.area_scene.area_scene_event"
	, "game.area_scene.area_scene_const"
	-- 新手训练营
	, "game.trainingcamp.trainingcamp_controller"
	, "game.trainingcamp.trainingcamp_event"
	, "game.trainingcamp.trainingcamp_model"

	-- 位面冒险(废弃)
	-- , "game.planes.planes_controller"
	-- , "game.planes.planes_event"
	-- , "game.planes.planes_model"
	-- , "game.planes.planes_const"
	-- , "game.planes.planes_tile"
	-- , "game.planes.planes_evt_vo"


	-- 位面冒险改版 参考 afk
	, "game.planesafk.planesafk_const"
	, "game.planesafk.planesafk_controller"
	, "game.planesafk.planesafk_event"
	, "game.planesafk.planesafk_model"

	--战力飞升礼包（0.1元礼包）
	, "game.onecentgift.onecentgift_controller"
	, "game.onecentgift.onecentgift_event"
	, "game.onecentgift.onecentgift_model"

	--新人练武场
	, "game.practisetower.practisetower_controller"
	, "game.practisetower.practisetower_event"
	, "game.practisetower.practisetower_model"
	
}

NewModelFile = {
	['LoginWindow'] = 'game.login.view.login_window'
	, ['UserPanel'] = 'game.login.view.user_panel'
	, ['PlatformPanel'] = 'game.login.view.platform_panel'
	, ['EnterPanel'] = 'game.login.view.enter_panel'
	, ['UserProtoPanel'] = 'game.login.view.user_proto_panel'
	, ["ServerPanel"] = 'game.login.view.server_panel'
	, ["ReconnectView"] = 'game.login.view.reconnect_view'
	, ["ServerCell"] = 'game.login.view.server_cell'
	, ["RoleLoginCell"] = 'game.login.view.role_login_cell'
	, ["DownLoadView"] = 'game.login.view.download_view'
	, ["FillView"] = 'game.login.view.login_fill_view'

	, ["LevupgradeWindow"] = 'game.levupgrade.view.lev_upgrade_window'

		--commonui
	, ["CommonComboboxPanel"] = 'game.common_ui.view.common_combobox_panel'

	
	-- 召唤
	, ["NewPartnerSummonWindow"] = 'game.newpartnersummon.view.newpartnersummon_window'

	-- 圣器系统
	, ["HallowsMainWindow"] = 'game.hallows.view.hallows_main_window'
	, ["HallowsTraceWindow"] = 'game.hallows.view.hallows_trace_window' 
	, ["HallowsActivityWindow"] = 'game.hallows.view.hallows_activity_window' 
	, ["HallowsStepUpWindow"] = 'game.hallows.view.hallows_step_up_window' 
	, ["HallowsTips"] = 'game.hallows.view.hallows_tips' 
	, ["HallowsTaskWindow"] = 'game.hallows.view.hallows_task_window' 
	, ["HallowsPreviewWindow"] = 'game.hallows.view.hallows_preview_window'
	, ["HallowsMagicWindow"] = 'game.hallows.view.hallows_magic_window'

	--荣耀神殿玩法
	, ["PrimusMainWindow"] = 'game.primus.view.primus_main_window' 
	, ["PrimusChallengePanel"] = 'game.primus.view.primus_challenge_panel' 
	, ["PrimusChallengeRecordPanel"] = 'game.primus.view.primus_challenge_record_panel' 
	, ["PrimusChallengeRecordItem"] = 'game.primus.view.primus_challenge_record_item' 
	, ["PrimusChallengeResultWindow"] = 'game.primus.view.primus_challenge_result_window' 

	-- 众神战场
	, ["GodBattleScene"] = 'game.godbattle.view.godbattle_scene'
	, ["GodBattleResultView"] = 'game.godbattle.view.godbattle_result_view'
	, ["GodBattleMainUI"] = 'game.godbattle.view.godbattle_mainui'
	, ["GodBattleKillNoticeView"] = 'game.godbattle.view.godbattle_killnotice_view'
	, ["GodBattleRewardsWindow"] = 'game.godbattle.view.godbattle_rewards_window'
	, ["GodBattleInfoView"] = 'game.godbattle.view.godbattle_info_view'
	, ["GodBattleRewardsPanel"] = 'game.godbattle.view.godbattle_rewards_panel'
	, ["GodBattleExplainPanel"] = 'game.godbattle.view.godbattle_explain_panel'
	, ["GodBattleRankRewardPanel"] = 'game.godbattle.view.godbattle_rank_reward_panel'

	-- 护送
	, ["EscortChallengeWindow"] = 'game.escort.view.escort_challenge_window'
	, ["EscortEmployWindow"] = 'game.escort.view.escort_employ_window'
	, ["EscortLogAtkPanel"] = 'game.escort.view.escort_log_atk_panel'
	, ["EscortLogDefPanel"] = 'game.escort.view.escort_log_def_panel'
	, ["EscortLogWindow"] = 'game.escort.view.escort_log_window'
	, ["EscortMainWindow"] = 'game.escort.view.escort_main_window'
	, ["EscortMyInfoWindow"] = 'game.escort.view.escort_my_info_window'
	, ["EscortPlunderWindow"] = 'game.escort.view.escort_plunder_window'

	-- 新任务
	, ["TaskMainWindow"] = 'game.task.view.task_main_window'
	, ["TaskPanel"] = 'game.task.view.task_panel'
	, ["FeatPanel"] = 'game.task.view.feat_panel'
	, ["TaskItem"] = 'game.task.view.task_item'
	--历练 --by lwc
	, ["TaskExpPanel"] = 'game.task.view.task_exp_panel'
	, ["TaskSharePanel"] = 'game.task.view.task_share_panel'

	, ["FunctionIcon"] = 'game.mainui.icon.function_icon'
	, ["FunctionIconVo"] = 'game.mainui.icon.function_icon_vo'
	, ["ItemExhibitionView"] = 'game.mainui.view.item_exhibition_view'
	, ["ItemExhibitionCompView"] = 'game.mainui.view.item_exhibition_comp_view'
	, ["ItemExhibitionList"] = 'game.mainui.view.item_exhibition_list'
	, ["PlayEffectView"] = 'game.mainui.view.play_effect_view'
	, ["LimitActionWindowTips"] = 'game.mainui.view.limit_action_window_tips'

	-- 主城建筑
	, ["BuildVo"] = 'game.scene.vo.build_vo'
	, ["UnitVo"] = 'game.scene.vo.unit_vo'
	
	-- 联盟相关
	, ["GuildInitWindow"] = 'game.guild.view.guild_init_window'
	, ["GuildMainWindow"] = 'game.guild.view.guild_main_window'
	, ["GuildCreatePanel"] = 'game.guild.view.guild_create_panel'
	, ["GuildListPanel"] = 'game.guild.view.guild_list_panel' 
	, ["GuildRequestItem"] = 'game.guild.view.guild_request_item'
	, ["GuildSearchPanel"] = 'game.guild.view.guild_search_panel' 
	, ["GuildListVo"]= 'game.guild.guild_list_vo' 
	, ["GuildMyInfoVo"] = 'game.guild.guild_my_info_vo'
	, ["GuildMemberVo"] = 'game.guild.guild_member_vo' 
	, ["GuildMemberWindow"] = 'game.guild.view.guild_member_window'
	, ["GuildDonateWindow"] = 'game.guild.view.guild_donate_window'
	, ["GuildApplyWindow"] = 'game.guild.view.guild_apply_window'
	, ["GuildApplySetWindow"] = 'game.guild.view.guild_apply_set_window'
	, ["GuildOperationPostWindow"] = 'game.guild.view.guild_operation_post_window'
	, ["GuildImpeachPostWindow"] = 'game.guild.view.guild_impeach_post_window'
	, ["GuildChangeNameWindow"] = 'game.guild.view.guild_change_name_window' 
	, ["GuildChangeSignWindow"] = 'game.guild.view.guild_change_sign_window'
	, ["GuildActionGoalWindow"] = 'game.guild.view.guild_action_goal_window'
	, ["GuildRewardWindow"] = 'game.guild.view.guild_reward_window'
	, ["GuildSendMailWindow"] = 'game.guild.view.guild_send_mail_window'
	, ["GuildNoticeWindow"] = 'game.guild.view.guild_notice_window'
	, ["GuildNoticeVo"] = 'game.guild.guild_notice_vo'
	, ["GuildNewMainWindow"] = 'game.guild.view.guild_new_main_window'
	, ["GuildActiveIconWindow"] = 'game.guild.view.guild_active_icon_window'

	--公会宝库 --by lwc
	, ["GuildmarketplaceMainWindow"] = 'game.guildmarketplace.view.guildmarketplace_main_window'
	, ["GuildmarketplacePutItemWindow"] = 'game.guildmarketplace.view.guildmarketplace_put_item_window'
	, ["GuildmarketplaceBuyItemPanel"] = 'game.guildmarketplace.view.guildmarketplace_buy_item_panel'
	, ["GuildmarketplaceRecordInfoPanel"] = 'game.guildmarketplace.view.guildmarketplace_record_info_panel'

	--公会秘境 --by lwc
	, ["GuildsecretareaMainWindow"] = 'game.guildsecretarea.view.guildsecretarea_main_window'
	, ["GuildsecretareaRewardWindow"] = 'game.guildsecretarea.view.guildsecretarea_reward_window'
	, ["GuildsecretareaStartCrusadePanel"] = 'game.guildsecretarea.view.guildsecretarea_start_crusade_panel'
	, ["GuildsecretareaEndCrusadePanel"] = 'game.guildsecretarea.view.guildsecretarea_end_crusade_panel'
	
	-- 联盟副本（boss）
	, ["GuildBossMainWindow"] = 'game.guildboss.view.guildboss_main_window'
	, ["GuildBossPreviewWindow"] = 'game.guildboss.view.guildboss_preview_window'
	, ["GuildBossResetWindow"] = 'game.guildboss.view.guildboss_reset_window'
	, ["GuildBossPassRewardWindow"] = 'game.guildboss.view.guildboss_pass_reward_window' 
	, ["GuildBossBoxRewardWindow"] = 'game.guildboss.view.guildboss_box_reward_window' 
	, ["GuildBossRankWindow"] = 'game.guildboss.view.guildboss_rank_window' 
	, ["GuildBossRankGuildPanel"] = 'game.guildboss.view.guildboss_rank_guild_panel'
	, ["GuildBossRankRolePanel"] = 'game.guildboss.view.guildboss_rank_role_panel'
	, ["GuildbossResultWindow"] = 'game.guildboss.view.guildboss_result_window'
	, ["GuildbossResultDpsRankWindow"] = 'game.guildboss.view.guildboss_result_dpsrank_window'
	, ["GuildBossRankRoleWindow"] = 'game.guildboss.view.guildboss_rank_role_window'
	, ["GuildBossRewardShowView"] = 'game.guildboss.view.guildboss_reward_show_view'
	, ["GuildBossRewardShowItem"] = 'game.guildboss.view.guildboss_reward_show_view'
	-- 联盟技能
	, ["GuildskillMainWindow"] = 'game.guildskill.view.guildskill_main_window'
	, ["GuildskillResetPanel"] = 'game.guildskill.view.guildskill_reset_panel'
	, ["GuildskillLevelUpPanel"] = 'game.guildskill.view.guildskill_level_up_panel'
	, ["GuildskillLevelSuccessPanel"] = 'game.guildskill.view.guildskill_level_success_panel'

	--联盟红包模块
	, ["RedBagWindow"] = 'game.redbag.view.redbag_window'
	, ["RedBagSendPanel"] = 'game.redbag.view.redbag_send_panel'
	, ["RedBagGetPanel"] = 'game.redbag.view.redbag_get_panel'
	, ["RedBagRankPanel"] = 'game.redbag.view.redbag_rank_panel'
	, ["RedBagLookWindow"] = 'game.redbag.view.redbag_look_window'
	, ["RedBagItem"] = 'game.redbag.view.redbag_item'
	, ["RedBagListPanel"] = 'game.redbag.view.redbag_list_panel'
	, ["RedBagOpenView"] = 'game.redbag.view.redbag_open_view'
	
	--公告模块
	, ["NoticeWindow"] = 'game.notice.view.notice_window'
	, ["BugPanel"] = 'game.notice.view.bug_panel'
	--客服中心
	, ["ContactServicePanel"] = 'game.notice.view.contact_service_panel'
	, ["FeedbackDetailWindow"] = 'game.notice.view.feedback_detail_window'
	, ["ServiceCenterWindow"] = 'game.notice.view.service_center_window'

	--npc
	, ["Npc"] = 'game.scene.element.npc'
	, ["Player"] = 'game.scene.element.player'

	-- 橙装制作
	, ["EquipmakeMainWindow"] = 'game.equipmake.view.equipmake_main_window'
	, ["EquipmakeSourcesWindow"] = 'game.equipmake.view.equipmake_source_window'


	, ["CommonExplainWindow"] = "common.common_explainwindow"

	--剧情模块
	, ["StoryView"] = 'game.story.view.story_view'
	, ["StoryBubble"] = 'game.story.view.story_bubble'
	, ["StoryTalk"] = 'game.story.view.story_talk'
	, ["StoryMangaView"] = 'game.story.view.story_manga_view'
	, ["DramaWelcommeWindow"] = 'game.story.view.drama_welcome_window'
	, ["DramaBlackCurtainWindow"] = 'game.story.view.drama_blackcurtain_window'

	, ["MainUiView"] = 'game.mainui.view.main_ui_view'
	, ["MainUiNoticeView"] = 'game.mainui.view.mainui_notice_view'
	, ["DownloadPanel"] = 'game.mainui.view.download_panel'
	, ["MainChatUiMsg"] = 'game.mainui.view.main_ui_msg'
	, ["LimitTimePlayPanel"] = 'game.mainui.view.limit_time_play_panel'
	, ["LimitTimePlayItem"] = 'game.mainui.view.limit_time_play_panel'
	, ["CustomHeadImgWindow"] = 'game.mainui.view.custom_headimg_window'

	--聊天模块
	, ["VoiceRecordUI"] = 'game.chat.view.voice_record_ui'
	, ["ChatWindow"] = 'game.chat.view.chat_window'
	, ["ChatInput"] = 'game.chat.view.chat_input'
	, ["NewCoseList"] = "game.chat.view.new_cose_list"
	, ["ChatMsg"] = "game.chat.view.chat_msg"
	, ["SoundEffect"] = "game.chat.view.sound_effect"
	, ["RefFacesUI"] = "game.chat.ref.ref_faces_ui"
	, ["RefItemUI"] = "game.chat.ref.ref_item_ui"
	, ["RefEquipUI"] = "game.chat.ref.ref_equip_ui"
	, ["RefPanel"] = "game.chat.ref.ref_panel"
	, ["PrivateChatPanel"] = "game.chat.view.private_chat_panel"
	, ["ChatListPanel"] = "game.chat.view.chat_list_panel"
	, ["ChatRepoprtWindow"] = "game.chat.view.chat_report_window"
	
	--邮件模块
	, ["MailView"] = 'game.mail.view.mail_view'
	, ["MailItem"] = 'game.mail.view.mail_item'
	, ["MailInfo"] = 'game.mail.view.mail_info'
	, ["MailWindow"] = 'game.mail.view.mail_window'
	, ["MailCell"] = 'game.mail.view.mail_cell'
	, ["MailInfoWindow"] = 'game.mail.view.mail_info_window'

	--世界地图
	, ["WorldMapMainWindow"] = 'game.worldmap.view.worldmap_main_window'
	, ["WorldMapLand"] = 'game.worldmap.view.worldmap_land'
	, ["WorldMapItem"] = 'game.worldmap.view.worldmap_item'
	, ["WorldMapTipsWindow"] = 'game.worldmap.view.worldmap_tips_window'
	
	--竖版图书馆系统
	, ["PokedexWindow"] = 'game.pokedex.view.pokedex_window'
	, ["PokedexItem"] = 'game.pokedex.view.pokedex_item'
	, ["PokedexCheckWindow"] = 'game.pokedex.view.pokedex_check_window'
	, ["CheckAllPanel"] = 'game.pokedex.view.check_all_panel'
	, ["CheckDescPanel"] = 'game.pokedex.view.check_desc_panel'
	, ["CheckAttrPanel"] = 'game.pokedex.view.check_attr_panel'
	, ["PartnerCommentWindow"] = 'game.pokedex.view.partner_comment_window'
	, ["PokedexStarWindow"] = 'game.pokedex.view.pokedex_star_window'
	, ["PokedexDramaLookPanel"] = 'game.pokedex.view.pokedex_drama_panel'
		
	--竖版星命塔
	, ["StarTowerWindow"] = 'game.startower.view.star_tower_window'
	, ["StarTowerItem"] = 'game.startower.view.star_tower_item'
	, ["StarTowerAwardWindow"] = 'game.startower.view.star_tower_award_window'
	, ["StarTowerAwardItem"] = 'game.startower.view.star_tower_award_item'
	, ["StarTowerMainWindow"] = 'game.startower.view.star_tower_main_window'
	, ["StarTowerVideoWindow"] = 'game.startower.view.star_tower_video_window'
	, ["StarTowerResultWindow"] = 'game.startower.view.star_tower_result_window'
	, ["StarTowerGetWindow"] = 'game.startower.view.star_tower_get_window'
	, ["StarTowerList"] = 'game.startower.view.star_tower_list'
	, ["StarTowerTipsWindow"] = 'game.startower.view.star_tower_tips_window'
	
	--竖版星命占卜
	, ["AuguryWindow"] = 'game.augury.view.augury_window'
	, ["AuguryAlertWindow"] = 'game.augury.view.augury_alert_window'
	, ["AuguryGetWindow"] = 'game.augury.view.augury_get_window'

	--竖版伙伴(新)hero --by lwc
	, ['HeroBagWindow'] = 'game.hero.view.hero_bag_window'
	, ['SkillViewItem'] = 'game.hero.view.skill_view_item'
	, ['HeroMainInfoWindow'] = 'game.hero.view.hero_main_info_window'
	, ['HeroLookDrawWindow'] = 'game.hero.view.hero_look_draw_window'
	, ['HeroDrawMainWindow'] = 'game.hero.view.hero_draw_main_window'
	, ['HeroDrawMainTabFiles'] = 'game.hero.view.hero_draw_main_tab_files'
	, ['HeroDrawMainTabDraw'] = 'game.hero.view.hero_draw_main_tab_draw'
	, ['HeroLibraryStoryPanel'] = 'game.hero.view.hero_library_story_panel'
	, ['HeroLibraryMainWindow'] = 'game.hero.view.hero_library_main_window'
	, ['HeroLibraryInfoWindow'] = 'game.hero.view.hero_library_info_window'
	, ['HeroMainTabTrainPanel'] = 'game.hero.view.hero_main_tab_train_panel'
	, ['HeroMainTabTalentPanel'] = 'game.hero.view.hero_main_tab_talent_panel'
	, ['HeroMainTabEquipPanel'] = 'game.hero.view.hero_main_tab_equip_panel'
	, ['HeroMainTabHolyequipmentPanel'] = 'game.hero.view.hero_main_tab_holyequipment_panel'
	, ['HeroMainTabUpgradeStarPanel'] = 'game.hero.view.hero_main_tab_upgrade_star_panel'
	, ['HeroTalentSkillLearnPanel'] = 'game.hero.view.hero_talent_skill_learn_panel'
	, ['HeroTalentSkillLevelUpPanel'] = 'game.hero.view.hero_talent_skill_level_up_panel'
	, ['HeroExhibitionItem'] = 'game.hero.view.hero_exhibition_item'
	, ['HeroBreakExhibitionWindow'] = 'game.hero.view.hero_break_exhibition_window'
	, ['HeroBreakPanel'] = 'game.hero.view.hero_break_panel'
	, ['HeroUpgradeStarFusePanel'] = 'game.hero.view.hero_upgrade_star_fuse_panel'
	, ['HeroUpgradeStarSelectPanel'] = 'game.hero.view.hero_upgrade_star_select_panel'
	, ['HeroUpgradeStarTipsPanel'] = 'game.hero.view.hero_upgrade_star_tips_panel'
	, ['HeroUpgradeStarUpPanel'] = 'game.hero.view.hero_upgrade_star_up_panel'
	, ['HeroUpgradeStarExhibitionPanel'] = 'game.hero.view.hero_upgrade_star_exhibition_panel'
	, ['HeroUpgradeStarorderExhibition'] = 'game.hero.view.hero_upgrade_starorder_exhibition'
	, ['HeroTipsPanel'] = 'game.hero.view.hero_tips_panel'
	, ['HeroTipsAttrPanel'] = 'game.hero.view.hero_tips_attr_panel'
	, ['HeroResetWindow'] = 'game.hero.view.hero_reset_window'
	, ['HeroSelectHeroPanel'] = 'game.hero.view.hero_select_hero_panel'
	, ['HeroResonateWindow'] = 'game.hero.view.hero_resonate_window'
	, ['HeroResonateTabStoneTabletPanel'] = 'game.hero.view.hero_resonate_tab_stone_tablet_panel'
	, ['HeroResonateTabEmpowermentPanel'] = 'game.hero.view.hero_resonate_tab_empowerment_panel'
	, ['HeroResonateTabResonatePanel'] = 'game.hero.view.hero_resonate_tab_resonate_panel'
	, ['HeroResonateSelectExpPanel'] = 'game.hero.view.hero_resonate_select_exp_panel'
	, ['HeroResonateSelectTalentSkillPanel'] = 'game.hero.view.hero_resonate_select_talent_skill_panel'
	, ['HeroResonateExtractPanel'] = 'game.hero.view.hero_resonate_extract_panel'
	, ['HeroResonatePutDownPanel'] = 'game.hero.view.hero_resonate_put_down_panel'
	, ['HeroResonatePutResultPanel'] = 'game.hero.view.hero_resonate_put_result_panel'
	, ['HeroResonateComfirmLevPanel'] = 'game.hero.view.hero_resonate_comfirm_lev_panel'

	, ['HeroResetComfirmPanel'] = 'game.hero.view.hero_reset_comfirm_panel'
	, ['HeroResetReturnPanel'] = 'game.hero.view.hero_reset_return_panel'
	, ['HeroResetOfferPanel'] = 'game.hero.view.hero_reset_offer_panel'
 	, ['HeroSharePanel'] = 'game.hero.view.hero_share_panel'
 	, ['HeroSkinWindow'] = 'game.hero.view.hero_skin_window'
	, ['HeroSkinTipsPanel'] = 'game.hero.view.hero_skin_tips_panel'
	, ['HeroResetPanel'] = 'game.hero.view.hero_reset_panel'
	, ['HeroChipsBreakWindow'] = 'game.hero.view.hero_chips_break_window'
	, ['HeroSacrificePanel'] = 'game.hero.view.hero_sacrifice_panel'
	--技能 --by lwc
	, ['SkillUnlockWindow'] = 'game.hero.view.skill.skill_unlock_window'
	, ['SkillItem'] = 'game.hero.view.skill.skill_item'
	--布阵 --by lwc
	, ['FormFilterHeroPanel'] = 'game.hero.view.form.form_filter_hero_panel'
	, ['FormGoFightPanel'] = 'game.hero.view.form.form_go_fight_panel'
	, ['FormationSelectPanel'] = 'game.hero.view.form.formation_select_panel'
	, ['FormHallowsSelectPanel'] = 'game.hero.view.form.form_hallows_select_panel'
	--装备
	, ['EquipClothWindow'] = 'game.hero.view.equip.equip_cloth_window'
	, ['EquipTips'] = 'game.hero.view.equip.equip_tips'
	--神装
	, ['HolyequipmentRefreshAttPanel'] = 'game.hero.view.holyequipment.holyequipment_refresh_att_panel'
	, ['HolyequipmentTotalAttrPanel'] = 'game.hero.view.holyequipment.holyequipment_total_attr_panel'
	, ['HeroClothesLustratWindow'] = 'game.hero.view.holyequipment.hero_clothes_lustrat_window'
	, ['HolyequipmentPlanPanel'] = 'game.hero.view.holyequipment.holyequipment_plan_panel'
	, ['HolyequipmentSaveTips'] = 'game.hero.view.holyequipment.holyequipment_save_tips'
	, ['HolyequipmentWearTips'] = 'game.hero.view.holyequipment.holyequipment_wear_tips'
	, ['HolyequipmentChooseTips'] = 'game.hero.view.holyequipment.holyequipment_choose_tips'
	, ['HeroHolyEquipClothPanel'] = 'game.hero.view.holyequipment.hero_holy_equip_cloth_panel'

	--萌宠功能
	, ['HomePetTravellingBagPanel'] = 'game.homepet.view.home_pet_travelling_bag_panel'
	, ['HomePetItemBagPanel'] = 'game.homepet.view.home_pet_item_bag_panel'
	, ['HomePetItemSellPanel'] = 'game.homepet.view.home_pet_item_sell_panel'
	, ['HomePetGoBackPanel'] = 'game.homepet.view.home_pet_go_back_panel'
	, ['HomePetGooutProgressPanel'] = 'game.homepet.view.home_pet_goout_progress_panel'
	, ['HomePetBaseInfoPanel'] = 'game.homepet.view.home_pet_base_info_panel'
	, ['HomePetOnWayEventPanel'] = 'game.homepet.view.home_pet_on_way_event_panel'
	, ['HomePetEventInfoPanel'] = 'game.homepet.view.home_pet_event_info_panel'
	, ['HomePetCollectionPanel'] = 'game.homepet.view.home_pet_collection_panel'
	, ['HomePetTreasureInfoPanel'] = 'game.homepet.view.home_pet_treasure_info_panel'
	, ['HomePetRewardPanel'] = 'game.homepet.view.home_pet_reward_panel'
	, ['HomePetInteractionTipsPanel'] = 'game.homepet.view.home_pet_interaction_tips_panel'
	
	--精英赛
	, ['ElitematchMainWindow'] = 'game.elitematch.view.elitematch_main_window'
	, ['ElitematchMatchingWindow'] = 'game.elitematch.view.elitematch_matching_window'
	, ['ElitematchFightResultPanel'] = 'game.elitematch.view.elitematch_fight_result_panel'
	, ['ElitematchRewardPanel'] = 'game.elitematch.view.elitematch_reward_panel'
	, ['ElitematchFightRecordPanel'] = 'game.elitematch.view.elitematch_fight_record_panel'
	, ['ElitematchFightRecordItem'] = 'game.elitematch.view.elitematch_fight_record_item'
	, ['ElitematchFightVedioPanel'] = 'game.elitematch.view.elitematch_fight_vedio_panel'
	, ['ElitematchHistoryRecordWindow'] = 'game.elitematch.view.elitematch_history_record_window'
	, ['ElitematchPersonalInfoPanel'] = 'game.elitematch.view.elitematch_personal_info_panel'
	, ['ElitematchDeclarationPanel'] = 'game.elitematch.view.elitematch_declaration_panel'
	, ['ChooseFacePanel'] = 'game.elitematch.view.choose_face_panel'
	, ['ElitematchZoneListPanel'] = 'game.elitematch.view.elitematch_zone_list_panel'
	, ['ElitematchOrderactionWindow'] = 'game.elitematch.view.elitematch_orderaction_window'
	, ['ElitematchOrderactionUntieRewardWindow'] = 'game.elitematch.view.elitematch_orderaction_untie_reward_window'
	, ['ElitematchOrderActionEndWarnWindow'] = 'game.elitematch.view.elitematch_orderaction_end_warn_window'
	
	
	--竖版神器
	, ['ArtifactWindow'] = 'game.hero.view.artifact.artifact_window'
	, ['ArtifactListWindow'] = 'game.hero.view.artifact.artifact_list_window'
	, ['ArtifactListItem'] = 'game.hero.view.artifact.artifact_list_item'
	, ['ArtifactTipsWindow'] = 'game.hero.view.artifact.artifact_tips_window'
	, ['ArtifactMessagePanel'] = 'game.hero.view.artifact.artifact_message_panel'
	, ['ArtifactComposePanel'] = 'game.hero.view.artifact.artifact_compose_panel'
	, ['ArtifactRecastPanel'] = 'game.hero.view.artifact.artifact_recast_panel'
	, ['ArtifactChoseWindow'] = 'game.hero.view.artifact.artifact_chose_window'
	, ['ArtifactComTipsWindow'] = 'game.hero.view.artifact.artifact_com_tips_window'
	, ['ArtifactRecastWindow'] = 'game.hero.view.artifact.artifact_secast_window'
	, ['ArtifactRecastCostPanel'] = 'game.hero.view.artifact.artifact_recast_cost_panel'
	
	--竖版好友
	, ['FriendWindow'] = 'game.friend.view.friend_window'
	, ['FriendListPanel'] = 'game.friend.view.friend_list_panel'
	, ['FriendApplyPanel'] = 'game.friend.view.friend_apply_panel'
	, ['FriendAwardPanel'] = 'game.friend.view.friend_award_panel'
	, ['FriendBlackPanel'] = 'game.friend.view.friend_black_panel'
	, ['FriendListItem'] = 'game.friend.view.friend_list_item'
	, ['FriendAddWindow'] = 'game.friend.view.friend_add_window'
	, ["FriendCheckInfoWindow"] = 'game.friend.view.friend_check_info_window'
	, ["FriendGloryWindow"] = "game.friend.view.friend_glory_window"
	
	--战斗模块
	, ["BattleRole"] = 'game.battle.new_view.battle_role'
	, ["BattleHookRole"] = 'game.battle.new_view.battle_hook_role'
	, ["BattleBuffTips"] = 'game.battle.new_view.battle_buff_tips'
	, ["BattleSkillTips"] = 'game.battle.new_view.battle_skill_tips'
	, ["BattleTacticalSTips"] = 'game.battle.new_view.battle_tactical_tips'
	, ["BattleSceneNewView"] = 'game.battle.new_view.battle_scene_view'
	, ["BattleFailView"] = 'game.battle.new_view.battle_fail_view'
	, ["BattleResultView"] = 'game.battle.new_view.battle_result_view'
	, ["BattlePkResultView"] = 'game.battle.new_view.battle_pk_result_view'
	, ["BattleMvpView"] = 'game.battle.new_view.battle_mvp_view'
	, ["BattleCampView"] = 'game.battle.new_view.battle_camp_view'
	, ["BattleHarmInfoView"] = 'game.battle.new_view.battle_harm_info_view'
	, ["BattleBuffInfoView"] = 'game.battle.new_view.battle_buff_info_view'
	, ["BattleBuffListView"] = 'game.battle.new_view.battle_buff_list_view'
	, ["BattleResultShowInfoWindow"] = 'game.battle.new_view.battle_result_showinfo_window'

	--战斗剧情副本
	, ["BttleTopDramaView"] = 'game.battle_drama.view.battle_drama_top_view'
	, ["BattleDramaMainPointItem"] = 'game.battle_drama.view.battle_drama_main_point_item'
	, ["BattlDramaBossInfoWindow"] = 'game.battle_drama.view.battle_drama_boos_info_window'
	, ["BattlDramaQuickBattleWindow"] = 'game.battle_drama.view.battle_drama_quick_battle_window'
	, ["BattlDramaSwapWindow"] = 'game.battle_drama.view.battle_drama_swap_view'
	, ["BattlDramaSwapRewardWindow"] = 'game.battle_drama.view.battle_drama_swap_reward_view'
	, ["BattlDramaHookRewardWindow"] = 'game.battle_drama.view.battle_drama_hook_reward_window'
	, ["BattlDramaDropTipsWindow"] = 'game.battle_drama.view.battle_drama_drop_tips_windows'
	, ["BattleDramaWorldWindows"] = 'game.battle_drama.view.battle_drama_world_windows'
	, ["BattleDramaRewardWindow"] = 'game.battle_drama.view.battle_drama_reward_view'
	, ["BattleDramaUnlockWindow"] = 'game.battle_drama.view.battle_drama_unlock_window'
	, ["BattleDramaUnlockChapterView"] = 'game.battle_drama.view.battle_drama_unlock_chapter_view'
	, ["BattleDramaQingBaoTipsView"] = 'game.battle_drama.view.battle_drama_qingbao_tips_view'
	, ["BattleDramaDropItem"] = 'game.battle_drama.view.battle_drama_drop_item'
	, ["BattleDramaFuncItem"] = 'game.battle_drama.view.battle_drama_func_item'
	, ["BattlDramafuncWindow"] = 'game.battle_drama.view.battle_drama_func_windows'
	, ["BattlDramaDropWindow"] = 'game.battle_drama.view.battle_drama_drop_windows'
	, ["BattleDramaDropBossTipsWindow"] = 'game.battle_drama.view.battle_drama_drop_boss_tips_windows'
	, ["BattleDramaDropSecBossItem"] = 'game.battle_drama.view.battle_drama_drop_boss_tips_windows'
	, ["BattleDramaDropSecBossItem"] = 'game.battle_drama.view.battle_drama_drop_sec_boss_item'
	, ["BattleDramaAutoCombatWindow"] = 'game.battle_drama.view.battle_drama_auto_combat_windows'
	, ["BattleDramaWorldLevTips"] = 'game.battle_drama.view.battle_drama_world_lev_tips' 
	, ["BattlDramaPassVedioView"] = 'game.battle_drama.view.battle_drama_vedio_view'
	, ["BattleDramaMapWindows"] = 'game.battle_drama.view.battle_drama_map_windows'

	-- 新的主场景
	, ["CenterCityScene"] = "game.scene.view.center_city_scene"
	, ["BuildItem"] = "game.scene.element.build_item"

	-- 区场景（商业区）
	, ["AreaSceneWindow"] = "game.area_scene.view.area_scene_window"
	, ["AreaBuildItem"] = "game.area_scene.view.area_build_item"

	--小图标提示
	, ["PromptVo"]= 'game.prompt.prompt_vo'

	--背包模块	
	, ["BackPackWindow"] = 'game.backpack.view.backpack_window'
	, ["BackPackItem"] = 'game.backpack.view.backpack_item'
	, ["RoundItem"] = 'game.backpack.view.round_item'
	, ["BackPackSellWindow"] = 'game.backpack.view.backpack_sell_window'
	, ["BackPackComposeWindow"] = 'game.backpack.view.backpack_compose_window'
	, ["BackPackEquipInterceptWindow"] = 'game.backpack.view.backpack_equip_intercept_window'
	, ["BackPackSellHolyWindow"] = 'game.backpack.view.backpack_sell_holy_window'
	, ["BackPackSellEquipWindow"] = 'game.backpack.view.backpack_sell_equip_window'
	, ["BackPackSellConfirmWindow"] = 'game.backpack.view.backpack_sell_confirm_window'
	
	, ["BackPackBatchView"] = 'game.backpack.view.backpack_batchuse_view'
	, ["GiftSelectPanel"] = 'game.backpack.view.gift_select_panel'
	, ["ItemSellPanel"] = 'game.backpack.view.item_sell_panel'
	
	--tips模块
	, ["SkillTips"] = 'game.tips.view.skill_tips'
	, ["HalidomSkillTips"] = 'game.tips.view.halidom_skill_tips'
	, ["ElfinTipsWindow"] = 'game.tips.view.elfin_tips'
	
	, ["MonTips"]	= 'game.tips.view.mon_tips'
	, ["GoodsBaseTips"] = 'game.tips.view.goods_base_tips'
	, ["GoodsTips"] = 'game.tips.view.goods_tips'
	, ["ShareTips"] = 'game.tips.view.tips_share'
	, ["CommonTips"] = 'game.tips.view.common_tips'
	, ["AdventureBuffTips"] = 'game.tips.view.adventure_buff_tips'
	, ["BackpackTips"] = 'game.tips.view.backpack_tips'
	, ["BackpackCompTips"] = 'game.tips.view.backpack_comp_tips'
	, ["CompChooseTips"] = 'game.tips.view.comp_choose_tips'
	, ["SourceItem"] = 'game.tips.view.source_item'
	, ["TipsSource"] = 'game.tips.view.tips_source'
	, ["TipsOnlySource"] = 'game.tips.view.tips_only_source'
	, ["WeekCardTips"] = 'game.tips.view.week_card_tips'
	--荣誉墙的tips --by lwc	
	, ["HonorIconTips"] = 'game.tips.view.honor_icon_tips' --荣誉icontips
	, ["HonorLevelTips"] = 'game.tips.view.honor_level_tips' --荣誉等级tips
	, ["HonorNextLevelTips"] = 'game.tips.view.honor_next_level_tips' --荣誉等级tips
	, ["TaskExpTips"] = 'game.tips.view.task_exp_tips' --荣誉对应历练任务tips
	--通用角色下来菜单列表
	, ["CommonOptionsList"] = "common.common_options_list"
	, ["CommonNum"] = "common.common_num"

	-- 通用二级菜单按钮列表
	, ["CommonSubBtnList"] = "common.common_sub_btn_list"

	-- 引导
	, ["GuideMainView"] = 'game.guide.view.guide_main_view'
	
	-- 弹幕
	, ["BarrageMainView"] = 'game.barrage.view.barrage_main_view'
	, ["BarrageItemList"] = 'game.barrage.view.barrage_item_list'
	, ["BarrageEditView"] = 'game.barrage.view.barrage_edit_view'

	--角色
	, ["RoleAttrView"] = 'game.role.view.role_attr_view'
	, ["RoleSkillView"] = 'game.role.view.role_skill_view'
	, ["RoleFacePanel"] = 'game.role.view.role_face_panel'
	, ["RoleFaceItem"] = 'game.role.view.role_face_panel'
	, ["RoleHeadPanel"] = 'game.role.view.role_head_panel'
	, ["RoleChangeView"] = 'game.role.view.role_change_view'
	, ["RoleDecorateTabBodyPanel"] = 'game.role.view.role_decorate_tab_body_panel'
	, ["RoleBackgroundPanel"] = 'game.role.view.role_background_panel'
	-- , ["RoleSetWindow"] = 'game.role.view.role_set_window' --废弃
	, ["RoleDecorateWindow"] = 'game.role.view.role_decorate_window'
	, ["RoleTitlePanel"] = 'game.role.view.role_title_panel'
	, ["RoleFaceTips"] = 'game.role.view.role_face_tips'
	, ["RoleSetNameView"] = 'game.role.view.role_setname_view'
	, ["RoleUpgradeMainWindow"] = 'game.role.view.role_upgrade_main_window'
	, ["RoleAttestationWindow"] = 'game.role.view.role_attestation_window'
	, ["RoleReportedPanel"] = 'game.role.view.role_reported_panel'
	, ["RolePhotoChooseWindow"] = 'game.role.view.role_photo_choose_window'
	--个人空间 --by lwc
	, ["RolePersonalSpacePanel"] = 'game.role.view.role_personal_space_panel'
	, ["RolePersonalSpaceTabInfoPanel"] = 'game.role.view.role_personal_space_tab_info_panel'
	, ["RolePersonalSpaceTabHonorWallPanel"] = 'game.role.view.role_personal_space_tab_honor_wall_panel'
	, ["RolePersonalSpaceTabGrowthWayPanel"] = 'game.role.view.role_personal_space_tab_growth_way_panel'
	, ["RolePersonalSpaceTabMessageBoardPanel"] = 'game.role.view.role_personal_space_tab_message_board_panel'
	, ["RoleMessageBoardReplyPanel"] = 'game.role.view.role_message_board_reply_panel'
	, ["RoleHeroShowFormPanel"] = 'game.role.view.role_hero_show_form_panel'
	, ["RoleSystemSetPanel"] = 'game.role.view.role_system_set_panel'
	, ["RoleSelectHonorListPanel"] = 'game.role.view.role_select_honor_list_panel'
	, ["RoleSelectHonorListPanel"] = 'game.role.view.role_select_honor_list_panel'
	, ['RoleHonorItem'] = 'game.role.view.role_honor_item'
	, ['RoleHonorUnlockPanel'] = 'game.role.view.role_honor_unlock_panel'
	, ['RoleAchieveWindow'] = 'game.role.view.role_achieve_window'

	-- 通用的滑动面板
	, ["CustomScrollView"] = 'common.custom_scroll_view'

	--竖版排行榜
	, ["RankWindow"] = 'game.rank.view.rank_window'
	, ["RankItem"] = 'game.rank.view.rank_item'
	--排行榜奖励
	, ["RankRewardPanel"] = 'game.rank.view.rank_reward_panel'
	, ["RankMainWindow"] = 'game.rank.view.rank_main_window'
	, ["RankMainItem"] = 'game.rank.view.rank_main_item'
	, ["SingleRankMainWindow"] = 'game.rank.view.single_rank_main_window'
	, ["SingleAwardPanel"] = 'game.rank.view.single_award_panel'
	, ["SingleRankPanel"] = 'game.rank.view.single_rank_panel'

	--商城模块
	, ["MallWindow"] = 'game.mall.view.mall_window'
	, ["MallWindow2"] = 'game.mall.view.mall_window_2'
	, ["MallItem"] = 'game.mall.view.mall_item'
	, ["MallBuyWindow"] = 'game.mall.view.mall_buy_window'
	, ["MallSonPanel"] = 'game.mall.view.mall_son_panel'
	, ["MallActionWindow"] = 'game.mall.view.mall_action_window'
	, ["MallItem2"] = 'game.mall.view.mall_item_2'
	, ["MallSingleShopPanel"] = 'game.mall.view.mall_single_shop_panel'

	-- 精灵商店
	, ["VarietyStoreWindows"] = 'game.mall.view.variety_store_windows'
	-- 皮肤商店
	, ["SkinShopWindow"] = 'game.mall.view.skin_shop_window'
	-- 圣羽商店
	, ["PlumeShopWindow"] = 'game.mall.view.plume_shop_window'
	-- 积分商店
	, ["ScoreShopWindow"] = 'game.mall.view.score_shop_window'
	, ["ScoreShopItem"] = 'game.mall.view.score_shop_item'
	, ["ChargeSureWindow"] = 'game.mall.view.charge_sure_window'
	-- 充值商店
	, ["ChargeShopWindow"] = 'game.mall.view.charge_shop_window'
	, ["ChargeDiamondPanel"] = 'game.mall.view.charge_diamond_panel'
	, ["ChargeValuePanel"] = 'game.mall.view.charge_value_panel'
	, ["ChargePrivilegePanel"] = 'game.mall.view.charge_privilege_panel'
	, ["ChargeDialyPanel"] = 'game.mall.view.charge_dialy_panel'
	, ["ChargeWeeklyPanel"] = 'game.mall.view.charge_weekly_panel'
	, ["ChargeMonthlyPanel"] = 'game.mall.view.charge_monthly_panel'
	, ["ChargeTimePanel"] = 'game.mall.view.charge_time_panel'
	, ["ChargeClothPanel"] = 'game.mall.view.charge_cloth_panel'

	-- 竞技场
	, ["ArenaLoopChallengeVo"] = 'game.arena.arena_loop_challenge_vo'
	, ["ArenaEnterWindow"] = 'game.arena.view.arena_enter_window'
	, ["ArenaLoopMatchWindow"] = 'game.arena.view.loop.arena_loop_match_window'
	, ["ArenaLoopChallengePanel"] = 'game.arena.view.loop.arena_loop_challenge_panel'
	, ["ArenaLoopActivityPanel"] = 'game.arena.view.loop.arena_loop_activity_panel'
	, ["ArenaLoopRankPanel"] = 'game.arena.view.loop.arena_loop_rank_panel'
	, ["ArenaLoopAwardsPanel"] = 'game.arena.view.loop.arena_loop_awards_panel'
	, ["ArenaLoopChallengeCheckWindow"] = 'game.arena.view.loop.arena_loop_challenge_check_window'
	, ["ArenaEnterLoopView"] = 'game.arena.view.arena_enter_loop_view'
	, ["ArenaEnterChampionView"] = 'game.arena.view.arena_enter_champion_view'
	, ["ArenaLoopChallengeBuffWindow"] = 'game.arena.view.loop.arena_loop_challenge_buff_window'
	, ["ArenaLoopResultWindow"] = 'game.arena.view.loop.arena_loop_result_window'
	, ["ArenaLoopMyLogWindow"] = 'game.arena.view.loop.arena_loop_my_log_window'
	, ["ArenaLoopChallengeBuy"] = 'game.arena.view.loop.arena_loop_challenge_buy'

	--组队竞技场 --by lwc
	, ["ArenateamMainWindow"] = 'game.arenateam.view.arenateam_main_window'
	, ["ArenateamMainItem"] = 'game.arenateam.view.arenateam_main_window'
	, ["ArenateamCreateTeamPanel"] = 'game.arenateam.view.arenateam_create_team_panel'
	, ["ArenateamHallPanel"] = 'game.arenateam.view.arenateam_hall_panel'
	, ["ArenateamHallTapTeamPanel"] = 'game.arenateam.view.arenateam_hall_tap_team_panel'
	, ["ArenateamHallTapTeamItem"] = 'game.arenateam.view.arenateam_hall_tap_team_panel'
	, ["ArenateamHallTapInvitationPanel"] = 'game.arenateam.view.arenateam_hall_tap_invitation_panel'
	, ["ArenateamHallTapInvitationItem"] = 'game.arenateam.view.arenateam_hall_tap_invitation_panel'
	, ["ArenateamHallTapMyTeamPanel"] = 'game.arenateam.view.arenateam_hall_tap_my_team_panel'
	, ["ArenateamChangTeamNamePanel"] = 'game.arenateam.view.arenateam_chang_team_name_panel'
	, ["ArenateamTeamSetPanel"] = 'game.arenateam.view.arenateam_team_set_panel'
	, ["ArenateamDeletePlayerPanel"] = 'game.arenateam.view.arenateam_delete_player_panel'
	, ["ArenateamAddPlayerPanel"] = 'game.arenateam.view.arenateam_add_player_panel'
	, ["ArenateamFormPanel"] = 'game.arenateam.view.arenateam_form_panel'
	, ["ArenateamFightTips"] = 'game.arenateam.view.arenateam_fight_tips'
	, ["ArenateamFightListPanel"] = 'game.arenateam.view.arenateam_fight_list_panel'
	, ["ArenateamFightListItem"] = 'game.arenateam.view.arenateam_fight_list_panel'
	, ["ArenateamFightResultPanel"] = 'game.arenateam.view.arenateam_fight_result_panel'
	, ["ArenateamFightRecordItem"] = 'game.arenateam.view.arenateam_fight_record_panel'
	, ["ArenateamFightRecordPanel"] = 'game.arenateam.view.arenateam_fight_record_panel'
	, ["ArenateamFightVedioItem"] = 'game.arenateam.view.arenateam_fight_vedio_panel'
	, ["ArenateamFightVedioPanel"] = 'game.arenateam.view.arenateam_fight_vedio_panel'
	, ["ArenateamBoxRewardPanel"] = 'game.arenateam.view.arenateam_box_reward_panel'
	, ["ArenateamBoxRewardItem"] = 'game.arenateam.view.arenateam_box_reward_panel'
	, ["ArenateamRankRewardPanel"] = 'game.arenateam.view.arenateam_rank_reward_panel'
	, ["ArenateamChatPanel"] = 'game.arenateam.view.arenateam_chat_panel'

	-- 冠军赛
	, ["ArenaChampionRankWindow"] = 'game.arena.view.champion.arena_champion_rank_window'
	, ["ArenaChampionMatchWindow"] = 'game.arena.view.champion.arena_champion_match_window'
	, ["ArenaChampionGuessWindow"] = 'game.arena.view.champion.arena_champion_guess_window' 
	, ["ArenaChampionRankAwardsWindow"] = 'game.arena.view.champion.arena_champion_rank_awards_window'
	, ["ArenaChampionMyGuessWindow"] = 'game.arena.view.champion.arena_champion_my_guess_window'
	, ["ArenaChampionBestInfoWindow"] = 'game.arena.view.champion.arena_champion_best_info_window'
	, ["ArenaChampionMyMatchReadyPanel"] = 'game.arena.view.champion.arena_champion_my_match_ready_panel'
	, ["ArenaChampionMyMatchPanel"] = 'game.arena.view.champion.arena_champion_my_match_panel'
	, ["ArenaChampionCurGuessPanel"] = 'game.arena.view.champion.arena_champion_cur_guess_panel'
	, ["ArenaChampionTop32Panel"] = 'game.arena.view.champion.arena_champion_top_32_panel'
	, ["ArenaChampionTop321View"] = 'game.arena.view.champion.arena_champion_top_32_1_view'
	, ["ArenaChampionTop322View"] = 'game.arena.view.champion.arena_champion_top_32_2_view'
	, ["ArenaChampionTop8View"] = 'game.arena.view.champion.arena_champion_top_8_view'
	, ["ArenaChampionCheckFightInfoView"] = 'game.arena.view.champion.arena_champion_check_fight_info_view'
	, ["ArenaChampionReportWindow"] = 'game.arena.view.champion.arena_champion_report_window'
	, ["ArenaChampionCurRankPanel"] = 'game.arena.view.champion.arena_champion_cur_rank_panel'
	, ["ArenaChampionInfoVo"] = 'game.arena.arena_champion_info_vo' 
	, ["ArenaChampionMyLogWindow"] = 'game.arena.view.champion.arena_champion_my_log_window'
	, ["ArenaChampionTop3Window"] = 'game.arena.view.champion.arena_champion_top_3_window'

	
	-- 多人竞技场
	, ['ArenaManyPeopleMainWindow'] = 'game.arenamanypeople.view.arenamanypeople_main_window'
	, ['ArenaManyPeopleBoxRewardPanel'] = 'game.arenamanypeople.view.arenamanypeople_box_reward_panel'
	, ['ArenaManyPeopleFightRecordPanel'] = 'game.arenamanypeople.view.arenamanypeople_fight_record_panel'
	, ['ArenaManyPeopleFightResultPanel'] = 'game.arenamanypeople.view.arenamanypeople_fight_result_panel'
	, ['ArenaManyPeopleRankWindow'] = 'game.arenamanypeople.view.arenamanypeople_rank_window'
	, ['ArenaManyPeopleAwardsPanel'] = 'game.arenamanypeople.view.arenamanypeople_awards_panel'
	, ['ArenaManyPeopleRankPanel'] = 'game.arenamanypeople.view.arenamanypeople_rank_panel'
	, ['ArenaManyPeopleHallPanel'] = 'game.arenamanypeople.view.arenamanypeople_hall_panel'
	, ['ArenaManyPeopleHallTeamPanel'] = 'game.arenamanypeople.view.arenamanypeople_hall_team_panel'
	, ['ArenaManyPeopleHallInvitationPanel'] = 'game.arenamanypeople.view.arenamanypeople_hall_invitation_panel'
	, ['ArenaManyPeopleFightTips'] = 'game.arenamanypeople.view.arenamanypeople_fight_tips'
	, ['ArenaManyPeopleMatchingWindow'] = 'game.arenamanypeople.view.arenamanypeople_matching_window'
	, ['ArenaManyPeopleFightVedioPanel'] = 'game.arenamanypeople.view.arenamanypeople_fight_vedio_panel'

	--新的竖版召唤
	, ["PartnerSummonItem"] = 'game.partnersummon.view.partnersummon_item'
	, ["PartnerSummonGoods"] = 'game.partnersummon.view.partnersummon_goods'
	, ["PartnerSummonWindow"] = 'game.partnersummon.view.partnersummon_window'
	--, ["PartnerSummonPreviewView"] = 'game.partnersummon.view.partnersummon_preview_view'
	, ["PartnerSummonGainWindow"] = 'game.partnersummon.view.partnersummon_gain_window'
	, ["PartnerSummonGainShowWindow"] = 'game.partnersummon.view.partnersummon_gain_show_window'
	, ["PartnerSummonGodView"] = 'game.partnersummon.view.partnersummon_god_view'
	, ["PartnerSummonScoreWindow"] = 'game.partnersummon.view.partnersummon_score_window'

	--vip
	, ["VipMainWindow"] = 'game.vip.view.vip_main_window'
	, ["VipPanel"] = 'game.vip.view.vip_panel'
	, ["ChargePanel"] = 'game.vip.view.charge_panel'
	, ["AccChargePanel"] = 'game.vip.view.acc_charge_panel'
	, ["VipMainTabBtn"] = 'game.vip.view.vip_main_tab'
	, ["DailyGiftPanel"] = 'game.vip.view.daily_gift_panel'
	, ["PrivilegePanel"] = 'game.vip.view.privilege_panel'

	--神界探险
	-- , ["AdventureScene"] = 'game.adventure.view.adventure_scene'
	-- , ["AdventurePlayer"] = 'game.adventure.adventure_player'
	-- , ["AdventureNpc"] = 'game.adventure.adventure_npc'
	-- , ["AdventureSceneVo"] = 'game.adventure.adventure_vo'
	-- , ["AdventureUIView"] = 'game.adventure.view.adventure_ui_view'
	-- , ["AdventureMiniMapItem"] = 'game.adventure.view.adventure_mini_map_item'
	-- , ["AdventureBigMapItem"] = 'game.adventure.view.adventure_big_map_item'
	-- , ["AdventureSwapWindow"] = 'game.adventure.view.adventure_swap_view'
	-- , ["AdventureSwapReWardWindow"] = 'game.adventure.view.adventure_swap_reward_view'
	-- , ["AdventureBackPackWindow"] = 'game.adventure.view.adventure_backpack_view'
	-- , ["AdventureBigMapWindow"] = 'game.adventure.view.adventure_big_map_window'
	-- , ["AdventurefloorSkipWindow"] = 'game.adventure.view.adventure_floor_skip_window'
	-- , ["AdventurefloorSkipItem"] = 'game.adventure.view.adventure_floor_skip_window'
	-- , ["AdventurePlunderRecordItem"] = 'game.adventure.view.adventure_plunder_record_item'
	-- , ["AdventurePlunderRecordWindow"] = 'game.adventure.view.adventure_plunder_record_view'
	-- , ["AdventureBackPackTips"] = 'game.adventure.view.adventure_backpack_tips'
	-- , ["AdventurePlunderTips"] = 'game.adventure.view.adventure_plunder_tips'
	-- , ["AdventureRecordPlunderView"] = 'game.adventure.view.adventure_record_plunder_view'

	, ["AdventureMineFightResultPanel"] = 'game.adventure.evt_view.adventure_mine_fight_result_panel'
	, ["AdventureMineLayerPanel"] = 'game.adventure.evt_view.adventure_mine_layer_panel'
	, ["AdventureMineMyInfoPanel"] = 'game.adventure.evt_view.adventure_mine_my_info_panel'
	, ["AdventureMineFightRecordPanel"] = 'game.adventure.evt_view.adventure_mine_fight_record_panel'
	, ["AdventureMineFightPanel"] = 'game.adventure.evt_view.adventure_mine_fight_panel'
	, ["AdventureMineWindow"] = 'game.adventure.evt_view.adventure_mine_window'
	, ["AdventureMainWindow"] = 'game.adventure.evt_view.adventure_main_window'
	, ["AdventureEvtFreeBoxWindow"] = 'game.adventure.evt_view.adventure_evt_free_box_view'
	, ["AdventureEvtOtherNpcWindow"] = 'game.adventure.evt_view.adventure_evt_other_npc_view' 
	, ["AdventureEvtShopView"] = 'game.adventure.evt_view.adventure_evt_shop_view' 
	, ["AdventureEvtNpcView"] = 'game.adventure.evt_view.adventure_evt_npc_view'
	, ["AdventureEvtStartWindow"] = 'game.adventure.evt_view.adventure_evt_answer_start_view'
	, ["AdventureEvtBoxWindow"] = 'game.adventure.evt_view.adventure_evt_box_view'
	, ["AdventureEvtAnswerWindow"] = 'game.adventure.evt_view.adventure_evt_answer_view'
	, ["AdventureEvtFighterGuessWindow"] = 'game.adventure.evt_view.adventure_evt_fighterguess_view'
	, ["AdventureFloorResultWindow"] = 'game.adventure.evt_view.adventure_floor_result_window'
	, ["AdventureShopWindow"] = 'game.adventure.evt_view.adventure_shop_window'
	, ["AdventureEvtChallengeWindow"] = 'game.adventure.evt_view.adventure_evt_challenge_window'
	, ["AdventureShotKillWindow"] = 'game.adventure.evt_view.adventure_shot_kill_window'
	, ["AdventureFormWindow"] = 'game.adventure.evt_view.adventure_form_window'
	, ["AdventureUseHPWindow"] = 'game.adventure.evt_view.adventure_use_hp_window'
	, ["AdventureBoxRewardWindow"] = 'game.adventure.evt_view.adventure_box_reward_window'

	--市场
	, ["MarketMainWindow"] = 'game.market.view.market_main_window'
	, ["GoldMarketItem"] = 'game.market.view.gold_market_item'
	, ["MarketItem"] = 'game.market.view.market_item'
	, ["MarketBuyWindow"] = 'game.market.view.market_buy_window'
	, ["SliverSellItem"] = 'game.market.view.sliver_sell_item'
	, ["SliverGroundingWindow"] = 'game.market.view.sliver_grounding_window'
	, ["SliverSellWindow"] = 'game.market.view.sliver_sell_window'
	, ["SliverOneUpWindow"] = 'game.market.view.sliver_oneup_window'

	--金银币兑换
	, ["ExchangeWindow"] = 'game.exchange.view.exchange_window'

	--福利模块
	, ["WelfareMainWindow"] = 'game.welfare.view.welfare_main_window'
	, ["WelfareTab"] = 'game.welfare.view.welfare_tab'
	, ["WelfareSubTabVo"] = 'game.welfare.view.welfare_sub_tab_vo'
	, ["HeroSoulWishPanel"] = 'game.welfare.view.hero_soul_wish_panel'
	, ["SignPanel"] = 'game.welfare.view.sign_panel'
	, ["PowerWelfarePanel"] = 'game.welfare.view.power_welfare_panel'
	, ["SupreYuekaPanel"] = 'game.welfare.view.supre_yueka_panel'
	, ["HonorYuekaPanel"] = 'game.welfare.view.honor_yueka_panel'
	, ["WeiXinGiftPanel"] = 'game.welfare.view.weixin_gift_panel'
	, ["QRcodeShardPanel"] = 'game.welfare.view.qrcode_shard_panel'
	, ["SureveyQuestWindow"] = 'game.welfare.view.sureveyquest_window'
	, ["MonthWeekPanel"] = 'game.welfare.view.month_week_panel'
	, ["LuxuryWelfarePanel"] = 'game.welfare.view.luxury_panel'
	, ["SubscriptionWechatPanel"] = 'game.welfare.view.subscription_wechat_panel'
	, ["BindPhonePanel"] = 'game.welfare.view.bind_phone_panel'
	, ["CertifyBindPhoneWindow"] = 'game.welfare.view.certify_bind_phone_window'
	, ["StartWorkPanel"] = 'game.welfare.view.start_work_panel'
	, ["PastePanel"] = 'game.welfare.view.paste_panel'
	, ["ShopPanel"] = 'game.welfare.view.shop_panel'
	, ["YuekaPanel"] = 'game.welfare.view.yueka_panel'
	, ["SubscriptionPrivilegePanel"] = 'game.welfare.view.subscription_privilege_panel'
	--活动
	, ["ActionCommonRewardPanel"] = 'game.action.view.action_common_reward_panel' --通用显示奖励界面 --by lwc
	, ["ActionFirstChargeWindow"] = 'game.action.view.action_first_charge_window'
	, ["ActionSevenLoginWindow"] = 'game.action.view.action_seven_login_window'
	, ["ActionSevenRankWindow"] = 'game.action.view.action_seven_rank_window'
	, ["ActionMainWindow"] = 'game.action.view.action_main_window'
	, ["ActionLimitGiftMainWindow"] = 'game.action.view.action_limit_gift_main_window'
	, ["ActionSubTabVo"] = 'game.action.action_sub_tab_vo'
	, ["ActionInvestPanel"] = 'game.action.view.action_invest_panel'
	, ["ActionAccChargePanel"] = 'game.action.view.action_acc_charge_panel'
	, ["ActionGiftPanel"] = 'game.action.view.action_gift_panel'
	, ["ActionAccCostPanel"] = 'game.action.view.action_acc_cost_panel'
	, ["ActionAccCostItem"] = 'game.action.view.action_acc_cost_panel'
	, ["ActionLimitBuyPanel"] = 'game.action.view.action_limit_buy_panel'
	, ["ActionLimitBuyItem"] = 'game.action.view.action_limit_buy_panel'
	, ["ActionLimitBossPanel"] = 'game.action.view.action_limit_boss_panel'
	, ["ActionGrowFundPanel"] = 'game.action.view.action_grow_fund_panel'
	, ["ActionGodPartnerPanel"] = 'game.action.view.action_godpartner_panel'
	, ["ActionFestvalLoginWindow"] = 'game.action.view.action_festval_login_window'
	, ["ActionSevenGoalWindow"] = 'game.action.view.action_seven_goal_window'
	, ["ActionCrossServerRankWindow"] = "game.action.view.action_crossserver_rank_window"
	, ["ActionDirectBuygiftWindow"] = 'game.action.view.action_direct_buygift_window'
	, ["ActionTreasureWindow"] = 'game.action.view.action_treasure_window'
	, ["ActionPreferentialWindow"] = "game.action.view.action_preferential_window"
	, ["ActionTreasureGetWindow"] = "game.action.view.action_treasure_get_window"
	, ["ActionLimitGroupbuyPanel"] = 'game.action.view.action_limit_groupbuy_panel'
	, ["ActionCommonPanel"] = 'game.action.view.action_common_panel'
	, ["ActionLimitChangePanel"] = 'game.action.view.action_limit_change_panel'
	, ["ActionLimitCommonPanel"] = 'game.action.view.action_limit_common_panel'
	, ["ActionOpenServerGiftWindow"] = 'game.action.view.action_open_server_gift_window'
	, ["ActionHighValueGiftPanel"] = 'game.action.view.action_high_value_gift_panel'
	, ["ActionMysteriousStorePanel"] = 'game.action.view.action_mysterious_store_panel'
	, ["ActionHeroClothesPanel"] = 'game.action.view.action_hero_clothes_panel'
	, ["ActionBuySkinPanel"] = 'game.action.view.action_buy_skin_panel'
	, ["ActionSkinDirectPurchasePanel"] = 'game.action.view.action_skin_direct_purchase_panel'
	, ["ActionSevenChargePanel"] = 'game.action.view.action_seven_charge_panel'
	, ["ActionSkinLotteryPanel"] = 'game.action.view.action_skin_lottery_panel'
	, ["ActionSpecialVipWindow"] = 'game.action.view.action_special_vip_window'
	, ["ActionPerferPrizeWindow"] = 'game.action.view.action_perfer_prize_window'
	, ["ActionActivityNoticePanel"] = 'game.action.view.action_activity_notice_panel'
	, ["ActionCarnivalReportPanel"] = 'game.action.view.action_carnival_report_panel'
	, ["ActionResetChargeWindow"] = 'game.action.view.action_reset_charge_window'
	, ["ActionRechargeRebatePanel"] = 'game.action.view.action_recharge_rebate_panel'
	, ["ActionSpriteResetWindow"] = 'game.action.view.action_sprite_reset_window'
	, ["ActionSpriteResetSelectPanel"] = 'game.action.view.action_sprite_reset_select_panel'
	, ["ActionLuckyDogPanel"] = 'game.action.view.action_lucky_dog_panel'
	, ["ActionFortuneBagDrawPanel"] = 'game.action.view.action_fortune_bag_draw_panel'
	, ["ActionFortuneBagSelectWindow"] = 'game.action.view.action_fortune_bag_select_window'
    , ["ActionFortuneBagRuleWindow"] = 'game.action.view.action_fortune_bag_rule_window'
	, ["ActionTimeCollectWindow"] = 'game.action.view.action_time_collect_window'
	, ["ActionGrowGiftPanel"] = 'game.action.view.action_grow_gift_panel'
	, ["ActionEightLoginWindow"] = 'game.action.view.action_eight_login_window'
	, ["ActionWhiteDayPanel"] = 'game.action.view.action_white_day_panel'
	, ["ActivePushWindow"] = 'game.action.view.action_active_push_window'
	, ["ActionSuperValueWeeklyCardPanel"] = 'game.action.view.action_super_value_weekly_card_panel'
	, ["ActionNoviceGiftPanel"] = 'game.action.view.action_novice_gift_panel'
	
	--活动的限时试炼之境
	, ["LimitExercisePanel"] = 'game.limitexercise.view.limitexercise_panel'
	, ["LimitExerciseChangeWindow"] = 'game.limitexercise.view.limitexercise_change_window'
	, ["LimitExerciseRewardWindow"] = 'game.limitexercise.view.limitexercise_reward_window'

	--英雄重生
	, ["ActionHeroResetSelectPanel"] = 'game.action.view.action_hero_reset_select_panel'
	, ["ActionHeroResetPanel"] = 'game.action.view.action_hero_reset_panel'
	, ["ActionHeroSkinResetPanel"] = 'game.action.view.action_hero_skin_reset_panel'
	
	
	--小额礼包 --by lwc
	, ["ActionSmallAmountGiftPanel"] = 'game.action.view.action_small_amount_gift_panel'
	
	--元宵冒险 --by lwc
	, ["ActionLimitYuanZhenPanel"] = 'game.action.view.action_limit_yuanzhen_panel'
	, ["ActionLimitFullExchangePanel"] = 'game.action.view.action_limit_full_exchange_panel'
	, ["ActionHeroConvertPanel"] = 'game.action.view.action_hero_convert_panel'
	--沙滩争夺战 --by lwc
	, ["ActionSandybeachBossFightPanel"] = 'game.action.view.sandybeach_boss_fight.action_sandybeach_boss_fight_panel'
	, ["SandybeachBossFightMainWindow"] = 'game.action.view.sandybeach_boss_fight.sandybeach_boss_fight_main_window'

	--升级有礼 --运营:任思仪 --by lwc
	, ["ActionAccLevelUpGiftPanel"] = 'game.action.view.action_acc_level_up_gift_panel'
	--开学季活动boss	 --by lwc
	, ["ActiontermbeginsPanel"] = 'game.actiontermbegins.view.action_term_begins_panel'
	, ["ActiontermbeginsMainWindow"] = 'game.actiontermbegins.view.action_term_begins_main_window'
	, ["ActiontermbeginsTabChapterPanel"] = 'game.actiontermbegins.view.action_term_begins_tab_chapter_panel'
	, ["ActiontermbeginsTabBossPanel"] = 'game.actiontermbegins.view.action_term_begins_tab_boss_panel'
	, ["ActiontermbeginsFightResultPanel"] = 'game.actiontermbegins.view.action_term_begins_fight_result_panel'
	, ["ActiontermbeginsCollectResultPanel"] = 'game.actiontermbegins.view.action_term_begins_collect_reward_panel'
	, ["ActionBuyPanel"] = 'game.actiontermbegins.view.action_buy_panel'

	
	--开学季活动排行榜	 --by lwc
	, ["ActiontermbeginsRankMainPanel"] = 'game.actiontermbegins.view.action_term_begins_rank_main_panel'
	, ["ActiontermbeginsRankTabRank"] = 'game.actiontermbegins.view.action_term_begins_rank_tab_rank'
	, ["ActiontermbeginsRankTabReward"] = 'game.actiontermbegins.view.action_term_begins_rank_tab_reward'

	--年兽活动
	, ["ActionyearmonsterMainWindow"] = 'game.actionyearmonster.view.actionyearmonster_main_window'
	, ["ActionyearmonsterChallengePanel"] = 'game.actionyearmonster.view.actionyearmonster_challenge_panel'
	, ["ActionyearmonsterEvtItem"] = 'game.actionyearmonster.view.actionyearmonster_evt_item'
	, ["ActionyearmonsterMonsterInfo"] = 'game.actionyearmonster.view.actionyearmonster_monster_info'
	, ["ActionyearmonsterBagPanel"] = 'game.actionyearmonster.view.actionyearmonster_bag_panel'
	, ["ActionyearmonsterSubmitPanel"] = 'game.actionyearmonster.view.actionyearmonster_submit_panel'
	, ["ActionyearmonsterResultPanel"] = 'game.actionyearmonster.view.actionyearmonster_result_panel'
	, ["ActionyearmonsterRedbagEventPanel"] = 'game.actionyearmonster.view.actionyearmonster_redbag_event_panel'
	, ["ActionyearmonsterRedbagEffectPanel"] = 'game.actionyearmonster.view.actionyearmonster_redbag_effect_panel'
	, ["ActionyearmonsterExchangeWindow"] = 'game.actionyearmonster.view.actionyearmonster_exchange_window'
	
	--新人练武场
	, ["ActionPractiseTowerPanel"] = 'game.action.view.action_practise_tower_panel'
	

	--巅峰竞技场 
	, ["ArenapeakchampionMainWindow"] = 'game.arenapeakchampion.view.arenapeakchampion_main_window'
	, ["ArenapeakchampionGuessingWindow"] = 'game.arenapeakchampion.view.arenapeakchampion_guessing_window'
	, ["ArenapeakchampionGuessingTabGuessing"] = 'game.arenapeakchampion.view.arenapeakchampion_guessing_tab_guessing'
	, ["ArenapeakchampionGuessingTabPromotion"] = 'game.arenapeakchampion.view.arenapeakchampion_guessing_tab_promotion'
	, ["ArenapeakchampionGuessCountPanel"] = 'game.arenapeakchampion.view.arenapeakchampion_guess_count_panel'
	, ["ArenapeakchampionFightInfoPanel"] = 'game.arenapeakchampion.view.arenapeakchampion_fight_info_panel'
	, ["ArenapeakchampionFightInfoItem"] = 'game.arenapeakchampion.view.arenapeakchampion_fight_info_item'
	, ["ArenapeakchampionGuessInfoPanel"] = 'game.arenapeakchampion.view.arenapeakchampion_guess_info_panel'
	, ["ArenapeakchampionGuessInfoItem"] = 'game.arenapeakchampion.view.arenapeakchampion_guess_info_panel'
	, ["MatchImgPanel"] = 'game.arenapeakchampion.view.match_img_panel'
	, ["MatchHeadItem"] = 'game.arenapeakchampion.view.match_img_panel'
	, ["ArenapeakchampionMymatchPanel"] = 'game.arenapeakchampion.view.arenapeakchampion_mymatch_panel'
	, ["ArenapeakchampionMymatchTabForm"] = 'game.arenapeakchampion.view.arenapeakchampion_mymatch_tab_form'
	, ["ArenapeakchampionMymatchTabRecord"] = 'game.arenapeakchampion.view.arenapeakchampion_mymatch_tab_record'
	, ["ArenapeakchampionMymatchTabRecordItem"] = 'game.arenapeakchampion.view.arenapeakchampion_mymatch_tab_record'
	, ["ArenapeakchampionResultPanel"] = 'game.arenapeakchampion.view.arenapeakchampion_result_panel'
	, ["ArenapeakchampionShopWindow"] = 'game.arenapeakchampion.view.arenapeakchampion_shop_window'


	--限时礼包入口
	, ["ActionLimitGiftMainPanel"] = 'game.action.view.action_limit_gift_main_panel'
	
	--基金主面板
	, ["ActionFundMainWindow"] = 'game.action.view.action_fund_main_window'
	, ["ActionFundOnePanel"] = 'game.action.view.action_fund_one_panel'
	, ["ActionFundTwoPanel"] = 'game.action.view.action_fund_two_panel'
	, ["ActionFundAwardWindow"] = 'game.action.view.action_fund_award_window'

	--合服活动
    , ["MergeTimeShopPanel"] = 'game.action.view.merge_action.merge_time_shop_panel'
    , ["MergeFirstChargePanel"] = 'game.action.view.merge_action.merge_first_charge_panel'
    , ["MergeTaskPanel"] = 'game.action.view.merge_action.merge_task_panel'
    , ["MergeSignPanel"] = 'game.action.view.merge_action.merge_sign_panel'
    , ["MergeAimPanel"] = 'game.action.view.merge_action.merge_aim_panel'
    , ["MergeAimRewardPanel"] = 'game.action.view.merge_action.merge_aim_reward_panel'



	-- 限时商城
	, ["ActionTimeShopPanel"] = 'game.action.view.action_time_shop_panel'

	--限时活动主面板
	, ["ActivityWindow"] = 'game.activity.view.activity_window'
	, ["ActivityItem"] = 'game.activity.view.activity_item'
	, ["ActivitySignWindow"] = 'game.activity.view.activity_sign_window'

	--英雄远征
	, ["HeroExpeditWindow"] = 'game.heroexpedit.view.heroexpedit_window'
	, ["HeroExpeditLevel"] = 'game.heroexpedit.view.heroexpedit_level'
	, ["EmpolyPanel"] = 'game.heroexpedit.view.empoly_panel'
	, ["BrowsePanel"] = 'game.heroexpedit.view.browse_panel'
	, ["ModeChooseWindow"] = 'game.heroexpedit.view.mode_choose_window'
	, ["HeroexpeditResultWindow"] = 'game.heroexpedit.view.heroexpedit_result_window'
	, ["HeroexpeditVideoWindow"] = 'game.heroexpedit.view.heroexpedit_video_window'
	
	--每日首充
	, ["DayChargeWindow"] = 'game.daycharge.view.daycharge_window'
	--活跃活动
	, ["AnimateActionFestvalPanel"] = 'game.animate_action.view.animate_action_festval_panel'
	, ["AnimateActionFestvalWindow"] = 'game.animate_action.view.animate_action_festval_window'
	, ["AnimateYuanzhenKitchenPanel"] = 'game.animate_action.view.animate_yuanzhen_kitchen_panel'
	, ["AnimateYuanzhenGotoKitchenWindow"] = 'game.animate_action.view.animate_yuanzhen_goto_kitchen_window'
	, ["AnimateYuanzhenKitchenLevWindow"] = 'game.animate_action.view.animate_yuanzhen_kitchen_lev_window'
	, ["AnimateYuanzhenCollectWindow"] = 'game.animate_action.view.animate_yuanzhen_collect_window'
	
	--节日活动
	, ["QingMingPanel"] = 'game.festivalaction.view.qing_ming_panel'
	, ["TreasurePanel"] = 'game.festivalaction.view.treasure_panel'
	, ["TreasureAllServerWindow"] = 'game.festivalaction.view.treasure_all_server_window'
	, ["TreasureMyServerWindow"] = 'game.festivalaction.view.treasure_my_server_window'
	, ["TreasureJoinWindow"] = 'game.festivalaction.view.treasure_join_window'
	, ["TreasureOpenAwardWindow"] = 'game.festivalaction.view.treasure_open_award_window'
	, ["PersonnalGiftWindow"] = 'game.festivalaction.view.personnal_gift_window'

	-- RFM个人推送礼包
	, ["RfmPersonnalGiftWindow"] = 'game.rfmpersonalgift.view.rfm_personnal_gift_window'

	--限时钜惠
	, ["LimitTimeGiftWindow"] = 'game.limittime.view.limit_time_gift_window'

	--回归活动
	, ["ReturnActionMainWindow"] = 'game.returnaction.view.returnaction_main_window'
	, ["ReturnActionPrivilegePanel"] = 'game.returnaction.view.returnaction_privilege_panel'
	, ["ReturnActionTaskPanel"] = 'game.returnaction.view.returnaction_task_panel'
	, ["ReturnActionShopPanel"] = 'game.returnaction.view.returnaction_shop_panel'
	, ["ReturnActionSigninPanel"] = 'game.returnaction.view.returnaction_signin_panel'
	, ["ReturnActionSummonAwardView"] = 'game.returnaction.view.returnaction_summon_award_view'
	, ["ReturnActionRedbagWindow"] = 'game.returnaction.view.returnaction_redbag_window'
	, ["ReturnActionRedbagInfoWindow"] = 'game.returnaction.view.returnaction_redbag_info_window'
	, ["ReturnActionSummonPanel"] = 'game.returnaction.view.returnaction_summon_panel'
	, ["ReturnActionRedbagItem"] = 'game.returnaction.view.returnaction_redbag_item'
	, ["ReturnActionRedbagMsgItem"] = 'game.returnaction.view.returnaction_redbag_msg_item'
	, ["ReturnActionRedbagInfoItem"] = 'game.returnaction.view.returnaction_redbag_info_item'
	
	--七天目标之冒险日记
	, ["SevenGoalAdventureWindow"] = 'game.sevengoal.view.seven_goal_adventure_window'
	, ["SevenGoalAdventureLevRewardWindow"] = 'game.sevengoal.view.seven_goal_adventure_lev_reward_window'
	, ["SevenGoalTotleChargeWindow"] = 'game.sevengoal.view.seven_goal_totle_charge_window'
	, ["SevenGoalSecretWindow"] = 'game.sevengoal.view.seven_goal_secret_window'

	--试炼之门
	, ["EsecsiceWindow"] = 'game.esecsice.view.esecsice_window'

	--宝石副本
	, ["StoneDungeonWindow"] = 'game.stone_dungeon.view.stone_dungeon_window'
	, ["StoneDungeonItem"] = 'game.stone_dungeon.view.stone_dungeon_item'

	-- 联盟远航
	--[[, ["GuildvoyageOrderVo"] = 'game.guildvoyage.guildvoyage_order_vo'
	, ["GuildvoyageMainWindow"] = 'game.guildvoyage.view.guildvoyage_main_window'
	, ["GuildVoyageOrderPanel"] = 'game.guildvoyage.view.guildvoyage_order_panel'
	, ["GuildVoyageEscortPanel"] = 'game.guildvoyage.view.guildvoyage_escort_panel'
	, ["GuildVoyageInteractionPanel"] = 'game.guildvoyage.view.guildvoyage_interaction_panel'
	, ["GuildvoyageOrderEscortWindow"] = 'game.guildvoyage.view.guildvoyage_order_escort_window'
	, ["GuildvoyageChoosePartnerWindow"] = 'game.guildvoyage.view.guildvoyage_choose_partner_window'
	, ["GuildvoyageDonateWindow"] = 'game.guildvoyage.view.guildvoyage_donate_window'
	, ["GuildvoyageResultWindow"] = 'game.guildvoyage.view.guildvoyage_result_window' 
	, ["GuildvoyageChooseConfirmWindow"] = 'game.guildvoyage.view.guildvoyage_choose_confirm_window' 
	, ["GuildVoyageLogWindow"] = 'game.guildvoyage.view.guildvoyage_log_window' --]]

	-- 联盟战
    , ["GuildwarMainWindow"] = 'game.guildwar.view.guildwar_main_window'
    , ["GuildwarAwardWindow"] = 'game.guildwar.view.guildwar_award_panel'
    , ["GuildwarAttkLookWindow"] = 'game.guildwar.view.guildwar_attk_look_window'
    , ["GuildwarDefendLookWindow"] = 'game.guildwar.view.guildwar_defend_look_window'
    , ["GuildwarAttkPositionWindow"] = 'game.guildwar.view.guildwar_attk_position_window'
    , ["GuildwarPositionItem"] = 'game.guildwar.view.guildwar_position_item'
    , ["GuildwarBattleListWindow"] = 'game.guildwar.view.guildwar_battle_list_window'
    , ["GuildwarBattleLogWindow"] = 'game.guildwar.view.guildwar_battle_log_window'
    , ["GuildwarBattleArrayPanel"] = 'game.guildwar.view.guildwar_battle_array_panel'
    , ["GuildWarPositionVo"] = 'game.guildwar.guildwar_position_vo'
    , ["GuildWarRankWindow"] = 'game.guildwar.view.guildwar_rank_window'
    , ["GuildwarAwardBoxWindow"] = 'game.guildwar.view.guildwar_award_box_window'
    , ["GuildwarAwardBoxPreview"] = 'game.guildwar.view.guildwar_award_preview'
    , ["GuildWarBoxVo"] = 'game.guildwar.guildwar_box_vo'
    
	--我要变强
	, ["StrongerMainWindow"] = 'game.stronger.view.stronger_main_window'
	, ["StrongerPanel"] = 'game.stronger.view.stronger_panel'
	, ["StrongerItem"] = 'game.stronger.view.stronger_item'
	, ["ResourcePanel"] = 'game.stronger.view.resource_panel'
	, ["RecommandPanel"] = 'game.stronger.view.recommand_panel'
	--, ["RecommandHeroItem"] = 'game.stronger.view.recommand_hero_item'
	, ["ProblemPanel"] = 'game.stronger.view.problem_panel'
	, ["StrongerSecItem"] = 'game.stronger.view.stronger_sec_item'
 
	--无尽试炼
	, ["EndlessTrailMainWindow"] = 'game.endless_trail.view.endless_trail_main_window'
	, ["EndlessTrailBattleView"] = 'game.endless_trail.view.endless_trail_battle_view'
	, ["EndlessTrailBuffView"] = 'game.endless_trail.view.endless_trail_buff_view'
	, ["EndlessTrailBuffItem"] = 'game.endless_trail.view.endless_trail_buff_view'
	, ["EndlessAwardsPanel"] = 'game.endless_trail.view.endless_awards_panel'
	, ["EndlessAwardsItem"] = 'game.endless_trail.view.endless_awards_panel'
	, ["EndlessRankPanel"] = 'game.endless_trail.view.endless_rank_panel'
	, ["EndlessRankItem"] = 'game.endless_trail.view.endless_rank_panel'
	, ["EndlessRankWindow"] = 'game.endless_trail.view.endless_rank_window'
	, ["EndlessHelpMePanel"] = 'game.endless_trail.view.endless_help_me_panel'
	, ["EndlessMeHelpPanel"] = 'game.endless_trail.view.endless_me_help_panel'
	, ["EndlessFriendHelpWindow"] = 'game.endless_trail.view.endless_friend_help_window'
	, ["EndlessFriendHelpItem"] = 'game.endless_trail.view.endless_friend_help_item'
	, ["EndlessRewardWindow"] = 'game.endless_trail.view.endless_reward_window'
	, ["EndlessFriendHelpItem2"] = 'game.endless_trail.view.endless_friend_help_item_2'
	, ["EndlessAwardsTips"] = 'game.endless_trail.view.endlesstrail_awards_tips'
	, ["EndlessTrailPanel"] = 'game.endless_trail.view.endless_trail_panel'
	, ["EndlessTrailCampPanel"] = 'game.endless_trail.view.endless_camp_panel'
	, ["EndlessOpenTips"] = 'game.endless_trail.view.endlesstrail_open_tips'
	
	--跨服时空 --by lwc
	, ['CrossshowMainWindow'] = 'game.crossshow.view.crossshow_main_window'
	
	--跨服天梯
	, ["LadderMainWindow"] = 'game.ladder.view.ladder_main_window'
	, ["LadderRoleItem"] = 'game.ladder.view.ladder_role_item'
	, ["LadderShopWindow"] = 'game.ladder.view.ladder_shop_window'
	, ["LadderRoleInfoWindow"] = 'game.ladder.view.ladder_role_info'
	, ["LadderLogWindow"] = 'game.ladder.view.ladder_log_window'
	, ["LadderAwardWindow"] = 'game.ladder.view.ladder_award_window'
	, ["LadderRankWindow"] = 'game.ladder.view.ladder_rank_window'
	, ["LadderTopThreeWindow"] = 'game.ladder.view.ladder_top_three_window'
	, ["LadderBattleResultWindow"] = 'game.ladder.view.ladder_battle_result_window'

	--先知殿
	, ["SeerpalaceMainWindow"] = 'game.seerpalace.view.seerpalace_main_window'
	, ["SeerpalaceSummonPanel"] = 'game.seerpalace.view.seerpalace_summon_panel'
	, ["SeerpalaceChangePanel"] = 'game.seerpalace.view.seerpalace_change_panel'
	, ["SeerpalaceShopWindow"] = 'game.seerpalace.view.seerpalace_shop_window'
	, ["SeerpalacePreviewWindow"] = 'game.seerpalace.view.seerpalace_preview_window'
	, ["SeerpalaceSummonScoreWindow"] = 'game.seerpalace.view.seerpalace_summon_score_window'

	--锻造房
	, ["ForgeHouseWindow"] = 'game.forgehouse.view.forgehouse_window'
	, ["ForgeArtifactPanel"] = 'game.forgehouse.view.forge_artifact_panel'
	, ["ArtifactAwardWindow"] = 'game.forgehouse.view.artifact_award_window'
	, ['ArtifactSkillWindow'] = 'game.forgehouse.view.artifact_skill_window'
	, ['EquipmentAllSynthesisWindow'] = 'game.forgehouse.view.equipment_all_synthesis_window'
	, ['EquipmentCompRecordWindow'] = 'game.forgehouse.view.equipment_comp_record_window'

	--限时礼包浏览
	, ["OnlineGiftWindow"] = 'game.onlinegift.view.onlinegift_window'

	--远航商人
	, ["VoyageMainWindow"] = 'game.voyage.view.voyage_main_window'
	, ["VoyageOrderItem"] = 'game.voyage.view.voyage_order_item'
	, ["VoyageDispatchWindow"] = 'game.voyage.view.voyage_dispatch_window'

	, ["CommonTabBtn"] = "common.common_tab_btn"

	-- 录像馆
	, ["VedioMainWindow"] = 'game.vedio.view.vedio_main_window'
	, ["VedioCollectWindow"] = 'game.vedio.view.vedio_collect_window'
	, ["VedioMyselfWindow"] = 'game.vedio.view.vedio_myself_window'
	, ["VedioMainItem"] = 'game.vedio.view.vedio_main_item'
	, ["VedioLookPanel"] = 'game.vedio.view.vedio_look_panel'
	, ["VedioSharePanel"] = 'game.vedio.view.vedio_share_panel'

	-- 限时召唤
	, ["ActionTimeSummonPanel"] = 'game.timesummon.view.action_time_summon_panel'
	, ["TimeSummonAwardView"] = 'game.timesummon.view.time_summon_award_view'
	, ["TimeSummonProgressView"] = 'game.timesummon.view.time_summon_progress_view'
	, ["TimeSummonPreviewWindow"] = 'game.timesummon.view.time_summon_preview_window'
	, ["HeroSelectPanel"] = 'game.timesummon.view.hero_select_panel'
	--精英召唤
	, ["EliteSummonPanel"] = 'game.elitesummon.view.elitesummon_panel'
	--预言召唤
	, ["PresageSummonPanel"] = 'game.elitesummon.view.presage_summon_panel'
	--自选召唤
	, ["SelectEliteSummonPanel"] = 'game.elitesummon.view.select_elitesummon_panel'
	--自选召唤up英雄选择界面
	, ["SummonSelectWindow"] = 'game.elitesummon.view.summon_select_window'
	

	--精灵召唤
	, ["ActionTimeElfinSummonPanel"] = 'game.timesummon.view.action_time_elfin_summon_panel'
	, ["ActionTimeElfinSummonGainWindow"] = 'game.timesummon.view.action_time_elfin_summon_gain_window'

	--邀请码
	, ["InviteCodePanel"] = 'game.invitecode.view.invitecode_panel'
	, ["InviteCodeMyPanel"] = 'game.invitecode.view.invitecode_my_panel'
	, ["InviteCodeFriendPanel"] = 'game.invitecode.view.invitecode_friend_panel'
	, ["InviteCodeReturnFriendPanel"] = 'game.invitecode.view.invitecode_return_friend_panel'
	
	-- 跨服战场
	, ["CrossgroundMainWindow"] = 'game.crossground.view.crossground_main_window'
	, ["CrossgroundItem"] = 'game.crossground.view.crossground_main_item'

	-- 冒险活动入口
	, ["AdventureActivityWindow"] = 'game.adventureactivity.view.adventureactivity_window'

	-- 元素神殿
	, ["ElementMainWindow"] = 'game.element.view.element_main_window'
	, ["ElementEctypeWindow"] = 'game.element.view.element_ectype_window'
	, ["ElementEctypeItem"] = 'game.element.view.element_ectype_item'
	, ["ElementRankWindow"] = 'game.element.view.element_rank_window'
	, ["ElementRankPanel"] = 'game.element.view.element_rank_panel'
	, ["ElementAwardPanel"] = 'game.element.view.element_award_panel'

	-- 圣物
	, ["HalidomMainPanel"] = 'game.halidom.view.halidom_main_panel'
	, ["HalidomUpStepWindow"] = 'game.halidom.view.halidom_up_step_window'
	, ["HalidomUpLvWindow"] = 'game.halidom.view.halidom_up_lv_window'
	, ["HalidomUnlockWindow"] = 'game.halidom.view.halidom_unlock_window'
	, ["HalidomStepPreView"] = 'game.halidom.view.halidom_step_preview'

	-- 精灵
	, ["ElfinMainPanel"] = 'game.elfin.view.elfin_main_panel'
	, ["ElfinGainWindow"] = 'game.elfin.view.elfin_gain_window'
	, ["ElfinSelectItemWindow"] = 'game.elfin.view.elfin_select_item_window'
	, ["ElfinPrivilegeWindow"] = 'game.elfin.view.elfin_privilege_window'
	, ["ElfinBookWindow"] = 'game.elfin.view.elfin_book_window'
	, ["ElfinInfoWindow"] = 'game.elfin.view.elfin_info_window'
	, ["ElfinRouseItem"] = 'game.elfin.view.elfin_rouse_item'
	, ["ElfinTreeStepWindow"] = 'game.elfin.view.elfin_tree_step_window'
	, ["ElfinTreeRouseWindow"] = 'game.elfin.view.elfin_tree_rouse_window'
	, ["ElfinChooseWindow"] = 'game.elfin.view.elfin_choose_window'
	, ["ElfinCompoundWindow"] = 'game.elfin.view.elfin_compound_window'
	, ["ElfinLvUpTipsWindow"] = 'game.elfin.view.elfin_lv_up_tips'
	, ["ElfinLvUpWindow"] = 'game.elfin.view.elfin_lv_up_window'
	, ["ElfinAdjustWindow"] = 'game.elfin.view.elfin_adjust_window'
	, ["ElfinRousePanel"] = 'game.elfin.view.elfin_rouse_panel'
	, ["ElfinSummonPanel"] = 'game.elfin.view.elfin_summon_panel'
	, ["ElfinWishWindow"] = 'game.elfin.view.elfin_wish_window'
	, ["ElfinHatchPanel"] = 'game.elfin.view.elfin_hatch_panel'
	, ["ElfinEggSyntheticPanel"] = 'game.elfin.view.elfin_egg_synthetic_panel'
	, ["ElfinHatchUnlockPanel"] = 'game.elfin.view.elfin_hatch_unlock_panel'
	, ["ElfinFightPlanPanel"] = 'game.elfin.view.elfin_fight_plan_panel'
	, ["ElfinFightPlanItem"] = 'game.elfin.view.elfin_fight_plan_panel'
	, ["ElfinFightPlanChooseTips"] = 'game.elfin.view.elfin_fight_plan_choose_tips'
	, ["ElfinFightPlanSaveTips"] = 'game.elfin.view.elfin_fight_plan_save_tips'
	
	
	--新版首充
	, ["NewFirstChargeWindow"] = 'game.newfirstcharge.view.newfirstcharge_window'
	, ["NewFirstChargeWindow1"] = 'game.newfirstcharge.view.newfirstcharge_window1'
	, ["NewFirstChargeWindow2"] = 'game.newfirstcharge.view.newfirstcharge_window2'
	, ["NewFirstChargeWindow3"] = 'game.newfirstcharge.view.newfirstcharge_window3'
	
	-- 转盘活动
	, ["DialActionMainPanel"] = 'game.dial_action.view.dial_action_main_panel'
	, ["DialRecordWindow"] = 'game.dial_action.view.dial_record_window'
	, ["DialAwardWindow"] = 'game.dial_action.view.dial_award_window'

	-- 花火大会
	, ["PetardActionMainPanel"] = 'game.petard_action.view.petard_action_main_panel'
	, ["PetardSelectItemWindow"] = 'game.petard_action.view.petard_select_item_window'
	, ["PetardActionTips"] = 'game.petard_action.view.petard_action_tips'
	, ["PetardAffirmWindow"] = 'game.petard_action.view.petard_affirm_window'
	, ["PetardEffectWindow"] = 'game.petard_action.view.petard_effect_window'
	, ["PetardRedbagInfoWindow"] = 'game.petard_action.view.petard_redbag_info_window'
	, ["PetardRedbagItem"] = 'game.petard_action.view.petard_redbag_item'
	, ["PetardRedbagMsgItem"] = 'game.petard_action.view.petard_redbag_msg_item'
	, ["PetardRedbagWindow"] = 'game.petard_action.view.petard_redbag_window'
	, ["PetardAwardWindow"] = 'game.petard_action.view.petard_award_window'
	, ["PetardRedbagInfoItem"] = 'game.petard_action.view.petard_redbag_info_item'

	-- 甜蜜大作战
	, ["ActionSweetPanel"] = 'game.action.view.action_sweet.action_sweet_panel'
	, ["ActionSweetAwardWindow"] = 'game.action.view.action_sweet.action_sweet_award_window'

	-- 砸金蛋活动
	, ["ActionSmasheggPanel"] = 'game.smashegg.view.action_smashegg_panel'
	, ["SmasheggRecordWindow"] = 'game.smashegg.view.smashegg_record_window'

	--合服调查问卷
	, ["MergeserverLookWindow"] = 'game.mergeserver.view.merge_server_look_window'

	-- 天界副本
	, ["HeavenMainWindow"] = 'game.heaven.view.heaven_main_window'
	, ["HeavenMainChapter"] = 'game.heaven.view.heaven_main_chapter'
	, ["HeavenChapterWindow"] = 'game.heaven.view.heaven_chapter_window'
	, ["HeavenCustomsItem"] = 'game.heaven.view.heaven_customs_item'
	, ["HeavenRankWindow"] = 'game.heaven.view.heaven_rank_window'
	, ["HeavenStarAwardWindow"] = 'game.heaven.view.heaven_star_award_window'
	, ["HeavenBattleWinView"] = 'game.heaven.view.heaven_battle_win_view'
	, ["HeavenDialWindow"] = 'game.heaven.view.heaven_dial_window'
	, ["HeavenDialRecordWindow"] = 'game.heaven.view.heaven_dial_record_window'
	, ["HeavenDungeonPanel"] = 'game.heaven.view.heaven_dungeon_panel'
	, ["HeavenDialWishWindow"] = 'game.heaven.view.heaven_dial_wish_window'
	
	--限时招募
	, ["RecruitHeroWindow"] = 'game.recruithero.view.recruit_hero_window'

	--战令活跃
	, ["OrderActionMainWindow"] = 'game.orderaction.view.orderaction_main_window'
	, ["BuyLevWindow"] = 'game.orderaction.view.buy_lev_window'
	, ["OrderActionEndWarnWindow"] = 'game.orderaction.view.orderaction_end_warn_window'
	, ["OrderActionRewardPanel1"] = 'game.orderaction.view.orderaction_reward_panel1'
	, ["OrderActionTeskPanel1"] = 'game.orderaction.view.orderaction_tesk_panel1'
	, ["UntieRewardWindow"] = 'game.orderaction.view.untie_reward_window'
	, ["UntieRewardWindow1"] = 'game.orderaction.view.untie_reward_window1'

	--全新战令
	, ["NewOrderactionWindow"] = 'game.neworderaction.view.neworderaction_window'
	, ["NewOrderActionTaskPanel"] = 'game.neworderaction.view.neworderaction_task_panel'
	, ["NewUntieRewardWindow1"] = 'game.neworderaction.view.newuntie_reward_window1'
	, ["NewOrderActionEndWarnWindow"] = 'game.neworderaction.view.neworderaction_end_warn_window'

	, ["OneCentGiftWindow"] = 'game.onecentgift.view.onecentgift_window'
	
	--神装商店
	, ["SuitShopMainWindow"] = 'game.suitshop.view.suitshop_main_window'

	-- 跨服竞技场
	, ["CrossareanMainWindow"] = 'game.crossarena.view.crossarena_main_window'
	, ["CrossarenaChallengePanel"] = 'game.crossarena.view.crossarena_challenge_panel'
	, ["CrossareanRoleItem"] = 'game.crossarena.view.crossarena_role_item'
	, ["CrossArenaResultWindow"] = 'game.crossarena.view.crossarena_result_window'
	, ["CrossarenaRankWindow"] = 'game.crossarena.view.crossarena_rank_window'
	, ["CrossarenaAwardWindow"] = 'game.crossarena.view.crossarena_award_window'
	, ["CrossarenaHonourPanel"] = 'game.crossarena.view.crossarena_honour_panel'
	, ["CrossareanHonourItem"] = 'game.crossarena.view.crossarena_honour_item'
	, ["CrossareanShopWindow"] = 'game.crossarena.view.crossarena_shop_window'
	, ["CorssarenaFormListPanel"] = 'game.crossarena.view.crossarena_form_list_panel'
	, ["CrossarenaRoleTips"] = 'game.crossarena.view.crossarena_role_tips'
	, ["CrossareanVideoWindow"] = 'game.crossarena.view.crossarena_video_window'

	-- 家园
	, ["HomeWorldScene"] = 'game.homeworld.view.homeworld_scene'
	, ["HomeworldShopWindow"] = 'game.homeworld.view.homeworld_shop_window'
	, ["HomeworldShopItem"] = 'game.homeworld.view.homeworld_shop_item'
	, ["HomeworldFurniture"] = 'game.homeworld.view.homeworld_furniture'
	, ["HomeworldPet"] = 'game.homeworld.view.homeworld_pet'
	, ["HomeworldRole"] = 'game.homeworld.view.homeworld_role'
	, ["HomeworldMyUnit"] = 'game.homeworld.view.homeworld_my_unit'
	, ["HomeworldMyUnitItem"] = 'game.homeworld.view.homeworld_my_unit_item'
	, ["HomeworldMyPlanItem"] = 'game.homeworld.view.homeworld_my_plan_item'
	, ["HomeworldVisitWindow"] = 'game.homeworld.view.homeworld_visit_window'
	, ["HomeworldSuitWindow"] = 'game.homeworld.view.homeworld_suit_window'
	, ["HomeworldFigureWindow"] = 'game.homeworld.view.homeworld_figure_window'
	, ["HomeworldFigureChoseWindow"] = 'game.homeworld.view.homeworld_figure_chose_window'
	, ["HomeworldBuyUnitWindow"] = 'game.homeworld.view.homeworld_buy_unit_window'
	, ["HomeworldHookTimeAward"] = 'game.homeworld.view.homeworld_hook_time_award'
	, ["HomeworldUnitInfoWindow"] = 'game.homeworld.view.homeworld_unit_info_window'
	, ["HomeworldUnlockKeyPanel"] = 'game.homeworld.view.homeworld_unlock_key_panel'
	, ["HomeworldInfoWindow"] = 'game.homeworld.view.homeworld_info_window'

	-- 跨服冠军赛
	, ["CrosschampionMainWindow"] = 'game.crosschampion.view.crosschampion_main_window'
	, ["CrosschampionShopWindow"] = 'game.crosschampion.view.crosschampion_shop_window'
	--奇遇冒险
	,["EncounterWindow"] = "game.encounter.view.encounter_window"
	,["EncounterLibraryWindow"] = "game.encounter.view.encounter_library_window"

	-- 大富翁
	, ["MonopolyMainScene"] = 'game.monopoly.view.monopoly_main_scene'
	, ["MonopolyGridItem"] = 'game.monopoly.view.monopoly_grid_item'
	, ["HolynightMainWindow"] = 'game.monopoly.view.holynight_main_window'
	, ["HolynightBossWindow"] = 'game.monopoly.view.holynight_boss_window'
	, ["HolynightBossItem"] = 'game.monopoly.view.holynight_boss_item'
	, ["MonopolyDialogWindow"] = 'game.monopoly.view.monopoly_dialog_window'
	, ["MonopolyTips"] = 'game.monopoly.view.monopoly_tips'
	, ["MonopolyChoseStepWindow"] = 'game.monopoly.view.monopoly_chose_step_window'
	, ["MonopolyPumpkinWindow"] = 'game.monopoly.view.monopoly_pumpkin_window'
	, ["MonopolyMorraWindow"] = 'game.monopoly.view.monopoly_morra_window'
	, ["MonopolyRankWindow"] = 'game.monopoly.view.monopoly_rank_window'
	, ["MonopolyGuildRankPanel"] = 'game.monopoly.view.monopoly_rank_guild_panel'
	, ["MonopolyPersonalRankPanel"] = 'game.monopoly.view.monopoly_rank_personal_panel'
	, ["MonopolyRankAwardPanel"] = 'game.monopoly.view.monopoly_rank_award_panel'
	, ["MonopolyShowItemWindow"] = 'game.monopoly.view.monopoly_show_item_window'
	, ["MonopolyMasterInfoWindow"] = 'game.monopoly.view.monopoly_master_info_window'

	-- 验证码
	, ["VerificationcodeMainWindow"] = 'game.verificationcode.view.verificationcode_main_window'

	-- 新手训练营
	, ["TrainingcampWindow"] = 'game.trainingcamp.view.trainingcamp_window'
	, ["TrainingcampTipsWindow"] = 'game.trainingcamp.view.trainingcamp_tips_window'
	, ["TrainingcampMainWindow"] = 'game.trainingcamp.view.trainingcamp_main_window'
	, ["TrainingcampAllfinishTipsWindow"] = 'game.trainingcamp.view.trainingcamp_allfinish_tips_window'

	-- 位面冒险
	, ["PlanesBagPanel"] = 'game.planes.view.planes_bag_panel' --背包
	, ["PlanesHeroListPanel"] = 'game.planes.view.planes_hero_list_panel' --英雄列表
	, ["PlanesMainWindow"] = 'game.planes.view.planes_main_window'
	, ["PlanesMainItem"] = 'game.planes.view.planes_main_item'
	, ["PlanesMapWindow"] = 'game.planes.view.planes_map_window'
	, ["PlanesEvtItem"] = 'game.planes.view.planes_evt_item'
	, ["PlanesBoardWindow"] = 'game.planes.view.planes_board_window'
	, ["PlanesMasterWindow"] = 'game.planes.view.planes_master_window'
	, ["PlanesDunInfoWindow"] = 'game.planes.view.planes_dun_info_window'
	, ["PlanesHireHeroWindow"] = 'game.planes.view.planes_hire_hero_window'
	, ["PlanesHireHeroItem"] = 'game.planes.view.planes_hire_hero_item'
	, ["PlanesBuffChoseWindow"] = 'game.planes.view.planes_buff_chose_window'
	, ["PlanesBuffItem"] = 'game.planes.view.planes_buff_item'
	, ["PlanesBuffListWindow"] = 'game.planes.view.planes_buff_list_window'
	, ["PlanesAwardInfoWindow"] = 'game.planes.view.planes_award_info_window'
	, ["PlanesFirstAwardWindow"] = 'game.planes.view.planes_first_award_window'

	--位面冒险 改版 参考afk
	, ["PlanesafkMainWindow"] = 'game.planesafk.view.planesafk_main_window'
	, ["PlanesafkItemUsePanel"] = 'game.planesafk.view.planesafk_item_use_panel'
	, ["PlanesafkHeroListPanel"] = 'game.planesafk.view.planesafk_hero_list_panel'
	, ["PlanesafkBuffListPanel"] = 'game.planesafk.view.planesafk_buff_list_panel'
	, ["PlanesafkMainItem"] = 'game.planesafk.view.planesafk_main_window'
	, ["PlanesafkEvtItem"] = 'game.planesafk.view.planesafk_evt_item'
	, ["PlanesafkResultPanel"] = 'game.planesafk.view.planesafk_result_panel'

	, ["PlanesafkChooseDifficultyPanel"] = 'game.planesafk.view.planesafk_choose_difficulty_panel'
	, ["PlanesafkEvtOccurrencePanel"] = 'game.planesafk.view.planesafk_evt_occurrence_panel'
	, ["PlanesafkEvtShopPanel"] = 'game.planesafk.view.planesafk_evt_shop_panel'
	, ["PlanesafkEvtShopItem"] = 'game.planesafk.view.planesafk_evt_shop_panel'
	, ["PlanesafkMasterWindow"] = 'game.planesafk.view.planesafk_master_window'
	, ["PlanesafkBuffChoseWindow"] = 'game.planesafk.view.planesafk_buff_chose_window'
	, ["PlanesafkBoardWindow"] = 'game.planesafk.view.planesafk_board_window'
	, ["PlanesafkHireHeroWindow"] = 'game.planesafk.view.planesafk_hire_hero_window'
	, ['PlanesafkOrderactionWindow'] = 'game.planesafk.view.planesafk_orderaction_window'
	, ['PlanesafkOrderactionUntieRewardWindow'] = 'game.planesafk.view.planesafk_orderaction_untie_reward_window'
	, ['PlanesafkOrderActionEndWarnWindow'] = 'game.planesafk.view.planesafk_orderaction_end_warn_window'

	--新人练武场
	, ['PractiseTowerWindow'] = 'game.practisetower.view.practisetower_window'
	, ['PractisetowerItem'] = 'game.practisetower.view.practisetower_item'
	, ['PractiseTowerResultWindow'] = 'game.practisetower.view.practisetower_result_window'
	, ['PractisetowerAwardsPanel'] = 'game.practisetower.view.practisetower_award_panel'
	, ['PractisetowerRankWindow'] = 'game.practisetower.view.practisetower_rank_window'
	, ['PractisetowerRankPanel'] = 'game.practisetower.view.practisetower_rank_panel'
	
	-------------------配置表-----------------
	, ["Config_RoleData"] = "config.role_data"
	, ["Config_UnitData"] = "config.unit_data"
	, ["Config_UnitData1"] = "config.unit_data1"
	, ["Config_UnitData2"] = "config.unit_data2"
	, ["Config_UnitData3"] = "config.unit_data3"
	, ["Config_MapUnit"] = "config.config_map_unit"
	, ["Config_MapBlock"] = "config.config_map_block"
	, ["Config_Map"] = "config.config_map"
	, ["Config_GmData"] = "config.gm_data"
	, ["Config_ColorData"] = "config.color_data"
	, ["Config_FunctionData"] = "config.function_data"
	, ["Config_FaceData"] = "config.face_data"
	, ["Config_RandomNameData"] = "config.random_name_data"
	, ["Config_PartnerData"] = "config.partner_data"
	, ["Config_PartnerSkillData"] = "config.partner_skill_data"
	, ["Config_PartnerSkinData"] = "config.partner_skin_data" --英雄皮肤
	, ["Config_PartnerVoiceData"] = "config.partner_voice_data" --英雄语音
	, ["Config_ItemData"] = "config.item_data"
	, ["Config_ItemData1"] = "config.item_data1"
	, ["Config_ItemData2"] = "config.item_data2"
	, ["Config_ItemData3"] = "config.item_data3"
	, ["Config_ItemData4"] = "config.item_data4"
	, ["Config_ItemData5"] = "config.item_data5"
	, ["Config_ItemData6"] = "config.item_data6"
	, ["Config_ItemData7"] = "config.item_data7"
	, ["Config_ItemData8"] = "config.item_data8"
	, ["Config_ItemData9"] = "config.item_data9"
	, ["Config_ItemData10"] = "config.item_data10"
	, ["Config_QuestData"] = "config.quest_data"
	, ["Config_GameData"] = "config.game_data"
	, ["Config_PartnerEqmData"] = "config.partner_eqm_data"
	, ["Config_PartnerHolyEqmData"] = "config.partner_holy_eqm_data"
	, ["Config_GiftData"] = "config.gift_data"
	, ["Config_DramaData"] = "config.drama_data"
	, ["Config_PackageData"] = "config.package_data"
	, ["Config_SoundData"] = "config.sound_data"
	, ["Config_SkillData"] = "config.skill_data"
	, ["Config_SkillData1"] = "config.skill_data1"
	, ["Config_SkillData2"] = "config.skill_data2"
	, ["Config_SkillData3"] = "config.skill_data3"
	, ["Config_SkillData4"] = "config.skill_data4"
	, ["Config_SkillData5"] = "config.skill_data5"
	, ["Config_SkillData6"] = "config.skill_data6"
	, ["Config_FormationData"] = "config.formation_data"
	, ["Config_SourceData"] = "config.source_data"
	, ["Config_DailyData"] = "config.daily_data"
	, ["Config_WeekCalendarData"] = "config.week_calendar_data"
	, ["Config_NoticeData"] = "config.notice_data"
	, ["Config_SummonData"] = "config.summon_data"
	, ["Config_AttrData"] = "config.attr_data"
	, ["Config_ExchangeData"] = "config.exchange_data"
	, ["Config_CheckinData"] = "config.checkin_data"
	, ["Config_ItemProductData"] = "config.item_product_data"
	, ["Config_AgendaData"] = "config.agenda_data"
	, ["Config_PartnerArtifactData"] = "config.partner_artifact_data"
	, ["Config_ArtifactSummonData"] = "config.artifact_summon_data"
	, ["Config_DunChapterData"] = "config.dun_chapter_data"
	, ["Config_BattleMapData"] = "config.battle_map_data"
	, ["Config_DunTrialData"] = "config.dun_trial_data"
	, ["Config_ArenaData"] = "config.arena_data"
	, ["Config_ArenaEliteData"] = "config.arena_elite_data"
	, ["Config_TradeData"] = "config.trade_data"
	, ["Config_BattleBgData"] = "config.battle_bg_data"
	, ["Config_EquipRecommend"] = "config.equip_recommend"
	, ["Config_BattleActData"] = "config.battle_act_data"
	, ["Config_FeatData"] = "config.feat_data"
	, ["Config_WharfData"] = "config.wharf_data"
	, ["Config_PartnerHaloData"] = "config.partner_halo_data"
	, ["Config_AnswerData"] = "config.answer_data"
	, ["Config_ActivityData"] = "config.activity_data"
	, ["Config_RecommendData"] = "config.recommend_data"
	, ["Config_GuildData"] = "config.guild_data"
	, ["Config_VipData"] = "config.vip_data"
	, ["Config_BuffData"] = "config.buff_data"
	, ["Config_InvestData"] = "config.invest_data"
	, ["Config_GuildWarData"] = "config.guild_war_data"
	, ["Config_GuildSecretAreaData"] = "config.guild_secret_area_data"--公会秘境
	, ["Config_GuildMarketplaceData"] = "config.guild_marketplace_data"--公会宝库
	, ["Config_CombatTypeData"] = "config.combat_type_data"
	, ["Config_CombatHaloData"] = "config.combat_halo_data"
	, ["Config_ResearchData"] = "config.research_data"
	, ["Config_SpecialSpineData"] = "config.special_spine_data"
	, ["Config_LevUpgradeData"] = "config.lev_upgrade_data"
	, ["Config_PartnerRefineData"] = "config.partner_refine_data"
	, ["Config_PartnerAwakenData"] = "config.partner_awaken_data"
	, ["Config_OracleData"] = "config.oracle_data"
	, ["Config_ChargeData"] = "config.charge_data"
	, ["Config_ChargeMallData"] = "config.charge_mall_data"
	, ["Config_DungeonTeamData"] = "config.dungeon_team_data"
	, ["Config_DayGoalsData"] = "config.day_goals_data"
	, ["Config_DialData"] = "config.dial_data"
	, ["Config_EffectData"] = "config.effect_data"
	, ["Config_LevGiftData"] = "config.lev_gift_data"
	, ["Config_HolidayClientData"] = "config.holiday_client_data"
	, ["Config_HolidayLuckyDogData"] = "config.holiday_lucky_dog_data"
	, ["Config_HolidayOptionalLotteryData"] = "config.holiday_optional_lottery_data"
	, ["Config_ForecastData"] = "config.forecast_data"	
	, ["Config_AvatarData"] = "config/avatar_data"
	, ["Config_SubtitleData"] = "config.subtitle_data"
	, ["Config_StrongerData"] = "config.stronger_data"
	, ["Config_GuildDunData"] = "config.guild_dun_data"
	, ["Config_HolidayQuestData"] = "config.holiday_quest_data"
	, ["Config_AvatarData"] = "config.avatar_data"
	, ["Config_SayData"] = "config.say_data"
	, ["Config_LooksData"] = "config.looks_data"
	, ["Config_HotPartnerData"] = "config.hot_partner_data"
	, ["Config_DayBargainData"] = "config.day_bargain_data"
	, ["Config_GroupControlData"] = "config.group_control_data"
	, ["Config_AdvanceGuideData"] = "config.advance_guide_data"
	, ["Config_TrialsData"] = "config.trials_data"
	, ["Config_DiamondWarData"] = "config.diamond_war_data"
	, ["Config_AttackCityData"] = "config.attack_city_data"
	, ["Config_HolidayRandData"] = "config.holiday_rand_data"
	, ["Config_MonthFundData"] = "config.month_fund_data"
	, ["Config_ClothesData"] = "config.clothes_data"
	, ["Config_StarTowerData"] = "config.star_tower_data"
	, ["Config_DayGoalsSecondData"] = "config.day_goals_second_data"
	, ["Config_HolidaySnowmanData"] = "config.holiday_snowman_data"
	, ["Config_StrongerRecommendData"] = "config.stronger_recommend_data"
	, ["Config_ArtifactExchangeData"] = "config.artifact_exchange_data"
	, ["Config_HolidayDinnerData"] = "config.holiday_dinner_data"
	, ["Config_CrossHallData"] = "config.cross_hall_data"
	, ["Config_CityData"] = "config.city_data"
	, ["Config_StarData"] = "config.star_data"
	, ["Config_StarDivinationData"] = "config.star_divination_data"
	, ["Config_GuildSkillData"] = "config.guild_skill_data"
	, ["Config_GuildQuestData"] = "config.guild_quest_data"
	, ["Config_PartnerFieldData"] = "config.partner_field_data"
	, ["Config_EscortData"] = "config.escort_data"
	, ["Config_RecruitAwardData"] = "config.recruit_award_data"
	, ["Config_ExpeditionData"] = "config.expedition_data"
	, ["Config_HolidayGrouponData"] = "config.holiday_groupon_data"
	, ["Config_HolidayLantermFestivalData"] = "config.holiday_lanterm_festival_data"
	, ["Config_HolidayLantermAdventureData"] = "config.holiday_lanterm_adventure_data"
	, ["Config_HolidayMakeData"] = "config.holiday_make_data"
	, ["Config_DayGoalsNewData"] = "config.day_goals_new_data"
	, ["Config_ServerData"] = "config.server_data"
	--音效配置
	, ["Config_VoiceData"] = "config.voice_data"
	
	--新剧情副本
	,["Config_DungeonData"] = "config.dungeon_data"
	,["Config_RecruitData"] = "config.recruit_data" --新召唤
	,["Config_HonorData"] = "config.honor_data" --称号
	,["Config_BossData"] = "config.boss_data"--世界boss
	,["Config_AdventureData"] = "config.adventure_data"--世界boss

	--市场
	,["Config_MarketGoldData"] = "config.market_gold_data"
	,["Config_MarketSilverData"] = "config.market_silver_data"

	--金银币兑换
	,["Config_ConvertData"] = "config.convert_data"

	--战力礼包
	,["Config_PowerGiftData"] = "config.power_gift_data"
	--七天登录
	,["Config_LoginDaysData"] = "config.login_days_data"
	--八天登录
	,["Config_LoginDaysNewData"] = "config.login_days_new_data"
	--七天排行
	,["Config_DaysRankData"] = "config.days_rank_data"
	--冠军赛
	,["Config_ArenaChampionData"] = "config.arena_champion_data"
	--跨服冠军赛
	,["Config_ArenaClusterChampionData"] = "config.arena_cluster_champion_data"
	--限时礼包入口
	,["Config_StarGiftData"] = "config.star_gift_data"
	--宝石
	, ["Config_PartnerGemstoneData"] = "config.partner_gemstone_data"
	--多人竞技场
	,["Config_HolidayArenaTeamData"] = "config.holiday_arena_team_data"

	--无尽试炼
	, ["Config_EndlessData"] = "config.endless_data"
	--活动
	, ["Config_DailyplayData"] = "config.dailyplay_data"
	--副本活动
	, ["Config_DungeonStoneData"] = "config.dungeon_stone_data"
	-- 众神战场
	, ["Config_ZsWarData"] = "config.zs_war_data"
	-- 圣器
	, ["Config_HallowsData"] = "config.hallows_data"
	, ["Config_HallowsRefineData"] = "config.hallows_refine_data"
    -- 世界等级
	, ["Config_WorldLevData"] = "config.world_lev_data"
	-- 剧情频道
	, ["Config_DramaChatData"] = "config.drama_chat_data"
	-- 联盟战
	, ["Config_GuildWarData"] = "config.guild_war_data"
	-- 星河神殿
	, ["Config_PrimusData"] = "config.primus_data"
	-- 跨服天梯
	,["Config_SkyLadderData"] = "config.sky_ladder_data"
	--在线奖励
	,["Config_MiscData"] = "config.misc_data"
	--先知殿
	,["Config_RecruitHighData"] = "config.recruit_high_data"
	--远航
	,["Config_ShippingData"] = "config.shipping_data"
	-- 特权礼包
	,["Config_PrivilegeData"] = "config.privilege_data"
	-- 录像馆
	,["Config_VideoData"] = "config.video_data"
	-- 限时召唤
	,["Config_RecruitHolidayData"] = "config.recruit_holiday_data"

	--邀请码
	,["Config_InviteCodeData"] = "config.invite_code_data"
	-- 跨服战场
	,["Config_CrossGroundData"] = "config.cross_ground_data"
	-- 元素圣殿
	,["Config_ElementTempleData"] = "config.element_temple_data"
	-- 圣物
	,["Config_HalidomData"] = "config.halidom_data"
	-- 精灵
	,["Config_SpriteData"] = "config.sprite_data"
	-- 跨服时空
	,["Config_CrossShowData"] = "config.cross_show_data"
	-- 转盘活动
	,["Config_HolidayDialData"] = "config.holiday_dial_data"
	--满减
	,["Config_HolidayFullExchangeData"] = "config.holiday_full_exchange_data"
	-- 砸蛋
	,["Config_BreakEggData"] = "config.break_egg_data"
	--限时招募
	,["Config_WelfareData"] = "config.welfare_data"
	-- 天界副本
	,["Config_DungeonHeavenData"] = "config.dungeon_heaven_data"
	--10星置换
	,["Config_HolidayConvertData"] = "config.holiday_convert_data"
	--战力活动
	,["Config_HolidayWarOrderData"] = "config.holiday_war_order_data"
	--新版战令
	,["Config_HolidayNewWarOrderData"] = "config.holiday_new_war_order_data"
	--沙滩争夺战
	,["Config_HolidayBossData"] = "config.holiday_boss_data"
	-- 神装转盘
	,["Config_HolyEqmLotteryData"] = "config.holy_eqm_lottery_data"
	-- 兑换商城
	,["Config_HolidayExchangeData"] = "config.holiday_exchange_data"
	--神装道具商店
	,["Config_HolidayHolyEqmData"] = "config.holiday_holy_eqm_data"
	,["Config_PartnerSkinData"] = "config.partner_skin_data"
	-- 跨服竞技场
	,["Config_ArenaClusterData"] = "config.arena_cluster_data"
	--勇者夺宝
	,["Config_HolidaySnatchData"] = "config.holiday_snatch_data"

	--试炼之境
	,["Config_HolidayBossNewData"] = "config.holiday_boss_new_data"
	--开学季
	,["Config_HolidayTermBeginsData"] = "config.holiday_term_begins_data"
	-- 花火大会
	,["Config_HolidayPetardData"] = "config.holiday_petard_data"
	-- 花火大会
	,["Config_HolidayValentinesData"] = "config.holiday_valentines_data"

	--组队竞技场
	,["Config_ArenaTeamData"] = "config.arena_team_data"
	--历练
	,["Config_RoomFeatData"] = "config.room_feat_data"
	--成长之路
	,["Config_RoomGrowData"] = "config.room_grow_data"
	--萌宠
	,["Config_HomePetData"] = "config.home_pet_data"
	--秘矿冒险
	,["Config_AdventureMineData"] = "config.adventure_mine_data"
	--共鸣
	,["Config_ResonateData"] = "config.resonate_data"
	--回归活动
	,["Config_HolidayReturnData"] = "config.holiday_return_data"
	--新回归活动
	,["Config_HolidayReturnNewData"] = "config.holiday_return_new_data"
	
	,["Config_RecruitHolidayEliteData"] = "config.recruit_holiday_elite_data"
	,["Config_HolidayPredictData"] = "config.holiday_predict_data"
	,["Config_HolidayPersonalGiftData"] = "config.holiday_personal_gift_data"

	-- 家园
	,["Config_HomeData"] = "config.home_data"
	,["Config_Map"] = "config.config_map"
	,["Config_MapBlock"] = "config.config_map_block"
	--皮肤抽奖
	,["Config_HolidaySkinDrawData"] = "config.holiday_skin_draw_data"
	--合服问卷
	,["Config_MergeVotingData"] = "config.merge_voting_data"
	,["Config_HolidayMergeGoalData"] = "config.holiday_merge_goal_data"

	--奇遇冒险
	,["Config_EncounterData"] = "config.encounter_data"
	-- 大富翁
	,["Config_MonopolyMapsData"] = "config.monopoly_maps_data"
	,["Config_MonopolyDungeonsData"] = "config.monopoly_dungeons_data"
	-- 精灵召唤
	,["Config_HolidaySpriteLotteryData"] = "config.holiday_sprite_lottery_data"
	-- 新手训练营
	,["Config_TrainingCampData"] = "config.training_camp_data"
	--巅峰竞技场
	,["Config_ArenaPeakChampionData"] = "config.arena_peak_champion_data"
	-- 段位赛战令
	,["Config_ArenaEliteWarOrderData"] = "config.arena_elite_war_order_data"
	-- 位面冒险
	,["Config_SecretDunData"] = "config.secret_dun_data"
	-- 位面冒险改版
	,["Config_PlanesData"] = "config.planes_data"
	--年兽活动
	,["Config_HolidayNianData"] = "config.holiday_nian_data"

	,["Config_HolidayPersonalFireGiftData"] = "config.holiday_personal_fire_gift_data"
	-- 新年投资返还钻石
	,["Config_HolidayChargeRebateData"] = "config.holiday_charge_rebate_data"
	-- 定时领奖活动
	,["Config_HolidayTimeAwardData"] = "config.holiday_time_award_data"
	-- 位面战令
	,["Config_PlanesWarOrderData"] = "config.planes_war_order_data"
	-- 订阅特权
	,["Config_SubscriberData"] = "config.subscriber_data"
	--战力飞升礼包（0.1元礼包）
	,["Config_HolidayDimeData"] = "config.holiday_dime_data"
	--女神试炼
   ,["Config_HolidayValentineBossData"] = "config.holiday_valentine_boss_data"
	--自选召唤数据
	,["Config_RecruitHolidayLuckyData"] = "config.recruit_holiday_lucky_data"
	--活动推送页
	,["Config_HolidayRolePushData"] = "config.holiday_role_push_data"
	-- 扫一扫功能
	,["Config_QrcodeData"] = "config.qrcode_data"
	--新人练武场
	,["Config_HolidayPractiseTowerData"] = "config.holiday_practise_tower_data"
}

-- 初始化加载的png
PLIST_LIST = {
	"resource/common/common"
	,"resource/mainui/mainui"
	-- ,"resource/common/num" 
}

SOUND_EFFECT_LIST = {
	"sound/common/c_get.mp3"
	, "sound/common/c_levelup.mp3"
	, "sound/common/c_get02.mp3"
	, "sound/common/c_002.mp3"
	, "sound/common/c_close.mp3"
	, "sound/common/c_button1.mp3"
	, "sound/battle/b_win.mp3"
}

SCENE_MUSIC_LIST = {
	-- "sound/scene/s_002.mp3",
	-- "sound/battle/b_002.mp3"
}
