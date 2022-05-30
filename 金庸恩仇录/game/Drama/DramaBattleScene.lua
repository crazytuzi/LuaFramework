local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001
local DramaBattleScene = class("DramaBattleScene", function()
	return display.newScene("DramaBattleScene")
end)
function DramaBattleScene:sendReq(curWave)
	dump("Noop")
end
function DramaBattleScene:result(data)
	local msg = {}
	msg.dramaSceneId = 2
	msg.nextFunc = self.nextFunc
	GameStateManager:ChangeState(GAME_STATE.DRAMA_SCENE, msg)
end
function DramaBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	self.timeScale = 1
	self.timeScale = ResMgr.battleTimeScale
	local battleData = msg.battleData
	dump(msg.battleData)
	self.nextFunc = msg.nextFunc
	function self.resultFunc(data)
		self:result(data)
	end
	function self.reqFunc()
	end
	local initData = {
	fubenType = DRAMA_FUBEN,
	reqFunc = self.reqFunc,
	resultFunc = self.resultFunc,
	battleData = battleData
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function DramaBattleScene:onExit(...)
	self:removeAllChildren()
end

return DramaBattleScene