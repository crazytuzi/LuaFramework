

local data_drama_scene_drama_scene = require("data.data_drama_scene_drama_scene")

local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001


local DramaScene = class("DramaScene",function ()

	return display.newScene("DramaScene")
end)

function DramaScene:sendReq(curWave)
	-- RequestHelper.sendNormalBattle({
	-- 	id = self.levelID,
	-- 	type = self.gradeID,
	-- 	callback = function(data)

	-- 		self.battleLayer:battleCallBack(data)
			
	-- 	end
	-- 	})
end





function DramaScene:ctor(msg)
    game.runningScene = self
	
	self:setNodeEventEnabled(true)

	--根据dramaSceneId 读取对应表的数据
	local dramaSceneId = msg.dramaSceneId
	local battleData   = msg.battleData -- 第一场剧情战的战场
    local nextFunc      = msg.nextFunc


	--根据数据依次创建动画，状态机，当最后一个动画终结的时候,就切换界面，跳转到另外的一个scene(根据dramaSceneId)
	local dramaTable = data_drama_scene_drama_scene[dramaSceneId].arr_drama

	print("drararara   "..dramaSceneId)

	local function dramaEndFunc()
		if dramaSceneId == 1 then
			--刚进游戏激活 播放完事后跳转到第一场剧情战
			--跳转到选人界面的func

			GameStateManager:ChangeState(GAME_STATE.DRAMA_BATTLE,msg)
		elseif dramaSceneId == 2 then
			--第一场剧情战之后激活,完事后跳转到选人界面
			
			nextFunc()
		elseif dramaSceneId == 3 then
			--创建角色之后激活，完事后跳转到牛家村1
			GameStateManager:ChangeState(GAME_STATE.STATE_NORMAL_BATTLE,{levelData = {id = 110101},grade = 1,star = 0})
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
	
	-- print("DramaScene:onExit")
	self:removeAllChildren()
end

return DramaScene