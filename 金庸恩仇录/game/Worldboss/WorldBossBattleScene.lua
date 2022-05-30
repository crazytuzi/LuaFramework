local WorldBossBattleScene = class("WorldBossBattleScene", function()
	return display.newScene("WorldBossBattleScene")
end)

function WorldBossBattleScene:ctor(param)
	game.runningScene = self
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	self._data = param.data
	self._resultFunc = param.resultFunc
	local fubenType = param.fubenType
	local initData = {
	fubenType = fubenType,
	battleData = self._data,
	resultFunc = function()
		if self._resultFunc ~= nil then
			self._resultFunc()
		end
	end
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function WorldBossBattleScene:onEnter()
	game.runningScene = self
end

return WorldBossBattleScene