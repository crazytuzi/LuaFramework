local EquipmentRefineItemCell = class ("EquipmentRefineItemCell", function (  )
    return CCSItemCellBase:create("ui_layout/equipment_EquipmentRefineItemCell.json")
end)
local ItemConst = require("app.const.ItemConst")
local EffectNode = require "app.common.effects.EffectNode"

local qualityIcon = {"jinglianshi_chuji.png",
                    "jinglianshi_zhongji.png",
                    "jinglianshi_gaoji.png",
                    "jinglianshi_jipin.png",}
local qualityBorder = {"pinji_chuji.png",
                    "pinji_zhongji.png",
                    "pinji_gaoji.png",
                    "pinji_jipin.png",}
local imageBegin = "ui/yangcheng/"

function EquipmentRefineItemCell:ctor()
    self._txtValue = self:getLabelByName("Label_value")
    self._txtCount = self:getLabelByName("Label_count")
    self._txtTitle = self:getLabelByName("Label_title")
    self._icon = self:getImageViewByName("Image_icon")
    self._border = self:getImageViewByName("Image_board") 
    self._clickCallback = nil
    self._refineItemId = 0
    self._curTimeCost = 0
    self._playing = false
    self._clickStart = false

    self._txtValue:createStroke(Colors.strokeBrown, 1)
    self._txtCount:createStroke(Colors.strokeBrown, 1)
    -- self._txtTitle:createStroke(Colors.strokeBrown, 1)

    -- self:regisgerWidgetTouchEvent("ImageView_dikuang", function( widget, typeValue )
    --     if TOUCH_EVENT_BEGAN == typeValue then 
    --         self._icon:setScale(0.90)
    --         self:_doClick()
    --         self:scheduleUpdate(handler(self, self._onUpdate), 0)
    --     elseif TOUCH_EVENT_MOVED == typeValue then 
    --     if not widget then 
    --         self:_stopSchedule()
    --     end
    --     local curPt = widget:getTouchMovePos()
    --     if not widget:hitTest(curPt) then 
    --         self:_stopSchedule()
    --     end
    -- elseif TOUCH_EVENT_ENDED == typeValue then 
    --         self._icon:setScale(1)
    --         -- self:_doClick()
    --         self:_stopSchedule()
    --     elseif TOUCH_EVENT_CANCELED == typeValue then 
    --         self._icon:setScale(1)
    --         self:_stopSchedule()
    --     end
    -- end)

end

function EquipmentRefineItemCell:_onUpdate( dt )
    self._curTimeCost = self._curTimeCost + dt

    if self._curTimeCost > 0.8 then 
        self._curTimeCost = self._curTimeCost - 0.3
        local canTouch = self:_doClick()
        if canTouch then
            if not self._playing then
                self._playing = true
                self._fire = EffectNode.new("effect_jinglian_julong", 
                    function(event, frameIndex)
                        if event == "forever" then
                        end
                    end
                )
                self._fire:setPosition(ccp(0,0))
                self:getImageViewByName("ImageView_dikuang"):addNode(self._fire)
                self._fire:play()
            end
        else
            self._icon:setScale(1)
            self:_stopSchedule()
        end
    end    
end

function EquipmentRefineItemCell:_doClick(typeValue )
    if self._clickCallback ~= nil then
        return self._clickCallback(self._refineItemId, self, typeValue)
    end
    return false
end

function EquipmentRefineItemCell:setCallback(callback )
    self._clickCallback = callback
end
 
 function EquipmentRefineItemCell:_stopSchedule( ... )
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

 function EquipmentRefineItemCell:stopEffect( )
    if self._fireone then 
       self._fireone:stop()
       self._fireone:removeFromParentAndCleanup(true)
       self._fireone = nil
       self._playing = false
    end
 end

function EquipmentRefineItemCell:updateData(refineItemId ,equip,useCount)
    useCount = useCount or 0
    self._refineItemId = refineItemId
    local item = item_info.get(refineItemId)
    local index = self:_getIndex(refineItemId)
    -- self._icon:loadTexture(G_Path.getItemIcon(item.res_id) )
    self._icon:loadTexture(imageBegin..qualityIcon[index] )
    -- self._txtTitle:setText(G_lang:get("LANG_JING_LIAN_VALUE"))

    self._txtValue:setColor(self:getColor(refineItemId))
    self._txtCount:setColor(Colors.uiColors.WHITE)

    self._txtValue:setText(G_lang:get("LANG_JING_LIAN_EXP2", {exp = item.item_value}))
    self._txtTitle:setText(G_lang:get("LANG_JING_LIAN_EXP"))
    

    local refineItemInfo = G_Me.bagData.propList:getItemByKey(refineItemId)
    if refineItemInfo and refineItemInfo.num > 0 then
        self._txtCount:setText(refineItemInfo.num - useCount)
        self:regisgerWidgetTouchEvent("ImageView_dikuang", function( widget, typeValue )
            if TOUCH_EVENT_BEGAN == typeValue then 
                local canTouch = self:_doClick(true)
                if canTouch then 
                    self._clickStart = true
                    self._icon:setScale(0.90)
                    -- self:scheduleUpdate(handler(self, self._onUpdate), 0)
                    self._playing = true
                    if self._fireone == nil then
                        self._fireone = EffectNode.new("effect_jinglian_julong", 
                            function(event, frameIndex)
                                -- if event == "loop" then
                                --     self._fireone:stop()
                                --     self._fireone:removeFromParentAndCleanup(true)
                                --     self._fireone = nil
                                -- end
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
                -- self:_doClick()
                self:_stopSchedule()
            elseif TOUCH_EVENT_CANCELED == typeValue then 
                self._icon:setScale(1)
                self:_stopSchedule()
            end
        end)
        -- if self._effect == nil then
        --     self._effect= EffectNode.new("effect_circle_light2", 
        --         function(event, frameIndex)
        --             if event == "finish" then
             
        --             end
        --         end
        --     )
        --     self._effect:setPosition(ccp(68,71))
        --     self:addNode(self._effect)
        --     self._effect:play()
        -- end
        self:getImageViewByName("Image_cover"):setVisible(false)
    else
        -- if self._effect ~= nil then
        --     self._effect:stop()
        --     self._effect:removeFromParentAndCleanup(true)
        --     self._effect = nil
        -- end
        self:getImageViewByName("Image_cover"):setVisible(true)
        -- self:_stopSchedule()
        if self._playing then 
           self._fireone:stop()
           self._fireone:removeFromParentAndCleanup(true)
           self._fireone = nil
           self._playing = false
        end
        self._txtCount:setText(0)
        self:regisgerWidgetTouchEvent("ImageView_dikuang", function( widget, typeValue )
            if TOUCH_EVENT_ENDED == typeValue then 
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, refineItemId,
                    GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentDevelopeScene", {equip,2}))
            end
        end)
    end
    self._icon:showAsGray(false)
    
    self._border:loadTexture(imageBegin..qualityBorder[index])

end

function EquipmentRefineItemCell:getImagePosition( )
    return self._icon:convertToWorldSpace(ccp(0, 0))

end

local refineItems = {ItemConst.ITEM_ID.REFINE_ITEM1, ItemConst.ITEM_ID.REFINE_ITEM2, ItemConst.ITEM_ID.REFINE_ITEM3, ItemConst.ITEM_ID.REFINE_ITEM4  }

function EquipmentRefineItemCell:_getIndex( refineItemId)
    for i = 1, 4 do 
        if refineItemId == refineItems[i] then
            return i
        end
    end
    return 1
end
    

function EquipmentRefineItemCell:getColor(refineItemId )
    if refineItemId == ItemConst.ITEM_ID.REFINE_ITEM1 then 
        return Colors.qualityColors[2]
    elseif refineItemId == ItemConst.ITEM_ID.REFINE_ITEM2 then 
        return Colors.qualityColors[3]
    elseif refineItemId == ItemConst.ITEM_ID.REFINE_ITEM3 then 
        return Colors.qualityColors[4]
    elseif refineItemId == ItemConst.ITEM_ID.REFINE_ITEM4 then 
        return Colors.qualityColors[5]
    end
    return Colors.qualityColors[1]
end

return EquipmentRefineItemCell

