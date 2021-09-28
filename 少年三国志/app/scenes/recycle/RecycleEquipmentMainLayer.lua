-- RecycleEquipmentMainLayer

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
    img:loadTexture(texture, texType)
    
end

require "app.cfg.equipment_info"
require "app.cfg.item_info"

local EffectNode = require "app.common.effects.EffectNode"

local RecycleEquipmentMainLayer = class("RecycleEquipmentMainLayer", UFCCSNormalLayer)

function RecycleEquipmentMainLayer.create(...)
    return RecycleEquipmentMainLayer.new("ui_layout/recycle_equipmentMainLayer.json", ...)
end

function RecycleEquipmentMainLayer:ctor(...)
    
    RecycleEquipmentMainLayer.super.ctor(self, ...)
    
    -- 绑定归隐按钮
    self:registerBtnClickEvent("Button_recycle", function()
        self:onButtonRecycleClicked()       
    end)
    
    -- 绑定自动添加
    self:registerBtnClickEvent("Button_auto_add", function()
        self:onButtonAutoAddClicked()        
    end)
    
    -- 特效
    local EffectNode = require "app.common.effects.EffectNode"
    local luzi = EffectNode.new("effect_luzi_down")
    local parent = self:getPanelByName("Panel_luzi")
    parent:addNode(luzi)
    luzi:setScale(0.7)

    self._luzi = luzi

    local luzi_smoke = EffectNode.new("effect_luzi_up")
    luzi:addChild(luzi_smoke)
--    luzi_smoke:setPosition(self:convertToNodeSpace(luzi:getParent():convertToWorldSpace(ccp(luzi:getPosition()))))
--    luzi_smoke:setScale(luzi:getScale())
    
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
        zb:setPosition(ccp(parent:getSize().width * (0.5 - parent:getAnchorPoint().x), parent:getSize().height * (0.5 - parent:getAnchorPoint().y)))

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
    
    self:getLabelByName("Label_equip_tip_1"):setText(G_lang:get("LANG_RECYCLE_EQUIPMENT_TIPS"))
    self:enableLabelStroke("Label_equip_tip_1", Colors.strokeBrown, 1 )
    
    self:registerBtnClickEvent("Button_help", function()
        self:onButtonHelpClicked()
    end)
    
end

function RecycleEquipmentMainLayer:onButtonRecycleClicked(  )
    if self._locked then return end
        
    -- 如果没有可重铸的装备则直接提示
    if table.nums(self._equipments) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_EQUIPMENT_EMPTY"))
        return
    end
    
    -- 未选中则提示
    if table.nums(self._selectEquipments) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_EQUIPMENT_EMPTY"))
        return
    end
    
    local equipments = {equip_id = {}, type=1}
    for k, equipment in pairs(self._selectEquipments) do
        equipments.equip_id[#equipments.equip_id+1] = equipment.id
    end
    G_HandlersManager.recycleHandler:sendRecycleEquipment(equipments, 1)
end

function RecycleEquipmentMainLayer:onButtonAutoAddClicked(  )
    if self._locked then return end
        
    local btn = self:getButtonByName("Button_auto_add")
    btn:removeAllNodes()
    
    -- 单位已满
    if table.nums(self._selectEquipments) >= 5 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_EQUIPMENT_FULL"))
        return
    end
    
    -- 已无剩余
    if table.nums(self._selectEquipments) == table.nums(self._equipments) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_EQUIPMENT_NO_REMAIN"))
        return
    end
    
    -- 除橙色级别以外已无剩余
    local _equipmentList = {}
    for i=1, #self._equipments do
        local equipment = self._equipments[i]
        local equipmentConfig = equipment_info.get(equipment.base_id)
        assert(equipmentConfig, "Could not find the equipment info with id: "..equipment.base_id)
        
        if equipmentConfig.potentiality < 20 then
           _equipmentList[#_equipmentList+1] = equipment 
        end
    end
    
    if #_equipmentList == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_EQUIPMENT_QUALITY_NO_REMAIN"))
        return
    end
    
    -- 如果没有可重铸的装备则直接提示
    if table.nums(self._equipments) == 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_EQUIPMENT_EMPTY"))
        return
    end
    
    local index = 1
    while table.nums(self._selectEquipments) < 5 and self._equipments[index] do
        
        local equipment = self._equipments[index]
        local equipConfig = equipment_info.get(equipment.base_id)
        assert(equipConfig, "Could not find the equipment info with id: "..equipment.base_id)
        
        if not self._selectEquipments[index] and equipConfig.potentiality < 20 then
            self._selectEquipments[index] = self._equipments[index]
        end
        index = index + 1
    end 

    self:initSelectState()
end

function RecycleEquipmentMainLayer:onButtonHelpClicked(  )
    -- protocal test
    -- local equipments = {equip_id = {}, type=0}        
    -- table.insert(equipments.equip_id, 106663)
    -- table.insert(equipments.equip_id, 10663)
    -- G_HandlersManager.recycleHandler:sendRecycleEquipment(equipments)
    
    require("app.scenes.common.CommonHelpLayer").show({
        {title=G_lang:get("LANG_RECYCLE_EQUIPMENT_TITLE"), content=G_lang:get("LANG_RECYCLE_EQUIPMENT_HELP_DESC")}
    } )
end

function RecycleEquipmentMainLayer:onLayerEnter()
    self._locked = false
    self:resetSelectState()
    
    -- 播放动画
    if self._effectNode then
        self._effectNode:play()
    end
    
    -- 如果有可回收的装备则显示流光特效
    local btn = self:getButtonByName("Button_auto_add")
    btn:removeAllNodes()
    
    if G_Me.bagData:hasEquipmentToRecycle() then
        local node = EffectNode.new("effect_around2")
        node:setScaleX(1.5)
        node:setScaleY(1.6)
        node:setPosition(ccp(-2, -2))
        node:play()
        btn:addNode(node)
    end
    
    local btn = self:getButtonByName("Button_help")
    local label = self:getLabelByName("Label_equip_tip_1")
    btn:setPositionXY(label:getPositionX() + label:getSize().width/2 + btn:getSize().width/2 - 10, label:getPositionY())
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_EQUIPMENT_PREVIEW, self._onRecycleEquipmentEvent, self)
    
end

function RecycleEquipmentMainLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function RecycleEquipmentMainLayer:_initSelecteds()
    
    -- 先获取全部的装备，挑选符合要求的装备
    self._equipments = G_Me.bagData:getNotWearEquipmentList()
    for i=1, #self._equipments do
        local equipment = self._equipments[i]
        equipment.potentiality = equipment_info.get(equipment.base_id).potentiality
    end

    -- 排序，按照潜力从小到大，潜力一致则等级从大到小排序，等级一致则根据ID从小到大排序
    table.sort(self._equipments, function(a, b)
        return a.potentiality < b.potentiality or (a.potentiality == b.potentiality and (a.level > b.level or (a.level == b.level and a.base_id < b.base_id)))
    end)
    
end

function RecycleEquipmentMainLayer:initSelectState(selectEquipments, anima)
    
    self._selectEquipments = selectEquipments or self._selectEquipments
    
    anima = anima == nil and true or anima
    
    -- 更新knight
    if self._selectEquipments then
        local count = 1
        for index, equipment in pairs(self._selectEquipments) do

            -- knight的配置文件
            require "app.cfg.equipment_info"
            local equipmentConfig = equipment_info.get(equipment.base_id)

            -- 隐藏按钮
            self:getButtonByName("Button_selected"..count):setVisible(false)

            -- 显示图像
            local img = self:getImageViewByName("ImageView_selected"..count)
            img:setVisible(true)
            
            -- 要做动画
            if anima then
                local positionOffsetY = -50
                img:setPositionY(img:getPositionY() + positionOffsetY * -1)
                local moveAction = CCEaseIn:create(CCMoveBy:create(0.2, ccp(0, positionOffsetY)), 0.2)
                img:runAction(moveAction)
            end
            
            -- 校准位置
            img:loadTexture(G_Path.getEquipmentPic(equipmentConfig.res_id))
            img:setAnchorPoint(ccp(0.5, 0.1))
            
            -- 星级
--            self:getPanelByName("Panel_stars"..count):setVisible(true)
--            for i=1, 6 do
--                self:getImageViewByName("ImageView_star_dark"..count.."_"..i):setVisible(i > equipmentConfig.star)
--            end

            self:getPanelByName("Panel_label"..count):setVisible(true)

            -- 名称
            local name = self:getLabelByName("Label_name"..count)
            name:setColor(Colors.qualityColors[equipmentConfig.quality])
            name:createStroke(Colors.strokeBlack,1)
            name:setText(equipmentConfig.name)

            -- 级别
--            local grade = self:getLabelByName("Label_grade"..count)
--            grade:setText('+'..equipmentConfig.advanced_level)
--            grade:createStroke(Colors.strokeBlack,1)
            
            -- 取消按钮
            -- 调整取消按钮的位置
            local btnCancel = self:getButtonByName("Button_cancel"..count)
            btnCancel:setVisible(true)
            btnCancel:setPosition(ccp(-120, 200))
            
            self:registerBtnClickEvent("Button_cancel"..count, function()
                self._selectEquipments[index] = nil
                self:initSelectState(self._selectEquipments, false)
            end)
            
            count = count + 1

        end

        -- 其余全部恢复显示按钮
        for i=count, 5 do
            self:getButtonByName("Button_selected"..i):setVisible(true)
            self:getImageViewByName("ImageView_selected"..i):setVisible(false)
--            self:getPanelByName("Panel_stars"..i):setVisible(false)
            self:getPanelByName("Panel_label"..i):setVisible(false)
        end
    end
    
end

function RecycleEquipmentMainLayer:_onRecycleEquipmentEvent(message)
    
    -- local money = rawget(message, "money")
    -- local refining = rawget(message, "refining") or 0
    -- local towerScore = rawget(message, "towerScore")
    
    -- 精炼石需要根据需求从大到小计算，先排满50的，再排满25的，10的，5的
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

    local hasAdvanceEquipment = function()
        for k, equipment in pairs(self._selectEquipments) do
            local equipmentConfig = equipment_info.get(equipment.base_id)
            assert(equipmentConfig, "Could not find the equipment config with id: "..equipment.base_id)
            -- 紫色(5)及以上算高品质
            if equipmentConfig.quality >= 4 then
                return true
            end
        end
        return false
    end
    
    -- 预览弹框
    local RecyclePreviewLayer = require("app.scenes.recycle.RecyclePreviewLayer")
    local layer = RecyclePreviewLayer.create(RecyclePreviewLayer.LAYOUT_EQUIPMENT, {
        -- "装备分解后将会获得以下物品"
        {"Label_result_desc", {text=G_lang:get("LANG_RECYCLE_EQUIPMENT_PREVIEW_DESC")}},
        -- 高品质装备提示
        {"Label_tips", {visible=hasAdvanceEquipment(), text=G_lang:get("LANG_RECYCLE_EQUIPMENT_ADVANCE_TIPS")}}
    })
    uf_sceneManager:getCurScene():addChild(layer)
    
    layer:registerBtnClickEvent("Button_ok", function()
            
        local equipments = {equip_id = {}, type=0}
        for k, equipment in pairs(self._selectEquipments) do
            equipments.equip_id[#equipments.equip_id+1] = equipment.id
        end
        G_HandlersManager.recycleHandler:sendRecycleEquipment(equipments)
        
        layer:animationToClose()
    end)
    
    -- 更新数据
    -- 先把数据打包封装
    
    local datas = {container = {}}
    
    datas.add = function(data)
        datas.container[#datas.container+1] = data
    end
    
    datas.get = function()
        return clone(datas.container)
    end
    
    datas.count = function()
        return #datas.container
    end
    
    -- for i=1, #refining do
    --     local item = item_info.get(refining[i].item)

    --     datas.add{
    --         {"ImageView_item", {visible=true}},
    --         {"ImageView_frame", {texture=G_Path.getEquipColorImage(item.quality,G_Goods.TYPE_ITEM)}},
    --         {"ImageView_head", {texture=G_Path.getItemIcon(item.res_id), texType=UI_TEX_TYPE_LOCAL}},
    --         {"ImageView_bg", {texture=G_Path.getEquipIconBack(item.quality)}},
    --         {"Label_name", {text=item.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[item.quality]}},
    --         {"Label_amount", {text="x"..refining[i].amount, stroke=Colors.strokeBlack}}
    --     }
    -- end

    -- if towerScore then
    --     local goodConfig = G_Goods.convert(16)

    --     datas.add{
    --         {"ImageView_item", {visible=true}},
    --         {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
    --         {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
    --         {"ImageView_bg", {texture=G_Path.getEquipIconBack(goodConfig.quality)}},
    --         {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
    --         {"Label_amount", {text="x"..towerScore, stroke=Colors.strokeBlack}}
    --     }
    -- end

    -- if money then
    --     local goodConfig = G_Goods.convert(1)   -- 1表示银两

    --     datas.add{
    --         {"ImageView_item", {visible=true}},
    --         {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
    --         {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
    --         {"ImageView_bg", {texture=G_Path.getEquipIconBack(goodConfig.quality)}},
    --         {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
    --         {"Label_amount", {text="x"..money, stroke=Colors.strokeBlack}}
    --     }
    -- end

    if rawget(message, "awards") then
        local awards = message.awards
        for i,v in ipairs(awards) do
            local goodConfig = G_Goods.convert(v.type, v.value)
                datas.add{
                    {"ImageView_item", {visible=true}},
                    {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality, goodConfig.type)}},
                    {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
                    {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
                    {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
                    {"Label_amount", {text='x'..v.size, stroke=Colors.strokeBlack}},
                }
        end
    end

    -- -- 红色装备额外返还物品
    -- local extraItem = rawget(message, "awards")
    -- if extraItem then
    --     local awardsExtra = message.awards
    --     -- 返回的红色装备精华数量
    --     local hongsezhuangbeijinghuaNum = 0
    --     for i=1, #awardsExtra do
    --         if awardsExtra[i].type == 3 and awardsExtra[i].value == 81 then
    --             -- 红色装备精华
    --             hongsezhuangbeijinghuaNum = hongsezhuangbeijinghuaNum + awardsExtra[i].size
    --         end
    --     end

    --     if hongsezhuangbeijinghuaNum > 0 then
    --         local goodConfig = G_Goods.convert(3, 81)
    --         datas.add{
    --             {"ImageView_item", {visible=true}},
    --             {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality, goodConfig.type)}},
    --             {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
    --             {"ImageView_bg", {visible=true, texture=G_Path.getEquipIconBack(goodConfig.quality)}},
    --             {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
    --             {"Label_amount", {text='x'..hongsezhuangbeijinghuaNum, stroke=Colors.strokeBlack}},
    --         }

    --     end
    -- end

    layer:updateListView("Panel_list", datas.get())
    
end

function RecycleEquipmentMainLayer:playRecycleAnimation()
    
    -- 这里为了保存原始的位置及缩放比等参数，采用闭包的方法
    
    -- 先记录原始的参数，方便重置
    local originalScales = {}
    local originalOpacitys = {}
    local originalPositions = {}
    
    -- 归隐动画，5表示最多显示5个
    for i=1, 5 do
        local img = self:getImageViewByName("ImageView_selected"..i)
        if img then
            originalScales[i] = img:getScale()
            originalOpacitys[i] = img:getOpacity()
            originalPositions[i] = ccp(img:getPosition())
        end
    end
    
    local effectNode = nil
    local effectSingleMoving = nil
    
    local luziNode = self._luzi
    local luziOriginalPosition = ccp(luziNode:getPosition())
    local luziOriginalScaleX = luziNode:getScaleX()
    local luziOriginalScaleY = luziNode:getScaleY()
    local luziOriginalOpacity = luziNode:getOpacity()
    local luziOriginalRotation = luziNode:getRotation()
    
    -- 返回一个控制函数
    return function(command, callback)
        
        command = command or "play"
        
        if command == "play" then

            local dstPosition = luziNode:convertToWorldSpaceAR(ccp(0, 100))
                            
            local durationFrame = 13
            
            local array = CCArray:create()
            
            -- 先是人物动画
            array:addObject(CCCallFunc:create(function()

                -- 重铸动画，5表示最多显示5个
                for i=1, 5 do
                    local img = self:getImageViewByName("ImageView_selected"..i)
                    if img:isVisible() then -- 表示其有选中

                        -- 隐藏名称
                        self:getPanelByName("Panel_label"..i):setVisible(false)
                        -- 隐藏取消按钮
                        self:getButtonByName("Button_cancel"..i):setVisible(false)

                        local array = CCArray:create()
        --                array:addObject(CCFadeOut:create(durationFrame/30))
                        array:addObject(CCScaleTo:create(durationFrame/30, 0.2))
        --                array:addObject(CCMoveTo:create(durationFrame/30, img:getParent():convertToNodeSpace(dstPosition)))
                        array:addObject(CCJumpTo:create(durationFrame/30, img:getParent():convertToNodeSpace(dstPosition), 80, 1))

                        img:runAction(CCSequence:createWithTwoActions(CCSpawn:create(array), CCCallFunc:create(function()
                            img:setScale(originalScales[i])
                            img:setOpacity(originalOpacitys[i])
                            img:setPosition(originalPositions[i])
                            img:setVisible(false)
                        end)))
                    end
                end
                
            end))
            
            -- 延迟
            array:addObject(CCDelayTime:create(durationFrame/30))
            
            -- 然后是特效
            array:addObject(CCCallFunc:create(function()
                effectSingleMoving = require("app.common.effects.EffectSingleMoving").run(luziNode, "smoving_huolu",
                    function(singleEvent)
                        if singleEvent == "finish" then
                            -- 闪光动画
                            effectNode = require("app.common.effects.EffectNode").new("effect_explode_light", callback)
                            self:addChild(effectNode)
                            effectNode:play()
                            effectNode:setPosition(effectNode:getParent():convertToNodeSpace(dstPosition))
                        end
                    end
                )
                effectSingleMoving:play()
            end))
            
            self:runAction(CCSequence:create(array))
                        
        elseif command == "reset" then
            
            for i=1, 5 do
                local img = self:getImageViewByName("ImageView_selected"..i)
                if img then
                    img:setScale(originalScales[i])
                    img:setOpacity(originalOpacitys[i])
                    img:setPosition(originalPositions[i])
                    img:setVisible(false)
                end
            end
            
            self:stopAllActions()
            
            if effectSingleMoving then
                effectSingleMoving:stop()
            end
            
            if effectNode then
                effectNode:removeFromParent()
                effectNode = nil
            end
            
            luziNode:setPosition(luziOriginalPosition)
            luziNode:setScaleX(luziOriginalScaleX)
            luziNode:setScaleY(luziOriginalScaleY)
            luziNode:setOpacity(luziOriginalOpacity)
            luziNode:setRotation(luziOriginalRotation)
            
            if callback then
                callback(command)
            end
            
        end
    end

end


function RecycleEquipmentMainLayer:resetSelectState()
    
    -- 更新当前的界面状态
    self:initSelectState{}
    
    self:_initSelecteds()
    
end

function RecycleEquipmentMainLayer:getAvailableSelecteds()
    return self._equipments
end

function RecycleEquipmentMainLayer:getSelecteds()
    return self._selectEquipments
end

function RecycleEquipmentMainLayer:lock() self._locked = true end
function RecycleEquipmentMainLayer:unlock() self._locked = false end

return RecycleEquipmentMainLayer
