
local DuobaoBattleReplayLayer = class("DuobaoBattleReplayLayer", function()
	return require("utility.ShadeLayer").new()
end)

function DuobaoBattleReplayLayer:ctor(data, closeFunc)
	self._data = data
	self.timeScale = ResMgr.battleTimeScale
	function self.resultFunc(data)
		if closeFunc ~= nil then
			closeFunc(self)
		end
	end
	local initData = {
	fubenType = DUOBAO_FUBEN,
	battleData = self._data,
	resultFunc = self.resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

return DuobaoBattleReplayLayer