local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001

local ArenaBattleScene = class("ArenaBattleScene", function()
	return display.newScene("ArenaBattleScene")
end)

function ArenaBattleScene:sendReq(curWave)
	RequestHelper.sendNormalBattle({
	id = self.levelID,
	type = self.gradeID,
	errback = function(data)
		self:sendReq(0)
	end,
	callback = function(data)
		self.battleLayer:battleCallBack(data)
	end
	})
end

function ArenaBattleScene:result(data)
	self.battleData = data["2"][1]
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData.win
	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	local resultLayer = require("game.Arena.ArenaResult").new({data = data})
	self:addChild(resultLayer, RESULT_ZORDER)
	self:checkIsLevelup(data)
end

function ArenaBattleScene:checkIsLevelup(data)
	local beforeLevel = game.player.getLevel()
	local curlevel = data["7"] or beforeLevel
	local curExp = data["8"]
	game.player:updateMainMenu({lv = curlevel, exp = curExp})
	if beforeLevel < curlevel then
		local curNail = game.player:getNaili()
		local levelUpLayer = UIManager:getLayer("game.LevelUp.LevelUpLayer", nil, {
		level = beforeLevel,
		uplevel = curlevel,
		naili = curNail,
		curExp = curExp
		})
		self:addChild(levelUpLayer, LEVELUP_ZORDER)
	end
end

function ArenaBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	self.timeScale = ResMgr.battleTimeScale
	function self.resultFunc(data)
		self:result(data)
	end
	local initData = {
	fubenType = ARENA_FUBEN,
	reqFunc = self.reqFunc,
	battleData = msg,
	resultFunc = self.resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function ArenaBattleScene:onExit()
	--self:removeAllChildren()
end

return ArenaBattleScene