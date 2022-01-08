--[[
******游戏数据碎片基类*******

	-- by Stephen.tao
	-- 2013/11/27
]]

local GameObject = require('lua.gamedata.base.GameObject')
local GameFragment = class("GameFragment",GameObject)
function GameFragment:ctor( Data )
	self.super.ctor(self)

	self:init(Data)
end

function GameFragment:init( Data )

	self.category 		= EnumGameObjectCategory.Fragment	--类型		//碎片
end
function GameFragment:dispose()


	self.super.dispose(self)
	TFDirector:unRequire('lua.gamedata.base.GameObject')
end

return GameFragment