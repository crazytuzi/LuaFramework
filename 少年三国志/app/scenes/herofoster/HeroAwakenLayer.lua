--HeroAwakenLayer.lua

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.strokeSize or 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    assert(img, "Could not find the image with name: "..name)
    
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

local function _updatePanel(target, name, params)
    
    local panel = target:getPanelByName(name)

    if params.visible ~= nil then
        panel:setVisible(params.visible)
    end
    
end

local function _createKnight(knightPath, jsonPath, withShadow)
    
    local node = display.newNode()
    
    local cardJson = decodeJsonFile(jsonPath)
    assert(cardJson, "Could not read the json with path: "..jsonPath)
    
    local cardSprite = display.newSprite(knightPath)
    local anchorPoint = cardSprite:getAnchorPoint()
    anchorPoint = ccp((anchorPoint.x * cardSprite:getContentSize().width - cardJson.x) / cardSprite:getContentSize().width, (anchorPoint.y * cardSprite:getContentSize().height - cardJson.y) / cardSprite:getContentSize().height)
    cardSprite:setAnchorPoint(anchorPoint)
    node:addChild(cardSprite)
    
    if withShadow then
        local shadow = display.newSprite(G_Path.getKnightShadow())
        shadow:setPosition(ccp(tonumber(cardJson.shadow_x) + cardSprite:getPositionX(), tonumber(cardJson.shadow_y) + cardSprite:getPositionY()))
        node:addChild(shadow)
    end
    
    return node
    
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


require "app.cfg.knight_awaken_info"
require "app.cfg.knight_info"
require "app.cfg.passive_skill_info"

local EffectNode = require "app.common.effects.EffectNode"
local JumpCard = require "app.scenes.common.JumpCard"
local KnightConst = require("app.const.KnightConst")


local HeroAwakenLayer = class("HeroJueXingLayer", UFCCSNormalLayer)


function HeroAwakenLayer.create(...)
    
    return HeroAwakenLayer.new("ui_layout/HeroAwakenLayer.json", nil, ...)
end

function HeroAwakenLayer:ctor(_, _, mainKnightId, itemId, packState)
    
    HeroAwakenLayer.super.ctor(self)
    
    self._mainKnightId = mainKnightId

    self._itemId = itemId

    self._packState = packState
    
    self._scenePack = G_GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._mainKnightId})

    -- 手动适配一下名字和星星的位置
    local imgName = self:getImageViewByName("Image_name_bg")
    imgName:setPositionY(imgName:getPositionY() + (display.height - 853) * 0.3)
    
    local panelStars = self:getPanelByName("Panel_stars")
    panelStars:setPositionY(panelStars:getPositionY() + (display.height - 853) * 0.25)
    
    local panelCurTalent = self:getPanelByName("Panel_cur_talent")
    panelCurTalent:setPositionY(panelCurTalent:getPositionY() - (display.height - 853) * 0.2)
    
    -- 背景特效    
    local parent = self:getImageViewByName("ImageView_background")
    parent:removeAllNodes()
    
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        local EffectNode = require "app.common.effects.EffectNode"
        local backEffect = EffectNode.new("effect_jinjiechangjing")
        parent:addNode(backEffect)
        backEffect:play()
    end
    
end

function HeroAwakenLayer:onLayerEnter()

    -- 更新人物
    self:_updateAwakenKnight()
    
    -- 更新页面的显示
    self:_updateView()
    
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_equipment2"), 
            self:getWidgetByName("Image_equipment1") }, true, 0.2, 3, 50)
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_equipment3"), 
            self:getWidgetByName("Image_equipment4") }, false, 0.2, 3, 50)

    if self._itemId and self._packState then

        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
        assert(knightInfo, "Could not find the knightInfo with id: "..tostring(self._mainKnightId))
        
        local cardConfig = knight_info.get(knightInfo.base_id)
        assert(cardConfig, "Could not find the card config with id:"..tostring(knightInfo.base_id))
        
        local awakenKnightInfo = knight_awaken_info.get(cardConfig.awaken_code, knightInfo.awaken_level)
        assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..cardConfig.awaken_code..", "..knightInfo.awaken_level)

        local HeroAwakenItemDetailLayer = require("app.scenes.herofoster.HeroAwakenItemDetailLayer")
        local state = HeroAwakenItemDetailLayer.STATE_CERTAIN

        local idx = nil
        for i = 1, 4 do
            local id = awakenKnightInfo["item_id_"..i]
            if id == self._itemId then
                idx = i
                break
            end
        end

        if idx then
            local itemId = self._itemId
                
            -- 是否已装备
            local equipped = G_Me.bagData.knightsData:isEquippedAwakenItem(self._mainKnightId, itemId, idx)
            beEquippedFull = beEquippedFull and equipped
            -- 是否可装备
            local canBeEquipped = G_Me.bagData:containAwakenItem(itemId)
            -- 是否可合成
            local canBeComposed = G_Me.bagData:awakenItemCanBeComposed(itemId, 1)
            -- 本身可合成
            local itemInfo = item_awaken_info.get(itemId)
            assert(itemInfo, "Could not find the awaken item with id: "..itemId)
            local couldBeComposed = itemInfo.compose_id ~= 0
            
            if equipped then
                state = HeroAwakenItemDetailLayer.STATE_CERTAIN
            elseif canBeEquipped then
                state = HeroAwakenItemDetailLayer.STATE_EQUIP
            elseif canBeComposed then
                state = HeroAwakenItemDetailLayer.STATE_COMPOSE
            elseif couldBeComposed then
                state = HeroAwakenItemDetailLayer.STATE_COMPOSE
            else
                state = HeroAwakenItemDetailLayer.STATE_GET
            end

            self:callAfterFrameCount(1,function( ... ) 
                local layer = HeroAwakenItemDetailLayer.create(self._itemId, state, function(_state, _layer)
                    self:_DetailLayerCallback(_state, _layer, self._itemId, idx)
                end, self._packState)
                uf_sceneManager:getCurScene():addChild(layer)
            end)
        end
    end
    
end

function HeroAwakenLayer:_updateView(withAnimation)

    local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
    assert(knightInfo, "Could not find the knightInfo with id: "..tostring(self._mainKnightId))
    
    local cardConfig = knight_info.get(knightInfo.base_id)
    assert(cardConfig, "Could not find the card config with id:"..tostring(knightInfo.base_id))
    
    local awakenKnightInfo = knight_awaken_info.get(cardConfig.awaken_code, knightInfo.awaken_level)
    assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..cardConfig.awaken_code..", "..knightInfo.awaken_level)
    
    -- 觉醒商店
    self:registerBtnClickEvent("Button_awaken_shop", function()
        --点击觉醒商店的时候肯定没有打开合成道具的窗口
        self._scenePack = G_GlobalFunc.sceneToPack("app.scenes.herofoster.HeroDevelopScene", {KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._mainKnightId})
        uf_sceneManager:replaceScene(require("app.scenes.awakenshop.AwakenShopScene").new(nil, nil, nil, nil, self._scenePack))
    end)
    
    -- 道具预览
    self:registerBtnClickEvent("Button_awaken_items", function()
        local layer = require("app.scenes.herofoster.HeroAwakenItemPreviewLayer").create(cardConfig.awaken_code, knightInfo.awaken_level, self._scenePack)
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    
    -- 更新武将的觉醒信息等，返回觉醒等级是否满足却未觉醒满级
    local enoughLevel = self:_updateAwakenKnightInfo(awakenKnightInfo, withAnimation)
    
    -- 更新觉醒装备，返回是否穿齐装备
    local beEquippedFull = self:_updateAwakenEquipments(awakenKnightInfo)
    
    -- 更新觉醒材料，返回是否满足材料
    local enoughMaterial = self:_updateAwakenMaterials(awakenKnightInfo)
    
    -- 更新觉醒花费，返回是否足够
    local enoughMoney = self:_updateAwakenCost(awakenKnightInfo)

    -- 觉醒
    self:registerBtnClickEvent("Button_awaken", function()
        
        -- 觉醒已满级
        if awakenKnightInfo.next_awaken_id == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_LEVEL_MAX_DESC"))
        -- 等级未到无法觉醒
        elseif awakenKnightInfo.level_ban > knightInfo.level then
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ERROR_NO_ENOUGH_LEVEL"))
        -- 装备未全无法觉醒
        elseif not G_Me.bagData.knightsData:isFullEquippedAwakenItem(self._mainKnightId) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ERROR_NO_ENOUGH_EQUIPMENT"))
        -- 材料不够
        elseif not enoughMaterial then
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ERROR_NO_ENOUGH_MATERIAL"))
        -- 金钱不够，这里消耗类型（银两）固定
        elseif G_Me.userData.money < awakenKnightInfo.money_cost then
--            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_ERROR_NO_ENOUGH_MONEY"))
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, nil, self._scenePack)
        else
            -- 请求觉醒
            -- 所需同名武将    
            local knightList = {}
            for i=1, 2 do
                local _type = awakenKnightInfo["cost_"..i.."_type"]
                if _type == 1 then
                    local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
                    local secondTeam = G_Me.formationData:getSecondTeamKnightIds()
                    local exceptKnights = {}
                    if firstTeam then
                        table.foreach(firstTeam, function ( i , value )
                            if value > 0 then
                                exceptKnights[value] = 1
                            end
                        end)
                    end
                    if secondTeam then
                        table.foreach(secondTeam, function ( i , value )
                            if value > 0 then
                                exceptKnights[value] = 1
                            end
                        end)
                    end
                    exceptKnights[self._mainKnightId] = 1

                    local _knightList = G_Me.bagData.knightsData:getCostKnight(cardConfig.advance_code, exceptKnights)
                    -- 取要用多少
                    for j=1, awakenKnightInfo["cost_"..i.."_size"] do
                        knightList[#knightList+1] = _knightList[j]
                    end
                    break
                end
            end
            
            -- 请求之前计算一下当前的属性，保存起来
            local beforeAttr = G_Me.bagData.knightsData:getKnightAttr1(self._mainKnightId)
            
            G_HandlersManager.bagHandler:sendAwakenKnight(self._mainKnightId, knightList)
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AWAKEN_KNIGHT_NOTI, function(_, message)
                if message.ret == NetMsg_ERROR.RET_OK then
                    
                    local btnAwaken = self:getButtonByName("Button_awaken")
                    btnAwaken:removeAllNodes()
                    
                    local btnAwakenItems = self:getButtonByName("Button_awaken_items")
                    
                    -- 屏蔽按钮
                    btnAwaken:setEnabled(false)
                    btnAwakenItems:setEnabled(false)

                    local items = {}
                    for i=1, 4 do
                        items[#items+1] = awakenKnightInfo["item_id_"..i]
                    end

                    -- 是否升星，升几星
                    local _levelUp = (awakenKnightInfo.awaken_level+1) % 10 == 0
                    local _level = (awakenKnightInfo.awaken_level+1) / 10
                    local afterAttr = G_Me.bagData.knightsData:getKnightAttr1(self._mainKnightId)

                    -- 播放动画
                    self:_playAwakenKnightAnimation(items, function(event)

                        -- 道具飞入结束
                        if event == "finish" then
                            -- 如果有升星，则播放升星动画
                            if _levelUp then
                                -- 这里模拟进阶那段动画=.=
                                local sprite = display.newSprite(G_Path.getShopCardDir() .."circle.png")
                                uf_sceneManager:getCurScene():addChild(sprite)
                                sprite:setPosition(sprite:getParent():convertToNodeSpace(self._awakenKnight:convertToWorldSpaceAR(ccp(0, 100))))
                                sprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.2, 20), CCCallFunc:create(function()

                                    sprite:removeFromParent()
                                    -- 白幕
                                    local whiteLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))
                                    uf_sceneManager:getCurScene():addChild(whiteLayer)

                                    whiteLayer:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.4), CCCallFunc:create(function()
                                        whiteLayer:removeFromParent()
                                    end)))

                                    -- 跳跃的卡牌
                                    local jumpCardNode = nil

                                    -- 加载UI, waitfunc是UI加载后的等待回调
                                    --knightId, startWorldPosition, jumpToWorldPosition, jumpToScale, waitCallback, endCallback
                                    local waitfunc = function() 
                                        require("app.scenes.herofoster.HeroAwakenLevelUpLayer").showHeroAwakenLevelUpLayer(self, 
                                            self._mainKnightId,
                                            beforeAttr,
                                            afterAttr,
                                            function()
                                                if jumpCardNode then
                                                    jumpCardNode:resume()
                                                end
                                            end)
                                    end

                                    -- jumpcard播放完成的回调
                                    local endfunc = function()
                                        -- 跳跃完成后恢复显示
                                        self._awakenKnight:setVisible(true)
                                        if jumpCardNode then
                                            jumpCardNode:removeFromParentAndCleanup(true)
                                        end
                                        -- 升星动画
                                        self:_playAwakenLevelUpStarAnimation(_level)

                                        -- 重启按钮
                                        --btnAwaken:setEnabled(true)
                                        --btnAwakenItems:setEnabled(true)
                                        -- 更新全部
                                        --self:_updateView(true)

                                        --觉醒说明动画效果                                     
                                        
                                        self:_playTalentDescAnimation(self:getLabelByName("Label_cur_talent_desc"), 0.25)
                                        self:_playTalentDescAnimation(self:getImageViewByName("Image_cur_talent_bg"), 0.25)
                                        self:_playTalentDescAnimation(self:getLabelByName("Label_cur_talent"), 0.25, true)
                                        

                                    end

                                    local position = self._awakenKnight:convertToWorldSpace(ccp(0, 0))

                                    -- 创建跳跃卡牌前得先隐藏原卡牌
                                    self._awakenKnight:setVisible(false)

                                    jumpCardNode = JumpCard.create(knightInfo.base_id, position,
                                    position, 0.5, waitfunc, endfunc, knightInfo.base_id == G_Me.bagData.knightsData:getMainKnightBaseId() and G_Me.dressData:getDressedPic() or nil)
                                    uf_notifyLayer:getModelNode():addChild(jumpCardNode)

                                end)))
                            else
                                -- 没有就飘差值
                                -- 觉醒成功

                                G_flyAttribute.addNormalText(G_lang:get("LANG_AWAKEN_PUTON_EQUIPMENT_SUCCESS_DESC"))
 
                                local delayUpdateView = false

                                --增加星级说明
                                if awakenKnightInfo.point and awakenKnightInfo.point > 0 then
                                    G_flyAttribute.addNormalText(awakenKnightInfo.spark_title, Colors.darkColors.DESCRIPTION, nil, nil, nil, 32)
                                    G_flyAttribute.addNormalText(awakenKnightInfo.spark_directions, Colors.darkColors.DESCRIPTION, nil, nil, nil, 32)
                                
                                    delayUpdateView = true

                                    --觉醒说明动画效果
                                    self:_playTalentDescAnimation(self:getLabelByName("Label_cur_talent_desc"), 2.5)                                   
                                    self:_playTalentDescAnimation(self:getImageViewByName("Image_cur_talent_bg"), 2.5)
                                    self:_playTalentDescAnimation(self:getLabelByName("Label_cur_talent"), 2.5, true)
                                    

                                end

                                G_flyAttribute.addKnightAttri1Change(beforeAttr, afterAttr)
                                G_flyAttribute.play()
                                
                                if delayUpdateView == false then
                                    -- 重启按钮
                                    btnAwaken:setEnabled(true)
                                    btnAwakenItems:setEnabled(true)
                                    -- 更新全部
                                    self:_updateView(true)
                                end

                            end
                        end
                    end)

                end
                uf_eventManager:removeListenerWithTarget(self)
            end, self)
        end
        
    end)
    
    local btn = self:getButtonByName("Button_awaken")
    btn:removeAllNodes()
    
    -- 流光特效是只有在等级满足且装备齐且材料齐且钱齐的情况下才有
    if enoughLevel and beEquippedFull and enoughMaterial and enoughMoney then
        -- 播放觉醒按钮流光特效
        local node = EffectNode.new("effect_around2")
        node:setScale(1.6)
        node:setPositionY(-3)
        node:play()
        
        btn:addNode(node)
    end
    
end

-- 更新觉醒武将本身
function HeroAwakenLayer:_updateAwakenKnight()
    
    -- 人物入场
    local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
    assert(knightInfo, "Could not find the knightInfo with id: "..tostring(self._mainKnightId))
    
    local cardConfig = clone(knight_info.get(knightInfo.base_id))
    assert(cardConfig, "Could not find the card config with id:"..tostring(knightInfo.base_id))

    -- 主角有时装
    if knightInfo.base_id == G_Me.bagData.knightsData:getMainKnightBaseId() then
        -- 这里注意使用的是克隆版的cardconfig而不能是原版，否则就会直接覆盖数据
        cardConfig.res_id = G_Me.dressData:getDressedPic()
    end
    
    local awakenKnightInfo = knight_awaken_info.get(cardConfig.awaken_code, knightInfo.awaken_level)
    assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..cardConfig.awaken_code..", "..knightInfo.awaken_level)
    
    -- 武将名称
--    _updateLabel(self, "Label_knight_name", {text=cardConfig.name, color=Colors.qualityColors[cardConfig.quality], stroke=Colors.strokeBrown, strokeSize=2})
    
    -- 隐藏天赋文字和星星等
    _updatePanel(self, "Panel_cur_talent", {visible=false})
    _updatePanel(self, "Panel_stars", {visible=false})
    _updateImageView(self, "Image_name_bg", {visible=false})
    
    local cardNode = nil
    
    local jumpNode = require("app.common.effects.EffectMovingNode").new("moving_card_jump", 
        function(key)
            -- 角色卡牌
            if key == "char" then
                cardNode = display.newNode()
                local cardSprite = _createKnight(G_Path.getKnightPic(cardConfig.res_id), G_Path.getKnightPicConfig(cardConfig.res_id), true)
                cardSprite:setScale(0.5)
                cardNode:addChild(cardSprite)
                
                self._awakenKnight = cardSprite
                return cardNode
            -- 烟尘
            elseif key == "effect_card_dust" then
                local effect = require("app.common.effects.EffectNode").new("effect_card_dust")
                effect:play()
                return effect  
            end
        end,
        function(event)
            if event == "finish" then
                if cardNode then
                    -- 呼吸动画
--                    cardNode:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(1.5, 1.05), CCScaleTo:create(1.5, 1))))
                    require("app.common.effects.EffectSingleMoving").run(cardNode, "smoving_idle", nil, {}, 1+math.floor(math.random()*30))
                end

                -- 没有下一个觉醒id了，则全部不显示
                if awakenKnightInfo.next_awaken_id == 0 then
                    _updatePanel(self, "Panel_cur_talent", {visible=false})
                -- 卡牌等级没到无法进行下一阶段的觉醒
                elseif awakenKnightInfo.level_ban > knightInfo.level then
                    _updateLabel(self, "Label_cur_talent", {visible=true})
                    _updateLabel(self, "Label_cur_talent_desc", {visible=false})
                end
                
                -- 显示
                _updatePanel(self, "Panel_cur_talent", {visible=true})
                _updatePanel(self, "Panel_stars", {visible=true})
                _updateImageView(self, "Image_name_bg", {visible=true})
            end
        end
    )
    
    -- 角色响应
    self:registerWidgetClickEvent("Panel_onKnightClick", function()
        if CCDirector:sharedDirector():getSceneCount() > 1 then 
            uf_sceneManager:popScene()
        else
            uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
        end
    end)
    
    local panel = self:getPanelByName("Panel_knight_content")
    panel:removeAllNodes()
    panel:addNode(jumpNode)

    jumpNode:play()
    
end

-- 更新觉醒武将信息
function HeroAwakenLayer:_updateAwakenKnightInfo(awakenKnightInfo, withAnimation)
    
    local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(self._mainKnightId)
    assert(knightInfo, "Could not find the knightInfo with id: "..tostring(self._mainKnightId))
    
    -- 觉醒x级
    _updateLabel(self, "Label_awaken_desc1", {text=G_lang:get("LANG_AWAKEN_LEVEL_DESC1", {star=math.floor(awakenKnightInfo.awaken_level/10)}), stroke=Colors.strokeBrown, strokeSize=2})
    _updateLabel(self, "Label_awaken_desc2", {text=G_lang:get("LANG_AWAKEN_LEVEL_DESC2", {level=awakenKnightInfo.awaken_level % 10}), stroke=Colors.strokeBrown, strokeSize=2})
    
    if withAnimation then
        -- 动态效果
        local function _playLevelAnimation(name)
            local label = self:getLabelByName(name)
            if label then
                label:stopActionByTag(100)
                label:setScale(1)

                local array = CCArray:create()
                array:addObject(CCScaleBy:create(0.2, 2))
                array:addObject(CCDelayTime:create(0.1))
                array:addObject(CCScaleBy:create(0.2, 0.5))

                local action = CCSequence:create(array)
                action:setTag(100)
                label:runAction(action)
            end
        end
        
        if knightInfo.awaken_level % 10 == 0 then
            -- 几星
            _playLevelAnimation("Label_awaken_desc1")
            -- 几级
            _playLevelAnimation("Label_awaken_desc2")
        else
            _playLevelAnimation("Label_awaken_desc2")
        end
    end
    
    -- 星级
    for i=1, 5 do
        _updateImageView(self, "Image_star"..i, {visible=awakenKnightInfo.awaken_level >= i*10})
    end
    
    local getPosition = _autoAlign(ccp(0, 0), {
        self:getLabelByName("Label_awaken_desc1"),
        self:getLabelByName("Label_space"),
        self:getLabelByName("Label_awaken_desc2"),
    }, ALIGN_CENTER)
    
    self:getLabelByName("Label_awaken_desc1"):setPosition(getPosition(1))
    self:getLabelByName("Label_space"):setPosition(getPosition(2))
    self:getLabelByName("Label_awaken_desc2"):setPosition(getPosition(3))
    
    -- 卡牌未满级且到了下一级觉醒
    local enoughLevel = true
    
    -- 觉醒已满级
    if awakenKnightInfo.next_awaken_id == 0 then
        enoughLevel = false
        _updateLabel(self, "Label_cur_talent", {text=G_lang:get("LANG_AWAKEN_LEVEL_MAX_DESC"), stroke=Colors.strokeBrown, strokeSize=2})
        _updateLabel(self, "Label_cur_talent_desc", {visible=false})
    -- 卡牌等级没到无法进行下一阶段的觉醒
    elseif awakenKnightInfo.level_ban > knightInfo.level then
        enoughLevel = false
        _updateLabel(self, "Label_cur_talent", {text=G_lang:get("LANG_AWAKEN_UNLOCK_TALENT_LIMIT_DESC", {level=awakenKnightInfo.level_ban}), stroke=Colors.strokeBrown, strokeSize=2})
        _updateLabel(self, "Label_cur_talent_desc", {visible=false})
    -- 显示觉醒天赋
    else
        --_updateLabel(self, "Label_cur_talent", {text=G_lang:get("LANG_AWAKEN_UNLOCK_TALENT_DESC", {level=math.floor(awakenKnightInfo.awaken_level / 10)+1}), stroke=Colors.strokeBrown, strokeSize=2})   
        --local abilityId = awakenKnightInfo.ability_id_show     
        --local passiveSkillInfo = passive_skill_info.get(abilityId)
        --assert(passiveSkillInfo, "Could not find the passiveSkillInfo with id: "..abilityId)
        --_updateLabel(self, "Label_cur_talent_desc", {text=passiveSkillInfo.directions, stroke=Colors.strokeBrown, strokeSize=2})
        
        _updateLabel(self, "Label_cur_talent", {text=awakenKnightInfo.spark_title, stroke=Colors.strokeBrown, strokeSize=2})   
        _updateLabel(self, "Label_cur_talent_desc", {text=awakenKnightInfo.spark_directions, stroke=Colors.strokeBrown, strokeSize=2})
      
    end
    
    return enoughLevel
    
end

-- 更新觉醒所需装备
function HeroAwakenLayer:_updateAwakenEquipments(awakenKnightInfo)
    
    -- 全部装备齐全
    local beEquippedFull = true
    
    -- 觉醒装备最多4个，如果没有则不显示
    for i=1, 4 do
        
        local itemId = awakenKnightInfo["item_id_"..i]
        
        -- 装备icon和背景
        _updateImageView(self, "Image_bg"..i, {visible=(itemId ~= 0)})
        _updateImageView(self, "Image_icon"..i, {visible=(itemId ~= 0)})
        _updateImageView(self, "Image_frame"..i, {visible=(itemId ~= 0)})
        
        -- 觉醒状态
        _updateImageView(self, "Image_equipment"..i, {visible=(itemId ~= 0)})
        
        if itemId ~= 0 then
            local itemInfo = item_awaken_info.get(itemId)
            assert(itemInfo, "Could not find the awaken item with id: "..itemId)

            _updateImageView(self, "Image_bg"..i, {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
            _updateImageView(self, "Image_icon"..i, {texture=itemInfo.icon})
            _updateImageView(self, "Image_frame"..i, {texture=G_Path.getEquipColorImage(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
            
            local HeroAwakenItemDetailLayer = require("app.scenes.herofoster.HeroAwakenItemDetailLayer")
            local state = HeroAwakenItemDetailLayer.STATE_CERTAIN
            
            -- 是否已装备
            local equipped = G_Me.bagData.knightsData:isEquippedAwakenItem(self._mainKnightId, itemId, i)
            beEquippedFull = beEquippedFull and equipped
            -- 是否可装备
            local canBeEquipped = G_Me.bagData:containAwakenItem(itemId)
            -- 是否可合成
            local canBeComposed = G_Me.bagData:awakenItemCanBeComposed(itemId, 1)
            -- 本身可合成
            local couldBeComposed = itemInfo.compose_id ~= 0
            
            self:getImageViewByName("Image_icon"..i):showAsGray(not equipped)
            self:getImageViewByName("Image_bg"..i):showAsGray(not equipped)
            self:getImageViewByName("Image_frame"..i):showAsGray(not equipped)
            
            local stateDesc = nil
            
            if equipped then
                state = HeroAwakenItemDetailLayer.STATE_CERTAIN
            elseif canBeEquipped then
                state = HeroAwakenItemDetailLayer.STATE_EQUIP
                stateDesc = G_lang:get("LANG_AWAKEN_EQUIPMENT_STATE_EQUIP_DESC")
            elseif canBeComposed then
                state = HeroAwakenItemDetailLayer.STATE_COMPOSE
                stateDesc = G_lang:get("LANG_AWAKEN_EQUIPMENT_STATE_COMPOSE_DESC")
            elseif couldBeComposed then
                state = HeroAwakenItemDetailLayer.STATE_COMPOSE
                stateDesc = G_lang:get("LANG_AWAKEN_EQUIPMENT_STATE_NONE_DESC")
            else
                state = HeroAwakenItemDetailLayer.STATE_GET
                stateDesc = G_lang:get("LANG_AWAKEN_EQUIPMENT_STATE_NONE_DESC")
            end
            
            -- 更新觉醒状态
            -- 文字分“无道具”，“可合成”，“可装备”
            _updateLabel(self, "Label_state_desc"..i, {visible=state ~= HeroAwakenItemDetailLayer.STATE_CERTAIN, text=stateDesc, color=((state == HeroAwakenItemDetailLayer.STATE_COMPOSE or state == HeroAwakenItemDetailLayer.STATE_GET) and Colors.darkColors.TITLE_02 or Colors.darkColors.ATTRIBUTE), strokeSize=2, stroke=Colors.strokeBrown})
            -- 当前不可装备的且可合成的道具
            _updateImageView(self, "Image_state_compose"..i, {visible=(not equipped and not canBeEquipped and canBeComposed)})
            -- 可装备的道具
            _updateImageView(self, "Image_state_equip"..i, {visible=(not equipped and canBeEquipped)})
            
            -- 觉醒装备按钮响应
            self:registerWidgetClickEvent("Image_icon"..i, function()
                
                local layer = HeroAwakenItemDetailLayer.create(itemId, state, function(_state, _layer)
                    self:_DetailLayerCallback(_state, _layer, itemId, i)

                end)
                uf_sceneManager:getCurScene():addChild(layer)

            end)
            
        end        
    end
    
    return beEquippedFull
    
end

function HeroAwakenLayer:_DetailLayerCallback(_state, _layer, itemId, i)
    -- 表示获取状态确认
    local HeroAwakenItemDetailLayer = require("app.scenes.herofoster.HeroAwakenItemDetailLayer")

    self._scenePack.param[4] = _state

    local itemInfo = item_awaken_info.get(itemId)

    if _state == HeroAwakenItemDetailLayer.STATE_GET then

        self._scenePack.param[3] = nil
        self._scenePack.param[4] = nil
        require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_AWAKEN_ITEM, itemId, self._scenePack)

    -- 表示装备状态确认
    elseif _state == HeroAwakenItemDetailLayer.STATE_EQUIP and i then
        -- 请求穿戴装备
        G_HandlersManager.bagHandler:sendPutonAwakenItem(self._mainKnightId, i-1, itemId)
        -- 监听消息
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AWAKEN_PUTON_ITEM_NOTI, function(_, message)
            if message.ret == NetMsg_ERROR.RET_OK then
                -- 成功后飘字，关闭弹窗

                local MergeEquipment = require "app.data.MergeEquipment"
                for i=1, 3 do
                    if itemInfo["str_type_"..i] ~= 0 then
                        local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(itemInfo["str_type_"..i], itemInfo["str_value_"..i])
                        G_flyAttribute.addNormalText(strtype.."+"..strvalue, Colors.getColor(2))    -- 飘字用固定颜色
                    end
                end

                G_flyAttribute.play()

                -- 播特效
                self:_playPutonAwakenEquipmentAnimation(i)
                if _layer then
                    _layer:animationToClose()
                end

                -- 更新界面
                self:_updateView()
            end
            uf_eventManager:removeListenerWithTarget(self)
        end, self)

    -- 表示合成状态确认
    elseif _state == HeroAwakenItemDetailLayer.STATE_COMPOSE then

        local newlayer = require("app.scenes.herofoster.HeroAwakenItemComposeLayer").create(nil, itemId, self._scenePack,
            function(_itemId, _newLayer ,fastCompose,num)
                -- 两处调用，提取出来
                local returnOk = function() 
                    _newLayer:lock()
                    local levelCount = _newLayer:getLevel()
                    if levelCount == 1 then
                        -- 切换至装备状态
                        _layer:setState(HeroAwakenItemDetailLayer.STATE_EQUIP)
                        -- 然后刷新detail页面
                        _layer:updateView()
                        -- 同时主界面也要更新
                        self:_updateView()
                    end
                    _newLayer:playComposeAnimation(function(event)
                        if event == "finish" then
                            _newLayer:unlock()
                            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_SUCCESS_DESC"))
                            -- 如果这个时候合成的是第一层级的道具，则要更新上一个页面，因为很可能已经可以装备
                            if levelCount == 1 then
                                -- 直接关闭
                                _newLayer:animationToClose()
                            else
                                -- 如果已经数量已足够则弹出最顶层的合成道具
                                if _newLayer:enoughToCompose() then
                                    _newLayer:popItem()
                                    -- 更新合成树
                                    _newLayer:updateComposeTree()
                                else
                                    -- 更新合成树
                                    _newLayer:updateComposeTree(nil, false)
                                end
                            end
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
                    G_HandlersManager.bagHandler:sendFastComposeAwakenItem(_itemId,num)
                    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FAST_AWAKEN_COMPOSE_ITEM_NOTI, function(_, message)
                        if message.ret == NetMsg_ERROR.RET_OK then
                            returnOk()
                            _newLayer:doNotRealLabelAndAnimation(true)
                        else 
                            -- 不ok的情况
                            _newLayer:updateComposeTree(nil, false)
                            _newLayer:doNotRealLabelAndAnimation(false)
                        end
                        uf_eventManager:removeListenerWithTarget(self)
                    end, self)
                end 
            end)
        uf_sceneManager:getCurScene():addChild(newlayer)
        newlayer:setParentLayer(_layer)
    end
end

-- 觉醒穿戴装备动画
function HeroAwakenLayer:_playPutonAwakenEquipmentAnimation(position, callback)
    
    -- 觉醒穿戴装备后装备上冒星星
    
    local imgEquipment = self:getImageViewByName("Image_equipment"..position)
    imgEquipment:removeAllNodes()
    
    local effect = EffectNode.new("effect_particle_star")
    imgEquipment:addNode(effect)
    effect:play()
    effect:setScale(0.5)
    
    local actionArr = CCArray:create()
    actionArr:addObject(CCDelayTime:create(1))
    actionArr:addObject(CCFadeOut:create(0.5))
    actionArr:addObject(CCRemoveSelf:create())
    actionArr:addObject(CCCallFunc:create(function()
        if callback then
            callback("finish")
        end
    end))
    
    effect:runAction(CCSequence:create(actionArr))
    
end

function HeroAwakenLayer:_playTalentDescAnimation(item, delayTime, addEffect)

    if not item then return end

    local delay = delayTime or 0.25

    item:stopAllActions()

    local startPosX, startPosY = item:getPosition()
    local actionArr = CCArray:create()
    actionArr:addObject(CCDelayTime:create(delay))

    actionArr:addObject(CCEaseElasticOut:create(CCMoveBy:create(1, ccp(0, 50)), 0.35))
    item:runAction(CCSequence:create(actionArr))
    
    actionArr = CCArray:create()
    actionArr:addObject(CCDelayTime:create(delay+0.8))
                                           
    local moveToAction = CCMoveTo:create(0.3, 
        self:getLabelByName("Label_cur_talent"):convertToNodeSpace(self._awakenKnight:convertToWorldSpaceAR(ccp(0, 200))))

    local scaleToAction = CCScaleTo:create(0.3, 0.0001)

    actionArr:addObject(CCSpawn:createWithTwoActions(moveToAction, scaleToAction))

    actionArr:addObject(CCCallFunc:create(function()
        item:setPosition(ccp(startPosX, startPosY))
        item:setScale(1)
        item:setOpacity(0)
    end))

    if addEffect then
        
        actionArr:addObject(CCCallFunc:create(function()
            -- 重启按钮
            self:getButtonByName("Button_awaken"):setEnabled(true)
            self:getButtonByName("Button_awaken_items"):setEnabled(true)
            -- 更新全部
            self:_updateView(true)
        end))
    end


    if addEffect then
        actionArr:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(1.0),
            CCCallFunc:create(function()
                local effectStar = EffectNode.new("effect_juexing_zhi")
                item:removeAllNodes()
                item:addNode(effectStar)
                effectStar:play()
                effectStar:setPositionY(-20)
                effectStar:setScale(1.2)

                local effectActionArr = CCArray:create()
                effectActionArr:addObject(CCDelayTime:create(3.5))
                effectActionArr:addObject(CCRemoveSelf:create())
                effectStar:runAction(CCSequence:create(effectActionArr))
            end))
        )
    else
        actionArr:addObject(CCFadeIn:create(1.0))
    end

    item:runAction(CCSequence:create(actionArr))

end


-- 觉醒动画
function HeroAwakenLayer:_playAwakenKnightAnimation(items, callback)

    for i=1, #items do
        
        if items[i] ~= 0 then
            
            _updateImageView(self, "Image_icon"..i, {visible=false})
            
            local itemInfo = item_awaken_info.get(items[i])
            assert(itemInfo, "Could not find the awaken item with id: "..items[i])
            
            local imgEquipment = self:getImageViewByName("Image_equipment"..i)
            imgEquipment:removeAllNodes()
            
            local node = display.newNode()
            imgEquipment:addNode(node)

            local effectShine = EffectNode.new("effect_juexing_a")
            node:addChild(effectShine)
            effectShine:play()

            local icon = display.newSprite(itemInfo.icon)
            node:addChild(icon)

            local effectStar = EffectNode.new("effect_particle_star")
            node:addChild(effectStar)
            effectStar:setScale(0.5)
            effectStar:play()

            local actionArr = CCArray:create()
            actionArr:addObject(CCEaseElasticOut:create(CCMoveBy:create(1.5, ccp(0, 100)), 0.35))
            node:runAction(CCSequence:create(actionArr))
            
            actionArr = CCArray:create()
            actionArr:addObject(CCDelayTime:create((i-1) * 0.15 + 0.8))
            
            assert(self._awakenKnight, "awaken knight could not be nil !")
            actionArr:addObject(CCMoveTo:create(0.5, node:getParent():convertToNodeSpace(self._awakenKnight:convertToWorldSpaceAR(ccp(0, 200)))))
            
            actionArr:addObject(CCCallFunc:create(function()
                if i == 1 then
                    local panel = self:getPanelByName("Panel_knight_effect")
                    panel:removeAllNodes()
                    
                    local effect = EffectNode.new("effect_juexing_new", function(event, frameIndex, _effect)
                        if event == "finish" then
                            _effect:removeFromParent()   
                            if callback then
                                callback("finish")
                            end
                        end
                    end)
                    panel:addNode(effect)
                    effect:setPositionY(100)
                    effect:setScale(1.3)
                    effect:play()
                end
            end))
            
            actionArr:addObject(CCRemoveSelf:create())
            
            node:runAction(CCSequence:create(actionArr))
        end
    end
    
end

-- 觉醒升级加星动画
function HeroAwakenLayer:_playAwakenLevelUpStarAnimation(level, callback)
    
    local imgStar = self:getImageViewByName("Image_star"..level)
    imgStar:stopAllActions()
    imgStar:setPositionY(imgStar:getPositionY() + 30)
    imgStar:setOpacity(0)
    imgStar:setVisible(true)

    local actionArr = CCArray:create()
    actionArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.3, ccp(0, -30)), CCFadeIn:create(0.3)))
    actionArr:addObject(CCCallFunc:create(function()

        imgStar:removeAllNodes()

        local _effectStar = EffectNode.new("effect_juexing_c")
        imgStar:addNode(_effectStar)
        _effectStar:play()

        if callback then
            callback("finish")
        end
    end))

    imgStar:runAction(CCSequence:create(actionArr))
    
end

-- 更新觉醒材料
function HeroAwakenLayer:_updateAwakenMaterials(awakenKnightInfo)
    
    local enoughMaterial = true
    
    -- 觉醒材料
    _updateLabel(self, "Label_awaken_material", {text=G_lang:get("LANG_AWAKEN_MATERIAL_DESC"), stroke=Colors.strokeBrown, strokeSize=2})
    
    -- 材料共两样，第二样可能没有
    local function _updateMaterial(index)
    
        local _type = awakenKnightInfo["cost_"..index.."_type"]
        
        if _type ~= 0 then
            
            if _type == 1 then
                _type = G_Goods.TYPE_KNIGHT
            elseif _type == 2 then
                _type = G_Goods.TYPE_ITEM
            end
            
            local _value = awakenKnightInfo["cost_"..index.."_value"]
            local _size = awakenKnightInfo["cost_"..index.."_size"]

            local good = G_Goods.convert(_type, _value, _size)

            _updateImageView(self, "Image_material_frame"..index, {texture=G_Path.getEquipColorImage(good.quality), texType=UI_TEX_TYPE_PLIST})
            _updateImageView(self, "Image_material_bg"..index, {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
            _updateImageView(self, "Image_material_icon"..index, {texture=good.icon})
            _updateLabel(self, "Label_material_name"..index, {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBrown, strokeSize=2})
            
            if _type == G_Goods.TYPE_KNIGHT then  
                local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
                local secondTeam = G_Me.formationData:getSecondTeamKnightIds()
                local exceptKnights = {}
                if firstTeam then
                    table.foreach(firstTeam, function ( i , value )
                        if value > 0 then
                            exceptKnights[value] = 1
                        end
                    end)
                end
                if secondTeam then
                    table.foreach(secondTeam, function ( i , value )
                        if value > 0 then
                            exceptKnights[value] = 1
                        end
                    end)
                end
                exceptKnights[self._mainKnightId] = 1

                local costKnightList = G_Me.bagData.knightsData:getCostKnight(_value, exceptKnights)

                local knightNums = #costKnightList
                local expectNums = _size
                _updateLabel(self, "Label_material_amount"..index, {text=''..knightNums.."/"..expectNums, color=knightNums < expectNums and Colors.lightColors.TIPS_01 or nil})
                
                enoughMaterial = enoughMaterial and knightNums >= expectNums
                
            elseif _type == G_Goods.TYPE_ITEM then
                local itemNums = G_Me.bagData:getPropCount(_value)
                local expectNums = _size
                _updateLabel(self, "Label_material_amount"..index, {text=''..itemNums.."/"..expectNums, color=itemNums < expectNums and Colors.lightColors.TIPS_01 or nil})
                
                enoughMaterial = enoughMaterial and itemNums >= expectNums
                
            end
            
            self:registerWidgetClickEvent("Image_material_icon"..index, function()
--                require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(good.type, good.value, self._scenePack)
            end)
            
            return true
        end
        
        return false
    end
    
    _updateImageView(self, "Image_material1", {visible=_updateMaterial(1)})
    _updateImageView(self, "Image_material2", {visible=_updateMaterial(2)})
    
    return enoughMaterial
    
end

-- 更新觉醒花费
function HeroAwakenLayer:_updateAwakenCost(awakenKnightInfo)
    
    local hasMoney = G_Me.userData.money
    local costMoney = awakenKnightInfo.money_cost
    
    -- 觉醒花费
    _updateLabel(self, "Label_yinbi_value", {text=costMoney, color=hasMoney >= costMoney and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01})
    
    -- 这里消耗类型（银两）固定
    return hasMoney >= costMoney
    
end

function HeroAwakenLayer:adapterLayer(...)
    
end

return HeroAwakenLayer

