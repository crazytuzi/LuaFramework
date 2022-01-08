local FightResultScene = class("FightResultScene", BaseScene);

function FightResultScene:ctor(data)
	self.super.ctor(self,data);

	self.mapLayer = require("lua.logic.fight.MapLayer"):new()
	self:addLayer(self.mapLayer)
end

function FightResultScene:onEnter()
	-- TFAudio.stopMusic()
	-- TFDirector:setFPS(GameConfig.FPS)
	FightManager:backInitSpeed()

	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 10 or fightType == 17  then
		local uiLayer = require("lua.logic.fight.BossFightResultLayer"):new()
		self:addLayer(uiLayer)
		return 
	end
	if FightManager:NeedShowText(false) and not self:isYouliFirst() then
		local endTextShowEndCallBack = function(event)
			local uiLayer = require("lua.logic.fight.FightResultLayer"):new()
			self:addLayer(uiLayer)
			PlayerGuideManager:doGuide()
			TFDirector:removeMEGlobalListener("MissionTipLayer.EVENT_SHOW_ENDTIP_COM")
		end
		TFDirector:addMEGlobalListener("MissionTipLayer.EVENT_SHOW_ENDTIP_COM",  endTextShowEndCallBack)

		if FightManager.fightBeginInfo.fighttype == 1 or FightManager.fightBeginInfo.fighttype == 19 or FightManager.fightBeginInfo.fighttype == 23 then
			MissionManager:showEndTip()
		elseif FightManager.fightBeginInfo.fighttype == 17 then
			FactionManager:showTip(12)
		end
	else
		local uiLayer = require("lua.logic.fight.FightResultLayer"):new()
		self:addLayer(uiLayer)
	end
end

function FightResultScene:isYouliFirst()
	if FightManager:isHasSecondFight() then
		if FightManager.fightResultInfo and FightManager.fightResultInfo.rank  and FightManager.fightResultInfo.rank == 1 then
			return true
		end
	end
	return false
end

function FightResultScene:StarShake(swingX, swingY)
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

function FightResultScene:LastStarShake(swingX, swingY)
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

return FightResultScene

