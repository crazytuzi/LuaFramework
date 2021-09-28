--CommonHelpLayer.lua


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local CommonAttrLayer = class("CommonAttrLayer", UFCCSModelLayer)



function CommonAttrLayer.show( ... )
	local helpLayer = CommonAttrLayer.new("ui_layout/common_CommonAttrLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(helpLayer, 10)
	return helpLayer
end

function CommonAttrLayer:ctor( ... )
	self.super.ctor(self, ...)
end

function CommonAttrLayer:onLayerLoad( _, _, content, currRefineLevel,titleUrl )
	self:_loadAttrContent(content)
	if titleUrl then
		self:getImageViewByName("Image_title"):loadTexture(titleUrl)
	end
	self._currRefineLevel = currRefineLevel
end

function CommonAttrLayer:setDesc( str )
	self:getLabelByName("Label_Curr_Level_Tag"):setText(str)
end

function CommonAttrLayer:setTitle( str )
	self:getImageViewByName("Image_title"):loadTexture(str)
end

function CommonAttrLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_jixu"), "smoving_wait", nil , {position = true} )

	-- 当前精炼等级
	if self._currRefineLevel ~= nil and type(self._currRefineLevel) == "number" then
		self:showWidgetByName("Panel_Curr_Level_Info", true)
		-- self:getLabelByName("Label_Curr_Level_Tag"):createStroke(Colors.strokeBrown, 1)
		local currRefineLevelLabel = self:getLabelByName("Label_Curr_Level")
		-- currRefineLevelLabel:createStroke(Colors.strokeBrown, 1)
		currRefineLevelLabel:setText(self._currRefineLevel .. " " .. G_lang:get("LANG_JING_LIAN_CURLEVEL2"))
	else
		self:showWidgetByName("Panel_Curr_Level_Info", false)
	end
end

function CommonAttrLayer:_loadAttrContent( content,colors,yPos,topY )
	if type(content) ~= "table" or #content < 1 then 
		return 
	end

	local contentList = self:getScrollViewByName("ScrollView_content")

	local scrollSize = contentList:getSize()
	local topPt = ccp(scrollSize.width/2, scrollSize.height - 10)
	local leftEdge = 50
	local contentEdge = 0
	local topYPos = 5
	local _addContent = function ( desc,color,topY )
		if type(desc) ~= "string" then 
			return topY
		end
		color = color or Colors.inActiveSkill
		local descLabel = GlobalFunc.createGameLabel(desc, 22, color, nil, CCSizeMake(scrollSize.width - leftEdge*2, 0), true)
		local descSize = descLabel:getSize()
		local back = ImageView:create()
		local imgHeight = descSize.height + 40
		imgHeight = imgHeight>=95 and imgHeight or 95
		back:loadTexture("ui/yangcheng/jx_huoqu_bg.png")
		back:setScale9Enabled(true)
		back:setCapInsets(CCRectMake(232, 47, 1, 1))
		back:setSize(CCSizeMake(464,imgHeight))
		back:addChild(descLabel)
		contentList:addChild(back)

		local top = topY + imgHeight/2 + contentEdge
		back:setPositionXY(scrollSize.width/2, top)
		descLabel:setPositionXY(0,0)
		return top + imgHeight/2
	end

	for loopi = #content, 1, -1 do 
		local attr = content[loopi]
		if attr then
			topYPos = _addContent(attr.content,attr.color, topYPos)
			topYPos = topYPos + 0
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

return CommonAttrLayer
