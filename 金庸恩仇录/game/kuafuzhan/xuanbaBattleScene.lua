
--跨选拔赛战斗
local xuanbaBattleScene = class("xuanbaBattleScene", function()
	return display.newScene("xuanbaBattleScene")
end)

function xuanbaBattleScene:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self
	local _data = param.data --战斗数据
	local enemyName = param.enemyName or "test" --敌方角色名称
	local enemyCombat = param.enemyCombat --敌人战斗力
	local heroName = param.heroName --角色名称
	local heroCombat = param.heroCombat --己方战斗力
	local function _resultFunc(data)
		if param.beRace then
			pop_scene()
		else
			local resultLayer = require("game.kuafuzhan.xuanbaBattleResultLayer").new({
			data = data,
			name1 = heroName or game.player:getPlayerName(),
			name2 = enemyName,
			attack1 = heroCombat or 1000,
			attack2 = enemyCombat,
			battleInfo = param
			})
			self:addChild(resultLayer, 1000)
		end
	end
	local initData = {
	fubenType = KUAFU_ZHAN,
	fubenId = 3,
	battleData = _data,
	resultFunc = _resultFunc
	}
	local battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(battleLayer)
end

function xuanbaBattleScene:onEnter()
	game.runningScene = self
end

return xuanbaBattleScene