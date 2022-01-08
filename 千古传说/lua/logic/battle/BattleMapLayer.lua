--
-- Author: Zippo
-- Date: 2013-12-03 12:14:25
--

local MapLayer = class("MapLayer", function(...)
	local layer = TFPanel:create()
	return layer
end)

function MapLayer:ctor(data)
	local mapID = self:GetMapID()
	local mapName = "fightmap/mission"..mapID..".jpg"

	print("load map:", mapID, mapName)
	local fightBGImg = TFImage:create(mapName)
	if fightBGImg == nil then
		fightBGImg = TFImage:create("fightmap/mission1.jpg")
	end

	local nViewHeight = GameConfig.WS.height
    local nViewWidth = GameConfig.WS.width
    fightBGImg:setPosition(CCPoint(nViewWidth/2, nViewHeight/2))
    self:addChild(fightBGImg)

    self:AddMapEffect(false, fightBGImg, mapID)
    self:AddMapEffect(true, fightBGImg, mapID)
end

function MapLayer:AddMapEffect(bFrontEffect, fightBGImg, mapID, effectPos)
	local effectName = "mission"..mapID
	if bFrontEffect then
		effectName = "mission"..mapID.."_f"
	end

	local effectPath = "fightmap/effect/"..effectName..".xml"
	if not TFFileUtil:existFile(effectPath) then
		return
	end

	TFResourceHelper:instance():addArmatureFromJsonFile(effectPath)
	local effect = TFArmature:create(effectName.."_anim")
	if effect == nil then
		return
	end

	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 1)

	local uiSize = fightBGImg:getSize()
	effect:setPosition(ccp(uiSize.width/2, uiSize.height/2))

	if bFrontEffect then
		effect:setZOrder(1000)
		self:addChild(effect)
	else
		fightBGImg:addChild(effect)
	end
end

function MapLayer:GetMapID()
	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 1 then
		local mapID = 1
		if FightManager.fightBeginInfo.bGuideFight then
			local guideInfo = PlayerGuideManager:GetGuideFightInfo()
			if guideInfo ~= nil then
				mapID = guideInfo.mapid
			end
		else
			local currMissionID = MissionManager.attackMissionId
			local missionInfo = MissionManager.missionList:objectByID(currMissionID)
			if missionInfo ~= nil then
				mapID = missionInfo.fight_bg
			end
		end
		return mapID
	elseif fightType == 2 then --铜人阵
		return 2
	elseif fightType == 3 then --群豪谱
		return 30
	elseif fightType == 5 then --无量山
		return 22
	elseif fightType == 8 then --护驾
		return 5
	elseif fightType == 9 then --血战
		return 10
	elseif fightType == 15 then --10:世界boss
		return 30
	elseif fightType == 12 then --10:世界boss
		return 30
	else
		return 1
	end
end

function MapLayer.GetRowAttackPos(targetPosIndex)
	local offsetX = 100
	if targetPosIndex >= 0 and targetPosIndex < 3 then
		local pos = MapLayer.GetPosByIndex(9)
		pos.x = pos.x - offsetX
		return pos
	elseif targetPosIndex >= 3 and targetPosIndex < 6 then
		local pos = MapLayer.GetPosByIndex(12)
		pos.x = pos.x - offsetX
		return pos
	elseif targetPosIndex >= 6 and targetPosIndex < 9 then
		local pos = MapLayer.GetPosByIndex(15)
		pos.x = pos.x - offsetX
		return pos
	elseif targetPosIndex >= 9 and targetPosIndex < 12 then
		local pos = MapLayer.GetPosByIndex(0)
		pos.x = pos.x + offsetX
		return pos
	elseif targetPosIndex >= 12 and targetPosIndex < 15 then
		local pos = MapLayer.GetPosByIndex(3)
		pos.x = pos.x + offsetX
		return pos
	else
		local pos = MapLayer.GetPosByIndex(6)
		pos.x = pos.x + offsetX
		return pos
	end
end

function MapLayer.GetPosByIndex(posIndex)
	local function GetLeftPosByIndex(posIndex)
		local nGirdOffsetX = 2-posIndex%3
		local nGirdOffsetY = 2-math.floor(posIndex/3)
		local nPosX = 110 + 110*nGirdOffsetX
		local nPosY = 125 + 102*nGirdOffsetY + nGirdOffsetX
		return CCPoint(nPosX, nPosY)
	end

    local nViewWidth = GameConfig.WS.width

	if posIndex >= 0 and posIndex <= 8 then
		return GetLeftPosByIndex(posIndex)
	elseif posIndex >= 9 and posIndex <= 17 then
		local pos = GetLeftPosByIndex(posIndex-9)
		return CCPoint(nViewWidth-pos.x, pos.y)
	else
		assert(false)
		return CCPoint(0, 0)
	end
end

function MapLayer:Shake(swingX, swingY)
	if self.zoomInTween ~= nil or self.zoomOutTween ~= nil then
		return
	end

	local postion = self:getPosition()

	if self.shakeTween ~= nil then
		TFDirector:killTween(self.shakeTween)
		self.shakeTween = nil
	end

	local shakeTime = 0.05 / FightManager.fightSpeed
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
			x = postion.x,
			y = postion.y,
		},
		onComplete = function ()
			TFDirector:killTween(self.shakeTween)
		end,
	}
	TFDirector:toTween(self.shakeTween)
end

function MapLayer:ZoomIn(zoomScale, posX, posY)
	if self.zoomInTween ~= nil then
		TFDirector:killTween(self.zoomInTween)
		self.zoomInTween = nil
	end

	self.zoomInTween = 
	{
		target = self,
		{
			duration = 0.2 / FightManager.fightSpeed,
			x = posX,
			y = posY,
			scale = zoomScale,

			onComplete = function ()
				TFDirector:killTween(self.zoomInTween)
				self.zoomInTween = nil
			end,
		},
	}
	TFDirector:toTween(self.zoomInTween)
end

function MapLayer:ZoomOut()
	local postion = self:getPosition()
	if postion.x == 0 and postion.y == 0 then
		self:setScale(1.0)
		return
	end
	
	if self.zoomOutTween ~= nil then
		TFDirector:killTween(self.zoomOutTween)
		self.zoomOutTween = nil
	end

	self.zoomOutTween = 
	{
		target = self,
		{
			duration = 0.3 / FightManager.fightSpeed,
			x = 0,
			y = 0,
			scale = 1,

			onComplete = function ()
				TFDirector:killTween(self.zoomOutTween)
				self.zoomOutTween = nil
			end,
		},
	}
	TFDirector:toTween(self.zoomOutTween)
end

function MapLayer:ChangeDark(bChange)
	if bChange then
		if self.darkPanel == nil then
			self.darkPanel = TFPanel:create()
			self.darkPanel:setSize(CCSizeMake(2*GameConfig.WS.width, 2*GameConfig.WS.height))
			self.darkPanel:setPosition(ccp(-300, 0))
			self.darkPanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
			self.darkPanel:setBackGroundColor(ccc3(0, 0, 0))
			self.darkPanel:setBackGroundColorOpacity(180)
			self.darkPanel:setZOrder(2)
			self:addChild(self.darkPanel)
		end
	else
		if self.darkPanel ~= nil then
			self:removeChild(self.darkPanel)
			self.darkPanel = nil
		end
	end
end

return MapLayer