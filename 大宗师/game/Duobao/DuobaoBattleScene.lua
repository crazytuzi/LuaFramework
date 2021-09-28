--[[
 --
 -- add by vicky
 -- 2014.09.05
 --
 --]]


local DuobaoBattleScene = class("DuobaoBattleScene",function ()
	return display.newScene("DuobaoBattleScene")
end)


function DuobaoBattleScene:result(data)
	
end


function DuobaoBattleScene:ctor(param) 

	game.runningScene = self

	self._data = param.data
	self._resultSceneFunc = param.resultFunc

	self.resultFunc = function(data)
		-- dump(data)
		
		self._resultSceneFunc()
	end

	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = DUOBAO_FUBEN,
		battleData = self._data,
		resultFunc = self.resultFunc
		})
	self:addChild(self.battleLayer)
end





function DuobaoBattleScene:onEnter()
	game.runningScene = self
end





function DuobaoBattleScene:onExit( ... )
	

	self:removeAllChildren()
end


return DuobaoBattleScene
