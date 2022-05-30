local DramaMgr = {}
local TUTO_TAG = 10000
local SHOW_DRAMA = true
local data_tutorial_tutorial = require("data.data_tutorial_tutorial")
require("data.data_msg_push_msg_push")
local data_drama_drama = require("data.data_drama_drama")
local data_field_field = require("data.data_field_field")
local data_world_world = require("data.data_world_world")
local dramaValueData, dramaFieldData, dramaWorldData
DramaMgr.isSkipBattleDrama = false
DramaMgr.isSkipBattleBefWorld = false
DramaMgr.isSkipBattleBefSub = false
DramaMgr.isSkipBattleBefNpc = false
function DramaMgr.runDramaBefWorld(bigMapId, endFunc)
	if SHOW_DRAMA then
		RequestHelper.getDramaValue({
		callback = function(data)
			dramaValueData = data["1"]
			local num = dramaValueData[1]
			if num < bigMapId then
				dramaValueData[1] = bigMapId
				RequestHelper.setDramaValue({
				param = dramaValueData,
				callback = function()
					dramaWorldData = data_world_world[bigMapId]
					local fieldDramaTable = dramaWorldData.arr_drama
					DramaMgr.dramaMachine(1, fieldDramaTable, endFunc)
				end
				})
			else
				endFunc()
			end
		end
		})
	else
		endFunc()
	end
end
function DramaMgr.runDramaBefSub(submapID, endFunc)
	if SHOW_DRAMA then
		RequestHelper.getDramaValue({
		callback = function(data)
			dramaValueData = data["1"]
			local num = dramaValueData[2]
			if num < submapID then
				dramaValueData[2] = submapID
				RequestHelper.setDramaValue({
				param = dramaValueData,
				callback = function()
					dramaFieldData = data_field_field[submapID]
					local fieldDramaTable = dramaFieldData.arr_drama
					DramaMgr.dramaMachine(1, fieldDramaTable, endFunc)
				end
				})
			else
				endFunc()
			end
		end
		})
	else
		endFunc()
	end
end
function DramaMgr.runDramaBefNpc(npcData, endFunc)
	if SHOW_DRAMA then
		RequestHelper.getDramaValue({
		callback = function(data)
			dump("cb data")
			dump(data)
			dramaValueData = data["1"]
			local serNpcValue = dramaValueData[3]
			local curNpcValue = npcData.id
			if SHOW_DRAMA and serNpcValue < curNpcValue then
				dramaFieldData = data_field_field[npcData.field]
				do
					local arr_battle = dramaFieldData.arr_battle
					local arr_npc_drama = dramaFieldData.arr_npc_drama
					if arr_battle ~= nil and type(arr_battle) == "table" and #arr_battle > 0 then
						do
							local curIndex = 0
							for i = 1, #arr_battle do
								if arr_battle[i] == curNpcValue then
									curIndex = i
									break
								end
							end
							local activeDrama
							if curIndex ~= 0 and arr_npc_drama ~= nil and curIndex <= #arr_npc_drama and arr_npc_drama[curIndex] ~= 0 then
								dramaValueData[3] = curNpcValue
								RequestHelper.setDramaValue({
								param = dramaValueData,
								callback = function()
									local npcDramaTable = arr_npc_drama[curIndex]
									DramaMgr.dramaMachine(1, npcDramaTable, endFunc)
								end
								})
							else
								endFunc()
							end
						end
					else
						endFunc()
					end
				end
			else
				endFunc()
			end
		end
		})
	else
		endFunc()
	end
end
DramaMgr.isSkipDrama = false

function DramaMgr.dramaEndLogin()
	local isNewUser = 1
	local nameBg = require("game.login.ChoosePlayerNameLayer").new(function()
		DramaMgr.request(isNewUser)
	end)
	game.runningScene:addChild(nameBg, 1000)
end

function DramaMgr.createChoseLayer(data)
	local function dramaEndStartLogin()
		DramaMgr.dramaEndLogin()
	end
	if SHOW_DRAMA then
		local msg = {}
		msg.dramaSceneId = 1
		msg.battleData = data["6"]
		msg.nextFunc = dramaEndStartLogin
		GameStateManager:ChangeState(GAME_STATE.DRAMA_SCENE, msg)
	else
		dramaEndStartLogin()
	end
end

function DramaMgr.resetTutorial()
	if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
		data_tutorial_tutorial[70].arr_funcs = {
		{0, 999999999}
		}
		data_msg_push_msg_push[3].time = 11
	end
end

function DramaMgr.dramaMachine(index, dramaTable, dramaEndFunc)
	if dramaTable ~= nil and index <= #dramaTable then
		local function finFunc()
			return DramaMgr.dramaMachine(index + 1, dramaTable, dramaEndFunc)
		end
		local function skipFunc()
			dramaEndFunc()
		end
		local activeId = dramaTable[index]
		local dramaLayer = require("game.Tutorial.DramaLayer").new(activeId, finFunc, skipFunc)
		game.runningScene:addChild(dramaLayer, DRAMA_ZORDER)
	else
		dramaEndFunc()
	end
end

function DramaMgr.request(isNew, data)
	local requestOnlineReward = function(...)
		local reqs = {}
		local RequestInfo = require("network.RequestInfo")
		table.insert(reqs, RequestInfo.new({
		modulename = "onlineReward",
		funcname = "list",
		param = {},
		oklistener = function(data)
			--dump(data)
			if #data["0"] > 0 then
				device.showAlert("Server Data Error", data["0"])
			else
				game.player.m_onlineRewardTime = data["3"]
				game.player.m_isShowOnlineReward = data["4"]
			end
		end
		}))
		
		table.insert(reqs, RequestInfo.new({
		modulename = "helpLineList",
		funcname = "list",
		param = {},
		oklistener = function(data)
			HelpLineModel:initData(data)
		end
		}))
		
		RequestHelperV2.request2(reqs, function()
			TutoMgr.getServerNum(function(plotNum)
				if plotNum == 0 and game.player.m_level == 1 then
					GameStateManager:ChangeState(GAME_STATE.STATE_BATTLE_FISRT, {
					levelData = {id = 110101},
					grade = 1,
					star = 0
					})
				else
					if plotNum == 0 then
						plotNum = 40
						TutoMgr.setServerNum({setNum = 40})
					end
					local msg = {}
					msg.showNote = true
					GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU, msg)
				end
			end)
		end)
	end
	local function initGame(baseData)
		game.player:init(baseData)
		SDKTKData.onLogin({
		account = game.player.m_uid
		})
		requestOnlineReward()
	end
	if isNew == 1 then
		RequestHelper.game.loginGame({
		sessionId = game.player.m_sessionID,
		uin = game.player.m_uid,
		platformID = game.player.m_platformID,
		callback = function(data)
			if data and data["0"] == "" then
				if data["4"] ~= nil and data["4"] ~= "" then
					game.player.m_serverKey = data["4"]
				end
				initGame(data["1"])
				game.player.m_gamenote = data["2"]
				CSDKShell.submitExtData({isNewUser = true})
			else
				show_tip_label(common:getLanguageString("@ServerError"))
			end
		end
		})
	else
		initGame(data["1"])
		game.player.m_gamenote = data["2"]
		CSDKShell.submitExtData({isNewUser = false})
	end
end

return DramaMgr