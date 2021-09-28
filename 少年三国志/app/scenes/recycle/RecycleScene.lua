-- RecycleScene

local TYPE_RECYCLE_KNIGHT          = 1
local TYPE_RECYCLE_EQUIPMENT       = 2
local TYPE_RECYCLE_REBORN          = 3
local TYPE_RECYCLE_EQUIP_REBORN    = 4
local TYPE_RECYCLE_TREASURE_REBORN = 5
local TYPE_RECYCLE_PET             = 6 -- 宠物分解
local TYPE_RECYCLE_PET_REBORN      = 7 -- 宠物重生

-- private method

local function _updateLabel(target, name, text, stroke, color)
    
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

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    assert(img ~= nil, "img is nil")
    img:loadTexture(texture, texType or UI_TEX_TYPE_LOCAL)
    
end

local RecycleScene = class("RecycleScene", UFCCSBaseScene)

RecycleScene.TYPE_RECYCLE_KNIGHT          = TYPE_RECYCLE_KNIGHT
RecycleScene.TYPE_RECYCLE_EQUIPMENT       = TYPE_RECYCLE_EQUIPMENT
RecycleScene.TYPE_RECYCLE_REBORN          = TYPE_RECYCLE_REBORN
RecycleScene.TYPE_RECYCLE_EQUIP_REBORN    = TYPE_RECYCLE_EQUIP_REBORN
RecycleScene.TYPE_RECYCLE_TREASURE_REBORN = TYPE_RECYCLE_TREASURE_REBORN
RecycleScene.TYPE_RECYCLE_PET             = TYPE_RECYCLE_PET
RecycleScene.TYPE_RECYCLE_PET_REBORN      = TYPE_RECYCLE_PET_REBORN

function RecycleScene:ctor(_, _, recycleType, _, scenePack, ...)
    
    RecycleScene.super.ctor(self)
    G_GlobalFunc.savePack(self, scenePack)

    self._controlLayer = UFCCSNormalLayer.new("ui_layout/recycle_rootMainLayer.json")
    self:addUILayerComponent("rootMainLayer",self._controlLayer,true)
    
    -- 绑定返回事件
    self._controlLayer:registerBtnClickEvent("Button_back", function()
        local packScene = G_GlobalFunc.createPackScene(self)
        if packScene then 
            uf_sceneManager:replaceScene(packScene)
        else
            GlobalFunc.popSceneWithDefault("app.scenes.mainscene.MainScene")
        end
        --uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end)
    
    recycleType = recycleType or TYPE_RECYCLE_KNIGHT
    
    -- 初始化tab页面
    self:_initLayerWithType(recycleType)
    
    -- tab页面切换按钮
    
    -- 武将分解
    _updateLabel(self._controlLayer, "Label_tab_left_check", G_lang:get("LANG_RECYCLE_KNIGHT_TITLE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_left_uncheck", G_lang:get("LANG_RECYCLE_KNIGHT_TITLE"))

    -- 装备分解
    _updateLabel(self._controlLayer, "Label_tab_right_check", G_lang:get("LANG_RECYCLE_EQUIPMENT_TITLE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_right_uncheck", G_lang:get("LANG_RECYCLE_EQUIPMENT_TITLE"))
    
    -- 武将重生
    _updateLabel(self._controlLayer, "Label_tab_right_reborn_check", G_lang:get("LANG_RECYCLE_REBORN_TITLE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_right_reborn_uncheck", G_lang:get("LANG_RECYCLE_REBORN_TITLE"))
    
    -- 装备重生
    _updateLabel(self._controlLayer, "Label_tab_equip_reborn_check", G_lang:get("LANG_RECYCLE_EQUIP_REBORN_TILTE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_equip_reborn_uncheck", G_lang:get("LANG_RECYCLE_EQUIP_REBORN_TILTE"))

    -- 宝物重生
    _updateLabel(self._controlLayer, "Label_tab_right_treasure_reborn_check", G_lang:get("LANG_RECYCLE_TREASURE_REBORN_TITLE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_right_treasure_reborn_uncheck", G_lang:get("LANG_RECYCLE_TREASURE_REBORN_TITLE"))

    -- 宠物分解
    _updateLabel(self._controlLayer, "Label_tab_pet_check", G_lang:get("LANG_RECYCLE_PET_TITLE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_pet_uncheck", G_lang:get("LANG_RECYCLE_PET_TITLE"))

    -- 宠物重生
    _updateLabel(self._controlLayer, "Label_tab_pet_reborn_check", G_lang:get("LANG_RECYCLE_PET_REBORN_TITLE"), Colors.strokeBrown)
    _updateLabel(self._controlLayer, "Label_tab_pet_reborn_uncheck", G_lang:get("LANG_RECYCLE_PET_REBORN_TITLE"))
    
    -- 绑定tab按钮
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_left")
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_right")
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_right_reborn")
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_right_equip_reborn")
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_right_treasure_reborn")
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_pet")
    self._controlLayer:addCheckBoxGroupItem(1, "CheckBox_tab_pet_Reborn")
    
    local key = "CheckBox_tab_left"
    if recycleType == TYPE_RECYCLE_EQUIPMENT then key = "CheckBox_tab_right"
    elseif recycleType == TYPE_RECYCLE_REBORN then key = "CheckBox_tab_right_reborn"
    elseif recycleType == TYPE_RECYCLE_EQUIP_REBORN then key = "CheckBox_tab_right_equip_reborn"
    elseif recycleType == TYPE_RECYCLE_TREASURE_REBORN then key = "CheckBox_tab_right_treasure_reborn"
    elseif recycleType == TYPE_RECYCLE_PET then key = "CheckBox_tab_pet"
    elseif recycleType == TYPE_RECYCLE_PET_REBORN then key = "CheckBox_tab_pet_Reborn"
    end
    self._controlLayer:setCheckStatus(1, key)
    
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_left", "Label_tab_left_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_left", "Label_tab_left_uncheck", false)

    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right", "Label_tab_right_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right", "Label_tab_right_uncheck", false)
    
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right_reborn", "Label_tab_right_reborn_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right_reborn", "Label_tab_right_reborn_uncheck", false)

    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right_equip_reborn", "Label_tab_equip_reborn_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right_equip_reborn", "Label_tab_equip_reborn_uncheck", false)
    
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right_treasure_reborn", "Label_tab_right_treasure_reborn_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_right_treasure_reborn", "Label_tab_right_treasure_reborn_uncheck", false)

    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_pet", "Label_tab_pet_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_pet", "Label_tab_pet_uncheck", false)

    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_pet_Reborn", "Label_tab_pet_reborn_check", true)
    self._controlLayer:addCheckNodeWithStatus("CheckBox_tab_pet_Reborn", "Label_tab_pet_reborn_uncheck", false)
    
    self._controlLayer:registerCheckBoxGroupEvent(function(groupId, oldName, newName, widget )
        if groupId == 1 then
            self._locked = false
            self._mainLayer:unlock()

            -- 动画执行回调，此时需要清空
            if self._curPlayInvoke then
                self._curPlayInvoke("reset")
                self._curPlayInvoke = nil
            end

            local FunctionLevelConst = require("app.const.FunctionLevelConst")
            
            if newName == "CheckBox_tab_left" then   --武将分解
                self:_initLayerWithType(TYPE_RECYCLE_KNIGHT)                
            elseif newName == "CheckBox_tab_right" then  -- 装备分解
                self:_initLayerWithType(TYPE_RECYCLE_EQUIPMENT)
            elseif newName == "CheckBox_tab_right_reborn" then  -- 武将重生
                self:_initLayerWithType(TYPE_RECYCLE_REBORN)
            elseif newName == "CheckBox_tab_right_equip_reborn" then  -- 装备重生
                self:_initLayerWithType(TYPE_RECYCLE_EQUIP_REBORN)
            elseif newName == "CheckBox_tab_right_treasure_reborn" then  -- 宝物重生
                self:_initLayerWithType(TYPE_RECYCLE_TREASURE_REBORN)
            elseif newName == "CheckBox_tab_pet" then  -- 宠物分解
                if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.RECYCLE_PET) then
                    self._controlLayer:setCheckStatus(1, oldName)
                    return
                end  
                self:_initLayerWithType(TYPE_RECYCLE_PET)
            elseif newName == "CheckBox_tab_pet_Reborn" then  -- 宠物重生  
                if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.RECYCLE_PET_REBORN) then
                    self._controlLayer:setCheckStatus(1, oldName)
                    return
                end 
                self:_initLayerWithType(TYPE_RECYCLE_PET_REBORN)
            end
            self:adapterLayerHeight(self._mainLayer,self._roleInfo,self._speedBar, 0, 0)
        end
    end)

end

function RecycleScene:_initLayerWithType(style)
    
    assert(style == TYPE_RECYCLE_KNIGHT
        or style == TYPE_RECYCLE_EQUIPMENT
        or style == TYPE_RECYCLE_REBORN 
        or style == TYPE_RECYCLE_EQUIP_REBORN
        or style == TYPE_RECYCLE_TREASURE_REBORN
        or style == TYPE_RECYCLE_PET
        or style == TYPE_RECYCLE_PET_REBORN
        , "Unknown recycle type: "..style)

    self._scrollViewButtons = {
        [TYPE_RECYCLE_KNIGHT]          = self._controlLayer:getCheckBoxByName("CheckBox_tab_left"),
        [TYPE_RECYCLE_EQUIPMENT]       = self._controlLayer:getCheckBoxByName("CheckBox_tab_right"),
        [TYPE_RECYCLE_REBORN]          = self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"),
        [TYPE_RECYCLE_EQUIP_REBORN]    = self._controlLayer:getCheckBoxByName("CheckBox_tab_right_equip_reborn"),
        [TYPE_RECYCLE_TREASURE_REBORN] = self._controlLayer:getCheckBoxByName("CheckBox_tab_right_treasure_reborn"),
        [TYPE_RECYCLE_PET]             = self._controlLayer:getCheckBoxByName("CheckBox_tab_pet"),
        [TYPE_RECYCLE_PET_REBORN]      = self._controlLayer:getCheckBoxByName("CheckBox_tab_pet_Reborn"),
    }
    
    self._scrollView = self._controlLayer:getScrollViewByName("ScrollView_20")

    local scrollView = self._scrollView
    local widget = self._scrollViewButtons[style]
    local widgetSize = scrollView:getSize()
    local containerSize = scrollView:getInnerContainerSize()
    local left = widget:getLeftInParent()
    local right = widget:getRightInParent()  
    local container = scrollView:getInnerContainer()
    local posx, posy = container:getPosition()
    if widgetSize.width < containerSize.width and 
        ((left + posx >= widgetSize.width) or ((right + posx) <= 0) or 
            ((left + posx < widgetSize.width) and (right + posx > widgetSize.width))) then   
        local per = 100*(left)/(containerSize.width - widgetSize.width)
        per = per > 100 and 100 or per
        scrollView:scrollToPercentHorizontal(per, 0, false)
    end

    self._controlLayer:showWidgetByName("Image_tab_knight_tip", G_Me.bagData:hasKnightToRecycle() and style ~= TYPE_RECYCLE_KNIGHT)
    self._controlLayer:showWidgetByName("Image_tab_equipment_tip", G_Me.bagData:hasEquipmentToRecycle() and style ~= TYPE_RECYCLE_EQUIPMENT)
    
    -- 先查找是否有已创建的layer
    local curLayer = nil
    if style == TYPE_RECYCLE_KNIGHT then
        curLayer = self._knightLayer
    elseif style == TYPE_RECYCLE_EQUIPMENT then
        curLayer = self._equipmentLayer
    elseif style == TYPE_RECYCLE_REBORN then
        curLayer = self._rebornLayer
    elseif style == TYPE_RECYCLE_EQUIP_REBORN then
        curLayer = self._equipRebornLayer
    elseif style == TYPE_RECYCLE_TREASURE_REBORN then
        curLayer = self._treasureRebornLayer
    elseif style == TYPE_RECYCLE_PET then
        curLayer = self._petLayer
    elseif style == TYPE_RECYCLE_PET_REBORN then
        curLayer = self._petRebornLayer
    end
    
    -- 选择一致则返回
    if curLayer and self._mainLayer == curLayer then
        return
    -- 不一致则替换，并初始化，此时需要清空之前已选择的项
    elseif curLayer and self._mainLayer ~= curLayer then
        self._mainLayer:onLayerExit()
        self._mainLayer:setVisible(false)
        -- 由于去掉了之前的来回addCompponent/removeCompponent导致onLayerEnter/Exit方法无法正常被回调
        -- 相应的操作无法被执行到，所以这里手动调用

        self._mainLayer = curLayer

        local comp = self:getComponent(SCENE_COMPONENT_GUI, curLayer.class.__cname)
        if not comp then 
            self:addUILayerComponent(curLayer.class.__cname, self._mainLayer, true)   
        else
            self._mainLayer:setVisible(true)
            self._mainLayer:onLayerEnter()
        end

        --self:removeComponent(SCENE_COMPONENT_GUI, "MainLayer")
        --self._mainLayer:setZOrder(-1)
        --self:addUILayerComponent("MainLayer",self._mainLayer,true)
    -- 没有则创建
    elseif not curLayer then
        if style == TYPE_RECYCLE_KNIGHT then
            curLayer = require("app.scenes.recycle.RecycleKnightMainLayer").create()
            curLayer:retain()  -- 保留起来为了下次不用加载直接使用, 这样加载速度比较快
            self._knightLayer = curLayer
        elseif style == TYPE_RECYCLE_EQUIPMENT then
            curLayer = require("app.scenes.recycle.RecycleEquipmentMainLayer").create()
            curLayer:retain()   -- 理由同上
            self._equipmentLayer = curLayer
        elseif style == TYPE_RECYCLE_REBORN then
            curLayer = require("app.scenes.recycle.RecycleRebornMainLayer").create()
            curLayer:retain()   -- 理由同上
            self._rebornLayer = curLayer
        elseif style == TYPE_RECYCLE_EQUIP_REBORN then
            curLayer = require("app.scenes.recycle.RecycleEquipmentRebornMainLayer").create()
            curLayer:retain()   -- 理由同上
            self._equipRebornLayer = curLayer
        elseif style == TYPE_RECYCLE_TREASURE_REBORN then
            curLayer = require("app.scenes.recycle.RecycleTreasureRebornMainLayer").create()
            curLayer:retain()   -- 理由同上
            self._treasureRebornLayer = curLayer
        elseif style == TYPE_RECYCLE_PET then
            curLayer = require("app.scenes.recycle.pet.RecyclePetMainLayer").create()
            curLayer:retain()   -- 理由同上
            self._petLayer = curLayer
        elseif style == TYPE_RECYCLE_PET_REBORN then
            curLayer = require("app.scenes.recycle.pet.RecyclePetRebornMainLayer").create()
            curLayer:retain()   -- 理由同上
            self._petRebornLayer = curLayer
        end

        
        if self._mainLayer then
            self._mainLayer:onLayerExit()
            self._mainLayer:setVisible(false)        
        end

        self._mainLayer = curLayer

        --self:removeComponent(SCENE_COMPONENT_GUI, "MainLayer")
        self._mainLayer:setZOrder(-1)

        self:addUILayerComponent(curLayer.class.__cname, self._mainLayer,true)   
    end
    
    -- 按钮的显示需要更新
    self._controlLayer:getButtonByName("Button_secret_shop"):setVisible(style == TYPE_RECYCLE_KNIGHT)
    self._controlLayer:getButtonByName("Button_secret_shop1"):setVisible(style == TYPE_RECYCLE_EQUIPMENT)
    self._controlLayer:getButtonByName("Button_secret_shop2"):setVisible(style == TYPE_RECYCLE_PET)
    
    -- 这里要注意，绑定之所以放在if外面是因为upvalue已经失效，需要重新绑定
    
    -- 神秘商店按钮
    self._controlLayer:registerBtnClickEvent("Button_secret_shop", function()
        local FunctionLevelConst = require "app.const.FunctionLevelConst"
        local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.SECRET_SHOP)
        if result then
            uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new(nil, nil, nil, nil, GlobalFunc.sceneToPack("app.scenes.recycle.RecycleScene")))
        end
    end)
    
    -- 神装商店按钮
    self._controlLayer:registerBtnClickEvent("Button_secret_shop1", function()
        local FunctionLevelConst = require "app.const.FunctionLevelConst"
        local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE)
        if result then
--            uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new())
            require("app.const.ShopType")
            uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.CHUANG_GUAN))
        end
    end)

    -- 战宠商店按钮
    self._controlLayer:registerBtnClickEvent("Button_secret_shop2", function()
        local FunctionLevelConst = require "app.const.FunctionLevelConst"
        local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET_SHOP)
        if result then
--            uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new())
            require("app.const.ShopType")
            uf_sceneManager:replaceScene(require("app.scenes.pet.shop.PetShopScene").new(nil, nil, nil, nil, GlobalFunc.sceneToPack("app.scenes.recycle.RecycleScene", {_, _, RecycleScene.TYPE_RECYCLE_PET})))
        end
    end)
    
    -- 绑定武将选择按钮事件
    local function _onSelectButtonTouch(widget, state)
        
        if self._locked then return end
        
        -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
        if not (not state or state == 2) then
            return
        end
        
        local curSelectLayer = nil
        if style == TYPE_RECYCLE_KNIGHT then
            curSelectLayer = self._selectKnightLayer
        elseif style == TYPE_RECYCLE_EQUIPMENT then
            curSelectLayer = self._selectEquipmentLayer
        elseif style == TYPE_RECYCLE_REBORN then
            curSelectLayer = self._selectRebornLayer
        elseif style == TYPE_RECYCLE_EQUIP_REBORN then
            curSelectLayer = self._selectEquipRebornLayer
        elseif style == TYPE_RECYCLE_TREASURE_REBORN then
            curSelectLayer = self._selectTreasureRebornLayer
        elseif style == TYPE_RECYCLE_PET then
            curSelectLayer = self._selectPetLayer
        elseif style == TYPE_RECYCLE_PET_REBORN then
            curSelectLayer = self._selectPetRebornLayer
        end

--        local available = {}
--        if style == TYPE_RECYCLE_KNIGHT then
--            available = self._knightLayer:getAvailableSelecteds()
--        elseif style == TYPE_RECYCLE_EQUIPMENT then
--            available = self._equipmentLayer:getAvailableSelecteds()
--        end
        local available = self._mainLayer:getAvailableSelecteds()
        
        -- 如果没有可归隐/重铸的武将/装备则直接提示
        if table.nums(available) == 0 then
            if style == TYPE_RECYCLE_KNIGHT then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_KNIGHT_EMPTY"))
            elseif style == TYPE_RECYCLE_EQUIPMENT then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_EQUIPMENT_EMPTY"))
            elseif style == TYPE_RECYCLE_REBORN then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_REBORN_EMPTY"))
            elseif style == TYPE_RECYCLE_EQUIP_REBORN then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_REBORN_EQUIPMENT_EMPTY"))
            elseif style == TYPE_RECYCLE_TREASURE_REBORN then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_TREASURE_REBORN_EMPTY"))
            elseif style == TYPE_RECYCLE_PET then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_PET_EMPTY"))
            elseif style == TYPE_RECYCLE_PET_REBORN then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_PET_REBORN_EMPTY"))
            end
            return
        end
        
--        local selects = {}
--        if style == TYPE_RECYCLE_KNIGHT then
--            selects = self._knightLayer:getSelecteds()
--        elseif style == TYPE_RECYCLE_EQUIPMENT then
--            selects = self._equipmentLayer:getSelecteds()
--        end
        local selects = clone(self._mainLayer:getSelecteds())
        
        if curSelectLayer then
            curSelectLayer:initSelectState(available, selects)
        elseif not curSelectLayer then
            if style == TYPE_RECYCLE_KNIGHT then
                curSelectLayer = require("app.scenes.recycle.RecycleSelectKnightLayer").create(available, selects)
                curSelectLayer:retain()
                self._selectKnightLayer = curSelectLayer
            elseif style == TYPE_RECYCLE_EQUIPMENT then
                curSelectLayer = require("app.scenes.recycle.RecycleSelectEquipmentLayer").create(available, selects)
                curSelectLayer:retain()
                self._selectEquipmentLayer = curSelectLayer
            elseif style == TYPE_RECYCLE_REBORN then
                curSelectLayer = require("app.scenes.recycle.RecycleSelectRebornLayer").create(available, selects, function()
                    -- 更换当前的layer
                    self._mainLayer:initSelectState(curSelectLayer:getSelecteds())
                    curSelectLayer:removeFromParent()
                end)
                curSelectLayer:retain()
                self._selectRebornLayer = curSelectLayer
            elseif style == TYPE_RECYCLE_EQUIP_REBORN then
                curSelectLayer = require("app.scenes.recycle.RecycleSelectEquipRebornLayer").create(available, selects, function()
                    -- 更换当前的layer
                    self._mainLayer:initSelectState(curSelectLayer:getSelecteds())
                    curSelectLayer:removeFromParent()
                end)
                curSelectLayer:retain()
                self._selectEquipRebornLayer = curSelectLayer
            elseif style == TYPE_RECYCLE_TREASURE_REBORN then
                curSelectLayer = require("app.scenes.recycle.RecycleSelectTreasureRebornLayer").create(available, selects, function()
                    -- 更换当前的layer
                    self._mainLayer:initSelectState(curSelectLayer:getSelecteds())
                    curSelectLayer:removeFromParent()
                end)
                curSelectLayer:retain()
                self._selectTreasureRebornLayer = curSelectLayer
            elseif style == TYPE_RECYCLE_PET then
                curSelectLayer = require("app.scenes.recycle.pet.RecycleSelectPetLayer").create(available, selects, function()
                    -- 更换当前的layer
                    self._mainLayer:initSelectState(curSelectLayer:getSelecteds())
                    curSelectLayer:removeFromParent()
                end)
                curSelectLayer:retain()
                self._selectPetLayer = curSelectLayer
            elseif style == TYPE_RECYCLE_PET_REBORN then
                curSelectLayer = require("app.scenes.recycle.pet.RecycleSelectPetRebornLayer").create(available, selects, function()
                    -- 更换当前的layer
                    self._mainLayer:initSelectState(curSelectLayer:getSelecteds())
                    curSelectLayer:removeFromParent()
                end)
                curSelectLayer:retain()
                self._selectPetRebornLayer = curSelectLayer
            end
        end
        
--        uf_notifyLayer:getModelNode():addChild(curSelectLayer)
        uf_sceneManager:getCurScene():addChild(curSelectLayer)

        -- 绑定确定按钮
        curSelectLayer:registerBtnClickEvent("Button_certain", function()
            -- 更换当前的layer
            self._mainLayer:initSelectState(curSelectLayer:getSelecteds())
            curSelectLayer:removeFromParent()
        end)
        
        -- 绑定返回按钮
        curSelectLayer:registerBtnClickEvent("Button_back", function()
            -- 返回
            curSelectLayer:removeFromParent()
        end)
        
    end
    
    self._mainLayer:registerBtnClickEvent("Button_selected", _onSelectButtonTouch)

    self._mainLayer:registerBtnClickEvent("Button_selected1", _onSelectButtonTouch)
    self._mainLayer:registerBtnClickEvent("Button_selected2", _onSelectButtonTouch)
    self._mainLayer:registerBtnClickEvent("Button_selected3", _onSelectButtonTouch)
    self._mainLayer:registerBtnClickEvent("Button_selected4", _onSelectButtonTouch)
    self._mainLayer:registerBtnClickEvent("Button_selected5", _onSelectButtonTouch)
    
    -- 按钮闪烁
    for i=1, 5 do
        local btn = self._mainLayer:getButtonByName("Button_selected"..i)
        if btn then
            btn:stopAllActions()
            btn:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(1), CCFadeIn:create(1))))
        end
    end
    
    self._mainLayer:registerWidgetTouchEvent("Image_selected", _onSelectButtonTouch)
    
    self._mainLayer:registerWidgetTouchEvent("ImageView_selected1", _onSelectButtonTouch)
    self._mainLayer:registerWidgetTouchEvent("ImageView_selected2", _onSelectButtonTouch)
    self._mainLayer:registerWidgetTouchEvent("ImageView_selected3", _onSelectButtonTouch)
    self._mainLayer:registerWidgetTouchEvent("ImageView_selected4", _onSelectButtonTouch)
    self._mainLayer:registerWidgetTouchEvent("ImageView_selected5", _onSelectButtonTouch)

    self._mainLayer:registerWidgetTouchEvent("Panel_Click", _onSelectButtonTouch)
    
    if self._valueChanger then
        self._valueChanger:stop()
        self._valueChanger = nil
    end
    
    self._lastValue = style == TYPE_RECYCLE_KNIGHT and G_Me.userData.essence or
     (style == TYPE_RECYCLE_EQUIPMENT and G_Me.userData.tower_score or
        (style == TYPE_RECYCLE_PET and G_Me.userData.pet_points or nil))
    -- 更新将魂/爬塔积分的显示
    self:_updateRecycleIcon(style)
    
end

function RecycleScene:_updateRecycleIcon(style, withAnimation)
    
    local recycleIcon = self._controlLayer:getPanelByName("Panel_recycle_icon")
    if not (style == TYPE_RECYCLE_KNIGHT or style == TYPE_RECYCLE_EQUIPMENT
        or style == TYPE_RECYCLE_PET) then
        recycleIcon:setVisible(false)
        return
    else
        recycleIcon:setVisible(true)
    end
    
    if style == TYPE_RECYCLE_KNIGHT then
        _updateImageView(self._controlLayer, "Image_recycle_icon", G_Goods.convert(G_Goods.TYPE_WUHUN).icon_mini, UI_TEX_TYPE_PLIST)
        _updateLabel(self._controlLayer, "Label_recycle_icon_desc", G_lang:get("LANG_RECYCLE_KNIGHT_ESSENCE_DESC"), Colors.strokeBrown)
    elseif style == TYPE_RECYCLE_EQUIPMENT then
        _updateImageView(self._controlLayer, "Image_recycle_icon", G_Goods.convert(G_Goods.TYPE_CHUANGUAN).icon_mini, UI_TEX_TYPE_PLIST)
        _updateLabel(self._controlLayer, "Label_recycle_icon_desc", G_lang:get("LANG_RECYCLE_EQUIPMENT_WEIMING_DESC"), Colors.strokeBrown)
    elseif style == TYPE_RECYCLE_PET then
        _updateImageView(self._controlLayer, "Image_recycle_icon", G_Goods.convert(G_Goods.TYPE_PET_SCORE).icon_mini, UI_TEX_TYPE_PLIST)
        _updateLabel(self._controlLayer, "Label_recycle_icon_desc", G_lang:get("LANG_RECYCLE_PET_SHOUHUN_DESC"), Colors.strokeBrown)
    end
    
    -- 是否有动画
    if withAnimation then
        
        if self._valueChanger then
            self._valueChanger:stop()
            self._valueChanger = nil
        end
        
        local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
        local label = self._controlLayer:getLabelByName("Label_recycle_icon_amount")
        local _newValue = style == TYPE_RECYCLE_KNIGHT and G_Me.userData.essence or
         (style == TYPE_RECYCLE_EQUIPMENT and G_Me.userData.tower_score or
            (style == TYPE_RECYCLE_PET and G_Me.userData.pet_points or nil))
         if _newValue ~= nil and self._lastValue ~= nil then
            self._valueChanger = NumberScaleChanger.new(label,  self._lastValue, _newValue,
                function(value)
                    self:_updateRecycleInfo(value)
                end
            )
        end
        
    else
        if style == TYPE_RECYCLE_KNIGHT then
            self:_updateRecycleInfo(G_Me.userData.essence)
        elseif style == TYPE_RECYCLE_EQUIPMENT then
            self:_updateRecycleInfo(G_Me.userData.tower_score)
        elseif style == TYPE_RECYCLE_PET then
            self:_updateRecycleInfo(G_Me.userData.pet_points)
        end
    end

end

function RecycleScene:_updateRecycleInfo( value )
    local amountLabel = self._controlLayer:getLabelByName("Label_recycle_icon_amount")
    local widthPre = amountLabel:getSize().width
    _updateLabel(self._controlLayer, "Label_recycle_icon_amount", value, Colors.strokeBrown)
    local widthCurr = amountLabel:getSize().width
    local offsetX = widthCurr - widthPre
    self:_updateWidgetPosistion(self._controlLayer, "Image_recycle_icon", offsetX, 0)
    self:_updateWidgetPosistion(self._controlLayer, "Label_recycle_icon_desc", offsetX, 0)
end

function RecycleScene:_updateWidgetPosistion( layer, name, offsetX, offsetY )
    local widget = layer:getWidgetByName(name)
    -- __Log("offsetX = %d", offsetX)
    widget:setPositionX(widget:getPositionX() - offsetX)
end

function RecycleScene:onSceneEnter()
    --在装备回收,动画播放时,点神装商店,pop回来,无法添加bug,所以这里解锁
    self._locked = false
    -- 初始化界面
    self._roleInfo = G_commonLayerModel:getShopRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    self:adapterLayerHeight(self._controlLayer, self._roleInfo, self._speedBar, -10, 0)
    self:adapterLayerHeight(self._mainLayer,self._roleInfo,self._speedBar, 0, 0)
    
    -- 绑定归隐服务器消息
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_RESULT, self._onRecycleResultEvent, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_EQUIPMENT_RESULT, self._onRecycleEquipmentEvent, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_TREASURE_RESULT, self._onRecycleTreasureEvent, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_PET_RESULT, self._onRecyclePetEvent, self)
--    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_EQUIPMENT, self._onRecycleEquipmentEvent, self)
--    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_REBORN, self._onRecycleRebornEvent, self)

    -- 装备重生
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_REBORN_EQUIPMENT_RESULT, self._onRecycleEquipmentRebornEvent, self)

end

function RecycleScene:onSceneUnload()
   -- self:removeComponent(SCENE_COMPONENT_GUI, "MainLayer")
    
    if self._knightLayer then
        self._knightLayer:release()
        self._knightLayer = nil
    end
    if self._equipmentLayer then
        self._equipmentLayer:release()
        self._equipmentLayer = nil
    end
    if self._treasureRebornLayer then 
        self._treasureRebornLayer:release()
        self._treasureRebornLayer = nil
    end
    if self._rebornLayer then
        self._rebornLayer:release()
        self._rebornLayer = nil
    end
    if self._equipRebornLayer then 
        self._equipRebornLayer:release()
        self._equipRebornLayer = nil
    end
    if self._petLayer then
        self._petLayer:release()
        self._petLayer = nil
    end
    if self._petRebornLayer then
        self._petRebornLayer:release()
        self._petRebornLayer = nil
    end

    
    -- 释放保存的selectLayer
    if self._selectKnightLayer then
        self._selectKnightLayer:release()
        self._selectKnightLayer = nil
    end
    if self._selectEquipmentLayer then
        self._selectEquipmentLayer:release()
        self._selectEquipmentLayer = nil
    end
    if self._selectRebornLayer then
        self._selectRebornLayer:release()
        self._selectRebornLayer = nil
    end
    if self._selectTreasureRebornLayer then
        self._selectTreasureRebornLayer:release()
        self._selectTreasureRebornLayer = nil
    end
    if self._selectPetLayer then
        self._selectPetLayer:release()
        self._selectPetLayer = nil
    end
    if self._selectPetRebornLayer then
        self._selectPetRebornLayer:release()
        self._selectPetRebornLayer = nil
    end
    if self._selectEquipRebornLayer then
        self._selectEquipRebornLayer:release()
        self._selectEquipRebornLayer = nil
    end
end

function RecycleScene:onSceneExit()
    
    if self._valueChanger then
        self._valueChanger:stop()
        self._valueChanger = nil
    end
    
    -- 移除公共UI部分
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "Notice")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    
    uf_eventManager:removeListenerWithTarget(self)

end

function RecycleScene:_onRecycleResultEvent(message)
    local recycleType = rawget(message, "type")
    if recycleType == 0 then self:_onRecycleKnightEvent(message)
    elseif recycleType == 1 then self:_onRecycleRebornEvent(message)
    end
end

function RecycleScene:_onRecycleKnightEvent(message)

    -- 锁定当前页面，这个时候不能切换，否则动画会被暂停，直到下一次切换回来
    self._locked = true
    self._mainLayer:lock()
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(false)
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(false)
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(false)
    
    self._curPlayInvoke = self._mainLayer:playRecycleAnimation()
    
    self._curPlayInvoke("play", function(event)

        if event == "finish" then
            
            -- 更新将魂/爬塔积分的显示
            self:_updateRecycleIcon(TYPE_RECYCLE_KNIGHT, true)
            
            self._curPlayInvoke("reset")
            self._curPlayInvoke = nil

            -- 清空当前界面的状态
            self._mainLayer:resetSelectState()
            -- 解除锁定
            self._locked = false
            self._mainLayer:unlock()
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(true)
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(true)
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(true)

            local item = rawget(message, "item") or {}
            local knights = rawget(message, "knight_food") or {}
            local essence = rawget(message, "essence")
            local money = rawget(message, "money")

            local _knights = {}
            local index = 1
            for i=1, #knights do
                if #_knights == 0 then
                    _knights[index] = _knights[index] or {id=knights[i], size=1}
                else
                    local bMatch = false
                    for j=1, #_knights do
                        if _knights[j].id == knights[i] then
                            bMatch = true
                            _knights[j].size = _knights[j].size + 1
                            break
                        end
                    end
                    if not bMatch then
                        index = index + 1
                        _knights[index] = _knights[index] or {id=knights[i], size=1}
                    end
                end
            end

            knights = _knights

            local count = (#knights > 0 and 1 or 0) + (#item > 0 and 1 or 0) + (essence and 1 or 0) + (money and 1 or 0)

            -- 弹框提示获取了什么奖励
            local awards = {}
            while #awards < math.min(3, count) do
                if table.nums(knights) > 0 then
                    awards[#awards+1] = {type = 4, value = knights[1].id, size = knights[1].size}
                    knights = {}
                elseif table.nums(item) > 0 then
                    awards[#awards+1] = {type = item[1].type, value = item[1].value, size = item[1].num}
                    item = {}
                elseif essence then
                    awards[#awards+1] = {type = 13, size = essence}
                    essence = nil
                elseif money then
                    awards[#awards+1] = {type = 1, size = money}
                    money = nil
                end
            end

            -- 红色武将额外返还物品
            local extraItem = rawget(message, "award")
            if extraItem then
                local awardsExtra = message.award
                -- 返回的红色武将精华数量
                local hongsewujiangjinghuaNum = 0
                for i=1, #awardsExtra do
                    if awardsExtra[i].type == 3 and awardsExtra[i].value == 3 then
                        -- 红色武将精华
                        hongsewujiangjinghuaNum = hongsewujiangjinghuaNum + awardsExtra[i].size
                    else
                        awards[#awards + 1] = {type = awardsExtra[i].type, value = awardsExtra[i].value, size = awardsExtra[i].size}
                    end
                end

                if hongsewujiangjinghuaNum > 0 then
                    awards[#awards + 1] = {type = 3, value = 3, size = hongsewujiangjinghuaNum}
                end
            end

            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards, function ( ... )
                if self._mainLayer and self._mainLayer.__EFFECT_FINISH_CALLBACK__ then 
                    self._mainLayer.__EFFECT_FINISH_CALLBACK__()
                end
            end)
            uf_sceneManager:getCurScene():addChild(_layer)

        end
    end)
    
end

function RecycleScene:_onRecycleEquipmentEvent(message)

    self._locked = true
    self._mainLayer:lock()
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(false)
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(false)
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(false)
    
    self._curPlayInvoke = self._mainLayer:playRecycleAnimation()
    
    self._curPlayInvoke("play", function(event)
        
        if event == "finish" then
            
            -- 更新将魂/爬塔积分的显示
            self:_updateRecycleIcon(TYPE_RECYCLE_EQUIPMENT, true)
            
            self._curPlayInvoke("reset")
            self._curPlayInvoke = nil
            
            -- 清空当前界面的状态
            self._mainLayer:resetSelectState()
            -- 解除锁定
            self._locked = false
            self._mainLayer:unlock()
--            self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(true)
--            self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(true)
--            self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(true)

        elseif event == "appear" then

            -- local money = rawget(message, "money")
            -- local refining = rawget(message, "refining") or 0
            -- local towerScore = rawget(message, "towerScore")
            
            -- -- 精炼石需要根据需求从大到小计算，先排满50的，再排满25的，10的，5的
            -- local _refining = {}
            -- local total = refining * 5 -- 默认服务器发来的是按照5的计算的
            -- local mod = function(amount, factor)
            --     return math.floor(amount / factor)
            -- end

            -- local ItemConst = require("app.const.ItemConst")

            -- _refining = {
            --     {amount = mod(total, 50), item = ItemConst.ITEM_ID.REFINE_ITEM4},
            --     {amount = mod(total % 50, 25), item = ItemConst.ITEM_ID.REFINE_ITEM3},
            --     {amount = mod(total % 50 % 25, 10), item = ItemConst.ITEM_ID.REFINE_ITEM2},
            --     {amount = mod(total % 50 % 25 % 10, 5), item = ItemConst.ITEM_ID.REFINE_ITEM1},
            -- }

            -- refining = {}
            -- for i=1, #_refining do
            --     if _refining[i].amount > 0 then
            --         refining[#refining+1] = _refining[i]
            --     end
            -- end
            
            -- 弹框提示获取了什么奖励
            local awards = {}
            -- local count = (money and 1 or 0) + #refining + (towerScore and 1 or 0)
            -- for i=1, math.min(3, count) do
            --     if i<=#refining then
            --         awards[#awards+1] = {type = 3, value = refining[i].item, size = refining[i].amount}
            --     elseif money then
            --         awards[#awards+1] = {type = 1, size = money}
            --         money = nil
            --     elseif towerScore then
            --         awards[#awards+1] = {type = 16, size = towerScore}
            --         towerScore = nil
            --     end
            -- end

            if rawget(message, "awards") then
                local extraAwards = message.awards
                for i,v in ipairs(extraAwards) do
                    table.insert(awards, v)
                end
            end    

            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
            uf_sceneManager:getCurScene():addChild(_layer)

        end
        
    end)
    
end

function RecycleScene:_onRecycleEquipmentRebornEvent( message )
    self._locked = true
    self._mainLayer:lock()
    
    self._curPlayInvoke = self._mainLayer:playRecycleAnimation()
    
    self._curPlayInvoke("play", function(event)

        if event == "finish" then
             
            self._curPlayInvoke("reset")
            self._curPlayInvoke = nil

            -- 清空当前界面的状态
            self._mainLayer:resetSelectState()
            -- 解除锁定
            self._locked = false
            self._mainLayer:unlock()

            local items = clone(rawget(message, "awards")) or {}
            
            -- 排序
            table.sort(items, function(a, b)
                if a.type > b.type then
                    return true
                elseif a.type == b.type then
                    return a.value > b.value
                end
            end)

            local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(items, function () end)
            uf_sceneManager:getCurScene():addChild(layer)

        end
    end)
end

function RecycleScene:_onRecycleRebornEvent(message)
    
    self._mainLayer:resetSelectState()
    
    local award = rawget(message, "award") or {}
    local knights = rawget(message, "knight_food") or {}
    local essence = rawget(message, "essence")
    local money = rawget(message, "money")
    local item = rawget(message, "item") or {}

    local _knights = {}
    for i=1, #knights do
        local bMatch = false
        for j=1, #_knights do
            if _knights[j].id == knights[i] then
                bMatch = true
                _knights[j].size = _knights[j].size + 1
                break
            end
        end
        if not bMatch then
            _knights[#_knights+1] = {id=knights[i], size=1}
        end
    end

    knights = _knights 

    -- 弹框提示获取了什么奖励
    local awards = {}
    local count = (#knights > 0 and 1 or 0) + (#award > 0 and 1 or 0) + (essence and 1 or 0) + (money and 1 or 0) + (#item > 0 and 1 or 0)

    while(#awards < math.min(3, count)) do
        if table.nums(knights) > 0 then
            awards[#awards+1] = {type = 4, value = knights[1].id, size = knights[1].size}
            knights = {}
        elseif table.nums(award) > 0 then
            local fragmentNum = 0
            -- 这里因为重生以后只有一种碎片，这里需要把碎片的数量加一下
            local fragmentType = 0
            local fragmentValue = 0

            for i=1,table.nums(award) do
                if award[i].type == G_Goods.TYPE_KNIGHT then
                    -- 觉醒道具可以放到后面显示
                    awards[#awards+1] = {type = award[i].type, value = award[i].value, size = award[i].size}
                else
                    fragmentNum = fragmentNum + award[i].size
                    if fragmentType == 0 then fragmentType = award[i].type end
                    if fragmentValue == 0 then fragmentValue = award[i].value end
                end
            end
            if fragmentNum > 0 then
                awards[#awards+1] = {type = fragmentType, value = fragmentValue, size = fragmentNum}
            end
            award = {}
        elseif essence then
            awards[#awards+1] = {type = 13, size = essence}
            essence = nil
        elseif money then
            awards[#awards+1] = {type = 1, size = money}
            money = nil
        elseif table.nums(item) > 0 then
            for i = 1, table.nums(item) do 
                awards[#awards + 1] = {type = item[i].type, value = item[i].value, size = item[i].num}
            end
            item = {}
        end
    end
    
    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
    uf_sceneManager:getCurScene():addChild(_layer)

end

function RecycleScene:_onRecycleTreasureEvent(message)
    
    -- 锁定当前页面，这个时候不能切换，否则动画会被暂停，直到下一次切换回来
    self._locked = true
    self._mainLayer:lock()
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(false)
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(false)
--    self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(false)
    
    self._curPlayInvoke = self._mainLayer:playRecycleAnimation()
    
    self._curPlayInvoke("play", function(event)

        if event == "finish" then
             
            self._curPlayInvoke("reset")
            self._curPlayInvoke = nil

            -- 清空当前界面的状态
            self._mainLayer:resetSelectState()
            -- 解除锁定
            self._locked = false
            self._mainLayer:unlock()
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(true)
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(true)
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(true)

            local item = clone(rawget(message, "item")) or {}
            
            -- 排序，按照宝物，道具，银两的形式排放
            table.sort(item, function(a, b)
                if a.type > b.type then
                    return true
                elseif a.type == b.type then
                    if a.type == G_Goods.TYPE_TREASURE then
                        require "app.cfg.treasure_info"
                        local treasureA = treasure_info.get(a.value)
                        local treasureB = treasure_info.get(b.value)
                        return treasureA.potentiality > treasureB.potentiality
                    end
                end
            end)

            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(item, function ( ... )
                if self._mainLayer and self._mainLayer.__EFFECT_FINISH_CALLBACK__ then 
                    self._mainLayer.__EFFECT_FINISH_CALLBACK__()
                end
            end)
            uf_sceneManager:getCurScene():addChild(_layer)

        end
    end)
    
end

function RecycleScene:_onRecyclePetEvent(message)

    -- 锁定当前页面，这个时候不能切换，否则动画会被暂停，直到下一次切换回来
    self._locked = true
    self._mainLayer:lock()

    -- self._curPlayInvoke = self._mainLayer:playRecycleAnimation()      
    
    -- self._curPlayInvoke("play", function(event)

    --     if event == "finish" then
             
    --         self._curPlayInvoke("reset")
    --         self._curPlayInvoke = nil

            -- 更新将魂/爬塔积分的显示
            if self._lastValue ~= nil then
                self:_updateRecycleIcon(TYPE_RECYCLE_PET, true)
            end

            -- 清空当前界面的状态
            self._mainLayer:resetSelectState()
            -- 解除锁定
            self._locked = false
            self._mainLayer:unlock()
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_left"):setEnabled(true)
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_right"):setEnabled(true)
--                self._controlLayer:getCheckBoxByName("CheckBox_tab_right_reborn"):setEnabled(true)

            local item = clone(rawget(message, "item")) or {}
            local money = rawget(message, "money") and message.money or 0
            local fight_score = rawget(message, "fight_score") and message.fight_score or 0

            if money and money > 0 then table.insert(item, {type = G_Goods.TYPE_MONEY, size = money}) end
            if fight_score and fight_score > 0 then table.insert(item, {type = G_Goods.TYPE_PET_SCORE, size = fight_score}) end

            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(item, function ( ... )
                if self._mainLayer and self._mainLayer.__EFFECT_FINISH_CALLBACK__ then 
                    self._mainLayer.__EFFECT_FINISH_CALLBACK__()
                end
            end)
            uf_sceneManager:getCurScene():addChild(_layer)

    --     end
    -- end)
end

return RecycleScene
