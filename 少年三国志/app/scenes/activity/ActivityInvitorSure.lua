
local ActivityInvitorSure = class("ActivityInvitorSure", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function ActivityInvitorSure:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)

    self._contextLabel = self:getLabelByName("Label_context")
    self._sayLabel = self:getLabelByName("Label_qipao")

    self._sayLabel:setText(G_lang:get("LANG_INVITOR_SURE_TALK"))
    self:initRichTxt()

    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_share", function()
        if G_Me.activityData.invitor.spreadId then
            -- local txt = G_lang:get("LANG_INVITOR_SURE_BASECONTEXT",{serverName=G_PlatformProxy:getLoginServer().name,id=G_Me.activityData.invitor.spreadId})
            local txt = G_lang:getByString(G_Setting:get("invite_content_base"),{serverName=G_PlatformProxy:getLoginServer().name,id=G_Me.activityData.invitor.spreadId,role_name=G_Me.userData.name})
            G_ShareService:weixinShareText(txt)  
        end    
    end)
end

function ActivityInvitorSure.create(...)
    local layer = ActivityInvitorSure.new("ui_layout/activity_ActivityInvitorSure.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function ActivityInvitorSure:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GETSPREADID, self._onSpreadIdRsp, self)
    -- G_HandlersManager.activityHandler:sendGetSpreadId()
    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )

    self:updateView()
end

function ActivityInvitorSure:initRichTxt()
        local label = self:getLabelByName("Label_context")
        if label then 
            local size = label:getSize()
            self._inputRichText = CCSRichText:create(size.width, size.height+30)
            self._inputRichText:setFontSize(label:getFontSize())
            self._inputRichText:setFontName(label:getFontName())
            local color = label:getColor()
            self._defaultColor = ccc3(color.r, color.g, color.b)
            self._inputRichText:setColor(self._defaultColor)
            self._inputRichText:setShowTextFromTop(true)
            local posx,posy = label:getPosition()
            -- self._inputRichText:setAnchorPoint(ccp(0,0.5))
            self._inputRichText:setPosition(ccp(posx,posy))
            label:getParent():addChild(self._inputRichText)
            label:setVisible(false)
    end
end

function ActivityInvitorSure:_updateRichText( txt )
    if self._inputRichText then 
        self._inputRichText:clearRichElement()
        self._inputRichText:appendContent(txt, self._defaultColor)
        self._inputRichText:reloadData()
    end
end

function ActivityInvitorSure:_onSpreadIdRsp(data)
    self:updateView()
end

function ActivityInvitorSure:updateView()
    if G_Me.activityData.invitor.spreadId then
        -- local txt = G_lang:get("LANG_INVITOR_SURE_RICHCONTEXT",{serverName=G_PlatformProxy:getLoginServer().name,id=G_Me.activityData.invitor.spreadId})
        local txt = G_lang:getByString(G_Setting:get("invite_content_rich"),{serverName=G_PlatformProxy:getLoginServer().name,id=G_Me.activityData.invitor.spreadId,role_name=G_Me.userData.name})
        self:_updateRichText(txt)
    else
        G_HandlersManager.activityHandler:sendGetSpreadId()
    end

end

function ActivityInvitorSure:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return ActivityInvitorSure

