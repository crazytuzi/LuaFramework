local FastRefineLayer = class("FastRefineLayer",UFCCSModelLayer)
local ItemConst = require("app.const.ItemConst")
local MergeEquipment = require("app.data.MergeEquipment")
require("app.cfg.pet_info")
require("app.cfg.pet_addition_info")
require("app.cfg.item_info")

FastRefineLayer.TYPE_EQUIPMENT = 1
FastRefineLayer.TYPE_PET = 2

FastRefineLayer.REFINEITEMS = {{ItemConst.ITEM_ID.REFINE_ITEM1, ItemConst.ITEM_ID.REFINE_ITEM2, ItemConst.ITEM_ID.REFINE_ITEM3, ItemConst.ITEM_ID.REFINE_ITEM4  }
                                                    ,{ItemConst.ITEM_ID.PET_REFINE_ITEM1, ItemConst.ITEM_ID.PET_REFINE_ITEM2, ItemConst.ITEM_ID.PET_REFINE_ITEM3  }}
FastRefineLayer.EQUIPREFINEICONS = {"ui/yangcheng/chuji.png","ui/yangcheng/zhongji.png","ui/yangcheng/gaoji.png","ui/yangcheng/jipin.png"}

FastRefineLayer.hasShow = false

function FastRefineLayer.show(fastType,item)
    if FastRefineLayer.hasShow then
        return
    end
    local curLevel = fastType == FastRefineLayer.TYPE_EQUIPMENT and item.refining_level or item.addition_lvl
    local maxLevel = fastType == FastRefineLayer.TYPE_EQUIPMENT and item:getMaxRefineLevel() or G_Me.bagData.petData:getCanRefineLevel(item)
    if maxLevel <= curLevel then
        local lang =  fastType == FastRefineLayer.TYPE_EQUIPMENT and G_lang:get("LANG_REFINE_LEVEL_LIMIT") or G_lang:get("LANG_PET_REFINE_MAX")
        return G_MovingTip:showMovingTip(lang)
    end
    
    if FastRefineLayer.calcCost(1,fastType,item) then
        local layer =  FastRefineLayer.create(fastType,item)
        uf_sceneManager:getCurScene():addChild(layer)
    else
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_CANNOT_REFINE_FAST"..fastType))
    end
end

function FastRefineLayer.create(fastType,item)
    local layer = FastRefineLayer.new("ui_layout/equipment_FastRefine.json",require("app.setting.Colors").modelColor,fastType,item)
    return layer
end


function FastRefineLayer:ctor(json,color,fastType,item)
    self._isAddingNum = true
    self._curTimeCost = 0
    
    self._buyCount = 1
    self._tryBuyCount = 1
    self._maxLevel = fastType == FastRefineLayer.TYPE_EQUIPMENT and item:getMaxRefineLevel() or G_Me.bagData.petData:getCanRefineLevel(item)
    self._fastType = fastType
    self._item = item
    self._baseInfo = fastType == FastRefineLayer.TYPE_EQUIPMENT and item:getInfo() or pet_info.get(item.base_id)
    self._cost = {0,0,0,0}
    self.super.ctor(self,json)
    
    self:_initWidgets()
    self:_createStrokes()
    self:_initBtnEvent()
    self:showAtCenter(true)
end

function FastRefineLayer:_createStrokes()
    self:enableLabelStroke("Label_name", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jian10", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jian1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jia10", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jia1", Colors.strokeBrown,1)
end

function FastRefineLayer:_initWidgets()
    local nameLabel = self:getLabelByName("Label_name")
    local itemButton = self:getButtonByName("Button_item")

    local titleImg = self._fastType == FastRefineLayer.TYPE_EQUIPMENT and "ui/text/txt-title/yijianjinglian.png" or "ui/text/txt-title/yijianshenlian.png"
    self:getImageViewByName("ImageView_title"):loadTexture(titleImg)
    nameLabel:setText(self._baseInfo.name)
    nameLabel:setColor(Colors.qualityColors[self._baseInfo.quality])
    self:getImageViewByName("ImageView_item_bg01"):loadTexture(G_Path.getEquipIconBack(self._baseInfo.quality))
    itemButton:loadTextureNormal(G_Path.getEquipColorImage(self._baseInfo.quality))
    itemButton:loadTexturePressed(G_Path.getEquipColorImage(self._baseInfo.quality))
    self:getLabelByName("Label_item_num"):setVisible(false)
    local beforeLevel = self._fastType == FastRefineLayer.TYPE_EQUIPMENT and self._item.refining_level or self._item.addition_lvl
    self:getLabelByName("Label_beforeLevel"):setText(G_lang:get("LANG_PET_REFINE_JIE",{level=beforeLevel}))

    local path = self._fastType == FastRefineLayer.TYPE_EQUIPMENT and G_Path.getEquipmentIcon(self._baseInfo.res_id) or G_Path.getPetIcon(self._baseInfo.res_id)
    self:getImageViewByName("ImageView_item"):loadTexture(path)

    local items = FastRefineLayer.REFINEITEMS[self._fastType]
    for i = 1 , 4 do 
        if items[i] then
            self:getImageViewByName("Image_icon"..i):setVisible(true)
            self:getLabelByName("Label_cost"..i):setVisible(true)
            local itemInfo = item_info.get(items[i])
            self:getImageViewByName("Image_icon"..i):loadTexture(self._fastType == 1 and FastRefineLayer.EQUIPREFINEICONS[i] or G_Path.getItemIcon(itemInfo.res_id))
        else
            self:getImageViewByName("Image_icon"..i):setVisible(false)
            self:getLabelByName("Label_cost"..i):setVisible(false)
        end
    end

    local cost = self:calcMyCost()
    if cost then
        self._cost = cost
    end

    self:updateLabels()
end

function FastRefineLayer:updateLabels()
    self:getLabelByName("Label_count"):setText(self._buyCount)
    local beforeLevel = self._fastType == FastRefineLayer.TYPE_EQUIPMENT and self._item.refining_level or self._item.addition_lvl
    self:getLabelByName("Label_nextLevel"):setText(G_lang:get("LANG_PET_REFINE_JIE",{level=beforeLevel+self._buyCount }))
    local items = FastRefineLayer.REFINEITEMS[self._fastType]
    for i = 1 , 4 do 
        if items[i] then
            local itemInfo = G_Me.bagData.propList:getItemByKey(items[i])
            local itemCount = itemInfo and itemInfo.num or 0
            self:getLabelByName("Label_cost"..i):setText(self._cost[i].."/"..itemCount)
        end
    end
end

function FastRefineLayer:calcMyCost(addLevel,fastType,refineItem)
    fastType = fastType or self._fastType
    refineItem = refineItem or self._item
    addLevel = addLevel or self._tryBuyCount
    return FastRefineLayer.calcCost(addLevel,fastType,refineItem)
end

function FastRefineLayer.calcCost(addLevel,fastType,refineItem)
    fastType = fastType or FastRefineLayer.TYPE_EQUIPMENT
    addLevel = addLevel or 1
    local curLevel = fastType == FastRefineLayer.TYPE_EQUIPMENT and refineItem.refining_level or refineItem.addition_lvl
    local targetLevel = curLevel + addLevel
    local maxLevel = fastType == FastRefineLayer.TYPE_EQUIPMENT and refineItem:getMaxRefineLevel() or G_Me.bagData.petData:getCanRefineLevel(refineItem)
    if maxLevel < targetLevel then
        return nil
    end
    local curExp = fastType == FastRefineLayer.TYPE_EQUIPMENT and refineItem.refining_exp or refineItem.addition_exp
    local getNeedExp = fastType == FastRefineLayer.TYPE_EQUIPMENT and MergeEquipment.getRefineNextLevelExp or G_Me.bagData.petData.getRefineNeedExp

    local totalNeedExp = 0
    for i = 0 , targetLevel - 1 do
        totalNeedExp = totalNeedExp + getNeedExp(refineItem,i)
    end
    local needExp = totalNeedExp - curExp

    local items = FastRefineLayer.REFINEITEMS[fastType]
    local cost = {0,0,0,0}
    for i = 1 , 4 do 
        if items[i] and needExp > 0 then
            local itemInfo = G_Me.bagData.propList:getItemByKey(items[i])
            local hasCount = itemInfo and itemInfo.num or 0
            local item = item_info.get(items[i])
            local need = math.ceil(needExp/item.item_value)
            local curCost = math.min(need,hasCount)
            needExp = needExp - curCost*item.item_value
            cost[i] = curCost
        end
    end
    if needExp > 0 then
        return nil
    else
        return cost
    end
end

function FastRefineLayer:_initBtnEvent()
    self:registerBtnClickEvent("Button_item",function()
        -- if self._item ~= nil then
        --     if self._fastType == FastRefineLayer.TYPE_EQUIPMENT then
        --         require("app.scenes.equipment.EquipmentInfo").showEquipmentInfo( self._item, 1)
        --     else
        --         require("app.scenes.pet.PetInfo").showEquipmentInfo( self._item , 1,{})
        --     end
        -- end
    end)
    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    self:enableAudioEffectByName("Button_cancel", false)
    self:registerBtnClickEvent("Button_cancel",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    --购买
    self:registerBtnClickEvent("Button_buy",function()
        if self._item ~= nil then
            local items = FastRefineLayer.REFINEITEMS[self._fastType]
            local costs = {}
            for i = 1 , 4 do 
                if items[i] and self._cost[i] > 0 then
                    table.insert(costs,#costs+1,{id=items[i],num=self._cost[i]})
                end
            end
            if #costs == 0 then
                return
            end
            if self._fastType == FastRefineLayer.TYPE_EQUIPMENT then
                G_HandlersManager.equipmentStrengthenHandler:sendFastRefineEquipment(self._item.id, costs)
            else
                G_HandlersManager.petHandler:sendPetFastUpAddition(self._item.id, costs)
            end
        end
        self:animationToClose()
    end)
    -- 加 1
    self:registerBtnClickEvent("Button_add01",function()
        local curLevel = self._fastType == FastRefineLayer.TYPE_EQUIPMENT and self._item.refining_level or self._item.addition_lvl
        if self._maxLevel <= curLevel + self._tryBuyCount then
            return
        end
        self._tryBuyCount = self._tryBuyCount + 1
        local cost = self:calcMyCost()
        if cost then
            self._cost = cost
            self._buyCount = self._tryBuyCount
            self:updateLabels()
        else
            self._tryBuyCount = self._buyCount
        end
    end)
    -- 减 1
    self:registerBtnClickEvent("Button_subtract01",function()
        if self._buyCount == 1 then
            return
        end
        self._buyCount = self._buyCount -1
        self._tryBuyCount = self._buyCount
        self._cost = self:calcMyCost()
        self:updateLabels()
    end)
     self:registerWidgetTouchEvent("Button_add10", function ( widget, typeValue )
         self._isAddingNum = true
         self:_onBtnTouch(widget, typeValue)
     end)
     self:registerWidgetTouchEvent("Button_subtract10", function ( widget, typeValue )
         self._isAddingNum = false
         self:_onBtnTouch(widget, typeValue)
     end)
     self:registerBtnClickEvent("Button_add10",function()
         self._isAddingNum = true
         self:_doCountChange() 
     end)
     self:registerBtnClickEvent("Button_subtract10",function()
        self._isAddingNum = false
        self:_doCountChange()    
     end)
end

function FastRefineLayer:_onBtnTouch( widget, typeValue )
    if TOUCH_EVENT_BEGAN == typeValue then 
        self:scheduleUpdate(handler(self, self._onUpdate), 0)
    elseif TOUCH_EVENT_MOVED == typeValue then 
        if not widget then 
            self:_stopSchedule()
        end
        local curPt = widget:getTouchMovePos()
        if not widget:hitTest(curPt) then 
            self:_stopSchedule()
        end
    elseif TOUCH_EVENT_ENDED == typeValue then 
        self:_stopSchedule()
    elseif TOUCH_EVENT_CANCELED == typeValue then 
        self:_stopSchedule()
    end
end

function FastRefineLayer:_stopSchedule( ... )
    self:unscheduleUpdate()
    self._curTimeCost = 0
end

function FastRefineLayer:_onUpdate( dt )
    self._curTimeCost = self._curTimeCost + dt
    
    if self._curTimeCost > 0.2 then 
        self._curTimeCost = self._curTimeCost - 0.2
        self:_doCountChange()
    end    
end

function FastRefineLayer:_doCountChange( ... )
    if self._isAddingNum then 
        local curLevel = self._fastType == FastRefineLayer.TYPE_EQUIPMENT and self._item.refining_level or self._item.addition_lvl
        if self._maxLevel <= curLevel + self._tryBuyCount then
            return
        end
        local tempCount = self._buyCount == 1 and 9 or 10
        self._tryBuyCount = self._tryBuyCount + tempCount
        self._tryBuyCount = self._maxLevel <= curLevel + self._tryBuyCount and self._maxLevel - curLevel or self._tryBuyCount
        local cost = self:calcMyCost()
        if cost then
            self._buyCount = self._tryBuyCount
           self._cost = cost
           self:updateLabels()
       else
            for i = 1 , 9 do
                self._tryBuyCount = self._tryBuyCount - 1
                local finCost = self:calcMyCost()
                if finCost then
                    self._buyCount = self._tryBuyCount
                   self._cost = finCost
                   self:updateLabels()
                   return
               end
            end
            self._tryBuyCount = self._buyCount
       end
    else
        if self._buyCount <= 10 then
            self._buyCount = 1
        else
            self._buyCount = self._buyCount -10
        end
        self._tryBuyCount = self._buyCount
        self._cost = self:calcMyCost()
        self:updateLabels()
    end
end

function FastRefineLayer:onLayerEnter()
    FastRefineLayer.hasShow = true
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self:getImageViewByName("Image_bg"), "smoving_bounce")
end

function FastRefineLayer:onLayerExit()
    FastRefineLayer.hasShow = false
end

return FastRefineLayer

