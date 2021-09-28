local ActivityDuihuanHelp = class("ActivityDuihuanHelp",UFCCSModelLayer)
function ActivityDuihuanHelp.show()
    local layer = ActivityDuihuanHelp.new("ui_layout/activity_ActivityDuihuanHelp.json",Colors.modelColor)
    uf_sceneManager:getCurScene():addChild(layer)
end

function ActivityDuihuanHelp:ctor(...)
    self.super.ctor(self,...)
    self:registerTouchEvent(false, true, 0)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        end)
    self:getLabelByName("Label_content"):setText(G_lang:get("LANG_ACTIVITY_DUIHUAN_XIAN_ZHI"))
end

function ActivityDuihuanHelp:onLayerEnter()
    self:closeAtReturn(true)
    self:showAtCenter(true)
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    EffectSingleMoving.run(self:getWidgetByName("Image_xixu"), "smoving_wait", nil , {position = true} )
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end


function ActivityDuihuanHelp:onTouchEnd( xpos, ypos )
    self:animationToClose()
end


return ActivityDuihuanHelp

