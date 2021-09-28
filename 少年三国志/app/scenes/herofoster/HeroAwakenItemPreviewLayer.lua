-- HeroAwakenItemPreviewLayer

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


require "app.cfg.item_awaken_info"
require "app.cfg.item_awaken_compose"
require "app.cfg.way_type_info"
require "app.cfg.way_function_info"

local FunctionLevelConst = require "app.const.FunctionLevelConst"
local EffectNode = require "app.common.effects.EffectNode"
local HeroAwakenItemDetailLayer = require "app.scenes.herofoster.HeroAwakenItemDetailLayer"

local HeroAwakenItemPreviewLayer = class("HeroAwakenItemPreviewLayer", UFCCSModelLayer)


function HeroAwakenItemPreviewLayer.create(...)
    return HeroAwakenItemPreviewLayer.new("ui_layout/HeroAwakenItemPreviewLayer.json", Colors.modelColor, ...)
end

function HeroAwakenItemPreviewLayer:ctor(_, _, awakenCode, awakenLevel, scenePack)
    
    HeroAwakenItemPreviewLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    self:adapterWithScreen()

    self._awakenCode = awakenCode
    self._awakenLevel = awakenLevel
    
    self._scenePack = scenePack
    
end

function HeroAwakenItemPreviewLayer:onLayerEnter()
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
        
    self:_updateView()
    
end

function HeroAwakenItemPreviewLayer:_updateView()
    
    -- 按钮响应
    local function _onClose()
        
        if self._lock then return end
        
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end

    self:registerBtnClickEvent("Button_close", _onClose)
    self:enableAudioEffectByName("Button_close", false)
    
    self:registerBtnClickEvent("Button_decide", _onClose)
    self:enableAudioEffectByName("Button_decide", false)
    
    -- 先计算一下有多少的装备
    local _start, _end
    _start = self._awakenLevel
    _end = self._awakenLevel
    
    local curAwakenKnightInfo = knight_awaken_info.get(self._awakenCode, self._awakenLevel)
    assert(curAwakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..self._awakenCode..", "..self._awakenLevel)
    
    if curAwakenKnightInfo.next_awaken_id ~= 0 then
        -- 确定了还有下一级才开始遍历，从下一级开始，数量为5个
        for i=1, 5 do
            local _awakenKnightInfo = knight_awaken_info.get(self._awakenCode, _start + i)
            assert(_awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..self._awakenCode..", "..(_start + i))

            if _awakenKnightInfo.next_awaken_id == 0 then
                break
            else
                _end = _start + i
            end
        end
    end
    
    if not self._listView then
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_list")

        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listView
        
        listView:setCreateCellHandler(function()
            return CCSItemCellBase:create("ui_layout/HeroAwakenItemPreviewItemCell.json")
        end)
        
        listView:setUpdateCellHandler(function(list, index, cell)
            
            local _awakenLevel = _start + index+1 -- index从0开始，我们从下一级开始
            
            local _awakenKnightInfo = knight_awaken_info.get(self._awakenCode, _awakenLevel)
            assert(_awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..self._awakenCode..", ".._awakenLevel)
            
            self:updatePanel("Panel_items2", {visible=(_awakenKnightInfo.item_num == 2)}, cell)
            self:updatePanel("Panel_items3", {visible=(_awakenKnightInfo.item_num == 3)}, cell)
            self:updatePanel("Panel_items4", {visible=(_awakenKnightInfo.item_num == 4)}, cell)
            
            -- title
            self:updateLabel("Label_level_desc", {text=G_lang:get("LANG_AWAKEN_LEVEL_DESC1", {star=math.floor(_awakenLevel/10)})..G_lang:get("LANG_AWAKEN_LEVEL_DESC2", {level=_awakenLevel%10}), stroke=Colors.strokeBrown, strokeSize=2}, cell)
            
            -- 当前等级背景需要变化
            if index == 0 then
                self:updateImageView("Image_item_bg", {texture="board_red.png", texType=UI_TEX_TYPE_PLIST}, cell)
                self:updateImageView("Image_item_inner_bg", {texture="list_board_red.png", texType=UI_TEX_TYPE_PLIST}, cell)
            else
                self:updateImageView("Image_item_bg", {texture="board_normal.png", texType=UI_TEX_TYPE_PLIST}, cell)
                self:updateImageView("Image_item_inner_bg", {texture="list_board.png", texType=UI_TEX_TYPE_PLIST}, cell)
            end
            
            for i=1, _awakenKnightInfo.item_num do
                -- 品级框
                local itemInfo = item_awaken_info.get(_awakenKnightInfo["item_id_"..i])
                assert(itemInfo, "Could not find the awaken item with id: "..tostring(_awakenKnightInfo["item_id_"..i]))
                
                local offset = 0
                if _awakenKnightInfo.item_num == 3 then offset = 2
                elseif _awakenKnightInfo.item_num == 4 then offset = 2 + 3
                end
                
                self:updateImageView("Image_bg"..(i+offset), {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST}, cell)
                self:updateImageView("Image_icon"..(i+offset), {texture=itemInfo.icon}, cell)
                self:updateImageView("Image_frame"..(i+offset), {texture=G_Path.getEquipColorImage(itemInfo.quality), texType=UI_TEX_TYPE_PLIST}, cell)
                
                local function _updateItemAmount()
                    -- 数量
                    self:updateLabel("Label_amount_desc"..(i+offset), {text=G_lang:get("LANG_AWAKEN_ITEM_DETAIL_AMOUNT_DESC")}, cell)
                    self:updateLabel("Label_amount"..(i+offset), {text=G_Me.bagData:getAwakenItemNumById(itemInfo.id)}, cell)
                    local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_amount_desc"..(i+offset)), 
                        cell:getLabelByName("Label_amount"..(i+offset))}, ALIGN_CENTER)
                    cell:getLabelByName("Label_amount_desc"..(i+offset)):setPosition(getPosition(1))
                    cell:getLabelByName("Label_amount"..(i+offset)):setPosition(getPosition(2))

                    -- 数量不足要置灰
                    local enough = G_Me.bagData:getAwakenItemNumById(itemInfo.id) > 0
                    cell:getImageViewByName("Image_icon"..(i+offset)):showAsGray(not enough)
                    cell:getImageViewByName("Image_bg"..(i+offset)):showAsGray(not enough)
                    cell:getImageViewByName("Image_frame"..(i+offset)):showAsGray(not enough)
                end
                
                _updateItemAmount()
                cell:registerWidgetClickEvent("Image_icon"..(i+offset), function()
                    
                    -- 分可合成和可获取两种状态
                    local state = itemInfo.compose_id ~= 0 and HeroAwakenItemDetailLayer.STATE_COMPOSE or HeroAwakenItemDetailLayer.STATE_GET
                    
                    local layer
                    layer = HeroAwakenItemDetailLayer.create(itemInfo.id, state, function(_state, _layer)

                        -- 表示获取状态确认
                        if _state == HeroAwakenItemDetailLayer.STATE_GET then
                            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_AWAKEN_ITEM, itemInfo.id, self._scenePack)
                        -- 表示合成状态确认
                        elseif _state == HeroAwakenItemDetailLayer.STATE_COMPOSE then

                            local newlayer = require("app.scenes.herofoster.HeroAwakenItemComposeLayer").create(nil, itemInfo.id, self._scenePack,
                                function(_itemId, _newLayer , fastCompose , num)
                                    local returnOk = function()
                                        _updateItemAmount()
                                        -- 详细信息界面也要刷新
                                        _layer:updateView()
                                        _newLayer:playComposeAnimation(function(event)
                                            if event == "finish" then
                                                G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_SUCCESS_DESC"))
                                                -- 成功合成后更新合成树
                                                _newLayer:updateComposeTree(nil, false)
                                            end
                                        end)
                                    end 

                                    if not fastCompose then 
                                        -- 请求合成装备
                                        G_HandlersManager.bagHandler:sendComposeAwakenItem(_itemId)
                                        -- 监听消息
                                        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AWAKEN_COMPOSE_ITEM_NOTI, function(_, message)
                                            if message.ret == NetMsg_ERROR.RET_OK then
                                                returnOk()
                                            end
                                            uf_eventManager:removeListenerWithTarget(self)
                                        end, self)
                                    
                                    else 
                                        G_HandlersManager.bagHandler:sendFastComposeAwakenItem(_itemId , num )
                                        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FAST_AWAKEN_COMPOSE_ITEM_NOTI, function(_, message)
                                            if message.ret == NetMsg_ERROR.RET_OK then
                                                returnOk()
                                                _newLayer:doNotRealLabelAndAnimation(true)
                                            else 
                                                -- 不ok的情况也需要刷新一下
                                                _newLayer:updateComposeTree(nil, false)
                                                _newLayer:doNotRealLabelAndAnimation(false)
                                            end
                                            uf_eventManager:removeListenerWithTarget(self)
                                        end, self)
                                    end 

                                end)
                            uf_sceneManager:getCurScene():addChild(newlayer)
                            newlayer:setParentLayer(layer)
                        end
                    end)
                    uf_sceneManager:getCurScene():addChild(layer)
                    
                end)
            end

        end)
        
        listView:initChildWithDataLength(_end - _start)

    end

    self._listView:reloadWithLength(_end - _start, 0)
    
end

function HeroAwakenItemPreviewLayer:updateLabel(name, params, target)
    
    target = target or self
    
    local label = target:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if params.stroke ~= nil and label.createStroke then
        label:createStroke(params.stroke, params.strokeSize or 1)
    end
    
    if params.color ~= nil and label.setColor then
        label:setColor(params.color)
    end
    
    if params.text ~= nil and label.setText then
        label:setText(params.text)
    end
    
    if params.visible ~= nil and label.setVisible then
        label:setVisible(params.visible)
    end

end

function HeroAwakenItemPreviewLayer:updateImageView(name, params, target)
    
    target = target or self
    
    local img = target:getImageViewByName(name)
    assert(img, "Could not find the image with name: "..name)
    
    if params.texture ~= nil and img.loadTexture then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil and img.setVisible then
        img:setVisible(params.visible)
    end
    
end

function HeroAwakenItemPreviewLayer:updateButton(name, params, target)
    
    target = target or self
    
    local btn = target:getButtonByName(name)
    assert(btn, "Could not find the button with name: "..name)
    
    if params.visible ~= nil and btn.setVisible then
        btn:setVisible(params.visible)
    end
    
end

function HeroAwakenItemPreviewLayer:updatePanel(name, params, target)
    
    target = target or self
    
    local panel = target:getPanelByName(name)
    assert(panel, "Could not find the panel with name: "..name)
    
    if params.visible ~= nil and panel.setVisible then
        panel:setVisible(params.visible)
    end
    
end

return HeroAwakenItemPreviewLayer
