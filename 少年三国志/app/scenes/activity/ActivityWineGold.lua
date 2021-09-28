local ActivityWineGold = class("ActivityWineGold",UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
function ActivityWineGold.create()
    return ActivityWineGold.new("ui_layout/activity_ActivityWineGold.json")
end

function ActivityWineGold:ctor(...)
    self.super.ctor(self,...)
    self:adapterWithScreen()
    self:registerTouchEvent(false,true,0)
    
    self:getLabelByName("Label_Desc"):setText(G_lang:get("LANG_ACTIVITY_WINE_GOLD_DESC"))
    self:getLabelByName("Label_Desc"):createStroke(Colors.strokeBrown,1)
    
    -- 元宝
    self:getLabelByName("Label_Money"):setText(G_lang:get("LANG_STORYDUNGEON_YUANBAO"))
    EffectSingleMoving.run(self:getImageViewByName("Image_Continue"), "smoving_wait", nil , {position = true} )

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion or IS_HEXIE_VERSION then   
        local panel = self:getPanelByName("Panel_Knight")
        if panel then 
            local bgImg = ImageView:create()
            bgImg:loadTexture("ui/arena/xiaozhushou_hexie.png")
            panel:addChild(bgImg) 
            local panelSize = panel:getSize()
            bgImg:setPositionXY(panelSize.width/2, panelSize.height/2)
            self:showWidgetByName("Image_15", false)
        end 
    end

    local yuanbao = self:getImageViewByName("Image_yuanbao")
    if yuanbao then 
        yuanbao:loadTexture("icon/basic/2.png", UI_TEX_TYPE_LOCAL)
    end
end

function ActivityWineGold:setGold(gold)
    self:getLabelByName("Label_Num"):setText(gold)

end

function ActivityWineGold:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function ActivityWineGold:onTouchEnd(xPos,yPos)
    self:close()
end

return ActivityWineGold

