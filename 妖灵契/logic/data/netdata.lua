module(..., package.seeall)

BAN = {
	["print"] = {
		["scene"] = {
			["GS2CSyncPos"] = true,
			["C2GSSyncPos"] = true,
			["GS2CSyncPosQueue"] = true,
			["C2GSSyncPosQueue"] = true,
			["GS2CAutoFindPath"] = true,
		},
		["other"] = {
			["GS2CBigPacket"] = true,
			["C2GSBigPacket"] = true,
			["GS2CMergePacket"] = true,
			["GS2CClientUpdateRes"] = true,
			["GS2CQueryLogin"] = true,
		},
		["login"] = {
			["GS2CQueryLogin"] = true,
		},
	},
	["proto"] = {
		["warend"] = {
			func = function() return g_WarCtrl:IsWar() and not g_WarCtrl:IsPlayRecord() end,
			["scene"] = {
				["GS2CShowScene"] = true,
				["GS2CEnterScene"] = true,
				["GS2CEnterAoiBlock"] = true,
				["GS2CEnterAoiPos"] = true,
				["GS2CLeaveAoi"] = true,
				["GS2CSyncAoi"] = true,
				["GS2CSyncPos"] = true,
				["GS2CAutoFindPath"] = true,
				["GS2CSceneRemoveTeam"] = true,
				["GS2CSceneUpdateTeam"] = true,
				["GS2CSceneCreateTeam"] = true,
			},
			["openui"]	= {
				["GS2CShowItem"] = true,
				["GS2CConfirmUI"] = true,
			},
			["notify"] = {
				["GS2CNotify"] = true,
			},
			["chat"] = {
				["GS2CConsumeMsg"] = true,
			},
			["task"] = {
				["GS2CAddTask"] = true,
				["GS2CRemoveTaskNpc"] = true,
				["GS2CRefreshTask"] = true,
				["GS2CDialog"] = true,
				["GS2CUpdateShimenStatus"] = true,
			},
			["huodong"] = {
				["GS2CSetGuard"] = true,
				["GS2CTerrawarsCountDown"] = true,
				["GS2CTramineOfflineInfo"] = true,
				["GS2CWorldBossDeath"] = true,
				["GS2CGradeGiftInfo"] = true,
			},
			["player"] = {
				["GS2CPropChange"] = true,
			},
			["partner"] = {
				["GS2CPartnerPropChange"] = true,
			},
			["state"] = {
				["GS2CAddState"] = true,
			},

			["npc"] = {
				["GS2CNpcSay"] = true,
			},
		},
		["waring"] = {
			func = function() return g_WarCtrl:IsWar() and not g_WarCtrl:IsPlayRecord() end,
			["org"] = {
				["GS2CLeaveOrgTips"] = true,
			},
			["huodong"] = {
				["GS2CSetGuard"] = true,
				["GS2CTerrawarsCountDown"] = true,
				["GS2CTramineOfflineInfo"] = true,
				["GS2CUpdateShimenStatus"] = true,
				["GS2CWorldBossDeath"] = true,
			},
		},
		["loginend"] = {
			["npc"] = {
				["GS2CNpcSay"] = true,
			},
			["task"] = {
				["GS2CDialog"] = true,
			},			
		},
		["dialogueani"] = {
			["task"] = {
				["GS2CAddTask"] = true,
				["GS2CRemoveTaskNpc"] = true,
				["GS2CRefreshTask"] = true,
				["GS2CDialog"] = true,
			},	
			["openui"] = {
				["GS2CConfirmUI"] = true,
				["GS2CShowItem"] = true,
			},
			["achieve"] = {
				["GS2CAchieveDone"] = true,
			},
			["item"] = {
				["GS2CAddItem"] = true,
			},
		},
		["treasure"] = {
			["notify"] = {
				["GS2CNotify"] = true,
			},
			["openui"] =	{
				["GS2CShowItem"] = true,
				["GS2CConfirmUI"] = true,
			},
			["item"] = {
				["GS2CClientShowReward"] = true,
			},
			["chat"] = {
				["GS2CSysChat"] = true,
			},
			["achieve"] = {
				["GS2CAchieveDone"] = true,
			},
		},
		["herobox"] = {
			["notify"] = {
				["GS2CNotify"] = true,
			},
			["openui"] =	{
				["GS2CShowItem"] = true,
			},
			["item"] = {
				["GS2CClientShowReward"] = true,
				["GS2CItemQuickUse"] = true,
			},
			["chat"] = {
				["GS2CSysChat"] = true,
				["GS2CConsumeMsg"] = true,
			},
			["partner"] = {
				["GS2CShowNewPartnerUI"] = true,
			},
			["achieve"] = {
				["GS2CAchieveDone"] = true,
			},
		},
	}
}

RECORD = {
	war_record = {
		war = {all_flag = true},
		scene = {GS2CShowScene=true},
	}
}

PBKEYS = {
	role = {
		"grade","name","title_info","goldcoin","coin","exp",
		"chubeiexp","max_hp","hp","attack","defense","speed","critical_ratio",
		"res_critical_ratio","critical_damage","cure_critical_ratio","abnormal_attr_ratio",
		"res_abnormal_ratio","model_info","school","coin_over","followers",
		"power", "school_branch", "skill_point", "systemsetting", "upvote_amount", 
		"arenamedal", "org_id", "orgname", "org_status", "org_offer", "org_pos", "medal", "skin",
		"sex", "active", "org_build_status", "org_sign_reward", "org_red_packet",
		"give_org_wish", "org_build_time", "trapmine_point", "is_org_wish","kp_sdk_info","org_fuben_cnt",
		"is_equip_wish", "give_org_equip", "travel_score", "color_coin", "org_leader", "org_level",
		"bcmd", "show_id", "open_day", "energy", "chatself", "camp"
	},
	summon = {"id","typeid","type","key","name","carrygrade","grade","exp","attribute","point","maxaptitude","curaptitude","life","race","element","score",
	"rank","talent","skill","max_hp","max_mp","hp","mp","basename","phy_attack","phy_defense","mag_attack","mag_defense",
	"speed","grow","model_info","traceno","autoswitch","freepoint",
	},
	NpcAoiBlock = {"name", "model_info", "war_tag", "orgid", "orgflag", "owner", "ownerid", "trapmine"},
	PlayerAoiBlock = {"name", "model_info", "war_tag","followers","title_info", "trapmine","social_display", "state", "show_id", "camp"},
	WarriorStatus = {"hp", "max_hp", "model_info", "name", "status", "auto_skill", "bcmd"},
	schedule = {"redpoint","around"},
	partner = {"partner_type", "parid", "star", "model_info", "name", "grade", "exp", "hp", 
		"attack", "defense", "critical_ratio", "res_critical_ratio", "cure_critical_ratio", 
		"abnormal_attr_ratio", "res_abnormal_ratio", "critical_damage", "speed", "max_hp", 
		"power", "lock", "awake", "skill", "equip_plan_id", "equip_plan", "equip_list",
		"patahp", "status", "power_rank", "amount", "souls", "soul_type"},
	team = {"name","model_info","school","grade","status","hp","max_hp","school_branch","bcmd"},
	SimplePartner = {"parid", "name", "grade", "pos", "model_info"},
	friend = {"pid", "name", "shape", "grade", "school", "friend_degree", "relation"},
	org = {"orgid", "name", "level", "leadername", "memcnt", "sflag", "flagbgid", 
		"aim", "cash", "exp", "rank", "prestige", "sign_degree", "red_packet", "active_point", 
		"apply_count", "online_count", "is_open_red_packet", "red_packet_rest", "mail_rest", "spread_endtime"},
	equipFbInfo = {"floor", "time", "auto", "scene_id", "estimate", "nid_list", "count"},
	todyInfo = {"trapmine_point_bought", "energy_buytime", "energy_receive", "shimen_finish"},
	GS2CChargeGiftInfo = {"czjj_is_buy", "czjj_grade_list", "charge_card"}
}

SESSIONLIST = {
	--login:
	"C2GSLogoutByOneKey",
	--arena:
	"C2GSOpenArena",
	"C2GSArenaMatch",
	"C2GSArenaCancelMatch",
	"C2GSConfigEqualArena",
	"C2GSArenaHistory",
	"C2GSArenaSetShowing",
	"C2GSArenaReplayByRecordId",
	"C2GSArenaOpenWatch",
	"C2GSArenaDetailRank",
	"C2GSArenaPraise",
	"C2GSArenaReplayByPlayerId",
	"C2GSEqualArenaMatch",
	"C2GSSelectEqualArena",
	"C2GSOpenEqualArena",
	"C2GSEqualArenaCancelMatch",
	"C2GSSetEqualArenaPartner",
	"C2GSEqualArenaOpenWatch",
	"C2GSEqualArenaSetShowing",
	"C2GSEqualArenaHistory",
	"C2GSGuaidArenaWar",
	--teampvp
	"C2GSTeamPVPMatch",

	--chat:
	"C2GSHongBaoOption",

	--friend:
	"C2GSQueryFriendProfile",
	"C2GSChatTo",
	"C2GSAckChatFrom",
	"C2GSApplyAddFriend",
	"C2GSDelApply",
	"C2GSFindFriend",
	"C2GSFriendShield",
	"C2GSFriendUnshield",
	"C2GSAgreeApply",
	"C2GSDeleteFriend",
	"C2GSEditDocument",
	"C2GSTakeDocunment",
	"C2GSFriendSetting",
	"C2GSRecommendFriends",
	"C2GSBroadcastList",
	"C2GSQueryFriendApply",
	"C2GSNearByFriend",
	"C2GSSetPhoto",
	"C2GSSetShowPartner",
	"C2GSGetShowPartnerInfo",
	"C2GSSetShowEquip",
	"C2GSGetEquipDesc",

	--handbook:
	"C2GSEnterName",
	"C2GSRepairDraw",
	"C2GSUnlockBook",
	"C2GSUnlockChapter",
	"C2GSReadChapter",
	"C2GSOpenBookChapter",
	"C2GSCloseHandBookUI",

	--house:
	"C2GSSwitchWareHouse",
	"C2GSBuyWareHouse",
	"C2GSRenameWareHouse",
	"C2GSWareHouseWithStore",
	"C2GSWareHouseWithDraw",
	"C2GSWareHouseArrange",
	"C2GSGivePartnerGift",

	--huodong:
	"C2GSAnswerQuestion",
	"C2GSOpenBossUI",
	"C2GSQuestionEnterMember",
	"C2GSEnterBossWar",
	"C2GSCloseBossUI",
	"C2GSPataOption",
	"C2GSPataEnterWar",
	"C2GSPataInvite",
	"C2GSPataFrdInfo",
	"C2GSGetEndlessList",
	"C2GSEndlessPVEStart",
	"C2GSQuestionEndReward",
	"C2GSOpenEquipFBMain",
	"C2GSGooutEquipFB",
	"C2GSOpenEquipFB",
	"C2GSEnterEquiFB",
	"C2GSRefreshEquipFBScene",
	"C2GSSetAutoEquipFuBen",
	"C2GSOpenPEMain",
	"C2GSPELock",
	"C2GSPEStartTurn",
	"C2GSEnterPEFuBen",
	"C2GSStartTrapmine",
	"C2GSCancelTrapmine",
	"C2GSTrapmineMonster",
	"C2GSGetLoginReward",
	"C2GSBuyMingleiTimes",
	"C2GSBuyBossBuff",
	"C2GSNpcFight",
	"C2GSBuyEquipPlayCnt",
	"C2GSBuyPEFuBen",
	"C2GSRefreshChipList",
	"C2GSTerrawarMine",
	"C2GSTerrawarWorldRank",
	"C2GSTerrawarOperate",
	"C2GSTerrawarOrgRank",
	"C2GSGetTerraInfo",
	"C2GSTerrawarMain",
	"C2GSAttackTerra",
	"C2GSTerrawarMapInfo",
	"C2GSSetGuard",
	"C2GSAutoSetGuard",
	"C2GSGetListInfo",
	"C2GSHelpFirst",
	"C2GSLeaveQueue",
	"C2GSEnterYJFuben",
	"C2GSBuyYJFuben",
	"C2GSYJFubenOp",
	"C2GSYJFubenView",
	"C2GSYJFindNpc",
	"C2GSBuyLingli",
	"C2GSSocailDisplay",
	"C2GSYJGuidanceReward",
	"C2GSGuideMingleiWar",
	"C2GSOpenFieldBossUI",
	"C2GSFieldBossInfo",
	"C2GSLeaveBattle",
	"C2GSFieldBossPk",
	"C2GSLeaveLegendFB",
	"C2GSClickLink",
	"C2GSLinkName",
	"C2GSLinkItem",
	"C2GSLinkPartner",
	"C2GSEditCommonChat",
	"C2GSGetCommonChat",
	"C2GSLinkPlayer",
	"C2GSGetOnlineGift",
	"C2GSFindHuodongNpc",
	
	--npc:
	"C2GSNpcRespond",
	"C2GSClickConvoyNpc",

	--openui:
	"C2GSOpenScheduleUI",
	"C2GSScheduleReward",
	"C2GSOpenInterface",
	"C2GSCloseInterface",
	"C2GSClickSchedule",

	--org:
	"C2GSOrgList",
	"C2GSSearchOrg",
	"C2GSApplyJoinOrg",
	"C2GSMultiApplyJoinOrg",
	"C2GSGetOrgInfo",
	"C2GSCreateOrg",
	"C2GSOrgMainInfo",
	"C2GSOrgMemberList",
	"C2GSOrgApplyList",
	"C2GSOrgDealApply",
	"C2GSUpdateAim",
	"C2GSRejectAllApply",
	"C2GSOrgSetPosition",
	"C2GSLeaveOrg",
	"C2GSSpreadOrg",
	"C2GSKickMember",
	"C2GSInvited2Org",
	"C2GSDealInvited2Org",
	"C2GSSetApplyLimit",
	"C2GSUpdateFlagID",
	"C2GSGetAim",
	"C2GSBanChat",
	"C2GSGiveOrgWish",
	"C2GSOrgSignReward",
	"C2GSOrgWish",
	"C2GSOrgWishList",
	"C2GSDoneOrgBuild",
	"C2GSSpeedOrgBuild",
	"C2GSOpenOrgRedPacket",
	"C2GSDrawOrgRedPacket",
	"C2GSOrgBuild",
	"C2GSOrgRedPacket",
	"C2GSLeaveOrgWishUI",
	"C2GSOrgLog",
	"C2GSPromoteOrgLevel",
	"C2GSOrgRecruit",
	"C2GSClickSpreadOrg",
	"C2GSOpenOrgFBUI",
	"C2GSClickOrgFBBoss",
	"C2GSRestOrgFuBen",
	"C2GSOrgOnlineCount",
	"C2GSGiveOrgEquipWish",
	"C2GSOrgEquipWish",

	--other:
	"C2GSCallback",
	"C2GSBarrage",
	"C2GSForceLeaveWar",
	"C2GSRequestPay",

	--partner:
	"C2GSPartnerFight",
	"C2GSPartnerSwitch",
	"C2GSAddExpToPartner",
	"C2GSUpgradePartnerStar",
	"C2GSSetPartnerLock",
	"C2GSRenamePartner",
	"C2GSComposePartner",
	"C2GSAwakePartner",
	"C2GSComposeAwakeItem",
	"C2GSPartnerEquipPlanSave",
	"C2GSPartnerEquipPlanUse",
	"C2GSAddPartnerComment",
	"C2GSPartnerCommentInfo",
	"C2GSUpVotePartnerComment",
	"C2GSGetOuQi",
	"C2GSPartnerPictureSwitchPos",
	"C2GSComposePartnerEquip",
	"C2GSStrengthPartnerEquip",
	"C2GSLockPartnerEquip",
	"C2GSSetFollowPartner",
	"C2GSCloseDrawCardUI",
	"C2GSOpenDrawCardUI",

	--player:
	"C2GSGetPlayerInfo",
	"C2GSPlayerItemInfo",
	"C2GSChangeSchool",
	"C2GSUpvotePlayer",
	"C2GSInitRoleName",
	"C2GSRename",
	"C2GSPlayerPK",
	"C2GSWatchWar",
	"C2GSLeaveWatchWar",
	"C2GSPlayerTop4Partner",

	--rank:
	"C2GSPartnerRank",
	"C2GSOpenRankUI",

	--scene:
	"C2GSClickWorldMap",
	"C2GSClickTrapMineMap",
	"C2GSReEnterScene",
	"C2GSChangeSceneModel",

	--skill:
	"C2GSLearnSkill",
	"C2GSLearnCultivateSkill",
	"C2GSWashSchoolSkill",

	--teach:
	"C2GSGetTaskReward",
	"C2GSGetProgressReward",
	--"C2GSFinishGuidance",

	--travel:
	"C2GSAcceptFrdTravelRwd",
	"C2GSGetFrdTravelInfo",
	"C2GSInviteTravel",
	"C2GSSetPartnerTravelPos",
	"C2GSStopTravel",
	"C2GSStartTravel",
	"C2GSAcceptTravelRwd",
	"C2GSCancelSpeedTravel",
	"C2GSSetFrdPartnerTravel",
	"C2GSClearTravelInvite",
	"C2GSDelTravelInvite",
	"C2GSShowTravelCard",
	"C2GSStartTravelCard",
	"C2GSQueryTravelInvite",
	--"C2GSStoreBuyList",
	
	--achieve
	"C2GSAchieveMain",
	"C2GSAchieveDirection",
	"C2GSAchieveReward",
	"C2GSAchievePointReward",

	--chapterfuben
	"C2GSFightChapterFb",
	"C2GSSweepChapterFb",

	--hunt
	"C2GSCallHuntNpc",
	"C2GSSetHuntAutoSale",
	"C2GSHuntSoul",
	"C2GSPickUpSoul",
	"C2GSPickUpSoulByOneKey",
	"C2GSSaleSoulByOneKey",
}