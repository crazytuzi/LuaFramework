-- CityChallengeLayer
-- 领地挑战界面

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        local border = params.border and params.border or 1
        label:createStroke(params.stroke, border)
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

require("app.cfg.city_info")

local CityChallengeLayer = class("CityChallengeLayer", UFCCSNormalLayer)

function CityChallengeLayer.create(...)
    return CityChallengeLayer.new("ui_layout/city_ChallengeMainLayer.json", nil, ...)
end

function CityChallengeLayer:ctor(_, _, index)
    
    CityChallengeLayer.super.ctor(self)
    
    self:initData(index)
    
    -- 手动适配一下位置
    local panel = self:getPanelByName("Panel_knight")
    panel:setPositionY(panel:getPositionY() + (display.height - 853) * 0.4)
    
end

function CityChallengeLayer:initData(index)
    
    -- 记录一下城池的索引
    self._index = index

end

function CityChallengeLayer:getCityIndex() return self._index end

function CityChallengeLayer:onLayerEnter()
    
    self:_initCityChallengeLayer()
    
end

function CityChallengeLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function CityChallengeLayer:_initCityChallengeLayer()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)
    
    local cardJson = decodeJsonFile(G_Path.getKnightPicConfig(city.monster_id))
    assert(cardJson, "Could not read the json with name: "..city.monster_id)
    
    -- 背景界面需要更新，未来打算根据city_info里的资源id来读取
    _updateImageView(self, "Image_bg", {texture=G_Path.getCityBGPathWithId(city.pic2)})
    
    -- 隐藏对话框和人物名称
    _updateImageView(self, "Image_dialog", {visible=false})
    _updateImageView(self, "Image_role_name_bg", {visible=false})

    local cardSprite = nil
    local shadowNode = display.newNode()
    
    local jumpNode = require("app.common.effects.EffectMovingNode").new("moving_card_jump", 
        function(key)
            -- 角色卡牌
            if key == "char" then
                cardSprite = display.newSprite(G_Path.getKnightPic(city.monster_id))
                local anchorPoint = cardSprite:getAnchorPoint()
                local size = cardSprite:getCascadeBoundingBox(true).size
                anchorPoint = ccp((anchorPoint.x * size.width - cardJson.x) / size.width, (anchorPoint.y * size.height - cardJson.y) / size.height)
                cardSprite:setAnchorPoint(anchorPoint)
                return cardSprite
            -- 烟尘
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
                
                -- 对话内容
                _updateLabel(self, "Label_dialog", {text=city.monster_word})
                
            end
        end
    )
    
    jumpNode:setScale(0.6)
    
    local panel = self:getPanelByName("Panel_knight")
    panel:removeAllNodes()
    panel:addNode(jumpNode)
    
    -- 阴影要在人物脚下，所以层次要放在人物下
    jumpNode:addChild(shadowNode, -1)
    
    jumpNode:play()
    
    -- 更新下城市名称
    _updateImageView(self, "Image_city_name", {texture=G_Path.getCityNamePathWithId(city.id)})
    
    -- 角色名字
    _updateLabel(self, "Label_role_name", {text=city.monster_name, color=Colors.qualityColors[city.monster_quality]})
    
    -- 城池描述
    _updateLabel(self, "Label_city_desc", {text=city.directions})
    
    -- 胜利奖励
    _updateLabel(self, "Label_winner_award", {text=G_lang:get('LANG_CITY_CHALLENGE_WINNER_AWARD_DESC'), stroke=Colors.strokeBrown, border = 2})
    
    -- 三个奖励
    for i=1, 3 do
        local _type = city['down_type_'..i]
        -- 是否有效
        if _type ~= 0 then
            local _value = city['down_value_'..i]
            local _size = city['down_size_'..i]
            
            local good = G_Goods.convert(_type, _value)
            assert(good, "Could not find the good with type: ".._type.." and value: ".._value)
            
            -- 背景
            _updateImageView(self, 'Image_award_background'..i, {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
            -- icon
            _updateImageView(self, 'Image_award_icon'..i, {texture=good.icon})
            -- 品级框
            _updateImageView(self, 'Image_award_frame'..i, {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})
            -- 名称
            _updateLabel(self, "Label_award_name"..i, {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
            -- 数量
            _updateLabel(self, "Label_award_amount"..i, {text='x'.._size, stroke=Colors.strokeBlack})
            
            -- 头像现在需要响应事件用来显示详情
            self:registerWidgetTouchEvent("Image_award_icon"..i, function(widget, state)
                -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                if state == 2 then
                    require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
                end
            end)
            
        end
    end
    
    -- 推荐战力
    _updateLabel(self, "Label_power_desc", {text=G_lang:get('LANG_CITY_CHALLENGE_SUGGESTION_POWER_DESC')})
    
    -- 战力
    _updateLabel(self, "Label_power_amount", {text=_convertUnit(city.fight_value)})
    
    -- 挑战按钮
    self:registerBtnClickEvent("Button_challenge", function()
        
        -- 请求攻打
        G_HandlersManager.cityHandler:sendCityAttack()
        
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_ATTACK, function(_, message)

            local battleField = nil
            G_Loading:showLoading(
                function()
                    --创建战斗场景
                    local BattleLayer = require "app.scenes.battle.BattleLayer"
                    local cityIndex = self._index
                    battleField = BattleLayer.create({msg=message.battle_report, skip = BattleLayer.SkipConst.SKIP_NO, battleBg=G_Path.getDungeonBattleMap(31012)}, function(event)
                        if event == BattleLayer.BATTLE_FINISH then
                            local FightEnd = require("app.scenes.common.fightend.FightEnd")
                            local result = G_GlobalFunc.getBattleResult(battleField)
                            FightEnd.show(FightEnd.TYPE_CITY, message.battle_report.is_win ,{awards=message.award},function()
                                uf_sceneManager:replaceScene(require("app.scenes.city.CityScene").new()) 
                            end, result)
                            
                            if message.battle_report.is_win then
                                -- 解锁当前城市
                                G_Me.cityData:resetCityInfo(cityIndex)
                                -- 开启下一个城市
                                G_Me.cityData:unlockCity(math.min(G_Me.cityData.MAX_CITY_NUM, cityIndex+1))
                            end
                        end
                    end)

                    local newScene = display.newScene("CityChallengeScene")
                    newScene:addChild(battleField)

                    uf_sceneManager:replaceScene(newScene)
                end, 
                function ( ... )
                    --开始播放战斗
                    if battleField ~= nil then
                        battleField:play()
                    end
                end
            )
            
        end, self)
        
    end)
        
end

return CityChallengeLayer
