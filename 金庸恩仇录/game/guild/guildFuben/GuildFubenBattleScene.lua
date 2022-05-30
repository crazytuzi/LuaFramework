local GuildFubenBattleScene = class("GuildFubenBattleScene", function()
	return display.newScene("GuildFubenBattleScene")
end)

function GuildFubenBattleScene:ctor(param)
	game.runningScene = self
	local data = param.data
	local id = param.id
	local function resultFunc()
		local layer = require("game.guild.guildFuben.GuildFubenResultLayer").new({
		data = data,
		confirmFunc = function()
			game.player:getGuildMgr():forceUpdateFbInfoLayer({
			reqEndFunc = function()
				pop_scene()
			end
			})
		end
		})
		self:addChild(layer)
	end
	local initData = {
	fubenType = GUILD_FUBEN,
	fubenId = id,
	battleData = data,
	resultFunc = resultFunc
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
	addbackevent(self)
end

function GuildFubenBattleScene:onEnter()
	game.runningScene = self
end

function GuildFubenBattleScene:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return GuildFubenBattleScene