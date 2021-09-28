--CommonHelpLayer.lua


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local CommonHelpLayer = class("CommonHelpLayer", UFCCSModelLayer)



function CommonHelpLayer.show( ... )
	local helpLayer = CommonHelpLayer.new("ui_layout/common_HelpLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(helpLayer, 10)
	return helpLayer
end

function CommonHelpLayer:ctor( ... )
	self.super.ctor(self, ...)
end

function CommonHelpLayer:onLayerLoad( _, _, content )
	self:_loadHelpContent(content)
	
end

function CommonHelpLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_5"), "smoving_wait", nil , {position = true} )
end

function CommonHelpLayer:_loadHelpContent( content )
	if type(content) ~= "table" or #content < 1 then 
		return 
	end

	local contentList = self:getScrollViewByName("ScrollView_content")

	local scrollSize = contentList:getSize()
	local topPt = ccp(scrollSize.width/2, scrollSize.height - 10)
	local leftEdge = 10
	local contentEdge = 10
	local topYPos = 5
	local _addContent = function ( desc, topY )
		if type(desc) ~= "string" then 
			return topY
		end
		local descLabel = GlobalFunc.createGameLabel(desc, 22, Colors.inActiveSkill, nil, CCSizeMake(scrollSize.width - leftEdge*2, 0), true)
		contentList:addChild(descLabel)
		local descSize = descLabel:getSize()

		local top = topY + descSize.height/2 + contentEdge
		descLabel:setPositionXY(scrollSize.width/2, top)
		return top + descSize.height/2
	end

	local _addTitle = function ( title, topY )
		if type(title) ~= "string" then 
			return topY
		end
		local back = ImageView:create()
		back:loadTexture(G_Path.getKnightNameBack())
		local nameLabel = GlobalFunc.createGameLabel(title, 24, Colors.darkColors.TITLE_01, Colors.strokeBrown)
		back:addChild(nameLabel)
		nameLabel:setPosition(ccp(0, 6))
		contentList:addChild(back)
		local size = back:getSize()
		local top = topY + size.height/2 + 15
		back:setPositionXY(scrollSize.width/2, top)
		return top + size.height/2
	end

	for loopi = #content, 1, -1 do 
		local help = content[loopi]
		if help then
			topYPos = _addContent(help.content, topYPos)
			topYPos = _addTitle(help.title, topYPos)
			topYPos = topYPos + 10
		end
	end

	if scrollSize.height > topYPos then
		local xPos, yPos = contentList:getPosition()
		contentList:setPositionXY(xPos, yPos + (scrollSize.height - topYPos))
	else
		contentList:setInnerContainerSize(CCSizeMake(scrollSize.width, topYPos))
		contentList:jumpToTop()
	end
end

return CommonHelpLayer
