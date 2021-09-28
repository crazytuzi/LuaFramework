
require("app.cfg.battlefield_info")
require("app.cfg.battlefield_position_info")
require("app.cfg.knight_info")

local CrusadeCommon = require("app.scenes.crusade.CrusadeCommon")

local Colors = require("app.setting.Colors")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"

local CrusadeHero = class("CrusadeHero", function (  )
    return CCSItemCellBase:create("ui_layout/crusade_Hero.json")
end)


function CrusadeHero:ctor(gateId, parent)

    self._gateId = gateId 

    self._parent = parent or nil

    local stageId = G_Me.crusadeData:getCurStage()
    self._stageInfo = battlefield_info.get( stageId )

    self._knight = self:getPanelByName("Panel_knight")

    self._knightPic = ImageView:create()
    self._knight:addChild(self._knightPic)

    if self._stageInfo then
        self._knightPic:loadTexture(G_Path.getBattleFieldPic(self._stageInfo.image))

        --2b手动调位置，因为四个据点图片的中心点不一致
        self._knightPic:setPositionY(10)
        if stageId == 2 then
            self._knightPic:setPosition(ccp(-20,0))
        elseif stageId == 1 then
            self._knightPic:setPosition(ccp(20,15))
        end
    end

    self._lock = self:getImageViewByName("Image_lock")
    self._lock:setVisible(false)
        
    self._ko = self:getImageViewByName("Image_ko")
    self._ko:setVisible(false)

    self._infoPanel = self:getPanelByName("Panel_info")

    self._blood = self:getImageViewByName("Image_blood")
    self._blood:setVisible(false)
    
    self._nameLabel = self:getLabelByName("Label_name")
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._levelLabel = self:getLabelByName("Label_level")
    self._levelLabel:createStroke(Colors.strokeBrown, 1)
    self._powerLabel = self:getLabelByName("Label_power")
    self._powerLabel:createStroke(Colors.strokeBrown, 1)

    self._powerLabel:setText("")

    self._progressBar = self:getLoadingBarByName("ProgressBar_power")

    self:registerWidgetTouchEvent("Panel_TouchBox", handler(self, self._onClickKnight))

end

function CrusadeHero:_onClickKnight(widget, event)

    if event == TOUCH_EVENT_BEGAN then
        self._knightPic:setScale(1.1)
    elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
        self._knightPic:setScale(1)
    end

    -- deal with the logic when touch ended
    if event == TOUCH_EVENT_ENDED then

        local heroInfo = G_Me.crusadeData:getHeroInfo(self._gateId)

        if not heroInfo then
            G_MovingTip:showMovingTip(G_lang:get("LANG_CRUSADE_FIGHT_UNLOCK"))
        elseif G_Me.crusadeData:getLeftChallengeTimes() > 0 then
            local soundConst = require("app.const.SoundConst")
            G_SoundManager:playSound(soundConst.GameSound.BUTTON_NORMAL)  
            local preview = require("app.scenes.crusade.CrusadeFightPreview").create(self._gateId, nil)
            uf_sceneManager:getCurScene():addChild(preview)
        --有免费奖励未领取    
        elseif G_Me.crusadeData:canOpenTreasureFree() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_CRUSADE_FREE_TREASURE"))
        elseif G_Me.crusadeData:getFreeResetCount() > 0 then
            local box = require("app.scenes.tower.TowerSystemMessageBox")
            box.showSpecialMessage( G_lang:get("LANG_CRUSADE_FIGHT_NOCHANCE"), 
                function()
                    --G_Me.crusadeData:initData()
                    G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_RESET)
                end,
                function() end, 
                self )           
        elseif G_Me.crusadeData:getResetCount() > 0 then
            local t = G_Me.crusadeData:getResetCost()            
            local box = require("app.scenes.tower.TowerSystemMessageBox")
            box.showMessage( box.TypeCrusade,t, G_Me.crusadeData:getResetCount(), 
                function()
                    local t = G_Me.crusadeData:getResetCost()
                    if G_Me.userData.gold < t then
                      -- G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH"))
                      require("app.scenes.shop.GoldNotEnoughDialog").show()
                      return 
                    end
                    --G_Me.crusadeData:initData()
                    G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_RESET)
                end,
                function() end, 
                self )
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_CRUSADE_CANNOT_CHALLENGE"))
        end

    end

end


function CrusadeHero:updateView()

    local heroInfo = G_Me.crusadeData:getHeroInfo(self._gateId)

    local unLock = false
    local hp_rate = 0
    local fight_value = 0
    local isBeaten = false

    if heroInfo then
        unLock = true
        hp_rate = heroInfo.hp_rate
        fight_value = heroInfo.fight_value

        if unLock and hp_rate <= 0 then
            isBeaten = true
        end
    end

    self._infoPanel:setVisible(false)
    self._ko:setVisible(isBeaten)
    self._blood:setVisible(false)
    self._lock:setVisible(false)
    self._knightPic:setScale(1)
    self._knightPic:setOpacity(255)
    self:getPanelByName("Panel_TouchBox"):setTouchEnabled(true)
    self._nameLabel:setText("")
    self._levelLabel:setText("")
    self._powerLabel:setText("")
    self._progressBar:setPercent(0)

    self:_breathe(false)
    self:_appear(false)
    self:_attacked(false)

    if not isBeaten then

        if G_Me.crusadeData:isBeAttacked(self._gateId) then
            self._blood:setVisible(true)
        end

        if heroInfo then
            --local knightInfo = knight_info.get(heroInfo.user.main_role)       
            --local color = Colors.qualityColors[knightInfo.quality]
            self._nameLabel:setColor(Colors.darkColors.TITLE_01)
            self._nameLabel:setText(heroInfo.name)
            self._levelLabel:setText(G_lang:get("LANG_CRUSADE_LEVEL")..heroInfo.level)

            self._powerLabel:setText(G_lang:get("LANG_CRUSADE_OPP_POWER1")..G_GlobalFunc.ConvertNumToCharacter(fight_value))
            local duration = 0

            --新解锁的不会显示血条
            --if G_Me.crusadeData:getNewUnlocked(heroInfo) then
            --    duration = 0.3
            --end
            self._progressBar:runToPercent(hp_rate, duration)
        end


        self._knightPic:setVisible(true)

        if not unLock then 
            --self._lock:setVisible(true)  --不显示锁了
            self._knightPic:showAsGray(true)
        --新解锁的
        elseif G_Me.crusadeData:getNewUnlocked(heroInfo) then
            self._knightPic:setOpacity(0)
            self:_breathe(true)
            self:_appear(true, hp_rate)
            G_Me.crusadeData:setNewUnlocked(heroInfo,false)
        else          
            self:_breathe(true)
            self._infoPanel:setVisible(true)
            self:getPanelByName("Panel_TouchBox"):setTouchEnabled(true)
            self:_attacked(G_Me.crusadeData:isBeAttacked(self._gateId))

        end    
    else
        self:getPanelByName("Panel_TouchBox"):setTouchEnabled(false)
        self._knightPic:setVisible(false)
    end
end

function CrusadeHero:_appear(status, hp)
    if status then
        self:getPanelByName("Panel_TouchBox"):setTouchEnabled(false)
        if not self._appearEffect then
            self._appearEffect = EffectNode.new("effect_card_show", function(event)
                            if event == "show" then
                                self._knightPic:runAction(CCFadeIn:create(0.5))
                            elseif event == "finish" then
                                self._appearEffect:stop()
                                self._appearEffect:setVisible(false)
                                self._infoPanel:setVisible(true)
                                self:getPanelByName("Panel_TouchBox"):setTouchEnabled(true)
                                self:_attacked(G_Me.crusadeData:isBeAttacked(self._gateId))
                            end
                        end)
            self:getPanelByName("Panel_effect"):addNode(self._appearEffect)
        end
        self._appearEffect:setPositionY(13)
        self._appearEffect:setVisible(true)
        self._appearEffect:play()
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SHOW)
    else
        if self._appearEffect ~= nil then
            self._appearEffect:stop()
            self._appearEffect = nil
        end
    end
end

function CrusadeHero:_breathe(status)
    if status then
        if self._idleEffect == nil then
            local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
            self._idleEffect = EffectSingleMoving.run(self._knight, "smoving_idle", nil, {})
        end
    else
        if self._idleEffect ~= nil then
            self._idleEffect:stop()
            self._idleEffect = nil
        end
    end
end

function CrusadeHero:_attacked(status )

    if status then
        if self._knifeEffect == nil then
            self._knifeEffect = EffectNode.new("effect_knife", 
                function(event, frameIndex)
                    if event == "finish" then
                 
                    end
                end
            )

            self._knifeEffect:setScale(0.7)
            self._knifeEffect:play()
            self:getPanelByName("Panel_effect"):addNode(self._knifeEffect) 
            self._knifeEffect:setZOrder(10)
            self._knifeEffect:setPositionY(45)

        end
    else
        if self._knifeEffect ~= nil then
            self._knifeEffect:stop()
            self._knifeEffect = nil
        end
    end
end


function CrusadeHero:destory( )
    if self._idleEffect ~= nil then
        self._idleEffect:stop()
        self._idleEffect = nil
    end

    if self._knifeEffect ~= nil then
        self._knifeEffect:stop()
        self._knifeEffect = nil
    end

    if self._appearEffect ~= nil then
        self._appearEffect:stop()
        self._appearEffect = nil
    end
    
    --print("-------crusade hero: destory me-------")
end



return CrusadeHero


