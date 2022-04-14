--
-- Author: LaoY
-- Date: 2018-07-11 19:09:16
-- RequireConfig

require("game/config/language/ConfigLanguage")
require("game/config/client/RequireClientConfig")

--###以下配置自动生成####--
--协议号
require("proto/proto")

--以下单独打包
--############################################
--物品配置信息
require("game.config.auto.item.db_item")
--礼包
require('game.config.auto.item_gift.db_item_gift')

-- 怪物
require("game.config.auto.creep.db_creep")
require("game.config.auto.creep_attr.db_creep_attr")

--任务
require("game.config.auto.task.db_task")
--运营活动
require("game.config.auto.yunying.db_yunying");
require("game.config.auto.yunying_reward.db_yunying_reward");
require("game.config.auto.db_yunying_lottery_shop");

--节日活动
require("game.config.auto.festival_reward.db_festival_reward");
require("game.config.auto.festival.db_festival");

--活动
require('game.config.auto.activity.db_activity')

--新手指引
require('game.config.auto.guide.db_guide')
require('game.config.auto.guide_step.db_guide_step')

-- 寻宝
require('game.config.auto.yunying_lottery_rewards.db_yunying_lottery_rewards')

--功能解锁提示
require('game.config.auto.sysopen.db_sysopen')
--############################################

--以下全部打到同一个包
--获得或使用物品/经验时的途径
require("game/config/auto/logConsume")
--错误码
require("game/config/ignore_error")
require("game/config/auto/errno")
require("game/config/auto/msgno")

-- 技能表
require("game/config/auto/db_skill")
require("game/config/auto/db_skill_level")
require("game/config/auto/db_skill_show")
require("game/config/auto/db_skill_recommend")
require("game/config/auto/db_skill_pos")
require("game/config/auto/db_skill_get")
require("game/config/auto/db_talent")

-- 场景相关 怪物、NPC 场景信息等
require("game/config/auto/db_scene")
require("game/config/auto/db_npc")

require("game/config/auto/db_role_level")

--背包配置信息
require("game/config/auto/db_bag")
require("game/config/auto/db_voucher")
--物品类型配置表  
require("game/config/auto/db_item_type")
--装备配置信息
require("game/config/auto/db_equip")
-- 跑环任务奖励
require("game/config/auto/db_task_loop")

--任务章节栏
require("game/config/auto/db_task_jump")


--强化限制
require("game/config/auto/db_equip_strength_limit")
--强化
require("game/config/auto/db_equip_strength")
--强化套装
require("game/config/auto/db_equip_strength_suite")
--装备分数
require("game/config/auto/db_equip_score")
--宝石配置表
require("game/config/auto/db_stone")
--宝石镶嵌孔表
require("game/config/auto/db_stones_hole")
--晶石配置表
require("game/config/auto/db_spar")
--晶石镶嵌孔表
require("game/config/auto/db_spar_unlock")
--属性类型表
require("game/config/auto/db_attr_type")
require('game/config/auto/db_equip_suite')
require('game/config/auto/db_equip_suite_make')
require("game/config/auto/db_equip_suite_level")
require("game/config/auto/db_equip_set")
require('game/config/auto/db_equip_smelt')
require('game/config/auto/db_equip_cast')
require('game/config/auto/db_equip_cast_limit')
require('game/config.auto/db_equip_refine')
require('game/config.auto/db_equip_refine_attr')
require('game/config.auto/db_equip_refine_score')
require('game/config.auto/db_equip_refine_other')

--培养
require("game/config/auto/db_mount")
require("game/config/auto/db_mount_train")
require("game/config/auto/db_mount_morph")
require("game/config/auto/db_mount_star")
require("game/config/auto/db_wing")
require("game/config/auto/db_wing_morph")
require("game/config/auto/db_wing_star")
require("game/config/auto/db_talis")
require("game/config/auto/db_talis_morph")
require("game/config/auto/db_talis_star")
require("game/config/auto/db_weapon")
require("game/config/auto/db_weapon_morph")
require("game/config/auto/db_weapon_star")
require("game/config/auto/db_weapon_train")
require("game/config/auto/db_wing_train")
require("game/config/auto/db_talis_train")

--队伍
require('game.config.auto.db_team_target')
require('game.config.auto.db_team_target_sub')

require("game/config/auto/db_boss")
require("game/config/auto/db_boss_local")

require('game/config/auto/db_game');

--合成配置目录
require('game.config.auto.db_equip_combine')
require('game.config.auto.db_equip_combine_type')
require('game.config.auto.db_equip_combine_sec_type')
require('game.config.auto.db_equip_combine_thr_type')
require('game.config.auto.db_equip_combine_type_set')
require('game.config.auto.db_equip_combine_lock')

require('game.config.auto.db_equip')

--商城
require('game.config.auto.db_mall')
require('game.config.auto.db_mall_type_name');
require('game.config.auto.db_beast_limit')

require('game/config/auto/db_dunge');
require('game.config.auto.db_dunge_coin');
require('game.config.auto.db_dunge_wave');
require('game.config.auto.db_dunge_couple');
require('game.config.auto.db_dunge_couple_question');

--觉醒
require('game.config.auto.db_wake')
require('game.config.auto.db_wake_step')
require('game.config.auto.db_wake_grid')
require('game.config.auto.db_wake_task_icon')

-- buff
require('game.config.auto.db_buff')

-- 小地图
-- require('game.config.auto.db_map')

--VIP
require('game.config.auto.db_vip_card')
require('game.config.auto.db_vip_level')
require('game.config.auto.db_vip_rights')
require('game.config.auto.db_vip_show')
require('game.config.auto.db_vip_mcard')
require('game.config.auto.db_vip_invest')
require('game.config.auto.db_vip_invest_reward')


-- 头衔
require('game.config.auto.db_jobtitle')

--寻宝
require('game.config.auto.db_searchtreasure_batch')
require('game.config.auto.db_searchtreasure_rewards')

require('game.config.auto.db_guild')
require('game.config.auto.db_guild_perm')
require('game.config.auto.db_guild_exch')

--魔法塔
require('game.config.auto.db_dunge_magic');
require('game.config.auto.db_dunge_magic_loto')

--魔法卡
require('game.config.auto.db_magic_card');
require('game.config.auto.db_magic_card_combine');
require('game.config.auto.db_magic_card_pos');
require('game.config.auto.db_magic_card_strength');
require('game.config.auto.db_magic_card_suite');
require('game.config.auto.db_magic_card_handbook');

--称号
require('game.config.auto.db_title')
require('game.config.auto.db_title_menu')

--过滤字
require('game.config.auto.db_filter_words')

-- 魔法塔寻宝
require('game.config.auto.db_mchunt')
require('game.config.auto.db_mchunt_reward')
require('game.config.auto.db_mchunt_out')

--时装
require('game.config.auto.db_fashion')
require('game.config.auto.db_fashion_type')
require('game.config.auto.db_fashion_star')


--市场
require('game.config.auto.db_market_item')
require('game.config.auto.db_market_stype')
require('game.config.auto.db_market_type')
require('game.config.auto.db_market_sell')

--赠礼
require('game.config.auto.db_flower')
require('game.config.auto.db_flower_honey')

--天书
require('game.config.auto.db_target')
require('game.config.auto.db_target_task')

--神兽
require('game.config.auto.db_beast');
require('game.config.auto.db_beast_equip');
require('game.config.auto.db_beast_reinforce');
require('game.config.auto.db_beast_reinforce_mul');
require('game.config.auto.db_beast_summon');
require("game.config.auto.db_beast_equip_score");


-- 恶魔/天使配置
require('game.config.auto.db_fairy');

--日常
require('game.config.auto.db_daily');
require('game.config.auto.db_daily_reward')
require('game.config.auto.db_daily_show')
require('game.config.auto.db_weekly_ad')
require('game.config.auto.db_weekly')
require('game.config.auto.db_weekly_reward')

--福利
require('game.config.auto.db_welfare_type')
require('game.config.auto.db_welfare_sign_count')
require('game.config.auto.db_welfare_sign_reward')
require('game.config.auto.db_welfare_online_reward')
require('game.config.auto.db_welfare_level_reward')
require('game.config.auto.db_welfare_power_reward')
require('game.config.auto.db_welfare_notice_reward')
require('game.config.auto.db_welfare_res_reward')
require('game.config.auto.db_welfare_grail_cost')
require('game.config.auto.db_welfare_grail_reward')
require('game.config.auto.db_welfare_grail_reward_exp')

require('game.config.auto.db_daily_show')

--排行榜配置
require('game.config.auto.db_rank')
require('game.config.auto.db_rank_group')
require('game.config.auto.db_rank_active')

--护送
require('game.config.auto.db_escort')
require('game.config.auto.db_escort_product')
require('game.config.auto.db_escort_road')

--充值
require('game.config.auto.db_recharge')
--乱斗战场
require('game.config.auto.db_melee');
require('game.config.auto.db_melee_damage')
require('game.config.auto.db_melee_score')
require('game.config.auto.db_melee')
require('game.config.auto.db_exp_acti_base')

--糖果屋
require('game.config.auto.db_candyroom')
require('game.config.auto.db_candyroom_exp')
require('game.config.auto.db_candyroom_gift')
require('game.config.auto.db_candyroom_reward')
require('game.config.auto.db_candyroom_task')

--公会战
require('game.config.auto.db_guildwar_victory_reward')

--特效配置
require('game.config.auto.db_effect')
--GPU数据
require('game.config.auto.db_phone_gpu')
--7日签到
require('game.config.auto.db_yylogin')
--挂机
require('game.config.auto.db_afk')
require('game.config.auto.db_afk_map')
--loading配置
require("game/config/auto/db_loading");
require("game/config/auto/db_loading_text");

--UI上角色展示参数
require("game.config.auto.db_ui_role");

-- 活动提示
require("game.config.auto.db_activity_tip");
require("game.config.auto.db_world_level");

--运营活动
require("game.config.auto.db_yunying_gift");

--成就
require("game.config.auto.db_achieve");
require("game.config.auto.db_achieve_group");
require("game.config.auto.db_achieve_page");

--宠物
require("game.config.auto.db_pet")
require("game.config.auto.db_pet_strong")
require("game.config.auto.db_pet_evolution")
require("game.config.auto.db_pet_compose")
require("game.config.auto.db_pet_equip")
require("game.config.auto.db_pet_equip_score")
require("game.config.auto.db_pet_equip_strength")
require("game.config.auto.db_pet_equip_suite")

--副手
require("game/config/auto/db_offhand");
require("game/config/auto/db_offhand_morph");
require("game/config/auto/db_offhand_star");
require("game/config/auto/db_offhand_train");

require("game.config.auto.db_area_scene")

--变强
require("game.config.auto.db_stronger")

-- 声音配置
require("game.config.auto.db_music_type")

--幻化技能配置
require("game/config/auto/db_skill_system_show");

--首充
require("game.config.auto.db_firstpay")

--0.1元首充
require("game.config.auto.db_firstpay_dime")

--充值活动
require("game.config.auto.db_actpay")
require("game.config.auto.db_actpay_reward")

--帮会驻地
require('game.config.auto.db_guild_question')
require('game.config.auto.db_guild_question_reward')
require('game.config.auto.db_guild_house_boss')
require('game.config.auto.db_guild_house_kill')

require("game/config/auto/db_dunge_mount_star_reward");
require("game/config/auto/db_dunge_mount_sweep");
require("game/config/auto/db_dunge_mount_clear_reward");

--悬赏令
require('game.config.auto.db_wanted')


--竞技场
require('game.config.auto.db_arena')
require('game.config.auto.db_arena_high_rank')
require('game.config.auto.db_arena_rank')
require('game.config.auto.db_arena_top_rank')
require('game.config.auto.db_arena_stimulate')
require('game.config.auto.db_arena_challenge')


--帮派红包
require('game.config.auto.db_guild_redenvelope_task')
require('game.config.auto.db_guild_redenvelope')

--表情
require('game.config.auto.db_emoji')

--广告
require('game.config.auto.db_advertise')

--结婚
require('game.config.auto.db_dating_tag')
require('game.config.auto.db_marriage_step')
require('game.config.auto.db_marriage')
require('game.config.auto.db_marriage_type')
require('game.config.auto.db_marriage_ring')
require('game.config.auto.db_marriage_hot')

require('game.config.auto.db_faker')

require("game.config.auto.db_creep_born");

--找回
require('game.config.auto.db_findback')

--巅峰1v1
require('game.config.auto.db_combat1v1')
require('game.config.auto.db_combat1v1_group')
require('game.config.auto.db_combat1v1_local_grade')
require('game.config.auto.db_combat1v1_local_limit')
require('game.config.auto.db_combat1v1_local_merit_reward')
require('game.config.auto.db_combat1v1_local_join_reward')
require('game.config.auto.db_combat1v1_local_goal_reward')
require('game.config.auto.db_combat1v1_cross_grade')
require('game.config.auto.db_combat1v1_cross_limit')
require('game.config.auto.db_combat1v1_cross_merit_reward')
require('game.config.auto.db_combat1v1_cross_join_reward')
require('game.config.auto.db_combat1v1_cross_goal_reward')


--勇者祭坛
require('game.config.auto.db_warrior_floor')
require('game.config.auto.db_warrior_reward')

--子女系统
require('game.config.auto.db_baby')
require('game.config.auto.db_baby_level')
require('game.config.auto.db_baby_order')
require('game.config.auto.db_baby_equip')
require('game.config.auto.db_baby_equip_level')
require('game.config.auto.db_baby_like_reward')


--神灵系统
require('game.config.auto.db_god')
require('game.config.auto.db_god_morph')
require('game.config.auto.db_god_star')
require('game.config.auto.db_god_train')
require('game.config.auto.db_god_equip')
require('game.config.auto.db_god_equip_level')
require('game.config.auto.db_god_equip_open')

--铸造小屋
require('game.config.auto.db_casthouse')
require('game.config.auto.db_casthouse_grid')
require('game.config.auto.db_proba_tip')

--公会守卫
require("game/config/auto/db_guild_guard_rank");

-- 资源缩放
require("game/config/auto/db_res_scale");
--圣痕秘境
require('game.config.auto.db_dunge_soul')
require('game.config.auto.db_dunge_soul_morph')
require('game.config.auto.db_soul_show')

--圣痕
require("game.config.auto.db_soul")
require("game.config.auto.db_soul_pos")
require("game.config.auto.db_soul_combine")
require("game.config.auto.db_soul_level")

-- 版号描述
require("game.config.auto.db_version_num")

-- 预下载配置
require("game.config.auto.db_res_load")

--本地跑马灯
require('game.config.auto.db_marquee')

--坐骑高度
require('game.config.auto.db_mount_high')


--限时爬塔
require('game.config.auto.db_yunying_dunge_limit_tower')

-- 神灵副本
require('game.config.auto.db_dunge_god')

require('game.config.auto.db_task_tip')
require('game.config.auto.db_task_tip_exp')
require('game.config.auto.db_task_tip_fight')

--快捷购买
require("game.config.auto.db_quick_buy");

--图鉴系统
require("game.config.auto.db_illustration_combination");
require("game.config.auto.db_illustration_menu");
require("game.config.auto.db_illustration_star");
require("game.config.auto.db_illustration");


--钻石擂台
require("game.config.auto.db_compete_battle_reward");
require("game.config.auto.db_compete_guess");
require("game.config.auto.db_compete_match");
require("game.config.auto.db_compete_misc");
require("game.config.auto.db_compete_rank_reward");

--机器人装饰配置
require("game.config.auto.db_robot_deco");

require('game.config.auto.db_timeboss')
require('game.config.auto.db_timeboss_box_reward')

--机甲竞速
require('game.config.auto.db_dunge_race_path')
require('game.config.auto.db_dunge_race_reward')
require('game.config.auto.db_dunge_race_conmand')

require('game.config.auto.db_actinvest_reward')
require('game.config.auto.db_actinvest')

require('game.config.auto.db_revive_help')


--实名
require('game.config.auto.db_realname')
require('game.config.auto.db_realname_time')

-- 宝宝 子女 翅膀
require('game.config.auto.db_baby_wing_morph')
require('game.config.auto.db_baby_wing_star')


--机甲
require('game.config.auto.db_mecha')
require('game.config.auto.db_mecha_equip')
require('game.config.auto.db_mecha_equip_level')
require('game.config.auto.db_mecha_equip_open')
require('game.config.auto.db_mecha_star')
require('game.config.auto.db_mecha_upgrade')

--夺城战
require('game.config.auto.db_siegewar_boss')
require('game.config.auto.db_siegewar_medal_reward')
require('game.config.auto.db_siegewar_order_show')
require('game.config.auto.db_siegewar_box_reward')
require('game.config.auto.db_siegewar_belong_reward')

--星之王座
require('game.config.auto.db_throne_boss')

--大富豪
require('game.config.auto.db_yunying_richman')
require('game.config.auto.db_yunying_richman_luck')
require('game.config.auto.db_yunying_richman_round')

--跨服工会战
require('game.config.auto.db_cgw_monthly_reward')
require('game.config.auto.db_cgw_weekly_reward')

--幸运转盘
require('game.config.auto.db_yunying_luckywheel')

--超值礼包
require('game.config.auto.db_direct_purchase')

--小贵族
require('game.config.auto.db_vip2_level')
require('game.config.auto.db_vip2_card')
require('game.config.auto.db_welfare_online2_reward')

--神器
require('game.config.auto.db_artifact_element')
require('game.config.auto.db_artifact_reinf')
require('game.config.auto.db_artifact_enchant')
require('game.config.auto.db_artifact_unlock')

--限时寻宝
require('game.config.auto.db_artifact_treasure')

--图腾
require('game.config.auto.db_totems')
require('game.config.auto.db_totems_equip')
require('game.config.auto.db_totems_equip_score')
require('game.config.auto.db_totems_reinforce')
require('game.config.auto.db_totems_summon')

--翻牌好礼
require('game.config.auto.db_yunying_flop_gift')