local BattleResultScene = class("BattleResultScene", BaseScene);

function BattleResultScene:ctor(data)
	self.super.ctor(self,data);

	self.mapLayer = require("lua.logic.battle.BattleMapLayer"):new()
	self:addLayer(self.mapLayer)
end

function BattleResultScene:onEnter()
	TFAudio.stopMusic()
	-- TFDirector:setFPS(GameConfig.FPS)
	FightManager:backInitSpeed()


	local uiLayer = require("lua.logic.battle.BattleResultLayer"):new()
	uiLayer:setPosition(ccp((GameConfig.WS.width - 960)/2,(GameConfig.WS.height - 640)/2));
	self:addLayer(uiLayer)
end

function BattleResultScene:StarShake(swingX, swingY)
	local postion = self:getPosition()

	if self.shakeTween ~= nil then
		TFDirector:killTween(self.shakeTween)
		self.shakeTween = nil
	end

	self:setScale(1.05)

	local shakeTime = 0.05
	self.shakeTween = 
	{
		target = self,
		{
			duration = shakeTime,
			x = postion.x+swingX,
			y = postion.y+swingY,
		},
		{
			duration = 2*shakeTime,
			x = postion.x-swingX,
			y = postion.y-swingY,
		},
		{
			duration = shakeTime,
			x = postion.x,
			y = postion.y,
		},
		onComplete = function ()
			TFDirector:killTween(self.shakeTween)
		end,
	}
	TFDirector:toTween(self.shakeTween)
end

function BattleResultScene:LastStarShake(swingX, swingY)
	local postion = self:getPosition()

	if self.shakeTween ~= nil then
		TFDirector:killTween(self.shakeTween)
		self.shakeTween = nil
	end

	local shakeTime = 0.05
	self.shakeTween = 
	{
		target = self,
		{
			duration = shakeTime,
			x = postion.x+swingX,
			y = postion.y+swingY,
		},
		{
			duration = 2*shakeTime,
			x = postion.x-swingX,
			y = postion.y-swingY,
		},
		{
			duration = shakeTime,
			x = postion.x,
			y = postion.y,
		},
		{
			duration = shakeTime,
			x = postion.x-swingX,
			y = postion.y+swingY,
		},
		{
			duration = 2*shakeTime,
			x = postion.x+swingX,
			y = postion.y-swingY,
		},
		{
			duration = shakeTime,
			x = 0,
			y = 0,
		},
		onComplete = function ()
			self:setScale(1)
			TFDirector:killTween(self.shakeTween)
		end,
	}
	TFDirector:toTween(self.shakeTween)
end

return BattleResultScene

