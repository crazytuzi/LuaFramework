--SplashLayer.lua


local SplashLayer = class("SplashLayer", function ( ... )
	return CCSNormalLayer:create()
end)

function SplashLayer:ctor( ... )
	self:adapterWithScreen()
end

function SplashLayer:splashScreen( fun )
	if not CCFileUtils:sharedFileUtils():isFileExist("splash.png") then 
		if fun then 
			fun()
		end
		return 
	end

	local winSize = CCDirector:sharedDirector():getWinSize()

	local clickImg = ImageView:create()
	clickImg:loadTexture("splash.png", UI_TEX_TYPE_LOCAL)
	self:getRootWidget():addChild(clickImg)
	clickImg:setOpacity(0)
	clickImg:setPosition(ccp(winSize.width/2, winSize.height/2))

	local arr = CCArray:create()
	arr:addObject(CCFadeIn:create(0.8))
	arr:addObject(CCDelayTime:create(1.5))
	arr:addObject(CCFadeTo:create(0.8, 50))
	arr:addObject(CCCallFunc:create(function (  )
		if fun then 
			fun()
		end
	end))
	clickImg:runAction(CCSequence:create(arr))
end

return SplashLayer
