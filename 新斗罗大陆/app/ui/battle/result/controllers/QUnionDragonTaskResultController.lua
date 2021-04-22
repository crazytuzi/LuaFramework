local QBaseResultController = import(".QBaseResultController")
local QUnionDragonTaskResultController = class("QUnionDragonTaskResultController", QBaseResultController)

function QUnionDragonTaskResultController:ctor(options)
end

function QUnionDragonTaskResultController:requestResult(isWin)
   	if isWin then
      local battleScene = self:getScene()
      local dungeonConfig = battleScene:getDungeonConfig()
      remote.dragon:consortiaDragonDoTaskRequest(dungeonConfig.taskId, nil, function()
   		-- remote.dragon:consortiaDragonTaskFightEndRequest(function()
   				self:exit()
   			end, function()
          self:exit()
        end)
   	else
   		self:exit()
   	end
end

function QUnionDragonTaskResultController:exit()
    app.grid:pauseMoving()
    app.battle:ended()
    app:exitFromBattleScene(true)
end

return QUnionDragonTaskResultController