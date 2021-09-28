


local DropInfoBaseView = class("DropInfoBaseView",UFCCSNormalLayer)



function DropInfoBaseView:ctor(...)

    self._closeCallback = nil
    self._toggleCallback  = nil
    self._subview  = nil
    self._type = 0
    self._value = 0
    self._clippingNode = nil
    self._openDetail = false

    self:setClickSwallow(true)
end



function DropInfoBaseView:setData(type, value)

    assert(nil, "DropInfoBaseView:setData should be override by child class")
end

function DropInfoBaseView:_createSubview(type, value)
    assert(nil, "DropInfoBaseView:_createSubview should be override by child class")

end

function DropInfoBaseView:_onOpenDetail()
    assert(nil, "DropInfoBaseView:_onOpenDetail should be override by child class")

end

function DropInfoBaseView:_onCloseDetail()
    assert(nil, "DropInfoBaseView:_onOpenDetail should be override by child class")

end



function DropInfoBaseView:_toggleDetail()
    local size = self:getRootWidget():getContentSize()
    local maskSize = CCSizeMake(size.width, display.height)

    if self._openDetail then

        self._subview:setVisible(false)

        --然后设定目标位置, 位移过去
        local subviewSize = self._subview:getRootWidget():getContentSize()
        transition.moveTo(self._subview, {x=0, y= maskSize.height ,  time=0.2})

        local initPosition = self:getInitPosition()
        local targetY =  initPosition.y
        transition.moveTo(self, {x=self:getPositionX(), y =targetY,  time=0.2})

        self._openDetail = false
        self:_onCloseDetail()
        if self._toggleCallback ~= nil then
            self._toggleCallback(targetY) --为了显示 [点击继续]
        end
    else
        if self._subview == nil then
            --make mask
            local maskNode = CCDrawNode:create()
            local pointarr1 = CCPointArray:create(4)
            pointarr1:add(ccp(0, 0))
            pointarr1:add(ccp(maskSize.width, 0))
            pointarr1:add(ccp(maskSize.width, maskSize.height))
            pointarr1:add(ccp(0, maskSize.height))
            if device.platform == "wp8" or device.platform == "winrt" then
                G_WP8.drawPolygon(maskNode, pointarr1, 4, ccc4f(1.0, 1.0, 0, 0.5), 1, ccc4f(0.1, 1, 0.1, 1))
            else
                maskNode:drawPolygon(pointarr1:fetchPoints(), 4, ccc4f(1.0, 1.0, 0, 0.5), 1, ccc4f(0.1, 1, 0.1, 1) )
            end            

            self._clippingNode = CCClippingNode:create()
            self._clippingNode:setStencil(maskNode)
            self._clippingNode:setPosition(ccp(0, -maskSize.height)) 
            self:addChild(self._clippingNode, -1)

            self._subview = self:_createSubview()
            self._clippingNode:addChild(self._subview)

        end

        self._subview:setVisible(true)


        --重新设置subview的位置
        self._subview:setPosition(ccp(0, maskSize.height))

        --然后设定目标位置, 位移过去
        local subviewSize = self._subview:getRootWidget():getContentSize()
        transition.moveTo(self._subview, {x=0, y= maskSize.height - subviewSize.height,  time=0.2})

        local totalHeight = size.height + subviewSize.height 
        local targetY =  (display.height/2 - totalHeight/2 ) + subviewSize.height + 25 --为了留点地方放 [点击继续]
        transition.moveTo(self, {x=self:getPositionX(), y =targetY,  time=0.2})

        self._openDetail = true
        self:_onOpenDetail( )
        if self._toggleCallback ~= nil then
            self._toggleCallback(targetY - subviewSize.height) --为了显示 [点击继续]
        end
        
    end




end

--subview不会调用此方法
function DropInfoBaseView:getInitPosition()
    local size = self:getRootWidget():getContentSize()
    return ccp(display.width/2 - size.width/2, display.height/2 - size.height/2)
end

--view刚出现时出现的postion坐标
function DropInfoBaseView:getInitPosition()
    local size = self:getRootWidget():getContentSize()
    return ccp(display.width/2 - size.width/2, display.height/2 - size.height/2  + 25 )--为了留点地方放 [点击继续]
end

function DropInfoBaseView:_close()
    self:animationToClose()

    if self._closeCallback ~= nil then
       self._closeCallback() 
    end


end


function DropInfoBaseView:setCloseCallback(callback)
    self._closeCallback = callback

end

function DropInfoBaseView:setToggleCallback(callback)
    self._toggleCallback = callback

end
return DropInfoBaseView
