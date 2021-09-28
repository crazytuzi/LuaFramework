--[[
 --
 -- add by vicky
 -- 2014.09.05
 --
 --]]


local DuobaoBattleReplayLayer = class("DuobaoBattleReplayLayer",function ()
	-- return display.newScene("DuobaoBattleReplayScene")
	return require("utility.ShadeLayer").new()
end)


function DuobaoBattleReplayLayer:ctor(data, closeFunc)
	-- display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")

	self._data = data 
	--设置游戏		
	self.timeScale = 1 
	self.timeScale = ResMgr.battleTimeScale 
	


	self.resultFunc = function(data) 
		if closeFunc ~= nil then 
			closeFunc(self) 
		end 
	end

	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = DUOBAO_FUBEN,
		battleData = self._data,
		resultFunc = self.resultFunc
		})
	self:addChild(self.battleLayer)
end



return DuobaoBattleReplayLayer
