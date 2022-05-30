local DuobaoBattleScene = class("DuobaoBattleScene", function()
	return display.newScene("DuobaoBattleScene")
end)

function DuobaoBattleScene:result(data)
end

function DuobaoBattleScene:ctor(param)
	game.runningScene = self
	self._data = param.data
	self._resultSceneFunc = param.resultFunc
	function self.resultFunc(data)
		self._resultSceneFunc()
	end
	local initData = {
	fubenType = DUOBAO_FUBEN,
	battleData = self._data,
	resultFunc = self.resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function DuobaoBattleScene:onEnter()
	game.runningScene = self
end

function DuobaoBattleScene:onExit()
	--self:removeAllChildren()
end

return DuobaoBattleScene