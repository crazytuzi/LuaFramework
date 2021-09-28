local KnightPic = require "app.scenes.common.KnightPic"
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local ShopDropKnightCell = class ("ShopDropKnightCell", function (  )
    return CCSItemCellBase:create("ui_layout/shop_ShopDropKnightCell.json")
end)


function ShopDropKnightCell:ctor()
end



function ShopDropKnightCell:updateData( knightInfoId )
    local info = knight_info.get(knightInfoId)
    self._knightInfoId = knightInfoId
    self._knightInfo = info

    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBlack,1)

    --local pic = KnightPic.createKnightNode(info.res_id)    
    --self:getPanelByName("Panel_knightAnchor"):addNode(pic)
    self:getPanelByName("Panel_knightAnchor"):setScale(0.35)



end
function ShopDropKnightCell:getKnightScale(  )
    return self:getPanelByName("Panel_knightAnchor"):getScale()
end

function ShopDropKnightCell:getKnightWorldPosition(  )

    local pos = self:getPanelByName("Panel_knightAnchor"):convertToWorldSpace(ccp(0, 0))
    return pos
end




function ShopDropKnightCell:_createKnightNode(  )

    local pic = KnightPic.createKnightNode(self._knightInfo.res_id, "knight", true)    
    pic:setCascadeOpacityEnabled(true)


    if self._knightInfo.quality >= 4 then
        local effect  
        effect= EffectNode.new("effect_card_back", function(event) 
            
        end) 
        effect:setScale(3.2)
        effect:play()
        pic:addChild(effect, - 4)
    end

    return pic
    
end

function ShopDropKnightCell:playAppear( callback )
 
    self._node = EffectMovingNode.new("moving_pickcard_many_s1", function(key)
            if key == "char" then
                return self:_createKnightNode()
            elseif key == "effect_card_show" then
              
                local effect  
                effect= EffectNode.new("effect_card_show", function(event) 
                    if event == "finish" then
                        effect:stop()
                    end
                end) 
                effect:play()
                return effect
            
            elseif key == "light_circle" then
                local pic = CCSprite:create(G_Path.getShopCardDir() .."circle.png")

                 return pic 
            
            end
        end,
        function (event) 
            if event=="finish_appear" then
                if self._knightInfo.quality >= 4 then
                    --等待next
                else
                    self._node:stop()

                    if callback ~= nil then
                        callback()
                    end
                    
                end
            elseif event == "next" then
                --finish all
                callback(true)
            end
        end
    )

    self:getPanelByName("Panel_knightAnchor"):addNode(self._node)
    self._node:play()
    
end



return ShopDropKnightCell

