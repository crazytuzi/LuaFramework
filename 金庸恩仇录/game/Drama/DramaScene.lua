local data_drama_scene_drama_scene = require("data.data_drama_scene_drama_scene")
local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001

local DramaScene = class("DramaScene", function()
	return display.newScene("DramaScene")
end)

function DramaScene:sendReq(curWave)
end

function DramaScene:ctor(msg)
	game.runningScene = self
	self:setNodeEventEnabled(true)
	local dramaSceneId = msg.dramaSceneId
	local battleData = msg.battleData
	local nextFunc = msg.nextFunc
	local dramaTable = data_drama_scene_drama_scene[dramaSceneId].arr_drama
	dump("drararara   " .. dramaSceneId)
	local function dramaEndFunc()
		if dramaSceneId == 1 then
			GameStateManager:ChangeState(GAME_STATE.DRAMA_BATTLE, msg)
		elseif dramaSceneId == 2 then
			nextFunc()
		elseif dramaSceneId == 3 then
			GameStateManager:ChangeState(GAME_STATE.STATE_BATTLE_FISRT, {
			levelData = {id = 110101},
			grade = 1,
			star = 0
			})
		end
	end
	if DramaMgr.isSkipDrama ~= true then
		DramaMgr.dramaMachine(1, dramaTable, dramaEndFunc)
	else
		nextFunc()
	end
end

function DramaScene:onEnter()
end

function DramaScene:onExit()
	self:removeAllChildren()
end

return DramaScene