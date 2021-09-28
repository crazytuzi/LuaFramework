-- RecycleTreasureRebornMainLayer

local REBORN_PRICE = 50

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

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)
    
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(position, item)

        -- print("position.x: "..position.x.." position.y: "..position.y)

        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)

    end
    
    if align == ALIGN_CENTER then

        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])

        end
        
    elseif align == ALIGN_LEFT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x + _width, 0), items[index])

        end
        
    elseif align == ALIGN_RIGHT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth + _width, 0), items[index])

        end

    else
        
        assert(false, "Now we don't support other align type :"..align)
        
    end

end

require "app.cfg.knight_info"
require "app.cfg.treasure_info"


local RecycleTreasureRebornMainLayer = class("RecycleTreasureRebornMainLayer", UFCCSNormalLayer)

function RecycleTreasureRebornMainLayer.create(...)
    return RecycleTreasureRebornMainLayer.new("ui_layout/recycle_treasureRebornMainLayer.json", nil, ...)
end

function RecycleTreasureRebornMainLayer:ctor(...)
    
    RecycleTreasureRebornMainLayer.super.ctor(self, ...)
    
    -- 重生返还初始武将以及养成所用的所有资源
    -- _updateLabel(self, "Label_desc1", G_lang:get("LANG_RECYCLE_TREASURE_REBORN_DESC1"))
    
    -- 价格
    _updateLabel(self, "Label_price", REBORN_PRICE, Colors.strokeBrown)
    
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
    
    self:registerBtnClickEvent("Button_help", function()
        self:onButtonHelpClicked()
    end)
    
end

function RecycleTreasureRebornMainLayer:onButtonRebornClicked(  )
    if self._locked then return end

    local treasures = {treasure_id=self._selectTreasures[1].id, type=1}  -- 3表示重生预览
    G_HandlersManager.recycleHandler:sendRecycleTreasure(treasures)
end

function RecycleTreasureRebornMainLayer:onButtonHelpClicked(  )
--        local layer = require("app.scenes.recycle.RecycleHelpLayer").create(G_lang:get("LANG_RECYCLE_TREASURE_REBORN_TITLE"), G_lang:get("LANG_RECYCLE_TREASURE_REBORN_HELP_DESC"))
--        uf_sceneManager:getCurScene():addChild(layer)

    require("app.scenes.common.CommonHelpLayer").show({
        {title=G_lang:get("LANG_RECYCLE_TREASURE_REBORN_TITLE"), content=G_lang:get("LANG_RECYCLE_TREASURE_REBORN_HELP_DESC")}
    } )
end

function RecycleTreasureRebornMainLayer:onLayerEnter()
    
    self:resetSelectState()
    
    -- 播放特效
    if self._effectNode then
        self._effectNode:play()
    end
    
    -- local btn = self:getButtonByName("Button_help")
    -- local label = self:getLabelByName("Label_desc1")
    -- btn:setPositionXY(label:getPositionX() + label:getSize().width/2 + btn:getSize().width/2, label:getPositionY())
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECYCLE_TREASURE_PREVIEW, self._onRecycleRebornEvent, self)
    
end

function RecycleTreasureRebornMainLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function RecycleTreasureRebornMainLayer:_initSelecteds()
    
    -- 先获取全部的武将，挑选符合要求的武将
    self._treasures = {}
    local treasureList = G_Me.bagData.treasureList:getList()
    
    for key, treasure in pairs(treasureList) do
        -- 未上阵，宝物等级>1或者精炼等级>1
        if not treasure:isWearing() and
            (treasure.level > 1 or 
            treasure.refining_level > 0) then
            treasure.potentiality = treasure_info.get(treasure.base_id).potentiality
            self._treasures[#self._treasures+1] = treasure
        end
    end

    -- 排序，按照资质从大到小排序，资质一致则根据等级从大到小排序，等级一致则根据ID从小到大排序
    table.sort(self._treasures, function(a, b)
        return a.potentiality > b.potentiality or (a.potentiality == b.potentiality and (a.level > b.level or (a.level == b.level and a.base_id < b.base_id)))
    end)
    
end

function RecycleTreasureRebornMainLayer:initSelectState(selectTreasures, anima)
    
    self._selectTreasures = selectTreasures or self._selectTreasures
    
    anima = anima == nil and true or anima
    
    -- 更新knight
    if self._selectTreasures and #self._selectTreasures >= 1 then
        
        self:getPanelByName("Panel_added"):setVisible(true)
        self:getPanelByName("Panel_before_add"):setVisible(false)
        
        local treasure = self._selectTreasures[1]

        -- knight的配置文件
        local treasureConfig = treasure_info.get(treasure.base_id)

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


        img:loadTexture(G_Path.getTreasurePic(treasureConfig.res_id))

        -- 星级
--            self:getPanelByName("Panel_stars"..count):setVisible(true)
--            for i=1, 6 do
--                self:getImageViewByName("ImageView_star_dark"..count.."_"..i):setVisible(i > knightConfig.star)
--            end

        self:getImageViewByName("Image_name"):setVisible(true)

        -- 名称
        local name = self:getLabelByName("Label_name")
        name:setColor(Colors.qualityColors[treasureConfig.quality])
        name:createStroke(Colors.strokeBlack,1)
        name:setText(treasureConfig.name)

--            -- 级别, 大于0则显示，否则不显示
--            if knightConfig.advanced_level > 0 then
--                local grade = self:getLabelByName("Label_grade"..count)
--                grade:createStroke(Colors.strokeBlack,1)
--                grade:setText('+'..knightConfig.advanced_level)
--            else
--                self:getLabelByName("Label_grade"..count):setVisible(false)
--            end

--        -- 取消按钮
--        -- 调整取消按钮的位置
--        local btnCancel = self:getButtonByName("Button_cancel")
--        btnCancel:setVisible(true)
--        btnCancel:setPosition(ccp(-120, 400))
--
--        self:registerBtnClickEvent("Button_cancel", function()
--            self._selectKnights[1] = nil
--            self:initSelectState(self._selectKnights, false)
--        end)
        
        -- 强化
        _updateLabel(self, "Label_content_strength_desc", G_lang:get("LANG_RECYCLE_TREASURE_LEVEL_DESC"))
        _updateLabel(self, "Label_content_strength", G_lang:get("LANG_RECYCLE_TREASURE_LEVEL", {level=treasure.level}))
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_strength_desc"),
        self:getLabelByName("Label_content_strength")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_strength_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_strength"):setPosition(getPosition(2))

        -- 精炼
        _updateLabel(self, "Label_content_refine_desc", G_lang:get("LANG_RECYCLE_TREASURE_REFINE_DESC"))
        _updateLabel(self, "Label_content_refine", G_lang:get("LANG_RECYCLE_TREASURE_REFINE", {refine=treasure.refining_level}))
        local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_content_refine_desc"),
        self:getLabelByName("Label_content_refine")}, ALIGN_LEFT)
        self:getLabelByName("Label_content_refine_desc"):setPosition(getPosition(1))
        self:getLabelByName("Label_content_refine"):setPosition(getPosition(2))
        
        -- 文字描述
        _updateLabel(self, "Label_result_desc", G_lang:get("LANG_RECYCLE_TREASURE_REBORN_DESC1"))
        
    else
        
        -- 显示按钮
        self:getButtonByName("Button_selected"):setVisible(true)
        self:getImageViewByName("Image_selected"):setVisible(false)
        self:getImageViewByName("Image_name"):setVisible(false)
        
        self:getPanelByName("Panel_added"):setVisible(false)
        self:getPanelByName("Panel_before_add"):setVisible(true)
                
    end
    
end

function RecycleTreasureRebornMainLayer:_onRecycleRebornEvent(message)
    
    local item = clone(rawget(message, "item")) or {}
    
    local treasureCount = 0
    for i=1, #item do
        if item[i].type == G_Goods.TYPE_TREASURE then
            treasureCount = treasureCount + item[i].size
        end
    end
    
    -- 排序，按照宝物，道具，银两的形式排放
    table.sort(item, function(a, b)
        if a.type > b.type then
            return true
        elseif a.type == b.type then
            if a.type == G_Goods.TYPE_TREASURE then
                local treasureA = treasure_info.get(a.value)
                local treasureB = treasure_info.get(b.value)
                return treasureA.potentiality > treasureB.potentiality
            end
        end
    end)
    
    local RecyclePreviewLayer = require("app.scenes.recycle.RecyclePreviewLayer")
    local layer = RecyclePreviewLayer.create(RecyclePreviewLayer.LAYOUT_REBORN_TREASURE, {
        -- "宝物重生后将会获得以下物品"
        {"Label_result_desc", {text=G_lang:get("LANG_RECYCLE_TREASURE_REBORN_PREVIEW_DESC")}},
        -- 消耗
        {"Label_price_desc", {text=G_lang:get("LANG_RECYCLE_TREASURE_REBORN_PRICE_DESC")}},
        -- 价格
        {"Label_price", {text=REBORN_PRICE, color=G_Me.userData.gold < REBORN_PRICE and ccc3(0xf2, 0x79, 0x0d) or nil}},
    })
    uf_sceneManager:getCurScene():addChild(layer)
    
    layer:registerBtnClickEvent("Button_ok", function()
             
        if G_Me.userData.gold < REBORN_PRICE then
--            G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_TREASURE_REBORN_GOLD_EMPTY"))
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        
        local CheckFunc = require("app.scenes.common.CheckFunc")
        if CheckFunc.checkDiffByType(G_Goods.TYPE_TREASURE, treasureCount) then
            return
        end
        
        local params = {treasure_id=self._selectTreasures[1].id, type=0}
        G_HandlersManager.recycleHandler:sendRecycleTreasure(params)
        
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
    
    for i=1, #item do

        local goodConfig = G_Goods.convert(item[i].type, item[i].value)
        
        datas.add{
            {"ImageView_item", {visible=true}},
            {"ImageView_frame", {texture=G_Path.getEquipColorImage(goodConfig.quality,goodConfig.type)}},
            {"ImageView_head", {texture=goodConfig.icon, texType=UI_TEX_TYPE_LOCAL}},
            {"ImageView_bg", {texture=G_Path.getEquipIconBack(goodConfig.quality)}},
            {"Label_name", {text=goodConfig.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[goodConfig.quality]}},
            {"Label_amount", {text="x"..item[i].size, stroke=Colors.strokeBlack}},
        }

    end
    
    layer:updateListView("Panel_list", datas.get())
    
end

function RecycleTreasureRebornMainLayer:playRecycleAnimation()
    
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
    --        effectNode:setPosition(ccp(display.cx, display.cy))
                        
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

function RecycleTreasureRebornMainLayer:resetSelectState()
    
    -- 更新当前的界面状态
    self:initSelectState{}   -- 初始化空表
    
    -- 更新当前可选武将
    self:_initSelecteds()
    
end

function RecycleTreasureRebornMainLayer:getAvailableSelecteds()
    return self._treasures
end

function RecycleTreasureRebornMainLayer:getSelecteds()
    return self._selectTreasures
end

function RecycleTreasureRebornMainLayer:lock() self._locked = true end
function RecycleTreasureRebornMainLayer:unlock() self._locked = false end

return RecycleTreasureRebornMainLayer
