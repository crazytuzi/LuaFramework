local BaseLayer = class("BaseLayer", function() return cc.Layer:create() end)

function BaseLayer:ctor()
end

function BaseLayer:createBaseInfo(tileimg,tilename)
	local comPath = "res/jjc/"
	local bg = createSprite(self,comPath.."common/fullBg.png",cc.p(g_scrSize.width/2,g_scrSize.height/2))
	local closeFunc = function() 
		removeFromParent(self)
	end
	createTouchItem(bg,comPath.."common/x.png",cc.p(917,598),closeFunc,nil,128)
	createSprite(bg,tileimg,cc.p(50,595))
	createSprite(bg,tilename,cc.p(165,600))

	return bg
end

return BaseLayer