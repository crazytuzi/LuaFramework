local KuafuModel = {}
KuafuModel.curStateEndTime = {}
local heroLevelLimit = 40
local data_kuafuzhanconfig_kuafuzhanconfig = require("data.data_kuafuzhanconfig_kuafuzhanconfig")
enumKuafuState = {
close = 0,
xuanba = 1,
apply = 2,
knockout = 3,
Bet16To8 = 4,
race16To8 = 5,
Bet8To4 = 6,
race8To4 = 7,
Bet4To2 = 8,
race4To2 = 9,
Bet2To1 = 10,
race1To1 = 11,
zhanshi = 12
}

local kuafuMsg = {
startXuanbaFight = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossPvp",
	fmt = param.fmt,
	type = param.challengeType,
	z = param.z,
	targetAcc = param.targetAcc,
	targetIdx = param.targetServerId
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

getKuafuStateInfo = function(param)
	local _callback = param.callback
	local msg = {m = "cross", a = "checkOpen"}
	RequestHelper.request(msg, _callback, param.errback)
end,

getDefendForm = function(param)
	local _callback = param.callback
	local msg = {m = "cross", a = "getTeam"}
	RequestHelper.request(msg, _callback, param.errback)
end,

setDefendForm = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "saveTeam",
	fmt = param.fmt
	}
	RequestHelper.request(msg, _callback, param.errback)
end,

applyInfo = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossApply",
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end

}

local function parseStr(str, c)
	local times = string.split(str, c)
	for key, value in pairs(times) do
		local v = tonumber(value)
		if v then
			times[key] = v
		else
			times[key] = parseStr(value, ":")
		end
	end
	return times
end
local minTime = 60
local hourTime = 3600
local dayTime = 24 * hourTime

function KuafuModel.loginInit()
	KuafuModel.curStateEndTime = {}
	KuafuModel.curStateId = -1
	KuafuModel.curStateRun = -1
	KuafuModel.curPhase = -1
	KuafuModel.hasSignUp = nil
end

function KuafuModel.kuafucurStateEndTime(state)
	if not KuafuModel.curStateEndTime[state] then
		local data1 = data_kuafuzhanconfig_kuafuzhanconfig[state]
		local endtime = {}
		if data1.endtime then
			endtime = parseStr(data1.endtime, "_")
		else
			endtime[1] = 7
			endtime[2] = {
			24,
			0,
			0
			}
		end
		local curTime = GameModel.getServerTimeInSec()
		local date = os.date("*t", curTime)
		dump(date)
		date.hour = 0
		date.min = 0
		date.sec = 0
		local wday = date.wday - 1
		if wday == 0 then
			wday = 7
		end
		local time = os.time(date) - dayTime * (wday - 1)
		if state == enumKuafuState.zhanshi then
			if wday == 7 then
				KuafuModel.curStateEndTime[state] = time + (endtime[1] - 1) * dayTime + endtime[2][1] * hourTime + endtime[2][2] * minTime + endtime[2][3] + tonumber(data1.checktime) * hourTime
			else
				KuafuModel.curStateEndTime[state] = time + tonumber(data1.checktime) * hourTime - 1
			end
		else
			KuafuModel.curStateEndTime[state] = time + (endtime[1] - 1) * dayTime + endtime[2][1] * hourTime + endtime[2][2] * minTime + endtime[2][3]
		end
	end
	return KuafuModel.curStateEndTime[state]
end

function KuafuModel.getChallengeTimeLimit()
	local data1 = data_kuafuzhanconfig_kuafuzhanconfig[1]
	local timeLimit = parseStr(data1.checktime, "_")
	local curTime = GameModel.getServerTimeInSec()
	local date = os.date("*t", curTime)
	dump(date)
	date.hour = 0
	date.min = 0
	date.sec = 0
	local time = os.time(date)
	local startTime = time + timeLimit[1][1] * hourTime + timeLimit[1][2] * minTime + timeLimit[1][3]
	local endTime = time + timeLimit[3][1] * hourTime + timeLimit[3][2] * minTime + timeLimit[3][3]
	return startTime, endTime
end

function KuafuModel.kuafuStateInit(callbackFunc)
	kuafuMsg.getKuafuStateInfo({
	callback = function(data)
		KuafuModel.curStateId = data.stateId
		KuafuModel.curStateRun = data.stateRun
		KuafuModel.curPhase = data.phase
		KuafuModel.serverNames = data.serverNames
		if callbackFunc then
			callbackFunc(KuafuModel.curStateId)
		end
	end
	})
end

local singleNumLanginfo = {
common:getLanguageString("@ZeroTxt"),
common:getLanguageString("@OneTxt"),
common:getLanguageString("@TwoTxt"),
common:getLanguageString("@ThreeTxt"),
common:getLanguageString("@FourTxt"),
common:getLanguageString("@FiveTxt"),
common:getLanguageString("@SixTxt"),
common:getLanguageString("@SevenTxt"),
common:getLanguageString("@EightTxt"),
common:getLanguageString("@NineTxt")
}

function KuafuModel.getShowPhaseLanginfo(phaseIndex)
	if common:getLanguageChineseType() then
		local tmpNum = 0
		local text = ""
		while phaseIndex > 0 do
			tmpNum = math.floor(phaseIndex / 10)
			text = singleNumLanginfo[phaseIndex - tmpNum * 10 + 1] .. text
			phaseIndex = tmpNum
		end
		return text
	else
		return tostring(phaseIndex)
	end
end

function KuafuModel.getserverNames()
	return KuafuModel.serverNames
end

function KuafuModel.getKuafuPhase()
	return KuafuModel.curPhase
end

function KuafuModel.getKuafuState()
	if KuafuModel.curStateId <= 0 then
		return KuafuModel.curStateId
	else
		local curTime = GameModel.getServerTimeInSec()
		while curTime >= KuafuModel.kuafucurStateEndTime(KuafuModel.curStateId) do
			KuafuModel.curStateId = KuafuModel.curStateId + 1
			if KuafuModel.curStateId > #data_kuafuzhanconfig_kuafuzhanconfig then
				KuafuModel.curStateEndTime = {}
				KuafuModel.curStateId = 1
				break
			end
		end
		return KuafuModel.curStateId
	end
end

function KuafuModel.init(kuafuSceneResetFunc, needInit)
	KuafuModel.kuafuSceneResetFunc = kuafuSceneResetFunc
	if not needInit then
		return
	end
	KuafuModel.heroList = nil
	KuafuModel.attackFormTitle = "kuafu_attack_form_" .. tostring(game.player.m_uid) .. "_" .. tostring(game.player.m_serverID)
	RequestHelper.getHeroList({
	callback = function(data)
		KuafuModel.heroList = {}
		for index, hero in pairs(data["1"]) do
			hero.id = hero._id
			if hero.level >= heroLevelLimit then
				hero.cardId = hero.resId
				if hero.resId == 1 or hero.resId == 2 then
					hero.bIsSelf = true
				end
				hero.state = -1
				table.insert(KuafuModel.heroList, hero)
			end
		end
		local str = CCUserDefault:sharedUserDefault():getStringForKey(KuafuModel.attackFormTitle, "")
		if str == "" then
			str = "["
			for index, hero in ipairs(data["1"]) do
				if hero.level >= heroLevelLimit and hero.pos > 0 then
					str = str .. string.format("[%s,%d],", hero.id, hero.pos)
				end
			end
			str = str .. "]"
			CCUserDefault:sharedUserDefault():setStringForKey(KuafuModel.attackFormTitle, str)
			CCUserDefault:sharedUserDefault():flush()
		end
	end
	})
end

function KuafuModel.getAttackFormTitle()
	return KuafuModel.attackFormTitle
end

function KuafuModel.clear()
	KuafuModel.heroList = nil
end

function KuafuModel.getHeroList()
	return KuafuModel.heroList
end

function KuafuModel.loadAttackFormStr(getTeamTbl)
	local str = CCUserDefault:sharedUserDefault():getStringForKey(KuafuModel.attackFormTitle, "")
	local teamTbl = {}
	if getTeamTbl then
		local function getHeroById(id)
			for key, hero in pairs(KuafuModel.heroList) do
				if hero.id == id then
					if hero.level >= heroLevelLimit then
						return hero
					else
						return nil
					end
				end
			end
		end
		for id, pos in string.gmatch(str, "%[(%d+),(%d+)%]") do
			local hero = getHeroById(checknumber(id))
			if hero then
				table.insert(teamTbl, hero)
			end
		end
	end
	return str, teamTbl
end

function KuafuModel.checkCurretntStep(checkState, needReload)
	if checkState then
		local curState = KuafuModel.getKuafuState()
		return true
		--[[
		if checkState ~= curState then
			if needReload then
				KuafuModel.kuafuSceneResetFunc(curState)
			else
				show_tip_label(common:getLanguageString("@kuafuTimeOut"))
			end
			return false
		else
			return true
		end
		]]
	end
	return true
end

function KuafuModel.challengeStart(fmtStr, itemData, challengeType, callback)
	if not KuafuModel.checkCurretntStep() then
		return
	end
	if not KuafuModel.getHeroList() then
		show_tip_label(common:getLanguageString("@DataInRequest"))
		return
	end
	local curTime = GameModel.getServerTimeInSec()
	local limitTimeStart, limitTimeEnd = KuafuModel.getChallengeTimeLimit()
	if curTime > limitTimeStart and curTime < limitTimeEnd then
		show_tip_label(common:getLanguageString("@kuafuChallengeTip1"))
		return
	end
	kuafuMsg.startXuanbaFight({
	targetAcc = itemData.account,
	targetServerId = itemData.serverId,
	z = itemData.sign or "",
	fmt = fmtStr,
	challengeType = challengeType,
	callback = function(data)
		dump(data)
		local battleData = {}
		battleData["1"] = {}
		battleData["1"][1] = data.win
		battleData["2"] = {}
		battleData["2"][1] = data.battleInfo
		battleData["3"] = data.item
		battleData["4"] = data.coin
		local tbl = {
		name1 = game.player:getPlayerName(),
		name2 = itemData.roleName,
		attack1 = data.battlePower,
		attack2 = itemData.battlePower,
		point = data.winPoint
		}
		battleData["5"] = tbl
		local heroData = battleData["2"][1].d[1].f2
		for _, hero in pairs(heroData) do
			if hero.id == 1 or hero.id == 2 then
				hero.name = itemData.roleName
				break
			end
		end
		local scene = require("game.kuafuzhan.xuanbaBattleScene").new({
		data = battleData,
		enemyName = itemData.roleName,
		enemyCombat = itemData.battlePower,
		heroCombat = data.battlePower
		})
		display.replaceScene(scene)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	})
end

local challengeEnemyFormTag = 21

function KuafuModel.showChallengeEnemyForm(itemData, parent, type)
	if parent:getChildByTag(challengeEnemyFormTag) then
		return
	end
	if not KuafuModel.heroList then
		show_tip_label(common:getLanguageString("@DataInRequest"))
		return
	end
	local _info = {}
	_info.name = itemData.roleName
	_info.combat = itemData.battlePower
	_info.cards = {}
	for key, card in pairs(itemData.resTeam) do
		table.insert(_info.cards, card)
	end
	local formLayer = require("game.scenes.showEnemyFormLayer").new({
	info = _info,
	leftFunc = function()
		local scenes = require("game.scenes.formSettingBaseScene").new({
		heros = KuafuModel.getHeroList(),
		content_label = common:getLanguageString("@kfs_shangzhenxianzhi"),
		save_form_title = KuafuModel.getAttackFormTitle(),
		formSettingType = FormSettingType.KuaFuZhanType,
		confirmFunc = function(fmtStr)
			local callbackFunc = function()
				pop_scene()
			end
			KuafuModel.challengeStart(fmtStr, itemData, type, callbackFunc)
		end,
		btnName = common:getLanguageString("@Kaishitiaozhan"),
		needLeadRole = true
		})
		KuafuModel.enmeyFormLayer:removeSelf()
		push_scene(scenes)
	end,
	rightFunc = function()
		local fmtStr, teamTbl = KuafuModel.loadAttackFormStr(true)
		if #teamTbl < 6 then
			local layer = require("utility.MsgBox").new({
			size = cc.size(500, 250),
			content = common:getLanguageString("@IsChallenge"),
			rightBtnFunc = function()
			end,
			directclose = true,
			leftBtnName = common:getLanguageString("@Confirm"),
			rightBtnName = common:getLanguageString("@NO"),
			leftBtnFunc = function()
				KuafuModel.challengeStart(fmtStr, itemData, type)
			end
			})
			KuafuModel.enmeyFormLayer:addChild(layer, 100)
		else
			KuafuModel.challengeStart(fmtStr, itemData, type)
		end
	end
	})
	parent:addChild(formLayer, 10, challengeEnemyFormTag)
	KuafuModel.enmeyFormLayer = formLayer
end

function KuafuModel.showFormLayer()
	local _heros = KuafuModel.getHeroList()
	if not _heros then
		show_tip_label(common:getLanguageString("@DataInRequest"))
	else
		local getHeroIndexById = function(tbl, id)
			for key, hero in pairs(tbl) do
				if hero.id == id then
					return key
				end
			end
			return nil
		end
		kuafuMsg.getDefendForm({
		callback = function(data)
			local _form_heros = {} --ÉÏÕóÏÀ¿Í
			local formInfo = data.info
			for key, hero in pairs(_heros) do
				hero.state = -1
			end
			local index = 1
			
			--ÉèÖÃÉÏÕóÏÀ¿Í
			for key, hero in ipairs(formInfo) do
				local tbl = {}
				tbl.index = getHeroIndexById(_heros, hero.onlyId)
				if tbl.index then
					_heros[tbl.index].state = 1
					tbl.pos = hero.pos
					_form_heros[index] = tbl
					index = index + 1
				end
			end
			local function onConfirn(formStr)
				--ÉèÖÃ·ÀÊØÕóÈÝ
				kuafuMsg.setDefendForm({
				fmt = formStr,
				callback = function(data)
					dump(data)
					pop_scene()
					show_tip_label(common:getLanguageString("@PlayRotation") .. common:getLanguageString("@SuccessLabel"))
				end
				})
			end
			local scenes = require("game.scenes.formSettingBaseScene").new({
			formHero = _form_heros,
			heros = _heros,
			content_label = common:getLanguageString("@kfs_xuanzexiake"),
			formSettingType = FormSettingType.KuaFuZhanType,
			confirmFunc = onConfirn,
			closeFunc = onCancel,
			btnName = common:getLanguageString("@Save"),
			needLeadRole = true
			})
			push_scene(scenes)
		end
		})
	end
end

function KuafuModel.getKuafuSignUp(callbackFunc)
	KuafuModel.hasSignUp  = true
	callbackFunc(KuafuModel.hasSignUp)
	--[[
	if KuafuModel.hasSignUp == nil then
		kuafuMsg.applyInfo({
		type = 0,
		callback = function(data)
			KuafuModel.hasSignUp = sign
			callbackFunc(sign)
		end
		})
	else
		callbackFunc(KuafuModel.hasSignUp)
	end
	]]
end

function KuafuModel.setKuafuSignUp(signUp)
	KuafuModel.hasSignUp = signUp
end

return KuafuModel