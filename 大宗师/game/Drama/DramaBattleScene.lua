

local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001


local DramaBattleScene = class("DramaBattleScene",function ()
	return display.newScene("DramaBattleScene")
end)

function DramaBattleScene:sendReq(curWave)
	print("Noop")
end


function DramaBattleScene:result(data)

	--剧情战没有结算界面，直接跳转到剧情动画界面2
	local msg = {}
	msg.dramaSceneId = 2
	msg.nextFunc = self.nextFunc
	GameStateManager:ChangeState(GAME_STATE.DRAMA_SCENE,msg)

	
end


function DramaBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")



	--设置游戏		
	self.timeScale = 1 
	self.timeScale = ResMgr.battleTimeScale 

	local battleData = msg.battleData

	dump(msg.battleData)
	self.nextFunc = msg.nextFunc
	self.resultFunc = function(data)
		self:result(data)
	end
	self.reqFunc = function() end
	
	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = DRAMA_FUBEN ,
		reqFunc = self.reqFunc,
		battleData = battleData,
		resultFunc = self.resultFunc
		})
	self:addChild(self.battleLayer)

end






function DramaBattleScene:onExit( ... )
	self:removeAllChildren()
end

return DramaBattleScene