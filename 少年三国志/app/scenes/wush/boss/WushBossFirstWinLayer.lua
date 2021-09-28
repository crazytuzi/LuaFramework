-- 三国无双精英boss首胜奖励弹出界面

local WushBossFirstWinLayer = class("WushBossFirstWinLayer",UFCCSModelLayer)

require ("app.cfg.dead_battle_boss_info")

function WushBossFirstWinLayer:ctor(json, color, callback, ...)
    self.super.ctor(self, ...)
    self:adapterWithScreen()
    self:registerTouchEvent(false, true, 0)

    self._callback = callback
    
    self:getLabelByName("Label_Desc"):setText(G_lang:get("LANG_WUSH_BOSS_PASSBOUNSDESC"))
    self:getLabelByName("Label_Desc"):createStroke(Colors.strokeBrown, 1)
        
    local bottomPanel = self:getPanelByName("Panel_Knight")
    
    local bossInfo = dead_battle_boss_info.get(G_Me.wushData:getBossFirstId())
    -- 小乔
    local head = require("app.scenes.common.KnightPic").getHalfNode(bossInfo.monster_image , 0, true)
    bottomPanel:addNode(head)
    head:setPositionX(bottomPanel:getContentSize().width*0.4)
    head:setPositionY(bottomPanel:getContentSize().height*0.57)

    local itemInfo = G_Goods.convert(bossInfo.first_type, bossInfo.first_value)
    -- dump(itemInfo)

    self:getLabelByName("Label_Name"):setColor(Colors.getColor(1))

    self:getLabelByName("Label_Name"):setText(bossInfo.monster_name)
    --self:getLabelByName("Label_Name"):createStroke(Colors.strokeBrown,1)
    self:getImageViewByName("Image_Item_Icon"):loadTexture(itemInfo.icon)
    -- 奖励
    self:getLabelByName("Label_Item_Name"):setText(bossInfo.first_size .. itemInfo.name)
    
    self:getImageViewByName("Image_Continue"):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))))
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:closeAtReturn(true)
end

function WushBossFirstWinLayer.show(callback)
    local layer = WushBossFirstWinLayer.new("ui_layout/wush_BossFirstWinLayer.json", Colors.modelColor, callback)
    uf_sceneManager:getCurScene():addChild(layer)
end

function WushBossFirstWinLayer:onLayerUnload(  )
    if self._callback then
        self._callback()
    end
end

function WushBossFirstWinLayer:onTouchEnd(xPos,yPos)
    self:animationToClose()
end

return WushBossFirstWinLayer

