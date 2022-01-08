-- local texts = {}
module("localizable", package.seeall )

---============================================= how to use ==============================================
-- TextManager:getString("gameactivity_egg_kehuode")

-- local msg = TextManager:getString("common_function_openlevel")
-- msg = string.format(msg, msg)


-- toastMessage(TextManager:getString("common_not_buytimestoday"))
--------------------------------------------EquipmentManager------------------------------------------------

-- texts["modulename_function_txt_name"]   		= "以后的新功能这样使用中文"

modulename_function_txt_name 					= "以后的新功能这样使用中文"

-- =============================common tips=============================
common_vip_level_buzu 							= "VIP等级不足"
common_todo_vip									= "您的VIP等级需要达到[Lv{p1}]才能购买"
common_vip_open									= "{v1}级开放"
common_out_max_number							= "超过购买上限"
common_level_buzu 								= "等级不足"
Common_good_buzu 			 					= "您没有足够的{p1}"
common_function_will_open 						= "即将开放，敬请期待！"
common_team_level 								= "等级"

common_vip_not_tuhao1                           = "VIP等级大于15才能发言"
common_vip_tuhao_not_enough                     = "VIP{p1}不足"

common_function_openlevel                       = "等级达到{p1}级开启"
common_function_up_number                       = "等级{p1}级可上阵{p2}人"
common_function_friend							= "好友系统将在{p1}级开放"
common_function_number_out						= "上阵人数已满"
common_team_level_notenough						= "您的等级不足，请提升到{p1}级，再尝试"

common_open_position				            = "等级{p1}级开启该阵位"
common_tips 									= "提示"
common_tips_zhuzhan								= "此为助阵神灵，上阵无法助阵，是否继续？"				
common_tips_zhuzhan_text1						= "此神灵助阵不会产生任何缘分，是否助阵？"				
common_tips_zhuzhan_text2						= "派遣的角色至少需要30分钟，确定派遣角色"				
common_tips_team_text1							= "派遣的队伍至少需要30分钟，确定派遣队伍"

common_openlevel_text1 							= "等级{p1}开放"
commom_open 									="已开启"
commom_no_open 									="未开启"
commom_no_open2 								="暂未开启"
common_tonguan									="已通关"
common_open_level								="{p1}级开启"
common_open_tips1								="即将开放，敬请期待！"
common_nono                                     ="暂无"
common_no  										="无"
common_free										="免费"
common_climb_openlevel 							= "无极幻境{p1}层解锁"

common_get_score								="获得积分"

common_no_yuanbao								= "灵玉不足"	
common_no_tongbi								= "铜钱不足"

common_your_yuanbao								="您的灵玉不足"
common_your_times								="您的次数已用完"
common_not_buy_times							="没有购买次数了"

common_team_unlock								="等级{p1}解锁"
common_use_yuanbao_open							= "是否消耗{p1}灵玉解锁？"
common_unlock									= "解锁"
common_level_unlock								= "{p1}级解锁"
common_vip_unlock								="解锁需要VIP{p1}级"
common_vip_tips									="请提升VIP等级"

common_vip_change_layer_enough                  ="您有可购的VIP礼包"
common_vip_change_layer_not_enough              ="没有可购买的VIP礼包"

common_please_check_one							= "请选择一个"
common_dead										= "已战败的角色不能上阵"

common_play_level_low							="该玩家等级过低"
common_input_player_name						="请输入玩家名称"
common_power_faction_low						="没有权限邀请入盟"

common_faction_no_1								="（盟主）"
common_faction_no_2								="（长老）"
common_faction_no_3								="（成员）"
			
common_no_power									="权限不足"
common_fight_times								="今日挑战次数已用完"
common_wait										="虚席以待"
common_every_week								="每周"

common_all_hurt									="总伤害"
common_all_hurt2								="总伤害:"
common_all_body									="全体+{p1}+{p2}%"
common_max_hurt									="最高伤害:"
common_hurt   									="{p1}伤害"

common_exp_add									="经验+{p1}"
common_win_radio								="胜率{p1}%"

common_index_round								="第{p1}层"
common_index_fight			  					="第{p1}战"
common_index_hui								="第{p1}回"
common_index_day								="第{p1}天"
common_index_chapter							="第{p1}章"
common_index_chong								="第{p1}重"
											
common_left_hp									="剩余血量"
common_hp_add									="血量+{p1}"

common_sys_notice								= "系统公告"
common_unlock_suc								= "成功解锁"
common_no_tiaozhancishu							= "没有足够的挑战次数"
common_no_fight_times							= "挑战次数不足！"
common_buy_suc									= "购买成功！"
common_relogin									= "重新登录"
common_wrong									= "出错啦"
common_net_wrong								= "网络连接失败"
common_net_desc									= "连接服务器失败,请检查您的网络稍后再试"

common_net_reset_connnet						="网络异常，请重新连接。。。"
common_net_reset 								="重新连接"

common_time_1									="{p1}小时{p2}分钟"
common_time_2									="{p1}分钟"
common_time_3									="{p1}天{p2}时{p3}分"
common_time_4									="{p1}月{p2}日{p3}时{p4}分"
common_time_5									="{p1}天{p2}时{p3}分{p4}秒"
common_time_6									="{p1}月{p2}日{p3}:{p4}"
common_time_7_ex									="{p1}天{p2}小时{p3}分{p4}秒"
common_time_longlong							="永久有效"
common_activity_time1							="活动时间：{p1}"


common_pay_tips_1								="您没有足够的灵玉购买物品，是否进入充值界面？"
common_pay_tips_2								="扣费提示"
common_pay_tips_3								="您已经手动刷新过【{p1}】次，此次手动刷新需要消耗【 {p2} 】{p3} ,是否确认刷新？"

common_CE										="战力:{p1}"
common_ce2										="{p1}战力"
common_ce_text									="战力:"

common_faction_CE								="仙盟战力:{p1}"

common_LV 										="{p1}级"
common_times   									="{p1}次"
common_ceng										="{p1}重"
common_rank 									="{p1}名"
common_zan 										="{p1}赞"
common_chong 									="{p1}重"
common_not_rank									="未排名"
common_not_fight								="未挑战"
common_not_know									="未知"

common_count									="获得数量：{p1}"

common_tomax_times								="已达最大{p1}次"
common_total_times								="最多累计{p1}次"
common_pay_times								="该单笔充值最多累计{p1}次"
common_buy_times 								="（剩余可购买{p1}次）"
common_reset_times 								="（剩余可重置{p1}次）"


common_login_fail								="登陆失败"

common_person  									="上阵人数：{p1}/{p2}"
common_equip_max 								="装备强化上限：{p1}级"
common_player_max	 							="神灵等级上限：{p1}级"
common_need_player_level						="需求神灵等级：{p1}"


commont_team_one								="至少上阵一个神灵"

common_coin 									="铜钱"
common_gold										="灵玉"
common_zhenqi									="真气"
common_hunpo									="魂魄"
common_level 									="经验"
common_jinglu									="精元"
common_res 										="资源"

common_not_record								="暂无记录"
common_not_more_record							="没有更多的记录了"

common_week_befor								="{p1}周前"
common_day_befor								="{p1}天前"
common_hour_befor								="{p1}小时前"
common_min_befor								="{p1}分钟前"
common_justnow									="刚刚"

common_get 										="已领取"
common_get_box									="您已经领取了该宝箱"
common_get_gold									="已领取{p1}灵玉"
common_get_award								="奖励已领取"
common_not_vip									="尚未达到相应的VIP等级"


common_round_normal								="(普通)"
common_round_high								="(困难)"
common_max_level								="满级"

common_not_contidion							="条件不满足"
common_sweep									="可扫荡"
common_not_same_hero							="仅允许上阵同一个神灵"
common_prop_not_enough = "道具不足"
common_add_coin									="增加{p1}铜钱"

-- =============================logic\activity --

activityLayer_text								 = {"聚贤斗法","无极幻境","群仙涿鹿","三垢奇阵","降妖伏魔","三清仙境"}

-- =============================logic\arena
arenafightreport_rank 							= "聚贤斗法"
arenafightreport_rank_no_change  				= "排名不变"
arenafightreport_rank_up  						= "排名升至第{p1}名"

arenafightreport_rank_text1  					= "聚贤斗法最高排名:"
arenafightreport_rank_text2  					= "主动挑战场数:"
arenafightreport_rank_text3  					= "主动挑战战绩:"
arenafightreport_rank_text4  					= "主动挑战最大连胜:"
arenafightreport_rank_text5  					= "防御战斗场数:"
arenafightreport_rank_text6  					= "被动防御战绩:"
arenafightreport_rank_text7 					= "被动防御最大连胜:"
arenafightreport_win							= "胜"
arenafightreport_lose							= "败"
arenafightreport_win_lose						="{p1}胜{p2}败"
arenafightreport_text 							= "{p1}胜{p2}败"

arenaplaylistlayer_list							= "第{p1}名"
arenaresultlayer_text1 							= "您当前的最佳排名是第{p1}名。\n比之前提升了{p2}名。"
arenarewardlayer_list							= "第{p1}-{p2}名"
-- =============================logic\army
-- =============================logic\assistFight
assistAgreeLayer_add							= "{p1}加成{p2}%"
assistAgreeLayer_text1							= "契合后，助阵神灵将自身{p1}按照百分比提供给上阵所有神灵"
assistAgreeLayer_text2							= "契合+{p1}"
assistAgreeLayer_all							= "全属性"
assistAgreeLayer_no_pro							= "契合所需物品不足	"
assistAgreeLayer_top_level						= "契合已达最高等级"
assistAgreeLayer_open							= "请先解锁"
assistAgreeLayer_up_all							= "上阵所有神灵{p1}+{p2}"
assistAgreeLayer_open = "请先解锁"
Assist_Somebody_Assist_You = "{p1}助阵您{p2}"
assistFightLayer_friend 						= "该阵容不可使用好友助阵"
assistFightLayer_vip_unlock = "{p1}解锁"
assistFightLayer_clibmLevel = "无极幻境{p1}层"
Assist_No_Assist_hero = "暂无好友助阵神灵"
Assist_UI_Assist = "累计助阵好友{p1}次"

-- =============================logic\bag
bagPieceDetailsLayer_text1						= "总计花费{p1}铜钱进行丹药炼化，是否继续？"						
bagPieceDetailsLayer_no_coin = "铜钱不足，无法完成丹药炼化"
bagPieceDetailsLayer_text1 = "总计花费{p1}铜钱进行丹药炼化，是否继续？"
bagPropDetailsLayer_number = "{p1}个"
bagPropDetailsLayer_exchange = "可兑换{p1}"
BagManager_goods_use_level = "等级达到{p1}才可以使用"
BagManager_no_enough_box = "没有足够的宝箱 [{p1}]"
BagManager_no_enough_key = "[{p1}]不足，可前往商城购买"
-- =============================logic\BaseLayer.lua
-- =============================logic\BaseScene.lua
-- =============================logic\battle
-- =============================logic\bloodFight
bloodFightArmyLayer_join						="神灵等级达到10级或以上才能参加群仙涿鹿"
bloodRewardBuy_next_box							="请您抽取一个奖励"
bloodRewardBuy_get_box_tips  					="恭喜您获得了一个奖励，消耗灵玉可购买其余两个！"
bloodBattleMainLayer_please_fight				= "请先打过{p1}"
bloodBattleMainLayer_up_vip				 		="提升VIP"
bloodBattleMainLayer_up_count			 		="今天的鼓舞次数已用完\n{v1}每天可鼓舞{p2}次"
bloodBattleMainLayer_upto_vip			 		="达到{v1}每天可鼓舞{p2}次"
bloodBattleMainLayer_box_tips				 	="顺利通过前面四关可领取宝箱"
bloodBattleMainLayer_no_times			 		="今日鼓舞次数已经用完"
bloodBattleMainLayer_reset		 				="通关关卡越多，可扫荡关卡越多，是否直接重置？"
bloodBattleMainLayer_reset_tips			 		="重置后群仙涿鹿的当前所有进度和鼓舞加成立刻清除，请确认"
bloodBattleMainLayer_up_success			 		="鼓舞成功"
bloodyQuickPassLayer_fight_index				="本次共扫荡{p1}关"
bloodBattleMainLayer_ketiaozhan					="可挑战"
BloodFightManager_weikaiqi = "未开启"
BloodFightManager_zhishaoshangzhenyiren = "至少上阵一人"
BloodFightManager_quanzhenwang = "阵上的人已全部阵亡，请重新布阵"
-- =============================logic\bossfight
bossFightMainLayer_close						="降妖伏魔已关闭！"
bossFightMainLayer_first						="您已到达第一名"
bossFightMainLayer_hurt							="{p1}伤害"
bossFightMainLayer_no_fight						="今日未挑战"
-- =============================logic\chat
chatBanned_no_speak								="请选择禁言按钮"
chatMainLayer_input								="请点击这里输入文字"
chatMainLayer_open_speak						="等级达到{p1}级可发言"
chatMainLayer_left_time							="您还有{p1}次免费聊天的次数"
chatMainLayer_buy_horn							="您没有足够的道具“千里传音符”，是否打开商城界面进行购买？"
chatMainLayer_condition							="{v1}或者等级达到{p2}级时增加免费发言次数"
chatMainLayer_no_time							="今日免费聊天次数已用完"
chatOperatePanel_no_permission					="没有权限邀请入盟"
publicMessageCell_time_out						="邀请已过期"
-- =============================logic\climb
climb_name										= "无极幻境"
carbonDetailLayer_sweep_pro						="扫荡令：{p1}"	
carbonDetailLayer_use							="每次扫荡消耗{p1}"
carbonDetailLayer_tips1							="扫荡令不足,是否花费{p1}灵玉进行扫荡？"
carbonMountain_cd								="冷却{p1}后可再挑战"
carbonMountainList_open                         ="无极幻境到达第{p1}层开放"
climbNorthLayer_reset							="是否重置当前无极幻境坤境的进度？"
climbNorthLayer_onekey_tips						="一键扫荡将会扫荡至最高一次达成所有目标的幻境层数，并自动选取消耗为9坤玉的属性，是否扫荡？"

ClimbMountainListLayer_floor_desc             	= "第{p1}层"
-- =============================logic\common
openMore_key									="钥匙数量："
openMore_box_number								="宝箱数量："
openMore_number_no_zero							="数量不能为{p1}"
replayLayer_buy_tili                            ="购买仙桃" 
replayLayer_no_tili								="体力不足"
replayLayer_buy_tili_tips						="是否花费{p1}灵玉购买{p2}点体力？"
replayLayer_today_left_times					="(今日还可以购买{p1}次)"

replayLayer_buy_climb                          ="购买幻境符" 
replayLayer_no_climb							="幻境符不足"
replayLayer_buy_climb_tips						="是否花费{p1}灵玉补充{p2}次挑战机会？"

replayLayer_buy_fight                           ="购买斗法战令" 
replayLayer_no_fight							="斗法战令不足"
replayLayer_buy_fight_tips						="是否花费{p1}灵玉购买{p2}个斗法战令？"

replayLayer_buy_skill                           ="补满技能点" 
replayLayer_no_skill							="技能点不足"
replayLayer_buy_skill_tips						="是否花费{p1}灵玉购买10点技能点？"
tipsMessage_lefttime1							="倒计时： {p1}时{p2}分{p3}秒"						
tipsMessage_lefttime2							="倒计时： {p1}天{p2}时{p3}分{p4}秒"						


-- =============================logic\default
-- =============================logic\employ
EmRoleArmyLayer_nothis_hero						="没有该神灵"
EmRoleArmyLayer_once							="每场战斗仅允许上阵一个协战"
EmSureLayer_text1								="确定雇佣玩家{p1}的神灵，需支付"
EmSureLayer_text2								="今天将不能雇佣来自{p1}的神灵"
EmTeamLayer_text1								="未派遣"
EmTeamSureLayer_text1							="确定雇佣{p1}的队伍，"
EmTeamSureLayer_text2							="今天将不能再雇佣来自{p1}的队伍"
ShowEmTeamLayer_team							="{p1}的队伍"
-- =============================logic\faction
applyLayer_exit_tips							="退出仙盟时间没有超过24小时"
applyLayer_text1								="已达到申请上限"
applyLayer_text2								="请输入仙盟ID"

appointLayer_text1								="正在禅让"
appointLayer_text2								="正在解散"
appointLayer_text3								="正在弹劾"
appointLayer_text4								="已经是长老了"
appointLayer_text5								="只能存在2位长老"
appointLayer_text6								="已经是仙盟成员了"

appointLayer_t_ren_tips							="是否确认请{p1}离开仙盟？"
appointLayer_out								="请离"
chapterListLayer_titleName						="镜中乱世({p1}):{p2}"
ChapterListLayer_progress						="进度:{p1}/{p2}"
creatFaction_input								="请输入仙盟名称"
creatFaction_create_tips						="是否花费500灵玉创建仙盟\n\"{p1}\""
creatFaction_create 							="创建仙盟"
factionApply_no_message							="列表内无申请消息"

factionInfo_text1								="盟主正在禅让"
factionInfo_text2								="仙盟正在解散"
factionInfo_text3								="盟主正在被弹劾"


factionInfo_exit_tips							="是否确认解散仙盟,仙盟解散后,\n所有仙盟成员将被强制解散"
factionInfo_exit								="解散仙盟"
factionInfo_exit_stop							="取消解散仙盟"
factionInfo_exit_stop_tips						="仙盟将在{p1}后\n解散，是否终止？"

factionInfo_exit_ok								="是否确认退出仙盟?\n(个人威望和仙盟修炼等级将保留)"
factionInfo_exit_fa								="退出仙盟"

factionInfo_xuanyan								="仙盟宣言"
factionInfo_gonggao								="仙盟公告"
factionInfo_dingji								="仙盟等级已达满级"
factionInfo_jianyan								="经验不足"
factionInfo_exit_time							="退出仙盟时间没有超过24小时"
factionInfo_edit_qizhi							="修改仙盟旗帜即将开放"
factionInfo_play_online							="玩家在线"

factionMembers_taihe_title						="弹劾"
factionMembers_taihe							="弹劾需要24小时,成功后将成为盟主,是否消耗500灵玉进行弹劾？\n（失败后会全额返还）"
factionMembers_taihe_conditidon					="盟主离线不足7天"
factionMembers_taihe_stop						="是否中断弹劾？\n(强制中断会扣除一半灵玉)"
factionMembers_taihe_suc						="您已经弹劾成功"
factionMembers_taihe_timeout					="弹劾时间已过期"
factionMembers_stop 							="终止弹劾"

factionMembers_chanrang_tips					="盟主之位将在{p1}后\n禅让，是否终止？"
factionMembers_chanrang_suc						="您已经禅让成功"
factionMembers_chanrang_timeout					="禅让时间已过期"
factionMembers_chanrang_stop					="取消禅让"

factionHomeLayer_openlevel						="珍宝阁需要仙盟等级{p1}级"
factionRename_rename							="改名需花费1张{p1}（剩余：{p2}）"
factionRename_rename_gold						="更名需花费{p1}灵玉"
factionRename_input								="请输入仙盟名"

houshanBoss_kill_tips							="获胜奖励：仙盟经验+{p1}     仙盟威望+{p2}"
houshanBoss_lefttimes							="今日剩余次数："
houshanRank_rank								="未上榜"
houshanLayer_chapter							="（{p1}） {p2}"
houshanLayer_times								="今日挑战次数："
houshanReward_hurt								="累计输出:{p1}/{p2}"
rankingList_text								={"仙盟等级","仙盟战力"}
zhongyi_add1									="仙盟威望+{p1}"
zhongyi_add2									="仙盟经验值+{p1}"
zhongyi_add3									="个人威望+{p1}"
zhongyi_text1									="捐献成功"
zhongyi_text2									="仙盟今日捐献{p1}次已达到上限"
-- =============================logic\factionMall
-- =============================logic\factionPractice
practiceChooseLayer_check_hero					="请选择神灵"
practiceInResult_level							="{p1}等级"
practiceInResult_attr							="{p1}属性"
practiceResult_level  							="修炼等级"
practiceStudyLayer_open_suc						="开启成功"
practiceStudyLayer_yanjiu_suc					="研究成功"
PracticeInherit_cost							= "传承需要消耗{p1}灵玉"
PracticeInherit_desc1							= "请选择传承神灵"
PracticeInherit_desc2							= "请选择受传承神灵"
PracticeInherit_desc3							= "暂无可传承技能"

-- =============================logic\fight
fight_FightUiLayer_auto_open 					= "VIP等级{p1}级或等级{p2}级开启"

-- =============================logic\friends
friendInfoLayer_faction							="仙盟:{p1}"
friendInfoLayer_add_friend						="请先添加好友！"
friendInfoLayer_dele_friend						="是否删除该好友？"
-- =============================logic\gameactivity
goldEggItem_hammer_type							={"??1", "??2"}
goldEggItem_no_hammer							="没有足够的{p1}"
goldEggMain_egg_type							={"??3", "??4"}
goldEggMain_number								="(当前拥有{p1})"
goldEggRecord_history							="没有更多的砸蛋历史了"
goldEggRecord_player_history					={"??5", "??6"}
goldEggRole_zhuanhuan							="此神灵自动转换为{p1}张同角色精魄"
activity_comm_pay								="连续充值第{p1}天"
activity_moneyshop_desc							={"??7", "??8", "??9"}
activity_moneyshop_buy_tips						="是否消耗{p1}灵玉购买{p2}？\n\n(活动期间只能购买一种通宝)"
activity_moneyshop_buy_suc						="购买{p1}成功"
activity_online_award							="请先领过前面的在线奖励"
exchangeCell_times_over							="兑换次数已用完"
exchangeCell_not_enough							="您的{p1}不足"
exchangeCell_exchange_tips						="是否确认使用 [{p1}] 兑换 [{p2}] ?"
rewardItemcommmon_wan							="{p1}万"
activity_min_score								="当前排名段最低积分"
activity_rank_reward1							="活动积分第{p1}-{p2}名奖励"
activity_rank_reward2							="活动积分第{p1}名奖励"
activity_user_reward							="第{p1}名:{p2}"
goldEggMain_get 								="{p1}获得了"

activity_recharge_text							="当前充值"
activity_recharge_min_score						="当前排名段最低充值"
activity_recharge_rank_reward1					="活动充值第{p1}-{p2}名奖励"
activity_recharge_rank_reward2					="活动充值第{p1}名奖励"

-- =============================logic\hermit
eatRoleIcon_tips1								="该神灵身上已穿戴装备，系统将自动卸下装备进行归隐"
eatRoleIcon_tips2								="该神灵身上已穿戴装备，系统将自动卸下装备进行重生"
roleFireLayer_tips1								="请放入需归隐的神灵/精魄"
roleFireLayer_tips2								="本次归隐包含高品阶神灵或精魄，将获得："
roleFireLayer_tips3								="本次归隐将获得："
roleFireLayer_tips4								="一次只能归隐6人"
roleFireLayer_not_delete						="没有可删除的精魄"
roleReBirthLayer_getplayer						="请选取重生的神灵"
roleReBirthLayer_award1							="本次重生包含高品阶神灵，将获得"
roleReBirthLayer_award2							="本次神灵重生将获得："
roleReBirthLayer_count							="一次只能重生1人"
roleReBirthLayer_not							="没有可重生的神灵"
-- =============================logic\home
menuLayer_monthcard								="至尊月卡"
menuLayer_monthcard_addattr						="您是尊贵的至尊月卡会员，月卡持续时间内主角额外获得：\n基础属性 =  500 + 等级*20"
menuLayer_chat1									="[世界]"
menuLayer_chat2									="[仙盟]"
menuLayer_chat3									="[好友]"
-- =============================logic\illustration
IllEquDetaLayer_growup							="{p1}成长:"
IllEquDetaLayer_base							="基础{p1}:"
IllOutputLayer_Desc								={"历练关卡", "聚贤斗法", "无极幻境", "三垢奇阵", "巡山", "太公钓鱼", "商店", "聚仙许愿" ,"金宝箱", "银宝箱", "", "", ""}
IllOutputLayer_base								="(普通)"
IllOutputLayer_big								="(困难)"
IllOutputLayer_tianshu							="(历劫)"
IllRoleDetaLayer_unlock							="{p1}品解锁"
-- =============================logic\item
-- =============================logic\leaderboard
leaderboard_not_times							="剩余点赞次数不足!"
leaderboard_update								="排行榜信息更新"
-- =============================logic\login
createPlayer_check_player						="请选择角色"
createPlayer_input_player						="请输入角色名"
createPlayer_not_player							="角色不存在"
createPlayer_create_fail						="创建角色失败"

createPlayer_namelist = 
{
	[1] = "吕洞宾",
	[2] = "嫦娥",
	[3] = "聂小倩",
	[4] = "姜子牙",
}

createPlayer_desc = 
{
	[1] = "纯阳剑气无往不利",
	[2] = "明月照耀扭转战局",
	[3] = "摄魂大法夺人心魄",
	[4] = "打神鞭法攻守兼备",
}

loginLayer_no_obb								="obb文件不存在，请重新下载"
loginLayer_input_account						="请输入账号"
loginNoticePage_check_server					="请选择区服"
loginNoticePage_please_login					="请登录账号"
loginNoticePage_login_fail						="登陆失败"
loginNoticePage_getserver_fail					="获取区服列表失败,是否重试?"
serverChoice_stop								="{p1}(维护中)"
serverChoice_serverstop							="服务器维护中"

update_error_storage							="存储容量不足"
update_error_req_ver							="请求版本错误"
update_error_parse_ver							="解析版本错误"
update_error_version							="更新版本错误"
update_error_no_network							="检查网络是否已连接，点击确认重试！"
updateLaye_check_resource						="正在检测最新资源"
updateLaye_update_tips							="正在更新，已下载{p1}%  ({p2}K/{p3}K)"
updateLaye_update_fail							="资源更新失败"
updateLaye_update_desc							="检测到新资源，共计{p1}\n\n目前不是WIFI网络，是否马上更新？"
updateLaye_update_lala							="更新资源啦"
updateLaye_update_ok							="更新"
updateLaye_update_confirm						="确认"
updateLaye_resource_version						="资源版本:{p1}"
updateLaye_check_resource_update				="检查资源更新"
updateLaye_check_resource_update_fail			="检查资源更新失败，是否重试"
updateLaye_update_fail_check_net				="资源更新失败，请检查您的网络后重试"
updateLaye_reset								="重试"

updatelayerNew_check_new_resource				="检测到有新的更新内容，共{p1}"
updatelayerNew_unZip_resource					="下载完成解压资源"
updatelayerNew_curr_version						="当前版本:{p1}"

createPlayer_firstname = {"上神","上仙","三界","六道","天仙","地仙","人仙","无极","玄天",}
createPlayer_secondName ={"真人","佳人","法力","气血","武力","身法","法力","暴击"}
-- =============================logic\main
fightLoadingLayer_loading						="正在载入资源···  {p1}%"
fightLoadingLayer_loading_over					="载入完成 ，正在进入"
mainPlayerLayer_max_level						="满级"
ReNameLayer_input								="请您输入尊姓大名"
mainPlayerLayer_tuhao_xuanyan                   ="VIP宣言"
-- =============================logic\mall
buyCoinLayer_crit								="暴击x{p1}"
randomStoreShopLayer_buy_number					="购买个数不可小于 1 "

xiakezhuanhuan_role_not_enough                  ="请选择转换神灵"
xiakezhuanhuan_select_role                      ="请选择转魂的神灵"
xiakezhuanhuan_change_role                      ="是否确认神灵转魂？"
xiakezhuanhuan_xiulianzhong                     ="该神灵正在仙盟修炼中"
xiakezhuanhuan_fail                             ="转魂失败"
xiakezhuanhuan_success                          ="转魂成功"
xiakezhuanhuan_same_quality                     ="非同品质神灵不可转魂"
-- =============================logic\message
-- =============================logic\mining
chooseMinLayer_trace							="微量"
chooseMinLayer_little							="少量"
chooseMinLayer_free								="免费次数:{p1}"
LootEmBattleLayer_fight_time					="战斗倒计时"
LootEmBattleLayer_tips1							="还有护送者未击败，是否继续退出？"
LootEmBattleLayer_tips2							="还有寻宝者未击败，是否继续退出？"
LootEmBattleLayer_not_reset						="满血时不能重置"
MiningFightReLayer_baoshidengji					={"一级","二级"}
MiningFightReLayer_dajie						="第{p1}次寻得先机"
MiningLayer_benzhoubeiguyong					="本周已被雇佣："
MiningLayer_text1								="本周已被雇佣："

-- =============================logic\mission
missionAuto_cost								="(预计花费：{p1}"
missionAuto_times								="挑战{p1}次)"
missionAuto_tomorrow							="请您明天再来吧，"
missionAuto_vip									="VIP不足"
missionAuto_vip_reset							="{v1}可重置挑战次数"
missionAuto_reset 								="是否花费{p1}灵玉重置此关卡挑战次数？"
missionAuto_reset_over							="\n\n(今日重置次数已用完)"
missionAuto_reset_times							="\n\n(今日还可以重置{p1}次)"
missionDetail_xiaohao							="每次扫荡消耗{p1}"
missionDetail_today_free						="今日免费扫荡：{p1}次"
missionDetail_sweep								="{v1}开启一键扫荡多次功能。\n\n是否前往充值？"
missionDetail_upvip								="提升至{v1}可每日购买挑战次数{p2}次。\n\n是否前往充值？"
missionDetail_upvip_over						="今日购买次数已用完！\n\n提升至{v1}可每日购买挑战次数{p2}次。\n\n是否前往充值？"
missionDetail_all_over							="挑战次数已用完，今日重置次数已用完"
missionDetail_reset								="此次重置需要重置令{p1}个，是否确定重置？"
missionDetail_reset_text						="\n\n(当前拥有重置令：{p1},今日还可以重置{p2}次"
missionDetail_sweep_times						="剩余免费次数和扫荡令总和不足,是否花费{p1}灵玉进行扫荡？"
missionDetail_fight								="可挑战"
missionLayer_please								="请先通关\"{p1}{p2}-{p3}\"!"
missionLayer_start								="要全部点亮三朵金莲"
StarBoxPanel_stars								= "点亮{p1}朵金莲后可领取"
-- =============================logic\notify
notifyInfoLayer_fight_text1						="{p1}不自量力，在聚贤斗法中向您发起挑战，被您轻松击退"
notifyInfoLayer_fight_text2						="{p1}计胜一筹，在聚贤斗法中击败了您，您的斗法排名降至{p2}"
notifyInfoLayer_start_text1						="{p1}在江湖宝藏中试图抢占您的星位，您成功的将其击退"
notifyInfoLayer_start_text2						="{p1}在江湖宝藏中抢夺了您的星位，您获得了占位奖励：{p2}个碎片"
-- =============================logic\p.txt
-- =============================logic\pay
vipQQLayer_title1								="专属通道"
vipQQLayer_content1								="这里有贴心的专属美女客服服务哦~"
vipQQLayer_title2								="优先权"
vipQQLayer_content2								="不管是什么活动都能第一时间知晓呢~"
vipQQLayer_title3								="福利"
vipQQLayer_content3								="还有随时可以领的专属礼包和超值福利"
vipQQLayer_title4								="终身制"
vipQQLayer_content4								="终身享受哦~"
vipQQLayer_input_qq								="点击输入QQ号"
vipQQLayer_copy_suc								="复制成功"
vipQQLayer_please_input							="请输入qq号码"
vipQQLayer_submit								="已成功提交QQ号"
MonthCardLayer_tianshu 							= "持续 {p1} 天"
Pay_multiple_txt	 							= "{p1} 元充值"

-- =============================logic\playerback
playerbackMain_not_task							="没有可领取任务"
playerbackReward_code							="请输入好友邀请码"
playerbackReward_code_null						="邀请码不能为空"
-- =============================logic\qiyu
EscortingLayer_today_over						="今日奖励已领完"
EscortTranLayer_yabiao_times_over				="今天的钓鱼次数已经用完"
EscortTranLayer_vip								="{v1}开放立即收获"
InFriendAccLayer_invite							="您已被邀请"
InFriendAccLayer_input_invite_code				="请输入邀请码"
InFriendAccLayer_char							="输入的邀请码包含了非法字符"
InFriendAccLayer_already						="已经被邀请过了"
InFriendAccLayer_not							="您还未接受邀请"
InFriendLayerNew_desc							="低于{p1}级的玩家可以接受他人邀请，成功受邀会有丰厚奖励！"
InFriendSendLayer_desc1							= "千古传说，上下五千。全新横版回合制战斗游戏， 四大主角，数百名神话人物任您挑选，对白搞趣幽默，仙家法术无往不利，御用法宝千变万化，快来和我一起玩吧！我在"
InFriendSendLayer_desc2 						= "服务器，您可以在奇遇邀请码中，点击受邀有礼，输入并验证我的账号"
InFriendSendLayer_desc3 						= "，即有豪礼相送！"
InFriendSendLayer_share							="已复制成功，快去您的微信分享吧！"
monthCardBuy_buy_suc							="月卡购买成功"
monthCartGet_already							="今天已经领过灵玉了"
-- =============================logic\role
dogfoodIcon_chuangong							="该神灵身上已穿戴装备，请先卸下装备再进行修炼"
equipOutLayer_chapter							="关卡尚未解锁，请先通关之前的关卡"
equipOutLayer_qunhao							="聚贤斗法尚未解锁"
mainSkillList_max								="已到达上限"
mainSkillList_wuxue								="境界{p1}重解锁"
mainSkillList_player							="主角{p1}级可用"
RoleTransferLayer_resetDesc						="没有选择任何修炼材料，无需重置！"
RoleTransferLayer_tishi							="消耗的卡牌中，存在天阶或地阶的精魄或神灵，若继续修炼则这些精魄或神灵将转换为经验值。\n是否确定继续修炼？"
RoleTransferLayer_max_level 					= "等级到达上限"
RoleTransferLayer_add_level						= "+{p1}级"
role_train_names = {"金","木","水","火","土","炼体"}
-- =============================logic\rolebook
roleBook_enchant_kulian							="淬炼成功"
roleBook_enchant_max_level						="已满级"
roleBook_enchant_tips1							="炼化的丹药中，存在高品质的丹药，若继续消耗则这些丹药将转换为淬炼经验值。\n是否确定继续修炼？"
roleBook_enchant_not_check						="您还没有选择合成材料"
roleBook_enchant_open							="一键淬炼将在{v1}开启"
roleBook_enchant_max_qinxue						="已经是最高等级，不能再淬炼了"
roleBook_enchant_yijian							="是否消耗{p1}灵玉进行一键淬炼"
roleBook_enchant_yijian_tips					="一键淬炼"
roleBook_enchant_hecheng						="没有足够的丹药用于炼化"
roleBook_enchant_out_level						="已经是最高等级"
roleBook_hecheng_not_hecheng					="丹药不能再炼化了"
roleBook_hecheng_not_cailiao					="材料不足不能合成"
roleBook_equip_book								="拥有{p1}本"
roleBook_equip_level_notenough					="角色等级不足，不能炼化此丹药"
-- =============================logic\role_new
MeridianLayer_text1								="炼体已经达到当前最高等级"
qimenduntupo_text1								="四象{p1}重"
qimenduntupo_text2								="全体神灵"
roleInfoLayer_max								="当前境界已达最高境界"
roleInfoLayer_py_max							="已修炼至最高级"
roleInfoLayer_py_vip							="一键配制开放需要VIP{p1}级"
roleInfoLayer_py_yijian							="本次一键配制总计花费{p1}铜钱进行炼丹合成，是否继续？"
roleInfoLayer_py_not							="铜钱不足，无法完成炼丹合成"
roleInfoLayer_py_condition						="炼化所有丹药后才可进阶"
roleInfoLayer_py_unlock							="{p1}重解锁"
roleInfoLayer_py_wuxue							="境界{p1}重"
roleInfoLayer_py_goto							="请前往三垢奇阵获取更多的主角精魄"
roleQualityUp_notenough							="升品所需道具不足"
roleQualityUp_tupo1								="突破四象{p1}重"
roleQualityUp_tupo2								="主角进阶至{p1}星"
roleQualityUp_jihuo								="{p1}星激活"
roleStartupPre_needlevel						="需求等级:{p1}"
roleStartupPre_xiahun							="精魄不足"
roleStartupPre_player							="神灵等级不足"
roleStartupPre_pro								="进阶道具不足"
roleStartupPre_msg								=
{
"1.可使用魂玉在商店-神灵殿中兑换",
"2.可在商店中购买",
"3.可在聚贤斗法处使用积分兑换",
"4.可在困难关卡中获得",
"5.可在群仙涿鹿、三垢奇阵获得精魄"
}
roleStartupPre_desc								= {"气血成长", "武力成长", "防御成长", "法力成长", "身法成长"}
trainLayer_trainNames							={"金","木","水","火","土","炼体"}
trainLayer_not									="该炼体等级不足"
trainLayer_chengzhang							="{p1}成长"
not_enough_jinglu								= "没有足够的精元"
-- =============================logic\SceneType.lua
-- =============================logic\setting
changetProLayer_have							="（拥有：{p1}）"
exchangeLayer_code								="请输入礼包码"
ChangeProfessionLayer_zhuanhuandanbuzu  		= "孟婆汤不足"
ChangeProfessionLayer_zhuanhuantishi			="是否确认转换主角？"

settingManager_text_vip                         ="显示VIP等级"
settingManager_text_not_show_vip                ="隐藏VIP"
settingManager_text_show_vip                    ="显示VIP"

-- =============================logic\sevendays
sevendays_activity_over							="离活动结束:"
sevendays_getaward_over							="离领奖结束:"
sevendays_tomorrow_login						="明天也要记得登陆哟"
sevendays_task_radio							="未完成({p1}/{p2})"
sevendays_over 									="已完成"
sevendays_buy									="仅限前{p1}人购买(剩余{p2}件)"
-- =============================logic\shop
getRoleLayer_free								="可免费获取"
getRoleLayer_time_free							="{p1}后免费"
qiyuanLayer_free								="{p1}:{p2}后免费"
qiyuanLayer_free_times							="免费({p1}/{p2})"
qiyuanLayer_buy									="是否花费{p1}灵玉购买{p2}个{p3}精魄？"
qiyuanLayer_check								="请先选择祈愿的神灵"
qiyuanLayer_qiyuan								="当前还有精魄未购买，是否确定祈愿？"
qiyuanLayer_check_free							="选择神灵，可免费获得该神灵精魄"
youfangLayer_no_data = "游方商人没有东西卖"
-- =============================logic\smithy
smithy_attr_unknow 				= "未知"
smithy_EquipmentRefining_toBuy = "您没有足够的道具[精炼石]，是否打开商城界面进行购买？"
smithy_EquipmentRefining_jlsbuzu = "精炼石不足"
smithy_EquipmentRefining_jl1 	= "一键精炼将自动为您精炼{p1}次，最多消耗{p2}灵玉,精炼满将自动停止，是否确认？"
smithy_EquipmentRefining_jl2 	= "一键精炼将自动为您精炼{p1}次,精炼满将自动停止，是否确认？"
smithy_EquipmentRefining_max 	= "属性全部达到最大值"
smithy_EquipmentRefining_own 	= "(拥有 {p1})"
smithy_EquipmentRefining_vip 	= "{v1}可用"
smithy_EquipmentRefining_max	="(已精炼至满级)"
smithy_EquipmentRefining_level	="(需装备强化{p1}级)"
smithy_EquipmentRefining_pro	="物品不足"
smithy_EquipmentRefining_maxlevel = "您已突破到最高等级"
smithy_EquipmentRefining_qianghua	="装备强化到{p1}级可继续突破"
smithy_EquipmentStarUp_base1	="基础武力："
smithy_EquipmentStarUp_add1		="武力成长："
smithy_EquipmentStarUp_base2	="基础防御："
smithy_EquipmentStarUp_add2		="防御成长："
smithy_EquipmentStarUp_base3	="基础法力："
smithy_EquipmentStarUp_add3		="法力成长："
smithy_EquipmentStarUp_base4	="基础血气："
smithy_EquipmentStarUp_add4		="血气成长："
smithy_EquipmentStarUp_base5	="基础身法："
smithy_EquipmentStarUp_add5		="身法成长："
smithy_EquipmentStarUp_check	="请选择材料"
smithy_EquipmentStarUp_max		="一次升星，道具上限为5件"
smithy_EquipmentStarUp_suc		="成功率已经达到[100%]，无需再选择新的装备"
smithy_EquipmentStarUp_start	="星级到达上限"
smithy_EquipmentStarUp_radio	="升星失败,累计补偿成功概率[{p1}%]"
smithy_EquipmentStarUp_fail		="升星失败"
smithy_EquipmentStarUp_text1	="您选择的装备已经镶嵌宝石，是否确认选择消耗此装备？"
smithy_EquipmentStarUp_text2	="您选择的装备是已经升星，是否确认选择消耗此装备？"
smithy_EquipmentStarUp_text3	="您选择的装备是已经强化过，是否确认选择消耗此装备？"
smithy_EquipmentStarUp_text4	="您选择的装备是稀有品质，是否确认选择消耗此装备？"
smithy_EquipPractice_store_tips	="您没有足够的道具[洗炼石]，是否打开商城界面进行购买？"
smithy_EquipPractice_not_store	="洗炼石不足"
smithy_EquipPractice_all		="所有属性都已上锁"
smithy_EquipPractice_ok_tips	="锁定属性将花费您{p1}灵玉，是否确认洗炼？"
smithy_EquipPractice_tips1		="洗练将会随机更换装备附加属性，是否开始洗练？"

smithy_EquipSell_max_equip		="最多可以选择15件装备!"
smithy_EquipSell_not_check		="您没有选择装备！"
smithy_EquipSell_sell			="本次出售装备可获得："
smithy_EquipIcon_open			="等级达到{p1}级开启装备"
smithy_EquipGem_not_gem			="没有镶嵌宝石"
smithy_EquipGem_xiangqian		="该装备不可镶嵌{p1}宝石"

smithyGemBuild_check_store		="请选择您需要合成的宝石"
smithyGemBuild_not_store		="宝石数量不足"
smithyGemBuild_not_coin			="铜钱数量不足"
smithyGemBuild_not_change		="正在自动合成，不可点击更换目标"
smithyGemBuild_not_find			="该宝石数据无法找到"
smithyGemBuild_max				="该宝石已经是最高等级了"
smithyGemBuild_not_in_bag		="背包中没有该宝石"
smithy_gem_not_six				="没有低于6级可合成的石头"
smithyIntensify_max				="已经达到最高等级不能再强化"
smithyIntensify_level			="最高可强化等级：{p1}"
smithyIntensify_not				="{p1}不足"
smithyRecast_tips				="重铸消耗的{p1}经过{p2}强化，是否确认消耗用来重铸？(重铸会返还部分材料)"
smithyRecast_uplevel			="/升级"
smithyRecast_upstart			="/升星"
smithyRecast_upjinglian			="/精炼"
smithyRecast_uprecast			="/重铸"
-- =============================logic\task
-- =============================logic\test
-- =============================logic\weekrace
weekrace_timeFont = {
    {
        "押注剩余时间:",
        "八进四战斗中:",
        "半决赛开始剩余时间:",
    },
    {
        "押注剩余时间:",
        "半决赛战斗中:",
        "总决赛开始剩余时间:",
    },
    {
        "押注剩余时间:",
        "总决赛战斗中:",
    }
}

weekrace_race_no_start = "比赛尚未开始"

weekrace_recordTitleFont = {
	{
		"八进四第一场",
		"八进四第二场",
		"八进四第三场",
		"八进四第四场"
	},
	{
		"半决赛第一场",
		"半决赛第二场"
	},
	{
		"总决赛"
	}
}

weekrace_yazhu = "押注不能小于{p1}"



-- =============================logic\zhengba
zhengba_ZhengbaLayer_huodongweikaiqi = "活动还未开始"
zhengba_ZhengbaLayer_shengfu = "{p1}胜{p2}负"
zhengba_ZhengbaLayer_jiliansheng = "{p1}连胜"
zhengba_ZhengbaLayer_no_jion = "未参加"
zhengba_ZhengbaLayer_no_rank = "未上榜"
zhengba_ZhengbaLayer_no_prize = "已领取完毕"
zhengba_ZhengbaLayer_liansheng = "取得进攻{p1}连胜"
zhengba_ZhengbaLayer_duizhan = "进行{p1}次对战"
zhengba_ZhengbaLayer_jifen = "积分：{p1}"
zhengba_ZhengbasaiArmyVSLayer_tishi = "本次退出对战，将会在接下来的30秒内不能再进行对战，是否退出？"

-- =============================gamedata\ActivityManager.lua
-- =============================gamedata\ArenaManager.lua
-- =============================gamedata\AssistFightManager.lua
-- =============================gamedata\BagManager.lua
BagManager_goods_use_level  = "等级达到{p1}才可以使用"
BagManager_no_enough_box  	= "没有足够的宝箱 [{p1}]"
BagManager_no_enough_key  	= "[{p1}]不足，可前往商城购买"
BagManager_toast_text1 = "该物品不是宝箱和钥匙：{p1}"
BagManager_unlock_no_compound = "不能合成已解锁的头像框"
BagManager_buzu_no_compound = "道具数量不足，不能合成头像框!"
BagManager_compound_success = "合成{p1}成功"


-- =============================gamedata\BloodFightManager.lua
BloodFightManager_weikaiqi  			= "未开启"
BloodFightManager_zhishaoshangzhenyiren  = "至少上阵一人"
BloodFightManager_quanzhenwang  		= "阵上的人已全部阵亡，请重新布阵"

-- =============================gamedata\BossFightManager.lua
BossFightManager_no_changlle_time = "今日挑战次数已用完"

-- =============================gamedata\CardRoleManager.lua
CardRoleManager_shifoguiyin = "该神灵正在被使用,是否确认归隐？"

-- =============================gamedata\ChatManager.lua
ChatManager_level_limit = "{p1}级才能使用世界聊天"
ChatManager_no_tool 	= "没有千里传音符"
ChatManager_empty_msg 	= "聊天消息不能为空"
ChatManager_same_msg 	= "您说得太快啦，喝口茶休息下呗"
ChatManager_cd_msg 		= "发言还剩{p1}秒"
ChatManager_no_friend 	= "对方已不是您的好友"
ChatManager_forb_chat 	= "禁言成功"
ChatManager_jubao 		= "举报成功"
ChatManager_jubao_1 		= "{p1}因发送内容不当,禁言 {p2} 天"
ChatManager_jubao_2 		= "{p1}因发送内容不当,禁言 {p2} 小时"
ChatManager_level_limit2 = "{p1}级才能使用跨服聊天"


-- =============================gamedata\ClimbManager.lua
-- =============================gamedata\CommonManager.lua
CommonManager_good_num_desc = "{p1}{p2}个"
CommonManager_good_duihuan = "可兑换{p1}"
CommonManager_change_name = "更名成功"
CommonManager_other_user_login = "您的账号在别处登录！重新登录？"
CommonManager_new_version  = "发现了一个新版本，是否立即更新？"
CommonManager_update_version1  = "更新资源啦"
CommonManager_update_version2  = "更新"
CommonManager_vip_up = "提升VIP"

CommonManager_need_vip  = "{v1}方可购买体力。\n\n是否前往充值？"
CommonManager_need_vip2 = "{v1}方可购买幻境符。\n\n是否前往充值？"
CommonManager_need_vip3 = "{v1}方可购买斗法战令。\n\n是否前往充值？"
CommonManager_need_vip4 = "{v1}方可使用灵玉购买技能点。\n\n是否前往充值？"

CommonManager_need_up_vip  = "今日购买次数已用完！\n\n提升至{v1}可购买{p2}次。\n\n是否前往充值？"
CommonManager_need_up_vip2 = "今日购买次数已用完！\n\n提升至{v1}可使用灵玉购买{p2}次。\n\n是否前往充值？";

CommonManager_out_time = "购买次数已用完"
CommonManager_out_time_today = "今日购买次数已用完"
CommonManager_out_time_today2 = "体力不足，今日购买次数已用完"
CommonManager_out_time_today3 = "幻境符不足，今日购买次数已用完"
CommonManager_out_time_today4 = "斗法战令不足，今日购买次数已用完"
CommonManager_out_time_today5 = "技能点不足，今日购买次数已用完"

CommonManager_tili_not_enough = "体力不足"
CommonManager_wuliangshanshi_not_enough = "幻境符不足"
CommonManager_challenge_not_enough = "斗法战令不足"
CommonManager_skillpoint_not_enough = "技能点不足"

CommonManager_tili_zengjia = "体力增加{p1}"
CommonManager_wuliangshanshi_add = "幻境符增加{p1}"
CommonManager_challenge_increase = "斗法战令增加{p1}"

CommonManager_relogin = "游戏好像出错了，请点击“重新登录”再次尝试。"
CommonManager_update = "更新资源啦，\n\n当前版本：{p1};最新版本：{p2}" 
CommonManager_update_now = "立即更新"

CommonManager_number = "{p1}个"
CommonManager_choose_server = "请选择服务器"




-- =============================gamedata\EmployManager.lua
EmployManager_role_is_full  = "放置角色已满"



-- =============================gamedata\EquipmentManager.lua
EquipmentManager_equip_wufaxilian  = "低级装备无法洗炼"

-- =============================gamedata\ErrorCodeManager.lua
ErrorCodeManager_unknowen_error = "未知错误{p1}"
-- =============================gamedata\FactionManager.lua

FactionManager_msgPostTemplate = {
	"盟主",
	"长老",
	"成员"
}
FactionManager_msgDrinkTemplate = {
	"绵薄之力",
	"恰如其分",
	"豪情万丈"
}

FactionManager_msgRecordTemplate = {
	"{p1}加入仙盟，仙盟又壮大了一分",
	"{p1}退出了仙盟",
	"经过仙盟每一位成员的努力，仙盟升到{p1}级！",
	"{p1}{p2}进行了{p3}的捐献来救济三界。",
	"{p1}被禅让为盟主，24小时后生效",
	"{p1}被任命为长老",
	"{p1}被降职为成员",
	"{p1}被请离仙盟",
	"盟主取消了禅让",
	"恭喜{p1}成为新盟主，仙盟必将更加强大！",
	"盟主长期没有上线，受到弹劾，24小时后生效",
	"弹劾成功，恭喜{p1}成为新盟主",
	"盟主{p1}及时上线，弹劾失败",
	"{p1}取消弹劾",
	"-----",
	"-----",
	"仙盟完成镜中乱世（{p1}）的首次通关，它将永久保存在排行榜中",
	"本仙盟在镜中乱世（{p1}）通关速度上升为第{p2}名",
	"{p1}击杀了{p2}，仙盟获得{p3}经验，{p4}仙盟威望",
	"{p1}开启了镜中乱世（{p2}）",
	"{p1}开启了镜中乱世（{p2}）",
	"玄清洞{p1}开启",
	"仙盟改名为“{p1}”，真是个响亮的名字",
	"仙盟修改旗帜成功",
}


FactionManager_create_fation  	="恭喜您创建了自己的仙盟！"
FactionManager_join_fation  	="恭喜您加入仙盟！"
FactionManager_leave_fation 	= "您被请离了仙盟"
FactionManager_jiejiao_fation 	= "结交成功,增加{p1}点体力"
FactionManager_shanrang_fation 	= "您已经将盟主之位禅让于人，请等待24小时"
FactionManager_shanrang_qx  	= "您已取消禅让"
FactionManager_rengming  		= "任命成功"
FactionManager_24_jiesan  		= "仙盟将于24小时后解散"
FactionManager_zhongzhi_jiesan 	= "已终止解散仙盟"
FactionManager_modify 			= "内容已修改"
FactionManager_open_practice 	= "玄清洞{p1}开启"
FactionManager_open_practice2   = "玄清洞{p1}开启，大家可以去修炼了"
FactionManager_uplevel_practice = "玄清洞{p1}等级研究到{p2}级"
FactionManager_uplevel_practice2 = "玄清洞{p1}等级研究到{p2}级，大家可以去升级了"
FactionManager_kill_boss        = "{p1}在镜中乱世（{p2}）击败了{p3}，奖励已通过邮件发送！"
FactionManager_modify_qizhi     = "仙盟改名为“{p1}”，真是个响亮的名字！"
FactionManager_modify_qizhi2     = "仙盟修改旗帜成功，各位快去围观吧"
FactionManager_xx_join_fation      = "{p1}成功加入仙盟"
FactionManager_clear_msg      	= "已清空申请消息"
FactionManager_invite_suc      = "邀请成功"
FactionManager_invite_req      = "“{p1}”邀请您加入{p2}，是否同意？"
FactionManager_time      		= "{p1}小时{p2}分钟"
FactionManager_houshan_dengji      		= "镜中界需要仙盟等级{p1}级开启"

-- =============================gamedata\FactionPracticeManager.lua
-- =============================gamedata\FateManager.lua
-- =============================gamedata\FightManager.lua
-- =============================gamedata\FriendManager.lua
FriendManager_list_req_all = "列表内已全部申请"
FriendManager_list_req_send = "已发送申请"
FriendManager_list_empty = "列表内无申请消息"
FriendManager_gift_all = "所有好友已赠送礼物"
FriendManager_gift_get = "所有礼物已领取"
FriendManager_login_time_now = "刚刚"
FriendManager_login_time_min = "最近登录：{p1}分钟前"
FriendManager_login_time_hour = "最近登录：{p1}小时前"
FriendManager_login_time_day = "最近登录：{p1}天前"
FriendManager_login_time_week = "最近登录：{p1}周前"

FriendManager_login_time_min_ex = "{p1}分钟前"
FriendManager_login_time_hour_ex = "{p1}小时前"
FriendManager_login_time_day_ex = "{p1}天前"
FriendManager_login_time_week_ex = "{p1}周前"

-- =============================gamedata\.lua
GameActivitiesManager_no_acitivty = "没有开启的活动"
GameActivitiesManager_online_yiwan = "今日在线奖励已领完"
GameActivitiesManager_online_shijianweidao = "倒计时未到"
GameActivitiesManager_not_open_activity = "还没有开启的活动"

GameActivitiesManager_yuanbao 			= "灵玉"
GameActivitiesManager_day 				= "天"
GameActivitiesManager_leijichongzhi 	= "累计充值"
GameActivitiesManager_danbichongzhi 	= "单笔充值"
GameActivitiesManager_leijixiaofei 		= "累计消费"
GameActivitiesManager_tianshu 			= "连续天数"
GameActivitiesManager_denglu 			= "登录第"
GameActivitiesManager_dengji 			= "等级达到"
GameActivitiesManager_dijitianleichong	= "第{p1}天累充"
GameActivitiesManager_dijitian = "第{p1}天..."

-- =============================gamedata\GameResourceManager.lua

-- =============================gamedata\GetCardManager.lua
-- =============================gamedata\GoldEggManager.lua
GoldEggManager_no_eggacitivty = "??10活动未开启"
GoldEggManager_type = {"???11","???12"}

-- =============================gamedata\HoushanManager.lua
-- =============================gamedata\IllustrationManager.lua
IllustrationManager_tips = 
{

	[1] = "关卡尚未开启",
	[2] = "聚贤斗法尚未开启",
	[3] = "无极幻境尚未开启",
	[4] = "三垢奇阵尚未开启",
	[17] = "日常尚未开启",
	[18] = "群仙涿鹿尚未开启",
	[20] = "祈愿尚未开启"
}
IllustrationManager_not_open = "祈愿尚未开启"

-- =============================gamedata\MainPlayer.lua
MainPlayer_money_desc 			= "{p1}万"
MainPlayer_tili_tixing 			= "体力值都满了，再不使用就都浪费了！"
MainPlayer_tili_name 			= "推图体力"
MainPlayer_jinengdian_tixing 	= "上仙，技能点都回满了，快去升级技能吧！"
MainPlayer_jinengdian_name 		= "技能点"
MainPlayer_double_exp			= "多倍经验"
MainPlayer_no_double_exp		= "没有多倍经验加成"
MainPlayer_double_desx			= "恭喜玩家获得多倍经验加成！\n双倍时间内从关卡获得的等级与神灵\n经验奖励提高为 {p1} 倍"

-- =============================gamedata\MallManager.lua
MallManager_refresh_tool			= "此次刷新需要刷新令{p1}个，是否确定刷新？\n\n(当前拥有刷新令：{p2})"
MallManager_mall_open				= "{p1}开启"
MallManager_up_vip_tip = "今日购买次数已用完！\n\n提升VIP可获得更多购买次数。\n\n是否前往充值？"
MallManager_vip_up = "提升VIP"
MallManager_out_time = "购买次数已用完"
MallManager_out_time_tip = "今日购买次数已用完,不能再购买该物品"
MallManager_refresh_tip = "此次刷新需要刷新令{p1}个，是否确定刷新？"

-- =============================gamedata\MiningManager.lua
MiningManager_no_mine_user 		= "暂时没有寻宝玩家"
MiningManager_no_fight_report	= "没有详细的战报"

-- =============================gamedata\MissionManager.lua
MissionManager_mission_typy1 = "普通"
MissionManager_mission_typy2 = "困难"
MissionManager_reset_time 	 = "挑战次数已重置"
MissionManager_layer_is_open = "关卡界面已打开，请返回关卡界面"


-- =============================gamedata\MonthCardManager.lua
MonthCardManager_buy_suc 	= "月卡购买成功"

-- =============================gamedata\NiuBilityManager.lua
NiuBilityManager_dianzan 	= "您已经赞过他了"

-- =============================gamedata\NorthClimbManager.lua
NorthClimbManager_choose_att_next_level = "请选择属性后进行下一关"
NorthClimbManager_reward_title 			= "通关本重可领"



-- =============================gamedata\NotifyManager.lua (还没有弄 放到后面 )
NotifyManager_getRole_strFormat =
	{
		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">今日与</font><font color="{p2}" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26">因缘际会，三界为之一震！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">与</font><font color="{p2}" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26">结缘成功，恭喜恭喜！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">许愿遇到了</font><font color="{p2}" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26">！</font></p>]],
	}
NotifyManager_getRole_strFormatChat =
	{
		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">今日与</font><font color="{p2}" fontSize="26">{p3}</font><font color="#000000" fontSize="26">因缘际会，三界为之一震！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">与</font><font color="{p2}" fontSize="26">{p3}</font><font color="#000000" fontSize="26">结缘成功，恭喜恭喜！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">许愿遇到了</font><font color="{p2}" fontSize="26">{p3}</font><font color="#000000" fontSize="26">！</font></p>]],
	}

NotifyManager_getEquip_strFormat =
	{
		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">获得了</font><font color="{p2}" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26"> x{p4}，三界称雄指日可待！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">获得了</font><font color="{p2}" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26"> x{p4}，战力大增！</font></p>]],
	}

NotifyManager_getEquip_strFormatChat =
	{
		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">获得了</font><font color="{p2}" fontSize="26">{p3}</font><font color="#000000" fontSize="26"> x{p4}，三界称雄指日可待！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">获得了</font><font color="{p2}" fontSize="26">{p3}</font><font color="#000000" fontSize="26"> x{p4}，战力大增！</font></p>]],
	}

NotifyManager_arena_strFormat = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">经过激烈的角逐，聚贤斗法的冠军已经产生！冠军：</font>
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">，亚军：</font><font color="#ff4ef5" fontSize="26">{p2}</font><font color="#ffffff" fontSize="26">，季军：</font><font color="#FF0000" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26">，今日仙位已成谱，明日群贤谁当先？</font></p>]]

NotifyManager_ArenaBalanceTrailer_strFormat = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">聚贤斗法将于21：00整结算奖励！请各位抓紧时间！</font></p>]]

NotifyManager_WorldBoss_strFormat = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">降妖伏魔</font>
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">力拔山河，对降妖伏魔Boss造成 </font><font color="#ff4ef5" fontSize="26">{p2}</font><font color="#ffffff" fontSize="26">伤害，</font><font color="#FF0000" fontSize="26">{p3}</font><font color="#ffffff" fontSize="26"> ，</font><font color="#FF0000" fontSize="26">{p4}</font><font color="#ffffff" fontSize="26">紧跟其后，分别造成了</font><font color="#FF0000" fontSize="26">{p5}</font><font color="#FFFFFF" fontSize="26"> ，</font><font color="#FF0000" fontSize="26">{p6}</font><font color="#FFFFFF" fontSize="26"> 伤害</font></p>]]

NotifyManager_Email_empty = "您的邮件已经是空的了！"

NotifyManager_Email_candel = "当前无可删除邮件"
NotifyManager_Email_bukeling = "没有可领取邮件"
NotifyManager_Email_shanchuchenggong = "删除已读邮件成功"


NotifyManager_ArenaChange_strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26"> 众仙技痒，斗法台已经重铸！ </font>
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26"> 在聚贤斗法中击败了 </font>
		<font color="#ff0000" fontSize="26">{p2}</font><font color="#000000" fontSize="26">，夺得了第{p3}名的宝座！</font></p>]]

NotifyManager_ArenaChange_strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26"> 众仙技痒，斗法台已经重铸！ </font>
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26"> 在聚贤斗法中击败了 </font>
		<font color="#feff8f" fontSize="26">{p2}</font><font color="#ffffff" fontSize="26">，夺得了第{p3}名的宝座！</font></p>]]



NotifyManager_ClimbPass_strFormatChat =[[<p style="text-align:left margin:5px"><font color="#ff0000" fontSize="26">{p1}</font>
		<font color="#000000" fontSize="26">竟然击败了无极幻境第</font><font color="#ff0000" fontSize="26"> {p2} </font>
		<font color="#000000" fontSize="26">层的强敌，真是战力非凡，群仙敬仰</font></p>]]
NotifyManager_ClimbPass_strFormat =[[<p style="text-align:left margin:5px"><font color="#feff8f" fontSize="26">{p1}</font>
		<font color="#ffffff" fontSize="26">竟然击败了无极幻境第</font><font color="#feff8f" fontSize="26"> {p2} </font>
		<font color="#ffffff" fontSize="26">层的强敌，真是战力非凡，群仙敬仰</font></p>]]


NotifyManager_HeroTop_strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">周围的气流突然凝聚，原来是战力第一的</font>
		<font color="#ff0000" fontSize="26"> {p1} </font>
		<font color="#000000" fontSize="26">上线了！</font></p>]]
NotifyManager_HeroTop_strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">周围的气流突然凝聚，原来是战力第一的</font>
		<font color="#feff8f" fontSize="26"> {p1} </font>
		<font color="#ffffff" fontSize="26">上线了！</font></p>]]

NotifyManager_ArenaTop_strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">众人只觉得体内法力涌动，原来是聚贤斗法第一名的</font>
		<font color="#ff0000" fontSize="26"> {p1} </font>
		<font color="#000000" fontSize="26">上线了！</font></p>]]
NotifyManager_ArenaTop_strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">众人只觉得体内法力涌动，原来是聚贤斗法第一名的</font>
		<font color="#feff8f" fontSize="26"> {p1} </font>
		<font color="#ffffff" fontSize="26">上线了！</font></p>]]

NotifyManager_vip_strFormatChat=[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">豪气万丈，富贵之气缓缓逼近，原来是【至尊•VIP】</font>
			<font color="#ff0000" fontSize="26"> {p1} </font>
			<font color="#000000" fontSize="26">上线了！</font></p>]]
			
NotifyManager_vip_strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">豪气万丈，富贵之气缓缓逼近，原来是【至尊•VIP】</font>
			<font color="#feff8f" fontSize="26"> {p1} </font>
			<font color="#ffffff" fontSize="26">上线了！</font></p>]]
NotifyManager_GoldEgg_rewarddesc = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">恭喜</font>
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">在砸蛋活动中，砸开{p2}获得了</font><font color="{p3}" fontSize="26">{p4}</font></p>]]

NotifyManager_GoldEgg_chatMsg = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">恭喜</font>
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">在砸蛋活动中，砸开{p2}获得了</font><font color="{p3}" fontSize="26">{p4}</font></p>]]

NotifyManager_GoldEgg_eggDesc = {"???13","???13"}


NotifyManager_FationRank_strTemplete = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">
		{p1}完成镜中乱世（{p2}）的首次通关，它将永久保存在排行榜中</font></p>]]
NotifyManager_FationRank_strTempleteChat = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">
		{p1}完成镜中乱世（{p2}）章节的首次通关，它将永久保存在排行榜中</font></p>]]

NotifyManager_FationRank_strTempleteChat2 = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">
		在{p1}的带领下，{p2}镜中乱世（{p3}）通关速度上升为第{p4}名</font></p>]]

NotifyManager_FationRank_strTempleteChat3 = [[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">
		第一名：{p1}仙盟技压群雄，在本届仙盟战中一举夺魁，可喜可贺！</font></p>]]

NotifyManager_nobody = "无名"

NotifyManager_operationStrFormat1 =  "，通过宝石合成，"
NotifyManager_operationStrFormat2 =  "，通过宝石拆卸，"
NotifyManager_operationStrFormat3 = "，通过装备升星，"
NotifyManager_operationStrFormat4 = "，通过出售装备，"
NotifyManager_operationStrFormat5 = "，通过装备重铸，"

NotifyManager_obtainGemNotify_strFormat = {
		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">{p2}</font><font color="#ffffff" fontSize="26">获得了</font><font color="{p3}" fontSize="26">{p4}</font><font color="#ffffff" fontSize="26"> x{p5}，战力大增！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#feff8f" fontSize="26">{p1}</font><font color="#ffffff" fontSize="26">{p2}</font><font color="#ffffff" fontSize="26">获得了</font><font color="{p3}" fontSize="26">{p4}</font><font color="#ffffff" fontSize="26"> x{p5}，速来围观！</font></p>]],
	}
NotifyManager_obtainGemNotify_strFormatChat = {
		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">{p2}</font><font color="#000000" fontSize="26">获得了</font><font color="{p3}" fontSize="26">{p4}</font><font color="#000000" fontSize="26"> x{p5}，战力大增！</font></p>]],

		[[<p style="text-align:left margin:5px">
		<font color="#ff0000" fontSize="26">{p1}</font><font color="#000000" fontSize="26">{p2}</font><font color="#000000" fontSize="26">获得了</font><font color="{p3}" fontSize="26">{p4}</font><font color="#000000" fontSize="26"> x{p5}，快来围观！</font></p>]],
	}

-- =============================gamedata\OperationActivitiesManager.lua(弃用)
-- =============================gamedata\OtherPlayerManager.lua
OtherPlayerManager_not_find = "找不到炼丹数据{p1}"
-- =============================gamedata\PayManager.lua
PayManager_monthCard_desc = [[<p style="text-align:left margin:5px"><font color="#000000" fontSize = "24">
					        恭喜您激活了{p1}
					        <br></br>
					        充值成功获得{p2}灵玉
					        <br></br><br></br>
					        <p style="text-align:left margin:5px"><font color="#000000" fontSize = "24">每日登陆即可领取</font><font color="#FF0000" fontSize = "24">{p3}</font><font color="#000000" fontSize = "24">灵玉</font></p>
					        </font>
					        </p>]]
PayManager_monthCard_name1 = "黄金月卡"
PayManager_monthCard_name2 = "至尊月卡"
PayManager_not_open = "充值暂未开放"

-- =============================gamedata\PlayBackManager.lua
PlayBackManager_zhaohui_suc = "召回玩家成功"
PlayBackManager_yaoqing_suc = "提交邀请码成功"
PlayBackManager_jibai_fail = "未加入仙盟，不能捐献"



-- =============================gamedata\PlayerGuideManager.lua (无中文)
-- =============================gamedata\QiYuanManager.lua

-- =============================gamedata\QiyuManager.lua
QiyuManager_wuhuodong 				= "奇遇的活动都没有开放"
QiyuManager_tilizengjia 			= "获得仙桃，体力增加{p1}"
QiyuManager_hujia_tips 				= "您的巡山还没有完成呢。"
QiyuManager_hujia_tips2 			= "您今日挑战次数已经用完，明日再来"
QiyuManager_hujia_tips3				= "耐心等待"

-- =============================gamedata\RankManager.lua
-- =============================gamedata\RedPointManager.lua
-- =============================gamedata\RewardManager.lua
-- =============================gamedata\SettingManager.lua
SettingManager_send_suc 			= "发送成功"
SettingManager_music_open 			= "音乐已开启"
SettingManager_music_close 			= "音乐已关闭"
SettingManager_effect_open 			= "音效已开启"
SettingManager_effect_close 		= "音效已关闭"
SettingManager_chat_open 			= "聊天提示已开启"
SettingManager_chat_close 			= "聊天提示已关闭"

-- =============================gamedata\SevenDaysManager.lua
-- =============================gamedata\SkillLevelData.lua
-- =============================gamedata\StrategyManager.lua
-- =============================gamedata\TaskManager.lua
TaskManager_com_task 				= "已完成:{p1},可领取奖励"
TaskManager_ask_join_fation			= "请您尽快加入仙盟体验更多内容"


-- =============================gamedata\TriggerFunction.lua
-- =============================gamedata\VipRuleManager.lua

VipRuleManager_open_yjqhua 	= "{v1}开放一键强化"
VipRuleManager_up_vip		= "提升VIP"
VipRuleManager_wuping_buzu 	= "{p1}不足"
VipRuleManager_goumai_wp 	= "{v1}方可购买{p2}。\n\n是否前往充值？"
VipRuleManager_tisheng_vip	= "今日购买次数已用完！\n\n提升至{v1}可购买{p2}次。\n\n是否前往充值？"
VipRuleManager_goumaicishu_buzu = "今日购买次数已用完！"
VipRuleManager_goumaicishu_buzu2 = "{p1}不足,今日购买次数已用完！"

-- =============================gamedata\WeekRaceManager.lua
WeekRaceManager_huodong_weikaishi = "活动未开始"
WeekRaceManager_no_player 		= "争霸赛无参赛选手"
WeekRaceManager_notify = {
		"武林大会八强赛即将开始，请参加八强赛的选手进行布阵准备，押注活动也将同步进行！",
		"武林大会半决赛即将开始，请参加半决赛的选手进行布阵准备，押注活动也将同步进行！",
		"武林大会总决赛即将开始，请参加总决赛的选手进行布阵准备，押注活动也将同步进行！"
	}	

-- =============================gamedata\WulinManager.lua
-- =============================gamedata\ZhengbaManager.lua
ZhengbaManager_cd_time 			= "对战冷却时间剩余：{p1}秒"
ZhengbaManager_insprie_time 	= "您已经鼓舞了"
ZhengbaManager_get_all_box 		= "您已领取所有宝箱"
ZhengbaManager_liansheng_ing 	= "取得进攻{p1}连胜可领取"
ZhengbaManager_liansheng_ed 	= "进行{p1}次对战可领取"
ZhengbaManager_jibai_xxx 		= "您击败了{p1},"
ZhengbaManager_jifen_add 		= "积分+{p1}"
ZhengbaManager_tiaozhanshibai	= "您挑战{p1}失败"
ZhengbaManager_xxx_jibai 		= "{p1}击败了您"
ZhengbaManager_xxx_tiaozhan 	= "{p1}挑战您失败，"
ZhengbaManager_no_this_hero 	= "没有该神灵"

ZhengbaManager_fight_desc		= 
{
	[5] = "{p1}取得了进攻{p2}连胜，正在暴走状态！",
	[6] = "{p1}取得了进攻{p2}连胜，已经技压群雄！",
	[7] = "{p1}取得了进攻{p2}连胜，已经无人能挡！",
	[8] = "{p1}取得了进攻{p2}连胜，已经主宰大会！",
	[9] = "{p1}取得了进攻{p2}连胜，犹如天神下凡！"

}

ZhengbaManager_fight_desc2 = "{p1}取得了防守连胜{p2}，已经无人能破！"

-- =============================gamedata\base\CardEquipment.lua
-- =============================gamedata\base\CardRole.lua
CardRole_tip1 = "该位置已经炼化了丹药，不可重复炼化"
CardRole_tip2 = "找不到对应的角色炼化丹药 : [{p1}] , [{p2}]"
CardRole_tip3 = "不可装备，Martial table is nil or not found"
CardRole_tip4 = "境界id与配置不匹配"

-- =============================gamedata\base\EffectExtraData.lua
-- =============================gamedata\base\EnumGameObject.lua
GameEquipmentTypeStr = 
{
	"武器",			--武器
	"衣服",			--衣服
	"戒指",			--戒指
	"腰带", 		--腰带
	"靴子",			--靴子
}

AttributeTypeStr = 
{
	"气血",
	"武力",
	"防御",
	"法力",
	"身法",
	"冰攻",
	"火攻",
	"咒攻",
	"冰抗",
	"火抗",
	"咒抗",
	"暴击",
	"抗暴",
	"命中",
	"闪避",
	"暴击率",
	"命中率",
	"气血",
	"武力",
	"防御",
	"法力",
	"身法",
	"冰攻",
	"火攻",
	"咒攻",
	"冰抗",
	"火抗",
	"咒抗",
	"暴抗率",
	"闪避率",
	"治疗加成",
	-- "当前气血",		---30
	-- "攻击百分比",  ---31
}

SkillTargetTypeStr = 
{		
	"敌方单体",		
	"敌方全体",		
	"敌方横排",		
	"敌方竖排",	
	"敌方随机",		
	"敌方血最少",		
	"敌方防最少",		
	"我方随机",	
	"我方血最少",		
	"我方全体",		
	"自己",		
	"敌方防最高",		
	"敌方法力最高",		
	"敌方法力最低",	
	"敌方武力最高",		
	"敌方武力最低",		
	"我方武力最高",		
	"我方武力最低",		
	"我方法力最高",		
	"我方法力最低",		
}

SkillTypeStr = 
{		
	"主动技能",		
	"主动治疗",		
	"主动技能",		
	"被动属性",	
	"增益光环",		
	"减持光环",		
	"被动技能",		
	"主动技能",		
}

SkillSexStr = 
{		
	"异性",		
	"同性",			
}

SkillEffectStr = 
{		
	"吸取战意",		
	"减少战意",		
	"增加战意",		
	"吸血",	
	"反弹",		
	"反击 ",		
	"化解",		
	"破阵 ",	
	"复活",		
	"净化 ",		
	"致死",		
	"免疫",	
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"通天法眼",
	"七伤拳",
	[22]= "神力剥夺",
	[23]= "神力剥夺",
	[24]= "伤害递增",
	[25]= "闪避释放技能",
}

SkillBuffHurtStr = 
{
	"中咒",		
	"灼烧",		
	"破甲",		
	"疲惫",		
	"散法",		
	"迟缓",		
	"失明",		
	"神力",		
	"坚固",		
	"混乱",		
	"封印",		
	"定身",		
	"晕眩",		
	"虚化",		
	"睡眠",		
	"低落",		
	"回血",	
	"",
	"",	
	"三头六臂",		
	"金翅天翔",		
	"易筋经",		
	"放手一搏",		
	"八仙阵",		
	"索命",		
	"追魂",
	"",
	-- "",
	-- "",
	-- "",
	-- "",
	[31]="俭心谱",
	[33]="百折不挠",		
	[34]="百折不挠",
	[35]="印记",
	[36]="印记",	
	[37]="胆怯",


	[40]= "普攻伤害",
	[41]= "技能伤害",
	[42]= "咒和火的持续伤害",
	[43]= "负面状态概率",
	[44]= "伤害",
	[45]= "治疗量",
	[46]= "增益属性状态效果",
	[47]= "负面属性状态效果",
	
	[50]= "流血",
	[51]= "神力剥夺",
	[52]= "神力剥夺",
	[53]= "必中",
	[54]= "无量天法",
	[55]= "重伤",
}


EnumItemOutPutType ={"历练关卡", "聚贤斗法", "无极幻境", "三垢奇阵", "巡山", "太公钓鱼", "商店", "聚仙许愿" ,"金宝箱", "银宝箱", "铜宝箱","VIP奖励","VIP礼包","活动","签到","成就","日常", "群仙涿鹿", "通过活动获取", "祈愿","藏书阁","历劫"}

-- 炼丹的等级描述
EnumWuxueLevelType = {"一", "二" , "三", "四" , "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七"}

--added by wuqi
--典籍重数
EnumSkyBookLevelType = {"一", "二" , "三", "四" , "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十"}

-- 境界一重：初探门径、境界二重：熟能生巧、境界三重：小有所成、境界四重：登堂入室、境界五重：炉火纯青、境界六重：登峰造极、境界七重：出神入化、境界八重：返璞归真、境界九重：一代宗师
EnumWuxueDescType   = {"境界一重","境界二重","境界三重","境界四重","境界五重","境界六重","境界七重","境界八重","境界九重","境界十重","境界十一重","境界十二重","境界十三重","境界十四重","境界十五重","境界十六重","境界十七重","境界十八重"}

-- 丹药的等级描述
EnumBookDescType   = {"下品","中品","上品","极品","仙品"}

-- =============================gamedata\base\functions.lua
QUALITY_STR  = {"凡品", "上品", "仙品", "神品"}
Equip_Des 	 = {"武器", "衣服", "法宝", "腰带", "靴子"}
ResourceName = 
{
	[3]="铜钱",
	[4]="灵玉",	
	[5]="悟性点",
	[6]="等级经验",	
	[127]="等级",
	[7]="角色经验",
	[10]="威望",
	[8]="聚贤斗法积分",
	[11]="影响力",
	[15]="八卦精元",
	[21]="虎令",
	[22]="龙令"
}

ResourceNameForGeneralHead = 
{
	[3]="铜钱",
	[4]="灵玉",	
	[5]="悟性点",
	[13]="威望",	
	[6]="等级经验",
	[7]="角色经验",
	[8]="斗法积分",
	[9]="仙桃",
	[10]="挑战次数",
	[11]="幻境符",
	[12]="技能点",
	[20]="包子",
	[21]="虎令",
	[22]="龙令"
}

fun_wan_desc = "{p1}万"

-- =============================gamedata\base\GameAttributeData.lua
-- =============================gamedata\base\GameFragment.lua
-- =============================gamedata\base\GameItem.lua
-- =============================gamedata\base\GameObject.lua
-- =============================gamedata\base\RandomCommodity.lua
-- =============================gamedata\base\RandomStore.lua
RandomStore_Min_Later = "{p1}分钟后"
RandomStore_Sec_Later = "{p1}秒后"
RandomStore_Refresh   = "正在刷新"

-- =============================gamedata\base\RoleEffectExtraData.lua
-- =============================gamedata\base\RoleEquipment.lua
-- =============================gamedata\hold\MartialInstance.lua



--***********************角色培养**************************
No_Acquisition_Techniques										= "无可炼化丹药"

--***********************无极幻境坤境************************
BEIKU_OPEN_NOT_ENOUGH_LEVEL                                    = "无极幻境乾境通关{p1}层开启"
BEIKU_ALL_PASS                                                 = "已通关坤境所有关卡，请重置"
BEIKU_GET_AND_PASS                                             = "您有宝箱没有领取，请领取宝箱"
BEIKU_CAN_NOT_RESET                                            = '重置次数用尽'
BEIKU_NPC_FORMATION_NOT_FOUND                                  = '找不到NPC配置信息'
BEIKU_GAME_LEVEL_NOT_FOUND	                                    = '找不到关卡配置信息'
BEIKU_ALREAY_MAX_GAME_LEVEL	                                = '没有更多的关卡设定'
BEIKU_INVALIDATE_GAME_LEVEL_ID	                                = '非法的关卡ID'
BEIKU_CAN_NOT_CHOICE_ATTRIBUTE                                 = '无法选择该属性'
BEIKU_CHOICE_ATTRIBUTE_NOT_FOUND                               = '无法选择可使用的属性'
BEIKU_CHOICE_ATTRIBUTE_CONF_NOT_FOUND                          = '找不到属性选择配置'
BEIKU_ATTRIBUTE_ALREAY_CHOICED                                 = '已经选择过该属性'
BEIKU_CHOICE_ATTRIBUTE_NOT_VALIDATE                            = '该属性配置错误'
BEIKU_NOT_ENOUGH_TOKENS                                        = '没有足够的幻境符'
BEIKU_HAVE_NOT_CHEST_CAN_OPEN                                  = '没有可以开启的宝箱'
BEIKU_CHEST_ALREAY_OPEN                                        = '已经开启过该宝箱'
BEIKU_CHEST_CONFIGURE_IS_NULL                                  = '宝箱配置为空'
BEIKU_ATTRIBUTE_ALREAY_CHOICED_IS_SKIP                         = '您已经跳过了鼓舞，不可以再次选择'
BEIKU_CAN_NOT_SWEEP                                            = '敌人过于强大，无法扫荡'
BEIKU_HAS_NOT_PASS                                             = '该关卡挑战失败，需要重置无极幻境坤境'
BEIKU_GET_AND_SWEEP                                            = '您有宝箱没有领取，请领取后扫荡'    
BEIKU_CHOICE_ATTRIBUTE_AND_SWEEP                               = '您有属性没有选择，请选择后扫荡'   


--***********************炼体突破**************************
JINGMAI_SURMOUNT_SUCCESS                                       = "突破成功，属性成长提升"
JINGMAI_SURMOUNT_FAIL                                          = "突破失败"
JINGMAI_SURMOUNT_OPEN_NOT_ENOUGH_LEVEL                         = "无极幻境乾境通关{p1}层开启"

--***********************仙盟**************************
No_Permissions                                                 = '等待盟主/长老开启'
NoT_Enough_Prosperity                                          = '仙盟威望不足'
Everyday_Reset_One_time                                        = '每日最多重置1次'
Consume_Prosperity_Open                                        = '是否消耗{p1}仙盟威望开启'
Consume_Prosperity_Reset                                       = '是否消耗{p1}仙盟威望重置'
Zone_Reset_Suceess                                        		= '重置成功'
Zone_Open_Suceess                                       		= '开启成功'
Zone_time_out_two_minute                                 		= '最多在挑战界面停留{p1}分钟'
Zone_time_out_ten_second                                 		= '最多在结算界面停留{p1}秒'
Zone_time_out_ten_minute                                 		= '挑战时长最大为{p1}分钟'
Zone_somebody_attacking                                 		= '其他玩家正在挑战'
Field_Finish_at_once                                      		= '是否消耗{p1}灵玉立刻完成修炼?'
Field_Open_Level                                        		= '玄清洞需要仙盟等级{p1}级'
Field_Open_XLC_Level                                        	= '玄清洞高级修炼需要仙盟等级{p1}级'
Field_Research_skill                                        	= '是否消耗{p1}仙盟威望研究{p2}级{p3}？'
Field_Open_skill                                            	= '是否消耗{p1}仙盟威望开启{p2}？'
Field_Research_skill_max_level                                	= '到达当前最高等级，请提升仙盟等级'
Field_Research_skill_max_level2                                = '到达最高等级'
Field_Study_skill_no_open                                      = '需要盟主/长老开启'
Field_Study_skill_max_level                                    = '到达当前最高等级，请提升研究等级'
Field_No_Permissions                                           = '只有盟主/长老才能研究'
Guild_flag_modify                                              = '仙盟旗帜修改成功'
Guild_UI                                                       = '需要1个仙盟更旗令（剩余：{p1}）'
Guild_Dedication_Not											= '仙盟威望不足'
Guild_Dedication_Tool_Not											= '{p1}不足'



--***********************装备重铸**************************
Recast_Unlock1                                                 = '第一个槽达到破损解锁'
Recast_Unlock2                                                 = '第二个槽达到瑕疵解锁'
Recast_Unlock3                                                 = '第三个槽达到完美解锁'
Recast_Unlock4                                                 = '第四个槽达到神铸解锁'
Recast_Gems                                                    = '装备重铸2个槽破损解锁'
Recast_Second_Prompt                                           = '重铸会消耗一件{p1}，是否确认重铸？'
Recast_Material_shortage                                       = '请收集{p1}'
Recast_Used_tool                                           		= '重铸会消耗一个{p1}，是否确认重铸？'

Recast_UnlockList = 
{
	'第一个槽达到破损解锁',
	'第二个槽达到瑕疵解锁',
	'第三个槽达到完美解锁',
	'第四个槽达到神铸解锁'
}



--***********************寻宝**************************
Mining_Protect_Record1                                         = '{p1}使用了您派遣的神灵，获得{p2}奖励'
Mining_Protect_Record2                                         = '在您担当{p1}的护卫期间，成功阻止{p2}的夺得先机。获得{p3}额外奖励'
Mining_UI1                                                     = '本周可选数量：{p1}'
Mining_UI2                                                     = '每周每个好友或仙盟成员只能选择一次'
Mining_UI3                                                     = '与{p1}战斗{p2}次，'
Mining_UI3_win                                                 = '{p1}寻得先机，与{p2}战斗{p3}次，{p4}寻宝成功'
Mining_UI3_lost                                                = '{p1}寻得先机，与{p2}战斗{p3}次，{p4}寻宝失败'
Mining_UI4_win                                                 = '{p1}与{p2}战斗，战斗胜利'
Mining_UI4_lost                                                = '{p1}与{p2}战斗，战斗失败'
Mining_Nobody                                                  = '暂时没有其他寻宝者'
Mining_Reset                                                   = '是否消耗1次寻宝令重置寻宝状态？'
Mining_No_Chance                                               = '寻宝令不足'
Mining_No_Protector                                            = '没有选择护送者，将更容易被人捷足先登，是否确认独自寻宝'
Mining_Rob_Success                                             = '获得{p1}铜钱'
Mining_Dead                                                    = '没有未战败神灵'
Mining_Increase_Frequency                                      = '寻宝令+{p1}'
Mining_No_Lineup                                               = '没有布置寻宝阵容的玩家'
Mining_No_Rob_frequency                                        = '缺少寻宝令'
Mining_Suffer_Rob                                              = '该玩家正在被攻击'
Mining_Mining_Complete                                         = '该玩家寻宝已经完成'
Mining_No_All_Beat                                             = '还有{p1}未击败，是否继续退出？'
Mining_Rob_Gemstone                                            = '获得{p1}个{p2}宝石箱'
Mining_Rob_Acer                                                = '获得{p1}灵玉'
Mining_Rob_Refined_stone                                       = '获得{p1}个精炼石'





--***********************四象**************************
Gossip_Upgrade_success                                         = '{p1}注入完毕'
Gossip_Breach                                                  = '请点击四象，并突破至下一重'
Gossip_Breach_success                                          = '成功突破至{p1}重'
Gossip_No_Prop                                                 = '乾玉不足，请前往无极幻境获取'
Gossip_Level_insufficient                                      = '等级提升至{p1}再试'
Gossip_No_Upgrade_complete                                     = '请将本重四象注入完毕后再试'





--***********************助阵**************************
Assist_Somebody_Assist_You                                     = '{p1}助阵您{p2}'
Assist_No_Assist_hero                                          = '暂无好友助阵神灵'
Assist_Assist_success                                          = '助阵{p1}成功'
Assist_No_hero                                                 = '抱歉，没有该神灵'
Assist_Hero_No_time                                            = '抱歉，该神灵次数不足'
Assist_Already_Assist_This_player                              = '抱歉，今天已助阵过该玩家'
Assist_This_player_Already_Assist_You                          = '抱歉，今天已接受过该玩家助阵'
Assist_Their_Hero_No_time                                      = '抱歉，今天该神灵助阵已达到最大次数'
Assist_Assist_success_they                                     = '成功助阵{p1}个好友'
Assist_UI_Assist                                               = '累计助阵好友{p1}次'
Assist_Assist_gift                                             = '所有礼物已领取'
Assist_NO_Assist_friend                                        = '没有可助阵好友'
Assist_No_Assist_time                                          = '今日助阵次数已用尽'
Assist_No_open                                                 = '等级达到40级开启'
                                    




--***********************协战**************************
Mercenary_Mercenary_back_limit                                  = '超过30分钟神灵才能归队'
Mercenary_The_team_returned_to_limit                            = '超过30分钟队伍才能归队'
Mercenary_The_knight_is_empty                                   = '没有协战神灵'
Mercenary_Team_is_empty                                         = '没有协战队伍'






--***********************雇佣**************************
Hire_The_same_Knight_battle                                     = '同名神灵不能同时上阵'
Hire_No_Knight_battle                                           = '至少上阵一位神灵'
Hire_Abnormal_information_Knight                                = '神灵信息刷新，请重新选择' 
Hire_The_knight_is_empty                                        = '没有好友队伍'
Hire_Team_is_empty                                              = '没有仙盟队伍'



--***********************祈愿**************************
QIYUAN_NOT_FIND_TEMPLATE                                               = '找不到模板'
QIYUAN_NOT_FIND_REWARD                                                 = '未找到奖励'
QIYUAN_REWARD_ALREADY_GET                                              = '奖励已领取' 
QIYUAN_NOT_ENOUGH_DAY                                                  = '祈愿天数不足15天'
QIYUAN_NOT_ENOUGH_COUNT                                                = '今日祈愿次数已满'
QIYUAN_WAIT_FIVE_MINUTE                                                = '请等待五分钟' 
QIYUAN_NOT_FIND_INVOCATORY_GOODS                                       = '没有祈愿石'
QIYUAN_NOT_INVOCATORY_REWARD_OR_RESET                                  = '三个卡槽没有奖励或者奖励已经被重置'



QIYUAN_NOTFIND_TEMPLATE                                               = '找不到模板'
QIYUAN_NOTFIND_REWARD                                                 = '未找到奖励'
QIYUAN_REWARDALREADY_GET                                              = '奖励已领取' 
QIYUAN_NOTENOUGH_DAY                                                  = '祈愿天数不足{p1}天'
QIYUAN_NOTENOUGH_COUNT                                                = '今日祈愿次数已满'
QIYUAN_WAITFIVE_MINUTE                                              = '请等待五分钟' 
QIYUAN_NOTFIND_INVOCATORY_GOODS                                                  = '没有祈愿石'
QIYUAN_NOTINVOCATORY_REWARD_OR_RESET                                                = '三个卡槽没有奖励或者奖励已经被重置'

--***********************非法第三方**************************
illegal_Third_party                                             = '战斗异常，请重新登录'


--国内新增
-----------------------------------------------------------------------------------------------------------------

smithy_gem_oneKeyBuild = "是否确认将所有低级宝石合成最高至6级？"
treasureMain_text1  = "上一轮还没有结束，请稍等"
treasureMain_text2	= "{p1}/{p2}次"
treasureMain_text3	= "{p1}次"
treasureMain_text4	= "可免费寻宝"
treasureMain_tiemout ="活动已结束"
smritiMain_text1 	= "请放入2件装备"
smritiMain_tips 	= "提示"
smritiMain_ok 		= "是否确认置换装备？"

--历劫相关
youli_DoubleStrategyNo = "请先在历劫界面布阵第二阵容"
youli_saodangling = "扫荡令："
youli_xiaohao = "每次扫荡消耗"
youli_freeTimes = "今日免费："
youli_text1 = "{v1}开启一键扫荡多次功能。\n\n是否前往充值？"
youli_text2 = "提升VIP"
youli_text3 = "缺少包子"
youli_text4 = "补满包子"
youli_text5 = "包子不足"
youli_text6 = "是否花费{p1}灵玉购买10个包子？"
youli_text7 = "今日还可以购买{p1}次"
youli_text8 = "提升至{v1}可每日购买挑战次数{p2}次。\n\n是否前往充值？"
youli_text9 = "今日购买次数已用完！\n\n提升至{v1}可每日购买挑战次数{p2}次。\n\n是否前往充值？"
youli_text10 = "挑战次数已用完"
youli_text11 = "挑战次数已用完，今日重置次数已用完"
youli_text12 = "此次重置需要重置令{p1}个，是否确定重置？\n\n(当前拥有重置令：{p2},今日还可以重置{p3}次)"
youli_text13 = "是否花费{p1}灵玉重置此关卡挑战次数？\n\n(今日还可以重置{p2}次)"
youli_text14 = "剩余免费次数和扫荡令总和不足,是否花费{p1}灵玉进行扫荡？"
youli_text15 = "杀戮次数不足"
youli_text16 = "补满杀戮次数"
youli_text17 = "杀戮次数不足"
youli_text18 = "是否花费{p1}灵玉购买5次杀戮次数？"
youli_text19 = "是否花费{p1}灵玉立即刷新？"
youli_otherplayer_text1 = "刷新成功"
youli_openmission_text = "没有已通关的关卡"
youli_reward_tips1 = "当前关卡掉落:"
youli_reward_tips2 = "胜利一场掉落:"
youli_reward_tips3 = "胜利二场掉落:"
youli_reqiure_level = "需求等级达到{p1}级"
youli_not_open = "敬请期待!"
youli_baozi = "包子"

youli_drop_tips1 = "阅历"
youli_drop_tips2 = "杀戮值"
youli_drop_tips3 = "铜钱"

youli_yueli_des = "通过历劫玩法获得，可用于培养典籍。"
youli_coin_des = "铜钱是装备强化，角色养成等玩法的主要消耗资源"
youli_shalu_des = "通过杀戮玩法获得，在杀戮值排行榜中名次越靠前，每周奖励越大"

youli_shop_txt1 = "数量不足"
youli_shop_txt2 = "剩余残页数量："
shalurecord_txt1 = "是否花费{p1}灵玉,进行复仇？"
shalurecord_txt2 = "前"
shalu_info_txt1 = "未入榜"
shalu_nearby_txt1 = "路人"
shalu_nearby_txt2 = "杀戮奖励放入结算池，每周日24点结算"
shalu_nearby_txt3 = "杀戮路人成功后直接获得奖励"

time_day_txt = "天"
time_hour_txt = "小时"
time_minute_txt = "分钟"
time_second_txt = "秒"


youli_home_xy = {x = 182, y = 257}
youli_playerHead_xy = {
	{x = -182, y = 494},
	{x = 194, y = 472},
	{x = 465, y = 381},
	{x = 610, y = 102},
	{x = -2, y = -112},
	{x = -263, y = 16},
}

--聊天
chat_serverChat_closed = "跨服聊天功能已关闭"

--vip
vip_employ_not_enough = "VIP{p1}级派遣{p2}号位。 \n\n是否前往充值？"
vip_qucik_saodang_not_enough = "VIP{p1}级开启快捷扫荡。 \n\n是否前往充值？"
vip_yiJianQianXue_not_enough = "VIP{p1}级开启一键淬炼。 \n\n是否前往充值？"
vip_yiJianXiDe_not_enough = "VIP{p1}级开启一键炼化。 \n\n是否前往充值？"
vip_gamble_not_enough = "VIP{p1}级开启一键点金。 \n\n是否前往充值？"
vip_intensify_not_enough = "VIP{p1}级开启一键强化。 \n\n是否前往充值？"
vip_factionMakeFriend_not_enough = "VIP{p1}级开启{p2}。 \n\n是否前往充值？"
vip_escortTran_not_enough = "VIP{p1}级开启加速。 \n\n是否前往充值？"


--仙盟
faction_makeFriend_show = {"相见恨晚","义结金兰","同甘共死"}






-------------new
common_up_vip = "提升VIP"    --为了防止有相同错误 在加一条Key
common_vip_up = "提升VIP"
faction_no_battle_info = "没有该场战斗信息"
faction_name = "我的名字是{p1}"
faction_no_levelup = "仙盟未晋级"
faction_no_rank = "未上榜"
activity_recruit_type = {"普通招募", "高级招募", "十连抽"}
activity_recruit_type2 = {"普通", "高级", "十连抽"}
activity_employDesc = "{p1}{p2}{p3}次  "
activity_employCondition = "{p1} {p2}{p3}次({p4}/{p5})"
common_max_shalu = "杀戮值:"
common_shalu = "{p1}杀戮值"
ZhengbaManager_no_this_hero = "没有该神灵"
recruit_rest_cnt = "今日剩余招募次数:{p1}"
recruit_lack = "今日剩余次数不足"


-- =============================gamedata\FactionFightManager.lua
FactionFightManager_join_before = "请先加入仙盟"
FactionFightManager_not_in_avtivity = "不在活动时间内"





--***********************仙盟战**************************
Guild_War_Output                                             = '获胜可得:气血增加10%'
Guild_War_Force                                              = '获胜可得:武力增加10%'
Guild_War_Internal                                           = '获胜可得:法力增加10%'
Guild_War_No_Elite                                           = '该精英不在队伍中'
Guild_War_War_star                                           = '仙盟争锋即将开始，无法报名'
Guild_War_No_Position                                        = '位置不足，请尝试其他队列'
Guild_War_No_Videotape                                       = '暂无战斗回顾信息'

GUILD_WAR_MSG = {
	Guild_War_Output,
	Guild_War_Force,
	Guild_War_Internal
}







------------new2----典籍----
sbStone_fenjie_tip = "本次分解精要可获得："

SkillDetail_reactive_skill = "被动技能"
SkillDetail_nuqi			="{p1}点战意"
SkillDetail_not_nuqi			="不消耗战意"

playerbackMain_text1 = "欢迎上仙归来！<br/>小仙我一直在此地苦等终于盼到您了，特别为您准备了海量福利，助您急速追赶，后来居上!<br/>在这里您可以开启为您专门准备的回归任务，完成后即可获得丰厚任务奖励。<br/>在此期间，上仙进行"
playerbackMain_text2 = "历练所获得的经验提高到1.5；历练所获得的经验丹提高到1.5倍，"
playerbackMain_text3 = "让您在等级上后顾无忧。<br/>最后，我们为您诚意送上的这份回归大礼包，点击下方按钮即可领取。随着您的成长，礼包内容也将愈加丰厚，愿您的回归之路一帆风顺，早日重回至尊！"

MonthCardLayer_text1 = "持续 {p1} 天"
MiningLayer_text1 	 = "本周已被雇佣：" 
StarBoxPanel_stars	 = "{p1}星可领取"
TreasureMain_tips1	 ="操作确认"
TreasureMain_tips2	 ="寻宝30次需要花费{p1}灵玉，是否确认"

Tianshu_hecheng_text1 ="碎片不足，无法合成"
Tianshu_hecheng_text2 ="(已开放)"
Tianshu_hecheng_text3 ="(未开放)"
Tianshu_hecheng_text4 ="关卡尚未通关"
Tianshu_rongru_text1  ="融入所需铜钱不足!"
Tianshu_rongru_text2  ="融入所需阅历不足!"
Tianshu_rongru_text3  ="您没有选择精要！"
Tianshu_rongru_text4  ="本次出售精要可获得："
--Tianshu_chongzhi_text1 = "1.典籍变为一重\n2.返还阅历{p1}点\n3.返还所有精要\n\n是否重置<<{p2}>>?"
Tianshu_chongzhi_tips1 = "  1.典籍变为一重<br/>  2.返还阅历"
Tianshu_chongzhi_tips2 = "点<br/>"
Tianshu_chongzhi_tips3 = "  3.返还所有精要<br/>"
Tianshu_chongzhi_tips4 = "是否重置&lt;&lt;"
Tianshu_chongzhi_tips5 = "  4.返还所有升重符<br/>"

Tianshu_chongzhi_tips6 = "所需材料:"
Tianshu_chongzhi_tips7 = "已研习至最高重"
Tianshu_chongzhi_tips8 = "  已修炼至最高级"
Tianshu_chongzhi_tips9 = "残页:"
Tianshu_chongzhi_text2 ="请至少镶嵌一颗精要"
Tianshu_chongzhi_text3 ="典籍重置符数量不足"
Tianshu_chongzhi_text4 ="该精要孔未开放"
Tianshu_chongzhi_text5 = "该典籍已达最大重数"
Tianshu_chongzhi_text6 = "融入全部{p1}个精要后才可以升重"
Tianshu_chongzhi_text7 = "升重所需铜钱不足"
Tianshu_chongzhi_text8 = "融入所需{p1}不足!"
Tianshu_tupo_text1     ="典籍突破材料不足"
Tianshu_jingyao_text1  = "暂无掉落"
RoleSkyBook_text1      ="快给您的神灵使用最合适的典籍吧!"
GambleMainLayer_text1  ="您的{p1}不足"
GambleMainLayer_text2  ="{p1}需要花费{p2}{p3}，是否确认"
GambleMainLayer_text3  ="转运需要花费{p1}{p2}，是否确认"
AdventureShop_text1    ="购买个数不可小于1"
HeadPicFrame_text1	   ="已解锁头像框"
HeadPicFrame_text2	   ="未解锁头像框"
HeadPicFrame_text3	   ="该头像框已过期"
HeadPicFrame_text4	   ="剩余时间：%02d:%02d"
HeadPicFrame_text5	   ="无效的头像ID"
HeadPicFrame_text6 = "已超过有效期"
EquipOutTianshu_text1  ="藏书阁"

Tianshu_Main_Attr 		= "主属性:"
Tianshu_Attr_Grow 		= "属性成长:"

Tianshu_chong_text      = "{p1}重"

------------newadd------------------------------------------
monthCard_text1													="已领取100灵玉"
monthCard_text2													="今日已领取"
monthCard_text3													="小仙为您辛勤工作，赚得"
roleTrain_text1													="突破到{p1}品后开放"
roleTrain_text2													="升级至{p1}级，{p2}"
roleTrain_text3													="所有炼体满级时方可进行突破"
SkillDetail_reactive_skill 										= "被动技能"
SkillDetail_nuqi												="{p1}点战意"
SkillDetail_not_nuqi											="不消耗战意"
changetProfession_text1											={"吕洞宾","嫦娥","聂小倩","姜子牙"}
bloodHomeLayer_text1							="血战将在{p1}级开放"   
roleFireLayer_tips5								="请选取归隐的神灵"
playerbackMain_text1 							= "欢迎上仙重出江湖！<br/>为了让上仙尽快适应，我们特别为您准备了海量福利和丰厚的回归大礼包，助您急速追赶，后来居上!<br/>在这里您可以开启您的专属回归任务，完成后即可获得丰厚任务奖励。<br/>在此期间，上仙进行"
playerbackMain_text2 							= "闯关所获得的等级经验提高到1.5；闯关所获得的经验丹提高到1.5倍，"
playerbackMain_text3 							= "让您在等级上后顾无忧。<br/>最后，我们为您诚意送上的这份回归大礼包，点击下方按钮即可领取，随着您的成长。礼包内容也将愈加丰厚，愿您的江湖之路一帆风顺，早日重回武林巅峰！"

multiFight_noRank = '未上榜'
multiFight_yzsyTime = '押注剩余时间'
multiFight_fightTime = '战斗剩余时间'
multiFight_viewTime = '结果展示时间'
multiFight_recordTitleFont = {
	{
		"十六进八第一场",
		"十六进八第二场",
		"十六进八第三场",
		"十六进八第四场",
		"十六进八第五场",
		"十六进八第六场",
		"十六进八第七场",
		"十六进八第八场"
	},
	{
		"八进四第一场",
		"八进四第二场",
		"八进四第三场",
		"八进四第四场"
	},
	{
		"半决赛第一场",
		"半决赛第二场"
	},
	{
		"总决赛"
	}
}

multiFight_result_timetxt = "即将开启"
multiFight_result_opentime = "下届跨服武林大会将于{p1}月{p2}日开启"
multiFight_atk_details = "{p1}胜{p2}败"
multiFight_atk_liansheng = "{p1}连胜"
multiFight_myRank = "排名:{p1}"
multiFight_highthonor = "龙令"
multiFight_lowhonor = "虎令"
multiFight_highthonor_des = "跨服通用稀有货币，能在跨服商店兑换稀有物品"
multiFight_lowhonor_des = "跨服通用普通货币，能在跨服商店兑换普通物品"
multiFight_score = "积分:"
multiFight_bet_sycee = "没有足够的灵玉"
multiFight_bet_coin = "没有足够的铜钱"
roleEquipChangeLayer_txt = "请选择互换装备的神灵"
roleEquipChangeLayer_txt1 = "换装成功"


--VIP
VIP_UNDER_18 = "VIP{p1}"
--VIP16 = "豪·VIP"
--VIP17 = "爵·VIP"
--VIP18 = "皇·VIP"

factionMail_noSycee = "灵玉不足"
factionMail_noTips = "标题不能为空"
factionMail_noContent = "内容不能为空"
factionMail_sucess = "发送成功"


roleInfoLayer_not_pro    = "没有可使用的道具"
roleInfoLayer_tips_1     = "该替身娃娃品质高于目标缘分，是否继续？"
roleInfoLayer_tips_2     ="该替身娃娃可激活人物缘分数高于目标缘分，是否继续？"
common_time_7			 ="{p1}天{p2}小时"
common_time_8			 ="{p1}小时{p2}分"
common_time_9			 ="{p1}分{p2}秒"
getJingyao_rongru_text1  ="是否卸下该精要?\n将返还阅历{p1}点"
Tianshu_Main_text1       ="已研习至最高重"
TreasureMain_text5		 ="没有更多的寻宝历史了"

SkyBookManager_text1	 ="典籍装配失败"
SkyBookManager_text2	 ="典籍卸下失败"
SkyBookManager_text3	 ="精要镶嵌失败"
SkyBookManager_text4	 ="典籍突破失败"
SkyBookManager_text5	 ="精要分解失败"
SkyBookManager_text6	 ="典籍重置失败"
SkyBookManager_text7	 ="典籍升重失败"
SkyBookManager_text7	 ="典籍升重失败"
SkyBookManager_text7	 ="典籍升重失败"
SkyBookManager_text7	 ="典籍升重失败"

TreasureManager_text1	 ="寻宝活动未开启"
functions_text1			 ="十"



HeadPicFrameManager_jiesuo_success = "成功解锁头像框:{p1}"
HeadPicFrameManager_wuxiao = "无效的头像框"

LianTi_Quality_Name_1	= "易筋"
LianTi_Quality_Name_2	= "粹骨"
LianTi_Quality_Name_3	= "换血"
LianTi_Quality_Name_4	= "洗髓"

RoleLianTiLayer_Point_tip_1 = "第一个部位易筋开放"
RoleLianTiLayer_Point_tip_2 = "第二个部位粹骨开放"
RoleLianTiLayer_Point_tip_3 = "第三个部位换血开放"
RoleLianTiLayer_Point_tip_4 = "第四个部位洗髓开放"

ItemTipLayer_have_txt	= "已拥有:"

FightMainLayer_BuyQualification_txt1 = "抱歉，服务器名额已满"
FightMainLayer_BuyQualification_txt2 = "是否报名跨服武林大会？"
FightMainLayer_BuyQualification_txt3 = "跨服赛报名成功"


ExtraReward_num = "当前排名段积分达{p1}可获得以上奖励"