--[[
通知常量
lizhuangzhuang
2014年10月21日15:55:26
]]

_G.RemindConsts = {};

--类型



-- position 2 右
RemindConsts.Type_NewMail     = 201; --新邮件提醒			position:	2	index:	1
RemindConsts.Type_EaLeftPoint = 202; --属性加点提示			position:	2	index:	2
RemindConsts.Type_FengYao     = 203; --封妖状态				position:	2	index:	3
RemindConsts.Type_HANG        = 204; --挂机					position:	2	index:	4
RemindConsts.Type_DropItem    = 205; --天赐机缘掉宝			position:	2	index:	5
RemindConsts.Type_LevelReward = 206; --等级奖励				position:	2	index:	6
RemindConsts.Type_FRecommend  = 208; --好友推荐				position:	2	index:	8
RemindConsts.Type_LvlUp		  = 209; --升级提醒				position:	2	index:	9
RemindConsts.Type_HuiZhang	  = 210; --聚灵碗提醒			position:	2	index:	10
RemindConsts.Type_FReward	  = 211; --好友升级奖励			position:	2	index:	11
RemindConsts.Type_Skill		  = 212; --技能升级提醒			position:	2	index:	12
RemindConsts.Type_LovelyPet	  = 213; --萌宠过期提醒			position:	2	index:	13
RemindConsts.Type_DominateRoute		= 214; --主宰之路扫荡提醒	position:	2	index:	14
RemindConsts.Type_InterContestPreZige	= 215; --跨服资格体香	position:	2	index:	15
RemindConsts.Type_SmithingStar = 216; --装备升星              position:   2   index:  16
RemindConsts.Type_SmithingInlay = 217;--宝石镶嵌             position:   2   index:  17
RemindConsts.Type_SmithingWash = 218; --装备洗练				position:   2   index:  18
RemindConsts.Type_LovelyPetFight = 219; --萌宠出战提醒		position:	2	index:	19
RemindConsts.Type_HuoYueDuUp = 220; --仙阶升级提醒			position:	2	index:	20
RemindConsts.Type_MountUp = 221; --坐骑升阶提醒				position:	2	index:	21
RemindConsts.Type_FuMo = 222; --伏魔激活升级提醒				position:	2	index:	22
RemindConsts.Type_XingTu = 223; --星图激活升级提醒				position:	2	index:	23
RemindConsts.Type_ZhuanZhi = 224; --转职奖励可以领取提醒				position:	2	index:	24
RemindConsts.Type_FriendApply = 101; --好友					position:	2	index:	25
--原来的 position 1 左
RemindConsts.Type_TeamApply   = 102; --申请入队				position:	2	index:	26
RemindConsts.Type_TeamInvite  = 103; --组队邀请				position:	2	index:	27
RemindConsts.Type_GuildInvite = 104; --帮派邀请				position:	2	index:	28
RemindConsts.Type_GuildZhaoji = 105; --帮主召集活动     		position:	2	index:	29
RemindConsts.Type_SWYJ        = 106; --死亡遗迹召集			position:   2   index:  30
RemindConsts.Type_GuildDGBid  = 107; --地宫竞标			    position:   2   index:  31
--原来的 position 3
RemindConsts.Type_CaveBoss	  = 301; --BOSS刷新提醒			position:	2	index:	32
RemindConsts.Type_LingLu	  = 302; --领路试练开启			position:	2	index:	33
RemindConsts.Type_UnionWar	  = 303; --帮派战斗 				position:	2	index:	34
RemindConsts.Type_UnionDGWar  = 304; --帮派地宫战斗 			position:	2	index:	35
RemindConsts.Type_UnionCityWar= 305; --帮派王城战 		    position:	2	index:	36
RemindConsts.Type_InterBoss	  = 306; --跨服boss 		    	position:	2	index:	37
RemindConsts.Type_InterContest= 307; --跨服擂台			    position:	2	index:	38

RemindConsts.Type_SmithingGroup = 225;--装备套装 			position:	2	index:	39
RemindConsts.Type_SmithingCollection = 226;--装备套装 			position:	2	index:	40
RemindConsts.Type_SkillJueXue = 227;--装备套装 			position:	2	index:	41