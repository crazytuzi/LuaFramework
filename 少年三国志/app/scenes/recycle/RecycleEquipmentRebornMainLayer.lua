-- RecycleEquipmentRebornMainLayer
require "app.cfg.equipment_info"
require "app.cfg.item_info"

local RecycleEquipmentRebornMainLayer = class("RecycleEquipmentRebornMainLayer", UFCCSNormalLayer)

RecycleEquipmentRebornMainLayer.REBORN_PRICE = 50

function RecycleEquipmentRebornMainLayer.create(...)
    return RecycleEquipmentRebornMainLayer.new("ui_layout/recycle_equipmentRebornMainLayer.json", nil, ...)
end

function RecycleEquipmentRebornMainLayer:_updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
    assert(label ~= nil, "label is nil")
    if stroke then
        label:createStroke(stroke, 1)
    end
    if color then
        label:setColor(color)
    end
    
    label:setText(text)
end

function RecycleEquipmentRebornMainLayer:ctor(...)
    
    RecycleEquipmentRebornMainLayer.super.ctor(self, ...)
    
    -- 价格
    self:_updateLabel(self, "Label_price", RecycleEquipmentRebornMainLayer.REBORN_PRICE, Colors.strokeBrown)
    
    -- 绑定重生按钮
    self:registerBtnClickEvent("Button_reborn", function()
        self:onButtonRebornClicked()
    end)
    
    -- 特效
    local EffectNode = require "app.common.effects.EffectNode"
    local luzi = EffectNode.new("effect_luzi_down")
    local parent = self:getPanelByName("Panel_luzi")
    parent:addNode(luzi)
    luzi:setScale(0.5)

    local luzi_smoke = EffectNode.new("effect_luzi_up")
    luzi:addChild(luzi_smoke)
    
    local fire_left = nil
    local fire_right = nil
    local zb = nil
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        
        -- 背景特效
        fire_left = EffectNode.new("effect_fire")
        self:getPanelByName("Panel_fire_left"):addNode(fire_left)
        fire_left:setScale(0.5)     -- 0.5是因为设计的尺寸是按照原图尺寸，而现在背景图缩小了一半

        fire_right = EffectNode.new("effect_fire")
        self:getPanelByName("Panel_fire_right"):addNode(fire_right)
        fire_right:setScale(0.5)

        zb = EffectNode.new("effect_zbyc")
        parent = self:getImageViewByName("ImageView_8508")
        parent:addNode(zb)
        zb:setScale(0.5)
        zb:setPositionXY(parent:getSize().width * (0.5 - parent:getAnchorPoint().x), parent:getSize().height * (0.5 - parent:getAnchorPoint().y))

    end
    
    self._effectNode = {}
    self._effectNode.play = function()
        luzi:play()
        luzi_smoke:play()
        if fire_left then
            fire_left:play()
        end
        if fire_right then
            fire_right:play()
        end
        if zb then
            zb:play()
        end
    end
    
    self:registerBtnClickEvent("Button_help", function()
        self:onButtonHelpClicked()
    end)
    
end

function RecycleEquipmentRebornMainLayer:onLayerEnter()
    __Log("RecycleEquipmentRebornMainLayer:onLayerEnter")    
    self:resetSelectState()
    
    -- 播放特效
    if self._effectNode then
        self._effectNode:play()
    end
    __Log("RecycleEquipmentRebornMainLayer:onLayerEnter")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_REBORN_EQUIPMENT_PREVIEW, self._onRecycleRebornEvent, self)    
end

function RecycleEquipmentRebornMainLayer:_initSelecteds()
    
    -- 先获取全部的装备，挑选符合要求的装备
    self._equipments = G_Me.bagData:getRebornEquipmentList()
    for i=1, #self._equipments do
        local equipment = self._equipments[i]
        equipment.potentiality = equipment_info.get(equipment.base_id).potentiality
    end

    -- 排序，按照潜力从小到大，潜力一致则等级从大到小排序，等级一致则根据ID从小到大排序
    table.sort(self._equipments, function(a, b)
        return a.potentiality < b.potentiality or (a.potentiality == b.potentiality and (a.level > b.level or (a.level == b.level and a.base_id < b.base_id)))
    end)
    
end

function RecycleEquipmentRebornMainLayer:initSelectState(selectEquipments, anima)
    
    self._selectEquipments = selectEquipments or self._selectEquipments

    anima = anima == nil and true or anima
    
    -- 更新装备显示
    if self._selectEquipments and #self._selectEquipments >= 1 then
        
        self:getPanelByName("Panel_added"):setVisible(true)
        self:getImageViewByName("Image_54"):setSize(CCSizeMake(631, 200))
        self:getPanelByName("Panel_before_add"):setVisible(false)
        
        local equipment = self._selectEquipments[1]

        -- equipment的配置文件
        local equipmentConfig = equipment_info.get(equipment.base_id)

        -- 隐藏按钮
        self:getButtonByName("Button_selected"):setVisible(false)

        -- 显示图像
        local img = self:getImageViewByName("Image_selected")
        img:setVisible(true)

        -- 要做动画
        if anima then
            local positionOffsetY = -50
            img:setPositionY(img:getPositionY() + positionOffsetY * -1)
            local moveAction = CCEaseIn:create(CCMoveBy:create(0.2, ccp(0, positionOffsetY)), 0.2)
            img:runAction(moveAction)
        end

        img:loadTexture(G_Path.getEquipmentPic(equipmentConfig.res_id))

        self:getImageViewByName("Image_name"):setVisible(true)

        -- 名称
        local name = self:getLabelByName("Label_name")
        name:setColor(Colors.qualityColors[equipmentConfig.quality])
        name:createStroke(Colors.strokeBlack,1)
        name:setText(equipmentConfig.name)
        
        -- 强化
        self:_updateLabel(self, "Label_content_strength_desc", G_lang:get("LANG_RECYCLE_TREASURE_LEVEL_DESC"))
        self:_updateLabel(self, "Label_content_strength", G_lang:get("LANG_RECYCLE_TREASURE_LEVEL", {level=equipment.level}))

        -- 精炼
        self:_updateLabel(self, "Label_content_refine_desc", G_lang:get("LANG_RECYCLE_TREASURE_REFINE_DESC"))
        self:_updateLabel(self, "Label_content_refine", G_lang:get("LANG_RECYCLE_TREASURE_REFINE", {refine=equipment.refining_level}))

        -- 星级
        local starLevel = equipment.star
        if starLevel and equipmentConfig.quality > 4 then            
            self:showWidgetByName("Label_Star_Tag", true)
            self:showWidgetByName("Panel_Star", true)
            for i=1, 5 do
                self:getImageViewByName("Image_Star_"..i):setVisible(true)
            end
            -- 橙装满星只有3星，红装有5星
            if equipmentConfig.quality == 5 then
               self:getImageViewByName("Image_Star_4"):setVisible(false) 
               self:getImageViewByName("Image_Star_5"):setVisible(false) 
            end
            for i=1, 5 do
                self:getImageViewByName("Image_Star_Bright_"..i):setVisible(i <= starLevel)
            end
        else
            self:showWidgetByName("Label_Star_Tag", false)
            self:showWidgetByName("Panel_Star", false)
        end
    else        
        -- 显示按钮
        self:getButtonByName("Button_selected"):setVisible(true)
        self:getImageViewByName("Image_selected"):setVisible(false)
        self:getImageViewByName("Image_name"):setVisible(false)
        
        self:getPanelByName("Panel_added"):setVisible(false)
        self:getImageViewByName("Image_54"):setSize(CCSizeMake(631, 173))
        self:getPanelByName("Panel_before_add"):setVisible(true)                
    end
end

function RecycleEquipmentRebornMainLayer:_onRecycleRebornEvent(message)    
    local items = clone(rawget(message, "awards")) or {}
    
    table.sort(items, function(a, b)
        if a.type > b.type then
            return true  
        else 
            return a.value > b.value      
        end
    end)
    
    local RecyclePreviewLayer = require("app.scenes.recycle.RecyclePreviewLayer")
    local layer = RecyclePreviewLayer.create(RecyclePreviewLayer.LAYOUT_REBORN_TREASURE, {
        -- "装备重生后将会获得以下物品"
        {"Label_result_desc", {text=G_lang:get("LANG_RECYCLE_EQUIP_REBORN_PREVIEW_DESC")}},
        -- 消耗
        {"Label_price_desc", {text=G_lang:get("LANG_RECYCLE_TREASURE_REBORN_PRICE_DESC")}},
        -- 价格
        {"Label_price", {text=RecycleEquipmentRebornMainLayer.REBORN_PRICE, color=G_Me.userData.gold < RecycleEquipmentRebornMainLayer.REBORN_PRICE and ccc3(0xf2, 0x79, 0x0d) or nil}},
    })

    uf_sceneManager:getCurScene():addChild(layer)
    
    layer:registerBtnClickEvent("Button_ok", function()
             
        if G_Me.userData.gold < RecycleEquipmentRebornMainLayer.REBORN_PRICE then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
    
        local equipmentIds = {}
        table.insert(equipmentIds, self._selectEquipments[1].id)
        G_HandlersManager.recycleHandler:sendRebornEquipment(equipmentIds, 0)
        
        layer:animationToClose()
    end)
    
    -- 添加数据
    local datas = {}
    
    for i=1, #items do

        local goodConfig = G_Goods.convert(items[i].type, items[i].value)

        local item = {
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text="x"..items[i].size, stroke=Colors.strokeBlack}},
        }
        
        table.insert(datas, item)

    end
    
    layer:updateListView("Panel_list", datas)
    
end

function RecycleEquipmentRebornMainLayer:playRecycleAnimation()
    
    local effectNode = nil
    
    -- 返回一个控制函数
    return function(command, callback)
        
        command = command or "play"
        
        if command == "play" then

            -- 直接把事件通过回调往外抛
            effectNode = require("app.common.effects.EffectNode").new("effect_hotfire", callback)
            self:getPanelByName("Panel_effect"):addNode(effectNode)
            effectNode:play()
            effectNode:setScale(3)                        
        elseif command == "reset" then
            
            if effectNode then
                effectNode:removeFromParent()
                effectNode = nil
            end
            
            if callback then
                callback(command)
            end            
        end        
    end
end

function RecycleEquipmentRebornMainLayer:resetSelectState()    
    -- 更新当前的界面状态
    self:initSelectState{}   -- 初始化空表    
    -- 更新当前可选武将
    self:_initSelecteds()    
end

function RecycleEquipmentRebornMainLayer:getAvailableSelecteds()
    return self._equipments
end

function RecycleEquipmentRebornMainLayer:getSelecteds()
    return self._selectEquipments
end

function RecycleEquipmentRebornMainLayer:onButtonRebornClicked(  )
    if self._locked then return end

    local equipmentIds = {}
    table.insert(equipmentIds, self._selectEquipments[1].id)
    G_HandlersManager.recycleHandler:sendRebornEquipment(equipmentIds, 1)
end

function RecycleEquipmentRebornMainLayer:onButtonHelpClicked(  )
    -- protocal test
    -- local equipmentIds = {}
    -- table.insert(equipmentIds, 10667)
    -- -- table.insert(equipmentIds, 10694)
    -- G_HandlersManager.recycleHandler:sendRebornEquipment(equipmentIds, 0)

    require("app.scenes.common.CommonHelpLayer").show({
        {title=G_lang:get("LANG_RECYCLE_EQUIP_REBORN_TILTE"), content=G_lang:get("LANG_RECYCLE_EQUIP_REBORN_HELP_DESC")}
    } )
end

function RecycleEquipmentRebornMainLayer:onLayerExit(  )
    __Log("RecycleEquipmentRebornMainLayer:onLayerExit")
    uf_eventManager:removeListenerWithTarget(self)
end

function RecycleEquipmentRebornMainLayer:lock() self._locked = true end
function RecycleEquipmentRebornMainLayer:unlock() self._locked = false end

return RecycleEquipmentRebornMainLayer
