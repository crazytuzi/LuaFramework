--[[
 --
 -- add by vicky
 -- 2015.03.11 
 --
 --]]


local GuildFubenBattleScene = class("GuildFubenBattleScene",function ()
	return display.newScene("GuildFubenBattleScene")
end)


function GuildFubenBattleScene:ctor(param) 

	game.runningScene = self

	local data = param.data 

	local function resultFunc()
		local layer = require("game.guild.guildFuben.GuildFubenResultLayer").new({
			data = data, 
			confirmFunc = function()
				-- 回到帮派副本详情界面（缺少功能）

			end,
			})
	end 

	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = GUILD_FUBEN,
		battleData = data,
		resultFunc = resultFunc 
		})
	self:addChild(self.battleLayer)
end


function GuildFubenBattleScene:onEnter()
	game.runningScene = self
end 


function GuildFubenBattleScene:onExit( ... ) 
	self:removeAllChildren()
	CCTextureCache:sharedTextureCache():removeUnusedTextures() 
end



return GuildFubenBattleScene 
