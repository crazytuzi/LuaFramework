local c2s = {}
--[[
	[1] = {--Worship
		[1] = 'int32':type	[祭拜类型]
	}
--]]
c2s.WORSHIP = 0x440d

--[[
	[1] = {--DrawMakePlayerAward
	}
--]]
c2s.DRAW_MAKE_PLAYER_AWARD = 0x4410

--[[
	[1] = {--LockPlayerMine
		[1] = 'int32':minePlayerId	[被劫矿的玩家]
		[2] = 'int32':id	[1,矿1,2,矿2]
	}
--]]
c2s.LOCK_PLAYER_MINE = 0x5009

--[[
	[1] = {--RequestExchangeGifts
		[1] = 'string':code	[礼包码]
	}
--]]
c2s.REQUEST_EXCHANGE_GIFTS = 0x3500

--[[
	[1] = {--BibleLevelUpRequest
		[1] = 'int64':instanceId	[id]
	}
--]]
c2s.BIBLE_LEVEL_UP_REQUEST = 0x6010

--[[
	[1] = {--GetActivityReward
		[1] = 'int32':type	[活动类型]
		[2] = 'int32':rewardId	[奖励配置表的ID]
	}
--]]
c2s.GET_ACTIVITY_REWARD = 0x3305

--[[
	[1] = {--UpgradeVIPInfo
		[1] = 'string':QQ	[QQ号码]
		[2] = 'string':telphone	[手机号]
	}
--]]
c2s.UPGRADE_VIPINFO = 0x1a20

--[[
	[1] = {--ChallengeByEmploy
		[1] = {--UpdateEmployFormation
			[1] = 'int32':type	[阵形类型,9.推图阵形]
			[2] = {--repeated MercenaryRoleInfo
				[1] = 'int64':instanceId	[角色实例ID]
				[2] = 'int32':position	[位置,0~8]
			},
			[3] = {--repeated MercenaryRoleInfo
				[1] = 'int64':instanceId	[角色实例ID]
				[2] = 'int32':position	[位置,0~8]
			},
		},
		[2] = 'int32':battleType	[战斗类型]
		[3] = 'string':params	[额外参数,每种战斗挑战时的附加参数不一致]
	}
--]]
c2s.CHALLENGE_BY_EMPLOY = 0x5131

--[[
	[1] = {--MountBookMsg
		[1] = 'int64':bookObjID	[book实例id]
		[2] = 'int64':roleID	[角色id]
		[3] = 'int32':position	[位置]
		[4] = 'bool':mount	[1 穿上 0卸下]
	}
--]]
c2s.MOUNT_BOOK = 0x1607

--[[
	[1] = {--QueryEmployRoleByUse
		[1] = 'int32':useType	[使用类型,客户端定义]
	}
--]]
c2s.QUERY_EMPLOY_ROLE_BY_USE = 0x5112

--[[
	[1] = {--GainFriendList
	}
--]]
c2s.GAIN_FRIEND_LIST = 0x4300

--[[
	[1] = {--UpdateGuildName
		[1] = 'string':Name	[新的名称]
	}
--]]
c2s.UPDATE_GUILD_NAME = 0x4428

--[[
	[1] = {--GetRecallTaskReward
		[1] = 'int32':taskid	[成就id 0代表领取全部奖励]
	}
--]]
c2s.GET_RECALL_TASK_REWARD = 0x5301

--[[
	[1] = {--GangSendBulletin
		[1] = 'string':bulletin
	}
--]]
c2s.GANG_SEND_BULLETIN = 0x1810

--[[
	[1] = {--GangAppointSecondMaster
		[1] = 'int32':playerId
	}
--]]
c2s.GANG_APPOINT_SECOND_MASTER = 0x1806

--[[
	[1] = {--SwapCurrentChatPlayer
		[1] = 'int32':playerId	[玩家编号]
	}
--]]
c2s.SWAP_CURRENT_CHAT_PLAYER = 0x1b04

--[[
	[1] = {--BloodySweepRequest
	}
--]]
c2s.BLOODY_SWEEP_REQUEST = 0x3230

--[[
	[1] = {--GangApplyAdd
		[1] = 'int32':gangId
	}
--]]
c2s.GANG_APPLY_ADD = 0x180b

--[[
	[1] = {--RolePractice
		[1] = 'int64':userid	[所需要修炼的角色实例id]
	}
--]]
c2s.ROLE_PRACTICE = 0x1509

--[[
	[1] = {--RequestAllActivityInfo
	}
--]]
c2s.REQUEST_ALL_ACTIVITY_INFO = 0x2301

--[[
	[1] = {--CreateGuild
		[1] = 'string':name	[名称]
		[2] = 'string':bannerId	[旗帜id]
	}
--]]
c2s.CREATE_GUILD = 0x4401

--[[
	[1] = {--QueryMyArenaChallengeBattleReport
	}
--]]
c2s.QUERY_MY_ARENA_CHALLENGE_BATTLE_REPORT = 0x1d42

--[[
	[1] = {--GangGetBuffInfo
	}
--]]
c2s.GANG_GET_BUFF_INFO = 0x1815

--[[
	[1] = {--Yabiao
	}
--]]
c2s.YABIAO = 0x3002

--[[
	[1] = {--RequestRecall
		[1] = 'int32':playerId	[被召回的目标玩家ID]
	}
--]]
c2s.REQUEST_RECALL = 0x5320

--[[
	[1] = {--EssentialUnMosaicRequest
		[1] = 'int64':bible	[精要的天书id]
		[2] = 'int32':pos	[卸下的精要的位置]
	}
--]]
c2s.ESSENTIAL_UN_MOSAIC_REQUEST = 0x6005

--[[
	[1] = {--queryBloodyBox
		[1] = 'int32':section	[关卡号(从1开始)    //关卡号(从1开始)]
	}
--]]
c2s.QUERY_BLOODY_BOX = 0x3211

--[[
	[1] = {--RequestRefineBreach
		[1] = 'int64':instanceId	[装备实例ID]
	}
--]]
c2s.REQUEST_REFINE_BREACH = 0x1080

--[[
	[1] = {--GangTransferMaster
	}
--]]
c2s.GANG_TRANSFER_MASTER = 0x1808

--[[
	[1] = {--EquipmentRefining
		[1] = 'int64':equipment	[装备userid]
		[2] = 'repeated int32':lock_attr	[锁定的属性行]
	}
--]]
c2s.EQUIPMENT_REFINING = 0x1019

--[[
	[1] = {--PayGetBillNo
		[1] = 'int32':id	[商品ID]
		[2] = 'int32':source	[来源标识(0:未知,1:招募)    //来源标识(0:未知,1:招募)]
	}
--]]
c2s.PAY_GET_BILL_NO = 0x1a00

--[[
	[1] = {--QueryBeRecalledInviteList
	}
--]]
c2s.QUERY_BE_RECALLED_INVITE_LIST = 0x5321

--[[
	[1] = {--GetFirstRechargeReward
	}
--]]
c2s.GET_FIRST_RECHARGE_REWARD = 0x1a10

--[[
	[1] = {--GainAssistantInfo
	}
--]]
c2s.GAIN_ASSISTANT_INFO = 0x4601

--[[
	[1] = {--ResetZone
		[1] = 'int32':zoneId
	}
--]]
c2s.RESET_ZONE = 0x441c

--[[
	[1] = {--QueryEmployRoleList
	}
--]]
c2s.QUERY_EMPLOY_ROLE_LIST = 0x5111

--[[
	[1] = {--LockBookMsg
		[1] = 'int64':objID	[实例id]
	}
--]]
c2s.LOCK_BOOK = 0x1605

--[[
	[1] = {--DiningRequest
	}
--]]
c2s.DINING_REQUEST = 0x2502

--[[
	[1] = {--PurchaseOrderForMysteryStore
		[1] = 'int32':commodityId	[购买商品的id]
	}
--]]
c2s.PURCHASE_ORDER_FOR_MYSTERY_STORE = 0x1911

--[[
	[1] = {--CancelApply
		[1] = 'int32':guildId	[公会编号]
	}
--]]
c2s.CANCEL_APPLY = 0x440b

--[[
	[1] = {--QueryQuestMsg
	}
--]]
c2s.QUERY_QUEST = 0x1400

--[[
	[1] = {--ExecApplyFriend
		[1] = 'int32':type	[ 类型 1同意单个 2 同意全部 3 忽略单个 4 忽略全部]
		[2] = 'int32':playerId
	}
--]]
c2s.EXEC_APPLY_FRIEND = 0x4304

--[[
	[1] = {--ResetChallengeMine
		[1] = 'int32':type	[矿洞]
		[2] = 'int32':minePlayerId	[被重置的玩家id]
	}
--]]
c2s.RESET_CHALLENGE_MINE = 0x500f

--[[
	[1] = {--ChallengeNorthCave
		[1] = 'int32':sectionId	[目标关卡ID,1~N]
		[2] = 'int32':choice	[挑战关卡选项]
		[3] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_NORTH_CAVE = 0x4901

--[[
	[1] = {--DrawAssistantAward
		[1] = 'int32':friendId
	}
--]]
c2s.DRAW_ASSISTANT_AWARD = 0x4313

--[[
	[1] = {--SendGuildInvitation
		[1] = 'int32':playerId
	}
--]]
c2s.SEND_GUILD_INVITATION = 0x4413

--[[
	[1] = {--ReConnectRequest
		[1] = 'string':accountId	[帐号id]
		[2] = 'string':validateCode	[登录完成后获得的校验码]
		[3] = 'int32':serverId	[服务器唯一标识]
		[4] = 'string':token	[设备token]
		[5] = 'string':deviceName	[设备名称]
		[6] = 'string':osName	[设备系统名称]
		[7] = 'string':osVersion	[设备系统版本]
		[8] = 'string':channel	[渠道]
		[9] = 'string':sdk	[第三方接入类型.如:PP.91等]
		[10] = 'string':deviceid	[设备ID唯一标识]
		[11] = 'string':sdkVersion	[SDK版本]
		[12] = 'string':MCC	[移动设备国家码]
		[13] = 'string':IP	[联网IP地址]
	}
--]]
c2s.RE_CONNECT_REQUEST = 0x0d10

--[[
	[1] = {--GainGuildInfo
		[1] = 'int32':guildId
	}
--]]
c2s.GAIN_GUILD_INFO = 0x4406

--[[
	[1] = {--ItembatchUsed
		[1] = 'int32':itemId	[道具ID]
		[2] = 'int32':num	[道具数量]
	}
--]]
c2s.ITEMBATCH_USED = 0x1061

--[[
	[1] = {--GetFixedStore
	}
--]]
c2s.GET_FIXED_STORE = 0x1901

--[[
	[1] = {--AdventureMassacre
	}
--]]
c2s.ADVENTURE_MASSACRE = 0x5907

--[[
	[1] = {--QueryMine
	}
--]]
c2s.QUERY_MINE = 0x5000

--[[
	[1] = {--GainGuildZoneInfo
		[1] = 'int32':zoneId
	}
--]]
c2s.GAIN_GUILD_ZONE_INFO = 0x4421

--[[
	[1] = {--PurchaseOrderForFixedStore
		[1] = 'int32':commodityId	[购买商品的id]
		[2] = 'int32':num	[购买商品的个数]
	}
--]]
c2s.PURCHASE_ORDER_FOR_FIXED_STORE = 0x1900

--[[
	[1] = {--EmployRoleOperation
		[1] = 'int64':roleId	[角色实例id]
		[2] = 'int32':operation	[操作符,1表示增加,2表示移除,3表示领取]
		[3] = 'int32':indexId	[位置id]
	}
--]]
c2s.EMPLOY_ROLE_OPERATION = 0x5101

--[[
	[1] = {--ViewNotice
	}
--]]
c2s.VIEW_NOTICE = 0x4431

--[[
	[1] = {--UnequipBibleRequest
		[1] = 'int64':roleId	[角色实例id]
		[2] = 'int64':bible	[要脱下的天书userid]
	}
--]]
c2s.UNEQUIP_BIBLE_REQUEST = 0x6002

--[[
	[1] = {--GetMiningPointListAroundMine
		[1] = 'int32':type	[宝藏类型.1:连城宝藏;2:闯王宝藏;3:大清龙脉]
		[2] = 'int32':begin	[起始索引,宝藏挖掘点索引,第几个位置.1--n    //起始索引,宝藏挖掘点索引,第几个位置.1--n]
		[3] = 'int32':end	[结束索引,宝藏挖掘点索引,第几个位置.1--n    //结束索引,宝藏挖掘点索引,第几个位置.1--n]
	}
--]]
c2s.GET_MINING_POINT_LIST_AROUND_MINE = 0x2202

--[[
	[1] = {--OpenZone
		[1] = 'int32':zoneId
	}
--]]
c2s.OPEN_ZONE = 0x441b

--[[
	[1] = {--GangCreate
		[1] = 'string':gangName
	}
--]]
c2s.GANG_CREATE = 0x180c

--[[
	[1] = {--GangRefleshExchangeList
	}
--]]
c2s.GANG_REFLESH_EXCHANGE_LIST = 0x1812

--[[
	[1] = {--GetInvocatoryReward
		[1] = 'int32':roleId	[祈愿的侠客模板id]
	}
--]]
c2s.GET_INVOCATORY_REWARD = 0x5401

--[[
	[1] = {--ChallengeMission
		[1] = 'int32':missionId
		[2] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_MISSION = 0x1201

--[[
	[1] = {--EquipRequest
		[1] = 'int64':roleId	[角色实例id]
		[2] = 'int64':equipment	[装备到身上的装备userid]
	}
--]]
c2s.EQUIP_REQUEST = 0x1011

--[[
	[1] = {--RondomBloodyBox
		[1] = 'int32':section	[关卡号(从1开始)    //关卡号(从1开始)]
	}
--]]
c2s.RONDOM_BLOODY_BOX = 0x3212

--[[
	[1] = {--StartSecondBattle
	}
--]]
c2s.START_SECOND_BATTLE = 0x5915

--[[
	[1] = {--ResetChallengeCountRequest
		[1] = 'int32':missionId	[关卡Id]
	}
--]]
c2s.RESET_CHALLENGE_COUNT_REQUEST = 0x1203

--[[
	[1] = {--BloodyOffBattle
		[1] = 'int64':roleId	[角色id]
	}
--]]
c2s.BLOODY_OFF_BATTLE = 0x3203

--[[
	[1] = {--ArenaGetHomeInfo
	}
--]]
c2s.ARENA_GET_HOME_INFO = 0x1305

--[[
	[1] = {--AdventureMassacreRanking
	}
--]]
c2s.ADVENTURE_MASSACRE_RANKING = 0x5908

--[[
	[1] = {--GetBookMsg
		[1] = 'int32':bookpos	[ pos为0拾取所有]
	}
--]]
c2s.GET_BOOK = 0x1602

--[[
	[1] = {--RequestMyEmployInfo
	}
--]]
c2s.REQUEST_MY_EMPLOY_INFO = 0x5100

--[[
	[1] = {--ArenaChallengePlayer
		[1] = 'int32':playerId
	}
--]]
c2s.ARENA_CHALLENGE_PLAYER = 0x1304

--[[
	[1] = {--GangRefleshBuffInfo
	}
--]]
c2s.GANG_REFLESH_BUFF_INFO = 0x1816

--[[
	[1] = {--QueryScoreRankInfos
	}
--]]
c2s.QUERY_SCORE_RANK_INFOS = 0x4516

--[[
	[1] = {--AdventureInterface
	}
--]]
c2s.ADVENTURE_INTERFACE = 0x5900

--[[
	[1] = {--DeleteFriend
		[1] = 'int32':friendId
	}
--]]
c2s.DELETE_FRIEND = 0x4307

--[[
	[1] = {--GiveGifi
		[1] = 'int32':friendId
	}
--]]
c2s.GIVE_GIFI = 0x4305

--[[
	[1] = {--EmployTeamDetailsQuery
		[1] = 'int32':playerId	[目标玩家ID]
		[2] = 'int32':useType	[使用类型]
	}
--]]
c2s.EMPLOY_TEAM_DETAILS_QUERY = 0x5161

--[[
	[1] = {--ResetPlayerTime
	}
--]]
c2s.RESET_PLAYER_TIME = 0x5914

--[[
	[1] = {--RequestActivityProgressList
	}
--]]
c2s.REQUEST_ACTIVITY_PROGRESS_LIST = 0x2303

--[[
	[1] = {--WatchServerBattleReplay
		[1] = 'int32':replayId
	}
--]]
c2s.WATCH_SERVER_BATTLE_REPLAY = 0x0f23

--[[
	[1] = {--QueryPlayer
		[1] = 'string':name
	}
--]]
c2s.QUERY_PLAYER = 0x430d

--[[
	[1] = {--QueryActivityRankList
		[1] = 'int32':type	[排行榜类型.0:全部]
	}
--]]
c2s.QUERY_ACTIVITY_RANK_LIST = 0x3303

--[[
	[1] = {--QueryInvocatory
	}
--]]
c2s.QUERY_INVOCATORY = 0x5400

--[[
	[1] = {--ClimbChallengeMountain
		[1] = 'int32':mountainId
		[2] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CLIMB_CHALLENGE_MOUNTAIN = 0x1701

--[[
	[1] = {--QuerySevenDaysGoalTask
	}
--]]
c2s.QUERY_SEVEN_DAYS_GOAL_TASK = 0x2051

--[[
	[1] = {--RegistData
		[1] = 'string':name	[昵称]
		[2] = {--Sex(enum)
			'v4':Sex
		},
		[3] = 'int32':profession	[选中的卡牌类型(相当于职业)    //选中的卡牌类型(相当于职业)]
	}
--]]
c2s.REGIST_DATA = 0x0d01

--[[
	[1] = {--RequestMartialSynthesis
		[1] = 'int32':martialId	[合成产出的武学]
		[2] = 'bool':autoSynthesis	[是否自动合成,只有在没有该武学,但是又拥有足够材料的情况下才为true,可以节省用户合成所需要的操作,由客户端进行智能验证填写,如果客户端不支持智能校验则填写为false]
	}
--]]
c2s.REQUEST_MARTIAL_SYNTHESIS = 0x3404

--[[
	[1] = {--GetMHYPassInfoRequest
	}
--]]
c2s.GET_MHYPASS_INFO_REQUEST = 0x1721

--[[
	[1] = {--RequestAllEmployInfo
	}
--]]
c2s.REQUEST_ALL_EMPLOY_INFO = 0x5104

--[[
	[1] = {--GangGetExchangeList
	}
--]]
c2s.GANG_GET_EXCHANGE_LIST = 0x1811

--[[
	[1] = {--Study
		[1] = 'int32':attributeType
	}
--]]
c2s.STUDY = 0x4423

--[[
	[1] = {--RequestChoiceCaveAttribute
		[1] = 'int32':targetId	[选中的属性ID]
		[2] = 'int32':index	[层数,1~N,最后一个属性可以传0]
	}
--]]
c2s.REQUEST_CHOICE_CAVE_ATTRIBUTE = 0x4920

--[[
	[1] = {--GainChampionsWarInfo
	}
--]]
c2s.GAIN_CHAMPIONS_WAR_INFO = 0x4511

--[[
	[1] = {--SweepSection
		[1] = 'int32':missionId	[关卡Id]
		[2] = 'int32':time	[扫荡次数]
	}
--]]
c2s.SWEEP_SECTION = 0x1205

--[[
	[1] = {--ProvideFriendAssistant
		[1] = 'repeated int32':friendIds	[提供给你人]
	}
--]]
c2s.PROVIDE_FRIEND_ASSISTANT = 0x4311

--[[
	[1] = {--DrawDpsAward
		[1] = 'int32':zoneId
		[2] = 'int32':awardId
	}
--]]
c2s.DRAW_DPS_AWARD = 0x4420

--[[
	[1] = {--GainRankInfo
	}
--]]
c2s.GAIN_RANK_INFO = 0x4509

--[[
	[1] = {--VerifyInviteCode
		[1] = 'string':inviteCode	[需要验证的邀请码]
	}
--]]
c2s.VERIFY_INVITE_CODE = 0x2601

--[[
	[1] = {--GainFriendAssistantInfoList
	}
--]]
c2s.GAIN_FRIEND_ASSISTANT_INFO_LIST = 0x4312

--[[
	[1] = {--QueryQualificationInfos
	}
--]]
c2s.QUERY_QUALIFICATION_INFOS = 0x4514

--[[
	[1] = {--GangGetDynamicInfo
	}
--]]
c2s.GANG_GET_DYNAMIC_INFO = 0x1802

--[[
	[1] = {--GangGetRankList
	}
--]]
c2s.GANG_GET_RANK_LIST = 0x1800

--[[
	[1] = {--GangExit
	}
--]]
c2s.GANG_EXIT = 0x1809

--[[
	[1] = {--UpdateAssistantRole
		[1] = 'int32':type	[类型]
		[2] = 'repeated int64':roles	[阵容上的人]
	}
--]]
c2s.UPDATE_ASSISTANT_ROLE = 0x4603

--[[
	[1] = {--OneKeyEquipRefine
		[1] = 'int64':instanceId	[装备实例ID]
		[2] = 'repeated int32':lock_attr	[锁定的属性行]
	}
--]]
c2s.ONE_KEY_EQUIP_REFINE = 0x1081

--[[
	[1] = {--EquipmentStarUp
		[1] = 'int64':equipment	[装备userid]
		[2] = 'repeated int64':eat_equipment	[吞噬的装备userid]
		[3] = {--repeated StuffStruct
			[1] = 'int32':id	[物品ID]
			[2] = 'int32':number	[数量]
		},
	}
--]]
c2s.EQUIPMENT_STAR_UP = 0x1020

--[[
	[1] = {--GetYabiaoReward
	}
--]]
c2s.GET_YABIAO_REWARD = 0x3003

--[[
	[1] = {--RoleRebirth
		[1] = 'int64':userid	[所需要重生的角色实例id]
	}
--]]
c2s.ROLE_REBIRTH = 0x1511

--[[
	[1] = {--OneKeySweepRequest
	}
--]]
c2s.ONE_KEY_SWEEP_REQUEST = 0x4930

--[[
	[1] = {--QueryQimenMsg
	}
--]]
c2s.QUERY_QIMEN = 0x5200

--[[
	[1] = {--XiaKeHereditary
		[1] = 'int64':roleId	[ 角色实例id]
		[2] = 'int64':hereditaryId	[ 接受传承的角色实例id]
	}
--]]
c2s.XIA_KE_HEREDITARY = 0x6501

--[[
	[1] = {--XieKeExchangeEquip
		[1] = 'int64':roleId	[ 角色实例id]
		[2] = 'int64':exchangeId	[ 互换的角色实例id]
	}
--]]
c2s.XIE_KE_EXCHANGE_EQUIP = 0x6500

--[[
	[1] = {--GagPlayerRequest
		[1] = 'int32':targetId	[目标玩家ID]
		[2] = 'int32':type	[操作类型]
	}
--]]
c2s.GAG_PLAYER_REQUEST = 0x7f30

--[[
	[1] = {--OpenWorshipBox
		[1] = 'int32':num	[宝箱值]
	}
--]]
c2s.OPEN_WORSHIP_BOX = 0x440e

--[[
	[1] = {--RequestMergeAuto
	}
--]]
c2s.REQUEST_MERGE_AUTO = 0x5804

--[[
	[1] = {--ClimbGetHomeInfo
	}
--]]
c2s.CLIMB_GET_HOME_INFO = 0x1702

--[[
	[1] = {--ChallengeWorldBoss
		[1] = 'int32':targetId	[目标BOSS配置ID]
		[2] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_WORLD_BOSS = 0x4200

--[[
	[1] = {--WatchCrossServerBattleReplay
		[1] = 'int32':replayId
	}
--]]
c2s.WATCH_CROSS_SERVER_BATTLE_REPLAY = 0x0f24

--[[
	[1] = {--AutoWarMatix
	}
--]]
c2s.AUTO_WAR_MATIX = 0x0e24

--[[
	[1] = {--UpdateGuildInfo
		[1] = 'int32':type	[类型 1公告 2 宣言]
		[2] = 'string':mess	[消息]
	}
--]]
c2s.UPDATE_GUILD_INFO = 0x4408

--[[
	[1] = {--RequestMartialEnchant
		[1] = 'int64':roleId	[角色id]
		[2] = 'int32':position	[武学装备位置]
		[3] = {--repeated EnchantMaterial
			[1] = 'int32':id	[id]
			[2] = 'int32':number	[个数]
		},
	}
--]]
c2s.REQUEST_MARTIAL_ENCHANT = 0x3405

--[[
	[1] = {--GetMineReward
		[1] = 'int32':id	[1,领取矿1的奖励,2,领取矿2的奖励]
	}
--]]
c2s.GET_MINE_REWARD = 0x5003

--[[
	[1] = {--ChampionsBet
		[1] = 'int32':roundId
		[2] = 'int32':index
		[3] = 'int32':coin
		[4] = 'int32':betPlayerId
	}
--]]
c2s.CHAMPIONS_BET = 0x4512

--[[
	[1] = {--ChangeIndex
		[1] = 'int32':from
		[2] = 'int32':target
	}
--]]
c2s.CHANGE_INDEX = 0x0e22

--[[
	[1] = {--AdventureShopBuy
		[1] = 'int32':type	[ 类型 1.珍本 2.善本 3.全本 4.抄本 5.残本]
		[2] = 'int32':goodsId	[ 购买货物的ID]
		[3] = 'int32':buyNum	[ 购买的数量]
	}
--]]
c2s.ADVENTURE_SHOP_BUY = 0x5904

--[[
	[1] = {--GetPayRecordList
	}
--]]
c2s.GET_PAY_RECORD_LIST = 0x1a04

--[[
	[1] = {--DispatchMercenaryTeam
		[1] = {--repeated MercenaryRoleInfo
			[1] = 'int64':instanceId	[角色实例ID]
			[2] = 'int32':position	[位置,0~8]
		},
		[2] = {--repeated MercenaryRoleInfo
			[1] = 'int64':instanceId	[角色实例ID]
			[2] = 'int32':position	[位置,0~8]
		},
	}
--]]
c2s.DISPATCH_MERCENARY_TEAM = 0x5151

--[[
	[1] = {--QueryCrossChampionsWarInfos
	}
--]]
c2s.QUERY_CROSS_CHAMPIONS_WAR_INFOS = 0x4517

--[[
	[1] = {--MergeEquipment
		[1] = 'int32':fragmentId	[碎片ID]
	}
--]]
c2s.MERGE_EQUIPMENT = 0x1060

--[[
	[1] = {--OutBattle
		[1] = 'int64':userId
	}
--]]
c2s.OUT_BATTLE = 0x0e23

--[[
	[1] = {--QueryTask
	}
--]]
c2s.QUERY_TASK = 0x2001

--[[
	[1] = {--ToBattle
		[1] = {--RoleConfigure
			[1] = 'int64':userId
			[2] = 'int32':index
		},
	}
--]]
c2s.TO_BATTLE = 0x0e21

--[[
	[1] = {--RequestChangeCaveOption
		[1] = 'int32':sectionId	[选中的关卡ID]
	}
--]]
c2s.REQUEST_CHANGE_CAVE_OPTION = 0x4923

--[[
	[1] = {--QueryBloodyEnemyInfo
		[1] = 'int32':section	[关卡号(从1开始)    //关卡号(从1开始)]
	}
--]]
c2s.QUERY_BLOODY_ENEMY_INFO = 0x3208

--[[
	[1] = {--CrossChampionsBet
		[1] = 'int32':roundId
		[2] = 'int32':index
		[3] = 'int32':coin
		[4] = 'int32':betPlayerId
	}
--]]
c2s.CROSS_CHAMPIONS_BET = 0x4518

--[[
	[1] = {--FreshMineList
	}
--]]
c2s.FRESH_MINE_LIST = 0x5007

--[[
	[1] = {--GetOtherRoleDetails
		[1] = 'int32':playerId	[玩家ID]
		[2] = 'int64':instanceId	[角色实例ID]
	}
--]]
c2s.GET_OTHER_ROLE_DETAILS = 0x0e73

--[[
	[1] = {--SummonPaladin
		[1] = 'int32':soulId	[侠魂ID]
	}
--]]
c2s.SUMMON_PALADIN = 0x0e90

--[[
	[1] = {--GainSimpleInfo
		[1] = 'int32':playerId
	}
--]]
c2s.GAIN_SIMPLE_INFO = 0x0e98

--[[
	[1] = {--Inheritance
		[1] = 'int64':instanceId
		[2] = 'int32':attributeType
		[3] = 'int64':inheritanceInstanceIdId
	}
--]]
c2s.INHERITANCE = 0x4426

--[[
	[1] = {--QueryOpenServiceActivityStatus
		[1] = 'int32':type	[类型.0:全部]
	}
--]]
c2s.QUERY_OPEN_SERVICE_ACTIVITY_STATUS = 0x3300

--[[
	[1] = {--EmployOtherInfo
	}
--]]
c2s.EMPLOY_OTHER_INFO = 0x5103

--[[
	[1] = {--GainRelpys
	}
--]]
c2s.GAIN_RELPYS = 0x500d

--[[
	[1] = {--GainFriendApplyList
	}
--]]
c2s.GAIN_FRIEND_APPLY_LIST = 0x4301

--[[
	[1] = {--HeadPicFrameSet
		[1] = 'int32':id
	}
--]]
c2s.HEAD_PIC_FRAME_SET = 0x0e96

--[[
	[1] = {--RequestResetArenaCD
	}
--]]
c2s.REQUEST_RESET_ARENA_CD = 0x1308

--[[
	[1] = {--UpdateDemand
		[1] = 'int64':id
	}
--]]
c2s.UPDATE_DEMAND = 0x430e

--[[
	[1] = {--GetPlayerBaseInfo
		[1] = 'int32':playerId	[玩家id]
	}
--]]
c2s.GET_PLAYER_BASE_INFO = 0x0e70

--[[
	[1] = {--GetPlayerDetails
		[1] = 'int32':playerId	[玩家id]
		[2] = 'int32':type	[类型]
	}
--]]
c2s.GET_PLAYER_DETAILS = 0x0e71

--[[
	[1] = {--GainRecommendFriend
	}
--]]
c2s.GAIN_RECOMMEND_FRIEND = 0x4302

--[[
	[1] = {--ApplyFriend
		[1] = 'repeated int32':playerIds
	}
--]]
c2s.APPLY_FRIEND = 0x4303

--[[
	[1] = {--ChallengeEscorting
		[1] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_ESCORTING = 0x2900

--[[
	[1] = {--ApplyCrossChampions
	}
--]]
c2s.APPLY_CROSS_CHAMPIONS = 0x4523

--[[
	[1] = {--GemBulid
		[1] = 'int32':itemId	[id]
		[2] = 'bool':isTuhao	[是否是土豪合成]
	}
--]]
c2s.GEM_BULID = 0x1050

--[[
	[1] = {--QueryBloodyDetail
	}
--]]
c2s.QUERY_BLOODY_DETAIL = 0x3209

--[[
	[1] = {--QimenBreachMsg
	}
--]]
c2s.QIMEN_BREACH = 0x5202

--[[
	[1] = {--QueryGuildBattleLastWiner
	}
--]]
c2s.QUERY_GUILD_BATTLE_LAST_WINER = 0x5707

--[[
	[1] = {--QueryAttrAddMsg
	}
--]]
c2s.QUERY_ATTR_ADD = 0x1402

--[[
	[1] = {--RequestAllEmailRewards
	}
--]]
c2s.REQUEST_ALL_EMAIL_REWARDS = 0x1d11

--[[
	[1] = {--UpdatePlayerName
		[1] = 'string':Name	[新的名称]
	}
--]]
c2s.UPDATE_PLAYER_NAME = 0x0e11

--[[
	[1] = {--UpdateBeginnersGuideSetpRequest
		[1] = 'int32':beginnersGuide	[新手进度]
		[2] = 'string':openlist	[已开放玩法列表]
	}
--]]
c2s.UPDATE_BEGINNERS_GUIDE_SETP_REQUEST = 0x0e80

--[[
	[1] = {--ChangeIconRequest
		[1] = 'int32':iconId	[更换的头像ID]
	}
--]]
c2s.CHANGE_ICON_REQUEST = 0x0e91

--[[
	[1] = {--RefreshMine
		[1] = 'int32':id	[1,刷新矿1,2,刷新矿2]
	}
--]]
c2s.REFRESH_MINE = 0x5001

--[[
	[1] = {--GainGuildDynamic
	}
--]]
c2s.GAIN_GUILD_DYNAMIC = 0x4419

--[[
	[1] = {--GetMiningPointList
		[1] = 'int32':type	[宝藏类型.1:连城宝藏;2:闯王宝藏;3:大清龙脉]
		[2] = 'int32':begin	[起始索引,宝藏挖掘点索引,第几个位置.1--n    //起始索引,宝藏挖掘点索引,第几个位置.1--n]
		[3] = 'int32':end	[结束索引,宝藏挖掘点索引,第几个位置.1--n    //结束索引,宝藏挖掘点索引,第几个位置.1--n]
	}
--]]
c2s.GET_MINING_POINT_LIST = 0x2201

--[[
	[1] = {--ResetClimbState
	}
--]]
c2s.RESET_CLIMB_STATE = 0x1700

--[[
	[1] = {--GainCrossOtherInfo
		[1] = 'int32':playerId
		[2] = 'int32':serverId
	}
--]]
c2s.GAIN_CROSS_OTHER_INFO = 0x0e99

--[[
	[1] = {--ChallengeMiningPoint
		[1] = 'int32':type	[宝藏类型.1:连城宝藏;2:闯王宝藏;3:大清龙脉]
		[2] = 'int32':index	[宝藏挖掘点索引,第几个位置.1--n    //宝藏挖掘点索引,第几个位置.1--n]
		[3] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_MINING_POINT = 0x2200

--[[
	[1] = {--QueryChallengeTimes
	}
--]]
c2s.QUERY_CHALLENGE_TIMES = 0x1405

--[[
	[1] = {--RequestCountBuyCoin
		[1] = 'int32':count	[购买次数]
	}
--]]
c2s.REQUEST_COUNT_BUY_COIN = 0x1930

--[[
	[1] = {--VisitMasterMsg
		[1] = 'bool':visitall	[ 1 表示一键拜访]
	}
--]]
c2s.VISIT_MASTER = 0x1601

--[[
	[1] = {--ChooseExtraAwayTreasureBox
	}
--]]
c2s.CHOOSE_EXTRA_AWAY_TREASURE_BOX = 0x2206

--[[
	[1] = {--GemMosaic
		[1] = 'int64':equipment	[镶嵌的装备id]
		[2] = 'int32':itemId	[宝石id]
		[3] = 'int32':pos	[镶嵌的位置]
	}
--]]
c2s.GEM_MOSAIC = 0x1051

--[[
	[1] = {--GoldEggInfo
	}
--]]
c2s.GOLD_EGG_INFO = 0x4701

--[[
	[1] = {--RequestBatchBetAuto
		[1] = 'int32':count	[自动赌石次数.0表示服务器控制]
	}
--]]
c2s.REQUEST_BATCH_BET_AUTO = 0x5801

--[[
	[1] = {--QueryBloodyInfo
	}
--]]
c2s.QUERY_BLOODY_INFO = 0x3200

--[[
	[1] = {--GetTaskReward
		[1] = 'int32':taskid	[成就id 0代表领取全部奖励]
	}
--]]
c2s.GET_TASK_REWARD = 0x2002

--[[
	[1] = {--challengeBloodyEnemy
		[1] = 'int32':section	[关卡号(从1开始)    //关卡号(从1开始)]
	}
--]]
c2s.CHALLENGE_BLOODY_ENEMY = 0x3210

--[[
	[1] = {--QueryGetSystemNotifyItem
		[1] = 'int32':notifyid	[消息ID]
	}
--]]
c2s.QUERY_GET_SYSTEM_NOTIFY_ITEM = 0x1d10

--[[
	[1] = {--SettingSendBug
		[1] = 'string':content	[bug内容]
	}
--]]
c2s.SETTING_SEND_BUG = 0x1e02

--[[
	[1] = {--QueryMyTreasureInfo
	}
--]]
c2s.QUERY_MY_TREASURE_INFO = 0x2203

--[[
	[1] = {--EmployTeamRequest
		[1] = 'int32':playerId	[目标玩家ID]
		[2] = 'int32':useType	[使用类型]
	}
--]]
c2s.EMPLOY_TEAM_REQUEST = 0x5160

--[[
	[1] = {--TreasureHuntExtraReward
		[1] = 'int32':id	[宝箱档次id]
	}
--]]
c2s.TREASURE_HUNT_EXTRA_REWARD = 0x6303

--[[
	[1] = {--PurchaseOrderForHeroStore
		[1] = 'int32':commodityId	[购买商品的id]
		[2] = 'int32':num	[购买商品的个数]
	}
--]]
c2s.PURCHASE_ORDER_FOR_HERO_STORE = 0x1906

--[[
	[1] = {--GetMyTGReward
	}
--]]
c2s.GET_MY_TGREWARD = 0x1313

--[[
	[1] = {--GainChatInfo
		[1] = 'int32':type	[类型 1世界.2公会]
	}
--]]
c2s.GAIN_CHAT_INFO = 0x1b07

--[[
	[1] = {--QueryLeftChallengeTimes
		[1] = 'int32':battleType	[1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点    //1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点]
	}
--]]
c2s.QUERY_LEFT_CHALLENGE_TIMES = 0x2101

--[[
	[1] = {--TreasureHuntConfig
	}
--]]
c2s.TREASURE_HUNT_CONFIG = 0x6300

--[[
	[1] = {--TreasureHuntResult
		[1] = 'int32':count	[寻宝次数]
	}
--]]
c2s.TREASURE_HUNT_RESULT = 0x6301

--[[
	[1] = {--RequestActivityInfo
		[1] = 'int32':id	[活动ID]
	}
--]]
c2s.REQUEST_ACTIVITY_INFO = 0x2300

--[[
	[1] = {--GetTGEnemyDetails
		[1] = 'int32':playerId	[玩家id]
	}
--]]
c2s.GET_TGENEMY_DETAILS = 0x1315

--[[
	[1] = {--GetMyTGRank
	}
--]]
c2s.GET_MY_TGRANK = 0x1312

--[[
	[1] = {--GetMyTGTime
	}
--]]
c2s.GET_MY_TGTIME = 0x1314

--[[
	[1] = {--GetInfoTG
		[1] = 'int32':type	[天罡星等级类型.0:初级;1:中级;2:高级]
		[2] = 'int32':begin	[座位索引,第几位.0~n]
		[3] = 'int32':end	[座位索引,第几位.0~n]
	}
--]]
c2s.GET_INFO_TG = 0x1311

--[[
	[1] = {--ChallengeTG
		[1] = 'int32':type	[天罡星等级类型.0:初级;1:中级;2:高级]
		[2] = 'int32':seatIndex	[座位索引,第几位.0~n]
		[3] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_TG = 0x1310

--[[
	[1] = {--TestPackage
		[1] = {--TPAType(enum)
			'v4':TPAType
		},
		[2] = 'int32':goodsId
		[3] = 'int32':number
	}
--]]
c2s.TEST_PACKAGE = 0xee01

--[[
	[1] = {--GainGuildInvitation
	}
--]]
c2s.GAIN_GUILD_INVITATION = 0x4412

--[[
	[1] = {--StartPractice
		[1] = 'int32':pos
		[2] = 'int64':instanceId
		[3] = 'int32':attributeType
	}
--]]
c2s.START_PRACTICE = 0x4424

--[[
	[1] = {--UpdateHosting
		[1] = 'bool':hosting
	}
--]]
c2s.UPDATE_HOSTING = 0x4522

--[[
	[1] = {--FriendChallenge
		[1] = 'int32':friendId
	}
--]]
c2s.FRIEND_CHALLENGE = 0x430c

--[[
	[1] = {--RefreshRandomStore
		[1] = 'int32':type	[随机商店类型,为了兼容多种随机商店]
	}
--]]
c2s.REFRESH_RANDOM_STORE = 0x1903

--[[
	[1] = {--ComposeBookMsg
		[1] = 'int64':objID	[book实例id]
		[2] = 'repeated int64':composedBookList	[被吞噬booklist]
		[3] = 'bool':composeAll	[是否一键合成]
	}
--]]
c2s.COMPOSE_BOOK = 0x1606

--[[
	[1] = {--GetContractDailyReward
		[1] = 'int32':id	[契约模板ID]
	}
--]]
c2s.GET_CONTRACT_DAILY_REWARD = 0x2802

--[[
	[1] = {--RequestDelEmail
		[1] = 'int32':notifyid	[消息ID, 0:为删除所有,其他为删除特定邮件]
	}
--]]
c2s.REQUEST_DEL_EMAIL = 0x1d12

--[[
	[1] = {--RequestBetByType
		[1] = 'int32':type	[赌石类型,1.试刀;2.切割;4.打磨;8.精工;16.雕琢]
	}
--]]
c2s.REQUEST_BET_BY_TYPE = 0x5800

--[[
	[1] = {--GangGetAddMemberList
	}
--]]
c2s.GANG_GET_ADD_MEMBER_LIST = 0x1804

--[[
	[1] = {--DeleteApply
		[1] = 'int32':playerId
	}
--]]
c2s.DELETE_APPLY = 0x4404

--[[
	[1] = {--GetInvocatoryDayReward
	}
--]]
c2s.GET_INVOCATORY_DAY_REWARD = 0x5403

--[[
	[1] = {--AdventureEvent
		[1] = 'int32':eventId	[ 事件ID]
	}
--]]
c2s.ADVENTURE_EVENT = 0x5910

--[[
	[1] = {--TestGetPartner
		[1] = 'int32':templateId
	}
--]]
c2s.TEST_GET_PARTNER = 0xee02

--[[
	[1] = {--EquipBilbleRequest
		[1] = 'int64':roleId	[角色实例id]
		[2] = 'int64':bible	[装备到身上的天书userid]
		[3] = 'int32':itemid	[装备到身上的天书的模板id]
	}
--]]
c2s.EQUIP_BILBLE_REQUEST = 0x6001

--[[
	[1] = {--TestChallengeSection
		[1] = 'int32':sectionId
	}
--]]
c2s.TEST_CHALLENGE_SECTION = 0xee00

--[[
	[1] = {--UnlockZone
		[1] = 'int32':zoneId
	}
--]]
c2s.UNLOCK_ZONE = 0x441e

--[[
	[1] = {--GetSevenDaysGoalTaskReward
		[1] = 'int32':taskid	[成就id 0代表领取全部奖励]
	}
--]]
c2s.GET_SEVEN_DAYS_GOAL_TASK_REWARD = 0x2052

--[[
	[1] = {--QueryRecallInviteList
	}
--]]
c2s.QUERY_RECALL_INVITE_LIST = 0x5322

--[[
	[1] = {--ReportPlayerRequest
		[1] = 'int32':targetId	[目标玩家ID]
		[2] = 'int32':type	[操作类型]
	}
--]]
c2s.REPORT_PLAYER_REQUEST = 0x7f31

--[[
	[1] = {--RequestEquipMartial
		[1] = 'int64':roleId	[角色id]
		[2] = 'int32':martialId	[武学id]
		[3] = 'int32':position	[武学装备位置]
		[4] = 'bool':autoSynthesis	[是否自动合成,只有在没有该武学,但是又拥有足够材料的情况下才为true,可以节省用户合成所需要的操作,由客户端进行智能验证填写,如果客户端不支持智能校验则填写为false]
	}
--]]
c2s.REQUEST_EQUIP_MARTIAL = 0x3401

--[[
	[1] = {--QueryDiscountShopItem
	}
--]]
c2s.QUERY_DISCOUNT_SHOP_ITEM = 0x2060

--[[
	[1] = {--GuardRecordList
		[1] = 'int32':curCount	[当前数量]
	}
--]]
c2s.GUARD_RECORD_LIST = 0x5006

--[[
	[1] = {--GangGetStaticInfo
	}
--]]
c2s.GANG_GET_STATIC_INFO = 0x1801

--[[
	[1] = {--PurchaseOrderForRandomStore
		[1] = 'int32':type	[商店类型]
		[2] = 'int32':commodityId	[购买商品的id]
		[3] = 'int32':num	[购买商品的个数]
	}
--]]
c2s.PURCHASE_ORDER_FOR_RANDOM_STORE = 0x1905

--[[
	[1] = {--GainGuildMember
	}
--]]
c2s.GAIN_GUILD_MEMBER = 0x4407

--[[
	[1] = {--QueryRecallTask
	}
--]]
c2s.QUERY_RECALL_TASK = 0x5300

--[[
	[1] = {--OpenTreasureBox
		[1] = 'int32':index	[开启的宝箱索引,1----n]
	}
--]]
c2s.OPEN_TREASURE_BOX = 0x2205

--[[
	[1] = {--UnUseProtagonistSkill
		[1] = 'int32':pos	[技能的位置]
	}
--]]
c2s.UN_USE_PROTAGONIST_SKILL = 0x1f07

--[[
	[1] = {--UseProtagonistSkill
		[1] = 'int32':skillId	[技能的id]
		[2] = 'int32':pos	[技能的位置]
	}
--]]
c2s.USE_PROTAGONIST_SKILL = 0x1f06

--[[
	[1] = {--GainPrivateChatListRequster
	}
--]]
c2s.GAIN_PRIVATE_CHAT_LIST_REQUSTER = 0x1b05

--[[
	[1] = {--GuildZoneInfo
	}
--]]
c2s.GUILD_ZONE_INFO = 0x441a

--[[
	[1] = {--RequestResetWaitTime
		[1] = 'int32':type	[1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点    //1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点]
	}
--]]
c2s.REQUEST_RESET_WAIT_TIME = 0x2105

--[[
	[1] = {--RequestBibleBreachRequest
		[1] = 'int64':instanceId	[天书实例ID]
	}
--]]
c2s.REQUEST_BIBLE_BREACH_REQUEST = 0x6006

--[[
	[1] = {--AgreedApply
		[1] = 'int32':playerId
	}
--]]
c2s.AGREED_APPLY = 0x4403

--[[
	[1] = {--GetReward
		[1] = 'int32':indexId	[卡槽位置id]
	}
--]]
c2s.GET_REWARD = 0x5402

--[[
	[1] = {--BuyContract
		[1] = 'int32':id	[契约合同ID]
	}
--]]
c2s.BUY_CONTRACT = 0x2801

--[[
	[1] = {--GetSignRequest
	}
--]]
c2s.GET_SIGN_REQUEST = 0x2701

--[[
	[1] = {--SignRequest
	}
--]]
c2s.SIGN_REQUEST = 0x2702

--[[
	[1] = {--GetRandomStore
		[1] = 'int32':type	[随机商店类型,为了兼容多种随机商店]
	}
--]]
c2s.GET_RANDOM_STORE = 0x1902

--[[
	[1] = {--getEscortingReward
	}
--]]
c2s.GET_ESCORTING_REWARD = 0x2903

--[[
	[1] = {--OneKeyMergeGoodsMsg
		[1] = 'int32':type	[物品类型,0.全部;1.秘籍.武学碎片;2.装备碎片]
	}
--]]
c2s.ONE_KEY_MERGE_GOODS = 0x1065

--[[
	[1] = {--ApplyRecallInviteCode
		[1] = 'string':inviteCode	[邀请码]
	}
--]]
c2s.APPLY_RECALL_INVITE_CODE = 0x5323

--[[
	[1] = {--TreasureHuntHistoryList
		[1] = 'int32':curCount	[当前数量]
		[2] = 'int32':count	[拉取数量]
		[3] = 'int32':type	[1个人历史2玩家历史]
	}
--]]
c2s.TREASURE_HUNT_HISTORY_LIST = 0x6302

--[[
	[1] = {--ExpTransferMsg
		[1] = 'int64':fromId	[被传承角色实例id]
		[2] = 'int64':targetId	[传陈角色实例id]
		[3] = 'int32':type	[1 初级传承 2 中级 3 高级]
	}
--]]
c2s.EXP_TRANSFER = 0x1503

--[[
	[1] = {--UnlockMine
	}
--]]
c2s.UNLOCK_MINE = 0x5004

--[[
	[1] = {--GoldEggResult
		[1] = 'int32':type	[1金蛋2银蛋]
		[2] = 'int32':count	[砸蛋次数]
	}
--]]
c2s.GOLD_EGG_RESULT = 0x4702

--[[
	[1] = {--LockedZone
		[1] = 'int32':zoneId
	}
--]]
c2s.LOCKED_ZONE = 0x441d

--[[
	[1] = {--RequestBuyCoin
	}
--]]
c2s.REQUEST_BUY_COIN = 0x1920

--[[
	[1] = {--GetVipRewardList
	}
--]]
c2s.GET_VIP_REWARD_LIST = 0x1a05

--[[
	[1] = {--AutoMergeGemRequest
		[1] = 'int32':maxLevel	[最高自动合成到什么等级]
	}
--]]
c2s.AUTO_MERGE_GEM_REQUEST = 0x1056

--[[
	[1] = {--uesInvocatoryGoods
		[1] = 'int32':roleId	[祈愿的侠客模板id]
	}
--]]
c2s.UES_INVOCATORY_GOODS = 0x5404

--[[
	[1] = {--ResetChallengeTimes
		[1] = 'int32':battleType	[1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点    //1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点]
	}
--]]
c2s.RESET_CHALLENGE_TIMES = 0x2104

--[[
	[1] = {--RandomMallWish
		[1] = 'int32':commodityId	[许愿商品的id]
	}
--]]
c2s.RANDOM_MALL_WISH = 0x1910

--[[
	[1] = {--SettingSaveConfig
		[1] = 'bool':isOpenMusic	[是否打开音乐 true or flase]
		[2] = 'bool':isOpenVolume	[是否打开音效 true or flase]
		[3] = 'bool':isOpenChat	[是否打开聊天 true or flase]
		[4] = 'bool':vipVisible	[是否显示VIP]
	}
--]]
c2s.SETTING_SAVE_CONFIG = 0x1e01

--[[
	[1] = {--SettingGetConfig
	}
--]]
c2s.SETTING_GET_CONFIG = 0x1e00

--[[
	[1] = {--RoleBreakthrough
		[1] = 'int64':userid	[角色实例id]
	}
--]]
c2s.ROLE_BREAKTHROUGH = 0x1505

--[[
	[1] = {--RequestAcupointBreachRate
	}
--]]
c2s.REQUEST_ACUPOINT_BREACH_RATE = 0x150b

--[[
	[1] = {--RequestPick
	}
--]]
c2s.REQUEST_PICK = 0x5802

--[[
	[1] = {--RoleStarUp
		[1] = 'int64':userid	[角色实例id]
		[2] = 'repeated int64':dogfoodlist	[消耗角色实例id]
		[3] = {--repeated RoleSoulInfo
			[1] = 'int32':id	[角色的id]
			[2] = 'int32':num	[角色魂魄的数量]
		},
	}
--]]
c2s.ROLE_STAR_UP = 0x1504

--[[
	[1] = {--OpenBox
		[1] = 'int32':type	[类型]
	}
--]]
c2s.OPEN_BOX = 0x4508

--[[
	[1] = {--SpellLevelUpRequest
		[1] = 'int64':userid	[目标角色的实例ID]
		[2] = 'int32':spellId	[技能ID,对应技能当前等级的唯一ID.为t_s_spell_level表格主键]
	}
--]]
c2s.SPELL_LEVEL_UP_REQUEST = 0x1520

--[[
	[1] = {--ChallengeGuildCheckpoint
		[1] = 'int32':zoneId
		[2] = 'int32':checkpointId
		[3] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_GUILD_CHECKPOINT = 0x441f

--[[
	[1] = {--GangGetBuff
	}
--]]
c2s.GANG_GET_BUFF = 0x1817

--[[
	[1] = {--RequestSetFuncState
		[1] = {--repeated FunctionState
			[1] = 'int32':functionId	[功能ID,客户端定义,服务器只做存储,无任何逻辑需求]
			[2] = 'bool':newMark	[状态标记,true:新状态,false:无]
		},
	}
--]]
c2s.REQUEST_SET_FUNC_STATE = 0x7f21

--[[
	[1] = {--CheckJoin
	}
--]]
c2s.CHECK_JOIN = 0x4510

--[[
	[1] = {--GangCancelAppointSecondMaster
		[1] = 'int32':playerId
	}
--]]
c2s.GANG_CANCEL_APPOINT_SECOND_MASTER = 0x180e

--[[
	[1] = {--SelectAttrAddMsg
		[1] = 'int32':attr	[ 1 血量加成, 2 内功加成, 3 外功加成, 4 内防加成, 5 外防加成 6 冰火毒伤加成]
	}
--]]
c2s.SELECT_ATTR_ADD = 0x1401

--[[
	[1] = {--GangGetMemberList
	}
--]]
c2s.GANG_GET_MEMBER_LIST = 0x1803

--[[
	[1] = {--RoleHermit
		[1] = 'repeated int64':dogfoodlist	[消耗角色实例id]
		[2] = {--repeated RoleSoulInfo
			[1] = 'int32':id	[角色的id]
			[2] = 'int32':num	[角色魂魄的数量]
		},
		[3] = 'bool':force	[是否强制归隐]
	}
--]]
c2s.ROLE_HERMIT = 0x1510

--[[
	[1] = {--RequestAcupointBreach
		[1] = 'int64':instanceId
		[2] = 'int32':pos	[穴位位置]
	}
--]]
c2s.REQUEST_ACUPOINT_BREACH = 0x150a

--[[
	[1] = {--GuildPracticeInfo
	}
--]]
c2s.GUILD_PRACTICE_INFO = 0x4422

--[[
	[1] = {--RequestOneKeyEquipMartial
		[1] = 'int64':instanceId	[角色实例ID]
	}
--]]
c2s.REQUEST_ONE_KEY_EQUIP_MARTIAL = 0x3410

--[[
	[1] = {--ArenaReceiveReward
	}
--]]
c2s.ARENA_RECEIVE_REWARD = 0x1303

--[[
	[1] = {--RefreshYabiao
	}
--]]
c2s.REFRESH_YABIAO = 0x3001

--[[
	[1] = {--EquipmentBuild
		[1] = 'int32':forgingId	[图谱id]
	}
--]]
c2s.EQUIPMENT_BUILD = 0x1013

--[[
	[1] = {--CallMasterMsg
	}
--]]
c2s.CALL_MASTER = 0x1604

--[[
	[1] = {--RequestMatchFate
		[1] = 'int64':instanceId	[角色实例ID]
		[2] = 'int32':roleFateId	[角色缘分id]
		[3] = 'int32':goodsId	[道具id]
		[4] = 'int32':goodsNum	[道具使用个数]
	}
--]]
c2s.REQUEST_MATCH_FATE = 0x5601

--[[
	[1] = {--GainGuildApply
	}
--]]
c2s.GAIN_GUILD_APPLY = 0x440a

--[[
	[1] = {--ItemSell
		[1] = 'int32':itemId	[id]
		[2] = 'int32':num	[num]
	}
--]]
c2s.ITEM_SELL = 0x1017

--[[
	[1] = {--QueryRewardRequest
		[1] = 'int32':type	[0:未知或者普通情况下显示提示的类型;1.豪杰榜;2铜人阵;3.天罡星等----]
	}
--]]
c2s.QUERY_REWARD_REQUEST = 0x7f01

--[[
	[1] = {--ArenaGetTopPlayerList
	}
--]]
c2s.ARENA_GET_TOP_PLAYER_LIST = 0x1306

--[[
	[1] = {--RequestMercenaryTeamListOutline
		[1] = 'int32':startIndex	[起始索引]
		[2] = 'int32':length	[单次请求数据条目的数量]
	}
--]]
c2s.REQUEST_MERCENARY_TEAM_LIST_OUTLINE = 0x5150

--[[
	[1] = {--OperateGuild
		[1] = 'int32':type	[ 1 禅让 2 提升为副帮主 3降级为成员 4请离 5弹劾 6解散 7 取消解散 8升级工会 9取消禅让 10取消弹劾]
		[2] = 'int32':playerId
	}
--]]
c2s.OPERATE_GUILD = 0x4409

--[[
	[1] = {--QueryRankingBaseInfo
		[1] = 'int32':type	[排行榜类型]
		[2] = 'int32':startIndex	[开始索引,0~N]
		[3] = 'int32':length	[获取信息长度]
		[4] = 'int32':guildZoneType	[公会副本类型 1查看副本通关时间 2查看副本伤害]
		[5] = 'int32':guildZoneId	[公会副本编号]
		[6] = 'int32':guildCheckpoint	[公会关卡编号]
	}
--]]
c2s.QUERY_RANKING_BASE_INFO = 0x4050

--[[
	[1] = {--RequestPraise
		[1] = 'int32':targetId	[目标玩家ID]
	}
--]]
c2s.REQUEST_PRAISE = 0x4060

--[[
	[1] = {--FactionSwithRequest
	}
--]]
c2s.FACTION_SWITH_REQUEST = 0x2503

--[[
	[1] = {--GetDiningRequest
	}
--]]
c2s.GET_DINING_REQUEST = 0x2501

--[[
	[1] = {--QimenInjectMsg
	}
--]]
c2s.QIMEN_INJECT = 0x5201

--[[
	[1] = {--NorthCaveSweepRequest
		[1] = 'int32':length	[层数,0表示扫荡到最高的3星通关层数]
	}
--]]
c2s.NORTH_CAVE_SWEEP_REQUEST = 0x4910

--[[
	[1] = {--EquipLevelUp
		[1] = 'int64':userId	[装备实例id]
		[2] = 'int32':ratioItemId	[概率加成工具(炼器宝典)    //概率加成工具(炼器宝典)]
	}
--]]
c2s.EQUIP_LEVEL_UP = 0x1054

--[[
	[1] = {--FreshEggRank
	}
--]]
c2s.FRESH_EGG_RANK = 0x4704

--[[
	[1] = {--ApplyGuild
		[1] = 'repeated int32':guildIds
	}
--]]
c2s.APPLY_GUILD = 0x4402

--[[
	[1] = {--SelectSpellRequest
		[1] = 'int32':spellId	[技能等级ID,选择的技能ID]
	}
--]]
c2s.SELECT_SPELL_REQUEST = 0x0e0c

--[[
	[1] = {--Mine
		[1] = 'int32':id	[1,挖矿1,2,挖矿2]
		[2] = 'int32':friendId	[护矿玩家id]
	}
--]]
c2s.MINE = 0x5002

--[[
	[1] = {--GetNorthCaveDetails
	}
--]]
c2s.GET_NORTH_CAVE_DETAILS = 0x4902

--[[
	[1] = {--UpdateGuildBanner
		[1] = 'string':bannerId	[旗帜id]
	}
--]]
c2s.UPDATE_GUILD_BANNER = 0x4429

--[[
	[1] = {--ChatMsg
		[1] = 'int32':chatType	[ 聊天类型;1.公共,2.帮派;3.GM;4.私聊]
		[2] = 'string':content	[消息;]
		[3] = 'string':playerName	[私聊对象的name]
		[4] = 'int32':playerId	[私聊玩家编号]
	}
--]]
c2s.CHAT = 0x1b01

--[[
	[1] = {--RequestResetNorthCave
	}
--]]
c2s.REQUEST_RESET_NORTH_CAVE = 0x4900

--[[
	[1] = {--RequestClearYabiaoCD
	}
--]]
c2s.REQUEST_CLEAR_YABIAO_CD = 0x3004

--[[
	[1] = {--MHYSweepRequest
		[1] = 'int32':id	[目标关卡ID]
		[2] = 'int32':count	[扫荡次数]
	}
--]]
c2s.MHYSWEEP_REQUEST = 0x1720

--[[
	[1] = {--EndPractice
		[1] = 'int32':pos
		[2] = 'bool':finish
	}
--]]
c2s.END_PRACTICE = 0x4425

--[[
	[1] = {--QueryYabiao
	}
--]]
c2s.QUERY_YABIAO = 0x3000

--[[
	[1] = {--SingleSweepSection
		[1] = 'int32':missionId	[关卡Id]
	}
--]]
c2s.SINGLE_SWEEP_SECTION = 0x1204

--[[
	[1] = {--OpenChapterBoxRequest
		[1] = 'int32':chapterId	[章节ID]
		[2] = 'int32':difficulty	[难度]
		[3] = 'int32':boxId	[奖励的宝箱id,对应t_s_stage_box表格中的id字段.此字段为了兼容一个关卡多个宝箱的需求]
	}
--]]
c2s.OPEN_CHAPTER_BOX_REQUEST = 0x1202

--[[
	[1] = {--GainPreviousCrossInfo
	}
--]]
c2s.GAIN_PREVIOUS_CROSS_INFO = 0x4520

--[[
	[1] = {--UnlockPlayerMine
		[1] = 'int32':minePlayerId	[被劫矿的玩家]
		[2] = 'int32':id	[1,矿1,2,矿2]
	}
--]]
c2s.UNLOCK_PLAYER_MINE = 0x500a

--[[
	[1] = {--ApplyReturnGift
	}
--]]
c2s.APPLY_RETURN_GIFT = 0x5324

--[[
	[1] = {--ChallengeMine
		[1] = 'int32':playerId	[打劫的玩家]
		[2] = 'int32':type	[打劫的矿洞]
		[3] = 'int32':challengeIndex	[打劫的所有 1挖矿的人 2 护矿的人]
	}
--]]
c2s.CHALLENGE_MINE = 0x500c

--[[
	[1] = {--GuardMine
		[1] = 'int32':friendId	[护矿好友id]
		[2] = 'int32':id	[1,矿1,2,矿2]
	}
--]]
c2s.GUARD_MINE = 0x5008

--[[
	[1] = {--BuyChallengeTimes
		[1] = 'int32':battleType	[1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点    //1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点]
		[2] = 'int32':times	[购买次数]
	}
--]]
c2s.BUY_CHALLENGE_TIMES = 0x2103

--[[
	[1] = {--GetBrokerage
	}
--]]
c2s.GET_BROKERAGE = 0x5005

--[[
	[1] = {--StudyProtagonistSkill
		[1] = 'int32':skillId	[技能的id]
	}
--]]
c2s.STUDY_PROTAGONIST_SKILL = 0x1f02

--[[
	[1] = {--GetVipReward
		[1] = 'int32':id	[vipID]
	}
--]]
c2s.GET_VIP_REWARD = 0x1a06

--[[
	[1] = {--QueryMyMercenaryTeam
	}
--]]
c2s.QUERY_MY_MERCENARY_TEAM = 0x5152

--[[
	[1] = {--RequestPickup
		[1] = 'int32':index	[拾取的目标索引,0表示全部拾取]
	}
--]]
c2s.REQUEST_PICKUP = 0x5803

--[[
	[1] = {--PlayArenaTopBattleReport
		[1] = 'int32':reportId	[战报ID]
	}
--]]
c2s.PLAY_ARENA_TOP_BATTLE_REPORT = 0x1d41

--[[
	[1] = {--EssentialMosaicRequest
		[1] = 'int64':bible	[镶嵌的天书id]
		[2] = 'int32':essential	[精要id]
		[3] = 'int32':pos	[镶嵌的位置]
	}
--]]
c2s.ESSENTIAL_MOSAIC_REQUEST = 0x6004

--[[
	[1] = {--QueryGuildBattleWarInfos
	}
--]]
c2s.QUERY_GUILD_BATTLE_WAR_INFOS = 0x5704

--[[
	[1] = {--GuardMinePlayer
	}
--]]
c2s.GUARD_MINE_PLAYER = 0x5010

--[[
	[1] = {--QueryEmployRoleCount
	}
--]]
c2s.QUERY_EMPLOY_ROLE_COUNT = 0x5110

--[[
	[1] = {--QueryArenaTopBattleReport
	}
--]]
c2s.QUERY_ARENA_TOP_BATTLE_REPORT = 0x1d40

--[[
	[1] = {--ChallengeClimbWanneng
		[1] = 'int32':id	[副本索引]
		[2] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.CHALLENGE_CLIMB_WANNENG = 0x1705

--[[
	[1] = {--QueryRecruitIntegralOutlineRank
	}
--]]
c2s.QUERY_RECRUIT_INTEGRAL_OUTLINE_RANK = 0x4011

--[[
	[1] = {--QueryGuildBattleReplayInfos
		[1] = 'int32':round
		[2] = 'int32':index
	}
--]]
c2s.QUERY_GUILD_BATTLE_REPLAY_INFOS = 0x5705

--[[
	[1] = {--BibleResetRequest
		[1] = 'int64':instanceId	[id]
	}
--]]
c2s.BIBLE_RESET_REQUEST = 0x6008

--[[
	[1] = {--UpdateEmployFormation
		[1] = 'int32':type	[阵形类型,9.推图阵形]
		[2] = {--repeated MercenaryRoleInfo
			[1] = 'int64':instanceId	[角色实例ID]
			[2] = 'int32':position	[位置,0~8]
		},
		[3] = {--repeated MercenaryRoleInfo
			[1] = 'int64':instanceId	[角色实例ID]
			[2] = 'int32':position	[位置,0~8]
		},
	}
--]]
c2s.UPDATE_EMPLOY_FORMATION = 0x5130

--[[
	[1] = {--QueryCrossChampionsInfos
	}
--]]
c2s.QUERY_CROSS_CHAMPIONS_INFOS = 0x4515

--[[
	[1] = {--QueryFightNotify
		[1] = 'bool':unread	[是否请求未读消息.如果是则只返回未读消息,否则返回全部消息]
	}
--]]
c2s.QUERY_FIGHT_NOTIFY = 0x1d06

--[[
	[1] = {--ArenaGetPlayerList
	}
--]]
c2s.ARENA_GET_PLAYER_LIST = 0x1300

--[[
	[1] = {--QuerySystemNotify
		[1] = 'bool':unread	[是否请求未读消息.如果是则只返回未读消息,否则返回全部消息]
	}
--]]
c2s.QUERY_SYSTEM_NOTIFY = 0x1d08

--[[
	[1] = {--GainChampions
	}
--]]
c2s.GAIN_CHAMPIONS = 0x4501

--[[
	[1] = {--ErrorReport
		[1] = 'string':errorMessage	[错误消息]
	}
--]]
c2s.ERROR_REPORT = 0x7ffe

--[[
	[1] = {--BloodyChangeStation
		[1] = 'int32':fromIndex	[原来的战阵索引]
		[2] = 'int32':targetIndex	[新的战阵索引]
	}
--]]
c2s.BLOODY_CHANGE_STATION = 0x3202

--[[
	[1] = {--ModifyEmployTeamFormation
		[1] = 'int32':playerId	[目标玩家ID]
		[2] = 'int32':useType	[使用类型]
		[3] = {--repeated MercenaryRoleInfo
			[1] = 'int64':instanceId	[角色实例ID]
			[2] = 'int32':position	[位置,0~8]
		},
	}
--]]
c2s.MODIFY_EMPLOY_TEAM_FORMATION = 0x5162

--[[
	[1] = {--RoleTransfer
		[1] = 'int64':userid	[角色实例id]
		[2] = 'repeated int64':dogfoodlist	[消耗角色实例id]
		[3] = {--repeated RoleSoulInfo
			[1] = 'int32':id	[角色的id]
			[2] = 'int32':num	[角色魂魄的数量]
		},
	}
--]]
c2s.ROLE_TRANSFER = 0x1508

--[[
	[1] = {--RequestMartialLevelUp
		[1] = 'int64':roleId	[角色id]
	}
--]]
c2s.REQUEST_MARTIAL_LEVEL_UP = 0x3403

--[[
	[1] = {--RequestAcupointLevelUp
		[1] = 'int64':instanceId
		[2] = 'int32':pos	[穴位位置]
	}
--]]
c2s.REQUEST_ACUPOINT_LEVEL_UP = 0x1502

--[[
	[1] = {--QueryRank
		[1] = 'int32':startIndex	[起始索引,1开始;0表示请求玩家所在哪一页]
		[2] = 'int32':length	[获取的数据条目数量]
	}
--]]
c2s.QUERY_RANK = 0x1404

--[[
	[1] = {--LoginMsg
		[1] = 'string':accountId	[帐号id]
		[2] = 'string':validateCode	[登录完成后获得的校验码]
		[3] = 'int32':serverId	[服务器唯一标识]
		[4] = 'string':token	[设备token]
		[5] = 'string':deviceName	[设备名称]
		[6] = 'string':osName	[设备系统名称]
		[7] = 'string':osVersion	[设备系统版本]
		[8] = 'string':channel	[渠道]
		[9] = 'string':sdk	[第三方接入类型.如:PP.91等]
		[10] = 'string':deviceid	[设备ID唯一标识]
		[11] = 'string':sdkVersion	[SDK版本]
		[12] = 'string':MCC	[移动设备国家码]
		[13] = 'string':IP	[联网IP地址]
	}
--]]
c2s.LOGIN = 0x0d00

--[[
	[1] = {--Encouraging
	}
--]]
c2s.ENCOURAGING = 0x4504

--[[
	[1] = {--EquipmentIntensifyToTop
		[1] = 'int64':equipment	[装备userid]
	}
--]]
c2s.EQUIPMENT_INTENSIFY_TO_TOP = 0x1022

--[[
	[1] = {--QueryNextRecoverTime
		[1] = 'int32':battleType	[1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点    //1-推图体力;2-群豪谱体力;3-爬塔体力; 4-江湖宝藏体力; 5-技能点]
	}
--]]
c2s.QUERY_NEXT_RECOVER_TIME = 0x2102

--[[
	[1] = {--EquipmentRecast
		[1] = 'int64':equipmentId
		[2] = 'bool':lock
		[3] = 'int64':recastEquipmentId
		[4] = 'int32':index
	}
--]]
c2s.EQUIPMENT_RECAST = 0x1082

--[[
	[1] = {--UpdateFormation
		[1] = 'int32':type	[类型 0进攻  1防守]
		[2] = 'repeated int64':formations	[阵容]
	}
--]]
c2s.UPDATE_FORMATION = 0x4505

--[[
	[1] = {--QueryEmployTeamList
	}
--]]
c2s.QUERY_EMPLOY_TEAM_LIST = 0x5163

--[[
	[1] = {--HeadPicFrameOpen
	}
--]]
c2s.HEAD_PIC_FRAME_OPEN = 0x0e95

--[[
	[1] = {--UnlockEquipmentHole
		[1] = 'int64':equipment	[解锁的装备id]
	}
--]]
c2s.UNLOCK_EQUIPMENT_HOLE = 0x1053

--[[
	[1] = {--GemUnMosaic
		[1] = 'int64':equipment	[卸下的装备id]
		[2] = 'int32':pos	[卸下的位置]
	}
--]]
c2s.GEM_UN_MOSAIC = 0x1052

--[[
	[1] = {--AdventureChallenge
		[1] = 'int32':id	[ 副本的ID]
	}
--]]
c2s.ADVENTURE_CHALLENGE = 0x5901

--[[
	[1] = {--AdventureEnemy
	}
--]]
c2s.ADVENTURE_ENEMY = 0x5905

--[[
	[1] = {--QueryGetRoleMsg
	}
--]]
c2s.QUERY_GET_ROLE = 0x1c00

--[[
	[1] = {--QueryContract
	}
--]]
c2s.QUERY_CONTRACT = 0x2800

--[[
	[1] = {--OneKeyEquip
		[1] = 'int64':roleId	[目标角色的实例ID.即对那个角色使用一键穿装]
	}
--]]
c2s.ONE_KEY_EQUIP = 0x101e

--[[
	[1] = {--GetCardRoleMsg
		[1] = 'int32':cardType	[ 1 最高得乙, 2 最高得甲, 3 连抽十次]
		[2] = 'bool':free	[ 是否免费]
	}
--]]
c2s.GET_CARD_ROLE = 0x1c01

--[[
	[1] = {--ClimbSweepRequest
		[1] = 'int32':id	[层数]
		[2] = 'int32':times	[扫荡次数]
	}
--]]
c2s.CLIMB_SWEEP_REQUEST = 0x1710

--[[
	[1] = {--UpdateProvide
		[1] = 'repeated int64':ids
	}
--]]
c2s.UPDATE_PROVIDE = 0x430f

--[[
	[1] = {--QueryOpenServiceActivityRewardRecord
	}
--]]
c2s.QUERY_OPEN_SERVICE_ACTIVITY_REWARD_RECORD = 0x3302

--[[
	[1] = {--Match
	}
--]]
c2s.MATCH = 0x4502

--[[
	[1] = {--FirstOnlinePromptRequest
	}
--]]
c2s.FIRST_ONLINE_PROMPT_REQUEST = 0x0e34

--[[
	[1] = {--EquipmentSell
		[1] = 'repeated int64':equipment	[装备userid]
	}
--]]
c2s.EQUIPMENT_SELL = 0x1015

--[[
	[1] = {--FightEndRequest
		[1] = 'int32':fighttype	[战斗类型.1:推图;2:铜人阵;3:豪杰榜;4:天罡星;5:无量山;6:大宝藏;7:护驾]
		[2] = 'bool':win	[战斗是否在客户端判断为胜利]
		[3] = {--repeated FightAction
			[1] = 'bool':bManualAction	[是否主动技能]
			[2] = 'int32':roundIndex	[当前回合]
			[3] = 'int32':attackerpos	[攻击者位置]
			[4] = 'int32':skillid	[技能id]
			[5] = 'int32':skillLevel	[技能id]
			[6] = 'bool':bBackAttack	[是否反击]
			[7] = {--repeated TargetInfo
				[1] = 'int32':targetpos	[受击者位置]
				[2] = 'int32':effect	[受击效果]
				[3] = 'int32':hurt	[受击伤害]
				[4] = 'int32':triggerBufferID	[触发bufferID]
				[5] = 'int32':triggerBufferLevel	[触发bufferID]
				[6] = 'int32':passiveEffect	[被动效果类型]
				[7] = 'int32':passiveEffectValue	[被动效果值]
				[8] = 'int32':activeEffect	[主动效果类型]
				[9] = 'int32':activeEffectValue	[主动效果值]
			},
			[8] = {--repeated StateInfo
				[1] = 'int32':frompos	[状态产生自谁行为发起者还是目标]
				[2] = 'int32':targetpos	[获得状态的目标]
				[3] = 'int32':stateId	[触发的状态ID,触发了哪个状态.始终是frompos对应角色身上的状态列表中的状态]
				[4] = 'int32':skillId	[状态时由哪个技能触发的.始终是frompos对应角色身上的技能]
				[5] = 'int32':skillLevel	[技能id]
				[6] = 'int32':bufferId	[targetpos的角色获得的状态ID]
				[7] = 'int32':bufferLevel	[技能id]
			},
			[9] = 'int32':triggerType	[触发技能类型87]
		},
		[4] = {--repeated LiveRole
			[1] = 'int32':posindex	[位置]
			[2] = 'int32':currhp	[剩余血量]
		},
		[5] = 'int32':angerSelf	[己方怒气]
		[6] = 'int32':angerEnemy	[对方怒气]
		[7] = {--repeated RoleHurtCount
			[1] = 'int32':posindex	[位置]
			[2] = 'int32':hurt	[伤害计算]
		},
	}
--]]
c2s.FIGHT_END_REQUEST = 0x0f02

--[[
	[1] = {--EquipmentIntensify
		[1] = 'int64':equipment	[装备userid]
	}
--]]
c2s.EQUIPMENT_INTENSIFY = 0x1014

--[[
	[1] = {--GetBloodyBox
		[1] = 'int32':section	[关卡号(从1开始)    //关卡号(从1开始)]
		[2] = 'int32':index	[宝箱索引(从1开始)    //宝箱索引(从1开始)]
		[3] = 'int32':getType	[1:免费领取 2:购买]
	}
--]]
c2s.GET_BLOODY_BOX = 0x3214

--[[
	[1] = {--EquipmentTranslateRequest
		[1] = 'int64':srcId	[源装备实例ID]
		[2] = 'int64':targetId	[目标装备实例ID]
	}
--]]
c2s.EQUIPMENT_TRANSLATE_REQUEST = 0x1090

--[[
	[1] = {--GangUpLevelExchange
	}
--]]
c2s.GANG_UP_LEVEL_EXCHANGE = 0x1814

--[[
	[1] = {--MerceanryTeamOperation
		[1] = 'int32':operation	[操作符,1.领取;2.归队]
	}
--]]
c2s.MERCEANRY_TEAM_OPERATION = 0x5153

--[[
	[1] = {--SellBookMsg
		[1] = 'int32':bookpos
	}
--]]
c2s.SELL_BOOK = 0x1603

--[[
	[1] = {--SendGuildMail
		[1] = 'string':title	[標題]
		[2] = 'string':content	[內容]
	}
--]]
c2s.SEND_GUILD_MAIL = 0x4432

--[[
	[1] = {--CheckBoxUsed
		[1] = 'int32':itemId	[id]
		[2] = 'repeated int32':indexId	[选中道具位置id]
	}
--]]
c2s.CHECK_BOX_USED = 0x1030

--[[
	[1] = {--ResetBloodyRequest
	}
--]]
c2s.RESET_BLOODY_REQUEST = 0x3220

--[[
	[1] = {--RequestBuyMoneyShop
		[1] = 'int32':type	[通宝类型]
		[2] = 'int32':activityId	[活动Id]
	}
--]]
c2s.REQUEST_BUY_MONEY_SHOP = 0x2305

--[[
	[1] = {--GuildStatInfo
	}
--]]
c2s.GUILD_STAT_INFO = 0x440c

--[[
	[1] = {--GotActivityReward
		[1] = 'int32':id	[活动ID]
		[2] = 'int32':index	[奖励索引,从1开始,第几个奖励]
	}
--]]
c2s.GOT_ACTIVITY_REWARD = 0x2304

--[[
	[1] = {--MakePlayer
		[1] = 'int32':type	[类型]
		[2] = 'int32':playerId	[结交的玩家编号]
	}
--]]
c2s.MAKE_PLAYER = 0x440f

--[[
	[1] = {--GangExpelMember
		[1] = 'int32':playerId
	}
--]]
c2s.GANG_EXPEL_MEMBER = 0x1807

--[[
	[1] = {--RequestOneKeyEnchant
		[1] = 'int64':roleId	[角色id]
		[2] = 'int32':position	[武学装备位置]
	}
--]]
c2s.REQUEST_ONE_KEY_ENCHANT = 0x3407

--[[
	[1] = {--AdventureBattleLog
	}
--]]
c2s.ADVENTURE_BATTLE_LOG = 0x5909

--[[
	[1] = {--FreshTreasureHuntRank
	}
--]]
c2s.FRESH_TREASURE_HUNT_RANK = 0x6304

--[[
	[1] = {--GetAllRandomStore
	}
--]]
c2s.GET_ALL_RANDOM_STORE = 0x1904

--[[
	[1] = {--GetEquipmentStarUpFail
	}
--]]
c2s.GET_EQUIPMENT_STAR_UP_FAIL = 0x1021

--[[
	[1] = {--ItemUsed
		[1] = 'int32':itemId	[id]
	}
--]]
c2s.ITEM_USED = 0x1018

--[[
	[1] = {--EssentialExplodeRequest
		[1] = {--repeated EssentialExplodeStruct
			[1] = 'int32':itemId	[分解模板id]
			[2] = 'int32':number	[分解的数量]
		},
	}
--]]
c2s.ESSENTIAL_EXPLODE_REQUEST = 0x6007

--[[
	[1] = {--GainMineBattleReport
		[1] = 'int32':id
	}
--]]
c2s.GAIN_MINE_BATTLE_REPORT = 0x500e

--[[
	[1] = {--RequestGetCaveChestReward
		[1] = 'int32':index	[层数,1~N,最后一个属性可以传0]
	}
--]]
c2s.REQUEST_GET_CAVE_CHEST_REWARD = 0x4925

--[[
	[1] = {--GetRewardRequest
		[1] = 'int32':type	[0:未知或者普通情况下显示提示的类型;1.豪杰榜;2铜人阵;3.天罡星等----]
	}
--]]
c2s.GET_REWARD_REQUEST = 0x7f00

--[[
	[1] = {--BloodyInspire
		[1] = 'int32':resType	[鼓舞资源类型]
	}
--]]
c2s.BLOODY_INSPIRE = 0x3215

--[[
	[1] = {--GetSendReward
		[1] = 'int32':id	[奖励配置ID,详情请见t_s_invite_code_reward_config表]
	}
--]]
c2s.GET_SEND_REWARD = 0x2602

--[[
	[1] = {--ExitGuild
	}
--]]
c2s.EXIT_GUILD = 0x4405

--[[
	[1] = {--ArenaGetRandList
		[1] = 'int32':startIndex	[起始索引,1开始;0表示请求玩家所在哪一页]
		[2] = 'int32':length	[获取的数据条目数量]
	}
--]]
c2s.ARENA_GET_RAND_LIST = 0x1301

--[[
	[1] = {--GangUpLevelBuff
	}
--]]
c2s.GANG_UP_LEVEL_BUFF = 0x1818

--[[
	[1] = {--HeadPicFrameRequest
	}
--]]
c2s.HEAD_PIC_FRAME_REQUEST = 0x0e94

--[[
	[1] = {--EquipPractice
		[1] = 'int64':equipment	[装备userid]
		[2] = 'repeated int32':lock_attr	[锁定的属性行]
	}
--]]
c2s.EQUIP_PRACTICE = 0x1023

--[[
	[1] = {--VerifyNewInviteCode
		[1] = 'int32':inviteCode	[需要验证的邀请码]
	}
--]]
c2s.VERIFY_NEW_INVITE_CODE = 0x2605

--[[
	[1] = {--WarMatixConf
		[1] = {--repeated RoleConfigure
			[1] = 'int64':userId
			[2] = 'int32':index
		},
	}
--]]
c2s.WAR_MATIX_CONF = 0x0e20

--[[
	[1] = {--UnapplyGuildBattle
	}
--]]
c2s.UNAPPLY_GUILD_BATTLE = 0x5701

--[[
	[1] = {--UnequipRequest
		[1] = 'int64':roleId	[角色实例id]
		[2] = 'int64':equipment	[装备到身上的装备userid]
	}
--]]
c2s.UNEQUIP_REQUEST = 0x1012

--[[
	[1] = {--QueryGoFight
		[1] = 'int32':gotype	[ 1 血闯, 2 勇闯, 3 力闯]
		[2] = 'int32':employType	[佣兵阵形类型,如果不是使用佣兵为0]
	}
--]]
c2s.QUERY_GO_FIGHT = 0x1403

--[[
	[1] = {--ApplyGuildBattle
		[1] = 'int32':index
	}
--]]
c2s.APPLY_GUILD_BATTLE = 0x5700

--[[
	[1] = {--OpenAssistantGrid
		[1] = 'int32':index	[要开启的格子]
	}
--]]
c2s.OPEN_ASSISTANT_GRID = 0x4602

--[[
	[1] = {--QueryTupuList
	}
--]]
c2s.QUERY_TUPU_LIST = 0x3100

--[[
	[1] = {--GangDissolve
	}
--]]
c2s.GANG_DISSOLVE = 0x180a

--[[
	[1] = {--OperateInvitation
		[1] = 'int32':type	[ 1同意申请 2忽略]
		[2] = 'int32':guildId	[0为全部忽略]
	}
--]]
c2s.OPERATE_INVITATION = 0x4414

--[[
	[1] = {--GangCancelApplyAdd
		[1] = 'int32':gangId
	}
--]]
c2s.GANG_CANCEL_APPLY_ADD = 0x180d

--[[
	[1] = {--LevelUpAgree
		[1] = 'int32':pos
	}
--]]
c2s.LEVEL_UP_AGREE = 0x4604

--[[
	[1] = {--RefreshProtagonistSkill
	}
--]]
c2s.REFRESH_PROTAGONIST_SKILL = 0x1f05

--[[
	[1] = {--QueryEmployTeamCount
	}
--]]
c2s.QUERY_EMPLOY_TEAM_COUNT = 0x5164

--[[
	[1] = {--AdventurePlayerBattle
		[1] = 'int32':type	[ 类型 20.杀戮21.复仇22.挑战排行榜]
		[2] = 'int32':playerId	[ 玩家ID]
	}
--]]
c2s.ADVENTURE_PLAYER_BATTLE = 0x5911

--[[
	[1] = {--ShuffleBloodyBox
		[1] = 'int32':section	[关卡号(从1开始)    //关卡号(从1开始)]
		[2] = 'int32':index	[奖品索引号(客户端:1-6 服务端4-24)    //奖品索引号(客户端:1-6 服务端4-24)]
	}
--]]
c2s.SHUFFLE_BLOODY_BOX = 0x3213

--[[
	[1] = {--QueryAllBloodyEnemySimpleInfoList
	}
--]]
c2s.QUERY_ALL_BLOODY_ENEMY_SIMPLE_INFO_LIST = 0x3207

--[[
	[1] = {--EquipmentExplode
		[1] = 'int64':equipment	[装备userid]
	}
--]]
c2s.EQUIPMENT_EXPLODE = 0x1016

--[[
	[1] = {--UpdateEliteGuildBattle
		[1] = 'int32':index
		[2] = 'int32':playerId
	}
--]]
c2s.UPDATE_ELITE_GUILD_BATTLE = 0x5702

--[[
	[1] = {--GangExchange
		[1] = 'int32':index	[索引]
	}
--]]
c2s.GANG_EXCHANGE = 0x1813

--[[
	[1] = {--GainLastChampion
	}
--]]
c2s.GAIN_LAST_CHAMPION = 0x4513

--[[
	[1] = {--EmploySingleRoleRequest
		[1] = 'int32':playerId	[雇佣的角色属于哪个玩家]
		[2] = 'int64':instanceId	[角色实例ID]
		[3] = 'int32':useType	[使用类型,客户端定义,这里可以是战斗类型]
	}
--]]
c2s.EMPLOY_SINGLE_ROLE_REQUEST = 0x5120

--[[
	[1] = {--QuerySocialNotify
		[1] = 'bool':unread	[是否请求未读消息.如果是则只返回未读消息,否则返回全部消息]
	}
--]]
c2s.QUERY_SOCIAL_NOTIFY = 0x1d07

--[[
	[1] = {--QueryReplayFight
		[1] = 'int32':reportId	[战报ID]
	}
--]]
c2s.QUERY_REPLAY_FIGHT = 0x1d09

--[[
	[1] = {--RequestChangeProfession
		[1] = 'int32':roleId	[角色id]
	}
--]]
c2s.REQUEST_CHANGE_PROFESSION = 0x5500

--[[
	[1] = {--QueryGuildBattleMemberInfo
	}
--]]
c2s.QUERY_GUILD_BATTLE_MEMBER_INFO = 0x5703

--[[
	[1] = {--EggRecordList
		[1] = 'int32':curCount	[当前数量]
		[2] = 'int32':count	[拉取数量]
		[3] = 'int32':type	[1个人历史2玩家历史]
	}
--]]
c2s.EGG_RECORD_LIST = 0x4703

--[[
	[1] = {--GangInviteMember
		[1] = 'int32':playerId
	}
--]]
c2s.GANG_INVITE_MEMBER = 0x1805

--[[
	[1] = {--BloodyToBattle
		[1] = {--C2SBloodyRoleStation
			[1] = 'int64':roleId	[角色ID]
			[2] = 'int32':index	[战阵索引(从0开始,-1表示未上阵)    //战阵索引(从0开始,-1表示未上阵)]
		},
	}
--]]
c2s.BLOODY_TO_BATTLE = 0x3201

--[[
	[1] = {--RequestActivityProgress
		[1] = 'int32':id	[活动ID]
	}
--]]
c2s.REQUEST_ACTIVITY_PROGRESS = 0x2302

--[[
	[1] = {--ChallengeChampions
	}
--]]
c2s.CHALLENGE_CHAMPIONS = 0x4503

--[[
	[1] = {--ClimbGetCarbonList
	}
--]]
c2s.CLIMB_GET_CARBON_LIST = 0x1704

--[[
	[1] = {--ArenaGetRewardInfo
	}
--]]
c2s.ARENA_GET_REWARD_INFO = 0x1302

--[[
	[1] = {--DrawGiveGifi
		[1] = 'int32':friendId
	}
--]]
c2s.DRAW_GIVE_GIFI = 0x4306

--[[
	[1] = {--GainAssistantRole
		[1] = 'int32':friendId
		[2] = 'int32':roleId
	}
--]]
c2s.GAIN_ASSISTANT_ROLE = 0x4310

--[[
	[1] = {--ForgingTheBodyRequest
		[1] = 'int64':roleId	[角色实例id]
		[2] = 'int32':acupoint	[穴位]
	}
--]]
c2s.FORGING_THE_BODY_REQUEST = 0x6600

return c2s