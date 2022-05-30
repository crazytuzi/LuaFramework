local GuildBattleFightScene = class("GuildBattleFightScene", function()
	return display.newScene("GuildBattleFightScene")
end)

function GuildBattleFightScene:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self
	local _data = param.data
	local _battleType = param.fightType == 1 and GUILD_BATTLE_WALL_FIGHT or GUILD_BATTLE_WALL_BOSS
	local enemyName = param.enemyName
	local enemyCombat = param.enemyCombat
	local heroName = param.heroName
	local heroCombat = _data["4"]
	local function _resultFunc(data)
		local resultLayer = require("game.guild.guildBattle.GuildBattleFightResultLayer").new({
		fightType = param.fightType,
		data = data,
		name1 = heroName or game.player:getPlayerName(),
		name2 = enemyName,
		attack1 = heroCombat or 1000,
		attack2 = enemyCombat,
		battleInfo = param
		})
		self:addChild(resultLayer, 1000)
	end
	local initData = {
	fubenType = _battleType,
	fubenId = 3,
	battleData = _data,
	resultFunc = _resultFunc
	}
	local battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(battleLayer)
	addbackevent(self)
end

function GuildBattleFightScene:onEnter()
	game.runningScene = self
end

return GuildBattleFightScene