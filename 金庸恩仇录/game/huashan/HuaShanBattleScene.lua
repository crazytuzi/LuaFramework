local HuaShanBattleScene = class("HuaShanBattleScene", function()
	return display.newScene("HuaShanBattleScene")
end)

function HuaShanBattleScene:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self
	local _data = param.data
	local enemyName = param.enemyName
	local enemyCombat = param.enemyCombat
	local function _resultFunc(data)
		local resultLayer = require("game.huashan.HuaShanBattleResultLayer").new({
		data = data,
		name1 = game.player:getPlayerName(),
		name2 = enemyName,
		attack1 = data["7"] or 1000,
		attack2 = enemyCombat,
		battleInfo = param
		})
		self:addChild(resultLayer, 1000)
	end
	local initData = {
	fubenType = LUNJIAN,
	fubenId = 3,
	battleData = _data,
	resultFunc = _resultFunc,
	isPassed = param.isPassed
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function HuaShanBattleScene:onEnter()
	game.runningScene = self
end

return HuaShanBattleScene