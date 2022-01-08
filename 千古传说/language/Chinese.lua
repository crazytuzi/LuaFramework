local Index = require('language.textIndex')
local texts = {}

texts[Index.OK]                                                        = '操作成功，无错误'
texts[Index.parameter_error]                                           = '参数错误'
texts[Index.unknow_exception]                                          = '异常错误'

--*****************阵形********************
texts[Index.fully]                                                     = '阵位已满'
texts[Index.unit_not_found]                                            = '找不到神灵'
texts[Index.idnex_closed]                                              = '该位置未开放'
texts[Index.player_must_in]                                            = '玩家必须上阵'
texts[Index.unit_must_be_unique]                                       = '同一时间不可以上阵两个同类角色'
texts[Index.at_less_one_in_war_side]                                   = '至少一人上阵'
texts[Index.bloody_unit_min_level]                                     = '角色等级低于10级，不能参加群仙涿鹿'

--*****************战斗********************
texts[Index.battle_not_found]                                          = '找不到战斗实例'
texts[Index.invalidate_battle_code]                                    = '无效的战斗代码，战斗代码是每次战斗开始发送到客户端，一个战斗代码只能够一次有效'
texts[Index.no_challenge_times]                                        = '体力已用完'
texts[Index.max_daily_buy_challenge_times]                             = '今日购买次数已达上限'

--*********************战斗校验****************
texts[Index.invalidate_round_count]                                    = '非法回合数'
texts[Index.fight_action_list_is_null]                                 = '战斗行为链表为空'
texts[Index.fight_action_list_is_empty]                                = '战斗行为链表中没有任何数据'
texts[Index.invalidate_action_from_position]                           = '非法的行为发起位置'
texts[Index.invalidate_action_target_position]                         = '非法的行为目标位置'
texts[Index.target_unit_not_found]                                     = '目标角色找不到'
texts[Index.action_unit_not_found]                                     = '行为角色找不到'
texts[Index.invalidate_unit]                                           = '非法行动角色'
texts[Index.unit_already_die]                                          = '角色已经死亡'
texts[Index.target_list_count_is_empty]                                = '目标列表为空'
texts[Index.invalidte_target_list_count]                               = '无效目标个数'
texts[Index.invalidate_target_unit]                                    = '非法目标角色'
texts[Index.invalidate_normal_attack_effect_value]                     = '非法普通攻击效果数值'
texts[Index.have_not_learn_spell]                                      = '没有学会该技能'
texts[Index.can_not_cast_spell_yet]                                    = '还未能够释放技能'
texts[Index.not_enough_energy]                                         = '没有足够的战意'
texts[Index.battle_already_end]                                        = '战斗已经结束'
texts[Index.invalidate_spell_effect_value]                             = '非法技能效果数值'
texts[Index.spell_state_rate_is_zero]                                  = '技能给予状态的概率为0'
texts[Index.have_not_state_for_19]                                     = '身上没有反弹伤害的状态'
texts[Index.invalidate_passive_effect_value]                           = '无效的被动效果值'
texts[Index.invalidate_active_effect_value]                            = '无效的主动效果值'
texts[Index.limit_to_cast_spell]                                       = '限制使用技能'

--*******************推图*****************
texts[Index.section_template_not_found]                                = '找不到章节信息'
texts[Index.section_template_npc_conf_error]                           = '关卡中NPC配置信息错误，数据异常'
texts[Index.pve_not_enough_challenge_times]                            = '挑战次数不足'
texts[Index.prev_chapter_not_passed]                                   = '前置章节尚未通关，无法挑战'
texts[Index.prev_section_not_passed]                                   = '前置关卡尚未通关，无法挑战'
texts[Index.chapter_template_not_found]                                = '找不到章节模板数据对象'
texts[Index.prev_difficulty_not_passed]                                = '只有完成普通难度才可以挑战宗师难度'
--texts[Index.chapter_record_not_found]                                  = '章节通关信息未能找到，您没有该章节的通关记录'
texts[Index.chapter_record_not_found]                                  = '未到达三星的关卡不能扫荡'
texts[Index.difficulty_record_not_found]                               = '章节特定难度通关信息未能找到，您没有该章节特定难度的通关记录'
texts[Index.chapter_box_not_found]                                     = '找不到对应的宝箱'
texts[Index.chapter_many_pass]                                         = '无法扫荡'
texts[Index.not_enough_star_number]                                    = '没有足够的星星数量'
texts[Index.already_open_box]                                          = '已经开启过该宝箱'
texts[Index.reward_configure_not_found]                                = '找不到奖励配置'
texts[Index.not_enough_player_level]                                   = '等级不足'

--******************物品*******************
texts[Index.hold_goods_not_found]                                      = '持有物品不存在'
texts[Index.goods_template_not_found]                                  = '没有该物品的数据模版'
texts[Index.package_fully]                                             = '背包已满'
texts[Index.not_equip]                                                 = '不是装备'
texts[Index.index_not_empty]                                           = '该位置已经放置了物品'
texts[Index.different_goods_instance]                                  = '不同的持有物品实例'
texts[Index.different_goods_template]                                  = '不同类型的物品'
texts[Index.equip_not_found]                                           = '找不到装备'
texts[Index.can_not_equip]                                             = '不可装备'
texts[Index.inval_position]                                            = '非法装备位'
texts[Index.broken]                                                    = '装备损坏'
texts[Index.package_not_found]                                         = '找不到背包'
texts[Index.excetpion]                                                 = '异常'
texts[Index.not_enough_hold_goods]                                     = '没有足够的物品'
texts[Index.intensify_data_not_found]                                  = '找不到强化数据'
texts[Index.hold_equip_gem_solt_is_all_opend]                          = '装备所有宝石孔都已经开启，不能再开启新的宝石孔'
texts[Index.out_of_hold_equip_gem_solt_index_bound]                    = '宝石孔索引越界'
texts[Index.unmosaic_gem_fail]                                         = '拆解宝石失败'
texts[Index.can_not_mosaic_same_gem_type_in_one_equip]                 = '同一件装备不能镶嵌两个相同类型的宝石'
texts[Index.invalid_sell_number]                                       = '非法出售物品个数'
texts[Index.forging_scroll_not_found]                                  = '无法找到锻造卷轴,您在背包中没有对应的锻造卷轴'
texts[Index.is_not_forging_scroll]                                     = '该物品不是锻造卷轴'
texts[Index.forging_product_template_not_found]                        = '锻造产出物品数据无法找到，数据缺失'
texts[Index.unit_not_enough_level]                                     = '等级不够'
texts[Index.already_equiped]                                           = '您已经装备了该物品'
texts[Index.out_of_max_intensify_level_bounds]                         = '不能再强化，等级已经达到最大强化等级'
texts[Index.can_not_intensify_level_lager_than_player_level]           = '强化等级不能超过玩家角色等级'
texts[Index.not_prop]                                                  = '不是道具，不能单独使用'
texts[Index.can_not_refining]                                          = '您装备属性已经达到最高，无法精炼'
texts[Index.must_set_dog_foods]                                        = '吞噬目标不能为空'
texts[Index.already_max_star_level]                                    = '当前装备星级已经达到最高'
texts[Index.can_not_be_use]                                            = '物品不可使用'
texts[Index.data_change_and_error]                                     = '数据更改并且出现非法错误'
texts[Index.can_not_merge_equipment]                                   = '不可合成装备'

--******************登陆/注册*******************
texts[Index.inval_uid]                                                 = '非法UID'
texts[Index.name_null]                                                 = '用户名称为空'
texts[Index.inval_name_length]                                         = '用户名称长度错误，太长或者太短'
texts[Index.inval_sex]                                                 = '非法性别'
texts[Index.inval_profession]                                          = '非法职业'
texts[Index.inval_camp]                                                = '非法阵营'
texts[Index.inval_hometown]                                            = '非法出生地'
texts[Index.regit_close]                                               = '注册功能关闭'
texts[Index.db_exception]                                              = '数据库操作错误'
texts[Index.error]                                                     = '操作异常'
texts[Index.duplicate_key]                                             = '此名字已被占用，请换一个！'
texts[Index.db_connect_fail]                                           = '数据库连接异常'
texts[Index.plyaer_not_found]                                          = '找不到玩家信息'
texts[Index.player_not_belong_account]                                 = '角色不属于帐号所有'
texts[Index.invalidate_validate_code]                                  = '无效验证码'
texts[Index.player_list_is_fully]                                      = '不能再创建角色'
texts[Index.player_invalide_name]                                      = '对不起，名称含有敏感词汇'
texts[Index.player_same_name]                                          = '对不起，名称不能与原名相同'
texts[Index.server_refuse_service]                                     = '服务器暂时拒绝服务'
texts[Index.regist_player_already_max]                                 = '注册人数已达到上限，请更换服务器'
texts[Index.online_number_already_max]                                 = '在线人数已满，请稍后再尝试或者更换服务器登录'
texts[Index.server_is_maintenance]                                     = '服务器处于维护中，请耐心等待'
texts[Index.server_open_time_is_not]                                   = '服务器开放时间未到，请耐心等待'
texts[Index.GAG]                                   					   = '您已被禁止发言'
texts[Index.BAN]                                   					   = '您已被禁止登陆，如有疑问可联系客服'

--*****************玩家********************
texts[Index.player_not_found]                                          = '找不到玩家'
texts[Index.not_enough_coin]                                           = '没有足够的铜币'
texts[Index.not_enough_sycee]                                          = '没有足够的元宝'
texts[Index.not_enough_inspiration]                                    = '没有足够的真气'
texts[Index.not_enough_team_exp]                                       = '没有足够的团队经验'
texts[Index.not_enough_role_exp]                                       = '没有足够的角色经验'
texts[Index.not_enough_arena_score]                                     = '积分不足'
texts[Index.not_enough_vip_score]                                      = '没有足够的VIP积分'
texts[Index.not_enough_errantry]                                       = '没有足够的功德'
texts[Index.not_enough_recruit_integral]                               = '没有足够的结缘积分'
texts[Index.not_enough_jinglu]                                         = '没有足够的精露，可前往下层幻境获取'
texts[Index.not_enough_res]                                     	   = '没够足够资源'
texts[Index.not_enough_team_level]                                     = '团队等级不足'
texts[Index.not_enough_body_strength]                                  = '没有足够的体力'
texts[Index.player_offline]                                            = '玩家不在线'
texts[Index.vip_level_too_low]                                         = '玩家vip等级不足'
texts[Index.not_enough_soul_card]                                      = '没有足够的精魄'
texts[Index.pusle_max_level]                                           = '该品质的经脉达到最大等级'
texts[Index.pusle_max_quality]                                         = '五行已经达到最高品质'
texts[Index.pusle_not_max_level]                                       = '五行未达到最高等级'
texts[Index.player_name_existed]                                       = '该名称已经存在'
texts[Index.sensitive_word]                                            = '文本中含有敏感词汇'
texts[Index.vip_level_reward_reced]                                    = '玩家vip等级奖励已领取过'
texts[Index.have_to_wait]											   = '您仍然需要等待一段时间，才可以进行此操作'

--*******************角色培养******************
texts[Index.role_train_unit_not_found]                                 = '找不到角色'
texts[Index.soul_card_and_card_can_not_be_null]                        = '上仙，您没有添加修炼材料！'
texts[Index.not_enough_star_level]                                     = '星级不足'
texts[Index.can_not_surmount]                                          = '不能突破'
texts[Index.role_already_max_star_level]                               = '已经是最高星级'
texts[Index.already_best_quality]                                      = '已经是最高品阶，无法继续提升'
texts[Index.profession_not_found]                                      = '找不到角色职业'
texts[Index.already_has_unit_instance]                                 = '你已经拥有该角色'
texts[Index.exp_already_max]                                           = '角色经验已经达到上限'
texts[Index.can_not_practice]                                          = '不可修炼'
texts[Index.role_is_Practice]                                          = '该神灵正在被使用'
texts[Index.role_is_assist]                                            = '该神灵正在被使用'

--********************竞技场*****************
texts[Index.arena_player_not_found]                                    = '找不到玩家'
texts[Index.arena_can_not_challenge_youself]                           = '不能挑战自己'
texts[Index.arena_not_enough_challenge_times]                          = '没有足够的挑战次数'

--********************铜人阵（废弃）*****************
texts[Index.eq_not_enough_challenge_times]                             = '当日挑战次数已用完'
texts[Index.have_not_reward]                                           = '没有任何可领取的奖励'
texts[Index.have_not_challenge_record]                                 = '没有任何挑战记录'
texts[Index.stage_npc_can_not_create]                                  = '关卡中npc设置错误，无法创建npc'
texts[Index.have_not_attribute_choice]                                 = '没有可以选择的属性'
texts[Index.can_not_refresh_attribute]                                 = '不能刷新属性'

--***********************无量山**************
texts[Index.climb_not_enough_challenge_times]                          = '今日挑战次数已用完'
texts[Index.invalid_section]                                           = '非法关卡'
texts[Index.climb_section_template_not_found]                          = '找不到关卡配置信息'
texts[Index.section_template_data_error]                               = '关卡配置出现错误'
texts[Index.max_history_extra_challenge_times]                         = '额外的挑战次数已达上限'
texts[Index.wannneg_max_battle_challenge_time]                         = '副本挑战次数已超过今日上限'
texts[Index.wannneg_battle_can_not_challenge_today]                    = '现在不能挑战'
texts[Index.wannneg_battle_no_challenge_time_today]                    = '今日挑战次数已用完'
texts[Index.wannneg_battle_cool_time]                                  = '挑战冷却时间还未结束'

--*********************仙盟（废弃）****************
texts[Index.player_has_league]                                         = '玩家已经拥有仙盟'
texts[Index.league_existed]                                            = '该仙盟已存在'
texts[Index.league_not_existed]                                        = '该仙盟不存在'
texts[Index.not_in_same_league]                                        = '玩家不在同一个仙盟'
texts[Index.not_league_member]                                         = '不是仙盟成员'
texts[Index.leader_cannot_quit_league]                                 = '盟主不能退出仙盟'
texts[Index.not_league_leader]                                         = '没有盟主权限'
texts[Index.not_league_manager]                                        = '没有仙盟管理权限'
texts[Index.cannot_invite_myself]                                      = '不能邀请自己'
texts[Index.no_invite]                                                 = '邀请不存在或者已过期'
texts[Index.player_has_apply]                                          = '已有仙盟申请'
texts[Index.player_no_apply]                                           = '没有该仙盟申请'
texts[Index.no_second_leader]                                          = '没有长老'
texts[Index.quit_league_cool_time]                                     = '退出仙盟不满24小时'
texts[Index.no_enough_money]                                           = '仙盟资金不足'
texts[Index.no_enough_offer]                                           = '仙盟成员贡献不足'
texts[Index.goods_building_level_max]                                  = '仙盟贡献建筑已达最高等级'
texts[Index.buff_building_level_max]                                   = '仙盟繁荣建筑已达最高等级'
texts[Index.got_building_goods]                                        = '已领取仙盟贡献建筑物品'
texts[Index.got_buff_today]                                            = '今日仙盟已经领取繁荣建筑BUFF'

--*********************商店****************
texts[Index.shop_entry_not_found]                                      = '商店已刷新，商品条目更新'
texts[Index.shop_count_today_usedup]                                   = '今日购买次数已用完'
texts[Index.shop_count_sum_usedup]                                     = '购买次数已用完'
texts[Index.shop_count_vip_usedup]                                     = 'vip购买次数已用完'
texts[Index.shop_bad_time]                                             = '当前时间不能购买'
texts[Index.shop_error_num]                                            = '不能购买小于1个'
texts[Index.shop_auto_refresh_not_yet]                                 = '自动刷新时间未到'
texts[Index.shop_entry_not_yours]                                      = '您的商店内没有该商品'
texts[Index.shop_max_num]                                              = '购买数量超过上限'
texts[Index.shop_can_not_exhanged]                                     = '不能兑换'
texts[Index.shop_closed]											   = '商城已关闭'

--********************充值*****************
texts[Index.recharge_exist]                                            = '已经存在充值订单'
texts[Index.recharge_fail_unkown]                                      = '下订单失败,原因未知'
texts[Index.recharge_close]                                            = '充值处理关闭状态'
texts[Index.recharge_not_found]                                        = '已经存在充值订单'
texts[Index.recharge_already_finish]                                   = '订单已经完成交易'

--*******************聊天******************
texts[Index.player_offline]                                            = '玩家不在线'
texts[Index.player_no_speak]                                           = '玩家被禁言'
texts[Index.CHAT_PUBLIC]                                               = '等级达到15级或VIP1解锁发言'
texts[Index.CHAT_TIMT]                                                 = '发言频率过快，请稍后再试'
texts[Index.CHAT_CONTENT_SAME]                                         = '请勿发送重复消息'
texts[Index.CHAT_REPORT_SAME]                                          = '请勿重复举报该玩家'

--*********************招募****************
texts[Index.recruit_not_free_but_request_free]                         = '客户端请求免费结缘，但服务器还存在CD时间'

--******************邮件*******************
texts[Index.mail_not_exist]                                            = '邮件不存在'
texts[Index.mail_not_receive]                                          = '邮件不可领取'
texts[Index.mail_had_receive]                                          = '邮件已领取过'
texts[Index.report_not_exist]                                          = '战报数据不存在'
texts[Index.mail_have_attachment_and_not_recive]                       = '邮件附件没有领取不可删除'
texts[Index.mail_is_protected]                                         = '系统邮件有12个小时保护时间，之后才可删除'

--**********************任务/成就***************
texts[Index.mission_not_existed]                                       = '不存在该任务'
texts[Index.mission_not_completed]                                     = '任务未完成'
texts[Index.mission_finished]                                          = '任务已结束'
texts[Index.task_7days_discount_conf_not_found]                              = '打折商品找不到'
texts[Index.task_7days_discount_conf_error]                                  = '打折商品配置错误'
texts[Index.task_7days_discount_sold_out]                                    = '商品已售完'

--********************大宝藏*****************
texts[Index.treasure_can_not_challenge_youself]                        = '不能挑战你自己'
texts[Index.target_is_not_player]                                      = '非法目标，目标不是玩家'
texts[Index.treasure_not_enough_challenge_times]                                = '没有足够的挑战次数'
texts[Index.already_have_excavation]                                   = '你已经占有了一个挖掘点'
texts[Index.max_history_extra_challenge_times]                         = '额外的挑战次数已达上限'
texts[Index.treasure_not_found]                                        = '找不到宝藏'
texts[Index.treasure_box_index_out_of_bound]                           = '索引越界'
texts[Index.prev_open_treasure_is_null]                                = '最后一次打开的宝藏宝箱为空'
texts[Index.treasure_is_not_box]                                       = '宝藏不是宝箱'
texts[Index.treasure_is_not_goods]                                     = '宝藏不是物品'

--*********************活动****************
texts[Index.activity_not_exist]                                        	= '活动不存在'
texts[Index.activity_not_start]                                        	= '活动未开始'
texts[Index.activity_finished]                                         	= '活动已结束'
texts[Index.template_not_found]											= '活动数据查找不到'
texts[Index.not_visiable]												= '活动不可见'
texts[Index.progress_not_found]											= '没有活动进度'
texts[Index.reward_key_not_found]										= '没有该奖励'
texts[Index.not_finish]													= '未完成'
texts[Index.not_enough_got_times]										= '没有足够的领取次数'

--******************技能*******************
texts[Index.already_max_level]                                         = '技能已经达到最大等级'
texts[Index.spell_template_not_found]                                  = '找不到技能数据模板'
texts[Index.have_not_spell_setting]                                    = '角色没有技能配置'
texts[Index.have_not_target_spell]                                     = '角色没有目标技能的设定'
texts[Index.next_level_spell_date_not_found]                           = '找不到下一个等级的技能数据'
texts[Index.not_enough_spell_study_point]                              = '没有足够的技能点'
texts[Index.spell_level_already_max_for_player_level_limit]            = '技能等级已经达到战队等级的最高限制'
texts[Index.spell_level_already_max_for_unit_level_limit]			   = '请提升角色等级后再进行升级'

--*******************奇遇******************
texts[Index.qiyu_dining_time_not]                                      = '不是摘桃时间'
texts[Index.qiyu_dining_dined]                                         = '已摘过仙桃'
texts[Index.qiyu_action_not_act]                                       = '此活动未开始或已结束'
texts[Index.sign_signed]                                               = '今日已签到'

--********************邀请码*****************
texts[Index.not_active_inv_code]                                       = '邀请码活动未开启'
texts[Index.invite_code_not_existed]                                   = '该邀请码不存在'
texts[Index.invite_code_used]                                          = '您已使用过邀请码'
texts[Index.no_this_reward]                                            = '没有该奖励'
texts[Index.has_gotten_this_reward]                                    = '已经领取过该奖励'
texts[Index.no_enough_invite_time_to_get_reward]                       = '邀请次数不足，不能领取该奖励'
texts[Index.invite_can_not_verify_yourself]                            = '对不起，您不能验证自己的邀请码'
texts[Index.invite_fail_level_limit]								   = '您已超过邀请等级'

--*********************月卡****************
texts[Index.contract_no_existed]                                       = '契约不存在'
texts[Index.contract_existed]                                          = '契约已存在'
texts[Index.contract_out_of_date]                                      = '契约已过期'
texts[Index.contract_got_reward_doday]                                 = '今日已领取奖励'
texts[Index.not_active_yue_ka]                                         = '月卡合同未开启'

--**********************护驾***************
texts[Index.escorting_not_enough_challenge_times]                      = '没有足够的挑战次数'
texts[Index.escorting_already_finish]                                  = '本次护驾已经结束'
texts[Index.escorting_have_not_finish]                                 = '护驾尚未结束'
texts[Index.not_enough_level_to_escorting]                             = '你的等级不足以护驾'
texts[Index.escorting_configure_error]                                 = '数据配置错误'
texts[Index.escorting_date_not_found]                                  = '数据配置错误-没有数据配置'
texts[Index.is_waiting]                                                = '冷却中'

--********************群仙涿鹿****************
texts[Index.no_enemy]                                                  = '该关卡还未开启或者不存在'
texts[Index.has_passed_section]                                        = '已通过该关卡，不能再挑战'
texts[Index.not_pass_prevous_section]                                  = '还未通过前一个关卡，不能挑战该关卡'
texts[Index.no_box_item]                                               = '不存在该宝箱条目'
texts[Index.box_item_in_hidden_status]                                 = '宝箱不处不可见状态'
texts[Index.box_item_not_in_can_buy_status]                            = '宝箱不处在可购买状态'
texts[Index.box_item_not_in_free_status]                               = '宝箱不处在可免费获取状态'
texts[Index.daily_inspire_time_used_up]                                = '今日鼓舞次数已经用完'
texts[Index.bloody_unit_all_dead]                                      = '上阵角色已经全部阵亡，不能挑战'
texts[Index.not_enough_bloody_reset_count]							   = '群仙涿鹿重置次数用尽'
texts[Index.not_pass_level]							   				   = '通关关数不足，无法扫荡'

--*******************开服活动（废弃）******************
texts[Index.have_wait_time]                                            = '你还需要等待一定时间'
texts[Index.already_get]                                               = '你已经领取过了该奖励'
texts[Index.not_enough_level]                                          = '你不够等级'
texts[Index.not_enough_times]                                          = '累计次数不够'
texts[Index.not_supported]                                             = '不支持'
texts[Index.reward_not_found]                                          = '好不到奖励'
texts[Index.activity_reward_configure_not_found]                       = '好不到奖励配置信息'
texts[Index.invalidate_request]                                        = '非法请求'
texts[Index.open_activity_not_start]                                   = '活动仍未开始'
texts[Index.open_activity_already_end]                                 = '活动已经结束'

--**********************押镖***************
texts[Index.not_active_yabiao]                                         = '未开启押镖活动'
texts[Index.not_got_reward]                                            = '还未领取上次押镖奖励'
texts[Index.not_in_yabiao_status]                                      = '当前没有押镖'
texts[Index.in_yabiao_status]                                          = '正在押镖中'
texts[Index.no_yabiao_time_today]                                      = '今日押镖次数已用完'
texts[Index.can_not_got_reward]                                        = '没有完成押镖，不能领取奖励'

--**********************礼包******************
texts[Index.already_use]					       = '礼包码已被使用，请更换重试'
texts[Index.invitation_not_found]				       = '礼包码错误，请核查重试'
texts[Index.invitation_package_not_found]			       = '找不到该礼包，请核查重试'
texts[Index.already_use_same_package]				       = '已经领取过该礼包'
texts[Index.time_less_than_package]				       = '未到领取时间'
texts[Index.package_not_start_time]				       = '礼包未开启'
texts[Index.package_out_of_end_time]				       = '礼包已关闭'

--**********************点赞*******************
texts[Index.already_praise_target_player]								= '今日已经赞过该玩家'
texts[Index.not_enough_praise_time] 									= '今日次数已经用完，没有足够的点赞次数'

--*****************掉落********************
texts[Index.drop_group_not_found]                                      = '掉落组找不到'
texts[Index.drop_item_not_found]                                       = '掉落组找不到'
texts[Index.drop_result_is_null_or_empty]                              = '掉落结果为空'

--******************伏魔录*******************
texts[Index.boss_fight_is_not_open]										= '活动未开始'
texts[Index.boss_fight_is_time_out]										= '活动已结束'
texts[Index.boss_fight_is_NOT_ENOUGH_CHALLENGE_TIMES]					= '没有足够的挑战次数'
texts[Index.boss_fight_is_CONFIGURE_NOT_FOUND]							= '找不到配置信息'
texts[Index.boss_fight_is_CONFIGURE_FORMATION_ERROR ]					= '找不到配置信息'

--*****************好友********************
texts[Index.PLAYER_NOT_EXIST]                                                  = '该玩家不存在'
texts[Index.PLAYER_IS_FRIEND]                                                  = '您与该玩家已经是好友'
texts[Index.PLAYER_IS_APPLY]                                                   = '您已向该玩家提出过申请'
texts[Index.FRIEND_APPLY_IS_FULL]                                              = '对方好友申请列表已满'
texts[Index.APPLY_NOT_EXIST]                                                   = '您已经发送过申请'
texts[Index.FRIEND_IS_FULL]                                                    = '您的好友列表已满'
texts[Index.SIDE_FRIEND_IS_FULL]                                               = '对方好友列表已满'
texts[Index.FRIEND_NOT_EXIST]                                                  = '该好友不存在'
texts[Index.NOT_IN_GIVE_TIME]                                                  = '赠送时间未到'
texts[Index.NOT_GIVE]                                                          = '无法领取'
texts[Index.DRAW_FULL]                                                         = '今日领取次数已用尽'
texts[Index.GIVE_FULL]                                                         = '今日赠送次数已用尽'
texts[Index.has_to_Assist]                                                     = '该好友今日已助阵'
texts[Index.Assist_in_FULL]                                                    = '今日接受助阵次数已达上限'
texts[Index.Assist_in_FULL2]                                                   = '今日助阵次数已达上限'


--*****************仙盟********************
texts[Index.NUPTIAL]                                                    = '该名字已存在'
texts[Index.HAS_GUILD]                                                  = '您已经加入仙盟'
texts[Index.APPLY_IS_FULL]                                              = '今日申请数量已达到上限'
texts[Index.APPLY_NOT_EXIST]                                            = '申请对象不存在'
texts[Index.GUILD_IS_FULL]                                              = '仙盟人数已达上限'
texts[Index.MEMBER_HAS_GUILD]                                           = '该玩家已有仙盟'
texts[Index.GUILD_NOT_EXIST]                                            = '仙盟不存在'
texts[Index.PRESIDENT_IMPEACHMENT]                                      = '盟主已被弹劾'
texts[Index.IMPEACHMENT_NO_TIME]                                        = '弹劾时间不足'
texts[Index.DECLARATION_INSUFFICIENT]                                   = '仙盟贡献不足'
texts[Index.HAS_BEEN_INVITED]                                           = '该玩家已被邀请'
texts[Index.NAME_ERROR]                                                 = '名称中含有特殊字符'
texts[Index.PUNISHMENT_TIME]                                            = '该玩家退出仙盟未超过24小时'
texts[Index.NAME_SENSITIVE_WORD]                                        = '名称中含有特殊字符'
texts[Index.MEMBER_EXIT_GUILD]                                          = '成员已经离开仙盟'
texts[Index.MAKED_COUNT_FULL]                                           = '该玩家被结交次数已满'
texts[Index.WORSHIP_FULL]                                               = '仙盟捐献次数已满'
texts[Index.OPEN_NOT_IN_TIME]                                           = '领取时间超时'
texts[Index.ZONE_IS_OPEN]                                               = '副本已被开启'
texts[Index.BOOM_DEFICIENCY]                                            = '威望不足'
texts[Index.ZONE_IS_LOCKED]                                             = '副本已被锁定'
texts[Index.ZONE_RESET]                                                 = '副本已被重置'
texts[Index.ZONE_RESET_FULL]                                            = '副本重置已达上限'
texts[Index.Chest_Upper]                                                = '宝箱领取已达今日上限'


--**********************争霸赛**********************
texts[Index.BATTLE_IS_NOT_START]                                    = '对战未开始或已结束'
texts[Index.NO_PLAYER_CAN_MATCH]                                    = '没有可匹配的玩家'
texts[Index.MATCH_NOT_IN_TIME]                                      = '对战正在冷却中，请稍后再试'
texts[Index.BET_NOT_IN_TIME]                                        = '押注时间已过'

--**********************无量山北窟******************
texts[Index.BEIKU_CAN_NOT_RESET]                                            = '重置次数用尽'
texts[Index.BEIKU_NPC_FORMATION_NOT_FOUND]                                  = '找不到NPC配置信息'
texts[Index.BEIKU_GAME_LEVEL_NOT_FOUND]	                                    = '找不到关卡配置信息'
texts[Index.BEIKU_ALREAY_MAX_GAME_LEVEL]	                                = '没有更多的关卡设定'
texts[Index.BEIKU_INVALIDATE_GAME_LEVEL_ID]	                                = '非法的关卡ID'
texts[Index.BEIKU_CAN_NOT_CHOICE_ATTRIBUTE]                                 = '无法选择该属性'
texts[Index.BEIKU_CHOICE_ATTRIBUTE_NOT_FOUND]                               = '无法选择可使用的属性'
texts[Index.BEIKU_CHOICE_ATTRIBUTE_CONF_NOT_FOUND]                          = '找不到属性选择配置'
texts[Index.BEIKU_ATTRIBUTE_ALREAY_CHOICED]                                 = '已经选择过该属性'
texts[Index.BEIKU_CHOICE_ATTRIBUTE_NOT_VALIDATE]                            = '该属性配置错误'
texts[Index.BEIKU_NOT_ENOUGH_TOKENS]                                        = '没有足够的无量山玉'
texts[Index.BEIKU_HAVE_NOT_CHEST_CAN_OPEN]                                  = '没有可以开启的宝箱'
texts[Index.BEIKU_CHEST_ALREAY_OPEN]                                        = '已经开启过该宝箱'
texts[Index.BEIKU_CHEST_CONFIGURE_IS_NULL]                                  = '宝箱配置为空'
texts[Index.BEIKU_ATTRIBUTE_ALREAY_CHOICED_IS_SKIP]                         = '您已经跳过了鼓舞，不可以再次选择'
texts[Index.BEIKU_CAN_NOT_SWEEP]                                            = '敌人过于强大，无法扫荡'
texts[Index.BEIKU_HAS_NOT_PASS]                                             = '该关卡挑战失败，需要重置无量山北窟'
texts[Index.BEIKU_GET_AND_SWEEP]                                            = '您有宝箱没有领取，请领取后扫荡'    
texts[Index.BEIKU_CHOICE_ATTRIBUTE_AND_SWEEP]                               = '您有属性没有选择，请选择后扫荡'   

--**********************砸蛋******************
texts[Index.EGG_ACTIVITY_IS_NOT_START]                                      = '活动不在开启时间'
texts[Index.EGG_PROP_NOT_ENOUGH]                                            = '砸蛋道具不足'
texts[Index.EGG_REWARD_NOT_FOUND]	                                        = '奖励配置为空'
texts[Index.EGG_NUMBER_ERROR]	                                            = '砸蛋次数错误'
texts[Index.EGG_GOLD_HAMMER_NOT_ENOUGH]	                                    = '金锤子数量不足'
texts[Index.EGG_SILVER_HAMMER_NOT_ENOUGH]	                                = '银锤子数量不足'

--************************采矿*******************
texts[Index.NO_SELECT_FORMATION]											= '至少上阵1个神灵'
texts[Index.NOT_ENOUGH_ROB_TIMES]											= '没有打劫机会了'
texts[Index.NOT_STTATEGY_MINE]												= '没有守矿阵容'
texts[Index.NOT_MINE_PLAYER_IS_LOCK]										= '该玩家正在被打劫'
texts[Index.MINE_Complete]									             	= '该玩家挖矿已经完成'



--************************老玩家回归*******************
texts[Index.regression_Invitation_code_error1]                              = '邀请码有误，请核查后重新输入'
texts[Index.regression_Invitation_code_error2]                              = '邀请码有误，请核查后重新输入'
texts[Index.regression_Invitation_code_error3]                              = '邀请码有误，请核查后重新输入'
texts[Index.regression_Has_returned]                                        = '玩家已经回归，无法召回'
texts[Index.regression_Insufficient_level]                                  = '目标等级不足'
texts[Index.regression_Insufficient_day]                                    = '玩家未登录天数不足'


--***********************雇佣神灵**************************
texts[Index.CAN_NOT_DISPATCH_Hire_a_knight]                                                = '不可派遣'     
texts[Index.IN_THE_GROUP_Hire_a_knight]                                                    = '该神灵已经在队伍中'
texts[Index.NOT_IN_THE_GROUP_Hire_a_knight]                                                = '该神灵不在队伍中'
texts[Index.NOT_VIP_LEVEL_Hire_a_knight]                                                   = 'VIP等级不够'
texts[Index.NOT_TIME_Hire_a_knight]                                                        = '时间不够'
texts[Index.NOT_FOUND_Hire_a_knight]                                                       = '神灵信息刷新，请重新选择'
texts[Index.ALREADY_HIRE_Hire_a_knight]                                                    = '已经雇佣过'
texts[Index.FORMATION_IS_EMPTY_Hire_a_knight]                                              = '佣兵阵形上没有出战角色'




--***********************雇佣队伍**************************
texts[Index.CAN_NOT_DISPATCH_Hiring_team]                                                = '不可派遣' 
texts[Index.NOT_FOUND_Hiring_team]                                                       = '找不到派遣队伍'
texts[Index.IS_NOT_DISPATCH_STATE_Hiring_team]                                           = '不在派遣状态'
texts[Index.NOT_ENOUGH_DISPATCH_TIME_Hiring_team]                                        = '派遣时间不足'
texts[Index.BATTLE_ROLE_IS_EMPTY_Hiring_team]                                            = '上阵角色为空'
texts[Index.HAVE_IN_ROLE_MERCENARY_Hiring_team]                                          = '上阵角色不可以在角色佣兵里面'
texts[Index.ALREADY_HIRE_TEAM_Hiring_team]                                               = '你已经雇佣过这个队伍了'
texts[Index.HIRE_TEAM_NOT_FOUND_Hiring_team]                                             = '找不到已经雇佣的佣兵队伍信息'
texts[Index.HIRE_TEAM_USE_TYPE_NOT_SAME_Hiring_team]                                     = '已经雇佣的佣兵队伍使用 类型不匹配'
texts[Index.HIRE_TEAM_MODIFY_ROLE_MISS_Hiring_team]                                      = '已经雇佣的佣兵队伍阵形角色ID遗失'

--***********************赌石**************************
texts[Index.DUSHI_NOT_ENABLE]                                                            = '未激活'
texts[Index.DUSHI_CONFIGURE_NOT_FOUND]                                                   = '找不到赌石配置'
texts[Index.DUSHI_DROP_GROUP_NOT_FOUND]                                                  = '找不到掉落配置'
texts[Index.DUSHI_DROP_EMPTY]                                                            = '找不到掉落组宝石'
texts[Index.DUSHI_ITEM_LIST_FULLY]                                                       = '宝石栏已满，请拾取后再试'
texts[Index.DUSHI_HAVE_NOT_ITEM]                                                         = '没有可以拾取的宝石'
texts[Index.DUSHI_ITEM_NOT_FOUND]                                                        = '无法拾取该宝石'




--***********************神灵炼体**************************
texts[Index.Refining_the_bodyNo_open]                                                    = '穴位未开启'
texts[Index.Refining_the_bodyLevel_Max]                                                  = '穴位已经突破至满级'
texts[Index.Refining_the_bodyLevel_low]                                                  = '角色经脉等级不能超过角色等级'
texts[Index.Refining_the_bodyNO_Level]                                                   = '角色经脉等级不足'





















------------------------下面是中文提示哈-----------------------

--***********************角色培养**************************
texts[Index.No_Acquisition_Techniques]										= "无可习得秘籍"

--***********************无量山北窟************************
texts[Index.BEIKU_OPEN_NOT_ENOUGH_LEVEL]                                    = "无量山南峰通关%d层开启"
texts[Index.BEIKU_ALL_PASS]                                                 = "已通关北窟所有关卡，请重置"
texts[Index.BEIKU_GET_AND_PASS]                                             = "您有宝箱没有领取，请领取宝箱"

--***********************经脉突破**************************
texts[Index.JINGMAI_SURMOUNT_SUCCESS]                                       = "突破成功，属性成长提升"
texts[Index.JINGMAI_SURMOUNT_FAIL]                                          = "突破失败"
texts[Index.JINGMAI_SURMOUNT_OPEN_NOT_ENOUGH_LEVEL]                         = "无量山南峰通关%d层开启"

--***********************仙盟**************************
texts[Index.No_Permissions]                                                 = '等待盟主/长老开启'
texts[Index.NoT_Enough_Prosperity]                                          = '威望不足'
texts[Index.Everyday_Reset_One_time]                                        = '每日最多重置1次'
texts[Index.Consume_Prosperity_Open]                                        = '是否消耗%d仙盟威望开启'
texts[Index.Consume_Prosperity_Reset]                                       = '是否消耗%d仙盟威望重置'
texts[Index.Zone_Reset_Suceess]                                        		= '重置成功'
texts[Index.Zone_Open_Suceess]                                       		= '开启成功'
texts[Index.Zone_time_out_two_minute]                                 		= '大侠，最多在挑战界面停留%d分钟'
texts[Index.Zone_time_out_ten_second]                                 		= '大侠，最多在结算界面停留%d秒'
texts[Index.Zone_time_out_ten_minute]                                 		= '大侠，挑战时长最大为%d分钟'
texts[Index.Zone_somebody_attacking]                                 		= '其他玩家正在挑战'
texts[Index.Field_Finish_at_once]                                      		= '是否消耗%d元宝立刻完成修炼?'
texts[Index.Field_Open_Level]                                        		= '玄清洞需要仙盟等级%d级'
texts[Index.Field_Research_skill]                                        	= '是否消耗%d威望研究%d级%s？'
texts[Index.Field_Open_skill]                                            	= '是否消耗%d威望开启%s？'
texts[Index.Field_Research_skill_max_level]                                	= '到达当前最高等级，请提升仙盟等级'
texts[Index.Field_Research_skill_max_level2]                                = '到达最高等级'
texts[Index.Field_Study_skill_no_open]                                      = '需要盟主/长老开启'
texts[Index.Field_Study_skill_max_level]                                    = '到达当前最高等级，请提升研究等级'
texts[Index.Field_No_Permissions]                                           = '只有盟主/长老才能研究'
texts[Index.Guild_flag_modify]                                              = '仙盟旗帜修改成功'
texts[Index.Guild_UI]                                                       = '需要1个仙盟更旗令（剩余：%d）'



--***********************装备重铸**************************
texts[Index.Recast_Unlock1]                                                 = '第一个槽达到破损解锁'
texts[Index.Recast_Unlock2]                                                 = '第二个槽达到瑕疵解锁'
texts[Index.Recast_Unlock3]                                                 = '第三个槽达到完美解锁'
texts[Index.Recast_Unlock4]                                                 = '第四个槽达到神铸解锁'
texts[Index.Recast_Gems]                                                    = '装备重铸2个槽破损解锁'
texts[Index.Recast_Second_Prompt]                                           = '重铸会消耗一件%s，是否确认重铸？'
texts[Index.Recast_Material_shortage]                                       = '请收集%s'
texts[Index.Recast_Used_tool]                                           	= '重铸会消耗一个%s，是否确认重铸？'





--***********************采矿**************************
texts[Index.Mining_Protect_Record1]                                         = '%s雇佣你担当护卫，获得%d佣金'
texts[Index.Mining_Protect_Record2]                                         = '在你担当%s的护卫期间，成功阻止%s的打劫。获得%d额外佣金'
texts[Index.Mining_UI1]                                                     = '本周可选数量：%d'
texts[Index.Mining_UI2]                                                     = '每周每个好友或仙盟成员只能选择一次'
texts[Index.Mining_UI3]                                                     = '与%s战斗%d次，'
texts[Index.Mining_UI3_win]                                                 = '%s前来打劫，与%s战斗%d次，%s打劫成功'
texts[Index.Mining_UI3_lost]                                                = '%s前来打劫，与%s战斗%d次，%s打劫失败'
texts[Index.Mining_UI4_win]                                                 = '%s与%s战斗，战斗胜利'
texts[Index.Mining_UI4_lost]                                                = '%s与%s战斗，战斗失败'
texts[Index.Mining_Nobody]                                                  = '暂时没有挖矿者'
texts[Index.Mining_Reset]                                                   = '是否消耗1次打劫令重置打劫状态？'
texts[Index.Mining_No_Chance]                                               = '打劫令不足'
texts[Index.Mining_No_Protector]                                            = '没有选择护矿者，将更容易受到打劫，是否确认独自采矿'
texts[Index.Mining_Rob_Success]                                             = '打劫%d铜币'
texts[Index.Mining_Dead]                                                    = '没有存活神灵'
texts[Index.Mining_Increase_Frequency]                                      = '打劫令+%d'
texts[Index.Mining_No_Lineup]                                               = '没有布置采矿阵容的玩家'
texts[Index.Mining_No_Rob_frequency]                                        = '缺少打劫令'
texts[Index.Mining_Suffer_Rob]                                              = '该玩家正在被打劫'
texts[Index.Mining_Mining_Complete]                                         = '该玩家挖矿已经完成'
texts[Index.Mining_No_All_Beat]                                             = '还有%s未击败，是否继续退出？'
texts[Index.Mining_Rob_Gemstone]                                            = '打劫%d个%s宝石箱'
texts[Index.Mining_Rob_Acer]                                                = '打劫%d元宝'
texts[Index.Mining_Rob_Refined_stone]                                       = '打劫%d个精炼石'





--***********************奇门遁**************************
texts[Index.Gossip_Upgrade_success]                                         = '%s注入完毕'
texts[Index.Gossip_Breach]                                                  = '请点击中心，并突破至下一重'
texts[Index.Gossip_Breach_success]                                          = '成功突破至%s重'
texts[Index.Gossip_No_Prop]                                                 = '乾玉不足，请前往无极幻境的乾境获取'
texts[Index.Gossip_Level_insufficient]                                      = '团队等级提升至%d再试'
texts[Index.Gossip_No_Upgrade_complete]                                     = '请将本重四象注入完毕后再试'





--***********************助阵**************************
texts[Index.Assist_Somebody_Assist_You]                                     = '%s助阵你%s'
texts[Index.Assist_No_Assist_hero]                                          = '暂无好友助阵神灵'
texts[Index.Assist_Assist_success]                                          = '助阵%s成功'
texts[Index.Assist_No_hero]                                                 = '抱歉，没有该神灵'
texts[Index.Assist_Hero_No_time]                                            = '抱歉，该神灵次数不足'
texts[Index.Assist_Already_Assist_This_player]                              = '抱歉，今天已助阵过该玩家'
texts[Index.Assist_This_player_Already_Assist_You]                          = '抱歉，今天已接受过该玩家助阵'
texts[Index.Assist_Their_Hero_No_time]                                      = '抱歉，今天该神灵助阵已达到最大次数'
texts[Index.Assist_Assist_success_they]                                     = '成功助阵%d个好友'
texts[Index.Assist_UI_Assist]                                               = '累计助阵好友%d次'
texts[Index.Assist_Assist_gift]                                             = '所有礼物已领取'
texts[Index.Assist_NO_Assist_friend]                                        = '没有可助阵好友'
texts[Index.Assist_No_Assist_time]                                          = '今日助阵次数已用尽'
texts[Index.Assist_No_open]                                                 = '团队等级达到40级开启'
                                    




--***********************佣兵**************************
texts[Index.Mercenary_Mercenary_back_limit]                                  = '超过30分钟神灵才能归队'
texts[Index.Mercenary_The_team_returned_to_limit]                            = '超过30分钟队伍才能归队'
texts[Index.Mercenary_The_knight_is_empty]                                   = '没有派遣神灵'
texts[Index.Mercenary_Team_is_empty]                                         = '没有派遣队伍'






--***********************雇佣**************************
texts[Index.Hire_The_same_Knight_battle]                                     = '同名神灵不能同时上阵'
texts[Index.Hire_No_Knight_battle]                                           = '至少上阵一位神灵'
texts[Index.Hire_Abnormal_information_Knight]                                = '神灵信息刷新，请重新选择' 
texts[Index.Hire_The_knight_is_empty]                                        = '没有好友队伍'
texts[Index.Hire_Team_is_empty]                                              = '没有仙盟队伍'



--***********************祈愿**************************
texts[Index.QIYUAN_NOT_FIND_TEMPLATE]                                               = '找不到模板'
texts[Index.QIYUAN_NOT_FIND_REWARD]                                                 = '未找到奖励'
texts[Index.QIYUAN_REWARD_ALREADY_GET]                                              = '奖励已领取' 
texts[Index.QIYUAN_NOT_ENOUGH_DAY]                                                  = '祈愿天数不足15天'
texts[Index.QIYUAN_NOT_ENOUGH_COUNT]                                                = '今日祈愿次数已满'
texts[Index.QIYUAN_WAIT_FIVE_MINUTE]                                                = '请等待五分钟' 
texts[Index.QIYUAN_NOT_FIND_INVOCATORY_GOODS]                                       = '没有祈愿石'
texts[Index.QIYUAN_NOT_INVOCATORY_REWARD_OR_RESET]                                  = '三个卡槽没有奖励或者奖励已经被重置'



texts[Index.QIYUAN_NOTFIND_TEMPLATE]                                               = '找不到模板'
texts[Index.QIYUAN_NOTFIND_REWARD]                                                 = '未找到奖励'
texts[Index.QIYUAN_REWARDALREADY_GET]                                              = '奖励已领取' 
texts[Index.QIYUAN_NOTENOUGH_DAY]                                                  = '祈愿天数不足%d天'
texts[Index.QIYUAN_NOTENOUGH_COUNT]                                                = '今日祈愿次数已满'
texts[Index.QIYUAN_WAITFIVE_MINUTE]                                                = '请等待五分钟' 
texts[Index.QIYUAN_NOTFIND_INVOCATORY_GOODS]                                       = '没有祈愿石'
texts[Index.QIYUAN_NOTINVOCATORY_REWARD_OR_RESET]                                  = '三个卡槽没有奖励或者奖励已经被重置'

--***********************非法第三方**************************
texts[Index.illegal_Third_party]                                             = '战斗异常，请重新登录'



--***********************仙盟战**************************
texts[Index.Guild_War_Output]                                             = '气血增加10%'
texts[Index.Guild_War_Force]                                              = '武力增加10%'
texts[Index.Guild_War_Internal]                                           = '内力增加10%'
texts[Index.Guild_War_No_Elite]                                           = '该精英不在队伍中'
texts[Index.Guild_War_War_star]                                           = '仙盟争锋即将开始，无法报名'
texts[Index.Guild_War_No_Position]                                        = '位置不足，请尝试其他队列'
texts[Index.Guild_War_No_Videotape]                                       = '暂无战斗回顾信息'




--***********************人物缘分道具**************************
texts[Index.Fate_Prop]                                             = '道具时间延长'



--***********************一键扫荡**************************
texts[Index.Sweep_Synthesis]                                              = '扫荡已完成，请合成'
texts[Index.Sweep_No_Martial]                                             = '没有可扫荡关卡，请先达成三星通关目标关卡'
texts[Index.Sweep_No_VIP]                                                 = 'VIP5开启'


--***********************寻宝**************************
texts[Index.XunBao_NOT_FIND_ACTIVITY]                                               = '寻宝活动已结束'
texts[Index.XunBao_NOT_FIND_TREASURE_INFO_LIST]                                     = '寻宝活动奖励没有配置'
texts[Index.XunBao_NOT_ENOUGH_COUNT]                                                = '寻宝次数不足'


texts[Index.XunBao_NOTFIND_ACTIVITY]                                               = '寻宝活动已结束'
texts[Index.XunBao_NOTFIND_TREASURE_INFO_LIST]                                     = '寻宝活动奖励没有配置'
texts[Index.XunBao_NOTENOUGH_COUNT]                                                = '寻宝次数不足'


--***********************天书**************************
texts[Index.SkyBook_TEMPLATE_NOT_FOUND]                                           = '找不到对应的物品配置'
texts[Index.SkyBook_NOT_ENOUGH_LEVEL]                                             = '等级不够'
texts[Index.SkyBook_BIBLE_ADD_ERROR]                                              = '添加天书失败'
texts[Index.SkyBook_BIBLE_NOT_EXIST]                                              = '身上没有该天书'
texts[Index.SkyBook_PLAYER_NOT_FOUND]                                             = '玩家不存在'
texts[Index.SkyBook_ESSENTIAL_MOSAIC_NOT_ALLOW]                                   = '该位置不允许镶嵌'
texts[Index.SkyBook_ESSENTIAL_MOSAIC_ALREADY]                                     = '该位置已镶嵌'
texts[Index.SkyBook_MOSAIC_RESOURCE_NOT_ENOUGH]                                   = '镶嵌条件不满足'
texts[Index.SkyBook_MOSAIC_RESOURCE_IS_NULL]                                      = '未配置镶嵌条件'
texts[Index.SkyBook_ESSENTIAL_NOT_ENOUGH]                                         = '精要数量不足'
texts[Index.SkyBook_ESSENTIAL_MOSAIC_NOT_EXIST]                                   = '该位置未镶嵌'
texts[Index.SkyBook_BIBLE_EQUIP_NOT_FULL]                                         = '未镶嵌满升重失败'
texts[Index.SkyBook_BIBLE_LIST_IS_NULL]                                           = '玩家天书记录为空'

--***********************游历**************************
texts[Index.Adventure_ADVENTURE_SHOP_BUY_ERROR]                                   = '货币不足,不予兑换'
texts[Index.Adventure_ADVENTURE_EVENT_ERROR]                                      = '随机事件不存在'
texts[Index.Adventure_ADVENTURE_FORMATION_ERROR]                                  = '请先在游历界面布阵第二阵容'

--***********************杀戮**************************
texts[Index.Adventure_ADVENTURE_Kill_Challenged]                                   = '今日已挑战过此玩家 无法再次挑战'

--***********************神灵换功**************************
texts[Index.Change_Short_PLAYER_ERROR]                                             = '主角不可以参与转换'
texts[Index.Change_Short_ITEM_ERROR]                                               = '转换丹不足'
texts[Index.Change_short_PRACTICE_ERROR]                                           = '该神灵正在仙盟修炼中'



--***********************神灵炼体**************************
texts[Index.Refining_the_bodyopen1]                                             = '第一个部位易筋开放'
texts[Index.Refining_the_bodyopen2]                                             = '第二个部位粹骨开放'
texts[Index.Refining_the_bodyopen3]                                             = '第三个部位换血开放'
texts[Index.Refining_the_bodyopen4]                                             = '第四个部位洗髓开放'



--***********************跨服个人战**************************
texts[Index.Personal_service_war_Full]                                          = '抱歉，服务器名额已满'





















return texts