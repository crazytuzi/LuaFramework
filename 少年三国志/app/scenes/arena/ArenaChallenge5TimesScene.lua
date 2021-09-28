-- 竞技场连续挑战五次

local ArenaChallenge5TimesScene = class("ArenaChallenge5TimesScene", UFCCSBaseScene)

function ArenaChallenge5TimesScene:ctor( rank, ... )
	ArenaChallenge5TimesScene.super.ctor(self)

	local layer = require("app.scenes.arena.ArenaChallenge5TimesLayer").create(rank)
	self:addUILayerComponent("Challenge5TimesLayer", layer, true)
	layer:adapterWithScreen()
end

function ArenaChallenge5TimesScene:onSceneEnter( ... )
	-- body
end

function ArenaChallenge5TimesScene:onSceneExit( ... )
	-- body
end


return ArenaChallenge5TimesScene