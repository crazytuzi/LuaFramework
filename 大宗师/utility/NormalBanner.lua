


local NormalBanner = class("NormalBanner", function (param)	
	return  display.newNode()
end)
function NormalBanner:ctor(param)

	local tipContext = param.tipContext
	local delayTime = param.delayTime or 1.5
	local ttfNode = display.newNode()
	self:addChild(ttfNode,100000)
	local tipBg = display.newSprite("ui_common/tip_bg.png", x, y, params)
	ttfNode:addChild(tipBg)
	ttfNode:setVisible(false)
		
	local tipContent = ui.newTTFLabel({
			text =tipContext,
			size =18
			})
	tipContent:setPosition(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2)
	tipBg:addChild(tipContent)
	
	local small = CCCallFunc:create(function() 
		ttfNode:setScale(0.1)
		ttfNode:setVisible(true)
		end)
	local bigger = CCScaleTo:create(0.3, 1)
	local delay = CCDelayTime:create(delayTime)
	local smaller = CCScaleTo:create(0.2, 0.2)
	local rev = CCRemoveSelf:create(true)
	local rems = CCCallFunc:create(function() self:removeSelf() end)
	local seq = transition.sequence({small,bigger,delay,smaller,rev,rems})
	ttfNode:runAction(seq)
end
function NormalBanner:getContentSize()

	return self.scaleBg:getContentSize()
end

return NormalBanner