local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001

local JingYingBattleScene = class("JingYingBattleScene", function(msg)
	return display.newScene("JingYingBattleScene")
end)

function JingYingBattleScene:sendReq(curWave)
	RequestHelper.JingyingFuBenBattle({
	callback = function(data)
		--dump("jingying fuben data")
		--dump(data)
		self.totalData = data
		self.battleLayer:battleCallBack(data)
	end,
	id = self.fubenid,
	npc = curWave
	})
end

function JingYingBattleScene:result(data)
	--dump("jing ying jingying ")
	self.battleData = data["2"][1]
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData.win
	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	local resultLayer = require("game.Battle.BattleResult").new({
	win = win,
	rewardItem = self.rewardItem,
	rewardCoin = self.rewardCoin,
	--win = 1,
	--rewardItem = {},
	--rewardCoin = {},
	jumpFunc = function()
		GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN)
	end
	})
	self:addChild(resultLayer, RESULT_ZORDER)
	self:checkIsLevelup(data)
end

function JingYingBattleScene:checkIsLevelup(data)
	dump(data)
	local beforeLevel = game.player.getLevel()
	local curlevel = data["6"] or beforeLevel
	local curExp = data["7"] or 0
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

function JingYingBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self
	self.fubenid = msg
	--dump("msg" .. msg)
	self.timeScale = 1
	self.timeScale = ResMgr.battleTimeScale
	
	function self.reqFunc(curWave)
		self:sendReq(curWave)
	end
	
	function self.resultFunc(data)
		self:result(data)
	end
	
	self.totalData = nil
	local initData = {
	fubenType = JINGYING_FUBEN,
	fubenId = self.fubenid,
	reqFunc = self.reqFunc,
	resultFunc = self.resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function JingYingBattleScene:onExit()
	--self:removeAllChildren()
end

return JingYingBattleScene