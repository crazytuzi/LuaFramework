
local DressRebirthLayer = class("DressRebirthLayer",UFCCSNormalLayer)
require("app.cfg.dress_info")
require("app.cfg.skill_info")
require("app.cfg.knight_info")
local MergeEquipment = require("app.data.MergeEquipment")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local JumpBackCard = require("app.scenes.common.JumpBackCard")
local EffectNode = require "app.common.effects.EffectNode"

function DressRebirthLayer.create( container)   
    local layer = DressRebirthLayer.new("ui_layout/dress_RebirthLayer.json") 
    layer:setContainer(container)
    return layer
end

function DressRebirthLayer:ctor(...)
    self.super.ctor(self, ...)

    self._nameLabel = self:getLabelByName("Label_dressName")
    self._levelLabel = self:getLabelByName("Label_level")
    self._levelTitleLabel = self:getLabelByName("Label_levelTitle")
    self._levelDescLabel = self:getLabelByName("Label_levelDesc")
    self._qipaoLabel = self:getLabelByName("Label_qipao")
    self._heroPanel = self:getPanelByName("Panel_hero")
    self._rebirthButton = self:getButtonByName("Button_rebirth")
    self._costNumLabel = self:getLabelByName("Label_cost_num")
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._levelLabel:createStroke(Colors.strokeBrown, 1)
    self._costNumLabel:createStroke(Colors.strokeBrown, 1)
    self._levelTitleLabel:createStroke(Colors.strokeBrown, 1)
    self._levelDescLabel:createStroke(Colors.strokeBrown, 1)
    self._talkImg = self:getImageViewByName("Image_qipao")
    self._talkImg:setVisible(false)

    self._goldCost = 200
    self._costNumLabel:setText(self._goldCost)
    self._levelTitleLabel:setText(G_lang:get("LANG_DRESS_REBIRTHLEVELTITLE"))

    self:registerBtnClickEvent("Button_rebirth", function()
        -- local show = require("app.scenes.dress.DressStrengthShow").create(self._equipment)
        -- uf_sceneManager:getCurScene():addChild(show)

        if self._playing then
            return
        end
        if self._goldCost > G_Me.userData.gold then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        if self._equipment.level == 1 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_DRESS_NOREBIRTHTALK1"))
            return
        end
        if G_Me.dressData:getDressed() and G_Me.dressData:getDressed().id == self._equipment.id then
            G_MovingTip:showMovingTip(G_lang:get("LANG_DRESS_NOREBIRTHTALK2"))
            return
        end
        G_HandlersManager.dressHandler:sendRecycleDress(self._equipment.id,1)
    end)
    self:getPanelByName("Panel_heroClick"):setTouchEnabled(true)
    self:registerWidgetClickEvent("Panel_heroClick", function()
        local dress = self._equipment
        if dress then
            require("app.scenes.dress.DressInfo").showEquipmentInfo(dress,self._container )
        end
    end)
end

function DressRebirthLayer:onLayerEnter( )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DRESS_RECYCLE, self._onRecycleRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onChangeRsp, self)
    -- self:updataData()
    self._playing = false
end

function DressRebirthLayer:_onRecycleRsp( data)
    if data.ret == 1 then
        if data.type == 1 then
            local show = require("app.scenes.dress.DressRebirthShow").create(self._equipment,data.award)
            uf_sceneManager:getCurScene():addChild(show)
        else
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.award)
            uf_notifyLayer:getModelNode():addChild(_layer,1000)

            local EffectNode = require "app.common.effects.EffectNode"
            self._endEffect = EffectNode.new("effect_particle_star", function(event, frameIndex)
                if event == "forever" then
                    self._endEffect:stop()
                    self._endEffect:removeFromParentAndCleanup(true)
                    self:updataData()
                end
            end)
            self._heroPanel:addNode(self._endEffect,20) 
            self._endEffect:setPositionXY(0,160)
            self._endEffect:setScale(2.0)
            self._endEffect:play()
            self:updataData()
        end
    end
end

function DressRebirthLayer:reset( )
    self._equipment = self._container:getChoosed()
    self:updataData()

    local strPanel = self:getWidgetByName("Panel_rebirth")
    local posx,posy = strPanel:getPosition()
    strPanel:setPosition(ccp(posx,posy-200))
    strPanel:setOpacity(0)
    self:_heroComeAnime()
end

function DressRebirthLayer:setContainer(container )
    self._container = container
end

function DressRebirthLayer:enterAnime( )

end

function DressRebirthLayer:updataData( )
    self._equipmentInfo = G_Me.dressData:getDressInfo(self._equipment.base_id) 
    self:updateInit()
    self:updateHero()
    if self._equipment.level == 1 or (G_Me.dressData:getDressed() and G_Me.dressData:getDressed().id == self._equipment.id) then
        self._levelLabel:setVisible(false)
        self._levelTitleLabel:setVisible(false)
        self._levelDescLabel:setText(G_lang:get("LANG_DRESS_NOREBIRTH"))
        if self._equipment.level == 1 then
            self._qipaoLabel:setText(G_lang:get("LANG_DRESS_NOREBIRTHTALK1"))
        else
            self._qipaoLabel:setText(G_lang:get("LANG_DRESS_NOREBIRTHTALK2"))
        end
    else
        self._levelLabel:setVisible(true)
        self._levelTitleLabel:setVisible(true)
        self._levelDescLabel:setText(G_lang:get("LANG_DRESS_REBIRTHLEVELDES"))
        self._qipaoLabel:setText(G_lang:get("LANG_DRESS_REBIRTHTALK"))
    end
end

function DressRebirthLayer:_onChangeRsp()
    self._equipment = self._container:getChoosed()
    self:updataData()
end

function DressRebirthLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end


function DressRebirthLayer:adapterLayer()
    -- self:adapterWidgetHeight("Panel_Click", "", "", 0, 0)
    -- self:adapterWidgetHeight("Panel_middle", "", "Panel_list", 0, 0)
    self:adapterWidgetHeight("Panel_top", "", "", 0, 160)
    self:enterAnime()
end

function DressRebirthLayer:updateHero()
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    local resid = info.res_id
    if self._equipment then
        resid = G_Me.dressData:getDressedResidWithDress(baseId,self._equipment.base_id)
    end
    if self._knight then
        self._knight:removeFromParentAndCleanup(true)
    end
    self._knight = KnightPic.createKnightPic( resid, self._heroPanel, "knightImg",true )
    -- self._knight:setScale(0.6)
    self._heroPanel:setScale(0.8)
    self:breathe(true)
end


function DressRebirthLayer:breathe(status)
    if status then
        if self._bossEffect == nil then
                    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
                    self._bossEffect = EffectSingleMoving.run(self._heroPanel, "smoving_idle", nil, {})
        end
    else
        if self._bossEffect ~= nil then
                    self._bossEffect:stop()
                    self._bossEffect = nil
        end
    end
end

function DressRebirthLayer:updateInit()
    local info = self._equipmentInfo
    self._nameLabel:setText(info.name)
    self._nameLabel:setColor(Colors.qualityColors[info.quality])
    self._levelLabel:setText(self._equipment.level)
end

function DressRebirthLayer:changeAnime()
    -- local panel = self:getPanelByName("Panel_breathe")
    -- self._breathEffect = EffectSingleMoving.run(self:getPanelByName("Panel_breathe"), "smoving_idle", nil, {})
    -- local guangImg = self:getImageViewByName("Image_guang")
    -- guangImg:stopAllActions()
    -- local fadeInAction = CCFadeIn:create(0.5)
    -- local fadeOutAction = CCFadeOut:create(0.5)
    -- local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
    -- seqAction = CCRepeatForever:create(seqAction)
    -- guangImg:runAction(seqAction)
end

function DressRebirthLayer:choosedDress(id)
    -- print("DressChooseLayer:choosedDress "..id)
    self._equipment = G_Me.dressData:getDressByBaseId(id)
    self:_heroChangeAnime()
    -- self:updataData()
end


function DressRebirthLayer:_heroChangeAnime()
    self._playing = true
    self._container:_setListClick(false)
    self._talkImg:setVisible(false)
    local baseScale = self._knight:getParent():getScale()
    local oldPosx, oldPosy = self._knight:getParent():getPosition()
    self:breathe(false)
    require("app.common.effects.EffectSingleMoving").run(self._knight:getParent(), "smoving_out", function(event)
        if event == "finish" then
            self._knight:setVisible(false)
            self._knight:getParent():setScale(baseScale)
            self._knight:getParent():setPosition(ccp(oldPosx,oldPosy))
            local EffectNode = require "app.common.effects.EffectNode"
            local node = EffectNode.new("effect_yan", function()
                -- if self._callback then
                --     self._callback()
                -- end
                self._knight:setVisible(true)
                self:updataData()
                self:_heroComeAnime(function()
                        -- self:_heroTalk()
                    end)
            end)
            self._knight:getParent():addNode(node)
            node:setPositionXY(50, 200)
            node:setScale(1.5)
            node:play()
            -- self:getWidgetByName("Panel_attr"):runAction(CCMoveBy:create(0.2,ccp(300,0)))
            -- self:getWidgetByName("Button_show"):runAction(CCMoveBy:create(0.2,ccp(300,0)))
            self:getWidgetByName("Panel_rebirth"):runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,-200)),CCFadeOut:create(0.2)))
        end
    end)

end

function DressRebirthLayer:_heroComeAnime(callback)
    self._playing = true
    self._container:_setListClick(false)
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    local resid = info.res_id
    if self._equipment then
        resid = G_Me.dressData:getDressedResidWithDress(baseId,self._equipment.base_id)
    end
    local knight = self._heroPanel
    local worldPos = knight:convertToWorldSpace(ccp(0,0))
    local jumpKnight = JumpBackCard.create()
    local start = knight:convertToWorldSpace(ccp(-400,0))
    knight:getParent():addNode(jumpKnight)
    self._knight:setVisible(false)
     jumpKnight:play(resid, start, 0.5, worldPos, 0.8, function() 
        jumpKnight:removeFromParentAndCleanup(true)
        self._playing = false
        self._container:_setListClick(true)
        self._knight:setVisible(true)
        -- if callback then
        --     callback()
        -- end
        self:_heroTalk()
    end )
     self:getWidgetByName("Panel_rebirth"):runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,200)),CCFadeIn:create(0.2)))
    -- self:getWidgetByName("Panel_attr"):runAction(CCMoveBy:create(0.2,ccp(-300,0)))
    -- self:getWidgetByName("Button_show"):runAction(CCMoveBy:create(0.2,ccp(-300,0)))
end

function DressRebirthLayer:_heroTalk()
    self._playing = true
    self._container:_setListClick(false)
    self._talkImg:setVisible(true)
    self._talkImg:setScale(0.1)
    local animeScale = CCEaseBounceOut:create(CCScaleTo:create(0.5,1))
    local arr = CCArray:create()
    arr:addObject(animeScale)
    arr:addObject(CCCallFunc:create(function()
                if callback then
                    callback()
                else
                    self._playing = false
                    self._container:_setListClick(true)
                end
        end))
    local anime = CCSequence:create(arr)
    self._talkImg:runAction(anime)
end

return DressRebirthLayer

