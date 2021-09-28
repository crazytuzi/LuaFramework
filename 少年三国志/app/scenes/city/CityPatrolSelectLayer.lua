-- CityPatrolSelectLayer
-- 领地巡逻界面

local _split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

local function _updatePanel(target, name, params)
    
    local panel = target:getPanelByName(name)
    assert(panel, "Could not find the panel with name: "..name)

    if params.visible ~= nil then
        panel:setVisible(params.visible)
    end
    
end

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
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
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

local function _convertUnit(num)
    if num >= 10000 and num < 100000000 then
        return math.floor(num / 10000)..G_lang:get("LANG_WAN")
    elseif num >= 100000000 then
        return math.floor(num / 100000000)..G_lang:get("LANG_YI")
    else
        return num
    end
end

require "app.cfg.city_info"
require "app.cfg.city_end_event_info"
require "app.cfg.knight_info"
require "app.cfg.fragment_info"
require "app.cfg.city_knight_text"


-- local hours = {4, 8, 12}
-- local minutes = {30, 20, 10}

local CityPatrolSelectLayer = class("CityPatrolSelectLayer", UFCCSNormalLayer)

CityPatrolSelectLayer.HOURS     = {4, 8, 12}
CityPatrolSelectLayer.MINUTES   = {30, 20, 10}
-- _hasAbilityToPay中用到的常量
CityPatrolSelectLayer.MONEY         = 1
CityPatrolSelectLayer.GOLD          = 2
CityPatrolSelectLayer.SHENGWANG     = 3
CityPatrolSelectLayer.ZHANGONG      = 4
CityPatrolSelectLayer.PATAJIFEN     = 5
CityPatrolSelectLayer.JIANGHUN      = 6
CityPatrolSelectLayer.TILI          = 7
CityPatrolSelectLayer.JINGLI        = 8

function CityPatrolSelectLayer.create(...)
    return CityPatrolSelectLayer.new("ui_layout/city_PatrolSelectMainLayer.json", nil, ...)
end

function CityPatrolSelectLayer:ctor(_, _, index, knight, callback)
    
    CityPatrolSelectLayer.super.ctor(self)
    
    self:initData(index, knight, callback)

    -- 手动适配一下位置
    local panel = self:getPanelByName("Panel_knight")
    panel:setPositionY(panel:getPositionY() + (display.height - 853) * 0.4)
        
end

function CityPatrolSelectLayer:initData(index, knight, callback)
        
    -- 记录一下城池的索引
    self._index = index
    
    -- 记录一下选择的武将
    self._knight = knight
    
    -- 结束回调
    self._callback = callback
    
end

function CityPatrolSelectLayer:getCityIndex() return self._index end

function CityPatrolSelectLayer:onLayerEnter()
    
    self:_initCityPatrolSelectLayer()
    
end

function CityPatrolSelectLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function CityPatrolSelectLayer:_hasAbilityToPay(costType, costAmount)
    
    if costType == CityPatrolSelectLayer.MONEY then   -- 银元
        return G_Me.userData.money >= costAmount, G_lang:get("LANG_NO_MONEY_TIPS")
    elseif costType == CityPatrolSelectLayer.GOLD then   -- 元宝
        return G_Me.userData.gold >= costAmount
    elseif costType == CityPatrolSelectLayer.SHENGWANG then   -- 声望
        return G_Me.userData.prestige >= costAmount, G_lang:get("LANG_SHENG_WANG_NOT_ENOUGH")
    elseif costType == CityPatrolSelectLayer.ZHANGONG then   -- 战功
        return G_Me.userData.medal >= costAmount, G_lang:get("LANG_JIANG_ZHANG_NOT_ENOUGH")
    elseif costType == CityPatrolSelectLayer.PATAJIFEN then   -- 爬塔积分
        return G_Me.userData.tower_score >= costAmount, G_lang:get("LANG_ZHAN_GONG_JIFEN_NOT_ENOUGH")
    elseif costType == CityPatrolSelectLayer.JIANGHUN then   -- 将魂
        return G_Me.userData.essence >= costAmount, G_lang:get("LANG_CITY_PATROL_COST_ESSENCE_NOT_ENOUGH")
    elseif costType == CityPatrolSelectLayer.TILI then   -- 体力
        return G_Me.userData.vit >= costAmount
    elseif costType == CityPatrolSelectLayer.JINGLI then   -- 精力
        return G_Me.userData.spirit >= costAmount
    else
        assert(false, 'Unknown costType: '..costType)
    end
    
end

function CityPatrolSelectLayer:_initCityPatrolSelectLayer()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)
    
    local cardConfig = knight_info.get(self._knight.base_id)
    assert(cardConfig, "Could not find the card config with id:"..self._knight.base_id)
    
    local cardJson = decodeJsonFile(G_Path.getKnightPicConfig(cardConfig.res_id))
    assert(cardJson, "Could not read the json with name: "..cardConfig.res_id)
    
    -- 背景界面需要更新，未来打算根据city_info里的资源id来读取
    _updateImageView(self, "Image_bg", {texture=G_Path.getCityBGPathWithId(city.pic2)})
    
    -- 更新下城市名称
    _updateImageView(self, "Image_city_name", {texture=G_Path.getCityNamePathWithId(city.id)})
    
    -- 隐藏对话框和人物名称
    _updateImageView(self, "Image_dialog", {visible=false})
    _updateImageView(self, "Image_role_name_bg", {visible=false})
        
    local cardSprite = nil
    local shadowNode = display.newNode()
    
    local jumpNode = require("app.common.effects.EffectMovingNode").new("moving_card_jump", 
        function(key)
            -- 角色卡牌
            if key == "char" then
                cardSprite = display.newSprite(G_Path.getKnightPic(cardConfig.res_id))
                local anchorPoint = cardSprite:getAnchorPoint()
                __Log("anchorPoint:(%f, %f)", anchorPoint.x, anchorPoint.y)
                local size = cardSprite:getCascadeBoundingBox(true).size
                anchorPoint = ccp((anchorPoint.x * size.width - cardJson.x) / size.width, (anchorPoint.y * size.height - cardJson.y) / size.height)
                cardSprite:setAnchorPoint(anchorPoint)
                return cardSprite
            elseif key == "effect_card_dust" then
                local effect = require("app.common.effects.EffectNode").new("effect_card_dust")
                effect:play()
                return effect  
            end
        end,
        function(event)
            if event == "finish" then
                -- 添加阴影
                if cardSprite then
                    local shadow = display.newSprite(G_Path.getKnightShadow())
                    shadow:setPosition(ccp(tonumber(cardJson.shadow_x) + cardSprite:getPositionX(), tonumber(cardJson.shadow_y) + cardSprite:getPositionY()))
                    shadowNode:addChild(shadow)
                    
                    -- 呼吸动画
--                    cardSprite:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(1, 1.05), CCScaleTo:create(1, 1))))
                    require("app.common.effects.EffectSingleMoving").run(cardSprite, "smoving_idle", nil, {}, 1+math.floor(math.random()*30))
                end
                
                -- 显示对话框和人物名称
                _updateImageView(self, "Image_role_name_bg", {visible=true})
                
                local imgDialog = self:getImageViewByName("Image_dialog")
                imgDialog:setVisible(true)
                imgDialog:setScale(0.38)
                imgDialog:runAction(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)))
                
                -- 角色名字
                _updateLabel(self, "Label_role_name", {text=cardConfig.name, color=Colors.qualityColors[cardConfig.quality]})
    
                -- 随机从city_knight_text中取对话
                local dialogs = {}
                local enableCities = {}
                enableCities.set = function(_t)
                    enableCities._content = _t
                end
                enableCities.contain = function(va)
                    for k, v in pairs(enableCities._content) do
                        if v == va then return true end
                    end
                    return false
                end

                for k=1, city_knight_text.getLength() do
                    local v = city_knight_text.indexOf(k)
                    enableCities.set(_split(v.city_id, ","))
                    if enableCities.contain(tostring(city.id)) or v.city_id == "0" then
                        dialogs[#dialogs+1] = v
                    end
                end
                
                -- 对话内容
                math.randomseed(tostring(os.time()):reverse():sub(1, 6))

                _updateLabel(self, "Label_dialog", {text=dialogs[math.random(1, #dialogs)].text})
                
            end
        end
    )
    
    jumpNode:setScale(0.6)
    
    local panel = self:getPanelByName("Panel_knight")
    panel:removeAllNodes()
    panel:addNode(jumpNode)
    
    jumpNode:addChild(shadowNode, -1)
    
    jumpNode:play()
    
    -- 可能获得
    _updateLabel(self, "Label_award_preview_desc", {text=G_lang:get('LANG_CITY_PATROL_SELECT_AWARD_PREVIEW_DESC'), stroke=Colors.strokeBlack})
    
    -- 更新巡逻武将的奖励
    -- 初始值都是1，这里的1表示配置表里为1的开始
    local patrol_time = 1
    local patrol_effect = 1
    local advance_code = knight_info.get(self._knight.base_id).advance_code
    
    self:_updatePatrolKnightAward(city, advance_code, patrol_time, patrol_effect)

    -- 选择巡逻时间响应
    local function _onCheckBoxClick(widget, type, isCheck)
        if isCheck then
            local name = widget:getName()
            local index = tonumber(string.sub(name, string.len(name), string.len(name)))
            patrol_time = index
            self:_updatePatrolKnightAward(city, advance_code, patrol_time, patrol_effect)
        end
    end
    
    -- 巡逻x小时
    for i=1, 3 do
        _updateLabel(self, "Label_patrol_time_desc"..i, {text=G_lang:get('LANG_CITY_PATROL_SELECT_TIME_DESC', {hour=CityPatrolSelectLayer.HOURS[i]})})
        self:addCheckBoxGroupItem(1, "CheckBox_select"..i)
        self:registerCheckboxEvent("CheckBox_select"..i, _onCheckBoxClick)
    end
    
    -- 默认选中1
    self:setCheckStatus(patrol_time, "CheckBox_select1")
    
    -- 普通巡逻
    _updateLabel(self, "Label_select_patrol_desc", {text=G_lang:get("LANG_CITY_PATROL_STYPE_DESC1")})
    
    self:registerBtnClickEvent("Button_select_patrol", function()
        local callback = function(style)
            _updateLabel(self, "Label_select_patrol_desc", {text=G_lang:get("LANG_CITY_PATROL_STYPE_DESC"..style)})
            patrol_effect = style
            self:_updatePatrolKnightAward(city, advance_code, patrol_time, patrol_effect)
        end

        require("app.scenes.city.CityPatrolStyleLayer").show(callback)        
    end)
    
    -- 派遣xxx去巡逻则会获得xxx
    local text = G_lang:get("LANG_CITY_PATROL_KNIGHT_DESC")
    text = GlobalFunc.formatText(text, {
        patrol_knight_color=Colors.qualityDecColors[cardConfig.quality],
        patrol_knight=cardConfig.name,
        fragment_patrol_knight_color = Colors.qualityDecColors[cardConfig.quality],
        fragment_patrol_knight = fragment_info.get(cardConfig.fragment_id).name,
        }
    )
    
    local panel = self:getPanelByName("Panel_knight_desc")
    panel:removeChildByTag(100, true)
    
    local label = self:getLabelByName("Label_knight_desc")
    local size = label:getSize()
    label:setText("")
    
    local label1 = CCSRichText:create(size.width, size.height)
    label1:setFontName(label:getFontName())
    label1:setFontSize(label:getFontSize())
    label1:setShowTextFromTop(true)
    label1:setTextAlignment(ui.TEXT_ALIGN_CENTER)
    label1:enableStroke(Colors.strokeBlack)
    label1:setPositionXY(label:getPositionX(), label:getPositionY() + (display.height-853)*0.15)
    
    label1:clearRichElement()
    label1:appendContent(text, ccc3(255, 255, 255))
    label1:reloadData()
    panel:addChild(label1, 5, 100)
    
    -- 模式没有开始巡逻
    self._isPatrolling = false
    
    -- 开始巡逻响应
    local _onPatrolCallback = function()
        
        -- 表示开始巡逻
        self._isPatrolling = true
        
        -- 开始巡逻动画，先设置按钮不可用
        self:getButtonByName("Button_patrol"):setTouchEnabled(false)

        -- 有一个更换文字的动画，写着“主公加油，我去巡逻了！”
        -- 先更换完文字
        _updateLabel(self, "Label_dialog", {text=G_lang:get("LANG_CITY_PATROL_SELECT_CERTAIN_DESC")})
        
        local imgDialog = self:getImageViewByName("Image_dialog")
        imgDialog:setScale(0.38)
        imgDialog:runAction(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)))
        
        jumpNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCCallFunc:create(function()

            -- 隐藏其他部件
            _updatePanel(self, "Panel_knight_desc", {visible=false})
            _updateImageView(self, "Image_role_name_bg", {visible=false})
            _updateImageView(self, "Image_dialog", {visible=false})

            require("app.common.effects.EffectSingleMoving").run(jumpNode, "smoving_out", function(event)
                if event == "finish" then
                    jumpNode:setVisible(false)

                    local EffectNode = require "app.common.effects.EffectNode"
                    local node = EffectNode.new("effect_yan", function()
                        if self._callback then
                            self._callback()
                        end
                    end)
                    jumpNode:getParent():addNode(node)
                    node:setPositionXY(jumpNode:getPositionX(), jumpNode:getPositionY() + 100)
                    node:play()
                end
            end)
        end)))

    end
    
    self:attachImageTextForBtn("Button_patrol", "Image_patrol_desc")
    self:getButtonByName("Button_patrol"):setTouchEnabled(true)
    
    -- 开始巡逻响应
    self:registerBtnClickEvent("Button_patrol", function()
        
        -- 如果所消耗的物品不足则不可以巡逻
        local ability, err = self:_hasAbilityToPay(self._costType, self._costAmount)
        if not ability then
            if err then
                G_MovingTip:showMovingTip(err)
                return
            else
                if self._costType == 2 then
                    require("app.scenes.shop.GoldNotEnoughDialog").show()
                elseif self._costType == 7 then
                    G_GlobalFunc.showPurchasePowerDialog(1)
                elseif self._costType == 8 then
                    G_GlobalFunc.showPurchasePowerDialog(2)
                end
                return
            end
        end
        
        -- 弹框提示，这里和提示添加好友公用一个框
        local tipLayer = UFCCSModelLayer.new("ui_layout/city_PatrolAddFriendLayer.json", Colors.modelColor)
        uf_sceneManager:getCurScene():addChild(tipLayer)
        tipLayer:closeAtReturn(true)
        require("app.common.effects.EffectSingleMoving").run(tipLayer, "smoving_bounce")
        tipLayer:adapterWithScreen()
        
        local text = G_lang:get("LANG_CITY_PATROL_SELECT_COST_CONFIRM")
        local _texture, _textureType = G_Path.getPriceTypeIcon(self._costType)
        text = GlobalFunc.formatText(text, {
            num = self._costAmount,
            num_color = cardConfig.name,
            hour = CityPatrolSelectLayer.HOURS[self._patrolTime],
            style = G_lang:get("LANG_CITY_PATROL_CONFIRM_STYLE_DESC"..self._patrolEffect),
            icon = _texture,
            texType = _textureType
            }
        )
        
        local label = tipLayer:getLabelByName("Label_add_friend_desc")
        local size = label:getSize()
        label:setText("")

        local label1 = CCSRichText:create(size.width, size.height)
        label1:setFontName(label:getFontName())
        label1:setFontSize(label:getFontSize())
        label1:setShowTextFromTop(true)
        label1:setTextAlignment(ui.TEXT_ALIGN_CENTER)
--        label1:enableStroke(Colors.strokeBlack)
--        label1:setPositionXY(label:getPositionX(), label:getPositionY() + (display.height-853)*0.15)

        label1:clearRichElement()
        label1:appendContent(text, ccc3(255, 255, 255))
        label1:reloadData()
        label:getParent():addChild(label1, 5)

        local function _onClose()
            tipLayer:animationToClose()
            local soundConst = require("app.const.SoundConst")
            G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
        end

        tipLayer:registerBtnClickEvent("Button_close", _onClose)
        tipLayer:enableAudioEffectByName("Button_close", false)

        tipLayer:registerBtnClickEvent("Button_cancel", _onClose)

        tipLayer:registerBtnClickEvent("Button_certain", function()
            
            -- 巡逻请求
            G_HandlersManager.cityHandler:sendCityPatrol(self._index, self._knight.id, patrol_time, patrol_effect)

            -- 收到消息则更新界面
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_PATROL, _onPatrolCallback, self)

            tipLayer:animationToClose()
        end)

    end)
    
end

function CityPatrolSelectLayer:_updatePatrolKnightAward(city, advance_code, patrol_time, patrol_effect)
    
    local award = city_end_event_info.get(advance_code, patrol_time, patrol_effect)
    assert(award, "Could not find the award with advance_code: "..advance_code.." patrol_time: "..patrol_time.." patrol_effect: "..patrol_effect)
    
    self._patrolTime = patrol_time
    self._patrolEffect = patrol_effect
    
    -- 统计一下累计奖励，包含普通掉落和惊喜掉落
    local awards = {_awards = {}}
    
    awards.addAward = function(_tType, _tValue, _tSize, params)
        local tAward = {_type = _tType, _value = _tValue, _size = _tSize}
        for k, v in pairs(params) do
            tAward[k] = v
        end
        awards._awards[#awards._awards+1] = tAward
    end
    
    awards.addAwardFromTable = function(config, prefix, length, params)
        for i=1, length do
            local _tType = config[prefix.."type_"..i]
            if _tType ~= 0 then
                awards.addAward(_tType, config[prefix.."value_"..i], config[prefix.."size_"..i], params)
            end
        end
    end
    
    awards.at = function(index)
        return awards._awards[index]
    end
    
    awards.count = function()
        return #awards._awards
    end
    
    -- 选择武将掉落
    for i=1, 3 do
        local _type = award['type_'..i]
        if _type ~= 0 then
            local _value = award['value_'..i]
            local _min_size = award['min_size_'..i]
            local _max_size = award['max_size_'..i]
            awards.addAward(_type, _value, _min_size == _max_size and _min_size or '('.._min_size..'~'.._max_size..')', {showAmount = true, showSure = true, showEffect=true})
        end
    end
    
    -- 惊喜掉落
    awards.addAwardFromTable(city, "spark_", 6, {showAmount = true})
    -- 普通掉落
    awards.addAwardFromTable(city, "", 3, {showAmount = false})

    if not self._awardList then
        
        local panel = self:getPanelByName("Panel_content")

        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)
        self._awardList = listView
        
        listView:setCreateCellHandler(function()
            return CCSItemCellBase:create("ui_layout/city_PatrolStateAwardItem.json")
        end)
        
    end
    
    self._awardList:setUpdateCellHandler(function(list, index, cell)
        
        local _award = awards.at(index+1)
        local good = G_Goods.convert(_award._type, _award._value)
        -- 背景
        _updateImageView(cell, 'Image_bg', {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
        -- icon
        _updateImageView(cell, 'Image_icon', {texture=good.icon})
        -- 品级框
        _updateImageView(cell, 'Image_frame', {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})
        -- 名称
--        _updateLabel(self, "Label_name", {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
        -- 数量
        _updateLabel(cell, "Label_amount", {visible=_award.showAmount, text="x".._award._size, stroke=Colors.strokeBlack})
        -- 必掉
        _updateImageView(cell, "Image_sure", {visible=_award.showSure ~= nil and _award.showSure or false})
        -- 头像现在需要响应事件用来显示详情
        -- cell:registerWidgetTouchEvent("Image_icon", function(widget, state)
        --     -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
        --     if state == 2 then
        --         require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
        --     end
        -- end)
        cell:registerWidgetClickEvent("Image_icon", function(widget, state)
            require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
        end)
        
        local frame = cell:getImageViewByName("Image_frame")
        frame:removeAllNodes()
        
        if _award.showEffect then
            -- 宝物流光特效
            local EffectNode = require "app.common.effects.EffectNode"
            local effect = EffectNode.new("effect_around1")
            effect:setScale(1.7)
            effect:setPosition(ccp(4, -4))
            frame:addNode(effect)
            effect:play()
        end
        
    end)
    
    self._awardList:initChildWithDataLength(awards.count())
    
    -- 更新价格
    local costType = city["patrol_cost_type_"..patrol_effect]
    
    -- icon
    local _texture, _textureType = G_Path.getPriceTypeIcon(costType)
    _updateImageView(self, "Image_price_type", {texture=_texture, texType = _textureType})
    -- 价格
    _updateLabel(self, "Label_price", {text=city["patrol_cost_value_"..patrol_effect] * CityPatrolSelectLayer.HOURS[patrol_time]})
    
    -- 记录一下价格类型和数量
    self._costType = costType
    self._costAmount = city["patrol_cost_value_"..patrol_effect] * CityPatrolSelectLayer.HOURS[patrol_time]
    
end

function CityPatrolSelectLayer:getSelectKnight() return self._knight.base_id end
function CityPatrolSelectLayer:getSelectTime() return self._patrolTime end
function CityPatrolSelectLayer:getSelectEfficiency() return self._patrolEffect end

function CityPatrolSelectLayer:getSelectPriceTypeAndAmount() return self._costType, self._costAmount end

function CityPatrolSelectLayer:isPatrolling() return self._isPatrolling end

return CityPatrolSelectLayer