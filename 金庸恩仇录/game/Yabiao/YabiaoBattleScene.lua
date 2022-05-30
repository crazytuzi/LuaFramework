local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001

local YabiaoBattleScene = class("YabiaoBattleScene", function()
	return display.newScene("YabiaoBattleScene")
end)

function YabiaoBattleScene:result(data)
	self.battleData = data["2"][1]
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData.win
	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	local resultLayer = require("game.Yabiao.YaBiaoResult").new({
	data = data,
	win = win,
	rewardItem = {},
	rewardCoin = 1,
	jumpFunc = function()
		GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_SCENE)
	end
	})
	self:addChild(resultLayer, RESULT_ZORDER)
	self:checkIsLevelup(data)
end

function YabiaoBattleScene:checkIsLevelup(data)
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

function YabiaoBattleScene:ctor(msg)
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

return YabiaoBattleScene