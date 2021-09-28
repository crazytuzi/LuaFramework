--[[
 --
 -- add by vicky 
 -- 2014.10.13
 --
 --]]  


 local WorldBossBattleScene = class("WorldBossBattleScene", function()
 		return display.newScene("WorldBossBattleScene") 
 	end)


 function WorldBossBattleScene:ctor(param)
 	-- dump(param.data)  
 	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")

	game.runningScene = self 
	self._data = param.data 
	self._resultFunc = param.resultFunc 
	local fubenType = param.fubenType 

	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = fubenType, 
		battleData = self._data, 
		resultFunc = function()
			if self._resultFunc ~= nil then
				self._resultFunc() 
			end 
		end 
		})

	dump(self.battleLayer) 
	self:addChild(self.battleLayer)
 end


 function WorldBossBattleScene:onEnter()
	game.runningScene = self
 end




 return WorldBossBattleScene 
