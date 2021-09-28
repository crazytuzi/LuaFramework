--CommonInfoTipLayer.lua


local CommonInfoTipLayer = class("CommonInfoTipLayer", UFCCSNormalLayer)
--[[ params:
desc: what content you want to show
y:    the y position for the tip to show at
delta: the delta time how long to show
clr: the color the tip text show with
]]

function CommonInfoTipLayer.show( ... )
	local layer = CommonInfoTipLayer.new(nil, nil, ...)
	if not layer:isValid() then
		return nil
	end

	uf_sceneManager:getCurScene():addChild(layer)
	return layer
end

function CommonInfoTipLayer:ctor( ... )
	self._delta = 2
	self._bkImg = nil

	self.super.ctor(self, ...)
end

function CommonInfoTipLayer:onLayerLoad( json, fun, desc, y, delta, clr )
	local label = self:_createLabelWithDesc(desc, clr)	
	if label then 
		self:_initWithLabel(label, y)
	end

	delta = delta or 2
	if delta < 0 then 
		delta = - delta 
	end
	if delta == 0 then 
		delta = 2
	end
	self._delta = delta or 2
end

function CommonInfoTipLayer:_createLabelWithDesc( desc, clr )
	if type(desc) ~= "string" or #desc < 1 then 
		return 
	end

	local winSize = CCDirector:sharedDirector():getWinSize()
	local label = GlobalFunc.createGameLabel( desc, 26, clr or Colors.darkColors.TIPS_02, nil )
	if not label then 
		return 
	end

	local labelSize = label:getSize()
	if labelSize.width >= winSize.width*0.9 then 
		label = GlobalFunc.createGameLabel( desc, 26, clr or Colors.darkColors.TIPS_02, nil, CCSizeMake(winSize.width*0.8, 0), true )
	end

	return label
end

function CommonInfoTipLayer:_initWithLabel( label, y )
	if not label then 
		return 
	end

	local widthOffset = 20
	local heightOffset = 10
	local labelSize = label:getSize()
	local bkImg = ImageView:create()
	--bkImg:loadTexture("board_black_bg.png", UI_TEX_TYPE_PLIST)
	bkImg:loadTexture("ui/arena/bg_shenwang.png", UI_TEX_TYPE_LOCAL)
	bkImg:setSize(CCSizeMake(labelSize.width + widthOffset, labelSize.height + heightOffset))
	bkImg:setScale9Enabled(true)
	bkImg:setCapInsets(CCRectMake(16, 16, 1, 1))

	local winSize = CCDirector:sharedDirector():getWinSize()
	y = y or winSize.height*3/5
	bkImg:setPositionXY(winSize.width/2, y)
	label:setPositionXY(0, 0)

	bkImg:addChild(label)
	self:addChild(bkImg)

	self._bkImg = bkImg
	self._bkImg:setVisible(false)
end

function CommonInfoTipLayer:onLayerEnter( ... )
	if not self._bkImg then 
		return 
	end

	self._bkImg:setVisible(true)

	local arr = CCArray:create()
	arr:addObject(CCFadeIn:create(0.3))
    arr:addObject(CCDelayTime:create(self._delta))
    arr:addObject(CCFadeOut:create(0.5))
    arr:addObject(CCCallFunc:create(function (  )
    	self:close()
    end))
    self._bkImg:runAction(CCSequence:create(arr))  
end

function CommonInfoTipLayer:isValid( ... )
	return self._bkImg ~= nil
end

return CommonInfoTipLayer
