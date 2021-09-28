local PetRefineItemCell = class ("PetRefineItemCell", function (  )
    return CCSItemCellBase:create("ui_layout/equipment_EquipmentRefineItemCell.json")
end)
local ItemConst = require("app.const.ItemConst")
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.item_info")

function PetRefineItemCell:ctor(refineId,icon,border)
    self._txtValue = self:getLabelByName("Label_value")
    self._txtCount = self:getLabelByName("Label_count")
    self._txtTitle = self:getLabelByName("Label_title")
    self._icon = self:getImageViewByName("Image_icon")
    self._border = self:getImageViewByName("Image_board") 
    self._clickCallback = nil
    self._refineItemId = refineId
    self._curTimeCost = 0
    self._playing = false
    self._clickStart = false

    self._txtValue:createStroke(Colors.strokeBrown, 1)
    self._txtCount:createStroke(Colors.strokeBrown, 1)

    self._icon:loadTexture(icon )
    local info = item_info.get(self._refineItemId)
    self._txtValue:setColor(Colors.qualityColors[info.quality])
    self._border:loadTexture(border)
end

function PetRefineItemCell:_doClick(typeValue )
    if self._clickCallback ~= nil then
        return self._clickCallback(self._refineItemId, self, typeValue)
    end
    return false
end

function PetRefineItemCell:setCallback(callback )
    self._clickCallback = callback
end
 
 function PetRefineItemCell:_stopSchedule( ... )
    if not self._clickStart then
        return
    end
    self._clickStart = false
     self:unscheduleUpdate()
     self:_doClick(false)
     self._curTimeCost = 0
     if self._playing then 
        self._fireone:stop()
        self._fireone:removeFromParentAndCleanup(true)
        self._fireone = nil
        self._playing = false
     end
 end

function PetRefineItemCell:updateData(pet,useCount)
    useCount = useCount or 0

    local item = item_info.get(self._refineItemId)
    self._txtCount:setColor(Colors.uiColors.WHITE)

    self._txtValue:setText(G_lang:get("LANG_JING_LIAN_EXP2", {exp = item.item_value}))
    self._txtTitle:setText(G_lang:get("LANG_JING_LIAN_EXP"))
    

    local refineItemInfo = G_Me.bagData.propList:getItemByKey(self._refineItemId)
    if refineItemInfo and refineItemInfo.num > 0 then
        self._txtCount:setText(refineItemInfo.num - useCount)
        self:regisgerWidgetTouchEvent("ImageView_dikuang", function( widget, typeValue )
            if TOUCH_EVENT_BEGAN == typeValue then 
                local canTouch = self:_doClick(true)
                if canTouch then 
                    self._clickStart = true
                    self._icon:setScale(0.90)
                    self._playing = true
                    if self._fireone == nil then
                        self._fireone = EffectNode.new("effect_jinglian_julong", 
                            function(event, frameIndex)
                            end
                        )
                        self._fireone:setPosition(ccp(0,0))
                        self:getImageViewByName("ImageView_dikuang"):addNode(self._fireone)
                        self._fireone:play()
                    end
                end
        elseif TOUCH_EVENT_MOVED == typeValue then 
            if not widget then 
                self:_stopSchedule()
            end
            local curPt = widget:getTouchMovePos()
            if not widget:hitTest(curPt) then 
                self:_stopSchedule()
            end
        elseif TOUCH_EVENT_ENDED == typeValue then 
                self._icon:setScale(1)
                self:_stopSchedule()
            elseif TOUCH_EVENT_CANCELED == typeValue then 
                self._icon:setScale(1)
                self:_stopSchedule()
            end
        end)
        self:getImageViewByName("Image_cover"):setVisible(false)
    else
        self:getImageViewByName("Image_cover"):setVisible(true)
        if self._playing then 
           self._fireone:stop()
           self._fireone:removeFromParentAndCleanup(true)
           self._fireone = nil
           self._playing = false
        end
        self._txtCount:setText(0)
        self:regisgerWidgetTouchEvent("ImageView_dikuang", function( widget, typeValue )
            if TOUCH_EVENT_ENDED == typeValue then 
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, self._refineItemId,
                    GlobalFunc.sceneToPack("app.scenes.pet.develop.PetDevelopeScene", {pet,3}))
            end
        end)
    end
    self._icon:showAsGray(false)

end

local refineItems = {ItemConst.ITEM_ID.REFINE_ITEM1, ItemConst.ITEM_ID.REFINE_ITEM2, ItemConst.ITEM_ID.REFINE_ITEM3, ItemConst.ITEM_ID.REFINE_ITEM4  }

function PetRefineItemCell:_getIndex( refineItemId)
    for i = 1, 4 do 
        if refineItemId == refineItems[i] then
            return i
        end
    end
    return 1
end

function PetRefineItemCell:getImagePosition( )
    return self._icon:convertToWorldSpace(ccp(0, 0))

end

function PetRefineItemCell:stopEffect( )
   if self._fireone then 
      self._fireone:stop()
      self._fireone:removeFromParentAndCleanup(true)
      self._fireone = nil
      self._playing = false
   end
end

return PetRefineItemCell

