





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"


Pomelo = Pomelo or {}


Pomelo.GameSocket = {}

local function onAchievementPushDecoder(stream)
	local res = achievementHandler_pb.OnAchievementPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onAchievementPush(cb)
	Socket.On("area.achievementPush.onAchievementPush", function(res) 
		Pomelo.GameSocket.lastOnAchievementPush = res
		cb(nil,res) 
	end, onAchievementPushDecoder) 
end


local function superPackageBuyPushDecoder(stream)
	local res = activityFavorHandler_pb.SuperPackageBuyPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.superPackageBuyPush(cb)
	Socket.On("area.activityFavorPush.superPackageBuyPush", function(res) 
		Pomelo.GameSocket.lastSuperPackageBuyPush = res
		cb(nil,res) 
	end, superPackageBuyPushDecoder) 
end


local function limitTimeGiftInfoPushDecoder(stream)
	local res = activityFavorHandler_pb.LimitTimeGiftInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.limitTimeGiftInfoPush(cb)
	Socket.On("area.activityFavorPush.limitTimeGiftInfoPush", function(res) 
		Pomelo.GameSocket.lastLimitTimeGiftInfoPush = res
		cb(nil,res) 
	end, limitTimeGiftInfoPushDecoder) 
end


local function amuletEquipNewPushDecoder(stream)
	local res = amuletHandler_pb.AmuletEquipNewPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.amuletEquipNewPush(cb)
	Socket.On("area.amuletPush.amuletEquipNewPush", function(res) 
		Pomelo.GameSocket.lastAmuletEquipNewPush = res
		cb(nil,res) 
	end, amuletEquipNewPushDecoder) 
end


local function onArenaBattleInfoPushDecoder(stream)
	local res = arenaHandler_pb.OnArenaBattleInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onArenaBattleInfoPush(cb)
	Socket.On("area.arenaPush.onArenaBattleInfoPush", function(res) 
		Pomelo.GameSocket.lastOnArenaBattleInfoPush = res
		cb(nil,res) 
	end, onArenaBattleInfoPushDecoder) 
end


local function onArenaBattleEndPushDecoder(stream)
	local res = arenaHandler_pb.OnArenaBattleEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onArenaBattleEndPush(cb)
	Socket.On("area.arenaPush.onArenaBattleEndPush", function(res) 
		Pomelo.GameSocket.lastOnArenaBattleEndPush = res
		cb(nil,res) 
	end, onArenaBattleEndPushDecoder) 
end


local function luxuryRewardPushDecoder(stream)
	local res = attendanceHandler_pb.LuxuryRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.luxuryRewardPush(cb)
	Socket.On("area.attendancePush.luxuryRewardPush", function(res) 
		Pomelo.GameSocket.lastLuxuryRewardPush = res
		cb(nil,res) 
	end, luxuryRewardPushDecoder) 
end


local function bagItemUpdatePushDecoder(stream)
	local res = bagHandler_pb.BagItemUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.bagItemUpdatePush(cb)
	Socket.On("area.bagPush.bagItemUpdatePush", function(res) 
		Pomelo.GameSocket.lastBagItemUpdatePush = res
		cb(nil,res) 
	end, bagItemUpdatePushDecoder) 
end


local function bagNewItemPushDecoder(stream)
	local res = bagHandler_pb.BagNewItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.bagNewItemPush(cb)
	Socket.On("area.bagPush.bagNewItemPush", function(res) 
		Pomelo.GameSocket.lastBagNewItemPush = res
		cb(nil,res) 
	end, bagNewItemPushDecoder) 
end


local function bagNewEquipPushDecoder(stream)
	local res = bagHandler_pb.BagNewEquipPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.bagNewEquipPush(cb)
	Socket.On("area.bagPush.bagNewEquipPush", function(res) 
		Pomelo.GameSocket.lastBagNewEquipPush = res
		cb(nil,res) 
	end, bagNewEquipPushDecoder) 
end


local function bagGridFullPushDecoder(stream)
	local res = bagHandler_pb.BagGridFullPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.bagGridFullPush(cb)
	Socket.On("area.bagPush.bagGridFullPush", function(res) 
		Pomelo.GameSocket.lastBagGridFullPush = res
		cb(nil,res) 
	end, bagGridFullPushDecoder) 
end


local function bagGridNumPushDecoder(stream)
	local res = bagHandler_pb.BagGridNumPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.bagGridNumPush(cb)
	Socket.On("area.bagPush.bagGridNumPush", function(res) 
		Pomelo.GameSocket.lastBagGridNumPush = res
		cb(nil,res) 
	end, bagGridNumPushDecoder) 
end


local function bagNewItemFromResFubenPushDecoder(stream)
	local res = bagHandler_pb.BagNewItemFromResFubenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.bagNewItemFromResFubenPush(cb)
	Socket.On("area.bagPush.bagNewItemFromResFubenPush", function(res) 
		Pomelo.GameSocket.lastBagNewItemFromResFubenPush = res
		cb(nil,res) 
	end, bagNewItemFromResFubenPushDecoder) 
end


local function throwPointItemListPushDecoder(stream)
	local res = battleHandler_pb.ThrowPointItemListPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.throwPointItemListPush(cb)
	Socket.On("area.battlePush.throwPointItemListPush", function(res) 
		Pomelo.GameSocket.lastThrowPointItemListPush = res
		cb(nil,res) 
	end, throwPointItemListPushDecoder) 
end


local function throwPointResultPushDecoder(stream)
	local res = battleHandler_pb.ThrowPointResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.throwPointResultPush(cb)
	Socket.On("area.battlePush.throwPointResultPush", function(res) 
		Pomelo.GameSocket.lastThrowPointResultPush = res
		cb(nil,res) 
	end, throwPointResultPushDecoder) 
end


local function fightLevelResultPushDecoder(stream)
	local res = battleHandler_pb.FightLevelResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.fightLevelResultPush(cb)
	Socket.On("area.battlePush.fightLevelResultPush", function(res) 
		Pomelo.GameSocket.lastFightLevelResultPush = res
		cb(nil,res) 
	end, fightLevelResultPushDecoder) 
end


local function itemDropPushDecoder(stream)
	local res = battleHandler_pb.ItemDropPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.itemDropPush(cb)
	Socket.On("area.battlePush.itemDropPush", function(res) 
		Pomelo.GameSocket.lastItemDropPush = res
		cb(nil,res) 
	end, itemDropPushDecoder) 
end


local function sceneNamePushDecoder(stream)
	local res = battleHandler_pb.SceneNamePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.sceneNamePush(cb)
	Socket.On("area.battlePush.sceneNamePush", function(res) 
		Pomelo.GameSocket.lastSceneNamePush = res
		cb(nil,res) 
	end, sceneNamePushDecoder) 
end


local function resourceDungeonResultPushDecoder(stream)
	local res = battleHandler_pb.ResourceDungeonResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.resourceDungeonResultPush(cb)
	Socket.On("area.battlePush.resourceDungeonResultPush", function(res) 
		Pomelo.GameSocket.lastResourceDungeonResultPush = res
		cb(nil,res) 
	end, resourceDungeonResultPushDecoder) 
end


local function consignmentRemovePushDecoder(stream)
	local res = consignmentLineHandler_pb.ConsignmentRemovePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.consignmentRemovePush(cb)
	Socket.On("area.consignmentLinePush.consignmentRemovePush", function(res) 
		Pomelo.GameSocket.lastConsignmentRemovePush = res
		cb(nil,res) 
	end, consignmentRemovePushDecoder) 
end


local function treasureOpenPushDecoder(stream)
	local res = crossServerHandler_pb.TreasureOpenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.treasureOpenPush(cb)
	Socket.On("area.crossServerPush.treasureOpenPush", function(res) 
		Pomelo.GameSocket.lastTreasureOpenPush = res
		cb(nil,res) 
	end, treasureOpenPushDecoder) 
end


local function updateActivityPushDecoder(stream)
	local res = dailyActivityHandler_pb.UpdateActivityPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.updateActivityPush(cb)
	Socket.On("area.dailyActivityPush.updateActivityPush", function(res) 
		Pomelo.GameSocket.lastUpdateActivityPush = res
		cb(nil,res) 
	end, updateActivityPushDecoder) 
end


local function sweepDemonTowerEndPushDecoder(stream)
	local res = demonTowerHandler_pb.SweepDemonTowerEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.sweepDemonTowerEndPush(cb)
	Socket.On("area.demonTowerPush.sweepDemonTowerEndPush", function(res) 
		Pomelo.GameSocket.lastSweepDemonTowerEndPush = res
		cb(nil,res) 
	end, sweepDemonTowerEndPushDecoder) 
end


local function equipmentSimplePushDecoder(stream)
	local res = equipHandler_pb.EquipmentSimplePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.equipmentSimplePush(cb)
	Socket.On("area.equipPush.equipmentSimplePush", function(res) 
		Pomelo.GameSocket.lastEquipmentSimplePush = res
		cb(nil,res) 
	end, equipmentSimplePushDecoder) 
end


local function equipInheritPushDecoder(stream)
	local res = equipHandler_pb.EquipInheritPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.equipInheritPush(cb)
	Socket.On("area.equipPush.equipInheritPush", function(res) 
		Pomelo.GameSocket.lastEquipInheritPush = res
		cb(nil,res) 
	end, equipInheritPushDecoder) 
end


local function equipStrengthPosPushDecoder(stream)
	local res = equipHandler_pb.StrengthPosPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.equipStrengthPosPush(cb)
	Socket.On("area.equipPush.equipStrengthPosPush", function(res) 
		Pomelo.GameSocket.lastStrengthPosPush = res
		cb(nil,res) 
	end, equipStrengthPosPushDecoder) 
end


local function onFashionGetPushDecoder(stream)
	local res = fashionHandler_pb.FashionGetPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onFashionGetPush(cb)
	Socket.On("area.fashionPush.onFashionGetPush", function(res) 
		Pomelo.GameSocket.lastFashionGetPush = res
		cb(nil,res) 
	end, onFashionGetPushDecoder) 
end


local function onConfirmEnterFubenPushDecoder(stream)
	local res = fightLevelHandler_pb.OnConfirmEnterFubenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onConfirmEnterFubenPush(cb)
	Socket.On("area.fightLevelPush.onConfirmEnterFubenPush", function(res) 
		Pomelo.GameSocket.lastOnConfirmEnterFubenPush = res
		cb(nil,res) 
	end, onConfirmEnterFubenPushDecoder) 
end


local function onMemberEnterFubenStateChangePushDecoder(stream)
	local res = fightLevelHandler_pb.OnMemberEnterFubenStateChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onMemberEnterFubenStateChangePush(cb)
	Socket.On("area.fightLevelPush.onMemberEnterFubenStateChangePush", function(res) 
		Pomelo.GameSocket.lastOnMemberEnterFubenStateChangePush = res
		cb(nil,res) 
	end, onMemberEnterFubenStateChangePushDecoder) 
end


local function onFubenClosePushDecoder(stream)
	local res = fightLevelHandler_pb.OnFubenClosePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onFubenClosePush(cb)
	Socket.On("area.fightLevelPush.onFubenClosePush", function(res) 
		Pomelo.GameSocket.lastOnFubenClosePush = res
		cb(nil,res) 
	end, onFubenClosePushDecoder) 
end


local function closeHandUpPushDecoder(stream)
	local res = fightLevelHandler_pb.CloseHandUpPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.closeHandUpPush(cb)
	Socket.On("area.fightLevelPush.closeHandUpPush", function(res) 
		Pomelo.GameSocket.lastCloseHandUpPush = res
		cb(nil,res) 
	end, closeHandUpPushDecoder) 
end


local function illusionPushDecoder(stream)
	local res = fightLevelHandler_pb.IllusionPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.illusionPush(cb)
	Socket.On("area.fightLevelPush.illusionPush", function(res) 
		Pomelo.GameSocket.lastIllusionPush = res
		cb(nil,res) 
	end, illusionPushDecoder) 
end


local function illusion2PushDecoder(stream)
	local res = fightLevelHandler_pb.Illusion2Push()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.illusion2Push(cb)
	Socket.On("area.fightLevelPush.illusion2Push", function(res) 
		Pomelo.GameSocket.lastIllusion2Push = res
		cb(nil,res) 
	end, illusion2PushDecoder) 
end


local function onFleeDeathPushDecoder(stream)
	local res = fleeHandler_pb.OnFleeDeathPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onFleeDeathPush(cb)
	Socket.On("area.fleePush.onFleeDeathPush", function(res) 
		Pomelo.GameSocket.lastOnFleeDeathPush = res
		cb(nil,res) 
	end, onFleeDeathPushDecoder) 
end


local function onFleeEndPushDecoder(stream)
	local res = fleeHandler_pb.OnFleeEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onFleeEndPush(cb)
	Socket.On("area.fleePush.onFleeEndPush", function(res) 
		Pomelo.GameSocket.lastOnFleeEndPush = res
		cb(nil,res) 
	end, onFleeEndPushDecoder) 
end


local function functionGoToPushDecoder(stream)
	local res = functionHandler_pb.FunctionGoToPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.functionGoToPush(cb)
	Socket.On("area.functionPush.functionGoToPush", function(res) 
		Pomelo.GameSocket.lastFunctionGoToPush = res
		cb(nil,res) 
	end, functionGoToPushDecoder) 
end


local function taskGuideFuncPushDecoder(stream)
	local res = functionHandler_pb.TaskGuideFuncPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.taskGuideFuncPush(cb)
	Socket.On("area.functionPush.taskGuideFuncPush", function(res) 
		Pomelo.GameSocket.lastTaskGuideFuncPush = res
		cb(nil,res) 
	end, taskGuideFuncPushDecoder) 
end


local function functionOpenListPushDecoder(stream)
	local res = functionOpenHandler_pb.FunctionOpenListPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.functionOpenListPush(cb)
	Socket.On("area.functionOpenPush.functionOpenListPush", function(res) 
		Pomelo.GameSocket.lastFunctionOpenListPush = res
		cb(nil,res) 
	end, functionOpenListPushDecoder) 
end


local function functionAwardListPushDecoder(stream)
	local res = functionOpenHandler_pb.FunctionAwardListPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.functionAwardListPush(cb)
	Socket.On("area.functionOpenPush.functionAwardListPush", function(res) 
		Pomelo.GameSocket.lastFunctionAwardListPush = res
		cb(nil,res) 
	end, functionAwardListPushDecoder) 
end


local function goddessEquipDynamicPushDecoder(stream)
	local res = goddessHandler_pb.GoddessEquipDynamicPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.goddessEquipDynamicPush(cb)
	Socket.On("area.goddessPush.goddessEquipDynamicPush", function(res) 
		Pomelo.GameSocket.lastGoddessEquipDynamicPush = res
		cb(nil,res) 
	end, goddessEquipDynamicPushDecoder) 
end


local function goddessGiftDynamicPushDecoder(stream)
	local res = goddessHandler_pb.GoddessGiftDynamicPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.goddessGiftDynamicPush(cb)
	Socket.On("area.goddessPush.goddessGiftDynamicPush", function(res) 
		Pomelo.GameSocket.lastGoddessGiftDynamicPush = res
		cb(nil,res) 
	end, goddessGiftDynamicPushDecoder) 
end


local function blessRefreshPushDecoder(stream)
	local res = guildBlessHandler_pb.BlessRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.blessRefreshPush(cb)
	Socket.On("area.guildBlessPush.blessRefreshPush", function(res) 
		Pomelo.GameSocket.lastBlessRefreshPush = res
		cb(nil,res) 
	end, blessRefreshPushDecoder) 
end


local function onHurtRankChangePushDecoder(stream)
	local res = guildBossHandler_pb.OnHurtRankChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onHurtRankChangePush(cb)
	Socket.On("area.guildBossPush.onHurtRankChangePush", function(res) 
		Pomelo.GameSocket.lastOnHurtRankChangePush = res
		cb(nil,res) 
	end, onHurtRankChangePushDecoder) 
end


local function onInspireChangePushDecoder(stream)
	local res = guildBossHandler_pb.OnInspireChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onInspireChangePush(cb)
	Socket.On("area.guildBossPush.onInspireChangePush", function(res) 
		Pomelo.GameSocket.lastOnInspireChangePush = res
		cb(nil,res) 
	end, onInspireChangePushDecoder) 
end


local function onQuitGuildBossPushDecoder(stream)
	local res = guildBossHandler_pb.OnQuitGuildBossPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onQuitGuildBossPush(cb)
	Socket.On("area.guildBossPush.onQuitGuildBossPush", function(res) 
		Pomelo.GameSocket.lastOnQuitGuildBossPush = res
		cb(nil,res) 
	end, onQuitGuildBossPushDecoder) 
end


local function onEndGuildBossPushDecoder(stream)
	local res = guildBossHandler_pb.OnEndGuildBossPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onEndGuildBossPush(cb)
	Socket.On("area.guildBossPush.onEndGuildBossPush", function(res) 
		Pomelo.GameSocket.lastOnEndGuildBossPush = res
		cb(nil,res) 
	end, onEndGuildBossPushDecoder) 
end


local function depotRefreshPushDecoder(stream)
	local res = guildDepotHandler_pb.DepotRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.depotRefreshPush(cb)
	Socket.On("area.guildDepotPush.depotRefreshPush", function(res) 
		Pomelo.GameSocket.lastDepotRefreshPush = res
		cb(nil,res) 
	end, depotRefreshPushDecoder) 
end


local function onGuildFortPushDecoder(stream)
	local res = guildFortHandler_pb.OnGuildFortPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onGuildFortPush(cb)
	Socket.On("area.guildFortPush.onGuildFortPush", function(res) 
		Pomelo.GameSocket.lastOnGuildFortPush = res
		cb(nil,res) 
	end, onGuildFortPushDecoder) 
end


local function onGuildResultPushDecoder(stream)
	local res = guildFortHandler_pb.OnGuildResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onGuildResultPush(cb)
	Socket.On("area.guildFortPush.onGuildResultPush", function(res) 
		Pomelo.GameSocket.lastOnGuildResultPush = res
		cb(nil,res) 
	end, onGuildResultPushDecoder) 
end


local function guildRefreshPushDecoder(stream)
	local res = guildHandler_pb.GuildRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.guildRefreshPush(cb)
	Socket.On("area.guildPush.guildRefreshPush", function(res) 
		Pomelo.GameSocket.lastGuildRefreshPush = res
		cb(nil,res) 
	end, guildRefreshPushDecoder) 
end


local function guildInvitePushDecoder(stream)
	local res = guildHandler_pb.GuildInvitePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.guildInvitePush(cb)
	Socket.On("area.guildPush.guildInvitePush", function(res) 
		Pomelo.GameSocket.lastGuildInvitePush = res
		cb(nil,res) 
	end, guildInvitePushDecoder) 
end


local function onDungeonEndPushDecoder(stream)
	local res = guildHandler_pb.OnDungeonEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onDungeonEndPush(cb)
	Socket.On("area.guildPush.onDungeonEndPush", function(res) 
		Pomelo.GameSocket.lastOnDungeonEndPush = res
		cb(nil,res) 
	end, onDungeonEndPushDecoder) 
end


local function guildDungeonOpenPushDecoder(stream)
	local res = guildHandler_pb.GuildDungeonOpenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.guildDungeonOpenPush(cb)
	Socket.On("area.guildPush.guildDungeonOpenPush", function(res) 
		Pomelo.GameSocket.lastGuildDungeonOpenPush = res
		cb(nil,res) 
	end, guildDungeonOpenPushDecoder) 
end


local function guildDungeonPassPushDecoder(stream)
	local res = guildHandler_pb.GuildDungeonPassPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.guildDungeonPassPush(cb)
	Socket.On("area.guildPush.guildDungeonPassPush", function(res) 
		Pomelo.GameSocket.lastGuildDungeonPassPush = res
		cb(nil,res) 
	end, guildDungeonPassPushDecoder) 
end


local function guildDungeonPlayerNumPushDecoder(stream)
	local res = guildHandler_pb.GuildDungeonPlayerNumPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.guildDungeonPlayerNumPush(cb)
	Socket.On("area.guildPush.guildDungeonPlayerNumPush", function(res) 
		Pomelo.GameSocket.lastGuildDungeonPlayerNumPush = res
		cb(nil,res) 
	end, guildDungeonPlayerNumPushDecoder) 
end


local function shopRefreshPushDecoder(stream)
	local res = guildShopHandler_pb.ShopRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.shopRefreshPush(cb)
	Socket.On("area.guildShopPush.shopRefreshPush", function(res) 
		Pomelo.GameSocket.lastShopRefreshPush = res
		cb(nil,res) 
	end, shopRefreshPushDecoder) 
end


local function guildTechRefreshPushDecoder(stream)
	local res = guildTechHandler_pb.GuildTechRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.guildTechRefreshPush(cb)
	Socket.On("area.guildTechPush.guildTechRefreshPush", function(res) 
		Pomelo.GameSocket.lastGuildTechRefreshPush = res
		cb(nil,res) 
	end, guildTechRefreshPushDecoder) 
end


local function receiveInteractPushDecoder(stream)
	local res = interactHandler_pb.ReceiveInteractPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.receiveInteractPush(cb)
	Socket.On("area.interactPush.receiveInteractPush", function(res) 
		Pomelo.GameSocket.lastReceiveInteractPush = res
		cb(nil,res) 
	end, receiveInteractPushDecoder) 
end


local function fishItemPushDecoder(stream)
	local res = itemHandler_pb.FishItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.fishItemPush(cb)
	Socket.On("area.itemPush.fishItemPush", function(res) 
		Pomelo.GameSocket.lastFishItemPush = res
		cb(nil,res) 
	end, fishItemPushDecoder) 
end


local function countItemChangePushDecoder(stream)
	local res = itemHandler_pb.CountItemChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.countItemChangePush(cb)
	Socket.On("area.itemPush.countItemChangePush", function(res) 
		Pomelo.GameSocket.lastCountItemChangePush = res
		cb(nil,res) 
	end, countItemChangePushDecoder) 
end


local function itemDetailPushDecoder(stream)
	local res = itemHandler_pb.ItemDetailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.itemDetailPush(cb)
	Socket.On("area.itemPush.itemDetailPush", function(res) 
		Pomelo.GameSocket.lastItemDetailPush = res
		cb(nil,res) 
	end, itemDetailPushDecoder) 
end


local function rewardItemPushDecoder(stream)
	local res = itemHandler_pb.RewardItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.rewardItemPush(cb)
	Socket.On("area.itemPush.rewardItemPush", function(res) 
		Pomelo.GameSocket.lastRewardItemPush = res
		cb(nil,res) 
	end, rewardItemPushDecoder) 
end


local function ltActivityInfoPushDecoder(stream)
	local res = limitTimeActivityHandler_pb.LTActivityInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.ltActivityInfoPush(cb)
	Socket.On("area.limitTimeActivityPush.ltActivityInfoPush", function(res) 
		Pomelo.GameSocket.lastLTActivityInfoPush = res
		cb(nil,res) 
	end, ltActivityInfoPushDecoder) 
end


local function onGetMailPushDecoder(stream)
	local res = mailHandler_pb.OnGetMailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onGetMailPush(cb)
	Socket.On("area.mailPush.onGetMailPush", function(res) 
		Pomelo.GameSocket.lastOnGetMailPush = res
		cb(nil,res) 
	end, onGetMailPushDecoder) 
end


local function medalTitleChangePushDecoder(stream)
	local res = medalHandler_pb.MedalTitleChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.medalTitleChangePush(cb)
	Socket.On("area.medalPush.medalTitleChangePush", function(res) 
		Pomelo.GameSocket.lastMedalTitleChangePush = res
		cb(nil,res) 
	end, medalTitleChangePushDecoder) 
end


local function onMessageAddPushDecoder(stream)
	local res = messageHandler_pb.OnMessageAddPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onMessageAddPush(cb)
	Socket.On("area.messagePush.onMessageAddPush", function(res) 
		Pomelo.GameSocket.lastOnMessageAddPush = res
		cb(nil,res) 
	end, onMessageAddPushDecoder) 
end


local function mountFlagPushDecoder(stream)
	local res = mountHandler_pb.MountFlagPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.mountFlagPush(cb)
	Socket.On("area.mountPush.mountFlagPush", function(res) 
		Pomelo.GameSocket.lastMountFlagPush = res
		cb(nil,res) 
	end, mountFlagPushDecoder) 
end


local function mountNewSkinPushDecoder(stream)
	local res = mountHandler_pb.MountNewSkinPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.mountNewSkinPush(cb)
	Socket.On("area.mountPush.mountNewSkinPush", function(res) 
		Pomelo.GameSocket.lastMountNewSkinPush = res
		cb(nil,res) 
	end, mountNewSkinPushDecoder) 
end


local function giftInfoPushDecoder(stream)
	local res = onlineGiftHandler_pb.GiftInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.giftInfoPush(cb)
	Socket.On("area.onlineGiftPush.giftInfoPush", function(res) 
		Pomelo.GameSocket.lastGiftInfoPush = res
		cb(nil,res) 
	end, giftInfoPushDecoder) 
end


local function onPetDetailPushDecoder(stream)
	local res = petHandler_pb.OnPetDetailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onPetDetailPush(cb)
	Socket.On("area.petPush.onPetDetailPush", function(res) 
		Pomelo.GameSocket.lastOnPetDetailPush = res
		cb(nil,res) 
	end, onPetDetailPushDecoder) 
end


local function onPetExpPushDecoder(stream)
	local res = petHandler_pb.OnPetExpPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onPetExpPush(cb)
	Socket.On("area.petPush.onPetExpPush", function(res) 
		Pomelo.GameSocket.lastOnPetExpPush = res
		cb(nil,res) 
	end, onPetExpPushDecoder) 
end


local function onNewPetDetailPushDecoder(stream)
	local res = petNewHandler_pb.OnNewPetDetailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onNewPetDetailPush(cb)
	Socket.On("area.petNewPush.onNewPetDetailPush", function(res) 
		Pomelo.GameSocket.lastOnNewPetDetailPush = res
		cb(nil,res) 
	end, onNewPetDetailPushDecoder) 
end


local function petExpUpdatePushDecoder(stream)
	local res = petNewHandler_pb.PetExpUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.petExpUpdatePush(cb)
	Socket.On("area.petNewPush.petExpUpdatePush", function(res) 
		Pomelo.GameSocket.lastPetExpUpdatePush = res
		cb(nil,res) 
	end, petExpUpdatePushDecoder) 
end


local function petInfoUpdatePushDecoder(stream)
	local res = petNewHandler_pb.PetInfoUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.petInfoUpdatePush(cb)
	Socket.On("area.petNewPush.petInfoUpdatePush", function(res) 
		Pomelo.GameSocket.lastPetInfoUpdatePush = res
		cb(nil,res) 
	end, petInfoUpdatePushDecoder) 
end


local function clientConfigPushDecoder(stream)
	local res = playerHandler_pb.ClientConfigPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.clientConfigPush(cb)
	Socket.On("area.playerPush.clientConfigPush", function(res) 
		Pomelo.GameSocket.lastClientConfigPush = res
		cb(nil,res) 
	end, clientConfigPushDecoder) 
end


local function battleEventPushDecoder(stream)
	local res = playerHandler_pb.BattleEventPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.battleEventPush(cb)
	Socket.On("area.playerPush.battleEventPush", function(res) 
		Pomelo.GameSocket.lastBattleEventPush = res
		cb(nil,res) 
	end, battleEventPushDecoder) 
end


local function battleClearPushDecoder(stream)
	local res = playerHandler_pb.BattleClearPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.battleClearPush(cb)
	Socket.On("area.playerPush.battleClearPush", function(res) 
		Pomelo.GameSocket.lastBattleClearPush = res
		cb(nil,res) 
	end, battleClearPushDecoder) 
end


local function onSuperScriptPushDecoder(stream)
	local res = playerHandler_pb.SuperScriptPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onSuperScriptPush(cb)
	Socket.On("area.playerPush.onSuperScriptPush", function(res) 
		Pomelo.GameSocket.lastSuperScriptPush = res
		cb(nil,res) 
	end, onSuperScriptPushDecoder) 
end


local function changeAreaPushDecoder(stream)
	local res = playerHandler_pb.ChangeAreaPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.changeAreaPush(cb)
	Socket.On("area.playerPush.changeAreaPush", function(res) 
		Pomelo.GameSocket.lastChangeAreaPush = res
		cb(nil,res) 
	end, changeAreaPushDecoder) 
end


local function playerDynamicPushDecoder(stream)
	local res = playerHandler_pb.PlayerDynamicPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.playerDynamicPush(cb)
	Socket.On("area.playerPush.playerDynamicPush", function(res) 
		Pomelo.GameSocket.lastPlayerDynamicPush = res
		cb(nil,res) 
	end, playerDynamicPushDecoder) 
end


local function playerRelivePushDecoder(stream)
	local res = playerHandler_pb.PlayerRelivePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.playerRelivePush(cb)
	Socket.On("area.playerPush.playerRelivePush", function(res) 
		Pomelo.GameSocket.lastPlayerRelivePush = res
		cb(nil,res) 
	end, playerRelivePushDecoder) 
end


local function playerSaverRebirthPushDecoder(stream)
	local res = playerHandler_pb.PlayerSaverRebirthPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.playerSaverRebirthPush(cb)
	Socket.On("area.playerPush.playerSaverRebirthPush", function(res) 
		Pomelo.GameSocket.lastPlayerSaverRebirthPush = res
		cb(nil,res) 
	end, playerSaverRebirthPushDecoder) 
end


local function simulateDropPushDecoder(stream)
	local res = playerHandler_pb.SimulateDataPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.simulateDropPush(cb)
	Socket.On("area.playerPush.simulateDropPush", function(res) 
		Pomelo.GameSocket.lastSimulateDataPush = res
		cb(nil,res) 
	end, simulateDropPushDecoder) 
end


local function kickPlayerPushDecoder(stream)
	local res = playerHandler_pb.KickPlayerPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.kickPlayerPush(cb)
	Socket.On("area.playerPush.kickPlayerPush", function(res) 
		Pomelo.GameSocket.lastKickPlayerPush = res
		cb(nil,res) 
	end, kickPlayerPushDecoder) 
end


local function suitPropertyUpPushDecoder(stream)
	local res = playerHandler_pb.SuitPropertyUpPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.suitPropertyUpPush(cb)
	Socket.On("area.playerPush.suitPropertyUpPush", function(res) 
		Pomelo.GameSocket.lastSuitPropertyUpPush = res
		cb(nil,res) 
	end, suitPropertyUpPushDecoder) 
end


local function commonPropertyPushDecoder(stream)
	local res = playerHandler_pb.CommonPropertyPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.commonPropertyPush(cb)
	Socket.On("area.playerPush.commonPropertyPush", function(res) 
		Pomelo.GameSocket.lastCommonPropertyPush = res
		cb(nil,res) 
	end, commonPropertyPushDecoder) 
end


local function buffPropertyPushDecoder(stream)
	local res = playerHandler_pb.BuffPropertyPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.buffPropertyPush(cb)
	Socket.On("area.playerPush.buffPropertyPush", function(res) 
		Pomelo.GameSocket.lastBuffPropertyPush = res
		cb(nil,res) 
	end, buffPropertyPushDecoder) 
end


local function playerBattleAttributePushDecoder(stream)
	local res = playerHandler_pb.PlayerBattleAttributePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.playerBattleAttributePush(cb)
	Socket.On("area.playerPush.playerBattleAttributePush", function(res) 
		Pomelo.GameSocket.lastPlayerBattleAttributePush = res
		cb(nil,res) 
	end, playerBattleAttributePushDecoder) 
end


local function payGiftStatePushDecoder(stream)
	local res = playerHandler_pb.PayGiftStatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.payGiftStatePush(cb)
	Socket.On("area.playerPush.payGiftStatePush", function(res) 
		Pomelo.GameSocket.lastPayGiftStatePush = res
		cb(nil,res) 
	end, payGiftStatePushDecoder) 
end


local function onAwardRankPushDecoder(stream)
	local res = rankHandler_pb.OnAwardRankPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onAwardRankPush(cb)
	Socket.On("area.rankPush.onAwardRankPush", function(res) 
		Pomelo.GameSocket.lastOnAwardRankPush = res
		cb(nil,res) 
	end, onAwardRankPushDecoder) 
end


local function skillUpdatePushDecoder(stream)
	local res = skillHandler_pb.SkillUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.skillUpdatePush(cb)
	Socket.On("area.skillPush.skillUpdatePush", function(res) 
		Pomelo.GameSocket.lastSkillUpdatePush = res
		cb(nil,res) 
	end, skillUpdatePushDecoder) 
end


local function skillKeyUpdatePushDecoder(stream)
	local res = skillKeysHandler_pb.SkillKeyUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.skillKeyUpdatePush(cb)
	Socket.On("area.skillKeysPush.skillKeyUpdatePush", function(res) 
		Pomelo.GameSocket.lastSkillKeyUpdatePush = res
		cb(nil,res) 
	end, skillKeyUpdatePushDecoder) 
end


local function onSoloMatchedPushDecoder(stream)
	local res = soloHandler_pb.OnSoloMatchedPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onSoloMatchedPush(cb)
	Socket.On("area.soloPush.onSoloMatchedPush", function(res) 
		Pomelo.GameSocket.lastOnSoloMatchedPush = res
		cb(nil,res) 
	end, onSoloMatchedPushDecoder) 
end


local function onNewRewardPushDecoder(stream)
	local res = soloHandler_pb.OnNewRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onNewRewardPush(cb)
	Socket.On("area.soloPush.onNewRewardPush", function(res) 
		Pomelo.GameSocket.lastOnNewRewardPush = res
		cb(nil,res) 
	end, onNewRewardPushDecoder) 
end


local function onFightPointPushDecoder(stream)
	local res = soloHandler_pb.OnFightPointPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onFightPointPush(cb)
	Socket.On("area.soloPush.onFightPointPush", function(res) 
		Pomelo.GameSocket.lastOnFightPointPush = res
		cb(nil,res) 
	end, onFightPointPushDecoder) 
end


local function onRoundEndPushDecoder(stream)
	local res = soloHandler_pb.OnRoundEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onRoundEndPush(cb)
	Socket.On("area.soloPush.onRoundEndPush", function(res) 
		Pomelo.GameSocket.lastOnRoundEndPush = res
		cb(nil,res) 
	end, onRoundEndPushDecoder) 
end


local function onGameEndPushDecoder(stream)
	local res = soloHandler_pb.OnGameEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onGameEndPush(cb)
	Socket.On("area.soloPush.onGameEndPush", function(res) 
		Pomelo.GameSocket.lastOnGameEndPush = res
		cb(nil,res) 
	end, onGameEndPushDecoder) 
end


local function leftSoloTimePushDecoder(stream)
	local res = soloHandler_pb.LeftSoloTimePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.leftSoloTimePush(cb)
	Socket.On("area.soloPush.leftSoloTimePush", function(res) 
		Pomelo.GameSocket.lastLeftSoloTimePush = res
		cb(nil,res) 
	end, leftSoloTimePushDecoder) 
end


local function cancelMatchPushDecoder(stream)
	local res = soloHandler_pb.CancelMatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.cancelMatchPush(cb)
	Socket.On("area.soloPush.cancelMatchPush", function(res) 
		Pomelo.GameSocket.lastCancelMatchPush = res
		cb(nil,res) 
	end, cancelMatchPushDecoder) 
end


local function taskUpdatePushDecoder(stream)
	local res = taskHandler_pb.TaskUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.taskUpdatePush(cb)
	Socket.On("area.taskPush.taskUpdatePush", function(res) 
		Pomelo.GameSocket.lastTaskUpdatePush = res
		cb(nil,res) 
	end, taskUpdatePushDecoder) 
end


local function taskAutoPushDecoder(stream)
	local res = taskHandler_pb.TaskAutoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.taskAutoPush(cb)
	Socket.On("area.taskPush.taskAutoPush", function(res) 
		Pomelo.GameSocket.lastTaskAutoPush = res
		cb(nil,res) 
	end, taskAutoPushDecoder) 
end


local function treasureScenePointPushDecoder(stream)
	local res = taskHandler_pb.TreasureScenePointPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.treasureScenePointPush(cb)
	Socket.On("area.taskPush.treasureScenePointPush", function(res) 
		Pomelo.GameSocket.lastTreasureScenePointPush = res
		cb(nil,res) 
	end, treasureScenePointPushDecoder) 
end


local function loopResultPushDecoder(stream)
	local res = taskHandler_pb.LoopResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.loopResultPush(cb)
	Socket.On("area.taskPush.loopResultPush", function(res) 
		Pomelo.GameSocket.lastLoopResultPush = res
		cb(nil,res) 
	end, loopResultPushDecoder) 
end


local function onSummonTeamPushDecoder(stream)
	local res = teamHandler_pb.OnSummonTeamPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onSummonTeamPush(cb)
	Socket.On("area.teamPush.onSummonTeamPush", function(res) 
		Pomelo.GameSocket.lastOnSummonTeamPush = res
		cb(nil,res) 
	end, onSummonTeamPushDecoder) 
end


local function onTeamUpdatePushDecoder(stream)
	local res = teamHandler_pb.OnTeamUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onTeamUpdatePush(cb)
	Socket.On("area.teamPush.onTeamUpdatePush", function(res) 
		Pomelo.GameSocket.lastOnTeamUpdatePush = res
		cb(nil,res) 
	end, onTeamUpdatePushDecoder) 
end


local function onTeamMemberUpdatePushDecoder(stream)
	local res = teamHandler_pb.OnTeamMemberUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onTeamMemberUpdatePush(cb)
	Socket.On("area.teamPush.onTeamMemberUpdatePush", function(res) 
		Pomelo.GameSocket.lastOnTeamMemberUpdatePush = res
		cb(nil,res) 
	end, onTeamMemberUpdatePushDecoder) 
end


local function onTeamTargetPushDecoder(stream)
	local res = teamHandler_pb.OnTeamTargetPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onTeamTargetPush(cb)
	Socket.On("area.teamPush.onTeamTargetPush", function(res) 
		Pomelo.GameSocket.lastOnTeamTargetPush = res
		cb(nil,res) 
	end, onTeamTargetPushDecoder) 
end


local function onAcrossTeamInfoPushDecoder(stream)
	local res = teamHandler_pb.OnAcrossTeamInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onAcrossTeamInfoPush(cb)
	Socket.On("area.teamPush.onAcrossTeamInfoPush", function(res) 
		Pomelo.GameSocket.lastOnAcrossTeamInfoPush = res
		cb(nil,res) 
	end, onAcrossTeamInfoPushDecoder) 
end


local function onTeamMumberHurtPushDecoder(stream)
	local res = teamHandler_pb.OnTeamMumberHurtPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onTeamMumberHurtPush(cb)
	Socket.On("area.teamPush.onTeamMumberHurtPush", function(res) 
		Pomelo.GameSocket.lastOnTeamMumberHurtPush = res
		cb(nil,res) 
	end, onTeamMumberHurtPushDecoder) 
end


local function tradeBeginPushDecoder(stream)
	local res = tradeHandler_pb.TradeBeginPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.tradeBeginPush(cb)
	Socket.On("area.tradePush.tradeBeginPush", function(res) 
		Pomelo.GameSocket.lastTradeBeginPush = res
		cb(nil,res) 
	end, tradeBeginPushDecoder) 
end


local function tradeItemChangePushDecoder(stream)
	local res = tradeHandler_pb.TradeItemChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.tradeItemChangePush(cb)
	Socket.On("area.tradePush.tradeItemChangePush", function(res) 
		Pomelo.GameSocket.lastTradeItemChangePush = res
		cb(nil,res) 
	end, tradeItemChangePushDecoder) 
end


local function tradeOperatePushDecoder(stream)
	local res = tradeHandler_pb.TradeOperatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.tradeOperatePush(cb)
	Socket.On("area.tradePush.tradeOperatePush", function(res) 
		Pomelo.GameSocket.lastTradeOperatePush = res
		cb(nil,res) 
	end, tradeOperatePushDecoder) 
end


local function auctionItemPushDecoder(stream)
	local res = auctionHandler_pb.AuctionItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.auctionItemPush(cb)
	Socket.On("auction.auctionPush.auctionItemPush", function(res) 
		Pomelo.GameSocket.lastAuctionItemPush = res
		cb(nil,res) 
	end, auctionItemPushDecoder) 
end


local function addAuctionItemPushDecoder(stream)
	local res = auctionHandler_pb.AddAuctionItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.addAuctionItemPush(cb)
	Socket.On("auction.auctionPush.addAuctionItemPush", function(res) 
		Pomelo.GameSocket.lastAddAuctionItemPush = res
		cb(nil,res) 
	end, addAuctionItemPushDecoder) 
end


local function removeAuctionItemPushDecoder(stream)
	local res = auctionHandler_pb.RemoveAuctionItemPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.removeAuctionItemPush(cb)
	Socket.On("auction.auctionPush.removeAuctionItemPush", function(res) 
		Pomelo.GameSocket.lastRemoveAuctionItemPush = res
		cb(nil,res) 
	end, removeAuctionItemPushDecoder) 
end


local function onChatPushDecoder(stream)
	local res = chatHandler_pb.OnChatPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onChatPush(cb)
	Socket.On("chat.chatPush.onChatPush", function(res) 
		Pomelo.GameSocket.lastOnChatPush = res
		cb(nil,res) 
	end, onChatPushDecoder) 
end


local function onChatErrorPushDecoder(stream)
	local res = chatHandler_pb.OnChatErrorPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onChatErrorPush(cb)
	Socket.On("chat.chatPush.onChatErrorPush", function(res) 
		Pomelo.GameSocket.lastOnChatErrorPush = res
		cb(nil,res) 
	end, onChatErrorPushDecoder) 
end


local function tipPushDecoder(stream)
	local res = chatHandler_pb.TipPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.tipPush(cb)
	Socket.On("chat.chatPush.tipPush", function(res) 
		Pomelo.GameSocket.lastTipPush = res
		cb(nil,res) 
	end, tipPushDecoder) 
end


local function loginQueuePushDecoder(stream)
	local res = entryHandler_pb.LoginQueuePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.loginQueuePush(cb)
	Socket.On("connector.entryPush.loginQueuePush", function(res) 
		Pomelo.GameSocket.lastLoginQueuePush = res
		cb(nil,res) 
	end, loginQueuePushDecoder) 
end


local function five2FiveApplyMatchPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveApplyMatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveApplyMatchPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveApplyMatchPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveApplyMatchPush = res
		cb(nil,res) 
	end, five2FiveApplyMatchPushDecoder) 
end


local function five2FiveMatchMemberInfoPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchMemberInfoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveMatchMemberInfoPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMatchMemberInfoPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveMatchMemberInfoPush = res
		cb(nil,res) 
	end, five2FiveMatchMemberInfoPushDecoder) 
end


local function five2FiveMemberChoicePushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMemberChoicePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveMemberChoicePush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMemberChoicePush", function(res) 
		Pomelo.GameSocket.lastFive2FiveMemberChoicePush = res
		cb(nil,res) 
	end, five2FiveMemberChoicePushDecoder) 
end


local function five2FiveOnGameEndPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveOnGameEndPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveOnGameEndPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveOnGameEndPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveOnGameEndPush = res
		cb(nil,res) 
	end, five2FiveOnGameEndPushDecoder) 
end


local function five2FiveOnNewRewardPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveOnNewRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveOnNewRewardPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveOnNewRewardPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveOnNewRewardPush = res
		cb(nil,res) 
	end, five2FiveOnNewRewardPushDecoder) 
end


local function five2FiveOnNoRewardPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveOnNoRewardPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveOnNoRewardPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveOnNoRewardPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveOnNoRewardPush = res
		cb(nil,res) 
	end, five2FiveOnNoRewardPushDecoder) 
end


local function five2FiveMatchFailedPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchFailedPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveMatchFailedPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMatchFailedPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveMatchFailedPush = res
		cb(nil,res) 
	end, five2FiveMatchFailedPushDecoder) 
end


local function five2FiveLeaderCancelMatchPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveLeaderCancelMatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveLeaderCancelMatchPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveLeaderCancelMatchPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveLeaderCancelMatchPush = res
		cb(nil,res) 
	end, five2FiveLeaderCancelMatchPushDecoder) 
end


local function five2FiveTeamChangePushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveTeamChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveTeamChangePush(cb)
	Socket.On("five2five.five2FivePush.five2FiveTeamChangePush", function(res) 
		Pomelo.GameSocket.lastFive2FiveTeamChangePush = res
		cb(nil,res) 
	end, five2FiveTeamChangePushDecoder) 
end


local function five2FiveMatchPoolChangePushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveMatchPoolChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveMatchPoolChangePush(cb)
	Socket.On("five2five.five2FivePush.five2FiveMatchPoolChangePush", function(res) 
		Pomelo.GameSocket.lastFive2FiveMatchPoolChangePush = res
		cb(nil,res) 
	end, five2FiveMatchPoolChangePushDecoder) 
end


local function five2FiveApplyMatchResultPushDecoder(stream)
	local res = five2FiveHandler_pb.Five2FiveApplyMatchResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.five2FiveApplyMatchResultPush(cb)
	Socket.On("five2five.five2FivePush.five2FiveApplyMatchResultPush", function(res) 
		Pomelo.GameSocket.lastFive2FiveApplyMatchResultPush = res
		cb(nil,res) 
	end, five2FiveApplyMatchResultPushDecoder) 
end


local function onRedPacketDispatchPushDecoder(stream)
	local res = redPacketHandler_pb.OnRedPacketDispatchPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GameSocket.onRedPacketDispatchPush(cb)
	Socket.On("redpacket.redPacketPush.onRedPacketDispatchPush", function(res) 
		Pomelo.GameSocket.lastOnRedPacketDispatchPush = res
		cb(nil,res) 
	end, onRedPacketDispatchPushDecoder) 
end





return Pomelo
