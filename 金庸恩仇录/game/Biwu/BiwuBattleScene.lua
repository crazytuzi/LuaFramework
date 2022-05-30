local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001

local BiwuBattleScene = class("BiwuBattleScene", function()
	return display.newScene("BiwuBattleScene")
end)

function BiwuBattleScene:result(data)
	self.battleData = data["2"][1]
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData.win
	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	local resultLayer = require("game.Biwu.BiwuResult").new({
	data = data,
	win = win,
	rewardItem = {},
	rewardCoin = 1,
	tabindex = self._tabIndex,
	extraMsg = self._extraMsg,
	jumpFunc = function()
		GameStateManager:ChangeState(GAME_STATE.STATE_BIWU, {
		tabindex = self._tabIndex,
		value = self._extraMsg
		})
	end
	})
	self:addChild(resultLayer, RESULT_ZORDER)
	game.player.m_energy = game.player.m_energy - 2
	self:checkIsLevelup(data)
end

function BiwuBattleScene:checkIsLevelup(data)
	local beforeLevel = game.player.getLevel()
	local curlevel = data["7"] or beforeLevel
	local curExp = data["8"]
	game.player:updateMainMenu({lv = curlevel, exp = curExp})
	if beforeLevel < curlevel then
		local curNail = game.player:getNaili()
		self:addChild(UIManager:getLayer("game.LevelUp.LevelUpLayer", nil, {
		level = beforeLevel,
		uplevel = curlevel,
		naili = curNail,
		curExp = curExp
		}), LEVELUP_ZORDER)
	end
end

function BiwuBattleScene:ctor(msg)
	self._tabIndex = msg.tabindex
	self._extraMsg = msg.data["10"]
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	self.timeScale = 1
	self.timeScale = ResMgr.battleTimeScale
	function self.resultFunc(data)
		self:result(data)
	end
	local initData = {
	fubenType = ARENA_FUBEN,
	reqFunc = self.reqFunc,
	battleData = msg.data,
	resultFunc = self.resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

return BiwuBattleScene