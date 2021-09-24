resFileMgr={
	luaFileList={}, --需要加载的lua文件列表
	textureFileList={}, --纹理文件列表
}

function resFileMgr:getLuaFileList()
	self.luaFileList={
		"luascript/script/global/func",
		"luascript/script/game/gamemodel/shop/allShopVoApi",
	    "luascript/script/game/gamemodel/shop/shopVoApi",
	    "luascript/script/game/gamemodel/bag/bagVoApi",
	    "luascript/script/game/gamemodel/daily/dailyVoApi",
	    "luascript/script/game/gamemodel/task/taskVoApi",
	    "luascript/script/game/gamemodel/checkPoint/checkPointVoApi",
	    "luascript/script/game/gamemodel/rank/rankVoApi",
	    "luascript/script/game/gamemodel/chat/chatVoApi",
	    "luascript/script/game/gamemodel/bookmark/bookmarkVoApi",
	    "luascript/script/game/gamemodel/newGifts/newGiftsVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceShopVoApi",
	    "luascript/script/config/gameconfig/allianceActiveCfg",
	    "luascript/script/game/scene/scene/mainLandScene",
        "luascript/script/game/scene/scene/mainUI",
    	"luascript/script/game/scene/scene/portScene",
    	"luascript/script/game/scene/scene/storyScene",
    	"luascript/script/game/scene/scene/allianceFubenScene",
    	"luascript/script/game/scene/scene/tankWarehouseScene",
    	-- "luascript/script/config/gameconfig/playerCfg",
    	"luascript/script/config/gameconfig/playerSkillCfg",
    	-- "luascript/script/config/gameconfig/taskCfg",
    	"luascript/script/config/gameconfig/dailyTaskCfg",
    	-- "luascript/script/config/gameconfig/dailyTaskCfg2",
    	"luascript/script/config/gameconfig/buildingCfg",
    	"luascript/script/config/gameconfig/techCfg",
    	"luascript/script/config/gameconfig/tankCfg",
    	-- "luascript/script/config/gameconfig/propCfg",
	    "luascript/script/config/gameconfig/checkPointCfg",
	    -- "luascript/script/config/gameconfig/challengeRewardCfg",
	    "luascript/script/config/gameconfig/challengeTechCfg",
	    -- "luascript/script/config/gameconfig/allianceSkillCfg",
	    "luascript/script/config/gameconfig/exteriorCfg",
	    "luascript/script/config/gameconfig/allianceFubenCfg",
	    -- "luascript/script/config/gameconfig/alliancebossCfg",
	    -- "luascript/script/config/gameconfig/activityCfg",
	    -- "luascript/script/config/gameconfig/accessoryCfg",
	    "luascript/script/config/gameconfig/accessoryGuidCfg",
	    "luascript/script/config/gameconfig/eliteChallengeCfg",
	    "luascript/script/config/gameconfig/allianceWarCfg",
	    "luascript/script/config/gameconfig/relativeCfg",
	    -- "luascript/script/config/gameconfig/arenaCfg",
	    "luascript/script/config/gameconfig/heroCfg",
	    "luascript/script/config/gameconfig/heroListCfg",
	    "luascript/script/config/gameconfig/heroSkillCfg",
	    "luascript/script/config/gameconfig/heroFeatCfg",
	    "luascript/script/config/gameconfig/expeditionCfg",
	    "luascript/script/config/gameconfig/succinctCfg",
	    -- "luascript/script/config/gameconfig/buffCfg",
	    "luascript/script/config/gameconfig/mapCfg",
	    "luascript/script/config/gameconfig/worldGroundCfg",
	    "luascript/script/config/gameconfig/mapHeatCfg",
	    "luascript/script/config/gameconfig/abilityCfg",
	    "luascript/script/config/gameconfig/rankCfg",
	    "luascript/script/config/gameconfig/alienTechCfg",
	    "luascript/script/config/gameconfig/dailyAnswerCfg",
	    "luascript/script/game/scene/building/buildings",
	    "luascript/script/componet/upgradeRequire",
	    "luascript/script/game/gamemodel/accessory/accessoryVoApi",
	    "luascript/script/game/gamemodel/accessory/accessoryVo",
	    "luascript/script/game/gamemodel/accessory/accessoryFragmentVo",
	    "luascript/script/game/gamemodel/accessory/eliteChallengeVo",
	    "luascript/script/game/gamemodel/slot/buildingSlotVoApi",
	    "luascript/script/game/gamemodel/building/buildingVoApi",
	    "luascript/script/game/gamemodel/player/playerVoApi",
	    "luascript/script/game/gamemodel/glory/gloryVoApi",
	    "luascript/script/game/gamemodel/skill/skillVo",
	    "luascript/script/game/gamemodel/skill/skillVoApi",
	    "luascript/script/game/gamemodel/technology/technologyVo",
	    "luascript/script/game/gamemodel/technology/technologyVoApi",
	    "luascript/script/game/gamemodel/slot/technologySlotVoApi",
	    "luascript/script/game/gamemodel/slot/technologySlotVo",
	    "luascript/script/game/gamemodel/workshop/workShopApi",
	    "luascript/script/game/gamemodel/slot/workShopSlotVo",
	    "luascript/script/game/gamemodel/slot/workShopSlotVoApi",
	    "luascript/script/game/gamemodel/slot/tankSlotVo",
	    "luascript/script/game/gamemodel/slot/tankSlotVoApi",
	    "luascript/script/game/gamemodel/slot/tankUpgradeSlotVo",
	    "luascript/script/game/gamemodel/slot/tankUpgradeSlotVoApi",
	    "luascript/script/game/gamemodel/slot/attackTankSoltVoApi",
	    "luascript/script/game/gamemodel/slot/useItemSlotVoApi",
	    "luascript/script/game/gamemodel/tank/tankVo",
	    "luascript/script/game/gamemodel/tank/tankVoApi",
	    "luascript/script/game/gamemodel/worldBases/worldBaseVo",
	    "luascript/script/game/gamemodel/worldBases/worldBaseVoApi",
	    "luascript/script/game/gamemodel/email/emailVoApi",
	    "luascript/script/game/gamemodel/enemy/enemyVoApi",
	    "luascript/script/game/gamemodel/activity/activityVo",
	    "luascript/script/game/gamemodel/activity/activityVoApi",
	    "luascript/script/game/gamemodel/arena/arenaVo",
	    "luascript/script/game/gamemodel/arena/arenaVoApi",
	    "luascript/script/game/gamemodel/arena/arenaReportVo",
	    "luascript/script/game/gamemodel/arena/arenaReportVoApi",
	    "luascript/script/game/gamemodel/note/noteVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceVo",
	    "luascript/script/game/gamemodel/alliance/allianceVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceMemberVo",
	    "luascript/script/game/gamemodel/alliance/allianceMemberVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceApplicantVo",
	    "luascript/script/game/gamemodel/alliance/allianceApplicantVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceSkillVo",
	    "luascript/script/game/gamemodel/alliance/allianceSkillVoApi",
	    "luascript/script/game/gamemodel/friend/friendVo",
	    "luascript/script/game/gamemodel/friend/friendGiftVo",
	    "luascript/script/game/gamemodel/friend/friendVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceEventVo",
	    "luascript/script/game/gamemodel/alliance/allianceEventVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceGiftVo",
	    "luascript/script/game/gamemodel/alliance/allianceGiftVoApi",
	    "luascript/script/game/gamemodel/alliance/helpDefendVo",
	    "luascript/script/game/gamemodel/alliance/helpDefendVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceFubenVo",
	    "luascript/script/game/gamemodel/alliance/allianceFubenVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceWarCityVo",
	    "luascript/script/game/gamemodel/alliance/allianceWarUserVo",
	    "luascript/script/game/gamemodel/alliance/allianceWarVo",
	    "luascript/script/game/gamemodel/alliance/allianceWarVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceWarRecordVo",
	    "luascript/script/game/gamemodel/alliance/allianceWarRecordVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceBattleMemVo",
	    "luascript/script/game/gamemodel/sign/signVoApi",
	    "luascript/script/game/gamemodel/sign/newSignInVoApi",
	    "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalVoApi",
	    "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamVoApi",
	    "luascript/script/game/gamemodel/worldWar/worldWarVoApi",
	    "luascript/script/game/gamemodel/hero/heroVo",
	    "luascript/script/game/gamemodel/hero/heroVoApi",
	    "luascript/script/game/gamemodel/friends/friendMailVo",
	    "luascript/script/game/gamemodel/friends/friendMailVoApi",
	    "luascript/script/game/gamemodel/alienTech/alienTechVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceWar2/allianceWar2CityVo",
	    "luascript/script/game/gamemodel/alliance/allianceWar2/allianceWar2UserVo",
	    "luascript/script/game/gamemodel/alliance/allianceWar2/allianceWar2Vo",
	    "luascript/script/game/gamemodel/alliance/allianceWar2/allianceWar2VoApi",
	    "luascript/script/game/gamemodel/alliance/allianceWar2/allianceWar2RecordVo",
	    "luascript/script/game/gamemodel/alliance/allianceWar2/allianceWar2RecordVoApi",
	    "luascript/script/componet/buildingUpgradeCommon",
	    "luascript/script/componet/tankInfoDialog",
	    "luascript/script/componet/propInfoDialog",
	    "luascript/script/componet/allianceDonate",
	    "luascript/script/componet/pageDialog",
	    "luascript/script/game/scene/scene/battleScene",
        "luascript/script/game/newguid/accessoryGuideMgr",
	    "luascript/script/game/gamemodel/vip/vipVoApi",
	    "luascript/script/game/gamemodel/expedition/expeditionVo",
	    "luascript/script/game/gamemodel/expedition/expeditionVoApi",
	    "luascript/script/game/gamemodel/expedition/expeditionReportVo",
	    "luascript/script/game/scene/gamedialog/platformAwardsDialog",
	    "luascript/script/game/gamemodel/dailyActivity/dailyActivityVoApi",
	    "luascript/script/game/gamemodel/alienMines/alienMinesVoApi",
	    "luascript/script/game/gamemodel/alienMines/alienMinesVo",
	    "luascript/script/game/gamemodel/alienMines/alienMinesEmailVoApi",
	    "luascript/script/game/gamemodel/alienMines/alienMinesEmailVo",
	    "luascript/script/game/gamemodel/alienMines/alienMinesReportVoApi",
	    "luascript/script/game/gamemodel/alienMines/alienMinesEnemyInfoVo",
	    "luascript/script/game/gamemodel/alienMines/alienMinesEnemyInfoVoApi",
	    "luascript/script/game/gamemodel/goldMine/goldMineVo",
	    "luascript/script/game/gamemodel/goldMine/goldMineVoApi",
	    "luascript/script/game/gamemodel/privateMine/privateMineVo",
	    "luascript/script/game/gamemodel/privateMine/privateMineVoApi",
	    "luascript/script/game/gamemodel/privateMine/privateMineCfg",
	    "luascript/script/config/gameconfig/goldMineCfg",
	    "luascript/script/global/guideTipMgr",
	    "luascript/script/config/gameconfig/arenanpcCfg",
	    "luascript/script/config/gameconfig/heroEquipAwakeShopCfg",
	    "luascript/script/config/gameconfig/buildingSkinCfg",
	    "luascript/script/componet/shareSmallDialog",
	    "luascript/script/game/gamemodel/armorMatrix/armorMatrixVoApi",
	    "luascript/script/config/gameconfig/armorCfg",
	    "luascript/script/config/gameconfig/serverWarLocal/serverWarLocalCfg",
	    "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalVoApi",
	    "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalFightVoApi",
	    "luascript/script/game/gamemodel/alliance/allianceHelpVo",
	    "luascript/script/game/gamemodel/alliance/allianceHelpEventVo",
	    "luascript/script/game/gamemodel/alliance/allianceHelpVoApi",
	    "luascript/script/game/gamemodel/ladder/ladderVoApi",
	    "luascript/script/game/gamemodel/ladder/ladderHofVo",
	    "luascript/script/game/gamemodel/ladder/ladderHofVo2",
	    "luascript/script/game/gamemodel/ladder/ladderRankVo",
	    "luascript/script/game/gamemodel/ladder/ladderScoreVo",
	    "luascript/script/config/gameconfig/skyladderCfg",
	    "luascript/script/config/gameconfig/accessorytechCfg",
	    "luascript/script/game/scene/gamedialog/gloryInPlayerLabel",
	    "luascript/script/game/scene/gamedialog/gloryUpgradeShowDialog",
	    "luascript/script/game/scene/gamedialog/allianceJoinSmallDialog",
	    "luascript/script/game/scene/gamedialog/newTipSmallDialog",
	    "luascript/script/config/gameconfig/levelShowCfg",
	    "luascript/script/game/gamemodel/emblem/emblemVoApi",
	    "luascript/script/global/jumpDialog",
	    "luascript/script/game/scene/gamedialog/scrollSmallDialog",
	    "luascript/script/global/noticeMgr",
	    -- "luascript/script/config/gameconfig/mapScoutCfg",
	    "luascript/script/game/gamemodel/worldBases/satelliteSearchVo",
	    "luascript/script/game/gamemodel/worldBases/satelliteSearchVoApi",
	    -- "luascript/script/config/gameconfig/headCfg",
	    -- "luascript/script/config/gameconfig/headFrameCfg",
	    -- "luascript/script/config/gameconfig/chatFrameCfg",
	    "luascript/script/config/gameconfig/titleCfg",
	    "luascript/script/game/gamemodel/localWar/localWarVoApi",
	    "luascript/script/netapi/socketHelper_2",
	    "luascript/script/config/gameconfig/buffEffectCfg",
	    "luascript/script/config/gameconfig/xstzCfg",
	    "luascript/script/game/gamemodel/rewardCenter/rewardCenterVoApi",
	    "luascript/script/game/scene/gamedialog/rewardCenter/rewardCenterDialog",
	    "luascript/script/config/gameconfig/superWeapon/superWeaponCfg",
	    "luascript/script/config/gameconfig/superWeapon/swChallengeCfg",
	    "luascript/script/game/gamemodel/superWeapon/superWeaponVoApi",
	    "luascript/script/game/gamemodel/superWeapon/superWeaponVo",
	    "luascript/script/game/gamemodel/superWeapon/swReportVoApi",
	    "luascript/script/config/gameconfig/platWarCfg",
	    "luascript/script/game/gamemodel/platWar/platWarVoApi",
	    "luascript/script/config/gameconfig/equipCfg",
	    "luascript/script/config/gameconfig/hChallengeCfg",
	    "luascript/script/game/gamemodel/hero/heroEquipVo",
	    "luascript/script/game/gamemodel/hero/heroEquipVoApi",
	    "luascript/script/game/gamemodel/hero/heroEquipChallengeVo",
	    "luascript/script/game/gamemodel/hero/heroEquipChallengeVoApi",
	    "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarVoApi",
	    "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarFightVoApi",
	    "luascript/script/game/newguid/buildingGuildMgr", 
	    "luascript/script/game/gamemodel/rebel/rebelVo",
	    "luascript/script/game/gamemodel/rebel/rebelVoApi",
	    -- "luascript/script/config/gameconfig/challengeRaidCfg",
	    "luascript/script/config/gameconfig/buildingCueCfg",
	    "luascript/script/global/buildingCueMgr",
	    "luascript/script/global/protocolController",
	    "luascript/script/config/gameconfig/dailyNewsCfg",
	    "luascript/script/game/gamemodel/dailyNews/dailyNewsVo",
	    "luascript/script/game/gamemodel/dailyNews/dailyNewsVoApi",
	    "luascript/script/config/gameconfig/planeCfg",
	    "luascript/script/config/gameconfig/planeGetCfg",
	    "luascript/script/config/gameconfig/planeGrowCfg",
	    "luascript/script/game/gamemodel/plane/planeVo",
	    "luascript/script/game/gamemodel/plane/planeSkillVo",
	    "luascript/script/game/gamemodel/plane/planeVoApi",
	    "luascript/script/game/gamemodel/plane/planeRefitVoApi",
  		"luascript/script/config/gameconfig/mapOrnamentalCfg",
  		"luascript/script/game/gamemodel/ltzdz/ltzdzVoApi",
  		"luascript/script/game/gamemodel/ltzdz/ltzdzFightApi",
  		"luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi",
  		"luascript/script/game/gamemodel/ltzdz/ltzdzChatVoApi",
		"luascript/script/game/gamemodel/alliance/allianceCity/allianceCityVoApi",
		"luascript/script/game/gamemodel/warStatue/warStatueVoApi",
		"luascript/script/game/gamemodel/believer/believerVoApi",
		"luascript/script/game/gamemodel/player/achievementVoApi",
		"luascript/script/game/gamemodel/friendInfo/friendInfoVo",
		"luascript/script/game/gamemodel/friendInfo/friendInfoVoApi",
		"luascript/script/game/gamemodel/buildDecorate/buildDecorateVo",
		"luascript/script/game/gamemodel/buildDecorate/buildDecorateVoApi",
		"luascript/script/game/gamemodel/championshipWar/championshipWarVoApi",
		"luascript/script/game/scene/gamedialog/buildDecorateDialog",
		"luascript/script/game/scene/gamedialog/limitChallenge/normalChallengeDialog",
		"luascript/script/game/scene/gamedialog/limitChallenge/hellChallengeDialog",
		"luascript/script/game/scene/gamedialog/dailyYdhkDialog",
		"luascript/script/game/gamemodel/migration/migrationVoApi",
		"luascript/script/config/gameconfig/superWeapon/weaponrobCfg",
		"luascript/script/game/gamemodel/AITroops/AITroopsVoApi",
		"luascript/script/game/gamemodel/AITroops/AITroopsFleetVoApi",
		"luascript/script/config/gameconfig/allianceFlagCfg",
		"luascript/script/config/gameconfig/allianceGiftCfg",
		"luascript/script/game/gamemodel/tank/tankSkinVoApi",
		"luascript/script/game/gamemodel/tank/tankSkinVo",
		"luascript/script/config/gameconfig/tankSkinCfg",
		"luascript/script/game/gamemodel/hero/heroAdjutantVoApi",
		"luascript/script/game/scene/gamedialog/supplyShopVoApi",
		"luascript/script/game/gamemodel/exerwar/exerWarVoApi",
		"luascript/script/game/gamemodel/strategyCenter/strategyCenterVoApi",
		"luascript/script/game/gamemodel/airShip/airShipVoApi",
  		"luascript/script/global/FuncSwitchApi",
	}
    if G_isShowNewMapAndBuildings()==1 then
    	table.insert(self.luaFileList,"luascript/script/config/gameconfig/homeCfgNew")
    else
    	table.insert(self.luaFileList,"luascript/script/config/gameconfig/homeCfg")
    end
 
	if platCfg.platNewGuideVersion[G_curPlatName()]==1 then
		table.insert(self.luaFileList,"luascript/script/config/gameconfig/newGuidBMCfg")
  	elseif platCfg.platNewGuideVersion[G_curPlatName()]==2 then
		table.insert(self.luaFileList,"luascript/script/config/gameconfig/newGuidQQCfg")
  	else
        if G_isShowNewMapAndBuildings()==1 then
    		table.insert(self.luaFileList,"luascript/script/config/gameconfig/newGuidQQCfg")
        else
    		table.insert(self.luaFileList,"luascript/script/config/gameconfig/newGuidCfg")
        end
  	end
 
    if platCfg.platNewGuideVersion[G_curPlatName()]==1 then
		table.insert(self.luaFileList,"luascript/script/game/newguid/newGuidBMMgr")
    else
		table.insert(self.luaFileList,"luascript/script/game/newguid/newGuidMgr")
    end
    self:loadGlobalServerLua(true)

    return self.luaFileList
end

function resFileMgr:getTextureFileList()
	--不用tinyPng压缩的图都统一放在这里
	if G_getGameUIVer() == 2 then
		table.insert(self.textureFileList,{path="homeBuilding/home_buildingv2.plist"})
		table.insert(self.textureFileList,{path="homeBuilding/alienTech_basev2.plist"})
	else
		table.insert(self.textureFileList,{path="homeBuilding/home_buildingv1.plist"})
		table.insert(self.textureFileList,{path="homeBuilding/alienTech_basev1.plist"})
	end
	table.insert(self.textureFileList,{path="public/building_youhua.plist"})
	table.insert(self.textureFileList,{path="public/aiTroopsImage/battleImage/aiTankBattleImage.plist",w=1})
	table.insert(self.textureFileList,{path="public/aiTroopsImage/aitroops_images1.plist",w=1})
	table.insert(self.textureFileList,{path="public/editTroops_images.plist"})
	table.insert(self.textureFileList,{path="public/youhuaUI7.plist",w=1})
	table.insert(self.textureFileList,{path="public/youhuaUI6.plist",w=1})
	table.insert(self.textureFileList,{path="public/youhuaUI5.plist",w=1})
	table.insert(self.textureFileList,{path="public/youhua170602.plist",w=1})
	table.insert(self.textureFileList,{path="public/frameImage.plist",w=1})
	table.insert(self.textureFileList,{path="public/frameImage2.plist"})
	table.insert(self.textureFileList,{path="public/frameImage3.plist"})
	table.insert(self.textureFileList,{path="public/itemProp4.plist"})
	table.insert(self.textureFileList,{path="public/skinFlash.plist"})
	table.insert(self.textureFileList,{path="public/jdpf_effect.plist"})
	table.insert(self.textureFileList,{path="public/tankSkin/tankSkin_icon1.plist"})
	table.insert(self.textureFileList,{path="public/militaryOrdersImages.plist",w=1})
	table.insert(self.textureFileList,{path="public/acZnkh2019_images.plist",w=1})
	table.insert(self.textureFileList,{path="public/airShip_bossIcon.plist",w=1})
	table.insert(self.textureFileList,{path="public/airShipImageInBattle.plist",w=1})
	table.insert(self.textureFileList,{path="public/airship_propicons.plist",w=1})
	table.insert(self.textureFileList,{path="public/airship_icons.plist",w=1})
	for idx = 1, 7 do
		table.insert(self.textureFileList,{path="public/arpl_ship"..idx..".plist",w=1})
		if idx == 1 or idx == 6 or idx == 7 then
			table.insert(self.textureFileList,{path="public/arpl_shipPropellerImage"..idx..".plist",w=1})
		end
	end
	table.insert(self.textureFileList,{path="public/arpl_shipUniversalImage1.plist",w=1})
	table.insert(self.textureFileList,{path="public/airShipImage2.plist",w=1})
    if platCfg.platCfgNewTypeAddTank==true then
    else
    	table.insert(self.textureFileList,{path="public/ladder/ladderCommon.plist",w=1})
    end
        
    if G_isShowNewMapAndBuildings()==1 then
    	table.insert(self.textureFileList,{path="newUI/buildingAnim2.plist"})
    	table.insert(self.textureFileList,{path="newUI/newBuilding2.plist"})
    else
    	table.insert(self.textureFileList,{path="homeBuilding/newBuilding.plist"})
    end
    -- ---------------不需要压缩的资源，必现放在前面-----start----------------
    -- if platCfg.platCfgUseCompressRes and platCfg.platCfgUseCompressRes[G_curPlatName()] and G_Version>=platCfg.platCfgUseCompressRes[G_curPlatName()] then
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressBg.plist")
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressCommon1.plist")
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressCommon2.plist")
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressPropIcon.plist")
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressSkillIcon.plist")
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressTankIcon.plist")
    -- end
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/allTankIcon.plist")
    -- ---------------不需要压缩的资源，必现放在前面-----end----------------
    if platCfg.platCfgNewWayAddTankImage then
    	local textures={
	      	"ship/newTankImage/showTankImage1.plist",
	      	"ship/newTankImage/showTankImage2.plist",
	      	"ship/newTankImage/newCommonImage.plist",
	      	"ship/newTankImage/newTankCommonImage1.plist",
	      	"ship/newTankImage/commonTankImage3.plist",
	      	"ship/newTankImage/commonTankImage4.plist",
	      	"ship/newTankImage/commonTankImage5.plist",
	      	"ship/newTankImage/commonTankImage6.plist",
	      	"ship/newTankImage/commonTankImage7.plist",
	      	"ship/newTankImage/commonTankImage.plist",
	      	"ship/newTankImage/commonTankImage2.plist",

	    }
	    for k,v in pairs(textures) do
	    	table.insert(self.textureFileList,{path=v})
	    end
    else
    	if G_isShowNewMapAndBuildings()==1 then
    		table.insert(self.textureFileList,{path="newUI/newTankLv6Image.plist"})
	    else
	    	table.insert(self.textureFileList,{path="ship/newTankLv6Image.plist"})
      	end
    end
    if G_getGameUIVer()==2 then
    	table.insert(self.textureFileList,{path="public/newUI_RotatingEffect.plist",w=1})
    	table.insert(self.textureFileList,{path="public/new_buy_light.plist",w=1})
    end
    table.insert(self.textureFileList,{path="scene/mainModelImage.plist",w=1})
    table.insert(self.textureFileList,{path="scene/mainModelImage2.plist",w=1})
	table.insert(self.textureFileList,{path="public/heroImage.plist",w=1})
	table.insert(self.textureFileList,{path="public/realDefImage2.plist",w=1})
	table.insert(self.textureFileList,{path="public/realDefImage3.plist",w=1})
	table.insert(self.textureFileList,{path="public/realDefImage4.plist",w=1})
	table.insert(self.textureFileList,{path="public/realDefImage5.plist",w=1})
	table.insert(self.textureFileList,{path="public/realDefImage6.plist",w=1})
	table.insert(self.textureFileList,{path="public/realDefImage7.plist",w=1})
    if platCfg.platCfgNewTypeAddTank==true then
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon4.plist"})
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon6.plist"})
    else
		table.insert(self.textureFileList,{path="public/hero_infoBtn.plist"})
		table.insert(self.textureFileList,{path="public/heroImage.plist"})
		table.insert(self.textureFileList,{path="public/selectTankImage.plist"})
		table.insert(self.textureFileList,{path=G_ChatImage})
    end

    if G_isShowNewMapAndBuildings()==1 then
		table.insert(self.textureFileList,{path="newUI/newImage.plist"})
    else
		table.insert(self.textureFileList,{path="public/newImage.plist"})
    end
    if platCfg.platCfgNewTypeAddTank==true then
    else
		table.insert(self.textureFileList,{path="public/newIconImage.plist"})
    end
    table.insert(self.textureFileList,{path="public/decorate.plist"})
    if platCfg.platCfgNewTypeAddTank==true then
    else
		table.insert(self.textureFileList,{path="public/chestNewIcon.plist"})
    end
	table.insert(self.textureFileList,{path=G_ImageSetting})
    if platCfg.platCfgNewTypeAddTank==true then
		table.insert(self.textureFileList,{path="ship/newTank/noCompression.plist"})
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon9.plist",w=1})
    end
    if platCfg.platCfgNewTypeAddTank==true then
    else
		table.insert(self.textureFileList,{path=G_AllIcon3})
    end
    if G_isShowNewMapAndBuildings()==1 then
		table.insert(self.textureFileList,{path="newUI/AllIcon2.plist"})
		table.insert(self.textureFileList,{path="newUI/accessoryCommonImage.plist"})
    else
		table.insert(self.textureFileList,{path=G_AllIcon2})
		table.insert(self.textureFileList,{path=G_AccessoryCommonImage})
    end
    if platCfg.platCfgNewTypeAddTank==true then
    else
		table.insert(self.textureFileList,{path=G_Tank1EffectSrc})
    end
	table.insert(self.textureFileList,{path=G_StoryImage})
	table.insert(self.textureFileList,{path=G_BoomEffect})
	table.insert(self.textureFileList,{path=G_TankDieAni})
	if G_isUseNewMap()==true then
		table.insert(self.textureFileList,{path="scene/mapBuilding.plist",w=1}) --必须在mapBaseBuilding.plist和G_HomeBuildingImage之前加载
		table.insert(self.textureFileList,{path="scene/mapBuilding2.plist",w=1})
		table.insert(self.textureFileList,{path="scene/mapBuilding3.plist",w=1})
		table.insert(self.textureFileList,{path="scene/mapBuilding4.plist",w=1})
		table.insert(self.textureFileList,{path="scene/mapBuilding5.plist",w=1})
		table.insert(self.textureFileList,{path="scene/mapBuilding6.plist",w=1})
		table.insert(self.textureFileList,{path="scene/mapBuilding7.plist",w=1})
		table.insert(self.textureFileList,{path="scene/mapBuilding8.plist",w=1})
	end
	table.insert(self.textureFileList,{path=G_BuildingAnimSrc}) --这个必须在G_HomeBuildingImage前加载
    if G_isShowNewMapAndBuildings()==1 then
		table.insert(self.textureFileList,{path="newUI/home_building.plist"})
    else
		table.insert(self.textureFileList,{path=G_HomeBuildingImage})
    end
	table.insert(self.textureFileList,{path=G_VSAnimation})
    if platCfg.platCfgNewTypeAddTank==true then
    else
		table.insert(self.textureFileList,{path=G_TankBulletSrc})
    end
    table.insert(self.textureFileList,{path=G_MainUIImage})
	if G_getGameUIVer()==2 then
		table.insert(self.textureFileList,{path=G_newMainUIImage1,w=1})
		table.insert(self.textureFileList,{path=G_newMainUIImage2,w=1})
	end
	table.insert(self.textureFileList,{path=G_NewHitAni})
	table.insert(self.textureFileList,{path="public/chatImageNew.plist"})
	
    if platCfg.platCfgNewTypeAddTank==true then
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon1.plist"})    
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon8.plist"})
    else
    	local textures={
	      	"ship/newTankImage1.plist",
	      	"ship/tank59Image.plist",
	      	"ship/t10044Image.plist",
	      	"ship/t10103Image.plist",
	      	"ship/t10054Image.plist",
	      	"ship/t10113_t10123Image.plist",
	      	"ship/t10064Image.plist",
	      	"ship/t10074Image.plist",
	      	"ship/tank1223.plist",
	      	"ship/Tank7LvImage.plist",
	      	"ship/tank1.plist",
	      	"ship/tank2.plist",
	      	"ship/80tankImage.plist",
	      	"ship/t10083Image.plist",
	      	"ship/t10094Image.plist",
	      	"ship/t10114Image.plist",
	      	"ship/t10124Image.plist",
	      	"ship/t20114Image.plist",
	      	"ship/t10133Image.plist",
	      	"ship/t10134Image.plist",
	      	"ship/t10075Image.plist",
	      	"ship/t10135Image.plist",
	      	"ship/skillIcon10134.plist",
	      	G_AddAttackType_2,
	      	G_BirdAndWaterImage,
	      	"public/tankImage_a10082.plist",
	      	"public/mibaoImage.plist",
	      	"public/militaryRankImage.plist",
	      	"public/newVip.plist",
	      	"public/friendsImage.plist",
	      	"public/kuangnuImage.plist",
	      	"public/access1223.plist",
	      	"public/mainBtnStrong.plist",
	      	"public/vipUp.plist",
	      	"public/refingBuildingImage.plist",
	      	"public/acSingles.plist",
	      	"public/goldmine_images.plist",
	      	"public/alienMines.plist",
	      	"public/midautumn_props.plist",
	    }
     	for k,v in pairs(textures) do
	    	table.insert(self.textureFileList,{path=v})
	    end
    end
	table.insert(self.textureFileList,{path=G_AllIcon})
	-- table.insert(self.textureFileList,{path="public/youhuaUI6.plist",w=1})
	table.insert(self.textureFileList,{path="public/youhuaUI.plist",w=1})
	table.insert(self.textureFileList,{path="public/acWjdc.plist",w=1})
	table.insert(self.textureFileList,{path="public/youhuaUI2.plist",w=1})
	table.insert(self.textureFileList,{path="public/stewardImage.plist",w=1})
	table.insert(self.textureFileList,{path="public/supplyShopImages.plist",w=1})
	table.insert(self.textureFileList,{path="public/supplyShopCopter.plist",w=1})
	table.insert(self.textureFileList,{path="public/airShip_editTroops_images.plist",w=1})
	-- table.insert(self.textureFileList,{path="public/acBlessWords.plist"})--用于双11红包 聊天里的图片显示
    if platCfg.platCfgNewTypeAddTank==true then
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon2.plist"})
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon3.plist"})
    else
    	local textures={
	        "ship/tankNewBuffIcon.plist",
	        "ship/t20054Image.plist",
	        "ship/t10045_20115Image.plist",
	        "ship/t10095Image.plist",
	        "ship/t20125Image.plist",
	        "ship/t20055Image.plist",
	        "ship/t10104Image.plist",
	        "ship/t20153_20155Image.plist",
	        "ship/skillIcon20153_20155.plist",
	        "ship/skillIcon10104.plist",
	        "ship/supperWeaponBgImage.plist",
	        "public/item_prop_sendAccessory.plist",
	        "public/pickedTankIcon.plist",
	        "public/forbidBtn.plist",
	        "ship/newTankBgImage.plist",
	        "ship/t10084&t10145Image.plist",
	        "ship/t20065Image.plist",
	        "public/acStormFortressImage/acStormFortressImage.plist",
	        {path="public/dimensionalWar/dimensionalWarCommon.plist",w=1},
	        {path="public/radiationImage.plist",w=1},
	        {path="public/gloryNeedPic.plist",w=1},
	    }
	    for k,v in pairs(textures) do
	    	if type(v)=="table" then
	    		table.insert(self.textureFileList,v)
	    	else
		    	table.insert(self.textureFileList,{path=v})
	    	end
	    end
    end
    local textures={
    	"ship/supperWeaponSkillShow1.plist",
    	"scene/newGuid_NewImage.plist",
		"public/acFirstRechargeYouhua.plist",
        "public/superWeapon/superWeaponCommon2.plist",
    	{path="public/guildImages.plist",w=1},
    	{path="public/addNewPropImage1.plist",w=1},
	}
	for k,v in pairs(textures) do
		if type(v)=="table" then
    		table.insert(self.textureFileList,v)
    	else
	    	table.insert(self.textureFileList,{path=v})
    	end
	end
    if platCfg.platCfgNewTypeAddTank==true then
		table.insert(self.textureFileList,{path="ship/newTank/newTankCommon5.plist"})
    else
    	local textures={
	        "ship/t10144Image.plist",
	        "ship/t10143Image.plist",
	        "ship/skillIcon10134.plist",
	        "ship/skillIcon10144.plist",
	        "ship/skillIcon_t10144.plist",
	        "ship/tankIconNewAdd.plist",
	        "public/xsicon.plist",
	        G_NewHitFireBulletAni,
	        "public/tankSkillIcon.plist",
	        "public/freeSpeedup.plist",
	        "public/scrollImage.plist",
	    }
	    for k,v in pairs(textures) do
	    	table.insert(self.textureFileList,{path=v})
	    end
    end

    if platCfg.platCfgNewTypeAddTank==true then
    	table.insert(self.textureFileList,{path="ship/newTank/newTankCommon7.plist"})
    	table.insert(self.textureFileList,{path="ship/newTank/newTankCommon10.plist",w=1})
    else
    	local textures={
	        "public/itemProp.plist",
	        "serverWar/serverWarCommon.plist",
	        "public/KoreaNeedProp.plist",
	        "public/playerIcon.plist",
	        "public/CheckCode.plist",
	        "public/acHalloweenImage.plist",
	        "homeBuilding/ladderBuild.plist",
	        "public/superWeapon/superWeaponCommon.plist",
	        "public/hero/heroequip/equipProp.plist",
	        "public/hero/heroequip/equipProp2.plist",
	        "public/hero/heroequip/equipProp3.plist",
	        "public/hero/heroequip/equipCommon.plist",
	        "public/autoBuildImage.plist",
	        "public/snowIcon.plist",
	        "public/redArmIconImage.plist",
	        "public/allianceWar2/allianceWar2Common.plist",
	        "public/newPropsIcon.plist",
	        {path="public/newFleetSlot.plist",w=1},
	        {path="public/newRecharge.plist",w=1},
	        {path="public/raids.plist",w=1},
	        {path="public/newTipImage.plist",w=1},
	        "public/alliance_join.plist",
	        "public/fleetSlotLine.plist",
	        "public/new_head.plist",
	    }
    	for k,v in pairs(textures) do
			if type(v)=="table" then
	    		table.insert(self.textureFileList,v)
	    	else
		    	table.insert(self.textureFileList,{path=v})
	    	end
		end
    end
    textures={
    	{path="public/emblem/emblemCommonImage.plist",w=1},
    	{path="public/newMiniImage.plist",w=1},
    	{path="public/privateMineImage.plist",w=1},
      	{path="public/privateCoverImages.plist",w=1},
    	{path="public/emblemIconAndDebris.plist",w=1},
    	{path="public/creatRoleImage.plist",w=1},
    	{path="public/armorMatrixCommon.plist",w=1},
    	{path="public/plane/planePark_images.plist",w=1},
    	{path="public/plane/planeAttack_images.plist",w=1},
    	{path="public/addNewPropImage1.plist",w=1},
	    "public/button_0301.plist",
	    "public/propReviews.plist",
	    "public/playerTitleBgImage.plist",
	    "public/alienTechCommon.plist",
	    "public/buildcue_images.plist",
	    "public/player_icon1.plist",
	    "public/taskPointIcon.plist",
	    "public/redAccessory.plist",
	    "public/propBox.plist",
	    "public/speedUpProp/speedUpPropImage.plist", --加速道具
	    "public/playIcon2017.plist", --新添加的玩家头像
	    {path="scene/mapOrnamentals.plist",w=1}, --地图装饰物
	    {path="scene/mapSurface.plist",w=1}, --地表
	    "scene/ui_home_eagle.plist",
	    "scene/mapPlane.plist",
	    "ship/newTank/newTankCommon11.plist",
	    "ship/newTank/newTankCommon12.plist",
	    "ship/newTank/tankSkinCommon1.plist",
	    "public/materialBox.plist",
	    "public/acRamadan_images.plist",
	    {path="public/acFyssImage.plist",w=1},
	    "public/abouGMImage.plist",
	    {path="public/itemProp2.plist",w=1},
	    "public/youhua170717.plist",
	    "ship/addFireEffectsImage1.plist",
	    "public/youhua170905.plist",
	    "public/headImage.plist",
	    "public/shatteredImage.plist",
	    "public/checkPointImage.plist",
	    {path="public/plane/planeSkillImages.plist",w=1},
    	{path="public/youhua170523.plist",w=1},
    	"public/itemProp3.plist",
    	{path="public/newRoleIcon.plist",w=1},
	    "public/plane/planeNewSkill.plist",
	    {path="public/allianceFlag.plist",w=1},
	    {path="public/heroAdjutantImages.plist",w=1},
	    {path="public/exerbase_images.plist"},
	    "public/hero/heroequip/equipProp4.plist",
	}
	for k,v in pairs(textures) do
		if type(v)=="table" then
    		table.insert(self.textureFileList,v)
    	else
	    	table.insert(self.textureFileList,{path=v})
    	end
	end
	return self.textureFileList
end

--重新加载全球混服相关的配置
-- isFirst是否是切换账号进入游戏，false：表示是切换账号
function resFileMgr:loadGlobalServerLua(isFirst)
	-- 全球混服加载配置
	local luaFiles
	if G_isGlobalServer()==true then
		luaFiles={
			"luascript/script/config/gameconfig/alienMineCfg2",
			"luascript/script/config/gameconfig/allianceWar2Cfg2",
			"luascript/script/config/gameconfig/bossCfg2",
			"luascript/script/config/gameconfig/energyNightCfg2",
			"luascript/script/config/gameconfig/energyNoonCfg2",
			"luascript/script/config/gameconfig/localWarCfg2",
			"luascript/script/config/gameconfig/userWarCfg2",
		}
	else
		luaFiles={
			"luascript/script/config/gameconfig/alienMineCfg",
			"luascript/script/config/gameconfig/bossCfg",
			"luascript/script/config/gameconfig/energyNightCfg",
			"luascript/script/config/gameconfig/energyNoonCfg",
			"luascript/script/config/gameconfig/userWarCfg",
		}
		if G_isMemoryServer() == true then
			table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/allianceWar2Cfg")
			table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/localWarCfg")
		else
			table.insert(luaFiles, "luascript/script/config/gameconfig/allianceWar2Cfg")
			table.insert(luaFiles, "luascript/script/config/gameconfig/localWarCfg")
		end
	end
	---[[ 怀旧服重载相关配置
	if G_isMemoryServer() then
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/alliancebossCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/arenaCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/dailyTaskCfg2")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/newSignInCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/playerCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/propCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/activityCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/allianceShopCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/taskCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/allianceSkillCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/allianceActiveCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/accessoryCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/chatFrameCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/headCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/headFrameCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/mapScoutCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/challengeRewardCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/buffCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/challengeRaidCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/memoryServerCfg/rebelCfg")
	else
		table.insert(luaFiles, "luascript/script/config/gameconfig/alliancebossCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/arenaCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/dailyTaskCfg2")
		table.insert(luaFiles, "luascript/script/config/gameconfig/newSignInCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/playerCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/propCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/activityCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/allianceShopCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/taskCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/allianceSkillCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/allianceActiveCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/accessoryCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/chatFrameCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/headCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/headFrameCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/mapScoutCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/challengeRewardCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/buffCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/challengeRaidCfg")
		table.insert(luaFiles, "luascript/script/config/gameconfig/rebelCfg")
	end
	--]]
	if luaFiles then
		if isFirst and isFirst==true then
			for k,luaPath in pairs(luaFiles) do
				table.insert(self.luaFileList,luaPath)
			end
		else
			package.loaded["luascript/script/config/gameconfig/alienMineCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/alienMineCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/allianceWar2Cfg"] = nil
			package.loaded["luascript/script/config/gameconfig/allianceWar2Cfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/bossCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/bossCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/energyNightCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/energyNightCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/energyNoonCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/energyNoonCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/localWarCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/localWarCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/userWarCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/userWarCfg2"] = nil
			---[[ 怀旧服重载相关配置
			package.loaded["luascript/script/config/gameconfig/alliancebossCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/alliancebossCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/arenaCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/arenaCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/dailyTaskCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/dailyTaskCfg2"] = nil
			package.loaded["luascript/script/config/gameconfig/newSignInCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/newSignInCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/playerCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/playerCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/propCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/propCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/activityCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/activityCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/allianceShopCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/allianceShopCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/allianceWar2Cfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/allianceWar2Cfg"] = nil
			package.loaded["luascript/script/config/gameconfig/taskCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/taskCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/allianceSkillCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/allianceSkillCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/allianceActiveCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/allianceActiveCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/accessoryCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/accessoryCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/chatFrameCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/chatFrameCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/headCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/headCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/headFrameCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/headFrameCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/challengeRewardCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/challengeRewardCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/mapScoutCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/mapScoutCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/buffCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/buffCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/challengeRaidCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/challengeRaidCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/localWarCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/rebelCfg"] = nil
			package.loaded["luascript/script/config/gameconfig/memoryServerCfg/rebelCfg"] = nil

			--]]
			-- for k,luaPath in pairs(luaFiles) do
			-- 	if luaPath and type(luaPath)=="string" then
			-- 		require (luaPath)
			-- 	end
			-- end
		end
	end
	return luaFiles
end

--某些需要切换账号重新加载的lua文件
function resFileMgr:getReloadLuaFiles()
	self.reloadLuas = self:loadGlobalServerLua(false)
	return self.reloadLuas
end

--某些需要切换账号重新加载的纹理资源（比如新旧版ui替换）
function resFileMgr:getReloadTextures()
	if G_checkUseAuditUI() == true or G_isApplyVersion() == true then
		do return {} end
	end
	self.reloadTextures = {}
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/home_buildingv2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("homeBuilding/home_buildingv2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/alienTech_basev2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("homeBuilding/alienTech_basev2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/home_buildingv1.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("homeBuilding/home_buildingv1.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/alienTech_basev1.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("homeBuilding/alienTech_basev1.png")
 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("scene/newMainUI_1.plist")
  	CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newMainUI_1.png")
 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("scene/newMainUI_2.plist")
 	CCTextureCache:sharedTextureCache():removeTextureForKey("scene/newMainUI_2.png")
 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/newUI_RotatingEffect.plist")
 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/newUI_RotatingEffect.png")
 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/new_buy_light.plist")
 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/new_buy_light.png")
	if G_getGameUIVer() == 2 then
		table.insert(self.reloadTextures,{path="homeBuilding/home_buildingv2.plist"})
		table.insert(self.reloadTextures,{path="homeBuilding/alienTech_basev2.plist"})
		table.insert(self.reloadTextures,{path="scene/newMainUI_1.plist",w=1})
		table.insert(self.reloadTextures,{path="scene/newMainUI_2.plist",w=1})
		table.insert(self.reloadTextures,{path="public/newUI_RotatingEffect.plist",w=1})
		table.insert(self.reloadTextures,{path="public/new_buy_light.plist",w=1})
	else
		table.insert(self.reloadTextures,{path="homeBuilding/home_buildingv1.plist"})
		table.insert(self.reloadTextures,{path="homeBuilding/alienTech_basev1.plist"})
	end
	return self.reloadTextures
end

function resFileMgr:clear()
	self.luaFileList={}
	self.textureFileLis={}
	self.reloadTextures={}
	self.reloadLuas={}
end