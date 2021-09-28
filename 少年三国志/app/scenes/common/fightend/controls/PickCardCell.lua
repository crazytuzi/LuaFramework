local PickCardCell = class ("PickCardCell")
local EffectNode= require "app.common.effects.EffectNode"


function PickCardCell:ctor(widget, panel, idString, selectCallback)
    self._id = idString
    self._selected = false
    self._widget = widget
    self._panel = panel
    widget:setTouchEnabled(true)
    self._panel:regisgerWidgetTouchEvent("ImageView_back" .. self._id, function ( widget, param )
        if param == TOUCH_EVENT_ENDED then
            selectCallback()

        end   
    end)
end

function PickCardCell:getWidget()
    return self._widget
end
 

function PickCardCell:updateData( pick )
    if not pick then 
      return 
    end
    
    local goods = G_Goods.convert (pick.type, pick.value, pick.size)

    self._panel:getImageViewByName("ImageView_border".. self._id):loadTexture(G_Path.getEquipColorImage(goods.quality,goods.type))

    self._panel:getImageViewByName("ImageView_icon".. self._id):loadTexture(goods.icon, UI_TEX_TYPE_LOCAL)
    self._panel:getImageViewByName("Image_back".. self._id):loadTexture(G_Path.getEquipIconBack(goods.quality))

    if goods.size > 1 then
        self._panel:getLabelByName("Label_count".. self._id):setVisible(true)
        self._panel:getLabelByName("Label_count".. self._id):setText('X' .. tostring(goods.size))
        self._panel:getLabelByName("Label_count".. self._id):createStroke(Colors.strokeBrown,1)
    else
        self._panel:getLabelByName("Label_count".. self._id):setVisible(false)
    end
    self._panel:getLabelByName("Label_name".. self._id):setVisible(false)

    self._panel:getLabelByName("Label_name".. self._id):setColor(Colors.qualityColors[goods.quality])
    self._panel:getLabelByName("Label_name".. self._id):setText(goods.name)

    self._panel:getLabelByName("Label_name".. self._id):createStroke(Colors.strokeBrown,1)

end

function PickCardCell:startRevert(revertCallback)


   
    local revert2 = function() 
          local revertAction2 = CCOrbitCamera:create(0.3, 1, 0, 270, 90, 0, 0)
          local sequence2 = transition.sequence({
              revertAction2,
              CCCallFunc:create(
                  function() 
                      if self._selected then
                          self:addAroundEffect()
                      end
                      
                      self._panel:getLabelByName("Label_name".. self._id):setVisible(true)


                      revertCallback()    


                  end
              )
          })
          self._panel:getImageViewByName("ImageView_back".. self._id):setVisible(false)
          self._panel:getImageViewByName("ImageView_card".. self._id):setVisible(true)
          self._panel:getImageViewByName("ImageView_card".. self._id):runAction(sequence2)
    end
   

    local revert1 = function() 
          local revertAction = CCOrbitCamera:create(0.3, 1, 0, 0, 90, 0, 0)

          local sequence = transition.sequence({
              revertAction,
              CCCallFunc:create(
                  function() 
                      
                       revert2()        
                  end
              )
          })
          self._panel:getImageViewByName("ImageView_back".. self._id):setVisible(true)
          self._panel:getImageViewByName("ImageView_card".. self._id):setVisible(false)
          self._panel:getImageViewByName("ImageView_back".. self._id):runAction(sequence)

    end
    

    revert1()
    

end
function PickCardCell:setSelected()
    self._selected = true
end

function PickCardCell:addAroundEffect()
    local effect = EffectNode.new("effect_around_card")
    self._widget:addNode(effect)
    effect:setPositionXY(5, 6)
    effect:play()
end

  

return PickCardCell

