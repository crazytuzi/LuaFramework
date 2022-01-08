local TextIndex = {}

TextIndex.OK										= 0				--操作成功，无错误
TextIndex.parameter_error							= 1				--参数错误
TextIndex.unknow_exception							= -127			--异常错误

--****************阵形*********************
TextIndex.fully                                                             = 3824     --战阵已满
TextIndex.unit_not_found                                                    = 3825     --找不到单位
TextIndex.idnex_closed                                                      = 3826     --该位置未开放
TextIndex.player_must_in                                                    = 3827     --玩家必须上阵
TextIndex.unit_must_be_unique                                               = 3828     --同一时间不可以上阵两个同类角色
TextIndex.at_less_one_in_war_side                                           = 3829     --至少一人上阵
TextIndex.bloody_unit_min_level                                             = 3830     --角色等级低于30级，不能参加雁门关

--****************战斗*********************
TextIndex.battle_not_found                                                  = 3840     --找不到战斗实例
TextIndex.invalidate_battle_code                                            = 3841     --无效的战斗代码，战斗代码是每次战斗开始发送到客户端，一个战斗代码只能够一次有效
TextIndex.no_challenge_times                                                = 3842     --挑战体力已用完
TextIndex.max_daily_buy_challenge_times                                     = 3843     --今日购买次数已达上限

--****************战斗校验******************
TextIndex.invalidate_round_count                                            = 3952     --非法回合数
TextIndex.fight_action_list_is_null                                         = 3953     --战斗行为链表为空
TextIndex.fight_action_list_is_empty                                        = 3954     --战斗行为链表中没有任何数据
TextIndex.invalidate_action_from_position                                   = 3955     --非法的行为发起位置
TextIndex.invalidate_action_target_position                                 = 3956     --非法的行为目标位置
TextIndex.target_unit_not_found                                             = 3957     --目标角色找不到
TextIndex.action_unit_not_found                                             = 3958     --行为角色找不到
TextIndex.invalidate_unit                                                   = 3959     --非法行动角色
TextIndex.unit_already_die                                                  = 3960     --角色已经死亡
TextIndex.target_list_count_is_empty                                        = 3961     --目标列表为空
TextIndex.invalidte_target_list_count                                       = 3962     --无效目标个数
TextIndex.invalidate_target_unit                                            = 3963     --非法目标角色
TextIndex.invalidate_normal_attack_effect_value                             = 3964     --非法普通攻击效果数值
TextIndex.have_not_learn_spell                                              = 3965     --没有学会该技能
TextIndex.can_not_cast_spell_yet                                            = 3966     --还未能够释放技能
TextIndex.not_enough_energy                                                 = 3968     --没有足够的怒气
TextIndex.battle_already_end                                                = 3969     --战斗已经结束
TextIndex.invalidate_spell_effect_value                                     = 3970     --非法技能效果数值
TextIndex.spell_state_rate_is_zero                                          = 3971     --技能给予状态的概率为0
TextIndex.have_not_state_for_19                                             = 3972     --身上没有反弹伤害的状态
TextIndex.invalidate_passive_effect_value                                   = 3973     --无效的被动效果值
TextIndex.invalidate_active_effect_value                                    = 3974     --无效的主动效果值
TextIndex.limit_to_cast_spell                                               = 3975     --限制使用技能

--*****************推图*******************
TextIndex.section_template_not_found                                        = 4608     --找不到章节信息
TextIndex.section_template_npc_conf_error                                   = 4609     --关卡中NPC配置信息错误，数据异常
TextIndex.pve_not_enough_challenge_times                                    = 4610     --你没有足够的挑战次数
TextIndex.prev_chapter_not_passed                                           = 4611     --前置章节尚未通关，无法挑战
TextIndex.prev_section_not_passed                                           = 4612     --前置关卡尚未通关，无法挑战
TextIndex.chapter_template_not_found                                        = 4613     --找不到章节模板数据对象
TextIndex.prev_difficulty_not_passed                                        = 4614     --前置难度尚未通关，无法开启当前难度
TextIndex.chapter_record_not_found                                          = 4615     --章节通关信息未能找到，您没有该章节的通关记录
TextIndex.difficulty_record_not_found                                       = 4616     --章节特定难度通关信息未能找到，您没有该章节特定难度的通关记录
TextIndex.chapter_box_not_found                                             = 4617     --找不到对应的宝箱
TextIndex.not_enough_star_number                                            = 4618     --没有足够的星星数量
TextIndex.already_open_box                                                  = 4619     --已经开启过该宝箱
TextIndex.reward_configure_not_found                                        = 4620     --找不到奖励配置
TextIndex.not_enough_player_level											= 4621     --等级不足
TextIndex.chapter_many_pass                                                 = 4624     --无法扫荡

--******************物品*******************
TextIndex.hold_goods_not_found                                              = 4097     --持有物品不存在
TextIndex.goods_template_not_found                                          = 4098     --没有该物品的数据模版
TextIndex.package_fully                                                     = 4099     --背包已满
TextIndex.not_equip                                                         = 4100     --不是装备
TextIndex.index_not_empty                                                   = 4101     --该位置已经放置了物品
TextIndex.different_goods_instance                                          = 4102     --不同的持有物品实例
TextIndex.different_goods_template                                          = 4103     --不同类型的物品
TextIndex.equip_not_found                                                   = 4116     --找不到装备
TextIndex.can_not_equip                                                     = 4117     --不可装备
TextIndex.inval_position                                                    = 4118     --非法装备位
TextIndex.broken                                                            = 4119     --装备损坏
TextIndex.package_not_found                                                 = 4120     --找不到背包
TextIndex.excetpion                                                         = 4223     --异常
TextIndex.not_enough_hold_goods                                             = 4121     --没有足够的物品
TextIndex.intensify_data_not_found                                          = 4122     --找不到强化数据
TextIndex.hold_equip_gem_solt_is_all_opend                                  = 4123     --装备所有宝石孔都已经开启，不能再开启新的宝石孔
TextIndex.out_of_hold_equip_gem_solt_index_bound                            = 4124     --宝石孔索引越界
TextIndex.unmosaic_gem_fail                                                 = 4125     --拆解宝石失败
TextIndex.can_not_mosaic_same_gem_type_in_one_equip                         = 4126     --同一件装备不能镶嵌两个相同类型的宝石
TextIndex.invalid_sell_number                                               = 4127     --非法出售物品个数
TextIndex.forging_scroll_not_found                                          = 4128     --无法找到锻造卷轴,您在背包中没有对应的锻造卷轴
TextIndex.is_not_forging_scroll                                             = 4129     --该物品不是锻造卷轴
TextIndex.forging_product_template_not_found                                = 4130     --锻造产出物品数据无法找到，数据缺失
TextIndex.unit_not_enough_level                                             = 4131     --等级不够
TextIndex.already_equiped                                                   = 4132     --您已经装备了该物品
TextIndex.out_of_max_intensify_level_bounds                                 = 4133     --不能再强化，等级已经达到最大强化等级
TextIndex.can_not_intensify_level_lager_than_player_level                   = 4134     --强化等级不能超过玩家角色等级
TextIndex.not_prop                                                          = 4135     --不是道具，不能单独使用
TextIndex.can_not_refining                                                  = 4136     --无法精炼
TextIndex.must_set_dog_foods                                                = 4137     --吞噬目标不能为空
TextIndex.already_max_star_level                                            = 4138     --当前装备星级已经达到最高
TextIndex.can_not_be_use                                                    = 4139     --物品不可使用
TextIndex.data_change_and_error                                             = 4140     --数据更改并且出现非法错误
TextIndex.can_not_merge_equipment                                           = 4141     --不可合成装备

--*****************登录/注册********************
TextIndex.inval_uid                                                         = 3329     --非法UID
TextIndex.name_null                                                         = 3330     --用户名称为空
TextIndex.inval_name_length                                                 = 3331     --用户名称长度错误，太长或者太短
TextIndex.inval_sex                                                         = 3332     --非法性别
TextIndex.inval_profession                                                  = 3333     --非法职业
TextIndex.inval_camp                                                        = 3334     --非法阵营
TextIndex.inval_hometown                                                    = 3335     --非法出生地
TextIndex.regit_close                                                       = 3336     --注册功能关闭
TextIndex.db_exception                                                      = 3337     --数据库操作错误
TextIndex.error                                                             = 3338     --操作异常
TextIndex.duplicate_key                                                     = 3339     --这个名字已经被小伙伴抢占了，还是换个更炫酷的吧！
TextIndex.db_connect_fail                                                   = 3340     --数据库连接异常
TextIndex.plyaer_not_found                                                  = 3341     --找不到玩家信息
TextIndex.player_not_belong_account                                         = 3342     --角色不属于帐号所有
TextIndex.invalidate_validate_code                                          = 3343     --无效验证码
TextIndex.player_list_is_fully                                              = 3344     --不能再创建角色
TextIndex.player_invalide_name                                              = 3345     --对不起，名称含有敏感词汇
TextIndex.player_same_name                                                  = 3346     --对不起，名称不能与原名相同
TextIndex.server_refuse_service                                             = 3347     --服务器暂时拒绝服务
TextIndex.regist_player_already_max                                         = 3348     --注册人数已达到上限，请更换服务器
TextIndex.online_number_already_max                                         = 3349     --在线人数已满，请稍后再尝试或者更换服务器登录
TextIndex.server_is_maintenance                                             = 3350     --服务器处于维护中，请耐心等待
TextIndex.server_open_time_is_not                                           = 3351     --服务器开放时间未到，请耐心等待
TextIndex.GAG                                          		 				= 3358     --您已被禁止发言
TextIndex.BAN                                           					= 3359     --您已被禁止登陆，请联系我们企业QQ:800075156

--****************玩家*********************
TextIndex.player_not_found                                                  = 3585     --找不到玩家
TextIndex.not_enough_coin                                                   = 3587     --没有足够的铜币
TextIndex.not_enough_sycee                                                  = 3588     --没有足够的元宝
TextIndex.not_enough_inspiration                                            = 3589     --没有足够的真气
TextIndex.not_enough_team_exp                                             	= 3590     --团队经验不足
TextIndex.not_enough_role_exp                                               = 3591     --没有足够的经验
TextIndex.not_enough_arena_score                                            = 3592     --没有足够的群豪谱积分
TextIndex.not_enough_vip_score                                              = 3593     --没有足够的VIP积分
TextIndex.not_enough_errantry                                               = 3594     --没有足够的侠义值
TextIndex.not_enough_recruit_integral                                       = 3596     --没有足够的招募积分
TextIndex.not_enough_jinglu                                                 = 3598     --没有足够的精露
TextIndex.not_enough_res                                               		= 3603     --没有足够的资源
TextIndex.not_enough_team_level                                             = 3711     --团队等级不足
TextIndex.not_enough_body_strength                                          = 3839     --没有足够的侠义值
TextIndex.player_offline                                                    = 3697     --玩家不在线
TextIndex.vip_level_too_low                                                 = 3698     --玩家vip等级不足
TextIndex.not_enough_soul_card                                              = 3699     --没有足够的魂卡
TextIndex.pusle_max_level                                                   = 3700     --该品质的经脉达到最大等级
TextIndex.pusle_max_quality                                                 = 3701     --经脉已经达到最高品质
TextIndex.pusle_not_max_level                                               = 3702     --经脉未达到最高等级
TextIndex.player_name_existed                                               = 3703     --该名称已经存在
TextIndex.sensitive_word                                                    = 3704     --文本中含有敏感词汇
TextIndex.vip_level_reward_reced                                            = 3705     --玩家vip等级奖励已领取过
TextIndex.have_to_wait														= 3706	   --你仍需要等待

--*****************角色培养********************
TextIndex.role_train_unit_not_found                                         = 3596     --找不到角色
TextIndex.soul_card_and_card_can_not_be_null                                = 3624     --你必须设定至少一个魂卡或者卡牌
TextIndex.not_enough_star_level                                             = 3625     --星级不足
TextIndex.can_not_surmount                                                  = 3626     --不能突破
TextIndex.role_already_max_star_level                                       = 3627     --已经是最高星级
TextIndex.already_best_quality                                              = 3628     --已经是最佳品质，无法继续突破
TextIndex.profession_not_found                                              = 3629     --找不到角色职业
TextIndex.already_has_unit_instance                                         = 3630     --你已经拥有该角色
TextIndex.exp_already_max                                                   = 3631     --角色经验已经达到上限
TextIndex.can_not_practice                                                  = 3632     --不可修炼
TextIndex.role_is_Practice                                                  = 3635     --该侠客正在被使用
TextIndex.role_is_assist                                                    = 3636     --该侠客正在助战

--*******************竞技场******************
TextIndex.arena_player_not_found                                            = 4864     --找不到玩家
TextIndex.arena_can_not_challenge_youself                                   = 4865     --不能挑战自己
TextIndex.arena_not_enough_challenge_times                                  = 4866     --没有足够的挑战次数

--*******************铜人阵（废弃）******************
TextIndex.eq_not_enough_challenge_times                                     = 5121     --当日挑战次数已用完
TextIndex.have_not_reward                                                   = 5122     --没有任何可领取的奖励
TextIndex.have_not_challenge_record                                         = 5123     --没有任何挑战记录
TextIndex.stage_npc_can_not_create                                          = 5124     --关卡中npc设置错误，无法创建npc
TextIndex.have_not_attribute_choice                                         = 5125     --没有可以选择的属性
TextIndex.can_not_refresh_attribute                                         = 5126     --不能刷新属性

--******************无量山*******************
TextIndex.climb_not_enough_challenge_times                                  = 5888     --没有足够的挑战次数，不能再挑战了
TextIndex.invalid_section                                                   = 5889     --非法关卡
TextIndex.climb_section_template_not_found                                  = 5890     --找不到关卡配置信息
TextIndex.section_template_data_error                                       = 5891     --关卡配置出现错误
TextIndex.max_history_extra_challenge_times                                 = 5892     --额外的挑战次数已达上限
TextIndex.wannneg_max_battle_challenge_time                                 = 5893     --无量山万能副本已超过今日上限
TextIndex.wannneg_battle_can_not_challenge_today                            = 5894     --现在不能挑战
TextIndex.wannneg_battle_no_challenge_time_today                            = 5895     --今日挑战次数以用完
TextIndex.wannneg_battle_cool_time                                          = 5896     --挑战冷却时间还未结束

--*****************帮派（废弃）********************
TextIndex.player_has_league                                                 = 6145     --玩家已经拥有帮派
TextIndex.league_existed                                                    = 6146     --该帮派已存在
TextIndex.league_not_existed                                                = 6147     --该帮派不存在
TextIndex.not_in_same_league                                                = 6148     --玩家不在同一个帮派
TextIndex.not_league_member                                                 = 6149     --不是帮派成员
TextIndex.leader_cannot_quit_league                                         = 6150     --帮主不能退出帮派
TextIndex.not_league_leader                                                 = 6151     --没有帮主权限
TextIndex.not_league_manager                                                = 6152     --没有帮派管理权限
TextIndex.cannot_invite_myself                                              = 6153     --不能邀请自己
TextIndex.no_invite                                                         = 6154     --邀请不存在或者已过期
TextIndex.player_has_apply                                                  = 6155     --已有帮派申请
TextIndex.player_no_apply                                                   = 6156     --没有该帮派申请
TextIndex.no_second_leader                                                  = 6157     --没有副帮主
TextIndex.quit_league_cool_time                                             = 6158     --退出帮派不满24小时
TextIndex.no_enough_money                                                   = 6159     --帮派资金不足
TextIndex.no_enough_offer                                                   = 6160     --帮派成员贡献不足
TextIndex.goods_building_level_max                                          = 6161     --帮派贡献建筑已达最高等级
TextIndex.buff_building_level_max                                           = 6162     --帮派繁荣建筑已达最高等级
TextIndex.got_building_goods                                                = 6163     --已领取帮派贡献建筑物品
TextIndex.got_buff_today                                                    = 6164     --今日帮派已经领取繁荣建筑BUFF

--*****************商店********************
TextIndex.shop_entry_not_found                                              = 6400     --找不到商品条目
TextIndex.shop_count_today_usedup                                           = 6401     --今日购买次数已用完
TextIndex.shop_count_sum_usedup                                             = 6402     --购买次数已用完
TextIndex.shop_count_vip_usedup                                             = 6403     --vip购买次数已用完
TextIndex.shop_bad_time                                                     = 6404     --当前时间不能购买
TextIndex.shop_error_num                                                    = 6405     --不能购买小于1个
TextIndex.shop_auto_refresh_not_yet                                         = 6406     --自动刷新时间未到
TextIndex.shop_entry_not_yours                                              = 6407     --您的商店内没有该商品
TextIndex.shop_max_num                                                      = 6407     --购买数量超过上限
TextIndex.shop_can_not_exhanged                                             = 6408     --不能兑换(群豪谱商店积分兑换)
TextIndex.shop_closed														= 6409     --商城已关闭

--****************充值*********************
TextIndex.recharge_exist                                                    = 6656     --已经存在充值订单
TextIndex.recharge_fail_unkown                                              = 6657     --下订单失败,原因未知
TextIndex.recharge_close                                                    = 6658     --充值处理关闭状态
TextIndex.recharge_not_found                                                = 6659     --已经存在充值订单
TextIndex.recharge_already_finish                                           = 6660     --订单已经完成交易

--****************聊天*********************
TextIndex.player_offline                                                    = 6913     --玩家不在线
TextIndex.player_no_speak                                                   = 6914     --玩家被禁言
TextIndex.CHAT_PUBLIC                                                       = 6915     --等级达到10级或VIP1解锁发言！
TextIndex.CHAT_TIMT                                                         = 6916     --发言频率过快，请稍后再试！
TextIndex.CHAT_CONTENT_SAME                                                 = 6917     --请勿发送重复消息！
TextIndex.CHAT_REPORT_SAME                                                  = 3708     --请勿重复举报该玩家！

--****************招募*********************
TextIndex.recruit_not_free_but_request_free                                 = 7168     --客户端请求免费招募，但服务器还存在CD时间

--****************邮件*********************
TextIndex.mail_not_exist                                                    = 7424     --邮件不存在
TextIndex.mail_not_receive                                                  = 7425     --邮件不可领取
TextIndex.mail_had_receive                                                  = 7426     --邮件已领取过
TextIndex.report_not_exist                                                  = 7427     --战报数据不存在
TextIndex.mail_have_attachment_and_not_recive                               = 7428     --邮件附件没有领取不可删除
TextIndex.mail_is_protected                                                 = 7429     --邮件处于保护期内，无法删除

--*****************任务/成就********************
TextIndex.mission_not_existed                                               = 8193     --不存在该任务
TextIndex.mission_not_completed                                             = 8194     --任务未完成
TextIndex.mission_finished                                                  = 8195     --任务已结束

--*****************7日目标********************
TextIndex.task_7days_discount_conf_not_found                                = 8272     --打折商品找不到
TextIndex.task_7days_discount_conf_error                                    = 8273     --打折商品配置错误
TextIndex.task_7days_discount_sold_out                                    	= 8274     --商品已售馨

--******************大宝藏（废弃）*******************
TextIndex.treasure_can_not_challenge_youself                                = 8704     --不能挑战你自己
TextIndex.target_is_not_player                                              = 8705     --非法目标，目标不是玩家
TextIndex.treasure_not_enough_challenge_times                               = 8706     --没有足够的挑战次数
TextIndex.already_have_excavation                                           = 8707     --你已经占有了一个挖掘点
TextIndex.max_history_extra_challenge_times                                 = 8708     --额外的挑战次数已达上限
TextIndex.treasure_not_found                                                = 8709     --找不到宝藏
TextIndex.treasure_box_index_out_of_bound                                   = 8710     --索引越界
TextIndex.prev_open_treasure_is_null                                        = 8711     --最后一次打开的宝藏宝箱为空
TextIndex.treasure_is_not_box                                               = 8712     --宝藏不是宝箱
TextIndex.treasure_is_not_goods                                             = 8713     --宝藏不是物品

--******************活动*******************
TextIndex.activity_not_exist                                                = 8960     --活动不存在
TextIndex.activity_not_start                                                = 8961     --活动未开始
TextIndex.activity_finished                                                 = 8962     --活动已结束
TextIndex.template_not_found												= 8963		--活动数据查找不到
TextIndex.not_visiable														= 8964		--活动不可见
TextIndex.progress_not_found												= 8965		--没有活动进度
TextIndex.reward_key_not_found												= 8966		--没有该奖励
TextIndex.not_finish														= 8967		--未完成
TextIndex.not_enough_got_times												= 8968		--没有足够的领取次数

--*******************技能******************
TextIndex.already_max_level                                                 = 9216     --技能已经达到最大等级
TextIndex.spell_template_not_found                                          = 9217     --找不到技能数据模板
TextIndex.have_not_spell_setting                                            = 9218     --角色没有技能配置
TextIndex.have_not_target_spell                                             = 9219     --角色没有目标技能的设定
TextIndex.next_level_spell_date_not_found                                   = 9220     --找不到下一个等级的技能数据
TextIndex.not_enough_spell_study_point                                      = 9221     --没有足够的技能点
TextIndex.spell_level_already_max_for_player_level_limit                    = 9222     --技能等级已经达到战队等级的最高限制
TextIndex.spell_level_already_max_for_unit_level_limit                    	= 9223     --请提升角色等级后再进行升级

--*******************奇遇******************
TextIndex.qiyu_dining_time_not                                              = 9472     --不是用餐时间
TextIndex.qiyu_dining_dined                                                 = 9473     --已用餐过
TextIndex.qiyu_action_not_act                                               = 9474     --此活动未开始或已结束
TextIndex.sign_signed                                                       = 9985     --今日已签到

--********************邀请码*****************
TextIndex.not_active_inv_code                                               = 9728     --邀请码活动未开启
TextIndex.invite_code_not_existed                                           = 9729     --该邀请码不存在
TextIndex.invite_code_used                                                  = 9730     --您已使用过邀请码
TextIndex.no_this_reward                                                    = 9731     --没有该奖励
TextIndex.has_gotten_this_reward                                            = 9732     --已经领取过该奖励
TextIndex.no_enough_invite_time_to_get_reward                               = 9733     --邀请次数不足，不能领取该奖励
TextIndex.invite_can_not_verify_yourself                                    = 9734     --对不起，您不能验证自己的邀请码
TextIndex.invite_fail_level_limit                                    		= 9735     --您已超过邀请等级

--**********************月卡***************
TextIndex.contract_no_existed                                               = 10240     --契约不存在
TextIndex.contract_existed                                                  = 10241     --契约已存在
TextIndex.contract_out_of_date                                              = 10242     --契约已过期
TextIndex.contract_got_reward_doday                                         = 10243     --今日已领取奖励
TextIndex.not_active_yue_ka     											= 10244		--月卡未购买或者过期

--*********************护驾****************
TextIndex.escorting_not_enough_challenge_times                              = 10496     --没有足够的挑战次数
TextIndex.escorting_already_finish                                          = 10497     --本次护驾已经结束
TextIndex.escorting_have_not_finish                                         = 10498     --护驾尚未结束
TextIndex.not_enough_level_to_escorting                                     = 10499     --你的等级不足以护驾
TextIndex.escorting_configure_error                                         = 10500     --数据配置错误
TextIndex.escorting_date_not_found                                          = 10501     --数据配置错误-没有数据配置
TextIndex.is_waiting                                                        = 10502     --冷却中

--*******************雁门关******************
TextIndex.no_enemy                                                          = 12800     --该关卡还未开启或者不存在
TextIndex.has_passed_section                                                = 12801     --已通过该关卡，不能再挑战
TextIndex.not_pass_prevous_section                                          = 12802     --还未通过前一个关卡，不能挑战该关卡
TextIndex.no_box_item                                                       = 12803     --不存在该宝箱条目
TextIndex.box_item_in_hidden_status                                         = 12804     --宝箱不处不可见状态
TextIndex.box_item_not_in_can_buy_status                                    = 12805     --宝箱不处在可购买状态
TextIndex.box_item_not_in_free_status                                       = 12806     --宝箱不处在可免费获取状态
TextIndex.daily_inspire_time_used_up                                        = 12807     --今日鼓舞次数已经用完
TextIndex.bloody_unit_all_dead                                              = 12808     --上阵角色已经全部阵亡，不能挑战
TextIndex.not_enough_bloody_reset_count										= 12818		--雁门关重置次数不足
TextIndex.not_pass_level													= 12819		--雁门关通关关数不足，无法扫荡

--********************开服活动（废弃）*****************
TextIndex.have_wait_time                                                    = 13056     --你还需要等待一定时间
TextIndex.already_get                                                       = 13057     --你已经领取过了该奖励
TextIndex.not_enough_level                                                  = 13058     --你不够等级
TextIndex.not_enough_times                                                  = 13059     --累计次数不够
TextIndex.not_supported                                                     = 13060     --不支持
TextIndex.reward_not_found                                                  = 13061     --好不到奖励
TextIndex.activity_reward_configure_not_found                               = 13062     --好不到奖励配置信息
TextIndex.invalidate_request                                                = 13063     --非法请求
TextIndex.open_activity_not_start                                           = 13064     --活动仍未开始
TextIndex.open_activity_already_end                                         = 13065     --活动已经结束

--********************押镖*****************
TextIndex.not_active_yabiao                                                 = 12288     --未开启押镖活动
TextIndex.not_got_reward                                                    = 12289     --还未领取上次押镖奖励
TextIndex.not_in_yabiao_status                                              = 12290     --当前没有押镖
TextIndex.in_yabiao_status                                                  = 12291     --正在押镖中
TextIndex.no_yabiao_time_today                                              = 12292     --日进押镖次数已用完
TextIndex.can_not_got_reward                                                = 12293     --没有完成押镖，不能领取奖励

--*******************礼包*********************
TextIndex.already_use								= 13569		--已经领取过
TextIndex.invitation_not_found							= 13570		--找不到礼包码
TextIndex.invitation_package_not_found						= 13571		--礼包找不到
TextIndex.already_use_same_package						= 13572		--已经使用过同一个礼包的礼包码
TextIndex.time_less_than_package						= 13573		--未到领取时间
TextIndex.package_not_start_time							= 13574		--礼包未开启
TextIndex.package_out_of_end_time						= 13575		--礼包已关闭


--********************点赞**********************
TextIndex.already_praise_target_player										= 16384		--今日已经赞过该玩家
TextIndex.not_enough_praise_time 											= 16385		--今日次数已经用完，没有足够的点赞次数

--******************掉落*******************
TextIndex.drop_group_not_found                                              = 32256     --掉落组找不到
TextIndex.drop_item_not_found                                               = 32257     --掉落组找不到
TextIndex.drop_result_is_null_or_empty                                      = 32258     --掉落结果为空

--******************伏魔录*******************
TextIndex.boss_fight_is_not_open                                      		= 16896     --boss活动未开始
TextIndex.boss_fight_is_time_out                                      		= 16897     --boss活动已结束     
TextIndex.boss_fight_is_NOT_ENOUGH_CHALLENGE_TIMES                          = 16898     --没有足够的挑战次数
TextIndex.boss_fight_is_CONFIGURE_NOT_FOUND                                 = 16899     --找不到配置信息
TextIndex.boss_fight_is_CONFIGURE_FORMATION_ERROR                           = 16900     --找不到配置信息

--******************好友*******************
TextIndex.PLAYER_NOT_EXIST                                                  = 17152     --该玩家不存在！
TextIndex.PLAYER_IS_FRIEND                                                  = 17153     --您与该玩家已经是好友！
TextIndex.PLAYER_IS_APPLY                                                   = 17154     --您已向该玩家提出过申请！
TextIndex.FRIEND_APPLY_IS_FULL                                              = 17155     --对方好友申请列表已满！
TextIndex.APPLY_NOT_EXIST                                                   = 17156     --您已经发送过申请！
TextIndex.FRIEND_IS_FULL                                                    = 17157     --您的好友列表已满！
TextIndex.SIDE_FRIEND_IS_FULL                                               = 17158     --对方好友列表已满！
TextIndex.FRIEND_NOT_EXIST                                                  = 17159     --该好友不存在！
TextIndex.NOT_IN_GIVE_TIME                                                  = 17160     --赠送时间未到！
TextIndex.NOT_GIVE                                                          = 17161     --无法领取！
TextIndex.DRAW_FULL                                                         = 17162     --今日领取次数已用尽
TextIndex.GIVE_FULL                                                         = 17163     --今日赠送次数已用尽
TextIndex.has_to_Assist                                                     = 17164     --该好友今日已助战
TextIndex.Assist_in_FULL                                                    = 17165     --今日接受助战次数已达上限
TextIndex.Assist_in_FULL2                                                   = 17166     --今日助战次数已达上限



--******************帮派*******************
TextIndex.NUPTIAL                                                           = 17409		--该名字已存在
TextIndex.HAS_GUILD                                                         = 17410		--您已经加入帮派
TextIndex.APPLY_IS_FULL                                                     = 17411		--今日申请数量已达到上限
TextIndex.APPLY_NOT_EXIST                                                   = 17412		--申请对象不存在
TextIndex.GUILD_IS_FULL                                                     = 17413		--帮派人数已达上限 
TextIndex.MEMBER_HAS_GUILD                                                  = 17414		--该玩家已有帮派
TextIndex.GUILD_NOT_EXIST                                                   = 17415		--帮派不存在
TextIndex.PRESIDENT_IMPEACHMENT                                             = 17416		--帮主已被弹劾
TextIndex.IMPEACHMENT_NO_TIME                                               = 17417		--弹劾时间不足
TextIndex.DECLARATION_INSUFFICIENT                                          = 17418		--帮派贡献不足
TextIndex.HAS_BEEN_INVITED                                                  = 17419		--该玩家已经被邀请
TextIndex.NAME_ERROR                                                        = 17420		--名称中有特殊字符
TextIndex.PUNISHMENT_TIME                                                   = 17421		--该玩家退出帮派未超过24小时
TextIndex.NAME_SENSITIVE_WORD                                               = 17422		--名称中有特殊字符
TextIndex.MEMBER_EXIT_GUILD                                                 = 17423		--成员已经离开帮派
TextIndex.MAKED_COUNT_FULL                                                  = 17424		--成员已经离开帮派
TextIndex.WORSHIP_FULL                                                      = 17425		--帮派祭拜次数已满
TextIndex.OPEN_NOT_IN_TIME                                                  = 17426		--领取时间超时
TextIndex.ZONE_IS_OPEN                                                      = 17427		--副本已被开启
TextIndex.BOOM_DEFICIENCY                                                   = 17428		--繁荣度不足
TextIndex.ZONE_IS_LOCKED                                                    = 17429		--副本已被锁定
TextIndex.ZONE_RESET                                                        = 17430		--副本已被重置
TextIndex.ZONE_RESET_FULL                                                   = 17431		--副本重置已达上限
TextIndex.Chest_Upper                                                       = 17432		--宝箱领取已达今日上限



--**********************争霸赛**********************
TextIndex.BATTLE_IS_NOT_START                                               = 17665		--对战未开始或已结束
TextIndex.NO_PLAYER_CAN_MATCH                                               = 17666		--没有可匹配的玩家
TextIndex.MATCH_NOT_IN_TIME                                                 = 17667     --对战正在冷却中，请稍后再试
TextIndex.BET_NOT_IN_TIME                                                   = 17668     --押注时间已过

--**********************无量山北窟******************
TextIndex.BEIKU_CAN_NOT_RESET                                               = 18688     --重置次数用尽
TextIndex.BEIKU_NPC_FORMATION_NOT_FOUND                                     = 18689     --找不到NPC配置信息
TextIndex.BEIKU_GAME_LEVEL_NOT_FOUND	                                    = 18690     --找不到关卡配置信息
TextIndex.BEIKU_ALREAY_MAX_GAME_LEVEL	                                    = 18691     --没有更多的关卡设定
TextIndex.BEIKU_INVALIDATE_GAME_LEVEL_ID	                                = 18692     --非法的关卡ID
TextIndex.BEIKU_CAN_NOT_CHOICE_ATTRIBUTE                                    = 18693     --无法选择该属性
TextIndex.BEIKU_CHOICE_ATTRIBUTE_NOT_FOUND                                  = 18694     --无法选择可使用的属性
TextIndex.BEIKU_CHOICE_ATTRIBUTE_CONF_NOT_FOUND                             = 18695     --找不到属性选择配置
TextIndex.BEIKU_ATTRIBUTE_ALREAY_CHOICED                                    = 18696     --已经选择过该属性
TextIndex.BEIKU_CHOICE_ATTRIBUTE_NOT_VALIDATE                               = 18697     --该属性配置错误
TextIndex.BEIKU_NOT_ENOUGH_TOKENS                                           = 18698     --没有足够的无量山玉
TextIndex.BEIKU_HAVE_NOT_CHEST_CAN_OPEN                                     = 18699     --没有可以开启的宝箱
TextIndex.BEIKU_CHEST_ALREAY_OPEN                                           = 18700     --已经开启过该宝箱
TextIndex.BEIKU_CHEST_CONFIGURE_IS_NULL                                     = 18701     --宝箱配置为空
TextIndex.BEIKU_ATTRIBUTE_ALREAY_CHOICED_IS_SKIP                            = 18702     --您已经跳过了鼓舞，不可以再次选择
TextIndex.BEIKU_CAN_NOT_SWEEP                                               = 18703     --敌人过于强大，无法扫荡
TextIndex.BEIKU_HAS_NOT_PASS                                                = 18704     --该关卡挑战失败，需要重置无量山北窟
TextIndex.BEIKU_GET_AND_SWEEP                                               = 18705     --您有宝箱没有领取，请领取后扫荡
TextIndex.BEIKU_CHOICE_ATTRIBUTE_AND_SWEEP                                  = 18706     --您有属性没有选择，请选择后扫荡


--**********************砸蛋******************
TextIndex.EGG_ACTIVITY_IS_NOT_START                                         = 18176     --活动不在开启时间
TextIndex.EGG_PROP_NOT_ENOUGH                                               = 18177     --砸蛋道具不足
TextIndex.EGG_REWARD_NOT_FOUND                                              = 18178     --奖励配置为空
TextIndex.EGG_NUMBER_ERROR                                                  = 18179     --砸蛋次数错误
TextIndex.EGG_GOLD_HAMMER_NOT_ENOUGH                                        = 18180     --金锤子数量不足
TextIndex.EGG_SILVER_HAMMER_NOT_ENOUGH                                      = 18181     --银锤子数量不足

--************************采矿*******************
TextIndex.NO_SELECT_FORMATION												= 20483		--至少上阵1个侠客
TextIndex.NOT_ENOUGH_ROB_TIMES												= 20486     --没有打劫机会了
TextIndex.NOT_STTATEGY_MINE												    = 20488     --没有守矿阵容
TextIndex.NOT_MINE_PLAYER_IS_LOCK											= 20490     --该玩家正在被打劫
TextIndex.MINE_Complete											            = 20493     --该玩家挖矿已经完成


--************************老玩家回归*******************
TextIndex.regression_Invitation_code_error1                                  = 21248     --邀请码有误，请核查后重新输入
TextIndex.regression_Invitation_code_error2                                  = 21249     --邀请码有误，请核查后重新输入
TextIndex.regression_Invitation_code_error3                                  = 21250     --邀请码有误，请核查后重新输入
TextIndex.regression_Has_returned                                            = 21251     --玩家已经回归，无法召回
TextIndex.regression_Insufficient_level                                      = 21252     --目标等级不足
TextIndex.regression_Insufficient_day                                        = 21253     --玩家未登录天数不足




--***********************雇佣侠客**************************
TextIndex.CAN_NOT_DISPATCH_Hire_a_knight                                                     = 20768        --不可派遣
TextIndex.IN_THE_GROUP_Hire_a_knight                                                         = 20769        --该侠客已经在队伍中
TextIndex.NOT_IN_THE_GROUP_Hire_a_knight                                                     = 20770        --该侠客不在队伍中
TextIndex.NOT_VIP_LEVEL_Hire_a_knight                                                        = 20771        --VIP等级不够
TextIndex.NOT_TIME_Hire_a_knight                                                             = 20772        --时间不够
TextIndex.NOT_FOUND_Hire_a_knight                                                            = 20773        --侠客信息刷新，请重新选择
TextIndex.ALREADY_HIRE_Hire_a_knight                                                         = 20774        --已经雇佣过
TextIndex.FORMATION_IS_EMPTY_Hire_a_knight                                                   = 20775        --佣兵阵形上没有出战角色





--***********************雇佣队伍**************************
TextIndex.CAN_NOT_DISPATCH_Hiring_team                                                    = 20736        --不可派遣
TextIndex.NOT_FOUND_Hiring_team                                                           = 20737        --找不到派遣队伍
TextIndex.IS_NOT_DISPATCH_STATE_Hiring_team                                               = 20738        --不在派遣状态
TextIndex.NOT_ENOUGH_DISPATCH_TIME_Hiring_team                                            = 20739        --派遣时间不足
TextIndex.BATTLE_ROLE_IS_EMPTY_Hiring_team                                                = 20740        --上阵角色为空
TextIndex.HAVE_IN_ROLE_MERCENARY_Hiring_team                                              = 20741        --上阵角色不可以在角色佣兵里面
TextIndex.ALREADY_HIRE_TEAM_Hiring_team                                                   = 20742        --你已经雇佣过这个队伍了
TextIndex.HIRE_TEAM_NOT_FOUND_Hiring_team                                                 = 20743        --找不到已经雇佣的佣兵队伍信息
TextIndex.HIRE_TEAM_USE_TYPE_NOT_SAME_Hiring_team                                         = 20744        --已经雇佣的佣兵队伍使用 类型不匹配
TextIndex.HIRE_TEAM_MODIFY_ROLE_MISS_Hiring_team                                          = 20745        --已经雇佣的佣兵队伍阵形角色ID遗失


--***********************祈愿**************************
TextIndex.QIYUAN_NOT_FIND_TEMPLATE                                                   = 21505       --找不到模板
TextIndex.QIYUAN_NOT_FIND_REWARD                                                     = 21506       --未找到奖励
TextIndex.QIYUAN_REWARD_ALREADY_GET                                                  = 21507       --奖励已领取  
TextIndex.QIYUAN_NOT_ENOUGH_DAY                                                      = 21508       --祈愿天数不足15天
TextIndex.QIYUAN_NOT_ENOUGH_COUNT                                                    = 21509       --今日祈愿次数已满
TextIndex.QIYUAN_WAIT_FIVE_MINUTE                                                    = 21510       --请等待五分钟  
TextIndex.QIYUAN_NOT_FIND_INVOCATORY_GOODS                                           = 21511       --没有祈愿石
TextIndex.QIYUAN_NOT_INVOCATORY_REWARD_OR_RESET                                      = 21512       --三个卡槽没有奖励或者奖励已经被重置


--***********************赌石**************************
TextIndex.DUSHI_NOT_ENABLE                                                   = 22528       --未激活
TextIndex.DUSHI_CONFIGURE_NOT_FOUND                                          = 22529       --找不到赌石配置
TextIndex.DUSHI_DROP_GROUP_NOT_FOUND                                         = 22530       --找不到掉落配置
TextIndex.DUSHI_DROP_EMPTY                                                   = 22531       --找不到掉落组宝石
TextIndex.DUSHI_ITEM_LIST_FULLY                                              = 22532       --宝石栏已满，请拾取后再试
TextIndex.DUSHI_HAVE_NOT_ITEM                                                = 22533       --没有可以拾取的宝石
TextIndex.DUSHI_ITEM_NOT_FOUND                                               = 22534       --无法拾取该宝石


--***********************寻宝**************************
TextIndex.XunBao_NOT_FIND_ACTIVITY                                                   = 25345       --寻宝活动已结束
TextIndex.XunBao_NOT_FIND_TREASURE_INFO_LIST                                         = 25346       --寻宝活动奖励没有配置
TextIndex.XunBao_NOT_ENOUGH_COUNT                                                    = 25347       --寻宝次数不足  



--***********************天书**************************
TextIndex.SkyBook_TEMPLATE_NOT_FOUND                                           =24576       --找不到对应的物品配置
TextIndex.SkyBook_NOT_ENOUGH_LEVEL                                             =24577       --等级不够
TextIndex.SkyBook_BIBLE_ADD_ERROR                                              =24580       --添加天书失败
TextIndex.SkyBook_BIBLE_NOT_EXIST                                              =24581       --身上没有该天书
TextIndex.SkyBook_PLAYER_NOT_FOUND                                             =24582       --玩家不存在
TextIndex.SkyBook_ESSENTIAL_MOSAIC_NOT_ALLOW                                   =24583       --该位置不允许镶嵌
TextIndex.SkyBook_ESSENTIAL_MOSAIC_ALREADY                                     =24584       --该位置已镶嵌
TextIndex.SkyBook_MOSAIC_RESOURCE_NOT_ENOUGH                                   =24585       --镶嵌条件不满足
TextIndex.SkyBook_MOSAIC_RESOURCE_IS_NULL                                      =24592       --未配置镶嵌条件
TextIndex.SkyBook_ESSENTIAL_NOT_ENOUGH                                         =24593       --精要数量不足
TextIndex.SkyBook_ESSENTIAL_MOSAIC_NOT_EXIST                                   =24594       --该位置未镶嵌
TextIndex.SkyBook_BIBLE_EQUIP_NOT_FULL                                         =24595       --未镶嵌满升重失败
TextIndex.SkyBook_BIBLE_LIST_IS_NULL                                           =24597       --玩家天书记录为空




--***********************游历**************************
TextIndex.Adventure_ADVENTURE_SHOP_BUY_ERROR                                 =22788       --货币不足,不予兑换
TextIndex.Adventure_ADVENTURE_EVENT_ERROR                                    =22800       --随机事件不存在
TextIndex.Adventure_ADVENTURE_FORMATION_ERROR                                =22784       --请先在游历界面布阵第二阵容

--***********************杀戮**************************
TextIndex.Adventure_ADVENTURE_Kill_Challenged                                        =22785      --今日已挑战过此玩家 无法再次挑战



--***********************侠客换功**************************
TextIndex.Change_Short_PLAYER_ERROR                                          =25856       --主角不可以参与转换
TextIndex.Change_Short_ITEM_ERROR                                            =25857       --转换丹不足
TextIndex.Change_short_PRACTICE_ERROR                                        =25858       --该侠客正在帮派修炼中




--***********************侠客炼体**************************
TextIndex.Refining_the_bodyNo_open                                            = 26112       --穴位未开启
TextIndex.Refining_the_bodyLevel_Max                                          = 26113       --穴位已经突破至满级
TextIndex.Refining_the_bodyLevel_low                                          = 5393       --角色经脉等级不能超过角色等级
TextIndex.Refining_the_bodyNO_Level                                           = 5395       --角色经脉等级不足


































------------------------下面是中文提示哈---------按模块走-------------- 后面 100000 起 


--***********************角色培养**************************
TextIndex.No_Acquisition_Techniques											= 103001		--无可习得秘籍
--***********************无量山北窟************************
TextIndex.BEIKU_OPEN_NOT_ENOUGH_LEVEL                                       = 118001		--无量山南峰通关%d层开启北窟
TextIndex.BEIKU_ALL_PASS                                                    = 118002        --已通关北窟所有关卡，请重置
TextIndex.BEIKU_GET_AND_PASS                                                = 118003        --您有宝箱没有领取，请领取宝箱

--***********************经脉突破**************************
TextIndex.JINGMAI_SURMOUNT_SUCCESS                                          = 120000        --突破成功，属性成长提升
TextIndex.JINGMAI_SURMOUNT_FAIL                                             = 120001        --突破失败
TextIndex.JINGMAI_SURMOUNT_OPEN_NOT_ENOUGH_LEVEL                            = 120002        --无量山南峰通关%d层开启

--***********************帮派**************************
TextIndex.No_Permissions                                                    = 117001		--等待帮主/副帮主开启
TextIndex.NoT_Enough_Prosperity                                             = 117002		--繁荣度不足
TextIndex.Everyday_Reset_One_time                                           = 117003		--每日最多重置1次
TextIndex.Consume_Prosperity_Open                                           = 117004	    --是否消耗%d仙盟威望开启
TextIndex.Consume_Prosperity_Reset                                          = 117005	    --是否消耗%d仙盟威望重置
TextIndex.Zone_Reset_Suceess		                                        = 117006	    --重置成功
TextIndex.Zone_Open_Suceess                                          		= 117007	    --开启成功
TextIndex.Zone_time_out_two_minute                                         	= 117008	    --大侠，最多在挑战界面停留%d分钟
TextIndex.Zone_time_out_ten_second                                          = 117009	    --大侠，最多在结算界面停留%d秒
TextIndex.Zone_time_out_ten_minute                                          = 117010	    --大侠，挑战时长最大为%d分钟
TextIndex.Zone_somebody_attacking                                           = 117011	    --其他玩家正在挑战
TextIndex.Field_Finish_at_once                                              = 117012	    --是否消耗%d元宝立刻完成修炼？
TextIndex.Field_Open_Level                                                  = 117013	    --修炼场需要帮派等级%d级
TextIndex.Field_Research_skill                                              = 117014	    --是否消耗%d繁荣度研究%d级%s？
TextIndex.Field_Open_skill                                                  = 117015	    --是否消耗%d繁荣度开启%s？
TextIndex.Field_Research_skill_max_level                                    = 117016	    --到达当前最高等级，请提升帮派等级
TextIndex.Field_Research_skill_max_level2                                   = 117017	    --到达最高等级
TextIndex.Field_Study_skill_no_open                                         = 117018	    --需要帮主/副帮主开启
TextIndex.Field_Study_skill_max_level                                       = 117019	    --到达当前最高等级，请提升研究等级
TextIndex.Field_No_Permissions                                              = 117020	    --只有帮主/副帮主才能研究
TextIndex.Guild_flag_modify                                                 = 117021        --帮派旗帜修改成功
TextIndex.Guild_UI                                                          = 117022        --需要1个帮派更旗令（剩余：%d）



  
--***********************背包-多选一宝箱**************************
TextIndex.None_Choosed														= 104001        --请选择一个奖励

--***********************装备重铸**************************
TextIndex.Recast_Unlock1                                                    = 119001	    --第一个槽达到破损解锁
TextIndex.Recast_Unlock2                                                    = 119002	    --第二个槽达到瑕疵解锁
TextIndex.Recast_Unlock3                                                    = 119003	    --第三个槽达到完美解锁
TextIndex.Recast_Unlock4                                                    = 119004	    --第四个槽达到神铸解锁
TextIndex.Recast_Gems                                                       = 119005	    --装备重铸2个槽破损解锁
TextIndex.Recast_Second_Prompt                                              = 119006        --重铸会消耗一件%s，是否确认重铸？
TextIndex.Recast_Material_shortage                                          = 119007        --请收集%s
TextIndex.Recast_Used_tool                                          		= 119008        --重铸会消耗一个%s，是否确认重铸？





--***********************采矿**************************
TextIndex.Mining_Protect_Record1                                             = 121001	    --%s雇佣你担当护卫，获得%d佣金
TextIndex.Mining_Protect_Record2                                             = 121002	    --在你担当%s的护卫期间，成功阻止%s的打劫。获得%d额外佣金
TextIndex.Mining_UI1                                                         = 121003	    --本周可选数量：%d/%d
TextIndex.Mining_UI2                                                         = 121004	    --每周每个好友或帮派成员只能选择一次
TextIndex.Mining_UI3                                                         = 121005	    --与%s战斗%d次，
TextIndex.Mining_UI3_win                                                     = 121006	    --%s前来打劫，与%s战斗%d次，打劫成功
TextIndex.Mining_UI3_lost                                                    = 121007	    --%s前来打劫，与%s战斗%d次，打劫失败
TextIndex.Mining_UI4_win                                                     = 121008	    --%s与%s战斗，战斗胜利
TextIndex.Mining_UI4_lost                                                    = 121009	    --%s与%s战斗，战斗失败
TextIndex.Mining_Nobody                                                      = 121010       --暂时没有挖矿者
TextIndex.Mining_Reset                                                       = 121011       --是否消耗1次打劫令重置打劫状态？
TextIndex.Mining_No_Chance                                                   = 121012       --打劫令不足
TextIndex.Mining_No_Protector                                                = 121013       --没有选择护矿者，将更容易受到打劫，是否确认独自采矿
TextIndex.Mining_Rob_Success                                                 = 121014       --打劫%d铜币
TextIndex.Mining_Dead                                                        = 121015       --没有存活侠客
TextIndex.Mining_Increase_Frequency                                          = 121016       --打劫令+%d
TextIndex.Mining_No_Lineup                                                   = 121017       --没有布置采矿阵容的玩家
TextIndex.Mining_No_Rob_frequency                                            = 121018       --缺少打劫令
TextIndex.Mining_Suffer_Rob                                                  = 121019       --该玩家正在被打劫
TextIndex.Mining_Mining_Complete                                             = 121020       --该玩家挖矿已经完成
TextIndex.Mining_No_All_Beat                                                 = 121021       --还有%s未击败，是否继续退出？
TextIndex.Mining_Rob_Gemstone                                                = 121022       --打劫%d个%s宝石箱
TextIndex.Mining_Rob_Acer                                                    = 121023       --打劫%d元宝
TextIndex.Mining_Rob_Refined_stone                                           = 121024       --打劫%d个精炼石






--***********************奇门遁**************************
TextIndex.Gossip_Upgrade_success                                              = 122000       --注入%s成功
TextIndex.Gossip_Breach                                                       = 122001       --请点击中央八卦突破
TextIndex.Gossip_Breach_success                                               = 122002       --成功突破到%s重
TextIndex.Gossip_No_Prop                                                      = 122003       --八卦精元不足
TextIndex.Gossip_Level_insufficient                                           = 122004       --请提升团队等级
TextIndex.Gossip_No_Upgrade_complete                                          = 122005       --请将本重注入完毕




--***********************助战**************************
TextIndex.Assist_Somebody_Assist_You                                          = 123000       --%s助战你%s
TextIndex.Assist_No_Assist_hero                                               = 123001       --暂无好友助战侠客
TextIndex.Assist_Assist_success                                               = 123002       --助战%s成功
TextIndex.Assist_No_hero                                                      = 123003       --抱歉，没有该侠客
TextIndex.Assist_Hero_No_time                                                 = 123004       --抱歉，该侠客次数不足
TextIndex.Assist_Already_Assist_This_player                                   = 123005       --抱歉，今天已助战过该玩家
TextIndex.Assist_This_player_Already_Assist_You                               = 123006       --抱歉，今天已接受过该玩家助战
TextIndex.Assist_Their_Hero_No_time                                           = 123007       --抱歉，今天该侠客助战已达到最大次数
TextIndex.Assist_Assist_success_they                                          = 123008       --成功助战%d个好友
TextIndex.Assist_UI_Assist                                                    = 123009       --累计助战好友%d次
TextIndex.Assist_Assist_gift                                                  = 123010       --所有礼物已领取
TextIndex.Assist_NO_Assist_friend                                             = 123011       --没有可助战好友
TextIndex.Assist_No_Assist_time                                               = 123012       --今日助战次数已用尽
TextIndex.Assist_No_open                                                      = 123013       --团队等级达到40级开启





--***********************佣兵**************************
TextIndex.Mercenary_Mercenary_back_limit                                      = 124000       --超过30分钟侠客才能归队
TextIndex.Mercenary_The_team_returned_to_limit                                = 124001       --超过30分钟队伍才能归队
TextIndex.Mercenary_The_knight_is_empty                                       = 124002       --没有佣兵侠客
TextIndex.Mercenary_Team_is_empty                                             = 124003       --没有佣兵队伍






--***********************雇佣**************************
TextIndex.Hire_The_same_Knight_battle                                         = 125000       --同名侠客不能同时上阵
TextIndex.Hire_No_Knight_battle                                               = 125001       --至少上阵一位侠客
TextIndex.Hire_Abnormal_information_Knight                                    = 125002       --侠客信息刷新，请重新选择  
TextIndex.Hire_The_knight_is_empty                                            = 125003       --没有好友队伍
TextIndex.Hire_Team_is_empty                                                  = 125004       --没有帮派队伍





--***********************非法第三方**************************
TextIndex.illegal_Third_party                                                 = 126000       --战斗异常，请重新登录


--***********************祈愿**************************
TextIndex.QIYUAN_NOTFIND_TEMPLATE                                                   = 127000       --找不到模板
TextIndex.QIYUAN_NOTFIND_REWARD                                                     = 127001       --未找到奖励
TextIndex.QIYUAN_REWARDALREADY_GET                                                  = 127002       --奖励已领取  
TextIndex.QIYUAN_NOTENOUGH_DAY                                                      = 127003       --祈愿天数不足15天
TextIndex.QIYUAN_NOTENOUGH_COUNT                                                    = 127004       --今日祈愿次数已满
TextIndex.QIYUAN_WAITFIVE_MINUTE                                                    = 127005       --请等待五分钟  
TextIndex.QIYUAN_NOTFIND_INVOCATORY_GOODS                                           = 127006       --没有祈愿石
TextIndex.QIYUAN_NOTINVOCATORY_REWARD_OR_RESET                                      = 127007       --三个卡槽没有奖励或者奖励已经被重置

--***********************帮派战**************************
TextIndex.Guild_War_Output                                                         = 128000       --气血增加10%
TextIndex.Guild_War_Force                                                          = 128001       --武力增加10%
TextIndex.Guild_War_Internal                                                       = 128002       --内力增加10%
TextIndex.Guild_War_No_Elite                                                       = 128003       --该精英不在队伍中
TextIndex.Guild_War_War_star                                                       = 128004       --帮派争锋即将开始，无法报名
TextIndex.Guild_War_No_Position                                                    = 128005       --位置不足，请尝试其他队列
TextIndex.Guild_War_No_Videotape                                                   = 128006       --暂无战斗回顾信息



--***********************人物缘分道具**************************
TextIndex.Fate_Prop                                                                = 129000       --道具时间延长



--***********************一键扫荡**************************
TextIndex.Sweep_Synthesis                                                          = 130000       --扫荡已完成，请合成
TextIndex.Sweep_No_Martial                                                         = 130001       --没有可扫荡关卡
TextIndex.Sweep_No_VIP                                                             = 130002       --VIP5开启


--***********************寻宝**************************
TextIndex.XunBao_NOTFIND_ACTIVITY                                                   = 131000       --寻宝活动已结束
TextIndex.XunBao_NOTFIND_TREASURE_INFO_LIST                                         = 131001       --寻宝活动奖励没有配置
TextIndex.XunBao_NOTENOUGH_COUNT                                                    = 131002       --寻宝次数不足  


--***********************天书**************************
TextIndex.SkyBookTEMPLATE_NOT_FOUND                                                 =132000       --找不到对应的物品配置
TextIndex.SkyBookNOT_ENOUGH_LEVEL                                                   =132001       --等级不够
TextIndex.SkyBookBIBLE_ADD_ERROR                                                    =132002       --添加天书失败
TextIndex.SkyBookBIBLE_NOT_EXIST                                                    =132003       --身上没有该天书
TextIndex.SkyBookPLAYER_NOT_FOUND                                                   =132004       --玩家不存在
TextIndex.SkyBookESSENTIAL_MOSAIC_NOT_ALLOW                                         =132005       --该位置不允许镶嵌
TextIndex.SkyBookESSENTIAL_MOSAIC_ALREADY                                           =132006       --该位置已镶嵌
TextIndex.SkyBookMOSAIC_RESOURCE_NOT_ENOUGH                                         =132007       --镶嵌条件不满足
TextIndex.SkyBookMOSAIC_RESOURCE_IS_NULL                                            =132008       --未配置镶嵌条件
TextIndex.SkyBookESSENTIAL_NOT_ENOUGH                                               =132009       --精要数量不足
TextIndex.SkyBookESSENTIAL_MOSAIC_NOT_EXIST                                         =132010       --该位置未镶嵌
TextIndex.SkyBookBIBLE_EQUIP_NOT_FULL                                               =132011       --未镶嵌满升重失败
TextIndex.SkyBookBIBLE_LIST_IS_NULL                                                 =132012       --玩家天书记录为空


--***********************游历**************************
TextIndex.AdventureADVENTURE_SHOP_BUY_ERROR                                         =133000       --货币不足,不予兑换
TextIndex.AdventureADVENTURE_EVENT_ERROR                                            =133001       --随机事件不存在
TextIndex.AdventureADVENTURE_FORMATION_ERROR                                        =133002       --请先在游历界面布阵第二阵容


--***********************杀戮**************************
TextIndex.AdventureADVENTURE_Kill_Challenged                                        =134000      --今日已挑战过此玩家 无法再次挑战
TextIndex.AdventureADVENTURE_Kill_Title                                             =134001       --杀戮池结算
TextIndex.AdventureADVENTURE_Kill_Sub_title                                         =134002       --杀戮池结算
TextIndex.AdventureADVENTURE_Kill_Sub_title                                         =134003       --恭喜大侠获得本周杀戮结算池奖励，击败更多侠士将会获得更为丰厚的奖励，希望您再接再厉，早日登上江湖巅峰。

--***********************侠客换功**************************
TextIndex.ChangeShort_PLAYER_ERROR                                                  =135000       --主角不可以参与转换
TextIndex.ChangeShort_ITEM_ERROR                                                    =135001       --转换丹不足
TextIndex.Changeshort_PRACTICE_ERROR                                                =135002       --该侠客正在帮派修炼中



--***********************侠客炼体**************************
TextIndex.Refining_the_bodyopen1                                                         = 136000       --第一个部位易筋开放
TextIndex.Refining_the_bodyopen2                                                         = 136001       --第二个部位粹骨开放
TextIndex.Refining_the_bodyopen3                                                         = 136002       --第三个部位换血开放
TextIndex.Refining_the_bodyopen4                                                         = 136003       --第四个部位洗髓开放



--***********************跨服个人战**************************
TextIndex.Personal_service_war_Full                                                      = 137000       --抱歉，服务器名额已满





















return TextIndex