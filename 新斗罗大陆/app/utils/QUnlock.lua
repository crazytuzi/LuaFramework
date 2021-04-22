--
-- Author: Your Name
-- Date: 2015-06-29 16:01:33
--
local QUnlock = class("QUnlock")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")

--临时测试的解锁key
QUnlock.TEMP_CONFIG = {}
-- QUnlock.TEMP_CONFIG["UNLOCK_BLACKROCK"] = {key = "UNLOCK_BLACKROCK", name = "黑石山", team_level = 50, description = "黑石山解锁，这是程序配置"}
QUnlock.TEMP_CONFIG["UNLOCK_ARTIFACT"] = {key = "UNLOCK_ARTIFACT", name = "武魂真身", team_level = 60, hero_level = 50, description = "武魂真身解锁，这是程序配置"}


function QUnlock:ctor(options)
	-- body
	self._config = QStaticDatabase:sharedDatabase():getUnlock()
	self._vipConfig = QStaticDatabase:sharedDatabase():getVIP()
end

--检查等级
function QUnlock:checkLevelUnlock(condition)
	if condition == nil then return true end
	return tonumber(condition) <= (remote.user.level or 0)
end

--检查副本
function QUnlock:checkDungeonUnlock(condition)
	if condition == nil then return true end
	return remote.instance:checkIsPassByDungeonId(condition)
end

--检查VIP
function QUnlock:checkVIPUnlock(condition)
	if condition == nil then return true end
	return QVIPUtil:VIPLevel() >= condition
end

--检查是否打过副本
function QUnlock:checkDungeonFightUnlock(condition)
	if condition == nil then return true end
	return remote.instance:getDungeonById(condition).info ~= nil
end

--检查宗门等级
function QUnlock:checkUnionLevelUnlock(condition)
	if condition == nil then return true end

	if remote.user.userConsortia == nil or next(remote.user.userConsortia) == nil 
		or remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "" then
		return false
	end

	return tonumber(condition) <= (remote.union.consortia.level or 0)
end

--检查VIP
function QUnlock:checkBattleForce(condition)
	if condition == nil then return true end
    local battleForce = remote.user:getTopNForce()
	return battleForce >= condition
end

--提示副本解锁
function QUnlock:tipsDungeon(value, vip, tips)
	local dungeonInfo = remote.instance:getDungeonById(value.dungeon)
	if tips == nil then
		if vip ~= nil then
			local text = "该功能，VIP达到"..vip.."级或通关副本"..dungeonInfo.number.."后可开启，是否前往充值提升VIP等级？"
			app:vipAlert({content=text}, false)
	    else
    		app.tip:floatTip(string.format("%s将在通关副本%s后开启，魂师大人努力提升自己吧！", value.name, dungeonInfo.number))
	    end
    else
		if vip ~= nil then
			app:vipAlert({content=string.format(tips,vip,dungeonInfo.number)}, false)
	    else
    		app.tip:floatTip(string.format(tips,dungeonInfo.number))
	    end
    end
end

--提示等级解锁
function QUnlock:tipsLevel(value, vip, tips)
	if tips == nil then
		if vip ~= nil then
			local text = "该功能，VIP达到"..vip.."级或等级达到"..value.team_level.."级后可开启，是否前往充值提升VIP等级？"
			app:vipAlert({content=text}, false)
	    else
    		app.tip:floatTip(string.format("%s将在%s级开启，魂师大人努力提升自己吧！", value.name, value.team_level))
	    end
    else
		if vip ~= nil then
			app:vipAlert({content=string.format(tips, vip, value.team_level)}, false)
	    else
    		app.tip:floatTip(string.format(tips, value.team_level))
	    end
    end
end

--提示宗门等级解锁
function QUnlock:tipsUnionLevel(value, vip, tips)
	if tips == nil then
		if vip ~= nil then
			local text = "该功能，VIP达到"..vip.."级或宗门等级达到"..value.sociaty_level.."级后可开启，是否前往充值提升VIP等级？"
			app:vipAlert({content=text}, false)
	    else
    		app.tip:floatTip(string.format("%s将在宗门等级%s级开启，魂师大人努力提升宗门等级吧！", value.name, value.sociaty_level))
	    end
    else
		if vip ~= nil then
			app:vipAlert({content=string.format(tips, vip, value.sociaty_level)}, false)
	    else
    		app.tip:floatTip(string.format(tips, value.sociaty_level))
	    end
    end
end

--提示等级解锁
function QUnlock:tipsLevelNew(value, vip, tips)
	if tips == nil then
		if vip ~= nil then
			local text = "魂师大人，##e"..(value.name or "").. "##n功能将会在等级达到##e"..value.team_level.."级##n后开启"
			app:vipAlert({content=text, showVipLevel = vip}, false)
	    else
    		app.tip:floatTip(string.format("%s将在%s级开启，魂师大人努力提升自己吧！", value.name, value.team_level))
	    end
    else
		if vip ~= nil then
			app:vipAlert({content=string.format(tips, vip, value.team_level)}, false)
	    else
    		app.tip:floatTip(string.format(tips, value.team_level))
	    end
    end
end


function QUnlock:getConfigByKey(key)
	if self._config[key] ~= nil then
		return self._config[key]
	end
	if self.TEMP_CONFIG[key] ~= nil then
		return self.TEMP_CONFIG[key]
	end
	return nil
end

--检查等级解锁
function QUnlock:checkUnlockByLevel(oldLevel, newLevel)
	for _,value in pairs(self._config) do
		if value.team_level ~= nil and value.team_level > oldLevel and value.team_level <= newLevel then
			self:unlockHandler(value)
		end
	end
end

--当有解锁被动发生时调用
function QUnlock:unlockHandler(config)
	if config.key == "UNLOCK_BADGE" then
		remote.herosUtil:unlockBadge()
	elseif config.key == "UNLOCK_GAD" then
		remote.herosUtil:unlockGad()
	elseif config.key == "UNLOCK_FRIEND" then
		remote.friend:initRequest()
	end
end

--检查是否解锁根据key
function QUnlock:checkLock(key, isTips, tips)
	local isUnlock = true                 -- 默认解锁
	local config = self:getConfigByKey(key)

	if config == nil then return isUnlock end

	--检查VIP是否解锁
	if config.vip_level ~= nil then
		isUnlock = self:checkVIPUnlock(config.vip_level)
		if isUnlock == true then return true end
	end

	--检查VIP等级是否解锁
	if config.need_vip ~= nil then
		isUnlock = self:checkVIPUnlock(config.need_vip)
		if isTips == true and isUnlock == false then
			self:tipsVip(config, config.vip_level, tips)
		end
		if isUnlock == false then return false end
	end

	--检查战队等级是否解锁
	if config.team_level ~= nil then
		isUnlock = self:checkLevelUnlock(config.team_level)
		if isTips == true and isUnlock == false then
			self:tipsLevel(config, config.vip_level, tips)
		end
		if isUnlock == false then return false end
	end

	--检查副本是否解锁
	if config.dungeon ~= nil then
		isUnlock = self:checkDungeonUnlock(config.dungeon)
		if isTips == true and isUnlock == false then
			self:tipsDungeon(config, config.vip_level, tips)
		end
		if isUnlock == false then return false end
	end

	--检查宗门等级是否解锁
	if config.sociaty_level ~= nil then
		isUnlock = self:checkUnionLevelUnlock(config.sociaty_level)
		if isTips == true and isUnlock == false then
			self:tipsUnionLevel(config, config.vip_level, tips)
		end
		if isUnlock == false then return false end
	end

	--检查战力是否解锁
	if config.force ~= nil then
		isUnlock = self:checkBattleForce(config.force)
		if isTips == true and isUnlock == false then
			self:tipsBattleForce(config, config.vip_level, tips)
		end
		if isUnlock == false then return false end
	end

	return isUnlock
end

--提示解锁
function QUnlock:tipsLock(key, title, newLayout)
	local config = self:getConfigByKey(key)
	if config == nil then return end
	local tips = nil
	if config.vip_level ~= nil then
		if config.team_level ~= nil then
			if newLayout then
				self:tipsLevelNew(config, config.vip_level, tips)
			else
				tips = title.."功能，VIP达到%s级或等级达到%s级后可开启，是否前往充值提升VIP等级？"
				self:tipsLevel(config, config.vip_level, tips)
			end
			return
		end
		if config.dungeon ~= nil then
			tips = title.."功能，VIP达到%s级或通关副本%s后可开启，是否前往充值提升VIP等级？"
			self:tipsDungeon(config, config.vip_level, tips)
			return
		end
		if config.sociaty_level ~= nil then
			tips = title.."功能，VIP达到%s级或宗门等级达到%s级后可开启，是否前往充值提升VIP等级？"
			self:tipsUnionLevel(config, config.vip_level, tips)
			return
		end
	else
		if config.team_level ~= nil then
			self:tipsLevel(config, config.vip_level, tips)
			return
		end
		if config.dungeon ~= nil then
			self:tipsDungeon(config, config.vip_level, tips)
			return
		end
		if config.sociaty_level ~= nil then
			self:tipsUnionLevel(config, config.vip_level, tips)
			return
		end
	end
end

--战队第二个格子解锁
function QUnlock:getUnlockTeam2(isTips, tips)
	return self:checkLock("UNLOCK_THE_SECOND", isTips, tips)
end

--战队第三个格子解锁
function QUnlock:getUnlockTeam3(isTips, tips)
	return self:checkLock("UNLOCK_THE_THIRD", isTips, tips)
end

--战队第四个格子解锁
function QUnlock:getUnlockTeam4(isTips, tips)
	return self:checkLock("UNLOCK_THE_FOURTH", isTips, tips)
end

--战队援助第一个格子解锁
function QUnlock:getUnlockTeamHelp1(isTips, tips)
	return self:checkLock("UNLOCK_HELP_1", isTips, tips)
end

--战队援助第二个格子解锁
function QUnlock:getUnlockTeamHelp2(isTips, tips)
	return self:checkLock("UNLOCK_HELP_2", isTips, tips)
end

--战队援助第三个格子解锁
function QUnlock:getUnlockTeamHelp3(isTips, tips)
	return self:checkLock("UNLOCK_HELP_3", isTips, tips)
end

--战队援助第四个格子解锁
function QUnlock:getUnlockTeamHelp4(isTips, tips)
	return self:checkLock("UNLOCK_HELP_4", isTips, tips)
end

--战队援助第五个格子解锁
function QUnlock:getUnlockTeamHelp5(isTips, tips)
	return self:checkLock("UNLOCK_HELP_5", isTips, tips)
end

--战队援助第六个格子解锁
function QUnlock:getUnlockTeamHelp6(isTips, tips)
	return self:checkLock("UNLOCK_HELP_6", isTips, tips)
end

--战队援助第七个格子解锁
function QUnlock:getUnlockTeamHelp7(isTips, tips)
	return self:checkLock("UNLOCK_HELP_7", isTips, tips)
end

--战队援助第八个格子解锁
function QUnlock:getUnlockTeamHelp8(isTips, tips)
	return self:checkLock("UNLOCK_HELP_8", isTips, tips)
end

--战队援助第9个格子解锁
function QUnlock:getUnlockTeamHelp9(isTips, tips)
	return self:checkLock("UNLOCK_HELP_9", isTips, tips)
end

--战队援助第10个格子解锁
function QUnlock:getUnlockTeamHelp10(isTips, tips)
	return self:checkLock("UNLOCK_HELP_10", isTips, tips)
end

--战队援助第11个格子解锁
function QUnlock:getUnlockTeamHelp11(isTips, tips)
	return self:checkLock("UNLOCK_HELP_11", isTips, tips)
end

--战队援助第12个格子解锁
function QUnlock:getUnlockTeamHelp12(isTips, tips)
	return self:checkLock("UNLOCK_HELP_12", isTips, tips)
end

--获取援助位解锁数量
function QUnlock:getUnlockTeamHelpNum(isRefash)
	if self._teamHelpNum and not isRefash then
		return self._teamHelpNum
	end

	self._teamHelpNum = 0
	local index = 1
	local key = nil
	while true do
		key = "UNLOCK_HELP_" .. index
		if not self:getConfigByKey(key) then
			break
		else
			index = index + 1
		end

		if self:checkLock(key) then
			self._teamHelpNum = self._teamHelpNum + 1
		else
			break
		end
	end
	return self._teamHelpNum
end

--替补战队援助第1个格子解锁
function QUnlock:getUnlockTeamAlternateHelp1(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_1", isTips, tips)
end

--替补战队援助第2个格子解锁
function QUnlock:getUnlockTeamAlternateHelp2(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_2", isTips, tips)
end

--替补战队援助第3个格子解锁
function QUnlock:getUnlockTeamAlternateHelp3(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_3", isTips, tips)
end

--替补战队援助第4个格子解锁
function QUnlock:getUnlockTeamAlternateHelp4(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_4", isTips, tips)
end

--替补战队援助第5个格子解锁
function QUnlock:getUnlockTeamAlternateHelp5(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_5", isTips, tips)
end

--替补战队援助第6个格子解锁
function QUnlock:getUnlockTeamAlternateHelp6(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_6", isTips, tips)
end

--替补战队援助第7个格子解锁
function QUnlock:getUnlockTeamAlternateHelp7(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_7", isTips, tips)
end

--替补战队援助第8个格子解锁
function QUnlock:getUnlockTeamAlternateHelp8(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_8", isTips, tips)
end

--替补战队援助第9个格子解锁
function QUnlock:getUnlockTeamAlternateHelp9(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM_9", isTips, tips)
end

--替补战队援助第10个格子解锁
function QUnlock:getUnlockTeamAlternateHelp10(isTips, tips)
	return false
end

--神器上阵第一个格子
function QUnlock:getUnlockTeamGodarmHelp1(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_1_1", isTips, tips)
end

--神器上阵第二个格子
function QUnlock:getUnlockTeamGodarmHelp2(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_1_2", isTips, tips)
end

--神器上阵第三个格子
function QUnlock:getUnlockTeamGodarmHelp3(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_1_3", isTips, tips)
end

--神器上阵第四个格子
function QUnlock:getUnlockTeamGodarmHelp4(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_1_4", isTips, tips)
end

--神器上阵第一个格子
function QUnlock:getUnlockTeam2GodarmHelp1(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_2_1", isTips, tips)
end

--神器上阵第二个格子
function QUnlock:getUnlockTeam2GodarmHelp2(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_2_2", isTips, tips)
end

--神器上阵第三个格子
function QUnlock:getUnlockTeam2GodarmHelp3(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_2_3", isTips, tips)
end

--神器上阵第四个格子
function QUnlock:getUnlockTeam2GodarmHelp4(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM_2_4", isTips, tips)
end

--商店解锁
function QUnlock:getUnlockShop(isTips, tips)
	return self:checkLock("UNLOCK_SHOP", isTips, tips)
end

--地精商店解锁
function QUnlock:getUnlockShop1(isTips, tips)
	return self:checkLock("UNLOCK_SHOP_1", isTips, tips)
end

--黑市商店解锁
function QUnlock:getUnlockShop2(isTips, tips)
	return self:checkLock("UNLOCK_SHOP_2", isTips, tips)
end

--活动试炼
function QUnlock:getUnlockTimeTransmitter(isTips, tips)
	return self:checkLock("UNLOCK_BPPTY_BAY", isTips, tips)
end

--要塞入侵
function QUnlock:getUnlockInvasion(isTips, tips)
	return self:checkLock("UNLOCK_FORTRESS", isTips, tips)
end

--搏击俱乐部解锁
function QUnlock:getUnlockFightClub(isTips, tips)
	return self:checkLock("UNLOCK_FIGHT_CLUB", isTips, tips)
end

--星斗大森林解锁
function QUnlock:getUnlockSotoTeam(isTips, tips)
	return self:checkLock("UNLOCK_SOTO_TEAM", isTips, tips)
end

--黄金试炼
function QUnlock:getUnlockGoldChallenge(isTips, tips)
	return self:checkLock("GOLD_CHALLENGE", isTips, tips)
end

--聊天解锁
function QUnlock:getUnlockChat(isTips, tips)
	return self:checkLock("UNLOCK_CHAT", isTips, tips)
end

--自动技能
function QUnlock:getUnlockAutoSkill(isTips, tips)
	return self:checkLock("UNLOCK_AUTO_SKILL", isTips, tips)
end

--强化大师解锁
function QUnlock:getUnlockStrengthMaster(isTips, tips)
	return self:checkLock("UNLOCK_STRENGTH_MASTER", isTips, tips)
end

--强化解锁
function QUnlock:getUnlockEnhance(isTips, tips)
	return self:checkLock("UNLOCK_ENHANCE", isTips, tips)
end

--饰品强化解锁
function QUnlock:getUnlockEnhanceAdvanced(isTips, tips)
	return self:checkLock("UNLOCK_ENHANCE_ADVANCED", isTips, tips)
end
--饰品戒指解锁
function QUnlock:getUnlockBADGE(isTips, tips)
	return self:checkLock("UNLOCK_BADGE", isTips, tips)
end
--饰品项链解锁
function QUnlock:getUnlockGAD(isTips, tips)
	return self:checkLock("UNLOCK_GAD", isTips, tips)
end


--觉醒解锁
function QUnlock:getUnlockEnchant(isTips, tips)
	return self:checkLock("UNLOCK_ENCHANT", isTips, tips)
end

--精英本解锁
function QUnlock:getUnlockElite(isTips, tips)
	return self:checkLock("UNLOCK_ELITE", isTips, tips)
end

--福利本解锁
function QUnlock:getUnlockWelfare(isTips, tips)
	return self:checkLock("UNLOCK_FULIFUBEN_TRIAL", isTips, tips)
end

--技能解锁
function QUnlock:getUnlockSkill(isTips, tips)
	return self:checkLock("UNLOCK_SKILLS", isTips, tips)
end

--斗魂场解锁
function QUnlock:getUnlockArena(isTips, tips)
	return self:checkLock("UNLOCK_ARENA", isTips, tips)
end

--风暴斗魂场解锁
function QUnlock:getUnlockStormArena(isTips, tips)
	return self:checkLock("UNLOCK_STORM_ARENA", isTips, tips)
end
--魂师大赛解锁
function QUnlock:getUnlockGloryTower(isTips, tips)
	return self:checkLock("UNLOCK_TOWER_OF_GLORY", isTips, tips)
end

--副将解锁
function QUnlock:getUnlockHelper(isTips, tips)
	return self:checkLock("UNLOCK_HELP_1", isTips, tips)
end

--副将解锁显示 
function QUnlock:getUnlockHelperDisplay(isTips, tips)
	return self:checkLock("UNLOCK_HELP_1", isTips, tips)
end

--雷电王座解锁
function QUnlock:getUnlockThunder(isTips, tips)
	return self:checkLock("UNLOCK_THUNDER", isTips, tips)
end

--点金手解锁
function QUnlock:getUnlockAddMoney(isTips, tips)
	return self:checkLock("UNLOCK_GOLD", isTips, tips)
end

--培养解锁
function QUnlock:getUnlockTraining(isTips, tips)
	return self:checkLock("UNLOCK_TRAIN", isTips, tips)
end

--培养十次解锁
function QUnlock:getUnlockTrainingTen(isTips, tips)
	return self:checkLock("UNLOCK_TRAIN_10", isTips, tips)
end

--雕纹解锁
function QUnlock:getUnlockGlyph(isTips, tips)
	return self:checkLock("GLYPH_SYSTEMS", isTips, tips)
end

--洗炼解锁
function QUnlock:getUnlockRefine(isTips, tips)
	return self:checkLock("UNLOCK_XILIAN", isTips, tips)
end

-- 宗门解锁
function QUnlock:getUnlockUnion(isTips, tips)
	return self:checkLock("UNLOCK_UNION", isTips, tips)
end

-- 魂师商店解锁
function QUnlock:getUnlockHeroStore(isTips, tips)
	return self:checkLock("UNLOCK_SOUL_SHOP", isTips, tips)
end

-- 力量试炼解锁
function QUnlock:getUnlockStrengthTrial(isTips, tips)
	return self:checkLock("UNLOCK_STRENGTH_TRIAL", isTips, tips)
end

-- 智慧试炼解锁
function QUnlock:getUnlockSapientialTrial(isTips, tips)
	return self:checkLock("UNLOCK_SAPIENTIAL_TRIAL", isTips, tips)
end

--雷电王座扫荡解锁
--废弃扫荡 只判断是否三星通过
-- function QUnlock:getUnlockFastFightThunder(isTips, tips)
-- 	-- return self:checkLock("UNLOCK_THUNDER_SAODANG", isTips, nil, isVipFunc)
-- 	local isUnlock = false
-- 	local config = self._config["UNLOCK_THUNDER_SAODANG"]

-- 	if config and config.team_level ~= nil then
-- 		isUnlock = self:checkLevelUnlock(config.team_level)
-- 		if isUnlock == true then return true end
-- 	end
-- 	if self._vipConfig and self._vipConfig[tostring(QVIPUtil:VIPLevel())] ~= nil then
-- 		isUnlock = self._vipConfig[tostring(QVIPUtil:VIPLevel())].saodang
-- 	end

-- 	return isUnlock
-- end

--考古学院解锁
function QUnlock:getUnlockArchaeology(isTips, tips)
	return self:checkLock("UNLOCK_ARCHAEOLOGY", isTips, tips)
end

--考古学院解锁
function QUnlock:getUnlockSoulTrial(isTips, tips)
	return self:checkLock("SOUL_TRIAL_UNLOCK", isTips, tips)
end

--好友解锁
function QUnlock:getUnlockFriend(isTips, tips)
	return self:checkLock("UNLOCK_FRIEND", isTips, tips)
end

--豪华召唤解锁
function QUnlock:getUnlockDirectionalTavern(isTips, tips)
	return self:checkLock("UNLOCK_HAOHUAZHAOHUA", isTips, tips)
end

--重生天使解锁
function QUnlock:getUnlockReborn(isTips, tips)
	return self:checkLock("UNLOCK_REBIRTH", isTips, tips)
end

--太阳海神岛解锁
function QUnlock:getUnlockSunWar(isTips, tips)
	return self:checkLock("UNLOCK_SUNWELL", isTips, tips)
end

--宝石功能解锁
function QUnlock:getUnlockGemStone(isTips, tips)
	return self:checkLock("UNLOCK_GEMSTONE", isTips, tips)
end

--魂兽森林功能解锁
function QUnlock:getUnlockSilverMine(isTips, tips)
	return self:checkLock("UNLOCK_SILVERMINE", isTips, tips)
end

--宗门战功能解锁
function QUnlock:getUnlockPlunder(isTips, tips)
	return self:checkLock("UNLOCK_KF_YKZ", isTips, tips)
end

--噩梦副本功能解锁
function QUnlock:getUnlockNightmare(isTips, tips)
	return self:checkLock("UNLOCK_NIGHTMARE", isTips, tips)
end

--暗器功能解锁
function QUnlock:getUnlockMount(isTips, tips)
	return self:checkLock("UNLOCK_ZUOQI", isTips, tips)
end

--神器器功能解锁
function QUnlock:getUnlockGodarm(isTips, tips)
	return self:checkLock("UNLOCK_GOD_ARM", isTips, tips)
end

--世界BOSS功能解锁
function QUnlock:getUnlockWorldBoss(isTips, tips)
	return self:checkLock("UNLOCK_SHIJIEBOSS", isTips, tips)
end

--海神岛扫荡功能解锁
function QUnlock:getUnlockSunWarFastFight(isTips, tips)
	return self:checkLock("UNLOCK_SUNWELL_QUICK_FIGHT", isTips, tips)
end

--版本公告功能解锁
function QUnlock:getUnlockVersioPost(isTips, tips)
	return self:checkLock("UNLOCK_YUGAO_TANKUANG", isTips, tips)
end

--海商功能解锁
function QUnlock:getUnlockMaritime(isTips, tips)
	return self:checkLock("UNLOCK_MARITIME", isTips, tips)
end

--魂师大赛扫荡功能解锁
function QUnlock:getUnlockGloryTowerQuickFight(isTips, tips)
	return self:checkLock("TOWER_OF_GLORY_UNLOCK_SKIP", isTips, tips)
end

--玩法日历功能解锁
function QUnlock:getUnlockGameCalendar(isTips, tips)
	return self:checkLock("UNLOCK_GAME_CALENDAR", isTips, tips)
end

--一键扫荡功能解锁
function QUnlock:getUnlockRobot(isTips, tips)
	return self:checkLock("UN_LOCK_YIJIAN_SAODANG", isTips, tips)
end

--宗门副本自动攻击功能解锁
function QUnlock:getUnlockRobotForSociety(isTips, tips)
	return self:checkLock("GONGHUIFUBEN_UNLOCK_SKIP", isTips, tips)
end

--宗门答题解锁
function QUnlock:getUnlockUnionQuestion(isTips, tips)
	return self:checkLock("UNION_ANSWER", isTips, tips)
end

--大富翁功能解锁
function QUnlock:getUnlockMonopoly(isTips, tips)
	return self:checkLock("UNLOCK_BINGHUOLIANGYIYAN", isTips, tips)
end

--无限技能点功能解锁
function QUnlock:getUnlockUnlimitedSkillPoint(isTips, tips)
	return self:checkLock("UNLOCK_SKILL_FREE", isTips, tips)
end

--长按技能加点功能解锁
function QUnlock:getUnlockLongClickSkill(isTips, tips)
	return self:checkLock("UNLOCK_SKILL_LEVELUP", isTips, tips)
end

--商城附魔宝箱、暗器宝箱小红点限制功能解锁
function QUnlock:getUnlockSeniorRedPoint(isTips, tips)
	return self:checkLock("UNLOCK_RED_SPOT", isTips, tips)
end

-- 宗门红包
function QUnlock:getUnlockUnionRedpacket(isTips, tips)
	return self:checkLock("UNLOCK_REDPACKET", isTips, tips)
end

-- 仙品养成，不要直接调用，统一使用 remote.magicHerb:checkMagicHerbUnlock(isTips, tips)
function QUnlock:getUnlockMagicHerb(isTips, tips)
    return self:checkLock("UNLOCK_MAGIC_HERB", isTips, tips)
end

--大魂师自动战斗功能解锁
function QUnlock:getUnlockGloryArena(isTips, tips)
	return self:checkLock("TOWER_OF_GLORY_UNLOCK_SKIP2", isTips, tips)
end

--每日任务一键领取功能解锁
function QUnlock:getUnlockDailyTask(isTips, tips)
	return self:checkLock("UNLOCK_TASKS_REWARDS", isTips, tips)
end

-- 魂灵养成，不要直接调用，统一使用 remote.soulSpirit:checkSoulSpiritUnlock(isTips, tips)
function QUnlock:getUnlockSoulSpirit(isTips, tips)
    return self:checkLock("UNLOCK_SOUL_SPIRIT", isTips, tips)
end

-- 老玩家回歸
function QUnlock:getUnlockPlayerRecall(isTips, tips)
	return self:checkLock("UNLOCK_PLAYER_CONMEBACK", isTips, tips)
end

-- 索托自动战斗
function QUnlock:getUnlockStormArenaFastFight(isTips, tips)
	return self:checkLock("UNLOCK_STORM_ZIDONGZHANDOU", isTips, tips)
end

-- 西尔维斯大斗魂场
function QUnlock:checkModuleUnlockByModuleKey(moduleKey, isTips, tips)
	return self:checkLock(moduleKey, isTips, tips)
end
return QUnlock