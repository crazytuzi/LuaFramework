--KnightTopLayer.lua


local KnightTopLayer = class("KnightTopLayer", UFCCSNormalLayer)


function KnightTopLayer.create( ... )
	return KnightTopLayer.new("ui_layout/HeroDevelop_Main.json")
end

function KnightTopLayer:ctor( ... )

	self._scrollViewPositionX = nil
	self._style = nil
	self.super.ctor(self, ...)


end

function KnightTopLayer:onLayerLoad( ... )
	self:_doInitCheckBtns()
end

function KnightTopLayer:_doInitCheckBtns( ... )
	self:enableLabelStroke("Label_strength_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_jingjie_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_guanzhi_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_xilian_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_juexing_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_God_check", Colors.strokeBrown, 2 )

	self:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_check", true)
    self:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_disable", false, false)

    self:addCheckNodeWithStatus("CheckBox_jingjie", "Label_jingjie_check", true)
    self:addCheckNodeWithStatus("CheckBox_jingjie", "Label_jingjie_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_jingjie", "Label_jingjie_disable", false, false)

    self:addCheckNodeWithStatus("CheckBox_guanzhi", "Label_guanzhi_check", true)
    self:addCheckNodeWithStatus("CheckBox_guanzhi", "Label_guanzhi_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_guanzhi", "Label_guanzhi_disable", false, false)

    self:addCheckNodeWithStatus("CheckBox_xilian", "Label_xilian_check", true)
    self:addCheckNodeWithStatus("CheckBox_xilian", "Label_xilian_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_xilian", "Label_xilian_disable", false, false)

    self:addCheckNodeWithStatus("CheckBox_juexing", "Label_juexing_check", true)
    self:addCheckNodeWithStatus("CheckBox_juexing", "Label_juexing_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_juexing", "Label_juexing_disable", false, false)

    self:addCheckNodeWithStatus("CheckBox_God", "Label_God_check", true)
    self:addCheckNodeWithStatus("CheckBox_God", "Label_God_uncheck", false)
    self:addCheckNodeWithStatus("CheckBox_God", "Label_God_disable", false, false)
end

function KnightTopLayer:initCheckBtns( style)
	--self._topBtns:addCheckBoxGroupItem(1, "CheckBox_strength")
	--self._topBtns:addCheckBoxGroupItem(1, "CheckBox_jingjie")
	--self._topBtns:addCheckBoxGroupItem(1, "CheckBox_guanzhi")
	--self._topBtns:addCheckBoxGroupItem(1, "CheckBox_xilian")

	self:registerCheckboxEvent("CheckBox_strength", function ( ... )
		
	end)
	self:registerCheckboxEvent("CheckBox_jingjie", function ( ... )
		
	end)
	self:registerCheckboxEvent("CheckBox_guanzhi", function ( ... )
		
	end)
	self:registerCheckboxEvent("CheckBox_xilian", function ( ... )
		
	end)
	self:registerCheckboxEvent("CheckBox_juexing", function ( ... )
		
	end)
	self:registerCheckboxEvent("CheckBox_God", function ( ... )
		
	end)

	local checkbox = self:getCheckBoxByName("CheckBox_jingjie")
	if checkbox then 
		checkbox:setSelectedState(style == 2)
		if checkbox.setCheckDisabled then
			checkbox:setCheckDisabled(style == 2)
		end
	end
	checkbox = self:getCheckBoxByName("CheckBox_guanzhi")
	if checkbox then 
		checkbox:setSelectedState(style == 3)
		if checkbox.setCheckDisabled then
			checkbox:setCheckDisabled(style == 3)
		end
	end
	checkbox = self:getCheckBoxByName("CheckBox_xilian")
	if checkbox then 
		checkbox:setSelectedState(style == 4)
		if checkbox.setCheckDisabled then
			checkbox:setCheckDisabled(style == 4)
		end
	end
	checkbox = self:getCheckBoxByName("CheckBox_strength")
	if checkbox then 
		checkbox:setSelectedState(style == 1)
		if checkbox.setCheckDisabled then
			checkbox:setCheckDisabled(style == 1)
		end
	end
	checkbox = self:getCheckBoxByName("CheckBox_juexing")
	if checkbox then
		checkbox:setSelectedState(style == 5)
		if checkbox.setCheckDisabled then
			checkbox:setCheckDisabled(style == 5)
		end
	end
	checkbox = self:getCheckBoxByName("CheckBox_God")
	if checkbox then 
		checkbox:setSelectedState(style == 6)
		if checkbox.setCheckDisabled then
			checkbox:setCheckDisabled(style == 6)
		end
	end

	self._style = style

end

function KnightTopLayer:onLayerEnter( ... )
	local topScrollView = self:getScrollViewByName("ScrollView_Tab")
	if self._scrollViewPositionX then
		topScrollView:getInnerContainer():setPositionX(self._scrollViewPositionX)
	elseif self._style == 5 then
		self:scrollToPage("CheckBox_juexing")
	elseif self._style == 6 then
		self:scrollToPage("CheckBox_God")
	end
end

function KnightTopLayer:updatePositionX(posX)
	self._scrollViewPositionX = posX
end

function KnightTopLayer:scrollToPage( widgetName )

    local widget = self:getWidgetByName(widgetName)
    local scrollView = self:getScrollViewByName("ScrollView_Tab")
    if widget and scrollView then 
        local widgetSize = scrollView:getSize()
        local containerSize = scrollView:getInnerContainerSize()
        local left = widget:getLeftInParent()
        local right = widget:getRightInParent()  
        local container = scrollView:getInnerContainer()
        local posx, posy = container:getPosition()
        if widgetSize.width < containerSize.width and 
            ((left + posx >= widgetSize.width) or ((right + posx) <= 0) or 
                ((left + posx < widgetSize.width) and (right + posx > widgetSize.width))) then   
            scrollView:jumpToPercentHorizontal(100*(left)/(containerSize.width - widgetSize.width))
        end
    end
end

return KnightTopLayer