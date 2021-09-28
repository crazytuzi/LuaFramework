require("app.cfg.days7_activity_info")
local Day7HelpLayer = class("Day7HelpLayer", UFCCSModelLayer)

function Day7HelpLayer:ctor(...)
    self.super.ctor(self,...)
    self:adapterWithScreen()
    self:_init()
end

function Day7HelpLayer:_init()
    local data = days7_activity_info.get(7002)
    local namelist = {}
    for i=1,4 do
        local goodInfo = G_Goods.convert(data["type_" .. i], data["value_" .. i], data["size_" .. i])
        
        local knightImg = self:getImageViewByName("Image_Knight" .. i)
        if knightImg then
            knightImg:loadTexture(goodInfo.icon)

            self:registerWidgetClickEvent("Image_Knight" .. i, function ( ... )
                require("app.scenes.common.baseInfo.BaseInfoKnight").showWidthBaseId(data["value_" .. i], "",uf_notifyLayer)
            end)
        end

        
        local numLabel = self:getLabelByName("Label_Num" .. i)
        if numLabel then
            numLabel:setText("x" .. goodInfo.size)
            numLabel:createStroke(Colors.strokeBrown,1)
        end
        
        local nameLabel = self:getLabelByName("Label_Knight" .. i)
        if nameLabel then
            nameLabel:setText(goodInfo.name)
            nameLabel:setColor(Colors.qualityColors[goodInfo.quality])
            nameLabel:createStroke(Colors.strokeBrown,1)
        end
        namelist[i] = goodInfo.name
    end
    
    self:getLabelByName("Label_TitleUp"):setText(G_lang:get("LANG_DAYS7_FREE"))
    self:getLabelByName("Label_TitleBottom"):setText(G_lang:get("LANG_DAYS7_HALFWELFARE"))
    self:getLabelByName("Label_Desc"):setText(G_lang:get("LANG_DAYS7_DESC"))
    self:getLabelByName("Label_Intro"):setText(G_lang:get("LANG_DAYS7_INTRO"))
    self:getLabelByName("Label_Knight"):setText(G_lang:get("LANG_DAYS7_KNIGHT",{name1=namelist[1],name2=namelist[2],name3=namelist[3],name4=namelist[4]}))
    
    self:getLabelByName("Label_TitleUp"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_TitleBottom"):createStroke(Colors.strokeBrown,1)
    
    self:registerBtnClickEvent("Button_CircleClose",function()
        self:animationToClose() 
    end)
    
    self:registerBtnClickEvent("Button_Close",function()
        self:animationToClose() 
    end)

end

function Day7HelpLayer:onLayerEnter()
    self:registerKeypadEvent(true)
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_1"), "smoving_bounce")
end

function Day7HelpLayer:onBackKeyEvent( ... )
    self:animationToClose()
    return true
end

function Day7HelpLayer.create(...)
    return Day7HelpLayer.new("ui_layout/day7_HelpLayer.json",Colors.modelColor,...)
end
return Day7HelpLayer