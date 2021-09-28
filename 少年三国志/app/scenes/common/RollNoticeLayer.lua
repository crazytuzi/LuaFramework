
local RollNoticeLayer = class ("RollNoticeLayer", UFCCSNormalLayer)

function RollNoticeLayer.create()
    return RollNoticeLayer.new("ui_layout/common_RollNoticeLayer.json")

end



function RollNoticeLayer:ctor( ... )
    self.super.ctor(self, ...)
    uf_notifyLayer:getLockNode():addChild(self, 900, 0)
    -- uf_notifyLayer:getSysNode():addChild(self, 1000, 0)
    self:setVisible(false)
end


function RollNoticeLayer:onLayerLoad( ... )
    
    self:showTextWithLabel("Label_str", "")
end


function RollNoticeLayer:show( txt )
    self:showTextWithLabel("Label_str", txt)
    local sz = self:getLabelByName("Label_str"):getContentSize()
    --print("sw =" .. sz.width)
    self:stopAllActions()
    self:getLabelByName("Label_str"):stopAllActions()

    self:setVisible(false)
    self:setPosition(ccp(0, display.height))
    self:getLabelByName("Label_str"):setPosition(ccp(display.width, 17))

    local size = self:getRootWidget():getContentSize()  

    local sequence = transition.sequence({
        CCCallFunc:create(
            function()
                self:setVisible(true)
            end
        ),
        CCMoveTo:create(0.3, ccp(0, display.height-size.height)),
        CCDelayTime:create(0.5),
        CCCallFunc:create(
            function()
                --滚动文本
                local xDistance = sz.width + 640
                local scrollSeconds = (xDistance) / 50
                local sequenceTxt = transition.sequence({  
                    CCMoveTo:create(scrollSeconds, ccp(display.width - xDistance , 17)),
                    CCDelayTime:create(0.5),
                    CCCallFunc:create(
                        function()
                            --消失
                            local sequence = transition.sequence({                                    
                                CCMoveTo:create(0.3, ccp(0, display.height)),
                                CCCallFunc:create(
                                    function()
                                        self:setVisible(false)
                                    end
                                )
                            })

                            self:runAction(sequence)   

                        end
                    ),    
                })
                self:getLabelByName("Label_str"):runAction(sequenceTxt)    
    
            end
        ),


    })

    self:runAction(sequence)    


    -- if sz.width < 630 then
    --     local sequence = transition.sequence({
    --         CCCallFunc:create(
    --             function()
    --                 self:setVisible(true)
    --             end
    --         ),
    --         CCMoveTo:create(0.3, ccp(0, display.height-size.height)),
    --         CCDelayTime:create(5),
    --         CCMoveTo:create(0.3, ccp(0, display.height)),
    --         CCCallFunc:create(
    --             function()
    --                 self:setVisible(false)
    --             end
    --         )
    --     })

    --     self:runAction(sequence)    
    -- else
    --     --文本需要水平滚动        
       



    -- end



end


return RollNoticeLayer
