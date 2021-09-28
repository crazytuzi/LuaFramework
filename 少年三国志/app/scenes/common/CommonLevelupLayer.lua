--CommonLevelupLayer.lua


local CommonLevelupLayer = class("CommonLevelupLayer", UFCCSModelLayer)

function CommonLevelupLayer.show( oldLevel, newLevel )
	if type(oldLevel) ~= "number" or type(newLevel) ~= "number" then 
		return 
	end

	local layer = CommonLevelupLayer.new()
	layer:initLevel(oldLevel, newLevel)

	uf_sceneManager:getCurScene():addChild(layer)
end

function CommonLevelupLayer:ctor( ... )
	self.super.ctor(self, ...)
	self:setBackColor(Colors.modelColor)
end

function CommonLevelupLayer:initLevel( oldLevel, newLevel )
	local levelup = require("app.scenes.common.fightend.parts.LevelupLayer").create(oldLevel, newLevel, function ( ... )
    end)
    self:addChild(levelup)
    local size = CCDirector:sharedDirector():getWinSize()
    levelup:setPositionXY(size.width/2, size.height/2)

    self._clickImg  = ImageView:create()
    self._clickImg:setName("clicktoclose")
	self._clickImg:loadTexture("ui/text/txt/dianjijixu.png", UI_TEX_TYPE_LOCAL)
	self:addChild(self._clickImg)

	local bkImg = levelup:getImageViewByName("Image_back")
	local bkSize = bkImg:getSize()
	self._clickImg:setPositionXY(size.width/2, (size.height - bkSize.height)/2 - 15)

	
end

function CommonLevelupLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self._clickImg, "smoving_wait", nil , {position = true} )
end

return CommonLevelupLayer
