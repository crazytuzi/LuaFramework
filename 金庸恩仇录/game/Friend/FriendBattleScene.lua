local FriendBattleScene = class("FriendBattleScene", function()
	return display.newScene("FriendBattleScene")
end)

function FriendBattleScene:ctor(param)
	game.runningScene = self
	local battleData = param.data.battle
	local name = param.name
	local battlepoint = param.battlepoint
	local function resultFunc(data)
		local resultLayer = require("game.Friend.FriendPKResultLayer").new({
		data = data,
		name1 = game.player:getPlayerName(),
		name2 = name,
		attack1 = game.player:getBattlePoint(),
		attack2 = battlepoint,
		battleInfo = param
		})
		self:addChild(resultLayer, 1000)
	end
	local initData = {
	fubenType = FRIEND_PK,
	battleData = battleData,
	resultFunc = resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
end

function FriendBattleScene:onEnter()
	game.runningScene = self
end

function FriendBattleScene:onExit(...)
	self:removeAllChildren()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return FriendBattleScene