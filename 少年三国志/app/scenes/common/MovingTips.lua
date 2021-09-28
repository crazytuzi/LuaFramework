--MovingTips.lua
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local Colors = require("app.setting.Colors")
local MovingTips = class ("MovingTips", function (  )
	return CCNode:create()
end)

function MovingTips:ctor(  )
	self._movingTips = {}
	self._cacheTips = {}
	self._func = nil
	uf_notifyLayer:getLockNode():addChild(self)
end

--text,支持richtext
-- extra 可以为空, 可以定义的东西有:
--      hasBg: boolean,  是否有背景边框, 默认为true
--      color: ccc3,  文字颜色, 默认为白色
--      movingStyle: string,  动画样式, 默认为moving_texttip
local defaultExtra = {
    hasBg = true,
    color =  Colors.tipTextColor,
    movingStyle = "moving_texttip4"
}

function MovingTips:showMovingTip( text,  extra, func )
	if type(text) ~= "string" or #text < 1 then
		return false
		
	end
    
    if extra == nil then
        extra = {}
    end
  
    if extra.hasBg == nil then
        extra.hasBg = defaultExtra.hasBg
    end

    if extra.color == nil then
        extra.color = defaultExtra.color
    end

    if extra.movingStyle == nil then
        extra.movingStyle = defaultExtra.movingStyle
    end

    self._func = func


    --如果text已经在显示中, 那么返回false,不显示
    for i, tip in ipairs(self._movingTips) do
    	if text == tip._container._text then
    		
    		return false
    	end
    end


	local movingNode = self:_fetchCacheMovingNode(extra)
	if not movingNode then
		__LogError("_initTipWithText: fetch tip control failed!")
		return false
	end

	self:_initTipWithText(movingNode, text, extra)

	self:_startMoving(movingNode)

	return true
end

function MovingTips:_initTipWithText( movingNode, text, extra )
	if not movingNode or not text then
		return 
	end

	movingNode._container._richText:clearRichElement()
	movingNode._container._richText:appendContent(text, extra.color)
	movingNode._container._richText:reloadData()
	movingNode._container._richText:adapterContent()
	movingNode._container._text =  text

	if extra.hasBg then
		movingNode._container._bg:setVisible(true)
	else
		movingNode._container._bg:setVisible(false)
	end

end

function MovingTips:_fetchCacheMovingNode(extra )
	if #self._cacheTips < 1 then
		return self:_createTipControl(extra)
	end

	local movingNode = self._cacheTips[#self._cacheTips]
	table.remove(self._cacheTips, #self._cacheTips)

	return movingNode
end

function MovingTips:_createTipControl( extra )
	
    local container = display.newNode()
    container:setCascadeOpacityEnabled(true)
    --先随便创建一个
    container._bg = CCSprite:create(G_Path.getTooltipBg())
    container:addChild(container._bg)
--    container._bg = CCScale9Sprite:create(G_Path.getTooltipBg())
--    container._bg:setContentSize(100, 120)
--    container:addChild(container._bg)
    
    local winSize = CCDirector:sharedDirector():getWinSize()
	container._richText = CCSRichText:create(winSize.width*0.8, 100)
	container._richText:setFontName("ui/font/FZYiHei-M20S.ttf")
	container._richText:setFontSize(24)
	--container._richText:setTextAlignment(kCCTextAlignmentCenter)
    container:addChild(container._richText)
    container:retain()

    
    local movingNode 
    movingNode = EffectMovingNode.new(extra.movingStyle, function(key) 
            if key == "txt" then
                return container
            end
        end, 
    function(event)
        if event == "finish" then
            self:_onMovingEnd( movingNode)
        end
    end)
    movingNode._container = container
    self:addChild(movingNode)
	return movingNode
end

function MovingTips:_startMoving( movingNode, extra )
	if not movingNode then
		__LogError("_startMoving: tip is nil!")
		return
	end
	table.insert(self._movingTips,  movingNode)

    movingNode:setVisible(true)
    movingNode:play();
    movingNode:setPosition(ccp(display.cx, display.cy))

end

function MovingTips:_onMovingEnd( movingNode )

	if not movingNode then
		return 
	end
    
    movingNode:stop()
	movingNode:setVisible(false)
    movingNode._container:release()
	
    	if self._func then
    		self._func()
    	end

    --never cache now
    --table.insert(self._cacheTips, #self._cacheTips + 1, movingNode)

	for i, value in pairs(self._movingTips) do
		if value == movingNode then
			table.remove(self._movingTips, i)
			return true
		end
	end
	
	return false
end

return MovingTips
