local BasePopUpLayer = class("BasePopUpLayer", function (param)   
    
    return display.newNode()

end)

function BasePopUpLayer:ctor(param) 
        local boardSize = param.boardSize
        display.addSpriteFramesWithFile("ui/ui_pop_window.plist", "ui/ui_pop_window.png")

        local colorLayer  = display.newColorLayer(ccc4(0,0,0,256))
           colorLayer:setContentSize(CCSize(display.width+100,display.height+100))
           colorLayer:setOpacity(128)

           colorLayer:setPosition(- display.width/2-50,-display.height/2-50)
           self:addChild(colorLayer)

        colorLayer:setTouchEnabled(true)

        local winSize = boardSize or CCSize(display.width * 0.93 , display.height*0.65)
        local scaleBg = display.newScale9Sprite("#popwin_bg.png", x, y, winSize)  
        self.bg = scaleBg
        self:add(scaleBg)
        self:setTouchEnabled(true)
end

function BasePopUpLayer:getContentSize()

    return self.bg:getContentSize()
end



return BasePopUpLayer