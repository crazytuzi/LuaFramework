local ActivityPageGiftCode = class("ActivityPageGiftCode",UFCCSNormalLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
function ActivityPageGiftCode.create()
    local layer = ActivityPageGiftCode.new("ui_layout/activity_ActivityGiftCode.json")
    layer:adapterLayer()
    return layer
end

function ActivityPageGiftCode:ctor(...)
    self.super.ctor(self,...)
    self._layerMoveOffset = 0
    local textfield = self:getTextFieldByName("TextField_giftcode")
    if textfield then 
      textfield:setText(" ")
      textfield:setReturnType(kCCSKeyboardReturnTypeDone)
    end
    self:registerBtnClickEvent("Button_ok",function()
      local textfield = self:getTextFieldByName("TextField_giftcode")
      local code = textfield:getStringValue()
      if not code or code == "" or code == " " then
        G_MovingTip:showMovingTip(G_lang:get("LANG_GET_GIFT_CODE_IS_NIL"))
        return
      end
      G_HandlersManager.bagHandler:sendGiftCode(code)
      end)
    self:_initCaiwenji()
end

function ActivityPageGiftCode:_initCaiwenji()
  local appstoreVersion = (G_Setting:get("appstore_version") == "1")
  local GlobalConst = require("app.const.GlobalConst")
  if appstoreVersion or IS_HEXIE_VERSION  then 
      knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
  else
      knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
  end
  if knight then
      local heroPanel = self:getPanelByName("Panel_knight")
      local KnightPic = require("app.scenes.common.KnightPic")
      KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
      heroPanel:setScale(0.7)
      if self._smovingEffect == nil then
          local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
          self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
      end
  end
end

function ActivityPageGiftCode:updatePage()
end

function ActivityPageGiftCode:showPage()  

end
function ActivityPageGiftCode:onLayerEnter( ... )
  uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GIFT_CODE_INFO, self._onGiftCode, self)
end
function ActivityPageGiftCode:onLayerExit()
  uf_eventManager:removeListenerWithTarget(self)
end
function ActivityPageGiftCode:_onGiftCode(data)
  if data and data.ret == 1 then
    local textfield = self:getTextFieldByName("TextField_giftcode")
    textfield:setText(" ")
    G_MovingTip:showMovingTip(G_lang:get("LANG_GET_GIFT_CODE_SUCCESS"))
  end
end

function ActivityPageGiftCode:adapterLayer()
    self:adapterWidgetHeight("Panel_16","Image_17","",0,100)
end
return ActivityPageGiftCode

